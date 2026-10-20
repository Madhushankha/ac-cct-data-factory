"""CCT Test-Execution Report Viewer — ECS-hosted, S3-backed, AC SSO (SAML) protected.

A small Flask server that:
  * authenticates users via the shared Air Canada auth service (Microsoft SAML behind a broker),
  * lists execution reports from an S3 bucket laid out as runs/<ENV>/<FLOW>/<run-id>/...
    (e.g. runs/int/fd/<run>/ — envs, flows and runs are all auto-discovered by listing),
  * streams the report files (index.html, *.evidence.html, metrics, result JSON) from S3.

It reads S3 with the ECS task role (no public bucket, no keys in code). Config is all env vars.

SSO flow (AUTH_MODE=saml) — the broker does all the SAML work, this app just rides its session:
  /login          -> redirect to  <AUTH_SERVICE_URL>/login/<APP_NAME>
  broker          -> Microsoft SAML, validates the assertion, sets the JWT cookie
                     `cct_auth_token` on Domain=.ac-cct-int.cloud.aircanada.com (shared subdomains)
  broker          -> redirects back to  <this app>/callback
  /callback       -> GET <AUTH_SERVICE_URL>/auth/validate with that cookie -> 200 {user{...}} | 401
  /logout         -> clear local session, then the broker's /logout

Env (set in the ECS task definition):
  S3_BUCKET            reports bucket name (e.g. cct-qa-artifacts-int)
  AWS_REGION           bucket region (e.g. ca-central-1)                     [default ca-central-1]
  RUNS_PREFIX          top-level prefix holding the runs                     [default runs]
  ENVS                 optional comma list pinning the envs (default: auto-discover from S3)
  FLASK_SECRET         random string for signing the session cookie
  AUTH_MODE            'saml' = AC SSO; 'basic' = local username/password form login
  AUTH_SERVICE_URL     the AC auth broker  [default https://ac-cct-int.cloud.aircanada.com]
  APP_NAME             this app's name registered with the broker  [default cct-report-viewer]
  DEV_AUTH             "user:pass" — used only when AUTH_MODE=basic (local/dev)
"""
from __future__ import annotations

import os
import re
from functools import wraps

import boto3
import requests
from flask import (Flask, Response, abort, redirect, request, session,
                   stream_with_context, url_for)

import jira_client   # local: Jira/Xray reads + the case->issue mapping store

app = Flask(__name__)
# MUST be stable across gunicorn workers or sessions won't validate. Prod sets FLASK_SECRET via
# Secrets Manager; the dev default keeps local multi-worker logins working (override in prod).
app.secret_key = os.environ.get("FLASK_SECRET") or "cct-viewer-dev-secret-override-in-prod"

BUCKET = os.environ.get("S3_BUCKET", "")
REGION = os.environ.get("AWS_REGION", "ca-central-1")
# Layout is <RUNS_PREFIX>/<ENV>/<FLOW>/<run-id>/... (e.g. runs/int/fd/<run>/). The bucket also holds
# datasets/ and indexes/ at the top level, so discovery starts at RUNS_PREFIX rather than the bucket
# root — otherwise those siblings would show up as environments.
RUNS_PREFIX = os.environ.get("RUNS_PREFIX", "runs").strip("/")
# Envs, flows and runs are all AUTO-DISCOVERED by listing prefixes, so a new env, flow, run or run
# version (…-run-v2) appears with no redeploy and no config. The indexes/*.json manifests in the
# bucket are the producer's job log — they miss runs that exist and list runs that never produced
# artifacts — so they are deliberately NOT used for discovery. ENVS may pin an explicit list.
ENVS_ENV = [s.strip() for s in os.environ.get("ENVS", "").split(",") if s.strip()]
# The layout supports an OPTIONAL suite level between flow and run:
#     runs/<env>/<flow>/<run>/...          (what the producer writes today)
#     runs/<env>/<flow>/<suite>/<run>/...  (when it starts recording SIT vs UAT)
# Which it is, is detected per flow by name rather than configured: a child of the flow whose name
# is one of SUITE_NAMES is a suite, anything else is a run. Both shapes work side by side, so the
# producer can migrate one flow at a time without the viewer changing.
SUITE_NAMES = {s.strip().lower() for s in os.environ.get("SUITE_NAMES", "sit,uat").split(",") if s.strip()}
DEV_AUTH = os.environ.get("DEV_AUTH", "")
# auth mode: 'saml' = AC SSO via the shared broker; 'basic' = local username/password form login.
AUTH_MODE = os.environ.get("AUTH_MODE", "basic").strip().lower()
AUTH_SERVICE_URL = os.environ.get("AUTH_SERVICE_URL", "https://ac-cct-int.cloud.aircanada.com").rstrip("/")
APP_NAME = os.environ.get("APP_NAME", "cct-report-viewer")
AUTH_COOKIE = "cct_auth_token"     # JWT cookie the broker sets across *.ac-cct-int.cloud.aircanada.com

