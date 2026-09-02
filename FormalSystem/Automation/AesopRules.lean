/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Aesop
import FormalSystem.Automation.AesopRuleSet
import FormalSystem.ProofSystem
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.Context
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.TemporalDerived

/-!
# Aesop Rules for TM Logic

**DEPRECATION NOTICE**: As of 2026-01-17, the `tm_auto` tactic no longer
uses Aesop. It now delegates to `modal_search` to avoid proof reconstruction issues
with DerivationTree. This module is preserved for:
1. Potential future Aesop integration experiments
2. Reference documentation of the original rule set
3. Direct Aesop usage (not via `tm_auto`)

Custom rule set for Aesop automation in bimodal TM logic.

This module populates the `TMLogic` Aesop rule set, providing forward chaining automation for
all proven TM axioms and key inference rules. The rule set itself is *declared* one module
upstream, in `Automation/AesopRuleSet.lean` — an Aesop rule set is not visible in the file that
declares it, so the declaration and its uses cannot share a compilation unit. Reaching these
rules takes an explicit `aesop (rule_sets := [TMLogic])`; plain `aesop` no longer sees them.

## Main Components

- Forward chaining lemmas for 5 proven axioms (MT, M4, MB, T4, TA)
- Apply rules for core inference (modus_ponens, modal_k, temporal_k)
- Normalization rules for derived operators (diamond, always, sometimes)

## Excluded Axioms

The following axioms are excluded pending soundness proofs:
- TL (temp_l): Temporal introspection - soundness incomplete
- MF (modal_future): Modal-future interaction - soundness incomplete
- TF (temporalFutureDerived): Now derived from MF + T + Modal 4

## Usage

```lean
-- DEPRECATED: tm_auto no longer uses Aesop
-- Use modal_search instead for TM automation
example : ⊢ (□p → p) := by
  modal_search

-- Direct Aesop usage (not via tm_auto). The rules below are registered in the
-- dedicated `TMLogic` rule set, declared in `Automation/AesopRuleSet.lean` and
-- imported above, so plain `aesop` does NOT pick them up. Name the rule set:
example : ⊢ (□p → p) := by
  aesop (rule_sets := [TMLogic])
```

## References

* [tactic-development.md](../../../docs/user-guide/tactic-development.md)
* [Axioms.lean](../ProofSystem/Axioms.lean)
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems

/-!
## Direct Axiom Rules

These rules directly construct axiom instances as derivations.
Uses safe apply to let Aesop try each axiom pattern.
-/

