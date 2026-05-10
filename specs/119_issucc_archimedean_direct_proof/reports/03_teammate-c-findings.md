# Teammate C Findings: Complete Proof Sketch for IsSuccArchimedean

- **Task**: 119 - Prove IsSuccArchimedean via Direct Connectivity Extraction
- **Role**: Critic (Teammate C, Round 3)
- **Session**: sess_1778449535_f13ea4
- **Date**: 2026-05-10

## 1. The Theorem

**Goal**: For `a <= b` in `LimitDomSubtype A h_mcs` (under discrete hypothesis `h_discrete`), prove `exists n, succ^[n] a = b`.

## 2. Complete Proof Sketch (Contradiction + Bolzano-Weierstrass)

### Step 0: Setup [ORDER]

Given `a <= b`, handle `a = b` (take `n = 0`). Otherwise `a < b`. Assume for contradiction that `succ^[n](a) != b` for all `n : Nat`.

**Status**: Trivial. No gap.

### Step 1: The succ-chain is strictly increasing and bounded [ORDER]

Define `s_n := succ^[n](a)`. Show:
- `s_n < s_{n+1}` for all n (from NoMaxOrder and SuccOrder)
- `s_n <= b` for all n (induction: base `a <= b`; step: `s_n < b` since `s_n != b`, then `succ(s_n) <= b` by succ_le_iff)

**Status**: Pure order theory. No gap. Available lemmas: `limitDomSubtype_succ_le_iff`, NoMaxOrder.

### Step 2: The pred-chain is strictly decreasing and bounded [ORDER]

Define `p_m := pred^[m](b)`. Show:
- `p_m > p_{m+1}` for all m (from NoMinOrder and PredOrder)
- `p_m >= a` for all m (induction: base `b >= a`; step: `p_m > a` since `p_m != a`, then `pred(p_m) >= a` by le_pred_iff)
- If `p_m = a` for some m: then `succ^[m](a) = succ^[m](pred^[m](b)) = b` (using `succ(pred(x)) = x` repeatedly). Done -- contradicts assumption.

So assume `p_m > a` for all m (i.e., `p_m != a` for all m).

**Status**: Pure order theory. No gap. Available lemmas: `limitDomSubtype_le_pred_iff`, `limitDomSubtype_succ_pred`, NoMinOrder.

### Step 3: The interleaving property [ORDER]

Show: `s_n < p_m` for all n, m (strictly).

Proof by strong induction on n + m:
- Base (n=0, m=0): `s_0 = a < b = p_0` (from Step 0).
- Step: Given `s_n < p_m`:
  - If `succ(s_n) = p_m`: then `succ^[n+1](a) = pred^[m](b)`, so `succ^[n+1+m](a) = b`. Contradicts assumption.
  - If `succ(s_n) < p_m`: then `succ(s_n) <= pred(p_m)` by le_pred_iff, giving `s_{n+1} <= p_{m+1}`.
    Since `s_{n+1} = p_{m+1}` would give `succ^[n+1+m+1](a) = b` (contradiction), we get `s_{n+1} < p_{m+1}`.

**Status**: Pure order theory. No gap. This step critically uses `succ_le_iff` and `le_pred_iff`.

### Step 4: Embed into R and find accumulation point [CONSTRUCTION]

The sequences `{(s_n.val : R)}` and `{(p_m.val : R)}` are:
- `s_n` is strictly increasing and bounded above (by `b.val`)
- `p_m` is strictly decreasing and bounded below (by `a.val`)

Both converge in R (monotone bounded sequences in R converge):
- `L_s := iSup (range (fun n => (s_n.val : R)))`
- `L_p := iInf (range (fun m => (p_m.val : R)))`

From Step 3: `s_n < p_m` for all n, m, so `L_s <= L_p`.

**Status**: Requires Mathlib real analysis.
- `isCompact_Icc` (for R)
- `Real.iSup_le` or `MonotoneBounded` convergence
- Rat.cast embedding and its properties

