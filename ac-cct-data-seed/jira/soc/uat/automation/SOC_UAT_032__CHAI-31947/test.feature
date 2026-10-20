Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I had a flight from Brussels to Toronto over a year ago that was delayed by about 7 hours. I had to buy food and pay for a hotel. I never filed a claim and want to do it now. Can I still get reimbursed?"
When the chatbot identifies Standards of Care (SoC) intent
Then the chatbot checks: Is this a third-party submission? ? NO

SOC ENTRY (SoC-01):
Then the chatbot displays the case opening legal disclaimer (GenUC-24):
"Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"

IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "[First Name] [Last Name]"
Then the chatbot responds:
"Thanks, [First Name]! And, what is your booking reference number?"
And the user provides "PNR: [PNR Code]"
Then the chatbot searches Trip Tracer for PNR: [PNR Code]
And Trip Tracer returns: PNR FOUND

AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: t***@gmail.com
� Phone: +1***789
And the user selects "Email: t***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "546879"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed to the next step."

Then the chatbot checks if this PNR a group booking ? No
Then the chatbot checks if there are multiple PAX on PNR? ? No

JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 835
� Route: Brussels (BRU) ? Toronto (YYZ)
� Date: January 15, 2025
� Departure Delay: 7 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"

Then the chatbot checks if there are more than 1 segment ? No

DUPLICATE CLAIM CHECK (GenUC-10):
Then the chatbot sends request to Case Services for duplicate check
And Case Services returns: NO existing case found for this passenger + journey combination

72-HOUR CHECK:
Then the chatbot checks if it passed the expected Departure time of the last itinerary ? Yes
Then the chatbot checks has it been more than 72 hours for all segments in the selected journey ? Yes (well beyond � disruption was January 2025)

CLAIM TIME LIMIT CHECK: ? FLOW STOPS HERE
Then the chatbot checks: Filing deadline for EU SOC per departing country
And the system calculates:
� Departing country: Belgium
� Belgium limitation period: 365 days (1 year)
� Disruption date: January 15, 2025
� Filing date: June 8, 2026
� Days elapsed: 509 days
� 509 > 365 ? OUTSIDE LIMITATION PERIOD ? EXPIRED 

? FLOW DOES NOT PROCEED TO:
  ? Triage Eligibility Check (SoC-02b) � SKIPPED
  ? Airline Company Routing � SKIPPED
  ? DDS Evaluation � SKIPPED
  ? Geographic origin check � SKIPPED (limitation expired first)
  ? Fraud Screening � SKIPPED
  ? Receipt Upload � SKIPPED
  (Limitation period check acts as a gate � if expired, no further checks)

 KEY EU DIFFERENCE � COUNTRY-BASED LIMITATION:
Unlike APPR (province-based) and ASL (fixed 1,460 days), EU limitation
varies by DEPARTING COUNTRY:
  - Belgium: 365 days (1 year) ? SHORTEST in EU
  - Italy: 730 days (2 years)
  - Portugal: 1,095 days (3 years)
  - Germany: 1,460 days (4 years)
  - France/Spain: 1,825 days (5 years)
  - UK/Ireland: 2,190 days (6 years)
  - Sweden/Czech Republic: 3,650 days (10 years) ? LONGEST in EU

This test uses Belgium (365 days) because it's the shortest limitation period,
making it easy to demonstrate expiry.

NOTE: If the departing country is NOT in the EU limitation table,
eu_expiration_date is set to null and the case must be escalated for manual review.

DDS RESPONSE CODE = SoC-EU-NE-08

NOT ELIGIBLE RESULT:
Then the chatbot displays: "Unfortunately, too much time has passed since your flight disruption to submit this claim. Your flight AC 835 from Brussels to Toronto was disrupted on January 15, 2025 � approximately 509 days ago. Under the applicable EU regulations for flights departing from Belgium, the filing deadline is 365 days (1 year) from the date of disruption. Since this deadline has passed, your claim is no longer eligible for expense reimbursement."

DISPUTE OPTION (GenUC-15):
Then the chatbot offers: "Do you agree with this assessment, or would you like to dispute it?"
� Agree
� Dispute
And the user selects "Agree"

END FLOW (GLOB-11):
Then the chatbot offers: "Is there anything else I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."



CLAIMS DASHBOARD VALIDATION:
Scenario: Claims Dashboard validation for SoC-EU-NE-08 � Limitation Expired Belgium Not Eligible
  Given the agent opens the Claims Dashboard for the case
  Then the Topic/Sub-topic is "Travel Disruptions � Expenses"
  And the Status is "Closed � Not Eligible"
  And the Created date and Last Updated date are populated
  And the SLA countdown is tracking correctly
  And the Team assignment is correct
  And the Claimant Name is populated
  And the Claimant Type is "Regular"
  And the Authentication is "Pass"
  And the PNR is populated
  And the Regime is "EU"
  And the Full Name is populated
  And the Tags include "Claimant" and "Adult"
  And the Email is "t***@gmail.com"
  And the Phone is "+1***789"
  And the Itinerary shows Journey AC 835 BRU ? YYZ as the claimed flight
  And the Flight Status is "DELAYED (7 hours)"
  And the Eligibility section shows Journey = AC 835 BRU ? YYZ
  And the Flight Leg at Fault is AC 835
  And the Operating Carrier is AC
  And the Disruption Reason is "N/A (not evaluated � limitation expired)"
  And the Delay Minutes is 420 min (7 hours)
  And the Travel Status is "Travelled (delayed)"
  And the Passenger Type is "Regular"
  And the Limitation Period Check is "FAILED"
  And the Departing country is "Belgium"
  And the Limitation is "365 days (1 year) � shortest in EU"
  And the Disruption date is "January 15, 2025"
  And the Filing date is "June 8, 2026"
  And the Days elapsed is "509 days"
  And 509 is greater than 365 so the limitation is EXPIRED
  And the Controllability is "NOT EVALUATED (limitation expired)"
  And the Geographic Check is "NOT EVALUATED (limitation expired)"
  And the Denied Boarding is "No"
  And the DDS Response Code is "SoC-EU-NE-08"
  And unlike APPR (province-based) and ASL (fixed), EU limitation varies by departing country (Belgium 1yr, Germany 4yr, France 5yr, UK 6yr, Sweden 10yr)
  And the Receipt Validator SOC Expense Line Items is "N/A (not reached)"
  And the Duplicate Check result is "No duplicate found"
  And CyberSource is NOT triggered
  And the Dispute option is offered (GenUC-15)
  And the user selected "Agree"
  And the Final Status is "Closed � Not Eligible"
  And the case is in read-only mode

PAYMENT VALIDATION:
Scenario: Payment validation for SoC-EU-NE-08 � Limitation Expired Belgium Not Eligible
  Given the case SoC-EU-NE-08 is determined as NOT ELIGIBLE
  Then no payment flow is triggered
  And no country of residence is asked
  And no compensation record is created
  And no batch file is dispatched
  And no receipt upload is triggered (SOC receipts only triggered for eligible cases)
  And the Claims Dashboard shows Eligibility = "NOT ELIGIBLE" with no compensation record and no payout section

EXPECTED RESULTS:
SoC-EU-NE-08. NOT ELIGIBLE. Claim outside EU limitation period. No receipt upload. No case creation.