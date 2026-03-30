# Implementation Summary: Sorry Closure Attempt for F-Preserving Construction

**Task**: 69 - close_z_chain_forward_f
**Session**: sess_1774898477_ec7e01
**Date**: 2026-03-30
**Status**: PARTIAL

## Overview

Attempted to close 2 remaining sorries from the F-preserving seeds implementation. Made partial progress but encountered fundamental difficulties in both proofs.

## Phase Summary

### Phase 1: Close Sorry 2 (Edge Case) - PARTIAL

**Goal**: Handle `phi ∈ chain(t)` case in `omega_F_preserving_forward_F_resolution`

**Progress**:
- Added case split on `G(phi) ∈ chain(t)`
- **Closed**: The `G(phi) ∈ chain(t)` case now derives contradiction via G-propagation + T-axiom
- **Blocked**: The `G(phi) ∉ chain(t)` case remains sorry

**Technical Analysis**:
When `phi ∈ chain(t)`, `F(phi) ∈ chain(t)`, and `G(phi) ∉ chain(t)`:
- phi is true at t but not necessarily at future times
- F(phi) is "resolved" at t since phi is there, so F(phi) may not persist to chain(n0)
- The strict `s > t` requirement cannot be satisfied in this case
- This is a semantic corner case where F(phi) is satisfied at t itself

**Location**: `UltrafilterChain.lean:4340` (approximately)

### Phase 2: Helper Lemmas - COMPLETED

**Added lemmas**:
1. `G_disjunction_in_mcs_elim`: If a disjunction of G-formulas is in an MCS, at least one G-formula is in the MCS
2. `G_of_disjunction_in_mcs_elim`: Same for G of a disjunction

**Location**: `UltrafilterChain.lean:1212-1262`

### Phase 3: Close Sorry 1 (F-Preserving Consistency) - BLOCKED

**Goal**: Prove `f_preserving_seed_consistent` via iterated F-extraction

**Analysis**: The proof is blocked by a fundamental difficulty:
- After extracting all F-formulas via deduction theorem, the resulting disjunction may include `neg(phi)` (not a G-formula)
- When `neg(phi) ∈ M` is the only outcome from disjunction_elim, no contradiction arises
- `neg(phi) ∈ M` and `F(phi) ∈ M` are semantically compatible (phi false now, true later)
- However, `neg(phi) ∉ f_preserving_seed` for generic phi, so the inconsistent pair `{phi, neg(phi)}` is not a subset of the seed

The theorem IS mathematically valid, but the formal proof requires a more sophisticated inductive argument that tracks the relationship between derivable formulas and seed membership.

**Location**: `UltrafilterChain.lean:1468` (approximately)

### Phase 4: Final Verification - PARTIAL

**Build**: Passes with warnings
**Sorry count**: 36 (increased by 1 from baseline 35 due to case split)
**New axioms**: None introduced

## Artifacts Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Added helper lemmas: `G_disjunction_in_mcs_elim`, `G_of_disjunction_in_mcs_elim`
  - Added case split in `omega_F_preserving_forward_F_resolution` (partial closure)
  - Improved documentation on remaining sorries

## Technical Gaps Identified

### Gap 1: Strict Temporal Coherence vs Semantic F-Satisfaction

The temporal coherence definition requires `s > t` for F-resolution, but semantically F(phi) can be satisfied at t itself when phi is already true. Options:
1. Modify temporal coherence definition to allow `s >= t`
2. Add construction that ensures phi reappears at some `s > t`

### Gap 2: G-Lift with Mixed Contexts

The G-lift argument requires all context elements to have their G in M. When the context includes phi (which may not have G(phi) in M) or F-formulas, the argument breaks down. The solution requires extracting these elements first, but this leads to the `neg(phi) ∈ M` dead end.

## Recommendations

1. **Consider weakening temporal coherence**: Allow `phi ∈ fam.mcs t OR exists s > t` instead of strictly `exists s > t`

2. **Alternative construction**: Modify F-preserving seed to include phi in all witnesses when phi is the "target" formula

3. **Separate theorems**: Create a "weak" version for `s >= t` that's provable, and a "strict" version with additional hypotheses

## Dependencies Blocked

The following theorems have sorries that depend on these proofs:
- `Z_chain_forward_F'`
- `omega_forward_F_bounded_persistence`
- `bfmcs_from_mcs_temporally_coherent`
- `bundle_validity_implies_provability`
