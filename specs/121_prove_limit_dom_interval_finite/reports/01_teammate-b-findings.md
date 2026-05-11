# Teammate B Findings: Alternative Approaches for limitDomSubtype_Icc_finite

**Task**: 121 — Prove bounded intervals in `LimitDomSubtype` are finite
**Angle**: Alternative proof strategies (non-paper-dependent approaches)
**Date**: 2026-05-10

## Key Findings

### 1. Mathlib's LinearLocallyFinite Goes the WRONG Direction

The imported file `Mathlib.Order.SuccPred.LinearLocallyFinite` provides:
- `LocallyFiniteOrder → SuccOrder` (not what we need)
- `LocallyFiniteOrder → PredOrder` (not what we need)
- `LocallyFiniteOrder + SuccOrder → IsSuccArchimedean` (not what we need)

The direction we need is: **SuccOrder + PredOrder → interval finiteness**. Mathlib does NOT provide this direction. There is no instance `SuccOrder + PredOrder → LocallyFiniteOrder` because this requires `IsSuccArchimedean`, which is circular for our use case.

### 2. Circular Dependency Map

```
limitDomSubtype_Icc_finite (SORRY — what we need to prove)
    ↓ used by
limitDomSubtype_isSuccArchimedean (uses Icc_finite + pigeonhole)
    ↓ would unlock
LocallyFiniteOrder (via IsSuccArchimedean + SuccOrder + PredOrder)
    ↓ would give
Set.finite_Icc (what we need)
```

We cannot use `IsSuccArchimedean`, `LocallyFiniteOrder`, or any Mathlib lemma that requires them.

### 3. Omega Chain Structural Analysis

**Each step adds at most 1 point**: `EliminationResult` uses `Finset.subset_insert y χ.dom` — the new domain is `insert y old_dom`.

**C5 elimination**: Places new point OUTSIDE the existing domain range (uses `exists_rat_gt_finset`).

**C4 elimination (g-propagation)**: Places new point BETWEEN existing adjacent points at the midpoint `z = (x+y)/2`. This CAN insert points inside [a.val, b.val].

**Stabilization argument FAILS for omega chain**: In the discrete case, C4 counterexample elimination can continue inserting midpoints between existing adjacent pairs forever. The omega chain does NOT stabilize on bounded intervals. The discreteness property only holds in the LIMIT, not at any finite stage.

### 4. Viable Alternative Approaches

#### Approach A: Direct Well-Founded Induction on Rational Gap (RECOMMENDED)

The key insight: define a well-founded measure on `{x : LimitDomSubtype | a ≤ x ∧ x ≤ b}` using the rational value `x.val`. Since `pred x < x` in LimitDomSubtype implies `(pred x).val < x.val` in ℚ, we can use strong induction:

1. Given the interval `[a, b]` in LimitDomSubtype, show `{x | a ≤ x ∧ x ≤ b} = {a} ∪ {x | succ(a) ≤ x ∧ x ≤ b}` (using SuccOrder property: no elements between a and succ(a)).
2. By induction on the "gap" `b.val - a.val` (or more precisely, on the interval [a.val, b.val] ∩ limit_dom as a well-ordered set), reduce to smaller intervals.

**Problem**: The gap `b.val - a.val` is a rational, and rationals are NOT well-ordered. We need a well-founded relation on the gap.

