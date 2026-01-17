# Research Report: Task #456

**Task**: 456 - Address TODOs in Bimodal Semantics LaTeX
**Started**: 2026-01-12T14:30:00Z
**Completed**: 2026-01-12T14:45:00Z
**Effort**: medium
**Priority**: normal
**Dependencies**: None
**Sources/Inputs**:
- Target file: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/02-Semantics.tex`
- Authoritative reference: `/home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
- Lean implementation files: `Theories/Bimodal/Semantics/*.lean`
**Artifacts**:
- This report: `specs/456_address_todos_in_bimodal_semantics_latex/reports/research-001.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Found **17 TODO comments** in `02-Semantics.tex` requiring attention
- TODOs fall into 4 categories: structural reorganization, terminology changes, style improvements, and notation alignment with the paper
- Key changes include: using tables for primitive types, using "sentence letters" instead of "atomic propositions", using lowercase `x`, `y`, `z` for time variables, using paper's `\approx` notation for time-shift, and removing redundant Lean tables
- All changes should align with the JPL paper notation and maintain semantic linefeeds (one sentence per line) per `.claude/rules/latex.md`

## Context & Scope

The target file `02-Semantics.tex` documents the task semantics for bimodal logic TM, including:
- Task frames (Definition 1)
- World histories (Definition 3)
- Task models (Definition 4)
- Truth conditions (Definition 5)
- Time-shift operations
- Logical consequence and validity

The TODOs request improvements to presentation, terminology, and notation to better align with the authoritative JPL paper.

## Findings

### TODO 1: Restructure Task Frame Definition (Line 11)

**Location**: Line 11
**Context**: Before Definition [Task Frame]
**TODO Text**:
```
% TODO: I don't like how this goes below. Instead I want to introduce the primitives first (the first bullet points) but using a table instead of bullet points to characterize these primitive types. Only then should the definition be given using the types that have been introduced in this table, where the definition can then be asserted somewhat more directly by defining the type of the task frame and imposing the constraints. It is also important that the constraints respect types (they types should not be omitted anywhere there is quantification throughout this document).
```

**Research**:
The JPL paper (line 862) defines frames as `F = (W, D, =>)` where:
- W is a nonempty set of world states
- D is a temporal order
- `=>` satisfies nullity and compositionality constraints

The current presentation mixes type introduction with constraints. The TODO requests:
1. First: a table introducing primitive types
2. Then: a definition that uses those types and states constraints

**Recommendation**:
Create a table like:
```latex
\begin{center}
\begin{tabular}{@{}lll@{}}
\toprule
Primitive & Type & Description \\
\midrule
$\worldstate$ & Type & World states (complete instantaneous total states) \\
$T$ & Type & Temporal durations with ordered abelian group structure \\
$w \taskto{x} u$ & $\worldstate \to T \to \worldstate \to \text{Prop}$ & Task relation \\
\bottomrule
\end{tabular}
\end{center}
```

Then define: "A task frame over temporal type $T$ is a structure $\taskframe : \worldstate \times T \times (\worldstate \to T \to \worldstate \to \text{Prop})$ satisfying:"
- **Nullity**: $\forall (w : \worldstate).\, w \taskto{0} w$
- **Compositionality**: $\forall (w\, u\, v : \worldstate)\, (x\, y : T).\, w \taskto{x} u \land u \taskto{y} v \to w \taskto{x+y} v$

---

### TODO 2: Remove Lean Field Table (Line 31)

**Location**: Line 31
**Context**: After Task Frame definition
**TODO Text**: `% TODO: so long as the types for the primitives are provided, this table below can be omitted`

**Research**:
The Lean field table (lines 33-44) is redundant if the primitives table is added above. The Lean-specific implementation details can be moved to a separate appendix or removed entirely for a cleaner presentation.

**Recommendation**:
Remove lines 33-44 (the Lean field table) once the primitives table is introduced in the definition. The document should present the mathematical formulation, not implementation details.

---

### TODO 3: Replace "respects the task relation" with "lawful" (Line 59)

**Location**: Line 59
**Context**: Before Definition [Respects Task]
**TODO Text**: `% TODO: replace 'respects the task relation' with 'lawfull', fixing the grammar accordingly`

**Research**:
The paper (line 868) defines world histories as functions `tau : X -> W` where "tau(x) =>_{y-x} tau(y) for all times x, y in X where x <= y". The paper doesn't use a special term like "lawful" but states the constraint directly.

**Recommendation**:
Instead of introducing "lawful" as a separate term, fold the constraint directly into the World History definition (see TODO 6). If a term is needed, use "task-respecting" or simply state the constraint inline. The term "lawful" may work but should be consistent throughout.

---

### TODO 4: Don't Use Dashes in Constraints (Line 69)

**Location**: Line 69
**Context**: Before Definition [World History]
**TODO Text**: `% TODO: don't use the dashes below, use simple sentences that state each constraint in a natural and direct way`

