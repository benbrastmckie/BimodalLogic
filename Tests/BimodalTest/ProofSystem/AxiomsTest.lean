import Bimodal.ProofSystem.Axioms
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.TemporalDerived

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

namespace BimodalTest.ProofSystem

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.TemporalDerived

-- ============================================================
-- Propositional K Axiom Tests: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
-- ============================================================

-- Test: Propositional K on atoms
example : Axiom (((Formula.atom_s "p").imp ((Formula.atom_s "q").imp (Formula.atom_s "r"))).imp
                  (((Formula.atom_s "p").imp (Formula.atom_s "q")).imp ((Formula.atom_s "p").imp (Formula.atom_s "r")))) :=
  Axiom.prop_k (Formula.atom_s "p") (Formula.atom_s "q") (Formula.atom_s "r")

-- Test: Propositional K with complex formulas
example : Axiom ((((Formula.atom_s "p").box).imp (((Formula.atom_s "q").all_future).imp (Formula.atom_s "r"))).imp
                  ((((Formula.atom_s "p").box).imp ((Formula.atom_s "q").all_future)).imp (((Formula.atom_s "p").box).imp (Formula.atom_s "r")))) :=
  Axiom.prop_k ((Formula.atom_s "p").box) ((Formula.atom_s "q").all_future) (Formula.atom_s "r")

-- Test: Propositional K with nested implications
example : Axiom (((Formula.atom_s "p").imp (((Formula.atom_s "q").imp (Formula.atom_s "r")).imp (Formula.atom_s "s"))).imp
                  (((Formula.atom_s "p").imp ((Formula.atom_s "q").imp (Formula.atom_s "r"))).imp ((Formula.atom_s "p").imp (Formula.atom_s "s")))) :=
  Axiom.prop_k (Formula.atom_s "p") ((Formula.atom_s "q").imp (Formula.atom_s "r")) (Formula.atom_s "s")

-- ============================================================
-- Propositional S Axiom Tests: φ → (ψ → φ)
-- ============================================================

-- Test: Propositional S on atoms
example : Axiom ((Formula.atom_s "p").imp ((Formula.atom_s "q").imp (Formula.atom_s "p"))) :=
  Axiom.prop_s (Formula.atom_s "p") (Formula.atom_s "q")

-- Test: Propositional S with box formula
example : Axiom (((Formula.atom_s "p").box).imp ((Formula.atom_s "q").imp ((Formula.atom_s "p").box))) :=
  Axiom.prop_s ((Formula.atom_s "p").box) (Formula.atom_s "q")

-- Test: Propositional S with complex formulas
example : Axiom ((((Formula.atom_s "p").imp (Formula.atom_s "q"))).imp
                  (((Formula.atom_s "r").all_future).imp ((Formula.atom_s "p").imp (Formula.atom_s "q")))) :=
  Axiom.prop_s ((Formula.atom_s "p").imp (Formula.atom_s "q")) ((Formula.atom_s "r").all_future)

-- ============================================================
-- Modal T Axiom Tests: □φ → φ
-- ============================================================

-- Test: Modal T axiom on atom
example : Axiom ((Formula.atom_s "p").box.imp (Formula.atom_s "p")) := Axiom.modal_t (Formula.atom_s "p")

-- Test: Modal T axiom on complex formula
example : Axiom ((Formula.atom_s "p" |>.imp (Formula.atom_s "q")).box.imp (Formula.atom_s "p" |>.imp (Formula.atom_s "q"))) :=
  Axiom.modal_t (Formula.atom_s "p" |>.imp (Formula.atom_s "q"))

-- Test: Modal T axiom on nested box
example : Axiom ((Formula.atom_s "p").box.box.imp (Formula.atom_s "p").box) :=
  Axiom.modal_t (Formula.atom_s "p").box

-- ============================================================
-- Modal 4 Axiom Tests: □φ → □□φ
-- ============================================================

-- Test: Modal 4 axiom on atom
example : Axiom ((Formula.atom_s "p").box.imp (Formula.atom_s "p").box.box) := Axiom.modal_4 (Formula.atom_s "p")

