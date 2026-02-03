# Research Report: Task #825

**Task**: FDSM Multi-History Modal Saturation (Phase 4 from implementation-003.md)
**Date**: 2026-02-03
**Focus**: Saturation fixed-point construction and termination proofs
**Session ID**: sess_1770086731_7dfdbc

## Summary

This report provides comprehensive research for implementing Phase 4 of the FDSM construction: the saturation fixed-point that iteratively adds witness histories until modal saturation is achieved. The key challenge is proving termination via the 2^closureSize bound while ensuring the modal_saturated property holds at the fixed point.

## 1. Current State Analysis

### 1.1 ModalSaturation.lean Status

The current `ModalSaturation.lean` (330 lines) contains:

**Completed Infrastructure (Phase 3)**:
- `isDiamondFormula`, `diamondInner?` - Diamond formula identification
- `witnessSet` - Construction of witness sets for diamond formulas
- `psi_mem_witnessSet`, `box_in_M_implies_in_witnessSet` - Witness set membership lemmas
- `witness_set_consistent` - **Has sorry** for modal necessitation reasoning (lines 190, 212)
- `modal_backward_from_saturation` - **Has sorry** (line 280)

**Placeholder Infrastructure (Phase 4 Stubs)**:
- `needsWitness` - Returns `none` placeholder (lines 292-297)
- `maxHistories` - Defined as `2 ^ closureSize phi` (lines 304-305)

### 1.2 Core.lean Status

The `FiniteDynamicalSystemModel` structure has:
- `modal_saturated` field with **sorry** for closure membership (line 205)
- Single-history `fdsm_from_closure_mcs` trivializes modal semantics

### 1.3 Completeness.lean Status

- Uses single-history construction that trivializes Box
- `modal_saturated` proof uses **sorry** (line 87)
- Research-013 warns this construction validates invalid principles (Box phi = phi)

## 2. Phase 4 Requirements

From implementation-003.md Phase 4:

1. **saturation_step**: One round of adding missing witnesses
2. **saturated_histories**: Fixed-point construction
3. **Termination proof**: Histories bounded by `2^closureSize`
4. **modal_saturated property**: At fixed point, all diamonds have witnesses
5. **modal_backward derivation**: Contrapositive of saturation

### 2.1 Mathematical Goal

```
saturated_histories_modal_saturated:
  forall h in hists, forall t, forall psi,
    (Formula.box psi).neg in (h.states t).toSet ->
    exists h' in hists, psi.neg in (h'.states t).toSet
```

The dual property for modal_backward:
```
saturated_modal_backward:
  forall h in hists, forall t, forall psi,
    (forall h' in hists, psi in (h'.states t).toSet) ->
    Formula.box psi in (h.states t).toSet
```

## 3. Mathlib Patterns for Saturation

### 3.1 Well-Founded Induction on Finsets

The strict subset relation on `Finset` is well-founded:

| Lemma | Type | Module |
|-------|------|--------|
| `Finset.lt_wf` | `WellFounded Finset.partialOrder.lt` | Mathlib.Data.Finset.Card |
| `Finset.isWellFounded_ssubset` | `IsWellFounded (Finset alpha) SSubset` | Mathlib.Data.Finset.Defs |
| `Finset.wellFoundedLT` | `WellFoundedLT (Finset alpha)` | Mathlib.Data.Finset.Defs |

**Usage Pattern for Saturation**:
```lean
theorem saturation_terminates :
    WellFounded (fun s t : Finset (FDSMHistory phi) => s ssubset t) :=
  Finset.wellFoundedLT.wf
```

### 3.2 Strong Induction on Finset Cardinality

| Lemma | Type | Module |
|-------|------|--------|
| `Finset.strongInduction` | Strong induction on strict subset | Mathlib.Data.Finset.Card |
| `Finset.strongDownwardInduction` | Downward induction with card bound | Mathlib.Data.Finset.Card |
| `Finset.card_lt_card` | `s ssubset t -> s.card < t.card` | Mathlib.Data.Finset.Card |

**Key Theorem** (Mathlib.Data.Finset.Card):
```lean
theorem Finset.card_lt_card {s t : Finset alpha} (h : s ssubset t) : s.card < t.card
```

