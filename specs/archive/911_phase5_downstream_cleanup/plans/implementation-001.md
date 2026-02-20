# Implementation Plan: Task #911

- **Task**: 911 - Phase 5 Downstream Cleanup
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: Task 910 (Phase 4 - Canonical Model Reconstruction)
- **Research Inputs**: specs/911_phase5_downstream_cleanup/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Verify full compilation after Omega parameter changes (tasks 907-910) and perform optional cosmetic cleanup of unused simp arguments. Research confirms the build already succeeds with zero compilation errors. The primary work is verification and optional linter warning cleanup in SoundnessLemmas.lean and Soundness.lean (136 combined warnings for unused `Set.mem_univ` and `true_implies` simp arguments).

### Research Integration

Key findings from research-001.md:
- `lake build` completes successfully with 1000 jobs, zero errors
- FMP/SemanticCanonicalModel.lean compiles without changes (uses own `semantic_truth_at_v2` definition)
- Two expected Omega-mismatch sorries exist in Representation.lean (from task 910, out of scope)
- 136 cosmetic linter warnings in SoundnessLemmas.lean (64) and Soundness.lean (72) for unused simp args
- Demo.lean has pre-existing Boneyard import error (unrelated to Omega changes)

## Goals & Non-Goals

**Goals**:
- Verify `lake build` succeeds with full compilation
- Confirm no new sorries introduced by Omega changes
- Optionally clean up unused simp argument warnings in soundness files
- Document build status and any remaining issues

**Non-Goals**:
- Resolving the two Omega-mismatch sorries in Representation.lean (follow-up task)
- Fixing Demo.lean Boneyard import error (pre-existing, unrelated)
- Modifying FMP/SemanticCanonicalModel.lean (already compiles correctly)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build state changed since research | Low | Low | Re-run full lake build to verify |
| Simp cleanup breaks proofs | Medium | Low | Test each file after cleanup; revert if needed |
| Hidden compilation issues | Low | Very Low | Research verified all key files compile |

## Implementation Phases

### Phase 1: Build Verification [COMPLETED]

- **Dependencies**: None
- **Goal**: Confirm full compilation succeeds after Omega changes

**Tasks**:
- [ ] Run `lake build` and capture output
- [ ] Verify 0 build errors
- [ ] Count current sorry instances in affected files
- [ ] Confirm the two Omega-mismatch sorries in Representation.lean are the only sorries in scope
- [ ] Verify FMP/SemanticCanonicalModel.lean compiles without changes

**Timing**: 15 minutes

**Files to modify**: None (verification only)

**Verification**:
- `lake build` completes successfully
- Build output shows no errors for Theories/Bimodal/Metalogic/ files
- Sorry count matches expected (2 in Representation.lean for Omega-mismatch)

**Progress:**

**Session: 2026-02-19, sess_1771544522_231840**
- Completed: Full build verification (1000 jobs, 0 errors)
- Completed: Sorry count verification (2 in Representation.lean, as expected)
- Completed: FMP/SemanticCanonicalModel.lean confirmed sorry-free

---

### Phase 2: Optional Linter Cleanup [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Remove unused simp arguments to eliminate cosmetic warnings

**Tasks**:
- [ ] Identify lines with unused `Set.mem_univ, true_implies` warnings in SoundnessLemmas.lean
- [ ] For each warning, determine if removal is safe (Box case needs both, others may not)
- [ ] Remove unused simp arguments from non-Box cases
- [ ] Verify SoundnessLemmas.lean compiles after changes
- [ ] Repeat for Soundness.lean
- [ ] Verify both files compile with reduced warnings

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove unused simp args (64 warnings)
- `Theories/Bimodal/Metalogic/Soundness.lean` - Remove unused simp args (72 warnings)

**Verification**:
- Both files compile successfully
- Warning count reduced significantly (target: 0 unused simp arg warnings)
- No proofs broken by cleanup

**Progress:**

**Session: 2026-02-19, sess_1771544522_231840**
- Removed: unused `Set.mem_univ, true_implies` simp args from 16 lines in SoundnessLemmas.lean
- Removed: unused `Set.mem_univ, true_implies` simp args from 18 lines in Soundness.lean (including 2 fully-unused simp calls)
- Completed: 0 unused simp arg warnings in both files (was 64 + 72 = 136)

---

### Phase 3: Final Validation [COMPLETED]

- **Dependencies**: Phase 2
- **Goal**: Complete final build verification and documentation

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify no new sorries introduced
- [ ] Document final build state in completion summary
- [ ] Note the two expected Omega-mismatch sorries for follow-up task

**Timing**: 15 minutes

**Files to modify**: None (verification only)

**Verification**:
- `lake build` succeeds
- No new sorries (only 2 expected in Representation.lean)
- All Theories/Bimodal/Metalogic/ files compile cleanly

**Progress:**

**Session: 2026-02-19, sess_1771544522_231840**
- Completed: Full `lake build` succeeds (1000 jobs, 0 errors)
- Completed: No new sorries introduced (2 in Representation.lean, pre-existing from task 910)
- Completed: All Metalogic files compile cleanly

---

## Testing & Validation

- [ ] `lake build` completes successfully with zero errors
- [ ] FMP/SemanticCanonicalModel.lean compiles without modification
- [ ] SoundnessLemmas.lean compiles (optionally with reduced warnings)
- [ ] Soundness.lean compiles (optionally with reduced warnings)
- [ ] No new sorries introduced by Omega changes
- [ ] Only 2 sorries remain in Representation.lean (Omega-mismatch, expected from task 910)

## Artifacts & Outputs

- Build verification log
- List of cleaned simp calls (if Phase 2 executed)
- Implementation summary documenting final state

## Rollback/Contingency

If simp cleanup breaks proofs:
1. Revert changes with `git checkout -- <file>`
2. Mark Phase 2 as skipped (cosmetic, non-blocking)
3. Complete task with Phase 1 and 3 only

The task can be completed successfully with only Phase 1 (verification) since research confirms the build already works.
