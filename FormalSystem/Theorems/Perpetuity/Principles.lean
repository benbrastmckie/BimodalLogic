/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Perpetuity.Helpers
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Automation.LemmaDB

/-!
# Perpetuity Principles (P1-P5)

This module contains the proofs of perpetuity principles P1 through P5, which
establish fundamental connections between modal necessity (□) and temporal operators
(always △, sometimes ▽).

## Main Theorems

- `perpetuity_1`: `□φ → △φ` (necessary implies always)
- `perpetuity_2`: `▽φ → ◇φ` (sometimes implies possible)
- `perpetuity3`: `□φ → □△φ` (necessity of perpetuity)
- `perpetuity4`: `◇▽φ → ◇φ` (possibility of occurrence)
- `perpetuity5`: `◇▽φ → △◇φ` (persistent possibility)

## Supporting Lemmas

- `contraposition`: Contraposition for implications
- `diamond4`: `◇◇φ → ◇φ` (S4 characteristic for diamond)
- `modal5`: `◇φ → □◇φ` (S5 characteristic)
- `persistence`: `◇φ → △◇φ` (persistence lemma for P5)

## References

* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Helpers.lean](Helpers.lean) - Helper lemmas
* [architecture.md](../../../../docs/user-guide/architecture.md) - TM logic specification
-/

namespace FormalSystem.Theorems.Perpetuity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

/--
Double Negation Elimination (local helper): `⊢ ¬¬φ → φ`.

Convenience wrapper for the derived DNE theorem from Propositional.lean.

