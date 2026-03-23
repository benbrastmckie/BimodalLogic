# Task 40: Impossibility Analysis

**Task**: Add p-step condition to Succ relation or prove successor_satisfies_p_step
**Date**: 2026-03-23
**Conclusion**: BLOCKED - Proof not achievable without an axiom

## Executive Summary

The forward chain p_step property cannot be proven from existing axioms and infrastructure. The fundamental issue is a structural asymmetry between the successor and predecessor constructions that cannot be bridged by temp_a, past_temp_a, or discreteness axioms alone.

## The Problem

**Goal**: Prove `p_content(forward_chain M0 (k+1)) <= forward_chain M0 k UNION p_content(forward_chain M0 k)`

Equivalently: If `P(phi)` is in the successor `v = forward_chain M0 (k+1)`, then either `phi` is in `u = forward_chain M0 k` or `P(phi)` is in `u`.

**Location**: SuccChainFMCS.lean line 350

## Investigation Summary

### 1. Duality Theorems (Insufficient)

The existing duality theorems provide:
- `Succ_implies_h_content_reverse`: If Succ u v, then h_content(v) subset u
- Uses temp_a: `phi -> G(P(phi))`

This only handles H-formulas (universal past), not P-formulas (existential past).

Key gap: `P(phi) = NOT H(NOT phi)` in v tells us `H(NOT phi) NOT_IN v`, but `h_content(v) subset u` is about formulas that ARE in h_content, not formulas that are NOT in h_content.

### 2. Discreteness Axiom Approach (Incomplete)

Attempted proof by contradiction:
1. Assume P(phi) in v, phi NOT_IN u, P(phi) NOT_IN u
2. From P(phi) NOT_IN u: H(NOT phi) in u (by MCS)
3. From temp_t_past: NOT phi in u
4. By discreteness_forward on NOT phi: (F_top AND NOT phi AND H(NOT phi)) -> F(H(NOT phi))
5. So F(H(NOT phi)) in u

**The Gap**: F(H(NOT phi)) in u only says there EXISTS a future MCS with H(NOT phi). It does NOT guarantee that the specific successor v has H(NOT phi).

To close the gap, we would need G(H(NOT phi)) in u, which would put H(NOT phi) in g_content(u) subset v.

### 3. temp_l Analysis

temp_l: `always(psi) -> G(H(psi))` where always = H AND id AND G

To derive G(H(NOT phi)) from H(NOT phi), we need always(NOT phi), which requires G(NOT phi) in u.

But G(NOT phi) in u is NOT guaranteed - the world might have F(phi) in u (future with phi).

### 4. The F(phi) Case Analysis

When F(phi) in u:
- By f_step: phi in v OR F(phi) in v
- Sub-case phi in v: We have phi in v but need phi in u OR P(phi) in u
  - From phi in v and past_temp_a: H(F(phi)) in v
  - By h_content(v) subset u: F(phi) in u (consistent but not helpful)
  - **No contradiction found**

### 5. Root Cause: Seed Asymmetry

**Predecessor seed** (works): `h_content(u) UNION pastDeferralDisjunctions(u)`
- pastDeferralDisjunctions includes `phi OR P(phi)` for each P(phi) in u
- This FORCES either phi or P(phi) into the predecessor
- p_step is CONSTRUCTED to hold

**Successor seed** (missing): `g_content(u) UNION deferralDisjunctions(u)`
- Only includes F-formula deferrals, nothing about P-formulas
- Lindenbaum extension can add arbitrary P-formulas
- p_step is NOT constrained by the seed

## Semantic Interpretation

In reflexive semantics, `P(phi)` at time v means "exists s <= v with phi(s)".

When the witness s = v (current time), we have phi in v but NOT necessarily phi in u.

The p_step property requires this "witnessed by current time" case to still satisfy phi in u OR P(phi) in u, but there's no syntactic mechanism to enforce this without an axiom.

## Conclusion

The p_step property for the forward chain is not derivable from:
- temp_a / past_temp_a (handle wrong direction)
- discreteness_forward (gives F not G)
- temp_l (requires always, not just H)
- g/h duality (handles H not P)

The property MUST be either:
1. Added as an axiom (like predecessor_f_step_axiom), OR
2. Built into a modified successor seed construction

Since the plan prohibits new axioms, this task must be BLOCKED.

## Recommendation

**Block this task** with a clear reason: The proof requires either a new axiom or a modified successor construction, both of which exceed the scope of proof-only changes.

**Future options**:
1. Accept successor_p_step_axiom (mirrors existing predecessor_f_step_axiom)
2. Redesign successor seed to include past deferrals (significant refactoring)
3. Live with the sorry if downstream uses are limited (technical debt)

## Impact Assessment

The sorry at line 350 blocks:
- `succ_chain_canonicalTask_backward_MCS_P_from` (SuccChainFMCS.lean:742/803)

If the canonical model construction is complete otherwise, this might be acceptable technical debt until a proper solution is designed.
