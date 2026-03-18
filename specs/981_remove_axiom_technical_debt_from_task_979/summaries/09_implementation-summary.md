# Implementation Summary: Task #981 - Truth Lemma Wiring (Partial)

**Completed**: 2026-03-18
**Session**: sess_1773867079_dd3321
**Status**: PARTIAL

## Summary

Phase 1 of plan v8 completed: proved `timelineQuotMCS_root_time_eq` which establishes that there exists a time in TimelineQuot whose MCS equals the root MCS. This reformulates the original `timelineQuotMCS_at_zero_eq_root` theorem more correctly.

Phases 2-4 remain blocked on the truth lemma infrastructure needed for the countermodel construction.

## Changes Made

### Phase 1: Root Time MCS Identification [COMPLETED]

Modified `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`:

1. **Added `rootTimelineElem`**: Definition wrapping the root point as a DenseTimelineElem
2. **Added `rootTime`**: Definition of the TimelineQuot element corresponding to the root MCS
3. **Added `timelineQuotMCS_root_time_eq`**: Theorem proving that `timelineQuotMCS root_time = root_mcs`
4. **Deprecated `timelineQuotMCS_at_zero_eq_root`**: Marked as deprecated with sorry, pointing to the new theorem

**Key Insight**: The original theorem `timelineQuotMCS_at_zero_eq_root` claimed that the AddCommGroup zero element has MCS = root_mcs. This is not provable because the Cantor isomorphism (`Order.iso_of_countable_dense`) is non-constructive and arbitrary. The correct approach is to define `rootTime` explicitly as the equivalence class of the root point.

### Phases 2-4: Blocked

The countermodel construction in `timelineQuot_not_valid_of_neg_consistent` requires:

1. Building a TaskModel with valuation reflecting MCS membership
2. A truth lemma relating MCS membership to semantic truth
3. Either a full BFMCS with modal saturation or a forward-only truth lemma

The existing `parametric_shifted_truth_lemma` requires a temporally coherent BFMCS. Building such a BFMCS over TimelineQuot is non-trivial and blocked on modal saturation infrastructure.

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Added root time definitions and proofs

## Verification

- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical` passes
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness` passes
- No new axioms introduced
- One functional sorry in TimelineQuotCompleteness.lean:127 (pre-existing)
- One deprecated sorry in TimelineQuotCanonical.lean:446 (intentional, use `timelineQuotMCS_root_time_eq`)

## Remaining Work

The countermodel theorem `timelineQuot_not_valid_of_neg_consistent` requires either:

1. **Option A (Preferred)**: Build a forward-only truth lemma for TimelineQuot that doesn't require full BFMCS modal saturation
2. **Option B**: Construct a temporally coherent BFMCS over TimelineQuot with modal saturation
3. **Option C (Fallback)**: Document the wiring gap comprehensively and mark task as complete with scope reduction

## Technical Notes

- The `rootTime` definition uses `toAntisymmetrization (. <= .) rootTimelineElem` to create the equivalence class
- The proof uses `denseTimelineElem_mutual_le_implies_mcs_eq` to show that all representatives in the same equivalence class have the same MCS
- The IsPreorder instance must be explicitly provided due to Lean's elaboration of `(. <= .)`
