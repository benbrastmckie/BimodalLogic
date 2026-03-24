import Bimodal.Metalogic.Algebraic.LindenbaumQuotient
import Bimodal.Metalogic.Algebraic.BooleanStructure
import Bimodal.Metalogic.Algebraic.InteriorOperators
import Mathlib.Order.BooleanAlgebra.Basic

/-!
# Shift-Closed Tense S5 Algebra (STSA)

This module defines the STSA typeclass capturing the algebraic structure of TM logic
(Tense and Modality). An STSA is a Boolean algebra equipped with:

- Box (□): S5 interior operator
- G, H: Temporal universal operators (future and past)
- Sigma (σ): Temporal duality involution

## Main Definitions

- `STSA`: Typeclass for Shift-Closed Tense S5 Algebras
- `instance : STSA LindenbaumAlg`: The Lindenbaum algebra is an STSA

## Mathematical Structure

The STSA axioms capture:
1. Box is an S5 interior operator (deflationary, monotone, idempotent, partition)
2. G and H are monotone
3. Sigma is an involutive Boolean automorphism swapping G and H
4. Interaction axioms: MF, TF, TA, TL
5. Temporal linearity

-/

namespace Bimodal.Metalogic.Algebraic.TenseS5Algebra

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure

/-!
## STSA Typeclass Definition
-/

/--
Shift-Closed Tense S5 Algebra (STSA).

An STSA is a Boolean algebra with three operators (Box, G, H) and a temporal
duality involution (sigma) satisfying the TM logic axiom equations at the algebraic level.

The key properties are:
- Box is an S5 interior operator
- G and H are monotone
- Sigma is an involutive automorphism swapping G ↔ H
- MF and TF ensure box formulas are temporally persistent
- TA ensures temporal connectedness
- TL captures temporal introspection
- Linearity ensures temporal ordering is total
-/
class STSA (α : Type*) extends BooleanAlgebra α where
  /-- Modal necessity operator -/
  box : α → α
  /-- Future universal operator -/
  G : α → α
  /-- Past universal operator -/
  H : α → α
  /-- Temporal duality involution -/
  sigma : α → α

  -- Box is an S5 interior operator
  /-- Box is deflationary: □a ≤ a -/
  box_deflationary : ∀ a, box a ≤ a
  /-- Box is monotone: a ≤ b → □a ≤ □b -/
  box_monotone : ∀ a b, a ≤ b → box a ≤ box b
  /-- Box is idempotent: □□a = □a -/
  box_idempotent : ∀ a, box (box a) = box a
  /-- S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ (equivalently ¬□a → □¬□a) -/
  box_s5 : ∀ a, (box a)ᶜ ≤ box ((box a)ᶜ)

  -- G and H are monotone
  /-- G is monotone: a ≤ b → Ga ≤ Gb -/
  G_monotone : ∀ a b, a ≤ b → G a ≤ G b
  /-- H is monotone: a ≤ b → Ha ≤ Hb -/
  H_monotone : ∀ a b, a ≤ b → H a ≤ H b

  -- Sigma is an involutive Boolean automorphism
  /-- Sigma is an involution: σσa = a -/
  sigma_involution : ∀ a, sigma (sigma a) = a
  /-- Sigma preserves complement: σ(aᶜ) = (σa)ᶜ -/
  sigma_neg : ∀ a, sigma (aᶜ) = (sigma a)ᶜ
  /-- Sigma preserves sup: σ(a ⊔ b) = σa ⊔ σb -/
  sigma_sup : ∀ a b, sigma (a ⊔ b) = sigma a ⊔ sigma b

  -- Sigma-G-H duality
  /-- Sigma swaps G and H: σ(Ga) = H(σa) -/
  sigma_G : ∀ a, sigma (G a) = H (sigma a)
  /-- Sigma swaps H and G: σ(Ha) = G(σa) -/
  sigma_H : ∀ a, sigma (H a) = G (sigma a)

  -- Box commutes with sigma
  /-- Sigma commutes with box: σ(□a) = □(σa) -/
  sigma_box : ∀ a, sigma (box a) = box (sigma a)

  -- Interaction axioms (shift-closure)
  /-- MF: □a ≤ □Ga (modal-future interaction) -/
  MF : ∀ a, box a ≤ box (G a)
  /-- TF: □a ≤ G□a (temporal-future of box) -/
  TF : ∀ a, box a ≤ G (box a)

  -- Temporal connectedness (TA)
  /-- TA: a ≤ G((Ha)ᶜ)ᶜ, i.e., a ≤ GPa (using F = ¬G¬, P = ¬H¬) -/
  TA : ∀ a, a ≤ G ((H (aᶜ))ᶜ)

  -- Temporal introspection (TL)
  /-- TL: Ha ⊓ Ga ≤ GHa -/
  TL : ∀ a, H a ⊓ G a ≤ G (H a)

  -- Linearity (algebraic form)
  -- Fa ∧ Fb → F(a ∧ b) ∨ F(a ∧ Fb) ∨ F(Fa ∧ b)
  -- where F = ¬G¬ (existential future)
  /-- Linearity: Fa ⊓ Fb ≤ F(a ⊓ b) ⊔ F(a ⊓ Fb) ⊔ F(Fa ⊓ b) -/
  linearity : ∀ a b,
    (G (aᶜ))ᶜ ⊓ (G (bᶜ))ᶜ ≤
    (G ((a ⊓ b)ᶜ))ᶜ ⊔ (G ((a ⊓ (G (bᶜ))ᶜ)ᶜ))ᶜ ⊔ (G (((G (aᶜ))ᶜ ⊓ b)ᶜ))ᶜ

