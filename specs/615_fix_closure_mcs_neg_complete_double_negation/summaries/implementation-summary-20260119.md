# Implementation Summary: Task #615

**Completed**: 2026-01-19
**Duration**: ~20 minutes

## Overview

Fixed the sorry in `closure_mcs_neg_complete` theorem by restricting the hypothesis from `psi in closureWithNeg phi` to `psi in closure phi`. This eliminates the double negation edge case where `chi.neg.neg` would escape `closureWithNeg`.

## Changes Made

### 1. Modified Theorem Signature (closure_mcs_neg_complete)

**Before:**
```lean
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi in closureWithNeg phi) :
    psi in S or psi.neg in S
```

**After:**
```lean
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi in closure phi) :
    psi in S or psi.neg in S
```

### 2. Simplified Proof Body

The original proof had two cases:
- Case 1: `psi in closure phi` (worked correctly)
- Case 2: `psi = chi.neg` for some `chi in closure phi` (contained the sorry)

With the restricted hypothesis, only Case 1 applies. The proof now:
1. Derives `psi in closureWithNeg phi` from `closure_subset_closureWithNeg`
2. Derives `psi.neg in closureWithNeg phi` from `neg_mem_closureWithNeg`
3. Uses the standard maximality argument to complete the proof

### 3. Updated Caller (closure_mcs_imp_iff)

**Before:**
```lean
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula)
    (h_imp_clos : Formula.imp psi chi in closure phi)
    (h_psi_clos : psi in closureWithNeg phi)
    (h_chi_clos : chi in closureWithNeg phi) :
    Formula.imp psi chi in S <-> (psi in S -> chi in S)
```

**After:**
```lean
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula)
    (h_imp_clos : Formula.imp psi chi in closure phi) :
    Formula.imp psi chi in S <-> (psi in S -> chi in S)
```

The `h_psi_clos` and `h_chi_clos` parameters were removed because they can be derived from `h_imp_clos` using `closure_imp_left` and `closure_imp_right`.

## Files Modified

- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean`
  - Modified `closure_mcs_neg_complete` theorem (lines ~270-393)
  - Modified `closure_mcs_imp_iff` theorem (lines ~646-794)

## Verification

- `lean_diagnostic_messages`: No errors in modified file
- `lake build`: Completed successfully (691 jobs)
- `grep sorry`: No matches found in Closure.lean
- Pre-existing warning about unused variable `h_clos` in `mcs_closure_neg_complete` (line 257) remains but is unrelated to this task

## Technical Notes

### Why This Fix Works

The key insight from the research phase: When `psi in closure phi`, we have:
- `psi in closureWithNeg phi` (via `closure_subset_closureWithNeg`)
- `psi.neg in closureWithNeg phi` (via `neg_mem_closureWithNeg`)

This means both `psi` and `psi.neg` are in `closureWithNeg`, so the maximality property of closure MCS applies to both. The proof proceeds by contradiction, showing that if neither `psi` nor `psi.neg` is in S, then S would be inconsistent.

### Why the Original Approach Failed

When `psi in closureWithNeg phi` but `psi not in closure phi`, we have `psi = chi.neg` for some `chi in closure phi`. In this case:
- `psi.neg = chi.neg.neg = (chi -> bot) -> bot`
- This double negation is NOT in `closureWithNeg phi`

Without `psi.neg in closureWithNeg phi`, the maximality property cannot be applied to `psi.neg`, breaking the proof structure.

## Downstream Impact

The signature change for `closure_mcs_imp_iff` removes two parameters that were always derivable from `h_imp_clos`. Any external callers of this theorem will need to be updated to remove the now-eliminated parameters.

## Related Tasks

- This fix follows the pattern from the old Metalogic's `closure_mcs_negation_complete` theorem at `FiniteCanonicalModel.lean:713`
