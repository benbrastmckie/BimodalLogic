# SC-C: Mathematical Proof Strategies for succ_cofinal

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Novel proof strategies for succ_cofinal (ChronicleToCountermodel.lean:1885)

---

## 0. Statement and Current State

```lean
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    exists n, b <= (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a
```

**Claim**: In the limit domain (discrete case), for any `a < b`, iterating succ from `a` eventually reaches or passes `b`.

**Current proof state**: Steps 1--8 complete (lines 1557--1696). The sorry is at line 1885, in Step 9 (gap elimination in the `L <= pred(b).val` case). The established infrastructure gives:
- Orbit `{succ^n(a)}` converges to `L` from below (in R)
- Pred-chain `{pred^k(pb)}` has all values `>= L`, strictly decreasing
- All orbit points are strictly below all pred-chain points
- Any limit_dom point with `a <= c` and `c.val < L` is an orbit point (`orbit_below_L`)
- `backward_G`, `backward_F`, `backward_P` truth lemmas (proved without circularity)
- Z1 is in every MCS (`z1_in_mcs`)

**The gap scenario**: orbit converges to L from below, pred-chain approaches L from above, no domain point at value L. Three formula-based approaches failed because the constant-MCS case (all domain points have identical formula assignments) is consistent with all temporal axioms.

---

## 1. Strategy 1: Well-Founded Measure (stage(x))

### Idea

Define `stage(x) = min { n : Nat | x in omega_chain_val(n).dom }` for each `x in limit_dom`. Since `limit_dom = Union_n omega_chain_val(n).dom`, this is well-defined. Then attempt:

> If `a < b` and `succ^n(a) < b` for all n, then there exists `c` with `stage(c) > stage(a)` between `a` and `b`, and the construction properties force a contradiction.

### Analysis

**Strengths**:
- `stage(x)` is well-defined via `Nat.find` (using `x.property : exists n, x.val in omega_chain_val(n).dom`)
- Basic properties provable: `stage(0) = 0` (singleton_dom), `x in omega_chain_val(stage(x)).dom`
- The omega chain is monotone: `stage(x) <= n` implies `x in omega_chain_val(n).dom`

**Critical weakness**: The claim "if C5 inserts new points, stage increases" is imprecise and insufficient. The construction adds at most one point per stage, but:

1. The point added at stage `n+1` resolves counterexample `counterexample_enum(Nat.unpair(n).2)`. This counterexample may have nothing to do with the gap region.
2. The vast majority of stages do NOT add a point between `a` and `b`. Only those stages resolving counterexamples at points in `[a, b]` are relevant.
3. Even when a point IS added in `[a, b]`, showing it extends the orbit (rather than creating a new gap component) requires the very argument we're trying to prove.

**Key gap in the strategy**: "If C5 doesn't insert new points between orbit and b, then the orbit must reach b" -- this is literally `succ_cofinal` restated.

### Verdict: UNPROMISING

The well-founded measure `stage(x)` captures when a point entered the construction but does not help prove that the orbit must reach `b`. The fundamental difficulty remains: showing the construction cannot produce a second Z-component above the orbit.

---

## 2. Strategy 2: Ordinal/Stage Induction (Archimedean at each stage)

### Idea

Induct on the stage number `N`:

> **Claim**: For all `N`, for all `a, b in omega_chain_val(N).dom` with `a <= b`, there exists `k` such that `succ^k(a) = b`.

### Analysis

**This is exactly `succ_reaches_dom_N`** (lines 1147--1448), which already has an extensive partial proof with two sorry'd boundary cases:

1. **Line 1285**: `a in dom(N)`, `b` is the new point above `max(dom(N))` at stage `N+1`. After reaching `max(dom(N))` via IH, we need `succ(max_N_sub) = b`. We know `succ(max_N_sub) <= b` (from `succ_le_iff`), but showing equality requires knowing that `succ(max_N_sub)` is in `dom(N+1)`. The succ-successor in the LIMIT domain may enter at a later stage, not at stage `N+1`.

2. **Line 1441**: `a` is the new point below `min(dom(N))`, `b in dom(N)`. Mirror difficulty.

