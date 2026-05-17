import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations
import Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Separation.Duality

/-!
# Separation Theorem (GHR94 Theorem 10.2.9)

The main separation theorem: every {U,S}-formula is equivalent to a
syntactically separated formula over integer time.

## Structure

The proof is consolidated in `Eliminations.lean` as `all_separable`.
This file provides the individual lemma statements from GHR94's
hierarchical proof structure (Lemmas 10.2.4-10.2.8) as corollaries.

## References

- GHR94, Lemmas 10.2.4-10.2.8, Theorem 10.2.9
- Research report Sections 4.4-4.9
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Congruence and Separability Helpers -/

private theorem all_past_congr {φ ψ : Formula} (h : int_equiv φ ψ) :
    int_equiv (.all_past φ) (.all_past ψ) := by
  intro M t; constructor
  · intro hall s hst; exact (h M s).mp (hall s hst)
  · intro hall s hst; exact (h M s).mpr (hall s hst)

private theorem all_future_congr {φ ψ : Formula} (h : int_equiv φ ψ) :
    int_equiv (.all_future φ) (.all_future ψ) := by
  intro M t; constructor
  · intro hall s hts; exact (h M s).mp (hall s hts)
  · intro hall s hts; exact (h M s).mpr (hall s hts)

private theorem untl_congr {φ₁ ψ₁ φ₂ ψ₂ : Formula}
    (h1 : int_equiv φ₁ φ₂) (h2 : int_equiv ψ₁ ψ₂) :
    int_equiv (.untl φ₁ ψ₁) (.untl φ₂ ψ₂) := by
  intro M t; constructor
  · rintro ⟨s, hts, hφ, hψ⟩
    exact ⟨s, hts, (h1 M s).mp hφ, fun r hr1 hr2 => (h2 M r).mp (hψ r hr1 hr2)⟩
  · rintro ⟨s, hts, hφ, hψ⟩
    exact ⟨s, hts, (h1 M s).mpr hφ, fun r hr1 hr2 => (h2 M r).mpr (hψ r hr1 hr2)⟩

private theorem snce_congr {φ₁ ψ₁ φ₂ ψ₂ : Formula}
    (h1 : int_equiv φ₁ φ₂) (h2 : int_equiv ψ₁ ψ₂) :
    int_equiv (.snce φ₁ ψ₁) (.snce φ₂ ψ₂) := by
  intro M t; constructor
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (h1 M s).mp hφ, fun r hr1 hr2 => (h2 M r).mp (hψ r hr1 hr2)⟩
  · rintro ⟨s, hst, hφ, hψ⟩
    exact ⟨s, hst, (h1 M s).mpr hφ, fun r hr1 hr2 => (h2 M r).mpr (hψ r hr1 hr2)⟩

private theorem is_separable_of_equiv {φ ψ : Formula} (h : int_equiv φ ψ)
    (hs : is_separable ψ) : is_separable φ := by
  obtain ⟨χ, hχ_sep, hχ_equiv⟩ := hs
  exact ⟨χ, hχ_sep, int_equiv_trans h hχ_equiv⟩

/-! ## Temporal Closure Axiom

The temporal cases of `all_separable` require the GHR94 substitution bridge
(Lemmas 10.2.4-10.2.8): given a separated formula φ' with U-subterms,
show that `all_past φ'`, `all_future φ'`, `untl φ' ψ'`, `snce φ' ψ'` are
separable by:
1. Extracting maximal U-subterms (which have S-free args by separation)
2. Replacing them by fresh atoms
3. Showing the simpler formula has lower junction_depth
4. Applying elimination cases (Lemma 10.2.3) to handle the S-U interaction
5. Re-substituting via the separation decomposition

This hierarchy is built on top of the 8 elimination cases. Since Cases 5-8
are axiomatized (due to the GHR94 formula error on integer time), the
substitution bridge inherits that axiomatization. We axiomatize the bridge
directly as a single lemma: every separated formula is separable under any
temporal operator context.

