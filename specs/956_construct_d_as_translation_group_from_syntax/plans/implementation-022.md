# Implementation Plan: Task #956 - D Construction via Staged Construction (v022)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PLANNED]
- **Effort**: 4-5 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-044.md (streamlined approach analysis)
- **Artifacts**: plans/implementation-022.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v022 reflects proof restructuring progress and streamlined Pattern C approach per research-044

## Overview

**Current State**: Phases 0-5 COMPLETED. Phase 6 has 14 sorries (11 in DensityFrameCondition, 3 in CantorApplication).

**Key Progress Since v021**:
- All "impossible" sorries (goal `False` from consistent contexts) have been ELIMINATED
- All remaining sorries have iteration-ready goal: `exists W, strict witness`
- Proof restructuring from `exfalso` to `by_cases` pattern is COMPLETE
- Infrastructure added: `caseB_M_not_reflexive`, `irreflexive_mcs_has_strict_future` (early), `checkStrictness`, `strictDensityAttempt`

**The Mathematical Obstruction** (from research-044):
- All sorries stem from **reflexive cluster escape** - when M' is reflexive, constructed witnesses may be equivalent to M' in the quotient
- M-side strictness is SOLVED via `caseB_M_not_reflexive` + `irreflexive_mcs_has_strict_future`
- M'-side strictness requires iteration: when M' absorbs all distinguishing formulas

**The Solution**: Pattern C with fuel-based iteration
1. Check if witness is strict via `checkStrictness`
2. If not strict, escape via seriality to new target M''
3. Recurse with density(M, M'')
4. Terminate via `Nat.strongRecOn` on subformula count

## Goals & Non-Goals

**Goals**:
- Implement `fuel_suffices` theorem to close all 14 remaining sorries
- Single theorem resolves all sorries (they share identical goal structure)
- Zero sorries in Phase 6 files
- Complete Phases 7-8 for D = Q construction

**Non-Goals**:
- Direct formula-based proofs (exhausted - no contradiction in reflexive cases)
- Pattern B (Finset.strongInductionOn) - blocked by decidability
- Further case splitting (all cases already have `by_cases` structure)

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries.

---

### Phase 6: Pattern C Strict Density [IN PROGRESS]

**Goal**: All 14 sorries resolved via Pattern C iteration

**Current Sorry Distribution** (from research-044):

| File | Count | Locations | Structure |
|------|-------|-----------|-----------|
| DensityFrameCondition.lean | 11 | 459, 463, 465, 542, 546, 548, 583, 588, 595, 791, 818 | `exists W, strict witness` |
| CantorApplication.lean | 3 | 210, 269, 316 | Uses density_frame_condition_strict |

**All sorries have identical goal**:
```lean
exists W : Set Formula, SetMaximalConsistent W and
  CanonicalR M W and CanonicalR W M' and
  neg CanonicalR W M and neg CanonicalR M' W
```

---

#### Phase 6a: Seriality Escape Helper [NOT STARTED]

**Estimated time**: 30 minutes

**Purpose**: Helper that escapes reflexive clusters via mcs_has_strict_future

```lean
/-- When M' is reflexive, we can find M'' strictly above M' via seriality.
    This helper provides the escape from a reflexive equivalence class. -/
theorem reflexive_seriality_escape (M' : Set Formula)
    (h_mcs' : SetMaximalConsistent M')
    (h_refl : CanonicalR M' M') :
    exists M'' : Set Formula, SetMaximalConsistent M'' and
      CanonicalR M' M'' and neg CanonicalR M'' M' := by
  -- Use mcs_has_strict_future (already in SeparationLemma.lean)
  -- Key: show the seriality witness is NOT equivalent to M'
  -- Strategy: The seriality witness from F(top) in M' lands at M''
  --   with top in M''. If M'' sees M', then G(top) in M'',
  --   so top in GContent(M''), so top in M' (by CanonicalR M'' M'),
  --   but top already in M' - no contradiction directly.
  --   Need: find a formula phi in M'' that distinguishes from M'
  sorry
```

**Alternative approach** (simpler):
```lean
-- Use that seriality gives fresh witness each time
-- Eventually one must escape the equivalence class
-- Or: use the distinguishing formula from the original M/M' pair
```

**Verification**: `lake build` passes, helper compiles

---

#### Phase 6b: Fuel-Based Iteration Function [NOT STARTED]

**Estimated time**: 1 hour

**Purpose**: Fuel-based iteration that checks strictness and recurses if not strict

```lean
/-- Iteration with fuel: applies density, escapes via seriality if not strict. -/
noncomputable def strictDensityWithFuel (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : neg CanonicalR M' M)
    (fuel : Nat) :
    Option (Sigma' (W : Set Formula), SetMaximalConsistent W and
           CanonicalR M W and CanonicalR W M' and
           neg CanonicalR W M and neg CanonicalR M' W) :=
  match fuel with
  | 0 => none
  | n + 1 =>
    -- Get non-strict witness from density_frame_condition
    let dpair := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
    let W := dpair.choose
    let hW := dpair.choose_spec
    -- Check strictness
    if h_strict : checkStrictness W M M' then
      -- STRICT! Done.
      some (Sigma'.mk W hW.with_strictness h_strict)
    else
      -- Not strict, escape via seriality
      if h_refl : CanonicalR M' M' then
        let escape := reflexive_seriality_escape M' h_mcs' h_refl
        let M'' := escape.choose
        -- Recurse with new target
        strictDensityWithFuel M M'' h_mcs escape.choose_spec.1
          (canonicalR_transitive M M' M'' h_mcs h_R escape.choose_spec.2.1)
          (escape_preserves_not_R h_not_R' escape.choose_spec.2.2)
          n
      else
        -- M' not reflexive but witness not strict - contradiction
        -- (This case is actually impossible given our hypotheses)
        none
termination_by fuel
```

