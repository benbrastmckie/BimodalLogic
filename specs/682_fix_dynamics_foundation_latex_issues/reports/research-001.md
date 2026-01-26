# Research Report: Task #682

**Task**: 682 - fix_dynamics_foundation_latex_issues
**Started**: 2026-01-26T14:30:00Z
**Completed**: 2026-01-26T15:15:00Z
**Effort**: 2-3 hours implementation
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**: 03-DynamicsFoundation.tex, 02-ConstitutiveFoundation.tex, logos-notation.sty, Lean source files, counterfactual_worlds.tex
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- 13 distinct FIX: tags identified across 03-DynamicsFoundation.tex requiring structural and notational changes
- Key pattern: Convert set-theoretic notation to dependent type theory notation for consistency with Lean implementation
- The `\Define` macro (`\Coloneqq` for `::=`) already exists in logos-notation.sty for BNF notation
- Counterfactual_worlds.tex provides Containment theorem (lines 1822-1842) establishing world-history equivalence with maximal possible evolutions
- Many derived operators currently have semantic clauses that should be moved to definitions section

## Context & Scope

The task addresses 11 categories of LaTeX formatting and structural issues in `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`. The fixes aim to:
1. Align notation with dependent type theory conventions used in the Lean source
2. Properly separate primitive operators (with semantic clauses) from derived operators (defined in terms of primitives)
3. Use standard BNF notation for grammar definitions
4. Improve mathematical clarity and consistency with the Constitutive Foundation document

## Findings

### Issue 1: Line 38 - BNF Notation for Well-Formed Sentences

**Current State**: Well-formed sentences defined as enumerated list
**Required**: Standard BNF notation with `::=` (double colon equals) and `|` (pipe) separators

**Solution**: The macro `\Define` already exists in `logos-notation.sty` (line 65):
```latex
\newcommand{\Define}{\Coloneq}         % BNF-style definition (::=)
```

**Recommended Format** (following pattern from 02-ConstitutiveFoundation.tex lines 34-38):
```latex
\begin{definition}[Well-Formed Formulas]\label{def:wff-dynamics}
The set of \emph{well-formed formulas} extends the Constitutive Foundation:
\begin{align*}
    \metaA \Define{}& \metaA_\text{CF} \mid \actual(t) \mid \forall\metaA \\
    \mid{}& \nec\metaA \mid \allpast\metaA \mid \allfuture\metaA \\
    \mid{}& \metaA \since \metaB \mid \metaA \until \metaB \\
    \mid{}& \metaA \boxright \metaB \mid \store{i}\metaA \mid \recall{i}\metaA
\end{align*}
where $\metaA_\text{CF}$ ranges over Constitutive Foundation formulas.
\end{definition}
```

### Issue 2: Line 58 - Additional Derived Symbols

**Current State**: Only two derived temporal operators defined ($\always$, $\sometimes$)

**Recommended Additions**:
```latex
\begin{definition}[Derived Operators]\label{def:derived-operators}
    \begin{align}
        \poss\metaA &:= \neg\nec\neg\metaA && \text{``Possibly $\metaA$''} \\
        \somepast\metaA &:= \neg\allpast\neg\metaA && \text{``Sometimes past $\metaA$''} \\
        \somefuture\metaA &:= \neg\allfuture\neg\metaA && \text{``Sometimes future $\metaA$''} \\
        \always\metaA &:= \allpast\metaA \land \metaA \land \allfuture\metaA && \text{``Always $\metaA$''} \\
        \sometimes\metaA &:= \somepast\metaA \lor \metaA \lor \somefuture\metaA && \text{``Sometimes $\metaA$''} \\
        \nec\metaA &:= \top \boxright \metaA && \text{``Necessarily $\metaA$'' (via counterfactual)} \\
        \diamondright &:= \neg(\metaA \boxright \neg\metaB) && \text{``$\metaA$ might-counterfactual $\metaB$''}
    \end{align}
\end{definition}
```

### Issue 3: Line 104 - Rename 'Core Frame' to 'Dynamical Frame'

**Current State**: Comment says "core frame" but section title is already "Dynamical Frame"
**Action**: Remove the FIX comment as the section already uses correct terminology

