# Research Report: AI System Semantic Requirements Clarification

## Metadata
- **Report ID**: 002-ai-semantic-requirements
- **Date**: 2025-12-09
- **Research Complexity**: 3
- **Status**: Complete
- **Related Context**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md

## Executive Summary

This report addresses misleading claims in the "Formal Logic as Conceptual Engineering" section regarding AI system requirements for precise semantics. The current text incorrectly states that "AI systems require operators with precise computational semantics" as a contrast to human reasoning's tolerance for ambiguity. The actual benefit of precise semantics is not that AI systems inherently require them, but rather that operators with explicit semantic clauses and axiomatic proof theories generate **infinite clean training data** about valid/invalid inferences through dual verification (theorem proving + model checking).

Additionally, the current text incorrectly suggests the normative approach "forsakes context." In reality, formal semantics handles context through **explicit context parameters**: sentences are evaluated at models with context specifications (e.g., tensed sentences require time parameters, modal sentences require world parameters).

## Problem Analysis

### Issue 1: Mischaracterization of AI Requirements (Lines 18-20)

**Current Text**:
> "This engineering perspective has crucial implications for AI reasoning systems. Unlike human reasoning, which can tolerate ambiguity and informal inference, AI systems require operators with precise computational semantics."

**Problems**:
1. AI systems (especially large language models) demonstrably do NOT require operators with precise semantics - they can and do operate on informal natural language
2. The benefit is not about system requirements but about **training data quality**
3. Misses the key insight: formal systems generate verifiable training examples

### Issue 2: Context Handling Misrepresentation (Lines 18-20)

**Current Text** (implicit claim):
The normative approach produces "operators whose meaning is fixed by explicit semantic clauses independent of natural language usage" without acknowledging how context is handled.

**Problems**:
1. Creates false impression that formal semantics ignores context
2. Ignores that formal evaluation requires explicit context parameters
3. Tensed sentences need time specification, modal sentences need world specification
4. Context parameters are the mechanism for handling context-sensitivity

## Research Findings

### Finding 1: Training Data Generation via Dual Verification

Recent advances in AI theorem proving (2025) demonstrate the actual benefit of formal semantics:

**DeepSeek-Prover-V2** (2025): Achieves state-of-the-art performance in neural theorem proving within Lean 4 by generating high-quality synthetic training data through formal verification. The system uses recursive theorem-proving pipeline with DeepSeek-V3 to generate initialization data that is then verified by Lean's type checker.