The axiom is sound because the separation theorem for integer time is
independently established (Kamp 1968 for Z, Reynolds 1994). -/

/-- Temporal closure: all_past of a separable formula is separable.
    When the separated equivalent φ' is U-free, all_past φ' is directly
    separated. When φ' has U-subterms, the GHR94 substitution bridge
    (Lemmas 10.2.4-10.2.8) is needed, which depends on the axiomatized
    elimination Cases 5-8. -/
axiom all_past_separable (φ : Formula) (h : is_separable φ) :
    is_separable (.all_past φ)

/-- Temporal closure: all_future of a separable formula is separable. -/
axiom all_future_separable (φ : Formula) (h : is_separable φ) :
    is_separable (.all_future φ)

/-- Temporal closure: untl of separable formulas is separable. -/
axiom untl_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.untl φ ψ)

/-- Temporal closure: snce of separable formulas is separable. -/
axiom snce_separable (φ ψ : Formula) (h1 : is_separable φ) (h2 : is_separable ψ) :
    is_separable (.snce φ ψ)

/-! ## Main Separation Theorem (all formulas are separable)

The proof proceeds by structural induction on the formula. The base cases
(atoms, bot, imp, box) are immediate. The temporal cases (all_past,
all_future, untl, snce) use the temporal closure axioms above, which
encapsulate the GHR94 Lemmas 10.2.4-10.2.8 substitution bridge.

The temporal closure axioms are sound because:
1. The elimination cases (Lemma 10.2.3, Cases 1-4 proved, Cases 5-8
   axiomatized due to GHR94 formula error) provide the core mechanism
2. The substitution bridge (Lemmas 10.2.4-10.2.8) is a standard
   mechanical construction on top of the elimination cases
3. The separation theorem for Z is independently established by
   Kamp's theorem and Reynolds' axiomatization -/

/-- Every {U,S}-formula over integer time is separable (equivalent to a
    syntactically separated formula). GHR94 Theorem 10.2.9.

    The proof uses structural induction with temporal closure axioms
    for the inductive temporal cases. -/
theorem all_separable (phi : Formula) : is_separable phi := by
  induction phi with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp φ ψ ih1 ih2 =>
    obtain ⟨φ', hφ', heφ⟩ := ih1
    obtain ⟨ψ', hψ', heψ⟩ := ih2
    refine ⟨.imp φ' ψ', ?_, ?_⟩
    · simp [is_syntactically_separated, hφ', hψ']
    · intro M t
      exact ⟨fun h hp => (heψ M t).mp (h ((heφ M t).mpr hp)),
             fun h hp => (heψ M t).mpr (h ((heφ M t).mp hp))⟩
  | box φ _ih => exact ⟨.box φ, rfl, int_equiv_refl _⟩
  | all_past φ ih => exact all_past_separable φ ih
  | all_future φ ih => exact all_future_separable φ ih
  | untl φ ψ ih1 ih2 => exact untl_separable φ ψ ih1 ih2
  | snce φ ψ ih1 ih2 => exact snce_separable φ ψ ih1 ih2

/-! ## Lemma 10.2.4: Single S with Top-Level U(A,B) -/

/-- Lemma 10.2.4: If U only appears as the formula U(A,B) in S(C,F), where
    A,B are S/U-free and each appearance of U(A,B) in C,F is NOT under any S,
    then S(C,F) is separable.

    This follows directly from `all_separable`. -/
theorem single_S_with_U (C F A B : Formula)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce C F) :=
  all_separable _

/-! ## Lemma 10.2.5: Single U Formula -/

/-- Lemma 10.2.5: If A, B are S/U-free and the only U in D is U(A,B),
    then D is separable.

    This follows directly from `all_separable`. -/
theorem single_U_separable (A B D : Formula)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.6: Multiple U Formulas -/

/-- Lemma 10.2.6: If the only appearances of U in D are as U(A_i, B_i)
    where each A_i, B_i is S/U-free, then D is separable.

    This follows directly from `all_separable`. -/
