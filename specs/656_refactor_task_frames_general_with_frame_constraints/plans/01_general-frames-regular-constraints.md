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

### Phase 4: Validity chain — the `FrameClass.Sat` lever [NOT STARTED]

**Goal**: Fix the meaning of validity across the coming strip, so that no soundness or
completeness theorem changes. This is the one place meaning could silently change.

**Tasks**:
- [ ] Redefine `FrameClass.Sat`: `.Base F => F.IsRegular`; `.Dense F => F.IsRegular ∧ F.IsDense`; `.ZTime F => F.IsRegular ∧ F.IsZTime`; `.RTime F => F.IsRegular ∧ F.IsRTime`. Keep the `@[reducible]` attribute — it is load-bearing, not decorative: it is what makes a bare `intro h` register the frame condition in the local instance cache.
- [ ] Leave `Valid`, `ValidIn`, `ValidOnFrames`, `GenericValidIn`, `GenericValidOnFrames`, `Valid.apply` and `Valid.of_forall` **byte-identical**. Confirm with `git diff` that no line in those definitions changed.
- [ ] Extend the `sat_intro` macro's `obtain` patterns for the three conjunctive tags by one component each. The `.Base` branch needs no change — verified in `probes/RegularClass.lean` that `G.comp` elaborates after a bare `intro h`.
- [ ] Add `[F.IsRegular]` to `TaskFrame.not_validOn_bot` and `TaskFrame.hF_nonempty_of_frameAxioms`. Rewrite `not_validOn_bot`'s docstring, whose claim that the axioms are "not arguments: `FrameOver` carries them as structure fields" becomes false — it must say they arrive through the class.
- [ ] Leave `TaskFrame.ValidOn` without a binder: it quantifies over `WorldHistory F`, which is general-frame data. Only the non-vacuity theorem needs the class.
- [ ] Full `--wfail` build plus test library.

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

### Phase 5: Migrate `Extension/` and Semantics-core consumers to the class [NOT STARTED]

**Goal**: Add `[F.IsRegular]` binders where an axiom accessor is used under a universally
quantified frame, across `Extension/` and the `Semantics/` core, and land the two
generalize-then-derive pairs. Still green, because Phase 2's blanket instance is still present.

**Tasks**:
- [ ] Re-derive the consumer grep and record the result in the phase's progress notes (see Scope Hypothesis).
- [ ] Add `[F.IsRegular]` to the extension chain: `Extension/Constraint.lean`, `Extension/Admissible.lean`, `Extension/Step.lean`, `Extension/Extension.lean`, `Extension/PeriodicExtension.lean`. Update the extension theorem's docstring to state the corrected constraint list (all four, with the per-site table from Research Integration above).
- [ ] Confirm `Step.lean`'s docstring claim that `F.saturation` is applied "directly, with zero adaptation" stays true — the re-exported theorem has the same type as the old field.
- [ ] Add `ShiftSet.rev_sep_of_limit` taking an explicit `TaskFrame.Limit F.TaskRel` hypothesis, and derive `ShiftSet.rev_sep` from it at `[F.IsRegular]`. Keep `rev_sep`'s name and statement. This is what makes separation-without-Limit statable in Phase 9.
- [ ] Add `FrameOver.eq_of_taskRel_zero_of_limit` taking an explicit Limit hypothesis, and derive `FrameOver.eq_of_taskRel_zero` from it. Its docstring already says it needs Limit alone.
- [ ] Add binders to the remaining `Semantics/` consumers: `FrameAxioms.lean`, `IntTransfer.lean`, `IntNormalForm.lean`, `ShiftSet.lean`, `Frames/TranslationProduct.lean`, `Correspondence/Rigidity.lean`, `Correspondence/RigidityReal.lean`, `Semantics.lean`.
- [ ] Re-site the frame **properties** requirement (5) names, confirming each is already stated over `TaskRel` alone and so needs no proof change: `TaskFrame.Deterministic`, `TaskFrame.ForwardDeterministic`, `TaskFrame.saturation_of_deterministic` (which *produces* a constraint — an `IsRegular` ingredient, not a consumer), `TaskFrame.Static`, `TaskFrame.UniformDwell`, `FrameOver.static_iff_uniformDwell`, `FrameOver.static_of_finite`, `FrameOver.static_of_countable`, and the duration properties `IsDense`/`IsDiscrete`/`IsZTime`/`IsComplete`/`IsRTime`/`IsQTime`. Where a declaration already lives on the general frame, record that in its docstring rather than editing it.
- [ ] Full `--wfail` build plus test library.

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

