---
name: skill-latex-implementation
description: Implement LaTeX documents following a plan. Invoke for LaTeX-language implementation tasks.
allowed-tools: Task
context: fork
agent: latex-implementation-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/latex/README.md
#   - .claude/context/project/latex/standards/latex-style-guide.md
#   - .claude/context/project/latex/standards/notation-conventions.md
#   - .claude/context/project/latex/standards/document-structure.md
#   - .claude/context/project/latex/patterns/theorem-environments.md
#   - .claude/context/project/latex/patterns/cross-references.md
#   - .claude/context/project/latex/templates/subfile-template.md
#   - .claude/context/project/latex/tools/compilation-guide.md
#   - .claude/context/project/logic/standards/notation-standards.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
#   - Bash(pdflatex *, latexmk *, bibtex *, biber *)
---

# LaTeX Implementation Skill

Execute LaTeX document implementation following a structured plan.

## Context Loading

This skill loads the following context automatically:

| File | Purpose |
|------|---------|
| `latex/README.md` | Overview and canonical sources |
| `latex/standards/latex-style-guide.md` | Document class, packages, formatting |
| `latex/standards/notation-conventions.md` | logos-notation.sty macro usage |
| `latex/standards/document-structure.md` | Main document and subfile organization |
| `latex/patterns/theorem-environments.md` | Definition, theorem, proof patterns |
| `latex/patterns/cross-references.md` | Labels, refs, and Lean cross-references |
| `latex/templates/subfile-template.md` | Boilerplate for new subfiles |
| `latex/tools/compilation-guide.md` | Build process and troubleshooting |
| `logic/standards/notation-standards.md` | General logical notation |

## Trigger Conditions

This skill activates when:
- Task language is "latex"
- /implement command targets a LaTeX task
- Documents, papers, or formatted output needs to be created

## Core Tools

### File Operations
- `Read` - Examine existing .tex files and templates
- `Write` - Create new .tex files
- `Edit` - Modify existing LaTeX source

### Build Tools
- `pdflatex` - Compile LaTeX to PDF
- `latexmk` - Automated multi-pass compilation
- `bibtex`/`biber` - Bibliography processing

## Implementation Strategy

### 1. Plan Review

Load and understand the implementation plan:
- What documents to create
- Document structure and sections
- Required packages and dependencies
- Bibliography requirements

### 2. File Setup

Ensure proper structure:
```latex
\documentclass[12pt]{article}
\usepackage{amsmath,amssymb,amsthm}
\usepackage{hyperref}
% Additional packages as needed

\title{Document Title}
\author{Author}
\date{\today}

\begin{document}
\maketitle

% Content goes here

\end{document}
```

### 3. Iterative Document Development

For each document section:
```
1. Write initial structure
2. Compile to check for errors
3. Add content
4. Verify compilation
5. Iterate until complete
6. Verify final output
```

### 4. Package Selection

Common LaTeX packages by use case:
```latex
% Mathematics
\usepackage{amsmath,amssymb,amsthm}

% Graphics
\usepackage{graphicx,tikz}

% Code listings
\usepackage{listings,minted}

% Tables
\usepackage{booktabs,longtable}

% References
\usepackage{hyperref,cleveref}

% Bibliography
\usepackage[backend=biber]{biblatex}
```

## Execution Flow

```
1. Receive task context with plan
2. Load plan and find resume point
3. Set up or modify .tex files
4. For each document section:
   a. Write LaTeX source
   b. Compile with pdflatex/latexmk
   c. Check for errors/warnings
   d. Fix any issues
   e. Verify output renders correctly
5. Build final PDF
6. Create implementation summary
7. Return results
```

## Compilation Loop

```
while errors_remain:
    1. Run pdflatex or latexmk
    2. Parse log for errors/warnings
    3. If error: identify and fix
    4. If warnings: assess severity
    5. Re-compile until clean
    6. Verify output PDF
```

## Common Patterns

### Document Structure
```latex
\documentclass{article}
\begin{document}
\section{Introduction}
\section{Main Content}
\section{Conclusion}
\end{document}
```

### Theorem Environments
```latex
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{definition}[theorem]{Definition}

\begin{theorem}
  Statement of theorem.
\end{theorem}
\begin{proof}
  Proof content.
\end{proof}
```

### Bibliography
```latex
\bibliographystyle{plain}
\bibliography{references}
% Or with biblatex:
\printbibliography
```

### Cross-references
```latex
\label{sec:intro}
\ref{sec:intro}
\eqref{eq:main}
```

## Verification

After implementation:
```bash
latexmk -pdf document.tex
```

Check:
- No compilation errors
- No undefined references
- Bibliography entries resolved
- PDF renders correctly
- Page layout is correct

## Return Format

```json
{
  "status": "completed|partial",
  "summary": "Implemented N document sections",
  "artifacts": [
    {
      "path": "docs/output.tex",
      "type": "implementation",
      "description": "LaTeX source"
    },
    {
      "path": "docs/output.pdf",
      "type": "output",
      "description": "Compiled PDF"
    }
  ],
  "sections_implemented": [
    "Introduction",
    "Main Content"
  ],
  "warning_count": 0,
  "build_status": "success"
}
```

## Error Handling

### Compilation Error
1. Parse error message from log
2. Identify line number and issue
3. Fix LaTeX source
4. Re-compile and verify

### Missing Package
1. Identify required package from error
2. Add \usepackage{} directive
3. Re-compile

### Undefined Reference
1. Check label spelling
2. Ensure label defined before reference
3. Run compilation twice for cross-references

### Bibliography Issues
1. Verify .bib file syntax
2. Run bibtex/biber
3. Re-run pdflatex twice

## Project Integration

### Directory Structure
```
docs/
├── *.tex           # LaTeX source files
├── *.bib           # Bibliography files
├── figures/        # Images and diagrams
├── build/          # Compiled output (optional)
└── *.pdf           # Final documents
```

### Build Commands
```bash
# Single compilation
pdflatex document.tex

# Full build with bibliography
latexmk -pdf document.tex

# Clean auxiliary files
latexmk -c
```
