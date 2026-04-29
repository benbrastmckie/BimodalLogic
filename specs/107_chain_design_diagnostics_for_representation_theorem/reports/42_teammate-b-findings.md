# Teammate B Findings: Resolution Path 4 -- Removing c2' from Finite-Stage Invariant

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Focus**: Can `omega_chain_c2'` be removed, making all 7 sorry sites moot?
**Date**: 2026-04-28

## Key Findings

### Finding 1: `omega_chain_c2'` is NEVER used downstream of the omega chain

The theorem `omega_chain_c2'` (line 279 of `ChronicleConstruction.lean`) extracts `c2'` from each finite stage. **It is referenced nowhere else in the entire codebase**:

- NOT in `ChronicleToCountermodel.lean` (zero matches for `c2'`, `hc2'`, or `omega_chain_c2'`)
- NOT in `Completeness.lean` (zero matches)
- NOT in any other file

The `ValidChronicle` structure (which includes `hc2'`) is defined in `ChronicleTypes.lean` line 443 but **never instantiated or used anywhere**. It is dead code.

The limit construction in `ChronicleToCountermodel.lean` uses only:
- `limit_dom`, `limit_f`, `limit_g`
- `limit_c0` (from `omega_chain_c0`)
- `limit_satisfies_c5_weak`, `limit_satisfies_c5'_weak`
- `limit_forward_G`, `limit_backward_H`
- `limit_dom_dense`

None of these depend on `omega_chain_c2'`.

### Finding 2: However, `h_c2'` IS used in sorry-free proofs WITHIN elimination functions

The hypothesis `h_c2' : chi.c2'` is a **parameter** to `eliminate_C4_counterexample` (line 305) and `eliminate_C4'_counterexample` (line 466). Inside these functions, it is used in **sorry-free code**:

- **Line 409**: `have h_r3m_wn := h_c2' w w_next h_adj` -- extracts `BurgessR3Maximal` for the adjacent pair `(w, w_next)` to perform the `burgessR3_gamma_not_in_B` bridging argument in the C4 hard case.
- **Line 546**: `have h_r3m_pw := h_c2' w_prev w h_adj` -- mirror for C4'.

This is the crux: **c2' is consumed at the finite stage level to prove C4 elimination works**. The C4 hard case (when gamma is in both f(x) and f(y)) needs `R(f(w), g(w, w_next), f(w_next))` -- the R-maximality of g for adjacent pairs -- to invoke Lemma 2.6's `burgessR3_gamma_not_in_B`. This is exactly Burgess's argument in Section 2.9 Case n=0.

### Finding 3: Burgess 1982 confirms c2' (R-maximality) is essential for C4 elimination

In Burgess's paper (Section 2.9, the Counterexample Lemma for C4a):

> "Case n = 0. By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6..."

C2' is the premise that triggers Lemma 2.6, which is the tool for inserting a new point z with the negated guard. Without R-maximality of g(x,y), Lemma 2.6 cannot be applied. There is no alternative route in Burgess's proof.

### Finding 4: c2' at the limit IS vacuously true (confirmed)

The limit domain is dense (`limit_dom_dense` is sorry-free). Dense domains have no adjacent pairs. `Chronicle.c2'` quantifies only over adjacent pairs. So c2' at the limit is vacuously true. Lines 921-948 of `ChronicleConstruction.lean` confirm this and note that the old placeholder proofs have been deleted.

### Finding 5: The 7 sorry sites are in `EliminationResult.c2'` -- maintaining c2' through each step

All 7 sorry sites in `CounterexampleElimination.lean` are at the same field: `c2' := sorry` inside the `EliminationResult` construction. They arise because when a new point z is inserted:

| Sorry Site | Lines | Case | Problem |
|-----------|-------|------|---------|
| 1 | 830 | C5 forward | New adj pair (x_max, y): need BurgessR3Maximal for g with new endpoints |
| 2 | 868 | C5' backward | New adj pair (y, x_min): mirror |
| 3 | 908 | C4 forward | New adj pairs around inserted z: need to split g via absorption |
| 4 | 946 | C4' backward | Mirror |
| 5 | 982 | G-prop forward | New adj pair after splitting: need g from absorption |
| 6 | 1014 | H-prop backward | Mirror |
| 7 | 1130 | Density | Sub-case (pc.x, z): burgessR3(f(x), g(x,y), f(x)) -- self-pair, doesn't follow |

