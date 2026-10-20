# The credential this project needs

From `cct-cascade/kb/source/reference/projects/triptracer-service-access.md`, §2.1–§2.3, which is
the authority. Implemented in `apps/trip-tracer-event-processor/rust/src/http/service_access.rs`.

It is **not a secret handout.** TripTracer's side holds only public material, in a configuration
document reviewed in the repository like any other deployment setting. The private key never leaves
us, and nothing secret is shared in either direction.

## What we do

Generate an EC P-256 key pair. The private half stays wherever we keep it; only the public half is
sent.

```bash
openssl ecparam -name prime256v1 -genkey -noout -out data-seed-int.key
openssl ec -in data-seed-int.key -pubout -out data-seed-int.pub
```

## What TripTracer adds, on INT

One issuer block inside `TT_SERVICE_ACCESS` on the live node's `tt-api`
(`live-node-api.int.env`, one line). Ours:

```json
{"issuer": "urn:cct:ac-cct-data-seed",
 "audience": "urn:cct:triptracer-api",
 "note": "CCT QA seed data, owner: QA",
 "keys": [{"kid": "data-seed-int-2026-10", "alg": "ES256",
           "pem": "-----BEGIN PUBLIC KEY-----\n…\n-----END PUBLIC KEY-----"}],
 "principals": [{"sub": "data-seed",
                 "scopes": ["triptracer.evaluation.read"],
                 "ratePerMinute": 600}]}
```

`keys[]` takes either that PEM (SubjectPublicKeyInfo) or the JWK members
(`kty: EC`, `crv: P-256`, `x`, `y`). A private key is refused by name at start and never echoed.
At start the server logs one `service_access_configured` line naming the issuer, audience, key id,
principal, scopes and rate — never key material.

## The scope, and why only one

| scope | opens | we need it |
|---|---|---|
| `triptracer.evaluation.read` | `POST /api/dds-evaluations`, `POST /api/live-evaluations` | **yes** — this is the verdict |
| `triptracer.trip.read` | `GET /api/trip/{pnr}`, `GET /api/service/trips/{pnrId}` | only if we also want to read the Trip |
| `triptracer.search.read` | exact-PNR lookup | no — we always know our own locator |
| `triptracer.qa.patterns` | the QA pattern service | no |

Default-deny: every other route answers 403 `NOT_AUTHORIZED` to a service principal. Asking for one
scope keeps it that way.

## The token we then mint

Per §2.2, and `core/raptor.py` builds exactly this:

* header — `alg` `ES256`, `kid` required, `typ` optional. A header carrying `crit`, `jwk`, `jku`,
  `x5u` or `x5c` is refused: the server never takes a key from the token.
* claims — `iss`, `aud`, `sub`, `iat`, `exp`, `scope` (space separated), **all required**; `nbf`
  honoured when present.
* lifetime — at most 15 minutes, `exp` no further than 15 minutes ahead, 60 s of clock skew either
  way. We use 300 s and re-mint 60 s before expiry.

Refused with 401: over 8 KiB; not three parts; an algorithm other than RS256/ES256, or one that
differs from the key's; an unknown issuer, key id, audience or principal; a bad signature; a missing
claim; expired, not yet valid, or too long-lived.

**An HS256 token cannot be used here at all.** A `tt_session`, or the CCT auth service's token, is
refused for its algorithm — so a session secret cannot mint a service token, and a service token can
never act as a session. This is also why calling through case-intake is a different credential
entirely (RS256 from `cct-auth-service`, audience `case-intake-service`, scope
`case_intake.full_access`) rather than a shortcut to the same one.

## Then, on our side

```
AQA_TT_KEY_PEM=…/data-seed-int.key     # path, or the PEM itself
AQA_TT_KID=data-seed-int-2026-10
AQA_TT_ISSUER=urn:cct:ac-cct-data-seed
AQA_TT_PRINCIPAL=data-seed
# AQA_TT_AUDIENCE defaults to urn:cct:triptracer-api
# AQA_TT_BASE overrides the host for the environment
```

## Already confirmed

`POST https://triptracer.ac-cct-int.cloud.aircanada.com/api/dds-evaluations?engine=raptor` answered
**401** from this workstation, connecting in 0.27 s. The host is reachable and the route exists; the
token is the only thing missing. No network, VPN or firewall work is needed.

The second question for the same owner: **which rule image INT runs.** As of 2026-10-15 the current
rules (cascade #400 + #403) were deployed to BAT only, and on an older image about 90 rule-dependent
cases fail for that reason alone — so a verdict from INT means nothing until that is known.