This is standard real analysis. **No gap**, but requires careful formalization of the Q-to-R embedding. The rational cast `Rat.cast : Q -> R` is an order-embedding (`Rat.cast_lt`, `Rat.cast_le`).

### Step 5: Case split on L_s [CONSTRUCTION + ORDER]

**Case A**: L_s = (q : R) for some q in limit_dom (i.e., L_s is the image of a limit_dom point).

Then q is in limit_dom. pred(q) exists. For large enough n, `s_n.val > pred(q).val` (since `s_n -> q` from below and `pred(q) < q`). Since no limit_dom in `(pred(q), q)`, and `s_n in limit_dom` with `pred(q) < s_n <= q`, we get `s_n = q`. But then `s_{n+1} = succ(q) > q`, and the succ-chain continues above q.

Restart with `a' = succ(q)` and same `b`. The argument repeats with a "higher starting point."

**Case B**: L_s is not the image of any limit_dom point (possibly irrational, or rational but not in limit_dom).

This is the case that needs structural analysis. See Step 6.

**Status for Case A**: [ORDER] once we establish q is reached. The "restart" argument is conceptually clean but needs formalization as a well-founded recursion. The difficulty is that Case A could happen infinitely often (reaching q_1, then q_2 = succ(q_1) leads to a new chain reaching q_3, etc.), which would require proving the sequence q_1, q_2, ... eventually reaches b. This is **equivalent to the original problem**. So Case A is not independently solvable without Case B.

### Step 6: Case B -- accumulation point not in limit_dom [GAP]

We have:
- `s_n -> L_s` from below, all `s_n in limit_dom`
- `L_s not in Rat.cast '' limit_dom`
- Between consecutive `s_n` and `s_{n+1} = succ(s_n)`, no limit_dom points
- So `limit_dom cap (a.val, L_s) = {s_n.val | n >= 1}`

Similarly (by symmetry with the pred-chain):
- `p_m -> L_p` from above, all `p_m in limit_dom`
- If `L_p not in Rat.cast '' limit_dom`:
  - `limit_dom cap (L_p, b.val) = {p_m.val | m >= 0}`

The question: does `L_s = L_p`? And does the omega chain construction prevent this situation?

**Analysis of why Case B should be impossible (but proof is incomplete)**:

Consider the gap structure near L_s. The succ-chain gaps `(s_n, s_{n+1})` shrink to zero width as `n -> infinity`. Each gap is "sealed" (no limit_dom points inside). Each `s_n` is in some `dom_{k_n}` (born at stage `k_n`).

In the omega chain, at stage `k_n`, the point `s_n` is inserted. At this stage, `s_n` is placed between two existing `dom_{k_n - 1}` elements `p` and `q` (the gap it splits). The g-value `g_{k_n}(p, q)` was extended to cover the new adjacencies.

For the U(T, bot) counterexample at `s_n`: the witness is `s_{n+1}` in the limit. At finite stages before `s_{n+1}` is born, the counterexample might be resolved by a farther witness (e.g., the dom-successor of `s_n` in `dom_N` with bot in g_N(s_n, dom-succ)). The g-value containing bot seals the gap (g can be Set.univ at finite stages).

The critical question for Case B: can the construction produce infinitely many sealed gaps `(s_n, s_{n+1})` all converging to a single point L?

**Why it MIGHT be impossible**: Each `s_{n+1}` enters the domain by splitting some existing gap in `dom_{k_{n+1} - 1}`. This split is triggered by a specific counterexample `(x, y, xi, eta, kind)`. For `s_{n+1}` to be inserted BETWEEN `s_n` and some point above `s_n`:
- If `s_n` and `p_0` (or some far-away dom point) are adjacent in `dom_{k_{n+1} - 1}`, the midpoint `(s_n + p_0) / 2` is inserted. But this midpoint might not equal `s_{n+1}`.
- The actual insertion point depends on which counterexample is processed and which gap the walk reaches.

The gap `(s_n, ?)` in `dom_{k_{n+1} - 1}` gets split, producing `s_{n+1}`. Then later `s_{n+2}` splits `(s_{n+1}, ?)`, etc. Each split produces a point closer to L. The sequence of splits is driven by different counterexamples.

