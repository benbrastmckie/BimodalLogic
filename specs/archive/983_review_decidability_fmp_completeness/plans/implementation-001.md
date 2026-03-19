# Implementation Plan: Task #983 — Decidability and FMP Review

- **Task**: 983 - Review decidability results and FMP for publication
- **Status**: [NOT STARTED]
- **Effort**: 45 hours
- **Dependencies**: Task 981 (discrete axiom debt, in progress), Task 982 (dense wiring)
- **Research Inputs**: specs/983_review_decidability_fmp_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

This task conducts a comprehensive review of decidability results in the ProofChecker codebase and implements missing components required for publication-quality decidability claims alongside soundness and completeness. The research identifies four key gaps: (1) FMP not proven, (2) decidability completeness not proven, (3) dense completeness wiring sorries, and (4) discrete completeness axiom debt. This plan coordinates addressing all gaps via delegation to sub-tasks and direct implementation where appropriate.

### Research Integration

- **Report**: research-001.md (team research, 3 teammates)
- **Key findings**: Decidability soundness is proven and sorry-free. FMP and decidability completeness are critical gaps requiring filtration-based proof. Dense completeness needs domain wiring (Task 982). Discrete completeness has axiom debt (Task 981). Total effort estimated at 40-61 hours.

## Goals & Non-Goals

**Goals**:
- Verify and document current decidability results and their proof status
- Coordinate completion of dense wiring (Task 982) and discrete axiom removal (Task 981)
- Formalize the Finite Model Property via filtration
- Prove decidability completeness (`decide_complete`)
- Produce publication-quality decidability theorems

