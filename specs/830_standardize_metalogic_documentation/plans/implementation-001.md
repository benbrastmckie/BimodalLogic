# Implementation Plan: Task #830

- **Task**: 830 - standardize_metalogic_documentation
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/830_standardize_metalogic_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Standardize README.md files across all Bimodal/Metalogic/ subdirectories to comply with DIRECTORY_README_STANDARD.md (Template D: LEAN Source Directory) and DOC_QUALITY_CHECKLIST.md. Research identified that Decidability/ is missing a README entirely, while existing READMEs need updates for accuracy, cross-link validity, and sorry count consistency. Each README must accurately report all directory contents, include subdirectory summaries with links, and provide appropriate cross-links to related documentation.

### Research Integration

Key findings from research-001.md:
- All target directories have existing READMEs except Decidability/ (8 files, no README)
- FMP/README.md has major inaccuracies (references non-existent files)
- Main Metalogic/README.md needs architecture updates and sorry count correction (4 sorries per Metalogic.lean)
- Bundle/README.md missing ModalSaturation.lean in listing
- Cross-links to archived directories (Representation/, Completeness/) need updating
- Sorry counts inconsistent across READMEs

## Goals & Non-Goals

**Goals**:
- Create Decidability/README.md following Template D (40-70 lines, navigation-focused)
- Update main Metalogic/README.md with accurate architecture and sorry counts
- Fix FMP/README.md to reflect actual 4-file directory structure
- Add ModalSaturation.lean to Bundle/README.md
- Standardize cross-links across all READMEs
- Update all "Last updated" timestamps
- Ensure 100-character line limit compliance

**Non-Goals**:
- Modifying .lean source files
- Creating extensive documentation beyond Template D guidelines
- Duplicating docstrings from .lean files in READMEs
- Adding READMEs to directories that don't need them (<3 files, self-explanatory)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale cross-links after updates | Medium | Medium | Verify all links work after changes |
| Sorry count drift | Low | Medium | Source from Metalogic.lean docstring as single truth |
| Over-documentation | Low | Low | Follow Template D line limits (40-70 lines) |
| Missing files in listings | Medium | Low | Use `ls` to verify actual directory contents |

## Implementation Phases

### Phase 1: Create Decidability/README.md [NOT STARTED]

**Goal**: Create missing README for the 8-file Decidability/ subdirectory following Template D.

**Tasks**:
- [ ] Verify actual file contents of Decidability/ directory
- [ ] Create Decidability/README.md with Template D structure
- [ ] Document all 8 Lean files with brief purpose descriptions
- [ ] Explain tableau-based decision procedure approach
- [ ] Add cross-links to main Metalogic/README.md
- [ ] Note sorry status from Metalogic.lean docstring

**Timing**: 30 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Decidability/README.md` - New file following Template D

**Verification**:
- README exists and has 40-70 lines
- All 8 files (SignedFormula, Tableau, Saturation, Closure, Correctness, ProofExtraction, CountermodelExtraction, DecisionProcedure) documented
- Cross-links valid

---

### Phase 2: Fix FMP/README.md [NOT STARTED]

**Goal**: Correct major inaccuracies in FMP/README.md to reflect actual 4-file directory structure.

**Tasks**:
- [ ] Verify actual FMP/ directory contents (4 files expected)
- [ ] Remove references to non-existent files (FiniteModelProperty.lean, ConsistentSatisfiable.lean)
- [ ] Update module table to match actual files: BoundedTime.lean, Closure.lean, FiniteWorldState.lean, SemanticCanonicalModel.lean
- [ ] Correct sorry location reference
- [ ] Update cross-links
- [ ] Update "Last updated" timestamp

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/README.md` - Major content corrections

**Verification**:
- Module table matches actual directory contents
- No references to non-existent files
- Sorry count accurate per Metalogic.lean

---

### Phase 3: Update Bundle/README.md [NOT STARTED]

**Goal**: Add missing ModalSaturation.lean and verify sorry counts.

