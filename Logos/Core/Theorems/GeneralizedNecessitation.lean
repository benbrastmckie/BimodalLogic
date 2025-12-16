import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Context
import Logos.Core.Metalogic.DeductionTheorem
import Logos.Core.ProofSystem.Axioms
import Logos.Core.Theorems.Combinators

/-!
# Generalized Necessitation Rules

This module contains the generalized necessitation rules that were previously primitive
inference rules. They are now derived theorems from standard necessitation + K distribution
+ deduction theorem.

**Status**: COMPLETE

All theorems in this module are now fully proven derived theorems.

## Main Theorems

- `generalized_modal_k`: If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- `generalized_temporal_k`: If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`

## References

* [Task 44 Plan](
  .claude/specs/071_inference_rule_refactoring_necessitation/plans/
  001-inference-rule-refactoring-plan.md)
-/

namespace Logos.Core.Theorems

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Metalogic

/--
The reverse of the deduction theorem. If `Γ ⊢ A → B`, then `A :: Γ ⊢ B`.
This is derivable from modus ponens and weakening.
-/
theorem reverse_deduction {Γ : Context} {A B : Formula}
    (h : Γ ⊢ A.imp B) : (A :: Γ) ⊢ B := by
  have h_weak : (A :: Γ) ⊢ A.imp B :=
    Derivable.weakening _ _ _ h
      (by intro x hx; simp; right; exact hx)
  have h_assum : (A :: Γ) ⊢ A := Derivable.assumption (A :: Γ) A (by simp)
  exact Derivable.modus_ponens (A :: Γ) A B h_weak h_assum

/--
Generalized Modal K rule (derived theorem).

If `Γ ⊢ φ`, then `□Γ ⊢ □φ`.

This is the generalized necessitation rule that was previously primitive.
It is now derivable from standard necessitation + K distribution + deduction theorem.

**Proof Strategy**:
Induction on the context `Γ`.
- **Base case `Γ = []`**: `[] ⊢ φ` → `[] ⊢ □φ`. This is the primitive `necessitation` rule.
- **Inductive step `Γ = A :: Γ'`**:
  1. Assume `(A :: Γ') ⊢ φ`.
  2. By `deduction_theorem`, `Γ' ⊢ A → φ`.
  3. By inductive hypothesis, `□Γ' ⊢ □(A → φ)`.
  4. By `modal_k_dist` axiom and weakening, `□Γ' ⊢ □A → □φ`.
  5. By `reverse_deduction`, `□A :: □Γ' ⊢ □φ`, which is `□(A :: Γ') ⊢ □φ`.
-/
theorem generalized_modal_k (Γ : Context) (φ : Formula) :
    (h : Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ) := by
  induction Γ generalizing φ with
  | nil =>
    intro h
    exact Derivable.necessitation φ h
  | cons A Γ' ih =>
    intro h
    -- from (A :: Γ') ⊢ φ, get Γ' ⊢ A → φ
    have h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    -- apply inductive hypothesis to the implication
    have ih_res : (Context.map Formula.box Γ') ⊢ Formula.box (A.imp φ) := ih (A.imp φ) h_deduction
    -- use modal_k_dist axiom
    have k_dist : ⊢ (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      Derivable.axiom [] _ (Axiom.modal_k_dist A φ)
    have k_dist_weak :
      (Context.map Formula.box Γ') ⊢
      (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      Derivable.weakening [] _ _ k_dist (List.nil_subset _)
    -- modus ponens to get □Γ' ⊢ □A → □φ
    have h_mp : (Context.map Formula.box Γ') ⊢ (Formula.box A).imp (Formula.box φ) :=
      Derivable.modus_ponens _ _ _ k_dist_weak ih_res
    -- reverse deduction to get □A :: □Γ' ⊢ □φ
    have h_rev_deduction := reverse_deduction h_mp
    -- Note: Context.map Formula.box (A :: Γ') = Formula.box A :: Context.map Formula.box Γ'
    -- so the context matches exactly.
    exact h_rev_deduction

/--
Generalized Temporal K rule (derived theorem).

If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`.

This is the generalized temporal necessitation rule that was previously primitive.
It is now derivable from standard temporal necessitation + temporal K distribution
+ deduction theorem.

**Proof Strategy**: Analogous to generalized modal K.
-/
theorem generalized_temporal_k (Γ : Context) (φ : Formula) :
    (h : Γ ⊢ φ) → ((Context.map Formula.all_future Γ) ⊢ Formula.all_future φ) := by
  induction Γ generalizing φ with
  | nil =>
    intro h
    exact Derivable.temporal_necessitation φ h
  | cons A Γ' ih =>
    intro h
    have h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    have ih_res :
      (Context.map Formula.all_future Γ') ⊢ Formula.all_future (A.imp φ) :=
      ih (A.imp φ) h_deduction
    have k_dist :
      ⊢ (Formula.all_future (A.imp φ)).imp
        ((Formula.all_future A).imp (Formula.all_future φ)) :=
      Derivable.axiom [] _ (Axiom.temp_k_dist A φ)
    have k_dist_weak :
      (Context.map Formula.all_future Γ') ⊢
      (Formula.all_future (A.imp φ)).imp
      ((Formula.all_future A).imp (Formula.all_future φ)) :=
      Derivable.weakening [] _ _ k_dist (List.nil_subset _)
    have h_mp :
      (Context.map Formula.all_future Γ') ⊢
      (Formula.all_future A).imp (Formula.all_future φ) :=
      Derivable.modus_ponens _ _ _ k_dist_weak ih_res
    exact reverse_deduction h_mp

end Logos.Core.Theorems
