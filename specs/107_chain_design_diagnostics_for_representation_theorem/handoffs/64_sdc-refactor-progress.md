# Handoff: SDC-Maximality Refactor Progress

## Session
- **Session ID**: sess_1778221275_3b41e2
- **Date**: 2026-05-08
- **Agent**: lean-implementation-agent (2nd attempt)

## Summary of Changes Made

### Files Modified

1. **ChronicleTypes.lean**: `BurgessR3Maximal` definition changed from CUD to SDC.
   - First conjunct: `SetDeductivelyClosed B` (was `ClosedUnderDerivation B`)
   - Maximality clause: `SetDeductivelyClosed D` (was `ClosedUnderDerivation D`)

2. **RRelation.lean**: Zorn construction updated for SDC.
   - `burgessR3DCSExtensions`: family restricted to SDC sets
   - `burgessR3Maximal_extension_exists`: seed parameter is SDC, chain union preserves SDC (consistency by finite character + CUD by directed union)
   - `BurgessR3Maximal_sdc`, `BurgessR3Maximal_consistent`: new accessor lemmas
   - `BurgessR3Maximal_cud`: changed to use `h.1.2` (SDC.2 = CUD)
   - `burgessR3Maximal_exists_from_seed`: proves DC({eta}) is SDC from eta in A (MCS)
   - `burgessR3Maximal_with_guard`: added `h_dc_cons : SetConsistent (deductiveClosure ({eta}))` parameter
   - **RRelation.lean builds successfully**

3. **PointInsertion.lean** (partial):
   - `BurgessR3Maximal_extension_fails`: added `h_cons : SetConsistent (deductiveClosure ({delta} ∪ B))` parameter
   - `BurgessR3Maximal_neg_or_ext_fails`: passes `deductiveClosure_consistent h_cons` to extension_fails, `.1.2` for CUD
   - `cud_contains_theorems h_r3m.1` -> `cud_contains_theorems h_r3m.1.2` (4 sites)
   - `lemma_2_6_splitting`: Zorn seeds changed from `h_B_dcs` to `h_r3m.1` (SDC)
   - `lemma_2_7`: partial fix with case split, inconsistent case uses `sorry`

4. **CounterexampleElimination.lean**: NOT yet modified

## Remaining Errors (18+ after partial fixes)

### PointInsertion.lean

#### Critical: lemma_2_7, lemma_2_8, lemma_2_7_since, lemma_2_8_since DC({xi}∪B) seeds

**Pattern**: Each of these 4 functions uses DC({xi}∪B) as a Zorn seed to get xi in B'. With SDC Zorn family, DC({xi}∪B) must be SDC. When {xi}∪B is inconsistent (xi.neg in B), this fails.

**Current state**: lemma_2_7 has a case split with `sorry` in the inconsistent branch. The other three are unfixed.

**Approach for each**: Case-split on `SetConsistent ({xi} ∪ B)`:
- Consistent: `deductiveClosure_is_dcs h_xi_B_cons` gives SDC seed, proceed as before
- Inconsistent: xi.neg in B. The function's return type promises `xi in B'`. Since any SDC B' containing B also contains xi.neg, it cannot contain xi. So this return value is IMPOSSIBLE.

**Resolution options**:
1. **Prove the inconsistent case is unreachable**: Show xi.neg cannot be in B given the context (untl(xi, eta) in A and BurgessR3Maximal(A, B, C)). This requires a mathematical argument I was unable to find.

2. **Change return type**: Return `xi in B' OR xi.neg in B` instead of `xi in B'`. This requires updating ~10 call sites in CounterexampleElimination.lean. Each caller already case-splits on `xi in g` vs `xi not-in g`. In the `xi not-in g` branch, if additionally `xi.neg in g = B`: the adjacent-pair guard condition `xi in B'` cannot be satisfied. The caller must handle this by an alternative proof that the c5 witness doesn't need xi in the guard interval.

3. **Add a consistency parameter**: `(h_cons : SetConsistent ({xi} ∪ B))` to lemma_2_7/2_8/etc., making the inconsistent case the caller's responsibility. The callers then need to prove `SetConsistent ({xi} ∪ g(x,y))` from context, which may or may not be available.

