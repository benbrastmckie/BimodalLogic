# Phase 2 handoff — timeShift_preserves_truth derived from shiftCorr

- **Next action**: Phase 3 (`alignedCorr` in IntTransfer.lean; re-prove `truthAt_map`).
- **State**: `TimeShift` namespace now holds `ShiftRel`, `shiftRel_timeShift`, `shiftRel_timeShift_neg`, `shiftCorr`, the 5-line derivation of `timeShift_preserves_truth` (statement byte-identical), and `timeShift_preserves_truth_total (τ : F.HF)`. The 230-line induction is gone.
- **Gates**: full `lake build` 2520 jobs green; invariants ALL CHECKS PASSED; axioms propext/Quot.sound.
- **Traps honoured**: `dur := OrderIso.addRight Δ`; `states_eq_of_time_eq` for the `-Δ` direction; `change … at h; rw [add_sub_cancel] at h`.