**Why it MIGHT be possible**: There are countably many counterexample types, each can insert one point. Infinitely many insertions into the interval `[a, b]` produce the infinite sequence `{s_n}`. The construction does not explicitly bound the number of insertions into any bounded interval.

**This is the genuine, irreducible gap in the proof.**

### Step 7: What would close the gap [GAP]

To close Case B, we need ONE of the following:

**(7a) Prove limit_dom cap [a, b] is finite** (the "finiteness lemma").
- If finite, Case B cannot arise (an increasing sequence in a finite set is eventually constant).
- But proving finiteness seems to require IsSuccArchimedean or equivalent. Circular.

**(7b) Prove that accumulation points of limit_dom are in limit_dom** (limit_dom is "sequentially closed" in R).
- This would eliminate Case B directly.
- But limit_dom is a subset of Q, and Q is not closed in R. An increasing sequence of rationals can converge to an irrational, which is never in limit_dom.
- So this approach would need to show the specific construction prevents irrational limits. This is a deep structural claim about the Burgess construction.

**(7c) Prove that the succ-chain stabilizes** (reaches b in finitely many steps) using a well-founded measure that decreases.
- All natural measures (dom_N count, birth stage, rational distance, universal-stage-minimum) have identified failure modes in Case 2 (when pred(b) or succ(a) is born at a later stage than a or b).
- A measure that works would need to incorporate the GLOBAL structure of the omega chain, not just local order properties.

**(7d) Prove Case B leads to a contradiction via the C4 counterexample elimination**.
- C4 ensures that if `U(eta, xi).neg in f(x)` and `eta in f(y)` with `x < y`, then there exists `z in (x, y)` with `xi.neg in f(z)`.
- C4 produces witnesses BETWEEN two points -- it densifies the domain.
- In Case B, the gaps `(s_n, s_{n+1})` shrink to zero. For C4 to insert between them would violate the succ property. But C4 might not need to insert between consecutive succ-chain elements.
- This angle has not been fully explored and might yield results.

**(7e) Prove IsSuccArchimedean via a completely different method** (not finiteness, not contradiction).
- Direct construction: given a and b, exhibit the path from a to b.
- Use the omega chain stages to build the path: at stage N, a and b are in dom_N. The finite path through dom_N elements from a to b, refined through subsequent stages, converges to the succ-path in the limit.
- This is promising but requires showing the refinement stabilizes.

## 3. Assessment of Each Gap Step

### The Genuine Gaps

| Step | Classification | Gap Description | Difficulty |
|------|---------------|-----------------|------------|
| Step 6 (Case B) | [GAP] | Accumulation point not in limit_dom | HARD |
| Step 5 (Case A restart) | [GAP] | Requires Case B or independent termination | MEDIUM |

### What is NOT a gap

| Step | Classification | Why It Works |
|------|---------------|--------------|
| Steps 0-3 | [ORDER] | Pure order theory, all lemmas exist in codebase |
| Step 4 | [CONSTRUCTION] | Standard Mathlib real analysis |

## 4. The Finiteness Approach (via Set.Icc)

The cleanest proof path is:

```
(Set.Icc a b).Finite  -->  LocallyFiniteOrder  -->  IsSuccArchimedean
```

where the first arrow uses `LocallyFiniteOrder.ofFiniteIcc` and the second uses `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder`.

To prove `(Set.Icc a b).Finite` for `a b : LimitDomSubtype`:

### Approach via Bolzano-Weierstrass (Proof by Contradiction)

1. Assume `(Set.Icc a b).Infinite`.
2. Embed into R: `S := Rat.cast '' (Subtype.val '' Set.Icc a b)` is infinite in R.
3. `S` is bounded: `S` is contained in `Set.Icc (a.val : R) (b.val : R)`, which is compact.
4. By `Set.Infinite.exists_accPt_of_subset_isCompact`: exists `L in Set.Icc (a.val : R) (b.val : R)` with `AccPt L (Filter.principal S)`.
5. **Case 1** (`L = (q : R)` for some `q in limit_dom`):
   - `q` has immediate successor `succ(q)` and predecessor `pred(q)` in limit_dom.
   - The open interval `(pred(q).val, succ(q).val)` in R is a neighborhood of `L = q`.
   - `S cap (pred(q).val, succ(q).val) = {q}` (no other limit_dom in this interval).
   - So `L` is NOT an accumulation point. Contradiction.