-- Test: Modal 4 axiom on implication
example : Axiom (((Formula.atom_s "p").imp (Formula.atom_s "q")).box.imp ((Formula.atom_s "p").imp (Formula.atom_s "q")).box.box) :=
  Axiom.modal_4 ((Formula.atom_s "p").imp (Formula.atom_s "q"))

-- ============================================================
-- Modal B Axiom Tests: φ → □◇φ
-- ============================================================

-- Test: Modal B axiom on atom
example : Axiom ((Formula.atom_s "p").imp (Formula.atom_s "p").diamond.box) := Axiom.modal_b (Formula.atom_s "p")

-- Test: Modal B axiom on box formula
example : Axiom ((Formula.atom_s "p").box.imp (Formula.atom_s "p").box.diamond.box) := Axiom.modal_b (Formula.atom_s "p").box

-- ============================================================
-- Modal 5 Collapse Tests: ◇□φ → □φ
-- ============================================================

-- Test: Modal 5 Collapse on atom
example : Axiom ((Formula.atom_s "p").box.diamond.imp (Formula.atom_s "p").box) :=
  Axiom.modal_5_collapse (Formula.atom_s "p")

-- Test: Modal 5 Collapse on complex formula
example : Axiom (((Formula.atom_s "p").imp (Formula.atom_s "q")).box.diamond.imp ((Formula.atom_s "p").imp (Formula.atom_s "q")).box) :=
  Axiom.modal_5_collapse ((Formula.atom_s "p").imp (Formula.atom_s "q"))

-- ============================================================
-- Ex Falso Quodlibet Tests: ⊥ → φ
-- ============================================================

-- Test: EFQ on atom
example : Axiom (Formula.bot.imp (Formula.atom_s "p")) :=
  Axiom.ex_falso (Formula.atom_s "p")

-- Test: EFQ on box formula
example : Axiom (Formula.bot.imp ((Formula.atom_s "p").box)) :=
  Axiom.ex_falso ((Formula.atom_s "p").box)

-- Test: EFQ on complex formula
example : Axiom (Formula.bot.imp (((Formula.atom_s "p").imp (Formula.atom_s "q")).all_future)) :=
  Axiom.ex_falso (((Formula.atom_s "p").imp (Formula.atom_s "q")).all_future)

-- ============================================================
-- Peirce's Law Tests: ((φ → ψ) → φ) → φ
-- ============================================================

-- Test: Peirce on atoms
example : Axiom ((((Formula.atom_s "p").imp (Formula.atom_s "q")).imp (Formula.atom_s "p")).imp (Formula.atom_s "p")) :=
  Axiom.peirce (Formula.atom_s "p") (Formula.atom_s "q")

-- Test: Peirce on complex formulas
example : Axiom (((((Formula.atom_s "p").box).imp (Formula.atom_s "q")).imp ((Formula.atom_s "p").box)).imp ((Formula.atom_s "p").box)) :=
  Axiom.peirce ((Formula.atom_s "p").box) (Formula.atom_s "q")

-- Test: Peirce with bot (used in DNE derivation)
example : Axiom ((((Formula.atom_s "p").imp Formula.bot).imp (Formula.atom_s "p")).imp (Formula.atom_s "p")) :=
  Axiom.peirce (Formula.atom_s "p") Formula.bot

-- ============================================================
-- Temporal 4 Derived Theorem Tests: Gφ → GGφ
-- Note: temp_4 is now a derived theorem (Task 116), not an axiom constructor.
-- ============================================================

-- Test: Temporal 4 derived theorem on atom
noncomputable example : ⊢ ((Formula.atom_s "p").all_future.imp (Formula.atom_s "p").all_future.all_future) :=
  temp_4_derived (Formula.atom_s "p")

-- Test: Temporal 4 derived theorem on complex formula
noncomputable example : ⊢ ((Formula.atom_s "p").box.all_future.imp (Formula.atom_s "p").box.all_future.all_future) :=
  temp_4_derived (Formula.atom_s "p").box

-- ============================================================
-- Temporal A Axiom Tests: φ → G(some_past φ)
-- Note: Axiom.temp_a was removed in a prior task. The BX analogue is connect_future.
-- ============================================================

