BACKGROUND � ORIGINAL CASE (Previously Completed):
Given a case was previously created and completed:
? Original Case Reference: CASE-FD-20260501-002
? Claimant: Catherine Bouchard (filed for herself only)
? PNR: TC198
? Passengers on PNR: Catherine Bouchard (Adult) + Marc Bouchard (Adult)
? Journey: YUL ? YYZ, May 1, 2026, delayed 4h
? Regime: APPR
? Decision: ELIGIBLE � $400 CAD (Catherine Bouchard only)
? Payment: Interac e-Transfer � $400 CAD PAID to Catherine (May 14, 2026)
? Case Status: CLOSED
? NOTE: Catherine filed for herself ONLY. Marc was on the same PNR but was NOT included in Catherine's claim.
SECOND CLAIM � MARC FILES FOR BOTH:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto on May 1st was delayed 4 hours. I'd like to file a compensation claim for myself and my wife"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO (Marc is a passenger on the PNR)
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Marc Bouchard"
Then the chatbot responds:
"Thanks, Marc! And, what is your booking reference number?"
And the user provides "PNR: TC198"
Then the chatbot searches Trip Tracer for PNR: TC198
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +1***345
And the user selects "Email: m***@gmail.com"
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
"I found 2 passengers on this booking:
� Marc Bouchard (Adult)
� Catherine Bouchard (Adult)
Who would you like to include?"
And the user selects BOTH passengers (Marc + Catherine)
Then the chatbot checks: PAX count on PNR = 2 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 422
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 1, 2026
� Arrival Delay: 4 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10) � PER-PASSENGER DUPLICATE CHECK:
Then the chatbot sends request to Case Services for duplicate check
And Case Services checks EACH PASSENGER INDIVIDUALLY:
MARC BOUCHARD � DUPLICATE CHECK:
? PNR: TC198 + Passenger: Marc Bouchard + Flight: AC 422 + Date: May 1, 2026
? Existing Case for Marc on this flight: NONE FOUND
? Marc's Duplicate Status: NOT A DUPLICATE � NEW CLAIM
CATHERINE BOUCHARD � DUPLICATE CHECK:
? PNR: TC198 + Passenger: Catherine Bouchard + Flight: AC 422 + Date: May 1, 2026
? Existing Case: CASE-FD-20260501-002
? Existing Case Claimant: Catherine Bouchard (filed for herself)
? Existing Case Status: CLOSED ($400 CAD PAID to Catherine)
? Catherine's Duplicate Status: DUPLICATE DETECTED � ALREADY COMPENSATED
MIXED DUPLICATE RESULT:
? Marc Bouchard: NOT DUPLICATE (new claim � eligible for assessment)
? Catherine Bouchard: DUPLICATE (already compensated on CASE-FD-20260501-002)
KEY INSIGHT: Duplicate detection is PASSENGER-BASED, not CLAIMANT-BASED. Even though Marc (a different claimant) is filing, Catherine's passenger record shows she was already compensated. The system blocks Catherine's duplicate but allows Marc's new claim.
DUPLICATE NOTIFICATION TO CUSTOMER:
Then the chatbot responds:
"I've checked the records for both passengers:
For Marc Bouchard: No previous claim found for this flight. I'll proceed with your claim.
For Catherine Bouchard: A claim has already been filed and processed for this flight under case CASE-FD-20260501-002. Compensation of $400 CAD was paid on May 14, 2026. A new claim cannot be filed for Catherine for the same journey.
I'll continue processing the claim for Marc Bouchard only. Is that okay?"
And the user confirms "Yes, please proceed for Marc"
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline ? within limitation ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YUL (Canada) ? APPR
And the system checks: Distance YUL?YYZ = ~505 km ? Short-haul
TRIAGE & DDS EVALUATION (Marc Bouchard Only):
Then the DDS evaluation is done in backend for Marc Bouchard only
And DDS Evaluates:
? APPR: Delay 3�6h, Controllable ? ELIGIBLE
? Compensation: CAD $400 (Marc Bouchard only)
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC198
? Passenger 1: Marc Bouchard ? NEW CLAIM ? ELIGIBLE $400 CAD
? Passenger 2: Catherine Bouchard ? DUPLICATE (already compensated on CASE-FD-20260501-002)
? Duplicate Detection: PASSENGER-BASED (not claimant-based)
? Claimant on original case: Catherine Bouchard (herself)
? Claimant on new case: Marc Bouchard (different person)
? System correctly identified Catherine as duplicate despite different claimant
Flight Compensation:
? MR MARC BOUCHARD | ELIGIBLE | APPR_3_TO_6_HOURS | CAD $400
? MS CATHERINE BOUCHARD | DUPLICATE | ALREADY_COMPENSATED | CAD $0
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
Then the chatbot sends case details to CyberSource for fraud screening (for Marc only)
And CyberSource evaluates and returns: GREEN LIGHT (no fraud detected)
ELIGIBLE RESULT (FD-05a) � MARC ONLY:
Then the chatbot displays:
"I've checked your flight details. Flight AC 422 from Montreal (YUL) to Toronto (YYZ) was delayed by about 4 hours.
For Marc Bouchard: Based on the Canadian Air Passenger Protection Regulations (APPR), you may be eligible for compensation of $400 CAD for this delay.
For Catherine Bouchard: As mentioned, compensation was already issued under a previous claim."
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"Thank you for confirming. In which country will your reimbursement be deposited?"
And the user selects "Canada"
Then the system determines: Country = Canada ? Currency = CAD
CASH vs AC WALLET CHECK (FD-06b):
Then the chatbot checks: Does customer have Aeroplan number on booking? ? No
Then the chatbot checks if the claim is for multiple pax ? No (only 1 eligible � Marc)
Then the chatbot responds: "Marc Bouchard is entitled to receive a $400 CAD compensation. Please note that it will take 5 to 10 business days to process payment. Would you like to proceed?"
And an alert information is displayed: "Please note that payments will be deposited in your local currency."
And user provides "Yes"
Then system checks which payment method is mapped based on country of residence ? Interac e-Transfer (Canada)
PAYMENT METHOD � INTERAC E-TRANSFER (FD-07):
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Before we move forward, please provide the email address where you'd like to receive the transfer."
And the user provides "marc.bouchard@gmail.com"
Then the chatbot confirms: "Thank you. Your Interac e-Transfer details have been recorded."
Then system checks that IDV is not completed
IDENTITY VERIFICATION � PERSONA (FD-07b):
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
Then system checks if IDV at Payment
Then system checks if user have consented to IDV
And the chatbot sends Persona IDV link to the customer
And the customer opens the Persona link
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully. Let's proceed to finalize your claim."
CLAIM AMOUNT CONFIRMATION FLOW:
Then the chatbot responds: "Please review your compensation details:
Marc Bouchard: $400 CAD
Catherine Bouchard: Not eligible (already compensated)
Total Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
After submission, you will receive a confirmation email summarizing your eligibility, claim details and next steps.
Would you like me to submit your claim?"
And an alert information is displayed: "Please note that the payment details cannot be changed after submission."
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details, and a second email that will include the secure link where you'll provide your information."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And notification email is sent to m***@gmail.com
And the email contains: Case Reference, compensation details (Marc: $400 CAD eligible; Catherine: duplicate � already compensated), regulation (APPR), flight details, next steps, tracking link
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the new case by PNR
Then the dashboard displays:
� New Case Title: "Travel Disruptions � Delay"
� Status: in review/done
� Claimant: Marc Bouchard
� Regime: APPR
PASSENGER INFORMATION:
� Marc Bouchard: Tags: Claimant, Adult � ELIGIBLE ($400 CAD) � NEW CLAIM
� Catherine Bouchard: Tags: Adult � DUPLICATE (already compensated on CASE-FD-20260501-002)
LINKED CASES:
� Original Case: CASE-FD-20260501-002 (Catherine's original claim � $400 PAID)
ELIGIBILITY AND COMPENSATION:
� Marc Bouchard: ELIGIBLE � $400 CAD
� Catherine Bouchard: DUPLICATE � $0 (already compensated)
DUPLICATE DETECTION VALIDATION:
? Different claimant (Marc vs Catherine): YES ?
? Same PNR: YES (TC198) ?
? Same flight: YES (AC 422, May 1, 2026) ?
? Catherine already compensated: YES ($400 on CASE-FD-20260501-002) ?
? Duplicate detection passenger-based: YES ?
? Duplicate detection NOT claimant-based: YES ?
? Catherine blocked as duplicate: YES ?
? Marc allowed as new claim: YES ?
? Mixed result (1 new + 1 duplicate): YES ?
? Customer informed clearly: YES ?

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marc Bouchard" with the same PNR as the original claim containing two passengers
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done" as partial with Marc's claim new and Catherine's duplicate
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And a Partial Duplicate Warning Banner should be displayed as one passenger is duplicate and one is new
    And the Decision Assist panel should NOT be greyed out for Marc's new claim
    And the Claimant Name should be "Marc Bouchard" as new claimant different from original claimant Catherine
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the Regime should be "APPR"
    And Passenger 1 DUPLICATE BLOCKED should be Catherine Bouchard with Tags Adult and DUPLICATE and Duplicate Status already compensated on prior case with Original Case ID and original payment $400 paid on the original date
    And Passenger 2 NEW eligible for assessment should be Marc Bouchard with Tags Claimant and Adult
    And the Journey should show "Bound 1: YUL ? YYZ" same flight as original claim
    And Catherine Bouchard DUPLICATE should show DUPLICATE FOUND at individual passenger level with Catherine's passenger record already having compensation paid on original case and eligibility NOT ELIGIBLE Duplicate and compensation $0 already compensated and original case ID referenced
    And Marc Bouchard NEW CLAIM should show NOT DUPLICATE as first-time claim for this passenger and DDS assessment should proceed normally and eligibility should be ELIGIBLE under APPR controllable delay criteria met and compensation "$400 CAD"
    And duplicate detection should be at the INDIVIDUAL PASSENGER level NOT PNR or claimant level
    And Catherine should be Blocked as duplicate passenger and Marc should Proceed as new passenger claim
    And a different claimant filing should NOT bypass duplicate detection for already-compensated passengers
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run for Marc Bouchard only as Catherine is blocked as duplicate
    And Marc should be ELIGIBLE under APPR and Catherine should be DUPLICATE blocked with original case referenced
    And the Duplicate Check should show Catherine Bouchard as DUPLICATE FOUND already compensated on prior case and Marc Bouchard as NOT DUPLICATE first-time claim proceed with assessment
    And the CyberSource result should be "GREEN" as it ran for eligible Marc Bouchard only
    And the system should have appended the booking record automatically
    And a notification email should have been sent to Marc Bouchard containing Marc Eligible $400 and Catherine Duplicate already compensated original case referenced and flight details
    And the Agent Notes section should be accessible
    And the Audit Log should record passenger-level duplicate detection with Catherine duplicate and Marc new
    And the original case ID should be logged for Catherine
    And Marc's assessment should be logged as new eligible claim
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Resolved" with Marc's claim processed and Catherine's blocked
    And the case should be in read-only mode
    And the Related Cases tab should link to Catherine's original case
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the result is MIXED with Marc Bouchard NEW eligible for payment and Catherine Bouchard DUPLICATE blocked already compensated on CASE-FD-20260501-002
    Then the customer's country of residence should be "Canada"
    And the currency should be set to "CAD"
    And the payment method should be "Interac e-Transfer" for Marc only
    And the customer has no Aeroplan linked so only Cash should be offered
    And the compensation amount should be "$400 CAD" for Marc Bouchard only as single eligible passenger
    And Catherine Bouchard should receive $0 as already compensated $400 CAD on original case CASE-FD-20260501-002 paid May 14 2026 and NO new compensation record should be created for Catherine
    And the Interac e-Transfer email should be collected for Marc
    And IDV at Payment should be triggered via Persona for Marc and IDV PASS should be required before claim submission
    And a compensation record should be created for Marc only in the backend with GL account and cost center
    And in UAT the batch file should be triggered manually in coordination with the Unifier and SAP team
    And Cash should be dispatched to Unifier and Unifier should send acknowledgement for Marc's $400 only
    And the end-of-day report from Interac should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired"
    And if Marc does not claim Interac within 35 days the status should be Expired
    And the Claims Dashboard Compensation tab should show payout details "$400 CAD" for Marc only with payment method "Cash" via "Interac" and status updated via talkback
    And the Claims Dashboard should show Catherine's record as DUPLICATE with $0 and original case ID referenced and original payment $400 CAD already processed
    And duplicate detection should be at the INDIVIDUAL PASSENGER level NOT PNR or claimant level and Catherine should be blocked as duplicate even though Marc as different claimant is filing and Marc's payment should proceed independently
    And the total payout for this case should be "$400 CAD" for 1 eligible passenger multiplied by $400 NOT $800 CAD

Expected Results:
DDS returns FD-DUP-NE-02 (for Catherine) + FD-APPR-EL-01 (for Marc). Duplicate Detection: Catherine Bouchard ? DUPLICATE FOUND (already compensated on prior case). Marc Bouchard ? NOT DUPLICATE (first-time claim, proceed with assessment). CRITICAL: Duplicate detection must be at the INDIVIDUAL PASSENGER level, not PNR or claimant level. Catherine is blocked; Marc proceeds normally. Compensation: Catherine = $0 (duplicate); Marc = $400 (new eligible claim). Claims Dashboard: Catherine: Duplicate; Original case referenced; Blocked. Marc: Eligible; $400; New claim processed. DDS = FD-DUP-NE-02.