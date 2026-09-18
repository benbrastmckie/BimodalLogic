/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Automation.LemmaDB

/-!
# Natural Deduction Rules: Negation Intro/Elim, Biconditional, Disjunction Elimination

Negation introduction/elimination (ni, ne), biconditional intro (biImp),
and disjunction elimination for the Hilbert-style proof system.
-/

namespace FormalSystem.Theorems.Propositional

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

noncomputable section

/-!
## Phase 5: Natural Deduction Style Rules

Negation Introduction (NI), Negation Elimination (NE), Disjunction Elimination (DE),
and Biconditional Introduction (BI_IMP) in Hilbert-style proof calculus.

These theorems provide natural deduction style inference patterns.
-/

/--
Negation Introduction (NI): If `Γ, A ⊢ B` and `Γ, A ⊢ ¬B`, then `Γ ⊢ ¬A`.

This is the standard proof-by-contradiction pattern: if assuming A leads to a
contradiction (both B and ¬B), then ¬A holds.

**Proof Strategy**:
1. From `h1 : (A :: Γ) ⊢ ¬B` and `h2 : (A :: Γ) ⊢ B`, derive `(A :: Γ) ⊢ ⊥` using modus ponens
2. Apply deductionTheorem: `Γ ⊢ A → ⊥` = `Γ ⊢ ¬A`

**Complexity**: Medium

**Dependencies**: `DerivationTree.modus_ponens`, `deductionTheorem`
-/
def ni {fc : FrameClass} (Γ : Context) (A B : Formula) (h1 : (A :: Γ) ⊢[fc] B.neg)
    (h2 : (A :: Γ) ⊢[fc] B) : Γ ⊢[fc] A.neg := by
  -- From h1 and h2, derive (A :: Γ) ⊢ ⊥
  -- ¬B = B → ⊥, so modus ponens gives ⊥
  have h_bot : (A :: Γ) ⊢[fc] Formula.bot :=
    DerivationTree.modus_ponens (A :: Γ) B Formula.bot h1 h2
  -- Apply deduction theorem: Γ ⊢ A → ⊥ = Γ ⊢ ¬A
  exact FormalSystem.Metalogic.Core.deductionTheorem Γ A Formula.bot h_bot

/--
Biconditional Introduction (Implication Form): `⊢ (A → B) → ((B → A) → (A ↔ B))`.

This is the curried form of biconditional introduction for compositional proofs.
The context-based `iffIntro` already exists; this provides the pure implication form.

**Recall**: `A ↔ B = (A → B) ∧ (B → A)`

**Proof Strategy**:
1. From context `[(A → B), (B → A)]`, derive both by assumption
2. Apply `pairing` to get `(A → B) ∧ (B → A)`
3. Apply deductionTheorem twice to lift to pure implication form

**Complexity**: Medium

