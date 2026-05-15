# Teammate A Findings: succ_cofinal Primary Implementation Approach

**Task**: 153
**Session**: sess_1747338900_a1b2c3
**Date**: 2026-05-15
**Role**: Primary approach — rigorous literature-guided investigation

---

## Key Findings

### 1. The Sorry Is a Genuine Mathematical Gap, Not a Lean Technicality

The sorry at line 1885 of `ChronicleToCountermodel.lean` sits at the conclusion of an extensive proof-by-contradiction setup. The proof has correctly established:

- The orbit `{s^[n](a)}` converges in R to a limit L with L <= pred(b).val
- The pred-chain `{p^[k](pb)}` is strictly decreasing with all values >= L
- `orbit_below_L`: every limit_dom point c with a <= c and c.val < L is a succ-iterate of a
- `h_lt_pred_chain`: all orbit points < all pred-chain points
- `backward_G`, `backward_F`, `_backward_P`: truth propagation already proved
- `z1_in_mcs`: Z1 is in every MCS

The existing commentary (lines 1800-1884) is accurate: the gap scenario (orbit converging from below, pred-chain descending from above, gap at L) is self-consistent at the order-theoretic level. The contradiction must come from the temporal logic.

### 2. The Prior-UZ Approach Is the Most Viable Path

The Doets maximum principle (Doets 1987 Claim 10, p.113-115) uses a closely related argument. But the **direct Reynolds (1994) approach** via Prior-UZ is more tractable in this formalization context.

**Prior-UZ** (Axiom.prior_UZ, line 357-358 of Axioms.lean) states:
```
F(φ) → U(φ, ¬φ)
```
This says: if φ holds at some future time, there is a **nearest** future time where φ holds (¬φ at all intermediate points). This is the discrete/integer version of the maximum principle.

**Key insight from Reynolds (1994), Sections 6-7**: In a Prior structure (where all instances of Prior-UZ/SZ hold), there are no "definable gaps." Specifically, for any definable property R (one expressible by a temporal formula), if R holds "up to a gap" (i.e., holds for a while then becomes false), Prior-UZ forces a last point where R holds. The gap elimination argument shows that the succ-orbit / pred-chain gap scenario contradicts Prior-UZ applied to a suitably chosen formula.

### 3. The Discriminating Formula: A Concrete Proof Sketch

In the gap scenario (second branch, L <= pred(b).val), consider the formula:

```
φ := next_top  (= U(⊤, ⊥))
```

Every limit_dom point satisfies `next_top ∈ limit_f(x)` by `h_discrete`. So `φ` is universally present — this is not a discriminating formula. We need a formula that differs between the orbit and points above the gap.

**Better approach**: Use the formula that is true at points of the pred-chain and false at orbit points. Since `orbit_below_L` gives us control over points below L, we need:

```
ψ := formula characterizing "being above the gap"
```

But in the constant-MCS case, no such ψ exists. This is the fundamental obstacle.

### 4. Why the Constant MCS Case Requires a Different Strategy

In the constant-MCS scenario (all limit_f(x) = A for all x in limit_dom):

- Z1 = `G(Gφ→φ) → (FGφ→Gφ)` is trivially satisfied: since Gφ iff φ ∈ A, both Gφ and Gφ→φ have uniform truth values across all points
- Prior-UZ = `F(φ) → U(φ,¬φ)`: if F(φ) holds (φ ∈ A), then U(φ,¬φ) must hold. But U(φ,¬φ) means "there is a nearest future time where φ holds, with ¬φ in between." Since ¬φ ∉ A = limit_f(x) for any x, U(φ,¬φ) with guard ¬φ fails if φ ∈ A (since the guard must hold at intermediate points, but ¬φ is not in A at any intermediate limit_dom point)
- Thus Prior-UZ gives: F(φ) → U(φ,¬φ). If φ ∈ A, then F(φ) ∈ A (by some MCS reasoning), so U(φ,¬φ) ∈ A. But U(φ,¬φ) in limit_f(x) = A requires a witness y > x with φ ∈ limit_f(y) = A (yes, always) and ¬φ ∈ limit_f(z) = A for all z between (impossible since ¬φ ∉ A). Contradiction!

Wait — this argument shows that `U(φ,¬φ)` CANNOT be in A if φ ∈ A (since the guard ¬φ must hold at intermediate points but ¬φ ∉ A). But Prior-UZ says F(φ) → U(φ,¬φ). If F(φ) ∈ A and U(φ,¬φ) must also be in A (by implication and MCS closure), then we need U(φ,¬φ) in A. This forces: there exists y > x in limit_dom with φ ∈ limit_f(y) AND ¬φ ∈ limit_f(z) for all z between x and y in limit_dom. But if limit_f is constant = A, then ¬φ ∉ limit_f(z) = A for any z with φ ∈ A. This is a contradiction IF φ ∈ A and F(φ) ∈ A simultaneously.

In the constant MCS case with next_top ∈ A: F(φ) ∈ A for φ = next_top (since next_top ∈ A and there are always future points). Actually F(next_top) = some_future(next_top). Does next_top ∈ A imply F(next_top) ∈ A? Not directly — F(φ) = some_future(φ) is a separate formula from φ. However, seriality (serial_future) gives F(⊤) ∈ A, and from next_top ∈ A and G-propagation... actually this needs careful analysis.

