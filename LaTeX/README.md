# Shared LaTeX Assets

This directory contains shared LaTeX assets used across all theory-specific documentation in the ProofChecker project.

## Contents

| File | Description |
|------|-------------|
| `formatting.sty` | Common document formatting: fonts, colors, hyperlinks, citations, headers, boxes |
| `bib_style.bst` | Bibliography style for consistent citation formatting |
| `notation-standards.sty` | Shared notation definitions used across all theories |

## Usage

### In Theory-Specific Documents

Import shared assets using relative paths from theory LaTeX directories:

```latex
% In Bimodal/LaTeX/BimodalReference.tex or Logos/LaTeX/LogosReference.tex
\usepackage{../../LaTeX/formatting}
\bibliographystyle{../../LaTeX/bib_style}
```

### In Theory-Specific Notation Files

Notation files should import the shared standards:

```latex
% In Bimodal/LaTeX/assets/bimodal-notation.sty
\RequirePackage{../../LaTeX/notation-standards}
```

## notation-standards.sty

Provides consistent notation across all theories:

### Modal Operators
- `\nec` - Necessity (Box)
- `\poss` - Possibility (Diamond)

### Truth Relations
- `\satisfies` - Satisfaction relation (models)
- `\notsatisfies` - Negated satisfaction

### Proof Theory
- `\proves` - Derivability (vdash)
- `\context` - Proof context (Gamma)

### Meta-Variables
- `\metaphi`, `\metapsi`, `\metachi` - Formula meta-variables

### Propositional Connectives
- `\imp` - Implication (arrow)
- `\lneg` - Negation
- `\falsum` - Falsity/bottom

### Model Notation
- `\model` - Model symbol (bold M)

### Lean References
- `\leansrc{name}` - Lean source reference
- `\leanref{name}` - Lean reference

## Adding a New Theory

When creating documentation for a new theory:

1. Create `Theory/LaTeX/` directory structure
2. Create `Theory/LaTeX/assets/theory-notation.sty`:
   ```latex
   \NeedsTeXFormat{LaTeX2e}
   \ProvidesPackage{theory-notation}[YYYY/MM/DD Theory Notation]

   % Import shared standards
   \RequirePackage{../../LaTeX/notation-standards}

   % Add theory-specific notation here
   \newcommand{\myoperator}{\diamond}
   ```
3. Create main document importing shared formatting:
   ```latex
   \usepackage{assets/theory-notation}
   \usepackage{../../LaTeX/formatting}
   ```

## Directory Structure

```
ProofChecker/
├── LaTeX/                          # This directory (shared assets)
│   ├── formatting.sty
│   ├── bib_style.bst
│   ├── notation-standards.sty
│   └── README.md
├── Bimodal/LaTeX/
│   ├── assets/
│   │   └── bimodal-notation.sty    # Imports notation-standards
│   └── BimodalReference.tex        # Imports ../../LaTeX/formatting
└── Logos/LaTeX/
    ├── assets/
    │   └── logos-notation.sty      # Imports notation-standards
    └── LogosReference.tex          # Imports ../../LaTeX/formatting
```
