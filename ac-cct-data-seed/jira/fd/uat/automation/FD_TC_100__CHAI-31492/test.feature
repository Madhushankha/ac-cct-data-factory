GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight from London to Montreal was delayed about 5 hours and I never got any clear explanation from Air Canada. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "V�ronique Caron"
Then the chatbot responds: "Thanks, V�ronique! And, what is your booking reference number?"
And the user provides "PNR: TC057"
Then the chatbot searches Trip Tracer for PNR: TC057
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: v***@outlook.com
* Phone: +1789
And the user selects "Email: v@outlook.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629481"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
* V�ronique Caron (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? 9 or fewer ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 865
* Route: London Heathrow (LHR) ? Montreal (YUL)
* Date: May 18, 2026
* Status: ARRIVED LATE
* Arrival Delay: 5 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival May 18, 2026; current date June 10, 2026 ? more than 72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Departure country = United Kingdom ? filing deadline = 2190 days (6 years)
And the system calculates: Disruption May 18, 2026; filing June 10, 2026 ? 23 days ? within 2190 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS evaluates and sends to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC057
? Promised Itinerary - Flight: AC 865, Route: LHR ? YUL, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 865, Route: LHR ? YUL, Status: ARRIVED LATE, Actual Arrival: 19:00, Delay: +5H 00M (4+ hours band seen in ADS/AODB)
? Regime: EU (UK) + APPR (2 regimes)
? Disruption Code: UNKNOWN (logged but not mapped in the DDS controllability table)
? Departure Code: N/A
? Cancellation Code: N/A (flight operated)
? Aeroplan: 9876543210 (Basic Member � linked)
? DDS Gate: Is disruption code available? ? YES (code present)
? DDS Gate: Is disruption code recognized / mapped? ? NO
  EU/UK controllability (Controllable / Uncontrollable) ? cannot be decided
  APPR controllability ? cannot be decided
? DDS decides: No Determination � UNKNOWN CODE ? straight away (no 14-day re-check)
? 14-day re-check: NOT triggered (it only applies when the code is NULL/missing)
Flight Compensation:
? MS V�RONIQUE CARON | NO DETERMINATION | UNKNOWN_CODE | GBP 0.00 (EU/UK) | CAD 0.00 (APPR)
NOTE: The 5h delay (4+ hours band) is visible. If the code is later found to be Controllable, the UK 4+ hours amount (GBP 520 Cash / GBP 624 AC Wallet) would apply as the most generous regime. For now it is on hold until manual review.

FRAUD SCREENING � NOT TRIGGERED:
Then CyberSource is called ONLY for ELIGIBLE cases
And this case is NO DETERMINATION ? CyberSource NOT invoked

AC WALLET CHECK � NOT TRIGGERED:
Then the AC Wallet offer appears ONLY for ELIGIBLE cases
And this case is NO DETERMINATION ? AC Wallet NOT offered, even with Basic Aeroplan linked (9876543210)

NO DETERMINATION RESULT � UNKNOWN CODE (ND-X02):
Then the chatbot displays the standard ND-X02 response:
"Based on the information available, we are unable to determine your eligibility at this time."
"Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available."
"Your claim will be reviewed and we will respond within 30 days."
NOTE: No confirmation prompt is shown. The case is created automatically after this message, with no "Would you like us to proceed?" step.

NO MANUAL HANDLING PROMPT (skipped):
Then the system goes straight to CASE CREATION without asking the customer for a preferred email or country
And no payment country, Interac email or other payment details are collected

CASE CREATION (GLOB-09):
Then the chatbot creates the case and responds:
"Your claim has been submitted. Case Reference: CASE-FD-20260610-054."
"Our team will review your case and contact you within 30 days."
And the system appends the booking record to the case automatically
And the case is routed to the agent queue for manual investigation

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And a case acknowledgement email is sent to v***@outlook.com
And the email contains:
* Case Reference: CASE-FD-20260610-054
* Flight details: AC 865 LHR ? YUL, May 18, 2026, delayed 5h
* Message: "Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available. Your claim will be reviewed and we will respond within 30 days."
* Contact information
NOTE: The email does NOT mention any possible compensation amount (GBP or CAD)

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything I can help you with?"
* I would like you to � new flow
* No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "V�ronique Caron" with PNR "TC057"
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "Forwarded � Manual Review"
And the Created date should be populated
And the Last Updated date should be populated
And the SLA countdown should be tracking correctly (30-day response commitment)
And the Team assignment should be "Customer Relations (Manual Review)"
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel may be restricted as it is pending manual review
And the Claimant Name should be "V�ronique Caron"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC057"
And the PNR Creation Date should be populated
And the Journey ID should be populated
And the Booking Source should be populated
And the Booking Office ID should be populated
And the Regime should be "EU (UK)" with APPR also listed as applicable
And the Full Name should be "V�ronique Caron"
And the Tags should include "Claimant" and "Adult"
And the Email should be "v***@outlook.com"
And the Phone should be "+1***789"
And the Address should be populated
And the Aeroplan should be "9876543210" linked (Basic Member in good standing)
And the Tier Status should be "Basic / Member"
And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight
And the Disruption Code should show "UNKNOWN (not mapped)"
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "NO DETERMINATION � Unknown disruption code � GBP 0 / CAD 0"
And no Cash or AC Wallet offer should be recorded
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "NO DETERMINATION" (EU/UK and APPR, unknown code)
And no 14-day re-check job should exist for this case
And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + LHR?YUL + FD"
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "Not triggered"
And the IDV status should be "Not triggered"
And the system should have appended the booking record automatically
And Trip Tracer poll should NOT be required
And a case acknowledgement email should have been sent via Adobe without any compensation amount
And the Agent Notes section should be accessible
And the Audit Log should record all actions with timestamps and before/after values
And Customer Communications should show the acknowledgement email chronologically
And the chatbot transcript should be accessible and linked to the case
And the Attachments tab should be empty
And the agent should be able to record a manual decision after investigating the code
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS outcome is "NO DETERMINATION" for claimant "V�ronique Caron"
Then no payment country should be collected
And no Cash or AC Wallet option should be offered
And no Interac email, banking or card details should be collected
And no compensation record should be created
And no record should be picked up by the daily evening batch file
And nothing should be dispatched to Unifier or EIP
And the Claims Dashboard Compensation tab should show no payout (GBP 0 / CAD 0, no payment instruction)
And if manual review later decides the claim is eligible, payment should follow the normal Canada resident path (Interac, email only) or AC Wallet

Expected Results:
DDS returns No Determination (ND-X02, unknown code) for a UK departure. Trip Tracer: Promise = 14:00; Actual = 19:00; Delay = 5hrs (4+ hours band); MSL = Leg 1 (AC 865 LHR ? YUL); Code UNKNOWN; Regimes = EU (UK) + APPR. No 14-day re-check. Compensation GBP 0 / CAD 0 while waiting. No CyberSource, IDV, AC Wallet or payment. Case created automatically ? Forwarded � Manual Review, 30-day SLA.