### 5. The Prior-UZ Argument Against the Constant MCS Case

**Claim**: In the constant MCS case with next_top ∈ A, we can derive a contradiction using Prior-UZ.

**Argument**:
1. `next_top = U(⊤, ⊥)` is in A (by h_discrete and limit_f(0) = A)
2. `F(next_top) = some_future(next_top)`: by seriality, there exists y > 0 in limit_dom, and `next_top ∈ limit_f(y) = A`. So `F(next_top) ∈ limit_f(0) = A` (by `backward_F` already available in scope)
3. By Prior-UZ instantiated at φ = next_top: `F(next_top) → U(next_top, ¬next_top)` is in every MCS, so `U(next_top, ¬next_top) ∈ A`
4. `U(next_top, ¬next_top) ∈ limit_f(0) = A` means: there exists y > 0 in limit_dom with `next_top ∈ limit_f(y) = A` AND `¬next_top ∈ limit_f(z) = A` for all z in limit_dom with 0 < z < y
5. But `¬next_top = next_top.neg`. Since `next_top ∈ A` and A is maximal consistent, `¬next_top ∉ A`. But `limit_f(z) = A` in the constant case. So `¬next_top ∉ limit_f(z)` for any z.
6. This contradicts step 4: the guard `¬next_top` must be in limit_f(z) for the interval witnesses in `limit_satisfies_c5_strong` with `until_mem = U(next_top, ¬next_top) ∈ A`.

**Status**: This argument shows the constant MCS case produces a **contradiction from the C5 property itself** (without needing complex gap analysis). The limit domain satisfies C5 (by `limit_satisfies_c5_strong`), which means any Until formula in limit_f(x) has a witness. For `U(next_top, ¬next_top) ∈ limit_f(0) = A`, the C5 witness y > 0 must have `next_top ∈ limit_f(y) = A` ✓ AND `¬next_top ∈ limit_f(z) = A` for intermediate z — which fails since ¬next_top ∉ A. So the constant MCS case is impossible by C5.

### 6. The Full Gap Elimination Argument

Combining the above:

**Case split at the sorry**: The second branch has L <= pred(b).val, meaning the orbit approaches L from below and the pred-chain descends from above L.

**Sub-case A: Non-constant MCS on the orbit or pred-chain region**

If some formula φ varies between orbit and pred-chain points: the backward_G + Z1 argument applies (as described in report 01). The key is finding φ such that G(Gφ→φ) holds at orbit points but FG(φ) is blocked, or vice versa. This requires the non-constant hypothesis.

**Sub-case B: All limit_dom points in the orbit have identical MCS**

If all orbit points have the same MCS as a (= limit_f(0) = A), then all limit_dom points below L have MCS = A. But then the entire limit domain in [a.val, L) has constant MCS A. By the constant MCS argument (section 5 above), this contradicts C5 applied to U(next_top, ¬next_top) at any orbit point.

### 7. Why This Is Hard to Formalize

The argument above has a gap: "if all orbit points have the same MCS as a" is not directly available as a hypothesis. The sub-case split needs to be:

- Either ∃ orbit point x with limit_f(x) ≠ limit_f(a): find discriminating formula, use backward_G + Z1
- Or ∀ orbit points x: limit_f(x) = limit_f(a) = A

For the second sub-case, the C5 argument works cleanly IF limit_dom = orbit (all limit_dom between a and L are succ-iterates). But orbit_below_L says: limit_dom points c with a <= c and c.val < L are orbit points — so the orbit IS all of limit_dom below L. Good.

The C5 witness for U(next_top, ¬next_top) at orbit point s^[n](a) gives y > s^[n](a) in limit_dom with:
- next_top ∈ limit_f(y) [satisfied: next_top ∈ A]  
- ¬next_top ∈ limit_f(z) for all z in limit_dom with s^[n](a) < z < y

If y is also an orbit point (y.val < L), then limit_f(y) = A and ¬next_top ∉ A — but we need ¬next_top ∈ limit_f(z) for z between s^[n](a) and y, and succ(s^[n](a)) should be between them if the U-witness is not the immediate successor... Actually: C5_strong says the witness y for U(next_top,¬next_top) satisfies: next_top ∈ limit_f(y) AND ¬next_top ∈ limit_f(z) for all limit_dom z between x and y. If ¬next_top ∉ A = limit_f(z) for all orbit z, then no z can be between x and y. So y must be the immediate successor of x in limit_dom = succ(x).

So the U(next_top,¬next_top)-witness IS succ(x). This means:
- next_top ∈ limit_f(succ(x)) = A ✓
- The guard: no limit_dom points between x and succ(x) (by definition of immediate successor)

Wait — this means U(next_top,¬next_top) is satisfied by the immediate successor, which is consistent! No contradiction yet.

The real contradiction needs: ¬next_top must hold at intermediate points, but there are NO intermediate points (succ is immediate). So U(next_top,¬next_top) IS satisfied vacuously (no intermediate points). The C5 condition is met.

**This reveals that the C5/Prior-UZ approach does NOT give a contradiction in the constant MCS case when succ witnesses are immediate successors.** The prior argument in section 5 was incorrect.

