# Handoff: Close Sorry Sites (Phase 6)

## Session
sess_1778114001_749277

## Status
2 of 4 sorry sites CLOSED. 2 remain (reduced scope).

## What Was Done

### CounterexampleElimination.lean (2 sorries -> 0)

Changed the `by_cases h_actual` condition in `eliminate_potential_counterexample` (both
forward and backward C5 cases) to include `domain_guard` in the existential:

**Before**: `¬∃ y ∈ dom, x < y ∧ η ∈ f(y) ∧ adj_guard(y)`
**After**: `¬∃ y ∈ dom, x < y ∧ η ∈ f(y) ∧ adj_guard(y) ∧ domain_guard(y)`

This required updating 8 sites:
1. `c5_forward_walk` parameter type (line ~697)
2. `h_guard_implies_no_event` in forward walk (line ~863)
3. `h_no_wit_x'` derivation in forward walk (line ~890)
4. `by_cases h_actual` in forward eliminate (line ~1814)
5. `h_guard_implies_no_event` in forward eliminate (line ~1986)
6. Same 5 changes mirrored for backward walk and backward eliminate

At each h_no_wit application site, the domain_guard argument is:
- **Adjacent pair**: vacuous (no domain points between adjacent points)
- **Condition (i)**: composed from conj_left_mcs (ξ ∈ f(x') from ξ∧U(ξ,η) ∈ f(x'))
  plus recursive domain_guard

The identity cases (push_neg at h_actual) now yield BOTH adj_guard and domain_guard
directly, eliminating the 2 sorries.

### ChronicleConstruction.lean (2 sorries -> 2 sorries, different)

The original 2 sorries in `limit_satisfies_c5_strong` and `limit_satisfies_c5'_strong`
were replaced with a cleaner proof structure that handles 2 of 3 cases:

- **w ∈ dom_n (old point)**: domain_guard gives ξ ∈ f_{n+1}(w) -> limit_f(w). DONE.
- **w ∉ dom_{n+1} (not at stage n+1)**: find containing adjacent pair in dom_{n+1},
  adj_guard + adj_g_mem_limit_f gives ξ ∈ limit_f(w). DONE.
- **w ∈ dom_{n+1} \ dom_n AND y ∈ dom_n**: 2 SORRY remain (1 forward, 1 backward).

Also added `exists_containing_adjacent` helper lemma (~30 lines).

## Remaining 2 Sorries: Root Cause

The problematic case is: w is the unique new point at step n+1 (w ∈ dom_{n+1} \ dom_n),
AND the C5 witness y is an old point (y ∈ dom_n). We need ξ ∈ f_{n+1}(w), but:

- `domain_guard` only covers χ.dom = dom_n points
- `adj_guard` gives ξ ∈ g_{n+1}(a,w), not ξ ∈ f_{n+1}(w)
- `g_sub_f_insert` gives g_n(a,b) ⊆ f_{n+1}(w), but we don't have ξ ∈ g_n(a,b)
- BurgessR3Maximal does NOT imply g ⊆ f

### Why This Case Is Actually Vacuous

When y ∈ dom_n, the elimination at step n was the **identity case** (¬h_actual):
- The witness came from `push_neg at h_actual`
- `val = χ`, so dom_{n+1} = dom_n
- Therefore w ∈ dom_{n+1} = dom_n, contradicting w ∉ dom_n

When y ∉ dom_n (non-identity case):
- Both w and y are new points
- omega_chain_dom_new_unique gives w = y
- But w < y, contradiction

So the case **cannot arise**. The issue is formalizing "y ∈ dom_n implies dom_{n+1} = dom_n".

### Proposed Fix: omega_chain_no_new_when_witness_old

Add a lemma (or field to EliminationResult) stating:

```
theorem omega_chain_no_new_when_witness_old (n : Nat) (x y : Rat) (ξ η : Formula)
    (hy_old : y ∈ dom_n)
    (hy_witness : y ∈ dom_{n+1} ∧ x < y ∧ η ∈ f_{n+1}(y) ∧ adj_guard ∧ domain_guard)
    (hn_eq : counterexample_enum ... = ⟨x, 0, ξ, η, .c5_forward⟩) :
    ∀ u ∈ dom_{n+1}, u ∈ dom_n
```

This follows from the structure of eliminate_potential_counterexample:
- hn_eq says step n processes THIS C5 counterexample
- y ∈ dom_n with the witness properties means the ¬h_actual branch was taken
- In ¬h_actual, val = χ, so dom_{n+1} = dom_n

Alternatively, add a boolean field `is_identity : Bool` or `no_new_points : ∀ u ∈ val.dom, u ∈ χ.dom ∨ ...` to EliminationResult.

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

## Build Status
`lake build` passes. 2 sorries in ChronicleConstruction.lean.
