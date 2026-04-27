# Teammate B Findings: Detailed Audit of Every Elimination Function

**Task**: 107 — Chain Design Diagnostics for Representation Theorem
**Date**: 2026-04-26
**Focus**: g-handling in each elimination function, what must change

---

## Executive Summary

**Every elimination function sets `g' = χ.g` unchanged.** No elimination function constructs new g-values for newly-created adjacent pairs. Instead, the architecture uses a **two-phase approach**: (1) eliminate counterexample (preserving g verbatim), then (2) call `rebuild_g` which assigns fresh `BurgessR3Maximal` g-values to ALL adjacent pairs in the new domain. This is the correct design --- the g-values from elimination are immediately overwritten by `rebuild_g`.

The `g_agrees` and `g_ext` fields in `EliminationResult` are both **trivially `rfl`** because `χ'.g = χ.g` in every case. They exist solely to satisfy the `EliminationResult` interface; they carry no mathematical content.

---

## Per-Function Audit

### 1. `eliminate_C5_counterexample` (C5 forward — add endpoint after)

**Location**: Lines 167–204

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. Sets `χ'.g = χ.g` (line 187: `χ.g` passed directly in chronicle literal) |
| **Input signature** | `h_c0 : χ.c0`, `ce : C5Counterexample χ` — does NOT take `c2'` |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` (not `EliminationResult`) |
| **Where does new MCS D come from?** | `lemma_2_4` — gives MCS C with `η ∈ C`, `g_content(f(x)) ⊆ C`, `P(U(ξ,η)) ∈ C` |
| **New point placement** | `y > all domain points` (via `exists_rat_gt_finset`) |
| **Adjacent pairs created** | `(max_old, y)` where `max_old` is the previous rightmost domain point |
| **Seed naturally available for BurgessR3Maximal** | `f(max_old)` and `C` (= new MCS at y). The `lemma_2_4` result provides `g_content(f(x)) ⊆ C` which is relevant but `x` may not be `max_old`. |
| **Calls lemma_2_4?** | YES (line 182–183) |
| **Calls lemma_2_6_full?** | No |
| **g_agrees proof** | `fun _ _ _ _ => rfl` (trivial, g unchanged) |
| **g_ext proof** | `fun _ _ => rfl` (trivial, g unchanged) |
| **Changes needed** | None for elimination itself. `rebuild_g` handles new g-values post-elimination. |

### 2. `eliminate_C5'_counterexample` (C5 backward — add endpoint before)

**Location**: Lines 211–249

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (line 235) |
| **Input signature** | `h_c0 : χ.c0`, `ce : C5'Counterexample χ` — does NOT take `c2'` |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | Manual construction: `since_P` axiom gives `P(η) ∈ f(x)`, then `past_temporal_witness_seed_consistent` + Lindenbaum. Does NOT use `lemma_2_4`. |
| **New point placement** | `y < all domain points` (via `exists_rat_lt_finset`) |
| **Adjacent pairs created** | `(y, min_old)` where `min_old` is the previous leftmost domain point |
| **Seed naturally available** | `f(min_old)` and new MCS `C`. The seed is `{η} ∪ h_content(f(x))` via past temporal witness. |
| **Calls lemma_2_4?** | No (uses manual seed construction) |
| **Calls lemma_2_6_full?** | No |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. `rebuild_g` handles. |

### 3. `eliminate_C4_counterexample` (C4 forward — insert between, Until)

**Location**: Lines 304–433

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (lines 324, 326) |
| **Input signature** | `h_c0 : χ.c0`, **`h_c2' : χ.c2'`**, `ce : C4Counterexample χ` — TAKES c2' |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | Three cases: (1) `¬γ ∈ f(x)` → D = f(x); (2) `¬γ ∈ f(y)` → D = f(y); (3) Hard case: `γ ∈ f(x)` AND `γ ∈ f(y)` → uses `burgessR3_gamma_not_in_B` to show `γ ∉ g(w, w_next)`, then `dcs_neg_insert_consistent` + Lindenbaum |
| **New point placement** | `z` between `x` and `y` (via `exists_rat_between_not_in_finset`) |
| **Adjacent pairs created** | Splits interval: old pair `(x, y)` (if adjacent) broken into `(x, z)` and `(z, y)` potentially, plus other adjacencies may change |
| **Seed naturally available for BurgessR3Maximal** | Hard case: D is extended from `{γ.neg} ∪ g(w, w_next)`. The g(w, w_next) is a DCS from c2'. The endpoints `f(w)` and `f(w_next)` are available. |
| **Calls lemma_2_4?** | No |
| **Calls lemma_2_6_full?** | No |
| **Uses c2' for?** | Getting `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` for the hard case bridging argument |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. `rebuild_g` handles. |

