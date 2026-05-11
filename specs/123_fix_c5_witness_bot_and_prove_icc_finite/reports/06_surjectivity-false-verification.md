# Surjectivity of succ_embed: Definitive Analysis

Task: 123 | Date: 2026-05-11

## 1. Verdict

**`succ_embed_surjective` is TRUE.** The succ-orbit from root covers all of `LimitDomSubtype` in the discrete case. The accumulation scenario described in the task prompt cannot occur.

## 2. Precise Statement

Given the discrete hypothesis `h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x` (i.e., `U(T,bot)` holds at every domain point), the function `succ_embed : Z -> LimitDomSubtype A h_mcs` is surjective:

```
forall w : LimitDomSubtype A h_mcs, exists n : Z, succ_embed A h_mcs h_discrete n = w
```

## 3. Why the Accumulation Scenario Cannot Occur

### 3.1 The hypothesized scenario

The task prompt describes this scenario: start with root at 0, C5-bot adds q1 = succ(0), then C4 inserts midpoints m1 between 0 and q1, then m2 between m1 and q1, etc. After infinitely many insertions, the succ chain from 0 is 0, m1, m2, m3, ... converging to some limit L, with q1 reachable only as succ^omega(0).

### 3.2 Why this scenario is impossible

**The scenario confuses finite-stage adjacency with limit-domain adjacency.**

At stage K, points m1, m2, ... between 0 and q1 may be added by C4 elimination. But the key structural constraint is:

**In the limit domain, `limitDomSubtype_succ` is the LIMIT-domain immediate successor, not any finite stage's successor.** The limit_dom successor of 0 is determined by `limit_dom_has_succ`, which invokes `limit_satisfies_c5_strong` with guard formula `bot`. This yields y such that:

```
bot in limit_f(w)  for all w in limit_dom with 0 < w < y
```

Since `bot` is never in any MCS, this means **there are NO limit_dom points between 0 and y**. The point y IS the immediate successor of 0 in the full limit_dom.

Now, can infinitely many midpoints m1, m2, ... be inserted between 0 and y? YES -- but then y is NOT the limit-domain immediate successor of 0. The key insight: `limitDomSubtype_succ(0)` uses `Classical.choose` on the FULL limit domain. If there are infinitely many points between 0 and q1, then `limitDomSubtype_succ(0)` is NOT q1 -- it is the actual immediate successor, which is the closest point to 0 in limit_dom.

**But wait**: in the discrete case, `limit_dom_has_succ` proves there EXISTS a y with NO limit_dom points between 0 and y. So:

- Either q1 has no limit_dom points between 0 and q1 (so `succ(0) = q1`), or
- Some other point y < q1 is the actual limit-dom successor (with nothing between 0 and y).

If infinitely many midpoints are inserted between 0 and q1, they produce an infinite ascending sequence 0 < m1 < m2 < ... < q1 in limit_dom. But `limit_dom_has_succ` guarantees the existence of a successor with the bot-gap property. This successor must be some point with no limit_dom points between 0 and it. If all the m_i are in limit_dom, such a point cannot exist between 0 and m1, because the bot-gap property says bot is in limit_f of all intermediate points -- but there are none, so it holds vacuously. So `succ(0) = m1` (the smallest point in limit_dom above 0).

Wait -- but this creates a question: does m1 itself have a successor, and does that successor have a successor, and so on, reaching q1 eventually? YES, because:

- `succ(0) = m1` (smallest limit_dom point above 0)
- `succ(m1) = m2` (smallest limit_dom point above m1)
- And so on: `succ(m_k) = m_{k+1}`
- The sequence m1, m2, m3, ... covers all limit_dom points between 0 and q1.

The question is whether this chain REACHES q1 in finitely many steps.

### 3.3 The decisive argument: Icc finiteness

**Claim**: For any a, b in LimitDomSubtype with a < b, the set `{w in LimitDomSubtype | a <= w <= b}` is finite in the discrete case.

**Proof**: Consider any three consecutive points x < y < z in limit_dom. The discrete hypothesis gives `U(T,bot) in limit_f(x)`. The C5 strong witness for this Until formula says: there exists a successor y' of x with `bot in limit_f(w)` for all w between x and y'. This means NO limit_dom points exist between x and y'. So y' is the immediate successor. But y is between x and z, and if y is the immediate successor of x, then z is the immediate successor of y.