6. **Case 2** (`L` is not the image of any limit_dom point): **[GAP]**
   - `L` could be irrational, or rational but not in limit_dom.
   - Points of `S` accumulate toward `L` but `L` itself is not in limit_dom.
   - **This case cannot be dismissed by order theory alone.**

### Why Case 2 is the essential difficulty

The set `{1/n | n >= 1}` in R is a counterexample to "bounded + discrete implies finite": it is bounded in `[0, 1]`, each point is isolated (discrete subspace topology), but the set is infinite with accumulation point 0. The accumulation point 0 is not in the set.

For `limit_dom`, the situation is analogous: limit_dom is discrete (each point isolated by succ/pred gaps) and bounded intervals might be infinite. The only way to rule this out is through STRUCTURAL properties of the omega chain construction.

### What structural property is needed

We need: **for any bounded interval `[a, b]` in Q, `limit_dom cap [a, b]` is finite.**

Equivalently: **limit_dom has no accumulation points in R** (every convergent sequence of limit_dom points has its limit in limit_dom).

Equivalently: **limit_dom, viewed as a subset of R via Rat.cast, is closed and discrete**, which by Heine-Borel implies bounded subsets are finite.

But limit_dom is a SUBSET of Q, and Q is NOT closed in R. So "limit_dom is closed" means: if a sequence of limit_dom rationals converges in R, the limit is also a limit_dom rational. This is a specific structural property of the Burgess construction.

## 5. The Structural Question: Is limit_dom "R-closed"?

### Argument that it might be R-closed

If a sequence `q_n in limit_dom` converges to `L in R` with `L not in limit_dom`:
- Each `q_n` is born at some stage `k_n`.
- The `q_n` are getting arbitrarily close to `L`.
- For large `N`, `dom_N` contains many `q_n` that are close to `L`.
- Between consecutive `q_n` (in the limit_dom ordering), the succ/pred gaps seal the intervals.
- The C5 walk for U(T, bot) at `q_n` inserts midpoints in gaps containing `q_n`.

The question is whether the walk ever inserts a point converging to L from the "other side" (creating a pred-chain approaching L from above, which combined with the succ-chain from below would force a point at or very near L).

### Argument that it might NOT be R-closed

The construction works with RATIONAL midpoints. If `L` is irrational, no rational midpoint can equal `L`. The midpoints are always of the form `(p + q) / 2` for `p, q in Q`, which is always rational. So `L` is never directly inserted.

However, a sequence of midpoints could converge to `L`. If the construction repeatedly inserts points closer and closer to `L` from both sides, the "gap" around `L` shrinks to zero. But `L` itself is never inserted. This is EXACTLY the `{1/n}` counterexample scenario.

### The key difference from `{1/n}`

In `{1/n}`, each point is added by an external prescription. In the omega chain, each point is added by processing a SPECIFIC counterexample. The counterexamples are enumerated surjectively. So every possible counterexample type is processed infinitely often.

For a given `q_n in limit_dom` and formula pair `(xi, eta)` with `U(eta, xi) in f(q_n)`, the counterexample `(q_n, 0, xi, eta, c5_forward)` is processed at some stage, producing a witness. If the witness happens to be a new point inserted near `L`, it adds to the convergent sequence.

The question: can infinitely many distinct counterexample types `(q_n, 0, xi_i, eta_i, c5_forward)` each insert a point converging to `L`?

Each MCS `f(q_n)` contains countably many formulas. For each Until formula `U(eta, xi)` in `f(q_n)`, processing the counterexample either finds an existing witness or inserts a new one. If the new witness is closer to `L` than `q_n`, it contributes to the convergent sequence.

