# Phase 6 handoff — task 433 (narrowed repair, post-ruling)

- **GATE RESULT: PASSED.** `PostBlockingSettlesRun fc fuel` carries `buildTableauAt_isSome_of_budget`.
- **Landed**: `PostBlockingSettlesRun`, `postBlockingSettlesRun_of_postBlockingSettles` (direction
  lemma, direction in words), `expandBranchWithFuel_eq_none_zero`, `postBlockingSettlesRun_zero`,
  `buildTableauAt_isSome_of_settlesRun` (bridge), eight terminus restatements
  (`*_of_budget{,_at,_selfGuarded,_fixed}_run` and their `*_at_seed*_run` forms),
  `buildTableauAt_isSome_of_budget_of_run` (strengthening certificate),
  `multBranch_one_length_lt_multSettledBranch`, `postBlockingRunProbe` with seven
  `#guard_msgs`-checked non-vacuity measurements. C9 entry 23 amended, entry 24 added.
- **Orchestrator's six conditions — all met**:
  1. Phase 6 gate passed; the narrowing carries the terminus, so it is landed as a result.
  2. Direction lemma machine-checked, direction named in words in its docstring (weaker predicate,
     difference at the `(ob, oOrd)` quantifier, every restatement a strengthening).
  3. Non-vacuity: the pass doing real work is *proved* at every frame class and every positive fuel;
     the full antecedent is exhibited on seed runs by `#guard_msgs`-checked measurement. The
     proof/measurement distinction is stated in the file and in entry 24, not blurred.
  4. The narrowing and the refutation of the unrestricted form are on `PostBlockingSettlesRun`'s own
     docstring, cross-referencing entries 22-24.
  5. Phase 3's FALSE verdict stands as proved and is not retro-edited; the ruling is recorded as a
     note under it, and Phases 5 and 6 carry deviation notes. Both refuted things
     (`PostBlockingSettles`, `PostBlockingExitSettled`) have C9 entries with witnesses.
  6. No `sorry`, no vacuous discharge, no frozen-file edit, no landed declaration altered, axioms
     within the permitted three, full `lake build` green.
- **Honest costs**: the restated termini name `ArmSettlement fc` explicitly instead of manufacturing
  it from a refuted predicate — a real change to the hypothesis list, and one `ArmSettlement`'s own
  narrowed quantification makes reasonable. Fourteen `_lengthBudget`/`signedUniverse` restatements
  are left as recorded mechanical substitutions.
- **Blockers**: none. The narrowed residual is carried, not discharged — which is why the task
  closes `[PARTIAL]`.