### 3.3 Cardinality Bound Lemmas

| Lemma | Type | Module |
|-------|------|--------|
| `Finset.card_insert_of_notMem` | `a notin s -> (insert a s).card = s.card + 1` | Mathlib.Data.Finset.Card |
| `Finset.card_le_card` | `s subseteq t -> s.card <= t.card` | Mathlib.Data.Finset.Card |
| `Finset.card_mono` | `Monotone card` | Mathlib.Data.Finset.Card |
| `card_finset_fin_le` | `s.card <= n` for `s : Finset (Fin n)` | Mathlib.Data.Fintype.Basic |

### 3.4 Iteration Patterns

| Lemma | Type | Module |
|-------|------|--------|
| `Nat.iterate` | Iterate function n times | Mathlib.Logic.Function.Iterate |
| `Function.iterate_fixed` | `f x = x -> iterate f n x = x` | Mathlib.Logic.Function.Iterate |
| `Monotone.iterate` | Monotone function iterates are monotone | Mathlib.Order.Monotone.Defs |
| `Monotone.monotone_iterate_of_le_map` | Monotone iterate sequence | Mathlib.Order.Iterate |

## 4. Termination Strategy

### 4.1 Approach: Bounded Iteration with Fuel

Since `FDSMHistory phi` is finite (function from finite type to finite type), and the maximum number of distinct histories is bounded by `2^closureSize phi`, we can use a fuel-based approach:

```lean
def maxHistories (phi : Formula) : Nat := 2 ^ closureSize phi

def saturation_step (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) : Finset (FDSMHistory phi) :=
  -- For each history h in hists
  -- For each diamond formula Diamond psi where Diamond psi in h.states t
  -- If no witness exists, add a new witness history
  hists union (new_witnesses phi hists t)

def saturate_with_fuel (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) (fuel : Nat) : Finset (FDSMHistory phi) :=
  match fuel with
  | 0 => hists
  | fuel + 1 =>
      let hists' := saturation_step phi hists t
      if hists' = hists then hists  -- Fixed point reached
      else saturate_with_fuel phi hists' t fuel

def saturated_histories (phi : Formula) (h_cons : SetConsistent {phi}) :
    Finset (FDSMHistory phi) :=
  -- Start with initial history from Lindenbaum extension
  let initial := {initial_history phi h_cons}
  -- Saturate with fuel = maxHistories
  saturate_with_fuel phi initial (BoundedTime.origin _) (maxHistories phi)
```

### 4.2 Termination Proof Structure

**Key Insight**: Each saturation step either:
1. Adds at least one new history (strictly increasing cardinality), OR
2. Reaches fixed point (no new witnesses needed)

**Termination Argument**:
```lean
theorem saturation_terminates (phi : Formula) :
    exists n <= maxHistories phi,
      saturation_step^[n] initial = saturation_step^[n+1] initial := by
  -- By Finset.card_lt_card: each step increases card by at least 1
  -- Card bounded by maxHistories = 2^closureSize
  -- Therefore terminates in at most maxHistories steps
  ...
```

### 4.3 Alternative: Well-Founded Recursion

```lean
def saturated_histories' (phi : Formula) (h_cons : SetConsistent {phi}) :
    Finset (FDSMHistory phi) := by
  apply WellFounded.fix (invImage (fun s => maxHistories phi - s.card) Nat.lt_wfRel.wf)
  intro hists ih
  let hists' := saturation_step phi hists (BoundedTime.origin _)
  if h : hists' = hists then
    exact hists  -- Fixed point
  else
    -- Card increases, so maxHistories - card decreases
    exact ih hists' (by
      have h_lt := saturation_step_card_increase phi hists h
      omega)
```

## 5. Modal Saturation Property

### 5.1 Saturation Invariant

Define the saturation check predicate:

```lean
def is_modally_saturated (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) : Prop :=
  forall h in hists, forall psi,
    psi in closure phi ->
    (Formula.neg (Formula.box (Formula.neg psi))) in (h.states t).toSet ->
    exists h' in hists, psi in (h'.states t).toSet
```

### 5.2 Fixed Point Implies Saturation

