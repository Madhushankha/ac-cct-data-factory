Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My Air Canada flight from Toronto to Calgary was delayed by about 6 hours. The airline says it was weather but I was at the airport and the weather was perfectly fine � other airlines were flying normally. I had to buy food and pay for a hotel. Can I get reimbursed?"
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
� Route: Toronto (YYZ) ? Calgary (YYC)
� Date: June 3, 2026
� Departure Delay: 6 hours
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
Then the chatbot checks: Filing deadline for APPR SOC per province
And the system calculates:
� Origin: YYZ (Ontario) ? Limitation = 730 days
� Destination: YYC (Alberta) ? Limitation = 730 days
� Days elapsed: 6 days ? Within limitation period ? PROCEED

Then the chatbot checks if there is triage data available? ? Yes

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATIONS:
Then the tester opens Trip Tracer UI for PNR
Trip Overview:
? PNR: [PNR Code]
? TYPE: REVENUE
? ?? Trip Completed, Disruption Detected � DISPUTED ? OVERRIDE APPROVED (PAY)
? Single-segment domestic trip YYZ?YYC on AC201 was delayed +8H 00M (note: prereqs say 8h/480 min, chatbot says 6h � use prereqs: 8h for Trip Tracer, chatbot displays 6h to user)
? Regime: APPR
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 201, Route: YYZ ? YYC, Scheduled Dep: 27-Jun 07:00
? Current Itinerary � Flight: AC 201, Route: YYZ ? YYC, Status: ARRIVED LATE, Scheduled Dep: 07:00 ? Actual: 15:00, Delay: +8H 00M

Standards of Care � Original Determination (1):
? SOC section present
? Original Departure Delay Code: 77 (Weather) � Uncontrollable
? Original DDS: SoC-APPR-NE-07 (NOT ELIGIBLE � weather, regular pax)
? PASSENGER: [Name] | STATUS: NOT_ELIGIBLE (original)

Override Section:
? Dispute Flag: YES
? Dispute Reason: Passenger disputes weather classification � claims weather was clear, other airlines operating normally
? Override Status: APPROVED ?
? Override Decision: PAY
? Override Reason: "Departure delay code 77 (Weather) was incorrectly assigned. Investigation confirms clear weather at YYZ on Jun 27, 2026. Other carriers operated normally. Actual cause was crew scheduling (Code 64 � controllable). Overriding to ELIGIBLE."
? Corrected Departure Delay Code: 64 (Flight Crew Shortage) � Controllable
? Original DDS Code: SoC-APPR-NE-07 (NOT ELIGIBLE)
? Overridden DDS Code: SoC-APPR-EL-08 (ELIGIBLE � controllable, transit delay ?2h)

Standards of Care � Post-Override (1):
? PASSENGER: [Name] | STATUS: ELIGIBLE (overridden) | BAND: DELAY_6_HOURS_OR_MORE | MEAL: $30.00 | ACCOMMODATION: Rate of day (max $500) | GENERAL EXPENSES: Transport $200 + Comm $30 + Parking $50 + Essentials $30 | EXPIRES: [date]
? CyberSource: GREEN (post-override)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: ELIGIBLE (Override Approved � Pay)
? Total Approved: $243.00 CAD (Hotel $170 + Meals $28 + Transport $45)
? Receipt Validation: 3 receipts processed, 4 line items, all PASSED, 0 flagged, 0 failed
? Payment: Canada ? EFT ? $243.00 CAD

DDS RESPONSE CODE = SoC-APPR-NE-07

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Unfortunately, your flight AC 201 from Toronto to Calgary was delayed due to weather conditions, which is classified as outside the airline's control. Under the applicable Canadian regulations (APPR), expense reimbursement is not available for disruptions caused by factors beyond the airline's control."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Dispute"

 DISPUTE FLOW:
Then the chatbot responds: "We understand. Your dispute has been recorded and a case has been created for our team to review manually. You will receive an update once our team has completed their review."

