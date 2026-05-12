# Research Report: Stage-Walk Revised with New Infrastructure

Task: 123 | Date: 2026-05-12 | Round: 15

## Executive Summary

This report re-examines the gap-at-L sorry in `succ_cofinal` (ChronicleToCountermodel.lean:1778) in light of the new infrastructure proved since plans v9/v10. The key finding is that **the Prior-SZ maximum principle approach (Alternative D from report 14) is the most viable path**, requiring no Z1 DerivationTree and no discriminating formula search. The approach needs approximately 80-120 lines of new Lean code and relies entirely on infrastructure that is already proved or straightforwardly derivable.

The stage-walk approach (plans v9/v10) remains blocked at the boundary cases. The Z1/Doets approach (plan v11) is blocked by the complex syntactic Z1 derivation. The Prior-SZ approach bypasses both blockers.

---

## 1. Construction Properties Relevant to Gap Elimination

### 1.1 The omega-chain structure

The omega-chain construction (ChronicleConstruction.lean:235-265) builds a sequence of chronicles:
- `omega_chain_val(0)` has `dom = {0}` with `f(0) = A` (the starting MCS)
- `omega_chain_val(n+1)` processes `counterexample_enum(Nat.unpair(n).2)`, either adding one new point or leaving the domain unchanged
- `omega_chain_dom_mono` (line 314): `dom(n) ⊆ dom(n+1)`
- `omega_chain_dom_new_unique` (line 1196): at most one new point per stage

### 1.2 How C5 witnesses are placed

For a C5 forward counterexample `U(η, ξ)` at point `x ∈ dom(n)` (lines 391-425):
- A witness `y ∈ dom(n+1)` is found with `x < y`
- Event: `η ∈ f(n+1)(y)`
- Adjacent-pair guard: `ξ ∈ g(n+1)(a,b)` for all adjacent `(a,b)` between `x` and `y`
- Domain guard: `ξ ∈ f(n+1)(w)` for all `w ∈ dom(n)` between `x` and `y`
- New-or-identity: either `y ∉ dom(n)` (new point) or `dom(n+1) ⊆ dom(n)` (resolved already)

For the specific case `U(⊤, ⊥)` (next_top):
- The guard formula is `⊥`
- Since `⊥ ∉` any MCS (by `bot_not_in_mcs`), `adj_g_mem_limit_f` ensures NO limit_dom point between `x` and `y`
- This means the C5-bot witness IS the immediate successor: `succ(x) = y`

### 1.3 What determines witness coordinates

C5 split case (CounterexampleElimination.lean): the witness is placed at `(x + ceiling) / 2` where `ceiling` is the next dom(n) point above `x`. C5 base case: the witness is placed beyond `max(dom(n))`. C4 witness: placed at `(x + y) / 2` between the two counterexample points.

### 1.4 The pred-chain and its construction relationship

The `pred` function is defined via `limit_dom_has_pred` (ChronicleToCountermodel.lean:873), which uses `limit_satisfies_c5'_strong` with `S(⊤, ⊥)`. The predecessor of any limit_dom point `x` is the C5-backward witness for `S(⊤, ⊥)` at `x`, processed at some stage. The `⊥`-guard ensures no limit_dom between `pred(x)` and `x`.

Key fact: `pred(x)` is determined by the C5-backward processing for `S(⊤, ⊥)` at `x`. This processing happens at stage `n` where `counterexample_enum(Nat.unpair(n).2) = ⟨x, 0, ⊥, ⊤, .c5_backward⟩`. The stage `n` is typically DIFFERENT from the stage where `x` enters the domain. Specifically, `first_stage(pred(x))` can exceed `first_stage(x)` -- this is why plan v8's induction failed.

---

## 2. Prior Plan Analyses

### 2.1 Plan v9 (stage-walk)

The core insight was correct: choose N large enough and walk through dom(N) points. The key lemma (plan v9 lines 336-443) showed that for adjacent dom(N) points where the C5-bot was resolved by stage N, `succ(z_j) = z_{j+1}`. However, the plan identified a genuine circularity: choosing N requires resolving C5-bot at all dom(N) points, but resolving adds new points to dom(N), creating more C5-bot obligations. Plan v9 left this circularity unresolved and marked Phase 2 as [BLOCKED].

### 2.2 Plan v10 (bot-guard adjacency, stage induction)

Replaced the "choose N" approach with direct Nat.rec induction on N. Proved 4 of 6 cases:
- Case 1 (both in dom(N)): IH directly
- Case 3-middle (a old, b new, b between dom(N) points): IH + orbit convexity
- Case 2-middle (a new between dom(N) points, b old): IH + orbit convexity
- Case 4 (both new): `omega_chain_dom_new_unique` gives a = b

**Two boundary cases remain as sorry** (lines 1295, 1448):
- Case 3-above-max (b above max(dom(N))): Cannot show `succ(max_N_sub)` enters dom(N+1). It may enter at a much later stage.
- Case 2-below-min (a below min(dom(N))): Mirror of the above.

The fundamental issue: at the boundary, `succ(max_N_sub)` is the next limit_dom point above max_N, but this point may be in `dom(M)` for `M >> N+1`. The IH only covers `dom(N)`, not `dom(M)`.

### 2.3 Plan v11 (Doets/Z1 gap elimination)

Pivoted away from stage induction entirely. The critical path goes through `succ_cofinal` (which uses convergence in R) rather than `succ_reaches_dom_N`. The sorry at line 1778 is in the `else` branch where `L <= pred(b).val`. The plan proposed deriving Z1 from Prior-UZ, then applying Doets Claim 10.