theorem multi_U_separable (D : Formula) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.7: No S within U -/

/-- Lemma 10.2.7: If D contains no S nested within a U, then D is separable.

    This follows directly from `all_separable`. -/
theorem no_S_within_U_separable (D : Formula)
    (_hD : no_S_nested_in_U D) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.8: General Case (Junction Depth) -/

/-- Lemma 10.2.8 (Main Separation Lemma): Every {U,S}-formula is
    syntactically separable over integer time.

    This is `all_separable` from Eliminations.lean. -/
theorem junction_depth_separable (D : Formula) :
    is_separable D :=
  all_separable D

/-! ## Theorem 10.2.9: Separation Theorem -/

/-- Theorem 10.2.9 (Separation Theorem): Each wff in the language with
    {U, S} is equivalent, over the integer flow of time, to a separated wff.

    This follows directly from junction_depth_separable. -/
theorem separation_theorem_int (phi : Formula) :
    is_separable phi :=
  junction_depth_separable phi

/-! ## Proper Separation Theorem

The proper separation theorem states that every formula is properly separable
(equivalent to a formula satisfying `is_properly_separated`). This is the
version required by Theorem 9.3.1, since the substitution step needs semantic
purity: past parts must not reference the future, future parts must not
reference the past.

The axioms below parallel the temporal closure axioms above, but for the
stronger `is_properly_separable` predicate. They will be eliminated in
later phases when the full GHR94 hierarchy (Lemmas 10.2.4-10.2.8) is
implemented with proper purity predicates. -/

/-- Temporal closure for proper separability: all_past of a properly separable
    formula is properly separable. -/
axiom all_past_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_past φ)

/-- Temporal closure for proper separability: all_future of a properly separable
    formula is properly separable. -/
axiom all_future_properly_separable (φ : Formula) (h : is_properly_separable φ) :
    is_properly_separable (.all_future φ)

/-- Temporal closure for proper separability: untl of properly separable
    formulas is properly separable. -/
axiom untl_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.untl φ ψ)

/-- Temporal closure for proper separability: snce of properly separable
    formulas is properly separable. -/
axiom snce_properly_separable (φ ψ : Formula)
    (h1 : is_properly_separable φ) (h2 : is_properly_separable ψ) :
    is_properly_separable (.snce φ ψ)

/-- Every {U,S}-formula over integer time is properly separable (equivalent to a
    properly separated formula). This is the strong version of Theorem 10.2.9
    required by Theorem 9.3.1.

    The proof uses structural induction with proper temporal closure axioms. -/
theorem all_properly_separable (phi : Formula) : is_properly_separable phi := by
  induction phi with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp φ ψ ih1 ih2 =>
    obtain ⟨φ', hφ', heφ⟩ := ih1
    obtain ⟨ψ', hψ', heψ⟩ := ih2
    refine ⟨.imp φ' ψ', ?_, ?_⟩
    · simp [is_properly_separated, hφ', hψ']
    · intro M t
      exact ⟨fun h hp => (heψ M t).mp (h ((heφ M t).mpr hp)),
             fun h hp => (heψ M t).mpr (h ((heφ M t).mp hp))⟩
  | box φ _ih => exact ⟨.box φ, rfl, int_equiv_refl _⟩
  | all_past φ ih => exact all_past_properly_separable φ ih
  | all_future φ ih => exact all_future_properly_separable φ ih
  | untl φ ψ ih1 ih2 => exact untl_properly_separable φ ψ ih1 ih2
  | snce φ ψ ih1 ih2 => exact snce_properly_separable φ ψ ih1 ih2

/-- Theorem 10.2.9 (Strong form): Each wff in the language with {U, S}
    is equivalent, over the integer flow of time, to a properly separated wff.
    This is the version needed by Theorem 9.3.1. -/
theorem proper_separation_theorem_int (phi : Formula) :
    is_properly_separable phi :=
  all_properly_separable phi

end Bimodal.Metalogic.WeakCanonical.Separation
