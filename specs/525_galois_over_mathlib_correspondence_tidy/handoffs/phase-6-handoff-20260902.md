# Phase 6 handoff — task 525

**Status**: Phase 6 [COMPLETED]. All six phases closed.

## Done
- Both README module tables regenerated and cross-checked against `wc -l` (12/12 cells match).
  `Correspondence/README.md` was stale in six of six rows, not the predicted four.
- `Independence/README.md` opening paragraph rewritten to the three result families over six
  modules, mirroring `Independence.lean:20-31`. `Independence.lean` itself untouched.
- `Correspondence/README.md`: `Galois.lean` / `Indicator.lean` / `DurationFrames.lean` Description
  cells rewritten; reciprocal "See also" added to Key Results; Mathlib edge recorded in
  Dependencies; opening prose updated. Last verified -> 2026-09-02 on both.
- `readme-lint.sh` PASS; `check-module-invariants.sh` ALL CHECKS PASSED with **C2 baseline
  unchanged**; final full `lake build` green.

## Next action
None — task complete. Summary at
`specs/525_galois_over_mathlib_correspondence_tidy/summaries/01_galois-over-mathlib-tidy-summary.md`.
