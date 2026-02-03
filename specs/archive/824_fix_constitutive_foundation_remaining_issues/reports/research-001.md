# Research Report: Task #824

**Task**: fix_constitutive_foundation_remaining_issues
**Date**: 2026-02-03
**Focus**: FIX and NOTE tags in ConstitutiveFoundation.tex

## Summary

This task addresses four distinct issues identified in `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`. The issues involve dependent type theory notation consistency, adding exclusivity/exhaustivity constraints from external source material, and applying the verum/falsum notation conventions established in task 823.

## Findings

### Issue 1: Line 181 - State Modality Dependent Type Theory Notation

**Current State**: The State Modality definitions (lines 186-193) use inconsistent notation for typing annotations.

**Analysis**: Lines 187-192 define predicates with type annotations like `\forall t : \statespace` and `\exists d : D`. This is already close to dependent type theory notation used elsewhere in the document (e.g., Definition 4.5 at line 148-154 uses phrases like "which is of type $S \to S \to \Prop$").

**Inconsistencies Found**:
- `\possible(s)` and `s \compatible t` have no explicit type annotation for `s` and `t`
- `\worldstates(w)` has no type annotation for `w`
- `\necessary(s)` has no type annotation for the outer `s`

**Reference Pattern** (from lines 151-153):
```latex
\item $\statespace = \tuple{S, \parthood}$ is a complete lattice of \textit{states} which are of type $S$ together with a \textit{parthood relation} $\parthood$ which is of type $S \to S \to \Prop$
```

**Recommendation**: Add explicit type annotations using colon notation like `\possible : \statespace \to \Prop` to match Lean-style dependent type notation used throughout the document.

### Issue 2: Lines 245-246 - Exclusivity and Exhaustivity Constraints

**Source Material** (counterfactual_worlds.tex line 861):
> "Given any sets of states $V$ and $F$, the ordered pair $\tuple{V,F}$ is \textit{exclusive} just in case the states in $V$ are incompatible with the states in $F$, and \textit{exhaustive} just in case every possible state is compatible with some state in either $V$ or $F$."

**Current Context** (lines 240-247): Definition 4.14 defines constraints for n-place predicates including fusion closure and parthood constraints. Two FIX tags indicate missing exclusivity and exhaustivity constraints.

**Required Generalization**: The source defines exclusivity/exhaustivity for sets of states (0-place case). For n-place predicates where $\verifiertype{F}, \falsifiertype{F} : ((\Fin\;n \to \statespace) \to \statespace) \to \Prop$, the constraints must be generalized to work with n-place functions.

**Proposed Constraints**:
1. **Exclusivity**: For any $f : |F|^+$ and $g : |F|^-$, and any $a_1, \ldots, a_n : \statespace$, the states $f(a_1, \ldots, a_n)$ and $g(a_1, \ldots, a_n)$ are incompatible (not compatible).
2. **Exhaustivity**: For any $a_1, \ldots, a_n : \statespace$ and any possible state $p : \possible$, there exists either $f : |F|^+$ or $g : |F|^-$ such that $f(a_1, \ldots, a_n) \compatible p$ or $g(a_1, \ldots, a_n) \compatible p$.

### Issue 3: Line 357 - Verum/Falsum Notation Comment

**Current State**: Lines 357-359 contain a NOTE comment explaining the distinction between `\top`/`\bot` and `\ver`/`\fal`:
```latex
% Notation: \top and \bot are the top/bottom elements for the ground ordering.
% The verum (\ver := \neg\bot) and falsum (\fal := \neg\top) are top/bottom for parthood.
% See logos-notation.sty for symbol definitions and notation-conventions.md for usage guidance.
```

**Task 823 Conventions** (from implementation summary):
- `\top`, `\bot` - top/bottom for ground ordering (primitive)
- `\ver`, `\fal` - top/bottom for parthood ordering (defined as `\neg\bot` and `\neg\top`)
- Strikethrough symbols visually distinguish the two pairs
- These macros are defined in `logos-notation.sty`

**Recommendation**: The NOTE comment correctly reflects the task 823 conventions. It should be removed since it's now documented in the notation files. No additional changes needed for verum/falsum at this location.

### Additional FIX Tags Found

During research, additional FIX tags were discovered in the file:

1. **Line 295**: `% FIX: turn the following subsection into an extended remark to match the others`
   - This requests converting the Verification and Falsification subsection (2.7) to a remark format
   - **Not in scope** for task 824 per the task description

2. **Line 481**: `% FIX: add definitions of the other two extremal elements defined as the negation of the primitive bot and top`
   - Requests adding `\ver` and `\fal` definitions
   - **Related to task 823** but appears to be within scope as it connects to verum/falsum notation

