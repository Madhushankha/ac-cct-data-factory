GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "My flight was delayed about 10 hours, I'd like to check if our booking of 6 is eligible for compensation and I'd prefer to get it on my Aeroplan account"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Nathalie Fortin"
Then the chatbot responds: "Thanks, Nathalie! And, what is your booking reference number?"
And the user provides "TC022"
Then the chatbot searches Trip Tracer for PNR: TC022
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is retrieved

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
* Email: n***@outlook.com
* Phone: +1678
And the user selects "Email: n@outlook.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides OTP code "739281"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR TC022:
"I found 6 passengers on this booking:
1. Nathalie Fortin (Adult - Aeroplan Member)
2. Marc Fortin (Adult)
3. Eric Fortin (Adult)
4. Julie Fortin (Adult)
5. Lucas Fortin (Child)
6. Emma Fortin (Child)
Would you like to include all 6 passengers in this claim?"
And the user confirms "Yes, include all 6 passengers"
Then the chatbot checks: PAX count on PNR = 6 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
* Flight: AC 434
* Route: Montreal (YUL) ? Toronto (YYZ)
* Date: May 8, 2026
* Arrival Delay: 10 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 6 passengers on this journey
Then the chatbot checks 72-hour rule: Arrival May 8, 2026; filing June 15, 2026 ? 38 days (>72 hours) ? PROCEED
Then the chatbot checks APPR filing deadline: 38 days elapsed (within 366 days) ? PROCEED

TRIAGE & DDS EVALUATION:
Backend DDS executes evaluation for PNR TC022 covering all 6 passengers:
� Regime: APPR Applicable
� Delay reason: Code 15 / 42 (Maintenance / Technical � Controllable)
� Delay duration: 10 hours (Band: 9+ hours ? Tier 3)
� Base Eligibility: $1,000 CAD per passenger x 6 = $6,000 CAD Cash
� AC Wallet Eligibility (+20% bonus): $1,200 CAD per passenger x 6 = $7,200 CAD AC Wallet

TRIP TRACER UI VALIDATION:
The tester opens Trip Tracer UI for PNR: TC022
[x] Promised Itinerary: Flight AC 434, YUL ? YYZ, Scheduled Arrival: 08:00
[x] Current Itinerary: Flight AC 434, YUL ? YYZ, Status: ARRIVED LATE, Scheduled: 08:00 ? Actual: 18:00, Delay: +10H 00M
[x] Regime: APPR (1 regime)
[x] MSL Flight: AC 434 � YUL ? YYZ � Code 15 / 42 ("Delayed due to scheduled maintenance / technical")
[x] Delay Classification: +10H 00M � CONTROLLABLE
[x] Aeroplan: 1234567890 (Nathalie Fortin � linked, active, good standing)
[x] Flight Compensation Assessment (6 Pax):
  - MS NATHALIE FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - MR MARC FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - MR ERIC FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - MS JULIE FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - MSTR LUCAS FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - MISS EMMA FORTIN | ELIGIBLE | DELAY_GTE_9_HOURS | CAD 1,000.00 Cash / CAD 1,200.00 AC Wallet
  - Total Compensation: CAD 6,000.00 Cash / CAD 7,200.00 AC Wallet

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Chatbot sends case details to CyberSource ? Returns GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Chatbot displays: "I've checked your flight details, and flight AC 434 from Montreal (YUL) to Toronto (YYZ) was delayed by about 10 hours due to maintenance constraints (Controllable). Under the Air Passenger Protection Regulations (APPR), all 6 passengers on your booking are eligible for compensation."

CLAIM PAYMENT & AEROPLAN AC WALLET SELECTION (FD-06b / FD-07):
Chatbot asks: "In which country will your reimbursement be deposited?"
User selects "Canada" ? Currency = CAD
Chatbot checks Aeroplan status: Primary claimant Nathalie Fortin has linked Aeroplan (1234567890, active and in good standing)
Chatbot offers BOTH options for all 6 passengers:
"Since you are an Aeroplan member, you can choose to receive for all 6 passengers:
* Cash: $6,000 CAD total ($1,000 CAD x 6) sent via Interac e-Transfer and takes 5 to 10 business days to process.
* AC Wallet: $7,200 CAD total ($1,200 CAD x 6, including a 20% bonus of $200 CAD per passenger) added to your AC Wallet immediately with no expiry.
How would you like to receive your funds?"
User selects "AC Wallet"

