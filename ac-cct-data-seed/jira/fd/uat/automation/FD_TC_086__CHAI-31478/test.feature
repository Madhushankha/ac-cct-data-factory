Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was delayed by 7 hours because the captain ordered a security check of the aircraft, so I decided not to continue my trip and stayed in Toronto. Can I get compensation?"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds: "Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Jacques Fortier"
Then the chatbot responds: "Thanks, Jacques! And, what is your booking reference number?"
And the user provides "PNR: TC073"
Then the chatbot searches Trip Tracer for PNR: TC073
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: j***@gmail.com | Phone: +1***901
And the user selects "Email: j***@gmail.com"
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
And the chatbot displays: "I found 1 passenger on this booking: Jacques Fortier (Adult). Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
  "I found the following journey:
   Segment 1: Flight AC 476, Montreal (YUL) ? Toronto (YYZ), June 1, 2026 � COMPLETED
   Segment 2: Flight AC 477, Toronto (YYZ) ? Vancouver (YVR), June 1, 2026 � DELAYED
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 DELAYED
Then the chatbot determines: Claim applies to Segment 2 (AC 477 YYZ?YVR � DELAYED)

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of the delayed segment
And the system calculates: Scheduled departure June 1, 2026; current date June 15, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 1, 2026; filing June 15, 2026 ? 14 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS identifies MSL = Leg 2 (AC 477 YYZ?YVR)
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? NOT AVAILABLE
And DDS falls back to the first departure delay code on MSL ? 69 (FB)
And DDS finds a single delay code on MSL ? Multiple Root Cause Analysis NOT required
And DDS calculates delay = 420 min ? delay band 6�9 hours
And DDS detects travel outcome: Incomplete (customer at mid-point YYZ, no landing at destination YVR)
And DDS classifies 69 (FB) as SAFETY under APPR (within carrier's control but required for safety)
And DDS does NOT apply the CAD 700 6�9 hour compensation tier because Safety is not compensable
And DDS reads Aeroplan tier code A (Aeroplan Basic) ? tier-based expense rule NOT applied (rule applies to uncontrollable disruptions only)
And DDS evaluates and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC073
? Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED (on time, no delay codes)
? Segment 2: Flight: AC 477, Route: YYZ ? YVR, Scheduled: 12:00 ? 14:05, Actual: 19:00 ? 21:05, Status: DELAYED (operated) (claim filed)
? Segment 2 departure delay = 420 min ; arrival delay = 420 min ? band 6�9 hours
? Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at mid-point YYZ, Leg 2 coupon not flown, no landing at YVR)
? History - No rebooking accepted for connecting segment
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 477 � YYZ ? YVR (Leg 2)
? Cancellation code: NONE
? First arrival delay code: NOT AVAILABLE (null/empty)
? First departure delay code: 69 (FB) � "Captain request for security check, extraordinary"
? No additional delay codes on MSL
? Controllability source = first departure delay code (fallback)
? Fallback: TRUE (arrival delay code not available)
? APPR causal category: Within carrier control � For Safety ? SAFETY
? Disruption Type: DELAY (mid-journey)
? No Travel Branch B (Did not remain at origin � intermediate travel) + MSL delayed 3+ hours ? controllability check ? Required for Safety
? Aeroplan: LINKED | Tier code A | Aeroplan Basic
? DDS outcome code: FD-APPR-NE-19
? Compensation outcome: NOT ELIGIBLE (no cash compensation, CAD 700 6�9h tier overridden)
? Ticket refund entitlement: PRO-RATED / FULL refund of unused portion (Branch B � Safety)
? Expenses: APPLICABLE under Standard of Care (none claimed in this test)
Flight Compensation:
? MR JACQUES FORTIER | NOT ELIGIBLE | SAFETY | CAD 0.00

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
  "I've reviewed the details of your flight. I understand your connecting flight AC 477 from Toronto (YYZ) to Vancouver (YVR) on June 1, 2026 was delayed by more than 6 hours and you decided not to continue your trip. However, you are not eligible for compensation for this delay. After a full review, we can confirm that the delay was caused by an extraordinary security check of the aircraft requested by the captain, which had to be completed before your flight could safely depart. Disruptions required for safety purposes aren't eligible for compensation under the compensation regulations APPR. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)

CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And a Not Eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (required for safety � captain request for extraordinary security check, departure delay code 69), travel status (No Travel - Incomplete), regulation reference (APPR), contact information

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "Jacques Fortier" with PNR "TC073"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "Closed � Not Eligible"
  And the Created date should be populated
  And the Last Updated date should be populated
  And the SLA countdown should be tracking correctly
  And the Team assignment should be correct
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Decision Assist panel should NOT be greyed out
  And the Claimant Name should be "Jacques Fortier"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC073"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "Jacques Fortier"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "j***@gmail.com"
  And the Phone should be "+1***901"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "Linked" with the Aeroplan number masked
  And the Tier Status should be "Aeroplan Basic" (tier code A)
  And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "NOT ELIGIBLE" with reason "Required for Safety � captain request for extraordinary security check (Departure Code 69, fallback)"
  And the delay should show 420 minutes (6�9 hour band)
  And the travel status should show "No Travel � Incomplete" with stranded location "YYZ"
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically
  And the DDS outcome should be "FD-APPR-NE-19"
  And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety departure delay Code 69 (FB � captain request for extraordinary security check) used as fallback because no arrival delay code was available
  And the eligibility decision should NOT show a CAD 700 compensation amount for the 6�9 hour band
  And the eligibility decision should NOT reference the Aeroplan Basic tier as a reason
  And the Duplicate Check should have run automatically using baseline data "Jacques Fortier + TC073 + YYZ?YVR + FD"
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
  Given the eligibility result is "NOT ELIGIBLE" due to Safety fallback departure delay code 69 (FB � captain request for extraordinary security check)
  And the delay is in the 6�9 hour band
  Then no payment flow should be triggered
  And no country of residence should have been asked
  And no Interac email should have been collected
  And no compensation record should have been created
  And no CAD 700 tier amount should have been calculated or stored
  And no AC Wallet or Aeroplan-related credit should have been issued
  And no batch file should have been dispatched
  And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results: DDS returns FD-APPR-NE-19. Seg 1 AC 476 YUL?YYZ Completed. Seg 2 AC 477 YYZ?YVR DELAYED (420 min, 6�9h band). Cancellation code = NONE. Arrival delay code = NOT AVAILABLE. Departure delay code = 69 (FB, captain request for extraordinary security check) used as fallback, Fallback = TRUE, single code on MSL. MSL = Leg 2. No Travel = TRUE, Status = Incomplete (at mid-point YYZ, no landing at YVR). Controllability: 69 = Within carrier control � For Safety, so no cash compensation and the CAD 700 6�9h tier is overridden. Outcome: refund of unused portion + Standard of Care expenses (none claimed), CAD 0.00 cash. Aeroplan Basic (tier A) is shown but doesn't affect the outcome. Fraud: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A. APPR = NE-19; EU = N/A; ASL = N/A.