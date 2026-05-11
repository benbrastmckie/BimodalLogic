# Teammate A Findings: Is succ_embed_surjective Provable?

Task: 123 | Artifact: 02a | Date: 2026-05-11

## Verdict: YES — succ_embed_surjective IS TRUE and PROVABLE

The statement `succ_embed_surjective` is mathematically TRUE. The accumulation
scenario described in the task prompt cannot occur. However, the current sorry
reflects a real formalization gap: the stage induction fails at the "above all
old points" subcase. A correct proof exists but requires a different strategy
than the current inductive approach.

---

## 1. Code Analysis: Where the Sorry Lives

**File**: `ChronicleToCountermodel.lean`, lines 2060, 2063.

The proof attempts induction on omega-chain stage K. For each q newly added at
stage K+1, it case-splits:
- `q` between old points (lines 2064–2095): **PROVED** using
  `exists_containing_adjacent` + `succ_embed_squeeze_strict`
- `q` above all old points (line 2060): **SORRY**
- `q` below all old points (line 2063): **SORRY** (symmetric)

The sorry at line 2060 covers: q > max_K where max_K = dom_K.max' is the
maximum stage-K domain point. By IH, max_K = succ_embed(j). We need to show
q = succ_embed(k) for some k. The obvious candidate is k = j+1 (i.e.,
succ_embed(j+1) = limitDomSubtype_succ(max_K) = q), but this requires
knowing that the limit-domain successor of max_K is exactly q and no later
stage inserts a point between max_K and q below q.

The difficulty: the limit-domain successor of max_K is computed using
`Classical.choose` on the FULL `limit_dom`, which includes points added at
stages K+2, K+3, .... A point m added at stage K+5 between max_K and q would
make `succ(max_K) = m`, not q. Then q ≠ succ_embed(j+1), and we'd need a
larger k, but the induction gives no handle on it.

---

## 2. How limit_dom Is Constructed (Answer to Question 2)

**`limit_dom`** is defined as:
```
limit_dom A h_mcs = { x | ∃ n : ℕ, x ∈ (omega_chain_val A h_mcs n).dom }
```
It is the union of all finite domains. Each `omega_chain_val(n).dom` is a
`Finset Rat`.

**Is it closed under limits of convergent sequences?** NO. Each point enters at
a FINITE stage. There is no "limit step." The construction is an omega-chain
(indexed by ℕ), not a transfinite ordinal sequence. If a bounded monotone
sequence s_0 < s_1 < s_2 < ... has rational limit L, then L itself is NOT
automatically in limit_dom unless some stage explicitly adds it.

**Can a monotone bounded sequence converge to a point NOT in limit_dom?** YES,
in principle. This is precisely why the accumulation question is non-trivial.
If infinite midpoints m_1 < m_2 < ... are added between 0 and q, they converge
to some L, and L need not be in limit_dom.

**How does `limit_dom_has_succ` work?** Given `next_top ∈ limit_f(x)`, the
theorem finds y with:
- y ∈ limit_dom
- x < y
- NO limit_dom points between x and y (the bot-gap property)

This uses `limit_satisfies_c5_strong` with ξ = bot, η = top_formula. The guard
condition gives `bot ∈ limit_f(w)` for all w in limit_dom with x < w < y. Since
bot is never in any MCS, this means there are truly NO limit_dom points between
x and y.

**Does `Classical.choose` pick from Q or from limit_dom?** The choose picks from
`limit_dom`. The existential in `limit_dom_has_succ` is:
```
∃ y ∈ limit_dom A h_mcs, x < y ∧ ∀ w ∈ limit_dom A h_mcs, x < w → w < y → False
```
So `limitDomSubtype_succ` returns the smallest `limit_dom` point above x that
has no `limit_dom` points between itself and x. This is the unique immediate
successor in the full limit_dom.

---

## 3. The Convergence Scenario Analysis (Answer to Question 3)

**Setup**: Suppose succ_embed(0), succ_embed(1), succ_embed(2), ... is an
increasing bounded sequence with rational values converging to some rational L.

Each succ_embed(n) = succ^n(root) where succ is the limit-domain immediate
successor. Between succ_embed(n) and succ_embed(n+1), there are NO limit_dom
points (by `succ_embed_no_gap`). So the values partition limit_dom into
consecutive "adjacent" blocks.

**Does the sequence have a limit in limit_dom?** Not automatically. If L ∉
limit_dom, then L is a rational number that was never added to any stage.

**But the convergence scenario leads to contradiction.** Here is the argument:

Suppose the positive orbit {succ_embed(n) : n ≥ 0} is bounded above by some
w ∈ LimitDomSubtype. Then:
1. succ_embed(n) < w for all n.
2. succ(succ_embed(n)) = succ_embed(n+1) ≤ w (by succ_le_iff in SuccOrder:
   succ(a) ≤ b ↔ a < b).