This theorem is now derived from EFQ + Peirce axioms (see Propositional.doubleNegation).
-/
private def double_negation {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.neg.neg.imp φ :=
  Propositional.doubleNegation φ

/-!
## P1: Necessary Implies Always

`□φ → △φ`

If φ is metaphysically necessary (true in all possible worlds),
then φ is always true (true at all times: past, present, and future).
-/

/--
P1: `□φ → △φ` (necessary implies always)

Derivation combines three components:
1. `□φ → Hφ` (past): via temporal duality on MF (see `boxToPast`)
2. `□φ → φ` (present): via MT axiom (see `boxToPresent`)
3. `□φ → Gφ` (future): via MF then MT (see `boxToFuture`)
4. Combine: `□φ → Hφ ∧ (φ ∧ Gφ)` (see `combineImpConj3`)

This proof uses the `pairing` axiom for conjunction introduction.
-/
def perpetuity_1 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.box.imp φ.always := by
  -- always φ = φ.allPast.and (φ.and φ.allFuture) = Hφ ∧ (φ ∧ Gφ)
  have h_past : ⊢[fc] φ.box.imp φ.allPast := boxToPast φ
  have h_present : ⊢[fc] φ.box.imp φ := boxToPresent φ
  have h_future : ⊢[fc] φ.box.imp φ.allFuture := boxToFuture φ
  exact combineImpConj3 h_past h_present h_future

/-!
## P2: Sometimes Implies Possible

`▽φ → ◇φ` (sometimes implies possible)

If φ happens at some time (past, present, or future), then φ is possible.
-/

/--
Contraposition: if `⊢ A → B` then `⊢ ¬B → ¬A`.

Derived from the `prop_k` and `prop_s` propositional axioms.

Proof strategy:
1. From `A → B`, we need to derive `¬B → ¬A` (i.e., `(B → ⊥) → (A → ⊥)`)
2. Assume `¬B` and `A`, derive `⊥`
3. From `A` and `A → B`, get `B` by modus ponens
4. From `B` and `¬B` (i.e., `B → ⊥`), get `⊥` by modus ponens
5. Therefore `¬B → (A → ⊥)` = `¬B → ¬A`

Steps 2-4 give the informal justification. Since TM is a Hilbert system with no
assumption discharge available here, the derivation below realises the same implication
combinator-style: it builds the commuted B-combinator
`(B → ⊥) → (A → B) → (A → ⊥)` from `prop_s` and `prop_k`, then finishes with two
modus ponens steps.

**Implementation Status**: FULLY DERIVED — complete Hilbert-style derivation, audits to
`[propext]` only.

**Usage**: Required for P2 (`▽φ → ◇φ`) and P4 (`◇▽φ → ◇φ`), which follow from
contraposition of P1 and P3 respectively.
-/
def contraposition {fc : FrameClass} {A B : Formula}
    (h : ⊢[fc] A.imp B) : ⊢[fc] B.neg.imp A.neg := by
  -- Contraposition: (A → B) → (¬B → ¬A)
  -- Where ¬X = X → ⊥
  -- Goal: (B → ⊥) → (A → ⊥)

  -- Proof outline:
  -- 1. From h : A → B
  -- 2. Build: (B → ⊥) → (A → ⊥)
  -- 3. Via the commuted B-combinator form (B → ⊥) → (A → B) → (A → ⊥),
  --    derived below from the prop_s and prop_k axioms
  -- 4. Apply modus ponens to get result

  -- What the proof needs is the commuted B-combinator form
  -- ⊢ (B → ⊥) → ((A → B) → (A → ⊥)), derived below from the prop_s and
  -- prop_k axioms via impTrans.

  -- S axiom: ⊢ (X → Y → Z) → (X → Y) → (X → Z)
  -- Instantiate with X = A, Y = B, Z = ⊥:
  -- ⊢ (A → B → ⊥) → (A → B) → (A → ⊥)
  have s_inst : ⊢[fc] (A.imp (B.imp Formula.bot)).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k A B Formula.bot) (FrameClass.base_le fc)
  -- Now we need: A → (B → ⊥) from h : A → B
  -- S axiom again: B → (A → B)
  have s_b : ⊢[fc] (B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (B.imp Formula.bot) A) (FrameClass.base_le fc)
  -- Now compose: (B → ⊥) → (A → (B → ⊥)) [s_b]
  --              (A → (B → ⊥)) → (A → B) → (A → ⊥) [s_inst]
  -- Result: (B → ⊥) → ((A → B) → (A → ⊥))
  have comm_bc : ⊢[fc] (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    impTrans s_b s_inst
  -- Now apply with h : A → B
  -- comm_bc : ⊢ (B → ⊥) → ((A → B) → (A → ⊥))
  -- But we want: ⊢ (B → ⊥) → (A → ⊥)
  -- We need to eliminate the (A → B) by applying h

  -- Use K axiom structure: ⊢ ((A → B) → (A → ⊥)) → (A → ⊥) when we have ⊢ A → B
  -- Actually, this is just modus ponens at the implication level

  -- We have comm_bc : ⊢ (B → ⊥) → ((A → B) → (A → ⊥))
  -- We need to transform this with h : ⊢ A → B

  -- Let's use S combinator to apply h:
  -- We want: ⊢ (B → ⊥) → (A → ⊥)
  -- We have: comm_bc : ⊢ (B → ⊥) → ((A → B) → (A → ⊥))
  -- We have: h : ⊢ A → B

  -- Build: ((B → ⊥) → (A → B) → (A → ⊥)) → ((B → ⊥) → (A → B)) → ((B → ⊥) → (A → ⊥))
  -- This is S combinator with X = (B → ⊥), Y = (A → B), Z = (A → ⊥)
  have s_final : ⊢[fc] ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                   (((B.imp Formula.bot).imp (A.imp B)).imp
                    ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
    DerivationTree.axiom [] _ (Axiom.prop_k (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot))
      trivial
  -- Apply s_final to comm_bc
  have step1 : ⊢[fc] ((B.imp Formula.bot).imp (A.imp B)).imp
                  ((B.imp Formula.bot).imp (A.imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ s_final comm_bc
  -- Now we need: ⊢ (B → ⊥) → (A → B)
  -- This is: constant function that ignores first arg and returns h
  -- K axiom: ⊢ (A → B) → ((B → ⊥) → (A → B))
  have const_h : ⊢[fc] (A.imp B).imp ((B.imp Formula.bot).imp (A.imp B)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (A.imp B) (B.imp Formula.bot)) (FrameClass.base_le fc)
  have step2 : ⊢[fc] (B.imp Formula.bot).imp (A.imp B) :=
    DerivationTree.modus_ponens [] _ _ const_h h
  -- Finally apply step1 to step2
  exact DerivationTree.modus_ponens [] _ _ step1 step2

/--
Diamond 4: `◇◇φ → ◇φ` (possible-possible implies possible).

Derived from M4 (`□φ → □□φ`) via contraposition on `¬φ`:
1. M4 for `¬φ`: `⊢ □¬φ → □□¬φ`
2. By definition: `□¬φ = ¬◇φ` and `□□¬φ = ¬◇◇φ`
3. So step 1 is: `⊢ ¬◇φ → ¬◇◇φ`
4. Contraposition: `⊢ ◇◇φ → ◇φ`

Note: Since `diamond φ = φ.neg.box.neg`, we have:
- `diamond (diamond φ) = (φ.neg.box.neg).neg.box.neg = φ.neg.box.neg.neg.box.neg`

The proof requires showing that the complex nested negation structure reduces
correctly via double negation elimination within the modal operators.
-/
@[tmLemma]
def diamond4 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.diamond.diamond.imp φ.diamond := by
  -- Goal (by definition): φ.neg.box.neg.neg.box.neg.imp φ.neg.box.neg
  --
  -- Observation: ◇◇φ = (φ.neg.box.neg).diamond = φ.neg.box.neg.neg.box.neg
  -- We want: ◇◇φ → ◇φ, which is φ.neg.box.neg.neg.box.neg → φ.neg.box.neg
  --
  -- Key insight: Use M4 and contraposition multiple times
  -- M4 for ¬φ: □¬φ → □□¬φ
  -- Contrapose to get the negated outer box structure we need

  -- Step 1: M4 for ¬φ: □¬φ → □□¬φ
  have m4_neg : ⊢[fc] φ.neg.box.imp φ.neg.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.neg) (FrameClass.base_le fc)
  -- Step 2: Contrapose M4: ¬□□¬φ → ¬□¬φ
  -- This is: φ.neg.box.box.neg → φ.neg.box.neg
  have m4_contraposed : ⊢[fc] φ.neg.box.box.neg.imp φ.neg.box.neg :=
    contraposition m4_neg
  -- Step 3: We need to relate φ.neg.box.neg.neg.box.neg to φ.neg.box.box.neg
  -- Use DNE:  ¬¬□¬φ → □¬φ
  have dne_box : ⊢[fc] φ.neg.box.neg.neg.imp φ.neg.box :=
    double_negation φ.neg.box
  -- Step 4: Apply M4 after DNE: ¬¬□¬φ → □¬φ → □□¬φ
  have combined : ⊢[fc] φ.neg.box.neg.neg.imp φ.neg.box.box :=
    impTrans dne_box m4_neg
  -- Step 5: Necessitate and distribute
  have box_combined : ⊢[fc] (φ.neg.box.neg.neg.imp φ.neg.box.box).box :=
    DerivationTree.necessitation _ combined
  have mk_dist : ⊢[fc] (φ.neg.box.neg.neg.imp φ.neg.box.box).box.imp
                    (φ.neg.box.neg.neg.box.imp φ.neg.box.box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.box.neg.neg φ.neg.box.box) (FrameClass.base_le fc)
  have distributed : ⊢[fc] φ.neg.box.neg.neg.box.imp φ.neg.box.box.box :=
    DerivationTree.modus_ponens [] _ _ mk_dist box_combined
  -- Step 6: Negate both sides: ¬□□□¬φ → ¬□¬¬□¬φ
  have distributed_neg : ⊢[fc] φ.neg.box.box.box.neg.imp φ.neg.box.neg.neg.box.neg :=
    contraposition distributed
  -- Step 7: Use M4 on □¬φ: □□¬φ → □□□¬φ
  have m4_twice : ⊢[fc] φ.neg.box.box.imp φ.neg.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.neg.box) (FrameClass.base_le fc)
  -- Step 8: Contrapose: ¬□□□¬φ → ¬□□¬φ
  have m4_twice_neg : ⊢[fc] φ.neg.box.box.box.neg.imp φ.neg.box.box.neg :=
    contraposition m4_twice
  -- Step 9: Chain them: ¬□¬¬□¬φ → ¬□□□¬φ → ¬□□¬φ → ¬□¬φ
  -- But we have distributed_neg going the wrong direction
  -- We need to flip the logic - distributed tells us:
  -- □¬¬□¬φ → □□□¬φ, so ¬□□□¬φ → ¬□¬¬□¬φ
  --
  -- What we actually want is: ¬□¬¬□¬φ → ¬□¬φ
  -- Which we can get from: ¬□□¬φ → ¬□¬φ (m4_contraposed)
  -- And: ¬□¬¬□¬φ → ¬□□¬φ
  --
  -- For the latter, we use DNI:
  have dni_box : ⊢[fc] φ.neg.box.imp φ.neg.box.neg.neg :=
    notNotIntro φ.neg.box
  -- Necessitate
  have box_dni : ⊢[fc] (φ.neg.box.imp φ.neg.box.neg.neg).box :=
    DerivationTree.necessitation _ dni_box
  -- Distribute
  have mk_dni : ⊢[fc] (φ.neg.box.imp φ.neg.box.neg.neg).box.imp
                   (φ.neg.box.box.imp φ.neg.box.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.box φ.neg.box.neg.neg) (FrameClass.base_le fc)
  have bridge : ⊢[fc] φ.neg.box.box.imp φ.neg.box.neg.neg.box :=
    DerivationTree.modus_ponens [] _ _ mk_dni box_dni
  -- Contrapose: ¬□¬¬□¬φ → ¬□□¬φ
  have bridge_neg : ⊢[fc] φ.neg.box.neg.neg.box.neg.imp φ.neg.box.box.neg :=
    contraposition bridge
  -- Finally compose: ¬□¬¬□¬φ → ¬□□¬φ → ¬□¬φ
  exact impTrans bridge_neg m4_contraposed

/--
Modal 5: `◇φ → □◇φ` (S5 characteristic for diamond).

If something is possible, it is necessarily possible.

Derived from MB + diamond4 + MK distribution:
1. MB on `◇φ`: `⊢ ◇φ → □◇◇φ`
2. diamond4: `⊢ ◇◇φ → ◇φ`
3. Necessitate: `⊢ □(◇◇φ → ◇φ)`
4. MK distribution: `⊢ □◇◇φ → □◇φ`
5. Compose steps 1 and 4: `⊢ ◇φ → □◇φ`
-/
@[tmLemma]
def modal5 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.diamond.imp φ.diamond.box := by
  -- Step 1: MB on ◇φ
  have mb_dia : ⊢[fc] φ.diamond.imp φ.diamond.diamond.box :=
    DerivationTree.axiom [] _ (Axiom.modal_b φ.diamond) (FrameClass.base_le fc)
  -- Step 2: diamond4 for φ
  have d4 : ⊢[fc] φ.diamond.diamond.imp φ.diamond := diamond4 φ
  -- Step 3: Necessitate d4 using modal_k with empty context
  have box_d4 : ⊢[fc] (φ.diamond.diamond.imp φ.diamond).box :=
    DerivationTree.necessitation _ d4
  -- Step 4: MK distribution
  have mk : ⊢[fc] (φ.diamond.diamond.imp φ.diamond).box.imp
               (φ.diamond.diamond.box.imp φ.diamond.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.diamond.diamond φ.diamond) (FrameClass.base_le fc)
  have d4_box : ⊢[fc] φ.diamond.diamond.box.imp φ.diamond.box :=
    DerivationTree.modus_ponens [] _ _ mk box_d4
  -- Step 5: Compose
  exact impTrans mb_dia d4_box

/--
P2: `▽φ → ◇φ` (sometimes implies possible)

Derivation via contraposition of P1:
1. P1: `□¬φ → △¬φ` (by P1 applied to ¬φ)
2. Contraposition: `¬△¬φ → ¬□¬φ`
3. Since `▽φ = ¬△¬φ` and `◇φ = ¬□¬φ`:
4. We get: `▽φ → ◇φ`
-/
def perpetuity_2 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.sometimes.imp φ.diamond := by
  -- Goal: ⊢ ▽φ → ◇φ
  -- Recall: ▽φ = sometimes φ = ¬(always ¬φ) = ¬(H¬φ ∧ ¬φ ∧ G¬φ)
  -- Recall: ◇φ = diamond φ = ¬□¬φ = (φ.neg.box).neg
  -- By P1 for ¬φ: □(¬φ) → △(¬φ) = □(¬φ) → always(¬φ)
  -- By contraposition: ¬(always(¬φ)) → ¬(□(¬φ))
  -- Which is: sometimes φ → diamond φ = ▽φ → ◇φ
  have h1 : ⊢[fc] φ.neg.box.imp φ.neg.always := perpetuity_1 φ.neg
  -- Unfold: always (neg φ) = H(neg φ) ∧ neg φ ∧ G(neg φ)
  -- So h1 : ⊢ (¬φ).box → (¬φ).always
  -- We need: ⊢ ¬((¬φ).always) → ¬((¬φ).box)
  -- Which is: ⊢ sometimes φ → diamond φ
  exact contraposition h1

/-!
## P3: Necessity of Perpetuity

`□φ → □△φ` (necessity of perpetuity)

What is necessary is necessarily always true.
-/

/--
Box implies boxed past: `⊢ □φ → □Hφ`.

Derived via temporal duality on MF, analogous to `boxToPast`.
-/
@[tmLemma]
def boxToBoxPast {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.box.imp (φ.allPast.box) := by
  have mf : ⊢[fc] φ.swapTemporal.box.imp (φ.swapTemporal.allFuture.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.swapTemporal) (FrameClass.base_le fc)
  have mf_swap : ⊢[fc] (φ.swapTemporal.box.imp (φ.swapTemporal.allFuture.box)).swapTemporal :=
    DerivationTree.temporal_duality _ mf
  simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution] at mf_swap
  exact mf_swap

/--
Introduction of boxed conjunction: from `⊢ □A` and `⊢ □B`, derive `⊢ □(A ∧ B)`.

This lemma uses modal K distribution and necessitation to combine boxed formulas
into a boxed conjunction.

Proof strategy:
1. By `pairing`: `⊢ A → (B → A∧B)`
2. By necessitation: `⊢ □(A → (B → A∧B))`
3. By modal K dist: `⊢ □A → □(B → A∧B)`
4. By modal K dist: `⊢ □(B → A∧B) → (□B → □(A∧B))`
5. Compose to get: `⊢ □A → □B → □(A∧B)`
6. Apply modus ponens with hA and hB
-/
def boxConjIntro {fc : FrameClass} {A B : Formula}
    (hA : ⊢[fc] A.box) (hB : ⊢[fc] B.box) : ⊢[fc] (A.and B).box := by
  -- Step 1: pairing axiom gives us the base implication
  have pair : ⊢[fc] A.imp (B.imp (A.and B)) := pairing A B
  -- Step 2: necessitation of pairing using modal_k with empty context
  have box_pair : ⊢[fc] (A.imp (B.imp (A.and B))).box :=
    DerivationTree.necessitation _ pair
  -- Step 3: modal K distribution (first application)
  -- □(A → (B → A∧B)) → (□A → □(B → A∧B))
  have mk1 : ⊢[fc] (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B))) (FrameClass.base_le fc)
  have h1 : ⊢[fc] A.box.imp (B.imp (A.and B)).box :=
    DerivationTree.modus_ponens [] _ _ mk1 box_pair
  -- Step 4: modal K distribution (second application)
  -- □(B → A∧B) → (□B → □(A∧B))
  have mk2 : ⊢[fc] (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist B (A.and B)) (FrameClass.base_le fc)
  -- Compose: □A → □(B → A∧B) and □(B → A∧B) → (□B → □(A∧B))
  -- to get: □A → (□B → □(A∧B))
  have h2 : ⊢[fc] A.box.imp (B.box.imp (A.and B).box) := impTrans h1 mk2
  -- Apply with hA to get: □B → □(A∧B)
  have h3 : ⊢[fc] B.box.imp (A.and B).box :=
    DerivationTree.modus_ponens [] _ _ h2 hA
  -- Apply with hB to get: □(A∧B)
  exact DerivationTree.modus_ponens [] _ _ h3 hB