_s3 = boto3.client("s3", region_name=REGION)
# a single path segment (env / flow / run): no '/', no '..', so keys can't escape their prefix
_SAFE_SEG = re.compile(r"^[A-Za-z0-9._-]+$")


# ── AC SSO (SAML via the shared broker) ───────────────────────────────────────
def _saml_enabled() -> bool:
    return AUTH_MODE == "saml"


class AuthServiceUnreachable(Exception):
    """The broker couldn't be reached at all (network/egress), as opposed to rejecting the token.

    Kept distinct on purpose: the ECS tasks sit in private subnets whose only default route is a
    transit gateway, so 'cannot reach the auth service' is a plausible deploy-time failure and must
    not be reported as 'your token is invalid'.
    """


def _validate_token(token: str) -> dict | None:
    """Ask the broker whether this session token is valid; returns the user dict or None.

    The broker owns the SAML assertion and the JWT — this app never parses the token itself,
    it just calls /auth/validate with the cookie the broker set.
    """
    if not token:
        return None
    try:
        r = requests.get(f"{AUTH_SERVICE_URL}/auth/validate", timeout=10,
                         headers={"Cookie": f"{AUTH_COOKIE}={token}"})
    except requests.RequestException as e:
        raise AuthServiceUnreachable(str(e)) from e
    if r.status_code != 200:
        return None
    try:
        return r.json().get("user") or None
    except ValueError:
        return None


def require_auth(fn):
    @wraps(fn)
    def wrap(*a, **k):
        if session.get("user"):
            return fn(*a, **k)
        return redirect(url_for("login"))
    return wrap


_LOGIN_HTML = """<!doctype html><meta charset=utf-8><title>CCT Reports — Sign in</title>
<style>body{margin:0;height:100vh;display:flex;align-items:center;justify-content:center;
background:#0f172a;font-family:system-ui,Segoe UI,sans-serif;color:#e2e8f0}
form{background:#1e293b;border:1px solid #334155;border-top:3px solid #d0021b;border-radius:12px;
padding:30px 32px;width:340px}h2{margin:0 0 4px}.sub{color:#94a3b8;font-size:13px;margin-bottom:18px}
input{width:100%;background:#0f172a;color:#e2e8f0;border:1px solid #334155;border-radius:6px;
padding:10px;margin-bottom:11px;font-size:14px}button{width:100%;background:#d0021b;color:#fff;border:0;
border-radius:6px;padding:10px;font-size:14px;cursor:pointer}.err{color:#f87171;font-size:13px;min-height:18px}
</style><form method=post action=/login>
<h2>✈ CCT Reports</h2><div class=sub>Test Execution Report Viewer — sign in</div>
<input name=user placeholder=Username autofocus autocomplete=username>
<input name=pass type=password placeholder=Password autocomplete=current-password>
<div class=err>%ERR%</div><button>Sign in</button></form>"""


@app.route("/login", methods=["GET", "POST"])
def login():
    # AC SSO: hand off to the broker, which runs the Microsoft SAML flow and comes back to /callback.
    if _saml_enabled():
        return redirect(f"{AUTH_SERVICE_URL}/login/{APP_NAME}")
    # dev / no-SSO: styled form login against DEV_AUTH (user:pass)
    if not DEV_AUTH:
        abort(503, "Auth not configured (set AUTH_MODE=saml for AC SSO, or DEV_AUTH for a local login)")
    u, p = (DEV_AUTH.split(":", 1) + [""])[:2]
    if request.method == "POST":
        if request.form.get("user") == u and request.form.get("pass") == p:
            session["user"] = u
            return redirect(url_for("home"))
        return Response(_LOGIN_HTML.replace("%ERR%", "Invalid username or password."), 401,
                        {"Content-Type": "text/html"})
    return Response(_LOGIN_HTML.replace("%ERR%", ""), 200, {"Content-Type": "text/html"})