**Solution**: Use well-founded induction on `{q : ℚ | q ∈ limit_dom ∧ a.val ≤ q ∧ q ≤ b.val}` ordered by `<`. This IS well-founded because:
- It's a subset of ℚ
- In the discrete case, it has no accumulation points (between consecutive points there's nothing)
- Every non-empty downward-closed subset has a minimum (it's well-ordered from below)

Actually, this reduces to proving the same statement. The well-foundedness of bounded discrete subsets of ℚ is essentially what we're trying to prove.

#### Approach B: Topological Argument via ℝ Embedding (PROMISING)

Use `Metric.finite_isBounded_inter_isClosed`:
```
theorem Metric.finite_isBounded_inter_isClosed
    [ProperSpace α] {K s : Set α} [DiscreteTopology s]
    (hK : IsBounded K) (hs : IsClosed s) : Set.Finite (K ∩ s)
```

**Strategy**:
1. Embed `limit_dom` into ℝ via `ℚ ↪ ℝ`
2. Show the image of `limit_dom` in [a, b] ⊆ ℝ is bounded and closed
3. Show it has discrete topology (no accumulation points, since between consecutive points there are no domain points)
4. Apply `Metric.finite_isBounded_inter_isClosed`

**Issues**:
- ℝ IS a proper space ✓
- Bounded interval [a, b] IS bounded ✓
- `limit_dom` image in ℝ must be CLOSED — this requires showing limit_dom ∩ [a,b] is closed in ℝ. A countable discrete subset of ℝ need not be closed (e.g., {1/n | n ∈ ℕ} has accumulation point 0). So we'd need to prove limit_dom ∩ [a.val, b.val] is closed in ℝ, which requires proving it has no accumulation points — which is essentially proving discreteness = no limits of sequences, which reduces back to finiteness.

**Verdict**: Circular for the same reason.

#### Approach C: Build Finite Enumeration via Succ Iteration (MOST DIRECT)

The cleanest approach that avoids circularity:

1. Define `enum : ℕ → LimitDomSubtype` by `enum 0 = a, enum (n+1) = succ (enum n)`.
2. Show `enum` is strictly increasing: `enum n < enum (n+1)` (from SuccOrder property, since LimitDomSubtype has NoMaxOrder).
3. Show every element of `[a, b]` appears in the range of `enum`: if `x ∈ [a, b]`, then `x = enum k` for some k. Prove by contradiction: if not, there exists `x` with `enum n ≤ x < enum (n+1)` for some n, but succ(enum n) is the LEAST element > enum n, so `succ(enum n) ≤ x`, i.e., `enum(n+1) ≤ x`, contradiction.
4. Show `enum` eventually exceeds `b`: since `enum` is strictly increasing and all values are ≤ b.val in ℚ, and the embedding into ℚ is order-preserving, the sequence `enum(n).val` is strictly increasing in ℚ and bounded above by b.val. Since each step in ℚ is by at least `1/(d₁·d₂)` where d₁, d₂ are denominators... NO, this doesn't work because the step size could shrink.

**Critical Issue**: The step size `(succ a).val - a.val` in ℚ could shrink to 0 as the limit domain gets denser between a and b. We can't bound the step size away from 0.

**Alternative for step 4**: Use the pigeonhole principle differently. The sequence `enum(n).val` for `n = 0, 1, 2, ...` gives distinct elements of `limit_dom ∩ [a.val, b.val]`. We need to show this sequence eventually leaves [a, b]. But this is equivalent to what the existing `isSuccArchimedean` proof does, and it USES `Icc_finite`.

#### Approach D: Reduction to Int via Prior-UZ Axiom (NOVEL)

The Prior-UZ axiom says `U(⊤,⊥)` is in every domain MCS in the discrete case. This means every point has an immediate successor and predecessor. The `orderIsoIntOfLinearSuccPredArch` from Mathlib gives `LimitDomSubtype ≃o ℤ` IF we have `IsSuccArchimedean`.

But we could try a DIFFERENT route to the ℤ-isomorphism that doesn't go through `IsSuccArchimedean`:
- Build the isomorphism directly by mapping `0 ↦ a` and iterating succ/pred
- Show this exhausts all elements between a and b
- This still requires showing the iteration terminates

### 5. Literature Insights

**Verbrugge 2004 (Completeness by construction)**: Their discrete construction (Theorem 5) assigns immediate successors at odd stages. The key property they exploit is that the U(⊤,⊥) axiom prevents accumulation of new points between consecutive domain points. Their completeness proof essentially assumes finiteness of bounded intervals (since they work with ℤ copies directly).

**Venema 1993**: Uses Doets' theorem to transfer from definably well-ordered models to actual well-orderings. The approach is model-theoretic replacement, not direct construction. Fact 3.3: D ∧ W ∧ L ↔ ω, so discrete well-ordered linear orders are isomorphic to ω. This doesn't directly help since our limit_dom is bi-infinite (no min/max).

## Recommended Approach

**Approach C (succ iteration) with a twist**: Instead of trying to bound the step size in ℚ, use the following strategy:

1. Define the iteration `enum : ℕ → LimitDomSubtype` starting from `a`
2. Show `∀ x ∈ [a, b], ∃ n, enum n = x` (by the no-gap property of SuccOrder — nothing between a point and its successor)
3. Show `∃ N, enum N > b` (THIS is the hard part — equivalent to IsSuccArchimedean)
4. Conclude finiteness: `{x | a ≤ x ∧ x ≤ b} ⊆ enum '' {n | n < N}`, which is finite

The trick for step 3: use `limit_dom_has_succ` which gives a CONCRETE ℚ value for the successor (the C5 witness). Since this witness comes from the omega chain construction and the omega chain domains are finite sets of rationals, each successor step increases the ℚ value. The bounded interval [a.val, b.val] in ℚ is compact in ℝ, and the sequence is strictly increasing, so if it stays bounded it must converge — but it CAN'T converge because the limit point would need to be in limit_dom (by construction), and then succ of the limit would push past it.

**This convergence argument may be the cleanest path**: Prove that a strictly increasing sequence in `limit_dom ∩ [a.val, b.val]` must be finite, using the fact that ℚ is Archimedean and limit_dom has the discrete property.

## Evidence/Examples

The `limitDomSubtype_succ_le_iff` lemma (lines 909-933) proves `succ a ≤ b ↔ a < b`, which means SuccOrder is well-behaved. The `limitDomSubtype_succ_pred` lemma (lines 1004-1029) proves `succ(pred(b)) = b`.

The `omega_chain_dom_new_unique` lemma shows each step adds at most one point, which means the omega chain is well-structured even if it doesn't stabilize on bounded intervals.

## Confidence Level

**Medium** — The alternative approaches all face the same fundamental challenge: proving that an increasing sequence in a discrete subtype of ℚ must eventually leave any bounded interval. This is true but non-trivial to formalize. The convergence-based argument (strictly increasing ℚ-valued sequence bounded above must converge, but the limit creates a contradiction with discreteness) seems most promising but requires careful handling of the ℚ → ℝ embedding and topological properties.

The most direct Lean-friendly approach may be: use `Set.Finite` for the image of `limit_dom ∩ Icc a.val b.val` under the omega chain, showing that this intersection stabilizes because in the limit, discreteness prevents infinite accumulation. But the formal argument needs careful construction.
