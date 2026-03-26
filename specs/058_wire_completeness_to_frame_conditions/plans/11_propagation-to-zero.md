# Implementation Plan: Task #58 - Propagation-to-Zero (v11)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/49_team-research.md (cross-chain witness propagation analysis)
- **Previous Plan**: plans/10_restricted-completeness.md (blocked on cross-chain sorries)
- **Artifacts**: plans/11_propagation-to-zero.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Revision Summary

Plan v10 was blocked at Phase 1 due to cross-chain F/P witness propagation sorries at `build_restricted_tc_family` (lines 3892, 3917). Team research (report 49, 3 teammates) converged on the **propagation-to-0 approach**:

- F-obligations in backward chain propagate rightward via Succ → reach seed at position 0 → enter forward chain → `restricted_forward_chain_forward_F` provides witness
- P-obligations symmetric through backward chain

This revision restructures phases to implement Option A (Combined Bounded Witness) with fallback to Option B (Bottom-up Sorry Resolution).

## Overview

The cross-chain witness problem arises because `restricted_succ_chain_fam` is built from two independent chains meeting at position 0:
- Backward chain: `...,-2,-1,0` (built by `constrained_predecessor_restricted`)
- Forward chain: `0,1,2,...` (built by `constrained_successor_restricted`)

When `F(psi)` is in the backward chain, the witness may be in the forward chain (cross-chain). The key insight: Succ relations flow rightward, so F-obligations propagate toward 0, cross the bridge at `seed.world`, and enter the forward chain.

## Goals & Non-Goals

**Goals**:
- Prove cross-chain F/P witness propagation for `build_restricted_tc_family`
- Fill sorries at lines 3892 and 3917 in SuccChainFMCS.lean
- Enable completion of Phase 2-4 from plan v10

