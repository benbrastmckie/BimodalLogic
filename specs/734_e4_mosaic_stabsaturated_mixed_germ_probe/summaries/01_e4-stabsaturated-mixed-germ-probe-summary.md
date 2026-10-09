# Implementation Summary: Task #734

- **Task**: 734 - Run experiment E4: decide StabSaturated on the Bool fixture's mosaic set, and acquire the Hodkinson-Reynolds Handbook sections
- **Status**: [BLOCKED]
- **Started**: 2026-10-09T08:35:45Z
- **Completed**: 2026-10-09T08:45:13Z
- **Effort**: 0.2 hours
- **Dependencies**: 733 (completed)
- **Artifacts**: plans/01_e4-stabsaturated-mixed-germ-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All four plan phases completed: the E4 probe is landed, headed, wired into the evidence gate, and the Handbook residual gap is recorded in the literature sub-index. The task rests `[PARTIAL]` by the recorded user decision (cycle 4, 2026-10-09): the acceptance clause's acquisition half (Handbook ch. 11 sections 5.10-5.11 present in the Literature index) stays a residual gap with its reactivation condition. That resting state is the acceptance clause's own prescribed outcome ("either half landing without the other is a [PARTIAL]"), not a shortfall of this dispatch; the status marker above reflects the one external blocker.

## What Changed

- `specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` -- Created new file (namespace `Probe734Mosaic`, 35 declarations, no sorry). Proves `stabSaturated_univ` (the landed `Probe718Mosaic.StabSaturated` is identically true on every finite mosaic set, mixed or not), `Smix_mixed` / `Smix_stabSaturated` (a genuinely mixed set where the same-state corner hypothesis fails and the predicate still holds), the witness-direction predicate `StabWitnessedAt` (SH1) with `Smix_witnessed` (holds on `{stayA, jumpB, stayB}`) and `Sdrop_not_witnessed` (fails on `{jumpB, stayB}`), `Sdrop_mixed`, and the E2 fixture transcription (`Rg`/`Fg`/`Mg`, `stayA`/`stayB`/`jumpB`, `not_stabFp_jumpB`, `succ_of_b`, `stabFp_stayB`). Header states the verdict VACUOUS, that it decides nothing about R2, that the review's falsifier is unsatisfiable, the witness-direction result, R2's standing, the Handbook residual gap, the hard constraints, and the measured axiom record.
- `scripts/check-evidence-probes.sh` -- one `WIRED` entry (`seam-gluing-ray-product/mosaic-stab-saturated`, 24th), one comment-table row, and the Probe 718 row's final clause amended by pointer ("attacked by name and found VACUOUS by the mosaic-stab-saturated entry below").
- `specs/literature-index.json` -- `hodkinson_2006.hazard` extended with the 2026-10-09 re-measurement (preview still 3 pages, byte-identical; DOI paywalled), the user decision, the two sections R2 needs, the in-corpus stand-ins, and "Reactivation condition unchanged".
- `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/prototype/mosaic-stab-saturated.proto.lean` -- the research scratch, committed as provenance.

## Decisions

- Verdict recorded as VACUOUS, in those words, in both the header and the gate row, so `stabSaturated_univ` is never read as support for R2; R2 neither promoted nor closed, its hypothesis restated as a syntactic saturated-set existence theorem with a bespoke `⊡`-fibre interaction condition (Caleiro 2013 section 4.3).
- `mosaic-germ-amalgamation.lean` left byte-identical (no-weakening rule); only its gate-table comment row was amended, by pointer.
- The finite-width refutation is cited by its real library name `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` rather than the task description's `Probe710.` shorthand.
- The five prototype docstrings prefixed `CLAIM n:` were neutralized (docstring-only); proofs byte-identical to the prototype.
- Phases executed 1, 3, 2, 4 (cheapest-closure-first; Phase 3 had no dependencies and the smaller estimate).
- No acquisition attempted (recorded user decision); no summary from memory ingested.

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: Success (`lake-build-guard.sh build` exit 0, `Build completed successfully (2837 jobs)`, 0 `error:` lines; no module under the Lake build graph was touched by this task, so the per-module `.olean` check is vacuous)
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved roots; the probe itself: 0)
- Vacuous count: 1 -- pre-existing and out of scope: `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`, present identically at HEAD before this task; a legitimate `trivial` proof of a definitionally-true domain predicate matched by the single-line grep). Introduced by this task: 0.
- Axiom count: 15 (unchanged from HEAD before this task's commits)
- Evidence gate: `bash scripts/check-evidence-probes.sh` exit 0, `PASS all 27 wired probe(s) compile` (baseline 26 + 1), PASS line for `seam-gluing-ray-product/mosaic-stab-saturated`
- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean` rc=0, 0 errors/warnings, exactly four axiom lines at `[propext, Classical.choice, Quot.sound]`, identical to the header's axiom record
- Deploy gate set: `verify-deploy.sh` PASS, 14 checks, 0 failures
- Sub-index: `jq empty` passes; one `hodkinson_2006` entry; diff exactly one line pair
- Tests: N/A (no test library change)
- Files verified: Yes

## Impacts

- R2's load-bearing hypothesis is now on record as vacuous as filed; any future re-ranking of R2 must rest on a syntactic saturated-set existence theorem and on the Handbook sections once acquired.
- The evidence gate holds the verdict in place (27 wired probes).
- No change to `FormalSystem`, no new axioms, no certificate class, no complexity claim.

## Follow-ups

- Acquisition half (external blocker): when institutional access, purchase, or an open release of Handbook ch. 11 pp. 708-712 becomes available, ingest sections 5.10-5.11 via `/literature`, update `hodkinson_2006`, and re-open this task for completion. Recorded in `issues.jsonl` (class `external dependency`, resolution `open`).
- Optional, outside this task's `file_scope`: a README note under `FormalSystem/Metalogic/Decidability/` pointing at the vacuity finding (the report's context-extension recommendation).

## References

- Plan: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/plans/01_e4-stabsaturated-mixed-germ-probe.md`
- Report: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md`
- Decision: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/.decisions.json`
- Continuation handoff: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/handoffs/phase-4-handoff-20261009T084436Z.md`
- Phase handoffs: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/handoffs/`
- Issue log: `specs/734_e4_mosaic_stabsaturated_mixed_germ_probe/issues.jsonl`
