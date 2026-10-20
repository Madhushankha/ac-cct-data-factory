Given the OTP service is OFFLINE/DOWN (system outage detected)
And the system health check identifies: OTP service = UNAVAILABLE
SYSTEM AVAILABILITY CHECK (Pre-Chat):
Then the system performs pre-chat health check
And the system checks critical services:
? Trip Tracer: ONLINE ?
? Case Services: ONLINE ?
? DDS: ONLINE ?
? CyberSource: ONLINE ?
? OTP Service: OFFLINE ?
? Persona IDV: ONLINE ?
? Adobe Notifications: ONLINE ?
And the system determines: CRITICAL SERVICE DOWN (OTP) ? CHATBOT DISABLED
NOTE: Per call transcript � if major services like OTP are down, the chat will be disabled entirely. No partial functionality. No fallback.
CHATBOT DISABLED � SYSTEM UNAVAILABLE MESSAGE:
Given the user opens the agentic chatbot
Then the chatbot does NOT display the standard greeting
Instead, the chatbot displays a system unavailable message:
"We're sorry, but our claims service is temporarily unavailable due to system maintenance. Please try again later. We apologize for the inconvenience."
And an alert information is displayed: "System temporarily unavailable"
And the chatbot provides:
� Estimated restoration time (if available)
� Alternative contact: "If you need immediate assistance, please contact our Customer Relations team at [phone number] or [email]."
� Link to Air Canada website for manual claim submission
NO IDENTIFICATION (chatbot disabled)
NO AUTHENTICATION (chatbot disabled)
NO JOURNEY SELECTION (chatbot disabled)
NO DDS EVALUATION (chatbot disabled)
NO CASE CREATION (no case created � chatbot disabled)
NO SHELL CASE (per call transcript � no shell case when system is down)
NO NOTIFICATION (no case to notify about)
SYSTEM MONITORING:
Then the system monitoring team is alerted:
? Alert: OTP Service DOWN
? Impact: Chatbot DISABLED for all users
? Priority: CRITICAL
? Estimated users affected: All FD claim users during outage window
POST-OUTAGE RECOVERY:
When the OTP service is restored
Then the system health check re-validates all critical services
And the system determines: All critical services ONLINE
And the chatbot is automatically re-enabled
And users can access the chatbot normally
CLAIMS DASHBOARD VALIDATION:
When the agent navigates to Claims Dashboard
Then the dashboard shows:
� No new cases created during outage window
� System outage logged in system health history
� Outage duration recorded

Expected Results:
Chat flow stops at authentication requirement; "System unavailable" message displayed with phone number; Customer directed to phone support; No shell case created; No identification completed; Error logged in monitoring; Operations team alerted