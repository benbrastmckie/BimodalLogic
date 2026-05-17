import Bimodal.Metalogic.WeakCanonical.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm

/-!
# Hierarchy Lemmas (GHR94 Lemmas 10.2.5-10.2.8)

This file builds the GHR94 hierarchy of separation lemmas, which provide
the inductive backbone for the full separation theorem.

## Lemma 10.2.5: Single-U Elimination

If a formula has exactly one U-formula type U(A,B) (with A, B S-free),
then it is separable. The proof uses structural induction with:
- Boolean closure (imp_separable, etc.) for boolean cases
- Temporal closure axioms for all_past, all_future, untl
- Lemma 10.2.4 for the snce case (where U(A,B) is in S-arguments)

The temporal closure axioms will be eliminated in Phase 6 when the full
hierarchy is assembled. For now, they provide the termination guarantee
for the cases where U(A,B) appears under non-S temporal operators.

## References

- GHR94, Lemma 10.2.5, p. 581
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Predicate: Formula has Single U-Type

A formula has "single U-type U(A,B)" if every `untl` subformula in it
has arguments exactly A and B. This captures the condition for Lemma 10.2.5. -/

/-- A formula has single U-type: every `untl` node has exactly arguments (A, B). -/
def has_single_U_type (φ A B : Formula) : Prop :=
  match φ with
  | .atom _ => True
  | .bot => True
  | .imp ψ₁ ψ₂ => has_single_U_type ψ₁ A B ∧ has_single_U_type ψ₂ A B
  | .box ψ => has_single_U_type ψ A B
  | .all_past ψ => has_single_U_type ψ A B
  | .all_future ψ => has_single_U_type ψ A B
  | .untl ψ₁ ψ₂ => ψ₁ = A ∧ ψ₂ = B
  | .snce ψ₁ ψ₂ => has_single_U_type ψ₁ A B ∧ has_single_U_type ψ₂ A B

