# Implementation Plan: Task #46

- **Task**: 46 - prove_forward_chain_p_step
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 45 (research completed), CanonicalFMCS.lean sorry-free infrastructure
- **Research Inputs**: specs/046_prove_forward_chain_p_step/reports/02_team-research.md
- **Artifacts**: plans/01_transfer-pattern-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Fill the sorry at SuccChainFMCS.lean:350 for the forward chain p-step case. The research conclusively shows that Option A (canonical model transfer) is viable while Option C (bidirectional construction) is mathematically impossible due to Lindenbaum circularity. The primary approach uses the sorry-free `canonical_backward_P` infrastructure to obtain witnesses, then transfers them back to integer indices. If surjectivity proves too complex, fall back to adding `successor_p_step_axiom` (mirroring existing `predecessor_f_step_axiom`).

### Research Integration

Key findings from 02_team-research.md:
- `canonical_backward_P` (CanonicalFrame.lean:170) is sorry-free
- `canonicalMCS_backward_P` (CanonicalFMCS.lean:271) wraps it for CanonicalMCS domain
- `transfer_backward_P` (FMCSTransfer.lean:305) demonstrates the transfer pattern
- Bidirectional chain construction is impossible due to "P-formulas IN v (unknown target)" constraint direction problem

## Goals & Non-Goals

**Goals**:
- Fill the sorry at SuccChainFMCS.lean:350 (forward chain case of succ_chain_fam_p_step)
- Ensure `lake build` succeeds with no sorries in succ_chain_fam_p_step
- Ensure `succ_chain_backward_P` compiles successfully

**Non-Goals**:
- Proving p-step structurally from the successor construction (research shows this is impossible)
- Modifying the Succ relation definition
- Changing the forward_chain construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Surjectivity proof too complex | H | M | Fall back to axiom at Phase 2 decision point |
| Type mismatches in transfer | M | L | Use existing FMCSTransfer pattern as template |
| Classical choice concerns | L | L | Already accepted in codebase (classical logic framework) |
| Integration issues with existing proofs | M | L | Verify dependent theorems still compile |

## Implementation Phases

### Phase 1: Explore Canonical Model Integration [NOT STARTED]

**Goal**: Determine if forward_chain elements can be embedded into CanonicalMCS for transfer

**Tasks**:
- [ ] Read CanonicalMCS definition and understand the CanonicalMCS structure
- [ ] Check if forward_chain elements are already CanonicalMCS instances (by is_mcs property)
- [ ] Explore whether `canonical_backward_P` can be used directly with forward_chain MCS
- [ ] Assess surjectivity requirement: must witness W be in forward_chain image?

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - CanonicalMCS definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - canonical_backward_P
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - forward_chain structure

**Verification**:
- Document whether direct transfer is feasible
- Identify specific obstacles if not

**Decision Point After Phase 1**:
- If direct integration is straightforward: proceed to Phase 2a (Transfer Implementation)
- If surjectivity is too complex: proceed to Phase 2b (Axiom Fallback)

---

### Phase 2a: Implement Transfer-Based Proof [NOT STARTED]

**Goal**: Use canonical_backward_P to prove forward_chain_p_step

**Tasks**:
- [ ] Create helper lemma: `forward_chain_to_CanonicalMCS` (embedding forward_chain k into CanonicalMCS)
- [ ] Use `canonical_backward_P` to obtain witness MCS W with phi in W
- [ ] Prove or assert that W corresponds to some forward_chain index m < k
- [ ] Connect back to show phi in forward_chain m or p_content(forward_chain m)
- [ ] Fill the sorry at line 350

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - add helper lemmas and fill sorry

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- No sorries in forward chain case

---

### Phase 2b: Add Axiom Fallback [NOT STARTED]

**Goal**: Add minimal axiom for forward chain p-step (ONLY if Phase 2a proves infeasible)

**Tasks**:
- [ ] Define `successor_p_step_axiom` in SuccExistence.lean (parallel to `predecessor_f_step_axiom`)
- [ ] Document semantic justification in docstring
- [ ] Use axiom to fill sorry at SuccChainFMCS.lean:350
- [ ] Verify integration with existing theorems

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - add axiom
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - use axiom to fill sorry

**Verification**:
- `lake build` succeeds
- Axiom has clear semantic justification documented

---

### Phase 3: Integration Verification [NOT STARTED]

**Goal**: Ensure the fix integrates correctly with dependent theorems

**Tasks**:
- [ ] Run full `lake build` to check all dependent files compile
- [ ] Verify `succ_chain_backward_P` compiles (uses succ_chain_fam_p_step)
- [ ] Check that no new sorries were introduced
- [ ] Verify the FMCS coherence theorems still work

**Timing**: 20 minutes

**Files to check**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - verify no sorries
- Files that import SuccChainFMCS.lean

**Verification**:
- `lake build` succeeds with no warnings
- All dependent theorems compile

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the approach taken and clean up any temporary code

**Tasks**:
- [ ] Update docstring for `succ_chain_fam_p_step` explaining the proof approach
- [ ] Remove any debug or temporary code
- [ ] Add references to relevant theorems used
- [ ] Update any stale comments about "pending infrastructure"

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - update documentation

**Verification**:
- Documentation accurately reflects implementation
- No stale TODO comments remain

## Testing & Validation

- [ ] `lake build` succeeds with zero sorries in succ_chain_fam_p_step
- [ ] `succ_chain_backward_P` compiles successfully
- [ ] No new sorries introduced elsewhere
- [ ] Full `lake build` completes without errors

## Artifacts & Outputs

- `specs/046_prove_forward_chain_p_step/plans/01_transfer-pattern-plan.md` (this file)
- `specs/046_prove_forward_chain_p_step/summaries/01_implementation-summary.md` (upon completion)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (if axiom fallback)

## Rollback/Contingency

If implementation causes issues:
1. The sorry at line 350 can be restored temporarily
2. `predecessor_f_step_axiom` pattern provides safe fallback
3. Git can revert to pre-change state if needed

If Phase 2a fails and Phase 2b is needed, document why transfer approach was infeasible for future reference.