IDENTITY VERIFICATION (PERSONA - FD-07b):
Chatbot displays "Get verified" button ? User completes Persona IDV ? Persona returns IDV PASS

CLAIM AMOUNT CONFIRMATION FLOW:
Chatbot responds: "Please review your compensation details:
Total Base Amount: $6,000 CAD
Top-Up Bonus (20%): $1,200 CAD
Total Deposit Amount: $7,200 CAD
Payment Method: AC Wallet (Aeroplan #: 1234567890)
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that payment details cannot be changed after submission."
User confirms "Yes"

CASE CREATION & NOTIFICATION (GLOB-09 / GLOB-11):
Chatbot responds: "Thank you. Your claim has been submitted and will be processed within 10 business days. A confirmation email will be sent to you with details on how to monitor your claim status and AC Wallet updates. Claim submission successful!"
System triggers notification email via Adobe to n***@outlook.com containing: Case Reference, $7,200 CAD AC Wallet compensation, Aeroplan account 1234567890, breakdown for 6 passengers, regulation (APPR), flight details (AC 434 YUL?YYZ), tracking link.
User selects "No" to further help ? Bot responds "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "Nathalie Fortin" with PNR "TC022" covering 6 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "In Review" or "Done"
And the Created date should be populated
And the Last Updated date should be populated
And the SLA countdown should be tracking correctly
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Nathalie Fortin"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC022"
And the PNR Creation Date should be populated
And the Journey ID should be populated
And the Booking Source should be populated
And the Booking Office ID should be populated
And the Regime should be "APPR"
And the Full Name should be "Nathalie Fortin"
And the Tags should include "Claimant" and "Adult"
And the Email should be "n***@outlook.com"
And the Phone should be "+1***678"
And the Address should be populated
And the Aeroplan should be "1234567890" linked and active
And the Profile ID should be populated
And the Tier Status should be populated
And all 6 passengers should be listed on the case (Nathalie, Marc, Eric, Julie, Lucas, Emma Fortin)
And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "$7,200 CAD (AC Wallet � 20% Top-up Applied)"
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "ELIGIBLE" (APPR, Tier 3: 9+ hrs, 6 Pax, AC Wallet)
And the Duplicate Check should have run automatically across all 6 passengers
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "GREEN"
And the case should have proceeded automatically and not be parked in Fraud Queue
And the system should have appended the booking record automatically
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
And the customer has Aeroplan "1234567890" linked and in good standing
And both options should be offered: Cash at $6,000 CAD and AC Wallet at $7,200 CAD with 20% top-up for 6 passengers
And the customer selects "AC Wallet"
And the 20% top-up should be applied converting $1,000 to $1,200 per passenger ($7,200 CAD total)
And AC Wallet should be offered because this is flight disruption APPR
And a compensation record should be created for $7,200 CAD
And the record should be picked up by the daily evening batch file
And the record should be dispatched to EIP and NOT Unifier
And EIP should convert from CAD to the customer's Aeroplan profile country currency if applicable
And EIP should check Aeroplan account validity confirming it is active and not frozen
And EIP should send to iGiga
And iGiga should send to iFly for deposit
And iFly should talk back to EIP
And EIP should talk back to Claims Dashboard with deposited amount, exchange rate, and status
And if the Aeroplan account is frozen or closed a rejection with error message should be returned and a failure notification should be sent to the case and the agent should be flagged
And in UAT the batch file should be triggered manually in coordination with the EIP team
And the Claims Dashboard Compensation tab should show "$7,200 CAD"
And the payment method should show "AC Wallet"
And the status should be updated via talkback

Expected Results:
DDS returns FD-APPR-EL-03 for 6 passengers. Trip Tracer: Promise = 08:00; Actual = 18:00; Delay = 10hrs; MSL = Leg 1; Code 15 / 42; Controllable; APPR. Compensation: $7,200 CAD via AC Wallet ($6,000 base for 6 pax + 20% top-up of $1,200). Aeroplan check: Account active, deposit dispatched to EIP/iFly. CyberSource: GREEN. Persona: PASS. Claims Dashboard: Case created in Resolved/Done status with read-only summary, 6 passengers listed, $7,200 CAD AC Wallet credited to Aeroplan 1234567890.