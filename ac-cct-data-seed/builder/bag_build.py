"""The bag half of a baggage build: `scenario_build.py` with each spec's `bagPlan` turned into events.

    bag_build.py <plan file> <specs dir> <out dir> <env> [--run-day YYYY-MM-DD]

A drop-in replacement for `scenario_build.py` in the one case it cannot serve: a scenario whose
whole expectation is about a bag. It injects two steps into each plan and then runs
`scenario_build.main` unchanged, so an FD or SOC build taking this path builds exactly as before --
a spec with no `bagPlan` is passed straight through.

    bag_checked   the builder's own step: the CM bag group, the DCS correlation, and the BROCK
                  BagCreatedEvent / BagAcceptedDeclaration, on the bag's segment 150 minutes
                  before it departs (after check-in).
    bag_file      the rest of the bag's BROCK SmartSuite history, in the shape the case needs: the
                  delayed-bag record (AHL + TracerReferenceId) opened 2 h after the delayed
                  flight's ACTUAL arrival, a carousel delivery at its hour, the record's closure N
                  days before the run day, a station scan with no record at all -- or no bag.

Vendored from the baggage SIT kit's `baggage/bag_build.py` (BAGGAGE_SIT_KIT_20261017), which is the
script that published the live INT and BAT sets. Three differences, all because this project
already holds what that script reached outside itself for:

* the seed pool comes from `uat_config.pool_dir()` (`-`), not a path on the author's machine;
* no `salt.txt` is copied: this project's `scenario_build.py` does not read one;
* `spec_to_build` has already run -- the plans arrive built, so only the injection happens here.

`BagBuild` subclasses the builder's `Build` rather than editing it, for the reason the kit gives:
the cascade builder repo is not ours to change. It overrides three things --

* `_surround_bag_tail`, because the builder's tail loads, unloads and delivers EVERY bag to the
  carousel, which would make every case a delivered bag and erase the shape under test;
* `_brock`, to list only the bag's own flight legs (the builder lists every segment the booking
  holds) and to keep an exemplar's file number off events that are not its own;
* `step_bag_file`, which does not exist upstream: it is how a case's own history is emitted.
"""
from __future__ import annotations

import json
import os
import sys
from datetime import date, datetime, time, timedelta, timezone
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import spec_to_build  # noqa: E402,F401  (puts the /qa builder on sys.path as a side effect)
import scenario_build  # noqa: E402
from builder import Build, local_to_utc  # noqa: E402


def iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse(text: str) -> datetime:
    return datetime.fromisoformat(text.replace("Z", "+00:00"))


class BagBuild(Build):
    """The builder's Build with the delayed-bag record shapes a baggage case needs."""

    def _surround_bag_tail(self):
        # the builder's tail delivers every bag; each case's own history is emitted by step_bag_file
        return None

    def step_bag_checked(self, at, params, phase, surround):
        self._bag_k = params.get("segment", 1)
        return super().step_bag_checked(at, params, phase, surround)

    def _brock(self, at, kind, i, bag, seg, extra, family, phase, origin="step"):
        super()._brock(at, kind, i, bag, seg, extra, family, phase, origin)
        m = self.messages[-1]
        x = m["obj"]
        k0 = getattr(self, "_bag_k", 1)
        mine = {(s.op_carrier, s.op_number.zfill(4), s.origin)
                for s in self.plan.segments if s.k >= k0}
        for key in ("BagFlightLegs", "FlightLegs"):
            if isinstance(x.get(key), list):
                x[key] = [l for l in x[key]
                          if (l.get("FlightCarrierCode"), l.get("FlightNumber"),
                              l.get("FlightDepartureStationCode")) in mine] or x[key][-1:]
        if "TracerReferenceId" not in extra:
            x.pop("TracerReferenceId", None)   # one file number never rides on another's event
        m["value"] = json.dumps(x, separators=(",", ":"))

    def step_bag_file(self, at, params, phase, surround):
        seg = self.seg(params["segment"])
        bags = [(i, b) for i in sorted(self.bags) for b in self.bags[i]]
        for ev in params.get("events") or []:
            i, bag = bags[ev["bag"]]
            extra = {"StationCode": ev.get("station") or seg.destination}
            if ev.get("tracer"):
                extra["TracerReferenceId"] = ev["tracer"]
            extra.update(ev.get("extra") or {})
            self._brock(parse(ev["at"]), ev["kind"], i, bag, seg, extra, "bag_file", phase, "step")


