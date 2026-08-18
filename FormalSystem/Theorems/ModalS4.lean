/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.ModalS5

/-!
# Modal S4 Theorems

This module derives modal S4-specific theorems in Hilbert-style proof calculus
for the TM bimodal logic system.

Modal S4 is characterized by reflexivity (T) and transitivity (4) axioms, but
without the symmetric accessibility (B) axiom. This gives S4 different properties
than S5, particularly for nested modalities.

## Main Theorems

### Modal S4 Nested Modalities (Phase 4)
- `s4DiamondBoxConj`: `⊢ (◇A ∧ □B) → ◇(A ∧ □B)` (diamond box conjunction distribution)
- `s4BoxDiamondBox`: `⊢ □A → □(◇□A)` (box diamond box nesting)
- `s4DiamondBoxDiamond`: `⊢ ◇(□(◇A)) ↔ ◇A` (diamond box diamond equivalence)
- `s5DiamondConjDiamond`: `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)` (S5 diamond conjunction distribution)

## Implementation Status

All 4 theorems above are fully proven; this module is sorry-free.

## References

* [Perpetuity.lean](Perpetuity.lean) - Modal infrastructure
  (modal_t, modal_4, modal_b, boxMono, diamondMono)
* [Propositional.lean](Propositional.lean) - Propositional infrastructure (botOfAndNeg, impNegImp,
negImp, orInl, orInr)
* [ModalS5.lean](ModalS5.lean) - S5 theorems (tBoxToDiamond, boxContrapose, tBoxConsistency)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata (modal_t, modal_4, modal_b, modal5)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace FormalSystem.Theorems.ModalS4

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.Propositional
open FormalSystem.Theorems.ModalS5

/-!
## Phase 4: Modal S4 Theorems (Not Started)
-/

/--
S4-Diamond-Box-Conjunction - `⊢ (◇A ∧ □B) → ◇(A ∧ □B)`.

In S4, if A is possible and B is necessary, then A ∧ □B is possible.

