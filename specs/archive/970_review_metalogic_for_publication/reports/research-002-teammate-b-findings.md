# Research Report: Task 970/971 Coordination Analysis

- **Task**: 970 (phases 5-9 remaining) and 971
- **Type**: Coordination/Overlap Analysis
- **Date**: 2026-03-15
- **Agent**: lean-research-agent (teammate-b)
- **Confidence**: HIGH

## Executive Summary

Task 970 phases 5-9 and Task 971 have **minimal overlap** but important **sequencing dependencies**. Task 971's scope (eliminating bmcs_truth_at layer) is orthogonal to most of task 970's remaining phases, but Phase 4 of task 970 (unused FMCS/BFMCS definitions) directly touches BFMCSTruth.lean, creating a dependency.

**Recommendation**: Task 970 phases 5-9 can proceed in parallel with task 971, EXCEPT that task 970's Phase 4 removals in BFMCSTruth.lean should be coordinated or deferred to task 971.

---

## Overlap Analysis

### Task 970 Remaining Phases vs Task 971 Scope

| Task 970 Phase | Scope | Overlaps with 971? | Details |
|----------------|-------|-------------------|---------|
| Phase 5: Consolidate Duplicates | `set_mcs_all_future_all_future` etc in Completeness.lean | **NO** | Different files |
| Phase 6: Unify asDiamond | ModalSaturation.lean vs Tableau.lean | **NO** | Different subsystem |
| Phase 7: Clean Internal Scaffolding | `needs_modal_witness` in ModalSaturation.lean | **MINIMAL** | Could touch BFMCSTruth.lean indirectly |
| Phase 8: Remove Weak/Finite Completeness | Various completeness variants | **NO** | Different layer |
| Phase 9: Naming Conventions | Cross-cutting | **POSSIBLE** | If renaming bmcs_* identifiers |

### Task 971 Scope

Task 971 targets:
1. **BFMCSTruth.lean** - Add deprecation notice, archive to Boneyard
2. **TruthLemma.lean** - Update documentation to note bmcs_truth_lemma as legacy
3. **Metalogic.lean** - Update publication exports
4. **IntRepresentation.lean** (Boneyard) - Update deprecation notice

### Direct Conflicts Identified

1. **BFMCSTruth.lean ownership conflict**:
   - Task 970 Phase 4 [COMPLETED] already removed `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`
   - Task 971 Phase 2 wants to add deprecation header and archive the file
   - **Resolution**: Task 970's Phase 4 work on BFMCSTruth.lean is DONE. Task 971 can proceed.

2. **TruthLemma.lean documentation**:
   - Task 970 Phase 11 [COMPLETED] adds legacy path markers
   - Task 971 Phase 3 updates documentation
   - **Resolution**: Tasks are aligned - both add deprecation/legacy notices. Task 971 can build on 970's work.

---

## Shared Dependencies

### Files Touched by Both Tasks

| File | Task 970 Phase | Task 971 Phase | Conflict Risk |
|------|----------------|----------------|---------------|
| `BFMCSTruth.lean` | Phase 4 (COMPLETED) | Phase 2 | LOW (970 done) |
| `TruthLemma.lean` | Phase 11 (COMPLETED) | Phase 3 | LOW (aligned goals) |
| `Metalogic.lean` | Phase 11 (COMPLETED) | Phase 4 | LOW (aligned goals) |
| `Bundle/README.md` | N/A | Phase 6 | NONE |

### Import Graph Impact

```
BFMCSTruth.lean
  <- TruthLemma.lean (imports BFMCSTruth)
  <- Boneyard/IntRepresentation/Representation.lean (imports BFMCSTruth)
```

Task 971 cannot remove BFMCSTruth.lean entirely - it must remain importable for TruthLemma.lean. Both plans acknowledge this.

---

## Recommended Task Sequencing

### Can Proceed in Parallel

1. **Task 970 Phase 5** (Consolidate Duplicates) - Completeness.lean, MCSProperties.lean
2. **Task 970 Phase 6** (Unify asDiamond) - ModalSaturation.lean, Tableau.lean
3. **Task 970 Phase 8** (Remove Weak/Finite Completeness) - Various files

### Should Complete Before Task 971

1. **Task 970 Phase 4** [ALREADY COMPLETED] - Removed unused BFMCSTruth definitions

### Task 971 Prerequisites

Task 971 can start immediately because:
- Task 970 Phase 4's BFMCSTruth.lean changes are done
- Task 970's legacy markers (Phase 11) are done
- No import cycle risks identified

### Potential Coordination Points

1. **Phase 9 (Naming Conventions)**: If task 970 renames any `bmcs_*` identifiers, coordinate with task 971's deprecation notices to avoid confusion.

2. **Phase 7 (Internal Scaffolding)**: Verify ModalSaturation.lean changes don't affect anything task 971 touches.

---

## Risk of Conflicts

| Scenario | Probability | Impact | Mitigation |
|----------|-------------|--------|------------|
| Merge conflict in BFMCSTruth.lean | LOW | LOW | Task 970's Phase 4 already done |
| Merge conflict in TruthLemma.lean | LOW | LOW | Both adding doc comments, non-overlapping |
| Import breakage | LOW | MEDIUM | Both plans require `lake build` verification |
| Naming inconsistency | MEDIUM | LOW | Task 971 should use same naming as existing code |

---

## Key Findings

### 1. bmcs_truth_at Usage is Limited

Active usage of `bmcs_truth_at` confined to:
- `BFMCSTruth.lean` (definition)
- `TruthLemma.lean` (bmcs_truth_lemma proof)
- `CanonicalConstruction.lean` (documentation comment only - notes redundancy)
- `Completeness.lean` (not directly using bmcs_truth_at)
- `Bundle/README.md` (documentation)

### 2. CanonicalConstruction Already Supersedes

`CanonicalConstruction.lean` lines 19-22 explicitly document:
> "The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally identical to `truth_at` when canonical definitions are chosen correctly."

This validates task 971's approach.

### 3. Task 970 Completed Phases Already Prepared the Path

Task 970 has already:
- Removed unused `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` (Phase 4)
- Added legacy path markers to documentation (Phase 11)
- Updated SORRY_REGISTRY.md (Phase 11)

---

## Recommendations

1. **Task 971 can start immediately** - No blocking dependencies from task 970's remaining phases.

2. **Task 970 phases 5-8 can proceed in parallel** - No overlap with task 971's scope.

3. **Task 970 Phase 9 (Naming)** should coordinate if renaming any `bmcs_*` identifiers to align with task 971's deprecation strategy.

4. **Both tasks should run `lake build`** after each phase to catch any unexpected breakage from the other task's changes.

5. **Recommended execution order**:
   - Start Task 971 (independent)
   - Continue Task 970 Phase 5-8 (parallel)
   - Coordinate Task 970 Phase 9 with Task 971 completion

---

## Confidence Level: HIGH

- Clear separation of concerns between tasks
- Task 970's BFMCSTruth.lean work already completed
- Import graph analysis confirms no circular dependencies
- Both plans align on using deprecation + preservation approach
