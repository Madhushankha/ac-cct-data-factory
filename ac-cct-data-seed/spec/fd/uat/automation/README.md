# fd/uat/automation — 266 FD scenarios

The set an automated suite runs end to end. **Jira is the source**: CHAI-31809's Xray tests define
the seed data, the chat and the checks. The FD gap document is not the source and disagreeing with
it is not a defect.

* `FD_TC_001`–`239` — the main table
* `FD_ED_TC_01`–`27` — the edge set
* `FD_TC_209` holds two bookings in one spec, addressed `FD_TC_209#1` and `#2`

## What has been proven

265 of the 266 built and published to INT (5,631 messages); 262 were read back from the engine and
judged. Re-judged by `flows/flight_disruption.py`: **215 agree, 46 disagree, 1 not judged**.

`reports/validated.json` in the kit still says 205/57. That is the *stored* judgement from before
four comparator fixes landed, and it is why `adapters/file_run_store.py` keeps the engine's document
and recomputes the verdict on every read. Trust a number that was recomputed, not one that was
saved.

The 46 are grouped by cause, with an owner each, in `builder/reports/disagreements.html`. Four
cases cannot pass whatever is seeded — `FD_TC_210` needs a `DBCP` keyword, `FD_TC_178` an
`ASL_regulatory_data_missing_lookup` table and EU261 distance bands, `FD_ED_TC_03` has no booking by
design — and that is stated rather than counted as a failure.

## `_superseded/`

19 specs whose booking was authored later. The files here are the original "no booking data"
shells: zero segments, `NO_DETERMINATION`, nothing to seed. The authored bookings replaced them in
this folder, and `INDEX.md` inside `_superseded/` records what was assumed for each and why.

Nothing reads `_superseded/`. It exists so that the choice is visible instead of being an accident
of directory order, which is how it worked before.
