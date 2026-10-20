# FD_ED_TC_19 · CHAI-31830 — checkpoints

**Goal:** Eligible claim was submitted and payment initiated for a 7-hour delay (6�<9h band, APPR Tier 2: $700 CAD) caused by Code 64 (Flight Crew Shortage � Controllable) on a domestic flight. Passenger holds a Basic Aeroplan profile (9876543210). Payment processor attempts $700 CAD Interac e-Transfer, but the bank rejects the payment (account closed). Customer receives notification and returns to chatbot to update banking details. Identity is re-verified via OTP (IDV already passed on original submission). Payment is re-processed to the new email address. Validates: (1) Payment failure handling and status updates for a Tier 2 APPR claim, (2) Re-authentication on customer return, (3) IDV bypass when already completed, (4) Successful re-processing of $700 CAD payout, (5) Dashboard payment audit history tracking.

Methods: chat 28, email 6, dashboard 3, implied 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Eligible claim was submitted and payment initiated for a 7-hour delay (6�<9h band, APPR Tier 2: $700 CAD) caused by Code 64 (Flight Crew Sho |  |
| CP002 | BACKGROUND � ORIGINAL CASE | system | implied | Given a case was previously created: CASE-FD-20260520-060 |  |
| CP003 | BACKGROUND � ORIGINAL CASE | idv | chat | And the case details are: | ? Passenger: Claire Dubois (Basic Aeroplan Member #: 9876543210) ? PNR: TC239 ? Journey: YUL ? YYZ (AC 301), May 20, 2026, delayed 7h (6�<9h band) ? Scheduled A |
| CP004 | PAYMENT FAILURE | system | implied | When the system initiates Interac e-Transfer of $700 CAD to claire.dubois@gmail.com |  |
| CP005 | PAYMENT FAILURE | system | implied | Then the payment processor attempts the transfer |  |
| CP006 | PAYMENT FAILURE | system | implied | And the bank returns: PAYMENT REJECTED | ? Rejection Reason: ACCOUNT CLOSED (the email is no longer linked to an active Interac account) ? Error Code: BANK_REJECT_ACCOUNT_CLOSED ? Payment Status: FAILE |
| CP007 | PAYMENT FAILURE NOTIFICATION | email | email | Then the system triggers notification via Adobe: |  |
| CP008 | PAYMENT FAILURE NOTIFICATION | email | email | And a Payment Failed notification email is sent to claire.dubois@gmail.com |  |
| CP009 | PAYMENT FAILURE NOTIFICATION | email | email | And the email contains: | Action Required: Payment for your Air Canada claim � CASE-FD-20260520-060 We were unable to complete the payment to the email address provided. This may be due  |
| CP010 | CASE STATUS UPDATE | system | implied | Then the system updates the case status: | ? Previous Status: Eligible � Payment Initiated ? New Status: Eligible � Payment Failed (Awaiting Updated Banking Details) ? Payment Failure Reason: Bank reject |
| CP011 | CUSTOMER RETURNS TO CHATBOT | customer | chat | Given the user opens the agentic chatbot |  |
| CP012 | CUSTOMER RETURNS TO CHATBOT | bot | chat | Then the chatbot displays greeting (GLOB-01): | Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today? |
| CP013 | CUSTOMER RETURNS TO CHATBOT | customer | chat | Then user selects English |  |
| CP014 | CUSTOMER RETURNS TO CHATBOT | alert | chat | Then an alert information is displayed "Please note that by using this service, you will interact with an automated chatbot which uses AI to | Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal informati |
| CP015 | CUSTOMER RETURNS TO CHATBOT | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP016 | CUSTOMER RETURNS TO CHATBOT | customer | chat | And the user says "I received an email saying my payment failed for my compensation claim. I need to update my banking details." | I received an email saying my payment failed for my compensation claim. I need to update my banking details. |
| CP017 | INTENT DETECTION � PAYMENT UPDATE | system | implied | When the chatbot identifies payment update intent |  |
| CP018 | INTENT DETECTION � PAYMENT UPDATE | bot | chat | Then the chatbot responds: | I can help you update your payment details. Let me look up your case first. |
| CP019 | CASE LOOKUP | bot | chat | Then the chatbot responds: | Could you please provide your case reference number or booking reference (PNR)? |
| CP020 | CASE LOOKUP | customer | chat | And the user provides "CASE-FD-20260520-060" | CASE-FD-20260520-060 |
| CP021 | CASE RETRIEVAL | system | implied | Then the system searches Case Services for: CASE-FD-20260520-060 |  |
| CP022 | CASE RETRIEVAL | system | implied | And Case Services returns: CASE FOUND | ? Case Reference: CASE-FD-20260520-060 ? Passenger: Claire Dubois (Aeroplan Basic Member #: 9876543210) ? Journey: YUL ? YYZ, 7h delay (Code 64 Crew Shortage) ? |
| CP023 | IDENTITY RE-VERIFICATION | bot | chat | Then the chatbot responds: | I found your case. Before we update your payment details, I need to verify your identity. |
| CP024 | IDENTITY RE-VERIFICATION | bot | chat | And the chatbot displays options: | � Email: c***@gmail.com � Phone: +1***567 |
| CP025 | IDENTITY RE-VERIFICATION | customer | chat | And the user selects "Email: c***@gmail.com" | Email: c***@gmail.com |
| CP026 | IDENTITY RE-VERIFICATION | bot | chat | Then the chatbot responds: | I've sent a verification code to your email, please enter it within 15 minutes of receiving it. |
| CP027 | IDENTITY RE-VERIFICATION | customer | chat | And the user provides the OTP code "518293" | 518293 |
| CP028 | IDENTITY RE-VERIFICATION | system | implied | Then the chatbot validates the OTP code ? CORRECT (attempt 1 of 5) |  |
| CP029 | IDENTITY RE-VERIFICATION | bot | chat | Then the chatbot responds: | Your verification was successful. |
| CP030 | PAYMENT FAILURE EXPLANATION | bot | chat | Then the chatbot responds: | I can see that the payment of $700 CAD for your claim could not be processed. The Interac e-Transfer to your previous email address was unsuccessful. Let's upda |
| CP031 | PAYMENT FAILURE EXPLANATION | customer | chat | And the user selects "Update my Interac e-Transfer email" | Update my Interac e-Transfer email |
| CP032 | UPDATED PAYMENT DETAILS | bot | chat | Then the chatbot responds: | Please provide the new email address where you'd like to receive the Interac e-Transfer. |
| CP033 | UPDATED PAYMENT DETAILS | customer | chat | And the user provides "claire.dubois.new@gmail.com" | claire.dubois.new@gmail.com |
| CP034 | UPDATED PAYMENT DETAILS | system | implied | Then the chatbot confirms: | "Thank you. I'll update your payment details to: � Payment Method: Interac e-Transfer � New Email: claire.dubois.new@gmail.com � Amount: $700 CAD Would you like |
| CP035 | UPDATED PAYMENT DETAILS | customer | chat | And the user confirms "Yes" | Yes |
| CP036 | IDV CHECK � ALREADY COMPLETED | idv | chat | Then the system checks: Has IDV been completed for this case? ? YES (completed during original submission) |  |
| CP037 | IDV CHECK � ALREADY COMPLETED | idv | chat | Then the system determines: IDV ALREADY PASSED � NO NEED TO REPEAT |  |
| CP038 | PAYMENT RE-PROCESSING | system | implied | Then the system updates the case: | ? Payment Email: claire.dubois@gmail.com ? claire.dubois.new@gmail.com ? Payment Status: Failed ? Re-Processing ? Re-Processing Initiated: June 15, 2026 |
| CP039 | PAYMENT RE-PROCESSING | bot | chat | Then the chatbot responds: | Your payment details have been updated and the payment is being re-processed. You should receive the $700 CAD via Interac e-Transfer at claire.dubois.new@gmail. |
| CP040 | PAYMENT RE-PROCESSING | alert | chat | And an alert information is displayed: "Payment re-processing initiated!" | Payment re-processing initiated! |
| CP041 | NOTIFICATION � PAYMENT RE-PROCESSING | email | email | Then the system triggers notification via Adobe: |  |
| CP042 | NOTIFICATION � PAYMENT RE-PROCESSING | email | email | And a Payment Re-Processing notification email is sent to claire.dubois.new@gmail.com |  |
| CP043 | NOTIFICATION � PAYMENT RE-PROCESSING | email | email | And the email contains: | Payment re-processing for your Air Canada claim � CASE-FD-20260520-060 Your payment is being re-processed. Please allow 5 to 10 business days. |
| CP044 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: | Is there anything I can help you with? |
| CP045 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP046 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP047 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP048 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the agent searches for the case |  |
| CP049 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard displays: | � Case Reference: CASE-FD-20260520-060 � Claimant Name: Claire Dubois � Aeroplan: 9876543210 (linked, Basic Member in good standing) � Status: Eligible � Paymen |
