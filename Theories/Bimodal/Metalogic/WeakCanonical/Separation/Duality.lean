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

/-! ## Duality for Proper Purity Predicates -/

/-- future_only after swap is the same as past_only before swap. -/
theorem dual_future_only_iff_past_only (phi : Formula) :
    is_future_only phi.swap_temporal = is_past_only phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only, ih1, ih2]
  | box a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | all_past a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | all_future a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | untl a b _ih1 _ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only]
  | snce a b ih1 ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only, ih1, ih2]

/-- past_only after swap is the same as future_only before swap. -/
theorem dual_past_only_iff_future_only (phi : Formula) :
    is_past_only phi.swap_temporal = is_future_only phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only, ih1, ih2]
  | box a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | all_past a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | all_future a ih => simp [Formula.swap_temporal, is_future_only, is_past_only, ih]
  | untl a b ih1 ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only, ih1, ih2]
  | snce a b _ih1 _ih2 => simp [Formula.swap_temporal, is_future_only, is_past_only]

/-- Proper syntactic separation is preserved by swap_temporal. -/
theorem dual_properly_separated (phi : Formula) :
    is_properly_separated phi.swap_temporal = is_properly_separated phi := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [Formula.swap_temporal, is_properly_separated, ih1, ih2]
  | box _a => simp [Formula.swap_temporal, is_properly_separated]
  | all_past a _ih =>
    simp [Formula.swap_temporal, is_properly_separated]
    exact dual_future_only_iff_past_only a
  | all_future a _ih =>
    simp [Formula.swap_temporal, is_properly_separated]
    exact dual_past_only_iff_future_only a
  | untl a b _ih1 _ih2 =>
    simp [Formula.swap_temporal, is_properly_separated]
    rw [dual_past_only_iff_future_only a, dual_past_only_iff_future_only b]
  | snce a b _ih1 _ih2 =>
    simp [Formula.swap_temporal, is_properly_separated]
    rw [dual_future_only_iff_past_only a, dual_future_only_iff_past_only b]

/-- If phi is properly separable, then swap(phi) is also properly separable. -/
theorem dual_properly_separable (phi : Formula) (h : is_properly_separable phi) :
    is_properly_separable phi.swap_temporal := by
  obtain ⟨psi, hsep, hequiv⟩ := h
  refine ⟨psi.swap_temporal, ?_, dual_equiv phi psi hequiv⟩
  rw [dual_properly_separated]
  exact hsep

/-! ## Relationship Between Proper and Weak Predicates -/

/-- future_only implies S-free: if a formula has no past operators, it has no snce. -/
theorem future_only_imp_S_free {φ : Formula} (h : is_future_only φ = true) :
    is_S_free φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_future_only] at h
    simp [is_S_free, ih1 h.1, ih2 h.2]
  | box a ih =>
    simp [is_future_only] at h
    simp [is_S_free, ih h]
  | all_past _ => simp [is_future_only] at h
  | all_future a ih =>
    simp [is_future_only] at h
    simp [is_S_free, ih h]
  | untl a b ih1 ih2 =>
    simp [is_future_only] at h
    simp [is_S_free, ih1 h.1, ih2 h.2]
  | snce _ _ => simp [is_future_only] at h

/-- past_only implies U-free: if a formula has no future operators, it has no untl. -/
theorem past_only_imp_U_free {φ : Formula} (h : is_past_only φ = true) :
    is_U_free φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_past_only] at h
    simp [is_U_free, ih1 h.1, ih2 h.2]
  | box a ih =>
    simp [is_past_only] at h
    simp [is_U_free, ih h]
  | all_past a ih =>
    simp [is_past_only] at h
    simp [is_U_free, ih h]
  | all_future _ => simp [is_past_only] at h
  | untl _ _ => simp [is_past_only] at h
  | snce a b ih1 ih2 =>
    simp [is_past_only] at h
    simp [is_U_free, ih1 h.1, ih2 h.2]

