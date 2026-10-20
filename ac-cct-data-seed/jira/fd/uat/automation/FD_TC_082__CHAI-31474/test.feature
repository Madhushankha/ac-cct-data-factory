Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Montreal to Toronto but my connecting flight from Toronto to Vancouver was cancelled due to a safety issue and I didn't take any replacement. Can I get compensation?"
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
And the user provides "Jacques Fortier"
Then the chatbot responds:
"Thanks, Jacques! And, what is your booking reference number?"
And the user provides "PNR: TC045"
Then the chatbot searches Trip Tracer for PNR: TC045
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: j***@gmail.com
� Phone: +1***901
And the user selects "Email: j***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "518293"
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
� Jacques Fortier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Segment 1: Flight AC 476, Montreal (YUL) ? Toronto (YYZ), June 1, 2026 � COMPLETED
� Segment 2: Flight AC 477, Toronto (YYZ) ? Vancouver (YVR), June 1, 2026 � CANCELLED
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 477 YYZ?YVR � CANCELLED)
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of cancelled segment
And the system calculates: Scheduled departure was June 1, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 1, 2026; filing June 15, 2026 ? 14 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC045
? Segment 1: Flight: AC 476, Route: YUL ? YYZ, Status: COMPLETED
? Segment 2: Flight: AC 477, Route: YYZ ? YVR, Status: CANCELLED (claim filed)
? Customer Status: NO TRAVEL - INCOMPLETE (started journey, stranded at connection YYZ)
? History - No rebooking accepted for connecting segment
? Regime: APPR (1 regime)
? MSL FLIGHT: AC 477 � YYZ ? YVR � PERF
? "Cancellation � safety regulation"
? SAFETY (PERF)
? Disruption Type: CANCELLATION (mid-journey)
? DDS Gate 9: Safety ? NOT ELIGIBLE under APPR
? Fallback: FALSE (cancellation code available)
Flight Compensation:
? MR JACQUES FORTIER | NOT ELIGIBLE | SAFETY | CAD 0.00
FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your connecting flight AC 477 from Toronto (YYZ) to Vancouver (YVR) on June 1, 2026 was cancelled. However, you are not eligible for expense reimbursement for this cancellation. After a full review, we can confirm that a safety regulation requirement was the primary reason. Since the cancellation was caused by safety concerns, safety-related factors are within the airline's control but required for safety and aren't covered under the compensation regulations APPR. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to j***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (safety � safety regulation), travel status (No Travel - Incomplete), regulation reference (APPR), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Jacques Fortier" with PNR "TC045"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Jacques Fortier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC045"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Jacques Fortier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "j***@gmail.com"
    And the Phone should be "+1***901"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: YUL ? YYZ" as completed and "Segment 2: YYZ ? YVR" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Safety � Code 81"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Safety Code 81 safety regulation
    And the Duplicate Check should have run automatically using baseline data "Jacques Fortier + TC045 + YYZ?YVR + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to Safety PERF
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS: FD-APPR-NE-18. Seg 1 AC 476 YUL?YYZ Completed. Seg 2 AC 477 YYZ?YVR CANCELLED. Cancellation code = PERF (Safety). MSL = Leg 2 (YYZ?YVR). No Travel = TRUE, Status = Incomplete (stranded at YYZ). No Travel Gate: MSL cancelled ? YES ? Check controllability. Controllability: PERF = Safety ? No cash compensation. Outcome: Expenses + pro-rated/full ticket refund, $0 cash. Fraud: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A. APPR = NE-18 (No Travel Incomplete + Safety); EU = N/A; ASL = N/A.