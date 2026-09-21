# Implementation Summary: Task #647

- **Task**: 647 - Extend the Lean appendix to semantics, a derived theorem, the metalogic map, and the decision procedure
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T14:20:00-07:00
- **Completed**: 2026-09-21T16:05:00-07:00
- **Effort**: ~1h45m
- **Dependencies**: None upstream. Tasks 648 and 649 are ordered after this task and were not pre-empted.
- **Artifacts**: plans/01_extend-lean-appendix-coverage.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`typst/chapters/ax-lean-appendix.typ` grew from nine sections to fourteen, so a reader who knows
the mathematics of *TM* but has never opened a Lean file can now read the semantic layer, a
derived theorem and its semantic counterpart, functions on derivations, the metalogic result map
and the decision procedure, not only the syntax and proof system it covered before. All ten
dispatch coverage items landed, threaded into the existing arc in dependency order rather than
appended. `scripts/typst-status-counts.sh` and `scripts/typst-sync-check.sh` Check 2 were
extended together so every newly cited figure is generator-derived and cannot drift silently.

## What Changed

- `typst/chapters/ax-lean-appendix.typ` — 446 lines to 1014. Five new sections
  (`lean-appendix-dependent-fields`, `lean-appendix-recursion`, `lean-appendix-derived-theorem`,
  `lean-appendix-semantic-counterpart`, `lean-appendix-derivations-as-data`) and three extended
  in place (`lean-appendix-structures`, `lean-appendix-lake`, `lean-appendix-reading-source`).
  All ten pre-existing `lean-appendix*` labels are byte-identical and each occurs exactly once.
  31 `#leansrc` excerpt blocks (39 segments) and 12 compiled didactic blocks.
- `scripts/typst-status-counts.sh` — emits three version pins (`lean_toolchain_pin`,
  `mathlib_tag`, `mathlib_rev`) and six per-tree scale figures in BOTH the `--json` payload and
  the `status.typ` write path. All are filesystem or git reads, so `--json` stays build-free, as
  Check 2 requires. Keeps the `FormalSystem.lean` import-count cross-check, warning on stderr
  rather than aborting.
- `scripts/typst-sync-check.sh` — Check 2 gained the six integer keys in `scalar_fields` and a
  new `string_fields` comparison path for the three pins, since the existing path matches
  `(\d+)` only and a string field added naively would report `MISSING` on every run.
- `typst/generated/status.typ` — regenerated (never hand-edited).
- `typst/sync-check-whitelist.txt` — two optional-parameter spans under a new category comment.
- `typst/SYNC-MAP.md` — new dated entry describing the new coverage, plus an inline correction to
  the 2026-09-17 entry's two stale claims.

No Lean source was changed. This task's nine commits touch zero `.lean` files.

## Decisions

- **Excerpt policy stated as token-identity, not byte-identity.** The appendix re-breaks long
  lines to fit its 71-column budget, so "verbatim up to whitespace" is the operative claim. The
  invariant is the token sequence, and it is now machine-checked rather than asserted.
- **Check 1 failures fixed by the source's own spelling, not by whitelisting.** Nine candidate
  spans failed Check 1 during authoring. Two genuine optional-parameter illustrations were
  whitelisted; the other seven were re-expressed using the source's spelling or moved into
  compiled didactic blocks, which Check 1 does not scan.
- **A repo-wide tracked-file count was written and then removed.** It changes on every commit
  that adds any file anywhere, so policing it under Check 2 would fail the sync check on work
  that never touched a cited figure. Repository scale is carried by the three per-tree Lean
  counts instead.
- **`SYNC-MAP.md` history was corrected in place rather than rewritten.** The file's own header
  states that its dated entries are a historical record retained as-is, so the 2026-09-17 entry
  keeps its text with a bracketed supersession note naming both stale claims, and the new
  coverage is described in a new dated entry.

## Plan Deviations

- **Phase 5** altered: `Perpetuity.contraposition` does not resolve under Check 1, so the
  ambiguity is stated in prose by naming both namespaces (`Theorems.Perpetuity` and
  `Theorems.Propositional`), which do resolve.
- **Phase 5** altered: `FrameClass.Base ≤ FrameClass.Dense` and `FrameClass.Base ≤
  FrameClass.ZTime` are not verbatim in source and fail Check 1 as inline spans, so the four
  order facts are carried as a compiled didactic block.
- **Phase 6** altered: result-map table columns are *frame class* / *declaration* / *status*
  rather than *statement* / *declaration* / *status*; each family's statement is given once in
  its lead sentence instead of being repeated in sixteen cells.
- **Phase 8** altered: the repo-wide `git ls-files` count was dropped (see Decisions).
- **Phase 9** altered: `Conservativity.plusDerivable_ofFormula_iff` does not resolve under
  Check 1 either, so the bare `plusDerivable_ofFormula_iff` is cited with its namespace
  `FormalSystem.Metalogic.Conservativity` named beside it.
- **Phase 10** altered: `SYNC-MAP.md`'s historical entry was corrected in place with a
  supersession note rather than rewritten (see Decisions).

## Verification

Four acceptance gates, final run, recorded verbatim:

- `(cd typst && typst compile --root .. BimodalReference.typ)` — exit 0. The only output is the
  two pre-existing `unknown font family: new computer modern sans` warnings from `thmbox`, which
  task 648 owns.
