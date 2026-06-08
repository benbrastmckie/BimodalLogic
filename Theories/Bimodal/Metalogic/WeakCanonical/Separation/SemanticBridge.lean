import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
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

/-- S-free formulas are box-free. -/
theorem s_free_implies_box_free (φ : Formula) (h : is_S_free φ = true) :
    is_box_free φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_S_free] at h; simp [is_box_free, ih1 h.1, ih2 h.2]
  | box a ih =>
    simp [is_S_free] at h; simp [is_box_free]
  | untl a b ih1 ih2 =>
    simp [is_S_free] at h; simp [is_box_free, ih1 h.1, ih2 h.2]
  | snce _ _ => simp [is_S_free] at h

/-- U-free formulas are box-free. -/
theorem u_free_implies_box_free (φ : Formula) (h : is_U_free φ = true) :
    is_box_free φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_U_free] at h; simp [is_box_free, ih1 h.1, ih2 h.2]
  | box a ih =>
    simp [is_U_free] at h; simp [is_box_free]
  | untl _ _ => simp [is_U_free] at h
  | snce a b ih1 ih2 =>
    simp [is_U_free] at h; simp [is_box_free, ih1 h.1, ih2 h.2]

/-- Separated formulas are box-free. -/
theorem separated_implies_box_free (φ : Formula) (h : is_syntactically_separated φ = true) :
    is_box_free φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated] at h; simp [is_box_free, ih1 h.1, ih2 h.2]
  | box _ => simp [is_syntactically_separated] at h
  | untl a b _ _ =>
    simp [is_syntactically_separated] at h
    simp [is_box_free, s_free_implies_box_free a h.1, s_free_implies_box_free b h.2]
  | snce a b _ _ =>
    simp [is_syntactically_separated] at h
    simp [is_box_free, u_free_implies_box_free a h.1, u_free_implies_box_free b h.2]

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

/-! ## Transfer through Order Isomorphisms

For Prior structures with arbitrary carriers, we transfer temporal_truth
through an order isomorphism to Z.
-/

/--
`temporal_truth` transfers through order isomorphisms: if `f : α ≃o β` is an
order isomorphism and M, N are ordered monadic structures on α, β respectively
with matching predicate interpretations, then temporal_truth agrees.
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
      exact ⟨f s, f.lt_iff_lt.mpr hts,
        (ih₁ s h_bf.1).mp hψ₁,
        fun r htr hrs => by
          have := hψ₂ (f.symm r) (by rwa [f.lt_iff_lt, f.apply_symm_apply])
            (by rwa [f.lt_iff_lt, f.apply_symm_apply])
          rwa [ih₂ (f.symm r) h_bf.2, show f (f.symm r) = r from f.apply_symm_apply r] at this⟩
    · rintro ⟨s, hts, hψ₁, hψ₂⟩
      exact ⟨f.symm s, by rwa [f.lt_iff_lt, f.apply_symm_apply],
        by rwa [show f (f.symm s) = s from f.apply_symm_apply s] at hψ₁;
           exact (ih₁ (f.symm s) h_bf.1).mpr hψ₁,
        fun r htr hrs => by
          have := hψ₂ (f r) (by rwa [f.lt_iff_lt]) (by rwa [f.lt_iff_lt, f.apply_symm_apply])
          exact (ih₂ r h_bf.2).mpr this⟩
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [is_box_free, Bool.and_eq_true] at h_bf
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hst, hψ₁, hψ₂⟩
      exact ⟨f s, f.lt_iff_lt.mpr hst,
        (ih₁ s h_bf.1).mp hψ₁,
        fun r hsr hrt => by
          have := hψ₂ (f.symm r) (by rwa [f.lt_iff_lt, f.apply_symm_apply])
            (by rwa [f.lt_iff_lt, f.apply_symm_apply])
          rwa [ih₂ (f.symm r) h_bf.2, show f (f.symm r) = r from f.apply_symm_apply r] at this⟩
    · rintro ⟨s, hst, hψ₁, hψ₂⟩
      exact ⟨f.symm s, by rwa [f.lt_iff_lt, f.apply_symm_apply],
        by rwa [show f (f.symm s) = s from f.apply_symm_apply s] at hψ₁;
           exact (ih₁ (f.symm s) h_bf.1).mpr hψ₁,
        fun r hsr hrt => by
          have := hψ₂ (f r) (by rwa [f.lt_iff_lt]) (by rwa [f.lt_iff_lt, f.apply_symm_apply])
          exact (ih₂ r h_bf.2).mpr this⟩

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
  let N : OrderedMonadicStructure sig :=
    ⟨⟨ℤ, fun p z => M.interp p (iso.symm z)⟩, inferInstance⟩
  -- Transfer M to N (Z-carrier) via iso
  rw [temporal_truth_order_iso M atomMap iso t φ h_bf_φ,
      temporal_truth_order_iso M atomMap iso t ψ h_bf_ψ]
  -- On N (Z-carrier), use int_equiv
  let Z : ZStructure sig := ⟨fun p z => M.interp p (iso.symm z)⟩
  -- N = Z.toOrdered sig
  have hN : N = Z.toOrdered sig := rfl
  rw [hN]
  exact int_equiv_implies_temporal_equiv_Z φ ψ h_equiv h_bf_φ h_bf_ψ Z atomMap (iso t)

end Bimodal.Metalogic.WeakCanonical.Separation
