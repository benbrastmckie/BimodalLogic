# Implementation Plan: Task #866

- **Task**: 866 - consolidate_latex_files
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/866_consolidate_latex_files/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Consolidate all LaTeX files needed for BimodalReference.tex into `Theories/Bimodal/latex/`, eliminating the root `latex/` directory. This aligns with the user's goal of having all necessary LaTeX files in a tidy, self-contained location. The approach moves shared style files to the Bimodal assets directory, makes the latexmkrc self-contained, and removes the now-unnecessary root latex directory.

### Research Integration

Based on research-001.md findings:
- BimodalReference.tex depends on only 2 shared style files: `formatting.sty` and `notation-standards.sty`
- The latexmkrc stub pattern can be collapsed into a single self-contained config
- The `latex/build/` directory contains orphaned artifacts safe to delete
- No other theories exist, so shared architecture provides no current benefit

## Goals & Non-Goals

**Goals**:
- Move `formatting.sty` and `notation-standards.sty` to `Theories/Bimodal/latex/assets/`
- Make `Theories/Bimodal/latex/latexmkrc` self-contained (no stub pattern)
- Delete the root `latex/` directory entirely
- Verify BimodalReference.tex compiles successfully after changes

**Non-Goals**:
- Preserving multi-theory shared architecture (only Bimodal exists)
- Updating Logos references in documentation (deleting with directory)
- Modifying BimodalReference.tex content beyond package import paths

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breaks after move | High | Medium | Test compilation after each file move |
| Missing dependency | Medium | Low | Trace all imports before moving |
| Path resolution issues | Medium | Medium | Update TEXINPUTS in latexmkrc explicitly |

## Implementation Phases

### Phase 1: Move Shared Style Files [COMPLETED]

**Goal**: Copy shared style files to Bimodal assets directory

**Tasks**:
- [ ] Copy `latex/formatting.sty` to `Theories/Bimodal/latex/assets/formatting.sty`
- [ ] Copy `latex/notation-standards.sty` to `Theories/Bimodal/latex/assets/notation-standards.sty`
- [ ] Verify both files are present in assets directory

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/latex/assets/formatting.sty` - new file (copy)
- `Theories/Bimodal/latex/assets/notation-standards.sty` - new file (copy)

**Verification**:
- Both .sty files exist in assets directory
- File contents match originals

---

### Phase 2: Update latexmkrc Configuration [COMPLETED]

**Goal**: Make latexmkrc self-contained without stub pattern

**Tasks**:
- [ ] Read current `latex/latexmkrc` to understand all configuration
- [ ] Read current `Theories/Bimodal/latex/latexmkrc` stub
- [ ] Create new self-contained latexmkrc with:
  - TEXINPUTS pointing to local `assets//` directory only
  - All build options from root config
  - Output directory configuration
- [ ] Replace Bimodal latexmkrc with self-contained version

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/latex/latexmkrc` - replace stub with full config

**Verification**:
- latexmkrc contains all necessary configuration
- No reference to `../../../latex/` path

---

### Phase 3: Test Build [COMPLETED]

**Goal**: Verify BimodalReference.tex compiles with new configuration

**Tasks**:
- [ ] Run `latexmk BimodalReference.tex` in Bimodal/latex directory
- [ ] Verify PDF is generated without errors
- [ ] Check for any missing package warnings

**Timing**: 10 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `latexmk` exits with code 0
- `BimodalReference.pdf` is generated
- No "File not found" or "Package not found" errors in log

---

### Phase 4: Remove Root latex Directory [COMPLETED]

**Goal**: Delete the now-unnecessary root latex directory

**Tasks**:
- [ ] Ensure Phase 3 build succeeded
- [ ] Delete `latex/build/` directory (orphaned artifacts)
- [ ] Delete `latex/formatting.sty` (moved to Bimodal)
- [ ] Delete `latex/notation-standards.sty` (moved to Bimodal)
- [ ] Delete `latex/latexmkrc` (functionality in Bimodal)
- [ ] Delete `latex/bib_style.bst` (unused by Bimodal)
- [ ] Delete `latex/latex-fix.sh` (troubleshooting script, optional)
- [ ] Delete `latex/README.md` (documentation for deleted structure)
- [ ] Delete `latex/MIGRATION_SUMMARY.md` (documentation)
- [ ] Delete `latex/LATEX_TROUBLESHOOTING.md` (documentation)
- [ ] Remove empty `latex/` directory

**Timing**: 15 minutes

**Files to modify**:
- `latex/` - entire directory deleted

**Verification**:
- `latex/` directory no longer exists
- `ls latex/` returns "No such file or directory"

---

### Phase 5: Final Verification [COMPLETED]

**Goal**: Confirm clean build and no broken references

**Tasks**:
- [ ] Run final `latexmk BimodalReference.tex` build
- [ ] Verify PDF generation succeeds
- [ ] Check for any references to old `latex/` path in codebase
- [ ] Clean build artifacts (optional)

**Timing**: 10 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Build succeeds without warnings about missing files
- No grep hits for `../../../latex` in Theories/Bimodal/latex/

## Testing & Validation

- [ ] BimodalReference.tex compiles successfully after Phase 2
- [ ] BimodalReference.tex compiles successfully after Phase 4
- [ ] No references to root latex/ directory remain
- [ ] All 7 subfiles compile correctly (via main document)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified: `Theories/Bimodal/latex/assets/formatting.sty` (new)
- Modified: `Theories/Bimodal/latex/assets/notation-standards.sty` (new)
- Modified: `Theories/Bimodal/latex/latexmkrc` (self-contained)
- Deleted: `latex/` directory (entire)

## Rollback/Contingency

If build fails after changes:
1. Restore `latex/` directory from git: `git checkout -- latex/`
2. Restore original latexmkrc: `git checkout -- Theories/Bimodal/latex/latexmkrc`
3. Delete copied files: `rm Theories/Bimodal/latex/assets/{formatting,notation-standards}.sty`

Full rollback command:
```bash
git checkout -- latex/ Theories/Bimodal/latex/latexmkrc
rm -f Theories/Bimodal/latex/assets/formatting.sty
rm -f Theories/Bimodal/latex/assets/notation-standards.sty
```