### 4. `eliminate_C4'_counterexample` (C4 backward — insert between, Since)

**Location**: Lines 443–547

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (line 461) |
| **Input signature** | `h_c0 : χ.c0`, **`h_c2' : χ.c2'`**, `ce : C4'Counterexample χ` — TAKES c2' |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | Mirror of C4: three cases using `burgessR3_gamma_not_in_B_since` / `burgessR3_gamma_not_in_B_since_nested` |
| **New point placement** | `z` between `y` and `x` (via `exists_rat_between_not_in_finset`) |
| **Adjacent pairs created** | Same as C4 mirror |
| **Seed naturally available** | Mirror of C4: `{γ.neg} ∪ g(w_prev, w)` in hard case |
| **Uses c2' for?** | Getting `BurgessR3Maximal(f(w_prev), g(w_prev, w), f(w))` |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. |

### 5. `eliminate_g_prop_counterexample` (G-propagation forward)

**Location**: Lines 564–598

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (line 587) |
| **Input signature** | `h_c0 : χ.c0`, `x y : Rat`, `α : Formula`, membership proofs, `h_adj : Adjacent χ.dom x y`, `h_G`, `h_not` — does NOT take c2' |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | `g_propagation_witness` — gives MCS D with `α ∈ D` and `g_content(f(x)) ⊆ D` |
| **New point placement** | `z = (x + y) / 2` (midpoint, breaking adjacency) |
| **Adjacent pairs created** | `(x, z)` and `(z, y)` — breaks the old adjacency `(x, y)` |
| **Seed naturally available** | `{α} ∪ g_content(f(x))`. Endpoints: `f(x)` and D for left pair, D and `f(y)` for right pair. |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. |

### 6. `eliminate_h_prop_counterexample` (H-propagation backward)

**Location**: Lines 604–641

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (line 630) |
| **Input signature** | `h_c0 : χ.c0`, `x y : Rat`, `α : Formula`, `h_adj : Adjacent χ.dom y x`, `h_H`, `h_not` — does NOT take c2' |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | `H_implies_P_mcs` → `past_temporal_witness_seed_consistent` → Lindenbaum. Gives D with `α ∈ D` and `h_content(f(x)) ⊆ D`. |
| **New point placement** | `z = (y + x) / 2` (midpoint, breaking adjacency) |
| **Adjacent pairs created** | `(y, z)` and `(z, x)` |
| **Seed naturally available** | `{α} ∪ h_content(f(x))`. Endpoints: `f(y)` and D, D and `f(x)`. |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. |

### 7. `eliminate_density_counterexample` (density — insert between)

**Location**: Lines 653–684

| Property | Value |
|----------|-------|
| **g-value for new pairs** | None. `χ'.g = χ.g` (line 672) |
| **Input signature** | `h_c0 : χ.c0`, `x y : Rat`, membership proofs, `h_adj : Adjacent χ.dom x y` — does NOT take c2' |
| **Return type** | Raw existential `∃ χ' : Chronicle, ...` |
| **Where does new MCS D come from?** | No new MCS needed! Uses `f(z) = f(x)` (line 672: `if q = z then χ.f x`) |
| **New point placement** | `z = (x + y) / 2` (midpoint) |
| **Adjacent pairs created** | `(x, z)` and `(z, y)` |
| **Seed naturally available** | `f(x)` copied to z. For BurgessR3Maximal: `(f(x), ?, f(x))` for left pair and `(f(x), ?, f(y))` for right pair. |
| **g_agrees / g_ext** | Both `rfl` |
| **Changes needed** | None. |

### 8. `eliminate_potential_counterexample` (the dispatcher)

**Location**: Lines 767–1047

