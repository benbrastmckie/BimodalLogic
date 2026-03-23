# Research Report: Lexicographic Well-Founded Order for `restricted_forward_chain_iter_F_witness`

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Session**: sess_1774302261_2485cd
**Focus**: Mathematically correct lexicographic well-founded order

## Executive Summary

The fuel-based approach in plan v5 failed because the invariant `fuel >= closure_F_bound phi` cannot be maintained through persistence (inr) steps. The correct solution requires understanding that **persistence is bounded NOT by fuel, but by the finite nature of deferralClosure itself**.

**Key Insight**: The existing `bounded_witness` pattern cannot be directly applied to `DeferralRestrictedMCS` because it requires global `SetMaximalConsistent`, but a **restricted version** can be constructed using the local negation completeness within deferralClosure.

## Analysis of the Blocker

### The Failed Fuel Approach

The plan v5 approach:
```lean
theorem restricted_forward_chain_iter_F_witness_persistence (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (fuel k d : Nat) (psi : Formula)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi in restricted_forward_chain phi M0 k)
    (h_fuel_enough : fuel >= closure_F_bound phi) :  -- THIS INVARIANT IS THE PROBLEM
    exists m, k < m and psi in restricted_forward_chain phi M0 m
```

**Why it fails**: In the inr (persistence) case:
- We have `fuel >= closure_F_bound phi`
- We call recursively with `fuel - 1`
- But `fuel - 1 >= closure_F_bound phi - 1`, NOT `>= closure_F_bound phi`
- The invariant weakens each step

**The fuel=0 contradiction doesn't work**: At fuel=0, we're in the inr case with `d < closure_F_bound phi` (checked at start). We cannot derive contradiction from fuel=0 because d never increases.

### Why Infinite Persistence Seems Possible

Consider `iter_F d psi` persisting through the chain:
- `iter_F d psi in chain(k)`, `iter_F d psi in chain(k+1)`, ...

The formula has fixed F-nesting depth `d + f_nesting_depth(psi)`. Nothing in the fuel-based approach bounds how many times the SAME formula can persist.

### The Real Termination Argument

The correct argument uses `restricted_forward_chain_F_bounded`:

At chain(k), we have d_k such that:
- `iter_F d_k psi in chain(k)` (the highest F-iteration in the chain)
- `iter_F (d_k + 1) psi not in chain(k)`

**Key property**: When F-step gives inl (depth decrease), d decreases. When it gives inr (persistence), d stays the same BUT the boundary `d_k+1 = d_k` propagates through the Succ relation to the next element.

The termination comes from the **bounded_witness** pattern, not fuel counting.

## The Correct Approach: Restricted Bounded Witness

### Overview

Instead of fuel-based recursion, use the existing `restricted_forward_chain_F_bounded` to get the boundary at the START, then apply a restricted version of `bounded_witness`.

### Step 1: Use F_bounded at Start

Given `F(psi) in chain(k)`, by `restricted_forward_chain_F_bounded`:
```lean
exists d, d >= 1 and iter_F d psi in chain(k) and iter_F (d+1) psi not in chain(k)
```

### Step 2: Build CanonicalTask_forward Chain

Use existing `restricted_forward_chain_canonicalTask_forward_from`:
```lean
CanonicalTask_forward (chain(k)) d (chain(k+d))
```

### Step 3: Apply Restricted Bounded Witness

Need a version of `bounded_witness` that works for `DeferralRestrictedMCS`:

```lean
theorem restricted_bounded_witness
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (k : Nat) (psi : Formula) (d : Nat)
    (h_Fd : iter_F d psi in chain(k))
    (h_Fd1_not : iter_F (d+1) psi not in chain(k)) :
    psi in chain(k+d)
```

### Why Restricted Bounded Witness Works

The original `bounded_witness` uses `single_step_forcing` and `succ_propagates_F_not`, which require global MCS for negation completeness.

For `DeferralRestrictedMCS`, we have LOCAL negation completeness:
- For any `chi in deferralClosure(phi)`: either `chi in M` or `neg(chi) in M`

**Key observation**: If `iter_F (d+1) psi not in chain(k)`:
- Case 1: `iter_F (d+1) psi not in deferralClosure(phi)` => it's not in ANY chain element (since all chain elements are restricted to deferralClosure)
- Case 2: `iter_F (d+1) psi in deferralClosure(phi)` => by local negation completeness, `neg(iter_F (d+1) psi) in chain(k)`

In either case, we can show `iter_F d psi in chain(k+1)` or `iter_F (d-1) psi in chain(k+1)`.

The proof proceeds by strong induction on d:
- Base case (d = 0): `iter_F 0 psi = psi in chain(k)`, done
- Inductive case: use F-step dichotomy with the "not in" propagation

## Lean 4 Implementation Strategy

### Strategy 1: Direct Strong Induction (Recommended)

```lean
private theorem restricted_forward_chain_iter_F_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
    (h_d_ge : d >= 1)
    (h_iter : iter_F d psi in restricted_forward_chain phi M0 k) :
    exists m, k < m and psi in restricted_forward_chain phi M0 m := by
  -- Get the F-boundary at chain(k)
  obtain <d_max, h_d_max_ge, h_d_max_in, h_d_max_not> :=
    restricted_forward_chain_F_bounded phi M0 k psi (iter_F_1_implies_F h_iter)
  -- Use strong induction on d_max to show psi in chain(k + d_max)
  exact restricted_bounded_witness phi M0 k psi d_max h_d_max_in h_d_max_not
```

