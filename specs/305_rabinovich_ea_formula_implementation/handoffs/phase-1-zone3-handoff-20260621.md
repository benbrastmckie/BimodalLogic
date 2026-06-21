# Phase 1 Handoff: Zone-3 Existential Transfer (Cycle 2)

## Status: PARTIAL

## What Was Accomplished

Added the statement of `prior_exist_transfer_one_dir` theorem to PriorComposition.lean (line 487-515). This theorem, once proved, will fill all 4 sorry sites.

Added PriorINF import to access `HasAttainedINF.first_occ`.

## Key Analysis (CRITICAL for next dispatch)

### The Fundamental Challenge

The 4 sorries require depth-(K+1) 3-var existential transfer at [x,t]/[x',t']. The strong induction gives depth-(K+1) 2-var agreement (from ih_strong at m=K-1). From this, exist_transfer_from_full_agree gives depth-K 3-var existential transfer. But we need depth-(K+1), not K. The 1-depth gap is intrinsic.

### Why `nvar_transfer_from_1var_agree` Cannot Close the Gap

`nvar_transfer_from_1var_agree` at d=K+1, r=2 requires h_rvar at depth K+2 arity 2, which IS the theorem being proved (circular). It works at d=K with h_rvar from ih_strong but only gives depth-K.

### The Correct Approach: Depth Induction with Prior-UZ

The theorem `prior_exist_transfer_one_dir` should be proved by induction on d (NF depth, 0 to K+1), with arity r universally quantified:

```
forall d <= K+1, forall r, forall envM envN,
  [1-var at depth d+1] -> [order] -> forall sub at depth d arity r+1,
  (exists z, nf_eval M d (r+1) [z, envM] sub) -> exists z', nf_eval N d (r+1) [z', envN] sub
```

At each step:
1. Find z' with matching depth-(d+1) 1-var type in the right order zone via Prior-UZ
2. Atoms match from 1-var + order
3. Quantifier conditions (at depth d, arity r+2) transfer by IH at depth d

The IH at depth d with env [z,envM]/[z',envN] needs:
- 1-var at depth d+1 for z/z': z' is found via char_fn (d+1), giving depth-(d+1) agreement. checkmark
- 1-var at depth d+1 for envM/envN: weaken from depth d+2. checkmark
- Order matching: from atom matching at current level. checkmark

### The Zone-3 Witness Existence Problem

Finding z' in the right order zone is the core difficulty. For r=2 (the case needed at sorry sites):

Given z in zone 3 of M (t < z < x), need z' in zone 3 of N (t' < z' < x').

Use cross_extend to get:
- w2 > t' (from h_t) with matching 1-var type
- w1 < x' (from h_x) with matching 1-var type

If w2 < x' or w1 > t': direct zone-3 witness via HasAttainedINF.first_occ. EASY CASE.

If w2 >= x' AND w1 <= t': HARD CASE. The formula char_fn (d+1) nf_z might not be realized in (t', x'). However, the mathematical theorem guarantees it IS for Prior structures. The proof must use the FULL depth-(d+2) 1-var agreements h_x and h_t to deduce this.

### Recommended Approach for Hard Case

The quantifier condition of the depth-(d+2) 1-var NF of t encodes: for each depth-(d+1) 2-var chi, whether `exists w > t, nf_eval M (d+1) 2 [w, t] chi`. Similarly for t'. By h_t: these match.

The z in (t, x) satisfies some depth-(d+1) 2-var chi at [z, t]. The quantifier says `exists w > t, ...` is true. By h_t: `exists w2 > t', ...` is true in N. w2 > t'.

But we also need w2 < x'. The information that z < x is NOT encoded in the 2-var type at [z, t]. It IS encoded in the 2-var type at [z, x] (via hw1).

The proof should combine hw2 and hw1 to extract: there exists a point in (t', x') with the right properties. Specifically, use the temporal formula approach:

1. char_fn (d+1) nf_z holds at w2 > t' (temporal truth)
2. Also holds at w1 < x'
3. By Prior-UZ: first occurrence s above t', s <= w2
4. By Prior-SZ: last occurrence s' below x', s' >= w1
5. By the 2-var agreements: the first occurrence above t' must precede x', or the last occurrence below x' must follow t'. This requires extracting ORDER INFORMATION from the 2-var agreements.

