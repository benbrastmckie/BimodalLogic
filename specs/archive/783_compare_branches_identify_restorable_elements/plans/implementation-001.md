# Implementation Plan: Task #783

- **Task**: 783 - compare_branches_identify_restorable_elements
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: Task 782 (revert completed)
- **Research Inputs**: specs/783_compare_branches_identify_restorable_elements/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan restores documentation improvements from the backup/pre-revert-782 branch and establishes the UnderDevelopment/ directory pattern with clear documentation. Per user instructions, only documentation is restored - no code files (FMP/SemanticCanonicalModel.lean, Soundness/ modularization, Examples, etc.) will be restored at this time.

### Research Integration

From research-001.md:
- 8 new README files identified in backup branch
- Typst chapter 04-metalogic.typ has extensive updates (~250 lines)
- UnderDevelopment/ pattern documented with import isolation rules

## Goals & Non-Goals

**Goals**:
- Cherry-pick documentation README files from backup branch
- Create Theories/Bimodal/Metalogic/UnderDevelopment/ directory with README.md explaining the pattern
- Cherry-pick typst chapter 04-metalogic.typ updates

**Non-Goals**:
- Restore any code files (FMP/SemanticCanonicalModel.lean, Soundness/, etc.)
- Restore Examples archived to Boneyard
- Restore Representation/ code to UnderDevelopment/
- Any code changes beyond documentation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cherry-pick conflicts | Medium | Low | Use `git checkout` to extract specific files rather than cherry-pick commits |
| Path mismatches | Low | Medium | Verify file paths exist on main before cherry-picking |
| Incomplete README extraction | Low | Low | Verify each README is created and non-empty |

## Implementation Phases

### Phase 1: Cherry-pick README files from backup [NOT STARTED]

**Goal**: Restore the 8 documentation README files from backup branch

**Tasks**:
- [ ] Extract Metalogic/Algebraic/README.md from backup
- [ ] Extract Metalogic/Completeness/README.md from backup
- [ ] Extract Metalogic/Core/README.md from backup
- [ ] Extract Metalogic/FMP/README.md from backup
- [ ] Extract Metalogic/Soundness/README.md from backup
- [ ] Extract UnderDevelopment/Decidability/README.md from backup (if directory exists)
- [ ] Extract UnderDevelopment/RepresentationTheorem/README.md from backup (if directory exists)
- [ ] Update main Metalogic/README.md with improved version from backup

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - create (147 lines)
- `Theories/Bimodal/Metalogic/Completeness/README.md` - create (89 lines)
- `Theories/Bimodal/Metalogic/Core/README.md` - create (156 lines)
- `Theories/Bimodal/Metalogic/FMP/README.md` - create (97 lines)
- `Theories/Bimodal/Metalogic/Soundness/README.md` - create (141 lines)
- `Theories/Bimodal/Metalogic/README.md` - update with improved version

**Verification**:
- All 6 README files exist in Metalogic/ subdirectories
- Main Metalogic/README.md has updated content
- No code files were modified

---

### Phase 2: Create UnderDevelopment/ directory with README [NOT STARTED]

**Goal**: Establish the UnderDevelopment/ directory pattern with clear documentation

**Tasks**:
- [ ] Create Theories/Bimodal/Metalogic/UnderDevelopment/ directory
- [ ] Create UnderDevelopment/README.md explaining the isolation pattern
- [ ] Document import isolation rules (can import from elsewhere, cannot be imported)
- [ ] Document root module commenting pattern for lake build isolation
- [ ] Note that this directory is for future use (content restoration deferred)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/UnderDevelopment/README.md` - create (~100 lines)

**Verification**:
- UnderDevelopment/ directory exists
- README.md clearly explains the isolation pattern
- No code files were created (just documentation)

---

### Phase 3: Cherry-pick typst chapter 04 updates [NOT STARTED]

**Goal**: Restore typst documentation updates for chapter 04-metalogic.typ

**Tasks**:
- [ ] Compare current docs/formal-methods/04-metalogic.typ with backup version
- [ ] Extract updated content from backup/pre-revert-782
- [ ] Verify typst compilation succeeds after update (if typst is available)

**Timing**: 45 minutes

**Files to modify**:
- `docs/formal-methods/04-metalogic.typ` - update (~250 lines changed)

**Verification**:
- Chapter 04 reflects documentation of contrapositive completeness path
- Updated theorem dependency diagrams included
- Sorry status table included if present in backup

---

## Testing & Validation

- [ ] Verify all README files exist and are non-empty
- [ ] Verify UnderDevelopment/README.md explains isolation pattern
- [ ] Verify no code files (.lean) were modified
- [ ] Verify lake build still succeeds (no new imports introduced)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)
- 6 README files in Metalogic/ subdirectories
- 1 README file in UnderDevelopment/
- Updated docs/formal-methods/04-metalogic.typ

## Rollback/Contingency

If documentation restoration causes issues:
1. Use `git checkout HEAD -- <file>` to restore individual files
2. Use `git reset --hard HEAD~1` to revert last commit (if needed)
3. All changes are documentation only, so rollback is straightforward
