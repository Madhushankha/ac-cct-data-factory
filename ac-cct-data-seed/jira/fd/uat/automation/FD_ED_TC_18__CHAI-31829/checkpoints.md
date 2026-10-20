# FD_ED_TC_18 · CHAI-31829 — checkpoints

**Goal:** Customer receives Not Eligible result, disagrees, and initiates a dispute through the chatbot. System must create a dispute record linked to the original case and route to manual review team.

Methods: seed 1, chat 23, email 3, dashboard 4, implied 10, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Customer receives Not Eligible result, disagrees, and initiates a dispute through the chatbot. System must create a dispute record linked to |  |
| CP002 | PREREQUISITES | prerequisite | seed | Original case exists: CASE-FD-20260520-050 (Not Eligible, NE-01 uncontrollable � weather); Customer returns to chatbot to dispute | Original case exists: CASE-FD-20260520-050 (Not Eligible, NE-01 uncontrollable � weather); Customer returns to chatbot to dispute |
| CP003 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP004 | START | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP005 | START | customer | chat | Then user selects English |  |
| CP006 | START | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP007 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP008 | START | customer | chat | And the user says "I received a decision that I'm not eligible for compensation for my delayed flight but I disagree. The weather was fine w | I received a decision that I'm not eligible for compensation for my delayed flight but I disagree. The weather was fine when I was at the airport. I want to dis |
| CP009 | INTENT DETECTION � DISPUTE | system | implied | When the chatbot identifies dispute intent |  |
| CP010 | INTENT DETECTION � DISPUTE | bot | chat | Then the chatbot responds: | I understand you'd like to dispute a previous decision on your flight disruption claim. I can help you with that. Let me look up your case. |
| CP011 | CASE LOOKUP | bot | chat | Then the chatbot responds: | To find your case, could you please provide your booking reference number (PNR) or case reference number? |
| CP012 | CASE LOOKUP | customer | chat | And the user provides "My case reference is CASE-FD-20260520-050" | My case reference is CASE-FD-20260520-050 |
| CP013 | CASE RETRIEVAL | system | implied | Then the system searches Case Services for: CASE-FD-20260520-050 |  |
| CP014 | CASE RETRIEVAL | system | implied | And Case Services returns: CASE FOUND | ? Case Reference: CASE-FD-20260520-050 ? Passenger: Robert Chen ? PNR: TC238 ? Journey: YYZ ? YVR, May 20, 2026 ? Delay: 5 hours ? Regime: APPR ? Decision: NOT  |
| CP015 | IDENTITY VERIFICATION FOR DISPUTE | bot | chat | Then the chatbot responds: | I found your case. Before we proceed with the dispute, I need to verify your identity. I'll send a verification code to the email or phone number associated wit |
| CP016 | IDENTITY VERIFICATION FOR DISPUTE | bot | chat | And the chatbot displays options: | � Email: r***@gmail.com � Phone: +1***789 |
| CP017 | IDENTITY VERIFICATION FOR DISPUTE | customer | chat | And the user selects "Email: r***@gmail.com" | Email: r***@gmail.com |
| CP018 | IDENTITY VERIFICATION FOR DISPUTE | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP019 | IDENTITY VERIFICATION FOR DISPUTE | customer | chat | And the user provides the OTP code "739281" | 739281 |
| CP020 | IDENTITY VERIFICATION FOR DISPUTE | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP021 | IDENTITY VERIFICATION FOR DISPUTE | bot | chat | Then the chatbot responds: | Your verification was successful. |
| CP022 | ORIGINAL DECISION DISPLAY | bot | chat | Then the chatbot responds: | Here are the details of your original claim: � Case Reference: CASE-FD-20260520-050 � Flight: AC 103, Toronto (YYZ) ? Vancouver (YVR) � Date: May 20, 2026 � Del |
| CP023 | DISPUTE REASON COLLECTION | customer | chat | And the user provides: "The weather was perfectly clear at Toronto Pearson when I was at the airport. There was no storm, no snow, nothing.  | The weather was perfectly clear at Toronto Pearson when I was at the airport. There was no storm, no snow, nothing. I think the weather code is wrong. I also ha |
| CP024 | SUPPORTING EVIDENCE UPLOAD | bot | chat | Then the chatbot responds: | Thank you for explaining. If you have any supporting evidence (photos, weather reports, screenshots, etc.), you can upload them now. This will help our review t |
| CP025 | SUPPORTING EVIDENCE UPLOAD | system | implied | And the user uploads: | � Airport_Photo_ClearSkies_1.jpg (photo showing clear skies at YYZ) � Airport_Photo_ClearSkies_2.jpg (photo showing departure board with no weather delays) |
| CP026 | EVIDENCE VALIDATION | system | implied | Then the system receives the uploaded files: | ? File 1: Airport_Photo_ClearSkies_1.jpg � Format: JPG ?, Size: 3.2 MB ? ? File 2: Airport_Photo_ClearSkies_2.jpg � Format: JPG ?, Size: 2.8 MB ? |
| CP027 | DISPUTE CASE CREATION | system | implied | Then the system creates a DISPUTE RECORD linked to the original case: | ? Dispute Reference: DISPUTE-CASE-FD-20260520-050-001 ? Linked Original Case: CASE-FD-20260520-050 ? Dispute Reason: Customer disputes weather code � claims cle |
| CP028 | DISPUTE CASE CREATION | bot | chat | Then the chatbot responds: | Thank you, Robert. Your dispute has been submitted and linked to your original case. Here are the details: � Dispute Reference: DISPUTE-CASE-FD-20260520-050-001 |
| CP029 | DISPUTE CASE CREATION | alert | chat | And an alert information is displayed: "Dispute submitted successfully!" | Dispute submitted successfully! |
| CP030 | NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP031 | NOTIFICATION | email | email | And a Dispute Received notification email is sent to r***@gmail.com |  |
| CP032 | NOTIFICATION | email | email | And the email contains: | Your dispute has been received � DISPUTE-CASE-FD-20260520-050-001 |
| CP033 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP034 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP035 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the original case |  |
| CP038 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: |  |
| CP039 | ORIGINAL CASE | system | implied | � Case Reference: CASE-FD-20260520-050 | � Status: Not Eligible ? DISPUTED � Decision: Not Eligible (NE-01 � Weather) � Dispute Flag: YES |
| CP040 | DISPUTE RECORD | system | implied | � Dispute Reference: DISPUTE-CASE-FD-20260520-050-001 | � Linked to: CASE-FD-20260520-050 � Status: Pending Review � Filed: June 15, 2026 � Dispute Reason: Customer disputes weather code � claims clear skies at YYZ � |
| CP041 | DISPUTE FLOW VALIDATION | system | implied | ? Customer returned to chatbot to dispute: YES ? | ? Case lookup by case reference: YES ? ? Identity re-verified (OTP): YES ? ? Original decision displayed: YES ? ? Dispute reason collected: YES ? ? Supporting e |
| CP042 | EXPECTED RESULTS | verdict | dashboard | Dispute intent detected; Original case retrieved and verified; Re-authentication performed; Dispute record created and linked to original ca | Dispute intent detected; Original case retrieved and verified; Re-authentication performed; Dispute record created and linked to original case; Customer stateme |
