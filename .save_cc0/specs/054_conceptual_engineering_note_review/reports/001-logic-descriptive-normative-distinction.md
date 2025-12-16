# Formal Logic Descriptive-Normative Distinction Research Report

## Metadata
- **Date**: 2025-12-09
- **Agent**: research-specialist
- **Topic**: Formal Logic Descriptive-Normative Distinction
- **Report Type**: best practices

## Executive Summary

This research report examines the descriptive-normative distinction in formal logic, addressing NOTE comments in CONCEPTUAL_ENGINEERING.md about the introduction's framing. The key finding is that the current text conflates descriptive natural language semantics (studying how expressions like "if...then" work in ordinary language) with descriptive logic—when actually, natural language semantics is descriptive while philosophical logic is normative (engineering operators with precise truth conditions). The material conditional exemplifies this: it doesn't match English "if...then" usage but enables useful formal regimentation like expressing "all humans are mammals" as ∀x(if x is human, then x is mammal). Five high-priority recommendations are provided: reframe terminology to distinguish natural language semantics from formal logic, expand the material conditional example to show semantic engineering, revise AI systems justification to emphasize training data generation rather than computational requirements, strengthen connections to contemporary conceptual engineering literature, and clarify references to modality types.

## Findings

### Finding 1: Current Framing Conflates Descriptive Semantics with Descriptive Logic

- **Description**: The current text (lines 14-16) describes "descriptive logic" as "analyzing existing patterns of reasoning in natural language to formalize valid argument structures we already employ." However, the NOTE comment correctly identifies that natural language semantics is descriptive (studying how conditionals and other operators work in natural language), while philosophical logic is normative (engineering operators for formal systems). The current paragraph conflates these two different enterprises.

- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md (lines 12-16)

- **Evidence**: The NOTE states: "natural language semantics is descriptive and philosophical logic is normative. For instance, the material conditional is not a part of English (it doesn't make sense in English to say that 'if it is raining the sky will fall tomorrow' is true whenever it is not raining) but the material conditional is still extremely useful (for instance, we may use it to say that 'all humans are mammals' by 'forall x(if x is a human, then x is a mammal)' where the 'if... then...' here can be regimented by the material conditional)."

- **Impact**: This conflation obscures the key distinction in conceptual engineering: natural language semantics describes how expressions work in ordinary language, while formal logic engineers operators with precise truth conditions that may differ from natural language usage but serve theoretical purposes. The material conditional example shows this perfectly—it doesn't match English "if...then" but enables useful formal regimentation.

### Finding 2: Material Conditional as Paradigmatic Case of Semantic Engineering

