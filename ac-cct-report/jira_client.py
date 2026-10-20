"""Jira / Xray access for the CCT report viewer.

Two read paths back the two Jira views in the UI:

  tickets(flow, ...)     -> Jira JQL over the flow's component  -> every ticket + resolved counts
  execution(flow, suite) -> Xray GraphQL over the flow's Test Execution issues -> per-test statuses

and one mapping store (an S3 object per flow) recording which Jira issues a test case belongs to:

  runs/<env>/<flow>/<run>/FD_TC_001...   <->   CHAI-24816 (the Xray test)   +   CHAI-27992 (the bug)

The mapping is NOT derivable: S3 case ids look like `FD_TC_001` while Xray test summaries look like
`[FD-SIT-008] APPR eligible - ...`, and no Jira issue mentions an `FD_TC_*` id anywhere. So the
store starts empty and is filled in deliberately (see bind_case), rather than guessed at.

Config: credentials come from the environment (see .env / deploy/.env.<env>); the flow -> component
-> Test Execution map is jira_flows.json next to this file, so retargeting a flow needs no code
change. Nothing here writes to Jira — creating and updating bugs is a separate, later step, and
this module deliberately has no code path that can POST an issue yet.
"""
from __future__ import annotations

import base64
import json
import os
import re
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import requests

JIRA_BASE_URL = os.environ.get("JIRA_BASE_URL", "https://aircanada.atlassian.net").rstrip("/")
JIRA_PROJECT = os.environ.get("JIRA_PROJECT", "CHAI")
JIRA_EMAIL = os.environ.get("JIRA_EMAIL", "")
JIRA_API_TOKEN = os.environ.get("JIRA_API_TOKEN", "")
XRAY_BASE_URL = os.environ.get("XRAY_BASE_URL", "https://xray.cloud.getxray.app").rstrip("/")
XRAY_CLIENT_ID = os.environ.get("XRAY_CLIENT_ID", "")
XRAY_CLIENT_SECRET = os.environ.get("XRAY_CLIENT_SECRET", "")
TIMEOUT = int(os.environ.get("JIRA_TIMEOUT", "20"))

_FLOWS_FILE = Path(__file__).with_name("jira_flows.json")


CACHE_TTL = int(os.environ.get("JIRA_CACHE_TTL", "300"))
_cache: dict = {}
_cache_lock = threading.Lock()


def cached(key: str, fn, ttl: int = None):
    """Memoise an expensive Jira/Xray roll-up for CACHE_TTL seconds.

    The summary views cost ~30-55s cold (27 count calls, ~15 Xray pages, all serial against a
    remote API), which is far too slow to do on every page load. Cache is per gunicorn worker and
    dies with the task — fine for a dashboard whose numbers move on a human timescale. Errors are
    never cached, so a transient failure doesn't stick for five minutes.
    """
    ttl = CACHE_TTL if ttl is None else ttl
    now = time.time()
    with _cache_lock:
        hit = _cache.get(key)
        if hit and now - hit[0] < ttl:
            return hit[1]
    val = fn()
    with _cache_lock:
        _cache[key] = (now, val)
    return val


def cache_clear() -> int:
    with _cache_lock:
        n = len(_cache)
        _cache.clear()
    return n


def cache_age(key: str):
    with _cache_lock:
        hit = _cache.get(key)
    return round(time.time() - hit[0]) if hit else None


class JiraUnreachable(Exception):
    """Jira/Xray could not be reached at all, as opposed to rejecting the request.

    Same reasoning as the auth broker in app.py: the ECS tasks sit in private subnets whose only
    default route is a transit gateway, so 'no egress to atlassian.net' is a plausible deploy-time
    failure and must not be reported to the user as 'no tickets found'.
    """


def configured() -> bool:
    return bool(JIRA_EMAIL and JIRA_API_TOKEN)


def xray_configured() -> bool:
    return bool(XRAY_CLIENT_ID and XRAY_CLIENT_SECRET)


# ── flow configuration ────────────────────────────────────────────────────────
_flows_cache: dict | None = None


def flows() -> dict:
    """The flow -> {component, labels, executions} map from jira_flows.json."""
    global _flows_cache
    if _flows_cache is None:
        try:
            _flows_cache = json.loads(_FLOWS_FILE.read_text(encoding="utf-8")).get("flows", {})
        except (OSError, ValueError):
            _flows_cache = {}
    return _flows_cache


def flow_cfg(flow: str) -> dict:
    return flows().get((flow or "").lower(), {})


# ── HTTP ──────────────────────────────────────────────────────────────────────
def _auth_header() -> str:
    return "Basic " + base64.b64encode(f"{JIRA_EMAIL}:{JIRA_API_TOKEN}".encode()).decode()


