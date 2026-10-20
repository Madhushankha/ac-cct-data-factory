Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation?"
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
And the user provides "Brigitte Pelletier"
Then the chatbot responds:
"Thanks, Brigitte! And, what is your booking reference number?"
And the user provides "PNR: TC113"
Then the chatbot searches Trip Tracer for PNR: TC113
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: b***@outlook.com
� Phone: +33***012
And the user selects "Email: b***@outlook.com"
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
� Brigitte Pelletier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Original: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 10, 2026 � CANCELLED
� Rebooked: Flight AC 872, Paris Charles de Gaulle (CDG) ? Ottawa (YOW), June 10, 2026 � COMPLETED
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction) = 5 years ? within limitation ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS checks: Is the current destination the same as the original destination?
And DDS compares: Original destination = YYZ (Toronto); Current destination = YOW (Ottawa) ? DIFFERENT DESTINATION
And DDS checks: Is YOW a sister city of YYZ? ? NO (Ottawa ? Toronto sister city)
And DDS determines: NEW DESTINATION (NEW CONTRACT) ? CANNOT ASSESS ? NO DETERMINATION
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC113
? Original Itinerary - Flight: AC 871, Route: CDG ? YYZ, Status: CANCELLED
? Current Itinerary - Flight: AC 872, Route: CDG ? YOW, Status: COMPLETED (new destination)
? Original Destination: YYZ (Toronto)
? Current Destination: YOW (Ottawa) � DIFFERENT CITY
? Sister City Check: YOW ? YYZ = NOT A VALID PAIR
? Contract Status: Original contract VOIDED; New contract issued for CDG?YOW
? Regime: EU 261 (EU origin � CDG)
? DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT
? Determination: NO DETERMINATION ? SENT TO AGENT
Flight Compensation:
? MS BRIGITTE PELLETIER | NO DETERMINATION | NEW_DESTINATION | PENDING AGENT REVIEW
NO FRAUD SCREENING (not triggered for No Determination)
NO DETERMINATION RESULT:
Then the chatbot displays:
"I've reviewed your flight details. Your original flight from Paris Charles de Gaulle (CDG) to Toronto (YYZ) was cancelled and you were rebooked to a different destination, Ottawa (YOW). Because the destination has changed, I'm unable to automatically assess your eligibility. I'll forward your claim to an agent who can review it manually. Would you like to proceed?"
And the user selects "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete."
And an alert information is displayed: "Claim forwarded for review!"
And the system appends the booking record to the case automatically
And the case is routed to the manual review team
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to b***@outlook.com
And the email contains: Case Reference, flight details (original CDG?YYZ cancelled, rebooked CDG?YOW), reason for manual review (new destination), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Brigitte Pelletier" with PNR "TC113"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending Agent Review"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "Manual Review Team"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should be greyed out or not applicable as it cannot assess new destination
    And the Claimant Name should be "Brigitte Pelletier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC113"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (EU origin � CDG)"
    And the Full Name should be "Brigitte Pelletier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "b***@outlook.com"
    And the Phone should be "+33***012"
    And the original journey should show "CDG ? YYZ" as cancelled
    And the rebooked journey should show "CDG ? YOW" as completed with new destination
    And the Sister City Check should show YOW and YYZ as NOT A VALID PAIR
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � DDS cannot assess"
    And the Decision Assist Panel should show DDS ran automatically but returned CANNOT ASSESS due to new destination
    And the determination should be "NO DETERMINATION" sent to agent
    And the Duplicate Check should have run automatically using baseline data "Brigitte Pelletier + TC113 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it is No Determination
    And the system should have appended the booking record automatically
    And the case should be routed to manual review team queue
    And the agent should pull the case for manual review
    And a No Determination notification email should have been sent to "b***@outlook.com" containing Case Reference and original CDG to YYZ cancelled and rebooked CDG to YOW and reason for manual review new destination
    And the Current Status should be "Pending Agent Review"
    And the case should NOT be in read-only mode as the agent can determine outcome
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to new destination
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-EU-ND-03. Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellation Code = 42; Controllable. CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against original promise (different endpoints). Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); EU 261; Routed to manual handling; DDS = FD-EU-ND-03.