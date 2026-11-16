# Phase 11.34 handoff — the library-side refutation declaration: LANDED

**Status**: Phase 11.34 `[COMPLETED]` (plan v25, dispatch 73). 53 of 66 phase headings closed.

**Immediate next action**: dispatch Phase 11.41 (route (M-1), the trunk) by explicit phase number.
Nothing in this phase gates it or is gated by it.

**Current state**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (2,154 lines, in-source
  `longFile 2300`) ends with the section "The agreement on `kappa`-classes is refuted at (K4)'s
  clip": namespace `K4ClipWitness` (47 `private` declarations) and the one public theorem
  `exists_kappa_collision_cellAt_ne_at_K4_clip`.
- Axioms: `[propext, Classical.choice, Quot.sound]`. Pinned in `scripts/check-module-invariants.sh`
  (C14 baseline and probe list) and `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  (3,612 lines against `longFile 3700`; baseline not raised).
- `docs/theorem-index.md` carries a new row for it; the rows and paragraphs that asserted REFUTED AS
  FILED now name it, with the fixture as the independently-gated duplicate.
- Gates, all green after the last source edit: guarded `lake build` (2976 jobs), `build BimodalTest`
  (3044 jobs), sorry census 0, `check-module-invariants.sh` ALL CHECKS PASSED,
  `check-evidence-probes.sh` (65 probes), `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh`.

**Key decisions**:
- Route (i), by measurement (scratch file importing only `LadderRealize`, compiled first).
- Statement is the EXISTENTIAL form of the schema's negation, with the clip written out as
  `max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)` in `ParamsOk` and in both `kappa` terms.
- The witness is `private`; one public declaration is the deliverable.

**Deviations**: 47 private support declarations beside the one theorem; `longFile` raised
1800 -> 2300; three stale "OPEN" sentences outside the plan's enumerated list corrected.

**Not done, by scope**: the `dblC` strengthening stays probe-only (docstring names it). Other
REFUTED assertions in the RaySummary README about OTHER statements (twelfth/fourteenth/fifteenth
probes, the path-level splice invariance) are still backed by fixtures only.