def _jira_get(path: str, params: dict | None = None) -> dict:
    try:
        r = requests.get(f"{JIRA_BASE_URL}{path}", params=params, timeout=TIMEOUT,
                         headers={"Authorization": _auth_header(), "Accept": "application/json"})
    except requests.RequestException as e:
        raise JiraUnreachable(str(e)) from e
    r.raise_for_status()
    return r.json()


_xray_token: str = ""
_xray_token_at: float = 0.0
_xray_lock = threading.Lock()


def _xray_auth() -> str:
    """Xray Cloud bearer token, cached. Tokens last ~1h; refresh a little before that."""
    global _xray_token, _xray_token_at
    with _xray_lock:
        if _xray_token and (time.time() - _xray_token_at) < 3000:
            return _xray_token
        try:
            r = requests.post(f"{XRAY_BASE_URL}/api/v2/authenticate", timeout=TIMEOUT,
                              headers={"Content-Type": "application/json"},
                              json={"client_id": XRAY_CLIENT_ID, "client_secret": XRAY_CLIENT_SECRET})
        except requests.RequestException as e:
            raise JiraUnreachable(str(e)) from e
        r.raise_for_status()
        _xray_token, _xray_token_at = r.text.strip('"'), time.time()
        return _xray_token


def _xray_graphql(query: str) -> dict:
    try:
        r = requests.post(f"{XRAY_BASE_URL}/api/v2/graphql", timeout=TIMEOUT,
                          headers={"Authorization": f"Bearer {_xray_auth()}",
                                   "Content-Type": "application/json"},
                          json={"query": query})
    except requests.RequestException as e:
        raise JiraUnreachable(str(e)) from e
    r.raise_for_status()
    return r.json()


# ── view 1: the tickets for a flow ────────────────────────────────────────────
def _jql_for(flow: str, issuetype: str = "") -> str:
    cfg = flow_cfg(flow)
    comp = cfg.get("component")
    if not comp:
        return ""
    jql = f'project={JIRA_PROJECT} AND component="{comp}"'
    if issuetype:
        jql += f' AND issuetype="{issuetype}"'
    return jql + " ORDER BY created DESC"


_FIELDS = "key,summary,status,resolution,issuetype,priority,created,updated,assignee,labels"


def _search_all(jql: str, cap: int = 1000) -> tuple:
    """Page through /search/jql until exhausted.

    The v3 JQL search returns a `nextPageToken` and NO usable `total`, so counting the first page
    would under-report every flow with more than a page of tickets (FD alone has ~100 bugs). Returns
    (issues, truncated) — truncated is True only if we hit `cap`, so the caller can say so rather
    than quietly presenting a short count as the whole picture.
    """
    issues, token = [], None
    while len(issues) < cap:
        params = {"jql": jql, "maxResults": min(100, cap - len(issues)), "fields": _FIELDS}
        if token:
            params["nextPageToken"] = token
        d = _jira_get("/rest/api/3/search/jql", params)
        issues += d.get("issues", [])
        token = d.get("nextPageToken")
        if not token or d.get("isLast") or not d.get("issues"):
            return issues, False
    return issues, True


def tickets(flow: str, issuetype: str = "", limit: int = 1000) -> dict:
    """Every ticket on a flow's component, with resolved/open counts.

    Resolution is read from the `resolution` field rather than the status name: CHAI uses several
    workflows, so 'has a resolution' is the portable definition of done here.
    """
    jql = _jql_for(flow, issuetype)
    if not jql:
        return {"flow": flow, "configured": False, "issues": [], "total": 0}
    raw, truncated = _search_all(jql, cap=limit)
    issues, counts, by_type = [], {"resolved": 0, "open": 0}, {}
    for i in raw:
        f = i.get("fields", {})
        res = (f.get("resolution") or {}).get("name")
        itype = (f.get("issuetype") or {}).get("name", "?")
        by_type[itype] = by_type.get(itype, 0) + 1
        counts["resolved" if res else "open"] += 1
        issues.append({
            "key": i["key"], "url": f"{JIRA_BASE_URL}/browse/{i['key']}",
            "summary": f.get("summary", ""), "type": itype,
            "status": (f.get("status") or {}).get("name", ""),
            "resolution": res,
            "priority": (f.get("priority") or {}).get("name"),
            "assignee": (f.get("assignee") or {}).get("displayName"),
            "labels": f.get("labels", []),
            "created": f.get("created", "")[:10], "updated": f.get("updated", "")[:10],
        })
    cfg = flow_cfg(flow)
    return {"flow": flow, "configured": True, "label": cfg.get("label", flow),
            "component": cfg.get("component"), "jql": jql,
            "total": len(issues), "truncated": truncated,
            "counts": counts, "by_type": by_type, "issues": issues}


