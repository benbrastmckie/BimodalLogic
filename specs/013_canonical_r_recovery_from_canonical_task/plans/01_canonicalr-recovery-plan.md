# Implementation Plan: CanonicalR Recovery from CanonicalTask

- **Task**: 13 - canonical_r_recovery_from_canonical_task
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: Tasks 11 (CanonicalTask definition), 12 (successor existence)
- **Research Inputs**: specs/013_canonical_r_recovery_from_canonical_task/reports/01_canonicalr-recovery-analysis.md
- **Artifacts**: plans/01_canonicalr-recovery-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This task establishes the equivalence `CanonicalR(u,v) <-> exists n >= 1, CanonicalTask(u,n,v)`, bridging duration-agnostic and duration-precise canonical accessibility. The forward direction leverages temp_4 transitivity through Succ-chains. The backward direction requires successor existence (task 12) and F-nesting depth bounds. Additionally, a backward-compatibility layer proves canonical_forward_G and canonical_forward_F from CanonicalTask definitions.

### Research Integration

Key findings from research report 01_canonicalr-recovery-analysis.md:
- **Recommendation**: Keep CanonicalR as derived shorthand (do NOT remove)
- CanonicalR used in 36+ active files; removing would be high-risk refactoring
- Forward direction: Easy via temp_4 (`G phi -> GG phi`) transitivity
- Backward direction: Requires successor existence (task 12) and F-nesting bounds
- Backward-compat layer: Prove canonical_forward_G/F from CanonicalTask for seamless migration

## Goals & Non-Goals

**Goals**:
- Prove `CanonicalTask M n M' -> CanonicalR M M'` (forward direction)
- Prove `CanonicalR M M' -> exists n >= 1, CanonicalTask M n M'` (backward direction)
- Prove backward-compatibility theorems (canonical_forward_G', canonical_forward_F')
- Document the two-level abstraction (CanonicalTask primitive, CanonicalR derived)

**Non-Goals**:
- Replace existing CanonicalR usage with CanonicalTask (keep both)
- Address dense temporal logic (applies only to discrete case)
- Modify existing CanonicalFrame.lean definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tasks 11/12 not completed | H | M | Document dependency explicitly; plan phases to be implementable once deps ready |
| Backward direction complexity | M | M | Phase 3 allocated 1.5 hours; may need induction on F-nesting depth |
| g_content transitivity proof difficulty | L | L | temp_4 already proved; transitivity is well-established pattern |
| Succ-chain construction in backward direction | M | M | Leverage successor_exists from task 12; bounded witness theorem |

## Implementation Phases

### Phase 1: Create File Structure and Import Dependencies [COMPLETED]

**Goal**: Set up CanonicalRecovery.lean with required imports and stub theorems

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`
- [ ] Import CanonicalFrame.lean, CanonicalTask.lean (from task 11), SuccRelation.lean
- [ ] Add module docstring explaining the recovery theorem's role
- [ ] Stub the main theorem signatures with `sorry`

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` - New file

**Verification**:
- File compiles with `lake build`
- Stubs visible with proper type signatures

---

### Phase 2: Forward Direction (CanonicalTask implies CanonicalR) [COMPLETED]

**Goal**: Prove that any CanonicalTask chain implies CanonicalR

**Tasks**:
- [ ] Prove helper: `Succ_preserves_g_content` showing each Succ step preserves g_content
- [ ] Prove `canonicalTask_step_preserves_g_content` by induction on chain length
- [ ] Prove main theorem `canonicalTask_implies_canonicalR`:
  ```lean
  theorem canonicalTask_implies_canonicalR {M M' : Set Formula} {n : Nat}
      (h_mcs : SetMaximalConsistent M) (h_n : n >= 1)
      (h_task : CanonicalTask M n M') :
      CanonicalR M M'
  ```
