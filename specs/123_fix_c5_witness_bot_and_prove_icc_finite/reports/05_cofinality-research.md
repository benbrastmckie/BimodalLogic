# Succ-Orbit Cofinality Research Report

Task: 123 | Date: 2026-05-11

## 1. Problem Statement

The last sorry in `ChronicleToCountermodel.lean` is in `succ_embed_surjective` (line 1973), which claims every `LimitDomSubtype` element equals `succ_embed(n)` for some integer `n`. The proof uses stage induction on the omega chain. The base case (stage 0) and the "between old points" case (using `succ_embed_squeeze_strict`) are proved. Two sorry cases remain:

- **Above max**: `q > max_K` (new point above all stage-K points)
- **Below min**: `q < min_K` (symmetric to above)

## 2. Architecture Summary

- `omega_chain(n)` builds stages; `limit_dom = Union_n dom(n)`.
- `limitDomSubtype_succ(x)`: immediate successor in limit_dom (deterministic via `Classical.choose` of `limit_dom_has_succ`).
- `succ_embed(n)`: for n >= 0, `succ^n(root)`; for n < 0, `pred^|n|(root)`.
- `succ_embed_no_gap`: no limit_dom points between `succ_embed(n)` and `succ_embed(n+1)`.
- `succ_embed_squeeze`: any point between `succ_embed(a)` and `succ_embed(b)` equals some `succ_embed(k)`.
- `limitDomSubtype_succ_pred`: `succ(pred(b)) = b` (proved).
- `limitDomSubtype_pred_succ`: `pred(succ(a)) = a` (NOT proved, needed).

## 3. Why Stage Induction Fails for the "Above" Case

When `q > max_K` (the maximum of `dom(K)`), `q` was added at stage K+1 by counterexample elimination. By IH, `max_K = succ_embed(j)`. The natural attempt is to show `q = succ_embed(j+1)`, which requires `limitDomSubtype_succ(max_K) = q`.

This fails because `limitDomSubtype_succ(max_K)` is the immediate successor in the FULL limit_dom, not at stage K+1. Later stages (K+2, K+3, ...) can insert points between `max_K` and `q` (via C4 midpoint insertions or C5 splitting). So `succ_embed(j+1)` could be strictly less than `q`.

Similarly, `pred(q)` in the full limit_dom might not exist at stage K or earlier, so the IH cannot be applied to it.

## 4. Can the Succ-Orbit Accumulate?

The comment at line 1052-1055 states that "omega-chains converge to accumulation points." This is a critical concern. If the orbit `{succ^n(root) : n in Nat}` converges (as rationals) to some limit L, and L is in limit_dom, then `pred(L)` exists with no limit_dom points in `(pred(L), L)`. For large n, `succ^n(root)` would be in `(pred(L), L)` -- contradicting the no-between property. So accumulation at a limit_dom point is IMPOSSIBLE.

However, accumulation at a point NOT in limit_dom remains theoretically possible. The orbit values could converge to an irrational or a rational not in limit_dom. In this case, there would be a "gap" in limit_dom separating the orbit from any point above L.

## 5. Proposed Proof Strategy: Pred-Chain with Bounded Rational Interval

### Strategy Overview

For `w > root`, prove `w = succ_embed(n)` by showing the pred-chain from `w` reaches `root` in finitely many steps. Then `w = succ^m(root) = succ_embed(m)` where `m` is the chain length.

### Key Lemma: Pred-Chain Bounded Below by Root

For `w >= root` in LimitDomSubtype: `pred(w) >= root`.

**Proof**: If `pred(w) < root`, then `root` is a limit_dom point with `pred(w) < root < w`. But `pred(w)` is the immediate predecessor of `w` (no limit_dom points between them). Contradiction.

### Key Lemma: Pred-Chain Reaches Root

The pred-chain `w, pred(w), pred^2(w), ...` consists of distinct limit_dom points in the rational interval `[root.val, w.val]`. We need this chain to be FINITE.

**Approach**: Define a well-founded measure using the omega chain structure. For `x in limit_dom`, define:
```
stage(x) = min { K : x.val in dom(K) }
rank(x) = |{ y in dom(stage(x)) : root.val <= y <= x.val }|
mu(x) = (stage(x), rank(x))    -- ordered lexicographically
```