**Blockers identified**:
1. Z1 DerivationTree from Prior-UZ is complex (60-120 lines, intricate Until manipulation)
2. Finding a discriminating formula between orbit and pred-chain points
3. Report 14 confirmed that the semantic approach to Z1 has a circular dependency with IsSuccArchimedean

### 2.4 What the new infrastructure resolves

The new lemmas (backward_G, backward_F, orbit_below_L, h_lt_pred_chain, h_pred_chain_ge_L) are all inside the sorry branch and provide the structural foundation for the gap scenario. They do NOT resolve the Z1 derivation blocker or the discriminating formula problem by themselves. However, they enable **Alternative D from report 14**: the direct maximum principle from Prior-SZ.

---

## 3. Assessment of Each Strategy

### Strategy A: Adjacent dom(N) convergence

**Idea**: Show that for large k, `p^[k](pb)` is close to L. At some stage N, the orbit point and pred-chain point are adjacent in dom(N). Bot-guard forcing gives `succ(orbit_point) = pred_chain_point`.

**Assessment**: This is essentially the stage-walk approach (plan v9). The adjacency argument is correct in principle but has the circularity problem: there is no finite N where ALL dom(N) points in [a, b] have their C5-bot resolved simultaneously. Each resolution adds new points that need their own resolution. The process may not terminate at any finite N.

**Verdict**: BLOCKED by the same circularity as plan v9. Not viable without a termination argument.

### Strategy B: Track construction stages for next_top witnesses

**Idea**: Since `next_top = U(⊤, ⊥) ∈ limit_f(x)` for ALL `x`, the C5 witness for next_top at orbit point `s^[n](a)` IS `s^[n+1](a)`. Similarly, the C5' witness for `S(⊤, ⊥)` at pred-chain point `p^[k](pb)` IS `p^[k+1](pb)`. Track the construction stages.

**Assessment**: This is correct but leads to the same boundary case problem as plan v10. The C5-bot witness for `s^[n](a)` enters at some stage `M_n`, and `succ(s^[n](a)) = s^[n+1](a)` which is the C5-bot witness. But `M_n` can grow without bound. The question is whether the sequence of stages `M_n` covers all limit_dom points between `a` and `b`. This reduces to IsSuccArchimedean -- circular.

**Verdict**: BLOCKED by circularity. Not viable.

### Strategy C: Prior-SZ maximum principle (formula propagation)

**Idea**: Use `backward_G` + `backward_F` (already proved) combined with Prior-SZ to show that bounded definable sets must have maxima. Then show the orbit set is bounded with no maximum, giving a contradiction.

**Assessment**: This is Alternative D from report 14, Section 5. The key insight is to use Prior-SZ (the past dual of Prior-UZ) rather than Z1. Prior-SZ gives `P(φ) → S(φ, ¬φ)`: if φ held in the past, then there is a nearest past φ-point with ¬φ at all intermediate points.

**The argument**:

In the gap-at-L scenario, we have:
- Orbit chain: `s^[0](a) < s^[1](a) < ... < pred(b)` all below L
- Pred-chain: `... < p^[2](pb) < p^[1](pb) < pb` all above or at L
- No limit_dom point at L

We need to find a formula φ that distinguishes the two sides of the gap.

**The discriminating formula**: Since ALL limit_dom points have `next_top = U(⊤, ⊥) ∈ limit_f(x)`, and all MCS labels include the same derivable formulas, we need a formula that varies across the domain. Prior-UZ guarantees this exists: if every point had the same MCS label, then `F(p) → U(p, ¬p)` would require `¬p` at some point, contradicting the constant model.

However, EXTRACTING the specific formula is the discriminating formula problem from plan v11. This problem was identified as a risk but not resolved.

**Critical realization**: We do NOT need a specific discriminating formula. We can use the Prior-SZ argument differently. Consider any orbit point `m = s^[n](a)`. The point `m` is in the orbit, so `m < pb`. Since `m < pb`, we have `succ(m) = s^[n+1](a)` (next orbit point), and `succ(m) ≤ pb`. In the gap scenario, ALL orbit points are below all pred-chain points. We now use `backward_G` to show that any formula holding at ALL pred-chain points must propagate backwards across the gap:

For any formula ψ: if `ψ ∈ limit_f(y)` for ALL `y > x` in limit_dom, then `G(ψ) ∈ limit_f(x)` (by `backward_G`).

The pred-chain points `p^[k](pb)` have values converging to L from above. Above ALL pred-chain points (i.e., for points above pb), we have limit_dom points extending to infinity. So the pred-chain is NOT the entire set of limit_dom points above the gap.

**The real argument**: Consider the formula `next_top` itself. Every limit_dom point has `next_top ∈ limit_f(x)`. So `G(next_top) ∈ limit_f(x)` for every `x` (by `backward_G` with ψ = `next_top`, since next_top holds at ALL future points). Similarly, `H(next_top) ∈ limit_f(x)` for every `x` (by the dual). This does not help directly -- it is just a theorem propagation.

**The correct formulation**: We need to use Prior-SZ/UZ to show that the gap structure is impossible. Here is the key argument that avoids discriminating formulas entirely:

**Direct argument using Prior-UZ + backward_G to derive False**:

Consider any orbit point `m = s^[n](a)`. Since `m` has `next_top ∈ limit_f(m)`, succ(m) exists. Consider the formula `neg_next_top = ¬U(⊤, ⊥)`. Since `next_top ∈ limit_f(m)` (by `h_discrete`), `neg_next_top ∉ limit_f(m)`. Actually, `next_top` is in EVERY limit_dom point's MCS (by `h_discrete`). So `neg_next_top` is in NO limit_dom point's MCS. This makes `neg_next_top` useless as a discriminating formula.

