# Implementation Plan: Task #396

**Task**: Fix LaTeX build missing style files
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Fix the LaTeX build errors by correcting path resolution in the shared `latexmkrc` configuration and updating the `bimodal-notation.sty` package to use TEXINPUTS-based resolution instead of hardcoded relative paths. The solution uses the latexmkrc file's own location as the anchor point for path calculation, making it robust against directory structure changes.

## Phases

### Phase 1: Fix Shared latexmkrc Path Calculation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Change `$shared_latex_dir` to compute path based on latexmkrc file location
2. Ensure TEXINPUTS correctly includes both theory-specific and shared directories

**Files to modify**:
- `latex/latexmkrc` - Fix path calculation logic

**Steps**:
1. Add `use File::Basename;` to imports
2. Change `$shared_latex_dir` calculation from `abs_path('../../LaTeX')` to `dirname(abs_path(__FILE__))`
3. Verify the `ensure_path('TEXINPUTS', ...)` calls use the corrected paths

**Code change**:
```perl
# Before:
my $shared_latex_dir = abs_path('../../LaTeX');

# After:
use File::Basename;
my $shared_latex_dir = dirname(abs_path(__FILE__));
```

**Note**: In latexmkrc, `__FILE__` is the standard way to get the current file path in Perl. However, when loaded via `do`, we need to use `$INC{...}` or the special variable. Testing will confirm the correct approach.

**Verification**:
- Run `cd Theories/Logos/LaTeX && perl -e "do '../../latex/latexmkrc'; print \"TEXINPUTS: $ENV{TEXINPUTS}\n\";"` to verify path computation
- Confirm `$shared_latex_dir` resolves to absolute path of `latex/` directory

---

### Phase 2: Fix bimodal-notation.sty Package Import

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Change hardcoded relative path to TEXINPUTS-based package name

**Files to modify**:
- `Theories/Bimodal/LaTeX/assets/bimodal-notation.sty` - Change `\RequirePackage` path

**Steps**:
1. Change line 18 from `\RequirePackage{../../latex/notation-standards}` to `\RequirePackage{notation-standards}`

**Code change**:
```latex
% Before:
\RequirePackage{../../latex/notation-standards}

% After:
\RequirePackage{notation-standards}
```

**Verification**:
- This mirrors the pattern already used in `logos-notation.sty`
- Will be verified during Phase 4 build test

---

### Phase 3: Update Documentation

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update `latex/README.md` to reflect actual directory structure
2. Ensure examples show correct paths

**Files to modify**:
- `latex/README.md` - Update directory paths and examples

**Steps**:
1. Change `Bimodal/latex/` references to `Theories/Bimodal/LaTeX/`
2. Change `Logos/latex/` references to `Theories/Logos/LaTeX/`
3. Update the directory tree diagram at the end of the file
4. Verify usage examples are consistent with actual structure

**Verification**:
- Read through updated documentation to ensure consistency
- Verify all path references are accurate

---

### Phase 4: Test and Verify Builds

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Build both LaTeX documents successfully
2. Verify no style file errors occur

**Steps**:
1. Build Logos document:
   ```bash
   cd Theories/Logos/LaTeX && latexmk -C && latexmk LogosReference.tex
   ```
2. Build Bimodal document:
   ```bash
   cd Theories/Bimodal/LaTeX && latexmk -C && latexmk BimodalReference.tex
   ```
3. Verify both PDFs are generated in `build/` subdirectory
4. Check build logs for any warnings related to style files

**Verification**:
- Both `Theories/Logos/LaTeX/build/LogosReference.pdf` and `Theories/Bimodal/LaTeX/build/BimodalReference.pdf` exist
- No "File not found" errors in build output
- No package loading warnings

## Dependencies

- None (self-contained fix)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `__FILE__` not available in `do` context | High | Medium | Test first, fall back to `$0` or explicit path if needed |
| Other latexmkrc consumers break | Medium | Low | Only theory directories use this config |
| Different behavior on macOS vs Linux | Low | Low | Perl path handling is cross-platform |

## Success Criteria

- [ ] `latexmk LogosReference.tex` builds without style file errors
- [ ] `latexmk BimodalReference.tex` builds without style file errors
- [ ] Both PDFs are generated successfully
- [ ] Documentation reflects actual directory structure

## Rollback Plan

If the fix causes issues:
1. Revert `latex/latexmkrc` to previous version
2. Revert `Theories/Bimodal/LaTeX/assets/bimodal-notation.sty` to previous version
3. Use explicit TEXINPUTS environment variable as workaround:
   ```bash
   TEXINPUTS="./assets/:../../../latex//:" latexmk BimodalReference.tex
   ```