**Research**:
The current definition uses em-dashes (---) to describe constraints. The TODO requests natural sentence form instead.

**Recommendation**:
Replace bullet points with dashes like:
```latex
\item $\domain : T \to \text{Prop}$ --- a convex temporal domain
```
With natural sentences:
```latex
$\domain$ is a predicate on $T$ specifying a convex temporal domain.
```

Or use a proper definition format:
```latex
Let $\domain : T \to \text{Prop}$ be a convex temporal domain predicate.
Let $\tau : (t : T) \to \domain(t) \to \worldstate$ be the world state assignment.
$\tau$ is lawful: for all $s, t : T$ with $\domain(s)$ and $\domain(t)$ and $s \le t$, we have $\tau(s) \taskto{t-s} \tau(t)$.
```

---

### TODO 5: Specify Type for World History (Line 71)

**Location**: Line 71
**Context**: Before Definition [World History]
**TODO Text**: `% TODO: don't say structure, say what the type of \tau is where it has domain dom that is convex and is lawful.`

**Research**:
The paper (line 868) defines: "I will define a world history to be a function tau : X -> W where X is convex and tau(x) =>_{y-x} tau(y) for all x, y in X where x <= y."

**Recommendation**:
Replace "is a structure $\tau$" with explicit type:
```latex
A \textbf{world history} in task frame $\taskframe$ is a dependent function:
\[
\tau : (t : T) \to \domain(t) \to \worldstate
\]
where $\domain : T \to \text{Prop}$ is convex and $\tau$ satisfies...
```

---

### TODO 6: Fold Lawful Definition into World History (Line 73)

**Location**: Line 73
**Context**: Before Definition [World History]
**TODO Text**: `% TODO: fold the definition above into the definition below, avoiding the need for an extra term 'lawful' by simply stating the lawful constraint in the definition of a world history. Despite using types, this should follow the definition in line 868 in /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`

**Research**:
JPL paper line 868:
> "I will define a world history to be a function tau : X -> W where X is a convex subset of D and tau(x) =>_{y-x} tau(y) for all times x, y in X where x <= y."

This is a single unified definition without separate "respects task" definition.

**Recommendation**:
Merge Definition [Respects Task] into Definition [World History]:
```latex
\begin{definition}[World History]
A \textbf{world history} in task frame $\taskframe$ is a dependent function $\tau : (t : T) \to \domain(t) \to \worldstate$ where:
\begin{itemize}
  \item $\domain : T \to \text{Prop}$ is a convex subset of $T$
  \item For all $s, t : T$ with $\domain(s)$, $\domain(t)$, and $s \le t$: $\tau(s) \taskto{t-s} \tau(t)$
\end{itemize}
We write $\histories_{\taskframe}$ for the set of all world histories over frame $\taskframe$.
\end{definition}
```

Remove the separate "Respects Task" definition (lines 61-67) and "Convex Domain" can stay separate or be folded in.

---

### TODO 7: Remove Lean Table for World History (Line 85)

**Location**: Line 85
**Context**: After Definition [World History]
**TODO Text**: `% TODO: this next table can be removed`

**Research**:
Like TODO 2, this Lean implementation table (lines 87-98) is redundant if types are properly specified in the definition.

