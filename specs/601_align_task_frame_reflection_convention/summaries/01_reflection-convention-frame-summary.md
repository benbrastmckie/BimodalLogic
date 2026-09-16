# Implementation Summary: Task #601

- **Task**: 601 - Align task-frame definition with the paper's reflection convention
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T14:05:00Z
- **Completed**: 2026-09-16T15:30:00Z
- **Effort**: ~1.5 hours (agent wall clock)
- **Dependencies**: 599 (completed), 598 (completed)
- **Artifacts**: plans/01_reflection-convention-frame.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FrameOver` now has exactly the paper's shape: `WorldState`, `[worldNonempty]`, a primitive
relation `PosRel` on the positive cone `D⁺`, and the four `def:frame` axioms (`comp`, `serial`,
`limit`, `saturation`). The reflection convention is a definition (`TaskFrame.reflect`), the
two-sided `FrameOver.TaskRel := reflect PosRel` is a definition, and the reflection law is the
derived theorem `FrameOver.reflection`. That follows research Option A: a subtype-typed primitive,
split strictly at zero. Every construction site and consumer was migrated, and the prose was
renamed from "converse convention" to "reflection convention" across Lean, docs, typst and LaTeX.

## What Changed

- `FormalSystem/Semantics/TemporalOrder.lean`: added `abbrev TemporalOrder.PositiveCone` (D⁺)
  and rewrote the positive-cone module note.
- `FormalSystem/Semantics/TaskFrame.lean`:
  - Bare-relation API: `TaskFrame.reflect`, `reflect_of_nonneg`, `reflect_of_neg`,
    `reflect_coe` (simp), `reflect_reflection_of_ne` and `reflect_eq_of_reflective`.
  - Transport lemmas: `reflect_restrict_iff` and
    `{compositional,serial,limit,saturation}_reflect_of_reflective`.
  - `reflection_of_permissive`, replacing the deleted `converse_of_permissive`.
  - Structure swap to `PosRel` plus the four axioms stated over `reflect PosRel`.
  - `FrameOver.TaskRel` as a non-reducible def, with `taskRel_of_nonneg`, `taskRel_of_neg`,
    `taskRel_coe` (simp) and `reflect_posRel` (a simp fold).
  - `FrameOver.reflection`, and `backward_comp` rerouted through it.
  - `FrameOver.ofReflective`, `ofReflective_taskRel` and `ofReflective_taskRel_eq`.
  - `TaskFrame.reflection` (total space), and `trivialFrame_taskRel` (simp).
  - `trivialFrame`, `staticFrame` and `natFrame` rebuilt with `ofReflective`.
- Construction sites moved to `ofReflective`:
  - `Frames/Standard.lean`
  - `IntTransfer.lean` (`FrameOver.map`, plus the new `map_taskRel`)
  - `IntNormalForm.lean` (`ofStep`)
  - `Examples/TemporalStructures.lean` (plus the new `intTimeFrame_taskRel`)
  - `Algebraic/FlowFrame.lean` (plus the new `multiFamGen_taskRel`)
  - `Bridge/RegionFrame.lean`
  - `FMP/Filtration.lean`
  - `Independence/ClockFrame.lean`
  - `IntegerModel/ReynoldsBridge.lean` (plus the new `zTaskFrameV2_taskRel`)
- Construction sites kept as `@[reducible]` literal structures, with fields cited from the
  transport lemmas:
  - `ShiftSet.fibre` (plus the new `shRel_*` obligations and `fibre_taskRel`)
  - `Independence/DriftFrame.fzeroFrame`
  - `Independence/ForwardDeterministicFrame.fnFrameOver`
- Renamed `fzero_converse` to `fzero_reflection` and `fn_converse` to `fn_reflection`, and
  `.converse` to `.reflection` at every projection.
- Consumers that relied on `TaskRel` being the literal relation now use the per-frame `*_taskRel`
  bridges (`.mp`/`.mpr`):
  - Semantics: `PartialHistory`, `ShiftSet`, `DurationFrames`, `PlusNonValidities`.
  - Metalogic: `IntPresentation`, `CoNotPriorU`, `StaticFrame`, `DriftHistories`,
    `StarDiscrimination`, `PastingIndependence`, `DiscreteNonCompactness`,
    `RealTranslationFrame`.
  - Tests: `TaskFrameTest`, `SemanticPropertyTest`, `Generators` (prose only).
- Prose and docs:
  - The Lean docstrings and `FormalSystem/Semantics/README.md`.
  - `README.md` and `docs/reference/API_REFERENCE.md`.
  - `docs/reference/paper-definitions-of-record.md`: re-pinned `def:task-relation` and
    `def:deterministic`, with new hashes.
  - `docs/architecture/total-history-validity-decisions.md` (identifier).
  - typst: `bimodal-notation.typ` (`leanConverse` replaced by `leanPosRel`/`leanReflection`),
    `02-semantics.typ`, `06-notes.typ` and `FormalFoundations.typ`.
  - LaTeX: `latex/subfiles/02-Semantics.tex`.
  - Regenerated inventory blocks (six READMEs).

## Decisions

- Option A (subtype primitive) held at every site. The Option B fallback was not needed.
- No deprecated alias for `converse`: direct rename, per the plan.
- `ofReflective` stays non-reducible. Making it `@[reducible]` broke unification of
  `ofReflective_taskRel` against named frames, because the pattern `?R w ↑x u` is not higher-order.
  Frames whose world-state type must reduce at reducible transparency (`ShiftSet.fibre`, used by
  `RealTranslationFrame`, `fzeroFrame` and `fnFrameOver`) stay literal structures and cite the
  transport lemmas field by field.
- `ofReflective_taskRel` is **not** `@[simp]`. Its left-hand side is type-correct only after
  unfolding `ofReflective`, and the simpNF linter (check C16) hit maximum recursion on it. Each
  frame states its own `@[simp]` bridge instead.
- `reflect_posRel` is a simp *fold* (`reflect F.PosRel w d u ↔ F.TaskRel w d u`), so that field
  instances rewrite against goals phrased over `F.TaskRel`. Neither `reflect` nor `TaskRel` is
  simp-unfolded.

## Plan Deviations

- **Phase 2** altered: `converse_of_permissive` was deleted in Phase 2, not Phase 3.
  `ofReflective_taskRel_eq` and `trivialFrame_taskRel` were added.
- **Phase 3** altered: `ShiftSet.fibre` became a reducible literal using new transport lemmas
  instead of `ofReflective`.
- **Phase 4** altered: more consumers needed bridge rewrites than the plan listed (see What
  Changed). `fzeroFrame` and `fnFrameOver` became reducible literals.
- **Phase 7** altered: `ofReflective_taskRel` dropped `@[simp]` (simpNF linter).
  `check-module-invariants.sh --emit-inventory` regenerated six stale inventory blocks, five of
  which were already stale at the base commit. The pre-existing C11 and C12 failures (deleted
  `ConvexHistory`) were cleared: a waiver in `scripts/boneyard-import-waivers.txt`, and a prose
  path fix.

## Verification

- Build: Success. Full `lake build` (2659 jobs) and `lake build FormalSystem BimodalTest`
  (2718 jobs) both pass.
- Tests: Passed (`lake test`).
- `scripts/readme-lint.sh`: PASS.
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED. That includes C16 (env_linter) and INV.
  Two failures pre-dated this task: C11 and C12 were dangling references to
  `ConvexHistory.lean`, which task 599 deleted. Both were cleared, with a Boneyard import waiver
  and a prose fix in `paper-definitions-of-record.md`.
- Sorry count: 0 new (the textual `sorry` grep over live, non-Boneyard Lean is 394
  before and after, all docstring/comment mentions; `check-module-invariants.sh` C3 confirms zero
  structural sorry).
- Vacuous count: 1, the same pre-existing match as the base commit (0 new).
- Axiom count: 0 new `axiom` declarations. The `^axiom ` grep matches only docstring lines:
  11 before, 11 after.
- `lean_verify`:
  - `FrameOver.reflection` and `TaskFrame.reflection`: [propext, Classical.choice, Quot.sound].
  - `reflect_eq_of_reflective` and `ofReflective_taskRel`: [propext, Quot.sound].
- `#print FrameOver` lists exactly `WorldState`, `worldNonempty`, `PosRel`, `comp`, `serial`,
  `limit`, `saturation`.
