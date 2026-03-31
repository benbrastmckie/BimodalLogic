# Blocker Analysis: Task #73

**Parent Task**: #73 - resolve_class_a_sorries_dne
**Generated**: 2026-03-31
**Blocker**: The original "Class A sorries" no longer exist - they have been resolved via DNE. The remaining 6 sorries fall into two distinct categories requiring separate tasks.

## Root Cause

The task description references "Class A sorries" that were documented in ROADMAP.md at specific line numbers. Research confirmed:

1. **DNE pattern already applied**: The double-negation elimination approach described in the task is already implemented successfully (e.g., `f_step_blocking_formulas_subset_u` at line 1144-1153).

2. **Line numbers outdated**: The referenced locations no longer contain sorries.

3. **Remaining sorries are different categories**: The 6 current sorries in SuccChainFMCS.lean fall into two unrelated categories:
   - **Consistency proofs** (lines 1734, 1763, 2082): Multi-BRS consistency arguments
   - **Termination artifacts** (lines 5386, 5544, 5740): Fuel-exhausted branches

## Proposed New Tasks

### New Task 1: Resolve consistency proof sorries in SuccChainFMCS
- **Effort**: 1-2 hours
- **Language**: lean4
- **Rationale**: Lines 1734, 1763, 2082 all involve proving set consistency for BRS-augmented seed sets. These require structural consistency arguments showing no contradictory formula pairs exist.
- **Depends on**: None

Specific sorries:
- `g_content_union_brs_consistent` (line 1734): Multi-BRS case consistency
- `augmented_seed_consistent` (line 1763): Boundary resolution set consistency
- `constrained_successor_seed_restricted_consistent` (line 2082): Seed consistency proof

### New Task 2: Clean up termination artifact sorries in SuccChainFMCS
- **Effort**: 1-2 hours
- **Language**: lean4
- **Rationale**: Lines 5386, 5544, 5740 are fuel-exhausted branches in bounded_witness theorems. These are semantically unreachable when called with sufficient initial fuel (B*B+1) but require explicit proof for the termination checker.
- **Depends on**: None

Specific sorries:
- `restricted_backward_bounded_witness_fueled` (line 5386)
- `restricted_combined_bounded_witness_fueled` (line 5544)
- `restricted_combined_bounded_witness_P_fueled` (line 5740)

## Dependency Reasoning

- **Task 1 and Task 2 are independent**: They address completely different proof obligations with no shared implementation decisions. Consistency proofs use structural reasoning about formula sets, while termination proofs use fuel/depth arguments. Neither affects how the other should be implemented.

## After Completion

Once both spawned tasks are complete, the parent task #73 can be marked as [COMPLETED] since its original goal (resolve Class A sorries) was already achieved and the remaining work has been properly scoped into actionable subtasks.

The blocker will be resolved because: The remaining sorries in SuccChainFMCS.lean will be addressed by the two new tasks, each focused on its specific proof category.
