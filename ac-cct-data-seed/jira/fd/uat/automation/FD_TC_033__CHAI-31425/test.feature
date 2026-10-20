Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
""Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?""
Then user selects English
Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice.""
Then chatbot asks ""How can I help you today?""
And the user says ""My flight from Montreal to Toronto was cancelled due to SOP ops control and I was rebooked to a flight landing at Hamilton instead. I arrived 7 hours later than my original flight was supposed to land. I'd like to check if I'm eligible for compensation""
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation.""
LEGAL DISCLAIMER:
Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?""
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
""I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you.""
And the chatbot responds:
""Please provide your full name exactly as it appears on your ticket, including any middle names if applicable.""
And the user provides ""Dominique Arsenault""
Then the chatbot responds:
""Thanks, Dominique! And, what is your booking reference number?""
And the user provides ""PNR: TC024""
Then the chatbot searches Trip Tracer for PNR: TC024
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
""To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?""
And the chatbot displays options:
� Email: d***@gmail.com
� Phone: +1***890
And the user selects ""Email: d***@gmail.com""
Then the chatbot responds:
""I've sent a verification code to your email, please enter it within 15 minutes of receiving it.""
And the user provides the OTP code ""629184""
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
""Your verification was successful. Let's proceed to the next step.""
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
""How many people are on your claim?""
And the chatbot displays passengers from PNR:
""I found 1 passenger on this booking:
� Dominique Arsenault (Adult - Aeroplan Member)
Is this who you'd like to include?""
And the user confirms ""Yes""
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
""I found the following journey:
� Flight: AC 436
� Route: Montreal (YUL) ? Hamilton (YHM) [Rebooked � original destination: Toronto YYZ]
� Date: May 10, 2026
� Arrival Delay: 7 hours
� Note: Rebooked to sister-city airport YHM (sister city of YYZ). Original flight AC 435 YUL?YYZ was cancelled due to SOP Ops Control.
Is this the journey you'd like to check?""
And the user confirms ""Yes""
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 10, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 10, 2026; filing June 15, 2026 ? 36 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC024
? Promised Itinerary - Flight: AC 435, Route: YUL ? YYZ, Scheduled Arrival: 10:00 at YYZ (original flight � CANCELLED)
? Current Itinerary - Flight: AC 436, Route: YUL ? YHM (rebooked to sister city), Status: ARRIVED, Actual Arrival: 17:00 at YHM
? History - Change 1: INVOL � Original flight AC 435 YUL?YYZ cancelled (SOP Ops Control). Customer accepted rebooking to AC 436 YUL?YHM (sister city of YYZ).
? Sister City Check: YHM ? YYZ = VALID PAIR (confirmed in DDS sister city config)
? Sister city accepted as equivalent destination
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 435 � YUL ? YYZ � Cancellation Code: SOP Ops Control
? Rebooked Flight: AC 436 � YUL ? YHM (sister city)
? Delay Calculation: Original promise = 10:00 at YYZ; Actual arrival = 17:00 at YHM (sister city); Delay = 7hrs
? Delay: +7H 00M � CONTROLLABLE (SOP Ops Control)
? Aeroplan: 9876543210 (Basic Member � linked)
Flight Compensation:
  ? MS DOMINIQUE ARSENAULT | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD $700.00 Cash / CAD $840.00 AC Wallet (+20%) | [expiry date]
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
And the customer is cleared to proceed to payment
ELIGIBLE RESULT (FD-05a):
Then the chatbot displays:
""I've checked your flight details, and it looks like your original flight AC 435 from Montreal (YUL) to Toronto (YYZ) was cancelled due to SOP operational control, and you were rebooked to Hamilton (YHM). Your actual arrival was 7 hours later than originally scheduled. Based on the Air Passenger Protection Regulations (APPR), you are eligible for compensation for this delay. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible.""
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
""Thank you for confirming. In which country will your reimbursement be deposited?""
And the user selects ""Canada""
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? YES (Aeroplan #: 9876543210, Status: Basic Member)
Then the chatbot checks: Aeroplan account in good standing? ? YES
Then the chatbot offers BOTH options:
""Since you are an Aeroplan member, you can choose to receive:
� Cash: $700 CAD will be sent via Interac e-Transfer and takes 5 to 10 business days to process.
� AC Wallet: $840 CAD (including a 20% bonus) will be added to your AC Wallet immediately and has no expiry.
How would you like to receive your funds?""
And the user selects ""Cash""
Then the system determines: Customer selected Cash ? Payment method = Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC (FD-07):
Then the chatbot responds:
""Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use d***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed.""
And the user confirms ""Yes, use this email""
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
""I must verify your identity for payment security. Please click here to get started""
And chatbot displays a button ""Get verified""
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
""Your identity has been verified successfully. Let's proceed to finalize your claim.""
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: ""Please review your compensation details:
Deposit Amount: $700 CAD
Payment Method: Interac e-Transfer (d***@gmail.com)
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
Would you like me to submit your claim?""
And an alert information is displayed: ""Please note that the payment details cannot be changed after submission.""
When the user provides: ""Yes""
CASE CREATION (GLOB-09):
Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information.""
And an alert information is displayed: ""Claim submission successful!""
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to d***@gmail.com
And the email contains: Case Reference, compensation amount ($700 CAD Cash � Interac e-Transfer), regulation (APPR), flight details (including sister city note: YHM for YYZ), disruption reason (SOP Ops Control Cancellation), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
""Is there anything I can help you with?""
� I would like you to � new flow
� No
And the user selects ""No""
Then the chatbot responds ""Thank you for choosing Air Canada.""
CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant ""Dominique Arsenault"" with PNR ""TC024""
    Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay""
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be ""In Review"" or ""Done""
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be ""Dominique Arsenault""
    And the Claimant Type should be ""Adult""
    And the Authentication should be ""Pass""
    And the PNR should be ""TC024""
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be ""APPR""
    And the Full Name should be ""Dominique Arsenault""
    And the Tags should include ""Claimant"" and ""Adult""
    And the Email should be ""d***@gmail.com""
    And the Phone should be ""+1***890""
    And the Address should be populated
    And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member)
    And the Profile ID should be populated
    And the Tier Status should be ""Basic / Member""
    And the Journey should show ""Bound 1: YUL ? YYZ"" (rebooked YUL ? YHM sister city) with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and populated for this automated FD case
    And the compensation should show ""$700 CAD (Cash � Interac e-Transfer)""
    And the AC Wallet option ($840 CAD) should be visible as offered but NOT selected
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as ""ELIGIBLE"" under APPR Tier 2 (sister city YHM, 7h delay, SOP Ops Control)
    And the Duplicate Check should have run automatically using baseline data ""Dominique Arsenault + TC024 + YUL?YYZ + FD""
    And the result should be ""No duplicate found""
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And the CyberSource result should be ""GREEN""
    And the case should have proceeded automatically and not be parked in Fraud Queue
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from ""Assigned"" to ""In Progress""
    And a case acknowledgement notification should have been sent
    And an eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be ""Resolved""
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only
PAYMENT VALIDATION
    Given the customer's country of residence is ""Canada""
    Then the currency should be set to ""CAD""
    And the customer has Aeroplan ""9876543210"" linked with Basic Member status in good standing
    And both options should have been offered: Cash ($700 CAD Interac) AND AC Wallet ($840 CAD with 20% top-up)
    And the customer selected ""Cash"" ? Payment method = Interac e-Transfer
    And AC Wallet was offered but NOT selected ? AC Wallet payout NOT dispatched
    And the compensation amount should be ""$700 CAD"" for Tier 2 delay of 6 to less than 9 hours
    And a compensation record should be created in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier
    And Unifier should send an acknowledgement back
    And the end-of-day report should be received from Interac
    And the status should be ""Pending"" transitioning to ""Cached"" or ""Rejected"" or ""Expired""
    And if the payment is unclaimed after 35 days the status should be set to ""Expired""
    And the Claims Dashboard Compensation tab should show ""$700 CAD"" Cash via Interac
    And the status should be updated via talkback
Expected Results:
Trip Tracer: Promise = 10:00 at YYZ (original flight AC 435, CANCELLED); Actual = 17:00 at YHM (rebooked flight AC 436, sister city); Sister City = TRUE (YHM?YYZ); Delay = 7hrs (17:00 ? 10:00); MSL = AC 435 (cancelled leg); Cancellation Code: SOP Ops Control (Controllable); APPR Tier 2. Aeroplan: Basic Member (9876543210) linked � BOTH Cash ($700 CAD) and AC Wallet ($840 CAD +20%) offered. Customer selects Cash. Change History: INVOL � AC 435 cancelled (SOP Ops Control) ? customer accepted rebooking to AC 436 YUL?YHM.