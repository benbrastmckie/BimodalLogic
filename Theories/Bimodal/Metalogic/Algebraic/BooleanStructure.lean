import Bimodal.Metalogic.Algebraic.LindenbaumQuotient
import Mathlib.Order.BooleanAlgebra.Defs
import Mathlib.Order.BooleanAlgebra.Basic

/-!
# Boolean Algebra Structure on Lindenbaum Algebra

This module proves that the Lindenbaum-Tarski algebra is a `BooleanAlgebra`.

## Main Results

- `LindenbaumAlg` is a `BooleanAlgebra`
- Order: `[φ] ≤ [ψ] ↔ ⊢ φ → ψ`
- Operations are well-defined on the quotient

## References

- Research report: specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md

## Status

Phase 3 of Task 700. Contains sorries pending propositional helper lemmas.
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
Top is the class of Truth.
-/
instance instTopLindenbaumAlg : Top LindenbaumAlg where
  top := top_quot

/--
Bot is the class of ⊥.
-/
instance instBotLindenbaumAlg : Bot LindenbaumAlg where
  bot := bot_quot

-- The lattice and Boolean algebra proofs require additional propositional lemmas.
-- For now, we provide the structure with sorries for the proofs.

/--
`a ⊓ b ≤ a`: conjunction implies first conjunct.
-/
theorem inf_le_left_quot (a b : LindenbaumAlg) : and_quot a b ≤ a := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives (φ.and ψ) φ
  exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.and ψ) φ
    (Bimodal.Theorems.Propositional.lce φ ψ)⟩

/--
`a ⊓ b ≤ b`: conjunction implies second conjunct.
-/
theorem inf_le_right_quot (a b : LindenbaumAlg) : and_quot a b ≤ b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives (φ.and ψ) ψ
  exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.and ψ) ψ
    (Bimodal.Theorems.Propositional.rce φ ψ)⟩

/--
`a ≤ b → a ≤ c → a ≤ b ⊓ c`: greatest lower bound property.
-/
theorem le_inf_quot {a b c : LindenbaumAlg} (hab : a ≤ b) (hac : a ≤ c) : a ≤ and_quot b c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  show Derives φ (ψ.and χ)
  -- Use combine_imp_conj: from ⊢ φ → ψ and ⊢ φ → χ, derive ⊢ φ → (ψ ∧ χ)
  have h_ab : Derives φ ψ := hab
  have h_ac : Derives φ χ := hac
  obtain ⟨d_ab⟩ := h_ab
  obtain ⟨d_ac⟩ := h_ac
  exact ⟨Bimodal.Theorems.Combinators.combine_imp_conj d_ab d_ac⟩

/--
`a ≤ a ⊔ b`: first disjunct implies disjunction.
-/
theorem le_sup_left_quot (a b : LindenbaumAlg) : a ≤ or_quot a b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ (φ.or ψ)
  -- φ ∨ ψ = ¬φ → ψ, so we need ⊢ φ → (¬φ → ψ)
  -- This is raa (Reductio ad Absurdum): ⊢ φ → (¬φ → ψ)
  unfold Derives
  unfold Formula.or
  exact ⟨Bimodal.Theorems.Propositional.raa φ ψ⟩

/--
`b ≤ a ⊔ b`: second disjunct implies disjunction.
-/
theorem le_sup_right_quot (a b : LindenbaumAlg) : b ≤ or_quot a b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives ψ (φ.or ψ)
  -- Need disjunction introduction right: ⊢ ψ → (φ ∨ ψ)
  -- φ ∨ ψ = ¬φ → ψ, so we need ⊢ ψ → (¬φ → ψ)
  -- This is just weakening (prop_s): ⊢ ψ → (¬φ → ψ)
  unfold Derives
  have d_s : DerivationTree [] (ψ.imp (φ.neg.imp ψ)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s ψ φ.neg)
  exact ⟨d_s⟩

