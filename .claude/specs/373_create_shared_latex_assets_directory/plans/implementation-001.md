# Implementation Plan: Task #373

**Task**: Create shared LaTeX assets directory
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

Create a ProofChecker/latex/ directory containing shared assets for all theory-specific LaTeX documentation. This includes:
1. `formatting.sty` - Common document formatting (currently duplicated)
2. `bib_style.bst` - Bibliography style (currently duplicated)
3. `notation-standards.sty` - NEW: Common notation definitions shared across theories

Theory-specific notation files will import notation-standards.sty and add their own specialized notation.

## Phases

### Phase 1: Create ProofChecker/latex/ Directory Structure

**Status**: [NOT STARTED]

**Objectives**:
1. Create ProofChecker/latex/ directory
2. Move formatting.sty to shared location
3. Move bib_style.bst to shared location

**Files to create/modify**:
- `latex/` - New directory
- `latex/formatting.sty` - Moved from Logos/latex/assets/
- `latex/bib_style.bst` - Moved from Logos/latex/assets/

**Steps**:
1. Create `ProofChecker/latex/` directory
2. Copy `Logos/latex/assets/formatting.sty` to `latex/formatting.sty`
3. Copy `Logos/latex/assets/bib_style.bst` to `latex/bib_style.bst`

**Verification**:
- Directory exists with both files

---

### Phase 2: Create notation-standards.sty

**Status**: [NOT STARTED]

**Objectives**:
1. Create shared notation standards file with common definitions
2. Include notation used identically across theories

**Files to create**:
- `latex/notation-standards.sty` - Common notation definitions

**Common notation to include** (shared between logos-notation.sty and bimodal-notation.sty):
- Modal operators: `\nec` (Box), `\poss` (Diamond)
- Truth relations: `\satisfies`, `\notsatisfies`
- Proof theory: `\proves`, `\context`
- Meta-variables: `\metaphi`, `\metapsi`, `\metachi`
- Model notation: `\model`
- Lean reference: `\leansrc`, `\leanref`
- Required packages: amsmath, amssymb, mathtools

**Steps**:
1. Create notation-standards.sty with package header
2. Add required packages section
3. Add modal operators section (nec, poss)
4. Add truth relations section (satisfies, notsatisfies)
5. Add proof theory section (proves, context)
6. Add meta-variables section
7. Add model notation section
8. Add Lean cross-reference commands

**Verification**:
- File compiles without errors when loaded

---

### Phase 3: Refactor Theory-Specific Notation Files

**Status**: [NOT STARTED]

**Objectives**:
1. Update logos-notation.sty to import notation-standards.sty
2. Update bimodal-notation.sty to import notation-standards.sty
3. Remove duplicated definitions from theory files

**Files to modify**:
- `Logos/latex/assets/logos-notation.sty` - Import standards, remove duplicates
- `Bimodal/latex/assets/bimodal-notation.sty` - Import standards, remove duplicates

**Steps**:
1. Add `\RequirePackage{../../latex/notation-standards}` to logos-notation.sty
2. Remove from logos-notation.sty: nec, poss, satisfies, notsatisfies, proves, context, metaphi, metapsi, metachi, model
3. Add `\RequirePackage{../../latex/notation-standards}` to bimodal-notation.sty
4. Remove from bimodal-notation.sty: nec, poss, satisfies, notsatisfies, proves, context, metaphi, metapsi, metachi, model

**Verification**:
- Both notation files load without errors
- No duplicate definition warnings

---

### Phase 4: Update Document Import Paths

**Status**: [NOT STARTED]

**Objectives**:
1. Update LogosReference.tex to use shared formatting.sty
2. Update BimodalReference.tex to use shared formatting.sty
3. Update bibliography style paths

**Files to modify**:
- `Logos/latex/LogosReference.tex` - Update import paths
- `Bimodal/latex/BimodalReference.tex` - Update import paths

**Steps**:
1. In LogosReference.tex:
   - Change `\usepackage{assets/formatting}` to `\usepackage{../../latex/formatting}`
   - Change `\bibliographystyle{assets/bib_style}` to `\bibliographystyle{../../latex/bib_style}`
2. In BimodalReference.tex:
   - Change `\usepackage{assets/formatting}` to `\usepackage{../../latex/formatting}`
   - Add `\bibliographystyle{../../latex/bib_style}` if using bibliography

**Verification**:
- Both documents compile with new paths

---

### Phase 5: Remove Duplicate Files

**Status**: [NOT STARTED]

**Objectives**:
1. Remove duplicate formatting.sty files
2. Remove duplicate bib_style.bst files

**Files to delete**:
- `Logos/latex/assets/formatting.sty`
- `Logos/latex/assets/bib_style.bst`
- `Bimodal/latex/assets/formatting.sty`
- `Bimodal/latex/assets/bib_style.bst`

**Steps**:
1. Delete `Logos/latex/assets/formatting.sty`
2. Delete `Logos/latex/assets/bib_style.bst`
3. Delete `Bimodal/latex/assets/formatting.sty`
4. Delete `Bimodal/latex/assets/bib_style.bst`

**Verification**:
- Files no longer exist in theory-specific assets directories

---

### Phase 6: Verification and Documentation

**Status**: [NOT STARTED]

**Objectives**:
1. Compile both reference documents to verify everything works
2. Create README.md documenting the shared assets

**Files to create/verify**:
- `latex/README.md` - Documentation
- Verify: `Logos/latex/LogosReference.pdf`
- Verify: `Bimodal/latex/BimodalReference.pdf`

**Steps**:
1. Compile LogosReference.tex with pdflatex
2. Compile BimodalReference.tex with pdflatex
3. Verify no errors or warnings related to missing files
4. Create README.md with:
   - Purpose of shared directory
   - List of shared files and descriptions
   - Usage instructions for new theories
   - Import path examples

**Verification**:
- Both PDFs generate successfully
- README.md exists with complete documentation

---

## Dependencies

- None external

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Relative path issues | Medium | Low | Test compilation after each phase |
| Conflicting definitions | Low | Low | Use \providecommand for safe redefinition |
| Missing imports | Medium | Low | Verify all \RequirePackage statements |

## Success Criteria

- [ ] ProofChecker/latex/ directory created with shared assets
- [ ] notation-standards.sty provides common notation for all theories
- [ ] logos-notation.sty imports standards and adds Logos-specific notation
- [ ] bimodal-notation.sty imports standards and adds Bimodal-specific notation
- [ ] LogosReference.tex compiles successfully with shared imports
- [ ] BimodalReference.tex compiles successfully with shared imports
- [ ] No duplicate files remain in theory-specific assets directories
- [ ] README.md documents usage for future theories

## Rollback Plan

If implementation fails:
1. Restore formatting.sty to both theory directories from git
2. Restore bib_style.bst to both theory directories from git
3. Revert notation files to pre-import state
4. Revert document import paths
5. Delete ProofChecker/latex/ directory