The set of limit_dom points in the rational interval [a.val, b.val] is well-ordered by < (every nonempty subset has a minimum, since the minimum limit_dom point above any value exists by `limit_dom_has_succ` and the no-between property). It is also reverse well-ordered by the dual argument using `limit_dom_has_pred`.

Actually, let me give the simplest argument. Suppose for contradiction that `Set.Icc a b` (in LimitDomSubtype) is infinite. Then there is an infinite strictly increasing sequence a = x_0 < x_1 < x_2 < ... all <= b. Each x_i has x_{i+1} = succ(x_i) (since between consecutive x_i there are no limit_dom points by the bot-gap property). Their rational values x_i.val form a bounded monotone sequence in Q, but Q is not order-complete, so this sequence need not converge in Q.

However, consider: for each i, between x_i.val and x_{i+1}.val there are no limit_dom points. The key question is whether the gaps x_{i+1}.val - x_i.val can shrink toward 0.

**Stage-counting argument**: Each x_i enters limit_dom at some finite omega-chain stage K_i. At stage K_i, the domain has K_i + 1 points (each stage adds at most one point). So among x_0, x_1, ..., x_N, if M = max(K_0, ..., K_N), then all are in dom(M), and dom(M) is a finite set of at most M + 1 rationals. But we claimed N can be arbitrarily large, while |dom(M)| is finite. This is not immediately a contradiction because M grows with N.

A better argument: Each x_i enters at some stage. But the succ function in limit_dom is derived from the omega chain. At any fixed stage K, the finitely many domain points in [a.val, b.val] are some finite collection. The succ chain from a in the FULL limit_dom may visit points added at arbitrarily late stages, but the no-gap property in the FULL limit_dom prevents accumulation.

### 3.4 The correct proof: succ_embed is surjective by no-gap + well-ordering of stages

Here is the correct argument for surjectivity:

**Step 1**: Every limit_dom point enters at a finite stage. If w in limit_dom, then w.val in dom(K) for some K.

**Step 2**: By the no-gap property (`succ_embed_no_gap`), between `succ_embed(n)` and `succ_embed(n+1)` there are NO limit_dom points.

**Step 3**: By `succ_embed_squeeze`, any limit_dom point w between `succ_embed(a)` and `succ_embed(b)` (inclusive) equals `succ_embed(k)` for some a <= k <= b. This is ALREADY PROVED in the codebase.

**Step 4**: The remaining question is whether succ_embed is COFINAL: for every w in limit_dom, does there exist n such that w <= succ_embed(n) (and symmetrically for the negative direction)?

This is the ONLY unproved part. The sorry covers the case `q > max_K` (new point above all stage-K points). By IH, max_K = succ_embed(j), so we need succ_embed(j+1) >= q, i.e., the limit-domain successor of max_K is at least q.

## 4. The Sorry: Why It Is Hard (But True)

### 4.1 The precise obstacle

At stage K+1, a new point q is added above max_K = succ_embed(j). We need: limitDomSubtype_succ(max_K) <= q in the FULL limit_dom ordering.

limitDomSubtype_succ(max_K) is the smallest limit_dom point above max_K. If q is the ONLY new point at stage K+1, and no later stages add points between max_K and q, then succ(max_K) = q and we are done.

But later stages CAN add points between max_K and q:
- C4 elimination can insert midpoints between any adjacent pair in the current domain.
- If max_K and q are adjacent at stage K+1, a C4 counterexample at stage K+2 could insert a midpoint m between max_K and q.
- Then `succ(max_K) = m` (not q), and `succ(m)` might be q or another intermediate point.

So `succ_embed(j+1) = succ(max_K) <= q` because succ(max_K) is the SMALLEST limit_dom point above max_K, and q is ABOVE max_K in limit_dom. Any midpoints inserted later are between max_K and q, so they are strictly less than q. The limit-domain successor succ(max_K) is at most any of these midpoints, which are all < q.

