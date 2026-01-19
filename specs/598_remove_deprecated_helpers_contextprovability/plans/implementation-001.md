# Implementation Plan: Task #598

- **Task**: 598 - Remove deprecated helper functions from ContextProvability.lean
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Priority**: Low
- **Dependencies**: None
- **Research Inputs**: specs/598_remove_deprecated_helpers_contextprovability/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Remove two deprecated helper functions from `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`. The functions `semantic_world_validity_implies_provable` and `semantic_consequence_implies_semantic_world_truth` were deprecated on 2026-01-18 as Strategy C (using `main_provable_iff_valid` directly) supersedes them. Research confirms both functions are completely unused in the codebase.

### Research Integration

Research report (research-001.md) confirmed:
- Both functions are defined but never referenced elsewhere
- The replacement `representation_theorem_backward_empty` is fully proven at line 221
- Lines 119-194 contain the deprecated section (including documentation comments)
- Safe to delete with no migration required

## Goals & Non-Goals

**Goals**:
- Remove `semantic_world_validity_implies_provable` (def, lines 127-133)
- Remove `semantic_consequence_implies_semantic_world_truth` (theorem, lines 149-194)
- Remove associated deprecated documentation comments (lines 119-148)
- Ensure build passes after removal

**Non-Goals**:
- Modifying any other files
- Adding replacement documentation (the existing docstring on `representation_theorem_backward_empty` already explains Strategy C)
- Changing the structure of remaining code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency in downstream code | Medium | Low | Research verified no usages; verify with `lake build` |
| Breaking Lean imports | Low | Very Low | Functions are local to this file; no exports affected |

## Implementation Phases

### Phase 1: Remove deprecated functions [COMPLETED]

**Goal**: Delete the deprecated section (lines 119-194) from ContextProvability.lean

**Tasks**:
- [ ] Delete lines 119-194 from `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
  - Line 119: Start of deprecated section comment (`/--`)
  - Lines 127-133: `semantic_world_validity_implies_provable` definition
  - Lines 135-148: Deprecated documentation for second function
  - Lines 149-194: `semantic_consequence_implies_semantic_world_truth` theorem

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Delete lines 119-194

**Verification**:
- File compiles with `lean_diagnostic_messages`
- Deprecated functions no longer appear in file

---

### Phase 2: Build verification [COMPLETED]

**Goal**: Verify the Lean project builds successfully after removal

**Tasks**:
- [ ] Run `lake build` to compile the project
- [ ] Verify no new errors or warnings related to removed functions
- [ ] Confirm dependent files still compile (WeakCompleteness.lean, FiniteModelProperty.lean, RepresentationTheorem.lean)

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` completes without errors
- `lean_diagnostic_messages` shows no new issues in ContextProvability.lean

## Testing & Validation

- [ ] `lean_diagnostic_messages` on ContextProvability.lean shows no errors
- [ ] `lake build` succeeds
- [ ] `rg "semantic_world_validity_implies_provable|semantic_consequence_implies_semantic_world_truth"` returns no results

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified: `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`

## Rollback/Contingency

If issues arise after removal:
1. Restore deleted lines from git: `git checkout -- Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
2. Investigate why the "unused" functions were actually needed
3. Update deprecation notice rather than removing if needed
