# Implementation Summary: Task #864

**Last Updated**: 2026-02-10
**Duration**: ~4 hours (session 1) + ~2 hours (session 2) + ~1 hour (sessions 3-7) + ~30 min (session 8) + ~45 min (session 9) + ~45 min (sessions 10-12) + ~1 hour (session 13)
**Status**: PARTIAL (Phase 3 in progress, existential cases complete)

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

## Sorries Remaining (Updated Session 13)

| File | Session 12 | Session 13 | Description |
|------|-----------|-----------|-------------|
| RecursiveSeed.lean | 9 | 7 | 2 completed (neg-G, neg-H); 2 in freshTime, 1 in wellFormed, 3 universal, 1 generic imp |
| SeedCompletion.lean | 6 | 6 | MCS properties, family construction, BoxContent inclusion |
| SeedBMCS.lean | 8 | 8 | Modal coherence, temporal coherence, context wrapper |
| **Total** | **23** | **21** | Net reduction of 2 sorries |

### Session 13 Progress

1. **Completed neg-Box case** in `buildSeedAux_preserves_seedConsistent`:
   - Used explicit result tuple instead of let-binding to avoid type unification issues
   - Applied IH using createNewFamily_preserves_seedConsistent/wellFormed and formula_at_new_position

2. **Completed neg-G case** in `buildSeedAux_preserves_seedConsistent`:
   - Added `createNewTime_formula_at_new_position` helper lemma
   - Added `freshFutureTime_no_entry` and `freshPastTime_no_entry` stub lemmas (with sorry)
   - Full proof structure: addFormula -> freshFutureTime -> createNewTime -> IH

3. **Completed neg-H case** in `buildSeedAux_preserves_seedConsistent`:
   - Symmetric to neg-G using freshPastTime instead of freshFutureTime

4. **RecursiveSeed.lean sorries**: Reduced from 9 to 7

### Session 12 Progress (Previous)

- `createNewFamily_preserves_wellFormed`: COMPLETED
- `createNewTime_preserves_wellFormed`: COMPLETED
- First position-uniqueness case (i < idx) in `addFormula_preserves_wellFormed`: COMPLETED

### Current Blocking Issue Analysis

The 7 sorries in RecursiveSeed.lean decompose as follows:

| Sorry Location | Count | Resolution Path |
|----------------|-------|-----------------|
| `freshFutureTime_no_entry` | 1 | Foldl max/min reasoning |
| `freshPastTime_no_entry` | 1 | Foldl max/min reasoning |
| Position uniqueness (i > idx) | 1 | Needs strengthened SeedWellFormed invariant |
| Box/G/H operator cases | 3 | Need addToAllFamilies/FutureTimes/PastTimes preserves lemmas |
| Generic imp wildcard | 1 | Pattern matching with abstract variables |

**Required Resolution Approach:**
1. Prove foldl lemmas for freshTime functions (1-2 hours)
2. Strengthen SeedWellFormed to track no duplicate entry values (1 hour)
3. Prove addToAll* preserves lemmas for universal operators (4-6 hours)
4. Handle generic imp case with explicit case analysis or reflection (1 hour)

## Phase Status

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Formula Classification | COMPLETED | Data structures and classification |
| Phase 2: Recursive Seed Builder | COMPLETED | buildSeedAux with termination proof |
| Phase 3: Seed Consistency | IN PROGRESS | 7 sorries in buildSeedAux_preserves_seedConsistent |
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

1. **Complete freshTime no_entry lemmas** (foldl max/min reasoning)
2. **Complete universal operator cases** (Box/G/H) - requires addToAll* preserves lemmas
3. **Handle generic implication case** - explicit case analysis or reflection
4. Complete the 6 sorries in SeedCompletion.lean (depends on seedConsistent)
5. Complete the 8 sorries in SeedBMCS.lean (depends on SeedCompletion)
6. Update Completeness.lean to use construct_seed_bmcs
7. Remove/comment axioms after verification
8. Run full `lake build` and `#print axioms` verification

## Files Modified

- Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean (extended with new lemmas)
- specs/864_recursive_seed_henkin_model/plans/implementation-002.md (phase markers updated)

## Verification

- `lake build Bimodal` succeeds with 695 jobs
- All new files compile without errors (warnings for sorries only)
- Classification tests pass (example proofs verify FormulaClass)
- Seed builder tests show correct family/time creation
