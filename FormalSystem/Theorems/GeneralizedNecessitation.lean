/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Context
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.ProofSystem.Axioms
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Connectives

/-!
# Generalized Necessitation Rules

This module contains the generalized necessitation rules that were previously primitive
inference rules. They are now derived theorems from standard necessitation + K distribution
+ deduction theorem.

**Status**: COMPLETE

All theorems in this module are now fully proven derived theorems.

## Main Theorems

- `generalizedModalK`: If `Γ ⊢ φ`, then `□Γ ⊢ □φ`
- `generalizedTemporalK`: If `Γ ⊢ φ`, then `GΓ ⊢ Gφ` (where G = allFuture)
- `generalizedPastK`: If `Γ ⊢ φ`, then `HΓ ⊢ Hφ` (where H = allPast)

## Supporting Theorems

- `pastNecessitation`: If `⊢ φ`, then `⊢ Hφ` (derived via temporal duality)
- `pastKDist`: `⊢ H(A → B) → (HA → HB)` (derived via temporal duality)
- `reverseDeduction`: If `Γ ⊢ A → B`, then `A :: Γ ⊢ B`

## References

-/

namespace FormalSystem.Theorems

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional

/-! ### Local derivation of temp_k_dist from BX3

G-distribution `G(φ→ψ) → (Gφ → Gψ)` derived from BX3 (right_mono_until)
and propositional contraposition. Defined here to avoid circular imports with
TemporalDerived.lean. -/

private noncomputable def temp_k_dist_local (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture) :=
  -- Step 1: ⊢ ¬(¬ψ→¬φ) → ¬(φ→ψ) (negated contrapositive)
  let neg_contra := mp (contraposeImp φ ψ) (contraposeImp (φ.imp ψ) (ψ.neg.imp φ.neg))
  -- Step 2: F(¬(¬ψ→¬φ)) → F(¬(φ→ψ)) via BX3
  let F_step := mp (DerivationTree.temporal_necessitation _ neg_contra)
    (DerivationTree.axiom [] _
      (Axiom.right_mono_until (ψ.neg.imp φ.neg).neg (φ.imp ψ).neg Formula.top) trivial)
  -- Step 3: G(φ→ψ) → G(¬ψ→¬φ) via contraposition
  let G_contra := contraposition F_step
  -- Step 4: G(¬ψ→¬φ) → (Gφ → Gψ) via BX3 + contraposition
  let G_to_GK := impTrans
    (DerivationTree.axiom [] _ (Axiom.right_mono_until ψ.neg φ.neg Formula.top) trivial)
    (contraposeImp (Formula.someFuture ψ.neg) (Formula.someFuture φ.neg))
  -- Compose
  impTrans G_contra G_to_GK

/--
The reverse of the deduction theorem. If `Γ ⊢ A → B`, then `A :: Γ ⊢ B`.
This is derivable from modus ponens and weakening.
-/
def reverseDeduction {fc : FrameClass} {Γ : Context} {A B : Formula}
    (h : Γ ⊢[fc] A.imp B) : (A :: Γ) ⊢[fc] B := by
  have h_weak : (A :: Γ) ⊢[fc] A.imp B :=
    DerivationTree.weakening _ _ _ h
      (by intro x hx; simp only [List.mem_cons]; right; exact hx)
  have h_assum : (A :: Γ) ⊢[fc] A := DerivationTree.assumption (A :: Γ) A (by simp)
  exact DerivationTree.modus_ponens (A :: Γ) A B h_weak h_assum

/--
Derived past necessitation rule.

If `⊢ φ`, then `⊢ Hφ` (where H is the "allPast" operator).

This is derived via temporal duality:
1. Apply `temporal_duality` to get `⊢ swapTemporal(φ)`
2. Apply `temporal_necessitation` to get `⊢ G(swapTemporal(φ))`
3. Apply `temporal_duality` again
4. Simplify using `swap_temporal_involution` to get `⊢ Hφ`
-/
noncomputable def pastNecessitation {fc : FrameClass} (φ : Formula)
    (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.allPast φ) := by
  have h_swap : DerivationTree fc [] φ.swapTemporal := DerivationTree.temporal_duality _ d
  have g_swap : DerivationTree fc [] φ.swapTemporal.allFuture :=
    DerivationTree.temporal_necessitation _ h_swap
  have final : DerivationTree fc [] φ.swapTemporal.allFuture.swapTemporal :=
    DerivationTree.temporal_duality _ g_swap
  simp only [Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution] at final
  exact final

/--
Past K distribution axiom (derived via temporal duality).

`⊢ H(A → B) → (HA → HB)`

This is the past analog of `temp_k_dist`, derived by applying temporal duality
to the future K distribution axiom.
-/
noncomputable def pastKDist {fc : FrameClass} (A B : Formula) :
    DerivationTree fc [] ((A.imp B).allPast.imp (A.allPast.imp B.allPast)) := by
  -- Apply derived temp_k_dist to swapped formulas (at Base, then lift)
  have fk : ⊢ (A.swapTemporal.imp B.swapTemporal).allFuture.imp
               (A.swapTemporal.allFuture.imp B.swapTemporal.allFuture) :=
    temp_k_dist_local A.swapTemporal B.swapTemporal
  have fk_fc := DerivationTree.lift (fc₁ := .Base) (fc₂ := fc) trivial fk
  -- Apply temporal duality
  have td : DerivationTree fc [] ((A.swapTemporal.imp B.swapTemporal).allFuture.imp
                (A.swapTemporal.allFuture.imp B.swapTemporal.allFuture)).swapTemporal :=
    DerivationTree.temporal_duality _ fk_fc
  -- Simplify: swap(swap x) = x
  simp only [Formula.swap_temporal_all_future,
    Formula.swapTemporal, Formula.swap_temporal_involution] at td
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
  2. By `deductionTheorem`, `Γ' ⊢ A → φ`.
  3. By inductive hypothesis, `□Γ' ⊢ □(A → φ)`.
  4. By `modal_k_dist` axiom and weakening, `□Γ' ⊢ □A → □φ`.
  5. By `reverseDeduction`, `□A :: □Γ' ⊢ □φ`, which is `□(A :: Γ') ⊢ □φ`.