### Issue 4: Lines 131, 144 - Dependent Type Theory Notation for State Modality

**Current State**: Set-theoretic notation like `s \in \possible`
**Required**: Type-theoretic notation consistent with Lean

**Lean Pattern** (from Frame.lean lines 77-126):
```lean
def possible (s : F.State) : Prop := F.taskRel s 0 s
def compatible (s t : F.State) : Prop := possible (F.toConstitutiveFrame.fusion s t)
def maximal (s : F.State) : Prop := ∀ t : F.State, compatible t s → F.toConstitutiveFrame.parthood t s
def world_state (w : F.State) : Prop := possible w ∧ maximal w
```

**Recommended LaTeX** (using predicate/type notation):
```latex
\begin{definition}[State Modality]\label{def:state-modality}
    Let $\mframe = \tuple{\statespace, \parthood, \temporalorder, \taskrel}$ be a dynamical frame. We define:
    \begin{align}
        \mathsf{Possible}(s) &\define \task{s}{0}{s} \\
        s \connected t &\define \exists d : D.\; \task{s}{d}{t} \lor \task{t}{d}{s} \\
        \mathsf{Compatible}(s, t) &\define \mathsf{Possible}(\fusion{s}{t}) \\
        \mathsf{Maximal}(s) &\define \forall t : \statespace.\; \mathsf{Compatible}(t, s) \to t \parthood s \\
        \mathsf{WorldState}(w) &\define \mathsf{Possible}(w) \land \mathsf{Maximal}(w) \\
        \mathsf{Necessary}(s) &\define \forall t : \statespace.\; s \connected t \to s = t
    \end{align}
\end{definition}
```

### Issue 5: Line 153 - World-State Definition Using Dependent Types

**Current State**: Remark notes maximality without formal definition
**Action**: Integrate the remark into Definition \ref{def:state-modality} as shown above, using the predicate `\mathsf{Maximal}(s)` which states: every compatible state is a part of s.

### Issue 6: Line 190 - Containment Subsection (World-History as Maximal Possible Evolution)

**Source**: counterfactual_worlds.tex lines 1435-1455 and theorem at lines 1822-1842

**Key Definitions from Source**:
1. **Discrete Evolution**: $\tau: \mathbb{Z} \to S$ is a function from times to states
2. **Possible Evolution**: $\tau$ is possible iff $\task{\tau(x)}{1}{\tau(x+1)}$ for all $x$
3. **Evolution Parthood**: $\tau \sqsubseteq \sigma$ iff $\tau(x) \sqsubseteq \sigma(x)$ for all $x$
4. **Maximal Evolution**: $\tau$ is maximal iff for any possible $\sigma$ where $\tau \sqsubseteq \sigma$, we have $\sigma = \tau$

**Theorem (Containment)**: $M_{\mathbb{Z}} = H_{\mathbb{Z}}$ where $M_{\mathbb{Z}}$ is maximal possible evolutions and $H_{\mathbb{Z}}$ is world-histories.

**Recommended LaTeX Structure**:
```latex
\begin{definition}[Evolution]\label{def:evolution}
    An \emph{evolution} over a dynamical frame $\mframe$ is a function $\tau : X \to \statespace$ where:
    \begin{itemize}
        \item $X \subseteq D$ is a convex subset of the temporal order
        \item $\task{\tau(x)}{y-x}{\tau(y)}$ for all times $x, y \in X$ where $x \leq y$
    \end{itemize}
\end{definition}

\begin{definition}[Evolution Parthood]\label{def:evolution-parthood}
    For evolutions $\tau, \sigma : X \to \statespace$, we define $\tau \sqsubseteq \sigma$ iff $\tau(x) \sqsubseteq \sigma(x)$ for all $x \in X$.
\end{definition}

\begin{definition}[Maximal Evolution]\label{def:maximal-evolution}
    An evolution $\tau$ is \emph{maximal} iff for any evolution $\sigma$ where $\tau \sqsubseteq \sigma$, we have $\sigma = \tau$.
\end{definition}

\begin{definition}[World-History]\label{def:world-history}
    A \emph{world-history} is a maximal possible evolution $\history : X \to \statespace$.
\end{definition}

\begin{theorem}[Containment]\label{thm:containment}
    An evolution $\tau$ is a world-history iff $\tau(x) \in \worldstates$ for all $x \in X$.
\end{theorem}
```

