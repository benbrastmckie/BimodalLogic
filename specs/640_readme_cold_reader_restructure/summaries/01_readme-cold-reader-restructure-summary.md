# Implementation Summary: Task #640

- **Task**: 640 - Readme cold reader restructure
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T17:35:00Z
- **Completed**: 2026-09-20T18:25:00Z
- **Effort**: ~1 hour
- **Dependencies**: Task 639 (completed — README factual corrections already landed)
- **Artifacts**: plans/01_readme-cold-reader-restructure.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Restructured the root `README.md` so a reader who arrives cold and gives it two minutes learns
what is proved and how to verify it in the first 40 lines, rather than at line 166. All five
plan phases completed: the Tags footer token was renamed, three revision-history passages were
retired (one deleted outright, two retired to a dated note in
`docs/reference/paper-definitions-of-record.md`), a results summary was hoisted into the opening
of the README, a new "How this repository is developed" section was added, and a full
acceptance pass confirmed all five criteria plus a full-build invariant check.

## What Changed

- `README.md` — the `## Tags` footer token `TM-plus` renamed to `TM⁺`; the saturation-footnote
  aside clause deleted; the "Earlier revisions of this README described…" and "The axiom-basis
  question this README used to record as open…" paragraphs deleted; a new "**Results at a
  glance**" paragraph inserted directly under the opening paragraph, stating soundness/weak
  completeness at all four frame classes, strong completeness proved at Base/Dense and
  machine-refuted at ZTime/RTime, zero sorry/zero custom axioms, and the pinned 105-declaration
  axiom-set harness, with links to `FormalSystem/MainResults.lean` and `docs/theorem-index.md`;
  the two intro paragraphs above the fold merged into one, and the **Main Results**/**Demo** link
  lines folded into the new summary's closing sentences to free the line budget; a new
  `## How this repository is developed` section added after `## Installation`, stating the
  agent-assisted development model and the kernel-plus-invariant-harness trust model, linking
  `docs/development/MODULE_INVARIANTS.md` and `CONTRIBUTING.md`.
- `docs/reference/paper-definitions-of-record.md` — one dated (2026-09-20), prose-only `Note:`
  appended to the `def:BX-r` entry, recording the two retired README claims (the prior
  completeness-*simpliciter* description and the prior open axiom-basis question) and pointing at
  `cor:tm-completeness` for the current text. No anchor, MANIFEST row, or checksum changed.

## Decisions

- Used both available compression options in Phase 3 (merging the two intro paragraphs AND
  folding the Main Results/Demo link lines into the summary) rather than just one, landing
  `## Operators` at line 35 instead of exactly at the 40-line limit, for a safety margin.
- Authored the results summary as one dense paragraph rather than a bulleted list — a bulleted
  list would have cost several more physical lines against a budget the research report flagged
  as having zero slack.
- Kept the destination note in `paper-definitions-of-record.md` as an entry-level note (not a new
  top-level dated section) since it stayed to six sentences.

## Plan Deviations

- **Task 2.4** skipped: the plan's alternative of promoting the destination note to a new
  top-level dated section (if it grew past a few sentences) was not needed — the note stayed
  short enough for the entry-level convention.

## Verification

- Build: Success (`bash scripts/check-module-invariants.sh` → `ALL CHECKS PASSED`)
- Tests: N/A (documentation-only task; `bash scripts/readme-lint.sh` → `RESULT: PASS`)
- Files verified: Yes
- `bash scripts/check-paper-definitions.sh` verdict unchanged from the pre-edit baseline (42
  recorded definitions, same checksum-tracking outcome as before any edits)
- Anchor census confirmed the expected delta after Phase 2: both `def:BX-r` occurrences gone
  (anchor left the file entirely, as expected), one of two `cor:tm-completeness` occurrences gone
  (the surviving occurrence intact)
- Generated inventory block confirmed byte-identical throughout (`--emit-inventory` reported "no
  generated inventory block needed a rewrite")
- No task-number references leaked into either edited file
- README lines ~285–286 ("the 45 TM" / "schemata re-declared") confirmed not reflowed

## Impacts

- A reader who opens `README.md` cold now sees, within the first 40 lines, exactly what is
  proved (soundness/weak completeness at all four frame classes, strong completeness proved at
  two of them and machine-refuted at the other two), the zero-sorry/zero-custom-axiom guarantee,
  and the two commands (`MainResults.lean`, `docs/theorem-index.md`) to verify it independently.
- The README no longer narrates its own revision history; a reader who wants that history now
  finds it in `docs/reference/paper-definitions-of-record.md`'s `def:BX-r` entry.
- A reader who opens `specs/` or a local `CLAUDE.md` now finds an explicit statement of the
  repository's trust model (Lean kernel plus invariant harness, not agent-output review) in
  `README.md` itself.

## Follow-ups

- None.

## References

- Plan: `specs/640_readme_cold_reader_restructure/plans/01_readme-cold-reader-restructure.md`
- Research: `specs/640_readme_cold_reader_restructure/reports/01_readme-cold-reader-restructure.md`
- Progress files: `specs/640_readme_cold_reader_restructure/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/640_readme_cold_reader_restructure/handoffs/phase-{1..4}-handoff-*.md`