### Phase 6: Migrate the remaining consumers [NOT STARTED]

**Goal**: Add `[F.IsRegular]` binders to the `Metalogic/`, `OpenLanguage/`, `PlusLanguage/` and
test-library consumers. Still green against the blanket instance.

**Tasks**:
- [ ] Migrate `OpenLanguage/OpenReversal.lean`, `PlusLanguage/PlusPasting.lean`.
- [ ] Migrate `Metalogic/Expressiveness/Kamp/{LiftPair,ConjInterleave,ZetaUniformExtract,MonadicFormulaSubstitution}.lean`.
- [ ] Migrate `Metalogic/Decidability/Verified/Bridge/{RegionFrame,DenseTruth}.lean`, `Metalogic/Decidability/FMP/Filtration.lean`.
- [ ] Migrate `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`, `Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`, `Metalogic/Conservativity/Plus/Atomization.lean`, `Metalogic/Algebraic/FlowFrame.lean`.
- [ ] Sweep `Tests/BimodalTest/` for accessor uses and migrate them.
- [ ] Full `--wfail` build plus test library.

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

### Phase 7: Migrate constructors to the regular spelling [NOT STARTED]

**Goal**: Rename every construction site to the regular constructor and give every
literal-structure frame an explicit `IsRegular` instance, so that Phase 8's field deletion is a
pure removal. **The fields are still present through this phase**, so `ofReflectiveRegular` is
introduced here as a 7-argument alias of the current `ofReflective`, not yet as a wrapper around
a 3-argument general constructor.

**Tasks**:
- [ ] Add `FrameOver.ofReflectiveRegular` with the **existing** 7-argument signature, defined as the current `ofReflective` body. Underscore-prefix the four axiom arguments if they become unused (`_hcomp`, ...) or C16's `unusedArguments` linter fires.
- [ ] Rename every construction call site `ofReflective` → `ofReflectiveRegular` across the 13 consumer files. Leave `ofReflective_taskRel` / `ofReflective_taskRel_eq` bridge references alone for now; their extra arguments are implicit and they are renamed with the constructor in Phase 8 only if their names change.
- [ ] For each of the five literal-structure frames (`Metalogic/Independence/{DriftFrame,LimitClosureFrame,ForwardDeterministicFrame}.lean`, `Semantics/ShiftSet.lean`, `OpenLanguage/OpenReversal.lean`): extract the four axiom proofs into named lemmas and add an explicit `instance : ….IsRegular` beside the `def`, while leaving the four field assignments in place. Multiple instances of a `Prop`-valued class are harmless, so this coexists with Phase 2's blanket instance.
- [ ] Full `--wfail` build plus test library.

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

### Phase 8: Retire the four fields [NOT STARTED]

**Goal**: Delete `comp`/`serial`/`limit`/`saturation` from `FrameOver`, delete Phase 2's blanket
instance, and promote the constructors to their final form. This is the only phase where a missed
consumer surfaces, and by construction it surfaces as a build error, not a meaning change.

