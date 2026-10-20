GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
  "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then an alert information is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks: "How can I help you today?"
And the user says: "Our flight from London to Montreal was delayed about 5 hours because of a request from the flight crew, I'd like to check if my family and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds: "I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Catherine Bouchard"
Then the chatbot responds: "Thanks, Catherine! And, what is your booking reference number?"
And the user provides "TC079"
Then the chatbot searches Trip Tracer for PNR: TC079
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details, linked Aeroplan profile) is retrieved

AUTHENTICATION (GenUC-05):
Then the chatbot responds: "To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options: Email: c***@gmail.com | Phone: +1***567
And the user selects "Email: c***@gmail.com"
Then the chatbot responds: "I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides OTP code "591837"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds: "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Then the system checks Trip Tracer for group booking identifier ? NOT PRESENT
Then the chatbot asks: "How many people are on your claim?"
And the chatbot displays passengers from PNR TC079:
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
   Flight: AC 865
   Route: London Heathrow (LHR) ? Montreal (YUL)
   Date: January 15, 2026
   Arrival Delay: 5 hours
   Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT & ELIGIBILITY CHECKS:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
Then the chatbot sends request to Case Services for duplicate check ? NO existing case found for any of the 3 passengers on this journey
Then the chatbot checks 72-hour rule: Arrival Jan 15, 2026; filing Jan 28, 2026 ? 312 hours (more than 72 hours) ? PROCEED
Then the chatbot checks filing deadline: UK departure ? 2190 days (6 years); 13 days elapsed ? within limit ? PROCEED

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend for PNR TC079
And DDS checks journey origin: LHR (United Kingdom) ? UK regime applicable (EU 261 UK branch)
And DDS checks destination: YUL (Canada) ? APPR also applicable
And DDS identifies MSL = AC 865 LHR ? YUL (only segment)
And DDS checks the cancellation code on MSL ? NONE
And DDS checks the first arrival delay code on MSL ? 65 (FR) ? no fallback needed
And DDS classifies 65 (FR) as CONTROLLABLE (flight deck crew special request � within carrier control)
And DDS checks disruption notice: less than 14 days before departure ? compensation applies
And DDS calculates delay = 19:00 ? 14:00 = 300 min ? UK band DELAY_GTE_4_HOURS
And DDS evaluates UK entitlement: GBP 520 per passenger x 3 = GBP 1,560
And DDS evaluates APPR entitlement (comparison): Tier 1 (3 to <6 hrs) CAD 400 per passenger x 3 = CAD 1,200
And DDS applies Most Generous logic ? EU/UK selected over APPR
And DDS returns EU ELIGIBLE for all 3 passengers and sends results to Trip Tracer UI

TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC079
? Promised Itinerary: Flight AC 865, LHR ? YUL, Scheduled Arrival: 14:00
? Current Itinerary: Flight AC 865, LHR ? YUL, Status: ARRIVED LATE, 14:00 ? 19:00, Delay: +5H 00M
? History: No booking changes (no VOL or INVOL)
? Regimes: EU (UK) + APPR (2 regimes) ? Most Generous = EU/UK
? MSL Flight: AC 865 � LHR ? YUL � Code 65 (FR) � "Delayed due to flight deck crew special request"
? Cancellation code: NONE ; Fallback: FALSE
? Delay Classification: +5H 00M � CONTROLLABLE
? Aeroplan: 9876543210 (Basic Member � linked)
? Passengers: 3 Pax (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard)
Flight Compensation Assessment:
? MS CATHERINE BOUCHARD | ELIGIBLE | DELAY_GTE_4_HOURS | GBP 520.00 Cash / GBP 624.00 AC Wallet | [expiry date]
? MR ALEXANDRE BOUCHARD | ELIGIBLE | DELAY_GTE_4_HOURS | GBP 520.00 Cash / GBP 624.00 AC Wallet | [expiry date]
? MISS SOPHIE BOUCHARD | ELIGIBLE | DELAY_GTE_4_HOURS | GBP 520.00 Cash / GBP 624.00 AC Wallet | [expiry date]
? Total: GBP 1,560.00 Cash / GBP 1,872.00 AC Wallet
? APPR comparison: CAD 1,200 (not selected)

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource
And CyberSource returns: GREEN LIGHT (Pass)

