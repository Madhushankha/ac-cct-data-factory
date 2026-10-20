Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I changed my flight through your call center last week and now I'm wondering if I can get compensation for the schedule difference"
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
And the user provides "Marc-Antoine Gagnon"
Then the chatbot responds:
"Thanks, Marc-Antoine! And, what is your booking reference number?"
And the user provides "PNR: TCVOL03"
Then the chatbot searches Trip Tracer for PNR: TCVOL03
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: m***@gmail.com
� Phone: +1***456
And the user selects "Email: m***@gmail.com"
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
� Marc-Antoine Gagnon (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 405
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 10, 2026
� Scheduled Arrival: 11:00
� Actual Arrival: 11:00
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival ? >72 hours ? PROCEED
REGIME DETERMINATION:
Then the system determines: Origin = YUL (Canada) ? APPR
TRIAGE & DDS EVALUATION � VOL CHANGE DETECTED:
Then the DDS evaluation is done in backend
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TCVOL03
? Promised Itinerary - Flight: AC 405, Route: YUL ? YYZ, Scheduled Arrival: 11:00 (updated by CC VOL)
? Current Itinerary - Flight: AC 405, Route: YUL ? YYZ, Status: ON TIME, Actual: 11:00
? Change History:
Change 1: Contact Center (ADDCOL, no ACNP) at D-7 � VOL � arrival 08:00 ? 11:00
? Promise = 11:00 (updated by VOL)
? Delay from promise = 0 hours
? Regime: APPR
? Result: NOT ELIGIBLE (no delay)
? No MSL (no disruption)
? No disruption code
? CRITICAL: ADDCOL alone does NOT determine VOL/INVOL � the ABSENCE of ACNP is what confirms VOL
Flight Compensation:
? MR MARC-ANTOINE GAGNON | NOT ELIGIBLE | NO_DELAY_FROM_PROMISE | $0
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT:
Then the chatbot displays:
"I've reviewed the details of your flight. Your flight AC 405 from Montreal (YUL) to Toronto (YYZ) arrived on time based on your current booking. Our records show that a schedule change was made to your booking prior to travel. Based on the updated schedule, there was no delay at arrival. You are not eligible for compensation at this time."
NO PAYMENT FLOW (not eligible � skipped entirely)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, flight details (AC 405, YUL?YYZ, June 10, 2026), not eligible reason (no delay from updated schedule � voluntary change detected), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marc-Antoine Gagnon" with PNR "TCVOL03"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Marc-Antoine Gagnon"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TCVOL03"
    And the Regime should be "APPR"
    And the Full Name should be "Marc-Antoine Gagnon"
    And the Tags should include "Claimant" and "Adult"
    And the Journey should show "Bound 1: YUL ? YYZ"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "NOT ELIGIBLE" with reason "No delay from promise (CC VOL change updated promise; flight on time)"
    And the compensation should be $0
    And the Change History should show Contact Center ADDCOL with no ACNP as VOL with promise updated to 11:00
    And ADDCOL alone does NOT determine VOL or INVOL as the ABSENCE of ACNP is what confirms VOL
    And the Promise should be 11:00 VOL-updated and the Actual should be 11:00 and the Delay should be 0hrs
    And DDS should have run automatically
    And VOL should have been detected via Contact Center ADDCOL with no ACNP
    And the promise should have been updated to VOL arrival 11:00
    And no delay should result in Not Eligible
    And the Duplicate Check should have run automatically using baseline data "Marc-Antoine Gagnon + TCVOL03 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases
    And the system should have appended the booking record automatically
    And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason no delay from updated schedule and contact information
    And the Audit Log should record CC VOL detected ADDCOL with no ACNP and promise updated to 11:00 and no delay and not eligible
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to no delay from promise after CC VOL change
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created in the backend
    And no batch file should have been dispatched to Unifier
    And the Claims Dashboard Compensation tab should show $0 with no delay from promise due to CC VOL change

Expected Results:
Tool: Contact Center (ADDCOL + no ACNP); Classification: VOL; Promise: Updated from 08:00 to 11:00; Actual: 11:00; Delay: 0hrs; NOT ELIGIBLE; CRITICAL: ACNP absence confirms VOL |