**Verification**: Function compiles, type-checks with `lake build`

---

#### Phase 6c: Fuel Sufficiency Proof [NOT STARTED]

**Estimated time**: 2 hours

**Purpose**: Prove iteration terminates via Nat.strongRecOn on subformula count

```lean
/-- Sufficient fuel exists, bounded by universe size.
    Each iteration "escapes" to a strictly larger target M''.
    Eventually we find a strict witness or escape the finite universe. -/
theorem fuel_suffices (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : neg CanonicalR M' M) :
    exists fuel, (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome := by
  -- Use Nat.strongRecOn on a measure of "remaining escape room"
  -- Key insight: each iteration either:
  --   (a) Finds strict witness (done)
  --   (b) Escapes to M'' with CanonicalR M' M'' and neg CanonicalR M'' M'
  -- The chain M < M' < M'' < ... must terminate (finite universe or omega-chain argument)
  -- Measure: subformula count of distinguishing anchor formula
  sorry
```

**Alternative termination argument** (from research-044):
- Each escape uses a different distinguishing formula
- Distinguishing formulas come from finite subformula closure
- Therefore: max iterations = |subformulas(anchor)|

**Verification**: `fuel_suffices` compiles and type-checks

---

#### Phase 6d: Final Composition [NOT STARTED]

**Estimated time**: 30 minutes

```lean
/-- Main theorem: strict intermediate always exists.
    This replaces all 14 remaining sorries. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : neg CanonicalR M' M) :
    exists W : Set Formula, SetMaximalConsistent W and
      CanonicalR M W and CanonicalR W M' and
      neg CanonicalR W M and neg CanonicalR M' W := by
  obtain (fuel, h_fuel) := fuel_suffices M M' h_mcs h_mcs' h_R h_not_R'
  let result := strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel
  exact (result.get h_fuel).snd
```

**Verification**: `density_frame_condition_strict` has correct type

---

#### Phase 6e: Wire Up Existing Sorries [NOT STARTED]

**Estimated time**: 30 minutes

Replace all 14 sorries with calls to `density_frame_condition_strict`:

**DensityFrameCondition.lean** (11 sorries):
```lean
-- At each sorry location (459, 463, 465, 542, 546, 548, 583, 588, 595, 791, 818):
-- Replace `sorry` with:
exact density_frame_condition_strict M M' h_mcs h_mcs' h_R h_not_R'
```

**CantorApplication.lean** (3 sorries):
```lean
-- Lines 210, 269, 316: Replace sorry with density_frame_condition_strict call
-- These use the strict theorem in NoMaxOrder, NoMinOrder, DenselyOrdered proofs
```

**Verification**: `lake build` passes with zero sorries in both files

---

**Phase 6 Timing Summary**:
| Sub-phase | Estimated | Task |
|-----------|-----------|------|
| 6a | 30 min | seriality_escape helper |
| 6b | 1 hr | strictDensityWithFuel function |
| 6c | 2 hrs | fuel_suffices theorem |
| 6d | 30 min | density_frame_condition_strict composition |
| 6e | 30 min | Wire up 14 sorries |
| **Total** | **4.5 hrs** | |

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

## Key Lemma Dependencies

| Lemma | Location | Purpose |
|-------|----------|---------|
| `mcs_has_strict_future` | SeparationLemma.lean:213 | Seriality witness |
| `irreflexive_mcs_has_strict_future` | DensityFrameCondition.lean:249 | Strict future for non-reflexive M |
| `caseB_M_not_reflexive` | DensityFrameCondition.lean:72 | M not reflexive in Case B |
| `checkStrictness` | DensityFrameCondition.lean | Decidable strictness check |
| `Nat.strongRecOn` | Init/WF.lean | Strong induction for termination |

## Summary of Changes from v021

| Aspect | v021 | v022 |
|--------|------|------|
| **Sorry count** | 13 (original) | 14 (after restructuring revealed sub-cases) |
| **Impossible sorries** | 2 | 0 (all eliminated via by_cases restructure) |
| **Goal structure** | Mixed (some False, some exists) | Uniform (all exists strict witness) |
| **Proof restructure** | Needed | COMPLETE |
| **Phase 6 sub-phases** | 5 (6a-6e) | 5 (revised based on research-044) |
| **Research basis** | research-043 | research-044 (implementation analysis) |

## Revision History

- **v022** (this revision): Reflects proof restructuring progress, streamlined Pattern C per research-044
- **v021**: Streamlined with explicit seriality escape per research-043
- **v020**: Pattern C structure introduced
- **v019**: Pattern B (blocked by decidability)
- **v018-v016**: Earlier iterations
