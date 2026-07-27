/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Theorems.Perpetuity.Helpers
import FormalSystem.Theorems.Perpetuity.Principles
import FormalSystem.Theorems.Propositional.Connectives

/-!
# Perpetuity Monotonicity and Duality Lemmas, and P6

This module contains bridge lemmas connecting modal and temporal duality,
monotonicity lemmas, and the proof of perpetuity principle P6.

## Main Theorems

- `perpetuity_6`: `▽□φ → □△φ` (occurrent necessity is perpetual)

## Bridge Lemmas

- `modal_duality_neg`: `◇¬φ → ¬□φ` (modal duality forward)
- `modal_duality_neg_rev`: `¬□φ → ◇¬φ` (modal duality reverse)
- `temporal_duality_neg`: `▽¬φ → ¬△φ` (temporal duality forward)
- `temporal_duality_neg_rev`: `¬△φ → ▽¬φ` (temporal duality reverse)
- `bridge1`: `¬□△φ → ◇▽¬φ` (connects modal/temporal negations)
- `bridge2`: `△◇¬φ → ¬▽□φ` (connects temporal/modal negations)

## Monotonicity Lemmas

- `box_mono`: Modal box monotonicity
- `diamond_mono`: Modal diamond monotonicity
- `future_mono`: Future operator monotonicity
- `past_mono`: Past operator monotonicity
- `always_mono`: Always operator monotonicity (axiom placeholder)

## Double Negation Lemmas

- `box_dne`: Boxed Double Negation Elimination
- `double_contrapose`: Contraposition through double negation

## References

* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Helpers.lean](Helpers.lean) - Helper lemmas
* [Principles.lean](Principles.lean) - P1-P5 proofs
-/

namespace FormalSystem.Theorems.Perpetuity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators

-- Many definitions in this module depend on noncomputable deduction_theorem
noncomputable section


/-!
## Modal and Temporal Duality Lemmas

These lemmas establish the relationship between negation and modal/temporal operators,
which are essential for deriving P6 from P5.
-/

/--
Modal duality (forward): `◇¬φ → ¬□φ`.

By definition, `◇¬φ = (¬φ).diamond = (¬φ).neg.box.neg = φ.neg.neg.box.neg`.
We need to derive: `φ.neg.neg.box.neg → φ.box.neg`.

Strategy:
1. Use DNI: `φ → ¬¬φ` to get `□φ → □¬¬φ`
2. Contrapose to get: `¬□¬¬φ → ¬□φ`
3. The goal `φ.neg.neg.box.neg → φ.box.neg` matches step 2
-/
def modalDualityNeg (φ : Formula) : ⊢ φ.neg.diamond.imp φ.box.neg := by
  -- Goal: φ.neg.diamond → ¬□φ
  -- Expand diamond: φ.neg.neg.box.neg → φ.box.neg

  -- Step 1: DNI gives us φ → ¬¬φ
  have dni_phi : ⊢ φ.imp φ.neg.neg :=
    notNotIntro φ
  -- Step 2: Necessitate using modal_k
  have box_dni : ⊢ (φ.imp φ.neg.neg).box :=
    DerivationTree.necessitation _ dni_phi
  -- Step 3: Modal K distribution: □(φ → ¬¬φ) → (□φ → □¬¬φ)
  have mk : ⊢ (φ.imp φ.neg.neg).box.imp (φ.box.imp φ.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ φ.neg.neg) trivial
  -- Step 4: Apply to get □φ → □¬¬φ
  have forward : ⊢ φ.box.imp φ.neg.neg.box :=
    DerivationTree.modus_ponens [] _ _ mk box_dni
  -- Step 5: Contrapose to get ¬□¬¬φ → ¬□φ
  exact contraposition forward

/--
Modal duality (reverse): `¬□φ → ◇¬φ`.

By definition, `◇¬φ = (¬φ).diamond = (¬φ).neg.box.neg = φ.neg.neg.box.neg`.
We need to derive: `φ.box.neg → φ.neg.neg.box.neg`.

