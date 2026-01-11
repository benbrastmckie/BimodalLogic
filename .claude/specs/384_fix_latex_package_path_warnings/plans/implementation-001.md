# Implementation Plan: Task #384

**Task**: Fix LaTeX package path warnings in LogosReference.tex
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Fix the LaTeX package path mismatch warnings by configuring TEXINPUTS in latexmkrc to add custom package directories to the search path. This allows packages to be referenced by their base names (e.g., `logos-notation` instead of `assets/logos-notation`), eliminating the warnings while maintaining the project's modular package structure.

## Phases

### Phase 1: Configure TEXINPUTS in latexmkrc

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add TEXINPUTS configuration to central LaTeX/latexmkrc
2. Configure paths for both theory-specific and shared packages

**Files to modify**:
- `LaTeX/latexmkrc` - Add TEXINPUTS ensure_path() calls

**Steps**:
1. Open `LaTeX/latexmkrc`
2. Add after the existing `ensure_path()` calls for BSTINPUTS/BIBINPUTS:
   ```perl
   # TEXINPUTS for custom .sty files
   # $source_dir/assets// enables theory-specific packages (e.g., logos-notation.sty)
   # $shared_latex_dir// enables shared packages (e.g., formatting.sty, notation-standards.sty)
   ensure_path('TEXINPUTS', "$source_dir/assets//");
   ensure_path('TEXINPUTS', "$shared_latex_dir//");
   ```

**Verification**:
- Run `latexmk -n -xelatex LogosReference.tex` to verify config loads without errors

---

### Phase 2: Update Package References

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update LogosReference.tex to use base package names
2. Update logos-notation.sty to use base package name for RequirePackage

**Files to modify**:
- `Logos/LaTeX/LogosReference.tex` - Change `\usepackage` calls
- `Logos/LaTeX/assets/logos-notation.sty` - Change `\RequirePackage` call

**Steps**:
1. In `Logos/LaTeX/LogosReference.tex`, change:
   - `\usepackage{assets/logos-notation}` → `\usepackage{logos-notation}`
   - `\usepackage{../../LaTeX/formatting}` → `\usepackage{formatting}`

2. In `Logos/LaTeX/assets/logos-notation.sty`, change:
   - `\RequirePackage{../../LaTeX/notation-standards}` → `\RequirePackage{notation-standards}`

**Verification**:
- File syntax is correct (no path separators in package names)

---

### Phase 3: Build and Verify

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Run clean build to regenerate all auxiliary files
2. Verify package path warnings are eliminated
3. Confirm PDF generates correctly

**Files to check**:
- `Logos/LaTeX/build/LogosReference.log` - Check for warnings

**Steps**:
1. Clean previous build: `cd Logos/LaTeX && latexmk -C`
2. Run full build: `latexmk -xelatex LogosReference.tex`
3. Grep log for warnings: `grep -i "Warning.*package" build/LogosReference.log`
4. Verify expected warnings are gone:
   - No "You have requested package 'assets/logos-notation'"
   - No "You have requested package '../../LaTeX/notation-standards'"
   - No "You have requested package '../../LaTeX/formatting'"
5. Open `build/LogosReference.pdf` to verify document renders correctly

**Verification**:
- Build succeeds
- No package path mismatch warnings in log
- PDF renders correctly with all notation

---

## Dependencies

- None (self-contained fix)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TEXINPUTS order affects package discovery | Med | Low | Test thoroughly; ensure_path prepends to existing paths |
| Other LaTeX files may use relative paths | Low | Low | Grep for other `\usepackage{.*\/` patterns |
| Subfiles may have different working directory | Med | Med | Test subfile compilation separately |

## Success Criteria

- [ ] Build completes without package path mismatch warnings
- [ ] All three warnings eliminated:
  - logos-notation
  - notation-standards
  - formatting
- [ ] PDF renders correctly
- [ ] Subfiles can still be compiled independently (if applicable)

## Rollback Plan

If the TEXINPUTS approach fails:
1. Revert changes to `LaTeX/latexmkrc`
2. Revert changes to `LogosReference.tex`
3. Revert changes to `logos-notation.sty`
4. Accept warnings as cosmetic (they don't affect PDF output)