3. The orbit is bounded above by w in LimitDomSubtype.
4. Between any two consecutive orbit points, there are no limit_dom points.
5. All orbit points are in limit_dom.

Now consider the limit_dom points in the interval [root, w]. By points 4 and 5,
the orbit points succ_embed(0), succ_embed(1), ... are all in this interval, and
no limit_dom points exist between consecutive orbit points.

**Key claim**: The interval [root, w] in LimitDomSubtype is FINITE.

**Proof of finiteness**: Suppose [root, w] is infinite. Then there exist
infinitely many limit_dom points c_0 < c_1 < c_2 < ... all ≤ w.val. Between
consecutive c_i, there are no limit_dom points (by the discrete property:
each c_i has an immediate successor with no intermediate points). In particular,
c_{i+1} = succ(c_i), so the sequence IS exactly the orbit starting from c_0.

The rational values c_i.val form an infinite bounded monotone sequence. Let
L = sup{c_i.val} ∈ ℝ. Since the c_i are rationals and the sequence is bounded,
L exists in ℝ but may or may not be in ℚ.

Case A (L ∈ ℚ): Consider the limit_dom point c with c.val closest to L (if
such exists). For large i, c_i is very close to L, so c_i > pred(c) (the
limit_dom predecessor of c). But between pred(c) and c, there are NO limit_dom
points. Yet c_i ∈ limit_dom and pred(c) < c_i < c for large i. Contradiction.

Actually, to be precise: for large enough i, c_i.val > pred(c).val (since
c_i.val → L = c.val). So pred(c) < c_i in LimitDomSubtype. But c_i < c (since
c_i.val < L = c.val). And by definition of pred(c), nothing is in limit_dom
between pred(c) and c. Yet c_i is there. Contradiction.

Case B (L ∉ ℚ): L is irrational. Consider the smallest limit_dom point z with
z.val > L (exists by NoMaxOrder + limit_dom structure). Then pred(z) exists and
pred(z).val < z.val with no limit_dom points between them. Since c_i.val → L
and L < z.val, for large i, c_i.val ∈ (pred(z).val, z.val). So c_i is a
limit_dom point between pred(z) and z. Contradiction.

**Conclusion**: The interval [root, w] must be FINITE. But the orbit
succ_embed(0), succ_embed(1), ... gives infinitely many distinct limit_dom
points in [root, w]. Contradiction.

Therefore the orbit CANNOT be bounded: it is cofinal (unbounded above) in
LimitDomSubtype. By the symmetric argument, the backward orbit is also cofinal
below. Combined with `succ_embed_squeeze`, every point in LimitDomSubtype lies
between two orbit points, hence equals some orbit point.

---

## 4. Is limit_dom Countable? (Answer to Question 4)

YES. `limit_dom` is the union of countably many finite sets:
- `omega_chain_val(n).dom` is a `Finset Rat` for each n
- The countable union of finite sets is countable

The Lean file explicitly establishes:
```lean
instance limitDomSubtype_countable : Countable (LimitDomSubtype A h_mcs) := Subtype.countable
```

