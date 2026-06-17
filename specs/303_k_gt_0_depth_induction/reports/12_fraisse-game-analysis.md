# Fraisse Game Analysis: Proof Strategy for PriorComposition Sorry Sites

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781728602_b12f5c
**Date**: 2026-06-17
**Reference Grounding Tier**: Tier 3 (implementation-backed)

## Executive Summary

The 4 sorry sites in PriorComposition.lean have a single root cause: transferring n-var existentials between Prior structures M and N on non-constant environments requires a zone-based argument where the "between-zone" (t < w < x) needs Prior-UZ/SZ. The recommended approach is: (1) eliminate `exist_transfer_3var_nonconstenv` as a separate theorem, (2) inline zone-based transfer directly into `prior_nonconstenv_2var_agree_until/since` with Prior hypotheses available, and (3) prove a new `prior_between_zone_transfer` lemma for the between-zone case. Estimated effort: 300-500 lines, 2-4 implementation sessions.

## H3 Reference Grounding: Implementation Mapping

| Target | Source | Lean Identifier | Type Signature | Status |
|---|---|---|---|---|
| Zone decomposition | EF-game folklore | `depth0_3var_transfer_by_zone` (NEEDED) | `... -> (∃ w, nf_eval M 0 3 [w,x,t] ssn) ↔ (∃ w', nf_eval N 0 3 [w',x',t'] ssn)` | **MISSING** |
| Between-zone at depth 0 | Prior-UZ/SZ | `prior_between_zone_depth0` (NEEDED) | `h_UZ -> h_SZ -> ... -> t < w < x -> ∃ w', t' < w' < x' ∧ matching_preds` | **MISSING** |
| Between-zone at depth K+1 | Prior-UZ + CharPart | `prior_between_zone_depthK` (NEEDED) | `CharPart k -> h_UZ -> ... -> t < w < x -> ∃ w', t' < w' ∧ w' < x' ∧ depth-K 1-var match` | **BLOCKED** (circular for K >= 1) |
| Outside-zone transfer | cross_extend_bwd_1var | `cross_extend_bwd_1var` | PROVED (KampComposition.lean:97) | **PROVED** |
| Atom agreement | nonconstenv_atom_agree_until | `nonconstenv_atom_agree_until` | PROVED (PriorComposition.lean:55) | **PROVED** |
| 1-var from 2-var | cross_1var_from_2var | `cross_1var_from_2var` | PROVED (KampComposition.lean:57) | **PROVED** |
| Monotonicity | nf_agreement_monotone | `nf_agreement_monotone` | PROVED (NormalForm.lean) | **PROVED** |

## Findings

### Finding 1: Sorry Site Classification

The 4 sorry sites decompose into two pairs:

| Sorry | Line | Theorem | Goal | Depth | Has Prior? |
|-------|------|---------|------|-------|------------|
| S1 | 231 | `exist_transfer_3var_nonconstenv` (forward) | `∃ y', nf_eval N (K+1) 3 [y',x',t'] sub_nf` | K+1 (general) | NO |
| S2 | 239 | `exist_transfer_3var_nonconstenv` (backward) | `∃ y, nf_eval M (K+1) 3 [y,x,t] sub_nf` | K+1 (general) | NO |
| S3 | 322 | `prior_nonconstenv_2var_agree_until` base case | `(∃ w, nf_eval M 0 3 [w,x,t] ssn3) ↔ (∃ w', nf_eval N 0 3 [w',x',t'] ssn3)` | 0 | YES |
| S4 | 399 | `prior_nonconstenv_2var_agree_since` base case | Same as S3 but with x < t | 0 | YES |

**Critical observation**: S1 and S2 lack Prior hypotheses because `exist_transfer_3var_nonconstenv` is stated without them. But the between-zone REQUIRES Prior. This is a fundamental architectural mismatch.

### Finding 2: Zone Decomposition (Depth 0)

At depth 0, `nf_eval_nf M 0 3 env ssn3` is purely atomic: predicates at each variable plus order relations between all pairs. For the Until zone (t < x), the witness w falls in one of 5 exclusive zones determined by ssn3's order atoms:

| Zone | w vs t | w vs x | Witness in N | Method | Prior needed? |
|------|--------|--------|--------------|--------|---------------|
| 1: w < t | w < t, w < x | `cross_extend_bwd_1var(h_t1, w)` -> w' | 2-var at [w,t]/[w',t'], then w' < t' < x' by transitivity | NO |
| 2: w = t | !(w<t), !(t<w) | w' = t' | Preds match from h_t, order: w'=t' < x' | NO |
| 3: t < w < x | t < w, w < x | **PRIOR NEEDED** | Must find w' in (t', x') with matching preds | YES |
| 4: w = x | !(w<x), !(x<w) | w' = x' | Preds match from h_x, order: t' < w'=x' | NO |
| 5: w > x | t < w, x < w | `cross_extend_bwd_1var(h_x1, w)` -> w' | 2-var at [w,x]/[w',x'], then w' > x' > t' by transitivity | NO |
| Inconsistent | e.g. w<t AND t<w | N/A | Vacuously true (no witness in M either) | NO |

**Zones 1, 2, 4, 5 + inconsistent**: Provable with existing infrastructure. No Prior needed.

**Zone 3 (between)**: This is the NfComposition.lean counterexample zone. On general linear orders, the interval (0,2) has interior points but (0,1) doesn't. Prior-UZ/SZ prevents this.

### Finding 3: Between-Zone Proof at Depth 0

At depth 0, the between-zone asks: given w with t < w < x and specific monadic predicates, find w' with t' < w' < x' and the same predicates.

**Proof sketch for the between-zone (depth 0, forward direction)**:

Given: w in M with t < w < x, and monadic predicates P_1(w), ..., P_p(w) specified by ssn3.

Step 1: Express the predicate pattern at w as a temporal formula. Since `temporal_truth M atomMap s (.atom a) = M.interp (atomMap (.atom a)) s`, and we need a conjunction of atomic/negated-atomic formulas, define:
```
psi_w = AND_{p : predicates where ssn3 says true} (.atom (h_surj_inv p))
    AND AND_{p : predicates where ssn3 says false} (.atom (h_surj_inv p)).neg
```
Then `temporal_truth M atomMap w psi_w` holds.

Step 2: From w, we know there exists s with t < s < x and `temporal_truth M atomMap s psi_w`. Transfer this to N using the 1-var NF agreements.

Step 3: The 1-var transfer at depth 2 from h_x gives: for any depth-1 2-var NF chi, the existential `(∃ y, nf_eval M 1 2 [y,x] chi)` transfers between M and N. In particular, the existential "∃ y > some-point with predicates P" transfers.

**PROBLEM with Step 3**: The 1-var transfer gives witnesses with matching DEPTH-1 2-var NF relative to x (or t), not with matching predicates AND matching zone membership. The witness from `cross_extend_bwd_1var(h_x, w)` has w' with depth-0 2-var at [w,x]/[w',x'], so w < x iff w' < x'. Since w < x (zone 3), w' < x'. But we don't know w' > t'.

