# Implementation Plan: Task #981 (Revision 3)

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Dependencies**: None (builds on existing codebase)
- **Research Inputs**: research-004.md (T-axiom direct subset argument)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**What changed from v2**:
- Phase 2 is NOW MUCH SIMPLER: The G-inference lifting approach in v2 was overcomplicating the problem
- **Key insight from research-004**: The codebase uses **KT4** (T-axiom at `Axioms.lean:256`), NOT strict K4
- `g_content(M) ⊆ M` holds for ALL MCSs by T-axiom closure - this is the breakthrough
- The sorry at line 319 is fillable with a DIRECT SUBSET ARGUMENT (~20 lines)
- Effort reduced from 5-7 hours to 4-5 hours due to simpler proof structure

**What stays the same from v2**:
- Phase 1 (blocking formula definitions): COMPLETED in v1, preserved
- Phase 3-5 approach: discreteImmediateSucc, covering, SuccOrder.ofCore
- Phase 6: axiom removal and verification

## Overview

This plan eliminates `discrete_Icc_finite_axiom` using the constructive method with blocking formulas. The critical breakthrough is recognizing that the T-axiom `G(phi) -> phi` gives us `g_content(M) ⊆ M` for free, making the consistency proof a simple subset argument rather than complex G-inference lifting.

### Research Integration

**Research-004.md findings integrated**:
- The codebase is KT4 (T-axiom confirmed at `Axioms.lean:256`), not K4
- New lemma `g_content_subset_mcs` (5 lines) uses `temp_t_future`
- Case 2 sorry is fillable via: `L_g ⊆ g_content(M) ⊆ M`, triggers ⊆ M, therefore contradiction

## Goals & Non-Goals

**Goals**:
- Prove consistency of blocking seed via direct subset argument (using T-axiom)
- Define `discreteImmediateSucc` as Lindenbaum extension
- Prove covering property using blocking formulas
- Instantiate `SuccOrder` via `SuccOrder.ofCore`
- Delete `discrete_Icc_finite_axiom`
- Build passes with zero sorries in affected files

