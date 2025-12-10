import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula

/-!
# Perpetuity Helper Lemmas

This module contains helper lemmas for proving the perpetuity principles (P1-P6).
These helpers include propositional reasoning combinators, conjunction introduction,
double negation introduction, and temporal component lemmas.

## Main Helper Categories

1. **Propositional Reasoning**: imp_trans, mp, identity, b_combinator, theorem_flip
2. **Application Combinators**: theorem_app1, theorem_app2
3. **Conjunction Introduction**: pairing, combine_imp_conj, combine_imp_conj_3
4. **Double Negation**: dni
5. **Temporal Components**: box_to_future, box_to_past, box_to_present

These helpers are used throughout the perpetuity principle proofs to construct
complex derivations from the basic K and S propositional axioms.

## References

* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Axioms.lean](../../ProofSystem/Axioms.lean) - Axiom schemata
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
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

/--
Flip combinator (C): `⊢ (A → B → C) → (B → A → C)`.

The C (flip) combinator swaps the order of arguments to a binary function.
This is essential for deriving the pairing combinator and dni.

**Derivation Strategy**: Use S axiom to weaken, then K axiom to redistribute
arguments at nested levels, composing with b_combinator.
-/
theorem theorem_flip {A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C)) := by
  -- Goal: (A → B → C) → (B → A → C)
  -- Strategy: Build B → ((A → B → C) → (A → C)) using K and S axioms,
  -- then compose appropriately.

  -- Step 1: From K axiom at level B: (A → B → C) → (B → (A → B → C))
  have step1 : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp (B.imp C))) :=
    Derivable.axiom [] _ (Axiom.prop_s (A.imp (B.imp C)) B)

  -- Step 2: K axiom gives us (A → (B → C)) → ((A → B) → (A → C))
  -- Instantiate with first arg as B: (B → A → B → C) → ((B → A → B) → (B → A → C))
  -- But actually we need: B → ((A → B → C) → ((A → B) → (A → C)))
  -- Using prop_k at the A level

  -- Actually, let's use a cleaner approach via B-combinator composition.
  -- We have b_combinator: (B → C) → (A → B) → (A → C)
  -- Specialized: ((B → C) → C) → (A → (B → C)) → (A → C)

  -- Alternative: use the fact that we need to "distribute" B into the context.

  -- The key insight is:
  -- From (A → B → C), we can get (A → C) if we have B.
  -- So: (A → B → C) → B → (A → C)
  -- This follows from: (A → B → C) → (B → (A → B → C)) and
  --                   (B → (A → B → C)) → (B → ((A → B) → (A → C)))

  -- Use prop_k: (B → (A → (B → C))) → ((B → A) → (B → (B → C)))
  -- Then extract (B → A → C) from (B → B → C) using app pattern

  -- Simpler approach: use b_combinator directly
  -- b_combinator: (Y → Z) → (X → Y) → (X → Z)
  -- With Y = (A → B → C), Z = ((A → B) → (A → C)), X = B
  -- We need: (A → B → C) → ((A → B) → (A → C))
  -- This is exactly prop_k A B C!

  have k_abc : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)

  -- Weaken k_abc: ((A → B → C) → ...) → (B → ((A → B → C) → ...))
  have weak_k : ⊢ ((A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C))).imp
                   (B.imp ((A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_s ((A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C))) B)

  have step2 : ⊢ B.imp ((A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C))) :=
    Derivable.modus_ponens [] _ _ weak_k k_abc

  -- Now use prop_k to distribute B through:
  -- (B → X → Y) → ((B → X) → (B → Y)) where X = (A → B → C), Y = ((A → B) → (A → C))
  have k_step : ⊢ (B.imp ((A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)))).imp
                   ((B.imp (A.imp (B.imp C))).imp (B.imp ((A.imp B).imp (A.imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_k B (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)))

  have step3 : ⊢ (B.imp (A.imp (B.imp C))).imp (B.imp ((A.imp B).imp (A.imp C))) :=
    Derivable.modus_ponens [] _ _ k_step step2

  -- Compose step1 with step3 to get (A → B → C) → (B → ((A → B) → (A → C)))
  have step4 : ⊢ (A.imp (B.imp C)).imp (B.imp ((A.imp B).imp (A.imp C))) :=
    imp_trans step1 step3

  -- Now we need to get from (B → ((A → B) → (A → C))) to ((A → B → C) → (B → (A → C)))
  -- We need to "supply" (A → B) = S axiom!

  -- S axiom gives B → (A → B)
  have s_ab : ⊢ B.imp (A.imp B) := Derivable.axiom [] _ (Axiom.prop_s B A)

  -- We need: (B → (A → B)) → ((B → ((A → B) → (A → C))) → (B → (A → C)))
  -- This is exactly the b_combinator pattern!
  -- b_combinator: (Y → Z) → (X → Y) → (X → Z)
  -- At level B: ((A → B) → (A → C)) is the function, (A → B) is the intermediate
  -- Actually we need: ((B → (A → B)) → ((B → ((A → B) → (A → C))) → (B → (A → C))))

  -- Use prop_k at level B: (B → X → Y) → ((B → X) → (B → Y))
  -- with X = (A → B), Y = (A → C)
  have k_final : ⊢ (B.imp ((A.imp B).imp (A.imp C))).imp ((B.imp (A.imp B)).imp (B.imp (A.imp C))) :=
    Derivable.axiom [] _ (Axiom.prop_k B (A.imp B) (A.imp C))

  -- Apply step4 via imp_trans pattern
  -- We have step4: (A → B → C) → (B → ((A → B) → (A → C)))
  -- We have k_final: (B → ((A → B) → (A → C))) → ((B → (A → B)) → (B → (A → C)))
  -- Compose: (A → B → C) → ((B → (A → B)) → (B → (A → C)))
  have step5 : ⊢ (A.imp (B.imp C)).imp ((B.imp (A.imp B)).imp (B.imp (A.imp C))) :=
    imp_trans step4 k_final

  -- Now apply s_ab
  -- We have step5: (A → B → C) → ((B → (A → B)) → (B → (A → C)))
  -- We have s_ab: B → (A → B)
  -- We need: (A → B → C) → (B → (A → C))

  -- Use prop_k to combine:
  -- prop_k: (φ → ψ → χ) → ((φ → ψ) → (φ → χ))
  -- with φ = (A → B → C), ψ = (B → (A → B)), χ = (B → (A → C))
  -- Actually that's not quite right structure.

  -- Let's use modus ponens pattern differently.
  -- We know s_ab: B → (A → B)
  -- Weaken to: (A → B → C) level:
  have weak_s_ab : ⊢ (B.imp (A.imp B)).imp ((A.imp (B.imp C)).imp (B.imp (A.imp B))) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp (A.imp B)) (A.imp (B.imp C)))

  have step6 : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp B)) :=
    Derivable.modus_ponens [] _ _ weak_s_ab s_ab

  -- Now combine step5 and step6 using prop_k
  -- step5: (A → B → C) → ((B → (A → B)) → (B → (A → C)))
  -- step6: (A → B → C) → (B → (A → B))
  -- Goal: (A → B → C) → (B → (A → C))
  -- Use prop_k at (A → B → C) level
  have k_combine : ⊢ ((A.imp (B.imp C)).imp ((B.imp (A.imp B)).imp (B.imp (A.imp C)))).imp
                      (((A.imp (B.imp C)).imp (B.imp (A.imp B))).imp ((A.imp (B.imp C)).imp (B.imp (A.imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_k (A.imp (B.imp C)) (B.imp (A.imp B)) (B.imp (A.imp C)))

  have step7 : ⊢ ((A.imp (B.imp C)).imp (B.imp (A.imp B))).imp ((A.imp (B.imp C)).imp (B.imp (A.imp C))) :=
    Derivable.modus_ponens [] _ _ k_combine step5

  exact Derivable.modus_ponens [] _ _ step7 step6

/--
Single application lemma (app1): `⊢ A → (A → B) → B`.

This lemma expresses that given a value of type A and a function A → B,
we can produce a value of type B. In combinator calculus, this corresponds
to the application pattern derived from flip applied to identity.

**Derivation**: Apply theorem_flip to identity with appropriate substitutions.
-/
theorem theorem_app1 {A B : Formula} : ⊢ A.imp ((A.imp B).imp B) := by
  -- Goal: A → (A → B) → B
  -- Strategy: Use flip to swap arguments of a suitable function

  -- identity at (A → B): (A → B) → (A → B)
  have id_ab : ⊢ (A.imp B).imp (A.imp B) := identity (A.imp B)

  -- Apply flip to this identity:
  -- flip: (X → Y → Z) → (Y → X → Z)
  -- With X = (A → B), Y = A, Z = B
  -- We need: ((A → B) → A → B) → (A → (A → B) → B)
  -- So flip applied to ((A → B) → A → B) gives (A → (A → B) → B)

  -- First, we need flip at these types
  have flip_inst : ⊢ ((A.imp B).imp (A.imp B)).imp (A.imp ((A.imp B).imp B)) :=
    @theorem_flip (A.imp B) A B

  exact Derivable.modus_ponens [] _ _ flip_inst id_ab

/--
Double application lemma (app2): `⊢ A → B → (A → B → C) → C`.

This lemma expresses that given values of types A and B, and a binary
function A → B → C, we can produce a value of type C.

**Derivation**: Compose theorem_app1 applications using b_combinator and
distribute appropriately using prop_k and prop_s axioms.
-/
theorem theorem_app2 {A B C : Formula} : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp C)) := by
  -- Goal: A → B → (A → B → C) → C
  -- Strategy: Use app1 at A-level and B-level, then compose

  -- Step 1: Use app1 at A to get: A → (A → (B → C)) → (B → C)
  have step_a : ⊢ A.imp ((A.imp (B.imp C)).imp (B.imp C)) := theorem_app1

  -- Step 2: Use app1 at B to get: B → (B → C) → C
  have step_b : ⊢ B.imp ((B.imp C).imp C) := theorem_app1

  -- Step 3: Weaken step_b with A: (B → (B → C) → C) → (A → (B → (B → C) → C))
  have weak_step_b : ⊢ (B.imp ((B.imp C).imp C)).imp (A.imp (B.imp ((B.imp C).imp C))) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp ((B.imp C).imp C)) A)

  have a_b_bc_c : ⊢ A.imp (B.imp ((B.imp C).imp C)) :=
    Derivable.modus_ponens [] _ _ weak_step_b step_b

  -- Step 4: Weaken step_a with B: (A → X → Y) → (B → (A → X → Y))
  have weak_step_a : ⊢ (A.imp ((A.imp (B.imp C)).imp (B.imp C))).imp
                        (B.imp (A.imp ((A.imp (B.imp C)).imp (B.imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_s (A.imp ((A.imp (B.imp C)).imp (B.imp C))) B)

  have b_a_abc_bc : ⊢ B.imp (A.imp ((A.imp (B.imp C)).imp (B.imp C))) :=
    Derivable.modus_ponens [] _ _ weak_step_a step_a

  -- Step 5: Flip to get A → B → (A → B → C) → (B → C)
  have a_b_abc_bc : ⊢ A.imp (B.imp ((A.imp (B.imp C)).imp (B.imp C))) :=
    Derivable.modus_ponens [] _ _ theorem_flip b_a_abc_bc

  -- Step 6: Now we have:
  -- a_b_abc_bc: A → B → (A → B → C) → (B → C)
  -- a_b_bc_c: A → B → (B → C) → C
  -- Goal: A → B → (A → B → C) → C

  -- We need to compose these at the (A → B) prefix level using b_combinator pattern

  -- b_combinator gives: ((B → C) → C) → ((A → B → C) → (B → C)) → ((A → B → C) → C)
  have b_comp : ⊢ ((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)) :=
    b_combinator

  -- Weaken with B
  have weak_b_comp : ⊢ (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                        (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_s
                           (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))
                           B)

  have b_b_comp : ⊢ B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.modus_ponens [] _ _ weak_b_comp b_comp

  -- Weaken with A
  have weak_a_b_comp : ⊢ (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))).imp
                          (A.imp (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))) :=
    Derivable.axiom [] _ (Axiom.prop_s
                           (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))
                           A)

  have a_b_b_comp : ⊢ A.imp (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.modus_ponens [] _ _ weak_a_b_comp b_b_comp

  -- Step 7: Use prop_k at the (A → B) level to distribute
  -- prop_k: (φ → ψ → χ) → ((φ → ψ) → (φ → χ))
  -- At (A → B) level with φ = ((B → C) → C), ψ = ((A → B → C) → (B → C)), χ = ((A → B → C) → C)

  -- First k at B level
  have k_b : ⊢ (B.imp (((B.imp C).imp C).imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))).imp
                ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_k B ((B.imp C).imp C) (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))

  have step7_b : ⊢ (B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.modus_ponens [] _ _ k_b b_b_comp

  -- Now k at A level
  have k_a : ⊢ (A.imp ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))).imp
                ((A.imp (B.imp ((B.imp C).imp C))).imp (A.imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))) :=
    Derivable.axiom [] _ (Axiom.prop_k A (B.imp ((B.imp C).imp C)) (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))

  -- Weaken step7_b with A
  have weak_step7 : ⊢ ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))).imp
                       (A.imp ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))) :=
    Derivable.axiom [] _ (Axiom.prop_s
                           ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))))
                           A)

  have a_step7 : ⊢ A.imp ((B.imp ((B.imp C).imp C)).imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.modus_ponens [] _ _ weak_step7 step7_b

  have step8 : ⊢ (A.imp (B.imp ((B.imp C).imp C))).imp (A.imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.modus_ponens [] _ _ k_a a_step7

  -- Apply step8 to a_b_bc_c
  have step9 : ⊢ A.imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.modus_ponens [] _ _ step8 a_b_bc_c

  -- Step 10: Now compose with a_b_abc_bc using prop_k at nested levels
  -- a_b_abc_bc: A → B → (A → B → C) → (B → C)
  -- step9: A → B → ((A → B → C) → (B → C)) → ((A → B → C) → C)
  -- Goal: A → B → (A → B → C) → C

  -- We need to combine at two levels: first B, then A
  -- Use prop_k at B level: (B → X → Y) → ((B → X) → (B → Y))
  -- with X = (A → B → C) → (B → C), Y = (A → B → C) → C
  have k_b_final : ⊢ (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                      ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.axiom [] _ (Axiom.prop_k B ((A.imp (B.imp C)).imp (B.imp C)) ((A.imp (B.imp C)).imp C))

  -- Weaken k_b_final with A
  have weak_k_b : ⊢ ((B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                      ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C)))).imp
                    (A.imp ((B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                      ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))))) :=
    Derivable.axiom [] _ (Axiom.prop_s
                           ((B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                            ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))))
                           A)

  have a_k_b : ⊢ A.imp ((B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                        ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.modus_ponens [] _ _ weak_k_b k_b_final

  -- Now use prop_k at A level to distribute
  -- prop_k A X Y gives: (A → X → Y) → ((A → X) → (A → Y))
  -- with X = (B → ((A → B → C) → (B → C)) → ((A → B → C) → C))
  --      Y = (B → ((A → B → C) → (B → C))) → (B → ((A → B → C) → C))
  have k_a_outer : ⊢ (A.imp ((B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C))).imp
                             ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))))).imp
                      ((A.imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))).imp
                       (A.imp ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))))) :=
    Derivable.axiom [] _ (Axiom.prop_k A (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))
                                          ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))))

  have step10_a : ⊢ (A.imp (B.imp (((A.imp (B.imp C)).imp (B.imp C)).imp ((A.imp (B.imp C)).imp C)))).imp
                     (A.imp ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.modus_ponens [] _ _ k_a_outer a_k_b

  have step10 : ⊢ A.imp ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.modus_ponens [] _ _ step10_a step9

  -- Now use prop_k at A level again to combine with a_b_abc_bc
  -- step10: A → ((B → ((A → B → C) → (B → C))) → (B → ((A → B → C) → C)))
  -- a_b_abc_bc: A → (B → ((A → B → C) → (B → C)))
  -- Goal: A → (B → ((A → B → C) → C))

  have k_a_final : ⊢ (A.imp ((B.imp ((A.imp (B.imp C)).imp (B.imp C))).imp (B.imp ((A.imp (B.imp C)).imp C)))).imp
                      ((A.imp (B.imp ((A.imp (B.imp C)).imp (B.imp C)))).imp (A.imp (B.imp ((A.imp (B.imp C)).imp C)))) :=
    Derivable.axiom [] _ (Axiom.prop_k A (B.imp ((A.imp (B.imp C)).imp (B.imp C))) (B.imp ((A.imp (B.imp C)).imp C)))

  have step11 : ⊢ (A.imp (B.imp ((A.imp (B.imp C)).imp (B.imp C)))).imp (A.imp (B.imp ((A.imp (B.imp C)).imp C))) :=
    Derivable.modus_ponens [] _ _ k_a_final step10

  exact Derivable.modus_ponens [] _ _ step11 a_b_abc_bc

/-!
## Helper Lemmas: Conjunction Introduction

Conjunction introduction (⊢ A → ⊢ B → ⊢ A ∧ B) requires the internal pairing
combinator (⊢ A → B → A ∧ B). This combinator is derived from the double
application lemma (theorem_app2) by observing that:
- A ∧ B = ¬(A → ¬B) = (A → B → ⊥) → ⊥
- theorem_app2 with C := ⊥ gives: A → B → (A → B → ⊥) → ⊥ = A → B → (A ∧ B)

This derivation completes the connection between combinator calculus and
conjunction introduction in the TM proof system.
-/

/--
Pairing combinator: `⊢ A → B → A ∧ B`.

This is the internal form of conjunction introduction. Given values of types
A and B, we can construct a value of type A ∧ B.

**Semantic Justification**: In task semantics, if A holds at (M,τ,t) and B holds
at (M,τ,t), then A ∧ B = ¬(A → ¬B) holds because assuming (A → ¬B) with A gives ¬B,
contradicting B.

**Derivation**: This theorem is derived from the double application combinator
`theorem_app2` by instantiating `C := Formula.bot`. The conjunction `A ∧ B`
expands to `((A → (B → ⊥)) → ⊥)`, which matches the type of `theorem_app2`
when `C = ⊥`:
- `A ∧ B = (A → B → ⊥) → ⊥` (by definition of conjunction and negation)
- `theorem_app2 A B ⊥ : A → B → (A → B → ⊥) → ⊥`
- These are definitionally equal after unfolding.

**Combinator correspondence**: In SKI combinator calculus, the pairing combinator
is the Vireo (V) combinator: V = λa.λb.λf. f a b. This derivation shows V can be
built from S (prop_s), K (prop_k), and I (identity = SKK) combinators via the
flip (C) and application (app1, app2) intermediate combinators.
-/
theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B)) := by
  -- Goal: A → B → A ∧ B
  -- Recall: A ∧ B = ¬(A → ¬B) = (A → B → ⊥) → ⊥
  -- From theorem_app2 with C := ⊥: A → B → (A → B → ⊥) → ⊥
  -- The types match exactly after unfolding the definition of conjunction
  unfold Formula.and Formula.neg
  -- Now goal is: A → B → (A → B → ⊥) → ⊥
  exact @theorem_app2 A B Formula.bot

