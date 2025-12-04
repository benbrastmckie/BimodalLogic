import Logos.Syntax.Formula

/-!
# Axioms - TM Axiom Schemata

This module defines the 10 axiom schemata for bimodal logic TM (Tense and Modality).

## Main Definitions

- `Axiom`: Inductive type characterizing valid axiom instances
- 10 axiom constructors: `prop_k`, `prop_s`, `modal_t`, `modal_4`, `modal_b`, `temp_4`, `temp_a`, `temp_l`, `modal_future`, `temp_future`

## Axiom Schemata

The TM logic includes:

### Propositional Axioms
- **K** (Propositional K): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution axiom
- **S** (Propositional S): `φ → (ψ → φ)` - weakening axiom

### S5 Modal Axioms (metaphysical necessity □)
- **MT** (Modal T): `□φ → φ` - what is necessary is true (reflexivity)
- **M4** (Modal 4): `□φ → □□φ` - necessary truths are necessarily necessary (transitivity)
- **MB** (Modal B): `φ → □◇φ` - truths are necessarily possible (symmetry)

### Temporal Axioms (future F, past P)
- **T4** (Temporal 4): `Fφ → FFφ` - future of future is future (transitivity)
- **TA** (Temporal A): `φ → FPφ` - the present was in the past of the future
- **TL** (Temporal L): `always φ → FPφ` - perpetuity implies recurrence

### Modal-Temporal Interaction Axioms
- **MF** (Modal-Future): `□φ → □Fφ` - necessary truths remain necessary in future
- **TF** (Temporal-Future): `□φ → F□φ` - necessary truths were/will-be necessary

## Implementation Notes

- Each constructor represents an axiom schema (quantified over all formulas)
- The `Axiom` type is a predicate on `Formula`, not a separate type
- Axiom instances are used in the `Derivable` relation

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - TM logic specification section
* [Formula.lean](../Syntax/Formula.lean) - Formula type definition
-/

namespace Logos.ProofSystem

open Logos.Syntax

/--
Axiom schemata for bimodal logic TM.

A formula `φ` is an axiom if it matches one of the 10 axiom schema patterns.
Each constructor takes formula parameters representing the schema instantiation.
-/
inductive Axiom : Formula → Prop where
  /--
  Propositional K axiom: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` (distribution).

  The distribution axiom for implication. If we have a way to derive χ from ψ
  assuming φ, and we have a way to derive ψ from φ, then we can derive χ from φ.
  This is a fundamental propositional tautology used in many proofs.
  -/
  | prop_k (φ ψ χ : Formula) :
      Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))

  /--
  Propositional S axiom: `φ → (ψ → φ)` (weakening).

  The weakening axiom for implication. A true formula remains true regardless
  of additional assumptions. This allows us to add hypotheses that are not used.
  This is a fundamental propositional tautology used in many proofs.
  -/
  | prop_s (φ ψ : Formula) : Axiom (φ.imp (ψ.imp φ))

  /--
  Modal T axiom: `□φ → φ` (reflexivity).

  What is necessarily true is actually true.
  Semantically: if φ holds at all possible worlds, it holds at the actual world.
  -/
  | modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)

  /--
  Modal 4 axiom: `□φ → □□φ` (transitivity).

  If something is necessary, it is necessarily necessary.
  Semantically: the accessibility relation is transitive.
  -/
  | modal_4 (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))

  /--
  Modal B axiom: `φ → □◇φ` (symmetry).

  Truths are necessarily possible.
  Semantically: the accessibility relation is symmetric.
  -/
  | modal_b (φ : Formula) : Axiom (φ.imp (Formula.box φ.diamond))

  /--
  Temporal 4 axiom: `Fφ → FFφ` (temporal transitivity).

  If something will always be true, it will always be true that it will always be true.
  -/
  | temp_4 (φ : Formula) : Axiom ((Formula.future φ).imp (Formula.future (Formula.future φ)))

  /--
  Temporal A axiom: `φ → F(sometime_past φ)` (temporal connectedness).

  If something is true now, at all future times there exists a past time where it was true.
  Semantically: if φ at t, then for all s > t, there exists r < s where φ at r (namely, t).

  Note: Uses existential `sometime_past` (¬P¬φ) not universal `past` (Pφ).
  -/
  | temp_a (φ : Formula) : Axiom (φ.imp (Formula.future φ.sometime_past))

  /--
  Temporal L axiom: `△φ → F(Pφ)` (temporal introspection).

  Following JPL paper §sec:Appendix (line 1040, thm:temporal-axioms-valid line 2325):
  If φ holds at ALL times (always φ = Past φ ∧ φ ∧ Future φ), then at all
  future times, φ holds at all past times.

  **Paper Proof** (line 2334):
  Suppose M,τ,x ⊨ always φ. Then M,τ,y ⊨ φ for all y ∈ T.
  To show M,τ,x ⊨ Future Past φ, consider any z > x.
  We must show M,τ,z ⊨ Past φ, i.e., M,τ,w ⊨ φ for all w < z.
  But this holds by our assumption that φ holds at all times in τ.

  This axiom is trivially valid because the premise (φ at ALL times)
  immediately implies the conclusion (φ at times w < z for any z).
  -/
  | temp_l (φ : Formula) : Axiom (φ.always.imp (Formula.future (Formula.past φ)))

  /--
  Modal-Future axiom: `□φ → □Fφ` (modal-future interaction).

  Necessary truths remain necessary in the future.
  -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.future φ)))

  /--
  Temporal-Future axiom: `□φ → F□φ` (temporal-modal interaction).

  Necessary truths will always be necessary.
  -/
  | temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.future (Formula.box φ)))

end Logos.ProofSystem