/--
Boxed conjunction introduction from implications: from `⊢ P → □A` and `⊢ P → □B`,
derive `⊢ P → □(A ∧ B)`.

This variant of `boxConjIntro` works with implications rather than direct
derivations. It's useful for combining components like `□φ → □Hφ`, `□φ → □φ`,
`□φ → □Gφ` into `□φ → □(Hφ ∧ (φ ∧ Gφ))`.
-/
def boxConjIntroImp {fc : FrameClass} {P A B : Formula}
    (hA : ⊢[fc] P.imp A.box) (hB : ⊢[fc] P.imp B.box) : ⊢[fc] P.imp (A.and B).box := by
  -- Strategy: Build P → □A → □B → □(A ∧ B), then apply with hA and hB
  -- From boxConjIntro proof, we have the pattern: □A → □B → □(A ∧ B)

  -- First, build the implication chain: □A → □B → □(A ∧ B)
  have pair : ⊢[fc] A.imp (B.imp (A.and B)) := pairing A B
  have box_pair : ⊢[fc] (A.imp (B.imp (A.and B))).box :=
    DerivationTree.necessitation _ pair
  have mk1 : ⊢[fc] (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B))) (FrameClass.base_le fc)
  have h1 : ⊢[fc] A.box.imp (B.imp (A.and B)).box :=
    DerivationTree.modus_ponens [] _ _ mk1 box_pair
  have mk2 : ⊢[fc] (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist B (A.and B)) (FrameClass.base_le fc)
  have box_to_box : ⊢[fc] A.box.imp (B.box.imp (A.and B).box) := impTrans h1 mk2
  -- Now compose: P → □A and □A → □B → □(A ∧ B) gives P → □B → □(A ∧ B)
  have h2 : ⊢[fc] P.imp (B.box.imp (A.and B).box) := impTrans hA box_to_box
  -- Compose: P → □B → □(A ∧ B) and P → □B gives P → □(A ∧ B)
  -- Use K axiom: (P → (□B → □(A ∧ B))) → ((P → □B) → (P → □(A ∧ B)))
  have k : ⊢[fc] (P.imp (B.box.imp (A.and B).box)).imp ((P.imp B.box).imp (P.imp (A.and B).box)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k P B.box (A.and B).box) (FrameClass.base_le fc)
  have h3 : ⊢[fc] (P.imp B.box).imp (P.imp (A.and B).box) :=
    DerivationTree.modus_ponens [] _ _ k h2
  exact DerivationTree.modus_ponens [] _ _ h3 hB

