Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed by more than 4 hours because of a technical problem with the aircraft, so I decided not to travel and stayed in Montreal. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "�mile Gagnon"
Then the chatbot responds: "Thanks, �mile! And, what is your booking reference number?"
And the user provides "PNR: TC066"
Then the chatbot searches Trip Tracer for PNR: TC066
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: e***@gmail.com | Phone: +1***567
And the user selects "Email: e***@gmail.com"
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
And the chatbot displays: "I found 1 passenger on this booking: �mile Gagnon (Adult). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Flight: AC 470
   Route: Montreal (YUL) ? Toronto (YYZ)
   Date: May 31, 2026
   Status: DELAYED
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the system calculates: Scheduled departure May 31, 2026; current date June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 31, 2026; filing June 15, 2026 ? 15 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? 41 (TD)
And DDS uses the arrival delay code for controllability (no fallback needed)
And DDS finds a single delay code on MSL ? Multiple Root Cause Analysis NOT required
And DDS classifies 41 (TD) as SAFETY under APPR (within carrier's control but required for safety)
And DDS reads Aeroplan tier code A (Aeroplan Basic) ? tier-based expense rule NOT applied (rule applies to uncontrollable disruptions only)
And DDS evaluates and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC066
? Promised Itinerary - Flight: AC 470, Route: YUL ? YYZ, Date: May 31, 2026, Scheduled Departure: 10:00, Scheduled Arrival: 12:00
? Actual Itinerary - Flight: AC 470, Route: YUL ? YYZ, Actual Departure: 14:15, Actual Arrival: 16:20, Status: DELAYED (operated)
? Departure delay = 255 min (?180) ; Arrival delay = 260 min (?180)
? Customer Status: NO TRAVEL - ORIGIN (not boarded, coupon not flown, remained at YUL)
? History - No rebooking accepted
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 470 � YUL ? YYZ (only segment)
? Cancellation code: NONE
? First arrival delay code: 41 (TD) � "Aircraft defects"
? First departure delay code: 41 (TD)
? No additional delay codes on MSL
? Controllability source = first arrival delay code (no cancellation code)
? Fallback: FALSE (arrival delay code available)
? APPR causal category: Within carrier control � For Safety ? SAFETY
? Disruption Type: DELAY
? No Travel Branch A (Remained at Origin) + MSL delayed 3+ hours ? controllability check ? Safety
? Aeroplan: LINKED | Tier code A | Aeroplan Basic
? DDS outcome code: FD-APPR-NE-14
? Compensation outcome: NOT ELIGIBLE (no cash compensation)
? Ticket refund entitlement: FULL refund (Branch A � Safety)
? Expenses: APPLICABLE under Branch A � Safety (none claimed in this test)
Flight Compensation:
? MR �MILE GAGNON | NOT ELIGIBLE | SAFETY | CAD 0.00

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
  "I've reviewed the details of your flight. I understand your flight AC 470 from Montreal (YUL) to Toronto (YYZ) on May 31, 2026 was delayed by more than 3 hours and you decided not to travel. However, you are not eligible for compensation for this delay. After a full review, we can confirm that the delay was caused by a technical issue with the aircraft that had to be repaired before the flight could safely depart. Disruptions required for safety purposes aren't eligible for compensation under the compensation regulations APPR. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And a Not Eligible notification email is sent to e***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (safety � aircraft defects, arrival delay code 41), travel status (No Travel - Origin), regulation reference (APPR), contact information

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "�mile Gagnon" with PNR "TC066"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "Closed � Not Eligible"
  And the Created date should be populated
  And the Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "�mile Gagnon"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC066"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "�mile Gagnon"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "e***@gmail.com"
  And the Phone should be "+1***567"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "Linked" with the Aeroplan number masked
  And the Tier Status should be "Aeroplan Basic" (tier code A)
  And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Safety � aircraft defects (Arrival Code 41)"
  And the travel status should show "No Travel � Origin"
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically
  And the DDS outcome should be "FD-APPR-NE-14"
  And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety arrival delay Code 41 (TD � aircraft defects)
  And the eligibility decision should NOT reference the Aeroplan Basic tier as a reason
  And the Duplicate Check should have run automatically using baseline data "�mile Gagnon + TC066 + YUL?YYZ + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And CyberSource should NOT have been triggered as it only runs for eligible cases
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

PAYMENT VALIDATION
  Given the eligibility result is "NOT ELIGIBLE" due to Safety arrival delay code 41 (TD � aircraft defects)
  Then no payment flow should be triggered
  And no country of residence should have been asked
  And no Interac email should have been collected
  And no compensation record should have been created
  And no AC Wallet or Aeroplan-related credit should have been issued
  And no batch file should have been dispatched
  And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results: DDS returns FD-APPR-NE-14. AC 470 YUL?YYZ DELAYED (departure 255 min late, arrival 260 min late). Cancellation code = NONE. Arrival delay code = 41 (TD, aircraft defects), Fallback = FALSE, single code on MSL. MSL = Leg 1. No Travel = TRUE, Status = Origin. Controllability: 41 = Within carrier control � For Safety, so no cash compensation. Branch A + Safety entitlement: expenses (none claimed) + full ticket refund, CAD 0.00 cash compensation. Aeroplan Basic (tier A) is shown but doesn't affect the outcome. Fraud: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A.