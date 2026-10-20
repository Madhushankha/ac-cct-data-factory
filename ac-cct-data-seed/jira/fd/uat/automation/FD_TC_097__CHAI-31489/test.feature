Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was cancelled and I was rebooked to Ottawa instead. Can I get compensation?"
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
And the user provides "Laurent Mercier"
Then the chatbot responds:
"Thanks, Laurent! And, what is your booking reference number?"
And the user provides "PNR: TC056"
Then the chatbot searches Trip Tracer for PNR: TC056
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: l***@outlook.com
� Phone: +1***345
And the user selects "Email: l***@outlook.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "739281"
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
� Laurent Mercier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Original: Flight AC 499, Montreal (YUL) ? Toronto (YYZ), June 9, 2026 � CANCELLED
� Rebooked: Flight AC 500, Montreal (YUL) ? Ottawa (YOW), June 9, 2026 � COMPLETED
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 9, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 9, 2026; filing June 15, 2026 ? 6 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS checks: Is the current destination the same as the original destination?
And DDS compares: Original destination = YYZ (Toronto); Current destination = YOW (Ottawa) ? DIFFERENT DESTINATION
And DDS checks: Is YOW a sister city of YYZ? ? NO (YOW is Ottawa, not a sister city of Toronto)
And DDS determines: NEW DESTINATION (NEW CONTRACT) ? CANNOT ASSESS ? NO DETERMINATION
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC056
? Original Itinerary - Flight: AC 499, Route: YUL ? YYZ, Status: CANCELLED
? Current Itinerary - Flight: AC 500, Route: YUL ? YOW, Status: COMPLETED (new destination)
? Original Destination: YYZ (Toronto)
? Current Destination: YOW (Ottawa) � DIFFERENT CITY
? Sister City Check: YOW ? YYZ = NOT A VALID PAIR (Ottawa ? Toronto sister city)
? Contract Status: Original contract VOIDED; New contract issued for YUL?YOW
? DDS: CANNOT ASSESS � NEW DESTINATION / NEW CONTRACT
? Regime: APPR (1 regime)
? Determination: NO DETERMINATION ? SENT TO AGENT
Flight Compensation:
? MR LAURENT MERCIER | NO DETERMINATION | NEW_DESTINATION | PENDING AGENT REVIEW
NO FRAUD SCREENING (not triggered for No Determination)
NO DETERMINATION RESULT:
Then the chatbot displays:
"I've reviewed your flight details. Your original flight from Montreal (YUL) to Toronto (YYZ) was cancelled and you were rebooked to a different destination, Ottawa (YOW). Because the destination has changed, I'm unable to automatically assess your eligibility. I'll forward your claim to an agent who can review it manually. Would you like to proceed?"
And the user selects "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been forwarded to our team for review. You will receive an update via email once the review is complete."
And an alert information is displayed: "Claim forwarded for review!"
And the system appends the booking record to the case automatically
And the case is routed to the manual review team
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a No Determination notification email is sent to l***@outlook.com
And the email contains: Case Reference, flight details (original YUL?YYZ cancelled, rebooked YUL?YOW), reason for manual review (new destination), next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Laurent Mercier" with PNR "TC056"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Forwarded � Manual Review"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be "Manual Review Team"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel may be restricted as it is pending manual review
    And the Claimant Name should be "Laurent Mercier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC056"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Laurent Mercier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "l***@outlook.com"
    And the Phone should be "+1***345"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Original: YUL ? YYZ" as cancelled and "Rebooked: YUL ? YOW" as completed with new destination
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "New destination / new contract � cannot auto-assess"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run but returned "NO DETERMINATION" due to destination mismatch YYZ not equal to YOW and not a sister city pair
    And the eligibility decision should be "PENDING AGENT REVIEW"
    And the Duplicate Check should have run automatically using baseline data "Laurent Mercier + TC056 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it is pending manual review
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the case should be routed to Manual Review Team
    And a No Determination notification email should have been sent to "l***@outlook.com"
    And the email should contain the Case Reference and flight details showing original YUL to YYZ cancelled and rebooked YUL to YOW and reason for manual review being new destination and next steps and tracking link
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and No Determination routing with timestamps
    And Customer Communications should show the No Determination notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Case Status should be "Forwarded � Manual Review" pending agent review
    And the case should NOT be in read-only mode as it is pending manual review team action
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given no determination was made due to new destination mismatch
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved

Expected Results:
DDS returns FD-APPR-ND-03. Trip Tracer: Leg 1 = Operated; Leg 2 = CANCELLED; MSL = Leg 2; Original destination = YVR; Actual destination = YEG (different); Cancellation Code = 42; Controllable. CRITICAL: Destination changed from YVR to YEG � DDS cannot calculate delay against the original promise because the endpoints are different. Automated delay = meaningless (comparing arrival at two different cities). Claims Dashboard: No Determination; Reason = Destination changed post-disruption (YVR ? YEG); Routed to manual handling; Agent must assess whether new destination satisfies original travel need; DDS = FD-APPR-ND-03.