/--
Three-way boxed conjunction introduction from implications.
From `⊢ P → □A`, `⊢ P → □B`, `⊢ P → □C`, derive `⊢ P → □(A ∧ (B ∧ C))`.
-/
def boxConjIntroImp3 {fc : FrameClass} {P A B C : Formula}
    (hA : ⊢[fc] P.imp A.box) (hB : ⊢[fc] P.imp B.box) (hC : ⊢[fc] P.imp C.box) :
    ⊢[fc] P.imp (A.and (B.and C)).box := by
  have hBC : ⊢[fc] P.imp (B.and C).box := boxConjIntroImp hB hC
  exact boxConjIntroImp hA hBC

/--
P3: `□φ → □△φ` (necessity of perpetuity)

What is necessary is necessarily always true.

Derivation combines three boxed temporal components using modal K distribution:
1. `□φ → □Hφ` (via temporal duality on MF, see `boxToBoxPast`)
2. `□φ → □φ` (identity on boxed formula)
3. `□φ → □Gφ` (MF axiom)
4. Combine using `boxConjIntroImp3` to get `□φ → □(Hφ ∧ (φ ∧ Gφ))`

This proof uses modal K distribution axiom and necessitation rule added in
the axiomatic extension (Phases 1-2).
-/
def perpetuity3 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.box.imp (φ.always.box) := by
  -- always φ = φ.allPast.and (φ.and φ.allFuture) = Hφ ∧ (φ ∧ Gφ)
  -- Goal: ⊢ □φ → □(Hφ ∧ (φ ∧ Gφ))

  -- Component implications from boxed φ to boxed temporal components
  have h_past : ⊢[fc] φ.box.imp (φ.allPast.box) := boxToBoxPast φ
  have h_present : ⊢[fc] φ.box.imp φ.box := identity φ.box
  have h_future : ⊢[fc] φ.box.imp (φ.allFuture.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ) (FrameClass.base_le fc)
  -- Combine using boxConjIntroImp3
  exact boxConjIntroImp3 h_past h_present h_future

