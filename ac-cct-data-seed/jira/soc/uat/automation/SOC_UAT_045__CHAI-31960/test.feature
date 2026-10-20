Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
""Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?""
Then user selects English
Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice.""
Then chatbot asks ""How can I help you today?""
And the user says ""My flight from Paris to Montreal took off but had to turn around and come back to Paris. The flight was cancelled after we returned. I was stuck at the airport for about 16 hours and had to pay for food, a hotel, and a taxi. Can I get reimbursed?""
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO
SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
""Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?""
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
""I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you.""
And the chatbot responds:
""Please provide your full name exactly as it appears on your ticket, including any middle names if applicable.""
And the user provides ""[First Name] [Last Name]""
Then the chatbot responds:
""Thanks, [First Name]! And, what is your booking reference number?""
And the user provides ""PNR: [PNR Code]""
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
""To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?""
And the chatbot displays options:
Email: t***@gmail.com
Phone: +1***789
And the user selects ""Email: t***@gmail.com""
Then the chatbot responds:
""I've sent a verification code to your email, please enter it within 15 minutes of receiving it.""
And the user provides the OTP code ""546879""
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
""Your verification was successful. Let's proceed to the next step.""
Then the chatbot checks if this PNR a group booking ? No
Then the chatbot checks if there are multiple PAX on PNR? ? No
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
""I found the following journey:
Flight: AC 856
Route: Paris Charles de Gaulle (CDG) ? Montreal (YUL)
Date: June 21, 2026
Status: DIVERTED � Returned to origin (CDG). Flight cancelled. Rebooked next day.
Is this the journey you'd like to check?""
And the user confirms ""Yes""
Then the chatbot checks if there are more than 1 segment ? No (single leg)
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
Departing country: France ? Limitation = 1,825 days (5 years)
Days elapsed: Within limitation period ? PROCEED
Then the chatbot checks if there is triage data available? ? Yes
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Not Completed, Disruption Detected
? Single-segment trip CDG?YUL on AC856 was diverted � returned to origin (CDG), then cancelled. Passenger returned to CDG, rebooked 16 hours later.
? Regime: EU (CDG departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 856, Route: CDG ? YUL, Scheduled Dep: 21-Jun 14:00
? Current Itinerary � Flight: AC 856, Route: CDG ? YUL, Status: DIVERTED � Returned to origin (CDG), CANCELLED, rebooked

Standards of Care (1):
? SOC section present
? Diversion + cancellation ? | SOC Segment Delay: 960 min (16h) ? ?2h ?
? Controllability: NOT CHECKED (EU regime)
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: �60.00 | ACCOMMODATION: Rate of day (max �500) | GENERAL EXPENSES: Transport �200 + Comm �30 + Parking �50 + Essentials �30 | EXPIRES: [date]
? CyberSource: GREEN

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: �303.00 EUR (Hotel �165 + Meals �55 + Transport �58 + Essentials �25)
DDS RESPONSE CODE = SoC-EU-EL-05
Then the chatbot checks which airline company is it ? AC
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes)
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow
ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: ""Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 856 from Paris to Montreal was diverted back to Paris and subsequently cancelled. You were unable to travel for approximately 16 hours. Under the applicable EU regulations (EC 261/2004), you may be reimbursed for reasonable expenses incurred during this disruption.""
ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, no ACR:
""Based on the length of your disruption (16 hours), you may be eligible for reimbursement in the following categories:
Meals: up to �60.00
Hotel accommodation: Rate of day (up to 3 nights, �500 maximum)
Ground transportation: up to �200.00
Communication: up to �30.00
Parking: up to �50.00 (1 day maximum)
Essential items: up to �30.00
Please note that all expenses must have been incurred during the disruption period and supported by valid receipts.""
RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
""To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption.""
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
Receipt 1: Hotel receipt � �165.00 EUR (1 night near CDG)
Receipt 2: Meal receipt � �55.00 EUR (dinner + breakfast + snack)
Receipt 3: Taxi receipt � �58.00 EUR (airport to hotel + hotel to airport)
Receipt 4: Essential items � �25.00 EUR (toiletries)
RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
Receipt 1 � Hotel:
Line item: Hotel stay, 1 night � �165.00 EUR
Date: June 21, 2026
Category: Hotel
Within disruption window: YES ?
Rate of day comparison: �165 vs rate of day (CDG area) ? WITHIN range ?
Nights: 1 ? | Amount: �165 < �500 cap ?
OCR Result: PASS ?
Receipt 2 � Meals:
Line item 1: Dinner � �25.00 EUR
Line item 2: Breakfast � �18.00 EUR
Line item 3: Snack � �12.00 EUR
Total meals: �55.00 EUR
Within disruption window: YES ?
Threshold check: �55 ? �60 ?
OCR Result: PASS ?
Receipt 3 � Transport:
Line item 1: Taxi airport?hotel � �32.00 EUR
Line item 2: Taxi hotel?airport � �26.00 EUR
Total transport: �58.00 EUR
Within disruption window: YES ?
Threshold check: �58 ? �200 ?
OCR Result: PASS ?
Receipt 4 � Essentials:
Line item: Toiletry kit � �25.00 EUR
Within disruption window: YES ?
Threshold check: �25 ? �30 ?
OCR Result: PASS ?
RECEIPT VALIDATION SUMMARY:
Total receipts processed: 4
Total line items extracted: 7
Items PASSED: 7 | Items FLAGGED: 0 | Items FAILED: 0
EXPENSE BREAKDOWN:
Hotel: �165.00 ?
Meals: �55.00 ?
Transport: �58.00 ?
Communication: �0.00 (no receipt)
Parking: �0.00 (no receipt)
Essentials: �25.00 ?
TOTAL APPROVED: �303.00 EUR
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the system initiates payment processing
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Germany"
Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible for:
� Hotel: �165.00
� Meals: �55.00
� Transport: �58.00
� Essentials: �25.00
� Total: �303.00 EUR"
Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed?"
And user responds: "Yes"
Then the system determines:
� Country = Germany | Currency = EUR
� Payment Method = BSM � Email Payment (EUR) | Processing Channel = HSBC
� Payout currency conversion = Not required (EUR ? EUR)
BSM OFFER (DEFAULT � EU / HSBC):
Then the chatbot responds:
"Before we move forward, please confirm the email address where you'd like to receive your payment and all updates about this case. Would you like to use t***@gmail.com?
Please note that only one email address can be used for this reimbursement and it can't be changed once confirmed."
And the chatbot displays options:
� Yes, confirm this email
� Use a different email
And the user selects "Yes, confirm this email"
Then the chatbot asks: "Great, can you please confirm that we have the right phone number on the file +1***789?"
And the chatbot displays options:
� Yes, confirm this phone number
� Use a different phone number
And the user selects "Yes, confirm this phone number"
Then system checks if IDV has been done already ? No
IDENTITY VERIFICATION � PERSONA:
Then the chatbot responds:
"Before we process your payment, we need to verify your identity. You will receive a separate link to complete identity verification through our secure partner."
And the chatbot sends Persona IDV link to the customer
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: �303.00 EUR
Payment Method: t***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-EU-EL-05
� Eligibility: ELIGIBLE | Regime: EU (EC 261/2004)
� Departure country: France
� Currency: EUR (receipts) ? EUR (threshold) ? EUR (payout)
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN
� Country of residence: Germany | Currency: EUR
� Payment method: BSM � Email Payment (EUR) via HSBC | Payment email: t***@gmail.com | Phone: +1***789
� IDV: Persona PASS
And the case reference number is provided to the passenger
Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: �303.00 EUR
� Categories: Hotel (�165.00), Meals (�55.00), Transport (�58.00), Essentials (�25.00)
You will receive a confirmation email shortly with your case details and next steps."
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to t***@gmail.com
And the email includes: Case reference number, claim summary (EUR), EU 261/2004 reference, flight details (AC 856 CDG?YUL DIVERTED/CANCELLED), next steps for payment, password required to access the secure payment link
And a separate email containing the secure BSM payment link is sent to t***@gmail.com
END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-EL-05 � EU Eligible No Travel Returned to Origin CDG Diverted Cancelled
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And no banners are displayed (Auth Flow 1)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU (EC 261/2004)"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 856 CDG ? YUL as the claimed flight (single leg, 1 segment)
  And the Flight Status is "DIVERTED � Returned to origin (CDG). Flight cancelled. Rebooked next day."
  And the Eligibility section shows Journey = AC 856 CDG ? YUL
  And the Flight Leg at Fault is AC 856
  And the Operating Carrier is AC
  And the Disruption Reason is "Flight cancelled (IRRELEVANT under EU SOC)"
  And the Delay Minutes is 960 min (16 hours)
  And the Travel Status is "No Travel � Returned to Origin (CDG)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (CDG = France, EU origin)"
  And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant)"
  And the Cancellation Check is "CANCELLED ? (flight diverted back + cancelled)"
  And the Departure Delay is "?2h (16 hours) ?"
  And the Overnight Eligible is "YES (delay >360 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-EL-05"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the Check Order is: 1. Pax Type ? Regular ? ? 2. No-travel check ? Flight cancelled ? ? Departure delay ?2h ? ? ELIGIBLE
  And the key difference from EL-04 is EL-04 stayed at origin (never departed) while EL-05 departed, diverted back, returned to origin � both result in "No Travel" but the travel status variant is different (Origin vs Return)
  And under APPR outcome depends on controllability � if uncontrollable (e.g., weather) ? NE-10, if Safety ? EL-03/04 � but under EU eligible regardless
  And the Entitlements for 1 adult PY no ACR show Meals $60 (EUR equivalent), Hotel rate of day max 3 nights $500 cap, Transport $200, Communication $30/pax, Parking $50 1 day max, Essentials $30/pax
  And the Receipt Validator shows Hotel �165 APPROVED
  And the Receipt Validator shows Meals �55 APPROVED
  And the Receipt Validator shows Transport �58 APPROVED
  And the Receipt Validator shows Essentials �25 APPROVED
  And the Total Approved is �303.00 EUR
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Booking Auto-Append shows the system appended the booking record automatically
  And the Eligible confirmation email was sent
  And the email contains Case Reference, approved amounts, EU 261/2004, flight details (AC 856 CDG ? YUL DIVERTED/CANCELLED)
  And the Country of Residence is "Germany" with Currency "EUR"
  And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC"
  And the Payment Email is "t***@gmail.com" (confirmed, locked)
  And the Phone is confirmed as "+1***789"
  And no bank details / IBAN are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And the eligible confirmation email (with password) and secure payment link email were sent to "t***@gmail.com"
  And the Final Status is "Resolved"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-EL-05 � EU Eligible No Travel Returned to Origin CDG � BSM HSBC EUR
  Given the case SoC-EU-EL-05 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered
  And the route is AC 856 CDG ? YUL DIVERTED + CANCELLED for 1 adult PY
  And the approved receipts are Hotel �165, Meals �55, Taxi �58, Essentials �25 totalling �303.00 EUR
  And the country of residence is Germany with currency EUR
  And the payment method is BSM � Email Payment (EUR) processed via HSBC
  And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details / IBAN)
  And the payment email cannot be changed after confirmation
  And Persona IDV returned PASS before claim submission
  And no currency conversion is applied (EUR receipts ? EUR payout)
  And the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows �303.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback
EXPECTED RESULTS:
SoC-EU-EL-05. ELIGIBLE. No travel (return), flight cancelled. Controllability NOT checked. Full receipt + case flow.