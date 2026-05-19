import Bimodal.Syntax.Formula
import Mathlib.Algebra.Order.Group.Int

/-!
# Separation Definitions: Integer Temporal Semantics

Core definitions for the separation theorem over integer time (GHR94 Chapter 10.2).

## Key Definitions

- `IntStructure`: A temporal structure over integers (valuation on Z)
- `int_truth`: Recursive truth evaluation for formulas over Z
- `int_equiv`: Semantic equivalence over integer time
- `is_pure_past`, `is_pure_future`, `is_pure_present`: Semantic purity predicates
- `is_U_free`, `is_S_free`: Syntactic absence predicates (decidable)
- `is_syntactically_separated`: Recursive syntactic separation check
- `is_separable`: Existential separation predicate
- `junction_depth`, `U_depth_under_S`, `count_U_subformulas`: Structural measures

## References

- GHR94, Chapter 10, Section 10.2 (pp. 569-592)
- Research report: `specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md`
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Integer Temporal Structure -/

/-- A temporal structure over integers: a valuation mapping atoms to sets of Z.
    This is GHR94's "linear temporal structure" (T, <, h) specialized to T = Z. -/
structure IntStructure where
  val : Atom → Set ℤ

/-! ## Truth Evaluation -/

/-- Truth of a formula at time t in an integer temporal structure.
    Note: box is treated as True (degenerate: modal component irrelevant for separation).
    This matches GHR94's "linear temporal structure" setup. -/
def int_truth (M : IntStructure) (t : ℤ) : Formula → Prop
  | .atom a => t ∈ M.val a
  | .bot => False
  | .imp φ ψ => int_truth M t φ → int_truth M t ψ
  | .box _ => True  -- degenerate: modal not relevant for separation
  | .untl φ ψ => ∃ s : ℤ, t < s ∧ int_truth M s φ ∧
      ∀ r : ℤ, t < r → r < s → int_truth M r ψ
  | .snce φ ψ => ∃ s : ℤ, s < t ∧ int_truth M s φ ∧
      ∀ r : ℤ, s < r → r < t → int_truth M r ψ

/-! ## int_truth simp lemmas for derived temporal operators -/

@[simp] theorem int_truth_all_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (Formula.all_past φ) ↔ ∀ s : ℤ, s < t → int_truth M s φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, int_truth]
  constructor
  · intro h s hs
    by_contra hns
    exact h ⟨s, hs, hns, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hns, _⟩
    exact hns (h s hs)

@[simp] theorem int_truth_all_future (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (Formula.all_future φ) ↔ ∀ s : ℤ, t < s → int_truth M s φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, int_truth]
  constructor
  · intro h s hs
    by_contra hns
    exact h ⟨s, hs, hns, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hns, _⟩
    exact hns (h s hs)

@[simp] theorem int_truth_some_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (Formula.some_past φ) ↔ ∃ s : ℤ, s < t ∧ int_truth M s φ := by
  simp only [Formula.some_past, Formula.top, int_truth]
  constructor
  · rintro ⟨s, hs, hphi, _⟩
    exact ⟨s, hs, hphi⟩
  · rintro ⟨s, hs, hphi⟩
    exact ⟨s, hs, hphi, fun _ _ _ h => h⟩

@[simp] theorem int_truth_some_future (M : IntStructure) (t : ℤ) (φ : Formula) :
    int_truth M t (Formula.some_future φ) ↔ ∃ s : ℤ, t < s ∧ int_truth M s φ := by
  simp only [Formula.some_future, Formula.top, int_truth]
  constructor
  · rintro ⟨s, hs, hphi, _⟩
    exact ⟨s, hs, hphi⟩
  · rintro ⟨s, hs, hphi⟩
    exact ⟨s, hs, hphi, fun _ _ _ h => h⟩

/-! ## Formula Atoms -/

/-- Collect all atoms occurring in a formula (as a `Set Atom`). -/
def formula_atoms : Formula → Set Atom
  | .atom a => {a}
  | .bot => ∅
  | .imp φ ψ => formula_atoms φ ∪ formula_atoms ψ
  | .box φ => formula_atoms φ
  | .untl φ ψ => formula_atoms φ ∪ formula_atoms ψ
  | .snce φ ψ => formula_atoms φ ∪ formula_atoms ψ

@[simp] theorem formula_atoms_all_past (φ : Formula) :
    formula_atoms (Formula.all_past φ) = formula_atoms φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, formula_atoms]
  ext a; simp only [Set.mem_union, Set.mem_empty_iff_false, or_false]

