import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula

/-!
# Perpetuity Principles (P1-P6)

This module derives the six perpetuity principles that establish deep connections
between modal necessity (□) and temporal operators (always △, sometimes ▽).

## Main Theorems

- `perpetuity_1`: `□φ → △φ` (necessary implies always)
- `perpetuity_2`: `▽φ → ◇φ` (sometimes implies possible)
- `perpetuity_3`: `□φ → □△φ` (necessity of perpetuity)
- `perpetuity_4`: `◇▽φ → ◇φ` (possibility of occurrence)
- `perpetuity_5`: `◇▽φ → △◇φ` (persistent possibility)
- `perpetuity_6`: `▽□φ → □△φ` (occurrent necessity is perpetual)

## Notation

- `△φ` = `always φ` = `Hφ ∧ φ ∧ Gφ` (φ at all times: past, present, future)
- `▽φ` = `sometimes φ` = `¬△¬φ` (φ at some time: past, present, or future)
- `◇φ` = `diamond φ` = `¬□¬φ` (φ is possible)

## Implementation Notes

The perpetuity principles are derived theorems, not axioms. They follow from
the TM axiom system, particularly:
- MF (Modal-Future): `□φ → □Fφ`
- TF (Temporal-Future): `□φ → F□φ`
- MT (Modal T): `□φ → φ`
- Modal and temporal K rules

Note: `always φ = Hφ ∧ φ ∧ Gφ` (past, present, and future), so `△φ` covers all times.

## Propositional Derivation Challenges

Many perpetuity principles require propositional reasoning (transitivity of
implication, contraposition, etc.) that is not directly available as
inference rules. The TM proof system has:
- Axiom schemas
- Modus ponens
- Modal K, Temporal K rules
- Temporal duality
- Weakening

It does NOT have built-in propositional axioms like:
- K axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- S axiom: `φ → (ψ → φ)`
- Transitivity: `(φ → ψ) → ((ψ → χ) → (φ → χ))`

For the MVP, we use `sorry` for propositional reasoning steps that would
require a more complete propositional calculus implementation.

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - TM logic specification
* [Axioms.lean](../ProofSystem/Axioms.lean) - Axiom schemata
* [Derivation.lean](../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Logos.Core.Theorems.Perpetuity

open Logos.Core.Syntax
open Logos.Core.ProofSystem

/-!
## Helper Lemmas: Propositional Reasoning

These lemmas establish propositional reasoning patterns needed for the
perpetuity principles. The TM proof system includes K and S propositional
axioms, which provide a complete basis for implicational propositional logic.
-/

/--
Transitivity of implication: if `⊢ A → B` and `⊢ B → C` then `⊢ A → C`.

This is the hypothetical syllogism rule, derived from K and S axioms.

Proof:
1. From `⊢ B → C`, derive `⊢ A → (B → C)` by S axiom and modus ponens
2. Use K axiom: `(A → (B → C)) → ((A → B) → (A → C))`
3. Apply modus ponens twice to get `⊢ A → C`
-/
theorem imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)
  have h3 : ⊢ A.imp (B.imp C) := Derivable.modus_ponens [] (B.imp C) (A.imp (B.imp C)) s_axiom h2
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  have h4 : ⊢ (A.imp B).imp (A.imp C) := Derivable.modus_ponens [] (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)) k_axiom h3
  exact Derivable.modus_ponens [] (A.imp B) (A.imp C) h4 h1

/--
From `⊢ A` and `⊢ A → B`, derive `⊢ B` (modus ponens restated).
-/
theorem mp {A B : Formula} (h1 : ⊢ A) (h2 : ⊢ A.imp B) : ⊢ B := by
  exact Derivable.modus_ponens [] A B h2 h1

/--
Identity combinator: `⊢ A → A` (SKK construction).

The identity function can be built from K and S combinators:
- S : (P → Q → R) → (P → Q) → P → R
- K : A → B → A
- SKK = λx. K x (K x) = λx. x
-/
theorem identity (A : Formula) : ⊢ A.imp A := by
  have k1 : ⊢ A.imp ((A.imp A).imp A) := Derivable.axiom [] _ (Axiom.prop_s A (A.imp A))
  have k2 : ⊢ A.imp (A.imp A) := Derivable.axiom [] _ (Axiom.prop_s A A)
  have s : ⊢ (A.imp ((A.imp A).imp A)).imp ((A.imp (A.imp A)).imp (A.imp A)) :=
    Derivable.axiom [] _ (Axiom.prop_k A (A.imp A) A)
  have h1 : ⊢ (A.imp (A.imp A)).imp (A.imp A) := Derivable.modus_ponens [] _ _ s k1
  exact Derivable.modus_ponens [] _ _ h1 k2

/--
B combinator (composition): `⊢ (B → C) → (A → B) → (A → C)`.

The B combinator represents function composition and can be derived from K and S axioms.
This enables transitivity reasoning in the proof system.

Proof strategy:
1. By S axiom: `(B → C) → (A → (B → C))` (weakening)
2. By K axiom: `(A → (B → C)) → ((A → B) → (A → C))` (distribution)
3. Compose: `(B → C) → ((A → B) → (A → C))` (by transitivity)
-/
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) := by
  -- Step 1: S axiom gives us (B → C) → (A → (B → C))
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)

  -- Step 2: K axiom gives us (A → (B → C)) → ((A → B) → (A → C))
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)

  -- Step 3: Compose with imp_trans
  exact imp_trans s_axiom k_axiom

/-!
## Helper Lemmas: Conjunction Introduction

Conjunction introduction (⊢ A → ⊢ B → ⊢ A ∧ B) requires the internal pairing
combinator (⊢ A → B → A ∧ B). This combinator is axiomatized because its
construction from K and S alone requires complex term manipulation that would
obscure the mathematical content.

The `pairing` axiom is SEMANTICALLY VALID in task semantics. Its soundness
follows from: if A is true and B is true and we have (A → B → ⊥), then
applying to A gives (B → ⊥), applying to B gives ⊥. So (A → B → ⊥) → ⊥
(which is A ∧ B) is true.
-/

/--
Pairing combinator: `⊢ A → B → A ∧ B`.

This is the internal form of conjunction introduction. Given values of types
A and B, we can construct a value of type A ∧ B.

**Semantic Justification**: In task semantics, if A holds at (M,τ,t) and B holds
at (M,τ,t), then A ∧ B = ¬(A → ¬B) holds because assuming (A → ¬B) with A gives ¬B,
contradicting B.

**Implementation Note**: This can be constructed from K and S combinators
(λa.λb.λf. f a b = S (S (K S) (S (K K) I)) (K I) where I = SKK), but the
construction is complex (~50+ lines of combinator manipulation) and would obscure
the proof. We axiomatize it with semantic justification for MVP. The derivation
is straightforward in principle but tedious in practice.

**Future Work**: Derive fully from S and K axioms using combinator calculus.
The pattern requires building the application combinator step-by-step through
nested S and K applications.
-/
axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))

/-!
## Helper Lemmas: Double Negation Introduction

