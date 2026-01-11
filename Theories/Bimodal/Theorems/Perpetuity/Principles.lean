import Bimodal.Theorems.Perpetuity.Helpers
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Perpetuity Principles (P1-P5)

This module contains the proofs of perpetuity principles P1 through P5, which
establish fundamental connections between modal necessity (□) and temporal operators
(always △, sometimes ▽).

## Main Theorems

- `perpetuity_1`: `□φ → △φ` (necessary implies always)
- `perpetuity_2`: `▽φ → ◇φ` (sometimes implies possible)
- `perpetuity_3`: `□φ → □△φ` (necessity of perpetuity)
- `perpetuity_4`: `◇▽φ → ◇φ` (possibility of occurrence)
- `perpetuity_5`: `◇▽φ → △◇φ` (persistent possibility)

## Supporting Lemmas

- `contraposition`: Contraposition for implications
- `diamond_4`: `◇◇φ → ◇φ` (S4 characteristic for diamond)
- `modal_5`: `◇φ → □◇φ` (S5 characteristic)
- `persistence`: `◇φ → △◇φ` (persistence lemma for P5)

## References

* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Helpers.lean](Helpers.lean) - Helper lemmas
* [ARCHITECTURE.md](../../../../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Bimodal.Theorems.Perpetuity

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

/--
Double Negation Elimination (local helper): `⊢ ¬¬φ → φ`.

Convenience wrapper for the derived DNE theorem from Propositional.lean.

This theorem is now derived from EFQ + Peirce axioms (see Propositional.double_negation).
-/
private def double_negation (φ : Formula) : ⊢ φ.neg.neg.imp φ :=
  Propositional.double_negation φ

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
def perpetuity_1 (φ : Formula) : ⊢ φ.box.imp φ.always := by
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
def contraposition {A B : Formula}
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
    DerivationTree.axiom [] _ (Axiom.prop_k A B Formula.bot)

  -- Now we need: A → (B → ⊥) from h : A → B
  -- S axiom again: B → (A → B)
  have s_b : ⊢ (B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (B.imp Formula.bot) A)

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
    DerivationTree.axiom [] _ (Axiom.prop_k (B.imp Formula.bot) (A.imp B) (A.imp Formula.bot))

  -- Apply s_final to comm_bc
  have step1 : ⊢ ((B.imp Formula.bot).imp (A.imp B)).imp
                  ((B.imp Formula.bot).imp (A.imp Formula.bot)) :=
    DerivationTree.modus_ponens [] _ _ s_final comm_bc

  -- Now we need: ⊢ (B → ⊥) → (A → B)
  -- This is: constant function that ignores first arg and returns h
  -- K axiom: ⊢ (A → B) → ((B → ⊥) → (A → B))
  have const_h : ⊢ (A.imp B).imp ((B.imp Formula.bot).imp (A.imp B)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (A.imp B) (B.imp Formula.bot))

  have step2 : ⊢ (B.imp Formula.bot).imp (A.imp B) :=
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
def diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := by
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
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.neg)

  -- Step 2: Contrapose M4: ¬□□¬φ → ¬□¬φ
  -- This is: φ.neg.box.box.neg → φ.neg.box.neg
  have m4_contraposed : ⊢ φ.neg.box.box.neg.imp φ.neg.box.neg :=
    contraposition m4_neg

  -- Step 3: We need to relate φ.neg.box.neg.neg.box.neg to φ.neg.box.box.neg
  -- Use DNE:  ¬¬□¬φ → □¬φ
  have dne_box : ⊢ φ.neg.box.neg.neg.imp φ.neg.box :=
    double_negation φ.neg.box

  -- Step 4: Apply M4 after DNE: ¬¬□¬φ → □¬φ → □□¬φ
  have combined : ⊢ φ.neg.box.neg.neg.imp φ.neg.box.box :=
    imp_trans dne_box m4_neg

  -- Step 5: Necessitate and distribute
  have box_combined : ⊢ (φ.neg.box.neg.neg.imp φ.neg.box.box).box :=
    DerivationTree.necessitation _ combined

  have mk_dist : ⊢ (φ.neg.box.neg.neg.imp φ.neg.box.box).box.imp
                    (φ.neg.box.neg.neg.box.imp φ.neg.box.box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.box.neg.neg φ.neg.box.box)

  have distributed : ⊢ φ.neg.box.neg.neg.box.imp φ.neg.box.box.box :=
    DerivationTree.modus_ponens [] _ _ mk_dist box_combined

  -- Step 6: Negate both sides: ¬□□□¬φ → ¬□¬¬□¬φ
  have distributed_neg : ⊢ φ.neg.box.box.box.neg.imp φ.neg.box.neg.neg.box.neg :=
    contraposition distributed

  -- Step 7: Use M4 on □¬φ: □□¬φ → □□□¬φ
  have m4_twice : ⊢ φ.neg.box.box.imp φ.neg.box.box.box :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ.neg.box)

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
    DerivationTree.necessitation _ dni_box

  -- Distribute
  have mk_dni : ⊢ (φ.neg.box.imp φ.neg.box.neg.neg).box.imp
                   (φ.neg.box.box.imp φ.neg.box.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.box φ.neg.box.neg.neg)

  have bridge : ⊢ φ.neg.box.box.imp φ.neg.box.neg.neg.box :=
    DerivationTree.modus_ponens [] _ _ mk_dni box_dni

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
def modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box := by
  -- Step 1: MB on ◇φ
  have mb_dia : ⊢ φ.diamond.imp φ.diamond.diamond.box :=
    DerivationTree.axiom [] _ (Axiom.modal_b φ.diamond)

  -- Step 2: diamond_4 for φ
  have d4 : ⊢ φ.diamond.diamond.imp φ.diamond := diamond_4 φ

  -- Step 3: Necessitate d4 using modal_k with empty context
  have box_d4 : ⊢ (φ.diamond.diamond.imp φ.diamond).box :=
    DerivationTree.necessitation _ d4

  -- Step 4: MK distribution
  have mk : ⊢ (φ.diamond.diamond.imp φ.diamond).box.imp
               (φ.diamond.diamond.box.imp φ.diamond.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.diamond.diamond φ.diamond)

  have d4_box : ⊢ φ.diamond.diamond.box.imp φ.diamond.box :=
    DerivationTree.modus_ponens [] _ _ mk box_d4

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
def perpetuity_2 (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := by
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
def box_to_box_past (φ : Formula) : ⊢ φ.box.imp (φ.all_past.box) := by
  have mf : ⊢ φ.swap_temporal.box.imp (φ.swap_temporal.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ.swap_temporal)
  have mf_swap : ⊢ (φ.swap_temporal.box.imp (φ.swap_temporal.all_future.box)).swap_temporal :=
    DerivationTree.temporal_duality _ mf
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
def box_conj_intro {A B : Formula}
    (hA : ⊢ A.box) (hB : ⊢ B.box) : ⊢ (A.and B).box := by
  -- Step 1: pairing axiom gives us the base implication
  have pair : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  -- Step 2: necessitation of pairing using modal_k with empty context
  have box_pair : ⊢ (A.imp (B.imp (A.and B))).box :=
    DerivationTree.necessitation _ pair
  -- Step 3: modal K distribution (first application)
  -- □(A → (B → A∧B)) → (□A → □(B → A∧B))
  have mk1 : ⊢ (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B)))
  have h1 : ⊢ A.box.imp (B.imp (A.and B)).box :=
    DerivationTree.modus_ponens [] _ _ mk1 box_pair
  -- Step 4: modal K distribution (second application)
  -- □(B → A∧B) → (□B → □(A∧B))
  have mk2 : ⊢ (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist B (A.and B))
  -- Compose: □A → □(B → A∧B) and □(B → A∧B) → (□B → □(A∧B))
  -- to get: □A → (□B → □(A∧B))
  have h2 : ⊢ A.box.imp (B.box.imp (A.and B).box) := imp_trans h1 mk2
  -- Apply with hA to get: □B → □(A∧B)
  have h3 : ⊢ B.box.imp (A.and B).box :=
    DerivationTree.modus_ponens [] _ _ h2 hA
  -- Apply with hB to get: □(A∧B)
  exact DerivationTree.modus_ponens [] _ _ h3 hB