CASE CREATION WITH DISPUTE FLAG:
Then the system creates a case in Case Services
And the case includes:
� DDS response code: SoC-APPR-NE-07
� Original eligibility: NOT ELIGIBLE
� Dispute flag: YES 
� Dispute reason: Passenger disputes weather classification � claims weather was fine at airport, other airlines operating normally
� Status: DISPUTED � Pending Override Review
� Regime: APPR
And the case is assigned to the manual handling queue
And the case reference number is provided to the passenger

Then the chatbot provides:
"Your dispute reference number is: [Case Number]. You will receive an email confirmation shortly."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

 AGENT OVERRIDE FLOW � OVERRIDE APPROVED (PAY):
When the agent opens the case in Claims Dashboard
Then the agent reviews:
� Original DDS determination: SoC-APPR-NE-07 (NOT ELIGIBLE � weather)
� Passenger dispute: Claims weather was fine at airport, other airlines operating normally
� Agent investigates:
  - Reviews Departure delay code 77 (Weather)
  - Checks operational logs for June 3, 2026
  - Reviews weather reports for YYZ and YYC on June 3
  - Finds: Weather at YYZ was CLEAR on June 3 � no significant weather events
  - Finds: Other carriers (WestJet, Porter) operated YYZ?YYC flights on time
  - Finds: The actual cause was a CREW SCHEDULING issue (Code 41) that was
    INCORRECTLY coded as weather (Code 77)
  - Determines: Departure delay code was MISCLASSIFIED
  - Correct code should be: 41 (Crew Scheduling) ? CONTROLLABLE
  - With correct code: Regular passenger + Controllable ? ELIGIBLE

OVERRIDE DECISION � PAY: 
Then the agent determines: Override APPROVED � original determination overridden
� Departure delay code 77 (Weather) was INCORRECTLY assigned
� Actual cause: Crew scheduling (Code 41) � CONTROLLABLE
� Weather reports confirm clear conditions at YYZ on June 3
� Other carriers operated normally on same route
� Passenger's dispute is VALID
� Override to ELIGIBLE

Then the agent updates the case:
� Override Status: APPROVED 
� Override Decision: PAY
� Override Reason: "Departure delay code 77 (Weather) was incorrectly assigned. Investigation confirms clear weather at YYZ on June 3, 2026. Other carriers operated normally. Actual cause was crew scheduling (Code 41 � controllable). Overriding to ELIGIBLE."
� Original DDS Code: SoC-APPR-NE-07 (NOT ELIGIBLE)
� Overridden DDS Code: SoC-APPR-EL-08 (ELIGIBLE � controllable, transit delay)
� Case Status: In Progress (Override Approved � Welcome Back flow initiated)

FRAUD SCREENING � POST-OVERRIDE (GLOB-05):
Then the system sends case data to CyberSource for fraud screening (behind the scenes)
And CyberSource evaluates the claim
And CyberSource returns: GREEN (no fraud indicators detected)
? PROCEED to Welcome Back flow

WELCOME BACK NOTIFICATION:
Then the system sends a Welcome Back email to the passenger:
"Good news! After reviewing your dispute for flight AC 201 from Toronto to Calgary on June 3, 2026, we have determined that you are eligible for expense reimbursement. Please click the link below to complete your claim by uploading your receipts."
And the email includes:
� Deep link to chatbot with pre-populated claim data
� Case reference number
� Expiry date for completing the claim

WELCOME BACK FLOW � RECEIPT UPLOAD:
Then the passenger clicks the deep link
And the chatbot opens with pre-populated data:
"Welcome back, [First Name]! We've reviewed your dispute and determined that you are eligible for expense reimbursement for your flight AC 201 from Toronto to Calgary on June 3, 2026. To complete your claim, please upload your receipts."

ENTITLEMENT DISPLAY:
Then the chatbot displays the eligible expense categories based on  delay, 1 adult, PY class, APPR regime:
"Based on the length of your disruption (6 hours), you may be eligible for reimbursement in the following categories:
� Meals: up to $30.00
� Hotel accommodation: Rate of day (up to 3 nights, $500 maximum)
� Ground transportation: up to $200.00
� Communication: up to $30.00
� Parking: up to $50.00 (1 day maximum)
� Essential items: up to $30.00