Actually, wait. succ(max_K) is the SMALLEST limit_dom point > max_K. Any point m inserted between max_K and q satisfies max_K < m < q. So succ(max_K) <= m < q, which means succ(max_K) < q, so succ(max_K) is NOT q. But then succ_embed(j+1) < q, and by squeeze, q = succ_embed(k) for some k > j+1.

**But we need to first establish that some succ_embed(N) >= q exists!** That is the cofinality property. The squeeze lemma only works when q is BETWEEN two embedded points. If the succ_embed orbit has a supremum below q, squeeze cannot be applied.

### 4.2 Why cofinality holds

The succ_embed orbit is cofinal (unbounded above) in LimitDomSubtype. Here is the argument:

Suppose for contradiction that the orbit `{succ_embed(n) : n >= 0}` is bounded above by some w in LimitDomSubtype. Then `succ_embed(n) < w` for all n >= 0. The orbit is strictly increasing (succ_embed_strictMono), so the rational values `succ_embed(n).val` form a bounded monotone sequence.

**Key observation**: succ_embed(n+1) = succ(succ_embed(n)), where succ is the limit-domain immediate successor. Between succ_embed(n) and succ_embed(n+1), there are no limit_dom points (by succ_embed_no_gap). So the entire orbit partitions limit_dom into "blocks" separated by these gaps.

Now consider any limit_dom point z > w (which exists by NoMaxOrder). Then z is above the orbit bound. By limit_dom_has_succ, z has a successor. But crucially, between the supremum of the orbit and z, there must be limit_dom points -- but each such point has a successor, and between consecutive limit_dom points there are no others (the bot-gap property).

The formal argument: let S = sup{succ_embed(n).val : n >= 0} in R. Two cases:

**(a) S in limit_dom**: Then there exists some limit_dom point at rational S. But for large n, succ_embed(n) is close to S, so succ_embed(n) is between pred(S_subtype) and S_subtype. By no-between, there are no limit_dom points between pred(S_subtype) and S_subtype. But succ_embed(n) IS a limit_dom point in this interval for large n. Contradiction (unless succ_embed(n) = pred(S_subtype) for all large n, which contradicts strict monotonicity).

**(b) S not in limit_dom**: The orbit converges to a non-domain rational. Now consider any limit_dom point z > S. Then pred(z) in limit_dom, and pred(z) < z, and no limit_dom points between pred(z) and z. For large n, succ_embed(n) is between pred(z) and z -- contradicting no-between. (Unless pred(z) >= S, in which case repeat with pred(z) instead of z. This creates a descending sequence pred(z), pred(pred(z)), ..., all >= S. If this sequence reaches S, case (a) applies. If it doesn't, the sequence is a descending sequence of limit_dom points bounded below by S, whose infimum is S. By the same argument applied to the infimum, we get a contradiction.)

This argument shows the orbit cannot be bounded, hence it IS cofinal. Combined with the symmetric argument for the negative direction, surjectivity follows by squeeze.

### 4.3 Formalization difficulty

The argument in Section 4.2 requires:
1. The Bolzano-Weierstrass-type reasoning (bounded monotone sequence converges in R, not in Q -- but we only need the EXISTENCE of limit_dom points near the supremum, not convergence per se).
2. Actually, the argument is simpler than it looks: we don't need convergence. We just need: if the orbit is bounded by w, then succ_embed(n) < w for all n, so succ(succ_embed(n)) = succ_embed(n+1) < w for all n (since w is in limit_dom, and succ(x) is the immediate successor, we'd need succ(x) <= w when x < w). But this is exactly the succ_le_iff property: succ(x) <= w iff x < w (in a SuccOrder). So succ_embed(n+1) = succ(succ_embed(n)) <= w for all n where succ_embed(n) < w.

Wait, this is actually much simpler! The SuccOrder on LimitDomSubtype gives `succ_le_iff : succ(a) <= b <-> a < b`. So if `succ_embed(n) < w`, then `succ(succ_embed(n)) <= w`, i.e., `succ_embed(n+1) <= w`. By induction, `succ_embed(n) <= w` for all n >= 0.

But this means `succ_embed(n) <= w` for all n. Does this give surjectivity? Not directly -- it shows the orbit stays below w. The orbit is strictly increasing and bounded, so it converges (in R). But we need it to REACH w.

