# Implementation Plan: General Task Frames with Regular Frame Constraints

- **Task**: 656 - Refactor task frames: general frames with the four constraints as frame conditions, the constrained class named *regular*
- **Status**: [IMPLEMENTING]
- **Effort**: 17.5 hours
- **Dependencies**: 651, 652, 654, 655 (all completed)
- **Research Inputs**: `specs/656_refactor_task_frames_general_with_frame_constraints/reports/01_general-frames-regular-constraints.md`
- **Artifacts**: plans/01_general-frames-regular-constraints.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FrameOver D` today carries six fields: the state type, its nonemptiness, the primitive relation
on the positive cone, and the paper's four axioms (Compositionality, Seriality, Limit,
Saturation). Because the axioms are fields, a frame violating one of them cannot be written down
at all, so the topological and rigidity results that distinguish the constraints — "Limit iff
the neighbourhood topology is T1", the four-state funnel on which the cone topology is T1 while
Limit fails, separation-without-Limit, the rigidity sharpness witnesses — are unstatable. This
refactor strips `FrameOver` to its three data fields, carries the four axioms in
`class FrameOver.IsRegular`, re-exports `FrameOver.comp`/`serial`/`limit`/`saturation` as
theorems taking `[F.IsRegular]` so that every consumer site stays textually unchanged, and lands
the neighbourhood topology plus the counterexample module that the split makes expressible.

Definition of done: `lake build --wfail` green over `FormalSystem` and `Tests/BimodalTest`; zero
`sorry`; `check-module-invariants.sh` all checks pass; `lake exe mk_all --lib FormalSystem --check`
exits 0; axiom sets unchanged from baseline on the extension theorem, the funnel's constraint
facts, and `FrameOver.t1Space_iff_limit`; the migration table below complete against
`git diff --stat`.

### Research Integration

The research round compiled two probe files (481 lines, 0 sorries, exit 0) that settle the
architecture end to end, and the plan below adopts their verified shapes verbatim rather than
re-deriving them:

- `probes/RegularClass.lean` — `class FrameOver.IsRegular`, same-named theorem re-exports,
  structure eta preserved by `rfl`, total-space delegation via
  `abbrev TaskFrame.IsRegular G := G.toFibre.IsRegular`, the `def`+`instance` construction split,
  the `ofReflectiveRegular` auto-instance, the `FrameClass.Sat` lever, and a compiled non-regular
  four-state funnel.
- `probes/TopologyInstance.lean` — `instance : TopologicalSpace F.WorldState := nbhdTopology F.TaskRel`
  on the **general** frame, `T1Space F.WorldState ↔ Limit F.TaskRel`, derived `T1Space`/`R0Space`
  on the regular class, and the real-carrier instance-keying probe. `#print axioms` returns
  Mathlib's standard three only.
- Task 655's six probe files (1983 lines) supply `nbhdTopology`, `coneTopology`,
  `t1Space_nbhdTopology_iff_limit`, the funnel, the two-origin half-line, the hedgehog, the
  real-carrier bridge lemmas, and the ℤ partition facts, all already compiled and sorry-free.

**Correction carried forward from research, superseding the task description.** The task
description conjectures that the extension theorem "uses Saturation and, through interpolation,
half of Compositionality". The tree says it consumes **all four constraints**:

| Module | Line | Constraint consumed | Via |
|---|---|---|---|
| `Extension/Constraint.lean` | 149, 171 | Compositionality, composition half | `F.forward_comp` (directedness) |
| `Extension/Constraint.lean` | 231, 233 | Seriality | `F.serial` (`nonempty_fib_of_serial`) |
| `Extension/Constraint.lean` | 254 | Compositionality, interpolation half | `F.interpolates` (`nonempty_seg_of_interpolates`) |
| `Extension/Admissible.lean` | 318 | Seriality + Limit at zero | `F.reflection` |
| `Extension/Admissible.lean` | 326 | Seriality + Limit | `TaskFrame.nullity_of_serial_limit F.serial F.limit` |
| `Extension/Step.lean` | 135 | Saturation | `F.saturation` — the sole application site in the development |

Design requirement (2) is therefore answered as: **`thm:extension` takes `[F.IsRegular]`**, and
the docstring must say it consumes the whole biconditional Compositionality (both halves, at
different sites), Seriality, Limit (through `lem:nullity` and through `reflection` at zero), and
Saturation.

**Histories cost zero edits.** `PartialHistory F`, `WorldHistory F`, `IsConvex`, `IsTotal`,
`timeShift` and `ofTotal` are already defined over `TaskFrame` through `respects_task`/`TaskRel`
alone; no axiom field appears in any of them. They become general-frame notions the moment the
fields leave the structure.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; no roadmap phases required (`roadmap_flag` not set).

### Settled Decisions Carried In

Both user-ratified decisions from `.decisions.json` are binding on this plan and are discharged
as follows:

1. **Build the topology here, not in a follow-up.** Phase 3 lands
   `FormalSystem/Semantics/StateTopology.lean` with `nbhdTopology` as the sole `TopologicalSpace`
   instance on a state space, `coneTopology` as a plain `def` with no instance,
   `TaskFrame.Limit` named and definitionally equal to the current literal shape, and
   `Limit ↔ T1`. History continuity takes the order topology on `D` as a **binder**, never a
   global instance. No documented hook; there is an instance.
2. **Prefer the import-weight lever over per-declaration instance pinning.** Stated explicitly
   here as the plan's choice: `Semantics/StateTopology.lean` and
   `Semantics/StateTopology/Counterexamples.lean` are kept **out of the `Semantics.lean`
   aggregator** and reached only by the generated root `FormalSystem.lean`, following the
   `TimeIndexedSharpness` precedent. This confines the new global `TopologicalSpace` instance to a
   leaf. C24 (every module transitively imports `FormalSystem.Init`) is satisfied through
   `TaskFrame`. No per-declaration instance pinning is used anywhere in this refactor.

## Goals & Non-Goals

**Goals**:

- Strip `FrameOver` to its three data fields and carry the four axioms in a `Prop`-valued class,
  so that any subset of the constraints can be assumed and frames violating a constraint become
  writable.
- Keep every existing theorem's name and statement, modulo an added instance binder; never
  silently weaken or strengthen a statement, and where a result genuinely needs fewer constraints,
  add a generalized version at the weaker hypothesis and derive the existing one from it.
- Keep the meaning of validity fixed across the strip, so no soundness or completeness theorem
  changes.
- Land the neighbourhood topology on the general frame, with the Limit characterisation, as one
  new leaf module, plus a counterexample module whose frames satisfy some constraints and not
  others.
- Leave the tree green, sorry-free and warning-free at every phase boundary, with documentation,
  generated inventory, theorem index and invariant gates all updated.
- Declarations pinned by `## Lean Challenge Statements`: `FrameOver.t1Space_iff_limit`,
  `FrameOver.eq_of_taskRel_zero_of_limit`, `ShiftSet.rev_sep_of_limit`,
  `StateTopology.funnelFrame`, `StateTopology.funnel_not_limit`,
  `StateTopology.funnel_t1Space_coneTopology`.

**Non-Goals**:

- Manuscript edits to `possible_worlds.tex`. The user makes these separately, after this refactor
  lands.
- A second, bundled `RegularFrameOver D extends FrameOver D` frame type. Research recommends
  against it and nothing in the requirements needs it.
- Proving Saturation for the two-origin and hedgehog frames. They are wanted precisely as frames
  satisfying some constraints and not others; Saturation is explicitly not claimed for them.
- A `TopologicalSpace` instance for the cone topology. Exactly one instance per state space, by
  ratified decision.
