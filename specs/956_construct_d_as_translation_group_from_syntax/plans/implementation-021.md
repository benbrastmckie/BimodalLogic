# Implementation Plan: Task #956 - D Construction via Staged Construction (v021)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PARTIAL]
- **Effort**: 4-5 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 959 (COMPLETE)
- **Research Inputs**: research-043.md (mathematical ideal path - Pattern C confirmed)
- **Artifacts**: plans/implementation-021.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v021 streamlines Pattern C with explicit seriality escape per research-043

## Overview

**Current State**: Phases 0-5 COMPLETED. Phase 6 has 13 sorries (10 in DensityFrameCondition, 3 in CantorApplication), ALL sharing a single root cause: escaping reflexive clusters.

**The Mathematical Obstruction** (from research-043):
- When M' is reflexive, non-strict density returns W = M' (Case B1)
- W = M' collapses in the quotient: [W] = [M'], so W is not "strictly between"
- The reflexive cluster is an equivalence class; we must ESCAPE it via seriality

**The Solution**: Pattern C with seriality escape
1. When witness W is not strict, apply seriality to M' to get strict future M''
2. Recurse with density(M, M'')
3. Bounded by subformula count via Nat.strongRecOn

## Goals & Non-Goals

**Goals**:
- Implement Pattern C with explicit seriality escape mechanism
- Clear separation: iteration function + sufficiency proof + final composition
- Zero sorries in Phase 6 files
- Complete Phases 7-8 for D = Q construction

**Non-Goals**:
- Pattern B (Finset.strongInductionOn) - blocked by decidability
- Direct formula-based proof - research-043 confirms iteration is necessary

## Implementation Phases

### Phase 0-5: [COMPLETED]

All phases completed with zero sorries.

---

### Phase 6: Pattern C Strict Density [IN PROGRESS]

**Goal**: All 13 sorries resolved via Pattern C iteration

**Progress:**

