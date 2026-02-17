# Handoff: Task 880 Phase 2 - Supporting Lemmas Analysis

**Session ID**: sess_1771004285_554061
**Created**: 2026-02-13
**Plan Version**: v005
**Current State**: Phase 2 Partial - Gap Identified in Proof Strategy

## Immediate Next Action

**FIX: Modify buildSeedAux to propagate G psi / H psi to future/past times**

Location: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`, lines 505-517

Current (only propagates psi):
```lean
| Formula.all_future psi, famIdx, timeIdx, seed =>
    let phi := Formula.all_future psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi  -- Only psi
    buildSeedAux psi famIdx timeIdx seed3
```

Fix (also propagate G psi):
```lean
| Formula.all_future psi, famIdx, timeIdx, seed =>
    let phi := Formula.all_future psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
    let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi  -- ADD: G psi to futures
    buildSeedAux psi famIdx timeIdx seed4
```

Similar fix needed for H psi case (lines 512-517).

## What Was Accomplished

1. **Added supporting lemma signatures** (lines 2763-2816):
   - `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`
   - `addToAllPastTimes_preserves_seedConsistent_with_hpsi`

2. **Documented the proof strategy**:
   - Use temp_t_future (G psi -> psi) to derive psi at future entries
   - Use temp_t_past (H psi -> psi) to derive psi at past entries
   - These axioms enable derivability needed for `addFormula_preserves_consistent`

3. **Identified critical gap**:
   - The lemmas require G psi / H psi to be at future/past entries
   - Current construction does NOT propagate G psi / H psi
   - Only psi is propagated, leaving no derivation source

## Key Finding: Construction Gap

The proof strategy from Phase 1 handoff relies on:
```
G psi at timeIdx implies psi is derivable at all future times via:
1. temp_4: G psi -> G(G psi) [G psi derivable at all future times]
2. temp_t: G psi -> psi [at each future time, psi derivable from G psi]
```

But this ONLY works if G psi is PRESENT at future entries. Currently:
- buildSeedAux adds G psi at currentTime
- buildSeedAux adds psi at currentTime
- buildSeedAux adds psi (NOT G psi) at future times

Without G psi at future entries, we cannot derive psi there.

## Semantic Justification for the Fix

If G psi holds at time t, it should also hold at all t' > t:
- G psi means "at all times >= t, psi holds"
- At t' > t, we still have "at all times >= t', psi holds"
- So G psi should hold at t' as well

The current construction is semantically incomplete. It adds psi (which is correct) but misses G psi (which should also be added).

## Impact Analysis

### Affected Constructs
1. `buildSeedAux` positive G case (lines 505-511)
2. `buildSeedAux` positive H case (lines 512-517)
3. Possibly other places that rely on temporal propagation

### Expected Changes
1. Add `seed4 := seed3.addToAllFutureTimes ... phi` in G case
2. Add `seed4 := seed3.addToAllPastTimes ... phi` in H case
3. Update proof to use seed4 instead of seed3
4. Well-formedness and consistency proofs need extension

### Proof Updates
- `addToAllFutureTimes_preserves_wellFormed` already exists
- `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` applies (with sorry)
- Need to prove the sorry using temp_t_future derivation

## Current State of Files

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

**New Sorries Added** (Phase 2):
- Line 2794: `addToAllFutureTimes_preserves_seedConsistent_with_gpsi`
- Line 2815: `addToAllPastTimes_preserves_seedConsistent_with_hpsi`

**Existing Sorries** (from before):
- Lines 3908, 3993, 4074, 4158, 4224, 4288 (original 6 sorries)

**Total**: 8 sorries (6 original + 2 new supporting lemmas)

## Recommended Path Forward

1. **Modify buildSeedAux** to propagate G psi / H psi (~2 hours)
   - Lines 505-517
   - Create seed4 with additional propagation
   - Update recursion to use seed4

2. **Update proof for G/H cases** (~2 hours)
   - Use the new supporting lemmas
   - Prove the supporting lemmas (fill in sorries)

3. **Re-assess sorries** after construction fix
   - The original 6 sorries might become provable with weakened hypotheses
   - The construction fix provides the derivability needed

## References

- Plan v005: `specs/880_augmented_extension_seed_approach/plans/implementation-005.md`
- Phase 1 handoff: `specs/880_augmented_extension_seed_approach/handoffs/phase-1-handoff-20260213.md`
- Target file: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- Added lemmas: lines 2763-2816
