Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My connecting flight on PAL was delayed and I arrived 4 hours late at my final destination, I want compensation"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Luc Beauchemin"
Then the chatbot responds:
"Thanks, Luc! And, what is your booking reference number?"
And the user provides "PNR: TC016"
Then the chatbot searches Trip Tracer for PNR: TC016
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: l***@gmail.com
� Phone: +1***567
And the user selects "Email: l***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "492817"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
"How many people are on your claim?"
And the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Luc Beauchemin (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Leg 1: AC 501 � Montreal (YUL) ? Toronto (YYZ) � June 25, 2026
� Leg 2: PAL 802 � Toronto (YYZ) ? Vancouver (YVR) � June 25, 2026
� Arrival Delay at final destination: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 legs)
Then the chatbot identifies: MSL = Leg 2 (PAL 802 YYZ?YVR) � longest leg / disrupted leg
Then the chatbot confirms segments with customer
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
??? SUB-SCENARIO A: PAL Coding PRESENT ???
TRIP TRACER UI VALIDATION (Sub-Scenario A):
Then the tester opens Trip Tracer UI for PNR: TC016 (Scenario A data)
? Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00
? Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M
? Regime: APPR
? MSL FLIGHT: PAL 802 � YYZ ? YVR � 42
? "Delayed due to Scheduled maintenance"
? Delay: +4H 00M � CONTROLLABLE
? PAL coding: PRESENT � Code 42 populated
? CRITICAL: DDS successfully reads PAL coding and classifies as Controllable
Flight Compensation:
? MR LUC BEAUCHEMIN | ELIGIBLE | DELAY_3_TO_LT_6_HOURS | CAD 400.00 | [expiry date]
DDS proceeds normally ? Eligible ? Payment flow continues as per TC_001
??? SUB-SCENARIO B: PAL Coding MISSING ???
TRIP TRACER UI VALIDATION (Sub-Scenario B):
Then the tester opens Trip Tracer UI for PNR: TC016 (Scenario B data)
? Promised Itinerary - Leg 1: AC 501 YUL?YYZ, Leg 2: PAL 802 YYZ?YVR, Scheduled Final Arrival: 18:00
? Current Itinerary - Leg 1: AC 501 YUL?YYZ (ON TIME), Leg 2: PAL 802 YYZ?YVR, Status: ARRIVED LATE, Actual: 22:00, Delay: +4H 00M
? Regime: APPR
? MSL FLIGHT: PAL 802 � YYZ ? YVR � BLANK/NULL
? Disruption reason: MISSING � no coding from PAL
? Delay: +4H 00M � Classification: UNABLE TO DETERMINE (no code)
? PAL coding: MISSING � Code field is BLANK/NULL
? CRITICAL: DDS cannot classify controllability without disruption code
Flight Compensation:
? MR LUC BEAUCHEMIN | PENDING REVIEW | DELAY_3_TO_LT_6_HOURS | AGENT REVIEW REQUIRED | [expiry date]
DDS MISSING CODING BEHAVIOUR:
Then DDS detects: MSL carrier = PAL, disruption code = NULL/BLANK
And DDS flags: UNABLE TO CLASSIFY � missing coding from interline partner
And DDS routes case to: AGENT REVIEW QUEUE (not auto-approved)
Then the chatbot responds:
"Thank you for providing your information. We've received your claim and it requires additional review by our team. A Customer Relations agent will review your case and follow up with you within 30 business days. You will receive a confirmation email with your case reference number."
And an alert information is displayed: "Claim submitted for review."
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "�lise Beaumont" with PNR "TC183"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the Claimant Name should be "�lise Beaumont"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC183"
    And the Regime should be "APPR"
    And the Operating Carrier should be "PAL"
    And the Ticketing Carrier should be "AC"
    And the Full Name should be "�lise Beaumont"
    And the Email should be "e***@gmail.com"
    And the Phone should be "+1***567"
    And the Aeroplan should be "Not linked"
    And the Journey should show "Bound 1: YUL ? MNL (AC 501, on time) ? MNL ? CEB (PAL 102, delayed)"
    And the Decision Assist Panel should show DDS ran automatically
    And the eligibility decision should be pre-populated
    And the MSL should be PAL 102
    And the Operating carrier PAL should be clearly displayed
    And the CyberSource result should be "GREEN"
    And the Final Status should be "Resolved"

PAYMENT VALIDATION
    Given Sub-Scenario A where PAL coding is present and DDS is eligible
    Then payment should be processed through the standard FD compensation flow
    And the customer's country of residence should be "Canada"
    And the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer"
    And the customer has no Aeroplan linked so only Cash should be offered with no AC Wallet option
    And the compensation amount should be "$400 CAD" for FD delay tier 3 to less than 6 hours under APPR NOT $900 which is the Denied Boarding tier
    And IDV should be completed via Persona and Persona should return IDV PASS
    And a compensation record should be created in the system
    And a daily batch file should be generated and dispatched to Unifier
    And the 35-day expiry rule should apply
    And the Claims Dashboard Compensation tab should show Amount $400 Currency CAD Method Cash Interac Status Pending or Completed
    And given Sub-Scenario B where PAL coding is missing and DDS is pending review
    Then no automated payment should be processed
    And no country of residence prompt should be displayed
    And no Cash vs AC Wallet check should be triggered
    And no payment method should be presented to the customer
    And no Persona IDV should be triggered
    And no CyberSource fraud screening should be triggered
    And no compensation record should be created in the automated pipeline
    And the case should be routed to agent queue for manual review
    And the Claims Dashboard Compensation tab should show Amount Pending Currency TBD Method TBD Status Awaiting Agent Review
    And any automated payment in Sub-Scenario B is a P1 defect

Expected Results:
Scenario A (PAL coding present): DDS returns FD-APPR-EL-01. Trip Tracer: Promise = 14:00 (14-day mark); Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Ticketing Carrier = AC; Disruption code present and mapped; Controllable. Compensation: $400 CAD. CyberSource: GREEN ? auto-approved. CRITICAL: DDS must correctly read and interpret PAL's disruption coding. Scenario B (PAL coding missing): DDS returns PENDING REVIEW. Trip Tracer: Promise = 14:00; Actual = 18:00; Delay = 4hrs; MSL = PAL 102 MNL?CEB; Operating Carrier = PAL; Disruption code = NULL/MISSING; Controllability = UNKNOWN. Case routed to agent queue. CRITICAL: DDS must NOT auto-approve or auto-deny. Agent must manually review. Verify DDS gracefully handles missing PAL data without errors.