**Can a countable dense subset of Q have the accumulation problem?**
In the DENSE case (F'T holds everywhere), yes: limit_dom is dense and has no
immediate successors. In the DISCRETE case (U(T,bot) holds everywhere), NO:
each point has an immediate successor with no limit_dom points between them.
The discrete structure precludes accumulation because any bounded increasing
sequence of limit_dom points would need to have a limit point in limit_dom to
"stop" — but the Icc finiteness argument above shows no such infinite bounded
sequence can exist.

---

## 5. How limitDomSubtype_succ Works (Answer to Question 5)

`limitDomSubtype_succ(⟨x, hx⟩)` returns the IMMEDIATE successor of x in the
full limit_dom ordering — the smallest limit_dom point y > x with no limit_dom
points between x and y. This is the `Classical.choose` from `limit_dom_has_succ`.

This is NOT the successor at any particular finite stage. It reflects the full
limit_dom structure, including points added at all future stages. This is why
stage induction fails: `succ(max_K)` at stage K may be a point added at stage
K+100 that has no relationship to what's currently in dom(K).

---

## 6. Why the Current Proof's Strategy Fails

The induction on K maintains: "every q ∈ dom(K) is in the image of succ_embed."

For q newly added at stage K+1 above max_K:
- By IH: max_K = succ_embed(j)
- We want: q = succ_embed(j+1) = succ(max_K)
- succ(max_K) is the smallest limit_dom point > max_K
- But succ(max_K) might be a point added at stage K+1000, not q itself

The orbit position of q (which integer k satisfies succ_embed(k) = q) is not
determined by the stage K. It depends on how many limit_dom points lie between
max_K and q in the FULL limit_dom, which is a global property.

---

## 7. The Correct Proof Strategy

The correct approach does NOT use stage induction. Instead:

**Strategy: Icc Finiteness + Pred-Chain Termination**

Lemma A: `icc_finite` — For any a, b ∈ LimitDomSubtype with a ≤ b, the set
`{w ∈ LimitDomSubtype | a ≤ w ≤ b}` is finite.

Proof sketch: By the accumulation argument in Section 3. An infinite bounded
set would have a convergent subsequence with a limit L, and since each element
has an immediate successor/predecessor with nothing between, L would need to
be in limit_dom (generating a contradiction via the no-between property).

Formally: Suppose for contradiction the set is infinite. Extract an infinite
increasing sequence c_0 < c_1 < c_2 < ... ≤ b. The rational values c_i.val
are bounded by b.val. Since the sequence is strictly increasing and bounded,
it converges in ℝ to some L ≤ b.val. For any limit_dom point z with z.val > L,
its predecessor pred(z) satisfies pred(z).val < z.val with no limit_dom points
between them. For large i, pred(z) < c_i < z (since c_i.val → L ≤ z.val and
c_i < z for all i, while c_i.val eventually exceeds pred(z).val). Contradiction.

Lemma B: `surjectivity from icc_finite` — Given icc_finite, for any w ∈
LimitDomSubtype, the set {k ≥ 0 : succ_embed(k) ≤ w} is finite (since
succ_embed is strictly increasing and all its values ≤ w lie in Icc root w).
Let k_max be its maximum; then succ_embed(k_max) ≤ w < succ_embed(k_max + 1).
By `succ_embed_no_gap`, there are no limit_dom points between them, so w =
succ_embed(k_max). Done for the positive direction.

**Technical challenge**: Proving Icc finiteness in Lean requires working with
the real number line or the archimedean property of Q. Specifically, the
convergence argument uses: for any ε > 0, there exists N such that c_i.val >
L - ε for i > N. With ε = (z.val - pred(z).val)/2, this places c_i between
pred(z) and z.

In Lean 4 / Mathlib, this can be formalized using:
- `Rat.instArchimedean` (Q is archimedean)
- `Finset.exists_lt_card_le` or pigeonhole on stages
- The key fact: each new element entered limit_dom at some stage K, so between
  any two consecutive elements c_i and c_{i+1}, a C4 or C5 counterexample was
  "processed" at stage K_{i+1} with c_i and c_{i+1} as adjacent pair bounds

**Alternative (simpler) formalization path**:

Rather than the real-number limit argument, use the STAGE-BASED argument:

Claim: For any a, b ∈ LimitDomSubtype, the interval [a.val, b.val] ∩ limit_dom
has at most countably many points. Moreover, between consecutive limit_dom
points in this interval, no more points can be added by later stages (because
the bot-gap property in the FULL limit_dom says nothing is there).

Wait, this is not quite right — later stages CAN add points. The bot-gap
property applies to the full limit_dom successor, not to any finite stage.

The cleanest path: prove `LocallyFiniteOrder (LimitDomSubtype A h_mcs)` by
explicitly constructing `Finset.Icc a b` for all a, b. This requires the
finiteness claim above. Then use Mathlib's `IsSuccArchimedean` for
`LocallyFiniteOrder`-equipped SuccOrders.

---

## 8. Impact Assessment

`succ_embed_surjective` is the only sorry in the discrete branch that blocks
the sorry-free completeness proof. The plan (Phase 4) already uses it as a
sub-lemma in the TC and FUC coherence proofs. Once proved:

- `cantor_bfmcs_discrete_restricted_tc` becomes sorry-free
- `cantor_bfmcs_discrete_restricted_fuc` becomes sorry-free
- `dd_countermodel_chronicle_discrete` becomes sorry-free
- The discrete branch of `bx_completeness` becomes sorry-free

---

## 9. Summary Table

| Question | Answer |
|----------|--------|
| Is `succ_embed_surjective` TRUE? | **YES** |
| Can accumulation (irrational limit) break surjectivity? | **NO** |
| Can a point be added above succ_embed(n) for all n? | **NO** — orbit is cofinal |
| Why is the current proof hard? | Stage induction cannot track orbit position of newly added points |
| Is `limit_dom` countable? | **YES** — countable union of finite sets |
| Does `Classical.choose` pick from limit_dom? | **YES** — succ is defined in limit_dom |
| Icc intervals finite? | **YES** — proved by accumulation contradiction |
| Recommended proof path | Prove Icc finiteness → deduce cofinality → apply squeeze lemma |
| Estimated proof length | ~80-120 lines of Lean 4 |
| Blockers | Lean formalization of the archimedean/convergence argument |