**Recommendation**:
Remove lines 87-98 (the Lean field table for World History).

---

### TODO 8: Use "Sentence Letters" not "Atomic Propositions" (Line 102)

**Location**: Line 102
**Context**: Before Task Models subsection
**TODO Text**: `% TODO: use 'sentence letters' in place of 'atomic propositions' throughout. Never use 'atomic proposition' anywhere.`

**Research**:
The JPL paper consistently uses "sentence letters" (e.g., line 889: "V(p_i) for every sentence letter p_i in SL"). This terminology distinguishes the syntactic symbols from the semantic propositions they express.

**Recommendation**:
Replace all occurrences of "atomic proposition" with "sentence letter":
- Line 104: "an interpretation function that assigns truth values to sentence letters at world states"
- Line 110: "Sentence letters express propositions..."
- Line 120: "assigns truth values to sentence letters at each world state"

Global search-and-replace: "atomic proposition" -> "sentence letter"

---

### TODO 9: Define Propositions as Sets of World States (Line 106)

**Location**: Line 106
**Context**: Before Task Model definition
**TODO Text**: `% TODO: define propositions as sets of world states which represent instantaneous ways for a syste to be.`

**Research**:
The JPL paper (line 889) defines the interpretation: "V(p_i) ⊆ W for every sentence letter p_i in SL". Propositions are subsets of world states.

**Recommendation**:
Add a sentence or short definition:
```latex
\textbf{Propositions} are subsets of $\worldstate$ representing instantaneous ways for the system to be.
Sentence letters are assigned propositions by the interpretation function.
```

Or integrate into the model definition: "The interpretation function $I : \text{String} \to \mathcal{P}(\worldstate)$ assigns each sentence letter a proposition (set of world states) where..."

---

### TODO 10: Don't Use Dashes (Line 108)

**Location**: Line 108
**Context**: Before explanation of propositions
**TODO Text**: `% TODO: don't use dashes. use natural sentences to speak directly.`

**Research**:
Line 110 currently says: "express **propositions**---instantaneous ways for the system to be"

**Recommendation**:
Rewrite as: "Sentence letters express propositions, which are instantaneous ways for the system to be that can be realized by zero or more world states."

---

### TODO 11: Specify Types Explicitly (Line 113)

**Location**: Line 113
**Context**: Before Definition [Task Model]
**TODO Text**: `% TODO: specify types explicitly when stating definitions`

**Research**:
The current definition doesn't specify all types explicitly.

**Recommendation**:
Make types explicit:
```latex
\begin{definition}[Task Model]
A \textbf{task model} over frame $\taskframe$ is a pair $\model = (\taskframe, I)$ where the interpretation function:
\[
I : \worldstate \to \text{String} \to \text{Prop}
\]
assigns to each world state $w : \worldstate$ and sentence letter $p : \text{String}$ a truth value $I(w, p) : \text{Prop}$.
\end{definition}
```

---

### TODO 12: Use x, y, z for Times; Times Not Restricted to Domain (Line 126)

**Location**: Line 126
**Context**: Before Truth Conditions
**TODO Text**: `% TODO: use 'x', 'y', 'z', etc., for times. Also, the time in the definition below is NOT restricted to the domain but may be ANY time in the frame. The same is true in the clauses for the tense operators.`

**Research**:
The JPL paper (lines 890-898) uses `x, y` for times consistently:
- "evaluated at a possible world tau in H_F and time x in D"
- "M,tau,x |= Past phi iff M,tau,y |= phi for all y in D where y < x"

The paper quantifies over ALL times in D, not just domain(tau). This is semantically significant.

**Recommendation**:
1. Change variable names: `t, s` -> `x, y` throughout Truth Conditions
2. Change "time $t \in \domain(\tau)$" to "time $x : T$" (or "time $x \in T$")
3. For tense operators, quantify over all times in T:
   - "for all $y : T$ where $y < x$" (not restricted to domain)

This matches the paper's semantic clauses exactly.

---

### TODO 13: Time-Shift Motivation - Perpetuity Theorems (Line 154)