Specifically: hw2 (2-var at [z,t]/[w2,t']) encodes order z > t via order atoms. The quantifier at depth d gives existential transfer at [z,t]/[w2,t']. In particular, x exists above z in M with certain properties (x is above z). By the existential transfer, there exists a point above w2 in N with matching properties. This point is at or above x'. But wait, x is not "above z" in the standard sense -- x > z is the order.

Actually: in the depth-(d+1) 2-var agreement at [z,t]/[w2,t'], the quantifier condition gives: for any chi at depth d arity 3, (exists u, nf_eval M d 3 [u, z, t] chi) iff (exists u', nf_eval N d 3 [u', w2, t'] chi). In particular, x satisfies some depth-d 3-var NF at [x, z, t]. The existential transfer gives: exists u' in N with the same NF at [u', w2, t']. The NF includes the order atom x > z (position 0 > position 1), so u' > w2. Since w2 >= x', we get u' > w2 >= x'. But we need w2 < x', not u' > x'.

This doesn't directly help. The order information flows in the wrong direction.

An alternative: use the 2-var agreement at [z,x]/[w1,x']. The quantifier gives: (exists u, nf_eval M d 3 [u, z, x] chi) iff (exists u', nf_eval N d 3 [u', w1, x'] chi). Since t < z in M (t is below z), t satisfies some NF at [t, z, x]. The transfer gives u' in N with the same NF at [u', w1, x']. The order: t < z (position 0 < position 1) implies u' < w1. Since w1 <= t', u' < w1 <= t'. But we need something in (t', x').

### Alternative Approach: Change Theorem Depth

If the fundamental gap cannot be closed, consider proving the theorem at depth K+1 (not K+2) from depth-(K+2) 1-var agreements:

```
h_x at depth K+2 -> 2-var agreement at depth K+1
```

This drops the depth by 1 (matching Rabinovich's Lemma 5.1). The outer theorem would then need adjustment: instead of depth-(K+2) 2-var from depth-(K+2) 1-var, prove depth-(K+1) 2-var from depth-(K+2) 1-var. The downstream consumers (KampBypass etc.) would need to adapt to the lower depth.

This is a STRUCTURAL CHANGE to the theorem and may propagate through the codebase.

### Alternative Approach: Restructure Strong Induction

Instead of strong induction on K at arity 2, use strong induction on the TOTAL depth D at ALL arities simultaneously:

```
forall D, forall r, forall envM envN,
  [1-var at depth D] -> [order] -> [Prior] ->
  forall nf at depth D-1 arity r,
  nf_eval M (D-1) r envM nf iff nf_eval N (D-1) r envN nf
```

This bundles the arity into the induction. At each step D:
- Atom agreement from 1-var + order (depth-independent)
- Quantifier at depth D-2 arity r+1: by IH at depth D-1 arity r+1

The IH at depth D-1 arity r+1 needs 1-var at depth D-1. From the outer hypothesis (1-var at depth D), weaken. checkmark.

But the IH for the new existential variable z/z': need 1-var at depth D-1 for z/z'. cross_extend gives depth-(D-1) 1-var. checkmark.

This avoids the gap because the induction is on D (total depth) with arity universally quantified. There's no h_rvar requirement.

The zone-3 witness finding still needs Prior-UZ + the interval existence argument.

## Sorry Inventory (5 sorries)

1. Line 515: `prior_exist_transfer_one_dir` body (NEW - the helper theorem)
2. Line 607: zone-3 existential transfer (until forward) - unchanged
3. Line 612: zone-3 existential transfer (until backward) - unchanged
4. Line 663: zone-3 existential transfer (since forward) - unchanged
5. Line 667: zone-3 existential transfer (since backward) - unchanged

Once line 515 is resolved, lines 607/612/663/667 can be filled by applying the theorem.

## Immediate Next Action

1. Prove `prior_exist_transfer_one_dir` by induction on d, handling the zone-3 witness existence via a case split on whether cross_extend companions fall in the interval
2. For the hard case (both companions outside interval): prove existence via the temporal formula + Prior-UZ/SZ + the 2-var agreement quantifier conditions
3. Apply the theorem at the 4 sorry sites

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (added import and theorem statement)
