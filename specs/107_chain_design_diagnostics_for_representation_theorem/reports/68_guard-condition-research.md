# Guard Condition Research: Burgess C5a vs Code Counterexample Check

## 1. Burgess C5a Definition (Paper, Section 2.10)

**Burgess C5a (p.372)**:
> Whenever x ∈ dom f and U(ξ, η) ∈ f(x), there is some y ∈ dom f with x < y and **ξ ∈ f(y)** and **η ∈ g(x, y)**.

In Burgess notation: ξ = event, η = guard. A **counterexample to C5a** is a triple (x, ξ, η) where U(ξ, η) ∈ f(x) but NO such y exists.

**Convention mapping** (our code ↔ Burgess):
- Our `untl(guard=ξ, event=η)` = Burgess `U(event=ξ, guard=η)` — **SWAPPED**
- So Burgess's "η ∈ g(x,y)" = our "ξ ∈ g(x,y)" (our guard in g)
- Burgess's "ξ ∈ f(y)" = our "η ∈ f(y)" (our event at endpoint)

**Key**: Burgess's C5a counterexample inherently involves **g-values** (η ∈ g(x,y) in Burgess = ξ ∈ g(x,y) in our code).

## 2. Our Code's Counterexample Check

**Location**: `CounterexampleElimination.lean:661-664`

```lean
by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.ξ pc.η ∈ χ.f pc.x ∧
    ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
      ∀ z ∈ χ.dom, pc.x < z → z < y →
        pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z
```

This checks: NO y exists in dom where:
1. `η ∈ f(y)` (event at endpoint) — matches Burgess
2. `ξ ∈ f(z)` for all intermediate z in dom — **WEAKER than Burgess**
3. `untl(ξ,η) ∈ f(z)` for all intermediate z — extra condition (for forward walk)

**The divergence**: Our code checks `ξ ∈ f(z)` (guard in f-values of intermediate DOMAIN POINTS), NOT `ξ ∈ g(x,y)` (guard in the interval set).

## 3. Why f-values ≠ g-values

By C3: `g(x,y) = g(x,z₁) ∩ f(z₁) ∩ g(z₁,z₂) ∩ ... ∩ f(zₖ) ∩ g(zₖ,y)`.

So `ξ ∈ g(x,y)` requires:
- `ξ ∈ f(zᵢ)` for ALL intermediate domain points — **our code checks this** ✓
- `ξ ∈ g(zⱼ, zⱼ₊₁)` for ALL adjacent sub-pairs — **our code does NOT check this** ✗

The adjacent-pair g-values are determined by BurgessR3Maximal, and a formula being in f-values at endpoints does NOT guarantee it's in the interval DCS. The g-values can be strictly smaller than the intersection of f-values.

## 4. The "Not Actual" Case

When `h_actual` is false (line 1473-1490), the code returns χ **unchanged** and provides the witness:

```lean
c5_forward_witness := by
    intro _ h_mem h_until
    push_neg at h_actual
    obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until
    exact ⟨y, hy_dom, hy_lt, hy_η⟩
```

The discarded `_` contains: `∀ z ∈ χ.dom, pc.x < z → z < y → pc.ξ ∈ χ.f z ∧ untl(pc.ξ, pc.η) ∈ χ.f z`.

This provides `ξ ∈ f(z)` for finite intermediate z but NOT `ξ ∈ g(x,y)`. At the limit, new points w are inserted between x and y at later stages. For these new w, we'd need `ξ ∈ f(w)`, which requires `ξ ∈ g_k(a,b)` for the adjacent pair (a,b) that was split to insert w. Without `ξ ∈ g(x,y)` at the base stage, we cannot propagate.

## 5. Burgess's Construction Doesn't Have This Problem

In Burgess, the omega chain processes only **actual** counterexamples (where C5a with g-values FAILS). When a counterexample IS NOT actual, it means `∃ y, ξ ∈ f(y) ∧ η ∈ g(x,y)` — the guard IS in g. So:

- **Actual counterexample** → eliminated by inserting a point with g-values containing the guard (Lemma 2.4 gives B with η ∈ B, and g(x,y) = B)
- **Not actual** → the guard is ALREADY in some g(x,y), no action needed

Our code's weaker f-value check means: when the code declares "not actual", it does NOT have the guard in g. The "not actual" case is "already satisfied in f-values" but NOT "already satisfied in the Burgess C5a sense."

## 6. Impact on the Sorry

The sorry at `ChronicleConstruction.lean:1445` needs:
```
Given: w ∈ limit_dom, x < w < y (where y is the C5 witness from omega_chain)
Show: ξ ∈ limit_f(w)
```

The proof strategy requires ξ to be in a finite-stage g-value `g_k(a,b)` for some adjacent pair (a,b) containing w. The existing infrastructure (`adj_g_mem_limit_f` at line 1406) then propagates to limit_f(w).

**For the "actual" case (n=0)**: `lemma_2_4` is used. `lemma_2_4_with_guard` exists (PointInsertion.lean:4846) and returns `γ ∈ B` (guard in interval set). Switching to `lemma_2_4_with_guard` would give ξ ∈ g(x,y), and the propagation works.

