# Teammate D Findings: Alternative Proof Strategies for IsSuccArchimedean

Task: 123 | Date: 2026-05-11

## 1. Executive Summary

Five alternative strategies for proving `IsSuccArchimedean` were evaluated. The **Icc finiteness via LocallyFiniteOrder** approach (Strategy 1) is the most promising because it avoids real analysis entirely and leverages a clean Mathlib pipeline: `Set.Finite (Set.Icc a b)` => `LocallyFiniteOrder.ofFiniteIcc` => `LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder`. However, the core difficulty -- proving Icc finiteness -- remains the same as in the monotone convergence approach. The **well-founded recursion on stage of entry** approach (Strategy 3) is a viable alternative that avoids real analysis but requires careful measure design. Strategies 2 and 4 are partial variants that don't eliminate the fundamental difficulty.

**Confidence**: MEDIUM-HIGH that the proof IS achievable, LOW that any approach completely avoids real analysis or analogous convergence reasoning.

## 2. Strategy 1: Set.Icc Finiteness => LocallyFiniteOrder => IsSuccArchimedean

### Mathlib Pipeline (Already Available)

The following chain is fully supported by the currently imported Mathlib modules:

```
(1) LocallyFiniteOrder.ofFiniteIcc :
      (forall a b, (Set.Icc a b).Finite) -> LocallyFiniteOrder alpha

(2) LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder :
      [LinearOrder alpha] -> [LocallyFiniteOrder alpha] ->
      [SuccOrder alpha] -> IsSuccArchimedean alpha
```

Both lemmas are available in `Mathlib.Order.Interval.Finset.Defs` and `Mathlib.Order.SuccPred.LinearLocallyFinite` respectively, which are ALREADY imported in ChronicleToCountermodel.lean (line 9).

### What This Buys

Instead of proving `IsSuccArchimedean` directly (by-contradiction + monotone convergence), we prove `Set.Finite (Set.Icc a b)` for all `a b : LimitDomSubtype A h_mcs`, then instantiate `LocallyFiniteOrder`, and get `IsSuccArchimedean` for free.

### Proof of Icc Finiteness

The key claim: in the discrete case, for any `a b : LimitDomSubtype A h_mcs`, the set `{w : LimitDomSubtype | a <= w <= b}` is finite.

**Approach A: Stabilization at a finite stage**. For any a, b in limit_dom, there exist stages K_a and K_b such that a.val in dom(K_a) and b.val in dom(K_b). Let K = max(K_a, K_b). At stage K, dom(K) is a `Finset Rat`. The claim would be that `{w in limit_dom | a.val <= w <= b.val} subset dom(K')` for some K' >= K.

This is FALSE in general: later stages can insert new points in [a.val, b.val] via C4 midpoint insertions. Each stage adds at most one point (`dom_new_unique`), but there is no a priori bound on how many stages add points to any given interval.

**Approach B: Bounded monotone contradiction**. Suppose `Set.Icc a b` is infinite. Then there exists an injective sequence `f : Nat -> LimitDomSubtype` with `a <= f(n) <= b` for all n. Since `LimitDomSubtype` is a subtype of `Rat`, the sequence `f(n).val` consists of distinct rationals in `[a.val, b.val]`. Cast to R, this is a bounded infinite sequence, hence has a convergent monotone subsequence (by Bolzano-Weierstrass). The limit L in R has the property that limit_dom points accumulate near L. But the bot-gap property (from `limit_dom_has_succ`: no limit_dom points between x and succ(x)) creates discrete gaps around every limit_dom point. This contradicts accumulation.

This is the SAME real analysis argument as the current monotone convergence plan, just packaged differently. It proves Icc finiteness rather than IsSuccArchimedean directly, but uses the same core mathematical content.

**Approach C: Counting argument (no real analysis)**. The succ-orbit from a inside [a, b] is a strictly increasing sequence of limit_dom points: a, succ(a), succ^2(a), .... By `succ_orbit_convex` (already proved, line 1112), if b <= succ^n(a) for some n, then all points in [a, b] are of the form succ^k(a). The number of such points is n+1, which is finite.

