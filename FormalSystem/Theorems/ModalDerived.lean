/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.TemporalDerived

/-!
# Derived Modal and Temporal Object-Level Theorems

Small derivation-tree helpers that were previously declared inside `Metalogic/Bundle/`, where
they were metalogic-adjacent by location only: every one of them is a closed derivation in the
object logic with no MCS, frame-class or canonical-model content.

They are collected here so the canonical-model modules can reach them without importing the
`Bundle/` machinery, and so the `Bundle/` files that hosted them could be retired.

## Main Definitions

- `dneTheorem`: `⊢ ¬¬φ → φ`
- `boxDneTheorem`: `⊢ □¬¬φ → □φ`
- `gDneTheorem` / `hDneTheorem`: the `G`/`H` analogues
- `modal5CollapseTheorem`: `⊢ ◇□φ → □φ` (the `modal_5_collapse` axiom, wrapped)
- `axiom5NegativeIntrospection` / `negBoxToBoxNegBox`: `⊢ ¬□φ → □¬□φ`
- `pastTempA`: `⊢ φ → H(F(φ))`

## References

- `Theorems/Propositional/Connectives.lean`: `doubleNegation`, `contraposition`
- `Theorems/Combinators.lean`: `impTrans`
-/

namespace FormalSystem.Theorems.ModalDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/--
Double negation elimination theorem: ⊢ ¬¬φ → φ

This is derived using Peirce's law and Ex Falso.
-/
noncomputable def dneTheorem (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  FormalSystem.Theorems.Propositional.doubleNegation phi

/--
Box distributes over double negation elimination: ⊢ Box(¬¬φ) → Box φ

Proof: By necessitation on DNE and modal K distribution.
-/
noncomputable def boxDneTheorem (phi : Formula) :
    [] ⊢ (Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi) := by
  -- Step 1: ⊢ ¬¬φ → φ (DNE)
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dneTheorem phi
  -- Step 2: ⊢ Box(¬¬φ → φ) (necessitation)
  have h_box_dne : [] ⊢ Formula.box ((Formula.neg (Formula.neg phi)).imp phi) :=
    DerivationTree.necessitation _ h_dne
  -- Step 3: ⊢ Box(¬¬φ → φ) → (Box(¬¬φ) → Box φ) (K distribution axiom)
  have h_K : [] ⊢ (Formula.box ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.box (Formula.neg (Formula.neg phi))).imp (Formula.box phi)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist _ _) trivial
  -- Step 4: ⊢ Box(¬¬φ) → Box φ (modus ponens)
  exact DerivationTree.modus_ponens [] _ _ h_K h_box_dne

/--
Modal 5 collapse axiom instance: `⊢ ◇□φ → □φ`.

This is a wrapper around the axiom for convenience.
-/
noncomputable def modal5CollapseTheorem (phi : Formula) :
    [] ⊢ Formula.box phi |>.diamond.imp (Formula.box phi) :=
  DerivationTree.axiom [] _ (Axiom.modal_5_collapse phi) trivial

/--
Axiom 5 (Negative Introspection): `⊢ ¬□φ → □¬□φ`.

This derives negative introspection from modal_5_collapse via contraposition.

**Proof**:
1. `modal_5_collapse` gives `⊢ ◇□φ → □φ`
2. By contraposition: `⊢ ¬□φ → ¬◇□φ`
3. `¬◇□φ = ¬(¬□(¬□φ)) = □(¬□φ)` by definition and double negation
4. Therefore: `⊢ ¬□φ → □(¬□φ)`