### Finding 6: Removing c2' from EliminationResult would break C4/C4' elimination

If we remove `c2'` from the `EliminationResult` structure, then:
- `omega_chain` no longer carries `c2'` through stages
- `eliminate_potential_counterexample` no longer receives `h_c2'` as input
- `eliminate_C4_counterexample` loses its `h_c2'` parameter
- The sorry-free `burgessR3_gamma_not_in_B` call at line 409 breaks

This is a **circular dependency**: C4 elimination needs c2' as input, but maintaining c2' in the output is where all the sorry sites are.

## Recommended Approach

**Resolution Path 4 (removing c2' entirely) is NOT feasible.** The hypothesis is wrong: c2' IS used downstream of the omega chain -- not at the limit level, but within each finite elimination step. C4/C4' elimination requires R-maximality (c2') of the adjacent pair to invoke Burgess's Lemma 2.6.

### Alternative: Focus on fixing the 7 sorry sites directly

The real problem is not that c2' is unnecessary, but that **maintaining c2' through elimination steps requires constructing proper g-values for new adjacent pairs**. This is the actual mathematical content that needs to be formalized:

1. **For C5/C5' (sorry sites 1-2)**: When a new endpoint y is added beyond/before the domain, the new adjacent pair (x_max, y) needs a g-value. This requires applying Lemma 2.4 to get R(f(x_max), g(x_max, y), f(y)).

2. **For C4/C4' (sorry sites 3-4)**: When z is inserted between x and y, the old g(x,y) must be split into g(x,z) and g(z,y) using Lemma 2.6. This is exactly what Burgess does in Section 2.9.

3. **For G-prop/H-prop (sorry sites 5-6)**: Similar to C4, need to split g when inserting a point.

4. **For density (sorry site 7)**: The self-pair case `burgessR3(f(x), g(x,y), f(x))` where f(z) = f(x). This needs a different g-value -- g(x,z) should be constructed via Lemma 2.4 applied to f(x) and f(x), not reuse the old g(x,y).

### Alternative weaker approach: Weaken c2' to c2 (r-relation without maximality)

If BurgessR3Maximal could be weakened to just `r3Relation` (i.e., c2 instead of c2'), the sorry sites become easier. But Burgess's proof of C4 elimination specifically requires R-maximality (the "R" in R(A,B,C)) to apply Lemma 2.6. So weakening is also not viable for the current proof strategy.

### The real fix: Use Lemma 2.4/2.6 to construct g-values in elimination functions

Each elimination function should:
1. Construct the new chronicle with proper g-values (using `lemma_2_4` or `burgessR3_split` / Lemma 2.6 decomposition)
2. Prove c2' for the result using those g-values

This is mathematically well-defined but requires formalizing the g-value construction that Burgess leaves to the reader ("details are left to the reader").

## Evidence/Examples

### Usage chain showing c2' is necessary

```
omega_chain step n+1
  -> eliminate_potential_counterexample(chi, h_c0, h_c2', pc)  [line 259]
    -> (for C4 case) eliminate_C4_counterexample(h_c0, h_c2', ce)  [line 901]
      -> h_c2' w w_next h_adj  [line 409, SORRY-FREE]
      -> burgessR3_gamma_not_in_B h_mcs_w h_r3_wn ...  [line 417, SORRY-FREE]
```

### Burgess 1982 Section 2.9 (verbatim)

> "Case n = 0. By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Let z = (x + y)/2. Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and let C3 determine the other values of g'(w,z) and g'(z,w)."

This shows that Burgess's C4 elimination:
1. Uses C2' to get R(A,B,C) -- the R-maximality
2. Applies Lemma 2.6 to split g into B' and B''
3. Assigns these as the new g-values for the new adjacent pairs

Our code does step 1 (sorry-free at line 409) but lacks steps 2-3 (the sorry sites).

## Confidence Level

**High** -- The analysis is based on exhaustive grep/search of the codebase and careful reading of both the Lean code and Burgess 1982. The conclusion that c2' cannot be removed is definitive: it is consumed in sorry-free code within C4/C4' elimination. The 7 sorry sites exist because g-value construction for new adjacent pairs (Burgess's "details left to the reader") has not been formalized.
