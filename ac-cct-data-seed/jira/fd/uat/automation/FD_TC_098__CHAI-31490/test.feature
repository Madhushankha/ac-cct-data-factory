Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed about 7 hours and I never got any explanation from Air Canada. I'd like to check if I'm eligible for compensation"
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
� Arrival Delay: 7 hours (observed in flight status � no disruption code logged)
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
? Arrival Code: NULL / MISSING
? Departure Code: NULL / MISSING (no fallback available)
? Cancellation Code: NULL (flight operated � not cancelled)
? Aeroplan: 9876543210 (Basic Member � linked)
? DDS Gate 6: Is disruption code available?
  Arrival code: NULL ? check departure code
  Departure code: NULL ? NO CODE AVAILABLE
? DDS Gate 6.1: Has 14 days elapsed since disruption?
  Disruption date: May 18, 2026
  Current date: June 10, 2026
  Days elapsed: 23 days ? YES, 14+ days elapsed
? Result: NO DETERMINATION � No code available after 14 days ? Manual review required
Flight Compensation:
? MS V�RONIQUE CARON | NO DETERMINATION | NO_CODE_14_DAYS | CAD 0.00
NOTE: 7h delay (6�<9h band) IS observed � if code is later entered and confirmed Controllable, APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply. Currently blocked pending manual review.

FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NO DETERMINATION ? CyberSource NOT invoked

AC WALLET CHECK � NOT TRIGGERED:
Then the chatbot notes: AC Wallet offer is ONLY triggered for ELIGIBLE cases
And this case is NO DETERMINATION ? AC Wallet NOT offered despite Basic Aeroplan linkage (9876543210)

NO DETERMINATION RESULT � NO CODE (FD-05b):
Then the chatbot displays:
"I've reviewed your flight details. Your Air Canada flight AC 372 from Montreal (YUL) to Toronto (YYZ) on May 18, 2026 arrived approximately 7 hours late. Unfortunately, our system does not have a disruption code assigned to this delay, which means we are unable to automatically determine your eligibility for compensation at this time."
"Your case has been forwarded to our Customer Relations team for manual review. They will investigate the cause of the delay and determine your eligibility for compensation."
"Would you like us to proceed with the manual review?"
And the user selects "Yes"

MANUAL HANDLING FLOW (GenUC-27):
Then the chatbot responds:
"To ensure our team can reach you regarding your claim, please confirm the following:"
And the chatbot asks:
� "Please confirm your preferred email for updates:"
And the user confirms: "v***@outlook.com"
And the chatbot asks:
� "Which country do you reside in?"
And the user provides: "Canada"

CASE CREATION (GLOB-09):
Then the chatbot creates the case and responds:
"Your case has been recorded and forwarded to our Customer Relations team for investigation. Case Reference: CASE-FD-20260610-054."
"Our team will investigate the cause of the delay and contact you with a determination. Please allow up to 30 days for a response."
And the system appends the booking record to the case automatically
And the case is routed to the agent queue for manual investigation

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a case acknowledgement email is sent to v***@outlook.com
And the email contains: Case Reference (CASE-FD-20260610-054), flight details (AC 372 YUL?YYZ, delayed 7h � no disruption code logged), explanation that disruption code is pending and manual review is required, estimated timeline (up to 30 days), contact information
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
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
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
    And the Regime should be "APPR"
    And the Full Name should be "V�ronique Caron"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "v***@outlook.com"
    And the Phone should be "+1***789"
    And the Address should be populated
    And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
    And the Tier Status should be "Basic / Member"
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Arrival Delay should show "+7H 00M (6�<9h band � no code logged)"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "No disruption code available after 14-day retry"
    And a note should indicate: "If code later confirmed Controllable ? APPR Tier 2 ($700 CAD Cash / $840 AC Wallet) would apply � pending agent manual determination"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run but returned "NO DETERMINATION" due to Arrival code NULL, Departure code NULL, 14-day window exhausted
    And the eligibility decision should be "PENDING AGENT REVIEW"
    And the Duplicate Check should have run automatically using baseline data "V�ronique Caron + TC057 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it is pending manual review
    And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should be routed to Customer Relations agent queue for manual investigation
    And a case acknowledgement email should have been sent to "v***@outlook.com"
    And the email should contain Case Reference "CASE-FD-20260610-054" and flight details AC 372 YUL to YYZ delayed 7h and explanation that disruption code is pending and estimated timeline up to 30 days
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and No Determination routing with timestamps
    And Customer Communications should show the acknowledgement email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Forwarded � Manual Review" pending agent investigation
    And the case should NOT be in read-only mode as it is pending CR team action
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to no disruption code after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling after 14-day retry exhausted
    And no country of residence payment mapping should have been executed
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � only applies to eligible cases
    And if the agent later determines eligible:
      - Manual compensation should be created ($700 CAD Cash / $840 AC Wallet for 7h 6�<9h band Tier 2 if Controllable confirmed)
      - Payment dispatched per type (Cash to Unifier, AC Wallet/e-credit to EIP)
      - AC Wallet (+20% = $840) should be offered as option if agent confirms eligibility and Aeroplan 9876543210 is in good standing
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-APPR-ND-04. Trip Tracer: Promise = 14:00; Actual = 21:00; Delay = 7hrs (6�<9h band observed � from ADS/AODB flight status data); MSL = Leg 1; Arrival Code = NULL; Departure Code = NULL; Cancellation Code = NULL; ALL codes missing; Cannot determine controllability. Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered (No Determination). Polling: System polls Trip Tracer daily for 14 days waiting for code entry. 14-day window EXHAUSTED (23 days since disruption) ? Routes to manual handling. If code later confirmed Controllable ? APPR Tier 2 ($700 CAD / $840 AC Wallet) would apply. Claims Dashboard: No Determination; Reason = All disruption codes missing after 14-day polling; Delay = 7h (6�<9h band); Aeroplan Basic logged; DDS = FD-APPR-ND-04.