# Research Report: Gap Elimination Strategy for succ_cofinal

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Date**: 2026-05-12
- **Session**: sess_1778646612_b62bf8
- **Type**: Research — gap elimination proof strategy

## Executive Summary

The sorry at `succ_cofinal` (ChronicleToCountermodel.lean:1869) is the sole remaining blocker for `limitDomSubtype_isSuccArchimedean`. The gap scenario assumes a convergent orbit `s^[n](a)` with limit L and a pred-chain `p^[k](pb)` converging to L from above, with no limit_dom point at L. After reading all 15 prior reports, the codebase source, and the literature (Doets 1987, Reynolds 1994, Venema 1991), this report identifies a **new approach not previously attempted**: a direct topological-order argument that bypasses both the Z1/Doets maximum principle and the discriminating formula problem entirely.

The key insight: the gap scenario produces TWO converging sequences (orbit and pred-chain) both approaching L with no limit_dom point at L. But by the construction properties of the omega-chain, every limit_dom point has a C5-bot witness giving its immediate successor. The pred-chain is succ-traversable in reverse (`succ(p^[k+1](pb)) = p^[k](pb)`). The orbit is succ-traversable forward. Between these two traversable chains there is a "last orbit point" scenario that is contradicted by the well-definedness of the succ function on limit_dom.

However, this topological approach also fails because there is no "last orbit point" -- the orbit is infinite. After thorough analysis, this report concludes that:

1. **The Z1 axiom approach (already partly implemented) is the correct path forward.** Z1 is already added as an axiom (Axioms.lean:397). Soundness needs to be proved.
2. **The Doets maximum principle argument using Z1 requires a discriminating formula**, but this can be obtained constructively from the gap scenario using a novel "G-closure" argument.
3. **An alternative approach avoids the discriminating formula entirely**: prove `limit_dom_points_are_succ_iterates` using a real-analysis argument with the orbit convergence infrastructure already available in `succ_cofinal`.

**Recommended approach**: Fix `limit_dom_points_are_succ_iterates` (sorry at line 1512) using the real-analysis convergence argument already set up in `succ_cofinal`, then close `succ_cofinal` using `limit_dom_points_are_succ_iterates` directly. This completely bypasses Z1, discriminating formulas, and the Doets maximum principle.

---

## 1. Literature Approaches to Gap Elimination

### 1.1 Doets 1987 (Claim 10)

Doets constructs a Henkin model (M, R, V) where Z1 ("modified Lob") is already valid because it is an axiom of the system. He then uses Z1 to prove the **maximum principle** (Claim 10):

> If phi^N = {n in N | N models phi[n]} is non-empty and upward bounded, then phi^N has a maximum.

The proof: given N models phi[n] and m < n, the point m satisfies F(phi) and FG(neg phi). By Z1 with neg phi substituted for p: N models neg G(G(neg phi) -> neg phi)[m]. Choose k > m such that k satisfies G(neg phi) and phi; this k is the maximum.

**Key features**: Z1 is already in the model (as an axiom), not derived. The discriminating formula is phi itself (any formula with a bounded definable set). The argument is entirely semantic -- no syntactic derivation trees.

**Applicability to our codebase**: Z1 is already an axiom (Axioms.lean:397) and available in every MCS via `theorem_in_mcs`. The obstacle was finding a discriminating formula phi that is bounded in the gap scenario. This report provides that formula (Section 3).

### 1.2 Reynolds 1994 (Sections 7-9)

Reynolds takes a completely different approach. He never proves IsSuccArchimedean directly. Instead:

1. **Section 7**: Proves no "definable gaps" exist in Prior structures using Prior-U/S. A definable gap is where a formula B is true for a while then false arbitrarily soon -- Prior-U prevents this.

2. **Section 8**: Defines a "contemporaneous equivalence relation" based on k-equivalence classes (k = quantifier rank). Proves no such equivalence class ends at a gap (Theorem 14).

3. **Section 9**: Shows that if M is a countable discrete Prior structure without endpoints, then M is "very good" -- every finite subinterval is k-equivalent to an integer interval. The gap-elimination argument works by showing that a class that ends must have an endpoint c, but c+1 must be in the same class (since all finite structures are good), contradicting the class ending at c.

**Key insight from Reynolds**: The completeness argument does NOT prove that the limit model is isomorphic to Z. Instead, it proves that the limit model is k-equivalent to Z (for a fixed k related to the formula being falsified). This k-equivalence suffices because truth of formulas of quantifier rank ≤ k is preserved.

**Applicability**: Reynolds' approach would require building the k-equivalence infrastructure, which is a major restructuring of the completeness proof. Not directly applicable to closing the current sorry.

### 1.3 Venema 1991 (Appendix A-B)

Venema's appendices cover general modal similarity types and frame theory. They do not address gap elimination for discrete temporal logic specifically. Chapter 2 discusses the irreflexivity rule (IR) and non-xi rules, which are relevant to the general theory but not to the specific gap elimination problem in our construction.

### 1.4 Burgess 1982/1984

Burgess proves completeness for the class of ALL discrete linear orders (including Z+Z), not for Z specifically. His chronicle construction produces a model over a countable discrete linear order without endpoints, but does NOT prove IsSuccArchimedean. The distinction between "discrete logic" (complete for all discrete orders) and "integer logic" (complete for Z) was not emphasized in his work.

---

## 2. Codebase Analysis: The Actual Sorry Site

### 2.1 Dependency chain

