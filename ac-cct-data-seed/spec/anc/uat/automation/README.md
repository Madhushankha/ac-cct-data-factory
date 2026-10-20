# anc/uat/automation — no set exists

Ancillary refunds: bag fees (`baggageRefundEligibility`) and seat fees (`seatFeeRefundEligibility`).
One flow, two sections, because the same question is asked of both in the same shape.

No scenarios exist and the flow cannot judge one. Both sections are keyed by EMD number and no EMD
record reaches a seeded booking today, so there is nothing to refund. An EMD publishing lane comes
before a set.