/--
Boxed conjunction introduction from implications: from `⊢ P → □A` and `⊢ P → □B`,
derive `⊢ P → □(A ∧ B)`.

This variant of `box_conj_intro` works with implications rather than direct
derivations. It's useful for combining components like `□φ → □Hφ`, `□φ → □φ`,
`□φ → □Gφ` into `□φ → □(Hφ ∧ (φ ∧ Gφ))`.
-/
def box_conj_intro_imp {P A B : Formula}
    (hA : ⊢ P.imp A.box) (hB : ⊢ P.imp B.box) : ⊢ P.imp (A.and B).box := by
  -- Strategy: Build P → □A → □B → □(A ∧ B), then apply with hA and hB
  -- From box_conj_intro proof, we have the pattern: □A → □B → □(A ∧ B)

  -- First, build the implication chain: □A → □B → □(A ∧ B)
  have pair : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  have box_pair : ⊢ (A.imp (B.imp (A.and B))).box :=
    DerivationTree.necessitation _ pair
  have mk1 : ⊢ (A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A (B.imp (A.and B)))
  have h1 : ⊢ A.box.imp (B.imp (A.and B)).box :=
    DerivationTree.modus_ponens [] _ _ mk1 box_pair
  have mk2 : ⊢ (B.imp (A.and B)).box.imp (B.box.imp (A.and B).box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist B (A.and B))
  have box_to_box : ⊢ A.box.imp (B.box.imp (A.and B).box) := imp_trans h1 mk2

  -- Now compose: P → □A and □A → □B → □(A ∧ B) gives P → □B → □(A ∧ B)
  have h2 : ⊢ P.imp (B.box.imp (A.and B).box) := imp_trans hA box_to_box

  -- Compose: P → □B → □(A ∧ B) and P → □B gives P → □(A ∧ B)
  -- Use K axiom: (P → (□B → □(A ∧ B))) → ((P → □B) → (P → □(A ∧ B)))
  have k : ⊢ (P.imp (B.box.imp (A.and B).box)).imp ((P.imp B.box).imp (P.imp (A.and B).box)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k P B.box (A.and B).box)
  have h3 : ⊢ (P.imp B.box).imp (P.imp (A.and B).box) :=
    DerivationTree.modus_ponens [] _ _ k h2
  exact DerivationTree.modus_ponens [] _ _ h3 hB

