# Implementation Summary: Task #704

- **Task**: 704 - Certificate non-vacuity and shape gates
- **Status**: [COMPLETED]
- **Started**: 2026-10-02T21:36:57Z
- **Completed**: 2026-10-02T22:47:47Z
- **Effort**: ~1.3 hours wall (six phases; Phase 5 time-boxed and closed with exclusions after 29 min)
- **Dependencies**: 696 (completed), 703 (completed); not 706 (its finite-carrier refutations remain unlanded and are reserved as commented rows)
- **Artifacts**: plans/01_certificate-non-vacuity-shape-gates.md, probes/03_tier2_sliced_certificates.lean, summaries/01_certificate-non-vacuity-shape-gates-summary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two enforced checks were added to `scripts/check-module-invariants.sh` in the published vocabulary
of Beer, Ben-David, Eisner and Rodeh (2001): **C36 NON-VACUITY** (every certifying predicate under
`Metalogic/Decidability/` carries an exhibited, closed-term, axiom-pinned INTERESTING WITNESS whose
interest expression evaluates `true` against the built library, plus a COVERAGE-LIMIT GUARD over the
lasso-based class's refutation declarations) and **C37 CLAUSE-SHAPE CHECK** (every biconditional-
bearing definition under the three certificate roots has a reviewed allowlist row whose anchor
re-resolves on every run). The sliced class's first non-degenerate inhabitant,
`WitnessFamily.Embedded.liveFamily_sliced_certifies`, and the lifted sharing-class witness were
landed in a new module `PlusSlicedCertificate/Examples.lean` and pinned in C2 (now thirty rows).
Both gate modes print `ALL CHECKS PASSED`.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — Created new module: the sliced class's non-vacuity record (`liveFamily_sliced_certifies` by `decide`, 4 s, axiom-clean) and `liveFamily_toSharing_certifies`; vocabulary and literature cited by title in the docstring (no bib entry exists)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — Aggregator import line and one Submodules bullet pointing at the non-vacuity record
- `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `typst/generated/status.typ` — Regenerated surfaces (641 live files)
- `scripts/check-module-invariants.sh` — Four C2 pins (`liveFamily_certifies`, `liveFamily_sliced_certifies`, `liveFamily_toSharing_certifies`, `plusCompression_fails_at_pumpTarget`; count word thirty), the C36a/C36b and C37 bodies, `ENFORCE_C36`/`ENFORCE_C37` paragraphs, header enumeration, companion-file lines, `--no-build` note
- `scripts/certificate-witness-inventory.txt` — Created: 5 `witness` rows (one per certifying predicate; two for the lasso class), 5 `coverage-limit` rows, 4 reserved commented finite-carrier rows pending `FiniteCarrier.lean`
- `scripts/clause-shape-allowlist.txt` — Created: 42 rows over the 30 biconditional-bearing definitions (15 INTENDED, 8 RESIDUAL, 19 OUT-OF-SHAPE); RESIDUAL rows anchor both their own side's `trans_refl` field (file-qualified) and the residue declaration
- `scripts/README.md` — Two data-file table rows
- `docs/development/CI_CD_PROCESS.md` — C36b added to the Known Not-in-CI Gaps (C36a and C37 run in CI)
- `specs/704_certificate_non_vacuity_and_shape_gates/probes/03_tier2_sliced_certificates.lean` — Created: the width-2 Tier-2 constructions, preserved with their result

## Decisions

- `#guard` omitted from `Examples.lean`: the compiled instance cost ~60 s per build for evidence the 4 s kernel `decide` already supplies.
- Witness rows must be C2/C14-pinned as well as coverage-limit rows (a C21-style union subset check), which required pinning `Embedded.liveFamily_certifies` as a fourth row; C36 never prints axioms itself, so a leak is reported once, by C2.
- Witness rows carry a seventh field (the closure term) so C36b can print closure cardinalities; the interest expression is the rest-of-line last field. C36a writes the `#eval` lines C36b compiles -- one parser, two halves.
- C37 counts `def`/`abbrev`/`structure`/`class` spans only (a biconditional stated by a theorem is not a clause); anchors resolve as declarations, structure fields, file-qualified `path#name`, or files.
- Phase 5 closed `[COMPLETED WITH EXCLUSIONS]` after 29 minutes: both width-2 constructions elaborate in 2 s and their cheap conjuncts evaluate, but `liveAt 0` -- the landed checker's computed liveness fixpoint -- does not return within 300 s compiled for either, on only 4 positions and 4 window times, so no kernel `decide` proof is reachable; changing the checker is outside this task.
- `docs/theorem-index.md` was left untouched (siblings 705 and 710 own it this cycle); the new theorems have no index entry yet.