_SAML_MISCONFIG_HTML = """<!doctype html><meta charset=utf-8><title>CCT Reports — SSO misconfigured</title>
<style>body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
background:#0f172a;font-family:system-ui,Segoe UI,sans-serif;color:#e2e8f0;padding:20px}
div{background:#1e293b;border:1px solid #334155;border-top:3px solid #d0021b;border-radius:12px;
padding:28px 32px;max-width:640px}code{background:#0f172a;border:1px solid #334155;border-radius:5px;
padding:2px 6px;font-size:13px;word-break:break-all}.s{color:#94a3b8;font-size:14px;line-height:1.6}
</style><div><h2>⚠ SSO is pointed at the wrong place</h2>
<div class=s><p>Microsoft posted the SAML assertion directly to this app. This app is not a SAML
service provider &mdash; the shared auth broker is. The assertion must go to the broker, which
validates it and then redirects here.</p>
<p><b>Fix:</b> set the Reply&nbsp;URL / ACS in Entra to the broker:</p>
<p><code>https://ac-cct-int.cloud.aircanada.com/auth-postback</code></p>
<p>Keep <code>https://cct-report-viewer.ac-cct-int.cloud.aircanada.com/callback</code> as the
broker&rsquo;s redirect target &mdash; that part is already correct.</p></div></div>"""


@app.route("/callback", methods=["GET", "POST"])
@app.route("/auth-postback", methods=["GET", "POST"])   # other AC apps use this path; accept both
def callback():
    """Where the broker lands after SAML. Validate its token, then start a local session.

    The token normally arrives as the shared `cct_auth_token` cookie; the broker may instead pass
    it as ?token=, so accept both (and set the cookie ourselves in that case).
    """
    if not _saml_enabled():
        abort(404)
    # A POSTed SAMLResponse means the IdP's ACS is aimed at this app instead of the broker. We are
    # not a SAML SP (no assertion signature/audience validation here, deliberately — hand-rolling
    # that is how auth bypasses happen), so explain the misconfiguration rather than 405.
    if request.form.get("SAMLResponse") or request.form.get("SAMLart"):
        app.logger.error("SAMLResponse POSTed to %s — Entra ACS should target the broker, not this app",
                         request.path)
        return Response(_SAML_MISCONFIG_HTML, 400, {"Content-Type": "text/html"})
    qtoken = request.args.get("token")
    token = qtoken or request.cookies.get(AUTH_COOKIE, "")
    try:
        user = _validate_token(token)
    except AuthServiceUnreachable as e:
        app.logger.error("auth service unreachable: %s", e)
        return Response(_LOGIN_HTML.replace(
            "%ERR%", "Cannot reach the SSO service (network). Check egress from the tasks."), 503,
            {"Content-Type": "text/html"})
    if not user:
        # not signed in (or the broker couldn't be reached) — show why rather than looping to /login
        return Response(_LOGIN_HTML.replace(
            "%ERR%", "SSO sign-in failed or the session expired. Try again."), 401,
            {"Content-Type": "text/html"})
    session["user"] = (user.get("email") or user.get("username")
                       or user.get("displayName") or "signed-in user")
    resp = redirect(url_for("home"))
    if qtoken:
        resp.set_cookie(AUTH_COOKIE, qtoken, httponly=True, secure=True, samesite="Lax", path="/")
    return resp


_BYE_HTML = """<!doctype html><meta charset=utf-8><title>CCT Reports — Signed out</title>
<style>body{margin:0;height:100vh;display:flex;align-items:center;justify-content:center;
background:#0f172a;font-family:system-ui,Segoe UI,sans-serif;color:#e2e8f0;text-align:center}
div{background:#1e293b;border:1px solid #334155;border-top:3px solid #d0021b;border-radius:12px;padding:30px 34px}
a{display:inline-block;margin-top:14px;background:#d0021b;color:#fff;text-decoration:none;
border-radius:6px;padding:9px 18px;font-size:14px}.s{color:#94a3b8;font-size:13px;margin-top:6px}
</style><div><h2>✈ Signed out</h2>
<div class=s>Your session for this app has ended.<br>Your Microsoft session may still be active.</div>
<a href="/login">Sign in again</a></div>"""


@app.route("/logout")
def logout():
    session.clear()
    if not _saml_enabled():
        return redirect(url_for("home"))
    # The broker exposes no GET /logout (it answers 403), so redirecting there would dump the user
    # on an error page. Instead end our own session and expire the shared cookie on the parent
    # domain, then show a terminal page — redirecting to /login would just bounce through the
    # broker and silently sign back in off the still-valid Microsoft session.
    resp = Response(_BYE_HTML, 200, {"Content-Type": "text/html"})
    resp.set_cookie(AUTH_COOKIE, "", expires=0, path="/",
                    domain=".ac-cct-int.cloud.aircanada.com", secure=True, samesite="Lax")
    return resp