/-!
## P4: Possibility of Occurrence

`◇▽φ → ◇φ` (possibility of occurrence)

If it's possible that φ happens at some time (past, present, or future), then φ is possible.
-/

/--
Lemma: Apply double negation elimination inside a box.

From `⊢ □¬¬A`, derive `⊢ □A`.

Proof:
1. DNE axiom: `⊢ ¬¬A → A`
2. Necessitation: `⊢ □(¬¬A → A)`
3. Modal K: `⊢ □(¬¬A → A) → (□¬¬A → □A)`
4. Modus ponens chain: `⊢ □¬¬A → □A`
-/
def boxDne {fc : FrameClass} {A : Formula}
    (h : ⊢[fc] A.neg.neg.box) : ⊢[fc] A.box := by
  -- Step 1: DNE axiom
  have dne : ⊢[fc] A.neg.neg.imp A :=
    double_negation A
  -- Step 2: Necessitate using modal_k with empty context
  have box_dne : ⊢[fc] (A.neg.neg.imp A).box :=
    DerivationTree.necessitation _ dne
  -- Step 3: Modal K distribution
  have mk : ⊢[fc] (A.neg.neg.imp A).box.imp (A.neg.neg.box.imp A.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A.neg.neg A) (FrameClass.base_le fc)
  -- Step 4: Apply modus ponens twice
  have step : ⊢[fc] A.neg.neg.box.imp A.box :=
    DerivationTree.modus_ponens [] _ _ mk box_dne
  exact DerivationTree.modus_ponens [] _ _ step h

/--
P4: `◇▽φ → ◇φ` (possibility of occurrence)

**Derivation Strategy**: Contraposition of P3 applied to `¬φ`, with double negation handling.

The proof navigates the formula structure difference:
- `φ.sometimes.diamond` = `(φ.neg.always.neg).neg.box.neg`
- Target: `φ.diamond` = `φ.neg.box.neg`

Key insight: Use double negation introduction (`notNotIntro`) to build the reverse direction
of DNE, then contrapose to get the needed bridge between formulas.

Proof outline:
1. P3 for `¬φ`: `⊢ □(¬φ) → □△(¬φ)`
2. Contrapose: `⊢ ¬□△(¬φ) → ¬□(¬φ)`
3. Build bridge via DNI: `⊢ △¬φ → ¬¬△¬φ`, lift to box, contrapose
4. Compose all pieces to get final result

