# Research Report: Task #846

**Task**: 846 - fix_latex_constitutive_foundation_tags
**Started**: 2026-02-03T12:30:00Z
**Completed**: 2026-02-03T12:35:00Z
**Effort**: Low (straightforward edits)
**Dependencies**: Task 845 (completed - context updates for LaTeX standards)
**Sources/Inputs**: Codebase analysis, LaTeX file inspection, logos-notation.sty
**Artifacts**: specs/846_fix_latex_constitutive_foundation_tags/reports/research-001.md
**Standards**: report-format.md, .claude/rules/latex.md

## Executive Summary

- 3 FIX tags and 2 NOTE tags identified in 02-ConstitutiveFoundation.tex
- FIX Line 165: Remark content should become formal definitions for null state, full state, state fusion, and pointwise fusion
- FIX Line 187: State modality definitions have excessive type annotations; simplify to left-aligned definitions with right-aligned brief characterizations
- FIX Line 202: Pointwise compatibility definition should be integrated into the state modality definition block
- NOTE Line 474: `\leansrc` reference format is correct; just ensure `\noindent` prefix is present (it is)
- NOTE Line 550: 7 instances of `\{ \}` need replacement with `\set{}` macro across the file

## Context & Scope

This task addresses FIX: and NOTE: tags discovered by `/learn` scanning in the ConstitutiveFoundation.tex LaTeX source file.
The tags mark areas needing improvement per project standards.

### Files Analyzed
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/assets/logos-notation.sty`
- `/home/benjamin/Projects/ProofChecker/.claude/rules/latex.md`

## Findings

### FIX Tag 1: Line 165 - Turn Remark into Definitions

**Current Content** (Lines 167-176):
```latex
\begin{remark}
	The lattice structure provides:
	\begin{itemize}
		\item \textbf{Null state} $\nullstate$: The bottom element (fusion of the empty set)
		\item \textbf{Full state} $\fullstate$: The top element (fusion of all states)
		\item \textbf{State Fusion} $\fusion{s}{t}$: The least upper bound of $s$ and $t$
		\item \textbf{Pointwise Fusion} $(\fusion{f}{g})(s_1,\ldots,s_n) \define \fusion{f(s_1,\ldots,s_n)}{g(s_1,\ldots,s_n)}$
	\end{itemize}
	These lattice operations interact with the task relation constraints...
\end{remark}
```

**Analysis**: The remark contains four lattice structure concepts that should be formal definitions.
These are fundamental concepts referenced throughout the document.

**Recommendation**: Convert to a definition environment with the four items as proper definitional clauses:
```latex
\begin{definition}[Lattice Operations]\label{def:lattice-operations}
The complete lattice $\statespace = \tuple{S, \parthood}$ provides:
\begin{itemize}
  \item \textbf{Null state}: $\nullstate$ is the bottom element (fusion of the empty set)
  \item \textbf{Full state}: $\fullstate$ is the top element (fusion of all states)
  \item \textbf{State Fusion}: $\fusion{s}{t}$ is the least upper bound of $s$ and $t$
  \item \textbf{Pointwise Fusion}: For functions $f, g$, $(\fusion{f}{g})(s_1,\ldots,s_n) \define \fusion{f(s_1,\ldots,s_n)}{g(s_1,\ldots,s_n)}$
\end{itemize}
\end{definition}
```

Then add a brief remark about how these interact with task relation constraints.

### FIX Tag 2: Line 187 - Simplify State Modality Layout

**Current Content** (Lines 189-199):
```latex
\begin{definition}[State Modality]\label{def:state-modality}
Let $\mframe = \tuple{\statespace, \temporalorder, \taskrel}$ be a dynamical frame.
We define the following predicates on states:
\begin{align}
    \possible &: \statespace \to \Prop & \possible(s) &\define \task{s}{0}{s} \\
    (\cdot \compatible \cdot) &: \statespace \to \statespace \to \Prop & s \compatible t &\define \possible(\fusion{s}{t}) \\
    ... (6 total definitions with full type signatures)
\end{align}
\end{definition}
```

**Analysis**: The current layout has 4 columns per definition:
1. Symbol/name
2. Type signature
3. Applied form
4. Definition

This is verbose.
The FIX comment says "the types here are overkill" and requests moving definitions to the left with brief characterizations on the right.

**Recommendation**: Restructure as two columns - definition on left, brief description on right:
```latex
\begin{definition}[State Modality]\label{def:state-modality}
Let $\mframe = \tuple{\statespace, \temporalorder, \taskrel}$ be a dynamical frame.
We define the following predicates on states:
\begin{align}
    \possible(s) &\define \task{s}{0}{s} & &\text{(state is possible)} \\
    s \compatible t &\define \possible(\fusion{s}{t}) & &\text{(states are compatible)} \\
    \mathsf{Maximal}(s) &\define \forall t.\; t \compatible s \to t \parthood s & &\text{(maximally compatible)} \\
    \worldstates(w) &\define \possible(w) \land \mathsf{Maximal}(w) & &\text{(world-state)} \\
    s \connected t &\define \exists d.\; \task{s}{d}{t} \lor \task{t}{d}{s} & &\text{(states are connected)} \\
    \necessary(s) &\define \forall t.\; s \connected t \to s = t & &\text{(state is necessary)}
