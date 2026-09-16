# Implementation Plan: Task #581

- **Task**: 581 - Repair the four wired bi-lasso evidence probes so `check-evidence-probes.sh` exits 0, then wire it into CI
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None (583 is concurrently planning the CI wiring pattern; see Risks)
- **Research Inputs**: specs/581_repair_bilasso_evidence_probes/reports/02_probe-repair-verified-diffs.md (primary), specs/581_repair_bilasso_evidence_probes/reports/01_bilasso-probe-frameclass-drift.md (sweep evidence)
- **Artifacts**: plans/02_repair-probes-wire-ci.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

All four wired probes under `specs/evidence/bi-lasso-decision-layer/` fail to compile after the
`TemporalOrder`/`FrameOver` refactor. Research report 02 drafted and machine-verified (`lake env
lean`, zero `sorry`, axioms exactly `[propext, Classical.choice, Quot.sound]`) a repair for each,
showing every obstruction still holds and every statement change is API-tracking only. This plan
applies those verified diffs, corrects one now-false sentence in the guard's DEFERRED comment,
then wires `scripts/check-evidence-probes.sh` into `.github/workflows/ci.yml` as a gating step.
Done means: guard exits 0 (4 PASS, 1 SKIP), no `sorryAx` in any repaired probe's axioms, and a CI
step that fails when a probe rots.

### Research Integration

Report 02 supplies (a) an API map of four drift causes plus one proof-internal cause:
`FiniteFilteredTaskFrame ℤ` -> `intOrder`; `TaskFrame.step` -> `FrameOver.step`; `IsStepPath` /
`HFofStepPath` relocated to the fibre (`toFibre`, `toFrameOver`); `WorldHistory` -> `ConvexHistory`;
and `omega` not seeing through `↑intOrder`-typed durations (fixed by ascribing binders at `ℤ`);
(b) exact, compiled diffs for all four probes, to apply verbatim; (c) a statement-by-statement
API-tracking justification; (d) the CI step shape, placement (after "Compile lean_exe roots",
before "Report results"), and the fail-not-report decision; (e) the side finding that the DEFERRED
spike no longer compiles (25 errors), so the guard's "It compiles today" comment is false.
Report 01's guess that phase3's `omega` failures were downstream of line 90 was measured wrong;
the report 02 diff already handles them.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted (no roadmap flag); this is repository-hygiene work guarding design decisions of the
bi-lasso decision layer.

## Goals & Non-Goals

**Goals**:
- The four wired probes compile under the current API with their obstructions intact.
- The evidence-probe guard exits 0 locally, reporting 4 PASS and 1 SKIP.
- The guard runs as a gating CI step, with the fail-not-report decision recorded in its comment.
- The guard's DEFERRED comment states the spike's actual (non-compiling) status.

**Non-Goals**:
- Deleting, weakening, or re-stating the content of any probe theorem.
- Repairing or wiring the DEFERRED spike probe (stays DEFERRED and unwired).
- Fixing phase12's pre-existing `unnecessarySeqFocus` linter warning (not drift; does not affect exit status).
- Rewording phase3's "The total world history" docstring (paper terminology; harmless).
- Writing the repository-wide CI wiring-pattern document (owned by 583).
- Adding `#print axioms` lines into the tracked probe files (audit is done from scratch copies).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| API drifts again between research and implementation (other agents active) | M | L | Re-run the guard right after applying diffs; if a hunk fails, re-derive from report 02's API map rather than editing statements |
| A diff hunk no longer applies textually (probe edited since research) | L | L | Probes last changed in commit e3f328841, before research; confirm `git log` on the directory before applying; apply hunks by hand with Edit if context shifted |
| 583 edits `ci.yml` concurrently, causing conflict or a differently-named step convention | M | M | Re-read `ci.yml` immediately before editing; if 583 has landed a wiring-pattern doc or new steps, follow its naming and place this step after any 583 steps that follow the lean_exe step; stage only the one hunk |
| Remote CI red-run cannot be demonstrated (agents may not push; no `act`/`actionlint`) | L | H | Local broken-probe test proves the step's command exits nonzero under `set -euo pipefail`; YAML-parse the workflow; record the remote red run as a user-side check in the summary |
| Broken-probe test leaves a probe corrupted | M | L | Make the break a single-token edit, revert it with Edit (not `git checkout`), then confirm `git diff --quiet` on that file and guard exit 0 |
| An obstruction turns out not to hold on re-verification | H | L | Stop; do not weaken the statement. Record explicitly in the summary that the obstruction no longer holds and that the decision it held in place needs revisiting |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Apply verified Lean repairs to the four wired probes [COMPLETED]

