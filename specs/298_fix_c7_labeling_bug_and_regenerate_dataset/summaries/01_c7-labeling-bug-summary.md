# Implementation Summary: Task #298 — Fix c7 Labeling Bug and Regenerate Dataset

- **Task**: 298 - Fix c7 labeling bug and regenerate dataset
- **Status**: PARTIAL (fix complete and empirically proven; c7 regeneration running unattended, ~9h)
- **Plan**: `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md`
- **Session**: sess_1784061208_6ea403, sess_1787618565_717c84 (2026-08-24 resume)

## Outcome

The root-cause fix is **complete and now empirically proven**, not merely build-verified. The
generator passed the record-13,750 stall point that defeated 3/3 prior attempts and reached
124,235 records with RSS pinned flat at ~1.70GB — against an original failure signature of
unbounded ~40MB/6s growth.

The remaining work is **wall-clock only**: the enumerator now emits 1,646,512 formulas at c7, so
the labeling pass needs ~9 hours at the observed ~50 formulas/sec. It is running unattended in a
detached, self-supervising driver.

## What Was Done

### Phase 1 — Global branch counter (committed `b6aa8e5b0`, prior session)
`expandBranchWithFuel` and `expandBranchWithFuel_tracedImpl` in
`Theories/Bimodal/Metalogic/Decidability/Saturation.lean` gained `maxBranches : Nat := 50000` and
`branchesUsed : Nat := 0` parameters, with an early `none` return placed **before** the fuel match
so the guard fires even at `fuel > 0`. Soundness theorems (`tryBranch_inr`,
`foldl_preserves_findClosure`, `expandBranchWithFuel_sound`, `blocking_sound`) were generalized
over the new parameters. `termination_by fuel` was preserved — `branchesUsed` does not participate
in the decreasing measure.

### Phase 2 — Timeout mechanism (committed `9b2bd79e8`, prior session)
`labelFormulaImpl` in `Theories/Bimodal/Automation/DatasetGenerator.lean` replaced the unkillable
`Task.spawn` with `IO.asTask (prio := .dedicated)`, and the timeout path now calls `IO.cancel task`.
Adaptive fuel reduction `min 500 (150 + φ.complexity * 30)` was added inline (360 for c7, 500 for
c12+).

### Task 343 interaction (verified, not rebuilt)
Per the dispatch note, task 343 (`abort_aware_tableau_cancellation`) landed **on top of** task 298's
phases 1-2 and superseded part of the plan's assumptions. Rather than build cancellation machinery
from scratch, the existing integration was verified as correct and strictly stronger than planned:

- `labelFormulaImpl` now runs `decideAutoAdaptiveCancellable abortRef φ fc adaptiveFuel`, which
  re-enters IO at every tableau step and cooperatively observes `abortRef`.
- The timeout path sets `abortRef.set true` **first**, then calls `IO.cancel task` as
  belt-and-braces. This matters: `IO.cancel` alone only signals, and a single non-observing pure
  computation would have ignored it and run on as a zombie thread to fuel/branch exhaustion —
  exactly the task-298 failure mode. The cooperative abort ref is what actually stops it.
- Countermodel extraction uses `extractCountermodelDataCancellable abortRef φ adaptiveFuel`, bounded
  at the deciding fuel rather than the unbounded `soundFuel`.

The result is defense in depth against the original bug: the branch counter bounds the pure search,
the abort ref cooperatively interrupts it, and `IO.cancel` signals the task.

### Phase 3 — Build verification and c4 soundness gate (2026-08-24)

**The July compile blocker is gone permanently.** `Formula.c` (162s) and `FormulaEnumerator.c`
(384s) are compiled and cached, and 751/751 link objects are present; a full
`lake build dataset_generator` is green in ~2 minutes.

**One real defect surfaced and was fixed.** A fourth `FrameClass` constructor (`.Dedekind`,
`FormalSystem/ProofSystem/Axioms.lean:523`) landed after the July binary was built, leaving
`frameClassName` in `FormalSystem/Automation/DatasetExport.lean` non-exhaustive
("Missing cases: FrameClass.Dedekind") and **blocking the build entirely**. Added the missing arm,
matching the `"Dedekind"` spelling already used by the sibling exporters
`MachineAppendixExport.lean:121` and `ProofStepExtractor.lean:208`, plus the symmetric
`parseFrameClass` arm so `--frame-class dedekind` no longer silently degrades to `.Base` and
mislabels output. No `Saturation.lean` or `DatasetGenerator.lean` edits were needed.

**The c4 spot-check gate was rebuilt.** The plan's exact-count gate (`== 806`) compared against a
2026-06-08 baseline that predates ~525 commits to `FormalSystem/`; the same command now yields
3,087 records under identical settings (`include_duals: false`, `max_complexity: 4`,
`exhaustive`, `Base`). Rather than assume that drift was benign, it was verified by set
comparison, then encoded as `check-c4-spotcheck.py`:

