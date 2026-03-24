import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Context
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Combinators

/-!
# Generalized Necessitation Rules

This module contains the generalized necessitation rules that were previously primitive
inference rules. They are now derived theorems from standard necessitation + K distribution
+ deduction theorem.

**Status**: COMPLETE

All theorems in this module are now fully proven derived theorems.

## Main Theorems

- `generalized_modal_k`: If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- `generalized_temporal_k`: If `Γ ⊢ φ`, then `GΓ ⊢ Gφ` (where G = all_future)
- `generalized_past_k`: If `Γ ⊢ φ`, then `HΓ ⊢ Hφ` (where H = all_past)

## Supporting Theorems

- `past_necessitation`: If `⊢ φ`, then `⊢ Hφ` (derived via temporal duality)
- `past_k_dist`: `⊢ H(A → B) → (HA → HB)` (derived via temporal duality)
- `reverse_deduction`: If `Γ ⊢ A → B`, then `A :: Γ ⊢ B`

## References

-/

namespace Bimodal.Theorems

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core

/--
The reverse of the deduction theorem. If `Γ ⊢ A → B`, then `A :: Γ ⊢ B`.
This is derivable from modus ponens and weakening.
-/
def reverse_deduction {Γ : Context} {A B : Formula}
    (h : Γ ⊢ A.imp B) : (A :: Γ) ⊢ B := by
  have h_weak : (A :: Γ) ⊢ A.imp B :=
    DerivationTree.weakening _ _ _ h
      (by intro x hx; simp; right; exact hx)
  have h_assum : (A :: Γ) ⊢ A := DerivationTree.assumption (A :: Γ) A (by simp)
  exact DerivationTree.modus_ponens (A :: Γ) A B h_weak h_assum

/--
Derived past necessitation rule.

If `⊢ φ`, then `⊢ Hφ` (where H is the "all_past" operator).

This is derived via temporal duality:
1. Apply `temporal_duality` to get `⊢ swap_temporal(φ)`
2. Apply `temporal_necessitation` to get `⊢ G(swap_temporal(φ))`
3. Apply `temporal_duality` again
4. Simplify using `swap_temporal_involution` to get `⊢ Hφ`
-/
noncomputable def past_necessitation (φ : Formula)
    (d : [] ⊢ φ) : [] ⊢ Formula.all_past φ := by
  have h_swap : ⊢ φ.swap_temporal := DerivationTree.temporal_duality _ d
  have g_swap : ⊢ φ.swap_temporal.all_future :=
    DerivationTree.temporal_necessitation _ h_swap
  have final : ⊢ φ.swap_temporal.all_future.swap_temporal :=
    DerivationTree.temporal_duality _ g_swap
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at final
  exact final

/--
Past K distribution axiom (derived via temporal duality).

`⊢ H(A → B) → (HA → HB)`

This is the past analog of `temp_k_dist`, derived by applying temporal duality
to the future K distribution axiom.
-/
noncomputable def past_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past) := by
  -- Apply temp_k_dist to swapped formulas
  have fk : ⊢ (A.swap_temporal.imp B.swap_temporal).all_future.imp
               (A.swap_temporal.all_future.imp B.swap_temporal.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist A.swap_temporal B.swap_temporal)
  -- Apply temporal duality
  have td : ⊢ ((A.swap_temporal.imp B.swap_temporal).all_future.imp
                (A.swap_temporal.all_future.imp B.swap_temporal.all_future)).swap_temporal :=
    DerivationTree.temporal_duality _ fk
  -- Simplify: swap(swap x) = x
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at td
  exact td

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
noncomputable def generalized_modal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ)
  | [], φ, h => DerivationTree.necessitation φ h
  | A :: Γ', φ, h =>
    -- from (A :: Γ') ⊢ φ, get Γ' ⊢ A → φ
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    -- apply inductive hypothesis to the implication
    let ih_res : (Context.map Formula.box Γ') ⊢ Formula.box (A.imp φ) :=
      generalized_modal_k Γ' (A.imp φ) h_deduction
    -- use modal_k_dist axiom
    let k_dist : ⊢ (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist A φ)
    let k_dist_weak :
      (Context.map Formula.box Γ') ⊢
      (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    -- modus ponens to get □Γ' ⊢ □A → □φ
    let h_mp : (Context.map Formula.box Γ') ⊢ (Formula.box A).imp (Formula.box φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    -- reverse deduction to get □A :: □Γ' ⊢ □φ
    -- Note: Context.map Formula.box (A :: Γ') = Formula.box A :: Context.map Formula.box Γ'
    -- so the context matches exactly.
    reverse_deduction h_mp

/--
Generalized Temporal K rule (derived theorem).

If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`.

This is the generalized temporal necessitation rule that was previously primitive.
It is now derivable from standard temporal necessitation + temporal K distribution
+ deduction theorem.

**Proof Strategy**: Analogous to generalized modal K.
-/
noncomputable def generalized_temporal_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_future Γ) ⊢ Formula.all_future φ)
  | [], φ, h => DerivationTree.temporal_necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    let ih_res :
      (Context.map Formula.all_future Γ') ⊢ Formula.all_future (A.imp φ) :=
      generalized_temporal_k Γ' (A.imp φ) h_deduction
    let k_dist :
      ⊢ (Formula.all_future (A.imp φ)).imp
        ((Formula.all_future A).imp (Formula.all_future φ)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist A φ)
    let k_dist_weak :
      (Context.map Formula.all_future Γ') ⊢
      (Formula.all_future (A.imp φ)).imp
      ((Formula.all_future A).imp (Formula.all_future φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    let h_mp :
      (Context.map Formula.all_future Γ') ⊢
      (Formula.all_future A).imp (Formula.all_future φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    reverse_deduction h_mp

/--
Generalized Past K rule (derived theorem).

If `Γ ⊢ φ`, then `HΓ ⊢ Hφ` (where H is the "all_past" operator).

This is the past analog of `generalized_temporal_k`, using the derived
`past_necessitation` and `past_k_dist` theorems instead of axioms.

**Proof Strategy**: Analogous to generalized modal K and generalized temporal K.
Induction on context `Γ`:
- **Base case `Γ = []`**: Use `past_necessitation`.
- **Inductive step `Γ = A :: Γ'`**: Use deduction theorem, inductive hypothesis,
  `past_k_dist`, and `reverse_deduction`.
-/
noncomputable def generalized_past_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_past Γ) ⊢ Formula.all_past φ)
  | [], φ, h => past_necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢ A.imp φ := deduction_theorem Γ' A φ h
    let ih_res :
      (Context.map Formula.all_past Γ') ⊢ Formula.all_past (A.imp φ) :=
      generalized_past_k Γ' (A.imp φ) h_deduction
    let k_dist :
      ⊢ (Formula.all_past (A.imp φ)).imp
        ((Formula.all_past A).imp (Formula.all_past φ)) :=
      past_k_dist A φ
    let k_dist_weak :
      (Context.map Formula.all_past Γ') ⊢
      (Formula.all_past (A.imp φ)).imp
      ((Formula.all_past A).imp (Formula.all_past φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    let h_mp :
      (Context.map Formula.all_past Γ') ⊢
      (Formula.all_past A).imp (Formula.all_past φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    reverse_deduction h_mp

end Bimodal.Theorems