### 8. The Fundamental Difficulty: Genuine Mathematical Gap in the Constant MCS Case

After deeper analysis, the constant MCS case with immediate successors throughout is **logically consistent** with all axioms including Prior-UZ, Z1, and C5. Here is why:

- Constant MCS A with next_top ∈ A
- All limit_dom points have MCS = A
- succ(x) is the unique limit_dom point immediately after x
- U(next_top,¬next_top): witness = succ(x), guard vacuously satisfied (no intermediate points)
- All F(φ), G(φ), etc. uniformly hold/fail based on whether φ ∈ A

The gap structure (orbit converging to L, pred-chain descending from above) IS consistent with constant MCS as long as:
1. Every orbit point has succ = next orbit point (all distinct from each other)
2. Every pred-chain point has pred = next pred-chain point
3. The "boundary" at L has no limit_dom points — but the gap has infinitely many limit_dom points on both sides (orbit and pred-chain), and NO limit_dom point AT L or in between

But wait — in the constant MCS case, succ(s^[n](a)) must be in limit_dom. If s^[n](a) is an orbit point with value approaching L, then succ(s^[n](a)) must also be in limit_dom. By h_lt_pred_chain, succ(s^[n](a)) < p^[k](pb) for all k. So succ(s^[n](a)).val <= L (since it's bounded by all pred-chain values, which are >= L). And succ(s^[n](a)) > s^[n](a). So succ(s^[n](a)).val is in (s^[n](a).val, L].

If succ(s^[n](a)).val = L: that would mean L ∈ Q ∩ limit_dom, meaning L is a rational limit_dom point. Then L = succ(s^[n](a)) for some n. But s^[n+1](a) = succ(s^[n](a)) = L. This contradicts "no orbit point reaches b" since b > L implies b is unreachable... wait, actually this shows s^[n+1](a).val = L < b.val, so the orbit reaches L but still doesn't reach b.

If succ(s^[n](a)).val < L for all n: this means every orbit point's succ is ALSO an orbit point (value < L). The orbit is closed under succ. The orbit is a copy of ω (natural numbers) ordered by succ. Similarly the pred-chain {p^[k](pb)} forms a separate copy. But the succ of any orbit point CANNOT be a pred-chain point (since that would contradict h_lt_pred_chain), and the pred of any pred-chain point CANNOT be an orbit point (by similar reasoning). So the limit domain has two disconnected ω/ω*-ordered components: the orbit (order type ω) and the pred-chain (order type ω*), with no limit_dom points in the gap.

**This is a Z+Z-like structure**: the limit_dom restricted to [a, ∞) has order type ω + ω*, with a gap in the middle. This contradicts IsSuccArchimedean (the pred-chain points are unreachable from the orbit).

**The difficulty**: This structure is NOT ruled out by C5, Z1, Prior-UZ, or backward_G/backward_F under constant MCS. The axioms are all vacuously/trivially satisfied.

### 9. The Doets Thesis: What It Actually Says

Doets (1987) Chapter 7 proves: the modified Löb axioms (Z1 and its past dual) ensure that any definable set with an upper bound has a maximum. This is **Claim 10** (p. 114):

"Suppose that φ is a formula over VAR_χ such that φ^N is non-empty and upward bounded. Then φ^N has a maximum."

This uses the Z1 axiom with p = ¬φ: if the set of φ-points is bounded above (there exists q with ¬φ at q and φ not beyond q), then there is a last φ-point (a maximum). But this requires the φ-set to be **non-empty**. In the constant MCS case with uniform φ-values, either φ is universal or empty — no bounded-above non-empty φ-set exists.

**Conclusion**: Doets' Claim 10 does not apply in the constant MCS case when the "gap" cannot be witnessed by any formula. The orbit and pred-chain form a gap that is **not definable** in the temporal language when MCS values are constant.

### 10. The Construction-Level Resolution: Why It Must Work

Despite the logical consistency of the gap structure, the Burgess omega-chain construction MUST produce a limit domain satisfying IsSuccArchimedean because:

**The construction resolves U(⊤,⊥) counterexamples**: When U(⊤,⊥) ∈ limit_f(x) at some x, and no immediate successor y exists in the current finite domain dom(N), the elimination step inserts y = (x + right_neighbor(x))/2 (or x+1 if x is maximal). The inserted point y is placed BETWEEN x and the existing right neighbor in dom(N).

**Critical observation**: The succ function (defined via C5 in the full limit_dom) picks the CLOSEST limit_dom point after x. If the orbit has succ(s^[n](a)) = s^[n+1](a) (i.e., succ maps orbit to orbit), then succ is already computing within the orbit sub-chain. But succ is defined as the C5 witness for U(⊤,⊥) — it finds the NEAREST limit_dom point above x with no limit_dom points in between.

**The key**: If the orbit and pred-chain are separated by a gap (no limit_dom points between them), then for an orbit point x, succ(x) might be in the pred-chain (if the pred-chain is directly above x with no limit_dom in between). This would immediately give: s^[n+1](a) = pred-chain point, contradicting h_lt_pred_chain.

**The orbit-succ connection**:
- h_lt_pred_chain says: s^[n](a) < p^[k](pb) for all n, k
- succ(s^[n](a)) <= p^[k](pb) for all k (from limitDomSubtype_succ_le_iff: succ(x) <= y iff x < y)
- So succ(s^[n](a)).val <= inf_k {(p^[k](pb)).val}

If inf_k {(p^[k](pb)).val} = L (the pred-chain converges from above to L), then:
- succ(s^[n](a)).val <= L
- succ(s^[n](a)).val > s^[n](a).val
- So s^[n](a).val < succ(s^[n](a)).val <= L

This means succ(s^[n](a)) is a limit_dom point with value in (s^[n](a).val, L]. By orbit_below_L: any limit_dom point c with a <= c and c.val < L is an orbit point (succ-iterate of a). But succ(s^[n](a)).val could equal L... 

**If succ(s^[n](a)).val = L for some n**: This means L ∈ Q and L ∈ limit_dom, and succ(s^[n](a)) is a limit_dom point at value L. But succ(s^[n](a)) = s^[n+1](a) (the next orbit point). So s^[n+1](a).val = L. This contradicts orbit_below_L NOT: it means the orbit reaches L exactly. Then b > L, and b > s^[n+1](a) means the orbit doesn't reach b — the contradiction is not immediate.

Wait — the key issue is that if succ(s^[n](a)).val = L, then L is a limit_dom point equal to s^[n+1](a). But ALL pred-chain values p^[k](pb).val >= L = s^[n+1](a).val. This means p^[k](pb) >= s^[n+1](a) for all k. But h_lt_pred_chain(k, n+1) says s^[n+1](a) < p^[k](pb) for all k. So s^[n+1](a).val < (p^[k](pb)).val for all k. But we also said succ(s^[n](a)).val <= (p^[k](pb)).val for all k, and if that value is L then s^[n+1](a).val = L <= (p^[k](pb)).val for all k.

Since h_lt_pred_chain gives strict inequality s^[n+1](a) < p^[k](pb), and s^[n+1](a).val = L, we'd have L < (p^[k](pb)).val for all k. But h_pred_chain_ge_L says L <= (p^[k](pb)).val, with strict inequality L < (p^[k](pb)).val following from s^[n+1](a).val = L being a limit_dom point strictly below each pred-chain point.

Now: succ(s^[n+1](a)) = next limit_dom point after s^[n+1](a). What is it? We know p^[0](pb) = pb is a limit_dom point > s^[n+1](a). So succ(s^[n+1](a)) <= pb. Is succ(s^[n+1](a)) = pb? Only if no limit_dom points exist between s^[n+1](a) and pb.

But we can apply the same argument recursively: for n' = n+1, either succ(s^[n'](a)).val = L' for some L' (where L' is the limit of the sub-orbit starting from s^[n'](a)), or succ keeps climbing. Eventually the orbit must either reach b or there's always a gap — which is exactly what we're trying to prove/disprove.

