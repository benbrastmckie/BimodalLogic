# Phase 4 Handoff: Wire Constructive Proof to Replace Axiom

## Immediate Next Action

Modify `exists_fullySaturated_extension` in SaturatedConstruction.lean to use temporal Lindenbaum for witness construction.

## Current State

- **File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
- **Line**: 985 (witness construction via set_lindenbaum)
- **Goal**: Replace `set_lindenbaum` with temporal Lindenbaum to ensure witness families are temporally coherent

## Completed Work

### Phase 1: Axiom 5 Derivation (COMPLETED)
- Added `axiom_5_negative_introspection` in ModalSaturation.lean
- Added `mcs_neg_box_implies_box_neg_box` for MCS version

### Phase 2: Fix 3 Sorries (COMPLETED)
- All 3 sorries in `exists_fullySaturated_extension` are fixed
- Build succeeds with only linter warnings
- Key fix: Axiom 5 contradiction argument for Lindenbaum coherence

### Phase 3: Truth Lemma Investigation (COMPLETED)
- Truth lemma requires `B.temporally_coherent` for ALL families
- However, only eval_family is used in completeness proof
- Constant families with TemporalForwardSaturated + TemporalBackwardSaturated automatically satisfy forward_F/backward_P
- Decision: Use temporal Lindenbaum for witness construction

## Phase 4 Implementation Strategy

### Step 1: Add Import
```lean
import Bimodal.Metalogic.Bundle.TemporalLindenbaum
```

### Step 2: Replace set_lindenbaum (line 985)

Current:
```lean
have ⟨W_set, h_W_extends, h_W_mcs⟩ := set_lindenbaum ({psi} ∪ BoxContent) h_witness_set_consistent
```

Replace with:
```lean
-- Use henkinLimit to add temporal witnesses
let tempBase := {psi} ∪ BoxContent
let henkinSet := henkinLimit tempBase
have h_henkin_consistent := henkinLimit_consistent tempBase h_witness_set_consistent
have h_henkin_fwd := henkinLimit_forward_saturated tempBase
have h_henkin_bwd := henkinLimit_backward_saturated tempBase
have h_base_sub_henkin := base_subset_henkinLimit tempBase

-- Apply temporal Lindenbaum to get MCS that's temporally saturated
let W_set := temporalSetLindenbaum henkinSet h_henkin_consistent h_henkin_fwd h_henkin_bwd
have h_W_in_tcs := temporalSetLindenbaum_in_tcs henkinSet h_henkin_consistent h_henkin_fwd h_henkin_bwd
have h_W_extends_henkin := temporalSetLindenbaum_extends henkinSet h_henkin_consistent h_henkin_fwd h_henkin_bwd

-- W_set is MCS and temporally saturated
have h_W_mcs : SetMaximalConsistent W_set :=
  maximal_tcs_is_mcs henkinSet W_set h_W_in_tcs
    (temporalSetLindenbaum_maximal henkinSet h_henkin_consistent h_henkin_fwd h_henkin_bwd)

-- Original set is contained
have h_W_extends : tempBase ⊆ W_set := by
  trans henkinSet
  · exact h_base_sub_henkin
  · exact h_W_extends_henkin
```

### Step 3: Add Temporal Coherence Properties

After creating constant witness family W, prove it's temporally coherent:

```lean
-- W is constant and temporally saturated, so it satisfies forward_F/backward_P
have h_W_forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ W.mcs t → ∃ s : D, t < s ∧ φ ∈ W.mcs s := by
  intro t phi h_F
  -- W.mcs t = W_set (constant family)
  have h_eq : W.mcs t = W_set := constantWitnessFamily_mcs_eq W_set h_W_mcs t
  rw [h_eq] at h_F
  -- W_set is TemporalForwardSaturated: F(phi) ∈ W_set → phi ∈ W_set
  have h_phi_in_W := h_W_in_tcs.2.2.1 phi h_F
  -- Take any s > t
  use t + 1
  constructor
  · linarith  -- or use appropriate ordering proof
  · rw [constantWitnessFamily_mcs_eq W_set h_W_mcs (t + 1)]
    exact h_phi_in_W

-- Similar for backward_P
```

### Step 4: Update FamilyCollection.saturate

The `saturate` function needs to track that all families are temporally coherent:
- Either add a constraint to the Zorn set S
- Or prove post-hoc that witness families from temporal Lindenbaum are temporally coherent

### Step 5: Create fully_saturated_bmcs_exists_constructive

```lean
theorem fully_saturated_bmcs_exists_constructive (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS D),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  -- Construction combines:
  -- 1. temporalLindenbaumMCS for initial temporally saturated family
  -- 2. exists_fullySaturated_extension for modal saturation
  -- With temporal Lindenbaum for all witness families
  sorry  -- Full proof requires the modifications above
```

## Key Decisions Made

1. Use `henkinLimit` + `temporalSetLindenbaum` instead of `set_lindenbaum` for witnesses
2. All witness families will be constant and temporally saturated
3. This ensures `B.temporally_coherent` for the final BMCS

## What NOT to Try

1. Modifying `B.temporally_coherent` definition - the truth lemma depends on it
2. Skipping temporal saturation for witness families - completeness needs it
3. Using regular `set_lindenbaum` - doesn't preserve temporal properties

## Critical Context

1. `henkinLimit` automatically adds temporal witnesses and is TemporalForwardSaturated/BackwardSaturated
2. `temporalSetLindenbaum` extends to MCS while preserving temporal saturation
3. `maximal_tcs_is_mcs` proves maximal temporally-saturated consistent set is MCS
4. Constant families with temporal saturation automatically satisfy forward_F/backward_P

## Dependencies

- `TemporalLindenbaum.lean` provides:
  - `henkinLimit`, `henkinLimit_consistent`, `henkinLimit_forward_saturated`, `henkinLimit_backward_saturated`
  - `temporalSetLindenbaum`, `temporalSetLindenbaum_extends`, `temporalSetLindenbaum_in_tcs`
  - `maximal_tcs_is_mcs`

## References

- Plan: `specs/881_modally_saturated_bmcs_construction/plans/implementation-001.md`
- Phase 3 findings: All families need temporal coherence; constant + temporally saturated works
- TemporalLindenbaum.lean: Provides henkinLimit and temporalSetLindenbaum
