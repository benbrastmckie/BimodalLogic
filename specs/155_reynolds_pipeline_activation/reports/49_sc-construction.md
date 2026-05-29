# Team SC-B: Deep Analysis of Omega-Chain Construction and succ_cofinal Breakdown

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Why the proof breaks at Step 9 and whether the gap scenario is actually reachable

---

## 1. The Omega-Chain Construction End-to-End

### 1.1 How Stages Are Built

The construction is in `ChronicleConstruction.lean` (lines 253-261):

```lean
noncomputable def omega_chain (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    (n : Nat) -> { chi : Chronicle // chi.c0 fc AND chi.c2' fc }
  | 0 => singleton_chronicle A   -- domain {0}, f(0) = A
  | n + 1 => eliminate_potential_counterexample(omega_chain(n), enum(unpair(n).2))
```

- **Stage 0**: Domain `{0}`, point function `f(0) = A` (the target MCS). All coherence conditions hold vacuously (no pairs).
- **Stage n+1**: Process the potential counterexample indexed by `Nat.unpair(n).2`. Uses Cantor unpairing so each counterexample index `j` is processed at infinitely many stages (for all `i`, stage `Nat.pair(i, j) + 1` processes counterexample `j`). This is essential because a counterexample `(x, xi, eta)` can only be eliminated when `x` is already in the domain.

### 1.2 What Is Resolved at Each Stage

Each `eliminate_potential_counterexample` call (defined at `CounterexampleElimination.lean:1810`) dispatches on the counterexample kind:

| Kind | What It Resolves | How |
|------|-----------------|-----|
| `c5_forward` | `U(eta, xi) in f(x)` needs witness `y > x` with `eta in f(y)` | Lemma 2.4 (x = max) or recursive walk (Burgess 2.10) |
| `c5_backward` | `S(eta, xi) in f(x)` needs witness `y < x` | Mirror |
| `c4_forward` | `neg(U(eta, xi)) in f(x)` with `eta in f(y)` needs `z` between with `xi.neg in f(z)` | Direct insertion |
| `c4_backward` | Mirror for Since | Mirror |

If the counterexample is already resolved (witness exists in current domain with proper guard), the step is the identity: `dom(n+1) = dom(n)`.

### 1.3 Coherence Conditions (C0-C5)

| Condition | Statement | Where Maintained |
|-----------|-----------|-----------------|
| **C0** | Every domain point maps to an MCS | `EliminationResult.c0` -- invariant at every stage |
| **C1** | `g_content(f(x)) subset f(y)` for `x < y` adjacent | Implied by C2' |
| **C2'** | `BurgessR3Maximal fc (f(x)) (g(x,y)) (f(y))` for adjacent `(x,y)` | `EliminationResult.c2'` -- invariant |
| **C3** | `g(x,z) = g(x,y) inter f(y) inter g(y,z)` for `x < y < z` | Proved at limit via dense definition of `limit_g` |
| **C4** | Counterexample elimination for `neg(U)` | `limit_satisfies_c4` -- proved at limit |
| **C5** | Until/Since witnesses exist | `limit_satisfies_c5_strong` -- proved at limit |

### 1.4 The Limit Domain

```lean
noncomputable def limit_dom (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) : Set Rat :=
  { x | exists n : Nat, x in (omega_chain_val fc A h_mcs n).dom }