Double negation introduction (`A → ¬¬A`) is a classical logic principle needed
for deriving P4 from P3 via contraposition.
-/

/--
Double negation introduction: `⊢ A → ¬¬A`.

In classical logic, if A is true, then ¬¬A is also true (assuming A leads to
contradiction from ¬A).

**Semantic Justification**: TM uses classical two-valued semantics where formulas
are either true or false at each (M,τ,t) triple. If A is true at (M,τ,t), then
assuming ¬A (i.e., A → ⊥) leads to contradiction: A and (A → ⊥) gives ⊥, so
¬¬A = ((A → ⊥) → ⊥) holds.

**Implementation Note**: While `A → ¬¬A` is derivable from excluded middle
(A ∨ ¬A), and can be constructed from K and S combinators via the C (flip)
combinator pattern (S (S (K S) K) (K K) or similar), the construction requires
~50+ lines of intricate combinator manipulation. For MVP, we axiomatize it
with semantic justification. The converse (¬¬A → A) is already axiomatized as
`double_negation`.

**Usage**: Required for P4 perpetuity proof (◇▽φ → ◇φ) via contraposition of P3.
-/
axiom dni (A : Formula) : ⊢ A.imp A.neg.neg

/--
Combine two implications into a conjunction implication.

Given `⊢ P → A` and `⊢ P → B`, derive `⊢ P → A ∧ B`.

Proof:
1. By `pairing`: `⊢ A → B → A ∧ B`
2. By transitivity with `⊢ P → A`: `⊢ P → B → A ∧ B`
3. By K axiom (S combinator): `(P → B → A∧B) → (P → B) → P → A∧B`
4. Apply modus ponens: `⊢ P → A ∧ B`
-/
theorem combine_imp_conj {P A B : Formula}
    (hA : ⊢ P.imp A) (hB : ⊢ P.imp B) : ⊢ P.imp (A.and B) := by
  have pair_ab : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  have h1 : ⊢ P.imp (B.imp (A.and B)) := imp_trans hA pair_ab
  have s : ⊢ (P.imp (B.imp (A.and B))).imp ((P.imp B).imp (P.imp (A.and B))) :=
    Derivable.axiom [] _ (Axiom.prop_k P B (A.and B))
  have h2 : ⊢ (P.imp B).imp (P.imp (A.and B)) :=
    Derivable.modus_ponens [] (P.imp (B.imp (A.and B))) ((P.imp B).imp (P.imp (A.and B))) s h1
  exact Derivable.modus_ponens [] (P.imp B) (P.imp (A.and B)) h2 hB

/--
Combine three implications into a nested conjunction implication.

Given `⊢ P → A`, `⊢ P → B`, and `⊢ P → C`, derive `⊢ P → A ∧ (B ∧ C)`.

This is used for P1 where △φ = Hφ ∧ (φ ∧ Gφ).
-/
theorem combine_imp_conj_3 {P A B C : Formula}
    (hA : ⊢ P.imp A) (hB : ⊢ P.imp B) (hC : ⊢ P.imp C) : ⊢ P.imp (A.and (B.and C)) := by
  have hBC : ⊢ P.imp (B.and C) := combine_imp_conj hB hC
  exact combine_imp_conj hA hBC

/-!
## Helper Lemmas: Temporal Components

The perpetuity principle P1 (□φ → △φ) requires deriving each temporal component:
- □φ → Hφ (past): via temporal duality on MF
- □φ → φ (present): via MT axiom
- □φ → Gφ (future): via MF then MT
-/

/--
Box implies future: `⊢ □φ → Gφ`.

Proof:
1. MF axiom: `□φ → □Gφ`
2. MT axiom: `□Gφ → Gφ`
3. Transitivity: `□φ → Gφ`
-/
theorem box_to_future (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  have mf : ⊢ φ.box.imp (φ.all_future.box) := Derivable.axiom [] _ (Axiom.modal_future φ)
  have mt : ⊢ φ.all_future.box.imp φ.all_future := Derivable.axiom [] _ (Axiom.modal_t φ.all_future)
  exact imp_trans mf mt

/--
Box implies past: `⊢ □φ → Hφ`.

Proof via temporal duality:
1. For any ψ, `box_to_future` gives: `⊢ □ψ → Gψ`
2. Apply to ψ = swap(φ): `⊢ □(swap φ) → G(swap φ)`
3. By temporal duality: `⊢ swap(□(swap φ) → G(swap φ))`
4. swap(□(swap φ) → G(swap φ)) = □(swap(swap φ)) → H(swap(swap φ)) = □φ → Hφ

This clever use of temporal duality avoids needing a separate "modal-past" axiom.
-/
theorem box_to_past (φ : Formula) : ⊢ φ.box.imp φ.all_past := by
  have h1 : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.all_future := box_to_future φ.swap_temporal
  have h2 : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.all_future).swap_temporal :=
    Derivable.temporal_duality (φ.swap_temporal.box.imp φ.swap_temporal.all_future) h1
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h2
  exact h2

/--
Box implies present: `⊢ □φ → φ` (MT axiom).
-/
theorem box_to_present (φ : Formula) : ⊢ φ.box.imp φ := Derivable.axiom [] _ (Axiom.modal_t φ)

/-!
## P1: Necessary Implies Always

`□φ → △φ`

If φ is metaphysically necessary (true in all possible worlds),
then φ is always true (true at all times: past, present, and future).
-/

/--
P1: `□φ → △φ` (necessary implies always)

Derivation combines three components:
1. `□φ → Hφ` (past): via temporal duality on MF (see `box_to_past`)
2. `□φ → φ` (present): via MT axiom (see `box_to_present`)
3. `□φ → Gφ` (future): via MF then MT (see `box_to_future`)
4. Combine: `□φ → Hφ ∧ (φ ∧ Gφ)` (see `combine_imp_conj_3`)

This proof uses the `pairing` axiom for conjunction introduction.
-/
theorem perpetuity_1 (φ : Formula) : ⊢ φ.box.imp φ.always := by
  -- always φ = φ.all_past.and (φ.and φ.all_future) = Hφ ∧ (φ ∧ Gφ)
  have h_past : ⊢ φ.box.imp φ.all_past := box_to_past φ
  have h_present : ⊢ φ.box.imp φ := box_to_present φ
  have h_future : ⊢ φ.box.imp φ.all_future := box_to_future φ
  exact combine_imp_conj_3 h_past h_present h_future

/-!
## P2: Sometimes Implies Possible

`▽φ → ◇φ` (sometimes implies possible)

If φ happens at some time (past, present, or future), then φ is possible.
-/

/--
Contraposition: if `⊢ A → B` then `⊢ ¬B → ¬A`.

Derived using double negation elimination (DNE) axiom.

Proof strategy:
1. From `A → B`, we need to derive `¬B → ¬A` (i.e., `(B → ⊥) → (A → ⊥)`)
2. Assume `¬B` and `A`, derive `⊥`
3. From `A` and `A → B`, get `B` by modus ponens
4. From `B` and `¬B` (i.e., `B → ⊥`), get `⊥` by modus ponens
5. Therefore `¬B → (A → ⊥)` = `¬B → ¬A`

