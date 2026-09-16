# Implementation Summary: Task #581

- **Task**: 581 - Repair the four wired bi-lasso evidence probes so `check-evidence-probes.sh` exits 0, then wire it into CI
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T09:08:46-07:00
- **Completed**: 2026-09-16T09:12:18-07:00
- **Effort**: ~35 minutes
- **Dependencies**: None
- **Artifacts**: plans/02_repair-probes-wire-ci.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All four wired bi-lasso evidence probes compile again under the current `TemporalOrder`/`FrameOver`
API. Every obstruction still holds, and no theorem was deleted or weakened. The guard's
stale DEFERRED comment is corrected, and `scripts/check-evidence-probes.sh` now runs as a gating
CI step that fails when a probe stops compiling.

## What Changed

- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`: carrier `ℤ` -> `intOrder`; `.toTaskFrame.WorldState/TaskRel` -> fibre-level `WorldState`/`TaskRel`; `TaskFrame.step` -> `FrameOver.step`; `IsStepPath` over `.toFrameOver`
- `specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean`: `univ2_all` states `IsStepPath univ2.toFibre f`; `hist` built via `FrameOver.HFofStepPath univ2.toFibre`
- `specs/evidence/bi-lasso-decision-layer/phase3-scan-bound-is-false.lean`: `tau : ConvexHistory …` (rename of `WorldHistory`); `ℤ`-ascribed binders and `show … by omega` inside the proofs of `truth_prev`, `plan_scan_bound_fails` and `no_formula_independent_scan_bound`
- `specs/evidence/bi-lasso-decision-layer/phase10-origin-anchoring-obstruction.lean`: `spikePath_isStepPath` over `toFibre`; `spikeHF` via `FrameOver.HFofStepPath`; `ConvexHistory` in the `truth_prev` and `Phase10Target` binders
- `scripts/check-evidence-probes.sh`: DEFERRED comment only. It now says the spike no longer compiles (`FrameClass.Discrete` and `TaskFrame.trivialFrame` are gone) and must be repaired under the no-weakening rule before it is wired. The `DEFERRED` array and all logic are unchanged
- `.github/workflows/ci.yml`: added one step, `check-evidence-probes.sh`, after "Compile lean_exe roots (outside the library closures)" and before "Report results". It uses `set -euo pipefail` and `::group::` and has no `continue-on-error`

### Statement-change justification (all API-tracking, no content change)

- **phase7**: `refinedFilteredTaskRel` is still `if d = 0 then w = u else True`, so the one-step relation is still universal. `↑intOrder` is `ℤ` by `rfl`. `FrameOver.step` is the same definition as the old `TaskFrame.step`, now defined on the fibre. The fibre spelling is required: `simp` cannot unfold through the total-space `toTaskFrame` wrapper. The obstruction holds.
- **phase12**: `IsStepPath` moved to the fibre (`toTaskFrame := toFibre.toTaskFrame`). `hist`'s type, `Sat` and `no_compositional_imp` are unchanged. The obstruction holds.
- **phase3**: the only statement-level edit is the `WorldHistory` -> `ConvexHistory` rename. The other edits are proof-internal `ℤ` ascriptions, because `omega` does not see through durations typed `↑intOrder`. The four theorem statements are byte-identical. The obstruction holds.
- **phase10**: `toFibre` and `FrameOver.HFofStepPath` follow the step-path API's new location. `spikeHF`'s type is unchanged. `WorldHistory` -> `ConvexHistory` is a rename. `origin_past_periodic`, `truth_prev5_spike`, `type_at_origin_never_recurs` and `typeAt_origin_never_recurs` are byte-identical in statement and proof. The load-bearing anchoring obstruction holds.

No obstruction failed, so no design decision needs revisiting.

## Decisions

- Applied report 02's verified diffs verbatim with one `git apply`. They applied cleanly, because the probes were unchanged since commit e3f328841.
- The CI step gates (a rotted probe fails CI) and does not just report. The rationale is recorded in the step's comment: a probe that no longer compiles no longer protects the decision it records.
- Named the step after the script, following the pattern in the research. When this step landed, no CI naming convention from the parallel CI-wiring work had been added to `ci.yml` or `docs/development/CI_CD_PROCESS.md`.

## Plan Deviations

- **Phase 1** altered: applied all four diffs in one `git apply` and checked them together with the guard, instead of running `lake env lean` on each file.
- **Phase 3** altered: for the broken-probe test, extracted the step's `run` block verbatim from the parsed YAML and ran it with `bash -e`. The break changed `rfl` to `trivial` in phase12's `hist_path`.
- **Phase 3** skipped: did not run a full `lake build`. No `FormalSystem/` commit landed during implementation, and no Lean library file was touched. The only `FormalSystem/` changes were uncommitted edits by other agents running at the same time, and the guard had already compiled against them.

## Verification

- Build: the guard (`lake env lean` on each probe) exits 0 with 4 PASS and 1 SKIP. A full `lake build` was not run, which the plan allows because no library file changed.
- Sorry count: 0 (no `sorry` in any repaired probe; the only matches are in docstrings)
- Vacuous count: 0
- Axiom count: 0 new `axiom` declarations. Scratch-copy `#print axioms` audit of every named result: phase7's three probes (the `example`s restated as theorems), all nine phase12 theorems, seven phase3 theorems and eight phase10 theorems each depend on exactly `[propext, Classical.choice, Quot.sound]`. No `sorryAx` appears.
- Tests:
  - Broken-probe test: running the CI step's `run` block locally exited 1, and the FAIL line named `phase12-check-not-compositional`.
  - Restored-probe test: after restoring the probe with Edit, `git diff --quiet` passed (byte-identical) and the step exited 0.
  - `ci.yml` parses as YAML. The step order is Checkout, lean-action, lean_exe roots, check-evidence-probes.sh, Report results.
- Spike check: `lake env lean` on `spike-untl-unfolding-and-fwd-obstruction.lean` exits 1 with 25 errors (22 `FrameClass.Discrete` and 1 `TaskFrame.trivialFrame`). The spike stays in DEFERRED and unwired.
- Files verified: Yes

## Impacts

- CI now catches evidence-probe rot. An API change that breaks a probe turns the build red instead of silently removing the obstruction the probe records.

## Follow-ups

- **Your check**: agents may not push, so a CI run on GitHub with a deliberately broken probe has not been observed. To confirm the step goes red there, push a branch that breaks one probe.
- The DEFERRED spike needs repair (under the no-weakening rule) once the frame-class uniformity work lands, before it is wired.
- phase12 still has an `unnecessarySeqFocus` linter warning on line 59. It was already there, is not drift, and does not affect the exit status.

## References

- specs/581_repair_bilasso_evidence_probes/plans/02_repair-probes-wire-ci.md
- specs/581_repair_bilasso_evidence_probes/reports/02_probe-repair-verified-diffs.md
- specs/581_repair_bilasso_evidence_probes/reports/01_bilasso-probe-frameclass-drift.md
- specs/reviews/review-2026-09-16.md (Finding C1)
