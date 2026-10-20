# FD_TC_226 · CHAI-31618 — checkpoints

**Goal:** Validates that when a parent claims on behalf of a minor/UMNR (Unaccompanied Minor) and passes OTP authentication, the claim is processed through the automated flow.

Methods: seed 3, chat 36, dashboard 15, implied 6, manual 11, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | Validates that when a parent claims on behalf of a minor/UMNR (Unaccompanied Minor) and passes OTP authentication, the claim is processed th |  |
| CP002 | PREREQUISITES | prerequisite | seed | Third-party caller type: Parent | Third-party caller type: Parent |
| CP003 | PREREQUISITES | prerequisite | seed | Passenger is a minor/UMNR | Passenger is a minor/UMNR |
| CP004 | PREREQUISITES | prerequisite | seed | OTP authentication passes | OTP authentication passes |
| CP005 | START | customer | chat | Given the user opens the agentic chatbot |  |
| CP006 | START | bot | chat | Then the chatbot displays greeting (GLOB-01) |  |
| CP007 | START | customer | chat | Then user selects English |  |
| CP008 | START | bot | chat | Then chatbot asks "How can I help you today?" | How can I help you today? |
| CP009 | START | customer | chat | And the user says "My 14-year-old child traveled as an unaccompanied minor and their flight was disrupted. I need to file a claim." | My 14-year-old child traveled as an unaccompanied minor and their flight was disrupted. I need to file a claim. |
| CP010 | START | system | implied | When the chatbot identifies flight disruption intent |  |
| CP011 | START | system | implied | Then the chatbot checks: Is this a third-party submission? ? YES |  |
| CP012 | START | system | implied | Then the chatbot identifies third-party type ? Parent/Guardian (UMNR/Minor) |  |
| CP013 | OTP AUTHENTICATION | system | implied | Then the chatbot initiates OTP verification |  |
| CP014 | OTP AUTHENTICATION | customer | chat | And the user provides the correct OTP code |  |
| CP015 | OTP PASSED | system | implied | Then the system validates OTP ? PASSED |  |
| CP016 | CLAIM PROCEEDS | system | implied | Then the chatbot allows the parent to proceed with the flight disruption claim through the regular automated regulation tree |  |
| CP017 | END FLOW (GLOB-11) | bot | chat | Then the chatbot offers: "Is there anything I can help you with?" | Is there anything I can help you with? |
| CP018 | END FLOW (GLOB-11) | customer | chat | And the user selects "No" | No |
| CP019 | END FLOW (GLOB-11) | bot | chat | Then the chatbot responds "Thank you for choosing Air Canada." | Thank you for choosing Air Canada. |
| CP020 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Given the system correctly identifies the third-party as "Parent/Guardian" claiming for a Minor or UMNR |  |
| CP021 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And OTP authentication has been initiated |  |
| CP022 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the user provides the correct OTP code |  |
| CP023 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system validates OTP as PASSED |  |
| CP024 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the claim should proceed through the regular automated regulation tree |  |
| CP025 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the case should be created and processed automatically |  |
| CP026 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And no manual handoff should be required |  |
| CP027 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Decision Assist Panel should auto-appear for FD topic |  |
| CP028 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And DDS should have run automatically |  |
| CP029 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the eligibility decision should be pre-populated based on the applicable regime and delay tier |  |
| CP030 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Duplicate Check should have run automatically and the result should be "No duplicate found" |  |
| CP031 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the CyberSource result should be "GREEN" |  |
| CP032 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the system should have appended the booking record automatically |  |
| CP033 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the passenger type should be logged as "Minor" or "UMNR" in the Audit Log |  |
| CP034 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the third-party type "Parent/Guardian � OTP Passed � UMNR/Minor" should be logged in the Audit Log |  |
| CP035 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And an eligible or not eligible notification email should have been sent via Adobe based on the DDS result |  |
| CP036 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | And the Final Status should reflect the DDS outcome |  |
| CP037 | CLAIMS DASHBOARD VALIDATION | dashboard | manual | And the case should be in read-only mode after resolution |  |
| CP038 | PAYMENT VALIDATION | payment | chat | Given the third-party type is "Parent/Guardian" claiming for a Minor or UMNR |  |
| CP039 | PAYMENT VALIDATION | payment | chat | And OTP authentication has PASSED |  |
| CP040 | PAYMENT VALIDATION | payment | chat | And the claim proceeds through the regular automated regulation tree as if submitted by the passenger |  |
| CP041 | PAYMENT VALIDATION | payment | chat | Then the payment flow should follow the standard FD compensation process identical to a direct passenger submission |  |
| CP042 | PAYMENT VALIDATION | payment | chat | And the country of residence prompt should be displayed to the parent acting on behalf of the minor |  |
| CP043 | PAYMENT VALIDATION | payment | chat | And the system should determine currency and payment method based on the passenger's country of residence |  |
| CP044 | PAYMENT VALIDATION | payment | chat | And if the passenger's country of residence is "Canada" then the currency should be set to "CAD" and the payment method should be "Interac e |  |
| CP045 | PAYMENT VALIDATION | payment | chat | And if the passenger's country of residence is an EU country then the currency should be set to "EUR" or "GBP" as applicable and the payment |  |
| CP046 | PAYMENT VALIDATION | payment | chat | And if the passenger's country of residence is "Israel" then the currency should be set to "ILS" and the payment method should be "BSM � Ema |  |
| CP047 | PAYMENT VALIDATION | payment | chat | And the Cash vs AC Wallet check should be performed based on whether the minor passenger has an Aeroplan number linked to the booking |  |
| CP048 | PAYMENT VALIDATION | payment | chat | And if no Aeroplan is linked then only Cash should be offered with no AC Wallet option |  |
| CP049 | PAYMENT VALIDATION | payment | chat | And if Aeroplan is linked and account is active and not frozen then BOTH Cash and AC Wallet with 20% top-up should be offered |  |
| CP050 | PAYMENT VALIDATION | payment | chat | And the compensation amount should be determined by the applicable regime and delay tier as per the standard regulation tree |  |
| CP051 | PAYMENT VALIDATION | payment | chat | And for APPR the compensation should be $400 CAD for Tier 1 3 to less than 6hrs or $700 CAD for Tier 2 6 to less than 9hrs or $1,000 CAD for |  |
| CP052 | PAYMENT VALIDATION | payment | chat | And for EU 261 the compensation should follow the distance band and delay thresholds as per standard EU 261 rules |  |
| CP053 | PAYMENT VALIDATION | payment | chat | And for ASL the compensation should follow the ASL fixed rate schedule |  |
| CP054 | PAYMENT VALIDATION | payment | chat | And for dual or triple regime scenarios the fixed priority hierarchy should apply as per standard regime selection rules |  |
| CP055 | PAYMENT VALIDATION | payment | chat | And the compensation amount for a minor or UMNR should be the SAME as for an adult passenger as APPR and EU 261 and ASL do not differentiate |  |
| CP056 | PAYMENT VALIDATION | payment | chat | And IDV at Payment should be triggered via Persona and the parent should complete IDV on behalf of the minor and Persona should return IDV P |  |
| CP057 | PAYMENT VALIDATION | payment | chat | And the Interac e-Transfer email or BSM email should be collected from the parent as the minor may not have their own email or bank account |  |
| CP058 | PAYMENT VALIDATION | payment | chat | And a compensation record should be created in the backend with GL account and cost center |  |
| CP059 | PAYMENT VALIDATION | payment | manual | And in UAT the batch file should be triggered manually in coordination with the Unifier or SAP team |  |
| CP060 | PAYMENT VALIDATION | payment | manual | And if payment method is Interac e-Transfer then Cash should be dispatched to Unifier and Unifier should process the Interac e-Transfer to t |  |
| CP061 | PAYMENT VALIDATION | payment | manual | And if payment method is BSM Email Payment then Cash should be dispatched to Unifier via HSBC channel for BSM |  |
| CP062 | PAYMENT VALIDATION | payment | manual | And if payment method is AC Wallet then the compensation record should be picked up by the daily evening batch file and dispatched to EIP no |  |
| CP063 | PAYMENT VALIDATION | payment | manual | And Unifier or EIP should send an acknowledgement back |  |
| CP064 | PAYMENT VALIDATION | payment | manual | And the end-of-day report should show status "Pending" transitioning to "Cached" or "Rejected" or "Expired" or "Completed" |  |
| CP065 | PAYMENT VALIDATION | payment | manual | And if payment method is Interac e-Transfer and unclaimed after 35 days the status should be Expired |  |
| CP066 | PAYMENT VALIDATION | payment | chat | And if payment fails a failure notification should be sent to the case and the agent should be flagged |  |
| CP067 | PAYMENT VALIDATION | payment | manual | And the Claims Dashboard Compensation tab should show payout details with the correct amount and currency and payment method and status upda |  |
| CP068 | PAYMENT VALIDATION | payment | chat | And the passenger type should be logged as "Minor" or "UMNR" in the Audit Log |  |
| CP069 | PAYMENT VALIDATION | payment | chat | And the third-party type "Parent/Guardian � OTP Passed � UMNR/Minor" should be logged in the Audit Log but should NOT affect the compensatio |  |
| CP070 | PAYMENT VALIDATION | payment | chat | And the payment flow should be identical to a direct adult passenger submission with the only difference being the Interac or BSM email may  |  |
| CP071 | PAYMENT VALIDATION | payment | chat | And if the system erroneously blocks payment or routes to manual handling due to the minor or UMNR flag despite OTP PASS this is a P1 defect |  |
| CP072 | PAYMENT VALIDATION | payment | chat | And if the system erroneously reduces the compensation amount for a minor this is a P1 defect as compensation is not age-dependent under any |  |