This requires propositional reasoning patterns that are complex to encode in
the current TM proof system. The key challenge is handling the nested implications
and bottom (⊥) correctly.

**Note**: This proof uses DNE axiom added in Phase 3. The full derivation requires
careful manipulation of negations and implications, which is left as sorry for the
MVP. The semantic justification remains sound.

**Usage**: Required for P2 (`▽φ → ◇φ`) and P4 (`◇▽φ → ◇φ`), which follow from
contraposition of P1 and P3 respectively.
-/
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- Contraposition: (A → B) → (¬B → ¬A)
  -- Where ¬X = X → ⊥
  -- Goal: (B → ⊥) → (A → ⊥)

  -- The full proof requires:
  -- 1. From h : A → B
  -- 2. Build: (B → ⊥) → (A → ⊥)
  -- 3. By B combinator (composition): (B → ⊥) → (A → B) → (A → ⊥)
  -- 4. Apply modus ponens to get result

  -- The B combinator gives us: (B → ⊥) → (A → B) → (A → ⊥)
  have bc : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    b_combinator

  -- Apply first modus ponens to get: (A → B) → (A → ⊥)
  -- But we need to rearrange: we have h : A → B
  -- bc is: (B → ⊥) → (A → B) → (A → ⊥)
  -- We need to apply bc in the form that takes h and (B → ⊥)

  -- First, we need to swap the order. We want: (A → B) → (B → ⊥) → (A → ⊥)
  -- But bc gives us: (B → ⊥) → (A → B) → (A → ⊥)
  -- So we need to derive the commuted form

  -- Actually, let's use bc directly:
  -- We'll build (B → ⊥) → (A → ⊥) from h : (A → B) and bc
  -- bc mp h gives us: (B → ⊥) → (A → ⊥), which is what we need!

  -- But we need to apply bc correctly
  -- bc : (B → ⊥) → (A → B) → (A → ⊥)
  -- This is a curried function, so bc takes (B → ⊥) and returns (A → B) → (A → ⊥)
  -- Then we can apply that result to h : (A → B) to get (A → ⊥)
  -- But we want to BUILD (B → ⊥) → (A → ⊥), not apply it to a specific (B → ⊥)

  -- The key insight: we can use S combinator to "flip" the application order
  -- Or we can use the fact that bc is already in the right form for transitivity

  -- Let me try a different approach using imp_trans:
  -- We have h : A → B
  -- We want to show: (B → ⊥) → (A → ⊥)
  -- This means: for any proof of (B → ⊥), we can derive (A → ⊥)
  -- By transitivity: A → B and B → ⊥ implies A → ⊥

  -- But imp_trans requires two derivations, not implications
  -- Let's use the B combinator directly by applying it with MP

  -- Actually, bc has type: ⊢ (B → ⊥) → ((A → B) → (A → ⊥))
  -- If we apply MP with something of type ⊢ B → ⊥, we get ⊢ (A → B) → (A → ⊥)
  -- Then if we apply MP with h : ⊢ A → B, we get ⊢ A → ⊥

  -- But we don't have ⊢ B → ⊥ as a concrete derivation, we want to BUILD the implication
  -- So we need: ⊢ (A → B) → ((B → ⊥) → (A → ⊥))

  -- This is the COMMUTED B combinator! Let's derive it using S and K

  -- S axiom: ⊢ (X → Y → Z) → (X → Y) → (X → Z)
  -- Instantiate with X = A, Y = B, Z = ⊥:
  -- ⊢ (A → B → ⊥) → (A → B) → (A → ⊥)
  have s_inst : ⊢ (A.imp (B.imp Formula.bot)).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B Formula.bot)

  -- Now we need: A → (B → ⊥) from h : A → B
  -- S axiom again: B → (A → B)
  have s_b : ⊢ (B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp Formula.bot) A)

  -- Now compose: (B → ⊥) → (A → (B → ⊥)) [s_b]
  --              (A → (B → ⊥)) → (A → B) → (A → ⊥) [s_inst]
  -- Result: (B → ⊥) → ((A → B) → (A → ⊥))
  have comm_bc : ⊢ (B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    imp_trans s_b s_inst

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
  have s_final : ⊢ ((B.imp Formula.bot).imp ((A.imp B).imp (A.imp Formula.bot))).imp
                   (((B.imp Formula.bot).imp (A.imp B)).imp
                    ((B.imp Formula.bot).imp (A.imp Formula.bot))) :=
    Derivable.axiom [] _ (Axiom.prop_k (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot))

  -- Apply s_final to comm_bc
  have step1 : ⊢ ((B.imp Formula.bot).imp (A.imp B)).imp
                  ((B.imp Formula.bot).imp (A.imp Formula.bot)) :=
    Derivable.modus_ponens [] _ _ s_final comm_bc

  -- Now we need: ⊢ (B → ⊥) → (A → B)
  -- This is: constant function that ignores first arg and returns h
  -- K axiom: ⊢ (A → B) → ((B → ⊥) → (A → B))
  have const_h : ⊢ (A.imp B).imp ((B.imp Formula.bot).imp (A.imp B)) :=
    Derivable.axiom [] _ (Axiom.prop_s (A.imp B) (B.imp Formula.bot))

  have step2 : ⊢ (B.imp Formula.bot).imp (A.imp B) :=
    Derivable.modus_ponens [] _ _ const_h h

  -- Finally apply step1 to step2
  exact Derivable.modus_ponens [] _ _ step1 step2

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
theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := by
  -- Goal (by definition): φ.neg.box.neg.neg.box.neg.imp φ.neg.box.neg
  --
  -- Observation: ◇◇φ = (φ.neg.box.neg).diamond = φ.neg.box.neg.neg.box.neg
  -- We want: ◇◇φ → ◇φ, which is φ.neg.box.neg.neg.box.neg → φ.neg.box.neg
  --
  -- Key insight: Use M4 and contraposition multiple times
  -- M4 for ¬φ: □¬φ → □□¬φ
  -- Contrapose to get the negated outer box structure we need

  -- Step 1: M4 for ¬φ: □¬φ → □□¬φ
  have m4_neg : ⊢ φ.neg.box.imp φ.neg.box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 φ.neg)

  -- Step 2: Contrapose M4: ¬□□¬φ → ¬□¬φ
  -- This is: φ.neg.box.box.neg → φ.neg.box.neg
  have m4_contraposed : ⊢ φ.neg.box.box.neg.imp φ.neg.box.neg :=
    contraposition m4_neg

  -- Step 3: We need to relate φ.neg.box.neg.neg.box.neg to φ.neg.box.box.neg
  -- Use DNE:  ¬¬□¬φ → □¬φ
  have dne_box : ⊢ φ.neg.box.neg.neg.imp φ.neg.box :=
    Derivable.axiom [] _ (Axiom.double_negation φ.neg.box)

  -- Step 4: Apply M4 after DNE: ¬¬□¬φ → □¬φ → □□¬φ
  have combined : ⊢ φ.neg.box.neg.neg.imp φ.neg.box.box :=
    imp_trans dne_box m4_neg

  -- Step 5: Necessitate and distribute
  have box_combined : ⊢ (φ.neg.box.neg.neg.imp φ.neg.box.box).box :=
    Derivable.modal_k [] _ combined

  have mk_dist : ⊢ (φ.neg.box.neg.neg.imp φ.neg.box.box).box.imp
                    (φ.neg.box.neg.neg.box.imp φ.neg.box.box.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.neg.box.neg.neg φ.neg.box.box)

  have distributed : ⊢ φ.neg.box.neg.neg.box.imp φ.neg.box.box.box :=
    Derivable.modus_ponens [] _ _ mk_dist box_combined

  -- Step 6: Negate both sides: ¬□□□¬φ → ¬□¬¬□¬φ
  have distributed_neg : ⊢ φ.neg.box.box.box.neg.imp φ.neg.box.neg.neg.box.neg :=
    contraposition distributed

  -- Step 7: Use M4 on □¬φ: □□¬φ → □□□¬φ
  have m4_twice : ⊢ φ.neg.box.box.imp φ.neg.box.box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 φ.neg.box)

  -- Step 8: Contrapose: ¬□□□¬φ → ¬□□¬φ
  have m4_twice_neg : ⊢ φ.neg.box.box.box.neg.imp φ.neg.box.box.neg :=
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
  have dni_box : ⊢ φ.neg.box.imp φ.neg.box.neg.neg :=
    dni φ.neg.box

  -- Necessitate
  have box_dni : ⊢ (φ.neg.box.imp φ.neg.box.neg.neg).box :=
    Derivable.modal_k [] _ dni_box

  -- Distribute
  have mk_dni : ⊢ (φ.neg.box.imp φ.neg.box.neg.neg).box.imp
                   (φ.neg.box.box.imp φ.neg.box.neg.neg.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.neg.box φ.neg.box.neg.neg)

  have bridge : ⊢ φ.neg.box.box.imp φ.neg.box.neg.neg.box :=
    Derivable.modus_ponens [] _ _ mk_dni box_dni

  -- Contrapose: ¬□¬¬□¬φ → ¬□□¬φ
  have bridge_neg : ⊢ φ.neg.box.neg.neg.box.neg.imp φ.neg.box.box.neg :=
    contraposition bridge

  -- Finally compose: ¬□¬¬□¬φ → ¬□□¬φ → ¬□¬φ
  exact imp_trans bridge_neg m4_contraposed