ELIGIBLE RESULT DISPLAY (FD-05a):
Then the chatbot displays: "I've checked your flight details, and it looks like flight AC 865 from London Heathrow (LHR) to Montreal (YUL) was delayed by about 5 hours. Because your journey departed from the United Kingdom, UK passenger rights regulations apply, and all 3 passengers on your booking may be eligible for compensation. I'll guide you through the next steps so we can get your claim submitted and processed as quickly as possible."

CLAIM PAYMENT & AEROPLAN OFFER (FD-06b / FD-07):
Then the chatbot asks: "Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada" ? Currency = CAD
Then the chatbot checks Aeroplan status: Catherine Bouchard has linked Aeroplan 9876543210, Basic Member in good standing
And the chatbot offers BOTH payment options:
  "Since you are an Aeroplan member, you can choose to receive for all 3 passengers:
   Cash: GBP 1,560 total (GBP 520 x 3), deposited in your local currency (CAD) via Interac e-Transfer, and takes 5 to 10 business days to process.
   AC Wallet: GBP 1,872 total (GBP 624 x 3, including a 20% bonus) added to your AC Wallet immediately with no expiry.
   How would you like to receive your funds?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And the user selects "Cash"
Then the system checks which payment method is mapped based on country of residence ? Interac (CANADA)
Then the chatbot responds: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use c***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
And the user confirms: "Yes, use this email"
Then the chatbot does NOT ask for bank account, card, transit or institution numbers
Then the system checks that IDV is not completed

IDENTITY VERIFICATION (PERSONA � FD-07b):
Then the chatbot responds: "I must verify your identity for payment security. Please click here to get started"
And the chatbot displays a "Get verified" button
When the user clicks on the button
Then the system checks IDV at Payment and consent
And the chatbot sends the Persona link
And the customer completes verification
And Persona returns: IDV PASS
Then the chatbot responds: "Your identity has been verified successfully. Let's proceed to finalize your claim."

CLAIM CONFIRMATION & CASE CREATION (GLOB-09):
Then the chatbot displays:
  "Please review your compensation details:
   Total Amount: GBP 1,560 (3 passengers x GBP 520), deposited in CAD
   Payment Method: Interac e-Transfer (c***@gmail.com)
   After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email.
   Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user responds "Yes"
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION & WRAP-UP (GLOB-11):
Then Adobe sends an eligible notification email to c***@gmail.com
And the email contains: Case Reference, GBP 1,560 Cash (paid in CAD via Interac e-Transfer), regulation (UK / EU 261), Flight AC 865 (LHR ? YUL), Code 65 Controllable, breakdown for 3 passengers, next steps, tracking link
Then the chatbot offers: "Is there anything I can help you with?" [I would like to � new flow] [No]
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