Please note that all expenses must have been incurred during the disruption period and supported by valid receipts."

RECEIPT UPLOAD:
Then the chatbot responds:
"To process your claim, I'll need you to upload your receipts. Please upload photos or scans of your receipts for any expenses you incurred during the disruption."
And the chatbot displays the receipt upload interface
And the user uploads receipt images:
� Receipt 1: Hotel receipt � $170.00 CAD (1 night)
� Receipt 2: Meal receipt � $28.00 CAD (dinner)
� Receipt 3: Taxi receipt � $45.00 CAD (airport to hotel + hotel to airport)

RECEIPT READER � OCR VALIDATION (RR-01):
Then the system processes uploaded receipts through OCR (Agentic Receipt Reader)
And the OCR engine extracts line items from each receipt:

Receipt 1 � Hotel:
� Line item: Hotel stay, 1 night � $170.00 CAD
� Date: June 3, 2026
� Category: Hotel
� Within disruption window: YES ?
� Rate of day comparison: $170 vs rate of day ? WITHIN range ?
� Nights: 1 (within 3-night max) ?
� Amount: $170 < $500 cap ?
� OCR Result: PASS ?

Receipt 2 � Meals:
� Line item: Dinner � $28.00 CAD
� Date: June 3, 2026
� Category: Meals
� Within disruption window: YES ?
� Threshold check: $28 ? $30 ( meal entitlement) ?
� OCR Result: PASS ?

Receipt 3 � Transport:
� Line item 1: Taxi airport?hotel � $25.00 CAD
� Line item 2: Taxi hotel?airport � $20.00 CAD
� Total transport: $45.00 CAD
� Date: June 3-4, 2026
� Category: Transport
� Within disruption window: YES ?
� Threshold check: $45 ? $200 ?
� OCR Result: PASS ?

RECEIPT VALIDATION SUMMARY:
Then the system displays the OCR validation summary:
� Total receipts processed: 3
� Total line items extracted: 4
� Items PASSED: 4
� Items FLAGGED for agent review: 0
� Items FAILED: 0

EXPENSE BREAKDOWN:
� Hotel: $170.00 ?
� Meals: $28.00 ?
� Transport: $45.00 ?
� Communication: $0.00 (no receipt submitted)
� Parking: $0.00 (no receipt submitted)
� Essentials: $0.00 (no receipt submitted)
� TOTAL APPROVED: $243.00 CAD

CASE UPDATE (GLOB-09):
Then the system updates the existing case in Case Services
And the case now includes:
� Override: APPROVED 
� Overridden eligibility: ELIGIBLE
� Overridden DDS code: SoC-APPR-EL-08
� All approved line items with amounts
� Receipt images attached
� Fraud screening result: GREEN (post-override)
And the case reference number is confirmed to the passenger

Then the chatbot responds:
"Your claim has been submitted successfully. Here's a summary:
� Case Reference: [Case Number]
� Total claim amount: $243.00 CAD
� Categories: Hotel ($170.00), Meals ($28.00), Transport ($45.00)
� Note: Your dispute was reviewed and approved � your eligibility has been updated.

You will receive a confirmation email shortly with your case details and next steps."

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe
And an eligible confirmation email is sent to the passenger at t***@gmail.com
And the email includes:
� Case reference number
� Claim summary with approved amounts
� Note about dispute resolution
� Next steps for payment processing

CLAIMS PAYMENT FLOW:
Then the system initiates payment processing
And Case Services calculates:
� Approved amount: $243.00 CAD
� Payment method: Canada ? EFT

Then the chatbot responds:
"To complete your reimbursement, we'll need your payment details."
And the chatbot collects:
� Country of residence: Canada
� Payment method: EFT
� Bank details: [collected securely]