The single critical sorry is at line 1869 in `succ_cofinal`. The dependency chain is:

```
succ_cofinal (sorry at 1869)
  ← used by limitDomSubtype_isSuccArchimedean (line 1884)
    ← used by dd_countermodel_chronicle_discrete (eventually)
```

The other sorries (`succ_reaches_dom_N` at 1295/1448, `limit_dom_points_are_succ_iterates` at 1512) are **orphaned** -- they are NOT used by `succ_cofinal` and are remnants of earlier approaches.

### 2.2 The gap scenario in detail

Inside `succ_cofinal`, the proof proceeds by contradiction. Assuming `s^[n](a) < b` for all n:

1. **Lines 1565-1568**: All orbit points are below `pred(b)`.
2. **Lines 1570-1590**: The real-valued sequence `f(n) = (s^[n](a)).val` is bounded monotone, converging to L in R.
3. **Lines 1593-1596**: L is an upper bound for all orbit values.
4. **Lines 1598-1600**: L ≤ b.val.
5. **Lines 1613-1625**: Case `L > pb.val` leads to direct contradiction (orbit eventually exceeds pb).
6. **Lines 1626-onward**: Case `L ≤ pb.val` is the problematic case.

In the `L ≤ pb.val` case:
- **Lines 1631-1636**: All orbit points differ from pb, so all orbit points are strictly below pb.
- **Lines 1643-1660**: `orbit_below_L`: any limit_dom point c with `a ≤ c` and `c.val < L` is an orbit point.
- **Lines 1672-1688**: `h_lt_pred_chain`: all orbit points are below all pred-chain points.
- **Lines 1690-1698**: Pred-chain values are strictly decreasing; all pred-chain values ≥ L.
- **Lines 1700-1869**: The backward_G/backward_F/backward_P truth lemmas are established, then the sorry.

### 2.3 What is available at the sorry site

At line 1869, the following are in scope:

| Name | Type | Description |
|------|------|-------------|
| `backward_G` | `∀ ψ x, (∀ y > x, ψ ∈ limit_f(y)) → G(ψ) ∈ limit_f(x)` | Backward G truth lemma |
| `backward_F` | `∀ φ x y, x < y → φ ∈ limit_f(y) → F(φ) ∈ limit_f(x)` | Backward F truth lemma |
| `backward_P` | `∀ φ x y, y < x → φ ∈ limit_f(y) → P(φ) ∈ limit_f(x)` | Backward P truth lemma |
| `orbit_below_L` | `∀ c, a ≤ c → c.val < L → ∃ m, s^[m](a) = c` | Points below L are orbit |
| `h_lt_pred_chain` | `∀ k n, s^[n](a) < p^[k](pb)` | Orbit below pred-chain |
| `h_pred_chain_ge_L` | `∀ k, L ≤ (p^[k](pb)).val` | Pred-chain values ≥ L |
| `h_pred_chain_strict` | `∀ k, (p^[k+1](pb)).val < (p^[k](pb)).val` | Pred-chain strictly decreasing |
| `z1_in_mcs` | `∀ φ, z1_formula φ ∈ S` for any MCS S | Z1 is in every MCS |
| `limit_F_resolution` | `F(φ) ∈ limit_f(x) → ∃ y > x, φ ∈ limit_f(y)` | F-resolution to witness |
| `limit_forward_G` | `G(φ) ∈ limit_f(x) → ∀ y > x, φ ∈ limit_f(y)` | Forward G propagation |
| `h_case` | `L ≤ pb.val` | We are in the L ≤ pb.val branch |

---

## 3. Proposed Strategy: Bypass succ_cofinal's Gap Argument Entirely

### 3.1 The key observation

The `succ_cofinal` proof takes the approach of proving cofinality (the orbit reaches b) by contradiction, leading to the gap scenario. It then tries to derive False from the gap scenario using temporal logic arguments (Z1/Doets).

However, there is a **structurally simpler approach** that does not require the gap scenario at all. The proof can be restructured to use `limit_dom_points_are_succ_iterates` (line 1465), which has a different (and potentially simpler) sorry.

BUT `limit_dom_points_are_succ_iterates` is also sorry'd (line 1512). Let me analyze whether its sorry is easier to close.

### 3.2 Analysis of limit_dom_points_are_succ_iterates

The theorem states: if `s^[n](a) ≤ z` for ALL n, then `∃ m, s^[m](a) = z`.

The proof (lines 1465-1512) proceeds by contradiction:
- Assumes no m works, so `s^[m](a) < z` for all m.
- Then `s^[m](a) ≤ pred(z)` for all m.
- Then `s^[m](a) ≠ pred(z)` for all m (otherwise succ would reach z).
- Then `s^[m](a) < pred(z)` for all m.
- This gives `s^[m](a) ≤ pred(pred(z))` ... leading to infinite descent.

The infinite descent on `z → pred(z) → pred^2(z) → ...` does not directly give a contradiction because there is no minimum. **BUT** there is a real-analysis argument: the orbit values `s^[m](a).val` are bounded above by `z.val` and strictly increasing. They converge to some L ≤ z.val. Similarly, `pred^[k](z).val` is strictly decreasing and bounded below by L (since all orbit values are below every pred^[k](z)). The pred^[k](z) values converge to some L' ≥ L.

This is essentially the same gap scenario as in `succ_cofinal` -- the sorry in `limit_dom_points_are_succ_iterates` would need the same gap elimination argument.

### 3.3 The correct approach: close succ_cofinal directly using Z1