# ── S3 report data ────────────────────────────────────────────────────────────
def _list(prefix: str, delimiter: str = "/") -> dict:
    out = {"folders": [], "files": []}
    tok = None
    while True:
        kw = {"Bucket": BUCKET, "Prefix": prefix, "Delimiter": delimiter}
        if tok:
            kw["ContinuationToken"] = tok
        r = _s3.list_objects_v2(**kw)
        out["folders"] += [p["Prefix"] for p in r.get("CommonPrefixes", [])]
        out["files"] += [{"key": o["Key"], "size": o["Size"],
                          "modified": o["LastModified"].isoformat()} for o in r.get("Contents", [])]
        if not r.get("IsTruncated"):
            break
        tok = r.get("NextContinuationToken")
    return out


def _children(prefix: str) -> list:
    """Immediate sub-folder names under a prefix (one S3 LIST, delimiter '/').

    Names are filtered to the safe charset here, at the point of discovery, so every env /
    flow / run the API hands to the UI is already known-safe to interpolate. A prefix
    someone creates with a quote or angle bracket in it is skipped rather than rendered.
    """
    return sorted(n for n in (p.rstrip("/").split("/")[-1] for p in _list(prefix, "/")["folders"])
                  if _SAFE_SEG.match(n))


def _envs() -> list:
    """Environments = the prefixes under RUNS_PREFIX (int, crt, ...). ENVS pins the list if set."""
    return ENVS_ENV or _children(f"{RUNS_PREFIX}/")


def _seg(*parts) -> str:
    """Validate path segments and join them into an S3 prefix under RUNS_PREFIX.

    Segments are restricted to a safe charset — no '/' and no '..' — so a crafted
    env/flow/run can never escape the intended <RUNS_PREFIX>/<env>/<flow>/<run>/ prefix.
    """
    for p in parts:
        if not p or not _SAFE_SEG.match(p):
            abort(400)
    return "/".join((RUNS_PREFIX,) + parts) + "/"


def _split_suites(names: list) -> tuple:
    """Partition a flow's children into (suites, runs) by name."""
    suites = [n for n in names if n.lower() in SUITE_NAMES]
    return suites, [n for n in names if n.lower() not in SUITE_NAMES]


def _run_prefix(env: str, flow: str, run: str, suite: str = "") -> str:
    """Prefix for one run, with or without the optional suite level."""
    return _seg(env, flow, suite, run) if suite else _seg(env, flow, run)


def _safe_key(key: str) -> str:
    """Validate a full object key sits under a real <RUNS_PREFIX>/<env>/<flow>/<run>/ prefix.

    Guards the two routes that take a raw key (/report/<key>, /download?file=): the key must
    start with RUNS_PREFIX, the env/flow/run segments must be safe names, the env must
    actually exist, and no segment may be empty or '..' — so a key can't reach anything
    outside the reports area (datasets/ and indexes/ included).
    """
    parts = key.split("/")
    # runs / env / flow / run / file…  → at least five segments
    if len(parts) < 5 or any(p in ("", ".", "..") for p in parts):
        abort(403)
    if parts[0] != RUNS_PREFIX:
        abort(403)
    if not all(_SAFE_SEG.match(p) for p in parts[1:4]) or parts[1] not in _envs():
        abort(403)
    return key


@app.route("/api/envs")
@require_auth
def api_envs():
    return {"envs": _envs(), "user": session.get("user"), "bucket": BUCKET}


@app.route("/api/flows")
@require_auth
def api_flows():
    """Flows within an env. Without ?env=, returns the env list too (first page load)."""
    env = request.args.get("env", "")
    envs = _envs()
    if not env:
        # default to the first env that actually has flows, so a first-time load never
        # lands on an empty screen (an env may exist as a prefix but hold no runs yet)
        env = next((e for e in envs if _children(_seg(e))), envs[0] if envs else "")
    if not env:
        return {"envs": [], "env": "", "flows": [], "user": session.get("user"), "bucket": BUCKET}
    flows = _children(_seg(env))
    return {"envs": envs, "env": env, "flows": flows,
            "user": session.get("user"), "bucket": BUCKET}


@app.route("/api/runs")
@require_auth
def api_runs():
    """Runs in a flow. If the flow uses the suite level, ?suite= selects which one.

    Without ?suite= the response lists any suites found so the UI can offer them, plus any runs
    sitting directly under the flow (the layout the producer writes today).
    """
    env, flow = request.args.get("env", ""), request.args.get("flow", "")
    suite = request.args.get("suite", "")
    if suite:
        return {"env": env, "flow": flow, "suite": suite, "suites": [],
                "runs": sorted(_children(_seg(env, flow, suite)), reverse=True)}
    suites, runs = _split_suites(_children(_seg(env, flow)))
    return {"env": env, "flow": flow, "suite": "", "suites": sorted(suites),
            "runs": sorted(runs, reverse=True)}


