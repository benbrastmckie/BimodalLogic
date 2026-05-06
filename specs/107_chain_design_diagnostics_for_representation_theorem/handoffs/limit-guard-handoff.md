# Handoff: Limit Guard Closure — 2 remaining sorry sites

## Status: 8 g_sub_g_new sorries CLOSED, 2 limit guard sorries remain

## What Was Done

### Phase 1: All 8 g_sub_g_new sorry sites closed

CounterexampleElimination.lean is now sorry-free. All 8 cases were closed:

1. **Lines 1543, 1683 (c5_backward n=0, Walk Case A)**: Vacuous — new point y placed before all old points, so `a < w` fails since `w = y < min ≤ a`.

2. **Lines 1409, 1877, 2062 (not-cond-i splits)**: Enriched the intermediate existentials (`h_split_result`, `h_split_pw`, `h_split_result` for backward) with `B ⊆ B'` and `B ⊆ B''` fields from the enriched splitting lemma returns. Updated all sub-case destructurings. Proof follows the template at CE:~1189.

3. **Lines 2340, 2603, 2792 (C4 forward/backward, density)**: Added `h_g_sub_B'` and `h_g_sub_B''` field extractions from the direct `lemma_2_6_splitting` result. Same template proof.

### Build Status
`lake build` passes (1097 jobs). 2 sorry sites remain in ChronicleConstruction.lean:1301 and 1313.

## Remaining Work: Limit Guard (ChronicleConstruction.lean:1301, 1313)

### Goal (line 1301)
```
⊢ ξ ∈ limit_f A h_mcs h_nubr3 w
```
Given: `untl(ξ,η) ∈ limit_f(x)`, `η ∈ limit_f(y)`, `x < w < y`, `w ∈ limit_dom`.

### Goal (line 1313) — mirror
```
⊢ ξ ∈ limit_f A h_mcs h_nubr3 w
```
Given: `snce(ξ,η) ∈ limit_f(x)`, `η ∈ limit_f(y)`, `y < w < x`, `w ∈ limit_dom`.

### Why This Is Hard

The limit guard proof requires showing that the guard formula ξ is in limit_f(w) for ALL intermediate points w between x and y. The difficulty is:

1. **limit_g is semantic**: `limit_g(x,y) = { φ | ∀ w ∈ limit_dom, x < w < y → φ ∈ limit_f(w) }` — it's defined by universal quantification, not by any finite-stage g-value.

2. **No direct finite-stage guarantee**: The C5 witness `y` from `limit_satisfies_c5_weak` gives `η ∈ limit_f(y)` but NO guard. The `c5_forward_witness` field only returns `∃ y, η ∈ val.f(y)` without the guard.

3. **g-propagation gap**: At any finite stage k, `g_k(x,y) = g_{n+1}(x,y)` (by g_agrees since x,y ∈ dom(n+1)). But when w enters at stage m between adjacent (a,b), g_sub_f_insert gives `g_{m-1}(a,b) ⊆ f_m(w)`. The gap is: `g_{m-1}(x,y) ⊄ g_{m-1}(a,b)` in general (g is a function, not monotone in endpoints).

### Possible Approaches

#### Approach A: Enrich c5_forward_witness with guard
Add a field to EliminationResult:
```lean
c5_forward_guard : pc.kind = .c5_forward → pc.x ∈ χ.dom →
    Formula.untl pc.ξ pc.η ∈ χ.f pc.x →
    ∀ y ∈ val.dom, pc.x < y → pc.η ∈ val.f y →
    ∀ w ∈ val.dom, pc.x < w → w < y → pc.ξ ∈ val.f w
```
This gives the guard at the FINITE stage. Then lift to limit. But proving this field for each elimination case requires showing ξ propagates through the splitting construction, which is non-trivial.

#### Approach B: Inductive g-containment at omega chain level
Prove: for all k ≥ n+1, for all adjacent (a,b) in dom(k) with x ≤ a < b ≤ y, `g_{n+1}(x,y) ⊆ g_k(a,b)`.
- Base: k = n+1, (a,b) = (x,y) if adjacent
- Step: from k to k+1, use g_sub_g_new when a point splits within [x,y]
Then: g_sub_f_insert gives g_k(a,b) ⊆ f_{k+1}(w), so g_{n+1}(x,y) ⊆ f_{k+1}(w).

Problem: requires proving ξ ∈ g_{n+1}(x,y), which depends on the C5 elimination structure.

#### Approach C: BX axiom approach at limit level
Use BX5 (self-accumulation) to show untl(ξ,η) propagates forward from x, giving ξ at each intermediate point. But in a dense order, this requires transfinite induction or a Zorn-like argument.

#### Approach D: Revise c5_forward_witness return type
Change to: `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ pc.ξ ∈ val.g pc.x y`
Adding the guard formula in the finite g-value. Then the limit proof uses: ξ ∈ g_{n+1}(x,y) = g_k(x,y), and for any w entering at stage m between adjacent (a,b) with x ≤ a < b ≤ y, need g_k(x,y) ⊆ g_{m-1}(a,b). This still requires Approach B.

### Recommended Path

**Approach D + B combined**: 
1. Add `pc.ξ ∈ val.g pc.x y` to c5_forward_witness (for all cases that insert a new point)
2. Prove the inductive g-containment lemma (Approach B)
3. Close the limit guard using steps 1+2

This is the cleanest and most maintainable approach but requires significant work (~200-400 lines of new infrastructure).

## Files Modified in This Session
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`: Closed all 8 g_sub_g_new sorry sites, enriched 3 intermediate existentials