## Plan Deviations

- **Task 3.1** altered: witness rows gained a seventh field (closure term) and the expression is rest-of-line.
- **Task 3.2** altered: witness rows are also required to be pinned, adding a fourth C2 pin (count word thirty, not twenty-nine).
- **Tasks 5.1-5.3** skipped (time box): see the plan's Phase 5 `#### Reasoned Exclusions` record.
- Phase 2's generated-surface list gained `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` (the plan listed only `README.md`).

## Verification

- Build: Success (guarded `lake build`, 2807 jobs, zero warnings for the new file; zero stale oleans before and after)
- Tests: Passed -- `check-module-invariants.sh --no-build` and full mode both `ALL CHECKS PASSED` (full 128 s; C2 thirty, C36a, C36b all five rows `true` at closure cards 6/8/3/3/3, C37 30 hits / 42 rows); `typst-sync-check.sh` PASS; `mk_all --check` 0; `--emit-inventory --check` PASS; negative tests for C36 (dropped witness row, renamed coverage-limit FQN) and C37 (unreviewed dummy def, dead anchor, dead RESIDUAL anchor) all FAIL by name and were reverted
- Files verified: Yes
- Task references: no new task-number citation outside `specs/` (repo total unchanged at 198, all pre-existing)

## Impacts

- A future certificate class without an exhibited interesting witness, or a witness row whose declaration vanishes or loses its pin, now fails the gate by name; the lasso class's coverage limits cannot be silently dropped.
- Any new `↔`-bearing definition under the certificate roots fails as unreviewed until it carries a verdict and an anchor; sibling task 705 removing `trans_refl` or the residue declarations turns the eight RESIDUAL rows into visible FAILs to re-review.
- Task 708's relay summary carries a 704-gated amendment; this task's outcome (C36/C37 landed, Tier 1 only) is now settled for it.
- Pre-existing, foreign: C5 failed mid-task on sibling 707's deployed context note; 707 corrected it in its own commits, and the final gate is clean.

## Follow-ups

- Profile why `PlusSlicedCertificate.liveT` fails to return at a 4-position, total-edge certificate (probe `03_tier2_sliced_certificates.lean`) when it is instantaneous at the self-loop embedded certificates, then land `certA`/`certB` as the Tier-2 witnesses; adjacent to the sliced finite-width question.
- Uncomment the reserved finite-carrier coverage-limit rows once `FiniteCarrier.lean` lands.
- Add `docs/theorem-index.md` entries for `liveFamily_sliced_certifies` and `liveFamily_toSharing_certifies` once 705/710 release the file.

## References

- specs/704_certificate_non_vacuity_and_shape_gates/plans/01_certificate-non-vacuity-shape-gates.md
- specs/704_certificate_non_vacuity_and_shape_gates/reports/01_certificate-non-vacuity-shape-gates.md
- specs/704_certificate_non_vacuity_and_shape_gates/probes/{01_decide_sliced_inhabitant,02_decide_conjuncts,03_tier2_sliced_certificates}.lean
- specs/704_certificate_non_vacuity_and_shape_gates/progress/phase-{1..6}-progress.json
