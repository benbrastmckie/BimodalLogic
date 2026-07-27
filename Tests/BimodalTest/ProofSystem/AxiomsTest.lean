/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Axioms
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.TemporalDerived

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

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.TemporalDerived

-- ============================================================
-- Propositional K Axiom Tests: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
-- ============================================================

-- Test: Propositional K on atoms
example : Axiom (((Formula.atomS "p").imp ((Formula.atomS "q").imp (Formula.atomS "r"))).imp
                  (((Formula.atomS "p").imp (Formula.atomS "q")).imp
                      ((Formula.atomS "p").imp (Formula.atomS "r")))) :=
  Axiom.prop_k (Formula.atomS "p") (Formula.atomS "q") (Formula.atomS "r")

-- Test: Propositional K with complex formulas
example : Axiom ((((Formula.atomS "p").box).imp
    (((Formula.atomS "q").allFuture).imp (Formula.atomS "r"))).imp
                  ((((Formula.atomS "p").box).imp ((Formula.atomS "q").allFuture)).imp
                      (((Formula.atomS "p").box).imp (Formula.atomS "r")))) :=
  Axiom.prop_k ((Formula.atomS "p").box) ((Formula.atomS "q").allFuture) (Formula.atomS "r")

-- Test: Propositional K with nested implications
example : Axiom (((Formula.atomS "p").imp
    (((Formula.atomS "q").imp (Formula.atomS "r")).imp (Formula.atomS "s"))).imp
                  (((Formula.atomS "p").imp ((Formula.atomS "q").imp (Formula.atomS "r"))).imp
                      ((Formula.atomS "p").imp (Formula.atomS "s")))) :=
  Axiom.prop_k (Formula.atomS "p") ((Formula.atomS "q").imp (Formula.atomS "r")) (Formula.atomS "s")

-- ============================================================
-- Propositional S Axiom Tests: φ → (ψ → φ)
-- ============================================================

-- Test: Propositional S on atoms
example : Axiom ((Formula.atomS "p").imp ((Formula.atomS "q").imp (Formula.atomS "p"))) :=
  Axiom.prop_s (Formula.atomS "p") (Formula.atomS "q")

-- Test: Propositional S with box formula
example : Axiom (((Formula.atomS "p").box).imp
    ((Formula.atomS "q").imp ((Formula.atomS "p").box))) :=
  Axiom.prop_s ((Formula.atomS "p").box) (Formula.atomS "q")

-- Test: Propositional S with complex formulas
example : Axiom ((((Formula.atomS "p").imp (Formula.atomS "q"))).imp
                  (((Formula.atomS "r").allFuture).imp
                      ((Formula.atomS "p").imp (Formula.atomS "q")))) :=
  Axiom.prop_s ((Formula.atomS "p").imp (Formula.atomS "q")) ((Formula.atomS "r").allFuture)

-- ============================================================
-- Modal T Axiom Tests: □φ → φ
-- ============================================================

-- Test: Modal T axiom on atom
example : Axiom ((Formula.atomS "p").box.imp (Formula.atomS "p")) := Axiom.modal_t
    (Formula.atomS "p")

-- Test: Modal T axiom on complex formula
example : Axiom ((Formula.atomS "p" |>.imp (Formula.atomS "q")).box.imp
    (Formula.atomS "p" |>.imp (Formula.atomS "q"))) :=
  Axiom.modal_t (Formula.atomS "p" |>.imp (Formula.atomS "q"))

-- Test: Modal T axiom on nested box
example : Axiom ((Formula.atomS "p").box.box.imp (Formula.atomS "p").box) :=
  Axiom.modal_t (Formula.atomS "p").box

-- ============================================================
-- Modal 4 Axiom Tests: □φ → □□φ
-- ============================================================

-- Test: Modal 4 axiom on atom
example : Axiom ((Formula.atomS "p").box.imp (Formula.atomS "p").box.box) := Axiom.modal_4
    (Formula.atomS "p")

