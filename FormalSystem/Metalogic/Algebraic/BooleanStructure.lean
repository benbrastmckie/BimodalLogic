/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
import FormalSystem.Metalogic.Decidability.Propositional.Tactic
import Mathlib.Order.BooleanAlgebra.Defs
import Mathlib.Order.BooleanAlgebra.Basic

/-!
# Boolean Algebra Structure on Lindenbaum Algebra

This module proves that the Lindenbaum-Tarski algebra is a `BooleanAlgebra`.

## Main Results

- `LindenbaumAlg` is a `BooleanAlgebra`
- Order: `[φ] ≤ [ψ] ↔ ⊢ φ → ψ`
- Operations are well-defined on the quotient

## Status

Phase 3 of the algebraic completeness theorem. Contains sorries pending propositional helper lemmas.
-/

namespace FormalSystem.Metalogic.Algebraic.BooleanStructure

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Metalogic.Algebraic.LindenbaumQuotient

/-!
## Order Structure

The order on the Lindenbaum algebra is defined by derivability.
-/

/--
Order on LindenbaumAlg: `a ≤ b` iff the underlying formulas satisfy `⊢ φ → ψ`.

This is well-defined on the quotient because provable equivalence respects derivability.
-/
instance instLELindenbaumAlg : LE LindenbaumAlg where
  le := Quotient.lift₂ (fun φ ψ => Derives φ ψ)
    (fun φ₁ φ₂ ψ₁ ψ₂ hφ hψ => by
      apply propext
      constructor
      · intro h
        exact derives_trans hφ.2 (derives_trans h hψ.1)
      · intro h
        exact derives_trans hφ.1 (derives_trans h hψ.2))

/--
The order is reflexive.
-/
theorem le_refl_quot (a : LindenbaumAlg) : a ≤ a := by
  induction a using Quotient.ind with | _ φ =>
  change Derives φ φ
  unfold Derives
  propDecide

/--
The order is transitive.
-/
theorem le_trans_quot {a b c : LindenbaumAlg} (hab : a ≤ b) (hbc : b ≤ c) : a ≤ c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  exact derives_trans hab hbc

/--
The order is antisymmetric (with respect to quotient equality).
-/
theorem le_antisymm_quot {a b : LindenbaumAlg} (hab : a ≤ b) (hba : b ≤ a) : a = b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  exact Quotient.sound ⟨hab, hba⟩

instance : Preorder LindenbaumAlg where
  le_refl := le_refl_quot
  le_trans := fun _ _ _ => le_trans_quot

instance : PartialOrder LindenbaumAlg where
  le_antisymm := fun _ _ => le_antisymm_quot

/-!
## Lattice Structure

We now establish the lattice operations (sup = or, inf = and).
-/

/--
Top is the class of Truth.
-/
instance instTopLindenbaumAlg : Top LindenbaumAlg where
  top := topQuot

/--
Bot is the class of ⊥.
-/
instance instBotLindenbaumAlg : Bot LindenbaumAlg where
  bot := botQuot

-- The lattice and Boolean algebra proofs require additional propositional lemmas.
-- For now, we provide the structure with sorries for the proofs.

/--
`a ⊓ b ≤ a`: conjunction implies first conjunct.
-/
theorem inf_le_left_quot (a b : LindenbaumAlg) : andQuot a b ≤ a := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  change Derives (φ.and ψ) φ
  unfold Derives
  propDecide

/--
`a ⊓ b ≤ b`: conjunction implies second conjunct.
-/
theorem inf_le_right_quot (a b : LindenbaumAlg) : andQuot a b ≤ b := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  change Derives (φ.and ψ) ψ
  unfold Derives
  propDecide

/--
`a ≤ b → a ≤ c → a ≤ b ⊓ c`: greatest lower bound property.
-/
theorem le_inf_quot {a b c : LindenbaumAlg} (hab : a ≤ b) (hac : a ≤ c) : a ≤ andQuot b c := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  induction c using Quotient.ind with | _ χ =>
  obtain ⟨d_ab⟩ := (hab : Derives φ ψ); obtain ⟨d_ac⟩ := (hac : Derives φ χ)
  obtain ⟨d_taut⟩ := (show |-! ((φ.imp ψ).and (φ.imp χ)).imp (φ.imp (ψ.and χ)) by propDecide)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_taut (DerivationTree.modus_ponens [] _ _
    (DerivationTree.modus_ponens [] _ _ (FormalSystem.Theorems.Combinators.pairing _ _) d_ab) d_ac)⟩

/--
`a ≤ a ⊔ b`: first disjunct implies disjunction.
-/
theorem le_sup_left_quot (a b : LindenbaumAlg) : a ≤ orQuot a b := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  change Derives φ (φ.or ψ)
  unfold Derives
  propDecide

