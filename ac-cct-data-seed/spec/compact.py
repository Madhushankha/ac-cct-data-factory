"""The compact text form of a scenario spec, and its codec.

A spec's JSON is around 520 tokens, which is what a model pays to read or write one case. The same
case in this form is around 40, and the saving is not compression: it is dropping the fields that
are identical in every spec and the facts that are already the environment's default.

The form is for TRANSPORT -- what a generator reads and writes, what a reviewer scans in a diff.
The JSON stays the record. So the codec's contract is narrow and testable:

    decode(encode(spec)) == spec     for every field in CARRIED
    anything in DROPPED              is absent from the text and stated here, never lost silently

`tests/test_compact_roundtrip.py` asserts exactly that over every spec in the repo, which is why
the form can be trusted in a pipeline rather than only agreed in a document.

Shape. One line per thing, a letter naming what it is, the common fields positional and the long
tail as `key=value`:

    # <id> <family> f<flightDaysAgo>
    P <type> <LAST>/<FIRST> <residence> [key=value ...]
    L <seg>/<bound> <carrier><number> <ORG>><DST> <dep>-<arr> d<dayOffset> <cabin>/<class> <status>
    O <seg> <kind> [arr=<min>] [dep=<min>] [code=<c>] [cancel=<c>] [notice=<h>] [divert=<apt>]
    R <replacesSeg> <carrier><number> <ORG>><DST> <dep>-<arr> d<dayOffset> <acc|rej> [key=value ...]
    S <seg> [dep=<delta>] [arr=<delta>] [notice=<h>] [key=value ...]
    E <seg> <pax> <event> [key=value ...]
    X <eligibility> <regime> <systemCode> <amount> <currency> <delayMin> <control> <cause>
    X. <key>=<json>                    one line per `expect` field beyond those eight
    V <text>                           one line per expected UI line, only with ui=True

Positional fields are the ones every spec states; `key=value` carries the rest, JSON-encoded, so a
field nobody anticipated still survives a round trip. A positional field a spec leaves null is
written `-`, which decodes back to None rather than to the string.

Why not positional throughout: `outcomes` alone has eleven distinct keys across the pack and
`expect` has twenty-four, most on a handful of cases. A fixed column order for those would be
unreadable and would break the first time someone adds a field.
"""
from __future__ import annotations

import json
from typing import Any

#: `expect` fields that get the positional X line, in this order.
_X_POSITIONAL = ("eligibility", "regime", "systemCode", "amount", "currency",
                 "delayMin", "control", "cause")
#: of those, the ones the corpus holds as integers
_X_INT = ("amount", "delayMin")

#: Written into the text and restored by `decode`.
CARRIED = ("id", "family", "flightDaysAgo", "passengers", "segments", "outcomes",
           "rebooking", "scheduleChanges", "paxEvents", "vouchers", "bags", "expect",
           "loyalty")

#: Deliberately absent from the text. The JSON keeps them; nothing reads them from the form.
DROPPED = {
    "summary": "prose: the case already has it, and a generator must not invent a new one",
    "assumed": "the author's notes on what they inferred; review material, not seed data",
    "unsupported": "the author's notes on what the booking cannot express",
    "expect.ttUi": "expected screen lines: carried only with ui=True, and never sent to a generator",
    "loyalty.why": "why the block says what it says: review material for a person, and a "
                   "generator must not copy one case reasoning onto another",
}

#: A spec holding several bookings is out of scope: its shape is a list of specs, not one case.
#: One of the 343 is like this, and the codec refuses it rather than flattening it into a lie.
UNSUPPORTED_KEY = "bookings"


class NotCompactable(ValueError):
    """Raised for a spec this form cannot carry. The caller keeps the JSON."""


def legend(ui: bool = False) -> str:
    """The lines a generator needs in front of it, paid once per batch rather than per case."""
    out = [
        "# <id> <family> f<flightDaysAgo>",
        "P <ADT|CHD|INF> <LAST>/<FIRST> <residence> [ap=<number>] [tier=<tier>] [employee=true]",
        "L <seg>/<bound> <carrier><number> <ORG>><DST> <dep>-<arr> d<dayOffset> <cabin>/<class> <status>",
        "O <seg> <delay|cancel|ontime|divert> [arr=<min>] [dep=<min>] [code=<c>] [cancel=<c>]"
        " [notice=<h>] [divert=<apt>]",
        "R <replacesSeg> <carrier><number> <ORG>><DST> <dep>-<arr> d<dayOffset> <acc|rej>",
        "S <seg> [dep=<deltaMin>] [arr=<deltaMin>] [notice=<h>]",
        "E <seg> <pax> <event>",
        "X <eligibility> <regime> <systemCode> <amount> <currency> <delayMin> <control> <cause>",
        "X. <key>=<json>   one per expect field beyond those eight",
        "Y <open|frozen_l1|frozen_l2> <tier|BASIC> [preexisting=true]"
        "   the AC Wallet member the case needs; omit the line when it needs none",
    ]
    if ui:
        out.append("V <text>   one per expected UI line")
    out += [
        "",
        "Times are LOCAL at that airport. A null positional field is written '-'.",
        "P repeats per passenger, L per segment in journey order, O per disrupted segment.",
    ]
    return "\n".join(out)