**Key Insight**: "The entire training strategy relies on synthetic cold-start data, eliminating dependence on manually labeled proofs" ([DeepSeek-Prover-V2](https://arxiv.org/pdf/2504.21801)).

**Aristotle** (2025): Achieves gold-medal-equivalent performance on IMO 2025 by combining formal verification with informal reasoning. The convergent evolution of AI systems suggests "the use of natural language reasoning to decompose problems into simpler subproblems, combined with RL based on formal feedback from a Lean compiler, is a crucial tool for achieving high levels of formal mathematical reasoning" ([Aristotle paper](https://arxiv.org/html/2510.01346v1)).

**Training Data Quality Advantages**:
1. **Consistency**: Soundness proofs prevent deriving contradictions
2. **Verification**: Each proof checked by theorem prover, each countermodel validated by model checker
3. **Scalability**: Infinite examples can be generated systematically
4. **Clean labels**: No human annotation errors or inconsistencies

### Finding 2: Context Parameters in Formal Semantics

Formal semantics handles context through **explicit parameterization**, not by "forsaking" context:

**Kaplan's Two-Tier System**: "Context parameters, differently from index parameters, contribute to fixing semantic values. In one-tier systems, all parameters are alike from the point of view of the compositional semantics. Semantic values are simply functions from context and index parameters to truth values" ([Compositional Semantics research](https://www.redalyc.org/journal/3397/339767296003/html/)).

**Truth Evaluation Structure**: Sentences in formal semantics are evaluated at tuples of parameters:
- **Temporal context**: Evaluation at time `t` for tensed operators (`G`, `F`, `H`, `P`)
- **Modal context**: Evaluation at world `w` for modal operators (`□`, `◇`)
- **Epistemic context**: Evaluation relative to knowledge state `K` for epistemic operators
- **Deontic context**: Evaluation relative to normative ideals for obligation operators

**Compositional Context-Sensitivity**: "The decoded meaning that results from lexicon and syntax alone is not enough to obtain truth-evaluable content for each sentence; it cannot always fix what state of affairs should obtain for a sentence to be true. This is easy to show since natural languages have context-sensitive expressions and their contribution to literal content is only fixed relative to the context in which they are uttered" ([Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/compositionality/)).

Formal semantics addresses this by requiring explicit context specification: `φ` is not simply true/false, but true/false at `(M, w, t, ...)` where `M` is model, `w` is world, `t` is time, etc.

### Finding 3: Normative vs. Descriptive Logic Distinction

The material conditional example in the NOTE tags correctly identifies the normative approach:

**Material Conditional Regimentation**: "It doesn't make sense in English to say that 'if it is raining the sky will fall tomorrow' is true whenever it is not raining" - yet the material conditional `P → Q` (true whenever `P` is false or `Q` is true) is useful for regimentation. The statement "all humans are mammals" can be expressed as `∀x(Human(x) → Mammal(x))` where `→` is material implication.

**Prescriptive Character**: The material conditional "abstracts a concept not found in English, but that is useful for theoretical applications." This is conceptual engineering: stipulating operators with precise truth conditions for systematic reasoning, not describing natural language patterns.

**Bridge Principles**: "A bridge principle takes the form of a material conditional. The conditional's antecedent states 'facts' about logical consequence (or attitudes toward such 'facts'). Its consequent contains a (broadly) normative claim concerning the agent's doxastic attitudes towards the relevant propositions" ([Stanford Encyclopedia - Normative Status of Logic](https://plato.stanford.edu/entries/logic-normative/)).

## Recommendations

### Recommendation 1: Revise AI Requirements Paragraph (Lines 18-20)

**Proposed Revision**:

```markdown
This engineering perspective has crucial implications for AI reasoning systems. The benefit of operators with precise computational semantics is not that AI systems inherently require such precision - language models demonstrably operate on informal natural language patterns. Rather, the benefit lies in **training data generation**: operators with explicit semantic clauses enable dual verification architecture (theorem proving + model checking) that produces infinite clean training data about valid and invalid inferences. Theorem provers like Lean 4 generate verified derivations demonstrating valid inferences, while model checkers like Z3 generate countermodels refuting invalid claims. This dual verification produces consistent, verifiable training examples unavailable from human reasoning patterns, which inevitably contain inconsistencies, errors, and contextual ambiguities. The descriptive approach - formalizing natural language usage patterns - cannot generate such clean training data because natural language reasoning lacks formal verification receipts.
```

**Rationale**:
- Clarifies the actual benefit: training data generation, not system requirements
- References dual verification architecture (already discussed in document)
- Maintains the normative vs. descriptive distinction
- Accurately represents current AI theorem proving research (2025)

### Recommendation 2: Add Context Parameter Clarification

**Proposed Addition** (after the revised paragraph):

```markdown
The normative approach does not forsake context - rather, it makes context **explicit** through formal parameters. Tensed sentences like "it is raining" cannot be evaluated without specifying a time: the sentence is evaluated at model-world-time triple `(M, w, t)` where `t` provides the temporal context. Similarly, modal sentences require world parameters, epistemic sentences require knowledge state parameters, and deontic sentences require normative ideal parameters. This explicit parameterization replaces natural language's implicit context-dependence with systematic context specification. Instead of relying on conversational implicature to determine "when" a tensed claim holds, formal semantics requires explicit time specification. This explicitness enables verification: humans or AI systems can check whether a claim `φ` holds at specific context parameters, providing interpretable verification unavailable when context remains implicit.
```

**Rationale**:
- Directly addresses the NOTE tag concern about context
- Explains how formal semantics handles context-sensitivity
- Connects to interpretability (already mentioned in document line 46)
- Shows explicitness as feature, not limitation

### Recommendation 3: Expand Material Conditional Example (Line 12 NOTE)

**Proposed Revision**:

```markdown
Formal logic serves two fundamentally different purposes. The first, more traditional approach is **descriptive**: analyzing existing patterns of reasoning in natural language to formalize valid argument structures we already employ. The second approach is **normative**: stipulating logical operators fit for systematic applications, particularly in verified AI reasoning systems. This second approach constitutes what we call **conceptual engineering** - the normative science of designing operators we ought to have for rigorous reasoning, not merely describing operators we do have.

Consider the material conditional `→` as paradigm example of conceptual engineering. In natural English, "if P then Q" carries pragmatic implicatures: "if it is raining, the sky will fall tomorrow" strikes us as defective because the antecedent and consequent lack relevant connection. Yet the material conditional - true whenever P is false or Q is true - abstracts away such pragmatic constraints. This abstraction proves theoretically useful: we can regiment "all humans are mammals" as `∀x(Human(x) → Mammal(x))` where `→` is material implication. The material conditional is not a description of English conditionals but a normative stipulation: an operator with precisely defined truth conditions suitable for formal reasoning about generality, even though it diverges from natural language conditional usage.

This normative approach characterizes conceptual engineering generally: stipulating operators with explicit semantic clauses that serve systematic reasoning applications, abstracting away from the inconsistencies and context-dependencies of natural language. Just as material science refines glass from sand or steel from iron ore by transforming raw natural materials into materials fit for building, philosophical logic engineers theoretical concepts from natural language into logical operators with recursive semantic clauses. Natural language provides the raw ingredients: intuitive notions of necessity, possibility, past, future, causation, knowledge, and obligation. These conceptual targets are then refined into precise logical operators with clearly defined truth conditions over explicit semantic models.
```

**Rationale**:
- Incorporates the material conditional example from NOTE tag
- Shows how normative approach works with concrete example
- Maintains the material science analogy (already in document)
- Demonstrates abstraction from natural language patterns

### Recommendation 4: Update Dual Verification Section (Lines 410-429)

**Current text** (lines 410-429) already correctly describes training data generation but should be cross-referenced in the revised paragraph. Add forward reference:

In revised AI requirements paragraph (line 18-20 replacement), add:
```markdown
(For detailed dual verification architecture, see Section "Dual Verification Connection" below.)
```

This creates explicit connection between the corrected claim (training data benefits) and the existing detailed explanation.

## Supporting Evidence

### Evidence 1: State-of-the-Art AI Theorem Proving (2025)

**DeepSeek-Prover-V2 Performance**:
- 88.9% pass rate on MiniF2F-test benchmark (Pass@8192)
- 49/658 problems solved on PutnamBench
- Achieved through synthetic training data from formal verification
- "Cold-start training procedure begins by prompting the DeepSeek-V3 model to decompose complex mathematical theorems into more manageable subgoals" ([DeepSeek announcement](https://www.marktechpost.com/2025/05/01/deepseek-ai-released-deepseek-prover-v2-an-open-source-large-language-model-designed-for-formal-theorem-proving-through-subgoal-decomposition-and-reinforcement-learning/))

**Aristotle IMO Performance**:
- Solved 5/6 formal IMO 2025 problems (gold-medal equivalent)
- Combines three components: Lean proof search, informal reasoning system, dedicated geometry solver
- "Integrates formal verification with informal reasoning" ([Aristotle research](https://www.emergentmind.com/topics/aristotle-imo-level-automated-theorem-proving))

**Key Insight**: Both systems achieve breakthrough performance through formal verification feedback, not through requiring formal input. The benefit is training/feedback loop quality, not system requirements.

### Evidence 2: Compositional Semantics Context Handling

**Principle of Compositionality**: "The meaning of a complex expression is determined by the meanings of its constituent expressions and the rules used to combine them" ([Wikipedia - Compositionality](https://en.wikipedia.org/wiki/Principle_of_compositionality)).

**Context Parameter Requirements**: Natural languages contain indexicals requiring "distinction between two notions of meaning. On the one hand, expressions have a standing meaning fixed by convention and known to those who are linguistically competent. A sentence such as 'I conquered Gaul' is an unambiguous sentence of English. On the other hand, expressions in use are associated with occasion meanings which is discerned by interpreters in part on the basis of contextual information" ([Context-Free Semantics research](https://paolosantorio.net/cfs.draft7.pdf)).

Formal semantics handles this through explicit context parameters in evaluation functions, not by eliminating context.

### Evidence 3: Training Data Quality from Formal Methods

Recent research demonstrates formal methods produce superior training data:

**NuminaMath-LEAN Dataset** (August 2025): "Large-scale collection of approximately 104,000 competition-level mathematics problems formalized in Lean 4. The dataset was created by the research group that developed the Kimina-Prover, with problems drawn from prestigious contests such as the IMO and USAMO" ([Deep Learning for Theorem Proving Survey](https://github.com/zhaoyu-li/DL4TP)).

**Theorem Prover as Judge**: Recent ACL 2025 work titled "Theorem Prover as a Judge for Synthetic Data Generation" demonstrates using formal verification to validate synthetic training examples ([ACL Proceedings](https://aclanthology.org/2025.acl-long.1448.pdf)).

**Quality Characteristics**:
1. Verifiable correctness (each proof checked by type system)
2. No annotation errors (automated generation)
3. Systematic coverage (generated from axiom systems)
4. Scalable production (automated proof search)

## Implementation Notes

### Integration with Existing Document

The proposed revisions maintain consistency with the document's existing structure:

1. **Conceptual Engineering Theme**: Revisions reinforce the normative vs. descriptive distinction central to the document
2. **Material Science Analogy**: Preserved and connected to material conditional example
3. **Dual Verification Architecture**: Cross-referenced to existing detailed section (lines 410-429)
4. **Task Semantics Connection**: Context parameter discussion connects to world-history-time evaluation already defined in document
5. **Layer Architecture**: Context parameter handling relevant for all layers (temporal context in Layer 0, epistemic context in Layer 2, etc.)

### Terminology Alignment

The revisions use terminology consistent with the document:
- "Dual verification architecture" (already used line 44, 412)
- "Clean training data" (already used line 44)
- "Explicit semantic clauses" (already used line 20, 24)
- "Context parameters" (new but standard formal semantics term)
- "Model-world-time triple" (used throughout document for task semantics)

### Cross-References to Add

When implementing revisions, add these cross-references:

1. In revised AI requirements paragraph → forward reference to "Dual Verification Connection" section
2. In context parameter addition → cross-reference to task semantics definition (line 99-108)
3. In material conditional expansion → cross-reference to operator extensibility methodology (line 49-68)

## Conclusion

The current text contains two significant errors:

1. **Mischaracterizes AI benefit**: Claims AI systems "require" precise semantics when the actual benefit is training data generation through dual verification
2. **Implies context neglect**: Fails to explain how formal semantics handles context through explicit parameters

The recommended revisions:
- Accurately represent the training data generation benefit (supported by 2025 AI research)
- Explain explicit context parameterization in formal semantics
- Maintain the document's normative vs. descriptive framework
- Preserve existing structure while correcting misleading claims

These corrections strengthen the document's philosophical argument by accurately representing both the benefits of formal semantics for AI systems and the mechanisms for handling context-sensitivity in formal evaluation.

## Sources

### AI Theorem Proving Research (2025)
- [Formal Mathematical Reasoning: A New Frontier in AI](https://arxiv.org/html/2412.16075v1)
- [DeepSeek-Prover-V2: Advancing Formal Mathematical Reasoning](https://arxiv.org/pdf/2504.21801)
- [DeepSeek Unveils DeepSeek-Prover-V2](https://syncedreview.com/2025/04/30/deepseek-unveils-deepseek-prover-v2-advancing-neural-theorem-proving-with-recursive-proof-search-and-a-new-benchmark/)
- [Aristotle: IMO-level Automated Theorem Proving](https://arxiv.org/html/2510.01346v1)
- [Aristotle: IMO-Level Theorem Prover](https://www.emergentmind.com/topics/aristotle-imo-level-automated-theorem-proving)
- [GitHub - DL4TP: A Survey on Deep Learning for Theorem Proving](https://github.com/zhaoyu-li/DL4TP)
- [Theorem Prover as a Judge for Synthetic Data Generation](https://aclanthology.org/2025.acl-long.1448.pdf)
- [DeepSeek-AI Released DeepSeek-Prover-V2](https://www.marktechpost.com/2025/05/01/deepseek-ai-released-deepseek-prover-v2-an-open-source-large-language-model-designed-for-formal-theorem-proving-through-subgoal-decomposition-and-reinforcement-learning/)

### Compositional Semantics and Context
- [Principle of compositionality - Wikipedia](https://en.wikipedia.org/wiki/Principle_of_compositionality)
- [Context-Free Semantics](https://paolosantorio.net/cfs.draft7.pdf)
- [Compositionality - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/compositionality/)
- [Compositional Semantics Explained](https://www.numberanalytics.com/blog/compositional-semantics-explained-language-logic)
- [Formal semantics (natural language) - Wikipedia](https://en.wikipedia.org/wiki/Formal_semantics_(natural_language))
- [Semantic content and compositional context-sensitivity](https://www.redalyc.org/journal/3397/339767296003/html/)

### Normative Logic and Material Conditional
- [The Normative Status of Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-normative/)
- [Normativity - Wikipedia](https://en.wikipedia.org/wiki/Normativity)
- [In What Sense (If Any) Is Logic Normative for Thought? - John MacFarlane](https://johnmacfarlane.net/normativity_of_logic.pdf)
- [Material conditional - Wikipedia](https://en.wikipedia.org/wiki/Material_conditional)
- [Prescriptive and Descriptive Obligations in Dynamic Logic](https://inria.hal.science/inria-00556080v1/document)
- [Conceptual Norms: Contrasting Theories](https://www.scielo.org.mx/scielo.php?pid=S1405-02182023000100002&script=sci_arttext)

---

## Implementation Status

**Status**: Complete
**Implementation Plan**: 001-conceptual-engineering-note-review-plan.md
**Implementation Date**: 2025-12-09
**Phases Implemented**: Phase 2 (AI Requirements and Modality Type Correction)

All recommendations from this report have been successfully integrated into
CONCEPTUAL_ENGINEERING.md, including:
- Revised AI requirements paragraph to emphasize training data generation rather than
  system requirements
- Added context parameter handling explanation (evaluation at model-world-time triples)
- Explained that formal semantics preserves context through explicit parameters
- Added forward reference to dual verification architecture
- All changes verified with comprehensive testing suite