Strategy:
1. Use DNE: `¬¬φ → φ` to get `□¬¬φ → □φ`
2. Contrapose to get: `¬□φ → ¬□¬¬φ`
3. The goal `φ.box.neg → φ.neg.neg.box.neg` matches step 2
-/
def modalDualityNegRev (φ : Formula) : ⊢ φ.box.neg.imp φ.neg.diamond := by
  -- Goal: ¬□φ → ◇¬φ
  -- Expand diamond: φ.box.neg → φ.neg.neg.box.neg

  -- Step 1: DNE gives us ¬¬φ → φ
  have dne_phi : ⊢ φ.neg.neg.imp φ :=
    Propositional.doubleNegation φ
  -- Step 2: Necessitate using modal_k
  have box_dne : ⊢ (φ.neg.neg.imp φ).box :=
    DerivationTree.necessitation _ dne_phi
  -- Step 3: Modal K distribution: □(¬¬φ → φ) → (□¬¬φ → □φ)
  have mk : ⊢ (φ.neg.neg.imp φ).box.imp (φ.neg.neg.box.imp φ.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.neg φ) trivial
  -- Step 4: Apply to get □¬¬φ → □φ
  have forward : ⊢ φ.neg.neg.box.imp φ.box :=
    DerivationTree.modus_ponens [] _ _ mk box_dne
  -- Step 5: Contrapose to get ¬□φ → ¬□¬¬φ
  exact contraposition forward

/-!
## Monotonicity Lemmas for P6 Derivation

These lemmas establish that modal and temporal operators are monotonic with respect
to implication, which is essential for the P6 derivation via duality transformations.
-/

/--
Box monotonicity: from `⊢ A → B`, derive `⊢ □A → □B`.

Uses necessitation (modal_k) and K distribution axiom.
-/
def boxMono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.box.imp B.box := by
  have box_h : ⊢ (A.imp B).box := DerivationTree.necessitation _ h
  have mk : ⊢ (A.imp B).box.imp (A.box.imp B.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A B) trivial
  exact DerivationTree.modus_ponens [] _ _ mk box_h

/--
Diamond monotonicity: from `⊢ A → B`, derive `⊢ ◇A → ◇B`.

Derived via contraposition of box_mono applied to the negated implication.
-/
def diamondMono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.diamond.imp B.diamond := by
  have contra : ⊢ B.neg.imp A.neg := contraposition h
  have box_contra : ⊢ B.neg.box.imp A.neg.box := boxMono contra
  exact contraposition box_contra

/--
Future monotonicity: from `⊢ A → B`, derive `⊢ GA → GB`.

Uses temporal K rule and future K distribution axiom.
-/
def futureMono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.allFuture.imp B.allFuture := by
  have g_h : ⊢ (A.imp B).allFuture := DerivationTree.temporal_necessitation _ h
  have fk : ⊢ (A.imp B).allFuture.imp (A.allFuture.imp B.allFuture) := futureKDist A B
  exact DerivationTree.modus_ponens [] _ _ fk g_h

/--
Past monotonicity: from `⊢ A → B`, derive `⊢ HA → HB`.

Derived via temporal duality from future monotonicity.
-/
def pastMono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.allPast.imp B.allPast := by
  have h_swap : ⊢ A.swapTemporal.imp B.swapTemporal := by
    have td : ⊢ (A.imp B).swapTemporal := DerivationTree.temporal_duality (A.imp B) h
    exact td
  have g_swap : ⊢ (A.swapTemporal.imp B.swapTemporal).allFuture :=
    DerivationTree.temporal_necessitation _ h_swap
  have past_raw : ⊢ ((A.swapTemporal.imp B.swapTemporal).allFuture).swapTemporal :=
    DerivationTree.temporal_duality _ g_swap
  have h_past : ⊢ (A.imp B).allPast := by
    simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
      Formula.swap_temporal_involution] at past_raw
    exact past_raw
  have pk : ⊢ (A.imp B).allPast.imp (A.allPast.imp B.allPast) := pastKDist A B
  exact DerivationTree.modus_ponens [] _ _ pk h_past

/-!
## Local Conjunction Elimination Lemmas

These are local copies to avoid circular dependency with Propositional module.
Propositional imports Perpetuity, so we cannot import it here.
-/






/-!
## Decomposition Lemmas for Always Operator

