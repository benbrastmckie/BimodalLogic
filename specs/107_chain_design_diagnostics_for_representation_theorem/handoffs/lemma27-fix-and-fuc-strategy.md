# Handoff: lemma_2_7 Fix Complete, FUC/FSC Guard Propagation Strategy

## Session: sess_1778085791_d0f727

## What Was Done

### Task A: Fixed lemma_2_7 (PointInsertion.lean:3616)
- Changed output type from `xi ∈ B'` to `B ⊆ B'`
- Deleted entire `by_cases h_xi_cons` split (~130 lines) and degenerate case
- Replaced with 3-line Zorn construction seeding B' from B
- Net code reduction: ~120 lines removed

### Task B: Enriched lemma_2_7_since (PointInsertion.lean:4364)
- Added `B ⊆ B'` to output type (was not previously present)
- Captured `h_B_sub_B'` from existing Zorn step (already seeded from B)
- 1-line change to output tuple

### Task C: Updated call sites in CounterexampleElimination.lean
- Forward (lemma_2_7): 5 call sites already used `_` for last component, no change needed
- Backward (lemma_2_7_since): 4 call sites updated from 7-tuple to 8-tuple destructuring with `_` for new component

### Build: `lake build` passes cleanly. 2 sorry sites remain (ChronicleToCountermodel.lean:634,638).

## What Remains: FUC/FSC Guard Propagation (Phases 2-5)

### The Core Problem

FUC sorry at line 634 requires:
```
untl(φ, ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ ∀ r, t < r → r < s → φ ∈ mcs(r)
```

This translates to proving `limit_satisfies_c5_strong`:
```
untl(ξ, η) ∈ limit_f(x) →
∃ y ∈ limit_dom, x < y ∧ η ∈ limit_f(y) ∧ ξ ∈ limit_g(x, y)
```

Where `limit_g(x, y) = { φ | ∀ w ∈ limit_dom, x < w → w < y → φ ∈ limit_f(w) }`.

`limit_satisfies_c5_weak` already gives the witness `y`. The missing piece is `ξ ∈ limit_g(x, y)`.

### Why Limit-Level Arguments Fail

1. **No BX8 (Until unfolding)**: BX8 was removed (unsound under open guard semantics). So we cannot derive `ξ ∈ f(w)` from `untl(ξ, η) ∈ f(w)` at arbitrary intermediate points.

2. **C4 goes the wrong direction**: C4 gives `¬(ξ U η) ∈ f(x) ∧ η ∈ f(y) → ∃ z, ¬ξ ∈ f(z)`. The contrapositive gives BUC (backward), not FUC (forward).

3. **No closed-form characterization**: `limit_g(x, y)` is a universal quantifier over the dense limit_dom. No finite-stage argument directly computes it.

### Why the Omega Chain Approach Works

The proof must track guard membership through the omega chain construction:

1. At stage `n+1` when `y` is created, `ξ ∈ g_{n+1}(x, y)` (from Phase 1 enriched lemma_2_4).

2. For any `w` inserted between `x` and `y` at stage `m > n+1`:
   - `w` is inserted between adjacent `(a, b)` at stage `m-1`
   - `f_m(w) = D` where `g_{m-1}(a, b) ⊆ D` (from seed: B ⊆ D)
   - Need: `ξ ∈ g_{m-1}(a, b)`