3. **Line 534**: `% FIX: add identities for the primitive top and bot elements which get mapped to specific extremal propositions, where these should be defined above`
   - Requests adding homomorphism identities for `\top` and `\bot` mapping to bilateral propositions
   - **Related to issue 481** - depends on verum/falsum definitions being added first

### Existing Pattern for Type Annotations

From Bimodal/latex/subfiles/02-Semantics.tex (lines 43, 49, 61), the project uses patterns like:
```latex
A domain $\domain : D \to \text{Prop}$
A \textbf{world history} in a task frame... is a dependent function $\tau : (x : D) \to \domain(x) \to \worldstate$
```

This confirms the colon notation for type annotations is the project standard.

## Recommendations

### For Line 181 (State Modality Notation)

Rewrite Definition 2.6 (State Modality) to use consistent dependent type theory notation:

```latex
\begin{definition}[State Modality]\label{def:state-modality}
Let $\mframe = \tuple{\statespace, \temporalorder, \taskrel}$ be a dynamical frame.
We define the following predicates:
\begin{align}
    \possible &: \statespace \to \Prop \text{ where } \possible(s) \define \task{s}{0}{s} \\
    (\cdot \compatible \cdot) &: \statespace \to \statespace \to \Prop \text{ where } s \compatible t \define \possible(\fusion{s}{t}) \\
    \mathsf{Maximal} &: \statespace \to \Prop \text{ where } \mathsf{Maximal}(s) \define \forall t : \statespace.\; t \compatible s \to t \parthood s \\
    \worldstates &: \statespace \to \Prop \text{ where } \worldstates(w) \define \possible(w) \land \mathsf{Maximal}(w) \\
    (\cdot \connected \cdot) &: \statespace \to \statespace \to \Prop \text{ where } s \connected t \define \exists d : D.\; \task{s}{d}{t} \lor \task{t}{d}{s} \\
    \necessary &: \statespace \to \Prop \text{ where } \necessary(s) \define \forall t : \statespace.\; s \connected t \to s = t
\end{align}
\end{definition}
```

### For Lines 245-246 (Exclusivity/Exhaustivity)

Add the following constraints to Definition 4.14:

```latex
\item \textbf{Exclusivity}: For any $f : |F|^+$, $g : |F|^-$, and $a_1, \ldots, a_n : \statespace$, we have $\neg(f(a_1, \ldots, a_n) \compatible g(a_1, \ldots, a_n))$.
\item \textbf{Exhaustivity}: For any $a_1, \ldots, a_n : \statespace$ and $p : \possible$, there exists $f : |F|^+$ with $f(a_1, \ldots, a_n) \compatible p$, or $g : |F|^-$ with $g(a_1, \ldots, a_n) \compatible p$.
```

### For Line 357 (Verum/Falsum Comment)

Remove the NOTE comment at lines 357-359 since the notation is now documented in:
- `logos-notation.sty` (lines 61-78)
- `.claude/context/project/latex/standards/notation-conventions.md` (lines 39-58)

### For Lines 481 and 534 (Related Verum/Falsum Definitions)

Add after Definition 2.18 (Essence and Ground):

```latex
\begin{definition}[Verum and Falsum]\label{def:verum-falsum}
  The \emph{verum} and \emph{falsum} are defined via negation:
  \begin{align}
    \ver &\define \neg\bot & &\text{(top for parthood ordering)} \\
    \fal &\define \neg\top & &\text{(bottom for parthood ordering)}
  \end{align}
  These are the extremal elements for the parthood ordering $\parthood$, distinct from $\top$ and $\bot$ which are extremal for the ground ordering $\ground$.
\end{definition}
```

And add to Remark 2.24 (Propositional vs. Sentential Operators) after the existing itemize:

```latex
\item $\sem{\top} = \tuple{\statespace, \{\fullstate\}}$ (verified by all, falsified only by full state)
\item $\sem{\bot} = \tuple{\{\nullstate\}, \statespace}$ (falsified by all, verified only by null state)
```

## References

- `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` lines 859-864
- `specs/823_update_context_verum_falsum_notation/summaries/implementation-summary-20260203.md`
- `.claude/context/project/latex/standards/notation-conventions.md`
- `Theories/Logos/latex/assets/logos-notation.sty`
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex` (type annotation examples)

## Next Steps

1. Implement the state modality notation fix (line 181)
2. Add exclusivity/exhaustivity constraints (lines 245-246)
3. Remove the NOTE comment at line 357
4. Add verum/falsum definitions (line 481) and homomorphism identities (line 534)
5. Remove all FIX/NOTE tags after implementing fixes
6. Build with `latexmk` to verify compilation
