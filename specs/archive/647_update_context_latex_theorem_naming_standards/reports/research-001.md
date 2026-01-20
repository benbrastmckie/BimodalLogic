# Research Report: Task #647

**Task**: 647 - Update context files for LaTeX theorem naming and formatting standards
**Started**: 2026-01-20T12:00:00Z
**Completed**: 2026-01-20T12:30:00Z
**Effort**: Small
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: 04-Metalogic.tex NOTE: tags, existing .claude/context/project/latex/ files, .claude/rules/latex.md
**Artifacts**: specs/647_update_context_latex_theorem_naming_standards/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Four NOTE: tags in `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` define new LaTeX documentation standards
- Existing context infrastructure already covers LaTeX with 7 files in `.claude/context/project/latex/`
- The standards should be added to existing files rather than creating new ones to avoid duplication
- Target files: `standards/latex-style-guide.md` and `patterns/theorem-environments.md`

## Context & Scope

This task involves documenting four LaTeX formatting standards discovered during the `/learn` scan of 04-Metalogic.tex. The standards concern:

1. Theorem name formatting (italics)
2. Definition ordering (definitions before usage)
3. Lean theorem name references (inline texttt vs footnotes)
4. Lean directory formatting (standardized texttt)

## Findings

### Source NOTE: Tags Analysis

The four NOTE: tags from `Theories/Bimodal/latex/subfiles/04-Metalogic.tex`:

**NOTE #1 (Line 109)**: Theorem name italics
```latex
% NOTE: I want 'Representation Theorem' and other names of theorems to be in italics
```
- **Pattern**: Named theorems like "Representation Theorem", "Deduction Theorem" should use `\emph{}` or `\textit{}`
- **Current practice**: Plain text without formatting
- **Rationale**: Visual distinction between theorem names and regular text

**NOTE #2 (Line 127)**: Definition ordering
```latex
% NOTE: important to state all relevant definitions before they are used. In particular, the definition of the task relation is critical
```
- **Pattern**: Definitions must appear before their first use
- **Example**: Task relation definition needed before canonical frame definition
- **Rationale**: Reader comprehension and logical flow

**NOTE #3 (Line 154)**: Lean theorem name references
```latex
% NOTE: reference the lean theorem names in the theorem itself. For instance, replace 'Representation Theorem' below with '\texttt{representation\_theorem}' and remove the footnote.
```
- **Current practice**: Footnotes like `\footnote{This is proven as \texttt{representation\_theorem}.}`
- **Recommended practice**: Inline reference in theorem name: `\begin{theorem}[\texttt{representation\_theorem}]`
- **Rationale**: Pairs LaTeX theorem numbering with Lean identifier for easier code navigation

**NOTE #4 (Line 371)**: Lean directory formatting
```latex
% NOTE: use the standardized formatting for lean directories throughout, replacing 'Metalogic\_v2' here with '\texttt{Metalogic\_v2}', and similarly throughout
```
- **Pattern**: All Lean paths should use `\texttt{}` formatting
- **Example**: `\texttt{Metalogic\_v2}` instead of `Metalogic\_v2`
- **Rationale**: Visual consistency, distinguishes code paths from prose

### Existing Context File Structure

The LaTeX context infrastructure already exists at `.claude/context/project/latex/`:

```
.claude/context/project/latex/
├── README.md (47 lines) - Overview and canonical sources
├── standards/
│   ├── latex-style-guide.md (165 lines) - Style rules including semantic linefeeds
│   ├── notation-conventions.md (158 lines) - logos-notation.sty macros
│   └── document-structure.md (184 lines) - Main doc and subfile organization
├── patterns/
│   ├── theorem-environments.md (189 lines) - Definition, theorem, proof usage
│   └── cross-references.md (178 lines) - Labels, refs, Lean cross-references
├── templates/
│   └── subfile-template.md - Boilerplate for new subfiles
└── tools/
    └── compilation-guide.md - Build process and troubleshooting
```

Additionally, `.claude/rules/latex.md` (130 lines) is auto-loaded for `.tex` files.

### Gap Analysis

| Standard | Covered In | Gap |
|----------|------------|-----|
| Theorem name italics | theorem-environments.md | NOT covered - no guidance on formatting theorem names |
| Definition ordering | document-structure.md | PARTIAL - "Content Flow" mentions order but no explicit rule |
| Lean theorem references | cross-references.md, notation-conventions.md | PARTIAL - footnote pattern shown, inline pattern not recommended |
| Lean directory formatting | notation-conventions.md | NOT covered - only covers notation macros, not path formatting |

### Current Patterns in Codebase

**Theorem names**: Currently unformatted plain text
```latex
% Current (04-Metalogic.tex line 111):
The Representation Theorem provides the fundamental bridge...

% Proposed:
The \emph{Representation Theorem} provides the fundamental bridge...
```

