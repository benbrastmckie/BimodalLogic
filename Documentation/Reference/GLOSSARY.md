# Terminology Glossary

This glossary maps terminology between Logos and Logos documentation, providing definitions for key concepts and operators.

## Layer Architecture

| Term | Definition | Related Terms |
|------|------------|---------------|
| Layer 0 | Core TM logic with Boolean, modal, and temporal operators | Core Layer, TM logic |
| TM logic | Bimodal logic combining Tense (temporal) and Modality (modal) operators | Layer 0, Core Layer |
| Layer 1 | Explanatory extension with counterfactual, constitutive, causal operators | Explanatory Extension |
| Layer 2 | Epistemic extension with belief, probability, knowledge operators | Epistemic Extension |
| Layer 3 | Normative extension with obligation, permission, preference operators | Normative Extension |
| Core Layer | Foundation layer (Layer 0) providing Boolean, modal, temporal reasoning | Layer 0 |
| Extension Layer | Additional operator layers (1-3) building on Core Layer | Layers 1-3 |
| Progressive Extension | Methodology enabling incremental addition of operator layers | Layer Architecture |

## Boolean Operators (Layer 0)

| Symbol | Name | Definition | Aliases |
|--------|------|------------|---------|
| `¬` | Negation | Logical "not" operator | not |
| `∧` | Conjunction | Logical "and" operator | and |
| `∨` | Disjunction | Logical "or" operator | or |
| `→` | Implication | Material conditional "if...then" | implies, imp |
| `↔` | Biconditional | "If and only if" | iff |
| `⊥` | Falsity | Logical constant false | bot, bottom |
| `⊤` | Truth | Logical constant true | top |

## Modal Operators (Layer 0)

| Symbol | Name | Definition | Aliases |
|--------|------|------------|---------|
| `□` | Necessity | "It is necessary that" (metaphysical necessity) | box |
| `◇` | Possibility | "It is possible that" (dual of necessity) | diamond |
| `Ca` | Ability | "Is able to" or "has the capacity to" | can |

**S5 Modal Logic**: Logos implements S5 axioms (MT, M4, MB) ensuring reflexivity, transitivity, and symmetry for modal accessibility relation.

## Temporal Operators (Layer 0)

| Symbol | Name | Function Name | Definition | Aliases |
|--------|------|---------------|------------|---------|
| `H` | All Past | `all_past` | "It always has been the case that" (universal past) | - |
| `P` | Some Past | `some_past` | "It has been the case that" (existential past) | - |
| `G` | All Future | `all_future` | "It is always going to be the case that" (universal future) | always |
| `F` | Some Future | `some_future` | "It is going to be the case that" (existential future) | - |
| `△` | Always | `always` | "It is always the case that" (universal temporal, henceforth) | triangle_always |
| `▽` | Sometimes | `sometimes` | "It is sometimes the case that" (existential temporal, eventually) | triangle_sometimes |

**Note**: `△A := HA ∧ A ∧ GA` (held at all past times, holds now, will hold at all future times)

**Note**: `▽A := PA ∨ A ∨ FA` (held at some past time, holds now, or will hold at some future time)

**LEAN Code Mapping**:
- `H φ` → `Formula.all_past φ` (universal past, primitive)
- `P φ` → `some_past φ` (existential past, derived via `¬(all_past ¬φ)`)
- `G φ` → `Formula.all_future φ` (universal future, primitive)
- `F φ` → `some_future φ` (existential future, derived via `¬(all_future ¬φ)`)

## Bimodal Interaction (Layer 0)

| Term | Definition | Related Axioms |
|------|------------|----------------|
| Modal persistence | Necessity persists through time | MF, TF |
| Temporal perpetuity | What is always true remains always true | TL |
| Perpetuity principles | Theorems connecting modal and temporal operators (P1-P6) | See Theorems section |

## Explanatory Operators (Layer 1 - Planned)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `□→` | Would Counterfactual | "If it were...then it would" | Counterfactual reasoning |
| `◇→` | Might Counterfactual | "If it were...then it might" | Counterfactual reasoning |
| `≤` | Grounding | "A is sufficient for B" or "A grounds B" | Constitutive reasoning |
| `⊑` | Essence | "A is necessary for B" or "A is essential to B" | Constitutive reasoning |
| `≡` | Identity | "A just is B" (propositional identity) | Constitutive reasoning |
| `≼` | Relevance | "A is wholly relevant to B" | Constitutive reasoning |
| `○→` | Causation | Productive causal relationships | Causal reasoning |

