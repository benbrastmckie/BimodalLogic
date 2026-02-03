# Research Report: Task #847

**Task**: 847 - restructure_constitutive_semantics_section
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:15:00Z
**Effort**: Low
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, web research on truthmaker semantics
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- The TODO at line 307-308 requests creating a new "Constitutive Semantics" section with an introduction explaining bilateral exact truthmaker semantics and hyperintensionality
- The remark at lines 311-326 should be moved/adapted into this introduction
- Current semantic clause subsubsections (Atomic Formulas through Propositional Identity) are already at the correct nesting level and should remain subsubsections under a new subsection
- The restructuring requires inserting a `\subsection{Constitutive Semantics}` with proper introduction before the existing subsubsections

## Context and Scope

### Task Requirements (from line 307-308)

The TODO comment specifies:
> make the following remark the introduction to a new section called Constitutive Semantics which explains that this is a bilateral exact truthmaker semantics which is hyperintensional insofar as it distinguishes necessarily equivalent sentences that differ in subject-matter before presenting all of the semantic clauses for the primitive operators included in the language in the subsubsection of this new section after the introduction.

### Current Document Structure

The document `02-ConstitutiveFoundation.tex` is organized as follows:

```
\section{Constitutive Foundation}
  \subsection{Syntactic Primitives}
  \subsection{Term Algebra}
  \subsection{Well-Formed Formulas}
  \subsection{Derived Operators}
  \subsection{Constitutive Frame}
  \subsection{State Modality Definitions}
  \subsection{Task Relation Constraints}
  \subsection{Constitutive Model}
  \subsection{Variable Assignment}
  [Lines 303-309: TODO comment and label]
  [Lines 311-326: Remark on Hyperintensional Semantics]
    \subsubsection{Atomic Formulas}
    \subsubsection{Lambda Abstraction}
    \subsubsection{Universal Quantification}
    \subsubsection{Top Constant}
    \subsubsection{Bottom Constant}
    \subsubsection{Negation}
    \subsubsection{Conjunction}
    \subsubsection{Disjunction}
    \subsubsection{Propositional Identity}
  \subsection{Essence and Ground}
  \subsection{Bilateral Propositions}
  \subsection{Constitutive Consequence}
```

### Key Observation

The semantic clauses (lines 328-466) are already formatted as `\subsubsection` entries.
They are currently orphaned without a parent `\subsection`.
The restructuring adds the missing `\subsection{Constitutive Semantics}` parent.

## Findings

### What is Bilateral Exact Truthmaker Semantics?

Bilateral exact truthmaker semantics is a framework developed primarily by Kit Fine that provides a more fine-grained approach to semantics than traditional possible-worlds semantics.

**Key characteristics:**

1. **Truthmakers and Falsemakers**: Unlike standard semantics that only tracks truth conditions, bilateral semantics independently specifies:
   - **Verifiers** (truthmakers): States that make a statement true
   - **Falsifiers** (falsemakers): States that make a statement false

2. **Exactness**: A state is an *exact* truthmaker only if it is "wholly relevant" to the truth of the sentence. A state that verifies "Anna is knitting" would not count if it also contains irrelevant information like "Lily is sleeping."

3. **State-based rather than world-based**: Instead of evaluating sentences at possible worlds (maximal, complete descriptions of reality), truthmaker semantics evaluates at partial states that may be incomplete.

4. **Bilateral structure**: Verification and falsification are independent dimensions. A state that fails to verify a formula is distinct from a state that falsifies it. This independence is crucial for maintaining relevance through logical operations.

**Formal structure:**
- A **unilateral proposition** is a set of states P that are closed under fusion
- A **bilateral proposition** is a pair (P+, P-) where P+ is the set of verifiers and P- is the set of falsifiers
- Negation swaps verifiers and falsifiers: neg P = (P-, P+)

### What is Hyperintensionality?

Hyperintensionality refers to the ability to distinguish between propositions that have the same *intension* (truth value at every possible world) but differ in some other semantic property.

**Classical example:**
- "It is raining or not raining" (necessarily true)
- "It is snowing or not snowing" (necessarily true)

In possible-worlds semantics, these have the same meaning (both true in all worlds). But intuitively, they are *about* different things: one is about rain, the other about snow.

**How truthmaker semantics captures hyperintensionality:**

The exact verifiers of these sentences differ:
- "Raining or not raining" is verified by rain-states and their absence
- "Snowing or not snowing" is verified by snow-states and their absence

This difference in verifiers captures their difference in **subject-matter** even though they have identical truth-conditions.

**Consequences for the Logos system:**

The document already notes (lines 315-323):
1. **Finer grain than intensions**: Necessarily equivalent sentences may have different verifiers
2. **Bilateral structure**: Both verification and falsification conditions are specified independently
3. **Non-monotonicity**: Verification is exact - extending a verifier with irrelevant content destroys verification

### The Remark to be Adapted (Lines 311-326)

The existing remark provides much of the needed content:

```latex
\begin{remark}[Hyperintensional Semantics]\label{rem:hyperintensional-semantics}
The bilateral semantic clauses for \emph{verification} ($\verifies$) and
\emph{falsification} ($\falsifies$) form the core of the hyperintensional semantics.
Unlike intensional semantics that evaluate sentences at a context which includes
the necessary parameters to assign truth-values, verification and falsification
evaluate formulas relative to \emph{states} that are wholly relevant to their
truth or falsity.
...
```

