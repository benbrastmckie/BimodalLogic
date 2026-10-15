# Implementation Summary: Task #796

- **Task**: 796 - Prove lem:time-reflection for BL and the semantic form of thm:TR-valid by instantiating the generic anti-isomorphism transport at the reflected model
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T08:40:00Z
- **Completed**: 2026-10-15T10:05:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None blocking
- **Artifacts**: plans/01_time-reflection-bl-tr-valid.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Both paper anchors were already reachable from pieces the repository held in two places that had
never been connected: the generic order-reversing transport `Truth.truthAt_of_truthAntiIso` in
`Semantics/TruthTransport.lean`, and the frame-reversal machinery in
`OpenLanguage/OpenReversal.lean`, which sat *above* it in the import graph and was therefore
invisible to it. This task did the layering move that lets the former see the latter, instantiated
the transport at the reflected model to get `lem:time-reflection` for the base language, and
derived `thm:TR-valid` at every frame class plus the two validity predicates no `FrameClass` tag
denotes. Eleven new declarations, sorry-free, with the reversal story promoted out of
`OpenLanguage/` into `Semantics/`.

## What Changed

- `FormalSystem/Semantics/TaskFrame.lean` — received the promoted converse-frame block in a new
  `section ConverseFrame`: `FrameOver.rev`, `instance FrameOver.rev_isRegular` (all four
  `def:frame` constraints), `FrameOver.rev_taskRel`, `FrameOver.rev_taskRel_neg`,
  `FrameOver.rev_rev`, `@[reducible] def TaskFrame.rev`, `TaskFrame.rev_rev`. `longFile` ceiling
  2900 -> 3000 with its justification comment extended; file is 2981 lines.
- `FormalSystem/Semantics/Reversal.lean` — **new module**, sole import
  `FormalSystem.Semantics.TruthTransport`, G-15 `assert_not_exists` guard verbatim. Nine
  declarations: `TaskModel.rev`, `TaskModel.rev_rev`, `WorldHistory.rev`,
  `@[simp] WorldHistory.rev_state`, `WorldHistory.rev_rev_hist`, `WorldHistory.rev_surjective`
  (moved), plus `revHistEquiv`, `revAntiIso` and `truthAt_rev` (new). **`truthAt_rev` is
  `lem:time-reflection` for BL.**
- `FormalSystem/Semantics/FrameClassValidity.lean` — `FrameClass.Sat.rev`: every frame class is
  closed under reversal, which is what lets `validIn_reflectTime` carry no closure hypothesis.
- `FormalSystem/Semantics/Validity.lean` — `import FormalSystem.Semantics.Reversal` plus seven
  declarations: `validOn_rev_iff`, `validOnFrames_reflectTime` (the primitive carrying the
  closure argument), `validIn_reflectTime`, `validIn_reflectTime_iff`, `valid_reflectTime`,
  `validComplete_reflectTime`, `validQTime_reflectTime`. **This family is `thm:TR-valid`.**
- `FormalSystem/Metalogic/Soundness.lean` — decision-(3) docstrings only; no statement or proof
  changed.
- `FormalSystem/OpenLanguage/OpenReversal.lean`, `FormalSystem/OpenLanguage.lean`,
  `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/OpenLanguage/README.md`, `FormalSystem.lean` — reconciled dependents,
  registration, and the stale promotion records.
- `docs/reference/paper-definitions-of-record.md`, `scripts/lean-citation-manifest.json`,
  `typst/generated/status.typ`, four regenerated README inventory blocks — gate reconciliation
  (see Decisions).

## Decisions

- **Decision (3): `derivable_valid_and_reflect_time_validIn` is left as is, with a
  cross-reference docstring.** Both halves of the collapse were verified available —
  `validIn_reflectTime (axiom_validIn_min ax)` alone proves `axiom_reflect_time_validIn_min`, and
  that one-liner recompiles — so this is a judgment call with the facts in hand. Not collapsed
  because: `soundness_validIn` is *defined* as `.1` of this theorem, so a real collapse needs a
  new single-valued `derivable_validIn` recursion with a fresh height-termination proof plus a
  rewiring of `soundness_in`, `soundness_validIn` and `Independence/CoarsenedModels.lean`; three
  sibling language layers document themselves as mirroring this recursion arm for arm; and the
  two routes are independent derivations of the same reflection validities, worth keeping as a
  cross-check. Recorded in the declaration's own docstring, with a back-reference on
  `axiom_reflect_time_validIn_min`.
