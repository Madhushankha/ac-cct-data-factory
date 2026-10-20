"""The verdict from the new TripTracer engine, read straight from tt-api.

The old approach cannot verify anything. `finalize` wrote the expected answer into
`execution_traces`, put a copy in S3 and wrote a `dds_pnr_output` row; `verify` read it back through
the rule-engine platform and found it. Expected and actual had the same author. Proven on INT on
2026-10-16: the same spec seeded with the pin passed all nine verdict checks (FYH0GF), and without
it the by-PNR endpoint answered **404 -- no document at all** (YXHFMQ). The platform never computed
a verdict for a seeded booking; it only ever held what we put there. Nothing on INT reads those
three writes any more either, since case-services moved to this engine on 2026-10-13.

The new engine stores nothing. It folds the booking's event history on every read and answers from
that, so there is nowhere to write an answer in advance and no way for a comparison to be circular.
A disagreement it reports is real -- which is how the uat-scenarios kit found five rule defects over
344 scenarios while our pinned runs found none over 230.

**This project calls tt-api directly and never goes through case-services.** A request through
another service's API would be answered with that service's identity and recorded as its traffic,
and its answer would arrive shaped by its own normalisation. We ask the engine ourselves.

## The principal

tt-api admits an internal service with a short-lived JWT the service signs with its OWN private key,
verified against the public key that service registered (cct-cascade
`kb/source/reference/projects/triptracer-service-access.md` §2.2, implemented in
`apps/trip-tracer-event-processor/rust/src/http/service_access.rs`). Nothing secret is shared with
TripTracer in either direction, so this project needs a principal of its own -- not a copy of
anyone else's key. Registering one means handing TripTracer a public key, a `kid` and the scopes;
the private half never leaves wherever you keep it.

The token is exactly what §2.2 asks for, and tt-api refuses anything more:

* header: `alg` (ES256) and `kid`, and nothing else -- no `typ`, and never `jwk`, `jku`, `x5u`,
  `x5c` or `crit`;
* claims: `iss`, `aud`, `sub` (the principal), `iat`, `exp`, `scope` (space separated), nothing else.

Lifetime is 300 seconds, reused until 60 seconds before expiry; tt-api's ceiling is 900 and a
configuration above it is refused here rather than by the server.

The key is read from the environment, never from a secret store: a seeding tool has no business
holding a role that can read service keys. Without one this module refuses, and a run reports the
verdict as not checked. An unverifiable result presented as a verdict is worse than no result.
"""
from __future__ import annotations

import json
import os
import pathlib
import threading
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field

import jwt

ALG = "ES256"
TOKEN_LIFETIME_SECONDS = 300
TOKEN_REFRESH_MARGIN_SECONDS = 60
#: tt-api's own ceiling; a longer lifetime is refused here rather than at the server
TOKEN_MAX_LIFETIME_SECONDS = 900

#: the scope this project needs, and the only one it asks for
SCOPE_EVALUATION = "triptracer.evaluation.read"
SCOPE_TRIP = "triptracer.trip.read"

TT_HOSTS = {
    "int": "https://triptracer.ac-cct-int.cloud.aircanada.com",
    "crt": "https://triptracer.ac-cct-crt.cloud.aircanada.com",
    "bat": "https://triptracer.ac-cct-bat.cloud.aircanada.com",
}
#: the audience every tt-api service token must carry (TT_SERVICE_ACCESS, §2.1)
TT_AUDIENCE = "urn:cct:triptracer-api"
DDS_ROUTE = "/api/dds-evaluations?engine=raptor"
#: tt-api's own code for a booking it does not hold. Only a 404 carrying it means "no verdict".
TRIP_NOT_FOUND = "TRIP_NOT_FOUND"
#: busy and 429 only, with bounded backoff, as the case-services client does
RETRY_ATTEMPTS = 3
RETRY_MAX_WAIT_SECONDS = 8
TRIP_ROUTE = "/api/trip/{pnr}?pnrId={pnr_id}&mode=live&engine=raptor"


class NoCredential(RuntimeError):
    """No registered principal. The caller reports the verdict as not checked."""


class RaptorError(RuntimeError):
    """The engine was reached and refused, or answered something unusable."""


@dataclass(frozen=True)
class Principal:
    """This project's registration with TripTracer, and the private half of its key."""
    private_key_pem: str = field(repr=False)
    kid: str
    issuer: str
    audience: str
    subject: str
    lifetime: int = TOKEN_LIFETIME_SECONDS

    def __post_init__(self) -> None:
        if self.lifetime > TOKEN_MAX_LIFETIME_SECONDS:
            raise ValueError(f"lifetime {self.lifetime}s exceeds tt-api's ceiling of "
                             f"{TOKEN_MAX_LIFETIME_SECONDS}s")
        for name in ("private_key_pem", "kid", "issuer", "audience", "subject"):
            if not str(getattr(self, name)).strip():
                raise ValueError(f"the principal has no {name}")


class _Signer:
    """One token at a time, reused until it is nearly expired. Never logged, never in a repr."""

    def __init__(self, principal: Principal, scope: str) -> None:
        self._p = principal
        self._scope = scope
        self._lock = threading.Lock()
        self._token = ""
        self._expires = 0.0

    def token(self) -> str:
        with self._lock:
            if self._token and time.time() < self._expires - TOKEN_REFRESH_MARGIN_SECONDS:
                return self._token
            now = int(time.time())
            claims = {"iss": self._p.issuer, "aud": self._p.audience, "sub": self._p.subject,
                      "iat": now, "exp": now + self._p.lifetime, "scope": self._scope}
            try:
                self._token = jwt.encode(claims, self._p.private_key_pem, algorithm=ALG,
                                         headers={"alg": ALG, "kid": self._p.kid})
            except Exception as ex:                                         # noqa: BLE001
                # the message is kept, the key is not: an exception must never carry key material
                raise NoCredential(f"the private key could not sign a token: "
                                   f"{type(ex).__name__}") from None
            self._expires = now + self._p.lifetime
            return self._token


