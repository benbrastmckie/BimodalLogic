# Terminology Glossary

This glossary maps terminology between Logos and Logos documentation, providing definitions for key concepts and operators.

## Layer Architecture

The Logos is organized into five semantic layers, each building upon the previous with increasing expressive power. See [LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) for full details and [RECURSIVE_SEMANTICS.md](../Research/RECURSIVE_SEMANTICS.md) for formal semantics.

| Term | Definition | Related Terms |
|------|------------|---------------|
| Constitutive Layer | Foundation layer with hyperintensional semantics over mereological state spaces | State space, Parthood, Bilateral proposition |
| Causal Layer | Intensional semantics with modal, temporal, and counterfactual operators | World-history, Task relation, TM logic |
| Epistemic Layer | Extensions for belief, knowledge, and probability operators | Credence function, Epistemic modality |
| Normative Layer | Extensions for obligation, permission, and preference operators | Value ordering, Deontic logic |
| Agential Layer | Extensions for multi-agent reasoning | Agent-relative accessibility |
| TM logic | Bimodal logic combining Tense (temporal) and Modality (modal) operators | Causal Layer |
| Progressive Extension | Methodology enabling incremental addition of operator layers | Layer Architecture |
| Semantic Progression | Each layer's frame includes all structure from previous layers | Layer Architecture |

## Boolean Operators (Constitutive/Causal Layer)

| Symbol | Name | Definition | Aliases |
|--------|------|------------|---------|
| `¬` | Negation | Logical "not" operator | not |
| `∧` | Conjunction | Logical "and" operator | and |
| `∨` | Disjunction | Logical "or" operator | or |
| `→` | Implication | Material conditional "if...then" | implies, imp |
| `↔` | Biconditional | "If and only if" | iff |
| `⊥` | Falsity | Logical constant false | bot, bottom |
| `⊤` | Truth | Logical constant true | top |

## Modal Operators (Causal Layer)

| Symbol | Name | Definition | Aliases |
|--------|------|------------|---------|
| `□` | Necessity | "It is necessary that" (metaphysical necessity) | box |
| `◇` | Possibility | "It is possible that" (dual of necessity) | diamond |
| `Ca` | Ability | "Is able to" or "has the capacity to" | can |

**S5 Modal Logic**: Logos implements S5 axioms (MT, M4, MB) ensuring reflexivity, transitivity, and symmetry for modal accessibility relation.

## Temporal Operators (Causal Layer)

| Symbol | Name | Function Name | Definition | Aliases |
|--------|------|---------------|------------|---------|
| `H` | All Past | `all_past` | "It always has been the case that" (universal past) | - |
| `P` | Some Past | `some_past` | "It has been the case that" (existential past) | - |
| `G` | All Future | `all_future` | "It is always going to be the case that" (universal future) | always |
| `F` | Some Future | `some_future` | "It is going to be the case that" (existential future) | - |
| `△` | Always | `always` | "It is always the case that" (universal temporal, at all times) | triangle_always |
| `▽` | Sometimes | `sometimes` | "It is sometimes the case that" (existential temporal, at some time) | triangle_sometimes |

**Note**: `△A := HA ∧ A ∧ GA` (held at all past times, holds now, will hold at all future times)

**Note**: `▽A := PA ∨ A ∨ FA` (held at some past time, holds now, or will hold at some future time)

**LEAN Code Mapping**:
- `H φ` → `Formula.all_past φ` (universal past, primitive)
- `P φ` → `some_past φ` (existential past, derived via `¬(all_past ¬φ)`)
- `G φ` → `Formula.all_future φ` (universal future, primitive)
- `F φ` → `some_future φ` (existential future, derived via `¬(all_future ¬φ)`)

## Bimodal Interaction (Causal Layer)

| Term | Definition | Related Axioms |
|------|------------|----------------|
| Modal persistence | Necessity persists through time | MF, TF |
| Temporal perpetuity | What is always true remains always true | TL |
| Perpetuity principles | Theorems connecting modal and temporal operators (P1-P6) | See Theorems section |

