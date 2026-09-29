# Implementation Summary: Uniform Style for the Typst Reference Manual

- **Task**: 702 - Improve the formatting and content of the Typst reference manual so every chapter follows one uniform approach in style and in the shape of its discussion
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T04:14:00Z
- **Completed**: 2026-09-29T05:40:00Z
- **Effort**: ~5 hours (single dispatch, all 13 phases)
- **Dependencies**: None (coordinates with sibling tasks owning the Lean appendix's define-before-use audit and code-environment convention, and the generated status counts' staleness)
- **Artifacts**: plans/01_uniform-style-reference-manual.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed all 13 phases of the implementation plan in a single dispatch: wrote a committed house
style sheet (`typst/STYLE.md`), centralized shared formatting helpers into `typst/template.typ`,
and brought all 17 chapter files under `typst/chapters/` into conformance with that style sheet.
The manual's two mechanical gates went from 8 element-lint placement failures / 296
chapter-quality BLOCKING findings to zero on both, with every phase closing on a clean
`typst compile` before the next opened.

## What Changed

- `typst/STYLE.md` (new) — the nine-rule house style sheet: chapter opening shape, section
  rhythm, element order, Lean-citation forms, cross-references, list syntax, tables, no local
  chapter helpers, and generated-number sourcing.
- `typst/README.md` — added a Style section linking `STYLE.md`.
- `typst/template.typ` — promoted `derivation-tree-rule`, `fmt-lines`, and a generalized
  `module-lines(map, path)` from chapter-local definitions; deprecated `items`/`item` in place.
- All 15 non-appendix chapters under `typst/chapters/`: added `#chapter-header(description:,
  dependencies:)` where missing, added a `<sec:...>` label to every `=` heading that lacked one,
  fixed every `FormalSystem/`/`BimodalTools/`-relative Lean-citation path (resolved per
  occurrence against the live source tree — never a blind bulk substitution), converted every
  `#items[]` block to native list syntax, wrote opening prose to close all 8 element-placement
  failures, converted every un-linked "the X chapter" mention to a native `@`-reference, and
  removed all remaining chapter-local `#let` formatting helpers.
- `typst/chapters/ax-lean-appendix.typ`, `ax-machine-appendix.typ` — citation-path fixes only, no
  other change (verified by diff), respecting the sibling appendix-maintenance work's boundary.
- `notation-conventions.md` in the typst extension's source store — documented `#leansrc`/
  `#leanref` as the manual's real Lean-citation commands, marked `srcref`/`coderef` superseded.
- `typst/sync-check-whitelist.txt` — added entries for illustrative, non-Lean code spans this
  task's own new `template.typ` comments introduced, restoring `typst-sync-check.sh` to green.
- `typst/BimodalReference.pdf` — regenerated (131 pages, zero compile warnings).

## Decisions

- Native list syntax (`- `/`+ `) wins over the `#items[]`/`#item[]` wrapper; `#items[]` stays
  defined in `template.typ`, behind a deprecation comment, for any other document that may still
  call it.
- `#chapter-header` extends to all numbered `00`–`06` chapters, closing the chronological-drift
  gap between them and the `p2`/`p3`/`p4` chapters that already used it.
- Where a citation was an inline declaration mention paired with a parenthetical file path (the
  dominant pattern in this manual), the fix was `FormalSystem/`-prefixing the existing path
  rather than restructuring into a block-level `#leansrc` call — `#leansrc` is explicitly
  block-level and "never mid-sentence" per the style sheet's own rule 4, so forcing it into an
  inline footnote would violate the same rule it is meant to satisfy.
- `p2-frame-classes.typ` needed a chapter-heading label distinct from `sec:frame-classes` (already
  claimed by a `03-proof-theory.typ` subsection): named `sec:frame-class-extensions` instead of
  causing a duplicate-label compile error.

## Plan Deviations

- Three chapter phases (Phases 4, 6, 9, 10, 11) deviated from the plan's stated intent to convert
  footnote-based citations into `#leansrc`/`#leanref` blocks; each recorded, in its own phase
  notes, why the block-level form was inapplicable to an inline citation and used a
  `FormalSystem/`-prefix fix instead. No information was lost; every citation still resolves.
- Several Scope Hypothesis counts undercounted the true occurrence set (Phase 6's in-table bare
  tokens, Phase 8's `p3-vlach-blstar.typ` un-linked references, Phase 2's `p2-frame-classes.typ`
  lookup that did not exist). Each was caught by re-running the mechanical checker after the
  first pass, per the pre-edit-verification-gate discipline, and fixed to completion rather than
  left at the hypothesis's original count.
- Phase 10 could not close one cross-reference (`p4-proof-automation.typ`'s "the dual-verification
  chapter" mention) because its target file, owned by Phase 11, had no label yet; recorded as
  deferred in Phase 10 and completed in Phase 11 once the label existed.
- Found and fixed one regression outside the plan's two named acceptance gates: this task's own
  new `template.typ` comments (Phase 2) introduced 6 new violations in the repository's separate
  `typst-sync-check.sh` drift detector. Added whitelist entries following that file's existing
  convention; the checker is back to its pre-task green state.

## Impacts

- Every chapter under `typst/chapters/` now opens, cites Lean source, and cross-references in one
  documented, checkable style; a future chapter has `typst/STYLE.md` as its single reference.
- `typst-element-lint.sh` and `chapter-quality-check.sh`, both run in CI-adjacent gates for this
  extension, now pass cleanly over the whole manual, removing a standing 296-finding backlog.
- The 269 JUDGED reviewer prompts and 111 ADVISORY findings both checkers still report are
  explicitly non-blocking and unaffected by this task's acceptance criteria; they remain future
  work for whoever next reviews prose quality rather than citation/placement mechanics.

## Follow-ups

- The 269 pending JUDGED reviewer prompts (source-grounding and open-question-honesty review
  questions) are not resolved by this task and remain for a future editorial pass.
- The Lean appendix's define-before-use audit and its Lean code-environment convention are
  explicitly out of scope here (Phase 12 touched only its citation paths) and remain owned by
  their respective sibling maintenance work.
- The generated status counts' staleness is out of scope here; this task only read
  `typst/generated/` as ground truth.

## References

- `specs/702_uniform_style_reference_manual/plans/01_uniform-style-reference-manual.md` — the
  13-phase implementation plan, with every phase's task list checked off and annotated with its
  own deviations.
- `typst/STYLE.md` — the committed house style sheet.
- `typst/README.md` — links `STYLE.md` under a new Style section.