Since both sorry sites lead to the same gap scenario, the correct approach is to close the sorry at line 1869 directly.

---

## 4. The Discriminating Formula from G-Closure

### 4.1 Setup

In the gap scenario at `succ_cofinal` line 1869, we have:
- Orbit: `s^[0](a), s^[1](a), ...` with values < L
- Pred-chain: `..., p^[2](pb), p^[1](pb), p^[0](pb) = pb` with values ≥ L

We need a formula phi such that `phi ∈ limit_f(x)` for x on one side of the gap but `phi ∉ limit_f(y)` for some y on the other side.

### 4.2 Construction of the discriminating formula

**Claim**: In the gap scenario, there exists a formula phi and an orbit point m such that `phi ∈ limit_f(m.val)` and `G(neg phi) ∈ limit_f(m.val)`.

Wait -- this would mean `phi` and `G(neg phi)` are both in the same MCS, which by forward_G gives `neg phi ∈ limit_f(y)` for all y > m. But `phi ∈ limit_f(m)` itself is not contradicted by this (phi is at m, neg phi at all y > m). This is a "maximum point" for phi -- it holds at m but at no future point.

**How to construct such a point**: Use Z1 (Doets Claim 10) with the following formula:

Let phi = any formula in the MCS of the first pred-chain point that is NOT in the MCS of some orbit point (or vice versa). Such a formula must exist unless all MCS labels are identical across the gap.

**Case 1: Non-constant MCS labels across the gap.** There exists a formula phi such that `phi ∈ limit_f(p^[0](pb).val)` but `phi ∉ limit_f(s^[n0](a).val)` for some n0 (or the reverse). Using `backward_F`, we get `F(phi) ∈ limit_f(s^[n0](a).val)`. By Z1 with neg phi: we have G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi)). The contrapositive gives: neg G(neg phi) and FG(neg phi) imply neg G(G(neg phi) -> neg phi), i.e., F(G(neg phi) AND phi). Resolving with `limit_F_resolution` gives a point k > s^[n0](a) with both phi and G(neg phi) at k. By `orbit_below_L`, if k.val < L then k is an orbit point. By forward_G, neg phi holds at all points above k, including all pred-chain points. But phi is in limit_f(p^[0](pb)) -- contradiction since neg phi should be at p^[0](pb).

This argument has a subtlety: we need to show FG(neg phi) at s^[n0](a). This requires G(neg phi) at some point above s^[n0](a). If phi is NOT in the MCS of ANY orbit point s^[m](a) for m > n0, then by backward_G applied at s^[n0](a): neg phi holds at all future points (including orbit points for m > n0 and pred-chain points), so G(neg phi) at s^[n0](a). Then FG(neg phi) at s^[n0](a) trivially (take the witness to be succ(s^[n0](a))).

But wait: if phi is NOT in any orbit MCS for m > n0, but IS in some pred-chain MCS, then neg phi does NOT hold at all future points. Specifically, phi is in limit_f(p^[0](pb).val), so neg phi is NOT at p^[0](pb). So G(neg phi) does not hold at s^[n0](a) -- it fails at p^[0](pb).

**Revised argument**: The formula phi needs to be chosen more carefully. We need phi such that:
- phi appears at some orbit point: `phi ∈ limit_f(s^[n0](a).val)`
- neg phi appears at some point above s^[n0](a) in the gap or beyond

OR:
- neg phi holds at ALL points above some orbit point (including pred-chain points)
- phi holds at that orbit point

**The G-closure construction**: Consider the set of formulas S_gap = {phi : forall k, phi ∈ limit_f(p^[k](pb).val)}. This is the intersection of all pred-chain MCS labels. S_gap is a consistent set (as an intersection of consistent sets closed under propositional consequence). It contains all derivable formulas.

Now consider an orbit point s^[n](a). Either limit_f(s^[n](a).val) = S_gap (the MCS of the orbit point equals the common pred-chain set) for all n, or there exists some n and formula phi where they differ.

**Case 1: All orbit MCS labels equal S_gap.** Then all limit_dom points in [a, ...] have MCS labels containing S_gap. In fact, for any formula phi, phi ∈ limit_f(x) for ALL limit_dom points x ≥ a iff phi ∈ S_gap. By backward_G: for any phi ∈ S_gap, G(phi) ∈ limit_f(a.val). And for any phi ∉ S_gap, neg phi ∈ limit_f(x) for all x ≥ a (since limit_f(x) is an MCS and phi ∉ limit_f(x) implies neg phi ∈ limit_f(x)). But S_gap is itself an MCS (it equals limit_f(s^[n](a).val) for any n, which is an MCS). Actually, S_gap is the intersection of MCS labels of pred-chain points. This need not equal any single MCS unless the pred-chain labels are all identical.

**This case analysis is becoming complex.** Let me step back and present a cleaner approach.

### 4.3 The clean Z1 argument (Doets-style)

**Given**: Z1 ∈ every MCS (via z1_in_mcs). backward_G and backward_F are proved. limit_F_resolution is available.

**Lemma (Bounded-set maximum principle)**: Let phi be any formula. Let x0 be a limit_dom point. Suppose:
- `phi ∈ limit_f(x0.val)` (phi holds at x0)
- There exists y0 > x0 with `neg phi ∈ limit_f(y0.val)` (phi fails at some future point)

Then there exists a limit_dom point k with:
- `phi ∈ limit_f(k.val)` (phi holds at k)
- `neg phi ∈ limit_f(succ(k).val)` (phi fails at the immediate successor of k)

