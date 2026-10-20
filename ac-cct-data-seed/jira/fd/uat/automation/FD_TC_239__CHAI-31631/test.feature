GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "My flight from Montreal to Toronto was delayed about 7 hours, I'd like to check if I'm eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot shows the automated decision-making disclaimer ? user agrees to start

IDENTIFICATION (GenUC-01):
User provides "S�bastien Lachance" and PNR "ID040" ? Trip Tracer PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
User selects Email s***@gmail.com ? OTP "275806" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next step."
And no UMNR / YP flag on the PNR

PASSENGER & JOURNEY SELECTION (GenUC-06 / GenUC-08):
Group booking identifier = NOT PRESENT
"I found 1 passenger on this booking: S�bastien Lachance (Adult - Aeroplan Member). Is this who you'd like to include?" ? "Yes"
AC 412, YUL ? YYZ, July 20, 2026, Arrival Delay 7 hours ? "Yes"

CHECKS:
Single leg ? skip GenUC-18; duplicate check ? none; 72-hour check ? PROCEED; APPR limit ? 8 days (within 366 days) ? PROCEED

DDS EVALUATION:
APPR; Code 96 Controllable; 420 min ? 6 to under 9 hrs; ELIGIBLE; FD-APPR-EL-02; CAD 700

TRIP TRACER UI VALIDATION (ID040):
? Promised: AC 412, YUL ? YYZ, 12:00
? Current: ARRIVED LATE, 12:00 ? 19:00, +7H 00M
? Regime: APPR (1 regime)
? MSL: AC 412 � YUL ? YYZ � 96 "Delayed due to operations control" � CONTROLLABLE
? Aeroplan: 9876543210 (Basic Member � linked)
? MR S�BASTIEN LACHANCE | ELIGIBLE | DELAY_6_TO_LT_9_HOURS | CAD 700.00 Cash / CAD 840.00 AC Wallet

ELIGIBLE RESULT (FD-05a):
Chatbot shows the APPR eligible message for AC 412 (about 7 hours)

CLAIM PAYMENT � COUNTRY & FRAUD (GenUC-16a.1 / GLOB-05):
Chatbot asks: "In which country will your reimbursement be deposited?" ? user selects "Canada" ? currency CAD
CyberSource ? GREEN ? PROCEED

AEROPLAN / AC WALLET OFFER (GenUC-16a.2):
System checks Aeroplan: 9876543210, Basic Member, good standing ? both options offered
Chatbot: "Since you are an Aeroplan member, you can choose to either receive:
* Cash: CAD $700 sent via Interac e-Transfer, takes 5 to 10 business days to process.
* AC Wallet: CAD $840 (including a 20% bonus) added to your AC Wallet immediately with no expiry.
How would you like to receive your funds?"
User selects "Cash"
And AC Wallet is recorded as offered but not selected

PAYMENT METHOD ROUTING (GenUC-17.1 / GenUC-17a):
Country = Canada ? Interac
Chatbot: "Your payment will be made through Interac e-Transfer. Before we move forward, please confirm the email address where you'd like to receive your payment related information. Would you like to use s***@gmail.com? Please note that only one email address can be used for this compensation/reimbursement and it can't be changed once confirmed."
User: "Yes, use this email"
And no address, bank, card or Transit/Institution details are asked for

PAYOUT IDV � CUSTOMER DECLINES (GenUC-17e / GenUC-19.1 / GenUC-19.2 b):
System checks "Completed IDV?" ? NO
Chatbot: "I must verify your identity for payment security. Please click here to get started" and shows the "Get verified >" button (link active 2 hours)
User says: "I don't want to upload my ID or a selfie, I want to protect my identity"
Then IDV context = Payment
And the customer's consent is recorded as NOT given
And the chatbot tells the customer that someone will contact them to verify their identity manually, and that they will get an email with next steps
And the Claim Amount Confirmation (GenUC-20b) is NOT shown
And the claim is NOT submitted for payment
And the bot does NOT offer to switch to AC Wallet to skip IDV
And NO CyberSource flag is raised
And the case is routed to Manual Handoff via Case Services (queue: CR)
And the chatbot offers "Is there anything I can help you with?" ? user "No" ? "Thank you for choosing Air Canada."

NOTIFICATION � MANUAL VERIFICATION NEXT STEPS:
An email is sent to s***@gmail.com with the case reference (CASE-FD-20260728-040) and the next steps for manual identity verification
And the email does NOT confirm a payment, payment date or AC Wallet credit

PART B � CR AGENT SCHEDULES mIDV (AUG 3):
Given Sarah Martin pulls the case from My Activities ? Assigned ? In Progress
Then Decision Assist shows ELIGIBLE, FD-APPR-EL-02, CAD 700
And the payout selection shows Cash (Interac); AC Wallet CAD 840 offered but not selected
And the IDV status shows "Not consented (payout)"
And a banner or tag shows that payout is blocked until identity is verified
When Sarah schedules video verification and sends the invitation to the other email address the customer gave
Then the invitation is logged in Customer Communications
And the case status is "Awaiting Customer Info" (manual IDV)

