# Boundary Case Analysis: FF(psi) not in deferralClosure

## Problem Summary

Task 48 v6 implementation has two remaining sorries in the bounded witness approach:
1. `restricted_single_step_forcing` (line ~3077) - When F(psi) in chain(k), FF(psi) not in deferralClosure
2. `restricted_succ_propagates_F_not` (line ~3236) - When FF(psi) not in chain(k), FF(psi) not in dc, but F(psi) in dc

Both cases arise when F(psi) is at the **boundary** of deferralClosure - meaning F(psi) is inside the closure but FF(psi) is outside.

## Key Definitions

```lean
-- F-step property of Succ relation
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v

-- f_content extracts formulas under F
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}
```

## Standard Proof Technique (when FF(psi) in dc)

For `single_step_forcing`: If F(psi) in u and FF(psi) not in u, prove psi in v.

1. FF(psi) not in u AND FF(psi) in subformulaClosure => neg(FF(psi)) in u (negation completeness)
2. neg(FF(psi)) derives GG(neg psi) via DNE inside G
3. GG(neg psi) in u => G(neg psi) in g_content(u)
4. G(neg psi) in v (by Succ G-persistence)
5. G(neg psi) in v => F(psi) not in v (consistency: G(neg psi) = neg(F(psi)))
6. F-step: psi in f_content(u) => psi in v OR psi in f_content(v)
7. Since F(psi) not in v, psi not in f_content(v)
8. Therefore psi in v

## The Boundary Case Problem

When FF(psi) is NOT in deferralClosure:
- We cannot apply negation completeness to get neg(FF(psi)) in u
- Therefore we cannot derive GG(neg psi) in u
- Therefore we cannot block F(psi) from appearing in v

The F-step only tells us: psi in v OR F(psi) in v. Without the GG argument, we cannot rule out F(psi) in v.

## Key Insight: The Boundary Trivializes succ_propagates_F_not

For `restricted_succ_propagates_F_not`, we want: FF(psi) not in chain(k) => F(psi) not in chain(k+1).

**Case split on F(psi) in deferralClosure:**

1. **F(psi) NOT in deferralClosure**: Then F(psi) not in chain(k+1) trivially, since chain(k+1) is a subset of deferralClosure. This case is ALREADY HANDLED in the code (lines 3237-3240).

2. **F(psi) IN deferralClosure but FF(psi) NOT in deferralClosure**: This is the sorry case. We need to show F(psi) not in chain(k+1).

## Analysis of Case 2

If F(psi) in dc but FF(psi) not in dc, what can we conclude?

**Structural facts:**
- F(psi) in deferralClosure => F(psi) in closureWithNeg (by `some_future_in_deferralClosure_is_in_closureWithNeg`)
- F(psi) in closureWithNeg => psi in subformulaClosure (by `some_future_in_closureWithNeg_inner_in_subformulaClosure`)
- FF(psi) NOT in deferralClosure means f_nesting_depth(FF(psi)) > max_F_depth_in_closure(phi)
- f_nesting_depth(FF(psi)) = 2 + f_nesting_depth(psi)
- f_nesting_depth(F(psi)) = 1 + f_nesting_depth(psi)

So F(psi) is "one step inside" the boundary, and FF(psi) is "one step outside".

## Why the Current Approach Fails

The proof tries to derive:
1. neg(FF(psi)) in u (needs negation completeness for FF(psi))
2. GG(neg psi) in u (from neg(FF(psi)) via DNE)
3. G(neg psi) in v (G-persistence)
4. F(psi) not in v (consistency)

Step 1 fails because FF(psi) not in subformulaClosure, so negation completeness doesn't apply.

## Proposed Solution: Reframe as Invariant Maintenance

**Key Observation:** The bounded_witness induction maintains an invariant that the "current depth" d decreases. At each step:
- Start: iter_F d psi in chain(k), iter_F (d+1) psi not in chain(k)
- After single_step_forcing: iter_F (d-1) psi in chain(k+1)
- After succ_propagates_F_not: iter_F d psi not in chain(k+1)

The question is: when iter_F (d+1) psi = FF(iter_F (d-1) psi) is NOT in deferralClosure, can d still decrease?

**Answer: YES, because F-step must eventually resolve.**

## Detailed Proof Strategy

### For `restricted_succ_propagates_F_not` (the critical case):

**Given:** FF(psi) not in chain(k), FF(psi) not in dc, F(psi) in dc
**Goal:** F(psi) not in chain(k+1)

**Approach:** By contradiction. Assume F(psi) in chain(k+1).

1. F(psi) in chain(k+1) implies F(psi) in dc (chain subset of dc) - CHECK, consistent with hypothesis
2. FF(psi) not in dc implies FF(psi) not in chain(k+1) (chain subset of dc)
3. Now we have: F(psi) in chain(k+1), FF(psi) not in chain(k+1), and we need contradiction

**The Missing Link:** We need to show that having F(psi) in chain(k+1) while FF(psi) is outside dc leads to a structural impossibility.

**Insight:** Since FF(psi) not in dc, we can't use negation completeness. But consider what happens as we continue the chain:
- At chain(k+2): Either psi in chain(k+2) OR F(psi) in chain(k+2) (by F-step)
- At chain(k+3): Similar dichotomy

If F(psi) persists forever, we need F(psi) to be stable under F-step. But F-step says:
`f_content(chain(k+1)) ⊆ chain(k+2) ∪ f_content(chain(k+2))`

