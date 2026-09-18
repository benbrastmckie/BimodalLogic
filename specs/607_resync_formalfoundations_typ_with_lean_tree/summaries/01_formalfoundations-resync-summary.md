# Implementation Summary: Task #607

- **Task**: 607 - Resync typst/FormalFoundations.typ with the current Lean tree and paper vocabulary
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T00:00:00Z
- **Completed**: 2026-09-18T04:45:00Z
- **Effort**: ~5 hours
- **Dependencies**: None (task 584, which deferred this work, is complete)
- **Artifacts**: plans/01_formalfoundations-resync-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Resynced `typst/FormalFoundations.typ` with the current Lean tree and paper vocabulary across all
six planned phases: fixed the axiom-key renames (`TB`/`TA` -> `TS`/`TC`) and the Machine-Checked
Status remark's constructor counts (22/5 -> 11/4); built a 98-row classification inventory of
every `TM`/`op("TM")`/`#BL`/`#BLplus` site; applied the `TM`/`TM⁻` and `#BL`/`#BLminus` naming
swap the codebase's own Lean tree and `paper-definitions-of-record.md` already settled on; added
provenance remarks explaining the naming; and ran the full gate set, finding and fixing 11 stale
`#leansrc` citations beyond what the plan's scope hypothesis anticipated.

## What Changed

- `typst/FormalFoundations.typ` — every phase's edits: axiom-key renames and count-remark fix
  (Phase 1); macro rename (`#let BL`/`#let BLplus` swapped, `#let TMminus` added) and file-wide
  `#BL`/`#BLplus` token rename plus §1 system-name renames (Phase 3); §2-§5 system-name renames,
  including the exact-wording conservativity remark fix (Phase 4); two provenance remarks (one
  new, one rewritten) and a narrative-consistency fix inside the TM⁻ definition block (Phase 5);
  one `typst-sync-check.sh` Check-1 fix and 11 stale `#leansrc` citation retargets (Phase 6).
- `specs/607_resync_formalfoundations_typ_with_lean_tree/working/tm-site-inventory.tsv` — created;
  98-row classification inventory (line, section, pattern, excerpt, verdict, reason, applied) of
  every ambiguous `TM`/`BL` site in the document, the load-bearing artifact phases 3-5 executed
  against.

## Decisions

- Adopted the plan's naming decision without modification: the paper's system (formerly written
  `op("TM")^+` over `#BLplus`) is now plain `TM` over `#BL`; the repository-only H/G system
  (formerly bare `TM` over `#BL`) is now `TM⁻` over `#BLminus`. This matches
  `FormalSystem/Metalogic/Conservativity.lean`'s own "System names, and how they map onto the
  paper" docstring, confirmed independently during Phase 2's cross-referencing.
- For a handful of sites not explicitly enumerated by the plan's Phase 3/4 task lists (the
  Discreteness Dichotomy remark's "TM-unprovable"/"TM-sound", the Strongest Objective Modality
  remark's "never a theorem of TM or `op(TM)^+`" contrast, and the closing Representation-Theorem
  remark), applied the same TM/TM⁻ verdict the TSV recorded for them, reasoning by analogy from
  the plan's explicitly-named sibling sites (the conservativity remark, which uses the identical
  contrast-sentence shape).
- Fixed the "TM⁻'s TL ... this is the paper's own presentation" sentence inside §1's TM⁻ block:
  attributing TL's disjunct order to "the paper's own presentation" no longer made sense once the
  document establishes (in the very next remark) that TM⁻ has no paper counterpart. Reworded to
  attribute it to the document's own historical presentation instead.

## Plan Deviations

