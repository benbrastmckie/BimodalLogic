# Teammate A Findings: Sorry Closure Path Analysis

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-06
**Angle**: Primary — exact sorry state and closure chain

## Key Findings

### 1. Exact State of the 2 Sorry Sites

**Sorry #1 — ChronicleConstruction.lean:1445**
```lean
theorem limit_satisfies_c5_strong ...
    (h_until : Formula.untl ξ η ∈ limit_f A h_mcs h_nubr3 x) :
    ∃ y ∈ limit_dom A h_mcs h_nubr3, x < y ∧ η ∈ limit_f A h_mcs h_nubr3 y ∧
      ξ ∈ limit_g A h_mcs h_nubr3 x y := by
  obtain ⟨y, hy_dom, hxy, hy_η⟩ := limit_satisfies_c5_weak A h_mcs h_nubr3 x hx ξ η h_until
  refine ⟨y, hy_dom, hxy, hy_η, ?_⟩
  intro w hw hxw hwy
  sorry  -- Need: ξ ∈ limit_f A h_mcs h_nubr3 w
```

**Sorry #2 — ChronicleConstruction.lean:1457** (Since mirror, identical structure)

The goal at the sorry is: given `w ∈ limit_dom` with `x < w < y`, prove `ξ ∈ limit_f(w)`.

By the definition of `limit_g` (line 878):
```lean
limit_g x z := { φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f y }
```

So `ξ ∈ limit_g(x,y)` unpacks to exactly `∀ w ∈ limit_dom, x < w → w < y → ξ ∈ limit_f(w)`.

### 2. The Infrastructure That EXISTS (Sorry-Free)

| Infrastructure | Location | Status | Purpose |
|---|---|---|---|
| `adj_g_mem_limit_f` | ChronicleConstruction.lean:1406 | Sorry-free | If `φ ∈ g_k(a,b)` for adjacent (a,b) at stage k, then `φ ∈ limit_f(w)` for all w between a,b |
| `adj_g_mem_f_at_stage` | ChronicleConstruction.lean:1347 | Sorry-free | Core induction: g-membership propagates through splitting to f at later stages |
| `omega_chain_g_sub_f_insert` | ChronicleConstruction.lean:1300 | Sorry-free | Old g-values flow into new f-values when a point is inserted |
| `omega_chain_g_sub_g_new` | ChronicleConstruction.lean:1314 | Sorry-free | Old g-values flow into sub-interval g-values after splitting |
| `omega_chain_dom_new_unique` | ChronicleConstruction.lean:1281 | Sorry-free | At most one new point per elimination step |
| `omega_chain_g_agrees` | ChronicleConstruction.lean:360 | Sorry-free | g-values unchanged for old domain pairs |
| `omega_chain_g_agrees_le` | ChronicleConstruction.lean:371 | Sorry-free | g-values preserved at later stages for old pairs |
| `lemma_2_4_with_guard` | PointInsertion.lean:4846 | Sorry-free | Returns `γ ∈ B` (guard in interval set) |
| `burgessR3Maximal_with_guard` | RRelation.lean:1593 | Sorry-free | Extension from DC({η}) gives η ∈ B |
| `burgessR3Maximal_extension_exists` | RRelation.lean:760 | Sorry-free | Zorn from seed S gives S ⊆ B |

### 3. The Infrastructure That's MISSING

The closure chain requires TWO things the sorry sites don't have:

**Gap A: `c5_forward_witness` is too weak.** The `EliminationResult.c5_forward_witness` field (CounterexampleElimination.lean:612-614) returns:
```lean
∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y
```
It does NOT return `pc.ξ ∈ val.g pc.x y` (guard in the interval g-value).

**Gap B: `omega_chain_c5_witness` inherits Gap A.** It returns (line 398):
```lean
∃ y ∈ dom(n+1), x < y ∧ η ∈ f(n+1)(y)
```
No guard info. The sorry at line 1445 needs `ξ ∈ g_k(a,b)` for some adjacent pair (a,b) containing (x,y) at some finite stage k, so that `adj_g_mem_limit_f` can lift to `ξ ∈ limit_f(w)`.

### 4. What Burgess C5a Alignment Has Already Been Done

The h_actual counterexample check (CounterexampleElimination.lean:663-664) is ALREADY aligned with Burgess C5a g-values:
```lean
¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧ pc.ξ ∈ χ.g pc.x y
```
The "not actual" branch at line 1478-1479 destructures this as:
```lean
push_neg at h_actual
obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until
```
The **discarded** `_` IS `pc.ξ ∈ χ.g pc.x y` — the guard info exists but is thrown away!

