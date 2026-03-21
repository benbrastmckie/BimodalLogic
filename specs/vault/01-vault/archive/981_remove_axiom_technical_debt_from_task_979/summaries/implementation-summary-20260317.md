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

---

### Phase 2 (Continued): Well-Ordering Approach [BLOCKED]

**Session**: 2026-03-17, sess_1773756442_ae96f4 (plan v5, iteration 1)
**Duration**: ~90 minutes

**Approach Attempted**: Well-Founded Minimal Successor (Approach 2 from research-006, as specified in plan v5)

**Analysis Performed**:
1. Studied Mathlib infrastructure: `WellFounded.min`, `SuccOrder.ofCore`, `SuccOrder.ofLinearWellFoundedLT`
2. Analyzed relationship between arbitrary well-orderings and timeline ordering
3. Identified fundamental conceptual flaw in the approach

**BLOCKER DISCOVERED**:

The plan claims that defining `discreteSucc(M) := WellFounded.min wellOrder (Ioi M)` gives covering "trivially from minimality". This is **mathematically incorrect**.

**The Flaw**:
- `WellFounded.min` picks the minimum under the well-ordering `≺`
- `SuccOrder.ofCore` requires: `a < b ↔ succ a ≤ b` in the **timeline order**
- An arbitrary well-ordering `≺` is INDEPENDENT of the timeline order `<`
- `≺`-minimality does NOT imply timeline-minimality

**Example**:
- Let `K` be the `≺`-minimum of `Ioi M = {x | M < x}`
- Let `J ∈ Ioi M` with `J <_timeline K` (J is earlier than K in timeline)
- We have `K ≺ J` (by `≺`-minimality of K), but `K >_timeline J`
- No contradiction - the orderings are different

**Alternative Approaches Ruled Out**:
1. `SuccOrder.ofLinearWellFoundedLT`: Timeline `<` is not well-founded (unbounded)
2. `WellFoundedLT` on `Ioi M`: Would require proving no infinite descending chains = covering
3. Blocking formula covering (`discreteImmediateSucc_covers`): Has 3 sorries

**Status**: Phase 2 BLOCKED due to fundamental mathematical impossibility of the approach as specified in plan v5.

## Updated Cumulative Statistics

| Metric | Value |
|--------|-------|
| Phases Completed | 1 (Phase 1) |
| Phases Blocked | 1 (Phase 2) |
| Phases Remaining | 2 (Phases 3-4) |
| Files Created | 1 |
| Files Modified | 1 (plan v5) |
| Lines Added | ~460 |
| Sorries Introduced | 0 |
| Axioms Introduced | 0 |

## Revised Recommendations

The well-founded minimal successor approach (Approach 2) has a fundamental flaw. Recommendations:

1. **Complete blocking formula covering** (highest priority):
   - The 3 sorries in `DiscreteSuccSeed.lean:discreteImmediateSucc_covers` (lines 525, 562, 595)
   - If these can be proved, covering follows and axiom can be eliminated
   - This is the most direct path

2. **Modify staged build to use blocking formulas**:
   - Change `discreteStagedBuild` to use `discreteImmediateSuccSeed`
   - Then covering holds "by construction" as originally intended

3. **Accept as documented debt** (last resort):
   - The axiom IS sound (discrete timelines have finite intervals)
   - Document thoroughly and flag for publication review

## Key Files

- **Implementation**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- **Plan**: `/home/benjamin/Projects/ProofChecker/specs/981_remove_axiom_technical_debt_from_task_979/plans/implementation-005.md`
- **Research**: `/home/benjamin/Projects/ProofChecker/specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md`
- **Blocking sorries**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (lines 525, 562, 595)

---

### Phase 2: Immediate Successor Staged Build (Plan v6) [COMPLETED]

**Session**: 2026-03-17, sess_1773759199_613452 (plan v6, iteration 1)
**Duration**: ~60 minutes

