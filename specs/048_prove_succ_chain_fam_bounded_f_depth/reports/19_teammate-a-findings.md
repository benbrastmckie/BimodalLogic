# Root Cause Analysis: Task 48 Mathematical Blockers

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Teammate**: A (Root Cause Analysis)
**Focus**: Why we keep going in circles on this problem

## Root Cause Identification

**The root cause is a fundamental asymmetry between unrestricted MCS and DeferralRestrictedMCS regarding negation completeness scope.**

### The Unrestricted Case Works Because:

In `CanonicalTaskRelation.lean:606-629`, `succ_propagates_F_not` succeeds via this chain:

```
FF(psi) not in u
  --> neg(FF(psi)) in u           [negation completeness - GLOBAL]
  --> GG(neg(psi)) in u           [derivation closure]
  --> G(neg(psi)) in g_content(u)
  --> G(neg(psi)) in v            [Succ g_persistence]
  --> F(psi) not in v             [consistency]
```

**Critical**: Negation completeness applies to ANY formula because full MCS is maximally consistent over the entire formula language.

### The Restricted Case Fails Because:

For `DeferralRestrictedMCS`, negation completeness is LOCAL - it only applies to formulas within `deferralClosure(phi)`. When `FF(psi) not in deferralClosure`:

```
FF(psi) not in u
  --> ???                          [Cannot apply negation completeness!]
```

The chain breaks at step 1. Without `neg(FF(psi)) in u`, we cannot derive `GG(neg(psi)) in u`, and the entire propagation argument collapses.

## Why Prior Approaches Failed

### Approach 1: Direct Translation (Plans v1-v4)
**Failure mode**: Assumed restricted negation completeness would suffice.
**Why**: Didn't recognize that `FF(psi)` can be outside `deferralClosure` even when `F(psi)` is inside.

### Approach 2: Fuel-Based Recursion (Plans v5-v6)
**Failure mode**: Fuel invariant `fuel >= closure_F_bound` cannot be maintained through persistence steps.
**Why**: Each recursive call with `fuel - 1` weakens the invariant. The fuel=0 base case doesn't yield contradiction because `d` never increases.

### Approach 3: Strengthen to GF Hypothesis (Plans v7-v9)
**Failure mode**: Even with `h_FF_not` AND `h_GF_not`, `F(psi)` can still appear in `v` via MCS maximality.
**Why**: The Succ relation only imposes INCLUSION constraints:
- `g_content(u) subset v`
- `f_content(u) subset v union f_content(v)`

It places NO exclusion constraints. The Lindenbaum extension during MCS construction can freely choose `F(psi)` over `G(psi.neg)` when neither is forced by the seed.

### The Deeper Problem: MCS Maximality Freedom

This is documented in the code comments at `SuccChainFMCS.lean:4322-4331`:

```lean
-- By maximality: either F(psi) in v or G(psi.neg) in v.
-- Without forcing, the MCS extension can pick either.
-- So we STILL can't prove F(psi) not in v.
--
-- UNLESS the MCS extension has a deterministic tie-breaking rule.
-- Looking at the construction, it uses Classical.choose, which is non-deterministic.
--
-- FINAL CONCLUSION: The theorem `restricted_succ_propagates_F_not'` with
-- hypotheses h_FF_not and h_GF_not is NOT provable in general.
```

The `Classical.choose` in Lindenbaum's lemma makes no guarantees about which formula is chosen when both `F(psi)` and `G(psi.neg)` are consistent with the seed.

## Mathematical Requirements for Solution

To close the 5 remaining sorries, we need ONE of the following:

### Option A: Prove a Stronger Seed Property (NOT VIABLE)

Would require showing that the seed construction FORCES `G(psi.neg)` over `F(psi)` at the boundary. This is false - the seed is:
```
g_content(u) union deferralDisjunctions(u) union p_step_blocking(u)
```
None of these contain `G(psi.neg)` when we're at the FF-boundary.

### Option B: Accept sorry and Defer (VIOLATES ZERO-DEBT)

Mark the theorems as axioms. This violates the project's zero-debt policy and defers real mathematical work.

### Option C: Modify Chain Construction (VIABLE - Recommended by Report 15)

Add a `boundary_resolution_set` to the seed:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi in u and
         Formula.some_future (Formula.some_future chi) not in deferralClosure(phi) and
         Formula.all_future (Formula.some_future chi) not in u}
```

**Why it might work**: At the boundary, adding `chi` directly forces the only coherent resolution.

**Gating question**: Is `old_seed union {chi}` consistent? This requires proving `neg(chi)` is not derivable from `g_content(u)` via modal axioms.

### Option D: Alternative Proof Strategy (UNKNOWN VIABILITY)

Instead of proving `F(psi) not in v` (which is false in general), prove the ultimate goal differently:
- Track a different measure (e.g., set of unresolved F-obligations)
- Use a counting argument on formulas in `deferralClosure`
- Leverage finiteness of `deferralClosure` more directly

## The 5 Sorry Locations Analyzed

| Line | Context | What's Needed |
|------|---------|---------------|
| 3201 | `restricted_single_step_forcing` | Show `psi in v` when `FF(psi) not in dc` |
| 3360 | `restricted_succ_propagates_F_not` | Show `F(psi) not in v` at boundary |
| 4108 | `restricted_succ_propagates_F_not'` | Same, with strengthened hypotheses |
| 4336 | `restricted_succ_propagates_F_not'` | MCS maximality case |
| 4348 | `restricted_succ_propagates_F_not'` | F(psi) not in u case |

**All 5 sorries reduce to the same fundamental gap**: We cannot force the MCS extension to choose `G(psi.neg)` over `F(psi)` when both are consistent with the seed.

## Confidence Level

**HIGH confidence** in the root cause identification.

The analysis is supported by:
1. Explicit code comments from multiple implementation attempts
2. Clear mathematical distinction between global and local negation completeness
3. Team research report 15 arriving at the same conclusion independently
4. The `Classical.choose` non-determinism is a hard mathematical fact

**MEDIUM confidence** in Option C as a solution.

The approach is mathematically sound but:
1. Consistency proof for augmented seed is non-trivial
2. May break existing proofs that depend on seed structure
3. Requires careful verification of downstream impact

## Summary

Task 48 is blocked by a **fundamental structural limitation** of `DeferralRestrictedMCS`: local negation completeness cannot substitute for global negation completeness in the `succ_propagates_F_not` argument.

The solution requires **modifying the chain construction** to explicitly resolve F-obligations at the boundary, not strengthening hypotheses on helper theorems. All hypothesis-strengthening approaches fail because the Succ relation's one-way inclusion constraints cannot prevent MCS maximality from introducing unwanted formulas.