@app.route("/api/files")
@require_auth
def api_files():
    env, flow, run = (request.args.get("env", ""), request.args.get("flow", ""),
                      request.args.get("run", ""))
    base = _run_prefix(env, flow, run, request.args.get("suite", ""))
    files = [{"name": f["key"][len(base):], "key": f["key"], "size": f["size"],
              "modified": f["modified"]}
             for f in _list(base, delimiter="")["files"] if f["key"] != base]
    files.sort(key=lambda f: f["modified"], reverse=True)  # latest updated first
    return {"base": base, "files": files}


# Objects in the reports bucket are uploaded without a content type, so S3 reports them as
# binary/octet-stream. Served as-is that makes the browser DOWNLOAD each report instead of
# rendering it in the viewer's iframe, so treat the generic types as "unset" and fall back to
# the extension. (The old cct-qa-results bucket did set text/html, which is why this only
# started mattering with cct-qa-artifacts-int.)
_GENERIC_CTYPES = {"", "binary/octet-stream", "application/octet-stream"}
_EXT_CTYPES = ((".html", "text/html; charset=utf-8"), (".htm", "text/html; charset=utf-8"),
               (".json", "application/json"), (".xml", "application/xml"),
               (".txt", "text/plain; charset=utf-8"), (".css", "text/css"),
               (".js", "application/javascript"), (".png", "image/png"),
               (".jpg", "image/jpeg"), (".svg", "image/svg+xml"))


def _ctype_for(key: str, s3_ctype: str | None) -> str:
    """Content type to serve a report with: S3's, unless it's generic — then by extension."""
    if (s3_ctype or "").split(";")[0].strip().lower() not in _GENERIC_CTYPES:
        return s3_ctype
    k = key.lower()
    return next((ct for ext, ct in _EXT_CTYPES if k.endswith(ext)), "application/octet-stream")


def _read_json(key: str):
    import json
    try:
        return json.loads(_s3.get_object(Bucket=BUCKET, Key=key)["Body"].read())
    except Exception:
        return None


@app.route("/api/runsummary")
@require_auth
def api_runsummary():
    """Per-case results for a run (read the *.result.json objects from S3) + pass/fail counts."""
    env, flow, run = (request.args.get("env", ""), request.args.get("flow", ""),
                      request.args.get("run", ""))
    base = _run_prefix(env, flow, run, request.args.get("suite", ""))
    files = _list(base, delimiter="")["files"]
    names = {f["key"][len(base):] for f in files}
    cases, p, f = [], 0, 0
    for key in sorted(fk["key"] for fk in files if fk["key"].endswith(".result.json")):
        d = _read_json(key)
        if not d:
            continue
        cid = d.get("case", {}).get("test_case") or key[len(base):].replace(".result.json", "")
        ok = bool(d.get("verdict", {}).get("matches_expected"))
        p, f = (p + 1, f) if ok else (p, f + 1)
        exp = d.get("case", {})
        amt = exp.get("expected_amount") or {}
        cases.append({
            "id": cid, "result": "Passed" if ok else "Failed",
            "expected": f"{exp.get('expected_status','')} · {exp.get('expected_system_code','')}"
                        + (f" · {amt.get('currency','')} {amt.get('value','')}" if amt else ""),
            "actual": d.get("verdict", {}).get("decision", ""),
            "evidence": f"{base}{cid}.evidence.html" if f"{cid}.evidence.html" in names else None,
            "quality": f"{base}{cid}.quality.html" if f"{cid}.quality.html" in names else None,
        })
    return {"env": env, "flow": flow, "run": run, "passed": p, "failed": f, "cases": cases,
            "has_index": "index.html" in names, "has_metrics": "metrics/report.html" in names}


