# Phase 2 Handoff — Task 273

## Immediate Next Action
Close `forward_nf_eval_of_holdsLeft` (KampBypass.lean:2385) — Phase 3 of plan v39.

## Current State
- Phase 1: COMPLETED (BracketFormula k encoding, bracket_from_distinct_witnesses)
- Phase 2: COMPLETED (backward injectivity: funext + nodup + getElem_inj_iff)
- Phase 3: IN PROGRESS (forward direction sorry at L2385)
- Phase 4: NOT STARTED (Since direction)
- Phase 5: NOT STARTED (chain verification)
- Build: GREEN (4 sorries at L2385, L2560, L2562, L2715)

## Key Decisions — Phase 3 Forward Proof

1. Use `cases h_eq.symm` to substitute `vea`/`n` with concrete `enriched_vecEA2_until` definition in all hypotheses
2. After substitution, `h_endRight` becomes a concrete `temporal_truth` statement about `Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)` at x
3. **CRITICAL**: `Formula.and` in this codebase is NOT a primitive — it encodes as `(a.imp b.neg).neg`. After simp with `[TemporalPred.eval_at, Formula.and, temporal_truth]`, h_endRight becomes a double-negated implication, not a conjunction. Need `temporal_and_iff` or `Formula.and_semantics` to decompose it properly.
4. Atom proof approach: `char_1_correct` + `nf_x_compat_check` for x-preds; `h_t_compat` + `h_atoms` for t-preds; `h_t_lt_x`/`h_gt`/`h_lt` for order atoms
5. Quantifier proof requires per-zone decomposition across `h_endLeft` (below_t, eq_t zones), `h_endRight` (eq_x, above_x zones), and `h_bracket` (between_tx zone with bracket witnesses)

## Sorry Inventory
See `.orchestrator-handoff.json` for full sorry_inventory.
