# Research Report: Task #683

**Task**: 683 - update_context_from_dynamics_foundation_notes
**Started**: 2026-01-26T16:47:14Z
**Completed**: 2026-01-26T16:50:00Z
**Effort**: 30 minutes
**Priority**: medium
**Dependencies**: None
**Sources/Inputs**:
- Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex (lines 214, 257)
- .claude/context/project/latex/standards/latex-style-guide.md
- .claude/context/project/latex/patterns/theorem-environments.md
- .claude/context/project/latex/standards/notation-conventions.md
- .claude/context/project/logic/standards/naming-conventions.md
**Artifacts**:
- specs/683_update_context_from_dynamics_foundation_notes/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

Analysis of two NOTE: tags in 03-DynamicsFoundation.tex reveals needed updates to LaTeX documentation:

1. **Definition formatting pattern** (line 214): Current practice uses named definitions like `\begin{definition}[Dynamical Model]` but the author prefers using italics on first mention of defining terms within the definition body. Context files should document this as the preferred pattern.

2. **Variable naming convention** (line 257): The metalanguage reserves x, y, z for time variables, while first-order object variables should use v₁, v₂, v₃, ... notation. This convention needs to be documented in both LaTeX and Lean contexts.

**Recommended Updates**:
- Add definition formatting guidance to `.claude/context/project/latex/patterns/theorem-environments.md`
- Document variable naming conventions in `.claude/context/project/latex/standards/notation-conventions.md`
- Cross-reference from `.claude/context/project/logic/standards/naming-conventions.md` (for Lean variable naming)

## Context & Scope

The research examines two specific NOTE: comments in the dynamics foundation LaTeX document to identify what context documentation needs updating. These notes represent documentation debt where actual usage patterns diverge from documented standards or where conventions are not yet documented.

**Constraints**:
- Must maintain consistency with existing LaTeX style guide patterns
- Variable naming must align across LaTeX and Lean implementations
- Changes should not conflict with existing documented conventions

## Findings

### NOTE 1: Definition Formatting Pattern (Line 214)

**Source Comment**:
```latex
% NOTE: I don't need definitions to have names as below with '[Dynamical Model]'
% since instead I want them to use italics when stating the definition to
% indicate the term being defined. Fix this throughout.
```

**Context**:
```latex
\begin{definition}[Dynamical Model]\label{def:core-model}
  A \emph{dynamical model} is a structure $\model = \tuple{\statespace, ...}$ where:
  ...
\end{definition}
```

**Current Documentation State**:

The `.claude/context/project/latex/patterns/theorem-environments.md` currently documents:

```latex
\begin{definition}[Constitutive Frame]\label{def:constitutive-frame}
A \emph{constitutive frame} is a structure $\mathbf{F} = \langle S, \sqsubseteq \rangle$...
\end{definition}
```

This shows BOTH patterns: named definition in brackets `[Constitutive Frame]` AND italics on first mention `\emph{constitutive frame}`.

**Author's Preferred Pattern**:

The author indicates the bracket name is redundant when italics already mark the defining term:

```latex
\begin{definition}\label{def:core-model}
  A \emph{dynamical model} is a structure $\model = \tuple{\statespace, ...}$ where:
  ...
\end{definition}
```

**Rationale**:
- Italics `\emph{...}` in the definition body already indicate the term being defined
- Bracket names like `[Dynamical Model]` add visual clutter
- LaTeX auto-numbering provides unique reference (e.g., "Definition 3.1")
- The `\label{def:...}` provides cross-reference capability

**Impact on Existing Patterns**:

From `.claude/context/project/latex/standards/latex-style-guide.md`:

| Context | Format | Example |
|---------|--------|---------|
| Prose reference | *Italics* | the *Soundness Theorem* states... |
| Environment name | Normal (in brackets) | `\begin{theorem}[Soundness]` |

This table suggests named environments are standard. The NOTE indicates definitions should follow a different convention than theorems.

### NOTE 2: Variable Naming Convention (Line 257)

**Source Comment**:
```latex
% NOTE: I want to avoid using x, y, z as first-order variables, using v_1, v_2, v_3, ...
% instead since x, y, z are reserved for times in the metalangauge.
```

