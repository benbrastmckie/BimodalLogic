# Research Report: Task #849

**Task**: 849 - add_contextual_parameters_section_to_dynamics
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:15:00Z
**Effort**: Low-medium (focused content extraction and adaptation)
**Dependencies**: None
**Sources/Inputs**:
- `Theories/Logos/docs/research/conceptual-engineering.md` (lines 17-26 primary, 17-165 supporting)
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` (target file)
- `Theories/Logos/latex/subfiles/01-Introduction.tex` (style reference)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The conceptual-engineering.md document contains a dedicated "Contextual Parameters" section (lines 17-26) that directly addresses the task requirements
- The DynamicsFoundation.tex file currently lacks introductory material explaining why contextual parameters are needed and how operators determine them
- The new section should be placed immediately after the opening paragraph of Section 3 (Dynamical Foundation), before "Additional Syntactic Primitives"
- Writing style should match Introduction.tex: clear expository prose, one sentence per line, precise technical vocabulary

## Context & Scope

### Task Requirements

The task requires adding a new section at the beginning of `03-DynamicsFoundation.tex` that:
1. Explains how contextual parameters are determined by the logical operators included in the language
2. Draws content from the conceptual-engineering.md research document
3. Maintains the clear and precise tone of the Introduction file

### Constraints

- Must integrate with existing document structure
- Must follow LaTeX conventions (semantic linefeeds, notation macros)
- Content must be relevant to the Dynamical Foundation specifically (not general conceptual engineering)

## Findings

### Source Content Analysis: conceptual-engineering.md

The **Contextual Parameters** section (lines 17-26) contains the core content needed:

#### Key Passage (lines 17-23)

> Logic describes inferences that hold in general, independent of the content or context of the claims involved. This generality is achieved by abstracting over two dimensions: the interpretation of non-logical symbols in the language (given by a semantic model) and the contextual parameters required to assign truth-values to sentences. For instance, there is no saying whether "Jon has won over three races" is true without specifying a time at which to evaluate this claim, as well as specifying who Jon is and what suffices for winning a race. The truth-value may vary by time or by who "Jon" picks out. The semantic model interprets the non-logical vocabulary, while the contextual parameters fix the circumstances of evaluation.

#### Key Passage (lines 21-23)

> Which contextual parameters must be provided is a function of which operators the language includes. For instance, including tense operators requires that times be included among the contextual parameters, since the truth of `Hφ` ("`φ` has been the case") depends on the time of evaluation. Similarly, historical modal operators require world-histories as parameters, and epistemic operators require agent-relative information states.

#### Key Passage (lines 23-24)

> The Logos language, proof systems, and semantic clauses are designed to be modular and extensible. Applications can import just the necessary operators and their associated contextual parameters, while further additions can be successively incorporated to expand the expressive power of the language. This modularity ensures that the semantic overhead scales with actual reasoning requirements: applications using only propositional logic need no contextual parameters beyond interpretation, while applications requiring temporal reasoning add times, and applications requiring multi-agent epistemic reasoning add agent-indexed accessibility relations.

### Supporting Context from conceptual-engineering.md

The **Planning Under Uncertainty** section (lines 25-165) provides supporting context about why tense and modal operators are foundational for planning. Key points:

1. **Plans as temporal evolutions** (lines 31-38): Planning requires representing alternative temporal evolutions and evaluating them at specific times
2. **Tense operators for temporal structure** (lines 38-50): `G`, `F`, `H`, `P` represent temporal evolution within world-histories
3. **Modal operators for alternative possibilities** (lines 38-50): Modal operators represent alternative world-histories for comparison
4. **Bimodal integration** (lines 134-153): TM logic combines temporal and modal dimensions

### Target File Analysis: 03-DynamicsFoundation.tex

#### Current Structure

1. **Section header** (line 8): `\section{Dynamical Foundation}\label{sec:dynamical-foundation}`
2. **Opening paragraph** (lines 10-13): Brief overview of Dynamical Foundation extending Constitutive Foundation
3. **Subsection 3.1** (line 18): Additional Syntactic Primitives
4. Following subsections: Well-Formed Sentences, Derived Operators, etc.

#### Current Opening Paragraph Content

The existing opening (lines 10-13) mentions:
- Extension with temporal and modal structure
- Task relation parameterized by durations
- Truth evaluation relative to world-history and time
- Intensional layer for contingent and temporary sentences

#### Gap Analysis

The current opening paragraph does NOT explain:
- Why contextual parameters are needed for truth evaluation
- How the choice of operators determines which parameters are required
- The modularity principle (semantic overhead scales with reasoning requirements)
- Concrete examples of operator-to-parameter relationships

### Style Analysis: 01-Introduction.tex

The Introduction file demonstrates the target writing style:

#### Sentence Structure
- One sentence per line (semantic linefeeds)
- Clear topic sentences introducing concepts
- Concrete examples following abstract principles
- Technical precision without jargon

#### Tone Characteristics
- Expository and explanatory rather than argumentative
- Third-person perspective
- Active voice preferred
- Definitions introduced with italics (e.g., `\textit{ameliorative approach}`)

#### Example Passage (lines 36-42)
```latex
Natural language semantics in linguistics is \textit{descriptive}, analyzing how expressions like ``if...then'' behave in languages such as English.
By contrast, formal logic is \textit{normative}, aiming to engineer the logical operators that are fit for systematic reasoning by stipulating precise semantic clauses and proof systems.
Logical operators are expected to diverge from natural language usage by abstracting conceptual targets from organically occurring semantic meanings.

