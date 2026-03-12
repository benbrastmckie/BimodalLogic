# Implementation Plan: Task #956 - D Construction via Staged Construction (v020)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PLANNED]
- **Effort**: 3-4 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-042.md (Pattern C fuel + sufficiency - recommended)
- **Artifacts**: plans/implementation-020.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v020 uses Pattern C (fuel + sufficiency via Nat.strongRecOn) per research-042 recommendation - sidesteps Finset decidability issue

## Overview

**Current State**: Phases 0-5 COMPLETED with zero sorries. Phase 6 has 10 sorries in `DensityFrameCondition.lean` plus 3 in `CantorApplication.lean`.

**Key insight from research-042**: Pattern C (fuel + sufficiency) is more mathematically satisfying than Pattern B for this problem:
1. Sidesteps Finset decidability issue (fundamental, not a Lean quirk)
2. Compositional structure (function + sufficiency lemma) is cleaner
3. Mirrors the two-part math argument: "iteration works" + "iteration terminates"
4. Aligns with Mathlib idiom (`Part.fix`, `Computation.Terminates`) and codebase (`Saturation.lean`)

**Pattern C Approach**:
- Layer 1: Fuel-based function returning `Option (exists W, ...)`
- Layer 2: Sufficiency proof via `Nat.strongRecOn` on subformulaCount
- Layer 3: Final theorem extracts witness via `.choose_spec.some`

## Goals & Non-Goals

**Goals**:
- Implement `density_frame_condition_strict` using Pattern C (fuel + sufficiency)
- Prove fuel sufficiency via `Nat.strongRecOn` on subformula count
- Final theorem type: `exists W, ...` (no Option exposed)
- Complete Phases 7-8 to construct D = Q via Cantor isomorphism
- Achieve sorry-free TaskFrame completeness with publication-quality proofs

**Non-Goals**:
- Pattern B (Finset.strongInductionOn) - blocked by decidability issue
- Pattern A (fuel without sufficiency) - mathematically weaker
- Direct Case A strictness proof (v017 approach - abandoned)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries. See implementation-014.md.

Files: `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`, `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`

---

### Phase 6: Pattern C Strict Density [IN PROGRESS]

- **Dependencies:** Phase 5 (COMPLETE)
- **Goal:** Implement `density_frame_condition_strict` with fuel + sufficiency pattern
- **Approach:** Pattern C from research-042

**Mathematical Foundation** (from research-042):

Pattern C separates concerns:
1. **Computational layer**: Fuel-based iteration, honest about partiality via `Option`
2. **Logical layer**: Sufficiency proof via `Nat.strongRecOn` on subformula count
3. **Final theorem**: Composes layers to get total result

**Phase 6a: Define Fuel-Based Iteration Function** (1 hour)

```lean
/-- Iteration helper: try to find strict witness with bounded fuel.
    Returns `none` if fuel exhausted, `some witness` if strict intermediate found. -/
def strictDensityWithFuel (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (fuel : Nat) :
    Option (Σ' W : Set Formula, SetMaximalConsistent W ∧
           CanonicalR M W ∧ CanonicalR W M' ∧
           ¬CanonicalR W M ∧ ¬CanonicalR M' W) :=
  match fuel with
  | 0 => none
  | n + 1 =>
    -- Apply non-strict density
    let ⟨W, hW_mcs, hW_R1, hW_R2⟩ := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
    -- Classical decidability for checking strictness
    if h_back : ¬CanonicalR W M then
      if h_fwd : ¬CanonicalR M' W then
        some ⟨W, hW_mcs, hW_R1, hW_R2, h_back, h_fwd⟩
      else
        -- W ~ M' in quotient, apply seriality to escape
        let ⟨M'', hM''_mcs, hM''_R, hM''_strict⟩ := mcs_has_strict_future M' h_mcs'
        -- Recurse with M'' as new target
        strictDensityWithFuel M M'' h_mcs hM''_mcs
          (canonicalR_transitive h_R hM''_R) (not_R_from_strict_future h_not_R' hM''_strict) n
    else
      -- W sees back to M, apply seriality
      let ⟨M'', hM''_mcs, hM''_R, hM''_strict⟩ := mcs_has_strict_future M' h_mcs'
      strictDensityWithFuel M M'' h_mcs hM''_mcs
        (canonicalR_transitive h_R hM''_R) (not_R_from_strict_future h_not_R' hM''_strict) n
termination_by fuel
```

**Phase 6b: Prove Fuel Sufficiency** (1.5 hours)

