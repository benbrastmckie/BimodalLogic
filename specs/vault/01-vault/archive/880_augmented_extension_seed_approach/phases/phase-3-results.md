# Phase 3 Results: Update Call Sites

**Task**: 880 - Augmented Extension Seed Approach
**Phase**: 3 of 4
**Status**: BLOCKED - Prerequisite Not Met

## Summary

Phase 3 cannot proceed as originally planned because Phase 2 did NOT implement the expected changes. The plan v005 called for Phase 2 to **restructure the theorem signature** with weaker hypotheses, but Phase 2 instead **fixed the construction** by adding `seed4` propagation while keeping the original hypotheses.

## Current State Analysis

### Theorem Signature (Unchanged)

The theorem `buildSeedAux_preserves_seedConsistent` still has the original hypotheses:

```lean
theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : seed.familyIndices = [famIdx])    -- ORIGINAL
    (h_single_time : seed.timeIndices famIdx = [timeIdx]) :  -- ORIGINAL
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed)
```

Plan v005 expected Phase 2 to change these to:
```lean
    (h_family_valid : famIdx < seed.nextFamilyIdx)        -- PROPOSED
    (h_entry_exists : seed.findEntry famIdx timeIdx <> none)  -- PROPOSED
```

### Remaining Sorries

The file contains 8 sorries, 6 of which are in `buildSeedAux_preserves_seedConsistent`:

| Line | Type | Issue |
|------|------|-------|
| 2809 | Supporting lemma | `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` |
| 2826 | Supporting lemma | `addToAllPastTimes_preserves_seedConsistent_with_hpsi` |
| 4005 | FALSE claim | `result.1.familyIndices = [result.2]` after createNewFamily |
| 4090 | FALSE claim | Same pattern in all_future case |
| 4171 | FALSE claim | Same pattern |
| 4255 | FALSE claim | Same pattern |
| 4321 | FALSE claim | Same pattern |
| 4385 | FALSE claim | Same pattern |

### "Dead Code" Claims Are Incorrect

The comments at lines 4005 etc. claim these are "DEAD CODE" because "inner.neg is imp". This is **only partially true**:

1. If `inner = atom "p"`, then `inner.neg = (atom "p").imp bot` - matches generic imp case (terminal)
2. If `inner = box q`, then `inner.neg = (box q).imp bot` - matches `Formula.imp (Formula.box phi) Formula.bot` case (creates new family!)

So the recursion CAN hit Box/G/H cases when there are nested operators.

### Call Site Status

The single call site at line 4472 in `seedConsistent` works correctly with the current hypotheses:

```lean
theorem seedConsistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeed phi) := by
  unfold buildSeed
  apply buildSeedAux_preserves_seedConsistent
  ...
  · exact initial_familyIndices_eq phi  -- provides h_single_family
  · exact initial_timeIndices_eq phi    -- provides h_single_time
```

The initial seed satisfies `h_single_family` and `h_single_time`, so no updates needed here.

## Recommendations

### Option 1: Resume from Phase 2 (Recommended)

Phase 2 needs to be re-executed with the original plan:

1. Change theorem signature to use weaker hypotheses
2. Update proof body to use `h_family_valid` and `h_entry_exists`
3. Prove supporting lemmas (`createNewFamily_preserves_family_valid`, etc.)
4. Eliminate the 6 false-claim sorries

Then Phase 3 can proceed to update call sites (which should be straightforward since weaker hypotheses are easier to satisfy).

### Option 2: Accept Current State

If the "dead code" claim is accurate for all practical formula structures encountered, the current implementation may be functionally correct despite the sorries. However, this is fragile and should be documented.

### Option 3: Prove Dead Code Property

Add lemmas proving that for the specific formula structure after `createNewFamily`/`createNewTime`, the recursive path through `buildSeedAux` never reaches the cases where `h_single_family` is actually used.

## Phase 3 Action Taken

Given that the prerequisite (theorem signature change) was not completed, Phase 3 marks itself as **BLOCKED** and documents the gap for the orchestrator to address.

## Files Examined

- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Main implementation file
- `specs/880_augmented_extension_seed_approach/plans/implementation-005.md` - Original plan
- `specs/880_augmented_extension_seed_approach/phases/phase-2-results.md` - Phase 2 report

## Build Status

- `lake build Bimodal` succeeds (with sorry warnings)
- No compilation errors
- 8 sorries remain in RecursiveSeed.lean
