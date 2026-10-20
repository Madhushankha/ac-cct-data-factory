# FD_ED_TC_06 · CHAI-31817 — checkpoints

**Goal:** OTP service is completely unavailable (system outage). Per call transcript, if major services like OTP are down, the chat will be disabled and users receive a "system unavailable" message. No shell case created.

Methods: seed 1, chat 4, dashboard 2, implied 12, report 1

| ID | Section | Kind | Verified by | Step | Expected |
|---|---|---|---|---|---|
| CP001 | GOAL | goal | report | OTP service is completely unavailable (system outage). Per call transcript, if major services like OTP are down, the chat will be disabled a |  |
| CP002 | PREREQUISITES | prerequisite | seed | OTP service: OFFLINE/DOWN (system outage); All other services operational; Customer attempts to file FD claim | OTP service: OFFLINE/DOWN (system outage); All other services operational; Customer attempts to file FD claim |
| CP003 | START | system | implied | Given the OTP service is OFFLINE/DOWN (system outage detected) |  |
| CP004 | START | system | implied | And the system health check identifies: OTP service = UNAVAILABLE |  |
| CP005 | SYSTEM AVAILABILITY CHECK | system | implied | Then the system performs pre-chat health check |  |
| CP006 | SYSTEM AVAILABILITY CHECK | idv | chat | And the system checks critical services: | ? Trip Tracer: ONLINE ? ? Case Services: ONLINE ? ? DDS: ONLINE ? ? CyberSource: ONLINE ? ? OTP Service: OFFLINE ? ? Persona IDV: ONLINE ? ? Adobe Notifications |
| CP007 | SYSTEM AVAILABILITY CHECK | system | implied | And the system determines: CRITICAL SERVICE DOWN (OTP) ? CHATBOT DISABLED | NOTE: Per call transcript � if major services like OTP are down, the chat will be disabled entirely. No partial functionality. No fallback. |
| CP008 | CHATBOT DISABLED � SYSTEM UNAVAILABLE MESSAGE | customer | chat | Given the user opens the agentic chatbot |  |
| CP009 | CHATBOT DISABLED � SYSTEM UNAVAILABLE MESSAGE | system | implied | Then the chatbot does NOT display the standard greeting | Instead, the chatbot displays a system unavailable message: "We're sorry, but our claims service is temporarily unavailable due to system maintenance. Please tr |
| CP010 | CHATBOT DISABLED � SYSTEM UNAVAILABLE MESSAGE | alert | chat | And an alert information is displayed: "System temporarily unavailable" | System temporarily unavailable |
| CP011 | CHATBOT DISABLED � SYSTEM UNAVAILABLE MESSAGE | system | implied | And the chatbot provides: | � Estimated restoration time (if available) � Alternative contact: "If you need immediate assistance, please contact our Customer Relations team at [phone numbe |
| CP012 | SYSTEM MONITORING | system | implied | Then the system monitoring team is alerted: | ? Alert: OTP Service DOWN ? Impact: Chatbot DISABLED for all users ? Priority: CRITICAL ? Estimated users affected: All FD claim users during outage window |
| CP013 | POST-OUTAGE RECOVERY | system | implied | When the OTP service is restored |  |
| CP014 | POST-OUTAGE RECOVERY | system | implied | Then the system health check re-validates all critical services |  |
| CP015 | POST-OUTAGE RECOVERY | system | implied | And the system determines: All critical services ONLINE |  |
| CP016 | POST-OUTAGE RECOVERY | system | implied | And the chatbot is automatically re-enabled |  |
| CP017 | POST-OUTAGE RECOVERY | system | implied | And users can access the chatbot normally |  |
| CP018 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | When the agent navigates to Claims Dashboard |  |
| CP019 | CLAIMS DASHBOARD VALIDATION | dashboard | dashboard | Then the dashboard shows: | � No new cases created during outage window � System outage logged in system health history � Outage duration recorded |
| CP020 | EXPECTED RESULTS | verdict | chat | Chat flow stops at authentication requirement; "System unavailable" message displayed with phone number; Customer directed to phone support; | Chat flow stops at authentication requirement; "System unavailable" message displayed with phone number; Customer directed to phone support; No shell case creat |
