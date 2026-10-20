Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from London to Toronto was delayed by about 7 hours. I had to buy food, pay for a hotel overnight, and take a taxi. Can I get reimbursed for what I spent?"
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
� Flight: AC 848
� Route: London Heathrow (LHR) ? Toronto (YYZ)
� Date: June 10, 2026
� Departure Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country: United Kingdom ? Limitation = 2,190 days (6 years)
� Days elapsed: Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected
? Single-segment trip LHR?YYZ on AC848 was delayed +7H 00M due to weather (uncontrollable � NOT CHECKED under EU)
? Regime: EU (LHR departure)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 848, Route: LHR ? YYZ, Scheduled Dep: 18-Jun 11:00
? Current Itinerary � Flight: AC 848, Route: LHR ? YYZ, Status: ARRIVED LATE, Scheduled Dep: 11:00 ? Actual: 18:00, Delay: +7H 00M

Standards of Care (1):
? SOC section present
? Departure Delay Code: 77 (Weather) � NOT CHECKED (EU does not evaluate controllability)
? PASSENGER: [Name] | STATUS: ELIGIBLE | BAND: DELAY_6_HOURS_OR_MORE | MEAL: �30.00 | ACCOMMODATION: Rate of day (max �500) | GENERAL EXPENSES: Transport �200 + Comm �30 + Parking �50 + Essentials �30 | EXPIRES: [date]
? CyberSource: GREEN
? CRITICAL: Weather = NOT ELIGIBLE under APPR (NE-07) but ELIGIBLE under EU (EL-01)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE
? Total Approved: �263.00 EUR (Hotel �170 + Meals �30 [capped] + Transport �49 + Comm �14)
? Flagged Items: 1 (meals exceeded �30 threshold � agent review required)

DDS RESPONSE CODE = SoC-EU-EL-01

Then the chatbot checks which airline company is it ? AC

FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes � not visible to passenger)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to eligible flow

ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "Great news! Based on the details of your flight, you are eligible for expense reimbursement. Your flight AC 848 from London to Toronto was delayed by approximately 7 hours. Under the applicable EU regulations (EC 261/2004), you may be reimbursed for reasonable expenses incurred during this disruption."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, EU regime:
"Based on the length of your disruption (7 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to �30.00
� Hotel accommodation: Rate of day (up to 3 nights, �500 maximum)
� Ground transportation: up to �200.00
� Communication: up to �30.00
� Parking: up to �50.00 (1 day maximum)
� Essential items: up to �30.00

 EU CURRENCY NOTE:
EU entitlements are calculated in EUR (or GBP for UK departures).
Receipts may be in any currency � Case Services handles conversion:
1. Receipt currency ? regime currency (EUR/GBP) for threshold comparison
2. Regime currency ? country of residence currency for payout display

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD � WELCOME BACK FLOW:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � �145.00 GBP (1 night near Heathrow)
� Receipt 2: Meal receipt � �38.00 GBP (dinner + breakfast)
� Receipt 3: Taxi receipt � �42.00 GBP (airport to hotel + hotel to airport)
� Receipt 4: Communication � �12.00 GBP (Wi-Fi + phone calls)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � �145.00 GBP
� Date: June 10, 2026
� Category: Hotel
� Within disruption window: YES ?
� Currency conversion: �145 GBP ? ~�170 EUR (for threshold comparison)
� Rate of day comparison: �170 vs rate of day (Heathrow area) ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: �170 < �500 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item 1: Dinner � �22.00 GBP
� Line item 2: Breakfast � �16.00 GBP
� Total meals: �38.00 GBP ? ~�45 EUR
� Date: June 10-11, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: �45 ? �30 ?  FLAGGED � exceeds �30 meal threshold
� OCR Result: FLAGGED FOR AGENT REVIEW 

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � �24.00 GBP
� Line item 2: Taxi hotel?airport � �18.00 GBP
� Total transport: �42.00 GBP ? ~�49 EUR
� Date: June 10-11, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: �49 ? �200 ?
� OCR Result: PASS ?

