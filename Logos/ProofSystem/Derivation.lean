import Logos.Syntax.Formula
import Logos.Syntax.Context
import Logos.ProofSystem.Axioms

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
4. **modal_k**: If `Γ ⊢ φ` then `□Γ ⊢ □φ` (JPL line 1030)
5. **temporal_k**: If `Γ ⊢ φ` then `FΓ ⊢ Fφ` (JPL line 1037)
6. **temporal_duality**: If `⊢ φ` then `⊢ swap_past_future φ`
7. **weakening**: If `Γ ⊢ φ` and `Γ ⊆ Δ` then `Δ ⊢ φ`

## Implementation Notes

- Modal K and Temporal K rules map the entire context through □ or F
- Temporal duality only applies to theorems (empty context)
- Weakening allows adding unused assumptions

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Proof system specification
* [Axioms.lean](./Axioms.lean) - Axiom schemata definitions
-/

namespace Logos.ProofSystem

open Logos.Syntax

/--
Derivability relation for bimodal logic TM.

`Derivable Γ φ` (written `Γ ⊢ φ`) means that formula `φ` is derivable
from the context of assumptions `Γ` using the TM proof system.

The relation is defined inductively with 7 inference rules covering:
- Axiom usage and assumptions
- Modus ponens (implication elimination)
- Modal and temporal K rules (distribution over □ and F)
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
  Modal K rule: Distribution of □ over derivation.

  If `Γ ⊢ φ`, then `□Γ ⊢ □φ` (where □Γ = Γ.map box).

  This rule expresses: if φ follows from assumptions Γ,
  then □φ follows from the necessary versions of those assumptions.

  Paper reference: JPL §sec:Appendix, line 1030
  -/
  | modal_k (Γ : Context) (φ : Formula)
      (h : Derivable Γ φ) : Derivable (Context.map Formula.box Γ) (Formula.box φ)

  /--
  Temporal K rule: Distribution of F over derivation.

  If `Γ ⊢ φ`, then `FΓ ⊢ Fφ` (where FΓ = Γ.map future).

  This rule expresses: if φ follows from assumptions Γ,
  then Fφ follows from the future versions of those assumptions.

  Paper reference: JPL §sec:Appendix, line 1037
  -/
  | temporal_k (Γ : Context) (φ : Formula)
      (h : Derivable Γ φ) : Derivable (Context.map Formula.future Γ) (Formula.future φ)

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

end Logos.ProofSystem
