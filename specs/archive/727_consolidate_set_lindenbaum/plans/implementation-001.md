# Implementation Plan: Task #727

- **Task**: 727 - Consolidate set_lindenbaum duplicates
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: Task 726 (completed)
- **Research Inputs**: specs/727_consolidate_set_lindenbaum/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Add deprecation notices to duplicate `set_lindenbaum` definitions in Boneyard/Metalogic/ files and document the canonical source. With Task 726 complete, the duplicates are now fully isolated in Boneyard with no active code depending on them. The approach is documentation-focused: mark duplicates as deprecated without removing them, preserving Boneyard integrity as a historical reference.

### Research Integration

Key findings from research-001.md integrated into this plan:
- Three `set_lindenbaum` locations identified (1 canonical, 2 duplicates)
- Canonical source: `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean:290`, re-exported via `Metalogic/Core/MaximalConsistent.lean`
- Duplicates at: `Boneyard/Metalogic/Completeness.lean:360` and `Boneyard/Metalogic/Representation/CanonicalModel.lean:139`
- After Task 726: no active code imports from Boneyard/Metalogic/Completeness.lean for MCS lemmas

## Goals & Non-Goals

**Goals**:
- Add deprecation notices to both duplicate `set_lindenbaum` definitions
- Document the canonical source location
- Create/update README files in affected Boneyard directories
- Prevent future confusion about which source to use

**Non-Goals**:
- Deleting duplicate code from Boneyard (preserves historical artifact)
- Refactoring Boneyard internals to use canonical source (unnecessary work)
- Modifying active codebase files (already using canonical source)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incomplete deprecation notice | M | L | Follow consistent template for both files |
| Missing README documentation | L | L | Create both READMEs in same phase |
| Future confusion about canonical source | M | M | Clear deprecation comments with cross-references |

## Implementation Phases

### Phase 1: Verify Task 726 Completion and Isolation [NOT STARTED]

**Goal**: Confirm that duplicates are fully isolated after Task 726

**Tasks**:
- [ ] Verify Task 726 is marked completed in state.json
- [ ] Check that no active Representation files import `Boneyard/Metalogic/Completeness.lean`
- [ ] Confirm canonical `set_lindenbaum` is accessible via `Metalogic/Core/MaximalConsistent.lean`

**Timing**: 15 minutes

**Files to examine**:
- `specs/state.json` - Verify Task 726 completion
- `Theories/Bimodal/Metalogic/Representation/*.lean` - Check imports
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Confirm re-export

**Verification**:
- Task 726 status is "completed"
- No active file imports `Boneyard/Metalogic/Completeness.lean`

---

### Phase 2: Add Deprecation Notice to Completeness.lean [NOT STARTED]

**Goal**: Mark `set_lindenbaum` in Completeness.lean as deprecated

**Tasks**:
- [ ] Read `Boneyard/Metalogic/Completeness.lean` to find `set_lindenbaum` at line 360
- [ ] Add deprecation comment block above the theorem
- [ ] Include canonical source reference and migration guidance

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean` - Add deprecation notice

**Deprecation Template**:
```lean
/-!
## DEPRECATED: set_lindenbaum

This `set_lindenbaum` theorem is a historical duplicate.

**Canonical source**: `Bimodal.Metalogic_v2.Core.set_lindenbaum`
**Re-exported via**: `Bimodal.Metalogic.Core.MaximalConsistent.set_lindenbaum`

This file remains for historical reference only. Active code should import from
`Metalogic/Core/MaximalConsistent.lean` instead.

See Task #727 for consolidation context.
-/
```

**Verification**:
- Deprecation comment is visible above `set_lindenbaum` definition
- File still compiles (no syntax errors in comment)

---

### Phase 3: Add Deprecation Notice to CanonicalModel.lean [NOT STARTED]

**Goal**: Mark `set_lindenbaum` in CanonicalModel.lean as deprecated

**Tasks**:
- [ ] Read `Boneyard/Metalogic/Representation/CanonicalModel.lean` to find `set_lindenbaum` at line 139
- [ ] Add deprecation comment block above the theorem
- [ ] Include canonical source reference and migration guidance

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Representation/CanonicalModel.lean` - Add deprecation notice

**Verification**:
- Deprecation comment is visible above `set_lindenbaum` definition
- File still compiles

---

### Phase 4: Update Boneyard README Files [NOT STARTED]

**Goal**: Document deprecation status and canonical sources in README files

**Tasks**:
- [ ] Check if `Boneyard/Metalogic/README.md` exists
- [ ] Create or update README with deprecation status and canonical source references
- [ ] Check if `Boneyard/Metalogic/Representation/README.md` exists
- [ ] Create or update README with deprecation status

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/README.md` - Create or update
- `Theories/Bimodal/Boneyard/Metalogic/Representation/README.md` - Create or update

**README Content Template**:
```markdown
# Boneyard/Metalogic

This directory contains historical code that has been superseded by the
reorganized `Metalogic/` module structure.

## Status: DEPRECATED

These files are preserved for historical reference. Active development should
use the canonical sources in `Metalogic/`.

## Key Deprecations

### `set_lindenbaum`
- **Deprecated location**: `Completeness.lean:360`
- **Canonical source**: `Metalogic/Core/MaximalConsistent.lean`
- **Original source**: `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean`

## Migration History

- Task #726: Moved essential MCS lemmas to `Metalogic/Core/`
- Task #727: Added deprecation notices, documented canonical sources
```

**Verification**:
- README files exist in both directories
- Deprecation status is clearly documented

---

### Phase 5: Final Verification and Summary [NOT STARTED]

**Goal**: Verify all changes and create implementation summary

**Tasks**:
- [ ] Run `lake build` to ensure no compilation errors introduced
- [ ] Verify all deprecation notices are in place
- [ ] Verify all README files are created/updated
- [ ] Create implementation summary

**Timing**: 20 minutes

**Files to create**:
- `specs/727_consolidate_set_lindenbaum/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- `lake build` succeeds
- All 4 files have been modified/created

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] Deprecation notices are visible in both duplicate files
- [ ] README files document canonical sources
- [ ] No active code imports from deprecated files (verified in Phase 1)

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (created in Phase 5)
- Modified: `Boneyard/Metalogic/Completeness.lean`
- Modified: `Boneyard/Metalogic/Representation/CanonicalModel.lean`
- Created/Modified: `Boneyard/Metalogic/README.md`
- Created/Modified: `Boneyard/Metalogic/Representation/README.md`

## Rollback/Contingency

If issues arise:
1. Deprecation notices are comment-only changes - can be removed without affecting code
2. README files are documentation-only - can be deleted if incorrect
3. No functional code is modified - rollback risk is minimal
4. Git revert can restore all files to pre-implementation state
