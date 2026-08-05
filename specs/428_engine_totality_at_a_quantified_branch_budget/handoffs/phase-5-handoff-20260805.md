# Phase 5 handoff (plan 02)

- **Landed**: `TimeOrdering.pathN_mono`, `directFutureOf_mono`, `directPastOf_mono`,
  `futureOf_mono`, `pastOf_mono`, `mem_futureOf_addFuture`, `mem_pastOf_addFuture`
  in `Fuel.lean`, immediately before `end TimeOrdering`.
- **Scope Hypothesis outcome**: CONFIRMED. Every BFS-calculus name the plan named is present
  (`PathN`, `bfsClosure`, `reachableForward_eq`, `reachableBackward_eq`,
  `mem_bfsClosure_of_mem_visited`, `bfsClosure_sound`, `BfsInv`, `bfsClosure_complete_aux`,
  `bfsClosure_complete`, `PathN.snoc`, `PathN.reverse`, `mem_directFutureOf_iff`,
  `orderDual_holds`), and `Fuel.lean:98`'s `open private` is in force. Nothing was rebuilt.
- **Verification**: `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`
  green; `sorry` count 0; purely additive.
- **Deviations**: none.
- **Next action**: Phase 6 — `firstIncomparablePair_spec`, `incomparableB`/`incompPairs` defs,
  `incomparableB_mono`, `incompPairs_mono`, `incompPairs_lt_addFuture`.
