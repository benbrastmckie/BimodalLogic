# Implementation Summary: Task #781

- **Task**: 781 - Decide whether the Phase 5 inner-fixpoint hoist in LiveFix.lean should stay
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T12:15:31Z
- **Completed**: 2026-11-12T12:40:00Z
- **Effort**: ~25 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_phase5-hoist-keep-decision.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The verdict is **KEEP**. The gap in the existing evidence — the small embedded witness had been
A/B'd only under `#eval`, never under the kernel — is now closed: a zero-rebuild kernel A/B at
both obligation sites puts the table clause shape within a few per cent of the per-vertex shape
in both directions, far inside the pre-committed 1.15 decision band. The substantive deliverable
is not the code, which was never in doubt, but the module's recorded justification: the docstring
argued for the hoist on a counting argument that predicts a kernel win proportional to `|X|`, and
the measurement refutes that prediction. That claim is now replaced by the measured record.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — rewrote the
  `## The hoisted inner fixpoint` docstring section. No declaration was added, removed, or
  changed: the declaration set is byte-identical to the pre-edit file. The counting argument's
  claim of a net kernel win is gone, replaced by a `### What the table shape is measured to buy`
  subsection stating the kernel result (neutral, with the whnf-cache explanation), the `#eval`
  result (5.4x better at the hard certificate, ~25 % worse at the cheap witness), and a pointer
  to the evidence directory. The `Finset.image`-not-`toList` note and the per-formula
  short-circuit note are retained unchanged — both are still true and still load-bearing.
- `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean` — new: both kernel obligations under the
  library's current table clause shape.
- `specs/evidence/phase5-hoist-kernel-ab/ab-old.lean` — new: the same two obligations against a
  locally defined per-vertex mirror, built from the library's surviving `untlLiveAt`/`snceLiveAt`.
- `specs/evidence/phase5-hoist-kernel-ab/README.md` — new: raw per-run timings, medians, both
  ratios, the measurement conditions, and the Verdict section.
- `typst/generated/status.typ` — regenerated `formalsystem-line-count` (405,830 → 405,853).
- `README.md` — regenerated `dir=FormalSystem rows=totals` (comment lines 139,499 → 139,517).
- `FormalSystem/Metalogic/README.md` — regenerated the `Decidability/` row (119,271 → 119,294).

### The measurement

Ten passes per arm, arms interleaved, under one `flock` on `.lake/build-guard.lock` held to
exit, against one unchanged build. `profiler true` in both arms gives per-declaration
`type checking` (kernel) and `tactic execution` (elaboration) figures, which is what separates
the two sites inside one file.

| site | OLD median (kernel) | NEW median (kernel) | r | D1 band |
|------|--------------------:|--------------------:|--:|:-------:|
| certA backward fixpoint | 880.5 ms | 866.5 ms | **0.984** | ≤ 1.15 ✓ |
| small embedded witness | 346.0 ms | 365.0 ms | **1.055** | ≤ 1.15 ✓ |

The minimum-over-ten-passes estimator, less sensitive to the load spike in the last two passes,
gives 1.030 and 1.015 — further inside the band. No estimator applied to this data selects
REVERT. D5's fallback was not needed; both sites were measured.

## Decisions

- **KEEP, by D1 applied to complete evidence.** Both ratios are inside the band at both sites, by
  both estimators. For `r_witness` to reach 1.15 the NEW arm would have to be a further 9 %
  slower than measured; for `r_certA`, a further 17 %.
- **The certA site is the backward fixpoint, not `certA.Certifies`.** The full certificate is the
  obligation the build actually pays and would be the more decision-relevant number, but it is
  not an available A/B site: mirroring it in the OLD arm would mean re-deriving the whole
  `decidableCertifies` chain downstream of the contraction. The hoist is encapsulated inside the
  fixpoint, so the fixpoint is where the two shapes can be compared against one unchanged build.
  The original A/B made the same choice for the same reason. This is recorded in the evidence
  README with the scale figure (`certA.Certifies` ≈ 2.3 s kernel + 2.2 s elaboration today).
- **Both batches of timings are recorded, not just the favourable one.** A 3-pass pilot gave
  r_certA = 0.863 and r_witness = 0.810 — NEW apparently 14-19 % faster. The 10-pass batch does
  not reproduce that margin. Three passes is too few against a ~20 % within-arm spread, and the
  pilot is kept in the README so a future reader sees the sample-size effect rather than
  inheriting the flattering number.
- **The harness stays unwired**, per D4. `grep -c phase5-hoist scripts/check-evidence-probes.sh`
  returns 0, and the script compiles only its explicit `WIRED` list rather than globbing the
  directory, so the new files are inert to that gate by construction.