### 5. Root Cause Summary

There are 3 independent places where guard info needs to flow but doesn't:

| Case | Where | What's Missing |
|---|---|---|
| **Not actual** (χ unchanged) | CE line 1479 | Discard `pc.ξ ∈ χ.g pc.x y` instead of threading |
| **n=0 (Walk Case A)** | CE line 848 | Uses `lemma_2_4` instead of `lemma_2_4_with_guard`; B_l24 doesn't contain guard |
| **n≥1 splitting** | CE lines 1036-1069 | `lemma_2_7` / `lemma_2_8` / `lemma_2_6_splitting` don't return `xi ∈ B'` |

## Recommended Approach

### Step 1: Strengthen `EliminationResult.c5_forward_witness` (and Since mirror)

Add guard to the witness type:
```lean
c5_forward_witness : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ 
    ∀ a b, Adjacent χ.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b
```

**Or simpler**: Add a separate field:
```lean
c5_forward_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
  Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
  ∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y_witness → pc.ξ ∈ val.g a b
```

**Estimated effort**: ~50 lines (type change) + updates across all 18 case constructions in CE.

### Step 2: Fix the 3 cases to produce guard info

**2a. Not actual case** (CE line 1470-1487): Stop discarding the guard. Thread `pc.ξ ∈ χ.g pc.x y` through `c5_forward_witness`. Since χ is unchanged, the guard is already in g. ~5 lines.

**2b. Walk Case A** (CE line 848): Switch `lemma_2_4` → `lemma_2_4_with_guard` to get `pc.ξ ∈ B_l24`. Since `g'(max_old, y) = B_l24`, this gives `pc.ξ ∈ g'(max_old, y)`. For walk pairs (x, x'), ..., (u_prev, u_max): guard ∈ g from condition (i) check at line 819. ~30 lines.

**2c. Walk Case B** (CE splitting at u_max, u_next, line 1005-): The splitting result (line 1016-1023) gives `χ.g u_max u_next ⊆ B'` and `⊆ D`. Two sub-cases:
- If guard was in `χ.g u_max u_next`: it propagates via subset to B', D, B''.
- If guard was NOT in `χ.g u_max u_next`: condition (i) at line 819 means walk never reached this pair.

Need to verify the walk invariant: at every walk step, guard ∈ g(walk[i], walk[i+1]). This follows from condition (i) check. ~40 lines.

**2d. n=0 case** (CE line 665-): This is the actual counterexample with pc.x at max_old. Uses `lemma_2_4` at line 679. Switch to `lemma_2_4_with_guard`. ~15 lines.

### Step 3: Fix lemma_2_7 / lemma_2_8 to produce xi ∈ B' (OPTIONAL but ideal)

Currently `lemma_2_7` (PointInsertion.lean:3616) starts the Zorn construction for B' from seed B:
```lean
obtain ⟨B', h_B_sub_B', _, h_B'_max⟩ := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
  h_B_dcs h_r3_ABD h_no_univ_AD
```

But the code ALREADY has at line 3687-3688:
```lean
have h_burgessR_xi : burgessR A xi D :=
  burgessRSince_implies_burgessR h_mcs_A h_D_mcs h_burgessRSince_xi
```

**Fix**: Replace `burgessR3Maximal_extension_exists` with `burgessR3Maximal_with_guard` (or change seed from B to DC(B ∪ {xi})):

**Option A** (use existing `burgessR3Maximal_with_guard`): This gives `xi ∈ B'` but starting from DC({xi}) rather than B. The output would NOT guarantee `B ⊆ B'` — only `xi ∈ B'`. This is WRONG because `B ⊆ B'` is needed for the `g_sub_g_new` field.

**Option B** (change Zorn seed to DC(B ∪ {xi})): Start from DC(B ∪ {xi}) instead of B. Need:
1. `SetDeductivelyClosed (DC(B ∪ {xi}))` — true by definition of deductiveClosure
2. `burgessR3(A, DC(B ∪ {xi}), D)` — from `burgessR3(A, B, D)` and `burgessR(A, xi, D)` + `burgessRSince(D, xi, A)`, extend via right-monotonicity
3. Then B' ⊇ DC(B ∪ {xi}) ⊇ {xi} gives `xi ∈ B'`, and B ⊆ DC(B ∪ {xi}) ⊆ B' gives `B ⊆ B'`