**Recommended**: Option 3. The callers likely have enough context to prove consistency of {xi}∪B. When BurgessR3Maximal(A, B, C) with A, C MCS: if the caller has xi in some g-value, and the g-values are produced by SDC Zorn, the caller can trace consistency. Alternatively, the callers can case-split and handle `xi.neg in B` separately using the `neg_or_ext_fails` unified interface.

#### burgessR3Maximal_with_guard callers (lines 5182, 5333)

The new `h_dc_cons` parameter needs to be provided. The callers have `burgessR(A, gamma, C)` and `burgessRSince(C, gamma, A)`. Need `SetConsistent (DC({gamma}))`.

**Fix**: Prove DC({gamma}) is consistent from the context. If gamma is derivable from some MCS element, {gamma} is consistent. Look for gamma in A or C at each call site.

### CounterexampleElimination.lean (estimated 40-50 errors)

#### Mechanical `.1` -> `.1.2` changes (~40 sites)
- `h_r3m.1` where CUD is needed -> `h_r3m.1.2`
- `h_r3m_adj.1` where CUD is needed -> `h_r3m_adj.1.2`

#### BurgessR3Maximal_bot_not_mem (line 254)
**Trivial once SDC change is complete**: `h_r3m.1.1` gives `SetConsistent B`, so bot not-in B.

#### BurgessR3Maximal_extension_fails callers (~6 sites)
Each needs `SetConsistent (DC({delta}∪B))`. Most callers already have context for this. The `neg_or_ext_fails` unified interface handles both cases.

#### lemma_2_7/2_8 callers (~20 sites)
Pass `h_r3m_adj.1.2` instead of `h_r3m_adj.1` for the CUD parameter.

## Mathematical Analysis

### Key Insight: Burgess's DCS = CUD (not SDC)

Burgess 1982 defines DCS as "deductively closed set" which does NOT require consistency. His R-maximality (Definition 2.5) is over all DCS extensions, including inconsistent ones. So CUD-maximality is Burgess's actual definition.

However, `BurgessR3Maximal_bot_not_mem` (consistency of g-values) is NOT provable from CUD-maximality because `burgessR3(A, Set.univ, C)` is consistent in J0 (satisfiable on discrete orders where open guard intervals can be empty).

The SDC change restricts the Zorn family to consistent sets, ensuring the maximal element is consistent. This is a STRENGTHENING of Burgess's construction that preserves all needed properties:
- `BurgessR3Maximal_neg_or_ext_fails` still works (consistent case uses extension_fails, inconsistent case gives neg in B)
- The Zorn chain union preserves SDC (consistency by finite character)
- The neg-until witness extraction still works through the unified interface

### The lemma_2_7 Blocker

When xi.neg in B (CUD B is SDC), {xi}∪B is inconsistent. DC({xi}∪B) = Set.univ, not SDC. Cannot seed Zorn from it.

The question of whether `xi.neg in B` can actually occur when `untl(xi, eta) in A` and `BurgessR3Maximal(A, B, C)` with `xi not-in B` is OPEN. I was unable to prove it impossible. If it IS possible, the return type of lemma_2_7 must change, cascading through CounterexampleElimination.

## Build Status

- ChronicleTypes.lean: modified, untested (depends on downstream)
- RRelation.lean: **builds successfully**
- PointInsertion.lean: 18+ errors remaining (1 sorry in lemma_2_7 inconsistent branch)
- CounterexampleElimination.lean: not yet touched (~40-50 errors expected)

## Estimated Remaining Work

- Mechanical `.1` -> `.1.2` in CE: ~2 hours
- BurgessR3Maximal_bot_not_mem: ~5 minutes (trivial with SDC)
- extension_fails caller fixes in PI: ~2 hours
- Zorn seed fixes (lemma_2_7/2_8/since mirrors): ~4-8 hours depending on approach
- burgessR3Maximal_with_guard callers: ~2 hours
- Total: ~10-14 hours

## Files NOT Modified
- CounterexampleElimination.lean
- ChronicleConstruction.lean
- ChronicleToCountermodel.lean
- Completeness.lean