**Tasks**:
- [ ] Verify actual Bundle/ directory contents
- [ ] Add ModalSaturation.lean to architecture listing
- [ ] Verify sorry counts match current state
- [ ] Check and update research report links
- [ ] Update "Last updated" timestamp

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/README.md` - Add missing file, update sorry counts

**Verification**:
- ModalSaturation.lean listed in architecture section
- All files in directory documented
- Sorry counts accurate

---

### Phase 4: Update Main Metalogic/README.md [NOT STARTED]

**Goal**: Fix architecture section, subdirectory table, and sorry count in main entry point README.

**Tasks**:
- [ ] Fix architecture diagram to match actual directory structure
- [ ] Remove stale Boneyard/ references (not at this level)
- [ ] Remove Completeness/ subdirectory reference (only Completeness.lean at top level)
- [ ] Add Decidability/ to subdirectory summaries with link to new README
- [ ] Update sorry count to 4 (matching Metalogic.lean docstring)
- [ ] Update subdirectory status table with accurate information
- [ ] Update "Last updated" timestamp

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` - Architecture corrections, subdirectory table updates

**Verification**:
- Architecture diagram matches actual directory structure
- All subdirectories with READMEs have links
- Sorry count matches Metalogic.lean docstring (4)

---

### Phase 5: Standardize Cross-Links and Minor Updates [NOT STARTED]

**Goal**: Fix cross-links in Core/README.md and Algebraic/README.md, verify all links work.

**Tasks**:
- [ ] Update Core/README.md: fix ../Representation/README.md reference (archived)
- [ ] Update Algebraic/README.md: fix ../Representation/README.md reference (archived)
- [ ] Update timestamps in Core/README.md and Algebraic/README.md
- [ ] Verify all cross-links resolve correctly across all updated READMEs
- [ ] Run 100-character line limit check on all modified files
- [ ] Verify formal symbols are backticked per DOC_QUALITY_CHECKLIST.md

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/README.md` - Cross-link fix, timestamp
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - Cross-link fix, timestamp

**Verification**:
- All ../Representation/README.md references updated for archived status
- All cross-links valid
- 100-character line limit compliance
- ATX-style headings used throughout

---

### Phase 6: Final Verification [NOT STARTED]

**Goal**: Comprehensive verification of all changes against both standards documents.

**Tasks**:
- [ ] Run DIRECTORY_README_STANDARD.md review checklist on all modified READMEs
- [ ] Run DOC_QUALITY_CHECKLIST.md formatting checks (line limit, backticks, ATX headings)
- [ ] Verify cross-reference validity across all files
- [ ] Verify sorry count consistency across all READMEs
- [ ] Confirm Template D compliance (40-70 lines for lightweight READMEs)
- [ ] Test all links by visual inspection

**Timing**: 25 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/README.md`
- `Theories/Bimodal/Metalogic/Decidability/README.md` (new)
- `Theories/Bimodal/Metalogic/Core/README.md`
- `Theories/Bimodal/Metalogic/Bundle/README.md`
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Verification**:
- All READMEs pass DIRECTORY_README_STANDARD.md review checklist
- All READMEs pass DOC_QUALITY_CHECKLIST.md formatting checks
- Documentation is publication-ready

## Testing & Validation

- [ ] Decidability/README.md exists and documents all 8 files
- [ ] FMP/README.md accurately reflects 4-file directory (no phantom files)
- [ ] Bundle/README.md includes ModalSaturation.lean
- [ ] Main Metalogic/README.md has correct architecture diagram
- [ ] All sorry counts consistent (4 per Metalogic.lean docstring)
- [ ] All cross-links resolve to existing files
- [ ] All READMEs have current "Last updated" timestamps
- [ ] 100-character line limit compliance verified
- [ ] No Setext-style headings (ATX-style only)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/README.md` - New README (created)
- `Theories/Bimodal/Metalogic/README.md` - Main entry point (updated)
- `Theories/Bimodal/Metalogic/Core/README.md` - Cross-links (updated)
- `Theories/Bimodal/Metalogic/Bundle/README.md` - File listing (updated)
- `Theories/Bimodal/Metalogic/FMP/README.md` - Content correction (updated)
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - Cross-links (updated)
- `specs/830_standardize_metalogic_documentation/summaries/implementation-summary-20260203.md` - Summary (created on completion)

## Rollback/Contingency

All changes are to markdown documentation files only. Rollback via git:
```bash
git checkout HEAD -- Theories/Bimodal/Metalogic/
```

If specific README changes cause issues, individual files can be reverted independently.
