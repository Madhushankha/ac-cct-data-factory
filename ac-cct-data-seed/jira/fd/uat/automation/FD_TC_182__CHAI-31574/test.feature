Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was changed and I arrived later than originally planned. Can I get compensation?"
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
And the user provides "Brigitte Lavoie"
Then the chatbot responds:
"Thanks, Brigitte! And, what is your booking reference number?"
And the user provides "PNR: TCVOL02"
Then the chatbot searches Trip Tracer for PNR: TCVOL02
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: b***@gmail.com
� Phone: +1***345
And the user selects "Email: b***@gmail.com"
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
� Brigitte Lavoie (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 403
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: June 10, 2026
� Scheduled Arrival: 12:00
� Actual Arrival: 12:00
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
Then the tester opens Trip Tracer UI for PNR: TCVOL02
? Promised Itinerary - Flight: AC 403, Route: YUL ? YYZ, Scheduled Arrival: 12:00 (updated by Volantio VOL)
? Current Itinerary - Flight: AC 403, Route: YUL ? YYZ, Status: ON TIME, Actual: 12:00
? Change History:
Change 1: Volantio (SK VOLY) at D-6 � VOL � arrival 09:00 ? 12:00
? Promise = 12:00 (updated by VOL)
? Delay from promise = 0 hours
? Regime: APPR
? Result: NOT ELIGIBLE (no delay)
? No MSL (no disruption)
? No disruption code (flight operated normally)
Flight Compensation:
? MS BRIGITTE LAVOIE | NOT ELIGIBLE | NO_DELAY_FROM_PROMISE | $0
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT:
Then the chatbot displays:
"I've reviewed the details of your flight. Your flight AC 403 from Montreal (YUL) to Toronto (YYZ) arrived on time based on your current booking. Our records show that a schedule change was made to your booking prior to travel. Based on the updated schedule, there was no delay at arrival. You are not eligible for compensation at this time."
NO PAYMENT FLOW (not eligible � skipped entirely)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to b***@gmail.com
And the email contains: Case Reference, flight details (AC 403, YUL?YYZ, June 10, 2026), not eligible reason (no delay from updated schedule � voluntary change detected), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Brigitte Lavoie" with PNR "TCVOL02"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Brigitte Lavoie"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TCVOL02"
    And the Regime should be "APPR"
    And the Full Name should be "Brigitte Lavoie"
    And the Tags should include "Claimant" and "Adult"
    And the Journey should show "Bound 1: YUL ? YYZ"
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "NOT ELIGIBLE" with reason "No delay from promise (Volantio VOL updated promise; flight on time)"
    And the compensation should be $0
    And the Change History should show Volantio SK VOLY as VOL with promise updated to 12:00
    And the Promise should be 12:00 VOL-updated and the Actual should be 12:00 and the Delay should be 0hrs
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And VOL should have been detected via Volantio tool SK VOLY
    And the promise should have been updated to VOL arrival 12:00
    And no delay should result in Not Eligible
    And the Duplicate Check should have run automatically using baseline data "Brigitte Lavoie + TCVOL02 + YUL?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for ELIGIBLE cases
    And the system should have appended the booking record automatically
    And a not eligible notification email should have been sent via Adobe containing Case Reference and flight details and not eligible reason no delay from updated schedule and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record Volantio VOL detected SK VOLY and promise updated to 12:00 and no delay and not eligible
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to no delay from promise after Volantio VOL change
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no payment method should have been determined
    And no compensation amount should have been calculated as it is $0
    And no IDV should have been triggered
    And no CyberSource fraud screening should have been triggered as it only runs for eligible cases
    And no compensation record should have been created in the backend
    And no batch file should have been dispatched to Unifier
    And the Claims Dashboard Compensation tab should show $0 with no delay from promise due to Volantio VOL change

Expected Results:
Tool: Volantio (SK VOLY); Classification: VOL; Promise: Updated from 09:00 to 12:00; Actual: 12:00; Delay from promise: 0hrs; Result: NOT ELIGIBLE; No disruption; No compensation; $0 |