**Why the claim does NOT survive the limit**: Even if the claim held at each finite stage (which it does not, due to the boundary cases), the limit argument is subtle. At stage `N`, the succ-function on `dom(N)` is the succ from the LIMIT domain restricted to `dom(N)`. Between stage-`N` consecutive points, new points may be inserted at later stages. The succ-path at stage `N` may be disrupted by insertions.

**Specific failure point**: At stage `N`, `a` and `succ_limit(a)` are in `dom(N)` and adjacent in `dom(N)`. At stage `N+1`, a point `z` may be inserted between them (if `z` resolves a C4 counterexample at `(a, succ_limit(a))`). Then in the limit, `succ_limit(a) = z`, not the old successor. The IH path at stage `N` no longer matches the limit-domain succ structure.

### Attempt to salvage: prove "succ at stage N equals succ in the limit"

This fails because succ in the limit is the IMMEDIATE next limit_dom point, which may have been inserted after stage `N`. Only for the DISCRETE case with `U(T, bot)` is the successor immediate (no domain point between consecutive succ-iterates). But this immediate-ness holds in the LIMIT, not at finite stages.

### Verdict: UNPROMISING (ALREADY ATTEMPTED)

This is the dead approach documented in the Boneyard (README.md). The boundary cases at lines 1285 and 1441 are genuine gaps, not fixable with the current infrastructure. The core issue: `succ(max_N)` in the limit domain may enter at an arbitrarily later stage than `N+1`, so the IH across stages does not compose.

---

## 3. Strategy 3: Constant-MCS Counterexample Exclusion

### Idea

The previous analysis established that the gap scenario is "consistent with temporal axioms in the constant-MCS case." But does the construction ACTUALLY produce constant-MCS chains? If we can show the construction forces non-constant MCS labels, we get a discriminating formula, and Z1 or Prior-UZ can close the gap.

### Analysis: Can the construction produce constant-MCS labels?

**Stage 0**: `limit_f(0) = A` (the root MCS).

**Stage 1**: Resolves some counterexample at point 0 (if applicable). If the counterexample is `U(eta, xi) in A`, the construction creates point `y` with MCS `C` where:
- `C` is obtained from `lemma_2_4_with_guard` (PointInsertion.lean:3343)
- `C` is a Lindenbaum extension of the seed `{beta} union g_content(A) union {snce(gamma, alpha) : alpha in A}`
- `g_content(A) = {phi | G(phi) in A}` (all formulas that A believes hold at all future points)
- So `g_content(A) subset C`

**Key question**: Is `C = A` possible?

For `C = A`, we would need `A` to be a Lindenbaum extension of the seed. Since `A` is already MCS and contains `g_content(A)`, and the seed also contains `beta = eta` and Since-obligations, we need `A` to contain:
- `eta` (the event formula)
- All Since-obligations `snce(xi, alpha)` for `alpha in A`

The event formula `eta` may or may not be in `A`. For `U(T, bot)` resolution:
- `eta = top_formula` (which IS in every MCS)
- `xi = bot` (the guard)

So for `U(T, bot)` resolution: `C` must contain `top` (yes, in every MCS), `g_content(A)` (yes, in `A` by definition), and `snce(bot, alpha)` for all `alpha in A`. Now `snce(bot, alpha) = S(alpha, bot)`. Is `S(alpha, bot) in A`?

`S(alpha, bot)` means "there exists a past point where alpha holds, and bot holds at all intermediate points." Under strict semantics, this is `exists y < x, alpha in f(y) and forall z, y < z < x -> bot in f(z)`. Since bot is never in any MCS, the intermediate condition says there are NO points between y and x. So `S(alpha, bot)` means "there exists an immediate predecessor where alpha holds."

In the discrete case with `Box(U(T, bot)) in A`, we have `U(T, bot) in A` and `S(T, bot) in A` (from `discrete_symm_fwd` axiom). But `S(alpha, bot)` for arbitrary `alpha in A` is NOT guaranteed. The MCS `A` may contain some alpha's but not `S(alpha, bot)`.

