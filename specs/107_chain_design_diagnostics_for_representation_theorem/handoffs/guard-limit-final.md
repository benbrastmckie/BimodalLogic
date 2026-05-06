# Handoff: Guard Propagation at Limit (2 remaining sorries)

## Status: 9/11 sorry sites closed, 2 remain

### What was done
- Enriched return types of all 5 splitting lemmas (lemma_2_6_splitting, lemma_2_7, lemma_2_8, lemma_2_7_since, lemma_2_8_since) in PointInsertion.lean with `B ⊆ D`
- Proved all 9 `g_sub_f_insert` sorry sites in CounterexampleElimination.lean
- Full build passes with 0 sorry sites in CounterexampleElimination.lean

### Remaining 2 sorry sites

Both in ChronicleConstruction.lean:

**Line 1301**: `limit_satisfies_c5_strong` — guard for forward Until
**Line 1313**: `limit_satisfies_c5'_strong` — guard for backward Since (mirror)

### Goal at each sorry

After `intro w hw hxw hwy`, the goal is `ξ ∈ limit_f A h_mcs h_nubr3 w`.

Context:
- `x ∈ limit_dom` with `untl(ξ, η) ∈ limit_f(x)`
- `y ∈ limit_dom` with `η ∈ limit_f(y)` and `x < y` (from `limit_satisfies_c5_weak`)
- `w ∈ limit_dom` with `x < w < y`

### Proof Strategy

The proof requires showing that the guard `ξ` propagates through the omega chain to reach `f(w)` for any `w` between `x` and `y`.

#### Key infrastructure needed

1. **omega_chain_g_sub_f_insert**: Expose `g_sub_f_insert` at the omega chain level:
   ```
   ∀ k, ∀ a b, Adjacent (dom_k) a b →
     ∀ w ∈ dom_{k+1}, w ∉ dom_k →
     a < w → w < b → g_k(a,b) ⊆ f_{k+1}(w)
   ```
   This follows directly from `(omega_chain_elim_result ... k).g_sub_f_insert`.

2. **omega_chain_g_sub_g_new** (NOT YET AVAILABLE): When a point `c` is inserted between adjacent `(a,b)` at stage `k`:
   ```
   g_k(a,b) ⊆ g_{k+1}(a,c) ∧ g_k(a,b) ⊆ g_{k+1}(c,b)
   ```
   This comes from `B ⊆ B'` returned by `burgessR3Maximal_extension_exists`. The splitting lemma already returns `B ⊆ B'` (for lemma_2_7/lemma_2_7_since) and the Zorn extension gives this for all cases.

   **To expose this**: Enrich the splitting lemma returns with `B ⊆ B'` and `B ⊆ B''` (currently lemma_2_6_splitting and lemma_2_8/lemma_2_8_since only return `B ⊆ D`, not `B ⊆ B'` or `B ⊆ B''`).

3. **guard_invariant** (omega chain induction):
   For all stages `k ≥ n+1`, for all adjacent `(a,b)` in `dom_k` with `x ≤ a < b ≤ y`:
   `ξ ∈ g_k(a,b)`.

   Base case (k = n+1): `ξ ∈ g_{n+1}(x, y)` from C5 elimination, then C3 monotonicity gives `ξ ∈ g_{n+1}(a, b)` for sub-intervals.

   Step (k → k+1): When point `c` is inserted between adjacent `(a,b)`:
   - `ξ ∈ g_k(a,b)` by IH
   - `ξ ∈ g_{k+1}(a,c)` from `g_sub_g_new`
   - `ξ ∈ g_{k+1}(c,b)` from `g_sub_g_new`

4. **limit proof**: Given `w` between `x` and `y` entering at stage `m`:
   - Find adjacent `(a,b)` in `dom_{m-1}` with `a < w < b`
   - By guard_invariant: `ξ ∈ g_{m-1}(a,b)`
   - By omega_chain_g_sub_f_insert: `g_{m-1}(a,b) ⊆ f_m(w)`
   - Hence `ξ ∈ f_m(w) = limit_f(w)`

### Alternative approach (simpler but still complex)

Instead of the full omega chain induction, use the existing C3 monotonicity:

If ALL intermediate points between `x` and `y` entered at stage `n+1` (i.e., `a, b ∈ dom_{n+1}`), then `g_{m-1}(a,b) = g_{n+1}(a,b) ⊇ g_{n+1}(x,y) ∋ ξ`.

If some intermediate points entered LATER, need `g_sub_g_new` to propagate.

### Missing piece for `g_sub_g_new`

The splitting lemmas need to also return `B ⊆ B''` (not just `B ⊆ B'` and `B ⊆ D`). This requires:
- `lemma_2_6_splitting`: Add `B ⊆ B'` and `B ⊆ B''` 
- `lemma_2_8` / `lemma_2_8_since`: Add `B ⊆ B'` and `B ⊆ B''`

The proof: In all splitting lemmas, `B'` and `B''` come from `burgessR3Maximal_extension_exists` which takes `B` as the seed and returns `B' ⊇ B`. The same holds for `B''`.

### C5 guard fact needed

Need a theorem that the C5 elimination produces a witness with `ξ ∈ g_{n+1}(x, y)`. This is NOT currently available. The `omega_chain_c5_witness` only returns `y` with `η ∈ f_{n+1}(y)`, NOT the guard membership.

This requires examining the `EliminationResult` more carefully: the C5 forward witness case produces `y` such that the new g-value at `(x, y)` contains elements from the splitting. The guard `ξ` is placed in the g-value by the splitting construction (Burgess 2.10 condition (i) ensures `ξ ∈ g(x, y)` when the walk terminates with `ξ ∧ untl(ξ,η) ∈ f(x')` and `ξ ∈ g(x, x')`).

### Files modified in this session
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: Enriched 5 splitting lemma return types with `B ⊆ D`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Proved all 9 `g_sub_f_insert` fields