Then the chatbot responds:
"Your payment of $243.00 CAD will be processed via Electronic Funds Transfer. You should receive the funds within [X] business days."

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-APPR-OVERRIDE-APPROVED � Override Approved Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Resolved (Override Approved)"
  And the Team assignment transitioned from "Manual Handling" to "Resolved"
  And the Tags include "Claimant", "Adult", "Disputed", and "Override Approved"
  And the Itinerary shows Journey AC 201 YYZ ? YYC as the claimed flight
  And the Flight Status is "DELAYED (6 hours)"
  And the Eligibility section shows Disruption Reason (Original) "Weather (Code 77 � INCORRECT)"
  And the Disruption Reason (Corrected) is "Crew Scheduling (Code 41 � CONTROLLABLE)"
  And the Delay Minutes is 360 min (6 hours)
  And the Travel Status is "Travelled (delayed Departure)"
  And the Controllability (Original) is "UNCONTROLLABLE (Weather � Code 77)"
  And the Controllability (Corrected) is "CONTROLLABLE (Crew Scheduling � Code 41)"
  And the Original DDS Response Code is "SoC-APPR-NE-07 (NOT ELIGIBLE)"
  And the Overridden DDS Response Code is "SoC-APPR-EL-08 (ELIGIBLE)"
  And the Dispute is "YES"
  And the Override Status is "APPROVED (PAY)"
  And the Agent Decision is "Override approved � Departure delay code was misclassified"
  And the Investigation shows "Weather reports confirm clear conditions at YYZ. Other carriers operated normally on same route."
  And the Evidence includes "NavCanada data, weather reports, competitor flight logs"
  And the Corrected Code is "41 (Crew Scheduling � controllable)"
  And the Outcome is "ELIGIBLE (overridden from NOT ELIGIBLE)"
  And the Fraud Screening is "CyberSource GREEN (post-override)"
  And the Eligibility is "ELIGIBLE (via override)"
  And the Receipt Validator shows Hotel $170.00 APPROVED
  And the Receipt Validator shows Meals $28.00 APPROVED (?$30)
  And the Receipt Validator shows Transport $45.00 APPROVED (?$200)
  And the Receipt Validator shows Communication $0.00 No receipt
  And the Receipt Validator shows Parking $0.00 No receipt
  And the Receipt Validator shows Essentials $0.00 No receipt
  And the Total Approved is $243.00 CAD
  And the Items Flagged for Review is 0
  And the Welcome Back email was sent post-override
  And the Eligible confirmation email was sent with approved amounts
  And the note about dispute resolution is included
  And the Final Status is "Resolved (Override Approved)"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-APPR-OVERRIDE-APPROVED � Override Approved Eligible
  Given the case SoC-APPR-OVERRIDE-APPROVED has override APPROVED and is ELIGIBLE
  Then SOC payment is CASH ONLY (even for override, SOC does not offer AC Wallet)
  And the route is AC 201 YYZ ? YYC with delay 360 min (6 hrs) originally coded Weather (77) corrected to Crew (41)
  And the original DDS is SoC-APPR-NE-07 overridden to SoC-APPR-EL-08
  And CyberSource fraud screening is GREEN (post-override)
  And the Welcome Back email was sent and customer uploaded receipts
  And the entitlements for 1 adult PY no ACR are Meals $30, Hotel rate of day/$500 cap, Transport $200, Communication $30, Parking $50, Essentials $30
  And the approved receipts are Hotel $170 (vs $500 PASS), Meals $28 (vs $30 PASS), Taxi $45 (vs $200 PASS) totalling $243.00 CAD
  And the country of residence is Canada with currency CAD and payment method Interac via Unifier
  And $243.00 is less than $500 so no approval is needed
  And the batch file is sent to Unifier and end-of-day report is generated
  And the Claims Dashboard Compensation tab shows Amount $243.00 CAD, Type Cash, Method Interac
  And the Override tag is "APPROVED"
  And the Original DDS is SoC-APPR-NE-07 and Overridden is SoC-APPR-EL-08
  And the status is updated via talkback

EXPECTED RESULTS:
SoC-Override-Pay. ELIGIBLE. Emergency override resolved to Pay. Normal DDS evaluation skipped � override takes precedence. Override amounts applied (may differ from standard entitlements). Fraud screening GREEN. Full receipt upload + OCR + case creation + notification. Case flagged with override metadata. Even if normal DDS would have returned NOT ELIGIBLE, override Pay = ELIGIBLE.