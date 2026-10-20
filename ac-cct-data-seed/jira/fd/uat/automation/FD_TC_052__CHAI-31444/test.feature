Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
""Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?""
Then user selects English
Then an alert information is displayed ""Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice.""
Then chatbot asks ""How can I help you today?""
And the user says ""My flight from Montreal to Toronto last year was delayed about 7 hours due to crew issues. I'd like to check if I'm still eligible for compensation""
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
Then the chatbot responds: ""No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation.""
LEGAL DISCLAIMER:
Then the chatbot responds: ""Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?""
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
""I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you.""
And the chatbot responds:
""Please provide your full name exactly as it appears on your ticket, including any middle names if applicable.""
And the user provides ""Luc Bergeron""
Then the chatbot responds:
""Thanks, Luc! And, what is your booking reference number?""
And the user provides ""PNR: TC039""
Then the chatbot searches Trip Tracer for PNR: TC039
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
""To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?""
And the chatbot displays options:
� Email: l***@gmail.com
� Phone: +1***890
And the user selects ""Email: l***@gmail.com""
Then the chatbot responds:
""I've sent a verification code to your email, please enter it within 15 minutes of receiving it.""
And the user provides the OTP code ""482917""
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
""Your verification was successful. Let's proceed to the next step.""
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
And system proceeds to passenger selection
PASSENGER SELECTION (GenUC-06):
Then the chatbot asks:
""How many people are on your claim?""
And the chatbot displays passengers from PNR:
""I found 1 passenger on this booking:
� Luc Bergeron (Adult - Aeroplan Member)
Is this who you'd like to include?""
And the user confirms ""Yes""
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
""I found the following journey:
� Flight: AC 459
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 1, 2025
� Arrival Delay: 7 hours
Is this the journey you'd like to check?""
And the user confirms ""Yes""
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment on selected journey? ? NO (single leg) ? skip GenUC-18
DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination
72-HOUR CHECK:
Then the chatbot checks: Hours since last leg arrival
And the system calculates: Arrival was May 1, 2025; current date is June 15, 2026 ? >72 hours ? PROCEED
CLAIM TIME LIMIT CHECK:
Then the chatbot checks: Filing deadline for APPR = 366 days from disruption
And the system calculates: Disruption May 1, 2025; filing June 15, 2026 ? 420 days ? EXCEEDS 366 days by 54 days ? OUTSIDE LIMITATION
Then the system determines: CLAIM TIME-BARRED ? NOT ELIGIBLE (limitation override)
CRITICAL NOTE � LIMITATION AS ABSOLUTE OVERRIDE:
? Code 64 (Flight Crew Shortage) IS confirmed as Controllable
? 7h delay IS within 6�<9h band (would normally yield $700 CAD Tier 2 / $840 AC Wallet)
? Basic Aeroplan IS linked (9876543210) � AC Wallet top-up would normally apply
? HOWEVER: 420 days > 366 days ? Limitation exceeded ? All of the above is irrelevant
? AC Wallet is NOT offered regardless of Aeroplan linkage � case is NE
NOT ELIGIBLE RESULT (Limitation):
Then the chatbot displays:
""I've reviewed the details of your flight. I understand your flight AC 459 from Montreal (YUL) to Toronto (YYZ) on May 1, 2025 was delayed by 7 hours due to a flight crew shortage. However, under the Air Passenger Protection Regulations (APPR), claims must be filed within one year (366 days) of the disruption. Your claim was submitted on June 15, 2026, which is 420 days after the disruption, exceeding the filing deadline by 54 days. Unfortunately, compensation is no longer available for this flight. We sincerely apologize for the inconvenience and appreciate your understanding.""
NO DDS FULL EVALUATION (skipped � limitation exceeded as pre-DDS gate; Code 64 + delay logged for audit purposes only)
NO PAYMENT FLOW (skipped entirely � time-barred)
NO IDV (not required � NE)
NO FRAUD SCREENING (not triggered � NE)
AC WALLET NOT OFFERED (Basic Aeroplan 9876543210 recognized but NE case � AC Wallet only for eligible cases)
CASE CREATION (GLOB-09):
Then the chatbot responds: ""Thank you. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for: A confirmation email summarizing your claim details.""
And an alert information is displayed: ""Claim submission successful!""
And the system appends the booking record to the case automatically
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Not Eligible notification email is sent to l***@gmail.com
And the email contains: Case Reference, flight details (AC 459 YUL?YYZ, May 1, 2025, 7h delay � Code 64 Crew Shortage), not eligible reason (outside 366-day limitation � 420 days elapsed, exceeded by 54 days), regulation reference (APPR), contact information
END FLOW (GLOB-11):
Then the chatbot offers:
""Is there anything I can help you with?""
� I would like you to � new flow
� No
And the user selects ""No""
Then the chatbot responds ""Thank you for choosing Air Canada.""
CLAIMS DASHBOARD VALIDATION
    Given the case has been created for claimant ""Luc Bergeron"" with PNR ""TC039""
    Then the Case Header Topic/Sub-topic should be ""Travel Disruptions � Delay""
    And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
    And the Case Status should be ""Closed � Not Eligible""
    And the Created date should be populated
    And the Last Updated date should be populated
    And the SLA countdown should be tracking correctly
    And the Team assignment should be correct
    And no banners should be displayed for identified and authenticated Auth Flow 1 user
    And the Decision Assist panel should NOT be greyed out
    And the Claimant Name should be ""Luc Bergeron""
    And the Claimant Type should be ""Adult""
    And the Authentication should be ""Pass""
    And the PNR should be ""TC039""
    And the PNR Creation Date should be populated
    And the Journey ID should be populated
    And the Booking Source should be populated
    And the Booking Office ID should be populated
    And the Regime should be ""APPR""
    And the Full Name should be ""Luc Bergeron""
    And the Tags should include ""Claimant"" and ""Adult""
    And the Email should be ""l***@gmail.com""
    And the Phone should be ""+1***890""
    And the Address should be populated
    And the Aeroplan should be ""9876543210"" linked and in good standing (Basic Member)
    And the Tier Status should be ""Basic / Member""
    And the Journey should show ""Bound 1: YUL ? YYZ"" with claim filed for this flight
    And the Ancillary Fee section should be present
    And the expected ancillary fees should be none
    And the Eligibility and Compensation section should be present and show ""NOT ELIGIBLE"" with reason ""Outside 366-day APPR limitation (420 days elapsed � Code 64 Crew Shortage 7h delay logged for audit only)""
    And the Decision Assist Panel should auto-appear for FD topic
    And DDS should NOT have run a full assessment as the limitation was exceeded before DDS evaluation
    And the eligibility decision should show ""NOT ELIGIBLE"" as time-barred
    And the Duplicate Check should have run automatically using baseline data ""Luc Bergeron + TC039 + YUL?YYZ + FD""
    And the result should be ""No duplicate found""
    And no Duplicate Warning Banner should be displayed
    And the Related Cases tab should show no related cases
    And CyberSource should NOT have been triggered as it only runs for eligible cases
    And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) as it only applies to eligible cases
    And the system should have appended the booking record automatically for identified and authenticated user
    And Trip Tracer poll should NOT be required
    And the agent should have used pull case from My Activities
    And the case status should have transitioned from ""Assigned"" to ""In Progress""
    And a case acknowledgement notification should have been sent
    And a not eligible notification email should have been sent via Adobe
    And the Agent Notes section should be accessible
    And the Audit Log should record all actions with timestamps and before/after values
    And Customer Communications should show the not eligible notification email chronologically
    And the chatbot transcript should be accessible and linked to the case
    And the Attachments tab should be empty
    And the Final Status should be ""Closed � Not Eligible""
    And the case should be in read-only mode with no editable Decision Assist fields
    And the agent should not be able to access Case Search as it is for leads and management only
