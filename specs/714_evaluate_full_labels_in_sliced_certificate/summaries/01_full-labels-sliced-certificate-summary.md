# Implementation Summary: Task #714

- **Task**: 714 - Evaluate full labels in the sliced certificate
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T11:44:21Z
- **Completed**: 2026-11-12T12:15:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_full-labels-sliced-certificate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research round had already refuted option 3 -- carrying full labels in the sliced certificate
-- so there was no certificate-class refactor to perform. This implementation made that refutation
durable and landed its one positive by-product: the three embedded-route equalities became library
regression theorems, the refutation probe was promoted out of the task directory into the tracked
evidence collection and wired into the probe gate, and `Position.lean`'s header now states what the
`posAt` over-approximation buys. The landed two-filter design (`TailStable`/`TailStableMirror`,
`fwdLiveAt`/`bwdLiveAt`) is byte-for-byte unchanged.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` -- new
  `WitnessFamily.FullLabelRegression` namespace after `end BotTargets`: `posAtFull` (the full-label
  position space, stated locally so no consumer of `posAt` is touched) plus the regression triple
  `botSnce_posAtFull_eq_liveAt`, `botUntl_posAtFull_eq_liveAt` and `liveFamily_posAtFull_eq_liveAt`,
  each proved `by decide` under its own finite `maxRecDepth`/`maxHeartbeats` envelope. File is now
  1610 lines, below its `linter.style.longFile 1700` baseline.
- `specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean` -- the promoted probe
  (`git mv` from the task directory), with the collection's Apache-2.0 header and an evidence-probe
  module docstring stating the decision it holds in place. Parts A, B and E kept verbatim; Parts C
  and D's theorems replaced by a pointer paragraph naming the library declarations, their `#eval`
  readouts retained.
- `scripts/check-evidence-probes.sh` -- one documentation-table row and one `WIRED` entry, so the
  probe is gate-compiled on every CI run and survives this task's archival.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` -- one new
  module-docstring section recording what the over-approximation buys. Docstring-only; no
  declaration, signature or proof in that file changed.
- `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md` -- regenerated
  coupled count surfaces.
- `specs/714_evaluate_full_labels_in_sliced_certificate/reports/01_full-labels-sliced-certificate.md`
  -- one-line pointer to the probe's new path.

## Decisions

- `LabCoherent` is written qualified as `PlusSlicedCertificate.LabCoherent` at the library site
  rather than opening that namespace inside `WitnessFamily`. This is a qualification-only
  adjustment; the four Challenge statements are implemented exactly as recorded.
- The probe's `#print axioms` and `#eval` lines stayed in the evidence probe and were not carried
  into `FormalSystem/`, which C27 gates.
- The documentation-table row was appended immediately above `WIRED=(` and the array entry at the
  array's end, matching the table's own trailing entry so the two orders stay aligned.

## Plan Deviations

- **Phase 1** altered: each `set_option maxHeartbeats 2000000 in` prefix also needed an adjacent
  `--` justification comment to satisfy Mathlib's `linter.style.maxHeartbeats`, which the plan
  scheduled C30 for but did not anticipate. Written in `Examples.lean`'s existing house style;
  the rebuild is warning-free. Annotated inline on the plan's own checklist item.

## Verification

- Build: Success -- full guarded `lake build`, 2975 jobs, exit 0, zero `error:` lines, `.olean`
  newer than source for both touched modules. Run at the end of every phase, not only at the end.
- Sorry count: 0
- Vacuous count: 0 attributable to this task (the single repo-wide grep hit,
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, predates this task and
  is a genuine proof)
- Axiom count: 14, unchanged; all three new theorems report
  `[propext, Classical.choice, Quot.sound]` under `lean_verify`
- Tests: the repository's complete gate set ran directly (see below); 7 of 10 gates exit 0 and the
  other 3 are recorded PASS under the plan's baseline-delta rule, with every finding enumerated and
  none naming a file this task touched
- Files verified: Yes

### Gate set and baseline deltas

This dispatch carried a Batch Gate Deferral directive. Neither narrowing invocation it names can
express this phase's criteria -- `run-all.sh` covers the agent system's own shell suites and this
task touches no `.claude/**` path, and the plan already rules `verify-deploy.sh` inapplicable for
the same reason -- so the UNMAPPABLE CRITERION clause applied and each named check ran directly.
The complete set still runs once for the whole batch at the end of the invocation.

Exit 0: `lake build` (full), `check-module-invariants.sh --no-build`,
`check-copyright-headers.sh --strict`, `readme-lint.sh`, `check-metalogic-cycles.sh`,
`typst-sync-check.sh`, `lake exe mk_all --lib FormalSystem --check`.

Red on a standing baseline, none naming a file this task touched:

- `check-evidence-probes.sh` exits 1. The new probe reports PASS. The single failure is
  `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean`,
  moved into the gitignored `specs/archive/` by commit `cf3e481fb` -- exactly the archival-move
  failure that gate's own header documents, and exactly what Phase 2 of this task existed to
  prevent for this probe.
- `check-paper-definitions.sh` exits 1 on 9 definitions drifted against an out-of-repo LaTeX
  source.
- `lake exe lint-style` exits 1 on 4 space-before-semicolon errors, all in
  `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean`, whose last change is an
  ancestor of this task's first commit.

### Build-cost delta

`EmbedComplete.lean` builds in 5.9s without the `FullLabelRegression` block and 7.0s with it:
+1.1s, roughly 19%, measured by a temporary removal and restore with a byte-for-byte restore
check. The risk table's build-cost entry is discharged.

## Impacts

- The claim "the embedding produces no junk positions" is now re-checked on every build rather than
  living only in a task-directory probe, and the option-3 refutation survives this task's archival
  because the probe is tracked under `specs/evidence/` and compiled by the probe gate.
- `Position.lean`'s header now carries the positive argument for the `posAt` over-approximation, so
  the next reader who proposes collapsing it to one label per state meets the `⊡`-comparison-class
  answer in the file itself.

## Follow-ups

- The `⊇` superset failure at `Fixture.cert` is untouched and survives full labels independently;
  its repair remains re-presenting the frame by absorbing the pre-period into `mid`.
- Option 4 (full labels plus an explicit state-sharing relation over a quotient frame carrier) was
  held out of scope by the plan and remains unopened; it should only be opened against a stated
  benefit the two-filter design does not already give.
- Three baseline gate failures above are open and belong to other owners, not to this task.

## References

- `specs/714_evaluate_full_labels_in_sliced_certificate/plans/01_full-labels-sliced-certificate.md`
- `specs/714_evaluate_full_labels_in_sliced_certificate/reports/01_full-labels-sliced-certificate.md`
- `specs/evidence/stability-modal-substrate/full-labels-collapse-stab.lean`
- `specs/714_evaluate_full_labels_in_sliced_certificate/handoffs/`