**Location**: Line 154
**Context**: Time-Shift subsection
**TODO Text**: `% TODO: relating truths at different times is not the reason this has been defined. Rather it is to establish the perpetuity theorems. Say this, and briefly sketch what these theorems say, and why they are plausible. See line 436 in /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex for simple motivation.`

**Research**:
JPL paper line 436: "It is natural to assume that whatever is metaphysically necessary is always the case, or equivalently, whatever is sometimes the case is metaphysically possible."

The perpetuity principles (P1 and P2) are:
- P1: `Box phi -> always phi` (necessary implies always)
- P2: `sometimes phi -> Diamond phi` (sometimes implies possible)

Time-shift is needed to prove MF (`Box phi -> Box F phi`) and TF (`Box phi -> F Box phi`) which are key axioms for deriving the perpetuity principles.

**Recommendation**:
Replace lines 154-158 with:
```latex
The time-shift operation is fundamental for establishing the \textbf{perpetuity theorems}:
\begin{enumerate}
  \item P1: $\nec\varphi \imp \always\varphi$ (what is necessary is always the case)
  \item P2: $\sometimes\varphi \imp \poss\varphi$ (what is sometimes the case is possible)
\end{enumerate}
These principles are intuitively plausible: if something is metaphysically necessary, it should be the case at all times.
Time-shift preserves truth at different times within the same possible world, enabling proofs of the bimodal axioms MF ($\nec\varphi \imp \nec\allfuture\varphi$) and TF ($\nec\varphi \imp \allfuture\nec\varphi$).
```

---

### TODO 14: Consistent Type Notation (Line 159)

**Location**: Line 159
**Context**: Time-Shift definition
**TODO Text**: `% TODO: I don't like the informal 'Given a history \tau...' and instead want consistent type notation to be used to get readers accustomed to this way of setting things out. This needs to be maintained uniformly everywhere throughout these latex subfiles documents.`

**Research**:
The LaTeX file 01-Syntax.tex uses a consistent pattern of stating types directly in definitions.

**Recommendation**:
Replace "Given history $\tau$ and offset $\Delta : T$" with typed form:
```latex
Let $\tau : \text{WorldHistory}$ and $x : T$.
The \textbf{time-shifted history} $\tau^{+x}$ (or $\tau \approx_y^x \sigma$) is defined by...
```

Or use the paper's notation with explicit types:
```latex
For $\tau \in \histories_{\taskframe}$ and $x : T$, define $\tau^{+x} \in \histories_{\taskframe}$ by...
```

---

### TODO 15: Use Duration Variable x, Not Greek Letter (Line 160)

**Location**: Line 160
**Context**: Time-Shift definition
**TODO Text**: `% TODO: the offset should be 'x' which is a duration, not a upper case greek letter! Maintain consistent notation conventions.`

**Research**:
The current definition uses $\Delta$ for the offset. The paper uses lowercase variables like `x`, `y`, `z` for times/durations.

**Recommendation**:
Replace $\Delta$ with $x$ or use the paper's notation. In def:time-shift-histories (line 1877), the paper writes:
"tau approx_y^x sigma" meaning "tau time-shifted from y to x equals sigma"

Use: "offset $x : T$" instead of "$\Delta : T$"

---

### TODO 16: Use Paper's Time-Shift Notation (Line 163)

**Location**: Line 163
**Context**: Before Definition [Time-Shift]
**TODO Text**: `% TODO: use the notation used in def:time-shift-histories from line 1877 in /home/benjamin/Projects/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`

**Research**:
JPL paper def:time-shift-histories (line 1877-1878):
> "Given a frame F = (W, D, =>), world histories tau, sigma in H_F are time-shifted from y to x---written tau approx_y^x sigma---if and only if there exists an order automorphism a : D -> D where y = a(x), dom(sigma) = a^{-1}(dom(tau)), and sigma(z) = tau(a(z)) for all z in dom(sigma)."

The notation is: $\tau \approx_y^x \sigma$ (tau is time-shifted from y to x, resulting in sigma)