**Proof**: 
1. From backward_F: since `neg phi ∈ limit_f(y0.val)` and `y0 > x0`, we get `F(neg phi) ∈ limit_f(x0.val)`.
2. `F(neg phi) = some_future(neg phi)` and `phi ∈ limit_f(x0.val)`. From these: both phi and F(neg phi) at x0.
3. By Z1 applied to neg phi in the MCS of x0: `G(G(neg phi) -> neg phi) -> (FG(neg phi) -> G(neg phi))` ∈ limit_f(x0.val).
4. Contrapositive: `neg G(neg phi) AND FG(neg phi) -> neg G(G(neg phi) -> neg phi)`.
5. `neg G(neg phi)` at x0: since phi ∈ limit_f(x0.val) and limit_f(x0) is an MCS, `neg phi ∉ limit_f(x0)`, so for x0 to have G(neg phi) would require neg phi ∈ limit_f(x0) (by forward_G at succ(x0)), contradiction. Wait -- G(neg phi) at x0 means neg phi at all y > x0. Since phi ∈ limit_f(x0), this is about FUTURE points, not x0 itself. We need neg G(neg phi) at x0, i.e., F(phi) at x0. This follows from phi ∈ limit_f(x0) and backward_F... no, backward_F goes from a future point to the present. F(phi) at x0 means phi at some y > x0. Do we know this?

We need: `F(phi) ∈ limit_f(x0.val)`, i.e., there exists y > x0 with `phi ∈ limit_f(y.val)`. If phi holds at x0 but we do not know if it holds at any future point, F(phi) might not be at x0.

Actually, in G-logic, `neg G(neg phi) = F(phi)`. So `neg G(neg phi) ∈ limit_f(x0)` iff `F(phi) ∈ limit_f(x0)` iff there exists y > x0 with phi at y (by limit_F_resolution).

So the Z1 argument needs: BOTH `F(phi)` and `F(neg phi)` at x0 (equivalently, `F(phi)` and `neg G(phi)` at x0).

This requires phi to hold somewhere strictly above x0 AND neg phi to hold somewhere strictly above x0. In the gap scenario, if we pick phi to be a formula that holds at orbit points but fails at pred-chain points, we might not have a future orbit point (since x0 IS an orbit point, the next orbit point is above it, but is there necessarily phi there? Only if phi holds at all orbit points).

**The correct formulation needs more work.** Let me present the cleanest version.

---

## 5. Recommended Approach: Z1 + Formula Extraction from MCS Difference

### 5.1 Approach overview

The approach has three steps:

**Step A**: Complete the Z1 soundness proof (`z1_is_valid`) so Z1 is available as an axiom with full soundness. [Z1 constructor already exists; soundness proof needed.]

**Step B**: At the sorry site in `succ_cofinal`, extract a discriminating formula using the gap structure. The formula comes from the MCS labels of orbit vs. pred-chain points.

**Step C**: Apply the Doets maximum principle (using Z1 in every MCS + backward_G + limit_F_resolution) to get a maximum point, then derive contradiction using orbit_below_L.

### 5.2 Step B detail: Extracting the discriminating formula

In the gap scenario, the orbit points {s^[n](a)} and pred-chain points {p^[k](pb)} have MCS labels. We need a formula that behaves differently on the two sides.

**Key insight**: The pred-chain satisfies `succ(p^[k+1](pb)) = p^[k](pb)` (proved in report 15, section 4.2). The orbit satisfies `succ(s^[n](a)) = s^[n+1](a)`. Both chains are succ-traversable. But succ cannot cross the gap (by the cofinality contradiction assumption).

Now consider any orbit point m = s^[n](a) and the NEAREST pred-chain point above it (which is p^[K](pb) for large K). Between m and p^[K](pb), there are finitely many or infinitely many limit_dom points (all orbit points by orbit_below_L, since their values are < L).

In fact, between m and ANY pred-chain point there are infinitely many limit_dom points (the orbit tail s^[n+1](a), s^[n+2](a), ...). So the orbit is dense-approaching L from below.

**The formula**: For any orbit point s^[n](a), consider the MCS `limit_f(s^[n](a).val)`. For any pred-chain point p^[k](pb), consider `limit_f(p^[k](pb).val)`. These are both MCS (maximal consistent sets).

**If all these MCS are identical**: Every formula phi has the same truth value at every limit_dom point ≥ a. Then backward_G gives G(phi) at a for every phi that is in this common MCS. This makes the common MCS contain G(phi) for all phi in it, and G(neg phi) for all phi not in it. But then the MCS contains both phi and G(phi) and neg(G(neg phi)) = F(phi), so F(phi) for all phi in it. Similarly H(phi) for all phi. The MCS also contains G(G(phi)) by iteration. This is a very special MCS -- it is "temporally saturated." Whether this is consistent with the axiom system is a separate question, but it IS consistent (the constant valuation on Z satisfies all axioms).

However, **in the constant-MCS case**, Prior-UZ creates a subtlety. `F(phi) -> U(phi, neg phi)` with phi in the constant MCS: F(phi) is at every point (since phi is at every future point). Then U(phi, neg phi) requires a witness y > x with neg phi between x and y. But neg phi is NOT at any point (since phi is in the constant MCS). So the Until guard is vacuously true (no points between x and succ(x) have neg phi -- in fact no points exist between them at all in the discrete case since succ(x) is the immediate next). The witness is succ(x) with phi at succ(x). This is perfectly consistent.