The problem: this PRESUPPOSES that b <= succ^n(a) for some n, which IS exactly IsSuccArchimedean. So this approach is circular if used to prove Icc finiteness as a stepping stone to IsSuccArchimedean.

### Assessment

Strategy 1 provides a CLEANER Lean formalization path (instantiate two typeclasses) but does NOT reduce the mathematical difficulty. The core challenge remains proving that bounded intervals are finite, which requires the same convergence/contradiction argument.

**Advantage**: Modular -- the finiteness proof is independent and reusable. If proved, both `LocallyFiniteOrder` and `IsSuccArchimedean` follow immediately.

**Disadvantage**: No mathematical simplification. The proof of Icc finiteness is essentially the same as the direct proof of IsSuccArchimedean.

## 3. Strategy 2: Finset Counting Approach

### Idea

Use the fact that each `dom(K)` is a `Finset Rat` and each step adds at most 1 point (`dom_new_unique`) to bound the total number of points in any interval.

### Analysis

At stage K, `dom(K) ∩ [a.val, b.val]` has some finite number of points N_K. At stage K+1, at most one new point is added (to the entire domain, not necessarily to [a.val, b.val]). So:

```
|dom(K+1) ∩ [a.val, b.val]| <= |dom(K) ∩ [a.val, b.val]| + 1
```

In the limit: `|limit_dom ∩ [a.val, b.val]| <= sum over all stages of new points in [a.val, b.val]`. Since there are countably infinite stages and each can contribute at most one point, this gives only a countable upper bound, not a finite one.

### Can C4/C5 Add Infinitely Many Points to a Bounded Interval?

**C5 elimination** (with bot guard): Inserts a successor point. In the discrete case, the bot-guard means the new point is an immediate successor with no domain points between it and the reference point. This can add points above or below, but always at the "boundary" of existing domain points.

**C4 elimination**: Inserts a midpoint between two existing points. For each pair (x, neg(U(xi,eta))), a new witness is added between x and some y. These insertions can theoretically target any interval repeatedly, as new counterexamples are enumerated.

The key question is: can C4 midpoint insertions add infinitely many points to [a.val, b.val]?

In the DENSE case (when U(T,bot) is NOT present everywhere), the answer is YES -- this is what creates density (DenselyOrdered).

In the DISCRETE case (when U(T,bot) IS present everywhere), C5 with bot guard creates immediate successors. BUT C4 can still insert midpoints for other formula pairs. However, the bot-gap property from `limit_dom_has_succ` says: in the LIMIT, there are NO domain points between x and succ(x). So any midpoints inserted by C4 between x and its eventual successor must be "absorbed" -- they become the new immediate successor themselves, and the gap moves.

This suggests that the interval stabilizes, but proving this formally requires showing that the C4/C5 process cannot insert infinitely many points in any bounded rational interval in the discrete case. This is the crux of the difficulty.

### Assessment

The Finset counting approach does NOT directly give finiteness because the number of stages is infinite. It would work if we could show only finitely many stages add points to [a.val, b.val], but this is precisely what's hard to prove.

**Confidence**: LOW that this approach is simpler than real analysis.

## 4. Strategy 3: Well-Founded Recursion on Stage of Entry

### Idea

Define `stage(x) = min { K : x.val in dom(K) }` for each `x in limit_dom`. Prove IsSuccArchimedean by well-founded induction on some measure involving stage.

### Measure Design

**Attempt 1: stage(b) - stage(a)**. This fails because `pred(w)` can have a HIGHER stage than w (a predecessor in the full limit_dom might be inserted at a later stage of the omega chain).

**Attempt 2: (stage(b), dom(stage(b)) ∩ [a.val, b.val])** lexicographic. At each step of the succ iteration, either:
- succ^n(a) enters at a later stage (stage decreases in the interval count), or
- succ^n(a) enters at the same stage as b (interval count decreases).