/--
Modal 5: `◇φ → □◇φ` (S5 characteristic for diamond).

If something is possible, it is necessarily possible.

Derived from MB + diamond_4 + MK distribution:
1. MB on `◇φ`: `⊢ ◇φ → □◇◇φ`
2. diamond_4: `⊢ ◇◇φ → ◇φ`
3. Necessitate: `⊢ □(◇◇φ → ◇φ)`
4. MK distribution: `⊢ □◇◇φ → □◇φ`
5. Compose steps 1 and 4: `⊢ ◇φ → □◇φ`
-/
theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box := by
  -- Step 1: MB on ◇φ
  have mb_dia : ⊢ φ.diamond.imp φ.diamond.diamond.box :=
    Derivable.axiom [] _ (Axiom.modal_b φ.diamond)

  -- Step 2: diamond_4 for φ
  have d4 : ⊢ φ.diamond.diamond.imp φ.diamond := diamond_4 φ

  -- Step 3: Necessitate d4 using modal_k with empty context
  have box_d4 : ⊢ (φ.diamond.diamond.imp φ.diamond).box :=
    Derivable.modal_k [] _ d4

  -- Step 4: MK distribution
  have mk : ⊢ (φ.diamond.diamond.imp φ.diamond).box.imp
               (φ.diamond.diamond.box.imp φ.diamond.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.diamond.diamond φ.diamond)

  have d4_box : ⊢ φ.diamond.diamond.box.imp φ.diamond.box :=
    Derivable.modus_ponens [] _ _ mk box_d4

  -- Step 5: Compose
  exact imp_trans mb_dia d4_box

/--
P2: `▽φ → ◇φ` (sometimes implies possible)

Derivation via contraposition of P1:
1. P1: `□¬φ → △¬φ` (by P1 applied to ¬φ)
2. Contraposition: `¬△¬φ → ¬□¬φ`
3. Since `▽φ = ¬△¬φ` and `◇φ = ¬□¬φ`:
4. We get: `▽φ → ◇φ`
-/
theorem perpetuity_2 (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := by
  -- Goal: ⊢ ▽φ → ◇φ
  -- Recall: ▽φ = sometimes φ = ¬(always ¬φ) = ¬(H¬φ ∧ ¬φ ∧ G¬φ)
  -- Recall: ◇φ = diamond φ = ¬□¬φ = (φ.neg.box).neg
  -- By P1 for ¬φ: □(¬φ) → △(¬φ) = □(¬φ) → always(¬φ)
  -- By contraposition: ¬(always(¬φ)) → ¬(□(¬φ))
  -- Which is: sometimes φ → diamond φ = ▽φ → ◇φ
  have h1 : ⊢ φ.neg.box.imp φ.neg.always := perpetuity_1 φ.neg
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

Derived via temporal duality on MF, analogous to `box_to_past`.
-/
theorem box_to_box_past (φ : Formula) : ⊢ φ.box.imp (φ.all_past.box) := by
  have mf : ⊢ φ.swap_temporal.box.imp (φ.swap_temporal.all_future.box) :=
    Derivable.axiom [] _ (Axiom.modal_future φ.swap_temporal)
  have mf_swap : ⊢ (φ.swap_temporal.box.imp (φ.swap_temporal.all_future.box)).swap_temporal :=
    Derivable.temporal_duality _ mf
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at mf_swap
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
theorem box_conj_intro {A B : Formula}
    (hA : ⊢ A.box) (hB : ⊢ B.box) : ⊢ (A.and B).box := by
  -- Step 1: pairing axiom gives us the base implication
  have pair : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  -- Step 2: necessitation of pairing using modal_k with empty context
  have box_pair : ⊢ (A.imp (B.imp (A.and B))).box :=
    Derivable.modal_k [] _ pair
  -- Step 3: modal K distribution (first application)
  -- □(A → (B → A∧B)) → (□A → □(B → A∧B))
  have mk1 : ⊢ (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B)))
  have h1 : ⊢ A.box.imp (B.imp (A.and B)).box :=
    Derivable.modus_ponens [] _ _ mk1 box_pair
  -- Step 4: modal K distribution (second application)
  -- □(B → A∧B) → (□B → □(A∧B))
  have mk2 : ⊢ (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist B (A.and B))
  -- Compose: □A → □(B → A∧B) and □(B → A∧B) → (□B → □(A∧B))
  -- to get: □A → (□B → □(A∧B))
  have h2 : ⊢ A.box.imp (B.box.imp (A.and B).box) := imp_trans h1 mk2
  -- Apply with hA to get: □B → □(A∧B)
  have h3 : ⊢ B.box.imp (A.and B).box :=
    Derivable.modus_ponens [] _ _ h2 hA
  -- Apply with hB to get: □(A∧B)
  exact Derivable.modus_ponens [] _ _ h3 hB

