import Bimodal.Syntax.Formula
import Mathlib.Data.List.Basic

/-!
# Subformula Definitions for Bimodal Logic

This module provides the subformula closure for bimodal formulas.
These definitions are used in the finite model property proof and
decidability procedures.

## Main Definitions

- `Formula.subformulas`: Collect all subformulas of a formula (including itself)
- `Formula.subformulaCount`: Count of distinct subformulas

## Main Results

- `Formula.self_mem_subformulas`: A formula is in its own subformula list
- `Formula.subformulas_trans`: Subformula relation is transitive
- Membership lemmas for each constructor

## References

- Migrated from `Bimodal.Metalogic.Decidability.SignedFormula` for better modularity
-/

namespace Bimodal.Syntax

namespace Formula

/--
Collect all subformulas of a formula (including the formula itself).

This is used to bound the size of finite models and tableaux.
The subformula property ensures that expansion only produces
formulas from the subformula closure.
-/
def subformulas : Formula → List Formula
  | φ@(.atom _) => [φ]
  | φ@.bot => [φ]
  | φ@(.imp ψ χ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.box ψ) => φ :: subformulas ψ
  | φ@(.all_past ψ) => φ :: subformulas ψ
  | φ@(.all_future ψ) => φ :: subformulas ψ

/-- Count of distinct subformulas (used for termination). -/
def subformulaCount (φ : Formula) : Nat := (subformulas φ).eraseDups.length

/-- Subformulas include the formula itself. -/
theorem self_mem_subformulas (φ : Formula) : φ ∈ subformulas φ := by
  cases φ <;> simp [subformulas]

/-- Subformulas of imp include the left component. -/
theorem imp_left_mem_subformulas (ψ χ : Formula) : ψ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  right
  left
  exact self_mem_subformulas ψ

/-- Subformulas of imp include the right component. -/
theorem imp_right_mem_subformulas (ψ χ : Formula) : χ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  right
  right
  exact self_mem_subformulas χ

/-- Subformulas of box include the inner formula. -/
theorem box_inner_mem_subformulas (ψ : Formula) : ψ ∈ subformulas (.box ψ) := by
  simp only [subformulas, List.mem_cons]
  right
  exact self_mem_subformulas ψ

/-- Subformulas of all_past include the inner formula. -/
theorem all_past_inner_mem_subformulas (ψ : Formula) : ψ ∈ subformulas (.all_past ψ) := by
  simp only [subformulas, List.mem_cons]
  right
  exact self_mem_subformulas ψ

/-- Subformulas of all_future include the inner formula. -/
theorem all_future_inner_mem_subformulas (ψ : Formula) : ψ ∈ subformulas (.all_future ψ) := by
  simp only [subformulas, List.mem_cons]
  right
  exact self_mem_subformulas ψ

/--
Transitivity of the subformula relation.

If chi is a subformula of psi, and psi is a subformula of phi,
then chi is a subformula of phi.
-/
theorem subformulas_trans {chi psi phi : Formula}
    (h1 : chi ∈ subformulas psi) (h2 : psi ∈ subformulas phi) :
    chi ∈ subformulas phi := by
  induction phi with
  | atom p =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | bot =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | imp a b iha ihb =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; left
      exact iha ha
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; right
      exact ihb hb
  | box a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2
  | all_past a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2
  | all_future a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2

/--
Direct membership: left side of implication is in subformulas of the implication.
This is the key lemma for closure_imp_left.
-/
theorem mem_subformulas_of_imp_left {ψ χ phi : Formula}
    (h : Formula.imp ψ χ ∈ subformulas phi) : ψ ∈ subformulas phi := by
  have h_left : ψ ∈ subformulas (Formula.imp ψ χ) := imp_left_mem_subformulas ψ χ
  exact subformulas_trans h_left h

/--
Direct membership: right side of implication is in subformulas of the implication.
This is the key lemma for closure_imp_right.
-/
theorem mem_subformulas_of_imp_right {ψ χ phi : Formula}
    (h : Formula.imp ψ χ ∈ subformulas phi) : χ ∈ subformulas phi := by
  have h_right : χ ∈ subformulas (Formula.imp ψ χ) := imp_right_mem_subformulas ψ χ
  exact subformulas_trans h_right h

/--
Direct membership: inner formula of box is in subformulas.
-/
theorem mem_subformulas_of_box {ψ phi : Formula}
    (h : Formula.box ψ ∈ subformulas phi) : ψ ∈ subformulas phi := by
  have h_inner : ψ ∈ subformulas (Formula.box ψ) := box_inner_mem_subformulas ψ
  exact subformulas_trans h_inner h

/--
Direct membership: inner formula of all_past is in subformulas.
-/
theorem mem_subformulas_of_all_past {ψ phi : Formula}
    (h : Formula.all_past ψ ∈ subformulas phi) : ψ ∈ subformulas phi := by
  have h_inner : ψ ∈ subformulas (Formula.all_past ψ) := all_past_inner_mem_subformulas ψ
  exact subformulas_trans h_inner h

/--
Direct membership: inner formula of all_future is in subformulas.
-/
theorem mem_subformulas_of_all_future {ψ phi : Formula}
    (h : Formula.all_future ψ ∈ subformulas phi) : ψ ∈ subformulas phi := by
  have h_inner : ψ ∈ subformulas (Formula.all_future ψ) := all_future_inner_mem_subformulas ψ
  exact subformulas_trans h_inner h

end Formula

end Bimodal.Syntax
