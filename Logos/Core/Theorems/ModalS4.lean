import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
import Logos.Core.Theorems.Perpetuity
import Logos.Core.Theorems.Propositional
import Logos.Core.Theorems.ModalS5

/-!
# Modal S4 Theorems

This module derives modal S4-specific theorems in Hilbert-style proof calculus
for the TM bimodal logic system.

Modal S4 is characterized by reflexivity (T) and transitivity (4) axioms, but
without the symmetric accessibility (B) axiom. This gives S4 different properties
than S5, particularly for nested modalities.

## Main Theorems

### Modal S4 Nested Modalities (Phase 4)
- `s4_diamond_box_conj`: `⊢ (◇A ∧ □B) → ◇(A ∧ □B)` (diamond box conjunction distribution)
- `s4_box_diamond_box`: `⊢ □A → □(◇□A)` (box diamond box nesting)
- `s4_diamond_box_diamond`: `⊢ ◇(□(◇A)) ↔ ◇A` (diamond box diamond equivalence)
- `s5_diamond_conj_diamond`: `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)` (S5 diamond conjunction distribution)

## Implementation Status

**Phase 4 Not Started**: 0/4 theorems proven (all pending Phase 2-3 completion)

## References

* [Perpetuity.lean](Perpetuity.lean) - Modal infrastructure (modal_t, modal_4, modal_b, box_mono, diamond_mono)
* [Propositional.lean](Propositional.lean) - Propositional infrastructure (ecq, raa, efq, ldi, rdi)
* [ModalS5.lean](ModalS5.lean) - S5 theorems (t_box_to_diamond, box_contrapose, t_box_consistency)
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata (modal_t, modal_4, modal_b, modal_5)
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Logos.Core.Theorems.ModalS4

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity
open Logos.Core.Theorems.Propositional
open Logos.Core.Theorems.ModalS5

/-!
## Phase 4: Modal S4 Theorems (Not Started)
-/

/--
Task 38: S4-Diamond-Box-Conjunction - `⊢ (◇A ∧ □B) → ◇(A ∧ □B)`.

In S4, if A is possible and B is necessary, then A ∧ □B is possible.

**Proof Strategy**: Use modal_4 axiom (□φ → □□φ) and complex modal distribution reasoning.

**Dependencies**: Phase 2 box_conj_iff (biconditional infrastructure)

