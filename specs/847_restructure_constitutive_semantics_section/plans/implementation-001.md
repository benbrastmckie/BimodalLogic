# Implementation Plan: Task #847

- **Task**: 847 - restructure_constitutive_semantics_section
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/847_restructure_constitutive_semantics_section/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Restructure the semantic clauses in `02-ConstitutiveFoundation.tex` by creating a new `\subsection{Constitutive Semantics}` with an introduction explaining bilateral exact truthmaker semantics.
The existing remark at lines 311-326 will be transformed into introduction prose, the TODO comment will be removed, and the orphaned subsubsections (Atomic Formulas through Propositional Identity) will become properly nested children of the new subsection.

### Research Integration

Research report provides:
- Complete draft introduction text explaining bilateral exact truthmaker semantics in Kit Fine's tradition
- Line references: TODO (307-308), label (309), remark (311-326), subsubsections (328+)
- Key concepts to cover: bilateral (independent verifiers/falsifiers), exact (wholly relevant states), hyperintensionality (distinguishes necessarily equivalent sentences by subject-matter)

## Goals & Non-Goals

**Goals**:
- Create `\subsection{Constitutive Semantics}` with proper label
- Add introduction explaining bilateral exact truthmaker semantics
- Remove TODO comment at lines 307-308
- Remove the formal remark block while preserving its content in the new introduction
- Maintain subsubsection structure for semantic clauses

**Non-Goals**:
- Modifying the semantic clause content itself
- Changing cross-references to `sec:verification-falsification` (preserve as alias)
- Restructuring other parts of the document

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing cross-references | M | L | Keep `sec:verification-falsification` label as alias |
| Introduction too long/verbose | L | L | Keep to 4-5 paragraphs as in research draft |
| Style inconsistency | L | L | Follow semantic linefeed conventions and existing document tone |

## Implementation Phases

### Phase 1: Restructure Constitutive Semantics Section [NOT STARTED]

**Goal**: Replace TODO comment and remark with proper subsection structure and introduction

**Tasks**:
- [ ] Remove TODO comment at lines 307-308
- [ ] Replace the remark block (lines 311-326) with new subsection header and introduction
- [ ] Insert `\subsection{Constitutive Semantics}\label{sec:constitutive-semantics}` with introduction prose
- [ ] Keep `\label{sec:verification-falsification}` as secondary label for backward compatibility
- [ ] Verify subsubsections remain properly nested under new subsection

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Insert subsection with introduction, remove TODO and remark

**Edits**:

1. Remove TODO comment (line 307):
   - Delete: `% TODO: make the following remark...` (entire multi-line comment)

2. Replace lines 309-326 (label + remark) with:
```latex
\subsection{Constitutive Semantics}\label{sec:constitutive-semantics}
\label{sec:verification-falsification}% backward compatibility

The constitutive semantics for the Logos is a \emph{bilateral exact truthmaker semantics} in the tradition of Kit Fine.
This framework evaluates formulas relative to partial states rather than complete possible worlds,
yielding a hyperintensional logic that distinguishes necessarily equivalent sentences differing in subject-matter.

The semantics is \emph{bilateral} in that it independently specifies both verification ($\verifies$) and falsification ($\falsifies$) conditions for each formula.
A state verifies a formula just in case it makes the formula true;
a state falsifies a formula just in case it makes it false.
These are independent dimensions:
a state that fails to verify a formula need not falsify it,
and negation exchanges verifiers and falsifiers while preserving relevance.

The semantics is \emph{exact} in that verifiers and falsifiers must be \emph{wholly relevant} to the truth or falsity they ground.
A state containing extraneous content---information irrelevant to why the formula holds---does not count as an exact verifier.
This exactness makes verification and falsification non-monotonic:
extending a verifier with irrelevant material destroys verification.

This bilateral exactness yields \emph{hyperintensionality}:
the ability to distinguish propositions that agree in truth-value across all possibilities but differ in what they are about.
For instance, ``It is raining or not raining'' and ``It is snowing or not snowing'' are both necessary truths,
verified at all possible worlds in intensional semantics.
Yet they have different exact verifiers---rain-states versus snow-states---reflecting their difference in subject-matter.

The clauses below define verification and falsification recursively for each syntactic form relative to a model $\model$, assignment $\assignment$, and state $s$.
```

**Verification**:
- [ ] Build document with `pdflatex` to verify no errors
- [ ] Verify subsection appears in document structure
- [ ] Verify subsubsections (Atomic Formulas, etc.) are nested under new subsection
- [ ] Grep for `sec:verification-falsification` to ensure any references still resolve

---

## Testing & Validation

- [ ] Document compiles without errors: `cd Theories/Logos/latex && pdflatex LogosReference.tex`
- [ ] New "Constitutive Semantics" subsection appears in table of contents
- [ ] All semantic clause subsubsections are properly nested
- [ ] No orphaned TODO comments remain in the section
- [ ] Cross-references to `sec:verification-falsification` still work

## Artifacts & Outputs

- Modified `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
- No new files created

## Rollback/Contingency

Git revert the commit if restructuring causes unexpected issues with document compilation or cross-references.
The changes are localized to lines 303-327, making manual rollback straightforward if needed.