### 11. The Correct Resolution: The Pred-Chain Must Converge to L Exactly

**The key structural fact** (not yet formalized): The pred-chain `{p^[k](pb)}` is strictly decreasing and bounded below by L. It must converge (in R) to some value M >= L. Two cases:

**Case M > L**: The gap (L, M) in R contains no limit_dom points. The orbit converges to L from below, and the pred-chain converges to M from above. There is no limit_dom point in (L, M). The succ of any orbit point must be <= the pred-chain (since pred-chain points are > orbit points, and succ(x) <= any limit_dom point > x). So succ(orbit).val <= M. And succ(orbit).val > orbit.val → L. So succ(orbit) converges to... something in [L, M]. But there's no limit_dom in (L, M), so succ(orbit) must converge to L or M.

Actually: the pred-chain values form a sequence p^[k](pb).val strictly decreasing from pb.val downward. They are >= L. Their infimum is M = inf_k {p^[k](pb).val} >= L. If M > L: there are no limit_dom points in (L, M) (since all orbit < L and all pred-chain >= M). For any orbit point x with x.val close to L: succ(x).val > x.val. And succ(x) <= p^[k](pb) for all k (from succ_le_iff). So succ(x).val <= p^[k](pb).val for all k, meaning succ(x).val <= M. But succ(x).val > x.val → L. So for large n, succ(s^[n](a)).val ∈ (L, M]. If succ(s^[n](a)).val < M: it's a limit_dom point in (L, M), contradicting "no limit_dom in (L, M)." If succ(s^[n](a)).val = M: it's a limit_dom point at M, which should be a pred-chain value if M is rational. But p^[k](pb).val > M for all k (since the infimum M is not achieved if pred-chain is strictly decreasing)... actually, M = lim_{k→∞} p^[k](pb).val could be rational or irrational.

**This is the crux**: If M is irrational, the pred-chain values approach M from above but never equal M. The orbit values approach L from below. succ(orbit) maps into (L, M] — but M is irrational, so there's no limit_dom point AT M. The succ values must be rational (since limit_dom ⊂ Q) and in (L, M] ⊂ Q. So succ values are in (L, M) ∩ Q, but those are... also limit_dom points in the gap!

**Wait**: (L, M) contains no limit_dom points by assumption. But succ(x).val for orbit x is a limit_dom point with value in (L, M). Contradiction!