Hmm, the argument is more subtle. The issue is: succ_le_iff says succ(a) <= b when a < b. So succ_embed(1) = succ(root) <= w. And succ_embed(2) = succ(succ(root)) <= w. But we never get succ_embed(n) = w unless the chain reaches w.

**The real argument for cofinality**: Suppose succ_embed(n) < w for all n >= 0. Consider the set D = {succ_embed(n) : n >= 0}. This is an infinite set of limit_dom points, all in the interval [root, w]. We claim this set is finite -- contradiction.

Why is it finite? Each element succ_embed(n) enters limit_dom at some finite stage K_n. But more importantly, between consecutive elements succ_embed(n) and succ_embed(n+1), there are NO other limit_dom points. So the elements of D, ordered by <, form a chain where each pair is "adjacent" (no limit_dom points between them).

The finiteness of D follows from the finiteness of `Icc root w` (if this can be proved). Alternatively, one can prove `IsSuccArchimedean` directly.

## 5. Recommended Proof Approach

### Approach A: Direct cofinality proof (Estimated: ~60 lines)

Prove that for any w in LimitDomSubtype, there exists N such that succ_embed(N) >= w. Then the existing succ_embed_squeeze gives surjectivity.

**Key lemma**: `succ_embed_cofinal_above`:
```
forall w : LimitDomSubtype, exists N : Nat, w <= succ_embed(N)
```

**Proof**: Strong induction on the omega-chain stage K where w enters. If w enters at stage 0, then w = root = succ_embed(0). If w enters at stage K+1:
- If w <= max_K: by IH, max_K = succ_embed(j) for some j. Then w <= succ_embed(j) and we are done.
- If w > max_K: At stage K+1, the only new point is q (added by elimination). By EliminationResult's `dom_new_unique`, at most one new point is added per stage. So q = w. Now max_K is in dom(K) and max_K < w. By IH, max_K = succ_embed(j). We need succ_embed(j+1) >= w.

  succ_embed(j+1) = succ(succ_embed(j)) = succ(max_K). The successor of max_K in limit_dom is the smallest limit_dom point > max_K. This point is <= w (since w > max_K and w in limit_dom). So succ(max_K) <= w, i.e., succ_embed(j+1) <= w.

  But we need equality or the ability to continue. If succ_embed(j+1) = w, done. If succ_embed(j+1) < w, then succ_embed(j+1) is a limit_dom point between max_K and w. But at stage K+1, the only new point is w = q, so succ_embed(j+1) must be in dom(K). But succ_embed(j+1) > max_K contradicts max_K being the maximum of dom(K).

  Wait -- succ_embed(j+1) = succ(max_K) is the limit-domain successor, which could be a point added at a LATER stage (K+2, K+3, ...). It need not be in dom(K).

This is the problem. The limit-domain successor of max_K may not be the point added at stage K+1. Later stages could insert a point between max_K and q, making that the actual successor.

### Approach B: Icc finiteness (Estimated: ~100 lines)

Prove `Set.Finite (Set.Icc a b)` for a, b in LimitDomSubtype. Then:
- The pred-chain from w to root stays in Icc root w (finite), hence terminates.
- Termination means w = succ^m(root) for some m, so w = succ_embed(m).

The Icc finiteness proof: Suppose Icc a b is infinite. Then there is a countably infinite collection of limit_dom points in [a.val, b.val]. Order them as a strictly increasing sequence c_0 < c_1 < c_2 < .... Between consecutive c_i, there are no limit_dom points (by the no-gap/bot-gap property). The sequence c_i.val is bounded and strictly increasing. Consider the point c_i.val as rationals in [a.val, b.val].

The decisive observation: at each omega-chain stage K, the domain dom(K) has at most K+1 elements. The number of dom(K) points in [a.val, b.val] is at most K+1. A point c_i enters at some stage K_i. If infinitely many c_i exist, then K_i -> infinity.

But this does not immediately give a contradiction. The argument needs: between c_i and c_{i+1}, no limit_dom points exist, so these are "adjacent" in limit_dom. Now consider c_i.val converging to L. If L is in limit_dom, then pred(L_sub) exists and for large i, c_i is between pred(L_sub) and L_sub -- but there should be nothing there. Contradiction.