@app.route("/api/analytics")
@require_auth
def api_analytics():
    """Analytics for a run from the TWO pre-computed files (metrics.json + analysis.json) — fast, no
    per-result reads. Decision mix comes from the metrics confusion matrix (column sums = actuals)."""
    from collections import Counter
    env, flow, run = (request.args.get("env", ""), request.args.get("flow", ""),
                      request.args.get("run", ""))
    base = _run_prefix(env, flow, run, request.args.get("suite", ""))
    m = _read_json(base + "metrics/metrics.json") or {}
    a = _read_json(base + "analysis/analysis.json") or {}
    conf = m.get("confusion", {})
    dec: dict = {}
    labels, matrix = conf.get("labels", []), conf.get("matrix", [])
    for j, lab in enumerate(labels):          # column sum = how many the bot actually returned `lab`
        tot = sum(row[j] for row in matrix if j < len(row))
        if tot:
            dec[lab] = tot
    # by_feed is keyed by the short feed name ("fd"), which is exactly the flow segment now
    by_feed = a.get("summary", {}).get("by_feed", {}) or {}
    summary = by_feed.get(flow.lower(), {})
    if not summary:
        summary = next(iter((a.get("summary", {}).get("by_feed", {}) or {}).values()), {})
    return {"headline": m.get("headline", {}), "confusion": conf,
            "stage_coverage": m.get("trajectory", {}).get("stage_coverage", {}),
            "decisions": dec, "grades": dict(Counter(g.get("grade") for g in a.get("grades", []))),
            "summary": summary, "clusters": a.get("clusters", []),
            "has_metrics": bool(m), "has_analysis": bool(a)}


# ── Jira / Xray ───────────────────────────────────────────────────────────────
# Two views, both read-only: the tickets on each flow's Jira component, and the per-test statuses
# of each flow's Xray Test Execution. Neither needs the S3-case -> Jira-issue mapping (that only
# gates the per-test-case button), so they work today. Roll-ups are cached — see jira_client.cached.
def _jira_guard():
    """Return an error response if Jira isn't usable, else None."""
    if not jira_client.configured():
        return {"error": "jira-not-configured",
                "detail": "Set JIRA_EMAIL and JIRA_API_TOKEN"}, 503
    return None


@app.route("/api/jira/flows")
@require_auth
def api_jira_flows():
    """Overview row per flow: ticket totals + open/resolved bug counts."""
    err = _jira_guard()
    if err:
        return err
    try:
        rows = jira_client.cached("bugs_summary", jira_client.bugs_summary)
    except jira_client.JiraUnreachable as e:
        app.logger.error("jira unreachable: %s", e)
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503
    return {"flows": rows, "base": jira_client.JIRA_BASE_URL,
            "cache_age": jira_client.cache_age("bugs_summary")}


@app.route("/api/jira/tickets")
@require_auth
def api_jira_tickets():
    """Every ticket on one flow's component (paged through in full)."""
    err = _jira_guard()
    if err:
        return err
    flow = request.args.get("flow", "")
    itype = request.args.get("type", "")
    if not jira_client.flow_cfg(flow):
        return {"error": "unknown-flow", "flow": flow}, 404
    key = f"tickets:{flow}:{itype}"
    try:
        return jira_client.cached(key, lambda: jira_client.tickets(flow, issuetype=itype))
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503


@app.route("/api/jira/executions")
@require_auth
def api_jira_executions():
    """Xray Test Execution status roll-up per flow, for one suite (sit | uat)."""
    err = _jira_guard()
    if err:
        return err
    if not jira_client.xray_configured():
        return {"error": "xray-not-configured",
                "detail": "Set XRAY_CLIENT_ID and XRAY_CLIENT_SECRET"}, 503
    suite = (request.args.get("suite", "sit") or "sit").lower()
    if suite not in ("sit", "uat"):
        abort(400)
    key = f"exec_summary:{suite}"
    try:
        rows = jira_client.cached(key, lambda: jira_client.execution_summary(suite))
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503
    return {"suite": suite, "flows": rows, "base": jira_client.JIRA_BASE_URL,
            "cache_age": jira_client.cache_age(key)}


@app.route("/api/jira/execution")
@require_auth
def api_jira_execution():
    """Per-test detail for one flow's Test Execution(s)."""
    err = _jira_guard()
    if err:
        return err
    flow, suite = request.args.get("flow", ""), (request.args.get("suite", "sit") or "sit").lower()
    if not jira_client.flow_cfg(flow):
        return {"error": "unknown-flow", "flow": flow}, 404
    if suite not in ("sit", "uat"):
        abort(400)
    key = f"exec:{flow}:{suite}"
    try:
        return jira_client.cached(key, lambda: jira_client.execution(flow, suite))
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503


@app.route("/api/jira/casemap")
@require_auth
def api_jira_casemap():
    """The stored S3-case -> Jira-issue mapping for a flow (empty until cases are bound)."""
    flow = request.args.get("flow", "")
    return {"flow": flow, "map": jira_client.get_cases(flow),
            "base": jira_client.JIRA_BASE_URL}


@app.route("/api/jira/refresh", methods=["POST"])
@require_auth
def api_jira_refresh():
    return {"cleared": jira_client.cache_clear()}