- Any concurrent work under `FormalSystem/`. This task's `file_scope` is the whole library.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 8 (field retirement) surfaces a missed consumer as a wall of build errors | H | H | The blanket instance from Phase 2 keeps Phases 4-7 verifiable against a green tree, so Phase 8 is a deletion whose failures are localized compile errors rather than meaning changes. Phase 8 is merged with no other phase and is bracketed by a full `--wfail` build plus the test library before and after. |
| Validity silently widens: after the strip `∀ F : TaskFrame` ranges over general frames, so `Valid` would become validity over all frames and soundness would break | H | H | Phase 4 redefines `FrameClass.Sat .Base F := F.IsRegular` and conjoins `F.IsRegular` into the `.Dense`/`.ZTime`/`.RTime` tags, leaving every `Valid*` definition byte-identical. Verified in `probes/RegularClass.lean` that `Sat` being `@[reducible]` over a `Prop` class makes a bare `intro h` register the instance, so `sat_intro` needs no new `.Base` branch. |
| `warn.classDefReducibility` on `nbhdTopology` (a `def` of class type) is **fatal under `--wfail`** | H | H | Decided here, not at build time: use a module-scoped `set_option warn.classDefReducibility false` in `StateTopology.lean`, not `@[instance_reducible]`. Making the topology instance-reducible changes how eagerly unification unfolds it and would interact with the carrier-keying hazard below. Recorded as a C29 (`set_option linter.* false`) candidate — confirm at Phase 10 whether C29's scope covers `warn.*` as well as `linter.*`, and add the justification comment the check requires if so. |
| Real-carrier instance ambiguity: at a frame with `WorldState := ℝ`, the new instance on `FrameOver.WorldState _` and Mathlib's `TopologicalSpace ℝ` coexist, so which one a goal gets depends on how the type is spelled | M | M | Land the bridge lemmas from task 655's `RealFrames.lean` probe (`nbhdTopology_eq_real`) in the same phase as the instance; never spell a frame carrier as the bare Mathlib type in a topological statement; do not make `WorldState` reducible. This is an ambiguity, not a diamond — the two topologies were proved propositionally equal on the metric frame. `Correspondence/RigidityReal.lean` is where it bites first. |
| Saturation for the two-origin and hedgehog frames is a paper argument, not a Lean proof | M | H | Requirement (6) does not need them regular. Land them as general frames with the three proved constraints as separate facts, Saturation explicitly **not** claimed, and say so in their docstrings. The named acceptance test — the four-state funnel — needs no paper argument: it is finite, so `TaskFrame.saturation_of_finite` discharges Saturation outright, and its interest is that Limit fails. |
| C17 (dead-declaration scan) flags the new topology vocabulary: `coneTopology` is deliberately a `def` with no instance, and several counterexample lemmas exist to be cited rather than used | M | H | C17 excludes `instance`-attributed and simp-set declarations; for the rest, cite each new declaration from its module docstring or from `docs/theorem-index.md`, the pattern the tree already uses. Phase 10 budgets a dedicated sweep. |
| C19 (90% docstring floor) and C16 (Batteries `docBlame`/`unusedArguments`) apply to ~40 new declarations in `StateTopology.lean` alone | M | M | Task 655's probe files already carry docstrings on essentially every declaration; lift them with the code. `ofReflectiveRegular`'s four unused explicit arguments must be underscore-prefixed (`_hcomp`, ...) or `unusedArguments` fires — confirmed by construction in the probe. |
| Build cost: a full `--wfail` build plus the test library at ten phase boundaries is the dominant wall-clock cost | M | H | Every build runs detached through the shared guard: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` under `Bash(run_in_background: true)`, with a bounded waiter per `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID, never `pgrep -f`). Never a foreground blocking `lake build`. |
| Concurrency: another task editing `FormalSystem/` mid-refactor | H | L | Phase 1 opens by re-checking `specs/state.json` for any task with status `implementing` whose scope touches `FormalSystem/`, and stops if one is found. Tasks 651/652/654/655 are all completed. |
| Toolchain papercuts rediscovered per phase | L | M | Carried forward from research: `le_or_lt` is unavailable at this pin under `TaskFrame.lean`'s import set — use `lt_or_ge`; `push_neg` is deprecated in favour of `push Not`; `linarith` does not close goals over an abstract `TemporalOrder` carrier (an ordered additive group, not an ordered field) — use `sub_lt_self`, `lt_add_of_pos_right`, `sub_lt_iff_lt_add'`; `TaskFrame.Serial` takes the `0 ≤ x` proviso as an explicit third argument; `Finite Bool` needs `Mathlib.Data.Finite.Prod` at this import set; `letI := nbhdTopology R` is load-bearing before any Mathlib separation lemma. |

## Migration Table

Design requirement (4). This is the plan-time table; the implementation summary carries the
final version, checked against `git diff --stat`.

| Old | New | Kind of change | Reason | Alias |
|---|---|---|---|---|
| `FrameOver.comp` (field) | `FrameOver.comp (F) [F.IsRegular]` (theorem) | binder added, name and type unchanged | constraint moves to the class; re-export keeps consumer text byte-identical | none needed (same name) |
| `FrameOver.serial` (field) | `FrameOver.serial (F) [F.IsRegular]` | same | same | none needed |
| `FrameOver.limit` (field) | `FrameOver.limit (F) [F.IsRegular]` | same | same | none needed |
| `FrameOver.saturation` (field) | `FrameOver.saturation (F) [F.IsRegular]` | same | same | none needed |
| `TaskFrame.comp`/`serial`/`limit`/`saturation` | same names, `[G.IsRegular]` binder | binder added | total-space delegation through `abbrev TaskFrame.IsRegular` | none needed |
| `FrameOver.nullity`, `reflection`, `nullity_identity`, `forward_comp`, `interpolates`, `backward_comp` | `[F.IsRegular]` binder added | binder added | derived from constraints that now arrive through the class | none needed |
| `FrameOver.eq_of_taskRel_zero` | `FrameOver.eq_of_taskRel_zero_of_limit (hlim : Limit F.TaskRel)` **new**, with `eq_of_taskRel_zero (F) [F.IsRegular]` derived from it | generalize-then-derive | genuinely needs Limit alone, per its own docstring; requirement (3)'s explicit sanction, on the `Rigidity.lean` model | old name retained as the derived form |
| `ShiftSet.rev_sep` | `ShiftSet.rev_sep_of_limit (hlim : Limit F.TaskRel)` **new**, with `rev_sep` derived | generalize-then-derive | "dischargeable from `F.limit` alone" per its own docstring; this is what makes separation-without-Limit statable | old name retained as the derived form |
| `FrameOver.ofReflective` (7 args) | `FrameOver.ofReflectiveRegular` (7 args) in Phase 7, then `FrameOver.ofReflective` (3 args: `W`, `R`, `hR`) in Phase 8 | split | requirement (1): the general structure keeps the bare frame name | `@[deprecated FrameOver.ofReflectiveRegular (since := "...")] alias` on the 7-argument spelling, added in Phase 8 |
| — | `instance FrameOver.instIsRegularOfReflective` **new** | new | supplies `IsRegular` by synthesis at every `ofReflectiveRegular` site, making each call-site migration a one-token rename | n/a |
| `TaskFrame.not_validOn_bot (F)` | `(F) [F.IsRegular]` | binder added | non-vacuity genuinely needs the constraints; `ValidOn` itself needs no binder (it quantifies over `WorldHistory F`, general-frame data) | none needed |
| `TaskFrame.hF_nonempty_of_frameAxioms (F)` | `(F) [F.IsRegular]` | binder added | same | none needed |
| `FrameClass.Sat .Base F := True` | `:= F.IsRegular` (and `.Dense`/`.ZTime`/`.RTime` conjoin `F.IsRegular`) | definition changed | preserves the meaning of `Valid`, `ValidIn`, `ValidOnFrames` verbatim across the strip | n/a |
| Literal-structure frames (`DriftFrame`, `LimitClosureFrame`, `ForwardDeterministicFrame`, `ShiftSet`, `OpenReversal`) | each splits into a data `def` plus a named `instance : ….IsRegular` | split | the four axiom assignments leave the structure literal | n/a |
| — | `TaskFrame.Limit` **new** `def` | new | the topology results need `Limit` on the right of an `↔`; definitionally equal to the current literal transcribed shape | n/a |
| — | `FormalSystem/Semantics/StateTopology.lean` **new module** | new | ratified topology decision; root-only import | n/a |
| — | `FormalSystem/Semantics/StateTopology/Counterexamples.lean` **new module** | new | requirement (6): frames satisfying some constraints and not others | n/a |

No deprecation alias is added for the four axiom accessors: they keep their names, so an alias
would be a self-alias. `@[deprecated target (since := "…")] alias old := target` is verified
working at this toolchain and is used only for the genuine `ofReflective` rename.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |
| 10 | 10 | 9 |

Phases within the same wave can execute in parallel. **This plan is deliberately fully
sequential: every wave holds exactly one phase.** Phases 3 and 4 are file-disjoint and their
mathematical dependencies would both be met by Phase 2 alone, so a purely data-driven wave map
would place them together; the plan declares Phase 4 as depending on Phase 3 instead, and the
`Blocked by` column above reflects that declared chain rather than the looser mathematical one.
The reason is the task's own process requirement: it forbids concurrent work under
`FormalSystem/`, every phase ends in a full-library build, and two concurrent full builds against
the same package serialize on the build guard's project-granular lock anyway. Parallelism would
buy nothing here and risks exactly the memory pressure the guard exists to prevent. Phase 8
additionally depends on Phase 3 transitively, through Phases 4-6.

---

### Phase 1: Name `TaskFrame.Limit` [COMPLETED]

**Goal**: Give the Limit axiom a name definitionally equal to its current literal transcribed
shape, and retire the docstrings that record the deliberate non-naming. Nothing else moves.

**Tasks**:
- [x] Re-check `specs/state.json` for any task with status `implementing` whose scope touches `FormalSystem/`; stop and report if one is found. *(completed — only task 656 itself is `implementing`)*
- [x] Add `def Limit {W : Type} (R : W → D → W → Prop) : Prop := ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` in namespace `FormalSystem.Semantics.TaskFrame`, beside `Serial`/`Saturation`/`Compositional`, with a docstring citing `def:frame#Limit` by label and its verbatim phrase (never by line number). *(completed)*
- [x] Restate the `FrameOver.limit` field's type as `TaskFrame.Limit (TaskFrame.reflect PosRel)`, by citation like `serial` and `saturation` already are. Confirm the change is definitional (the field's proofs at every construction site must still typecheck unchanged). *(completed — whole tree rebuilt green with no construction-site edit; `TaskFrame.limit` re-export restated by citation too)*
- [x] Rewrite the three docstrings that record the deliberate non-naming: the module header's "Alignment status" bullet, the `limit` field docstring, and `exists_uniform_radius_of_finite`'s "Status" paragraph. *(deviation: altered — the two non-naming docstrings (module-header bullet list, the bare-relation-predicates section header) plus the `limit` field docstring and the `TaskFrame.limit` re-export docstring were rewritten here; `exists_uniform_radius_of_finite`'s "Status" paragraph records that no topology exists, not that Limit is unnamed, and its rewrite is deferred to Phase 3 where `Semantics/StateTopology.lean` actually exists, so the docstring is never false at a phase boundary)*
- [x] Full `--wfail` build of `FormalSystem` plus `Tests/BimodalTest`, detached through the build guard. *(completed — 2780 jobs, guard exit 0, 0 `error:` lines)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — add `TaskFrame.Limit`; restate the `limit` field by citation; rewrite three docstrings.

**Verification**:
- `lake build --wfail` green over `FormalSystem` and `Tests/BimodalTest`.
- `grep -rn "deliberately.*not named\|no name is given" FormalSystem/Semantics/TaskFrame.lean` returns nothing referring to Limit.
- `example (F : FrameOver D) : TaskFrame.Limit F.TaskRel := F.limit` typechecks by `rfl`-level definitional equality.

---

### Phase 2: Introduce `class FrameOver.IsRegular` alongside the fields [COMPLETED]

**Goal**: Land the class, the same-named theorem re-exports, the total-space delegation, and a
blanket instance derived from the still-present fields, so that the tree is green with **zero**
consumer edits. This is the "introduce alongside" step the process requirements demand.

**Tasks**:
- [x] Declare `class FrameOver.IsRegular (F : FrameOver D) : Prop` with fields `comp`, `serial`, `limit`, `saturation`, each stated by citation as the corresponding bare-relation predicate of `F.TaskRel`. Namespace it as `FrameOver.IsRegular`, **never** bare `IsRegular` — Mathlib's `IsRegular` (cancellable monoid elements) and `RegularSpace` must not be shadowed, and `Mathlib.Topology.Separation.Basic` enters scope in Phase 3. *(completed)*
- [x] Add the blanket instance `instance (F : FrameOver D) : F.IsRegular := ⟨F.comp, F.serial, F.limit, F.saturation⟩`, reading the fields directly. This is temporary scaffolding, deleted in Phase 8; say so in its docstring. *(completed as `FrameOver.instIsRegularOfFields`)*
- [x] Add `abbrev TaskFrame.IsRegular (G : TaskFrame) : Prop := G.toFibre.IsRegular` plus `instance (G : TaskFrame) [h : G.toFibre.IsRegular] : G.IsRegular := h`. *(completed)*
- [x] Write the module docstring paragraph required by requirement (9), in `TaskFrame.lean` and nowhere else. *(completed — new module-header section "General frames and the regular class")*
- [x] Confirm structure eta survives. *(completed — both `example`s plus a class-delegation `example` land in the definitional-content section and elaborate)*
- [x] Full `--wfail` build plus test library. *(completed — 2780 jobs, guard exit 0, 0 `error:` lines; `git diff --name-only` over the library shows exactly `FormalSystem/Semantics/TaskFrame.lean`)*

**Deviation (altered)**: the same-named theorem re-exports (`FrameOver.comp`/`serial`/`limit`/
`saturation` at `[F.IsRegular]`) named in this phase's Goal **cannot** be declared while the
fields of the same names are still present — the names would collide. They land in Phase 8, in
the same edit that deletes the fields. Nothing is lost: with the fields present, `F.comp` already
resolves to the field, so consumer text is byte-identical either way, which is what the "zero
consumer edits" goal actually asks for.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the class, the blanket instance, the total-space delegation, the module docstring paragraph.

**Verification**:
- `lake build --wfail` green with **no file outside `TaskFrame.lean` modified** (`git diff --name-only` shows exactly one path).
- The two eta `example`s above typecheck.
- `grep -rn "^class IsRegular\|\bIsRegular\b" FormalSystem/Semantics/TaskFrame.lean` shows only namespaced occurrences.

---

### Phase 3: `Semantics/StateTopology.lean` [COMPLETED]

**Goal**: Land the neighbourhood topology as the sole `TopologicalSpace` instance on a general
frame's state space, the Limit characterisation, the derived separation instances on the regular
class, and the real-carrier bridge lemmas — all while the old fields are still present, so the
topology lands before any consumer churn.

**Tasks**:
- [x] Create `FormalSystem/Semantics/StateTopology.lean`, lifting `nbhdTopology`, `coneTopology` and `t1Space_nbhdTopology_iff_limit` from task 655's `NbhdTopology.lean` probe with their docstrings. *(completed — the whole probe lifted: both topologies, the closed-set and discreteness characterisations, `limit_eq_iff`, the cone-filter/`mkOfNhds` block, history continuity, the triangle condition, and `limit_of_t1Space_coneTopology`)*
- [x] Put `set_option warn.classDefReducibility false` at module scope with a comment recording why. *(completed)*
- [x] Add `instance FrameOver.stateTopology`. *(completed)*
- [x] Add `theorem FrameOver.t1Space_iff_limit` — on the **general** frame. *(completed; axioms = the standard three)*
- [x] Add the derived `T1Space` instance on the regular class and record that `R0Space` follows free. *(completed as `FrameOver.instT1SpaceOfRegular`, with an `example … := inferInstance` pinning the R0 claim rather than asserting it)*
- [x] Add `def FrameOver.coneTop` as a plain `def` with **no** instance. *(completed, with `coneTop_le_stateTopology`, `t1Space_coneTop` and `r0Space_coneTop` as the `app:topology-t1`/`app:topology-r0` frame-level forms)*
- [x] Lift the real-carrier bridge lemmas from task 655's `RealFrames.lean` probe. *(completed — `nbhdTopology_eq_real`, `coneTopology_eq_nbhdTopology_real`, `not_discreteTopology_real`, stated against the generic `nbhdTopology`/`coneTopology` rather than the probe's ℝ-specialised copies; the probe's named ℝ frames themselves belong to Phase 9)*
- [x] State history continuity with the order topology on `D` as **binders**, never a global instance. *(completed at both the bare-relation and the frame level)*
- [x] Do **not** add the module to `FormalSystem/Semantics.lean`. Regenerate the root with `lake exe mk_all --lib FormalSystem`. *(completed — `grep -c StateTopology FormalSystem/Semantics.lean` = 0; the root carries the import; `mk_all --check` exits 0)*
- [x] Full `--wfail` build plus test library; `#print axioms` on `FrameOver.t1Space_iff_limit` and the derived `T1Space` instance must return Mathlib's standard three only. *(completed — 2781 jobs green, 0 `error:` lines; `lean_verify` on both returns `[propext, Classical.choice, Quot.sound]`)*
- [x] *(carried over from Phase 1)* Rewrite `exists_uniform_radius_of_finite`'s "Status" paragraph, which claimed "no topology exists anywhere in this library". *(completed here, where the claim first became false; re-verified by a scoped `--wfail` build of `FormalSystem.Semantics.TaskFrame`, a docstring-only change that cannot affect dependents' elaboration)*

