# fd/uat/po — 27 FD cases for a product owner

The cases a product owner walks through by hand, imported from the `fd-uat` fixtures by
`tools/import_po.py`. Ids are `FD_PO_001`–`027`.

Each one's provenance is recorded in `catalog/fd-po.json`: the fixture it came from, where its
expectation was resolved, whether the binding is exact, and what is missing if anything. A case
whose expectation came from a gap-doc card rather than from Jira says so there — the distinction
matters, because the gap doc is not authoritative.

These are now reachable through the same build path as the automation set, which they were not when
they lived outside the kit's flat spec folder.
