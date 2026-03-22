# Implementation Plan: CanonicalTask Relation Definition

- **Task**: 11 - define_canonical_task_relation
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: Task 10 (completed - Succ relation in SuccRelation.lean)
- **Research Inputs**: specs/011_define_canonical_task_relation/reports/01_canonical-task-research.md
- **Artifacts**: plans/01_canonical-task-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Define the CanonicalTask relation as an integer-indexed relation built inductively from the Succ relation (Task 10). The implementation uses a split approach: define CanonicalTask_forward (Nat-indexed) and CanonicalTask_backward (Nat-indexed) separately, then combine into CanonicalTask (Int-indexed). This pattern mirrors CanonicalR_chain from DovetailedCoverageReach.lean. The plan covers the three TaskFrame axioms (nullity identity, forward compositionality, converse) and the bounded witness corollary.

### Research Integration

From report 01_canonical-task-research.md:
- All prerequisites exist in SuccRelation.lean: Succ, single_step_forcing, Succ_implies_CanonicalR
- Recommended split approach (forward/backward chains) for cleaner proofs
- Estimated 150-180 lines of code, moderate difficulty
- Converse theorem requires careful constructor design to hold by construction

## Goals & Non-Goals

**Goals**:
- Define iter_F helper for iterated F application
- Define CanonicalTask_forward and CanonicalTask_backward inductively
- Define combined CanonicalTask with Int index
- Prove nullity identity: CanonicalTask(u, 0, v) iff u = v
- Prove forward compositionality: chain concatenation property
- Prove converse: CanonicalTask(u, n, v) iff CanonicalTask(v, -n, u)
- Prove bounded witness corollary using single_step_forcing
- Add comprehensive docstrings for all definitions/theorems

**Non-Goals**:
- Full TaskFrame instance (may be separate task)
- Integration with completeness proof
- Automation tactics (simp_all setup beyond basic simp lemmas)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Integer arithmetic complexity | M | M | Prove Nat version first, derive Int version |
| Converse proof complexity | M | L | Design backward constructor to make converse definitional |
| Bounded witness induction difficulty | M | M | Use single_step_forcing as black box, follow research proof strategy |
| Import issues | L | L | Imports clearly documented in research report |

## Implementation Phases

### Phase 1: File Setup and Helper Definitions [COMPLETED]

