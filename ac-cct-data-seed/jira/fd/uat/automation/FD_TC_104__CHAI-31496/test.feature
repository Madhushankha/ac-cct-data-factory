Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I changed my flight myself to a later one and it arrived on time. I'd like to check if I'm eligible for any compensation since my original flight was much earlier"
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
And the user provides "Olivier Deschamps"
Then the chatbot responds:
"Thanks, Olivier! And, what is your booking reference number?"
And the user provides "PNR: TC061"
Then the chatbot searches Trip Tracer for PNR: TC061
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: o***@gmail.com
� Phone: +1***890
And the user selects "Email: o***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "371928"
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
� Olivier Deschamps (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 505
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 20, 2026
� Status: ARRIVED (on time)
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 20, 2026; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Flight date May 20, 2026; filing June 15, 2026 ? 26 days ? within 366 days ? PROCEED
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS checks: Booking change history
And DDS identifies: Change 1 (Day -5): VOL � customer changed flight ? arrival updated from 10:00 to 15:00
And DDS checks: Any INVOL changes? ? NO (VOL only)
And DDS determines: Promise = VOL arrival (15:00) � VOL updates the promise baseline
And DDS calculates: Delay = Actual arrival (15:00) - Promise (15:00) = 0H 00M
And DDS determines: NO DELAY ? NOT ELIGIBLE
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC061
? Promised Itinerary - Flight: AC 505, Route: YUL ? YYZ, Scheduled Arrival: 15:00 (VOL-updated promise, NOT 10:00 original)
? Current Itinerary - Flight: AC 505, Route: YUL ? YYZ, Status: ARRIVED ON TIME, Actual Arrival: 15:00, Delay: 0H 00M
? History - Original booking: arr 10:00 | Change 1 (Day -5): VOL � customer changed flight ? arr 15:00
? Promise Rule: VOL only (no INVOL) ? promise = VOL arrival (15:00)
? Delay = Actual (15:00) - Promise (15:00) = 0h
? Regime: APPR (1 regime)
? CRITICAL: Promise = 15:00 (VOL), NOT 10:00 (original/14-day mark). Customer's voluntary change updates the baseline.
? DDS: NO DELAY ? NOT ELIGIBLE
Flight Compensation:
? MR OLIVIER DESCHAMPS | NOT ELIGIBLE | NO_DELAY | CAD 0.00
FRAUD SCREENING � NOT TRIGGERED:
Then the chatbot notes: CyberSource is ONLY called for ELIGIBLE cases
And this case is NOT ELIGIBLE ? CyberSource NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've checked your flight details, and it looks like your arrival in Toronto was on time. That means there's no recorded delay for this part of your trip. Based on Air Passenger Protection Regulations (APPR), you are not entitled to compensation at this time."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to o***@gmail.com
And the email contains: Case Reference, flight details, not eligible reason (no delay � VOL change updated promise, actual matched promise), regulation reference (APPR), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant "Olivier Deschamps" with PNR "TC061"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Olivier Deschamps"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC061"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "APPR"
    And the Full Name should be "Olivier Deschamps"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "o***@gmail.com"
    And the Phone should be "+1***890"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YUL ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "No delay � VOL change updated promise to 15:00, actual = 15:00"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to VOL only with promise updated to VOL arrival and actual matched promise resulting in 0h delay
    And the Duplicate Check should have run automatically using baseline data "Olivier Deschamps + TC061 + YUL?YYZ + FD"
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
    Given the eligibility result is "NOT ELIGIBLE" due to VOL change with no delay
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section

Expected Results:
DDS returns FD-APPR-NE-27. Trip Tracer � Promise Calculation: Changes = VOL only (no INVOL); Rule = when only VOL, promise = latest state including VOL; Original arrival = 10:00; VOL arrival = 15:00; Promise = 15:00 (VOL selection). Actual = 15:00. Delay = 0 (no delay from updated promise). No arrival or delay code (normal operation). Compensation: $0 � no delay. Customer voluntarily chose the later flight; that time is the baseline. Fraud Screening: NOT INVOKED. Claims Dashboard: VOL updated promise to 15:00; Actual = 15:00; No delay; $0; DDS = FD-APPR-NE-27.