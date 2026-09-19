# Implementation Summary: Task #597

- **Task**: 597 - Adopt Mathlib's standard linter set, following cslib's precedent
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T11:26:09-07:00
- **Completed**: 2026-09-18T18:11:37-07:00
- **Effort**: about 6.75 hours of wall time (16 phases; 12 full all-target builds of about 20 minutes each)
- **Dependencies**: None (the compiler-warning burn-down and its C28 gate had already landed)
- **Artifacts**: plans/01_mathlib-linter-set-adoption.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lakefile.toml` now enables Mathlib's standard syntax-linter set at package level
(`weak.linter.mathlibStandardSet = true`, `weak.linter.style.longFile = 1500`). Every linter
class in the set is at zero warnings. There is one documented permanent opt-out: `hashCommand`,
for the `BimodalTest` library only. The tree builds green under `--wfail` for all targets.

The rollout was staged: each class had a temporary `weak.linter.X = false` line while its
warnings were fixed, and that line was deleted once the class reached zero. A new ratchet check,
C30, forbids blanket linter options and unscoped heartbeat budgets. No theorem statement changed
in meaning.

## What Changed

- `lakefile.toml`:
  - package-level `[leanOptions]` table enabling the set and the long-file limit;
  - `weak.linter.hashCommand = false` on `BimodalTest`, with a reason comment;
  - no `TEMPORARY` lines left.
- `scripts/warning-budget.py`: the trailer regex now accepts dotted class names such as
  `linter.style.longLine`, and the long-file trailer (which ends in `0`, not `false`) is
  classified.
- `scripts/warning-budget.txt`: a `blocking` disposition row for each of the 15 classes in the
  set.
- `scripts/check-module-invariants.sh`: new check C30, with 12 fixtures, `ENFORCE_C30=1`, a
  header entry and anti-silence guards.
- `docs/development/MODULE_INVARIANTS.md`: a row for C30.
- `docs/development/LEAN_STYLE_GUIDE.md`: a new "Lint-Suppression Policy (Mathlib's Standard
  Linter Set)" section, modelled on cslib's policy.
- `docs/development/CI_CD_PROCESS.md`: a pointer paragraph in the warning-gate section.
- About 360 Lean files under `FormalSystem/`, `Tests/` and `scripts/`, by class (warnings
  measured in the Phase 1 re-measurement):

| Class | Warnings | Fix |
|-------|----------|-----|
| docString, multiGoal, openClassical, missingEnd, cdot | 10 | Fixed at each site. |
| Blanket suppression in `Semantics/Ultraproduct/Carrier.lean` | 1 | Removed by splitting the `variable` block. |
| setOption | 7 | The 7 unscoped heartbeat budgets were replaced by per-declaration budgets, measured with `#count_heartbeats` under `Elab.async false`. `TemporalSaturation.lean` needed no budget at all. |
| maxHeartbeats | 32 | A `--` reason was added after each `in`. |
| longFile | 38 | Each long file got an in-source `set_option linter.style.longFile N` baseline. No file was split. |
| hashCommand | 241 | 230 are covered by the test-library opt-out. The 11 library `#guard` smoke tests each carry a scoped suppression with a C29 reason. |
| emptyLine | 540 | The blank lines were deleted. |
| show | 196 | Each `show` became `change`. |
| flexible | 88 (34 sites) | Replaced by `simp only` / `simp_all only` with the union lemma list, then unused arguments were pruned. |
| longLine | about 1,010 | Prose was reflowed, trailing comments were hoisted, and code was broken at safe points. Over-long markdown tables became lists. |
| unusedFintypeInType | 274 | Changed to `[Finite X]` or `omit ... in`. Where a proof still needed the instance, it got `haveI := Fintype.ofFinite X`. |
| unusedDecidableInType | 249, then +13 in a cascade | The binder was dropped or `omit`-ed. Where a proof still needed the instance, it got `haveI := Classical.decEq X`. |

## Decisions

- **Package-level placement.** The options live at package level because `[[lean_exe]]` roots
  do not inherit a library's `leanOptions`. That the library-level `hashCommand` value
  overrides the package set was settled from Lake's source (`LeanLib.leanOptions` =
  build type ++ package ++ library, and the later entry wins). The green `--wfail` build
  confirmed it.
