# Implementation Summary: Task #70 - Bidirectional Witness (BLOCKED)

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Status**: BLOCKED at Phase 2
**Plan**: plans/04_bidirectional-witness.md (v4)

## Overview

Implementation of the bidirectional temporal witness construction was blocked at Phase 2 due to a fundamental flaw discovered in the plan's proof strategy.

## Completed Phases

### Phase 0: Archive Dead Code [COMPLETED]
- Added ARCHIVED comments to CoherentZChain (6 unfixable sorries)
- Documented f_preserving_seed_consistent sub-case A as mathematically unprovable
- Updated ROADMAP.md with temporal coherence resolution strategy

### Phase 1: Define Bidirectional Seed [COMPLETED]
- Defined `bidirectional_temporal_box_seed` = G_theory U H_theory U box_theory
- Proved subset lemmas (G_theory_subset_bidirectional_seed, etc.)
- Proved `bidirectional_seed_subset_mcs`: bidirectional_seed M subset M

## Blocking Issue: Phase 2

### The Flaw

The plan claims:
> "{phi} U M is consistent when F(phi) in M (standard temporal witness argument)"

This claim is FALSE.

The correct statement is:
> "{phi} U temporal_box_seed(M) is consistent when F(phi) in M"

The proof of `temporal_theory_witness_consistent` uses **G-lift**: if L subset seed derives neg(phi), then G-lifting gives G(neg(phi)) in M, contradicting F(phi) in M.

This requires ALL seed elements to be G-liftable (i.e., G(x) in M for all x in seed).

### Why H_theory Is Not G-Liftable

H_theory consists of H(a) where H(a) in M. For G-liftability, we need G(H(a)) in M.

**Semantic Analysis:**
- H(a) at time t means: for all s <= t, a holds at s
- G(H(a)) at time t means: for all r >= t, for all s <= r, a holds at s
- This is equivalent to: for all s, a holds at s (i.e., always(a))

**Conclusion:** H(a) does NOT imply G(H(a)). In fact, G(H(a)) is semantically equivalent to always(a), which is much stronger than H(a).

Therefore, H(a) -> G(H(a)) is NOT derivable from our axioms (it's not even semantically valid).

### Impact on Bidirectional Construction

Without H_theory being G-liftable, the bidirectional_seed_consistent proof cannot use the G-lift argument. The sorries at lines 3864 and 4271 reflect this gap.

## Possible Resolutions

1. **Derive H(a) -> G(H(a))**: Unlikely given semantic analysis showing it's not valid.

2. **Prove H_theory elements don't contribute to neg(phi) derivation**: Need to show that if L subset bidirectional_seed derives neg(phi), then L subset temporal_box_seed would also derive neg(phi). Difficult to formalize.

3. **Different seed construction**: Perhaps use temporal_box_seed for F-direction and past_temporal_box_seed for P-direction separately, then combine differently.

4. **Add axiom**: Adding H(a) -> G(H(a)) as an axiom changes the logic (makes it stronger than intended).

5. **Alternative completeness approach**: The existing sorry-free infrastructure (SuccChainFMCS, bundle-level coherence) may provide an alternative path for specific formulas.

## Files Modified

- `specs/070_explore_ultrafilter_construction/plans/04_bidirectional-witness.md`: Phase 2 marked [BLOCKED] with analysis
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`: Phases 0-1 code (unchanged in this session - already done)

## Current State of Sorries

The file UltrafilterChain.lean has 23 actual sorry statements:
- Lines 3864, 4271: Related to G_of_bidirectional_seed (Phase 2 blocking issue)
- Lines 3369, 3375: f_preserving_seed_consistent (archived as unprovable)
- Lines 7371, 7393: CoherentZChain (archived as fundamentally broken)
- Various others related to chain constructions

## Recommendation

The plan v4 (bidirectional witness) approach needs revision. Key options:

1. **Investigate whether the consistency proof can avoid G-lift for H_theory elements** - explore if H_theory contributes harmlessly to the derivation

2. **Use separate seeds for F and P directions** - temporal_box_seed for F-witness, past_temporal_box_seed for P-witness, without trying to combine them

3. **Focus on existing sorry-free infrastructure** - SuccChainFMCS provides same-family temporal coherence; investigate if it's sufficient for completeness

## Session Info

- Session ID: sess_1774928450_0fd62e
- Agent: lean-implementation-agent
- Duration: ~1.5 hours
- Outcome: Found fundamental flaw in plan, blocked progress