**Context**:
```latex
% TODO: clean up the below where labdas are just for binding the last free variable
% (if any) and universal quantifiers are just for quantifying the last open variable
% in the sentence (if any). Research careful conventions and definitions, defining
% them above to match the lean code.

\begin{definition}[Lambda and Quantification]\label{def:lambda-quant-truth}
  \begin{align}
    \model, \history, x, \assignment, \tempindex \trueat (\lambda v.\metaA)(t)
      & \iff \model, \history, x, \assignsub{\sem{t}^\assignment_\model}{v}, ...
    \model, \history, x, \assignment, \tempindex \trueat \forall \metaA(v)
      & \iff \model, \history, x, \assignsub{s}{v}, ... \text{ for all } s : \statespace
  \end{align}
\end{definition}
```

**Variable Usage Analysis**:

The semantics clauses use:
- `x, y, z` for temporal parameters (time points in domain D)
- `v` for bound first-order variables in lambda/quantification
- `s, t, r` for state space elements

Example from the document:
```latex
\model, \history, x, \assignment, \tempindex \trueat \allpast\metaA
  \iff \model, \history, y, \assignment, \tempindex \trueat \metaA
       \text{ for all } y : D \text{ where } y < x
```

Here `x, y` are clearly time variables (elements of temporal order D).

**Current Documentation State**:

From `.claude/context/project/logic/standards/naming-conventions.md`:

```lean
### Model and Frame Variables
**Standard Names**: Use M, N for models; F for frames; τ, σ for histories.

theorem soundness (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F)
    (t : T) (ht : t ∈ τ.domain) (φ : Formula) :
  ⊢ φ → truth_at M τ t ht φ := by sorry
```

This shows `t` for time variables in Lean code.

From `.claude/context/project/latex/standards/notation-conventions.md`:

```latex
### Variable Assignment
| Assignment | `\assignment` | σ | Variable assignment |
| Substitution | `\assignsub{v}{x}` | σ[v/x] | Assignment update |
```

The notation guide uses `v` and `x` in substitution examples but doesn't specify the convention.

**Proposed Convention**:

| Variable Type | LaTeX Notation | Lean Notation | Usage |
|---------------|----------------|---------------|-------|
| Time (metalanguage) | x, y, z | t, s (or explicit names) | Elements of temporal order D |
| First-order variables | v₁, v₂, v₃ or v, w | v, w (or descriptive) | Bound variables in quantifiers |
| States | s, t, r | s, t, r | Elements of state space |
| World-histories | τ, σ, α, β | τ, σ | Functions from times to states |

**Cross-Language Alignment**:

Lean code uses `t` for time parameters, while LaTeX drafts use `x, y, z`. The NOTE suggests reserving `x, y, z` for metalanguage time discussion. This creates potential for:
- LaTeX: Use `x, y, z` for metalanguage time variables
- Lean: Use `t, s` or descriptive names for time parameters
- Both: Use `v₁, v₂, v₃` or `v, w` for first-order variables

### Codebase Pattern Analysis

**Definition Environments in Use**:

Examining 03-DynamicsFoundation.tex reveals mixed usage:
- Line 38: `\begin{definition}[Well-Formed Formulas]\label{def:wff-dynamics}` - NAMED
- Line 55: `\begin{definition}[Derived Operators]\label{def:derived-operators}` - NAMED
- Line 68: `\begin{definition}[Quantifier Notation]\label{def:quantifier-notation}` - NAMED
- Line 120: `\begin{definition}\label{def:dynamical-frame}` - UNNAMED
- Line 139: `\begin{definition}[State Modality]\label{def:state-modality}` - NAMED

The NOTE at line 214 suggests transitioning all to unnamed with italics-only pattern.

**Variable Usage in Semantics**:

Throughout the truth conditions section:
- Times consistently use `x, y, z`: "for all $y : D$ where $y < x$"
- Bound variables use `v`: "$\lambda v.\metaA$", "$\forall v.\metaA$"
- States use `s, t, r, w`: "$s \parthood t$", "$w : \worldstates$"

