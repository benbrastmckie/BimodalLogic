# Implementation Plan: Task #956 - D Construction via Staged Construction (v023)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL]
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

#### Phase 6a: Define Iteration Function [PARTIAL]

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

#### Phase 6b: Prove Sufficiency via Nat.strongRecOn [IN PROGRESS]

**Estimated time**: 2-3 hours (critical phase)

**Purpose**: Prove that sufficient fuel always exists

**Key insight from research-045**: Each iteration "consumes" a distinguishing formula from `subformulaClosure(anchor)`. Since this set is finite, iteration terminates.

**Progress:**

**Session: 2026-03-12, sess_1773379347_ca5p87 (Iteration 5)**
- Added: `strict_density_M_reflexive` theorem with full case analysis
- Expanded: Case neg-pos (line 2095) - extract psi from h_WM, apply Case A, verify
- Expanded: Case pos-neg (line 2165) - extract psi from h_M'W, apply Case A, verify
- Pattern verified: Each expansion either returns strict witness OR has U~M iteration case
- Sorries: 23 in DensityFrameCondition (up from 17 due to exposed iteration structure)
- Key insight: Termination via finite formula consumption - each psi_n distinct from psi_{n-1}
- Handoff: Updated phase-6-handoff-20260312-iter5.md with termination argument

**Session: 2026-03-12, sess_1773376107_8hwl1r (Iteration 4)**
- Proved: Line 865 sorry (Case A, V ~ M, M reflexive) partially resolved
- Added: Iteration pattern extraction from h_M'_V distinguishing formula
- Added: Case A construction with new distinguishing formula psi
- Added: Case splits for strictness and equivalence
- Sorries: 17 (+1: eliminated 865 but added 894, 921 for iteration cases)
- Key insight: Each iteration uses formula from subformulaClosure, guarantees termination

**Session: 2026-03-12, sess_1773362894_63cc2c76 (Iteration 3)**
- Attempted: Direct proof approach for M-reflexive case using V ~ M equivalence
- Proved: `h_V_refl : CanonicalR V V` derived from M reflexive and V ~ M
- Blocked: Cannot derive `phi in M implies phi in V` without `phi -> G(phi)` axiom (not valid in temporal logic)
- Reverted: Recursive approach causes termination checker failure
- Sorries: 16 (unchanged - 13 in DensityFrameCondition, 3 in CantorApplication)

**Blocking Analysis (2026-03-12)**:

The 13 sorries share a common pattern: constructed witness W is equivalent to an endpoint (M or M') in the CanonicalR preorder. The mathematical structure is:

1. **When W ~ M' (9 sorries)**: W and M' are mutually accessible (reflexive cluster). Finding strict intermediate requires escaping this cluster.

2. **When V ~ M (4 sorries)**: V is equivalent to M (M is reflexive in these cases). The witness needs to be strictly above M.

**Key Dichotomy**:
- If GContent(M') ⊈ GContent(M): There exists a "Case A" formula psi with G(psi) ∈ M' and G(psi) ∉ M. Such psi can be used to construct a strict intermediate directly.
- If GContent(M') ⊆ GContent(M): ALL forward witnesses from M are seen by M'. Iteration is required to escape the absorbing cluster.

**Required Implementation**:
The fuel-based iteration must track:
1. Current target (M' or equivalent W)
2. Formula consumed from subformulaClosure(anchor)
3. Termination via Nat.strongRecOn on closure cardinality

The escape mechanism uses seriality from the absorbing cluster to find a new target M'' where the problem is "smaller" (fewer candidate distinguishing formulas in subformulaClosure).

**Recommendation**: This requires well-founded recursion infrastructure that is complex to implement directly. Consider:
1. Alternative: Axiomatize the strict density property and defer proof
2. Alternative: Implement as a standalone module with explicit termination proof

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
