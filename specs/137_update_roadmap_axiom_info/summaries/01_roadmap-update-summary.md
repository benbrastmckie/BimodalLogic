# Implementation Summary: Task #137

**Completed**: 2026-05-13
**Duration**: ~15 minutes

## Changes Made

Applied six targeted textual corrections to `specs/ROADMAP.md` to remove stale
information introduced by the axiom cleanup sprint (tasks 132-135):

1. **Axiom count (line 9)**: "45 BX axioms" → "41 BX axioms" in the Architecture paragraph.
2. **Axiom count (line 149)**: "45 axiom constructors" → "41 axiom constructors" in the BX Axiom System section header.
3. **BX2/BX2' table rows (lines 182-183)**: Removed the `left_mono_until` and `left_mono_since` rows from the Layer 3 table. These constructors were deleted in task 133; BX2H/BX2H' (`left_mono_until_G`/`left_mono_since_H`) remain as the canonical left-monotonicity axioms.
4. **BX2H subsumption note (line 208)**: Rewrote to state that BX2/BX2' were actually removed in task 133 (not merely subsumed), and that BX2H/BX2H' are now the canonical forms.
5. **PointInsertion.lean line count (line 356)**: "~3690 lines" → "~3555 lines".
6. **CanonicalChain.lean summary (line 562)**: Removed `left_mono_until_mcs` from the Key Definitions list (function removed in task 135).

## Files Modified

- `specs/ROADMAP.md` — six targeted textual corrections as described above
- `specs/137_update_roadmap_axiom_info/plans/01_roadmap-update-plan.md` — phase status updated to [COMPLETED]
- `specs/state.json` — status updated to completing
- `specs/TODO.md` — status markers updated

## Verification

- `grep "45 BX" specs/ROADMAP.md` — returns no output (PASS)
- `grep "41" specs/ROADMAP.md` — returns 2 matches at lines 9 and 149 (PASS)
- `grep "left_mono_until_mcs" specs/ROADMAP.md` — returns no output (PASS)
- `grep "3690" specs/ROADMAP.md` — returns no output (PASS)
- `grep "3555" specs/ROADMAP.md` — returns 1 match at line 354 (PASS)
- BX2/BX2' table rows absent, table structure intact (visual verified)
- Build: N/A (documentation-only change)
- Tests: N/A

## Notes

The plan specified 5 edits but Edit 3 (BX2/BX2' row removal) involved removing two rows in a single edit operation, and the BX2H note (Edit 4) was corrected from "BX2G/BX2H'" to "BX2H/BX2H'" to match the actual axiom naming in the table above it. No Lean files were modified.