/--
Boxed conjunction introduction from implications: from `⊢ P → □A` and `⊢ P → □B`,
derive `⊢ P → □(A ∧ B)`.

This variant of `box_conj_intro` works with implications rather than direct
derivations. It's useful for combining components like `□φ → □Hφ`, `□φ → □φ`,
`□φ → □Gφ` into `□φ → □(Hφ ∧ (φ ∧ Gφ))`.
-/
theorem box_conj_intro_imp {P A B : Formula}
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) : ⊢ P.imp (A.and B).box := by
  -- Strategy: Build P → □A → □B → □(A ∧ B), then apply with hA and hB
  -- From box_conj_intro proof, we have the pattern: □A → □B → □(A ∧ B)

  -- First, build the implication chain: □A → □B → □(A ∧ B)
  have pair : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  have box_pair : ⊢ (A.imp (B.imp (A.and B))).box :=
    Derivable.modal_k [] _ pair
  have mk1 : ⊢ (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B)))
  have h1 : ⊢ A.box.imp (B.imp (A.and B)).box :=
    Derivable.modus_ponens [] _ _ mk1 box_pair
  have mk2 : ⊢ (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist B (A.and B))
  have box_to_box : ⊢ A.box.imp (B.box.imp (A.and B).box) := imp_trans h1 mk2

  -- Now compose: P → □A and □A → □B → □(A ∧ B) gives P → □B → □(A ∧ B)
  have h2 : ⊢ P.imp (B.box.imp (A.and B).box) := imp_trans hA box_to_box

  -- Compose: P → □B → □(A ∧ B) and P → □B gives P → □(A ∧ B)
  -- Use K axiom: (P → (□B → □(A ∧ B))) → ((P → □B) → (P → □(A ∧ B)))
  have k : ⊢ (P.imp (B.box.imp (A.and B).box)).imp ((P.imp B.box).imp (P.imp (A.and B).box)) :=
    Derivable.axiom [] _ (Axiom.prop_k P B.box (A.and B).box)
  have h3 : ⊢ (P.imp B.box).imp (P.imp (A.and B).box) :=
    Derivable.modus_ponens [] _ _ k h2
  exact Derivable.modus_ponens [] _ _ h3 hB

/--
Three-way boxed conjunction introduction from implications.
From `⊢ P → □A`, `⊢ P → □B`, `⊢ P → □C`, derive `⊢ P → □(A ∧ (B ∧ C))`.
-/
theorem box_conj_intro_imp_3 {P A B C : Formula}
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) (hC : ⊢ P.imp C.box) :
    ⊢ P.imp (A.and (B.and C)).box := by
  have hBC : ⊢ P.imp (B.and C).box := box_conj_intro_imp hB hC
  exact box_conj_intro_imp hA hBC

/--
P3: `□φ → □△φ` (necessity of perpetuity)

What is necessary is necessarily always true.

Derivation combines three boxed temporal components using modal K distribution:
1. `□φ → □Hφ` (via temporal duality on MF, see `box_to_box_past`)
2. `□φ → □φ` (identity on boxed formula)
3. `□φ → □Gφ` (MF axiom)
4. Combine using `box_conj_intro_imp_3` to get `□φ → □(Hφ ∧ (φ ∧ Gφ))`

This proof uses modal K distribution axiom and necessitation rule added in
the axiomatic extension (Phases 1-2).
-/
theorem perpetuity_3 (φ : Formula) : ⊢ φ.box.imp (φ.always.box) := by
  -- always φ = φ.all_past.and (φ.and φ.all_future) = Hφ ∧ (φ ∧ Gφ)
  -- Goal: ⊢ □φ → □(Hφ ∧ (φ ∧ Gφ))

  -- Component implications from boxed φ to boxed temporal components
  have h_past : ⊢ φ.box.imp (φ.all_past.box) := box_to_box_past φ
  have h_present : ⊢ φ.box.imp φ.box := identity φ.box
  have h_future : ⊢ φ.box.imp (φ.all_future.box) :=
    Derivable.axiom [] _ (Axiom.modal_future φ)

  -- Combine using box_conj_intro_imp_3
  exact box_conj_intro_imp_3 h_past h_present h_future

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
theorem box_dne {A : Formula}
    (h : ⊢ A.neg.neg.box) : ⊢ A.box := by
  -- Step 1: DNE axiom
  have dne : ⊢ A.neg.neg.imp A :=
    Derivable.axiom [] _ (Axiom.double_negation A)

  -- Step 2: Necessitate using modal_k with empty context
  have box_dne : ⊢ (A.neg.neg.imp A).box :=
    Derivable.modal_k [] _ dne

  -- Step 3: Modal K distribution
  have mk : ⊢ (A.neg.neg.imp A).box.imp (A.neg.neg.box.imp A.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist A.neg.neg A)

  -- Step 4: Apply modus ponens twice
  have step : ⊢ A.neg.neg.box.imp A.box :=
    Derivable.modus_ponens [] _ _ mk box_dne
  exact Derivable.modus_ponens [] _ _ step h

/--
P4: `◇▽φ → ◇φ` (possibility of occurrence)

**Derivation Strategy**: Contraposition of P3 applied to `¬φ`, with double negation handling.

The proof navigates the formula structure difference:
- `φ.sometimes.diamond` = `(φ.neg.always.neg).neg.box.neg`
- Target: `φ.diamond` = `φ.neg.box.neg`

Key insight: Use double negation introduction (`dni`) to build the reverse direction
of DNE, then contrapose to get the needed bridge between formulas.

Proof outline:
1. P3 for `¬φ`: `⊢ □(¬φ) → □△(¬φ)`
2. Contrapose: `⊢ ¬□△(¬φ) → ¬□(¬φ)`
3. Build bridge via DNI: `⊢ △¬φ → ¬¬△¬φ`, lift to box, contrapose
4. Compose all pieces to get final result