/-!
## Helper Lemmas: Double Negation Introduction

Double negation introduction (`A → ¬¬A`) is a classical logic principle needed
for deriving P4 from P3 via contraposition.
-/

/--
Double negation introduction: `⊢ A → ¬¬A`.

In classical logic, if A is true, then ¬¬A is also true (assuming A leads to
contradiction from ¬A).

**Theorem**: This is now derived (not axiomatized) from `theorem_app1`.

**Proof**: Where `¬A = A → ⊥`, we have `¬¬A = (A → ⊥) → ⊥`.
The theorem follows from `theorem_app1` which gives `⊢ A → (A → B) → B`.
Instantiating with `B = ⊥` yields `⊢ A → (A → ⊥) → ⊥`, which is exactly `⊢ A → ¬¬A`.

The intuition: if we have `A`, then to derive a contradiction from `¬A` (i.e., `A → ⊥`),
we simply apply modus ponens to get `⊥`.

**Usage**: Required for P4 perpetuity proof (◇▽φ → ◇φ) via contraposition of P3.
-/
theorem dni (A : Formula) : ⊢ A.imp A.neg.neg :=
  @theorem_app1 A Formula.bot

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
## Helper Lemmas: Boilerplate Reduction

These lemmas reduce proof verbosity by combining common patterns:
- `axiom_in_context`: Axiom application in non-empty contexts
- `apply_axiom_to`: Axiom + modus ponens combination
- `apply_axiom_in_context`: Context-aware axiom application with modus ponens

