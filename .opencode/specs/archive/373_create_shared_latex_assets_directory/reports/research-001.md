# Research Report: Task #373

**Task**: Create shared LaTeX assets directory
**Date**: 2026-01-11
**Focus**: Research best LaTeX practices for sharing formatting assets across multiple documents

## Summary

Research reveals that creating a shared ProofChecker/latex/ directory is the most elegant approach for consolidating common assets. The current setup has identical `formatting.sty` and `bib_style.bst` files duplicated in both `Logos/latex/assets/` and `Bimodal/latex/assets/`. Using relative paths with `../` allows theory-specific documents to import shared assets while maintaining their own notation packages.

## Findings

### Current State Analysis

**Duplicated files (100% identical):**
- `formatting.sty` - 163 lines of common document formatting
- `bib_style.bst` - Bibliography style file

**Theory-specific files (different, should remain separate):**
- `logos-notation.sty` - 145 lines, Logos-specific notation (truthmaker semantics, counterfactuals)
- `bimodal-notation.sty` - 94 lines, Bimodal-specific notation (S5 modality, temporal operators)

### Best Practices from Research

#### 1. Directory Structure Pattern

From [Multi-file LaTeX projects](https://www.overleaf.com/learn/latex/Multi-file_LaTeX_projects) and [LaTeX Best Practices](https://github.com/ahmadassaf/PhD/blob/master/LaTEX%20Best%20Practices.md):

```
ProofChecker/
├── latex/                    # Shared assets (NEW)
│   ├── formatting.sty        # Common formatting
│   ├── bib_style.bst        # Common bibliography style
│   └── README.md            # Usage documentation
├── Logos/latex/
│   ├── assets/
│   │   └── logos-notation.sty  # Theory-specific
│   └── LogosReference.tex
└── Bimodal/latex/
    ├── assets/
    │   └── bimodal-notation.sty  # Theory-specific
    └── BimodalReference.tex
```

#### 2. Relative Path Import Strategy

From [Kpathsea documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files):

In theory-specific documents, import shared assets using:
```latex
\usepackage{../../latex/formatting}
\bibliographystyle{../../latex/bib_style}
```

This approach:
- Works without environment variable configuration
- Maintains explicit dependency tracking
- Is portable across different systems
- Works with Overleaf and local builds

#### 3. Alternative: TEXINPUTS Environment Variable

From [Edinburgh TEXINPUTS guide](https://www2.ph.ed.ac.uk/~wjh/tex/documents/environmental.pdf):

```bash
export TEXINPUTS=".:./../../latex//:"
```

**Not recommended** because:
- Requires system configuration per user
- Less portable
- Harder to debug path issues
- Relative paths are simpler and more explicit

### Shared vs Theory-Specific Content

**Should be shared (ProofChecker/latex/):**
- `formatting.sty` - Document formatting, fonts, hyperref setup, citation commands
- `bib_style.bst` - Bibliography formatting style
- Potentially: common theorem environments, proof macros

**Should remain theory-specific:**
- `logos-notation.sty` - Truthmaker semantics notation (verifies, falsifies, state space)
- `bimodal-notation.sty` - Bimodal logic notation (temporal operators, frame structure)

### Import Order Consideration

The current `formatting.sty` loads hyperref last (correct order). Theory documents should:
1. Load shared formatting first: `\usepackage{../../latex/formatting}`
2. Load theory-specific notation: `\usepackage{assets/logos-notation}`
3. Load cleveref after hyperref (which formatting.sty handles)

## Recommendations

### 1. Create ProofChecker/latex/ Directory

Create a new top-level LaTeX directory containing shared assets:
- `formatting.sty` (moved from either theory directory)
- `bib_style.bst` (moved from either theory directory)
- `README.md` documenting usage

### 2. Update Import Paths in Documents

Change imports in BimodalReference.tex and LogosReference.tex:
```latex
% Old:
\usepackage{assets/formatting}
\bibliographystyle{assets/bib_style}

% New:
\usepackage{../../latex/formatting}
\bibliographystyle{../../latex/bib_style}
```

### 3. Remove Duplicates

Delete from theory-specific assets directories:
- `Logos/latex/assets/formatting.sty`
- `Logos/latex/assets/bib_style.bst`
- `Bimodal/latex/assets/formatting.sty`
- `Bimodal/latex/assets/bib_style.bst`

### 4. Consider Future Consolidation

Evaluate whether these could also be shared:
- Common theorem environment definitions (currently in main .tex files)
- Custom title page macros (currently duplicated as `\HRule`)

## References

- [Multi-file LaTeX projects - Overleaf](https://www.overleaf.com/learn/latex/Multi-file_LaTeX_projects)
- [Kpathsea and file searching - Overleaf](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files)
- [Local LaTeX style files - IAS](https://www.ias.edu/math/computing/faq/local-latex-style-files)
- [TEXINPUTS Environmental Variables - Edinburgh](https://www2.ph.ed.ac.uk/~wjh/tex/documents/environmental.pdf)
- [LaTeX Best Practices - GitHub](https://github.com/ahmadassaf/PhD/blob/master/LaTEX%20Best%20Practices.md)

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Create ProofChecker/latex/ directory structure
   - Phase 2: Move shared files to new location
   - Phase 3: Update import paths in all documents
   - Phase 4: Remove duplicates from theory directories
   - Phase 5: Test compilation of both documents
   - Phase 6: Create documentation