**For the "actual" case (n≥1)**: The forward walk + splitting uses lemma_2_7 which provides η ∈ D (event in new point) but NOT ξ ∈ D (guard). The g_old ⊆ B' and g_old ⊆ B'' propagation preserves old g-values, but ξ was specifically NOT in g_old (that's why we're splitting).

**For the "not actual" case**: Guard is in f-values but not guaranteed in g-values. Cannot propagate to later-inserted points.

## 7. Recommended Fix

### Approach: Strengthen "not actual" check to match Burgess C5a

**Change the counterexample check** from f-value based to g-value based. The "not actual" condition should be the negation of the FULL Burgess C5a counterexample:

```lean
-- CURRENT (f-value check):
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
    ∀ z ∈ χ.dom, pc.x < z → z < y →
      pc.ξ ∈ χ.f z ∧ Formula.untl pc.ξ pc.η ∈ χ.f z

-- PROPOSED (g-value check, matching Burgess):
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g pc.x y
```

When "not actual" under this check: ∃ y with η ∈ f(y) AND ξ ∈ g(x,y). This directly gives the guard in g, which propagates via `adj_g_mem_limit_f`.

### Impact Assessment

**Files changed**: 
1. `CounterexampleElimination.lean` — Change h_actual condition, update "not actual" branch, update "actual" n=0 and n≥1 branches
2. `ChronicleConstruction.lean` — Add `c5_forward_guard` field to `EliminationResult` or strengthen `c5_forward_witness`, close sorry

**What changes in the "actual" case**:
The "actual" case now means: there is NO y with η ∈ f(y) AND ξ ∈ g(x,y). Some triples that were "actual" under the old check (ξ in f-values but not g-values) may now be "not actual" — fine, since those already have the guard in g.

The old f-value check + untl persistence was used for the forward walk in n≥1. The forward walk logic inspects `ξ ∈ g(x,x')` (condition (i)) anyway (line 825), so the walk is already g-value aware for intermediate steps. The base check just needs alignment.

**What changes in the "not actual" case**:
The witness now includes `ξ ∈ g(x,y)`, which is exactly what's needed. No construction needed — just return the chronicle unchanged with the g-value witness.

### Effort Estimate

- **EliminationResult changes**: Add `c5_forward_guard_witness` field (or strengthen existing `c5_forward_witness` to include g-value). ~20 lines.
- **h_actual condition change**: Change the `by_cases` discriminant. ~5 lines.
- **"Not actual" branch**: Update to use the new witness (trivial — the g-value comes from the negation). ~10 lines.
- **"Actual" n=0 case**: Switch `lemma_2_4` → `lemma_2_4_with_guard`. ~15 lines (mostly destructuring updates).
- **"Actual" n≥1 cases**: The forward walk and splitting may need updates. Most of the walk logic already checks g-values (condition (i)). The Walk Case A (reaching max_old) needs `lemma_2_4_with_guard`. Walk Case B (splitting at u_max, u_next) needs the splitting lemma to produce g-value witnesses. ~50 lines.
- **Since mirror**: Mirror all changes for c5_backward. ~100 lines.
- **Close the sorry**: With g-value witnesses flowing through `EliminationResult`, prove `limit_satisfies_c5_strong` using `adj_g_mem_limit_f`. ~30 lines.
- **Total estimate**: ~230 lines of changes, moderate complexity.

### Alternative: Simpler Two-Phase Approach

Instead of refactoring the counterexample check, an alternative:

1. **Phase 1**: In the "actual" case, use `lemma_2_4_with_guard` to get ξ ∈ g(x,y). Add a `c5_guard_in_g` field to `EliminationResult` that records "when the C5 counterexample was actual, ξ ∈ g_new(x,y)".

2. **Phase 2**: In the "not actual" case, prove that ξ ∈ f(z) for intermediate z AND the existing BurgessR3Maximal conditions imply ξ ∈ g(x,y) at that stage. This uses the fact that if ξ ∈ f(z) for all intermediate z, and the chronicle satisfies C2', then ξ ∈ g(x,y) follows from the C3 decomposition combined with g-value membership of ξ in each adjacent sub-interval.

But this Phase 2 is exactly the hard part — showing ξ ∈ g(zⱼ, zⱼ₊₁) for adjacent pairs, which requires ξ to be in the BurgessR3Maximal interval set. This is not guaranteed by ξ ∈ f(zⱼ) alone. So the alternative doesn't actually simplify things.

## 8. Summary

| Aspect | Burgess C5a | Our Code |
|--------|-------------|----------|
| Guard check | η ∈ g(x,y) (g-values) | ξ ∈ f(z) for z ∈ dom (f-values) |
| "Not actual" provides | Guard in g ✓ | Guard in f only ✗ |
| Propagation to limit | Automatic via C3 | Blocked — guard not in g |
| Fix needed | N/A | Align check with Burgess |

The recommended path is to align the counterexample check with Burgess C5a, use `lemma_2_4_with_guard` for the actual n=0 case, and propagate g-value witnesses through `EliminationResult`. The infrastructure is mostly in place (`lemma_2_4_with_guard`, `adj_g_mem_limit_f`, `g_sub_f_insert`, `g_sub_g_new`).
