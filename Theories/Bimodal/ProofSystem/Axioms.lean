import Bimodal.Syntax.Formula

/-!
# Axioms - TM Axiom Schemata

This module defines the 15 axiom schemata for bimodal logic TM (Tense and Modality).

## Main Definitions

- `Axiom`: Inductive type characterizing valid axiom instances
- 17 axiom constructors: `prop_k`, `prop_s`, `ex_falso`, `peirce`, `modal_t`, `modal_4`,
  `modal_b`, `modal_5_collapse`, `modal_k_dist`, `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`,
  `temp_t_future`, `temp_t_past`, `modal_future`, `temp_future`, `temp_linearity`

## Axiom Schemata

The TM logic includes:

### Propositional Axioms
- **K** (Propositional K): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution axiom
- **S** (Propositional S): `φ → (ψ → φ)` - weakening axiom
- **EFQ** (Ex Falso Quodlibet): `⊥ → φ` - from absurdity, anything follows
- **Peirce** (Peirce's Law): `((φ → ψ) → φ) → φ` - classical implication principle

**Note**: Double Negation Elimination (`¬¬φ → φ`) is derivable from EFQ + Peirce
(see `Bimodal.Theorems.Propositional.double_negation`).

### S5 Modal Axioms (metaphysical necessity □)
- **MT** (Modal T): `□φ → φ` - what is necessary is true (reflexivity)
- **M4** (Modal 4): `□φ → □□φ` - necessary truths are necessarily necessary (transitivity)
- **MB** (Modal B): `φ → □◇φ` - truths are necessarily possible (symmetry)
- **MK** (Modal K Distribution): `□(φ → ψ) → (□φ → □ψ)` - necessity distributes over implication

### Temporal Axioms (future G, past H)
- **TK** (Temporal K Distribution): `G(φ → ψ) → (Gφ → Gψ)` - future distributes over implication
- **T4** (Temporal 4): `Gφ → GGφ` - future of future is future (transitivity)
- **TA** (Temporal A): `φ → GPφ` - the present was in the past of the future
- **TL** (Temporal L): `always φ → GPφ` - perpetuity implies recurrence
- **TT-G** (Temporal T Future): `Gφ → φ` - what is always future is true now (reflexivity)
- **TT-H** (Temporal T Past): `Hφ → φ` - what has always been is true now (reflexivity)

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

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Axiom schemata for bimodal logic TM.

A formula `φ` is an axiom if it matches one of the 15 axiom schema patterns.
Each constructor takes formula parameters representing the schema instantiation.
-/
inductive Axiom : Formula → Type where
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
  Ex Falso Quodlibet (EFQ): `⊥ → φ` (explosion principle).

  From absurdity (`⊥`), anything can be derived. This axiom directly characterizes
  what `bot` means: if we have reached a contradiction, we can derive any formula.

  This is the fundamental principle that distinguishes absurdity from other formulas.
  Since `bot` is primitive in our syntax and `neg` is derived (`¬φ = φ → ⊥`), this
  axiom directly states what the primitive `bot` means.

  This axiom is accepted in both classical and intuitionistic logic. It provides
  the semantic content of the absurdity symbol without imposing classical reasoning.

  Semantically: In classical two-valued logic, `⊥` is false at all models, so the
  implication `⊥ → φ` is vacuously true (false antecedent). In task semantics,
  `truth_at M τ t ht Formula.bot = False`, so the implication is valid.

  **Historical Note**: Also called the "principle of explosion" (Latin: *ex falso
  [sequitur] quodlibet*, "from falsehood, anything [follows]").
  -/
  | ex_falso (φ : Formula) : Axiom (Formula.bot.imp φ)

  /--
  Peirce's Law: `((φ → ψ) → φ) → φ` (classical implication principle).

  Pure implicational classical reasoning. If assuming that (φ implies ψ) leads
  to φ, then φ holds. This is the characteristic axiom that distinguishes
  classical from intuitionistic logic in purely implicational form.

  This axiom is equivalent to the Law of Excluded Middle (LEM) and Double
  Negation Elimination (DNE) in the presence of other propositional axioms,
  but it expresses classical reasoning using only implication, without
  mentioning negation or disjunction.

  Semantically: Valid in classical logic where every formula is either true
  or false at each model-history-time triple. The semantic proof uses case
  analysis: if φ is false, then φ → ψ is vacuously true (false antecedent),
  so from (φ → ψ) → φ we get φ, contradicting the assumption that φ is false.
  Therefore φ must be true.

  **Historical Note**: Named after the American philosopher Charles Sanders Peirce
  (1839-1914), who studied this principle in his work on the logic of relations.
  -/
  | peirce (φ ψ : Formula) : Axiom (((φ.imp ψ).imp φ).imp φ)

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
  -/
  | modal_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))

  /--
  Temporal K Distribution axiom: `F(φ → ψ) → (Fφ → Fψ)` (distribution).

  Future distributes over implication. If it will always be the case that φ implies ψ,
  then if φ will always be true, ψ will also always be true.

  This is the temporal analog of modal K distribution. It is the fundamental axiom
  of normal temporal logics. It enables combining future formulas: from `⊢ Fφ` and
  `⊢ Fψ`, we can derive `⊢ F(φ ∧ ψ)` by first deriving `⊢ F(φ → (ψ → φ∧ψ))` via
  temporal necessitation, then applying this axiom twice.

  Semantically: if (φ → ψ) holds at all future times, and φ holds at all future
  times, then ψ must hold at all future times.

  This axiom is sound in task semantics due to the linear temporal structure.
  -/
  | temp_k_dist (φ ψ : Formula) :
      Axiom ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))

  /--
  Temporal 4 axiom: `Fφ → FFφ` (temporal transitivity).

  If something will always be true, it will always be true that it will always be true.
  -/
  | temp_4 (φ : Formula) :
    Axiom ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))

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
  Temporal T axiom for future: `Gφ → φ` (temporal reflexivity).

  If something will always be true (from now on), it is true now.
  This makes G reflexive: G includes the present moment.
  Semantically: if φ holds at all times s ≥ t, then φ holds at t.

  This axiom, together with `temp_t_past`, enables the coherence proofs
  for the canonical model construction by providing a local constraint
  connecting Gφ to φ within a single MCS.
  -/
  | temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)

  /--
  Temporal T axiom for past: `Hφ → φ` (temporal reflexivity).

  If something has always been true (until now), it is true now.
  This makes H reflexive: H includes the present moment.
  Semantically: if φ holds at all times s ≤ t, then φ holds at t.

  This axiom, together with `temp_t_future`, enables the coherence proofs
  for the canonical model construction by providing a local constraint
  connecting Hφ to φ within a single MCS.
  -/
  | temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)

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

  /--
  Temporal Linearity axiom: `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`
  (future-directedness / linear time).

  If two formulas both hold at some future time, then either they coincide, or
  one precedes the other. This axiom characterizes linear temporal order and is
  sound for the intended linear integer time semantics.

  Semantically: given witnesses s1 ≥ t for φ and s2 ≥ t for ψ, either s1 = s2
  (first disjunct), s1 ≤ s2 (second disjunct), or s2 ≤ s1 (third disjunct).
  This trichotomy holds because D is linearly ordered.

  **Technical Debt (Task 922)**: This axiom extends the TM system to enforce
  linearity of the temporal order. It is sound for linear integer time (the
  intended semantics) but was not part of the original axiom set. It is required
  for the canonical quotient completeness proof because the original TM axioms
  do not derive linearity -- a branching-time frame satisfying all other TM axioms
  exists as a counterexample. Remediation: derive from existing axioms if possible,
  or document as a permanent axiom of TM.

  **References**:
  - Goldblatt 1992, *Logics of Time and Computation* (Kt.Li axiomatization)
  - Blackburn, de Rijke, Venema 2001, *Modal Logic* (frame correspondence)
  - Task 922 research-001.md, research-002.md (linearity analysis)
  -/
  | temp_linearity (φ ψ : Formula) :
      Axiom (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
        (Formula.or (Formula.some_future (Formula.and φ ψ))
          (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
            (Formula.some_future (Formula.and (Formula.some_future φ) ψ)))))
  deriving Repr

end Bimodal.ProofSystem