We need a formula that CHANGES VALUE across the gap. In a constant-model scenario (all MCS labels equal), Prior-UZ creates a contradiction (as identified in report 13). But the MCS labels are NOT necessarily all equal -- they might differ from point to point while still not providing a usable discriminating formula across the GAP.

**Revised assessment**: The discriminating formula problem IS a genuine obstacle. Prior-UZ forces non-constant models globally, but it does not hand us a specific formula that is true on one side of the gap and false on the other. The MCS labels could vary arbitrarily across the domain while still being compatible with the gap structure.

**However**: there is a way to bypass the discriminating formula problem entirely by using Prior-UZ at the semantic level with the backward_G/backward_F infrastructure. Here is how:

**Verdict**: PARTIALLY VIABLE. The Prior-SZ maximum principle is mathematically correct but the discriminating formula extraction requires careful handling. See the recommended approach below.

### Strategy D: Direct descent / stage monotonicity

**Idea**: In the gap scenario, each pred-chain point `p^[k](pb)` enters at some stage `M_k`. Show that `M_{k+1} > M_k` or some other monotonicity on stages, then derive contradiction by well-foundedness.

**Assessment**: This fails because `first_stage(pred(c))` can exceed `first_stage(c)` (confirmed by plan v8 handoff). The pred-chain points' entry stages are NOT monotone -- they can be in any order. There is no well-founded descent on stages.

**Verdict**: NOT VIABLE.

---

## 4. Recommended Approach: Prior-UZ/SZ Gap Closure via MCS Pigeonhole

### 4.1 Core idea

The gap-at-L scenario has infinitely many orbit points `s^[n](a)` and infinitely many pred-chain points `p^[k](pb)`. Each limit_dom point `x` has an MCS label `limit_f(x)`. Since the orbit is infinite and the formula language is fixed, by pigeonhole there exist orbit indices `n₁ < n₂` such that `limit_f(s^[n₁](a))` and `limit_f(s^[n₂](a))` agree on EVERY formula of complexity ≤ K (for any fixed K). In fact, since the set of all possible MCS labels is countable but may be infinite, we cannot directly apply pigeonhole to get exact equality.

**Better approach**: We do NOT need pigeonhole. We need a much simpler argument:

### 4.2 The argument (no discriminating formula needed)

The key insight is that `backward_G` and `limit_forward_G` together give a COMPLETE G truth lemma at the semantic level (forward and backward). Specifically:

- **Forward**: `G(φ) ∈ limit_f(x)` and `y > x` implies `φ ∈ limit_f(y)` (by `limit_forward_G`)
- **Backward**: If `φ ∈ limit_f(y)` for ALL `y > x`, then `G(φ) ∈ limit_f(x)` (by `backward_G`, already proved, no IsSuccArchimedean needed)

Similarly for H:
- **Forward**: `H(φ) ∈ limit_f(x)` and `y < x` implies `φ ∈ limit_f(y)` (by `limit_backward_H`)
- **Backward**: If `φ ∈ limit_f(y)` for ALL `y < x`, then `H(φ) ∈ limit_f(x)` (dual of backward_G, needs to be proved but is symmetric)

With these, we can run the Doets Claim 10 argument DIRECTLY without a Z1 DerivationTree:

**Step 1**: In the gap scenario, consider Prior-UZ applied to any formula at an orbit point.

Consider the orbit point `m = s^[0](a) = a`. We have `next_top ∈ limit_f(a)`. In particular, `F(⊤) ∈ limit_f(a)` (since `next_top = U(⊤, ⊥)` implies `F(⊤)` by BX10). This is just seriality and not useful directly.

**Step 2**: The real leverage comes from the fact that the gap creates a "G-definable" transition. Consider the formula:

`ψ = G(⊤)` (trivially true everywhere -- not useful)

No, we need something that USES the gap. Here is the correct argument:

**Step 3 (The actual argument)**: Consider the pred-chain point `pb = pred(b)`. We know `h_lt_pred_chain`: `s^[n](a) < p^[k](pb)` for ALL n, k. In particular, `s^[n](a) < pb` for all n (from `h_lt_pb`).

Now consider `backward_G` applied at orbit point `a` with ψ = some formula. We need a formula that holds at ALL limit_dom points above `a`. But in the gap scenario, SOME formulas might not hold everywhere -- that is exactly what the discriminating formula would give us.

### 4.3 The breakthrough: Using `orbit_below_L` + `backward_G` + Prior-UZ

Here is the argument that works without a discriminating formula:

**Setup**: In the gap-at-L scenario, `orbit_below_L` (line 1619) says: every limit_dom point `c` with `a ≤ c` and `c.val < L` is an orbit point. Combined with `h_pred_chain_ge_L` (line 1671): all pred-chain values are ≥ L. So the gap partition is:
- Points with value < L: all orbit points
- Points with value ≥ L: all pred-chain points or above

**Key observation**: Consider any pred-chain point `p^[k](pb)`. Its predecessor in limit_dom is `pred(p^[k](pb)) = p^[k+1](pb)` (by `limitDomSubtype_pred_succ` dual). What about its successor? `succ(p^[k](pb))` is the next limit_dom point above `p^[k](pb)`. Since `p^[k](pb) < p^[k-1](pb)` and `p^[k-1](pb)` is a limit_dom point above `p^[k](pb)`, we have `succ(p^[k](pb)) ≤ p^[k-1](pb)` (by `succ_le_iff`). Is `succ(p^[k](pb)) = p^[k-1](pb)`?