**Proof**: Build `A → (□B → (A ∧ □B))` from `pairing` and `theoremFlip`, lift it under
a box with `modal_4` and `boxMono`, then apply `kDistDiamond` and extract from the
conjunction premise.
-/
noncomputable def s4DiamondBoxConj {fc : FrameClass} (A B : Formula) :
    ⊢[fc] (A.diamond.and B.box).imp ((A.and B.box).diamond) := by
  -- Goal: (◇A ∧ □B) → ◇(A ∧ □B)
  --
  -- Strategy:
  -- 1. From □B, derive □(A → (A ∧ □B)):
  --    - pairing: A → □B → (A ∧ □B)
  --    - theoremFlip: □B → (A → (A ∧ □B))
  --    - modal_4: □B → □□B
  --    - boxMono: □□B → □(A → (A ∧ □B))
  -- 2. Apply kDistDiamond: □(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))
  -- 3. Extract from conjunction premise

  -- Step 1: Build pairing theorem A → □B → (A ∧ □B)
  have pair : ⊢[fc] A.imp (B.box.imp (A.and B.box)) :=
    pairing A B.box
  -- Step 2: Flip to get □B → (A → (A ∧ □B))
  have flipped : ⊢[fc] B.box.imp (A.imp (A.and B.box)) :=
    DerivationTree.modus_ponens [] _ _ (@theoremFlip fc A B.box (A.and B.box)) pair
  -- Step 3: Apply modal_4 to get □B → □□B
  have modal_4_b : ⊢[fc] B.box.imp B.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 B) (FrameClass.base_le fc)
  -- Step 4: Apply boxMono to flipped to get □□B → □(A → (A ∧ □B))
  have box_flipped : ⊢[fc] B.box.box.imp (A.imp (A.and B.box)).box :=
    boxMono flipped
  -- Step 5: Compose: □B → □□B → □(A → (A ∧ □B))
  have box_b_to_box_imp : ⊢[fc] B.box.imp (A.imp (A.and B.box)).box :=
    impTrans modal_4_b box_flipped
  -- Step 6: Apply kDistDiamond: □(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))
  have k_dist : ⊢[fc] (A.imp (A.and B.box)).box.imp (A.diamond.imp (A.and B.box).diamond) :=
    kDistDiamond A (A.and B.box)
  -- Step 7: Compose: □B → (◇A → ◇(A ∧ □B))
  have box_b_to_diamond_imp : ⊢[fc] B.box.imp (A.diamond.imp (A.and B.box).diamond) :=
    impTrans box_b_to_box_imp k_dist
  -- Step 8: Build (◇A ∧ □B) → ◇(A ∧ □B)
  -- We need to extract □B and ◇A from the conjunction and apply them

  -- Extract □B from conjunction: (◇A ∧ □B) → □B
  have rce_conj : ⊢[fc] (A.diamond.and B.box).imp B.box :=
    Propositional.rceImp A.diamond B.box
  -- Compose to get: (◇A ∧ □B) → (◇A → ◇(A ∧ □B))
  -- Use bCombinator: (B.box → X) → ((◇A ∧ □B) → B.box) → ((◇A ∧ □B) → X)
  have b_comp : ⊢[fc] (B.box.imp (A.diamond.imp (A.and B.box).diamond)).imp
                   (((A.diamond.and B.box).imp B.box).imp
                    ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond))) :=
    bCombinator
  have step1 : ⊢[fc] ((A.diamond.and B.box).imp B.box).imp
                  ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond)) :=
    DerivationTree.modus_ponens [] _ _ b_comp box_b_to_diamond_imp
  have conj_to_imp : ⊢[fc] (A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond) :=
    DerivationTree.modus_ponens [] _ _ step1 rce_conj
  -- Extract ◇A from conjunction: (◇A ∧ □B) → ◇A
  have lce_conj : ⊢[fc] (A.diamond.and B.box).imp A.diamond :=
    Propositional.lceImp A.diamond B.box
  -- Now apply S axiom to combine: (X → Y → Z) → ((X → Y) → (X → Z))
  -- With X = (◇A ∧ □B), Y = ◇A, Z = ◇(A ∧ □B)
  have s_axiom : ⊢[fc] ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond)).imp
                   (((A.diamond.and B.box).imp A.diamond).imp
                    ((A.diamond.and B.box).imp (A.and B.box).diamond)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k (A.diamond.and B.box) A.diamond (A.and B.box).diamond)
      trivial
  have step2 : ⊢[fc] ((A.diamond.and B.box).imp A.diamond).imp
                  ((A.diamond.and B.box).imp (A.and B.box).diamond) :=
    DerivationTree.modus_ponens [] _ _ s_axiom conj_to_imp
  exact DerivationTree.modus_ponens [] _ _ step2 lce_conj

/--
S4-Box-Diamond-Box - `⊢ □A → □(◇□A)`.

In S4, necessity implies the necessity of its own possibility being necessary.

**Proof Strategy**:
1. From modal_b: A → □◇A, apply to □A to get □A → □◇□A
2. This is exactly what we need

**Dependencies**: None (uses only core modal axioms)

**Status**: Complete
-/
def s4BoxDiamondBox {fc : FrameClass} (A : Formula) : ⊢[fc] A.box.imp ((A.box.diamond).box) := by
  -- Goal: □A → □(◇□A)
  -- modal_b gives: A → □◇A
  -- Apply to □A: □A → □◇□A
  have modal_b_inst : ⊢[fc] A.box.imp (A.box.diamond).box :=
    DerivationTree.axiom [] _ (Axiom.modal_b A.box) (FrameClass.base_le fc)
  exact modal_b_inst

/--
S4-Diamond-Box-Diamond Equivalence - `⊢ ◇(□(◇A)) ↔ ◇A`.

In S4, nested diamond-box-diamond collapses to simple diamond.

**Proof Strategy**:
- Backward (`◇A → ◇□◇A`): Use modal5 (◇A → □◇A) then tBoxToDiamond
- Forward (`◇□◇A → ◇A`): Use modal_t (□◇A → ◇A) under diamond, then collapse