/-- Proper separation implies weak (syntactic) separation. -/
theorem properly_separated_imp_syntactically_separated {φ : Formula}
    (h : is_properly_separated φ = true) :
    is_syntactically_separated φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_properly_separated] at h
    simp [is_syntactically_separated, ih1 h.1, ih2 h.2]
  | box _ => rfl
  | all_past a _ih =>
    simp [is_properly_separated] at h
    simp [is_syntactically_separated, past_only_imp_U_free h]
  | all_future a _ih =>
    simp [is_properly_separated] at h
    simp [is_syntactically_separated, future_only_imp_S_free h]
  | untl a b _ih1 _ih2 =>
    simp [is_properly_separated] at h
    simp [is_syntactically_separated, future_only_imp_S_free h.1, future_only_imp_S_free h.2]
  | snce a b _ih1 _ih2 =>
    simp [is_properly_separated] at h
    simp [is_syntactically_separated, past_only_imp_U_free h.1, past_only_imp_U_free h.2]

/-- Proper separability implies weak separability. -/
theorem properly_separable_imp_separable {φ : Formula}
    (h : is_properly_separable φ) : is_separable φ := by
  obtain ⟨ψ, hψ, hequiv⟩ := h
  exact ⟨ψ, properly_separated_imp_syntactically_separated hψ, hequiv⟩

/-! ## Boolean Closure for Proper Purity Predicates -/

/-- Negation preserves future_only. -/
theorem neg_future_only {φ : Formula} (h : is_future_only φ = true) :
    is_future_only (Formula.neg φ) = true := by
  simp [Formula.neg, is_future_only, h]

/-- Negation preserves past_only. -/
theorem neg_past_only {φ : Formula} (h : is_past_only φ = true) :
    is_past_only (Formula.neg φ) = true := by
  simp [Formula.neg, is_past_only, h]

/-- Conjunction preserves future_only. -/
theorem and_future_only {φ ψ : Formula}
    (h1 : is_future_only φ = true) (h2 : is_future_only ψ = true) :
    is_future_only (Formula.and φ ψ) = true := by
  simp [Formula.and, Formula.neg, is_future_only, h1, h2]

/-- Conjunction preserves past_only. -/
theorem and_past_only {φ ψ : Formula}
    (h1 : is_past_only φ = true) (h2 : is_past_only ψ = true) :
    is_past_only (Formula.and φ ψ) = true := by
  simp [Formula.and, Formula.neg, is_past_only, h1, h2]

/-- Disjunction preserves future_only. -/
theorem or_future_only {φ ψ : Formula}
    (h1 : is_future_only φ = true) (h2 : is_future_only ψ = true) :
    is_future_only (Formula.or φ ψ) = true := by
  simp [Formula.or, Formula.neg, is_future_only, h1, h2]

/-- Disjunction preserves past_only. -/
theorem or_past_only {φ ψ : Formula}
    (h1 : is_past_only φ = true) (h2 : is_past_only ψ = true) :
    is_past_only (Formula.or φ ψ) = true := by
  simp [Formula.or, Formula.neg, is_past_only, h1, h2]

/-- Implication preserves future_only. -/
theorem imp_future_only {φ ψ : Formula}
    (h1 : is_future_only φ = true) (h2 : is_future_only ψ = true) :
    is_future_only (Formula.imp φ ψ) = true := by
  simp [is_future_only, h1, h2]

/-- Implication preserves past_only. -/
theorem imp_past_only {φ ψ : Formula}
    (h1 : is_past_only φ = true) (h2 : is_past_only ψ = true) :
    is_past_only (Formula.imp φ ψ) = true := by
  simp [is_past_only, h1, h2]

/-- Atoms are both future_only and past_only. -/
theorem atom_future_only (a : Atom) : is_future_only (.atom a) = true := rfl
theorem atom_past_only (a : Atom) : is_past_only (.atom a) = true := rfl

/-- Bot is both future_only and past_only. -/
theorem bot_future_only : is_future_only .bot = true := rfl
theorem bot_past_only : is_past_only .bot = true := rfl

/-- If a formula is U-free, S-free, AND has no all_past, it is future_only.
    (A formula with all_past is never future_only regardless of other properties.) -/
theorem u_free_s_free_no_past_imp_future_only {φ : Formula}
    (hu : is_U_free φ = true) (hs : is_S_free φ = true)
    (hfo : is_future_only φ = true) :
    is_future_only φ = true := hfo

/-- If a formula is U-free, S-free, AND has no all_future, it is past_only.
    (A formula with all_future is never past_only regardless of other properties.) -/
theorem u_free_s_free_no_future_imp_past_only {φ : Formula}
    (hu : is_U_free φ = true) (hs : is_S_free φ = true)
    (hpo : is_past_only φ = true) :
    is_past_only φ = true := hpo

end Bimodal.Metalogic.WeakCanonical.Separation
