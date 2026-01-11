# Research Report: Task #379 - Implementation Findings

**Task**: Fix LogosReference LaTeX warnings and errors
**Date**: 2026-01-11
**Focus**: BibTeX path resolution with latexmk build directory

## Summary

Phase 1 (formatting.sty fix) and Phase 2 (adding `\nocite{*}`) completed successfully. Phase 3 (verification) revealed a complex interaction between latexmk's build directory mechanism and BibTeX's file path resolution that prevents the bibliography from being generated correctly.

## Completed Fixes

### 1. formatting.sty Package Declaration (COMPLETED)
- Changed `\ProvidesPackage{problem_set}` to `\ProvidesPackage{formatting}`
- Removed stale `%!TEX root = LogicNotes.tex` comment
- Committed in `050f354`

### 2. BibTeX Citation Commands (COMPLETED)
- Added `\nocite{*}` to LogosReference.tex before `\bibliography`
- Changed `\bibliographystyle{../../LaTeX/bib_style}` to `\bibliographystyle{bib_style}`
- Committed in `c6e46c1`

### 3. latexmkrc BSTINPUTS Configuration (PARTIAL)
- Added custom `$bibtex` command with inline environment variables
- BSTINPUTS and BIBINPUTS correctly computed using `Cwd::abs_path`

## Outstanding Issue: BibTeX with Build Directory

### Problem Description

When latexmk uses `$out_dir = 'build'`:
1. BibTeX runs from the `build/` subdirectory
2. Relative paths in `\bibliographystyle` and `\bibliography` become invalid
3. Environment variables (BSTINPUTS, BIBINPUTS) must contain absolute paths

### Attempted Solutions

#### Solution 1: ensure_path() (FAILED)
```perl
ensure_path('BSTINPUTS', '../../LaTeX');
```
- Problem: Path evaluated relative to build/ directory when bibtex runs

#### Solution 2: Absolute path computation (PARTIAL SUCCESS)
```perl
use Cwd qw(abs_path cwd);
my $shared_latex_dir = abs_path('../../LaTeX');
$ENV{'BSTINPUTS'} = "$shared_latex_dir:";
```
- Problem: latexmk resets environment variables between runs

#### Solution 3: Custom $bibtex command (PARTIAL SUCCESS)
```perl
$bibtex = "BSTINPUTS='$shared_latex_dir:' BIBINPUTS='$source_dir:' bibtex %O %S";
```
- Result: BibTeX finds files and processes bibliography correctly
- Problem: The .bbl file is empty after latexmk completes
- Diagnosis: latexmk appears to overwrite .bbl with empty content

### Evidence

Manual bibtex execution succeeds:
```
$ BSTINPUTS="/home/.../LaTeX:" BIBINPUTS="/home/.../Logos/LaTeX:" bibtex LogosReference.aux
The style file: bib_style.bst
Database file #1: bibliography/LogosReferences.bib
(There were 2 warnings)
$ wc -l LogosReference.bbl
46 LogosReference.bbl
```

After latexmk runs (even without calling bibtex):
```
$ wc -l build/LogosReference.bbl
0 build/LogosReference.bbl
```

### Root Cause Analysis

The issue appears to be in latexmk's handling of .bbl files when using `$out_dir`. Possible causes:
1. latexmk may clear .bbl as part of its dependency tracking
2. Multiple bibtex invocations may race to write the file
3. latexmk's `$emulate_aux = 1` setting may affect .bbl handling

## Options for Resolution

### Option A: Remove Bibliography (Simplest)
- Comment out `\bibliographystyle` and `\bibliography` lines
- Primary references are already inline on title page
- No functional loss if bibliography entries aren't cited

### Option B: Copy bib_style.bst to Theory Directories
- Place copy in `Logos/LaTeX/bib_style.bst` and `Bimodal/LaTeX/bib_style.bst`
- Duplicates file but eliminates path resolution issues
- Violates DRY principle

### Option C: Disable Build Directory
- Remove `$out_dir = 'build'` from latexmkrc
- Auxiliary files remain in source directory
- Less clean but works reliably

### Option D: Use Absolute Path in .tex File
- Change to `\bibliographystyle{/absolute/path/to/bib_style}`
- Ties document to specific machine/path
- Not portable

### Option E: Further Investigation
- Debug latexmk's .bbl handling more deeply
- Potential latexmk bug or configuration issue
- Time-consuming with uncertain outcome

## Current File States

### LaTeX/latexmkrc
```perl
# Custom bibtex command with inline environment variables
$bibtex = "BSTINPUTS='$shared_latex_dir:' BIBINPUTS='$source_dir:' bibtex %O %S";
```

### Logos/LaTeX/LogosReference.tex
```latex
\nocite{*}  % Include all bibliography entries without explicit citations
\bibliographystyle{bib_style}
\bibliography{bibliography/LogosReferences}
```

### LaTeX/formatting.sty
```latex
\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{formatting}[2026/01/11 ProofChecker shared formatting]
```

## Recommendations

1. **Short-term**: Use Option A (remove bibliography) since references are already inline
2. **Long-term**: Investigate Option C (disable build directory) if bibliography is needed
3. **Alternative**: Report potential bug to latexmk maintainers

## Files Modified

| File | Change | Status |
|------|--------|--------|
| `LaTeX/formatting.sty` | Fix ProvidesPackage name | Committed |
| `Logos/LaTeX/LogosReference.tex` | Add \nocite{*}, simplify bibliographystyle path | Committed |
| `LaTeX/latexmkrc` | Add BSTINPUTS/BIBINPUTS configuration | Uncommitted |

## Next Steps

Awaiting user decision on resolution approach before completing Phase 3.