def count(jql: str) -> int:
    """Issue count for a JQL, in ONE call.

    The summary view needs totals, not issues — and the components are big (Flight Disruption alone
    has 662 issues, seven pages). Paging all of them for nine flows would be ~60 requests per
    dashboard load, so counts come from the count endpoint and only the detail view fetches issues.
    """
    try:
        r = requests.post(f"{JIRA_BASE_URL}/rest/api/3/search/approximate-count", timeout=TIMEOUT,
                          headers={"Authorization": _auth_header(), "Accept": "application/json",
                                   "Content-Type": "application/json"},
                          json={"jql": jql})
    except requests.RequestException as e:
        raise JiraUnreachable(str(e)) from e
    r.raise_for_status()
    return r.json().get("count", 0)


def _parallel(jobs: list, workers: int = 8) -> list:
    """Run independent Jira/Xray calls concurrently, preserving order.

    Every call here is a round trip to a remote API — the roll-ups are ~27 (tickets) and ~26
    (executions) of them, and run serially that is 20-55s of pure waiting. They don't depend on
    each other, so a small thread pool turns the wall-clock into roughly the slowest single call.
    Kept modest (8) to stay well inside Atlassian's rate limits.
    """
    with ThreadPoolExecutor(max_workers=workers) as ex:
        return [f.result() for f in [ex.submit(j) for j in jobs]]


def _bug_row(flow: str, cfg: dict) -> dict:
    row = {"flow": flow, "label": cfg.get("label", flow), "component": cfg.get("component"),
           "bugs_open": 0, "bugs_resolved": 0, "total": 0, "error": None}
    base = _jql_for(flow).replace(" ORDER BY created DESC", "")
    if not base:
        row["error"] = "no component configured"
        return row
    try:
        n = _parallel([lambda: count(base),
                       lambda: count(f'{base} AND issuetype=Bug AND resolution IS EMPTY'),
                       lambda: count(f'{base} AND issuetype=Bug AND resolution IS NOT EMPTY')], 3)
        row["total"], row["bugs_open"], row["bugs_resolved"] = n
    except JiraUnreachable:
        raise
    except requests.HTTPError as e:
        row["error"] = f"HTTP {e.response.status_code}"
    return row


def bugs_summary() -> list:
    """One row per configured flow: bug counts (open / resolved) + total tickets.

    Counting calls rather than paging every issue (see count()), and all flows in parallel.
    """
    items = list(flows().items())
    return _parallel([lambda f=f, c=c: _bug_row(f, c) for f, c in items], 6)


# ── view 2: the Xray test-execution results for a flow ────────────────────────
# Xray caps testRuns at 100 per call, so this is paged with `start` until `total` is reached —
# without that, a 132-test execution silently reports only its first 100 tests.
_EXEC_Q = """{ getTestExecution(issueId: "%s") { issueId
  testRuns(limit: 100, start: %d) { total results { status { name } test { jira(fields: ["key","summary"]) } } } } }"""


def _all_test_runs(issue_id: str) -> tuple:
    """Every test run in an execution, following Xray's 100-per-page limit. -> (results, total)."""
    out, total, start = [], 0, 0
    while True:
        d = _xray_graphql(_EXEC_Q % (issue_id, start))
        te = (d.get("data") or {}).get("getTestExecution")
        if not te:
            msg = "; ".join(e.get("message", "") for e in d.get("errors", [])) or "no data"
            raise ValueError(msg)
        runs = te.get("testRuns") or {}
        total = runs.get("total", 0)
        page = runs.get("results") or []
        out += page
        start += len(page)
        if not page or start >= total:
            return out, total


def _issue_ids(keys: list) -> dict:
    """Xray's GraphQL wants numeric issue ids, but the config (and humans) speak in issue keys."""
    def one(k):
        try:
            return _jira_get(f"/rest/api/3/issue/{k}", {"fields": "id,summary,status"})
        except requests.HTTPError:
            return None
    return dict(zip(keys, _parallel([lambda k=k: one(k) for k in keys], min(6, len(keys) or 1))))