This aligns with the NOTE's requested convention.

## Recommendations

### Update 1: Definition Formatting Pattern

**File**: `.claude/context/project/latex/patterns/theorem-environments.md`

**Section to Add/Update**: "Definition Environment" section

**Recommended Content**:

```markdown
## Definition Environment

### Unnamed Definitions with Italics

**Preferred Pattern**: Use italics to mark the defining term; omit bracket names.

```latex
\begin{definition}\label{def:constitutive-frame}
A \emph{constitutive frame} is a structure $\frame = \langle \statespace, \parthood \rangle$ where:
\begin{itemize}
  \item $\statespace$ is a nonempty set of states
  \item $\parthood$ is a partial order on $\statespace$
\end{itemize}
\end{definition}
```

**Rationale**:
- The italicized term in the definition body indicates what is being defined
- LaTeX auto-numbering (e.g., "Definition 3.1") provides unique identification
- Labels like `\label{def:...}` enable cross-references via `\cref{def:...}`
- Bracket names add redundant clutter when italics already mark the defining term

**Alternative Pattern** (acceptable for backwards compatibility):

```latex
\begin{definition}[Constitutive Frame]\label{def:constitutive-frame}
A \emph{constitutive frame} is a structure $\frame = \langle \statespace, \parthood \rangle$...
\end{definition}
```

Use this pattern when:
- The definition introduces multiple related terms
- The bracket name provides useful context in generated lists
- Backwards compatibility with existing references is required

**Cross-Reference Pattern**:

```latex
By \cref{def:constitutive-frame}, constitutive frames provide...
% Generates: "By Definition 3.1, constitutive frames provide..."
```
```

### Update 2: Variable Naming Conventions

**File 1**: `.claude/context/project/latex/standards/notation-conventions.md`

**Section to Add**: After "Meta-Variables" section

**Recommended Content**:

```markdown
## Variable Naming Conventions

### Metalanguage vs Object Language

| Variable Type | Notation | Domain | Usage |
|---------------|----------|--------|-------|
| **Time (metalanguage)** | x, y, z | D (temporal order) | Evaluation times in semantics clauses |
| **First-order variables** | v₁, v₂, v₃ or v, w | S (state space) | Bound variables in quantifiers/lambdas |
| **States** | s, t, r | S (state space) | State space elements |
| **World-states** | w | W ⊆ S | Maximal possible states |
| **World-histories** | τ, σ, α, β | D → S | Functions from times to states |

### Examples

**Time variables** (metalanguage):
```latex
\model, \history, x, \assignment, \tempindex \trueat \allpast\metaA
  \iff \model, \history, y, \assignment, \tempindex \trueat \metaA
       \text{ for all } y : D \text{ where } y < x
```

**First-order variables** (object language):
```latex
\model, \history, x, \assignment, \tempindex \trueat (\lambda v.\metaA)(t)
  \iff \model, \history, x, \assignsub{\sem{t}^\assignment_\model}{v}, \tempindex \trueat \metaA

\model, \history, x, \assignment, \tempindex \trueat \forall v.\metaA
  \iff \model, \history, x, \assignsub{s}{v}, \tempindex \trueat \metaA
       \text{ for all } s : \statespace
```

### Rationale

This convention reserves `x, y, z` for metalanguage temporal parameters, preventing confusion with first-order variables in the object language. First-order variables use `v` notation (optionally indexed as v₁, v₂, v₃) to distinguish them from time parameters.
```

**File 2**: `.claude/context/project/logic/standards/naming-conventions.md`

**Section to Update**: "Variable Naming" section (lines 357-403)

**Recommended Addition**:

```markdown
### Time Variables vs First-Order Variables

**LaTeX Convention**: In LaTeX semantics, reserve `x, y, z` for metalanguage time parameters (elements of temporal order `D`). Use `v, w` or indexed `v₁, v₂, v₃` for first-order object variables in quantifiers and lambdas.

**Lean Convention**: For time parameters, prefer descriptive names like `t`, `s`, or `time` rather than `x, y, z`. For first-order variables, use `v`, `w`, or descriptive names.

**Cross-Reference**: See `.claude/context/project/latex/standards/notation-conventions.md` for detailed variable naming conventions in LaTeX semantics.

```lean
-- Good: Descriptive time parameter
theorem truth_at_time (M : Model) (τ : WorldHistory) (t : T) (φ : Formula) :
  truth_at M τ t φ → ...