**Scope Hypothesis outcome**: asserted "roughly 40 new declarations". Actual: 40 `def`/`theorem`/
`instance` declarations in `StateTopology.lean` (625 lines). Within the asserted band; the Phase 10
C19 docstring budget needs no re-scoping.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts roughly 40 new declarations in `StateTopology.lean`,
lifted from task 655's 425-line `NbhdTopology.lean` and 206-line `RealFrames.lean` probes.
Confirm at implementation time by counting `^(def|theorem|instance|abbrev) ` in the new module
and comparing against the probe sources; if the real count diverges materially, re-budget the
C19 docstring sweep in Phase 10 accordingly.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology.lean` — **new**.
- `FormalSystem.lean` — regenerated, never hand-edited.

**Verification**:
- `lake build --wfail` green.
- `grep -n "StateTopology" FormalSystem/Semantics.lean` returns nothing (the import-weight lever holds).
- `grep -n "StateTopology" FormalSystem.lean` returns the generated import.
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `#print axioms FormalSystem.Semantics.FrameOver.t1Space_iff_limit` → `[propext, Classical.choice, Quot.sound]`.

---

### Phase 4: Validity chain — the `FrameClass.Sat` lever [COMPLETED]

**Goal**: Fix the meaning of validity across the coming strip, so that no soundness or
completeness theorem changes. This is the one place meaning could silently change.

