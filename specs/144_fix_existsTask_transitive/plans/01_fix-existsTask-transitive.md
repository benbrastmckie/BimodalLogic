# Implementation Plan: Fix existsTask_transitive

- **Task**: 144 - fix_existsTask_transitive
- **Status**: [NOT STARTED]
- **Effort**: 0.25 hours
- **Dependencies**: None (fix already applied in task 139 phase 2, commit a60bc6358)
- **Research Inputs**: reports/01_research.md
- **Artifacts**: plans/01_fix-existsTask-transitive.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The one-line sorry in `existsTask_transitive` (CanonicalFrame.lean:259) has already been fixed in commit `a60bc6358` as part of task 139 phase 2. The fix replaced `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`, which is a direct axiom application matching the identical pattern at MCSProperties.lean:248 and :274. This plan covers verification that the fix is complete: confirming no sorry remains, that `#print axioms bx_completeness` no longer references `existsTask_transitive` sorry axioms, and that `lake build` passes cleanly.

### Research Integration

Research report (`reports/01_research.md`) confirmed:
- The sorry filled `h_T4`, a proof of the temporal 4 axiom `G phi -> G(G phi)` as a DerivationTree
- The fix `DerivationTree.axiom [] _ (Axiom.temp_4 phi)` is 100% confidence -- identical pattern compiles at two other locations
- The misleading comment `BX: derive temp_4 from BX1` was incorrect; `temp_4` is a direct axiom constructor
- Critical path: existsTask_transitive -> canonicalR_transitive -> parametric_task_rel_forward_comp -> bx_completeness (both dense and discrete cases)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation requested.

## Goals & Non-Goals

**Goals**:
- Verify existsTask_transitive is sorry-free in the current codebase
- Confirm `#print axioms bx_completeness` shows no sorry-related axioms from existsTask_transitive
- Confirm `lake build` passes cleanly
- Mark task as verified/complete

**Non-Goals**:
- Applying the fix (already done in task 139 phase 2)
- Fixing other sorries in the codebase (separate tasks)
- Refactoring the proof or improving the misleading comment

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fix from task 139 may have been reverted | H | L | Check git log and grep for sorry in CanonicalFrame.lean |
| Other sorries may still propagate into bx_completeness | M | M | Use lean_verify on bx_completeness to check full axiom chain |
| lake build may fail due to unrelated changes | L | L | Isolate whether failure is in CanonicalFrame.lean or elsewhere |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Verify Fix Applied [NOT STARTED]

**Goal**: Confirm the sorry in existsTask_transitive has been replaced and the proof compiles.

**Tasks**:
- [ ] Grep CanonicalFrame.lean for `sorry` to confirm none remain
- [ ] Use `lean_goal` at the end of existsTask_transitive to confirm no goals remain
- [ ] Use `lean_verify` on `existsTask_transitive` to confirm no sorryAx dependency
- [ ] Verify the proof term at line 259 is `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`

**Timing**: 5 minutes

**Depends on**: none

**Files to modify**:
- None (verification only)

**Verification**:
- `grep -c sorry CanonicalFrame.lean` returns 0
- `lean_verify` on existsTask_transitive shows no sorryAx

---

### Phase 2: Verify Propagation and Build [NOT STARTED]

**Goal**: Confirm the fix propagates through the critical path to bx_completeness and the full project builds.

**Tasks**:
- [ ] Use `lean_verify` on `canonicalR_transitive` to confirm no sorryAx
- [ ] Use `lean_verify` on `bx_completeness` (or equivalent top-level theorem) to check axiom dependencies
- [ ] Run `lake build` to confirm the full project compiles
- [ ] Document verification results

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**:
- None (verification only)

**Verification**:
- `lean_verify` on bx_completeness shows no sorry-related axioms from existsTask_transitive
- `lake build` exits with code 0

## Testing & Validation

- [ ] No `sorry` keyword in CanonicalFrame.lean
- [ ] `lean_verify existsTask_transitive` shows no sorryAx
- [ ] `lean_verify bx_completeness` does not list existsTask_transitive-related sorry axioms
- [ ] `lake build` passes

## Artifacts & Outputs

- `specs/144_fix_existsTask_transitive/plans/01_fix-existsTask-transitive.md` (this plan)
- `specs/144_fix_existsTask_transitive/summaries/01_fix-existsTask-transitive-summary.md` (after implementation)

## Rollback/Contingency

Since no code changes are expected (fix already applied), rollback is not applicable. If verification reveals the fix is incomplete or has been reverted, the known fix is: replace `sorry` at CanonicalFrame.lean:259 with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`. This is a single-line change with 100% confidence per research.
