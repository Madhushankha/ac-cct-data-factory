GREETING & INTENT IDENTIFICATION:
Given the user opens the agentic chatbot
Then the chatbot displays greeting (GLOB-01): "Hello! I will be your virtual assistant today. I can assist you in English or French. Which language would you prefer to use today?"
Then user selects "English"
Then the privacy alert is displayed: "Please note that by using this service, you will interact with an automated chatbot which uses AI to answer your questions and requests. Your personal information will be used to identify and authenticate you, to answer your request, and for other purposes detailed in the Privacy Notice."
Then chatbot asks "How can I help you today?"
And the user says "Our flight from Madrid to Toronto arrived about 5 hours late. I'd like to check if my husband and I are eligible for compensation"
When the chatbot identifies flight disruption intent
Then third-party check ? NO
Then the chatbot responds: "No problem, I can help you create a claim for your delayed flight and see if you are eligible for compensation."

LEGAL DISCLAIMER:
Then the chatbot shows the automated decision-making disclaimer ? user agrees to start

IDENTIFICATION (GenUC-01):
User provides "Luc�a Garc�a" and PNR "EU002" ? Trip Tracer PNR FOUND (Auth Flow 1)

AUTHENTICATION (GenUC-05):
User selects Email l***@gmail.com ? OTP "830514" ? CORRECT (attempt 1 of 5) ? "Your verification was successful. Let's proceed to the next step."

GROUP BOOKING CHECK & PASSENGER SELECTION (GenUC-06):
Group booking identifier = NOT PRESENT
"I found 2 passengers on this booking: Luc�a Garc�a (Adult - Aeroplan Member), Javier Garc�a (Adult). Would you like to include all passengers in this claim?" ? "Yes, include both" ? PAX count 2 ? 9 or fewer ? PROCEED

JOURNEY SELECTION (GenUC-08):
Chatbot displays: Flight AC 837, Madrid (MAD) ? Toronto (YYZ), Aug 10, 2026, Arrival Delay 5 hours ? user "Yes"

SEGMENT CHECK:
More than 1 segment ? NO (single leg) ? skip GenUC-18

DUPLICATE, 72-HOUR AND TIME LIMIT CHECKS:
Duplicate check ? no existing case for either passenger
72-hour check ? more than 72 hours ? PROCEED
Time limit ? Spain departure ? 5 years (Aug 10, 2031); 10 days elapsed ? PROCEED

TRIAGE & DDS EVALUATION (EU):
Gate 1: not employee ? PROCEED
Gate 2: promised = actual (no VOL / INVOL)
Gate 3: travelled to final destination (YYZ)
Gate 4: MSL = AC 837 MAD ? YYZ (single leg)
Gate 5: operating carrier = null ? not AC / AC family, STAR or OAL ? CARRIER UNKNOWN
Gate 6: not denied boarding
Gate 7: expiry = Aug 10, 2031 (Spain, 5 years) ? not null
Gate 8: delay 300 min ? 3+ hours ? band DELAY_GTE_4_HOURS
Gate 9: arrival code 96 = Controllable, but can't be applied because the carrier at fault is unknown
Result per passenger: NO_DETERMINATION | FD-EU-ND-xx | reason "Carrier at fault unknown" | EUR 0
And DDS does NOT return Eligible (EUR 600) or Not Eligible
And APPR is also assessed as No Determination (same carrier reason), so no amount is picked under the most generous rule

TRIP TRACER UI VALIDATION (PNR EU002):
? Promised Itinerary: AC 837 MAD ? YYZ, Scheduled Arrival 15:00
? Current Itinerary: AC 837 MAD ? YYZ, ARRIVED LATE, 15:00 ? 20:00, +5H 00M
? Regimes: EU + APPR (2 regimes)
? MSL: AC 837 � MAD ? YYZ � Code 96 (Controllable)
? MSL operating carrier: blank / "Unknown"; isStarSegment = false; isOalSegment = false
? EU expiry: 2031-08-10
? Aeroplan: 9876543210 (Basic Member � linked, claimant)
? MS LUC�A GARC�A | NO DETERMINATION | Carrier unknown | EUR 0.00
? MR JAVIER GARC�A | NO DETERMINATION | Carrier unknown | EUR 0.00
NOTE: If manual review confirms AC is the operating carrier, EU DELAY_GTE_4_HOURS applies (EUR 600 each). It's on hold until then.

FRAUD SCREENING � NOT TRIGGERED:
CyberSource runs only for ELIGIBLE cases ? NOT invoked

AC WALLET / CASH � NOT TRIGGERED:
No offer, even with Basic Aeroplan linked

