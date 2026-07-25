/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Table

/-!
# Semantic Bridge: IntStructure ↔ ZStructure/OrderedMonadicStructure

Connects `IntStructure`/`int_truth` (separation framework) with
`OrderedMonadicStructure`/`temporal_truth` (completeness framework).

## Key Results

- `z_structure_to_int`: IntStructure from ZStructure + atomMap
- `int_truth_eq_temporal_truth_Z`: int_truth matches temporal_truth on Z-carrier
- `int_equiv_implies_temporal_equiv_Z`: int_equiv → temporal_truth equivalence
- `temporal_truth_order_iso`: temporal_truth transfers through order isomorphisms

## References

- GHR94 Chapter 10: Separation on integer time
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Construction -/

/-- Build an IntStructure from a ZStructure and atomMap. -/
def z_structure_to_int {sig : MonadicSignature}
    (Z : ZStructure sig) (atomMap : Formula → sig.preds) : IntStructure where
  val a := { t : ℤ | Z.interp (atomMap (.atom a)) t }

/-! ## Box-Free Formulas -/

/-- A formula is box-free: contains no `box` constructor. -/
def is_box_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_box_free φ && is_box_free ψ
  | .box _ => false
  | .untl φ ψ => is_box_free φ && is_box_free ψ
  | .snce φ ψ => is_box_free φ && is_box_free ψ

/-! ## Core Bridge: int_truth ↔ temporal_truth on Z-carrier -/