This remark should be:
1. Converted from a remark to an introduction paragraph
2. Expanded to explicitly name "bilateral exact truthmaker semantics"
3. Enhanced to explain the relation to Kit Fine's work and state-based semantics

### Proposed Section Structure

```
\subsection{Constitutive Semantics}\label{sec:constitutive-semantics}

[Introduction paragraphs explaining:]
- This section presents bilateral exact truthmaker semantics
- Explains what bilateral means (independent verifiers and falsifiers)
- Explains what exact means (wholly relevant states)
- Explains hyperintensionality (distinguishes necessarily equivalent sentences)
- States that the clauses define verification/falsification recursively

\subsubsection{Atomic Formulas}
\subsubsection{Lambda Abstraction}
\subsubsection{Universal Quantification}
\subsubsection{Top Constant}
\subsubsection{Bottom Constant}
\subsubsection{Negation}
\subsubsection{Conjunction}
\subsubsection{Disjunction}
\subsubsection{Propositional Identity}
```

### Draft Introduction Text

Based on the research, here is a draft introduction for the new section:

```latex
\subsection{Constitutive Semantics}\label{sec:constitutive-semantics}

The constitutive semantics for the Logos is a \emph{bilateral exact truthmaker
semantics} in the tradition of Kit Fine.
This framework evaluates formulas relative to partial states rather than
complete possible worlds, yielding a hyperintensional logic that distinguishes
necessarily equivalent sentences differing in subject-matter.

The semantics is \emph{bilateral} in that it independently specifies both
verification ($\verifies$) and falsification ($\falsifies$) conditions for
each formula.
A state verifies a formula just in case it makes the formula true;
a state falsifies a formula just in case it makes it false.
These are independent dimensions:
a state that fails to verify a formula need not falsify it,
and negation exchanges verifiers and falsifiers while preserving relevance.

The semantics is \emph{exact} in that verifiers and falsifiers must be
\emph{wholly relevant} to the truth or falsity they ground.
A state containing extraneous content---information irrelevant to why the
formula holds---does not count as an exact verifier.
This exactness makes verification and falsification non-monotonic:
extending a verifier with irrelevant material destroys verification.

This bilateral exactness yields \emph{hyperintensionality}:
the ability to distinguish propositions that agree in truth-value across all
possibilities but differ in what they are about.
For instance, ``It is raining or not raining'' and ``It is snowing or not
snowing'' are both necessary truths, verified at all possible worlds in
intensional semantics.
Yet they have different exact verifiers---rain-states versus snow-states---
reflecting their difference in subject-matter.

The clauses below define verification and falsification recursively for each
syntactic form relative to a model $\model$, assignment $\assignment$, and
state $s$.
```

## Implementation Recommendations

### Structural Changes

1. **Insert new subsection** after line 302 (after Variable Assignment subsection ends):
   ```latex
   \subsection{Constitutive Semantics}\label{sec:constitutive-semantics}
   ```

2. **Remove the TODO comment** at lines 307-308

3. **Remove or adapt the remark** at lines 311-326:
   - The content should be incorporated into the new introduction
   - The label `\label{sec:verification-falsification}` at line 309 should be kept or updated to `sec:constitutive-semantics`

4. **Preserve subsubsection structure**: The existing subsubsections (Atomic Formulas through Propositional Identity) are already at the correct level and need no changes

### Label Updates

Consider whether to:
- Keep `sec:verification-falsification` as an alias
- Update cross-references throughout the document
- The main label should be `sec:constitutive-semantics`

### Style Considerations

- Follow semantic linefeeds (one sentence per line)
- Use established macros: `\verifies`, `\falsifies`, `\model`, `\assignment`, etc.
- Maintain consistency with existing document tone and notation

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking cross-references | Search for all uses of `sec:verification-falsification` before removing |
| Introduction too long | Keep to 4-5 paragraphs maximum |
| Missing semantic concepts | The current remark content covers key points; draft expands appropriately |
| Style inconsistency | Follow existing document patterns for introductory text |

## Appendix

### Search Queries Used

1. "bilateral exact truthmaker semantics Kit Fine philosophy"
2. "hyperintensional semantics truthmaker subject-matter Fine"
3. "exact truthmaker bilateral verifier falsifier definition semantics"

### Key References

- Fine, K. "Truthmaker Semantics" (survey paper)
- Fine, K. and Jago, M. (Forthcoming). *An Introduction to Truthmaker Semantics*, Oxford University Press
- Fine, K. "A Theory of Truthmaker Content II: Subject-matter"
- Champollion, L. (2025). "Truthmaker Semantics and Natural Language Semantics" in *Language and Linguistics Compass*

### Document Line References

| Content | Lines |
|---------|-------|
| TODO comment | 307-308 |
| Label for section | 309 |
| Hyperintensional Semantics remark | 311-326 |
| Atomic Formulas subsubsection | 328-335 |
| Lambda Abstraction subsubsection | 337-352 |
| Universal Quantification subsubsection | 354-365 |
| Top Constant subsubsection | 367-379 |
| Bottom Constant subsubsection | 381-393 |
| Negation subsubsection | 395-407 |
| Conjunction subsubsection | 409-429 |
| Disjunction subsubsection | 431-448 |
| Propositional Identity subsubsection | 450-465 |