**Claim**: `mu(pred(w)) < mu(w)` in the lexicographic order on `Nat x Nat`.

This is the key step. Two sub-cases:

(a) If `pred(w).val in dom(stage(w))`: then `stage(pred(w)) <= stage(w)` and `rank(pred(w)) < rank(w)` (since `pred(w) < w` and both are in `dom(stage(w))`). So `mu` decreases.

(b) If `pred(w).val not in dom(stage(w))`: then `pred(w)` was added at a LATER stage. Specifically, `stage(pred(w)) > stage(w)`. This seems like `mu` increases, not decreases. This case is problematic.

### The Problematic Sub-Case

Sub-case (b) is the real obstacle. A point `p = pred(w)` can be added at a stage AFTER `w`'s stage. For example: `w` is at stage 5, and between `w`'s predecessor-at-stage-5 and `w`, a new point is inserted at stage 10. This new point becomes `pred(w)` in the full limit_dom.

This means the simple lexicographic measure doesn't work. A more sophisticated measure is needed.

## 6. Alternative Approach: Rational Distance Measure

Define for `x in LimitDomSubtype` with `x > root`:
```
d(x) = x.val - root.val    -- rational distance to root
```

The pred-chain `w, pred(w), pred^2(w), ...` has strictly decreasing rational values, all >= root.val. So d decreases at each step: `d(pred(w)) < d(w)`.

But d takes values in the POSITIVE RATIONALS, which is NOT well-ordered. So this doesn't directly give termination.

However, we can combine this with the omega chain finiteness:

### Approach: Counting Points in a Rational Interval

**Claim**: `{ x in limit_dom : root.val <= x <= w.val }` is finite.

If this is true, the pred-chain (which stays in this set) must be finite, and hence reaches root.

**Proof attempt**: At stage K = stage(w), `dom(K) cap [root.val, w.val]` has N_K elements. At stage K+j, at most one new point is added (total, not just in the interval). So after M stages total, the set has at most N_K + M points? No -- M grows without bound.

The issue: an unbounded number of stages can each contribute one point to [root.val, w.val]. So this set could be countably infinite.

### Resolution: Use the Discrete No-Between Property

Even if the set is infinite, the discrete structure prevents accumulation:

Between any two consecutive limit_dom points, there's nothing. So the set `limit_dom cap [root.val, w.val]` is either finite or has an accumulation point. But accumulation in limit_dom is impossible (proved in Section 4 for limit_dom points).

The remaining question: can limit_dom points in `[root.val, w.val]` accumulate at a non-limit_dom rational? If yes, the set is infinite; if no, it's finite.

## 7. The Core Open Question

**Can infinitely many limit_dom points exist in a bounded rational interval `[a, b]` in the discrete case?**

If NO (Icc is always finite): `succ_embed_surjective` follows immediately.
If YES: the proof requires a fundamentally different approach.

Evidence for NO:
- The discrete guard (bot) prevents ANY limit_dom points between consecutive limit_dom points.
- This should make limit_dom "locally finite."
- The omega chain adds at most one point per stage; points in [a,b] added at stages beyond some K must eventually "run out of room."

Evidence for YES (the concern):
- The comment at line 1052-1055 explicitly states that "omega-chains converge to accumulation points, making Icc intervals infinite."
- This was written by the code author, who understands the construction.

**Resolution**: The comment at line 1052-1055 is likely WRONG or describes a situation that cannot occur in the discrete case with the U(T,bot) guard. The key argument: if `succ^n(root)` for n in Nat accumulated at L in limit_dom, then pred(L) would have orbit points between it and L -- contradiction. The comment may have been written before the full discrete structure was understood.

## 8. Recommended Proof Strategy

### Step 1: Prove `limitDomSubtype_pred_succ` (~15 lines)

`pred(succ(a)) = a`. Mirror of the existing `limitDomSubtype_succ_pred`.

### Step 2: Prove `Icc_finite` for LimitDomSubtype (~60-100 lines)

