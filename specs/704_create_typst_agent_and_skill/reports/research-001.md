# Research Report: Task #704

**Task**: 704 - create_typst_agent_and_skill
**Started**: 2026-01-28T10:30:00Z
**Completed**: 2026-01-28T11:00:00Z
**Effort**: ~4 hours (implementation)
**Priority**: high
**Dependencies**: None
**Sources/Inputs**: Codebase, Typst official documentation, LaTeX context files
**Artifacts**: specs/704_create_typst_agent_and_skill/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The project already has substantial Typst usage in `Theories/Bimodal/typst/` with established patterns for document structure, notation modules, and theorem environments (using thmbox package)
- Typst context files should mirror the LaTeX context structure at `.claude/context/project/typst/` with standards, patterns, templates, and tools documentation
- The typst skill and agent should follow the existing thin-wrapper delegation pattern used by skill-latex-implementation and latex-implementation-agent
- Typst compilation is simpler than LaTeX: single `typst compile` command (no multi-pass, no bibtex) with instant feedback

## Context & Scope

This research examines requirements for creating a Typst agent and skill that parallel the existing LaTeX infrastructure. The focus is on:
1. Understanding the existing LaTeX skill/agent structure
2. Analyzing current Typst usage in the project
3. Identifying Typst-specific context files needed
4. Determining Typst compilation and build patterns

## Findings

### 1. Existing LaTeX Infrastructure

The LaTeX implementation follows a thin-wrapper skill pattern:

**skill-latex-implementation** (`.claude/skills/skill-latex-implementation/SKILL.md`):
- Thin wrapper that delegates to `latex-implementation-agent`
- Handles preflight status update, subagent invocation, postflight processing
- Uses Task tool to spawn subagent

**latex-implementation-agent** (`.claude/agents/latex-implementation-agent.md`):
- Full implementation agent with 8-stage execution flow
- Loads context files on-demand from `.claude/context/project/latex/`
- Handles compilation loop with error recovery
- Creates implementation summaries

**LaTeX Context Files** (`.claude/context/project/latex/`):
```
latex/
├── README.md                           # Overview and canonical sources
├── standards/
│   ├── latex-style-guide.md            # Document class, packages, semantic linefeeds
│   ├── notation-conventions.md         # logos-notation.sty macros
│   └── document-structure.md           # Main document and subfile organization
├── patterns/
│   ├── theorem-environments.md         # Definition, theorem, proof environments
│   └── cross-references.md             # Labels, refs, citations, Lean xrefs
├── templates/
│   └── subfile-template.md             # Boilerplate for new subfiles
└── tools/
    └── compilation-guide.md            # Build process (pdflatex/latexmk)
```

### 2. Current Typst Usage in Project

The project has substantial Typst usage in `Theories/Bimodal/typst/`:

**Main Document** (`BimodalReference.typ`):
- Uses `@preview/cetz:0.3.4` for diagrams
- Uses `@preview/thmbox:0.3.0` for theorem environments
- Font: New Computer Modern (11pt)
- Page margins: 1.5in x 1.25in (LaTeX-like)
- Modular chapter structure via `#include`

**Template File** (`template.typ`):
- Initializes thmbox with custom styling
- Defines theorem environments: definition, theorem, lemma, axiom, remark, proof
- AMS/journal aesthetic: no background colors, italic theorem bodies
- URLblue color for hyperlinks

**Notation Modules**:
- `notation/shared-notation.typ` - Common notation (modal operators, meta-variables, Lean xrefs)
- `notation/bimodal-notation.typ` - Theory-specific notation (temporal operators, task semantics)

**Chapter Files** (`chapters/00-06`):
- Import template and notation via `#import "../template.typ": *`
- Use definition/theorem environments consistently
- Include figures with tables and CeTZ diagrams
- Reference Lean code with `#raw()` formatting

### 3. Typst vs LaTeX Key Differences

| Aspect | LaTeX | Typst |
|--------|-------|-------|
| Compilation | Multi-pass (pdflatex/bibtex/pdflatex/pdflatex) | Single pass (`typst compile`) |
| Speed | Seconds to minutes | Milliseconds |
| Watch mode | External tools | Built-in (`typst watch`) |
| Package imports | `\usepackage{}` | `#import "@preview/pkg:version"` |
| Headings | `\section{}` | `= Heading` |
| Math | `$...$` or `\[...\]` | `$...$` (space for display mode) |
| Bold/Italic | `\textbf{}` / `\emph{}` | `*bold*` / `_italic_` |
| Labels | `\label{def:name}` | `<def:name>` |
| References | `\ref{def:name}` / `\cref{}` | `@def:name` |
| Functions | `\newcommand` | `#let func(args) = ...` |
| Styling | Package options | `#set` and `#show` rules |

### 4. Proposed Typst Context Structure

Parallel to LaTeX context, create at `.claude/context/project/typst/`:

```
typst/
├── README.md                           # Overview and canonical sources
├── standards/
│   ├── typst-style-guide.md            # Typography, page layout, semantic linefeeds
│   ├── notation-conventions.md         # shared-notation.typ and theory modules
│   └── document-structure.md           # Main document and chapter organization
├── patterns/
│   ├── theorem-environments.md         # thmbox setup and custom environments
│   └── cross-references.md             # Labels, refs, Lean xrefs (#raw)
├── templates/
│   └── chapter-template.md             # Boilerplate for new chapters
└── tools/
    └── compilation-guide.md            # typst compile/watch commands
```

### 5. Typst-Specific Context Content

**typst-style-guide.md** should cover:
- Document setup: `#set document()`, `#set text()`, `#set page()`
- Typography: New Computer Modern font, paragraph settings
- Heading configuration: `#set heading(numbering: "1.1")`
- Semantic linefeeds (same principle as LaTeX)
- Show rules for styling

**notation-conventions.md** should document:
- `shared-notation.typ` symbols (modal, temporal operators)
- Theory-specific notation modules
- `#let` macro definitions
- Lean cross-reference patterns (`#raw()`, `#link()`)

**theorem-environments.md** should cover:
- thmbox package usage: `#import "@preview/thmbox:0.3.0"`
- Custom styling (no background, italic bodies)
- Environment definitions: definition, theorem, lemma, axiom, remark, proof
- Page-breaking settings

**cross-references.md** should document:
- Label syntax: `<label>` after headings/figures
- Reference syntax: `@label`
- Bibliography: `#bibliography()` with BibTeX or YAML
- Citation style language support

**compilation-guide.md** should cover:
- `typst compile file.typ` - Basic compilation
- `typst watch file.typ` - Auto-recompile on changes
- `typst compile --font-path PATH file.typ` - Custom fonts
- PDF standard options (`--pdf-standard`)
- No multi-pass needed (unlike LaTeX)

### 6. Skill and Agent Structure

**skill-typst-implementation**:
- Mirror skill-latex-implementation structure
- Same thin-wrapper pattern with preflight/postflight
- Invoke `typst-implementation-agent` via Task tool
- Validate task language is "typst"

**typst-implementation-agent**:
- Mirror latex-implementation-agent structure
- 8-stage execution flow
- Load typst context files on-demand
- Simpler compilation loop (no multi-pass)
- Create implementation summaries

**Key Differences from LaTeX Agent**:
- Compilation command: `typst compile` instead of `latexmk -pdf`
- No bibliography processing step (handled automatically)
- No auxiliary file cleanup needed
- Faster iteration due to instant compilation

### 7. Typst Tooling and Ecosystem

**Compilation**:
- CLI: `typst compile`, `typst watch`
- Installation: Package managers, Cargo, Docker
- Instant feedback via incremental compilation

**Packages** (Typst Universe):
- thmbox - Theorem environments (currently used)
- cetz - Diagrams/graphics (currently used)
- Other available: ctheorems, theorion, great-theorems

**Editor Support**:
- Tinymist language server
- VSCode, Neovim, Emacs extensions
- Web app at typst.app

### 8. Language Routing Update

Add "typst" to the Language-Based Routing table in CLAUDE.md:

| Language | Research Tools | Implementation Tools |
|----------|----------------|---------------------|
| `typst` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash (typst compile/watch) |

## Recommendations

1. **Create Typst context files** at `.claude/context/project/typst/` mirroring the LaTeX structure
2. **Create skill-typst-implementation** following the thin-wrapper pattern
3. **Create typst-implementation-agent** following the 8-stage execution model
4. **Update CLAUDE.md** with typst language routing and skill-to-agent mapping
5. **Update context/index.md** with typst context file references

## Decisions

- Use thmbox package for theorem environments (already established in project)
- Use New Computer Modern font (already established in project)
- Follow AMS/journal aesthetic with no colored backgrounds (already established)
- Single compilation step (no multi-pass complexity)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Typst version compatibility | Pin package versions (e.g., `@preview/thmbox:0.3.0`) |
| Missing Typst packages | Document required packages in compilation guide |
| Graphics conversion | SVG preferred; PDF/EPS not natively supported |

## Appendix

### Search Queries Used
- "Typst typesetting language documentation tutorial 2025"
- "Typst vs LaTeX comparison best practices 2025"
- "Typst theorem environment thmbox package 2025"
- "Typst compilation command line CLI build PDF"

### Key References
- [Typst Tutorial](https://typst.app/docs/tutorial/)
- [For LaTeX Users Guide](https://typst.app/docs/guides/for-latex-users/)
- [thmbox Package](https://typst.app/universe/package/thmbox/)
- [Typst CLI Documentation](https://typst.app/docs/)
- [Typst 0.14 Release Notes](https://typst.app/blog/2025/typst-0.14/)

### Existing Project Files Examined
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/context/project/latex/` (all files)
- `Theories/Bimodal/typst/` (all files)