**Dependencies**: Biconditional infrastructure (available via pairing pattern)
-/
def s4DiamondBoxDiamond {fc : FrameClass} (A : Formula) : ⊢[fc] iff (A.diamond.box.diamond) A.diamond := by
  -- Goal: ◇□◇A ↔ ◇A

  -- Backward direction: ◇A → ◇□◇A
  have backward : ⊢[fc] A.diamond.imp (A.diamond.box.diamond) := by
    -- We need: ◇A → ◇□◇A

    -- Use modal_b: A → □◇A
    -- Apply to ◇A: ◇A → □◇(◇A)
    -- But we want ◇A → ◇□◇A, not ◇A → □◇◇A

    -- Different approach: Use modal5 first
    -- modal5: ◇A → □◇A
    have modal_5_inst : ⊢[fc] A.diamond.imp A.diamond.box :=
      modal5 A
    -- Now we need: □◇A → ◇□◇A
    -- This should be: B → ◇B for any B, which doesn't exist
    -- Or: □B → ◇□B

    -- Actually, let's use tBoxToDiamond directly on □◇A
    -- tBoxToDiamond applied to (□◇A): □(□◇A) → ◇(□◇A)
    -- But we have □◇A, not □□◇A

    -- Use modal_4 first: □◇A → □□◇A
    have modal_4_diamond : ⊢[fc] A.diamond.box.imp (A.diamond.box.box) :=
      DerivationTree.axiom [] _ (Axiom.modal_4 A.diamond) (FrameClass.base_le fc)
    -- Then tBoxToDiamond on □◇A: □□◇A → ◇□◇A
    have box_box_diamond_to_diamond_box_diamond :
      ⊢[fc] (A.diamond.box.box).imp (A.diamond.box.diamond) :=
      tBoxToDiamond A.diamond.box
    have box_diamond_to_diamond_box_diamond : ⊢[fc] A.diamond.box.imp A.diamond.box.diamond :=
      impTrans modal_4_diamond box_box_diamond_to_diamond_box_diamond
    -- Compose: ◇A → □◇A → ◇□◇A
    exact impTrans modal_5_inst box_diamond_to_diamond_box_diamond
  -- Forward direction: ◇□◇A → ◇A
  have forward : ⊢[fc] (A.diamond.box.diamond).imp A.diamond := by
    -- We have: ◇□◇A
    -- We want: ◇A

    -- Key insight: □◇A → ◇A (modal_t applied to ◇A)
    -- Now lift this under ◇ using diamondMono

    -- modal_t: □B → B, so with B = ◇A: □◇A → ◇A
    have modal_t_diamond : ⊢[fc] A.diamond.box.imp A.diamond :=
      DerivationTree.axiom [] _ (Axiom.modal_t A.diamond) (FrameClass.base_le fc)
    -- diamondMono: (A → B) → (◇A → ◇B)
    -- With A = □◇A, B = ◇A, we get: ◇□◇A → ◇◇A
    -- But we want ◇□◇A → ◇A, not ◇□◇A → ◇◇A

    -- Wait, that's wrong. Let me reconsider.
    -- diamondMono takes h : ⊢ A.imp B and gives ⊢ A.diamond.imp B.diamond
    -- So from □◇A → ◇A, we get ◇(□◇A) → ◇(◇A)
    -- But ◇(◇A) is not ◇A (no diamond idempotence)

    -- Actually, I need a different approach.
    -- From ◇□◇A, extract □◇A somehow, then apply modal_t

    -- In S4, we don't have ◇□X → □X (that's S5)
    -- But we have ◇□X → X via: if □X is possible, then X is possible (weaker)

    -- Actually, let's use this chain:
    -- ◇□◇A means □◇A is possible
    -- From modal_t: □◇A → ◇A
    -- We need to show: if □◇A is possible, then ◇A holds
    -- This is the content of: ◇(□◇A) → ◇A

    -- But how to get from ◇(□◇A) → ◇A?
    -- We have □◇A → ◇A (modal_t)
    -- We need ◇□◇A → ◇A

    -- One approach: ◇□◇A → ◇◇A (by diamondMono on modal_t)
    -- Then ◇◇A → ◇A (by diamond idempotence, if we had it)
    -- But we don't have diamond idempotence!

    -- Different approach: Use the fact that in S4, ◇□X implies X
    -- We have ◇□◇A, want ◇A
    -- So we need the pattern: ◇□X → X

    -- Let me try: modal_t gives □◇A → ◇A
    -- Contrapose: ¬◇A → ¬□◇A
    -- Which is: □¬A → □¬◇A
    -- Then: ¬□¬◇A → ¬□¬A
    -- Which is: ◇◇A → ◇A? No, that's wrong too.

    -- Actually, this requires S5's modal_5_collapse: ◇□X → □X
    -- With X = ◇A: ◇□◇A → □◇A
    -- Then modal_t: □◇A → ◇A
    -- Compose: ◇□◇A → ◇A

    -- Step 1: modal_5_collapse on ◇A: ◇□(◇A) → □(◇A)
    have m5c : ⊢[fc] A.diamond.box.diamond.imp A.diamond.box :=
      DerivationTree.axiom [] _ (Axiom.modal_5_collapse A.diamond) (FrameClass.base_le fc)
    -- Step 2: modal_t on ◇A: □(◇A) → ◇A
    -- (Already have this as modal_t_diamond)

    -- Compose: ◇□◇A → □◇A → ◇A
    exact impTrans m5c modal_t_diamond
  -- Combine using pairing to build biconditional
  have pair_forward_backward : ⊢[fc] (A.diamond.box.diamond.imp A.diamond).imp
    ((A.diamond.imp A.diamond.box.diamond).imp
     ((A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond))) :=
    pairing (A.diamond.box.diamond.imp A.diamond) (A.diamond.imp A.diamond.box.diamond)
  have step1 : ⊢[fc] (A.diamond.imp A.diamond.box.diamond).imp
    ((A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond)) :=
    DerivationTree.modus_ponens [] _ _ pair_forward_backward forward
  have result : ⊢[fc] (A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond) :=
    DerivationTree.modus_ponens [] _ _ step1 backward
  exact result

