# Guard Propagation Through Omega Chain — Research Report

## Problem

Task 107 needs `limit_satisfies_c5_strong` and `limit_satisfies_c5'_strong` (ChronicleConstruction.lean:1291-1313): proving that for `untl(ξ,η) ∈ limit_f(x)`, there exists `y > x` with `η ∈ limit_f(y)` AND `ξ ∈ limit_g(x,y)`. The guard condition `ξ ∈ limit_g(x,y)` means `∀ w ∈ limit_dom, x < w < y → ξ ∈ limit_f(w)`.

Previous attempts added `g_sub_f_insert` to `EliminationResult` but left 9 sorry sites because the density case appeared to set `f(z) = f(pc.x)`, making `g(a,b) ⊆ f(z)` unprovable.

## Key Findings

### 1. Density Case IS a Splitting Case (Critical Correction)

The density case at CounterexampleElimination.lean:2470-2485 uses `lemma_2_6_splitting` to produce a fresh MCS D, NOT `f(pc.x)`. The comment at line 2445 saying "f(z) = f(x)" is outdated. The actual code:

```lean
have h_split := lemma_2_6_splitting h_mcs_x h_mcs_y h_r3m h_B_sdc h_gc β h_beta_not h_nubr3
-- f(z) = D (from splitting), NOT f(pc.x)
exact { val := ⟨fun q => if q = z then D else χ.f q, g', insert z χ.dom⟩
```

This means `B ⊆ D` holds (where B = g(a,b)), making `g_sub_f_insert` provable for ALL cases uniformly.

### 2. Burgess Has No Density Step

Burgess 1982 only handles C4/C5 counterexamples (Lemmas 2.9/2.10). Density comes from Q being dense. Our `.density` kind is needed because finite stages have finite domains; `limit_dom_dense` (ChronicleConstruction.lean:733) requires explicitly inserting midpoints. Cannot remove density.

### 3. `B ⊆ D` Proved But Not Returned

All splitting lemmas prove `B ⊆ D` internally but only `lemma_2_7` returns `B ⊆ B'`:

| Lemma | `B ⊆ D` location | Returned? |
|-------|-------------------|-----------|
| `lemma_2_6_splitting` | PI:2817-2819 | No |
| `lemma_2_7` | PI:3639-3641 | No (but `B ⊆ B'` returned) |
| `lemma_2_8` | PI:4000-4002 | No |

Fix: Add `B ⊆ D` to return types of `lemma_2_6_splitting` and `lemma_2_8`.

### 4. `limit_g` Definition Simplifies Goal

`limit_g` is defined as intersection over intermediate points (CC:874-878):
```lean
fun x z => { φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y }
```

So `ξ ∈ limit_g(x,y)` is exactly `∀ w ∈ limit_dom, x < w < y → ξ ∈ limit_f(w)`.

### 5. "Not Actual" C5 Check Includes Guard

The C5 elimination's actuality check (CE:658-661) includes guard at intermediate domain points. When a counterexample is already handled, the witness comes with guard for free.

## Recommended Implementation Plan

### Phase A: Fill `g_sub_f_insert` (9 sorry sites, ~2 hours)

1. Enrich `lemma_2_6_splitting` return type to include `B ⊆ D`
2. Enrich `lemma_2_8` return type to include `B ⊆ D`
3. Enrich `lemma_2_8_since` similarly
4. Fill 9 sorry sites with uniform pattern: show w = z (only new point), then `g(a,b) ⊆ D = f(w)`

### Phase B: Add `g_sub_g_new` to EliminationResult (~1 hour)

```lean
g_sub_g_new : ∀ a b, Adjacent χ.dom a b → ∀ w ∈ val.dom, w ∉ χ.dom →
    a < w → w < b → χ.g a b ⊆ val.g a w ∧ χ.g a b ⊆ val.g w b
```

This follows from `B ⊆ B'` from `burgessR3Maximal_extension_exists`.

### Phase C: Omega chain guard invariant + limit proof (~3 hours)

Prove by induction on k:
```
∀ k ≥ n+1, ∀ adjacent (a,b) in dom(k) with x ≤ a < b ≤ y: ξ ∈ g_k(a,b)
```

Then for `w ∈ limit_dom` at stage m: `ξ ∈ g_{m-1}(a,b) ⊆ f_m(w) = limit_f(w)`.

## Sorry Site Inventory

| File | Line | Kind | Status |
|------|------|------|--------|
| CE:1150 | g_sub_f_insert | Walk Case B splitting | Solvable with `B ⊆ D` |
| CE:1323 | g_sub_f_insert | Not-condition-(i) splitting | Solvable with `B ⊆ D` |
| CE:1449 | g_sub_f_insert | C5 backward mirror | Solvable with `B ⊆ D` |
| CE:1582 | g_sub_f_insert | C5 backward walk B | Solvable with `B ⊆ D` |
| CE:1753 | g_sub_f_insert | C5 backward not-cond-(i) | Solvable with `B ⊆ D` |
| CE:1930 | g_sub_f_insert | C5 backward walk A | Solvable with `B ⊆ D` |
| CE:2186 | g_sub_f_insert | C4 forward | Solvable with `B ⊆ D` |
| CE:2427 | g_sub_f_insert | C4 backward | Solvable with `B ⊆ D` |
| CE:2594 | g_sub_f_insert | Density | Solvable with `B ⊆ D` (NOT problematic!) |
| CC:1301 | limit guard | limit_satisfies_c5_strong | Needs omega chain invariant |
| CC:1313 | limit guard | limit_satisfies_c5'_strong | Mirror |

## Key File Locations

- EliminationResult: CounterexampleElimination.lean:602-637
- lemma_2_6_splitting: PointInsertion.lean:2798 (B ⊆ D at 2817)
- lemma_2_7: PointInsertion.lean:3616 (B ⊆ D at 3639)
- lemma_2_8: PointInsertion.lean:3977 (B ⊆ D at 4000)
- burgessR3Maximal_extension_exists: RRelation.lean:760
- limit_g definition: ChronicleConstruction.lean:874-878
- limit_satisfies_c5_strong: ChronicleConstruction.lean:1291
- Density elimination: CounterexampleElimination.lean:2443-2616