```lean
theorem fixed_point_is_saturated (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi)
    (h_fixed : saturation_step phi hists t = hists) :
    is_modally_saturated phi hists t := by
  intro h hh psi h_psi_clos h_diamond
  -- By definition of saturation_step:
  -- If Diamond psi in h but no witness exists, saturation_step adds one
  -- Since saturation_step = identity (fixed point), no witnesses were needed
  -- Therefore for every Diamond psi, a witness already exists
  by_contra h_no_witness
  -- saturation_step would have added a witness for (h, psi)
  have h_step_adds := saturation_step_adds_witness ...
  -- But saturation_step = hists, contradiction
  ...
```

### 5.3 Modal Backward from Saturation (Contrapositive)

```lean
theorem modal_backward_from_saturation' (phi : Formula)
    (hists : Finset (FDSMHistory phi)) (t : FDSMTime phi)
    (h_sat : is_modally_saturated phi hists t)
    (h : FDSMHistory phi) (hh : h in hists) (psi : Formula)
    (h_psi_clos : psi in closure phi)
    (h_all : forall h' in hists, psi in (h'.states t).toSet) :
    Formula.box psi in (h.states t).toSet := by
  -- Contrapositive: assume Box psi notin h.states t
  by_contra h_not_box
  -- By MCS negation completeness: (Box psi).neg in h.states t
  have h_diamond := closure_mcs_neg_complete ... h_not_box
  -- This is Diamond (neg psi) form (after unfolding neg (Box psi))
  -- By h_sat: exists h' in hists where psi.neg in h'.states t
  -- But h_all says psi in ALL histories
  -- Contradiction: psi and psi.neg in same history
  obtain ⟨h', hh', h_neg_psi⟩ := h_sat h hh (psi.neg) ...
  have h_psi := h_all h' hh'
  exact mcs_inconsistent h_psi h_neg_psi
```

## 6. Implementation Architecture

### 6.1 Required Definitions

```lean
-- 1. Diamond formula check and extraction
def getDiamondWitness? (f : Formula) : Option Formula :=
  match f with
  | Formula.neg (Formula.box (Formula.neg psi)) => some psi
  | _ => none

-- 2. Unsatisfied diamonds in a history
def unsatisfiedDiamonds (phi : Formula) (hists : Finset (FDSMHistory phi))
    (h : FDSMHistory phi) (t : FDSMTime phi) : Finset Formula :=
  (closure phi).filter (fun psi =>
    (Formula.neg (Formula.box (Formula.neg psi))) in (h.states t).toSet ∧
    forall h' in hists, psi notin (h'.states t).toSet)

-- 3. Build witness history for a diamond formula
noncomputable def buildWitnessHistory (phi : Formula) (h : FDSMHistory phi)
    (t : FDSMTime phi) (psi : Formula)
    (h_diamond : (Formula.neg (Formula.box (Formula.neg psi))) in (h.states t).toSet) :
    FDSMHistory phi :=
  -- Witness set = {psi} union {chi | Box chi in h.states t}
  -- Extend to closure MCS
  -- Build constant history from closure MCS
  ...

-- 4. Saturation step
def saturation_step (phi : Formula) (hists : Finset (FDSMHistory phi))
    (t : FDSMTime phi) : Finset (FDSMHistory phi) :=
  hists union (hists.biUnion (fun h =>
    (unsatisfiedDiamonds phi hists h t).image (fun psi =>
      buildWitnessHistory phi h t psi ...)))

-- 5. Fixed point via fuel
def saturated_histories (phi : Formula) (h_cons : SetConsistent {phi}) :
    Finset (FDSMHistory phi) :=
  saturate_with_fuel phi {initial_history phi h_cons}
    (BoundedTime.origin _) (maxHistories phi)
```

### 6.2 Key Theorems to Prove

1. **`witness_set_consistent`**: If M is MCS with Diamond psi, witness set is consistent
   - Currently has sorry - requires modal necessitation reasoning
   - Key: K axiom + necessitation on finite box-formulas

2. **`saturation_step_preserves_consistency`**: New histories are consistent
   - Depends on witness_set_consistent

3. **`saturation_step_monotone`**: `hists subseteq saturation_step hists`
   - Direct from union definition