def _case_facts(env: str, flow: str, run: str, case_id: str, suite: str = "") -> dict:
    """Pull the ground truth for one test case out of its result.json in S3.

    The bug text has to come from the run itself, not from anything the browser sends, so a
    crafted request can't dictate what gets written into Jira.
    """
    base = _run_prefix(env, flow, run, suite)
    d = _read_json(f"{base}{case_id}.result.json")
    if d is None:
        abort(404, "no result.json for that case")
    case, verdict = d.get("case", {}) or {}, d.get("verdict", {}) or {}
    amt = case.get("expected_amount") or {}
    expected = " · ".join(x for x in [
        case.get("expected_status", ""), case.get("expected_system_code", ""),
        f"{amt.get('currency','')} {amt.get('value','')}".strip() if amt else ""] if x)
    ctx = " · ".join(x for x in [
        f"PNR {case.get('pnr','')}" if case.get("pnr") else "",
        f"regime {case.get('regime','')}" if case.get("regime") else "",
        f"passenger {case.get('passenger','')}" if case.get("passenger") else ""] if x)
    return {"passed": bool(verdict.get("matches_expected")), "env": env, "run": run,
            "expected": expected or "-", "actual": verdict.get("decision", "-"),
            "headline": (verdict.get("decision") or "automated test failure"),
            "context": ctx}


def _run_cases(env: str, flow: str, run: str, suite: str = "") -> list:
    """The test cases in a run, with the facts the matcher scores on, read from S3."""
    base = _run_prefix(env, flow, run, suite)
    out = []
    for f in _list(base, delimiter="")["files"]:
        name = f["key"][len(base):]
        if not name.endswith(".result.json"):
            continue
        d = _read_json(f["key"]) or {}
        case = d.get("case", {}) or {}
        cid = case.get("test_case") or name.replace(".result.json", "")
        out.append({"case_id": cid,
                    "regime": case.get("regime", ""),
                    "expected_status": case.get("expected_status", ""),
                    "expected_system_code": case.get("expected_system_code", ""),
                    "expected_amount": case.get("expected_amount") or {},
                    "passed": bool((d.get("verdict", {}) or {}).get("matches_expected"))})
    out.sort(key=lambda c: c["case_id"])
    return out


@app.route("/api/jira/mapping")
@require_auth
def api_jira_mapping():
    """Ranked Xray-test candidates for each case in a run. Suggests only — commits nothing."""
    err = _jira_guard()
    if err:
        return err
    env, flow, run = (request.args.get("env", ""), request.args.get("flow", ""),
                      request.args.get("run", ""))
    suite = (request.args.get("suite", "sit") or "sit").lower()
    if not jira_client.flow_cfg(flow):
        return {"error": "unknown-flow", "flow": flow}, 404
    if suite not in ("sit", "uat"):
        abort(400)
    cases = _run_cases(env, flow, run, request.args.get("path_suite", ""))
    try:
        d = jira_client.suggest(flow, suite, cases)
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503
    d.update(env=env, run=run, base=jira_client.JIRA_BASE_URL)
    return d


@app.route("/api/jira/mapping", methods=["POST"])
@require_auth
def api_jira_mapping_save():
    """Confirm one case -> Xray test pairing (or clear it by sending an empty key)."""
    b = request.get_json(silent=True) or {}
    flow, case_id, xray = b.get("flow", ""), b.get("case", ""), (b.get("xray_key") or "").strip()
    if not jira_client.flow_cfg(flow) or not _SAFE_SEG.match(case_id or ""):
        abort(400)
    if xray and not re.match(r"^[A-Z][A-Z0-9]+-\d+$", xray):
        return {"error": "bad-key", "detail": "expected an issue key like CHAI-24816"}, 400
    return {"saved": jira_client.bind_case(flow, case_id, xray_key=xray)}


@app.route("/api/jira/link", methods=["POST"])
@require_auth
def api_jira_link():
    """Attach a case's bug to its test run inside the flow's Test Execution."""
    err = _jira_guard()
    if err:
        return err
    b = request.get_json(silent=True) or {}
    flow, case_id = b.get("flow", ""), b.get("case", "")
    suite = (b.get("suite") or "sit").lower()
    if not jira_client.flow_cfg(flow) or not _SAFE_SEG.match(case_id or ""):
        abort(400)
    row = jira_client.get_case(flow, case_id) or {}
    bug = (b.get("bug_key") or row.get("bug_key") or "").strip()
    if not bug:
        return {"ok": False, "reason": "no bug recorded for this case yet"}, 400
    try:
        return jira_client.link_defect(flow, case_id, bug, suite)
    except jira_client.WritesDisabled:
        return {"error": "writes-disabled"}, 403
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503


