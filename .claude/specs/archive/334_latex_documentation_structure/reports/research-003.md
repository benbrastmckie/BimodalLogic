# Research Report: LaTeX Documentation from RECURSIVE_SEMANTICS.md

**Task**: 334 - Create LaTeX documentation structure for Logos system mirroring layer structure

**Date**: 2026-01-10

**Focus**: Systematic mapping of RECURSIVE_SEMANTICS.md content to LaTeX documentation structure with Lean 4 refactoring considerations

**Sources/Inputs**:
- docs/research/RECURSIVE_SEMANTICS.md (primary - 591 lines)
- docs/research/LAYER_EXTENSIONS.md (secondary)
- .claude/specs/334_latex_documentation_structure/reports/research-001.md (prior research)
- .claude/specs/334_latex_documentation_structure/reports/research-002.md (prior research)

---

## Executive Summary

This research report provides a systematic mapping from the newly restructured RECURSIVE_SEMANTICS.md to LaTeX documentation, superseding aspects of research-001.md that were based on LogicNotes.tex. The RECURSIVE_SEMANTICS.md document establishes a cleaner architecture with two well-developed layers (Constitutive Foundation, Core Extension) and four placeholder extensions (Epistemic, Normative, Spatial, Agential).

**Key Findings**:

1. **New Extension Architecture**: The document uses a new terminology:
   - **Constitutive Foundation**: Hyperintensional base with mereological state space
   - **Core Extension**: Modal, temporal, and counterfactual operators over task frames
   - **Modular Extensions**: Epistemic, Normative, Spatial (optional, parallel)
   - **Agential Extension**: Requires at least one modular extension

