# baggage/uat/automation — no set exists

No baggage scenarios have been written, and the flow cannot judge one yet. `flows/pending.py`:

1. **A bag-event lane is missing.** The engine decides a delayed-bag claim from the events it
   holds; a row written straight into a database is invisible to it. Until something publishes bag
   events, a seeded baggage case has nothing for the engine to fold.
2. **Baggage answers per bag**, not per passenger, so it needs its own row shape.
3. **Receipts**, for the interim-expenses section.

Baggage reads two sections: `baggageClaimEligibility` and `interimExpensesEligibility`. Interim
expenses are the essentials a passenger buys while their bag is missing, so that section is decided
by the bag's delay, not the flight's — it is not a standards-of-care question.
