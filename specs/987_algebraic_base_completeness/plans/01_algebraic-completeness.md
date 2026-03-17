# Implementation Plan: Task #987

- **Task**: 987 - algebraic_base_completeness
- **Status**: [PARTIAL]
- **Effort**: 4 hours
- **Dependencies**: None (avoids task 986 by using CanonicalMCS sorry-free path)
- **Research Inputs**: specs/987_algebraic_base_completeness/reports/02_taskframe-semantics.md
- **Artifacts**: plans/01_algebraic-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Wire algebraic base completeness by constructing a sorry-free `BFMCS CanonicalMCS` from the existing `temporal_coherent_family_exists_CanonicalMCS` construction, then feeding it as the `construct_bfmcs` argument to `parametric_algebraic_representation_conditional`. The key insight is that `valid phi` quantifies over ALL D types, so we can instantiate with any D that has `AddCommGroup + LinearOrder + IsOrderedAddMonoid` -- but the BFMCS indexing uses `CanonicalMCS` (which only needs `Preorder`). The challenge is bridging these two: the parametric representation theorem needs `BFMCS D` where D satisfies the TaskFrame constraints, but the sorry-free construction produces `FMCS CanonicalMCS` where CanonicalMCS has only Preorder. The resolution is to use D = Int for the TaskFrame side and construct a `BFMCS Int` by lifting the CanonicalMCS construction through an Int-indexed embedding.

### Research Integration

- D = CanonicalMCS is WRONG for TaskFrame (no AddCommGroup). CanonicalMCS is the FMCS index type.
- D = Int is correct for discrete temporal logic.
- `temporal_coherent_family_exists_CanonicalMCS` is sorry-free and provides F/P witnesses.
- `parametric_algebraic_representation_conditional` requires `construct_bfmcs : M -> SMC M -> Sigma' (BFMCS D) ...`
- The existing `IntBFMCS.lean` has 2 sorries (forward_F, backward_P dovetailing).
- Option 2 from research (semantic equivalence) is the recommended path.

## Goals & Non-Goals

**Goals**:
- Create `AlgebraicBaseCompleteness.lean` with a closed completeness theorem
- Prove `valid phi -> Nonempty (DerivationTree [] phi)` (or the contrapositive)
- Achieve this sorry-free by leveraging the CanonicalMCS sorry-free infrastructure
- Properly connect the CanonicalMCS-based construction to the parametric algebraic representation

**Non-Goals**:
- Completing the Int-specific dovetailing construction in IntBFMCS.lean (task 986)
- Proving strong completeness (context-level)
- Dense completeness (separate infrastructure)
- Removing sorries from IntBFMCS.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatch between BFMCS D and FMCS CanonicalMCS | H | M | Phase 1 focuses on understanding the exact type bridge needed |
| CanonicalMCS lacks AddCommGroup for TaskFrame D | H | H | Use D = Int for TaskFrame, CanonicalMCS only as FMCS index -- OR bypass parametric_algebraic_representation_conditional entirely and prove completeness directly from CanonicalMCS truth lemma |
| Universe level issues with `valid` using `Type` not `Type*` | M | L | Check universe compatibility early in Phase 1 |
| Omega/ShiftClosed mismatch between validity definition and canonical model | M | M | Phase 2 addresses Omega construction carefully |

## Implementation Phases

### Phase 1: Analyze Type Bridge and Choose Architecture [COMPLETED]

**Goal**: Determine the exact proof architecture for bridging CanonicalMCS-based sorry-free construction to the closed completeness theorem.

**Tasks**:
- [ ] Study how `valid phi` is defined (quantifies over ALL D : Type, ALL TaskFrame D, ALL TaskModel, ALL Omega, ALL histories)
- [ ] Determine whether we can bypass `parametric_algebraic_representation_conditional` entirely
- [ ] Analyze the direct path: use CanonicalMCS-based truth lemma + BFMCS to build a countermodel for ANY non-provable phi, showing it fails in SOME model (contradicting validity)
- [ ] Check whether `CanonicalMCS` with its Preorder can serve as the D parameter anywhere, or if we must use Int
- [ ] Identify the exact type signature of the completeness theorem

**Key Insight to Verify**: The completeness theorem `valid phi -> provable phi` is equivalent to the contrapositive `not provable phi -> exists countermodel`. The CanonicalMCS-based construction gives us a countermodel, but we need to verify it constitutes a valid TaskModel over some TaskFrame D where D has AddCommGroup. Since `valid` quantifies over ALL D, we only need ONE D for the countermodel -- and that D can be Int.

**Timing**: 1 hour

**Files to modify**:
- None (analysis only)