- None (implementation followed plan). Two scope hypotheses in the plan undercounted the real
  totals — expected and explicitly anticipated by the plan itself ("Confirm the counts... record
  the actual totals"): Phase 1's `TB`/`TA` site count was 15, not 14; Phase 2's TM/BL site count
  was 98 distinct lines, not the ~79/35/13/22 per-pattern estimates.

## Verification

- Build: `typst compile FormalFoundations.typ` — Success (exit 0, only pre-existing font warnings)
- Tests: N/A (no test suite for this artifact)
- `bash scripts/typst-sync-check.sh` — PASS (all 3 checks green, 0 violations, 676 candidates)
- `bash scripts/check-paper-definitions.sh` — pass (all 42 recorded definitions unchanged)
- `#leansrc` existence check — 67 citations / 66 unique pairs, all resolve after fixing 11 stale
  ones (see Follow-ups for the one still-open conceptual-correctness question this check cannot
  itself settle)
- Residual greps (`TB`/`TA`, `op("TM")^+`, `#BLplus`, `twenty-two`/`five constructors`) — all clean
- `check-task-references.sh` fallback grep — no task-number references added
- Files verified: Yes

## Impacts

- `typst/FormalFoundations.typ` now states the correct axiom-constructor counts, uses the paper's
  own `TS`/`TC` keys, and names each system (TM vs. TM⁻) consistently with the rest of the
  repository's documentation and Lean source. Nine `#leansrc` citation lines now point at the Lean
  declarations that actually back the claims they annotate, rather than at stale or wrong module
  paths — a defect that predates this task and was invisible to `typst-sync-check.sh`'s Check 1
  (which only verifies backticked *text* resolves against Lean source, not that a `#leansrc`
  module/decl *pairing* is internally correct).

## Follow-ups

- **Two apparent `#leansrc` citation-target defects, deeper than a stale path, were found during
  Phase 2's theorem-attribution check and left unresolved (out of this plan's explicit
  renaming-only scope):**
  - The §2 Soundness theorem (`typst/FormalFoundations.typ`, "TM⁻ and for each of its four
    frame-class extensions...") cites `Metalogic.Soundness.soundness`/`soundness_dense`/
    `soundness_ztime`/`soundness_rtime`, which per `Soundness.lean:185`'s own docstring are stated
    over `Formula` (the until/since-primitive language, i.e. the paper's TM) — not over
    `MinusFormula`, despite the theorem's own DF/DN/CO content matching TM⁻ exclusively (per
    `MinusLanguage/Axioms.lean`'s DF/DN/CO table). The dedicated `minus_soundness`/
    `minus_soundness_dense`/`minus_soundness_ztime`/`minus_soundness_rtime` family in
    `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` (whose stale module path
    this task DID fix, at the §5 Algebraic-soundness proposition) looks like the theorem the
    Soundness section actually needs.
  - Conversely, the §5 "Algebraic soundness" proposition (about `op("TM")`-algebras, i.e. the
    paper's TM) cites that same `minus_soundness*` family — the citations at those two sites look
    swapped with each other. This is a conceptual-correctness question (which Lean theorem
    actually proves which typst claim) that a mechanical existence check cannot settle on its own;
    it needs a dedicated verification pass, ideally by someone who can also confirm whether the
    document's own DF/DN/CO-vs-UZ/Z1/DN/NN/PU/SEP system boundary is itself still accurate.
- The `f/d/c` -> `z/d/r` frame-class subscript rename (paper's current convention; this document
  still uses the paper's old `f/d/c` subscripts throughout) — explicitly deferred as a Non-Goal,
  not a pure relabel (`BX_r` extends `BX_d` in the paper's current presentation; this document's
  `BX_c` extends BX directly).
- The same TM/TM⁻/BL naming resync for `typst/chapters/p2-decidability-practice.typ` and the rest
  of `typst/BimodalReference.typ`, which still use the pre-rename bare-`TM`/`op("TM")_f` family
  (confirmed present via a spot grep during research; not touched by this task, which is scoped
  to `FormalFoundations.typ` only).
- Promoting the "Language correspondence" table (in `docs/reference/paper-definitions-of-record.md`)
  to a standalone document — the research report's own suggestion for a separate task.

## References

- Plan: `specs/607_resync_formalfoundations_typ_with_lean_tree/plans/01_formalfoundations-resync-plan.md`
- Research: `specs/607_resync_formalfoundations_typ_with_lean_tree/reports/01_formalfoundations-typst-resync.md`
- Inventory: `specs/607_resync_formalfoundations_typ_with_lean_tree/working/tm-site-inventory.tsv`
- Handoffs: `specs/607_resync_formalfoundations_typ_with_lean_tree/handoffs/phase-{1..6}-handoff-*.md`
