Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight was delayed 5 hours and I'm furious. I need compensation NOW"
When the chatbot identifies flight disruption intent
Then the chatbot checks: Is this a third-party submission? ? NO
SENTIMENT ANALYSIS � MESSAGE 1:
Then the sentiment analysis engine evaluates the message:
? Message: "My flight was delayed 5 hours and I'm furious. I need compensation NOW"
? Sentiment: NEGATIVE (frustrated/angry)
? Threat Level: LOW (angry but not threatening)
? Action: CONTINUE FLOW with empathy acknowledgment
Then the chatbot responds with empathy:
"I completely understand your frustration, and I'm sorry about the delay you experienced. Let me help you check your eligibility for compensation right away."
LEGAL DISCLAIMER:
Then the chatbot responds: "Please note that the assessment and decision regarding your request will be made through an automated decision-making process. To file your claim, you'll need your booking reference, the name associated to the booking and any receipts you'd like to be reimbursed for. If your claim is eligible, you may also need to provide your address, contact information and where you'd like the funds deposited. Would you like to get started?"
IDENTIFICATION (GenUC-01):
Then the chatbot responds:
"I can definitely help you with that. To start I'll just need to know some information to be able to process your request and identify you."
And the chatbot responds:
"Please provide your full name exactly as it appears on your ticket, including any middle names if applicable."
And the user provides "Robert Angry"
Then the chatbot responds:
"Thanks, Robert! And, what is your booking reference number?"
And the user provides "TC245"
Then the chatbot searches Trip Tracer for PNR: TC245
And Trip Tracer returns: PNR FOUND (Auth Flow 1)
AUTHENTICATION (GenUC-05):
Then the chatbot responds:
"To keep your account secure and assist you further, I'll need to verify your identity. I'll do this by sending a one-time verification code to either your email or phone number on file. Where would you like to receive it?"
And the chatbot displays options:
� Email: r***@gmail.com
� Phone: +1456
And the user selects "Email: r@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
THREATENING LANGUAGE � MESSAGE 2 (DURING OTP ENTRY):
And the user responds: "This is taking too long! If you don't give me my money I swear I will sue Air Canada and make sure everyone knows how terrible you are. I'll come to your office and make a scene!"
SENTIMENT ANALYSIS � MESSAGE 2:
Then the sentiment analysis engine evaluates the message:
? Message: "...I swear I will sue Air Canada...I'll come to your office and make a scene!"
? Sentiment: HIGHLY NEGATIVE
? Threat Level: HIGH (threatening language � "come to your office and make a scene")
? Keywords Detected: "sue", "come to your office", "make a scene"
? Action: EMPATHY RESPONSE + LIVE AGENT HANDOFF OFFERED
EMPATHY RESPONSE:
Then the chatbot responds:
"I hear you, Robert, and I truly understand how frustrating this situation must be. Flight delays are stressful, and I want to make sure you get the help you need. I'm doing my best to process your claim as quickly as possible.
If you'd prefer, I can connect you with a live agent who can assist you personally. Would you like to:
� Continue with me � I'll keep processing your claim
� Speak with a live agent � I'll transfer you to a customer service representative"
CUSTOMER CHOOSES LIVE AGENT:
And the user responds "Connect me to a live agent right now"
LIVE AGENT HANDOFF:
Then the system initiates live agent handoff
And the system transfers the following context to the live agent:
? Customer Name: Robert Angry
? PNR: TC245
? Journey: [from Trip Tracer data]
? Flow Progress: Identification COMPLETED, Authentication IN PROGRESS (OTP sent, not yet verified)
? Sentiment Flag: HIGH � THREATENING LANGUAGE DETECTED
? Sentiment History:
Message 1: NEGATIVE (frustrated) � continued flow
Message 2: HIGHLY NEGATIVE (threatening) � handoff triggered
? Transcript: Full conversation history attached
Then the chatbot responds:
"I'm connecting you with a live agent now. I've shared your case details so they can pick up right where we left off. Please hold for a moment."
LIVE AGENT CONNECTION:
Then the system connects the customer to a live agent
And the live agent receives:
? Customer context (name, PNR, journey)
? Sentiment alert: THREATENING LANGUAGE � HANDLE WITH CARE
? Flow progress (identification done, authentication pending)
? Full conversation transcript
Then the chatbot displays:
"You're now connected with [Agent Name]. They have all the details of your case. Thank you for your patience, Robert."
NO CASE CREATION BY CHATBOT (live agent takes over � agent will complete the flow)
NO DDS EVALUATION BY CHATBOT (deferred to live agent)
NO PAYMENT FLOW BY CHATBOT (deferred to live agent)
SENTIMENT ANALYSIS VALIDATION:
? Message 1 sentiment: NEGATIVE (frustrated) � flow continued with empathy ?
? Message 2 sentiment: HIGHLY NEGATIVE (threatening) � handoff offered ?
? Threat keywords detected: "sue", "come to your office", "make a scene" ?
? Empathy response provided: YES ?
? Live agent handoff offered: YES ?
? Customer chose live agent: YES ?
? Context transferred to agent: YES (name, PNR, sentiment flag, transcript) ?
? Sentiment flag visible to agent: YES ("THREATENING LANGUAGE � HANDLE WITH CARE") ?

Expected Results:
Negative sentiment detected initially; Empathy response triggered; Escalated threatening language detected; Enhanced empathy response; Live agent handoff offered; Both paths (continue/handoff) functional; Sentiment logged with timestamps; Transcript includes sentiment markers; Dashboard shows sentiment flags for agent/manager visibility