**Verification**:
- Clear architectural decision documented in code comments
- Type signatures for key lemmas identified

---

### Phase 2: Construct Sorry-Free BFMCS Int [PARTIAL]

**Goal**: Build a sorry-free `BFMCS Int` construction that can serve as the `construct_bfmcs` argument, leveraging the CanonicalMCS sorry-free infrastructure.

**Tasks**:
- [ ] Define a function `construct_bfmcs_int_via_canonical : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent) (fam : FMCS Int) (hfam : fam in B.families) (t : Int), M = fam.mcs t`
- [ ] Approach A (preferred): Build an FMCS Int from the CanonicalMCS FMCS by composing with the Int chain (`intChainMCS`). The key: for G/H coherence, use `intChain_forward_G` and `intChain_backward_H` (already sorry-free in IntBFMCS.lean). For F/P coherence, lift from CanonicalMCS where it's trivial.
- [ ] Approach B (alternative): Prove completeness WITHOUT `parametric_algebraic_representation_conditional` by directly constructing a countermodel from `temporal_coherent_family_exists_CanonicalMCS` and the non-parametric truth lemma infrastructure
- [ ] Wrap the FMCS Int into a BFMCS Int with modal saturation
- [ ] Prove temporal coherence for the BFMCS

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - New file (or IntBFMCS.lean additions)

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` succeeds
- No sorries in the new construction (grep for `sorry`)

---

### Phase 3: Prove Closed Completeness Theorem [COMPLETED]

**Goal**: State and prove the closed algebraic base completeness theorem.

**Tasks**:
- [ ] Create `AlgebraicBaseCompleteness.lean` with proper imports
- [ ] State the completeness theorem: `theorem algebraic_base_completeness (phi : Formula) (h_valid : valid phi) : Nonempty (DerivationTree [] phi)`
- [ ] Prove by contrapositive: assume not provable, use `parametric_algebraic_representation_conditional` (or direct construction) to get a countermodel, then show this contradicts validity
- [ ] Handle the Omega/ShiftClosed requirements: the canonical model needs a shift-closed Omega, and validity gives truth at ALL shift-closed Omega
- [ ] Verify the countermodel is a legitimate TaskModel over some TaskFrame D (with D = Int)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Main completeness theorem

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` succeeds
- No sorries in the completeness theorem
- The theorem statement matches the expected form

---

### Phase 4: Integration and Verification [COMPLETED]

**Goal**: Integrate the new file into the project module structure and verify everything builds cleanly.

**Tasks**:
- [ ] Add import to `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` (module aggregator)
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify sorry count has not increased (grep for sorry in the new file)
- [ ] Add documentation header with references to research report and this plan
- [ ] Verify the theorem is accessible from the main Metalogic module

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - Add import
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Final documentation

**Verification**:
- Full `lake build` succeeds
- `grep -r sorry Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` returns nothing
- The completeness theorem is importable from the main module

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` compiles without errors
- [ ] Full `lake build` succeeds (no regressions)
- [ ] No new sorries introduced (grep verification)
- [ ] The completeness theorem has the expected type signature
- [ ] The proof uses only sorry-free components

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Main completeness file
- Possibly modifications to `IntBFMCS.lean` if approach A is used for the BFMCS construction

## Rollback/Contingency

If the sorry-free path proves infeasible:
1. Fall back to a sorry-backed completeness theorem that documents the exact sorry dependency
2. The sorry would be isolated to the `construct_bfmcs` argument (same as current state)
3. This would still provide value by wiring the full architecture

If type mismatches prove intractable:
1. Consider the direct CanonicalMCS-based completeness (Approach B in Phase 2) which avoids the parametric infrastructure entirely
2. This may require building a separate truth lemma for CanonicalMCS-indexed models

## Architecture Decision Notes

### Why Not Use parametric_algebraic_representation_conditional Directly

The `parametric_algebraic_representation_conditional` theorem requires `construct_bfmcs : M -> SMC M -> Sigma' (BFMCS D) ...` where D has `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. The sorry-free construction lives in CanonicalMCS land where D = CanonicalMCS (only Preorder). Bridging requires either:

1. **Embedding approach**: Map Int -> CanonicalMCS and pull back the FMCS. This is what IntBFMCS.lean attempts but has 2 sorries for F/P.
2. **Direct approach**: Skip `parametric_algebraic_representation_conditional` and prove completeness from scratch using the CanonicalMCS truth lemma and BFMCS construction directly.
3. **Hybrid approach**: Use the parametric truth lemma at D = Int but provide `construct_bfmcs` by a novel construction that avoids dovetailing.

The implementation should try option 3 first, falling back to option 2 if needed.