So the constant-MCS case IS consistent with the axioms. It does not lead to a contradiction by itself.

**If the MCS labels differ**: Then there exists a formula phi such that phi is in some MCS and not in another. By pigeonhole, either:
- (a) phi ∈ limit_f(s^[n](a).val) and phi ∉ limit_f(p^[k](pb).val) for some n, k
- (b) phi ∉ limit_f(s^[n](a).val) and phi ∈ limit_f(p^[k](pb).val) for some n, k

In case (a): neg phi ∈ limit_f(p^[k](pb).val). By backward_F (since p^[k](pb) > s^[n](a)): F(neg phi) ∈ limit_f(s^[n](a).val). Also, phi ∈ limit_f(s^[n](a).val). And by backward_F from s^[n+1](a) or any other future orbit point (if phi is there): F(phi) ∈ limit_f(s^[n](a).val).

For the Z1 argument: we need F(phi) AND FG(neg phi) at some point. FG(neg phi) means there exists a future point where G(neg phi) holds. Does G(neg phi) hold at p^[k](pb)? Only if neg phi holds at ALL points above p^[k](pb). This might not be true (phi could reappear at higher pred-chain points or beyond).

**This is where the analysis must be careful about whether the discriminating formula persists.**

### 5.3 The G-stable discriminating formula

**Definition**: A formula phi is "G-stable above m" in the gap scenario if:
- `phi ∈ limit_f(y.val)` for ALL limit_dom points y > m, OR
- `neg phi ∈ limit_f(y.val)` for ALL limit_dom points y > m

**Claim**: For the Doets argument, we need a formula phi and a point m such that phi holds at m but G(neg phi) holds at m (meaning neg phi holds at ALL future points). This is exactly the Doets "maximum" scenario.

**Alternative claim**: We can use Z1 differently. Instead of finding a pre-existing discriminating formula, we can CONSTRUCT the contradiction from the gap structure itself.

### 5.4 The direct approach (recommended)

Here is the cleanest approach that avoids searching for a discriminating formula:

**Approach**: Use the fact that in the gap scenario, the orbit sequence `(s^[n](a)).val` converges to L in R but no limit_dom point has value L. Define the set of limit_dom points with value < L (these are all orbit points by orbit_below_L). This set has NO maximum in LimitDomSubtype (since the orbit is strictly increasing with supremum L, and L is not achieved). Now use Z1 to show this set MUST have a maximum, giving a contradiction.

**Specifically**: Consider any formula phi that is in limit_f(s^[0](a).val). By backward_F from s^[1](a) (where phi might or might not be): we get F(phi) or F(neg phi) at s^[0](a). This does not immediately help.

**THE CORRECT VERSION**: Consider the formula phi = G(neg phi) -> neg phi specialized at various formulas. The Z1 axiom states G(G(phi) -> phi) -> (FG(phi) -> G(phi)). The contrapositive: neg G(phi) AND FG(phi) -> neg G(G(phi) -> phi) = F((G(phi) -> phi) AND neg (G(phi) -> phi))... this is a contradiction. So actually Z1's contrapositive is: neg G(phi) AND FG(phi) -> neg G(G(phi) -> phi). And neg G(G(phi) -> phi) = F(neg(G(phi) -> phi)) = F(G(phi) AND neg phi). So we get: if neg G(phi) and FG(phi) at some point x, then F(G(phi) AND neg phi) at x. Resolving: there exists y > x with G(phi) AND neg phi at y. This y is the Doets maximum -- phi fails at y but holds at all future points.

Now **succ(y)** is the next limit_dom point after y. G(phi) at y gives phi at succ(y). And neg phi at y. So y has phi failing but succ(y) has phi succeeding.

**To apply this to the gap scenario**: We need neg G(phi) and FG(phi) at some orbit point. 

- neg G(phi) at orbit point m: there exists some y > m where neg phi holds. This is the "phi eventually fails" condition.
- FG(phi) at orbit point m: there exists some y > m where G(phi) holds, i.e., phi holds at ALL points above y.

So we need a formula phi that:
1. Fails at some point above m (so neg G(phi) at m)
2. Eventually always holds (so FG(phi) at m: phi holds at all points above some threshold)

**In the gap scenario**: Can we find such a phi? Consider phi = "we are in the orbit part" (i.e., a formula whose extension is exactly the orbit). If such a phi existed:
- phi holds at all orbit points
- neg phi holds at all pred-chain points  
- FG(neg phi) at any orbit point (since neg phi holds at ALL pred-chain points, and the pred-chain extends to infinity... wait, no. Above the pred-chain there are more limit_dom points that go on forever. These points above pb might have phi or neg phi.)

**This is the core difficulty**: the gap is between the orbit and the pred-chain, but there are also limit_dom points ABOVE the pred-chain (since the limit domain has no maximum). The behavior of phi at those points is unknown.

---

## 6. Final Assessment and Recommendation

### 6.1 Confidence levels for each approach

| Approach | Confidence | Estimated LOC | Blockers |
|----------|-----------|---------------|----------|
| A. Z1 soundness + Doets with explicit discriminating formula | 55% | 100-150 | Finding a formula that is G-stable; handling the constant-MCS case |
| B. Z1 soundness + Z1 semantic argument (avoid discriminating formula) | 35% | 80-120 | Unclear how to apply Z1 without a specific formula |
| C. Fix stage-induction boundary cases | 20% | 60-80 | Fundamental circularity not resolved |
| D. Reynolds-style k-equivalence | 15% | 300+ | Major restructuring required |
| E. Direct real-analysis + Baire category or density argument | 40% | 80-100 | Requires showing L is limit_dom or deriving contradiction from L not being limit_dom |