So psi in f_content(chain(k+1)) means psi in chain(k+2) OR psi in f_content(chain(k+2)) = F(psi) in chain(k+2).

**Key Question:** Can F(psi) persist in the chain forever while FF(psi) stays outside dc?

### For `restricted_single_step_forcing` (the other sorry):

**Given:** F(psi) in chain(k), FF(psi) not in chain(k), FF(psi) not in dc, F(psi) in dc
**Goal:** psi in chain(k+1)

F-step gives: psi in chain(k+1) OR F(psi) in chain(k+1).

If we can prove F(psi) not in chain(k+1), we're done.

But that requires succ_propagates_F_not, which has the same sorry!

## Alternative Approach: Inline the Proof in bounded_witness

Instead of separating single_step_forcing and succ_propagates_F_not, prove bounded_witness directly with case analysis:

**Induction on d:**
- Base: d = 1. iter_F 1 psi = F(psi) in chain(k), iter_F 2 psi = FF(psi) not in chain(k).
  - If FF(psi) in dc: Use standard single_step_forcing argument
  - If FF(psi) not in dc: Need special handling
- Step: d = d' + 1. Use ih after showing depth decreases.

**The d=1 boundary case:** When F(psi) in chain(k), FF(psi) not in chain(k), FF(psi) not in dc:

Since FF(psi) not in dc, FF(psi) not in chain(k+1) either. By F-step on F(psi):
psi in chain(k+1) OR F(psi) in chain(k+1).

If F(psi) in chain(k+1), apply the same reasoning at k+1:
psi in chain(k+2) OR F(psi) in chain(k+2).

This can continue indefinitely. We need an argument that it must eventually resolve.

## Recommended Solution: Leverage DeferralRestrictedSerialMCS Structure

The MCS M0 and all chain elements satisfy `DeferralRestrictedMCS phi`. This means:
1. They are subsets of deferralClosure(phi)
2. They are maximal consistent within deferralClosure(phi)

**Claim:** If F(psi) in M and FF(psi) not in M and M is DeferralRestrictedMCS, and FF(psi) not in deferralClosure, then F(psi) must eventually be "used up" by the F-step.

**Why:** The deferralClosure has a fixed finite F-depth bound. F(psi) is at the boundary (depth = max). The deferral disjunction `psi ∨ F(psi)` is in deferralClosure. The chain construction uses these deferral disjunctions to ensure progress.

## Concrete Fix for the Sorries

### Option A: Prove boundary case using deferral disjunction membership

For F(psi) at boundary (FF(psi) not in dc):
1. Show that `psi ∨ F(psi)` is in deferralClosure (by deferral_of_F_in_closure)
2. Show that `psi ∨ F(psi)` in chain(k) (since F(psi) in chain(k) and chain respects disjunction)
3. In the successor construction, the deferral disjunction forces either psi or F(psi) to be in chain(k+1)
4. Track that the "deferred" case (F(psi) in chain(k+1)) cannot persist forever

**Issue:** This requires understanding the successor construction in detail.

### Option B: Modify theorem statements to exclude boundary case

Add hypothesis `FF(psi) ∈ deferralClosure phi` to both theorems. Then modify `bounded_witness` to handle the boundary case separately.

In `bounded_witness`, when iter_F (d+1) psi not in dc:
- iter_F (d+1) psi not in chain(k) trivially (since chain subset of dc)
- This IS the boundary case
- Use direct argument that at boundary, F-step must resolve

### Option C: Direct proof using closure depth tracking

**Lemma:** If iter_F d psi in chain(k) with d >= 1 and iter_F (d+1) psi not in dc, then psi in chain(k+d).

**Proof:** By induction on d.
- d = 1: F(psi) in chain(k), FF(psi) not in dc => FF(psi) not in chain(k+1).
  F-step: psi in chain(k+1) OR F(psi) in chain(k+1).
  If F(psi) in chain(k+1), then FF(psi) not in chain(k+2) (still outside dc).
  F-step at k+1: psi in chain(k+2) OR F(psi) in chain(k+2).
  ...eventually psi must appear because... (need finite argument)

**The Missing Finite Argument:** We need to show F(psi) cannot persist forever.

## Recommended Implementation

1. **Prove a helper lemma:** `boundary_F_eventually_resolves`
   - If F(psi) in chain(k), FF(psi) not in dc, then exists m > k such that psi in chain(m) and F(psi) not in chain(m)

2. **Use this in bounded_witness** to handle the boundary case specially

3. **For the helper lemma proof:**
   - Use well-founded recursion on something that decreases
   - Candidate: the number of "boundary F-formulas" that remain unresolved
   - Or: use the finiteness of deferralClosure to bound the number of steps

## Files to Modify

1. `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
   - Lines 3077 and 3236 (the sorry locations)
   - Add helper lemmas for boundary case handling

2. Potentially: `Theories/Bimodal/Syntax/SubformulaClosure.lean`
   - If new lemmas about closure depth bounds are needed

## Summary

The boundary case sorries arise because the standard negation completeness argument requires FF(psi) to be in the closure. When FF(psi) is outside the closure:
- We cannot derive neg(FF(psi)) in the MCS
- We cannot derive GG(neg psi) to block F(psi) in the successor

The solution requires a different argument that leverages:
1. The finiteness of deferralClosure
2. The structure of deferral disjunctions (psi ∨ F(psi))
3. A termination argument showing F cannot persist forever at the boundary

**Recommended approach:** Option C - direct proof using closure depth tracking, possibly combined with a custom well-founded argument in bounded_witness.
