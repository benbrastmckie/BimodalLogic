# Implementation Plan: Update ROADMAP.md stale axiom info

- **Task**: 137 - Update ROADMAP.md stale axiom info
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/01_roadmap-update-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

ROADMAP.md contains five specific stale references introduced by the axiom cleanup sprint (tasks 132-135). These are purely textual corrections: two axiom count updates (45 -> 41), removal of two table rows for BX2/BX2' constructors that were deleted in task 133, one note update clarifying that BX2/BX2' were removed rather than merely subsumed, one line-count correction for PointInsertion.lean (3690 -> 3555), and one summary correction for CanonicalChain.lean removing a reference to `left_mono_until_mcs`. All changes are in `specs/ROADMAP.md`. No Lean files are touched.

### Research Integration

No research report was produced for this task. The specific line numbers and required changes were identified by review of ROADMAP.md against the completed axiom sprint tasks (132-135) and are fully specified in the task description.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found applicable — this task IS the ROADMAP.md update; no separate roadmap consultation is needed.

## Goals & Non-Goals

**Goals**:
- Correct axiom count from 45 to 41 at lines 9 and 149 of ROADMAP.md
- Remove BX2/BX2' table rows (lines 182-183) reflecting that these constructors were deleted in task 133
- Update the BX2H subsumes BX2 note (line 208) to state that BX2/BX2' were actually removed
- Update PointInsertion.lean line count from ~3690 to ~3555 (line 356)
- Remove `left_mono_until_mcs` from the CanonicalChain.lean summary (line 562)

**Non-Goals**:
- Any other edits to ROADMAP.md beyond the five identified stale references
- Changes to any Lean source files
- Changes to TODO.md (separate task 138)
- Updating the ROADMAP.md "last updated" date or any other metadata

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers shifted by prior edits | L | L | Verify each target line before editing; search by content, not only line number |
| Over-broad edit removes valid surrounding content | M | L | Edit only the specific text identified; re-read changed region after each edit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Apply five targeted edits to ROADMAP.md [COMPLETED]

- **Goal**: Correct all five stale references in specs/ROADMAP.md identified by the post-sprint review
- **Tasks**:
  - [ ] Read specs/ROADMAP.md lines 1-20 to confirm line 9 contains "45 BX axioms"; edit to "41 BX axioms"
  - [ ] Read specs/ROADMAP.md around line 149 to confirm the second "45 BX axioms" occurrence; edit to "41 BX axioms"
  - [ ] Read specs/ROADMAP.md around lines 178-190; locate and remove the two BX2/BX2' table rows (`left_mono_until` / `left_mono_since` constructors)
  - [ ] Read specs/ROADMAP.md around line 208; update the note "BX2H subsumes BX2" to state that BX2 and BX2' were removed (constructors deleted in task 133, now derived via BX2G/BX2H)
  - [ ] Read specs/ROADMAP.md around line 356; update PointInsertion.lean line count from "~3690" to "~3555"
  - [ ] Read specs/ROADMAP.md around line 562; remove `left_mono_until_mcs` reference from the CanonicalChain.lean summary
  - [ ] Re-read each changed region to verify edits are correct and no surrounding content was inadvertently altered
- **Timing**: 20-30 minutes
- **Depends on**: none
- **Files to modify**:
  - `specs/ROADMAP.md` — five targeted textual corrections as described above

- **Verification**:
  - `grep "45 BX" specs/ROADMAP.md` returns no matches
  - `grep "41 BX" specs/ROADMAP.md` returns exactly 2 matches (lines 9 and 149)
  - `grep -n "BX2'" specs/ROADMAP.md` returns no table-row matches (only contextual mentions are acceptable if accurate)
  - `grep "left_mono_until_mcs" specs/ROADMAP.md` returns no matches
  - `grep "3690" specs/ROADMAP.md` returns no matches
  - `grep "3555" specs/ROADMAP.md` returns 1 match

---

## Testing & Validation

- [ ] `grep "45 BX" specs/ROADMAP.md` — must return no output
- [ ] `grep "41 BX" specs/ROADMAP.md` — must return 2 lines
- [ ] `grep "left_mono_until_mcs" specs/ROADMAP.md` — must return no output
- [ ] `grep "3690" specs/ROADMAP.md` — must return no output
- [ ] `grep "3555" specs/ROADMAP.md` — must return 1 line
- [ ] Visual review of the BX2/BX2' table region confirms those rows are absent and the table is well-formed

## Artifacts & Outputs

- `specs/ROADMAP.md` — updated in place (5 textual corrections)
- `specs/137_update_roadmap_axiom_info/plans/01_roadmap-update-plan.md` — this file
- `specs/137_update_roadmap_axiom_info/summaries/01_roadmap-update-summary.md` — post-implementation summary

## Rollback/Contingency

All changes are to a single markdown file tracked in git. If any edit is incorrect, run `git diff specs/ROADMAP.md` to inspect the full diff and use `git checkout specs/ROADMAP.md` to restore the original, then re-apply only the correct edits.
