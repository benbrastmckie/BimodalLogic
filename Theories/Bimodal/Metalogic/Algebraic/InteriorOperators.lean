import Bimodal.Metalogic.Algebraic.BooleanStructure
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.Perpetuity

/-!
# Interior Operators for Temporal Modalities

This module proves that G (all_future) and H (all_past) are interior operators
on the Lindenbaum algebra, using the reflexive T-axioms.

## Main Definitions

- `InteriorOp`: Structure for interior operators (dual of closure operators)
- `G_interior`: Instance showing G is an interior operator
- `H_interior`: Instance showing H is an interior operator

## Key Properties

Interior operators satisfy:
1. **Deflationary**: `c(a) ≤ a` (from T-axiom: `Gφ → φ`)
2. **Monotone**: `a ≤ b → c(a) ≤ c(b)` (from K-distribution)
3. **Idempotent**: `c(c(a)) = c(a)` (from 4-axiom: `Gφ → GGφ` and T-axiom)

-/

namespace Bimodal.Metalogic.Algebraic.InteriorOperators

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure

/-!
## Interior Operator Definition
-/

/--
An interior operator on a partial order.

This is the dual of Mathlib's ClosureOperator: instead of inflationary, it's deflationary.
-/
structure InteriorOp (α : Type*) [PartialOrder α] where
  /-- The interior operation -/
  toFun : α → α
  /-- Interior is deflationary: i(a) ≤ a -/
  le_self : ∀ a, toFun a ≤ a
  /-- Interior is monotone: a ≤ b → i(a) ≤ i(b) -/
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b
  /-- Interior is idempotent: i(i(a)) = i(a) -/
  idempotent : ∀ a, toFun (toFun a) = toFun a

/-!
## G as Interior Operator
-/

/--
G is deflationary: `Gφ ≤ φ`.

Uses T-axiom `temp_t_future`: `Gφ → φ`.
-/
theorem G_le_self (a : LindenbaumAlg) : G_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  show Derives φ.all_future φ
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩

/--
G is monotone: `φ ≤ ψ → Gφ ≤ Gψ`.

Uses K-distribution and temporal necessitation.
-/
theorem G_monotone (a b : LindenbaumAlg) (h : a ≤ b) : G_quot a ≤ G_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ.all_future ψ.all_future
  have h' : Derives φ ψ := h
  obtain ⟨d⟩ := h'
  have d_temp : DerivationTree [] (Formula.all_future (φ.imp ψ)) :=
    DerivationTree.temporal_necessitation (φ.imp ψ) d
  have d_k : DerivationTree [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩

/--
G is idempotent: `G(Gφ) = Gφ`.

Uses 4-axiom `temp_4`: `Gφ → GGφ` and T-axiom for the converse.
-/
theorem G_idempotent (a : LindenbaumAlg) : G_quot (G_quot a) = G_quot a := by
  induction a using Quotient.ind
  rename_i φ
  apply Quotient.sound
  show ProvEquiv φ.all_future.all_future φ.all_future
  constructor
  · exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ.all_future)⟩
  · exact ⟨DerivationTree.axiom [] _ (Axiom.temp_4 φ)⟩

/--
G is an interior operator on the Lindenbaum algebra.
-/
def G_interior : InteriorOp LindenbaumAlg where
  toFun := G_quot
  le_self := G_le_self
  monotone := G_monotone
  idempotent := G_idempotent

/-!
## H as Interior Operator
-/

/--
H is deflationary: `Hφ ≤ φ`.

Uses T-axiom `temp_t_past`: `Hφ → φ`.
-/
theorem H_le_self (a : LindenbaumAlg) : H_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  show Derives φ.all_past φ
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ)⟩

/--
H is monotone: `φ ≤ ψ → Hφ ≤ Hψ`.

Uses `past_mono` from Perpetuity (derived via temporal duality).
-/
theorem H_monotone (a b : LindenbaumAlg) (h : a ≤ b) : H_quot a ≤ H_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ.all_past ψ.all_past
  have h' : Derives φ ψ := h
  obtain ⟨d⟩ := h'
  exact ⟨Bimodal.Theorems.Perpetuity.past_mono d⟩

/--
H is idempotent: `H(Hφ) = Hφ`.

Uses `temp_4_past` (derived via temporal duality from temp_4).
-/
theorem H_idempotent (a : LindenbaumAlg) : H_quot (H_quot a) = H_quot a := by
  induction a using Quotient.ind
  rename_i φ
  apply Quotient.sound
  show ProvEquiv φ.all_past.all_past φ.all_past
  constructor
  · exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ.all_past)⟩
  · exact ⟨Bimodal.Metalogic.Core.temp_4_past φ⟩

/--
H is an interior operator on the Lindenbaum algebra.
-/
def H_interior : InteriorOp LindenbaumAlg where
  toFun := H_quot
  le_self := H_le_self
  monotone := H_monotone
  idempotent := H_idempotent

/-!
## Box as Interior Operator
-/

/--
Box is deflationary: `□φ ≤ φ`.

Uses T-axiom `modal_t`: `□φ → φ`.
-/
theorem box_le_self (a : LindenbaumAlg) : box_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  show Derives φ.box φ
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t φ)⟩

/--
Box is monotone: `φ ≤ ψ → □φ ≤ □ψ`.

Uses K-distribution and necessitation.
-/
theorem box_monotone (a b : LindenbaumAlg) (h : a ≤ b) : box_quot a ≤ box_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ.box ψ.box
  have h' : Derives φ ψ := h
  obtain ⟨d⟩ := h'
  have d_box : DerivationTree [] (Formula.box (φ.imp ψ)) :=
    DerivationTree.necessitation (φ.imp ψ) d
  have d_k : DerivationTree [] ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩

/--
Box is idempotent: `□(□φ) = □φ`.

Uses 4-axiom `modal_4`: `□φ → □□φ` and T-axiom for the converse.
-/
theorem box_idempotent (a : LindenbaumAlg) : box_quot (box_quot a) = box_quot a := by
  induction a using Quotient.ind
  rename_i φ
  apply Quotient.sound
  show ProvEquiv φ.box.box φ.box
  constructor
  · exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t φ.box)⟩
  · exact ⟨DerivationTree.axiom [] _ (Axiom.modal_4 φ)⟩

/--
Box is an interior operator on the Lindenbaum algebra.
-/
def box_interior : InteriorOp LindenbaumAlg where
  toFun := box_quot
  le_self := box_le_self
  monotone := box_monotone
  idempotent := box_idempotent

end Bimodal.Metalogic.Algebraic.InteriorOperators