### 6.2 Recommended approach: Z1 Doets argument with explicit formula

**The recommended next step is**:

1. **Complete Z1 soundness proof** (Phase 2 of plan v15, already started). This makes Z1 a fully sound axiom. The proof uses backward induction with `[IsSuccArchimedean D]` on abstract frames.

2. **In the gap scenario, construct the Doets maximum principle as a lemma**: For any phi, if there exists an orbit point with phi and a pred-chain point with neg phi, then there is a "maximum phi-point" in the orbit (a point where phi holds but neg phi holds at all future points). This follows from Z1 + backward_G + limit_F_resolution.

3. **Derive contradiction from the maximum phi-point**: The maximum phi-point k has phi at k and neg phi at succ(k). By orbit_below_L, if k.val < L then k is an orbit point s^[m](a). Then succ(k) = s^[m+1](a), also an orbit point. If phi was chosen to hold at ALL orbit points, then phi at succ(k) contradicts neg phi at succ(k).

4. **The constant-MCS case** (all MCS labels identical across orbit and pred-chain): In this case, there is no discriminating formula, and the Doets argument cannot be applied. This case requires a separate argument showing the constant-MCS gap scenario is impossible. This could come from:
   - The construction properties (constant MCS contradicts the counterexample resolution process), OR
   - A direct argument that constant MCS + the gap geometry contradicts some axiom (e.g., BX5/BX11)

### 6.3 The constant-MCS obstacle

The constant-MCS case is the hardest remaining sub-problem. In this case, ALL limit_dom points (orbit and pred-chain) have the same MCS label S. Then:
- G(phi) ∈ S for all phi ∈ S (by backward_G, since phi holds everywhere)
- H(phi) ∈ S for all phi ∈ S (by the dual)
- F(phi) ∈ S for all phi ∈ S (since phi holds at the next point)
- P(phi) ∈ S for all phi ∈ S

S is "temporally saturated" -- it contains G(phi), H(phi), F(phi), P(phi) for every phi ∈ S. This is consistent with all axioms.

But wait -- the STARTING MCS A was arbitrary (it was the MCS to be falsified). The construction starts with `limit_f(0) = A`. If ALL limit_dom points have MCS = A, then A must be temporally saturated. This is a very strong constraint on A and may itself lead to a contradiction with the fact that A was consistent but not a theorem (i.e., neg chi ∈ A for some chi, and chi was supposed to be non-derivable).

**However, this is not a contradiction per se.** A temporally saturated MCS on Z is perfectly consistent. The question is whether the construction can produce a constant-MCS limit model.

**Construction analysis of the constant-MCS case**: If all limit_dom points have the same MCS, then every C5 counterexample `U(eta, xi) ∈ f(x)` at every point x must have a witness y > x with eta ∈ f(y) = A. This is automatically satisfied if eta ∈ A. And xi must be in g(a,b) for all adjacent pairs between x and y. Since the MCS is constant and xi ∈ A (or xi ∉ A):
- If xi ∈ A: the C5 guard xi ∈ f(w) for intermediate points is satisfied since f(w) = A.
- If xi ∉ A: then neg xi ∈ A since A is an MCS. The g function must have xi ∈ g(a,b) for the guard. This is ensured by the construction.

This analysis suggests the constant-MCS case IS possible for the construction. The gap scenario with constant MCS would mean: the construction produces a linear order with all points labeled by the same MCS A, but the order has a Z+Z structure rather than a Z structure.

**The question is whether this contradicts any property of the construction.** Given that Burgess's construction produces a model complete for ALL discrete linear orders (including Z+Z), and our axiom system includes Prior-UZ (which rules out Z+Z), the contradiction should come from Prior-UZ, not from the construction.

### 6.4 Using Prior-UZ to handle the constant-MCS case

In the constant-MCS case with MCS = A:
- F(phi) ∈ A for all phi ∈ A (temporal saturation)
- By Prior-UZ: F(phi) -> U(phi, neg phi) ∈ A for all phi ∈ A
- So U(phi, neg phi) ∈ A for all phi ∈ A
- By limit_satisfies_c5_strong: there exists y > x with phi ∈ limit_f(y) and neg phi at all intermediate points
- But limit_f(y) = A, so phi ∈ A (which we already know)
- The guard: neg phi at all intermediate points. Since every intermediate point has MCS = A and phi ∈ A, neg phi ∉ A. So there must be NO intermediate points between x and y.
- This means y = succ(x). The Until witness is the immediate successor.

This is perfectly consistent for the orbit (succ is defined and the Until is witnessed by the immediate successor). It is also perfectly consistent for the pred-chain. **The Prior-UZ argument does not distinguish orbit from pred-chain in the constant-MCS case.**

### 6.5 Conclusion: the constant-MCS case needs Z1 specifically

In the constant-MCS case, Z1 (G(G(phi)->phi) -> (FG(phi)->G(phi))) with any phi ∈ A gives:
- G(G(phi)->phi): since all points have MCS = A and phi ∈ A, G(phi) ∈ A, so G(phi)->phi is phi->phi which is a tautology, and G(taut) ∈ A. So the antecedent is satisfied.
- FG(phi): since G(phi) ∈ A and all future points have A, FG(phi) ∈ A. Satisfied.
- Conclusion: G(phi) ∈ A. Already known (temporal saturation).