NO DETERMINATION RESULT:
Chatbot displays the standard No Determination response:
"Based on the information available, we are unable to determine your eligibility at this time."
"Flight disruptions can involve multiple factors, and the reason for a disruption may change as additional information becomes available."
"Your claim will be reviewed and we will respond within 30 days."
And no compensation amount (EUR or CAD) is shown
And no "Would you like us to proceed?" prompt is shown (case created automatically)
And the country of residence question is NOT asked
And no email or phone for BSM, bank name, IBAN or SWIFT/BIC is collected

CASE CREATION (GLOB-09):
Chatbot responds: "Your claim has been submitted. Case Reference: CASE-FD-20260820-402." / "Our team will review your case and contact you within 30 days."
And one case is created for both passengers
And the booking record is appended automatically
And the case is routed to the manual review queue

NOTIFICATION (Adobe):
One acknowledgement email sent to l***@gmail.com for the case, with: Case Reference, both passenger names, AC 837 MAD ? YYZ Aug 10, 2026 (delayed 5h), the No Determination message, contact information
And the email does NOT mention any compensation amount

END FLOW (GLOB-11):
"Is there anything I can help you with?" ? user selects "No" ? "Thank you for choosing Air Canada."

Claims Dashboard Gherkin:
Given the case has been created for claimant "Luc�a Garc�a" with PNR "EU002" covering 2 passengers
Then the Case Header Topic/Sub-topic should be "Travel Disruptions � Delays"
And the agent should be able to edit Topic/Sub-topic but cannot switch automated to non-automated
And the Case Status should be "Forwarded � Manual Review"
And the Created and Last Updated dates should be populated
And the SLA countdown should track the 30-day response commitment
And the Team assignment should be the manual review team
And no banners should be displayed for identified and authenticated Auth Flow 1 user
And the Claimant should be "Luc�a Garc�a", Adult, Authentication "Pass"
And the PNR should be "EU002" with Creation Date, Journey ID, Booking Source and Office ID populated
And the Regime should be "EU" with APPR also listed as applicable
And the passengers should be listed as Luc�a Garc�a (Adult, Claimant, Aeroplan 9876543210, Basic / Member) and Javier Garc�a (Adult)
And the Email should be "l***@gmail.com" and the Address populated
And the Journey should show "Bound 1: MAD ? YYZ" (AC 837, +5H 00M, MSL)
And the MSL operating carrier should show "Unknown" (not AC, STAR or OAL)
And the Disruption Code should show "96 (Controllable)"
And the EU expiry should show "2031-08-10" (Spain, 5 years)
And the Ancillary Fee section should be present and empty
And the Eligibility and Compensation section should show "NO DETERMINATION � Carrier at fault unknown � EUR 0" for each passenger
And no Cash or AC Wallet offer should be recorded
And DDS should have run automatically with no agent action
And Decision Assist should show "No Determination" with carrier unknown as the only reason
And the Duplicate Check should show "No duplicate found" for both passengers using baseline "Luc�a Garc�a + EU002 + MAD?YYZ + FD"
And the CyberSource result should be "Not triggered"
And the IDV status should be "Not triggered"
And the Trip Tracer poll should NOT be required
And Customer Communications should show one acknowledgement email with no compensation amount
And the chatbot transcript should be linked
And the Audit Log should record DDS result, case creation, routing and notification with timestamps
And the Attachments tab should be empty
And the agent should be able to confirm the operating carrier and record a manual decision per passenger
And the agent should not be able to access Case Search as it is for leads and management only

Payment Validation Gherkin:
Given the DDS outcome is "NO DETERMINATION" for both passengers because the carrier at fault is unknown
Then no country of residence should be collected for payment
And no Cash or AC Wallet option should be offered
And no BSM email or phone, bank name, IBAN or SWIFT/BIC should be collected
And Persona IDV for payout should not be triggered
And no payment record should be created for either passenger
And nothing should be picked up by the evening batch file
And nothing should be sent to Unifier (HSBC) or Ariba
And the Compensation tab should show EUR 0 per passenger and EUR 0 total
And if manual review later finds the claim eligible, a Spain resident should be offered BSM � Email Payment in EUR, collecting email and phone, with Manual (Ariba) as the fallback, and one payment record per passenger

Expected Results:
DDS returns NO DETERMINATION (FD-EU-ND-xx, carrier unknown) for both passengers, EUR 0. It doesn't return EUR 600 or Not Eligible, even though the delay (5h), the code (96) and the Spain expiry all pass. The chatbot shows the standard No Determination message and creates one case automatically. The case is Forwarded � Manual Review with a 30-day SLA. No CyberSource check, offer, IDV, BSM or bank details, or payment records.