These lemmas enable breaking down `always φ = Hφ ∧ (φ ∧ Gφ)` into components.
Essential for deriving `always_dni` and `always_dne`.
-/

/--
Decomposition: `⊢ △φ → Hφ` (always implies past component).

Extract the past component from the always operator using left conjunction elimination.
-/
def alwaysToPast (φ : Formula) : ⊢ φ.always.imp φ.allPast := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Use lce_imp to extract first conjunct
  exact Propositional.lceImp φ.allPast (φ.and φ.allFuture)

/--
Decomposition: `⊢ △φ → φ` (always implies present component).

Extract the present component from the always operator.
-/
def alwaysToPresent (φ : Formula) : ⊢ φ.always.imp φ := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Step 1: Extract (φ ∧ Gφ) using rce_imp
  have step1 : ⊢ φ.always.imp (φ.and φ.allFuture) :=
    Propositional.rceImp φ.allPast (φ.and φ.allFuture)
  -- Step 2: Extract φ from (φ ∧ Gφ) using lce_imp
  have step2 : ⊢ (φ.and φ.allFuture).imp φ :=
    Propositional.lceImp φ φ.allFuture
  -- Step 3: Compose
  exact impTrans step1 step2

/--
Decomposition: `⊢ △φ → Gφ` (always implies future component).

Extract the future component from the always operator.
-/
def alwaysToFuture (φ : Formula) : ⊢ φ.always.imp φ.allFuture := by
  -- always φ = Hφ ∧ (φ ∧ Gφ)
  -- Step 1: Extract (φ ∧ Gφ) using rce_imp
  have step1 : ⊢ φ.always.imp (φ.and φ.allFuture) :=
    Propositional.rceImp φ.allPast (φ.and φ.allFuture)
  -- Step 2: Extract Gφ from (φ ∧ Gφ) using rce_imp
  have step2 : ⊢ (φ.and φ.allFuture).imp φ.allFuture :=
    Propositional.rceImp φ φ.allFuture
  -- Step 3: Compose
  exact impTrans step1 step2

/--
Composition: `⊢ (Hφ ∧ (φ ∧ Gφ)) → △φ` (components imply always).

This is trivial by definitional equality since `always φ = Hφ ∧ (φ ∧ Gφ)`.
-/
def pastPresentFutureToAlways (φ : Formula) :
    ⊢ (φ.allPast.and (φ.and φ.allFuture)).imp φ.always := by
  -- Definitional equality: always φ = Hφ ∧ (φ ∧ Gφ)
  exact identity (φ.allPast.and (φ.and φ.allFuture))

/--
Derived def: DNI distributes over always.

From `always φ → always (¬¬φ)`, we can derive the temporal analog of double negation introduction.

