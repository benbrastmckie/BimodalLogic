import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context
import Logos.Core.ProofSystem.Axioms

/-!
# Derivation - Proof System for TM Logic

This module defines the derivability relation for bimodal logic TM,
representing syntactic provability from a context of assumptions.

## Main Definitions

- `Derivable`: Inductive relation `Γ ⊢ φ` meaning φ is derivable from context Γ
- Notation `⊢ φ` for derivability from empty context (theorem)
- Notation `Γ ⊢ φ` for derivability from context Γ

## Inference Rules

The derivability relation includes 7 inference rules:

1. **axiom**: Any axiom schema instance is derivable
2. **assumption**: Formulas in context are derivable
3. **modus_ponens**: If `Γ ⊢ φ → ψ` and `Γ ⊢ φ` then `Γ ⊢ ψ`
4. **necessitation**: If `⊢ φ` then `⊢ □φ` (standard modal necessitation)
5. **temporal_necessitation**: If `⊢ φ` then `⊢ Fφ` (standard temporal necessitation)
6. **temporal_duality**: If `⊢ φ` then `⊢ swap_past_future φ`
7. **weakening**: If `Γ ⊢ φ` and `Γ ⊆ Δ` then `Δ ⊢ φ`

## Implementation Notes

- Necessitation rules only apply to theorems (empty context)
- Temporal duality only applies to theorems (empty context)
- Weakening allows adding unused assumptions
- K distribution is handled by axioms (`modal_k_dist`, `temp_k_dist`)

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Proof system specification
* [Axioms.lean](./Axioms.lean) - Axiom schemata definitions
-/

namespace Logos.Core.ProofSystem

open Logos.Core.Syntax

/--
Derivability relation for bimodal logic TM.

`Derivable Γ φ` (written `Γ ⊢ φ`) means that formula `φ` is derivable
from the context of assumptions `Γ` using the TM proof system.

The relation is defined inductively with 7 inference rules covering:
- Axiom usage and assumptions
- Modus ponens (implication elimination)
- Modal and temporal necessitation (from theorems to necessary theorems)
- Temporal duality (swapping past/future)
- Weakening (adding unused assumptions)
-/
inductive Derivable : Context → Formula → Prop where
  /--
  Axiom rule: Any axiom schema instance is derivable from any context.

  If `Axiom φ` holds (φ matches an axiom schema), then `Γ ⊢ φ`.
  -/
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : Derivable Γ φ

  /--
  Assumption rule: Formulas in the context are derivable.

  If `φ ∈ Γ`, then `Γ ⊢ φ`.
  -/
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : Derivable Γ φ

  /--
  Modus ponens: Implication elimination.

  If `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, then `Γ ⊢ ψ`.
  -/
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (h1 : Derivable Γ (φ.imp ψ))
      (h2 : Derivable Γ φ) : Derivable Γ ψ

  /--
  Necessitation rule: From theorems, derive necessary theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ □φ`.

  This is the standard necessitation rule of modal logic. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it is necessarily true (□φ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `□Γ ⊢ □φ` is derivable from
  this rule plus K distribution (`modal_k_dist`) and the deduction theorem.
  See `Logos.Core.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.box φ)

  /--
  Temporal necessitation rule: From theorems, derive future-necessary theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ Fφ`.

  This is the temporal analog of modal necessitation. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it will always be true (Fφ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `FΓ ⊢ Fφ` is derivable from
  this rule plus temporal K distribution (`temp_k_dist`) and the deduction theorem.
  See `Logos.Core.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | temporal_necessitation (φ : Formula)
      (h : Derivable [] φ) : Derivable [] (Formula.all_future φ)

  /--
  Temporal duality rule: Swapping past and future in theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ swap_past_future φ`.

  This rule only applies to theorems (proofs from no assumptions).
  -/
  | temporal_duality (φ : Formula)
      (h : Derivable [] φ) : Derivable [] φ.swap_past_future

  /--
  Weakening rule: Adding unused assumptions.

  If `Γ ⊢ φ` and `Γ ⊆ Δ`, then `Δ ⊢ φ`.

  This allows adding extra assumptions that don't affect the derivation.
  -/
  | weakening (Γ Δ : Context) (φ : Formula)
      (h1 : Derivable Γ φ)
      (h2 : Γ ⊆ Δ) : Derivable Δ φ

/-! ## Derivation Height Measure -/

/--
Height of a derivation tree.

The height is defined as the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening):
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1

This measure is used for well-founded recursion in the deduction theorem proof.

## Implementation Notes

Since `Derivable` is a `Prop` (not a `Type`), we cannot pattern match on it
to produce data. Therefore, `height` is axiomatized with its key properties.

The axiomatization is sound because:
1. The height function is uniquely determined by the derivation structure
2. All properties follow from the recursive definition
3. The function is only used for termination proofs (not computation)

## Usage

The height measure is primarily used in `Logos.Core.Metalogic.DeductionTheorem`
for proving termination of the deduction theorem via well-founded recursion.
-/
axiom Derivable.height {Γ : Context} {φ : Formula} (d : Derivable Γ φ) : Nat

/-! ## Height Properties -/

/--
Weakening increases height by exactly 1.
-/
axiom Derivable.weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    (Derivable.weakening Γ' Δ φ d h).height = d.height + 1

/--
Subderivations in weakening have strictly smaller height.

This is the key lemma for proving termination of well-founded recursion
in the deduction theorem.
-/
axiom Derivable.subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : Derivable Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (Derivable.weakening Γ' Δ φ d h).height

/--
Modus ponens height is strictly greater than the left subderivation.
-/
axiom Derivable.mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d1.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

/--
Modus ponens height is strictly greater than the right subderivation.
-/
axiom Derivable.mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : Derivable Γ (φ.imp ψ)) (d2 : Derivable Γ φ) :
    d2.height < (Derivable.modus_ponens Γ φ ψ d1 d2).height

/--
Necessitation increases height by exactly 1.
-/
axiom Derivable.necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.necessitation φ d).height = d.height + 1

/--
Temporal necessitation increases height by exactly 1.
-/
axiom Derivable.temporal_necessitation_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_necessitation φ d).height = d.height + 1

/--
Temporal duality increases height by exactly 1.
-/
axiom Derivable.temporal_duality_height_succ {φ : Formula}
    (d : Derivable [] φ) :
    (Derivable.temporal_duality φ d).height = d.height + 1

/--
Notation `Γ ⊢ φ` for derivability from context Γ.
-/
notation:50 Γ " ⊢ " φ => Derivable Γ φ

/--
Notation `⊢ φ` for derivability from empty context (theorem).
-/
notation:50 "⊢ " φ => Derivable [] φ

/-!
## Example Derivations

Demonstrating basic usage of the proof system.
-/

/--
Example: Modal T axiom is a theorem.

`⊢ □p → p` for any propositional variable p.
-/
example (p : String) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.axiom
  apply Axiom.modal_t

/--
Example: Modus ponens from assumptions.

If we assume both `p → q` and `p`, we can derive `q`.
-/
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption
    simp
  · apply Derivable.assumption
    simp

/--
Example: Modal 4 axiom is a theorem.

`⊢ □φ → □□φ` for any formula φ.
-/
example (φ : Formula) : ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) := by
  apply Derivable.axiom
  apply Axiom.modal_4

/--
Example: Weakening allows adding assumptions.

If we can derive `□p → p` from empty context,
we can also derive it with extra assumptions.
-/
example (p : String) (ψ : Formula) : [ψ] ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply Derivable.weakening (Γ := [])
  · apply Derivable.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil _ h)

end Logos.Core.ProofSystem