@app.route("/api/jira/bug", methods=["POST"])
@require_auth
def api_jira_bug():
    """Create-or-update the Jira bug for one test case.

    POST {env, flow, run, case, commit}. With commit falsy (the default) this only returns the
    plan — the exact payload, attachment name and comment — so the UI can show it for confirmation.
    Nothing reaches Jira until a second call arrives with commit true.
    """
    err = _jira_guard()
    if err:
        return err
    b = request.get_json(silent=True) or {}
    env, flow, run = b.get("env", ""), b.get("flow", ""), b.get("run", "")
    case_id = b.get("case", "")
    commit = bool(b.get("commit"))
    if not _SAFE_SEG.match(case_id or ""):
        abort(400)
    if not jira_client.flow_cfg(flow):
        return {"error": "unknown-flow", "flow": flow,
                "detail": "no Jira component configured for this flow in jira_flows.json"}, 404
    path_suite = b.get("path_suite", "")   # suite level in the S3 path, if the run has one
    facts = _case_facts(env, flow, run, case_id, path_suite)

    evidence = None
    key = f"{_run_prefix(env, flow, run, path_suite)}{case_id}.evidence.html"
    try:
        evidence = _s3.get_object(Bucket=BUCKET, Key=key)["Body"].read()
    except Exception:
        evidence = None      # a case with no evidence file still gets a bug, just no attachment

    try:
        return jira_client.bug_action(flow, case_id, facts, evidence=evidence, commit=commit,
                                      suite=(b.get("suite") or "sit").lower())
    except jira_client.WritesDisabled:
        return {"error": "writes-disabled", "detail": "JIRA_WRITE=0 on this deployment"}, 403
    except jira_client.JiraUnreachable as e:
        return {"error": "jira-unreachable", "detail": str(e)[:200]}, 503
    except requests.HTTPError as e:
        detail = ""
        try:
            j = e.response.json()
            detail = "; ".join(j.get("errorMessages", []) +
                               [f"{k}: {v}" for k, v in (j.get("errors") or {}).items()])
        except ValueError:
            detail = e.response.text[:200]
        app.logger.error("jira write failed %s: %s", e.response.status_code, detail)
        return {"error": "jira-rejected", "status": e.response.status_code,
                "detail": detail or "see logs"}, 502


@app.route("/download")
@require_auth
def download():
    """Zip report files for a run from S3. ?env=&flow=&run=&kind=all|evidence|quality, or ?file=<key>."""
    import io
    import zipfile
    if request.args.get("file"):
        key = _safe_key(request.args["file"])
        obj = _s3.get_object(Bucket=BUCKET, Key=key)
        return Response(obj["Body"].read(), headers={
            "Content-Disposition": f'attachment; filename="{key.split("/")[-1]}"'},
            content_type=obj.get("ContentType") or "application/octet-stream")
    env, flow, run = (request.args.get("env", ""), request.args.get("flow", ""),
                      request.args.get("run", ""))
    kind = request.args.get("kind", "all")
    base = _run_prefix(env, flow, run, request.args.get("suite", ""))
    keep = (lambda n: n.endswith(".evidence.html")) if kind == "evidence" else \
           (lambda n: n.endswith(".quality.html")) if kind == "quality" else (lambda n: True)
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        for fk in _list(base, delimiter="")["files"]:
            name = fk["key"][len(base):]
            if name and keep(name):
                z.writestr(f"{run}/{name}", _s3.get_object(Bucket=BUCKET, Key=fk["key"])["Body"].read())
    return Response(buf.getvalue(), content_type="application/zip",
                    headers={"Content-Disposition": f'attachment; filename="{run}_{kind}.zip"'})


@app.route("/report/<path:key>")
@require_auth
def report(key):
    """Stream a report file from S3 (only within a discovered <env>/<flow>/<run>/ prefix)."""
    key = _safe_key(key)
    try:
        obj = _s3.get_object(Bucket=BUCKET, Key=key)
    except Exception:
        abort(404)
    ctype = _ctype_for(key, obj.get("ContentType"))
    dl = request.args.get("dl")
    hdrs = {}
    if dl:
        hdrs["Content-Disposition"] = f'attachment; filename="{key.split("/")[-1]}"'
    return Response(stream_with_context(obj["Body"].iter_chunks()), content_type=ctype, headers=hdrs)


@app.route("/")
@require_auth
def home():
    return app.send_static_file("index.html")


@app.route("/healthz")
def healthz():
    return {"ok": True}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
