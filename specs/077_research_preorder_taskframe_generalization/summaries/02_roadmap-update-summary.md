# Implementation Summary: Task #77

**Completed**: 2026-03-31
**Duration**: ~5 minutes

## Changes Made

Added a new section "Investigated Dead Ends: Logic Weakening (Task 77)" to ROADMAP.md documenting why relaxing the linearity constraint on D (the duration type) does not provide a viable path to TM completeness.

The section covers:
1. The category error in prior proposals conflating D with MCS
2. How partial order D creates multi-dimensional time rather than branching time
3. Which TM axioms actually require linearity (only temp_linearity)
4. Why the F/P blocker is structural and independent of D's order structure
5. The representation theorem goal and why FMP/filtration is not a substitute

## Files Modified

- `ROADMAP.md` - Added new section (35 lines) after "Temporal Coherence Resolution" section

## Verification

- Build: N/A (documentation-only change)
- Tests: N/A
- Files verified: Yes - section placed correctly between "Temporal Coherence Resolution" and "Other Open Items"
- Reference path verified: `specs/077_research_preorder_taskframe_generalization/reports/05_team-research.md` exists

## Notes

This is a documentation update based on research findings from task 77 reports (01_team-research.md, 02_time-shift-analysis.md, 05_team-research.md). The update follows the revised plan v2 which corrects the earlier plan's incorrect recommendation of FMP/filtration as an alternative approach.

Key insight preserved: The goal is a representation theorem characterizing TM's semantic class, not merely proving decidability via FMP techniques.
