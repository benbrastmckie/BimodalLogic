# Implementation Plan: Resolve Truth.lean Sorries

**Task**: 258  
**Language**: lean  
**Status**: [NOT STARTED]  
**Created**: 2026-01-04  
**Estimated Total Effort**: 0.5 hours  

## Metadata

- **Proof Strategy**: Verification and documentation (no proofs needed - already resolved)
- **Complexity**: simple
- **Research Integrated**: Yes (research-001.md confirms task already resolved)
- **Mathlib Dependencies**: None (verification only)
- **Original Estimate**: 10-20 hours (outdated - based on unresolved sorries)
- **Actual Effort**: 0.5 hours (verification and status update only)

## Overview

### Problem Statement

Task 258 was created to resolve 3 `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity (lines 697, 776, 798 in an older version). However, research findings reveal these sorries **no longer exist** - they were removed in Task 213 (commit 1cf688b, 2025-12-28).

### Current State

- **Truth.lean**: 580 lines, **0 sorries** (verified)
- **Build Status**: Compiles successfully
- **SORRY_REGISTRY.md**: Confirms 0 active sorries in Truth.lean
- **Task 213**: Removed unprovable `is_valid_swap_involution` theorem and associated sorries

### Scope

This plan covers:
1. Verification that all sorries are indeed resolved
2. Cross-referencing with Task 213 artifacts
3. Updating task status to reflect completion
4. Documentation of resolution for future reference

**Out of Scope**: No new proofs or code changes needed.

### Lean-Specific Constraints

- **Mathlib Compatibility**: N/A (no changes needed)
- **Type Universe Constraints**: N/A (no changes needed)
- **Decidability Requirements**: N/A (no changes needed)
- **Computational vs Propositional**: N/A (no changes needed)

### Definition of Done

- [x] Verify Truth.lean has 0 sorries (confirmed via grep)
- [x] Verify Truth.lean builds successfully (confirmed)
- [x] Cross-reference Task 213 resolution (confirmed in research)
- [ ] Update task status to ALREADY_RESOLVED or OBSOLETE
- [ ] Document findings in task artifacts

## Proof Strategy

**Strategy**: Verification and documentation (no proofs needed)

### High-Level Approach

This is a verification task, not an implementation task. The work has already been completed in Task 213. The strategy is to:

1. Verify current state matches research findings
2. Document the resolution path (Task 213)
3. Update task metadata to reflect completion

### Key Tactics

N/A - No proofs needed. Verification only.

### Mathlib Theorems to Leverage

N/A - No new theorems needed. Existing Truth.lean theorems are:
- `time_shift_preserves_truth`: Main time-shift preservation (fully proven)
- `truth_double_shift_cancel`: Double shift cancellation (fully proven)
- `exists_shifted_history`: Corollary for MF/TF axioms (fully proven)

### Historical Context: Original Sorries (Removed in Task 213)

The 3 sorries that Task 258 originally targeted were:

1. **Line 697** (old version): `truth_swap_of_valid_at_triple` implication case
   - Issue: Swap of implication not obviously equivalent
   - Resolution: Removed with unprovable theorem

2. **Line 776** (old version): `truth_swap_of_valid_at_triple` past case
   - Issue: Domain extension for history quantification
   - Resolution: Removed with unprovable theorem

3. **Line 798** (old version): `truth_swap_of_valid_at_triple` future case
   - Issue: Domain extension into the past
   - Resolution: Removed with unprovable theorem

**Why Removed**: Task 213 discovered that `is_valid_swap_involution` was semantically false for arbitrary formulas. The swap operation exchanges `all_past` ↔ `all_future`, which quantify over different time ranges and are not equivalent in general temporal models.

**Counterexample**: φ = all_past(atom "p") in a model where p is true at all future times but false at all past times.

### Potential Pitfalls

- **Pitfall**: Attempting to re-implement removed functionality
- **Mitigation**: Document why the theorem was unprovable and should not be re-added

## Implementation Phases

### Phase 1: Verification [NOT STARTED]
**Objective**: Verify current state matches research findings

**Tasks**:
1. Run `grep -c sorry Logos/Core/Semantics/Truth.lean` to confirm 0 sorries
2. Run `lake build Logos.Core.Semantics.Truth` to verify compilation
3. Check SORRY_REGISTRY.md for Truth.lean entry
4. Review Task 213 commit (1cf688b) for resolution details

**Acceptance Criteria**:
- Truth.lean has 0 sorries (verified)
- Truth.lean builds successfully (verified)
- SORRY_REGISTRY.md shows 0 sorries for Truth.lean (verified)
- Task 213 artifacts reviewed and understood

**Estimated Effort**: 0.25 hours

### Phase 2: Documentation and Status Update [NOT STARTED]
**Objective**: Update task status and document resolution

**Tasks**:
1. Update task status in TODO.md to [ALREADY_RESOLVED] or [OBSOLETE]
2. Add note referencing Task 213 as the resolution
3. Update task description to reflect current state
4. Add cross-reference to Task 213 artifacts
5. Document findings in this implementation plan

**Acceptance Criteria**:
- Task status updated in TODO.md
- Cross-reference to Task 213 added
- Implementation plan documents resolution path
- Future developers can understand why task is marked resolved

**Estimated Effort**: 0.25 hours

## Mathlib Integration

### Required Imports

N/A - No changes to Truth.lean needed. Current imports are:
```lean
import Logos.Core.Semantics.TaskModel
import Logos.Core.Semantics.WorldHistory
import Logos.Core.Syntax.Formula
```

### Relevant Namespaces

- `Logos.Core.Semantics`: Truth evaluation definitions
- `Logos.Core.Semantics.TimeShift`: Time-shift preservation theorems

### API Usage Patterns

N/A - No new API usage needed.

### Version Compatibility Notes

Current Truth.lean is compatible with Lean 4 and builds successfully with the project's lean-toolchain version.

## Testing and Validation

### Type Checking

```bash
lake build Logos.Core.Semantics.Truth
```

**Expected Result**: Success (already verified)

### Unit Tests

N/A - Truth.lean has comprehensive tests in LogosTest/Core/Semantics/TruthTest.lean (already passing).

### Property Testing

N/A - Semantic property tests in LogosTest/Core/Semantics/SemanticPropertyTest.lean (already passing).

### Example Usage Verification

Truth.lean is used throughout the codebase for semantic validation. All dependent modules build successfully.

### Documentation Review

Truth.lean has comprehensive documentation:
- Module-level docstring explaining paper alignment
- Function-level docstrings for `truth_at`
- Theorem-level docstrings for all major results
- Historical notes on removed functionality (lines 669-700 in old version)

## Artifacts

### Lean Source Files

- `Logos/Core/Semantics/Truth.lean` (no changes needed - already clean)

### Test Files

- `LogosTest/Core/Semantics/TruthTest.lean` (no changes needed - already passing)

### Documentation

- This implementation plan (documents resolution)
- Task 213 artifacts (original resolution)
- Research report (research-001.md)

## Rollback

### Git Commit Strategy

No commits needed - no code changes required.

### Revert Procedure

N/A - No changes to revert.

### Alternative Approaches

If task status update is blocked:
1. Mark task as OBSOLETE instead of ALREADY_RESOLVED
2. Add note in task description explaining resolution via Task 213
3. Keep task in TODO.md for historical reference

## Cross-References

### Related Tasks

- **Task 213**: Resolved is_valid_swap_involution blocker (commit 1cf688b)
  - Removed unprovable theorem and 3 associated sorries
  - Added comprehensive documentation
  - Moved temporal duality to SoundnessLemmas.lean

### Related Commits

- **1cf688b** (2025-12-28): Task 213 - removed unprovable theorem and sorries
- **cd463cf**: Temporal operator refactor - originally introduced the 3 sorries

### Related Documentation

- `.opencode/specs/213_resolve_is_valid_swap_involution_blocker/` - Task 213 artifacts
- `docs/project-info/SORRY_REGISTRY.md` - Confirms 0 sorries in Truth.lean
- Research report: `.opencode/specs/258_resolve_truth_lean_sorries/reports/research-001.md`

## Notes

### Why This Task Exists Despite Being Resolved

Task 258 was created based on an outdated snapshot of the codebase. Between task creation and task execution, Task 213 resolved the underlying issues. This is a normal occurrence in concurrent development.

### Recommendation

Mark this task as **ALREADY_RESOLVED** with a note: "Resolved in Task 213 (commit 1cf688b, 2025-12-28). Truth.lean currently has 0 sorries and builds successfully."

### Future Work

No future work needed for Truth.lean sorries. The file is clean and well-documented.

For temporal duality handling, see:
- `Logos/Core/Metalogic/SoundnessLemmas.lean` (temporal_duality case)
- Will be completed after soundness theorem proven (documented circular dependency)