**Derivation Strategy**:
1. Decompose `△φ` into `Hφ ∧ φ ∧ Gφ`
2. Apply `dni` to `φ`: `φ → ¬¬φ`
3. Apply `past_k_dist` and `future_k_dist` to get `Hφ → H(¬¬φ)` and `Gφ → G(¬¬φ)`
4. Recombine: `H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ) = △(¬¬φ)`
-/
def alwaysDni (φ : Formula) : ⊢ φ.always.imp φ.neg.neg.always := by
  -- Step 1: Get DNI for φ
  have dni_phi : ⊢ φ.imp φ.neg.neg := notNotIntro φ
  -- Step 2: Lift through past operator
  have past_lift : ⊢ φ.allPast.imp φ.neg.neg.allPast := by
    have pk : ⊢ (φ.imp φ.neg.neg).allPast.imp (φ.allPast.imp φ.neg.neg.allPast) :=
      pastKDist φ φ.neg.neg
    have past_dni : ⊢ (φ.imp φ.neg.neg).allPast := by
      have h_swap : ⊢ (φ.imp φ.neg.neg).swapTemporal := DerivationTree.temporal_duality _ dni_phi
      have g_swap : ⊢ (φ.imp φ.neg.neg).swapTemporal.allFuture :=
        DerivationTree.temporal_necessitation _ h_swap
      have past_raw : ⊢ ((φ.imp φ.neg.neg).swapTemporal.allFuture).swapTemporal :=
        DerivationTree.temporal_duality _ g_swap
      simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
      Formula.swap_temporal_involution] at past_raw
      exact past_raw
    exact DerivationTree.modus_ponens [] _ _ pk past_dni
  -- Step 3: Present is just dni_phi

  -- Step 4: Lift through future operator
  have future_lift : ⊢ φ.allFuture.imp φ.neg.neg.allFuture := by
    have fk : ⊢ (φ.imp φ.neg.neg).allFuture.imp (φ.allFuture.imp φ.neg.neg.allFuture) :=
      futureKDist φ φ.neg.neg
    have future_dni : ⊢ (φ.imp φ.neg.neg).allFuture :=
      DerivationTree.temporal_necessitation _ dni_phi
    exact DerivationTree.modus_ponens [] _ _ fk future_dni
  -- Step 5: Decompose always φ and apply lifts
  have to_past : ⊢ φ.always.imp φ.allPast := alwaysToPast φ
  have to_present : ⊢ φ.always.imp φ := alwaysToPresent φ
  have to_future : ⊢ φ.always.imp φ.allFuture := alwaysToFuture φ
  have past_comp : ⊢ φ.always.imp φ.neg.neg.allPast := impTrans to_past past_lift
  have present_comp : ⊢ φ.always.imp φ.neg.neg := impTrans to_present dni_phi
  have future_comp : ⊢ φ.always.imp φ.neg.neg.allFuture := impTrans to_future future_lift
  -- Step 6: Combine into nested conjunction
  have present_future : ⊢ φ.always.imp (φ.neg.neg.and φ.neg.neg.allFuture) :=
    combineImpConj present_comp future_comp
  have all_three : ⊢ φ.always.imp (φ.neg.neg.allPast.and (φ.neg.neg.and φ.neg.neg.allFuture)) :=
    combineImpConj past_comp present_future
  -- Step 7: Result is definitionally equal to always (¬¬φ)
  exact all_three

/--
Temporal duality (forward): `▽¬φ → ¬△φ`.

By definitions:
- `▽¬φ = sometimes (¬φ) = (¬φ).neg.always.neg = (φ.neg).neg.always.neg`
- `△φ = always φ = φ.always`

We need to derive: `(φ.neg).neg.always.neg → φ.always.neg`.

But `(φ.neg).neg = φ` after expansion and double negation.

Strategy:
1. Use `always_dni`: `always(φ) → always(¬¬φ)`
   Which is: `φ.always → φ.neg.neg.always`
2. Contrapose to get: `¬always(¬¬φ) → ¬always(φ)`
   Which is: `φ.neg.neg.always.neg → φ.always.neg`
3. But we need to substitute φ.neg for φ to get the right form

Actually the substitution should be on φ.neg:
  `(φ.neg).always → (φ.neg).neg.neg.always`
Contrapose: `(φ.neg).neg.neg.always.neg → (φ.neg).always.neg`

This matches our goal if we recognize that `(φ.neg).always = (always (¬φ))` and
`(φ.neg).neg.neg.always = (always (¬¬¬φ))`.

Let me reconsider: the goal type is asking for:
  `φ.neg.sometimes → φ.always.neg`

Expand `φ.neg.sometimes`:
  `sometimes (φ.neg) = (φ.neg).neg.always.neg`

So the actual Lean type is:
  `((φ.neg).neg.always).neg → (φ.always).neg`

Simplify: `(φ.neg).neg` in the formula language, not in Lean's type system.
So this is asking: `(always ((φ → ⊥) → ⊥)).neg → (always φ).neg`

Use DNI on φ: `φ.always → φ.neg.neg.always` and contrapose.
-/
def temporalDualityNeg (φ : Formula) : ⊢ φ.neg.sometimes.imp φ.always.neg := by
  -- Goal: φ.neg.sometimes → φ.always.neg
  -- Expand: (φ.neg).neg.always.neg → φ.always.neg

  -- Step 1: Get always_dni for φ
  have adni : ⊢ φ.always.imp φ.neg.neg.always :=
    alwaysDni φ
  -- Step 2: Contrapose to get φ.neg.neg.always.neg → φ.always.neg
  exact contraposition adni