/-- Modal T axiom as direct derivation. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomModalT (Γ : Context) (φ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ ((Formula.box φ).imp φ) :=
  DerivationTree.axiom Γ ((Formula.box φ).imp φ) (Axiom.modal_t φ) trivial

/-- Propositional K axiom as direct derivation. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomPropK (Γ : Context) (φ ψ χ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  DerivationTree.axiom Γ _ (Axiom.prop_k φ ψ χ) trivial

/-- Propositional S axiom as direct derivation. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomPropS (Γ : Context) (φ ψ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ (φ.imp (ψ.imp φ)) :=
  DerivationTree.axiom Γ _ (Axiom.prop_s φ ψ) trivial

/-- Modal 4 axiom as direct derivation. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomModal4 (Γ : Context) (φ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) :=
  DerivationTree.axiom Γ _ (Axiom.modal_4 φ) trivial

/-- Modal B axiom as direct derivation. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomModalB (Γ : Context) (φ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ (φ.imp (Formula.box φ.diamond)) :=
  DerivationTree.axiom Γ _ (Axiom.modal_b φ) trivial

/-- Temporal 4 axiom: G(φ) → G(G(φ)). Derived from BX3 + BX6. -/
@[aesop safe apply (rule_sets := [TMLogic])]
noncomputable def axiomTemp4 (Γ : Context) (φ : Formula) :
    Γ ⊢ ((Formula.allFuture φ).imp (Formula.allFuture (Formula.allFuture φ))) :=
  DerivationTree.weakening [] Γ _ (FormalSystem.Theorems.TemporalDerived.temporal4Derived φ)
      (List.nil_subset Γ)

/-- Connect future (BX4): φ → G(P(φ)). In BX axiom system. -/
@[aesop safe apply (rule_sets := [TMLogic])]
def axiomTempA (Γ : Context) (φ : Formula) {fc : FrameClass} :
    DerivationTree fc Γ (φ.imp (Formula.allFuture φ.somePast)) :=
  DerivationTree.axiom Γ _ (Axiom.connect_future φ) trivial

/-!
## Forward Chaining Rules for Proven Axioms

These rules apply axioms to derive new conclusions from existing assumptions.
Only includes axioms with complete soundness proofs.
-/

/--
Forward chaining for Modal T axiom: `□φ → φ`.

If we have `□φ` derivable, we can derive `φ` using modal T axiom and modus ponens.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def modalTForward {Γ : Context} {φ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ (Formula.box φ) → DerivationTree fc Γ φ := by
  intro d
  exact DerivationTree.modus_ponens Γ (Formula.box φ) φ
    (DerivationTree.axiom Γ _ (Axiom.modal_t φ) trivial) d

/--
Forward chaining for Modal 4 axiom: `□φ → □□φ`.

If we have `□φ` derivable, we can derive `□□φ` using modal 4 axiom and modus ponens.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def modal4Forward {Γ : Context} {φ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ (Formula.box φ) → DerivationTree fc Γ (Formula.box (Formula.box φ)) := by
  intro d
  exact DerivationTree.modus_ponens Γ (Formula.box φ) (Formula.box (Formula.box φ))
    (DerivationTree.axiom Γ _ (Axiom.modal_4 φ) trivial) d

/--
Forward chaining for Modal B axiom: `φ → □◇φ`.

If we have `φ` derivable, we can derive `□◇φ` using modal B axiom and modus ponens.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def modalBForward {Γ : Context} {φ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ φ → DerivationTree fc Γ (Formula.box φ.diamond) := by
  intro d
  exact DerivationTree.modus_ponens Γ φ (Formula.box φ.diamond)
    (DerivationTree.axiom Γ _ (Axiom.modal_b φ) trivial) d

/--
Forward chaining for Temporal 4 axiom: `Fφ → FFφ`.

If we have `Fφ` derivable, we can derive `FFφ` using temporal 4 axiom and modus ponens.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
noncomputable def temporal4Forward {Γ : Context} {φ : Formula} :
    (Γ ⊢ Formula.allFuture φ) →
    (Γ ⊢ Formula.allFuture (Formula.allFuture φ)) := by
  intro d
  exact DerivationTree.modus_ponens Γ _ _ (axiomTemp4 Γ φ) d

/--
Forward chaining for Connect Future (BX4): `φ → G(P(φ))`.

If we have `φ` derivable, we can derive `G(P(φ))` using connect_future axiom
and modus ponens.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def temporalAForward {Γ : Context} {φ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ φ → DerivationTree fc Γ (Formula.allFuture φ.somePast) := by
  intro d
  exact DerivationTree.modus_ponens Γ _ _ (axiomTempA Γ φ) d

/--
Forward chaining for Propositional K axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`.

This is the distribution axiom for implication.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def propKForward {Γ : Context} {φ ψ χ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ (φ.imp (ψ.imp χ)) → DerivationTree fc Γ ((φ.imp ψ).imp (φ.imp χ)) := by
  intro d
  exact DerivationTree.modus_ponens Γ (φ.imp (ψ.imp χ)) ((φ.imp ψ).imp (φ.imp χ))
    (DerivationTree.axiom Γ _ (Axiom.prop_k φ ψ χ) trivial) d

/--
Forward chaining for Propositional S axiom: `φ → (ψ → φ)`.

This is the weakening axiom for implication.
-/
@[aesop safe forward (rule_sets := [TMLogic])]
def propSForward {Γ : Context} {φ ψ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ φ → DerivationTree fc Γ (ψ.imp φ) := by
  intro d
  exact DerivationTree.modus_ponens Γ φ (ψ.imp φ)
    (DerivationTree.axiom Γ _ (Axiom.prop_s φ ψ) trivial) d

/-!
## Apply Rules for Inference

These rules create subgoals for core inference rules.
-/

/--
Modus ponens as safe apply rule.

To prove `ψ`, if we can prove `φ → ψ` and `φ`, then we're done.
-/
@[aesop safe apply (rule_sets := [TMLogic])]
def applyModusPonensRule {Γ : Context} {φ ψ : Formula} {fc : FrameClass} :
    DerivationTree fc Γ (φ.imp ψ) → DerivationTree fc Γ φ → DerivationTree fc Γ ψ :=
  DerivationTree.modus_ponens Γ φ ψ

/--
Generalized Modal K rule as safe apply rule.

To prove `□φ` from `□Γ`, if we can prove `φ` from `Γ`, then we're done.
-/
@[aesop safe apply (rule_sets := [TMLogic])]
noncomputable def applyModalK {Γ : Context} {φ : Formula} :
    (Γ ⊢ φ) → ((Context.map Formula.box Γ) ⊢ Formula.box φ) :=
  generalizedModalK Γ φ

/--
Generalized Temporal K rule as safe apply rule.

To prove `Fφ` from `FΓ`, if we can prove `φ` from `Γ`, then we're done.
-/
@[aesop safe apply (rule_sets := [TMLogic])]
noncomputable def applyTemporalK {Γ : Context} {φ : Formula} :
    (Γ ⊢ φ) → ((Context.map Formula.allFuture Γ) ⊢ Formula.allFuture φ) :=
  generalizedTemporalK Γ φ

/-!
## Normalization Rules for Derived Operators

These rules unfold derived operators to their primitive definitions.
-/

/--
Normalize diamond operator to primitive negation and box.

`◇φ` unfolds to `¬□¬φ`.
-/
@[aesop norm unfold (rule_sets := [TMLogic])]
def normalizeDiamond := @Formula.diamond

/--
Normalize always operator to primitive conjunction.

`△φ` unfolds to `Pφ ∧ φ ∧ Fφ`.
-/
@[aesop norm unfold (rule_sets := [TMLogic])]
def normalizeAlways := @Formula.always

/--
Normalize sometimes operator to primitive disjunction.

`▽φ` unfolds to `¬Pφ ∨ φ ∨ ¬Fφ` (via De Morgan's law).
-/
@[aesop norm unfold (rule_sets := [TMLogic])]
def normalizeSometimes := @Formula.sometimes

/--
Normalize somePast operator to primitive negation.

`somePast φ` unfolds to `¬P¬φ`.
-/
@[aesop norm unfold (rule_sets := [TMLogic])]
def normalizeSomePast := @Formula.somePast

end FormalSystem.Automation