# --------------------------------------------------------------------------- encode


def _pos(v: Any) -> str:
    """A positional field: None becomes '-', so an absent value cannot read as the text '-'."""
    if v is None:
        return "-"
    s = str(v)
    return s.replace(" ", " ") if " " in s else s      # a space would split the field


def _bare_ok(v: str) -> bool:
    """Whether a string can be written unquoted, i.e. `decode` will read it back AS a string.

    `code=64` would decode to the integer 64, and the corpus holds delay codes as strings
    throughout, so anything JSON would parse as another type keeps its quotes.
    """
    if not v or " " in v or "=" in v:
        return False
    try:
        json.loads(v)
    except json.JSONDecodeError:
        return True                                   # not JSON at all, so it can only be a string
    return False


def _one(name: str, v: Any) -> str:
    """One `key=value`, quoted unless the text can only read back as the string it is."""
    return (f"{name}={v}" if isinstance(v, str) and _bare_ok(v)
            else f"{name}={json.dumps(v, separators=(',', ':'))}")


def _kv(d: dict, skip: tuple[str, ...]) -> list[str]:
    """The long tail, JSON-encoded so a value survives whatever it is."""
    return [_one(k, d[k]) for k in sorted(d) if k not in skip and d[k] is not None]


def _line(letter: str, positional: list[str], tail: list[str]) -> str:
    return " ".join([letter, *positional, *tail]).rstrip()


def encode(spec: dict, *, ui: bool = False) -> str:
    """One spec as compact text. Raises NotCompactable for a shape the form cannot carry."""
    if UNSUPPORTED_KEY in spec:
        raise NotCompactable(f"{spec.get('id')}: holds {UNSUPPORTED_KEY!r}, which is several bookings")

    lines = [f"# {spec['id']} {spec.get('family') or '-'} f{_pos(spec.get('flightDaysAgo'))}"]

    for p in spec.get("passengers") or []:
        name = f"{_pos(p.get('lastName'))}/{_pos(p.get('firstName'))}"
        tail = _kv(p, ("type", "firstName", "lastName", "residence"))
        # aeroplanNumber / aeroplanTier are long names for fields every FD case states
        tail = [t.replace("aeroplanNumber=", "ap=").replace("aeroplanTier=", "tier=") for t in tail]
        lines.append(_line("P", [_pos(p.get("type")), name, _pos(p.get("residence"))], tail))

    for s in spec.get("segments") or []:
        lines.append(_line("L", [
            f"{_pos(s.get('seg'))}/{_pos(s.get('bound'))}",
            f"{_pos(s.get('carrier'))}{_pos(s.get('number'))}",
            f"{_pos(s.get('origin'))}>{_pos(s.get('destination'))}",
            f"{_pos(s.get('depLocal'))}-{_pos(s.get('arrLocal'))}",
            f"d{_pos(s.get('dayOffset'))}",
            f"{_pos(s.get('cabin'))}/{_pos(s.get('bookingClass'))}",
            _pos(s.get("status")),
        ], _kv(s, ("seg", "bound", "carrier", "number", "origin", "destination",
                   "depLocal", "arrLocal", "dayOffset", "cabin", "bookingClass", "status"))))

    for o in spec.get("outcomes") or []:
        tail = _kv(o, ("seg", "kind", "arrDelayMin", "depDelayMin", "delayCode", "cancelCode",
                       "noticeHours", "divertTo"))
        for key, short in (("arrDelayMin", "arr"), ("depDelayMin", "dep"), ("delayCode", "code"),
                           ("cancelCode", "cancel"), ("noticeHours", "notice"), ("divertTo", "divert")):
            if o.get(key) is not None:
                tail.insert(0, _one(short, o[key]))
        lines.append(_line("O", [_pos(o.get("seg")), _pos(o.get("kind"))], tail))

    for r in spec.get("rebooking") or []:
        acc = r.get("accepted")
        lines.append(_line("R", [
            _pos(r.get("replacesSeg")),
            f"{_pos(r.get('carrier'))}{_pos(r.get('number'))}",
            f"{_pos(r.get('origin'))}>{_pos(r.get('destination'))}",
            f"{_pos(r.get('depLocal'))}-{_pos(r.get('arrLocal'))}",
            f"d{_pos(r.get('dayOffset'))}",
            "acc" if acc is True else "rej" if acc is False else "-",
        ], _kv(r, ("replacesSeg", "carrier", "number", "origin", "destination",
                   "depLocal", "arrLocal", "dayOffset", "accepted"))))

    for s in spec.get("scheduleChanges") or []:
        tail = _kv(s, ("seg", "depDeltaMin", "arrDeltaMin", "noticeHours"))
        for key, short in (("depDeltaMin", "dep"), ("arrDeltaMin", "arr"), ("noticeHours", "notice")):
            if s.get(key) is not None:
                tail.insert(0, _one(short, s[key]))
        lines.append(_line("S", [_pos(s.get("seg"))], tail))

    for e in spec.get("paxEvents") or []:
        lines.append(_line("E", [_pos(e.get("seg")), _pos(e.get("pax")), _pos(e.get("event"))],
                           _kv(e, ("seg", "pax", "event"))))

    for key, letter in (("vouchers", "W"), ("bags", "G")):
        for item in spec.get(key) or []:
            lines.append(_line(letter, [], _kv(item, ())))

    loyalty = spec.get("loyalty") or {}
    if loyalty:
        # the wallet state and tier positionally, because every loyalty case states both;
        # `why` is documentation and stays in the JSON (see DROPPED)
        lines.append(_line("Y", [_pos(loyalty.get("wallet_state") or "open"),
                                 _pos(loyalty.get("tier") or "E50K")],
                           _kv(loyalty, ("wallet_state", "tier", "why"))))

    exp = spec.get("expect") or {}
    lines.append(_line("X", [_pos(exp.get(k)) for k in _X_POSITIONAL], []))
    for k in sorted(exp):
        if k in _X_POSITIONAL or k == "ttUi" or exp[k] is None:
            continue
        lines.append(f"X. {k}={json.dumps(exp[k], separators=(',', ':'))}")
    if ui:
        for line in exp.get("ttUi") or []:
            lines.append(f"V {line}")

    return "\n".join(lines)


