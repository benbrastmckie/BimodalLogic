import Logos.Core.Syntax.Formula

/-!
# Axioms - TM Axiom Schemata

This module defines the 12 axiom schemata for bimodal logic TM (Tense and Modality).

## Main Definitions

- `Axiom`: Inductive type characterizing valid axiom instances
- 12 axiom constructors: `prop_k`, `prop_s`, `modal_t`, `modal_4`, `modal_b`, `modal_k_dist`, `double_negation`, `temp_4`, `temp_a`, `temp_l`, `modal_future`, `temp_future`

## Axiom Schemata

The TM logic includes:

### Propositional Axioms
- **K** (Propositional K): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution axiom
- **S** (Propositional S): `φ → (ψ → φ)` - weakening axiom
- **DNE** (Double Negation Elimination): `¬¬φ → φ` - classical logic principle

### S5 Modal Axioms (metaphysical necessity □)
- **MT** (Modal T): `□φ → φ` - what is necessary is true (reflexivity)
- **M4** (Modal 4): `□φ → □□φ` - necessary truths are necessarily necessary (transitivity)
- **MB** (Modal B): `φ → □◇φ` - truths are necessarily possible (symmetry)
- **MK** (Modal K Distribution): `□(φ → ψ) → (□φ → □ψ)` - necessity distributes over implication

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

namespace Logos.Core.ProofSystem

open Logos.Core.Syntax

/--
Axiom schemata for bimodal logic TM.

A formula `φ` is an axiom if it matches one of the 12 axiom schema patterns.
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
  Modal 5 Collapse axiom: `◇□φ → □φ` (S5 characteristic collapse).

  If it is possible that φ is necessary, then φ is necessary.
  This is the characteristic axiom of S5 that collapses nested modalities.

  Semantically: in S5 (where accessibility is an equivalence relation),
  if from the actual world we can access some world where □φ holds,
  then from that world we can access all worlds (including the actual world),
  so φ holds at all worlds, hence □φ at the actual world.

  This axiom enables:
  1. The S5 characteristic theorem `◇□A ↔ □A`
  2. Collapsing diamond-box patterns in modal reasoning
  3. Completing the modal distribution theorems in ModalS5.lean

  Note: Combined with B (`φ → □◇φ`) and 5 (`◇φ → □◇φ`, derived as `modal_5`),
  this completes the S5 modal logic.
  -/
  | modal_5_collapse (φ : Formula) : Axiom (φ.box.diamond.imp φ.box)

  /--
  Modal K Distribution axiom: `□(φ → ψ) → (□φ → □ψ)` (distribution).

  Necessity distributes over implication. If it is necessary that φ implies ψ,
  then if φ is necessary, ψ must also be necessary.

  This is the fundamental axiom of normal modal logics (K, T, S4, S5).
  It enables combining boxed formulas: from `⊢ □A` and `⊢ □B`, we can derive `⊢ □(A ∧ B)`
  by first deriving `⊢ □(A → (B → A∧B))` via necessitation, then applying this axiom twice.

  Semantically: in Kripke semantics, if φ → ψ holds at all accessible worlds,
  and φ holds at all accessible worlds, then ψ must hold at all accessible worlds.

  This axiom is sound in task semantics due to the S5 modal structure (Corollary 2.11).

  ## Derivability from MK Rule

  This axiom is derivable from the modal K inference rule (MK) plus the deduction theorem:
  1. From `[φ → ψ, φ] ⊢ ψ` (by modus ponens)
  2. Apply MK: `□[φ → ψ, φ] ⊢ □ψ`, i.e., `[□(φ → ψ), □φ] ⊢ □ψ`
  3. Apply deduction theorem twice to get `⊢ □(φ → ψ) → (□φ → □ψ)`

  The LEAN implementation includes this as an axiom for convenience, as the full
  deduction theorem (with modal cases) is not yet complete. Once the deduction
  theorem is proven for all inference rules, this could be replaced with a theorem.
  -/
  | modal_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))

  /--
  Double Negation Elimination: `¬¬φ → φ` (classical logic).

  A formula that is not false is true. This is the classical logic principle that
  distinguishes classical from intuitionistic logic.

  This axiom enables:
  1. Deriving contraposition: from `A → B` derive `¬B → ¬A`
  2. Proving perpetuity principle P4: `◇▽φ → ◇φ` via contraposition of P3
  3. Classical reasoning patterns throughout the proof system

  Semantically: TM uses two-valued classical semantics (formulas are either true
  or false at each world-history-time triple), so double negation elimination is
  valid. The semantics in `Truth.lean` uses boolean evaluation, not constructive logic.

  Note: This axiom makes TM a classical logic. Without it, TM would be intuitionistic.
  -/
  | double_negation (φ : Formula) : Axiom (φ.neg.neg.imp φ)

  /--
  Temporal 4 axiom: `Fφ → FFφ` (temporal transitivity).

  If something will always be true, it will always be true that it will always be true.
  -/
  | temp_4 (φ : Formula) : Axiom ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))

  /--
  Temporal A axiom: `φ → F(sometime_past φ)` (temporal connectedness).

  If something is true now, at all future times there exists a past time where it was true.
  Semantically: if φ at t, then for all s > t, there exists r < s where φ at r (namely, t).

  Note: Uses existential `sometime_past` (¬P¬φ) not universal `past` (Pφ).
  -/
  | temp_a (φ : Formula) : Axiom (φ.imp (Formula.all_future φ.sometime_past))

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
  | temp_l (φ : Formula) : Axiom (φ.always.imp (Formula.all_future (Formula.all_past φ)))

  /--
  Modal-Future axiom: `□φ → □Fφ` (modal-future interaction).

  Necessary truths remain necessary in the future.
  -/
  | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))

  /--
  Temporal-Future axiom: `□φ → F□φ` (temporal-modal interaction).

  Necessary truths will always be necessary.
  -/
  | temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))

end Logos.Core.ProofSystem
