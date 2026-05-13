# Implementation Plan: Remove unused left_mono_until_mcs

- **Task**: 135 - Remove unused left_mono_until_mcs from CanonicalChain.lean
- **Status**: [NOT STARTED]
- **Effort**: 15 minutes
- **Dependencies**: None
- **Research Inputs**: Task 115 verification audit
- **Artifacts**: plans/01_remove-dead-code.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Remove the `left_mono_until_mcs` theorem (CanonicalChain.lean lines 67-91) which is defined but has zero external callers. It uses BX2 (left_mono_until), which is a candidate for removal in task 133. Removing it now avoids having to update it later.

## Goals & Non-Goals

**Goals**:
- Remove `left_mono_until_mcs` theorem and its doc comment from CanonicalChain.lean
- Update module doc comment to remove the reference (line 14)
- Verify `lake build` passes

**Non-Goals**:
- Removing BX2 itself (that is task 133)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden caller exists | L | L | Grep confirmed zero external references |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

### Phase 1: Remove dead code [NOT STARTED]

**Goal**: Delete `left_mono_until_mcs` and verify build.

**Tasks**:
- [ ] Remove lines 67-91 (theorem + doc comment) from CanonicalChain.lean
- [ ] Remove line 14 reference from module doc comment
- [ ] Run `lake build`

**Timing**: 15 minutes
**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean`

**Verification**:
- `lake build` passes
- `grep -rn "left_mono_until_mcs" Theories/` returns zero hits

## Testing & Validation

- [ ] `lake build` passes clean
- [ ] Zero references to `left_mono_until_mcs`

## Artifacts & Outputs

- plans/01_remove-dead-code.md (this file)

## Rollback/Contingency

Revert the deletion if any caller is discovered. Git makes this trivial.
