# Phase 8 handoff (plan 02)

- **Outcome**: the strict lemma CLOSED. R2's sanctioned fallback (carrying strictness as a
  hypothesis) was NOT needed and was NOT used. All three cases discharged.
- **Landed** in `Fuel.lean`, immediately after `expandOnceUnblocked_split_card_le`:
  `branching_arms_new_of_guard` (case 1), `applyRule_branching_arms_fresh` (cases 2+3),
  `findApplicableRule_branching_guard`, `applyRule_serialityRule_not_branching`,
  `applyRule_timeLinearity_not_branching`, `findApplicableSerialRule_not_branching`,
  `findApplicableLinearityRule_not_branching`, and the target
  `expandOnceUnblocked_split_card_lt`.
- **Scope Hypothesis outcome**: CONFIRMED, exactly THREE cases. `findApplicableRule`'s
  `.branching` arm (Tableau.lean:1943-1948) has exactly two guard bypasses, `ruleSelfGuarded`
  then `ruleMintsFreshLabel`, before the `bss.any` containment test. No fourth bypass exists.
  `findApplicableRule_branching_guard` pins this to the source rather than to a reading of it.
- **One thing the plan's three-case framing did not name, and how it was handled**: the other
  two pick stages are unguarded entirely, so a fourth case would have been needed had they been
  able to produce `.branching`. They cannot — `serialityRule` reports only
  `.notApplicable`/`.persistent` and `timeLinearity` only `.notApplicable`/`.branchingOrdered`.
  That is now a theorem (`applyRule_serialityRule_not_branching`,
  `applyRule_timeLinearity_not_branching`), not an assumption. This is not a guard bypass and
  does not change the three-case count.
- Cases 2 and 3 share one lemma because they share their witness: `Branch.nextTime` plus the
  landed `not_mem_of_time_nextTime`. The 36-rule case analysis leaves exactly four live rules
  (`.untlNeg`, `.snceNeg`, `.untlPos`, `.sncePos`).
- The landed non-strict `expandOnceUnblocked_split_card_le` is present and unmodified.
- **Verification**: scoped `lake build` green; `sorry` count 0; purely additive.
- **Next action**: Phase 9 — split-fold preservation helpers.