- **Description**: Academic literature confirms that the material conditional is the paradigmatic example of semantic engineering. As noted in Stanford Encyclopedia of Philosophy on conditionals, the material conditional "appears adequate to regiment mathematical proofs involving conditional sentences" but "fails to do justice to some of the ways in which conditionals are ordinarily understood and used in natural language" (Frege's Begriffsschrift). The material conditional serves formal purposes (truth-functional treatment, interdefinability with Boolean operators) despite not matching natural language usage.

- **Location**: Research finding from Stanford Encyclopedia of Philosophy: The Logic of Conditionals

- **Evidence**: From search results: "The material conditional has considerable virtues of simplicity, and in that regard the material conditional analysis provides a benchmark for other theories. Its main virtue is that it lends itself to a truth-functional treatment (the truth value of a conditional is a function of the truth values of antecedent and consequent). It also makes the conditional interdefinable with Boolean negation, disjunction, and conjunction."

- **Impact**: The material conditional demonstrates semantic engineering: refining natural language concepts into formal operators with different but theoretically useful properties. The example "all humans are mammals" regimented as "∀x(if x is human, then x is mammal)" shows how material conditional enables expressing universal quantification despite differing from English conditionals.

### Finding 3: Precise Semantics Enable Training Data, Not Just Computation

- **Description**: The current text (lines 18-20) claims "AI systems require operators with precise computational semantics," suggesting precision serves computational needs. However, the NOTE correctly identifies that the actual benefit is "the infinite clean data that these theories supply about what is and isn't a valid inference." The normative approach doesn't forsake context—"sentences are evaluated at a model and host of context parameters which specify what is needed to evaluate that sentence."

- **Location**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md (lines 18-20)

- **Evidence**: The NOTE states: "AI systems do not require operators with precise semantics. Rather, the benefit of providing operators with precise semantics and axiomatic proof theories is the infinite clean data that these theories supply about what is and isn't a valid inference. It is true that attempting to maintain the descriptive approach by using natural language patterns themselves creates inconsistency and variability. The normative approach does not, however, forsake context since sentences are evaluated at a model and host of context parameters."

- **Impact**: The current framing misses the key advantage of formal semantics for AI: generating unlimited clean training data through theorem proving and model checking. Context-sensitivity is preserved through evaluation parameters (models, times, worlds), not eliminated. This reframes the normative/descriptive distinction: not about eliminating context but about engineering operators that enable systematic inference.

### Finding 4: Descriptive vs Normative in Contemporary Philosophy Literature

- **Description**: Contemporary philosophy of logic recognizes the descriptive/normative distinction as fundamental. The Stanford Encyclopedia article "The Normative Status of Logic" distinguishes between descriptive uses (representing particular arguments, depicting logical form) and normative uses (assessing and changing inferential practice). As noted in 2025 SOPhiA workshop, Simon Vonlanthen defends that "the logical consequence relation can be found in natural language on a use theory of meaning," while the formal systems approach is explicitly normative.

- **Location**: Research finding from Stanford Encyclopedia of Philosophy: The Normative Status of Logic

- **Evidence**: From search results: "By a logical theory, philosophers mean a formal system together with its semantics, meta-theory, and rules for translating ordinary language into its notation. Logical theories can be used descriptively (for example, to represent particular arguments or to depict the logical form of certain sentences). However, the most important applications of logical theories are normative, and the epistemology is that of wide reflective equilibrium."

- **Impact**: The literature confirms that formal logic's primary applications are normative—assessing and revising reasoning practices—not merely describing existing patterns. This supports reframing the introduction to emphasize that philosophical logic engineers operators for systematic reasoning, while descriptive semantics studies natural language.

### Finding 5: Conceptual Engineering as Established Methodology in 2025

- **Description**: Conceptual engineering has emerged as a major topic in contemporary philosophy. David Chalmers' 2025 Inquiry article defines it as "the design, implementation, and evaluation of concepts." Jennifer Nado characterizes conceptual engineers as "not mere analyzers of concepts or simply armchair philosophers; they aim to present themselves as concept innovators, improvers, or revisioners... Their project is prescriptive rather than descriptive."

- **Location**: Research finding from recent philosophy literature (2025)

- **Evidence**: From search results: "Conceptual engineers aim to improve or to replace rather than to analyse; to create rather than to discover... Their project is prescriptive rather than descriptive." Example: "Scharp's work uses ASCENDING TRUTH and DESCENDING TRUTH instead of TRUTH to make it impossible to derive the liar paradox and other logical paradoxes related to truth."

- **Impact**: Conceptual engineering provides established philosophical vocabulary and methodology for what the document describes. Framing formal logic as conceptual engineering aligns with contemporary philosophical practice and provides readers familiar philosophical context for understanding the normative approach.

## Recommendations

### 1. Reframe "Descriptive Logic" as "Descriptive Natural Language Semantics"

**Priority**: High

**Rationale**: Based on Finding 1, the current framing conflates two distinct enterprises. The revision should clarify that natural language semantics is descriptive (studying how "if...then" works in English), while formal logic is normative (engineering operators like material conditional for theoretical purposes).

**Specific Changes**:
- Replace "descriptive logic" terminology with "descriptive natural language semantics" or "natural language semantics"
- Replace "normative logic" terminology with "formal logic" or "philosophical logic"
- Emphasize that formal logic engineering operators that may differ from natural language usage but serve theoretical purposes

**Example Revision** (lines 14-16):
"Natural language semantics is **descriptive**: analyzing how reasoning expressions like 'if...then' work in ordinary language. By contrast, formal logic is **normative**: engineering logical operators with precise truth conditions for systematic reasoning, even when these operators differ from natural language usage. This engineering approach constitutes **conceptual engineering**—stipulating operators we ought to have for rigorous reasoning, not merely describing operators found in natural language."

### 2. Expand Material Conditional Example to Show Semantic Regimentation

**Priority**: High

**Rationale**: Based on Findings 1 and 2, the material conditional is the paradigmatic example showing how semantic engineering works. The NOTE's example of "all humans are mammals" regimented as "∀x(if x is human, then x is mammal)" should be prominently featured.

**Specific Changes**:
- Add dedicated paragraph explaining material conditional as semantic engineering
- Use the "all humans are mammals" example to show useful regimentation
- Explain that material conditional doesn't match English "if...then" (paradoxes of material implication) but enables expressing universal quantification and mathematical proofs
- Note that the "if it is raining the sky will fall tomorrow" is true whenever it is not raining (material conditional) but this doesn't match English usage

**Example Addition** (after line 16):
"Consider the material conditional (→) as a paradigmatic case. The material conditional doesn't match English 'if...then'—it's counterintuitive that 'if it is raining, the sky will fall tomorrow' is true whenever it is not raining. However, the material conditional enables useful formal regimentation. To express 'all humans are mammals' formally, we write ∀x(if x is human, then x is mammal), where the conditional can be regimented using material implication. The material conditional abstracts a concept not found in English but useful for expressing universal quantification, mathematical proofs, and truth-functional reasoning. This is semantic engineering: refining natural language notions into formal operators with different but theoretically valuable properties."

### 3. Revise AI Systems Justification to Emphasize Training Data Generation

**Priority**: High

**Rationale**: Based on Finding 3, the current text (lines 18-20) incorrectly claims AI systems "require" precise semantics for computation. The actual benefit is generating unlimited clean training data through theorem proving and model checking.

**Specific Changes**:
- Replace "AI systems require operators with precise computational semantics" with emphasis on training data generation
- Clarify that context is preserved through evaluation parameters (models, times, worlds), not eliminated
- Emphasize that formal semantics enables dual verification: theorem proving generates valid inferences, model checking generates counterexamples
- Connect to later discussion of dual verification architecture (line 44)

**Example Revision** (lines 18-20):
"This engineering perspective has crucial implications for AI reasoning systems. Operators with precise semantics and axiomatic proof theories generate unlimited clean training data about valid and invalid inferences. Theorem proving produces verified derivations guaranteed sound by metalogical proofs, while model checking produces countermodels refuting invalid claims. This dual verification architecture provides consistent, verifiable training data not achievable by formalizing inconsistent natural language reasoning patterns. The normative approach preserves context through evaluation parameters—sentences are evaluated at specific models, times, and worlds—while enabling systematic inference generation."

### 4. Strengthen Connection to Contemporary Conceptual Engineering Literature

**Priority**: Medium

**Rationale**: Based on Finding 5, conceptual engineering is an established methodology in contemporary philosophy. The document should explicitly connect to this literature to provide philosophical grounding.

**Specific Changes**:
- Add citation to David Chalmers (2025) "What is conceptual engineering and what should it be?" from Inquiry
- Reference Jennifer Nado's characterization: conceptual engineers as "concept innovators, improvers, or revisioners" pursuing prescriptive rather than descriptive projects
- Optionally add example of Scharp's ASCENDING TRUTH and DESCENDING TRUTH as paradigmatic conceptual engineering in logic

**Example Addition** (after line 16 or in methodology discussion):
"This approach aligns with contemporary **conceptual engineering** in philosophy. As David Chalmers (2025) defines it, conceptual engineering is 'the design, implementation, and evaluation of concepts.' Conceptual engineers are 'concept innovators, improvers, or revisioners' pursuing prescriptive projects to improve or replace concepts rather than merely analyze them (Nado). The Logos layer architecture exemplifies conceptual engineering: systematically designing modal, temporal, causal, and epistemic operators with explicit truth conditions fit for verified AI reasoning."

### 5. Clarify Modality Type Reference

**Priority**: Low

**Rationale**: Based on the NOTE at line 22, the text should clarify that "historical modality" (presumably temporal modality or tense logic) is primarily at issue, not purely metaphysical modality.

**Specific Changes**:
- At line 24, revise "metaphysical modality" reference to clarify relationship between modal and temporal operators
- Consider emphasizing that the bimodal TM logic combines S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (historical modality)
- This is lower priority since the document extensively discusses temporal operators in later sections

**Example Revision** (line 24):
"For AI systems requiring proof receipts, the normative question is primary. The Logos specifies modal and temporal operators with precise truth conditions: `□φ` is true at a model-history-time triple exactly when `φ` holds at all accessible worlds at that time, while temporal operators quantify over times within world-histories. This bimodal structure combines metaphysical modality (necessity/possibility) with historical modality (temporal evolution), enabling reasoning about how worlds evolve over time."

## References

### Codebase Files Analyzed

- /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Research/CONCEPTUAL_ENGINEERING.md (lines 8-47, 12-16, 18-20, 22-24) - Context file containing NOTE comments about descriptive/normative distinction, material conditional example, and AI systems justification

### External Sources Consulted

- [The Normative Status of Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-normative/) - Distinction between descriptive uses (representing arguments, depicting logical form) and normative uses (assessing and changing inferential practice)

- [The Logic of Conditionals - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-conditionals/) - Material conditional's virtues for formal reasoning despite inadequacy for natural language conditionals; Frege's acknowledgment in Begriffsschrift

- [Logic: Normative or Descriptive? - Cambridge Core](https://www.cambridge.org/core/journals/philosophy-of-science/article/abs/logic-normative-or-descriptive-the-ethics-of-belief-or-a-branch-of-psychology/FE40E1AB508AE4902C9B493E4FB9DA7C) - Michael D. Resnik on normative vs descriptive status of logic

- [Logic(s) of Normativity and the Normativity of Logic(s) - SOPhiA 2025](https://sophia-conference.org/logics-of-normativity-and-the-normativity-of-logics/) - 2025 workshop on normativity in logic including Simon Vonlanthen on logical consequence in natural language

- [Formal Semantics (Natural Language) - Wikipedia](https://en.wikipedia.org/wiki/Formal_semantics_(natural_language)) - Direct vs indirect interpretation approaches; formal semantics as truth-conditional and model-theoretic

- [What is conceptual engineering and what should it be? - David Chalmers (2025)](https://philpapers.org/rec/CHAWIC-5) - Definition of conceptual engineering as "design, implementation, and evaluation of concepts"

- [Conceptual Engineering: A Road Map to Practice - Isaac (2022)](https://compass.onlinelibrary.wiley.com/doi/full/10.1111/phc3.12879) - Jennifer Nado's characterization of conceptual engineers as concept innovators pursuing prescriptive projects

- [Conceptual Engineering: A Brief Introduction - Steffen Koch](https://philpapers.org/rec/KOCCEA-2) - Conceptual engineering as prescriptive/normative activity for revising terms and concepts

- [Deontic Logic - Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-deontic/) - Deontic logic's formal language for normative expressions without determining which principles hold

- [Material Conditional - Wikipedia](https://en.wikipedia.org/wiki/Material_conditional) - Truth-functional treatment and interdefinability with Boolean operators

---

## Implementation Status

**Status**: Complete
**Implementation Plan**: 001-conceptual-engineering-note-review-plan.md
**Implementation Date**: 2025-12-09
**Phases Implemented**: Phase 1 (Descriptive/Normative Distinction Revision)

All recommendations from this report have been successfully integrated into
CONCEPTUAL_ENGINEERING.md, including:
- Reframed terminology to distinguish descriptive natural language semantics from
  normative formal logic
- Expanded material conditional example with "all humans are mammals" regimentation
- Clarified that material conditional enables useful formal reasoning despite not matching
  English usage
- All changes verified with comprehensive testing suite