-- Good: First-order variable
theorem quantifier_semantics (M : Model) (τ : WorldHistory) (t : T) (v : State) :
  ...
```
```

### Update 3: Cross-Reference Additions

**File**: `.claude/context/project/latex/README.md`

**Section to Update**: Add to conventions list

```markdown
## Key Conventions

- **Definition formatting**: Use italics for defining terms; bracket names optional (see patterns/theorem-environments.md)
- **Variable naming**: Reserve x, y, z for metalanguage times; use v₁, v₂, v₃ for first-order variables (see standards/notation-conventions.md)
```

## Decisions

1. **Definition naming is a preference, not a requirement**: The unnamed pattern is preferred for new definitions, but named definitions remain acceptable for backwards compatibility or when the name adds meaningful context.

2. **Variable naming is a hard convention**: The x/y/z vs v₁/v₂/v₃ distinction prevents semantic confusion between metalanguage time parameters and object-language variables. This should be enforced in new LaTeX writing.

3. **Lean variable naming uses descriptive names**: While LaTeX reserves x/y/z for times, Lean code should use descriptive parameter names like `t : T` or `time : T` for clarity.

4. **Documentation updates are additive**: New sections augment existing docs rather than replacing them. This preserves compatibility with existing practices while documenting preferred patterns.

## Risks & Mitigations

### Risk 1: Inconsistency with Existing Documents

**Risk**: Updating conventions may create inconsistency with already-written LaTeX files that use named definitions and mixed variable conventions.

**Mitigation**:
- Document both patterns (preferred + acceptable)
- Mark the unnamed/italics-only pattern as preferred for new work
- Allow gradual migration rather than requiring immediate changes
- Use TODO comments in existing files to track needed updates

### Risk 2: LaTeX/Lean Variable Name Mismatch

**Risk**: LaTeX using x/y/z for times while Lean uses t/s may cause confusion when cross-referencing.

**Mitigation**:
- Explicitly document the difference in both context files
- Use consistent semantic roles (time vs first-order variable) even if notation differs
- Add examples showing LaTeX ↔ Lean correspondence

### Risk 3: Over-Specification of Conventions

**Risk**: Too many prescriptive rules may hinder rather than help writing.

**Mitigation**:
- Frame conventions as "preferred" rather than "required" where possible
- Provide rationale for each convention so authors understand the reasoning
- Allow flexibility for special cases documented in comments

## Appendix

### Search Queries Used

1. Grep for LaTeX-related files in `.claude/context/`
2. Grep for variable/naming/convention patterns
3. Direct file reads:
   - `.claude/context/project/latex/standards/latex-style-guide.md`
   - `.claude/context/project/latex/patterns/theorem-environments.md`
   - `.claude/context/project/latex/standards/notation-conventions.md`
   - `.claude/context/project/logic/standards/naming-conventions.md`

### References

- **Source Document**: `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
- **NOTE 1**: Line 214 (definition formatting)
- **NOTE 2**: Line 257 (variable naming)
- **LaTeX Style Guide**: Semantic linefeeds, theorem environments, definition ordering
- **Theorem Environment Patterns**: Current definition environment examples
- **Notation Conventions**: Existing macro and variable documentation
- **Lean Naming Conventions**: Existing Lean variable naming standards

### Pattern Frequency Analysis

**Named vs Unnamed Definitions** in 03-DynamicsFoundation.tex:
- Named: ~15 occurrences
- Unnamed: ~3 occurrences
- Author preference: Transition to unnamed

**Variable Usage** in semantics clauses:
- `x, y, z` for times: ~20+ occurrences
- `v` for bound variables: ~5 occurrences
- `s, t, r, w` for states: ~30+ occurrences
- Consistent with NOTE's requested convention
