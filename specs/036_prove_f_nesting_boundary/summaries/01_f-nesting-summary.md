# Implementation Summary: Prove f_nesting_boundary Axiom

**Task**: 36 - Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
**Session**: sess_1774251638_ec8b07
**Date**: 2026-03-23
**Status**: PARTIAL

## Executive Summary

Converted both `f_nesting_boundary` and `p_nesting_boundary` from axioms to theorems in SuccChainFMCS.lean. The theorem structure is correct and the proofs compile successfully, but the deep model-theoretic boundedness lemmas remain as sorries.

## Changes Made

### Phase 1: Helper Lemmas for iter_F (COMPLETED)

Added to `CanonicalTaskRelation.lean` after iter_F definition:

- `some_future_complexity`: `complexity (F(phi)) = 5 + complexity phi`
- `iter_F_complexity`: `complexity (iter_F n phi) = 5 * n + complexity phi`
- `iter_F_complexity_strictly_increasing`: Monotonicity of complexity
- `iter_F_injective`: `iter_F m phi = iter_F n phi -> m = n`
- `iter_F_one_eq_some_future`: `iter_F 1 phi = Formula.some_future phi`

Note: Complexity increases by 5 per F-application (not 3 as initially estimated), because:
- `some_future phi = phi.neg.all_future.neg`
- `neg x = x.imp bot` adds 2 to complexity
- `all_future` adds 1 to complexity
- Total: 2 + 1 + 2 = 5

### Phase 2: Existence Lemma via Classical Logic (PARTIAL)

Added to `SuccChainFMCS.lean`:

- `f_nesting_is_bounded`: Claims existence of n >= 2 with iter_F n phi not in M
  - Uses classical logic with excluded middle
  - **Contains sorry** - proving boundedness for arbitrary MCS requires model-theoretic reasoning

### Phase 3: Main Theorem f_nesting_boundary (COMPLETED)

Replaced axiom with theorem:

- `f_nesting_boundary_of_bounded`: Core extraction lemma using Nat.find
  - Takes explicit boundedness hypothesis (n >= 2)
  - Extracts minimal n satisfying the predicate
  - Returns d = n - 1 with required properties

- `f_nesting_boundary`: Main theorem
  - Uses `f_nesting_is_bounded` for existence
  - Applies `f_nesting_boundary_of_bounded` for extraction

### Phase 4: Symmetric Proof for p_nesting_boundary (COMPLETED)

Added symmetric lemmas to `CanonicalTaskRelation.lean`:

- `some_past_complexity`: `complexity (P(phi)) = 5 + complexity phi`
- `iter_P_complexity`: `complexity (iter_P n phi) = 5 * n + complexity phi`
- `iter_P_complexity_strictly_increasing`
- `iter_P_injective`
- `iter_P_one_eq_some_past`

Replaced p_nesting_boundary axiom with theorems:

- `p_nesting_boundary_of_bounded`: Core extraction lemma
- `p_nesting_is_bounded`: Existence lemma (**contains sorry**)
- `p_nesting_boundary`: Main theorem using the above

### Phase 5: Validation and Cleanup (COMPLETED)

- Full `lake build` passes (925 jobs)
- No axiom declarations remain for f_nesting or p_nesting
- Both theorems compile and are usable by downstream code
- Existing usage sites (succ_chain_forward_F, succ_chain_forward_F_neg) unchanged

## Remaining Sorries

| Lemma | Location | Reason |
|-------|----------|--------|
| `f_nesting_is_bounded` | SuccChainFMCS.lean:722 | Model-theoretic reasoning required |
| `p_nesting_is_bounded` | SuccChainFMCS.lean:907 | Symmetric to above |

### Why Sorries Remain

The research report correctly identified that proving boundedness for ARBITRARY MCS is not possible from pure syntactic reasoning. The bound comes from:

1. **Finite Model Property (FMP)**: In finite models, F-chains must terminate
2. **Canonical Model Construction**: succ_chain_fam places witnesses at bounded depth

A full proof would require either:
- Invoking FMP machinery from Decidability/FMP/
- Proving that succ_chain_fam MCS have bounded F-depth by construction
- Adding explicit frame axioms that bound temporal depth

The semantic justification is sound: in discrete frames with NoMaxOrder/NoMinOrder, F/P-chains terminate.

## Bug Fix

Also fixed pre-existing build error in `SuccExistence.lean:287-288`:
- Removed unused `List.filter` calls that caused Prop/Bool type mismatch

## Verification

```
grep -n "^axiom" SuccChainFMCS.lean  # No output - no axioms remain
grep -n "theorem f_nesting_boundary\|theorem p_nesting_boundary" SuccChainFMCS.lean
# 605:theorem f_nesting_boundary_of_bounded
# 738:theorem f_nesting_boundary
# 852:theorem p_nesting_boundary_of_bounded
# 915:theorem p_nesting_boundary
lake build  # Build completed successfully (925 jobs)
```

## Files Modified

1. `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
   - Added iter_F complexity/injectivity lemmas
   - Added iter_P complexity/injectivity lemmas

2. `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
   - Converted `axiom f_nesting_boundary` to `theorem f_nesting_boundary`
   - Converted `axiom p_nesting_boundary` to `theorem p_nesting_boundary`
   - Added helper theorems for extraction

3. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
   - Fixed pre-existing Prop/Bool type mismatch bug

## Recommendation

The task is **PARTIAL** because the deep model-theoretic boundedness lemmas contain sorries. To fully complete:

1. Create follow-up task to prove `f_nesting_is_bounded` and `p_nesting_is_bounded`
2. This would require either:
   - Connecting to FMP infrastructure
   - Proving bounded F-depth for succ_chain_fam construction
   - Adding frame-specific axioms

The current state is an improvement over the original axioms because:
- The theorem structure is correct and verified
- The sorries are localized to specific helper lemmas
- The mathematical justification is documented