PART C � mIDV FAILS (AUG 4):
Given the customer joins the video call
When Sarah compares the government ID shown with the claimant (S�bastien Lachance), the booking and the Aeroplan profile
Then the name or photo on the ID doesn't match the claimant
And Sarah records the mIDV result = FAIL (Not Verified)
And the IDV result is saved to the case and can't be edited
And Sarah writes a short, factual internal note, with no personal details beyond what's needed
And the case is flagged or visible in the Fraud failed-IDV view (to confirm)

PART D � CLAIM DECLINED AND CLOSED:
When Sarah rejects the case
Then an automated message tells the customer the claim was declined
And the message does NOT disclose itinerary details, the fraud check or the internal reason
And no secure payment link is sent
And no AC Wallet credit is made to 9876543210
And the case status becomes Closed
And Decision Assist and payment fields become read-only

Claims Dashboard Gherkin:
Given case "CASE-FD-20260728-040" for claimant "S�bastien Lachance" (PNR "ID040") has DDS "ELIGIBLE", "FD-APPR-EL-02", "CAD 700"
And the customer has Basic Aeroplan "9876543210" linked and in good standing
And the customer selected "Cash" over AC Wallet
And the customer declined consent for payout IDV in the chatbot
Then the case should be routed to Manual Handoff in the CR queue
And no CyberSource flag should be raised for the consent refusal
And the IDV status should show "Not consented (payout)"
And the payout should be blocked
And the Topic/Sub-topic should be "Travel Disruptions � Delays"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Created and Last Updated dates should be populated
And the SLA countdown should be tracking correctly
And the Claimant should be "S�bastien Lachance", Adult, Authentication "Pass (OTP)"
And the PNR should be "ID040" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "APPR"
And the Tags should include "Claimant" and "Adult"
And the Email should be "s***@gmail.com"
And the Aeroplan should be "9876543210" linked, Tier Status "Basic / Member"
And the Journey should show "Bound 1: YUL ? YYZ" (AC 412, +7H 00M, Code 96)
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "ELIGIBLE � CAD 700 � Cash (Interac)" with no payment issued
And AC Wallet CAD 840 should show as offered but not selected
And the Duplicate Check should show "No duplicate found"
And the CyberSource result should be "GREEN"
When the CR agent schedules video verification using another email address
Then the invitation should be logged in Customer Communications
And the status should be "Awaiting Customer Info"
When the agent records the mIDV result as "FAIL"
Then the IDV result should be saved and not editable
And no passenger, Aeroplan or flight fields should be updated automatically from the failed verification
And any related notes should be free text only
When the agent rejects the case
Then an automated "claim declined" message should be sent to the customer
And the message should not disclose itinerary or fraud details
And no payment link should be sent
And the case status should be "Closed"
And the Audit Log should record in order: created, DDS Eligible, CyberSource GREEN, Cash selected (AC Wallet offered), Interac email confirmed, IDV consent declined, Manual Handoff to CR, Assigned, In Progress, mIDV scheduled, mIDV FAIL, rejection, decline message sent, Closed, with actor and timestamp
And the chatbot transcript should be linked
And the case should be read-only after closure
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the customer's country of residence is "Canada"
And the customer has Basic Aeroplan "9876543210" linked in good standing
Then both Cash (CAD 700) and AC Wallet (CAD 840) should be offered
When the customer selects "Cash"
Then the currency should be "CAD" and the payment method "Interac e-Transfer"
And only the email "s***@gmail.com" should be collected
And no address, bank, card or Transit/Institution details should be collected
When the customer declines payout IDV
Then the claim should not be submitted for payment
And no compensation record should be created
When the manual IDV fails and the case is closed
Then no compensation record should exist
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier or EIP
And no Interac transfer should be issued or show a status
And no AC Wallet credit should be made to account 9876543210
And the Compensation tab should show "Eligible CAD 700 � not paid (identity not verified)"

Expected Results:
DDS FD-APPR-EL-02, ELIGIBLE, CAD 700. CyberSource GREEN. Basic Aeroplan linked, so Cash CAD 700 and AC Wallet CAD 840 are both offered. The customer picks Cash ? Interac, email only. The customer declines Persona IDV at payout, so the claim isn't submitted. The case goes to CR through Manual Handoff with no CyberSource flag. The CR video check fails, and the result is saved and can't be changed. The agent rejects the case, an automated decline message is sent and the claim is closed. No compensation record, no AC Wallet credit, no batch pickup, no Unifier or EIP dispatch, no Interac transfer.