/--
Three-way boxed conjunction introduction from implications.
From `⊢ P → □A`, `⊢ P → □B`, `⊢ P → □C`, derive `⊢ P → □(A ∧ (B ∧ C))`.
-/
def box_conj_intro_imp_3 {P A B C : Formula}
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
def perpetuity_3 (φ : Formula) : ⊢ φ.box.imp (φ.always.box) := by
  -- always φ = φ.all_past.and (φ.and φ.all_future) = Hφ ∧ (φ ∧ Gφ)
  -- Goal: ⊢ □φ → □(Hφ ∧ (φ ∧ Gφ))

  -- Component implications from boxed φ to boxed temporal components
  have h_past : ⊢ φ.box.imp (φ.all_past.box) := box_to_box_past φ
  have h_present : ⊢ φ.box.imp φ.box := identity φ.box
  have h_future : ⊢ φ.box.imp (φ.all_future.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ)

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
def box_dne {A : Formula}
    (h : ⊢ A.neg.neg.box) : ⊢ A.box := by
  -- Step 1: DNE axiom
  have dne : ⊢ A.neg.neg.imp A :=
    double_negation A

  -- Step 2: Necessitate using modal_k with empty context
  have box_dne : ⊢ (A.neg.neg.imp A).box :=
    DerivationTree.necessitation _ dne

  -- Step 3: Modal K distribution
  have mk : ⊢ (A.neg.neg.imp A).box.imp (A.neg.neg.box.imp A.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist A.neg.neg A)

  -- Step 4: Apply modus ponens twice
  have step : ⊢ A.neg.neg.box.imp A.box :=
    DerivationTree.modus_ponens [] _ _ mk box_dne
  exact DerivationTree.modus_ponens [] _ _ step h

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
def perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
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
    DerivationTree.necessitation _ dni_always

  -- Modal K: □(△¬φ → ¬¬△¬φ) → (□△¬φ → □¬¬△¬φ)
  have mk_dni : ⊢ (φ.neg.always.imp φ.neg.always.neg.neg).box.imp
                   (φ.neg.always.box.imp φ.neg.always.neg.neg.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.always φ.neg.always.neg.neg)

  -- Apply: □△¬φ → □¬¬△¬φ
  have box_dni_imp : ⊢ φ.neg.always.box.imp φ.neg.always.neg.neg.box :=
    DerivationTree.modus_ponens [] _ _ mk_dni box_dni_always

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
def mb_diamond (φ : Formula) : ⊢ φ.imp (φ.diamond.box) :=
  DerivationTree.axiom [] _ (Axiom.modal_b φ)

