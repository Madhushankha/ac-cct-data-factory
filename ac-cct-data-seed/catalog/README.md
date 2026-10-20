New case id -> source id, source file, who states its expectation, binding status.

| file | set | what the binding is |
|---|---|---|
| `fd-po.json` | `spec/fd/uat/po` | the `fd-uat` fixture each `FD_PO_*` came from, and whether its expectation came from a gap-doc card or only from the dataset manifest |
| `baggage-po.json` | `spec/baggage/sit/po` | the kit case each `BAG_PO_*` came from, and the PNR already published for it on INT and on BAT — pnrId, last names, tickets, bag shape, result and the case number the kit's own check created |

`baggage-po.json` also records `missing` twice, once per flow interface (`spec_dict` and
`parsed_scenario`), and `runnable` beside them. Both interfaces now accept all 73 for seeding, so
`missing` is empty on both and `runnable` is true throughout; recording both is what shows that is
the flow's answer and not an artefact of one interface. It does not mean the verdict can be
claimed — the baggage flow still refuses that, for the per-bag row shape. See
`spec/baggage/sit/po/README.md`.
