# Research Report: Task #897

**Task**: 897 - fix_tags_constitutive_foundation_latex
**Started**: 2026-02-17T00:00:00Z
**Completed**: 2026-02-17T00:30:00Z
**Effort**: Medium
**Dependencies**: Task 896 (notation-conventions.md) - completed
**Sources/Inputs**: Codebase analysis, notation-conventions.md from task 896
**Artifacts**: specs/897_fix_tags_constitutive_foundation_latex/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Five FIX:/NOTE: tags in `02-ConstitutiveFoundation.tex` require coordinated changes to notation and content
- Primary changes: (1) Add remark about identity sentence propositions being trivial, (2) define `\interp{\cdot}` formally, (3) rename `\sem` to `\ext`, (4) extend the homomorphism to include `\equiv`, `\forall`, `\lambda`, and `F(t_1,...,t_n)`, (5) replace vague language with precise terminology
- Changes should be implemented in order: macro rename first, then formal definitions, then content additions

## Context & Scope

This task addresses 5 FIX:/NOTE: tags found in `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex`. The tags relate to improving the precision and completeness of the semantic interpretation formalism, particularly around:

1. The nature of propositions assigned to identity sentences
2. The formal definition of the interpretation function `\interp{\cdot}`
3. Notation distinction between term extension (`\ext`) and sentence interpretation (`\interp`)
4. The homomorphism from syntax to semantics

Task 896 has already documented the notation conventions in `.claude/context/project/latex/standards/notation-conventions.md`, providing the theoretical foundation for distinguishing `\ext` (term extension) from `\interp{\cdot}` (sentence interpretation).

## Findings

### Tag 1: Line 496 - Identity Sentence Propositions

**Location**: After Definition 3.5 (Propositional Identity Verification and Falsification), line 496

**Current State**: No remark follows the definition explaining the propositional content of identity sentences.

**Tag Content**:
```latex
% FIX: include a remark that the only propositions assigned to identity sentences are either \bot if false or \neg\bot if true, indicating that the claim is trivially false or trivially true, requiring nothing (the null state) to make it true/false.
```

**Analysis**: Looking at Definition 3.5 (lines 481-494), identity sentences are verified/falsified only at the null state:
- `\model, \assignment, s \verifies \metaA \equiv \metaB \iff s = \nullstate` (when the identity holds)
- `\model, \assignment, s \falsifies \metaA \equiv \metaB \iff s = \nullstate` (when the identity fails)

This means:
- If `A \equiv B` is true (same verifiers/falsifiers), the proposition is `\neg\bot` = `\fal` (verified only by null state)
- If `A \equiv B` is false (different verifiers/falsifiers), the proposition is `\bot` (falsified only by null state)

**Recommended Addition**:
```latex
\begin{remark}[Propositions Expressed by Identity Sentences]
Identity sentences express only trivial propositions.
If $\metaA \equiv \metaB$ holds (that is, $\metaA$ and $\metaB$ have the same exact verifiers and falsifiers), then the proposition expressed is $\neg\bot$ (the falsum)---verified by the null state and no other.
If $\metaA \equiv \metaB$ fails, the proposition expressed is $\bot$ (bottom)---falsified by the null state and no other.
This triviality reflects the nature of identity claims: they assert nothing contingent about what states obtain, only whether two sentences express the same proposition.
\end{remark}
```

### Tag 2: Line 583 - Include \equiv and Define \interp{\cdot}

**Location**: Before Remark 3.22 (Propositional vs. Sentential Operators), line 583

**Current State**: The remark at lines 587-602 lists the homomorphism properties for `\neg`, `\land`, `\lor`, `\top`, `\bot` but omits `\equiv`, `\forall`, `\lambda`, and predicate application `F(t_1,...,t_n)`.

**Tag Content**:
```latex
% FIX: include $\equiv$ in the remark below, where \sem{\metaA \equiv \metaB} = \neg\bot if \sem{\metaA} = \sem{\metaB} and \bot otherwise. I also want to include \forall and \lambda and F(t_1, \ldots, t_n) so that a model and assignment provide an interpretation function which is a homomorphism from closed sentences to propositions. It is important to define \interp{\cdot}^\assignment_\model to do so in order to state the propositional operations for \lambda and \forall (this definition should be given prior to this remark)
```

**Analysis**: The current `\sem{}` function (line 315) maps terms to states. A new function `\interp{\cdot}` is needed to map sentences (closed formulas) to bilateral propositions. This must be defined before the remark.

