# Handoff: Phase 3A - Fix Build Errors in WitnessGraph.lean

## Immediate Next Action

Continue fixing remaining ~30 build errors in `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`. The main error categories remaining are:

1. **Type mismatches in helper lemmas** (lines ~1524-1585): `addFutureWitness_isWitnessed_monotone` and `addPastWitness_isWitnessed_monotone` have `(List.mem_zipIdx h_mem).2.1` which may not produce the right type. Check the exact type of `List.mem_zipIdx` in the current Lean4/Mathlib version.

2. **`List.append_cancel_left` not working** (lines ~2070-2077 in `processStep_new_edge_nodes_gt`): The `List.append_cancel_left` might require explicit type annotations or use `List.append_left_cancel` instead.

3. **`simp [WitnessGraph.addFutureWitness]` no progress in `forward_witness_of_isWitnessed`** (lines ~1669-1681): The `simp` on `WitnessGraph.addFutureWitness` in the goal `g.nodes.length < (buildWitnessGraph rootMCS (m+1)).nodes.length` doesn't work because the goal has `buildWitnessGraph rootMCS (m+1)` not `addFutureWitness`. Need to first `simp only [buildWitnessGraph]` then `rw [h_ps_eq]` before the simp.

4. **Unknown identifier `i` / `psi`** (lines ~1677, 1777): After `subst` eliminates variables, later references to original names fail. Need to use the remaining names post-substitution.

5. **`simp [WitnessEdge.mk.injEq]` no progress** (lines ~2182, 2314): In GContent/HContent proofs, the `simp [List.mem_append, WitnessEdge.mk.injEq]` to eliminate direction-mismatched edges may not work because `simp` may not automatically derive the direction inequality. Try `simp [List.mem_append, List.mem_singleton, WitnessEdge.mk.injEq, show EdgeDirection.forward ≠ EdgeDirection.backward from by decide]` or similar.

## Current State

- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
- **Lines**: ~2520 (increased from 2489 due to new helper lemmas)
- **Build errors**: ~30 (down from 48 original)
- **Sorries**: 0 syntactically

## Key Decisions Made

1. **Added `processStep_outcome` helper** (line ~1597): Clean characterization of processStep as either unchanged, addFutureWitness, or addPastWitness. This is much easier to work with than `processStep_edges_subset_or_new`.

2. **Rewrote `processStep_isWitnessed_monotone`** using two helper lemmas (`addFutureWitness_isWitnessed_monotone`, `addPastWitness_isWitnessed_monotone`) instead of 120-line case analysis.

3. **Rewrote `forward_witness_of_isWitnessed` and `backward_witness_of_isWitnessed`** using `processStep_outcome` instead of broken `split at h_eq_f ⊢ <;> split at h_eq_f ⊢` patterns.

4. **Fixed `addFutureWitness_new_obl_matches` / `addPastWitness_new_obl_matches`**: Used `simp only [BEq.beq, decide_eq_true_eq]` + `ObligationType.future.inj`/`.past.inj` instead of `injection`.

## What NOT to Try

- `split at x ⊢ <;> split at x ⊢` - Not valid Lean 4 syntax (can't specify multiple targets)
- `rfl.symm ▸ h_true` - Not a valid tactic
- `cases h := expr` - Must be `cases h : expr` (colon, not `:=`)
- `rw [beq_iff_eq]` on ObligationType - Missing `LawfulBEq` instance. Use `simp only [BEq.beq, decide_eq_true_eq]` instead.
- `h_new.2.1` on `simp [List.mem_append]` result - May be a single equation, not an `And`. Use `simp only [WitnessEdge.mk.injEq] at h_new; obtain ⟨h1, h2, h3⟩ := h_new`.

## Critical Context

1. `processStep_outcome` provides the cleanest characterization for most proofs
2. `ObligationType` has `DecidableEq` and derived `BEq` but NOT `LawfulBEq`
3. The `List.mem_zipIdx` API may differ between Mathlib versions - check exact signature
4. `WitnessEdge.mk.injEq` decomposes WitnessEdge equality into field equalities
5. The `end Bimodal.Metalogic.Bundle` namespace closer has been added at file end

## References

- Plan: `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-008.md`
- Research: `specs/916_implement_fp_witness_obligation_tracking/reports/research-012.md`
