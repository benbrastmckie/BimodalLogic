# Implementation Plan: Task #40

- **Task**: 40 - succ_p_step_forward_chain
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None (research completed)
- **Research Inputs**: specs/040_succ_p_step_forward_chain/reports/01_team-research.md
- **Artifacts**: plans/01_successor-p-step-axiom.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Add `successor_p_step_axiom` to SuccExistence.lean (mirroring `predecessor_f_step_axiom`), then add `forward_chain_p_step` theorem in SuccChainFMCS.lean and fill the blocked sorry at line 350. The research confirmed that a pure theorem approach is not achievable because the successor deferral seed contains no past-direction content.

### Research Integration

Key findings integrated:
- Approach B (pure theorem) is NOT achievable - successor seed has no P-content
- `predecessor_f_step_axiom` at SuccExistence.lean:516 provides exact template
- `predecessor_satisfies_p_step` is provable (lines 573-598) because predecessor seed contains pastDeferralDisjunctions
- Semantic justification: In discrete linear frames, P-obligations in successor resolve to source or defer

## Goals & Non-Goals

**Goals**:
- Add `successor_p_step_axiom` with symmetric signature to `predecessor_f_step_axiom`
- Add `forward_chain_p_step` theorem using the axiom
- Fill the sorry at SuccChainFMCS.lean:350

**Non-Goals**:
- Extending Succ to 4 conditions (more invasive, same axiom cost)
- Proving the axiom from temporal duality infrastructure (future work)
- Modifying the successor seed construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Axiom signature doesn't match usage site | M | L | Mirror exact structure of predecessor_f_step_axiom |
| forward_chain_p_step proof fails | M | L | Research verified prerequisites exist (forward_chain_mcs, forward_chain_has_F_top) |
| Dependent proofs break | L | L | Only one downstream dependent identified (succ_chain_canonicalTask_backward_MCS_P_from) |

## Implementation Phases

### Phase 1: Add successor_p_step_axiom [NOT STARTED]

**Goal**: Add the symmetric axiom to SuccExistence.lean

**Tasks**:
- [ ] Add `successor_p_step_axiom` after line 419 (after `successor_succ` theorem)
- [ ] Include docstring with semantic justification matching predecessor_f_step_axiom style
- [ ] Verify axiom compiles with `lake build`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Add axiom after successor_succ

**Code to add** (after line 419):
```lean
/--
Axiom: The successor P-step condition holds.

**Semantic Justification**:
When constructing a successor v of u (so Succ u v), the P-obligations of v
must resolve or defer to u. This is the temporal dual of `predecessor_f_step_axiom`.
In a discrete linear frame where Succ u v:
- P-obligations in v must resolve to u (the predecessor) or remain as P-obligations in u
- This matches the frame semantics where the predecessor is the unique immediate past

This axiom is necessary because the successor deferral seed contains no past-direction
content (only g_content and deferralDisjunctions for F-step).
-/
axiom successor_p_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (successor_from_deferral_seed u h_mcs h_F_top) ⊆ u ∪ p_content u
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- Axiom appears in file after `successor_succ`

---

### Phase 2: Add forward_chain_p_step theorem [NOT STARTED]

**Goal**: Add theorem to SuccChainFMCS.lean connecting axiom to forward chain

**Tasks**:
- [ ] Add `forward_chain_p_step` theorem after backward_chain_p_step (around line 270)
- [ ] Theorem should use `successor_p_step_axiom` with `forward_chain_mcs` and `forward_chain_has_F_top`
- [ ] Verify theorem compiles

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add theorem after backward_chain_p_step

**Code to add** (after backward_chain_p_step, around line 270):
```lean
/--
P-step for forward chain: p_content(forward_chain (k+1)) ⊆ forward_chain k ∪ p_content(forward_chain k).

This follows from `successor_p_step_axiom` applied to the forward chain construction.
The forward_chain construction uses successor_from_deferral_seed, and this axiom
provides the P-step property for such successors.
-/
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
  successor_p_step_axiom
    (forward_chain M0 k)
    (forward_chain_mcs M0 k)
    (forward_chain_has_F_top M0 k)
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- Theorem can be used in proofs

---

### Phase 3: Fill the sorry [NOT STARTED]

**Goal**: Replace the sorry at line 350 with actual proof

**Tasks**:
- [ ] Replace the sorry with `exact forward_chain_p_step M0 k h_φ`
- [ ] Verify the entire file compiles
- [ ] Verify downstream dependent `succ_chain_canonicalTask_backward_MCS_P_from` still compiles

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace sorry at line 350

**Code change** (lines 347-350):
```lean
-- Before:
    simp only [succ_chain_fam] at h_φ ⊢
    -- Forward chain P-step: p_content(forward_chain (k+1)) ⊆ forward_chain k ∪ p_content(forward_chain k)
    -- This follows from temporal duality but requires additional infrastructure
    sorry

-- After:
    simp only [succ_chain_fam] at h_φ ⊢
    exact forward_chain_p_step M0 k h_φ
```

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds with no sorries in succ_chain_fam_p_step
- `grep -r "sorry" SuccChainFMCS.lean` shows no production sorries remain (only any in comments)

---

### Phase 4: Verify and clean up [NOT STARTED]

**Goal**: Final verification and documentation

**Tasks**:
- [ ] Run full `lake build` to ensure no regressions
- [ ] Verify `succ_chain_canonicalTask_backward_MCS_P_from` (line 742/803) compiles
- [ ] Remove any outdated comments about "pending infrastructure"
- [ ] Update any related docstrings

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Clean up comments at lines 332-337

**Verification**:
- `lake build` completes successfully
- No warnings about missing proofs
- Comments accurately reflect implementation state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- [ ] `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- [ ] `lake build` (full project) succeeds
- [ ] No production sorries remain in succ_chain_fam_p_step
- [ ] Dependent theorem succ_chain_canonicalTask_backward_MCS_P_from compiles

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (axiom added)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (theorem + sorry filled)

## Rollback/Contingency

If implementation fails:
1. `git checkout -- Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
2. `git checkout -- Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
3. Run `lake build` to restore working state
4. Investigate error and revise approach

Alternative approaches if primary fails:
- Extend Succ to 4 conditions (more invasive, same semantic cost)
- Add axiom with different signature if type mismatch occurs