/-!
## STSA Instance for LindenbaumAlg

We prove that the Lindenbaum algebra satisfies all STSA axioms.
-/

open Bimodal.Metalogic.Algebraic.InteriorOperators

/--
S5 collapse property: (□a)ᶜ ≤ □(□a)ᶜ, i.e., ¬□a → □¬□a

This is the S5 negative introspection axiom. Derived from modal_5_collapse
(◇□φ → □φ) via contraposition and double negation elimination:
1. modal_5_collapse(φ): ◇□φ → □φ
2. Contrapose: ¬□φ → ¬◇□φ
3. Expand diamond: ¬◇□φ = ¬¬□¬□φ (syntactically)
4. DNE: ¬¬□¬□φ → □¬□φ
5. Compose: ¬□φ → □¬□φ
-/
theorem box_s5_quot (a : LindenbaumAlg) : (box_quot a)ᶜ ≤ box_quot ((box_quot a)ᶜ) := by
  induction a using Quotient.ind
  rename_i φ
  show Derives (Formula.box φ).neg (Formula.box (Formula.box φ).neg)
  unfold Derives
  -- Step 1: modal_5_collapse(φ) gives ◇□φ → □φ
  have h_collapse : ⊢ (Formula.box φ).diamond.imp (Formula.box φ) :=
    DerivationTree.axiom [] _ (Axiom.modal_5_collapse φ)
  -- Step 2: Contrapose to get ¬□φ → ¬◇□φ
  have h_contra : ⊢ (Formula.box φ).neg.imp (Formula.box φ).diamond.neg :=
    Bimodal.Theorems.Propositional.contraposition h_collapse
  -- Step 3: (□φ).diamond.neg = (□φ).neg.box.neg.neg syntactically
  have h_expand : (Formula.box φ).diamond.neg = (Formula.box φ).neg.box.neg.neg := rfl
  rw [h_expand] at h_contra
  -- Step 4: DNE: (□φ).neg.box.neg.neg → (□φ).neg.box
  have h_dne : ⊢ ((Formula.box φ).neg.box.neg.neg).imp ((Formula.box φ).neg.box) :=
    Bimodal.Theorems.Propositional.double_negation ((Formula.box φ).neg.box)
  -- Step 5: Compose via imp_trans
  exact ⟨Bimodal.Theorems.Combinators.imp_trans h_contra h_dne⟩

/--
MF axiom on quotient: □a ≤ □Ga
-/
theorem MF_quot (a : LindenbaumAlg) : box_quot a ≤ box_quot (G_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  show Derives (Formula.box φ) (Formula.box (Formula.all_future φ))
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_future φ)⟩

/--
TF axiom on quotient: □a ≤ G□a
-/
theorem TF_quot (a : LindenbaumAlg) : box_quot a ≤ G_quot (box_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  show Derives (Formula.box φ) (Formula.all_future (Formula.box φ))
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_future φ)⟩

/--
TA axiom on quotient: a ≤ G((Ha)ᶜ)ᶜ, i.e., a ≤ GPa

Note: P = ¬H¬ = some_past, so (H(aᶜ))ᶜ = ¬H¬a = Pa
And G((H(aᶜ))ᶜ) = GPa
-/
theorem TA_quot (a : LindenbaumAlg) : a ≤ G_quot (neg_quot (H_quot (neg_quot a))) := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: Derives φ (G(¬H(¬φ)))
  -- temp_a: φ → G(some_past φ) = φ → G(¬H(¬φ))
  show Derives φ (Formula.all_future (Formula.neg (Formula.all_past (Formula.neg φ))))
  -- some_past φ = φ.neg.all_past.neg
  have h : Formula.some_past φ = Formula.neg (Formula.all_past (Formula.neg φ)) := rfl
  rw [← h]
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_a φ)⟩

