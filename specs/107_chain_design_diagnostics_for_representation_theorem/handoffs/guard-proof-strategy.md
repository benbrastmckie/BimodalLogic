# Handoff: Guard Proof Strategy for limit_satisfies_c5_strong

## Status: IN PROGRESS

## What Was Done

Consolidated the 2 FUC/FSC sorry sites from ChronicleToCountermodel.lean into
2 precisely specified lemmas in ChronicleConstruction.lean:

- `limit_satisfies_c5_strong` (ChronicleConstruction.lean:1289): Full C5 with guard for Until
- `limit_satisfies_c5'_strong` (ChronicleConstruction.lean:1303): Full C5' with guard for Since

The integration code (`cantor_bfmcs_restricted_fuc`) in ChronicleToCountermodel.lean
is now sorry-free, using the strong C5 lemmas with Cantor isomorphism transfer
(same pattern as `cantor_bfmcs_restricted_tc`).

## Files Modified

1. **ChronicleConstruction.lean**: Added `limit_satisfies_c5_strong` and
   `limit_satisfies_c5'_strong` (each with sorry at the guard step)
2. **ChronicleToCountermodel.lean**: Rewrote `cantor_bfmcs_restricted_fuc` to use
   the strong C5 lemmas — the original sorry sites at lines 634/638 are eliminated

## Build Status

`lake build` passes. 2 sorry sites remain in ChronicleConstruction.lean.

## Remaining Sorry Sites (2)

### `limit_satisfies_c5_strong` guard step

**Goal**: Given `untl(ξ,η) ∈ limit_f(x)`, `η ∈ limit_f(y)` with `x < y`,
and `w ∈ limit_dom` with `x < w < y`, prove `ξ ∈ limit_f(w)`.

### `limit_satisfies_c5'_strong` guard step

Mirror for Since.

## Proof Strategy

### Key Mathematical Argument

The guard propagates through the omega chain via the following invariant:

**Invariant**: For the C5 witness pair (x, y) created at stage n+1, for all stages
k >= n+1, for all adjacent pairs (a, b) in dom(k) with x <= a < b <= y:
ξ ∈ g_k(a, b).