### Issue 7: Line 202 - Dependent Type Theory Notation for World-History

**Current State**: Set notation `\historyspace`
**Recommended**: Use type notation consistently:
```latex
\begin{notation}
    The type of all world-histories over $\mframe$ is denoted $\mathsf{WorldHistory}(\mframe)$.
\end{notation}
```

### Issue 8: Line 224 - Restate Interpretation from Constitutive Foundation

**Source**: 02-ConstitutiveFoundation.tex lines 111-121

**Recommended Addition**:
```latex
\begin{remark}[Interpretation Function]
    The interpretation function $\interp{\cdot}$ assigns:
    \begin{itemize}
        \item \textbf{n-place function symbols}: $\interp{f} : (\Fin\;n \to \statespace) \to \statespace$
        \item \textbf{n-place predicates}: verifier and falsifier function types $\verifiertype{F}, \falsifiertype{F} : ((\Fin\;n \to \statespace) \to \statespace) \to \Prop$
    \end{itemize}
    See the Constitutive Foundation (\Cref{def:constitutive-model}) for full details.
\end{remark}
```

### Issue 9: Line 248 - Convert Remark to Theorem

**Current State**: Remark about truth/falsity equivalence for world-histories
**Action**: Convert to theorem for Lean implementation:

```latex
\begin{theorem}[Bivalence for World-Histories]\label{thm:bivalence}
    For any world-history $\tau$, model $\model$, time $x$, assignment $\assignment$, and temporal index $\tempindex$:
    \[
        \model, \history, x, \assignment, \tempindex \trueat \metaA \iff \model, \history, x, \assignment, \tempindex \nfalseat \metaA
    \]
\end{theorem}

\begin{remark}
    This property breaks down for non-maximal evolutions $\tau$.
\end{remark}
```

### Issue 10: Line 270 - Define Quantifier Notation

**Current State**: Comment about defining $\forall v.\metaA(v)$ as $\forall(\lambda v_1.\metaA)(v_2)$
**Action**: Add to Derived Operators section:

```latex
\begin{definition}[Quantifier Notation]\label{def:quantifier-notation}
    The notation $\forall v.\metaA$ abbreviates $\forall(\lambda v.\metaA)$ where:
    \begin{itemize}
        \item $\lambda v.\metaA$ binds the variable $v$ in $\metaA$
        \item $\forall$ is the universal quantifier applied to the resulting property
    \end{itemize}
    Similarly, $\exists v.\metaA$ abbreviates $\exists(\lambda v.\metaA)$ where $\exists := \neg\forall\neg$.
\end{definition}
```

### Issue 11: Lines 303, 312, 322, 333 - Primitive vs Derived Semantic Clauses

**Current State**: Semantic clauses given for both primitive and derived operators
**Required**:
- Give semantic clauses only for primitives: $\boxright$, $\allpast$, $\allfuture$, $\since$, $\until$, $\store{}$, $\recall{}$
- Introduce stability operator as primitive (quantifies over histories intersecting current world-state at evaluation time)
- Move derived operators ($\nec$, $\poss$, $\somepast$, $\somefuture$) to definitions

**Recommended Structure**:

```latex
\subsubsection{Stability Operator (Primitive)}

\begin{definition}[Stability]\label{def:stability-truth}
    The \emph{stability operator} $\mathsf{Stab}\metaA$ quantifies over all histories sharing the current world-state:
    \[
        \model, \history, x, \assignment, \tempindex \trueat \mathsf{Stab}\metaA \iff
        \model, \alpha, x, \assignment, \tempindex \trueat \metaA \text{ for all } \alpha \in \historyspace \text{ where } \alpha(x) = \history(x)
    \]
\end{definition}

\begin{remark}
    The stability operator cannot be defined in terms of the counterfactual conditional.
    It captures what is true at the current world-state across all compatible histories.
\end{remark}
```

Then move modal operator semantic clauses to remarks showing they follow from the counterfactual definition:

