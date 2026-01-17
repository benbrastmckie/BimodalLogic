# Implementation Plan: Task #379

**Task**: Fix LogosReference LaTeX warnings and errors
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Fix LaTeX compilation warnings and errors that appeared in LogosReference.tex after integrating the shared latexmkrc configuration (Task 375). The issues fall into three categories: (1) package name mismatch in `formatting.sty`, (2) BibTeX errors from missing citations, and (3) benign warnings that can be ignored. BimodalReference.tex compiles cleanly; these fixes target LogosReference.tex specifically while also fixing the shared `formatting.sty` that affects both documents.

## Phases

### Phase 1: Fix formatting.sty Package Declaration

**Estimated effort**: 5 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Fix the `\ProvidesPackage` declaration to match the actual filename
2. Remove stale `%!TEX root` comment referencing non-existent file

**Files to modify**:
- `latex/formatting.sty` - Fix package declaration and remove stale comment

**Steps**:
1. Read `latex/formatting.sty` to confirm current state
2. Change line 3 from:
   ```latex
   \ProvidesPackage{problem_set}[2025/01/29 Support for MIT logic texts]
   ```
   to:
   ```latex
   \ProvidesPackage{formatting}[2026/01/11 ProofChecker shared formatting]
   ```
3. Remove line 1 (`%!TEX root = LogicNotes.tex`) which references a non-existent file

**Verification**:
- `formatting.sty` has correct `\ProvidesPackage{formatting}` declaration
- No `%!TEX root` comment present
- Both BimodalReference.tex and LogosReference.tex compile without package warnings

---

### Phase 2: Fix BibTeX Errors in LogosReference.tex

**Estimated effort**: 5 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Address BibTeX errors "no \citation commands" and "no style file"
2. Either enable bibliography display or remove unused bibliography infrastructure

**Files to modify**:
- `Logos/latex/LogosReference.tex` - Add `\nocite{*}` or remove bibliography lines

**Steps**:
1. Read `Logos/latex/LogosReference.tex` to find bibliography configuration
2. Decision: Add `\nocite{*}` to include all bibliography entries without explicit citations
   - This is preferred because the bibliography file exists and may be useful for reference
3. Add `\nocite{*}` before `\bibliography{...}` line:
   ```latex
   \nocite{*}  % Include all bibliography entries
   \bibliographystyle{../../latex/bib_style}
   \bibliography{bibliography/LogosReferences}
   ```

**Alternative** (if bibliography not needed):
- Comment out or remove the `\bibliographystyle` and `\bibliography` lines

**Verification**:
- BibTeX runs without "no \citation commands" error
- LogosReference.pdf includes bibliography (if `\nocite{*}` approach used)

---

### Phase 3: Verify and Test Builds

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify both documents compile without errors
2. Confirm undefined reference warnings resolve with multiple passes
3. Document any remaining benign warnings

**Files to modify**:
- None (testing only)

**Steps**:
1. Clean build artifacts:
   ```bash
   cd Logos/LaTeX && latexmk -C LogosReference.tex
   cd ../../Bimodal/LaTeX && latexmk -C BimodalReference.tex
   ```
2. Build LogosReference.tex:
   ```bash
   cd Logos/LaTeX && latexmk LogosReference.tex
   ```
3. Verify:
   - No BibTeX errors
   - No package warnings about `formatting`
   - Undefined references resolved (or documented as expected on first build)
4. Build BimodalReference.tex:
   ```bash
   cd Bimodal/LaTeX && latexmk BimodalReference.tex
   ```
5. Verify BimodalReference compiles cleanly
6. Note: `\showhyphens has changed` warning from microtype is benign and will be ignored

**Verification**:
- LogosReference.pdf generated in `build/` without errors
- BimodalReference.pdf generated in `build/` without errors
- No critical warnings in build output (package warnings, bibtex errors)

---

## Dependencies

- Task 375 (Integrate latexmkrc) - COMPLETED
- Task 373 (Create shared LaTeX assets) - COMPLETED

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bibliography file missing entries | Low | Low | `\nocite{*}` will simply include whatever entries exist |
| Other documents depend on `problem_set` package name | Medium | Very Low | Search codebase for references; `formatting` is the correct name |
| Cross-reference warnings persist | Low | Low | These resolve with additional latexmk passes; not errors |

## Success Criteria

- [ ] `latex/formatting.sty` has `\ProvidesPackage{formatting}` declaration
- [ ] `latex/formatting.sty` has no stale `%!TEX root` comment
- [ ] `Logos/latex/LogosReference.tex` compiles without BibTeX errors
- [ ] `Bimodal/latex/BimodalReference.tex` compiles without package warnings
- [ ] Both PDFs generated successfully in `build/` directories

## Rollback Plan

If implementation causes issues:
1. Revert `formatting.sty` changes:
   ```bash
   git checkout latex/formatting.sty
   ```
2. Revert `LogosReference.tex` changes:
   ```bash
   git checkout Logos/latex/LogosReference.tex
   ```
3. Original documents will compile (with the same warnings/errors as before)