```lean
/-- Key lemma: sufficient fuel exists bounded by subformula count.
    Each iteration either succeeds or consumes a distinguishing formula
    from the finite subformula closure. -/
theorem fuel_suffices (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : ∀ phi, Formula.all_future phi ∈ M' → phi ∈ anchor.subformulas) :
    ∃ fuel, (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome := by
  -- Use Nat.strongRecOn on anchor.subformulaCount
  -- Each iteration either:
  --   (a) Returns strict witness (base case)
  --   (b) Uses a distinguishing formula from subformula closure, reducing measure
  apply Nat.strongRecOn anchor.subformulaCount
  intro n ih
  -- Key insight: if iteration recurses, the new target M'' has
  -- GContent(M'') strictly contained in anchor.subformulas
  -- via the seriality escape, reducing the candidate set
  sorry -- Implementation
```

**Phase 6c: Final Theorem Composition** (0.5 hours)

```lean
/-- Main theorem: strict intermediate always exists.
    Composes fuel function with sufficiency proof. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  -- Construct anchor from M' (any formula covering GContent(M'))
  obtain ⟨anchor, h_anchor⟩ := anchor_formula_exists M' h_mcs'
  -- Get fuel sufficiency
  obtain ⟨fuel, h_fuel⟩ := fuel_suffices M M' h_mcs h_mcs' h_R h_not_R' anchor h_anchor
  -- Extract witness
  exact (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).get h_fuel
```

**Phase 6d: Resolve CantorApplication Sorries** (0.5 hours)

Use `density_frame_condition_strict` to resolve:
- `NoMaxOrder` instance sorry
- `NoMinOrder` instance sorry
- `DenselyOrdered` instance sorry

**Timing:** 3.5 hours total

**Progress:**

**Session: 2026-03-12, sess_1773337195_0a1a7c (prior)**
- Added: `irreflexive_mcs_has_strict_future` - proves non-reflexive MCS has strict seriality future
- Fixed: NoMaxOrder unreachable case - mutual accessibility with non-reflexive MCS is contradiction
- Sorries: 10 + 3 = 13 total (DensityFrameCondition + CantorApplication)

**Session: 2026-03-12, sess_1773341155_cd27e0**
- Added: Pattern C section with mathematical documentation
- Added: `density_frame_condition_strict_patternC` - clean wrapper theorem
- Added: `density_frame_condition_strict_wf` - well-founded alias
- Fixed: Transitivity proof using `canonicalR_transitive` instead of direct phi chaining
- Sorries: 10 + 3 = 13 unchanged (reflexive cluster cases still need iteration)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add Pattern C implementation
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - resolve 3 sorries

**Verification**:
- `lake build` passes
- Zero sorries in CantorApplication.lean
- Zero NEW sorries in DensityFrameCondition.lean
- Final theorem type is `∃ W, ...` (not `Option (∃ W, ...)`)

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D as (Q, +) and task_rel as actual displacement

**Tasks** (unchanged from v019):
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

**Tasks** (unchanged from v019):
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
- [ ] Final theorem type is TOTAL (`∃ W, ...` not `Option`)

### Mathematical Quality Checks
- [ ] `density_frame_condition_strict` has type `∃ W, ...`
- [ ] Fuel sufficiency proven via `Nat.strongRecOn`
- [ ] Pattern C compositional structure preserved

## Artifacts & Outputs

**Existing files (Phases 0-5)**:
- `StagedTimeline.lean`, `WitnessSeedWrapper.lean`, `SeparationLemma.lean`
- `StagedExecution.lean`, `DenseTimeline.lean`, `DensityFrameCondition.lean`
- `CantorApplication.lean` (partial - 3 sorries)

**Files to complete (Phases 6-8)**:
- `DensityFrameCondition.lean` - add Pattern C implementation
- `CantorApplication.lean` - resolve 3 sorries
- `DFromSyntax.lean` - Phase 7
- `TaskFrameFromSyntax.lean` - Phase 8

## Rollback/Contingency

**If Pattern C proves difficult**:
1. Pattern C is the pragmatic choice; issues should be solvable
2. If anchor formula construction problematic: use explicit bound instead
3. Last resort: Pattern A (fuel without sufficiency) is acceptable for progress

**If seriality escape complex**:
1. Seriality infrastructure from `mcs_has_strict_future` already exists
2. Track which formulas are "consumed" to bound iterations

## Revision History

- **v020** (this revision): Pattern C (fuel + sufficiency via Nat.strongRecOn) per research-042 - sidesteps Finset decidability
- **v019**: Pattern B (well-founded via Finset.strongInduction) - blocked by decidability
- **v018**: Pattern A iteration approach (fuel-based) - mathematically weaker
- **v017**: Direct Case A strictness proof (FAILED)
- **v016**: Strategy C iteration approach (original)
