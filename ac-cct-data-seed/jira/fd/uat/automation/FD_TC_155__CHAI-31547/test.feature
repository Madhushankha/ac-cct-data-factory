Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours. I'd like to check if I'm eligible for compensation"
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
And the user provides "Yonatan Weiss"
Then the chatbot responds:
"Thanks, Yonatan! And, what is your booking reference number?"
And the user provides "PNR: TC122"
Then the chatbot searches Trip Tracer for PNR: TC122
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is revealed � OAL EMPLOYEE BOOKING IDENTIFIER PRESENT
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: y***@elal.co.il
� Phone: +972***234
And the user selects "Email: y***@elal.co.il"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
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
� Yonatan Weiss (Adult) [OAL Employee]
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 084
� Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ)
� Date: June 1, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
EMPLOYEE CHECK:
Then the system checks: Is passenger an airline employee? ? YES (OAL employee booking identifier present)
Then the system determines: OAL EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes)
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC122
? Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M
? Passenger: OAL EMPLOYEE (OAL employee booking identifier present)
? Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies
? MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE
? Employee Check: OAL EMPLOYEE ? NOT ELIGIBLE (overrides all other checks)
Flight Compensation:
? MR YONATAN WEISS | NOT ELIGIBLE | EMPLOYEE_OAL | 0.00
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was delayed by 4 hours. However, based on our records, this booking is associated with an airline employee travel benefit. Employee bookings are not eligible for flight disruption compensation under the applicable regulations. We apologize for the inconvenience."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to y***@elal.co.il
And the email contains: Case Reference, flight details, not eligible reason (OAL employee booking), regulation reference, contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Yonatan Weiss" with PNR "TC122"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Yonatan Weiss"
    And the Authentication should be "Pass"
    And the PNR should be "TC122"
    And the Regime should be "ASL (Israel)" but employee exclusion applies
    And the Full Name should be "Yonatan Weiss"
    And the Tags should include "Claimant" and "Adult" and "OAL Employee"
    And the Email should be "y***@elal.co.il"
    And the Phone should be "+972***234"
    And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "OAL Employee � employee bookings excluded from all regimes"
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to OAL Employee booking overriding all other checks
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And CyberSource should NOT have been triggered
    And the system should have appended the booking record automatically
    And a not eligible notification email should have been sent to "y***@elal.co.il" containing Case Reference and flight details and not eligible reason OAL employee booking and regulation reference
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-02. Employee Check: OAL Employee flag = TRUE ? NOT ELIGIBLE (universal employee exclusion). Compensation: $0. Fraud Screening: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A. Regime Assessment: ASL = NE-02 (OAL Employee); APPR = NE (Employee); EU = NE (Employee). Claims Dashboard: Status = Closed � Not Eligible; Reason = OAL Employee; DDS = FD-ASL-NE-02.