# Round 7: IsSuccArchimedean Proof Strategy from Prior-UZ

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Status**: Research complete
- **Type**: lean4
- **Date**: 2026-05-10

## Executive Summary

This report identifies the correct proof strategy for `limitDomSubtype_isSuccArchimedean` now that Prior-UZ has been added as an axiom (Phases 1-2 complete, build passing). After extensive analysis of both the literature and multiple proof strategies, the recommended approach is:

**Prove `limit_dom ∩ [a, b]` is finite using topology (compact + discrete => finite), then induct on the cardinality.**

Specifically:
1. Embed `limit_dom` into R via `Rat.cast`
2. Show each limit_dom point is isolated in R (using SuccOrder/PredOrder)
3. Apply Mathlib's `IsCompact.finite` to the image in `Set.Icc (a:R) (b:R)`
4. Use the resulting `Set.Finite` to build a `Finset`, then induct on `Finset.card`

Prior-UZ is NOT needed for the IsSuccArchimedean proof itself. It was needed to ADD SuccOrder/PredOrder to the limit_dom (via `theorem_in_mcs` giving `U(top,bot)` in every MCS). Once SuccOrder, PredOrder, and `succ(pred(x)) = x` are established, IsSuccArchimedean follows from the embedding in Q (a subset of R).

## Part 1: Literature Analysis

### 1.1 Reynolds 1992, Section 10

Reynolds axiomatizes US/Z with Prior-UZ: `Fp -> U(p, neg p)`. His completeness proof (Theorem 9) for the integers is short:

- Define "good" = k-equivalent to an interval of Z
- Define "very good" = all sub-intervals are good
- Define the equivalence relation ~ where a ~ b iff M|[a,b] is very good
- Show ~ has no gaps (from Prior-UZ, via the same Lemma 9 used for the real case)
- Then: if M is not good, M is not very good, so exists a < b with M|[a,b] not good
- This gives two disjoint ~-classes. Class of a includes c but not c+1.
- But M|[c, c+1] is finite (2 points), hence very good, hence c ~ c+1. Contradiction.

**Key insight**: Reynolds NEVER constructs an OrderIso to Z. He uses Ehrenfeucht-Fraisse k-equivalence.

### 1.2 Venema 1993

Venema's axiom W = Prior-UZ = `Fp -> U(p, neg p)`. 

**Lemma 4.1**: Every BW-model is definably well-ordered. Proof: U'(psi, chi) is equivalent to bot over any BW-model. If U'(psi, chi) held at t, chi holds until a gap with neg-chi arbitrarily soon after. But F(chi) at t gives U(chi, neg chi) by W, meaning a nearest future chi-point exists. This contradicts chi failing near the gap.

**Theorem 4.3** (completeness for omega): phi consistent with BN implies phi has a well-ordered model satisfying Box(D), hence isomorphic to (omega, <) by the characterization: discrete + well-ordered + beginning = omega.

### 1.3 What Prior-UZ Actually Does

Prior-UZ validates on Z because Z is well-ordered upward (every non-empty subset bounded below has a minimum). The ZxZ counterexample shows Prior-UZ is independent from the base BX axioms.

In the canonical model, Prior-UZ enters via `theorem_in_mcs`: since `Axiom.prior_UZ phi` gives a `DerivationTree [] (phi.some_future.imp (Formula.untl phi phi.neg))`, every MCS contains this. This in turn ensures the limit domain has the required structure. But for the IsSuccArchimedean proof itself, all we need is SuccOrder + PredOrder + the embedding in Q.

## Part 2: Why Prior-UZ Is Not Directly Needed for IsSuccArchimedean

The following fact is purely order-theoretic:

**Theorem**: Let S be a subset of Q with LinearOrder (inherited from Q), SuccOrder, PredOrder, `succ(pred(x)) = x`, NoMaxOrder, and NoMinOrder. Then S has IsSuccArchimedean.

**Proof sketch**: For any a <= b in S, `S ∩ [a, b]` is finite (because S is discrete in R and [a, b] is compact in R). Then `succ^[|S ∩ (a, b]|](a) = b`.

Prior-UZ was needed to ESTABLISH SuccOrder and PredOrder on limit_dom (by ensuring `U(top, bot)` and `S(top, bot)` are in every MCS, which gives immediate successors/predecessors via C5 resolution). But once these orders exist, IsSuccArchimedean follows from the embedding in Q.

## Part 3: Recommended Proof Strategy

### 3.1 Step 1: Prove Discreteness in R

**Lemma** `limit_dom_isDiscrete_in_R`: The image of `limit_dom ∩ [a, b]` under `Rat.cast : Q -> R` is `IsDiscrete` (has discrete subspace topology in R).

**Proof**: For each x in the set, the interval `(pred(x).val : R, succ(x).val : R)` is an open set in R containing x but no other points of the set. This gives `DiscreteTopology` on the subtype, hence `IsDiscrete`.

### 3.2 Step 2: Prove Finiteness

**Lemma** `limit_dom_interval_finite`: For any a, b in LimitDomSubtype with a <= b, the set `{x : Q | x ∈ limit_dom ∧ a.val <= x ∧ x <= b.val}` is `Set.Finite`.

**Proof**: The image under `Rat.cast` is a subset of `Set.Icc (a.val : R) (b.val : R)`, which is compact (by `ConditionallyCompleteLinearOrder.isCompact_Icc` for R). The image is `IsDiscrete` (Step 1). Apply `IsCompact.finite`.

### 3.3 Step 3: Derive IsSuccArchimedean

