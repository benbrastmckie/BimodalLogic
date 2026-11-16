# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [BLOCKED]
- **Started**: 2026-11-16T02:50:00Z
- **Completed**: 2026-11-16T03:35:00Z
- **Effort**: 0.75 hours
- **Dependencies**: None
- **Artifacts**: plans/21_refutation-first-run-level-adequacy.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The filed `cellAt_const_of_kappa_eq` is REFUTED by a compiled object, at parameters satisfying
`ParamsOk` as defined, on the two-state fixture: `kappa`'s gap coordinate `n - c` is read past
(K4)'s clip by a `⊡`-carrying formula. `ladderRealized` falls with it. Phase 11.29's outcome is
revised from (b) to (a), Phase 11.32 is closed on its own outcome-(a) rule, and Phases 11.30/11.31
are not entered because the refutation contradicts the premise they were planned on. The task is
blocked on a route decision.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` — fourth section
  appended (977 lines, zero `sorry`, eighteen printed theorems): `thetaC`, `thetaC_not_mem`,
  `thetaC_mem`, `kappa_collision_theta`, `refutationTargetC_holds`, `not_countMoveTargetC`,
  `cellAt_const_of_kappa_eq_schema_refuted`, `no_fibre_equation_over_kappa`,
  `no_transferSys_links_collisions`, `certStabK_fails_of_contains_realized`; the unbounded family
  `mixC`, `mixC_mem`, `mixC_not_mem`, `mixC_refutes`; tools `gluePath_isPath`,
  `cnt_le_nxt_succ_of_past_idle`, `exists_upRamp`, `exists_downRamp`.
- `scripts/check-evidence-probes.sh` — the fixture's gate-table row extended.
- `docs/theorem-index.md` — verdict paragraphs rewritten: two statements REFUTED, three OPEN.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — decision docstring section
  rewritten as "The refutation of the agreement over counter classes" (docstring only).
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — one docstring sentence.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md`, `typst/generated/status.typ` — two README sentences, regenerated inventories/stamp.
- `specs/761_ladder_realization_theorem/records/round-21-refutation-verdict.md` — section "Round 4".

## Decisions

- Read the GAP, not the countdown: (K2) carries an exponential margin, (K4) carries none.
- Ran the (T-1) measurement in this implement dispatch rather than returning empty; the plan had
  no enterable phase and no revision had landed.
- Did not enter Phase 11.30: its derivation says the parameter axis is spent, and the refutation
  is a parameter-source defect that the soundness leg inherits
  (`certStabK_fails_of_contains_realized`).
- Did not promote the refutation into the library: which statement the library carries is the
  route question.

## Plan Deviations

- **Phase 11.29, "On outcome (a)"** altered: headline and schema refutation landed in the fixture
  and the verdict recorded in `LadderCell.lean`; the library-side statement in `LadderRealize.lean`
  is not landed.
- **Phase 11.32** altered: closed `[COMPLETED WITH EXCLUSIONS]` on its outcome-(a) rule after
  having run on outcome (b); its `BLOCKER` record is kept as the historical account.
- **Phases 11.30/11.31** not entered although outcome (a) is their entry condition (see Decisions).
- **Decision (T-1)**'s literal obligation (a verdict at the tight family) is not discharged; the
  tight family's gaps lie inside every clip.

## Verification

- Build: Success (full `lake build` through the guard, 2975 jobs, exit 0, 0 errors; `.olean`
  newer than source for `LadderCell` and `LadderRealize`)
- Sorry count: 0
- Vacuous count: 1 (unchanged baseline; no library declaration edited)
- Axiom count: 14 (unchanged)
- Tests: evidence gate PASS (63 wired probes); `check-module-invariants.sh` ALL CHECKS PASSED;
  `verify-deploy.sh` exit 0
- Files verified: Yes

## Refuted Filed Statements

- `cellAt_const_of_kappa_eq` — REFUTED (`cellAt_const_of_kappa_eq_schema_refuted`).
- `ladderRealized` — REFUTED as a consequence (`no_fibre_equation_over_kappa`).
- The `## Lean Challenge Statements` block is NOT edited.

## Impacts

- Every phase whose goal is the agreement or the fibre equation at the filed `ParamsOk`
  (11.6, 11.7, 11.8, 11.20, 12.2, 16) now has a false target.
- (K4) is wrong in shape, not by a constant: the separated gap exceeds the clip by `k - 1` along
  `mixC (k + 2) k`.
- Condition (5) fails on the realized set at the clip `3`, so `Real`'s certification — the planned
  route to `ladderSound` — fails at the filed parameters too.

## Follow-ups

- Route decision (returned as `user_decision`): repair (K4) and re-run the refutation attempt
  against the repaired statement, or enter the run-level pair, or both in that order.
- Not settled: whether any formula-derived clip makes the agreement true; the tight family.
- The library still carries no refutation declaration; `docs/theorem-index.md` cites the probe.

## References

- `specs/761_ladder_realization_theorem/plans/21_refutation-first-run-level-adequacy.md`
- `specs/761_ladder_realization_theorem/records/round-21-refutation-verdict.md` (section "Round 4")
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
