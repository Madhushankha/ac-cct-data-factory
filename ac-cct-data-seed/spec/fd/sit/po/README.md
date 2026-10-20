# fd/sit/po — not imported

The 132-case FD SIT set. No specs here yet.

To fill it: the SIT fixtures are the source, and `tools/import_po.py` is the pattern to follow —
it reads fixtures, binds each to its expectation, writes one spec per case and records the binding
in `catalog/`. Any case whose expectation cannot be bound to Jira should be left out rather than
imported with a guess, for the reason in `spec/README.md`: a set that can report a pass without a
stated expectation is worse than an empty one.
