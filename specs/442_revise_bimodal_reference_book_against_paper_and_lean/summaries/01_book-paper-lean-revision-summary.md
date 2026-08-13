# Implementation Summary: Revise BimodalReference Against the Paper and the Lean Tree

- **Task**: 442 - revise_bimodal_reference_book_against_paper_and_lean
- **Status**: [COMPLETED]
- **Started**: 2026-08-13T00:00:00Z
- **Completed**: 2026-08-13T00:00:00Z
- **Effort**: ~21 hours planned, all 16 phases across 9 dependency waves completed in this
  dispatch
- **Dependencies**: None
- **Artifacts**: plans/01_book-paper-lean-revision.md, reports/01_book-paper-lean-sync-audit.md,
  reports/02_revision-findings.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Revised `typst/BimodalReference.typ` and all of `typst/chapters/` so the book is faithful to the
paper at `possible_worlds.tex` and to the live Lean tree, and is adequate as exposition. All 16
plan phases completed: the mechanical sync-check gate closure (Check 1 25→0 violations, Check 2
clean), the reversed completeness story, the deleted conservative-extension theorem, the
retracted decidability premise, the four-frame-class module-table rebuild, and the expository
mandate (introduction, six remarks, five diagrams, bibliography).

## What Changed

- `02-semantics.typ`: task frames rebuilt to the paper's current four-axiom `def:frame`
  (Compositionality, Seriality, Limit, Spherical), Nullity restated as a derived lemma
  (`lem:nullity`), world histories rebuilt to the partial/world/total layering with `H_F`
  correctly denoting only total histories, the extension machinery (Constraint Lemma through the
  Extension Theorem) added, two cetz diagrams added.
- `04-metalogic.typ`: new "Why TM Is Incomplete" section (discrete-or-dense dichotomy, the (DD)
  split validity, Halldén clarification, BL^+ completeness table), module table rebuilt from the
  live tree (four frame classes, unified `Soundness.lean`, `StrongCompleteness.lean`), two cetz
  diagrams added (two-fibre Z/R countermodel, three-way case-split).
- `p2-frame-classes.typ`: conservativity section rewritten to the paper's four-part status,
  frame-class lattice diagram added (Dedekind strictly above Dense), Dedekind axiom row added.
- `p2-decidability-practice.typ`, `p3-decidability-frontier.typ`: decidability status corrected
  to open with the DF/CO witnesses; dead `FMP/DenseFMP.lean`/`FMP/DiscreteFMP.lean` citations
  replaced with the accurate discrete-only account.
- `03-proof-theory.typ`, `06-notes.typ`, `p3-ltl-to-tm.typ`, `01-syntax.typ`: conservativity and
  completeness passages corrected; six reader-stumble remarks added across the book.
- `00-introduction.typ`: motivated introduction (task frames vs. Kripke frames, the ordered-
  abelian-group choice, what MF buys), outline rewritten to match the live `#include` order.
- `05-theorems.typ`: repointed `Bridge.lean` → `MonotonicityDuality.lean`; added the
  MF/MT-derivation remark; cited `dorr2020diamonds`.
- `bibliography.bib`: five entries added (Prior 1967, Dorr & Goodman 2020, Bacon & Zeng 2022,
  Walsh 2016, Rumberg & Zanardo 2019).
- `sync-check-whitelist.txt`: eight new entries, each with a one-line reason; no dead `.lean`
  path whitelisted (reviewed end-to-end).
- `typst/README.md`: de-numbered follow-up table, Marker Convention section with a 7-entry
  occurrence table for `LEAN-ANCHOR-MAY-MOVE`.
- `typst/SYNC-MAP.md`: new dated verdict section appended (historical tables untouched).
- `typst/generated/status.typ`: regenerated via `typst-status-counts.sh`.

## Decisions

- Delete-don't-repoint applied strictly to the entire `Metalogic/ConservativeExtension/` cluster
  (now Boneyard-only); no whitelist entry admits a dead `.lean` path.
- The BX-level `completeness_dense`/`completeness_discrete`/`completeness_dedekind` theorems and
  the paper's `cor:tm-completeness` claim about TM_d/TM_f are presented as an open cross-
  reference, not adjudicated as either consistent or contradictory — recorded as finding 1b in
  `reports/02_revision-findings.md` rather than resolved unilaterally.
- `LEAN-ANCHOR-MAY-MOVE` markers placed at headline claims per scope (7 sites), not exhaustively
  at every secondary mention — documented as a deliberate scope limitation in the README.

## Plan Deviations

- None (implementation followed the plan's 16-phase, 9-wave structure phase-by-phase; several
  scope hypotheses were superseded by fresh greps as the plan itself instructed, e.g. Phase 6's
  conservativity sweep found `01-syntax.typ` beyond the plan's four-file hypothesis, and Phase 12
  caught two additional frame-class-count misses via wording variants the original sweep did not
  match).

## Impacts

- `bash scripts/typst-sync-check.sh` now exits 0 with all three checks green (previously failing
  on Check 1 with 25 violations).
- `typst compile BimodalReference.typ` succeeds with no unresolved references or citations
  (99 pages).
- A separate Lean task targeting a conservativity-bridge formalization has a stale premise
  (`thm:ConservativeExtension`, deleted from the paper) — flagged for the user, not modified.
- The in-flight `completeness_over_total_history_semantics` Lean task shares territory with 4 of
  the 7 `LEAN-ANCHOR-MAY-MOVE` markers; a re-sync sweep after it lands is recommended.

## Follow-ups

- Reconcile finding 1b (BX-level Dense/Discrete/Dedekind completeness vs. `cor:tm-completeness`'s
  TM_d/TM_f status) — owner: user, timing: alongside or after the in-flight canonical-completeness
  work.
- Re-sync sweep on the 7 `LEAN-ANCHOR-MAY-MOVE` sites once 415/417/419 land.

## References

- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/plans/01_book-paper-lean-revision.md`
- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/01_book-paper-lean-sync-audit.md`
- `specs/442_revise_bimodal_reference_book_against_paper_and_lean/reports/02_revision-findings.md`
- `typst/SYNC-MAP.md` (2026-08-13 verdict section)
