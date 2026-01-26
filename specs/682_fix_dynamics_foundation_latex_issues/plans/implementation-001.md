# Implementation Plan: Task #682

- **Task**: 682 - fix_dynamics_foundation_latex_issues
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/682_fix_dynamics_foundation_latex_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Fix 13 distinct LaTeX formatting and structural issues in `03-DynamicsFoundation.tex` to align notation with dependent type theory conventions used in Lean, properly separate primitive operators from derived operators, use standard BNF notation, and improve consistency with the Constitutive Foundation document.

### Research Integration

Integrated findings from `reports/research-001.md`:
- The `\Define` macro (for `::=`) exists in `logos-notation.sty`
- Counterfactual_worlds.tex provides Containment theorem (lines 1822-1842) for maximal evolutions
- Type-theoretic predicate notation (e.g., `\mathsf{Possible}(s)`) preferred over set notation

## Goals & Non-Goals

**Goals**:
- Convert set-theoretic notation to dependent type theory notation for Lean consistency
- Separate primitive operators (semantic clauses) from derived operators (definitions)
- Use standard BNF notation for well-formed formula definitions
- Add missing definitions (stability operator, altworlds, evolution, containment)
- Improve document structure by moving operator readings to introduction sections

**Non-Goals**:
- Implementing the stability operator in Lean (future task)
- Modifying other Logos LaTeX files
- Changing the counterfactual axiom system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking cross-references | Medium | Medium | Verify all `\ref` and `\cref` after changes |
| Notation inconsistency | Medium | Low | Review logos-notation.sty macros before using |
| Stability operator not in Lean | Low | N/A | Add as syntax only; implementation is future work |
| Document length increase | Low | Medium | Keep definitions concise; use remarks for intuition |

## Implementation Phases

### Phase 1: Notation Foundation [COMPLETED]

**Goal**: Establish BNF notation for well-formed formulas and define quantifier notation convention

**Tasks**:
- [ ] Replace enumerated list at line 38-50 with BNF definition using `\Define` macro
- [ ] Add quantifier notation definition (Issue 10, line 270) to Derived Operators section

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 38-65, 270

**Detailed Steps**:

1. Replace lines 38-50 (Well-Formed Sentences section) with:
```latex
% FIX: define the well-formed sentences using the standard definition...
% (Remove FIX comment and replace enumerated list with:)

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

2. Add after line 65 (before Operator Summary section):
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

3. Remove the FIX comment at line 270 (now addressed by the above definition)

**Verification**:
- Document compiles without errors
- BNF definition renders correctly with `::=` symbol
- Cross-references to `def:wff-dynamics` and `def:quantifier-notation` resolve

---

### Phase 2: Type Theory Conversion [COMPLETED]

**Goal**: Convert state modality and world-history definitions to dependent type theory notation

**Tasks**:
- [ ] Convert state modality definitions (lines 131-157) to predicate notation
- [ ] Update world-history notation (line 202-206) to type notation
- [ ] Integrate maximality remark into state modality definition

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 131-157, 202-206

**Detailed Steps**:

1. Replace lines 131-157 (State Modality Definitions) with:
```latex
% (Remove FIX comments at lines 131, 144, 153)

\begin{definition}[State Modality]\label{def:state-modality}
    Let $\mframe = \tuple{\statespace, \parthood, \temporalorder, \taskrel}$ be a dynamical frame.
    We define the following predicates on states:
    \begin{align}
        \mathsf{Possible}(s) &\define \task{s}{0}{s} \\
        s \connected t &\define \exists d : D.\; \task{s}{d}{t} \lor \task{t}{d}{s} \\
        \mathsf{Compatible}(s, t) &\define \mathsf{Possible}(\fusion{s}{t}) \\
        \mathsf{Maximal}(s) &\define \forall t : \statespace.\; \mathsf{Compatible}(t, s) \to t \parthood s \\
        \mathsf{WorldState}(w) &\define \mathsf{Possible}(w) \land \mathsf{Maximal}(w) \\
        \mathsf{Necessary}(s) &\define \forall t : \statespace.\; s \connected t \to s = t
    \end{align}
\end{definition}

\begin{remark}
    A world-state $w$ satisfying $\mathsf{WorldState}(w)$ is maximal in the sense that every compatible state is a part of $w$.
\end{remark}

