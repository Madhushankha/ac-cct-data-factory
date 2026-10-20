# FD_ED_TC_26 · CHAI-31837 — checkpoints

**Goal:** Customer is persistently angry throughout the flow (not threatening, but consistently negative). System monitors sentiment across multiple messages and offers live agent handoff when negativity threshold is reached. Tests continuous sentiment monitoring vs. single-message detection.

Methods: seed 1, chat 44, api 3, email 2, dashboard 1, implied 19, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer is persistently angry throughout the flow (not threatening, but consistently negative). System monitors sentiment across multiple m |  |
| CP002 | PREREQUISITES | prerequisite | seed | Sentiment analysis with multi-message tracking; Negativity threshold configured (e.g., 3+ consecutive negative messages) | Sentiment analysis with multi-message tracking; Negativity threshold configured (e.g., 3+ consecutive negative messages) |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | NEGATIVE MESSAGE 1 | customer | chat | And the user says "Your airline ruined my vacation. My flight was delayed and nobody cared. I want compensation." | Your airline ruined my vacation. My flight was delayed and nobody cared. I want compensation. |
| CP009 | SENTIMENT ANALYSIS � MESSAGE 1 | system | implied | ? Sentiment: NEGATIVE (angry, accusatory) | ? Threat Level: NONE ? Consecutive Negative Count: 1 of 3 threshold ? Action: CONTINUE FLOW with empathy |
| CP010 | SENTIMENT ANALYSIS � MESSAGE 1 | bot | chat | Then the chatbot responds: | I'm really sorry to hear about your experience. I understand how disappointing that must have been. Let me help you check your eligibility for compensation. |
| CP011 | SENTIMENT ANALYSIS � MESSAGE 1 | bot | chat | Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation." | No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation. |
| CP012 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process... |
| CP013 | IDENTIFICATION | bot | chat | Then the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP014 | NEGATIVE MESSAGE 2 | system | implied | And the user responds "Why do I have to give you all this information? This is ridiculous. Your airline caused the problem and now I have to |  |
| CP015 | SENTIMENT ANALYSIS � MESSAGE 2 | system | implied | ? Sentiment: NEGATIVE (frustrated, accusatory) | ? Threat Level: NONE ? Consecutive Negative Count: 2 of 3 threshold ? Action: CONTINUE FLOW with empathy acknowledgment |
| CP016 | SENTIMENT ANALYSIS � MESSAGE 2 | bot | chat | Then the chatbot responds: | I understand this process can feel frustrating, Karen, and I apologize for the inconvenience. We need this information to verify your identity and process your  |
| CP017 | SENTIMENT ANALYSIS � MESSAGE 2 | bot | chat | And the chatbot responds: | What is your booking reference number? |
| CP018 | NEGATIVE MESSAGE 3 | system | implied | And the user responds "TC246. This better work. I've been trying to get help for weeks and nobody at Air Canada gives a damn. Worst airline  |  |
| CP019 | SENTIMENT ANALYSIS � MESSAGE 3 | system | implied | ? Sentiment: NEGATIVE (angry, disparaging) | ? Threat Level: NONE ? Consecutive Negative Count: 3 of 3 threshold � THRESHOLD REACHED ? Action: OFFER LIVE AGENT HANDOFF (persistent negativity threshold met) |
| CP020 | SENTIMENT ANALYSIS � MESSAGE 3 | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC246 |  |
| CP021 | SENTIMENT ANALYSIS � MESSAGE 3 | verdict | api | And Trip Tracer returns: PNR FOUND |  |
| CP022 | PERSISTENT NEGATIVITY � HANDOFF OFFERED | bot | chat | Then the chatbot responds: | I found your booking, Karen. I can see your frustration, and I want to make sure you have the best experience possible. I have two options for you: � Continue w |
| CP023 | CUSTOMER CHOOSES TO CONTINUE | system | implied | And the user responds "Just keep going. I don't want to wait on hold for an agent." |  |
| CP024 | SENTIMENT ANALYSIS � MESSAGE 4 | system | implied | ? Sentiment: NEGATIVE (still frustrated but willing to continue) | ? Threat Level: NONE ? Action: CONTINUE FLOW � customer declined handoff ? Consecutive Negative Count: RESET (handoff was offered, customer chose to continue) ? |
| CP025 | FLOW CONTINUES � AUTHENTICATION | bot | chat | Then the chatbot responds: | Absolutely, let's keep moving. To verify your identity, I'll send a one-time verification code to your email or phone on file. Where would you like to receive i |
| CP026 | FLOW CONTINUES � AUTHENTICATION | bot | chat | And the chatbot displays options: | � Email: k***@gmail.com � Phone: +1567 |
| CP027 | FLOW CONTINUES � AUTHENTICATION | customer | chat | And the user selects "Email: k@gmail.com" | Email: k@gmail.com |
| CP028 | FLOW CONTINUES � AUTHENTICATION | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP029 | FLOW CONTINUES � AUTHENTICATION | customer | chat | And the user provides the OTP code "482917" | 482917 |
| CP030 | FLOW CONTINUES � AUTHENTICATION | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP031 | FLOW CONTINUES � AUTHENTICATION | bot | chat | Then the chatbot responds: | Your verification was successful. Let's proceed. |
| CP032 | GROUP BOOKING CHECK | verdict | api | Then the system checks Trip Tracer for group booking identifier |  |
| CP033 | GROUP BOOKING CHECK | system | implied | And group booking identifier = NOT PRESENT |  |
| CP034 | PASSENGER SELECTION (GenUC-06) | bot | chat | Then the chatbot displays passengers from PNR: | I found 1 passenger on this booking: � Karen Mitchell (Adult) Is this correct? |
| CP035 | PASSENGER SELECTION (GenUC-06) | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | JOURNEY SELECTION (GenUC-08) | bot | chat | Then the chatbot retrieves booking details and displays: | I found the following journey: � Flight: AC 103 � Route: Toronto (YYZ) ? Vancouver (YVR) � Date: May 25, 2026 � Arrival Delay: 5 hours Is this the journey you'd |
| CP037 | JOURNEY SELECTION (GenUC-08) | customer | chat | And the user confirms "Yes" | Yes |
| CP038 | SEGMENT CHECK | system | implied | Then the chatbot checks: More than 1 segment? ? NO ? skip GenUC-18 |  |
| CP039 | DUPLICATE CLAIM CHECK | system | implied | And Case Services returns: NO existing case found |  |
| CP040 | 72-HOUR CHECK | system | implied | Hours since arrival ? >72 hours ? PROCEED |  |
| CP041 | REGIME DETERMINATION | system | implied | Origin = YYZ (Canada) ? APPR |  |
| CP042 | DDS EVALUATION | system | implied | APPR: Delay 3�6h, Controllable ? ELIGIBLE, $400 CAD |  |
| CP043 | FRAUD SCREENING | system | implied | CyberSource: GREEN |  |
| CP044 | ELIGIBLE RESULT | bot | chat | Then the chatbot displays: | Great news, Karen! I've checked your flight details, and it looks like flight AC 103 from Toronto (YYZ) to Vancouver (YVR) was delayed by about 5 hours. Based o |
| CP045 | NEGATIVE MESSAGE 5 | system | implied | And the user responds "Finally! About time. Let's just get this done." |  |
| CP046 | SENTIMENT ANALYSIS � MESSAGE 5 | system | implied | ? Sentiment: SLIGHTLY NEGATIVE (impatient but accepting) | ? Trend: IMPROVING (from highly negative to slightly negative) ? Consecutive Negative Count: 1 (reset after handoff offer) ? Action: CONTINUE FLOW |
| CP047 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | bot | chat | Then the chatbot asks: | In which country will your reimbursement be deposited? |
| CP048 | CLAIM PAYMENT: COUNTRY OF RESIDENCE FLOW | customer | chat | And the user selects "Canada" | Canada |
| CP049 | CASH vs AC WALLET CHECK | system | implied | No Aeroplan ? cash only |  |
| CP050 | CASH vs AC WALLET CHECK | bot | chat | Then the chatbot responds: "You are entitled to receive a $400 CAD compensation. Would you like to proceed?" | You are entitled to receive a $400 CAD compensation. Would you like to proceed? |
| CP051 | CASH vs AC WALLET CHECK | customer | chat | And user provides "Yes" | Yes |
| CP052 | PAYMENT METHOD � INTERAC E-TRANSFER | bot | chat | Then the chatbot responds: | Your payment will be made through Interac e-Transfer. Please provide the email address where you'd like to receive the transfer. |
| CP053 | PAYMENT METHOD � INTERAC E-TRANSFER | customer | chat | And the user provides "karen.mitchell@gmail.com" | karen.mitchell@gmail.com |
| CP054 | PAYMENT METHOD � INTERAC E-TRANSFER | system | implied | Then the chatbot confirms: "Thank you. Your details have been recorded." |  |
| CP055 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | I must verify your identity for payment security. Please click here to get started |
| CP056 | IDENTITY VERIFICATION � PERSONA | bot | chat | And chatbot displays a button "Get verified" | Get verified |
| CP057 | IDENTITY VERIFICATION � PERSONA | customer | chat | When user clicks on the button |  |
| CP058 | IDENTITY VERIFICATION � PERSONA | idv | chat | And the customer completes identity verification via Persona |  |
| CP059 | IDENTITY VERIFICATION � PERSONA | idv | chat | And Persona returns: IDV PASS |  |
| CP060 | IDENTITY VERIFICATION � PERSONA | bot | chat | Then the chatbot responds: | Your identity has been verified successfully. |
| CP061 | CLAIM AMOUNT CONFIRMATION | bot | chat | Then the chatbot responds: "Please review your compensation details: | Deposit Amount: $400 CAD Payment Method: Interac e-Transfer Would you like me to submit your claim?" |
| CP062 | CLAIM AMOUNT CONFIRMATION | customer | chat | When the user provides: "Yes" | Yes |
| CP063 | CASE CREATION (GLOB-09) | bot | chat | Then the chatbot responds: "Thank you, Karen. Your claim has been submitted and will now be processed within the next 15 days. Please check  | Thank you, Karen. Your claim has been submitted and will now be processed within the next 15 days. Please check your email for a confirmation. |
| CP064 | CASE CREATION (GLOB-09) | alert | chat | And an alert information is displayed: "Claim submission successful!" | Claim submission successful! |
| CP065 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP066 | NOTIFICATION | email | email | And an eligible notification email is sent to k***@gmail.com |  |
| CP067 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP068 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP069 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada. I hope your next trip goes smoothly, Karen!" | Thank you for choosing Air Canada. I hope your next trip goes smoothly, Karen! |
| CP070 | SENTIMENT MONITORING VALIDATION | idv | chat | ? Message 1: NEGATIVE (angry) � empathy provided, flow continued ? | Great news |
| CP071 | EXPECTED RESULTS | verdict | dashboard | Multi-message sentiment tracking works; Threshold reached after 3 consecutive negative messages; Empathy responses increase in warmth as neg | Multi-message sentiment tracking works; Threshold reached after 3 consecutive negative messages; Empathy responses increase in warmth as negativity persists; Li |
