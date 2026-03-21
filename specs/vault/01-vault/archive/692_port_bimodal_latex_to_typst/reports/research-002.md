# Research Report: Task #692 (Follow-up)

**Task**: 692 - port_bimodal_latex_to_typst
**Started**: 2026-01-27T16:00:00Z
**Completed**: 2026-01-27T16:45:00Z
**Effort**: Medium (2-4 hours implementation)
**Priority**: Normal
**Dependencies**: research-001.md (symbol mapping and conversion basics)
**Sources/Inputs**:
- [Typst Documentation - For LaTeX Users](https://typst.app/docs/guides/for-latex-users/)
- [Typst Blog - Version 0.12 Improvements](https://typst.app/blog/2024/typst-0.12/)
- [Benjamin Hackl - Typesetting with Typst vs. TeX](https://benjamin-hackl.at/blog/2024/07/typesetting-and-typst.html)
- [jreyesr - Exploring Typst](https://blog.jreyesr.com/posts/typst/)
- [Typst Scripting Reference](https://typst.app/docs/reference/scripting/)
- [GitHub Discussion #2201 - Multi-file Guide](https://github.com/typst/typst/discussions/2201)
- [Typst Forum - Best Practices for Long Documents](https://forum.typst.app/t/best-practices-for-working-with-longer-documents/1228)
- [LWN.net - Typst: a possible LaTeX replacement](https://lwn.net/Articles/1037577/)
**Artifacts**:
- specs/692_port_bimodal_latex_to_typst/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Typst offers significant advantages for this project: faster compilation (milliseconds vs seconds), cleaner syntax, and a modern scripting language
- Best practices for multi-file projects: centralize configuration in main file, use `#include` for chapters, define notation in a shared module
- Key simplifications over LaTeX: no package conflicts, unified syntax, incremental compilation with live preview
- Maintainability recommendations: avoid over-abstraction, keep notation module lean, use set rules for global styling
- Recommended workflow: `typst watch` for development, organize by separation of content and styling

## Context & Scope

This research focuses on Typst advantages, best practices, and maintainability considerations to complement research-001.md which covered symbol mapping and basic conversion patterns.

## Findings

### 1. Typst Advantages Over LaTeX

#### Compilation Speed

Typst provides dramatically faster compilation through incremental compilation technology:
- **LaTeX**: Large documents can take 30-90 seconds to compile
- **Typst**: Millisecond compilation times for most changes; ~15 seconds for clean builds of large documents

This enables true real-time preview during editing. The `typst watch` command provides instant feedback as you type.

#### Cleaner Syntax

| Aspect | LaTeX | Typst |
|--------|-------|-------|
| Headings | `\section{Title}` | `= Title` |
| Bold | `\textbf{text}` | `*text*` |
| Italic | `\textit{text}` | `_text_` |
| Math fractions | `\frac{a}{b}` | `a/b` (auto-converted) |
| Symbols | `\leq`, `\rightarrow` | `<=`, `->` |
| Lists | `\begin{itemize}...\end{itemize}` | `- item` |

The reduction in backslashes and curly braces makes source files more readable and less error-prone.

#### Better Error Messages

Typst provides clear, actionable error messages that:
- Point to the exact location of the problem
- Explain what went wrong in plain language
- Often suggest fixes ("did you mean...")

This contrasts sharply with LaTeX's cryptic error messages that often point to symptoms rather than causes.

#### Unified Language Design

Unlike LaTeX where each package defines its own conventions:
- Typst has one consistent syntax for all commands
- All functions work the same way
- No package conflicts or option clashes
- Single binary (no pdflatex vs xelatex vs lualatex confusion)

#### Modern Scripting

Typst's scripting language is a proper programming language:

```typst
// Loops and conditionals work naturally
#for i in range(1, 5) [
  Item #i
]

// Functions are first-class
#let double(x) = x * 2
Result: #double(5)

// Data loading is built-in
#let data = json("data.json")
```

This eliminates the need for external preprocessing (Python scripts generating LaTeX) that is common in complex LaTeX workflows.

### 2. Best Practices for Academic/Mathematical Documents

#### Multi-File Project Structure

The recommended pattern from the Typst community:

**Main file centralizes configuration:**
```typst
// main.typ
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#set text(font: "New Computer Modern", size: 11pt)

#include "chapters/00-introduction.typ"
#include "chapters/01-syntax.typ"
// ...
```

**Subfiles contain only content:**
```typst
// chapters/01-syntax.typ
= Syntax

The language syntax consists of...
```

Key insight: Set rules in the main file automatically apply to all included files. No need for repeated preambles.

#### Notation Module Organization

Create a dedicated notation file analogous to a `.sty` package:

```typst
// notation.typ

// Modal operators (short, memorable names)
#let nec = $square.stroked$
#let poss = $diamond.stroked$

// Temporal operators
#let H = $sans("H")$
#let G = $sans("G")$
#let P = $sans("P")$
#let F = $sans("F")$

// Semantic relations
#let sat = $tack.r.double$
#let proves = $tack.r$

// Convenience functions for common patterns
#let truthat(m, t, x, phi) = $#m, #t, #x #sat #phi$
```

Import with wildcard for convenience:
```typst
#import "notation.typ": *
```

#### Theorem Environment Setup

Define theorem environments once in the main file:

```typst
#import "@preview/great-theorems:0.1.2": *
#show: great-theorems-init

#let definition = mathblock(blocktitle: "Definition")
#let theorem = mathblock(blocktitle: "Theorem")
#let lemma = mathblock(blocktitle: "Lemma")
#let axiom = mathblock(blocktitle: "Axiom")
#let proof = proofblock()
```

### 3. Improvements Over LaTeX Conventions

#### What Typst Simplifies

1. **No package loading complexity**: Packages are auto-downloaded on first use
2. **No engine selection**: One `typst` command handles everything
3. **No aux file management**: No need to run multiple passes
4. **Automatic parenthesis sizing**: `$(a+b)/(c+d)$` auto-sizes delimiters
5. **Unicode input**: Type symbols directly or use shorthand (`->` for arrow)
6. **Bibliography integration**: Single pass, no BibTeX/biber complexity

#### Modern Features Without LaTeX Equivalents

1. **Incremental compilation**: Only recompute what changed
2. **Built-in styling cascade**: CSS-like styling with show rules
3. **First-class data loading**: JSON, CSV, YAML, XML parsing built-in
4. **Programmatic content generation**: Real loops and conditionals, not macros
5. **Live preview**: Built into the web editor and CLI watch mode

#### Genuine Workflow Improvements

| LaTeX Pain Point | Typst Solution |
|------------------|----------------|
| Package conflicts | Single unified system, no conflicts |
| Multiple compilation passes | Single pass compilation |
| Cryptic errors | Clear, located error messages |
| Learning curve for macros | Straightforward function definitions |
| Installation complexity | Single binary download |

### 4. Avoiding Needless Complexity

#### Keep Simple Things Simple

**DO:**
- Use built-in symbols directly: `$square.stroked$` not a wrapper function
- Use set rules for global styling, not repeated inline styling
- Keep notation module to essential definitions only

**DON'T:**
- Over-abstract simple patterns (if it's used once, don't make a function)
- Create deep nesting of imports
- Replicate LaTeX's verbosity "for familiarity"

#### When NOT to Use Typst Features

1. **Excessive scripting**: If you're writing more code than content, reconsider
2. **Complex computed layouts**: Some advanced layouts are simpler in LaTeX's precise box model
3. **Package dependencies for simple things**: Built-in features often suffice

#### Maintainability Considerations

1. **Flat hierarchy preferred**: 2 levels of imports maximum (main -> notation + chapters)
2. **Explicit over implicit**: Name things clearly, avoid magic abbreviations
3. **Documentation in code**: Comments explaining non-obvious notation choices
4. **Version pin packages**: Use specific versions (`@preview/great-theorems:0.1.2`) not latest

### 5. Recommended Typst Setup for This Project

#### Directory Structure

```
Theories/Bimodal/typst/
├── BimodalReference.typ          # Main document (config + includes)
├── notation/
│   ├── bimodal-notation.typ      # Bimodal-specific notation
│   └── shared-notation.typ       # Shared notation (mirrors notation-standards.sty)
├── chapters/                     # Chapter files (pure content)
│   ├── 00-introduction.typ
│   ├── 01-syntax.typ
│   ├── 02-semantics.typ
│   ├── 03-proof-theory.typ
│   ├── 04-metalogic.typ
│   ├── 05-theorems.typ
│   └── 06-notes.typ
└── build/                        # Output directory (gitignored)
```

Rationale:
- Separates notation from content clearly
- Mirrors LaTeX structure for easy comparison
- `notation/` subdirectory allows shared notation across projects

#### Configuration Approach

**Main file pattern:**
```typst
// BimodalReference.typ

// Package imports
#import "@preview/great-theorems:0.1.2": *
#import "@preview/cetz:0.4.2"

// Local notation
#import "notation/bimodal-notation.typ": *

// Document configuration
#set document(
  title: "Bimodal Reference Manual",
  author: "Benjamin Brast-McKie",
)
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")

// Theorem environments (once, applies globally)
#show: great-theorems-init
// ... theorem definitions ...

// Content
#include "chapters/00-introduction.typ"
// ...
```

#### Build/Compilation Workflow

**Development:**
```bash
cd Theories/Bimodal/typst
typst watch BimodalReference.typ build/BimodalReference.pdf
```

This provides:
- Instant recompilation on save
- Error messages in terminal
- PDF updates in viewer (most viewers auto-refresh)

**Production build:**
```bash
typst compile BimodalReference.typ build/BimodalReference.pdf
```

**Recommended editor setup:**
- VS Code + Typst Preview extension for best experience
- Neovim + typst-preview.nvim for vim users
- Web editor at typst.app for quick edits

## Decisions

1. **Use notation/ subdirectory** - Allows future sharing of notation-standards equivalent across Typst projects (Logos, Bimodal, etc.)

2. **Keep chapter files pure content** - No imports or configuration in chapter files; all handled by main document

3. **Prefer built-in symbols over abstractions** - Only create notation shortcuts for frequently-used combinations, not single symbols

4. **Pin package versions** - Prevents breaking changes from affecting document compilation

5. **Use `typst watch` during development** - Leverage Typst's speed advantage for rapid iteration

6. **Maintain parallel structure to LaTeX** - Eases comparison and validation during porting

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Package ecosystem less mature | Medium | Low | Core needs (theorems, diagrams) are well-supported |
| Subfiles not independently compilable | Certain | Low | Accept limitation; quick full-document compile makes this less important |
| Font rendering differences | Low | Low | Use same "New Computer Modern" font as LaTeX |
| Cross-reference edge cases | Low | Medium | Test all references thoroughly during porting |
| Future Typst breaking changes | Low | Medium | Pin package versions, test before updating |

## Appendix

### Search Queries Used
- "Typst advantages over LaTeX 2026 academic mathematical documents"
- "Typst best practices project structure multi-file academic papers 2026"
- "Typst mathematical notation formal logic documents maintainability"
- "Typst scripting features data processing loops conditionals templates"
- "Typst compilation workflow incremental preview live watch mode"
- "Typst avoid complexity pitfalls common mistakes simple maintainable"

### Key Web Resources
- [Typst Documentation](https://typst.app/docs/)
- [Typst Universe (Package Registry)](https://typst.app/universe/)
- [Typst Forum](https://forum.typst.app/)
- [Typst GitHub Discussions](https://github.com/typst/typst/discussions)
- [Typst Examples Book](https://sitandr.github.io/typst-examples-book/)

### Comparison with research-001.md

This report complements research-001.md:

| research-001.md | research-002.md |
|-----------------|-----------------|
| Symbol mapping (LaTeX -> Typst) | Advantages and workflow benefits |
| Basic conversion patterns | Best practices and project organization |
| Package equivalents | Maintainability and simplicity guidelines |
| CeTZ diagram basics | Build workflow recommendations |

Together, these reports provide complete guidance for the porting task.