\begin{definition}[Maximal Compatible Part]\label{def:maximal-compatible}
    For states $r, t : \statespace$, the set of \emph{maximal $t$-compatible parts} of $r$ is:
    \[
        \maxcompat{r}{t} := \set{s : \statespace \mid s \parthood r \land \mathsf{Compatible}(s, t) \land \forall s'.\; (s \parthood s' \parthood r \land \mathsf{Compatible}(s', t)) \to s' \parthood s}
    \]
\end{definition}
```

2. Replace lines 202-206 (World-History notation) with:
```latex
% (Remove FIX comment at line 202)

\begin{notation}
    The type of all world-histories over $\mframe$ is denoted $\mathsf{WorldHistory}(\mframe)$.
    We write $\history : \mathsf{WorldHistory}(\mframe)$ to indicate that $\history$ is a world-history.
\end{notation}
```

**Verification**:
- Document compiles without errors
- Predicate notation renders with `\mathsf{}` formatting
- All cross-references to modified definitions resolve

---

### Phase 3: Derived vs Primitive Restructure [COMPLETED]

**Goal**: Expand derived operators section, introduce stability operator, and reorganize semantic clauses

**Tasks**:
- [ ] Expand derived operators definition (line 58-65) with modal and temporal operators
- [ ] Add stability operator as primitive in Modal Operators section (lines 303-318)
- [ ] Convert modal and tense operator semantic clauses to remarks showing derivation
- [ ] Move operator readings from remarks to primitive symbol introduction (lines 352, 374)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 58-65, 303-337, 352-357, 374-379

**Detailed Steps**:

1. Replace lines 58-65 (Derived Operators) with expanded definition:
```latex
% (Remove FIX comment at line 58)

\begin{definition}[Derived Operators]\label{def:derived-operators}
    The following operators are defined in terms of primitives:
    \begin{align}
        \poss\metaA &:= \neg\nec\neg\metaA && \text{``Possibly $\metaA$''} \\
        \somepast\metaA &:= \neg\allpast\neg\metaA && \text{``Sometimes past $\metaA$''} \\
        \somefuture\metaA &:= \neg\allfuture\neg\metaA && \text{``Sometimes future $\metaA$''} \\
        \always\metaA &:= \allpast\metaA \land \metaA \land \allfuture\metaA && \text{``Always $\metaA$''} \\
        \sometimes\metaA &:= \somepast\metaA \lor \metaA \lor \somefuture\metaA && \text{``Sometimes $\metaA$''} \\
        \nec\metaA &:= \top \boxright \metaA && \text{``Necessarily $\metaA$''} \\
        \diamondright\metaA\metaB &:= \neg(\metaA \boxright \neg\metaB) && \text{``$\metaA$ might-counterfactual $\metaB$''}
    \end{align}
\end{definition}
```

2. Replace lines 303-318 (Modal Operators section) with stability operator and derivation remarks:
```latex
% (Remove FIX comments at lines 303, 312)

\subsubsection{Stability Operator (Primitive)}

\begin{definition}[Stability]\label{def:stability-truth}
    The \emph{stability operator} $\mathsf{Stab}\metaA$ quantifies over all histories sharing the current world-state:
    \[
        \model, \history, x, \assignment, \tempindex \trueat \mathsf{Stab}\metaA \iff
        \model, \alpha, x, \assignment, \tempindex \trueat \metaA \text{ for all } \alpha : \mathsf{WorldHistory}(\mframe) \text{ where } \alpha(x) = \history(x)
    \]
\end{definition}

\begin{remark}
    The stability operator cannot be defined in terms of the counterfactual conditional.
    It captures what is true at the current world-state across all compatible histories.
\end{remark}

\subsubsection{Modal Operators (Derived)}

\begin{remark}[Modal Operators as Derived]\label{rem:modal-derived}
    The modal operators are derived from the counterfactual:
    \begin{itemize}
        \item $\nec\metaA := \top \boxright \metaA$ (necessity)
        \item $\poss\metaA := \neg\nec\neg\metaA$ (possibility)
    \end{itemize}
    The semantic clauses follow from these definitions:
    \begin{align}
        \model, \history, x, \assignment, \tempindex \trueat \nec\metaA  & \iff \model, \alpha, x, \assignment, \tempindex \trueat \metaA \text{ for all } \alpha : \mathsf{WorldHistory}(\mframe)  \\
        \model, \history, x, \assignment, \tempindex \trueat \poss\metaA & \iff \model, \alpha, x, \assignment, \tempindex \trueat \metaA \text{ for some } \alpha : \mathsf{WorldHistory}(\mframe)
    \end{align}
\end{remark}
```

3. Replace lines 322-337 (Dynamical Tense Operators) to show derived operators:
```latex
% (Remove FIX comments at lines 322, 333)

\begin{definition}[Primitive Tense Operators]\label{def:tense-truth}
    \begin{align}
        \model, \history, x, \assignment, \tempindex \trueat \allpast\metaA     & \iff \model, \history, y, \assignment, \tempindex \trueat \metaA \text{ for all } y : D \text{ where } y < x  \\
        \model, \history, x, \assignment, \tempindex \trueat \allfuture\metaA & \iff \model, \history, y, \assignment, \tempindex \trueat \metaA \text{ for all } y : D \text{ where } y > x
    \end{align}
\end{definition}

\begin{remark}[Derived Tense Operators]\label{rem:tense-derived}
    The ``sometimes'' operators are derived:
    \begin{itemize}
        \item $\somepast\metaA := \neg\allpast\neg\metaA$
        \item $\somefuture\metaA := \neg\allfuture\neg\metaA$
    \end{itemize}
    Their semantic clauses follow:
    \begin{align}
        \model, \history, x, \assignment, \tempindex \trueat \somepast\metaA    & \iff \model, \history, y, \assignment, \tempindex \trueat \metaA \text{ for some } y : D \text{ where } y < x \\
        \model, \history, x, \assignment, \tempindex \trueat \somefuture\metaA & \iff \model, \history, y, \assignment, \tempindex \trueat \metaA \text{ for some } y : D \text{ where } y > x
    \end{align}
\end{remark}
```

4. Update Additional Syntactic Primitives section (lines 22-30) to include operator readings:
```latex
\begin{itemize}
    \item \textbf{Actuality Predicate}: $\actual$ (``$t$ is actual'')
    \item \textbf{Quantification}: $\forall$ (``for all'')
    \item \textbf{Counterfactual conditional}: $\boxright$ (``if $\metaphi$ were the case, then $\metaC$ would be the case'')
    \item \textbf{Temporal operators}: $\allpast$ (``it has always been that''), $\allfuture$ (``it will always be that'')
    \item \textbf{Extended temporal operators}: $\since$ (``$\metaA$ since $\metaB$'' means $\metaB$ was true at some past time and $\metaA$ has been true ever since), $\until$ (``$\metaA$ until $\metaB$'' means $\metaB$ will be true at some future time and $\metaA$ is true until then)
    \item \textbf{Stability operator}: $\mathsf{Stab}$ (``stably $\metaA$'')
    \item \textbf{Store/recall operators}: $\store{i}$ (``store current time''), $\recall{i}$ (``recall stored time'')
\end{itemize}
```

5. Remove or simplify remarks at lines 352-357 and 374-379 (readings now in introduction)

**Verification**:
- Document compiles without errors
- Stability operator definition renders correctly
- Derived operator definitions show as remarks, not semantic clauses
- Operator readings appear in primitive introduction section

---

### Phase 4: Additional Definitions [COMPLETED]

**Goal**: Add evolution definitions, Containment theorem, interpretation restatement, and altworlds definition

**Tasks**:
- [ ] Add evolution and maximal evolution definitions (Issue 6, line 190)
- [ ] Add Containment theorem relating world-histories to maximal possible evolutions
- [ ] Restate interpretation function from Constitutive Foundation (Issue 8, line 224)
- [ ] Define altworlds in terms of imposition (Issue 13, line 368)

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 188-206, 220-225, 368-372

**Detailed Steps**:

1. Replace lines 188-206 (World-History section) with evolution-based definition:
```latex
\subsection{World-History}\label{sec:world-history}

% (Remove FIX comment at line 190)

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

\begin{definition}[Possible and Maximal Evolution]\label{def:maximal-evolution}
    An evolution $\tau$ is:
    \begin{itemize}
        \item \emph{possible} iff $\mathsf{Possible}(\tau(x))$ for all $x$ in its domain
        \item \emph{maximal} iff for any possible evolution $\sigma$ where $\tau \sqsubseteq \sigma$, we have $\sigma = \tau$
    \end{itemize}
\end{definition}

\begin{definition}[World-History]\label{def:world-history}
    A \emph{world-history} is a maximal possible evolution $\history : X \to \statespace$.
\end{definition}

\begin{theorem}[Containment]\label{thm:containment}
    An evolution $\tau$ is a world-history iff $\mathsf{WorldState}(\tau(x))$ for all $x$ in its domain.
\end{theorem}

\begin{notation}
    The type of all world-histories over $\mframe$ is denoted $\mathsf{WorldHistory}(\mframe)$.
\end{notation}
```

2. Add after line 220 (before FIX comment at 224):
```latex
% (Remove FIX comment at line 224)

\begin{remark}[Interpretation Function]
    The interpretation function $\interp{\cdot}$ assigns:
    \begin{itemize}
        \item \textbf{n-place function symbols}: $\interp{f} : (\mathsf{Fin}\;n \to \statespace) \to \statespace$
        \item \textbf{n-place predicates}: verifier and falsifier function types
    \end{itemize}
    See the Constitutive Foundation (\Cref{def:constitutive-model}) for full details.
\end{remark}
```

3. Replace lines 368-372 (after Imposition definition) with altworlds definition:
```latex
% (Remove FIX comment at line 368)

\begin{definition}[Alternative Worlds]\label{def:altworlds}
    For a world-history $\tau$, state $s : \statespace$, and time $x : D$, the \emph{alternative worlds} are:
    \[
        \altworlds{\tau}{s}{x} := \set{\beta : \mathsf{WorldHistory}(\mframe) \mid \imposition{s}{\tau(x)}{\beta(x)}}
    \]
    where $\imposition{t}{w}{w'}$ holds iff there exists $r \in \maxcompat{w}{t}$ such that $\fusion{r}{t} \parthood w'$.
\end{definition}
```

**Verification**:
- Document compiles without errors
- Evolution definitions precede world-history definition
- Containment theorem links world-histories to world-states
- Altworlds definition uses imposition correctly

---

### Phase 5: Cleanup and Final Fixes [COMPLETED]

**Goal**: Remove obsolete comments, convert remark to theorem, and verify document integrity

**Tasks**:
- [ ] Remove FIX comment at line 104 (terminology already correct)
- [ ] Convert bivalence remark (line 248-253) to theorem
- [ ] Remove remaining FIX comments (lines 278, 406, 427, 456, 473)
- [ ] Verify all cross-references resolve
- [ ] Compile document and check for errors

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - various lines

**Detailed Steps**:

1. Remove FIX comment at line 104:
```latex
% Remove: % FIX: a 'core frame' is not what this is called. Instead it is called a 'dynamical frame'.
```

2. Replace lines 248-253 (bivalence remark) with theorem:
```latex
% (Remove FIX comment at line 248)

\begin{theorem}[Bivalence for World-Histories]\label{thm:bivalence}
    For any world-history $\history : \mathsf{WorldHistory}(\mframe)$, model $\model$, time $x : D$, assignment $\assignment$, and temporal index $\tempindex$:
    \[
        \model, \history, x, \assignment, \tempindex \trueat \metaA \iff \model, \history, x, \assignment, \tempindex \nfalseat \metaA
    \]
\end{theorem}

\begin{remark}
    This bivalence property breaks down for non-maximal evolutions $\tau$ that are not world-histories.
\end{remark}
```

3. Address remaining FIX comments:
   - Line 278: Add remark about restricted quantifier variants (possibly actual, sometimes actual)
   - Line 406: Note that bimodal principles should move to proof theory section (future task)
   - Line 427: Note that temporal constraints should follow task constraints (future task)
   - Line 456: Update logical consequence to use type notation
   - Line 473: Note that full logic presentation is future work

4. Final verification:
   - Run `pdflatex` on the document
   - Check for undefined references
   - Verify no overfull hboxes in critical sections

**Verification**:
- Document compiles without errors or warnings
- All FIX comments removed or addressed
- Bivalence stated as theorem
- Cross-references resolve correctly

---

## Testing & Validation

- [ ] Document compiles with `pdflatex Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
- [ ] No undefined reference warnings
- [ ] BNF notation renders correctly with `\Define` macro
- [ ] Type-theoretic predicates render with `\mathsf{}` formatting
- [ ] Stability operator definition is complete and well-formed
- [ ] Containment theorem connects world-histories to world-states
- [ ] All FIX comments from original file are addressed

## Artifacts & Outputs

- `specs/682_fix_dynamics_foundation_latex_issues/plans/implementation-001.md` (this file)
- Modified: `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
- `specs/682_fix_dynamics_foundation_latex_issues/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If implementation introduces compilation errors or breaks document structure:
1. Revert `03-DynamicsFoundation.tex` using `git checkout HEAD -- Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
2. Apply changes incrementally, testing compilation after each phase
3. If specific macros are missing from `logos-notation.sty`, add them before using in document