**However**, `g_content(A) subset A` is true by definition (if `G(phi) in A`, then `phi in A` would follow from reflexive G, but under STRICT semantics, `G(phi) in A` does NOT imply `phi in A`).

Wait -- `g_content(A) = {phi | G(phi) in A}`. Under strict semantics, `G(phi)` at point 0 means `phi` at all points STRICTLY greater than 0. It does NOT mean `phi in A` (which is f(0)). So `g_content(A)` may contain formulas NOT in `A`.

**This is key**: `g_content(A)` includes `phi` whenever `G(phi) in A`, but under strict semantics, `phi` need not be in `A` itself. So `C` must extend `g_content(A)`, which may NOT be a subset of `A`. Therefore `C = A` is NOT generally possible under strict semantics.

**But**: If `A` happens to be "temporally saturated" (every `G(phi) in A` implies `phi in A`), then `g_content(A) subset A` and `C = A` becomes possible. Under strict semantics, this is not forced by the axioms. However, the Burgess R3 maximality construction (Zorn's lemma) may CHOOSE `C = A` if `A` is temporally saturated and satisfies all the R-relation constraints.

**Conclusion on constant-MCS**: The constant-MCS scenario (`C = A` at every point) is NOT excluded by the seed construction alone, because:
1. Under strict semantics with a temporally saturated MCS, `g_content(A) subset A`
2. The Lindenbaum extension may select `A` itself when `A` satisfies all seed requirements
3. The Zorn construction for BurgessR3Maximal may choose `B subset A` when possible

The Boneyard README confirms: "BurgessR3Maximal returns the starting MCS when it is temporally saturated."

### Verdict: UNPROMISING

The constant-MCS scenario is not excludable from the construction properties alone. This confirms the documented analysis. Any proof must work even when all limit_f values are identical.

---

## 4. Strategy 4: U(T, bot) / Frozen Guard Semantics

### Idea

In the discrete case, `Box(U(T, bot)) in A` means every MCS in the domain has `U(T, bot)`. When C5 resolves `U(top, bot)` at point `x`:
- The witness `y` is placed at the immediate successor position
- The guard `bot` is in `g(x, y)` and in `g(a, b)` for all adjacent pairs between `x` and `y`
- Since `bot` is NEVER in any MCS, `adj_g_mem_limit_f` implies: there are NO limit_dom points between `x` and `y`
- This is precisely the "frozen guard" property: the successor relationship `x -> y` is permanent

### Analysis: Does this help with succ_cofinal?

The frozen guard gives: `succ(x) = y` in the limit domain, and no point is ever inserted between them. This is the foundation of `limitDomSubtype_succ` and `SuccOrder`. It is already USED in the proof -- it is what makes the discrete case have a SuccOrder at all.

**But the gap scenario is still consistent**: The orbit `0, succ(0), succ^2(0), ...` converges to `L`. Each consecutive pair has the frozen guard (no insertions between them). Point `pred(b)` has `succ(pred(b)) = b`, also frozen. The issue is: are there limit_dom points with values in `(L-epsilon, L)` that are NOT orbit points?

The frozen guard says: between `succ^n(0)` and `succ^{n+1}(0)`, there are no domain points. But it says nothing about points with values ABOVE all orbit values. Points in the pred-chain `pred^k(b)` satisfy `pred(pred^k(b)) = pred^{k+1}(b)`, also frozen. The two frozen chains (orbit going up, pred-chain going down) converge to `L` but never meet.

**Key insight that DOES help**: Consider what happens at stage `n_p` when a pred-chain point `p` is first inserted. At that stage, `p` is placed between two existing domain points `a_L < p < a_R`. In the LIMIT domain, `succ(a_L) = succ_{limit}(a_L)` may or may not equal `p`:

- If `succ_{limit}(a_L) = p`: then `a_L` is in the orbit (it was there at stage `n_p`) and `p = succ(a_L)` is also in the orbit. Contradiction with `p` being a gap point.
- If `succ_{limit}(a_L)` is something inserted BETWEEN `a_L` and `p` at a later stage: that point is also in the gap region, and the argument recurses.

The frozen guard means: once `succ(a_L) = z` is established (at whatever stage `z` enters), NO point is ever inserted between `a_L` and `z`. So if `z = p`, it stays that way. If `z` is inserted before `p`, then `p` is above `z`, and we need `succ(z)` to eventually reach `p`.

**This brings us back to the original problem**: the frozen guard is necessary infrastructure but not sufficient for the gap elimination.

### What WOULD suffice

If we could prove: "when point `p` is inserted at stage `n_p`, its immediate predecessor in the stage-`n_p` domain is already in the orbit of 0," then `p = succ(predecessor) = succ(orbit point) = next orbit point`, and `p` is in the orbit.

**Why this is hard**: At stage `n_p`, the domain is `omega_chain_val(n_p).dom`. The predecessor of `p` in this domain (call it `a_L`) may be an orbit point or itself a gap point inserted at an earlier stage. If `a_L` is a gap point, we need to show `a_L` is in the orbit, which requires the same argument applied to `a_L`.

This is a well-founded induction on stages: if we process points in order of their entry stage, and show each is an orbit point assuming all earlier points are orbit points. But the predecessor of `p` at stage `n_p` may have entered at a LATER stage than `p` (if `a_L` was in the original domain and `p` was inserted adjacent to it, but then another point was inserted between `a_L` and `p` at a later stage, becoming the new predecessor).

Wait -- the predecessor of `p` in the LIMIT domain may differ from the predecessor at stage `n_p`. In the limit, `pred(p)` is the immediate predecessor with no domain points between. But at stage `n_p`, the predecessor might be `a_L` with `a_L < p < a_R`, and later points `z_1, z_2, ...` are inserted in `(a_L, p)`. Eventually `pred_{limit}(p) = z_k` for the last such insertion.

The frozen guard for `p` says: `pred(p)` is frozen once established. Since `U(T, bot) in limit_f(pred(p))`, we get `succ(pred(p)) = p` with no insertions between. So once `pred(p)` enters the domain, the pair `(pred(p), p)` is permanent.

But `pred(p)` may enter AFTER `p`, creating a new pair inside what was previously `(a_L, p)`.

### Verdict: NEEDS INVESTIGATION

The frozen guard / U(T, bot) structure provides important constraints but does not by itself close the gap. The critical question is whether we can show by stage induction that every point's limit-predecessor is an orbit point. This requires understanding the temporal ordering of point insertions, which is exactly the "construction-level argument" from Strategy 5.

---

## 5. Strategy 5: Direct Construction Argument (Discrete Case)

### Idea

Instead of proving `succ_cofinal` for general limit domains, exploit the discrete case properties to prove a construction-specific claim:

> **Claim**: Every point in the limit domain is `succ^n(0)` or `pred^n(0)` for some `n : Nat`.

This implies `succ_cofinal` immediately: if `a = succ^m(0)` and `b = succ^k(0)` with `m < k`, then `succ^{k-m}(a) = b`.

### Analysis

**Why this might work for discrete but not dense**: In the dense case, the limit domain is order-isomorphic to Q (rationals), which is NOT a Z-chain. In the discrete case, the claim is that the limit domain IS a single Z-chain. This is the content of `succ_cofinal` / `IsSuccArchimedean`.

**Construction-level argument sketch**:

Define `orbit := { succ^n(0) | n : Nat } union { pred^n(0) | n : Nat }`. We want to show `limit_dom = orbit`.

Approach: induction on stage number `N`.

**Base**: `dom(0) = {0} = orbit intersection dom(0)`. Trivially, all stage-0 points are orbit points.

**Step**: Assume all points in `dom(N)` are orbit points. At stage `N+1`, the construction either:
1. Adds no new point (identity elimination): `dom(N+1) = dom(N)`, done by IH.
2. Adds one new point `y` resolving a C5/C4 counterexample.

For case 2, we need: `y` is an orbit point.

Sub-case 2a: `y` resolves a C5 forward counterexample `U(eta, xi) at x`. Then `y > x` and `y` is placed either:
- Beyond `max(dom(N))` (Burgess 2.4): then `y > max(dom(N))`. By IH, `max(dom(N))` is an orbit point, say `max(dom(N)) = succ^m(0)`. In the limit domain, `succ(max(dom(N))) = succ^{m+1}(0)`. If `y = succ^{m+1}(0)`: done. **But is y = succ^{m+1}(0)?**
  - At stage `N+1`, `y` is the first point beyond `max(dom(N))`. In the limit domain, `succ(max(dom(N)))` is the NEAREST limit_dom point above `max(dom(N))`. If `y` is the nearest: `y = succ(max(dom(N)))` and we're done. If a closer point is inserted at a LATER stage between `max(dom(N))` and `y`: then `succ(max(dom(N)))` is that closer point, not `y`. Then `y = succ^{k+1}(0)` for some `k > m` -- still an orbit point.
  - **Key argument**: In the limit, `succ(max(dom(N)))` is some point `z <= y`. If `z = y`: done. If `z < y`: `z` is in the limit domain, `z > max(dom(N))`, so `z notin dom(N)`. `z` entered at some stage `M > N`. By IH on stage `M`, if all dom(M-1) points are orbit points and `z` is the new point at stage `M`... but we're trying to prove `z` is an orbit point, which is the induction step.

**The circularity**: Proving the point at stage `N+1` is an orbit point requires knowing that points inserted at later stages (which become the limit-predecessor/successor) are orbit points. This is forward-looking, not backward-looking.

**Possible fix**: Induct on the well-founded order of point VALUES, not stage numbers.

**Value induction sketch**:
- The orbit generates a sequence of rationals: `..., pred^2(0), pred(0), 0, succ(0), succ^2(0), ...`
- In the limit domain, these form a Z-chain.
- If there exists a non-orbit point `p`, take the one with SMALLEST `|p.val|` (or some measure).
- `pred(p)` and `succ(p)` are also in the limit domain.
- If `pred(p)` is an orbit point and `succ(p)` is an orbit point: `pred(p) = succ^m(0)` and `succ(p) = succ^n(0)`. Then `succ(pred(p)) = succ^{m+1}(0)`. But `succ(pred(p)) = p` (from `succ_pred`). So `p = succ^{m+1}(0)`, an orbit point. Contradiction.
- So if `p` is non-orbit, at least one of `pred(p)` or `succ(p)` is non-orbit.
- By minimality of `|p.val|`, `pred(p)` and `succ(p)` have `|val| >= |p.val|`.
- But `pred(p).val < p.val < succ(p).val`, so `|pred(p).val|` might be less than `|p.val|` if `p.val > 0` and `pred(p).val >= 0`. This doesn't give a clean well-founded argument.

**Alternative well-founded measure**: Use `distance_to_orbit(p) := inf { |p.val - q.val| : q in orbit }`.
- If `p` is non-orbit, `distance > 0`.
- `pred(p)` is closer to the orbit (since `pred(p).val < p.val` and the orbit extends below `p.val`... unless the orbit is bounded from above, which is the gap scenario).

This circularly assumes the orbit is unbounded, which is `succ_cofinal`.

### The core insight (from report 48)

The most promising construction-level argument from report 48:

> If point `p` is above ALL orbit points (value > L), then `p` was inserted at some finite stage `n_p`. At stage `n_p`, the domain has a maximum orbit point `succ^K(0)`. Point `p` is above `succ^K(0)`. Then `pred(p)` in the limit domain satisfies `pred(p).val >= succ^K(0).val` (since `pred(p) < p` and `pred(p)` is the nearest limit_dom point below `p`).
>
> If `pred(p).val < L`: by `orbit_below_L`, `pred(p)` is an orbit point, so `p = succ(pred(p))` is an orbit point. Contradiction.
>
> If `pred(p).val >= L`: `pred(p)` is also a gap point, and `pred(pred(p))` is also a gap point, giving infinite descent toward `L`. But the descent converges to `L`, and we never find an orbit point as the predecessor.

**This IS the gap scenario in the current proof.** The construction-level argument says the same thing as the convergence analysis already coded at lines 1656--1696.

### Verdict: NEEDS INVESTIGATION (but likely UNPROMISING for direct approach)

A purely construction-level argument faces the same gap scenario. The value-induction approach fails because the orbit may be bounded. The stage-induction approach is circular because future-stage insertions affect the limit-domain successor structure.

However, there is one unexplored angle: **showing that the construction cannot produce a gap point whose predecessor is also a gap point** (blocking infinite descent). This requires analyzing what counterexample resolution leads to the insertion of points in the gap region.

---

## 6. Strategy 6: Existing Infrastructure Audit

### succ_orbit_convex (lines 1093--1113, SORRY-FREE)

**Statement**: If `a <= b <= succ^n(a)`, then `b = succ^k(a)` for some `k <= n`.

**How it works**: Induction on `n`. If `b = succ^n(a)`: done. Otherwise `b < succ^n(a)`, so `b <= pred(succ^n(a)) = succ^{n-1}(a)` (using `succ_pred`). Apply IH.

**Relevance**: This is used AFTER `succ_cofinal` to convert from "succ^n(a) >= b" to "succ^k(a) = b". It does NOT help prove cofinality.

### succ_embed_squeeze_strict (lines 2773--2805, SORRY-FREE)

**Statement**: If `succ_embed(a) < w < succ_embed(b)` for `a < b`, then `w = succ_embed(k)` for some `a < k < b`.

**How it works**: Uses `succ_embed_no_gap` (no limit_dom point between consecutive succ_embed images) and induction on `b - a`.

**Relevance**: Works for points BETWEEN two known embedded points. Cannot handle points OUTSIDE the embedded range (which is the `succ_embed_surjective` problem, equivalent to `succ_cofinal`).

### succ_embed_no_gap (SORRY-FREE)

**Statement**: There is no limit_dom point strictly between `succ_embed(k)` and `succ_embed(k+1)`.

**How it works**: Direct from the frozen guard / SuccOrder properties.

**Relevance**: This is the foundation of the discrete case. It confirms that consecutive orbit points have no insertions between them. But it says nothing about points above the orbit.

### backward_G (lines 1703--1753, SORRY-FREE within succ_cofinal proof)

**Statement**: If `psi in limit_f(y)` for ALL `y > x` in limit_dom, then `G(psi) in limit_f(x)`.

**Proof**: By contradiction. If `not G(psi) in limit_f(x)`, then `neg(G(psi)) = F(neg(psi)) in limit_f(x)`. By `limit_F_resolution`, there exists `y > x` with `neg(psi) in limit_f(y)`. But `psi in limit_f(y)` by hypothesis. Contradiction.

**Key property**: This does NOT use `succ_cofinal`. It uses `limit_F_resolution`, which is sorry-free. This means we can establish G-truth at any point from universal F-truth, without circularity.

### limit_satisfies_c5_strong (ChronicleConstruction.lean:1430, SORRY-FREE)

**Statement**: If `U(eta, xi) in limit_f(x)`, then there exists `y > x` in limit_dom with `eta in limit_f(y)` and the guard `xi in limit_f(w)` for all `w in limit_dom` with `x < w < y`.

**Relevance**: This is the frozen guard in the limit. For `U(T, bot)`, the guard is `bot`, meaning NO domain points between `x` and `y`. This is what makes the discrete case discrete.

---

## 7. Strategy Rankings

| Rank | Strategy | Verdict | Reasoning |
|------|----------|---------|-----------|
| 1 | Direct Construction (Strategy 5, refined) | NEEDS INVESTIGATION | Only approach that engages with WHY the construction cannot produce gaps. Requires new insight about counterexample resolution in the gap region. |
| 2 | U(T, bot) Frozen Guard (Strategy 4) | NEEDS INVESTIGATION | Provides strong constraints but needs combination with construction argument. The "frozen predecessor is an orbit point" claim is the key unproved step. |
| 3 | Constant-MCS Exclusion (Strategy 3) | UNPROMISING | Confirmed that constant-MCS is consistent with the construction. The Boneyard README explicitly states this. |
| 4 | Stage Induction (Strategy 2) | UNPROMISING (DEAD) | Already attempted, archived in Boneyard. Boundary cases intractable. |
| 5 | Well-Founded Measure (Strategy 1) | UNPROMISING | Reduces to the same gap problem. Stage numbers don't provide useful ordering. |

---

## 8. Refined Approach: Construction Contradiction in the Gap Region

This combines insights from Strategies 4 and 5 into a concrete attack plan.

### Setup

Assume the gap scenario: orbit `{succ^n(a) | n : Nat}` converges to `L`, and there exist limit_dom points above `L` (the pred-chain from `b`). Let `p` be ANY limit_dom point with `p.val > L`.

### Step A: p was inserted to resolve some counterexample

Point `p` entered at stage `stage(p)`. The counterexample resolved was `counterexample_enum(Nat.unpair(stage(p) - 1).2)` (since `omega_chain(stage(p)) = eliminate(omega_chain(stage(p)-1), ...)` ).

There are four kinds of counterexamples:
1. **C5 forward** (`U(eta, xi) at x`): witness `y` placed above `x` or between adjacent dom points.
2. **C5 backward** (`S(eta, xi) at x`): witness `y` placed below `x` or between adjacent dom points.
3. **C4 forward** (negation of Until): witness `z` placed between two dom points.
4. **C4 backward** (negation of Since): witness `z` placed between two dom points.

### Step B: In which cases does p end up above L?

- **C5 forward, base case**: `p` is placed above `max(dom(stage(p)-1))`. If `max(dom(stage(p)-1))` is an orbit point `succ^K(a)` (which it is, if all dom(stage(p)-1) points are orbit points by IH), then `p > succ^K(a)`. In the limit, `succ(succ^K(a))` is either `p` or a point inserted later between `succ^K(a)` and `p`. Either way, `p` is reachable from the orbit.

- **C5 forward, walk/split case**: `p` is placed between two consecutive dom points. If both are orbit points (by IH), `p` is between consecutive orbit points. But orbit points have the frozen guard -- no domain points between them. So `p` cannot be between two consecutive orbit points.

  Wait -- the orbit points at stage `stage(p)-1` are `succ_N` iterates within dom(stage(p)-1). They are NOT necessarily consecutive in the limit domain. Between orbit-point `succ^k(a)` (value $v_k$) and `succ^{k+1}(a)` (value $v_{k+1}$), there are no limit_dom points (frozen guard). But the C5 walk goes between `x` and the NEXT dom(stage(p)-1) point after `x`, which may skip many orbit points that haven't been inserted yet.

  **No**: at stage `stage(p)-1`, the domain is a finite set. The walk goes from `x` to the next dom point in that finite set. These may not be consecutive orbit points in the limit.

### Step C: The key difficulty restated

The problem is that at stage `n`, the domain `dom(n)` contains only SOME of the orbit points. The orbit structure is determined by the LIMIT, not by finite stages. At stage `n`:
- `dom(n)` has `n+1` points (at most, since one point is added per stage)
- These include `0` and `n` other inserted points
- The succ-structure in the limit may differ from the adjacency structure at stage `n`

**The fundamental mismatch**: The orbit is defined using limit-domain succ (which is non-constructive, using `Classical.choose`), while the construction builds the domain point-by-point. There is no simple relationship between "the order in which points are inserted" and "their position in the succ-orbit."

### Verdict on Refined Approach: STILL NEEDS INVESTIGATION but reveals the core difficulty

The core difficulty is that the succ-orbit is defined in the limit, and the construction builds finitely. Proving every point is in the orbit requires showing the limit-succ function is compatible with the construction's point-placement, which is a deep structural property.

---

## 9. Key Files and Line Numbers

| Item | Location |
|------|----------|
| `succ_cofinal` (sorry at Step 9) | `ChronicleToCountermodel.lean:1885` |
| `succ_reaches_dom_N` (sorry at boundary) | `ChronicleToCountermodel.lean:1285, 1441` |
| `limit_dom_points_are_succ_iterates` (sorry) | `ChronicleToCountermodel.lean:1508` |
| `succ_orbit_convex` (sorry-free) | `ChronicleToCountermodel.lean:1093` |
| `succ_embed_squeeze_strict` (sorry-free) | `ChronicleToCountermodel.lean:2773` |
| `backward_G` (sorry-free, within succ_cofinal) | `ChronicleToCountermodel.lean:1703` |
| `limit_satisfies_c5_strong` (sorry-free) | `ChronicleConstruction.lean:1430` |
| `adj_g_mem_limit_f` (sorry-free) | `ChronicleConstruction.lean:1357` |
| `omega_chain_dom_new_unique` (sorry-free) | `ChronicleConstruction.lean:1186` |
| `omega_chain_c5_witness` (sorry-free) | `ChronicleConstruction.lean:391` |
| `limit_dom_has_succ` (sorry-free) | `ChronicleToCountermodel.lean:839` |
| `limitDomSubtype_succ` | `ChronicleToCountermodel.lean:882` |
| `EliminationResult` structure | `CounterexampleElimination.lean:560` |
| `c5_forward_walk` | `CounterexampleElimination.lean:667` |
| `lemma_2_4_with_guard` | `PointInsertion.lean:3343` |
| `singleton_chronicle` (stage 0) | `ChronicleConstruction.lean:64` |
| `counterexample_enum_surjective_above` | `ChronicleConstruction.lean:223` |
| Boneyard README | `Boneyard/StageInductionGapAnalysis/README.md` |

---

## 10. Recommendations

### For `succ_cofinal` directly: BLOCKED without new mathematical insight

All investigated strategies encounter the same fundamental difficulty: the gap scenario (orbit converging to L, pred-chain from above) is consistent with every available proof ingredient at the formula/axiom level.

The one remaining angle -- a CONSTRUCTION-LEVEL argument showing the omega-chain cannot produce gaps -- requires a new idea about how point-insertion stages interact with the limit-domain succ structure. This idea does not emerge from any of the six strategies investigated.

### Recommended path forward

1. **Bypass via Reynolds pipeline** (task 155 primary goal): Complete the GHR93 game-based completeness proof, which provides `IsSuccArchimedean` through a different route that does not go through `succ_cofinal`.

2. **Bypass via Henkin model** (task 129): Build a Henkin-style model where `IsSuccArchimedean` holds by construction (every point is a distinct MCS on a Z-indexed chain).

3. **If direct proof is desired**: The most promising avenue is to prove a structural lemma about the omega-chain construction:

   > **Conjecture**: For every `p in limit_dom` with `p.val > 0`, there exists `q in limit_dom` with `q.val < p.val` and `stage(q) <= stage(p)` and `succ(q) = p`.

   This says: the limit-domain predecessor of `p` entered the domain no later than `p` did. If true, induction on `stage(p)` would show every point is in the orbit of 0.

   **Plausibility**: When `p` is inserted at stage `n_p` to resolve `U(eta, xi)` at some point `x`, the construction places `p` between `x` and the next existing domain point (or above all). The left neighbor `a_L` of `p` at stage `n_p` satisfies `stage(a_L) < stage(p)`. But `a_L` may not be `pred(p)` in the limit (other points may be inserted between `a_L` and `p` later).

   **Problem with this conjecture**: The frozen guard from `U(T, bot)` means no point is ever inserted between `pred_{limit}(p)` and `p`. But `pred_{limit}(p)` itself may be a point inserted AFTER `p`. At stage `stage(p)`, `p`'s left neighbor is `a_L`. If a point `q` is later inserted between `a_L` and `p`, then `q` becomes the new predecessor candidate. Eventually, `pred_{limit}(p) = q` for the LAST point inserted in `(a_L, p)` such that `succ(q) = p`. This point `q` may have `stage(q) > stage(p)`.

   So the conjecture `stage(pred(p)) <= stage(p)` is **FALSE** in general. The predecessor in the limit domain can enter the domain at a later stage than `p` itself.

   **However**, a weaker property may suffice: for any non-orbit point `p`, the set `{q in limit_dom : q.val between a.val and p.val}` grows at each stage, and every new point is succ-connected to an existing orbit point via the construction. This would need deep analysis of the C5 elimination walk (CounterexampleElimination.lean:667) to verify.

   Estimated effort if this approach works: 200-400 lines. Risk: HIGH. The construction mechanics are complex and may not yield the needed invariant.