## Constitutive Operators (Constitutive Layer)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `≡` | Propositional Identity | "A just is B" (identical verifiers and falsifiers) | Hyperintensional reasoning |
| `≤` | Grounding | "A is sufficient for B" or "A grounds B" | Constitutive reasoning |
| `⊑` | Essence | "A is necessary for B" or "A is essential to B" | Constitutive reasoning |
| `≼` | Relevance | "A is wholly relevant to B" | Constitutive reasoning |

## Causal Operators (Causal Layer)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `□→` | Would Counterfactual | "If it were...then it would" (mereological semantics) | Counterfactual reasoning |
| `◇→` | Might Counterfactual | "If it were...then it might" | Counterfactual reasoning |
| `○→` | Causation | Productive causal relationships | Causal reasoning |
| `↑ⁱ` | Store | Store current time in register i | Temporal reference |
| `↓ⁱ` | Recall | Evaluate at stored time i | Temporal reference |

## Extended Tense Operators (Causal Layer)

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `S` | Since | "A since B" (A has held since B was true) | Temporal reasoning |
| `U` | Until | "A until B" (A holds until B becomes true) | Temporal reasoning |

## Epistemic Operators (Epistemic Layer)

[DETAILS: Full semantic specifications pending]

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `B_a` | Belief | "Agent a believes that A" | Belief modeling |
| `K_a` | Knowledge | "Agent a knows that A" | Epistemic modality |
| `Pr` | Probability | Probability quantification (Pr(A) ≥ θ) | Uncertainty reasoning |
| `Mi` | Might (epistemic) | "It might be the case that A" | Epistemic modality |
| `Mu` | Must (epistemic) | "It must be the case that A" | Epistemic modality |
| `⟹` | Indicative Conditional | "If...then" under actual beliefs | Conditional reasoning |

## Normative Operators (Normative Layer)

[DETAILS: Full semantic specifications pending]

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `O` | Obligation | "It is obligatory that A" | Deontic logic |
| `P` | Permission | "It is permitted that A" | Deontic logic |
| `≺_a` | Preference | "Agent a prefers B to A" | Preference reasoning |
| `↦` | Normative Explanation | "A grounds obligation B" | Normative reasoning |

## Constitutive Layer Concepts

| Term | Definition | Related Terms |
|------|------------|---------------|
| State Space | Complete lattice ⟨S, ⊑⟩ of states ordered by parthood | Constitutive frame |
| Parthood | Mereological relation ⊑ ordering states | State space |
| Null State | Bottom element □ of the state lattice (fusion of empty set) | State space |
| Full State | Top element ■ of the state lattice (fusion of all states) | State space |
| Fusion | Least upper bound s.t of states s and t | State space, Mereology |
| Compatibility | States s and t are compatible iff their fusion is possible | State space |
| Verification | Relation between states and formulas (s ⊩⁺ A) | Hyperintensional semantics |
| Falsification | Relation between states and formulas (s ⊩⁻ A) | Hyperintensional semantics |
| Bilateral Proposition | Ordered pair ⟨V, F⟩ of verifier and falsifier states | Hyperintensional semantics |
| Hyperintensional Semantics | Semantics distinguishing propositions with same truth-value profile | Constitutive Layer |

## Causal Layer Concepts

| Term | Definition | Related Terms |
|------|------------|---------------|
| Task Relation | Three-place relation ⇒ constraining state transitions with nullity and compositionality | Causal frame |
| World-state | Maximal possible state | Causal Layer |
| World-history | Function τ from convex time set to world-states respecting task relation | Causal frame |
| Temporal Order | Totally ordered abelian group D = ⟨D, +, ≤⟩ of times | Causal frame |
| Convex Time Set | Time interval without gaps | World-history |

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

## Axioms (Causal Layer)

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
- [ARCHITECTURE.md](../UserGuide/ARCHITECTURE.md) - Technical specification
- [OPERATORS.md](OPERATORS.md) - Formal symbols reference
- [LAYER_EXTENSIONS.md](../Research/LAYER_EXTENSIONS.md) - Five-layer architecture overview
- [RECURSIVE_SEMANTICS.md](../Research/RECURSIVE_SEMANTICS.md) - Full formal semantic specifications

---

_Last updated: January 2026_