```latex
\begin{remark}[Modal Operators as Derived]
    The modal operators are derived from the counterfactual:
    \begin{itemize}
        \item $\nec\metaA := \top \boxright \metaA$ (necessity)
        \item $\poss\metaA := \neg\nec\neg\metaA$ (possibility)
    \end{itemize}
    The semantic clauses for $\nec$ and $\poss$ follow from these definitions.
\end{remark}
```

### Issue 12: Lines 352, 374 - Move Operator Readings to Introduction

**Current State**: Operator readings given in remarks near semantic clauses
**Action**: Move readings to Section \ref{sec:additional-syntax} where primitives are introduced

**Example for Since/Until**:
```latex
\begin{itemize}
    \item \textbf{Extended temporal operators}: $\since$ (``$\metaA$ since $\metaB$'' means $\metaB$ was true at some past time, and $\metaA$ has been true ever since), $\until$ (``$\metaA$ until $\metaB$'' means $\metaB$ will be true at some future time, and $\metaA$ is true until then)
\end{itemize}
```

### Issue 13: Line 368 - Define `\altworlds` in Terms of Imposition

**Current State**: `\altworlds` used in counterfactual definition without explicit definition
**Required**: Connect to imposition definition

**Recommended**:
```latex
\begin{definition}[Alternative Worlds]\label{def:altworlds}
    For a world-history $\tau$, state $s$, and time $x$, define:
    \[
        \altworlds{\tau}{s}{x} := \set{\beta \in \historyspace : \imposition{s}{\tau(x)}{\beta(x)}}
    \]
    where $\imposition{t}{w}{w'}$ holds iff there exists a maximal $t$-compatible part $r \in \maxcompat{w}{t}$ such that $\fusion{r}{t} \parthood w'$.
\end{definition}
```

## Decisions

1. **BNF Notation**: Use existing `\Define` macro rather than introducing new packages
2. **Type Theory Style**: Use predicate notation (e.g., `\mathsf{Possible}(s)`) instead of set membership
3. **Primitive Operators**: $\boxright$, $\allpast$, $\allfuture$, $\since$, $\until$, $\store{}$, $\recall{}$, and new stability operator
4. **Derived Operators**: $\nec$, $\poss$, $\somepast$, $\somefuture$, $\always$, $\sometimes$
5. **World-History Definition**: Use maximal possible evolution definition with Containment theorem

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Stability operator not yet in Lean | Add as syntax first, implement semantics later |
| Breaking cross-references | Check all `\ref` and `\cref` after changes |
| Notation inconsistency | Review logos-notation.sty macros before using |
| Document length increase | Keep definitions concise, use remarks for intuition |

## Implementation Order

**Phase 1: Notation Foundation** (Issues 1, 10)
- Add BNF well-formed sentence definition
- Add quantifier notation definition

**Phase 2: Type Theory Conversion** (Issues 4, 5, 7)
- Convert state modality definitions to dependent type style
- Update world-state definition
- Update world-history notation

**Phase 3: Derived vs Primitive Restructure** (Issues 2, 11, 12)
- Expand derived operators section
- Introduce stability operator
- Move semantic clauses to appropriate locations
- Move readings to primitive introductions

**Phase 4: Additional Definitions** (Issues 6, 8, 13)
- Add evolution and maximal evolution definitions
- Add Containment theorem
- Restate interpretation from Constitutive Foundation
- Define `\altworlds` in terms of imposition

**Phase 5: Cleanup** (Issues 3, 9)
- Remove obsolete FIX comment at line 104
- Convert remark to theorem at line 248

## Appendix

### Search Queries Used
- LaTeX BNF grammar notation double colon syntax package

### Key Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/assets/logos-notation.sty`
- `/home/benjamin/Projects/ProofChecker/latex/notation-standards.sty`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Dynamics/Frame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Dynamics/Syntax.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Foundation/Semantics.lean`
- `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` (lines 1435-1455, 1822-1842)

### References
- [simplebnf LaTeX package](https://github.com/Zeta611/simplebnf) - BNF notation
- [formal-grammar LaTeX package](https://ctan.org/pkg/formal-grammar) - Grammar typesetting with `\Coloneqq` support
