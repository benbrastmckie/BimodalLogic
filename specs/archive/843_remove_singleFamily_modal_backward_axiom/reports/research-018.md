# Research Report: Task #843

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-12
**Focus**: Relevance assessment in light of task 864 progress
**Session**: sess_1770918069_2f0443

## Summary

Task 864 (Recursive Seed Henkin Model) has made substantial progress and supersedes task 843's approach for achieving axiom-free completeness. Task 843's Phase 4 (critical goal) is already COMPLETED. The remaining phases are either BLOCKED (Phase 1) or provide mathematical results that would be redundant if task 864 succeeds. Recommend **archiving task 843 as PARTIAL** or **marking BLOCKED pending task 864 outcome**.

## Current State Analysis

### Task 843 Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | **BLOCKED** | Interleaved chain construction - architectural limitation prevents cross-sign G/H propagation |
| Phase 2 | NOT STARTED | BoxContent accessibility symmetry |
| Phase 3 | NOT STARTED | Generalized diamond-BoxContent consistency |
| Phase 4 | **COMPLETED** | FALSE axiom replaced with CORRECT axiom |
| Phase 5 | NOT STARTED | Prove the correct axiom (depends on Phases 1-3) |

**Key Achievement**: The FALSE `singleFamily_modal_backward_axiom` has been replaced with the mathematically sound `fully_saturated_bmcs_exists` axiom. This was task 843's critical goal.

**Remaining Work**: Proving `fully_saturated_bmcs_exists` and eliminating 4 temporal sorries.

### Task 864 Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phases 1-2 | COMPLETED | Data structures and recursive builder |
| Phase 3 | **IN PROGRESS** | Seed consistency proof - 28 of 36 hours completed |
| Phases 4-6 | NOT STARTED | Seed completion, BMCS assembly, verification |

**Key Achievement**: Session 28 eliminated the generic imp case sorry using full case analysis. The mathematical correctness of the proof is established.

**Remaining Sorries**: Structural "dead code" with false hypotheses (not mathematical gaps) + pre-existing API issues.

### Relationship Between Tasks

From task 864's plan v003:
> **Dependencies**: None (supersedes task 843's approach)

Task 864 uses recursive seed construction that:
1. Pre-places witnesses BEFORE Lindenbaum extension
2. Bypasses the cross-sign temporal propagation problem entirely
3. Does not require interleaved chain construction or S5 canonical model properties

## Findings

### 1. Task 843's Phase 1 is Architecturally Blocked

The v008 plan acknowledges (research-017 analysis):
- The two-chain architecture CANNOT support cross-sign G/H propagation
- Interleaved construction does NOT solve the problem (MCS at negative indices constructed AFTER less negative ones)
- Recommendation was "Accept 4 sorries as documented technical debt per Alternative C"

### 2. Task 864 Provides Alternative Path

Task 864's recursive seed construction addresses the same end goal (axiom-free completeness) via a different mechanism:
- Recursively builds seeds from formula structure
- Witnesses embedded during seed construction, not after
- G/H propagation handled by seed inclusion, not MCS chaining

### 3. Task 843's Remaining Value

If task 864 succeeds in achieving axiom-free completeness, task 843's remaining work provides:

| Component | Independent Value | Overlap with 864 |
|-----------|------------------|------------------|
| Phase 2 (S5 symmetry) | Yes - mathematical characterization | No |
| Phase 3 (Diamond consistency) | Yes - generalized lemma | Partial - 864 may use similar lemmas |
| Phase 5 (Canonical BMCS) | Depends on whether canonical model approach is desired | Full - 864 makes this unnecessary |

### 4. Effort Comparison

| Task | Remaining Effort | Probability of Success |
|------|------------------|----------------------|
| 843 (Phases 1-5) | 50-65 hours | LOW (Phase 1 blocked) |
| 864 (Phases 3-6) | ~17 hours | HIGH (mathematical correctness established) |

## Recommendations

### Option A: Archive Task 843 as PARTIAL (Recommended)

**Rationale**: Phase 4 (critical goal) is complete. Phase 1 is architecturally blocked. Task 864 provides superior path to remaining goals.

**Action**:
1. Update task 843 status to PARTIAL
2. Add completion_summary: "Phase 4 completed - FALSE axiom replaced with CORRECT axiom. Phases 1-3,5 superseded by task 864's recursive seed approach."
3. Archive the task

**Benefits**: Clean task list, acknowledges real progress made, avoids chasing blocked approach.

### Option B: Mark Task 843 BLOCKED pending Task 864

**Rationale**: If task 864 fails, task 843's S5 canonical model approach may still be needed.

**Action**:
1. Update task 843 status to BLOCKED
2. Add depends_on: [864]
3. Add note: "Blocked on architectural limitation. Re-evaluate after task 864 completes."

**Benefits**: Preserves fallback option if task 864 encounters unexpected obstacles.

### Option C: Scope Reduction (Extract Valuable Components)

**Rationale**: Phases 2-3 provide independent mathematical value (S5 characterization) even if not needed for completeness.

**Action**:
1. Create new task for S5 properties (Phases 2-3) if these are desired for documentation
2. Archive task 843 as PARTIAL with completion of Phase 4
3. New task would be optional enhancement, not on critical path

**Benefits**: Captures reusable lemmas without blocking completeness work.

## Decision Matrix

| Factor | Option A (Archive) | Option B (Block) | Option C (Extract) |
|--------|-------------------|------------------|-------------------|
| Cleanliness | Best | Medium | Medium |
| Risk mitigation | Low | High | Medium |
| Effort to execute | 15 min | 5 min | 1-2 hours |
| Preserves 843 work | Yes (Phase 4) | Yes (all) | Yes (all + new task) |

## Conclusion

**Recommendation: Option A (Archive as PARTIAL)**

Task 843 has achieved its critical goal (Phase 4). The remaining phases are either blocked or superseded by task 864's more promising approach. Archiving acknowledges the real progress while avoiding investment in a blocked path.

If the S5 canonical model characterization (Phases 2-3) is desired for documentation or future work, Option C provides a clean extraction path.

## Next Steps

1. Confirm recommendation with user
2. If Option A: Update task 843 status to PARTIAL, add completion_summary, run /todo
3. If Option B: Update task 843 status to BLOCKED, add dependency
4. Continue focus on task 864 completion

## References

- specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-008.md
- specs/864_recursive_seed_henkin_model/plans/implementation-003.md
- specs/843_remove_singleFamily_modal_backward_axiom/reports/research-017.md (architectural analysis)
- specs/864_recursive_seed_henkin_model/reports/research-002.md (how 864 bypasses 843's blockage)