/--
Derived def: DNE distributes over always.

From `always (¬¬φ) → always φ`, we can derive the temporal analog of double negation elimination.

**Derivation Strategy**: Mirror of always_dni but using `Propositional.double_negation`
instead of `dni`.
-/
def alwaysDne (φ : Formula) : ⊢ φ.neg.neg.always.imp φ.always := by
  -- Step 1: Get DNE for φ
  have dne_phi : ⊢ φ.neg.neg.imp φ := Propositional.doubleNegation φ
  -- Step 2: Lift through past operator
  have past_lift : ⊢ φ.neg.neg.allPast.imp φ.allPast := by
    have pk : ⊢ (φ.neg.neg.imp φ).allPast.imp (φ.neg.neg.allPast.imp φ.allPast) :=
      pastKDist φ.neg.neg φ
    have past_dne : ⊢ (φ.neg.neg.imp φ).allPast := by
      have h_swap : ⊢ (φ.neg.neg.imp φ).swapTemporal := DerivationTree.temporal_duality _ dne_phi
      have g_swap : ⊢ (φ.neg.neg.imp φ).swapTemporal.allFuture :=
        DerivationTree.temporal_necessitation _ h_swap
      have past_raw : ⊢ ((φ.neg.neg.imp φ).swapTemporal.allFuture).swapTemporal :=
        DerivationTree.temporal_duality _ g_swap
      simp only [Formula.swapTemporal, Formula.swap_temporal_all_future,
      Formula.swap_temporal_involution] at past_raw
      exact past_raw
    exact DerivationTree.modus_ponens [] _ _ pk past_dne
  -- Step 3: Present is just dne_phi

  -- Step 4: Lift through future operator
  have future_lift : ⊢ φ.neg.neg.allFuture.imp φ.allFuture := by
    have fk : ⊢ (φ.neg.neg.imp φ).allFuture.imp (φ.neg.neg.allFuture.imp φ.allFuture) :=
      futureKDist φ.neg.neg φ
    have future_dne : ⊢ (φ.neg.neg.imp φ).allFuture :=
      DerivationTree.temporal_necessitation _ dne_phi
    exact DerivationTree.modus_ponens [] _ _ fk future_dne
  -- Step 5: Decompose always (¬¬φ) and apply lifts
  have to_past : ⊢ φ.neg.neg.always.imp φ.neg.neg.allPast := alwaysToPast φ.neg.neg
  have to_present : ⊢ φ.neg.neg.always.imp φ.neg.neg := alwaysToPresent φ.neg.neg
  have to_future : ⊢ φ.neg.neg.always.imp φ.neg.neg.allFuture := alwaysToFuture φ.neg.neg
  have past_comp : ⊢ φ.neg.neg.always.imp φ.allPast := impTrans to_past past_lift
  have present_comp : ⊢ φ.neg.neg.always.imp φ := impTrans to_present dne_phi
  have future_comp : ⊢ φ.neg.neg.always.imp φ.allFuture := impTrans to_future future_lift
  -- Step 6: Combine into nested conjunction
  have present_future : ⊢ φ.neg.neg.always.imp (φ.and φ.allFuture) :=
    combineImpConj present_comp future_comp
  have all_three : ⊢ φ.neg.neg.always.imp (φ.allPast.and (φ.and φ.allFuture)) :=
    combineImpConj past_comp present_future
  -- Step 7: Result is definitionally equal to always φ
  exact all_three

/--
Temporal duality (reverse): `¬△φ → ▽¬φ`.

By definitions:
- `▽¬φ = sometimes (¬φ) = (¬φ).neg.always.neg`
- `△φ = always φ`

We need to derive: `φ.always.neg → (φ.neg).neg.always.neg`.

Strategy:
1. Use `always_dne`: `always(¬¬φ) → always(φ)`
   Which is: `φ.neg.neg.always → φ.always`
2. Contrapose to get: `¬always(φ) → ¬always(¬¬φ)`
   Which is: `φ.always.neg → φ.neg.neg.always.neg`