```

This is the countable union of all finite-stage domains. It is a countable subset of `Rat` containing 0, with no maximum or minimum (from seriality axioms). It inherits `LinearOrder` from `Rat`.

### 1.5 LimitDomSubtype

```lean
abbrev LimitDomSubtype (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :=
  {q : Rat // q in limit_dom fc A h_mcs}
```

Instances established:
- `Countable` -- from subtype of countable (line 84)
- `NoMaxOrder` / `NoMinOrder` -- from seriality (lines 130-147)
- `Nonempty` -- from `zero_mem_limit_dom` (line 152)
- `DenselyOrdered` (dense case only) -- from `F'T` hypothesis (line 208)
- `SuccOrder` / `PredOrder` (discrete case only) -- from `limit_dom_has_succ` / `limit_dom_has_pred`

---

## 2. The Successor Function on the Limit Domain

### 2.1 Definition

The successor function is defined at `ChronicleToCountermodel.lean:882`:

```lean
noncomputable def limitDomSubtype_succ (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x) :
    LimitDomSubtype fc A h_mcs -> LimitDomSubtype fc A h_mcs :=
  fun (x, hx) =>
    (limit_dom_has_succ fc A h_mcs x hx (h_discrete x hx)).choose
```

It comes from the chronicle's C5 resolution. Specifically, `next_top = U(top, bot)` holds at every point (the discrete hypothesis). By `limit_satisfies_c5_strong`, there exists a witness `y > x` with `bot` at `y` (false!) and `bot` at all intermediates. The only way this resolves without contradiction is if `y` is the IMMEDIATE successor of `x` -- no domain points between them. The witness is extracted by `Classical.choose`.

### 2.2 Key Properties (Sorry-Free)

| Property | Statement | Status |
|----------|-----------|--------|
| `limitDomSubtype_succ_le_iff` | `succ(a) <= b <-> a < b` | Proved (line 893) |
| `limitDomSubtype_pred_succ` | `pred(succ(a)) = a` | Proved (line 1044) |
| `limitDomSubtype_succ_pred` | `succ(pred(b)) = b` | Proved (line 1010) |
| `limitDomSubtype_pred_lt` | `pred(b) < b` | Proved (line 1081) |
| `succ_orbit_convex` | `a <= b <= succ^[n](a) -> exists k <= n, succ^k(a) = b` | Proved (line 1093) |

### 2.3 What Depends on succ_cofinal

| Property | Statement | Status |
|----------|-----------|--------|
| `succ_cofinal` | `a < b -> exists n, b <= succ^[n](a)` | **SORRY** (line 1885) |
| `limitDomSubtype_isSuccArchimedean` | `IsSuccArchimedean` instance | Depends on `succ_cofinal` |
| `succ_embed_surjective` | Every limit domain point is `succ_embed(n)` for some `n : Int` | Depends on `IsSuccArchimedean` |
| `cantor_bfmcs_discrete_restricted_tc` | TC coherence | Depends on `succ_embed_surjective` |
| `cantor_bfmcs_discrete_restricted_fuc` | FUC coherence | Depends on `succ_embed_surjective` |

Sorry-free: `succ_embed_strictMono`, `succ_embed_no_gap`, `succ_embed_squeeze`, `succ_embed_squeeze_strict`, `cantor_bfmcs_discrete_restricted_buc`.

---

## 3. Detailed Analysis of Step 9

### 3.1 Steps 1-8 (All Proved)

The proof of `succ_cofinal` (lines 1553-1886) proceeds by contradiction: assume `succ^[n](a) < b` for all `n`.

| Step | Lines | What It Establishes |
|------|-------|---------------------|
| 1 | 1561-1564 | All orbit points `s^[n](a) <= pred(b)` |
| 2 | 1566-1586 | Real-valued sequence `f(n) = (s^[n](a)).val` converges to some `L <= b.val` |
| 3 | 1597-1603 | `pred(b).val < b.val` in reals (basic) |
| 4 | 1609-1621 | If `L > pred(b).val`: orbit eventually exceeds `pred(b)`, contradiction with Step 1 |
| 5 | 1627-1634 | All orbit points strictly below `pred(b)` |
| 6 | 1639-1656 | `orbit_below_L`: any limit_dom point `c` with `a <= c` and `c.val < L` is an orbit point `s^[m](a)` |
| 7 | 1658-1684 | Pred-chain `p^[k](pb)` has: all orbit < all pred-chain (for all `k, n`) |
| 8 | 1686-1695 | Pred-chain values >= L in reals; strictly decreasing |

Additional infrastructure proved WITHIN the sorry proof (not depending on the sorry):
- `backward_G` (lines 1703-1753): If `psi in limit_f(y)` for ALL `y > x` in limit_dom, then `G(psi) in limit_f(x)`.
- `backward_F` (lines 1757-1778): If `phi in limit_f(y)` for SOME `y > x`, then `F(phi) in limit_f(x)`.
- `_backward_P` (lines 1827-1839): If `phi in limit_f(y)` for SOME `y < x`, then `P(phi) in limit_f(x)`.

### 3.2 Exact Goal State at the Sorry (Line 1885)

From `lean_goal` at line 1885:

```
case neg
fc : FrameClass
A : Set Formula
h_mcs : SetMaximalConsistent A
h_discrete : forall x in limit_dom fc A h_mcs, next_top in limit_f fc A h_mcs x
a b : LimitDomSubtype fc A h_mcs
hab : a < b
s : LimitDomSubtype fc A h_mcs -> LimitDomSubtype fc A h_mcs
    := limitDomSubtype_succ fc A h_mcs h_discrete
h_not_cofinal : forall (n : Nat), s^[n] a < b
pb : LimitDomSubtype fc A h_mcs
    := limitDomSubtype_pred fc A h_mcs h_discrete b
h_le_pb : forall (n : Nat), s^[n] a <= pb
f : Nat -> Real := fun n => (s^[n] a).val
s_lt : forall (x : LimitDomSubtype fc A h_mcs), x < s x
f_mono : Monotone f
f_bdd : BddAbove (Set.range f)
L : Real
hL_tendsto : Filter.Tendsto f Filter.atTop (nhds L)
hL_ub : forall (n : Nat), f n <= L
hL_le_b : L <= b.val
h_pb_lt_b : pb.val < b.val
h_case : L <= pb.val         -- *** We are in the L <= pred(b) case ***
h_ne_pb : forall (n : Nat), s^[n] a != pb
h_lt_pb : forall (n : Nat), s^[n] a < pb
orbit_below_L : forall (c : LimitDomSubtype fc A h_mcs),
    a <= c -> c.val < L -> exists m, s^[m] a = c
p : LimitDomSubtype fc A h_mcs -> LimitDomSubtype fc A h_mcs
    := limitDomSubtype_pred fc A h_mcs h_discrete
h_lt_pred_chain : forall (k n : Nat), s^[n] a < p^[k] pb
h_pred_chain_strict : forall (k : Nat), (p^[k + 1] pb).val < (p^[k] pb).val
h_pred_chain_ge_L : forall (k : Nat), L <= (p^[k] pb).val
backward_G : forall (psi : Formula) (x : LimitDomSubtype fc A h_mcs),
    (forall (y : LimitDomSubtype fc A h_mcs), x < y ->
      psi in limit_f fc A h_mcs y.val) ->
    psi.all_future in limit_f fc A h_mcs x.val
backward_F : forall (phi : Formula) (x y : LimitDomSubtype fc A h_mcs),
    x < y -> phi in limit_f fc A h_mcs y.val ->
    phi.some_future in limit_f fc A h_mcs x.val
_backward_P : forall (phi : Formula) (x y : LimitDomSubtype fc A h_mcs),
    y < x -> phi in limit_f fc A h_mcs y.val ->
    phi.some_past in limit_f fc A h_mcs x.val
|- False
```

### 3.3 What Is Being Asked

We need to derive `False` from the hypothesis that:
1. The orbit `{s^[n](a)}` is an infinite strictly increasing sequence with real values converging to `L`.
2. `L <= pred(b).val` (all orbit points are well below `b`).
3. Every limit_dom point below `L` (and >= a) is an orbit point.
4. The pred-chain `{p^[k](pb)}` is strictly decreasing with values >= `L`.
5. Every orbit point is strictly below every pred-chain point.
6. We have `backward_G`, `backward_F`, `_backward_P` for the limit domain.
7. Every domain point has an immediate successor and predecessor (discreteness).

The contradiction must come from showing this "gap" structure (orbit from below, pred-chain from above, with limit value `L` between them) is impossible.

---

## 4. The Gap Scenario

### 4.1 The Claim: "Mathematically Consistent with All Temporal Axioms"

The comments at lines 1848-1884 state: "the gap scenario is consistent with all temporal axioms (Z1, Prior-UZ, c5) under strict semantics in the constant-MCS case."

**This claim is CORRECT for temporal axioms alone.** Here is why:

In the **constant-MCS case** (all limit_dom points have the same MCS `B`):
- Every formula either holds everywhere or nowhere
- `G(phi) in B <-> phi in B` (all future points have `B`, so `phi` holds at all of them iff `phi in B`)
- `F(phi) in B <-> phi in B` (dual)
- `U(phi, psi) in B` is resolved by the immediate successor (discrete case: no intermediates, so guard is vacuous)
- Prior-UZ: `F(phi) -> U(phi, neg(phi))`. If `phi in B`: `F(phi) in B`, so `U(phi, neg(phi)) in B`. The C5 witness `y` has `neg(phi) in f(y) = B`. But `phi in B` and `neg(phi) in B` contradicts consistency of `B`.

**Wait**: This IS a contradiction. The constant-MCS case is impossible!

### 4.2 Why the Constant-MCS Case is Impossible

Report 33 identified this at Section 5:

1. B is an MCS, so it contains some formula phi (e.g., any atom or its negation).
2. Since all points have MCS B, phi holds at all future points, so F(phi) in B.
3. By Prior-UZ (axiom in BX): F(phi) -> U(phi, neg(phi)). So U(phi, neg(phi)) in B.
4. By C5-strong: there exists y > x with neg(phi) in f(y) and phi at all intermediates.
5. f(y) = B (constant MCS). So neg(phi) in B.
6. But phi in B and neg(phi) in B contradicts B being consistent (part of being MCS).

**So the constant-MCS case provably cannot arise.**

### 4.3 But the Non-Constant Case Is the REAL Problem

Once we know MCSs vary across the domain, we have a discriminating formula `phi_0` (phi_0 in f(some orbit point) but phi_0 not in f(some pred-chain point), or vice versa). 

The difficulty is: **how to derive a contradiction from this discriminating formula and the gap structure?**

The challenge: the discriminating formula `phi_0` might vary in complex patterns across the domain. We know:
- `phi_0 in f(x)` for some orbit point `x`
- `phi_0 not in f(z)` for some pred-chain point `z`
- Between orbit and pred-chain: NO domain points (the gap at L)

Attempts to exploit this:
1. **backward_G + Prior-UZ**: If `phi_0` fails at `z > x`, then `G(phi_0) not in f(x)`. So `F(neg(phi_0)) in f(x)`. By Prior-UZ: `U(neg(phi_0), phi_0) in f(x)`. C5-strong gives witness `y > x` with `phi_0 in f(y)` and `neg(phi_0)` at intermediates. But `y` could be on the same side of the gap as `x` (orbit side), giving no contradiction.

2. **Crossing the gap**: We need a witness that CROSSES the gap. But `U(neg(phi_0), phi_0)` might be resolved by an orbit point (if `phi_0` holds at some later orbit point). The problem is controlling WHERE the C5 witness falls.

3. **backward_G at gap boundary**: All orbit points have values < L. All pred-chain points have values >= L. If `psi` holds at ALL points > x, then `G(psi) in f(x)`. But we cannot show `psi` holds at points near L from above (those are pred-chain points with potentially different MCS).

### 4.4 Is the Gap Scenario Actually Reachable by the Construction?

**This is the key question.** There are two possibilities:

**(A) The construction CANNOT produce gaps** (succ_cofinal is provable by a construction-level argument):

Evidence for:
- Each point is inserted at a specific finite stage to resolve a specific counterexample
- In the discrete case, new points are placed as immediate successors/predecessors of existing points
- The Cantor unpairing ensures every counterexample is processed infinitely often
- Report 48 (Section 1, "What Would a Proof Look Like") sketches: if a gap point `p` exists above all orbit points, it was inserted at some stage `n_p`. At stage `n_p`, the domain was finite with some maximum orbit point `succ^K(0)`. Point `p` is placed above `succ^K(0)`. Then `pred(p)` should be `succ^K(0)` or a later orbit point, making `p = succ^{K+1}(0)`, an orbit point.

Evidence against:
- The argument above has a gap: `pred(p)` in the LIMIT domain might differ from the predecessors at stage `n_p` because later stages insert more points
- In the discrete case, `pred(p)` is the immediate predecessor (no domain points between), but establishing WHEN `pred(p)` enters the domain relative to `p` is subtle
- Report 32 identifies: "Path A is UNLIKELY to work unless there is a specific BX construction property that forces MCS variation"

**(B) The construction CAN produce gaps** (succ_cofinal requires an external argument):

Evidence for:
- Report 32, Section 2: "The gap scenario IS consistent with all temporal axioms under strict semantics in the constant-MCS case"
- Reynolds 1994, Corollary 3 produces "a countable, discrete [order] without endpoints" but does NOT claim it is Z-isomorphic -- that requires the separate gap elimination pipeline (Lemmas 6-14, Theorem 14)
- The constant-MCS case is impossible (Section 4.2 above), but the non-constant case may still allow gaps

**My assessment**: The truth is likely **(A)** -- the construction cannot produce gaps -- but proving this formally requires a construction-level argument that has not been fully worked out. The gap between the mathematical truth and the formal proof is not due to mathematical incorrectness but due to the difficulty of reasoning about the omega-chain's inductive structure at the limit.

---

## 5. The Frozen Guard Property (adj_g_mem_limit_f)

### 5.1 Type Signature

From `lean_hover_info` at `ChronicleConstruction.lean:1357`:

```lean
adj_g_mem_limit_f (fc : FrameClass) (A : Set Formula)
  (h_mcs : SetMaximalConsistent A) (k : Nat) (a b : Rat)
  (h_adj : Adjacent (omega_chain_val fc A h_mcs k).dom a b)
  (phi : Formula) (hphi : phi in (omega_chain_val fc A h_mcs k).g a b)
  (w : Rat) (hw : w in limit_dom fc A h_mcs)
  (haw : a < w) (hwb : w < b)
  : phi in limit_f fc A h_mcs w
```

### 5.2 What It Says

If `phi` is in the interval function `g_k(a, b)` for an adjacent pair `(a, b)` at stage `k`, then for ANY point `w` in the limit domain with `a < w < b`, `phi` is in `limit_f(w)`.

This is proved by strong induction on the first stage `m` where `w` enters the domain (lines 1299-1369). The key mechanism:
1. When `w` is inserted between adjacent `(a', b')` at stage `m`, `g_{m-1}(a', b') subset f_m(w)` (the `g_sub_f_insert` property of `EliminationResult`).
2. The old g-values propagate to the new sub-intervals via `g_sub_g_new`: `g_k(a, b) subset g_{m-1}(a', w)` and `g_k(a, b) subset g_{m-1}(w, b')`.
3. So `phi in g_k(a, b) subset g_{m-1}(a', b') subset f_m(w) = limit_f(w)`.

### 5.3 Interaction with U(T, bot) Processing

When the construction processes `U(top, bot)` (= `next_top`) at a point `x`:
- C5-strong resolution creates a witness `y > x` with `bot in f(y)` -- but `bot` cannot be in any MCS (inconsistency). This means the construction finds an EXISTING witness `y > x` that is the immediate successor. The `bot` guard forces `y` to be immediately adjacent to `x`.
- The guard says `bot in g(a, b)` for all adjacent `(a, b)` between `x` and `y`. Since `bot` cannot be in any MCS, `adj_g_mem_limit_f` implies NO future domain point can be placed between `x` and `y` (any such point would need `bot in limit_f(w)`, which contradicts C0).

**This is the discrete invariant**: once `U(top, bot)` is resolved for a point, its successor is FROZEN -- no future stage will insert points between them.

### 5.4 Can adj_g_mem_limit_f Close the Gap?

Not directly. The frozen guard applies to SPECIFIC adjacent pairs at SPECIFIC stages. The gap between orbit points and pred-chain points is not captured by any single adjacent pair's g-value. The gap is a global phenomenon at the limit level, while `adj_g_mem_limit_f` reasons about local intervals at finite stages.

However, `adj_g_mem_limit_f` IS used critically in the proof of `limit_satisfies_c5_strong` (the strong C5 condition with guard), which is sorry-free. The question is whether similar reasoning can establish something about the global gap structure.

---

## 6. Infrastructure Search Results

### 6.1 Local Search: "cofinal"

| Name | File | Type |
|------|------|------|
| `cofinal_above_iff_succ` | WeakCanonical/StaviConnectives.lean | theorem (weak canonical, different architecture) |
| `cofinal_below_iff_pred` | WeakCanonical/StaviConnectives.lean | theorem |

These are in the weak canonical model infrastructure, not directly usable for the Burgess chronicle.

### 6.2 Local Search: "succ_embed"

All sorry-free except `succ_embed_surjective` (depends on `IsSuccArchimedean`):

| Name | Status |
|------|--------|
| `succ_embed` | Sorry-free (definition) |
| `succ_embed_zero` | Sorry-free |
| `succ_embed_succ` | Sorry-free |
| `succ_embed_pred` | Sorry-free |
| `succ_embed_strictMono` | Sorry-free |
| `succ_embed_no_gap` | Sorry-free |
| `succ_embed_squeeze` | Sorry-free |
| `succ_embed_squeeze_strict` | Sorry-free |
| `succ_embed_surjective` | **SORRY** (via `IsSuccArchimedean`) |

### 6.3 Local Search: "IsSuccArchimedean"

Only the Mathlib class and the sorry-bearing instance `limitDomSubtype_isSuccArchimedean`.

### 6.4 succ_orbit_convex

```lean
private theorem succ_orbit_convex
    (a b : LimitDomSubtype fc A h_mcs) (n : Nat)
    (h_le : a <= b)
    (h_ub : b <= succ^[n] a) :
    exists k <= n, succ^[k] a = b
```

Sorry-free. Proves that if `b` is between `a` and `succ^[n](a)`, then `b` is some iterate of `a`. This is the "convexity" of the succ-orbit -- no domain points can exist between orbit points without being orbit points themselves.

### 6.5 succ_reaches_dom_N

```lean
private theorem succ_reaches_dom_N
    (N : Nat) (a b : LimitDomSubtype fc A h_mcs)
    (ha : a.val in omega_chain_val(N).dom)
    (hb : b.val in omega_chain_val(N).dom)
    (hab : a <= b) :
    exists k, succ^[k] a = b
```

**Has a sorry** at the boundary case (line 1285) where `b` is above `max(dom(N))`. This is the `succ_reaches_dom_N` stage-induction attempt. The non-boundary case (b between two dom(N) points) is proved using `succ_orbit_convex`.

---

## 7. Summary: WHY the Proof Breaks at Step 9

### 7.1 The Core Difficulty

The proof has shown:
- Orbit `{s^[n](a)}` converges to `L` from below
- Pred-chain `{p^[k](pb)}` has values >= `L`, strictly decreasing
- All orbit points < all pred-chain points
- Any limit_dom point with value < `L` and >= `a` is an orbit point

What remains is to derive `False` -- show this structure is impossible. The difficulty:

1. **Temporal axioms are insufficient**: Z1, Prior-UZ, and C5 all give vacuous results in the discrete case (no intermediates between consecutive points, so guards are trivially satisfied).

2. **The constant-MCS case IS eliminable** (Prior-UZ contradiction), but the non-constant case leaves no clear path to contradiction from temporal axioms alone.

3. **The construction-level approach** (showing the omega-chain cannot produce this structure) requires deep interaction with `EliminationResult` internals, specifically tracking how new points relate to the succ-orbit across stages. The key missing lemma: "every point inserted at stage `n` has its limit-domain predecessor as a point from stage `n` or earlier." This is plausible but formally subtle because `pred(p)` in the limit domain may differ from the predecessor at the stage `p` was inserted.

### 7.2 Assessment: Is the Gap Reachable?

**Mathematical answer**: No. The theorem `succ_cofinal` is mathematically true. The limit domain in the discrete case IS order-isomorphic to Z.

**Formal proof status**: The gap scenario cannot be ruled out by the currently available formal infrastructure. The proof requires either:

**(a)** A construction-level argument (~300-600 lines of new infrastructure), showing that the omega-chain's inductive structure prevents gaps. Estimated difficulty: MEDIUM-HIGH.

**(b)** The Reynolds pipeline (Lemmas 6-14, Theorem 14), which proves no gaps in Prior structures using expressive completeness. Estimated difficulty: HIGH (~1000-1500 lines, requires stavi_expressive_completeness).

**(c)** The Henkin model approach (task 129), building a model that is Z-isomorphic by construction. Estimated difficulty: MEDIUM (~300-500 lines, but different proof architecture).

### 7.3 The Minimum Cut

The sorry enters the completeness theorem ONLY through `succ_embed_surjective`, which is called by both `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`. The BUC proof uses `succ_embed_squeeze_strict` (sorry-free) instead. So the minimum intervention needed is either:

1. Close `succ_cofinal` directly (any of approaches a/b/c above), OR
2. Reprove TC and FUC coherence WITHOUT `succ_embed_surjective` -- this requires finding witnesses within the known image range of `succ_embed`, which is the same as proving surjectivity.