-/
noncomputable def generalizedModalK {fc : FrameClass} : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢[fc] φ) → ((Context.map Formula.box Γ) ⊢[fc] Formula.box φ)
  | [], φ, h => DerivationTree.necessitation φ h
  | A :: Γ', φ, h =>
    -- from (A :: Γ') ⊢ φ, get Γ' ⊢ A → φ
    let h_deduction : Γ' ⊢[fc] A.imp φ := deductionTheorem Γ' A φ h
    -- apply inductive hypothesis to the implication
    let ih_res : (Context.map Formula.box Γ') ⊢[fc] Formula.box (A.imp φ) :=
      generalizedModalK Γ' (A.imp φ) h_deduction
    -- use modal_k_dist axiom
    let k_dist : ⊢[fc] (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist A φ) trivial
    let k_dist_weak :
      (Context.map Formula.box Γ') ⊢[fc]
      (Formula.box (A.imp φ)).imp ((Formula.box A).imp (Formula.box φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    -- modus ponens to get □Γ' ⊢ □A → □φ
    let h_mp : (Context.map Formula.box Γ') ⊢[fc] (Formula.box A).imp (Formula.box φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    -- reverse deduction to get □A :: □Γ' ⊢ □φ
    -- Note: Context.map Formula.box (A :: Γ') = Formula.box A :: Context.map Formula.box Γ'
    -- so the context matches exactly.
    reverseDeduction h_mp

/--
Generalized Temporal K rule (derived theorem).

If `Γ ⊢ φ`, then `FΓ ⊢ Fφ`.

This is the generalized temporal necessitation rule that was previously primitive.
It is now derivable from standard temporal necessitation + temporal K distribution
+ deduction theorem.

**Proof Strategy**: Analogous to generalized modal K.
-/
noncomputable def generalizedTemporalK {fc : FrameClass} : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢[fc] φ) → ((Context.map Formula.allFuture Γ) ⊢[fc] Formula.allFuture φ)
  | [], φ, h => DerivationTree.temporal_necessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢[fc] A.imp φ := deductionTheorem Γ' A φ h
    let ih_res :
      (Context.map Formula.allFuture Γ') ⊢[fc] Formula.allFuture (A.imp φ) :=
      generalizedTemporalK Γ' (A.imp φ) h_deduction
    let k_dist_base :
      ⊢ (Formula.allFuture (A.imp φ)).imp
        ((Formula.allFuture A).imp (Formula.allFuture φ)) :=
      temp_k_dist_local A φ
    let k_dist : ⊢[fc] (Formula.allFuture (A.imp φ)).imp
        ((Formula.allFuture A).imp (Formula.allFuture φ)) :=
      DerivationTree.lift (FrameClass.base_le fc) k_dist_base
    let k_dist_weak :
      (Context.map Formula.allFuture Γ') ⊢[fc]
      (Formula.allFuture (A.imp φ)).imp
      ((Formula.allFuture A).imp (Formula.allFuture φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    let h_mp :
      (Context.map Formula.allFuture Γ') ⊢[fc]
      (Formula.allFuture A).imp (Formula.allFuture φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    reverseDeduction h_mp

/--
Generalized Past K rule (derived theorem).

If `Γ ⊢ φ`, then `HΓ ⊢ Hφ` (where H is the "allPast" operator).

This is the past analog of `generalizedTemporalK`, using the derived
`pastNecessitation` and `pastKDist` theorems instead of axioms.

**Proof Strategy**: Analogous to generalized modal K and generalized temporal K.
Induction on context `Γ`:
- **Base case `Γ = []`**: Use `pastNecessitation`.
- **Inductive step `Γ = A :: Γ'`**: Use deduction theorem, inductive hypothesis,
  `pastKDist`, and `reverseDeduction`.
-/
noncomputable def generalizedPastK {fc : FrameClass} : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢[fc] φ) → ((Context.map Formula.allPast Γ) ⊢[fc] Formula.allPast φ)
  | [], φ, h => pastNecessitation φ h
  | A :: Γ', φ, h =>
    let h_deduction : Γ' ⊢[fc] A.imp φ := deductionTheorem Γ' A φ h
    let ih_res :
      (Context.map Formula.allPast Γ') ⊢[fc] Formula.allPast (A.imp φ) :=
      generalizedPastK Γ' (A.imp φ) h_deduction
    let k_dist :
      ⊢[fc] (Formula.allPast (A.imp φ)).imp
        ((Formula.allPast A).imp (Formula.allPast φ)) :=
      pastKDist A φ
    let k_dist_weak :
      (Context.map Formula.allPast Γ') ⊢[fc]
      (Formula.allPast (A.imp φ)).imp
      ((Formula.allPast A).imp (Formula.allPast φ)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    let h_mp :
      (Context.map Formula.allPast Γ') ⊢[fc]
      (Formula.allPast A).imp (Formula.allPast φ) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    reverseDeduction h_mp

end FormalSystem.Theorems