**Session: 2026-03-12, sess_1773343103_ae99e7**
- Analyzed: 10 sorries in DensityFrameCondition.lean, 3 in CantorApplication.lean
- Found: Direct case analysis uses exfalso in non-contradictory cases
- Found: Case B1 (M' reflexive) requires iteration, not contradiction
- Blocked: Need to implement seriality_escape helper first
- Created: handoff document with detailed analysis
- Sorries: 13 -> 13 (analysis only, no changes)

#### Phase 6a: Seriality Escape Helper (30 min)

**Purpose**: Extract the "escape" mechanism from reflexive clusters into a clean helper.

```lean
/-- When M' is reflexive, seriality guarantees a strict future exists.
    This escapes the reflexive equivalence class [M']. -/
theorem seriality_escape (M' : Set Formula) (h_mcs' : SetMaximalConsistent M')
    (h_refl : CanonicalR M' M') :
    ∃ M'' : Set Formula, SetMaximalConsistent M'' ∧
      CanonicalR M' M'' ∧ ¬CanonicalR M'' M' := by
  -- F(T) ∈ M' by seriality
  -- Apply canonical_forward_F to get M'' with T ∈ M''
  -- M'' cannot see back to M' because that would require G(T) ∈ M''
  -- But G(T) implies T by temp_4, and T ∧ G(T) is inconsistent with irreflexive frame condition
  sorry
```

**Verification**: `lake build` passes, helper compiles

#### Phase 6b: Fuel-Based Iteration Function (1 hour)

**Purpose**: Define `strictDensityWithFuel` that iterates until strict witness found.

```lean
/-- Iteration with fuel: applies density, escapes via seriality if not strict. -/
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
    -- Get non-strict witness
    let ⟨W, hW_mcs, hW_R1, hW_R2⟩ := density_frame_condition M M' h_mcs h_mcs' h_R h_not_R'
    -- Check both strictness conditions
    if h_back : ¬CanonicalR W M then
      if h_fwd : ¬CanonicalR M' W then
        -- STRICT! Done.
        some ⟨W, hW_mcs, hW_R1, hW_R2, h_back, h_fwd⟩
      else
        -- W ~ M' (forward collapse), escape via seriality
        if h_refl : CanonicalR M' M' then
          let ⟨M'', hM''⟩ := seriality_escape M' h_mcs' h_refl
          -- Recurse with new target M''
          strictDensityWithFuel M M'' h_mcs hM''.1
            (canonicalR_transitive h_R hM''.2.1)
            (not_R_after_escape h_not_R' hM''.2.2) n
        else
          -- M' not reflexive but CanonicalR M' W - contradiction
          absurd (⟨W, hW_mcs, h_fwd, hW_R2⟩) (non_reflexive_no_mutual_future h_mcs' h_refl)
    else
      -- W sees back to M (backward collapse), same escape
      if h_refl : CanonicalR M' M' then
        let ⟨M'', hM''⟩ := seriality_escape M' h_mcs' h_refl
        strictDensityWithFuel M M'' h_mcs hM''.1
          (canonicalR_transitive h_R hM''.2.1)
          (not_R_after_escape h_not_R' hM''.2.2) n
      else
        -- Non-reflexive M' with CanonicalR W M - analyze further
        sorry -- Direct case analysis possible here
termination_by fuel
```

**Verification**: Function compiles, type-checks with `lake build`

#### Phase 6c: Fuel Sufficiency Proof (2 hours)

**Purpose**: Prove iteration terminates via Nat.strongRecOn on subformula count.

**Key insight**: Each iteration uses a DIFFERENT distinguishing formula. The set of potential distinguishing formulas is bounded by the subformula closure.

```lean
/-- Anchor formula construction: a formula whose subformulas contain all of GContent(M'). -/
theorem anchor_formula_exists (M' : Set Formula) (h_mcs' : SetMaximalConsistent M') :
    ∃ anchor : Formula, ∀ phi, Formula.all_future phi ∈ M' → phi ∈ anchor.subformulas := by
  -- M' is finitely axiomatizable (or use universe bound)
  -- Construct anchor as conjunction/disjunction of representatives
  sorry

/-- Sufficient fuel exists, bounded by subformula count. -/
theorem fuel_suffices (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (h_not_R' : ¬CanonicalR M' M)
    (anchor : Formula)
    (h_anchor : ∀ phi, Formula.all_future phi ∈ M' → phi ∈ anchor.subformulas) :
    ∃ fuel, (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel).isSome := by
  -- Strong induction on anchor.subformulaCount
  apply Nat.strongRecOn anchor.subformulaCount
  intro n ih
  -- Case: does strictDensityWithFuel succeed with fuel = 1?
  by_cases h_one : (strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' 1).isSome
  case pos => exact ⟨1, h_one⟩
  case neg =>
    -- fuel = 1 failed, meaning we escaped via seriality
    -- New target M'' has DIFFERENT distinguishing formula
    -- This formula is in anchor.subformulas (by h_anchor for the chain)
    -- Apply ih with smaller subformula measure
    sorry
```

**Verification**: `fuel_suffices` compiles and type-checks

#### Phase 6d: Final Composition (30 min)

```lean
/-- Main theorem: strict intermediate always exists. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧
      CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR W M ∧ ¬CanonicalR M' W := by
  obtain ⟨anchor, h_anchor⟩ := anchor_formula_exists M' h_mcs'
  obtain ⟨fuel, h_fuel⟩ := fuel_suffices M M' h_mcs h_mcs' h_R h_not_R' anchor h_anchor
  let result := strictDensityWithFuel M M' h_mcs h_mcs' h_R h_not_R' fuel
  exact ⟨result.get h_fuel⟩.snd
```

#### Phase 6e: CantorApplication Integration (30 min)

Use `density_frame_condition_strict` in CantorApplication.lean:

```lean
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) := ⟨fun p => by
  obtain ⟨W, hW⟩ := density_frame_condition_strict p.mcs ... -- use strict version
  exact ⟨⟨W, ...⟩, ...⟩
⟩

instance : NoMinOrder (TimelineQuot root_mcs root_mcs_proof) := ... -- symmetric

instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) := ⟨fun a b hab => by
  -- Extract MCSs from quotient representatives
  -- Apply density_frame_condition_strict
  -- Lift result to quotient
  ...
⟩
```

**Timing**: Phase 6 total = 4.5 hours

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
- [ ] `staged_completeness : valid phi → provable phi`

**Timing:** 0.5 hours

---

## Testing & Validation

- [ ] `lake build` passes
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` empty
- [ ] `grep -n "^axiom " Theories/.../StagedConstruction/` shows no new axioms
- [ ] `density_frame_condition_strict` has type `∃ W, ...`

## Summary of Changes from v020

| Aspect | v020 | v021 |
|--------|------|------|
| **Seriality escape** | Implicit in fuel function | Explicit helper theorem |
| **Phase structure** | 4 sub-phases | 5 sub-phases (clearer boundaries) |
| **Mathematical clarity** | Pattern C description | Reflexive cluster obstruction explained |
| **Time estimates** | 3.5 hours | 4.5 hours (more realistic) |

## Revision History

- **v021** (this revision): Streamlined with explicit seriality escape per research-043
- **v020**: Pattern C structure introduced
- **v019**: Pattern B (blocked by decidability)
- **v018-v016**: Earlier iterations
