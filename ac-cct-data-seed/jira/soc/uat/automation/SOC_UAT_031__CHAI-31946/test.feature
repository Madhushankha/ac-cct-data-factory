Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will bef used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to London was delayed by about 7 hours. I had to buy food and stay overnight at a hotel. Can I get reimbursed?"
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
� Flight: AC 855
� Route: Montreal (YUL) ? London Heathrow (LHR)
� Date: June 5, 2026
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
� Departing country: Canada ? Limitation = 730 days (2 years)
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
? Single-segment trip YUL?LHR on AC855 was delayed +6H 00M � origin NOT in UK (YUL = Canada)
? Regime: APPR (system determines � UK/EU does not apply to non-UK/EU departures)
? PASSENGERS: 1 � SEGMENTS: 1

Itinerary:
? Promised Itinerary � Flight: AC 855, Route: YUL ? LHR, Scheduled Dep: 06-Jun 20:00
? Current Itinerary � Flight: AC 855, Route: YUL ? LHR, Status: ARRIVED LATE, Scheduled Dep: 20:00 ? Actual: 07-Jun 02:00, Delay: +6H 00M

Standards of Care (1):
? SOC section present
? Geographic Check: Origin = YUL (Canada) � NOT UK ? UK regime does NOT apply
? Regime applied: APPR (system routes to applicable regime)
? Departure Delay Code: 64 (Flight Crew Shortage) � Controllable
? PASSENGER: [Name] | STATUS: depends on regime routing (ELIGIBLE under APPR � controllable ?2h / NOT_ELIGIBLE if evaluated under EU/UK only � geographic fail)

Passenger Claims:
? Intent: TRAVEL DISRUPTIONS | Sub-Intent: EXPENSES | Status: depends on regime routing

 GEOGRAPHIC ORIGIN CHECK � UK-SPECIFIC TEST:
� EU regime geographic check:
  - Origin airport: YUL (Montreal, Canada)
  - Origin country: CANADA
  - Is Canada an EU/EEA member state? ? NO 
  - Is Canada the United Kingdom? ? NO 
  - Result: ITINERARY DID NOT START IN UK ? NOT ELIGIBLE

   WHY SEPARATE FROM NE-06:
  After Brexit, the UK has its own version of EU261 (UK261 / "Retained EU Law").
  The system needs to check BOTH:
  - NE-06: Did the flight start in the EU/EEA? ? NO
  - NE-07: Did the flight start in the UK? ? NO
  
  These are separate checks because:
  - A flight from CDG (Paris) to YYZ qualifies under EU261 but NOT UK261
  - A flight from LHR (London) to YYZ qualifies under UK261 but NOT EU261
  - A flight from YYZ to LHR qualifies under NEITHER (non-EU carrier departing from non-EU)
  
  NE-06 tests the EU gate. NE-07 tests the UK gate specifically.
  In this case, YUL?LHR fails BOTH gates because Canada is neither EU nor UK.

� All further checks SKIPPED:
  ? Controllability � SKIPPED
  ? Notification � SKIPPED
  ? No-travel � SKIPPED

DDS RESPONSE CODE = SoC-EU-NE-07

Then the chatbot checks which airline company is it ? AC

NOT ELIGIBLE RESULT (SoC-03b):
Then the chatbot displays: "I've reviewed the details of your flight. Your flight AC 855 departed from Montreal (Canada), which is outside the United Kingdom. Under UK aviation regulations (retained EU261), expense reimbursement is only available for flights departing from a UK airport when operated by a non-UK carrier. Since your flight did not depart from the UK, your claim is not eligible under UK regulations. However, your flight may be eligible under Canadian regulations (APPR). Would you like us to check your eligibility under APPR instead?"

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-07 � UK Geographic Gate Failed Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the agent can edit Topic/Sub-topic but cannot switch between automated and non-automated
  And the Status is "Closed � Not Eligible"
  And the Created date is populated
  And the Last Updated date is populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And no banners are displayed (identified + authenticated, Auth Flow 1)
  And the Decision Assist panel is NOT greyed out
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the PNR Creation Date is populated
  And the Journey ID is populated
  And the Booking Source is populated
  And the Booking Office ID is populated
  And the Regime is "EU (UK-specific check)"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Address is populated
  And the Tier Status is "Regular"
  And the Itinerary shows Journey AC 855 YUL ? LHR as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Ancillary Fee section is present with no entries
  And the Eligibility section shows Journey = AC 855 YUL ? LHR
  And the Flight Leg at Fault is AC 855
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � geographic check failed)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Geographic Origin Check (UK) is "FAILED"
  And the Origin is "YUL (Montreal, Canada) � NOT UK"
  And the Destination is "LHR (London, UK) � UK ? (but origin matters for non-UK carriers)"
  And the Geographic Origin Check (EU) is "Also FAILED (Canada is NOT EU/EEA)"
  And the Controllability is "NOT EVALUATED (geographic gate failed)"
  And the Departure delay code is "64 (Flight Crew Shortage) � Controllable (present in flight data but never evaluated)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-NE-07"
  And the Regime Note is "May be eligible under APPR instead (Canadian departure)"
  And this is separate from NE-06 because after Brexit UK has its own version of EU261 (UK261 / Retained EU Law) so NE-06 tests the EU gate and NE-07 tests the UK gate specifically
  And YUL ? LHR fails BOTH gates because Canada is neither EU nor UK
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Applicable Regimes SOC Amount is "N/A"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Eligibility on Claims Dashboard is "NOT ELIGIBLE" with no compensation record and no payout section
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode
  And the agent cannot access Case Search (leads/management only)

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-07 � UK Geographic Gate Failed Not Eligible
  Given the case SoC-EU-NE-07 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-07. NOT ELIGIBLE. Itinerary originated from YUL (Canada), not from UK. UK regime requires UK origin. No receipt upload. No case creation.