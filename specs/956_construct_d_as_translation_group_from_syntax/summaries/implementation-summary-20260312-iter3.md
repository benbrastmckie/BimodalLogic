# Implementation Summary: Task 956 - Iteration 3

**Date**: 2026-03-12
**Session**: sess_1773353508_f76726
**Status**: PARTIAL

## Changes Made

### New Theorem: `non_reflexive_target_has_strict_intermediate`
**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean:1517-1730`

**Purpose**: Proves strict density for the case when M' is NOT reflexive.

**Key insights**:
- When M' is not reflexive, there exists gamma with G(gamma) in M' and gamma not in M'
- This gamma provides the distinguishing formula for the construction
- The proof uses Case A analysis (G(gamma) not in M implies F(neg(gamma)) in M)

### Iteration Pattern Established

For witnesses W that collapse to M's equivalence class (CanonicalR W M holds):
1. Apply `density_frame_condition(W, M')` to get new witness W'
2. Case split on `CanonicalR W' M`:
   - If false: W' is strict from M side. Prove `neg CanonicalR M' W'` via gamma/T4 argument.
   - If true: W' also collapses. Recurse.

### Proofs Added

1. **T4 transitivity contradiction**: When M' sees W' and W' sees M, derive M' sees M via T4, contradicting h_not_R'.

2. **Gamma-based M' strictness**: For any W' with CanonicalR W' M':
   - G(gamma) in M' implies G(G(gamma)) in M' by T4
   - If CanonicalR M' W', then G(gamma) in W'
   - Then gamma in GContent(W') subset M' by CanonicalR W' M'
   - But gamma not in M'. Contradiction.

## Sorries Remaining

**13 sorries total**:

| Lines | Description |
|-------|-------------|
| 486, 490, 492 | Original Case B1 reflexive M' sorries |
| 585, 589, 591 | Original Case B1 with different witness |
| 641, 646, 653 | Original V = M' case sorries |
| 860, 898 | Original Case A sorries |
| 1632 | Nested iteration (W'' ~ M in non_reflexive theorem) |
| 1717 | Second iteration point (V = M' branch) |

**All sorries have identical goal**: `exists W, strict witness between M and M'`

**All sorries occur at**: "witness collapses to M's equivalence class" case

## Mathematical Insight

The fundamental obstruction: density construction via Lindenbaum extension may produce witnesses equivalent to the source MCS. This happens when:
- M is reflexive (which follows from any V ~ M)
- The distinguishing formula's negation doesn't "escape" M's equivalence class

The solution requires showing that iteration MUST terminate. Each iteration should use a "smaller" formula (via subformula measure), eventually exhausting the finite set of candidate formulas.

## Next Steps

1. Implement termination measure based on subformula count
2. Implement fuel-based `strictDensityWithFuel` function
3. Prove `fuel_suffices` showing sufficient fuel exists
4. Wire up all 13 sorries to the fuel-based theorem

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
  - Added `non_reflexive_target_has_strict_intermediate` theorem
  - Added nested iteration patterns
  - Added T4/gamma proofs for strict cases
