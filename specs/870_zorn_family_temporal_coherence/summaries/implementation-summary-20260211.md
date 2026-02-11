# Implementation Summary: Task #870

**Task**: Zorn-based family selection for temporal coherence
**Status**: PARTIAL
**Completed**: 2026-02-11
**Session**: sess_1770851482_8b4a31

## Overview

This task aimed to use Zorn's lemma to construct an `IndexedMCSFamily Int` with guaranteed cross-sign temporal coherence (forward_G, backward_H, forward_F, backward_P), bypassing the chain construction limitations in DovetailingChain.lean that have 4 sorries.

## Changes Made

Created `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` with:

### Phase 1: CoherentPartialFamily Structure (COMPLETE)
- Defined `CoherentPartialFamily` structure with:
  - `domain`: Partial subset of Int
  - `mcs`: MCS assignment function
  - `is_mcs`: Maximal consistency proof
  - `forward_G`, `backward_H`: Universal temporal propagation
  - `forward_F`, `backward_P`: Existential witness properties
- Defined partial order `CoherentPartialFamily.le` for domain extension
- Proved reflexivity, transitivity, and antisymmetry lemmas

### Phase 2: Chain Upper Bound Lemma (COMPLETE)
- Proved `chain_mcs_unique`: MCS uniqueness at overlapping times
- Constructed `chainUpperBound`: union of chain domains with consistent MCS
- Proved all coherence properties inherited (forward_G, backward_H, forward_F, backward_P)
- Theorem `coherent_chain_has_upper_bound`: key prerequisite for Zorn

### Phase 3: Extension Seed Consistency (PARTIAL - 3 sorries)
- Defined `extensionSeed`: combines GContent from past, HContent from future
- Proved helper lemmas: `GContent_consistent`, `HContent_consistent`
- Theorem `extensionSeed_consistent` has 3 sorries:
  1. Cross-sign case (both past and future times)
  2. Pure G-content case
  3. Pure H-content case

### Phase 4: Zorn Application (PARTIAL - 5 sorries)
- Defined `CoherentExtensions`: set of extending families
- Defined `buildBaseFamily`: base family from consistent context (2 sorries for F/P)
- Defined `maximalCoherentFamily`: structure for Zorn result
- Theorem `maximal_coherent_partial_family_exists` stated but depends on Zorn sorries

## Technical Debt

| Location | Sorry | Reason |
|----------|-------|--------|
| `extensionSeed_consistent` | 3 | Cross-sign and pure-content cases need 4-axiom propagation |
| `maximalCoherentFamily` | 1 | Classical.choice placeholder for Zorn application |
| `maximalCoherentFamily_extends` | 1 | Zorn construction property |
| `maximalCoherentFamily_maximal` | 1 | Zorn construction property |
| `buildBaseFamily.forward_F` | 1 | Singleton domain cannot satisfy F witnesses |
| `buildBaseFamily.backward_P` | 1 | Singleton domain cannot satisfy P witnesses |

**Total**: 8 sorries in ZornFamily.lean

## Blocked Phases

Phases 5 (Maximality Implies Totality) and 6 (Final Construction) are blocked pending:
1. Completion of Zorn application sorries
2. Resolution of extension seed consistency
3. Alternative approach for base family F/P (temporal saturation or larger initial domain)

## Verification

- `lake build Bimodal` succeeds with sorry warnings
- All structure definitions compile
- Chain upper bound lemma fully proven
- File integrates with existing import structure

## Architecture Notes

The Zorn approach has the right conceptual structure to solve the cross-sign problem:
1. Build partial families incrementally
2. Use chain upper bounds to preserve coherence
3. Maximality should force totality (domain = Set.univ)

However, the technical details require:
- Proper Zorn lemma type alignment (custom partial order vs Set inclusion)
- 4-axiom propagation for seed consistency
- Alternative base family construction (not singleton domain)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` (new, 700+ lines)

## Recommendations

1. **Zorn Type Alignment**: Use `zorn_le_nonempty₀` with Preorder instance on CoherentPartialFamily
2. **Seed Consistency**: Implement 4-axiom propagation (G phi -> GG phi, H phi -> HH phi)
3. **Base Family**: Use dovetailing construction for initial domain, not singleton {0}
4. **Integration**: Once complete, replace DovetailingChain sorries with Zorn-based construction