**Status**: Not started (pending Phase 2-3 completion)
-/
theorem s4_diamond_box_conj (A B : Formula) : ⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond) := by
  -- Goal: (◇A ∧ □B) → ◇(A ∧ □B)
  --
  -- Strategy:
  -- 1. From □B, derive □(A → (A ∧ □B)):
  --    - pairing: A → □B → (A ∧ □B)
  --    - theorem_flip: □B → (A → (A ∧ □B))
  --    - modal_4: □B → □□B
  --    - box_mono: □□B → □(A → (A ∧ □B))
  -- 2. Apply k_dist_diamond: □(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))
  -- 3. Extract from conjunction premise

  -- Step 1: Build pairing theorem A → □B → (A ∧ □B)
  have pair : ⊢ A.imp (B.box.imp (A.and B.box)) :=
    pairing A B.box

  -- Step 2: Flip to get □B → (A → (A ∧ □B))
  have flipped : ⊢ B.box.imp (A.imp (A.and B.box)) :=
    Derivable.modus_ponens [] _ _ (theorem_flip A B.box (A.and B.box)) pair

  -- Step 3: Apply modal_4 to get □B → □□B
  have modal_4_b : ⊢ B.box.imp B.box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 B)

  -- Step 4: Apply box_mono to flipped to get □□B → □(A → (A ∧ □B))
  have box_flipped : ⊢ B.box.box.imp (A.imp (A.and B.box)).box :=
    box_mono flipped

  -- Step 5: Compose: □B → □□B → □(A → (A ∧ □B))
  have box_b_to_box_imp : ⊢ B.box.imp (A.imp (A.and B.box)).box :=
    imp_trans modal_4_b box_flipped

  -- Step 6: Apply k_dist_diamond: □(A → (A ∧ □B)) → (◇A → ◇(A ∧ □B))
  have k_dist : ⊢ (A.imp (A.and B.box)).box.imp (A.diamond.imp (A.and B.box).diamond) :=
    k_dist_diamond A (A.and B.box)

  -- Step 7: Compose: □B → (◇A → ◇(A ∧ □B))
  have box_b_to_diamond_imp : ⊢ B.box.imp (A.diamond.imp (A.and B.box).diamond) :=
    imp_trans box_b_to_box_imp k_dist

  -- Step 8: Build (◇A ∧ □B) → ◇(A ∧ □B)
  -- We need to extract □B and ◇A from the conjunction and apply them

  -- Extract □B from conjunction: (◇A ∧ □B) → □B
  have rce_conj : ⊢ (A.diamond.and B.box).imp B.box :=
    Propositional.rce_imp A.diamond B.box

  -- Compose to get: (◇A ∧ □B) → (◇A → ◇(A ∧ □B))
  -- Use b_combinator: (B.box → X) → ((◇A ∧ □B) → B.box) → ((◇A ∧ □B) → X)
  have b_comp : ⊢ (B.box.imp (A.diamond.imp (A.and B.box).diamond)).imp
                   (((A.diamond.and B.box).imp B.box).imp
                    ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond))) :=
    b_combinator

  have step1 : ⊢ ((A.diamond.and B.box).imp B.box).imp
                  ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond)) :=
    Derivable.modus_ponens [] _ _ b_comp box_b_to_diamond_imp

  have conj_to_imp : ⊢ (A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond) :=
    Derivable.modus_ponens [] _ _ step1 rce_conj

  -- Extract ◇A from conjunction: (◇A ∧ □B) → ◇A
  have lce_conj : ⊢ (A.diamond.and B.box).imp A.diamond :=
    Propositional.lce_imp A.diamond B.box

  -- Now apply S axiom to combine: (X → Y → Z) → ((X → Y) → (X → Z))
  -- With X = (◇A ∧ □B), Y = ◇A, Z = ◇(A ∧ □B)
  have s_axiom : ⊢ ((A.diamond.and B.box).imp (A.diamond.imp (A.and B.box).diamond)).imp
                   (((A.diamond.and B.box).imp A.diamond).imp
                    ((A.diamond.and B.box).imp (A.and B.box).diamond)) :=
    Derivable.axiom [] _ (Axiom.prop_k (A.diamond.and B.box) A.diamond (A.and B.box).diamond)

  have step2 : ⊢ ((A.diamond.and B.box).imp A.diamond).imp
                  ((A.diamond.and B.box).imp (A.and B.box).diamond) :=
    Derivable.modus_ponens [] _ _ s_axiom conj_to_imp

  exact Derivable.modus_ponens [] _ _ step2 lce_conj

/--
Task 39: S4-Box-Diamond-Box - `⊢ □A → □(◇□A)`.

In S4, necessity implies the necessity of its own possibility being necessary.

**Proof Strategy**:
1. From modal_b: A → □◇A, apply to □A to get □A → □◇□A
2. This is exactly what we need

**Dependencies**: None (uses only core modal axioms)

**Status**: Complete
-/
theorem s4_box_diamond_box (A : Formula) : ⊢ A.box.imp ((A.box.diamond).box) := by
  -- Goal: □A → □(◇□A)
  -- modal_b gives: A → □◇A
  -- Apply to □A: □A → □◇□A

  have modal_b_inst : ⊢ A.box.imp (A.box.diamond).box :=
    Derivable.axiom [] _ (Axiom.modal_b A.box)

  exact modal_b_inst

/--
Task 40: S4-Diamond-Box-Diamond Equivalence - `⊢ ◇(□(◇A)) ↔ ◇A`.

In S4, nested diamond-box-diamond collapses to simple diamond.

**Proof Strategy**:
- Backward (`◇A → ◇□◇A`): Use modal_5 (◇A → □◇A) then t_box_to_diamond
- Forward (`◇□◇A → ◇A`): Use modal_t (□◇A → ◇A) under diamond, then collapse

**Dependencies**: Biconditional infrastructure (available via pairing pattern)

