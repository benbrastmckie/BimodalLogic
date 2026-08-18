# Implementation Summary: Task #445

- **Task**: 445 - Restore or retire 39 commented-out footnotes in FormalFoundations.typ
- **Status**: [COMPLETED]
- **Started**: 2026-08-18
- **Completed**: 2026-08-18
- **Effort**: ~0.75 hours
- **Dependencies**: None
- **Artifacts**: plans/01_restore-commented-footnotes.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All 39 `] // FIX: #footnote[` sites in `typst/FormalFoundations.typ` were restored to live
`]#footnote[` form via one content-anchored bulk `sed` pass, and the two content corrections
identified by the research report (a nonexistent paper anchor, two misattributed Lean file
citations) were applied. The 12 out-of-scope bare `// FIX:` tags belonging to sibling tasks
446/447 were verified byte-identical in content and line position, before and after. The
document compiles cleanly with no new diagnostics.

## What Changed

- `typst/FormalFoundations.typ` — 39 sites lost the literal ` // FIX: ` between the block-closing
  `]` and `#footnote[` (live-footnote restoration; no other characters touched). Two of those 39
  restored footnotes additionally received a content correction: the Model definition's footnote
  anchor (`def:BL-model` -> `def:BL-semantics`) and the Reynolds-pipeline footnote's Lean file
  attributions (`good` and `limitdom_is_good` moved to `IntegerModel/GoodStructures.lean` and
  `IntegerModel/ReynoldsBridge.lean` respectively).

## Decisions

- **Notable pre-existing condition discovered during implementation**: the working tree at task
  start already differed from `HEAD` in ways unrelated to this task. `HEAD`'s committed content
  for `typst/FormalFoundations.typ` already had all 39 footnote sites restored (no
  `] // FIX: #footnote[` occurrences at all) but with the two uncorrected anchors/attributions
  this task's Phase 2 fixed. The dirty, uncommitted working tree present before this session
  started had reintroduced the FIX-annotated form at those 39 sites as an incidental side effect
  of unrelated, uncommitted WIP belonging to sibling tasks 446/447 (commented-out proof/prose
  blocks under their 12 bare `// FIX:` tags — matching those tasks' TODO.md descriptions exactly:
  the Extension proof at `:244`, the Task Topology definition at `:267`, axiom formalization at
  `:353`/`:362`, proof-systems restructuring at `:369`, and the section intro at `:393`).
  Consequently:
  - Phase 1's bulk transformation, once applied, produced **zero diff against `HEAD`** for the 39
    sites (it returned them to a state `HEAD` already had). No phase-1 commit was made, since
    staging `typst/FormalFoundations.typ` at that point would have swept the sibling tasks'
    unrelated, unverified, uncommitted WIP into a commit attributed to task 445. This is recorded
    as a deviation in the Phase 1 progress file and annotated on the plan checklist.
  - Phase 2's two corrections **were** genuinely new relative to `HEAD`. They were staged with a
    minimal 4-line cached patch built by diffing `HEAD`'s content against a copy with only the
    two corrections applied (via `git apply --cached`), rather than `git add`, so that only the
    two in-scope lines were committed — none of the unrelated foreign content was swept in.
  - The 12 bare `// FIX:` tags and the surrounding sibling-task WIP remain exactly as found:
    uncommitted, untouched, byte-identical in content and line position (verified by a
    before/after line-numbered snapshot diff at Phase 1 and re-confirmed at Phase 3).

## Plan Deviations

- **Task 1.6** (Phase 1's "Commit: task 445 phase 1: bulk-restore 39 commented-out footnotes")
  altered: no phase-1 commit was made, because the transformation netted zero diff against `HEAD`
  (see Decisions above). The transformation was verified live via `grep` against the working file
  instead of via a commit diff.

## Verification

- Build: N/A
- Tests: N/A
- `typst compile typst/FormalFoundations.typ`: exit 0, output byte-identical to the Phase 1
  baseline (exactly the two pre-existing `unknown font family: new computer modern sans`
  warnings from the `thmbox` package; no new warnings or errors).
- `grep -c '\] // FIX: #footnote\['`: 0 (was 39).
- `grep -o '\]#footnote\[' | wc -l`: 39.
- `grep -c 'FIX:'`: 12, all bare, content and line numbers unchanged from the pre-task snapshot
  (214, 244, 257, 263, 267, 277, 323, 342, 353, 362, 369, 393).
- `grep -c 'def:BL-model'`: 0. `grep -c 'ReynoldsBridge.lean'`: 1. `grep -c 'limitdom_is_good'`: 1.
- Files verified: Yes.

## Impacts

- The 39 footnotes are now live document text with correct citations, ready for the compiled
  paper.
- The 12 bare `// FIX:` tags for sibling tasks 446/447 remain exactly as they were, unblocking
  those tasks' own work with no line-number drift introduced by this task.
- The pre-existing, unrelated, uncommitted WIP for sibling tasks 446/447 discovered in the working
  tree at task start was left untouched and uncommitted — it was neither authored by nor
  committed by this task, and remains available in the working tree for those tasks' own
  implementation and commit.

## Follow-ups

- The orchestrator/user should be aware that `typst/FormalFoundations.typ` currently carries
  substantial uncommitted content beyond this task's scope (draft edits matching tasks 446 and
  447's descriptions) that predates this session. That content was not created, verified, or
  committed by task 445 and should be reviewed under tasks 446/447's own implementation passes.

## References

- `specs/445_restore_commented_footnotes_formalfoundations/plans/01_restore-commented-footnotes.md`
- `specs/445_restore_commented_footnotes_formalfoundations/reports/01_restore-commented-footnotes.md`
- `specs/445_restore_commented_footnotes_formalfoundations/progress/phase-1-progress.json`
- `specs/445_restore_commented_footnotes_formalfoundations/progress/phase-2-progress.json`
- `specs/445_restore_commented_footnotes_formalfoundations/progress/phase-3-progress.json`
