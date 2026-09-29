# Implementation Summary: Task #650

- **Task**: 650 - Define-before-use audit of the Lean appendix
- **Status**: [COMPLETED]
- **Started**: 2026-09-29
- **Completed**: 2026-09-29
- **Effort**: ~4 hours
- **Dependencies**: 647, 648, 649 (all landed)
- **Artifacts**: plans/01_define-before-use-audit.md, reports/01_define-before-use-audit.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The 140-row first-use ledger over `typst/chapters/ax-lean-appendix.typ` was applied in reading
order across nine phases. Thirty forward references, forty-four never-introduced items, eight
named-but-unexplained items and one naming defect were closed by adding and relocating
introductions, adding one-clause glosses with section pointers, and converting two re-explanations
into back-references. The three author `TODO` comments were resolved into rendered prose and
removed. No claim the appendix makes was changed and no Lean source was touched.

## What Changed

- `typst/chapters/ax-lean-appendix.typ` — the audited appendix. The turnstile table gained a `⊨ φ`
  row; the prose after it now explains the `[fc]` bracket in full (project-defined notation, what
  may sit between the brackets, the book's subscripted turnstile, the `.Base` identity, the `!`
  mark) plus the `Γ`/`φ` versus `G`/`p` spelling switch, with a `rfl` block proving the identity.
  `Context`, `Nonempty`, `abbrev`, the leading dot, `Axiom`, `Axiom.minFrameClass` and the
  `FrameClass` order are introduced at first use. A glyph paragraph covers `:=`, the function
  arrow against object implication, the quantifiers, `¬`, `True`/`False`, `↑`, and the two roles of
  `|`. Roughly a dozen single-site glosses were added. The three `TODO` blocks became the `Atom`
  walkthrough, a five-part treatment of all three binders around the live signature
  `Semantics.PartialHistory.NearestAt`, and the `worldNonempty` and sibling proof-field account.
- `typst/sync-check-whitelist.txt` — four tag-instantiated turnstile forms added to the existing
  turnstile category; the editorial-`TODO` category removed and its two surviving spans merged into
  a new category for rendered generic Lean-syntax illustrations.
- `typst/SYNC-MAP.md` — dated 2026-09-29 entry recording the audit, the categories of change, the
  resolved `TODO` comments, the whitelist rework, and the gate results.

## Decisions

- Where a full treatment already earns its position later in the appendix, the repair is a
  one-clause gloss at first use plus a section pointer, not a relocation. Relocation was used only
  for the short `Context` and leading-dot introductions.
- The line-651 naming defect was treated as a correction, not a scope widening: the leading dot is
  dot notation resolved against the expected type, and the name *anonymous constructor* now belongs
  to `⟨ ⟩` alone.
- Pure syntax shapes the prose teaches rather than cites are rendered with `#raw`, the idiom this
  file already uses for non-declaration monospace text, rather than added to the whitelist. Only
  shapes that read better as backtick spans were whitelisted.
- `typst/generated/status.typ` was deliberately not regenerated. See Verification.

## Plan Deviations

- **Phase 8** altered: the plan's Scope Hypothesis that no whitelisted span becomes unnecessary
  once the `TODO` comments become prose is falsified. Seven of the category's nine spans are unused
  by the rendered prose. The two survivors were merged into the rendered-syntax category and the
  emptied category was removed rather than left as a header over nothing.
- **Phase 9** altered: no count-bearing prose changed, so `typst-status-counts.sh` was not run. See
  the Reasoned Exclusions record on the plan's Phase 9 heading.

## Verification

- Build: Success. `typst compile --root .. BimodalReference.typ build/BimodalReference.pdf` from
  `typst/` completes with zero errors and zero warnings.
- Element lint: `typst-element-lint.sh --verbose` reports 0 remarks, 0 failures, 0 warnings.
- Sync check: Checks 1 (`TOTAL_VIOLATIONS=0`), 2b, 3 and 4 (`CHECK4_VIOLATIONS=0`) pass. Check 2
  reports two mismatched fields, `formalsystem-file-count` and `formalsystem-line-count`.
- Sorry count: 0 — this task added no Lean declarations.
- Vacuous count: 0. Axiom count: unchanged; no Lean source was modified.
- Every Lean fact asserted in new prose was re-verified against live non-Boneyard source; every
  didactic block added was compiled with `lake env lean` against the pinned toolchain from a
  scratch path outside `FormalSystem/` and `Tests/`.
- `grep -n "TODO" typst/chapters/ax-lean-appendix.typ` returns nothing.
- No task-number reference appears in any file this task wrote.
- Files verified: Yes.

The Check 2 failure is not a product of this work. Both fields were in sync at the pass's baseline
and drifted during it as concurrent Lean work landed new modules under
`FormalSystem/Metalogic/Decidability/`. No commit of this task touches any path under
`FormalSystem/`. `typst/generated/status.typ` should be regenerated once that concurrent work
settles; regenerating mid-flight would commit a state that goes stale on the next commit.

## Impacts

- A reader can now take the appendix in reading order without meeting an unexplained convention,
  identifier or piece of Lean syntax. The `[fc]` bracket, the single largest gap, is explained where
  it is first shown.
- Three editorial `TODO` markers are gone from a deliverable file, and the whitelist category that
  shielded their spans is gone with them.

## Follow-ups

- Regenerate `typst/generated/status.typ` and re-run `scripts/typst-sync-check.sh` once the
  concurrent `FormalSystem/Metalogic/Decidability/` work settles, to bring Check 2 back to green.
- The research report recommends a short context file capturing the first-use ledger procedure so a
  later audit of another chapter does not re-derive it. Not done here; out of this task's scope.
- The repo carries 198 pre-existing unexempted task-reference occurrences outside `specs/`, none in
  files this task wrote.

## References

- `specs/650_define_before_use_audit_lean_appendix/plans/01_define-before-use-audit.md`
- `specs/650_define_before_use_audit_lean_appendix/reports/01_define-before-use-audit.md`
- `typst/SYNC-MAP.md`, 2026-09-29 entry