4. **`saturation_step_card_bound`**: If not fixed, card increases by at least 1
   - Use `Finset.card_insert_of_notMem`

5. **`saturation_terminates`**: Fixed point reached in at most `maxHistories` steps
   - Combine card bound with `2^closureSize` bound

6. **`saturated_is_modal_saturated`**: Fixed point has saturation property
   - By definition of fixed point

7. **`modal_backward_from_saturation`**: Contrapositive derivation
   - Uses saturation + MCS negation completeness

## 7. Technical Challenges

### 7.1 witness_set_consistent Sorry

The current sorry at line 190-212 requires proving:
- If witness set {psi, chi_1, ..., chi_n} is inconsistent (where Box chi_i in M)
- Then by deduction and necessitation, Box(neg psi) is derivable from M
- But M contains Diamond psi = neg(Box(neg psi)), contradicting MCS consistency

**Required Infrastructure**:
- Lift derivation from Gamma to Box-Gamma via K axiom iterations
- Necessitation on finite context

### 7.2 Closure Membership Tracking

The `modal_saturated` field in `FiniteDynamicalSystemModel` requires:
- Proving `(Box (neg psi)).neg in closure phi` given `psi in closure phi`
- Current sorry at line 205 needs closure properties for box/neg

**Required Lemmas**:
```lean
theorem box_neg_in_closureWithNeg (phi psi : Formula)
    (h : psi in closure phi) :
    (Formula.box (Formula.neg psi)).neg in closureWithNeg phi
```

### 7.3 Multi-Time Saturation

The current task description mentions saturation at each time t. For full saturation:
- Either saturate at all times simultaneously
- Or prove saturation at origin suffices (constant histories)

## 8. Recommendations

### 8.1 Implementation Order

1. **First**: Implement `unsatisfiedDiamonds` and `buildWitnessHistory`
2. **Second**: Implement `saturation_step` with fuel-based termination
3. **Third**: Prove `saturation_terminates` using card bounds
4. **Fourth**: Prove `saturated_is_modal_saturated` from fixed-point property
5. **Fifth**: Prove `modal_backward_from_saturation` via contrapositive

### 8.2 Handling witness_set_consistent Sorry

Two approaches:
1. **Accept as axiom for now**: Focus on saturation structure
2. **Prove directly**: Requires 50+ lines of modal reasoning with K axiom

Recommendation: Mark as a known sorry with clear documentation, focus on saturation structure first.

### 8.3 Simplification: Time-Uniform Saturation

Since histories are constant (same world state at all times), saturation at the origin implies saturation at all times. This simplifies implementation.

## 9. Relevant Mathlib Lemmas Summary

| Pattern | Lemma | Usage |
|---------|-------|-------|
| Termination | `Finset.wellFoundedLT` | Well-founded induction on subset |
| Card increase | `Finset.card_lt_card` | Strict subset implies card increase |
| Insert card | `Finset.card_insert_of_notMem` | Adding new element increases card by 1 |
| Card bound | `finiteWorldState_card_bound` | World states bounded by 2^closureSize |
| Monotone iterate | `Monotone.iterate` | Saturation step is monotone |
| Fixed point | `Function.iterate_fixed` | Fixed point stability |
| Strong induction | `Finset.strongInduction` | Induction on strict subset |

## 10. References

### Codebase Files
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Current Phase 3 infrastructure
- `Theories/Bimodal/Metalogic/FDSM/Core.lean` - FDSM structure definitions
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Current single-history construction
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - closureSize and closure lemmas
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Fuel-based saturation pattern

### Prior Research
- research-013.md: Multi-family modal saturation analysis
- research-014.md: FMP-based finite model strategy
- implementation-003.md: Phase 4 specification

### Mathlib
- `Mathlib.Data.Finset.Card` - Cardinality lemmas and strong induction
- `Mathlib.Logic.Function.Iterate` - Iteration patterns
- `Mathlib.Order.Iterate` - Monotone iteration

## Next Steps

1. Continue from line 287 in ModalSaturation.lean
2. Implement saturation_step with proper termination handling
3. Prove modal_saturated property at fixed point
4. Update Completeness.lean to use multi-history construction
