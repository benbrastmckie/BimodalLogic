# Implementation Plan: Task #780

- **Task**: 780 - improve_bimodal_metalogic_documentation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/780_improve_bimodal_metalogic_documentation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The Bimodal/Metalogic/ directory has significant documentation inaccuracies: the Compactness/ subdirectory contains only a README with no Lean files, the Representation/ README describes 7 modules when only 2 exist, and the main README contains outdated dependency diagrams and historical notes about migrations. This plan first audits and cleans up the Lean file structure (removing empty directories, verifying sorry status), then systematically updates all 11 README files to reflect the accurate current state.

### Research Integration

Research report research-001.md identified:
- 11 README files needing review
- Compactness/ directory empty of Lean files (critical)
- Representation/ README lists 5 non-existent files (critical)
- Historical/migration notes in 7 files to remove
- 73 total sorry occurrences across 18 files (most in UnderDevelopment/)

## Goals & Non-Goals

**Goals**:
- Remove or archive empty directories that mislead users
- Update all README files to accurately reflect current file structure
- Remove historical notes about migrations and task references
- Ensure dependency diagrams are accurate
- Clarify sorry-free vs sorry-containing components

**Non-Goals**:
- Changing Lean code implementations
- Moving files between directories (already done in prior tasks)
- Fixing sorries (separate task scope)
- Creating new documentation beyond corrections

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing information users depend on | Medium | Low | Preserve key context in UnderDevelopment README |
| Introducing new inaccuracies | Medium | Medium | Verify each README against actual `ls` output |
| Breaking documentation links | Low | Low | Search for internal references before changes |
| Misrepresenting sorry status | Medium | Medium | Use grep output to verify sorry counts per file |

## Implementation Phases

### Phase 1: Audit and Clean Directory Structure [NOT STARTED]

**Goal**: Remove empty Compactness/ directory and verify file structure matches expectations

**Tasks**:
- [ ] Verify Compactness/ contains only README.md (no Lean files)
- [ ] Delete Compactness/ directory entirely (Compactness.lean is in UnderDevelopment/RepresentationTheorem/)
- [ ] Update Metalogic.lean if it imports from Compactness/ (verify imports)
- [ ] Verify Representation/ only has IndexedMCSFamily.lean and CanonicalWorld.lean
- [ ] Document final directory structure for reference in later phases

**Timing**: 30 minutes

**Files to modify**:
- Delete: `Theories/Bimodal/Metalogic/Compactness/` (entire directory)

**Verification**:
- `ls Theories/Bimodal/Metalogic/` shows no Compactness/ subdirectory
- `grep -r "Compactness" Theories/Bimodal/Metalogic/*.lean` returns no import errors
- Project builds successfully (`lake build`)

---

### Phase 2: Update Main Metalogic/README.md [NOT STARTED]

**Goal**: Fix architecture diagram, dependency flowchart, and remove historical sections

**Tasks**:
- [ ] Remove Compactness from architecture diagram (lines 75-76)
- [ ] Update subdirectory status table: remove Compactness row, update Representation status
- [ ] Update dependency flowchart to remove Compactness node and edges
- [ ] Delete "Migration Notes (2026-01-29)" section entirely (lines 194-202)
- [ ] Delete "Deprecation Notes (Task 769, 2026-01-30)" section entirely (lines 204-209)
- [ ] Update References to remove task-specific citations (lines 214-215)
- [ ] Remove "(NEW - migrated 2026-01-29)" annotation from Soundness line
- [ ] Update "Known Architectural Limitations" section to remove Representation/ file references (those files moved)
- [ ] Update last updated date

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`

**Verification**:
- README contains no references to Compactness/ as a current directory
- README contains no date-specific migration notes
- README contains no task number references (like "Task 769")
- Architecture diagram matches actual directory structure

---

### Phase 3: Fix Critical READMEs (Representation, Completeness) [NOT STARTED]

**Goal**: Rewrite READMEs for directories whose contents have changed significantly

**Tasks**:
- [ ] **Representation/README.md**: Remove 5 non-existent modules from table (CoherentConstruction, CanonicalHistory, TaskRelation, TruthLemma, UniversalCanonicalModel)
- [ ] **Representation/README.md**: Update dependency flowchart to show only IndexedMCSFamily and CanonicalWorld
- [ ] **Representation/README.md**: Add note pointing to UnderDevelopment/RepresentationTheorem/ for the complete implementation
- [ ] **Representation/README.md**: Simplify "Main Result" section to describe what these 2 files provide
- [ ] **Representation/README.md**: Remove "Known Sorries" section (sorries are in files that no longer exist here)
- [ ] **Completeness/README.md**: Remove InfinitaryStrongCompleteness.lean from module table (file is in UnderDevelopment)
- [ ] **Completeness/README.md**: Update dependency flowchart to remove InfinitaryStrongCompleteness
- [ ] **Completeness/README.md**: Update "Key Theorems" section to not reference infinitary version
- [ ] **Completeness/README.md**: Remove "migrated from Boneyard" reference in line 115

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/README.md`
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Verification**:
- Representation README module table has exactly 2 entries
- Completeness README module table has exactly 3 entries (Completeness, WeakCompleteness, FiniteStrongCompleteness)
- No references to files that don't exist in each directory

