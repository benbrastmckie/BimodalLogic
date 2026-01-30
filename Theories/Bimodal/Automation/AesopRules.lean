import Aesop
import Bimodal.ProofSystem
import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Aesop Rules for TM Logic

**DEPRECATION NOTICE (Task 513)**: As of 2026-01-17, the `tm_auto` tactic no longer
uses Aesop. It now delegates to `modal_search` to avoid proof reconstruction issues
with DerivationTree. This module is preserved for:
1. Potential future Aesop integration experiments
2. Reference documentation of the original rule set
3. Direct Aesop usage (not via `tm_auto`)

Custom rule set for Aesop automation in bimodal TM logic.

This module defines the TMLogic rule set for Aesop, providing forward chaining
automation for all proven TM axioms and key inference rules.

## Main Components

- `TMLogic` rule set declaration
- Forward chaining lemmas for 5 proven axioms (MT, M4, MB, T4, TA)
- Apply rules for core inference (modus_ponens, modal_k, temporal_k)
- Normalization rules for derived operators (diamond, always, sometimes)

## Excluded Axioms

The following axioms are excluded pending soundness proofs:
- TL (temp_l): Temporal introspection - soundness incomplete
- MF (modal_future): Modal-future interaction - soundness incomplete
- TF (temp_future): Temporal-modal interaction - soundness incomplete

## Usage

```lean
-- DEPRECATED: tm_auto no longer uses Aesop
-- Use modal_search instead for TM automation
example : ⊢ (□p → p) := by
  modal_search

-- Direct Aesop usage (not via tm_auto)
example : ⊢ (□p → p) := by
  aesop (rule_sets [TMLogic])
```

## References

* [TACTIC_DEVELOPMENT.md](../../../docs/ProjectInfo/TACTIC_DEVELOPMENT.md)
* [Axioms.lean](../ProofSystem/Axioms.lean)
* [Task 513](../../../../specs/513_address_tm_auto_proof_reconstruction_issues/)
-/

namespace Bimodal.Automation

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems

/-!
## Direct Axiom Rules

These rules directly construct axiom instances as derivations.
Uses safe apply to let Aesop try each axiom pattern.
-/

/-- Modal T axiom as direct derivation. -/
@[aesop safe apply]
def axiom_modal_t (Γ : Context) (φ : Formula) :
    DerivationTree Γ ((Formula.box φ).imp φ) :=
  DerivationTree.axiom Γ ((Formula.box φ).imp φ) (Axiom.modal_t φ)

/-- Propositional K axiom as direct derivation. -/
@[aesop safe apply]
def axiom_prop_k (Γ : Context) (φ ψ χ : Formula) :
    DerivationTree Γ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) :=
  DerivationTree.axiom Γ _ (Axiom.prop_k φ ψ χ)

/-- Propositional S axiom as direct derivation. -/
@[aesop safe apply]
def axiom_prop_s (Γ : Context) (φ ψ : Formula) :
    DerivationTree Γ (φ.imp (ψ.imp φ)) :=
  DerivationTree.axiom Γ _ (Axiom.prop_s φ ψ)

/-- Modal 4 axiom as direct derivation. -/
@[aesop safe apply]
def axiom_modal_4 (Γ : Context) (φ : Formula) :
    DerivationTree Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) :=
  DerivationTree.axiom Γ _ (Axiom.modal_4 φ)

/-- Modal B axiom as direct derivation. -/
@[aesop safe apply]
def axiom_modal_b (Γ : Context) (φ : Formula) :
    DerivationTree Γ (φ.imp (Formula.box φ.diamond)) :=
  DerivationTree.axiom Γ _ (Axiom.modal_b φ)

/-- Temporal 4 axiom as direct derivation. -/
@[aesop safe apply]
def axiom_temp_4 (Γ : Context) (φ : Formula) :
    DerivationTree Γ ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ))) :=
  DerivationTree.axiom Γ _ (Axiom.temp_4 φ)

/-- Temporal A axiom as direct derivation. -/
@[aesop safe apply]
def axiom_temp_a (Γ : Context) (φ : Formula) :
    DerivationTree Γ (φ.imp (Formula.all_future φ.sometime_past)) :=
  DerivationTree.axiom Γ _ (Axiom.temp_a φ)

/-!
## Forward Chaining Rules for Proven Axioms

These rules apply axioms to derive new conclusions from existing assumptions.
Only includes axioms with complete soundness proofs.
-/

/--
Forward chaining for Modal T axiom: `□φ → φ`.

If we have `□φ` derivable, we can derive `φ` using modal T axiom and modus ponens.
-/
@[aesop safe forward]
def modal_t_forward {Γ : Context} {φ : Formula} :
    DerivationTree Γ (Formula.box φ) → DerivationTree Γ φ := by
  intro d
  have ax := DerivationTree.axiom Γ (Formula.box φ |>.imp φ) (Axiom.modal_t φ)
  exact DerivationTree.modus_ponens Γ (Formula.box φ) φ ax d

/--
Forward chaining for Modal 4 axiom: `□φ → □□φ`.

If we have `□φ` derivable, we can derive `□□φ` using modal 4 axiom and modus ponens.
-/
@[aesop safe forward]
def modal_4_forward {Γ : Context} {φ : Formula} :
    DerivationTree Γ (Formula.box φ) → DerivationTree Γ (Formula.box (Formula.box φ)) := by
  intro d
  have ax := DerivationTree.axiom Γ ((Formula.box φ).imp (Formula.box (Formula.box φ))) (Axiom.modal_4 φ)
  exact DerivationTree.modus_ponens Γ (Formula.box φ) (Formula.box (Formula.box φ)) ax d

