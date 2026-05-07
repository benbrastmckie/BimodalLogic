# Research Report: Close Strategy for 4 Remaining Sorry Sites

## Summary

The 4 remaining sorry sites (2 in CounterexampleElimination.lean, 2 in ChronicleConstruction.lean) can ALL be closed with a single coherent approach. The domain_guard infrastructure added in Phase 6 was correct in direction but incomplete in the identity case. The recommended fix changes the `by_cases` check condition to include domain_guard, making the identity case trivially satisfied via `push_neg`.

## Current Sorry Sites

### CounterexampleElimination.lean (2 sorries)

**Line 2322** (c5_forward identity case):
```
h_guard : ∀ a b, Adjacent χ.dom a b → x ≤ a → b ≤ y → ξ ∈ χ.g a b
w : ℚ, hw : w ∈ χ.dom, hxw : x < w, hwy : w < y
⊢ ξ ∈ χ.f w
```

**Line 2817** (c5_backward identity case, mirror):
```
h_guard : ∀ a b, Adjacent χ.dom a b → y ≤ a → b ≤ x → ξ ∈ χ.g a b
w : ℚ, hw : w ∈ χ.dom, hyw : y < w, hwx : w < x
⊢ ξ ∈ χ.f w
```

Both are in the `¬h_actual` branch where `val = χ` (identity elimination). The adj_guard from `push_neg at h_actual` cannot yield `ξ ∈ f(w)` because `burgessR3` does not imply `g ⊆ f` at endpoints. The `until_guard` axiom (`(φ U ψ) → φ`) was removed in task 113 as invalid under open guard semantics.

### ChronicleConstruction.lean (2 sorries)

**Line 1467** (limit_satisfies_c5_strong):
```
h_until : ξ.untl η ∈ limit_f(x), hy_dom : y ∈ limit_dom, hxy : x < y, hy_η : η ∈ limit_f(y)
w ∈ limit_dom, x < w, w < y
⊢ ξ ∈ limit_f(w)
```

