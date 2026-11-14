# Implementation Summary: Task #929

- **Task**: 929 - Discharge the `I = 1` idle-run sub-regime so `ForwardSlackWitnessed` becomes unconditional
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T18:30:00Z
- **Completed**: 2026-11-13T19:12:00Z
- **Effort**: ~6 hours across 4 dispatched phases
- **Dependencies**: None blocking. Territory-concurrent with task 930 (no declared file scope).
- **Artifacts**: plans/01_idle-run-one-forward-slack.md, reports/01_idle-run-one-forward-slack.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task's stated goal is REFUTED rather than dischargeable, and the refutation is compiled, not
argued — the outcome the task description explicitly admits as equally reportable provided it is
compiled. On a two-state object with no idle self-loop (hence with every idle run of length
exactly `1` on every ladder path), `ForwardSlackWitnessed` is FALSE at amount `4` at a state that
genuinely inhabits the pending-forever regime. This is the first cell-level refutation of
`ForwardSlackWitnessed` in the development. Its reach is bounded, and the bound is itself
compiled: the five depth-`0` cell-equality schemas of `LadderCell.lean` instantiate the
hypothesis at an amount where the ceiling driving the refutation is satisfied for free, so all
five keep `ForwardSlackWitnessed` for a positive reason rather than through not having been
edited.

## What Changed

- `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean` — Created. The promoted
  refutation probe, wired into the CI probe guard as a tracked `WIRED` entry.