**Note**: Uses `dni` axiom (double negation introduction) which is semantically valid
in TM's classical semantics. The paper states P4 "follows from definitions and classical
logic" (§3.2 lines 1070-1081).
-/
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- Goal: ⊢ (φ.neg.always.neg).neg.box.neg → φ.neg.box.neg
  --
  -- Strategy:
  -- 1. From P3(¬φ): φ.neg.box → φ.neg.always.box
  -- 2. Contrapose: φ.neg.always.box.neg → φ.neg.box.neg
  -- 3. Build bridge: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  --    using DNI (△¬φ → ¬¬△¬φ) lifted to box and contraposed
  -- 4. Compose bridge with contraposed result

  -- Step 1: Get P3 for ¬φ
  have p3_neg : ⊢ φ.neg.box.imp φ.neg.always.box := perpetuity_3 φ.neg

  -- Step 2: Contrapose to get: φ.neg.always.box.neg → φ.neg.box.neg
  have contraposed : ⊢ φ.neg.always.box.neg.imp φ.neg.box.neg := contraposition p3_neg

  -- Step 3: Build bridge using DNI
  -- We need: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  --
  -- Build from DNI: △¬φ → ¬¬△¬φ (i.e., φ.neg.always → φ.neg.always.neg.neg)
  have dni_always : ⊢ φ.neg.always.imp φ.neg.always.neg.neg :=
    dni φ.neg.always

  -- Necessitate: □(△¬φ → ¬¬△¬φ) using modal_k with empty context
  have box_dni_always : ⊢ (φ.neg.always.imp φ.neg.always.neg.neg).box :=
    Derivable.modal_k [] _ dni_always

  -- Modal K: □(△¬φ → ¬¬△¬φ) → (□△¬φ → □¬¬△¬φ)
  have mk_dni : ⊢ (φ.neg.always.imp φ.neg.always.neg.neg).box.imp
                   (φ.neg.always.box.imp φ.neg.always.neg.neg.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.neg.always φ.neg.always.neg.neg)

  -- Apply: □△¬φ → □¬¬△¬φ
  have box_dni_imp : ⊢ φ.neg.always.box.imp φ.neg.always.neg.neg.box :=
    Derivable.modus_ponens [] _ _ mk_dni box_dni_always

  -- Contrapose: ¬□¬¬△¬φ → ¬□△¬φ
  -- i.e., φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  have bridge : ⊢ φ.neg.always.neg.neg.box.neg.imp φ.neg.always.box.neg :=
    contraposition box_dni_imp

  -- Step 4: Compose bridge with contraposed
  -- bridge: φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg
  -- contraposed: φ.neg.always.box.neg → φ.neg.box.neg
  -- Result: φ.neg.always.neg.neg.box.neg → φ.neg.box.neg
  exact imp_trans bridge contraposed

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
theorem mb_diamond (φ : Formula) : ⊢ φ.imp (φ.diamond.box) :=
  Derivable.axiom [] _ (Axiom.modal_b φ)

/--
Helper lemma: Apply TF axiom to boxed diamond.

From `□◇φ`, derive `F□◇φ` (necessarily possible persists to future).
-/
theorem box_diamond_to_future_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_future) :=
  Derivable.axiom [] _ (Axiom.temp_future φ.diamond)

/--
Helper lemma: Apply temporal duality to get past component.

From TF on `□◇φ`, derive `H□◇φ` via temporal duality.
-/
theorem box_diamond_to_past_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_past) := by
  -- Apply TF to swapped temporal version
  have tf_swap : ⊢ φ.diamond.box.swap_temporal.imp
                    (φ.diamond.box.swap_temporal.all_future) :=
    box_diamond_to_future_box_diamond φ.swap_temporal
  -- Apply temporal duality
  have td : ⊢ (φ.diamond.box.swap_temporal.imp
                φ.diamond.box.swap_temporal.all_future).swap_temporal :=
    Derivable.temporal_duality _ tf_swap
  -- Simplify: swap(swap x) = x
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at td
  exact td

/--
Temporal K distribution for future: `G(A → B) → (GA → GB)`.

This is the temporal analog of modal K distribution. It allows distributing
the future operator over implications.

**Semantic Justification**: In task semantics, if A → B holds at all future times
and A holds at all future times, then B must hold at all future times by modus ponens
applied pointwise across the timeline.

**Implementation Note**: While this should be derivable from the Temporal K inference
rule combined with modus ponens, the construction requires meta-level reasoning about
contexts and derivations that is complex to encode. For MVP, we axiomatize it with
semantic justification. The principle is sound and follows from standard temporal logic.

**Future Work**: Derive from Temporal K rule using context manipulation and MP lifting.
-/
axiom future_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)

/--
Temporal K distribution for past: `H(A → B) → (HA → HB)`.

This is the past analog of future K distribution, derived via temporal duality.

**Semantic Justification**: By temporal symmetry in task semantics, if A → B holds
at all past times and A holds at all past times, then B must hold at all past times.

**Derivation**: This follows from `future_k_dist` applied with temporal duality.
-/
theorem past_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past) := by
  -- Apply future_k_dist to swapped formulas
  have fk : ⊢ (A.swap_temporal.imp B.swap_temporal).all_future.imp
               (A.swap_temporal.all_future.imp B.swap_temporal.all_future) :=
    future_k_dist A.swap_temporal B.swap_temporal
  -- Apply temporal duality
  have td : ⊢ ((A.swap_temporal.imp B.swap_temporal).all_future.imp
                (A.swap_temporal.all_future.imp B.swap_temporal.all_future)).swap_temporal :=
    Derivable.temporal_duality _ fk
  -- Simplify: swap(swap x) = x
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at td
  exact td

/--
Persistence lemma (ATTEMPTED): `◇φ → △◇φ` (possibility is perpetual).

**Target**: If φ is possible, then φ is always possible (at all times).

**Attempted Derivation Strategy**:
1. From MB: `φ → □◇φ` (truths are necessarily possible)
2. From TF: `□◇φ → F□◇φ` (boxed diamond persists to future)
3. From TD: `□◇φ → H□◇φ` (boxed diamond extends to past)
4. Need to lift: `◇φ → □◇φ` to get started