For any `a b : LimitDomSubtype` with `a <= b`, prove `Set.Finite (Set.Icc a b)` (as a set of LimitDomSubtype elements).

**Proof sketch**: Suppose for contradiction it's infinite. Then there exists an infinite strictly increasing sequence `a = x_0 < x_1 < x_2 < ...` in limit_dom with all `x_i <= b`. Between consecutive `x_i` and `x_{i+1}`, there are no limit_dom points (each pair is consecutive since succ(x_i) <= x_{i+1} and pred(x_{i+1}) >= x_i). The rational values x_i.val converge to some L <= b.val.

If L = b.val: for large i, x_i is in (pred(b), b) -- no limit_dom points there. Contradiction.
If L < b.val: consider whether L is in limit_dom.
- L in limit_dom: for large i, x_i is in (pred(L_subtype), L_subtype) where L_subtype = (L, ...). But pred(L_subtype) < L and no limit_dom points between them. For large i, x_i is in this interval. Contradiction.
- L not in limit_dom: The sup of the sequence is not in limit_dom. But succ(x_i) for any i is x_{i+1} (by the construction of the sequence as consecutive limit_dom points). So the sequence IS the succ-orbit restricted to [a, b]. It accumulates at L not in limit_dom. 

For the "L not in limit_dom" case: consider any limit_dom point z > L. Then pred(z) < z. If pred(z) < L, then z and pred(z) bracket L, and the orbit points x_i with x_i > pred(z) are between pred(z) and z -- but there should be none. If pred(z) >= L, then pred(z) is a limit_dom point >= L > x_i for all i. Then succ(x_i) = x_{i+1} <= pred(z) for all i (since x_i < pred(z) implies succ(x_i) <= pred(z)). This keeps the orbit below pred(z), then below pred(pred(z)), etc. This creates a descending chain of bounds, which by the same accumulation argument must terminate -- giving a bound equal to some x_j, contradicting that x_j < z for all such bounds.

This argument is delicate but formalizable. Estimated difficulty: MEDIUM-HIGH.

### Step 3: Derive surjectivity from Icc_finite (~30-40 lines)

Given `w >= root`, the set `Icc root w` is finite. The succ-orbit from root either reaches w (done) or stays below w forever. If the orbit stays below w, all orbit elements are in `Icc root w` (finite set). The orbit is strictly increasing, so it reaches some maximum element `m` in the set. Then `succ(m)` is NOT in `Icc root w` (since m is the max orbit element in the interval), so `succ(m) > w`. But by succ_le_iff, `succ(m) <= w` iff `m < w`. If `m < w`, then `succ(m) <= w`, so `succ(m)` IS in `Icc root w` -- contradiction with m being the max.

Alternatively: by Icc_finite + discrete order, can use IsSuccArchimedean directly once we have LocallyFiniteOrder.

### Step 4: Handle the negative case (~10 lines)

For `w < root`, the symmetric argument via pred-orbit works.

## 9. Estimated Effort

| Component | Lines | Difficulty |
|-----------|-------|------------|
| `limitDomSubtype_pred_succ` | ~15 | Low |
| `Icc_finite` lemma | ~80 | High |
| Surjectivity from Icc_finite | ~40 | Medium |
| Negative case | ~15 | Low |
| **Total** | **~150** | **High** |

## 10. Alternative: Skip Icc_finite, Prove Surjectivity Directly

Instead of proving Icc_finite first, prove surjectivity via well-founded induction on `(stage(w), card(dom(stage(w)) cap [root, w]))` with careful case analysis for when pred(w) is at a later stage. This avoids the Icc_finite detour but requires handling the stage-crossing case explicitly. Estimated similar effort (~120 lines) but messier proof structure.

## 11. Blocked/Non-Viable Approaches

- **Stage induction alone**: fails because pred(w) can be at a later stage.
- **Rational convergence**: not well-ordered, can't prove termination directly.
- **WellFoundedGT**: LimitDomSubtype has no min (isomorphic to Z), so GT is not well-founded.
- **Bypassing surjectivity**: `restricted_tc` and `restricted_fuc` both directly invoke `succ_embed_surjective`.