The material conditional exemplifies this approach.
A material conditional $\phi \to \psi$ is true whenever its antecedent is false or its consequent is true.
```

## Recommendations

### Section Placement

Insert new subsection **immediately after the opening paragraph** (after line 13) and **before the Additional Syntactic Primitives subsection** (before line 15).

Rationale:
- Contextual parameters explanation provides conceptual foundation for understanding why the primitives are needed
- Follows the pattern of Introduction.tex which presents conceptual motivation before technical details
- Creates logical flow: motivation -> primitives -> syntax -> semantics

### Recommended Section Title

`\subsection{Contextual Parameters}\label{sec:contextual-parameters}`

This matches the section title in conceptual-engineering.md and is descriptive of the content.

### Content Outline

The new section should include:

1. **Opening paragraph**: Logic describes general inferences by abstracting over interpretation and contextual parameters
2. **Operator-parameter relationship**: Which parameters are required depends on which operators the language includes
3. **Examples paragraph**: Concrete examples of operator-to-parameter relationships
   - Tense operators require times
   - Modal operators require world-histories
   - (Reference to epistemic operators requiring agent-relative states as future extension)
4. **Modularity paragraph**: Semantic overhead scales with reasoning requirements

### Writing Guidelines

1. **Adapt, don't copy verbatim**: The source is written for a research document; the target is a reference manual
2. **Use LaTeX notation macros**: Replace ASCII symbols (`φ`, `Hφ`) with LaTeX macros (`$\metaphi$`, `$\allpast\metaphi$`)
3. **Maintain precision**: Preserve technical accuracy while improving accessibility
4. **One sentence per line**: Follow semantic linefeed convention
5. **Cross-reference appropriately**: Reference the Constitutive Foundation and upcoming sections where relevant

### Estimated Length

Approximately 3-4 paragraphs (15-25 lines of LaTeX source), matching the density of the Introduction's Conceptual Engineering subsection.

## Decisions

1. **Placement decision**: New content goes BEFORE "Additional Syntactic Primitives" (not after Truth Conditions or at end of file)
2. **Scope decision**: Focus on tense and modal operators specifically, with brief forward reference to epistemic extensions
3. **Depth decision**: Provide enough conceptual foundation without duplicating the detailed semantics that follows
4. **Style decision**: Match Introduction.tex tone rather than the more academic tone of conceptual-engineering.md

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| New section disrupts document flow | Low | Medium | Place before technical content; test reading flow |
| Content too similar to Introduction | Low | Low | Focus on Dynamical Foundation specifics |
| LaTeX build errors | Low | High | Test compilation after implementation |
| Missing notation macros | Low | Medium | Use existing macros from logos-notation.sty |

## Appendix

### Key Quotes from Source for Adaptation

1. "Logic describes inferences that hold in general, independent of the content or context of the claims involved."

2. "This generality is achieved by abstracting over two dimensions: the interpretation of non-logical symbols in the language (given by a semantic model) and the contextual parameters required to assign truth-values to sentences."

3. "Which contextual parameters must be provided is a function of which operators the language includes."

4. "Including tense operators requires that times be included among the contextual parameters, since the truth of `Hφ` depends on the time of evaluation."

5. "Applications can import just the necessary operators and their associated contextual parameters, while further additions can be successively incorporated to expand the expressive power of the language."

### LaTeX Notation Reference

| Concept | Source notation | LaTeX macro |
|---------|-----------------|-------------|
| Formula variable | φ | `$\metaphi$` |
| "Always past" | Hφ | `$\allpast\metaphi$` |
| "Sometime past" | Pφ | `$\somepast\metaphi$` |
| "Always future" | Gφ | `$\allfuture\metaphi$` |
| "Sometime future" | Fφ | `$\somefuture\metaphi$` |
| Necessity | □φ | `$\nec\metaphi$` |
| Possibility | ◇φ | `$\poss\metaphi$` |

### File References

- Source: `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/conceptual-engineering.md`
- Target: `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
- Style reference: `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/01-Introduction.tex`