# --------------------------------------------------------------------------- decode


def _unpos(s: str, as_int: bool = False) -> Any:
    """A positional field back to its value: '-' to None, otherwise the slot's own type.

    The slot decides, not the text. Every field in the corpus holds one type throughout -- flight
    `number` and `delayCode` are strings, `seg` and `delayMin` are integers -- so guessing from the
    characters would turn "301" into 301 and lose the distinction on the way back.
    """
    if s == "-":
        return None
    s = s.replace(" ", " ")
    if not as_int:
        return s
    # a numeric slot carries whatever number the spec held. The kit's specs write an amount
    # as `400`; the specs imported from a dataset manifest write `400.0`, and int("400.0")
    # raises -- which is how the corpus grew a spec the format could not decode. An integral
    # value comes back as an int, so the common case is unchanged.
    number = float(s)
    return int(number) if number.is_integer() else number


def _split_kv(parts: list[str], long_names: dict[str, str]) -> dict:
    out: dict[str, Any] = {}
    for p in parts:
        k, _, v = p.partition("=")
        k = long_names.get(k, k)
        try:
            out[k] = json.loads(v)
        except json.JSONDecodeError:
            out[k] = v
    return out


def _pair(s: str, sep: str, as_int: bool = False) -> tuple[Any, Any]:
    a, _, b = s.partition(sep)
    return _unpos(a, as_int), _unpos(b, as_int)


