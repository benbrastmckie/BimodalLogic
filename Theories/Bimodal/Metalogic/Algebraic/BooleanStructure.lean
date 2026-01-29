import Bimodal.Metalogic.Algebraic.LindenbaumQuotient
import Mathlib.Order.BooleanAlgebra

/-!
# Boolean Algebra Structure on Lindenbaum Algebra

This module proves that the Lindenbaum-Tarski algebra is a `BooleanAlgebra`.

## Main Results

- `LindenbaumAlg` is a `BooleanAlgebra`
- Order: `[φ] ≤ [ψ] ↔ ⊢ φ → ψ`
- Operations are well-defined on the quotient

## References

- Research report: specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md
-/

namespace Bimodal.Metalogic.Algebraic.BooleanStructure

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient

/-!
## Order Structure

The order on the Lindenbaum algebra is defined by derivability.
-/

/--
Order on LindenbaumAlg: `a ≤ b` iff the underlying formulas satisfy `⊢ φ → ψ`.

This is well-defined on the quotient because provable equivalence respects derivability.
-/
instance : LE LindenbaumAlg where
  le := Quotient.lift₂ (fun φ ψ => Derives φ ψ)
    (fun φ₁ φ₂ ψ₁ ψ₂ hφ hψ => by
      -- Need to show: Derives φ₁ ψ₁ ↔ Derives φ₂ ψ₂
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
  induction a using Quotient.ind
  exact derives_refl _

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
Sup (join) is given by disjunction.
-/
instance : Sup LindenbaumAlg where
  sup := or_quot

/--
Inf (meet) is given by conjunction.
-/
instance : Inf LindenbaumAlg where
  inf := and_quot

/--
Top is the class of Truth.
-/
instance : Top LindenbaumAlg where
  top := top_quot

/--
Bot is the class of ⊥.
-/
instance : Bot LindenbaumAlg where
  bot := bot_quot

/--
`a ⊓ b ≤ a`: conjunction implies first conjunct.
-/
theorem inf_le_left_quot (a b : LindenbaumAlg) : a ⊓ b ≤ a := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  -- Need to show Derives (φ.and ψ) φ
  -- and φ ψ = (φ.imp ψ.neg).neg
  -- We need ⊢ (φ ∧ ψ) → φ
  unfold Derives
  exact ⟨Bimodal.Theorems.Propositional.and_elim_left φ ψ⟩

/--
`a ⊓ b ≤ b`: conjunction implies second conjunct.
-/
theorem inf_le_right_quot (a b : LindenbaumAlg) : a ⊓ b ≤ b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  unfold Derives
  exact ⟨Bimodal.Theorems.Propositional.and_elim_right φ ψ⟩

/--
`a ≤ b → a ≤ c → a ≤ b ⊓ c`: greatest lower bound property.
-/
theorem le_inf_quot {a b c : LindenbaumAlg} (hab : a ≤ b) (hac : a ≤ c) : a ≤ b ⊓ c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  -- hab : Derives φ ψ
  -- hac : Derives φ χ
  -- Need: Derives φ (ψ.and χ)
  unfold Derives at *
  obtain ⟨d1⟩ := hab
  obtain ⟨d2⟩ := hac
  exact ⟨Bimodal.Theorems.Propositional.and_intro d1 d2⟩

/--
`a ≤ a ⊔ b`: first disjunct implies disjunction.
-/
theorem le_sup_left_quot (a b : LindenbaumAlg) : a ≤ a ⊔ b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  -- or φ ψ = φ.neg.imp ψ
  -- Need: Derives φ (φ.or ψ)
  unfold Derives
  exact ⟨Bimodal.Theorems.Propositional.or_intro_left φ ψ⟩

/--
`b ≤ a ⊔ b`: second disjunct implies disjunction.
-/
theorem le_sup_right_quot (a b : LindenbaumAlg) : b ≤ a ⊔ b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  unfold Derives
  exact ⟨Bimodal.Theorems.Propositional.or_intro_right φ ψ⟩

/--
`a ≤ c → b ≤ c → a ⊔ b ≤ c`: least upper bound property.
-/
theorem sup_le_quot {a b c : LindenbaumAlg} (hac : a ≤ c) (hbc : b ≤ c) : a ⊔ b ≤ c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  -- hac : Derives φ χ
  -- hbc : Derives ψ χ
  -- Need: Derives (φ.or ψ) χ
  unfold Derives at *
  obtain ⟨d1⟩ := hac
  obtain ⟨d2⟩ := hbc
  exact ⟨Bimodal.Theorems.Propositional.or_elim d1 d2⟩

/--
`⊥ ≤ a`: bot is least element.
-/
theorem bot_le_quot (a : LindenbaumAlg) : ⊥ ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: Derives Formula.bot φ
  unfold Derives
  exact ⟨DerivationTree.axiom [] _ (Axiom.ex_falso φ)⟩

/--
`a ≤ ⊤`: top is greatest element.
-/
theorem le_top_quot (a : LindenbaumAlg) : a ≤ ⊤ := by
  induction a using Quotient.ind
  rename_i φ
  -- top_quot = ⟦Formula.bot.imp Formula.bot⟧
  -- Need: Derives φ (Formula.bot.imp Formula.bot)
  unfold Derives
  -- ⊢ φ → (⊥ → ⊥) is derivable: φ implies any tautology
  have d_id : DerivationTree [] (Formula.bot.imp Formula.bot) := Bimodal.Theorems.Propositional.identity Formula.bot
  exact ⟨Bimodal.Theorems.Propositional.weaken_conclusion d_id φ⟩

instance : Lattice LindenbaumAlg where
  inf_le_left := inf_le_left_quot
  inf_le_right := inf_le_right_quot
  le_inf := fun _ _ _ => le_inf_quot
  le_sup_left := le_sup_left_quot
  le_sup_right := le_sup_right_quot
  sup_le := fun _ _ _ => sup_le_quot

instance : BoundedOrder LindenbaumAlg where
  bot_le := bot_le_quot
  le_top := le_top_quot

/-!
## Complement and Boolean Algebra

The complement is given by negation.
-/

/--
Complement is given by negation.
-/
instance : HasCompl LindenbaumAlg where
  compl := neg_quot

/--
`a ⊓ aᶜ = ⊥`: meet with complement is bot.
-/
theorem inf_compl_eq_bot_quot (a : LindenbaumAlg) : a ⊓ aᶜ = ⊥ := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: and_quot ⟦φ⟧ ⟦φ.neg⟧ = ⟦Formula.bot⟧
  -- I.e., ⟦φ.and φ.neg⟧ = ⟦Formula.bot⟧
  -- This means ProvEquiv (φ.and φ.neg) Formula.bot
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · -- ⊢ (φ ∧ ¬φ) → ⊥
    exact ⟨Bimodal.Theorems.Propositional.contradiction φ⟩
  · -- ⊢ ⊥ → (φ ∧ ¬φ)
    exact ⟨DerivationTree.axiom [] _ (Axiom.ex_falso (φ.and φ.neg))⟩

/--
`a ⊔ aᶜ = ⊤`: join with complement is top.
-/
theorem sup_compl_eq_top_quot (a : LindenbaumAlg) : a ⊔ aᶜ = ⊤ := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: ⟦φ.or φ.neg⟧ = ⟦Formula.bot.imp Formula.bot⟧
  -- This means ProvEquiv (φ.or φ.neg) (Formula.bot.imp Formula.bot)
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · -- ⊢ (φ ∨ ¬φ) → (⊥ → ⊥)
    -- Any formula implies a tautology
    have d_id : DerivationTree [] (Formula.bot.imp Formula.bot) := Bimodal.Theorems.Propositional.identity Formula.bot
    exact ⟨Bimodal.Theorems.Propositional.weaken_conclusion d_id (φ.or φ.neg)⟩
  · -- ⊢ (⊥ → ⊥) → (φ ∨ ¬φ)
    -- LEM is derivable in our classical logic (via Peirce)
    have d_lem : DerivationTree [] (φ.or φ.neg) := Bimodal.Theorems.Propositional.excluded_middle φ
    exact ⟨Bimodal.Theorems.Propositional.weaken_conclusion d_lem (Formula.bot.imp Formula.bot)⟩

/-!
## Distributivity

We need to prove distributivity for the Boolean algebra structure.
-/

/--
`a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c)`: distributivity of meet over join.
-/
theorem inf_sup_distrib_quot (a b c : LindenbaumAlg) : a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · -- ⊢ φ ∧ (ψ ∨ χ) → (φ ∧ ψ) ∨ (φ ∧ χ)
    exact ⟨Bimodal.Theorems.Propositional.and_or_distrib φ ψ χ⟩
  · -- ⊢ (φ ∧ ψ) ∨ (φ ∧ χ) → φ ∧ (ψ ∨ χ)
    exact ⟨Bimodal.Theorems.Propositional.or_and_distrib φ ψ χ⟩

/--
Stronger form of distributivity needed for BooleanAlgebra.
We use the standard pattern from Mathlib.
-/
theorem le_sup_inf_quot (a b c : LindenbaumAlg) : (a ⊔ b) ⊓ (a ⊔ c) ≤ a ⊔ (b ⊓ c) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  unfold Derives
  -- ⊢ (φ ∨ ψ) ∧ (φ ∨ χ) → φ ∨ (ψ ∧ χ)
  exact ⟨Bimodal.Theorems.Propositional.or_and_distrib' φ ψ χ⟩

/--
SDiff placeholder for BooleanAlgebra.
-/
instance : SDiff LindenbaumAlg where
  sdiff a b := a ⊓ bᶜ

instance : DistribLattice LindenbaumAlg where
  le_sup_inf := le_sup_inf_quot

/--
The Lindenbaum algebra is a Boolean algebra.
-/
instance : BooleanAlgebra LindenbaumAlg where
  inf_compl_le_bot := fun a => by rw [inf_compl_eq_bot_quot]
  top_le_sup_compl := fun a => by rw [sup_compl_eq_top_quot]
  sdiff_eq := fun a b => rfl
  himp := fun a b => aᶜ ⊔ b
  himp_eq := fun a b => rfl

end Bimodal.Metalogic.Algebraic.BooleanStructure