@[simp] theorem formula_atoms_all_future (φ : Formula) :
    formula_atoms (Formula.all_future φ) = formula_atoms φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, formula_atoms]
  ext a; simp only [Set.mem_union, Set.mem_empty_iff_false, or_false]

/-! ## Semantic Equivalence -/

/-- Semantic equivalence of formulas over integer time. -/
def int_equiv (φ ψ : Formula) : Prop :=
  ∀ (M : IntStructure) (t : ℤ), int_truth M t φ ↔ int_truth M t ψ

/-- int_equiv is reflexive. -/
theorem int_equiv_refl (φ : Formula) : int_equiv φ φ :=
  fun _ _ => Iff.rfl

/-- int_equiv is symmetric. -/
theorem int_equiv_symm {φ ψ : Formula} (h : int_equiv φ ψ) : int_equiv ψ φ :=
  fun M t => (h M t).symm

/-- int_equiv is transitive. -/
theorem int_equiv_trans {φ ψ χ : Formula} (h1 : int_equiv φ ψ) (h2 : int_equiv ψ χ) :
    int_equiv φ χ :=
  fun M t => (h1 M t).trans (h2 M t)

/-! ## Semantic Purity Predicates -/

/-- A formula is "pure past" if its truth at t depends only on the past of t. -/
def is_pure_past (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), s < t → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)

/-- A formula is "pure future" if its truth at t depends only on the future of t. -/
def is_pure_future (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), t < s → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)

/-- A formula is "pure present" if its truth at t depends only on time t. -/
def is_pure_present (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom), (t ∈ M₁.val a ↔ t ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)

/-! ## Syntactic Predicates -/

/-- A formula is "syntactically U-free": contains no `untl` constructor. -/
def is_U_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_U_free φ && is_U_free ψ
  | .box φ => is_U_free φ
  | .untl _ _ => false
  | .snce φ ψ => is_U_free φ && is_U_free ψ

/-- A formula is "syntactically S-free": contains no `snce` constructor. -/
def is_S_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_S_free φ && is_S_free ψ
  | .box φ => is_S_free φ
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce _ _ => false

/-! ### Simp lemmas for is_U_free and is_S_free at derived temporal operators -/

@[simp] theorem is_U_free_all_past (φ : Formula) :
    is_U_free (Formula.all_past φ) = is_U_free φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, is_U_free,
    Bool.and_true]

@[simp] theorem is_U_free_all_future (φ : Formula) :
    is_U_free (Formula.all_future φ) = false := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, is_U_free,
    Bool.false_and]

@[simp] theorem is_S_free_all_past (φ : Formula) :
    is_S_free (Formula.all_past φ) = false := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, is_S_free,
    Bool.false_and]

@[simp] theorem is_S_free_all_future (φ : Formula) :
    is_S_free (Formula.all_future φ) = is_S_free φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, is_S_free,
    Bool.and_true]

/-- A formula is "syntactically separated" if it is a boolean combination of:
    - atoms (pure present)
    - U-formulas with S-free arguments (pure future)
    - S-formulas with U-free arguments (pure past)

    We define this recursively. A formula is separated if:
    - It is an atom or bot
    - It is imp phi psi with both separated
    - It is all_future phi with S-free phi (hence pure future)
    - It is all_past phi with U-free phi (hence pure past)
    - It is untl phi psi with both S-free (hence pure future)
    - It is snce phi psi with both U-free (hence pure past)
    - It is box phi (treated as atomic/present) -/
def is_syntactically_separated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_syntactically_separated φ && is_syntactically_separated ψ
  | .box _ => true  -- box treated as atomic
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce φ ψ => is_U_free φ && is_U_free ψ

@[simp] theorem is_syntactically_separated_all_past (φ : Formula) :
    is_syntactically_separated (Formula.all_past φ) = is_U_free φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top,
    is_syntactically_separated, is_U_free, Bool.and_true]

@[simp] theorem is_syntactically_separated_all_future (φ : Formula) :
    is_syntactically_separated (Formula.all_future φ) = is_S_free φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top,
    is_syntactically_separated, is_S_free, Bool.and_true]

/-- A formula is "separable" if it is integer-equivalent to a syntactically
    separated formula. -/
def is_separable (φ : Formula) : Prop :=
  ∃ ψ : Formula, is_syntactically_separated ψ = true ∧ int_equiv φ ψ

/-! ## Proper Purity Predicates (Option D from Report 07)