These helpers eliminate 50+ axiom weakening boilerplate patterns and 150+ modus ponens chains
across the perpetuity proofs (identified in Plan 063 research).
-/

/--
Axiom in context: `Γ ⊢ φ` when `Axiom φ`.

This helper eliminates the common weakening boilerplate pattern:
```lean
Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (List.nil_subset Γ)
```

Instead of writing the above 5-argument weakening call, use:
```lean
axiom_in_context Γ φ h
```

**Proof Strategy**: Apply weakening from empty context to Γ using `List.nil_subset`.
-/
theorem axiom_in_context (Γ : Context) (φ : Formula) (h : Axiom φ) : Γ ⊢ φ := by
  exact Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (List.nil_subset Γ)

/--
Apply axiom to argument: `⊢ B` from `Axiom (A → B)` and `⊢ A`.

This helper eliminates the common modus ponens + axiom pattern:
```lean
Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h
```

Instead of writing the above nested modus ponens, use:
```lean
apply_axiom_to axiom_proof h
```

**Proof Strategy**: Apply axiom in empty context, then apply modus ponens.
-/
theorem apply_axiom_to {A B : Formula} (axiom_proof : Axiom (A.imp B)) (h : ⊢ A) : ⊢ B := by
  exact Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h

/--
Apply axiom in context: `Γ ⊢ B` from `Axiom (A → B)` and `Γ ⊢ A`.

This helper combines `axiom_in_context` and `modus_ponens` for the common pattern:
```lean
Derivable.modus_ponens Γ A B
  (Derivable.weakening [] Γ (A.imp B) (Derivable.axiom [] (A.imp B) axiom_proof) (List.nil_subset Γ))
  h
```

Instead of writing the above nested weakening + modus ponens, use:
```lean
apply_axiom_in_context Γ axiom_proof h
```

**Proof Strategy**: Use `axiom_in_context` to get `Γ ⊢ A → B`, then apply modus ponens with `h`.
-/
theorem apply_axiom_in_context (Γ : Context) {A B : Formula}
    (axiom_proof : Axiom (A.imp B)) (h : Γ ⊢ A) : Γ ⊢ B := by
  have hAB : Γ ⊢ A.imp B := axiom_in_context Γ (A.imp B) axiom_proof
  exact Derivable.modus_ponens Γ A B hAB h

end Logos.Core.Theorems.Perpetuity
