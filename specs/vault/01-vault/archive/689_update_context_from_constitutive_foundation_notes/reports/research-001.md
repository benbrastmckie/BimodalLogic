# Research Report: Task #689

**Task**: 689 - update_context_from_constitutive_foundation_notes
**Started**: 2026-01-27T00:00:00Z
**Completed**: 2026-01-27T00:00:00Z
**Effort**: Small
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (.claude/context/), LaTeX source files
**Artifacts**: specs/689_update_context_from_constitutive_foundation_notes/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The NOTE: tag at line 21 of `02-ConstitutiveFoundation.tex` requests a naming convention change: reserve `x, y, z` for metalanguage durations and use `v_1, v_2, v_3, ...` for object language variables
- Found 5 context files that document variable naming conventions and require updates
- The current convention uses `x, y, z` for both states (object language) and times/durations (metalanguage), creating ambiguity
- Recommended approach: Update all affected files to clearly distinguish object language variables (`v_1, v_2, ...`) from metalanguage duration variables (`x, y, z`)

## Context & Scope

### Source of Request

From `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` line 21:

```latex
% NOTE: I want variables in the object language to be represented with v_1, v_2, v_3, ..., and not x, y, z which are reserved for durations in the metalanguage
```

This NOTE appears immediately before the current "Variables" item which states:
```latex
\item \textbf{Variables}: $x, y, z, \ldots$ (ranging over states)
```

### Current State

The current documentation uses `x, y, z` inconsistently:
- In object language syntax: `x, y, z` for variables ranging over states
- In metalanguage semantics: `x, y` for time points or durations

This creates ambiguity when reading the formal documentation.

### Requested Convention

| Context | Variables | Purpose |
|---------|-----------|---------|
| **Object Language** | `v_1, v_2, v_3, ...` | Variables in formulas (bound by quantifiers, lambda) |
| **Metalanguage** | `x, y, z` | Temporal durations in task semantics |

## Findings

### Files Requiring Updates

#### 1. `.claude/context/project/logic/standards/naming-conventions.md`

**Location**: Lines 359-375 (Variable Naming section)

**Current Content**:
```markdown
### Formula Variables

**Standard Names**: Use Greek letters consistently.

| Variable | Usage | Example |
|----------|-------|---------|
| φ, ψ, χ | Primary formulas | `theorem example (φ ψ : Formula) : ...` |
| p, q, r, s | Atomic propositions | `def p := Formula.atom "p"` |
```

**Change Needed**: Add new row for object language variables:
```markdown
| v_1, v_2, v_3 | Object language variables | `∀v_1.(F(v_1) → G(v_1))` |
```

Also add clarification that `x, y, z` are reserved for metalanguage durations.

---

#### 2. `.claude/context/project/logic/standards/notation-standards.md`

**Location**: Lines 169-190 (Formula Variable Naming section)

**Current Content**:
```markdown
| Type | Variables | Usage |
|------|-----------|-------|
| Formulas | φ, ψ, χ | Primary formula variables (phi, psi, chi) |
| Atoms | p, q, r, s | Propositional atoms |
| Contexts | Γ, Δ | Proof contexts (Gamma, Delta) |
| Models | M, N | Task models |
| Frames | F | Task frames |
| Histories | τ, σ | World histories (tau, sigma) |
| Times | t, s, x, y | Time points or durations |
```

**Change Needed**:
1. Add row for object language variables: `v_1, v_2, v_3 | Object language variables (quantified)`
2. Update "Times" row to clarify: `x, y, z | Metalanguage durations (reserved)`
3. Remove `x, y` from "Times" row and consolidate

---

#### 3. `.claude/context/project/latex/templates/subfile-template.md`

**Location**: Line 67

**Current Content**:
```latex
\item \textbf{Variables}: $x, y, z, \ldots$ (ranging over states)
```

**Change Needed**:
```latex
\item \textbf{Variables}: $v_1, v_2, v_3, \ldots$ (object language variables ranging over states)
```

---

#### 4. `.claude/context/project/latex/standards/notation-conventions.md`

**Current Content**: The file defines LaTeX macros for the Logos notation system but does not currently document variable naming conventions explicitly.

**Change Needed**: Add a "Meta-Variables vs Object-Language Variables" section:
```markdown
## Variable Naming

### Object Language Variables
| Concept | Macro | Output | Usage |
|---------|-------|--------|-------|
| Object variable | `\objvar{1}` | v_1 | Variables in formulas |
| Object variable | `\objvar{2}` | v_2 | Variables in formulas |

### Metalanguage Variables
| Concept | Macro | Output | Usage |
|---------|-------|--------|-------|
| Duration | `x, y, z` | x, y, z | Temporal durations in task relation |
| Time point | `t, s` | t, s | Specific time instants |
```

---

#### 5. `.claude/context/project/lean4/standards/lean4-style-guide.md`

**Location**: Lines 61-64 (Variables quick reference table)

**Current Content**:
```markdown
| **Variables (times)** | Lowercase | `t`, `s` (times), `τ`, `σ` (histories) |
```

**Change Needed**: Add clarification about object language vs metalanguage:
```markdown
| **Variables (times)** | Lowercase | `t`, `s` (specific times), `x`, `y`, `z` (durations) |
| **Variables (object lang)** | Subscripted | `v₁`, `v₂`, `v₃` (quantified variables in formulas) |
```

### Related Files (No Changes Needed)

The following files mention variables but do not require changes:

1. **`.claude/context/project/logic/domain/task-semantics.md`**: Uses `x, y` correctly for durations in the metalanguage (lines 53, 66-67). The current usage aligns with the requested convention.

2. **`.claude/context/project/lean4/README.md`**: General overview, no variable naming specifics.

## Decisions

1. **Subscript Notation**: Use `v_1, v_2, v_3` (with subscripts) rather than `v1, v2, v3` for clarity and mathematical convention
2. **LaTeX Macro**: Recommend creating `\objvar{n}` macro in `logos-notation.sty` for consistency
3. **Lean Representation**: In Lean code, use `v₁, v₂, v₃` (Unicode subscripts) or `v1, v2, v3` depending on context
4. **Backward Compatibility**: This is a documentation convention update; no code changes are required

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Inconsistency with existing LaTeX source | Medium | Update `02-ConstitutiveFoundation.tex` alongside context files |
| Lean code using `x, y, z` for object variables | Low | Lean code already uses Greek letters (φ, ψ, χ) for formulas |
| Reader confusion during transition | Low | Add explicit notes in updated files explaining the convention |

## Recommendations

### Implementation Approach

**Phase 1: Update Context Files**
1. Update all 5 identified files with the new variable naming convention
2. Add explicit disambiguation between object language and metalanguage variables

**Phase 2: Update LaTeX Source**
1. Update `02-ConstitutiveFoundation.tex` line 24 to use `v_1, v_2, v_3`
2. Consider adding `\objvar{n}` macro to `logos-notation.sty`
3. Remove the NOTE: tag after the convention is documented

### Suggested Addition to `logos-notation.sty`

```latex
% Object Language Variables
\newcommand{\objvar}[1]{v_{#1}}  % \objvar{1} produces v_1
```

## Appendix

### Search Queries Used

1. `Glob .claude/context/**/*.md` - Found 95+ context files
2. `Grep "variable|naming|convention"` - Found 43 files with matches
3. `Grep "x, y, z|v_1|metalanguage|object language|duration"` - Identified key files

### Key References

- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Source of NOTE: tag
- `Theories/Logos/latex/logos-notation.sty` - LaTeX notation package
- `.claude/context/project/logic/domain/task-semantics.md` - Authoritative semantics documentation