**Base case** (k = n+1): ξ ∈ g_{n+1}(x, y). This is guaranteed by:
- n=0 case: `lemma_2_4_with_guard` produces B with ξ ∈ B
- n>=1 walk case: condition (i) checks ξ ∈ g(x, x'), and the walk/splitting
  produces the guard in the new g-values

**Inductive step** (k -> k+1): When a point w is inserted between adjacent (a, b)
in dom(k) via ANY splitting (lemma_2_6, lemma_2_7, lemma_2_8, or lemma_2_4):
- `burgessR3Maximal_extension_exists` returns `S ⊆ B'` where S = old g-value
- The D₀ seed includes B (old g-value), so D ⊇ B
- Therefore: g_k(a,b) ⊆ g_{k+1}(a,w) AND g_k(a,b) ⊆ f_{k+1}(w) AND g_k(a,b) ⊆ g_{k+1}(w,b)

**Derivation**: For any w ∈ limit_dom with x < w < y:
1. w enters at stage m > n+1
2. w is inserted between adjacent (a,b) in dom(m-1) with x ≤ a < b ≤ y
   (since x,y ∈ dom(m-1) and no point of dom(m-1) can be between a and b
   if a and b are adjacent, so a >= x and b <= y)
3. By invariant: ξ ∈ g_{m-1}(a,b)
4. By splitting: g_{m-1}(a,b) ⊆ f_m(w)
5. Therefore: ξ ∈ f_m(w) = limit_f(w)

### Implementation Plan

#### Step 1: Strengthen C5 elimination for guard (base case)

Modify `eliminate_potential_counterexample` (CounterexampleElimination.lean) to
expose the guard. Two sub-approaches:

**Approach A (Preferred)**: Add a new field `c5_forward_guard` to `EliminationResult`:
```
c5_forward_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ pc.ξ ∈ val.g pc.x y
```

This requires proving ξ ∈ g(x, y) for the new adjacent pair in each case:
- n=0: Use `lemma_2_4_with_guard` instead of `lemma_2_4`
- n>=1, Walk Case A: Use `lemma_2_4_with_guard` for the walk terminus
- n>=1, Walk Case B: Verify lemma_2_7/2_8 give ξ ∈ B' (may need enriching output)
- Not actual: The h_actual check gives the guard directly

**Approach B (Less invasive)**: Don't modify EliminationResult. Instead, prove
a separate theorem `omega_chain_c5_guard` that re-derives the guard from the
elimination structure. More complex but avoids touching 15+ match cases.

#### Step 2: Add `g_sub_f_new` property to EliminationResult

Add field:
```
g_sub_f_new : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
  a < w → w < b → χ.g a b ⊆ val.f w
```

This captures: old g-values flow into new f-values through splittings.

Proof: For each case of the elimination where a point w is inserted between
adjacent (a,b): the splitting produces f(w) = D with D ⊇ B = g(a,b) (from
the seed construction including B). The only new point is the one inserted
by the elimination. For other adjacent pairs not affected by the insertion,
the property is vacuously true (no new points between them).

#### Step 3: Add `g_sub_g_new` property

```
g_sub_g_new : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
  a < w → w < b → χ.g a b ⊆ val.g a w ∧ χ.g a b ⊆ val.g w b
```

This follows from `burgessR3Maximal_extension_exists` returning `S ⊆ B'`.

#### Step 4: Prove omega chain guard invariant

```
omega_chain_guard_invariant : ∀ k ≥ n+1,
  ∀ a b, Adjacent (omega_chain_val k).dom a b →
    x ≤ a → b ≤ y → ξ ∈ (omega_chain_val k).g a b
```

By induction on k, using Steps 2-3.

#### Step 5: Prove limit guard

For any w ∈ limit_dom with x < w < y:
1. w ∈ dom(m) for some m
2. w is inserted between adjacent (a,b) in dom(m-1)
3. x ≤ a < b ≤ y (since x,y ∈ dom(m-1) and adjacency of (a,b))
4. ξ ∈ g_{m-1}(a,b) (by invariant)
5. ξ ∈ f_m(w) (by g_sub_f_new)
6. ξ ∈ limit_f(w) (by limit_f_eq)

### Estimated Effort

- Step 1 (base case): 3-4 hours (modifying elimination is the most invasive part)
- Step 2 (g_sub_f): 1-2 hours
- Step 3 (g_sub_g): 1-2 hours
- Step 4 (invariant): 1 hour
- Step 5 (limit): 30 min

Total: 6-9 hours

### Alternative: Enriching lemma_2_7/2_8 output

Instead of modifying EliminationResult, enrich the splitting lemma outputs:

- `lemma_2_7` already returns `B ⊆ B'`. It could additionally return `xi ∈ B'`
  (which Burgess 2.7 guarantees: η ∈ B' in Burgess = ξ ∈ B' in our convention).
  The seed already includes snce(β∧xi, α) terms that establish this.

- `lemma_2_6_splitting` returns B', D, B'' with burgessR3Maximal. Since
  B ⊆ B' (from extension), B ⊆ D (from seed), B ⊆ B'' (from extension),
  the g_sub properties are immediate.

- `lemma_2_8` similarly.

This approach enriches the splitting lemmas rather than EliminationResult,
which may be cleaner.

### Key Code Locations

- EliminationResult: CounterexampleElimination.lean:602-631
- eliminate_potential_counterexample: CounterexampleElimination.lean:640
- omega_chain_c5_witness: ChronicleConstruction.lean:392
- limit_satisfies_c5_weak: ChronicleConstruction.lean:619
- limit_satisfies_c5_strong: ChronicleConstruction.lean:1289
- lemma_2_4_with_guard: PointInsertion.lean:4832
- lemma_2_7: PointInsertion.lean:3616
- lemma_2_6_splitting: PointInsertion.lean:2798
- lemma_2_8: PointInsertion.lean:3977
- burgessR3Maximal_extension_exists: RRelation.lean:760
- burgessR3_absorption: RRelation.lean:591
