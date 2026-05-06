# Handoff: Guard Propagation Infrastructure

## Status: 3 sorries remain (down from 2 original + 1 new helper)

### What was built

**New infrastructure in ChronicleConstruction.lean** (lines ~1276-1420):

1. **`omega_chain_dom_new_unique`** (sorry): States that each elimination step inserts at most one new domain point. Needed for adjacency proofs in the g-value propagation chain.

2. **`omega_chain_g_sub_f_insert`**: Lifts `EliminationResult.g_sub_f_insert` to omega chain level. Proved.

3. **`omega_chain_g_sub_g_new`**: Lifts `EliminationResult.g_sub_g_new` to omega chain level. Proved.

4. **`adj_g_mem_f_at_stage`** (private): The core propagation lemma. Proves: for adjacent `(a,b)` in `dom(n)` and `phi in g_n(a,b)`, if `w in dom(n+d)` with `a < w < b`, then `phi in f_{n+d}(w)`. Proved by induction on `d`, tracking the "current containing adjacent pair" through insertions. Uses `omega_chain_dom_new_unique` for adjacency of sub-intervals after point insertion.

5. **`adj_g_mem_limit_f`**: The bridge lemma. For adjacent `(a,b)` in `dom(k)` and `phi in g_k(a,b)`, and `w in limit_dom` with `a < w < b`: `phi in limit_f(w)`. Proved using `adj_g_mem_f_at_stage`.

### What remains

#### Sorry 1: `omega_chain_dom_new_unique` (line ~1289)

**Statement**: `u, v in dom(n+1) \ dom(n) => u = v`

**Approach**: Add `dom_new_unique` field to `EliminationResult` structure. Every case of `eliminate_potential_counterexample` either returns the chronicle unchanged (`val.dom = chi.dom`, vacuously true) or constructs `val.dom = insert z chi.dom` for a specific `z` (any new point must equal `z`). There are 18 cases total: 7 unchanged (trivial) and 11 insert (need `Finset.mem_insert` reasoning).

**Estimated effort**: ~50 lines of mechanical proofs across CounterexampleElimination.lean.

#### Sorry 2+3: `limit_satisfies_c5_strong` and `limit_satisfies_c5'_strong` (lines ~1441, 1453)

**Statement**: Need to prove `xi in limit_f w` for intermediate `w` between `x` and the C5 witness `y`.

**What's needed**: Show `xi in g_k(a, b)` for some adjacent pair `(a, b)` at stage `k` where the C5 elimination happened, with `x <= a < b <= y`. Then `adj_g_mem_limit_f` closes the proof.

**Approach**: 

For the **n=0 case** of C5 elimination (pc.x is the maximum domain point):
- `g'(pc.x, y) = B` from `lemma_2_4`
- `lemma_2_4_with_guard` (already exists in PointInsertion.lean line 4846) gives `xi in B`
- Need to modify the elimination to use `_with_guard` OR prove after-the-fact that `xi in B`

For the **n>=1 case** (forward walk + splitting):
- Condition (i) walk gives `xi in g(x, x')` for the first step
- The walk set computes `u_max` and splits at `(u_max, u_next)`
- Need `xi in g(u_max, u_next)` or equivalent
- This requires either step-by-step walk tracking (complex) or a different argument

**Estimated effort**: 100-200 lines. The n=0 case is straightforward if we modify the elimination or prove a standalone lemma. The n>=1 case is harder and may require restructuring the walk logic.

### Architecture summary

```
limit_satisfies_c5_strong
  uses: adj_g_mem_limit_f + [MISSING: xi in g_k(a,b) from C5 elimination]
    adj_g_mem_limit_f
      uses: adj_g_mem_f_at_stage (induction on stage difference)
        uses: omega_chain_g_sub_f_insert (proved)
              omega_chain_g_sub_g_new (proved) 
              omega_chain_dom_new_unique (sorry)
```

### Key file: ChronicleConstruction.lean

All new code is between the existing `limit_c3_interval_subset_right` theorem and `limit_satisfies_c5_strong`. The original sorry sites at the end of the file are unchanged in their location but may have shifted by ~70 lines due to the new infrastructure.
