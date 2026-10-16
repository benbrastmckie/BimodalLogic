# Implementation Summary: Task #808

- **Task**: 808 - Fix the C16 env_linter failure: unused `[Finite F.WorldState]` on `FrameOver.mem_HF_iff_no_forbidden`
- **Status**: [COMPLETED]
- **Started**: 2026-10-16T14:31:37-07:00
- **Completed**: 2026-10-16T14:53:00-07:00
- **Effort**: ~0.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_drop-unused-finite-binder.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`scripts/check-module-invariants.sh` exited 1 on exactly one group, C16, because
`lake exe runLinter FormalSystem` reported one unused argument beyond the baseline in
`scripts/nolints.json`: argument 3 of `FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden`,
the instance binder `[Finite F.WorldState]`. The binder was deleted from the signature and the
declaration's docstring was restated to describe the module's current design. The binder proved
not to be load-bearing at any call site, so `scripts/nolints.json` is untouched and the
plan's conditional baseline-entry branch was not taken.

## What Changed

- `FormalSystem/Semantics/ShiftFiniteType.lean` — `mem_HF_iff_no_forbidden` now reads
  `theorem mem_HF_iff_no_forbidden (F : FrameOver intOrder) [F.IsRegular] (f : ℤ → F.WorldState)`,
  character for character the plan's `## Lean Challenge Statements` signature. The four-line
  proof body, `finite_forbiddenBlocks`, `instDecidableForbidden`, and `Forbidden` are untouched.
  Two doc-comment restatements: the declaration docstring now states that the identification is
  stated at any carrier and that the finite-carrier hypothesis sits on `finite_forbiddenBlocks`;
  the module docstring's *Saturation* section names `finite_forbiddenBlocks` explicitly where it
  previously said only "below" (verified by `grep -n Finite` that it is the module's only
  declaration carrying `[Finite F.WorldState]`).
- `typst/generated/status.typ` — regenerated (`formalsystem-line-count` 362642 -> 362643, stamp
  commit). Not planned; forced by the repo's pre-commit `typst-sync-check.sh` Check 2 gate.
- `README.md` — generated inventory block regenerated (live comment lines 124,017 -> 124,018).
  Not planned; forced by `check-module-invariants.sh`'s `FAIL INV` group.

## Decisions

- Dropped the binder rather than adding a `scripts/nolints.json` entry: `lean_references` at the
  declaration found no term-level application, and the full `lake build` plus
  `lake build BimodalTest` confirmed no unification-dependent consumer exists.
- `lake exe runLinter --update` was never run, per the dispatch's explicit prohibition; no
  in-source `@[nolint unusedArguments]` attribute was added (C26 still PASS with its 7
  pre-existing attribute pairs).
- The two generated-metadata files were repaired with each gate's own printed remedy
  (`typst-sync-check.sh --fix`, `check-module-invariants.sh --emit-inventory`) rather than
  bypassed with `git commit --no-verify`, since this task's own edit caused the drift.

## Plan Deviations

- **Phase 2** altered: committing the docstring restatement required also regenerating
  `typst/generated/status.typ`, a file outside the phase's `Files to modify` set. The net +1 line
  in `FormalSystem/` drifted `formalsystem-line-count` and the pre-commit gate blocked the commit
  until the generated file was refreshed. Applying the fix also required running Phase 3's full
  `lake build` ahead of Phase 2's commit, since `--fix` is build-requiring.
- **Phase 3** altered: the same +1 line left `README.md`'s generated inventory block stale, which
  the gate reports as its own `FAIL INV` group. `README.md` was regenerated, so the phase's
  "no modified file outside this plan's Files to modify sets" criterion is met only modulo these
  two generated files. The plan's `git diff -- scripts/nolints.json` empty criterion holds
  exactly.
- **Phase 4** not taken; closed `[COMPLETED WITH EXCLUSIONS]` with a Reasoned Exclusions record.
- Minor evidence corrections: `lean_references` returned `total: 2`, not research's `total: 1`
  (the extra hit is the `#print axioms` command at
  `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:178`, which applies no
  instance arguments); and the linter's green verdict prints
  `-- Linting passed for FormalSystem.` rather than a `-- Found 0 errors` line.

## Verification

- Build: Success — full `lake build` exit 0 (2872 jobs, zero `error:` lines);
  `lake build BimodalTest` exit 0 (2936 jobs, zero `error:` lines), with the pinned
  `#print axioms` / `#guard_msgs` axiom-profile block at
  `Tests/BimodalTest/Metalogic/EffectivePeriodicExtensionAxiomTest.lean:173-178` rebuilt green
  and unedited. Scoped builds of `FormalSystem.Semantics.ShiftFiniteType` and
  `FormalSystem.Semantics.ShiftFiniteTypeDictionary` exit 0. Every build was detached via
  `Bash(run_in_background: true)` through `lake-build-guard.sh`, and each verdict was read from
  the guard's own `STATUS: exit_status=` line and captured exit code, never a pipe status.
- Linter: `lake exe runLinter FormalSystem` exit 0, `-- Linting passed for FormalSystem.`
  (before the edit: exit 1, one `unusedArguments` finding).
- Gate: `bash scripts/check-module-invariants.sh` exit 0, `ALL CHECKS PASSED`, zero `FAIL`
  lines. In particular `C16 PASS` (env_linter batch has no un-nolisted finding), both
  `C1 lake build` groups PASS, `C3 PASS` (structural sorry inventory ZERO across `FormalSystem/`
  and `BimodalTools/`), `INV PASS`, and `C26 PASS` with its 7 pre-existing in-source `nolint`
  attribute pairs unchanged. The gate's first run exited 1 on a single `FAIL INV` group
  (`README.md` stale generated inventory), which the regeneration below resolved; `C16` was
  already `PASS` in that first run.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots, empty inventory)
- Vacuous count: 0 introduced by this task. The single-line heuristic grep has exactly one
  repository-wide hit, `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal ... := trivial`), which is pre-existing, unrelated to this task, and a
  genuine proof whose goal reduces to `True` rather than a placeholder.
- Axiom count: 14 `^axiom ` declarations across the resolved source roots, unchanged; this task's
  diff adds zero `axiom` lines.
- `git diff -- scripts/nolints.json`: empty. No `@[nolint]` attribute added anywhere.
- Tests: N/A beyond `lake build BimodalTest` above.
- Files verified: Yes

## Impacts

- `FrameOver.mem_HF_iff_no_forbidden` is now available at a strictly weaker hypothesis set: any
  carrier, finite or not. Downstream consumers gain the identification without a finiteness
  obligation; `finite_forbiddenBlocks` remains the sole bearer of `[Finite F.WorldState]` in the
  module, which is the split the module docstring says the two-theorem structure exists to keep.
- The repository's aggregate invariant gate is green again, so the next task's gate set no longer
  starts from a red C16.

## Follow-ups

- Plan-authoring lesson worth capturing: any net line-count change under `FormalSystem/` drags
  `typst/generated/status.typ` and `README.md`'s generated inventory block with it. A plan whose
  `Files to modify` set omits those two generated files cannot land such an edit without a
  recorded deviation.

## References

- `specs/808_c16_unused_finite_instance_shiftfinitetype/plans/01_drop-unused-finite-binder.md`
- `specs/808_c16_unused_finite_instance_shiftfinitetype/reports/01_c16-unused-finite-instance.md`
- `specs/808_c16_unused_finite_instance_shiftfinitetype/handoffs/`