- **Decision (4): the promotion is possible and was done, in three pieces** — frame level to
  `Semantics/TaskFrame.lean`, model/history/transport to the new `Semantics/Reversal.lean`,
  validity level into `Semantics/Validity.lean` and `Semantics/FrameClassValidity.lean`. **No
  import cycle**: `Reversal.lean` imports only `TruthTransport.lean`, which `Validity.lean`
  already imported. Splitting the validity level off is what keeps `Reversal.lean`
  G-15-guard-clean.
- `validIn_reflectTime` takes **no** closure hypothesis: all four `FrameClass` tags are closed
  under `rev` because `F.rev.Duration` is `F.Duration` by `rfl`. `validOnFrames_reflectTime` is
  the primitive carrying the closure argument, which is what reaches `ValidComplete` and
  `ValidQTime`.
- `revAntiIso.atom` is proved by `change` + `rw [neg_neg]`, **not** `rfl` (the dispatch's
  suggested `rfl` is wrong: the goal sits at `t` on one side and `- -t` on the other).
- `WorldHistory.rev`'s `respects_task` obligation closes by `rwa [neg_sub_neg] at this`, not
  `abel`, which is unavailable at that import level.

## Plan Deviations

- **Phase 1 idempotency check altered**: the `FrameOver.rev` block was *not* already present
  (task 617 had not landed its Phase A), so the insert ran rather than being skipped.
- **Phase 4 siting altered**: the plan said to site the whole block after `ValidIn.mono`.
  `validComplete_reflectTime` and `validQTime_reflectTime` had to go after the `ValidQTime`
  definition instead, because `ValidComplete`/`ValidQTime` are declared *below* `ValidIn.mono`
  and cannot be referenced above their own definitions. The pinned Challenge statements are
  unchanged.