- [ ] Use temp_4 (`G phi -> GG phi`) for transitivity through the chain

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`

**Verification**:
- `canonicalTask_implies_canonicalR` compiles without `sorry`
- Unit tests: `CanonicalTask M 1 M' -> CanonicalR M M'` (single step case)

---

### Phase 3: Backward Direction (CanonicalR implies CanonicalTask) [PARTIAL]

**Goal**: Prove that CanonicalR implies existence of some CanonicalTask chain

**Tasks**:
- [ ] Import `successor_exists` from task 12
- [ ] Define auxiliary: `g_content_implies_successor_chain` showing g_content subset can be decomposed into Succ steps
- [ ] Prove bounded witness theorem: F-nesting depth bounds the chain length needed
- [ ] Prove main theorem `canonicalR_implies_canonicalTask`:
  ```lean
  theorem canonicalR_implies_canonicalTask {M M' : Set Formula}
      (h_mcs_M : SetMaximalConsistent M) (h_mcs_M' : SetMaximalConsistent M')
      (h_R : CanonicalR M M') :
      exists n : Nat, n >= 1 /\ CanonicalTask M n M'
  ```
- [ ] Handle edge case: when M = M' (reflexive), use n = 0 path (excluded by n >= 1 condition; may need n >= 0)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`

**Verification**:
- `canonicalR_implies_canonicalTask` compiles without `sorry`
- Check that it correctly uses successor_exists from task 12

---

### Phase 4: Backward-Compatibility Layer [COMPLETED]

**Goal**: Prove existing lemmas (canonical_forward_G, canonical_forward_F) from CanonicalTask definitions

**Tasks**:
- [ ] Prove `canonical_forward_G'` using canonicalTask_implies_canonicalR:
  ```lean
  theorem canonical_forward_G' (M M' : Set Formula) {n : Nat}
      (h_task : CanonicalTask M n M') (phi : Formula) (h_G : G phi in M) :
      phi in M'
  ```
- [ ] Prove `canonical_forward_F'` with explicit duration bound:
  ```lean
  theorem canonical_forward_F_with_bound (M : Set Formula)
      (h_mcs : SetMaximalConsistent M) (phi : Formula) (h_F : F phi in M) :
      exists (W : Set Formula) (n : Nat),
        SetMaximalConsistent W /\ CanonicalTask M n W /\ phi in W /\ n <= F_depth phi
  ```
- [ ] Add lemma showing equivalence to original `canonical_forward_F`
- [ ] Document which lemma to use in new vs existing code

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`

**Verification**:
- Backward-compat lemmas compile without `sorry`
- Verify types match original canonical_forward_G/F signatures

---

### Phase 5: Integration and Documentation [COMPLETED]

**Goal**: Add module to build, verify full compilation, update project docs

**Tasks**:
- [ ] Add CanonicalRecovery.lean to Bimodal.lean imports
- [ ] Run `lake build` to verify full project compilation
- [ ] Add docstrings explaining the two-level abstraction:
  - CanonicalTask: Duration-precise primitive for TaskFrame axioms
  - CanonicalR: Duration-agnostic derived for transitivity/Preorder
- [ ] Cross-reference recovery theorem in CanonicalFrame.lean comments
- [ ] Update any existing documentation mentioning CanonicalR

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` - Docstrings
- `Theories/Bimodal.lean` - Import
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Cross-reference comment

**Verification**:
- `lake build` succeeds
- Module accessible via import Theories.Bimodal.Metalogic.StagedConstruction.CanonicalRecovery

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] All theorems compile without `sorry`
- [ ] Forward direction: `canonicalTask_implies_canonicalR` works for n=1, n=2, n=5 test cases
- [ ] Backward direction: `canonicalR_implies_canonicalTask` produces valid n for test MCS pairs
- [ ] Backward-compat: `canonical_forward_G'` type-checks against original usage patterns
- [ ] No regressions in existing CanonicalFrame.lean or downstream files

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` - Main implementation
- `specs/013_canonical_r_recovery_from_canonical_task/summaries/01_canonicalr-recovery-summary.md` - Execution summary

## Rollback/Contingency

If the backward direction proves too complex:
1. Implement forward direction and backward-compat layer first (phases 2, 4)
2. Mark backward direction as [PARTIAL] with detailed notes on blocking issues
3. Create subtask for backward direction once tasks 11/12 provide clearer path
4. CanonicalR remains usable even without full bidirectional proof

If tasks 11/12 are delayed:
1. Complete phase 1 (file structure with stubs)
2. Mark task as [BLOCKED] pending dependencies
3. Resume when prerequisites complete
