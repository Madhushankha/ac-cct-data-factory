Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed about 7 hours and I never got any clear explanation from Air Canada. I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "V�ronique Caron"
Then the chatbot responds:
"Thanks, V�ronique! And, what is your booking reference number?"
And the user provides "PNR: TC057"
Then the chatbot searches Trip Tracer for PNR: TC057
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: v***@outlook.com
� Phone: +1***789
And the user selects "Email: v***@outlook.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629481"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection

PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� V�ronique Caron (Adult - Aeroplan Member)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 372
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 18, 2026
� Status: ARRIVED LATE
� Arrival Delay: 7 hours (observed in flight status � disruption code logged but unrecognized)
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 18, 2026; current date is June 10, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 18, 2026; filing June 10, 2026 ? 23 days ? within 366 days ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC057
? Promised Itinerary - Flight: AC 372, Route: YUL ? YYZ, Scheduled Arrival: 14:00
? Current Itinerary - Flight: AC 372, Route: YUL ? YYZ, Status: ARRIVED LATE, Actual Arrival: 21:00, Delay: +7H 00M (6�<9h band observed in ADS/AODB)
? Disruption Code: UNKNOWN (code IS logged in system but is not recognized / not mapped in DDS classification table)
? Departure Code: N/A
? Cancellation Code: N/A (flight operated � not cancelled)
? Aeroplan: 9876543210 (Basic Member � linked)
? DDS Gate 6: Is disruption code available?
  Code IS present ? YES
? DDS Gate 6a: Is disruption code RECOGNIZED / MAPPED?
  Code type = UNKNOWN ? NOT recognized in DDS classification table
  Cannot determine Controllable / Uncontrollable ? NO DETERMINATION
? DDS determines: FD-APPR-ND-X02 � UNKNOWN CODE ? immediate No Determination (no 14-day polling � code exists)
? 14-day polling: NOT triggered (polling only applies when code is NULL/missing � code IS present here, just unknown)
Flight Compensation:
? MS V�RONIQUE CARON | NO DETERMINATION | UNKNOWN_CODE | CAD 0.00
NOTE: 7h delay (6�<9h band) IS observed � if code is later reclassified as Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply. Currently blocked pending manual review.

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NO DETERMINATION ? CyberSource NOT invoked

AC WALLET CHECK � NOT TRIGGERED:
Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases
And this case is NO DETERMINATION ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210)

NO DETERMINATION RESULT � UNKNOWN CODE (FD-APPR-ND-X02):
Then the chatbot displays the standardized FD-APPR-ND-X02 response:
"Based on the information available, we are unable to determine your eligibility at this time."
"Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available."
"Your claim will be reviewed and we will respond within 30 days."
NOTE: No confirmation prompt is displayed � case is created automatically after this message. No "Would you like us to proceed?" step.

NO MANUAL HANDLING PROMPT (skipped � FD-APPR-ND-X02 flows directly to case creation):
Then the system proceeds immediately to CASE CREATION without collecting preferred email or country from the customer
NOTE: This is distinct from FD-APPR-ND-04 which includes manual handling flow (GenUC-27). FD-APPR-ND-X02 creates the case automatically after the ND message.

