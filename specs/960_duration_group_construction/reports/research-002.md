# Research Report: Reflexive MCS Obstacle Analysis

**Task**: 960 (Duration Group Construction from Pure Syntax)
**Date**: 2026-03-14
**Status**: [RESEARCHED]

## Summary

The 3 sorry'd instances in CantorApplication.lean (NoMaxOrder, NoMinOrder,
DenselyOrdered) and the pending SuccOrder/PredOrder for the discrete case are
ALL blocked by the same fundamental obstacle: the canonical model can contain
**reflexive MCSs** (M with CanonicalR M M), and `canonicalR_irreflexive` is
unprovable with the current `String` atom type.

This is NOT a proof gap — it is a genuine semantic limitation demonstrated by
a concrete counterexample.

## The Counterexample

Consider a model `{w₀, w₁, w₂}` with relations:
- R(w₀, w₁), R(w₀, w₂), R(w₁, w₂), R(w₂, w₁), R(w₁, w₁), R(w₂, w₂)
- ¬R(w₁, w₀), ¬R(w₂, w₀)

Properties:
- **Density axiom satisfied**: F(φ) → F(F(φ)) holds everywhere because
  successors of w₁ = {w₁, w₂} and successors of w₂ = {w₁, w₂}, so
  F(F(φ)) ↔ F(φ) at w₀, and F(F(φ)) ↔ F(φ) at w₁, w₂.
- **Quotient**: {[w₀], [w₁] = [w₂]} — only two equivalence classes.
- **NOT densely ordered**: No element strictly between [w₀] and [w₁].
- **HAS a max element**: [w₁] has no strict successor.
- **IRR rule NOT sound**: w₁ is reflexive, so the model doesn't satisfy the
  irreflexivity condition needed for IRR soundness.

This shows that the density axiom alone, without irreflexivity of all points,
does NOT guarantee DenselyOrdered/NoMaxOrder/NoMinOrder in the quotient.

## Root Cause: String Atom Freshness

The standard proof of `canonicalR_irreflexive` (Goldblatt 1992, BdRV 2001)
uses the IRR rule contrapositively:

1. Assume CanonicalR(M, M) for contradiction
2. Pick fresh atom p ∉ (any formula in GContent(M)).atoms
3. Build naming set: GContent(M) ∪ {p, H(¬p)}
4. Show naming set is consistent (via IRR contrapositive)
5. Extend to MCS M' ⊇ GContent(M) ∪ {p, H(¬p)}
6. CanonicalR(M, M') since GContent(M) ⊆ M'
7. H(¬p) ∈ M' gives ¬p ∈ M (by HContent duality)
8. Since GContent(M) ⊆ M (reflexivity) and all of M ⊆ M' (freshness), ¬p ∈ M'
9. Contradiction: p ∈ M' and ¬p ∈ M'

**Step 2 fails with String atoms**: For every string s, the tautology
`G(s ∨ ¬s)` is in M (by temporal necessitation), so `s ∨ ¬s` ∈ GContent(M)
with `s ∈ (s ∨ ¬s).atoms`. No string is fresh for GContent(M).

**Step 8 fails without freshness**: atomFreeSubset(M, p) ⊊ M, so M ⊄ M',
and ¬p ∈ M might not transfer to M'.

## Impact Assessment

| Component | Status | Blocker |
|-----------|--------|---------|
| NoMaxOrder (CantorApplication) | sorry | reflexive MCS |
| NoMinOrder (CantorApplication) | sorry | reflexive MCS |
| DenselyOrdered (CantorApplication) | sorry | reflexive MCS + strict density |
| density_frame_condition_strict | 12 sorries | reflexive MCS (Case B branches) |
| SuccOrder (DiscreteTimeline) | TODO | reflexive MCS (for NoMaxOrder prereq) |
| PredOrder (DiscreteTimeline) | TODO | reflexive MCS (for NoMinOrder prereq) |
| baseTaskFrame (CanonicalDomain) | **WORKS** | uses D = ℤ directly |
| DurationTransfer | **WORKS** | sorry-free generic transfer |

## Resolution Paths

### Path 1: Change Atom Type (Recommended)

Replace `String` with a type supporting freshness:

```lean
-- Option A: Use Nat × Nat where second component provides fresh atoms
abbrev Atom := Nat × Nat

-- Option B: Use a dedicated Fresh type
structure Atom where
  base : String
  fresh_index : Option Nat  -- None = base atom, Some n = fresh atom #n
```

This requires:
- Refactoring `Formula` to use the new atom type
- Proving `Infinite Atom` and `Countable Atom`
- Proving freshness: for any `Finset Atom`, there exists an atom not in it
- Large-scale change across the codebase

### Path 2: Direct Construction on ℚ

Build a model directly on ℚ by assigning MCSs to rationals via dovetailing:
- Avoids the quotient entirely
- Can enforce irreflexivity by construction (always pick strict successors)
- Similar to the existing DovetailingChain.lean approach but on ℚ instead of ℤ
- Blocked by the same F/P witness persistence issue that blocked DovetailingChain

### Path 3: Accept Sorry, Use ℤ-Direct Path

The existing `CanonicalConstruction.lean` provides `TaskFrame ℤ` that works
because it uses unconditional GContent/HContent dual requirements (not the
Antisymmetrization quotient). This avoids the reflexive MCS obstacle entirely.

For the pure-syntax D construction:
- Base case: `baseTaskFrame : TaskFrame ℤ` — **COMPLETE**
- Dense case: `denseCanonicalTaskFrame` — depends on 3 sorries
- Discrete case: `discreteCanonicalTaskFrame` — SuccOrder/PredOrder TODO

The base case already provides a working TaskFrame. The dense and discrete
cases provide the *parameterized* construction where D emerges from syntax,
but are blocked by the same fundamental obstacle.

### Path 4: Prove Irreflexivity via Model-Theoretic Argument

Instead of proving `canonicalR_irreflexive` directly, prove that the
Antisymmetrization quotient of the staged timeline has no reflexive-cluster
maximum. This would require showing that the staged construction process
always creates points outside any reflexive cluster.

This is plausible because the staged construction uses density intermediates
that come from `density_frame_condition`, which in Case A produces witnesses
that are provably outside the source cluster. But Case B1 (reflexive M')
remains problematic.

## Recommendation

**Short-term**: Accept the sorries, document them clearly (done), and use the
base case `TaskFrame ℤ` for the completeness theorem.

**Medium-term**: Investigate Path 4 (model-theoretic argument) or Path 1
(atom type change). Path 1 is the cleanest but highest-effort solution.

**Long-term**: Path 1 (change atom type) is the right fix. It aligns with the
standard literature where atoms are drawn from a countably infinite set with
freshness, not from String which conflates the naming domain with the meta-
language.
