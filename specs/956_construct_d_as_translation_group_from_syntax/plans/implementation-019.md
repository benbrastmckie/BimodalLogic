# Implementation Plan: Task #956 - D Construction via Staged Construction (v019)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [IMPLEMENTING]
- **Effort**: 4-6 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-041.md (Pattern B well-founded approach)
- **Artifacts**: plans/implementation-019.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v019 uses Pattern B (well-founded recursion via Finset.strongInduction) - mathematically strongest approach

## Overview

**Current State**: Phases 0-5 COMPLETED with zero sorries. Phase 6 has 3 sorries in `CantorApplication.lean` plus partial `density_frame_condition_strict`.

**Key insight from research-041**: Pattern B (well-founded recursion) gives the STRONGEST theorem - proves termination intrinsically without `Option` return type. Uses `Finset.strongInduction` on candidate distinguishing formulas.

**Pattern B Approach**: Each iteration uses a DIFFERENT distinguishing formula from a finite candidate set. The set shrinks on each iteration (formula consumed or target changes via seriality). Well-foundedness via `Finset.lt_wf`.

## Goals & Non-Goals

**Goals**:
- Implement `density_frame_condition_strict` using Pattern B (well-founded recursion)
- Prove termination intrinsically (no `Option` return type)
- Complete Phases 7-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness with publication-quality proofs

**Non-Goals**:
- Fuel-based iteration (Pattern A - mathematically weaker)
- Direct Case A strictness proof (v017 approach - abandoned)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries. See implementation-014.md.

Files: `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`

---

### Phase 6: Well-Founded Strict Density [IN PROGRESS]

- **Dependencies:** Phase 5 (COMPLETE)
- **Goal:** Implement `density_frame_condition_strict` with intrinsic termination proof
- **Approach:** Pattern B from research-041 (well-founded recursion)

**Mathematical Foundation** (from research-041):

The candidate distinguishing formula set is:
```lean
def candidateFormulas (M M' : Set Formula) (anchor : Formula) : Finset Formula :=
  (anchor.subformulas.toFinset).filter (fun phi => G(phi) ∈ M' ∧ phi ∉ M)
```

Each iteration either:
1. Returns a strict witness (success), OR
2. Uses a formula phi from candidateFormulas and "eliminates" it for the next iteration

By `Finset.strongInduction`, iteration terminates because the candidate set shrinks.

**Phase 6a: Define Candidate Set and Measure** (1 hour)

```lean
/-- Candidate distinguishing formulas between M and M'. -/
def candidateFormulas (M M' : Set Formula) (anchor : Formula) : Finset Formula :=
  (anchor.subformulas.toFinset).filter (fun phi =>
    Formula.all_future phi ∈ M' ∧ phi ∉ M)

/-- Anchor formula containing all relevant subformulas. -/
def anchorFormula (M M' : Set Formula) (h_mcs' : SetMaximalConsistent M') : Formula :=
  -- Some formula whose subformulas contain all of GContent(M')
  -- Could use a disjunction/conjunction of formulas in M'
  sorry

/-- The measure for well-founded recursion: candidate set cardinality. -/
def iterMeasure (M M' : Set Formula) (anchor : Formula) : Nat :=
  (candidateFormulas M M' anchor).card
```

**Phase 6b: Prove Measure Decreases** (1.5 hours)

```lean
/-- When Case B1 fires and we recurse with seriality future, measure decreases. -/
lemma measure_decreases_on_seriality
    (M M' M'' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_mcs'' : SetMaximalConsistent M'')
    (h_R : CanonicalR M M')
    (h_serial : CanonicalR M' M'')  -- M'' is seriality future
    (h_strict : ¬CanonicalR M'' M')  -- strict future
    (anchor : Formula)
    (h_anchor : ∀ phi, Formula.all_future phi ∈ M' → phi ∈ anchor.subformulas)
    (h_anchor'' : ∀ phi, Formula.all_future phi ∈ M'' → phi ∈ anchor.subformulas)
    (delta : Formula)
    (h_delta_used : delta ∈ candidateFormulas M M' anchor)  -- delta was the distinguishing formula
    :
    iterMeasure M M'' anchor < iterMeasure M M' anchor ∨
    delta ∉ candidateFormulas M M'' anchor := by
  -- Either the measure decreases OR delta is no longer a candidate
  -- The key insight: M'' is a STRICT future of M', so GContent(M'') ⊂ GContent(M')
  -- (by transitivity arguments)
  sorry
```

**Phase 6c: Implement Well-Founded Strict Density** (2 hours)

