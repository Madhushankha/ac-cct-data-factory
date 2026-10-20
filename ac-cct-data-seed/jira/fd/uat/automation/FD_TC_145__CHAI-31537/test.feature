Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Paris to Toronto was delayed about 2 hours and I arrived in Vancouver about an hour and a half late. Can I get compensation under EU regulations?"

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
And the user provides "Jos�phine Lambert"
Then the chatbot responds:
"Thanks, Jos�phine! And, what is your booking reference number?"
And the user provides "PNR: TC111"
Then the chatbot searches Trip Tracer for PNR: TC111
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:

Email: j***@outlook.com

Phone: +33***678

And the user selects "Email: j***@outlook.com"
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

Jos�phine Lambert (Adult)

Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:

Segment 1: Flight AC 871, Paris Charles de Gaulle (CDG) ? Toronto (YYZ), June 6, 2026 � ARRIVED LATE (+2h)

Segment 2: Flight AC 121, Toronto (YYZ) ? Vancouver (YVR), June 6, 2026 � ARRIVED ON TIME

Is this the journey you'd like to check?"
And the user confirms "Yes"

SEGMENT CHECK (GenUC-18):
Then the chatbot checks: More than 1 segment on selected journey? ? YES (2 segments)
Then the chatbot identifies: Segment 1 ARRIVED LATE (MSL), Segment 2 ARRIVED ON TIME
Then the chatbot determines: Final destination = YVR; Final arrival delay = 1.5h

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was June 6, 2026; current date is June 25, 2026 ? >72 hours ? PROCEED

CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for EU 261 (French jurisdiction � CDG origin) = 5 years ? within limitation ? PROCEED

REGIME DETERMINATION:
Then the system determines: Journey origin = CDG (Paris, EU Mainland) ? EU 261 (EU Mainland)

TRIAGE & DDS EVALUATION:
Then the DDS evaluation is done in backend
And DDS Evaluates and sends to Trip Tracer UI:

Trip Tracer UI Validation
Then the tester opens Trip Tracer UI for PNR: TC111

? Segment 1: Flight: AC 871, Route: CDG ? YYZ, Scheduled Arrival: 13:00, Actual: 15:00, Delay: +2H 00M (MSL)

? Arrival Delay Code on Leg 1: 42 � numeric delay code (Controllable)

? Segment 2: Flight: AC 121, Route: YYZ ? YVR, Scheduled Arrival: 20:00, Actual: 21:30, Delay: +1H 30M

? Final Destination: YVR

? Final Arrival Delay: Promised arrival at YVR = 20:00; Actual arrival at YVR = 21:30 ? +1H 30M

? MSL Delay: 2H 00M (Leg 1 � CDG?YYZ) ? also below 3h

? BOTH MSL delay (2h) AND arrival delay (1.5h) are below 3-hour threshold

? Regime: EU 261 (EU Mainland � CDG origin)

? EU 261 Threshold: Arrival delay at final destination must be ? 3 hours ? 1.5h < 3h ? NOT ELIGIBLE

? Fallback: FALSE (arrival delay code 42 available)

? No ambiguity � insufficient delay at every measurement point

Flight Compensation:

? MS JOS�PHINE LAMBERT | NOT ELIGIBLE | ARRIVAL_DELAY_BELOW_3_HOURS | EUR 0.00

FRAUD SCREENING � NOT TRIGGERED:
CyberSource is ONLY called for ELIGIBLE cases ? NOT invoked

NOT ELIGIBLE RESULT (FD-05b):
Then the chatbot displays:
"I've checked your flight details, and it looks like your arrival in Vancouver was on time. That means there's no recorded delay for this part of your trip. Based on the EU Air Passenger Rights regulations (EU 261/2004), you are not entitled to compensation at this time."

NO PAYMENT FLOW (skipped entirely for not eligible)
NO IDV (not required for not eligible)
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details."
And an alert information is displayed: "Claim submission successful!"
And the system appends the booking record to the case automatically

NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to j***@outlook.com
And the email contains: Case Reference, flight details (Seg 1: CDG?YYZ +2h MSL; Seg 2: YYZ?YVR; Final arrival YVR +1h30m), not eligible reason (both MSL delay and arrival delay at final destination below 3-hour threshold), regulation reference (EU 261), contact information

END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"

I would like you to � new flow

No

And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
Feature: Claims Dashboard Validation � TC111 Jos�phine Lambert (EU 261 EU Mainland Both Delays Below Threshold � Not Eligible)

  Scenario: Validate Claims Dashboard for TC111 Jos�phine Lambert (EU 261 EU Mainland Both Delays Below Threshold � Not Eligible)
    Given the case has been created for claimant "Jos�phine Lambert" with PNR "TC111"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Jos�phine Lambert"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC111"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (EU Mainland)"
    And the Full Name should be "Jos�phine Lambert"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "j***@outlook.com"
    And the Phone should be "+33***678"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Segment 1: CDG ? YYZ" arrived late plus 2h as MSL and "Segment 2: YYZ ? YVR" arrived on time
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Both MSL delay 2h AND final arrival delay at YVR 1.5h are below 3h EU 261 threshold"
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to arrival delay 1.5h being less than 3h and MSL delay 2h also being less than 3h
    And the Duplicate Check should have run automatically using baseline data "Jos�phine Lambert + TC111 + CDG?YVR + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "j***@outlook.com" containing arrival delay and MSL delay both below 3h and EU 261
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC111 Jos�phine Lambert (EU 261 Both Delays Below Threshold � No Payment)

  Scenario: Validate Payment for TC111 Jos�phine Lambert (EU 261 Both Delays Below Threshold � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to both MSL and final arrival delays below 3-hour threshold
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC112 Julien Marchand (EU 261 EU Mainland Extraordinary Weather Delay � Not Eligible)

  Scenario: Validate Claims Dashboard for TC112 Julien Marchand (EU 261 EU Mainland Extraordinary Weather Delay � Not Eligible)
    Given the case has been created for claimant "Julien Marchand" with PNR "TC112"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Closed � Not Eligible"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "Julien Marchand"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC112"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261 (EU Mainland)"
    And the Full Name should be "Julien Marchand"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "j***@gmail.com"
    And the Phone should be "+33***234"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" with claim filed for this flight as arrived late plus 4h
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show "NOT ELIGIBLE" with reason "Extraordinary circumstances � severe weather, arrival delay code 72 � EU 261 Article 5(3)"
    And the delay should be 4hrs which would be eligible if controllable as long-haul greater than 3500km CDG to YYZ approximately 5900km equals �600 but extraordinary overrides
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should have run automatically with no agent action needed
    And the eligibility decision should be pre-populated as "NOT ELIGIBLE" due to extraordinary circumstances with arrival delay code 72 and weather and delay 4h and long-haul greater than 3500km
    And the Fallback flag should be FALSE as arrival code is available Code 72
    And the Sister City flag should be FALSE
    And the Duplicate Check should have run automatically using baseline data "Julien Marchand + TC112 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from "Assigned" to "In Progress"
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe to "j***@gmail.com" containing Case Reference and flight details AC 871 CDG to YYZ delayed 4h and not eligible reason extraordinary circumstances severe weather arrival delay code 72 and regulation reference EU 261 Article 5(3) and insurance suggestion and contact information
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be "Closed � Not Eligible"
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC112 Julien Marchand (EU 261 Extraordinary Weather Delay � No Payment)

  Scenario: Validate Payment for TC112 Julien Marchand (EU 261 Extraordinary Weather Delay � No Payment)
    Given the eligibility result is "NOT ELIGIBLE" due to extraordinary circumstances severe weather
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And the Claims Dashboard should show eligibility as "NOT ELIGIBLE" with no compensation record and no payout section


Feature: Claims Dashboard Validation � TC113 Brigitte Pelletier (EU 261 New Destination � No Determination)

  Scenario: Validate Claims Dashboard for TC113 Brigitte Pelletier (EU 261 New Destination � No Determination)
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


Feature: Payment Validation � TC113 Brigitte Pelletier (EU 261 New Destination � No Automated Payment)

  Scenario: Validate Payment for TC113 Brigitte Pelletier (EU 261 New Destination � No Automated Payment)
    Given no determination was made due to new destination
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved


Feature: Claims Dashboard Validation � TC145 Critical MSL Data Missing EU (No Determination � 14-Day Exhausted)

  Scenario: Validate Claims Dashboard for TC145 Critical MSL Data Missing EU (No Determination � 14-Day Exhausted)
    Given the case has been created for PNR "TC145" under EU 261 EU origin CDG
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Last Updated date should be Day 14
    And the Team assignment should be "Manual Review Agent Queue"
    And the Journey should show "CDG ? YYZ" as disrupted with details incomplete due to missing structural data
    And the flight number and operating times should both be NULL meaning RE cannot even identify which flight to query codes for
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "Critical MSL data missing � operating times NULL, flight number NULL after 14 days"
    And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned NULL for operating times and flight number
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to agent
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to MSL data missing
    And an escalation email should have been sent to the customer's email on file containing Case Reference and limited flight details CDG to YYZ with date and data gap and status under review and expected timeline
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC145 Critical MSL Data Missing EU (No Automated Payment)

  Scenario: Validate Payment for TC145 Critical MSL Data Missing EU (No Automated Payment)
    Given no determination was made due to critical MSL data missing after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved


Feature: Claims Dashboard Validation � TC115 OAL Non-Star Alliance Data Missing EU (No Determination � 14-Day Exhausted)

  Scenario: Validate Claims Dashboard for TC115 OAL Non-Star Alliance Data Missing EU (No Determination � 14-Day Exhausted)
    Given the case has been created for PNR "TC115" under EU 261 EU origin CDG
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "Pending Agent Review" escalated from System Processing Queue after 14 days
    And the Last Updated date should be Day 14
    And the Team assignment should be "Manual Review Agent Queue"
    And the Journey should show "Segment 1: CDG ? YYZ" as completed and AC operated and "Segment 2: YYZ ? YOW" arrived late plus 4h and WestJet WS 3421 operated as OAL Non-Star Alliance
    And the MSL should be Segment 2 WestJet as non-Star Alliance OAL
    And this should differ from TC142 where Star Alliance results in immediate StarQuest routing whereas here non-Star OAL means system polls for 14 days then escalates
    And the Eligibility and Compensation section should be present and show "NO DETERMINATION" with reason "OAL data not available � WestJet does not share disruption codes with AC; 14-day retry exhausted"
    And RE should have polled on Days 1, 3, 7, 10, and 14 and all returned WestJet data NOT AVAILABLE
    And the 14-Day Retry Window should be exhausted
    And the determination should be "NO DETERMINATION" escalated to agent
    And the Case Status History should show Created then System Processing Queue then Day 14 Pending Agent Review escalated due to OAL data not available
    And an escalation email should have been sent to the customer's email on file containing Case Reference and Leg 1 CDG to YYZ AC completed and Leg 2 YYZ to YOW WestJet delayed 4h and status under review and coordination with another airline note
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC115 OAL Non-Star Alliance Data Missing EU (No Automated Payment)

  Scenario: Validate Payment for TC115 OAL Non-Star Alliance Data Missing EU (No Automated Payment)
    Given no determination was made due to OAL data not available after 14-day retry
    Then no automated payment flow should be triggered
    And the case was created and sent to agent for manual handling
    And no country of residence should have been asked
    And no compensation record should have been created automatically
    And no batch file should have been dispatched
    And if the agent later determines eligible manual compensation should be created and payment dispatched per type with cash to Unifier and e-credit to EIP
    And the Claims Dashboard should show case status as "No Determination" with no payout section until manually resolved


Feature: Claims Dashboard Validation � TC116 Philippe Lavoie (EU 261 72-Hour Pending)

  Scenario: Validate Claims Dashboard for TC116 Philippe Lavoie (EU 261 72-Hour Pending)
    Given the case has been created for claimant "Philippe Lavoie" with PNR "TC116" filed within 72 hours of arrival
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be "Pending (System Processing Queue)"
    And the Created date should be populated as June 15 2026
    And the Last Updated date should be populated as June 15 2026
    And the SLA should be 15 days
    And the Team assignment should be "System Processing"
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should be pending as DDS has not yet run
    And the Claimant Name should be "Philippe Lavoie"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC116"
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be "EU 261" pending confirmation after DDS runs
    And the Pending Reason should be "Filed within 72 hours of arrival"
    And the Scheduled DDS Run should be approximately June 18 2026
    And the Full Name should be "Philippe Lavoie"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "p***@gmail.com"
    And the Phone should be "+33***123"
    And the Address should be populated
    And the Aeroplan should be "Not linked"
    And the Profile ID should be populated
    And the Tier Status should be populated
    And the Journey should show "Bound 1: CDG ? YYZ" delayed plus 4h with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation status should be "PENDING" awaiting 72-hour window
    And DDS should NOT have run yet as it is deferred until 72-hour window elapses approximately June 18 2026
    And no eligibility determination should exist yet
    And the Duplicate Check should have run automatically using baseline data "Philippe Lavoie + TC116 + CDG?YYZ + FD"
    And the result should be "No duplicate found"
    And CyberSource should NOT have been triggered as DDS has not yet determined eligibility
    And the system should have appended the booking record automatically for identified and authenticated user
    And a pending received notification email should have been sent via Adobe to "p***@gmail.com" containing Case Reference and AC 871 CDG to YYZ June 15 delayed 4h and status "received and being processed" and outcome within 15 days and allow time for flight data finalization
    And the Agent Notes section should be accessible
    And the Audit Log should record case creation and pending status
    And Customer Communications should show the pending notification email
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Current Status should be "Pending (System Processing Queue)"
    And the case should NOT be in read-only mode as it will be updated after DDS runs post 72h
    And after approximately June 18 2026 the system should automatically trigger DDS evaluation
    And the status should update to Eligible or Not Eligible or No Determination based on DDS result
    And the customer should be notified via email of the final outcome
    And the agent should not be able to access Case Search as it is for leads and management only


Feature: Payment Validation � TC116 Philippe Lavoie (EU 261 72-Hour Pending � No Payment Yet)

  Scenario: Validate Payment for TC116 Philippe Lavoie (EU 261 72-Hour Pending � No Payment Yet)
    Given the case is in System Processing Queue pending 72-hour window
    Then no payment flow should be triggered
    And the system should poll DDS for up to 14 days
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And if DDS returns eligible the Welcome Back flow should trigger and then the payment flow should proceed
    And if no answer after 14 days the case should be sent to the agent queue
    And the Claims Dashboard should show case status as "Pending" with no payout section


Feature: Claims Dashboard Validation � TC117 David Cohen (ASL Travel Completed � ?3,670 Eligible)

  Scenario: Validate Claims Dashboard for TC117 David Cohen (ASL Travel Completed � ?3,670 Eligible)
    Given the case has been created for claimant "David Cohen" with PNR "TC117"
    Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delay"
    And the Case Status should be "In Review" or "Done"
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be "David Cohen"
    And the Claimant Type should be "Adult"
    And the Authentication should be "Pass"
    And the PNR should be "TC117"
    And the Regime should be "ASL + APPR"
    And the Full Name should be "David Cohen"
    And the Tags should include "Claimant" and "Adult"
    And the Email should be "d***@gmail.com"
    And the Phone should be "+972***456"
    And the Journey should show "Bound 1: YYZ ? TLV" with claim filed for this flight as arrived late plus 9h
    And the Eligibility and Compensation section should be present and populated with compensation "?3,670 ILS" as ASL fixed rate for Travel Completed Not Extraordinary and delay 8 hours or more
    And the Arrival Delay Code should be "42" as Not Extraordinary Circumstance
    And the Dual Regime should show ASL at ?3,6