/--
TL axiom on quotient: Ha ⊓ Ga ≤ GHa

The axiom temp_l is: always φ → G(Hφ)
where always φ = Hφ ∧ φ ∧ Gφ

So we need: Hφ ∧ Gφ ≤ always φ → G(Hφ) → G(Hφ)
Actually we need Hφ ∧ Gφ → G(Hφ), which is weaker than temp_l.

From temp_l: (Hφ ∧ φ ∧ Gφ) → G(Hφ)
We need: Hφ ∧ Gφ → G(Hφ)

Using temp_t_future: Gφ → φ (reflexive semantics), so Hφ ∧ Gφ → Hφ ∧ φ ∧ Gφ
Then apply temp_l.
-/
theorem TL_quot (a : LindenbaumAlg) : and_quot (H_quot a) (G_quot a) ≤ G_quot (H_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  show Derives (Formula.and (Formula.all_past φ) (Formula.all_future φ))
               (Formula.all_future (Formula.all_past φ))
  unfold Derives
  -- Strategy: Hφ ∧ Gφ → always φ → G(Hφ)
  -- First show: Hφ ∧ Gφ → always φ
  -- always φ = Hφ ∧ φ ∧ Gφ
  -- So we need: Hφ ∧ Gφ → Hφ ∧ φ ∧ Gφ
  -- From Gφ → φ (temp_t_future), we get φ from Gφ
  -- Build: [Hφ ∧ Gφ] ⊢ Hφ ∧ φ ∧ Gφ
  let HG := Formula.and φ.all_past φ.all_future
  let Always := φ.always  -- Hφ ∧ φ ∧ Gφ = Hφ ∧ (φ ∧ Gφ)

  -- Derive in context [Hφ ∧ Gφ]
  have h_ctx : [HG] ⊢ Always := by
    -- Get Hφ from Hφ ∧ Gφ
    have h_hg : [HG] ⊢ HG := DerivationTree.assumption [HG] HG (List.mem_singleton.mpr rfl)

    -- lce: Hφ ∧ Gφ → Hφ
    have lce_thm : ⊢ HG.imp φ.all_past := Bimodal.Theorems.Propositional.lce_imp φ.all_past φ.all_future
    have lce_ctx : [HG] ⊢ HG.imp φ.all_past := DerivationTree.weakening [] [HG] _ lce_thm (List.nil_subset _)
    have h_H : [HG] ⊢ φ.all_past := DerivationTree.modus_ponens [HG] HG φ.all_past lce_ctx h_hg

    -- rce: Hφ ∧ Gφ → Gφ
    have rce_thm : ⊢ HG.imp φ.all_future := Bimodal.Theorems.Propositional.rce_imp φ.all_past φ.all_future
    have rce_ctx : [HG] ⊢ HG.imp φ.all_future := DerivationTree.weakening [] [HG] _ rce_thm (List.nil_subset _)
    have h_G : [HG] ⊢ φ.all_future := DerivationTree.modus_ponens [HG] HG φ.all_future rce_ctx h_hg

    -- temp_t_future: Gφ → φ
    have t_future : ⊢ φ.all_future.imp φ := DerivationTree.axiom [] _ (Axiom.temp_t_future φ)
    have t_ctx : [HG] ⊢ φ.all_future.imp φ := DerivationTree.weakening [] [HG] _ t_future (List.nil_subset _)
    have h_phi : [HG] ⊢ φ := DerivationTree.modus_ponens [HG] φ.all_future φ t_ctx h_G

    -- Build Hφ ∧ (φ ∧ Gφ) = always φ
    -- pairing: φ → (Gφ → φ ∧ Gφ)
    have pair1 : ⊢ φ.imp (φ.all_future.imp (φ.and φ.all_future)) := Bimodal.Theorems.Combinators.pairing φ φ.all_future
    have pair1_ctx : [HG] ⊢ φ.imp (φ.all_future.imp (φ.and φ.all_future)) := DerivationTree.weakening [] [HG] _ pair1 (List.nil_subset _)
    have h_step1 : [HG] ⊢ φ.all_future.imp (φ.and φ.all_future) := DerivationTree.modus_ponens [HG] _ _ pair1_ctx h_phi
    have h_phiG : [HG] ⊢ φ.and φ.all_future := DerivationTree.modus_ponens [HG] _ _ h_step1 h_G

    -- pairing: Hφ → ((φ ∧ Gφ) → Hφ ∧ (φ ∧ Gφ))
    have pair2 : ⊢ φ.all_past.imp ((φ.and φ.all_future).imp (φ.all_past.and (φ.and φ.all_future))) :=
      Bimodal.Theorems.Combinators.pairing φ.all_past (φ.and φ.all_future)
    have pair2_ctx : [HG] ⊢ φ.all_past.imp ((φ.and φ.all_future).imp (φ.all_past.and (φ.and φ.all_future))) :=
      DerivationTree.weakening [] [HG] _ pair2 (List.nil_subset _)
    have h_step2 : [HG] ⊢ (φ.and φ.all_future).imp (φ.all_past.and (φ.and φ.all_future)) :=
      DerivationTree.modus_ponens [HG] _ _ pair2_ctx h_H
    have h_always : [HG] ⊢ φ.all_past.and (φ.and φ.all_future) := DerivationTree.modus_ponens [HG] _ _ h_step2 h_phiG
    exact h_always

  -- Now apply temp_l: always φ → G(Hφ)
  have temp_l : ⊢ Always.imp (φ.all_past.all_future) := DerivationTree.axiom [] _ (Axiom.temp_l φ)
  have temp_l_ctx : [HG] ⊢ Always.imp (φ.all_past.all_future) := DerivationTree.weakening [] [HG] _ temp_l (List.nil_subset _)
  have h_result : [HG] ⊢ φ.all_past.all_future := DerivationTree.modus_ponens [HG] _ _ temp_l_ctx h_ctx

  -- Apply deduction theorem
  exact ⟨Bimodal.Metalogic.Core.deduction_theorem [] HG (φ.all_past.all_future) h_result⟩

/--
Linearity on quotient.

The linearity axiom temp_linearity states:
  Fφ ∧ Fψ → F(φ ∧ ψ) ∨ F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ)

