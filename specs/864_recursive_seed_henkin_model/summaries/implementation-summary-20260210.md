# Implementation Summary: Task #864

**Last Updated**: 2026-02-10
**Duration**: ~4 hours (session 1) + ~2 hours (session 2) + ~1 hour (sessions 3-7)
**Status**: PARTIAL (Phase 3 in progress, blocking issue identified)

## Overview

Implemented recursive seed construction for Henkin model completeness in TM bimodal logic. This construction bypasses task 843's cross-sign temporal propagation blockage by placing ALL temporal witnesses in the seed BEFORE Lindenbaum extension.

## Changes Made

### New Files Created

1. **RecursiveSeed.lean** (Theories/Bimodal/Metalogic/Bundle/)
   - `FormulaClass`: Classification of formulas by main operator
   - `SeedEntryType`: Distinguishes temporal/modal witnesses from universal targets
   - `SeedEntry`, `ModelSeed`: Data structures for seed construction
   - `buildSeedAux`, `buildSeed`: Recursive seed builder with termination proof
   - Key consistency lemmas (with sorries)

2. **SeedCompletion.lean** (Theories/Bimodal/Metalogic/Bundle/)
   - `extendSeedEntry`: Extend seed entry to MCS via Lindenbaum
   - `seedFamilyMCS`: MCS at each seed position
   - `buildFamilyFromSeed`: Build IndexedMCSFamily from seed
   - Cross-sign handling documentation

3. **SeedBMCS.lean** (Theories/Bimodal/Metalogic/Bundle/)
   - `buildSeedBMCS`: Main BMCS construction entry point
   - Modal coherence theorems (modal_forward, modal_backward)
   - Temporal coherence theorems (forward_G, backward_H)
   - `construct_seed_bmcs`: Wrapper for Completeness.lean compatibility
   - Task 843 blockage resolution documentation

## Key Achievements

1. **Architecture Design**: Formula-driven seed construction that mirrors BMCS semantics:
   - Modal witnesses (neg Box phi) create NEW families
   - Temporal witnesses (neg G phi, neg H phi) create NEW times in SAME family

2. **Termination Proof**: buildSeedAux terminates using Formula.complexity as decreasing measure

3. **Cross-Sign Resolution**: Documented how seed construction avoids the problem:
   - Seed formulas: Pre-placed before Lindenbaum, no propagation needed
   - Lindenbaum-added: 4-axiom (G phi -> G(G phi)) propagates through time 0

4. **Build Verification**: All three files compile successfully; full Bimodal module builds

## Sorries Remaining (Updated Session 7)

| File | Session 2 | Session 7 | Description |
|------|-----------|-----------|-------------|
| RecursiveSeed.lean | 4 | 1 | `buildSeedAux_preserves_seedConsistent` (blocking) |
| SeedCompletion.lean | 6 | 6 | MCS properties, family construction, BoxContent inclusion |
| SeedBMCS.lean | 8 | 8 | Modal coherence, temporal coherence, context wrapper |
| **Total** | **18** | **15** | Reduced by 3 |

### Session 7 Progress

1. **Proved `createNewTime_preserves_seedConsistent`**: Creating a new time entry with a consistent formula preserves seed consistency
2. **Proved `createNewFamily_preserves_seedConsistent`**: Creating a new family entry with a consistent formula preserves seed consistency
3. **Code cleanup**: Removed 10+ intermediate sorries, simplified proof structure
4. **Identified blocking issue**: The theorem statement needs a stronger invariant (see below)

### Blocking Issue Analysis

The remaining sorry in `buildSeedAux_preserves_seedConsistent` is blocked because the hypothesis:

```lean
h_pos_cons : ∀ ψ ∈ seed.getFormulas famIdx timeIdx, SetConsistent {ψ}
```

Only states that individual formulas are consistent as singletons. This is insufficient because:
- Adding a formula to an existing entry requires proving **mutual compatibility**
- Example: {p} is consistent and {neg p} is consistent, but {p, neg p} is NOT

**Required invariant** (for future work):
1. The seed is consistent (SeedConsistent)
2. The formula being processed (phi) is IN the current position's formula set
3. All formulas at current position are derived from the same root formula (ensuring compatibility)

### Session 2 Completed Proofs

1. **`diamond_box_interaction`** (KEY LEMMA) - ~170 lines
   - Proves: If Box phi and neg(Box psi) are jointly consistent in S, then {phi, neg psi} is consistent
   - Uses: double negation elimination, necessitation, modal K distribution
   - This is the mathematical core for seed consistency

2. **`addFormula_preserves_consistent_of_theorem`** - ~60 lines
   - Proves: Adding a theorem to a consistent set preserves consistency
   - Uses: deduction theorem, modus ponens, cut elimination pattern

## Phase Status

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Formula Classification | COMPLETED | Data structures and classification |
| Phase 2: Recursive Seed Builder | COMPLETED | buildSeedAux with termination proof |
| Phase 3: Seed Consistency | IN PROGRESS | 1 sorry (seedConsistent) - key lemmas done |
| Phase 4: Seed Completion | PARTIAL | 6 sorries in MCS construction |
| Phase 5: BMCS Assembly | PARTIAL | 8 sorries in coherence proofs |
| Phase 6: Verification | PARTIAL | Build verified, documentation added |

## Relationship to Task 843

This implementation supersedes task 843's Phase 1 (interleaved chain construction):

| Aspect | Task 843 (BLOCKED) | Task 864 (This Implementation) |
|--------|-------------------|------------------------------|
| Architecture | Two-chain (forward/backward) | Single seed with multiple families |
| Witness placement | During chain building | In seed BEFORE Lindenbaum |
| Cross-sign temporal | Cannot work | Avoided by pre-placement |
| Cross-sign Lindenbaum | Not addressed | 4-axiom through time 0 |

The 4 sorries in DovetailingChain.lean are no longer on the critical path.

## Axiom Elimination Status

Target axioms for elimination (not yet removed pending sorry resolution):
- `singleFamily_modal_backward_axiom` (Construction.lean): Replaced by multi-family modal_backward
- `temporal_coherent_family_exists` (TemporalCoherentConstruction.lean): Replaced by seed construction

## Next Steps

1. **Complete `seedConsistent`** - The remaining sorry in RecursiveSeed.lean
   - Requires induction on formula complexity
   - Uses the completed `diamond_box_interaction` lemma
   - Proof sketch and invariant structure added

2. Complete the 6 sorries in SeedCompletion.lean (depends on seedConsistent)
3. Complete the 8 sorries in SeedBMCS.lean (depends on SeedCompletion)
4. Update Completeness.lean to use construct_seed_bmcs
5. Remove/comment axioms after verification
6. Run full `lake build` and `#print axioms` verification

## Files Modified

- specs/864_recursive_seed_henkin_model/plans/implementation-002.md (phase markers updated)

## Verification

- `lake build Bimodal` succeeds with 998 jobs
- All new files compile without errors (warnings for sorries only)
- Classification tests pass (example proofs verify FormulaClass)
- Seed builder tests show correct family/time creation
