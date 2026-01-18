# Implementation Plan: Task #570

- **Task**: 570 - Analyze Compound Formula Proof Requirements
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Priority**: High
- **Dependencies**: Task 566, Task 569
- **Research Inputs**: specs/570_analyze_compound_formula_proof_requirements/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the 4 compound formula sorries in `truth_at_implies_semantic_truth` (lines 3627-3651 of FiniteCanonicalModel.lean). The core challenge is bridging semantic truth (`truth_at`) with syntactic membership (assignment equals true). Research identified that the fundamental obstacle is the gap between semantic evaluation and MCS membership - specifically, showing that if semantic evaluation holds, the world state's assignment must record it. The recommended approach uses negation-completeness via `closure_mcs_negation_complete` with a contrapositive argument.

### Research Integration

From research-001.md:
- `IsLocallyConsistent` only provides soundness (compound true => parts true), but we need completeness (parts true => compound true)
- `closure_mcs_negation_complete` provides the key negation-completeness property for MCS sets
- The implication case is the most tractable starting point (requires only negation-completeness)
- Box and temporal cases require modal/temporal canonical properties across histories/times
- Estimated total effort: 14-21 hours across all cases

## Goals & Non-Goals

**Goals**:
- Complete the implication case sorry at line 3635
- Complete the box case sorry at line 3641
- Complete the all_past case sorry at line 3646
- Complete the all_future case sorry at line 3651
- Establish reusable bridge lemmas for semantic-to-syntactic conversion
- Ensure all proofs compile without sorries

**Non-Goals**:
- Restructuring the overall completeness proof architecture
- Changing the definition of `truth_at` or `SemanticWorldState`
- Optimizing proof performance (clarity over efficiency)
- Extending to additional formula types beyond the existing 4

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Negation not directly in closure | High | Medium | May need syntactic equivalence lemmas or `closureWithNeg` construction |
| MCS construction details obscure | Medium | Medium | Trace through Lindenbaum construction carefully, add helper lemmas |
| Time domain complications for temporal cases | High | High | Start with implication case first; temporal cases may need domain-specific infrastructure |
| Box case requires universal quantification over histories | High | High | May need canonical modal property lemma from completeness theory |
| Contrapositive approach introduces complexity | Medium | Medium | Document proof strategy clearly; may fall back to direct approach |

## Implementation Phases

### Phase 1: Infrastructure and Helper Lemmas [NOT STARTED]

**Goal**: Establish the foundational bridge lemmas needed by all 4 cases

**Tasks**:
- [ ] Analyze the exact structure of how `SemanticWorldState` relates to closure MCS
- [ ] Create helper lemma `mcs_of_semantic_world_state` to extract MCS membership from SemanticWorldState
- [ ] Verify `closure_mcs_negation_complete` works with SemanticWorldState's underlying MCS
- [ ] Create lemma `assignment_true_iff_in_mcs` relating assignment values to MCS membership
- [ ] Create lemma `assignment_false_implies_neg_in_mcs` for contrapositive arguments
- [ ] Test infrastructure compiles and key lemmas are usable

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add helper lemmas near line 3600

**Verification**:
- All new lemmas compile without sorries
- `lean_goal` shows lemmas have expected types
- Helper lemmas can be used in simple test cases

---

### Phase 2: Implication Case [NOT STARTED]

**Goal**: Complete the sorry at line 3635 for the implication case (`psi.imp chi`)

**Tasks**:
- [ ] Read the exact goal state at line 3635 using `lean_goal`
- [ ] Implement contrapositive approach:
  - Assume `assignment ⟨psi.imp chi, h_mem⟩ = false`
  - By Phase 1 infrastructure, deduce `(psi.imp chi).neg` is in MCS (or equivalent)
  - Unfold negation semantics to get `psi` true and `chi` false in MCS
  - Use IH or bridge lemma to get `truth_at psi` and `NOT truth_at chi`
  - Derive contradiction with `h_truth : truth_at psi -> truth_at chi`