**Goal**: Create CanonicalTaskRelation.lean with imports, namespace, and iter_F helper

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
- [ ] Add imports: SuccRelation, CanonicalFrame, MCSProperties, TaskFrame
- [ ] Define namespace Bimodal.Metalogic.Bundle
- [ ] Define `iter_F : Nat -> Formula -> Formula` for n-fold F application
- [ ] Add `iter_F_zero` and `iter_F_succ` lemmas
- [ ] Add docstrings explaining iter_F purpose

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - create new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalTaskRelation` succeeds
- No sorries in iter_F definition and lemmas

---

### Phase 2: Forward and Backward Chain Definitions [COMPLETED]

**Goal**: Define CanonicalTask_forward and CanonicalTask_backward inductively

**Tasks**:
- [ ] Define `CanonicalTask_forward : Set Formula -> Nat -> Set Formula -> Prop`
  - Constructor `base`: CanonicalTask_forward u 0 u
  - Constructor `step`: Succ u w -> CanonicalTask_forward w n v -> CanonicalTask_forward u (n+1) v
- [ ] Define `CanonicalTask_backward : Set Formula -> Nat -> Set Formula -> Prop`
  - Constructor `base`: CanonicalTask_backward u 0 u
  - Constructor `step`: Succ v w -> CanonicalTask_backward u n w -> CanonicalTask_backward u (n+1) v
- [ ] Add accessor lemmas for constructors
- [ ] Add docstrings explaining forward vs backward direction

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Both inductive definitions compile without errors

---

### Phase 3: Combined CanonicalTask Definition [COMPLETED]

**Goal**: Define CanonicalTask with Int index, combining forward and backward chains

**Tasks**:
- [ ] Define `CanonicalTask : Set Formula -> Int -> Set Formula -> Prop`
  - Match on Int: ofNat k uses CanonicalTask_forward, negSucc k uses CanonicalTask_backward
- [ ] Add `CanonicalTask_of_nat` simp lemma: CanonicalTask u (k : Nat) v = CanonicalTask_forward u k v
- [ ] Add `CanonicalTask_neg_succ` simp lemma for negative case
- [ ] Add docstrings explaining Int indexing semantics

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Combined definition matches forward/backward appropriately

---

### Phase 4: Nullity Identity Axiom [COMPLETED]

**Goal**: Prove CanonicalTask(u, 0, v) iff u = v

**Tasks**:
- [ ] Add theorem `CanonicalTask_forward_zero`: CanonicalTask_forward u 0 v iff u = v
  - Forward: case analysis, only base applies
  - Backward: substitute and apply base
- [ ] Add theorem `CanonicalTask_nullity_identity`: CanonicalTask u 0 v iff u = v
  - Reduce to CanonicalTask_forward_zero via definition
- [ ] Mark as @[simp] for automation
- [ ] Add docstring explaining this is the nullity axiom

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Both forward/backward directions proven
- No sorries

---

### Phase 5: Forward Compositionality [COMPLETED]

**Goal**: Prove chain concatenation for forward chains

**Tasks**:
- [ ] Add theorem `CanonicalTask_forward_comp`:
  ```lean
  CanonicalTask_forward u m w -> CanonicalTask_forward w n v -> CanonicalTask_forward u (m + n) v
  ```
  - Induction on first derivation
  - Base: m = 0 means u = w, result follows
  - Step: use IH and step constructor
- [ ] Add theorem for Int version (restricted to non-negative):
  ```lean
  0 <= m -> 0 <= n -> CanonicalTask u m w -> CanonicalTask w n v -> CanonicalTask u (m + n) v
  ```
- [ ] Add docstring explaining chain concatenation semantics

**Timing**: 40 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Both Nat and Int versions proven
- Arithmetic lemmas (add_comm, etc.) used correctly

---

### Phase 6: Converse Theorem [COMPLETED]

**Goal**: Prove CanonicalTask(u, n, v) iff CanonicalTask(v, -n, u)

**Tasks**:
- [ ] Add helper lemma `CanonicalTask_forward_backward_flip`:
  ```lean
  CanonicalTask_forward u n v iff CanonicalTask_backward v n u
  ```
  - Induction on n/derivation structure
- [ ] Add theorem `CanonicalTask_converse`:
  ```lean
  CanonicalTask u n v iff CanonicalTask v (-n) u
  ```
  - Case split on Int (ofNat vs negSucc)
  - Use forward_backward_flip in each direction
- [ ] Add docstring explaining converse captures temporal reversal

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Both directions of iff proven
- Int negation handled correctly (including edge cases)

---

### Phase 7: Bounded Witness Corollary [COMPLETED]

**Goal**: Prove bounded witness theorem using single_step_forcing

**Tasks**:
- [ ] Add theorem `bounded_witness`:
  ```lean
  theorem bounded_witness
      (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
      (phi : Formula) (n : Nat)
      (h_Fn : iter_F n phi ∈ u)
      (h_Fn1_not : iter_F (n + 1) phi ∉ u)
      (h_task : CanonicalTask_forward u n v) :
      phi ∈ v
  ```
- [ ] Prove by induction on n:
  - Base (n = 0): iter_F 0 phi = phi in u, task u 0 v means u = v, so phi in v
  - Step (n = k + 1): Use single_step_forcing to get intermediate witness, apply IH
- [ ] Add helper lemmas for iter_F membership propagation if needed
- [ ] Add docstring explaining bounded witness semantics

**Timing**: 50 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build` succeeds
- Induction structure correct
- single_step_forcing applied correctly
- No sorries

---

### Phase 8: Final Verification and Documentation [COMPLETED]

**Goal**: Verify complete file and add module documentation

**Tasks**:
- [ ] Add module docstring explaining CanonicalTaskRelation.lean purpose
- [ ] Document relationship to TaskFrame axioms
- [ ] Document relationship to future tasks (canonical model construction)
- [ ] Run full `lake build` to verify all theorems
- [ ] Check no sorries with grep
- [ ] Verify all core theorems are proven:
  - CanonicalTask_nullity_identity
  - CanonicalTask_forward_comp
  - CanonicalTask_converse
  - bounded_witness

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalTaskRelation` succeeds with no warnings
- `grep -r "sorry" CanonicalTaskRelation.lean` returns no results
- All theorems documented

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.CanonicalTaskRelation` succeeds
- [ ] No sorries in the file (`grep sorry CanonicalTaskRelation.lean`)
- [ ] All three TaskFrame axioms proven:
  - [ ] `CanonicalTask_nullity_identity`
  - [ ] `CanonicalTask_forward_comp` (or restricted version)
  - [ ] `CanonicalTask_converse`
- [ ] Bounded witness corollary proven:
  - [ ] `bounded_witness`
- [ ] Documentation comments for each definition/theorem
- [ ] Module compiles cleanly with no warnings

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - New Lean 4 module
- `specs/011_define_canonical_task_relation/plans/01_canonical-task-plan.md` - This plan
- `specs/011_define_canonical_task_relation/summaries/01_canonical-task-summary.md` - Summary (post-implementation)

## Rollback/Contingency

- If converse proof becomes complex, simplify to iff with explicit forward/backward proofs
- If bounded_witness induction is tricky, add intermediate lemmas for iter_F propagation
- If Int arithmetic causes issues, prove Nat versions only and defer Int combination
- Full rollback: `git checkout -- Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