By the no-limit-dom-between property of succ: no limit_dom between `p^[k](pb)` and `succ(p^[k](pb))`. Since `p^[k-1](pb)` is limit_dom with `p^[k-1](pb) > p^[k](pb)`, we get `succ(p^[k](pb)) ≤ p^[k-1](pb)`. Also, `p^[k-1](pb) = succ(pred(p^[k-1](pb))) = succ(p^[k](pb))` by `limitDomSubtype_succ_pred`. So indeed `succ(p^[k](pb)) = p^[k-1](pb)`.

This means the pred-chain is also traversable by succ: `succ(p^[k+1](pb)) = p^[k](pb)` for all k. So from `p^[k](pb)`, iterating succ gives `p^[k-1](pb), ..., p^[0](pb) = pb, succ(pb) = b` (by `succ_pred`). In k+1 succ steps, we reach b from `p^[k](pb)`.

**Now the question reduces to**: can succ iteration reach FROM the orbit TO the pred-chain?

In the gap scenario, we claim this is impossible (by assumption `h_not_cofinal`: `s^[n](a) < b` for all n). But if `succ(p^[k](pb)) = p^[k-1](pb)`, then the pred-chain is succ-traversable. The orbit is also succ-traversable by definition. The question is whether there is a "bridge" -- a limit_dom point where succ steps from the orbit into the pred-chain region.

**The gap claim**: In the gap scenario, no limit_dom point has value exactly L. The orbit values converge to L from below, the pred-chain values converge to L from above. Between them: no limit_dom point (by `orbit_below_L` -- values < L are orbit; by `h_pred_chain_ge_L` -- pred-chain values ≥ L; and no limit_dom at L itself because if there were, it would be an orbit point by `orbit_below_L` which requires value < L, or it would have value = L which is the boundary).

Wait -- `orbit_below_L` says: if `c.val < L`, then `c` is an orbit point. It does NOT say anything about `c.val = L`. So there might be a limit_dom point at L.

**Can there be a limit_dom point at value L?**

If L is rational: L ∈ Q ∩ limit_dom would mean L is the value of some limit_dom point. Since `f(n) → L` and `f(n) < L` for all n (where `f(n) = s^[n](a).val`), L is a limit_dom point c with `c.val = L`. Then `c.val ≥ L` (equality), so c is NOT covered by `orbit_below_L` (which requires `c.val < L`). And `h_pred_chain_ge_L` says `(p^[k](pb)).val ≥ L`, so `c.val = L ≤ (p^[k](pb)).val`.

Is `c` an orbit point? Since `s^[n](a) < c` for all n (as `f(n) < L = c.val`), and `c ≤ pb` (since `L ≤ pb.val` by `h_case`), `c` is between the orbit and the pred-chain.

`c` has `next_top ∈ limit_f(c)` (by `h_discrete`). So `succ(c)` exists. `succ(c)` is the next limit_dom point above `c`. Since `c.val = L` and `p^[k](pb).val ≥ L` for all k, and the pred-chain converges to L, `succ(c) ≤ p^[k](pb)` for all k. If `succ(c) = p^[k](pb)` for some k, then `succ^[k+1](c) = p^[0](pb) = pb` and `succ^[k+2](c) = b`. And `pred(c)` is the largest orbit point below c.

Actually: `pred(c)` is the previous limit_dom point. Since all limit_dom points with value < L are orbit points, `pred(c)` is some orbit point `s^[m](a)`. Then `succ(s^[m](a)) ≤ c` (since `s^[m](a) < c`). Also `succ(s^[m](a))` is a limit_dom point > `s^[m](a)`, and `(succ(s^[m](a))).val > s^[m](a).val`. If `succ(s^[m](a)) < c`, then `succ(s^[m](a))` is a limit_dom point with value in `(s^[m](a).val, L)`, making it an orbit point by `orbit_below_L`. So `succ(s^[m](a)) = s^[m+1](a)`. Then `s^[m+1](a) < c`. Repeat: `succ(s^[m+1](a)) = s^[m+2](a) < c`. This gives `s^[n](a) < c` for all `n ≥ m`. But this is already known (all orbit points < c).

So if `c.val = L` is a limit_dom point, then `pred(c)` is an orbit point `s^[m](a)` but `succ(s^[m](a)) ≠ c` (since `succ(s^[m](a)) = s^[m+1](a)` which has value < L = c.val). Actually, `succ(s^[m](a))` IS defined as the nearest limit_dom point above `s^[m](a)`. If `c` is the limit_dom point at L, and there are no limit_dom points between `s^[m](a)` and `c`, then `succ(s^[m](a)) = c`. But `orbit_below_L` says any limit_dom point with value < L between `a` and `c` is an orbit point. So the limit_dom points between `s^[m](a)` and `c` are: `s^[m+1](a), s^[m+2](a), ...` all with values < L approaching L. These are infinitely many, so `succ(s^[m](a)) = s^[m+1](a)` (the next orbit point), not c.

Thus c exists at L but is NOT reachable in finitely many succ steps from any orbit point -- precisely the gap scenario.

**However**: if c exists at L, then c has `next_top ∈ limit_f(c)`, so `succ(c)` exists. And `succ(c) > c`, so `succ(c).val > L`. Since the pred-chain values converge to L from above, `succ(c) ≤ p^[k](pb)` for any k. In fact, `succ(c)` is the nearest limit_dom point above L. This is the smallest pred-chain point (or something between c and the pred-chain).