**Tasks**:
- [x] Redefine `FrameClass.Sat`: `.Base F => F.IsRegular`; `.Dense F => F.IsRegular ∧ F.IsDense`; `.ZTime F => F.IsRegular ∧ F.IsZTime`; `.RTime F => F.IsRegular ∧ F.IsRTime`. Keep the `@[reducible]` attribute. *(completed; `FrameClass.Sat.anti`'s 16-case proof re-derived for the conjunctive shapes)*
- [x] Leave `Valid`, `ValidIn`, `ValidOnFrames`, `GenericValidIn`, `GenericValidOnFrames` **byte-identical**. *(completed for those five — `git diff` shows no change to any of their definition lines)* *(deviation: altered — `Valid.apply`/`GenericValid.apply` **must** gain `[F.IsRegular]`: they eliminate into a bare `∀ F`, which after the strip ranges over frames the hypothesis says nothing about. `SemanticConsequence.apply` likewise. See the extra bullet below.)*
- [x] Extend the `sat_intro` macro's `obtain` patterns. *(deviation: altered — the plan's "one component each" is unsafe: `Sat .Base` is now the four-field class `IsRegular`, and a bare `obtain ⟨_, _, _, _, _⟩` **matches it**, silently destroying the frame's regularity instance. The macro instead wraps the pre-split body in a regularity strip guarded by the type ascription `($h : _ ∧ _)`, which fails at `.Base` and degrades the whole macro to `skip`. Verified by direct elaboration at all four tag shapes before the edit.)*
- [x] Add `[F.IsRegular]` to `TaskFrame.not_validOn_bot` and `TaskFrame.hF_nonempty_of_frameAxioms`, and rewrite `not_validOn_bot`'s docstring. *(completed)*
- [x] Leave `TaskFrame.ValidOn` without a binder. *(completed — unchanged)*
- [x] Full `--wfail` build plus test library. *(completed — 2781 jobs, guard exit 0, 0 `error:` lines, 0 warnings)*

**Additional migrations this phase forced, all recorded in the summary's migration table:**

- `Valid.of_forall` / `GenericValid.of_forall` / `SemanticConsequence.of_forall` keep their **bare**
  `∀ F` hypothesis (the *sufficient* form, which every constraint-free axiom supplies), and a new
  `…of_forall_regular` sibling takes `∀ F [F.IsRegular]` (the *equivalent* form, for a soundness
  argument that reads a constraint off the frame). Adding the binder to `of_forall` itself was
  tried first and rejected: it would have forced an `intro F _ M τ t` edit at every propositional
  and modal soundness proof in the tree, for results that consume no constraint at all.
- `Valid.apply`, `GenericValid.apply`, `SemanticConsequence.apply`, `Validity.validOn_of_valid`
  and `Validity.valid_iff_forall_validOn` gain `[F.IsRegular]`. `valid_iff_forall_validOn`'s
  right-hand side would otherwise quantify over general frames and the biconditional would be
  false rather than content-free.
- `ValidComplete` and `ValidQTime` conjoin `F.IsRegular` into their frame predicates. They are
  `ValidOnFrames` at a bare frame property, bypassing `Sat` entirely, so the `Sat` lever alone
  does **not** reach them; without this they would have silently widened to the general Complete
  and ℚ-time frames, over which their soundness bridges are false.
- The `Th`/`Mod` correspondence polarity is relativised: `Semantics.validOnRel` becomes
  `F.IsRegular ∧ F.ValidOn φ`. Over general frames `Mod S` would contain frames with no world
  histories at all, which validate everything vacuously, and no order-defined class would be
  Galois-closed — `galoisClosed_sat_dense` would become false rather than merely unproved.
  `galoisClosed_of_indicator{,_iff}` gain the corresponding hypotheses, and
  `galoisClosed_isDiscrete` is restated at `{F | F.IsRegular ∧ F.IsDiscrete}`.
- `Indicator`'s three `validOn_*_iff` lemmas gain `[F.IsRegular]` (they build a world history via
  `hF_nonempty_of_frameAxioms`).
