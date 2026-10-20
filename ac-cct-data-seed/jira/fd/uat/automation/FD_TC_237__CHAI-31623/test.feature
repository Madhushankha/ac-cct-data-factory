GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "Our flight from Montreal to Vancouver was cancelled and they said it was the weather, but the weather was fine. We were put on a later flight and arrived about 7 hours late. I'd like to check if my husband and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot shows the automated decision-making disclaimer ? user agrees to start

IDENTIFICATION (GenUC-01):
User provides "Marie-�ve Tremblay" and PNR "UD002" ? Trip Tracer PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
User selects Email m***@gmail.com ? OTP "482091" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Group booking identifier = NOT PRESENT
"I found 2 passengers on this booking: Marie-�ve Tremblay (Adult - Aeroplan Member), Luc Tremblay (Adult). Would you like to include all passengers in this claim?" ? "Yes, include both" ? PAX count 2 ? 9 or fewer ? PROCEED

JOURNEY SELECTION (GenUC-08):
Chatbot displays: Original flight AC 305 Montreal (YUL) ? Vancouver (YVR), Aug 5, 2026 (Cancelled); rebooked on AC 311; Arrival Delay 7 hours ? user "Yes"

SEGMENT CHECK:
More than 1 segment on the selected journey ? NO (single leg) ? skip GenUC-18

DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS:
Duplicate check ? no existing case for either passenger
72-hour check ? more than 72 hours ? PROCEED
APPR limit ? 9 days (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Gate 1: not employee, not infant ? PROCEED (both)
Gate 2: first INVOL = AC 305 cancellation; no earlier VOL ? promised itinerary = 14-day itinerary (AC 305, arriving 10:30)
Gate 3: both boarded AC 311 and reached YVR ? TRAVELLED
Gate 4: MSL = AC 305 (single leg, not boarded, first/only segment)
Gate 5: MSL operating carrier = AC ? PROCEED
Gate 6: not denied boarding
Gate 7: expiry = Aug 6, 2027 (366 days)
Gate 8: delay = 17:30 ? 10:30 = 420 min (no VOL minutes) ? 3+ hours ? PROCEED
Gate 9: MSL cancellation code WXX (Weather ? Uncontrollable) BUT coding under review (00 / IU Under Investigation logged) ? controllability disputed ? cannot decide
Result for each passenger: NO_DETERMINATION | FD-APPR-ND-xx | reason "Controllability under determination" | CAD 0
And DDS does NOT return FD-APPR-NE-28 (uncontrollable Not Eligible)

TRIP TRACER UI VALIDATION (PNR UD002):
? Promised Itinerary: AC 305 YUL ? YVR, 08:00 ? 10:30
? Current Itinerary: AC 305 CANCELLED (INVOL); AC 311 YUL ? YVR, arrived 17:30
? Delay: +7H 00M
? Regime: APPR (1 regime)
? MSL Flight: AC 305 � YUL ? YVR � Cancellation code WXX "Cancelled due to weather"
? Coding flag: 00 / IU "Under Investigation" (controllability under review)
? Controllability: UNDER DETERMINATION (not Uncontrollable, not Controllable)
? Aeroplan: 9876543210 (Basic Member � linked, claimant)
? MS MARIE-�VE TREMBLAY | NO DETERMINATION | Controllability under determination | CAD 0.00
? MR LUC TREMBLAY | NO DETERMINATION | Controllability under determination | CAD 0.00
NOTE: If the review confirms Weather, both passengers become Not Eligible. If it changes the cause to controllable, APPR 6 to under 9 hrs applies (CAD 700 each).

FRAUD SCREENING � NOT TRIGGERED:
CyberSource runs only for ELIGIBLE cases ? NOT invoked

AC WALLET / CASH � NOT TRIGGERED:
No offer, even with Basic Aeroplan linked

NO DETERMINATION RESULT:
Chatbot displays the standard No Determination response:
"Based on the information available, we are unable to determine your eligibility at this time."
"Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available."
"Your claim will be reviewed and we will respond within 30 days."
And the chatbot does NOT say the claim is declined or that weather makes them ineligible
And no compensation amount is shown
And no "Would you like us to proceed?" prompt is shown (case created automatically)
And no payment country, Interac email or other payment details are collected

CASE CREATION (GLOB-09):
Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260814-302." / "Our team will review your case and contact you within 30 days."
And one case is created for both passengers
And the booking record is appended to the case automatically
And the case is routed to the manual review queue

NOTIFICATION (Adobe):
One acknowledgement email sent to m***@gmail.com for the case, containing: Case Reference, both passenger names, AC 305 YUL ? YVR Aug 5, 2026 (cancelled, rebooked, 7h late), the No Determination message, contact information
And the email does NOT mention any compensation amount or a weather decline

END FLOW (GLOB-11):
"Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "Marie-�ve Tremblay" with PNR "UD002" covering 2 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellations"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "Forwarded � Manual Review"
And the Created and Last Updated dates should be populated
And the SLA countdown should track the 30-day response commitment
And the Team assignment should be the manual review team
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Claimant should be "Marie-�ve Tremblay", Adult, Authentication "Pass"
And the PNR should be "UD002" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the passengers should be listed as Marie-�ve Tremblay (Adult, Claimant, Aeroplan 9876543210, Basic / Member) and Luc Tremblay (Adult)
And the Email should be "m***@gmail.com" and the Address populated
And the Journey should show "Bound 1: YUL ? YVR" with AC 305 Cancelled (MSL) and AC 311 as the rebooked flight (+7H 00M)
And the Disruption Code should show "WXX � Weather" with the "Under Investigation / under review" flag
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "NO DETERMINATION � Controllability under determination � CAD 0" for each passenger
And no Cash or AC Wallet offer should be recorded
And DDS should have run automatically with no agent action
And Decision Assist should show "No Determination" and should not show "Not Eligible" or "Eligible"
And the Duplicate Check should show "No duplicate found" for both passengers using baseline "Marie-�ve Tremblay + UD002 + YUL?YVR + FD"
And the CyberSource result should be "Not triggered"
And the IDV status should be "Not triggered"
And the Trip Tracer poll should NOT be required
And Customer Communications should show one acknowledgement email with no compensation amount
And the chatbot transcript should be linked
And the Audit Log should record DDS result, case creation, routing and notification with timestamps
And the Attachments tab should be empty
And the agent should not edit the flight code and should request a coding review, then re-run Decision Assist once the review is complete
And the agent should be able to record a manual decision per passenger (Eligible or Not Eligible) after the review
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS outcome is "NO DETERMINATION" for both passengers because controllability is under determination
Then no payment country should be collected
And no Cash or AC Wallet option should be offered
And no Interac email, bank or card details should be collected
And Persona IDV for payout should not be triggered
And no payment record should be created for either passenger
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier or EIP
And the Compensation tab should show no payout (CAD 0 per passenger, CAD 0 total)
And if manual review later finds the claim eligible, payment should follow the Canada resident path (Interac, email only) or AC Wallet if selected, with a separate payment record per passenger

Expected Results:
DDS returns NO DETERMINATION (FD-APPR-ND-xx, controllability under determination) for both passengers, CAD 0. It does not return FD-APPR-NE-28. Trip Tracer shows the MSL as AC 305 cancelled with WXX Weather plus an under-review flag, rebooked on AC 311, +7H 00M. The chatbot shows the standard No Determination message, with no decline and no amount, and creates one case automatically. The case is Forwarded � Manual Review with a 30-day SLA. No CyberSource check, offer, IDV, payment details or payment records.