# Implementation Summary: Task #512 — bundle the duration type into `TaskFrame`

- **Task**: 512 - bundle_duration_into_taskframe
- **Type**: lean4
- **Plan**: `specs/512_bundle_duration_into_taskframe/plans/01_bundle-duration-into-taskframe.md`
- **Research**: `specs/512_bundle_duration_into_taskframe/reports/01_bundle-duration-into-taskframe.md`
- **Outcome**: **PARTIAL** — 5 of 13 phases complete and verified green; 5 phases BLOCKED on an
  owner decision; 3 phases not started (they sit downstream of the blocked ones).
- **Tree state**: green at every commit. `lake build` exits 0 and
  `bash scripts/check-module-invariants.sh` reports **ALL CHECKS PASSED** at HEAD.

## Phase outcomes

| Phase | Name | Status |
|-------|------|--------|
| 1 | Rename to `ParamTaskFrame`, declare bundled `TaskFrame`, establish the bridge | COMPLETED |
| 2 | Semantics core structures | COMPLETED |
| 3 | Validity and the BL layer | COMPLETED WITH EXCLUSIONS |
| 4 | Extension layer and `ShiftSet` | COMPLETED WITH EXCLUSIONS |
| 5 | ℤ machinery — `IntNormalForm`, `IntTransfer` | **BLOCKED** |
| 6 | ℤ machinery — `IntPresentation`, FMP | **BLOCKED** (same cause) |
| 7 | `ReynoldsBridge`, group-model countermodel base | **BLOCKED** (same cause) |
| 8 | Soundness layer | COMPLETED WITH EXCLUSIONS |
| 9 | Canonical constructions | NOT STARTED (depends on 7) |
| 10 | Decidability remainder | **BLOCKED** (BiLasso half) |
| 11 | Independence, Examples, `FrameConditions`, aggregators | NOT STARTED |
| 12 | Tests | **BLOCKED** (same cause) |
| 13 | Delete the bridge; restore names; documentation | NOT STARTED — and **not executable as written**, see below |

## What landed

`FormalSystem/Semantics/TaskFrame.lean` now carries the target shape verbatim:

```lean
structure TaskFrame where
  Duration : Type
  [addCommGroup : AddCommGroup Duration]  [linearOrder : LinearOrder Duration]
  [orderedAddMonoid : IsOrderedAddMonoid Duration]  [nontrivial : Nontrivial Duration]
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → Duration → WorldState → Prop
  nullity_identity … comp … converse … serial … limit … spherical
```

with `FiniteTaskFrame`, the `attribute [instance]` block, the bundled derived API
(`forward_comp`, `interpolates`, `nullity`, `backward_comp`), the bundled definitional-content
`example`s, and the transitional bridge (`@[reducible] ofParam`, `toParam`, and a `CoeOut`).

Migrated to `(F : TaskFrame)`: `PartialHistory`, `PartialHistoryOrder`, `WorldHistory`,
`TaskModel`, `Truth`, `FrameAxioms`' history half, `H_F`, `Extension/{Admissible,Constraint,
Extension,Step}`, `ShiftSet`, the whole `Valid*` / `SemanticConsequence*` / `Satisfiable*Set`
family (`Validity`, `BLValidity`, `BLTruth`, `SetConsequence`), and the soundness layer
(`Soundness`, `BaseLanguageSoundness`, `StrongCompleteness`, `DiscreteNonCompactness`,
`SoundnessLemmas/CoValidity`, `Automation/PrefilterSoundness`), plus the consumer sites those
forced across `FrameConditions/`, `BXCanonical/`, `Decidability/` and `Independence/`.

## The three load-bearing findings

**1. The `CoeOut` mechanism works, and the shim ledger is empty.** Phase 1's decision ladder
resolved to option (a): `CoeOut (ParamTaskFrame D) TaskFrame` fires at explicit argument
positions of plain `def`s, at structure parameter positions, and with dependent following
arguments, and `(ofParam F).addCommGroup = inferInstance` closes by `rfl` at reducible
transparency. Not one of the 75 unmigrated files needed a call-site edit at Phase 2, and no shim
was ever introduced. One universe caveat: the coercion cannot cross a universe boundary, so all
95 `D : Type*` binder sites were demoted to `D : Type` — which is the target shape's own choice
(research F2), not a workaround.

**2. Two things the coercion does *not* reach**, both discovered empirically:

- *Generalized field notation.* `F.HF`, `F.forward_comp`, `F.ValidOn` resolve by the head
  constant of `F`'s type and never consult the coercion. Namespace-level items therefore have to
  move as a unit with a call-site edit (`TaskFrame.HF F`), or be given a bundled twin.
- *Explicit `∀ (D : Type) [4 instances]` binders inside a Prop.* This is what `valid` and its
  four siblings have, so every consumer supplies them positionally and every consumer breaks at
  once. Phase 3 is consequently not a one-agent-run phase: iterating it to green touched 17
  files spanning plan Phases 3, 8, 9, 10 and 11, and completed most of Phase 8 as a side effect.
  A re-plan should merge 3 and 8 into one dependency component.

**3. The blocker: bundling makes "the frames over a fixed duration type" inexpressible.**
The ℤ machinery does not quantify over *a* frame; it quantifies over `(F : ParamTaskFrame ℤ)`
and writes the numeral `1` at that duration type (`step F w u := F.TaskRel w 1 u`,
`IntNormalForm.lean:175`). `(F : TaskFrame)` says nothing about the carrier, and
`(F : TaskFrame) (hD : F.Duration = ℤ)` does not help — `hD` is a `Prop`, `OfNat F.Duration 1`
is data, and the equation cannot transport the instance:

```
failed to synthesize instance of type class
  OfNat F.Duration 1