**Recommended Addition** (new definition before the remark):
```latex
\begin{definition}[Sentence Interpretation]\label{def:sentence-interpretation}
The \emph{interpretation} of a sentence given a model $\model$ and assignment $\assignment$ is a function $\interp{\cdot}^\assignment_\model : \sent \to \props$ defined by:
\begin{align}
  \interp{F(t_1, \ldots, t_n)}^\assignment_\model &= \tuple{\set{s : \model, \assignment, s \verifies F(t_1, \ldots, t_n)}, \set{s : \model, \assignment, s \falsifies F(t_1, \ldots, t_n)}} \\
  \interp{(\lambda v.\metaA)(t)}^\assignment_\model &= \interp{\metaA}^{\assignsub{\ext{t}^\assignment_\model}{v}}_\model \\
  \interp{\forall \metaA(v)}^\assignment_\model &= \tuple{\set{s : \model, \assignment, s \verifies \forall \metaA(v)}, \set{s : \model, \assignment, s \falsifies \forall \metaA(v)}} \\
  \interp{\top}^\assignment_\model &= \top_\props \\
  \interp{\bot}^\assignment_\model &= \bot_\props \\
  \interp{\neg\metaA}^\assignment_\model &= \neg\interp{\metaA}^\assignment_\model \\
  \interp{\metaA \land \metaB}^\assignment_\model &= \interp{\metaA}^\assignment_\model \land \interp{\metaB}^\assignment_\model \\
  \interp{\metaA \lor \metaB}^\assignment_\model &= \interp{\metaA}^\assignment_\model \lor \interp{\metaB}^\assignment_\model \\
  \interp{\metaA \equiv \metaB}^\assignment_\model &=
    \begin{cases}
      \fal_\props & \text{if } \interp{\metaA}^\assignment_\model = \interp{\metaB}^\assignment_\model \\
      \bot_\props & \text{otherwise}
    \end{cases}
\end{align}
where $\ext{\cdot}^\assignment_\model$ is the term extension function (\Cref{def:term-extension}).
\end{definition}
```

**Note**: The `\fal_\props` (falsum) and `\bot_\props` are already defined in Definition 3.21 (lines 572-581).

### Tag 3: Line 585 - Rename \sem to \ext

**Location**: Line 585

**Tag Content**:
```latex
% NOTE: \interp{\cdot}^\assignment_\model should be used instead of \sem{}^\assignment_\model which is what is used for the extension of terms. Also, rename \sem to \ext to indicate this is for the extension of a term
```

**Analysis**: The macro `\sem` is defined in `logos-notation.sty` at line 210:
```latex
\newcommand{\sem}[1]{\llbracket #1 \rrbracket}
```

According to the notation-conventions.md:
- `\ext{t}` should be used for term extensions (domain elements, sets, functions)
- `\interp{\phi}` should be used for sentence interpretation (bilateral propositions)
- `\sem{t}` is deprecated in favor of `\ext{t}`

**Recommended Changes**:

1. **In `logos-notation.sty`**: Add new macro and deprecation note:
```latex
\newcommand{\ext}[1]{\llbracket #1 \rrbracket}  % Term extension: \ext{t} -> [[t]]
% DEPRECATED: \sem is deprecated in favor of \ext for term extensions
\newcommand{\sem}[1]{\llbracket #1 \rrbracket}
```

2. **In `02-ConstitutiveFoundation.tex`**: Replace all instances of `\sem{...}` with `\ext{...}`:
   - Line 315: `\sem{\cdot}^\assignment_\model` -> `\ext{\cdot}^\assignment_\model`
   - Line 317: `\sem{v}^\assignment_\model` -> `\ext{v}^\assignment_\model`
   - Line 318: `\sem{f(t_1, \ldots, t_n)}^\assignment_\model` -> `\ext{f(t_1, \ldots, t_n)}^\assignment_\model`
   - Line 318: `\sem{t_1}^\assignment_\model, \ldots, \sem{t_n}^\assignment_\model` -> `\ext{t_1}^\assignment_\model, \ldots, \ext{t_n}^\assignment_\model`
   - Lines 361-362: Similar replacements in atomic verification
   - Lines 370-371: Similar replacements in lambda verification

**Current usages to replace** (from grep):
- Line 315: function definition
- Lines 317-318: term extension clauses
- Lines 361-362: atomic formula semantics
- Lines 370-371: lambda semantics
- Lines 592-596: homomorphism equations (these should use `\interp` not `\ext`)

### Tag 4: Line 599 - Formal Definition of Homomorphism

**Location**: Line 599, inside Remark 3.22

**Tag Content**:
```latex
% FIX: provide the formal definition of the homomorphism from the syntax to the semantics
```

**Analysis**: The remark mentions the homomorphism but does not formally define it. With the new `\interp{\cdot}` definition (Tag 2), the formal statement becomes clearer.

