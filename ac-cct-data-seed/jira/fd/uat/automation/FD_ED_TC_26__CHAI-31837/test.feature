Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
NEGATIVE MESSAGE 1:
And the user says "Your airline ruined my vacation. My flight was delayed and nobody cared. I want compensation."
SENTIMENT ANALYSIS � MESSAGE 1:
? Sentiment: NEGATIVE (angry, accusatory)
? Threat Level: NONE
? Consecutive Negative Count: 1 of 3 threshold
? Action: CONTINUE FLOW with empathy
Then the chatbot responds:
"I'm really sorry to hear about your experience. I understand how disappointing that must have been. Let me help you check your eligibility for compensation."
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process..."
IDENTIFICATION:
Then the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
NEGATIVE MESSAGE 2:
And the user responds "Why do I have to give you all this information? This is ridiculous. Your airline caused the problem and now I have to jump through hoops. My name is Karen Mitchell."
SENTIMENT ANALYSIS � MESSAGE 2:
? Sentiment: NEGATIVE (frustrated, accusatory)
? Threat Level: NONE
? Consecutive Negative Count: 2 of 3 threshold
? Action: CONTINUE FLOW with empathy acknowledgment
Then the chatbot responds:
"I understand this process can feel frustrating, Karen, and I apologize for the inconvenience. We need this information to verify your identity and process your claim securely. I'll make this as quick as possible."
And the chatbot responds:
"What is your booking reference number?"
NEGATIVE MESSAGE 3:
And the user responds "TC246. This better work. I've been trying to get help for weeks and nobody at Air Canada gives a damn. Worst airline ever."
SENTIMENT ANALYSIS � MESSAGE 3:
? Sentiment: NEGATIVE (angry, disparaging)
? Threat Level: NONE
? Consecutive Negative Count: 3 of 3 threshold � THRESHOLD REACHED
? Action: OFFER LIVE AGENT HANDOFF (persistent negativity threshold met)
Then the chatbot searches Trip Tracer for PNR: TC246
And Trip Tracer returns: PNR FOUND
PERSISTENT NEGATIVITY � HANDOFF OFFERED:
Then the chatbot responds:
"I found your booking, Karen. I can see your frustration, and I want to make sure you have the best experience possible. I have two options for you:
� Continue with me � I'll keep processing your claim and get you to a result as quickly as possible. We're almost there.
� Speak with a live agent � If you'd prefer a personal touch, I can connect you with a customer service representative who can help.
What would you prefer?"
CUSTOMER CHOOSES TO CONTINUE:
And the user responds "Just keep going. I don't want to wait on hold for an agent."
SENTIMENT ANALYSIS � MESSAGE 4 (Post-Handoff Offer):
? Sentiment: NEGATIVE (still frustrated but willing to continue)
? Threat Level: NONE
? Action: CONTINUE FLOW � customer declined handoff
? Consecutive Negative Count: RESET (handoff was offered, customer chose to continue)
? Next threshold: 3 more consecutive negative messages before re-offering
FLOW CONTINUES � AUTHENTICATION:
Then the chatbot responds:
"Absolutely, let's keep moving. To verify your identity, I'll send a one-time verification code to your email or phone on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: k***@gmail.com
� Phone: +1567
And the user selects "Email: k@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "482917"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful. Let's proceed."
GROUP BOOKING CHECK:
Then the system checks Trip Tracer for group booking identifier
And group booking identifier = NOT PRESENT
PASSENGER SELECTION (GenUC-06):
Then the chatbot displays passengers from PNR:
"I found 1 passenger on this booking:
� Karen Mitchell (Adult)
Is this correct?"
And the user confirms "Yes"
JOURNEY SELECTION (GenUC-08):
Then the chatbot retrieves booking details and displays:
"I found the following journey:
� Flight: AC 103
� Route: Toronto (YYZ) ? Vancouver (YVR)
� Date: May 25, 2026
� Arrival Delay: 5 hours
Is this the journey you'd like to check?"
And the user confirms "Yes"
SEGMENT CHECK:
Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18
DUPLICATE CLAIM CHECK:
And Case Services returns: NO existing case found
72-HOUR CHECK:
Hours since arrival ? >72 hours ? PROCEED
REGIME DETERMINATION:
Origin = YYZ (Canada) ? APPR
DDS EVALUATION:
APPR: Delay 3�6h, Controllable ? ELIGIBLE, $400 CAD
FRAUD SCREENING:
CyberSource: GREEN
ELIGIBLE RESULT:
Then the chatbot displays:
"Great news, Karen! I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 5 hours. Based on the Canadian Air Passenger Protection Regulations (APPR), you are eligible for compensation of $400 CAD for this delay. I'll guide you through the next steps."
NOTE: The chatbot uses positive, encouraging language ("Great news") to help shift the customer's sentiment after persistent negativity.
NEGATIVE MESSAGE 5 (Post-Eligible Result):
And the user responds "Finally! About time. Let's just get this done."
SENTIMENT ANALYSIS � MESSAGE 5:
? Sentiment: SLIGHTLY NEGATIVE (impatient but accepting)
? Trend: IMPROVING (from highly negative to slightly negative)
? Consecutive Negative Count: 1 (reset after handoff offer)
? Action: CONTINUE FLOW
CLAIM PAYMENT ? INTERAC E-TRANSFER ? IDV ? CONFIRMATION ? CASE CREATION:
CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW:
Then the chatbot asks:
"In which country will your reimbursement be deposited?"
And the user selects "Canada"
CASH vs AC WALLET CHECK:
No Aeroplan ? cash only
Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Would you like to proceed?"
And user provides "Yes"
PAYMENT METHOD � INTERAC E-TRANSFER:
Then the chatbot responds:
"Your payment will be made through Interac e-Transfer. Please provide the email address where you'd like to receive the transfer."
And the user provides "karen.mitchell@gmail.com"
Then the chatbot confirms: "Thank you. Your details have been recorded."
IDENTITY VERIFICATION � PERSONA:
Then the chatbot responds:
"I must verify your identity for payment security. Please click here to get started"
And chatbot displays a button "Get verified"
When user clicks on the button
And the customer completes identity verification via Persona
And Persona returns: IDV PASS
Then the chatbot responds:
"Your identity has been verified successfully."
CLAIM AMOUNT CONFIRMATION:
Then the chatbot responds: "Please review your compensation details:
Deposit Amount: $400 CAD
Payment Method: Interac e-Transfer
Would you like me to submit your claim?"
When the user provides: "Yes"
CASE CREATION (GLOB-09):
Then the chatbot responds: "Thank you, Karen. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for a confirmation."
And an alert information is displayed: "Claim submission successful!"
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And an eligible notification email is sent to k***@gmail.com
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada. I hope your next trip goes smoothly, Karen!"
NOTE: Personalized, warm closing to end on a positive note after a difficult interaction.
SENTIMENT MONITORING VALIDATION:
? Message 1: NEGATIVE (angry) � empathy provided, flow continued ?
? Message 2: NEGATIVE (frustrated) � empathy provided, flow continued ?
? Message 3: NEGATIVE (disparaging) � THRESHOLD REACHED (3/3) � handoff offered ?
? Customer declined handoff � flow continued ?
? Consecutive count reset after handoff offer ?
? Message 4: NEGATIVE (still frustrated) � count 1/3 (reset) ?
? Message 5: SLIGHTLY NEGATIVE (improving) � count 1/3 ?
? No threatening language detected throughout ?
? Empathy responses at each negative message ?
? Positive language used at eligible result ("Great news") ?
? Warm personalized closing ?
? Full flow completed despite persistent negativity ?

Expected Results:
Multi-message sentiment tracking works; Threshold reached after 3 consecutive negative messages; Empathy responses increase in warmth as negativity persists; Live agent handoff offered at threshold; Customer choice respected; Sentiment log shows progression; Dashboard flags persistent negativity for agent/manager awareness