### Strategy 2: Lexicographic WellFounded.fix

If needed for more complex recursion:
```lean
-- Measure: d (only first component needed since we use bounded_witness)
-- The recursion terminates because d decreases each step
termination_by d
```

### Key Lemma: Restricted Single Step Forcing

```lean
theorem restricted_single_step_forcing
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi in chain(k))
    (h_FF_not : Formula.some_future (Formula.some_future psi) not in chain(k)) :
    psi in chain(k+1) := by
  -- Case analysis on whether FF(psi) is in deferralClosure
  by_cases h_in_dc : Formula.some_future (Formula.some_future psi) in deferralClosure phi
  . -- In closure: use local negation completeness
    have h_neg_FF := local_negation_complete (chain_is_drm k) h_in_dc h_FF_not
    -- neg(FF(psi)) in chain(k) => GG(neg(psi)) in chain(k) => G(neg(psi)) in chain(k+1)
    -- => F(psi) not in chain(k+1) => by F-step, psi in chain(k+1)
    ...
  . -- Not in closure: FF(psi) is not in any chain element
    -- Direct argument using F-step: since F(psi) in chain(k) and FF(psi) can never be in chain(k+1)
    -- the only option is psi in chain(k+1)
    ...
```

### Key Lemma: Restricted Propagates F Not

```lean
theorem restricted_succ_propagates_F_not
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_FF_not : Formula.some_future (Formula.some_future psi) not in chain(k)) :
    Formula.some_future psi not in chain(k+1) := by
  -- Case analysis on whether FF(psi) is in deferralClosure
  by_cases h_in_dc : Formula.some_future (Formula.some_future psi) in deferralClosure phi
  . -- Similar to original: local negation completeness gives neg(FF(psi))
    -- => GG(neg(psi)) => G(neg(psi)) propagates => F(psi) not in successor
    ...
  . -- Not in closure: FF(psi) not in chain(k) AND FF(psi) not in chain(k+1)
    -- So F(psi) not in f_content(chain(k+1))
    -- But we need F(psi) not in chain(k+1) directly...
    -- Actually, if FF(psi) not in deferralClosure, then F(psi) might still be in closure
    -- This case needs more careful analysis
    ...
```

## Mathematical Confidence

**HIGH confidence** in the approach, with caveats.

### What Works
1. The `restricted_forward_chain_F_bounded` lemma provides the boundary at each chain element
2. The Succ relation with F-step gives the depth decrease or persistence dichotomy
3. The finite deferralClosure bounds the F-nesting depth

### Caveats
1. **Restricted single_step_forcing needs proof**: The case where `FF(psi)` is outside deferralClosure requires careful handling
2. **Restricted succ_propagates_F_not needs proof**: May need additional case analysis
3. **May need Lindenbaum extension**: If the restricted lemmas are too hard, an alternative is to extend each chain element to full MCS and use original bounded_witness

### Fallback: Lindenbaum Extension

If the restricted bounded_witness is difficult:
```lean
-- Extend chain(k) to full MCS
let M_k := extendToMCS (chain_drm k)
-- Use original bounded_witness on the extension
have h_psi := bounded_witness M_k M_{k+d} psi d ...
-- Transfer back: psi in M_k and chain(k) subset M_k => psi in chain(k+d) if psi in deferralClosure
```

This works because:
- `chain(k) subset extendToMCS(chain(k))`
- If `psi in chain(k+d)` is what we want, and `psi in deferralClosure`, the extension approach should work

## Summary of Correct Lexicographic Order

The correct termination measure is NOT `(d, fuel)` but simply `d` (the F-nesting depth), using the bounded_witness pattern:

1. **Get boundary at start**: `iter_F d psi in chain(k)`, `iter_F (d+1) psi not in chain(k)`
2. **Propagate through chain**: At each step, either depth decreases (d -> d-1) or we get contradiction
3. **Termination**: d decreases, reaching d=0 where `iter_F 0 psi = psi in chain(k+d)`

The key insight is that **we don't need to track persistence separately** - the bounded_witness pattern handles it by propagating the "not in" property through the chain.

## Recommendations

1. **First**: Prove `restricted_single_step_forcing` and `restricted_succ_propagates_F_not` for DeferralRestrictedMCS
2. **Then**: Prove `restricted_bounded_witness` using these lemmas
3. **Finally**: Prove `restricted_forward_chain_iter_F_witness` using `restricted_bounded_witness`

If step 1 proves difficult, use the Lindenbaum extension fallback.

## Files to Modify

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`: Add restricted versions of single_step_forcing, succ_propagates_F_not, and bounded_witness
- Remove the fuel-based `restricted_forward_chain_iter_F_witness_persistence` approach

## References

- `CanonicalTaskRelation.lean`: Original `bounded_witness` and `single_step_forcing`
- `SuccRelation.lean`: Succ definition and F-step property
- `RestrictedMCS.lean`: `deferral_restricted_mcs_F_bounded`, local negation completeness