3. This matches our goal
-/
def temporalDualityNegRev (φ : Formula) : ⊢ φ.always.neg.imp φ.neg.sometimes := by
  -- Goal: φ.always.neg → φ.neg.sometimes
  -- Expand: φ.always.neg → (φ.neg).neg.always.neg

  -- Step 1: Get always_dne for φ
  have adne : ⊢ φ.neg.neg.always.imp φ.always :=
    alwaysDne φ
  -- Step 2: Contrapose to get φ.always.neg → φ.neg.neg.always.neg
  exact contraposition adne


/--
Always monotonicity: from `⊢ A → B`, derive `⊢ △A → △B`.

**Derivation Strategy**:
1. Decompose `△A` into `HA ∧ A ∧ GA` using decomposition lemmas
2. Apply `past_mono` to get `HA → HB`
3. Use the given `A → B`
4. Apply `future_mono` to get `GA → GB`
5. Combine to get `HB ∧ B ∧ GB = △B`

**Usage**: Essential for P6 derivation to lift modal_duality_neg through always.
-/
def alwaysMono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.always.imp B.always := by
  -- Step 1: Get monotonicity for each component
  have past_h : ⊢ A.allPast.imp B.allPast := pastMono h
  have future_h : ⊢ A.allFuture.imp B.allFuture := futureMono h
  
  -- Step 2: Decompose △A into components
  have to_past : ⊢ A.always.imp A.allPast := alwaysToPast A
  have to_present : ⊢ A.always.imp A := alwaysToPresent A
  have to_future : ⊢ A.always.imp A.allFuture := alwaysToFuture A
  
  -- Step 3: Compose to get △A → HB, △A → B, △A → GB
  have comp_past : ⊢ A.always.imp B.allPast := impTrans to_past past_h
  have comp_present : ⊢ A.always.imp B := impTrans to_present h
  have comp_future : ⊢ A.always.imp B.allFuture := impTrans to_future future_h
  
  -- Step 4: Combine into △A → (HB ∧ (B ∧ GB))
  have present_future : ⊢ A.always.imp (B.and B.allFuture) :=
    combineImpConj comp_present comp_future
  have all_three : ⊢ A.always.imp (B.allPast.and (B.and B.allFuture)) :=
    combineImpConj comp_past present_future
  
  -- Step 5: Result is definitionally equal to △B
  exact all_three


/--
Double contraposition: from `⊢ ¬A → ¬B`, derive `⊢ B → A`.

Combines contraposition with DNE/DNI to handle the double negations.

Proof:
1. Contrapose `¬A → ¬B` to get `¬¬B → ¬¬A`
2. Chain with DNE: `¬¬B → ¬¬A → A`
3. Prepend DNI: `B → ¬¬B → A`
-/
def doubleContrapose {A B : Formula} (h : ⊢ A.neg.imp B.neg) : ⊢ B.imp A := by
  have contra : ⊢ B.neg.neg.imp A.neg.neg := contraposition h
  have dne_a : ⊢ A.neg.neg.imp A := Propositional.doubleNegation A
  have chain : ⊢ B.neg.neg.imp A := impTrans contra dne_a
  have dni_b : ⊢ B.imp B.neg.neg := notNotIntro B
  exact impTrans dni_b chain

/-!
## Bridge Lemmas for P6 Derivation

These lemmas connect the formula structures needed to derive P6 from P5(¬φ).
-/

/--
Bridge 1: `¬□△φ → ◇▽¬φ`

Connects negated box-always to diamond-sometimes-neg using modal and temporal duality.

Proof:
1. `modal_duality_neg_rev` on `△φ`: `¬□△φ → ◇¬△φ`
2. `temporal_duality_neg_rev` on `φ`: `¬△φ → ▽¬φ`
3. `diamond_mono` lifts step 2: `◇¬△φ → ◇▽¬φ`
4. Compose steps 1 and 3
-/
def bridge1 (φ : Formula) : ⊢ φ.always.box.neg.imp φ.neg.sometimes.diamond := by
  have md_rev : ⊢ φ.always.box.neg.imp (φ.always).neg.diamond :=
    modalDualityNegRev φ.always
  have td_rev : ⊢ φ.always.neg.imp φ.neg.sometimes :=
    temporalDualityNegRev φ
  have dm : ⊢ (φ.always).neg.diamond.imp φ.neg.sometimes.diamond :=
    diamondMono td_rev
  exact impTrans md_rev dm