- [ ] If contrapositive is complex, try direct approach using decidability
- [ ] Test proof compiles and goal is discharged
- [ ] Document the proof strategy in comments

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Line 3635

**Verification**:
- `lean_diagnostic_messages` shows no errors at line 3635
- The sorry is replaced with actual proof term
- Nearby lines still compile

---

### Phase 3: Box Case [NOT STARTED]

**Goal**: Complete the sorry at line 3641 for the box case (`psi.box`)

**Tasks**:
- [ ] Read the exact goal state at line 3641 using `lean_goal`
- [ ] Analyze what's needed for modal canonical property:
  - `h_truth : forall sigma, truth_at M sigma 0 psi` means psi holds at all histories
  - Need to show `assignment ⟨psi.box, h_mem⟩ = true`
- [ ] Check if existing modal lemmas can be leveraged
- [ ] Implement proof using contrapositive approach:
  - Assume box(psi) assignment is false
  - By negation-completeness, there exists a "witness" history where psi fails
  - Derive contradiction with universal quantifier in h_truth
- [ ] Test proof compiles
- [ ] Document proof strategy

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Line 3641

**Verification**:
- `lean_diagnostic_messages` shows no errors at line 3641
- The sorry is replaced with actual proof term

---

### Phase 4: Temporal Cases (all_past and all_future) [NOT STARTED]

**Goal**: Complete the sorries at lines 3646 and 3651 for temporal operators

**Tasks**:
- [ ] Read the exact goal states at lines 3646 and 3651 using `lean_goal`
- [ ] Analyze temporal canonical properties:
  - `all_past`: `forall s < t, truth_at M tau s psi` => assignment true
  - `all_future`: `forall s > t, truth_at M tau s psi` => assignment true
- [ ] Check if temporal cases can reuse pattern from box case
- [ ] Handle time domain issues (FiniteTime vs abstract time)
- [ ] Implement all_past case at line 3646
- [ ] Implement all_future case at line 3651
- [ ] Verify both cases follow similar pattern
- [ ] Document proof strategies

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Lines 3646, 3651

**Verification**:
- `lean_diagnostic_messages` shows no errors at lines 3646, 3651
- Both sorries are replaced with actual proof terms

---

### Phase 5: Verification and Documentation [NOT STARTED]

**Goal**: Ensure all changes are robust and well-documented

**Tasks**:
- [ ] Run full build to verify no regressions: `lake build`
- [ ] Check diagnostic messages for any remaining sorries in the theorem
- [ ] Add inline comments explaining proof strategies
- [ ] Verify `truth_at_implies_semantic_truth` has no remaining sorries
- [ ] Check downstream consumers of the theorem still work
- [ ] Update task 566 summary if applicable

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Documentation only

**Verification**:
- `lake build` succeeds with no errors
- No sorries remain in `truth_at_implies_semantic_truth`
- All downstream theorems compile

## Testing & Validation

- [ ] Each phase produces compiling Lean code
- [ ] `lean_goal` at each sorry location shows no remaining goal
- [ ] `lean_diagnostic_messages` shows no errors in modified file
- [ ] Full `lake build` succeeds after all phases
- [ ] No regressions in theorems that depend on `truth_at_implies_semantic_truth`

## Artifacts & Outputs

- specs/570_analyze_compound_formula_proof_requirements/plans/implementation-001.md (this file)
- Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean (modified with proofs)
- specs/570_analyze_compound_formula_proof_requirements/summaries/implementation-summary-YYYYMMDD.md (upon completion)

## Rollback/Contingency

If proofs prove intractable:
1. **Phase 1 failure**: Document required infrastructure in research report; create subtasks for each missing lemma
2. **Individual case failure**: Mark that case as blocked; proceed with other cases; document blocking reason
3. **All cases fail**: Consider alternative architecture per research recommendations (Strategy C: restructure to avoid the bridge)
4. **Partial completion**: Accept documented sorries as technical debt; create follow-up task for remaining cases

Git provides rollback to any phase boundary via commit history.
