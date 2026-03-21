# Implementation Plan: Task #575

**Task**: 575 - Implement closureWithNeg Infrastructure
**Version**: 001
**Created**: 2026-01-18
**Language**: lean
**Parent**: 574 (Restructure main_weak_completeness)

## Overview

This task implements the `closureWithNeg` infrastructure needed for negation completeness in the MCS (Maximal Consistent Set) framework. The key change is refactoring `ClosureMaximalConsistent` and related definitions to use `closureWithNeg` instead of `closure`, which enables a simpler proof of negation completeness.

### Background

Currently:
- `closure phi` = subformulas of phi
- `closureWithNeg phi` = closure phi ∪ {neg ψ | ψ ∈ closure phi} (already defined at line 458)
- `ClosureMaximalConsistent phi S` requires S ⊆ closure phi (line 495)
- `closure_mcs_negation_complete` needs BOTH `ψ ∈ closure phi` AND `neg ψ ∈ closure phi` (line 669)

After refactoring:
- `ClosureMaximalConsistent phi S` requires S ⊆ closureWithNeg phi
- `closure_mcs_negation_complete` only needs `ψ ∈ closureWithNeg phi`
- Negation completeness becomes trivially provable from MCS maximality

## Goals & Non-Goals

**Goals**:
- Refactor `ClosureConsistent` and `ClosureMaximalConsistent` to use `closureWithNeg`
- Simplify `closure_mcs_negation_complete` proof
- Update `worldStateFromClosureMCS` to work with new definitions
- Ensure all existing theorems still compile

**Non-Goals**:
- Complete the compound formula proofs (task 577)
- Eliminate all sorries in the file
- Change the closure or closureWithNeg definitions themselves

## Phases

### Phase 1: Update ClosureConsistent and ClosureMaximalConsistent [NOT STARTED]

**Objectives**:
1. Modify `ClosureConsistent` to use `closureWithNeg` instead of `closure`
2. Modify `ClosureMaximalConsistent` to use `closureWithNeg` instead of `closure`
3. Update related helper theorems

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` (lines 484-497)

**Steps**:
1. Change `ClosureConsistent` definition (line 484):
   ```lean
   def ClosureConsistent (phi : Formula) (S : Set Formula) : Prop :=
     S ⊆ (closureWithNeg phi : Set Formula) ∧ SetConsistent S
   ```
2. Change `ClosureMaximalConsistent` definition (line 495):
   ```lean
   def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop :=
     ClosureConsistent phi S ∧
     ∀ ψ : Formula, ψ ∈ closureWithNeg phi → ψ ∉ S → ¬SetConsistent (insert ψ S)
   ```
3. Update `closure_consistent_subset` theorem (line 502)
4. Update `closure_mcs_maximal` theorem (line 530)

**Verification**:
- Run `lean_diagnostic_messages` after each edit
- Ensure no new errors introduced

---

### Phase 2: Update closure_lindenbaum_via_projection [NOT STARTED]

**Objectives**:
1. Update the Lindenbaum lemma to produce sets maximal in `closureWithNeg`
2. Fix the sorry at line 658 by using negation availability in closureWithNeg

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` (lines 610-658)

**Steps**:
1. Update theorem statement to project to closureWithNeg
2. Modify proof to use `closureWithNeg_neg_mem` for negation availability
3. Prove the previously-sorry case using negation completeness of closureWithNeg

**Verification**:
- The sorry at line 658 should be eliminated
- Run `lake build` to verify

---

### Phase 3: Simplify closure_mcs_negation_complete [NOT STARTED]

**Objectives**:
1. Simplify the theorem to only require `ψ ∈ closureWithNeg phi`
2. Remove the now-redundant `h_neg : Formula.neg ψ ∈ closure phi` hypothesis

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` (lines 669-795)

**Steps**:
1. Update theorem signature to use closureWithNeg:
   ```lean
   theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
       (h_mcs : ClosureMaximalConsistent phi S) (ψ : Formula)
       (h_psi : ψ ∈ closureWithNeg phi) :
       ψ ∈ S ∨ (Formula.neg ψ) ∈ S
   ```
2. Simplify proof using that neg ψ ∈ closureWithNeg phi is automatic
3. The proof becomes: by maximality, either ψ ∈ S or insert ψ S inconsistent; if insert ψ S inconsistent, then neg ψ ∈ S by similar argument with closureWithNeg guaranteeing neg neg ψ = ψ.imp bot is available

**Verification**:
- Theorem compiles without sorry
- All callers still work

---

### Phase 4: Update worldStateFromClosureMCS and dependencies [NOT STARTED]

**Objectives**:
1. Update `assignmentFromClosureMCS` if needed
2. Update `worldStateFromClosureMCS` and related theorems
3. Ensure `IsMCSDerived` and related predicates still work

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` (lines 1240-1400)

**Steps**:
1. Review `assignmentFromClosureMCS` - may not need changes if it already works on closure
2. Update `worldStateFromClosureMCS_models_iff` theorem (line 1264) - needs `h_mem : psi ∈ closure phi` not `closureWithNeg`
3. Verify `mcs_imp_iff_material` still works (line 1347)

**Key insight**: The `FiniteWorldState` still uses `closure phi` for the domain, only the MCS definition uses `closureWithNeg`. The assignment function maps from `closure phi` formulas, so we need:
- MCS S ⊆ closureWithNeg phi (for negation completeness)
- S ∩ closure phi determines the assignment (for world state)

**Verification**:
- All dependent theorems compile
- `lake build` succeeds

---

### Phase 5: Testing and Cleanup [NOT STARTED]

**Objectives**:
1. Run `lake build` on full project
2. Verify no new errors
3. Check that dependent tasks (576, 577) can proceed

**Files to check**:
- All files importing FiniteCanonicalModel.lean

**Verification**:
- `lake build` succeeds with no new errors
- `lean_diagnostic_messages` shows no regressions
- Phase markers updated in parent task 574's plan

## Dependencies

- None (this is the first subtask of 574)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing proofs that use ClosureMaximalConsistent | High | Carefully update each theorem, run diagnostics after each edit |
| worldStateFromClosureMCS incompatible with new defs | Medium | The world state still uses closure phi for domain; only S uses closureWithNeg |
| closure_lindenbaum still needs sorry | Medium | Focus on eliminating line 658 sorry via negation availability |

## Success Criteria

- [ ] `ClosureConsistent` and `ClosureMaximalConsistent` use closureWithNeg
- [ ] `closure_mcs_negation_complete` has simpler signature
- [ ] Line 658 sorry eliminated (or documented why unavoidable)
- [ ] `lake build` succeeds with no new errors
- [ ] Task 576 can use the new infrastructure
