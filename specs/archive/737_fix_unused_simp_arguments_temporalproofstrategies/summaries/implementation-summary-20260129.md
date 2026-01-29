# Implementation Summary: Task #737

**Completed**: 2026-01-29
**Session**: sess_1769659919_aefadb

## Changes Made

Removed unused `Formula.swap_temporal_involution` arguments from four simp calls in TemporalProofStrategies.lean. The linter correctly identified these arguments as unused because the preceding `rw [φ_eq]` already handles the involution rewriting.

## Files Modified

- `Theories/Bimodal/Examples/TemporalProofStrategies.lean`:
  - Line 174: Changed `simp [Formula.swap_temporal_involution] at h2` to `simp at h2`
  - Line 203: Changed `simp [Formula.swap_temporal_involution] at past_chain` to `simp at past_chain`
  - Line 242: Changed `simp [Formula.swap_temporal_involution] at h_swap` to `simp at h_swap`
  - Line 459: Changed `simp [Formula.swap_temporal_involution] at h2` to `simp at h2`

## Verification

- Lake build: Success (707 jobs)
- All four affected proofs remain valid
- Linter warnings for unused simp arguments eliminated

## Notes

The `swap_temporal_involution` lemma was not needed in these simp calls because:
1. Each proof establishes `φ_eq : φ = φ.swap_temporal.swap_temporal`
2. The `rw [φ_eq]` already rewrites `φ` to the double-swap form
3. The subsequent simp then operates on the rewritten form, but the involution lemma is not applied
