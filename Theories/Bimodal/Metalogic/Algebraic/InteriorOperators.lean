import Bimodal.Metalogic.Algebraic.BooleanStructure
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.Perpetuity

/-!
# Interior Operators for Modal and Temporal Modalities

This module defines interior operators on the Lindenbaum algebra.

## Main Definitions

- `InteriorOp`: Structure for interior operators (dual of closure operators)
- `box_interior`: Instance showing Box (□) is an interior operator

## Key Properties

Interior operators satisfy:
1. **Deflationary**: `c(a) ≤ a` (from T-axiom: `□φ → φ`)
2. **Monotone**: `a ≤ b → c(a) ≤ c(b)` (from K-distribution)
3. **Idempotent**: `c(c(a)) = c(a)` (from 4-axiom: `□φ → □□φ` and T-axiom)

## Status

Under strict temporal semantics (Task 991), G and H are NOT interior operators:
- The T-axiom `Gφ → φ` is not valid when G quantifies over s > t (strict future)
- The T-axiom `Hφ → φ` is not valid when H quantifies over s < t (strict past)

However, the modal operator Box (□) remains an interior operator because
the modal T-axiom `□φ → φ` is still valid (modal accessibility is reflexive).

## Historical Note

This module previously included `G_interior` and `H_interior` instances
under reflexive temporal semantics (Task 967). Under strict semantics,
only monotonicity (G_monotone, H_monotone) remains valid.
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
## G Monotonicity (Valid Under Strict Semantics)
-/

/--
G is monotone: `φ ≤ ψ → Gφ ≤ Gψ`.

Uses K-distribution and temporal necessitation.
This property holds under both reflexive and strict semantics.
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

/-!
## H Monotonicity (Valid Under Strict Semantics)
-/

/--
H is monotone: `φ ≤ ψ → Hφ ≤ Hψ`.

Uses `past_mono` from Perpetuity (derived via temporal duality).
This property holds under both reflexive and strict semantics.
-/
theorem H_monotone (a b : LindenbaumAlg) (h : a ≤ b) : H_quot a ≤ H_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ.all_past ψ.all_past
  have h' : Derives φ ψ := h
  obtain ⟨d⟩ := h'
  exact ⟨Bimodal.Theorems.Perpetuity.past_mono d⟩

/-!
## Box as Interior Operator

The modal operator Box (□) is an interior operator because the modal T-axiom
`□φ → φ` remains valid. Modal accessibility is reflexive in our logic.
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

/-!
## Note on G and H Under Strict Semantics

Under strict temporal semantics (Task 991), G and H are NOT interior operators
because they fail the deflationary property:

- `Gφ → φ` is not valid when G quantifies over s > t (strict future)
- `Hφ → φ` is not valid when H quantifies over s < t (strict past)

The T-axioms `temp_t_future` and `temp_t_past` have been removed from the
proof system as part of the Task 991 refactoring.

Mathematically, this is expected: under strict semantics, "always in the future"
does not imply "now", and "always in the past" does not imply "now".

The G and H operators still satisfy:
- Monotonicity (G_monotone, H_monotone) - preserved
- The 4-axiom direction (Gφ → GGφ) - preserved
- K-distribution - preserved

But they fail:
- Deflationarity (Gφ → φ, Hφ → φ) - invalid
- Full idempotency (requires T-axiom for one direction)

Thus, `G_interior` and `H_interior` instances are not defined under strict semantics.
-/

end Bimodal.Metalogic.Algebraic.InteriorOperators
