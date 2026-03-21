# Implementation Summary: Task 23 - Succ-Chain FMCS Construction

## Status: PARTIAL

**Session ID**: sess_1774128721_7c7899
**Date**: 2026-03-21

## Overview

This implementation creates `SuccChainFMCS.lean` using the Succ-constrained chain approach
to address the F/P temporal witness problem. Unlike generic Lindenbaum chain constructions
(which fail for F/P witnesses), the Succ-chain construction guarantees temporal coherence
by construction via deferral seeds.

## Phases Completed

### Phase 1: Create SuccChainFMCS.lean [COMPLETED]

File already existed with partial implementation. Key structures in place:
- `SerialMCS`: MCS with F(top) and P(top) seriality
- `forward_chain` / `backward_chain`: Nat-indexed chains using deferral seeds
- `succ_chain_fam`: Combined Int-indexed family
- `SuccChainFMCS`: FMCS Int structure
- `SuccChainTemporalCoherent`: TemporalCoherentFamily Int structure

### Phase 2: Prove Temporal Coherence [PARTIAL]

**Proven (no axioms):**
- `F_top_propagates` / `P_top_propagates` - converted from axioms to theorems
- `succ_chain_forward_G` - G-persistence along chain
- `succ_chain_backward_H` - H-persistence along chain
- `forward_chain_canonicalTask_forward_MCS` - connects to bounded_witness
- `succ_chain_forward_F` (single-step case) - when FF(phi) not in mcs

**Still axioms (3 in SuccChainFMCS.lean):**
- `succ_chain_forward_F_bounded_axiom` - handles FF(phi) in mcs case
- `succ_chain_forward_F_neg_axiom` - handles negative indices
- `succ_chain_backward_P_axiom` - backward P coherence

### Phase 3: Wire to Completeness [BLOCKED]

The completeness path requires BFMCS (bundle of FMCS families) with cross-family
modal coherence. This is an architectural issue beyond single-family construction.

Current architecture:
- `construct_bfmcs_from_mcs_Int_v4` uses `DirectMultiFamilyBFMCS`
- DirectMultiFamilyBFMCS has sorries for cross-family modal coherence at t != 0
- SuccChainFMCS provides TemporalCoherentFamily but not BFMCS

### Phase 4: Axiom Assessment [NOT STARTED]

3 axioms remain in SuccExistence.lean:
- `successor_deferral_seed_consistent_axiom`
- `predecessor_deferral_seed_consistent_axiom`
- `predecessor_f_step_axiom`

## Key Technical Details

### Single-Step Forcing

When `F(phi) in mcs` and `FF(phi) not in mcs`, `single_step_forcing` provides
the witness at the next step without any axiom:

```lean
-- From SuccRelation.lean
theorem single_step_forcing ... (h_succ : Succ u v) : phi in v
```

This handles the common case where F-obligations don't nest deeply.

### CanonicalTask_forward_MCS Connection

Created `forward_chain_canonicalTask_forward_MCS_from` to build MCS chains
suitable for `bounded_witness` application:

```lean
theorem forward_chain_canonicalTask_forward_MCS_from (M0 : SerialMCS) (start n : Nat) :
    CanonicalTask_forward_MCS (forward_chain M0 start) n (forward_chain M0 (start + n))
```

### Axiom Reduction

Reduced SuccChainFMCS axioms from 5 to 3 by proving F_top/P_top propagation:
- `F_top_propagates` - proven via `SetMaximalConsistent.contains_F_top`
- `P_top_propagates` - proven via `SetMaximalConsistent.contains_P_top`

## Verification

- **Build**: `lake build` succeeds (1024 jobs)
- **Sorries in SuccChainFMCS.lean**: 0
- **Axioms in SuccChainFMCS.lean**: 3
- **Axioms in SuccExistence.lean**: 3 (unchanged)

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | Added proofs, reduced axioms |
| `specs/023_fp_temporal_witness_chain/plans/03_succ-chain-construction.md` | Updated phase markers |

## Remaining Work

1. **Prove bounded F-nesting axioms**: Requires well-founded argument on formula depth
2. **Address negative index case**: Similar to bounded case
3. **Backward P coherence**: Symmetric to forward F
4. **Wire to completeness**: Requires architectural decision about BFMCS bypass

## Recommendation

The Succ-chain approach provides correct infrastructure but the completeness path
requires either:
1. A new completeness proof bypassing BFMCS (using SuccChainFMCS + CanonicalTask directly)
2. Converting remaining 3 axioms to theorems (bounded_witness approach)

Option 1 is cleaner but requires significant refactoring. Option 2 is more incremental.