## Epistemic Operators (Layer 2 - Planned)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `B` | Belief | "Agent a believes that A" | Belief modeling |
| `Pr` | Probability | Probability quantification | Uncertainty reasoning |
| `Mi` | Might (epistemic) | "It might be the case that A" | Epistemic modality |
| `Mu` | Must (epistemic) | "It must be the case that A" | Epistemic modality |
| `⟹` | Indicative Conditional | "If...then" under actual beliefs | Conditional reasoning |

## Normative Operators (Layer 3 - Planned)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `O` | Obligation | "It is obligatory that A" | Deontic logic |
| `P` | Permission | "It is permitted that A" | Deontic logic |
| `≺` | Preference | "A is preferred over B" | Preference reasoning |
| `⟼` | Normative Explanation | Normative grounding | Normative reasoning |

## Verification Concepts

| Term | Definition | Related Components |
|------|------------|-------------------|
| Dual Verification | Complementary syntactic and semantic verification | Proof-checker, Model-checker |
| Proof Receipt | LEAN-generated certificate of proof validity | Syntactic verification |
| Counterexample | Z3-generated semantic model showing invalidity | Semantic verification |
| Syntactic Verification | Proof construction via LEAN | Proof-checker |
| Semantic Verification | Model checking via Z3 | Model-checker |
| Task Semantics | Possible worlds as functions from times to states | Semantic framework |
| Task Frame | Structure with world states, times, task relation | Semantic model |
| World History | Function from convex time sets to world states | Semantic structure |

## Implementation Terms

| Term | Definition | Related Documentation |
|------|------------|----------------------|
| Derivable | Inductive relation defining proof derivability | ProofSystem/Derivation.lean |
| Axiom | Axiom schema in TM logic (8 total) | ProofSystem/Axioms.lean |
| Inference Rule | Derivation rule (7 total) | ProofSystem/Derivation.lean |
| Soundness | `Γ ⊢ φ → Γ ⊨ φ` (provable implies valid) | Metalogic/Soundness.lean |
| Completeness | `Γ ⊨ φ → Γ ⊢ φ` (valid implies provable) | Metalogic/Completeness.lean |
| Perpetuity Principles | Theorems P1-P6 connecting modal and temporal | Theorems/Perpetuity.lean |
| Canonical Model | Model constructed from maximal consistent sets | Completeness proof |

## Theorems and Principles

| Name | Statement | Interpretation |
|------|-----------|----------------|
| P1 | `□φ → △φ` | What is necessary is always the case |
| P2 | `▽φ → ◇φ` | What is sometimes the case is possible |
| P3 | `□φ → □△φ` | Necessity of perpetuity |
| P4 | `◇▽φ → ◇φ` | Possibility of occurrence |
| P5 | `◇▽φ → △◇φ` | Persistent possibility |
| P6 | `▽□φ → □△φ` | Occurrent necessity is perpetual |

## Axioms (Layer 0)

| Name | Statement | Purpose |
|------|-----------|---------|
| MT (Modal T) | `□φ → φ` | Necessity implies truth (reflexivity) |
| M4 (Modal 4) | `□φ → □□φ` | Positive introspection (transitivity) |
| MB (Modal B) | `φ → □◇φ` | Symmetry |
| T4 (Temporal 4) | `Gφ → GGφ` | Temporal transitivity (all_future iterates) |
| TA (Temporal A) | `φ → G(Pφ)` | Temporal accessibility (now will have been) |
| TL (Temporal L) | `△φ → G(Hφ)` | Temporal perpetuity (always implies future all-past) |
| MF (Modal-Future) | `□φ → □Gφ` | Modal persistence (necessary implies necessarily all-future) |
| TF (Temporal-Future) | `□φ → G□φ` | Temporal persistence of necessity (necessary remains necessary) |

## Status Information

For all implementation status information, see [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md).

## Related Documentation

- [METHODOLOGY.md](../UserGuide/METHODOLOGY.md) - Philosophical foundations
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Layer 0 technical specification
- [OPERATORS.md](OPERATORS.md) - Formal symbols reference
- [Research/LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) - Layers 1-3 specifications

---

_Last updated: December 2025_