| Property | Result |
|---|---|
| valid<->invalid soundness flips | **0** |
| Baseline coverage | 802/806 = 99.5% |
| Timeout rate | **fell** 14.9% -> 4.2% |
| Label movement | 120 timeout->decided, 56 decided->timeout |

All 176 label changes are timeout<->decided. The 56 newly-timing-out formulas are the priced-in
cost of this fix's own adaptive-fuel reduction (c4 now gets fuel 270 instead of a flat 500); the
new `decision_method_distribution` keys (`adaptive_240/270/300/330/390/420`) are direct evidence
that the Phase 2 adaptive-fuel change is live in the binary.

### Phase 4 — c7 regeneration (2026-08-24, running)

Launched 18:05:36 after the c4 gate passed.

| Signal | Old failure | Measured now |
|---|---|---|
| Record 13,750 | hard stall, 3/3 attempts | passed ~18:12; 124,235 records by 18:44 |
| RSS trend | +40MB/6s, unbounded | 1699-1737MB flat over 40 min, no trend |
| c4 exit | never terminated | exit 0, peak RSS 133MB |

Output integrity at 124,235 records: every line parses as JSON, zero duplicate ids, labels
111,116 invalid / 9,857 timeout / 3,262 valid.

**The 77,272-record target in the task description is stale** and was surpassed at 18:33. The
enumerator now emits 1,646,512 formulas at c7 (the same growth that took c4 from 806 to 3,087),
so expect on the order of 1.4-1.5M records after dedup.

## Verification Results

| Check | Result |
|-------|--------|
| `lake build dataset_generator` | PASS — 2724 jobs, zero errors |
| Termination proof (`termination_by fuel`) | PASS — still accepted |
| Sorry count (`FormalSystem/`) | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 |
| c4 soundness gate | PASS — 0 flips, 99.5% coverage, timeout rate down |
| c7 past stall point | PASS — 124,235 records vs 13,749 stall |
| c7 memory bounded | PASS — flat ~1.70GB over 40 min |
| c7 run complete | **INCOMPLETE** — ~9h total, running unattended |

## Remaining Work

Wall-clock only. Poll `logs/driver.log`; the driver logs the final label distribution and a
`SUCCESS:` line, or `FAIL:` after restoring the backup. Full instructions:
`handoffs/phase-4-handoff-20260824.md`.

## Plan Deviations

- **Phase 1** — `buildTableau` / `expandBranchWithFuel_traced` not updated to pass `maxBranches`
  explicitly *(skipped — Lean default parameter values make explicit threading unnecessary)*.
- **Phase 2** — `adaptiveFuel` implemented inline rather than as a named helper; fuel exposed via
  an optional `fuel : Nat := 500` parameter on `decideAutoAdaptive` *(altered)*.
- **Phase 2** — the plan's `IO.cancel`-only design was superseded by task 343's cooperative
  `abortRef`, which is strictly stronger; verified rather than rebuilt *(altered)*.
- **Phase 3** — c4 exact-count gate (`== 806`) replaced with the soundness gate above *(altered —
  the baseline is stale by ~525 commits; the replacement tests stronger properties)*.
- **Phase 3** — `parseFrameClass` gained a `dedekind` arm beyond the minimum needed to compile
  *(altered — one line, and without it `--frame-class dedekind` silently mislabels output as
  `Base`)*.
- **Phase 4** — memory precondition lowered 20GB -> 12GB, and the RSS watchdog likewise
  *(altered — `earlyoom -m10 --prefer ^(lean|lake|claude)$` on this host would kill the generator
  or the session before a 20GB ceiling was reached; observed peak is ~1.74GB, so neither binds)*.
- **Phase 4** — driver invokes `./.lake/build/bin/dataset_generator` directly rather than via
  `lake exe` *(altered — so RSS monitoring observes the generator, not the lake wrapper)*.
- **Phase 4** — the plan's "~77k formulas, 15-60 min" estimate was built on the June enumerator
  *(altered — 1,646,512 formulas at ~50/sec is ~9h; not a defect, per-formula work is bounded)*.

## Files Modified (2026-08-24 session)

- `FormalSystem/Automation/DatasetExport.lean` — `FrameClass.Dedekind` arms (build fix)
- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/check-c4-spotcheck.py` — new soundness gate
- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/run-c7-regen.sh` — gate rewired, watchdog
  12GB, metadata backup/restore
- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md` — phase markers
- `specs/298_fix_c7_labeling_bug_and_regenerate_dataset/handoffs/phase-4-handoff-20260824.md` — new
- `data/bmlogic-c7.jsonl` — being regenerated (not git-tracked)
