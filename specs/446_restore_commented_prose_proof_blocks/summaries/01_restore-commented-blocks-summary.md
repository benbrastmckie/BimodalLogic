# Implementation Summary: Task #446

- **Task**: 446 - Restore or retire 6 commented-out prose/proof blocks in FormalFoundations.typ
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T00:00:00Z
- **Completed**: 2026-08-18T01:00:00Z
- **Effort**: ~1 hour
- **Dependencies**: 445, 456 (both already landed)
- **Artifacts**: plans/01_restore-commented-blocks.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`typst/FormalFoundations.typ` carried 6 bare `// FIX:` tags, each above a block of commented-out
prose or proof text. All 6 were restored verbatim as live document text, along with two adjacent
untagged blocks the plan brought into scope by explicit decision. The document compiles cleanly
throughout, with no regression in warnings, and the 6 *explanatory* FIX tags (owned by a sibling
task) were left byte-for-byte untouched.

## What Changed

- `typst/FormalFoundations.typ` — 6 bare `// FIX:` tags deleted and their commented content
  restored as live text, plus two untagged blocks restored per the plan's Scope Decisions:
  - Site 1 (Nullity lemma proof, originally line 228): `#proof[...]` block and the following
    "Nullity is derived, not postulated..." paragraph restored; the separating `//` line became a
    genuine blank line.
  - Site 2 (Step Lemma prose, originally line 275): paragraph with its inline `#footnote[...]`
    (citing `@brastmckie2026possibleworlds`) restored, footnote kept as a single unbroken line.
  - Site 3 (cones/basis sentence, originally line 281): single sentence restored.
  - Site 4 (Separation theorem T1/R0 proof, originally line 295): `#proof[...]` block restored
    verbatim, including the "converse convention" reference (left as plain text — the plan made
    bold-emphasis optional and non-blocking).
  - Untagged remark (Scope Decision 1, originally lines 304-315): `#remark[...]` restored,
    delivering the abstract's line-120 promise about partial histories being restrictions of
    possible worlds — the only live coverage of that claim in the document.
  - Site 5 (box-modality/S5 paragraph, originally line 345): three-sentence paragraph restored.
  - Untagged frame-validity clause (Scope Decision 2, originally lines 362-363): restored inside
    the live `#definition("Validity and Consequence")[...]`, forming the definition's first
    clause and chaining via a trailing "And" into the existing `$Gamma #satisfies phi.alt$`
    clause.
  - Site 6 (general-frame contrast paragraph, originally line 370): full paragraph restored,
    including the `@blackburnderijkevenema2001` citation.

## Decisions

- Scope Decision 1 (restore the untagged remark at 304-315): confirmed and applied. A repo-wide
  grep before editing showed the abstract's "restriction of a possible world" claim had no other
  live coverage; restoring the remark closes that gap.
- Scope Decision 2 (restore the untagged frame-validity clause at 362-363): confirmed and
  applied. Before editing, `grep -n 'taskframe #satisfies|frame validity|frame-valid'` showed only
  pre-existing *uses* of frame validity (a proposition and a remark later in the document,
  originally around lines 862 and 877) that presuppose the notion, never a competing live
  definition — confirming the commented fragment was the sole definitional home, per the plan's
  Scope Hypothesis for Phase 4. After restoring, the assembled "Validity and Consequence"
  definition was read end-to-end and found grammatical and non-duplicative; no repair was needed.
- The optional cosmetic emphasis of "converse convention" in the Separation proof (Phase 3) was
  left as plain text, per the plan's explicit discretion clause not to spend time deliberating on
  it.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: N/A (Typst document, not a Lean/code build)
- Tests: N/A
- Compile: Success — `typst compile typst/FormalFoundations.typ` exits 0 at every phase boundary
  and at final verification, with only the two pre-existing `thmbox` "unknown font family"
  warnings (no new warnings at any point).
- Bare `// FIX:` tag count: dropped from 6 (baseline) to 0 (final), confirmed by `grep -n "FIX:"`
  after each phase.
- Explanatory FIX tag set: confirmed byte-identical, pre- vs. post-change, via a direct diff
  against the Phase 1 baseline record (all 6 present, unchanged text, only their line numbers
  shifted as expected).
- PDF sanity check: `pdftotext` extraction confirms both restored proofs render inside `Proof:`
  environments, the restored remark renders inside a `Remark` environment (not leaking as raw
  body text), and the assembled Validity-and-Consequence definition reads as one coherent
  two-clause statement.
- No orphaned comment markers or stray `//` lines left behind in the restored regions.
- `git status --short` after final verification shows no file outside
  `typst/FormalFoundations.typ`, `specs/446_restore_commented_prose_proof_blocks/`, and the
  standard machine-state files (`specs/TODO.md`, `specs/state.json`) touched by this task's
  own phase-tracking.
- Files verified: Yes

## Impacts

- The document now delivers, in live body text, all six previously-commented arguments plus the
  two adjacent blocks the abstract's promises and Site 5/6's prose depended on.
- This task's additions shift downstream line numbers in `typst/FormalFoundations.typ`. This is
  expected and non-blocking: the sibling task owning the 6 explanatory FIX tags anchors its own
  work by content, not by the line numbers cited in its original description, and no renumbering
  was attempted here.

## Follow-ups

- None — the 6 explanatory FIX tags remain, byte-for-byte, for the sibling task to address in its
  own scope.

## References

- `specs/446_restore_commented_prose_proof_blocks/plans/01_restore-commented-blocks.md`
- `specs/446_restore_commented_prose_proof_blocks/reports/01_restore-fix-tagged-blocks.md`
- `typst/FormalFoundations.typ`
