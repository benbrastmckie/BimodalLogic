# Implementation Summary: Task 28 - Succ-Chain Discrete Completeness

**Date**: 2026-03-21
**Status**: Partial
**Plan**: plans/03_succ-chain-discrete-completeness.md

## Overview

This implementation advances the Succ-chain FMCS construction toward discrete completeness. The original plan targeted proving 3 axioms in SuccChainFMCS.lean. Progress was made but some axioms remain.

## Changes Made

### Phase 1: Forward F Coherence for Bounded Case [PARTIAL]

**Original Axiom**: `succ_chain_forward_F_bounded_axiom`
**Approach**: Replaced with `f_nesting_boundary` axiom + `bounded_witness` theorem

**New Theorems Added**:
- `iter_F_shift`: Helper relating `iter_F d (F phi) = iter_F (d+1) phi`
- `succ_chain_canonicalTask_forward_MCS_from`: Build MCS chains from any Int position
- Proof of `succ_chain_forward_F` for positive indices using `f_nesting_boundary`

**Remaining Axiom**: `f_nesting_boundary` - Finding the F-nesting boundary where `F^d(phi) ∈ M` and `F^(d+1)(phi) ∉ M`. The termination argument requires well-founded recursion on a non-obvious measure (the recursion on formula complexity goes upward, not downward).

### Phase 2: Forward F Coherence for Negative Indices [COMPLETED]

**Original Axiom**: `succ_chain_forward_F_neg_axiom`
**Approach**: Proven using `f_nesting_boundary` + `succ_chain_canonicalTask_forward_MCS_from`

**Theorems**:
- `succ_chain_forward_F_neg`: Complete proof for F-coherence at negative indices

The theorem `succ_chain_forward_F` now handles both positive and negative indices, with only the `f_nesting_boundary` helper remaining as an axiom.

### Phase 3: Backward P Coherence [PARTIAL]

**Axiom**: `succ_chain_backward_P_axiom` - remains as axiom

**Infrastructure Added**:
- `iter_P`: n-fold application of P operator
- `iter_P_shift`: Helper relating `iter_P d (P phi) = iter_P (d+1) phi`
- `p_nesting_boundary`: axiom (symmetric to `f_nesting_boundary`)

**Blocker**: Proving backward P coherence requires:
1. A `single_step_forcing_backward` theorem (P version of single_step_forcing)
2. A `bounded_witness_past` theorem (backward chain witness)
3. Succ relation properties for p_content (not currently present)

The Succ relation is defined with f_content/g_content, not p_content/h_content, making the backward direction non-trivial.

### Phase 4: Documentation [NOT STARTED]

Documentation updates were not completed as implementation phases were not fully completed.

## Axiom Count

**Before**: 3 axioms
- `succ_chain_forward_F_bounded_axiom`
- `succ_chain_forward_F_neg_axiom`
- `succ_chain_backward_P_axiom`

**After**: 3 axioms (different set)
- `f_nesting_boundary` - Helper for F-nesting boundary
- `p_nesting_boundary` - Helper for P-nesting boundary
- `succ_chain_backward_P_axiom` - Backward P coherence

**Net change**: 0 (axioms transformed but not reduced)

The axioms are now more modular:
- Two "nesting boundary" axioms capture the termination argument for F/P chains
- One "P coherence" axiom captures the backward direction structure

## Verification

- `lake build`: SUCCESS
- Sorries in SuccChainFMCS.lean: 0
- Axioms in SuccChainFMCS.lean: 3

## Follow-up Work Required

1. **Prove f_nesting_boundary**: Requires showing that unbounded F-nesting implies MCS inconsistency. Consider using `Nat.find` with a classical existence proof.

2. **Prove p_nesting_boundary**: Symmetric to f_nesting_boundary.

3. **Prove succ_chain_backward_P_axiom**: Requires:
   - Adding p_content to Succ relation or proving it follows from existing conditions
   - Defining `single_step_forcing_backward` theorem
   - Defining `bounded_witness_past` theorem
   - Building backward MCS chains

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added iter_F_shift, iter_P, iter_P_shift
  - Added succ_chain_canonicalTask_forward_MCS_from
  - Refactored succ_chain_forward_F to use f_nesting_boundary
  - Added succ_chain_forward_F_neg theorem
  - Restructured axioms

## Key Insight

The F-nesting boundary proof requires well-founded recursion, but the natural recursive call (on `F(phi)`) has HIGHER complexity than `phi`, not lower. This makes standard structural recursion infeasible. The proof likely requires:
- Classical logic to find the minimum d where `F^(d+1)(phi) ∉ M`
- Or showing that unbounded F-nesting leads to inconsistency via a clever argument

The semantic justification is sound - in discrete temporal frames, F-obligations must resolve at some finite distance.
