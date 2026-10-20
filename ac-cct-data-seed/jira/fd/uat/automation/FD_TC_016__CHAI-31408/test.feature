GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "Our group flight was delayed 7 hours, there are 12 of us, we want compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Jean-Pierre Martin"
Then the chatbot responds: "Thanks, Jean-Pierre! And, what is your booking reference number?"
And the user provides "TC013"
Then the chatbot searches Trip Tracer for PNR: TC013
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is retrieved

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: j***@gmail.com
* Phone: +1234
And the user selects "Email: j@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides OTP code "847291"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PRIVACY RESTRICTION:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = PRESENT (12 passengers on booking)
Then the chatbot responds: "I can see this is a group booking with 12 passengers. For privacy and data protection, you will only be able to claim for yourself. Other travelers on this booking must file their claims individually."
And the user confirms "Understood"
Then passenger selection is skipped (restricted to Jean-Pierre Martin only)

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 301
* Route: Montreal (YUL) ? Toronto (YYZ)
* Date: January 15, 2026
* Arrival Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for Jean-Pierre Martin on this journey
Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (>72 hours) ? PROCEED
Then the chatbot checks APPR filing deadline: 13 days elapsed (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Backend DDS executes evaluation for PNR TC013 / Claimant Jean-Pierre Martin:
� Regime: APPR Applicable
� Delay reason: Code 31 (Documentation / Dispatch / System Issue � Controllable)
� Delay duration: 7 hours (Band: 6 to <9 hours ? Tier 2)
� Eligibility: ELIGIBLE ($700 CAD for 1 claimant)

TRIP TRACER UI VALIDATION:
The tester opens Trip Tracer UI for PNR: TC013
[x] Promised Itinerary: Flight AC 301, YUL ? YYZ, Scheduled Arrival: 14:00
[x] Current Itinerary: Flight AC 301, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 14:00 ? Actual: 21:00, Delay: +7H 00M
[x] Regime: APPR (1 regime)
[x] MSL Flight: AC 301 � YUL ? YYZ � Code 31 ("Delayed due to documentation / flight dispatch issues")
[x] Delay Classification: +7H 00M � CONTROLLABLE
[x] Aeroplan: 9871234567 (Basic Member � linked)
[x] Group Booking Indicator: TRUE (12 Pax total, restricted to self-claim)
[x] Flight Compensation Assessment:
  - MR JEAN-PIERRE MARTIN | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet (+20%) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Chatbot displays: "I've checked your flight details, and flight AC 301 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours due to documentation and scheduling delays (Code 31 - Controllable). Under the Air Passenger Protection Regulations (APPR), you are eligible for compensation of $700 CAD for this delay."

CLAIM PAYMENT & AEROPLAN OFFER (FD-06b / FD-07):
Chatbot asks: "In which country will your reimbursement be deposited?"
User selects "Canada" ? Currency = CAD
Chatbot checks Aeroplan status: Jean-Pierre Martin has linked Aeroplan (9871234567, Basic Member in good standing)
Chatbot offers BOTH payment options:
"Since you are an Aeroplan member, you can choose to receive:
* Cash: $700 CAD sent via Interac e-Transfer (takes 5 to 10 business days).
* AC Wallet: $840 CAD (including a 20% bonus) added to your AC Wallet immediately with no expiry.
How would you like to receive your funds?"
User selects "Cash"
Chatbot confirms payment method: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use j***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
User confirms: "Yes, use this email"

IDENTITY VERIFICATION (PERSONA - FD-07b):
Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS

CLAIM CONFIRMATION & CASE CREATION (GLOB-09):
Chatbot displays summary:
"Please review your compensation details:
Deposit Amount: $700 CAD
Payment Method: Interac e-Transfer (j***@gmail.com)
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
Would you like me to submit your claim?"
User responds "Yes"
Chatbot creates case and displays: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Claim submission successful!"

NOTIFICATION & WRAP-UP (GLOB-11):
Adobe triggers notification email to j***@gmail.com containing: Case Reference, compensation amount ($700 CAD Cash � Interac e-Transfer), regulation (APPR), flight details (YUL?YYZ AC 301), disruption reason (Code 31 Documentation / Dispatch), next steps, tracking link.

Claims Dashboard Gherkin:
Given the case has been created for claimant "Jean-Pierre Martin" with PNR "TC013"
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "In Review" or "Done"
And the Created date should be populated
And the Last Updated date should be populated
And the SLA countdown should be tracking correctly
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Jean-Pierre Martin"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC013"
And the PNR Creation Date should be populated
And the Journey ID should be populated
And the Booking Source should be populated
And the Booking Office ID should be populated
And the Regime should be "APPR"
And the Full Name should be "Jean-Pierre Martin"
And the Tags should include "Claimant", "Adult", and "Group Booking"
And the Email should be "j***@gmail.com"
And the Phone should be "+1234"
And the Address should be populated
And the Aeroplan should be "9871234567" linked and in good standing (Basic Member)
And the Tier Status should be "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "$700 CAD (Cash � Interac e-Transfer)"
And the AC Wallet option ($840 CAD) should be visible as the offered alternative but NOT selected
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Code 31 Controllable, 7h delay, Tier 2)
And the Duplicate Check should have run automatically using baseline data "Jean-Pierre Martin + TC013 + YUL?YYZ + FD"
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "GREEN"
And the case should have proceeded automatically and not be parked in Fraud Queue
And the system should have appended the booking record to the case automatically
And Trip Tracer poll should NOT be required
And the agent should have used pull case function from My Activities to get this case
And the case status should have transitioned from "Assigned" to "In Progress"
And a case acknowledgement notification should have been sent to the customer
And an eligible notification email should have been sent via Adobe containing $700 CAD Cash and Interac e-Transfer payment method
And the Agent Notes section should be accessible
And the Audit Log should record all actions with timestamps
And Customer Communications should show the notification email
And the chatbot transcript should be accessible and linked
And the Attachments tab should be empty
And the Final Status should be "Resolved"
And the case should be in read-only mode with no editable Decision Assist fields
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the customer's country of residence is "Canada"
Then the currency should be set to "CAD"
And the customer has Aeroplan "9871234567" linked with Basic Member status in good standing
And both options should have been offered: Cash ($700 CAD Interac) AND AC Wallet ($840 CAD with 20% top-up)
And the customer selected "Cash" ? Payment method = Interac e-Transfer
And AC Wallet was offered but NOT selected � AC Wallet payout NOT dispatched
And the Interac email should be collected from the customer (j@gmail.com)
And a compensation record should be created with $700 CAD
And the record should be picked up by the daily evening batch file
And the record should be dispatched to Unifier
And Unifier should send an acknowledgement back
And the end-of-day report should be received from Interac
And the status should be "Pending" transitioning to "Cached" or "Rejected" or "Expired"
And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired"
And the Claims Dashboard Compensation tab should show payout details: amount ($700 CAD), payment method (Cash � Interac e-Transfer), status updated via talkback

Expected Results:
DDS generates FD-APPR-EL-01 for single claimant under group booking. Delay: 7 hours (Tier 2: 6�<9h). Code: 31 (Documentation / Dispatch � Controllable). Regime: APPR. Total Payout: $700 CAD Cash via Interac e-Transfer to j***@gmail.com. Other 11 group passengers remain unexposed and unfiled.