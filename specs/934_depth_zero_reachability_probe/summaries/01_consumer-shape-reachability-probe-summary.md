# Implementation Summary: Task #934

- **Task**: 934 - Depth-0 reachability probe: is `ForwardSlackWitnessed` satisfiable at the consumer instantiation
- **Status**: [COMPLETED]
- **Started**: 2026-11-14T09:32:00Z
- **Completed**: 2026-11-14T09:50:00Z
- **Effort**: ~20 minutes (plan estimate 2.5 hours; the probe was already compiled by research)
- **Dependencies**: None
- **Artifacts**: plans/01_consumer-shape-reachability-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research-compiled consumer-shape witness was promoted into the tracked evidence collection,
wired into the CI probe guard with its documentation-table row, and the written verdict below was
recorded. No file under `FormalSystem/**` and not `specs/ROADMAP.md` was edited; the Stage 0 gate
ruling is not taken.

## Verdict

1. **The question.** `specs/ROADMAP.md` Stage 0 states the depth-0 gate's crux as whether a
   `ForwardSlackWitnessed` hypothesis at a POSITIVE amount is satisfiable at any state the
   depth-0 induction one layer up reaches, and records it as "claimed in neither direction".
   The five depth-0 cell-equality schemas use the hypothesis at exactly one shape: the higher
   state `(q, c + m*(P+1), n)` at amount `m*(P+1)`.
2. **The compiled answer: satisfiable.** In
   `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`, on the object
   `stepOr x y = x || y` at `φ = ⊥`:
   - `fsw_consumer_shape`: the hypothesis holds at `(true, c + m*(P+1), 0)` at amount `m*(P+1)`
     for every `c`, `m`, `P`;
   - `plateau_next_region`: the witness path has a genuine next region at idle-run length `1`,
     so the slack premise is inhabited (not met vacuously);
   - `consumer_fires`: at `Tcof/Tnof/Pof/Bof` (so `ParamsOk` by `paramsOk_params`),
     `c := Tc + B + 2`, `m := 1`, the pending-forever regime (`0 + 2 ≤ c`, `Tc ≤ c`), the
     `kappa` collision and the hypothesis at the positive amount `P + 1` hold together, and
     `cellLE_zero_const_of_kappa_eq_of_forwardSlack` is applied to give the cell equality;
   - `climbC_isLadderPath`, `climbC_not_hasForwardSlack`: a second ladder path through the same
     state has no forward slack at any positive amount, so the existential over paths is doing
     real work (the per-path form fails where the cell-level form holds).
3. **Which lifting event it supports.** `cellLE_zero_const_of_kappa_eq` landing as a
   sorryAx-free theorem — AS EXISTENCE EVIDENCE ONLY. It does not bring that event about.
4. **What it does not do.** It is NOT a general discharge of `ForwardSlackWitnessed`: the cell
   at `φ = ⊥` is the singleton `{∅}`, so one path witnesses every type. It does not refute
   `CellLEZeroConstOfKappaEq` under `ParamsOk`. The reserved name
   `cellLE_zero_const_of_kappa_eq` is claimed by nothing. All five depth-0 schemas still carry
   the hypothesis, and `certStabK`'s restatement obligation is unchanged.
5. **The failure direction is ARGUED, NOT COMPILED.** Research found no non-ceiling failure
   mechanism and no concrete refuting object; that is an argument in the report, not a compiled
   result. A failure of the hypothesis at this shape would in any case not by itself refute the
   schema: the upward cell inclusion is unconditional, so a refutation needs a type in the
   higher cell that is absent from the lower one.
6. **The Stage 0 ruling is NOT taken.** The roadmap's "claimed in neither direction" wording is
   left as it stands, for the user or a `/roadmap` pass to revise.
7. **Candidate follow-up, named but not filed.** A multi-type-cell instance (a formula whose
   cell holds several types). It is equivalent to route 4 at the cell level (simultaneous
   multi-region shortening) on that instance.

## What Changed

- `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean` — Created (git rename
  of the task-local draft): proofs verbatim, namespace `Probe934` renamed `ProbeConsumerShape`
  at its three sites, module docstring added (what it establishes, two reading aids, what it does
  NOT establish, verdict).