/--
`a ≤ c → b ≤ c → a ⊔ b ≤ c`: least upper bound property.
-/
theorem sup_le_quot {a b c : LindenbaumAlg} (hac : a ≤ c) (hbc : b ≤ c) : or_quot a b ≤ c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  show Derives (φ.or ψ) χ
  -- Need disjunction elimination: from ⊢ φ → χ and ⊢ ψ → χ, derive ⊢ (φ ∨ ψ) → χ
  -- φ ∨ ψ = ¬φ → ψ
  -- Strategy: Build (¬φ → ψ) → χ by:
  -- 1. From ⊢ ψ → χ and ⊢ ¬φ → ψ, get ⊢ ¬φ → χ via composition
  -- 2. From ⊢ φ → χ and ⊢ ¬φ → χ, get χ via classical_merge
  have h_ac : Derives φ χ := hac
  have h_bc : Derives ψ χ := hbc
  obtain ⟨d_ac⟩ := h_ac
  obtain ⟨d_bc⟩ := h_bc
  unfold Derives Formula.or
  -- We need: ⊢ (¬φ → ψ) → χ
  -- Step 1: Build (¬φ → χ) using composition with (¬φ → ψ) → (ψ → χ) → (¬φ → χ)
  -- b_combinator: (ψ → χ) → (¬φ → ψ) → (¬φ → χ)
  have b1 : ⊢ (ψ.imp χ).imp ((φ.neg.imp ψ).imp (φ.neg.imp χ)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have neg_phi_to_chi_given_disj : ⊢ (φ.neg.imp ψ).imp (φ.neg.imp χ) :=
    DerivationTree.modus_ponens [] _ _ b1 d_bc
  -- Step 2: Use classical_merge: (φ → χ) → ((¬φ → χ) → χ)
  -- We have d_ac : ⊢ φ → χ
  -- We need to combine with the above to get: (¬φ → ψ) → χ
  -- Build: (φ → χ) → ((¬φ → χ) → χ) and compose with (¬φ → ψ) → (¬φ → χ)
  have cm : ⊢ (φ.imp χ).imp ((φ.neg.imp χ).imp χ) :=
    Bimodal.Theorems.Propositional.classical_merge φ χ
  have step1 : ⊢ (φ.neg.imp χ).imp χ :=
    DerivationTree.modus_ponens [] _ _ cm d_ac
  -- Now compose: (¬φ → ψ) → (¬φ → χ) with (¬φ → χ) → χ
  have b2 : ⊢ ((φ.neg.imp χ).imp χ).imp (((φ.neg.imp ψ).imp (φ.neg.imp χ)).imp ((φ.neg.imp ψ).imp χ)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have step2 : ⊢ ((φ.neg.imp ψ).imp (φ.neg.imp χ)).imp ((φ.neg.imp ψ).imp χ) :=
    DerivationTree.modus_ponens [] _ _ b2 step1
  exact ⟨DerivationTree.modus_ponens [] _ _ step2 neg_phi_to_chi_given_disj⟩

/--
`⊥ ≤ a`: bot is least element.
-/
theorem bot_le_quot (a : LindenbaumAlg) : ⊥ ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  show Derives Formula.bot φ
  exact ⟨DerivationTree.axiom [] _ (Axiom.ex_falso φ)⟩

/--
`a ≤ ⊤`: top is greatest element.
-/
theorem le_top_quot (a : LindenbaumAlg) : a ≤ ⊤ := by
  induction a using Quotient.ind
  rename_i φ
  show Derives φ (Formula.bot.imp Formula.bot)
  -- ⊢ φ → (⊥ → ⊥)
  -- Derivable: from identity and weakening
  have d_id : DerivationTree [] (Formula.bot.imp Formula.bot) :=
    Bimodal.Theorems.Combinators.identity Formula.bot
  have d_s : DerivationTree [] ((Formula.bot.imp Formula.bot).imp (φ.imp (Formula.bot.imp Formula.bot))) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (Formula.bot.imp Formula.bot) φ)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_s d_id⟩

/--
Stronger form of distributivity: `(a ⊔ b) ⊓ (a ⊔ c) ≤ a ⊔ (b ⊓ c)`.
-/
theorem le_sup_inf_quot (a b c : LindenbaumAlg) :
    and_quot (or_quot a b) (or_quot a c) ≤ or_quot a (and_quot b c) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  rename_i φ ψ χ
  -- Need: ⊢ ((φ ∨ ψ) ∧ (φ ∨ χ)) → (φ ∨ (ψ ∧ χ))
  -- This is classical distributivity - requires case analysis via LEM
  show Derives ((φ.or ψ).and (φ.or χ)) (φ.or (ψ.and χ))
  unfold Derives
  -- Strategy: Use disjunction elimination on φ ∨ ψ
  -- Case 1 (φ): We get φ, hence φ ∨ (ψ ∧ χ) immediately
  -- Case 2 (ψ): We have ψ and (φ ∨ χ). Apply disjunction elimination on φ ∨ χ:
  --   Case 2a (φ): φ ∨ (ψ ∧ χ)
  --   Case 2b (χ): ψ ∧ χ, hence φ ∨ (ψ ∧ χ)

  -- Let P = (φ ∨ ψ) ∧ (φ ∨ χ), Q = φ ∨ (ψ ∧ χ)
  let P := (φ.or ψ).and (φ.or χ)
  let Q := φ.or (ψ.and χ)

  -- We'll use the classical_merge approach:
  -- From (φ → Q) and (¬φ → Q), derive Q
  -- (φ → Q): φ → φ ∨ (ψ ∧ χ) is di_left
  -- (¬φ → Q): From ¬φ and P, we get ψ and χ, hence ψ ∧ χ, hence Q

  -- Left intro: φ → φ ∨ (ψ ∧ χ)
  -- Using deduction theorem on ldi: [φ] ⊢ φ ∨ (ψ ∧ χ) implies ⊢ φ → φ ∨ (ψ ∧ χ)
  have di_left : ⊢ φ.imp Q :=
    Bimodal.Metalogic.Core.deduction_theorem [] φ Q (Bimodal.Theorems.Propositional.ldi φ (ψ.and χ))

  -- From context [P], derive φ ∨ ψ and φ ∨ χ
  -- Then derive: ¬φ → ψ (from φ ∨ ψ = ¬φ → ψ) and ¬φ → χ (from φ ∨ χ = ¬φ → χ)
  -- Combine: ¬φ → (ψ ∧ χ)
  -- Then: ¬φ → φ ∨ (ψ ∧ χ) (via di_right and imp_trans)

  -- di_right: ψ ∧ χ → φ ∨ (ψ ∧ χ)
  -- Using deduction theorem on rdi: [ψ ∧ χ] ⊢ φ ∨ (ψ ∧ χ) implies ⊢ (ψ ∧ χ) → φ ∨ (ψ ∧ χ)
  have di_right_conj : ⊢ (ψ.and χ).imp Q :=
    Bimodal.Metalogic.Core.deduction_theorem [] (ψ.and χ) Q (Bimodal.Theorems.Propositional.rdi φ (ψ.and χ))

  -- lce: P → (φ ∨ ψ)
  have lce_p : ⊢ P.imp (φ.or ψ) := Bimodal.Theorems.Propositional.lce_imp (φ.or ψ) (φ.or χ)

  -- rce: P → (φ ∨ χ)
  have rce_p : ⊢ P.imp (φ.or χ) := Bimodal.Theorems.Propositional.rce_imp (φ.or ψ) (φ.or χ)

  -- φ ∨ ψ = ¬φ → ψ, so P → (¬φ → ψ)
  have p_to_neg_phi_psi : ⊢ P.imp (φ.neg.imp ψ) := lce_p

  -- φ ∨ χ = ¬φ → χ, so P → (¬φ → χ)
  have p_to_neg_phi_chi : ⊢ P.imp (φ.neg.imp χ) := rce_p

  -- Combine: P → (¬φ → ψ ∧ χ)
  -- We need: from (P → (¬φ → ψ)) and (P → (¬φ → χ)), derive P → (¬φ → ψ ∧ χ)
  -- This requires combining under implication

  -- Use deduction theorem approach: from [P, ¬φ] derive ψ ∧ χ
  have h_ctx : [φ.neg, P] ⊢ ψ.and χ := by
    -- Get P from context
    have h_p : [φ.neg, P] ⊢ P := by apply DerivationTree.assumption; simp
    -- Get ¬φ from context
    have h_neg_phi : [φ.neg, P] ⊢ φ.neg := by apply DerivationTree.assumption; simp

    -- Weaken p_to_neg_phi_psi to context
    have h1 : [φ.neg, P] ⊢ P.imp (φ.neg.imp ψ) :=
      DerivationTree.weakening [] _ _ p_to_neg_phi_psi (List.nil_subset _)
    -- Apply to get ¬φ → ψ
    have h2 : [φ.neg, P] ⊢ φ.neg.imp ψ :=
      DerivationTree.modus_ponens _ _ _ h1 h_p
    -- Apply to get ψ
    have h_psi : [φ.neg, P] ⊢ ψ :=
      DerivationTree.modus_ponens _ _ _ h2 h_neg_phi

    -- Similarly for χ
    have h3 : [φ.neg, P] ⊢ P.imp (φ.neg.imp χ) :=
      DerivationTree.weakening [] _ _ p_to_neg_phi_chi (List.nil_subset _)
    have h4 : [φ.neg, P] ⊢ φ.neg.imp χ :=
      DerivationTree.modus_ponens _ _ _ h3 h_p
    have h_chi : [φ.neg, P] ⊢ χ :=
      DerivationTree.modus_ponens _ _ _ h4 h_neg_phi

    -- Combine ψ and χ into ψ ∧ χ using pairing
    have pair : ⊢ ψ.imp (χ.imp (ψ.and χ)) := Bimodal.Theorems.Combinators.pairing ψ χ
    have pair_ctx : [φ.neg, P] ⊢ ψ.imp (χ.imp (ψ.and χ)) :=
      DerivationTree.weakening [] _ _ pair (List.nil_subset _)
    have step1 : [φ.neg, P] ⊢ χ.imp (ψ.and χ) :=
      DerivationTree.modus_ponens _ _ _ pair_ctx h_psi
    exact DerivationTree.modus_ponens _ _ _ step1 h_chi

  -- Apply deduction theorem twice: [P, ¬φ] ⊢ ψ ∧ χ implies [P] ⊢ ¬φ → ψ ∧ χ
  have h_ctx2 : [P] ⊢ φ.neg.imp (ψ.and χ) :=
    Bimodal.Metalogic.Core.deduction_theorem [P] φ.neg (ψ.and χ) h_ctx

  -- Now [P] ⊢ ¬φ → ψ ∧ χ, and ψ ∧ χ → Q (di_right)
  -- Compose to get [P] ⊢ ¬φ → Q
  have di_right_ctx : [P] ⊢ (ψ.and χ).imp Q :=
    DerivationTree.weakening [] _ _ di_right_conj (List.nil_subset _)
  have b_inst : ⊢ ((ψ.and χ).imp Q).imp ((φ.neg.imp (ψ.and χ)).imp (φ.neg.imp Q)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have b_ctx : [P] ⊢ ((ψ.and χ).imp Q).imp ((φ.neg.imp (ψ.and χ)).imp (φ.neg.imp Q)) :=
    DerivationTree.weakening [] _ _ b_inst (List.nil_subset _)
  have step2 : [P] ⊢ (φ.neg.imp (ψ.and χ)).imp (φ.neg.imp Q) :=
    DerivationTree.modus_ponens _ _ _ b_ctx di_right_ctx
  have h_neg_phi_Q : [P] ⊢ φ.neg.imp Q :=
    DerivationTree.modus_ponens _ _ _ step2 h_ctx2

  -- Now we have [P] ⊢ φ → Q (via di_left weakened) and [P] ⊢ ¬φ → Q
  -- Use classical_merge: (φ → Q) → ((¬φ → Q) → Q)
  have di_left_ctx : [P] ⊢ φ.imp Q :=
    DerivationTree.weakening [] _ _ di_left (List.nil_subset _)

  have cm : ⊢ (φ.imp Q).imp ((φ.neg.imp Q).imp Q) :=
    Bimodal.Theorems.Propositional.classical_merge φ Q
  have cm_ctx : [P] ⊢ (φ.imp Q).imp ((φ.neg.imp Q).imp Q) :=
    DerivationTree.weakening [] _ _ cm (List.nil_subset _)
  have step3 : [P] ⊢ (φ.neg.imp Q).imp Q :=
    DerivationTree.modus_ponens _ _ _ cm_ctx di_left_ctx
  have h_Q : [P] ⊢ Q :=
    DerivationTree.modus_ponens _ _ _ step3 h_neg_phi_Q

  -- Apply deduction theorem: [P] ⊢ Q implies [] ⊢ P → Q
  exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] P Q h_Q⟩

/-!
## Complement and Boolean Algebra

The complement is given by negation.
-/

/--
`a ⊓ aᶜ ≤ ⊥`: meet with complement is at most bot.
-/
theorem inf_compl_le_bot_quot (a : LindenbaumAlg) : and_quot a (neg_quot a) ≤ ⊥ := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: ⊢ (φ ∧ ¬φ) → ⊥
  -- From [φ ∧ ¬φ] we can derive ⊥ via lce, rce, and modus ponens
  show Derives (φ.and φ.neg) Formula.bot
  unfold Derives
  -- Use deduction theorem: from [φ ∧ ¬φ] ⊢ ⊥, derive ⊢ (φ ∧ ¬φ) → ⊥
  have h_conj_ctx : [φ.and φ.neg] ⊢ φ.and φ.neg := by
    apply DerivationTree.assumption
    simp
  have h_phi : [φ.and φ.neg] ⊢ φ := by
    apply DerivationTree.modus_ponens [φ.and φ.neg] _ _
    · apply DerivationTree.weakening [] [φ.and φ.neg]
      · exact Bimodal.Theorems.Propositional.lce_imp φ φ.neg
      · intro; simp
    · exact h_conj_ctx
  have h_neg_phi : [φ.and φ.neg] ⊢ φ.neg := by
    apply DerivationTree.modus_ponens [φ.and φ.neg] _ _
    · apply DerivationTree.weakening [] [φ.and φ.neg]
      · exact Bimodal.Theorems.Propositional.rce_imp φ φ.neg
      · intro; simp
    · exact h_conj_ctx
  -- φ.neg = φ → ⊥, so modus ponens gives ⊥
  have h_bot : [φ.and φ.neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens [φ.and φ.neg] φ Formula.bot h_neg_phi h_phi
  exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] (φ.and φ.neg) Formula.bot h_bot⟩

/--
`⊤ ≤ a ⊔ aᶜ`: top is at most join with complement.
-/
theorem top_le_sup_compl_quot (a : LindenbaumAlg) : ⊤ ≤ or_quot a (neg_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: ⊢ ⊤ → (φ ∨ ¬φ)
  -- ⊤ = ⊥ → ⊥, so need: ⊢ (⊥ → ⊥) → (φ ∨ ¬φ)
  -- This follows from LEM (⊢ φ ∨ ¬φ) by weakening
  show Derives (Formula.bot.imp Formula.bot) (φ.or φ.neg)
  unfold Derives
  have h_lem : ⊢ φ.or φ.neg := Bimodal.Theorems.Propositional.lem φ
  -- Weaken: ⊢ (φ ∨ ¬φ) → ((⊥ → ⊥) → (φ ∨ ¬φ))
  have h_s : ⊢ (φ.or φ.neg).imp ((Formula.bot.imp Formula.bot).imp (φ.or φ.neg)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (φ.or φ.neg) (Formula.bot.imp Formula.bot))
  exact ⟨DerivationTree.modus_ponens [] _ _ h_s h_lem⟩

/--
Sup is commutative.
-/
theorem sup_comm_quot (a b : LindenbaumAlg) : or_quot a b = or_quot b a := by
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
  sup := or_quot
  inf := and_quot
  compl := neg_quot
  sdiff := fun a b => and_quot a (neg_quot b)
  himp := fun a b => or_quot (neg_quot a) b
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
  himp_eq := fun a b => sup_comm_quot _ _

end Bimodal.Metalogic.Algebraic.BooleanStructure
