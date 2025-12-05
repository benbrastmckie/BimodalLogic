import Logos.Core.ProofSystem.Axioms

/-!
# Axioms Test Suite

Tests for the TM axiom schemata.

## Test Categories

- Propositional axioms (K, S)
- Modal axioms (MT, M4, MB)
- Temporal axioms (T4, TA, TL)
- Modal-temporal interaction axioms (MF, TF)
- Axiom instantiation correctness
-/

namespace LogosTest.Core.ProofSystem

open Logos.Core.Syntax
open Logos.Core.ProofSystem

-- ============================================================
-- Propositional K Axiom Tests: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
-- ============================================================

-- Test: Propositional K on atoms
example : Axiom (((Formula.atom "p").imp ((Formula.atom "q").imp (Formula.atom "r"))).imp
                  (((Formula.atom "p").imp (Formula.atom "q")).imp ((Formula.atom "p").imp (Formula.atom "r")))) :=
  Axiom.prop_k (Formula.atom "p") (Formula.atom "q") (Formula.atom "r")

-- Test: Propositional K with complex formulas
example : Axiom ((((Formula.atom "p").box).imp (((Formula.atom "q").future).imp (Formula.atom "r"))).imp
                  ((((Formula.atom "p").box).imp ((Formula.atom "q").future)).imp (((Formula.atom "p").box).imp (Formula.atom "r")))) :=
  Axiom.prop_k ((Formula.atom "p").box) ((Formula.atom "q").future) (Formula.atom "r")

-- Test: Propositional K with nested implications
example : Axiom (((Formula.atom "p").imp (((Formula.atom "q").imp (Formula.atom "r")).imp (Formula.atom "s"))).imp
                  (((Formula.atom "p").imp ((Formula.atom "q").imp (Formula.atom "r"))).imp ((Formula.atom "p").imp (Formula.atom "s")))) :=
  Axiom.prop_k (Formula.atom "p") ((Formula.atom "q").imp (Formula.atom "r")) (Formula.atom "s")

-- ============================================================
-- Propositional S Axiom Tests: φ → (ψ → φ)
-- ============================================================

-- Test: Propositional S on atoms
example : Axiom ((Formula.atom "p").imp ((Formula.atom "q").imp (Formula.atom "p"))) :=
  Axiom.prop_s (Formula.atom "p") (Formula.atom "q")

-- Test: Propositional S with box formula
example : Axiom (((Formula.atom "p").box).imp ((Formula.atom "q").imp ((Formula.atom "p").box))) :=
  Axiom.prop_s ((Formula.atom "p").box) (Formula.atom "q")

-- Test: Propositional S with complex formulas
example : Axiom ((((Formula.atom "p").imp (Formula.atom "q"))).imp
                  (((Formula.atom "r").future).imp ((Formula.atom "p").imp (Formula.atom "q")))) :=
  Axiom.prop_s ((Formula.atom "p").imp (Formula.atom "q")) ((Formula.atom "r").future)

-- ============================================================
-- Modal T Axiom Tests: □φ → φ
-- ============================================================

-- Test: Modal T axiom on atom
example : Axiom ((Formula.atom "p").box.imp (Formula.atom "p")) := Axiom.modal_t (Formula.atom "p")

-- Test: Modal T axiom on complex formula
example : Axiom ((Formula.atom "p" |>.imp (Formula.atom "q")).box.imp (Formula.atom "p" |>.imp (Formula.atom "q"))) :=
  Axiom.modal_t (Formula.atom "p" |>.imp (Formula.atom "q"))

-- Test: Modal T axiom on nested box
example : Axiom ((Formula.atom "p").box.box.imp (Formula.atom "p").box) :=
  Axiom.modal_t (Formula.atom "p").box

-- ============================================================
-- Modal 4 Axiom Tests: □φ → □□φ
-- ============================================================

-- Test: Modal 4 axiom on atom
example : Axiom ((Formula.atom "p").box.imp (Formula.atom "p").box.box) := Axiom.modal_4 (Formula.atom "p")

-- Test: Modal 4 axiom on implication
example : Axiom (((Formula.atom "p").imp (Formula.atom "q")).box.imp ((Formula.atom "p").imp (Formula.atom "q")).box.box) :=
  Axiom.modal_4 ((Formula.atom "p").imp (Formula.atom "q"))

-- ============================================================
-- Modal B Axiom Tests: φ → □◇φ
-- ============================================================

-- Test: Modal B axiom on atom
example : Axiom ((Formula.atom "p").imp (Formula.atom "p").diamond.box) := Axiom.modal_b (Formula.atom "p")

-- Test: Modal B axiom on box formula
example : Axiom ((Formula.atom "p").box.imp (Formula.atom "p").box.diamond.box) := Axiom.modal_b (Formula.atom "p").box

-- ============================================================
-- Temporal 4 Axiom Tests: Gφ → GGφ
-- ============================================================

-- Test: Temporal 4 axiom on atom
example : Axiom ((Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future) := Axiom.temp_4 (Formula.atom "p")

-- Test: Temporal 4 axiom on complex formula
example : Axiom ((Formula.atom "p").box.all_future.imp (Formula.atom "p").box.all_future.all_future) := Axiom.temp_4 (Formula.atom "p").box

-- ============================================================
-- Temporal A Axiom Tests: φ → G(some_past φ)
-- ============================================================

-- Test: Temporal A axiom on atom
example : Axiom ((Formula.atom "p").imp ((Formula.atom "p").some_past.all_future)) := Axiom.temp_a (Formula.atom "p")

-- Test: Temporal A axiom on negation
example : Axiom ((Formula.atom "p").neg.imp ((Formula.atom "p").neg.some_past.all_future)) := Axiom.temp_a (Formula.atom "p").neg

-- ============================================================
-- Temporal L Axiom Tests: Gφ → GHφ (G = all_future in our formalization)
-- ============================================================

-- Test: Temporal L axiom on atom
example : Axiom ((Formula.atom "p").all_future.imp ((Formula.atom "p").all_past.all_future)) := Axiom.temp_l (Formula.atom "p")

-- ============================================================
-- Modal-Future Axiom Tests: □φ → □Gφ
-- ============================================================

-- Test: Modal-Future axiom on atom
example : Axiom ((Formula.atom "p").box.imp (Formula.atom "p").all_future.box) := Axiom.modal_future (Formula.atom "p")

-- Test: Modal-Future axiom on implication
example : Axiom (((Formula.atom "p").imp (Formula.atom "q")).box.imp ((Formula.atom "p").imp (Formula.atom "q")).all_future.box) :=
  Axiom.modal_future ((Formula.atom "p").imp (Formula.atom "q"))

-- ============================================================
-- Temporal-Future Axiom Tests: □φ → G□φ
-- ============================================================

-- Test: Temporal-Future axiom on atom
example : Axiom ((Formula.atom "p").box.imp (Formula.atom "p").box.all_future) := Axiom.temp_future (Formula.atom "p")

-- Test: Temporal-Future axiom on complex formula
example : Axiom (((Formula.atom "p").and (Formula.atom "q")).box.imp ((Formula.atom "p").and (Formula.atom "q")).box.all_future) :=
  Axiom.temp_future ((Formula.atom "p").and (Formula.atom "q"))

-- ============================================================
-- Negative Tests: Non-axioms
-- ============================================================

-- Note: We cannot prove Axiom on arbitrary formulas
-- The following would NOT compile (correctly):
-- example : Axiom (Formula.atom "p") := _ -- Error: not an axiom schema

end LogosTest.Core.ProofSystem
