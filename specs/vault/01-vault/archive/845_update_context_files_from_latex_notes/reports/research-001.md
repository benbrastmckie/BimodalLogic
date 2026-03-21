# Research Report: Task #845

**Task**: 845 - update_context_files_from_latex_notes
**Started**: 2026-02-03T00:00:00Z
**Completed**: 2026-02-03T00:15:00Z
**Effort**: Low (documentation updates)
**Dependencies**: None
**Sources/Inputs**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (lines 474, 550)
- `.claude/context/project/latex/` directory
- `latex/notation-standards.sty`
- `Theories/Logos/latex/assets/logos-notation.sty`
**Artifacts**:
- This report: `specs/845_update_context_files_from_latex_notes/reports/research-001.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **NOTE 1 (Line 474)**: Requests standardization of Lean source code references using `\leansrc{Module}{Definition}` at end of sections
- **NOTE 2 (Line 550)**: Requests using `\set{}` macro instead of `\{ \}` for set notation
- The `\set{}` macro already exists in `logos-notation.sty` (line 54)
- The `\leansrc` macro is defined in `latex/notation-standards.sty` (line 123)
- Context files need updates to document both conventions explicitly

## Context & Scope

### Task Description

Update `.claude/context/` files based on two NOTE: tags from the LaTeX source file `02-ConstitutiveFoundation.tex`:

1. **Line 474**: "I want the references to the lean source code to follow this standard form at the end of sections (where relevant to include)"
2. **Line 550**: "Use `\set{  }` instead of `\{ \}` everywhere, defining this in logos-notation.sty"

### Research Questions

1. What is the current pattern for Lean source code references?
2. Where is this pattern documented in context files?
3. Does the `\set{}` macro already exist?
4. Where should these conventions be documented?

## Findings

### 1. Lean Source Reference Pattern

**Current Usage Analysis**

The `\leansrc` command is used consistently throughout the LaTeX files with this pattern:

```latex
\noindent
See \leansrc{Module.Submodule.Path}{DefinitionName}.
```

Examples from `02-ConstitutiveFoundation.tex`:
- Line 76: `See \leansrc{Logos.SubTheories.Foundation.Syntax}{Term}.`
- Line 100: `See \leansrc{Logos.SubTheories.Foundation.Syntax}{ConstitutiveFormula}.`
- Line 179: `See \leansrc{Logos.Foundation.Frame}{ConstitutiveFrame}.`
- Line 477: `See \leansrc{Logos.Foundation.Semantics}{verifies}.`
- Line 521: `See \leansrc{Logos.Foundation.Relations}{essence}.`
- Line 618: `See \leansrc{Logos.Foundation.Proposition}{BilateralProp}.`

**Macro Definition**

Located in `latex/notation-standards.sty` (lines 120-124):
```latex
% Lean Cross-Reference Commands
\newcommand{\leansrc}[2]{\texttt{#1}.\texttt{#2}}   % Lean source reference
\newcommand{\leanref}[1]{\texttt{#1}}               % Lean reference
```

**Standard Pattern (from NOTE)**

The NOTE at line 474 shows the desired standard form appearing immediately after definition environments at the end of (sub)sections:

```latex
\begin{definition}[...]
...
\end{definition}

\noindent
See \leansrc{Module.Path}{Definition}.
```

**Documentation Status**

The pattern is partially documented in:
- `.claude/context/project/latex/patterns/cross-references.md` (lines 59-88) - describes `\leansrc` usage
- `.claude/context/project/latex/standards/document-structure.md` (lines 164-166) - mentions external references

However, neither document explicitly states:
1. That `\leansrc` references should appear at the END of sections
2. That they follow definition environments with `\noindent`
3. That they are optional ("where relevant to include")

### 2. Set Notation Macro

**Current Status**

The `\set{}` macro is ALREADY DEFINED in `logos-notation.sty` at line 54:
```latex
\newcommand{\set}[1]{\{#1\}}          % Set notation (replaces \{...\} pairs)
```

**Usage Analysis**

Current uses of `\set{}` (correct pattern):
- Line 540: `$X \otimes Y \define \set{\fusion{s}{t} : s \in X, t \in Y}$`

Remaining uses of `\{ \}` that should migrate to `\set{}`:
- Line 58: `\FV(v) &= \{v\} \\`
- Line 106: `\FV((\lambda v.\metaA)(t)) &= (\FV(\metaA) \setminus \{v\}) \cup \FV(t) \\`
- Lines 555-558: Multiple set definitions in extremal bilateral propositions

**Documentation Status**

The `\set{}` macro is NOT documented in any context file. The `logos-notation.sty` file has a comment but this pattern is not exposed to Claude agents.

### 3. Existing Context File Analysis

**Files Relevant to This Task**

| File | Purpose | Update Needed |
|------|---------|---------------|
| `.claude/context/project/latex/patterns/cross-references.md` | Cross-reference patterns | Add section placement standard |
| `.claude/context/project/latex/standards/latex-style-guide.md` | Style conventions | Add `\set{}` macro requirement |
| `.claude/context/project/latex/README.md` | LaTeX context overview | Minor update for notation link |
| `.claude/rules/latex.md` | Auto-applied LaTeX rules | Add `\set{}` to macro checklist |

### 4. Related Context Files

The following files were examined but do not need updates:
- `.claude/context/project/latex/standards/document-structure.md` - focuses on file organization
- `.claude/context/project/latex/patterns/theorem-environments.md` - focuses on theorem/definition structure
- `.claude/context/project/latex/tools/compilation-guide.md` - focuses on build process

## Recommendations

### Implementation Plan

**Phase 1: Update cross-references.md**

Add new section "Lean Source Reference Placement" that documents:
1. References appear at END of subsections (after final definition/remark)
2. Use `\noindent` prefix
3. Include only when relevant (not required for every section)
4. Format: `See \leansrc{Module.Path}{Definition}.`

**Phase 2: Update latex-style-guide.md**

Add to "Notation Macros" section:
1. Document `\set{}` macro for set notation
2. State that `\{ \}` should NOT be used for simple sets
3. Explain rationale: consistency and easier maintenance

**Phase 3: Update latex.md rules**

Add to validation checklist:
- [ ] Use `\set{}` macro for set notation (not `\{ \}`)
- [ ] Lean source references at end of relevant sections

### Specific Context File Changes

**`.claude/context/project/latex/patterns/cross-references.md`**

Add after line 88 (after "Module Reference" section):

```markdown
### Lean Source Reference Placement

Place `\leansrc` references at the **end of sections**, after the final definition or remark:

```latex
\begin{definition}[Constitutive Frame]\label{def:constitutive-frame}
...
\end{definition}

\noindent
See \leansrc{Logos.Foundation.Frame}{ConstitutiveFrame}.
```

**Rules**:
1. Use `\noindent` to prevent paragraph indentation
2. Place after the final environment in a (sub)section
3. Include only when relevant - not required for every section
4. Follow the format: `See \leansrc{Module.Path}{Definition}.`
```

**`.claude/context/project/latex/standards/latex-style-guide.md`**

Add to "Notation Macros" section (create if needed) after line 125:

```markdown
### Set Notation

Use the `\set{}` macro for set notation instead of raw `\{ \}` braces:

```latex
% Good: Use \set{} macro
\FV(v) = \set{v}
X \otimes Y \define \set{\fusion{s}{t} : s \in X, t \in Y}

% Bad: Raw braces
\FV(v) = \{v\}
X \otimes Y \define \{\fusion{s}{t} : s \in X, t \in Y\}
```

**Rationale**: The `\set{}` macro (defined in `logos-notation.sty`) ensures consistent set notation and simplifies maintenance.
```

**`.claude/rules/latex.md`**

Add to validation checklist:
```markdown
- [ ] Use `\set{}` macro for set notation (not `\{ \}`)
- [ ] Lean source references placed at end of relevant sections with `\noindent`
```

## Decisions

1. **Location**: Update context files in `.claude/context/project/latex/` rather than creating new files
2. **Scope**: Focus on documenting the two specific patterns from the NOTEs
3. **Rules update**: Include in `.claude/rules/latex.md` for automatic application

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing LaTeX files | This task only updates documentation; actual LaTeX changes are separate |
| Inconsistent documentation | Review all LaTeX context files for alignment after updates |
| Missing edge cases | Include examples showing when NOT to use patterns (optional placement) |

## Appendix

### Files Examined

1. `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Source of NOTEs
2. `Theories/Logos/latex/assets/logos-notation.sty` - Contains `\set{}` macro
3. `latex/notation-standards.sty` - Contains `\leansrc` macro
4. `.claude/context/project/latex/patterns/cross-references.md` - Existing cross-ref docs
5. `.claude/context/project/latex/standards/latex-style-guide.md` - Existing style guide
6. `.claude/context/project/latex/standards/document-structure.md` - Document organization
7. `.claude/context/project/latex/README.md` - LaTeX context overview
8. `.claude/rules/latex.md` - Auto-applied LaTeX rules

### Search Queries Used

1. `Grep: \\leansrc` in `Theories/Logos/latex` - Found 18 usages across 4 files
2. `Grep: \\set\{` in `Theories/Logos/latex` - Found 3 usages
3. `Grep: \\\{` in `Theories/Logos/latex/subfiles` - Found 7 raw brace usages
4. `Glob: .claude/context/**/*.md` - Found 96 context files
5. `Grep: \\newcommand\{\\leansrc` - Found macro definition in `notation-standards.sty`