def execution(flow: str, suite: str = "sit") -> dict:
    """Per-test statuses for a flow's Test Execution(s) in one suite (sit | uat).

    A flow may map to several executions (booking change splits VOL / INVOL / E2E); their results
    are returned per execution and also rolled up, so the UI can show either.
    """
    cfg = flow_cfg(flow)
    keys = (cfg.get("executions") or {}).get(suite.lower(), [])
    if not keys:
        return {"flow": flow, "suite": suite, "configured": False, "executions": [], "totals": {}}
    meta = _issue_ids(keys)
    execs, totals = [], {}
    # one thread per execution: each is an independent Xray paging loop
    fetched = dict(zip(keys, _parallel(
        [lambda k=k: (_all_test_runs(meta[k]["id"]) if meta.get(k) else None) for k in keys],
        min(6, len(keys) or 1))))
    for key in keys:
        m = meta.get(key)
        if not m:
            execs.append({"key": key, "error": "issue not found"})
            continue
        row = {"key": key, "url": f"{JIRA_BASE_URL}/browse/{key}",
               "summary": m["fields"]["summary"], "status": m["fields"]["status"]["name"],
               "counts": {}, "tests": []}
        got = fetched.get(key)
        if not got:
            row["error"] = "no data from Xray"
            execs.append(row)
            continue
        results, total = got
        row["total"] = total
        for r in results:
            st = ((r.get("status") or {}).get("name") or "UNKNOWN").upper()
            jira = (r.get("test") or {}).get("jira") or {}
            row["counts"][st] = row["counts"].get(st, 0) + 1
            totals[st] = totals.get(st, 0) + 1
            row["tests"].append({"key": jira.get("key"), "summary": jira.get("summary", ""),
                                 "status": st,
                                 "url": f"{JIRA_BASE_URL}/browse/{jira.get('key')}" if jira.get("key") else None})
        execs.append(row)
    return {"flow": flow, "suite": suite, "configured": True,
            "label": cfg.get("label", flow), "executions": execs, "totals": totals}


def execution_summary(suite: str = "sit") -> list:
    """One row per flow: how many of its Xray tests passed / failed / are still to do."""
    def one(flow, cfg):
        row = {"flow": flow, "label": cfg.get("label", flow), "suite": suite,
               "keys": (cfg.get("executions") or {}).get(suite.lower(), []), "totals": {}, "error": None}
        if row["keys"]:
            try:
                row["totals"] = execution(flow, suite)["totals"]
            except JiraUnreachable:
                raise
            except (requests.HTTPError, KeyError) as e:
                row["error"] = str(e)[:120]
        return row
    items = list(flows().items())
    return _parallel([lambda f=f, c=c: one(f, c) for f, c in items], 5)


# ── mapping store (S3) ────────────────────────────────────────────────────────
# The only persistent state this app has: which Jira issues a given S3 test case corresponds to.
#
#   s3://<S3_BUCKET>/<MAPPING_PREFIX>/<flow>.json
#   { "FD_TC_001": {"xray_key": "CHAI-24818", "bug_key": "CHAI-27992", "updated": "...Z"} }
#
# S3 rather than SQLite because these rows are MANUAL work — a human confirming FD_TC_001 ->
# CHAI-24818 case by case — and a SQLite file on the Fargate task's ephemeral disk is wiped by
# every redeploy. S3 rather than Postgres because the app already has this bucket and IAM access,
# and one small object per flow does not justify standing up a database.
#
# Concurrency: writes are read-modify-write under a process lock. Two tasks writing the same flow
# in the same instant would last-write-win, which is acceptable here — the service runs one task,
# writes happen only when someone confirms a mapping or creates a bug, and the blast radius is one
# re-confirmation. If that ever stops being true, switch _save to a conditional PUT on the ETag.
MAPPING_PREFIX = os.environ.get("MAPPING_PREFIX", "mappings").strip("/")
MAPPING_BUCKET = os.environ.get("MAPPING_BUCKET") or os.environ.get("S3_BUCKET", "")
MAPPING_TTL = int(os.environ.get("MAPPING_CACHE_TTL", "30"))

_store_lock = threading.Lock()
_store_cache: dict = {}          # flow -> (fetched_at, {case_id: row})
_s3_client = None


def _s3():
    global _s3_client
    if _s3_client is None:
        import boto3
        _s3_client = boto3.client("s3", region_name=os.environ.get("AWS_REGION", "ca-central-1"))
    return _s3_client


def _map_key(flow: str) -> str:
    return f"{MAPPING_PREFIX}/{flow}.json"


def store_location(flow: str = "<flow>") -> str:
    return f"s3://{MAPPING_BUCKET}/{_map_key(flow)}"


def _load(flow: str, fresh: bool = False) -> dict:
    """Every mapped case for a flow. Missing object == nothing mapped yet, which is not an error."""
    now = time.time()
    if not fresh:
        hit = _store_cache.get(flow)
        if hit and now - hit[0] < MAPPING_TTL:
            return hit[1]
    if not MAPPING_BUCKET:
        return {}
    try:
        body = _s3().get_object(Bucket=MAPPING_BUCKET, Key=_map_key(flow))["Body"].read()
        data = json.loads(body) or {}
        if not isinstance(data, dict):
            data = {}
    except Exception as e:                      # NoSuchKey on first use, or a transient read
        if type(e).__name__ not in ("NoSuchKey", "ClientError"):
            raise
        data = {}
    _store_cache[flow] = (now, data)
    return data