**Line 1479** (limit_satisfies_c5'_strong, mirror):
```
h_since : ξ.snce η ∈ limit_f(x), hy_dom : y ∈ limit_dom, hyx : y < x, hy_η : η ∈ limit_f(y)
w ∈ limit_dom, y < w, w < x
⊢ ξ ∈ limit_f(w)
```

These call `limit_satisfies_c5_weak` which discards adj_guard and domain_guard from `omega_chain_c5_witness`.

## Key Findings

### 1. domain_guard Infrastructure Was Correctly Added (Phase 6)

The `domain_guard` field in `C5ForwardWalkResult` / `C5BackwardWalkResult`:
```
domain_guard : ∀ w ∈ χ.dom, start < w → w < witness → ξ ∈ val.f w
```
is provable in ALL walk cases:
- **Base case**: Vacuous (start = max/min, no old points beyond)
- **Condition (i)**: ξ ∈ f(x') via `conj_left_mcs`, recursion for deeper points
- **Split case**: Vacuous (midpoint between adjacent pair, no old points in interval)

This field is already proved and compiles.

### 2. The CElim Identity Case Is NOT Provable From adj_guard Alone

The identity case has `val = χ` (no chronicle extension) and only adj_guard from `push_neg`. Since `BurgessR3Maximal(f(a), g(a,b), f(b))` does NOT imply `g(a,b) ⊆ f(a)` or `g(a,b) ⊆ f(b)`, and the until_guard axiom is invalid in this logic, there is no way to derive `ξ ∈ f(w)` from `ξ ∈ g(a,w)` at a single chronicle level.

### 3. Option A (Change by_cases Condition) Is Viable

Change the condition in `eliminate_potential_counterexample` from:
```
¬∃ y ∈ χ.dom, x < y ∧ η ∈ f(y) ∧ adj_guard(y)
```
to:
```
¬∃ y ∈ χ.dom, x < y ∧ η ∈ f(y) ∧ adj_guard(y) ∧ domain_guard(y)
```

Where `domain_guard(y) := ∀ w ∈ χ.dom, x < w → w < y → ξ ∈ f(w)`.

**Why this works**: The negation `¬∃ y, (A ∧ B ∧ C)` is WEAKER than `¬∃ y, (A ∧ B)`. The walk's `h_no_wit` argument uses the STRONGER negation. With the weaker negation, all contradiction derivations in the walk still work because we can provide domain_guard at each contradiction site:

- **h_guard_implies_no_event** (line 863/1974): Witness is x' (adjacent successor). Domain_guard for x' is vacuous since (start, x') is adjacent with no points between.

- **h_no_wit_x'** (line 889-912): Composed from condition (i) giving ξ ∈ f(x') plus recursive domain_guard. Specifically: w between start and x' is impossible (adjacent); w = x' gets ξ from conj_left_mcs; w between x' and y gets ξ from recursive domain_guard.

- **eliminate_potential_counterexample** contradiction sites (lines 1974, 2502): Same pattern as h_guard_implies_no_event — witness is adjacent successor, domain_guard is vacuous.

**Identity case closes automatically**: With the stronger `by_cases` condition, `push_neg at h_actual` gives:
```
∃ y ∈ χ.dom, x < y ∧ η ∈ f(y) ∧ adj_guard(y) ∧ domain_guard(y)
```
So both adj_guard AND domain_guard are directly available. No sorry needed.

### 4. CC Sorries Close With Current Infrastructure (After CElim Fix)

Once CElim identity cases are closed, `omega_chain_c5_witness` returns both adj_guard and domain_guard. The CC proof needs refactoring:

**Instead of**: calling `limit_satisfies_c5_weak` (which discards guards)
**Do**: inline the enumeration and retain adj_guard + domain_guard

For `w ∈ limit_dom` with `x < w < y`, case-split on `w ∈ dom_{n+1}`:

**Case A: w ∈ dom_{n+1}**
- Sub-case w ∈ dom_n: domain_guard gives ξ ∈ f_{n+1}(w). By f_agrees chain, f_{n+1}(w) = f_n(w) = limit_f(w).
- Sub-case w ∈ dom_{n+1} \ dom_n: The unique new point at stage n+1 IS the witness y (verified: walk base case adds y, split case adds z=witness, condition (i) preserves from recursion). So w = y by `omega_chain_dom_new_unique`. Contradicts w < y.

**Case B: w ∉ dom_{n+1}**
- Since x, y ∈ dom_{n+1} and x < w < y, find adjacent (a, b) in dom_{n+1} containing w (helper lemma needed).
- x ≤ a and b ≤ y (from adjacency + x,y in domain).
- adj_guard gives ξ ∈ g_{n+1}(a, b).
- `adj_g_mem_limit_f` gives ξ ∈ limit_f(w).

### 5. Helper Lemma Needed

**`finset_containing_adjacent`**: Given Finset dom, points x y ∈ dom with x < w < y and w ∉ dom, there exist a b ∈ dom adjacent with a < w < b and x ≤ a and b ≤ y.

This is a standard Finset argument using filter/max'/min'. About 25-30 lines.

## Whether domain_guard Should Be Kept or Reverted

**KEEP domain_guard**. The field is correctly proved in all walk cases and is essential for the proof. Without it, there is no known way to derive ξ ∈ f(w) for old domain points between start and witness. The g-value approach (using C2'/burgessR3) does not work because burgessR3 does not imply g ⊆ f.

## Recommended Implementation Plan

### Phase 1: CElim Identity Case Fix (Closes 2 sorries)

**Estimated: 80-120 lines of changes in CounterexampleElimination.lean**

1. **Change walk h_no_wit type** (both c5_forward_walk and c5_backward_walk):
   ```
   -- OLD:
   h_no_wit : ¬∃ y ∈ χ.dom, pt < y ∧ η ∈ χ.f y ∧
     (∀ a b, Adjacent χ.dom a b → pt ≤ a → b ≤ y → ξ ∈ χ.g a b)
   -- NEW:
   h_no_wit : ¬∃ y ∈ χ.dom, pt < y ∧ η ∈ χ.f y ∧
     (∀ a b, Adjacent χ.dom a b → pt ≤ a → b ≤ y → ξ ∈ χ.g a b) ∧
     (∀ w ∈ χ.dom, pt < w → w < y → ξ ∈ χ.f w)
   ```

2. **Update contradiction sites in walks** (~4 sites per walk, 2 walks):
   At each site where h_no_wit is applied, provide the domain_guard argument. All are either vacuous (adjacent pair with no points between) or composed from condition (i) + recursion.

3. **Update by_cases in eliminate_potential_counterexample** (2 sites: forward + backward):
   Change the by_cases condition to match the new h_no_wit type. The identity case (¬h_actual) now gets domain_guard from push_neg automatically.

4. **Update h_no_wit derivation in eliminate_potential_counterexample**:
   Where the function derives h_no_wit for the walk call (currently extracting 3rd conjunct of h_actual), now extract the 3rd conjunct of the stronger condition.

### Phase 2: CC Strong C5 (Closes 2 sorries)

**Estimated: 80-100 lines of changes in ChronicleConstruction.lean**

1. **Add helper lemma** `finset_containing_adjacent` (~30 lines)

2. **Rewrite `limit_satisfies_c5_strong`** (~40 lines):
   - Remove call to `limit_satisfies_c5_weak`
   - Inline enumeration: get n₀ from hx, get n from surjectivity, derive hx_n and h_until_n
   - Call `omega_chain_c5_witness` to get y, adj_guard, domain_guard
   - Prove limit_dom/limit_f facts for y
   - For the guard (ξ ∈ limit_g x y): intro w hw hxw hwy
   - Case split on `w ∈ dom_{n+1}` (decidable)
   - Use domain_guard + f_agrees for w ∈ dom_{n+1}
   - Use adj_guard + adj_g_mem_limit_f for w ∉ dom_{n+1}

3. **Mirror for `limit_satisfies_c5'_strong`** (~40 lines, symmetric)

### Dependency Order

Phase 1 MUST be done before Phase 2:
- Phase 2 uses `omega_chain_c5_witness` which depends on `EliminationResult.c5_forward_witness`
- Phase 1 closes the EliminationResult's domain_guard sorry
- Without Phase 1, omega_chain_c5_witness's domain_guard is sorry-tainted

### Risk Assessment

- **Phase 1**: Medium risk. The walk changes are mechanical but touch ~8-12 sites. Each needs careful handling of the domain_guard argument.
- **Phase 2**: Low risk. Well-understood infrastructure (adj_g_mem_limit_f, limit_f_eq, omega_chain_dom_new_unique).
- **Total**: Net reduction from 4 sorries to 0. No new sorries introduced.

### Estimated Effort

- Phase 1: 2-3 hours (complex CElim edits)
- Phase 2: 1-2 hours (straightforward CC restructuring)
- Total: 3-5 hours