/--
Helper lemma: Apply TF axiom to boxed diamond.

From `□◇φ`, derive `F□◇φ` (necessarily possible persists to future).
-/
def box_diamond_to_future_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_future) :=
  DerivationTree.axiom [] _ (Axiom.temp_future φ.diamond)

/--
Helper lemma: Apply temporal duality to get past component.

From TF on `□◇φ`, derive `H□◇φ` via temporal duality.
-/
def box_diamond_to_past_box_diamond (φ : Formula) :
    ⊢ φ.diamond.box.imp (φ.diamond.box.all_past) := by
  -- Apply TF to swapped temporal version
  have tf_swap : ⊢ φ.diamond.box.swap_temporal.imp
                    (φ.diamond.box.swap_temporal.all_future) :=
    box_diamond_to_future_box_diamond φ.swap_temporal
  -- Apply temporal duality
  have td : ⊢ (φ.diamond.box.swap_temporal.imp
                φ.diamond.box.swap_temporal.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ tf_swap
  -- Simplify: swap(swap x) = x
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at td
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
noncomputable def future_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future) := by
  -- Step 1: [A → B, A] ⊢ B via modus ponens
  have step1 : [A.imp B, A] ⊢ B := by
    have h_imp : [A.imp B, A] ⊢ A.imp B := by
      apply DerivationTree.assumption
      simp
    have h_a : [A.imp B, A] ⊢ A := by
      apply DerivationTree.assumption
      simp
    exact DerivationTree.modus_ponens [A.imp B, A] A B h_imp h_a
  
  -- Step 2: Apply generalized_temporal_k to get [G(A → B), GA] ⊢ GB
  have step2 : [(A.imp B).all_future, A.all_future] ⊢ B.all_future := by
    exact Bimodal.Theorems.generalized_temporal_k [A.imp B, A] B step1
  
  -- Step 3: Reorder context to [GA, G(A → B)] ⊢ GB using weakening
  -- We need GA at the front to apply deduction theorem
  have step3_reordered : [A.all_future, (A.imp B).all_future] ⊢ B.all_future := by
    apply DerivationTree.weakening [(A.imp B).all_future, A.all_future] [A.all_future, (A.imp B).all_future] B.all_future step2
    intro x hx
    simp at hx ⊢
    exact hx.symm
  
  -- Step 4: Apply deduction theorem to get [G(A → B)] ⊢ GA → GB
  have step4 : [(A.imp B).all_future] ⊢ A.all_future.imp B.all_future := by
    exact Bimodal.Metalogic.deduction_theorem [(A.imp B).all_future] A.all_future B.all_future step3_reordered
  
  -- Step 5: Apply deduction theorem again to get ⊢ G(A → B) → (GA → GB)
  have step5 : [] ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future) := by
    exact Bimodal.Metalogic.deduction_theorem [] (A.imp B).all_future (A.all_future.imp B.all_future) step4
  
  exact step5

/--
Temporal K distribution for past: `H(A → B) → (HA → HB)`.

This is the past analog of future K distribution, derived via temporal duality.

**Semantic Justification**: By temporal symmetry in task semantics, if A → B holds
at all past times and A holds at all past times, then B must hold at all past times.