3. Induction on the splitting tree:
   - Base: `ξ ∈ g_{n+1}(x, y)`
   - Step: when `(a, b)` is split by inserting `z`:
     - `g(a, z) = B'` with `g(a, b) ⊆ B'` (from B ⊆ B' — our lemma_2_7 fix!)
     - `g(z, b) = B''` with `g(a, b) ⊆ B''` (from B ⊆ B'')
     - So `ξ ∈ g(a, b) ⊆ B' = g(a, z)` and `ξ ∈ g(a, b) ⊆ B'' = g(z, b)`

4. Therefore `ξ ∈ g_{m-1}(a, b) ⊆ D = f_m(w) = limit_f(w)`.

### Key Property: B ⊆ B' in All Splitting Lemmas

| Lemma | B ⊆ B' | B ⊆ D | Why |
|-------|--------|-------|-----|
| lemma_2_4 | N/A (creates first pair) | ξ ∈ B from Phase 1 | Phase 1 enrichment |
| lemma_2_6_splitting | Yes (Zorn seeds from B) | Yes (seed includes B) | Lines 2846, 2817 |
| lemma_2_7 | Yes (our fix!) | Yes (seed includes B) | Lines 3690, 3639 |
| lemma_2_7_since | Yes (already seeded from B, now captured) | Yes | Lines 4416, 4388 |
| lemma_2_8 | Yes (Zorn seeds from B) | Yes (seed includes B) | Lines 4024, 4000 |
| lemma_2_8_since | Yes (Zorn seeds from B) | Yes | Same pattern |

### Implementation Strategy for Phases 2-5

**Phase 2**: Add `omega_chain_g_agrees` and `omega_chain_g_agrees_le` to ChronicleConstruction.lean (mirrors f_agrees pattern). Add `c5_forward_full_witness` to EliminationResult or prove as separate lemma.

**Phase 3**: Prove `omega_chain_guard_stable`: for points `w` inserted between `x` and `y` at later stages, `ξ ∈ f_m(w)`. This requires induction on the splitting tree, using `g_agrees` (g-values preserved for old pairs) and `B ⊆ B'` (g-values of child pairs contain parent's g-value).

**Phase 4**: Combine into `limit_satisfies_c5_strong`.

**Phase 5**: Close FUC/FSC sorries by transferring through Cantor isomorphism (mirrors cantor_bfmcs_restricted_tc pattern).

### Key Difficulty

The main difficulty is that the splitting tree induction is implicit in the omega chain. The `eliminate_potential_counterexample` function handles many cases (forward/backward, C4/C5, density). The guard propagation needs to work across ALL of these cases. Each case inserts points in different ways, but they all share the invariant `B ⊆ D` and `B ⊆ B'`.

A possible simplification: instead of modifying EliminationResult, add a standalone theorem:

```lean
theorem omega_chain_splitting_preserves_guard
    (x y : Rat) (ξ : Formula) (n : Nat)
    (hx : x ∈ (omega_chain_val A h_mcs h_nubr3 n).dom)
    (hy : y ∈ (omega_chain_val A h_mcs h_nubr3 n).dom)
    (hxy : x < y)
    (h_guard : ξ ∈ (omega_chain_val A h_mcs h_nubr3 n).g x y)
    (m : Nat) (hm : m ≥ n)
    (w : Rat) (hw : w ∈ (omega_chain_val A h_mcs h_nubr3 m).dom)
    (hxw : x < w) (hwy : w < y) :
    ξ ∈ (omega_chain_val A h_mcs h_nubr3 m).f w
```

This would be proved by induction on `m - n`, using `g_agrees` and the `B ⊆ D` property.

### Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — lemma_2_7 fix, lemma_2_7_since enrichment
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — call site updates for lemma_2_7_since

### Additional Infrastructure Added

- `omega_chain_g_eq_elim` (ChronicleConstruction.lean) — g at step n+1 equals elimination result g
- `omega_chain_g_agrees` (ChronicleConstruction.lean) — g-values preserved for old domain pairs
- `omega_chain_g_agrees_le` (ChronicleConstruction.lean) — g-agrees extends transitively

### Critical Discovery: Forward Walk Region Gap

The guard propagation splits into TWO regions for the n>=1 walk case:

**Region A** (x, u_max]: Points in the forward walk. `ξ ∈ f(w)` from condition (i). But `ξ ∈ g(w, w')` for walk adjacent pairs is NOT guaranteed. The BurgessR3Maximal condition doesn't imply `ξ ∈ g(w, w')` just because `ξ ∈ f(w)` and `ξ ∈ f(w')`.

**Region B** [u_max, y): The splitting region. `ξ ∈ g(u_max, y)` from lemma_2_4 or lemma_2_7. Guard propagation through splitting tree works via `B ⊆ B'` and `B ⊆ D`.

For Region A, later insertions between walk points `(w, w')` produce `f(new) = D` where `g(w, w') ⊆ D`. But `ξ ∈ g(w, w')` is unknown, so `ξ ∈ D` is not guaranteed.

### Possible Solutions for the Walk Region Gap

1. **Strengthen the walk**: In the forward walk (condition (i)), we have `ξ ∧ untl(ξ, η) ∈ f(w')`. From BX5: `untl(ξ ∧ untl(ξ, η), η) ∈ f(w)`. Combined with Phase 1 enrichment of lemma_2_4 applied to these stronger Until formulas, we might get `ξ ∈ g(w, w')` via `burgessR3Maximal_with_guard`. But this requires `burgessR(f(w), ξ, f(w'))` which needs `untl(ξ, γ) ∈ f(w)` for all `γ ∈ f(w')` — not just `untl(ξ, η)`.

2. **Modify elimination to split at EACH walk step**: Instead of walking forward and splitting at the end, split at EACH adjacent pair in the walk. Each splitting creates a new intermediate point with the guard in g. This is a significant restructuring of `eliminate_potential_counterexample`.

3. **Use BX14 (separation)**: BX14: `untl(φ, ψ ∨ χ) → untl(φ, ψ) ∨ untl(φ, χ)`. Combined with `untl(ξ, η) ∈ f(w)` and the MCS structure of `f(w')`, maybe derive `untl(ξ, γ) ∈ f(w)` for enough `γ` to get `burgessR3(f(w), ξ, f(w'))`.

4. **Accept that guard at walk points comes from f-stability**: Since `ξ ∈ f(w) = limit_f(w)` for all walk points `w` (from condition (i)), and later insertions happen between walk points, the NEW points' f-values might not contain `ξ`. BUT, the limit_g(x, y) by definition requires `ξ ∈ limit_f(w)` for ALL intermediate `w` in limit_dom. If some future `w` doesn't have `ξ ∈ limit_f(w)`, then `ξ ∉ limit_g(x, y)`. So we genuinely need `ξ` at ALL intermediate points, not just the walk points.

**Recommendation**: Option 2 (restructure elimination to split at each walk step) is the most principled but highest effort. A preliminary investigation should check whether `burgessR3(f(w), ξ, f(w'))` holds in the walk context (option 1), as this would avoid the restructuring.

### Files To Modify Next

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — guard propagation lemmas, limit_satisfies_c5_strong
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — possibly restructure walk to split at each step
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — close FUC/FSC sorries
