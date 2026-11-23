/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Congruence.Boolean

/-! # Necessity congruence for TM □ and TM⁺ □ and ⊡ -/

namespace FormalSystem.Theorems.ProofMode.Congruence

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

/-- Closed distribution and monotonicity for a specified necessity operator. -/
structure NecessityRules {L : Type} {P : L → Type} (kit : Kit L P) where
  /-- The necessity operator whose body can be rewritten. -/
  operator : L → L
  /-- Closed distribution through implication. -/
  distribution : ∀ A B, P (kit.imp (operator (kit.imp A B))
    (kit.imp (operator A) (operator B)))
  /-- Closed implication lifts under the operator. -/
  mono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (operator A) (operator B))

/-- Apply one congruence constructor to the rules for any of the supported necessity operators. -/
def Step.necessity {L : Type} {P : L → Type} {kit : Kit L P}
    (rules : NecessityRules kit) : Step kit where
  wrap := rules.operator
  demand := rules.operator
  flips := false
  transfer := rules.distribution
  demandMono := rules.mono

variable {fc : FrameClass}

/-- Modal body `x ↦ □x` in TM, by modal K and necessitation. -/
def tmBox : Step (tmKit fc) :=
  Step.necessity {
    operator := Formula.box
    distribution := fun A B => .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)
    mono := fun {A B} h =>
      Combinators.mp (.necessitation _ h)
        (.axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) }

/-- Modal body `x ↦ □x` in TM⁺, by native distribution and necessitation. -/
def plusBox : Step (plusKit fc) :=
  Step.necessity {
    operator := PlusFormula.box
    distribution := fun A B => .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)
    mono := fun {A B} h =>
      PlusLanguage.ProofMode.ctxMp
        (.axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) (.necessitation _ h) }

/-- Stability body `x ↦ ⊡x`, by native stability distribution and necessitation. -/
def plusStability : Step (plusKit fc) :=
  Step.necessity {
    operator := PlusFormula.stab
    distribution := fun A B => .axiom [] _ (.stab_k A B) (FrameClass.base_le fc)
    mono := fun {A B} h =>
      PlusLanguage.ProofMode.ctxMp
        (.axiom [] _ (.stab_k A B) (FrameClass.base_le fc)) (stabNecessitation h) }

end FormalSystem.Theorems.ProofMode.Congruence
