# Task 956: Iteration 4 Summary

**Session**: sess_1773344838_384103
**Date**: 2026-03-12
**Status**: Partial (infrastructure added, sorries not yet resolved)

## Objective

Implement Pattern C fuel-based iteration infrastructure for strict density proofs.

## Changes Made

### New Theorems and Definitions Added to DensityFrameCondition.lean

1. **`mutual_canonicalR_implies_reflexive`** (lines 1594-1622)
   - Proves: When CanonicalR M M' and CanonicalR M' M both hold, M and M' are both reflexive
   - Uses Temporal 4 propagation pattern

2. **`equiv_GContent_subset`** (lines 1628-1651)
   - Proves: When M ~ M' (mutually accessible), G(phi) in M iff G(phi) in M'
   - Key for understanding equivalent witnesses

3. **`reflexive_equiv_witness_sees_target`** (lines 1657-1676)
   - Helper: When M ~ V and V sees M', then M sees M'
   - Used for transitivity reasoning in equiv cases

4. **`equiv_witness_preserves_intermediate`** (lines 1684-1697)
   - Confirms non-strict intermediate property via transitivity
   - Documents that equiv witnesses still satisfy weaker density

5. **`StrictDensityWitness`** (structure, lines 1805-1811)
   - Clean packaging of strict intermediate witness with all proofs
   - Fields: W, h_mcs, h_R_MW, h_R_WM', h_not_WM, h_not_M'W

6. **`checkStrictness`** (noncomputable def, lines 1817-1828)
   - Decidable check if non-strict intermediate is actually strict
   - Uses classical decidability for the if-then-else

7. **`strictDensityAttempt`** (noncomputable def, lines 1834-1850)
   - Fuel-based iteration attempt
   - Gets non-strict intermediate from density_frame_condition
   - Checks strictness via checkStrictness

8. **`strict_intermediate_exists_aux`** (theorem, lines 1857-1868)
   - Placeholder for the full Pattern C proof
   - Currently delegates to density_frame_condition_strict (with sorries)

## Why Sorries Remain

Analysis of remaining sorries confirmed they are NOT provable via contradiction in the current proof structure:

| Line | Case | Issue |
|------|------|-------|
| 505 | B1, h_VM' and h_M'V both hold | V ~ M', need iteration |
| 586 | B1, h_M'V holds | V equivalent to M', exfalso goal is consistent |
| 612 | B1, V = M' | Forward witness landed at M', need different approach |
| 895 | Case A, h_VM holds | V ~ M via assumption, M reflexive, consistent |
| 1306 | Case A, V=M', W1 ~ M | W1 equivalent to M, consistent configuration |
| 1410 | Case A, V=M', M reflexive | Same as 1306 in different subcase |

**Key Insight**: All sorries occur in branches where the proof uses `exfalso` to derive False, but the mathematical configuration IS consistent - it just means the current witness is not strictly intermediate. The proof needs restructuring to handle these cases by iteration rather than contradiction.

## Build Status

- `lake build` passes successfully
- 6 sorries remain in DensityFrameCondition.lean
- 3 sorries remain in CantorApplication.lean (depend on strict density)

## Next Steps

1. **Restructure proof approach**: Replace nested `by_cases` + `exfalso` structure with direct iteration
2. **Implement `fuel_suffices`**: Prove that bounded fuel suffices using subformula count measure
3. **Complete `strict_intermediate_exists_aux`**: Use fuel-based iteration to find strict witness
4. **Update calling sites**: Replace `density_frame_condition_strict` calls with proven version

## File Diff Summary

- Added ~170 lines to DensityFrameCondition.lean (1702 -> 1871 lines)
- Build passes
- No sorries eliminated this iteration (infrastructure only)

## Continuation Point

To continue implementation:
1. Read DensityFrameCondition.lean lines 1700-1871 for new infrastructure
2. The key challenge is proving `fuel_suffices` - need to show iteration terminates
3. Consider alternative: prove directly that SOME witness is strict using cardinality argument