**Recommendation**:
Rewrite the Time-Shift definition to match the paper:
```latex
\begin{definition}[Time-Shift]
Given frame $\taskframe$, world histories $\tau, \sigma \in \histories_{\taskframe}$ are \textbf{time-shifted from $y$ to $x$}---written $\tau \approx_y^x \sigma$---if and only if there exists an order automorphism $\bar{a} : T \to T$ where $y = \bar{a}(x)$, $\domain_\sigma = \bar{a}^{-1}(\domain_\tau)$, and $\sigma(z) = \tau(\bar{a}(z))$ for all $z \in \domain_\sigma$.
\end{definition}
```

This replaces the current `\leanTimeShift(\tau, \Delta)` notation with the paper's `\tau \approx_y^x \sigma` notation.

---

### TODO 17: Replace \leanTimeShift with Paper Notation (Line 176)

**Location**: Line 176
**Context**: After Time-Shift definition, in theorems
**TODO Text**: `% TODO: the \leanTimeShift looks really bad, like kids handwriting. use the notation used in def:time-shift-histories and state these definitions more formally to match the paper and lean implementation`

**Research**:
The current `\leanTimeShift(\tau, \Delta)` macro is visually unappealing and doesn't match the paper's notation.

**Recommendation**:
1. Remove `\leanTimeShift` macro usage
2. Use paper notation: $\tau \approx_y^x \sigma$ for the relationship
3. For the shifted history itself, use $\tau^{+x}$ or just describe the construction

Rewrite theorems:
```latex
\begin{theorem}[Convexity Preservation]
If $\tau$ has a convex domain and $\tau \approx_y^x \sigma$, then $\sigma$ has a convex domain.
\end{theorem}

\begin{theorem}[Task Preservation]
If $\tau$ respects the task relation and $\tau \approx_y^x \sigma$, then $\sigma$ respects the task relation.
\end{theorem}
```

---

### TODO 18: Restate Logical Consequence with Types (Line 190)

**Location**: Line 190
**Context**: Before Definition [Logical Consequence]
**TODO Text**: `% TODO: this needs to be restated with types for the quantified variables but while keeping the informal sentence form for readability, using natural language for quantifiers and the like.`

**Research**:
The current definition lacks explicit types. Need quasi-formal presentation.

**Recommendation**:
```latex
\begin{definition}[Logical Consequence]
A formula $\varphi$ is a \textbf{logical consequence} of $\Gamma$ (written $\Gamma \models \varphi$) just in case for every temporal type $T : \text{Type}$, frame $\taskframe : \text{TaskFrame}(T)$, model $\model : \text{TaskModel}(\taskframe)$, history $\tau \in \histories_{\taskframe}$, and time $x : T$, if all formulas in $\Gamma$ are true at $\model, \tau, x$, then $\varphi$ is true at $\model, \tau, x$.
\end{definition}
```

---

### TODO 19: Define Validity as Consequence of Empty Set (Line 196)

**Location**: Line 196
**Context**: After Logical Consequence definition
**TODO Text**: `% TODO: define validity here as a logical consequence of no sentences. Make sure that the lean code defines validity in this way as well.`

**Research**:
The Lean code in `Validity.lean` (lines 110-116) shows:
```lean
theorem valid_iff_empty_consequence (phi : Formula) :
    (valid phi) <-> ([] entails phi)
```

This confirms validity should be defined as consequence from empty context.

**Recommendation**:
Add after Logical Consequence:
```latex
\begin{definition}[Validity]
A formula $\varphi$ is \textbf{valid} (written $\models \varphi$) just in case $\varphi$ is a logical consequence of the empty set: $\varnothing \models \varphi$.
Equivalently, $\varphi$ is true at every model-history-time triple.
\end{definition}
```

---

### TODO 20: Restate Satisfiability with Types (Line 198)

**Location**: Line 198
**Context**: Before Definition [Satisfiability]
**TODO Text**: `% TODO: this needs to be restated with types for the quantified variables but while keeping the informal sentence form for readability, using natural language for quantifiers and the like. Use \models instead of 'true at'. We are going for quasi-formal for readability but not at the cost of clarity.`

