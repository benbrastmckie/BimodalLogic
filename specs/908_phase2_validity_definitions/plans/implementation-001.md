# Implementation Plan: Task #908

- **Task**: 908 - Phase 2 Validity Definitions Update
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: Task 907 (COMPLETED)
- **Research Inputs**: specs/908_phase2_validity_definitions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Update Validity.lean definitions and theorems to use the new `truth_at` signature with Omega parameter. All changes are mechanical: insert `Set.univ` for validity/consequence definitions, add existential Omega for satisfiability definitions, and update theorem proofs accordingly. This is Phase 2 of the parent task 906 (Box Admissible Histories Omega Closure).

### Research Integration

Research report (research-001.md) identified:
- 4 definitions need updates: `valid`, `semantic_consequence`, `satisfiable`, `formula_satisfiable`
- `satisfiable_abs` needs NO code change (inherits from `satisfiable`)
- 6 theorems need mechanical updates to their `truth_at` calls
- All changes follow simple patterns: add `Set.univ` or existential `Omega`

## Goals & Non-Goals

**Goals**:
- Update all Validity.lean definitions to use new truth_at signature
- Update all theorems in Validity namespace to compile
- Ensure `lake build Bimodal.Semantics.Validity` succeeds

**Non-Goals**:
- Fix downstream files (Soundness.lean, Representation.lean) - handled in Tasks 909-911
- Update Boneyard files - intentionally left broken
- Add new functionality beyond signature updates

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Set.univ` not in scope | High | Low | Import via Mathlib.Data.Set.Basic if needed (likely transitively available) |
| Satisfiable existential witness syntax | Low | Medium | Use explicit `Exists.intro` if anonymous constructor fails |
| Proof breakage in unsatisfiable_implies_all* | Low | Medium | Use `Set.mem_univ` for membership proofs |

## Sorry Characterization

### Pre-existing Sorries
- None in Validity.lean

### Expected Resolution
- N/A

### New Sorries
- None expected. All changes are mechanical signature updates.

### Remaining Debt
- No sorry debt from this task

## Implementation Phases

### Phase 1: Update Definitions [COMPLETED]

- **Dependencies:** None
- **Goal:** Update all 4 definition signatures to use Omega parameter

**Tasks**:
- [ ] Update `valid` (line 64): change `truth_at M tau t phi` to `truth_at M Set.univ tau t phi`
- [ ] Update `semantic_consequence` (lines 86-87): add `Set.univ` to all truth_at calls
- [ ] Update `satisfiable` (lines 103-105): add existential Omega and tau membership constraint
- [ ] Update `formula_satisfiable` (lines 126-129): add existential Omega and tau membership constraint
- [ ] Verify `satisfiable_abs` compiles without changes (inherits from satisfiable)

**Exact Changes**:

`valid` (line 64):
```lean
-- Before:
    truth_at M tau t phi
-- After:
    truth_at M Set.univ tau t phi
```

`semantic_consequence` (lines 86-87):
```lean
-- Before:
    (forall psi in Gamma, truth_at M tau t psi) ->
    truth_at M tau t phi
-- After:
    (forall psi in Gamma, truth_at M Set.univ tau t psi) ->
    truth_at M Set.univ tau t phi
```

`satisfiable` (lines 103-105):
```lean
-- Before:
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    forall phi in Gamma, truth_at M tau t phi
-- After:
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    forall phi in Gamma, truth_at M Omega tau t phi
```

`formula_satisfiable` (lines 126-129):
```lean
-- Before:
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    truth_at M tau t phi
-- After:
def formula_satisfiable (phi : Formula) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

**Timing**: 15 minutes

**Verification**:
- Definitions compile without error (theorems may still fail at this stage)

---

### Phase 2: Update Validity Theorems [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Update all 6 theorems in Validity namespace to compile

