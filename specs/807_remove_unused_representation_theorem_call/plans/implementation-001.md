# Implementation Plan: Task #807

- **Task**: 807 - Remove unused representation_theorem call from InfinitaryStrongCompleteness.lean
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/807_remove_unused_representation_theorem_call/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

Remove dead code from `InfinitaryStrongCompleteness.lean` consisting of an unused `representation_theorem` call and its supporting hypothesis. The research confirmed that lines 233-261 represent an abandoned proof approach that was replaced by a stronger alternative using `set_lindenbaum`.

### Research Integration

Key findings from research-001.md:
- The `representation_theorem` call at line 248 is confirmed dead code
- The `h_neg_cons` hypothesis (lines 239-244) is only used for this call
- Comments (lines 233-235, 250-261) document the abandoned approach
- The variables `family`, `t`, `h_neg_in`, `h_neg_true` from line 247-248 are never referenced
- Risk level is "Very Low" - pure dead code with no external dependencies

## Goals & Non-Goals

**Goals**:
- Remove dead code (lines 233-261) cleanly
- Maintain proof correctness and build success
- Improve code maintainability by removing abandoned approach

**Non-Goals**:
- Refactoring the working proof
- Changing the proof strategy
- Removing related imports (still needed for other functions)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental removal of used code | H | L | Research confirmed all removed lines are unused; verify build succeeds |
| Line number drift from original research | M | L | Re-verify line contents before removal |

## Implementation Phases

### Phase 1: Remove Dead Code [NOT STARTED]

**Goal**: Remove the unused `representation_theorem` call and associated dead code from InfinitaryStrongCompleteness.lean

**Tasks**:
- [ ] Read current file to verify line contents match research expectations
- [ ] Remove lines 233-261 (comments about initial approach, h_neg_cons definition, representation_theorem call, and failure explanation comments)
- [ ] Verify the proof structure remains coherent (line 262+ should continue cleanly)
- [ ] Run `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` to verify success

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - Remove lines 233-261 (dead code)

**Verification**:
- Build command succeeds without errors
- No new warnings introduced
- Proof still completes successfully

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` completes without errors
- [ ] No new sorry placeholders introduced
- [ ] No references to removed code elsewhere in codebase

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` with dead code removed
- Implementation summary documenting the cleanup

## Rollback/Contingency

If build fails after removal:
1. Restore the removed lines using `git checkout -- Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
2. Re-examine which specific lines caused the issue
3. Apply more conservative removal if needed