The key observation is that `¬◇A = □¬A` (necessity of the negation equals
negation of possibility).
-/
noncomputable def axiom5NegativeIntrospection (phi : Formula) :
    [] ⊢ (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg) := by
  -- Step 1: modal_5_collapse gives ◇□φ → □φ
  have h_collapse : [] ⊢ (Formula.box phi).diamond.imp (Formula.box phi) :=
    modal5CollapseTheorem phi
  -- Step 2: By contraposition: ¬□φ → ¬◇□φ
  have h_contra : [] ⊢ (Formula.box phi).neg.imp (Formula.box phi).diamond.neg :=
    FormalSystem.Theorems.Propositional.contraposition h_collapse
  -- Step 3: ¬◇□φ = □¬□φ by definition
  -- ◇A = ¬□¬A, so ¬◇A = ¬¬□¬A
  -- ¬◇□φ = ¬¬□(¬□φ) = □(¬□φ) (by double negation)
  --
  -- But Formula.diamond unfolds as: phi.diamond = phi.neg.box.neg
  -- So (Formula.box phi).diamond = (Formula.box phi).neg.box.neg
  -- Therefore (Formula.box phi).diamond.neg = ((Formula.box phi).neg.box.neg).neg
  --                                         = (Formula.box phi).neg.box (by DNE)
  --
  -- We need to show (Formula.box phi).diamond.neg equals Formula.box (Formula.box phi).neg
  -- This requires applying double negation elimination.
  --
  -- Expand the diamond:
  -- (Formula.box phi).diamond = (Formula.box phi).neg.box.neg
  -- So (Formula.box phi).diamond.neg = (Formula.box phi).neg.box.neg.neg
  --
  -- We have h_contra : ¬□φ → ((□φ).neg.box.neg).neg
  -- We need: ¬□φ → (□φ).neg.box
  --
  -- The gap: ((□φ).neg.box.neg).neg vs (□φ).neg.box
  -- These are syntactically different but semantically equivalent (double negation)

  -- Use double negation elimination to convert ¬¬□(¬□φ) to □(¬□φ)
  -- h_contra has conclusion: (Formula.box phi).diamond.neg
  --                        = ((Formula.box phi).neg.box.neg).neg  (expanding diamond)
  --
  -- Goal is: (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg)
  --        = (Formula.box phi).neg.imp ((Formula.box phi).neg.box)

  -- The diamond of A is: A.neg.box.neg (¬□¬A)
  -- So (Formula.box phi).diamond = (Formula.box phi).neg.box.neg

  -- The conclusion of h_contra is:
  -- ((Formula.box phi).neg.box.neg).neg = (Formula.box phi).neg.box.neg.neg

  -- We need to prove: (Formula.box phi).neg.box

  -- Use DNE: ¬¬B → B where B = (Formula.box phi).neg.box
  have h_dne : [] ⊢ ((Formula.box phi).neg.box.neg.neg).imp ((Formula.box phi).neg.box) :=
    FormalSystem.Theorems.Propositional.doubleNegation ((Formula.box phi).neg.box)
  -- Now compose: ¬□φ → ¬¬□¬□φ → □¬□φ
  -- h_contra : ¬□φ → (diamond □φ).neg = ¬□φ → (¬□(¬□φ)).neg = ¬□φ → ¬¬□¬□φ
  -- h_dne : ¬¬□¬□φ → □¬□φ

  -- Check the types align:
  -- h_contra : (Formula.box phi).neg.imp (Formula.box phi).diamond.neg
  -- (Formula.box phi).diamond.neg = ((Formula.box phi).neg.box.neg).neg
  --                               = (Formula.box phi).neg.box.neg.neg

  -- So h_contra : (Formula.box phi).neg.imp ((Formula.box phi).neg.box.neg.neg)
  -- And h_dne : (Formula.box phi).neg.box.neg.neg.imp ((Formula.box phi).neg.box)

  -- We need: (Formula.box phi).neg.imp ((Formula.box phi).neg.box)

  -- Use impTrans to compose them
  have h_result : [] ⊢ (Formula.box phi).neg.imp ((Formula.box phi).neg.box) := by
    -- First verify h_contra has the right form
    have h_contra_expanded :
      (Formula.box phi).diamond.neg = (Formula.box phi).neg.box.neg.neg := rfl
    rw [h_contra_expanded] at h_contra
    -- Now h_contra : (Formula.box phi).neg.imp ((Formula.box phi).neg.box.neg.neg)

    -- Compose with DNE using impTrans
    exact FormalSystem.Theorems.Combinators.impTrans h_contra h_dne
  exact h_result

/--
Alternative name for axiom 5: `negBoxToBoxNegBox`.

This is the form needed for BoxContent preservation: if ¬□φ is true at a world,
then □(¬□φ) is also true at that world (negative introspection).
-/
noncomputable def negBoxToBoxNegBox (phi : Formula) :
    [] ⊢ (Formula.box phi).neg.imp (Formula.box (Formula.box phi).neg) :=
  axiom5NegativeIntrospection phi

/--
G distributes over double negation elimination: G(neg(neg phi)) -> G(phi)

**Proof Strategy**:
1. dneTheorem: neg(neg phi) -> phi
2. temporal_necessitation: G(neg(neg phi) -> phi)
3. temp_k_dist: G(A -> B) -> (G(A) -> G(B))
4. modus_ponens
-/
noncomputable def gDneTheorem (phi : Formula) :
    [] ⊢ (Formula.allFuture (Formula.neg (Formula.neg phi))).imp (Formula.allFuture phi) := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dneTheorem phi
  have h_G_dne : [] ⊢ Formula.allFuture ((Formula.neg (Formula.neg phi)).imp phi) :=
    DerivationTree.temporal_necessitation _ h_dne
  have h_K : [] ⊢ (Formula.allFuture ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.allFuture (Formula.neg (Formula.neg phi))).imp
                   (Formula.allFuture phi)) :=
    FormalSystem.Theorems.TemporalDerived.temporalKDistDerived (Formula.neg (Formula.neg phi)) phi
  exact DerivationTree.modus_ponens [] _ _ h_K h_G_dne

/--
H distributes over double negation elimination: H(neg(neg phi)) -> H(phi)

Past analog of gDneTheorem.
-/
noncomputable def hDneTheorem (phi : Formula) :
    [] ⊢ (Formula.allPast (Formula.neg (Formula.neg phi))).imp (Formula.allPast phi) := by
  have h_dne : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi := dneTheorem phi
  have h_H_dne : [] ⊢ Formula.allPast ((Formula.neg (Formula.neg phi)).imp phi) :=
    FormalSystem.Theorems.pastNecessitation _ h_dne
  have h_K : [] ⊢ (Formula.allPast ((Formula.neg (Formula.neg phi)).imp phi)).imp
               ((Formula.allPast (Formula.neg (Formula.neg phi))).imp (Formula.allPast phi)) :=
    FormalSystem.Theorems.pastKDist _ _
  exact DerivationTree.modus_ponens [] _ _ h_K h_H_dne

/-- Past analog of the `connect_past` axiom: ⊢ φ → H(F(φ)).
Applied directly as an axiom instance; `Axiom.connect_past` is the constructor. -/
noncomputable def pastTempA (psi : Formula) :
    [] ⊢ psi.imp psi.someFuture.allPast :=
  DerivationTree.axiom [] _ (Axiom.connect_past psi) trivial

end FormalSystem.Theorems.ModalDerived