**Non-Goals**:
- Changing the core tableau decision procedure (already functional)
- Addressing soundness edge-case sorries (2 in Soundness.lean, low priority per research)
- Full complexity analysis (PSPACE-completeness proof)
- Writing publication prose (separate documentation task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMP filtration proof complexity exceeds estimates | High | Medium | Break into smaller lemmas; leverage existing SubformulaClosure machinery |
| Task 981/982 delayed or blocked | Medium | Low | Phases 4-5 can proceed independently; 981/982 coordination in Phase 1 |
| Definition mismatches (prior FMP attempt failed this way) | High | Medium | Phase 2 explicitly verifies definition alignment before proving |
| Truth preservation across filtration quotient is complex | Medium | Medium | Use literature references; adapt known proof patterns |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `FrameConditions/Completeness.lean` (dense wiring, Task 982 scope)
- 2 sorries in `Soundness.lean` (edge cases, out of scope for this task)

### Expected Resolution
- Task 982 resolves the 3 dense wiring sorries
- This task does not directly resolve sorries; it creates new sorry-free proofs (FMP, decidability completeness)

### New Sorries
- None. NEVER introduce new sorries. If FMP or decidability proofs cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- Dense wiring sorries handled by Task 982
- Discrete axiom debt handled by Task 981
- Soundness edge-case sorries remain (low priority, documented)

## Implementation Phases

### Phase 1: Audit and Coordination Setup [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish baseline status of all decidability components and coordinate with dependent tasks

**Tasks:**
- [ ] Audit `Metalogic/Decidability/` for current status (confirm sorry-free, axiom-free)
- [ ] Audit `Decidability/Correctness.lean` for `decide_sound` status
- [ ] Verify countermodel extraction (`CountermodelExtraction.lean`) is sorry-free
- [ ] Document current state of Task 981 (discrete axiom) and Task 982 (dense wiring)
- [ ] Create coordination notes in task directory

**Timing:** 2 hours

**Files to review:**
- `Theories/Metalogic/Decidability/` - decision procedure
- `Theories/Decidability/Correctness.lean` - decidability soundness
- `Theories/Decidability/CountermodelExtraction.lean` - countermodel extraction

**Verification:**
- Complete status report of all decidability-related modules
- Dependencies on Task 981/982 documented

---

### Phase 2: FMP Infrastructure [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Set up foundational infrastructure for Finite Model Property proof via filtration

**Tasks:**
- [ ] Review existing `SubformulaClosure` machinery and verify it meets FMP needs
- [ ] Verify `validity` definition matches intended semantics (avoid prior FMP failure)
- [ ] Design filtration equivalence relation: `w ≡_Σ v ↔ ∀ ψ ∈ closure(φ), w ⊨ ψ ↔ v ⊨ ψ`
- [ ] Create `Theories/Metalogic/FMP/` module directory
- [ ] Define filtration equivalence and prove it is an equivalence relation
- [ ] Prove equivalence classes are bounded by 2^|closure(φ)|

**Timing:** 5 hours

**Files to create/modify:**
- `Theories/Metalogic/FMP/Basic.lean` - FMP module root
- `Theories/Metalogic/FMP/FiltrationEquivalence.lean` - equivalence relation

**Verification:**
- `lake build` passes
- `FiltrationEquivalence` module compiles sorry-free
- Size bound theorem stated and proven

---

### Phase 3: Filtered Model Construction [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Construct the filtered (quotiented) model and prove its structure is preserved

**Tasks:**
- [ ] Define filtered model structure (worlds = equivalence classes, accessibility lifted)
- [ ] Prove filtered model is a valid frame (accessibility well-defined on quotient)
- [ ] Handle both temporal and modal accessibility in the bimodal setting
- [ ] Prove finiteness of filtered model (world count ≤ 2^|closure(φ)|)

**Timing:** 8 hours

**Files to create/modify:**
- `Theories/Metalogic/FMP/FilteredModel.lean` - filtered model construction
- `Theories/Metalogic/FMP/Finiteness.lean` - finiteness proof

**Verification:**
- `lake build` passes
- All new files sorry-free
- Finiteness theorem formally proven with explicit bound

---

### Phase 4: Filtration Truth Preservation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove the Filtration Lemma: truth is preserved across the quotient for subformula closure

**Tasks:**
- [ ] State Filtration Lemma: `M, w ⊨ ψ ↔ M*, [w] ⊨ ψ` for all `ψ ∈ closure(φ)`
- [ ] Prove by induction on formula structure (atom, bot, imp, box, future/past)
- [ ] Handle temporal operators (dense/discrete variations if needed)
- [ ] Integrate with existing truth lemma infrastructure

**Timing:** 8 hours

**Files to create/modify:**
- `Theories/Metalogic/FMP/FiltrationLemma.lean` - truth preservation proof

**Verification:**
- `lake build` passes
- Filtration Lemma sorry-free
- `grep -rn "\bsorry\b" Theories/Metalogic/FMP/` returns empty

---

### Phase 5: FMP Theorem [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** State and prove the Finite Model Property theorem

**Tasks:**
- [ ] State FMP: `¬(⊨ φ) → ∃ M : FiniteModel, ¬(truth_at M w φ)` with size bound
- [ ] Construct finite countermodel from canonical model via filtration
- [ ] Prove FMP theorem connecting all prior lemmas
- [ ] Verify theorem uses standard `valid` definition (not a variant)
- [ ] Add FMP to decidability module exports

**Timing:** 6 hours

**Files to create/modify:**
- `Theories/Metalogic/FMP/FMP.lean` - main FMP theorem
- `Theories/Metalogic/FMP.lean` - module index file

**Verification:**
- `lake build` passes
- FMP theorem sorry-free and axiom-free
- FMP uses canonical `valid` definition (verified via `lean_hover_info`)

---

### Phase 6: Decidability Completeness [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Prove `decide_complete`: if φ is valid, the decision procedure returns ProofFound

**Tasks:**
- [ ] Connect FMP to open saturated branch analysis
- [ ] Prove tableau exhaustiveness: saturated open branch implies finite countermodel exists
- [ ] State `decide_complete : ⊨ φ → ∃ d, decide φ = ProofFound d`
- [ ] Prove decide_complete using FMP and tableau properties
- [ ] Verify symmetry with `decide_sound`

**Timing:** 8 hours

**Files to create/modify:**
- `Theories/Decidability/Completeness.lean` - decidability completeness proof
- `Theories/Decidability/Correctness.lean` - update with completeness

**Verification:**
- `lake build` passes
- `decide_complete` sorry-free
- Both `decide_sound` and `decide_complete` present in decidability module

---

### Phase 7: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 6, Task 981, Task 982
- **Goal:** Verify all decidability results cohere and are publication-ready

**Tasks:**
- [ ] Verify Task 981 (discrete axiom) is complete or document status
- [ ] Verify Task 982 (dense wiring) is complete or document status
- [ ] Run full `lake build` and verify no sorries in decidability modules
- [ ] Run axiom audit: `grep -n "^axiom " Theories/Metalogic/Decidability/*.lean`
- [ ] Create summary of all decidability theorems with their status
- [ ] Update project documentation pointers

**Timing:** 4 hours

**Files to verify:**
- `Theories/Metalogic/Decidability/` - all modules
- `Theories/Metalogic/FMP/` - all modules
- `Theories/Decidability/` - correctness and completeness

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Metalogic/Decidability/ Theories/Metalogic/FMP/ Theories/Decidability/` returns empty
- `grep -n "^axiom " <same paths>` shows no custom axioms

---

### Phase 8: Documentation Update [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Update documentation with proven decidability results

**Tasks:**
- [ ] Update CHANGE_LOG.md with decidability milestones
- [ ] Update ROAD_MAP.md removing decidability gaps
- [ ] Create decidability summary in task directory
- [ ] Document any remaining edge cases (soundness sorries, etc.)

**Timing:** 4 hours

**Files to modify:**
- `specs/CHANGE_LOG.md`
- `specs/ROAD_MAP.md`
- `specs/983_review_decidability_fmp_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Verification:**
- Documentation accurately reflects proven results
- All artifacts properly linked

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Metalogic/FMP/` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Decidability/Completeness.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Metalogic/FMP/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Theorem Verification
- [ ] `finite_model_property` theorem stated with explicit bound
- [ ] `decide_sound` remains intact
- [ ] `decide_complete` proven
- [ ] FMP uses canonical `valid` definition

### Integration Verification
- [ ] Task 981 completion status verified
- [ ] Task 982 completion status verified
- [ ] All decidability components coherent

## Artifacts & Outputs

- `specs/983_review_decidability_fmp_completeness/plans/implementation-001.md` (this file)
- `Theories/Metalogic/FMP/Basic.lean` - FMP module root
- `Theories/Metalogic/FMP/FiltrationEquivalence.lean` - equivalence relation
- `Theories/Metalogic/FMP/FilteredModel.lean` - filtered model
- `Theories/Metalogic/FMP/Finiteness.lean` - finiteness proof
- `Theories/Metalogic/FMP/FiltrationLemma.lean` - truth preservation
- `Theories/Metalogic/FMP/FMP.lean` - main theorem
- `Theories/Decidability/Completeness.lean` - decidability completeness
- `specs/983_review_decidability_fmp_completeness/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

- FMP module is isolated in `Theories/Metalogic/FMP/`; can be removed without affecting existing code
- Decidability completeness builds on FMP; if FMP blocked, completeness phase marked [BLOCKED]
- If definition mismatches discovered (Phase 2), revert to research for alignment strategy
- Task 981/982 delays do not block Phases 1-6; only Phase 7 integration requires their completion