These predicates correctly model GHR94's semantic separation for our formalization
where `all_future` (G) and `all_past` (H) are primitive constructors rather than
derived from U/S. A "future-only" formula contains no past temporal operators,
and a "past-only" formula contains no future temporal operators. -/

/-- A formula is "future-only": contains no `all_past` and no `snce`.
    Permits `all_future`, `untl`, atoms, boolean connectives.
    This correctly captures "pure future" for our primitive operator set. -/
def is_future_only : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_future_only φ && is_future_only ψ
  | .box φ => is_future_only φ
  | .untl φ ψ => is_future_only φ && is_future_only ψ
  | .snce _ _ => false

@[simp] theorem is_future_only_all_past (φ : Formula) :
    is_future_only (Formula.all_past φ) = false := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, is_future_only,
    Bool.false_and]

@[simp] theorem is_future_only_all_future (φ : Formula) :
    is_future_only (Formula.all_future φ) = is_future_only φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, is_future_only,
    Bool.and_true]

/-- A formula is "past-only": contains no `all_future` and no `untl`.
    Permits `all_past`, `snce`, atoms, boolean connectives.
    This correctly captures "pure past" for our primitive operator set. -/
def is_past_only : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_past_only φ && is_past_only ψ
  | .box φ => is_past_only φ
  | .untl _ _ => false
  | .snce φ ψ => is_past_only φ && is_past_only ψ

@[simp] theorem is_past_only_all_past (φ : Formula) :
    is_past_only (Formula.all_past φ) = is_past_only φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, is_past_only,
    Bool.and_true]

@[simp] theorem is_past_only_all_future (φ : Formula) :
    is_past_only (Formula.all_future φ) = false := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top, is_past_only,
    Bool.false_and]

/-- A formula is "properly separated" if it is a boolean combination of:
    - atoms (pure present)
    - future-only formulas under `all_future` or `untl`
    - past-only formulas under `all_past` or `snce`

    This matches GHR94's semantic separation requirement: S-arguments must be
    genuinely past-dependent (no future operators), and U-arguments must be
    genuinely future-dependent (no past operators). -/
def is_properly_separated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_properly_separated φ && is_properly_separated ψ
  | .box _ => true
  | .untl φ ψ => is_future_only φ && is_future_only ψ
  | .snce φ ψ => is_past_only φ && is_past_only ψ

@[simp] theorem is_properly_separated_all_past (φ : Formula) :
    is_properly_separated (Formula.all_past φ) = is_past_only φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top,
    is_properly_separated, is_past_only, Bool.and_true]

@[simp] theorem is_properly_separated_all_future (φ : Formula) :
    is_properly_separated (Formula.all_future φ) = is_future_only φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top,
    is_properly_separated, is_future_only, Bool.and_true]

/-- A formula is "properly separable" if it is integer-equivalent to a
    properly separated formula. This is the correct notion for Theorem 9.3.1. -/
def is_properly_separable (φ : Formula) : Prop :=
  ∃ ψ : Formula, is_properly_separated ψ = true ∧ int_equiv φ ψ

/-! ## Structural Measures for Induction -/

mutual
/-- Junction depth of a formula: maximum alternation depth of U/S nesting.
    This is the key induction measure for Lemma 10.2.8.
    Mutually recursive with junction_depth_U and junction_depth_S. -/
def junction_depth : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junction_depth phi) (junction_depth psi)
  | .box phi => junction_depth phi
  | .untl phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | .snce phi psi => max (junction_depth_S phi) (junction_depth_S psi)

def junction_depth_U : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | .box phi => junction_depth_U phi
  | .untl phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | .snce phi psi => 1 + max (junction_depth phi) (junction_depth psi)

def junction_depth_S : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junction_depth_S phi) (junction_depth_S psi)
  | .box phi => junction_depth_S phi
  | .untl phi psi => 1 + max (junction_depth phi) (junction_depth psi)
  | .snce phi psi => max (junction_depth_S phi) (junction_depth_S psi)
end

/-! ### Simp lemmas for junction_depth at derived temporal operators -/

@[simp] theorem junction_depth_all_past (φ : Formula) :
    junction_depth (Formula.all_past φ) = junction_depth_S φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top,
    junction_depth, junction_depth_S]; omega

@[simp] theorem junction_depth_all_future (φ : Formula) :
    junction_depth (Formula.all_future φ) = junction_depth_U φ := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top,
    junction_depth, junction_depth_U]; omega

/-- U-nesting depth beneath S: maximum depth of U under S (with no intervening S).
    Used for Lemma 10.2.7 induction. -/