**Approach**: Following plan v6 (Modified Staged Construction from research-007)

**Changes Made**:
- Created `Theories/Bimodal/Metalogic/StagedConstruction/ImmediateStagedBuild.lean` (~340 lines)
- Defined `immediateForwardWitnessPoint` - Creates forward witness using blocking formula seed
- Defined `processImmediateForwardObligation` - Wraps witness creation for staged build
- Defined `discreteStagedBuildImmediate` - Alternative staged build using immediate successors
- Proved `discreteStagedBuildImmediate_monotone` - Monotonicity
- Proved `discreteStagedBuildImmediate_linear` - All points comparable with root, hence linear
- Proved `has_immediate_successor_at_next_stage` - Every point has immediate successor
- Proved `covering_at_stage` - Covering (delegates to `discreteImmediateSucc_covers`)
- Defined `immediateStagedUnion` and `immediateStagedUnion_linear`

**Verification**:
- `lake build` passes (933 jobs, no errors)
- No new sorries introduced (but depends on existing sorries in DiscreteSuccSeed.lean)

---

### Phase 3: Stage-Level Immediate Successor (Plan v6) [COMPLETED]

**Session**: 2026-03-17, sess_1773759199_613452
**Duration**: ~10 minutes

**Analysis**:
- Key covering content was already implemented in Phase 2
- Plan's uniqueness claim (`immediateSucc_unique`) is mathematically incorrect (Lindenbaum extensions not unique)
- Covering follows from blocking formulas, not uniqueness

---

### Phase 4: Colimit Isomorphism (Plan v6) [BLOCKED]

**Session**: 2026-03-17, sess_1773759199_613452
**Duration**: ~30 minutes

**Discovery**: The implementation depends on `discreteImmediateSucc_covers` which has 3 UNFILLABLE sorries.

**Analysis**:
1. `immediateForwardWitnessPoint_covers` (Phase 2) delegates to `discreteImmediateSucc_covers`
2. `discreteImmediateSucc_covers` (DiscreteSuccSeed.lean) has sorries at lines 525, 562, 595
3. Research-007 confirmed these sorries are UNFILLABLE with current approach
4. The "covering by construction" claim from research-007 is overly optimistic

**Root Cause**:
- Blocking formulas constrain the SUCCESSOR (W) but not arbitrary INTERMEDIATE K
- K satisfying `CanonicalR M K` and `CanonicalR K W` is not constrained to equal M or W
- The algebraic proof requires semantic reasoning not extractable from DF axiom membership

**Mathematical Gap**:
The gap between:
- SEMANTIC: DF frame condition says immediate successors exist
- SYNTACTIC: DF creates F(H(phi)) obligations in MCSs
These F-obligations don't constrain intermediate MCSs - they can be witnessed by ANY forward MCS.

---

## Final Status

| Phase | Status |
|-------|--------|
| Phase 1 | COMPLETED (prior session) |
| Phase 2 | COMPLETED (new infrastructure) |
| Phase 3 | COMPLETED (covering integrated with Phase 2) |
| Phase 4 | BLOCKED (depends on unfillable sorries) |
| Phase 5 | NOT STARTED (blocked by Phase 4) |

## Files Created

| File | Lines | Description |
|------|-------|-------------|
| `ImmediateStagedBuild.lean` | ~340 | Alternative staged build with blocking formulas |
| `IncrementalTimeline.lean` | ~310 | Stage-indexed infrastructure (prior session) |

## Conclusion

The Modified Staged Construction approach (plan v6) made infrastructure progress but is ultimately blocked by the same covering proof gap that blocked all prior approaches. The 3 sorries in `discreteImmediateSucc_covers` represent a fundamental mathematical obstacle: the DF frame condition cannot be extracted from DF axiom membership at the MCS level.

**Recommendation**: Mark Phase 4 as BLOCKED and require user review for next steps. The axiom remains as documented technical debt pending new mathematical insight.