**Derivation**: This follows from `future_k_dist` applied with temporal duality.
-/
noncomputable def past_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past) := by
  -- Apply future_k_dist to swapped formulas
  have fk : ⊢ (A.swap_temporal.imp B.swap_temporal).all_future.imp
               (A.swap_temporal.all_future.imp B.swap_temporal.all_future) :=
    future_k_dist A.swap_temporal B.swap_temporal
  -- Apply temporal duality
  have td : ⊢ ((A.swap_temporal.imp B.swap_temporal).all_future.imp
                (A.swap_temporal.all_future.imp B.swap_temporal.all_future)).swap_temporal :=
    DerivationTree.temporal_duality _ fk
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
noncomputable def persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
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
    DerivationTree.axiom [] _ (Axiom.temp_future φ.diamond)

  -- We can derive: □◇φ → H□◇φ from TD (temporal duality on TF)
  have td : ⊢ φ.diamond.box.imp φ.diamond.box.all_past := by
    -- Apply TF to swapped temporal version
    have tf_swap : ⊢ φ.diamond.box.swap_temporal.imp
                      (φ.diamond.box.swap_temporal.all_future) :=
      DerivationTree.axiom [] _ (Axiom.temp_future φ.diamond.swap_temporal)
    -- Apply temporal duality
    have td_result : ⊢ (φ.diamond.box.swap_temporal.imp
                          φ.diamond.box.swap_temporal.all_future).swap_temporal :=
      DerivationTree.temporal_duality _ tf_swap
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
      DerivationTree.temporal_necessitation _ mt_swap
    have past_mt_raw :
      ⊢ ((φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal).all_future).swap_temporal :=
      DerivationTree.temporal_duality _ future_mt_swap
    -- Simplify using swap_temporal_diamond and swap_temporal_involution
    -- The key: swap(G(...)) = H(swap(...)), and swap is involutive
    -- swap(◇ψ) = ◇(swap ψ) by swap_temporal_diamond
    -- swap(□ψ) = □(swap ψ) similarly (box commutes with swap)
    -- So: swap(G(□◇(swap φ) → ◇(swap φ))) = H(□◇φ → ◇φ)
    have past_mt : ⊢ (φ.diamond.box.imp φ.diamond).all_past := by
      -- Show the equality of formula structures
      show ⊢ (φ.diamond.box.imp φ.diamond).all_past
      -- past_mt_raw has type that simplifies to what we need
      have eq1 :
        ((φ.diamond.box.swap_temporal.imp φ.diamond.swap_temporal).all_future).swap_temporal =
        (φ.diamond.box.imp φ.diamond).all_past := by
        -- Expand definitions and apply involution/commutation lemmas
        simp only [Formula.swap_temporal, Formula.swap_temporal_involution]
        rfl
      rw [← eq1]
      exact past_mt_raw
    -- Use past K distribution: H(□◇φ → ◇φ) → (H□◇φ → H◇φ)
    have pk : ⊢ (φ.diamond.box.imp φ.diamond).all_past.imp
                 (φ.diamond.box.all_past.imp φ.diamond.all_past) :=
      past_k_dist φ.diamond.box φ.diamond
    have past_bridge : ⊢ φ.diamond.box.all_past.imp φ.diamond.all_past :=
      DerivationTree.modus_ponens [] _ _ pk past_mt
    exact imp_trans chain1 past_bridge

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
      DerivationTree.temporal_necessitation _ mt
    -- Use future K distribution: G(□◇φ → ◇φ) → (G□◇φ → G◇φ)
    have fk : ⊢ (φ.diamond.box.imp φ.diamond).all_future.imp
                 (φ.diamond.box.all_future.imp φ.diamond.all_future) :=
      future_k_dist φ.diamond.box φ.diamond
    have future_bridge : ⊢ φ.diamond.box.all_future.imp φ.diamond.all_future :=
      DerivationTree.modus_ponens [] _ _ fk future_mt
    exact imp_trans chain2 future_bridge

  -- Combine all three components using combine_imp_conj_3
  exact combine_imp_conj_3 past_comp present_comp future_comp

/--
P5: `◇▽φ → △◇φ` (persistent possibility)

**Derivation**: Composition of P4 and persistence lemma:
- P4: `◇▽φ → ◇φ` (possibility of occurrence)
- Persistence: `◇φ → △◇φ` (possibility is perpetual)
- P5: `imp_trans (perpetuity_4 φ) (persistence φ)`

**Implementation Status**: FULLY PROVEN (zero sorry)
- All components proven as of Phase 3 completion
- Uses `modal_5` (`◇φ → □◇φ`, the S5 characteristic axiom derived from MB + diamond_4)
- Persistence lemma proven using `swap_temporal_diamond` for formula simplification
- Past component: temporal duality + past K distribution
- Future component: temporal K + future K distribution

**Semantic Justification** (Corollary 2.11):
P5 is semantically valid in task semantics:
1. S5 modal structure ensures possibility is stable across worlds
2. Temporal homogeneity ensures time-invariance of modal facts
3. Therefore: ◇▽φ at t implies ◇φ at all times in any world history
-/
noncomputable def perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always :=
  imp_trans (perpetuity_4 φ) (persistence φ)

end Bimodal.Theorems.Perpetuity
