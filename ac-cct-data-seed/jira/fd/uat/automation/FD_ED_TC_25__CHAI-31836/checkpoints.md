# FD_ED_TC_25 · CHAI-31836 — checkpoints

**Goal:** Customer uses threatening or aggressive language during the FD flow. Per call transcript: "Sentiment analysis should be used primarily for live agent handoff, while empathy may be relevant for case creation." System must detect threatening sentiment, respond with empathy, and offer live agent handoff.

Methods: seed 1, chat 20, api 2, dashboard 1, implied 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer uses threatening or aggressive language during the FD flow. Per call transcript: "Sentiment analysis should be used primarily for l |  |
| CP002 | PREREQUISITES | prerequisite | seed | Sentiment analysis enabled; Live agent handoff available; Customer is mid-flow in FD claim | Sentiment analysis enabled; Live agent handoff available; Customer is mid-flow in FD claim |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "My flight was delayed 5 hours and I'm furious. I need compensation NOW" | My flight was delayed 5 hours and I'm furious. I need compensation NOW |
| CP009 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP010 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? NO |  |
| CP011 | SENTIMENT ANALYSIS � MESSAGE 1 | system | implied | Then the sentiment analysis engine evaluates the message: | ? Message: "My flight was delayed 5 hours and I'm furious. I need compensation NOW" ? Sentiment: NEGATIVE (frustrated/angry) ? Threat Level: LOW (angry but not  |
| CP012 | SENTIMENT ANALYSIS � MESSAGE 1 | bot | chat | Then the chatbot responds with empathy: | I completely understand your frustration, and I'm sorry about the delay you experienced. Let me help you check your eligibility for compensation right away. |
| CP013 | LEGAL DISCLAIMER | bot | chat | Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-m | Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need y |
| CP014 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you. |
| CP015 | IDENTIFICATION (GenUC-01) | bot | chat | And the chatbot responds: | Please provide your full name exactly as it appears on your ticket, including any middle names if applicable. |
| CP016 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "Robert Angry" | Robert Angry |
| CP017 | IDENTIFICATION (GenUC-01) | bot | chat | Then the chatbot responds: | Thanks, Robert! And, what is your booking reference number? |
| CP018 | IDENTIFICATION (GenUC-01) | customer | chat | And the user provides "TC245" | TC245 |
| CP019 | IDENTIFICATION (GenUC-01) | verdict | api | Then the chatbot searches Trip Tracer for PNR: TC245 |  |
| CP020 | IDENTIFICATION (GenUC-01) | verdict | api | And Trip Tracer returns: PNR FOUND (Auth Flow 1) |  |
| CP021 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email |
| CP022 | AUTHENTICATION (GenUC-05) | bot | chat | And the chatbot displays options: | � Email: r***@gmail.com � Phone: +1456 |
| CP023 | AUTHENTICATION (GenUC-05) | customer | chat | And the user selects "Email: r@gmail.com" | Email: r@gmail.com |
| CP024 | AUTHENTICATION (GenUC-05) | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP025 | THREATENING LANGUAGE � MESSAGE 2 | system | implied | And the user responds: "This is taking too long! If you don't give me my money I swear I will sue Air Canada and make sure everyone knows ho |  |
| CP026 | SENTIMENT ANALYSIS � MESSAGE 2 | system | implied | Then the sentiment analysis engine evaluates the message: | ? Message: "...I swear I will sue Air Canada...I'll come to your office and make a scene!" ? Sentiment: HIGHLY NEGATIVE ? Threat Level: HIGH (threatening langua |
| CP027 | EMPATHY RESPONSE | bot | chat | Then the chatbot responds: | I hear you, Robert, and I truly understand how frustrating this situation must be. Flight delays are stressful, and I want to make sure you get the help you nee |
| CP028 | CUSTOMER CHOOSES LIVE AGENT | system | implied | And the user responds "Connect me to a live agent right now" |  |
| CP029 | LIVE AGENT HANDOFF | system | implied | Then the system initiates live agent handoff |  |
| CP030 | LIVE AGENT HANDOFF | system | implied | And the system transfers the following context to the live agent: | ? Customer Name: Robert Angry ? PNR: TC245 ? Journey: [from Trip Tracer data] ? Flow Progress: Identification COMPLETED, Authentication IN PROGRESS (OTP sent, n |
| CP031 | LIVE AGENT HANDOFF | bot | chat | Then the chatbot responds: | I'm connecting you with a live agent now. I've shared your case details so they can pick up right where we left off. Please hold for a moment. |
| CP032 | LIVE AGENT CONNECTION | system | implied | Then the system connects the customer to a live agent |  |
| CP033 | LIVE AGENT CONNECTION | system | implied | And the live agent receives: | ? Customer context (name, PNR, journey) ? Sentiment alert: THREATENING LANGUAGE � HANDLE WITH CARE ? Flow progress (identification done, authentication pending) |
| CP034 | LIVE AGENT CONNECTION | bot | chat | Then the chatbot displays: | You're now connected with [Agent Name]. They have all the details of your case. Thank you for your patience, Robert. |
| CP035 | SENTIMENT ANALYSIS VALIDATION | system | implied | ? Message 1 sentiment: NEGATIVE (frustrated) � flow continued with empathy ? | ? Message 2 sentiment: HIGHLY NEGATIVE (threatening) � handoff offered ? ? Threat keywords detected: "sue", "come to your office", "make a scene" ? ? Empathy re |
| CP036 | EXPECTED RESULTS | verdict | dashboard | Negative sentiment detected initially; Empathy response triggered; Escalated threatening language detected; Enhanced empathy response; Live  | Negative sentiment detected initially; Empathy response triggered; Escalated threatening language detected; Enhanced empathy response; Live agent handoff offere |
