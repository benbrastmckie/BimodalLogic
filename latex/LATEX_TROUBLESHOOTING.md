# LaTeX Troubleshooting Guide for ProofChecker Theories

## Common Issues and Solutions

### 1. "Runaway argument" and "File ended while scanning" Errors

**Cause**: Corrupted auxiliary files (.aux, .toc, .out) from interrupted compilation.

**Solution**: Use the centralized fix script:
```bash
# Method 1: From theory directory
cd Theories/Logos/latex
../../latex/latex-fix.sh rebuild

# Method 2: From repository root
./latex/latex-fix.sh rebuild logos
```

Or manually:
```bash
cd Theories/Logos/latex
latexmk -C  # Clean all build files
rm -f *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
latexmk -f -pdf LogosReference.tex  # Force rebuild
```

### 2. "Package not found" Errors

**Cause**: LaTeX can't find custom style files.

**Solution**: The centralized latexmkrc configuration handles this automatically. Ensure:
- Custom .sty files are in `assets/` directory within each theory
- The theory's `latexmkrc` loads the shared configuration via `do '../../../latex/latexmkrc'`
- TEXINPUTS paths are correctly set in the shared configuration

### 3. Undefined References

**Cause**: Missing labels or incomplete compilation cycles.

**Solution**:
1. Run LaTeX multiple times (latexmk does this automatically):
   ```bash
   cd Theories/Logos/latex
   latexmk -pdf LogosReference.tex
   ```
2. Check that all `\label{}` commands have corresponding `\ref{}` or `\cref{}` usage
3. Ensure all sections with referenced labels exist

### 4. Missing Bibliography Fields

**Cause**: BibTeX entries missing required fields like `journal`.

**Solution**: Add missing fields to bibliography entries:
```bibtex
@article{Carr2013,
  author =        {Carr, Alastair},
  title =         {Natural {{Deduction Pack}}},
  journal =       {Software Documentation},  % Add missing journal
  year =          {2013},
}
```

## Recommended Workflow

### Using the Centralized Fix Script (Recommended)
```bash
# From repository root
./latex/latex-fix.sh rebuild logos    # Rebuild Logos theory
./latex/latex-fix.sh check logos      # Check Logos theory health
./latex/latex-fix.sh clean logos      # Clean Logos theory files

# From theory directory (auto-detects theory)
cd Theories/Logos/latex
../../latex/latex-fix.sh rebuild
```

### Regular Compilation
```bash
cd Theories/Logos/latex
latexmk -pdf LogosReference.tex  # Normal compilation
```

### Clean Rebuild (when errors occur)
```bash
cd Theories/Logos/latex
latexmk -C  # Remove all generated files
latexmk -f -pdf LogosReference.tex  # Force complete rebuild
```

### Continuous Compilation (during development)
```bash
cd Theories/Logos/latex
latexmk -pvc -pdf LogosReference.tex  # Watch for changes and recompile
```

## File Organization

### Centralized LaTeX Configuration
```
latex/                           # Shared LaTeX resources
├── latexmkrc                   # Main build configuration
├── formatting.sty              # Shared formatting package
├── bib_style.bst               # Bibliography style
├── latex-fix.sh               # Centralized troubleshooting script
└── LATEX_TROUBLESHOOTING.md   # This guide
```

### Individual Theory Structure
```
Theories/Logos/latex/
├── LogosReference.tex          # Main document
├── latexmkrc                   # Loads shared config: do '../../../latex/latexmkrc'
├── assets/
│   └── logos-notation.sty      # Theory-specific style package
├── bibliography/
│   └── LogosReferences.bib     # Bibliography database
├── subfiles/                   # Chapter files
└── build/                      # Generated files (auto-created)
    ├── LogosReference.pdf
    ├── LogosReference.aux
    └── ... (other auxiliary files)
```

## Configuration Notes

The centralized build system uses:
- **XeLaTeX** for Unicode and modern font support
- **Biber** for modern bibliography processing  
- **Isolated build directory** to keep source clean
- **Automatic TEXINPUTS** for finding custom packages
- **Shared configuration** across all theories
- **Theory-specific packages** in local `assets/` directories

## Prevention Tips

1. **Use the centralized latex-fix.sh script** for troubleshooting
2. **Always use latexmk** instead of direct pdflatex/xelatex calls
3. **Clean rebuild** when switching between major document changes
4. **Check compilation output** for warnings after major edits
5. **Use consistent citation keys** and verify they exist in .bib file
6. **Run complete compilation cycles** before final output (latexmk handles this)
7. **Keep custom style files** in theory-specific `assets/` directories

## Debugging Commands

```bash
# Check LaTeX version and packages
xelatex --version

# Test package loading for Logos theory
cd Theories/Logos/latex
xelatex -interaction=nonstopmode "\documentclass{article}\usepackage{logos-notation}\begin{document}Test\end{document}"

# Manual bibliography processing
biber build/LogosReference.bcf

# Show detailed compilation
latexmk -f -pdf -jobname=debug LogosReference.tex 2>&1 | tee compilation.log

# Use centralized script for comprehensive checking
./latex/latex-fix.sh check logos    # Full health check
```

## Multiple Theory Support

The centralized system supports multiple theories simultaneously:

```bash
# Work on different theories
./latex/latex-fix.sh rebuild logos    # Logos Reference Manual
./latex/latex-fix.sh rebuild bimodal # Bimodal Logic Theory
./latex/latex-fix.sh check logos     # Check Logos health
./latex/latex-fix.sh clean bimodal   # Clean Bimodal files

# Auto-detect when working from theory directory
cd Theories/Logos/latex
../../latex/latex-fix.sh rebuild     # Auto-detects "logos"
```