/--
`b ≤ a ⊔ b`: second disjunct implies disjunction.
-/
theorem le_sup_right_quot (a b : LindenbaumAlg) : b ≤ orQuot a b := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  change Derives ψ (φ.or ψ)
  unfold Derives
  propDecide

/--
`a ≤ c → b ≤ c → a ⊔ b ≤ c`: least upper bound property.
-/
theorem sup_le_quot {a b c : LindenbaumAlg} (hac : a ≤ c) (hbc : b ≤ c) : orQuot a b ≤ c := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  induction c using Quotient.ind with | _ χ =>
  obtain ⟨d_ac⟩ := (hac : Derives φ χ); obtain ⟨d_bc⟩ := (hbc : Derives ψ χ)
  obtain ⟨d_taut⟩ := (show |-! ((φ.imp χ).and (ψ.imp χ)).imp ((φ.or ψ).imp χ) by propDecide)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_taut (DerivationTree.modus_ponens [] _ _
    (DerivationTree.modus_ponens [] _ _ (FormalSystem.Theorems.Combinators.pairing _ _) d_ac) d_bc)⟩

/--
`⊥ ≤ a`: bot is least element.
-/
theorem bot_le_quot (a : LindenbaumAlg) : ⊥ ≤ a := by
  induction a using Quotient.ind with | _ φ =>
  change Derives Formula.bot φ
  unfold Derives
  propDecide

/--
`a ≤ ⊤`: top is greatest element.
-/
theorem le_top_quot (a : LindenbaumAlg) : a ≤ ⊤ := by
  induction a using Quotient.ind with | _ φ =>
  change Derives φ (Formula.bot.imp Formula.bot)
  unfold Derives
  propDecide

/--
Stronger form of distributivity: `(a ⊔ b) ⊓ (a ⊔ c) ≤ a ⊔ (b ⊓ c)`.
-/
theorem le_sup_inf_quot (a b c : LindenbaumAlg) :
    andQuot (orQuot a b) (orQuot a c) ≤ orQuot a (andQuot b c) := by
  induction a using Quotient.ind with | _ φ =>
  induction b using Quotient.ind with | _ ψ =>
  induction c using Quotient.ind with | _ χ =>
  change Derives ((φ.or ψ).and (φ.or χ)) (φ.or (ψ.and χ))
  unfold Derives
  propDecide

/-!
## Complement and Boolean Algebra

The complement is given by negation.
-/

/--
`a ⊓ aᶜ ≤ ⊥`: meet with complement is at most bot.
-/
theorem inf_compl_le_bot_quot (a : LindenbaumAlg) : andQuot a (negQuot a) ≤ ⊥ := by
  induction a using Quotient.ind with | _ φ =>
  change Derives (φ.and φ.neg) Formula.bot
  unfold Derives
  propDecide

/--
`⊤ ≤ a ⊔ aᶜ`: top is at most join with complement.
-/
theorem top_le_sup_compl_quot (a : LindenbaumAlg) : ⊤ ≤ orQuot a (negQuot a) := by
  induction a using Quotient.ind with | _ φ =>
  change Derives (Formula.bot.imp Formula.bot) (φ.or φ.neg)
  unfold Derives
  propDecide

/--
Sup is commutative.
-/
theorem sup_comm_quot (a b : LindenbaumAlg) : orQuot a b = orQuot b a := by
  apply le_antisymm
  · apply sup_le_quot
    · exact le_sup_right_quot b a
    · exact le_sup_left_quot b a
  · apply sup_le_quot
    · exact le_sup_right_quot a b
    · exact le_sup_left_quot a b

/--
The Lindenbaum algebra is a Boolean algebra.
-/
instance : BooleanAlgebra LindenbaumAlg where
  sup := orQuot
  inf := andQuot
  compl := negQuot
  sdiff := fun a b => andQuot a (negQuot b)
  himp := fun a b => orQuot (negQuot a) b
  le_sup_left := le_sup_left_quot
  le_sup_right := le_sup_right_quot
  sup_le := fun _ _ _ => sup_le_quot
  inf_le_left := inf_le_left_quot
  inf_le_right := inf_le_right_quot
  le_inf := fun _ _ _ => le_inf_quot
  le_top := le_top_quot
  bot_le := bot_le_quot
  le_sup_inf := le_sup_inf_quot
  inf_compl_le_bot := inf_compl_le_bot_quot
  top_le_sup_compl := top_le_sup_compl_quot
  sdiff_eq := fun _ _ => rfl
  himp_eq := fun _a _b => sup_comm_quot _ _

end FormalSystem.Metalogic.Algebraic.BooleanStructure
