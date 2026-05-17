import Bimodal.Metalogic.WeakCanonical.Separation.Defs

/-!
# Temporal Duality for Integer Semantics

Establishes the `swap_temporal` duality principle for integer semantics,
enabling automatic derivation of "S out of U" cases from "U out of S" cases.

## Key Results

- `IntStructure.reverse`: Flip time direction
- `swap_temporal_int_truth`: Truth is preserved under reversal + swap
- `dual_equiv`: If phi equiv psi then swap(phi) equiv swap(psi)
- `dual_U_free_iff_S_free`: U-free after swap iff S-free before
- `dual_separated`: Separation is preserved by swap

## References

- GHR94 Chapter 10.2: The duality principle halves the proof burden
  (8 cases for "U out of S" automatically give 8 cases for "S out of U")
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Time Reversal -/

/-- Reverse an integer structure: flip the time direction.
    If M interprets atom a as the set S, then M.reverse interprets a
    as {-s | s in S}. -/
def IntStructure.reverse (M : IntStructure) : IntStructure where
  val a := {t | -t ∈ M.val a}

/-- Reversing twice gives back the original structure. -/
theorem IntStructure.reverse_reverse (M : IntStructure) :
    M.reverse.reverse = M := by
  cases M with | mk val =>
  simp only [IntStructure.reverse]
  congr 1
  funext a
  ext t
  simp [Set.mem_setOf_eq, neg_neg]

/-! ## Duality Theorem -/

/-- The core duality theorem: truth of swap_temporal phi in M at t
    is equivalent to truth of phi in M.reverse at -t.

    This captures the fact that swapping U<->S and past<->future
    is semantically equivalent to reversing the time direction. -/
theorem swap_temporal_int_truth (M : IntStructure) (t : Int) (phi : Formula) :
    int_truth M t phi.swap_temporal ↔ int_truth M.reverse (-t) phi := by
  induction phi generalizing t with
  | atom a =>
    simp [Formula.swap_temporal, int_truth, IntStructure.reverse, Set.mem_setOf_eq, neg_neg]
  | bot => simp [Formula.swap_temporal, int_truth]
  | imp phi psi ih1 ih2 =>
    simp only [Formula.swap_temporal, int_truth]
    rw [ih1, ih2]
  | box phi _ih =>
    simp [Formula.swap_temporal, int_truth]
  | all_past phi ih =>
    simp only [Formula.swap_temporal, int_truth]
    constructor
    · intro h s hts
      have := h (-s) (by omega)
      rw [ih] at this
      simpa [neg_neg] using this
    · intro h s hts
      rw [ih]
      have := h (-s) (by omega)
      simpa [neg_neg] using this
  | all_future phi ih =>
    simp only [Formula.swap_temporal, int_truth]
    constructor
    · intro h s hts
      have := h (-s) (by omega)
      rw [ih] at this
      simpa [neg_neg] using this
    · intro h s hts
      rw [ih]
      have := h (-s) (by omega)
      simpa [neg_neg] using this
  | untl phi psi ih1 ih2 =>
    -- swap_temporal (untl phi psi) = snce (swap phi) (swap psi)
    -- int_truth M t (snce (swap phi) (swap psi)) = exists s < t, ...
    -- int_truth M.reverse (-t) (untl phi psi) = exists s > -t, ...
    simp only [Formula.swap_temporal, int_truth]
    constructor
    · rintro ⟨s, hst, h1, h2⟩
      refine ⟨-s, by omega, ?_, ?_⟩
      · rw [ih1] at h1; simpa [neg_neg] using h1
      · intro r hr1 hr2
        have := h2 (-r) (by omega) (by omega)
        rw [ih2] at this
        simpa [neg_neg] using this
    · rintro ⟨s, hts, h1, h2⟩
      refine ⟨-s, by omega, ?_, ?_⟩
      · rw [ih1]; simpa [neg_neg] using h1
      · intro r hr1 hr2
        rw [ih2]
        have := h2 (-r) (by omega) (by omega)
        simpa [neg_neg] using this
  | snce phi psi ih1 ih2 =>
    -- swap_temporal (snce phi psi) = untl (swap phi) (swap psi)
    -- int_truth M t (untl (swap phi) (swap psi)) = exists s > t, ...
    -- int_truth M.reverse (-t) (snce phi psi) = exists s < -t, ...
    simp only [Formula.swap_temporal, int_truth]
    constructor
    · rintro ⟨s, hts, h1, h2⟩
      refine ⟨-s, by omega, ?_, ?_⟩
      · rw [ih1] at h1; simpa [neg_neg] using h1
      · intro r hr1 hr2
        have := h2 (-r) (by omega) (by omega)
        rw [ih2] at this
        simpa [neg_neg] using this
    · rintro ⟨s, hst, h1, h2⟩
      refine ⟨-s, by omega, ?_, ?_⟩
      · rw [ih1]; simpa [neg_neg] using h1
      · intro r hr1 hr2
        rw [ih2]
        have := h2 (-r) (by omega) (by omega)
        simpa [neg_neg] using this

