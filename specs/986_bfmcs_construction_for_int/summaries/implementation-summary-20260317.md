# Implementation Summary: Task 986 - BFMCS Construction for Int

**Date**: 2026-03-17
**Session**: sess_1773752190_077933
**Status**: Partial (Phase 1 partial, Phases 2-5 not started)

## Overview

Attempted to implement a sorry-free BFMCS construction for D = Int. Created the core infrastructure but encountered fundamental blockers for the F/P witness proofs.

## Completed Work

### File Created: `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

**Definitions:**
- `successorMCS`: Given MCS M, produces successor M' with CanonicalR M M'
- `predecessorMCS`: Given MCS M, produces predecessor M' with CanonicalR M' M
- `posChain`: Positive direction chain via Nat recursion
- `negChain`: Negative direction chain via Nat recursion
- `intChainMCS`: Combined Int-indexed chain

**Theorems Proven (sorry-free):**
- `h_content_consistent`: h_content of MCS is consistent (symmetric to existing g_content_consistent)
- `intChainMCS_is_mcs`: Each chain element is an MCS
- `posChain_canonicalR`: CanonicalR between consecutive positive chain elements
- `negChain_canonicalR`: CanonicalR between consecutive negative chain elements
- `canonicalR_propagates_G`: CanonicalR propagates G-formulas
- `canonicalR_propagates_GG`: CanonicalR propagates G-formulas with G prefix

**Theorems with Sorries:**
- `intChain_forward_G`: G propagation through Int chain (needs induction formalization)
- `intChain_backward_H`: H propagation through Int chain (symmetric)
- `intFMCS_forward_F`: Forward F witness existence (fundamental blocker)
- `intFMCS_backward_P`: Backward P witness existence (fundamental blocker)

## Fundamental Blocker

The core issue is that `forward_F` and `backward_P` require the Int-indexed chain to contain witnesses for all F/P obligations. The simple chain construction (iterating successorMCS/predecessorMCS) does NOT guarantee this.

**Why the simple chain doesn't work:**
- If F(phi) is in mcs(t), canonical_forward_F gives SOME witness MCS W with phi in W
- But W is not necessarily in our Int-indexed chain
- The chain elements are determined by successorMCS, not by F-obligation witnesses

**Required solution (not implemented):**
- Dovetailing enumeration: At each step, extend chain to witness the "oldest unsatisfied" F/P obligation
- This ensures all obligations are eventually witnessed
- This is what the deprecated DovetailingChain attempted (with sorries)

## Build Status

The file compiles with warnings (4 sorries).

```
lake build Bimodal.Metalogic.Algebraic.IntBFMCS
# Builds successfully with 4 sorry warnings
```

## Recommendations

1. **intChain_forward_G and intChain_backward_H**: These should be provable with more effort. The mathematical argument is sound (CanonicalR propagates G-formulas through chain). The challenge is formalizing the induction across Int indices.

2. **forward_F and backward_P**: These require a fundamentally different construction:
   - Option A: Implement dovetailing enumeration (complex, was abandoned in DovetailingChain)
   - Option B: Use CanonicalMCS domain with type-level embedding from Int (changes type signature)
   - Option C: Accept that BFMCS Int with full temporal coherence is not achievable with simple construction

3. **Alternative approaches** (from research):
   - Order-embedding transfer from CanonicalMCS (requires different algebraic infrastructure)
   - Conditional formulation (current DiscreteInstantiation approach)

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` (new file, ~400 lines)
- `specs/986_bfmcs_construction_for_int/plans/implementation-001.md` (phase status update)

## Phase Status

| Phase | Status | Notes |
|-------|--------|-------|
| 1: Chain Construction Core | PARTIAL | Core defs done, G/H coherence needs induction formalization |
| 2: FMCS Int with G/H Coherence | NOT STARTED | Blocked by Phase 1 sorries |
| 3: Forward_F and Backward_P | NOT STARTED | Fundamental blocker (dovetailing required) |
| 4: BFMCS Int Construction | NOT STARTED | Blocked by Phase 3 |
| 5: Verification and Cleanup | NOT STARTED | Blocked by prior phases |
