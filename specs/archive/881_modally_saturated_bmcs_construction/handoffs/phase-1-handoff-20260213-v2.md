# Handoff: Task 881 Phase 1 (Session 2)

**Date**: 2026-02-13
**Session**: sess_1771031369_96dacd
**Agent**: lean-implementation-agent

## Immediate Next Action

Prove `addFormula_preserves_mem_diff_position` lemma in RecursiveSeed.lean (line 4726):
```lean
private lemma addFormula_preserves_mem_diff_position
    (seed : ModelSeed) (famIdx addFam : Nat) (t addTime : Int) (phi psi : Formula) (ty : SeedEntryType)
    (h_diff : famIdx ≠ addFam ∨ t ≠ addTime)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.addFormula addFam addTime psi ty).getFormulas famIdx t
```

This is the key lemma blocking all the foldl preservation proofs.

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Build status**: Succeeds with 23 sorries (was 5 originally, 18 added)
**Lines 4715-4810**: New helper lemmas section

### Infrastructure Added

1. `addFormula_preserves_mem_diff_position` (line 4726) - SORRY
   - Key lemma: generalizes existing `_diff_fam` and `_diff_time` lemmas
   - Blocked because existing lemmas require query time = add time

2. `foldl_addFormula_preserves_mem_general` (line 4743) - PROVEN using above
   - For time-list folds (used by addToAllFutureTimes/PastTimes)

3. `foldl_addFormula_fam_preserves_mem_general` (line 4761) - PROVEN using above
   - For family-list folds (used by addToAllFamilies)

4. `addToAllFamilies_preserves_mem_getFormulas` (line 4779) - PROVEN
5. `addToAllPastTimes_preserves_mem_getFormulas` (line 4790) - PROVEN
6. `addToAllFutureTimes_preserves_mem_getFormulas` (line 4802) - PROVEN

### Remaining Phase 1 Sorries

Lines after 5000 have the original sorries that depend on `buildSeedAux_preserves_getFormulas` which in turn depends on the lemmas above.

## Key Insight

The existing lemmas in the file have this limitation:
- `addFormula_preserves_getFormulas_diff_fam`: `(seed.addFormula famIdx' timeIdx phi ty).getFormulas famIdx timeIdx = ...`
  - Note: query time = add time (`timeIdx`)
- `addFormula_preserves_getFormulas_diff_time`: `(seed.addFormula famIdx timeIdx' phi ty).getFormulas famIdx timeIdx = ...`
  - Note: query family = add family (`famIdx`)

We need: query position (famIdx, t) can be COMPLETELY different from add position (addFam, addTime).

## Proof Strategy for `addFormula_preserves_mem_diff_position`

The proof should follow this structure:
1. Unfold `addFormula` and `getFormulas`
2. Case split on whether entry exists at (addFam, addTime)
   - If `findIdx? = none`: new entry appended, show it doesn't match (famIdx, t)
   - If `findIdx? = some idx`: entry modified at idx, show find? for (famIdx, t) unchanged
3. Key observation: `modify` at index idx doesn't change familyIdx/timeIdx fields
   - So find? with predicate on (famIdx, t) returns same entry at same index

The proof is similar to existing `addFormula_preserves_getFormulas_diff_fam` but needs to handle disjoint positions.

## What NOT to Try

- Don't try to use `rw [addFormula_preserves_getFormulas_diff_fam ...]` when query time ≠ add time
- Don't try to use `rw [addFormula_preserves_getFormulas_diff_time ...]` when query family ≠ add family

## References

- Plan: `specs/881_modally_saturated_bmcs_construction/plans/implementation-004.md`
- Previous handoff: `specs/881_modally_saturated_bmcs_construction/handoffs/phase-1-handoff-20260213.md`
- Existing lemmas around line 3154-3370 in RecursiveSeed.lean