- **Zero C28 baseline.** CI's `--wfail` rules out a non-zero baseline, so "baseline the rest"
  was read as "disposition rows at zero count".
- **Line numbers kept honest.**
  - After every line-moving phase, the long-file baselines were re-tightened, because the linter
    accepts N only when `N - 200 <= lines < N`.
  - `file.lean:NNN` citations were re-pointed with a diff-based line map (C20).
  - The README inventory blocks were regenerated.
- **`#guard` smoke tests kept.** The 11 library `#guard` smoke tests stay as `#guard`: a kernel
  `decide` would not test the compiled code, which is what they exist to test.
- **No per-declaration exemption for `unusedDecidableInType`.** The bounded fallback (a
  permanent lakefile opt-out) was never triggered.

## Plan Deviations

- **Phase 1**: altered. `longFile = 1500` was held commented out rather than paired with a
  `= 0` line, because TOML forbids a duplicate key. The library-over-package probe was settled
  from Lake's source instead of a probe build.
- **Phase 2**: altered. The two `open scoped Classical` lines were deleted outright rather than
  scoped, because neither file needs `Classical`.
- **Phase 3**: altered. Heartbeats were measured in one `#count_heartbeats` pass instead of
  remove-and-rebuild trials.
- **Phase 5**: altered. The re-measurement found 11 `hashCommand` sites in `FormalSystem`, not
  0. They got scoped, reasoned suppressions.
- **Phase 11**: altered. The phase was not split into 11.1 and 11.2: the reflow helper made the
  roughly 600-line slice one bounded pass.
- **Phase 12**: altered. No `#guard_msgs` suppression was needed; every captured long line could
  be reflowed.
- **Phase 13**: altered. No fixpoint over statements was needed, because the linter reads types
  only. The cascade happened in proofs instead and was handled per file.
- **Phase 14**: the bounded-fallback step was skipped, because it was not triggered.
- **Phase 16**: the final full harness exposed a C16 `unusedArguments` cascade: 5 definitions
  whose `DecidableEq` binder had become unused. It was fixed in Phase 16 (5 definitions, then 13
  theorems).

## Verification

- Build: Success. The all-target `lake build --wfail` (FormalSystem, BimodalTest and all 13
  exe roots) is green, via the build guard.
- Warning budget: `warning-budget.py --from-build` reports 0 warnings. C28 passes with a
  baseline of 0.
- Invariant harness: the full `check-module-invariants.sh` passes ALL CHECKS, including C1, C2
  (flagship axiom sets unchanged), C3, C16 (`runLinter FormalSystem` passes), C20, C24, C25,
  C28, C29 (17 reasoned scoped suppressions) and C30.
- Sorry count: 0 structural (C3). No sorry was introduced.
- Vacuous count: 1. It is pre-existing and unchanged from the base commit; none was introduced.
- Axiom count: unchanged (12 `axiom` lines, the same as the base commit). The C2 axiom sets match
  their baselines.
- Tests: Passed. `BimodalTest`, including every `#guard_msgs` test, builds under `--wfail`.
- Files verified: Yes. Every touched file was elaborated per file with the lakefile options
  before each full build.

## Impacts

- Any new warning from Mathlib's set now fails CI at the point it is introduced.
- Blanket linter options and file-wide heartbeat budgets can no longer land (C30).
- About 270 theorems now take `[Finite X]` instead of `[Fintype X]`, or no instance at all.
  Callers with `Fintype` in context are unaffected, because `Finite` is found through the
  instance.
- About 260 theorems and 5 definitions no longer take `[DecidableEq sig.preds]`. Callers that
  pass the instance by name, or apply these declarations with `@`, would need updating; the tree
  has none.

## Follow-ups

- None required. The unenforced C16 report on the non-FormalSystem roots reads 161 findings.
  It is not gated and lies outside this task's scope.

## References

- specs/597_adopt_mathlib_standard_linter_set/plans/01_mathlib-linter-set-adoption.md
- specs/597_adopt_mathlib_standard_linter_set/reports/01_mathlib-linter-set-survey.md
- docs/development/LEAN_STYLE_GUIDE.md (Lint-Suppression Policy section)
- docs/development/MODULE_INVARIANTS.md (C30)