Since each `f(q_n)` is an MCS (hence contains infinitely many formulas), there are infinitely many potential insertions. Each inserts at most one point. This could produce infinitely many points converging to `L`.

**Conclusion: The Burgess construction does NOT obviously prevent accumulation points of limit_dom from being outside limit_dom. The structural closure property cannot be easily established.**

## 6. Recommended Proof Strategy

Given the analysis, the following is the most promising path forward:

### Primary: Direct Omega-Chain Induction (Approach 7e)

Instead of proving finiteness or ruling out Case B, construct the succ-path directly using the omega chain structure.

**Theorem**: For all `N : Nat` and `a b : Rat` with `a in dom_N` and `b in dom_N` and `a <= b`, there exist `n : Nat` and subtype elements `a_sub, b_sub : LimitDomSubtype` with `a_sub.val = a` and `b_sub.val = b` such that `succ^[n](a_sub) = b_sub`.

**Proof attempt by strong induction on `|dom_N.filter(fun q => a <= q && q <= b)|`**:

This is the original dom_N count induction. The blocker was Case 2 (pred(b) not in dom_N). But here's the key insight I missed:

**We do not need to descend through pred(b). We can descend through the dom_N-predecessor of b instead.**

Let `c` be the largest element of `dom_N` strictly less than `b` (exists since `a < b` and `a in dom_N`). Then:
- `c in dom_N`, `c < b`, `a <= c` (since `c >= a` as the largest dom_N element below `b`, and `a in dom_N` with `a < b`).
- `|dom_N.filter([a, c])| = |dom_N.filter([a, b])| - 1` (we removed `b`, and `c` is the next element down in dom_N, so no dom_N elements in `(c, b)`).
- By IH: `exists n, succ^[n](a_sub) = c_sub`.
- Now need: `exists m, succ^[m](c_sub) = b_sub`.

The sub-problem `(c_sub, b_sub)` has `c` and `b` adjacent in `dom_N` (no dom_N elements between them). This is the "gap problem": given consecutive dom_N elements, prove succ-connectivity in limit_dom.

**Gap Lemma**: For consecutive `p, q` in `dom_N` (adjacent in dom_N) with `p, q in limit_dom`, `exists n, succ^[n](p_sub) = q_sub`.

This is a CLEANER formulation of the remaining gap. It isolates the difficulty to a single gap between consecutive dom_N elements.

### The Gap Lemma: Proof Sketch

Given: `p, q in dom_N`, adjacent in `dom_N`, `p < q`.

**By strong induction on `(N, |dom_{N+1}.filter([p, q])|)` lexicographically**:

At stage N+1, either:
- No point is inserted in `(p, q)`: then `dom_{N+1} cap (p, q) = empty`. The gap is still empty at stage N+1. We need to show that EVENTUALLY a point is inserted, or p and q are adjacent in limit_dom.
- A point `z` is inserted in `(p, q)` at stage N+1: then `p < z < q`, `z in dom_{N+1}`. Apply IH to `(p, z)` at stage N+1 and `(z, q)` at stage N+1.

The difficulty: if no point is ever inserted in `(p, q)`, then `p` and `q` are adjacent in limit_dom, so `succ(p_sub) = q_sub` and we're done (n = 1). If a point is inserted at stage M > N, we apply IH at stage M.

**But the IH is on N, and M > N. The first component INCREASES!**

So we need a different induction. What about induction on `|limit_dom cap [p, q]|`? But that's what we're trying to prove is finite.

**ALTERNATIVE**: Induction on `(q - p)` as a rational? Not well-founded.

**ALTERNATIVE**: Consider that between consecutive dom_N elements `p, q`, the number of limit_dom points is either 0 (adjacent in limit_dom) or finite. How to prove this?

If there's at least one limit_dom point `z` in `(p, q)`, then `z` enters at some stage `M > N`. At stage M, `z in dom_M`. In `dom_M`, the gap `(p, q)` is split into `(p, z)` and `(z, q)` (possibly with other `dom_M` elements too). Each sub-gap has a SMALLER interval length: `z - p < q - p` and `q - z < q - p`.

