# Shared LaTeX Assets

This directory contains shared LaTeX assets used across all theory-specific documentation in the ProofChecker project.

## Contents

| File | Description |
|------|-------------|
| `latexmkrc` | Shared latexmk build configuration |
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

## Build Configuration (latexmk)

This directory contains the shared `latexmkrc` configuration for consistent LaTeX builds across all theories.

### How It Works

Theory directories use a "stub pattern" to load the central config:

```
LaTeX/latexmkrc                    # Central configuration (this directory)
Bimodal/LaTeX/latexmkrc            # Stub: do '../../LaTeX/latexmkrc';
Logos/LaTeX/latexmkrc              # Stub: do '../../LaTeX/latexmkrc';
```

This provides a single source of truth while allowing latexmk to auto-discover the config in each directory.

### Build Settings

The shared `latexmkrc` configures:

| Setting | Value | Purpose |
|---------|-------|---------|
| `$pdf_mode` | 5 | Use XeLaTeX for Unicode/modern fonts |
| `$out_dir` | `build` | Output directory for PDF |
| `$aux_dir` | `build` | Auxiliary files directory |
| `$bibtex_use` | 2 | Use biber for biblatex |
| `$max_repeat` | 5 | Max compilation passes |
| synctex | enabled | Editor synchronization |

### Bibliography Path Configuration

When using the `build/` output directory, BibTeX runs from inside the build directory, which breaks relative paths for `.bst` and `.bib` files. The shared latexmkrc solves this using latexmk's `ensure_path()` function:

```perl
ensure_path('BSTINPUTS', "$shared_latex_dir//");
ensure_path('BIBINPUTS', "$source_dir//");
```

This adds the shared LaTeX directory and theory source directory to BibTeX's search paths. The trailing `//` enables recursive subdirectory searching via Kpathsea. This approach integrates properly with latexmk's `$bibtex_fudge` mechanism which handles directory changes when running bibtex.

For more details on Kpathsea path searching, see [Overleaf's Kpathsea documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files).

### Usage

Build a document:
```bash
cd Bimodal/LaTeX
latexmk BimodalReference.tex
# Output: build/BimodalReference.pdf
```

Or use the build script:
```bash
./build.sh                # Build document
./build.sh --clean        # Remove auxiliary files
./build.sh --full-clean   # Remove all build artifacts
```

Continuous compilation (auto-rebuild on changes):
```bash
latexmk -pvc BimodalReference.tex
```

### PDF Viewer Configuration

The project config intentionally does **not** set `$pdf_previewer`, so your personal preference from `~/.latexmkrc` is used.

To set your preferred viewer, add to `~/.latexmkrc`:

```perl
# Linux examples
$pdf_previewer = 'sioyek %S';      # Sioyek
$pdf_previewer = 'zathura %S';     # Zathura
$pdf_previewer = 'evince %S';      # Evince
$pdf_previewer = 'okular %S';      # Okular

# macOS
$pdf_previewer = 'open -a Skim';   # Skim
$pdf_previewer = 'open -a Preview'; # Preview
```

### Build Directory

All auxiliary files (`*.aux`, `*.log`, `*.toc`, etc.) and the PDF are placed in the `build/` subdirectory. This directory is gitignored project-wide.

## Directory Structure

```
ProofChecker/
├── LaTeX/                          # This directory (shared assets)
│   ├── latexmkrc                   # Shared build configuration
│   ├── formatting.sty
│   ├── bib_style.bst
│   ├── notation-standards.sty
│   └── README.md
├── Bimodal/LaTeX/
│   ├── latexmkrc                   # Stub loading ../../LaTeX/latexmkrc
│   ├── build.sh                    # Build script using latexmk
│   ├── assets/
│   │   └── bimodal-notation.sty    # Imports notation-standards
│   └── BimodalReference.tex        # Imports ../../LaTeX/formatting
└── Logos/LaTeX/
    ├── latexmkrc                   # Stub loading ../../LaTeX/latexmkrc
    ├── assets/
    │   └── logos-notation.sty      # Imports notation-standards
    └── LogosReference.tex          # Imports ../../LaTeX/formatting
```