/-! ## Derived Duality Results -/

/-- If phi is equivalent to psi over Z, then swap(phi) is equivalent to swap(psi). -/
theorem dual_equiv (phi psi : Formula) (h : int_equiv phi psi) :
    int_equiv phi.swap_temporal psi.swap_temporal := by
  intro M t
  constructor
  · intro h1
    exact (swap_temporal_int_truth M t psi).mpr ((h M.reverse (-t)).mp
      ((swap_temporal_int_truth M t phi).mp h1))
  · intro h2
    exact (swap_temporal_int_truth M t phi).mpr ((h M.reverse (-t)).mpr
      ((swap_temporal_int_truth M t psi).mp h2))

/-- U-free after swap is the same as S-free before swap. -/
theorem dual_U_free_iff_S_free (phi : Formula) :
    is_U_free phi.swap_temporal = is_S_free phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free, ih1, ih2]
  | box a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | all_past a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | all_future a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | untl a b ih1 ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free, ih1, ih2]
  | snce a b _ih1 _ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free]

/-- S-free after swap is the same as U-free before swap. -/
theorem dual_S_free_iff_U_free (phi : Formula) :
    is_S_free phi.swap_temporal = is_U_free phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free, ih1, ih2]
  | box a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | all_past a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | all_future a ih => simp [Formula.swap_temporal, is_U_free, is_S_free, ih]
  | untl a b _ih1 _ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free]
  | snce a b ih1 ih2 => simp [Formula.swap_temporal, is_U_free, is_S_free, ih1, ih2]

/-- Syntactic separation is preserved by swap_temporal. -/
theorem dual_separated (phi : Formula) :
    is_syntactically_separated phi.swap_temporal = is_syntactically_separated phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [Formula.swap_temporal, is_syntactically_separated, ih1, ih2]
  | box _a => simp [Formula.swap_temporal, is_syntactically_separated]
  | all_past a _ih =>
    simp [Formula.swap_temporal, is_syntactically_separated]
    exact dual_S_free_iff_U_free a
  | all_future a _ih =>
    simp [Formula.swap_temporal, is_syntactically_separated]
    exact dual_U_free_iff_S_free a
  | untl a b _ih1 _ih2 =>
    simp [Formula.swap_temporal, is_syntactically_separated]
    rw [dual_U_free_iff_S_free a, dual_U_free_iff_S_free b]
  | snce a b _ih1 _ih2 =>
    simp [Formula.swap_temporal, is_syntactically_separated]
    rw [dual_S_free_iff_U_free a, dual_S_free_iff_U_free b]

/-- If phi is separable, then swap(phi) is also separable. -/
theorem dual_separable (phi : Formula) (h : is_separable phi) :
    is_separable phi.swap_temporal := by
  obtain ⟨psi, hsep, hequiv⟩ := h
  refine ⟨psi.swap_temporal, ?_, dual_equiv phi psi hequiv⟩
  rw [dual_separated]
  exact hsep

end Bimodal.Metalogic.WeakCanonical.Separation