- `Metalogic.soundness{,_dense,_ztime,_rtime}`, `MinusLanguage.minus_soundness{,_dense,_ztime,_rtime}`,
  `plus_soundness_base`, `Deterministic.valid_iff_valid_deterministic`,
  `Independence.CValid`, and `Frames.FrameOver.translationProduct{,_taskRel,_sat}` gain
  `[F.IsRegular]`; every `trivial` discharging a `Sat .Base` slot becomes `inferInstance`, and
  every positional `Sat` witness at a constrained tag gains its regularity component.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/FrameClassValidity.lean` — the `Sat` table, `sat_intro` conjunctive branches.
- `FormalSystem/Semantics/Validity.lean` — `not_validOn_bot`, `hF_nonempty_of_frameAxioms`, docstrings.
- `FormalSystem/Semantics/ValidityLayer.lean` — expected unchanged; confirm.

**Verification**:
- `lake build --wfail` green over the full library **including** `Metalogic/` (soundness and completeness are the real test that meaning is preserved).
- `git diff FormalSystem/Semantics/ValidityLayer.lean` is empty, and the `Valid`/`ValidIn` definition lines in `Validity.lean` are unchanged.

---

### Phase 5: Migrate `Extension/` and Semantics-core consumers to the class [COMPLETED]

**Goal**: Add `[F.IsRegular]` binders where an axiom accessor is used under a universally
quantified frame, across `Extension/` and the `Semantics/` core, and land the two
generalize-then-derive pairs. Still green, because Phase 2's blanket instance is still present.

**Tasks**:
- [x] Re-derive the consumer grep and record the result. *(completed — see the Scope Hypothesis outcome below)*
- [x] Add `[F.IsRegular]` where the extension chain consumes a constraint. *(completed — the binders land on the general-frame derived theorems the chain goes through (`FrameOver.nullity`, `nullity_identity`, `reflection`, `forward_comp`, `interpolates`, `backward_comp`, `eq_of_taskRel_zero`, and their total-space re-exports) plus `PartialHistory.ofLe`; the `Extension/` modules themselves needed no edit, because every one of their accessor uses is already under a frame that reaches regularity through those.)*
- [x] Confirm `Step.lean`'s docstring claim that `F.saturation` applies "directly, with zero adaptation" stays true. *(completed — the re-exported theorem has the old field's type verbatim, and `Step.lean` is unchanged)*
- [x] Add `ShiftSet.rev_sep_of_limit` and derive `ShiftSet.rev_sep` from it at `[F.IsRegular]`. *(completed)*
- [x] Add `FrameOver.eq_of_taskRel_zero_of_limit` and derive `FrameOver.eq_of_taskRel_zero` from it. *(completed)*
- [x] Add binders to the remaining `Semantics/` consumers. *(completed — `ShiftSet.ofModel`/`reverse_repr`, `Correspondence/Rigidity.lean`'s four rigidity theorems, `Frames/TranslationProduct.lean`'s product, `PartialHistory.ofLe`)*
- [x] Re-site the frame **properties** requirement (5) names. *(completed — confirmed by inspection that `TaskFrame.Deterministic`, `ForwardDeterministic`, `Static`, `UniformDwell`, `saturation_of_deterministic` and the duration properties `IsDense`/`IsDiscrete`/`IsZTime`/`IsComplete`/`IsRTime`/`IsQTime` are all stated over `TaskRel` or `Duration` alone and are therefore already general-frame notions; only the four rigidity theorems that *consume* a constraint gained a binder)*
- [x] Full `--wfail` build plus test library. *(completed — 2781 jobs, guard exit 0)*

**Scope Hypothesis outcome**: asserted 26 files / 116 accessor occurrences outside
`TaskFrame.lean`, with 34 inside. Re-derived with the plan's own grep: **25 files / 63
occurrences outside, 34 inside (97 total)**, of which roughly half are prose in docstrings and
seven are `Function.comp`/`StrictMono.comp` false positives the filter does not catch. The real
code-site count outside `TaskFrame.lean` is **25**. The hypothesis was an over-estimate, so the
Phase 5/6 split needed no re-balancing; both phases were smaller than budgeted.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: the accessor surface is asserted here as **26 files / 116 occurrences**
outside `TaskFrame.lean`, with `TaskFrame.lean` itself at 34. Re-derive at implementation time
with `grep -rnE "\.(comp|serial|limit|saturation)\b" FormalSystem Tests --include=*.lean | grep -vE "Function\.comp"`
and record the per-file counts before editing; the heaviest are `TaskFrame.lean` (34),
`Extension/Step.lean` (8), `IntTransfer.lean` (6), `ShiftSet.lean` (5),
`Extension/PeriodicExtension.lean` (4), `OpenLanguage/OpenReversal.lean` (4). Note that the raw
grep carries `Function.comp` false positives; the filtered count is the hypothesis, and a
divergence of more than a few occurrences means the split between this phase and Phase 6 must be
re-balanced before editing.

**Files to modify**:
- `FormalSystem/Semantics/Extension/{Constraint,Admissible,Step,Extension,PeriodicExtension}.lean`
- `FormalSystem/Semantics/{FrameAxioms,IntTransfer,IntNormalForm,ShiftSet,TaskFrame}.lean`
- `FormalSystem/Semantics/Frames/TranslationProduct.lean`
- `FormalSystem/Semantics/Correspondence/{Rigidity,RigidityReal}.lean`
- `FormalSystem/Semantics.lean`

**Verification**:
- `lake build --wfail` green.
- `ShiftSet.rev_sep` and `FrameOver.eq_of_taskRel_zero` retain their exact original statements (check by `lean_hover_info` or `#check` against the pre-phase signature).
- No declaration outside the two generalize-then-derive pairs changed its statement.

---

### Phase 6: Migrate the remaining consumers [COMPLETED]

**Goal**: Add `[F.IsRegular]` binders to the `Metalogic/`, `OpenLanguage/`, `PlusLanguage/` and
test-library consumers. Still green against the blanket instance.

