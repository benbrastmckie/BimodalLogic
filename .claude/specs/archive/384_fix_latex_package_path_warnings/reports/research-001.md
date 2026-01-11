# Research Report: Task #384

**Task**: Fix LaTeX package path warnings in LogosReference.tex
**Date**: 2026-01-11
**Focus**: Understanding and resolving package path warnings

## Summary

The LaTeX warnings arise from a mismatch between the path used in `\usepackage{...}` and the name declared in `\ProvidesPackage{...}`. This is a known LaTeX behavior when packages are loaded via relative paths. The proper fix is to use TEXINPUTS to add custom directories to the search path, allowing packages to be referenced by their base names.

## Findings

### Current Warnings (After Fresh Build)

After running `latexmk -f -xelatex LogosReference.tex`, the log shows:

1. **Package path mismatch warnings**:
   - `You have requested package 'assets/logos-notation', but the package provides 'logos-notation'`
   - `You have requested package '../../latex/notation-standards', but the package provides 'notation-standards'`
   - `You have requested package '../../latex/formatting', but the package provides 'formatting'`

2. **Minor float warning**:
   - `'h' float specifier changed to 'ht'` (cosmetic, not addressed in this task)

### Root Cause Analysis

The warnings occur because:
1. LaTeX's `\usepackage` expects the package name to match exactly what `\ProvidesPackage` declares
2. When using relative paths like `assets/logos-notation`, LaTeX sees the full path as the "requested" package name
3. But `\ProvidesPackage{logos-notation}` correctly declares just the base name
4. This creates a mismatch that triggers warnings (not errors)

According to [LaTeX documentation](https://latexref.xyz/_005cProvidesClass-_0026-_005cProvidesPackage.html), the package name in `\ProvidesPackage` must match the filename. Including directory paths in package names is not good style since LaTeX package names are directory-agnostic.

### File Structure

```
ProofChecker/
├── latex/
│   ├── latexmkrc          # Central build config
│   ├── notation-standards.sty
│   └── formatting.sty
└── Logos/latex/
    ├── latexmkrc          # Loads ../../latex/latexmkrc
    ├── LogosReference.tex
    └── assets/
        └── logos-notation.sty  # Requires notation-standards
```

### Current Package Loading (Problematic)

In `LogosReference.tex`:
```latex
\usepackage{assets/logos-notation}
\usepackage{../../latex/formatting}
```

In `assets/logos-notation.sty`:
```latex
\RequirePackage{../../latex/notation-standards}
```

### Solution: Use TEXINPUTS

The [Kpathsea documentation](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files) explains that TEXINPUTS can be configured to add custom directories to LaTeX's search path. The latexmkrc already uses `ensure_path()` for BSTINPUTS and BIBINPUTS.

**Best approach**: Extend the latexmkrc to add TEXINPUTS paths:

```perl
ensure_path('TEXINPUTS', "$source_dir/assets//");  # Theory-specific packages
ensure_path('TEXINPUTS', "$shared_latex_dir//");   # Shared packages
```

This allows:
```latex
\usepackage{logos-notation}      % Found in assets/
\usepackage{formatting}          % Found in ../../latex/
\RequirePackage{notation-standards}  % Found in ../../latex/
```

### Alternative Approaches Considered

1. **Edit \ProvidesPackage to include path** - Rejected as it's against LaTeX conventions
2. **Install packages to TEXMF tree** - Rejected as it defeats the purpose of local project packages
3. **Use \input@path** - Rejected as it causes its own warnings ([Issue #472](https://github.com/latex3/latex2e/issues/472))

### Warnings No Longer Present

The following warnings from the original issue are no longer present in the xelatex build:
- `Command \showhyphens has changed` - Related to microtype/pdflatex; xelatex doesn't trigger this
- `Label(s) may have changed` - Cross-references are now stable

## Recommendations

1. **Add TEXINPUTS configuration to latex/latexmkrc**:
   ```perl
   ensure_path('TEXINPUTS', "$source_dir/assets//");
   ensure_path('TEXINPUTS', "$shared_latex_dir//");
   ```

2. **Update LogosReference.tex package loading**:
   ```latex
   \usepackage{logos-notation}  % was: assets/logos-notation
   \usepackage{formatting}      % was: ../../latex/formatting
   ```

3. **Update logos-notation.sty RequirePackage**:
   ```latex
   \RequirePackage{notation-standards}  % was: ../../latex/notation-standards
   ```

4. **Test the build** to confirm warnings are resolved

## References

- [LaTeX \ProvidesPackage documentation](https://latexref.xyz/_005cProvidesClass-_0026-_005cProvidesPackage.html)
- [Kpathsea and TEXINPUTS](https://www.overleaf.com/learn/latex/Articles/An_introduction_to_Kpathsea_and_how_TeX_engines_search_for_files)
- [Package name mismatch issue](https://github.com/xdanaux/moderncv/issues/7)
- [GitHub Issue: \input@path warnings](https://github.com/latex3/latex2e/issues/472)

## Next Steps

1. Create implementation plan
2. Implement TEXINPUTS configuration in latex/latexmkrc
3. Update package references to use base names
4. Verify build succeeds without warnings