PAYMENT VALIDATION
    Given the eligibility result is ""NOT ELIGIBLE"" due to outside 366-day APPR limitation (420 days elapsed)
    Then no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And AC Wallet should NOT have been offered despite Basic Aeroplan linkage (9876543210) � AC Wallet only applies to eligible cases
    And the Claims Dashboard should show eligibility as ""NOT ELIGIBLE (Outside Limitation)"" with no compensation record and no payout section
    And the audit log should record Code 64 (Flight Crew Shortage � Controllable) and 7h delay (6�<9h band, Tier 2) for logging purposes only � this data is captured but does not affect the NE outcome
Expected Results:
DDS returns FD-APPR-NE-07. Trip Tracer: Travel date = May 1, 2025; Filing date = June 15, 2026; Days elapsed = 420 days; APPR limitation = 366 days; LIMITATION EXCEEDED by 54 days. Arrival delay code = 64 (Flight Crew Shortage � Controllable); Delay = 7h (6�<9h band); Scheduled arrival = 14:00; Actual arrival = 21:00. Time Limit Check: 420 days > 366 days ? OUTSIDE LIMITATION ? NOT ELIGIBLE. CRITICAL: The limitation check is an absolute override � even though the disruption was controllable Code 64 with 7h delay (normally $700 CAD Tier 2 / $840 AC Wallet for Basic Aeroplan linked member), the claim is time-barred. AC Wallet NOT offered (NE). No grace period, no exceptions, no rounding. DDS may log the delay/controllability data (Code 64, 7h, Tier 2) for audit but the result is definitively NE. Compensation: $0 � limitation expired. Fraud Screening: NOT INVOKED. IDV: NOT REQUIRED. Payment: N/A. Aeroplan: Basic Member (9876543210) recognized � AC Wallet NOT offered. Regime Assessment: APPR = NE-07 (Outside 1-year limitation, 420 days); EU = N/A; ASL = N/A. Claims Dashboard: Case = CASE-FD-20260615-039; Status = Closed � Not Eligible; Reason = Outside 1-year limitation (420 days, exceeded by 54 days); Travel date = May 1, 2025; Filing date = June 15, 2026; Code 64 logged; $0; DDS = FD-APPR-NE-07.