2. **Notation Conventions**: The document establishes consistent notation:
   - σ (sigma) for variable assignments (compatible across LaTeX, markdown, Lean)
   - i⃗ for temporal index (vector of stored times)
   - →_w for imposition (t →_w w' means "imposing t on w yields w'")
   - τ (tau) for world-histories

3. **Well-Specified Content**: The Constitutive Foundation and Core Extension contain complete formal specifications suitable for direct LaTeX transcription:
   - Verification/falsification clauses (14 operators)
   - Truth conditions (20+ operators)
   - Task relation constraints (6 constraints)
   - Perpetuity principles (6 principles)

4. **Placeholder Content**: Extensions marked [DETAILS] and [QUESTION: ...] require future development before LaTeX documentation.

**Recommendations**:

1. Structure LaTeX documentation as two subfile groups:
   - **Foundation**: 00-Introduction, 01-ConstitutiveFoundation
   - **Core**: 02-CoreExtension-Syntax, 03-CoreExtension-Semantics, 04-CoreExtension-Axioms

2. Use RECURSIVE_SEMANTICS.md section headers as LaTeX section structure

3. Implement LaTeX macros matching the document's notation conventions

4. Create stub subfiles for future extensions with [DETAILS] markers preserved

5. Design Lean module structure to mirror LaTeX documentation structure

---

## Section-by-Section Mapping

### RECURSIVE_SEMANTICS.md Structure

| Section | Lines | LaTeX Target | Lean Module Target |
|---------|-------|--------------|-------------------|
| Introduction | 10-62 | 00-Introduction.tex | - |
| Constitutive Foundation | 65-225 | 01-ConstitutiveFoundation.tex | Logos/Foundation/ |
| Core Extension | 228-464 | 02-03-04-CoreExtension*.tex | Logos/Core/ |
| Epistemic Extension | 467-496 | 05-Epistemic.tex (stub) | Logos/Extensions/Epistemic/ |
| Normative Extension | 499-528 | 06-Normative.tex (stub) | Logos/Extensions/Normative/ |
| Spatial Extension | 531-557 | 07-Spatial.tex (stub) | Logos/Extensions/Spatial/ |
| Agential Extension | 560-576 | 08-Agential.tex (stub) | Logos/Extensions/Agential/ |
| References | 580-591 | Bibliography | - |

---

## Constitutive Foundation: LaTeX Specification

### LaTeX Subfile: 01-ConstitutiveFoundation.tex

**Section Structure**:

```
1. Syntactic Primitives
   1.1 Variables and Constants
   1.2 Function Symbols and Predicates
   1.3 Sentence Letters
   1.4 Lambda Abstraction
   1.5 Logical Connectives

2. Constitutive Frame
   2.1 State Space
   2.2 Parthood Ordering
   2.3 Lattice Operations (Null, Full, Fusion)

3. Constitutive Model
   3.1 Interpretation Function
   3.2 Function Symbol Interpretation
   3.3 Predicate Interpretation (Verifier/Falsifier Functions)
   3.4 Containment Constraint

4. Variable Assignment
   4.1 Assignment Definition
   4.2 Term Extension

5. Verification and Falsification Clauses
   5.1 Atomic Formulas
   5.2 Lambda Abstraction
   5.3 Negation
   5.4 Conjunction
   5.5 Disjunction
   5.6 Top and Bottom
   5.7 Propositional Identity

6. Derived Relations
   6.1 Essence (⊑)
   6.2 Ground (≤)
   6.3 Bilattice Structure

7. Bilateral Propositions
   7.1 Definition (Exclusivity, Exhaustivity)
   7.2 Propositional Operations (Product, Sum)
   7.3 Conjunction and Disjunction on Propositions
   7.4 Negation on Propositions

8. Logical Consequence (Constitutive)
```

### Key LaTeX Content Extractions

**Frame Definition** (from lines 82-94):

```latex
\begin{definition}[Constitutive Frame]
A \emph{constitutive frame} is a structure $\mathbf{F} = \langle S, \sqsubseteq \rangle$ where:
\begin{itemize}
  \item $S$ is a nonempty set of \emph{states}
  \item $\sqsubseteq$ is a partial order on $S$ making $\langle S, \sqsubseteq \rangle$ a complete lattice
\end{itemize}
\end{definition}

\begin{remark}
The lattice structure provides:
\begin{itemize}
  \item \textbf{Null state} $\square$: The bottom element (fusion of the empty set)
  \item \textbf{Full state} $\blacksquare$: The top element (fusion of all states)
  \item \textbf{Fusion} $s \cdot t$: The least upper bound of $s$ and $t$
\end{itemize}
\end{remark}
```

**Verification Clauses** (from lines 130-179):

```latex
\begin{definition}[Verification and Falsification]
A state $s$ \emph{verifies} ($\Vdash^+$) or \emph{falsifies} ($\Vdash^-$) a formula $A$ relative to model $\mathbf{M}$ and assignment $\sigma$:

\paragraph{Atomic Formulas}
\begin{align}
\mathbf{M}, \sigma, s \Vdash^+ F(t_1,\ldots,t_n) &\iff \exists f \in v_F : s = f(\sem{t_1}^\sigma_\mathbf{M}, \ldots, \sem{t_n}^\sigma_\mathbf{M}) \\
\mathbf{M}, \sigma, s \Vdash^- F(t_1,\ldots,t_n) &\iff \exists f \in f_F : s = f(\sem{t_1}^\sigma_\mathbf{M}, \ldots, \sem{t_n}^\sigma_\mathbf{M})
\end{align}

\paragraph{Negation}
\begin{align}
\mathbf{M}, \sigma, s \Vdash^+ \neg A &\iff \mathbf{M}, \sigma, s \Vdash^- A \\
\mathbf{M}, \sigma, s \Vdash^- \neg A &\iff \mathbf{M}, \sigma, s \Vdash^+ A
\end{align}

\paragraph{Conjunction}
\begin{align}
\mathbf{M}, \sigma, s \Vdash^+ A \land B &\iff s = t \cdot u \text{ for some } t, u \text{ where } \mathbf{M}, \sigma, t \Vdash^+ A \text{ and } \mathbf{M}, \sigma, u \Vdash^+ B \\
\mathbf{M}, \sigma, s \Vdash^- A \land B &\iff \mathbf{M}, \sigma, s \Vdash^- A, \text{ or } \mathbf{M}, \sigma, s \Vdash^- B, \text{ or } \\
  &\quad\;\; s = t \cdot u \text{ for some } t, u \text{ where } \mathbf{M}, \sigma, t \Vdash^- A \text{ and } \mathbf{M}, \sigma, u \Vdash^- B
\end{align}

\paragraph{Propositional Identity}
\begin{align}
\mathbf{M}, \sigma, s \Vdash^+ A \equiv B &\iff s = \square \land \{t : \mathbf{M}, \sigma, t \Vdash^+ A\} = \{t : \mathbf{M}, \sigma, t \Vdash^+ B\} \\
  &\quad \land \{t : \mathbf{M}, \sigma, t \Vdash^- A\} = \{t : \mathbf{M}, \sigma, t \Vdash^- B\}
\end{align}
\end{definition}
```

**Bilateral Propositions** (from lines 199-214):

```latex
\begin{definition}[Bilateral Proposition]
A \emph{bilateral proposition} is an ordered pair $\langle V, F \rangle$ where:
\begin{itemize}
  \item $V$ and $F$ are subsets of $S$ closed under fusion
  \item $\langle V, F \rangle$ is \emph{exclusive}: states in $V$ are incompatible with states in $F$
  \item $\langle V, F \rangle$ is \emph{exhaustive}: every possible state is compatible with some state in $V$ or $F$
\end{itemize}
\end{definition}

\begin{definition}[Propositional Operations]
\begin{align}
X \otimes Y &:= \{s \cdot t : s \in X, t \in Y\} && \text{(Product)} \\
X \oplus Y &:= X \cup Y \cup (X \otimes Y) && \text{(Sum)} \\
\langle V, F \rangle \land \langle V', F' \rangle &:= \langle V \otimes V', F \oplus F' \rangle && \text{(Conjunction)} \\
\langle V, F \rangle \lor \langle V', F' \rangle &:= \langle V \oplus V', F \otimes F' \rangle && \text{(Disjunction)} \\
\neg\langle V, F \rangle &:= \langle F, V \rangle && \text{(Negation)}
\end{align}
\end{definition}
```

### Lean Module Mapping: Logos/Foundation/

| LaTeX Section | Lean File | Key Definitions |
|---------------|-----------|-----------------|
| 2. Constitutive Frame | Frame.lean | `ConstitutiveFrame`, `StateSpace`, `Parthood` |
| 3. Constitutive Model | Model.lean | `ConstitutiveModel`, `Interpretation` |
| 4. Variable Assignment | Assignment.lean | `Assignment`, `termExtension` |
| 5. Verification/Falsification | Semantics.lean | `verifies`, `falsifies` |
| 6. Derived Relations | Relations.lean | `essence`, `ground` |
| 7. Bilateral Propositions | Proposition.lean | `BilateralProp`, `product`, `sum` |

---

## Core Extension: LaTeX Specification

### LaTeX Subfiles: 02-03-04-CoreExtension*.tex

**02-CoreExtension-Syntax.tex**:
```
1. Additional Syntactic Primitives
   1.1 Modal Operators (□, ◇)
   1.2 Temporal Operators (H, G, P, F)
   1.3 Extended Temporal Operators (◁, ▷)
   1.4 Counterfactual Conditional (□→)
   1.5 Store/Recall Operators (↑ⁱ, ↓ⁱ)
```

**03-CoreExtension-Semantics.tex**:
```
1. Core Frame
   1.1 Temporal Order (Totally Ordered Abelian Group)
   1.2 Task Relation
   1.3 State Modality Definitions
   1.4 Task Relation Constraints

2. World-History
   2.1 Definition
   2.2 Convexity Constraint
   2.3 Task Constraint

3. Core Model
   3.1 Extended Interpretation

4. Truth Conditions
   4.1 Evaluation Context (τ, x, σ, i⃗)
   4.2 Atomic Sentences
   4.3 Lambda Abstraction
   4.4 Universal Quantifier
   4.5 Actuality Predicate
   4.6 Extensional Connectives
   4.7 Modal Operators
   4.8 Core Tense Operators
   4.9 Extended Tense Operators
   4.10 Counterfactual Conditional
   4.11 Store and Recall Operators

5. Bimodal Interaction Principles
   5.1 Perpetuity Principles P1-P6

6. Temporal Frame Constraints

7. Logical Consequence (Core Extension)
```

**04-CoreExtension-Axioms.tex**:
```
1. Counterfactual Logic Axiom Schemata
   1.1 Core Rules (R1)
   1.2 Core Axioms (C1-C7)
   1.3 Modal Axioms (M1-M5)
```

### Key LaTeX Content Extractions

**Core Frame** (from lines 245-252):

```latex
\begin{definition}[Core Frame]
A \emph{core frame} is a structure $\mathbf{F} = \langle S, \sqsubseteq, D, \Rightarrow \rangle$ where:
\begin{itemize}
  \item $\langle S, \sqsubseteq \rangle$ is a constitutive frame
  \item $D = \langle D, +, \leq \rangle$ is a totally ordered abelian group (temporal order)
  \item $\Rightarrow$ is a ternary relation on $S \times D \times S$ (task relation)
\end{itemize}
\end{definition}

\begin{notation}
We write $s \Rightarrow_d t$ (read: ``there is a task from $s$ to $t$ of duration $d$'').
\end{notation}
```

**State Modality Definitions** (from lines 255-267):

```latex
\begin{definition}[State Modality]
\begin{tabular}{ll}
\textbf{Possible state} & $s \in P$ iff $s \Rightarrow_0 s$ \\
\textbf{Impossible state} & $s \notin P$ iff $\neg(s \Rightarrow_0 s)$ \\
\textbf{Connected} & $s \sim t$ iff $s \Rightarrow_d t$ or $t \Rightarrow_d s$ for some $d$ \\
\textbf{Compatible states} & $s \circ t$ iff $s \cdot t \in P$ \\
\textbf{Maximal $t$-compatible part} & $s \in r_t$ iff $s \sqsubseteq r$, $s \circ t$, and $s' \sqsubseteq s$ for all $s'$ where $s \sqsubseteq s' \sqsubseteq r$ and $s' \circ t$ \\
\textbf{Maximal state} & $s$ is maximal iff $t \sqsubseteq s$ for every compatible state $t \circ s$ \\
\textbf{World-state} & $w \in W$ iff $w$ is a maximal possible state \\
\textbf{Necessary state} & $s \in N$ iff $s \sim t$ implies $s = t$
\end{tabular}
\end{definition}
```

**Task Relation Constraints** (from lines 269-279):

```latex
\begin{definition}[Task Relation Constraints]
\begin{description}
\item[Compositionality] If $s \Rightarrow_x t$ and $t \Rightarrow_y u$, then $s \Rightarrow_{x+y} u$
\item[Parthood (Left)] If $d \sqsubseteq s$ and $s \Rightarrow_x t$, then $d \Rightarrow_x r$ for some $r \sqsubseteq t$
\item[Parthood (Right)] If $r \sqsubseteq t$ and $s \Rightarrow_x t$, then $d \Rightarrow_x r$ for some $d \sqsubseteq s$
\item[Containment (L)] If $s \in P$, $d \sqsubseteq s$, and $d \Rightarrow_x r$, then $s \Rightarrow_x t \cdot r$ for some $t \in S$
\item[Containment (R)] If $t \in P$, $r \sqsubseteq t$, and $d \Rightarrow_x r$, then $s \cdot d \Rightarrow_x t$ for some $s \in S$
\item[Maximality] If $s \in S$ and $t \in P$, there is a maximal $t$-compatible part $r \in s_t$
\end{description}
\end{definition}
```

**World-History** (from lines 281-289):

```latex
\begin{definition}[World-History]
A \emph{world-history} over a causal frame $\mathbf{F}$ is a function $\tau : X \to W$ where:
\begin{itemize}
  \item $X \subseteq D$ is a convex subset of the temporal order
  \item $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$ where $x \leq y$
\end{itemize}
\end{definition}

\begin{notation}
The set of all world-histories over $\mathbf{F}$ is denoted $H_\mathbf{F}$.
\end{notation}
```

**Truth Evaluation Context** (from lines 297-299):

```latex
\begin{definition}[Truth Evaluation]
Truth is evaluated relative to:
\begin{itemize}
  \item Model $\mathbf{M}$
  \item World-history $\tau \in H_\mathbf{F}$
  \item Time $x \in D$
  \item Variable assignment $\sigma$
  \item Temporal index $\vec{\imath} = \langle i_1, i_2, \ldots \rangle$
\end{itemize}
\end{definition}
```

**Counterfactual Conditional** (from lines 384-398):

```latex
\begin{definition}[Counterfactual Conditional]
\textbf{Mereological formulation}:
\[
\mathbf{M}, \tau, x, \sigma, \vec{\imath} \models \varphi \boxright C \iff
\]
for all $t \in v_\varphi$ and $\beta \in H_\mathbf{F}$: if $s \cdot t \sqsubseteq \beta(x)$ for some maximal $t$-compatible part $s \in \tau(x)_t$, then $\mathbf{M}, \beta, x, \sigma, \vec{\imath} \models C$

Where:
\begin{itemize}
  \item $v_\varphi$ is the set of exact verifiers for $\varphi$
  \item $\tau(x)_t$ is the set of maximal $t$-compatible parts of $\tau(x)$
\end{itemize}
\end{definition}

\begin{definition}[Imposition]
We write $t \to_w w'$ (``imposing $t$ on $w$ yields $w'$'') iff there exists maximal $t$-compatible part $s \in w_t$ where $s \cdot t \sqsubseteq w'$.
\end{definition}
```

**Perpetuity Principles** (from lines 412-424):

```latex
\begin{theorem}[Perpetuity Principles]
The task semantics validates:
\begin{align}
\textbf{P1} &\quad \Box\varphi \to \triangle\varphi && \text{Necessary implies always} \\
\textbf{P2} &\quad \triangledown\varphi \to \Diamond\varphi && \text{Sometimes implies possible} \\
\textbf{P3} &\quad \Box\triangle\varphi \leftrightarrow \triangle\Box\varphi && \text{Necessary-always commutativity} \\
\textbf{P4} &\quad \Diamond\triangledown\varphi \leftrightarrow \triangledown\Diamond\varphi && \text{Possible-sometimes commutativity} \\
\textbf{P5} &\quad \Box\varphi \to \Box\triangle\varphi && \text{Necessary implies necessary-always} \\
\textbf{P6} &\quad \triangledown\Diamond\varphi \to \Diamond\varphi && \text{Sometimes-possible implies possible}
\end{align}
\end{theorem}
```

### Lean Module Mapping: Logos/Core/

| LaTeX Section | Lean File | Key Definitions |
|---------------|-----------|-----------------|
| 1. Core Frame | Frame.lean | `CoreFrame`, `TemporalOrder`, `TaskRelation` |
| 2. State Modality | Modality.lean | `possible`, `compatible`, `maximal`, `worldState` |
| 3. Task Constraints | Constraints.lean | `Compositionality`, `Parthood`, `Containment`, `Maximality` |
| 4. World-History | History.lean | `WorldHistory`, `H_F` |
| 5. Core Model | Model.lean | `CoreModel` |
| 6. Truth Conditions | Semantics.lean | `satisfies` (⊨) |
| 7. Perpetuity | Perpetuity.lean | `P1`-`P6` |
| 8. Axioms | Axioms.lean | `C1`-`C7`, `M1`-`M5`, `R1` |

---

## LaTeX Macro Definitions

### File: logos-notation.sty

```latex
% ============================================================================
% Logos Notation Package
% ============================================================================

\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{logos-notation}[2026/01/10 Logos Logic Notation]

% --------------------------------------------------------------------------
% Constitutive Foundation
% --------------------------------------------------------------------------

% State space
\newcommand{\statespace}{S}
\newcommand{\nullstate}{\square}
\newcommand{\fullstate}{\blacksquare}
\newcommand{\fusion}[2]{#1 \cdot #2}
\newcommand{\parthood}{\sqsubseteq}

% Verification and falsification
\newcommand{\verifies}{\Vdash^+}
\newcommand{\falsifies}{\Vdash^-}
\newcommand{\verifierset}[1]{v_{#1}}
\newcommand{\falsifierset}[1]{f_{#1}}

% Propositional operations
\newcommand{\product}{\otimes}
\newcommand{\psum}{\oplus}
\newcommand{\propid}{\equiv}

% Derived relations
\newcommand{\essence}{\sqsubseteq}
\newcommand{\ground}{\leq}

% Variable assignment
\newcommand{\assignment}{\sigma}
\newcommand{\assignsub}[2]{\sigma[#1/#2]}
\newcommand{\sem}[1]{\llbracket #1 \rrbracket}

% --------------------------------------------------------------------------
% Core Extension
% --------------------------------------------------------------------------

% Temporal order
\newcommand{\temporalorder}{D}
\newcommand{\timelt}{<}
\newcommand{\timeleq}{\leq}

% Task relation
\newcommand{\task}[3]{#1 \Rightarrow_{#2} #3}
\newcommand{\taskrel}{\Rightarrow}

% State modality
\newcommand{\possible}{P}
\newcommand{\compatible}{\circ}
\newcommand{\connected}{\sim}
\newcommand{\worldstates}{W}
\newcommand{\necessary}{N}
\newcommand{\maxcompat}[2]{#1_{#2}}

% World-history
\newcommand{\history}{\tau}
\newcommand{\historyspace}{H_\mathbf{F}}

% Temporal index
\newcommand{\tempindex}{\vec{\imath}}

% Truth evaluation
\newcommand{\satisfies}{\models}
\newcommand{\notsatisfies}{\not\models}

% Modal operators
\newcommand{\nec}{\Box}
\newcommand{\poss}{\Diamond}

% Temporal operators (core)
\newcommand{\always}{H}  % always past
\newcommand{\willalways}{G}  % always future
\newcommand{\waspast}{P}  % some past
\newcommand{\willfuture}{F}  % some future

% Temporal operators (derived)
\newcommand{\alwaystemporal}{\triangle}  % at all times
\newcommand{\sometimestemporal}{\triangledown}  % at some time

% Extended temporal operators
\newcommand{\since}{\triangleleft}
\newcommand{\until}{\triangleright}

% Counterfactual
\newcommand{\boxright}{\Box\!\to}
\newcommand{\imposition}[2]{#1 \to_{#2}}

% Store/recall
\newcommand{\store}[1]{\uparrow^{#1}}
\newcommand{\recall}[1]{\downarrow^{#1}}

% Actuality
\newcommand{\actual}{\mathsf{Act}}

% --------------------------------------------------------------------------
% Model notation
% --------------------------------------------------------------------------

\newcommand{\frame}{\mathbf{F}}
\newcommand{\model}{\mathbf{M}}
\newcommand{\interp}{I}

% Meta-variables for formulas
\newcommand{\metaA}{A}
\newcommand{\metaB}{B}
\newcommand{\metaC}{C}
\newcommand{\metaphi}{\varphi}
\newcommand{\metapsi}{\psi}

% Semantic brackets
\RequirePackage{stmaryrd}  % for \llbracket, \rrbracket

% --------------------------------------------------------------------------
% Cross-reference to Lean
% --------------------------------------------------------------------------

\newcommand{\leansrc}[2]{\texttt{#1.#2}}
\newcommand{\leanref}[1]{\texttt{#1}}
```

---

## Extension Stub Structure

### Epistemic Extension (05-Epistemic.tex)

From RECURSIVE_SEMANTICS.md lines 467-496, extract structure for stub:

```latex
\section{Epistemic Extension}

\textsc{[Details pending development]}

The Epistemic Extension extends the Core Extension with structures for belief, knowledge, and probability.

\subsection{Frame Extension}

\textsc{[Details pending development]}

The epistemic frame extends the core frame with a credence function assigning probabilities to state transitions.

\begin{question}
What is the exact structure of the credence function? Does it assign probabilities to individual state transitions or to sets of transitions?
\end{question}

\subsection{Operators}

\begin{tabular}{ll}
$B_a \varphi$ & Agent $a$ believes that $\varphi$ \\
$K_a \varphi$ & Agent $a$ knows that $\varphi$ \\
$\Pr(\varphi) \geq r$ & The probability of $\varphi$ is at least $r$
\end{tabular}

\textsc{[Full semantic clauses pending specification]}

\subsection{Indicative Conditionals}

\textsc{[Details pending development]}

\begin{question}
How do indicative conditionals relate to counterfactual conditionals in the semantic framework?
\end{question}
```

Similar stubs for Normative (06), Spatial (07), and Agential (08) extensions.

---

## Lean 4 Refactoring Considerations

### Current vs. Proposed Module Structure

The RECURSIVE_SEMANTICS.md structure suggests a cleaner module organization than the current Logos implementation:

**Current Structure** (from codebase):
```
Logos/
├── Core/
│   ├── Syntax/
│   └── Semantics/
├── Layer0/
├── Layer1/
└── Shared/
```

**Proposed Structure** (from RECURSIVE_SEMANTICS.md):
```
Logos/
├── Foundation/           -- Constitutive Foundation
│   ├── Frame.lean       -- ConstitutiveFrame
│   ├── Model.lean       -- ConstitutiveModel, Interpretation
│   ├── Assignment.lean  -- Variable assignment, term extension
│   ├── Semantics.lean   -- Verification/falsification clauses
│   ├── Relations.lean   -- Essence, Ground
│   └── Proposition.lean -- BilateralProp
│
├── Core/                 -- Core Extension
│   ├── Frame.lean       -- CoreFrame
│   ├── Modality.lean    -- State modality definitions
│   ├── Constraints.lean -- Task relation constraints
│   ├── History.lean     -- World-History
│   ├── Model.lean       -- CoreModel
│   ├── Semantics.lean   -- Truth conditions
│   ├── Perpetuity.lean  -- P1-P6
│   └── Axioms.lean      -- C1-C7, M1-M5, R1
│
└── Extensions/           -- Modular extensions
    ├── Epistemic/
    ├── Normative/
    ├── Spatial/
    └── Agential/
```

### Type Correspondences

| RECURSIVE_SEMANTICS.md | LaTeX | Lean |
|------------------------|-------|------|
| State space S | $\statespace$ | `StateSpace : Type` |
| Parthood ⊑ | $\parthood$ | `Parthood : StateSpace → StateSpace → Prop` |
| Temporal order D | $\temporalorder$ | `TemporalOrder : Type` |
| Task relation ⇒ | $\taskrel$ | `TaskRel : StateSpace → TemporalOrder → StateSpace → Prop` |
| World-history τ | $\history$ | `WorldHistory : ConvexSet D → WorldState` |
| Variable assignment σ | $\assignment$ | `Assignment : Var → StateSpace` |
| Temporal index i⃗ | $\tempindex$ | `TemporalIndex : List D` |

### Verification/Falsification in Lean

The bilateral verification/falsification clauses suggest a Lean type:

```lean
inductive VerificationResult where
  | verifies : VerificationResult
  | falsifies : VerificationResult
  | neither : VerificationResult

def evaluate : Model → Assignment → StateSpace → Formula → VerificationResult
```

Or using bilateral propositions directly:

```lean
structure BilateralProp (S : Type) where
  verifiers : Set S
  falsifiers : Set S
  exclusive : ∀ s, s ∈ verifiers → s ∈ falsifiers → False
  exhaustive : ∀ s, Possible s → (∃ v ∈ verifiers, Compatible s v) ∨ (∃ f ∈ falsifiers, Compatible s f)
```

---

## Recommendations

### Recommendation 1: Two-Phase Documentation

**Phase A**: Constitutive Foundation + Core Extension (complete content)
- Create subfiles 01-04 with full formal specifications
- Implement corresponding Lean modules

**Phase B**: Extension Stubs (placeholder content)
- Create subfiles 05-08 with [DETAILS] markers preserved
- Implement Lean module stubs with `sorry` placeholders

### Recommendation 2: Consistent Notation

Adopt the notation conventions from RECURSIVE_SEMANTICS.md throughout:
- σ for variable assignments (not τ which is reserved for world-histories)
- i⃗ for temporal index
- →_w for imposition

### Recommendation 3: LaTeX-Lean Correspondence

Each LaTeX definition should have a corresponding Lean definition:
- Use `\leansrc{Module}{definition}` macro to cross-reference
- Maintain parallel structure between subfiles and modules

### Recommendation 4: Progressive Development

1. **First**: Create LaTeX documentation from complete content
2. **Second**: Implement Lean modules matching documentation
3. **Third**: Add Lean proofs for stated theorems (e.g., perpetuity principles)
4. **Fourth**: Fill in [DETAILS] as theoretical development proceeds

### Recommendation 5: Preserve Questions

The [QUESTION: ...] tags in RECURSIVE_SEMANTICS.md identify open research questions. These should be preserved in LaTeX stubs using a consistent format:

```latex
\begin{question}
How do indicative conditionals relate to counterfactual conditionals in the semantic framework?
\end{question}
```

---

## Implementation Checklist

### LaTeX Documentation

- [ ] Create logos-notation.sty with macros
- [ ] Create 00-Introduction.tex (from Introduction section)
- [ ] Create 01-ConstitutiveFoundation.tex (from lines 65-225)
- [ ] Create 02-CoreExtension-Syntax.tex (from lines 233-240)
- [ ] Create 03-CoreExtension-Semantics.tex (from lines 243-438)
- [ ] Create 04-CoreExtension-Axioms.tex (from lines 440-464)
- [ ] Create 05-Epistemic.tex stub (from lines 467-496)
- [ ] Create 06-Normative.tex stub (from lines 499-528)
- [ ] Create 07-Spatial.tex stub (from lines 531-557)
- [ ] Create 08-Agential.tex stub (from lines 560-576)
- [ ] Create LogosReference.tex main document

### Lean Refactoring

- [ ] Create Logos/Foundation/ module directory
- [ ] Create Logos/Core/ module directory (refactor existing)
- [ ] Create Logos/Extensions/ module directory structure
- [ ] Implement bilateral proposition type
- [ ] Implement verification/falsification semantics
- [ ] Implement task relation constraints
- [ ] Implement world-history type
- [ ] Implement truth evaluation
- [ ] Prove perpetuity principles P1-P6

---

## References

- RECURSIVE_SEMANTICS.md - Primary source document
- LAYER_EXTENSIONS.md - Extension architecture
- research-001.md - Prior research on LogicNotes.tex approach
- research-002.md - Prior research on constitutive/causal layers
- Fine, K. (2017). "Truthmaker Semantics"
- Brast-McKie, B. "Possible Worlds" (JPL)
- Brast-McKie, B. "Counterfactual Worlds" (JPL)

---

**End of Research Report**