- `scripts/check-paper-definitions.sh`: `def:task-relation` and `def:deterministic` are no longer
  drifted (drift went from 16 to 14; the remaining 14 are out of scope).
- `grep "converse convention"`: 0 hits in live Lean, docs, typst and latex. The only remaining
  mention is the historical note in paper-definitions-of-record.
- typst: `FormalFoundations.typ` and `BimodalReference.typ` both compile.
- Files verified: Yes.

## Impacts

- Every `FrameOver` construction now supplies `PosRel` (on `D⁺`) plus four axioms. Two-sided
  presentations go through `FrameOver.ofReflective`, whose obligation `hR` is the reflection law.
- Downstream proofs over a concrete frame can no longer rely on `TaskRel` being definitionally the
  presenting relation. They use that frame's `*_taskRel` bridge instead. Abstract-frame
  consumers are unchanged (`F.serial : Serial F.TaskRel` still holds by citation).
- Task 602 (`PartialHistory.lean`) should rebase onto these commits. The 601 edits there are
  `.converse` renamed to `.reflection`, prose, and `trivialFrameHistory`'s bridge.

## Follow-ups

- Paper note (author's call, non-blocking): `def:task-relation` states the convention "for
  $x \geq 0$", which overlaps itself at `x = 0`. The Lean encoding splits strictly at zero and
  derives symmetry at zero from *Seriality* plus *Limit*. Stating the convention "for $x > 0$"
  would make the paper literally match.
- Paper drift (out of scope): 14 other drifted anchors in `check-paper-definitions.sh`. Also,
  `def:frame`'s opening now reads "for all positive durations $x, y \geq 0$", while in-tree
  docstrings quote the older "for $x, y \geq 0$".
- `typst/SYNC-MAP.md` keeps a historical audit row that mentions a `converse` field. It was left
  as a record.
- Optional: a lean4 context pattern note on "primitive-on-cone field + derived extension + smart
  constructor" (source store `agent-system/extensions/lean/...`).

## Converse Audit

Remaining "converse" hits in live Lean, docs, typst and latex are genuine converses, not the D⁺
stipulation:

- Logical converses of theorems (Compactness, Erasure, DeterminismUndefinable, Conservativity,
  `deductionConverse`, Kamp, MintBound, and others).
- The order-dual `orderDual_converse` and `TimeOrderConverse` (Decidability Bridge).
- Relational converses (typst 02-semantics "superscript inverse", `O-Conv`, "closed under
  converses", latex "take converses").
- The historical rename note in paper-definitions-of-record and the `SYNC-MAP.md` audit row.

## References

- specs/601_align_task_frame_reflection_convention/plans/01_reflection-convention-frame.md
- specs/601_align_task_frame_reflection_convention/reports/01_reflection-convention-encoding.md
- /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex (`def:task-relation`, `def:frame`, `def:deterministic`)
