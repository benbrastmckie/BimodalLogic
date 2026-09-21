# Implementation Summary: Fix Reference-Book Defects Found in Appendix Review

- **Task**: 648 - Fix the defects found in `typst/BimodalReference.typ` and its surroundings
  during the accuracy-and-formatting review of `typst/chapters/ax-lean-appendix.typ`
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T22:17:44Z
- **Completed**: 2026-09-22T02:30:00Z
- **Effort**: ~4.5 hours
- **Dependencies**: extend the Lean appendix (landed, final commit `a171dc67e`)
- **Artifacts**: plans/01_fix-reference-book-defects.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Fixed nine numbered defects found while reviewing the extended Lean appendix, all outside that
appendix's own content: a rendering bug in the shared appendix-reference rule, stale sync
records, three separate places repeating a false `Axiom`-is-`Prop`-valued claim, a wrong
three-way `DecisionResult` description, an incomplete introduction directory list, a metavariable
letter mismatch in the machine appendix, and two Typst template hygiene issues. One
unflagged blocker (a failing `typst-sync-check.sh` from uncommitted editorial content in the
off-limits appendix file) was cleared first so every later phase's verification was meaningful.

## What Changed

- `typst/BimodalReference.typ` — rewrote the `#show ref` rule to read the target heading's own
  `supplement`/`numbering` dynamically instead of hardcoding "Chapter" and a fixed pattern,
  eliminating the raw-counter-concatenation bug ("Chapter 1534").
- `typst/chapters/ax-lean-appendix.typ` — title heading only: real letter numbering
  (`supplement: "Appendix"`, renders "A"), per the task's explicit exception to the file's
  off-limits status.
- `typst/chapters/ax-machine-appendix.typ` — title heading given letter "B" (continues the same
  counter by auto-increment); its three level-2 headings numbered `B.1`–`B.3`; the `untl`/`snce`
  JSON-shape table's metavariable letters swapped to the book's own guard-first convention.
- `typst/chapters/p4-dataset-pipeline.typ` — stale appendix-title link text updated to "Appendix
  B: The Machine-Readable Axiomatization".
- `typst/chapters/00-introduction.typ` — project-structure list completed
  (`MinusLanguage/`, `PlusLanguage/`, `StarLanguage/`, `OpenLanguage/`, `HybridLanguage/`,
  `ForMathlib/`, `Tactic/`, `MainResults.lean`) and the training-data-pipeline attribution
  corrected to the separate `BimodalTools` library.
- `typst/chapters/p2-decidability-practice.typ` — `DecisionResult`'s description corrected from
  a false three-way `valid`/`invalid`/`timeout` split to the real four constructors (`valid`,
  `invalid`, `fuelExhausted`, `extractionFailed`), with the distinction between the two
  non-verdict outcomes explained.
- `typst/chapters/p4-proof-automation.typ` — axiom-count coverage claim corrected to
  machine-verified figures (27 of the generated `axiom-count`, omitted set `{prior_U_gap, sep}`);
  both `Prop`-valued occurrences corrected; `apply_axiom` item corrected to its real behavior.
- `typst/template.typ` — `#item` now expands to native `list(body)` (hanging indent, no
  call-site changes); every thmbox-based environment style dict given `sans-fonts`/`title-fonts`
  set to DejaVu Sans, eliminating both recurring font warnings.
- `typst/SYNC-MAP.md` — folded the appendix's pre-existing section-numbering mechanism into the
  existing most-recent entry; added one new dated entry recording this round.
- `typst/sync-check-whitelist.txt` — new whitelist categories for the off-limits appendix's
  uncommitted editorial-comment syntax illustrations and the swapped machine-appendix table
  spans; pruned one unused entry (`leanprover/lean4`); removed an ephemeral task-directory path
  citation.
- `typst/generated/status.typ`, `typst/generated/automation-module-map.typ` — regenerated
  (Lean docstring edits moved tracked line counts).
- `FormalSystem/Automation/Tactics/Search.lean` — module docstring and `tryAxiomMatch`/search
  docstrings corrected (doc-comment-only).
- `FormalSystem/Automation/Tactics/Commands.lean` — `modal_search` docstring's Prop/Type phrase
  corrected (doc-comment-only).
- `FormalSystem/Automation/Tactics/UserTactics.lean` — `apply_axiom` and `modal_t` docstrings
  rewritten to the real behavior, stale "Supported Axioms" list deleted, both worked examples
  replaced with elaboration-verified ones (doc-comment-only).
- `FormalSystem/Automation/Tactics/README.md` — module-inventory description for `Search.lean`
  corrected (same false claim, found while editing).

## Decisions

- Chose real Typst letter numbering for the appendix titles (matching the task's literal
  instruction: "supplement Appendix, letter numbering") over the documented literal-title-text
  fallback; root-caused the original bug in an isolated scratch reproduction first.
- Font: DejaVu Sans, not the plan's suggested Noto Sans (a variable font that trades one Typst
  warning for another).
