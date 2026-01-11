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

The shared assets are available via TEXINPUTS configured in latexmkrc. Import packages by name:

```latex
% In Theories/Bimodal/LaTeX/BimodalReference.tex or Theories/Logos/LaTeX/LogosReference.tex
\usepackage{bimodal-notation}  % or logos-notation (from assets/)
\usepackage{formatting}        % From shared latex/
```

### In Theory-Specific Notation Files

Notation files should import the shared standards by name (TEXINPUTS resolves the path):

```latex
% In Theories/Bimodal/LaTeX/assets/bimodal-notation.sty
\RequirePackage{notation-standards}
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

1. Create `Theories/{Theory}/LaTeX/` directory structure with `assets/` subdirectory
2. Create stub latexmkrc:
   ```perl
   # {Theory} LaTeX Build Configuration
   do '../../../latex/latexmkrc';
   ```
3. Create `Theories/{Theory}/LaTeX/assets/theory-notation.sty`:
   ```latex
   \NeedsTeXFormat{LaTeX2e}
   \ProvidesPackage{theory-notation}[YYYY/MM/DD Theory Notation]

   % Import shared standards (found via TEXINPUTS)
   \RequirePackage{notation-standards}

   % Add theory-specific notation here
   \newcommand{\myoperator}{\diamond}
   ```
4. Create main document importing packages by name:
   ```latex
   \usepackage{theory-notation}  % From assets/
   \usepackage{formatting}       % From shared latex/
   ```

## Build Configuration (latexmk)

This directory contains the shared `latexmkrc` configuration for consistent LaTeX builds across all theories.

### How It Works

Theory directories use a "stub pattern" to load the central config:

```
latex/latexmkrc                           # Central configuration (this directory)
Theories/Bimodal/LaTeX/latexmkrc          # Stub: do '../../../latex/latexmkrc';
Theories/Logos/LaTeX/latexmkrc            # Stub: do '../../../latex/latexmkrc';
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

### Path Configuration

The shared latexmkrc sets up TEXINPUTS so packages can be referenced by name:

```perl
# $source_dir/assets// enables theory-specific packages (e.g., logos-notation.sty)
# $shared_latex_dir// enables shared packages (e.g., formatting.sty, notation-standards.sty)
ensure_path('TEXINPUTS', "$source_dir/assets//");
ensure_path('TEXINPUTS', "$shared_latex_dir//");
```

This eliminates the need for relative paths in `\usepackage` commands and avoids the "You have requested package X but the package provides Y" warning.

### Bibliography Path Configuration

When using the `build/` output directory, BibTeX runs from inside the build directory, which breaks relative paths for `.bst` and `.bib` files. The shared latexmkrc solves this using latexmk's `ensure_path()` function:

```perl
ensure_path('BSTINPUTS', "$shared_latex_dir//");
ensure_path('BIBINPUTS', "$source_dir//");
```

This adds the shared LaTeX directory and theory source directory to BibTeX's search paths. The trailing `//` enables recursive subdirectory searching via Kpathsea.

For more details on Kpathsea path searching, see [Overleaf's Kpathsea documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files).

### Usage

Build a document:
```bash
cd Theories/Bimodal/LaTeX
latexmk BimodalReference.tex
# Output: build/BimodalReference.pdf
```

Or use the build script (if available):
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
├── latex/                              # This directory (shared assets)
│   ├── latexmkrc                       # Shared build configuration
│   ├── formatting.sty
│   ├── bib_style.bst
│   ├── notation-standards.sty
│   └── README.md
└── Theories/
    ├── Bimodal/LaTeX/
    │   ├── latexmkrc                   # Stub: do '../../../latex/latexmkrc';
    │   ├── build.sh                    # Build script using latexmk
    │   ├── assets/
    │   │   └── bimodal-notation.sty    # \RequirePackage{notation-standards}
    │   └── BimodalReference.tex        # \usepackage{bimodal-notation}
    └── Logos/LaTeX/
        ├── latexmkrc                   # Stub: do '../../../latex/latexmkrc';
        ├── assets/
        │   └── logos-notation.sty      # \RequirePackage{notation-standards}
        └── LogosReference.tex          # \usepackage{logos-notation}
```