| Property | Value |
|----------|-------|
| **Input signature** | `χ : Chronicle`, `h_c0 : χ.c0`, **`h_c2' : χ.c2'`**, `pc : PotentialCounterexample` |
| **Return type** | `EliminationResult χ pc` (structured result) |
| **Pattern** | Match on `pc.kind`, check if actual counterexample via `by_cases`, delegate to specific eliminator or return identity |
| **g handling** | Passes through from sub-eliminators: all `g_agrees` and `g_ext` fields are either `rfl` (identity case) or extracted from the sub-eliminator's proof |
| **Density case** | Inlined (lines 993–1046) rather than calling `eliminate_density_counterexample` |

---

## Analysis of `g_agrees` and `g_ext`

### `g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b`

**Currently**: Always `rfl` because `val.g = χ.g` (same function). This is trivially true.

**Purpose**: States that g-values for OLD domain pairs are preserved. Since g is entirely unchanged, this is trivially satisfied.

**After `rebuild_g`**: This property would be FALSE because `rebuild_g` replaces g-values wholesale. But `g_agrees` is only needed within the elimination step, before `rebuild_g` runs.

### `g_ext : ∀ a b, val.g a b = χ.g a b`

**Currently**: Always `rfl` because `val.g = χ.g`.

**Purpose**: States that g is extensionally equal (stronger than `g_agrees`). Needed for omega-chain C3 preservation proof.

**Note**: This is the key property. Since elimination preserves g exactly, and then `rebuild_g` completely replaces it, the C3 preservation must work through the `rebuild_g` step, not through elimination.

---

## Architecture: Two-Phase g-Value Assignment

The omega chain step (line 305-315 of ChronicleConstruction.lean) is:

```
omega_chain (n+1) = rebuild_g (eliminate(omega_chain(n), enum(unpair(n).2)))
```

**Phase 1: Elimination** — adds new point, sets `f` for new point, leaves `g` unchanged.
**Phase 2: `rebuild_g`** — replaces ALL g-values:
- Adjacent pairs: `g(x,y) = BurgessR3Maximal(f(x), -, f(y))` via `burgessR3Maximal_exists_general`
- Non-adjacent pairs: `g(x,y) = ∅`

This means:
1. The `g_ext` field in `EliminationResult` is consumed by the chain invariant proofs BETWEEN elimination and rebuild.
2. After rebuild, g-values are entirely determined by adjacency structure and `f`-values.
3. The g-values at the LIMIT are defined differently (C3 three-way intersection for non-adjacent pairs).

---

## What is `burgessR3Maximal_exists_general`?

This is the existence theorem for BurgessR3Maximal sets. Given two MCS endpoints A and C, it produces a DCS B with `BurgessR3Maximal(A, B, C)`. This is the core "seed" for g-values.

The `rebuild_g` function uses `Classical.choice` to pick such a B non-constructively.

---

## Summary of Findings

1. **All 7 elimination functions set g unchanged** (`χ'.g = χ.g`). None constructs new g-values.

2. **g_agrees and g_ext are both trivially `rfl`** in every case. They carry no mathematical content.

3. **The real g-value assignment happens in `rebuild_g`**, called after every elimination step in the omega chain.

4. **`rebuild_g` uses `burgessR3Maximal_exists_general`** to assign g-values to adjacent pairs, taking `f(x)` and `f(y)` as endpoints.

5. **C4/C4' eliminators need c2'** because they use the EXISTING g-values (from the previous `rebuild_g` call) in the bridging argument. Specifically: `h_R3M := h_c2' w w_next h_adj` extracts `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))`.

6. **C5/C5' and g_prop/h_prop eliminators do NOT need c2'** — they only need c0.

7. **If the "empty g" problem exists**, it is NOT in the elimination functions themselves. It would be in:
   - The singleton chronicle initialization (`g := fun _ _ => ∅`, line 66) — but this is vacuously fine since a singleton has no pairs.
   - The `rebuild_g` function — but this assigns proper BurgessR3Maximal values.
   - The LIMIT construction — where non-adjacent g-values need to be defined by C3 intersection.

8. **No changes are needed to the elimination functions for g-handling.** The two-phase architecture (eliminate then rebuild) is sound. Any "empty g" issues live elsewhere in the construction.