def bag_steps(spec: dict, build: dict) -> tuple[list, list]:
    """The `bag_checked` step and the context `bag_events` needs, from a spec's `bagPlan`."""
    plan = spec.get("bagPlan") or {}
    if not plan or plan.get("shape") == "no_bag" or not plan.get("bags"):
        return [], []
    k = plan["segment"]
    seg_flight = next(f for f in build["flights"]
                      if f.get("segment") == k and not f.get("explicit"))
    dest = next(s for s in spec["segments"] if s["seg"] == k)["destination"]
    npax = len(spec.get("passengers") or [1])
    checked = {"family": "bag_checked",
               "at": {"anchor": f"departure:{k}", "offsetMinutes": -150},
               "params": {"segment": k,
                          "count": 1 if plan.get("perPassenger") else plan["bags"]}}
    if not plan.get("perPassenger") and npax > 1:
        checked["params"]["passengers"] = [0]
    return [checked], [{"segment": k, "dest": dest,
                        "delay": int(seg_flight.get("minutes") or 0)}]


def bag_events(plan: dict, sched_arr: datetime, delay: int, dest: str,
               run_now: datetime) -> list[dict]:
    """One case's BROCK history. The AHL opens after the ACTUAL arrival, so delay is added."""
    shape = plan["shape"]
    n = plan["bags"]
    ahl_at = sched_arr + timedelta(minutes=delay) \
        + timedelta(hours=plan.get("ahlHoursAfterActualArrival", 2))
    seed = plan.get("ahlNumberSeed") or 10000
    ahl_ids = [f"{dest}AC{(seed + j) % 100000:05d}"
               for j in range(max(plan.get("ahls") or 1, 1))]
    ev: list[dict] = []
    for j in range(n):
        tracer = ahl_ids[j % len(ahl_ids)]
        if shape == "no_ahl":
            ev.append({"bag": j, "kind": "BagSeenAtStationDeclaration",
                       "at": iso(sched_arr + timedelta(minutes=delay + 30)), "station": dest})
            continue
        ev.append({"bag": j, "kind": "BagDelayedBagRecordCreated", "at": iso(ahl_at),
                   "tracer": tracer, "station": dest,
                   "extra": {"ForwardFlightRoute": f"YVR-{dest}"}})
        if "delivered" in shape:
            h = plan.get("deliveredHoursAfterSchedArrival") or 24
            ev.append({"bag": j, "kind": "BagDeliveredToCarouselDeclaration",
                       "at": iso(sched_arr + timedelta(hours=h)), "station": dest,
                       "extra": {"CarouselFriendlyName": "Carousel 4"}})
        if "closed" in shape:
            ago = plan.get("closedDaysAgo") or []
            when = run_now - timedelta(days=ago[j % len(ago)]) if ago \
                else ahl_at + timedelta(hours=24)
            ev.append({"bag": j, "kind": "BagDelayedBagRecordClosedEvent", "at": iso(when),
                       "tracer": tracer, "station": dest})
    return sorted(ev, key=lambda e: e["at"])


def inject(plans: list[dict], specs: dict[str, dict], run_day: str) -> int:
    """Add the two steps to every plan whose spec asks for a bag. Returns how many were touched."""
    run_now = datetime.combine(date.fromisoformat(run_day), time(12, 0), tzinfo=timezone.utc)
    touched = 0
    for b in plans:
        spec = specs.get(b.get("id")) or {}
        b["bagPlan"] = spec.get("bagPlan")
        b["expectBag"] = spec.get("expectBag")
        checked, ctx = bag_steps(spec, b)
        if not checked:
            continue
        b["plan"]["phases"].setdefault("day_of_flight", []).extend(checked)
        c = ctx[0]
        seg = b["plan"]["bounds"][-1]["segments"][-1]
        sched_arr = local_to_utc(seg["arrival"], seg["destination"])
        b["bagEvents"] = bag_events(spec["bagPlan"], sched_arr, c["delay"], c["dest"], run_now)
        b["plan"]["phases"].setdefault("post_flight", []).append(
            {"family": "bag_file",
             "at": {"anchor": f"arrival:{c['segment']}", "offsetMinutes": 0},
             "params": {"segment": c["segment"], "events": b["bagEvents"]}})
        touched += 1
    return touched


def main(plan_file: str, specs_dir: str, out_dir: str, env: str = "int",
         run_day: str | None = None) -> None:
    plans = json.loads(Path(plan_file).read_text(encoding="utf-8"))
    specs = {p.stem: json.loads(p.read_text(encoding="utf-8"))
             for p in sorted(Path(specs_dir).glob("*.json"))}
    day = run_day or datetime.now(timezone.utc).date().isoformat()
    touched = inject(plans, specs, day)
    with_bags = Path(plan_file).with_name(Path(plan_file).stem + "-bags.json")
    with_bags.write_text(json.dumps(plans, indent=1), encoding="utf-8")
    print(f"bag steps injected into {touched} of {len(plans)} plan(s); {with_bags.name}")
    scenario_build.Build = BagBuild
    scenario_build.main(str(with_bags), "-", out_dir, env)


if __name__ == "__main__":
    a = sys.argv[1:]
    opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d        # noqa: E731
    main(a[0], a[1], a[2], a[3] if len(a) > 3 and not a[3].startswith("--") else "int",
         opt("--run-day"))
