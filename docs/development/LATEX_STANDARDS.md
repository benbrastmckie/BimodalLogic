# LaTeX Documentation Standards

[Back to Development](README.md)

Standards for creating and maintaining LaTeX documentation in ProofChecker.

> **For build instructions and usage**: See [latex/README.md](../../latex/README.md) for
> comprehensive build commands, latexmk usage, and PDF viewer configuration.

## Directory Structure

### Shared Assets (`latex/`)

Central shared resources for all theory documentation:

```
latex/
├── latexmkrc            # Central build configuration
├── formatting.sty       # Shared document formatting (fonts, colors, citations)
├── notation-standards.sty  # Shared notation commands
├── bib_style.bst        # Bibliography style
└── README.md            # Build documentation
```

### Theory-Specific Structure

Each theory follows this pattern:

```
{Theory}/latex/
├── latexmkrc            # Stub loading central config
├── build.sh             # Build script (optional)
├── {Theory}Reference.tex  # Main document
├── assets/
│   └── {theory}-notation.sty  # Theory-specific notation
├── subfiles/            # Document sections
│   ├── 00-Introduction.tex
│   └── ...
├── bib/                 # Bibliography files
└── build/               # Output (gitignored)
```

## Build Configuration

### latexmkrc Stub Pattern

Theory directories use a one-line stub to load the central configuration:

```perl
# {Theory}/latex/latexmkrc
do '../../latex/latexmkrc';
```

This provides:
- XeLaTeX compilation (`$pdf_mode = 5`)
- Build directory isolation (`$out_dir = 'build'`)
- Automatic path configuration for packages and bibliography

### Build Commands

```bash
cd {Theory}/LaTeX
latexmk {Theory}Reference.tex    # Build PDF
latexmk -c                       # Clean auxiliary files
latexmk -pvc {Theory}Reference.tex  # Continuous compilation
```

## Package Conventions

### Import by Base Name

Always import packages using base names, not relative paths:

```latex
% Correct - packages found via TEXINPUTS
\usepackage{formatting}
\usepackage{{theory}-notation}
\RequirePackage{notation-standards}

% Incorrect - causes warnings
\usepackage{../../latex/formatting}
\usepackage{assets/{theory}-notation}
```

### Theory Notation Package Structure

Theory-specific notation packages (`{theory}-notation.sty`) must:

1. Import shared notation standards
2. Define theory-specific commands
3. Use sectioned organization

```latex
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{{theory}-notation}[YYYY/MM/DD {Theory} Notation]

% Import shared standards
\RequirePackage{notation-standards}

% === Syntax ===
\newcommand{\myoperator}{\diamond}

% === Semantics ===
\newcommand{\myrelation}{\sim}

% === Proof Theory ===
\newcommand{\myderivation}[2]{#1 \vdash #2}
```

### Shared Notation (`notation-standards.sty`)

The shared package provides standard commands:

| Category | Commands |
|----------|----------|
| Modal | `\nec`, `\poss` |
| Truth | `\satisfies`, `\notsatisfies` |
| Proof | `\proves`, `\context` |
| Meta-variables | `\metaphi`, `\metapsi`, `\metachi` |
| Propositional | `\imp`, `\lneg`, `\falsum` |
| Model | `\model` |
| Lean refs | `\leansrc{name}`, `\leanref{name}` |

## Adding a New Theory

Checklist for creating LaTeX documentation for a new theory:

1. **Create directory structure**:
   ```bash
   mkdir -p {Theory}/latex/assets {Theory}/latex/subfiles {Theory}/latex/bib
   ```

2. **Create latexmkrc stub**:
   ```perl
   # {Theory}/latex/latexmkrc
   do '../../latex/latexmkrc';
   ```

3. **Create notation package** (`assets/{theory}-notation.sty`):
   - Import `notation-standards`
   - Define theory-specific notation
   - Follow sectioned organization

4. **Create main document** (`{Theory}Reference.tex`):
   ```latex
   \documentclass{article}
   \usepackage{formatting}
   \usepackage{{theory}-notation}
   % ... document content
   ```

5. **Test build**:
   ```bash
   cd {Theory}/LaTeX
   latexmk {Theory}Reference.tex
   ```

6. **Verify**:
   - PDF generated in `build/`
   - No package path warnings
   - Notation commands work correctly

## Related Documentation

- [latex/README.md](../../latex/README.md) - Build instructions and latexmk usage
- [MODULE_ORGANIZATION.md](MODULE_ORGANIZATION.md) - Project directory structure

---

[Back to Development](README.md)
