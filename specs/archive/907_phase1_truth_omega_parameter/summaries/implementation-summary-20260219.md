# Implementation Summary: Task #907

**Completed**: 2026-02-19
**Session**: sess_1771539369_566e30

## Changes Made

Added an `Omega : Set (WorldHistory F)` parameter to the `truth_at` definition in Truth.lean, restricting the Box modality to quantify over histories in Omega rather than all histories. Defined a `ShiftClosed` predicate and proved `Set.univ` is shift-closed. Updated all Truth and TimeShift namespace lemmas to thread the Omega parameter, with `time_shift_preserves_truth` additionally requiring a `ShiftClosed Omega` hypothesis for its Box case proof.

## Files Modified

- `Theories/Bimodal/Semantics/Truth.lean` - Added Omega parameter to truth_at, defined ShiftClosed, updated all lemmas

## Definitions Added

- `ShiftClosed (Omega : Set (WorldHistory F)) : Prop` - Predicate asserting closure under time_shift
- `Set.univ_shift_closed` - Proof that Set.univ is shift-closed

## Definitions Modified

- `truth_at` - New signature: `(M : TaskModel F) (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (t : D) : Formula -> Prop`
  - Box case now: `forall sigma in Omega, truth_at M Omega sigma t phi`
- `Truth.bot_false` - Added Omega parameter
- `Truth.imp_iff` - Added Omega parameter
- `Truth.atom_iff_of_domain` - Added Omega parameter
- `Truth.atom_false_of_not_domain` - Added Omega parameter
- `Truth.box_iff` - Added Omega parameter, statement now includes `sigma in Omega ->`
- `Truth.past_iff` - Added Omega parameter
- `Truth.future_iff` - Added Omega parameter
- `TimeShift.truth_history_eq` - Added Omega parameter
- `TimeShift.truth_double_shift_cancel` - Added Omega parameter (no ShiftClosed needed)
- `TimeShift.time_shift_preserves_truth` - Added Omega + ShiftClosed parameters, Box case rewritten
- `TimeShift.exists_shifted_history` - Added Omega + ShiftClosed parameters

## Key Design Decisions

1. **Omega position**: Placed after `M` and before `tau` in truth_at signature, matching the paper's M,Omega,tau,x notation
2. **ShiftClosed placement**: Between `end Truth` and `namespace TimeShift`, since it is needed by TimeShift lemmas
3. **truth_double_shift_cancel does NOT need ShiftClosed**: Both sides expand to `forall sigma in Omega, ...` with the same Omega, so the box case is definitionally equal
4. **Only time_shift_preserves_truth needs ShiftClosed**: The box case proof needs to shift a history and prove it remains in Omega

## Verification

- `lake build Bimodal.Semantics.Truth` succeeds (669 jobs built, 0 errors)
- No sorries in Truth.lean
- No new axioms introduced
- All proofs verified via lean_goal at critical points

## Notes

- Downstream files (Validity.lean, Soundness.lean, SoundnessLemmas.lean, etc.) will have compilation errors until Phases 2-4 of parent task 906 are completed
- Boneyard files are expected to break and should NOT be updated
- When Omega = Set.univ, the pattern `simp only [Set.mem_univ, true_implies]` recovers the original universal quantification form