**Tasks**:
- [x] Migrate `OpenLanguage/OpenReversal.lean`, `PlusLanguage/PlusPasting.lean`. *(completed — `OpenReversal.lean`'s `FrameOver.rev` splits into a data `def` plus `FrameOver.rev_isRegular`; `PlusPasting.lean` needed no edit, its `F.comp` use being under a frame that reaches regularity through the class)*
- [x] Migrate the four `Metalogic/Expressiveness/Kamp/` modules. *(deviation: skipped — every `.comp` occurrence in all four is `StrictMono.comp`/`Function.Injective.comp`, a false positive of the accessor grep. Verified individually; no frame accessor appears in any of them.)*
- [x] Migrate `Metalogic/Decidability/Verified/Bridge/{RegionFrame,DenseTruth}.lean`, `Metalogic/Decidability/FMP/Filtration.lean`. *(completed — the constructor rename; their `.limit`/`.saturation` uses are at concrete `ofReflectiveRegular` frames and are served by the auto-instance)*
- [x] Migrate `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `.../RamseyFactorization.lean`, `Metalogic/Conservativity/Plus/Atomization.lean`, `Metalogic/Algebraic/FlowFrame.lean`. *(completed for `ReynoldsBridge` and `FlowFrame`; `RamseyFactorization` and `Atomization`'s hits are `StrictMono.comp`/`Function.Injective.comp` false positives and needed no edit)*
- [x] Sweep `Tests/BimodalTest/` for accessor uses and migrate them. *(completed — the re-derived grep finds no frame-accessor code site anywhere under `Tests/`; the test library builds green unchanged)*
- [x] Full `--wfail` build plus test library. *(completed — 2781 jobs, guard exit 0)*

**Scope Hypothesis outcome**: the Phase 5 grep's file set is fully covered by Phases 5 and 6; the
files it names that appear in neither list are exactly the seven `Function.comp`/`StrictMono.comp`
false positives enumerated above, each checked by hand.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that after Phase 5 no accessor site outside the files
listed above remains. Confirm by re-running the Phase 5 grep and diffing the file set against the
union of Phases 5 and 6; any file in the grep result that appears in neither list is an
unanticipated site and must be added here before the phase closes.

**Files to modify**: the files enumerated above, under `FormalSystem/Metalogic/`,
`FormalSystem/OpenLanguage/`, `FormalSystem/PlusLanguage/`, and `Tests/BimodalTest/`.

**Verification**:
- `lake build --wfail` green over the full library and test library.
- The Phase 5 grep's file set is fully covered by Phases 5 and 6.

---

### Phase 7: Migrate constructors to the regular spelling [COMPLETED]

**Goal**: Rename every construction site to the regular constructor and give every
literal-structure frame an explicit `IsRegular` instance, so that Phase 8's field deletion is a
pure removal. **The fields are still present through this phase**, so `ofReflectiveRegular` is
introduced here as a 7-argument alias of the current `ofReflective`, not yet as a wrapper around
a 3-argument general constructor.

**Tasks**:
- [x] Add `FrameOver.ofReflectiveRegular` with the **existing** 7-argument signature, defined as the current `ofReflective` body. *(completed — defined as `ofReflective W R hR hcomp hser hlim hsat`, i.e. delegating rather than duplicating the body, and deliberately **not** `@[reducible]` so that `instIsRegularOfReflective` has a rigid instance key)*
- [x] Rename every construction call site `ofReflective` → `ofReflectiveRegular` across the consumer files. *(completed; `ofReflectiveRegular_taskRel` / `_taskRel_eq` bridges added and the 17 bridge references renamed with them, since the regular constructor's non-reducibility means the `ofReflective` bridges no longer apply at a regular frame)*
- [x] For each of the five literal-structure frames, add an explicit `instance : ….IsRegular` beside the `def`. *(completed — `DriftFrame.fzeroFrame_isRegular`, `ForwardDeterministicFrame.fnFrameOver_isRegular`, `LimitClosureFrame.eFrameOver_isRegular`, `ShiftSet.fibre_isRegular`, `OpenReversal.FrameOver.rev_isRegular`; the field assignments stay in place until Phase 8)*
- [x] Full `--wfail` build plus test library. *(completed — 2781 jobs, guard exit 0)*
- [x] **Added here**: `FrameOver.instIsRegularOfReflective`, the auto-instance on `ofReflectiveRegular`, so that every renamed call site keeps `F.comp`/`F.serial`/`F.limit`/`F.saturation` working by synthesis with nothing else at the site changing.

**Scope Hypothesis outcome**: asserted 13 files / 37 `ofReflective` occurrences outside
`TaskFrame.lean` (20 construction sites, 17 bridge references) plus 24 inside, 61 total.
Re-derived before editing: **14 files / 37 occurrences outside** (20 construction sites, 17
bridge references) and 24 inside — 61 total, matching exactly. The fourteenth file is
`Semantics/ShiftSet.lean`, whose single occurrence is a docstring mention, not a call site.

**Deviation (process)**: Phases 5, 6 and 7 are committed together, in one commit from one green
tree. Their edits interleave inside the same files — `Semantics/IntTransfer.lean` carries a
Phase 5 binder and a Phase 7 constructor rename, `OpenLanguage/OpenReversal.lean` a Phase 6
migration and a Phase 7 instance — and git commits whole files, so a three-way split would have
had to either mis-attribute whole files or stage hunks. Each phase's checklist is discharged and
verified above; the committed tree is green under `--wfail` over `FormalSystem` and
`Tests/BimodalTest`.

**Method note**: the binder sites for Phases 5 and 6 were not guessed. Phase 2's blanket instance
makes every `[F.IsRegular]` binder redundant while it is present, so the compiler gives no signal.
The sites were enumerated by temporarily demoting the blanket instance to a plain theorem and
building: each `failed to synthesize F.IsRegular` error names exactly one declaration that needs
the binder. The instance was restored before committing, so the committed intermediate state is
the "alongside" state the process requirements ask for.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: asserted as **13 files outside `TaskFrame.lean`, 37 `ofReflective`
occurrences outside it** (of which 20 are construction sites and 17 are
`ofReflective_taskRel*` bridge references), plus 24 occurrences inside `TaskFrame.lean`, 61
total. Re-derive with `grep -rn 'ofReflective' FormalSystem Tests --include=*.lean` before
editing and record the split; note this supersedes the research report's "31 occurrences"
figure, which did not separate bridge references from construction sites. The five
literal-structure sites are confirmed by
`grep -rln "PosRel :=\|PosRel w" FormalSystem Tests --include=*.lean` (six hits, one of which is
`TaskFrame.lean` itself).

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — `ofReflectiveRegular`.
- `FormalSystem/Examples/TemporalStructures.lean`, `FormalSystem/Semantics/Frames/{Standard,TranslationProduct}.lean`, `FormalSystem/Semantics/Correspondence/{RigiditySharpness,RigidityReal}.lean`, `FormalSystem/Semantics/{IntTransfer,IntNormalForm,ShiftSet}.lean`, `FormalSystem/Metalogic/Independence/ClockFrame.lean`, `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`, `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`, `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`.
- `FormalSystem/Metalogic/Independence/{DriftFrame,LimitClosureFrame,ForwardDeterministicFrame}.lean`, `FormalSystem/OpenLanguage/OpenReversal.lean` — extracted lemmas plus explicit instances.

**Verification**:
- `lake build --wfail` green.
- `grep -rn '\bofReflective\b' FormalSystem Tests --include=*.lean | grep -v 'Semantics/TaskFrame.lean' | grep -v 'ofReflective_taskRel'` returns nothing.
- Every literal-structure frame has a named `IsRegular` instance.

---

### Phase 8: Retire the four fields [COMPLETED]

**Goal**: Delete `comp`/`serial`/`limit`/`saturation` from `FrameOver`, delete Phase 2's blanket
instance, and promote the constructors to their final form. This is the only phase where a missed
consumer surfaces, and by construction it surfaces as a build error, not a meaning change.

**Tasks**:
- [x] Take a durable, non-reverting checkpoint before starting. *(completed — `git-snapshot.sh 656 --no-revert`)*
- [x] Run a full `--wfail` build plus the test library **before** any edit, and record it green. *(completed — the Phases 5-7 boundary build, 2781 jobs, guard exit 0)*
- [x] Delete the four axiom fields from `structure FrameOver`, leaving `WorldState`, `[worldNonempty]`, `PosRel`. *(completed; the field docstrings' content now lives on the corresponding `FrameOver.IsRegular` fields and on the four re-export theorems, with the `def:frame#…` labels and verbatim phrases preserved)*
- [x] Delete the blanket `instance (F : FrameOver D) : F.IsRegular` from Phase 2. *(completed)*
- [x] Promote `FrameOver.comp`/`serial`/`limit`/`saturation` to theorems projecting out of `[h : F.IsRegular]`. *(completed; their types are unchanged, so every consumer site reads exactly as before)*
- [x] Redefine `FrameOver.ofReflective` as the 3-argument general constructor; redefine `ofReflectiveRegular` as `ofReflective W R hR` with the four proofs consumed by `FrameOver.instIsRegularOfReflective`. *(completed)* *(deviation: altered — **no deprecation alias is possible** for the 7-argument `ofReflective` spelling. The plan assumed the name could be aliased, but the general constructor *keeps* the name `ofReflective` with a new signature, so an alias would be a self-alias. A call site written against the old spelling now gets an arity error whose expected type names the three surviving arguments, and both constructors' docstrings name `ofReflectiveRegular` as the regular form. Requirement (4)'s "where Lean permits" is what governs here.)*
- [x] Remove the four field assignments from each of the five literal-structure frames. *(completed)*
- [x] Sweep every docstring so that no docstring still says the constraints are fields. *(completed — see Phase 10's C-check sweep for the residual prose in `docs/`)*
- [x] Full `--wfail` build plus test library **after** the edits. *(completed — 2781 jobs, guard exit 0, **0 `error:` lines and 0 `warning:` lines**)*

**The consumer cascade, measured.** Phase 8 took **32 build iterations** to converge. The
migration surface it exposed is larger than the accessor grep predicted, because the cascade runs
through the *derived* theorems rather than through the accessors: `FrameOver.nullity`,
`nullity_identity`, `reflection`, `forward_comp`, `interpolates`, `backward_comp` and
`eq_of_taskRel_zero` each gained `[F.IsRegular]`, and every declaration that reaches a frame
constraint through one of them gained it too. The final count is **59 files** touched across
`FormalSystem/` and `Tests/`.

**Three structural findings, none of them anticipated by the plan:**

1. **`variable {F : TaskFrame} [F.IsRegular]` is not usable.** Adding the instance to a section's
   `variable` line is the obvious way to cover a whole module, and it fails under `--wfail`:
   Lean's automatic section-variable inclusion pulls the instance into every declaration
   mentioning `F`, and `linter.unusedSectionVars` then reports each declaration that does not use
   it — dozens of fatal warnings. Every binder in this phase is therefore per-declaration.
2. **Instance synthesis does not see through a frame definition.** A frame defined as
   `def X := ofReflectiveRegular …` does not get `X.IsRegular` from
   `instIsRegularOfReflective`: instance search does not unfold `X`. Each named frame carries an
   explicit `instance X_isRegular : X.IsRegular := instIsRegularOfReflective _ _ _ _ _ _ _`,
   whose *term* elaboration does unfold `X` during unification. Twenty such instances were added.
   `@[reducible]` on the frame does not help and makes it worse: `ShiftSet.fibre` is reducible, so
   its key unfolds to a structure literal and even the sibling `ShiftSet.frame_isRegular` is
   unreachable from it — `rShift` and `F1` each needed their own.
3. **`FrameClass.Sat.isRegular` was added** (`Semantics/FrameClassValidity.lean`): every tag's
   `Sat` value carries regularity, and a consumer holding an anonymous `fc.Sat F` at an unknown
   tag needs to project it out uniformly. Several countermodel existentials
   (`countermodel_dense_enriched`, `countermodel_discrete`, `countermodel_discrete_reynolds_v2`,
   `countermodel_dedekind_dense`) gained an `IsRegular` component for the same reason.

**Timing**: 1.5 hours

**Depends on**: 7 (and, transitively through Phases 4-6, on Phase 3: the field deletion must land after the topology module exists)

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — field deletion, blanket-instance deletion, constructor promotion, auto-instance, deprecation alias.
- `FormalSystem/Metalogic/Independence/{DriftFrame,LimitClosureFrame,ForwardDeterministicFrame}.lean`, `FormalSystem/Semantics/ShiftSet.lean`, `FormalSystem/OpenLanguage/OpenReversal.lean` — remove field assignments.
- Any module surfaced by the build as a missed consumer.

**Verification**:
- `lake build --wfail` green over `FormalSystem` and `Tests/BimodalTest`.
- `structure FrameOver` has exactly three fields; `grep -A30 'structure FrameOver' FormalSystem/Semantics/TaskFrame.lean` shows no `comp`/`serial`/`limit`/`saturation` field.
- Zero `sorry`.
- `#print axioms` on the extension theorem matches the pre-refactor baseline.
- A general, non-regular frame is constructible: a scratch `example` building `ofReflective` with a relation violating Limit elaborates without an `IsRegular` obligation.

---

### Phase 9: `StateTopology/Counterexamples.lean` — the acceptance test [COMPLETED]

**Goal**: Land the frames the whole refactor exists to make expressible, as ordinary frames of
the general structure with the constraints they satisfy proved as separate facts. The four-state
funnel is the named acceptance test that the refactor achieved its purpose.

**Tasks**:
- [x] Create `FormalSystem/Semantics/StateTopology/Counterexamples.lean`, outside the `Semantics.lean` aggregator, reached only by the generated root. *(completed — `grep -c StateTopology FormalSystem/Semantics.lean` = 0; the root carries the import; C8 satisfied: `StateTopology.lean` sits beside `StateTopology/` and there is no `StateTopology/StateTopology.lean`)*
- [x] **The four-state funnel (acceptance test)**: lift task 655's `FourState.lean` probe. *(completed — `funnelFrame`, `funnel_serial`, `funnel_compositional`, `funnel_saturation`, `funnel_not_limit`, `funnel_t1Space_coneTopology`, plus `funnelRel_nbhdTopology_eq_top`, `funnel_not_t1Space`, `funnelRel_not_isOpen_cone`, `funnel_one_way_pair` and `funnel_not_continuous_coneTopology`; the module docstring records that it is deliberately not an `IsRegular` instance)* *(deviation: altered — built as a **literal structure**, not via the 3-argument `ofReflective`. `ofReflective` is a plain `def`, so `funnelFrame.WorldState` would reduce to `Fin 4` only at default transparency, and the funnel's proofs are `decide` calls and `Fin 4` numerals that need it at *reducible* transparency. This is the tree's own recorded convention, stated in `ofReflective`'s docstring. The reflection law is still proved (`funnelRel_reflection`) and is what `funnelFrame_taskRel_eq` rests on.)*
- [x] **Separation without Limit** *(completed as `funnel_sep_of_history`, with the four supporting history lemmas)*
- [x] **The two-origin half-line and the hedgehog**: lift from task 655's `TwoOrigins.lean` and `Hedgehog.lean` probes as general frames with Seriality, Compositionality and Limit proved as separate facts, *Saturation* explicitly not claimed. *(completed — `TwoOrigins.frame` with `frame_serial`/`frame_compositional`/`frame_limit`/`frame_t1Space`/`frame_not_t2Space`, and `Hedgehog.frame` with the same four plus `finalTopology_ne_nbhdTopology` and `not_continuous_coneTopology_history`. Both docstrings say *Saturation* is not claimed and why; neither is an `IsRegular` instance.)*
- [x] **The ℤ partition facts**: lift from task 655's `IntPartition.lean` probe. *(completed — `TaskFrame.cone_int_one`, `nbhdTopology_isOpen_iff_int`, `limit_int_iff`, `discreteTopology_nbhdTopology_int_iff`)*
- [x] **The rigidity sharpness witnesses** *(completed — confirmed statable as general frames: each is an `ofReflectiveRegular` frame carrying a named `IsRegular` instance, and what each refutes is an **order** hypothesis (density, Archimedean, finiteness) rather than a `def:frame` constraint, so no statement moved. `RigiditySharpness.lean`'s module docstring now records that the bare-relation workaround has become the architecture, and points at the Counterexamples module for witnesses that refute a constraint itself.)*
- [x] Never spell a frame carrier as the bare Mathlib type in a topological statement. *(completed, and the hazard bit: `funnelFrame` is `@[reducible]`, so `funnelFrame.WorldState` reduces to `Fin 4` and Mathlib's discrete `instTopologicalSpaceFin` outranks `FrameOver.stateTopology`. Every topological statement about a frame in this module names its topology explicitly with `@`, and `funnel_not_t1Space`'s docstring records why.)*
- [x] Regenerate the root with `lake exe mk_all --lib FormalSystem`. Full `--wfail` build plus test library. *(completed — 2782 jobs, guard exit 0, 0 `error:` and 0 `warning:` lines; `lean_verify` on `funnel_not_limit` and `funnel_t1Space_coneTopology` returns the standard three axioms)*

**Scope Hypothesis outcome**: asserted that task 655's four probes (1352 lines) "lift with only the
frame-layer wrapper added". **They did not.** Three adaptations were needed and are reported here
rather than absorbed:

1. The funnel's constraints had to be proved over the bare relation first and transported to the
   frame by `funnelFrame_taskRel_eq`, because `decide` cannot run on a goal mentioning
   `funnelFrame.WorldState` (a type containing the free variable `D`).
2. `funnelFrame` had to be a literal structure rather than an `ofReflective` application, for
   reducibility (see the deviation above).
3. Making it reducible then exposed `Fin 4`'s own Mathlib topology, so every topological statement
   about the frame names its topology explicitly.

None of this is new mathematics — each probe's *proofs* transferred verbatim — but the frame-layer
wrapper was not the only change, and the hypothesis is recorded as falsified.

**Deviation (process)**: the plan's Rollback/Contingency offered landing the funnel alone and
reporting the two-origin and hedgehog as a reasoned exclusion if the probes did not lift verbatim.
That trigger fired (see the Scope Hypothesis outcome), but the contingency was **not** taken: both
frames were landed in full, because the three adaptations above turned out to be mechanical rather
than mathematical. No exclusion is claimed for this phase.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that task 655's probes (`FourState.lean` 428 lines,
`Hedgehog.lean` 387, `IntPartition.lean` 142, `TwoOrigins.lean` 395 — 1352 lines of already
compiled, sorry-free material) lift with only the frame-layer wrapper added. Confirm at
implementation time by compiling each lifted section before assembling the module; any section
that does not lift verbatim is new mathematical work and must be reported rather than absorbed
silently.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — **new**.
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` — restatements, if any.
- `FormalSystem.lean` — regenerated.

**Verification**:
- `lake build --wfail` green; zero `sorry`.
- `funnel_not_limit` and `funnel_t1Space_coneTopology` both typecheck — **this pair is the acceptance test that the refactor achieved its purpose**.
- `#print axioms` on the funnel's constraint facts returns standard axioms only.
- `grep -n "Counterexamples" FormalSystem/Semantics.lean` returns nothing.
- No `IsRegular` instance exists for `funnelFrame`, the two-origin frame, or the hedgehog.

---

### Phase 10: Documentation, inventory and gates [IN PROGRESS]

**Goal**: Bring every generated artifact, document, index and invariant gate into agreement with
the refactored tree, and close the migration table.

**Tasks**:
- [ ] `lake exe mk_all --lib FormalSystem`, then confirm `lake exe mk_all --lib FormalSystem --check` exits 0. Never hand-edit `FormalSystem.lean`.
- [ ] `bash scripts/check-module-invariants.sh` — all checks pass. Regenerate the inventory block with `--emit-inventory`.
- [ ] C14: update every documented axiom/sorry count that moved, in `docs/`, `README.md` and Lean docstrings. Add C14 pins for the new headline declarations (`FrameOver.t1Space_iff_limit`, the funnel's constraint facts).
- [ ] `docs/theorem-index.md`: update the three `FrameOver` rows (166-168, the rigidity results) if their statements moved, and add rows for the new topology and counterexample headlines. Confirm every declaration named in the index resolves.
- [ ] C17 sweep: cite each new declaration that would otherwise read as dead — `coneTopology`, `FrameOver.coneTop`, and the counterexample lemmas that exist to be cited — from its module docstring or from `docs/theorem-index.md`.
- [ ] C19 sweep: confirm the 90% docstring-coverage floor holds over the two new modules.
- [ ] C29: confirm whether the check's scope covers `warn.*` as well as `linter.*`; if so, add the justification comment `StateTopology.lean`'s `set_option warn.classDefReducibility false` requires.
- [ ] Update `scripts/module-invariants-allowlist.txt` for any entry naming a retired `FrameOver` field.
- [ ] Update the prose that prints the six-field structure verbatim and is now wrong: `docs/reference/API_REFERENCE.md` (the `FrameOver` block), `docs/user-guide/architecture.md` (same), `docs/reference/paper-definitions-of-record.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`.
- [ ] Update `FormalSystem/Semantics/README.md` and `FormalSystem/Metalogic/README.md`.
- [ ] C9: confirm zero task-number citations outside `specs/` (`bash .claude/scripts/check-task-references.sh`).
- [ ] Write the final migration table into the implementation summary and check it against `git diff --stat` of the whole implementation.
- [ ] Final full `--wfail` build over `FormalSystem` and `Tests/BimodalTest`; `lean_verify` on the extension theorem, the funnel's constraint facts, and `FrameOver.t1Space_iff_limit`.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: the documentation surface is asserted as the seven files found by
`grep -rln "FrameOver\|PosRel\|worldNonempty" docs/ scripts/` (`docs/theorem-index.md`,
`docs/user-guide/architecture.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`,
`docs/reference/API_REFERENCE.md`, `docs/reference/paper-definitions-of-record.md`,
`scripts/module-invariants-allowlist.txt`, `scripts/check-module-invariants.sh`) plus the two
READMEs. Re-run that grep at implementation time; a file appearing in the result that is not in
this list must be added before the phase closes.

**Files to modify**:
- `FormalSystem.lean` (regenerated), `docs/theorem-index.md`, `docs/reference/API_REFERENCE.md`, `docs/reference/paper-definitions-of-record.md`, `docs/user-guide/architecture.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`, `scripts/module-invariants-allowlist.txt`, `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`.

**Verification**:
- `bash scripts/check-module-invariants.sh` — all C1-C29 pass.
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `lake build --wfail` green over `FormalSystem` and `Tests/BimodalTest`; zero `sorry`.
- Every declaration in `docs/theorem-index.md` resolves.
- The migration table in the summary is complete against `git diff --stat`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.StateTopology
import FormalSystem.Semantics.StateTopology.Counterexamples

namespace FormalSystem.Semantics

variable {D : TemporalOrder}

/-- The neighbourhood topology on a **general** frame's state space is T1 exactly when the
frame satisfies *Limit*. This is the characterisation the refactor exists to make statable:
`Limit` is a hypothesis about the frame, not a field of it. -/
theorem FrameOver.t1Space_iff_limit (F : FrameOver D) :
    T1Space F.WorldState ↔ TaskFrame.Limit F.TaskRel := sorry

/-- Injectivity at zero, at the constraint it actually uses: *Limit* alone, with no
*Seriality*, *Compositionality* or *Saturation*. `FrameOver.eq_of_taskRel_zero` is derived from
this at `[F.IsRegular]` and keeps its existing statement. -/
theorem FrameOver.eq_of_taskRel_zero_of_limit (F : FrameOver D)
    (hlim : TaskFrame.Limit F.TaskRel) {w u : F.WorldState}
    (h : F.TaskRel w 0 u) : w = u := sorry

/-- Separation of shift-related histories, at the constraint it actually uses: *Limit* alone,
per `rev_sep`'s own docstring. `ShiftSet.rev_sep` is derived from this and keeps its existing
statement; stating it this way is what makes separation-without-*Limit* expressible. -/
theorem ShiftSet.rev_sep_of_limit {F : TaskFrame}
    (hlim : TaskFrame.Limit F.TaskRel) (σ τ : WorldHistory F)
    (h : ∀ x : F.Duration, 0 < x → ∃ y : F.Duration, |y| < x ∧ τ = σ.timeShift y) :
    τ = σ := sorry

/-- The four-state funnel: a general task frame satisfying *Seriality*, *Compositionality* and
*Saturation* but **not** *Limit*. Deliberately not an `IsRegular` instance. -/
def StateTopology.funnelFrame [DenselyOrdered D] : FrameOver D := sorry

/-- *Limit* fails on the funnel. -/
theorem StateTopology.funnel_not_limit [DenselyOrdered D] :
    ¬ TaskFrame.Limit (StateTopology.funnelFrame (D := D)).TaskRel := sorry

/-- The cone topology on the funnel's state space is T1 **although** *Limit* fails — the
acceptance test that the refactor achieved its purpose, since neither this frame nor this
statement can be written down while the four constraints are structure fields. -/
theorem StateTopology.funnel_t1Space_coneTopology [DenselyOrdered D] :
    @T1Space (StateTopology.funnelFrame (D := D)).WorldState
      (FrameOver.coneTop (StateTopology.funnelFrame (D := D))) := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green with `--wfail` over `FormalSystem`, at every phase boundary, run detached with a bounded waiter.
- [ ] `Tests/BimodalTest` builds green at every phase boundary.
- [ ] Zero `sorry` in the tree (`check-module-invariants.sh` C3, asserted by content).
- [ ] `bash scripts/check-module-invariants.sh` — all checks pass (C1-C29).
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0.
- [ ] `lean_verify` on the extension theorem, the funnel's constraint facts, and `FrameOver.t1Space_iff_limit` returns standard axioms only, matching the pre-refactor baseline.
- [ ] Every declaration in `docs/theorem-index.md` resolves.
- [ ] Acceptance test: `StateTopology.funnel_not_limit` and `StateTopology.funnel_t1Space_coneTopology` both typecheck, and no `IsRegular` instance exists for `funnelFrame`.
- [ ] Meaning preservation: `git diff` shows no change to the definition lines of `Valid`, `ValidIn`, `ValidOnFrames`, `GenericValidIn`, `GenericValidOnFrames`.
- [ ] `grep -rn "as a structure field\|carries them as structure fields" FormalSystem/` returns no hit referring to a frame axiom.

## Artifacts & Outputs

- `FormalSystem/Semantics/StateTopology.lean` — new module: `nbhdTopology` instance on the general frame, `coneTopology` as a plain `def`, `Limit ↔ T1`, derived `T1Space`/`R0Space` on the regular class, real-carrier bridge lemmas.
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — new module: four-state funnel (acceptance test), separation-without-Limit, two-origin half-line, hedgehog, ℤ partition facts.
- `FormalSystem/Semantics/TaskFrame.lean` — three-field `FrameOver`, `class FrameOver.IsRegular`, theorem re-exports, `TaskFrame.Limit`, `ofReflective`/`ofReflectiveRegular` split plus auto-instance and deprecation alias, rewritten module docstring.
- Roughly 45-55 migrated Lean modules across `FormalSystem/` and `Tests/BimodalTest/`.
- `FormalSystem.lean` — regenerated by `mk_all`.
- Updated `docs/theorem-index.md`, `docs/reference/API_REFERENCE.md`, `docs/reference/paper-definitions-of-record.md`, `docs/user-guide/architecture.md`, `docs/development/PROPERTY_TESTING_GUIDE.md`, `scripts/module-invariants-allowlist.txt`, `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`.
- `specs/656_refactor_task_frames_general_with_frame_constraints/summaries/01_*-summary.md` — carrying the final migration table, checked against `git diff --stat`.

## Rollback/Contingency

The refactor is green at every phase boundary and each phase is committed on completion, so the
ordinary contingency is to stop at the last green phase: the tree is a consistent, buildable
intermediate state at every one of them, including the "alongside" states in Phases 2-7 where the
class and the fields coexist.

If a phase must be reverted mid-flight while uncommitted work exists, take the snapshot first and
then roll back — see `context/contracts/recovery.md`'s rollback rung for the exact invocation
shape, including its `--allow-out-of-scope` override for the deliberate whole-tree case. Do **not**
emit a bare reverting `git-snapshot.sh 656` as a routine start-of-phase precaution; Phase 8's
pre-phase checkpoint uses the durable, non-reverting `--no-revert` form instead.

Phase-specific contingencies:

- **Phase 8 fails to converge** (too many missed consumers surface at once): revert to the Phase 7
  commit, where the class and the fields coexist and the tree is green, and re-split the consumer
  migration across additional Phase 5/6-shaped passes before retrying the deletion. The alongside
  architecture is precisely what makes this retry cheap.
- **Phase 3's topology instance proves unworkable under `--wfail`** despite the probe: revert
  `StateTopology.lean`, leave a documented hook, and report the divergence from the ratified
  decision as a `user_decision` rather than silently downgrading to option (b).
- **Phase 9's lifted counterexamples do not lift verbatim**: land the four-state funnel alone (the
  named acceptance test, which needs no paper argument) and report the two-origin and hedgehog
  frames as a reasoned exclusion with evidence, rather than opening new mathematical work inside
  this refactor.
