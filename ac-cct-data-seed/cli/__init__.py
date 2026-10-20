"""The command line: one entry point, thin.

A command parses arguments, builds the adapters, calls one use case and prints what came back. It
holds no logic of its own, which is the test of whether this layering worked: if a command needs to
decide something, the decision belongs in `application/` or a flow policy.

    python -m cli sets                                    what the spec tree holds
    python -m cli flows                                   the flows, and which can claim a verdict
    python -m cli doctor                                  are the external paths and credentials there
    python -m cli plan  fd/uat/automation                 patch and date, publish nothing
    python -m cli seed  fd/uat/automation --go            build, publish, settle, read, judge
    python -m cli judge fd/uat/automation --run <label>   re-judge a stored run without re-reading
    python -m cli show  FD_TC_118                         one case: its spec, and the last verdict

`seed` without `--go` is a dry run: it builds and sends nothing. That is the default because
publishing writes to topics other services read.
"""
