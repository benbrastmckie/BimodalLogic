# Implementation Plan: Task #956 - D Construction via Staged Construction (v023)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PLANNED]
- **Effort**: 4-5 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-045.md (well-founded termination measure)
- **Artifacts**: plans/implementation-023.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v023 incorporates specific termination measure from research-045

## Overview

**Current State**: Phases 0-5 COMPLETED. Phase 6 has 13 sorries (10 in DensityFrameCondition, 3 in CantorApplication).

**Key Progress Since v022**:
- Added `non_reflexive_target_has_strict_intermediate` with iteration pattern
- Added M-reflexivity case splits (lines 860/865, 921/923)
- Proved: when M NOT reflexive, witnesses don't see M back (via T4)
- All remaining sorries are in M-reflexive cases

**The Termination Solution** (from research-045):
- **Measure**: `subformulaClosure(anchor).card` bounds iteration depth
- **Tool**: `Nat.strongRecOn` from `Init.WF`
- **Infrastructure**: `subformulaClosure`, `subformulaCount` already exist in codebase
- **Key insight**: Each iteration either succeeds OR "consumes" a distinguishing formula from the finite subformula closure

## Goals & Non-Goals

**Goals**:
- Implement 3-layer Pattern C: iteration function + sufficiency proof + composition
- Use `Nat.strongRecOn` with `subformulaClosure(anchor).card` as measure
- Single `density_frame_condition_strict` theorem resolves all 13 sorries
- Complete Phases 7-8 for D = Q construction

**Non-Goals**:
- Direct formula contradiction (W~M is mathematically consistent)
- Impossibility proofs (cannot derive False from W~M)
- Further case splitting (all cases already structured)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries.

---

### Phase 6: Pattern C Strict Density [IN PROGRESS]

**Goal**: All 13 sorries resolved via unified iteration theorem

**Current Sorry Distribution**:

| File | Count | Lines | Pattern |
|------|-------|-------|---------|
| DensityFrameCondition.lean (Case B1) | 9 | 486, 490, 492, 585, 589, 591, 641, 646, 653 | W ~ M' |
| DensityFrameCondition.lean (Case A) | 2 | 865, 923 | V ~ M (M reflexive) |
| DensityFrameCondition.lean (non_refl_target) | 2 | 1668, 1753 | W ~ M (M reflexive) |
| CantorApplication.lean | 3 | 210, 269, 316 | Uses density_frame_condition_strict |

**All sorries resolve with single theorem**:
```lean
theorem density_frame_condition_strict (M M' : Set Formula) ... :
    exists W, SetMaximalConsistent W and CanonicalR M W and CanonicalR W M' and
              neg CanonicalR W M and neg CanonicalR M' W
```

---

#### Phase 6a: Define Iteration Function [NOT STARTED]

**Estimated time**: 30 minutes

**Purpose**: Fuel-based iteration that returns Option of strict witness

```lean
/-- Iteration with fuel: applies density, checks strictness, escapes if needed. -/
noncomputable def strictDensityIter (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : neg CanonicalR M' M)
    (fuel : Nat) : Option (StrictDensityWitness M M') :=
  match fuel with
  | 0 => none
  | n + 1 =>
    -- Get non-strict witness from density_frame_condition
    let W := (density_frame_condition M M' h_mcs h_mcs' h_R h_not_R').choose
    -- Check strictness using Classical.dec
    if h_back : neg CanonicalR W M then
      if h_fwd : neg CanonicalR M' W then
        -- STRICT! Return witness
        some (StrictDensityWitness.mk W ...)
      else
        -- W ~ M' (forward collapse), escape and retry
        none -- placeholder for escape logic
    else
      -- W ~ M (backward collapse), escape and retry
      none -- placeholder for escape logic
termination_by fuel
```

**Verification**: Function compiles, type-checks with `lake build`

---

#### Phase 6b: Prove Sufficiency via Nat.strongRecOn [NOT STARTED]

**Estimated time**: 2-3 hours (critical phase)

**Purpose**: Prove that sufficient fuel always exists

**Key insight from research-045**: Each iteration "consumes" a distinguishing formula from `subformulaClosure(anchor)`. Since this set is finite, iteration terminates.

```lean
/-- The termination measure: subformula closure cardinality. -/
def iterFuel (anchor : Formula) : Nat := (subformulaClosure anchor).card + 1

/-- Sufficient fuel exists for strict density iteration. -/
theorem fuel_suffices (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : neg CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : forall phi, G(phi) IN M' -> phi IN subformulaClosure anchor) :
    exists fuel, (strictDensityIter M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome := by
  -- Strong induction on subformulaClosure(anchor).card
  apply Nat.strongRecOn (subformulaClosure anchor).card
  intro n ih
  -- Case 1: If checkStrictness succeeds with fuel=1, done
  -- Case 2: If fails, escape uses a formula from subformulaClosure
  --         New target has smaller formula set (ih applies)
  sorry
```

**Sub-lemmas needed**:

1. **Strictness trichotomy**: Either W is strict, or W ~ M, or W ~ M'
2. **Escape decreases measure**: When W ~ M, escape to M'' has smaller `subformulaClosure.card`
3. **Anchor coverage**: Distinguishing formulas are bounded by anchor's subformulas

