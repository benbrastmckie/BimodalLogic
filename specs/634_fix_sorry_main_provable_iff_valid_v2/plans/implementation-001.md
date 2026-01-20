# Implementation Plan: Fix sorry in main_provable_iff_valid_v2

- **Task**: 634 - Fix sorry in main_provable_iff_valid_v2
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: Low
- **Dependencies**: None
- **Research Inputs**: None (task description provides context)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The `main_provable_iff_valid_v2` theorem at SemanticCanonicalModel.lean:632 has a sorry in its completeness direction. The sorry exists because bridging from general validity (`valid phi` - truth in ALL models) to finite model truth (`semantic_truth_at_v2`) is non-trivial. However, a sorry-free alternative `semantic_weak_completeness` exists at line 551 that proves completeness via a different approach. The task description recommends "continuing with the sorry-free alternative."

This plan documents the sorry as a known limitation and ensures the codebase is properly annotated. The sorry cannot be easily eliminated without significant theoretical work, but it does not block practical usage since `semantic_weak_completeness` provides equivalent functionality.

## Goals & Non-Goals

**Goals**:
- Document the sorry as an intentional limitation with clear rationale
- Verify that all callers can use `semantic_weak_completeness` as an alternative
- Add or improve documentation explaining the two approaches
- Consider deprecation annotation if appropriate

**Non-Goals**:
- Actually proving the truth bridge lemma (estimated 8-12 hours with uncertain success)
- Removing `main_provable_iff_valid_v2` entirely (it's referenced in tests and documentation)
- Refactoring ContextProvability.lean to avoid the sorry chain (would change the proof strategy)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The sorry in `main_provable_iff_valid_v2` transitively affects other proofs | Medium | Medium | Document the chain; callers can use `semantic_weak_completeness` directly |
| Deprecation annotation breaks dependent code | Low | Low | Check all usages before adding annotation |

## Implementation Phases

### Phase 1: Audit Usage and Document [NOT STARTED]

**Goal**: Understand current usage patterns and add comprehensive documentation.

**Tasks**:
- [ ] Review all usages of `main_provable_iff_valid_v2` (identified: ContextProvability.lean, Demo.lean, tests)
- [ ] Check if ContextProvability.lean's usage actually depends on the sorry direction
- [ ] Add documentation comment to `main_provable_iff_valid_v2` explaining:
  - Why the sorry exists (truth bridge problem)
  - When to use `semantic_weak_completeness` instead
  - What the theoretical limitation means in practice
- [ ] Update the theorem's docstring to clearly indicate the sorry in completeness direction

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Improve docstring

**Verification**:
- Documentation clearly explains the limitation
- lake build succeeds

---

### Phase 2: Add Alternative for Callers [NOT STARTED]

**Goal**: Provide a sorry-free pathway for code that needs the equivalence.

**Tasks**:
- [ ] Consider adding a type alias or helper that wraps `semantic_weak_completeness` for common use cases
- [ ] Review if ContextProvability.lean line 149 could use `semantic_weak_completeness` directly
- [ ] If feasible, add a comment in ContextProvability.lean noting the sorry dependency
- [ ] Update README.md in Metalogic_v2 if needed to document the recommended approach

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Add comment noting sorry dependency
- `Theories/Bimodal/Metalogic_v2/README.md` - Update if needed

**Verification**:
- All files compile without new errors
- Documentation is consistent

---

### Phase 3: Verify and Close [NOT STARTED]

**Goal**: Ensure the codebase builds and the limitation is properly documented.

**Tasks**:
- [ ] Run `lake build` to verify no regressions
- [ ] Verify diagnostic messages show no new errors
- [ ] Create implementation summary documenting the approach taken

**Timing**: 10 minutes

**Verification**:
- `lake build` succeeds
- No new sorries introduced
- Existing sorry is documented

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] `lean_diagnostic_messages` shows no new errors in modified files
- [ ] Documentation accurately describes the limitation and alternatives

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Updated docstrings in SemanticCanonicalModel.lean
- Updated comments in ContextProvability.lean

## Rollback/Contingency

Changes are limited to documentation and comments. If any issues arise:
- Revert docstring changes with `git checkout`
- The sorry itself is not being modified, only documented