-- Test: Modal 4 axiom on implication
example : Axiom (((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
    ((Formula.atomS "p").imp (Formula.atomS "q")).box.box) :=
  Axiom.modal_4 ((Formula.atomS "p").imp (Formula.atomS "q"))

-- ============================================================
-- Modal B Axiom Tests: φ → □◇φ
-- ============================================================

-- Test: Modal B axiom on atom
example : Axiom ((Formula.atomS "p").imp (Formula.atomS "p").diamond.box) := Axiom.modal_b
    (Formula.atomS "p")

-- Test: Modal B axiom on box formula
example : Axiom ((Formula.atomS "p").box.imp (Formula.atomS "p").box.diamond.box) := Axiom.modal_b
    (Formula.atomS "p").box

-- ============================================================
-- Modal 5 Collapse Tests: ◇□φ → □φ
-- ============================================================

-- Test: Modal 5 Collapse on atom
example : Axiom ((Formula.atomS "p").box.diamond.imp (Formula.atomS "p").box) :=
  Axiom.modal_5_collapse (Formula.atomS "p")

-- Test: Modal 5 Collapse on complex formula
example : Axiom (((Formula.atomS "p").imp (Formula.atomS "q")).box.diamond.imp
    ((Formula.atomS "p").imp (Formula.atomS "q")).box) :=
  Axiom.modal_5_collapse ((Formula.atomS "p").imp (Formula.atomS "q"))

-- ============================================================
-- Ex Falso Quodlibet Tests: ⊥ → φ
-- ============================================================

-- Test: EFQ on atom
example : Axiom (Formula.bot.imp (Formula.atomS "p")) :=
  Axiom.ex_falso (Formula.atomS "p")

-- Test: EFQ on box formula
example : Axiom (Formula.bot.imp ((Formula.atomS "p").box)) :=
  Axiom.ex_falso ((Formula.atomS "p").box)

-- Test: EFQ on complex formula
example : Axiom (Formula.bot.imp (((Formula.atomS "p").imp (Formula.atomS "q")).allFuture)) :=
  Axiom.ex_falso (((Formula.atomS "p").imp (Formula.atomS "q")).allFuture)

-- ============================================================
-- Peirce's Law Tests: ((φ → ψ) → φ) → φ
-- ============================================================

-- Test: Peirce on atoms
example : Axiom ((((Formula.atomS "p").imp (Formula.atomS "q")).imp (Formula.atomS "p")).imp
    (Formula.atomS "p")) :=
  Axiom.peirce (Formula.atomS "p") (Formula.atomS "q")

-- Test: Peirce on complex formulas
example : Axiom (((((Formula.atomS "p").box).imp (Formula.atomS "q")).imp
    ((Formula.atomS "p").box)).imp ((Formula.atomS "p").box)) :=
  Axiom.peirce ((Formula.atomS "p").box) (Formula.atomS "q")

-- Test: Peirce with bot (used in DNE derivation)
example : Axiom ((((Formula.atomS "p").imp Formula.bot).imp (Formula.atomS "p")).imp
    (Formula.atomS "p")) :=
  Axiom.peirce (Formula.atomS "p") Formula.bot

-- ============================================================
-- Temporal 4 Derived Theorem Tests: Gφ → GGφ
-- Note: temp_4 is now a derived theorem (Task 116), not an axiom constructor.
-- ============================================================

-- Test: Temporal 4 derived theorem on atom
noncomputable example : ⊢ ((Formula.atomS "p").allFuture.imp
    (Formula.atomS "p").allFuture.allFuture) :=
  temporal4Derived (Formula.atomS "p")

-- Test: Temporal 4 derived theorem on complex formula
noncomputable example : ⊢ ((Formula.atomS "p").box.allFuture.imp
    (Formula.atomS "p").box.allFuture.allFuture) :=
  temporal4Derived (Formula.atomS "p").box

-- ============================================================
-- Temporal A Axiom Tests: φ → G(somePast φ)
-- Note: Axiom.connect_future was removed in a prior task. The BX analogue is connect_future.
-- ============================================================

-- Test: connect_future axiom on atom (φ → G(P(φ)))
example : Axiom ((Formula.atomS "p").imp ((Formula.atomS "p").somePast.allFuture)) :=
  Axiom.connect_future (Formula.atomS "p")

-- Test: connect_future axiom on negation
example : Axiom ((Formula.atomS "p").neg.imp ((Formula.atomS "p").neg.somePast.allFuture)) :=
  Axiom.connect_future (Formula.atomS "p").neg

-- NOTE (Task 365): quarantined — `Axiom.temp_l` was removed (no axiom/derived replacement;
-- requires a multi-step derivation). Semantic `temp_l_valid` is retained elsewhere. See task
-- summary.
-- -- ============================================================
-- -- Temporal L Axiom Tests: △φ → FPφ (always implies future-past)
-- -- Note: Axiom.temp_l was removed in a prior task. This property can be derived.
-- -- ============================================================

-- Test: always implies future-past (derived from connect_future)
-- △φ = Hφ ∧ (φ ∧ Gφ), so △φ → φ → G(Pφ) via connect_future
-- Skipped: temp_l is no longer an axiom and requires a multi-step derivation

-- ============================================================
-- Modal-Future Axiom Tests: □φ → □Gφ
-- ============================================================

-- Test: Modal-Future axiom on atom
example : Axiom ((Formula.atomS "p").box.imp (Formula.atomS "p").allFuture.box) :=
    Axiom.modal_future (Formula.atomS "p")

-- Test: Modal-Future axiom on implication
example : Axiom (((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
    ((Formula.atomS "p").imp (Formula.atomS "q")).allFuture.box) :=
  Axiom.modal_future ((Formula.atomS "p").imp (Formula.atomS "q"))

-- ============================================================
-- Temporal-Future Derived Theorem Tests: □φ → G□φ (derived from MF + T + Modal 4)
-- ============================================================

-- Test: Temporal-Future derived theorem on atom
example : ⊢ (Formula.atomS "p").box.imp (Formula.atomS "p").box.allFuture :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived (Formula.atomS "p")

-- Test: Temporal-Future derived theorem on complex formula
example : ⊢ ((Formula.atomS "p").and (Formula.atomS "q")).box.imp
    ((Formula.atomS "p").and (Formula.atomS "q")).box.allFuture :=
  FormalSystem.Theorems.Combinators.temporalFutureDerived
      ((Formula.atomS "p").and (Formula.atomS "q"))

-- ============================================================
-- Modal K Distribution Axiom Tests: □(φ → ψ) → (□φ → □ψ)
-- ============================================================

-- Test: Modal K distribution on atoms
example : Axiom (((Formula.atomS "p").imp (Formula.atomS "q")).box.imp
                  ((Formula.atomS "p").box.imp (Formula.atomS "q").box)) :=
  Axiom.modal_k_dist (Formula.atomS "p") (Formula.atomS "q")

-- Test: Modal K distribution with complex formulas
example : Axiom ((((Formula.atomS "p").box).imp ((Formula.atomS "q").allFuture)).box.imp
                  (((Formula.atomS "p").box).box.imp ((Formula.atomS "q").allFuture).box)) :=
  Axiom.modal_k_dist ((Formula.atomS "p").box) ((Formula.atomS "q").allFuture)

-- Test: Modal K distribution enables combining boxed conjuncts
-- This is the pattern used in perpetuity3 proof
example (A B : Formula) :
  Axiom ((A.imp (B.imp (A.and B))).box.imp (A.box.imp (B.imp (A.and B)).box)) :=
  Axiom.modal_k_dist A (B.imp (A.and B))

-- ============================================================
-- Double Negation Elimination: Now Derived (not an axiom)
-- ============================================================

-- Note: DNE is now derived from EFQ + Peirce (see
-- FormalSystem.Theorems.Propositional.doubleNegation)
-- The following tests have been removed as DNE is no longer an axiom:
-- - Double negation elimination on atom
-- - Double negation elimination on box formula
-- - Double negation elimination on complex formula

-- ============================================================
-- Negative Tests: Non-axioms
-- ============================================================

-- Note: We cannot prove Axiom on arbitrary formulas
-- The following would NOT compile (correctly):
-- example : Axiom (Formula.atomS "p") := _ -- Error: not an axiom schema

end BimodalTest.ProofSystem