/--
For box-free formulas, `int_truth` on the IntStructure constructed from a ZStructure
agrees with `temporal_truth` on the corresponding OrderedMonadicStructure.
-/
theorem int_truth_eq_temporal_truth_Z {sig : MonadicSignature}
    (Z : ZStructure sig) (atomMap : Formula → sig.preds)
    (t : ℤ) (φ : Formula) (h_bf : is_box_free φ = true) :
    int_truth (z_structure_to_int Z atomMap) t φ ↔
    temporal_truth (Z.toOrdered sig) atomMap t φ := by
  induction φ generalizing t with
  | atom a =>
    simp only [int_truth, z_structure_to_int, Set.mem_setOf_eq,
               temporal_truth, ZStructure.toOrdered]
  | bot => simp [int_truth, temporal_truth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [int_truth, temporal_truth]
    exact Iff.imp (ih₁ t h_bf.1) (ih₂ t h_bf.2)
  | box _ => simp [is_box_free] at h_bf
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [int_truth, temporal_truth, ZStructure.toOrdered]
    exact ⟨fun ⟨s, hts, h1, h2⟩ => ⟨s, hts, (ih₁ s h_bf.1).mp h1,
        fun r htr hrs => (ih₂ r h_bf.2).mp (h2 r htr hrs)⟩,
      fun ⟨s, hts, h1, h2⟩ => ⟨s, hts, (ih₁ s h_bf.1).mpr h1,
        fun r htr hrs => (ih₂ r h_bf.2).mpr (h2 r htr hrs)⟩⟩
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [int_truth, temporal_truth, ZStructure.toOrdered]
    exact ⟨fun ⟨s, hst, h1, h2⟩ => ⟨s, hst, (ih₁ s h_bf.1).mp h1,
        fun r hsr hrt => (ih₂ r h_bf.2).mp (h2 r hsr hrt)⟩,
      fun ⟨s, hst, h1, h2⟩ => ⟨s, hst, (ih₁ s h_bf.1).mpr h1,
        fun r hsr hrt => (ih₂ r h_bf.2).mpr (h2 r hsr hrt)⟩⟩

/-! ## Transfer: int_equiv → temporal_truth on Z-structures -/

/--
If two box-free formulas are `int_equiv`, they have the same `temporal_truth`
on any Z-carrier ordered monadic structure.
-/
theorem int_equiv_implies_temporal_equiv_Z {sig : MonadicSignature}
    (φ ψ : Formula) (h_equiv : int_equiv φ ψ)
    (h_bf_φ : is_box_free φ = true) (h_bf_ψ : is_box_free ψ = true)
    (Z : ZStructure sig) (atomMap : Formula → sig.preds) (t : ℤ) :
    temporal_truth (Z.toOrdered sig) atomMap t φ ↔
    temporal_truth (Z.toOrdered sig) atomMap t ψ := by
  rw [← int_truth_eq_temporal_truth_Z Z atomMap t φ h_bf_φ,
      ← int_truth_eq_temporal_truth_Z Z atomMap t ψ h_bf_ψ]
  exact h_equiv (z_structure_to_int Z atomMap) t

/-! ## Transfer through Order Isomorphisms -/

/--
`temporal_truth` transfers through order isomorphisms for box-free formulas.
-/
theorem temporal_truth_order_iso {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (f : M.carrier ≃o ℤ)
    (t : M.carrier) (φ : Formula) (h_bf : is_box_free φ = true) :
    temporal_truth M atomMap t φ ↔
    temporal_truth (⟨⟨ℤ, fun p z => M.interp p (f.symm z)⟩,
      inferInstance⟩ : OrderedMonadicStructure sig) atomMap (f t) φ := by
  induction φ generalizing t with
  | atom a =>
    simp only [temporal_truth]
    exact ⟨fun h => by simpa using h, fun h => by simpa using h⟩
  | bot => simp [temporal_truth]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [temporal_truth]
    exact Iff.imp (ih₁ t h_bf.1) (ih₂ t h_bf.2)
  | box _ => simp [is_box_free] at h_bf
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hts, hψ₁, hψ₂⟩
      refine ⟨f s, f.lt_iff_lt.mpr hts, (ih₁ s h_bf.1).mp hψ₁, fun r htr hrs => ?_⟩
      have h1 : t < f.symm r := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      have h2 : f.symm r < s := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      have := hψ₂ (f.symm r) h1 h2
      rw [ih₂ (f.symm r) h_bf.2, show f (f.symm r) = r from f.apply_symm_apply r] at this
      exact this
    · rintro ⟨s, hts, hψ₁, hψ₂⟩
      have hts' : t < f.symm s := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      refine ⟨f.symm s, hts', ?_, fun r htr hrs => ?_⟩
      · -- hψ₁ : temporal_truth N atomMap s ψ₁, need temporal_truth M atomMap (f.symm s) ψ₁
        have := (ih₁ (f.symm s) h_bf.1).mpr
        rw [show f (f.symm s) = s from f.apply_symm_apply s] at this
        exact this hψ₁
      · have hfr_gt : f t < f r := f.lt_iff_lt.mpr htr
        have hfr_lt : f r < s := by
          rw [← f.apply_symm_apply s]; exact f.lt_iff_lt.mpr hrs
        have := hψ₂ (f r) hfr_gt hfr_lt
        exact (ih₂ r h_bf.2).mpr this
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hst, hψ₁, hψ₂⟩
      refine ⟨f s, f.lt_iff_lt.mpr hst, (ih₁ s h_bf.1).mp hψ₁, fun r hsr hrt => ?_⟩
      have h1 : f.symm r < t := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      have h2 : s < f.symm r := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      have := hψ₂ (f.symm r) h2 h1
      have h3 := (ih₂ (f.symm r) h_bf.2).mp this
      rwa [show f (f.symm r) = r from f.apply_symm_apply r] at h3
    · rintro ⟨s, hst, hψ₁, hψ₂⟩
      have hst' : f.symm s < t := by rwa [← f.lt_iff_lt, f.apply_symm_apply]
      refine ⟨f.symm s, hst', ?_, fun r hsr hrt => ?_⟩
      · have h3 := (ih₁ (f.symm s) h_bf.1).mpr
        rw [show f (f.symm s) = s from f.apply_symm_apply s] at h3
        exact h3 hψ₁
      · have hfr_lt : f r < f t := f.lt_iff_lt.mpr hrt
        have hfr_gt : s < f r := by
          rw [← f.apply_symm_apply s]; exact f.lt_iff_lt.mpr hsr
        have := hψ₂ (f r) hfr_gt hfr_lt
        exact (ih₂ r h_bf.2).mpr this

/--
Main bridge theorem: if `int_equiv φ ψ` and both are box-free, then for ANY
ordered monadic structure with an order isomorphism to Z, temporal_truth agrees.
-/
theorem int_equiv_implies_temporal_equiv_with_iso {sig : MonadicSignature}
    (φ ψ : Formula) (h_equiv : int_equiv φ ψ)
    (h_bf_φ : is_box_free φ = true) (h_bf_ψ : is_box_free ψ = true)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (iso : M.carrier ≃o ℤ) (t : M.carrier) :
    temporal_truth M atomMap t φ ↔ temporal_truth M atomMap t ψ := by
  rw [temporal_truth_order_iso M atomMap iso t φ h_bf_φ,
      temporal_truth_order_iso M atomMap iso t ψ h_bf_ψ]
  let Z : ZStructure sig := ⟨fun p z => M.interp p (iso.symm z)⟩
  exact int_equiv_implies_temporal_equiv_Z φ ψ h_equiv h_bf_φ h_bf_ψ Z atomMap (iso t)

end Bimodal.Metalogic.WeakCanonical.Separation