**Note**: Uses `notNotIntro` axiom (double negation introduction) which is semantically valid
in TM's classical semantics. The paper states P4 "follows from definitions and classical
logic" (§3.2 lines 1070-1081).
-/
def perpetuity4 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.sometimes.diamond.imp φ.diamond := by
  -- Goal: ⊢ (φ.neg.always.neg).neg.box.neg → φ.neg.box.neg
  --
  -- Strategy:
  -- 1. From P3(¬φ): φ.neg.box → φ.neg.always.box
  -- 2. Contrapose: φ.neg.always.box.neg → φ.neg.box.neg
  -- 3. Build bridge: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  --    using DNI (△¬φ → ¬¬△¬φ) lifted to box and contraposed
  -- 4. Compose bridge with contraposed result

  -- Step 1: Get P3 for ¬φ
  have p3_neg : ⊢[fc] φ.neg.box.imp φ.neg.always.box := perpetuity3 φ.neg
  -- Step 2: Contrapose to get: φ.neg.always.box.neg → φ.neg.box.neg
  have contraposed : ⊢[fc] φ.neg.always.box.neg.imp φ.neg.box.neg := contraposition p3_neg
  -- Step 3: Build bridge using DNI
  -- We need: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  --
  -- Build from DNI: △¬φ → ¬¬△¬φ (i.e., φ.neg.always → φ.neg.always.neg.neg)
  have dni_always : ⊢[fc] φ.neg.always.imp φ.neg.always.neg.neg :=
    notNotIntro φ.neg.always
  -- Necessitate: □(△¬φ → ¬¬△¬φ) using modal_k with empty context
  have box_dni_always : ⊢[fc] (φ.neg.always.imp φ.neg.always.neg.neg).box :=
    DerivationTree.necessitation _ dni_always
  -- Modal K: □(△¬φ → ¬¬△¬φ) → (□△¬φ → □¬¬△¬φ)
  have mk_dni : ⊢[fc] (φ.neg.always.imp φ.neg.always.neg.neg).box.imp
                   (φ.neg.always.box.imp φ.neg.always.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.always φ.neg.always.neg.neg) (FrameClass.base_le fc)
  -- Apply: □△¬φ → □¬¬△¬φ
  have box_dni_imp : ⊢[fc] φ.neg.always.box.imp φ.neg.always.neg.neg.box :=
    DerivationTree.modus_ponens [] _ _ mk_dni box_dni_always
  -- Contrapose: ¬□¬¬△¬φ → ¬□△¬φ
  -- i.e., φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  have bridge : ⊢[fc] φ.neg.always.neg.neg.box.neg.imp φ.neg.always.box.neg :=
    contraposition box_dni_imp
  -- Step 4: Compose bridge with contraposed
  -- bridge: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  -- contraposed: φ.neg.always.box.neg → φ.neg.box.neg
  -- Result: φ.neg.always.neg.neg.box.neg → φ.neg.box.neg
  exact impTrans bridge contraposed

/-!
## P5: Persistent Possibility

`◇▽φ → △◇φ` (persistent possibility)

If it's possible that φ happens sometime, then it's always possible.
-/

/--
Helper lemma: Modal B for diamond forms.

From MB axiom `φ → □◇φ`, we can derive that truths are necessarily possible.
This is used as a foundation for the persistence lemma.
-/
@[tmLemma]
def mbDiamond {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.imp (φ.diamond.box) :=
  DerivationTree.axiom [] _ (Axiom.modal_b φ) (FrameClass.base_le fc)

/--
Helper lemma: Apply TF axiom to boxed diamond.

From `□◇φ`, derive `F□◇φ` (necessarily possible persists to future).
-/
def boxDiamondToFutureBoxDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.box.imp (φ.diamond.box.allFuture) :=
  temporalFutureDerived φ.diamond

/--
Helper lemma: Apply temporal duality to get past component.

From TF on `□◇φ`, derive `H□◇φ` via temporal duality.
-/
def boxDiamondToPastBoxDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.box.imp (φ.diamond.box.allPast) := by
  -- Apply TF to swapped temporal version
  have tf_swap : ⊢[fc] φ.diamond.box.swapTemporal.imp
                    (φ.diamond.box.swapTemporal.allFuture) :=
    boxDiamondToFutureBoxDiamond φ.swapTemporal
  -- Apply temporal duality
  have td : ⊢[fc] (φ.diamond.box.swapTemporal.imp
                φ.diamond.box.swapTemporal.allFuture).swapTemporal :=
    DerivationTree.temporal_duality _ tf_swap
  -- Simplify: swap(swap x) = x
  simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution] at td
  exact td

/--
Temporal K distribution for future: `G(A → B) → (GA → GB)`.

This is the temporal analog of modal K distribution, enabling distribution of
implications through the future operator.

**Semantic Justification**: In task semantics, if A → B holds at all future times
and A holds at all future times, then B must hold at all future times. This follows
from the pointwise nature of implication in the temporal dimension.

**Derivation Strategy**:
1. Start with `[A → B, A] ⊢ B` (modus ponens from assumptions)
2. Apply temporal_k to get `[G(A → B), GA] ⊢ GB`
3. Apply deduction theorem to get `[G(A → B)] ⊢ GA → GB`
4. Apply deduction theorem again to get `⊢ G(A → B) → (GA → GB)`

