# soc/uat/automation — 77 SOC scenarios

`SOC_UAT_001`–`076`, plus `SOC_UAT_076__CHAI-...` which is a second spec for the same card and
should be renumbered or removed.

**Not seeded from here, and the policy will not claim a verdict.** `flows/pending.py` states why in
full; the short version is three things:

1. SOC answers per passenger **per segment**, where FD answers per bound. Judging a SOC document
   with FD's row shape passes a document holding the right number of wrong rows.
2. The eligible cases answer `receipt_validation_required` until a receipt is uploaded, and
   nothing uploads one.
3. These are the SIT-layout cards; no UAT card layout is parsed yet.

Three delay gates (120 / 300 / 360 minutes) decide the SOC tiers, the regime follows the segment's
origin rather than the passenger's residence, and an ACR voucher is a hard gate — those are in
`reference/`, not re-derived per case.