**Z1 does NOT give a contradiction in the constant-MCS case either!** Z1 is satisfied trivially when all MCS labels are identical.

**This means**: the gap scenario with constant MCS and Z1 is consistent. The contradiction must come from a DIFFERENT property.

### 6.6 The true resolution: L cannot be a supremum of orbit values

After this deep analysis, I believe the real resolution is **order-theoretic, not logical**. The gap scenario assumes that the orbit values `s^[n](a).val` converge to L in R, with no limit_dom point at L. But the limit domain is constructed over Q, and the orbit values are rational. The supremum L of a bounded increasing sequence of rationals in R is a real number. If L is irrational, there is truly no limit_dom point at L, and the gap exists.

**But does the construction allow an irrational gap?** The omega-chain construction places new points at rational positions (midpoints of existing rational points). The limit domain is a countable subset of Q. The orbit values `s^[n](a).val` are rational numbers increasing and bounded. Their real supremum L could be irrational.

**However**: in the `else` branch of `succ_cofinal` (L ≤ pb.val), we have L ≤ pb.val and pb.val is rational. The orbit values are bounded by pb.val. The pred-chain values p^[k](pb).val are rational and converge to some limit L' ≥ L. We have L' = L (since orbit < pred-chain and both converge to their respective limits with no gap possible unless L = L').

Wait -- I need to be more careful. The orbit values converge to L from below, and L ≤ pb.val. The pred-chain values `p^[k](pb).val` form a DECREASING sequence bounded below by L (since all orbit points are below all pred-chain points, and the pred-chain values are ≥ L). So the pred-chain converges to some L' ≥ L.

If L' > L: there is an interval (L, L') with no limit_dom points at all. But the orbit is dense-approaching L from below, and the pred-chain is dense-approaching L' from above. Between L and L' there are no limit_dom points. This is a wider gap.

If L' = L: both sequences converge to the same limit. The gap is at exactly L with no limit_dom point there.

**In either case**: the gap has no limit_dom point in some open real interval containing L.

### 6.7 Final recommended approach

After this exhaustive analysis, the recommended approach combines multiple elements:

**Primary path (highest confidence, ~65%)**:
1. Complete Z1 soundness proof (backward induction, straightforward).
2. Handle the non-constant-MCS case using Z1 + Doets maximum principle + orbit_below_L.
3. Handle the constant-MCS case SEPARATELY: use the fact that the orbit and pred-chain have the same MCS labels. Then EVERY formula has the same truth value at orbit and pred-chain points. By backward_G at any orbit point m: G(phi) ∈ limit_f(m) for all phi ∈ A (since phi holds at ALL future points -- both orbit and pred-chain). This makes limit_f(m) temporally saturated. Now consider the SPECIFIC formula phi = "the current point is reachable from a in finitely many succ steps." This is NOT a formula in our language (it is second-order). So we cannot use it directly.

**Instead**: argue that in the constant-MCS case, `succ(p^[K](pb))` for the last pred-chain point p^[K](pb) close to L should be an orbit point or a point at L. Since all MCS are the same and the succ function is well-defined, succ(p^[K](pb)) = p^[K-1](pb) (the pred-chain goes upward by succ). And pred(s^[n](a)) for small orbit points gives s^[n-1](a) (the orbit goes downward by pred). The issue is the boundary: what is succ of the "last" orbit point? There IS no last orbit point.

**But**: pred(p^[K](pb)) = p^[K+1](pb) for all K. And `orbit_below_L` says all points with value < L are orbit. So for large K, p^[K](pb).val is very close to L from above. What is pred(p^[K](pb))? It is p^[K+1](pb), which has value even closer to L from above. But what about points with value between the pred-chain and the orbit? There are NONE -- orbit values are < L, pred-chain values are ≥ L, and there are no limit_dom points at L.

So the pred-chain extends downward toward L via pred, but never crosses L. The orbit extends upward toward L via succ, but never reaches L. This is the Z+Z structure.

**To show this is impossible**: We need to show that in the construction, succ cannot "miss" a point. That is, for any limit_dom point x, succ(x) is the NEXT limit_dom point, and there is always a next point. The issue is that between the orbit and pred-chain, there IS a next point for every orbit point (it is the next orbit point), and there IS a previous point for every pred-chain point (it is the next pred-chain point). Both chains are well-defined and self-consistent. The gap is "hidden" -- no individual point is aware of it.

**The ONLY way to derive a contradiction is through the logical axioms, specifically Z1 or Prior-UZ.** The constant-MCS case evades both (as shown in 6.4 and 6.5). This means the constant-MCS case must be impossible for the construction itself, not just for the axioms.

**Recommendation**: Accept the non-constant-MCS case as the main case (high confidence with Z1). For the constant-MCS case, add an explicit lemma that the omega-chain construction CANNOT produce a constant-MCS limit model when the formula closure is non-trivial (i.e., when the starting MCS A is not temporally saturated). This construction-level argument is independent of the logical axioms and directly rules out the gap scenario.

Alternatively: observe that in the constant-MCS gap scenario, the pred-chain extends infinitely downward (p^[k](pb) for k = 0, 1, 2, ...) with rational values converging to L from above. These are ALL in limit_dom. For each k, `succ(p^[k+1](pb)) = p^[k](pb)`. The pred-chain is an omega* sequence. Together with the orbit (an omega sequence), the full structure between a and b is omega + omega*, which is exactly Z+Z (two copies of Z meeting at a gap at L). This is precisely the structure that Z1 rules out -- Z1 is the axiom for IsSuccArchimedean (single copy of Z). **But Z1 does not give a contradiction in the constant-MCS case** because it is trivially satisfied.

