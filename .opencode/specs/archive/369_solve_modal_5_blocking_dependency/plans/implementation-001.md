# Implementation Plan: Task #369

**Task**: Solve the blocking dependency in the Modal 5 theorem
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

The "Modal 5 blocking dependency" is caused by `diamond_mono_imp` and `diamond_mono_conditional` theorems in ModalS5.lean that contain `sorry` because they are semantically INVALID in modal logic. The solution is to remove these invalid theorems and update the documentation, since they are unused and the valid alternative `k_dist_diamond` is already proven.

## Phases

### Phase 1: Remove Invalid Theorems from ModalS5.lean

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove `diamond_mono_imp` definition (lines 91-94)
2. Remove `diamond_mono_conditional` definition (lines 101-104)
3. Preserve the educational docstring as a comment block
4. Verify build succeeds without sorry warnings

**Files to modify**:
- `Bimodal/Theorems/ModalS5.lean` - Remove definitions, keep documentation

**Steps**:
1. Read the current ModalS5.lean file to understand exact line numbers
2. Replace the `diamond_mono_imp` definition with a comment block preserving the counter-model documentation
3. Remove `diamond_mono_conditional` definition entirely
4. Run `lake build Bimodal.Theorems.ModalS5` to verify no errors
5. Check `lean_diagnostic_messages` to confirm sorry warning is gone

**Verification**:
- `lake build Bimodal.Theorems.ModalS5` succeeds
- No sorry warnings in ModalS5.lean
- Counter-model documentation preserved as comment

---

### Phase 2: Update SORRY_REGISTRY Documentation

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update SORRY_REGISTRY.md to reflect removal
2. Document that the theorems were removed (not fixed)
3. Add note about `k_dist_diamond` as the valid alternative

**Files to modify**:
- `docs/project-info/SORRY_REGISTRY.md` - Update lines 107-127

**Steps**:
1. Read current SORRY_REGISTRY.md section for ModalS5.lean
2. Change status from "DOCUMENTED AS INVALID" to "REMOVED (2026-01-11)"
3. Add resolution note explaining why theorems were removed
4. Verify the `k_dist_diamond` alternative is mentioned

**Verification**:
- SORRY_REGISTRY accurately reflects current state
- Alternative solution is documented

---

### Phase 3: Verify Build and Update Sorry Count

**Estimated effort**: 5 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Run full Bimodal build to ensure no regressions
2. Update sorry count in TODO.md frontmatter if needed
3. Verify no downstream breakage

**Files to modify**:
- `.claude/specs/TODO.md` - Update sorry_count in frontmatter (if count changed)

**Steps**:
1. Run `lake build Bimodal` to check for any regressions
2. Count remaining sorries with grep to verify reduction
3. Update TODO.md frontmatter if sorry count changed
4. Git commit all changes

**Verification**:
- Full Bimodal build succeeds
- Sorry count is accurate
- No downstream modules affected

## Dependencies

- None - this is a cleanup task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Downstream code uses invalid theorems | High | Very Low | Research confirmed nothing uses these |
| Build breaks after removal | Medium | Low | Verify build in Phase 1 before proceeding |
| Documentation becomes unclear | Low | Low | Preserve counter-model as comment |

## Success Criteria

- [ ] `diamond_mono_imp` and `diamond_mono_conditional` removed from ModalS5.lean
- [ ] No sorry warnings in ModalS5.lean
- [ ] SORRY_REGISTRY updated to reflect changes
- [ ] Counter-model documentation preserved (as comment)
- [ ] `lake build Bimodal` succeeds without regressions
- [ ] Git commit with all changes

## Rollback Plan

If removal causes unexpected issues:
1. Restore ModalS5.lean from git: `git checkout HEAD -- Bimodal/Theorems/ModalS5.lean`
2. Restore SORRY_REGISTRY: `git checkout HEAD -- docs/project-info/SORRY_REGISTRY.md`
3. Re-evaluate whether theorems need different treatment