**Status**: In progress
-/
theorem s4_diamond_box_diamond (A : Formula) : ⊢ iff (A.diamond.box.diamond) A.diamond := by
  -- Goal: ◇□◇A ↔ ◇A

  -- Backward direction: ◇A → ◇□◇A
  have backward : ⊢ A.diamond.imp (A.diamond.box.diamond) := by
    -- We need: ◇A → ◇□◇A

    -- Use modal_b: A → □◇A
    -- Apply to ◇A: ◇A → □◇(◇A)
    -- But we want ◇A → ◇□◇A, not ◇A → □◇◇A

    -- Different approach: Use modal_5 first
    -- modal_5: ◇A → □◇A
    have modal_5_inst : ⊢ A.diamond.imp A.diamond.box :=
      modal_5 A

    -- Now we need: □◇A → ◇□◇A
    -- This should be: B → ◇B for any B, which doesn't exist
    -- Or: □B → ◇□B

    -- Actually, let's use t_box_to_diamond directly on □◇A
    -- t_box_to_diamond applied to (□◇A): □(□◇A) → ◇(□◇A)
    -- But we have □◇A, not □□◇A

    -- Use modal_4 first: □◇A → □□◇A
    have modal_4_diamond : ⊢ A.diamond.box.imp (A.diamond.box.box) :=
      Derivable.axiom [] _ (Axiom.modal_4 A.diamond)

    -- Then t_box_to_diamond on □◇A: □□◇A → ◇□◇A
    have box_box_diamond_to_diamond_box_diamond : ⊢ (A.diamond.box.box).imp (A.diamond.box.diamond) :=
      t_box_to_diamond A.diamond.box

    have box_diamond_to_diamond_box_diamond : ⊢ A.diamond.box.imp A.diamond.box.diamond :=
      imp_trans modal_4_diamond box_box_diamond_to_diamond_box_diamond

    -- Compose: ◇A → □◇A → ◇□◇A
    exact imp_trans modal_5_inst box_diamond_to_diamond_box_diamond

  -- Forward direction: ◇□◇A → ◇A
  have forward : ⊢ (A.diamond.box.diamond).imp A.diamond := by
    -- We have: ◇□◇A
    -- We want: ◇A

    -- Key insight: □◇A → ◇A (modal_t applied to ◇A)
    -- Now lift this under ◇ using diamond_mono

    -- modal_t: □B → B, so with B = ◇A: □◇A → ◇A
    have modal_t_diamond : ⊢ A.diamond.box.imp A.diamond :=
      Derivable.axiom [] _ (Axiom.modal_t A.diamond)

    -- diamond_mono: (A → B) → (◇A → ◇B)
    -- With A = □◇A, B = ◇A, we get: ◇□◇A → ◇◇A
    -- But we want ◇□◇A → ◇A, not ◇□◇A → ◇◇A

    -- Wait, that's wrong. Let me reconsider.
    -- diamond_mono takes h : ⊢ A.imp B and gives ⊢ A.diamond.imp B.diamond
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

    -- One approach: ◇□◇A → ◇◇A (by diamond_mono on modal_t)
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
    have m5c : ⊢ A.diamond.box.diamond.imp A.diamond.box :=
      Derivable.axiom [] _ (Axiom.modal_5_collapse A.diamond)

    -- Step 2: modal_t on ◇A: □(◇A) → ◇A
    -- (Already have this as modal_t_diamond)

    -- Compose: ◇□◇A → □◇A → ◇A
    exact imp_trans m5c modal_t_diamond

  -- Combine using pairing to build biconditional
  have pair_forward_backward : ⊢ (A.diamond.box.diamond.imp A.diamond).imp
    ((A.diamond.imp A.diamond.box.diamond).imp
     ((A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond))) :=
    pairing (A.diamond.box.diamond.imp A.diamond) (A.diamond.imp A.diamond.box.diamond)

  have step1 : ⊢ (A.diamond.imp A.diamond.box.diamond).imp
    ((A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond)) :=
    Derivable.modus_ponens [] _ _ pair_forward_backward forward

  have result : ⊢ (A.diamond.box.diamond.imp A.diamond).and (A.diamond.imp A.diamond.box.diamond) :=
    Derivable.modus_ponens [] _ _ step1 backward

  exact result

/--
Task 41: S5-Diamond-Conjunction-Diamond - `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)`.

In S5, diamond distributes over conjunction with nested diamond.

**Proof Strategy**: Use modal_5 (◇φ → □◇φ) and complex S5 distribution properties.

**Dependencies**: Phase 2 diamond_disj_iff (biconditional infrastructure)