**Recommended Addition** (after the bullet list in Remark 3.22):
```latex
Formally, the interpretation function $\interp{\cdot}^\assignment_\model$ is a \emph{homomorphism} from the algebra $\tuple{\sent, \neg, \land, \lor, \top, \bot}$ of sentences to the algebra $\tuple{\props, \neg, \land, \lor, \top_\props, \bot_\props}$ of bilateral propositions:
\[
  \interp{\cdot}^\assignment_\model : (\sent, \neg, \land, \lor, \top, \bot) \to (\props, \neg, \land, \lor, \top_\props, \bot_\props)
\]
This means the interpretation function preserves the algebraic structure: applying a sentential connective and then interpreting yields the same result as interpreting each component and then applying the corresponding propositional operation.
```

### Tag 5: Line 600 - Replace Vague Language

**Location**: Line 600-601, inside Remark 3.22

**Current Text**:
```latex
This homomorphism property ensures that reasoning about propositions directly mirrors reasoning about sentences, justifying the common notation.
```

**Tag Content**:
```latex
% FIX: instead of 'directly mirrors' which is vague, use the correct language which explains what the embedding amounts to
```

**Recommended Replacement**:
```latex
This homomorphism property ensures that deductions valid in the propositional algebra $\tuple{\props, \neg, \land, \lor}$ correspond exactly to deductions valid in the sentential algebra $\tuple{\sent, \neg, \land, \lor}$, justifying the use of the same symbols for both levels.
```

Or more concisely:
```latex
This homomorphism property establishes a structure-preserving embedding from the syntactic algebra of sentences into the semantic algebra of propositions, ensuring that logical equivalences among sentences are reflected as identities among propositions.
```

## Recommendations

### Implementation Order

1. **Phase 1: Macro changes** (logos-notation.sty)
   - Add `\ext` macro
   - Keep `\sem` for backward compatibility with deprecation note

2. **Phase 2: Notation updates** (02-ConstitutiveFoundation.tex)
   - Replace `\sem{...}` with `\ext{...}` in term extension contexts (lines 315-371)
   - Keep `\interp{...}` for symbol interpretations (already correct at line 318)

3. **Phase 3: Add formal definitions** (02-ConstitutiveFoundation.tex)
   - Add Definition for `\interp{\cdot}` (sentence interpretation) before Remark 3.22 (before line 587)
   - This definition should go after Definition 3.21 (Extremal Bilateral Propositions)

4. **Phase 4: Add remarks and fix language** (02-ConstitutiveFoundation.tex)
   - Add remark about identity sentence propositions after line 496
   - Update Remark 3.22 to include `\equiv`, `\forall`, `\lambda`, and formal homomorphism statement
   - Replace "directly mirrors" with precise language

### Dependencies

- Tag 3 (rename `\sem` to `\ext`) should be done first as it affects multiple locations
- Tag 2 (`\interp{\cdot}` definition) should come before Tag 4 (formal homomorphism)
- Tag 1 (identity remark) is independent and can be done in any order

### Notation Summary

After changes:
- `\ext{t}^\assignment_\model` - Extension of term `t` (returns a state/domain element)
- `\interp{\cdot}^\assignment_\model` - Interpretation function (maps sentences to propositions)
- `\interp{f}` - Interpretation of non-logical symbol `f` (from the model)

## Risks & Mitigations

1. **Risk**: Breaking existing LaTeX compilation
   - **Mitigation**: Keep `\sem` as a deprecated alias for `\ext` in logos-notation.sty

2. **Risk**: Notation inconsistency with other subfiles
   - **Mitigation**: Search for `\sem` usage in other files; update consistently or add deprecation note

3. **Risk**: The `\interp{\cdot}` definition for quantifiers and lambda is complex
   - **Mitigation**: The definition can reference the verification/falsification clauses already given, rather than repeating them

## Appendix

### Search Queries Used
- `grep -n "FIX:\|NOTE:" 02-ConstitutiveFoundation.tex` - Located all tags
- `grep -n "\\sem{" 02-ConstitutiveFoundation.tex` - Found all `\sem` usages
- Analysis of `logos-notation.sty` for existing macros

### File Locations
- Source file: `/home/benjamin/Projects/Logos/Theory/latex/subfiles/02-ConstitutiveFoundation.tex`
- Style file: `/home/benjamin/Projects/Logos/Theory/latex/assets/logos-notation.sty`
- Notation conventions: `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/notation-conventions.md`

### Tag Line Number Corrections
The task description listed line numbers that differ slightly from actual locations:
- Tag 1: Listed as 479, actual at 496
- Tag 2: Listed as 566, actual at 583
- Tag 3: Listed as 568, actual at 585
- Tag 4: Listed as 582, actual at 599
- Tag 5: Listed as 583, actual at 600

(Line numbers may have shifted due to prior edits; the grep results provide accurate current locations.)