**Lean references**: Currently use footnotes
```latex
% Current (04-Metalogic.tex line 157):
\begin{theorem}[Representation Theorem]
Every consistent context is satisfiable...\footnote{This is proven as \texttt{representation\_theorem}.}
\end{theorem}

% Proposed:
\begin{theorem}[\texttt{representation\_theorem}]
Every consistent context is satisfiable...
\end{theorem}
```

**Lean directories**: Inconsistent formatting
```latex
% Current (04-Metalogic.tex line 373):
The Metalogic\_v2 directory contains 27 Lean files...

% Proposed:
The \texttt{Metalogic\_v2} directory contains 27 Lean files...
```

## Recommendations

### Target Files for Updates

**Option A (Recommended)**: Add to existing files
1. `standards/latex-style-guide.md` - Add "Theorem and Definition Naming" section
2. `patterns/theorem-environments.md` - Add "Lean Cross-Reference Pattern" section
3. `patterns/cross-references.md` - Update "Lean Cross-References" section

**Option B (Not recommended)**: Create new file
- `.claude/context/project/latex/standards/theorem-naming-standards.md`
- Reason against: Would duplicate content across multiple files, violates single-responsibility principle

### Implementation Structure

#### latex-style-guide.md Additions

Add new section after "Source File Formatting":

```markdown
## Theorem and Definition Naming

### Named Theorem Formatting

Use `\emph{}` for named theorems and definitions when referenced in prose:

| Context | Format | Example |
|---------|--------|---------|
| In prose | `\emph{Name}` | The \emph{Representation Theorem} shows... |
| In environment name | `[Name]` | `\begin{theorem}[Representation Theorem]` |
| With Lean reference | `[\texttt{lean_name}]` | `\begin{theorem}[\texttt{representation_theorem}]` |

### Definition Ordering

**Rule**: All definitions must appear before their first use.

- State foundational definitions in logical order
- If Definition B uses concepts from Definition A, A must appear first
- Cross-reference earlier definitions using `\cref{}`
```

#### theorem-environments.md Additions

Update the "Theorem with Proof Reference" section:

```markdown
### Lean Cross-Reference in Theorem Environment

**Preferred**: Include Lean name in the theorem environment itself:

```latex
\begin{theorem}[\texttt{representation\_theorem}]
Every consistent context is satisfiable in the canonical model.
\end{theorem}
```

**Deprecated**: Footnote pattern (still acceptable for backwards compatibility):

```latex
\begin{theorem}[Representation Theorem]
Every consistent context...\footnote{Proven as \texttt{representation\_theorem}.}
\end{theorem}
```

The inline pattern:
- Pairs LaTeX theorem numbers with Lean identifiers
- Removes footnote clutter
- Makes code navigation easier for readers
```

#### cross-references.md Additions

Add to "Lean Cross-References" section:

```markdown
### Code Path Formatting

All Lean file paths, module paths, and directory names use `\texttt{}`:

| Element | Format | Example |
|---------|--------|---------|
| Directory | `\texttt{Dir\_Name}` | `\texttt{Metalogic\_v2}` |
| File path | `\texttt{path/to/file.lean}` | `\texttt{Core/Basic.lean}` |
| Module | `\texttt{Module.Name}` | `\texttt{Logos.Core.Semantics}` |
| Definition | `\texttt{def\_name}` | `\texttt{representation\_theorem}` |

Note: Use `\_` for underscores in code names to escape them properly.
```

## Decisions

1. **Add to existing files** rather than create new file (avoids duplication)
2. **Update three files**: latex-style-guide.md, theorem-environments.md, cross-references.md
3. **Do NOT update .claude/rules/latex.md** - rules are auto-loaded; context standards are loaded on-demand
4. **Deprecate footnote pattern** but keep as acceptable for backwards compatibility

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Existing documents don't follow new standards | Standards apply to new/updated content; gradual adoption |
| Inline Lean names may be verbose | Keep as recommended, not required; footnote pattern still acceptable |
| Underscore escaping confusion | Add explicit note about `\_` escaping in code names |

## Appendix

### Search Queries Used

1. `NOTE:` grep in 04-Metalogic.tex
2. `\emph{.*Theorem` pattern search (no matches - confirms standard not in use)
3. `\textit{.*Theorem` pattern search (no matches)
4. `\texttt{.*_theorem}` pattern search (found existing footnote patterns)
5. `Metalogic\_v2` grep (found inconsistent usage)

### Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
- `/home/benjamin/Projects/ProofChecker/.claude/rules/latex.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/README.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/latex-style-guide.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/notation-conventions.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/standards/document-structure.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/patterns/theorem-environments.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/latex/patterns/cross-references.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/index.md`

### Related Context Files

- `.claude/context/project/meta/standards-checklist.md` - Validation standards for meta tasks
- `.claude/context/core/formats/report-format.md` - Research report structure
