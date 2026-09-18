# Implementation Summary: Task #585

- **Task**: 585 - Burn down the live compiler warnings and add a warning gate
- **Status**: [COMPLETED]
- **Started**: 2026-09-17
- **Completed**: 2026-09-17
- **Effort**: ~9 hours wall, dominated by 9 all-target builds
- **Dependencies**: Task 583 (CI wiring) complete; Task 584 complete
- **Artifacts**: plans/02_warning-burndown-and-c28-gate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`lake build` exited 0 while the tree carried 348 compiler warnings across 56 files, and nothing
gated them: C16 runs Batteries' `env_linter` against *declarations* and never sees a *compiler*
warning, so the two sets are disjoint and the hole was real. This task burned **348 down to 0** and landed a
build-free ratchet — `scripts/warning-budget.py` plus a new **C28** in
`scripts/check-module-invariants.sh` — shipping **enforced** against a **zero** baseline, with
`build-args: "--wfail"` wired as the second gate.

The honest headline is **zero modulo six pre-existing undocumented suppressions**, listed below.
There are no baselined residuals: the earlier plan to tolerate 7 was abandoned once a red C16
forced the cascade to be driven to its true floor, which turned out to be zero.

## What Changed

**The gate**
- `scripts/warning-budget.py` — new. Build-free scanner over Lake's `.lake/build/lib/lean/**/*.trace`
  store. Four modes (verify / `--list` / `--update` / `--from-build`). Baseline key is
  `<count> <path> <linter>`: not a per-class scalar (which cannot catch one warning fixed and
  another introduced in the same class) and not line-qualified (so ordinary edits do not churn it).
- `scripts/warning-budget.txt` — new. Disposition table plus the baseline, now 7 entries, each
  with a recorded reason.
- `scripts/check-module-invariants.sh` — C28 block, `ENFORCE_C28` (shipped 0, now **1**), header rows.
- `docs/development/MODULE_INVARIANTS.md` — C28 row and companion-file subsection.
- `docs/development/CI_CD_PROCESS.md` — four false `--wfail` claims corrected.
- `.github/workflows/ci.yml` — `--wfail` deliberately **withheld**, with the reason in place.

**The burn-down** — 341 warnings removed across ~60 files: 71 `push_neg` → `push Not`, 4 `Std`
migrations, 54+20+20+3 unused simp arguments, 14+6 dead tactics, 102 `omit [...] in` insertions,
36 binder renames, 13 `intro` merges, 10 `def` → `theorem`, 7 further deprecations.

## Decisions

- **C28, not C26.** C26 (snake_case names + `nolint` attributes) and C27 (live debug directives)
  are both already live. Re-confirmed at implementation time.
- **`push_neg` → `push Not` is provably identity**, not merely probably: `Mathlib/Tactic/Push.lean`
  defines the deprecated tactic as the same `push … (.const ``Not) loc` plus a `logWarning`.
- **`linter.defProp` dispositioned `blocking`** after reading all 10 sites: every one is a
  Prop-valued test helper and nothing unfolds any of them definitionally.
- **Three suppressions added, each with an in-source reason** (see Verification).
- **`--wfail` withheld.** See Plan Deviations.

## Plan Deviations

- **Phase 7 is a fixpoint, not a single pass — a plan defect, found empirically.** The plan
  specifies one `omit` pass. Adding `omit [A] in` to a declaration makes instance `B` — which the
  linter could not call unused while `A` was still in scope there — provably unused in turn, so
  each pass exposes the next layer. Observed **348 → 47 → 10 → 8 → 7**, with `TruthTransfer`,
  `Lemma5` and `TaskFrame` appearing only in wave two and `NoGaps` *increasing* on one wave. Any
  future burn-down of this linter class must iterate to a fixpoint and verify convergence.
- **A stopping rule was set at wave 4 and then correctly overridden.** The rule — iterate while
  each wave strictly decreases *and* surfaces no new file — was sound for a warnings-only
  trade-off, and waves 3 and 4 failed it (`NoGaps` went up; `TruthTransfer` resurfaced), so the
  plan became "baseline 7 deliberately". That was the wrong call once **C16 turned out to be red**:
  a failing gate is not a diminishing-returns judgement. Iteration resumed and converged quickly:
  **7 → 5 → 1 → 0** over waves 5-7, each with a green all-target build.
- **The cascade's real mechanism, established late and worth recording**: it propagates through
  the **call graph**, not within a declaration. `omit [A] in X` removes `A` from `X`'s signature,
  so a caller `Y` whose only "use" of `A` was passing it to `X` becomes unused in turn. That is why
  counts could rise on a wave, why new files kept appearing, and why it nonetheless terminates —
  at declarations that genuinely use the instance. Knowing this, the right expectation for a
  burn-down of this linter class is "iterate to a fixpoint, expect non-monotonicity", not "one
  pass" and not "it has stalled".
- **`--wfail` was withheld, then restored when its stated condition was met.** At a floor of 7 it
  would have made CI permanently red *by design* — the exact property the plan uses to reject
  `--iofail` — and a measured `lake build --wfail` did exit 1 on `NoGaps`, confirming this rather
  than assuming it. It was withheld with the re-entry condition recorded in `ci.yml`: "the same
  change that takes the baseline to zero". Waves 5-7 met that condition, so it is now wired, and
  `CI_CD_PROCESS.md`'s two-gate description is true of `ci.yml` rather than aspirational.
