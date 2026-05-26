import Bimodal.Theorems.Propositional.Connectives

/-!
# Natural Deduction Rules: Negation Intro/Elim, Biconditional, Disjunction Elimination

Negation introduction/elimination (ni, ne), biconditional intro (bi_imp),
and disjunction elimination for the Hilbert-style proof system.
-/

namespace Bimodal.Theorems.Propositional

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

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
2. Apply deduction_theorem: `Γ ⊢ A → ⊥` = `Γ ⊢ ¬A`

**Complexity**: Medium

**Dependencies**: `DerivationTree.modus_ponens`, `deduction_theorem`
-/
def ni (Γ : Context) (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg := by
  -- From h1 and h2, derive (A :: Γ) ⊢ ⊥
  -- ¬B = B → ⊥, so modus ponens gives ⊥
  have h_bot : (A :: Γ) ⊢ Formula.bot :=
    DerivationTree.modus_ponens (A :: Γ) B Formula.bot h1 h2
  -- Apply deduction theorem: Γ ⊢ A → ⊥ = Γ ⊢ ¬A
  exact Bimodal.Metalogic.Core.deduction_theorem Γ A Formula.bot h_bot

/--
Negation Elimination (NE): If `Γ, ¬A ⊢ B` and `Γ, ¬A ⊢ ¬B`, then `Γ ⊢ A`.

This is classical proof by contradiction (indirect proof): if assuming ¬A leads to
a contradiction, then A holds.

**Proof Strategy**:
1. From `h1 : (A.neg :: Γ) ⊢ ¬B` and `h2 : (A.neg :: Γ) ⊢ B`, derive `(A.neg :: Γ) ⊢ ⊥`
2. Apply deduction_theorem: `Γ ⊢ ¬A → ⊥` = `Γ ⊢ ¬¬A`
3. Apply DNE (double_negation axiom): `Γ ⊢ A`

**Complexity**: Medium

**Dependencies**: `DerivationTree.modus_ponens`, `DerivationTree.weakening`,
`double_negation` (derived theorem), `deduction_theorem`
-/
def ne (Γ : Context) (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A := by
  -- From h1 and h2, derive (A.neg :: Γ) ⊢ ⊥
  have h_bot : (A.neg :: Γ) ⊢ Formula.bot :=
    DerivationTree.modus_ponens (A.neg :: Γ) B Formula.bot h1 h2
  -- Apply deduction theorem: Γ ⊢ ¬A → ⊥ = Γ ⊢ ¬¬A
  have h_neg_neg : Γ ⊢ A.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem Γ A.neg Formula.bot h_bot
  -- Apply DNE: ¬¬A → A
  have dne : ⊢ A.neg.neg.imp A :=
    double_negation A
  have dne_ctx : Γ ⊢ A.neg.neg.imp A :=
    DerivationTree.weakening [] Γ _ dne (List.nil_subset Γ)
  exact DerivationTree.modus_ponens Γ A.neg.neg A dne_ctx h_neg_neg

/--
Biconditional Introduction (Implication Form): `⊢ (A → B) → ((B → A) → (A ↔ B))`.

This is the curried form of biconditional introduction for compositional proofs.
The context-based `iff_intro` already exists; this provides the pure implication form.

**Recall**: `A ↔ B = (A → B) ∧ (B → A)`

**Proof Strategy**:
1. From context `[(A → B), (B → A)]`, derive both by assumption
2. Apply `pairing` to get `(A → B) ∧ (B → A)`
3. Apply deduction_theorem twice to lift to pure implication form

**Complexity**: Medium

**Dependencies**: `deduction_theorem`, `pairing`, `DerivationTree.assumption`, `DerivationTree.weakening`
-/
def bi_imp (A B : Formula) :
    ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) := by
  -- First, derive [(A → B), (B → A)] ⊢ (A → B) ∧ (B → A)
  have h_in_ctx : [(B.imp A), (A.imp B)] ⊢ (A.imp B).and (B.imp A) := by
    -- Get (A → B) from context
    have h_ab : [(B.imp A), (A.imp B)] ⊢ A.imp B := by
      apply DerivationTree.assumption
      simp
    -- Get (B → A) from context
    have h_ba : [(B.imp A), (A.imp B)] ⊢ B.imp A := by
      apply DerivationTree.assumption
      simp
    -- Use pairing: X → Y → (X ∧ Y)
    have pair_inst : ⊢ (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      pairing (A.imp B) (B.imp A)
    -- Weaken to context
    have pair_ctx : [(B.imp A), (A.imp B)] ⊢
        (A.imp B).imp ((B.imp A).imp ((A.imp B).and (B.imp A))) :=
      DerivationTree.weakening [] _ _ pair_inst (List.nil_subset _)
    -- Apply modus ponens twice
    have step1 : [(B.imp A), (A.imp B)] ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
      DerivationTree.modus_ponens _ _ _ pair_ctx h_ab
    exact DerivationTree.modus_ponens _ _ _ step1 h_ba

  -- Apply deduction theorem: [(A → B)] ⊢ (B → A) → ((A → B) ∧ (B → A))
  have step1 : [(A.imp B)] ⊢ (B.imp A).imp ((A.imp B).and (B.imp A)) :=
    Bimodal.Metalogic.Core.deduction_theorem [(A.imp B)] (B.imp A) _ h_in_ctx

  -- Apply deduction theorem: [] ⊢ (A → B) → ((B → A) → ((A → B) ∧ (B → A)))
  exact Bimodal.Metalogic.Core.deduction_theorem [] (A.imp B) _ step1

/--
Disjunction Elimination (DE): If `Γ, A ⊢ C` and `Γ, B ⊢ C`, then `Γ, A ∨ B ⊢ C`.

This is case analysis: if we can derive C from either A or B (separately),
then from A ∨ B we can derive C.

**Recall**: `A ∨ B = ¬A → B`

**Proof Strategy**:
1. Apply deduction_theorem to get `Γ ⊢ A → C` and `Γ ⊢ B → C`
2. Weaken both to `((A.or B) :: Γ)`
3. Get `A ∨ B = ¬A → B` from context via assumption
4. Apply `classical_merge`: `(A → C) → ((¬A → C) → C)`
5. Compose `A ∨ B` with `B → C` via b_combinator to get `¬A → C`
6. Apply modus_ponens chain to derive C

**Complexity**: Complex

**Dependencies**: `deduction_theorem`, `DerivationTree.weakening`, `classical_merge`,
               `b_combinator`, `DerivationTree.assumption`
-/
noncomputable def de (Γ : Context) (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) :
    ((A.or B) :: Γ) ⊢ C := by
  -- Apply deduction theorem to get Γ ⊢ A → C
  have ac : Γ ⊢ A.imp C :=
    Bimodal.Metalogic.Core.deduction_theorem Γ A C h1

  -- Apply deduction theorem to get Γ ⊢ B → C
  have bc : Γ ⊢ B.imp C :=
    Bimodal.Metalogic.Core.deduction_theorem Γ B C h2

  -- Weaken A → C to context ((A.or B) :: Γ)
  have ac_ctx : ((A.or B) :: Γ) ⊢ A.imp C :=
    DerivationTree.weakening Γ _ _ ac (by intro x hx; simp; right; exact hx)

  -- Weaken B → C to context ((A.or B) :: Γ)
  have bc_ctx : ((A.or B) :: Γ) ⊢ B.imp C :=
    DerivationTree.weakening Γ _ _ bc (by intro x hx; simp; right; exact hx)

  -- Get A ∨ B from context
  have h_disj : ((A.or B) :: Γ) ⊢ A.or B := by
    apply DerivationTree.assumption
    simp

  -- A ∨ B = ¬A → B (by definition)
  -- We need ¬A → C from (¬A → B) and (B → C) via b_combinator

  -- b_combinator: (B → C) → (¬A → B) → (¬A → C)
  have b_inst : ⊢ (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    b_combinator

  have b_ctx : ((A.or B) :: Γ) ⊢ (B.imp C).imp ((A.neg.imp B).imp (A.neg.imp C)) :=
    DerivationTree.weakening [] _ _ b_inst (List.nil_subset _)

  have step1 : ((A.or B) :: Γ) ⊢ (A.neg.imp B).imp (A.neg.imp C) :=
    DerivationTree.modus_ponens _ _ _ b_ctx bc_ctx

  -- h_disj : ((A.or B) :: Γ) ⊢ A.or B
  -- A.or B unfolds to ¬A → B
  have h_disj_unf : ((A.or B) :: Γ) ⊢ A.neg.imp B := by
    unfold Formula.or at h_disj
    exact h_disj

  -- Get ¬A → C
  have nac : ((A.or B) :: Γ) ⊢ A.neg.imp C :=
    DerivationTree.modus_ponens _ _ _ step1 h_disj_unf

  -- Now use classical_merge: (A → C) → ((¬A → C) → C)
  have cm : ⊢ (A.imp C).imp ((A.neg.imp C).imp C) :=
    classical_merge A C

  have cm_ctx : ((A.or B) :: Γ) ⊢ (A.imp C).imp ((A.neg.imp C).imp C) :=
    DerivationTree.weakening [] _ _ cm (List.nil_subset _)

  have step2 : ((A.or B) :: Γ) ⊢ (A.neg.imp C).imp C :=
    DerivationTree.modus_ponens _ _ _ cm_ctx ac_ctx

  exact DerivationTree.modus_ponens _ _ _ step2 nac

end -- noncomputable section

/--
From (A ∨ B), ¬A, and ¬B, derive ⊥.

This is the key lemma for disjunction elimination when both alternatives are refuted:
if we have A ∨ B and both A and B lead to contradiction, then we can derive ⊥.

**Proof Strategy**:
1. From A :: Γ, derive ⊥ using h_neg_A (weakened) and the assumption A
2. From B :: Γ, derive ⊥ using h_neg_B (weakened) and the assumption B
3. Apply disjunction elimination `de` to get (A ∨ B) :: Γ ⊢ ⊥
4. Apply cut with h_or to eliminate A ∨ B from context
-/
noncomputable def or_elim_neg_neg (Γ : Context) (A B : Formula)
    (h_or : Γ ⊢ A.or B)
    (h_neg_A : Γ ⊢ A.neg)
    (h_neg_B : Γ ⊢ B.neg) :
    Γ ⊢ Formula.bot := by
  -- From A :: Γ, derive ⊥
  have h_A_bot : (A :: Γ) ⊢ Formula.bot := by
    have h_A : (A :: Γ) ⊢ A := DerivationTree.assumption (A :: Γ) A (@List.mem_cons_self _ A Γ)
    have h_neg_A' : (A :: Γ) ⊢ A.neg :=
      DerivationTree.weakening Γ (A :: Γ) A.neg h_neg_A (List.subset_cons_of_subset A (List.Subset.refl Γ))
    -- neg φ = φ.imp bot, so modus ponens gives us bot
    exact DerivationTree.modus_ponens (A :: Γ) A Formula.bot h_neg_A' h_A
  -- From B :: Γ, derive ⊥
  have h_B_bot : (B :: Γ) ⊢ Formula.bot := by
    have h_B : (B :: Γ) ⊢ B := DerivationTree.assumption (B :: Γ) B (@List.mem_cons_self _ B Γ)
    have h_neg_B' : (B :: Γ) ⊢ B.neg :=
      DerivationTree.weakening Γ (B :: Γ) B.neg h_neg_B (List.subset_cons_of_subset B (List.Subset.refl Γ))
    -- neg φ = φ.imp bot, so modus ponens gives us bot
    exact DerivationTree.modus_ponens (B :: Γ) B Formula.bot h_neg_B' h_B
  -- Apply disjunction elimination: de Γ A B ⊥ h_A_bot h_B_bot : (A.or B) :: Γ ⊢ ⊥
  have h_disj_bot : ((A.or B) :: Γ) ⊢ Formula.bot := de Γ A B Formula.bot h_A_bot h_B_bot
  -- Apply cut with h_or: deduction_theorem gives Γ ⊢ (A.or B) → ⊥, then modus_ponens with h_or
  have h_impl : Γ ⊢ (A.or B).imp Formula.bot :=
    Bimodal.Metalogic.Core.deduction_theorem Γ (A.or B) Formula.bot h_disj_bot
  exact DerivationTree.modus_ponens Γ (A.or B) Formula.bot h_impl h_or


end Bimodal.Theorems.Propositional
