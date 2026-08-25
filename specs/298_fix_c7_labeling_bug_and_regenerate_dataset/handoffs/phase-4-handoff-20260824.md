# Phase 4 Handoff: c7 Regeneration Running — Task 298

## Immediate next action

**Poll the detached driver. Do not restart work, and do not re-run the generator.**

```bash
tail -20 specs/298_fix_c7_labeling_bug_and_regenerate_dataset/logs/driver.log
pgrep -af 'bin/dataset_generator'          # alive?
wc -l data/bmlogic-c7.jsonl                # monotonically rising
```

- **Driver alive** -> wait. Expected finish ~2026-08-25T03:00-07:00 (~9h from an 18:05:36 start).
- **`driver.log` ends in `SUCCESS:`** -> Phase 4 is done. Mark Phase 4 and the task `[COMPLETED]`.
- **`driver.log` ends in `FAIL:`** -> read the reason. The driver has already restored
  `data/bmlogic-c7.jsonl` and its `_metadata.json` from the `.bak` copies.
- **Driver gone with no terminal line** (reboot, OOM kill) -> just re-launch it; it is idempotent
  and every expensive artifact is cached:
  ```bash
  setsid nohup bash specs/298_fix_c7_labeling_bug_and_regenerate_dataset/run-c7-regen.sh &
  ```

## The bug is fixed. This is settled, not pending.

Do not re-open the diagnosis. Measured this session:

| Signal | Old failure | Now |
|---|---|---|
| Record 13,750 | hard stall, 3/3 attempts | passed at ~18:12; 124,235 records by 18:44 |
| RSS trend | +40MB/6s, unbounded | 1699-1737MB flat over 40 min, no trend |
| Exit | never terminated | c4 exited 0 at peak RSS 133MB |

Output integrity at 124,235 records: every line parses as JSON, zero duplicate ids,
labels 111,116 invalid / 9,857 timeout / 3,262 valid.

What remains is **wall-clock only**.

## Two stale baselines — do not treat either as a regression

Both are consequences of ~525 commits to `FormalSystem/` since the June run, not of this fix.

1. **c4 is 3,087 records, not 806.** Verified sound rather than assumed: 802/806 baseline formulas
   reappear (99.5%), there are **zero** valid<->invalid flips, and the timeout rate *fell*
   14.9% -> 4.2%. All 176 label changes are timeout<->decided (120 newly decided; 56 newly timing
   out, which is the priced-in cost of this fix's own adaptive-fuel reduction). The driver's
   exact-count gate was replaced with `check-c4-spotcheck.py`, which tests these properties.
2. **c7 will hold far more than 77,272 records.** The enumerator now emits **1,646,512** formulas
   at c7. The 77,272 figure in the task description is a June artifact and was surpassed at 18:33.
   Expect on the order of 1.4-1.5M records after dedup.

## Code change made this session

`FormalSystem/Automation/DatasetExport.lean` — a fourth `FrameClass` constructor (`.Dedekind`,
`FormalSystem/ProofSystem/Axioms.lean:523`) landed after the July binary was built, leaving
`frameClassName` non-exhaustive and **blocking the build entirely**. Added the missing arm using
the `"Dedekind"` spelling already used by `MachineAppendixExport.lean:121` and
`ProofStepExtractor.lean:208`, plus the symmetric `parseFrameClass` arm so `--frame-class dedekind`
no longer silently degrades to `.Base` and mislabels output. Committed as `b7bea9f62`.

No `Saturation.lean` or `DatasetGenerator.lean` edits were needed — phases 1-2 remain correct.

## The July compile blocker is gone permanently

`Formula.c` (162s) and `FormulaEnumerator.c` (384s) are compiled and cached; 751/751 link objects
are present. A full `lake build dataset_generator` is green in ~2 minutes. Do not budget hours for
this again.

## Standing caution

`earlyoom -m10 --prefer ^(lean|lake|claude|node|npm|opencode)$` runs on this host. It will kill the
generator (or the session) before any 20GB ceiling is reached, which is why the driver's RSS
watchdog is set to 12GB. At an observed ~1.7GB peak, neither bound binds — but avoid launching
other memory-heavy Lean work alongside the run.