- **The `Std` migration is not a pure rename.** `Std.Irrefl`/`Std.Trichotomous` take the carrier
  implicitly. In `BlockDecomposition.lean` bare `blockLt` then fails to pin `α` (`typeclass instance
  problem is stuck`); resolved as `Std.Irrefl (blockLt (α := α))`.
- **Plan's `(simp_all only []; done)` count is wrong**: 5 tactic sites, not 6. Line 1014 is prose.
- **Phase 10's `pending` check is unusable as written.** `grep -c 'pending' scripts/warning-budget.txt`
  can never reach 0 — the header legend must define the word. Replaced with a mechanical exit-2
  guard in the scanner; the honest textual form is `grep -c '^# disposition .* pending '`.

## Verification

- Build: all-target guarded build exits 0, zero errors.
- Sorry count: 0 (C3 green).
- Vacuous count: 0.
- Axiom count: unmoved (C2/C14 baselines green).
- Warning count: **348 → 0**. C28 enforced (`ENFORCE_C28=1`) against a zero baseline.
- C16 (`lake exe runLinter`) green: the 7 `unusedArguments` findings this task introduced are
  cleared at source, not grandfathered.
- Harness: `check-module-invariants.sh --no-build` — ALL CHECKS PASSED.
- Tests: conformance and unit suites pass as part of the all-target build.

**Every suppression this task added carries an in-source reason:**

| Location | Why |
|---|---|
| `SubformulaProperty.lean:1085`, `:1127` | `done` is reached and succeeds; it guards against `first` committing to a partial simplification. Deleting it weakens the proof silently. |
| `Singletons.lean:479` | Lean's own `omit` remedy is unwritable — the section variable is shadowed by the theorem's `{C : Formula}` binder, so it prints the inaccessible `C✝`. |
| `TimeCensus.lean` (`applyRule_emitted_time_mem`) | Deletion was tried and **failed** with `unsolved goals`: `refine … ?_ hg` leaves the goal open and `assumption` closes it. |

**Six pre-existing suppressions carry NO reason** (untouched by this task, listed for follow-up):

| Location | Linter |
|---|---|
| `…/MintBound/UntlSnceFree.lean:352` | `unusedTactic` |
| `…/Verified/Bridge/RegionFrame.lean:128` | `unusedVariables` |
| `…/Verified/Bridge/RegionFrame.lean:278` | `unusedVariables` |
| `…/Semantics/Ultraproduct/Carrier.lean:63` | `unusedSectionVars` (file-scoped) |
| `…/Semantics/Ultraproduct/Los.lean:47` | `unusedSectionVars` (file-scoped) |
| `…/Semantics/Ultraproduct/ShiftSetProduct.lean:60` | `unusedSectionVars` (file-scoped) |

### C16 regression introduced by this task

**This task turned C16 red, and that is established rather than assumed.** CI runs `lake lint`
via lean-action (`lint: true`), and CI was green on `7e4279572` at 2026-09-17T15:24, five commits
before this session. Seven ungrandfathered `unusedArguments` findings would have failed that run.
They did not exist then, and `nolints.json` has not been touched by any commit in this task.

Mechanism: the same cascade documented above, seen by a second linter. Removing tactics and simp
arguments that consumed `[IsDualClosed C]` left it genuinely unused in the elaborated signature,
which is exactly what `unusedArguments` reports. The two linters track 1:1 — C16's finding count
has equalled the residual `unusedSectionVars` count at every measurement (7 and 7, then 5 and 5)
— because they are two views of one fact. They clear together.

**`nolints.json` was deliberately NOT used to absorb this.** That file grandfathers *pre-existing*
findings; using it for a regression this task created is the same silent-baseline move the
warning-budget header forbids for `--update`, and would have defeated the purpose of the task.

## Impacts

**Hidden-count measurement (the input the blanket-suppression follow-up needs).** Commenting out
the three file-scoped `Ultraproduct/` suppressions and rebuilding all three modules — verified
*Built*, not replayed — reveals **3 warnings total: `Carrier.lean` 3 (lines 85, 267, 271); `Los.lean`
0; `ShiftSetProduct.lean` 0.** Two of the three blankets hide nothing and can simply be deleted.
All three files restored byte-identically (md5-verified, clean `git status`).

## Follow-ups

- Convert the three `Ultraproduct/` blankets (2 of 3 hide nothing — see Impacts) and give the
  other three pre-existing suppressions a reason.
- `DenseModelSurgery/` now carries ~100 `omit [...] in` lines. Narrowing the over-broad
  `variable` blocks would replace most of them with a handful of scope changes. Not required —
  the tree is at zero — but it is the tidier end state.

## References

- `specs/585_burn_down_compiler_warnings_and_add_gate/plans/02_warning-burndown-and-c28-gate.md`
- `specs/585_burn_down_compiler_warnings_and_add_gate/reports/02_warning-gate-design-remeasure.md`
- `scripts/warning-budget.txt` (the recorded reason for each residual)