**Theorem** `limitDomSubtype_isSuccArchimedean`: Replace the sorry at line 1068.

**Proof**: Given a <= b, by Step 2, `limit_dom ∩ (a.val, b.val]` is finite with some cardinality k. Do strong induction on k.

- k = 0: a = b, done with n = 0.
- k + 1: a < b. succ(a) exists and succ(a) <= b. The set `limit_dom ∩ (succ(a).val, b.val]` has cardinality < k + 1 (because succ(a) was in `(a.val, b.val]` but is not in `(succ(a).val, b.val]`). By IH, `succ^[m](succ(a)) = b`. So `succ^[m+1](a) = b`.

### 3.4 Mathlib Lemmas Required

| Lemma | Module | Purpose |
|-------|--------|---------|
| `IsCompact.finite` | `Mathlib.Topology.Compactness.Compact` | Compact + discrete => finite |
| `ConditionallyCompleteLinearOrder.isCompact_Icc` | `Mathlib.Topology.Order.IsLUB` | [a,b] is compact in R |
| `Rat.cast` | `Mathlib.Data.Rat.Cast.Defs` | Q -> R embedding |
| `Set.Finite.toFinset` | `Mathlib.Order.Filter.Basic` | Convert Set.Finite to Finset |

### 3.5 Key Technical Detail: Discreteness Proof

To show `IsDiscrete` (= `DiscreteTopology` on the subtype), we need each point to be isolated. For x in `limit_dom ∩ [a.val, b.val]`:

- `pred(x_sub)` and `succ(x_sub)` exist in limit_dom
- No limit_dom points in `(pred(x_sub).val, x) ∪ (x, succ(x_sub).val)`
- The open interval `(pred(x_sub).val : R, succ(x_sub).val : R)` intersected with the image of our set is `{(x : R)}`
- This is an open set in the subspace topology containing x and only x

For boundary points (a and b themselves), use slightly different neighborhoods:
- For a: use `(-infinity, succ(a).val : R)` or just `(a.val - 1 : R, succ(a).val : R)`
- For b: use `(pred(b).val : R, b.val + 1 : R)`

## Part 4: Alternative Approaches

### 4.1 Direct Proof Without Topology (More Elementary)

Prove `limit_dom ∩ [a, b]` is finite WITHOUT topology, using the omega-chain structure:

Both a, b are in dom_N. Show that the set of limit_dom points in (a, b) equals the set of dom_M points in (a, b) for some sufficiently large M (the chain "stabilizes" in bounded intervals). This M is bounded by the enumeration index of the last counterexample involving points in (a, b).

This avoids topology but requires deep analysis of the counterexample enumeration.

### 4.2 Bypass Finiteness Entirely

Prove IsSuccArchimedean directly by well-founded induction on `b - a` in some well-ordered measure. The challenge: Q has no natural well-ordering compatible with <.

One possibility: use `Nat.strongRecOn` on `|dom_N ∩ (a.val, b.val]|` and handle the "gap between consecutive dom_N points" case by appealing to the finiteness of the gap via the topology argument.

### 4.3 Bypass OrderIso to Z Entirely

Restructure discrete completeness to use k-equivalence transfer (Reynolds's approach) instead of constructing `LimitDomSubtype ≃o Z`. This avoids IsSuccArchimedean entirely but requires ~500-1000 lines of Ehrenfeucht-Fraisse formalization.

## Part 5: Assessment

### 5.1 Difficulty and Effort

| Approach | Difficulty | Lines | Dependencies |
|----------|-----------|-------|--------------|
| Topology (recommended) | Medium | ~100-150 | IsCompact.finite, Rat.cast, Icc compact in R |
| Direct omega-chain | High | ~200-300 | Deep counterexample analysis |
| k-equivalence bypass | Very High | ~500-1000 | Ehrenfeucht-Fraisse games |

### 5.2 Risks

1. **Topology imports**: The proof requires importing topology modules. Check that these are compatible with the existing Lean/Mathlib setup. The project already uses Mathlib, so this should be fine.

2. **DiscreteTopology construction**: Showing `DiscreteTopology` on the subtype requires constructing open neighborhoods for each point. This is straightforward using `isOpen_Ioo` and the SuccOrder/PredOrder properties.

3. **Casting between Q and R**: The `Rat.cast : Q -> R` is an order-preserving injection. Need to verify that `Rat.cast` preserves < and that the image is what we expect.

4. **Finset construction from Set.Finite**: `Set.Finite.toFinset` gives a Finset from a finite set proof. The induction on `Finset.card` is standard.

### 5.3 Recommendation

Implement the topology-based approach (Section 3). It is the cleanest, uses well-established Mathlib infrastructure, and requires the least new mathematical machinery. The proof factors into three clear steps (discreteness, finiteness, induction), each of which is independently verifiable.

## Summary of Key Findings

1. **Prior-UZ is needed for SuccOrder/PredOrder** (via theorem_in_mcs and C5 resolution), but NOT directly for IsSuccArchimedean.

2. **IsSuccArchimedean follows from: SuccOrder + PredOrder + embedding in Q** (equivalently, in R via compactness).

3. **The finiteness of bounded limit_dom intervals** is the key enabling lemma, provable via `IsCompact.finite` applied to the image in R.

4. **Reynolds/Venema never prove IsSuccArchimedean** -- they use k-equivalence transfer. Our codebase's OrderIso approach requires it, and the topology route is the cleanest way to get it.

5. **Mathlib has all needed infrastructure**: `IsCompact.finite`, `isCompact_Icc` for R, `Rat.cast`, `Set.Finite.toFinset`.