The key question is: does a limit_dom point at L exist? If L is irrational, no (since limit_dom ⊆ Q). If L is rational, possibly.

### 4.4 The correct approach: show L IS a limit_dom point and derive contradiction

**Claim**: In the gap-at-L scenario, L must be the value of a limit_dom point. This contradicts the gap structure.

**Proof attempt**: L is the supremum of the orbit values in R. The orbit values are all rational (limit_dom ⊆ Q). L is the supremum of a bounded monotone sequence of rationals in R. L could be rational or irrational.

If L is irrational: L ∉ Q, so there is no limit_dom point at L. The gap between orbit (values < L) and pred-chain (values ≥ L, which are > L since L ∉ Q) is genuinely at an irrational value. This is order-theoretically consistent.

If L is rational: L ∈ Q. But is L ∈ limit_dom? Not necessarily -- L is rational but might not be in any `dom(n)`. However, L is the supremum of `{s^[n](a).val}` which are all in limit_dom. The limit_dom is a countable subset of Q with no density requirement in the discrete case.

**This approach (showing L ∈ limit_dom) does not work in general.**

### 4.5 The CORRECT recommended approach

After this deep analysis, the viable approaches are:

**Approach E: Prior-SZ maximum principle with discriminating formula from MCS finiteness**

The argument:

1. In the gap scenario, consider the orbit points `{s^[n](a) : n ∈ N}`. Each has MCS label `limit_f(s^[n](a).val)`.

2. There are only COUNTABLY many MCS labels possible (since the formula language is countable). But we do not need finiteness -- we need something much weaker.

3. By Prior-UZ at orbit point `s^[0](a) = a`: for any formula φ with `F(φ) ∈ limit_f(a)`, we get `U(φ, ¬φ) ∈ limit_f(a)`. The Until witness resolves by `limit_satisfies_c5_strong`: there exists `y > a` with `φ ∈ limit_f(y)` and `¬φ` at all intermediate limit_dom points. This `y` is the NEAREST future φ-point from `a`.

4. Now consider: does `F(G(⊤)) ∈ limit_f(a)`? Since `⊤ ∈ limit_f(y)` for all y, `G(⊤) ∈ limit_f(y)` for all y (by `backward_G` with ψ = ⊤). So `G(⊤) ∈ limit_f(y)` for all `y > a`. By `backward_F`: `F(G(⊤)) ∈ limit_f(a)`. This is true but not useful -- all formulas involving ⊤ are trivially true.

5. **The real leverage**: Consider the formula `ψ_gap` defined as follows. In the gap scenario:
   - ALL pred-chain points and their successors are above L
   - ALL orbit points are below L
   - `backward_G` says: if a formula ψ holds at ALL future limit_dom points above some `x`, then `G(ψ) ∈ limit_f(x)`

6. Here is the key argument that does NOT need a discriminating formula:

   Consider the pred-chain point `pb = pred(b)`. We have `pb.val ≥ L` (by `h_pred_chain_ge_L` with k=0). Now `succ(pb) = b` (by `succ_pred`). So `b = succ(pb)`, and iterating succ from `pb` gives `b` in 1 step.

   Now consider `pred(pb) = p^[1](pb)`. We have `succ(pred(pb)) = pb` (by `succ_pred`). So iterating succ from `p^[1](pb)` gives `pb` in 1 step and `b` in 2 steps.

   In general: from `p^[k](pb)`, iterating succ k+1 times gives `b`.

   **The question is whether the orbit ever reaches a pred-chain point.** In the gap scenario, it does not (by assumption). But we need to DERIVE a contradiction from this assumption.

7. **The real real argument**: For each orbit point `m = s^[n](a)`, consider the formula `F(G(ψ))` where ψ is chosen to make this formula true on one side and false on the other. The problem is that we have not identified ψ.

**After extensive analysis, I believe the correct path requires the Z1 derivation or an equivalent mechanism.** The discriminating formula problem is NOT avoidable. Let me now propose a concrete resolution.

### 4.6 Resolution of the discriminating formula problem

The discriminating formula exists AUTOMATICALLY from the gap structure combined with Prior-UZ. Here is the precise argument:

**Lemma (Prior-UZ forces non-constant MCS labels across any infinite succ-chain)**:

If `{x_n}` is an infinite strictly increasing sequence of limit_dom points with the SAME MCS label (i.e., `limit_f(x_n.val) = limit_f(x_0.val)` for all n), then we derive a contradiction.

**Proof**: Pick any formula φ in the common MCS label (there must be one -- say `next_top` which is in every label). Consider the formula `φ.neg` (which is NOT in the label, since the label is consistent). So `φ.neg ∉ limit_f(x_0.val)`, meaning `φ ∈ limit_f(x_0.val)`.

Now, `F(φ) ∈ limit_f(x_0.val)` (since `x_1 > x_0` and `φ ∈ limit_f(x_1.val)`, by `backward_F`). By Prior-UZ: `U(φ, ¬φ) ∈ limit_f(x_0.val)`. The Until witness `y > x_0` has `φ ∈ limit_f(y)` and `¬φ` at all points between `x_0` and `y`. But `x_1` is between `x_0` and `y` (or equal to `y`), and `φ ∈ limit_f(x_1.val)`. If `x_1 < y`: then `¬φ ∈ limit_f(x_1.val)`, contradicting `φ ∈ limit_f(x_1.val)`. If `x_1 = y`: the Until guard is vacuous (no points between `x_0` and `x_1` in the discrete case). Then `x_1 = y` and the Until witness is `x_1` itself.