**This is the key contradiction**: If M > L (gap exists), then for any orbit point x with x.val close to L, succ(x).val is a limit_dom point in (L, M) — but no such limit_dom points exist. CONTRADICTION.

**Therefore M = L**: The pred-chain converges to exactly L. But then p^[k](pb).val → L, while all p^[k](pb).val > L (strictly, since s^[n](a) < p^[k](pb) strictly and s^[n](a).val → L). 

Now succ(x).val for orbit x: succ(x).val > x.val, succ(x).val <= p^[k](pb).val for all k. So succ(x).val <= inf_k p^[k](pb).val = L. But succ(x).val > x.val → L means succ(x).val approaches L. Actually: succ(x).val ∈ (x.val, L]. If succ(x).val = L: L ∈ Q ∩ limit_dom = orbit point (by orbit_below_L, if L.val = L and a <= L, then L is an orbit point). And succ(x) = L is an orbit point with value = L. Then succ(L) must be some limit_dom point > L. succ(L).val > L. And succ(L) <= p^[k](pb) for all k. So succ(L).val <= inf_k p^[k](pb).val = L. Contradiction: succ(L).val > L and succ(L).val <= L.

**This gives the needed contradiction**: Once M = L (pred-chain converges to L), the orbit must eventually have a succ that is a limit_dom point with value in (x.val, L]. If that value = L: L is a limit_dom point (orbit point), and succ(L) has value > L but <= L. Contradiction. If value < L: it's another orbit point, and we recurse. But the orbit values strictly increase toward L, and succ maps orbit to limit_dom with value <= L. If all succ values are < L (orbit stays below L), the orbit is closed under succ — an omega-chain converging to L with no escape. This is consistent but forces the limit_dom to have a "Dedekind cut" at L.

The key step missing: we need to show succ(s^[n](a)).val CANNOT be strictly between s^[n](a).val and L for all n. But this is essentially what we're trying to prove (the orbit must eventually reach or exceed b).

---

## Recommended Approach: The Succ-Implies-Pred-Chain Approach

Based on the analysis above, the cleanest formalization strategy is:

**Theorem**: `succ(s^[n](a)).val <= L` for all n [proved, since succ <= all pred-chain values, and all pred-chain values >= L... wait, this gives succ(s^[n](a)).val <= p^[k](pb).val for all k, so succ(s^[n](a)).val <= inf_k p^[k](pb).val].

**New fact needed**: `inf_k p^[k](pb).val = L` — the pred-chain converges exactly to L.

**Proof**: The pred-chain values p^[k](pb).val are >= L (by h_pred_chain_ge_L). Their infimum is some M >= L. For any ε > 0, the orbit values s^[n](a).val converge to L, so for large n, s^[n](a).val > L - ε. And s^[n](a).val < p^[k](pb).val for all k. So p^[k](pb).val > L - ε for all k. Taking inf: M >= L - ε for all ε > 0, so M >= L. Combined with M >= L already, M = L... no wait, this just says M >= L which we already know.

Actually we need M <= L to conclude M = L. But orbit values → L and orbit < pred-chain means L <= pred-chain, so M = inf pred-chain >= L. There's no reason M <= L from the orbit alone.

**Different approach**: Use h_pred_chain_ge_L combined with the fact that pred-chain is strictly decreasing. The pred-chain p^[k](pb) has p^[k+1](pb) = pred(p^[k](pb)) which is the immediate predecessor. So p^[k](pb).val and pred(p^[k](pb)).val are consecutive limit_dom values — no limit_dom points between them. By h_lt_pred_chain: for any orbit point s^[n](a): s^[n](a).val < p^[k+1](pb).val = pred(p^[k](pb)).val < p^[k](pb).val. So orbit points are always strictly below consecutive pred-chain points. As k → ∞, p^[k](pb).val → M.

**The contradiction via succ and pred-chain approach**:

For large enough n, s^[n](a).val is very close to L (within ε of L). We have:
- succ(s^[n](a)) <= p^[k](pb) for all k [since p^[k](pb) is a limit_dom point > s^[n](a)]
- So succ(s^[n](a)).val <= p^[k](pb).val for all k
- Taking inf: succ(s^[n](a)).val <= M = inf_k p^[k](pb).val

And:
- succ(s^[n](a)).val > s^[n](a).val (strictly)

So: s^[n](a).val < succ(s^[n](a)).val <= M.

This shows succ(s^[n](a)) is a limit_dom point in the interval (s^[n](a).val, M].

If succ(s^[n](a)).val < M: then succ(s^[n](a)) is a limit_dom point in (s^[n](a).val, M). Is succ(s^[n](a)) an orbit point? By orbit_below_L: if succ(s^[n](a)).val < L, yes. If succ(s^[n](a)).val ∈ [L, M), then it's in the "gap" — but by h_lt_pred_chain: s^[n+1](a) < p^[k](pb) for all k. If s^[n+1](a).val < M = inf pred-chain, and s^[n+1](a) is NOT an orbit point (value >= L)... this is the gap scenario again.

