# Phase 6 handoff (plan 02)

- **Landed** in `Fuel.lean`, immediately after `timeChain_of_linearity_saturated`:
  `firstIncomparablePair_spec`, `incomparableB`, `incompPairs`, `mem_incompPairs`,
  `incomparableB_mono`, `incompPairs_mono`, `addFuture_constraints_mono`,
  `incompPairs_lt_addFuture`.
- `mem_incompPairs` and `addFuture_constraints_mono` are two small unplanned membership/
  monotonicity bridges, not a change of decomposition: every planned lemma is present under its
  planned name and planned statement.
- `incompPairs_lt_addFuture` is stated as a conjunction covering BOTH `addFuture` arms
  (`ord.addFuture t1 t2` and `ord.addFuture t2 t1`), which is what the plan's "covers
  timeLinearity arms 1 and 2" requires under a single name.
- `incomparableB`'s body is `firstIncomparablePair`'s test transcribed verbatim (checkable by
  reading `Tableau.lean:420-428` beside it).
- **Verification**: scoped `lake build` green; `sorry` count 0; purely additive.
- **Next action**: Phase 7 — the identification arm and the lexicographic combination.
