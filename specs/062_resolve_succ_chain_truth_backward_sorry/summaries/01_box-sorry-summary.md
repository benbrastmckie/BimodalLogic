# Implementation Summary: Resolve SuccChainTruth Box Backward Sorry

**Task**: 62 - Resolve backward Box sorry in succ_chain_truth_lemma and correct misleading documentation
**Status**: Partial (BLOCKED by task 56 build failure)
**Session**: sess_1774415448_f2d8a2
**Date**: 2026-03-24

## Summary

Corrected misleading documentation that falsely claimed `succ_chain_truth_forward` was "sorry-free". The forward direction DOES depend on `sorryAx` because the Imp case structurally requires the backward direction for sub-formulas. Additionally, documented WHY the Box backward case is mathematically unprovable in the singleton-Omega architecture.

## Changes Made

### Phase 1: Documentation Correction (COMPLETED)

1. **SuccChainTruth.lean** - Fixed documentation:
   - Lines 33-39: Replaced claim about forward direction being independent with accurate sorry status
   - Lines 248-294: Replaced brief sorry comment with comprehensive explanation
   - Lines 331-350: Replaced false "sorry-free" claim with accurate dependency explanation

2. **SuccChainCompleteness.lean** - Fixed axiom dependency section:
   - Lines 28-37: Clarified that `succ_chain_truth_forward` depends on `sorryAx`
   - Added pointer to sorry-free alternatives

### Phase 2: Algebraic Analysis (COMPLETED)

Studied `UltrafilterChain.lean` to understand why BFMCS can prove Box backward:

**Key insight**: The BFMCS bundles ALL families agreeing on Box-content. When `Box phi` fails in some MCS:
1. `Diamond(neg phi)` is in M0 (MCS negation completeness)
2. `box_theory_witness_exists` provides W' with `neg phi in W'` and same box-class
3. The shifted chain from W' is IN the bundle
4. If phi were in ALL families, it contradicts `neg phi in W'`

**Why singleton-Omega fails**: There are no witness families. When Box backward needs to derive `Box psi in MCS` from "psi in all families", with only ONE family it reduces to `psi in MCS -> Box psi in MCS`, which doesn't hold without S5 necessitation for arbitrary MCS content.

### Phase 3: Resolution Strategy (COMPLETED)

The sorry is mathematically correct - the goal IS unprovable in singleton-Omega. Resolution:
1. Keep sorry with comprehensive documentation explaining unprovability
2. Document the BFMCS alternative that CAN prove Box backward
3. Point users to sorry-free completeness paths

### Phase 4: Verification (PARTIAL)

- **Sorry count**: No new sorries introduced (1 sorry remains, same as before)
- **Axiom count**: No new axioms introduced
- **Build status**: BLOCKED by task 56 error (missing `restricted_bounded_witness`)

## Verification Results

```
# Sorry check - only 1 sorry in SuccChainTruth (the Box backward case)
grep -c "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean
# Result: 1 (in actual proof code, excluding comments)

# Axiom check - no new axioms
grep -c "^axiom " Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean
# Result: 0
```

## Build Blocker

Task 56 introduced a build error by removing `restricted_bounded_witness` from SuccChainFMCS.lean while code still references it:

```
error: Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2215:19:
  Unknown identifier `restricted_bounded_witness`
```

This prevents running `lake build` to verify my documentation changes compile.

## Files Modified

| File | Lines Changed | Description |
|------|---------------|-------------|
| `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` | ~50 | Fixed misleading documentation, added comprehensive sorry explanation |
| `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` | ~10 | Fixed axiom dependency claims |
| `specs/062_resolve_succ_chain_truth_backward_sorry/plans/01_box-sorry-resolution.md` | Phase markers | Updated status |

## Mathematical Explanation (for README)

The Box backward case requires showing:
```
∀ sigma ∈ Omega, truth sigma t psi → Box psi ∈ MCS
```

For singleton Omega = {h}, this reduces to:
```
truth h t psi → Box psi ∈ MCS
```
= (by backward IH)
```
psi ∈ MCS → Box psi ∈ MCS
```

This is the S5 necessitation property for MCS content, which does NOT hold in general. An MCS can contain `psi` but not `Box psi` - the T-axiom gives us `Box phi → phi`, not `phi → Box phi`.

The BFMCS approach avoids this by quantifying over ALL box-class agreeing families. Witness existence ensures that if `Box phi` fails, a family with `neg phi` exists in the bundle, making the "phi in all families" hypothesis false.

## Recommendations

1. **Fix task 56 build failure first** - The `restricted_bounded_witness` needs to be restored or the code using it needs to be removed

2. **For completeness proofs** - Use one of:
   - `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean)
   - Algebraic path (Algebraic/ParametricRepresentation.lean)
   - The BFMCS construction for Box backward (UltrafilterChain.lean)

3. **Do not remove the sorry** - It correctly marks an unprovable goal. The SuccChain singleton-Omega architecture cannot prove Box backward.