**The real key insight**: in the discrete case, the pred-chain is a sequence of actual limit_dom points with consecutive points being immediate predecessors. The pred-chain values form a strictly decreasing sequence with values in Q bounded below by L. Being in Q and strictly decreasing, this sequence CANNOT converge to an irrational. But it CAN converge to a rational. If it converges to rational M > L: there is no limit_dom point in (L, M) ∩ Q... but the orbit's succ values are in (orbit.val, M] ∩ Q ∩ limit_dom. If no limit_dom in (L, M), all succ values are <= L or = M. Since succ values > orbit > converging to L, for large n succ(s^[n](a)).val > L. So succ values approach M from above or equal M.

Can succ(s^[n](a)).val = M for infinitely many n? If so, M ∈ Q ∩ limit_dom. Then M is a limit_dom point, and p^[k](pb).val → M from above. So for large k, p^[k](pb).val is very close to M from above, and they are consecutive limit_dom points in the pred-chain. But M = limit_dom point. Is M in the pred-chain? The pred-chain starts at pb and iterates pred. If M is NOT in the pred-chain, then p^[k](pb).val never equals M — but they converge to M. The pred-chain values are a strictly decreasing sequence of rationals in Q converging to M ∈ Q with no value equal to M. This is only possible if there are infinitely many limit_dom points in (M, pb.val] — the pred-chain itself. And M is a limit_dom point with no predecessor in the pred-chain. But pred(M) is a limit_dom point < M (since pred(x) < x always). By h_lt_pred_chain: s^[n](a) < pred(M) for all n? Not necessarily — pred(M) might be < L.

This analysis is getting extremely complex. The conclusion is:

**The succ_cofinal proof is genuinely hard and requires a novel argument not directly found in the cited literature.**

---

## Evidence and Examples

### Relevant File Locations

- `ChronicleToCountermodel.lean:1559-1885` — full succ_cofinal proof with sorry
- `ChronicleToCountermodel.lean:1100-1133` — succ_orbit_convex
- `ChronicleToCountermodel.lean:858-882` — limit_dom_has_succ, limit_dom_has_pred
- `ChronicleToCountermodel.lean:912-936` — limitDomSubtype_succ_le_iff (succ(a) <= b iff a < b)
- `ChronicleConstruction.lean:689-722` — limit_F_resolution, limit_P_resolution
- `Axioms.lean:357-378` — prior_UZ, prior_SZ, z1 definitions
- `literature/Doets_1987_Completeness_and_Definability_thesis.md:114-116` — Claim 10 (maximum principle)
- `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md:450-690` — Prior-UZ gap elimination

### The Most Tractable Formal Argument

**Claim**: In the second branch (L <= pred(b).val), for any orbit point s^[n](a), the successor succ(s^[n](a)) is a limit_dom point that is upper-bounded by ALL pred-chain points. 

**Formalization sketch** (using already-available lemmas):

```lean
-- For any orbit point x = s^[n](a) and pred-chain point p^[k](pb):
-- succ(x) <= p^[k](pb)   [since x < p^[k](pb) and succ_le_iff: succ(x) <= y iff x < y]
have h_succ_le_pred_chain : ∀ k n, 
    limitDomSubtype_succ A h_mcs h_discrete (s^[n] a) ≤ p^[k] pb :=
  fun k n => (limitDomSubtype_succ_le_iff A h_mcs h_discrete _ _).mpr (h_lt_pred_chain k n)

-- Taking k → ∞: succ(s^[n](a)).val ≤ inf_k (p^[k](pb)).val = M
-- But pred-chain values converge (strictly decreasing, bounded), so M = lim
-- If M > L: succ(s^[n](a)) is a limit_dom point in (L, M) — but orbit_below_L
--   says all limit_dom in [a, L) are orbit points; points in [L, M) would need
--   to be limit_dom points that are neither orbit nor pred-chain. 
-- Key: If M > L, then pred-chain converges to M > L with all pred-chain values
--   strictly above L. The inf_k succ(s^[n](a)).val <= M. But does this bound
--   get strict? YES: if succ(s^[n](a)).val < M and succ(s^[n](a)).val >= L,
--   then succ(s^[n](a)) is a limit_dom point in [L, M). It is NOT an orbit point
--   (orbit_below_L: orbit points have value < L). So succ(s^[n](a)) is between
--   the orbit and pred-chain: succ(s^[n](a)) > all orbit, succ(s^[n](a)) < some pred-chain.
```

However, h_lt_pred_chain(k, n+1) says s^[n+1](a) < p^[k](pb) for all k. So s^[n+1](a) = succ(s^[n](a)) satisfies succ(s^[n](a)) < p^[k](pb) for all k — which we already know from h_lt_pred_chain!