**Status**: Not started
-/
theorem s5_diamond_conj_diamond (A B : Formula) : ⊢ iff ((A.and B.diamond).diamond) (A.diamond.and B.diamond) := by
  -- Goal: ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)

  -- Forward direction: ◇(A ∧ ◇B) → (◇A ∧ ◇B)
  have forward : ⊢ (A.and B.diamond).diamond.imp (A.diamond.and B.diamond) := by
    -- Strategy:
    -- 1. ◇(A ∧ ◇B) → ◇A via k_dist_diamond on (A ∧ ◇B) → A (lce)
    -- 2. ◇(A ∧ ◇B) → ◇◇B via k_dist_diamond on (A ∧ ◇B) → ◇B (rce)
    -- 3. ◇◇B → ◇B using S5 axiom (modal_5_collapse on ¬B)
    -- 4. Combine with pairing

    -- Step 1: Get ◇(A ∧ ◇B) → ◇A
    -- Use lce_imp: (A ∧ ◇B) → A
    have lce : ⊢ (A.and B.diamond).imp A := Propositional.lce_imp A B.diamond
    -- Apply diamond_mono to get ◇(A ∧ ◇B) → ◇A
    have dia_lce : ⊢ (A.and B.diamond).diamond.imp A.diamond := diamond_mono lce

    -- Step 2: Get ◇(A ∧ ◇B) → ◇◇B
    -- Use rce_imp: (A ∧ ◇B) → ◇B
    have rce : ⊢ (A.and B.diamond).imp B.diamond := Propositional.rce_imp A B.diamond
    -- Apply diamond_mono to get ◇(A ∧ ◇B) → ◇◇B
    have dia_rce : ⊢ (A.and B.diamond).diamond.imp B.diamond.diamond := diamond_mono rce

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

    -- Actually, in S5 we have: □◇B ↔ ◇B (from s5_diamond_box applied to B)
    -- So ◇□◇B ↔ ◇◇B (duality)
    -- And ◇□◇B → □◇B by modal_5_collapse
    -- And □◇B → ◇B by modal_t
    -- So ◇◇B → ◇B

    -- Let me build this step by step:
    -- Step 3a: Get □◇B → ◇B (modal_t on ◇B)
    have box_dia_to_dia : ⊢ B.diamond.box.imp B.diamond :=
      Derivable.axiom [] _ (Axiom.modal_t B.diamond)

    -- Step 3b: Get ◇□◇B → □◇B (modal_5_collapse on ◇B)
    have dia_box_dia_to_box_dia : ⊢ B.diamond.box.diamond.imp B.diamond.box :=
      Derivable.axiom [] _ (Axiom.modal_5_collapse B.diamond)

    -- Step 3c: Compose to get ◇□◇B → ◇B
    have dia_box_dia_to_dia : ⊢ B.diamond.box.diamond.imp B.diamond :=
      imp_trans dia_box_dia_to_box_dia box_dia_to_dia

    -- Step 3d: Now I need to show ◇◇B = ◇□◇B
    -- Actually, this is NOT true in general!
    -- ◇◇B = ¬□¬◇B = ¬□□¬B (using ¬◇X = □¬X)
    -- ◇□◇B = ¬□¬□◇B = ¬□¬□¬□¬B

    -- Let me use a different approach: use modal_t on □◇B
    -- We have ◇◇B, want ◇B
    -- ◇◇B = ◇¬□¬B
    -- By diamond_mono on modal_t: (□¬B → ¬B) implies (◇□¬B → ◇¬B)
    -- Contrapose: (B → ¬□¬B) implies... wait, this is getting circular

    -- Actually, the simplest approach: I'll just use that ◇ is idempotent in S5
    -- But we don't have that lemma! Let me prove it here.

    -- Lemma: ◇◇B → ◇B in S5
    -- Proof: Use □B → □□B (modal_4), contrapose to get ◇◇B → ◇B... wait, that gives the wrong direction!

    -- Let me think again. In S5, we have modal_5: ◇B → □◇B
    -- Apply to ◇B: ◇◇B → □◇◇B
    -- But we need ◇◇B → ◇B

    -- Actually, the key is: in S5, □◇B ↔ ◇B (this is proven in s5_diamond_box for B, not ◇B)
    -- So if we can show ◇◇B → □◇B, then we get ◇◇B → ◇B

    -- ◇◇B → □◇B is exactly modal_5 applied to ◇B!
    have dia_dia_to_box_dia : ⊢ B.diamond.diamond.imp B.diamond.box :=
      modal_5 B.diamond

    -- Now compose with modal_t to get ◇◇B → ◇B
    have dia_dia_to_dia : ⊢ B.diamond.diamond.imp B.diamond :=
      imp_trans dia_dia_to_box_dia box_dia_to_dia

    -- Step 4: Compose dia_rce with dia_dia_to_dia to get ◇(A ∧ ◇B) → ◇B
    have dia_conj_to_dia_b : ⊢ (A.and B.diamond).diamond.imp B.diamond :=
      imp_trans dia_rce dia_dia_to_dia

    -- Step 5: Combine ◇(A ∧ ◇B) → ◇A and ◇(A ∧ ◇B) → ◇B into ◇(A ∧ ◇B) → (◇A ∧ ◇B)
    exact combine_imp_conj dia_lce dia_conj_to_dia_b

  -- Backward direction: (◇A ∧ ◇B) → ◇(A ∧ ◇B)
  have backward : ⊢ (A.diamond.and B.diamond).imp (A.and B.diamond).diamond := by
    -- Strategy:
    -- 1. From ◇B, use modal_5: ◇B → □◇B
    -- 2. From □◇B, derive □(A → (A ∧ ◇B)):
    --    - pairing: A → ◇B → (A ∧ ◇B)
    --    - theorem_flip: ◇B → (A → (A ∧ ◇B))
    --    - box_mono: □◇B → □(A → (A ∧ ◇B))
    -- 3. Apply k_dist_diamond: □(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))
    -- 4. Extract from conjunction premise

    -- Step 1: Apply modal_5 to B: ◇B → □◇B
    have modal_5_b : ⊢ B.diamond.imp B.diamond.box :=
      modal_5 B

    -- Step 2: Build pairing A → ◇B → (A ∧ ◇B)
    have pair : ⊢ A.imp (B.diamond.imp (A.and B.diamond)) :=
      pairing A B.diamond

    -- Step 3: Flip to get ◇B → (A → (A ∧ ◇B))
    have flipped : ⊢ B.diamond.imp (A.imp (A.and B.diamond)) :=
      Derivable.modus_ponens [] _ _ (theorem_flip A B.diamond (A.and B.diamond)) pair

    -- Step 4: Apply box_mono to get □◇B → □(A → (A ∧ ◇B))
    have box_flipped : ⊢ B.diamond.box.imp (A.imp (A.and B.diamond)).box :=
      box_mono flipped

    -- Step 5: Compose: ◇B → □◇B → □(A → (A ∧ ◇B))
    have dia_b_to_box_imp : ⊢ B.diamond.imp (A.imp (A.and B.diamond)).box :=
      imp_trans modal_5_b box_flipped

    -- Step 6: Apply k_dist_diamond: □(A → (A ∧ ◇B)) → (◇A → ◇(A ∧ ◇B))
    have k_dist : ⊢ (A.imp (A.and B.diamond)).box.imp (A.diamond.imp (A.and B.diamond).diamond) :=
      k_dist_diamond A (A.and B.diamond)

    -- Step 7: Compose: ◇B → (◇A → ◇(A ∧ ◇B))
    have dia_b_to_imp : ⊢ B.diamond.imp (A.diamond.imp (A.and B.diamond).diamond) :=
      imp_trans dia_b_to_box_imp k_dist

    -- Step 8: Build (◇A ∧ ◇B) → ◇(A ∧ ◇B)
    -- Extract ◇B from conjunction: (◇A ∧ ◇B) → ◇B
    have rce_conj : ⊢ (A.diamond.and B.diamond).imp B.diamond :=
      Propositional.rce_imp A.diamond B.diamond

    -- Compose to get: (◇A ∧ ◇B) → (◇A → ◇(A ∧ ◇B))
    have b_comp : ⊢ (B.diamond.imp (A.diamond.imp (A.and B.diamond).diamond)).imp
                     (((A.diamond.and B.diamond).imp B.diamond).imp
                      ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond))) :=
      b_combinator

    have step1 : ⊢ ((A.diamond.and B.diamond).imp B.diamond).imp
                    ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond)) :=
      Derivable.modus_ponens [] _ _ b_comp dia_b_to_imp

    have conj_to_imp : ⊢ (A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond) :=
      Derivable.modus_ponens [] _ _ step1 rce_conj

    -- Extract ◇A from conjunction: (◇A ∧ ◇B) → ◇A
    have lce_conj : ⊢ (A.diamond.and B.diamond).imp A.diamond :=
      Propositional.lce_imp A.diamond B.diamond

    -- Apply S axiom to combine
    have s_axiom : ⊢ ((A.diamond.and B.diamond).imp (A.diamond.imp (A.and B.diamond).diamond)).imp
                     (((A.diamond.and B.diamond).imp A.diamond).imp
                      ((A.diamond.and B.diamond).imp (A.and B.diamond).diamond)) :=
      Derivable.axiom [] _ (Axiom.prop_k (A.diamond.and B.diamond) A.diamond (A.and B.diamond).diamond)

    have step2 : ⊢ ((A.diamond.and B.diamond).imp A.diamond).imp
                    ((A.diamond.and B.diamond).imp (A.and B.diamond).diamond) :=
      Derivable.modus_ponens [] _ _ s_axiom conj_to_imp

    exact Derivable.modus_ponens [] _ _ step2 lce_conj

  -- Combine into biconditional
  exact Propositional.iff_intro (A.and B.diamond).diamond (A.diamond.and B.diamond) forward backward

end Logos.Core.Theorems.ModalS4