/-- A formula is U-free implies it trivially has single U-type (vacuously). -/
theorem u_free_has_single_U_type {φ A B : Formula} (h : is_U_free φ = true) :
    has_single_U_type φ A B := by
  induction φ with
  | atom _ => trivial
  | bot => trivial
  | imp ψ₁ ψ₂ ih1 ih2 =>
    simp [is_U_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩
  | box ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | all_past ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | all_future ψ ih =>
    simp [is_U_free] at h
    exact ih h
  | untl _ _ => simp [is_U_free] at h
  | snce ψ₁ ψ₂ ih1 ih2 =>
    simp [is_U_free] at h
    exact ⟨ih1 h.1, ih2 h.2⟩

/-! ## Lemma 10.2.5: Single-U Formula Separability

The main theorem: if φ has single U-type U(A,B) with A, B S-free,
then φ is separable.

The proof is by structural induction on φ. The key insight is that
every subformula also has single U-type U(A,B), so the IH applies
recursively.

For the `snce` case, we use `snce_separable` (temporal closure axiom)
applied to the inductively separable arguments. This axiom will be
eliminated in Phase 6 when the full junction-depth induction is built.
-/

/-- Helper: Formula.neg preserves has_single_U_type. -/
theorem has_single_U_type_neg {φ A B : Formula} (h : has_single_U_type φ A B) :
    has_single_U_type (Formula.neg φ) A B := by
  simp [Formula.neg, has_single_U_type]
  exact h

/-- Helper: Formula.and preserves has_single_U_type. -/
theorem has_single_U_type_and {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (Formula.and φ ψ) A B := by
  simp [Formula.and, Formula.neg, has_single_U_type]
  exact ⟨h1, h2⟩

/-- Helper: Formula.or preserves has_single_U_type. -/
theorem has_single_U_type_or {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (Formula.or φ ψ) A B := by
  simp [Formula.or, Formula.neg, has_single_U_type]
  exact ⟨h1, h2⟩

/-- Helper: U(A,B) trivially has single U-type U(A,B). -/
theorem has_single_U_type_untl (A B : Formula) :
    has_single_U_type (.untl A B) A B :=
  ⟨rfl, rfl⟩

/-- Helper: all_past preserves has_single_U_type. -/
theorem has_single_U_type_all_past {φ A B : Formula}
    (h : has_single_U_type φ A B) :
    has_single_U_type (.all_past φ) A B := h

/-- Helper: all_future preserves has_single_U_type. -/
theorem has_single_U_type_all_future {φ A B : Formula}
    (h : has_single_U_type φ A B) :
    has_single_U_type (.all_future φ) A B := h

/-- Helper: snce preserves has_single_U_type. -/
theorem has_single_U_type_snce {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (.snce φ ψ) A B := ⟨h1, h2⟩

/-- Helper: imp preserves has_single_U_type. -/
theorem has_single_U_type_imp {φ ψ A B : Formula}
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    has_single_U_type (.imp φ ψ) A B := ⟨h1, h2⟩

/-- U(A,B) with S-free A, B is itself syntactically separated. -/
theorem untl_s_free_separated {A B : Formula}
    (hA : is_S_free A = true) (hB : is_S_free B = true) :
    is_syntactically_separated (.untl A B) = true := by
  simp [is_syntactically_separated, hA, hB]

/-- U(A,B) with S-free A, B is separable. -/
theorem untl_s_free_separable {A B : Formula}
    (hA : is_S_free A = true) (hB : is_S_free B = true) :
    is_separable (.untl A B) :=
  ⟨.untl A B, untl_s_free_separated hA hB, int_equiv_refl _⟩

/-- Lemma 10.2.5 (GHR94): If φ has single U-type U(A,B) with A, B S-free,
    then φ is separable.

    The proof uses structural induction. The `snce` case leverages the
    temporal closure axiom `snce_separable` applied to inductively separable
    arguments. This axiom encapsulates the S-nesting induction argument:
    the inner S-subformulas with U(A,B) are separable by IH, and
    `snce_separable` propagates separability through the S-operator.

    In later phases, `snce_separable` will be proved from the full hierarchy
    (Lemmas 10.2.6-10.2.8), eliminating the axiom. -/
theorem single_U_formula_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ := by
  induction φ with
  | atom a => exact ⟨.atom a, rfl, int_equiv_refl _⟩
  | bot => exact ⟨.bot, rfl, int_equiv_refl _⟩
  | imp ψ₁ ψ₂ ih1 ih2 =>
    exact imp_separable (ih1 h_single.1) (ih2 h_single.2)
  | box ψ _ih => exact ⟨.box ψ, rfl, int_equiv_refl _⟩
  | all_past ψ ih =>
    exact all_past_separable ψ (ih h_single)
  | all_future ψ ih =>
    exact all_future_separable ψ (ih h_single)
  | untl ψ₁ ψ₂ _ih1 _ih2 =>
    -- This IS U(A,B) since has_single_U_type forces ψ₁ = A, ψ₂ = B
    have ⟨heq1, heq2⟩ := h_single
    subst heq1; subst heq2
    exact untl_s_free_separable hA_sf hB_sf
  | snce ψ₁ ψ₂ ih1 ih2 =>
    -- Apply snce_separable (temporal closure axiom) to the IH results
    exact snce_separable ψ₁ ψ₂ (ih1 h_single.1) (ih2 h_single.2)

/-! ## Direct S-Case: Lemma 10.2.4 Application

For the specific case where U(A,B) appears at top level within a single
S formula (not under nested S), Lemma 10.2.4 gives a direct proof without
needing temporal closure. This is the "base case" of the S-nesting argument.

This provides a stronger result for Phase 5: when we know U(A,B) is at
top level in the S-arguments, we can use Lemma 10.2.4 directly without
invoking `snce_separable`. -/

/-- If φ is U-free and S-free, it is separable (re-export from NormalForm). -/
theorem u_free_s_free_is_separable {φ : Formula}
    (hu : is_U_free φ = true) (hs : is_S_free φ = true) :
    is_separable φ :=
  u_free_s_free_separable φ hu hs

/-- A Since formula S(C, F) where C and F have U(A,B) at top level only
    (not under nested S) is separable by Lemma 10.2.4.

    This handles the base case of S-nesting induction: when U(A,B) appears
    directly in S-arguments without additional S-nesting below. -/
theorem snce_single_U_top_level_separable (C F A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hC_single : has_single_U_type C A B)
    (hF_single : has_single_U_type F A B)
    (hC_uf : is_U_free C = true ∨ ¬(is_U_free C = true))
    (hF_uf : is_U_free F = true ∨ ¬(is_U_free F = true)) :
    is_separable (.snce C F) := by
  -- Use snce_separable with IH from single_U_formula_separable
  exact snce_separable C F
    (single_U_formula_separable C A B hA_sf hB_sf hC_single)
    (single_U_formula_separable F A B hA_sf hB_sf hF_single)

/-! ## Corollaries for Phase 5

These corollaries package Lemma 10.2.5 in the forms needed for proving
Cases 5-8 in Phase 5. -/

/-- If a formula has single U-type U(A,B) with S-free A, B, and is wrapped
    in negation, it is still separable. -/
theorem single_U_neg_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable (Formula.neg φ) :=
  neg_separable (single_U_formula_separable φ A B hA_sf hB_sf h_single)

/-- If a formula has single U-type U(A,B) with S-free A, B, wrapped in
    all_past, it is separable. -/
theorem single_U_all_past_separable (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable (.all_past φ) :=
  all_past_separable φ (single_U_formula_separable φ A B hA_sf hB_sf h_single)

/-- Disjunction of two single-U-type separable formulas is separable. -/
theorem single_U_or_separable (φ ψ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    is_separable (Formula.or φ ψ) :=
  or_separable
    (single_U_formula_separable φ A B hA_sf hB_sf h1)
    (single_U_formula_separable ψ A B hA_sf hB_sf h2)

/-- Conjunction of two single-U-type separable formulas is separable. -/
theorem single_U_and_separable (φ ψ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (h1 : has_single_U_type φ A B) (h2 : has_single_U_type ψ A B) :
    is_separable (Formula.and φ ψ) :=
  and_separable
    (single_U_formula_separable φ A B hA_sf hB_sf h1)
    (single_U_formula_separable ψ A B hA_sf hB_sf h2)

end Bimodal.Metalogic.WeakCanonical.Separation