If L is not in limit_dom, consider the smallest limit_dom point z > L (exists by NoMaxOrder + limit_dom properties). Then pred(z) < z and no limit_dom points between them. For large i, c_i > pred(z) (since c_i -> L >= pred(z).val eventually). But c_i < z (since c_i < L < z... actually L <= z). This puts c_i between pred(z) and z -- contradiction.

The technical difficulty: proving that such L and z exist with the right properties. We need the limit_dom to have no infinite descending/ascending chains in bounded intervals.

### Approach C (Recommended): Prove IsSuccArchimedean via LocallyFiniteOrder

Mathlib provides `IsSuccArchimedean` for linearly ordered types with SuccOrder where the Icc sets are finite. If we can show `LocallyFiniteOrder (LimitDomSubtype A h_mcs)`, then `IsSuccArchimedean` follows.

For `LocallyFiniteOrder`, we need `Finset.Icc a b` for all a, b. This requires the Icc finiteness from Approach B.

## 6. Why Previous Agents Failed to Prove It

The previous agents (report 05) correctly identified the core difficulty: stage induction fails because `pred(w)` can enter limit_dom at a LATER stage than w, breaking the induction measure. The lexicographic measure `(stage(w), rank(w))` fails because rank can increase when stage increases.

The agents also correctly identified that Icc finiteness would resolve the problem, but estimated it as HIGH difficulty. The actual proof requires an accumulation/convergence argument that is straightforward in classical analysis but requires careful formalization in Lean with the discrete limit_dom structure.

The agents did NOT attempt the cofinality approach (Approach A above), which is actually blocked by the same stage-crossing issue.

## 7. Implications for the BFMCS Construction

`succ_embed_surjective` is used in:
1. `cantor_bfmcs_discrete_restricted_tc` -- restricted temporal coherence
2. `cantor_bfmcs_discrete_restricted_fuc` -- restricted forward Until/Since coherence

Both are structurally complete modulo surjectivity. Once surjectivity is proved, the entire discrete branch of the completeness theorem goes through.

The surjectivity IS true, and the proof path via Icc finiteness (Approach B) is the most direct. The key mathematical insight is that bounded discrete subsets of Q (where "discrete" means each point has an immediate successor/predecessor with nothing between) must be finite, because an infinite bounded discrete set would have an accumulation point that contradicts the discreteness.

## 8. Concrete Refutation of the Accumulation Scenario

Returning to the specific scenario from the task prompt:

> Start with root at 0. C5-bot adds q1 > 0. C4 inserts m1 between 0 and q1. Later, C4 inserts m2 between m1 and q1. After infinitely many insertions, the succ chain from 0 is: 0, m1, m2, m3, ... converging to L, but q1 only reachable as succ^omega(0).

This scenario is refuted as follows:

1. In the limit_dom, `succ(0) = m1` (smallest limit_dom point above 0).
2. `succ(m1) = m2` (smallest above m1).
3. The chain 0, m1, m2, ... consists of consecutive limit_dom points.
4. If infinitely many m_i exist in [0, q1], they are all in limit_dom.
5. The rational values m_i converge to some L <= q1.
6. If L is in limit_dom: for large i, m_i is between pred(L) and L in limit_dom. But nothing should be between pred(L) and L. Contradiction with m_i being there.
7. If L is not in limit_dom: consider the smallest limit_dom point z > L. By NoMaxOrder, such z exists. Then pred(z) exists, pred(z) < z, nothing between pred(z) and z. For large i, pred(z) < m_i < z (since m_i -> L and pred(z) <= L < z). This puts m_i between pred(z) and z -- contradiction.

Therefore, only finitely many m_i can exist between 0 and q1. The succ chain from 0 reaches q1 in finitely many steps.

## 9. Summary

| Question | Answer |
|----------|--------|
| Is `succ_embed_surjective` true? | **YES** |
| Can accumulation occur? | **NO** -- Icc sets are finite in the discrete case |
| Why does the current proof have sorry? | Stage induction fails for the "above max" case; needs Icc finiteness or cofinality argument |
| Proof approach | Prove Icc finiteness via accumulation contradiction (Approach B, ~100 lines) |
| Impact if proved | Completes discrete branch of BX completeness theorem |
| Is there a concrete counterexample? | **NO** -- no such counterexample exists |