- **Phase 5/6 scope altered — three gate collisions, each recorded in `issues.jsonl`**:
  1. The pre-commit `typst-sync-check.sh --counts-only` hook blocks *every* phase commit until
     `typst/generated/status.typ` is regenerated, since any `.lean` edit shifts the repo line
     count. The plan sited that regeneration in Phase 6 only. Regenerated per phase commit
     instead, at the cost of one full `lake build` per phase. Precedent: task 793's phase 1/3/5
     commits did the same.
  2. `check-module-invariants.sh` **C15** failed on `def:time-reflection` and `thm:TR-valid` —
     two paper anchors this task newly cites, neither with a KNOWN-ANCHORS row. Added two
     `LIVE-UNPINNED` rows to `docs/reference/paper-definitions-of-record.md` after verifying
     read-only that both are live, uncommented `Ddef`/`Tthm` environments in the paper
     (lines 3963, 3999). **This file is a plan Non-Goal** (task 801's territory); 801 is deferred
     and the file was uncontended, and the alternative was deleting the very anchors the dispatch
     asked to be recorded.
  3. `check-module-invariants.sh` **C35** failed with 78 citation-manifest problems, all pure
     line-offset drift in exactly the three files this task shifted. Fixed by the generator the
     gate prescribes, `python3 scripts/export-lean-citations.py`, never by hand.
     `scripts/lean-citation-manifest.json` is also in 801's declared `file_scope`; same grounds.
  Also `FAIL INV`: the new module staled four generated README inventory blocks, regenerated via
  `--emit-inventory`, with `OpenReversal.lean`'s hand-written description column fixed by hand
  (the generator preserves it verbatim and it still credited the module with the promoted
  declarations).

## Verification

- Build: **Success**. Guarded, detached builds all exit 0 with zero `error:` —
  `FormalSystem` (2856 jobs), `BimodalTest` (2919), `BimodalTools` (1969),
  `BimodalToolsTest` (1979).
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1, inherited** — `FormalSystem/Examples/TemporalStructures.lean:495`,
  byte-identical at the pre-task baseline `db9de8b4f`, in a file this task never touched, and
  legitimate (`intTimeHistory.domain t` over total ℤ-time unfolds to `True`). Zero introduced.
- Axiom count: **14, unchanged** from the pre-task baseline `db9de8b4f`.
- `lean_verify` on the new declarations: `truthAt_rev`, `validIn_reflectTime`,
  `validQTime_reflectTime`, `FrameClass.Sat.rev` all report
  `[propext, Classical.choice, Quot.sound]`; `WorldHistory.rev_surjective` reports
  `[propext, Quot.sound]`. No `sorryAx`, no non-standard axiom anywhere.
- **Compiled signature probe** (`lake env lean`, zero diagnostics): all eleven pinned Challenge
  signatures elaborate at their recorded statements; `validIn_reflectTime (axiom_validIn_min ax)`
  recompiles, confirming the decision-(3) availability claim; and `F.rev.rev = F := rfl` confirms
  `TaskFrame.rev`'s load-bearing `@[reducible]` survived the promotion.
- `check-module-invariants.sh`: **exit 0, zero FAIL lines**, with C35 ("byte-current: all 86
  seeded declaration(s) resolve"), C15 (all 83 anchor citations resolve; all 289 theorem-index
  rows carry their anchor), INV, C33, C24, C4, C5, C8, C9 and C32 all PASS.
- `check-copyright-headers.sh` exit 0 (690 files, 0 nonconforming/missing/duplicate).
- `readme-lint.sh` exit 0. `typst-sync-check.sh` **exit 0, all 4 checks green**, with
  `formalsystem-file-count = 690` as predicted.
- `check-phantom-citations.sh` exit 0 with 15 advisory findings, **all inherited** — none names
  any surface this task changed.
- `check-paper-definitions.sh`: **exit 1, fully inherited**. Run untruncated; exactly ten drifted
  anchors — `CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`,
  `def:strongest`, `thm:exist`, `lem:uniq` — matching the count the plan's Risks section recorded
  as already drifted before this task began. Zero occurrences of `time-reflection` or `TR-valid`
  in the report. Each drift is an author-side edit to `possible_worlds.tex` (`\leanfoot{}`
  additions, the BX axiom-list restructuring) in a repository this task must not edit.
- `verify-deploy.sh --skip-slow` exit 0 (0 checks, 0 failures). This repository has no
  `agent-system/` source store and no `source_dir` key, so the dispatch's named scoped-gate
  scripts do not exist here; this task touched zero files under `.claude/**`, so that gate surface
  is untouched by this change class. The full repository gate set is **deferred to the batch
  stage** per the dispatch's Batch Gate Deferral, and attributed back by `modified_files`.
- Files verified: Yes.

## Impacts

- `lem:time-reflection` and `thm:TR-valid` are now machine-checked for the base language, and
  `thm:TM-soundness`' TR case has a second, independent semantic route.
- The reversal machinery is now at the base of the semantics layer rather than above the open
  language, so it is reachable from the whole `Semantics/` tree — including the Presheaf cluster,
  which is what the Reflection-clause work needs. `FrameOver.rev_isRegular` (an `instance`) and
  `WorldHistory.rev_state` (a `@[simp]` lemma) become visible much earlier; both are keyed on a
  `.rev` head, so instance search and `simp` engage only on goals already mentioning reversal, and
  all four target builds confirm no downstream disturbance.
- `validOnFrames_reflectTime` is reusable at any `rev`-closed frame predicate, including the two
  that no `FrameClass` tag denotes.

## Follow-ups

- **Paper-side `% PORT:` clearance is deferred to the user**, per the plan's Non-Goals and the
  user's twice-recorded decision that implement agents touch only this repository. Nothing outside
  `/home/benjamin/Projects/BimodalLogic` was written. The two markers are
  `possible_worlds.tex:3973` (`lem:time-reflection`, discharged by
  `FormalSystem.Semantics.truthAt_rev` in `Semantics/Reversal.lean`) and
  `possible_worlds.tex:4003` (`thm:TR-valid`, discharged by
  `FormalSystem.Semantics.validIn_reflectTime` and its family in `Semantics/Validity.lean`).
  Both can be cleared without re-deriving anything.
- **Task 801's dispatch inherits two touches inside its declared `file_scope`**:
  `scripts/lean-citation-manifest.json` (regenerated) and
  `docs/reference/paper-definitions-of-record.md` (two LIVE-UNPINNED rows). Both are recorded in
  `issues.jsonl` so 801 meets them as a written record rather than surprise drift.
- The ten `check-paper-definitions.sh` drifted anchors remain open and are task 801's territory.
- A real collapse of `derivable_valid_and_reflect_time_validIn` onto `validIn_reflectTime`
  remains available as its own task, with the four-layer scope recorded in the Decisions above.
- Task 617 (the presheaf Reflection clause) is the categorical packaging of the same involution
  and is independent; its Phase A is now already done by this task's Phase 1, since the two
  designs agreed on the declarations and the destination file.

## References

- `specs/796_time_reflection_bl_tr_valid_anti_iso/plans/01_time-reflection-bl-tr-valid.md`
- `specs/796_time_reflection_bl_tr_valid_anti_iso/reports/01_time-reflection-bl-tr-valid.md`
- `specs/796_time_reflection_bl_tr_valid_anti_iso/handoffs/` (phases 1, 2, 3, 5)
- `specs/796_time_reflection_bl_tr_valid_anti_iso/issues.jsonl`
