GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My connecting flight from Toronto to Quebec City was delayed about 7 hours. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot shows the automated decision-making disclaimer ? user agrees to start

IDENTIFICATION (GenUC-01):
User provides "Gabriel Morin" and PNR "UC002" ? Trip Tracer PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
User selects Email g***@gmail.com ? OTP "704318" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Group booking identifier = NOT PRESENT
"I found 1 passenger on this booking: Gabriel Morin (Adult - Aeroplan Member). Is this who you'd like to include?" ? "Yes" ? PAX count 1 ? PROCEED

JOURNEY SELECTION (GenUC-08):
Chatbot displays: Journey YUL ? YQB, Jul 20, 2026, via YYZ (AC 412, AC 7650), Arrival Delay 7 hours ? user "Yes"

SEGMENT CHECK:
More than 1 segment ? YES (2 legs) ? segment handling (GenUC-18) runs; journey confirmed as one bound

DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS:
Duplicate check ? none
72-hour check ? more than 72 hours ? PROCEED
APPR limit ? 8 days (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Gate 1: not employee, not infant ? PROCEED
Gate 2: promised = actual routing (no VOL / INVOL)
Gate 3: travelled to final destination (YQB)
Gate 4: MSL = Leg 2 AC 7650 YYZ ? YQB
Gate 5: operating carrier on MSL = null ? not AC / AC family, not STAR, not OAL ? CARRIER UNKNOWN
DDS cannot apply carrier rules or controllability ? NO DETERMINATION
Result: MR GABRIEL MORIN | NO_DETERMINATION | FD-APPR-ND-xx | reason "Carrier at fault unknown" | CAD 0

TRIP TRACER UI VALIDATION (PNR UC002):
? Promised Itinerary: AC 412 YUL ? YYZ (10:00) + AC 7650 YYZ ? YQB (14:00)
? Current Itinerary: Leg 1 on time; Leg 2 ARRIVED LATE, 14:00 ? 21:00, +7H 00M
? Regime: APPR (1 regime)
? MSL Flight: AC 7650 � YYZ ? YQB
? MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false
? Delay: +7H 00M � controllability not decided
? Aeroplan: 9876543210 (Basic Member � linked)
? MR GABRIEL MORIN | NO DETERMINATION | Carrier unknown | CAD 0.00
NOTE: The 7h delay is visible. If manual review confirms the carrier is AC or AC family and the code is controllable, APPR 6 to under 9 hrs (CAD 700 / CAD 840 AC Wallet) would apply. It's on hold until then.

FRAUD SCREENING � NOT TRIGGERED:
CyberSource runs only for ELIGIBLE cases ? NOT invoked

AC WALLET CHECK � NOT TRIGGERED:
AC Wallet / Cash offer only for ELIGIBLE cases ? NOT offered, even with Basic Aeroplan linked

NO DETERMINATION RESULT:
Chatbot displays the standard No Determination response:
"Based on the information available, we are unable to determine your eligibility at this time."
"Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available."
"Your claim will be reviewed and we will respond within 30 days."
And no compensation amount is shown
And no "Would you like us to proceed?" prompt is shown (case created automatically)
And no payment country, Interac email or other payment details are collected

CASE CREATION (GLOB-09):
Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260728-202." / "Our team will review your case and contact you within 30 days."
And the booking record is appended to the case automatically
And the case is routed to the manual review queue

NOTIFICATION (Adobe):
Case acknowledgement email sent to g***@gmail.com with: Case Reference, journey YUL ? YQB Jul 20, 2026 (delayed 7h), the No Determination message, contact information
And the email does NOT mention any compensation amount

END FLOW (GLOB-11):
"Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "Gabriel Morin" with PNR "UC002"
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "Forwarded � Manual Review"
And the Created and Last Updated dates should be populated
And the SLA countdown should track the 30-day response commitment
And the Team assignment should be the manual review team
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Claimant should be "Gabriel Morin", Adult, Authentication "Pass"
And the PNR should be "UC002" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Tags should include "Claimant" and "Adult"
And the Email should be "g***@gmail.com" and the Address populated
And the Aeroplan should be "9876543210", Tier "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ ? YQB" with Leg 2 AC 7650 as the MSL (+7H 00M)
And the MSL operating carrier should show "Unknown" (not AC, STAR or OAL)
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "NO DETERMINATION � Carrier at fault unknown � CAD 0"
And no Cash or AC Wallet offer should be recorded
And DDS should have run automatically with no agent action
And Decision Assist should show "No Determination" with the carrier reason, and should not show an Eligible or Not Eligible recommendation
And the Duplicate Check should show "No duplicate found" using baseline "Gabriel Morin + UC002 + YUL?YQB + FD"
And the CyberSource result should be "Not triggered"
And the IDV status should be "Not triggered"
And the Trip Tracer poll should NOT be required
And the acknowledgement email should be shown in Customer Communications with no compensation amount
And the chatbot transcript should be linked
And the Audit Log should record DDS result, case creation, routing and notification with timestamps
And the Attachments tab should be empty
And the agent should be able to investigate the operating carrier and record a manual decision (Eligible, Not Eligible or refer)
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS outcome is "NO DETERMINATION" because the carrier at fault is unknown
Then no payment country should be collected
And no Cash or AC Wallet option should be offered
And no Interac email, bank or card details should be collected
And Persona IDV for payout should not be triggered
And no compensation record should be created
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier or EIP
And the Compensation tab should show no payout (CAD 0)
And if manual review later finds the claim eligible, payment should follow the Canada resident path (Interac, email only) or AC Wallet if selected

Expected Results:
DDS returns NO DETERMINATION (FD-APPR-ND-xx, carrier unknown) for the single passenger, CAD 0. Trip Tracer shows MSL Leg 2 AC 7650 YYZ ? YQB, +7H 00M, operating carrier Unknown. The chatbot shows the standard No Determination message and creates the case automatically. The case is Forwarded � Manual Review with a 30-day SLA. No CyberSource check, AC Wallet or Cash offer, IDV, payment details or compensation record.