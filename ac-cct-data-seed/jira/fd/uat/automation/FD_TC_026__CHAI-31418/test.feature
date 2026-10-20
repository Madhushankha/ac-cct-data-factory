GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight was delayed about 7 hours due to a maintenance issue, I'd like to check if I'm eligible for compensation and I'd prefer to get it on my Aeroplan account"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Isabelle C�t�"
Then the chatbot responds: "Thanks, Isabelle! And, what is your booking reference number?"
And the user provides "PNR: TC019"
Then the chatbot searches Trip Tracer for PNR: TC019
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, Star Alliance Gold profile) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: i***@gmail.com
* Phone: +1345
And the user selects "Email: i@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Welcome back, Isabelle (Star Alliance Gold). Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR TC019:
"I found 1 passenger on this booking:
* Isabelle C�t� (Adult - Star Alliance Gold)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 431
* Route: Montreal (YUL) to Toronto (YYZ)
* Date: May 10, 2026
* Arrival Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for this passenger + journey combination
Then the chatbot checks 72-hour rule: Arrival May 10, 2026; filing June 13, 2026 ? 34 days (>72 hours) ? PROCEED
Then the chatbot checks APPR filing deadline: 34 days elapsed (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Backend DDS executes evaluation for PNR TC019 / Claimant Isabelle C�t�:
� Regime: APPR Applicable
� Delay reason: Code 11 (Late Passengers / Gate Hold � Controllable)
� Delay duration: 7 hours (Band: 6 to <9 hours ? Tier 2)
� Star Alliance Recognition: Star Alliance Gold (G) status validated and active
� Base Eligibility: $700 CAD Cash
� AC Wallet Eligibility (+20% bonus): $840 CAD AC Wallet

TRIP TRACER UI VALIDATION:
The tester opens Trip Tracer UI for PNR: TC019
[x] Promised Itinerary: Flight AC 431, Route: YUL to YYZ, Scheduled Arrival: 10:00
[x] Current Itinerary: Flight AC 431, Route: YUL to YYZ, Status: ARRIVED LATE, Scheduled Arrival: 10:00 ? Actual: 17:00, Delay: +7H 00M
[x] Regime: APPR (1 regime)
[x] MSL Flight: AC 431 � YUL to YYZ � Code 11 ("Delayed due to late passengers")
[x] Delay Classification: +7H 00M � CONTROLLABLE
[x] Loyalty Profile: 9876543210 (Star Alliance Gold � linked, active)
[x] Flight Compensation Assessment:
  - MS ISABELLE C�T� | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 840.00 (Wallet) | [expiry date]

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Chatbot displays: "I've checked your flight details, and flight AC 431 from Montreal (YUL) to Toronto (YYZ) was delayed by about 7 hours. Based on the Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT & AC WALLET SELECTION (FD-06b / FD-07):
Chatbot asks: "In which country will your reimbursement be deposited?"
User selects "Canada" ? Currency = CAD
Chatbot checks loyalty profile status: Primary claimant Isabelle C�t� has linked profile (9876543210, Status: Star Alliance Gold in good standing)
Chatbot offers BOTH options:
"As a Star Alliance Gold member, you can choose to either receive:
 Cash: CAD $700 will be compensated and takes 5 to 10 business days to process the payment.
* AC Wallet: CAD $840 (including a 20% bonus of $140 CAD) will be added to your AC wallet immediately and has no expiry.
How would you like to receive your funds?"
User selects "AC Wallet"

IDENTITY VERIFICATION (PERSONA - FD-07b):
Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS

CLAIM AMOUNT CONFIRMATION FLOW:
Chatbot responds: "Thank you. You will be receiving $700 CAD converted into the currency associated to your profile.
Deposit Amount: $840 CAD
Payment Method: AC Wallet (Account #: 9876543210)
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission."
When the user clicks on "Yes"

CASE CREATION & NOTIFICATION (GLOB-09 / GLOB-11):
Chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor your claim status and payment updates. Please refer to that email for any follow-up information."
And an alert information is displayed: "Claim submission successful!"
System triggers notification email via Adobe to i***@gmail.com containing: Case Reference, compensation amount ($840 CAD AC Wallet), Star Alliance Gold tier confirmation (9876543210), regulation (APPR), flight details (AC 431 YUL to YYZ), disruption reason (Code 11 Late Passengers), tracking link.
User selects "No" to further help ? Bot responds "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "Isabelle C�t�" with PNR "TC019"
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "In Review" or "Done"
And the Created date should be populated
And the Last Updated date should be populated
And the SLA countdown should be tracking correctly
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Isabelle C�t�"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC019"
And the PNR Creation Date should be populated
And the Journey ID should be populated
And the Booking Source should be populated
And the Booking Office ID should be populated
And the Regime should be "APPR"
And the Full Name should be "Isabelle C�t�"
And the Tags should include "Claimant", "Adult", and "Star Alliance Gold"
And the Email should be "i***@gmail.com"
And the Phone should be "+1***345"
And the Address should be populated
And the Loyalty Number should be "9876543210" linked and active
And the Profile ID should be populated
And the Tier Status should be "Star Alliance Gold / Member"
And the Journey should show "Bound 1: YUL to YYZ" with claim filed for this flight
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "$840 CAD (AC Wallet � 20% Top-up Applied)"
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 2: 6 to <9 hrs, Code 11 Controllable, AC Wallet)
And the Duplicate Check should have run automatically using baseline data "Isabelle C�t� + TC019 + YUL to YYZ + FD"
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "GREEN"
And the case should have proceeded automatically and not be parked in Fraud Queue
And the system should have appended the booking record automatically for identified and authenticated user
And Trip Tracer poll should NOT be required
And the agent should have used pull case from My Activities
And the case status should have transitioned from "Assigned" to "In Progress"
And a case acknowledgement notification should have been sent
And an eligible notification email should have been sent via Adobe
And the Agent Notes section should be accessible
And the Audit Log should record all actions with timestamps and before/after values
And Customer Communications should show the notification email chronologically
And the chatbot transcript should be accessible and linked to the case
And the Attachments tab should be empty
And the Final Status should be "Resolved"
And the case should be in read-only mode with no editable Decision Assist fields
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the customer's country of residence is "Canada"
Then the currency should be set to "CAD"
And the customer has Star Alliance Gold profile "9876543210" linked with active status in good standing
And both options should be offered: Cash at $700 CAD and AC Wallet at $840 CAD with 20% top-up
And the customer selects "AC Wallet"
And the 20% top-up should be applied converting $700 to $840 CAD
And AC Wallet should be offered because this is flight disruption APPR
And a compensation record should be created for $840 CAD
And the record should be picked up by the daily evening batch file
And the record should be dispatched to EIP and NOT Unifier
And EIP should convert from CAD to the customer's profile country currency if applicable
And EIP should check loyalty account validity confirming it is active and not frozen
And EIP should send to iGiga
And iGiga should send to iFly for deposit
And iFly should talk back to EIP
And EIP should talk back to Claims Dashboard with deposited amount ($840 CAD), exchange rate, and status
And if the loyalty account is frozen or closed a rejection with error message should be returned and a failure notification should be sent to the case and the agent should be flagged
And in UAT the batch file should be triggered manually in coordination with the EIP team
And the Claims Dashboard Compensation tab should show "$840 CAD"
And the payment method should show "AC Wallet"
And the status should be updated via talkback

Expected Results:
DDS returns FD-APPR-EL-02. Trip Tracer: Promise = 10:00, Actual = 17:00, Delay = 7hrs, MSL = Leg 1, Code 11 (Late Passengers � Controllable), Regime = APPR. Loyalty Profile: Star Alliance Gold profile linked. Compensation: $840 CAD via AC Wallet ($700 base + 20% top-up of $140 CAD). EIP check: Account active, deposit successful via iGiga/iFly. CyberSource: GREEN. Persona: PASS. Claims Dashboard: Case created in Resolved/Done status with read-only summary, Star Alliance Gold tier populated, Code 11, and $840 CAD AC Wallet credited to account 9876543210.