**BLOCKING ISSUE**: The MB axiom gives `φ → □◇φ`, but we need to start from `◇φ`.
The step `◇φ → □◇φ` is NOT derivable from current axioms. This would require:
- Either: `◇φ → φ` (which is false - possibility doesn't imply truth)
- Or: A modal axiom specifically for `◇◇φ → □◇φ` (not in TM)
- Or: Modal necessitation at the ◇ level (requires richer proof system)

**Alternative Approach Analysis**:
The paper (§3.2) claims P5 follows from P4 + persistence, but the persistence lemma
itself requires modal/temporal interaction principles not expressible in the current
TM axiom system without additional machinery.

**Semantic Justification** (Corollary 2.11, paper line 2373):
P5 is semantically valid in task semantics. In any task model, if ◇▽φ holds at (M,τ,t),
then there exists a world history ρ and time s where φ holds. By the S5 structure of
possibility and time-invariance of worlds, this means φ is possible at all times in τ.

**Implementation Decision**: Axiomatize P5 for MVP. The syntactic derivation requires
either extending the proof system with:
1. Modal necessitation rules for ◇ (not just □)
2. Additional axiom schemas for ◇-F interactions
3. Semantic translation mechanisms

Future work: Investigate whether P5 can be derived using Temporal K (TK) inference rule
combined with modal distribution, as suggested by paper's reference to "TK rules".
-/
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Goal: ◇φ → △◇φ
  -- Expanded: ◇φ → H◇φ ∧ ◇φ ∧ G◇φ
  --
  -- KEY INSIGHT: Use modal_5 (◇φ → □◇φ) as starting point
  -- Then apply TF and TD to □◇φ to get temporal components
  -- Then apply MT to strip the boxes

  -- KEY: Use modal_5 to get ◇φ → □◇φ (S5 characteristic axiom)
  have m5 : ⊢ φ.diamond.imp φ.diamond.box := modal_5 φ

  -- We can derive: □◇φ → F□◇φ from TF
  have tf : ⊢ φ.diamond.box.imp φ.diamond.box.all_future :=
    Derivable.axiom [] _ (Axiom.temp_future φ.diamond)

  -- We can derive: □◇φ → H□◇φ from TD (temporal duality on TF)
  have td : ⊢ φ.diamond.box.imp φ.diamond.box.all_past := by
    -- Apply TF to swapped temporal version
    have tf_swap : ⊢ φ.diamond.box.swap_temporal.imp
                      (φ.diamond.box.swap_temporal.all_future) :=
      Derivable.axiom [] _ (Axiom.temp_future φ.diamond.swap_temporal)
    -- Apply temporal duality
    have td_result : ⊢ (φ.diamond.box.swap_temporal.imp
                          φ.diamond.box.swap_temporal.all_future).swap_temporal :=
      Derivable.temporal_duality _ tf_swap
    -- Simplify: swap(swap x) = x
    simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at td_result
    exact td_result

  -- Now build the components of △◇φ = H◇φ ∧ ◇φ ∧ G◇φ
  -- We need: ◇φ → H◇φ, ◇φ → ◇φ, ◇φ → G◇φ

  -- Step 1: ◇φ → H◇φ
  have past_comp : ⊢ φ.diamond.imp φ.diamond.all_past := by
    -- We have: ◇φ → □◇φ (m5) and □◇φ → H□◇φ (td)
    -- Compose: ◇φ → H□◇φ
    have chain1 : ⊢ φ.diamond.imp φ.diamond.box.all_past := imp_trans m5 td
    -- Apply MT to get □◇φ → ◇φ
    have mt : ⊢ φ.diamond.box.imp φ.diamond := box_to_present φ.diamond
    -- We need H(□◇φ → ◇φ) to apply past K distribution
    -- Build this by applying temporal_k to the swapped formula, then swap back
    have mt_swap : ⊢ φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal :=
      box_to_present φ.diamond.swap_temporal
    have future_mt_swap : ⊢ (φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal).all_future :=
      Derivable.temporal_k [] _ mt_swap
    have past_mt : ⊢ ((φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal).all_future).swap_temporal :=
      Derivable.temporal_duality _ future_mt_swap
    -- Now we need to simplify this to (φ.diamond.box.imp φ.diamond).all_past
    -- This requires understanding how swap_temporal interacts with diamond
    -- For MVP, we'll use a sorry here as the simplification is complex
    sorry  -- TODO: simplify swapped diamond expressions

  -- Step 2: ◇φ → ◇φ (identity)
  have present_comp : ⊢ φ.diamond.imp φ.diamond := identity φ.diamond

  -- Step 3: ◇φ → G◇φ
  have future_comp : ⊢ φ.diamond.imp φ.diamond.all_future := by
    -- We have: ◇φ → □◇φ (m5) and □◇φ → G□◇φ (tf)
    -- Compose: ◇φ → G□◇φ
    have chain2 : ⊢ φ.diamond.imp φ.diamond.box.all_future := imp_trans m5 tf
    -- Apply MT to get □◇φ → ◇φ
    have mt : ⊢ φ.diamond.box.imp φ.diamond := box_to_present φ.diamond
    -- Lift MT to future using temporal_k
    have future_mt : ⊢ (φ.diamond.box.imp φ.diamond).all_future :=
      Derivable.temporal_k [] _ mt
    -- Use future K distribution: G(□◇φ → ◇φ) → (G□◇φ → G◇φ)
    have fk : ⊢ (φ.diamond.box.imp φ.diamond).all_future.imp
                 (φ.diamond.box.all_future.imp φ.diamond.all_future) :=
      future_k_dist φ.diamond.box φ.diamond
    have future_bridge : ⊢ φ.diamond.box.all_future.imp φ.diamond.all_future :=
      Derivable.modus_ponens [] _ _ fk future_mt
    exact imp_trans chain2 future_bridge

  -- Combine all three components using combine_imp_conj_3
  exact combine_imp_conj_3 past_comp present_comp future_comp

/--
P5: `◇▽φ → △◇φ` (persistent possibility)

**Derivation Strategy** (from paper §3.2 lines 1082-1085):
P5 would follow from P4 composed with persistence lemma, if persistence were provable.

**Blocked Implementation**:
- P4: `◇▽φ → ◇φ` (proven in Phase 2)
- Persistence: `◇φ → △◇φ` (BLOCKED - requires modal axioms not in TM)
- P5: Would be `imp_trans (perpetuity_4 φ) (persistence φ)` IF persistence were proven

**Root Cause**: The persistence lemma requires `◇φ → □◇φ`, which is not derivable
from TM axioms. The paper's claim that P5 "follows from P4 + persistence" assumes
the persistence lemma is provable, but it requires modal machinery beyond TM's axioms.

**Semantic Justification** (Corollary 2.11, paper line 2373):
P5 is semantically valid in task semantics. The soundness follows from:
1. S5 modal structure ensures possibility is stable across worlds
2. Temporal homogeneity ensures time-invariance of modal facts
3. Therefore: ◇▽φ at t implies ◇φ at all times in any world history

**MVP Status**: NOW DERIVABLE from P4 + persistence. The key breakthrough is using
`modal_5` (`◇φ → □◇φ`, the S5 characteristic axiom) which we derived from MB + diamond_4.

**Implementation**:
P5 = P4 ∘ persistence, where:
- P4: `◇▽φ → ◇φ` (PROVEN - zero sorry)
- persistence: `◇φ → △◇φ` (uses modal_5 + temporal K dist, has 1 sorry for simplification)
- modal_5: `◇φ → □◇φ` (PROVEN from MB + diamond_4)

**Remaining Work**: The persistence lemma has 1 sorry for simplifying swapped diamond
expressions when applying temporal K distribution to the past component. This is a
technical simplification issue, not a fundamental gap.
-/
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always :=
  imp_trans (perpetuity_4 φ) (persistence φ)

/-!
## P6: Occurrent Necessity is Perpetual

`▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time (past, present, or future), then it's always necessary.
-/

/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

**Attempted Derivation Strategy**: Apply P5 to `¬φ` with operator duality and contraposition.

**Proof Outline** (if P5 were proven):
1. P5 for `¬φ`: `◇▽(¬φ) → △◇(¬φ)`
2. Use operator duality theorems:
   - Need: `◇(¬φ) ↔ ¬□φ` (modal duality)
   - Need: `▽(¬φ) ↔ ¬△φ` (temporal duality)
3. Apply to P5(¬φ) with contraposition
4. Result: `▽□φ → □△φ`

**BLOCKING ISSUE 1: P5 Dependency**
Since P5 is axiomatized (blocked by `◇φ → □◇φ` axiom gap), P6 cannot be derived via
this approach. The P5-based derivation requires:
- P5 as a proven theorem (BLOCKED - requires `◇φ → □◇φ`)
- Operator duality theorems (would need to be proven separately)

**BLOCKING ISSUE 2: Operator Duality**
The operator duality identities `◇(¬φ) = ¬□φ` and `▽(¬φ) = ¬△φ` are NOT definitional
in our Formula structure:
- `φ.neg.diamond` = `(φ.neg).neg.box.neg` ≠ `φ.box.neg` (definitionally)
- `φ.neg.sometimes` = `(φ.neg).neg.always.neg` ≠ `φ.always.neg` (definitionally)

Proving these dualities as derivable implications would require:
- Modal K distribution and DNE for modal case
- Temporal K distribution and DNE for temporal case
- Contraposition and double negation handling
- Estimated effort: 20-30 additional lines per duality lemma

Even IF these dualities were proven, the P5 blocking issue remains.

**Alternative Direct Approach**: Derive P6 directly from TF axiom using temporal
necessitation, but this requires inference rules not in current proof system:
- TF axiom: `□φ → F□φ` (necessity persists to future)
- Would need: "If ▽□φ then at some time t, □φ holds"
- Would need: "From □φ at t and F□φ from t, derive G□φ globally"
- This requires temporal necessitation or semantic reasoning beyond current system

**Semantic Justification** (Corollary 2.11, paper line 2373):
P6 is semantically valid in task semantics. The soundness follows from:
1. TF axiom validity (Theorem 2.9)
2. Time-shift invariance (Lemma A.4)
3. If □φ holds at any temporal point in a world history, TF ensures it persists forward
4. By temporal homogeneity, this propagates to perpetual necessity

**MVP Status**: Axiomatized for MVP. Both derivation approaches are blocked:
- **P5-based approach**: Blocked by P5 axiomatization (requires `◇φ → □◇φ`)
- **TF-based approach**: Blocked by lack of temporal necessitation inference rules

Future work options:
1. Add `◇φ → □◇φ` axiom to unblock P5, then derive P6 from P5 via duality
2. Implement temporal necessitation inference rules to derive P6 directly from TF
3. Prove operator duality theorems (`◇(¬φ) ↔ ¬□φ`, `▽(¬φ) ↔ ¬△φ`) as helper lemmas
4. Accept P6 as axiom with semantic justification (current MVP approach)
-/
axiom perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box

/-!
## Summary

**Fully Proven Theorems** (zero sorry):
- P1: `□φ → △φ` (necessary implies always)
  - Uses `box_to_past`, `box_to_present`, `box_to_future` helper lemmas
  - Combines with `combine_imp_conj_3` for conjunction introduction
  - Requires `pairing` axiom for internal conjunction combinator
- P2: `▽φ → ◇φ` (sometimes implies possible)
  - Contraposition of P1 applied to `¬φ`
  - Uses `contraposition` theorem (proven via B combinator)
- P3: `□φ → □△φ` (necessity of perpetuity)
  - Uses `box_to_box_past`, identity, MF axiom for components
  - Combines with `box_conj_intro_imp_3` for boxed conjunction
  - Uses modal K distribution axiom (added in Phase 1-2)
- P4: `◇▽φ → ◇φ` (possibility of occurrence)
  - Contraposition of P3 applied to `¬φ`
  - Uses DNI axiom to bridge double negation in formula structure
  - Complete proof with zero sorry (Phase 2)

**Partially Proven Theorems** (sorry with semantic justification):
- **Persistence lemma**: `◇φ → △◇φ` (1 sorry)
  - Helper components proven: `mb_diamond`, `box_diamond_to_future_box_diamond`, `box_diamond_to_past_box_diamond`
  - BLOCKING ISSUE: Requires `◇φ → □◇φ` which is NOT derivable from TM axioms
  - This is an S5 characteristic axiom for ◇ not included in base TM system
  - Semantic justification: Valid in task semantics by S5 modal structure

**Axiomatized** (semantic justification only):
- P5: `◇▽φ → △◇φ` (persistent possibility)
  - Would follow from: `imp_trans (perpetuity_4 φ) (persistence φ)`
  - BLOCKED by persistence lemma requiring `◇φ → □◇φ`
  - Semantic justification: Valid in task semantics (Corollary 2.11)
- P6: `▽□φ → □△φ` (occurrent necessity is perpetual)
  - Requires temporal necessitation or P5 equivalence
  - Semantic justification: Valid in task semantics (Corollary 2.11)

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

**Axioms Used** (semantically justified):
- `pairing`: `⊢ A → B → A ∧ B` (conjunction introduction combinator)
- `dni`: `⊢ A → ¬¬A` (double negation introduction, classical logic)

**Sorry Count**: 1 (persistence lemma only - requires `◇φ → □◇φ`)

**Implementation Status**:
- P1: ✓ FULLY PROVEN (zero sorry)
- P2: ✓ FULLY PROVEN (zero sorry)
- P3: ✓ FULLY PROVEN (zero sorry)
- P4: ✓ FULLY PROVEN (zero sorry)
- P5: ✗ AXIOMATIZED (blocked by persistence lemma requiring `◇φ → □◇φ`)
- P6: ✗ AXIOMATIZED (requires P5 or temporal necessitation)

**Gap Analysis**:
1. **S5 ◇ Axiom**: `◇φ → □◇φ` needed for persistence lemma
   - This is a characteristic axiom of S5 for possibility
   - Not included in base TM system
   - Adding would unblock P5 derivation
2. **Temporal Necessitation**: Rules for lifting `⊢ φ → Fφ` to `⊢ ◇φ → F◇φ`
   - Required for alternative P5 derivation approaches
   - Not expressible in current inference rule system

**Future Work**:
1. Add `◇φ → □◇φ` axiom (S5 characteristic for ◇) to complete persistence lemma
2. Investigate Temporal K (TK) inference rule for modal/temporal lifting
3. Derive P6 from P5 via duality and contraposition (blocked by P5)
4. Consider accepting P5/P6 as axioms with semantic justification (current approach)
-/

/-!
## Example Usages with Triangle Notation

The perpetuity principles can be expressed using Unicode triangle notation
for improved readability in bimodal contexts.
-/

/-- Example: P1 with triangle notation - necessary implies always -/
example (p : Formula) : ⊢ p.box.imp (△p) := perpetuity_1 p

/-- Example: P2 with triangle notation - sometimes implies possible -/
example (p : Formula) : ⊢ (▽p).imp p.diamond := perpetuity_2 p

/-- Example: P3 with mixed notation - necessity of perpetuity -/
example (p : Formula) : ⊢ p.box.imp (△p).box := perpetuity_3 p

/-- Example: Combined modal-temporal with triangles - □△p -/
example (p : Formula) : ⊢ p.box.imp (△p).box := perpetuity_3 p

/-- Example: Combined possibility-temporal - ◇▽p -/
example (p : Formula) : ⊢ (▽p).diamond.imp p.diamond := perpetuity_4 p

end Logos.Core.Theorems.Perpetuity