- `scripts/check-evidence-probes.sh` — Added the probe's `WIRED` entry and documentation-table row.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` — Added `section IOne`
  (namespace `IdleRunOne`), sixteen transcribed declarations. Headline:
  `forwardSlackWitnessed_refuted_I_one` (`ForwardSlackWitnessed` false at amount `4` at
  `xState = (true, 2, 0)` on `stepOr x y = x || y`); `xState_regime` (the refuted state inhabits
  the pending-forever gap, by a concrete path, so the refutation is non-vacuous);
  `ceiling_slack_at_consumer_amount` (the ceiling `l ≤ n + cntAt + I` is satisfied for free at
  the consumer amount `m · (P + 1)` on the higher state whenever `0 < I` — the compiled bound on
  the refutation's reach); `not_idleRunPumpable` (`IdleRunPumpable` unsatisfiable on that object,
  so the refutation and the conditional discharge cannot collide);
  `forwardSlackWitnessed_holds_below_ceiling` (the boundary is sharp — the same state carries
  every amount `l ≤ 3 = n + c + 1`). Module docstring restated. 1,342 → 1,358 lines.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — Two docstring sites
  restated (module docstring; `exists_deleted_ladderPath_of_next_region_nxt`). No signature,
  declaration, or proof changed. 2,956 → 2,984 lines; declared
  `set_option linter.style.longFile 3000` unchanged and still accepted.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` — Frontier bullet corrected. 292 → 303 lines.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — Inventory block regenerated; the
  `LadderIdle.lean` row's hand-written description written from a `<!-- TODO: add description -->`
  placeholder; a two-paragraph frontier correction inserted; the antitone open-question paragraph
  sharpened.
- `README.md`, `FormalSystem/Metalogic/README.md` — Inventory blocks regenerated.
- `typst/generated/status.typ` — Regenerated (Phase 3).
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — NOT edited; byte-unchanged.

## Decisions

- The refutation is stated at exactly its reach and no further. Every site that states it cites
  `ceiling_slack_at_consumer_amount` in the same breath, so the limit on what it closes is a
  compiled fact at each site rather than a prose caveat that can drift.
- `LadderCell.lean` left untouched and `certStabK`'s restatement obligation left PROVISIONAL.
  The compiled result supports neither change.
- The library transcription uses `namespace IdleRunOne` rather than the probe's own `Probe929`,
  since `specs/**` is exempt from the no-task-references rule and `FormalSystem/` is not.
- `RaySummary.lean`'s `LadderIdle` bullet asserted the module states no cell-level consequence —
  false once the conditional discharge landed and `LadderWindow` began importing it. Corrected
  in the same edit rather than left to carry a false claim alongside the refutation.
- Two pre-existing gate reds were enumerated rather than fixed; both name files outside this
  plan's scope.

## Plan Deviations

- **Phase 4** altered: `typst-sync-check.sh --fix` was a no-op (Phase 3 had already settled
  `status.typ`), so `typst/generated/status.typ` is not in Phase 4's modified-file list despite
  appearing in its "Files to modify".
- **Phase 4** altered: the Scope Hypothesis predicted four inventory blocks would move; three
  did. `FormalSystem/README.md`'s block is `rows=loose`, over files directly under
  `FormalSystem/`, none of which this plan touched. No block outside the predicted list changed.
- **Phase 4** altered: `check-paper-definitions.sh` was expected to report `SKIP (neutral)`
  because "the paper's repository is not visible here". It is visible on this machine, so the
  gate runs and exits `1`. Recorded as a pre-existing, out-of-scope red.
- **Phase 4** altered: `lake exe lint-style` exits `1` on 4 pre-existing style errors outside
  this plan's scope. Enumerated, not fixed.
- **Phase 4** altered: the dispatch's Batch Gate Deferral directive was answered under its
  unmappable-criterion clause — all eleven criteria were run directly rather than through a
  narrowing invocation, because both narrowings reach agent-system surfaces only.
- **Phase 3** altered: one sentence of `section IOne`'s own docstring was rephrased because it
  quoted superseded wording that would have failed the phase's own grep criterion. No claim
  changed.

## Verification

- Build: Success — full guarded `lake build`, `GUARD_EXIT=0`, 2975/2975 jobs, 0 `error:`,
  0 `warning:` (CI `--wfail` parity). `lake test` 3042/3042, exit 0. `.olean` newer than source
  for every module this task touched.
- Sorry count: 0
- Vacuous count: 0 introduced (one pre-existing grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is a genuine theorem whose goal reduces to
  `True`)
- Axiom count: 14, identical to the task-start baseline at `ac7b058f6` — not increased
- Tests: Passed
- Files verified: Yes

Gate set, each run directly:

| Gate | Result |
|---|---|
| `lake build` (guarded, full) | PASS, 0 error / 0 warning |
| `lake test` | PASS |
| `check-evidence-probes.sh` | PASS, 59 wired probes |
| `check-module-invariants.sh --no-build` | PASS |
| `check-module-invariants.sh --emit-inventory --check` | PASS (idempotent after the hand edit) |
| `check-copyright-headers.sh --strict` | PASS, 756/756 conforming |
| `readme-lint.sh` | PASS |
| `check-metalogic-cycles.sh` | PASS (Assertion B asserts equality, so this confirms the no-new-import hypothesis) |
| `typst-sync-check.sh` | PASS, all 4 checks |
| `lake exe mk_all --lib FormalSystem --check` | PASS, "No update necessary" |
| `check-task-references.sh` | PASS, 0 unexempted occurrences |
| `check-paper-definitions.sh` | RED, pre-existing and out of scope — 9 drifted anchors in an external `.tex` repository, all LaTeX list/spacing formatting |
| `lake exe lint-style` | RED, pre-existing and out of scope — 4 space-before-semicolon errors at `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:383,390,413,420`, zero occurrences of that file in this task's commit range |

Plan invariants re-checked at completion: `LadderCell.lean` byte-unchanged since `ac7b058f6`;
`cellLE_zero_const_of_kappa_eq` claimed by zero declarations anywhere in the tree; `certStabK`
still worded PROVISIONAL; no `(K1)` amendment and zero new `spanning` constraints on added lines;
zero task-number references and zero record-versioning phrases introduced outside `specs/**`.

## Impacts

- The `I = 1` sub-regime is settled negatively at the every-amount shape, by a compiled object
  rather than by argument, so no later effort need re-attempt a pumping route there.
- The refutation's bound is available as a reusable compiled fact
  (`ceiling_slack_at_consumer_amount`), so any future consumer of `ForwardSlackWitnessed` can
  check whether the ceiling bites at its own instantiation instead of reasoning about it.
- `RaySummary/README.md`'s `LadderIdle.lean` row carried a stale line count and a literal
  description placeholder since before this task; both are now closed, and the module's
  conditional discharge has a README surface it did not previously have anywhere.
- The depth-`0` cell-equality programme is unchanged: five schemas, same signatures, same
  hypotheses, and task 761's Phase 11.6 gate untouched.

## Follow-ups

- Route 4 at the cell level — simultaneous multi-region shortening — is the surviving frontier,
  recorded in `section IOne`'s docstring and in `RaySummary/README.md` and not attempted here.
  It carries three enumerated, undischarged obligations in the research report.
- The two pre-existing gate reds remain: `lint-style` on `NormalForm.lean` (4 style errors, a
  mechanical `--fix` away) and `check-paper-definitions.sh` drift against the external paper
  working tree (9 anchors, formatting only). Neither belongs to this task.
- `certStabK`'s restatement obligation stays PROVISIONAL. Lifting it needs a result this work
  does not supply.

## References

- `specs/929_idle_run_length_one_forward_slack_discharge/plans/01_idle-run-one-forward-slack.md`
- `specs/929_idle_run_length_one_forward_slack_discharge/reports/01_idle-run-one-forward-slack.md`
- `specs/929_idle_run_length_one_forward_slack_discharge/handoffs/phase-4-handoff-20261113-191056.md`
- `specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` (`section IOne`)