**Implementation Status**: FULLY DERIVED (zero sorry) using complete deduction theorem
-/
noncomputable def futureKDist {fc : FrameClass} (A B : Formula) :
    ⊢[fc] (A.imp B).allFuture.imp (A.allFuture.imp B.allFuture) := by
  -- Step 1: [A → B, A] ⊢ B via modus ponens
  have step1 : [A.imp B, A] ⊢[fc] B := by
    have h_imp : [A.imp B, A] ⊢[fc] A.imp B := by
      apply DerivationTree.assumption
      simp
    have h_a : [A.imp B, A] ⊢[fc] A := by
      apply DerivationTree.assumption
      simp
    exact DerivationTree.modus_ponens [A.imp B, A] A B h_imp h_a
  
  -- Step 2: Apply generalizedTemporalK to get [G(A → B), GA] ⊢ GB
  have step2 : [(A.imp B).allFuture, A.allFuture] ⊢[fc] B.allFuture := by
    exact FormalSystem.Theorems.generalizedTemporalK [A.imp B, A] B step1
  
  -- Step 3: Reorder context to [GA, G(A → B)] ⊢ GB using weakening
  -- We need GA at the front to apply deduction theorem
  have step3_reordered : [A.allFuture, (A.imp B).allFuture] ⊢[fc] B.allFuture := by
    apply DerivationTree.weakening [(A.imp B).allFuture, A.allFuture] [A.allFuture,
        (A.imp B).allFuture] B.allFuture step2
    intro x hx
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hx ⊢
    exact hx.symm
  
  -- Step 4: Apply deduction theorem to get [G(A → B)] ⊢ GA → GB
  have step4 : [(A.imp B).allFuture] ⊢[fc] A.allFuture.imp B.allFuture := by
    exact FormalSystem.Metalogic.Core.deductionTheorem [(A.imp B).allFuture]
      A.allFuture B.allFuture step3_reordered
  
  -- Step 5: Apply deduction theorem again to get ⊢ G(A → B) → (GA → GB)
  have step5 : [] ⊢[fc] (A.imp B).allFuture.imp (A.allFuture.imp B.allFuture) := by
    exact FormalSystem.Metalogic.Core.deductionTheorem []
      (A.imp B).allFuture (A.allFuture.imp B.allFuture) step4
  
  exact step5

/--
Temporal K distribution for past: `H(A → B) → (HA → HB)`.

This is the past analog of future K distribution, derived via temporal duality.

**Semantic Justification**: By temporal symmetry in task semantics, if A → B holds
at all past times and A holds at all past times, then B must hold at all past times.

**Derivation**: This follows from `futureKDist` applied with temporal duality.
-/
noncomputable def pastKDist {fc : FrameClass} (A B : Formula) :
    ⊢[fc] (A.imp B).allPast.imp (A.allPast.imp B.allPast) := by
  -- Apply futureKDist to swapped formulas
  have fk : ⊢[fc] (A.swapTemporal.imp B.swapTemporal).allFuture.imp
               (A.swapTemporal.allFuture.imp B.swapTemporal.allFuture) :=
    futureKDist A.swapTemporal B.swapTemporal
  -- Apply temporal duality
  have td : ⊢[fc] ((A.swapTemporal.imp B.swapTemporal).allFuture.imp
                (A.swapTemporal.allFuture.imp B.swapTemporal.allFuture)).swapTemporal :=
    DerivationTree.temporal_duality _ fk
  -- Simplify: swap(swap x) = x
  simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution] at td
  exact td

/--
Persistence lemma: `◇φ → △◇φ` (possibility is perpetual).

If φ is possible, then φ is always possible — at every time in the history.

**Derivation**:
1. `modal5`: `◇φ → □◇φ` (the S5 characteristic axiom supplies the lifting step)
2. `temporalFutureDerived` (TF): `□◇φ → G□◇φ`
3. TF under `temporal_duality` (TD): `□◇φ → H□◇φ`
4. `modal_t` (MT) strips each box, and the three temporal components are combined
   into `△◇φ = H◇φ ∧ ◇φ ∧ G◇φ`

This is derived syntactically from the TM axioms; it is not axiomatized.