/--
Bridge 2: `△◇¬φ → ¬▽□φ`

Connects always-diamond-neg to negated sometimes-box using modal duality and DNI.

Proof:
1. `modal_duality_neg` on `φ`: `◇¬φ → ¬□φ`
2. `always_mono` lifts step 1: `△◇¬φ → △¬□φ`
3. DNI on `△¬□φ`: `△¬□φ → ¬¬△¬□φ`
4. Observe: `¬¬△¬□φ = (¬▽□φ)` since `▽ψ = ¬△¬ψ`
5. Compose steps 2 and 3
-/
def bridge2 (φ : Formula) : ⊢ φ.neg.diamond.always.imp φ.box.sometimes.neg := by
  have md : ⊢ φ.neg.diamond.imp φ.box.neg := modalDualityNeg φ
  have am : ⊢ φ.neg.diamond.always.imp φ.box.neg.always := alwaysMono md
  have dni_step : ⊢ φ.box.neg.always.imp φ.box.neg.always.neg.neg :=
    notNotIntro φ.box.neg.always
  exact impTrans am dni_step

/-!
## P6: Occurrent Necessity is Perpetual

`▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time (past, present, or future), then it's always necessary.
-/

/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time, it is always necessary.

**Derivation**: Contraposition of P5 applied to `¬φ` with operator duality:
1. P5 for `¬φ`: `◇▽¬φ → △◇¬φ`
2. Bridge 1: `¬□△φ → ◇▽¬φ`
3. Bridge 2: `△◇¬φ → ¬▽□φ`
4. Chain: `¬□△φ → ◇▽¬φ → △◇¬φ → ¬▽□φ`
5. Double contrapose to get: `▽□φ → □△φ`

The derivation uses:
- `perpetuity_5` (P5)
- `bridge1` (`¬□△φ → ◇▽¬φ`)
- `bridge2` (`△◇¬φ → ¬▽□φ`)
- `double_contrapose` (handles DNE/DNI for contraposition)

**Implementation Status**: FULLY PROVEN (zero sorry)
-/
def perpetuity6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always :=
    perpetuity5 φ.neg
  have b1 : ⊢ φ.always.box.neg.imp φ.neg.sometimes.diamond := bridge1 φ
  have b2 : ⊢ φ.neg.diamond.always.imp φ.box.sometimes.neg := bridge2 φ
  -- Chain: ¬□△φ → ¬▽□φ
  have chain : ⊢ φ.always.box.neg.imp φ.box.sometimes.neg := by
    have step1 : ⊢ φ.always.box.neg.imp φ.neg.diamond.always := impTrans b1 p5_neg
    exact impTrans step1 b2
  -- Double contrapose: from ¬A → ¬B, get B → A
  exact doubleContrapose chain

/-!
## Summary

**Fully Proven Theorems** (zero sorry):
- P1: `□φ → △φ` (necessary implies always)
  - Uses `box_to_past`, `box_to_present`, `box_to_future` helper lemmas
  - Combines with `combine_imp_conj_3` for conjunction introduction
  - Requires `pairing` axiom for internal conjunction combinator
- P2: `▽φ → ◇φ` (sometimes implies possible)
  - Contraposition of P1 applied to `¬φ`
  - Uses `contraposition` def (proven via B combinator)
- P3: `□φ → □△φ` (necessity of perpetuity)
  - Uses `box_to_box_past`, identity, MF axiom for components
  - Combines with `box_conj_intro_imp_3` for boxed conjunction
  - Uses modal K distribution axiom (added in Phase 1-2)
- P4: `◇▽φ → ◇φ` (possibility of occurrence)
  - Contraposition of P3 applied to `¬φ`
  - Uses DNI axiom to bridge double negation in formula structure
  - Complete proof with zero sorry (Phase 2)
- **Persistence lemma**: `◇φ → △◇φ` (zero sorry)
  - Helper components proven: `modal_5` (`◇φ → □◇φ` from MB + diamond_4)
  - Uses `swap_temporal_diamond` and `swap_temporal_involution` for formula simplification
  - Past component: temporal duality + past K distribution
  - Future component: temporal K + future K distribution
  - FULLY PROVEN as of Phase 3 completion
- P5: `◇▽φ → △◇φ` (persistent possibility)
  - Derived: `imp_trans (perpetuity_4 φ) (persistence φ)`
  - Uses `modal_5` def (`◇φ → □◇φ`) which is derived from MB + diamond_4
  - FULLY PROVEN (zero sorry, depends on proven persistence lemma)

- P6: `▽□φ → □△φ` (occurrent necessity is perpetual)
  - Contraposition of P5 applied to `¬φ` with operator duality
  - Uses `bridge1` (`¬□△φ → ◇▽¬φ`) and `bridge2` (`△◇¬φ → ¬▽□φ`)
  - FULLY PROVEN (zero sorry) via double_contrapose

**Helper Lemmas Proven**:
- `imp_trans`: Transitivity of implication (from K and S axioms)
- `identity`: Identity combinator `⊢ A → A` (SKK construction)
- `b_combinator`: Function composition `⊢ (B → C) → (A → B) → (A → C)`
- `combine_imp_conj`: Combine implications into conjunction implication
- `combine_imp_conj_3`: Three-way version for P1
- `box_to_future`: `⊢ □φ → Gφ` (MF + MT)
- `box_to_past`: `⊢ □φ → Hφ` (temporal duality on MF)
- `box_to_present`: `⊢ □φ → φ` (MT axiom)
- `box_to_box_past`: `⊢ □φ → □Hφ` (temporal duality on MF)
- `box_conj_intro`: Boxed conjunction introduction
- `box_conj_intro_imp`: Implicational version for combining `P → □A` and `P → □B`
- `box_conj_intro_imp_3`: Three-way version for P3
- `box_dne`: Apply DNE inside modal box
- `mb_diamond`: Modal B axiom instantiation for diamonds
- `box_diamond_to_future_box_diamond`: TF axiom for `□◇φ`
- `box_diamond_to_past_box_diamond`: Temporal duality for `□◇φ`
- `contraposition`: Classical contraposition (proven via B combinator)
- `box_mono`: Box monotonicity `⊢ (A → B) → (□A → □B)` (via necessitation + K)
- `diamond_mono`: Diamond monotonicity `⊢ (A → B) → (◇A → ◇B)` (via contraposition of box_mono)
- `future_mono`: Future monotonicity `⊢ (A → B) → (GA → GB)` (via temporal K + future K dist)
- `past_mono`: Past monotonicity `⊢ (A → B) → (HA → HB)` (via temporal duality on future_mono)
- `double_contrapose`: From `⊢ ¬A → ¬B`, derive `⊢ B → A` (combines contraposition with DNE/DNI)
- `bridge1`: `⊢ ¬□△φ → ◇▽¬φ` (for P6 derivation)
- `bridge2`: `⊢ △◇¬φ → ¬▽□φ` (for P6 derivation)

**Axioms Used** (semantically justified):
- `pairing`: `⊢ A → B → A ∧ B` (conjunction introduction combinator)
- `dni`: `⊢ A → ¬¬A` (double negation introduction, classical logic)
- `always_mono`: `⊢ (A → B) → (△A → △B)` (always monotonicity, derivable but complex)

**Sorry Count**: 0 (all proven defs have zero sorry)

**Implementation Status**:
- P1: ✓ FULLY PROVEN (zero sorry)
- P2: ✓ FULLY PROVEN (zero sorry)
- P3: ✓ FULLY PROVEN (zero sorry)
- P4: ✓ FULLY PROVEN (zero sorry)
- P5: ✓ FULLY PROVEN (zero sorry, via P4 + persistence)
- P6: ✓ FULLY PROVEN (zero sorry, via P5(¬φ) + bridge lemmas + double_contrapose)

**ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN** (100% completion)

**Future Work**:
1. Derive `always_mono` compositionally (requires conjunction elimination lemmas)
2. Add `swap_temporal_box` lemma to show box commutes with temporal swap (for symmetry)
3. Document modal-temporal duality relationships more precisely
-/

end

end FormalSystem.Theorems.Perpetuity