Given the case has been created for primary claimant "Catherine Bouchard" with PNR "TC079" covering 3 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay" mapped from chatbot intent
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "In Review" or "Done"
And the Created date and Last Updated date should be populated
And the SLA countdown should be tracking correctly against the EU261 SLA
And the Team assignment should be correct
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Decision Assist panel should NOT be greyed out
And the Claimant Name should be "Catherine Bouchard"
And the Claimant Type should be "Adult"
And the Authentication should be "Pass"
And the PNR should be "TC079"
And the PNR Creation Date, Journey ID, Booking Source and Booking Office ID should be populated
And the Regime should be "EU (UK)" with APPR also listed as applicable
And the Most Generous selection should be "EU/UK"
And all 3 passengers should be listed (Catherine Bouchard, Alexandre Bouchard, Sophie Bouchard)
And the Tags for the claimant should include "Claimant" and "Adult"
And the Email should be "c***@gmail.com"
And the Phone should be "+1***567"
And the Address should be populated
And the Aeroplan should be "9876543210" linked and in good standing (Basic Member)
And the Tier Status should be "Basic / Member"
And the Journey should show "Bound 1: LHR ? YUL" with claim filed for this flight
And the Disruption Code should show "Code 65 (FR � flight deck crew special request) � Controllable"
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "GBP 1,560 (GBP 520 x 3) � Cash, Interac e-Transfer in CAD"
And the AC Wallet option (GBP 1,872) should be visible as the offered alternative but NOT selected
And the APPR amount (CAD 1,200) should be shown as assessed but NOT applied
And the Decision Assist Panel should auto-appear for FD topic
And DDS should have run automatically with no agent action needed
And the eligibility decision should be pre-populated as "ELIGIBLE" (EU/UK, Code 65 Controllable, 5h delay, DELAY_GTE_4_HOURS)
And the Duplicate Check should have run automatically across all 3 passengers using baseline data "Catherine Bouchard + TC079 + LHR?YUL + FD"
And the result should be "No duplicate found"
And no Duplicate Warning Banner should be displayed
And the Related Cases tab should show no related cases
And the CyberSource result should be "GREEN"
And the case should have proceeded automatically and not be parked in Fraud Queue
And the Persona IDV result should be "PASS"
And the system should have appended the booking record to the case automatically
And Trip Tracer poll should NOT be required
And the agent should have used pull case from My Activities to get this case
And the case status should have transitioned from "Assigned" to "In Progress"
And a case acknowledgement notification should have been sent to the customer
And an eligible notification email should have been sent via Adobe containing GBP 1,560 Cash, Interac e-Transfer and Code 65
And the Agent Notes section should be accessible
And the Audit Log should record all actions with timestamps and before/after values
And Customer Communications should show the notification email chronologically
And the chatbot transcript should be accessible and linked
And the Attachments tab should be empty
And the Final Status should be "Resolved"
And the case should be in read-only mode with no editable Decision Assist fields
And the agent should not be able to access Case Search as it is for leads and management only

Given the customer's country of residence is "Canada"
Then the currency should be set to "CAD"
And the payment method should be set to "Interac e-Transfer"
And the customer has Aeroplan "9876543210" linked with Basic Member status in good standing
And both options should have been offered: Cash (GBP 1,560) AND AC Wallet (GBP 1,872 with 20% top-up)
And the customer selected "Cash" ? AC Wallet payout NOT dispatched
And only the Interac email "c***@gmail.com" should be collected (no banking details)
And the GBP 1,560 entitlement should be converted to CAD for the payout
And exactly one compensation record should be created with the CAD equivalent of GBP 1,560
And the record should be picked up by the daily evening batch file
And the record should be dispatched to Unifier
And in UAT the batch file should be triggered manually in coordination with the Unifier team
And Unifier should send an acknowledgement back
And the end-of-day report should be received from Interac
And the status should be "Pending" transitioning to "Cashed" or "Rejected" or "Expired"
And if the customer does not claim the Interac payment within 35 days the status should be set to "Expired"
And payment for this controllable EU/UK claim should be issued within 30 days of submission
And the Claims Dashboard Compensation tab should show the GBP entitlement, CAD paid amount, exchange rate, payment method (Cash � Interac e-Transfer) and status updated via talkback

Expected Results: DDS returns an EU eligible response for all 3 passengers (UK departure). Trip Tracer: Promise = 14:00, Actual = 19:00, Delay = 5 hours, MSL = Leg 1 (AC 865 LHR ? YUL), no cancellation code, arrival code 65 (FR) controllable, Fallback = FALSE, Regimes = EU (UK) + APPR, Most Generous = EU/UK. Compensation: GBP 520 x 3 = GBP 1,560 cash, paid in CAD by Interac to c***@gmail.com. AC Wallet (GBP 1,872) offered but not selected. APPR (CAD 1,200) not applied. CyberSource GREEN. Persona PASS.