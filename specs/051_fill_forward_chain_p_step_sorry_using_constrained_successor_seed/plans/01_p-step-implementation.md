# Implementation Plan: Task #51

- **Task**: 51 - Fill forward chain P-step sorry using constrained successor seed
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: Task 50 (completed - constrained successor infrastructure)
- **Research Inputs**: reports/01_p-step-proof-strategy.md
- **Artifacts**: plans/01_p-step-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Fill the sorry at `SuccChainFMCS.lean:378` in the `succ_chain_fam_p_step` theorem by modifying the forward chain construction to use `constrained_successor_from_seed` instead of `successor_from_deferral_seed`. The constrained successor infrastructure from task 50 guarantees P-step via the `successor_p_step` theorem, which directly provides the needed proof.

### Research Integration

Key findings from research report:
- Current forward chain uses `successor_from_deferral_seed` which does NOT include P-step blocking formulas
- Task 50 implemented `constrained_successor_from_seed` with seed including `p_step_blocking_formulas`
- The `successor_p_step` theorem at SuccExistence.lean:324-355 proves P-step for constrained successors
- Constrained successor preserves all existing guarantees (Succ relation, MCS property) plus adds P-step

## Goals & Non-Goals

**Goals**:
- Modify `ForwardChainElement.next` to use `constrained_successor_from_seed`
- Update `forward_chain_succ` to use `constrained_successor_succ`
- Add `forward_chain_p_step` helper theorem
- Fill the sorry at line 378 in `succ_chain_fam_p_step`
- Verify zero-debt compliance (no new sorries)
- Confirm build succeeds

**Non-Goals**:
- Modifying backward chain construction (already has P-step via existing infrastructure)
- Adding new axioms or postulates
- Changing the API or signatures of existing public theorems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing theorems break after modification | Medium | Low | Constrained successor has strictly more guarantees; verify with lake build |
| Type signature mismatch | Low | Low | Both successors have same type signature; verify is_mcs and succ proofs exist |
| F_top propagation fails | Low | Very Low | Constrained successor is an MCS, so contains F_top; existing F_top_propagates applies |

## Implementation Phases

### Phase 1: Modify Forward Chain Construction [COMPLETED]

**Goal**: Replace `successor_from_deferral_seed` with `constrained_successor_from_seed` in `ForwardChainElement.next`

**Tasks**:
- [ ] Change `ForwardChainElement.next.world` from `successor_from_deferral_seed` to `constrained_successor_from_seed`
- [ ] Change `ForwardChainElement.next.is_mcs` from `successor_from_deferral_seed_mcs` to `constrained_successor_from_seed_mcs`
- [ ] Change `ForwardChainElement.next.has_F_top` to use `constrained_successor_succ` instead of `successor_succ`
- [ ] Update `forward_chain_succ` theorem to use `constrained_successor_succ`
- [ ] Run `lake build` to verify existing dependent theorems still work

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 158-196)

**Verification**:
- `lake build` succeeds with no new errors
- `forward_chain_succ` still proves Succ relation

---

### Phase 2: Add Forward Chain P-Step Theorem and Fill Sorry [COMPLETED]

**Goal**: Add `forward_chain_p_step` helper theorem and use it to fill the sorry

**Tasks**:
- [ ] Add `forward_chain_p_step` theorem after `forward_chain_succ`:
  ```lean
  theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
      p_content (forward_chain M0 (k + 1)) ⊆
      forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
    successor_p_step (forward_chain M0 k) (forward_chain_mcs M0 k) (forward_chain_has_F_top M0 k)
  ```
- [ ] Replace the sorry at line 378 with `exact forward_chain_p_step M0 k h_φ`
- [ ] Verify the proof compiles with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 197-198 for new theorem, line 378 for sorry)

**Verification**:
- `lake build` succeeds
- No sorries remain in `succ_chain_fam_p_step`

---

### Phase 3: Build Verification and Zero-Debt Check [COMPLETED]

**Goal**: Ensure full project builds and no new sorries were introduced

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Grep for `sorry` in SuccChainFMCS.lean to verify none remain in the P-step code
- [ ] Check that no other files were affected by the change
- [ ] Review dependent theorems (`forward_chain_canonicalTask_forward_MCS_from`, `succ_chain_forward_F`) still work

**Timing**: 30 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `lake build` exits with code 0
- `grep -n "sorry" SuccChainFMCS.lean` shows no sorries in P-step section
- All existing tests/lemmas pass

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] `forward_chain_p_step` theorem exists and proves P-step for forward chain
- [ ] `succ_chain_fam_p_step` has no remaining sorries
- [ ] Existing `forward_chain_succ`, `forward_chain_mcs`, `forward_chain_has_F_top` still work
- [ ] No new sorries introduced anywhere in the codebase

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- New theorem: `forward_chain_p_step`
- Filled sorry: `succ_chain_fam_p_step` ofNat case

## Rollback/Contingency

If the modification causes unexpected failures:
1. Revert changes to `ForwardChainElement.next` and `forward_chain_succ`
2. The original `successor_from_deferral_seed` construction still exists and is valid
3. Document any unexpected dependencies for further investigation