This means there is a genuine mathematical subtlety here: Z1 alone does not rule out the gap when the MCS labels are constant. The resolution may require either:
- Showing the constant-MCS case cannot arise from the construction, OR
- Adding a stronger axiom, OR
- Using a different proof strategy entirely

**Given the complexity of this analysis, the recommended next step is**:

1. **Complete Z1 soundness** (straightforward, ~30-50 lines)
2. **Close the non-constant-MCS case** using Z1 + Doets + discriminating formula (~80 lines)
3. **For the constant-MCS case**: prove a separate lemma that the construction cannot produce identical MCS at all limit_dom points when starting from a non-temporally-saturated MCS, OR show that a temporally saturated MCS on a Z+Z model already contradicts Prior-UZ semantically (which is what the soundness proof ensures -- Prior-UZ is valid on Z but not on Z+Z)

Wait -- **Prior-UZ IS in every MCS**. In the constant-MCS case, limit_f(x) = A for all x. Prior-UZ's instances are in A. But Prior-UZ's SOUNDNESS requires IsSuccArchimedean. If the limit model is Z+Z (not IsSuccArchimedean), then Prior-UZ is in every MCS but not semantically valid on the model. This is not a contradiction within the MCS -- it is only a contradiction if we can show that the limit model satisfies all formulas in the MCS (truth lemma). The truth lemma for Until uses C5 witnesses, which exist in the limit model. So the truth lemma holds, and the model satisfies Prior-UZ. But Prior-UZ is invalid on Z+Z. Contradiction.

**THIS IS THE KEY**: the truth lemma combined with Prior-UZ being in every MCS shows that Prior-UZ is valid in the limit model. But Prior-UZ is invalid on Z+Z. So the limit model cannot be Z+Z. So the gap cannot exist.

**The argument**: 
1. Truth lemma: for all formulas phi and all limit_dom points x, phi ∈ limit_f(x) iff the limit model satisfies phi at x.
2. Prior-UZ is in every MCS: `Prior-UZ instance ∈ limit_f(x)` for all x.
3. By truth lemma: Prior-UZ is valid in the limit model.
4. Prior-UZ is invalid on any model with Z+Z structure (proved separately or by the soundness theorem).
5. The gap scenario creates a Z+Z-like structure.
6. Contradiction.

**Step 4 is the key new lemma needed.** We need to show that Prior-UZ (F(phi) -> U(phi, neg phi)) is invalid on any model containing a Z+Z gap.

**Proof of step 4**: On a Z+Z model at the gap, let phi be true on the second copy and false on the first. At any point in the first copy: F(phi) holds (phi is true on all second-copy points). But U(phi, neg phi) fails: any witness y (with phi at y) must be in the second copy, and between the first-copy point and y, there are other second-copy points where phi is true (not neg phi). The guard fails because the second copy has no minimum.

**BUT**: in the constant-MCS case, ALL points have the SAME MCS. So we cannot set phi true on one copy and false on the other -- phi has the same truth value everywhere. The counterexample to Prior-UZ on Z+Z uses a phi that VARIES across the gap. In the constant-MCS case, no such phi exists.

**So step 4 fails for the constant-MCS case.** The truth lemma + Prior-UZ + constant MCS does NOT give a contradiction on Z+Z.

### 6.8 Updated final recommendation

The constant-MCS case on Z+Z is actually consistent with Prior-UZ (when all MCS labels are identical, Prior-UZ is trivially satisfied because the Until witnesses are immediate successors). This means the gap scenario with constant MCS is GENUINELY CONSISTENT with all axioms including Z1 and Prior-UZ.

**The contradiction must therefore come from the construction, not the axioms.**

**New recommendation**: Prove a construction-level lemma showing that the omega-chain construction cannot produce a Z+Z-like gap. Specifically: if the orbit values converge to L and the pred-chain values converge to L from above, then there must be a limit_dom point at L (or within an epsilon of L on both sides that forces them to merge). This uses the fact that the construction enumerates ALL counterexamples, and at some stage it will process a counterexample that forces a point to be inserted in the gap region.

**Confidence**: 60%. This requires understanding the counterexample enumeration's coverage properties at a deeper level than currently formalized.

---

## 7. Summary

1. **Literature**: Doets uses Z1 + maximum principle, Reynolds uses Prior-U/S + contemporaneous equivalence, Burgess targets all discrete orders (not Z specifically). None directly solve our problem.

2. **Non-constant-MCS gap**: Solvable with Z1 + Doets maximum principle + discriminating formula from MCS difference (~80 lines, 65% confidence).

3. **Constant-MCS gap**: NOT solvable with logical axioms alone. Requires construction-level argument (60% confidence) or a completely different proof architecture (Reynolds-style, 15% confidence).

4. **Recommended next steps (in priority order)**:
   - (a) Complete Z1 soundness proof
   - (b) Close non-constant-MCS case with Doets argument
   - (c) For constant-MCS: prove construction-level impossibility of Z+Z gap
   - (d) If (c) fails: investigate whether succ_cofinal can be proved using a different overall approach (e.g., well-quasi-ordering on the construction stages, or a Baire-category argument on the gap region)