**Tasks**:
- [ ] Update `valid_iff_empty_consequence` (lines 136-142) - should work as-is since Set.univ is in definitions
- [ ] Update `consequence_monotone` (lines 147-152) - should work as-is
- [ ] Update `valid_consequence` (lines 157-159) - should work as-is
- [ ] Update `consequence_of_member` (lines 164-167) - should work as-is
- [ ] Update `unsatisfiable_implies_all` (lines 177-180) - add Set.univ and Set.mem_univ to witness
- [ ] Update `unsatisfiable_implies_all_fixed` (lines 186-193) - add Set.univ, Set.mem_univ, and update signature

**Exact Changes**:

`unsatisfiable_implies_all` (lines 179-180):
```lean
-- Before:
  fun h_unsat D _ _ _ F M tau t h_all =>
    absurd (exists F, M, tau, t, h_all) (h_unsat D)
-- After:
  fun h_unsat D _ _ _ F M tau t h_all =>
    absurd (exists F, M, Set.univ, tau, Set.mem_univ tau, t, h_all) (h_unsat D)
```

`unsatisfiable_implies_all_fixed` (lines 186-193):
```lean
-- Before (signature at lines 188-189):
    not satisfiable D Gamma -> forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F)
      (t : D), (forall psi in Gamma, truth_at M tau t psi) -> truth_at M tau t phi
-- After:
    not satisfiable D Gamma -> forall (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F)
      (t : D), (forall psi in Gamma, truth_at M Set.univ tau t psi) -> truth_at M Set.univ tau t phi

-- Before (proof at lines 190-193):
  intro h_unsat F M tau t h_all
  exfalso
  apply h_unsat
  exact (exists F, M, tau, t, h_all)
-- After:
  intro h_unsat F M tau t h_all
  exfalso
  apply h_unsat
  exact (exists F, M, Set.univ, tau, Set.mem_univ tau, t, h_all)
```

**Timing**: 20 minutes

**Verification**:
- `lake build Bimodal.Semantics.Validity` succeeds

---

### Phase 3: Build Verification and Cleanup [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Verify build and update docstrings

**Tasks**:
- [ ] Run `lake build Bimodal.Semantics.Validity` and confirm success
- [ ] Update module docstring to mention Omega parameter usage
- [ ] Update `valid` definition docstring to note Set.univ usage
- [ ] Update `satisfiable` definition docstring to note existential Omega

**Timing**: 10 minutes

**Verification**:
- Clean build with no errors
- Docstrings accurately describe new semantics

**Progress:**

**Session: 2026-02-19, sess_1771540603_60919c**
- Phase 1: Added `Set.univ` to `valid` and `semantic_consequence` definitions
- Phase 1: Added existential `Omega` with `tau in Omega` to `satisfiable` and `formula_satisfiable`
- Phase 2: Updated `unsatisfiable_implies_all` proof with `Set.univ` and `Set.mem_univ` witness
- Phase 2: Updated `unsatisfiable_implies_all_fixed` signature and proof with `Set.univ`
- Phase 2: Verified 4 other theorems compiled without changes (Set.univ embedded in definitions)
- Phase 3: Updated module, `valid`, and `satisfiable` docstrings
- Phase 3: Build verified: `lake build Bimodal.Semantics.Validity` succeeds (671 jobs)
- Sorries: 0 -> 0 (none introduced)

## Testing & Validation

- [ ] `lake build Bimodal.Semantics.Validity` succeeds with no errors
- [ ] No new sorries or axioms introduced
- [ ] All 6 theorems in Validity namespace compile

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Semantics/Validity.lean`
- Plan: `specs/908_phase2_validity_definitions/plans/implementation-001.md` (this file)
- Summary: `specs/908_phase2_validity_definitions/summaries/implementation-summary-20260219.md` (on completion)

## Rollback/Contingency

If implementation fails:
1. Revert Validity.lean changes via `git checkout Theories/Bimodal/Semantics/Validity.lean`
2. Task 908 remains [PLANNED], parent task 906 blocked at Phase 2
3. Investigate failure cause and create revised plan if needed