This is WRONG because succ^n(a) might enter at a later stage than b AND be in a different interval.

**Attempt 3: Rational distance d(x) = b.val - x.val**. The pred-chain from b (or equivalently, the succ-chain from a towards b) has strictly decreasing rational distance. But Q+ is not well-ordered, so d is not a well-founded measure.

**Attempt 4: |dom(K) ∩ [x.val, b.val]| at stage K = stage(x)**. For each point x on the succ-path from a to b, at the stage where x enters the domain, count how many domain points at that stage are between x and b. This count strictly decreases along the succ-chain IF all relevant points are at the same stage. But they might not be.

### The Real Insight

The well-founded recursion approach works IF we can find a measure that strictly decreases along the succ-chain. The key observation: each point in LimitDomSubtype enters the omega chain at a finite stage and has a finite position within that stage's domain. The pair `(stage(x), position(x))` in Nat x Nat with lexicographic ordering is well-founded. But proving the measure decreases requires showing `stage(succ(x)) <= stage(x)` OR that position decreases, which is not obvious because `succ(x)` is determined by the FULL limit_dom, not by any finite stage.

### Assessment

Well-founded recursion is mathematically cleaner than real analysis (avoids topology and convergence) but the measure design is equally difficult. The fundamental issue is that `limitDomSubtype_succ` operates on the full limit domain, not on any finite stage, making stage-based reasoning difficult.

**Confidence**: LOW-MEDIUM. A correct measure likely exists but finding it is hard.

## 5. Strategy 4: Limited Surjectivity (Bypass Full IsSuccArchimedean)

### Idea

Instead of proving `succ_embed_surjective` for ALL points, prove surjectivity only for points that appear as C5 witnesses -- which is what TC and FUC actually need.

### Analysis

TC (temporal coherence) needs: if `F(phi) in limit_f(succ_embed(t))`, find `m > t` with `phi in limit_f(succ_embed(m))`. The F-resolution gives a witness `y in limit_dom` with `y > succ_embed(t).val` and `phi in limit_f(y)`. We need `y = succ_embed(m).val` for some integer m.

FUC (forward-Until coherence) needs: similarly, map limit_dom witnesses back to integers.

Could we prove surjectivity only for C5 witnesses? No -- C5 witnesses are ARBITRARY points in limit_dom (they are chosen by `Classical.choose` from the full limit domain). A C5 witness y might be ANY limit_dom point above the reference point. So "surjectivity for C5 witnesses" IS full surjectivity.

### Alternative: Direct TC/FUC Without Surjectivity

Could we prove TC/FUC without mapping back to integers at all? The TC condition says: for `F(phi) in discrete_f(t)`, there exists `t' > t` with `phi in discrete_f(t')`. Since `discrete_f(t) = limit_f(succ_embed(t).val)`, and we know `limit_forward_G` gives witnesses in limit_dom, we need the witness to be an embedded point.

One approach: instead of finding ANY limit_dom witness and mapping it back, construct the integer witness directly. We know `F(phi) in limit_f(succ_embed(t))`, which means `G(phi) in limit_f(succ_embed(t))` (by the F-axiom). By `limit_forward_G`, `phi in limit_f(y)` for all y > succ_embed(t) in limit_dom. In particular, `phi in limit_f(succ_embed(t+1))`, so t' = t+1 works.

Wait -- does `limit_forward_G` give `phi in limit_f(y)` for ALL y > x, or just for SOME y > x? Let me check.

From the codebase (line ~694): `limit_forward_G_strong` says if `G(phi) in limit_f(x)` and `y > x` and `y in limit_dom`, then `phi in limit_f(y)`. This is UNIVERSAL -- it applies to ALL y > x in limit_dom, not just some witness.

This means: for TC, we have `G(phi) in limit_f(succ_embed(t))`, and `succ_embed(t+1) > succ_embed(t)` (strict monotonicity), so `phi in limit_f(succ_embed(t+1))`. Therefore `phi in discrete_f(t+1)`, and t' = t+1 works.

