# Research Report: Task #380

**Task**: Document LaTeX standards in ProofChecker/docs/
**Date**: 2026-01-11
**Focus**: Review implemented LaTeX infrastructure from tasks 375, 378-379, 384

## Summary

The ProofChecker project has a well-established LaTeX infrastructure following tasks 375, 378-379, and 384. The current documentation in `latex/README.md` is comprehensive for users building documents, but project-wide documentation standards for LaTeX are missing from `docs/Development/`. This task should create a concise LaTeX standards document for contributors.

## Findings

### 1. Current LaTeX Infrastructure

The project uses a centralized LaTeX build system:

| Component | Location | Purpose |
|-----------|----------|---------|
| Central Config | `latex/latexmkrc` | Shared build settings (XeLaTeX, build dir, paths) |
| Shared Formatting | `latex/formatting.sty` | Fonts, colors, citations, boxes |
| Shared Notation | `latex/notation-standards.sty` | Modal, proof theory, meta-variable commands |
| Bibliography Style | `latex/bib_style.bst` | Consistent citation formatting |

Theory directories use a stub pattern to load the central config:
```perl
# Bimodal/latex/latexmkrc, Logos/latex/latexmkrc
do '../../latex/latexmkrc';
```

### 2. Directory Structure Pattern

```
ProofChecker/
├── latex/                    # Shared LaTeX assets
│   ├── latexmkrc            # Central build config
│   ├── formatting.sty       # Shared document formatting
│   ├── notation-standards.sty # Shared notation
│   ├── bib_style.bst        # Bibliography style
│   └── README.md            # Comprehensive usage documentation
├── {Theory}/latex/
│   ├── latexmkrc            # Stub loading ../../latex/latexmkrc
│   ├── build.sh             # Build script (optional)
│   ├── assets/
│   │   └── {theory}-notation.sty  # Theory-specific notation
│   ├── subfiles/            # Document sections
│   └── {Theory}Reference.tex # Main document
```

### 3. Build Configuration Standards (Task 375)

Key settings in `latex/latexmkrc`:

| Setting | Value | Rationale |
|---------|-------|-----------|
| `$pdf_mode` | 5 (XeLaTeX) | Unicode and modern font support |
| `$out_dir/$aux_dir` | `build` | Isolate output from source |
| `$bibtex_use` | 2 | Use biber for biblatex |
| `$max_repeat` | 5 | Prevent infinite loops |
| synctex | enabled | Editor synchronization |

Path configuration uses `ensure_path()` for Kpathsea integration:
- `TEXINPUTS`: Custom package directories
- `BSTINPUTS`: Bibliography style files
- `BIBINPUTS`: Bibliography databases

### 4. Package Reference Pattern (Task 384)

Package imports use base names instead of relative paths:
```latex
% Correct (packages found via TEXINPUTS)
\usepackage{logos-notation}
\usepackage{formatting}
\RequirePackage{notation-standards}

% Incorrect (causes warnings)
\usepackage{assets/logos-notation}
\usepackage{../../latex/formatting}
```

### 5. Theory-Specific Notation Pattern

Theory notation packages:
1. Import `notation-standards` for shared commands
2. Define theory-specific operators, relations, meta-variables
3. Follow sectioned organization with clear comments

Example structure from `bimodal-notation.sty`:
```latex
\RequirePackage{notation-standards}  % Shared notation

% === Syntax ===
\newcommand{\allfuture}{G}

% === Semantics ===
\newcommand{\truthat}[4]{#1, #2, #3 \satisfies #4}

% === Proof Theory ===
\newcommand{\derivable}[2]{#1 \proves #2}
```

### 6. Current Documentation Gap

Documentation exists in:
- `latex/README.md` - Comprehensive build and usage docs (195 lines)
- Task implementation summaries in `specs/`

Documentation missing:
- `docs/Development/` has no LaTeX-specific standards document
- No cross-link from `docs/README.md` to LaTeX documentation

## Recommendations

### 1. Create docs/Development/LATEX_STANDARDS.md

A concise (< 150 lines) standards document covering:
- Directory structure requirements
- Build configuration standards
- Package naming and import conventions
- Notation package organization
- Adding a new theory checklist

### 2. Update docs/README.md

Add LaTeX standards to the Development/ section listing and link to the new document.

### 3. Keep latex/README.md as Primary Reference

The existing `latex/README.md` is well-written and should remain the primary user documentation. The new standards document should reference it rather than duplicate content.

## References

- Task 375: `latexmkrc` central configuration integration
- Task 378: Documentation structure refactoring
- Task 379: Bibliography path configuration fixes
- Task 384: Package path warnings resolution
- `latex/README.md`: Current comprehensive documentation

## Next Steps

1. Create `docs/Development/LATEX_STANDARDS.md` with:
   - Overview referencing `latex/README.md`
   - Required directory structure
   - Package naming conventions
   - Build requirements
   - New theory checklist
2. Update `docs/README.md` to list LATEX_STANDARDS.md
3. Update `docs/Development/README.md` if needed
