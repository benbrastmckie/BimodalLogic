# Phase 1 Handoff: Active untlNeg and snceNeg Rules

## What Was Done
- Modified `untlNeg` in `Tableau.lean` to create a fresh future time when `futureOf l.time` is empty
- Modified `snceNeg` symmetrically for past times
- Both rules include full auto-propagation: T(GA), F(FA), F(U/S(...)), T(box A), F(diamond A)
- Full project builds with zero errors and zero sorries

## Design Decision
The active case fires ONLY when `futureOf l.time` (or `pastOf l.time`) is genuinely empty, NOT when existing times are all processed. This preserves the proof structure in `sat_untl_neg`/`sat_snce_neg` which relies on `applyRule` returning `notApplicable` when future times exist but are all processed.

## Key Deviation from Plan
The plan proposed making `| [] =>` always active. The implementation adds an `if futureTimes.isEmpty` guard. This is more conservative but preserves proof compatibility and avoids the saturation check issue where an always-active rule would prevent the formula from ever being "expanded".

## Next Action
Phase 2: Verify `sat_untl_neg` and `sat_snce_neg` proofs (they already pass with the conservative approach). Phase 2 may be simpler than expected.

## Current State
- `lake build` passes with zero errors
- All `sat_untl_neg` and `sat_snce_neg` proofs still valid
- All existing `#eval` tests pass