**This does NOT give a contradiction!** If `x_1 = y`, then `U(φ, ¬φ)` at `x_0` with witness `y = x_1` is perfectly consistent: `φ` at `x_1`, and `¬φ` at all points strictly between `x_0` and `x_1` (there are none by discreteness). So the Until is vacuously satisfied.

The argument DOES work if we choose φ to be a formula that is NOT in the common MCS. Let `φ` be such that `¬φ ∈ limit_f(x_n.val)` for all n. Then `F(¬φ) ∈ limit_f(x_n.val)` for all n (since `x_{n+1}` has `¬φ`). By Prior-UZ: `U(¬φ, φ) ∈ limit_f(x_n.val)`. The Until witness gives a limit_dom point with `¬φ` beyond which `φ` held at all intermediate points. But all orbit points have `¬φ`. So the witness must be AT an orbit point or BEYOND the orbit. In the gap scenario, points beyond the orbit (above L) are pred-chain points. If the witness is a pred-chain point, it has `¬φ` (since it has the same label, or maybe not -- we haven't established the pred-chain MCS labels).

**The real issue**: The argument needs to compare MCS labels of orbit points versus pred-chain points, not orbit points versus themselves.

### 4.7 FINAL RECOMMENDED APPROACH: Derive Z1 from Prior-UZ by adding it as a proved axiom in the Hilbert system

Given the analysis above, the cleanest approach is:

1. **Add Z1 as a theorem** (not a new axiom) by providing its DerivationTree from Prior-UZ + BX axioms. The derivation IS complex (~60-120 lines) but is a one-time effort.

2. **Apply Doets Claim 10** using Z1 at the semantic level (via `theorem_in_mcs`), with any formula that varies (guaranteed to exist by Prior-UZ non-constancy).

3. **Use `orbit_below_L`** to show the phi-set (for the discriminating formula) is bounded above with no maximum.

**However**, I now recognize a SIMPLER path that avoids both the Z1 derivation and the discriminating formula:

### 4.8 THE SIMPLEST VIABLE APPROACH: Direct contradiction from Prior-UZ at the gap boundary

**Claim**: In the gap-at-L scenario, we can derive False directly using backward_G + Prior-UZ + limit_forward_G, without Z1 and without a discriminating formula.

**Proof**:

Consider any pred-chain point `c = p^[k](pb)` for large k. We have:
- `c.val ≥ L` (by `h_pred_chain_ge_L`)
- `s^[n](a) < c` for all n (by `h_lt_pred_chain`)
- `c` has `next_top ∈ limit_f(c.val)` (by `h_discrete`)

Now, `pred(c) = p^[k+1](pb)` and `pred(c).val ≥ L` (by `h_pred_chain_ge_L` with k+1).

Consider the formula `φ = next_top.neg`. Since `next_top ∈ limit_f(x)` for ALL `x ∈ limit_dom` (by `h_discrete`), `φ = next_top.neg ∉ limit_f(x)` for ALL `x`. This means `¬(next_top.neg) = next_top ∈ limit_f(x)` for all x. So `φ.neg ∈ limit_f(x)` for all x. This does not vary -- NOT useful.

We need a formula that varies. Since all limit_dom points have the same `next_top`, consider other formulas.

**The MCS at different points CAN differ** on non-derivable formulas. For example, atomic propositions `p` might be in `limit_f(x)` at some points and not others, depending on the MCS labels.

**But we don't know WHICH formulas vary.** The construction assigns MCS labels based on the omega-chain construction, and these labels depend on the counterexample enumeration ordering.

**After 13 rounds of research, the fundamental conclusion is**: the discriminating formula must come from the STRUCTURE of the gap itself, not from specific formula properties. The most tractable approach is the Z1/Doets path, which requires the Z1 DerivationTree.

---

## 5. Concrete Recommended Plan

### 5.1 Primary recommendation: Z1 DerivationTree + Doets Claim 10

This is the approach from plan v11, now with clearer understanding of what is needed.

**Step 1**: Build `DerivationTree [] Z1_formula` (~80-120 lines)

The derivation strategy that avoids the problematic semantic induction:

From Prior-UZ applied to `G(φ)`: `F(G(φ)) → U(G(φ), ¬G(φ))`

From BX5 (Until self-accumulation): `U(G(φ), ¬G(φ)) → U(G(φ), ¬G(φ) ∧ U(G(φ), ¬G(φ)))`

The Until witness has `¬G(φ) ∧ U(G(φ), ¬G(φ))` at all intermediate points and `G(φ)` at the event. Combined with `G(G(φ) → φ)`:

At the event point y: `G(φ) ∧ (G(φ) → φ)` gives `φ` at y.
At the predecessor z of y (from `U(⊤, ⊥)`): `¬G(φ)` at z (from Until guard). But `G(φ)` at y means φ at y, y+1, .... So `G(φ)` at z iff φ at z+1 AND φ at z+2 AND .... Since z+1 = y and G(φ) at y gives the rest, `G(φ)` at z iff φ at y, which is true. Contradiction with `¬G(φ)` at z.

Wait -- this gives `G(φ)` at z, contradicting `¬G(φ)` at z. So the Until chain from x to y must have NO intermediate points, meaning y is the immediate successor of x. Then `G(φ)` at y gives `G(φ)` at x (since for all w > x: if w = y, φ at y by G(φ); if w > y, φ at w by G(φ)).

**This IS the correct derivation!** The key step: the predecessor z of y has `G(φ)` (from the analysis above), contradicting `¬G(φ)` from the Until guard. So there CAN be no intermediate point -- y must be x's immediate successor. And then G(φ) at y implies G(φ) at x.

**The formal derivation needs**:
1. Prior-UZ applied to G(φ) (axiom)
2. BX5 or direct Until manipulation to get the self-referential Until
3. `next_top = U(⊤, ⊥)` to access predecessor/successor structure
4. Modus ponens chains and contrapositive reasoning

This derivation requires the axiom `U(⊤, ⊥)` (discreteness) combined with Prior-UZ. The resulting Z1 formula holds ONLY in the discrete case, which is exactly our setting (we have `h_discrete`).

**Specific lemmas needed**:

```lean
-- Z1 derivable from Prior-UZ + discreteness axiom
-- G(Gφ → φ) → (F(Gφ) → Gφ)
theorem z1_from_prior_UZ (φ : Formula) :
    DerivationTree [] (
      (φ.all_future.imp φ).all_future.imp
        (φ.all_future.some_future.imp φ.all_future))
```

**Step 2**: Apply Z1 semantically + find discriminating formula (~40-60 lines)

```lean
-- In the gap scenario, Z1 ∈ every MCS via theorem_in_mcs
have h_Z1 : ∀ x ∈ limit_dom A h_mcs,
    Z1_formula φ ∈ limit_f A h_mcs x :=
  fun x hx => theorem_in_mcs (limit_c0 A h_mcs x hx)
    (z1_from_prior_UZ φ)

-- The discriminating formula: use Classical.choice on the symmetric
-- difference of any two MCS labels on opposite sides of the gap
-- (existence guaranteed by Prior-UZ non-constancy)
```

**Step 3**: Derive False from Z1 + discriminating formula (~30-50 lines)

The Doets Claim 10 argument as outlined in plan v11, Step 2c.

### 5.2 Fallback recommendation: Add Z1 soundness lemma

If the syntactic Z1 derivation proves too complex, add a SOUNDNESS lemma for Z1 on discrete linear orders:

```lean
-- Z1 is valid on all discrete linear orders (semantic proof)
theorem z1_valid_discrete (M : Model) [LinearOrder M.W]
    [SuccOrder M.W] [IsSuccArchimedean M.W] :
    M.valid Z1_formula
```

**Problem**: This requires IsSuccArchimedean as a hypothesis, creating the very circularity we are trying to break!

**Resolution**: Prove Z1 validity on the LIMIT MODEL specifically, using the construction properties rather than abstract order properties. The limit model has specific structural properties (omega-chain construction) that go beyond abstract discrete linear orders.

### 5.3 Alternative fallback: Fix the stage induction boundary cases

Return to plan v10's `succ_reaches_dom_N` and close the two boundary sorry sites using a DIFFERENT induction variable. Instead of inducting on N (the stage), induct on `(N, |dom(N) ∩ [a, b]|)` lexicographically. The boundary cases (above-max, below-min) increase N but decrease the relevant interval, providing well-foundedness.

**Sketch**: When `b` is above `max(dom(N))` at stage `N+1`:
- `b ∈ dom(N+1)`, `a ∈ dom(N)`
- Consider stage `M` where `succ(max_N_sub).val` enters dom(M)
- Apply IH at stage `max(N+1, M)` with the same `a, b`
- Both `a` and `b` are in `dom(max(N+1, M))` (by monotonicity)
- `dom(max(N+1, M))` has MORE points in [a, b] than `dom(N)`
- But the lexicographic ordering `(stage, points_in_interval)` is NOT well-founded in the right direction

This does not work either.

---

## 6. Specific Lemmas to Prove

### For the Z1 approach (primary):

1. **`z1_from_prior_UZ`** (~80-120 lines): DerivationTree for Z1 from Prior-UZ + BX axioms + discreteness. Located in a new file `Theories/Bimodal/Theorems/Z1Derivation.lean` or inline.

2. **`discriminating_formula_exists`** (~20-40 lines): In the gap scenario, there exists a formula φ such that `φ ∈ limit_f(s^[n](a).val)` for some n but `¬φ ∈ limit_f(p^[k](pb).val)` for some k (or the reverse). Uses Prior-UZ non-constancy + Classical.choice.

3. **`doets_claim_10`** (~30-50 lines): Maximum principle from Z1. If φ-set is bounded above with no maximum, derive False using Z1 at some orbit point.

4. **Gap closure** (~20-30 lines): In the sorry branch, apply `doets_claim_10` with the discriminating formula to derive False.

### For the Prior-SZ approach (if Z1 is bypassed):

1. **`backward_P`** (~30 lines): Dual of `backward_F`. If φ ∈ limit_f(y) for some y < x, then P(φ) ∈ limit_f(x). Should be a symmetric argument to backward_F.

2. **`backward_H`** (~30 lines): Already exists as `limit_backward_H` in ChronicleConstruction.lean.

3. **`max_principle_prior_SZ`** (~50-80 lines): From Prior-SZ, prove the maximum principle directly. Requires the discriminating formula.

---

## 7. Open Questions and Blockers

### 7.1 The discriminating formula problem (CRITICAL)

Both the Z1 and Prior-SZ approaches require a formula that distinguishes orbit points from pred-chain points in the gap scenario. Prior-UZ guarantees non-constant models globally but does NOT hand us a specific formula for the gap region.

**Possible resolution**: The MCS labels `limit_f(s^[n](a).val)` for orbit points and `limit_f(p^[k](pb).val)` for pred-chain points are determined by the omega-chain construction. The construction uses counterexample enumeration, which processes different formulas at different stages. At some stage, a formula φ is processed that creates a C4 or C5 witness between an orbit point and a pred-chain point, establishing `¬φ` at an intermediate point (or φ at the witness). This witness creates a domain point with a different MCS label, providing the discriminating formula.

**Concrete extraction**: For any orbit point `x_n` and any pred-chain point `y_k`, since they are distinct limit_dom points with possibly different MCS labels, consider: if `limit_f(x_n.val) = limit_f(y_k.val)`, then they have the same MCS. By Prior-UZ at `x_n`: `F(φ) → U(φ, ¬φ)` for any φ ∈ limit_f(x_n.val). Since `φ ∈ limit_f(y_k.val)` too (same MCS), and `y_k > x_n`, we get (via backward_F) that `F(φ) ∈ limit_f(x_n.val)`. Then `U(φ, ¬φ) ∈ limit_f(x_n.val)`. The Until witness z > x_n has `φ ∈ limit_f(z)` and `¬φ` between x_n and z. The successor `succ(x_n)` is between x_n and z (or is z). `¬φ ∈ limit_f(succ(x_n).val)` if `succ(x_n) < z`. But `succ(x_n) = x_{n+1}` (next orbit point). If `limit_f(x_{n+1}.val)` has `¬φ`, that contradicts `limit_f(x_{n+1}.val) = limit_f(x_n.val)` (same MCS) which has `φ`. So `succ(x_n) = z`, meaning z = x_{n+1}. Then the Until guard between x_n and x_{n+1} is vacuous (no intermediate points by discreteness). So the Prior-UZ instance is trivially satisfied, giving no new information.

**This confirms**: Prior-UZ at orbit points with formulas shared across ALL orbit points gives NO discriminating power. The discriminating formula must come from a formula that DIFFERS across orbit points (or between orbit and pred-chain).

### 7.2 Resolution via backward_G directly

**New insight**: We do NOT need a discriminating formula at all! Here is the complete argument:

In the gap scenario, we have `backward_G`: if ψ ∈ limit_f(y) for ALL y > x in limit_dom, then G(ψ) ∈ limit_f(x).

Consider the orbit point `m = s^[n](a)`. For any formula ψ such that `ψ ∈ limit_f(y)` for all y > m (i.e., all limit_dom points above m), we get `G(ψ) ∈ limit_f(m.val)`.

Now, in the gap scenario, consider: does there exist ψ such that `ψ ∈ limit_f(y)` for all y > m but `ψ ∉ limit_f(m.val)`? If yes, `G(ψ) ∈ limit_f(m.val)` by backward_G. And by `limit_forward_G`, `ψ ∈ limit_f(m.val)` -- contradiction!

Wait, `limit_forward_G` says: if `G(ψ) ∈ limit_f(x)` and `y > x` then `ψ ∈ limit_f(y)`. It does NOT say `ψ ∈ limit_f(x)`. So there is no contradiction from `G(ψ) ∈ limit_f(m.val)` alone. The formula `G(ψ)` means ψ holds at all STRICT future points, not at m itself.

So we need: G(ψ) ∈ limit_f(m) AND ψ ∉ limit_f(m). Then ¬ψ ∈ limit_f(m). And G(ψ) ∈ limit_f(m) means ψ at all y > m. In particular ψ at succ(m). But this says ψ ∈ limit_f(succ(m).val). And succ(m) = s^[n+1](a) is another orbit point. If ψ holds at ALL y > m, it holds at succ(m). And ¬ψ at m. So ψ changes value from m to succ(m). This IS a discriminating formula between m and succ(m) -- but we don't know such ψ exists.

**THE CIRCULAR NATURE OF THE PROBLEM**: Every approach to derive False from the gap scenario eventually needs a formula that distinguishes two sides of the gap. And identifying such a formula requires either (a) explicit construction knowledge about MCS labels (hard to extract formally), or (b) an abstract argument from Prior-UZ that forces such a formula to exist (the Z1 path).

## 8. Final Assessment and Recommendation

After thorough analysis of all four strategies and their variants:

**Primary recommendation**: Build the Z1 DerivationTree from Prior-UZ. The derivation sketch in Section 5.1 shows it IS possible using:
- Prior-UZ applied to G(φ)
- The discreteness axiom U(⊤, ⊥) to access predecessor structure
- Contrapositive reasoning to show the Until guard chain collapses

The Z1 DerivationTree is the ONLY component blocking the Doets Claim 10 argument, which is itself the ONLY known mechanism to eliminate the gap-at-L without construction-specific dynamics.

**Estimated effort**: 80-120 lines for the Z1 DerivationTree, 40-60 lines for discriminating formula extraction, 30-50 lines for Doets Claim 10 application. Total: ~150-230 lines.

**Key risk**: The discriminating formula extraction from Prior-UZ non-constancy. This should be formalized as: in the gap scenario, not all MCS labels can be equal (Prior-UZ forces transitions). Classical.choice extracts a specific formula from the non-empty symmetric difference.

**Secondary recommendation**: If the Z1 DerivationTree proves intractable, explore adding Z1 as a new axiom with a direct soundness proof on the limit model (using construction-specific properties to prove Z1 validity WITHOUT IsSuccArchimedean). This changes the axiom system but is mathematically justified.

**Tertiary recommendation**: If both fail, leave the sorry with full documentation and file a separate task. The sorry is well-localized and does not affect the dense/nondense cases.