**Dependencies**: `deductionTheorem`, `pairing`, `DerivationTree.assumption`,
`DerivationTree.weakening`
-/
@[tmLemma]
def biImp {fc : FrameClass} (A B : Formula) :
    ⊢[fc] (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) := by
  -- First, derive [(A → B), (B → A)] ⊢ (A → B) ∧ (B → A)
  have h_in_ctx : [(B.imp A), (A.imp B)] ⊢[fc] (A.imp B).and (B.imp A) := by
    -- Get (A → B) from context
    have h_ab : [(B.imp A), (A.imp B)] ⊢[fc] A.imp B := by
      apply DerivationTree.assumption
      simp
    -- Get (B → A) from context
    have h_ba : [(B.imp A), (A.imp B)] ⊢[fc] B.imp A := by
      apply DerivationTree.assumption
      simp
    -- Use pairing: X → Y → (X ∧ Y)
    have pair_inst : ⊢[fc] (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      pairing (A.imp B) (B.imp A)
    -- Weaken to context
    have pair_ctx : [(B.imp A), (A.imp B)] ⊢[fc]
        (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      DerivationTree.weakening [] _ _ pair_inst (List.nil_subset _)
    -- Apply modus ponens twice
    have step1 : [(B.imp A), (A.imp B)] ⊢[fc] (B.imp A).imp ((A.imp B).and (B.imp A)) :=
      DerivationTree.modus_ponens _ _ _ pair_ctx h_ab
    exact DerivationTree.modus_ponens _ _ _ step1 h_ba
  -- Apply deduction theorem: [(A → B)] ⊢ (B → A) → ((A → B) ∧ (B → A))
  have step1 : [(A.imp B)] ⊢[fc] (B.imp A).imp ((A.imp B).and (B.imp A)) :=
    FormalSystem.Metalogic.Core.deductionTheorem [(A.imp B)] (B.imp A) _ h_in_ctx
  -- Apply deduction theorem: [] ⊢ (A → B) → ((B → A) → ((A → B) ∧ (B → A)))
  exact FormalSystem.Metalogic.Core.deductionTheorem [] (A.imp B) _ step1

/--
Disjunction Elimination (DE): If `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`.

This is case analysis: if we can derive C from either A or B (separately),
then from A ∨ B we can derive C.

**Recall**: `A ∨ B = ¬A → B`

**Proof Strategy**:
1. Apply deductionTheorem to get `Γ ⊢ A → C` and `Γ ⊢ B → C`
2. Weaken both to `((A.or B) :: Γ)`
3. Get `A ∨ B = ¬A → B` from context via assumption
4. Apply `classicalMerge`: `(A → C) → ((¬A → C) → C)`
5. Compose `A ∨ B` with `B → C` via bCombinator to get `¬A → C`
6. Apply modus_ponens chain to derive C

**Complexity**: Complex

**Dependencies**: `deductionTheorem`, `DerivationTree.weakening`, `classicalMerge`,
               `bCombinator`, `DerivationTree.assumption`
-/
noncomputable def de {fc : FrameClass} (Γ : Context) (A B C : Formula) (h1 : (A :: Γ) ⊢[fc] C)
    (h2 : (B :: Γ) ⊢[fc] C) :
    ((A.or B) :: Γ) ⊢[fc] C := by
  -- Apply deduction theorem to get Γ ⊢ A → C
  have ac : Γ ⊢[fc] A.imp C :=
    FormalSystem.Metalogic.Core.deductionTheorem Γ A C h1
  -- Apply deduction theorem to get Γ ⊢ B → C
  have bc : Γ ⊢[fc] B.imp C :=
    FormalSystem.Metalogic.Core.deductionTheorem Γ B C h2
  -- Weaken A → C to context ((A.or B) :: Γ)
  have ac_ctx : ((A.or B) :: Γ) ⊢[fc] A.imp C :=
    DerivationTree.weakening Γ _ _ ac
      (by intro x hx; simp only [List.mem_cons]; right; exact hx)
  -- Weaken B → C to context ((A.or B) :: Γ)
  have bc_ctx : ((A.or B) :: Γ) ⊢[fc] B.imp C :=
    DerivationTree.weakening Γ _ _ bc
      (by intro x hx; simp only [List.mem_cons]; right; exact hx)
  -- Get A ∨ B from context
  have h_disj : ((A.or B) :: Γ) ⊢[fc] A.or B := by
    apply DerivationTree.assumption
    simp
  -- A ∨ B = ¬A → B (by definition)
  -- We need ¬A → C from (¬A → B) and (B → C) via bCombinator

  -- bCombinator: (B → C) → (¬A → B) → (¬A → C)
  have b_inst : ⊢[fc] (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    bCombinator
  have b_ctx : ((A.or B) :: Γ) ⊢[fc] (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    DerivationTree.weakening [] _ _ b_inst (List.nil_subset _)
  have step1 : ((A.or B) :: Γ) ⊢[fc] (A.neg.imp B).imp (A.neg.imp C) :=
    DerivationTree.modus_ponens _ _ _ b_ctx bc_ctx
  -- h_disj : ((A.or B) :: Γ) ⊢ A.or B
  -- A.or B unfolds to ¬A → B
  have h_disj_unf : ((A.or B) :: Γ) ⊢[fc] A.neg.imp B := by
    unfold Formula.or at h_disj
    exact h_disj
  -- Get ¬A → C
  have nac : ((A.or B) :: Γ) ⊢[fc] A.neg.imp C :=
    DerivationTree.modus_ponens _ _ _ step1 h_disj_unf
  -- Now use classicalMerge: (A → C) → ((¬A → C) → C)
  have cm : ⊢[fc] (A.imp C).imp ((A.neg.imp C).imp C) :=
    classicalMerge A C
  have cm_ctx : ((A.or B) :: Γ) ⊢[fc] (A.imp C).imp ((A.neg.imp C).imp C) :=
    DerivationTree.weakening [] _ _ cm (List.nil_subset _)
  have step2 : ((A.or B) :: Γ) ⊢[fc] (A.neg.imp C).imp C :=
    DerivationTree.modus_ponens _ _ _ cm_ctx ac_ctx
  exact DerivationTree.modus_ponens _ _ _ step2 nac

end -- noncomputable section


end FormalSystem.Theorems.Propositional