---

### Phase 4: Clean Minor READMEs [NOT STARTED]

**Goal**: Remove historical notes and simplify status lines in remaining READMEs

**Tasks**:
- [ ] **Core/README.md**: Remove "As of 2026-01-29..." paragraph (around line 120-121)
- [ ] **Core/README.md**: Update last updated date
- [ ] **Soundness/README.md**: Simplify status line (remove Boneyard reference if any)
- [ ] **Soundness/README.md**: Update last updated date
- [ ] **FMP/README.md**: Remove or consolidate "Archived Code" section referencing Boneyard (lines 40-50)
- [ ] **FMP/README.md**: Update last updated date
- [ ] **Algebraic/README.md**: Update last updated date only (content is accurate)
- [ ] Remove "Self-Contained (No Boneyard Dependencies)" status line pattern - simplify to just "Self-Contained" or remove entirely

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/README.md`
- `Theories/Bimodal/Metalogic/Soundness/README.md`
- `Theories/Bimodal/Metalogic/FMP/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Verification**:
- No README contains "2026-01-29" migration date references
- No README contains "Boneyard" references except as brief historical context
- All README "Last updated" dates are current

---

### Phase 5: Update UnderDevelopment READMEs [NOT STARTED]

**Goal**: Ensure UnderDevelopment documentation clearly explains what content was moved here

**Tasks**:
- [ ] **UnderDevelopment/README.md**: Verify it explains the RepresentationTheorem and Decidability subdirectories
- [ ] **UnderDevelopment/README.md**: Add note that Compactness.lean and InfinitaryStrongCompleteness.lean live here
- [ ] **UnderDevelopment/RepresentationTheorem/README.md**: Verify module list is accurate
- [ ] **UnderDevelopment/RepresentationTheorem/README.md**: Clarify relationship to Representation/ (these are the files that were moved)
- [ ] **UnderDevelopment/Decidability/README.md**: Verify module list is accurate (research says this is already good)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/README.md`
- `Theories/Bimodal/Metalogic/UnderDevelopment/RepresentationTheorem/README.md`
- `Theories/Bimodal/Metalogic/UnderDevelopment/Decidability/README.md` (if needed)

**Verification**:
- UnderDevelopment README mentions Compactness.lean location
- UnderDevelopment README mentions InfinitaryStrongCompleteness.lean location
- RepresentationTheorem README module table matches actual file count (10 files)

---

### Phase 6: Final Verification and Build Test [NOT STARTED]

**Goal**: Verify all changes are consistent and project still builds

**Tasks**:
- [ ] Run `lake build` to ensure no import breakage
- [ ] Verify no README references files that don't exist
- [ ] Verify no README is missing files that do exist in its directory
- [ ] Search for broken cross-references between READMEs
- [ ] Verify sorry status claims in READMEs match actual grep output
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)
- Create: `specs/780_improve_bimodal_metalogic_documentation/summaries/implementation-summary-{DATE}.md`

**Verification**:
- `lake build` succeeds
- All README module tables match actual directory contents
- Cross-references between READMEs are valid

---

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] Each README in Metalogic/ has been reviewed against its directory's actual contents
- [ ] No historical dates (2026-01-29, etc.) remain in documentation
- [ ] No task number references remain in documentation
- [ ] Compactness/ directory no longer exists
- [ ] Dependency diagrams in main README match actual module structure

## Artifacts & Outputs

- Removed: `Theories/Bimodal/Metalogic/Compactness/` directory
- Modified: 11 README.md files in Metalogic/
- Created: `specs/780_improve_bimodal_metalogic_documentation/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

All changes are to documentation files (README.md). If any change introduces problems:
1. Use `git checkout -- Theories/Bimodal/Metalogic/` to restore all changes
2. The only structural change is deleting Compactness/ which contains no code
3. If Compactness/ deletion causes issues, restore via `git checkout -- Theories/Bimodal/Metalogic/Compactness/`

Since this task only modifies documentation and removes an empty directory, rollback is straightforward with git.
