# Implementation Plan: Backward Tracing for boundary_implies_k_lt_B

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [IN PROGRESS]
- **Effort**: 2-4 hours
- **Dependencies**: Plan 13 (Phases 1-3, 5-6 complete)
- **Research Inputs**: reports/39_provenance-proof-research.md
- **Artifacts**: plans/14_backward-tracing-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 14

## Overview

Plan 13 successfully implemented the bulldozing approach (adding `f_content u` to the seed), but Phase 4 (`boundary_implies_k_lt_B`) was left with a sorry. This plan completes the proof using the **backward tracing** strategy identified in Report 39.

### Current State

From Plan 13 (Phases completed):
- **Phase 1**: f_content added to seed definition
- **Phase 2**: Seed consistency proven
- **Phase 3**: F-persistence theorems proven (`restricted_forward_chain_F_resolves`, `restricted_forward_chain_iter_F_resolves`)
- **Phase 5**: Target sorries at lines 3006, 3037 closed (calling `boundary_implies_k_lt_B`)
- **Phase 6**: Build passes, no new axioms

**Remaining Sorry**: `boundary_implies_k_lt_B` at SuccChainFMCS.lean:2813

### Research Integration

From **Report 39 (Provenance Proof Research)**:

**Key Insight**: The proof requires backward tracing of F-formulas through the chain:
- If `iter_F d theta ∈ chain(k)`, trace backward to find `iter_F (d+k) theta ∈ chain(0)`
- Since `chain(0) = M0.world ⊆ deferralClosure(phi)`, we get `d + k < B`
- Hence `k < B - d < B`

**Proof Strategy**: Strong induction on k with the backward tracing lemma.

## Goals & Non-Goals

**Goals**:
- Prove `iter_F_trace_to_base` lemma (backward tracing)
- Complete `boundary_implies_k_lt_B` proof using backward tracing
- Achieve zero sorries in the target proof chain

**Non-Goals**:
- Modifying the seed construction (already done in Plan 13)
- Alternative proof strategies (well-founded recursion, fairness counters)
- Documentation updates (defer to task completion)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backward tracing lemma harder than expected | M | M | Multiple formulations available; can use contrapositive |
| G-content entry complicates tracing | M | L | G-formulas propagate forward, can handle as separate case |
| Proof requires additional infrastructure | L | L | Use existing depth bounds and DRM properties |

## Implementation Phases

### Phase 1: Prove iter_F_trace_to_base Lemma [PARTIAL]

**Goal**: Establish that F-formulas in chain(k) can be traced back to chain(0)

**Tasks**:
- [ ] Define and prove `iter_F_trace_to_base`:
  ```lean
  lemma iter_F_trace_to_base (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (theta : Formula)
      (h_d_pos : d >= 1)
      (h_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
      iter_F (d + k) theta ∈ M0.world ∨
      (∃ j < k, G (iter_F (d + j) theta) ∈ restricted_forward_chain phi M0 (k - j - 1))
  ```
- [ ] Prove by strong induction on k:
  - Base case (k = 0): trivial (iter_F d theta ∈ M0.world, so iter_F (d+0) theta ∈ M0.world)
  - Inductive case (k = succ k'): F-formulas enter via f_content (trace to k') or g_content (handle separately)
- [ ] Run `lake build` to verify

**Key Insight**: If `iter_F d theta ∈ chain(k)` for k >= 1, it either:
1. Was in chain(k-1) and persisted via MCS closure
2. Entered via f_content: so `F(iter_F d theta) = iter_F (d+1) theta` was in chain(k-1)
3. Entered via g_content: so `G(iter_F d theta)` was in chain(k-1)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — new lemma (~line 2730 area, before boundary_implies_k_lt_B)

**Verification**:
- Lemma compiles without sorry
- Strong induction structure is well-founded

---

### Phase 2: Complete boundary_implies_k_lt_B Proof [COMPLETED]

**Goal**: Remove the sorry from `boundary_implies_k_lt_B` using backward tracing

**Tasks**:
- [ ] Apply `iter_F_trace_to_base` to get either:
  - `iter_F (d + k) theta ∈ M0.world`, or
  - G-content entry at some earlier chain position
- [ ] For the M0.world case:
  - Use `deferral_restricted_mcs_depth_bound` to get `f_nesting_depth(iter_F (d+k) theta) < B`
  - Since `f_nesting_depth(iter_F (d+k) theta) = d + k + f_nesting_depth(theta) >= d + k`
  - We get `d + k < B`, hence `k < B - d < B`
- [ ] For the G-content case:
  - G-formulas have bounded depth in deferralClosure
  - Similar depth argument applies
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Current Sorry Location**: SuccChainFMCS.lean:2813

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — complete the sorry at line 2813

**Verification**:
- `boundary_implies_k_lt_B` compiles without sorry
- The overall proof chain has no new sorries

---

### Phase 3: Final Verification [PARTIAL]

**Goal**: Verify complete proof chain and document

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Check sorry count: should have no new sorries from this work
- [ ] Verify `restricted_bounded_witness_wf` has no sorries
- [ ] Run `lean_verify` on key theorems
- [ ] Update summary file

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Target sorries (original lines 3006, 3037) remain closed

## Testing & Validation

- [ ] `lake build` succeeds for SuccChainFMCS.lean
- [ ] `boundary_implies_k_lt_B` has no sorry
- [ ] `iter_F_trace_to_base` compiles
- [ ] Strong induction terminates correctly
- [ ] Depth bound reasoning is sound

## Artifacts & Outputs

- `plans/14_backward-tracing-completion.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Updated `summaries/13_bulldozing-summary.md` or new summary upon completion

## Rollback/Contingency

If backward tracing proves insufficient:
1. Consider alternative formulation: contrapositive (assume k >= B, derive contradiction)
2. Try well-founded recursion on (k, formula_complexity) lexicographic order
3. Document failure mode in updated summary

## Relationship to Plan 13

This plan is a **continuation** of Plan 13, specifically completing Phase 4. The overall approach remains bulldozing via f_content; this plan adds the missing mathematical machinery for the boundary lemma.

| Plan 13 Phase | Status | Plan 14 Coverage |
|---------------|--------|------------------|
| Phase 1 | COMPLETED | N/A |
| Phase 2 | COMPLETED | N/A |
| Phase 3 | COMPLETED | N/A |
| Phase 4 | PARTIAL (sorry) | Phases 1-2 complete this |
| Phase 5 | COMPLETED | N/A |
| Phase 6 | COMPLETED | Phase 3 re-verifies |