**This is the right fix.** Estimated effort: ~40 lines for lemma_2_7, ~40 for lemma_2_8, ~80 for Since mirrors.

However, the tricky part is step 2: proving `burgessR3(A, DC(B ∪ {xi}), D)`. This needs:
- `burgessRSet(A, DC(B ∪ {xi}), D)`: for any φ ∈ DC(B ∪ {xi}), `burgessR(A, φ, D)`. If φ is derivable from B ∪ {xi}, we need the right-monotonicity of untl: from ⊢ β → φ (where β ∈ B) and `untl(β, δ) ∈ A`, get `untl(φ, δ) ∈ A` via BX2/BX3. This requires some derivation-unwinding.
- Similarly for `burgessRSetSince`.

A helper lemma `burgessR3_deductiveClosure_union` would be valuable. ~50 lines.

### Step 4: Strengthen omega_chain_c5_witness

Add guard to the return type (ChronicleConstruction.lean:392):
```lean
∃ y ∈ dom(n+1), x < y ∧ η ∈ f(n+1)(y) ∧ 
  ∀ a b, Adjacent dom(n+1) a b → x ≤ a → b ≤ y → ξ ∈ g(n+1)(a, b)
```

This threads the EliminationResult guard info up to the omega chain. ~20 lines.

### Step 5: Close the sorry (ChronicleConstruction.lean:1445)

With guard at every adjacent pair between x and y at stage n+1, use `adj_g_mem_limit_f` for each w:
- w is at some later stage m ≥ n+1
- w sits between some adjacent pair (a,b) at stage n+1
- guard ∈ g(n+1)(a,b) from Step 4
- `adj_g_mem_limit_f` gives guard ∈ limit_f(w)

~30 lines.

### Step 6: Mirror for Since

~identical to Steps 1-5 for the backward direction. ~same effort.

## Dependency Chain

```
Step 3 (lemma_2_7/2_8 xi ∈ B') ──┐
Step 2d (n=0: lemma_2_4_with_guard)──┤
Step 2a (not actual: keep guard) ────┤
Step 2b (Walk A: lemma_2_4_with_guard)──> Step 1 (strengthen EliminationResult)
Step 2c (Walk B: walk invariant) ────┤     |
                                      ├──> Step 4 (omega_chain_c5_witness)
                                      |     |
                                      └──> Step 5 (close sorry)
```

## Effort Estimate

| Step | Lines | Difficulty | Hours |
|---|---|---|---|
| 1. Strengthen EliminationResult | ~50 | Medium (type change cascades to 18 cases) | 2-3 |
| 2a. Not actual case | ~5 | Easy | 0.5 |
| 2b. Walk Case A | ~30 | Medium | 1 |
| 2c. Walk Case B | ~40 | Hard (walk invariant) | 2 |
| 2d. n=0 case | ~15 | Easy | 0.5 |
| 3. lemma_2_7/2_8 + mirrors | ~200 | Hard (DC(B∪{xi}) proof) | 4-6 |
| 4. omega_chain_c5_witness | ~20 | Easy | 0.5 |
| 5. Close sorry + mirror | ~60 | Medium | 1-2 |
| **Total** | **~420** | | **12-16h** |

**Alternative without Step 3**: If guard info can be obtained WITHOUT strengthening lemma_2_7/2_8 (e.g., by proving guard ∈ g from the existing `B ⊆ B'` + additional reasoning), Steps 1-2 + 4-5 alone suffice: ~200 lines, 7-9h.

## Evidence/Examples

- `limit_g` definition (line 878): universal quantifier over limit_dom, reducing to `∀ w ∈ limit_dom, x < w < y → ξ ∈ limit_f(w)`.
- `adj_g_mem_limit_f` (line 1406): the bridge from finite-stage g to limit f. This is the key tool — everything upstream is about getting guard into g at a finite stage.
- `h_actual` check (line 663-664): already g-value based (Burgess C5a aligned).
- `lemma_2_4_with_guard` (line 4846): already exists and is sorry-free, returns `γ ∈ B`.
- `burgessR3Maximal_with_guard` (RRelation.lean:1593): already exists and is sorry-free.
- `burgessR A xi D` exists at lemma_2_7 line 3688: the infrastructure for DC(B∪{xi}) is already in place.

## Confidence Level

**High** — The mathematical path is clear and all infrastructure tools exist. The remaining work is threading guard info through 18 mechanical case constructions and one non-trivial lemma (burgessR3 for DC(B∪{xi})).