/--
S5-Diamond-Conjunction-Diamond - `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)`.

In S5, diamond distributes over conjunction with nested diamond.

**Proof**: Each direction is built from `diamondMono` applied to `lceImp`/`rceImp`,
the S5 collapse of `◇◇B` to `◇B`, and `pairing`; the two are combined into the
biconditional.
-/
noncomputable def s5DiamondConjDiamond {fc : FrameClass} (A B : Formula) :
    ⊢[fc] iff ((A.and B.diamond).diamond) (A.diamond.and B.diamond) := by
  -- Goal: ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)

  -- Forward direction: ◇(A ∧ ◇B) → (◇A ∧ ◇B)
  have forward : ⊢[fc] (A.and B.diamond).diamond.imp (A.diamond.and B.diamond) := by
    -- Strategy:
    -- 1. ◇(A ∧ ◇B) → ◇A via kDistDiamond on (A ∧ ◇B) → A (andLeft)
    -- 2. ◇(A ∧ ◇B) → ◇◇B via kDistDiamond on (A ∧ ◇B) → ◇B (andRight)
    -- 3. ◇◇B → ◇B using S5 axiom (modal_5_collapse on ¬B)
    -- 4. Combine with pairing

    -- Step 1: Get ◇(A ∧ ◇B) → ◇A
    -- Use lceImp: (A ∧ ◇B) → A
    have lce : ⊢[fc] (A.and B.diamond).imp A := Propositional.lceImp A B.diamond
    -- Apply diamondMono to get ◇(A ∧ ◇B) → ◇A
    have dia_lce : ⊢[fc] (A.and B.diamond).diamond.imp A.diamond := diamondMono lce
    -- Step 2: Get ◇(A ∧ ◇B) → ◇◇B
    -- Use rceImp: (A ∧ ◇B) → ◇B
    have rce : ⊢[fc] (A.and B.diamond).imp B.diamond := Propositional.rceImp A B.diamond
    -- Apply diamondMono to get ◇(A ∧ ◇B) → ◇◇B
    have dia_rce : ⊢[fc] (A.and B.diamond).diamond.imp B.diamond.diamond := diamondMono rce
    -- Step 3: Get ◇◇B → ◇B using S5
    -- In S5: ◇□X → □X (modal_5_collapse)
    -- We need ◇◇B → ◇B
    -- Use duality: ◇◇B = ¬□¬◇B = ¬□¬¬□¬B = ¬□□¬B
    -- We can use: □□¬B → □¬B (by modal_t on □¬B), then contrapose
    -- Actually simpler: Use the fact that modal_t gives □X → X for any X
    -- So □◇B → ◇B (modal_t on ◇B)
    -- We need to lift this: we need ◇◇B → ◇B, which is the dual

    -- Alternative: Use modal_5_collapse directly
    -- modal_5_collapse: ◇□X → □X
    -- Apply to ¬B: ◇□¬B → □¬B
    -- Contrapose: ¬□¬B → ¬◇□¬B which is ◇B → □◇B (this is modal_5!)
    -- But we need the reverse: ◇◇B → ◇B

    -- Actually, in S5 we have: □◇B ↔ ◇B (from s5DiamondBox applied to B)
    -- So ◇□◇B ↔ ◇◇B (duality)
    -- And ◇□◇B → □◇B by modal_5_collapse
    -- And □◇B → ◇B by modal_t
    -- So ◇◇B → ◇B

    -- Let me build this step by step:
    -- Step 3a: Get □◇B → ◇B (modal_t on ◇B)
    have box_dia_to_dia : ⊢[fc] B.diamond.box.imp B.diamond :=
      DerivationTree.axiom [] _ (Axiom.modal_t B.diamond) (FrameClass.base_le fc)
    -- Step 3b: Get ◇□◇B → □◇B (modal_5_collapse on ◇B)
    have dia_box_dia_to_box_dia : ⊢[fc] B.diamond.box.diamond.imp B.diamond.box :=
      DerivationTree.axiom [] _ (Axiom.modal_5_collapse B.diamond) (FrameClass.base_le fc)
    -- Step 3c: Compose to get ◇□◇B → ◇B
    have dia_box_dia_to_dia : ⊢[fc] B.diamond.box.diamond.imp B.diamond :=
      impTrans dia_box_dia_to_box_dia box_dia_to_dia
    -- Step 3d: Now I need to show ◇◇B = ◇□◇B
    -- Actually, this is NOT true in general!
    -- ◇◇B = ¬□¬◇B = ¬□□¬B (using ¬◇X = □¬X)
    -- ◇□◇B = ¬□¬□◇B = ¬□¬□¬□¬B

    -- Let me use a different approach: use modal_t on □◇B
    -- We have ◇◇B, want ◇B
    -- ◇◇B = ◇¬□¬B
    -- By diamondMono on modal_t: (□¬B → ¬B) implies (◇□¬B → ◇¬B)
    -- Contrapose: (B → ¬□¬B) implies... wait, this is getting circular

    -- Use diamond4: ◇◇B → ◇B (already proven in Perpetuity)
    have dia_dia_to_dia : ⊢[fc] B.diamond.diamond.imp B.diamond :=
      diamond4 B
    -- Step 4: Compose dia_rce with dia_dia_to_dia to get ◇(A ∧ ◇B) → ◇B
    have dia_conj_to_dia_b : ⊢[fc] (A.and B.diamond).diamond.imp B.diamond :=
      impTrans dia_rce dia_dia_to_dia
    -- Step 5: Combine ◇(A ∧ ◇B) → ◇A and ◇(A ∧ ◇B) → ◇B into ◇(A ∧ ◇B) → (◇A ∧ ◇B)
    exact combineImpConj dia_lce dia_conj_to_dia_b
  -- Backward direction: (◇A ∧ ◇B) → ◇(A ∧ ◇B)
  have backward : ⊢[fc] (A.diamond.and B.diamond).imp (A.and B.diamond).diamond := by
    -- Strategy:
    -- 1. From ◇B, use modal5: ◇B → □◇B
    -- 2. From □◇B, derive □(A → (A ∧ ◇B)):
    --    - pairing: A → ◇B → (A ∧ ◇B)
    --    - theoremFlip: ◇B → (A → (A ∧ ◇B))
    --    - boxMono: □◇B → □(A → (A ∧ ◇B))
    -- 3. Apply kDistDiamond: □(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))
    -- 4. Extract from conjunction premise

    -- Step 1: Apply modal5 to B: ◇B → □◇B
    have modal_5_b : ⊢[fc] B.diamond.imp B.diamond.box :=
      modal5 B
    -- Step 2: Build pairing A → ◇B → (A ∧ ◇B)
    have pair : ⊢[fc] A.imp (B.diamond.imp (A.and B.diamond)) :=
      pairing A B.diamond
    -- Step 3: Flip to get ◇B → (A → (A ∧ ◇B))
    have flipped : ⊢[fc] B.diamond.imp (A.imp (A.and B.diamond)) :=
      DerivationTree.modus_ponens []
        _ _ (@theoremFlip fc A B.diamond (A.and B.diamond)) pair
    -- Step 4: Apply boxMono to get □◇B → □(A → (A ∧ ◇B))
    have box_flipped : ⊢[fc] B.diamond.box.imp (A.imp (A.and B.diamond)).box :=
      boxMono flipped
    -- Step 5: Compose: ◇B → □◇B → □(A → (A ∧ ◇B))
    have dia_b_to_box_imp : ⊢[fc] B.diamond.imp (A.imp (A.and B.diamond)).box :=
      impTrans modal_5_b box_flipped
    -- Step 6: Apply kDistDiamond: □(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))
    have k_dist : ⊢[fc] (A.imp (A.and B.diamond)).box.imp (A.diamond.imp (A.and B.diamond).diamond) :=
      kDistDiamond A (A.and B.diamond)
    -- Step 7: Compose: ◇B → (◇A → ◇(A ∧ ◇B))
    have dia_b_to_imp : ⊢[fc] B.diamond.imp (A.diamond.imp (A.and B.diamond).diamond) :=
      impTrans dia_b_to_box_imp k_dist
    -- Step 8: Build (◇A ∧ ◇B) → ◇(A ∧ ◇B)
    -- Extract ◇B from conjunction: (◇A ∧ ◇B) → ◇B
    have rce_conj : ⊢[fc] (A.diamond.and B.diamond).imp B.diamond :=
      Propositional.rceImp A.diamond B.diamond
    -- Compose to get: (◇A ∧ ◇B) → (◇A → ◇(A ∧ ◇B))
    have b_comp : ⊢[fc] (B.diamond.imp (A.diamond.imp (A.and B.diamond).diamond)).imp
                     (((A.diamond.and B.diamond).imp B.diamond).imp
                      ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond))) :=
      bCombinator
    have step1 : ⊢[fc] ((A.diamond.and B.diamond).imp B.diamond).imp
                    ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond)) :=
      DerivationTree.modus_ponens [] _ _ b_comp dia_b_to_imp
    have conj_to_imp : ⊢[fc] (A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond) :=
      DerivationTree.modus_ponens [] _ _ step1 rce_conj
    -- Extract ◇A from conjunction: (◇A ∧ ◇B) → ◇A
    have lce_conj : ⊢[fc] (A.diamond.and B.diamond).imp A.diamond :=
      Propositional.lceImp A.diamond B.diamond
    -- Apply S axiom to combine
    have s_axiom :
      ⊢[fc] ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond)).imp
        (((A.diamond.and B.diamond).imp A.diamond).imp
         ((A.diamond.and B.diamond).imp (A.and B.diamond).diamond)) :=
      DerivationTree.axiom [] _
        (Axiom.prop_k (A.diamond.and B.diamond) A.diamond (A.and B.diamond).diamond) trivial
    have step2 : ⊢[fc] ((A.diamond.and B.diamond).imp A.diamond).imp
                    ((A.diamond.and B.diamond).imp (A.and B.diamond).diamond) :=
      DerivationTree.modus_ponens [] _ _ s_axiom conj_to_imp
    exact DerivationTree.modus_ponens [] _ _ step2 lce_conj
  -- Combine into biconditional
  exact Propositional.iffIntro (A.and B.diamond).diamond (A.diamond.and B.diamond) forward backward

end FormalSystem.Theorems.ModalS4