def _save(flow: str, data: dict) -> None:
    _s3().put_object(Bucket=MAPPING_BUCKET, Key=_map_key(flow),
                     Body=json.dumps(data, indent=2, sort_keys=True).encode("utf-8"),
                     ContentType="application/json")
    _store_cache[flow] = (time.time(), data)


def _row(flow: str, case_id: str, d: dict) -> dict:
    """Shape a stored entry the way callers expect (flat, with its keys present)."""
    return {"flow": flow, "case_id": case_id,
            "xray_key": d.get("xray_key", ""), "bug_key": d.get("bug_key", ""),
            "updated": d.get("updated", "")}


def get_case(flow: str, case_id: str) -> dict | None:
    d = _load(flow).get(case_id)
    return _row(flow, case_id, d) if d else None


def get_cases(flow: str) -> dict:
    return {cid: _row(flow, cid, d) for cid, d in _load(flow).items()}


def bind_case(flow: str, case_id: str, xray_key: str = "", bug_key: str = "") -> dict:
    """Record (or update) which Jira issues a test case corresponds to.

    Only the fields given are changed, so binding a bug later doesn't clear the Xray key. Passing
    an explicit empty string for a field that was never set simply leaves it empty.
    """
    with _store_lock:
        data = dict(_load(flow, fresh=True))       # re-read under the lock, don't trust the cache
        cur = dict(data.get(case_id) or {})
        if xray_key:
            cur["xray_key"] = xray_key
        if bug_key:
            cur["bug_key"] = bug_key
        cur.setdefault("xray_key", "")
        cur.setdefault("bug_key", "")
        cur["updated"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        data[case_id] = cur
        _save(flow, data)
    return _row(flow, case_id, cur)


# ── writes ────────────────────────────────────────────────────────────────────
# Everything above this line is read-only. Everything below can modify CHAI, a shared project, so:
#   * every call goes through bug_action(), whose `commit` flag defaults to False — callers must
#     ask twice, and the UI shows the exact payload before the second ask;
#   * JIRA_WRITE=0 disables the write path entirely, whatever the UI does;
#   * there is still no DELETE anywhere, so nothing here can destroy an issue, comment or file.
WRITE_ENABLED = os.environ.get("JIRA_WRITE", "1") != "0"
BUG_LABEL_DEFAULT = os.environ.get("JIRA_BUG_LABEL", "")
# Jira's "Testing Type" select on the CHAI Bug screen. Stamped from the suite the run belongs to,
# so a bug raised from a SIT execution is filed as SIT and one from UAT as UAT. Ids are discovered
# from createmeta, not guessed: note the SIT option is labelled "SIT Test", not "SIT".
TESTING_TYPE_FIELD = os.environ.get("JIRA_TESTING_TYPE_FIELD", "customfield_10153")
TESTING_TYPE_LABELS = {"sit": "SIT Test", "uat": "UAT"}
TESTING_TYPE_IDS = {
    "sit": os.environ.get("TESTING_TYPE_SIT", "14669"),   # "SIT Test"
    "uat": os.environ.get("TESTING_TYPE_UAT", "10370"),   # "UAT"
}
_me_cache: dict = {}


class WritesDisabled(Exception):
    """JIRA_WRITE=0 — this deployment forbids modifying Jira."""


def _jira_post(path: str, payload: dict) -> dict:
    try:
        r = requests.post(f"{JIRA_BASE_URL}{path}", json=payload, timeout=TIMEOUT,
                          headers={"Authorization": _auth_header(), "Accept": "application/json",
                                   "Content-Type": "application/json"})
    except requests.RequestException as e:
        raise JiraUnreachable(str(e)) from e
    r.raise_for_status()
    return r.json() if r.text.strip() else {}


def _adf(blocks: list) -> dict:
    """Minimal Atlassian Document Format: strings -> a document ('## x' becomes a heading).

    Jira Cloud v3 rejects plain strings for description/comment, so even a two-line body has to be
    wrapped in ADF. Only paragraphs and one heading level are needed here.
    """
    content = []
    for b in blocks:
        if not b:
            continue
        if b.startswith("## "):
            content.append({"type": "heading", "attrs": {"level": 3},
                            "content": [{"type": "text", "text": b[3:]}]})
        else:
            content.append({"type": "paragraph", "content": [{"type": "text", "text": b}]})
    return {"type": "doc", "version": 1,
            "content": content or [{"type": "paragraph",
                                    "content": [{"type": "text", "text": " "}]}]}


def evidence_filename(case_id: str, run: str) -> str:
    """Per-run attachment name.

    Jira attachments are append-only — there is no replace API, and deleting is off the table — so
    uploading `FD_TC_001.evidence.html` every run would leave a pile of identically-named files
    with no way to tell which is current. Embedding the run id keeps every upload distinct and
    sorts chronologically, because the run ids already end in a timestamp.
    """
    return f"{case_id}__{run}.evidence.html"


def attach(issue_key: str, filename: str, data: bytes) -> dict:
    if not WRITE_ENABLED:
        raise WritesDisabled()
    try:
        r = requests.post(f"{JIRA_BASE_URL}/rest/api/3/issue/{issue_key}/attachments",
                          timeout=max(TIMEOUT, 60),
                          headers={"Authorization": _auth_header(),
                                   "X-Atlassian-Token": "no-check", "Accept": "application/json"},
                          files={"file": (filename, data, "text/html")})
    except requests.RequestException as e:
        raise JiraUnreachable(str(e)) from e
    r.raise_for_status()
    return {"filename": filename, "size": len(data)}


def comment(issue_key: str, blocks: list) -> dict:
    if not WRITE_ENABLED:
        raise WritesDisabled()
    return _jira_post(f"/rest/api/3/issue/{issue_key}/comment", {"body": _adf(blocks)})


def transitions(issue_key: str) -> list:
    d = _jira_get(f"/rest/api/3/issue/{issue_key}/transitions")
    return [{"id": t["id"], "name": t["name"], "to": t["to"]["name"]}
            for t in d.get("transitions", [])]


def transition_to(issue_key: str, name: str) -> dict:
    """Move an issue by transition NAME (ids differ per workflow).

    Returns {'ok': False, ...} rather than raising when the transition isn't offered from the
    issue's current state. CHAI's Bug workflow exposes no path to Closed from New, so 'couldn't
    move it' is an expected outcome to report, not a failure.
    """
    if not WRITE_ENABLED:
        raise WritesDisabled()
    avail = transitions(issue_key)
    match = next((t for t in avail if t["name"].lower() == name.lower()), None)
    if not match:
        return {"ok": False, "reason": f"'{name}' not available from the current status",
                "available": [t["name"] for t in avail]}
    _jira_post(f"/rest/api/3/issue/{issue_key}/transitions", {"transition": {"id": match["id"]}})
    return {"ok": True, "to": match["to"], "via": match["name"]}


def build_bug(flow: str, case_id: str, facts: dict, suite: str = "sit") -> dict:
    """The exact issue payload for a failing case, built WITHOUT contacting Jira — so the UI can
    show it for confirmation before anything is created."""
    cfg = flow_cfg(flow)
    labels = [x for x in (cfg.get("labels") or []) if x]
    if not labels and BUG_LABEL_DEFAULT:
        labels = [BUG_LABEL_DEFAULT]
    prefix = f"[{labels[0]}] " if labels else ""
    fields = {
        "project": {"key": JIRA_PROJECT},
        "issuetype": {"name": "Bug"},
        "summary": f"{prefix}{case_id} - {facts.get('headline') or 'automated test failure'}"[:250],
        "description": _adf([
            "## Automated test failure",
            f"Test case: {case_id}   Flow: {cfg.get('label', flow)}   Env: {facts.get('env', '')}",
            f"Run: {facts.get('run', '')}",
            "## Expected vs actual",
            f"Expected: {facts.get('expected', '-')}",
            f"Actual: {facts.get('actual', '-')}",
            "## Context",
            facts.get("context", ""),
            "Raised automatically from the CCT Report Viewer. Evidence is attached.",
        ]),
    }
    if cfg.get("component"):
        fields["components"] = [{"name": cfg["component"]}]
    if labels:
        fields["labels"] = labels
    tt = TESTING_TYPE_IDS.get((suite or "").lower())
    if tt and TESTING_TYPE_FIELD:
        fields[TESTING_TYPE_FIELD] = {"id": tt}
    return {"fields": fields}


def bug_action(flow: str, case_id: str, facts: dict, evidence: bytes = None,
               commit: bool = False, suite: str = "sit") -> dict:
    """Create-or-update the Jira bug for one test case. Does nothing unless commit=True.

    Failing case, no bug yet  -> create Bug, attach evidence, remember the key.
    Failing case, bug exists  -> attach this run's evidence + comment that it failed again.
    Passing case, bug exists  -> comment that it passed, then move the bug to Monitor.
    Passing case, no bug      -> nothing to do.

    The case -> bug mapping is a side effect, not a prerequisite: the row in case_map is written
    when the bug is created, so nothing has to be seeded up front for this to work.
    """
    existing = get_case(flow, case_id) or {}
    bug = existing.get("bug_key") or ""
    passed = bool(facts.get("passed"))
    run = facts.get("run", "")
    fname = evidence_filename(case_id, run)

    xray = existing.get("xray_key") or ""
    plan = {"flow": flow, "case": case_id, "run": run, "passed": passed,
            "existing_bug": bug or None, "attachment": fname if evidence else None,
            "write_enabled": WRITE_ENABLED, "evidence_bytes": len(evidence or b""),
            # the bug only shows up against the test case if we know which Xray test that is
            "xray_test": xray or None,
            "suite": suite,
            "testing_type": TESTING_TYPE_LABELS.get((suite or "").lower()),
            "will_link": bool(xray) and not passed,
            "link_note": None if xray else
                         "no Xray test mapped - the bug will be created but will NOT appear "
                         "against the test case. Map it on the Case mapping tab."}
    if passed and not bug:
        plan.update(action="none", detail="test passed and no bug is mapped - nothing to do")
        return plan
    if passed:
        plan.update(action="resolve", issue=bug, transition="Monitor",
                    comment=f"{case_id} PASSED in run {run}. Reported by the CCT Report Viewer.")
    elif bug:
        plan.update(action="update", issue=bug,
                    comment=f"{case_id} failed again in run {run}. New evidence attached as {fname}.")
    else:
        plan.update(action="create", payload=build_bug(flow, case_id, facts, suite))

    if not commit:
        plan["preview"] = True
        return plan
    if not WRITE_ENABLED:
        raise WritesDisabled()

    done = {}
    if plan["action"] == "create":
        created = _jira_post("/rest/api/3/issue", plan["payload"])
        bug = created.get("key", "")
        done["created"] = bug
        bind_case(flow, case_id, bug_key=bug)
    if evidence and bug and plan["action"] in ("create", "update"):
        done["attached"] = attach(bug, fname, evidence)
    if bug and plan.get("comment"):
        comment(bug, [plan["comment"]])
        done["commented"] = True
    if plan["action"] == "resolve" and bug:
        done["transition"] = transition_to(bug, "Monitor")
    # make the bug visible against the test case itself, the way this project already does it
    # (every failed FAQ test carries a linked defect). Touches the test RUN only.
    if xray and bug and plan["action"] in ("create", "update"):
        try:
            done["linked"] = link_defect(flow, case_id, bug, suite)
        except (JiraUnreachable, requests.HTTPError) as e:
            done["linked"] = {"ok": False, "reason": str(e)[:160]}
    plan.update(preview=False, result=done,
                url=f"{JIRA_BASE_URL}/browse/{bug}" if bug else None)
    return plan


# ── case -> Xray test suggestion ──────────────────────────────────────────────
# S3 names its cases FD_TC_001; Xray names the same tests "[FD-SIT-008] APPR eligible - 3 to <6
# hour delay - CA". There is no shared identifier, and the counts differ (239 S3 cases vs 132 Xray
# tests for FD), so nothing here auto-commits a pairing — it only RANKS candidates for a human to
# confirm. bind_case() is what makes a pairing real.
_STOP = {"the", "a", "an", "and", "or", "to", "of", "in", "is", "for", "with", "on", "test",
         "case", "should", "be", "that", "this", "not", "no", "when", "then", "given"}


def _tokens(text: str) -> set:
    out = set()
    for w in re.split(r"[^A-Za-z0-9]+", (text or "").lower()):
        if len(w) > 1 and w not in _STOP:
            out.add(w)
    return out


def _case_num(text: str) -> str:
    """The case number, preferring a bracketed id like "[FD-SIT-001]" or "FD_TC_001".

    Taking the last number in the string instead would pick up amounts and delay hours — a summary
    ending "CAD 400" would compare 400 against the case number and never match.
    """
    m = re.match(r"\s*\[[A-Za-z]+[-_][A-Za-z]+[-_](\d+)\]", text or "")
    if m:
        return m.group(1).lstrip("0")
    m = re.match(r"^[A-Za-z]+[-_][A-Za-z]+[-_](\d+)$", (text or "").strip())
    if m:
        return m.group(1).lstrip("0")
    m = re.findall(r"(\d{2,4})", text or "")
    return m[0].lstrip("0") if m else ""


def score_case(facts: dict, summary: str) -> float:
    """How well does an Xray test summary match one S3 case? 0..1, higher is better.

    Deliberately simple and explainable — the operator sees the score next to the summary and is
    the one who decides. Signals, in order of weight:
      * the semantic words from the case (regime, expected status, system code parts)
      * the trailing number (FD_TC_001 vs [FD-SIT-001]) — a hint only, since the two sequences
        are different lengths and definitely drift apart
    """
    st = _tokens(summary)
    if not st:
        return 0.0
    strong = _tokens(" ".join(str(facts.get(k, "")) for k in
                              ("regime", "expected_status", "expected_system_code")))
    # split a code like FD-APPR-EL-01 into its parts too
    strong |= _tokens(str(facts.get("expected_system_code", "")).replace("-", " "))
    hits = len(strong & st)
    score = hits / max(len(strong), 1) * 0.55

    # the expected amount is a strong discriminator: several tests share "APPR eligible" but
    # differ by payout, and the summaries spell it out ("... - CAD 400").
    amt = facts.get("expected_amount") or {}
    cur, val = str(amt.get("currency", "")).strip(), amt.get("value")
    if cur and val is not None:
        whole = str(int(val)) if float(val) == int(float(val)) else str(val)
        if re.search(r"%s\s*%s" % (re.escape(cur), re.escape(whole)), summary, re.I):
            score += 0.25

    a, b = _case_num(facts.get("case_id", "")), _case_num(summary)
    if a and a == b:
        score += 0.2
    return round(min(score, 1.0), 3)


def suggest(flow: str, suite: str, cases: list, top: int = 5) -> dict:
    """Rank the flow's Xray tests against each S3 case. Read-only; commits nothing.

    `cases` is a list of {case_id, regime, expected_status, expected_system_code} built from the
    run's result.json files by the caller (app.py owns S3 access, this module owns Jira).
    """
    ex = execution(flow, suite)
    tests = [t for x in ex.get("executions", []) for t in (x.get("tests") or []) if t.get("key")]
    bound = get_cases(flow)
    out = []
    for c in cases:
        cid = c.get("case_id", "")
        ranked = sorted(({"key": t["key"], "summary": t.get("summary", ""),
                          "score": score_case(c, t.get("summary", ""))} for t in tests),
                        key=lambda r: r["score"], reverse=True)[:top]
        out.append({"case_id": cid, "facts": c,
                    "bound": (bound.get(cid) or {}).get("xray_key") or None,
                    "bug": (bound.get(cid) or {}).get("bug_key") or None,
                    "candidates": ranked,
                    # "confident" only pre-selects a dropdown; it never binds anything. A clear
                    # gap to the runner-up matters more than the absolute score, since scores
                    # compress when many tests share the same wording.
                    "confident": bool(ranked and ranked[0]["score"] >= 0.5
                                      and (len(ranked) < 2
                                           or ranked[0]["score"] - ranked[1]["score"] >= 0.15))})
    return {"flow": flow, "suite": suite, "tests_available": len(tests), "cases": out}


# ── attaching a bug to the test case in its execution ─────────────────────────
_ADD_DEFECT = ('mutation { addDefectsToTestRun(id: "%s", issues: ["%s"]) '
               '{ addedDefects warnings } }')


def _test_run_id(xray_key: str, exec_key: str) -> str | None:
    """The id of the test-run row for one test inside one execution."""
    meta = _jira_get(f"/rest/api/3/issue/{exec_key}", {"fields": "id"})
    q = ('{ getTestExecution(issueId: "%s") { testRuns(limit: 100, start: %d) { total results { id '
         'test { jira(fields: ["key"]) } } } } }')
    start = 0
    while True:
        d = _xray_graphql(q % (meta["id"], start))
        te = (d.get("data") or {}).get("getTestExecution")
        if not te:
            return None
        runs = te.get("testRuns") or {}
        for r in runs.get("results", []):
            if ((r.get("test") or {}).get("jira") or {}).get("key") == xray_key:
                return r.get("id")
        start += len(runs.get("results") or [])
        if start >= runs.get("total", 0) or not runs.get("results"):
            return None


def link_defect(flow: str, case_id: str, bug_key: str, suite: str = "sit") -> dict:
    """Attach an existing bug to the test case's run inside the flow's Test Execution.

    This is what makes the bug show up against the test in Xray — the convention already used in
    this project (every failed FAQ test carries a linked defect). It modifies only the TEST RUN,
    never the Test Case issue itself, so the test plan is untouched.
    """
    if not WRITE_ENABLED:
        raise WritesDisabled()
    row = get_case(flow, case_id) or {}
    xkey = row.get("xray_key")
    if not xkey:
        return {"ok": False, "reason": "no Xray test mapped for this case - confirm it on the "
                                       "mapping screen first"}
    keys = (flow_cfg(flow).get("executions") or {}).get(suite.lower(), [])
    for ex_key in keys:
        rid = _test_run_id(xkey, ex_key)
        if rid:
            d = _xray_graphql(_ADD_DEFECT % (rid, bug_key))
            if d.get("errors"):
                return {"ok": False, "reason": "; ".join(e.get("message", "") for e in d["errors"])}
            res = (d.get("data") or {}).get("addDefectsToTestRun") or {}
            return {"ok": True, "execution": ex_key, "test": xkey, "test_run": rid,
                    "added": res.get("addedDefects"), "warnings": res.get("warnings")}
    return {"ok": False, "reason": f"{xkey} is not in any {suite.upper()} execution for {flow}"}
