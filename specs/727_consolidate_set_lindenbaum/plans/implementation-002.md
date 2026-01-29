# Implementation Plan: Task #727 (v2)

- **Task**: 727 - Consolidate set_lindenbaum duplicates
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: Task 726 (completed)
- **Research Inputs**: specs/727_consolidate_set_lindenbaum/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Revision Notes

**v2 changes from v1**:
- Removed: External documentation updates outside Boneyard
- Clarified: Deprecation notices ONLY in Boneyard files
- Added: Verification that active code has clean documentation (no historical references)
- Simplified: Fewer phases, focused scope

**User requirement**: Add deprecation notices in Boneyard only. No extra comments or documentation outside Boneyard. Active code should have clear documentation about current implementation with no mention of past attempts.

## Overview

Add deprecation notices to duplicate `set_lindenbaum` definitions within Boneyard files only. The active codebase (`Metalogic/`) already uses the canonical source and should have clean, forward-looking documentation without references to Boneyard alternatives.

### Key Principle

- **Boneyard**: Add deprecation notices pointing to canonical source
- **Active code**: Keep clean - no mentions of Boneyard, historical attempts, or "deprecated alternatives"

## Goals & Non-Goals

**Goals**:
- Add deprecation notices to both duplicate `set_lindenbaum` definitions in Boneyard
- Create/update Boneyard README files documenting deprecation
- Verify active code (`Metalogic/`) has no references to Boneyard

**Non-Goals**:
- Adding any comments to active codebase files
- Creating documentation outside Boneyard about "alternatives" or "deprecated versions"
- Modifying active code documentation in any way
- Deleting duplicate code from Boneyard

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incomplete deprecation notice | M | L | Follow consistent template for both files |
| Accidentally adding comments to active code | M | L | Verify modified files are only in Boneyard/ |

## Implementation Phases

### Phase 1: Verify Active Code Isolation [COMPLETED]

**Goal**: Confirm active code has no Boneyard imports and no historical references

**Tasks**:
- [ ] Verify Task 726 completed (no Boneyard imports in active Representation/ files)
- [ ] Check that `Metalogic/Core/MaximalConsistent.lean` has clean documentation (no "see Boneyard" references)
- [ ] Grep active Metalogic/ for any references to "Boneyard" or "deprecated" alternatives

**Timing**: 10 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Representation/*.lean` - Check no Boneyard imports
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Check clean docs

**Verification**:
- No active file in `Metalogic/` imports from `Boneyard/`
- No comments in active files mention "Boneyard" alternatives

**Expected result**: Already clean after Task 726. If any Boneyard references found in active code, remove them.

---

### Phase 2: Add Deprecation Notices to Boneyard Files [NOT STARTED]

**Goal**: Mark duplicate `set_lindenbaum` definitions as deprecated

**Tasks**:
- [ ] Add deprecation notice to `Boneyard/Metalogic/Completeness.lean:360`
- [ ] Add deprecation notice to `Boneyard/Metalogic/Representation/CanonicalModel.lean:139`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean`
- `Theories/Bimodal/Boneyard/Metalogic/Representation/CanonicalModel.lean`

**Deprecation Template**:
```lean
/-!
## DEPRECATED

This `set_lindenbaum` is superseded by the canonical version at:
- `Bimodal.Metalogic.Core.set_lindenbaum` (re-export)
- `Bimodal.Metalogic_v2.Core.set_lindenbaum` (original)

This file is preserved for historical reference only.
-/
```

**Verification**:
- Both files have deprecation notices above `set_lindenbaum`
- Files still compile

---

### Phase 3: Update Boneyard README Files [NOT STARTED]

**Goal**: Document deprecation status in Boneyard README files

**Tasks**:
- [ ] Create or update `Boneyard/Metalogic/README.md` with deprecation info
- [ ] Create or update `Boneyard/Metalogic/Representation/README.md` with deprecation info

**Timing**: 20 minutes

**Files to create/modify**:
- `Theories/Bimodal/Boneyard/Metalogic/README.md`
- `Theories/Bimodal/Boneyard/Metalogic/Representation/README.md`

**README Content**:
```markdown
# Boneyard/Metalogic

Historical code preserved for reference. Active development uses `Metalogic/`.

## Deprecated Definitions

| Definition | Location | Canonical Source |
|------------|----------|------------------|
| `set_lindenbaum` | Completeness.lean:360 | `Metalogic.Core.MaximalConsistent` |
| MCS lemmas | various | `Metalogic.Core.MCSProperties` |

## History

- Task #726: MCS lemmas moved to Core
- Task #727: Deprecation notices added
```

**Verification**:
- README files exist in both Boneyard directories
- Documentation clearly indicates these are deprecated

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify all changes are correct and confined to Boneyard

**Tasks**:
- [ ] Run `lake build` to ensure no compilation errors
- [ ] Verify ONLY Boneyard files were modified (git status)
- [ ] Confirm no comments about "Boneyard" or "deprecated alternatives" exist in Metalogic/
- [ ] Create implementation summary

**Timing**: 10 minutes

**Verification**:
- `lake build` succeeds
- `git status` shows only Boneyard files modified
- `grep -r "Boneyard" Theories/Bimodal/Metalogic/` returns no results (except import paths which don't exist post-726)

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] Only Boneyard files modified
- [ ] Active code clean of Boneyard references
- [ ] Deprecation notices visible in both duplicate files
- [ ] Boneyard README files document canonical sources

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (created in Phase 4)
- Modified: `Boneyard/Metalogic/Completeness.lean` - deprecation notice
- Modified: `Boneyard/Metalogic/Representation/CanonicalModel.lean` - deprecation notice
- Created/Modified: `Boneyard/Metalogic/README.md`
- Created/Modified: `Boneyard/Metalogic/Representation/README.md`

## Rollback/Contingency

All changes are Boneyard-only:
1. Deprecation notices are comment-only - can be removed without affecting functionality
2. README files are documentation-only
3. Active code is NOT modified
4. Git revert restores all files to pre-implementation state