**Semantic Justification** (Corollary 2.11, paper line 2373):
P5 is semantically valid in task semantics. In any task model, if ◇▽φ holds at (M,τ,t),
then there exists a world history ρ and time s where φ holds. By the S5 structure of
possibility and time-invariance of worlds, this means φ is possible at all times in τ.
-/
noncomputable def persistence {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.diamond.imp φ.diamond.always := by
  -- Goal: ◇φ → △◇φ
  -- Expanded: ◇φ → H◇φ ∧ ◇φ ∧ G◇φ
  --
  -- KEY INSIGHT: Use modal5 (◇φ → □◇φ) as starting point
  -- Then apply TF and TD to □◇φ to get temporal components
  -- Then apply MT to strip the boxes

  -- KEY: Use modal5 to get ◇φ → □◇φ (S5 characteristic axiom)
  have m5 : ⊢[fc] φ.diamond.imp φ.diamond.box := modal5 φ
  -- We can derive: □◇φ → F□◇φ from TF
  have tf : ⊢[fc] φ.diamond.box.imp φ.diamond.box.allFuture :=
    temporalFutureDerived φ.diamond
  -- We can derive: □◇φ → H□◇φ from TD (temporal duality on TF)
  have td : ⊢[fc] φ.diamond.box.imp φ.diamond.box.allPast := by
    -- Apply TF to swapped temporal version
    have tf_swap : ⊢[fc] φ.diamond.box.swapTemporal.imp
                      (φ.diamond.box.swapTemporal.allFuture) :=
      temporalFutureDerived φ.diamond.swapTemporal
    -- Apply temporal duality
    have td_result : ⊢[fc] (φ.diamond.box.swapTemporal.imp
                          φ.diamond.box.swapTemporal.allFuture).swapTemporal :=
      DerivationTree.temporal_duality _ tf_swap
    -- Simplify: swap(swap x) = x
    simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution] at td_result
    exact td_result
  -- Now build the components of △◇φ = H◇φ ∧ ◇φ ∧ G◇φ
  -- We need: ◇φ → H◇φ, ◇φ → ◇φ, ◇φ → G◇φ

  -- Step 1: ◇φ → H◇φ
  have past_comp : ⊢[fc] φ.diamond.imp φ.diamond.allPast := by
    -- We have: ◇φ → □◇φ (m5) and □◇φ → H□◇φ (td)
    -- Compose: ◇φ → H□◇φ
    have chain1 : ⊢[fc] φ.diamond.imp φ.diamond.box.allPast := impTrans m5 td
    -- Apply MT to get □◇φ → ◇φ
    have mt : ⊢[fc] φ.diamond.box.imp φ.diamond := boxToPresent φ.diamond
    -- We need H(□◇φ → ◇φ) to apply past K distribution
    -- Build this by applying temporal_k to the swapped formula, then swap back
    have mt_swap : ⊢[fc] φ.diamond.box.swapTemporal.imp φ.diamond.swapTemporal :=
      boxToPresent φ.diamond.swapTemporal
    have future_mt_swap : ⊢[fc] (φ.diamond.box.swapTemporal.imp φ.diamond.swapTemporal).allFuture :=
      DerivationTree.temporal_necessitation _ mt_swap
    have past_mt_raw :
      ⊢[fc] ((φ.diamond.box.swapTemporal.imp φ.diamond.swapTemporal).allFuture).swapTemporal :=
      DerivationTree.temporal_duality _ future_mt_swap
    -- Simplify using swap_temporal_diamond and swap_temporal_involution
    -- The key: swap(G(...)) = H(swap(...)), and swap is involutive
    -- swap(◇ψ) = ◇(swap ψ) by swap_temporal_diamond
    -- swap(□ψ) = □(swap ψ) similarly (box commutes with swap)
    -- So: swap(G(□◇(swap φ) → ◇(swap φ))) = H(□◇φ → ◇φ)
    have past_mt : ⊢[fc] (φ.diamond.box.imp φ.diamond).allPast := by
      -- Show the equality of formula structures
      show ⊢[fc] (φ.diamond.box.imp φ.diamond).allPast
      -- past_mt_raw has type that simplifies to what we need
      have eq1 :
        ((φ.diamond.box.swapTemporal.imp φ.diamond.swapTemporal).allFuture).swapTemporal =
        (φ.diamond.box.imp φ.diamond).allPast := by
        -- Expand definitions and apply involution/commutation lemmas
        simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
    Formula.swap_temporal_involution]
      rw [← eq1]
      exact past_mt_raw
    -- Use past K distribution: H(□◇φ → ◇φ) → (H□◇φ → H◇φ)
    have pk : ⊢[fc] (φ.diamond.box.imp φ.diamond).allPast.imp
                 (φ.diamond.box.allPast.imp φ.diamond.allPast) :=
      pastKDist φ.diamond.box φ.diamond
    have past_bridge : ⊢[fc] φ.diamond.box.allPast.imp φ.diamond.allPast :=
      DerivationTree.modus_ponens [] _ _ pk past_mt
    exact impTrans chain1 past_bridge
  -- Step 2: ◇φ → ◇φ (identity)
  have present_comp : ⊢[fc] φ.diamond.imp φ.diamond := identity φ.diamond
  -- Step 3: ◇φ → G◇φ
  have future_comp : ⊢[fc] φ.diamond.imp φ.diamond.allFuture := by
    -- We have: ◇φ → □◇φ (m5) and □◇φ → G□◇φ (tf)
    -- Compose: ◇φ → G□◇φ
    have chain2 : ⊢[fc] φ.diamond.imp φ.diamond.box.allFuture := impTrans m5 tf
    -- Apply MT to get □◇φ → ◇φ
    have mt : ⊢[fc] φ.diamond.box.imp φ.diamond := boxToPresent φ.diamond
    -- Lift MT to future using temporal_k
    have future_mt : ⊢[fc] (φ.diamond.box.imp φ.diamond).allFuture :=
      DerivationTree.temporal_necessitation _ mt
    -- Use future K distribution: G(□◇φ → ◇φ) → (G□◇φ → G◇φ)
    have fk : ⊢[fc] (φ.diamond.box.imp φ.diamond).allFuture.imp
                 (φ.diamond.box.allFuture.imp φ.diamond.allFuture) :=
      futureKDist φ.diamond.box φ.diamond
    have future_bridge : ⊢[fc] φ.diamond.box.allFuture.imp φ.diamond.allFuture :=
      DerivationTree.modus_ponens [] _ _ fk future_mt
    exact impTrans chain2 future_bridge
  -- Combine all three components using combineImpConj3
  exact combineImpConj3 past_comp present_comp future_comp

/--
P5: `◇▽φ → △◇φ` (persistent possibility)

**Derivation**: Composition of P4 and persistence lemma:
- P4: `◇▽φ → ◇φ` (possibility of occurrence)
- Persistence: `◇φ → △◇φ` (possibility is perpetual)
- P5: `impTrans (perpetuity4 φ) (persistence φ)`

**Implementation Status**: FULLY PROVEN (zero sorry)
- All components proven as of Phase 3 completion
- Uses `modal5` (`◇φ → □◇φ`, the S5 characteristic axiom derived from MB + diamond4)
- Persistence lemma proven using `swap_temporal_diamond` for formula simplification
- Past component: temporal duality + past K distribution
- Future component: temporal K + future K distribution

**Semantic Justification** (Corollary 2.11):
P5 is semantically valid in task semantics:
1. S5 modal structure ensures possibility is stable across worlds
2. Temporal homogeneity ensures time-invariance of modal facts
3. Therefore: ◇▽φ at t implies ◇φ at all times in any world history
-/
noncomputable def perpetuity5 {fc : FrameClass} (φ : Formula) : ⊢[fc] φ.sometimes.diamond.imp φ.diamond.always :=
  impTrans (perpetuity4 φ) (persistence φ)

end FormalSystem.Theorems.Perpetuity
