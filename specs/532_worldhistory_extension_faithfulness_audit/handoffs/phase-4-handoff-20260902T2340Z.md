# Phase 4 handoff — record re-pinned

- **Next action**: Phase 2 (`ShiftRel`/`shiftCorr`, derive `timeShift_preserves_truth`), then Phase 3.
- **State**: `specs/paper-definitions-of-record.md` re-quoted/re-hashed for the 10 anchors, manifest rows updated, sentinels re-pinned to sha256 `7303bc9e…` / HEAD `fa0dbf7c…` (dirty) / 4867 lines, narrative "Drift correction (2026-09-02): ten-anchor re-pin" added, two headings updated.
- **Gates**: `check-paper-definitions.sh` exit 0 (quiet); invariants ALL CHECKS PASSED.
- **Note for Phase 5**: the narrative promises the in-tree `def:world-history` closing-sentence quotes (WorldHistory.lean x2, PartialHistory.lean, FlowFrame.lean) are updated in this change set — Phase 5 must do that.
