# Implementation Summary: Task 58 Phase 1

**Task**: Wire completeness to FrameConditions
**Date**: 2026-03-25
**Session**: sess_1774456136_6ae199
**Status**: Phase 1 COMPLETED, Phase 2 IN PROGRESS

## Completed Work

### Phase 1: Modify Successor Seed with Boundary Resolution

**Changes Made**:

1. **Modified `constrained_successor_seed_restricted`** (SuccExistence.lean)
   - Added `boundary_resolution_set` as the fourth component of the seed
   - Old definition: `g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u`
   - New definition: `g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪ boundary_resolution_set phi u`

2. **Reorganized file structure** (SuccExistence.lean)
   - Moved `boundary_resolution_set` definition and lemmas BEFORE `constrained_successor_seed_restricted`
   - This allows the seed definition to reference boundary_resolution_set

3. **Updated membership lemmas** (SuccExistence.lean)
   - `mem_constrained_successor_seed_restricted_iff` now has 4 disjuncts
   - Added `boundary_resolution_set_subset_constrained_successor_seed_restricted` lemma
   - Fixed subset chain lemmas for the new 4-way union

4. **Updated downstream proofs** (SuccChainFMCS.lean)
   - `constrained_successor_seed_restricted_subset_deferralClosure`: added case for boundary_resolution_set
   - `augmented_seed_consistent`: simplified using absorption (boundary_resolution_set already in seed)
   - `constrained_successor_seed_restricted_consistent`: added case for boundary_resolution_set

**Build Status**: All files compile successfully with `lake build`

### Key Design Decision

The boundary_resolution_set definition retains the `chi ∈ u` condition:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | chi ∈ u ∧
         Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)}
```

This ensures seed consistency via the simple argument `seed ⊆ u` (since u is consistent).

An alternative design (without `chi ∈ u`) was considered but rejected because it complicates the consistency proof - we cannot prove the seed is a subset of u when boundary resolution formulas might not be in u.

## Remaining Work

### Phase 2: Prove Forward F-Coherence [IN PROGRESS]

The termination proof in `restricted_bounded_witness` still has sorry:

```lean
termination_by d
decreasing_by
  all_goals simp_wf
  all_goals sorry
```

**Why termination fails**: The recursive calls use depths that may not decrease:
- Case "d' > 1": depth is `d' + (n - 1)` which can be ≥ original d
- Deferred case: depth is `d' + n` which is definitely ≥ original d

**Proposed solutions** (from archived task 53 research):
1. Use lexicographic measure `(d, N - k)` where N bounds chain length
2. Use unresolved F-obligation count as measure
3. Extend chain elements to full MCS and use unrestricted bounded_witness

### Other Remaining Sorries

1. `neg_not_in_boundary_resolution_set` (line 1400) - marked sorry but NOT actually needed for main proofs
2. Termination proof in `restricted_bounded_witness` (line 2353) - the main blocker

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
  - Reorganized boundary_resolution_set section
  - Modified constrained_successor_seed_restricted definition
  - Updated subset lemmas

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Updated proofs using mem_constrained_successor_seed_restricted_iff
  - Added cases for boundary_resolution_set in subset proofs
  - Simplified augmented_seed_consistent

## Next Steps

1. Implement termination proof for `restricted_bounded_witness` using one of the proposed approaches
2. Once Phase 2 complete, proceed to Phase 3 (backward chain construction)
3. Eventually wire through to FrameConditions/Completeness.lean (Phase 5)