Receipt 4 � Communication:
� Line item 1: Wi-Fi � �7.00 GBP
� Line item 2: Phone calls � �5.00 GBP
� Total communication: �12.00 GBP ? ~�14 EUR
� Date: June 10, 2026
� Category: Communication
� Within disruption window: YES ?
� Threshold check: �14 ? �30 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 4
� Total line items extracted: 6
� Items PASSED: 5
� Items FLAGGED for agent review: 1 (meals exceed �30 threshold)
� Items FAILED: 0

 AGENT REVIEW REQUIRED:
Meal total (�45) exceeds �30 threshold by �15.
Agent must decide:
� Option A: Approve up to �30, reject �15 overage ? Approved meals = �30
� Option B: Approve full amount with justification (e.g., airport pricing)
� Option C: Reject entire meal receipt and request resubmission

EXPENSE BREAKDOWN (after agent review � assuming Option A):
� Hotel: �145.00 / �170.00 ?
� Meals: �25.50 / �30.00 ? (capped at �30 threshold)
� Transport: �42.00 / �49.00 ?
� Communication: �12.00 / �14.00 ?
� Parking: �0.00 / �0.00 (no receipt submitted)
� Essentials: �0.00 / �0.00 (no receipt submitted)
� TOTAL APPROVED: �263.00 EUR (displayed in country of residence currency for payout)

CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the system initiates payment processing
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Germany"
Then the chatbot responds: "Thank you for confirming. Based on the information provided, here is the total reimbursement you are eligible for:
� Hotel: �170.00
� Meals: �30.00 (capped at threshold)
� Transport: �49.00
� Communication: �14.00
� Total: �263.00 EUR"
Then the chatbot responds: "I am able to proceed to payment now. Please note that once you confirm, your reimbursement amount will be finalized. Would you like to proceed?"
And user responds: "Yes"
Then the system determines:
� Country = Germany
� Currency = EUR
� Payment Method = BSM � Email Payment (EUR)
� Processing Channel = HSBC
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
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: �263.00 EUR
Payment Method: t***@gmail.com
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps that will also include the password required to access the secure payment link, which will be sent in a separate email
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-EU-EL-01
� Eligibility: ELIGIBLE
� Regime: EU (EC 261/2004)
� Departure country: United Kingdom
� Currency: GBP (receipts) ? EUR (threshold comparison) ? EUR (payout)
� All approved line items with amounts
� Flagged item: Meals capped at �30 (excess �15 rejected)
� Receipt images attached
� Fraud screening result: GREEN
� Country of residence: Germany | Currency: EUR
� Payment method: BSM � Email Payment (EUR) via HSBC | Payment email: t***@gmail.com | Phone: +1***789
� IDV: Persona PASS
� Note: Weather disruption (Code 77) � would be NOT ELIGIBLE under APPR but ELIGIBLE under EU (no controllability check)
And the case reference number is provided to the passenger
Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: �263.00 EUR
� Categories: Hotel (�170.00), Meals (�30.00 � capped at threshold), Transport (�49.00), Communication (�14.00)
� Note: Your meal expenses exceeded the maximum threshold of �30.00. The approved amount has been adjusted accordingly.
You will receive a confirmation email shortly with your case details and next steps."
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com
And the email includes:
� Case reference number
� Claim summary with approved amounts (EUR)
� Note about meal threshold cap
� Next steps for payment
� Password required to access the secure payment link
And a separate email containing the secure BSM payment link is sent to t***@gmail.com
END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."


CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-EL-01 � EU Eligible Travel Completed Flagged Meal
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "In Progress (flagged item requires agent review)"
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
  And the Itinerary shows Journey AC 849 LHR ? YYZ as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 849 LHR ? YYZ
  And the Flight Leg at Fault is AC 849
  And the Operating Carrier is AC
  And the Disruption Reason is "Weather (Code 77)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Passenger Type is "Regular"
  And the Geographic Check is "PASSED ? (LHR = UK origin)"
  And the Controllability is "NOT CHECKED (EU regime � controllability irrelevant)"
  And the Overnight Eligible is "YES (delay >330 min)"
  And the Class of Booking is "PY"
  And the Revenue Booking is "YES"
  And the ACR Issued shows Hotel No, Transport No, Meal No
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-EL-01"
  And the Fraud Screening is "CyberSource GREEN"
  And the Eligibility is "ELIGIBLE"
  And the same passenger, same flight, same disruption under APPR would be SoC-APPR-NE-07 (NOT ELIGIBLE � weather is uncontrollable) but under EU is SoC-EU-EL-01 (ELIGIBLE � controllability not checked)
  And the Receipt Validator shows Hotel �145.00 / �170.00 APPROVED (1 night, within rate of day, <�500 cap)
  And the Receipt Validator shows Meals �38.00 / �45.00 FLAGGED (exceeds �30 threshold by �15 � agent decision required: approve up to �30, approve full with justification, or reject)
  And the Receipt Validator shows Transport �42.00 / �49.00 APPROVED (?�200)
  And the Receipt Validator shows Communication �12.00 / �14.00 APPROVED (?�30)
  And the Receipt Validator shows Parking �0.00 No receipt
  And the Receipt Validator shows Essentials �0.00 No receipt
  And the Total Approved is �263.00 EUR (after meal cap at �30)
  And the Items Flagged for Review is 1 (meals � agent decision required)
  And the Applicable Regimes SOC Amount is "�263.00 EUR (EU � Suggested Highlighted)"
  And receipts are in GBP converted to EUR for threshold comparison with payout in country of residence currency
  And the Duplicate Check result is "No duplicate found"
  And CyberSource result is "GREEN"
  And the Country of Residence is "Germany" with Currency "EUR"
  And the Payment Method is "BSM � Email Payment (EUR)" with Processing Channel "HSBC"
  And the Payment Email is "t***@gmail.com" (confirmed, locked)
  And the Phone is confirmed as "+1***789"
  And no bank details / IBAN are stored on the case
  And the IDV result is "Persona PASS (at Payment)"
  And the secure payment link email and password email were sent to "t***@gmail.com"
  And the case Status is "In Progress (flagged item � NOT read-only until agent resolves meal flag)"

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-EL-01 � EU Eligible Flagged Meal � BSM HSBC EUR
  Given the case SoC-EU-EL-01 is determined as ELIGIBLE
  Then SOC payment is CASH ONLY
  And AC Wallet / e-credit is NOT offered
  And the route is AC 848 LHR ? YYZ with delay 420 min (7 hrs) for 1 adult PY
  And receipts are in GBP with threshold comparison in EUR
  And the entitlements are Meals �30, Hotel rate of day/�500 cap, Transport �200, Comm �30, Parking �50, Essentials �30
  And the approved receipts are Hotel �170, Meals �30 (capped from �45), Taxi �49, Comm �14 totalling �263.00 EUR
  And the country of residence is Germany with currency EUR
  And the payment method is BSM � Email Payment (EUR) processed via HSBC
  And only the customer's email t***@gmail.com and phone confirmation are collected (no bank details)
  And the payment email cannot be changed after confirmation
  And Persona IDV returned PASS before claim submission
  And no payout currency conversion is applied (EUR ? EUR)
  And the Comp Status is "Pending agent review" until the meal flag is resolved
  And after the agent approves the �30 cap, the Comp Status is "Sent for issuance"
  And the Claims Dashboard shows �263.00 EUR, Cash, BSM (HSBC), t***@gmail.com, status via talkback

EXPECTED RESULTS:
SoC-EU-EL-01. ELIGIBLE. No travel (origin), delay ?2h. Controllability NOT checked (EU regime difference from APPR). Eligible regardless of disruption type. Entitlements in EUR. Full receipt + case flow.