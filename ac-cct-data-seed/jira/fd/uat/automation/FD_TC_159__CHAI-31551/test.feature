Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I flew from Toronto to Frankfurt but my connecting flight from Frankfurt to Tel Aviv was cancelled due to severe weather. I'm stuck in Frankfurt � I didn't go back to Toronto and I never made it to Tel Aviv. Can I get compensation?"
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
And the user provides "Talia Friedman"
Then the chatbot responds:
"Thanks, Talia! And, what is your booking reference number?"
And the user provides "PNR: TC127"
Then the chatbot searches Trip Tracer for PNR: TC127
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: t***@outlook.com
� Phone: +1***123
And the user selects "Email: t***@outlook.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629184"
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
� Talia Friedman (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Segment 1: Flight AC 873, Toronto (YYZ) ? Frankfurt (FRA), May 29, 2026 � COMPLETED
� Segment 2: Flight AC 9042, Frankfurt (FRA) ? Tel Aviv Ben Gurion (TLV), May 29, 2026 � CANCELLED
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 COMPLETED, Segment 2 CANCELLED
Then the chatbot determines: Claim applies to Segment 2 (AC 9042 FRA?TLV � CANCELLED)
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since scheduled departure of Leg 2
And the system calculates: Scheduled departure was May 29, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for ASL (Israel) = 7 years ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines applicable regime:
And the system checks: Origin airport = YYZ (Toronto, Canada) ? NOT Israel origin
And the system checks: Destination airport = TLV (Tel Aviv, Israel) ? Israel destination
And the system determines: ASL (Israel Aviation Services Law) applies
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC127
? Segment 1: Flight: AC 873, Route: YYZ ? FRA, Status: COMPLETED (on time)
? Segment 2: Flight: AC 9042, Route: FRA ? TLV, Status: CANCELLED (claim filed)
? Customer Status: NO TRAVEL - INCOMPLETE (stranded at FRA � did not return to YYZ, did not reach TLV)
? History - Customer stranded at mid-point FRA; no rebooking accepted; no return to origin
? Regime: ASL (Israel) (Israel destination � TLV)
? Destination: TLV (Israel)
? MSL FLIGHT: AC 9042 � FRA ? TLV � WEAT
? "Cancellation � severe weather"
? EXTRAORDINARY CIRCUMSTANCES (WEAT)
? Disruption Type: CANCELLATION (Leg 2, mid-journey)
? ASL: Extraordinary circumstances ? NOT ELIGIBLE
? Fallback: FALSE (cancellation code available)
Flight Compensation:
? MS TALIA FRIEDMAN | NOT ELIGIBLE | EXTRAORDINARY_CIRCUMSTANCES | 0.00
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your connecting flight AC 9042 from Frankfurt (FRA) to Tel Aviv Ben Gurion (TLV) on May 29, 2026 was cancelled. However, you are not eligible for compensation at this time. After a full review, we can confirm that severe weather was the primary reason. Since the cancellation was caused by extraordinary circumstances beyond the airline's control, compensation is not required under the applicable regulations. If you have travel insurance, you may want to contact your insurance provider to see if your policy offers any coverage for this situation."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to t***@outlook.com
And the email contains: Case Reference, flight details (Leg 2: FRA?TLV CANCELLED), not eligible reason (extraordinary circumstances � severe weather), travel status (No Travel - Incomplete), regulation reference (ASL), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Talia Friedman" with PNR "TC127"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And the Claimant Name should be "Talia Friedman"
    And the Authentication should be "Pass"
    And the PNR should be "TC127"
    And the Regime should be "ASL (Israel destination � TLV) + APPR"
    And the Full Name should be "Talia Friedman"
    And the Email should be "t***@outlook.com"
    And the Phone should be "+1***123"
    And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � WEAT � Leg 2 cancellation mid-journey � stranded at FRA � ASL"
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with WEAT and Leg 2 FRA to TLV and No Travel Incomplete and stranded at FRA
    And the Duplicate Check should have run automatically and the result should be "No duplicate found"
    And CyberSource should NOT have been triggered
    And the system should have appended the booking record automatically
    And a not eligible notification email should have been sent to "t***@outlook.com"
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-ASL-NE-12. Trip Tracer: Leg 1 = Completed; Leg 2 = CANCELLED; MSL = Leg 2 (AC 9042 FRA?TLV); Cancellation Code = WEAT (Extraordinary Circumstance); No Travel = Incomplete (stranded at FRA); Fallback = FALSE; ASL + APPR. CRITICAL: Potentially all three regimes (ASL + APPR + EU 261) � ALL NE (Extraordinary/Uncontrollable). Result: NOT ELIGIBLE, ILS 0. DDS = FD-ASL-NE-12.