So `h_succ_le_pred_chain` is just h_lt_pred_chain restated (with <= instead of <, but they're equivalent since succ(x) != pred-chain by h_ne_pb reasoning). This doesn't give new information.

### The Approach That DOES Work: Pred-Chain Convergence to the Orbit Limit

The most rigorous argument is:

**Claim**: The pred-chain inf M = L (same limit as the orbit).

**Proof**: 
- h_pred_chain_ge_L: ∀ k, L ≤ (p^[k](pb)).val [pred-chain values >= L]
- So M = inf_k (p^[k](pb)).val >= L
- We need M <= L to get M = L

For M <= L: Suppose M > L. Then there is a rational gap (L, M) with no limit_dom points. For any orbit point s^[n](a), succ(s^[n](a)) is a limit_dom point in (s^[n](a).val, ∞). By h_succ_le_pred_chain: succ(s^[n](a)).val <= p^[k](pb).val for all k. Taking lim k→∞: succ(s^[n](a)).val <= M. 

But succ(s^[n](a)).val > s^[n](a).val → L. For large n, succ(s^[n](a)).val > L. So succ(s^[n](a)) is a limit_dom point in (L, M] — **but (L, M) has no limit_dom points by assumption, and M is the infimum of the pred-chain (not necessarily achieved)**. 

If succ(s^[n](a)).val ∈ (L, M): it's a limit_dom point in the gap. Contradiction with "no limit_dom in gap."

If succ(s^[n](a)).val = M: M is a rational limit_dom point. Then M ∈ Q ∩ limit_dom. But p^[k](pb).val → M from above with p^[k](pb) ∈ limit_dom. Is M = p^[K](pb) for some K? If yes: the pred-chain reaches M at step K and then pred(M) = p^[K+1](pb) with pred(M).val < M. But pred-chain values >= L and pred(M).val < M — is pred(M).val >= L? Not necessarily.

If pred(M).val < L: then pred-chain value p^[K+1](pb).val < L, contradicting h_pred_chain_ge_L.

If pred(M).val >= L: then p^[K+1](pb).val ∈ [L, M), contradicting the infimum property (M = inf but p^[K+1](pb).val < M is a smaller bound).

Wait: inf_k p^[k](pb).val = M means M is the greatest lower bound. If p^[K+1](pb).val < M for some K+1, that contradicts M being the infimum (M <= p^[K+1](pb).val for all k).

**Aha!** Since p^[k](pb) is strictly decreasing (each step reduces by pred), the infimum M satisfies p^[k](pb).val > M for all k. So M is never achieved in the pred-chain. If M is rational, there might or might not be a limit_dom point at M.

**If M ∈ limit_dom** (M is a rational limit_dom point not in the pred-chain): Then succ(s^[n](a)).val = M for large n (as the orbit's succ converges to M). Then s^[n+1](a) = M for large n — but the orbit values s^[n+1](a).val are strictly increasing and approaching L, so they equal M only if M = L. Contradiction with M > L.

**If M ∉ limit_dom** (M is not a limit_dom point): The orbit's succ values succ(s^[n](a)).val are in (s^[n](a).val, M] ∩ Q ∩ limit_dom. Since succ(s^[n](a)).val > s^[n](a).val → L and succ(s^[n](a)).val <= M, for large n succ(s^[n](a)).val ∈ (L, M]. If M ∉ limit_dom, then succ(s^[n](a)).val ∈ (L, M) for all large n. But (L, M) ∩ limit_dom = ∅ by assumption. Contradiction!

**BOTH sub-cases give contradictions when M > L**. Therefore M <= L, which combined with M >= L gives **M = L**.

This is the key structural result: **the pred-chain converges to exactly L**.

### Putting It Together

Once M = L is established:

- All pred-chain values p^[k](pb).val → L from above, all strictly > L
- succ(s^[n](a)).val <= p^[k](pb).val for all k, so succ(s^[n](a)).val <= L
- succ(s^[n](a)).val > s^[n](a).val (strict)
- So succ(s^[n](a)) is a limit_dom point in (s^[n](a).val, L]
- By orbit_below_L: if succ(s^[n](a)).val < L, then succ(s^[n](a)) is an orbit point
- So either succ maps orbit to orbit (values < L, all orbit points), or succ(s^[n](a)).val = L

If succ(s^[n](a)).val = L for some n: L ∈ Q ∩ limit_dom, L = s^[n+1](a). Then succ(L) = succ(s^[n+1](a)) is a limit_dom point with value in (L, succ(L).val]. And succ(L) <= p^[k](pb) for all k (from h_lt_pred_chain: s^[n+1](a) < p^[k](pb) and succ_le_iff). So succ(L).val <= L. But succ(L).val > L = s^[n+1](a).val. Contradiction!

**This is the final contradiction in the case where some orbit point's succ reaches L.**

If succ maps orbit to orbit (all values < L): then the orbit is closed under succ, a bi-infinite ω-chain. But then `pred(s^[0](a)) = pred(a)` is a pred-chain point (by h_lt_pred_chain: s^[n](a) < p^[k](pb), and if the orbit < all pred-chain, then pred(something in orbit) might be in orbit or pred-chain). Actually pred(orbit_point) < orbit_point, which might be another orbit point (since orbit is closed under pred as well? No — pred is the GLOBAL pred on limit_dom, not restricted to orbit). Hmm.

Actually: in the constant MCS case with succ mapping orbit to orbit:
- succ(s^[n](a)).val < L for all n
- succ(s^[n](a)) is another orbit point
- s^[n+1](a) is the next orbit point
- orbit_below_L: s^[n](a) < s^[n+1](a) < L for all n

So the orbit strictly increases toward L but never reaches L. succ maps orbit to orbit. This is the ω-chain. The pred-chain (descending from pb) converges to L from above. Together they form the Z+Z structure.

But we proved M = L: pred-chain converges to L. And pred-chain values > L. So for any pred-chain point p^[k](pb), pred(p^[k](pb)) = p^[k+1](pb) is strictly between L and p^[k](pb). The pred-chain approaches L but never reaches it.

**The final contradiction**: Consider pred(p^[0](pb)) = pred(pb) = p^[1](pb). We need pred(pb).val > L. This is p^[1](pb).val > L (by h_pred_chain_ge_L). Now succ(p^[1](pb).val...): we need succ(pred-chain point). But pred-chain points are NOT orbit points. Where does succ(p^[1](pb)) land?

succ(p^[1](pb)) is the next limit_dom point after p^[1](pb). It must be <= p^[0](pb) = pb (since pb is a limit_dom point > p^[1](pb), and succ(x) <= any limit_dom point > x). So succ(p^[1](pb)) <= pb.

Is succ(p^[1](pb)) = pb? That would mean pred(pb) and pb are consecutive in limit_dom, which is the definition — pred(pb) is the immediate predecessor of pb in limit_dom. And succ(pred(pb)) = pb by limitDomSubtype_succ_pred! So YES: succ(p^[1](pb)) = succ(pred(pb)) = pb = p^[0](pb).

So pred-chain points are connected: succ(pred-chain point k+1) = pred-chain point k. The pred-chain is itself an ω*-chain with succ mapping each pred-chain point to the previous one (toward pb).

The orbit and pred-chain together form two disjoint components of limit_dom in [a, ∞):
- Orbit: a, s(a), s²(a), ... with values increasing to L
- Pred-chain: pb, pred(pb), pred²(pb), ... with values decreasing to L

And NOTHING in between (no limit_dom points with values in [L, inf-pred-chain) from below or (orbit-sup, L] from above, since orbit values approach L from below and pred-chain values approach L from above with no limit_dom in between).

**Now apply the key constraint**: succ(s^[n](a)) = s^[n+1](a) for all n (orbit closed under succ). And succ(p^[k+1](pb)) = p^[k](pb) for all k (pred-chain closed under succ, going upward).

But what connects the orbit to the pred-chain? The orbit values approach L, and the pred-chain values approach L. The orbit's succ values are strictly in (orbit.val, L), all orbit. The pred-chain's pred values are strictly in (L, pred-chain.val), all pred-chain. NOTHING connects them.

**But wait**: The entire limit_dom = union of all omega_chain_val(N).dom. The orbit and pred-chain are both SUBSETS of limit_dom. Are there other limit_dom points in [a.val, b.val] besides the orbit and pred-chain? In the Z+Z scenario, NO — that's the assumption (orbit and pred-chain are the ONLY limit_dom points in the relevant region).

The Z+Z structure IS consistent with all temporal axioms in the constant MCS case. So the sorry represents a genuine mathematical gap that CANNOT be closed by the Z1/Prior-UZ approach alone in the constant MCS case.

---

## Confidence Level

**Mathematical truth of succ_cofinal**: HIGH — IsSuccArchimedean holds for the limit domain in the discrete case. The Burgess construction cannot produce a genuine Z+Z gap in the actual limit_dom because the construction ALWAYS inserts a new point as immediate successor, ensuring succ-connectivity.

**Confidence that the current proof approach (by contradiction, gap analysis) can be completed**: LOW. The constant MCS + Z+Z case appears to be a genuine mathematical gap in the formalization that the current approach cannot close without accessing construction internals.

**Confidence in the Prior-UZ/Z1 approach**: MEDIUM for the non-constant MCS case, LOW for constant MCS case.

**Recommended primary approach**: 

1. **Use the pred-chain convergence argument**: Prove M = L (pred-chain inf = orbit limit). Then use the contradiction that succ(s^[n](a)).val ∈ (s^[n](a).val, L] — forcing the orbit to reach L (a contradiction if succ(orbit at L) has value > L but <= L), or succ maps orbit to orbit forever (which forces a Z+Z structure contradicting the existence of b > orbit).

Actually, the last point is key: b is a SPECIFIC limit_dom point with a < b. In the Z+Z scenario, succ^[n](a) never reaches b (all orbit points have values < L <= pred(b).val < b.val). The sorry represents the claim that this is impossible — but in the constant MCS case with the Z+Z structure, it appears that succ^[n](a) genuinely never reaches b.

**The true resolution**: The theorem succ_cofinal is mathematically true because the Burgess CONSTRUCTION cannot produce a Z+Z gap. But proving this requires:
1. Understanding that the construction inserts succ points in a globally consistent way
2. Showing that if b ∈ limit_dom, then b was inserted at some stage N, and at that stage, the chain from a to b was already "connected" by the construction

This is the **construction-level argument** (Approach B from report 01), which is the only approach that truly resolves the constant MCS case. The formalization effort is HIGH but the mathematical path is clear: trace how b entered limit_dom (at some stage N), and show that by that stage, all the intermediate limit_dom points including the chain from a to b were already present and succ-connected.

**Final recommendation**: This is a [BLOCKED] situation for the current formalization approach. The sorry cannot be resolved within the current proof structure without either:
1. Massive new construction-level infrastructure (200-400 lines), OR
2. An alternative formalization strategy (e.g., the reflexive/weak completeness approach referenced in task 129)

The team research should focus on whether approach (2) — the alternative from task 129 — is closer to completion than approach (1).
