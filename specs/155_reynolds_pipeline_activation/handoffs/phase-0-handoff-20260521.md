# Phase 0 Handoff: U'/S' Semantics Fix

## Status: IN PROGRESS (Tasks 0.1-0.6, 0.10, 0.12 complete)

## What Was Done

### Core Definition Changes (Tasks 0.1-0.4) -- COMPLETE
- Replaced `stavi_U_truth`, `stavi_S_truth` with GHR93 FO table definitions (existential form)
- Replaced `stavi_temporal_truth` stavi_untl/snce cases with recursive FO table
- Replaced `stavi_temporal_truth_mu` stavi_untl/snce cases with mu-relativized FO table (s NOT mu-restricted)
- Updated `flatten_stavi` to map stavi_untl/snce to `Formula.bot`

### Discrete Order Proofs (Tasks 0.5-0.6) -- COMPLETE, SORRY-FREE
- Proved `fo_table_body_forces_P`: FO table body forces P at all points in (t,s) on SuccOrder + IsSuccArchimedean. Uses strong induction on succ-iterate index via `Nat.strongRecOn` + `Function.monotone_iterate_of_id_le`.
- Proved `fo_table_body_forces_P_past`: Dual for PredOrder + IsPredArchimedean. Uses `Function.antitone_iterate_of_le_id`.
- Proved `flatten_stavi_correct` stavi_untl/snce cases using the above helpers.
- `flatten_stavi_correct` now requires `[IsSuccArchimedean M.carrier] [IsPredArchimedean M.carrier]` (acceptable for Prior structures).
- `stavi_U_discrete_equiv`/`stavi_S_discrete_equiv` REMOVED (replaced by inline proofs in `flatten_stavi_correct`).
- StaviConnectives.lean: **ZERO sorries**. `lean_verify flatten_stavi_correct` shows only propext, Classical.choice, Quot.sound.

### stavi_truth_mu_at_point Reproof (Task 0.9) -- PARTIALLY COMPLETE
- **Point case (s = extendPoint s') + mpr direction**: PROVED (both stavi_untl and stavi_snce)
- **Gap case (s = Sum.inr g) mp direction**: SORRY'd (2 sorries). Strategy: use g.no_sup to find s' in g.cut above witnesses, then body transfers since (m, s') ⊆ g.cut.

### rank_embed_stavi_truth_mu Reproof (Task 0.8) -- SORRY'd
- 4 sorries (stavi_untl mp/mpr, stavi_snce mp/mpr)
- Strategy: rank_embed preserves order, mu-status, predicates. Witnesses transfer except bound s which may need gap-handling similar to Task 0.9.

### Verification (Task 0.10, 0.12) -- COMPLETE
- Cases I, II, Lemma 10, Lemma 11 forward all compile unchanged
- `lake build` passes with zero errors

## Remaining Work

### Task 0.8: rank_embed_stavi_truth_mu reproof (4 sorries)
- File: EFGames.lean lines 1025-1050
- Key challenge: the bound s may be an r'-gap not in the image of rank_embed. Need to either find a preimage or construct an equivalent bound in r. The no_sup trick from the gap case of Task 0.9 applies.
- Estimated effort: 60-100 lines per direction

### Task 0.9: stavi_truth_mu_at_point gap cases (2 sorries)
- File: EFGames.lean lines 1528, 1608
- Strategy documented above: use g.no_sup to find s' in g.cut.
- Challenge: `extendPoint x < Sum.inr g` in ExtendedCarrier does NOT definitionally equal `x ∈ g.val.cut`. Need to extract via the extendedLE definition.
- Need helper: `extendPoint_lt_gap_iff : extendPoint x < Sum.inr g ↔ x ∈ g.val.cut`
- Estimated effort: 40-60 lines per case

### Task 0.7: FO table MonadicFormula encodings (optional)
- Can defer — only needed for FO-definability direction, not for game theory

### Task 0.11: std_untl/std_snce constructors (optional)
- Can defer — not needed for current pipeline

## Key Decisions
1. Added `IsSuccArchimedean`/`IsPredArchimedean` to `flatten_stavi_correct` — acceptable since it's used for Prior structures
2. Removed standalone `stavi_U_always_false_discrete` — functionality absorbed into `fo_table_body_forces_P`
3. Removed `stavi_U_discrete_equiv`/`stavi_S_discrete_equiv` — superseded by always-false proofs
4. Used abstracted helper lemmas (`fo_table_body_forces_P`) that work for any predicate P, avoiding coupling to specific stavi_temporal_truth calls

## File State
- `StaviConnectives.lean`: 0 sorries (CLEAN)
- `EFGames.lean`: 10 sorries total (6 new from Phase 0 + 4 pre-existing)
  - New: 4 rank_embed + 2 gap cases
  - Pre-existing: left/right_formula_gap_detection, ghr93_decomposition_implies_game, stavi_expressive_completeness