- `scripts/check-evidence-probes.sh` — one `WIRED` entry
  `"forward-slack-pin-cascade/consumer-shape-witness"` after `idle-run-one-ceiling`, plus its
  documentation-table row.
- `specs/934_depth_zero_reachability_probe/probe-draft/consumer-shape-witness.lean` — removed.
- `specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md` —
  forward pointer to the promoted path on the `**Artifacts**` line.

## Decisions

- Positive direction only; no attempt to compile a non-ceiling failure.
- The three verdict carriers (probe docstring, script table row, this summary) were checked to
  agree: none says the gate is decided, none claims a discharge, none claims the reserved name.

## Plan Deviations

- **Phase 1, module docstring item** altered: the docstring verdict says "a theorem resting on no
  placeholder axiom" where the plan's wording was "sorryAx-free", because the same phase's
  verification requires `grep -c 'sorry\|native_decide\|Probe934'` on the probe to return `0`.
- **Phase 1, wiring item** altered: the pre-edit wired total (61) was read from the
  `WIRED`/`WIRED_REPO` array lengths at the pre-task commit (the script's own `wired_total`
  computation) instead of a second full pre-edit guard run. The post-edit run is a real run.

## Verification

- Probe compile (`lake-build-guard.sh build --timeout 500 -- env lean <probe>`): exit 0, no
  `sorry` warning; `#print axioms` — `fsw_consumer_shape`, `consumer_fires`,
  `climbC_isLadderPath`: `[propext, Classical.choice, Quot.sound]`; `plateau_next_region`,
  `climbC_not_hasForwardSlack`: `[propext, Quot.sound]`.
- `bash scripts/check-evidence-probes.sh`: `PASS  all 62 wired probe(s) compile` (61 before).
- Probe is tracked (`git ls-files --error-unmatch` exit 0); promoted file differs from the draft
  only by the namespace rename and 70 added docstring lines (0 removed lines).
- Build: Success — full `lake build` through the guard, twice (phase-1 end and final):
  `Build completed successfully (2975 jobs)`, exit 0, 0 `error:` lines. No module in any Lake
  source root was touched by this task.
- Sorry count: 0
- Vacuous count: 0 introduced. The repo-wide grep has one hit, pre-existing in an untouched file
  (`FormalSystem/Examples/TemporalStructures.lean:495`, a genuine statement proved by `trivial`).
- Axiom count: 14 `^axiom ` lines, unchanged (no source-root file differs from `c55b78740`).
- Plan compliance check: skipped (plan declares zero Lean goals by design).
- Tests: `lake test` exit 0.
- Gate set, as deltas against `c55b78740`:
  - PASS: `verify-deploy.sh` (15 checks, 0 failures), `check-module-invariants.sh --no-build`,
    `--emit-inventory --check`, `check-copyright-headers.sh --strict`, `readme-lint.sh`,
    `check-metalogic-cycles.sh`, `typst-sync-check.sh` (4 checks), `lake exe mk_all --lib
    FormalSystem --check`.
  - RED, pre-existing, outside this task's files: `lake exe lint-style` (4 errors, all
    `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:383,390,413,420`, "space
    before a semicolon"; file last changed 2026-11-06); `check-paper-definitions.sh` (drift
    against `docs/reference/paper-definitions-of-record.md`). Neither names a file this task
    touched; neither was repaired.
- Out-of-scope constraints: `git diff c55b78740 -- FormalSystem/ specs/ROADMAP.md` is empty.
- Files verified: Yes

## Impacts

- The probe is recompiled on every CI run, so the existence evidence cannot rot silently.
- The crux as the roadmap states it now has compiled evidence on the satisfiable side; the
  roadmap text itself is unchanged and awaits the user's ruling.

## Follow-ups

- The Stage 0 gate ruling and any rewording of the roadmap's crux line (user / `/roadmap`).
- Optional: a multi-type-cell consumer-shape instance (not filed).
- Pre-existing reds `lint-style` and `check-paper-definitions.sh` belong to other work.

## References

- specs/934_depth_zero_reachability_probe/plans/01_consumer-shape-reachability-probe.md
- specs/934_depth_zero_reachability_probe/reports/01_consumer-shape-reachability-probe.md
- specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean
- specs/evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean
- scripts/check-evidence-probes.sh
