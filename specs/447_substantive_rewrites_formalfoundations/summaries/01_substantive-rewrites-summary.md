# Implementation Summary: Task #447

- **Task**: 447 - Substantive rewrites in FormalFoundations.typ: proof repair, axiom presentation, section restructure
- **Status**: [COMPLETED]
- **Started**: 2026-08-18T15:42:00Z
- **Completed**: 2026-08-18T16:40:00Z
- **Effort**: ~2 hours (single dispatch, all 9 phases)
- **Dependencies**: 446 (complete)
- **Artifacts**: plans/01_substantive-rewrites.md, reports/02_source-transcription.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All 9 plan phases executed in a single dispatch, resolving all six substantive `FIX:` directives
in `typst/FormalFoundations.typ` with content transcribed from
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. Every phase ended at a
green `typst compile`, and each phase was committed separately. The final file compiles cleanly
with only the two pre-existing thmbox font warnings, matching the Phase 1 baseline exactly.

## What Changed

- `typst/FormalFoundations.typ` — repaired the Extension proof by adding four live blocks
  (`#definition("Constraints")`, `#lemma("Directedness")`, `#lemma("Admissibility")`,
  `#lemma("Step")`) and restoring the proof itself, citing only Zorn's lemma and the Step Lemma;
  expanded `#definition("Task Topology")` into five indented sub-items (Basic Opens, Topology,
  Closure, T1, R0); formalized `#definition("S5")` as five indented axiom items; expanded
  `#definition("BX")` into all seventeen keys across four groups, with the `⟨S|U⟩`-swap notation
  defined first; added systematic definitions for `TM+`, `BX_f`, `BX_d`, `BX_c`, and the `TM+_f/d/c`
  extensions, correcting the frame-class table's "Prior-S" transcription error (in two places) to
  the paper's actual Prior-U/Sep pair; added `#definition("TM")` (BL-level, 3 rules + 9 axioms),
  its extensions `TM_f/d/c/dc` with DF/DN/CO stated in full, and `#definition("Derivability")`
  closing the gap left by task 446's now-live `⊨` definition; replaced the "Completeness and
  Decidability" section's introduction with a concrete 5-sentence overview.
- `specs/447_substantive_rewrites_formalfoundations/reports/02_source-transcription.md` — new;
  the Phase 1 transcription record pairing every LaTeX source string with its Typst rendering,
  built after re-anchoring against the current (further-drifted) working tree and source paper.

## Decisions

- Adopted the plan's condensed Extension-proof ladder (4 blocks instead of the paper's 7-link
  chain), matching the paper's own already-merged `lem:admissible` (its `% CHANGE` comment
  confirms the paper authors independently folded the standalone fiber lemma in).
- Left `cor:spherical-finite` at footnote level rather than adding a corollary block, per the
  plan's instruction not to duplicate the claim.
- Fixed the "Prior-S" transcription error in both its Phase-5-scoped occurrence (the frame-class
  table and footnote) and a second occurrence outside the phase's nominal file scope (a footnote
  in the completeness-construction section, line ~868) — required by the phase's own verification
  criterion that `grep -c "Prior-S"` return 0 file-wide, not just within the edited region.
- Replaced deprecated `angle.l`/`angle.r` with `chevron.l`/`chevron.r` in the new BX/TM swap
  notation to avoid introducing new compiler warnings beyond the Phase 1 baseline.
- Adjusted the Step-Lemma prose paragraph's wording ("The Step Lemma above is the sole application
  site...") to point at the now-live `#lemma("Step")` rather than at an external paper citation,
  per Phase 8's knitting instruction; left the post-Separation `#remark[...]` unchanged since its
  wording was already abstract enough to read correctly once Step became live.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: Success — `typst compile typst/FormalFoundations.typ` exits 0 after every phase.
- Tests: N/A (no test suite for this document).
- Files verified: Yes.
- `grep -c "FIX:" typst/FormalFoundations.typ` = 0.
- Warning set after the final compile is byte-identical to the Phase 1 baseline (two pre-existing
  "unknown font family: new computer modern sans" warnings from thmbox).
- Axiom completeness audit: all 33 named axioms (MK, MT, M5, MP, MN, TN, TD, TB, TL, CN, TA, UE,
  UT, UI, UC, UF, UG, SU, NP, NF, NA, NB, MF, UZ, Z1, DN, NN, Prior-U, Sep, CO, DF, TK, T4) have a
  full formal statement at their point of definition.
- Citation-integrity audit: every lemma/theorem cited inside a `#proof[` block resolves to a live
  block in the document (Admissibility, Compositionality, Directedness, Limit, Nullity, Seriality,
  Spherical, Step).
- Count invariants confirmed: S5 = 5, BX = 17 (2+3+8+4), BX_f = 2, BX_d = 2, BX_c = 2 postulated +
  1 derived, TM = 3 rules + 9 axioms (12 items), Task Topology = 5 sub-items.
- `grep "cor:tm-decidability"` — no occurrence (none introduced). `grep -c "cor:tm-completeness"`
  = 1, byte-identical to the pre-task file (the pre-existing footnote at the representation-theorem
  remark; nothing migrated from it into the proof-systems section).
- `Completeness <sec:completeness-status>` subsection is byte-identical to the pre-task version.
- `git diff --stat` against the pre-task commit shows only `typst/FormalFoundations.typ`, the two
  task artifacts (plan, transcription record), and the expected `specs/TODO.md`,
  `specs/state.json`, `specs/events.jsonl` task-management side effects.

## Impacts

- The Extension theorem is now self-contained: a reader no longer needs to consult the source
  paper to verify the proof's lemma dependencies.
- The derivability relation `⊢` now has a document-local definition, closing the self-containedness
  gap task 446 introduced by making `⊨` live without a `⊢` counterpart.
- The proof-systems section now gives a complete, systematic account of ten named systems (S5, BX,
  BX_f, BX_d, BX_c, TM+, TM+_f, TM+_d, TM+_c, TM, plus TM_f/d/c/dc) with every axiom stated once,
  in full, at first use.
- The "Prior-S" transcription error is corrected everywhere it appeared, preventing a reader from
  hunting for a nonexistent third Reynolds axiom.

## Follow-ups

- None.

## References

- `specs/447_substantive_rewrites_formalfoundations/plans/01_substantive-rewrites.md`
- `specs/447_substantive_rewrites_formalfoundations/reports/01_substantive-rewrites-research.md`
- `specs/447_substantive_rewrites_formalfoundations/reports/02_source-transcription.md`
- `typst/FormalFoundations.typ`
