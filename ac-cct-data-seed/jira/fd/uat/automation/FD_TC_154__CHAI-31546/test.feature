Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Tel Aviv to Toronto was delayed 4 hours due to a crew issue. I'd like to check if I'm eligible for compensation"
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
And the user provides "Daniel Avraham"
Then the chatbot responds:
"Thanks, Daniel! And, what is your booking reference number?"
And the user provides "PNR: TC121"
Then the chatbot searches Trip Tracer for PNR: TC121
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data is revealed � EMPLOYEE BOOKING IDENTIFIER PRESENT (AC Employee)
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: d***@aircanada.ca
� Phone: +972***123
And the user selects "Email: d***@aircanada.ca"
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
� Daniel Avraham (Adult) [AC Employee]
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 084
� Route: Tel Aviv Ben Gurion (TLV) ? Toronto (YYZ)
� Date: May 31, 2026
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
Then the system checks: Is passenger an AC employee? ? YES (employee booking identifier present)
Then the system determines: AC EMPLOYEE ? NOT ELIGIBLE (employee bookings excluded from all regimes)
TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS sends to Trip Tracer UI:
TRIP TRACER UI VALIDATION
Then the tester opens Trip Tracer UI for PNR: TC121
? Promised Itinerary - Flight: AC 084, Route: TLV ? YYZ, Scheduled Arrival: 16:00
? Current Itinerary - Flight: AC 084, Route: TLV ? YYZ, Status: ARRIVED LATE, Actual: 20:00, Delay: +4H 00M
? Passenger: AC EMPLOYEE (employee booking identifier present)
? Regime: ASL (Israel origin � TLV) � BUT employee exclusion applies
? MSL FLIGHT: AC 084 � TLV ? YYZ � 42 � CONTROLLABLE
? Employee Check: AC EMPLOYEE ? NOT ELIGIBLE (overrides all other checks)
Flight Compensation:
? MR DANIEL AVRAHAM | NOT ELIGIBLE | EMPLOYEE_AC | 0.00
FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked
NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've reviewed the details of your flight. I understand your flight AC 084 from Tel Aviv Ben Gurion (TLV) to Toronto (YYZ) was delayed by 4 hours. However, based on our records, this booking is associated with an employee travel benefit. Employee bookings are not eligible for flight disruption compensation under the applicable regulations. We apologize for the inconvenience."
NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to d***@aircanada.ca
And the email contains: Case Reference, flight details, not eligible reason (AC employee booking), regulation reference, contact information
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
Feature: Claims Dashboard Validation � TC121 Daniel Avraham (ASL AC Employee � Not Eligible)

  Scenario: Validate Claims Dashboard for TC121 Daniel Avraham (ASL AC Employee � Not Eligible)
    Given the case has been created for claimant "Daniel Avraham" with PNR "TC121"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Daniel Avraham"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC121"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel)" but employee exclusion applies
    And the Full Name should be "Daniel Avraham"
    And the Tags should include "Claimant" and "Adult" and "AC Employee"
    And the Email should be "d***@aircanada.ca"
    And the Phone should be "+972***123"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "AC Employee � employee bookings excluded from all regimes"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to AC Employee booking overriding all other checks including controllability
    And the Duplicate Check should have run automatically using baseline data "Daniel Avraham + TC121 + TLV?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "d***@aircanada.ca" containing Case Reference and flight details and not eligible reason AC employee booking and regulation reference
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC121 Daniel Avraham (ASL AC Employee � No Payment)

  Scenario: Validate Payment for TC121 Daniel Avraham (ASL AC Employee � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to AC Employee
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC122 Yonatan Weiss (ASL OAL Employee � Not Eligible)

  Scenario: Validate Claims Dashboard for TC122 Yonatan Weiss (ASL OAL Employee � Not Eligible)
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


Feature: Payment Validation � TC122 Yonatan Weiss (ASL OAL Employee � No Payment)

  Scenario: Validate Payment for TC122 Yonatan Weiss (ASL OAL Employee � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to OAL Employee
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC123 OAL Operated ASL (No Case)

  Scenario: Validate Claims Dashboard for TC123 OAL Operated ASL (No Case)
    Given the system determined all segments are operated by OAL El Al LY 315 for PNR "TC123"
    Then the chatbot should have redirected the customer to contact El Al directly
    And no DDS evaluation should have occurred
    And no case should have been created in the automated system
    And no Claims Dashboard entry should exist for PNR "TC123"
    And when searching Claims Dashboard by PNR "TC123" no case should be found


Feature: Payment Validation � TC123 OAL Operated ASL (No Payment)

  Scenario: Validate Payment for TC123 OAL Operated ASL (No Payment)
    Given no case was created due to OAL operated flight
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC124 Denied Boarding ASL (No Case)

  Scenario: Validate Claims Dashboard for TC124 Denied Boarding ASL (No Case)
    Given the chatbot identified a denied boarding event for PNR "TC124"
    Then the chatbot should have redirected the customer to Customer Relations or the denied boarding claim form
    And no identification flow should have occurred
    And no authentication flow should have occurred
    And no DDS evaluation should have occurred
    And no case should have been created in the automated system as denied boarding is handled separately
    And no Claims Dashboard entry should exist for PNR "TC124"
    And when searching Claims Dashboard by PNR "TC124" no automated case should be found


Feature: Payment Validation � TC124 Denied Boarding ASL (No Payment)

  Scenario: Validate Payment for TC124 Denied Boarding ASL (No Payment)
    Given no case was created due to denied boarding being handled separately
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC125 Amir Segal (ASL Extraordinary Weather Origin Cancellation � Not Eligible)

  Scenario: Validate Claims Dashboard for TC125 Amir Segal (ASL Extraordinary Weather Origin Cancellation � Not Eligible)
    Given the case has been created for claimant "Amir Segal" with PNR "TC125"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Amir Segal"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC125"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel origin � TLV) + APPR"
    And the Full Name should be "Amir Segal"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "a***@gmail.com"
    And the Phone should be "+972***789"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: TLV ? YYZ" with claim filed for this flight as cancelled
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weather, cancellation code WEAT � ASL"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with cancellation code WEAT and No Travel Origin
    And the Duplicate Check should have run automatically using baseline data "Amir Segal + TC125 + TLV?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "a***@gmail.com" containing Extraordinary Circumstance severe weather WEAT and TLV to YYZ CANCELLED and ASL and insurance suggestion
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC125 Amir Segal (ASL Extraordinary Weather Origin � No Payment)

  Scenario: Validate Payment for TC125 Amir Segal (ASL Extraordinary Weather Origin � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return Cancellation � Not Eligible)

  Scenario: Validate Claims Dashboard for TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return Cancellation � Not Eligible)
    Given the case has been created for claimant "Eli Navon" with PNR "TC126"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Eli Navon"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC126"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel destination � TLV) + APPR"
    And the Full Name should be "Eli Navon"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "e***@gmail.com"
    And the Phone should be "+1***901"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: YYZ ? FRA" as completed and "Segment 2: FRA ? TLV" as cancelled with claim filed
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary Circumstance � severe weather, cancellation code WEAT � Leg 2 cancellation � ASL"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to Extraordinary Circumstance with cancellation code WEAT and Leg 2 FRA to TLV cancellation and No Travel Return and customer returned to YYZ
    And the Duplicate Check should have run automatically using baseline data "Eli Navon + TC126 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "e***@gmail.com" containing Case Reference and Leg 2 FRA to TLV CANCELLED and Extraordinary Circumstance severe weather WEAT and No Travel Return and ASL and insurance suggestion
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return � No Payment)

  Scenario: Validate Payment for TC126 Eli Navon (ASL Extraordinary Weather Leg 2 Return � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete Cancellation � Not Eligible)

  Scenario: Validate Claims Dashboard for TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete Cancellation � Not Eligible)
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


