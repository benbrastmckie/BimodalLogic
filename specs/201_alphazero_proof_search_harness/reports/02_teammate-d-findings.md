# Teammate D (Horizons) Findings: Corrective Training Signal Integration

**Task**: 201 — AlphaZero-style proof search harness (Round 2: ModelChecker integration)
**Date**: 2026-05-29
**Focus**: Strategic alignment, ModelChecker update strategy, extensibility, publication

---

## Key Findings

### 1. The Dual Signal Is a Genuine Competitive Differentiator

**Confidence**: High

The technical memo's dual verification architecture — proof certificates (positive) + countermodels (corrective) — is not a rhetorical framing. It maps to a concrete and novel training methodology that has no direct competitor:

- **Proof-only systems** (AlphaProof, DeepSeek-Prover, ReProver) train on successful proofs. Failed attempts are simply discarded — the model learns what works but not *why failures fail*.
- **Countermodel systems** (Z3/CVC5 used in verification) exist but are not integrated into theorem-prover training loops.
- **The gap**: No published system combines formal proof certificates with structured countermodels as dual RL signals for training. The closest work is "Learning to Disprove" (arXiv:2603.19514, March 2026), which fine-tunes LLMs to generate counterexamples in Lean 4 — but uses mutation strategies for training data, not a semantic model finder.

The Logos approach is structurally stronger: the ModelChecker doesn't just find *a* counterexample — it constructs an explicit *semantic model* with world histories, task relations, and truth valuations that demonstrate exactly how an inference fails. This structured countermodel is far richer than a bare counterexample.

**Business implication**: For Stage 1 (selling training data to frontier labs), the dual signal is the differentiator. Proof-only data is commoditized — anyone with Lean/Coq can generate it. Structured countermodels paired with proofs are novel and defensible.

### 2. The ModelChecker Is Significantly Outdated — Critical Gaps Identified

**Confidence**: High

Comparing the ModelChecker (Python/Z3) against the ProofChecker (Lean 4) reveals concrete divergences:

| Feature | ProofChecker (Lean 4) | ModelChecker (Python/Z3) |
|---------|----------------------|--------------------------|
| **Primitive operators** | 6: atom, bot, imp, box, untl, snce | 9 primitive + 6 defined; NO Until/Since |
| **Temporal semantics** | Strict/irreflexive (G: `t < s`, H: `s < t`) | Strict (Future: `eval_time < future_time`) — aligned |
| **Temporal primitives** | Until U(φ,ψ), Since S(φ,ψ) are foundational | Only G (Future), H (Past) — no binary temporal operators |
| **Time type** | Polymorphic `D` (Int, Rat, Real) | Fixed integer (`z3.IntSort`) |
| **Frame structure** | `TaskFrame D` with `nullity_identity`, `forward_comp`, `converse` | Simpler: `task` relation, Skolem abundance, but no converse axiom |
| **Axiom system** | 42 BX axiom constructors in 8 layers | No proof system (model checker only) |
| **Frame classes** | 3: Base, Dense, Discrete | 1: effectively discrete (integer times) |
| **World histories** | Convex domain predicate over `D` | Array mapping with interval bounds |
| **Witness predicates** | WitnessRegistry + WitnessConstraintGenerator (Phase 4) | Not present |

**The critical gap is Until/Since**: The ProofChecker's axiom system is built on Burgess-Xu, where Until and Since are primitive temporal operators (22 of 42 axioms involve them). The ModelChecker has no Until/Since at all. This means:
- The ModelChecker cannot generate countermodels for Until/Since formulas
- Training data cannot include the most interesting temporal reasoning patterns
- The majority of the BX axiom system is invisible to the corrective signal

**Secondary gap — frame classes**: The ProofChecker distinguishes Base, Dense, and Discrete frame classes. The ModelChecker operates only with integer times (effectively discrete). Dense-order countermodels cannot be generated.

### 3. Strategic Decision: Update vs. Rebuild

**Confidence**: Medium (depends on engineering assessment)

Three options exist for closing the ModelChecker gap:

**Option A: Update the existing ModelChecker**
- Add Until/Since operators to the bimodal theory
- Add frame class support (Base/Dense/Discrete)
- Maintain Python/Z3 architecture
- *Pro*: Existing infrastructure, display, iteration all work
- *Con*: The ModelChecker is a general-purpose tool with many other theory libraries; changes to bimodal must not break the framework. Maintenance burden of keeping two implementations in sync.
- *Effort*: 2-4 weeks to add Until/Since with correct semantics

**Option B: Build a lightweight countermodel generator**
- Purpose-built Python/Z3 module specifically for training data generation
- Reads formula AST directly from the ProofChecker's Lean output
- Generates countermodels in a format consumable by the training pipeline
- *Pro*: No legacy constraints, can match ProofChecker semantics exactly, no maintenance of general-purpose tool
- *Con*: Duplicates some effort, no pretty-printing/iteration infrastructure
- *Effort*: 3-5 weeks from scratch

**Option C (Recommended): Hybrid — update ModelChecker core, add training-pipeline adapter**
- Update the ModelChecker's bimodal theory to add Until/Since and frame classes (these are semantically well-understood — the Z3 encoding is straightforward given the existing architecture)
- Build a thin adapter layer that converts between ProofChecker formula format and ModelChecker formula format
- Use the ModelChecker's existing model extraction + iteration infrastructure
- Export structured countermodels in a training-ready format (JSON with world histories, truth valuations, task relations)
- *Pro*: Leverages both codebases, ModelChecker improvements benefit other users too, adapter isolates format differences
- *Con*: Requires coordination across two repos
- *Effort*: 3-4 weeks total

### 4. The Countermodel Is More Than a Negative Signal

**Confidence**: High

The technical memo frames countermodels as "corrective feedback" — but they can serve multiple training functions:

**a. Structured negative signal (corrective RL)**
When the prover attempts an invalid inference φ₁,...,φₙ ⊢ ψ, the countermodel provides:
- A concrete semantic model where all premises are true and the conclusion is false
- The world histories that witness the failure
- The specific time point and world state where the inference breaks

This is far richer than a binary "wrong" signal. The model can learn *which structural features of a formula lead to failure*.

**b. Proof guidance via semantic hints**
For valid inferences, the *failure to find a countermodel* confirms provability. But attempted (failed) countermodel construction can reveal:
- Which subformulas are the "hard" part (those that resist countermodel construction)
- What structural properties the model finder had to give up (abundance, uniqueness, etc.)
- This could guide the prover toward the productive parts of the search space

**c. Adversarial training**
Generate formulas that are "almost valid" — minor mutations of theorems that become invalid. The countermodel shows exactly how the mutation breaks the inference. Train the prover to distinguish valid from near-miss invalid formulas.

**d. Curriculum design**
Countermodel complexity (number of worlds, time points, task transitions) provides a natural difficulty metric. Simple countermodels = easy invalidity; complex countermodels = subtle invalidity. This enables principled curriculum learning.

### 5. Extensibility to the Full Logos

**Confidence**: Medium

The technical memo describes the full Logos with counterfactual, causal, epistemic, and normative operators. Design decisions now that affect extensibility:

**Architecture decisions that enable extensibility:**
- The ModelChecker's modular design (semantics class + operator collection) already supports adding new operators. Until/Since is the first test case.
- The training pipeline adapter (Option C) should be operator-agnostic: it converts formula ASTs and extracts model structures, regardless of which operators are present.
- The countermodel export format should use a generic structure: `{worlds: [...], times: [...], relations: [...], valuations: [...], counterexample_point: {...}}` — this generalizes to any modal/temporal/hyperintensional logic.

**Architecture decisions that could break extensibility:**
- Hardcoding the formula type to bimodal TM's 6 constructors. The adapter must be parameterized by the operator set.
- Assuming integer times. The full Logos may need rational or real-valued times for dense orders.
- Assuming a single modal accessibility relation (S5). Epistemic/deontic operators need separate accessibility relations.

**Recommendation**: Design the training data format now with the full Logos in mind. The bimodal TM pipeline is the MVP, but the data schema should accommodate additional operators, multiple accessibility relations, and dense/continuous time.

### 6. Publication Strategy

**Confidence**: High

The dual verification training signal is publishable as a standalone contribution, independent of the full AlphaZero harness. Recommended framing:

**Primary paper**: "Dual Verification for Neural Theorem Proving: Proof Certificates and Countermodels as Complementary Training Signals"
- Venue: ICML, NeurIPS, or ICLR (ML track) — or CADE/TABLEAUX (logic track)
- Contribution: First system to combine formal proof certificates (positive RL signal) with structured semantic countermodels (corrective signal) for neural theorem proving
- Baseline comparison: proof-only training vs. dual training on the bimodal TM benchmark
- The "Learning to Disprove" paper (March 2026) establishes that counterexample training is valuable; the Logos contribution is providing *semantic* countermodels (structured models, not just witnesses) from a decision procedure

**Secondary paper**: "Semantic Countermodels as Curriculum for Logical Reasoning"
- Use countermodel complexity as a difficulty metric for curriculum learning
- Show that structured countermodel feedback produces better generalization than binary right/wrong signals
- This is a novel contribution — no existing work uses model-theoretic countermodels for curriculum design

**Key differentiator from "Learning to Disprove"**: That paper uses *syntactic mutation* to generate counterexample training data (discard hypotheses from valid theorems). The Logos approach uses *semantic model construction* — Z3 builds an explicit model witnessing invalidity. The semantic approach:
- Produces more diverse counterexamples (not limited to hypothesis deletion)
- Provides richer training signal (full model structure, not just a witness term)
- Works on unprovable formulas directly (no need for a valid starting theorem to mutate)

## Strategic Recommendations

1. **Prioritize Until/Since in the ModelChecker** before any training pipeline work. Without these operators, the corrective signal covers only a fraction of the proof system's expressiveness.

2. **Adopt Option C (hybrid update + adapter)**. Update the ModelChecker's bimodal theory, build a format adapter, and export training-ready countermodels.

3. **Design the training data format for the full Logos** even though the MVP is bimodal TM. Use a generic schema that accommodates additional operators.

4. **Target the dual verification paper** as the first publication from this work. It's novel, the infrastructure exists (task 203's formula enumerator + ModelChecker + ProofChecker), and it establishes the Logos brand in the ML-for-theorem-proving community.

5. **Don't delay the bimodal pipeline for the full Logos**. The bimodal TM fragment is publication-worthy on its own. Extensibility is a design constraint, not a scope expansion.

6. **Consider the countermodel as a first-class training artifact**, not just a negative signal. Structured countermodels enable curriculum learning, adversarial training, and semantic proof guidance — each independently publishable.

## Creative Approaches

### Dueling Networks Architecture
Train two competing systems:
- **Prover network**: Attempts to prove formulas in the BX proof system
- **Refuter network**: Attempts to construct countermodels via the ModelChecker

The refuter provides targeted adversarial training data for the prover. When the prover attempts an invalid inference, the refuter shows exactly why it fails. When the prover succeeds on a valid inference, the refuter's failure confirms the proof.

This is structurally analogous to GANs but for logical reasoning — and it's the *only* domain where both sides have formal verification (Lean for proofs, Z3 for countermodels).

### Semantic Embedding of Countermodels
Instead of treating countermodels as binary "wrong" signals:
- Embed the countermodel's structure (world count, time intervals, task relation graph) into a vector
- Use this as an auxiliary input to the proof search network
- The model learns to recognize which structural features of formulas lead to which kinds of countermodels
- This provides geometric intuition about the space of valid/invalid inferences

### Cross-Verification Confidence Scoring
For formulas near the provability boundary:
- If Z3 times out (no countermodel found) but the prover also fails → uncertain
- If Z3 finds a countermodel quickly → definitely invalid, high-confidence negative signal
- If the prover succeeds quickly → definitely valid, high-confidence positive signal
- Countermodel construction time provides a natural uncertainty measure

## References

- "Learning to Disprove: Formal Counterexample Generation with Large Language Models" (arXiv:2603.19514, March 2026)
- "ExVerus: Verus Proof Repair via Counterexample Reasoning" (arXiv:2603.25810, 2026)
- "Efficient PRM Training Data Synthesis via Formal Verification" (arXiv:2505.15960, 2025)
- LeanProgress (2025) — proof progress prediction for neural theorem proving
- Aristotle (Harmonic Team, 2025) — AND/OR proof search