@dataclass
class Reader:
    principal: Principal
    env: str = "int"
    timeout: int = 30
    base_url: str = ""
    via: str = "tt-api"

    def __post_init__(self) -> None:
        self.base_url = (self.base_url or TT_HOSTS.get(self.env) or "").rstrip("/")
        if not self.base_url:
            raise ValueError(f"no tt-api host for env {self.env!r}")
        self._signer = _Signer(self.principal, SCOPE_EVALUATION)

    def document(self, pnr_id: str) -> dict | None:
        """The DDS evaluation document for this booking, or None when there is no assessment.

        None is an answer, not a failure: a bound the engine has not assessed yet has no document,
        exactly as a 404 from the old by-PNR endpoint meant none. `TRIP_NOT_FOUND` -- the booking
        has not reached TripTracer at all -- is also None, and is the answer a case that was never
        published should get.
        """
        # upper-cased and stripped, as case-services normalises it before sending
        payload_out = {"pnrId": (pnr_id or "").strip().upper()}
        if not payload_out["pnrId"]:
            raise ValueError("a PNR id is required for a DDS evaluation")

        for attempt in range(1, RETRY_ATTEMPTS + 1):
            req = urllib.request.Request(
                self.base_url + DDS_ROUTE, data=json.dumps(payload_out).encode(), method="POST",
                headers={"Content-Type": "application/json", "Accept": "application/json",
                         "Authorization": f"Bearer {self._signer.token()}",
                         "User-Agent": "ac-cct-data-seed"})
            try:
                with urllib.request.urlopen(req, timeout=self.timeout) as r:
                    body = json.load(r)
                break
            except urllib.error.HTTPError as ex:
                detail = (ex.read() or b"")[:400].decode("utf-8", "replace")
                # Busy and 429 are retried with bounded backoff, honouring Retry-After, as the
                # case-services client does. Nothing else is retried.
                if (ex.code == 429 or "TRIP_CAPACITY_BUSY" in detail) and attempt < RETRY_ATTEMPTS:
                    wait = min(float(ex.headers.get("Retry-After") or 0) or 2 ** attempt,
                               RETRY_MAX_WAIT_SECONDS)
                    time.sleep(wait)
                    continue
                # A 404 means "no DDS output" ONLY when tt-api says TRIP_NOT_FOUND -- the booking
                # has not reached TripTracer. A 404 without it is the ROUTE being refused, which is
                # a configuration or permission fault; swallowing it as "no verdict" would report a
                # broken setup as a clean absence.
                if ex.code == 404 and TRIP_NOT_FOUND in detail:
                    return None
                raise RaptorError(f"HTTP {ex.code} from tt-api: {detail}") from None
            except (urllib.error.URLError, TimeoutError) as ex:
                raise RaptorError(f"tt-api unreachable: {ex}") from None
        else:                                                   # pragma: no cover - loop exhausted
            raise RaptorError(f"tt-api stayed busy after {RETRY_ATTEMPTS} attempts")

        if not isinstance(body, dict):
            raise RaptorError(f"tt-api answered {type(body).__name__}, not an object")
        # The response contract: `document` is PRESENT and is either null or an object. An answer
        # without the key is a broken response, not an empty one -- case-services raises
        # TripTracerLiveApiInvalidResponse on exactly this, and treating the whole body as the
        # document instead would invent rows out of an envelope.
        if "document" not in body or not (body["document"] is None or isinstance(body["document"], dict)):
            raise RaptorError("the DDS evaluation response had no document")
        # A null document is no assessment yet: the bound is not ready, which is a real answer.
        return body["document"] or None


def from_env(env: str = "int") -> Reader:
    """A reader from this project's own registered principal.

        AQA_TT_KEY_PEM    path to the private key, or the PEM itself
        AQA_TT_KID        the key id TripTracer registered
        AQA_TT_ISSUER     the issuer it registered
        AQA_TT_AUDIENCE   the audience it expects (default: tt-api)
        AQA_TT_PRINCIPAL  this project's principal name
        AQA_TT_BASE       override the host for the environment
    """
    pem = os.environ.get("AQA_TT_KEY_PEM", "").strip()
    if pem and not pem.startswith("-----"):
        path = pathlib.Path(pem).expanduser()
        if not path.exists():
            raise NoCredential(f"AQA_TT_KEY_PEM points at {path}, which does not exist")
        pem = path.read_text(encoding="utf-8")
    if not pem:
        raise NoCredential(
            "no TripTracer principal. This project needs its OWN registration with tt-api: a key "
            "pair whose public half TripTracer holds against a kid, scoped "
            f"{SCOPE_EVALUATION!r}. Then set AQA_TT_KEY_PEM (path or PEM), AQA_TT_KID, "
            "AQA_TT_ISSUER and AQA_TT_PRINCIPAL. No key is read from a secret store here, and "
            "there is no fallback to the old pinned endpoint.")
    try:
        principal = Principal(
            private_key_pem=pem,
            kid=os.environ.get("AQA_TT_KID", ""),
            issuer=os.environ.get("AQA_TT_ISSUER", ""),
            audience=os.environ.get("AQA_TT_AUDIENCE", TT_AUDIENCE),
            subject=os.environ.get("AQA_TT_PRINCIPAL", ""))
    except ValueError as ex:
        raise NoCredential(str(ex)) from None
    return Reader(principal=principal, env=env,
                  base_url=os.environ.get("AQA_TT_BASE", ""))
