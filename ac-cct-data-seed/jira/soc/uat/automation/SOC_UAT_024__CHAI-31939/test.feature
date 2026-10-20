Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I just landed yesterday and my flight was delayed by about 6 hours. I had to buy food and pay for a taxi. Can I get reimbursed for what I spent?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO

SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "[First Name] [Last Name]"
Then the chatbot responds:
"Thanks, [First Name]! And, what is your booking reference number?"
And the user provides "PNR: [PNR Code]"
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: t***@gmail.com
� Phone: +1***789
And the user selects "Email: t***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "546879"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

Then the chatbot checks if this PNR a group booking ? No
Then the chatbot checks if there are multiple PAX on PNR? ? No

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 201
� Route: Toronto (YYZ) ? Montreal (YUL)
� Date: June 7, 2026
� Departure Delay: 6 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK: ? FLOW STOPS HERE � PENDING
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey:
� Last leg Departure: June 7, 2026
� Current date: June 8, 2026
� Hours elapsed: ~24 hours
� 24 hours < 72 hours ? WITHIN 72-HOUR WINDOW ? PENDING ?

? FLOW DOES NOT PROCEED TO:
  ? Claim Time Limit Check � SKIPPED
  ? Triage Eligibility Check (SoC-02b) � SKIPPED
  ? Airline Company Routing � SKIPPED
  ? DDS Evaluation � SKIPPED
  ? Fraud Screening � SKIPPED
  ? Receipt Upload � SKIPPED
  (72-hour hold takes effect � system needs time to gather complete data)

SHELL CASE CREATION:
Then the system creates a SHELL case in Case Services
And the shell case includes:
� Case type: Shell (pending � awaiting 72-hour window closure)
� Passenger: [First Name] [Last Name]
� PNR: [PNR Code]
� Journey: AC 201 YYZ?YUL, June 7, 2026
� Delay: ~360 min (6 hours) � preliminary, subject to confirmation
� Status: SYSTEM PROCESSING
� Regime: TBD (pending evaluation)
� DDS Response Code: TBD (pending evaluation)
� Location: System processing queue (NOT in agent queue � no agent assigned)
And the case is placed in the polling queue for 72-hour retrigger

DDS RESPONSE CODE = SoC-APPR-PE-01 (PENDING)

PENDING RESULT:
Then the chatbot displays: "Thank you for submitting your claim details. Your flight AC 201 from Toronto to Montreal arrived recently, and we need a little more time to gather all the necessary flight data to evaluate your eligibility. Your claim is being processed and you will receive an update within the next few days."

Then the chatbot responds:
"Here's what will happen next:
� We've created a reference for your claim: [Shell Case Reference]
� Our system will automatically evaluate your eligibility once all flight data is available (typically within 72 hours of your last flight)
� You will receive an email with a link to complete your claim if you are eligible
� Please keep any receipts for expenses you incurred during the disruption, as you may need to upload them later"

DEEP LINK NOTIFICATION (after 72-hour window closes):
NOTE: The following happens AUTOMATICALLY after 72 hours � the passenger does not need to take any action.

After 72 hours (approximately June 10, 2026):
Then the system's polling queue triggers a re-evaluation
And the Rules Engine (RE) retrieves complete flight data:
� Actual departure time: confirmed
� Actual Departure time: confirmed
� Departure delay code: populated (e.g., 41 � Crew Scheduling)
� Operating data: complete

Then the DDS evaluates eligibility with complete data:
� If ELIGIBLE: Deep link email sent to passenger ? passenger clicks link ? returns to chatbot ? enters Welcome Back flow ? uploads receipts ? OCR validation ? case creation ? payment
� If NOT ELIGIBLE: Rejection email sent to passenger ? case auto-closed
� If NO DETERMINATION: Case moved to manual agent queue

WELCOME BACK FLOW (if eligible � after 72h):
Then the passenger receives an email from Air Canada:
"Good news! We've reviewed the details of your flight AC 201 from Toronto to Montreal, and you are eligible for expense reimbursement. Please click the link below to complete your claim by uploading your receipts."
And the email includes:
� Deep link to chatbot with pre-populated claim data
� Case reference number
� Expiry date for completing the claim

Then the passenger clicks the deep link
And the chatbot opens with pre-populated data:
"Welcome back, [First Name]! We've determined that you are eligible for expense reimbursement for your flight AC 201 from Toronto to Montreal on June 7, 2026. To complete your claim, please upload your receipts."