- `bash scripts/typst-sync-check.sh` — `PASS (all 3 checks green)`. Check 1:
  `TOTAL_VIOLATIONS=0`, `TOTAL_CANDIDATES=797` (688 at baseline). Check 2: `MISMATCH_COUNT=0`.
  Check 2b: `MODULE_MAP_MISMATCHES=0`. Check 3: `MA_COUNT_MISMATCHES=0`.
- `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ` —
  `[PASS]`, 0 remarks, 0 failures, 0 warnings.
- `grep -n ';' typst/chapters/ax-lean-appendix.typ | grep -v 'apply DerivationTree.axiom'` —
  no output. Exactly one semicolon remains in the file, the permitted macro body at line 594.

Excerpt fidelity:

- All 39 segments across the 31 `#leansrc` blocks machine-diffed against live source by
  tokenising each segment and requiring it to appear as a contiguous sublist of the source
  file's token stream with docstrings stripped. `MATCH=39 DIFF=0`.
- No code line in the file exceeds 71 columns (235 code lines scanned).

Render inspection:

- All 30 appendix pages (88-117 of 126) rendered with `pdftoppm` and inspected.
- No orphaned `#leansrc` label on any page, confirmed both mechanically across all 30 pages and
  visually. No wrapped code lines. No block/paragraph collisions.
- One finding fixed: the Mathlib resolved-commit cell sat flush against the right margin with
  no slack, so the three pin values now render at 8pt.
- One finding recorded, not fixed: a page ending shortly before a large excerpt leaves visible
  trailing white space (pages 92, 94, 95, 96 are the clearest), because the file-local rule sets
  `breakable: false` so no excerpt splits across a page. This predates the task — page 92's gap
  comes from the pre-existing `DerivationTree` excerpt — and fixing it would mean allowing
  excerpts to split.

Check 2 coupling, proved by perturbation rather than inspection:

- `formalsystem-line-count` set to 999999 produced
  `VIOLATION: formalsystem-line-count: committed=999999 live=283236` and FAIL.
- `mathlib-tag` set to `v0.0.0-bogus` produced
  `VIOLATION: mathlib-tag: committed=v0.0.0-bogus live=v4.33.0-rc1` and FAIL.
- Restoring each returned `MISMATCH_COUNT=0` and PASS.

Lean-side verification (this task changed zero `.lean` files):

- Build: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, run
  detached, exit 0, "Build completed successfully (2683 jobs)".
- Sorry count: 0 (`lean-sorry-census.sh FormalSystem/`).
- Vacuous count: 1, unchanged from the pre-task baseline. The single grep hit is
  `FormalSystem/Examples/TemporalStructures.lean:483`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, a genuine proof
  that a definitionally-`True` domain predicate holds, not a placeholder. Not introduced here.
- Axiom count: 12, unchanged from the pre-task baseline.
- Didactic snippets: `lake env lean` on the scratch file (outside `FormalSystem/` and `Tests/`,
  never committed) exits 0 with zero errors, re-run after the final edits.
- Files verified: Yes.

Constraint checks:

- No `specs/` path and no task number anywhere in the appendix.
- All ten pre-existing `lean-appendix*` labels present exactly once; `@lean-appendix` still
  resolves from `00-introduction.typ` (two references).
- The opening paragraph's stated section count (fourteen) equals the actual `==` heading count.

## Impacts

- The appendix's soundness walkthrough no longer leaves `F.Duration.carrier` unexplained, which
  was a live defect for any reader who ran `#check` themselves.
- `typst/generated/status.typ` now carries version pins and repository-scale figures that other
  chapters can cite instead of hand-typing.
- Check 2 now polices nine more fields, including three string-valued ones. **Consequence worth
  knowing**: the `FormalSystem/` and `Tests/` line counts move whenever any task edits Lean
  source, so `scripts/typst-status-counts.sh` must be re-run and `status.typ` re-committed after
  such work, or the sync check fails. This surfaced twice during this task while another task
  was committing Lean changes concurrently.
- Tasks 648 and 649 apply cleanly on top: the appendix title and every `lean-appendix*` label are
  unchanged, `p2-decidability-practice.typ` and `template.typ` were not touched, and every
  `#leansrc` call site keeps the current two-argument signature.

## Follow-ups

- The `SYNC-MAP.md` 2026-09-17 entry's "Pre-existing, unrelated Check 2b finding" is now stale in
  the other direction: Check 2b currently passes. Left alone, since it is a dated historical
  record.
- The research report's two context-extension recommendations (record the generator-plus-Check-2
  pairing rule somewhere discoverable, and state the `#leansrc` excerpt policy once in a shared
  place rather than in three) are not addressed here. The new `SYNC-MAP.md` entry states both,
  but a `typst/README.md` section would be the durable home.

## References

- specs/647_extend_lean_appendix_semantics_metalogic_coverage/plans/01_extend-lean-appendix-coverage.md
- specs/647_extend_lean_appendix_semantics_metalogic_coverage/reports/01_extend-lean-appendix-coverage.md
- specs/647_extend_lean_appendix_semantics_metalogic_coverage/handoffs/phase-1-handoff-20260921.md through phase-10-handoff-20260921.md
- typst/SYNC-MAP.md, 2026-09-21 entry
