# FDSM Module - Archived

**Archived**: 2026-02-03
**Task**: 826
**Previous Location**: `Theories/Bimodal/Metalogic/FDSM/`

## Summary

The FDSM (Finite Duration Saturated Model) approach was an attempt to construct
completeness via multi-history modal saturation. It aimed to create finite models
that properly handle both modal and temporal operators simultaneously.

## Why Archived

The FDSM approach has three fundamental architectural blockers that cannot be
resolved without major restructuring:

### 1. fdsm_truth_at Definition Blocker

The `fdsm_truth_at` function for atoms uses `h.initial_mcs` membership, but atoms
may not be in the closure. This causes a type mismatch in the truth lemma:
- Expected: `p ∈ h.mcs_at 0` (membership in current MCS)
- Actual: `p ∈ h.initial_mcs` (membership in initial MCS)

**Fix Attempt**: Required restructuring FDSM to track atoms separately from closure.

### 2. MCSTrackedHistory Finiteness Blocker

The `MCSTrackedHistory.mcs_history` field has type `Set Formula` (unbounded), but
the FMP construction requires provable finiteness (bounded by closure size).

**Fix Attempt**: Required changing representation to `Finset` or adding explicit
finiteness proofs throughout the construction.

### 3. Termination Bound Blocker (Time Dimension)

The modal saturation algorithm needs a termination proof along the time dimension.
Without explicit time bounds, the construction cannot guarantee finite depth.

**Fix Attempt**: Required major restructuring to add time bounds to the construction.

## Alternative: BFMCS Approach

Task 812 successfully implemented completeness via the BFMCS (Bundle of Maximal
Consistent Sets) approach, which:
- Avoids multi-history complexity
- Has sorry-free box case in truth lemma
- Provides full weak and strong completeness

See: `Bimodal/Metalogic/Bundle/Completeness.lean`

## Files Archived

| File | Sorries | Purpose |
|------|---------|---------|
| Core.lean | 0 | Clean definitions (FDSM structure) |
| TruthLemma.lean | 16 | Truth lemma with atom blocker |
| ModalSaturation.lean | 15 | Saturation with finiteness/termination blockers |
| Completeness.lean | 3 | Main theorems (depended on above) |
| **Total** | **34** | |

## References

- Task 826 research: `specs/826_fdsm_completeness_saturated_construction/reports/`
- BFMCS completeness: `Bimodal/Metalogic/Bundle/Completeness.lean`
- FMP completeness: `Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
