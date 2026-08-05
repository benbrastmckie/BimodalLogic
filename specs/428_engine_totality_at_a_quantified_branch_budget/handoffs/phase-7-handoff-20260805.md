# Phase 7 handoff (plan 02)

- **Landed** in `Fuel.lean`, immediately after `applyRule_timeLinearity_arms`:
  `applyRule_timeLinearity_arms_trigger`, `src_not_mem_knownTimes_identifyTime`,
  `knownTimes_identifyTime_subset`, `knownTimes_card_lt_identifyTime`,
  `splitOrderedMeasure`, `splitOrderedMeasure_lt_of_timeLinearity`.
- **Scope Hypothesis outcome**: CONFIRMED. `timeLinearity` is the sole producer of
  `.branchingOrdered` — `Tableau.lean:1513-1520` is the only construction site (all other
  occurrences at 1935, 2191, 2237, 2276, 2491, 2502 are consumers/matches), and
  `findApplicableRule`'s own `.branchingOrdered` comment records the same fact.
- `applyRule_timeLinearity_arms_trigger` is an additive strengthening of the landed arms lemma
  (same three arms plus the `firstIncomparablePair` equation). The landed lemma is unmodified.
  Without it the arm-3 case cannot read off `t1, t2 in knownTimes` and `t2 != t1`.
- The decrease is stated in `Prod.Lex (. < .) (. < .)` on `Nat x Nat`.
- G2 is recorded in `splitOrderedMeasure`'s docstring: no fact about `identifyTime`'s output
  ORDERING is proved, assumed, or needed anywhere. Verified by grep: the only lemmas naming
  `identifyTime` in this phase are about the output BRANCH.
- **Verification**: scoped `lake build` green; `sorry` count 0; purely additive.
- **Next action**: Phase 8 — strict `.split` cardinality growth (UNVERIFIED, three cases).