- Extended item 5's fix to two sites the dispatch/plan didn't explicitly name (`tryAxiomMatch`'s
  own doc comment, and `Tactics/README.md`'s auto-regenerated module inventory) because both
  repeat the identical misconception in files this task's own edits already touched.

## Plan Deviations

- None material. Font choice (DejaVu Sans vs. Noto Sans) and the two extra Prop/Type-claim
  corrections are recorded above as justified extensions, not deviations from any specified step.

## Verification

- Build: Success — `lake build --wfail` green, full project, 2696 jobs, zero warnings.
- Tests: N/A (docstring-only Lean edits; no statement or proof changed, confirmed by reading
  every diff hunk).
- Typst compile: Success — `typst compile --root .. BimodalReference.typ` zero errors, zero
  warnings.
- Sync check: Success — `scripts/typst-sync-check.sh` PASS on all four checks (Check 1: 0
  violations of 829 candidates; Check 2, 2b, 3: 0 mismatches).
- pdftotext acceptance grep: zero matches for `Chapter 1` followed by three or more digits; every
  reference to either appendix reads "Appendix A" / "Appendix B" correctly; every ordinary
  chapter reference still reads "Chapter N".
- Rendered-page inspection: all six touched chapter/appendix pages (introduction p.11,
  decidability-in-practice p.51, proof-automation p.72, dataset-pipeline p.81, Lean appendix
  p.90, machine appendix p.120) rendered and visually inspected — all correct, no regressions.
- Files verified: Yes.

## Item Disposition

1. **Broken cross-references to the appendices** — Fixed. `#show ref` rewritten; both appendices
   given real letter identities ("A"/"B"); stale link text updated. The sub-claim of a bare
   `@machine-appendix` reference rendering incorrectly does **not reproduce** — no such reference
   exists anywhere in `typst/`; closed as not-reproducing. The underlying rule bug was real and is
   fixed regardless.
2. **Stale records about the Lean appendix** — Fixed. `typst/SYNC-MAP.md` and
   `typst/sync-check-whitelist.txt` brought in line with the appendix's actual stated policy; the
   ephemeral task-directory path citation removed.
3. **Axiom-schema count disagreement** — Fixed. Machine-verified: 29 `Axiom` constructors, 27 in
   `tryAxiomMatch`, omitted set exactly `{prior_U_gap, sep}` (the dispatch's third name,
   `prior_S_gap`, does not exist as an `Axiom` constructor). All three prior disagreeing sites now
   agree, and the chapter sources its total from the generated `axiom-count`.
4. **`DecisionResult` constructors** — Fixed. Corrected from a false three-way split to the real
   four constructors, with the `fuelExhausted`/`extractionFailed` distinction explained. The
   chapter's other decision-procedure descriptions were re-checked and confirmed already correct.
5. **`Axiom` is Type-valued** — Fixed in all five sites found (three named by the
   dispatch/plan, two more found while editing): both `Axiom` and `DerivationTree` are
   `Type`-valued, not `Prop`-valued; Aesop's reconstruction targets `Prop`-valued goals, which is
   the real reason the search is hand-written at the meta level.
6. **`apply_axiom` description** — Fixed (docstring, worked example, and chapter item): it
   applies the generic axiom constructor and leaves `h`/`h_fc` open, it does not unify with a
   schema or infer parameters. `modal_t`'s docstring and worked example were rewritten the same
   way (its body is byte-identical); the chapter's `modal_t` item was already correct and left
   unchanged, as was `apply_axiom`'s Lean macro body itself (no statement/proof change).
7. **Introduction's project-structure list** — Fixed. List completed against a live directory
   listing (which also surfaced a newly-landed `HybridLanguage/` directory the original report
   predated); tooling attribution corrected to the separate `BimodalTools` library.
8. **Machine appendix metavariable letters** — Fixed. Swapped so guard is φ and event is ψ,
   matching the book's own stated convention; the explanatory paragraph and `CONFIRM(lean)`
   comment were already accurate and left unchanged.
9. **Template and build hygiene** — (a) Fixed: `#item` now hangs indented via native `list()`.
   (b) Fixed: build is warning-free (DejaVu Sans). (c) Explicitly out of scope per the dispatch
   (code-block presentation belongs to the follow-on task) — not touched.

## Residual Risks / Follow-ups

- `tryAxiomMatch`'s own list length ("27") remains a typed numeral with no generator, as the
  plan's Non-Goals record — a residual manual-maintenance risk if the list changes again.
- A significant, unrelated concurrent task (a different session, working on
  `FormalSystem/*Language/` extensions) ran throughout this task's entire execution, repeatedly
  changing `FormalSystem/` file and line counts. Every commit in this task was staged by explicit
  path (never `git add -A`/whole-file adds on files carrying mixed ownership) to keep that work
  out; see the phase handoffs for the specific partial-hunk-staging technique used on
  `typst/chapters/ax-lean-appendix.typ`, which independently carries a pre-existing, still-
  uncommitted, out-of-scope editorial-TODO diff (not part of this task, not touched). Both
  `lake build --wfail` and `typst-sync-check.sh` were confirmed green at this task's close
  regardless of that concurrent activity.
- `typst/chapters/ax-lean-appendix.typ` still carries three uncommitted `// TODO:` editorial
  review comments (marking exposition gaps), present before this task started and out of this
  task's scope to resolve (task 647 / a future define-before-use audit owns that file's content).
  This task only whitelisted the Check-1-breaking backtick spans inside them, per its own Phase 1.

## Impacts

- The rendered reference manual no longer prints a nonsensical "Chapter 1534"/"Chapter 1512" for
  either back-matter appendix, and both now carry a real, referenceable "Appendix A"/"Appendix B"
  identity in prose, cross-references, and the table of contents.
- Three previously-disagreeing Lean docstrings, a chapter, and a module inventory now state
  consistent, machine-verified facts about axiom coverage and `Type`-valuedness.
- The build is fully warning-free for the first time this task tracked, and item lists no longer
  visually misalign when they wrap.

## References

- Plan: `specs/648_fix_reference_book_defects_found_in_appendix_review/plans/01_fix-reference-book-defects.md`
- Progress files: `specs/648_fix_reference_book_defects_found_in_appendix_review/progress/phase-{1..9}-progress.json`
- Handoffs: `specs/648_fix_reference_book_defects_found_in_appendix_review/handoffs/phase-{1..8}-handoff-*.md`