def decode(text: str) -> dict:
    """Compact text back to a spec dict holding exactly the fields in CARRIED."""
    spec: dict[str, Any] = {"passengers": [], "segments": [], "outcomes": [], "rebooking": [],
                            "scheduleChanges": [], "paxEvents": [], "vouchers": [], "bags": [],
                            "expect": {}}
    ui: list[str] = []

    for raw in text.splitlines():
        # only the newline: a V line is an expected screen line, and a trailing space in one is
        # part of what the screen shows (SOC_UAT_007 ends a band label with one)
        raw = raw.rstrip(chr(13) + chr(10))
        if not raw.strip():
            continue
        letter, _, rest = raw.partition(" ")
        parts = rest.split()

        if letter == "#":
            spec["id"], fam, days = parts[0], parts[1], parts[2]
            spec["family"] = None if fam == "-" else fam
            spec["flightDaysAgo"] = _unpos(days[1:], True)

        elif letter == "P":
            last, first = _pair(parts[1], "/")
            p = {"type": _unpos(parts[0]), "firstName": first, "lastName": last,
                 "residence": _unpos(parts[2])}
            p.update(_split_kv(parts[3:], {"ap": "aeroplanNumber", "tier": "aeroplanTier"}))
            spec["passengers"].append(p)

        elif letter == "L":
            seg, bound = _pair(parts[0], "/", True)
            org, dst = _pair(parts[2], ">")
            dep, arr = _pair(parts[3], "-")
            cab, cls = _pair(parts[5], "/")
            s = {"seg": seg, "bound": bound, "carrier": parts[1][:2],
                 "number": _unpos(parts[1][2:]), "origin": org, "destination": dst,
                 "depLocal": dep, "arrLocal": arr, "dayOffset": _unpos(parts[4][1:], True),
                 "cabin": cab, "bookingClass": cls, "status": _unpos(parts[6])}
            s.update(_split_kv(parts[7:], {}))
            spec["segments"].append(s)

        elif letter == "O":
            o = {"seg": _unpos(parts[0], True), "kind": _unpos(parts[1])}
            o.update(_split_kv(parts[2:], {"arr": "arrDelayMin", "dep": "depDelayMin",
                                           "code": "delayCode", "cancel": "cancelCode",
                                           "notice": "noticeHours", "divert": "divertTo"}))
            spec["outcomes"].append(o)

        elif letter == "R":
            org, dst = _pair(parts[2], ">")
            dep, arr = _pair(parts[3], "-")
            r = {"replacesSeg": _unpos(parts[0], True), "carrier": parts[1][:2],
                 "number": _unpos(parts[1][2:]), "origin": org, "destination": dst,
                 "depLocal": dep, "arrLocal": arr, "dayOffset": _unpos(parts[4][1:], True),
                 "accepted": True if parts[5] == "acc" else False if parts[5] == "rej" else None}
            r.update(_split_kv(parts[6:], {}))
            spec["rebooking"].append(r)

        elif letter == "S":
            s = {"seg": _unpos(parts[0], True)}
            s.update(_split_kv(parts[1:], {"dep": "depDeltaMin", "arr": "arrDeltaMin",
                                           "notice": "noticeHours"}))
            spec["scheduleChanges"].append(s)

        elif letter == "E":
            e = {"seg": _unpos(parts[0], True), "pax": _unpos(parts[1], True),
                 "event": _unpos(parts[2])}
            e.update(_split_kv(parts[3:], {}))
            spec["paxEvents"].append(e)

        elif letter in ("W", "G"):
            spec["vouchers" if letter == "W" else "bags"].append(_split_kv(parts, {}))

        elif letter == "Y":
            spec["loyalty"] = {"wallet_state": _unpos(parts[0]),
                               "tier": _unpos(parts[1]),
                               **_split_kv(parts[2:], {})}

        elif letter == "X":
            spec["expect"].update({k: _unpos(v, k in _X_INT)
                                   for k, v in zip(_X_POSITIONAL, parts)})

        elif letter == "X.":
            k, _, v = rest.partition("=")
            spec["expect"][k] = json.loads(v)

        elif letter == "V":
            ui.append(rest)

        else:
            raise ValueError(f"unknown line type {letter!r}: {raw[:60]!r}")

    if ui:
        spec["expect"]["ttUi"] = ui
    return spec


# --------------------------------------------------------------------------- comparison


def carried(spec: dict, *, ui: bool = False) -> dict:
    """The part of a spec the form claims to carry, for comparing against a round trip.

    Three pairs are the same thing to this form and normalise together here: a key a spec omits
    and one it sets to null; a list it omits and one it sets to empty; a field inside an item set
    to null and one left out. `decode` cannot tell any pair apart and does not pretend to -- what
    it restores is the content, not which spelling the author used. Comparing a round trip means
    putting both sides through this function.
    """
    out = {}
    for k in CARRIED:
        v = spec.get(k)
        if k in ("passengers", "segments", "outcomes", "rebooking", "scheduleChanges",
                 "paxEvents", "vouchers", "bags"):
            out[k] = [{kk: vv for kk, vv in item.items() if vv is not None} for item in (v or [])]
        elif k == "loyalty":
            # a spec with no loyalty block and one with an empty one are the same case to this
            # form, and `why` is not carried, so both sides normalise to the data keys alone
            # the Y line always states both, and a spec that omits wallet_state means open, so
            # both sides get the same defaults filled in -- otherwise a spec carrying only a tier
            # compares unequal against its own round trip
            block = {kk: vv for kk, vv in (v or {}).items()
                     if vv is not None and kk != "why"}
            if block:
                block.setdefault("wallet_state", "open")
                block.setdefault("tier", "E50K")
            out[k] = block
        elif k == "expect":
            out[k] = {kk: vv for kk, vv in (v or {}).items()
                      if vv is not None and vv != [] and vv != {} and (ui or kk != "ttUi")}
        else:
            out[k] = v
    return out