```

reproduced in `probes/06_fixed-duration-expressibility.lean`. Research F4's idiom ("state the
lemma at `Int`, discharge arithmetic outside the frame application") does not rescue this: it
presupposes the frame's duration is *syntactically* `ℤ` at the use site, true of a coerced
concrete frame and false of an abstract bundled frame variable.

This is a missing abstraction, not a proof-engineering obstacle. `ParamTaskFrame D` **is** the
fibre notion, which is why Phase 13's "delete `ParamTaskFrame`" cannot be executed as written.
The blocked surface is 76 occurrences of `ParamTaskFrame {ℤ,Int,ℚ,ℝ}` across 20 live files, plus
the four `TaskFrame Int` values in `Tests/`.

**Decision required** (enumerated in full under the Phase 5 blocker in the plan):

1. Keep `ParamTaskFrame D` permanently as the library's name for the fibre over `D`, with
   `TaskFrame.ofParam` as the canonical inclusion. Cheapest by far — Phases 5-7, 10 and 12 shrink
   to nothing, because those files are already correct and already interoperate with the bundled
   layer through the coercion. Phase 13 loses its deletion step and gains a docstring.
2. Reformulate the ℤ machinery over frame *components*. Faithful to "one frame type", but a
   redesign of ~350 occurrences, not a restatement.
3. Introduce a `FrameOver D` abstraction carrying the carrier equation as data. A new design
   object; close to what option 1 gives for free.

## Plan Deviations

- **Phase ordering**: Phase 4 ran before Phase 3. Phase 4's stated dependency on Phase 3 is not
  real (no file in `Semantics/Extension/` or `ShiftSet.lean` imports `Semantics/Validity.lean`),
  and Phase 3 is the one phase the coercion cannot hold green, so it was not allowed to block a
  phase it does not gate.
- **Phase 1, added**: three mechanical steps the plan did not anticipate — module-path imports
  rewritten back after the token rename, the `extends` parent projection renamed at its 5
  structure-projection sites, and the 95 `D : Type*` demotions.
- **Phase 2, altered**: `ParamTaskFrame.HF` and `FiniteTaskModel` deliberately left parameterized
  (dot notation does not coerce); the F4 hazard arrived a phase early and three ℤ-facing files
  (`BiLasso/Unfold.lean`, `BiLasso/TruthLemma.lean`, `Extension/PeriodicExtension.lean`) took the
  idiom then. The working form is an explicit `@LT.lt ℤ _ a b`: a `(t : ℤ)` ascription is a no-op
  when `t` is itself frame-typed and silently re-elaborates at the frame type.
- **Phases 3 and 8, altered**: frame-class side conditions taken as statement-level instance
  binders (research option (b)) rather than `haveI`-introduced Prop hypotheses (option (a)). The
  plan's preference for (a) is scoped to conditions destined to become `FrameConditionFor` match
  arms, and that collapse is an explicit Non-Goal here; instance binders keep every downstream
  proof script byte-identical.
- **Phase 4, altered**: `ShiftSet.frame` had to become `@[reducible]` (its `hist` proof rewrites
  under `S.frame.Duration`); `ShiftSet` itself stays parameterized by a duration *type*, being a
  carrier-level structure rather than a frame.
- **Phase 4, excluded**: `Extension/PeriodicExtension.lean`, ℤ-specific, deferred to Phase 5.
- **Phase 3, excluded**: `satisfiable` / `SatisfiableAbs`, `SoundnessLemmas`' `IsValid D`, and
  `FrameConditions`' `ValidOver` — all three are the fixed-carrier shape of finding 3.
- **Phase 8, excluded**: `SoundnessLemmas/Core.lean`'s `IsValid D`; `Separability.lean` needed no
  edit at all (zero frame binders).

Every exclusion is tabled with a reason and evidence in the plan's `#### Reasoned Exclusions`
sections.

## Verification

Run at every phase boundary, not deferred:

- `lake build` exits 0. Phase 1 wall-time baseline: 403 s for a full rebuild.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED**, including
  **C2** (the four flagship axiom profiles — `BXCanonical.{completeness, completeness_dense,
  completeness_discrete}` and `BXCanonical.Chronicle.countermodel_dense` — each still exactly
  `[propext, Classical.choice, Quot.sound]`), **C3** (zero structural `sorry`), C6, C9, C14, C15.
- No mathematical content changed anywhere: every restatement is an identity accepted by `defeq`,
  and no proof gained a new lemma or a new step.

## Artifacts

- `specs/512_bundle_duration_into_taskframe/probes/04_coercion-and-transparency.lean` — the
  Phase 1 decision-ladder probe (coercion firing, reducible-transparency instance unification).
- `specs/512_bundle_duration_into_taskframe/probes/05_omega-at-a-coerced-frame.lean` — why
  `omega` loses its hypotheses at a coerced ℤ frame, and which restatement recovers them.
- `specs/512_bundle_duration_into_taskframe/probes/06_fixed-duration-expressibility.lean` — the
  blocker, reproduced.