**Non-Goals**:
- G-inference lifting (proven unnecessary by research-004)
- Arbitrary forward witness containment (proven impossible by research-003)
- Fixing IRR + T-axiom inconsistency (pre-existing issue, not in scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cut/substitution formalization | MEDIUM | LOW | Research-004 gives multiple options; simplest is weakening + subset |
| Covering proof case analysis | MEDIUM | MEDIUM | Blocking formulas force clean disjunctions |
| SuccOrder.ofCore availability | LOW | LOW | Verify early with `lean_local_search` |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry: `DiscreteSuccSeed.lean:319` (Case 2 of consistency proof)

### Expected Resolution
- Phase 2 fills line 319 sorry via direct subset argument using T-axiom
- No deletion/replacement - the existing proof structure is correct, just incomplete

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach

### Remaining Debt
After this implementation:
- 0 sorries in `DiscreteSuccSeed.lean`
- 0 axioms in `DiscreteTimeline.lean` (discrete_Icc_finite_axiom removed)

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `discrete_Icc_finite_axiom` in `DiscreteTimeline.lean`

### Expected Resolution
- Phase 5 eliminates axiom via `SuccOrder.ofCore` instantiation
- Phase 6 deletes the axiom declaration

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
After this implementation:
- 0 axioms in discrete timeline module
- Downstream theorems inherit no axiom dependency

## Implementation Phases

### Phase 1: Define Discrete Immediate Successor Seed [COMPLETED]

**Dependencies:** None
**Goal:** Already implemented in v1. No changes needed.

**What exists**:
- `blockingFormula`, `blockingFormulas`, `discreteImmediateSuccSeed` definitions
- `blocking_formula_from_negG`: `[negG(psi)] |- neg psi ∨ negG(psi)`
- `g_content_consistent`: g_content(M) is consistent
- `discreteImmediateSuccSeed_consistent` with Case 1 complete, Case 2 sorry

**Files created**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

---

### Phase 2: Fill Case 2 Sorry (T-Axiom Direct Subset) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Fill the sorry at line 319 using the T-axiom to show `g_content(M) ⊆ M`

**Key insight (research-004)**: The T-axiom `temp_t_future` gives us `G(phi) -> phi`, so for any phi in g_content(M) (meaning G(phi) in M), we have phi in M by MCS implication closure.

**Tasks:**
- [ ] Add lemma `g_content_subset_mcs`:
```lean
lemma g_content_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by
  intro φ h_in_gc
  -- h_in_gc : φ ∈ g_content M means G(φ) ∈ M
  have h_T : [] ⊢ (Formula.all_future φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_T) h_in_gc
```

- [ ] Fill Case 2 sorry at line 319 with direct subset argument:
  - Build the set of triggers: for each blocking formula bf in L, get trigger negG(psi) in M
  - Show: all g_content formulas in L are in M (by `g_content_subset_mcs`)
  - Show: all triggers are in M (by definition of blocking formulas)
  - Use weakening: from `L ⊢ ⊥` with L ⊆ M derive contradiction via `closed_under_derivation`
  - Alternatively, use cut to replace each bf with its trigger, then apply subset

- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty
- `lean_goal` shows "no goals" at theorem QED

---

### Phase 3: Define Discrete Immediate Successor [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Define `discreteImmediateSucc M` as Lindenbaum extension of the consistent seed

**Tasks:**
- [ ] Define `discreteImmediateSucc M := lindenbaumMCS_set (discreteImmediateSuccSeed M) h_consistent`
- [ ] Prove `discreteImmediateSucc_mcs`: result is MCS
- [ ] Prove `discreteImmediateSucc_extends_seed`: seed formulas are in result
- [ ] Prove `discreteImmediateSucc_canonicalR`: `CanonicalR M (discreteImmediateSucc M)`
  - Follows from `g_content M ⊆ seed ⊆ discreteImmediateSucc M`
- [ ] Prove `discreteImmediateSucc_blocking`: blocking formulas are in result
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- All proofs complete (no sorries)

---

### Phase 4: Prove Covering Property [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove no MCS exists strictly between M and `discreteImmediateSucc M`

**Tasks:**
- [ ] State covering theorem:
```lean
theorem discreteImmediateSucc_covers
    (M K : Set Formula)
    (h_M : SetMaximalConsistent M)
    (h_K : SetMaximalConsistent K)
    (h_MK : CanonicalR M K)
    (h_KW : CanonicalR K (discreteImmediateSucc M h_M)) :
    K = M ∨ K = discreteImmediateSucc M h_M
```

- [ ] Prove using blocking formula argument:
  - Let W = discreteImmediateSucc M
  - Suppose K != M and K != W (want contradiction)
  - Since CanonicalR M K: g_content(M) ⊆ K
  - Since CanonicalR K W: g_content(K) ⊆ W
  - Consider blocking formulas in W
  - Each bf = neg psi ∨ negG(psi) with negG(psi) in M
  - If negG(psi) in K, then K agrees with M on this formula
  - Case analysis forces K = M or K = W

- [ ] If stuck, mark [BLOCKED] with review_reason
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- `lean_goal` shows "no goals" at theorem QED
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty

---

### Phase 5: Derive SuccOrder via ofCore [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Instantiate `SuccOrder` using `SuccOrder.ofCore` and covering property

**Mathlib API**:
```lean
SuccOrder.ofCore :
  (succ : alpha -> alpha) ->
  (forall {a}, ¬IsMax a -> forall b, a < b <-> succ a <= b) ->
  (forall a, IsMax a -> succ a = a) ->
  SuccOrder alpha
```

**Tasks:**
- [ ] Verify `SuccOrder.ofCore` is available: `lean_local_search "SuccOrder.ofCore"`
- [ ] Define `discreteSuccFn : DiscreteTimelineQuot -> DiscreteTimelineQuot`
  - Lift `discreteImmediateSucc` to quotient
- [ ] Prove the covering condition for ofCore:
  - `forall {a}, ¬IsMax a -> forall b, a < b <-> discreteSuccFn a <= b`
  - This follows from Phase 4's covering property
- [ ] Prove max handling (NoMaxOrder makes this vacuous):
  - `forall a, IsMax a -> discreteSuccFn a = a`
- [ ] Instantiate `SuccOrder` via `SuccOrder.ofCore`
- [ ] Derive `LocallyFiniteOrder` as consequence (from SuccOrder + PredOrder + linear)
- [ ] Verify with `lake build` WITHOUT `discrete_Icc_finite_axiom`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes
- SuccOrder instance compiles WITHOUT `discrete_Icc_finite_axiom`

---

### Phase 6: Remove Axiom and Final Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Delete `discrete_Icc_finite_axiom` and verify clean build

**Tasks:**
- [ ] Delete `discrete_Icc_finite_axiom` declaration from `DiscreteTimeline.lean`
- [ ] Delete `discrete_Icc_finite` theorem that wraps the axiom
- [ ] Update `LocallyFiniteOrder` instance to derive from SuccOrder
- [ ] Run full `lake build` to verify no regressions
- [ ] Run `grep -rn "\baxiom\b" Theories/Bimodal/` to verify no new axioms
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` to verify zero sorries
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes with no errors
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` returns empty

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] `discreteCanonicalTaskFrame` still compiles and works
- [ ] Downstream completeness proofs still work
- [ ] No regressions in existing functionality

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (modified)
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (modified)
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. Phase 2 is now LOW risk - T-axiom argument is well-understood
2. Phase 4 (covering) remains the main challenge - if formalization stuck, mark [BLOCKED]
3. Original `DiscreteTimeline.lean` preserved in git history
4. Fallback: accept axiom with typeclass constraint (research-003 Approach D)