Then the chatbot proceeds to:
� Receipt upload flow
� OCR validation
� Expense breakdown
� Case creation
� Payment flow
(Same as EL-08 detailed steps from receipt upload onwards)

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-PE-01 � 72-Hour Hold Pending
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "System Processing ??"
  And the Created date is populated as June 8, 2026
  And the Last Updated date is populated as June 8, 2026
  And the SLA is 72-hour processing window
  And the Team assignment is "N/A (system processing � not assigned to agent)"
  And no banners are displayed (Auth Flow 1)
  And the Decision Assist panel is pending (DDS not yet run)
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the PNR Creation Date is populated
  And the Journey ID is populated
  And the Booking Source is populated
  And the Booking Office ID is populated
  And the Regime is "TBD (pending evaluation)"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 201 YYZ ? YUL as the claimed flight
  And the Flight Status is "DELAYED (6 hours � preliminary)"
  And the Eligibility section shows Journey = AC 201 YYZ ? YUL
  And the Flight Leg at Fault is AC 201
  And the Operating Carrier is AC
  And the Disruption Reason is "TBD � pending 72-hour data completion"
  And the Delay Minutes is approximately 360 min (preliminary � subject to confirmation)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Passenger Type is "Regular"
  And the Controllability is "TBD � pending Departure delay code"
  And the DDS Response Code is "SoC-APPR-PE-01 (PENDING)"
  And the DDS Polling Status is "ACTIVE � system will re-evaluate after 72h"
  And the Fraud Screening is "NOT YET PERFORMED"
  And the Eligibility is "PENDING"
  And the last leg Departure is June 7, 2026
  And the filing date is June 8, 2026
  And the hours elapsed is approximately 24 hours
  And 24 hours is less than 72 hours so the case is WITHIN 72-HOUR WINDOW and PENDING
  And the scheduled DDS Run is approximately June 10, 2026
  And the flow is STOPPED at 72-hour check with the following SKIPPED: Claim Time Limit Check, Triage Eligibility Check (SoC-02b), Airline Company Routing, DDS Evaluation, Fraud Screening, Receipt Upload
  And the Receipt Validator SOC Expense Line Items is "N/A (pending eligibility determination)"
  And the Applicable Regimes SOC Amount is "N/A (pending)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered (pending)
  And the system processing queue is visible to management only (not agents)
  And agents cannot see or action cases in system processing queue
  And once 72h passes the case moves to appropriate queue
  And the Current Status is "System Processing (Pending � 72-hour hold)"
  And the case is NOT in read-only mode (will be updated after DDS runs post-72h)

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-PE-01 � 72-Hour Hold Pending
  Given the case SoC-APPR-PE-01 is PENDING
  Then no payment flow is triggered at this stage
  And a shell case is created in System Processing Queue
  And the route is AC 201 YYZ ? YVR with delay 360 min (6 hrs) filed less than 72 hrs since Departure
  And no country of residence is asked
  And no receipts are uploaded
  And no CyberSource fraud check is triggered
  And no compensation record is created
  And no batch file is dispatched
  And no GL account or cost center is assigned
  And the system polls DDS for up to 14 days
  And after 72h if DDS returns ELIGIBLE then a deep link email is sent to customer
  And the customer returns to chatbot and uploads receipts for OCR validation
  And SOC is Cash only (no AC Wallet / e-credit for SOC)
  And country of residence is asked and Canada maps to CAD with Interac via Unifier
  And entitlements are applied based on delay category for 1 adult PY no ACR: Meals $30, Hotel rate of day 3 nights max $500 cap, Transport $200, Communication $30, Parking $50, Essentials $30
  And receipts are validated against entitlement thresholds
  And compensation record is created with GL accounts per category and cost center CR 503
  And approval threshold check is based on total approved amount
  And batch file is triggered to Unifier and end-of-day report is generated
  And Claims Dashboard Compensation tab is populated with amount CAD, Cash, Interac, status via talkback
  And after 72h if DDS returns NOT ELIGIBLE then rejection email is sent to passenger
  And the case is auto-closed with no compensation record, no batch file, and no payment
  And Claims Dashboard shows NOT ELIGIBLE with no payout section
  And if no DDS answer after 14 days then the case is sent to agent queue for manual handling
  And the agent investigates and manually determines outcome
  And Claims Dashboard while pending shows Case status = "Pending / System Processing" with no payout section

EXPECTED RESULTS:
SoC-APPR-PE-01. PENDING. Last leg <72h ago. Shell case created. Placed in polling queue. Passenger informed of pending status. After 72h window: RE retrigger ? DDS evaluation ? deep link sent if eligible. No receipt upload at this stage.