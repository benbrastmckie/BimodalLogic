# Implementation Plan: Task #379

**Task**: Fix LogosReference LaTeX warnings and errors
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Reason**: Use research findings on `ensure_path()` best practices to fix BibTeX/build directory issue

## Revision Summary

Research (research-003.md) revealed that the current approach using a custom `$bibtex` command with inline environment variables conflicts with latexmk's internal `$bibtex_fudge` mechanism. The recommended approach is to use latexmk's `ensure_path()` function instead.

### Previous Plan Status
- Phase 1: [COMPLETED] - formatting.sty package declaration fixed (commit 050f354)
- Phase 2: [COMPLETED] - `\nocite{*}` added, bibliographystyle simplified (commit c6e46c1)
- Phase 3: [PARTIAL] - Verification revealed .bbl file empty due to latexmk/bibtex conflict

### Key Changes
1. **New Phase 3**: Replace custom `$bibtex` command with `ensure_path()` calls
2. **New Phase 4**: Implement fallback (copy .bst) if `ensure_path()` doesn't resolve issue
3. **Revised verification**: Test .bbl file content, not just compilation success

## Overview

The original plan's Phases 1-2 are complete but Phase 3 (verification) revealed a deeper issue: latexmk's build directory mechanism conflicts with BibTeX's file discovery. The custom `$bibtex` command attempted in research-002.md resulted in empty .bbl files. This revised plan implements the researched best practice of using `ensure_path()`.

## Phases

### Phase 1: Fix formatting.sty Package Declaration [COMPLETED]

**Status**: [COMPLETED] - Committed 050f354

Already fixed:
- Changed `\ProvidesPackage{problem_set}` to `\ProvidesPackage{formatting}`
- Removed stale `%!TEX root` comment

---

### Phase 2: Fix BibTeX Citation Commands [COMPLETED]

**Status**: [COMPLETED] - Committed c6e46c1

Already fixed:
- Added `\nocite{*}` before `\bibliography`
- Changed `\bibliographystyle{../../LaTeX/bib_style}` to `\bibliographystyle{bib_style}`

---

### Phase 3: Fix latexmkrc with ensure_path()

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace custom `$bibtex` command with `ensure_path()` calls
2. Let latexmk's `$bibtex_fudge` handle directory changes properly
3. Ensure BibTeX can find both .bst and .bib files

**Files to modify**:
- `LaTeX/latexmkrc` - Replace custom bibtex with ensure_path

**Steps**:
1. Read current `LaTeX/latexmkrc` to confirm current state
2. Remove the custom `$bibtex` line (line 59):
   ```perl
   # DELETE THIS:
   $bibtex = "BSTINPUTS='$shared_latex_dir:' BIBINPUTS='$source_dir:' bibtex %O %S";
   ```
3. Add `ensure_path()` calls after the `$source_dir` definition:
   ```perl
   # Use ensure_path for proper latexmk integration with bibtex_fudge
   ensure_path('BSTINPUTS', "$shared_latex_dir//");
   ensure_path('BIBINPUTS', "$source_dir//");
   ```
4. Update the comment block to explain the approach

**Verification**:
- Run `latexmk -verbose LogosReference.tex` from `Logos/LaTeX/`
- Check that bibtex finds `bib_style.bst` in output
- Verify `build/LogosReference.bbl` is non-empty (should have ~46 lines)
- Confirm PDF has bibliography section

---

### Phase 4: Fallback - Copy .bst File (If Phase 3 Fails)

**Estimated effort**: 5 minutes
**Status**: [SKIPPED] - Phase 3 succeeded, fallback not needed
**Conditional**: Only execute if Phase 3 verification fails

**Objectives**:
1. Copy `bib_style.bst` to theory LaTeX directories as fallback
2. Eliminate path resolution entirely

**Files to modify**:
- `Logos/LaTeX/bib_style.bst` (copy from `LaTeX/bib_style.bst`)

**Steps**:
1. If Phase 3 verification fails, copy .bst file:
   ```bash
   cp LaTeX/bib_style.bst Logos/LaTeX/bib_style.bst
   ```
2. The `\bibliographystyle{bib_style}` in LogosReference.tex will find local copy
3. Add comment in copied file noting it's a copy:
   ```
   % Copy of LaTeX/bib_style.bst for build directory compatibility
   % See Task 379 research-003.md for explanation
   ```

**Verification**:
- Same as Phase 3: non-empty .bbl, PDF with bibliography

---

### Phase 5: Final Verification and Cleanup

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify both LogosReference and BimodalReference compile cleanly
2. Clean up any uncommitted latexmkrc changes from research-002
3. Document solution in LaTeX/README.md

**Files to modify**:
- `LaTeX/README.md` - Document BibTeX configuration (if not already documented)

**Steps**:
1. Clean build:
   ```bash
   cd Logos/LaTeX && rm -rf build && latexmk LogosReference.tex
   ```
2. Verify LogosReference.pdf has bibliography
3. Clean build BimodalReference:
   ```bash
   cd ../../Bimodal/LaTeX && rm -rf build && latexmk BimodalReference.tex
   ```
4. Verify BimodalReference compiles without warnings
5. Update LaTeX/README.md if needed to document the `ensure_path()` configuration

**Verification**:
- Both PDFs generated successfully
- LogosReference.pdf contains bibliography
- No BibTeX errors in build logs
- No package warnings

---

## Dependencies

- Task 375 (Integrate latexmkrc) - COMPLETED
- Task 373 (Create shared LaTeX assets) - COMPLETED
- Research-003.md findings on `ensure_path()` best practices

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ensure_path()` doesn't work with theory stub config | Medium | Medium | Phase 4 fallback: copy .bst file |
| BimodalReference affected by latexmkrc changes | Medium | Low | Test BimodalReference in Phase 5 |
| Latexmk version incompatibility | Low | Very Low | `ensure_path()` is documented in official manual |

## Success Criteria

- [x] `LaTeX/formatting.sty` has `\ProvidesPackage{formatting}` declaration
- [x] `LaTeX/formatting.sty` has no stale `%!TEX root` comment
- [x] `Logos/LaTeX/LogosReference.tex` has `\nocite{*}` and simplified bibliographystyle
- [ ] `LaTeX/latexmkrc` uses `ensure_path()` instead of custom `$bibtex`
- [ ] `build/LogosReference.bbl` is non-empty after build
- [ ] `Logos/LaTeX/build/LogosReference.pdf` includes bibliography
- [ ] `Bimodal/LaTeX/build/BimodalReference.pdf` compiles without warnings

## Rollback Plan

If implementation causes issues:
1. Revert latexmkrc changes:
   ```bash
   git checkout LaTeX/latexmkrc
   ```
2. If Phase 4 fallback was used, remove copied .bst:
   ```bash
   rm Logos/LaTeX/bib_style.bst
   ```
3. Original configuration will restore (with the same warnings as before)
