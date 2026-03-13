# Implementation Summary: Task #961

**Task**: 961 - quotient_density_iteration_no_max_min_dense
**Status**: PARTIAL
**Date**: 2026-03-13
**Session**: sess_1773429728_680b1ce2

## Summary

Implemented well-founded iteration infrastructure for quotient density proofs. Resolved 4 of 6 original DenselyOrdered sorries but introduced 2 new sorries for fuel decrease checks. NoMaxOrder and NoMinOrder reflexive cases remain unresolved.

## Changes Made

### Added `strict_intermediate_exists` theorem
- Well-founded iteration using `Nat.strong_induction_on`
- Takes [p] < [q] and returns strict intermediate [c] with [p] < [c] < [q]
- Uses `dense_timeline_has_intermediate` as base, recurses when intermediate is equivalent to endpoint
- Fuel measure: `subformulaClosure(delta).card`

### Added helper lemmas
- `equiv_endpoint_transitivity`: transitivity through equivalent endpoints
- `intermediate_not_both_equiv`: intermediate cannot be equivalent to both endpoints

### Resolved DenselyOrdered sorries
- Line 332 (original): d ~ c ~ p case - now uses `strict_intermediate_exists`
- Line 345 (original): d ~ q case - now uses `strict_intermediate_exists`
- Line 380 (original): d ~ p case - now uses `strict_intermediate_exists`
- Line 385 (original): d ~ c ~ q case - now uses `strict_intermediate_exists`

## Remaining Sorries (4)

### In `strict_intermediate_exists` (2)
1. **Line 190**: Fuel decrease check for c ~ p case
   - Requires proving: `subformulaClosure(delta').card < subformulaClosure(delta).card`
   - Challenge: Need to show new distinguishing formula has smaller closure
   
2. **Line 211**: Fuel decrease check for c ~ q case
   - Same challenge as above

### In NoMaxOrder/NoMinOrder (2)
3. **Line 366**: NoMaxOrder reflexive case
   - Context: p is reflexive, all seriality witnesses are equivalent to p
   - Challenge: Need to prove timeline has points outside p's equivalence class
   
4. **Line 425**: NoMinOrder case
   - Symmetric to NoMaxOrder

## Technical Analysis

### Fuel Decrease Challenge
The well-founded iteration requires proving that each recursive call uses a strictly smaller measure. The current proof attempts to show `subformulaClosure(delta').card < subformulaClosure(delta).card`, but this requires:
1. Tracking that delta' is extracted from a "smaller" formula space
2. Proving the subformula relationship between consecutive distinguishing formulas

### NoMaxOrder/NoMinOrder Challenge
For reflexive MCSs, all seriality witnesses may be in the same equivalence class. The proof needs to establish that:
1. The timeline has multiple equivalence classes (not all points are equivalent)
2. Given any point, there exists a point in a different equivalence class that is strictly greater

This requires proving that different MCSs have different G-content structures, which prevents all MCSs from being mutually CanonicalR-accessible.

## Build Status

- `lake build` passes with warnings about sorries
- No new axioms introduced
- All existing proofs remain valid

## Recommendations for Next Session

1. **Priority 1**: Resolve fuel decrease sorries
   - Consider explicit formula tracking instead of cardinality
   - Alternative: use `Finset.lt_wf` with explicit consumed formula set

2. **Priority 2**: Resolve NoMaxOrder reflexive case
   - Prove timeline contains points from multiple equivalence classes
   - Use MCS distinctness argument: root MCS determines unique structure

3. **Alternative approach**: 
   - Prove `NoMaxOrder` at MCS level first (easier)
   - Lift to quotient using Antisymmetrization properties

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Sorries Before/After

- Before: 6 sorries (lines 210, 269, 332, 345, 380, 385)
- After: 4 sorries (lines 190, 211, 366, 425)
- Net change: -2 sorries