WAIT -- does TC actually require this? Let me check what TC says precisely.

### Checking TC Definition

TC (temporal coherence) for a BFMCS says: if `F(phi) in f(t)`, then there exists `t' > t` with `phi in f(t')`. For the discrete FMCS, `f(t) = limit_f(succ_embed(t).val)`.

If `F(phi) in limit_f(succ_embed(t).val)`:
- `F(phi) -> G(phi)` is a BX theorem, so `G(phi) in limit_f(succ_embed(t).val)`
- By `limit_forward_G`, `phi in limit_f(y)` for all `y > succ_embed(t).val` in limit_dom
- In particular, `phi in limit_f(succ_embed(t+1).val)`
- So `phi in discrete_f(t+1)`, giving t' = t+1

This WORKS! TC does NOT need surjectivity!

Similarly for backward temporal coherence and FUC -- if the coherence conditions can be proved using limit_forward_G/backward_H directly on succ_embed points rather than mapping arbitrary witnesses back.

### Checking FUC Definition

FUC (forward-Until coherence) says: if `U(xi,eta) in f(t)`, then there exists `t' > t` with `eta in f(t')` and `xi in f(s)` for all t < s < t'.

The current proof (lines ~2494-2547) uses `limit_satisfies_c5_strong` to get a witness `y in limit_dom` with `eta in limit_f(y)` and a guard condition. Then it maps y back to an integer via `succ_embed_surjective`. Without surjectivity, we need an alternative.

Key insight for FUC: `U(xi,eta) in limit_f(succ_embed(t))`. The C5 strong witness gives y > succ_embed(t) with eta in limit_f(y) and the guard: bot.neg = xi in limit_f(w) for all w between succ_embed(t) and y.

Actually wait -- the C5 strong witness for Until uses the GUARD formula, not bot. For `U(xi,eta)`, the guard is `xi` (xi holds at all intermediate points). So the C5 strong witness gives: there exists `y in limit_dom` with `y > succ_embed(t)`, `eta in limit_f(y)`, and `xi in limit_f(w)` for all `w in limit_dom` with `succ_embed(t) < w < y`.

Now, `succ_embed(t+1)` is between `succ_embed(t)` and y (or equals y). If `succ_embed(t+1) < y`, then `xi in limit_f(succ_embed(t+1))`. We can iterate: is `U(xi,eta) in limit_f(succ_embed(t+1))`? This requires `U(xi,eta) in limit_f(succ_embed(t+1))`. We know `xi in limit_f(succ_embed(t+1))`, but we need `U(xi,eta)` specifically.

Using the MCS property: `U(xi,eta) in limit_f(succ_embed(t))` and `succ_embed(t) < succ_embed(t+1) < y`. By the Until axiom, `U(xi,eta) -> xi /\ U(xi,eta) \/ eta`. Hmm, this isn't quite right.

