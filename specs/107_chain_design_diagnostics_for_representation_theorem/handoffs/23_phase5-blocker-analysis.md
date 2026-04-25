# Handoff: Phase 5 Blocker Analysis

**Session**: sess_1777093251_dbd5f0
**Date**: 2026-04-24
**Status**: BLOCKED -- fundamental architecture issue identified

## Summary

Phase 5 implementation is blocked by a fundamental issue with the `omega_chain_g_ordered` / `omega_chain_h_ordered` proofs. These two sorry sites (ChronicleConstruction.lean:846,855) are the ROOT CAUSE of all 14 remaining sorry sites. The issue is that under strict (irreflexive) temporal semantics, the current elimination functions do NOT preserve g/h-ordering.

## Root Cause Analysis

### The g_ordered invariant

`omega_chain_g_ordered` claims: at every stage n of the omega chain, for all x < y in dom_n, `g_content(f_n(x)) ⊆ f_n(y)`.

This is supposed to be proved by induction on n. At n=0 (singleton), vacuously true. At n+1, the elimination step inserts a new point z with some MCS f(z).

### Why induction fails: the density case

Consider the density elimination: adjacent x < y, insert z = (x+y)/2 with f(z) = f(x).

At stage n+1, we need g_content(f(x)) ⊆ f(z) = f(x). Under strict semantics, this means: G(phi) in f(x) implies phi in f(x). But there is NO axiom G(phi) -> phi under irreflexive semantics (no T-axiom for temporal operators). So `g_content(f(x)) ⊆ f(x)` is FALSE in general.

**The density elimination as currently written breaks g_ordered.**

### Why induction fails: the C5 case

C5 forward elimination: insert y beyond ALL domain points, f(y) = C from lemma_2_4 with seed {beta} ∪ g_content(f(ce.x)).

For g_ordered at n+1: for all old w < y, need g_content(f(w)) ⊆ C.
- For w <= ce.x: g_content(f(w)) ⊆ f(ce.x) (IH) and g_content(f(ce.x)) ⊆ C (seed). By lemma_2_5b (transitivity): g_content(f(w)) ⊆ C. OK.
- For w > ce.x (old domain point between ce.x and max_dom): g_content(f(w)) ⊆ C is NOT guaranteed. The seed only contains g_content(f(ce.x)), not g_content(f(w)).

### Why induction fails: the g_prop case

G-propagation elimination: insert z between adjacent x, y with f(z) = D from g_propagation_witness, g_content(f(x)) ⊆ D.

For z < old w: need g_content(D) ⊆ f(w). Not guaranteed by the construction.

### Dependency chain

```
omega_chain_g_ordered (sorry, BLOCKED)
  -> limit_forward_G (proved FROM g_ordered)
    -> chronicle_fmcs.forward_G (sorry, needs limit_forward_G at extended_limit_f level)
      -> box_stable (sorry, needs forward_G + backward_H)
        -> chronicle_bfmcs coherence
          -> restricted_tc (sorry)
          -> restricted_buc (sorry)
          -> restricted_fuc (sorry)
            -> dd_countermodel_chronicle
```

All 14 sorry sites trace back to omega_chain_g_ordered.

## The Fix

### Required changes to elimination functions

Each elimination function must use a TWO-SIDED SEED that includes:
- g_content(f(left_neighbor)) -- for forward G-propagation
- h_content(f(right_neighbor)) -- for backward H-propagation

This ensures:
- g_content(f(left)) ⊆ f(new_point) -- g_ordered from left
- h_content(f(right)) ⊆ f(new_point) -- h_ordered from right
- By duality: g_content(f(new_point)) ⊆ f(right) and h_content(f(new_point)) ⊆ f(left)

### Seed consistency

The two-sided seed `{target} ∪ g_content(f(x)) ∪ h_content(f(y))` must be proven consistent. The key insight: by g_ordered IH at stage n, g_content(f(x)) ⊆ f(y), so by duality h_content(f(y)) ⊆ f(x). Every element of g_content(f(x)) has G(phi) in f(x), and every element of h_content(f(y)) has H(psi) in f(y).