```lean
/-- Strict density via well-founded recursion on candidate formula set. -/
theorem density_frame_condition_strict_wf
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : ∀ phi, Formula.all_future phi ∈ M' → phi ∈ anchor.subformulas) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Use Finset.strongInduction on (candidateFormulas M M' anchor)
  -- Base case: candidateFormulas is empty → contradiction with h_not_R'
  -- Inductive case: apply density_frame_condition, check strictness
  --   If strict: done
  --   If not strict (Case B1): apply seriality to get M'', recurse by IH
  apply Finset.strongInductionOn (candidateFormulas M M' anchor)
  intro candidates ih
  -- Get distinguishing formula
  obtain ⟨delta, h_delta⟩ := distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- Apply non-strict density
  obtain ⟨W, hW_mcs, hW_R1, hW_R2⟩ := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
  -- Check strictness
  by_cases h_back : ¬CanonicalR W M
  case pos =>
    by_cases h_fwd : ¬CanonicalR M' W
    case pos => exact ⟨W, hW_mcs, hW_R1, hW_R2, h_back, h_fwd⟩
    case neg =>
      -- W ~ M' in quotient, apply seriality to M'
      obtain ⟨M'', hM''_mcs, hM''_R, hM''_strict⟩ := mcs_has_strict_future M' h_mcs'
      -- Recurse via IH with smaller candidate set
      have h_smaller : candidateFormulas M M'' anchor ⊂ candidates := by sorry
      exact ih (candidateFormulas M M'' anchor) h_smaller ...
  case neg =>
    -- W sees back to M, i.e., W ~ M
    -- This means Case B1 fired, apply seriality
    obtain ⟨M'', hM''_mcs, hM''_R, hM''_strict⟩ := mcs_has_strict_future M' h_mcs'
    have h_smaller : candidateFormulas M M'' anchor ⊂ candidates := by sorry
    exact ih (candidateFormulas M M'' anchor) h_smaller ...
```

**Phase 6d: Wrapper Without Anchor** (0.5 hours)

```lean
/-- Main theorem: strict intermediate exists (no anchor parameter exposed). -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Construct anchor from M'
  let anchor := anchorFormula M M' h_mcs'
  exact density_frame_condition_strict_wf M M' h_mcs h_mcs' h_R h_not_R' anchor (anchorFormula_covers ...)
```

**Phase 6e: Resolve CantorApplication Sorries** (0.5 hours)

Use `density_frame_condition_strict` to resolve NoMaxOrder, NoMinOrder, DenselyOrdered sorries (same as v018 approach).

**Timing:** 5.5 hours total

**Progress:**

**Session: 2026-03-12, sess_1773337195_0a1a7c**
- Added: `irreflexive_mcs_has_strict_future` - proves non-reflexive MCS has strict seriality future via Temporal 4 closure
- Fixed: NoMaxOrder unreachable case - mutual accessibility with non-reflexive MCS is contradiction
- Improved: CantorApplication proof structure with explicit case analysis
- Sorries: 16 + 3 = 19 total (DensityFrameCondition + CantorApplication)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add well-founded theorem
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 3 sorries

**Verification**:
- `lake build` passes
- Zero sorries in CantorApplication.lean
- Zero NEW sorries in DensityFrameCondition.lean
- Theorem type is `∃ W, ...` NOT `Option (∃ W, ...)`

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks** (unchanged from v018):
- [ ] Define `D : Type := Q` with AddCommGroup instance from Mathlib
- [ ] Extract eval/eval_inv from `cantor_iso`
- [ ] Define `task_rel (d : D) (w : T) : T := eval_inv (eval w + d)`
- [ ] Prove `task_rel` is a group action
- [ ] Prove order preservation

**Timing:** 0.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromSyntax.lean`

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame and prove completeness

**Tasks** (unchanged from v018):
- [ ] Define `staged_task_frame : TaskFrame D`
- [ ] Prove temporal axiom validity
- [ ] Construct canonical evaluation
- [ ] Prove truth lemma
- [ ] Prove `staged_completeness`: valid phi -> phi provable

**Timing:** 0.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TaskFrameFromSyntax.lean`

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/` shows no new axioms
- [ ] Theorem type is TOTAL (no `Option` return)

### Mathematical Quality Checks
- [ ] `density_frame_condition_strict` has type `∃ W, ...` (not `Option`)
- [ ] Termination is intrinsic to proof structure (not fuel-based)
- [ ] Uses `Finset.strongInduction` or equivalent well-founded pattern

## Artifacts & Outputs

**Existing files (Phases 0-5)**:
- `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`
- `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`
- `CantorApplication.lean` (partial - 3 sorries)

**Files to complete (Phases 6-8)**:
- `DensityFrameCondition.lean` - add well-founded theorem
- `CantorApplication.lean` - resolve 3 sorries
- `DFromSyntax.lean` - Phase 7
- `TaskFrameFromSyntax.lean` - Phase 8

## Rollback/Contingency

**If Pattern B proves difficult**:
1. Fall back to Pattern C (fuel-based + sufficiency lemma)
2. Pattern C provides equivalent mathematical strength with potentially simpler proofs
3. Last resort: Pattern A (fuel-based) is acceptable for progress, then upgrade later

## Revision History

- **v019** (this revision): Pattern B (well-founded recursion via Finset.strongInduction) - mathematically strongest
- **v018**: Pattern A iteration approach (fuel-based) - replaced for mathematical strength
- **v017**: Direct Case A strictness proof (FAILED)
- **v016**: Strategy C iteration approach (original)