**Research**:
Need quasi-formal presentation with types and use of `\models`.

**Recommendation**:
```latex
\begin{definition}[Satisfiability]
A context $\context$ is \textbf{satisfiable} in temporal type $T$ if there exist a frame $\taskframe : \text{TaskFrame}(T)$, model $\model : \text{TaskModel}(\taskframe)$, history $\tau \in \histories_{\taskframe}$, and time $x : T$ such that $\model, \tau, x \models \psi$ for all $\psi \in \context$.
\end{definition}
```

---

## Decisions

1. **Terminology**: Use "sentence letters" consistently, never "atomic propositions"
2. **Time variables**: Use lowercase `x`, `y`, `z` for times, not `t`, `s` or Greek letters
3. **Time-shift notation**: Use paper's `\tau \approx_y^x \sigma` notation, not `\leanTimeShift`
4. **Lean tables**: Remove all Lean-specific implementation tables from the main text
5. **Style**: Use natural sentences instead of em-dashes (---) for explanatory text
6. **Types**: Always specify types explicitly in definitions using quasi-formal notation
7. **Semantic linefeeds**: Maintain one sentence per line per `.claude/rules/latex.md`

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking LaTeX compilation | Test compile after each major change |
| Notation inconsistency with other subfiles | Review 01-Syntax.tex patterns first |
| Loss of Lean alignment | Keep comments referencing Lean field names where helpful |
| Overcomplicating definitions | Follow paper's concise style |

## Appendix

### Search Queries and References

1. JPL Paper key definitions:
   - Line 862: Frame definition
   - Line 868: World history definition
   - Line 889-898: Model and semantic clauses
   - Line 1877-1878: Time-shift definition (def:time-shift-histories)
   - Line 1918: Time-shift preservation theorem

2. Lean implementation files consulted:
   - `Theories/Bimodal/Semantics/TaskFrame.lean`
   - `Theories/Bimodal/Semantics/WorldHistory.lean`
   - `Theories/Bimodal/Semantics/Truth.lean`
   - `Theories/Bimodal/Semantics/Validity.lean`
   - `Theories/Bimodal/Theorems/Perpetuity.lean`

3. LaTeX style reference:
   - `.claude/rules/latex.md` - Semantic linefeeds, notation macros

### Summary Table of TODOs

| # | Line | Category | Summary |
|---|------|----------|---------|
| 1 | 11 | Structure | Use table for primitives, then definition with constraints |
| 2 | 31 | Cleanup | Remove Lean table (redundant) |
| 3 | 59 | Terminology | Consider "lawful" or fold into definition |
| 4 | 69 | Style | Natural sentences instead of dashes |
| 5 | 71 | Types | Specify type of world history explicitly |
| 6 | 73 | Structure | Fold "respects task" into world history definition |
| 7 | 85 | Cleanup | Remove Lean table (redundant) |
| 8 | 102 | Terminology | "Sentence letters" not "atomic propositions" |
| 9 | 106 | Definition | Define propositions as sets of world states |
| 10 | 108 | Style | Natural sentences instead of dashes |
| 11 | 113 | Types | Specify types explicitly in Task Model |
| 12 | 126 | Notation | Use x, y, z for times; times not restricted to domain |
| 13 | 154 | Content | Explain time-shift motivation (perpetuity theorems) |
| 14 | 159 | Style | Consistent type notation throughout |
| 15 | 160 | Notation | Use x for duration offset, not Greek letters |
| 16 | 163 | Notation | Use paper's time-shift notation (approx) |
| 17 | 176 | Notation | Replace \leanTimeShift with paper notation |
| 18 | 190 | Types | Restate logical consequence with types |
| 19 | 196 | Definition | Define validity as consequence of empty set |
| 20 | 198 | Types | Restate satisfiability with types |

## Next Steps

1. Create implementation plan organizing changes by section
2. Make structural changes first (primitive tables, fold definitions)
3. Apply notation changes (time variables, time-shift notation)
4. Apply terminology changes globally (sentence letters)
5. Remove Lean tables
6. Final review for semantic linefeeds compliance
