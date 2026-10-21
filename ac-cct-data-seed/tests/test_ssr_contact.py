"""The CTCE / CTCM contact SSRs get the booking's own inbox and phone, not the builder's "SYNTHETIC TEXT".

The chat reads CTCE as the e-mail on file: left as "SYNTHETIC TEXT" it offered `SY***` for the OTP and no
code could ever be read (FD_TC_002/003/004/014/015/016/030 on BAT, 2026-10-21).

Run:  python tests/test_ssr_contact.py
"""
from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from adapters.kafka_publisher import _SSR_CONTACT, ssr_email   # noqa: E402

FAILED: list[str] = []


def check(label: str, got: object, want: object) -> None:
    if got != want:
        FAILED.append(label)
        print(f"  FAIL {label}: got {got!r}, wanted {want!r}")
    else:
        print(f"  ok   {label}")


def rewrite(text: str, email: str, phone: str) -> str:
    return _SSR_CONTACT.sub(lambda m: m.group(1) + (ssr_email(email) if m.group(2) == "CTCE" else phone)
                            + m.group(3), text)


CTCE = ('{"service":{"code":"CTCE","creation":{"dateTime":"2026-05-15T16:38:00Z","pointOfSale":{"office":'
        '{"id":"GVAI83140"}}},"nip":5,"serviceProvider":{"code":"AC"},"status":"HK",'
        '"subType":"SPECIAL_SERVICE_REQUEST","text":"SYNTHETIC TEXT"}}')
CTCM = CTCE.replace('"CTCE"', '"CTCM"')
OTHER = CTCE.replace('"CTCE"', '"CHLD"')


def main() -> int:
    mail, phone = "lahiru-fd-tc-002-1022t0302@ae-qa1-aircanada.mailinator.com", "15558775462"
    check("CTCE carries the booking's inbox in IATA form",
          '"text":"LAHIRU-FD-TC-002-1022T0302//AE-QA1-AIRCANADA.MAILINATOR.COM"' in rewrite(CTCE, mail, phone), True)
    check("CTCM carries the booking's phone", '"text":"15558775462"' in rewrite(CTCM, mail, phone), True)
    check("other SSRs keep their text", rewrite(OTHER, mail, phone), OTHER)
    two = '{"keywords":[{"code":"CTCE","text":"x"}],"service":{"code":"OTHS","text":"SYNTHETIC TEXT"}}'
    check("a CTCE does not reach into the next SSR's text", rewrite(two, mail, phone), two)
    print(f"\n{len(FAILED)} failed" if FAILED else "\nall checks passed")
    return 1 if FAILED else 0


if __name__ == "__main__":
    raise SystemExit(main())
