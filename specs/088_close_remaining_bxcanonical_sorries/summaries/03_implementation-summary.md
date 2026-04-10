# Implementation Summary: Task 88 (Plan v3)

**Task**: 88 — Close remaining BXCanonical sorries
**Plan**: plans/03_implementation-plan.md (v3)
**Status**: PARTIAL (Phase 1 partial, Phase 2 NO-GO, Phases 3-5 skipped)
**Session**: sess_1775800559_e91a55

## What Was Accomplished

### Phase 1: CanonicalEmbedding:418 (usf_completeness) — PARTIAL

**Concrete deliverable**: Closed 2 sorries in `SuccChainFMCS.lean`:
- `F_top_theorem` (line 120): F(⊤) = ¬G(¬¬⊥) derived from BX1 (temp_t_future) + double negation elimination
- `P_top_theorem` (line 130): P(⊤) = ¬H(¬¬⊥) derived from BX1' (temp_t_past) + double negation elimination

These were previously blocked on removed seriality axioms. The proofs use `imp_trans` to chain BX1's `G(¬¬⊥) → ¬¬⊥` with `double_negation`'s `¬¬⊥ → ⊥`.

**CanonicalEmbedding:418 sorry remains**. Extensive analysis identified the root cause and viable approach:

**Root cause**: On constant histories (the only WorldHistory construction available in CanonicalEmbedding.lean), `truth_at G(α) = truth_at α` semantically. This means the bidirectional truth lemma `φ ∈ w ↔ truth_at φ` fails for G(α) in the backward direction: `truth_at G(α) → G(α) ∈ w` requires `truth_at α → G(α) ∈ w`, but `α ∈ w` does NOT imply `G(α) ∈ w`.

**Viable approach** (estimated 12-18 additional hours):
1. Use `RestrictedTemporallyCoherentFamily` from SuccChainFMCS to build a DRM chain with forward_F/backward_P
2. Extend each position to full MCS via Lindenbaum
3. Prove restricted version of parametric truth lemma for sub-formulas of the target formula
4. Apply to ψ.imp χ to get contradiction with validity

**Why this works**: For sub-formulas in deferralClosure:
- forward_G holds (via temp_4 + g_content propagation along chain)
- backward_H holds (symmetric)
- forward_F/backward_P hold (from RestrictedTemporallyCoherentFamily)
- temporal_backward_G works (via forward_F, proved in TemporalCoherence.lean)

### Phase 2: Architecture Spike — Until-Witness Chain bx_le — NO-GO

**Assessment**: Redefining bx_le via Until-witness chains does NOT solve the fundamental guard propagation problem.

**What works under bx_le_new**:
- Reflexivity (empty chain) and transitivity (chain concatenation)
- bx_le_new ⊆ bx_le (old) — each chain step gives g_content inclusion
- G/H truth lemma forward direction — follows from bx_le (old) containment
- G/H truth lemma backward direction — BX12 converts F(¬α) to ⊤ U ¬α, giving Until-witness step

**What fails**:
- **Interval linearity NOT guaranteed**: Two BXPoints u₁, u₂ may both be bx_le_new-reachable from w via DIFFERENT Until-witness chains but not bx_le_new-comparable. The guard condition `∀ u ∈ [w, v), φ ∈ u` quantifies over ALL bx_le_new-intermediate points, not just those on a specific chain.
- **Until formula propagation still blocked**: φ U ψ ∈ w does NOT imply φ U ψ ∈ u for bx_le_new-successors u, even though P(φ U ψ) ∈ u holds (via BX4 + g_content propagation). The X-vs-G mismatch persists.

**Conclusion**: The problem is NOT the ordering definition but the guard quantification. Any single global ordering (whether g_content-based or Until-chain-based) faces the same issue: the guard requires the formula at ALL intermediate points, but Until formulas don't propagate through any global ordering.

### Phases 3-5: SKIPPED (Phase 2 NO-GO gate)

Per the plan, Phases 3-5 depend on Phase 2 GO decision.

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | Closed F_top_theorem and P_top_theorem sorries (2 sorries → 0) |

## Verification

- `lake build` succeeds (945 jobs)
- No new sorries introduced
- No new axioms introduced
- BXCanonical sorry count unchanged (6): CanonicalEmbedding:418, Frame:653/675/690/704, Completeness:160

## Future Directions

1. **CanonicalEmbedding:418**: Implement the restricted truth lemma approach documented above. Requires new theorem connecting DRM chain to parametric truth lemma for USF sub-formulas. Estimated 12-18 hours.

2. **Frame.lean sorries (4)**: Require novel mathematical technique beyond architecture change. Candidates:
   - (B) Quasimodel approach: bypass canonical model entirely
   - (C) Two-indexed canonical model: separate orderings for temporal and modal dimensions
   - (D) Formula-specific ordering: per-Until ordering instead of global bx_le

3. **Completeness:160**: Downstream of Frame.lean sorries. Closes automatically when Frame.lean is resolved.