def U_depth_under_S : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .box φ => U_depth_under_S φ
  | .untl φ ψ => 1 + max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .snce _ _ => 0  -- S resets the counter

/-- Count of maximal U-subformulas in a formula.
    Used for Lemma 10.2.6 induction on the number of distinct U-patterns. -/
def count_U_subformulas : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => count_U_subformulas φ + count_U_subformulas ψ
  | .box φ => count_U_subformulas φ
  | .untl _ _ => 1  -- count the U itself, not sub-U's
  | .snce φ ψ => count_U_subformulas φ + count_U_subformulas ψ

/-- S-nesting depth above U occurrences. Used for Lemma 10.2.5 induction.
    Counts the maximum number of S's between the root and any U. -/
def S_nesting_above_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (S_nesting_above_U φ) (S_nesting_above_U ψ)
  | .box φ => S_nesting_above_U φ
  | .untl _ _ => 0  -- U found; no S above it on this path
  | .snce φ ψ =>
    -- If there's a U below, this S adds 1 to the nesting
    let sub := max (S_nesting_above_U_inner φ) (S_nesting_above_U_inner ψ)
    if sub > 0 then 1 + sub else 0
where
  /-- Helper: counts S-nesting above U inside an S context.
      Returns 0 if there is no U below. -/
  S_nesting_above_U_inner : Formula → Nat
    | .atom _ => 0
    | .bot => 0
    | .imp φ ψ => max (S_nesting_above_U_inner φ) (S_nesting_above_U_inner ψ)
    | .box φ => S_nesting_above_U_inner φ
    | .untl _ _ => 1  -- U found inside S: contributes 1 (the S we're in)
    | .snce φ ψ =>
      let sub := max (S_nesting_above_U_inner φ) (S_nesting_above_U_inner ψ)
      if sub > 0 then 1 + sub else 0

/-! ## Auxiliary Predicates for Elimination Cases -/

/-- Predicate: U only appears in the formula as the specific subformula U(A,B),
    not under any S (i.e., all occurrences of U(A,B) are at "top level" w.r.t. S). -/
def u_appearances_top_level_only : Formula → Formula → Formula → Prop
  | .atom _, _, _ => True
  | .bot, _, _ => True
  | .imp φ ψ, A, B => u_appearances_top_level_only φ A B ∧ u_appearances_top_level_only ψ A B
  | .box φ, A, B => u_appearances_top_level_only φ A B
  | .untl φ ψ, A, B => φ = A ∧ ψ = B  -- Only the specific U(A,B) is allowed
  | .snce φ ψ, _, _ =>
    -- Under S: no untl allowed at all (U must be at top level, not under S)
    is_U_free φ = true ∧ is_U_free ψ = true

/-- Predicate: In the result formula, U(A,B) appears only at top level
    (not under any S). Equivalent to: under every S, the formula is U-free. -/
def u_appears_only_as_top_level : Formula → Formula → Formula → Prop
  | .atom _, _, _ => True
  | .bot, _, _ => True
  | .imp φ ψ, A, B => u_appears_only_as_top_level φ A B ∧ u_appears_only_as_top_level ψ A B
  | .box φ, A, B => u_appears_only_as_top_level φ A B
  | .untl φ ψ, A, B => u_appears_only_as_top_level φ A B ∧ u_appears_only_as_top_level ψ A B
  | .snce φ ψ, _, _ => is_U_free φ = true ∧ is_U_free ψ = true

/-- Predicate: the formula has no S nested within any U. -/
def no_S_nested_in_U : Formula -> Prop
  | .atom _ => True
  | .bot => True
  | .imp phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi
  | .box phi => no_S_nested_in_U phi
  | .untl phi psi => is_S_free phi = true ∧ is_S_free psi = true
  | .snce phi psi => no_S_nested_in_U phi ∧ no_S_nested_in_U psi

@[simp] theorem no_S_nested_in_U_all_past (φ : Formula) :
    no_S_nested_in_U (Formula.all_past φ) ↔ no_S_nested_in_U φ := by
  simp only [Formula.all_past, Formula.neg, Formula.some_past, Formula.top, no_S_nested_in_U,
    and_true]

@[simp] theorem no_S_nested_in_U_all_future (φ : Formula) :
    no_S_nested_in_U (Formula.all_future φ) ↔ (is_S_free φ = true) := by
  simp only [Formula.all_future, Formula.neg, Formula.some_future, Formula.top,
    no_S_nested_in_U, is_S_free, Bool.and_true, and_true]

end Bimodal.Metalogic.WeakCanonical.Separation