But `q - p` is a rational, and Q has no well-founded ordering under `<` on positive rationals. We cannot induct on it.

**HOWEVER**: The rationals appearing as `q - p` are all of the form `r / (2^k * D)` where `D` is some fixed denominator from the original dom_N elements. Actually, not exactly -- the midpoints `(p + q) / 2` have specific denominators, and denominators grow.

**This approach does not easily yield a well-founded measure.**

### The gap: status

The Gap Lemma (for consecutive dom_N elements, prove succ-connectivity) has status **[GAP]**. It is equivalent to the original problem restricted to a single gap. No currently identified proof technique closes it without circularity.

## 7. Summary of Gaps

| # | Gap | What Would Close It | Estimated Difficulty |
|---|-----|---------------------|---------------------|
| 1 | Case B of Bolzano-Weierstrass (accumulation point not in limit_dom) | Prove limit_dom is "R-closed" OR prove finiteness of bounded intervals by other means | HARD |
| 2 | Gap Lemma (consecutive dom_N elements are succ-connected) | A well-founded measure on gaps that decreases when sub-gaps are created | HARD |
| 3 | Case A termination (succ-chain catching limit_dom points) | Equivalent to full theorem; not independently solvable | REDUCES TO 1 or 2 |

**These three gaps are essentially ONE gap viewed from different angles: the inability to prove that limit_dom has no accumulation points outside itself, equivalently that bounded intervals of limit_dom are finite, equivalently that succ-iteration reaches any target.**

## 8. What IS Provable (Gap-Free Skeleton)

The following proof skeleton is entirely gap-free:

```
1. [ORDER] Setup: a < b, assume contradiction
2. [ORDER] succ-chain strictly increasing, bounded by b
3. [ORDER] pred-chain strictly decreasing, bounded by a
4. [ORDER] Interleaving: s_n < p_m for all n, m (else done)
5. [CONSTRUCTION] Embed in R, both chains converge
6. [ORDER] If chains meet (s_n = p_m): done
7. [ORDER + CONSTRUCTION] Case A (limit in limit_dom): 
   pred/succ gap gives isolation, sequence stabilizes at limit point,
   restart from succ(limit_point)
8. [GAP] Case B (limit not in limit_dom): UNRESOLVED
```

The gap-free portion (Steps 1-7 excluding the Case A termination argument) is approximately 100-150 lines of Lean. The gap (Step 8) is the entire difficulty.

## 9. Concrete Recommendation

**The theorem `limitDomSubtype_isSuccArchimedean` cannot be proven by pure order theory or standard real analysis alone.** It requires a deep structural property of the Burgess omega chain construction (either R-closedness of limit_dom or finiteness of bounded intervals).

### Recommended next steps (in priority order):

1. **Investigate whether limit_dom is R-closed using the omega chain construction directly.** This means: if rationals `q_1, q_2, ...` in limit_dom converge to `L in R`, and `L = r` for some `r in Q`, prove `r in limit_dom`. (The case where L is irrational needs separate handling -- or show it cannot happen for limit_dom.) This is a property of the specific Burgess construction, not general order theory.

2. **Investigate whether there is a well-founded measure on "gaps" in dom_N.** The gap between consecutive dom_N elements `(p, q)` gets split at various stages. Is there a measure on the gap that strictly decreases with each split, and reaches 0 when p and q become adjacent in limit_dom? The measure cannot be the rational width (not well-founded). But perhaps a measure based on the counterexample types that can affect the gap?

3. **Consider axiomatizing the finiteness property.** If the structural proof is too complex, introduce an axiom `limit_dom_icc_finite : forall a b, (limit_dom cap Set.Icc a b).Finite` and prove everything else. This converts the sorry from a theorem about succ-iteration to a theorem about set finiteness, which is mathematically more natural and self-documenting. The axiom would be the ONLY sorry in the completeness proof.

4. **Search for an entirely different proof of discrete completeness** that avoids IsSuccArchimedean. Perhaps the Z-isomorphism can be constructed directly from the omega chain without going through succ/pred archimedeanity.
