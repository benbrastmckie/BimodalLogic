# Implementation Summary: Task #981

**Task**: remove_axiom_technical_debt_from_task_979
**Status**: [IN PROGRESS]
**Started**: 2026-03-17
**Language**: lean

## Overview

This implementation follows plan v4 (incremental construction approach) to eliminate `discrete_Icc_finite_axiom` by making covering hold BY CONSTRUCTION through incremental model building.

## Phase Log

### Phase 1: Stage-Indexed Timeline Types [COMPLETED]

**Session**: 2026-03-17, sess_1773718331_6878f2 (iteration 1)
**Duration**: ~120 minutes

**Changes Made**:
- Created new file `IncrementalTimeline.lean` with stage-indexed timeline infrastructure
- Defined `DiscreteTimelineElem_at_stage n` - elements of discrete timeline at stage n
- Defined `DiscreteTimelineQuot_at_stage n` - antisymmetrization at each stage
- Proved `LinearOrder` on stage quotients (inherits from `discreteStagedBuild_linear`)
- Proved `Finite` and `Fintype` instances at each stage (Finset membership)
- Proved `LocallyFiniteOrder` at each stage (trivial from finiteness)
- Defined `embed_to_full` and `embed_quot_to_full` for embedding into full timeline
- Proved `quot_from_stage`: every element of `DiscreteTimelineQuot` comes from some stage

**Verification**:
- `lake build` passes (1023 jobs, no errors)
- `grep -n "\bsorry\b" IncrementalTimeline.lean` returns empty

---

### Phase 2: Stage Embedding and Successor [PARTIAL]

**Session**: 2026-03-17, sess_1773718331_6878f2 (iteration 2)
**Duration**: ~60 minutes

**Changes Made**:
- Defined `stage_embed_elem` - Element-level embedding from stage n to stage n+1
- Proved `stage_embed_elem_mono` - Stage embedding preserves order
- Proved `stage_embed_elem_injective` - Stage embedding is injective
- Defined `stage_embed` - Quotient-level embedding from stage n to stage n+1
- Proved `stage_embed_mono`, `stage_embed_injective` - Quotient-level properties
- Defined `immediateSuccPoint` - Creates successor MCS using blocking formulas
- Proved `immediateSuccPoint_canonicalR` - CanonicalR from M to its immediate successor
- Proved `immediateSuccPoint_covers` - Covering property from `discreteImmediateSucc_covers`

**BLOCKED**:
- `succ_at_stage : DiscreteTimelineQuot_at_stage n → DiscreteTimelineQuot_at_stage (n+1)` cannot be defined
- **Root cause**: `discreteStagedBuild` uses `forward_temporal_witness_seed` which does NOT include blocking formulas
- The successor MCS from `discreteImmediateSucc` (with blocking formulas) may NOT be in `discreteStagedBuild (n+1)`
- These are fundamentally different MCS constructions using different Lindenbaum seeds

**Resolution Options**:
1. **Modify `StagedExecution.lean`**: Change `processForwardObligation` to use `discreteImmediateSuccSeed` instead of `forward_temporal_witness_seed`
2. **Define new build**: Create `discreteStagedBuildImmediate` that uses blocking formula seeds
3. **Use well-founded minimal**: Approach 2 from research-006 - define `succ(M) := WellFounded.min { K | CanonicalR M K ∧ K ≠ M }`

**Verification**:
- `lake build` passes (1023 jobs, no errors)
- `grep -n "\bsorry\b" IncrementalTimeline.lean` returns empty (no new sorries)
- File now ~460 lines

## Cumulative Statistics

| Metric | Value |
|--------|-------|
| Phases Completed | 1 (Phase 1) |
| Phases Partial | 1 (Phase 2 blocked) |
| Phases Remaining | 3 (Phases 3-5) |
| Files Created | 1 |
| Files Modified | 0 |
| Lines Added | ~460 |
| Sorries Introduced | 0 |
| Axioms Introduced | 0 |

## Blocking Issue Analysis

The fundamental issue is an **architectural mismatch**:

1. **What we have**: `discreteStagedBuild` adds witnesses using `forward_temporal_witness_seed = {phi} ∪ g_content(M)`
2. **What we need**: Immediate successors using `discreteImmediateSuccSeed = g_content(M) ∪ blockingFormulas(M)`

The blocking formulas in `discreteImmediateSuccSeed` are what guarantee the covering property (no intermediate K between M and W). Without them, the staged build's witnesses may have intermediates.

**Mathematical insight**: The covering property `¬∃K. M < K < W` comes from blocking formulas, NOT from the staged construction order. The research-006 claim that "freshness" gives covering is incorrect for the CURRENT staged build because it doesn't use blocking formulas.

## Recommendations

1. **Plan revision needed**: The plan should be revised to either:
   - Add a Phase 1.5 to modify `StagedExecution.lean` to use blocking formula seeds
   - Switch to Approach 2 (well-founded minimal successor) from research-006

2. **Most feasible path**: Approach 2 (well-founded minimal) is likely cleaner because:
   - Doesn't require modifying existing infrastructure
   - Covering is trivial by minimality
   - Research-006 rates it "MEDIUM-HIGH confidence"

3. **Effort estimate**: ~12-16 hours additional to implement Approach 2

## Key Files

- **Implementation**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- **Plan**: `/home/benjamin/Projects/ProofChecker/specs/981_remove_axiom_technical_debt_from_task_979/plans/implementation-004.md`
- **Research**: `/home/benjamin/Projects/ProofChecker/specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md`
