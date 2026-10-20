Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight is on May 21st and I heard there might be delays. I'd like to file a compensation claim in advance"
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
And the user provides "Philippe Tremblay"
Then the chatbot responds:
"Thanks, Philippe! And, what is your booking reference number?"
And the user provides "PNR: TC063"
Then the chatbot searches Trip Tracer for PNR: TC063
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
And Trip Tracer data (passenger info, journey details) is revealed to the customer
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: p***@gmail.com
� Phone: +1***012
And the user selects "Email: p***@gmail.com"
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
� Philippe Tremblay (Adult)
Is this who you'd like to include?"
And the user confirms "Yes"
Then the chatbot checks: PAX count on PNR = 1 ? ?9 ? NOT a group booking ? PROCEED
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 507
� Route: Montreal (YUL) ? Toronto (YYZ)
� Date: May 21, 2026
� Status: SCHEDULED (not yet departed)
Is this the journey you'd like to check?"
And the user confirms "Yes"
PRE-TRAVEL CHECK:
Then the system checks: Has the flight departed?
And the system calculates: Flight date = May 21, 2026; Current date = May 18, 2026 ? FLIGHT HAS NOT YET DEPARTED
Then the system determines: PRE-TRAVEL ? REJECTED (cannot file claim for a flight that hasn't occurred)
PRE-TRAVEL REJECTION RESULT:
Then the chatbot displays:
"I understand you'd like to file a claim, but it looks like your flight AC 507 from Montreal (YUL) to Toronto (YYZ) on May 21, 2026 has not yet departed. Claims can only be filed after your flight has taken place. Please come back after your travel is complete, and I'll be happy to assist you with your claim."
NO DDS EVALUATION (cannot run � flight not departed)
NO PAYMENT FLOW (skipped)
NO IDV (skipped)
NO FRAUD SCREENING (skipped)
NO CASE CREATION (no case created for pre-travel rejection)
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."

CLAIMS DASHBOARD VALIDATION
    Given the system detected the flight has not yet departed for PNR "TC063" with flight date May 21 and current date May 18
    Then the chatbot should have informed the customer that claims can only be filed after travel is complete
    And no DDS evaluation should have occurred
    And no case should have been created in the system
    And no Claims Dashboard entry should exist for PNR "TC063"
    And when searching Claims Dashboard by PNR "TC063" no case should be found

PAYMENT VALIDATION
    Given the claim was rejected because the flight has not yet departed
    Then no case was created so no payment flow should be triggered
    And no country of residence should have been asked
    And no compensation record should have been created
    And no batch file should have been dispatched
    And no Claims Dashboard entry should exist as no case exists

Expected Results:
Flight Date Check: Flight date = May 22, 2026; Current date = May 20, 2026; Flight is FUTURE (has not occurred) ? PRE-TRAVEL REJECTION. DDS: NOT INVOKED � cannot assess a flight that hasn't happened. No disruption data exists. Case: NOT CREATED � no shell case, no reference number generated. There is nothing to track for a future flight. Customer Messaging: "We appreciate you reaching out. However, we are unable to process a flight disruption claim before your travel date. Please come back 72 hours after the expected arrival of the final leg of your journey on May 22, 2026. This allows us to properly assess your claim." Fraud Screening: NOT INVOKED. Payment: N/A. Claims Dashboard: NO ENTRY � no case created, no DDS invoked, pre-travel rejection only. Key Distinction from 72-hour check (TC_068): TC_068 = flight has occurred but <72hrs have passed (case created, pending). TC_077 = flight hasn't occurred at all (no case created, rejected outright).