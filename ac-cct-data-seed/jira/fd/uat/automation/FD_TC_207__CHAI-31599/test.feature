Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My bus from Ottawa to Montreal was delayed 3 hours and I missed my connecting flight AC 870 to Paris. I want to check if I'm eligible for compensation"
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
And the user provides "Marc-Andr� Pelletier"
Then the chatbot responds:
"Thanks, Marc-Andr�! And, what is your booking reference number?"
And the user provides "PNR: TC_BUS01"
Then the chatbot searches Trip Tracer for PNR: TC_BUS01
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
Email: m***@gmail.com
Phone: +1***456
And the user selects "Email: m***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "629481"
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
Marc-Andr� Pelletier (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
Segment 1: Bus � Ottawa (YOW) ? Montreal (YUL) � June 5, 2026
Segment 2: Flight AC 870 � Montreal (YUL) ? Paris (CDG) � June 5, 2026
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments: bus + flight)
Then the chatbot identifies: Segment 1 = Bus (ground transport), Segment 2 = Flight AC 870
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg expected arrival
And the system calculates: Expected arrival was June 6, 2026 02:00; current date is June 17, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption June 5, 2026; filing June 17, 2026 ? 12 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION:
Then the tester opens Trip Tracer UI for PNR: TC_BUS01
? Promised Itinerary:
Segment 1: Bus YOW ? YUL, Scheduled Dep: 08:00, Scheduled Arr: 10:00
Segment 2: Flight AC 870 YUL ? CDG, Scheduled Dep: 13:00, Scheduled Arr: 02:00+1
? Current Itinerary:
Segment 1: Bus YOW ? YUL, Status: ARRIVED LATE, Actual Arr: 13:00, Delay: +3H 00M
Segment 2: Flight AC 870 YUL ? CDG, Status: DEPARTED ON TIME � CUSTOMER NO-SHOW (missed connection)
? Disrupted Segment: Segment 1 (Bus) � NOT a flight segment
? Flight Segment (AC 870): Operated on time � no flight disruption occurred
? Rule Applied: "Train and Bus: If the customer misses their flight due to a delay on the bus/train, there is no entitlement to compensation (all regimes) as only flight segments matter."
? Regime Assessment:
APPR = NOT ELIGIBLE (disruption on non-flight segment)
EU 261 = NOT ELIGIBLE (disruption on non-flight segment)
ASL = NOT ELIGIBLE (disruption on non-flight segment)
? GW Flag: Available at business discretion � not automatic
Flight Compensation:
? MR MARC-ANDR� PELLETIER | NOT ELIGIBLE | NON_FLIGHT_SEGMENT_DISRUPTION | CAD 0.00
FRAUD SCREENING � CYBERSOURCE (GLOB-05):
CyberSource only runs for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've checked your journey details. Your itinerary included a ground transportation (bus) segment from Ottawa (YOW) to Montreal (YUL), which experienced a 3-hour delay causing you to miss your connecting flight AC 870 to Paris."
"However, under the Air Passenger Protection Regulations (APPR), EU 261, and all applicable regulations, only flight segment disruptions are eligible for compensation. Since the disruption occurred on a bus segment, you are not entitled to compensation."
"We apologize for the inconvenience caused."
DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
Agree
Dispute
And the user selects "Agree"
NO PAYMENT FLOW (skipped entirely)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Your case has been recorded. Case Reference: CASE-FD-20260617-BUS01."
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to m***@gmail.com
And the email contains: Case Reference, regulation (APPR), journey details, reason for ineligibility (non-flight segment disruption), next steps
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
I would like you to � new flow
No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Marc-Andr� Pelletier" with PNR "TC_BUS01"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Marc-Andr� Pelletier"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC_BUS01"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Marc-Andr� Pelletier"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "m***@gmail.com"
    And the Phone should be "+1***456"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YOW ? YUL (Bus) + YUL ? CDG (Flight AC 870)" with claim filed for missed connection
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility should be "NOT ELIGIBLE" with reason "Non-flight segment disruption (bus)"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE"
    And the Duplicate Check should have run automatically using baseline data "Marc-Andr� Pelletier + TC_BUS01 + YOW?YUL?CDG + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been invoked as it only runs for eligible cases
    And the system should have appended the booking record to the case automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case function from My Activities to get this case
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent to the customer
    And a not eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps
    And Customer Communications should show the notification email
    And the chatbot transcript should be accessible and linked
    And the Attachments tab should be empty
    And the Final Status should be "Resolved"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only

PAYMENT VALIDATION
    Given the eligibility result is "NOT ELIGIBLE" due to non-flight segment disruption
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
Trip Tracer: Segment 1 = Bus YOW?YUL, delayed 3hrs; Segment 2 = Flight AC 870 YUL?CDG, operated on time. Disruption on non-flight segment. Rule: "Only flight segments matter for compensation � bus/train disruptions excluded under all regimes." APPR = NOT ELIGIBLE; EU = NOT ELIGIBLE; ASL = NOT ELIGIBLE. Compensation: $0. GW: Available at business discretion. CyberSource: NOT invoked.