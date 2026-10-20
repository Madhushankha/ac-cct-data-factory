Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01):
"Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects English
Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "I received a decision that I'm not eligible for compensation for my delayed flight but I disagree. The weather was fine when I was at the airport. I want to dispute this decision."
INTENT DETECTION � DISPUTE:
When the chatbot identifies dispute intent
Then the chatbot responds:
"I understand you'd like to dispute a previous decision on your flight disruption claim. I can help you with that. Let me look up your case."
CASE LOOKUP:
Then the chatbot responds:
"To find your case, could you please provide your booking reference number (PNR) or case reference number?"
And the user provides "My case reference is CASE-FD-20260520-050"
CASE RETRIEVAL:
Then the system searches Case Services for: CASE-FD-20260520-050
And Case Services returns: CASE FOUND
? Case Reference: CASE-FD-20260520-050
? Passenger: Robert Chen
? PNR: TC238
? Journey: YYZ ? YVR, May 20, 2026
? Delay: 5 hours
? Regime: APPR
? Decision: NOT ELIGIBLE
? Reason: NE-01 � Uncontrollable (Code 72 � Weather)
? Decision Date: May 25, 2026
IDENTITY VERIFICATION FOR DISPUTE:
Then the chatbot responds:
"I found your case. Before we proceed with the dispute, I need to verify your identity. I'll send a verification code to the email or phone number associated with your case."
And the chatbot displays options:
� Email: r***@gmail.com
� Phone: +1***789
And the user selects "Email: r***@gmail.com"
Then the chatbot responds:
"I've sent a verification code to your email, please enter it within 15 minutes of receiving it."
And the user provides the OTP code "739281"
Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5)
Then the chatbot responds:
"Your verification was successful."
ORIGINAL DECISION DISPLAY:
Then the chatbot responds:
"Here are the details of your original claim:
� Case Reference: CASE-FD-20260520-050
� Flight: AC 103, Toronto (YYZ) ? Vancouver (YVR)
� Date: May 20, 2026
� Delay: 5 hours
� Decision: Not Eligible
� Reason: The delay was determined to be caused by weather conditions (uncontrollable circumstances), which are outside the airline's control under the Canadian Air Passenger Protection Regulations (APPR).
You mentioned you'd like to dispute this decision. Could you please tell me why you disagree?"
DISPUTE REASON COLLECTION:
And the user provides: "The weather was perfectly clear at Toronto Pearson when I was at the airport. There was no storm, no snow, nothing. I think the weather code is wrong. I also have photos from the airport showing clear skies."
SUPPORTING EVIDENCE UPLOAD:
Then the chatbot responds:
"Thank you for explaining. If you have any supporting evidence (photos, weather reports, screenshots, etc.), you can upload them now. This will help our review team assess your dispute. Accepted formats: PDF, JPG, PNG (max 10MB each)."
And the user uploads:
� Airport_Photo_ClearSkies_1.jpg (photo showing clear skies at YYZ)
� Airport_Photo_ClearSkies_2.jpg (photo showing departure board with no weather delays)
EVIDENCE VALIDATION:
Then the system receives the uploaded files:
? File 1: Airport_Photo_ClearSkies_1.jpg � Format: JPG ?, Size: 3.2 MB ?
? File 2: Airport_Photo_ClearSkies_2.jpg � Format: JPG ?, Size: 2.8 MB ?
DISPUTE CASE CREATION:
Then the system creates a DISPUTE RECORD linked to the original case:
? Dispute Reference: DISPUTE-CASE-FD-20260520-050-001
? Linked Original Case: CASE-FD-20260520-050
? Dispute Reason: Customer disputes weather code � claims clear skies at YYZ at time of departure
? Supporting Evidence: 2 photos uploaded (Airport_Photo_ClearSkies_1.jpg, Airport_Photo_ClearSkies_2.jpg)
? Dispute Status: PENDING REVIEW
? Routing: Dispute Review Team / Manual Review
? Original Decision: Not Eligible (NE-01 � Weather)
? Dispute Filed: June 15, 2026
Then the chatbot responds:
"Thank you, Robert. Your dispute has been submitted and linked to your original case. Here are the details:
� Dispute Reference: DISPUTE-CASE-FD-20260520-050-001
� Original Case: CASE-FD-20260520-050
� Status: Pending Review
� Evidence Uploaded: 2 files
Our Dispute Review Team will re-examine your case, including the evidence you've provided. You will receive an update via email once the review is complete. Please allow up to 30 business days for the dispute review process."
And an alert information is displayed: "Dispute submitted successfully!"
NOTIFICATION (Adobe):
Then the system triggers notification via Adobe:
And a Dispute Received notification email is sent to r***@gmail.com
And the email contains:
Subject: "Your dispute has been received � DISPUTE-CASE-FD-20260520-050-001"
Dispute Reference number
Original Case Reference: CASE-FD-20260520-050
Original Decision: Not Eligible (weather)
Dispute Reason: Customer disputes weather code
Evidence: 2 files received
Status: Pending Review
Expected timeline: 30 business days
Contact information for further questions
END FLOW (GLOB-11):
Then the chatbot offers:
"Is there anything I can help you with?"
� I would like you to � new flow
� No
And the user selects "No"
Then the chatbot responds "Thank you for choosing Air Canada."
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
And the agent searches for the original case
Then the dashboard displays:
ORIGINAL CASE:
� Case Reference: CASE-FD-20260520-050
� Status: Not Eligible ? DISPUTED
� Decision: Not Eligible (NE-01 � Weather)
� Dispute Flag: YES
DISPUTE RECORD:
� Dispute Reference: DISPUTE-CASE-FD-20260520-050-001
� Linked to: CASE-FD-20260520-050
� Status: Pending Review
� Filed: June 15, 2026
� Dispute Reason: Customer disputes weather code � claims clear skies at YYZ
� Evidence: 2 photos (Airport_Photo_ClearSkies_1.jpg, Airport_Photo_ClearSkies_2.jpg)
� Team: Dispute Review Team
� SLA: 30 business days
DISPUTE FLOW VALIDATION:
? Customer returned to chatbot to dispute: YES ?
? Case lookup by case reference: YES ?
? Identity re-verified (OTP): YES ?
? Original decision displayed: YES ?
? Dispute reason collected: YES ?
? Supporting evidence uploaded: YES (2 photos) ?
? Dispute record created and linked to original case: YES ?
? Original case status updated to "Disputed": YES ?
? Routed to Dispute Review Team: YES ?
? Customer notified with dispute reference: YES ?
? SLA: 30 business days ?

Expected Results:
Dispute intent detected; Original case retrieved and verified; Re-authentication performed; Dispute record created and linked to original case; Customer statement and documents captured; Routed to dispute review queue; 15-day SLA; Dashboard shows linked dispute with all supporting materials