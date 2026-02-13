# Handoff: Task 880 Phase 1 Analysis (FINAL)

**Session ID**: sess_1771002787_b0345e
**Created**: 2026-02-13
**Plan Version**: v005
**Current State**: Phase 1 Complete - Clear Path Forward Identified

## Immediate Next Action

**PROVE `addToAllFutureTimes_preserves_seedConsistent`**

Location: Add this lemma near line 2744 (after `addToAllFutureTimes_preserves_wellFormed`)

```lean
/--
addToAllFutureTimes preserves seed consistency.
Key insight: G psi at timeIdx implies psi is derivable at all future times via:
1. temp_4: G psi -> G(G psi) [G psi derivable at all future times]
2. temp_t: G psi -> psi [at each future time, psi derivable from G psi]
-/
theorem addToAllFutureTimes_preserves_seedConsistent
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_gpsi_in : psi.all_future ∈ seed.getFormulas famIdx currentTime) :
    SeedConsistent (seed.addToAllFutureTimes famIdx currentTime psi)
```

**Proof Strategy**:
1. Unfold `addToAllFutureTimes` - it's a fold over future time entries
2. For each future time t' > currentTime, need to show adding psi preserves consistency
3. Build derivation: `[G psi] ⊢ G(G psi)` via temp_4, then `[G(G psi)] ⊢ G psi` at t', then `[G psi] ⊢ psi` via temp_t
4. Use `addFormula_preserves_consistent` at each step

**CRITICAL**: Also need `addToAllPastTimes_preserves_seedConsistent` (same structure, different axioms).

## What Was Tried and Failed

**Case-split approach** (Option A from research-007.md):
- Result: PARTIAL FAILURE
- What worked: Non-modal cases (atom, bot, imp) proved directly without IH
- What failed: Modal cases (box, all_future, all_past) still need IH with false hypotheses
- Net effect: Increased sorry count from 6 to 8
- Conclusion: DO NOT retry this approach

## Current State

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Backup**: `RecursiveSeed.lean.backup-v004`
**Theorem**: `buildSeedAux_preserves_seedConsistent` (line 3341)
**Sorry Count**: 6 at lines 3908, 3993, 4074, 4158, 4224, 4288

## Key Findings Summary

1. **Sorries claim FALSE statements** - can't be proven as-is
2. **Positive G/H cases unreachable from neg paths** - false hypotheses are never used
3. **Plan v005 gap**: Needs `addToAllFutureTimes/PastTimes_preserves_seedConsistent` lemmas
4. **temp_4 axiom enables proof**: `G psi -> G(G psi)` allows deriving psi at future times

## Recommended Path Forward

1. Prove `addToAllFutureTimes_preserves_seedConsistent` (~4-6 hours)
2. Prove `addToAllPastTimes_preserves_seedConsistent` (~4-6 hours)
3. Modify positive G/H cases to use these lemmas instead of no-op trick
4. Weaken theorem hypotheses as plan v005 suggests
5. Update IH calls in neg cases with weaker hypotheses (which ARE provable)

## References

- Plan: `specs/880_augmented_extension_seed_approach/plans/implementation-005.md`
- Research: `specs/880_augmented_extension_seed_approach/reports/research-007.md`
- Progress: `specs/880_augmented_extension_seed_approach/progress/phase-1-progress.json`
- Target file: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
