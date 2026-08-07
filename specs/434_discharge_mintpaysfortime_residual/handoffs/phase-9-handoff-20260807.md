# Task 434 final handoff — phases 1-6, 9 complete; 7-8 BLOCKED

**Next action**: user review, then spawn a task for the missing measure component.

## Delivered (all in MintBound.lean, sections D1 and D2; sorry-free, axiom-free, full `lake build` green)

Time-coordinate accounting (D1) — **the deliverable task 432 Phase 7 consumes**:
- `ruleMintsFreshTime`, `freshTimeRules`, `mem_freshTimeRules`, `freshTimeRules_card`,
  `freshTimeRules_incomparable_freshLabelRules`
- plumbing: `exists_constraint_from_of_pathN`, `exists_constraint_from_of_mem_pastOf`,
  `mem_knownTimes_of_mem_futureOf`/`_pastOf`, `mem_filterMap_time`, `mem_filterMap_const_time`,
  `mem_filterMap_const_time_mem`, `mem_filterMap_futureOf_time`/`_pastOf_time`,
  `mem_identifyTime_time`, `mem_identifyTime_time_at_trigger`, `fst_mem_of_mem_trichotomyCandidates`
- `applyRule_orderTrichotomy_emitted_time`, **`applyRule_emitted_time_mem`**,
  `applyRule_emitted_timeFinset_mem`, `applyRule_emitted_time_mem_ordTimesKnown_needed`
- `applyRule_emitted_nextTime_of_freshLabel`, `applyRule_emitted_time_dichotomy_selfGuarded`,
  **`applyRule_emitted_time_dichotomy`**, `unorderedSuccessor_time_dichotomy`,
  `knownTimes_card_le_succ_of_unorderedSuccessor`

Verdicts and refutations (D2):
- `witnessPresent_eq_false_of_not_freshLabel`, `mintPaysForTime_untlNeg_false`,
  `mintPaysForTime_empty`
- `splitOrderedRank_lt_of_knownTimes_lt`, `mintPaysForTime_rank_repair_false`
- `rho_src_ne_src`, `rhoSF_time_ne_src`, `mint_not_in_rhoSF_image`,
  `nextTime_reissues_retired_time`, `reuseStep`, `reuseWitnessBranch`/`Ord`/`State`,
  `reuse_driven_through_engine`

Reconciliation: the three in-source notes asserting `applyRule_emitted_time_mem` does not exist are
corrected; do-not-re-attempt register grew 12 → 16 entries.

## For task 432

Both consumed names are top-level and stable, but **each carries `OrdTimesKnown b ord`** beyond the
signature the plan advertised. The unconditional form is decided false
(`applyRule_emitted_time_mem_ordTimesKnown_needed`). Thread the invariant via
`expandOnceUnblocked_ordTimesKnown`.

## Blocker (phases 7-8)

No satisfiable repair of `MintPaysForTime` exists. Both routes the plan specifies are refuted
in-source. What is missing: a fourth measure component paying for `untlNeg`/`snceNeg`/`densityRule`
that survives `TimeOrdering.identifyTime`. Full statement: plan file Phase 7 BLOCKER block, and
MintBound.lean section D2's "The repair, attempted and BLOCKED" note plus register entry 14.

## Proof-engineering note worth keeping

A term-level `by` block inside a `first` alternative elaborates with error recovery: a failing side
goal is filled with `sorryAx` and the alternative appears to succeed. The first draft of the time
sweep did exactly this and only `#print axioms` caught it. Every closer in the landed sweeps is a
tactic-mode `refine … ?_`.
