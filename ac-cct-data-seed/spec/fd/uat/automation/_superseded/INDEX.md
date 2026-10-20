# specs-nobooking: bookings for the 19 scenarios skipped as "no booking data"

All flights/passenger names not in the scenario text are assumed (listed in each spec's `assumed`). Default booking: domestic APPR,
240 min arrival delay, code 42 (controllable) -> FD-APPR-EL-01 CAD 400 (DELAY_3_TO_LT_6_HOURS). Flight numbers differ per spec to avoid colliding with existing (flight, day) keys.

| id | booking | why |
|---|---|---|
| FD_ED_TC_03 | none: expectNotFound, passenger JOHN SMITHSON | PNR/e-ticket/Aeroplan must all match nothing (shell case path) |
| FD_ED_TC_06 | SOPHIE TREMBLAY, AC 450 YUL-YYZ, +240, APPR EL-01 CAD 400 | OTP outage: tester just needs a valid eligible PNR |
| FD_ED_TC_10 | LUC GAGNON, AC 452 YUL-YYZ, +240, APPR EL-01 CAD 400 | intent detection: tester picks "File a compensation claim", needs a valid PNR |
| FD_ED_TC_16 | EMMA WATSON, AC 454 YYZ-YUL, +240, APPR EL-01 CAD 400; agency hint TravelCo/Mark Johnson | travel agent files for Emma Watson; TT must return PNR FOUND |
| FD_TC_211 | JEAN-PIERRE MARTIN, AC 456 YUL-YYZ, +240, APPR EL-01 | claims company, Canada disruption, rejected |
| FD_TC_212 | SOPHIE LEFEVRE (FR), AC 873 CDG-YYZ, +300, EU FD-EU-EL-14 EUR 600 | claims company, France (EU) origin, manual handoff |
| FD_TC_213 | MICHAEL THOMPSON (US), AC 725 EWR-YYZ, +240, APPR EL-01 | claims company, US origin, rejected then disputed |
| FD_TC_214 | ISABELLE ROY, AC 458 YYZ-YUL, +240, APPR EL-01 | claims company, no claim opened, Canada, rejected |
| FD_TC_215 | LUCAS PEETERS (BE), AC 876 BRU-YYZ, +300, EU FD-EU-EL-14 EUR 600 | claims company, no claim opened, Belgium (EU), manual handoff |
| FD_TC_216 | DANIEL HARRIS (US), AC 727 EWR-YYZ, +240, APPR EL-01 | claims company, no claim opened, US, rejected then disputed |
| FD_TC_217 | FRANCOIS BERGERON, AC 460 YUL-YYZ, +240, APPR EL-01, flight 21 days ago | claims company follow-up on CS case opened 15 days ago (case itself not expressible) |
| FD_TC_218 | EMILIE GAGNON, AC 462 YUL-YYZ, +240, APPR EL-01, flight 26 days ago | same, case opened 20 days ago, user disputes the wait |
| FD_TC_220 | MARGARET HOLLOWAY (SRC), AC 468 YUL-YYZ, +240, APPR EL-01 | travel agency for an elderly client, disputes rejection |
| FD_TC_221 | RICHARD CALDWELL, AC 470 YYZ-YUL, +240, APPR EL-01 | executive assistant for an executive, hard rejection |
| FD_TC_222 | CLAIRE DESJARDINS, Aeroplan Basic linked, AC 472 YUL-YYZ, +420, APPR EL-02 CAD 700 | family/friend passes OTP -> full automation to payout (cash 700 / wallet 840) |
| FD_TC_223 | HELEN CARTER (SRC), AC 474 YUL-YYZ, +240, APPR EL-01 | elderly mother, family OTP fails, POA upload, manual handling |
| FD_TC_224 | EMMA LAROCHE (CHD age 12), AC 476 YUL-YYZ, +240, APPR EL-01 | legal guardian of a minor, POA path |
| FD_TC_225 | GERALD PRESTON, AC 478 YYZ-YUL, +240, APPR EL-01 | insurer for a policyholder, no document, denied |
| FD_TC_226 | OLIVIA BRENNAN (CHD age 14, umnr true), AC 111 YYZ-YVR, +240, APPR EL-01 | parent of unaccompanied minor, OTP passes, DDS runs automatically; amount same as adult |