**Verification**: `fuel_suffices` compiles and type-checks

---

#### Phase 6c: Compose Final Theorem [NOT STARTED]

**Estimated time**: 30 minutes

```lean
/-- Main theorem: strict intermediate always exists.
    This resolves all 13 remaining sorries. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : neg CanonicalR M' M) :
    exists W : Set Formula, SetMaximalConsistent W and
      CanonicalR M W and CanonicalR W M' and
      neg CanonicalR W M and neg CanonicalR M' W := by
  -- Get anchor formula from distinguishing_formula_exists
  obtain (delta, h_G_delta_M', h_delta_not_M) := distinguishing_formula_exists ...
  -- Prove anchor coverage
  have h_anchor : forall phi, G(phi) IN M' -> phi IN subformulaClosure delta := ...
  -- Get sufficient fuel
  obtain (fuel, h_some) := fuel_suffices M M' h_mcs h_mcs' h_R h_not_R' delta h_anchor
  -- Extract witness
  exact (strictDensityIter M M' h_mcs h_mcs' h_R h_not_R' fuel).get h_some
```

**Verification**: `density_frame_condition_strict` has correct type signature

---

#### Phase 6d: Wire Up Existing Sorries [NOT STARTED]

**Estimated time**: 30 minutes

Replace all 13 sorries with calls to `density_frame_condition_strict`:

**DensityFrameCondition.lean** (10 sorries):
```lean
-- At each sorry location, replace with:
exact density_frame_condition_strict M M' h_mcs h_mcs' h_R h_not_R'
```

**CantorApplication.lean** (3 sorries):
```lean
-- Lines 210, 269, 316: Replace sorry with density_frame_condition_strict
-- The strict theorem provides the witnesses needed for NoMaxOrder, NoMinOrder, DenselyOrdered
```

**Verification**: `lake build` passes with zero sorries in both files

---

**Phase 6 Timing Summary**:
| Sub-phase | Estimated | Task |
|-----------|-----------|------|
| 6a | 30 min | Define `strictDensityIter` function |
| 6b | 2-3 hrs | Prove `fuel_suffices` via Nat.strongRecOn |
| 6c | 30 min | Compose `density_frame_condition_strict` |
| 6d | 30 min | Wire up 13 sorries |
| **Total** | **4-5 hrs** | |

---

### Phase 7: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Define D = Q with Cantor isomorphism

**Tasks**:
- [ ] `D : Type := Q` with `AddCommGroup` from Mathlib
- [ ] Extract `eval`/`eval_inv` from `cantor_iso`
- [ ] Define `task_rel d w := eval_inv (eval w + d)`
- [ ] Prove group action properties

**Timing:** 0.5 hours

---

### Phase 8: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Construct TaskFrame and completeness

**Tasks**:
- [ ] `staged_task_frame : TaskFrame D`
- [ ] Temporal axiom validity
- [ ] Truth lemma
- [ ] `staged_completeness : valid phi -> provable phi`

**Timing:** 0.5 hours

---

## Testing & Validation

- [ ] `lake build` passes
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` empty
- [ ] `grep -n "^axiom " Theories/.../StagedConstruction/` shows no new axioms
- [ ] `density_frame_condition_strict` has type `exists W, ...`

## Key Infrastructure

### Existing (from codebase)

| Item | Location | Purpose |
|------|----------|---------|
| `subformulaClosure` | SubformulaClosure.lean | Finset of subformulas |
| `subformulaClosureCard` | SubformulaClosure.lean | Termination measure |
| `Nat.strongRecOn` | Init.WF (Mathlib) | Strong induction on Nat |
| `density_frame_condition` | DensityFrameCondition.lean | Non-strict intermediate |
| `mcs_has_strict_future` | SeparationLemma.lean | Seriality witness |
| `irreflexive_mcs_has_strict_future` | DensityFrameCondition.lean | Strict future for non-reflexive M |

### To Implement

| Item | Purpose |
|------|---------|
| `strictDensityIter` | Fuel-based iteration function |
| `fuel_suffices` | Sufficiency proof via Nat.strongRecOn |
| `density_frame_condition_strict` | Final composition |

## Summary of Changes from v022

| Aspect | v022 | v023 |
|--------|------|------|
| **Sorry count** | 14 | 13 (updated after implementation) |
| **Termination measure** | "subformula count" (vague) | `subformulaClosure(anchor).card` (specific) |
| **Mathlib tool** | Pattern C mentioned | `Nat.strongRecOn` from Init.WF confirmed |
| **Infrastructure** | "needs implementation" | Confirmed `subformulaClosure` exists |
| **Phase 6 structure** | 5 sub-phases | 4 sub-phases (streamlined) |
| **Research basis** | research-044 | research-045 (termination analysis) |

## Revision History

- **v023** (this revision): Specific termination measure from research-045
- **v022**: Proof restructuring progress, streamlined Pattern C
- **v021**: Explicit seriality escape per research-043
- **v020**: Pattern C structure introduced