/--
Forward chaining for Modal B axiom: `φ → □◇φ`.

If we have `φ` derivable, we can derive `□◇φ` using modal B axiom and modus ponens.
-/
@[aesop safe forward]
def modal_b_forward {Γ : Context} {φ : Formula} :
    DerivationTree Γ φ → DerivationTree Γ (Formula.box φ.diamond) := by
  intro d
  have ax := DerivationTree.axiom Γ (φ.imp (Formula.box φ.diamond)) (Axiom.modal_b φ)
  exact DerivationTree.modus_ponens Γ φ (Formula.box φ.diamond) ax d

/--
Forward chaining for Temporal 4 axiom: `Fφ → FFφ`.

If we have `Fφ` derivable, we can derive `FFφ` using temporal 4 axiom and modus ponens.
-/
@[aesop safe forward]
def temp_4_forward {Γ : Context} {φ : Formula} :
    DerivationTree Γ (Formula.all_future φ) →
    DerivationTree Γ (Formula.all_future (Formula.all_future φ)) := by
  intro d
  have ax :=
    DerivationTree.axiom Γ
      ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))
      (Axiom.temp_4 φ)
  exact DerivationTree.modus_ponens Γ (Formula.all_future φ)
    (Formula.all_future (Formula.all_future φ)) ax d

/--
Forward chaining for Temporal A axiom: `φ → F(sometime_past φ)`.

If we have `φ` derivable, we can derive `F(sometime_past φ)` using temporal A axiom
and modus ponens.
-/
@[aesop safe forward]
def temp_a_forward {Γ : Context} {φ : Formula} :
    DerivationTree Γ φ → DerivationTree Γ (Formula.all_future φ.sometime_past) := by
  intro d
  have ax := DerivationTree.axiom Γ (φ.imp (Formula.all_future φ.sometime_past)) (Axiom.temp_a φ)
  exact DerivationTree.modus_ponens Γ φ (Formula.all_future φ.sometime_past) ax d

/--
Forward chaining for Propositional K axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`.

This is the distribution axiom for implication.
-/
@[aesop safe forward]
def prop_k_forward {Γ : Context} {φ ψ χ : Formula} :
    DerivationTree Γ (φ.imp (ψ.imp χ)) → DerivationTree Γ ((φ.imp ψ).imp (φ.imp χ)) := by
  intro d
  have ax :=
    DerivationTree.axiom Γ
      ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
      (Axiom.prop_k φ ψ χ)
  exact DerivationTree.modus_ponens Γ (φ.imp (ψ.imp χ))
    ((φ.imp ψ).imp (φ.imp χ)) ax d

/--
Forward chaining for Propositional S axiom: `φ → (ψ → φ)`.

This is the weakening axiom for implication.
-/
@[aesop safe forward]
def prop_s_forward {Γ : Context} {φ ψ : Formula} :
    DerivationTree Γ φ → DerivationTree Γ (ψ.imp φ) := by
  intro d
  have ax := DerivationTree.axiom Γ (φ.imp (ψ.imp φ)) (Axiom.prop_s φ ψ)
  exact DerivationTree.modus_ponens Γ φ (ψ.imp φ) ax d

/-!
## Apply Rules for Inference

These rules create subgoals for core inference rules.
-/

/--
Modus ponens as safe apply rule.

To prove `ψ`, if we can prove `φ → ψ` and `φ`, then we're done.
-/
@[aesop safe apply]
def apply_modus_ponens {Γ : Context} {φ ψ : Formula} :
    DerivationTree Γ (φ.imp ψ) → DerivationTree Γ φ → DerivationTree Γ ψ :=
  DerivationTree.modus_ponens Γ φ ψ

/--
Generalized Modal K rule as safe apply rule.

To prove `□φ` from `□Γ`, if we can prove `φ` from `Γ`, then we're done.
-/
@[aesop safe apply]
noncomputable def apply_modal_k {Γ : Context} {φ : Formula} :
    DerivationTree Γ φ → DerivationTree (Context.map Formula.box Γ) (Formula.box φ) :=
  generalized_modal_k Γ φ

/--
Generalized Temporal K rule as safe apply rule.

To prove `Fφ` from `FΓ`, if we can prove `φ` from `Γ`, then we're done.
-/
@[aesop safe apply]
noncomputable def apply_temporal_k {Γ : Context} {φ : Formula} :
    DerivationTree Γ φ → DerivationTree (Context.map Formula.all_future Γ) (Formula.all_future φ) :=
  generalized_temporal_k Γ φ

/-!
## Normalization Rules for Derived Operators

These rules unfold derived operators to their primitive definitions.
-/

/--
Normalize diamond operator to primitive negation and box.

`◇φ` unfolds to `¬□¬φ`.
-/
@[aesop norm unfold]
def normalize_diamond := @Formula.diamond

/--
Normalize always operator to primitive conjunction.

`△φ` unfolds to `Pφ ∧ φ ∧ Fφ`.
-/
@[aesop norm unfold]
def normalize_always := @Formula.always

/--
Normalize sometimes operator to primitive disjunction.

`▽φ` unfolds to `¬Pφ ∨ φ ∨ ¬Fφ` (via De Morgan's law).
-/
@[aesop norm unfold]
def normalize_sometimes := @Formula.sometimes

/--
Normalize sometime_past operator to primitive negation.

`sometime_past φ` unfolds to `¬P¬φ`.
-/
@[aesop norm unfold]
def normalize_sometime_past := @Formula.sometime_past

end Bimodal.Automation