CASE CREATION (GLOB-09):
Then the chatbot creates the case and responds:
"Your claim has been submitted. Case Reference: CASE-FD-20260610-054."
"Our team will review your case and contact you within 30 days."
And the system appends the booking record to the case automatically
And the case is routed to the agent queue for manual investigation

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a case acknowledgement email is sent to v***@outlook.com
And the email contains:
� Case Reference: CASE-FD-20260610-054
� Flight details: AC 372 YUL?YYZ, May 18, 2026, delayed 7h
� Message: "Based on the information available, we are unable to determine your eligibility at this time. Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available. Your claim will be reviewed and we will respond within 30 days."
� Contact information
NOTE: Email does NOT reference potential compensation amount as no eligibility determination has been made

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
  Given the case has been created for claimant "V�ronique Caron" with PNR "TC057"
  Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
  And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
  And the Case Status should be "Forwarded � Manual Review"
  And the Created date and Last Updated date should be populated
  And the SLA countdown should be tracking against the 30-day response commitment
  And the Team assignment should be "Customer Relations (Manual Review)"
  And no banners should be displayed for identified and authenticated Auth Flow 1 user
  And the Claimant Name should be "V�ronique Caron"
  And the Claimant Type should be "Adult"
  And the Authentication should be "Pass"
  And the PNR should be "TC057"
  And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
  And the Regime should be "APPR"
  And the Full Name should be "V�ronique Caron"
  And the Tags should include "Claimant" and "Adult"
  And the Email should be "v***@outlook.com"
  And the Phone should be "+1***789"
  And the Address and Profile ID should be populated
  And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
  And the Tier Status should be "Basic / Member"
  And the Journey should show "Bound 1: YUL ? YYZ" (AC 372, 14:00 ? 21:00, +7H 00M) with claim filed for this flight
  And the Disruption Code should show "UNKNOWN � not mapped in DDS"
  And the Ancillary Fee section should be present with no expected ancillary fees
  And the Eligibility and Compensation section should show "NO DETERMINATION � Unknown disruption code � CAD 0"
  And no CAD 700 Cash or CAD 840 AC Wallet amount should be shown or stored
  And the Decision Assist Panel should auto-appear for FD topic
  And DDS should have run automatically with no agent action needed
  And the DDS outcome should be "FD-APPR-ND-X02"
  And the Decision Assist Panel should show the observed delay (7h, 6 to <9h band) for agent reference
  And the Decision Assist Panel should allow the agent to record a manual eligibility decision
  And the case should NOT show a 14-day polling status or System Processing Queue entry
  And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + YUL?YYZ + FD"
  And the result should be "No duplicate found"
  And no Duplicate Warning Banner should be displayed
  And the Related Cases tab should show no related cases
  And the CyberSource result should be "Not triggered"
  And the Persona IDV status should be "Not triggered"
  And the system should have appended the booking record automatically for identified and authenticated user
  And Trip Tracer poll should NOT be required
  And the case should be available in the manual review queue for an agent to pull from My Activities
  And a case acknowledgement email should have been sent via Adobe to "v***@outlook.com"
  And the acknowledgement email should not contain any compensation amount
  And the Agent Notes section should be accessible
  And the Audit Log should record DDS returning FD-APPR-ND-X02, automatic case creation and routing to manual review, with timestamps
  And the Audit Log should record all actions with timestamps and before/after values
  And Customer Communications should show the acknowledgement email chronologically
  And the chatbot transcript should be accessible and linked to the case
  And the chatbot transcript should show no confirmation prompt and no email or country collection after the ND-X02 message
  And the Attachments tab should be empty
  And the case should remain open (NOT Resolved and NOT read-only) pending the agent's manual decision
  And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
  Given the DDS outcome is "FD-APPR-ND-X02" (No Determination � Unknown Code)
  Then no payment flow should be triggered
  And no country of residence should have been asked
  And no Cash offer should have been displayed
  And no AC Wallet offer should have been displayed despite Basic Aeroplan "9876543210" being linked
  And no Interac email, banking or card details should have been collected
  And Persona IDV should NOT have been triggered
  And no compensation record should have been created
  And no CAD 700 or CAD 840 amount should have been calculated or stored
  And no record should be picked up by the daily evening batch file
  And nothing should be dispatched to Unifier or EIP
  And the Claims Dashboard Compensation tab should show no payout and no payment instruction

Expected Results: DDS returns FD-APPR-ND-X02 straight away. Trip Tracer: Promise = 14:00, Actual = 21:00, Delay = 7 hours (6 to under 9 hour band), MSL = Leg 1 (AC 372), no cancellation code, disruption code UNKNOWN (present but not mapped), Gate 9 classification = none, Fallback = not applicable, 14-day polling not triggered, APPR. Compensation: CAD 0. The chatbot shows the standard ND-X02 message, asks for no confirmation, and creates the case for manual review with a 30-day commitment. CyberSource, Persona, Cash, AC Wallet and payment are all not triggered. Claims Dashboard: Forwarded � Manual Review, ND-X02, the case stays open for the agent's decision.