Actually, a cleaner approach: `U(xi,eta) in limit_f(succ_embed(t))`. By C5 strong, there exists y with `eta in limit_f(y)` and guard `xi in limit_f(w)` for all intermediate w. Now I need to find an INTEGER t' with `eta in limit_f(succ_embed(t'))`. The witness y might not be an embedded point.

However, using `succ_embed_squeeze`: if `succ_embed(t) < y <= succ_embed(t+k)` for some k, then y = succ_embed(j) for some t < j <= t+k. This IS surjectivity restricted to the range [succ_embed(t), succ_embed(t+k)].

But finding such k requires knowing that succ_embed eventually passes y -- which IS IsSuccArchimedean.

### Assessment

TC CAN be proved without surjectivity, using `limit_forward_G` directly on embedded points.

FUC CANNOT be proved without some form of surjectivity or IsSuccArchimedean. The Until witness from C5_strong lives in the full limit_dom and must be mapped back to an integer.

**Confidence**: MEDIUM that TC bypass works. LOW that FUC bypass works.

## 6. Strategy 5: Multi-Attempt Tactic Exploration

Tried `omega`, `simp`, `exact?`, `apply?`, `aesop` at the sorry site (line 1211). None close the goal:

```
h_not_cofinal : forall n, (limitDomSubtype_succ ...)^[n] a < b
|- False
```

This is expected -- the goal requires a substantive mathematical argument, not a simple tactic application.

## 7. Comparative Assessment

| Strategy | Avoids Real Analysis? | Mathematical Difficulty | Lean Formalization | Confidence |
|----------|----------------------|------------------------|--------------------|------------|
| 1. Icc Finiteness + LFO | No (same core argument) | SAME as current plan | CLEANER (typeclass pipeline) | MEDIUM-HIGH |
| 2. Finset Counting | Would if it worked | DOES NOT GIVE FINITENESS | N/A | LOW |
| 3. Well-Founded Stage | Yes (pure order theory) | HARD (measure design) | HARDER (WF machinery) | LOW-MEDIUM |
| 4. Limited Surjectivity | Partial (TC only) | EASIER for TC, SAME for FUC | MIXED | MEDIUM for TC |
| 5. Tactic Exploration | N/A | N/A | IMPOSSIBLE (too complex) | NONE |

## 8. Recommendation

**Primary recommendation**: Use the **monotone convergence + predecessor contradiction** approach as currently planned (plan 04), but structure the proof to prove **Icc finiteness** as an intermediate lemma, then instantiate `LocallyFiniteOrder.ofFiniteIcc` and get `IsSuccArchimedean` from the Mathlib instance. This is cleaner Lean than proving `IsSuccArchimedean.mk` directly.

Specifically:

```lean
-- Step 1: Prove Icc finiteness (the hard part)
theorem limitDomSubtype_Icc_finite (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : forall x in limit_dom A h_mcs, next_top in limit_f A h_mcs x)
    (a b : LimitDomSubtype A h_mcs) :
    Set.Finite (Set.Icc a b) := by
  -- Monotone convergence argument here
  ...

-- Step 2: Instantiate LocallyFiniteOrder (free from Mathlib)
noncomputable def limitDomSubtype_locallyFiniteOrder ... :=
  LocallyFiniteOrder.ofFiniteIcc (limitDomSubtype_Icc_finite ...)

-- Step 3: IsSuccArchimedean follows automatically
-- LinearLocallyFiniteOrder.instIsSuccArchimedeanOfLocallyFiniteOrder
-- gives IsSuccArchimedean for free
```

**Secondary recommendation**: If real analysis imports are a concern, investigate Strategy 4 (limited surjectivity) for TC specifically. TC can be proved without surjectivity by using `limit_forward_G` directly. FUC still requires surjectivity.

**Tertiary recommendation**: The current direct proof in plan 04 (monotone convergence at the sorry site) is also viable and slightly more direct. The choice between "prove Icc finiteness then get IsSuccArchimedean" vs "prove IsSuccArchimedean directly" is a matter of style -- the mathematical content is identical.

## 9. Key Insight: No Approach Avoids the Core Difficulty

All viable approaches reduce to the same fundamental question: **can the succ-orbit of a point in LimitDomSubtype accumulate (converge without reaching) at a point?** The answer is NO, and proving this requires either:

(a) Real analysis: bounded monotone sequences converge, and the limit point creates a contradiction via the bot-gap property (the current plan).

(b) A well-founded measure on LimitDomSubtype that strictly decreases along the succ-chain while staying in [a, b]. No simple measure (stage, distance, position) has been found to work.

(c) Direct construction: show that `succ_embed(t+k)` eventually passes any given b by constructing the specific k. This requires tracking succ through the omega-chain construction, which creates the mutual-dependency problem documented in report 05.

The monotone convergence approach (a) remains the most promising because Mathlib provides all the needed tools and the argument is mathematically clean.
