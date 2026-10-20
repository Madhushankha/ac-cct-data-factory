Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Vancouver was cancelled because the aircraft was damaged and needed maintenance. I was rebooked and arrived 7 hours late. I am an Elite 35K member and want to check compensation."
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your cancelled flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Richard Clarke"
Then the chatbot responds: "Thanks, Richard! And, what is your booking reference number?"
And the user provides "PNR: TC084"
Then the chatbot searches Trip Tracer for PNR: TC084
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, Aeroplan Elite 35K profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: r***@gmail.com | Phone: +1***678
And the user selects "Email: r***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays: "I found 1 passenger on this booking: Richard Clarke (Adult - Aeroplan Elite 35K). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Original Flight: AC 123 (Cancelled)
   Rebooked Flight: AC 127 (Operated by Air Canada)
   Route: Toronto (YYZ) ? Vancouver (YVR)
   Date: May 26, 2026
   Arrival Delay: 7 hours
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

OPERATING CARRIER CHECK:
Then the system checks the operating carrier on all segments
And the system finds: original AC 123 and rebooked AC 127 are both operated by Air Canada
And the system determines: AC-operated itinerary ? NO OAL redirect ? proceed to DDS

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the system calculates: Arrival May 26, 2026; filing June 5, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 26, 2026; filing June 5, 2026 ? 10 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS identifies MSL = AC 123 YYZ?YVR (cancelled leg)
And DDS checks the cancellation code on MSL ? DAMA (ANA) ? used for controllability (no fallback needed)
And DDS classifies DAMA (ANA) as OUTSIDE CARRIER CONTROL ? UNCONTROLLABLE (aircraft damage by external source)
And DDS detects INVOL rebooking: AC 123 ? AC 127 YYZ?YVR
And DDS calculates delay = 21:00 (actual arrival on AC 127) ? 14:00 (original promise on AC 123) = 7 hours ? band 6 to <9 hours
And DDS does NOT apply the CAD 700 Tier 2 amount because the cause is uncontrollable
And DDS reads Aeroplan Elite 35K status ? recognised, does NOT override the uncontrollable outcome
And DDS returns NOT ELIGIBLE (FD-APPR-NE-TBC) and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC084
? Promised Itinerary - Flight: AC 123, Route: YYZ ? YVR, Scheduled Departure: 09:00, Scheduled Arrival: 14:00 (CANCELLED)
? Current Itinerary - Flight: AC 127, Route: YYZ ? YVR, Status: ARRIVED, Actual Arrival: 21:00
? History - Change 1: INVOL � AC 123 cancelled at D-1 (DAMA � ANA). Customer rebooked onto AC 127 YYZ?YVR
? Operating carrier: Air Canada (AC) on all segments ? OAL redirect NOT applied
? Ticket stock: 014- (AC issued)
? Delay Calculation: 21:00 ? 14:00 = 7 hrs ? DELAY_6_TO_LT_9_HOURS
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 123 � YYZ ? YVR � Cancellation Code: DAMA (ANA) � "Cancelled due to aircraft damage requiring maintenance"
? Fallback: FALSE (cancellation code available)
? APPR causal category: Outside carrier control ? UNCONTROLLABLE
? Aeroplan: 9876543210 (Elite 35K � linked)
? DDS outcome code: FD-APPR-NE-TBC
Flight Compensation:
? MR RICHARD CLARKE | NOT ELIGIBLE | DELAY_6_TO_LT_9_HOURS | UNCONTROLLABLE | CAD 0.00

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
  "I've reviewed the details of your flight. I understand your flight AC 123 from Toronto (YYZ) to Vancouver (YVR) on May 26, 2026 was cancelled and you were rebooked on flight AC 127, arriving about 7 hours after your original scheduled arrival. However, you are not eligible for compensation for this cancellation. After a full review, we can confirm that the aircraft was damaged by an external source and required maintenance before it could safely operate. Situations outside of the airline's control aren't covered under the compensation regulations APPR. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (country of residence, Cash/AC Wallet offer and Interac skipped)
NO IDV (Persona not required for not eligible)
NO OAL REDIRECT and NO MANUAL HANDOFF

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And a Not Eligible notification email is sent to r***@gmail.com
And the email contains: Case Reference, flight details (AC 123 cancelled ? AC 127 YYZ?YVR), not eligible reason (uncontrollable � DAMA (ANA) aircraft damage requiring maintenance), regulation reference (APPR), contact information

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "Richard Clarke" with PNR "TC084"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "Closed � Not Eligible"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Richard Clarke"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC084"
  And the Ticket Stock should be "014-" (Air Canada issued)
  And the Operating Carrier should be "Air Canada (AC)"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "Richard Clarke"
  And the Tags should include "Claimant", "Adult" and "Elite 35K"
  And the Email should be "r***@gmail.com"
  And the Phone should be "+1***678"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "9876543210" linked and in good standing
  And the Tier Status should be "Elite 35K"
  And the Journey should show "Bound 1: YYZ ? YVR" (AC 123 cancelled; rebooked on AC 127) with claim filed for this flight
  And the Disruption Code should show "Cancellation Code DAMA (ANA) � aircraft damage requiring maintenance � Uncontrollable"
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "NOT ELIGIBLE � Uncontrollable (DAMA � ANA) � CAD 0"
  And the delay should show 7 hours (6 to <9 hour band) with no CAD 700 amount
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-APPR-NE-TBC"
  And the eligibility decision should NOT reference OAL redirect or United Airlines
  And the eligibility decision should NOT use the Elite 35K tier as a reason
  And the Duplicate Check should have run automatically using baseline data "Richard Clarke + TC084 + YYZ?YVR + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And CyberSource should NOT have been triggered as it only runs for eligible cases
  And no manual-review queue item should exist for this case
  And the system should have appended the booking record automatically for identified and authenticated user
  And Trip Tracer poll should NOT be required
  And the agent should have used pull case from My Activities
  And the case status should have transitioned from "Assigned" to "In Progress"
  And a case acknowledgement notification should have been sent
  And a not eligible notification email should have been sent via Adobe
  And the Agent Notes section should be accessible
  And the Audit Log should record all actions with timestamps and before/after values
  And Customer Communications should show the not eligible notification email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the Attachments tab should be empty
  And the Final Status should be "Closed � Not Eligible"
  And the case should be in read-only mode with no editable Decision Assist fields
  And the agent should not be able to access Case Search as it is for leads and management only



Expected Results: DDS returns FD-APPR-NE-TBC. Trip Tracer: MSL = Leg 1 (AC 123, cancelled). Operating carrier = Air Canada, so there's no OAL redirect. Cancellation code = DAMA (ANA), uncontrollable, Fallback = FALSE. Scheduled arrival 14:00, actual arrival on AC 127 21:00, delay 7 hours (6 to under 9 hour band). Ticket stock 014-. Aeroplan Elite 35K is recognised, with no effect on the outcome. Compensation: CAD 0. CyberSource: not invoked. IDV: not required. Payment: N/A. Claims Dashboard: Closed � Not Eligible, DAMA (ANA), AC operated.