# Handoff: FUC/FSC Sorry Consolidation (Phase 7)

## Status: PARTIAL

## What Was Done

Consolidated the 2 FUC/FSC sorry sites from `ChronicleToCountermodel.lean` into
2 precisely specified lemmas in `ChronicleConstruction.lean`:

- `limit_satisfies_c5_strong` (line ~660): Full C5 with guard for Until
- `limit_satisfies_c5'_strong` (line ~700): Full C5' with guard for Since

The integration code (`cantor_bfmcs_restricted_fuc`) is now sorry-free,
using helper functions `limit_satisfies_c5_strong_fuc` and
`limit_satisfies_c5_strong_fsc` that transfer through the Cantor isomorphism.

## Files Modified

1. **ChronicleConstruction.lean**: Added `limit_satisfies_c5_strong` and
   `limit_satisfies_c5'_strong` (each with sorry)
2. **ChronicleToCountermodel.lean**: Removed 2 sorry sites; added
   `limit_satisfies_c5_strong_fuc`, `limit_satisfies_c5_strong_fsc`,
   and rewrote `cantor_bfmcs_restricted_fuc` to use them

## Remaining Sorry Sites (2)

### `limit_satisfies_c5_strong` (ChronicleConstruction.lean)

**Statement**: For `U(ξ,η) ∈ limit_f(x)`, there exists `y > x` in limit_dom
with `η ∈ limit_f(y)` AND `ξ ∈ limit_g(x,y)`.

The `limit_g(x,y)` condition means: for all `w ∈ limit_dom` with `x < w < y`,
`ξ ∈ limit_f(w)`.

**What's available**: `limit_satisfies_c5_weak` gives the endpoint `y` with
`η ∈ limit_f(y)`. The guard `ξ ∈ limit_g(x,y)` is the missing piece.

### `limit_satisfies_c5'_strong` (ChronicleConstruction.lean)

Mirror for Since.

## Analysis of the Guard Problem

### Why the guard is hard

The `limit_g` definition (`{φ | ∀ w ∈ limit_dom, x < w → w < y → φ ∈ limit_f(w)}`)
requires the guard formula at ALL intermediate limit_dom points. These points are
added at various steps of the omega chain, and the finite-level g function doesn't
directly propagate to the limit-level guard.

### Approaches Considered

1. **Finite-level extraction**: Extract guard from `h_actual` being FALSE in
   `eliminate_potential_counterexample`. Problem: guard at dom(n) points doesn't
   extend to later-added points in limit_dom.

2. **BX5 self-accumulation**: Use `U(ξ∧U(ξ,η), η) ∈ f(x)` from BX5. Problem:
   `c5_weak` for this formula still only gives the endpoint, not the guard.

3. **C4 contrapositive**: Attempt contradiction from guard failure. Problem:
   C4 requires `¬U(ξ,η) ∈ f(x)`, but we have `U(ξ,η) ∈ f(x)`.

4. **BX13 enrichment**: Use `U(φ, ψ∧S(φ,p))` form. Problem: still doesn't
   extract the guard from the endpoint-only `c5_weak`.

### Recommended Approach

**Track the Burgess g-function through the omega chain**:

1. Add `omega_chain_g_agrees` lemmas (analogous to `omega_chain_f_agrees`)
2. Define `limit_g_burgess(x,y) = omega_chain_val(n).g(x)(y)` for n where
   both x,y ∈ dom(n)
3. Prove `limit_g_burgess(x,y) ⊆ limit_g(x,y)` (follows from C3 + density)
4. Prove C5a at the limit using the Burgess g: when the counterexample
   `(x, ξ, η)` is eliminated at step n, `η ∈ g_n(x, y)`. This persists
   to the limit via g_agrees.
5. Conclude `η ∈ limit_g(x,y)` via step 3.

This approach requires strengthening `EliminationResult.c5_forward_witness`
to include guard information in the g-value, which the elimination code
already computes but discards (see `h_actual` at line 652-655 in
CounterexampleElimination.lean).

### Alternative: Strengthen EliminationResult

Add a field to `EliminationResult`:
```
c5_forward_witness_with_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧
    ∀ z ∈ val.dom, pc.x < z → z < y →
      pc.ξ ∈ val.f z ∧ Formula.untl pc.ξ pc.η ∈ val.f z
```

This is exactly the `h_actual` check. In the FALSE case, the guard is
already available (currently discarded with `_` at line 784). In the TRUE
case, the new y is beyond max(dom), so the guard is vacuously true at
dom(n+1) points between x and y (there may be none between x and y if
x = max, or if there are old points between x and max_old, the guard
holds vacuously because y > all old points).

Wait - in the TRUE case, there CAN be old domain points between x and y.
The guard at those points is NOT guaranteed. This is why the current
construction only provides the endpoint.

## Burgess Paper Reference

Burgess 1982, Theorem 2.11 (Truth Lemma), p.375:
- C5a: `U(ξ,η) ∈ f(x) → ∃y > x, ξ ∈ f(y), η ∈ g(x,y)`
- C3: `g(x,y) ⊆ f(z)` for `x < z < y`
- Combined: guard at intermediate points follows from C5a + C3

Our `limit_g` equals the Burgess g at the limit (for dense domains).

## Convention Reminder

Our `untl(guard=φ, event=ψ)` = Burgess `U(event=ξ, guard=η)`.
So Burgess ξ = our ψ, Burgess η = our φ.