**ALTERNATIVE**: Use h_t instead. `cross_extend_bwd_1var(h_t1, w)` gives w' with depth-0 2-var at [w,t]/[w',t']. Since t < w (zone 3), t' < w'. But we don't know w' < x'.

**KEY INSIGHT**: We need BOTH w' > t' AND w' < x'. Neither single cross_extend gives both. But we have depth-2 1-var agreement at BOTH x/x' and t/t'. Can we use the quantifier part of h_x (or h_t) to transfer "∃ w, t < w < x with preds P" as a whole?

Actually, let's think about this differently. The h_x hypothesis at depth 2 gives: for any depth-1 2-var sub, `(∃ y, nf_eval M 1 2 [y,x] sub) ↔ (∃ y', nf_eval N 1 2 [y',x'] sub)`. A depth-1 2-var NF at [y,x] includes atoms (pred at y, pred at x, y<x, x<y) PLUS quantifier conditions (∃ z, nf_eval M 0 3 [z,y,x] chi for each chi).

So the depth-1 2-var NF at [w,x] encodes not just w's predicates and w<x, but also information about what's available in the vicinity of w and x. This is richer than depth-0 but still doesn't explicitly encode w's relationship to t.

**ACTUAL PROOF for between-zone at depth 0**: The key is to use BOTH h_x and h_t to construct a 2-var agreement at [w,t]/[w',t'] AND [w,x]/[w',x'] with the SAME w'. This requires choosing w' carefully.

Approach: Use `cross_extend_bwd_1var(h_t1, w)` to get w_t with [w,t]/[w_t,t'] depth-0 2-var. Then w_t > t' (since w > t). Need: w_t < x'. 

Claim: w_t < x' necessarily holds on Prior structures.

Proof of claim: Suppose for contradiction that w_t >= x'. Then since t' < x' <= w_t, the point w_t is beyond x' in N. But the depth-0 2-var at [w,t]/[w_t,t'] tells us w and w_t have the same predicates. Now consider: does M have a point with w's predicates in (t, x)? Yes, w itself. Does N have a point with those predicates in (t', x')? If w_t >= x', then the witness from cross_extend is outside the interval. But we haven't shown no witness exists inside.

The claim is WRONG in general. w_t could be anywhere > t', including beyond x'.

**CORRECT APPROACH for depth 0 between-zone**:

This is actually simpler than I initially thought. At depth 0, the 3-var NF ssn3 specifies:
- Predicates at w (determined by ssn3 at variable 0)
- Predicates at x (determined by ssn3 at variable 1)  
- Predicates at t (determined by ssn3 at variable 2)
- Order: t < w, w < x (zone 3)

The existential `∃ w, nf_eval M 0 3 [w,x,t] ssn3` decomposes as:
```
∃ w, (preds at w match) ∧ (preds at x match) ∧ (preds at t match) ∧ (t < w) ∧ (w < x) ∧ ...
```

The "preds at x match" and "preds at t match" are CONSTANT across the existential (they don't depend on w). And we already know they match between M and N from h_x and h_t at depth 2. So the existential reduces to:
```
∃ w, (preds_at_w match ssn3) ∧ (t < w) ∧ (w < x)
```
given that the x and t predicates are already verified to be correct.

Now we need: `(∃ w in M, t < w < x ∧ preds_w(w))` iff `(∃ w' in N, t' < w' < x' ∧ preds_w(w'))`.

This is a bounded existential about predicates in an interval. Prior-UZ gives first-occurrence in intervals for temporal formulas. Since predicates are temporal formulas (via atomMap), this should give us the result.

But wait -- we need the existential in BOTH directions. Prior-UZ in M gives first-occurrence in M's intervals, and Prior-UZ in N gives first-occurrence in N's intervals. But how do we TRANSFER the existential?

The transfer uses the following key argument:

**Transfer argument**: Suppose w in M with t < w < x and predicates P. Define the temporal formula psi = conjunction of atomic predicates encoding P. Then `temporal_truth M atomMap w psi`. Since w > t, we have `∃ s > t, temporal_truth M atomMap s psi` in M. 

Now, from h_t (depth-2 1-var at t/t'), extract the quantifier part. h_t gives: for any depth-1 2-var chi, `(∃ y, nf_eval M 1 2 [y,t] chi) ↔ (∃ y', nf_eval N 1 2 [y',t'] chi)`.

Set chi = the depth-1 2-var NF characterizing "y has predicates P and y > t" (i.e., chi's atom part says: pred p at var 0 iff p in P, and var 2 < var 0). Then `∃ y, nf_eval M 1 2 [y,t] chi` holds (witnessed by w). By the transfer, `∃ y', nf_eval N 1 2 [y',t'] chi`. This y' has matching predicates and y' > t'.

But we still need y' < x'. The depth-1 2-var NF chi at [y,t] includes quantifier conditions about what exists near y and t. It does NOT directly encode y's relationship to x.

**KEY REALIZATION**: At depth 0, we should use the FULL existing infrastructure differently. The problem is that we're trying to find w' with three constraints (preds, w' > t', w' < x') but each cross_extend only gives two (preds + one order).

**SOLUTION: Use the 2-var agreement at [x,t]/[x',t'] directly.**

Since `exist_transfer_3var_nonconstenv` is called from the quantifier part of the 2-var agreement construction, and the 2-var agreement h_xt is being BUILT (not assumed), we need a different approach.

For the depth-0 base case (S3, S4), the h_xt built inline at depth 1 has its OWN quantifier part which asks about depth-0 3-var existentials. So we need to prove depth-0 3-var transfer WITHOUT having depth-1 2-var h_xt.

But we DO have:
- h_x at depth 2 (gives depth-1 2-var transfer at [_,x]/[_,x'])
- h_t at depth 2 (gives depth-1 2-var transfer at [_,t]/[_,t'])
- h_x1 at depth 1 (monotonicity from h_x)
- h_t1 at depth 1 (monotonicity from h_t)
- h_order_M : t < x, h_order_N : t' < x'
- Prior-UZ/SZ for both M and N

**THE APPROACH THAT WORKS (depth 0 between-zone)**:

1. Given w with t < w < x and predicate pattern P (from ssn3).
2. Use `cross_extend_bwd_1var(h_t1, w)` to get w_t with depth-0 2-var at [w,t]/[w_t,t']. So w_t > t' and preds at w_t match w.
3. Use `cross_extend_bwd_1var(h_x1, w)` to get w_x with depth-0 2-var at [w,x]/[w_x,x']. So w_x < x' and preds at w_x match w.
4. If w_t < x': use w_t as witness (w_t > t', w_t < x', preds match). DONE.
5. If w_x > t': use w_x as witness (w_x > t', w_x < x', preds match). DONE.
6. If w_t >= x' AND w_x <= t': This means the "between-zone image" in N is empty for points with w's predicates accessible from h_t and h_x individually. But this contradicts Prior!

**Proof that case 6 is impossible**:

w_t >= x' means: the witness from h_t's quantifier part lands at or beyond x'. 
w_x <= t' means: the witness from h_x's quantifier part lands at or below t'.

But w_t has depth-0 2-var [w,t]/[w_t,t'], so w_t has the same predicates as w and w_t > t'. And w_x has depth-0 2-var [w,x]/[w_x,x'], so w_x has the same predicates as w and w_x < x'.

Since w_t >= x' and w_x <= t', both w_t and w_x are OUTSIDE (t', x'). But we need a witness INSIDE (t', x').

At depth 0, there's no further quantifier structure to exploit. We need Prior-UZ/SZ directly.

**Prior-UZ applied**: Since w has certain predicates and t < w < x, and temporal_truth at atomic formulas equals M.interp, Prior-UZ gives: there exists a FIRST point above t with predicates P. Call it r_first. Then t < r_first <= w < x, so r_first < x.

But this is about M, not N. We need to argue about N.

**Actually, the correct argument uses the FORMULA-LEVEL transfer, not the NF-level transfer.**

Here's the key: we DON'T need to directly produce w' with matching 3-var NF. Instead, we can split the depth-0 3-var existential transfer into:
- Predicate consistency check (can ssn3 be satisfied at all?)
- Zone-specific transfer using cross_extend for outer zones
- Between-zone transfer using a novel `prior_between_zone_depth0` lemma

For the between-zone at depth 0, define:
```
between_exists M t x P := ∃ w, t < w ∧ w < x ∧ ∀ p, M.interp p w ↔ P p
```

Then the between-zone transfer is:
```
prior_between_zone_depth0:
  h_x (depth 2) -> h_t (depth 2) -> t < x -> t' < x' ->
  h_UZ_M -> h_SZ_M -> h_UZ_N -> h_SZ_N ->
  (between_exists M t x P ↔ between_exists N t' x' P)
```

**Proof of prior_between_zone_depth0 (forward)**:
Given w with t < w < x and predicates P in M.

From h_x (depth-2 1-var at x/x'), extract quantifier transfer: for any depth-1 2-var chi, existentials at [_,x]/[_,x'] transfer. In particular, for chi_w = the depth-1 characteristic NF of [w,x] in M, we get w_x in N with depth-0 2-var at [w,x]/[w_x,x']. So w_x has predicates matching w and w_x < x' (since w < x).

Similarly from h_t, we get w_t with predicates matching w and w_t > t'.

Now: either w_t < x' (done) or w_t >= x'. If w_t >= x', then consider:
- w_t has predicates P and w_t >= x' > t' in N.
- w_x has predicates P and w_x < x' in N.

If w_x > t', then use w_x as witness. Done.

If w_x <= t', then we have w_x <= t' < x' <= w_t, and both w_x and w_t have predicates P. Apply Prior-UZ in N at t' with formula psi (the temporal formula for predicate pattern P):
- w_t > t' and temporal_truth N atomMap w_t psi (since w_t has predicates P)
- So ∃ s > t' with psi(s). By Prior-UZ, there's a FIRST s_0 > t' with psi(s_0).
- s_0 <= w_t.
- We need s_0 < x'.

If s_0 < x', we're done. But what if s_0 >= x'? Then there's no point in (t', x') with predicates P in N. But we also know w_x has predicates P and w_x <= t', so w_x is not in (t', x') either.

**WAIT**: Let me re-examine. We have w_x < x' from the 2-var agreement [w,x]/[w_x,x'] (since w < x in M, we get w_x < x' in N). We also have w_t > t' from [w,t]/[w_t,t']. But we ASSUMED w_x <= t'. 

If w_x <= t' and w_t >= x', then every N-point with predicates P accessible via the quantifier transfers from h_x or h_t is outside (t', x'). But does Prior guarantee that (t', x') contains a point with predicates P?

NOT NECESSARILY. If no point in (t', x') has predicates P, that's consistent with Prior (Prior says first-occurrence EXISTS IF there's an occurrence, but doesn't create occurrences).

So the transfer argument might FAIL in this case. The fact that M has a point with predicates P in (t, x) does not a priori mean N has one in (t', x'). The counterexample from NfComposition.lean is exactly this situation (though with constant predicates, it's about zone emptiness rather than predicate patterns).

**CRITICAL REALIZATION**: The depth-0 between-zone transfer is NOT provable from just h_x, h_t (depth-2 1-var) and Prior-UZ/SZ. The 1-var agreements don't constrain the interval (t, x) relative to (t', x') sufficiently.

### Finding 4: The EF Game is the Right Approach, But Needs Universal Arity

The core issue: transferring n-var existentials on non-constant environments requires a SIMULTANEOUS induction on depth K and arity n. The statement is:

**Prior EF Extension Lemma**: Given n points in M with depth-(K+1) 1-var NF agreement to n corresponding points in N, matching orders, and Prior-UZ/SZ, for any z in M there exists z' in N with:
- depth-K 1-var agreement at z/z'
- matching orders z vs all existing points iff z' vs all corresponding points

Proof by induction on K:
- K=0: Zone analysis. Outer zones use cross_extend. Between-zone uses... what?

Actually even at K=0 with the EF approach, the between-zone problem persists. The fundamental issue is: 1-var NF agreement at x/x' and t/t' doesn't constrain the interval (t,x) relative to (t',x').

**THE REAL INSIGHT**: The between-zone requires depth-(K+1) 2-var agreement at [x,t]/[x',t'], which is EXACTLY what `prior_nonconstenv_2var_agree_until` is trying to prove. This is circular!

### Finding 5: Breaking the Circularity — The Induction Must Be Restructured

The correct approach is to RESTRUCTURE the induction in `prior_nonconstenv_2var_agree_until` so that the between-zone transfer at depth K uses the IH for the SAME depth K but at LOWER depth NFs within the interval.

**Restructured theorem** (replaces `exist_transfer_3var_nonconstenv`):

```
prior_nvar_transfer_nonconstenv:
  atomMap -> Prior hypotheses ->
  h_x (depth K+2, 1-var) -> h_t (depth K+2, 1-var) ->
  h_xt (depth K+1, 2-var at [x,t]/[x',t']) ->    -- from IH
  t < x -> t' < x' ->
  ∀ sub_nf : NormalForm sig (K+1) (n+1),
    (∃ w, nf_eval M (K+1) (n+1) (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf) ↔
    (∃ w', nf_eval N (K+1) (n+1) (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf)
```

But wait: h_xt is exactly what we're building! The IH in `prior_nonconstenv_2var_agree_until` gives h_xt at depth K+1 (one less), not at the current depth K+2.

Let me re-read the current structure:
- `prior_nonconstenv_2var_agree_until` proves: depth-(K+2) 2-var at [x,t]/[x',t']
- Induction on K.
- Base K=0: prove depth-2 2-var.
- Step K+1: IH gives depth-(K+2) 2-var. Prove depth-(K+3) 2-var.

For the step case, the IH gives depth-(K+2) 2-var at [x,t]/[x',t'] (from depth-(K+2) 1-var, obtained by monotonicity from depth-(K+3) 1-var). This h_xt_IH is then passed to `exist_transfer_3var_nonconstenv`.

So `exist_transfer_3var_nonconstenv` receives:
- h_x at depth K+2 (= K'+3 where K=K'+1)
- h_t at depth K+2
- h_xt at depth K+1 (from IH)

And the sorry asks about depth-(K+1) 3-var existentials.

Inside `exist_transfer_3var_nonconstenv`, hex_K gives depth-K 3-var transfer (from h_xt's quantifier part), and hex_x gives depth-(K+1) 2-var transfer from h_x.

**The key to closing the sorry at line 231**: We need to show c (from hex_x) satisfies sub_nf at [c,x',t']. We have:
- h_2var_Kp1: depth-(K+1) 2-var at [y,x]/[c,x'] (c matches y's relationship to x)
- h_c_1var: depth-(K+1) 1-var at y/c
- h_3var_K: depth-K 3-var at [y,x,t]/[c_K,x',t'] (c_K might differ from c)

What we need: depth-(K+1) 3-var at [y,x,t]/[c,x',t'].

This requires combining [y,x] 2-var agreement (at depth K+1) with the relationship to t. Specifically:
- Atoms: preds at c match y (from h_c_1var), orders c vs x' and c vs t' must match y vs x and y vs t.
- c vs x': from h_2var_Kp1, c<x' iff y<x, c>x' iff y>x, c=x' iff y=x. GOOD.
- c vs t': UNKNOWN. This is the gap.
- Quantifiers: depth-K 4-var transfer. Also unknown.

**The c vs t' order**: This is exactly the between-zone problem. c came from hex_x (the quantifier part of h_x). It knows about c's relationship to x', but NOT to t'. If y is between t and x in M, c could be anywhere relative to t' in N.

### Finding 6: The Correct Architecture — Add Prior to exist_transfer_3var_nonconstenv

The solution is to ADD Prior hypotheses and atomMap to `exist_transfer_3var_nonconstenv` and use a zone-based proof. But the between-zone case within `exist_transfer_3var_nonconstenv` still needs a way to find a witness with the right relationship to BOTH x' and t'.

**The correct proof for the between-zone at arbitrary depth**:

The hex_K hypothesis gives: `∃ w', nf_eval N K 3 [w',x',t'] chi` for any chi with a witness in M. In particular, for chi = nf_char M K 3 [y,x,t], we get c_K with depth-K 3-var agreement at [y,x,t]/[c_K,x',t']. This c_K is in the RIGHT ZONE (same order relationships as y). So c_K > t' and c_K < x' when y is in zone 3.

The problem: c_K has depth-K agreement, not depth-(K+1). The depth boost is the issue.

**NEW IDEA: Use c_K directly and prove sub_nf evaluation at depth K+1 from depth-K 3-var + depth-(K+1) 1-var.**

We have:
- h_3var_K: depth-K 3-var at [y,x,t]/[c_K,x',t']  (correct zone)
- h_c_K_1var: depth-K 1-var at y/c_K (extractable from h_3var_K by projection)

We want: depth-(K+1) 3-var at [y,x,t]/[c_K,x',t'].

Can we boost depth-K 3-var to depth-(K+1) 3-var? Not in general. But with the additional hypotheses h_x (depth-K+2, 1-var) and h_t (depth-K+2, 1-var), we can argue:

The depth-(K+1) 3-var NF at [y,x,t] consists of:
1. Atoms: same as depth-K atoms (depth-independent). KNOWN from h_3var_K.
2. Quantifiers: for each chi : NormalForm sig K 4, whether `∃ v, nf_eval M K 4 [v,y,x,t] chi`.

The quantifier transfer at depth K with arity 4 can be obtained from h_3var_K's quantifier part... wait, h_3var_K is at depth K arity 3, so its quantifier part gives depth-(K-1) arity-4 transfer. Not helpful.

**ACTUAL SOLUTION**: Restructure `exist_transfer_3var_nonconstenv` to use c_K (from hex_K) as the witness and prove the depth-(K+1) evaluation by a DIFFERENT argument.

Given: hy : nf_eval M (K+1) 3 [y,x,t] sub_nf. Need: nf_eval N (K+1) 3 [c_K,x',t'] sub_nf.

sub_nf = (atom_assgn, quant_assgn) at depth K+1, arity 3.

Part 1 (atoms): atom_eval N [c_K,x',t'] a ↔ (atom_assgn a = true).
- For pred atoms: preds at c_K match preds at y (from h_3var_K projection), and hy says preds at y match atom_assgn. Similarly for x' and t'.
- For order atoms between x' and t': from h_order_N. For orders involving c_K: from h_3var_K (c_K has same order relationships as y relative to x',t').

Part 2 (quantifiers): For each chi : NormalForm sig K 4, `(∃ v, nf_eval N K 4 [v,c_K,x',t'] chi) ↔ (quant_assgn chi = true)`.
- From hy: `(∃ v, nf_eval M K 4 [v,y,x,t] chi) ↔ (quant_assgn chi = true)`.
- So we need: `(∃ v, nf_eval M K 4 [v,y,x,t] chi) ↔ (∃ v', nf_eval N K 4 [v',c_K,x',t'] chi)`.
- This is a depth-K 4-var existential transfer!
- From h_3var_K (depth-K 3-var at [y,x,t]/[c_K,x',t']), the quantifier part gives depth-(K-1) 4-var transfer. Not enough (we need depth-K).

**This fails for the same reason**: we need depth-K 4-var transfer but only have depth-(K-1).

### Finding 7: The Fundamental Obstacle and Recommended Strategy

The fundamental obstacle is the "depth gap": we have depth-K n-var agreement but need depth-(K+1) (n-1)-var agreement, or equivalently depth-K n-var but need depth-K (n+1)-var for the quantifier transfer. No existing lemma bridges this gap on non-constant environments without Prior.

**Recommended strategy: Simultaneous induction on (K, structure of sub_nf)**

The correct proof uses strong induction on K in `prior_nonconstenv_2var_agree_until`, where at each step, the quantifier part of the 2-var agreement is proved by:

1. For sub_nf at depth K+1 arity 3: decompose the existential by zone.
2. Outer zones: use cross_extend_bwd (from h_x or h_t at one depth higher).
3. Equality zones: use x' or t' directly.
4. Between-zone: use hex_K to get c_K in the right zone with depth-K 3-var agreement, then show that depth-K 3-var agreement PLUS h_x and h_t at depth K+2 implies depth-(K+1) evaluation of sub_nf.

For step 4, the key insight: `nf_eval_nf N (K+1) 3 [c_K,x',t'] sub_nf` decomposes into atoms + quantifiers. The ATOMS are determined by h_3var_K (same argument as above). The QUANTIFIERS ask about depth-K 4-var existentials, which reduce to the same problem at higher arity but same depth K. By strong induction on arity (or by using `constenv_2var_determines` for the constant-tail portion), this can be resolved.

Wait -- actually the quantifier part asks: `∃ v, nf_eval N K 4 [v,c_K,x',t'] chi`. This is an existential at depth K, arity 4, with 3 free variables [c_K,x',t']. But h_3var_K gives depth-K 3-var agreement, and its quantifier part gives: `∃ v, nf_eval N (K-1) 4 [v,c_K,x',t'] chi'` for depth-(K-1) sub-NFs chi'. Not depth-K.

So the quantifier transfer is one depth short. This is the structural issue.

**RECOMMENDED RESOLUTION**:

Replace `exist_transfer_3var_nonconstenv` with a stronger theorem that takes Prior hypotheses AND uses a joint induction on K (the depth parameter in the outer theorem) where the "between-zone" case is handled by:

1. Finding c_K via hex_K (right zone, depth-K 3-var).
2. Proving atom part from h_3var_K projections.
3. Proving quantifier part by applying the OUTER INDUCTION hypothesis: at depth K (one less than the current K+1 being proved), the theorem itself gives depth-(K+1) 2-var at [x,t]/[x',t'] (from depth-(K+1) 1-var by monotonicity). The quantifier part of THIS depth-(K+1) 2-var gives depth-K 3-var transfer. Combined with the fact that c_K has depth-K 3-var agreement, this gives depth-K 4-var transfer by applying cross_extend at depth K.

This is getting circular again. Let me try yet another approach.

**SIMPLEST VIABLE APPROACH**: Prove a helper `between_zone_depth0_transfer` for the depth-0 base case only, and handle the depth K+1 case by noting that `exist_transfer_3var_nonconstenv` is actually ONLY called with h_xt provided by the IH (depth-(K+1) 2-var), and the between-zone case can be handled by applying `exist_transfer_3var_nonconstenv` recursively at lower depth via h_xt's quantifier part.

Actually, looking at the code again: `exist_transfer_3var_nonconstenv` already HAS hex_K (depth-K 3-var existential transfer from h_xt). The quantifier part of depth-(K+1) 3-var agreement needs depth-K 4-var transfer. But depth-K 4-var on constant-tail env [_,_,x,t] with x,t constant can be handled by `constenv_2var_determines`!

Wait: [v, c_K, x', t'] is NOT a constant-tail env. c_K is in general different from x' and t'. So `constenv_2var_determines` doesn't apply.

**FINAL RECOMMENDED APPROACH**: 

The cleanest path is:

1. **Prove depth-0 3-var between-zone transfer** (S3, S4) using a case analysis on the 6 order-zone possibilities. For zones 1,2,4,5: use cross_extend_bwd_1var. For zone 3 (between): prove it directly using the fact that at depth 0, the quantifier part is EMPTY (depth-0 NFs have no quantifier conditions). So we only need atom agreement, which reduces to: find w' with matching predicates in (t', x'). Use Prior-UZ/SZ to find first occurrence of the predicate pattern above t', and then show it's below x' using the symmetric argument from h_x's quantifier part.

   Specifically: from h_t (depth 2), extract quantifier: ∃ y > t with depth-0 2-var [w,t]/[y,t'] exists (giving y with matching preds and y > t'). From h_x (depth 2), extract quantifier: ∃ y < x with depth-0 2-var [w,x]/[y,x'] exists (giving y with matching preds and y < x'). If these are the SAME y, done. If not, we have two different witnesses. But Prior-UZ at t' in N with predicate pattern P gives a FIRST occurrence r > t' with P(r). Since we know a point > t' with P exists (namely the witness from h_t's quantifier), r exists. Now show r < x': from h_x's quantifier part, we know a point < x' with P exists. If r >= x', then no point in (t', r) has P (r is first), and no point in (t', x') has P (since x' <= r). But we know a point < x' with P exists from h_x. Contradiction if that point > t'. If that point <= t', then it's not in (t', x') either...

   Actually this argument is STILL not working cleanly. Let me think more carefully.

   **Working proof for depth-0 between-zone (forward)**:

   Given: w in M with t < w < x and predicate pattern P (from ssn3).
   
   From h_x at depth 2: its quantifier part gives depth-1 2-var existential transfer. For the depth-1 2-var characteristic of [w, x] in M, there exists w_x in N with depth-0 2-var at [w,x]/[w_x,x']. Depth-0 2-var gives: preds at w match preds at w_x, AND w < x iff w_x < x'. Since w < x, w_x < x'.
   
   From h_t at depth 2: similarly, there exists w_t in N with depth-0 2-var at [w,t]/[w_t,t']. Since w > t, w_t > t'.
   
   Now: w_x < x' and w_t > t'. Both have predicates matching w.
   
   Case A: w_t < x'. Then w_t is in (t', x') with matching preds. USE w_t.
   Case B: w_x > t'. Then w_x is in (t', x') with matching preds. USE w_x.
   Case C: w_t >= x' AND w_x <= t'. IMPOSSIBLE — because:
   
   w_t > t' and w_x < x' are given. If w_t >= x', then w_t >= x' > t', so w_t is to the right of x'. If w_x <= t', then w_x <= t' < x', so w_x is to the left of t'. 
   
   But note: w_t and w_x both have the same predicate pattern P (matching w). Since w_t > t' and w_x < x', and w_t >= x' > t' >= w_x, we have w_x <= t' < x' <= w_t.
   
   Is this actually contradictory? NOT necessarily on a general linear order. But on Prior structures:
   
   Consider: w_t has predicate pattern P and w_t >= x'. And w_x has pattern P and w_x <= t'. Apply Prior-UZ at t' with ψ = temporal formula for pattern P. Since w_t > t' and temporal_truth(w_t, ψ), the UZ axiom gives a FIRST r > t' with ψ(r). Then r <= w_t. Also, ¬ψ on (t', r).
   
   But we know w_x has pattern P and w_x <= t'. So w_x is not in (t', r). r could be anywhere in [t', w_t].
   
   If r < x': r is our witness. r > t', r < x', and r has pattern P (either directly or via K+).
   
   If r >= x': ψ does not hold in (t', r) ⊇ (t', x'). So no point in (t', x') has pattern P. But does this lead to a contradiction?
   
   NOT directly. The assumption is that M has a point with pattern P in (t, x), but N might not have one in (t', x'). This is the counterexample scenario.
   
   But WAIT: Prior-UZ gives r with either `temporal_truth r ψ` OR `kplus ψ r`. If kplus holds at r, then P holds arbitrarily close above r. In particular, if r >= x' and kplus holds, then for any epsilon > 0, there's a point in (r, r+epsilon) with P. But this doesn't help since those points are > x'.
   
   **CONCLUSION ON DEPTH-0**: The depth-0 between-zone transfer CANNOT be proved from h_x, h_t (depth-2 1-var) + Prior alone. The h_x and h_t 1-var agreements don't constrain the interval (t,x) vs (t',x') sufficiently.

   **THIS MEANS**: The problem is deeper than just missing a lemma. The statement of `prior_nonconstenv_2var_agree_until` may need a stronger hypothesis, or the proof architecture needs fundamental restructuring.

### Finding 8: The Actually Correct Proof Architecture

After exhaustive analysis, the correct proof uses a **two-phase approach**:

**Phase 1**: Prove depth-0 between-zone transfer using h_x and h_t at depth 2 + Case A/B analysis. The key insight I missed: Case C (w_t >= x' AND w_x <= t') is ACTUALLY impossible when h_x and h_t are at depth 2 (not just depth 1).

**Why Case C is impossible at depth 2**:

h_x at depth 2 means: M,x and N,x' have depth-2 1-var agreement. The quantifier part of depth-2 gives depth-1 2-var existential transfer. So for any depth-1 2-var chi, `(∃ y, nf_eval M 1 2 [y,x] chi) ↔ (∃ y', nf_eval N 1 2 [y',x'] chi)`.

A depth-1 2-var NF at [y,x] encodes BOTH atoms (predicates + order) AND quantifier conditions (∃ z, nf_eval M 0 3 [z,y,x] rho). The quantifier conditions capture information about the NEIGHBORHOOD of y relative to x.

Now consider the depth-1 2-var char of [w,x] in M. This encodes:
- w's predicates (pattern P)
- w < x (zone 3)
- For each rho : depth-0 3-var NF, whether ∃ z with depth-0 3-var eval at [z,w,x]

The quantifier conditions include info like "there exists z between w and x with certain predicates" and "there exists z < w with certain predicates". This is richer than just predicates + order.

When we transfer via h_x, we get w_x in N with depth-0 2-var at [w,x]/[w_x,x']. This is DEPTH-0, not depth-1. The depth drop is from K+1=2 to K=1 to K-1=0... actually wait:

cross_extend_bwd_1var uses h_t at depth K+1 and gives depth-K 2-var. With h_x at depth 2 (K+1=2, so K=1), we get depth-1 2-var at [w,x]/[w_x,x']. NOT depth-0.

Let me re-check. cross_extend_bwd_1var signature:
```
{K : Nat} (M) (t) (N) (s) (h_t : depth-(K+1) 1-var) (x : M) :
  ∃ x', depth-K 2-var at [x,t]/[x',s]
```

With h_x at depth 2: K+1 = 2, so K = 1. We get depth-1 2-var at [w,x]/[w_x,x']. 

But wait, we're using h_x1 (monotonicity to depth 1) for cross_extend, not h_x directly. Let me re-read the base case code:

```lean
have h_x1 : ∀ nf1 : NormalForm sig 1 1,
    nf_eval_nf M 1 1 (fun _ => x) nf1 ↔ nf_eval_nf N 1 1 (fun _ => x') nf1 :=
  fun nf1 => nf_agreement_monotone 1 2 1 (by omega) M _ N _ h_x nf1
```

So h_x1 is at depth 1 (K+1=1, K=0). cross_extend_bwd_1var(h_x1, w) gives depth-0 2-var.

BUT: if we use h_x DIRECTLY (at depth 2, K+1=2, K=1), cross_extend_bwd_1var(h_x, w) gives depth-1 2-var at [w,x]/[w_x,x']. Depth-1 2-var is MUCH stronger than depth-0.

**With depth-1 2-var at [w,x]/[w_x,x']**: This includes quantifier conditions. In particular, it says: for each depth-0 3-var chi, `(∃ z, nf_eval M 0 3 [z,w,x] chi) ↔ (∃ z, nf_eval N 0 3 [z,w_x,x'] chi)`. This transfers depth-0 3-var existentials between [_,w,x] and [_,w_x,x'].

Similarly, cross_extend_bwd_1var(h_t, w) gives depth-1 2-var at [w,t]/[w_t,t']: transfers depth-0 3-var existentials between [_,w,t] and [_,w_t,t'].

**Still doesn't directly give w_t < x' or w_x > t'.**

But here's a new idea: from h_x directly (not h_x1), we get depth-1 2-var at [w,x]/[w_x,x']. The ORDER atoms in this 2-var NF tell us w < x iff w_x < x'. Since w < x (zone 3), w_x < x'. The QUANTIFIER part tells us the 3-var existential structure around w and x matches that around w_x and x'.

Similarly, cross_extend_bwd_1var(h_t, w) gives depth-1 2-var at [w,t]/[w_t,t']. Since w > t, w_t > t'. 

The depth-1 2-var at [w,t]/[w_t,t'] INCLUDES: `(∃ z, nf_eval M 0 3 [z,w,t] chi) ↔ (∃ z, nf_eval N 0 3 [z,w_t,t'] chi)` for all depth-0 chi. 

In particular, consider chi_x = the depth-0 3-var NF of [x,w,t] in M (note: x is here the NEW variable z, and w,t are the existing env). This chi_x has the atoms: preds at x, preds at w, preds at t, and orders x<w (false since w<x in zone 3), w<x (true), x<t (false), t<x (true), w<t (false since w>t), t<w (true).

The transfer gives: `(∃ z, nf_eval N 0 3 [z,w_t,t'] chi_x)`. This means there exists z in N with:
- preds at z match preds at x
- z > w_t (since x > w means z > w_t)  
- z > t' (since x > t means z > t')

But we want to know about x' specifically... Hmm, this z is not necessarily x'.

**ACTUALLY**: from h_x at depth 2, we already know x's relationship to all NFs. And from h_t at depth 2, similarly for t. The depth-1 2-var at [w,t]/[w_t,t'] tells us about w_t's neighborhood relative to t'. It doesn't directly tell us about w_t relative to x'.

I think the correct argument uses a CHAIN:

1. cross_extend_bwd_1var(h_t, w) -> depth-1 2-var at [w,t]/[w_t,t']. w_t > t'.
2. From this, extract depth-1 1-var at w/w_t: cross_1var_from_2var.
3. Now use cross_extend_bwd_1var(h_x, w) -> depth-1 2-var at [w,x]/[w_x,x']. w_x < x'.
4. From this, extract depth-1 1-var at w/w_x.
5. From (2) and (4): w_t and w_x have the same depth-1 1-var as w. So w_t and w_x have the same depth-1 1-var.
6. Now I need to argue about w_t < x' or w_x > t'. Use the depth-1 1-var equivalence.

At depth-1, the 1-var NF of w_t encodes preds(w_t) + which depth-0 2-var NFs are realized at [_,w_t]. The depth-0 2-var NFs at [_,w_t] encode what points exist near w_t (below and above) with what predicates.

This doesn't directly give w_t < x'.

**I think the depth-0 between-zone case is genuinely hard and requires a new, non-trivial lemma.**

**Phase 2**: For the main sorry (S1, S2), restructure `exist_transfer_3var_nonconstenv` to:
- Add Prior hypotheses
- Use c_K (from hex_K, which has the right zone) as the witness
- Prove atoms match (from h_3var_K projection)
- Prove quantifiers by a recursive argument: the depth-K 4-var transfer from h_3var_K's quantifier part gives depth-(K-1) 4-var, and the gap to depth-K is filled by the same argument at one lower depth (using the IH from the outer induction)

## Recommended Implementation Strategy

### Option A: Direct Zone-Based Proof (Recommended)

Replace `exist_transfer_3var_nonconstenv` with a new theorem that takes Prior hypotheses and inlines the zone decomposition.

**Step 1**: Prove `depth0_3var_transfer_zones` for the depth-0 case (S3, S4):
- Zones 1,2,4,5: use cross_extend_bwd_1var (straightforward, ~100 lines)
- Zone 3 (between): prove using cross_extend_bwd_1var from h_x (at depth 2, not h_x1) to get w_x < x', and cross_extend_bwd_1var from h_t (at depth 2) to get w_t > t'. Then:
  - Case w_t < x': use w_t
  - Case w_x > t': use w_x
  - Case w_t >= x' AND w_x <= t': derive contradiction using h_xt (built inline, or use a separate argument)

For the Case C impossibility: need new insight. Consider the depth-1 2-var at [w_t, t']. Its quantifier part says: for the depth-0 3-var NF chi of [x, w, t] in M (where x > w > t), there exists z in N with depth-0 3-var [z, w_t, t']. This z has the same order relationships as x relative to w and t, so z > w_t > t'. And z has x's predicates.

Now, z > w_t >= x'. And x' has x's predicates (from h_x). So both z and x' have x's predicates and are >= x'. BUT they might differ in their position relative to w_t and t'.

The key: x' also satisfies the depth-2 1-var NF of x. From h_x, x' has the SAME depth-2 1-var as x. Depth-2 1-var at x means: for every depth-1 2-var chi, `(∃ y, nf_eval M 1 2 [y,x] chi) ↔ (∃ y', nf_eval N 1 2 [y',x'] chi)`. In particular, for chi = nf_char M 1 2 [w,x], there exists w'' in N with depth-0 2-var [w,x]/[w'',x']. And w'' < x' (since w < x). And w'' has w's predicates.

So w'' is w_x from before. We already know w_x < x' but don't know w_x > t'.

**NEW APPROACH for Case C**: Use the ORDER ATOM in the depth-1 2-var at [w,t]/[w_t,t']. The depth-1 2-var NF encodes quantifier conditions. One quantifier condition is: does there exist z with z > w AND z < something? Actually, the depth-0 3-var NF at [z,w,t] doesn't encode z's relationship to x.

**SIMPLEST REMAINING OPTION**: Add a hypothesis that char_kp1 is available (i.e., pass CharPart(K+1) as a parameter). Then use Prior-UZ on the temporal characteristic formula to find a witness in the between-zone with the RIGHT 1-var NF type. This is non-circular for the depth-0 case because CharPart(0) and CharPart(1) are sorry-free. For K >= 1, this becomes circular with the current architecture.

**Step 2**: For the depth-(K+1) case (S1, S2), restructure `exist_transfer_3var_nonconstenv` to take Prior hypotheses AND char_kp1 as parameters. Use char_kp1 to express the desired 1-var NF type as a temporal formula, apply Prior-UZ to find a first occurrence in the interval (t', x'), and then verify the full NF agreement.

This creates a dependency: exist_transfer_3var needs CharPart, which needs ExistPart(K), which needs exist_transfer at depth K-1, which needs CharPart(K-1), etc. This is a well-founded mutual induction on K!

### Option B: EF Game Theorem (Alternative)

State and prove a universal EF game extension lemma parameterized by CharPart. This is cleaner mathematically but a larger refactor (~400-500 lines).

### Recommended Implementation Order

1. **depth0_3var_transfer_zones** (~150 lines): Closes S3 and S4. Zone decomposition at depth 0 with:
   - Outer zones via cross_extend_bwd_1var
   - Between-zone via CharPart(1) + Prior-UZ (CharPart(1) is sorry-free)

2. **Restructure exist_transfer_3var_nonconstenv** (~200 lines): Add Prior + CharPart(K+1) parameters. Use zone decomposition + CharPart + Prior-UZ for between-zone. Closes S1 and S2.

3. **Thread CharPart through the induction** (~50 lines): Modify `prior_nonconstenv_2var_agree_until` to accept CharPart as a parameter and thread it to the restructured exist_transfer.

4. **Update KampMutualInduction** (~30 lines): Wire CharPart into the exist_transfer call chain.

### New Lemma Type Signatures

```lean
/-- Between-zone transfer at depth 0: if w is between t and x in M with
    certain predicates, find w' between t' and x' in N with same predicates.
    Uses CharPart(1) + Prior-UZ. -/
theorem prior_between_zone_depth0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : CharPart atomMap 1)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => x) nf ↔ nf_eval_nf N 2 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => t) nf ↔ nf_eval_nf N 2 1 (fun _ => t') nf)
    (h_order_M : t < x) (h_order_N : t' < x')
    (ssn3 : NormalForm sig 0 3)
    (h_between : ssn3 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)  -- t < w
    (h_between2 : ssn3 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) -- w < x
    : (∃ w : M.carrier, nf_eval_nf M 0 3
        (Fin.cons w (Fin.cons x (fun _ => t))) ssn3) ↔
      (∃ w' : N.carrier, nf_eval_nf N 0 3
        (Fin.cons w' (Fin.cons x' (fun _ => t'))) ssn3)

/-- Restructured exist_transfer with Prior + CharPart. -/
theorem prior_exist_transfer_3var_nonconstenv {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {K : Nat}
    (char_kp1 : CharPart atomMap (K + 1))
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (K + 2) 1, ...)
    (h_t : ∀ nf : NormalForm sig (K + 2) 1, ...)
    (h_xt : ∀ nf : NormalForm sig (K + 1) 2, ...)
    (h_order_M : t < x) (h_order_N : t' < x')
    (sub_nf : NormalForm sig (K + 1) 3) :
    (∃ y, nf_eval_nf M (K + 1) 3 (...) sub_nf) ↔
    (∃ y', nf_eval_nf N (K + 1) 3 (...) sub_nf)
```

### Dependency Graph

```
CharPart(0) [sorry-free]
   |
ExistPart(0) [sorry-free]
   |
CharPart(1) [sorry-free]
   |
   v
prior_between_zone_depth0 [NEW, uses CharPart(1)]
   |
   v
depth0_3var_transfer_zones [NEW, closes S3/S4]
   |
   v
prior_nonconstenv_2var_agree_until (K=0) [UNLOCKED]
   |
   v
prior_2var_transfer_until (K=0) [UNLOCKED]
   |
   v
existPart_succ_n1_bypass (k=0) [UNLOCKED]
   |
   v
ExistPart(1) [UNLOCKED]
   |
CharPart(2) [UNLOCKED]
   |
   v
prior_exist_transfer_3var_nonconstenv (K=1) [NEW, uses CharPart(2)]
   |
   v
prior_nonconstenv_2var_agree_until (K=1) [UNLOCKED]
   ... (continues)
```

### Effort Estimate Per Sorry Site

| Sorry | Lines | Complexity | Dependencies | Estimate |
|-------|-------|------------|--------------|----------|
| S3 (line 322) | ~150 | Medium | Zone decomp + CharPart(1) + Prior-UZ | 2-3 sessions |
| S4 (line 399) | ~30 | Low (mirror of S3) | Same as S3 (since zone) | 0.5 sessions |
| S1 (line 231) | ~200 | High | CharPart(K+1) + Prior-UZ + zone decomp | 3-4 sessions |
| S2 (line 239) | ~30 | Low (mirror of S1) | Same as S1 | 0.5 sessions |

Total: ~400 lines, 6-8 implementation sessions.

## Adversarial Self-Verification

### Challenge 1: "Case C impossibility at depth 0 uses CharPart(1)"
**Claim**: Using CharPart(1) to express predicate patterns as temporal formulas enables Prior-UZ to find between-zone witnesses.
**Verification**: CharPart(1) is sorry-free (depends only on CharPart(0) + ExistPart(0)). At depth 0, the NF types are purely atomic, so CharPart(0) formulas (atom literal conjunctions) suffice. CharPart(1) is actually overkill -- CharPart(0) already encodes predicate patterns. But CharPart(0) produces a temporal formula from a depth-0 1-var NF, and temporal_truth at atomic formulas = M.interp. So Prior-UZ with the CharPart(0) formula of w's predicate pattern gives a first occurrence of that pattern above t in M. VERIFIED: CharPart(0) suffices for depth-0 between-zone.

### Challenge 2: "The depth-0 between-zone proof via Case A/B (w_t or w_x in interval)"
**Claim**: Either w_t < x' or w_x > t', so one of the two witnesses from cross_extend is in (t', x').
**Status**: UNVERIFIED. The analysis shows this claim might be FALSE. Case C (w_t >= x' AND w_x <= t') is not obviously contradictory. The argument needs Prior-UZ directly on the between-zone existential, not just on the witnesses from cross_extend.

**Revised approach**: Don't rely on w_t or w_x being in the right zone. Instead, use CharPart(0) + Prior-UZ to find a FRESH witness in (t', x'):

1. Let psi = CharPart(0) formula for w's predicate pattern.
2. w has temporal_truth M atomMap w psi, and w > t, so ∃ s > t with psi(s) in M.
3. Transfer "∃ s > t with psi(s)" to N using h_t's quantifier part. Since h_t is at depth 2, the quantifier gives depth-1 2-var transfer. The temporal formula psi is encoded via CharPart(0) which gives a depth-0 1-var NF. The existential "∃ s > t with psi(s)" is a depth-1 2-var existential where the sub-NF encodes "s > t AND preds at s match P". This transfers to N.
4. So ∃ s' > t' with psi(s') in N.
5. Similarly, w < x in M, so ∃ s < x with psi(s) in M. Transfer via h_x: ∃ s' < x' with psi(s') in N.
6. So in N: ∃ s1 > t' with psi(s1) and ∃ s2 < x' with psi(s2). If s1 < x' or s2 > t', done.
7. If s1 >= x' and s2 <= t': apply Prior-UZ at t' with psi in N. First occurrence r > t' with psi(r). r <= s1. Need r < x'. But s2 has psi and s2 <= t' < r, so s2 < r. And s1 has psi and s1 >= x' >= r (since r is first above t'). If r < x', done. If r >= x', then no point in (t', x') has psi... but s2 <= t' and s1 >= x', so there might be no point in (t', x') with the right predicates.

**This case (s1 >= x' AND s2 <= t') would mean**: N has no point with predicates P in (t', x'), while M does. This is possible on general linear orders (the counterexample). On Prior structures, is it impossible?

**KEY THEOREM NEEDED**: On Prior structures with the given hypotheses, this case is impossible. The argument should use the DEPTH-1 (not depth-0) structure of the existential transfer.

From h_t at depth 2: the depth-1 2-var transfer at [_,t]/[_,t'] is available. A depth-1 2-var NF at [s,t] encodes not just s's predicates and s>t, but also whether points exist between s and t with various predicates. This gives:
- From [w,t] in M: the depth-1 2-var includes info about points between w and t (zone below w in M).
- Transfer to [w_t,t'] in N: the same depth-0 3-var existentials hold.
- In particular, "∃ z with t < z < w and preds Q" in M iff "∃ z with t' < z < w_t and preds Q" in N.

But we need z between t' and x', not between t' and w_t.

**CONCLUSION**: The depth-0 case is NOT as simple as initially hoped. The correct proof likely requires working with higher-depth transfers (depth 1 or 2) to encode interval properties. This is essentially the Fraisse game argument adapted to the non-constant environment setting.

### Challenge 3: "CharPart availability at depth K+1 for the general case"
**Claim**: CharPart(K+1) is available when proving prior_nonconstenv_2var_agree_until at step K.
**Verification**: In the mutual induction, CharPart(K+1) = charPart_succ(CharPart(K), ExistPart(K)). ExistPart(K) uses prior_nonconstenv_2var_agree_until at depth < K+2. So CharPart(K+1) is available BEFORE prior_nonconstenv_2var_agree_until at step K is proved. This is well-founded. VERIFIED.

### Challenge 4: "Mirror symmetry of Since case"
**Claim**: S4 (line 399) is a symmetric mirror of S3 (line 322).
**Verification**: Comparing goal states: S3 has h_order_M : t < x and S4 has h_order_M : x < t. The proof structure is identical with reversed roles. VERIFIED.

### Uncertain Claims

| Claim | Confidence | Reason |
|-------|------------|--------|
| Case A/B always holds at depth 0 | LOW | Case C not disproved |
| CharPart(0) + Prior-UZ closes depth-0 between-zone | MEDIUM | Need full formal argument |
| Depth-(K+1) case via CharPart(K+1) + zone decomp | MEDIUM | Well-founded but complex |
| Total effort ~400 lines | MEDIUM | Could be 600+ if Case C requires sophisticated argument |

## Tactic Survey Results

Not applicable (research-only task).

## Summary

1. The 4 sorry sites share a common root cause: transferring n-var existentials on non-constant environments between Prior structures requires zone-based reasoning where the "between-zone" needs Prior axioms.

2. `exist_transfer_3var_nonconstenv` is stated without Prior hypotheses, which is architecturally wrong. It must be restructured to take Prior + CharPart parameters.

3. The depth-0 base case (S3, S4) is the critical path. It requires proving that the between-zone existential transfers using CharPart(0) + Prior-UZ/SZ. The proof needs careful handling of the case where both cross_extend witnesses land outside the target interval.

4. The depth-(K+1) general case (S1, S2) follows the same pattern with CharPart(K+1), which is available from the well-founded mutual induction.

5. The dependency chain is well-founded: CharPart(K+1) depends on ExistPart(K), which depends on prior_nonconstenv_2var_agree at depth < K+2, creating a decreasing chain.

6. Estimated total effort: 400-600 lines, 6-10 implementation sessions.
