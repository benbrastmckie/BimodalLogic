# Implementation Summary: Task #467

- **Task**: 467 - Systematically update FormalSystem/Metalogic/Decidability/README.md to be aligned with the current state of the Decidability/ directory
- **Status**: [COMPLETED]
- **Started**: 2026-08-20T01:48:25Z
- **Completed**: 2026-08-20T02:50:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_decidability-readme-alignment.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Corrected all 11 misalignments the research report identified between
`FormalSystem/Metalogic/Decidability/README.md` and the directory it documents, executed
section-by-section across six phases: the Overview's unproved decidability overclaim, the
Modules table's five missing rows and one nonexistent row, the stale `DecisionResult`
constructor set and missing `decideBlocking` entry point, the backwards `Correctness.lean` edge
and missing `TraceCertificate.lean` node in the dependency flowchart, two missing sibling README
links and a stale footer date, and a final whole-file consistency pass. The sole deliverable file
is `FormalSystem/Metalogic/Decidability/README.md`; `Verified/README.md` was deliberately left
untouched per the plan's Non-Goals.

## What Changed

- `FormalSystem/Metalogic/Decidability/README.md` — Overview bullet rewritten to describe the
  procedure as a tableau search for a proof or countermodel, name `decide_sound` as the one
  machine-checked direction, and cite `Correctness.lean`'s "Retired as vacuous" section for the
  open biconditional; Modules table rebuilt (`FMP.lean` row deleted, `CancellableExpansion.lean`/
  `TraceCertificate.lean`/`TraceExport.lean` rows added, `Verified/`/`Propositional/` summary rows
  added, `FMP/` file count normalized to the `.lean`-only convention); Quick Reference's
  `DecisionResult` constructor list corrected to `valid/invalid/fuelExhausted/extractionFailed`
  and `decideBlocking` added as a documented complement to `decide`; dependency flowchart
  redrawn — `Correctness.lean` moved to a separate downstream block (it imports
  `DecisionProcedure.lean`, not the reverse), `TraceCertificate.lean` added as a third child of
  `DecisionProcedure.lean`, the `Correctness.lean -> FMP/FMP.lean` edge added, and a scope
  caption listing deliberate omissions added; `Verified/README.md` and `Propositional/README.md`
  links added to Related Documentation; footer date updated to 2026-08-19.

## Decisions

- Rephrased the `DecisionResult` gloss to avoid the literal word "timeout" (using "single prior
  inconclusive-verdict constructor" instead) so the phase's own Verification criterion — the word
  must not appear anywhere in the Quick Reference — is satisfied while still conveying the
  post-R7 constructor split.
- Resolved two cross-cutting import edges (`Saturation.lean -> TraceCertificate.lean`, and the
  `Correctness.lean -> DecisionProcedure.lean` edge itself, drawn as a separate downstream block
  rather than a line spanning the whole diagram) via adjacent prose notes rather than crossing
  ASCII lines, after an early attempt at a fully connected multi-way diagram produced
  hand-alignment errors. Every edge actually rendered as a box connector was verified
  programmatically (character-column checks) before being written to the file.
- Reused the exact box-drawing style and character widths of the original diagram's
  `DecisionProcedure.lean`/`ProofExtraction.lean`/`CountermodelExtraction.lean` boxes when
  extending the branch to three children, to keep the diff visually consistent with the
  pre-existing diagram aesthetic.

## Plan Deviations

- **Task 2.5** (TraceExport.lean row wording) altered: the plan's task text said the row should
  note consumption by "`Automation/TraceExporter.lean` and `DatasetGenerator.lean`". Re-derivation
  via `grep -n '^import' FormalSystem/Automation/DatasetGenerator.lean` showed `DatasetGenerator.lean`
  does not import `TraceExport.lean` — the only textual hit was an unrelated doc-comment mention
  inside `TraceCertificate.lean`. The row was written to cite only the confirmed importer,
  `Automation/TraceExporter.lean`.
- **Task 3.2** (Quick Reference gloss wording) altered: per the reasoning above, the optional
  gloss was added but reworded to avoid the literal word "timeout", to satisfy this phase's own
  stated Verification criterion.

## Verification

- Build: N/A (documentation-only task; no `.lean` file modified, per plan)
- Tests: N/A
- Files verified: Yes — every claim checked against the working tree (import lines, file
  listings, `inductive DecisionResult` block, `decideBlocking` definition, `sorry` occurrences,
  Related Documentation link targets)

All nine Testing & Validation checklist items in the plan pass:
- `git diff --name-only` across all phase commits names exactly one non-`specs/**` file:
  `FormalSystem/Metalogic/Decidability/README.md`.
- No `.lean` file was modified.
- Every top-level `.lean` file (13 confirmed) has exactly one Modules table row; no row names a
  nonexistent file.
- Subdirectory file counts match freshly re-derived `.lean`-only counts: `FMP/`=6, `BiLasso/`=18,
  `Verified/`=21, `Propositional/`=3.
- All seven Related Documentation links resolve to existing files.
- The four `DecisionResult` constructors in the README (`valid`, `invalid`, `fuelExhausted`,
  `extractionFailed`) match `DecisionProcedure.lean`'s `inductive DecisionResult` block exactly.
- Every edge drawn in the dependency flowchart corresponds to a real `import` line, verified via
  `grep -n '^import FormalSystem.Metalogic.Decidability' FormalSystem/Metalogic/Decidability/*.lean`.
- `FormalSystem/Metalogic/Decidability/Verified/README.md` shows no modification in `git status`.
- The only "decides"-adjacent claim remaining in the file is the pre-existing, accurate
  `BiLasso/` row statement that it does **not** decide the logic — no claim that TM validity
  itself is decided.

## Impacts

- Downstream readers of this README (both human contributors and future agent-dispatched
  research/planning work on `Decidability/`) now see an accurate inventory, corrected result-type
  vocabulary, and a directionally correct dependency diagram, removing a source of a previously
  retired-but-still-documented overclaim about TM decidability.

## Follow-ups

- `FormalSystem/Metalogic/Decidability/Verified/README.md` is itself substantially stale (per the
  research report's Finding 9 caveat: 8+ existing, compiling files marked "planned" in its table,
  and 11 files absent from that table entirely). It was explicitly out of scope for this task
  (Non-Goal) and warrants its own follow-up task.
- A repo-wide grep for the removed Overview phrasing ("Decides validity of TM bimodal logic
  formulas") outside `specs/**` returned zero hits, so no other document needs a matching
  correction at this time.

## References

- `specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md`
- `specs/467_update_decidability_readme/plans/01_decidability-readme-alignment.md`
- `FormalSystem/Metalogic/Decidability/README.md`
- `FormalSystem/Metalogic/Decidability/Correctness.lean`
- `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`