-- Test: connect_future axiom on atom (φ → G(P(φ)))
example : Axiom ((Formula.atom_s "p").imp ((Formula.atom_s "p").some_past.all_future)) :=
  Axiom.connect_future (Formula.atom_s "p")

-- Test: connect_future axiom on negation
example : Axiom ((Formula.atom_s "p").neg.imp ((Formula.atom_s "p").neg.some_past.all_future)) :=
  Axiom.connect_future (Formula.atom_s "p").neg

-- ============================================================
-- Temporal L Axiom Tests: △φ → FPφ (always implies future-past)
-- Note: Axiom.temp_l was removed in a prior task. This property can be derived.
-- ============================================================

-- Test: always implies future-past (derived from connect_future)
-- △φ = Hφ ∧ (φ ∧ Gφ), so △φ → φ → G(Pφ) via connect_future
-- Skipped: temp_l is no longer an axiom and requires a multi-step derivation

-- ============================================================
-- Modal-Future Axiom Tests: □φ → □Gφ
-- ============================================================

-- Test: Modal-Future axiom on atom
example : Axiom ((Formula.atom_s "p").box.imp (Formula.atom_s "p").all_future.box) := Axiom.modal_future (Formula.atom_s "p")

-- Test: Modal-Future axiom on implication
example : Axiom (((Formula.atom_s "p").imp (Formula.atom_s "q")).box.imp ((Formula.atom_s "p").imp (Formula.atom_s "q")).all_future.box) :=
  Axiom.modal_future ((Formula.atom_s "p").imp (Formula.atom_s "q"))

-- ============================================================
-- Temporal-Future Derived Theorem Tests: □φ → G□φ (derived from MF + T + Modal 4)
-- ============================================================

-- Test: Temporal-Future derived theorem on atom
example : ⊢ (Formula.atom_s "p").box.imp (Formula.atom_s "p").box.all_future :=
  Bimodal.Theorems.Combinators.temp_future_derived (Formula.atom_s "p")

-- Test: Temporal-Future derived theorem on complex formula
example : ⊢ ((Formula.atom_s "p").and (Formula.atom_s "q")).box.imp ((Formula.atom_s "p").and (Formula.atom_s "q")).box.all_future :=
  Bimodal.Theorems.Combinators.temp_future_derived ((Formula.atom_s "p").and (Formula.atom_s "q"))

-- ============================================================
-- Modal K Distribution Axiom Tests: □(φ → ψ) → (□φ → □ψ)
-- ============================================================

-- Test: Modal K distribution on atoms
example : Axiom (((Formula.atom_s "p").imp (Formula.atom_s "q")).box.imp
                  ((Formula.atom_s "p").box.imp (Formula.atom_s "q").box)) :=
  Axiom.modal_k_dist (Formula.atom_s "p") (Formula.atom_s "q")

-- Test: Modal K distribution with complex formulas
example : Axiom ((((Formula.atom_s "p").box).imp ((Formula.atom_s "q").all_future)).box.imp
                  (((Formula.atom_s "p").box).box.imp ((Formula.atom_s "q").all_future).box)) :=
  Axiom.modal_k_dist ((Formula.atom_s "p").box) ((Formula.atom_s "q").all_future)

-- Test: Modal K distribution enables combining boxed conjuncts
-- This is the pattern used in perpetuity_3 proof
example (A B : Formula) :
  Axiom ((A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box)) :=
  Axiom.modal_k_dist A (B.imp (A.and B))

-- ============================================================
-- Double Negation Elimination: Now Derived (not an axiom)
-- ============================================================

-- Note: DNE is now derived from EFQ + Peirce (see Bimodal.Theorems.Propositional.double_negation)
-- The following tests have been removed as DNE is no longer an axiom:
-- - Double negation elimination on atom
-- - Double negation elimination on box formula
-- - Double negation elimination on complex formula

-- ============================================================
-- Negative Tests: Non-axioms
-- ============================================================

-- Note: We cannot prove Axiom on arbitrary formulas
-- The following would NOT compile (correctly):
-- example : Axiom (Formula.atom_s "p") := _ -- Error: not an axiom schema

end BimodalTest.ProofSystem