**Goal**: Make all four wired probes compile under the current API with statements unchanged in
content, and confirm axiom hygiene.

**Tasks**:
- [x] Confirm the probe files are unchanged since research (`git log --oneline -1 -- specs/evidence/bi-lasso-decision-layer/`)
- [x] Apply report 02's phase7 diff (`intOrder` carrier, fibre-level `WorldState`/`TaskRel`, `FrameOver.step` in `simp` sets); `lake env lean` the file, expect exit 0 *(deviation: altered — all four diffs applied in one `git apply` of report 02's diff block, then verified together via the guard rather than per-file `lake env lean`)*
- [x] Apply report 02's phase12 diff (`univ2_all` over `univ2.toFibre`; `hist` via `FrameOver.HFofStepPath`); `lake env lean`, expect exit 0 (one pre-existing linter warning is acceptable)
- [x] Apply report 02's phase3 diff (`tau : ConvexHistory`; `ℤ`-ascribed binders and `show … by omega` in `truth_prev`, the `-5 < 0` witness, and the `-1 < k` witness); `lake env lean`, expect exit 0
- [x] Apply report 02's phase10 diff (`spikePath_isStepPath` over `toFibre`; `spikeHF` via `FrameOver.HFofStepPath`; `ConvexHistory` in `truth_prev` and `Phase10Target`); `lake env lean`, expect exit 0
- [x] Axiom audit from scratch copies in the session scratchpad (never in the tracked files): append `#print axioms` for every named theorem in each probe; for phase7's anonymous `example`s, restate them as named theorems in the scratch copy. Every result must be a subset of `[propext, Classical.choice, Quot.sound]`, with no `sorryAx`
- [x] Grep each repaired probe for `sorry` (expect none)
- [x] Run `bash scripts/check-evidence-probes.sh`; expect exit 0 with 4 PASS, 1 SKIP
- [x] Record, for the summary, the per-probe statement-change justification (report 02's "Does each obstruction still hold?" list, confirmed against the applied diff)

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep (one commit per probe once it compiles, or one commit after the guard is green)

**Scope Hypothesis**: 4 files, ~25 changed lines, ~30 compile errors cleared, 5 drift causes (per report 02). Confirm by `git diff --stat` on the evidence directory after the phase and by the guard's PASS count; any error not covered by report 02's API map is out-of-hypothesis and must be re-derived and justified individually.

**Files to modify**:
- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` - carrier and fibre-level API spelling
- `specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean` - step-path API relocated to fibre
- `specs/evidence/bi-lasso-decision-layer/phase3-scan-bound-is-false.lean` - `ConvexHistory` rename; `ℤ` ascriptions inside proofs
- `specs/evidence/bi-lasso-decision-layer/phase10-origin-anchoring-obstruction.lean` - fibre step-path API; `ConvexHistory` rename

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0, output shows 4 PASS and 1 SKIP
- Scratch axiom audit shows no `sorryAx` for any probe result
- Every statement-level hunk in `git diff` maps to a row of report 02's API map (no content change)

---

### Phase 2: Correct the guard's stale DEFERRED comment [COMPLETED]

**Goal**: Make the guard's DEFERRED comment factually accurate about the spike probe, without
wiring it.

**Tasks**:
- [x] Confirm the spike still fails: `lake env lean specs/evidence/bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction.lean` (expect nonzero exit; report 02 measured 25 errors citing removed `FrameClass.Discrete` and `TaskFrame.trivialFrame`)
- [x] Replace "It compiles today, but" in the DEFERRED comment block of `scripts/check-evidence-probes.sh` with an accurate statement: it no longer compiles against the current frame-class API, and when the frame-class uniformity work lands it must be repaired (under the same no-weakening rule) before it is wired
- [x] Leave the `DEFERRED=(...)` array and all script logic unchanged
- [x] Confirm no task-number reference was introduced (deliverable file outside `specs/`)

**Timing**: 10 minutes

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `scripts/check-evidence-probes.sh` - DEFERRED comment text only

**Verification**:
- `git diff scripts/check-evidence-probes.sh` touches only `#` comment lines
- `bash -n scripts/check-evidence-probes.sh` succeeds
- Guard still reports the spike as SKIP (checked as part of Phase 3's final run)

---

### Phase 3: Wire the guard into CI as a gating step [COMPLETED]

**Goal**: Run `check-evidence-probes.sh` in CI after the Lake cache is warm, failing the build when
any wired probe rots.

**Tasks**:
- [x] Re-read `.github/workflows/ci.yml`; check whether 583 has landed new steps or a wiring-pattern document (e.g. under `docs/development/` or `CI_CD_PROCESS.md`). If so, follow its step-naming convention; otherwise name the step after the script
- [x] Insert a step after "Compile lean_exe roots (outside the library closures)" (and after any 583-added steps in that region), before "Report results", following report 02's suggested shape: `set -euo pipefail`, `::group::`/`::endgroup::`, `bash scripts/check-evidence-probes.sh`, no `continue-on-error`
- [x] Precede the step with a comment recording: probes live under `specs/` outside every Lake root, so the build never elaborates them; they rotted undetected once; the decision is that a rotted probe FAILS CI, because a probe that no longer compiles no longer protects the decision it records; the step reuses the lean-action cache (all probe imports are in the `FormalSystem` import closure). No task-number references
- [x] YAML-parse the workflow: `python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/ci.yml"))'`
- [x] Broken-probe test: introduce a single-token type error into one wired probe, run the step's exact command sequence locally under `bash -c 'set -euo pipefail; …'`, confirm nonzero exit and a FAIL line naming the probe; *(deviation: altered — the `run` block was extracted verbatim from the parsed YAML and executed with `bash -e`; break was `rfl` -> `trivial` in phase12 `hist_path`)* revert the token with Edit; confirm `git diff --quiet` on that probe and guard exit 0
- [x] Final gate: `bash scripts/check-evidence-probes.sh` exits 0 with 4 PASS, 1 SKIP; `lake build` is not required (no Lean library file touched), but re-run it if any file under `FormalSystem/` changed on the branch during implementation *(deviation: skipped — no `FormalSystem/` commit landed during implementation; the only `FormalSystem/` changes are other concurrent agents' uncommitted working-tree edits, which the guard already compiled against)*
- [x] Note in the summary that the remote red run on a deliberately broken probe is a user-side check (agents may not push)

**Timing**: 30 minutes

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `.github/workflows/ci.yml` - one new gating step with explanatory comment

**Verification**:
- Workflow YAML parses
- Local broken-probe run exits nonzero; restored run exits 0
- `git diff .github/workflows/ci.yml` adds exactly one step, placed after the lean_exe compile step and before "Report results"

## Lean Challenge Statements

None. This plan introduces no new theorem or definition. The probes' named theorems depend on
file-local definitions (`univ2`, `chainPresentation`, `freePresentation`, `tau`, `L`) and cannot be
stated standalone; their statements are pinned instead by the requirement that every
statement-level diff hunk be one of report 02's API-tracking rewrites. The identifier set named
under **Goals** is correspondingly empty.

## Testing & Validation

- [x] `bash scripts/check-evidence-probes.sh` exits 0 with 4 PASS, 1 SKIP
- [x] No repaired probe's `#print axioms` (scratch audit) contains `sorryAx`; each is within `[propext, Classical.choice, Quot.sound]`
- [x] Every changed theorem statement is justified as API-tracking in the summary (phase7, phase12, phase3, phase10)
- [x] `spike-untl-unfolding-and-fwd-obstruction` remains in `DEFERRED` and unwired
- [x] `.github/workflows/ci.yml` parses and contains the gating step in the specified position
- [x] Deliberately broken probe makes the step's command exit nonzero locally; restored probe is byte-identical to the committed repair
- [x] No task-number references in `scripts/check-evidence-probes.sh`, `ci.yml`, or the probe files

## Artifacts & Outputs

- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` (repaired)
- `specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean` (repaired)
- `specs/evidence/bi-lasso-decision-layer/phase3-scan-bound-is-false.lean` (repaired)
- `specs/evidence/bi-lasso-decision-layer/phase10-origin-anchoring-obstruction.lean` (repaired)
- `scripts/check-evidence-probes.sh` (DEFERRED comment corrected)
- `.github/workflows/ci.yml` (new gating step)
- `specs/581_repair_bilasso_evidence_probes/summaries/02_repair-probes-wire-ci-summary.md`

## Rollback/Contingency

Each phase is committed separately and touches disjoint files, so any phase can be reverted with
`git revert` of its commit. If a probe cannot be repaired without changing a statement's content,
do not weaken it: leave that probe failing, mark Phase 1 `[PARTIAL]`, state in the summary which
obstruction no longer holds and which design decision it held in place needs revisiting, and skip
Phase 3 (a gating step on a red guard would break CI).