**Non-Goals**:
- Resolving termination sorries in `restricted_bounded_witness` (defer unless blocking)
- Resolving seed consistency sorries (defer unless blocking)
- Full bottom-up sorry resolution (fallback only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Combined bounded witness needs Succ verification | H | M | Use existing `succ_chain_fam_succ` which already handles junction |
| Pre-existing sorry chain blocks progress | M | M | Pivot to Option B (bottom-up) |
| Termination argument fails | M | H (flagged LOW confidence) | Accept partial with termination sorry if provable modulo termination |
| G-persistence reverse unprovable | H | M | May need definition adjustment |

## Implementation Phases

### Phase 1: Combined Bounded Witness Infrastructure [COMPLETED]

**Goal**: Define `restricted_combined_bounded_witness` working over the full Int-indexed chain.

**Mathematical Content**:
Instead of separate `restricted_forward_chain_forward_F` and a missing `restricted_backward_chain_forward_F`, define a single combined witness lemma that works over `restricted_succ_chain_fam` indexed by Int.

The key is that `succ_chain_canonicalTask_forward_MCS_from` already provides forward MCS chains starting from any position in the combined chain. The junction at 0 is handled by `succ_chain_fam_succ` which proves `Succ (backward_chain M0 1) (forward_chain M0 0)`.

**Tasks**:
- [ ] Analyze `succ_chain_canonicalTask_forward_MCS_from` (line 560-577) for Int position support
- [ ] Define `restricted_combined_F_bounded`: F-nesting bounded at any Int position in the combined chain
- [ ] Define `restricted_combined_bounded_witness`: For any `F(psi)` at Int position n, find witness at m > n
- [ ] Verify the junction case: witness search crosses from n < 0 to m >= 0

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add combined witness lemma

**Verification**:
- `lake build`
- `lean_goal` at key positions

---

### Phase 2: Fill Cross-Chain Sorries [COMPLETED]

**Goal**: Use combined bounded witness to fill sorries at lines 3892 and 3917.

**Mathematical Content**:

**Sorry 1 (line 3892, `forward_F`, `Int.negSucc k` case)**:
```lean
-- h_F : F(psi) ∈ restricted_succ_chain_fam phi seed (Int.negSucc k)
-- Goal: ∃ m : Int, m > Int.negSucc k ∧ psi ∈ restricted_succ_chain_fam phi seed m

-- Apply combined bounded witness
have h_witness := restricted_combined_bounded_witness phi seed (Int.negSucc k) psi h_F
-- This gives m > Int.negSucc k with psi in chain at m
-- m could be negative (still in backward chain) or non-negative (crossed to forward chain)
exact h_witness
```

**Sorry 2 (line 3917, `backward_P`, `Int.ofNat (k+1)` case)**:
```lean
-- h_P : P(psi) ∈ restricted_succ_chain_fam phi seed (Int.ofNat (k+1))
-- Goal: ∃ m : Int, m < Int.ofNat (k+1) ∧ psi ∈ restricted_succ_chain_fam phi seed m

-- Symmetric: Apply combined backward bounded witness
-- P-obligations propagate leftward through forward chain to 0, then backward chain
have h_witness := restricted_combined_backward_bounded_witness phi seed (Int.ofNat (k+1)) psi h_P
exact h_witness
```

**Tasks**:
- [ ] Fill sorry at line 3892 using `restricted_combined_bounded_witness`
- [ ] Fill sorry at line 3917 using symmetric argument
- [ ] Verify `build_restricted_tc_family` compiles without sorries (modulo pre-existing)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fill sorries in `build_restricted_tc_family`

**Verification**:
- `lake build`
- `#check build_restricted_tc_family` succeeds
- Grep for remaining sorries in `build_restricted_tc_family`

---

### Phase 3: Complete RestrictedTruthLemma [COMPLETED]

**Goal**: With cross-chain sorries resolved, complete Phase 2 from plan v10.

**Mathematical Content**:
`RestrictedTruthLemma.lean` has 3 remaining sorries after refactoring (from 7). With `build_restricted_tc_family` providing a fully verified `RestrictedTemporallyCoherentFamily`, the truth lemma can be completed.

The key dependencies:
- `forward_G` and `backward_H` in FMCS structure → use Succ G-persistence
- `restricted_fmcs_forward_F` and `restricted_fmcs_backward_P` → lift from `build_restricted_tc_family`

**Tasks**:
- [ ] Fill remaining sorries in RestrictedTruthLemma.lean using `build_restricted_tc_family`
- [ ] Verify `restricted_truth_lemma` and `restricted_truth_at_seed` are sorry-free

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

**Verification**:
- `lake build`
- `#print axioms restricted_truth_lemma` shows no `sorryAx`

---

### Phase 4: Wire to FrameConditions/Completeness [PARTIAL]

**Goal**: Eliminate the 3 target sorries in FrameConditions/Completeness.lean.

**Mathematical Content**:
Same as plan v10 Phase 4:
1. `bundle_validity_implies_provability` (line 186-214): Use restricted completeness
2. `dense_completeness_fc`: Reduce to `completeness_over_Int`
3. `discrete_completeness_fc`: Reduce to `completeness_over_Int`

**Tasks**:
- [ ] Define lifting lemma: restricted completeness → completeness over Int
- [ ] Wire `bundle_validity_implies_provability`
- [ ] Wire `dense_completeness_fc` via `dense_implies_int + completeness_over_Int`
- [ ] Wire `discrete_completeness_fc` via `discrete_implies_int + completeness_over_Int`
- [ ] Final axiom verification

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms completeness_over_Int` shows no `sorryAx`

---

## Fallback: Option B (Bottom-up Sorry Resolution)

If Phase 1-2 fail due to Succ relation issues, pivot to Option B:

1. **Resolve `constrained_predecessor_restricted_g_persistence_reverse`** (line 3360)
2. **Resolve `constrained_predecessor_restricted_f_step_forward`** (line 3420)
3. **Create `restricted_backward_chain_F_bounded`** (analogous to P_bounded)
4. **Create `restricted_backward_bounded_witness_F`** (F-witness for backward chain)
5. **Prove propagation-to-0** via step-wise induction
6. **Fill cross-chain sorries** (3892, 3917)

Estimated additional effort: +4-6 hours

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorryAx)
- [ ] Final verification: all 3 target sorries eliminated
- [ ] Regression test: existing sorry-free theorems remain sorry-free

## Artifacts & Outputs

- `plans/11_propagation-to-zero.md` (this file)
- Modified Lean files:
  - `SuccChainFMCS.lean` - Combined bounded witness, cross-chain sorries filled
  - `RestrictedTruthLemma.lean` - Remaining sorries filled
  - `FrameConditions/Completeness.lean` - Target sorries eliminated
- `summaries/12_propagation-to-zero-summary.md` (after completion)

## Pre-existing Sorry Inventory

From team research report 49:

| Sorry Location | Line | Status | Notes |
|---------------|------|--------|-------|
| `g_persistence_reverse` | 3360 | May block Phase 1 | Needed for Succ verification |
| `f_step_forward` | 3420 | May block Phase 1 | Needed for Succ verification |
| `restricted_bounded_witness` termination | 2405 | Defer | Accept if proof works modulo termination |
| `restricted_backward_bounded_witness` termination | 3824 | Defer | Accept if proof works modulo termination |
| `neg_not_in_boundary_resolution_set` | 1435 | Defer | May need definition change |
| `constrained_successor_seed_restricted_consistent` | 1543 | Defer | Depends on #5 |

**Strategy**: Focus on cross-chain sorries first. If blocked by pre-existing sorries, document the dependency and create a follow-up task.