Consistency argument: Suppose L ⊆ {target} ∪ g_content(f(x)) ∪ h_content(f(y)) derives bot. Split L into L_g (from g_content), L_h (from h_content), and possibly target. Since all G(phi) for phi in L_g are in f(x), and all H(psi) for psi in L_h are in f(y), we can G-lift to get G(neg target) in f(x) (using the standard temporal witness argument). This gives neg(target) in g_content(f(x)) ⊆ f(y). Combined with target-related information... this needs careful formalization.

### Specific elimination changes

1. **Density**: Change `f(z) = f(x)` to `f(z) = Lindenbaum(g_content(f(x)) ∪ h_content(f(y)))`.
   Seed consistency: by g_ordered IH, g_content(f(x)) ⊆ f(y), so by duality h_content(f(y)) �� f(x). The seed ⊆ f(y) (since g_content(f(x)) ⊆ f(y) and we need to show h_content(f(y)) ⊆ f(y), which is true because H(phi) in f(y) means phi in h_content, and by BX4' + MCS: phi in h_content(f(y)) means H(phi) in f(y), but we need phi in f(y) itself... actually h_content(f(y)) = {phi | H(phi) in f(y)}, and H(phi) in f(y) does NOT imply phi in f(y) under strict semantics. So the seed is NOT necessarily a subset of f(y).

   **Alternative**: Use `forward_temporal_witness_seed f(x) (some_fresh_formula)` which is `{fresh} ∪ g_content(f(x))`, proven consistent by BX machinery. Then ADDITIONALLY prove h_content(f(y)) is compatible.

2. **C5 forward**: Change seed from `{beta} ∪ g_content(f(ce.x))` to `{beta} ∪ g_content(f(max_dom))`. But this requires F(beta) in f(max_dom), which is not available.

   **Alternative**: Use a two-phase insertion: first insert a density point to propagate g_content from ce.x to the boundary, then insert the C5 witness.

3. **G_prop forward/backward**: Similar two-sided seed approach.

### Alternative architecture: Cantor isomorphism

Instead of fixing g_ordered at finite stages, prove it at the LIMIT using the Cantor isomorphism:

1. Prove limit_dom is countable, dense, unbounded (already partially done)
2. Apply Order.iso_of_countable_dense to get limit_dom ≃o Rat
3. Redefine extended_limit_f via the isomorphism: every rational is a domain point
4. Prove limit_forward_G using the limit properties directly

The advantage: no need to maintain g_ordered at finite stages. The disadvantage: requires significant Mathlib API interaction.

### Recommended path

**Option A (preferred)**: Fix the elimination functions with two-sided seeds. This is the cleanest path but requires:
- New seed consistency proof for two-sided seeds (main difficulty)
- Modifications to 3 elimination functions (density, g_prop, h_prop)
- Modification to C5/C5' elimination to use max_dom
- All changes are localized to CounterexampleElimination.lean

**Option B**: Cantor isomorphism approach. Requires:
- Subtype limit_dom instances: Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty
- Order isomorphism application
- Redefinition of extended_limit_f
- Changes to ChronicleConstruction.lean and ChronicleToCountermodel.lean

## Files and Sorry Inventory

| File | Sorry Count | Root Cause |
|------|-------------|------------|
| ChronicleConstruction.lean | 2 | omega_chain_g_ordered, omega_chain_h_ordered |
| PointInsertion.lean | 1 | lemma_2_6_full (seed consistency for richer seed) |
| CounterexampleElimination.lean | 2 | C4/C4' hard cases (need ChronicleInvariant) |
| ChronicleToCountermodel.lean | 9 | All downstream of forward_G/backward_H |
| **Total** | **14** | |

## Prior Phase Status

- Phase 0-2: COMPLETED
- Phase 3: IN PROGRESS (dcs_neg_union_consistent proved, r3Maximal_neg_of_not_mem proved)
- Phase 4: PARTIAL (limit_dom_dense proved, g/h_ordered in ChronicleInvariant, limit_forward_G/backward_H proved FROM g_ordered)
- Phase 5: BLOCKED (this analysis)
- Phase 6-7: NOT STARTED
