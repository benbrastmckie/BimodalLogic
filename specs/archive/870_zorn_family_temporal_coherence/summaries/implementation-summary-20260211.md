# Implementation Summary: Task #870 (Revised)

**Task**: Zorn-based family selection for temporal coherence
**Status**: PARTIAL (Restructured per v002 plan)
**Completed**: 2026-02-11
**Session**: sess_1770855612_d4c54f

## Overview

This task implements a Zorn-based construction of `IndexedMCSFamily Int` with temporal coherence. The implementation follows the revised plan v002, which addresses the three root causes identified in research-003.md:

1. **Base Family Impossibility**: Removed F/P from structure (singleton domain works with vacuous G/H)
2. **Zorn Type Mismatch**: Added `Preorder GHCoherentPartialFamily` instance
3. **4-Axiom Gap**: Isolated to seed consistency, cleaner proof path

## Changes Made

### Phase 1: Restructure CoherentPartialFamily [COMPLETED]

- Renamed structure to `GHCoherentPartialFamily` (only G/H coherence)
- Removed `forward_F` and `backward_P` fields entirely
- Added `instance : Preorder GHCoherentPartialFamily` for Mathlib Zorn integration
- Added backward compatibility alias `CoherentPartialFamily := GHCoherentPartialFamily`

### Phase 2: Simplify Base Family [COMPLETED]

- `buildBaseFamily` now compiles WITHOUT sorry
- G/H coherence for singleton domain {0} is vacuously satisfied (omega tactic proves 0 < 0 false)
- Eliminated 2 sorries from original implementation

### Phase 3: Extension Seed with F/P Obligations [PARTIAL]

- Added `FObligations` and `PObligations` definitions for extension seed
- Extended `extensionSeed` to include F/P obligation formulas
- Added helper lemmas for seed membership
- **3 sorries remain** in `extensionSeed_consistent`:
  - Cross-sign consistency (line 512)
  - Pure past case (line 519)
  - Pure future case (line 526)

### Phase 4: Zorn Application [COMPLETED]

- Used `zorn_le_nonempty₀` from Mathlib with Preorder instance
- `zorn_maximal_exists` theorem proven WITHOUT sorry
- `maximalCoherentFamily` definition via `choose`
- `maximalCoherentFamily_extends` and `maximalCoherentFamily_maximal` lemmas proven

### Phase 5: Maximality Implies Totality [PARTIAL]

- Added `extendFamily` definition for extending to new time
- Added `extendFamily_strictly_extends` lemma
- **3 sorries remain**:
  - `extendFamily` forward_G from new time (line 771)
  - `extendFamily` backward_H from new time (line 802)
  - `maximal_implies_total` final step (line 863)

### Phase 6: F/P Recovery for Total Family [PARTIAL]

- Added `total_family_forward_F` and `total_family_backward_P` stubs
- Main theorem `temporal_coherent_family_exists_zorn` structured correctly
- **2 sorries remain** for F/P recovery (lines 887, 896)

## Technical Debt

| Location | Count | Description |
|----------|-------|-------------|
| `extensionSeed_consistent` | 3 | Cross-sign and pure past/future cases |
| `extendFamily` | 2 | G/H propagation from new time |
| `maximal_implies_total` | 1 | Final extension construction |
| `total_family_forward_F` | 1 | F witness existence |
| `total_family_backward_P` | 1 | P witness existence |
| **Total** | **8** | |

## Comparison: v001 vs v002

| Metric | After v001 | After v002 (Current) |
|--------|------------|----------------------|
| Structure fields | forward_F, backward_P, forward_G, backward_H | forward_G, backward_H only |
| Preorder instance | No | Yes |
| Base family sorries | 2 (unsolvable) | 0 (solved via vacuous G/H) |
| Zorn application | Custom le, sorry | zorn_le_nonempty₀, no sorry |
| Total sorries | 8 | 8 |

Key improvement: The 2 base family sorries (fundamentally unsolvable for singleton domain) were eliminated. New sorries are in different locations (extension, F/P recovery) and are theoretically solvable.

## Verification

- `lake build Bimodal.Metalogic.Bundle.ZornFamily` - SUCCESS with warnings
- All structure definitions compile
- Chain upper bound lemma fully proven
- Zorn application works correctly

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Complete restructure (~950 lines)

## Remaining Work

The remaining 8 sorries require:

1. **4-axiom propagation**: Use `temp_4_future` (G phi -> GG phi) and `temp_4_past` (H phi -> HH phi)
2. **Seed membership tracking**: Prove that formulas in extension seed propagate to Lindenbaum MCS
3. **F/P recovery**: Show that total (domain = univ) families automatically satisfy F/P

## Recommendations

1. **Seed consistency**: Focus on proving cross-sign case using 4-axiom transitivity
2. **Extension coherence**: Add preconditions for G/H propagation from mcs_t back to F
3. **F/P recovery**: Key insight is that witness t+1 is always in domain for total families
4. **Integration**: Once complete, replace DovetailingChain.lean sorries with Zorn-based construction
