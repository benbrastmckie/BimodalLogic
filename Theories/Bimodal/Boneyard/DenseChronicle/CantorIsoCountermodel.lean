/-!
# ARCHIVED: Cantor Isomorphism Countermodel Pathway

**Status**: Reference only — NOT imported by active modules.
**Origin**: Extracted from ChronicleToCountermodel.lean (task 117).
**Purpose**: Preserve Cantor iso pathway for reference or alternative formalization approaches.

This file contains the Cantor isomorphism pathway for building the countermodel:
- `cantor_iso`: OrderIso from LimitDomSubtype to Rat (via Order.iso_of_countable_dense)
- `cantor_f`: MCS assignment via cantor_iso.symm
- `cantor_zero`, `cantor_f_at_zero`, `cantor_f_is_mcs`
- `cantor_fmcs`, `shifted_cantor_fmcs`, `rooted_cantor_fmcs`
- `box_stable_in_rooted_cantor_fmcs`
- `cantor_bfmcs` with modal_forward/modal_backward
- `cantor_bfmcs_restricted_tc`, `cantor_bfmcs_restricted_buc`, `cantor_bfmcs_restricted_fuc`
- `dd_countermodel_chronicle` (original version using cantor_bfmcs)

The Cantor isomorphism approach requires DenselyOrdered on LimitDomSubtype,
which in turn requires limit_dom_dense, which depends on the density counterexample
kind. Since density was removed (due to the unprovable sorry for SetConsistent g),
this entire pathway is replaced by the natural inclusion approach (X ⊂ Q).

## Old Imports (for reference)

```
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Data.Rat.Encodable
```

## Restore Instructions

To restore the Cantor pathway:
1. Restore density support (see DenseCounterexampleElimination.lean)
2. Restore limit_dom_dense (see DenseLimitDomain.lean)
3. Add back the imports listed above
4. Re-add all definitions and theorems from this file to ChronicleToCountermodel.lean
5. Prove SetConsistent (χ.g x y) in the density branch
-/

-- THIS FILE DOES NOT BUILD. It is archived reference code only.
-- Do not add to any lakefile or import list.

#exit

/-
-- Full Cantor isomorphism pathway (ChronicleToCountermodel.lean lines 174-709):

noncomputable def cantor_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    LimitDomSubtype A h_mcs ≃o Rat :=
  Classical.choice (Order.iso_of_countable_dense (LimitDomSubtype A h_mcs) Rat)

noncomputable def cantor_f (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    Rat → Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso A h_mcs).symm q).val

noncomputable def cantor_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    : Rat :=
  (cantor_iso A h_mcs) ⟨0, zero_mem_limit_dom A h_mcs⟩

theorem cantor_f_at_zero (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    cantor_f A h_mcs (cantor_zero A h_mcs) = A := by
  unfold cantor_f cantor_zero
  simp [OrderIso.symm_apply_apply]
  exact limit_f_zero A h_mcs

theorem cantor_f_is_mcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (q : Rat) : SetMaximalConsistent (cantor_f A h_mcs q) := by
  unfold cantor_f
  exact limit_c0 A h_mcs _ ((cantor_iso A h_mcs).symm q).property

noncomputable def cantor_fmcs (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    FMCS Rat where
  mcs := cantor_f A h_mcs
  is_mcs := cantor_f_is_mcs A h_mcs
  forward_G := by
    intro t t' φ h_lt h_G
    have h_lt_dom := (cantor_iso A h_mcs).symm.strictMono h_lt
    exact limit_forward_G A h_mcs
      ((cantor_iso A h_mcs).symm t).val
      ((cantor_iso A h_mcs).symm t').val
      ((cantor_iso A h_mcs).symm t).property
      ((cantor_iso A h_mcs).symm t').property
      h_lt_dom φ h_G
  backward_H := by
    intro t t' φ h_lt h_H
    have h_lt_dom := (cantor_iso A h_mcs).symm.strictMono h_lt
    exact limit_backward_H A h_mcs
      ((cantor_iso A h_mcs).symm t).val
      ((cantor_iso A h_mcs).symm t').val
      ((cantor_iso A h_mcs).symm t).property
      ((cantor_iso A h_mcs).symm t').property
      h_lt_dom φ h_H

-- ... shifted_cantor_fmcs, rooted_cantor_fmcs, box_stable_in_rooted_cantor_fmcs ...
-- ... cantor_bfmcs, cantor_bfmcs_restricted_tc/buc/fuc ...
-- ... dd_countermodel_chronicle ...
-- See git history for the complete code (~540 lines).
-/
