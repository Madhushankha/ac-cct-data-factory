GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "Our flight from London to Montreal was delayed about 2 and a half hours, I'd like to check if my family and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Catherine Bouchard"
Then the chatbot responds: "Thanks, Catherine! And, what is your booking reference number?"
And the user provides "TC003"
Then the chatbot searches Trip Tracer for PNR: TC003
And Trip Tracer returns: PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: c***@gmail.com
* Phone: +1567
And the user selects "Email: c@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides OTP code "591837"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR TC003:
"I found 3 passengers on this booking:
1. Catherine Bouchard (Adult - Aeroplan Member)
2. Alexandre Bouchard (Adult)
3. Sophie Bouchard (Child)
Would you like to include all passengers in this claim?"
And the user confirms "Yes, include all 3 passengers"
Then the chatbot checks: PAX count on PNR = 3 ? 9 or fewer ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 865
* Route: London Heathrow (LHR) ? Montreal (YUL)
* Date: January 15, 2026
* Arrival Delay: 2 hours 30 minutes
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers
Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours ? PROCEED
Then the chatbot checks filing deadline: UK departure ? 2190 days; 13 days elapsed ? PROCEED

TRIAGE & DDS EVALUATION:
Backend DDS executes evaluation for PNR TC003:
� Journey origin: LHR (United Kingdom) ? UK regime applicable
� Arrival in Canada ? APPR also applicable
� Delay reason: Code 68 (Controllable)
� Delay duration: 150 min ? below the 180 min minimum for both UK and APPR
� UK entitlement: GBP 0 | APPR entitlement: CAD 0
� Eligibility: NOT ELIGIBLE for all 3 passengers (reason: arrival delay under 3 hours)

TRIP TRACER UI VALIDATION:
The tester opens Trip Tracer UI for PNR: TC003
[x] Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00
[x] Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 16:30, Delay: +2H 30M
[x] Regime: EU (UK) + APPR (2 regimes)
[x] MSL Flight: AC 865 � LHR ? YUL � Code 68 ("Delayed due to flight crew shortage / crew rest requirement")
[x] Delay Classification: +2H 30M � CONTROLLABLE
[x] Aeroplan: 9876543210 (Basic Member � linked)
[x] Flight Compensation Assessment:
  - MS CATHERINE BOUCHARD | NOT ELIGIBLE | Delay under 3 hours | GBP 0.00
  - MR ALEXANDRE BOUCHARD | NOT ELIGIBLE | Delay under 3 hours | GBP 0.00
  - MISS SOPHIE BOUCHARD | NOT ELIGIBLE | Delay under 3 hours | GBP 0.00

NOT ELIGIBLE RESULT � IN-CHAT DECLINE:
Then the chatbot does NOT send the claim to manual review
And the chatbot displays: "I've checked your flight details. Flight AC 865 from London Heathrow (LHR) to Montreal (YUL) arrived about 2 hours and 30 minutes late. Compensation under the UK passenger rights regulations and the Air Passenger Protection Regulations (APPR) applies only when the arrival delay is 3 hours or more, so the passengers on this booking are not eligible for compensation for this delay."
And no compensation amount is quoted (amount = 0)
And no manual-review reference number is given

PAYMENT FLOW SKIPPED:
Then CyberSource fraud screening (GLOB-05) is NOT triggered
And the country of residence question is NOT asked
And no Cash or AC Wallet offer is shown
And no Interac email is requested
And Persona IDV (FD-07b) is NOT triggered

NOTIFICATION & WRAP-UP (GLOB-11):
Then a not-eligible notification email is sent via Adobe to c***@gmail.com containing: Case Reference, outcome (Not Eligible), reason (arrival delay under 3 hours), regulation (UK / EU 261 and APPR), flight details (AC 865 LHR ? YUL)
Then the chatbot offers: "Is there anything I can help you with?"
* I would like you to � new flow
* No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given a case has been created for primary claimant "Catherine Bouchard" with PNR "TC003" covering 3 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "Done"
And the Created date should be populated
And the Last Updated date should be populated
And the SLA countdown should be tracking correctly
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Catherine Bouchard"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC003"
And the PNR Creation Date should be populated
And the Journey ID should be populated
And the Booking Source should be populated
And the Booking Office ID should be populated
And the Regime should be "EU (UK)" with APPR also listed as applicable
And all 3 passengers should be listed (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard)
And the Tags for the claimant should include "Claimant" and "Adult"
And the Email should be "c***@gmail.com"
And the Phone should be "+1***567"
And the Address should be populated
And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
And the Tier Status should be "Basic / Member"
And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "NOT ELIGIBLE � Delay under 3 hours � GBP 0" for all 3 passengers
And no Cash or AC Wallet offer should be recorded
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "NOT ELIGIBLE" (EU/UK and APPR, 2h 30m delay)
And the Duplicate Check should have run automatically using baseline data "Catherine Bouchard + TC003 + LHR?YUL + FD"
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "Not triggered"
And the IDV status should be "Not triggered"
And no manual-review queue item should exist for this case
And the system should have appended the booking record automatically
And Trip Tracer poll should NOT be required
And a not-eligible notification email should have been sent via Adobe
And the Agent Notes section should be accessible
And the Audit Log should record all actions with timestamps and before/after values
And Customer Communications should show the notification email chronologically
And the chatbot transcript should be accessible and linked
And the Attachments tab should be empty
And the Final Status should be "Resolved"
And the case should be in read-only mode with no editable Decision Assist fields
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the claim outcome is "NOT ELIGIBLE" for all 3 passengers
Then no country of residence should be collected for payment
And no Cash or AC Wallet option should be offered
And no Interac email, banking or card details should be collected
And no compensation record should be created
And no record should be picked up by the daily evening batch file
And nothing should be dispatched to Unifier or EIP
And the Claims Dashboard Compensation tab should show no payout (GBP 0 / no payment instruction)

Expected Results:
DDS returns an EU not-eligible response for all 3 pax. Trip Tracer: Promise = 14:00; Actual = 16:30; Delay = 2h 30m; MSL = Leg 1 (AC 865 LHR ? YUL); Code 68 Controllable; Regimes = EU (UK) + APPR. Compensation: GBP 0 (under 3 hours). The bot declines in the chat with the reason, with no manual review, no payment offer, no CyberSource check and no IDV.