where F = some_future = ¬G¬.

In the Boolean algebra on LindenbaumAlg:
- complement (ᶜ) = neg_quot
- inf (⊓) = and_quot
- sup (⊔) = or_quot
- G_quot lifts all_future

We need to show that the Boolean algebra operations on the quotient
match the formula-level operations used in temp_linearity.
-/
theorem linearity_quot (a b : LindenbaumAlg) :
    (G_quot aᶜ)ᶜ ⊓ (G_quot bᶜ)ᶜ ≤
    (G_quot (a ⊓ b)ᶜ)ᶜ ⊔ (G_quot (a ⊓ (G_quot bᶜ)ᶜ)ᶜ)ᶜ ⊔ (G_quot ((G_quot aᶜ)ᶜ ⊓ b)ᶜ)ᶜ := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  -- The BooleanAlgebra sup is left-associated: (A ⊔ B) ⊔ C
  -- But temp_linearity produces right-associated: A ∨ (B ∨ C)
  -- Use sup_assoc to convert left to right association
  rw [sup_assoc]
  -- Now the goal matches the temp_linearity axiom after reduction
  show Derives (Formula.and (Formula.some_future φ) (Formula.some_future ψ))
    (Formula.or (Formula.some_future (φ.and ψ))
      (Formula.or (Formula.some_future (φ.and (Formula.some_future ψ)))
        (Formula.some_future ((Formula.some_future φ).and ψ))))
  unfold Derives
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_linearity φ ψ)⟩

/--
The Lindenbaum algebra is a Shift-Closed Tense S5 Algebra.
-/
noncomputable instance lindenbaumSTSA : STSA LindenbaumAlg where
  box := box_quot
  G := G_quot
  H := H_quot
  sigma := sigma_quot

  box_deflationary := box_le_self
  box_monotone := box_monotone
  box_idempotent := box_idempotent
  box_s5 := box_s5_quot

  G_monotone := G_monotone
  H_monotone := H_monotone

  sigma_involution := sigma_quot_involution
  sigma_neg := sigma_quot_neg
  sigma_sup := sigma_quot_sup
  sigma_G := sigma_quot_G_H
  sigma_H := sigma_quot_H_G
  sigma_box := sigma_quot_box

  MF := MF_quot
  TF := TF_quot
  TA := TA_quot
  TL := TL_quot
  linearity := linearity_quot

/-!
## Basic Derived Lemmas
-/

variable {α : Type*} [STSA α]

/-- Sigma preserves inf: σ(a ⊓ b) = σa ⊓ σb -/
theorem sigma_inf (a b : α) : STSA.sigma (a ⊓ b) = STSA.sigma a ⊓ STSA.sigma b := by
  -- a ⊓ b = (aᶜ ⊔ bᶜ)ᶜ by De Morgan
  have h : a ⊓ b = (aᶜ ⊔ bᶜ)ᶜ := by simp only [compl_compl, ← compl_inf]
  rw [h, STSA.sigma_neg, STSA.sigma_sup, STSA.sigma_neg, STSA.sigma_neg]
  simp only [compl_compl, ← compl_inf]

end Bimodal.Metalogic.Algebraic.TenseS5Algebra
