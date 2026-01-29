# Implementation Plan: Task #732

- **Task**: 732 - Complete phase 4 of task 630: Prove mem_extractTrueAtomSet_iff helper lemma
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/732_complete_630_phase4_truth_lemma_proof/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes the `mem_extractTrueAtomSet_iff` lemma which establishes that `p \in extractTrueAtomSet b <-> SignedFormula.pos (.atom p) \in b`. The proof uses the standard generalized accumulator pattern for foldl membership proofs: state a suffices clause generalizing the accumulator, prove by induction on the branch list, then instantiate with the empty set.

### Research Integration

Research report research-001.md identified:
- Key Mathlib lemmas: `List.foldl_nil`, `List.foldl_cons`, `Finset.mem_insert`, `Finset.notMem_empty`
- Case structure: 12 cases (2 signs x 6 formula constructors) but only `pos + atom` modifies accumulator
- Recommended approach: suffices with generalized accumulator

## Goals and Non-Goals

**Goals**:
- Complete the `mem_extractTrueAtomSet_iff` lemma proof
- Replace the `sorry` at line 277 with a working proof
- Ensure `lake build` succeeds with no errors

**Non-Goals**:
- Refactoring extractTrueAtomSet definition
- Adding additional helper lemmas beyond what is needed
- Performance optimization

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case explosion verbose | Low | High | Use rcases for structured matching, extract common patterns |
| Tactic state complexity | Low | Medium | Use show to clarify expected types |
| Missing lemmas | Low | Low | Research identified all needed lemmas exist |

## Implementation Phases

### Phase 1: Proof Structure Setup [COMPLETED]

**Goal**: Establish the suffices clause and set up induction

**Tasks**:
- [ ] Replace `sorry` with `suffices h : forall acc, p \in b.foldl (...) acc <-> p \in acc \/ SignedFormula.pos (.atom p) \in b`
- [ ] Add induction on branch `b` after suffices
- [ ] Apply the suffices to empty set at the end: `exact h empty`
- [ ] Verify structure compiles (may have sorry in subgoals)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean` - lines 269-277

**Verification**:
- lean_goal shows expected proof state structure
- Induction generates nil and cons cases

---

### Phase 2: Base Case (nil) [COMPLETED]

**Goal**: Prove the base case where branch is empty list

**Tasks**:
- [ ] In the nil case, unfold/simp with `List.foldl_nil`
- [ ] Show `p \in acc <-> p \in acc \/ False` simplifies trivially
- [ ] Use `simp only [List.foldl_nil, List.not_mem_nil, or_false]`

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean` - nil case

**Verification**:
- Base case closes with no remaining goals

---

### Phase 3: Inductive Case Setup [COMPLETED]

**Goal**: Set up the cons case with List.foldl_cons and prepare for case splits

**Tasks**:
- [ ] Apply `List.foldl_cons` to rewrite foldl on cons
- [ ] Introduce the signed formula as `sf` and its components
- [ ] Set up rcases on `(sf.sign, sf.formula)` for all 12 cases

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean` - cons case

**Verification**:
- lean_goal shows 12 subgoals or structured match

---

### Phase 4: Complete Case Splits [COMPLETED]

**Goal**: Close all 12 cases in the inductive step

**Tasks**:
- [ ] For pos+atom case: use `Finset.mem_insert`, show equivalence with IH
- [ ] For all other 11 cases: accumulator unchanged, apply IH directly
- [ ] Use `List.mem_cons` for membership on the RHS
- [ ] Verify all cases close

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean` - all case splits

**Verification**:
- All 12 cases close
- Inductive case complete

---

### Phase 5: Verification and Build [COMPLETED]

**Goal**: Ensure proof compiles and build succeeds

**Tasks**:
- [ ] Run `lake build` to verify full compilation
- [ ] Check that `atom_true_iff_pos_in_branch` (which uses this lemma) also compiles
- [ ] Verify no remaining `sorry` in the lemma

**Timing**: 5 minutes

**Verification**:
- `lake build` succeeds with no errors
- No `sorry` in mem_extractTrueAtomSet_iff or dependent theorems

## Testing and Validation

- [ ] `lake build` completes without errors
- [ ] `lean_goal` at line 277 shows "no goals" after proof
- [ ] `atom_true_iff_pos_in_branch` theorem compiles (depends on this lemma)

## Artifacts and Outputs

- Modified: `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/BranchTaskModel.lean`
- Expected: `specs/732_complete_630_phase4_truth_lemma_proof/summaries/implementation-summary-20260129.md`

## Rollback/Contingency

If the proof approach fails:
1. Restore original sorry
2. Try alternative approach: direct induction without suffices
3. Create follow-up task if significant blockers found