\end{align}
\end{definition}
```

### FIX Tag 3: Line 202 - Integrate Pointwise Compatibility

**Current Content** (Lines 204-207):
A separate definition environment for pointwise compatibility immediately after the state modality definition.

**Analysis**: The pointwise compatibility definition extends the binary `\compatible` relation to functions.
It logically belongs with the state modality definitions above.

**Recommendation**: Add pointwise compatibility as two additional items in the state modality definition block:
```latex
    f \compatible g &\define \forall a_1, \ldots, a_n.\; f(a_1, \ldots, a_n) \compatible g(a_1, \ldots, a_n) & &\text{(pointwise compatible)} \\
    f \ncompatible g &\define \forall a_1, \ldots, a_n.\; f(a_1, \ldots, a_n) \ncompatible g(a_1, \ldots, a_n) & &\text{(pointwise incompatible)}
```

Then delete the separate Definition environment (lines 204-207) and remove the FIX comment.

### NOTE Tag 1: Line 474 - Lean Source Reference Standard

**Current Content** (Lines 476-477):
```latex
\noindent
See \leansrc{Logos.Foundation.Semantics}{verifies}.
```

**Analysis**: This already follows the correct standard:
- `\noindent` prefix is present
- `\leansrc` macro is used correctly
- Placed at end of section

**Recommendation**: The NOTE tag can simply be removed. The format is already correct.
The NOTE comment itself documents the standard for other occurrences - but this instance is compliant.

### NOTE Tag 2: Line 550 - Replace \{ \} with \set{} Macro

**Current Content**: The NOTE tag at line 550 documents the requirement.

**Analysis**: Found 7 instances of `\{ \}` that should use `\set{}`:

| Line | Current | Replacement |
|------|---------|-------------|
| 58 | `\{v\}` | `\set{v}` |
| 106 | `\{v\}` | `\set{v}` |
| 555 | `\{\fullstate\}` | `\set{\fullstate}` |
| 556 | `\{\nullstate\}` | `\set{\nullstate}` |
| 557 | `\{\fullstate\}` (twice in line) | `\set{\fullstate}` |
| 558 | `\{\nullstate\}` | `\set{\nullstate}` |

**Note**: The `\set{}` macro is defined in logos-notation.sty as:
```latex
\newcommand{\set}[1]{\{#1\}}          % Set notation (replaces \{...\} pairs)
```

The macro produces identical output but provides semantic clarity and consistency.

**Recommendation**: Replace all 7 instances, then remove the NOTE comment at line 550.

## Decisions

1. **FIX Line 165**: Convert remark to definition environment with proper label
2. **FIX Line 187**: Remove type signatures column, keep definition and brief characterization
3. **FIX Line 202**: Merge pointwise compatibility into state modality definition, delete separate definition
4. **NOTE Line 474**: Remove comment only (format already correct)
5. **NOTE Line 550**: Replace all 7 `\{ \}` instances with `\set{}`, remove comment

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| LaTeX compilation errors after edits | Test compilation with `pdflatex` after each major change |
| Cross-reference breakage | Add label `\label{def:lattice-operations}` to new definition, check no references break |
| Alignment issues in align environment | Test visually after simplifying state modality layout |

## Implementation Checklist

1. [ ] Convert lattice remark (Lines 167-176) to formal definition
2. [ ] Simplify state modality definition layout (Lines 189-199)
3. [ ] Integrate pointwise compatibility into state modality (Lines 204-207)
4. [ ] Remove FIX comments (Lines 165, 187, 202)
5. [ ] Remove NOTE comment at Line 474
6. [ ] Replace 7 instances of `\{ \}` with `\set{}`
7. [ ] Remove NOTE comment at Line 550
8. [ ] Test LaTeX compilation

## Appendix

### Search Queries Used
- File read: 02-ConstitutiveFoundation.tex (full file)
- File read: logos-notation.sty (for \set{} macro definition)
- Grep: `\{` patterns in source file
- Grep: `\set{` existing usage

### References
- `.claude/rules/latex.md` - LaTeX development rules including \set{} and \leansrc standards
- Task 845 - Context updates that documented these standards