Feature: Payment Validation � TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete � No Payment)

  Scenario: Validate Payment for TC127 Talia Friedman (ASL Extraordinary Weather Leg 2 Incomplete � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to Extraordinary Circumstance severe weather on Leg 2
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC128 Hadas Mor (ASL Below Threshold Origin Cancellation � Not Eligible)

  Scenario: Validate Claims Dashboard for TC128 Hadas Mor (ASL Below Threshold Origin Cancellation � Not Eligible)
    Given the case has been created for claimant "Hadas Mor" with PNR "TC128"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Cancellation"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Hadas Mor"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC128"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "ASL (Israel destination � TLV) + APPR"
    And the Full Name should be "Hadas Mor"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "h***@gmail.com"
    And the Phone should be "+1***345"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: YYZ ? TLV" with claim filed as cancelled
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "MSL re-routing delay 2h � below ASL minimum 3-hour No Travel threshold; cancellation code CREW = Not Extraordinary Circumstance but threshold overrides"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to delay 2h being less than 3h ASL No Travel threshold
    And the Duplicate Check should have run automatically using baseline data "Hadas Mor + TC128 + YYZ?TLV + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "h***@gmail.com" containing Case Reference and YYZ to TLV CANCELLED and MSL delay below 3h and No Travel Origin and ASL
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC128 Hadas Mor (ASL Below Threshold Origin � No Payment)

  Scenario: Validate Payment for TC128 Hadas Mor (ASL Below Threshold Origin � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to MSL delay below 3-hour ASL threshold
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC129 Itai Bergman (ASL Below