# Implementation Plan: Task #906

- **Task**: 906 - Box Admissible Histories Omega Closure
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-004.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Modify the semantic framework so that Box quantifies over a designated set of admissible histories (Omega), matching the JPL paper's specification. This follows **Choice B**: Define Omega as the closure of canonical histories under ALL time-shifts, rather than using constant families (Choice A). The research report (research-004.md) identified that the root cause of two sorries in Representation.lean is the mismatch between Lean's Box (all histories) and the paper's Box (histories in Omega).

### Research Integration

From research-004.md:
- Problem 1 (line 229): Box forward case of truth lemma - cannot prove truth_at for arbitrary world histories with empty domains
- Problem 2 (line 95): constant_family_bmcs_exists_int - existence of constant-family BMCS
- Root cause: Box quantifies over ALL type-theoretically possible histories, but paper quantifies over Omega
- Solution: Add Omega parameter to truth_at, define canonicalOmega as shift-closure

## Goals & Non-Goals

**Goals**:
- Add Omega parameter to truth_at (box case quantifies over sigma in Omega)
- Update validity/satisfiable/semantic_consequence to include Omega
- Update soundness proofs with Omega threading (MF/TF use shift-closure)
- Update time_shift_preserves_truth with Omega
- Define canonicalOmega as shift-closure of canonical histories
- Eliminate or restructure constant_family_bmcs_exists_int sorry
- Fix truth lemma box forward case (line 229)

**Non-Goals**:
- Changing the proof system (Axiom, DerivationTree)
- Modifying formula syntax
- Rewriting temporal operator semantics (only Box changes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large scope of type signature changes | High | High | Phase incrementally; commit after each phase |
| MF/TF soundness requires shift-closure | Medium | Medium | Add ShiftClosed predicate early; verify works before proceeding |
| Non-constant families complicate canonical model | Medium | Medium | Choice B uses non-constant families which aligns naturally with shift-closure |
| Downstream modules may break | High | High | Build frequently; fix compilation errors before next phase |

## Sorry Characterization

### Pre-existing Sorries
- Line 229 in Representation.lean: Box forward case of truth lemma
- Line 95 in Representation.lean: constant_family_bmcs_exists_int (BMCS existence)

### Expected Resolution
- Phase 4 fixes line 229 by using canonicalOmega: box quantifies over sigma in Omega, and all sigma are canonical histories with universal domain
- Line 95 may be restructured or eliminated: with non-constant families and Omega, the constant-family requirement becomes unnecessary

### New Sorries
- None expected. The fundamental gap (empty-domain histories) is eliminated by Omega.

### Remaining Debt
- Temporal coherence construction may retain sorries from DovetailingChain
- These are separate from the Omega change and outside this task's scope

## Axiom Characterization

### Pre-existing Axioms
- None directly related to this change

### Expected Resolution
- N/A - no axioms in scope

### New Axioms
- None

### Remaining Debt
- N/A

## Implementation Phases

### Phase 1: Add Omega to truth_at [NOT STARTED]

- **Dependencies:** None
- **Goal:** Modify core semantic definition to include admissible history set

**Tasks**:
- [ ] Add Omega parameter to truth_at definition
- [ ] Modify Box case: `forall sigma in Omega, truth_at M Omega sigma t phi`
- [ ] Thread Omega through other cases (no behavior change)
- [ ] Add ShiftClosed predicate definition

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Core semantic change

**Verification**:
- File compiles without errors
- truth_at signature includes Omega parameter

---

### Phase 2: Update Validity and Satisfiability [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update semantic definitions for validity, consequence, and satisfiability

**Tasks**:
- [ ] Add Omega to valid definition (quantify over Omega, require tau in Omega)
- [ ] Add Omega to semantic_consequence definition
- [ ] Add Omega to satisfiable definition
- [ ] Update formula_satisfiable if needed
- [ ] Update validity lemmas (valid_iff_empty_consequence, etc.)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean` - Definition updates

**Verification**:
- File compiles
- Definitions require tau in Omega for validity statements

---

### Phase 3: Update Soundness Proofs [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Thread Omega through all soundness proofs

**Tasks**:
- [ ] Update SoundnessLemmas.lean with Omega threading
- [ ] Update axiom validity lemmas (prop_k, modal_t, modal_4, etc.)
- [ ] For T axiom: use tau in Omega
- [ ] For 4/5 axioms: use Omega closure
- [ ] For MF/TF: add shift-closure hypothesis, prove using time_shift_preserves_truth
- [ ] Update main soundness theorem

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Bridge theorems
- `Theories/Bimodal/Metalogic/Soundness.lean` - Main soundness proof

**Verification**:
- Both files compile
- All axiom validity lemmas proven
- soundness theorem proven

---

### Phase 4: Update Time-Shift Infrastructure [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove time_shift_preserves_truth with Omega parameter

**Tasks**:
- [ ] Thread Omega through time_shift_preserves_truth
- [ ] Box case requires shift-closure of Omega
- [ ] Update helper lemmas (truth_double_shift_cancel, etc.)
- [ ] Update exists_shifted_history

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` (TimeShift section)

**Verification**:
- time_shift_preserves_truth compiles with Omega parameter
- Shift-closure is used in box case

---

### Phase 5: Canonical Model with Omega [NOT STARTED]

- **Dependencies:** Phases 1-4
- **Goal:** Define canonicalOmega and fix truth lemma

**Tasks**:
- [ ] Define canonicalOmega as shift-closure of canonical histories
- [ ] Update canonicalHistory to use non-constant families (fam.mcs t at time t)
- [ ] Update CanonicalWorldState type if needed
- [ ] Update canonical_truth_lemma_all: map fam.mcs t to truth_at at time t
- [ ] Fix box forward case (line 229): forall sigma in canonicalOmega works because all are canonical histories
- [ ] Update box backward case if needed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` - Core fix

**Verification**:
- Box forward case sorry eliminated
- canonical_truth_lemma_all compiles without sorries in box case

---

### Phase 6: Update Completeness Theorems [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Update standard completeness theorems with Omega

**Tasks**:
- [ ] Update standard_representation with canonicalOmega
- [ ] Update standard_context_representation
- [ ] Update standard_weak_completeness
- [ ] Update standard_strong_completeness
- [ ] Evaluate constant_family_bmcs_exists_int: eliminate or restructure

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` - Completeness theorems

**Verification**:
- All completeness theorems compile
- constant_family_bmcs_exists_int sorry reduced or eliminated

---

## Testing & Validation

- [ ] `lake build` succeeds for all modified files
- [ ] No new sorries introduced
- [ ] Box forward case sorry in truth lemma eliminated
- [ ] Soundness theorem proven
- [ ] Completeness theorems preserved (may have sorry reduction)
- [ ] MF/TF axioms valid with shift-closure

## Artifacts & Outputs

- `specs/906_box_admissible_histories_omega_closure/plans/implementation-001.md` - This plan
- Modified files:
  - `Theories/Bimodal/Semantics/Truth.lean`
  - `Theories/Bimodal/Semantics/Validity.lean`
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
  - `Theories/Bimodal/Metalogic/Soundness.lean`
  - `Theories/Bimodal/Metalogic/Representation.lean`

## Rollback/Contingency

If implementation reveals fundamental issues:
1. Git revert to pre-implementation state
2. Consider Choice A (constant families + Omega) as fallback
3. Choice A is simpler but retains constant_family_bmcs_exists_int sorry

If shift-closure complicates MF/TF:
1. Add explicit ShiftClosed hypothesis to validity definition
2. Prove canonical Omega is shift-closed as separate lemma