- **`maxHeartbeats 0` is set in both arms, identically.** Correct in a timing probe and nowhere
  else: a heartbeat cap converts a slow arm into a failure and destroys the measurement. The
  library's own guarded `example`s keep their finite caps, untouched.

## Plan Deviations

- **Phase 1, timing task** altered: three passes per arm were taken as the plan specifies, then a
  10-pass-per-arm batch was added under the same lock and the same build, because the 3-pass
  medians proved to lie inside the ~20 % within-arm spread. This adds samples to the planned
  measurement rather than substituting a different one; both batches are recorded.
- **Phase 3, REVERT branch** not applicable: Phase 2 recorded KEEP, so the branch the plan gates
  on a REVERT verdict was correctly not taken.
- **Phase 4, gate-set task** altered: discharged against a scoped tier per this dispatch's Batch
  Gate Deferral directive, under its UNMAPPABLE CRITERION branch. See `## Verification`.

## Verification

- Build: Success — full guarded `lake build`, exit 0, 2975 jobs, 0 errors, 0 warnings. Scoped
  builds of `...PlusSlicedCertificate.LiveFix`, `...Bridge` and `...PlusSlicedCertificate` all
  exit 0, warning-free. `LiveFix.olean` is newer than `LiveFix.lean`.
- Sorry count: 0
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`,
  `int_domain_universal ... := trivial`. Pre-existing and identical at the pre-task commit
  `e2c2662e0`; a file this record never touched, and an honest proof rather than a placeholder
  (`intTimeHistory.domain t` genuinely reduces to `True` at `Int`).
- Axiom count: 14 — identical at the pre-task commit. Not increased.
- Tests: `bash scripts/check-module-invariants.sh` — 55 checks PASS, 0 FAIL, `ALL CHECKS PASSED`.
- Files verified: Yes. `scripts/check-module-invariants.sh --emit-inventory --check` exits 0;
  `scripts/typst-sync-check.sh --counts-only` exits 0 (`MISMATCH_COUNT=0`);
  `check-task-references.sh` and `check-record-versioning.sh` both exit 0 on each of the four
  touched deliverables.

### Scoped gate discharge

This dispatch carried a Batch Gate Deferral directive. The complete gate set was NOT independently
run here; it runs once for the whole batch at the end of the invocation, and its result is
attributed back by `modified_files`. The full gate is deferred, not forgiven.

The phase criterion naming `verify-deploy.sh` is this directive's UNMAPPABLE CRITERION case:
every `verify-deploy.sh` gate compares a deployed `.claude/` tree against its source store, and
this record touched no path under `.claude/` or `agent-system/`. No `--only-gate` number reaches
a `FormalSystem/**.lean` edit, and `run-all.sh`'s suites exercise the agent system's own shell
scripts, not this library. It was discharged by running the repository checks that do cover these
files directly, enumerated in the `## Verification` list above.

The deployed `.claude/` tree is reported STALE for the `core` extension. That staleness is what
`verify-deploy.sh` measures, it predates this record, no file touched here can affect it, and it
belongs to the redeploy record. Noted, not acted on.

## Impacts

- A future reader of `LiveFix.lean` no longer inherits a counting argument the kernel refutes.
  The module now states what was measured, where it was measured, and what the kernel's whnf
  cache does to the argument's premise.
- The decision is durable and reproducible next to the code: both arms compile standalone under
  `lake env lean`, so the A/B can be re-run against any later tree.
- No consumer is affected. The Tab family has zero references outside `LiveFix.lean` (confirmed:
  all 27 are in that one file), and the declaration set is unchanged, so nothing downstream moved.

## Follow-ups

- The absolute cost at the certA site has fallen roughly thirtyfold since the original A/B
  (25.9 s → 0.88 s per arm) through intervening work that is not the hoist. Anyone comparing the
  two records must read the ratio, not the seconds. This is recorded in the evidence README and
  in the issue log.
- `certA.Certifies` — the obligation the build actually pays — remains un-A/B'd, and is not
  A/B-able without re-deriving the `decidableCertifies` chain in the OLD arm. If that ever
  becomes cheap, it is the better site.
- The deployed `.claude/` tree is stale for `core`; a redeploy belongs to its own record.

## References

- `specs/781_phase5_hoist_kernel_neutral_decision/plans/01_phase5-hoist-keep-decision.md`
- `specs/evidence/phase5-hoist-kernel-ab/README.md` — raw timings, medians, ratios, verdict
- `specs/evidence/phase5-hoist-kernel-ab/ab-old.lean`, `.../ab-new.lean` — the two arms
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — the corrected record
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Examples.lean` — the two kernel
  obligations the A/B mirrors
