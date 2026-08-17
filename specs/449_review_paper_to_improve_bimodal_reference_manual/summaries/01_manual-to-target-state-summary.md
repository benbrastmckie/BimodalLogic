# Implementation Summary: Task #449

- **Task**: 449 - review_paper_to_improve_bimodal_reference_manual
- **Status**: [COMPLETED]
- **Started**: 2026-08-17T17:30:00Z
- **Completed**: 2026-08-17T20:55:00Z
- **Effort**: ~3.5 hours (8 phases, single dispatch)
- **Dependencies**: None
- **Artifacts**: plans/01_manual-to-target-state.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Revised `typst/BimodalReference.typ` and its chapters to state the target end state of the
Since/Until-primitive bimodal system TM, per the governing directive: no progress-report prose,
every not-yet-established claim guarded by a maintainer-only `CONFIRM` comment, and the paper
credited exactly once in the front matter. All 8 plan phases closed with the full gate set green
(typst compile, `typst-sync-check.sh` 3/3, CONFIRM well-formedness, event-first residual grep,
book-wide citation gate, FIX-comment removal, `check-paper-definitions.sh`).

## What Changed

- `typst/notation/bimodal-notation.typ` — infix guard-first `snce`/`untl` macros (`⊲`/`⊳`) plus `snceOp`/`untlOp` display helpers
- `typst/README.md` — new CONFIRM Tag Convention section beside the Marker Convention
- `specs/paper-definitions-of-record.md` — full re-pin twice in one day: 22 drifted anchors re-quoted/re-hashed, 3 dangling anchors retired (`def:BL-model`, `cor:tm-decidability`, `lem:fibers`), 3 new anchors added (`thm:BLplus-PastFuture`, `thm:BLplus-NextPrevious`, `def:time-shift-histories`); 49 manifest anchors verified green
- `typst/chapters/01-syntax.typ` — guard-first grammar/tables, snce/past-first ordering, Burgess convention demoted to a literature footnote, standalone L+ framing, Next/Prev derived operators with discrete caveat, 3 FIX comments resolved
- `typst/chapters/02-semantics.typ` — snce clause before untl in guard-first infix, time-shift restated in translation form (Lean automorphism generality footnoted as design fact), T1/R0 topology footnote, full E2 citation sweep (13 CONFIRM(paper) comments now carry provenance)
- `typst/chapters/03-proof-theory.typ` — nine layers with new Layer 9 (Reynolds Dedekind, K+/K− abbreviations; tables sum to 45), four-value FrameClass with Dedekind-above-Dense order, short-name cross-index column (TB, UG, UC, TA, ...), §Relation to the Paper's Presentation recast as §The Tense-Primitive Subsystem, all schemas guard-first
- `typst/chapters/04-metalogic.typ` — (DD)/two-fibre/Halldén incompleteness exposition cut entirely (Decision D1); four target completeness theorems with CONFIRM obligations; non-compactness negative results in body; dichotomy theorem retained standalone with `@sec:dichotomy` label; Implementation Status recast as Formalization Anchors table
- `typst/chapters/p2-frame-classes.typ` — Dedekind↔TM_c labeling fixed (no TM+_dc), conservativity theorem box replaced by deferred-subsystem note, Next/Prev guard-first, complete-order-class gap phrased as design scope
- `typst/chapters/p2-decidability-practice.typ` — decidability stated as CONFIRM-guarded target, class-specific-FMP two-witness content kept, status table removed
- `typst/chapters/06-notes.typ` — recast as permanent design notes; deferred-subsystem axiom map labeled; completeness section reduced to a pointer
- `typst/chapters/p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`, `p3-decidability-frontier.typ` — retired axiom vocabulary fixed, all paper citations deleted (CONFIRM(paper) provenance), notation swept
- `typst/chapters/ax-machine-appendix.typ` — Dedekind added to frame_class enumeration, guard-first JSONL CONFIRM added
- `typst/BimodalReference.typ`, `typst/chapters/00-introduction.typ` — abstract/introduction reframed to target state with naming remark (book's TM = source work's TM+), Z/Q phrasing fixed, "8 layers" → 9, edition-history narrative removed
- `typst/SYNC-MAP.md` — dated 2026-08-17 verdict section appended
- `typst/sync-check-whitelist.txt` — 14 orphaned entries removed after per-entry citation greps; `allClosed arrow.r "valid"` retained (still cited)
- `typst/generated/status.typ` — regenerated (stamp only; no count drift)

## Decisions

- Extraction/well-formedness greps documented with `--include='*.typ'` so the README's own examples never self-match the gate.
- Book-native system names TM, TM_f, TM_d, TM_c used in the correspondence (per Decision N1's naming remark), with the source work's TM+ identified once in the introduction.
- Paper anchors inside CONFIRM comments written without backticks throughout (sync-check Check-1 safety).
- All 7 `LEAN-ANCHOR-MAY-MOVE` markers preserved (3 relocated within 04-metalogic to the new completeness section and anchors table).

## Plan Deviations

- **Phase 1 R14** altered: live paper had drifted far beyond the plan's known-drift list (22 anchors, not 2); absorbed under the plan's paper-drift contingency.
- **Phase 5 R5d** skipped: the CO/Reynolds-triple independence is no longer open — Lean's `CoNotPriorU.co_not_derives_prior_U_gap` is machine-checked sorry-free — so restating it as an open problem would be false; the only mention sat inside the D1-cut exposition.
- **Phase 8 closing gate** altered: paper drifted a second time (`lem:fibers` label removed); retired from the manifest and re-pinned at the gate.

## Verification

- Build: `typst compile BimodalReference.typ` exit 0 (every phase and at closure)
- Tests: `typst-sync-check.sh` PASS 3/3; `check-paper-definitions.sh` pass; CONFIRM well-formedness grep empty; book-wide E2 gate clean; event-first residual only the deliberate Burgess footnote; `FIX:` count 0
- Files verified: Yes (all 17 modified files compile into the book or pass their checkers)

## Impacts

- `grep -rn --include='*.typ' 'CONFIRM(lean)' typst/` and `'CONFIRM(paper)'` now enumerate the complete finished-state checklist for the Lean repo and the paper (19 lean / 22 paper obligation comments).
- The Lean guard-first constructor migration and the strong-completeness work will close CONFIRM(lean) obligations without further manual edits.
- The manual no longer cites `possible_worlds.tex` anchors in rendered content; anchor provenance lives in `specs/paper-definitions-of-record.md` and CONFIRM comments only.

## Follow-ups

- The paper is drifting rapidly (two re-pins in one day); re-run `check-paper-definitions.sh` before any future dispatch citing paper anchors.
- A dependent task premised on the deleted `thm:ConservativeExtension` needs re-scoping (surfaced to user in the plan; informational).

## References

- specs/449_review_paper_to_improve_bimodal_reference_manual/plans/01_manual-to-target-state.md
- specs/449_review_paper_to_improve_bimodal_reference_manual/reports/01_paper-manual-lean-alignment.md
- specs/449_review_paper_to_improve_bimodal_reference_manual/progress/ (phase-1 through phase-8 progress files)
- typst/SYNC-MAP.md (2026-08-17 verdict section)
