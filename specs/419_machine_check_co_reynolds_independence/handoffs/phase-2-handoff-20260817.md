# Phase 2 handoff — the looping-duration lemmas

- **State**: `FormalSystem/Metalogic/Independence/LoopingDuration.lean` builds green, zero sorries.
- **Landed**: `LoopingDuration`, `LoopingDuration.neg`, `LoopingDuration.exists_pos`,
  `states_add_of_looping` (Lemma A), `truthAt_add_period` (Lemma B), `truthAt_add_nsmul`,
  `allPast_imp_allFuture` and `allFuture_imp_allPast` (Lemma C + mirror), `co_true`;
  clock instances `clockRel_one`, `clockFrame_looping`, `clock_co_true`,
  `clock_allPast_imp_allFuture`, `clock_allFuture_imp_allPast`.
- **Confirmed scope hypothesis**: `Formula` has exactly the six constructors the plan asserted
  (`atom`, `bot`, `imp`, `box`, `untl`, `snce`); Lemma B's induction covers all six. No deviation.
- **Gotchas for successors**: `clockFrame.WorldState` does not elaborate as `ClockState` inside a
  tactic block — state auxiliary facts about `clockRel` with `ClockState`-typed binders and apply
  them, rather than `show`/`unfold`-ing through the projection. `add_lt_add_right h c` in this
  Mathlib yields `c + a < c + b`; use `(add_lt_add_iff_right c).mpr` instead.
- **Next action**: Phase 3 — `CoNotPriorU.lean`, the arc model and the Prior-U refutation.