**Tasks**:
- [ ] Take a durable, non-reverting checkpoint before starting: `bash .claude/scripts/git-snapshot.sh 656 --no-revert`.
- [ ] Run a full `--wfail` build plus the test library **before** any edit, and record it green.
- [ ] Delete the four axiom fields from `structure FrameOver`, leaving `WorldState`, `[worldNonempty]`, `PosRel`. Move each field's docstring content onto the corresponding `IsRegular` field, preserving the `def:frame#…` label citations and verbatim phrases.
- [ ] Delete the blanket `instance (F : FrameOver D) : F.IsRegular` from Phase 2.
- [ ] Promote `FrameOver.comp`/`serial`/`limit`/`saturation` to their final form as theorems projecting out of `[h : F.IsRegular]`.
- [ ] Redefine `FrameOver.ofReflective` as the 3-argument general constructor (`W`, `[Nonempty W]`, `R`, `hR`); redefine `ofReflectiveRegular` as `ofReflective W R hR` with the four axiom proofs consumed by the auto-instance `FrameOver.instIsRegularOfReflective`, built from `TaskFrame.compositional_reflect_of_reflective`, `serial_reflect_of_reflective`, `limit_reflect_of_reflective`, `saturation_reflect_of_reflective`. Add the `@[deprecated FrameOver.ofReflectiveRegular (since := "…")] alias` for the 7-argument spelling.
- [ ] Remove the four field assignments from each of the five literal-structure frames; the explicit `IsRegular` instances added in Phase 7 now carry them.
- [ ] Sweep every docstring in every touched module so that **no docstring still says the constraints are fields** (requirement 8). `grep -rn "structure field\|carries them as structure fields\|as a field" FormalSystem/` and fix each hit that refers to an axiom.
- [ ] Full `--wfail` build plus test library **after** the edits.

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

### Phase 9: `StateTopology/Counterexamples.lean` — the acceptance test [NOT STARTED]

**Goal**: Land the frames the whole refactor exists to make expressible, as ordinary frames of
the general structure with the constraints they satisfy proved as separate facts. The four-state
funnel is the named acceptance test that the refactor achieved its purpose.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/StateTopology/Counterexamples.lean`, outside the `Semantics.lean` aggregator, reached only by the generated root. Confirm the aggregator convention C8 is satisfied (`StateTopology.lean` sits beside `StateTopology/`, and there is no `StateTopology/StateTopology.lean`).
- [ ] **The four-state funnel (acceptance test)**: lift task 655's `FourState.lean` probe. Build `funnelFrame` as a general `FrameOver D` over `Fin 4` via the 3-argument `ofReflective`. Prove Seriality, Compositionality and Saturation as separate facts (Saturation via `TaskFrame.saturation_of_finite`, which needs a `Finite` instance in scope; `Finite Bool` requires `Mathlib.Data.Finite.Prod` at this import set). Prove `funnel_not_limit : ¬ TaskFrame.Limit funnelFrame.TaskRel`. Prove `funnel_t1Space_coneTopology`: the cone topology on the funnel's state space is T1 **while Limit fails** — the exact witness the task names. Record in the module docstring that the funnel is deliberately **not** an `IsRegular` instance.
- [ ] **Separation without Limit**: instantiate `ShiftSet.rev_sep_of_limit`'s contrapositive shape at the funnel — separation holds on it (task 655's `R4_sep`) although Limit does not — and state it as a named fact.
- [ ] **The two-origin half-line and the hedgehog**: lift from task 655's `TwoOrigins.lean` and `Hedgehog.lean` probes as general frames with Seriality, Compositionality and Limit proved as separate facts. **Saturation is explicitly not claimed**; each docstring must say so and say why (the paper "shadow map" argument is not yet a Lean proof). Both carriers are `ℝ`-based, so `noncomputable def` is required, as is the `TemporalOrder.of Real` abbreviation.
- [ ] **The ℤ partition facts**: lift from task 655's `IntPartition.lean` probe.
- [ ] **The rigidity sharpness witnesses**: confirm `Correspondence/RigiditySharpness.lean`'s witnesses are now statable as general frames with their satisfied constraints proved separately; restate any that were previously forced through the bare-relation workaround, and record in the module docstring that the workaround has become the architecture.
- [ ] Never spell a frame carrier as the bare Mathlib type in a topological statement; use the bridge lemmas from Phase 3 at every real-carrier site.
- [ ] Regenerate the root with `lake exe mk_all --lib FormalSystem`. Full `--wfail` build plus test library.

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

### Phase 10: Documentation, inventory and gates [NOT STARTED]

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
