# Implementation Plan: Task #512

- **Task**: 512 - bundle_duration_into_taskframe
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours
- **Dependencies**: None blocking. Sequencing interaction with task 507 (Dedekind -> Complete
  rename in `Semantics/Validity.lean`); the batch sequences 512 strictly before 507, so the two
  never run concurrently. Partition of ownership: **512 owns binder lists, 507 owns names.**
- **Research Inputs**: `specs/512_bundle_duration_into_taskframe/reports/01_bundle-duration-into-taskframe.md`
  (verified; probe files `reports/{01,02,03}_probes.lean` all green at commit `3365859e2`)
- **Artifacts**: plans/01_bundle-duration-into-taskframe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Make the duration type a **field** of `TaskFrame` rather than a **parameter**, so that a frame
carries its own temporal structure and every frame-class notion (`Dense`, `Discrete`, `Complete`)
becomes a genuine property of a frame. This is a **restatement refactor**: no theorem's
mathematical content changes, and any semantic drift is a defect. Scope is 81 live `.lean` files,
183 `TaskFrame D` occurrences and 208 `D`-binder sites; the migration proceeds layer by layer
behind a definitional bridge, with `lake build` green and a commit at every phase boundary.

Definition of done: target shape landed, `ParamTaskFrame` bridge deleted, sorry-free,
`lake build` exits 0, `bash scripts/check-module-invariants.sh` passes, and the four C2 flagship
axiom profiles are byte-identical to the recorded baseline.

### Target shape (frozen for this task)

```lean
structure TaskFrame where
  Duration : Type
  [addCommGroup : AddCommGroup Duration]
  [linearOrder : LinearOrder Duration]
  [orderedAddMonoid : IsOrderedAddMonoid Duration]
  [nontrivial : Nontrivial Duration]
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState -> Duration -> WorldState -> Prop
  comp : ...
  converse : ...
  serial : ...
  limit : ...
  spherical : ...
  nullity_identity : ...
```

`Duration : Type` and `WorldState : Type` — no universe polymorphism (research F2; bundled
`TaskFrame` is `Type 1`, exactly what `TaskFrame D` is today). The field set is **frozen**: the
`nullity_identity` field is retained, and any field-set change is a separate task (research
Decision 5).

### Migration Mechanism (load-bearing; read before Phase 1)

The migration rests on research finding F3: `ofParam`/`toParam` round-trip by `rfl` in **both**
directions via structure eta, and `(ofParam F).Duration = D` is `rfl`. This makes a rename-and-
shadow migration possible:

1. Phase 1 renames the current structure to `ParamTaskFrame` tree-wide and declares the bundled
   `TaskFrame` beside it, with `ofParam` / `toParam` bridging the two.
2. Phases 2-12 migrate one import layer at a time. Each phase converts its files' binder lists
   from `{D} [4 binders] (F : ParamTaskFrame D)` to `(F : TaskFrame)`.
3. Not-yet-migrated call sites of an already-migrated definition are held green by a
   **transitional compatibility mechanism** (below). Every such shim is removed by the phase that
   migrates its file; the count of surviving shims is the migration progress meter and MUST reach
   zero at Phase 13.
4. Phase 13 deletes `ParamTaskFrame`, `ofParam`, `toParam`, and any residual shim.

**Transitional compatibility mechanism — decision ladder, resolved in Phase 1:**

- **(a) Coercion (preferred if it works).** Declare
  `instance : CoeOut (ParamTaskFrame D) TaskFrame := ⟨ofParam⟩` and probe whether Lean inserts it
  at explicit-argument positions (`WorldHistory F` where `F : ParamTaskFrame D`). If it fires,
  unmigrated call sites need **no edit at all** and each downstream file is touched exactly once.
- **(b) Mechanical `ofParam` insertion (fallback).** Rewrite unmigrated call sites to
  `WorldHistory (TaskFrame.ofParam F)` by `sed`, removing each insertion when its file migrates.
  Costs one extra mechanical touch per downstream file.

(a) is a **hypothesis**, not a fact — Phase 1 probes it and records the outcome in the phase
commit message before any downstream phase starts. Whichever is chosen, `ofParam` MUST be
declared `@[reducible]` (or as an `abbrev`): research F4/M2/M3 show a non-reducible `def` in the
chain stalls typeclass synthesis at reducible transparency, which would manufacture a transitional
instance diamond (`(ofParam F).addCommGroup` not syntactically the ambient `[AddCommGroup D]`
binder). Confirm reducibility with a probe in Phase 1.

### Research Integration

Findings driving this plan, all from the verified report:

- **F1/F2** — target shape elaborates verbatim; instance-implicit fields are in scope for later
  fields' types, so the axiom fields keep their definitional content and `TaskFrame.lean`'s
  definitional-content `example`s (`:1501-1511`, load-bearing for the Step Lemma) survive.
  `Type 1` before and after: no universe decision.
- **F3** — the bridge is a definitional isomorphism; incremental migration, not big-bang. This is
  the single most consequential planning fact and it shapes Phases 1-13.
- **F4 — THE HAZARD.** At a concrete ℤ-carried frame, `F.Duration = Int` is `rfl` at default
  transparency, but typeclass synthesis runs at *reducible* transparency: the numeral `1` cannot
  elaborate at `F.Duration` and `omega` cannot see the type at all. Working idiom (probe R4/R9):
  **state concrete-frame lemmas with explicit `(d : Int)` binders; discharge arithmetic at `Int`
  outside the frame application.** Abstract frames are entirely unaffected — all metatheory
  quantifying `∀ F : TaskFrame` is untouched. This idiom is the stated contract of Phases 5-7.
- **F5** — only 27 concrete frame values in live code (+4 in Tests, +2 dead in Boneyard). The
  hazard surface is small and enumerable.
- **F6** — 225 binder-bearing `AddCommGroup` occurrences in 30 shapes; the canonical 4-binder
  shape is 51% of them. Frame-class side conditions become either `haveI`-introduced Prop
  hypotheses on the frame (preferred, probe R7) or instance binders on the statement (R6).
- **F9** — `FrameConditionFor` / `TemporalCarrier` at `Bridge/Carrier.lean:110,126` is **already**
  the FrameClass-indexed carrier-condition abstraction. Reuse it; do not invent a parallel `Sat`.
- **F10** — verification gates: C1 build, C2 axiom profiles (hard stop, checked **per phase**),
  C3 zero sorry, C14 documented counts, C15 paper anchors. C9 additionally forbids task-number
  citations under `FormalSystem/` — no "task 512" in any Lean docstring.

**Adjacent findings deliberately NOT folded in** (research F8, Recommendation 8): the
`TemporalOrder` Prop-mixin (collapses the 4-binder list to 3; verified diamond-free) and the H1
collapse of the 15 `Valid*` predicates onto `FrameConditionFor`-indexed definitions. Both are
enabled by this refactor and both are separate tasks. Folding either in doubles the review
surface of every diff in this plan.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap consultation was
performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `TaskFrame` and `FiniteTaskFrame` carry `Duration` as a field, in the exact target shape above.
- All 81 live `.lean` files migrated; `ParamTaskFrame` and the bridge deleted.
- Frame-class notions (`Dense`, `Discrete`, `Complete`) statable as predicates on a frame.
- `FormalSystem/FrameConditions/Validity.lean`'s orphaned `ValidOver` **deleted** (subsumed by
  bundled `TaskFrame.ValidOn`).
- Sorry-free; `lake build` green; `check-module-invariants.sh` passing; C2 axiom profiles
  unchanged on all four flagship theorems.
- `TaskFrame.lean` module docstring records that `D`-as-a-field is `def:frame` conformance.

**Non-Goals**:
- No change to any theorem's mathematical content. This is a restatement.
- No `TemporalOrder` mixin (separate task).
- No H1 collapse of `Valid*` / `SetSemanticConsequence*` / soundness (separate task).
- No field-set change: `nullity_identity` stays.
- No universe polymorphism.
- No porting of the two dead Boneyard frames (`SuccChainTaskFrame.lean:95`,
  `CanonicalConstruction.lean:267`); they do not elaborate today either.
- No renaming of `Dedekind` -> `Complete`; that is task 507's territory.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `OfNat`/`omega` failure at concrete ℤ frames burns a whole dispatch | H | H if unanticipated | F4 is fully characterised with green probe evidence. Phases 5-7 carry the `(d : Int)` idiom as an explicit phase contract, stated before any edit. |
| Semantic drift — a "restatement" that quietly changes a theorem | H | M | C2 axiom-profile check **every phase**, not only at the end. Bridge round-trip being `rfl` makes drift a typechecking failure, not a silent one. Any proof that needs a *new* lemma to close is a drift signal: stop and report. |
| Transitional instance diamond at shim sites | M | M | Declare `ofParam` `@[reducible]`; Phase 1 probes that `(ofParam F).addCommGroup` reduces to the ambient binder instance at reducible transparency. Fallback: per-site `haveI` normalization. |
| Coercion mechanism (a) does not fire; churn doubles | M | M | Fallback (b) is fully mechanical (`sed`) and pre-specified. Phase 1 resolves the ladder before any downstream phase starts; the choice is recorded in the Phase 1 commit. |
| A phase ends red and blocks the chain | H | M | Never let a phase end red. Phase-level rollback is `git revert` of that phase's commits only; all prior phases stay green (see Rollback). |
| Phase 1's tree-wide rename over-reaches (renames the predicate namespace) | M | H | Accepted and planned: the token rename carries `TaskFrame.Compositional` etc. to `ParamTaskFrame.*`. Phase 13 renames the predicate namespace back. Recorded explicitly so it is not mistaken for breakage. |
| 507's `Dedekind -> Complete` rename collides in `Validity.lean` | M | L | Batch sequences 512 strictly before 507. Ownership partition stated in metadata: 512 owns binders, 507 owns names. Do not rename `Dedekind` in this task. |
| Boneyard files break | L | Certain | Not built (`roots := #[FormalSystem]`, and 2 already fail to elaborate). Exclude `FormalSystem/Boneyard/` from every rename; C11 waivers cover dangling imports. |
| New files disturb the aggregator convention (C4-C8) | L | L | Keep the bundled structure and bridge **inside** `FormalSystem/Semantics/TaskFrame.lean`. Add no new modules. |
| Build times regress from instance-projection synthesis | L | L | Record `lake build` wall time in each phase's commit; investigate if it grows >25% over the Phase 1 baseline. |

## Standing Per-Phase Contract

Applies to every phase below; not restated per phase.

1. `lake build` exits 0 at the phase boundary. No phase ends red.
2. `bash scripts/check-module-invariants.sh` passes (use `--no-build` for fast intra-phase
   structural passes; the full run is required at the boundary).
3. Zero `sorry`. The zero-debt gate applies: no phase may land a `sorry`, strategic or otherwise.
4. C2 axiom profiles for the four flagship theorems unchanged — verified **this phase**, not
   deferred to the end.
5. Commit at the boundary: `task 512 phase {P}: {name}`, plus per-green-substep commits within
   the phase (except where `Commit Mode: atomic-batch` is declared).
6. No task-number citations in any file under `FormalSystem/` (C9).
7. `FormalSystem/Boneyard/` is excluded from every edit.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 8 | 4 |
| 6 | 6, 7 | 5 |
| 7 | 9 | 7, 8 |
| 8 | 10 | 6, 9 |
| 9 | 11 | 9, 10 |
| 10 | 12 | 11 |
| 11 | 13 | 12 |

Phases within the same wave can execute in parallel — they are file-disjoint (wave 5: ℤ machinery
vs. abstract soundness; wave 6: decidability-side vs. canonical-side ℤ code). Parallel execution
requires a territory contract naming the file sets, and a serialized `lake build`. Sequential
execution in the listed order is the default and is always safe.

---

### Phase 1: Rename to ParamTaskFrame, declare bundled TaskFrame, establish the bridge [COMPLETED]

**Goal**: The bundled `TaskFrame` exists in the target shape beside the renamed
`ParamTaskFrame`, the bridge round-trips by `rfl`, the transitional compatibility mechanism is
chosen and probed, and the tree is green with zero behavioural change.

**Tasks**:
- [x] Mechanically rename the token `TaskFrame` -> `ParamTaskFrame` and `FiniteTaskFrame` ->
      `ParamFiniteTaskFrame` across all live `.lean` files (81 files), **excluding**
      `FormalSystem/Boneyard/`. The rename carries the predicate namespace
      (`TaskFrame.Compositional`, `.Converse`, `.Serial`, `.Limit`, `.Spherical`,
      `.NullityIdentity`) to `ParamTaskFrame.*`; this is intended and is reversed in Phase 13.
- [x] *(deviation: added — three mechanical steps the phase did not anticipate, all forced by the
      rename rather than optional: (i) `import FormalSystem.Semantics.ParamTaskFrame` and
      `Semantics/TaskFrame.lean` path references were rewritten back, since the module path is
      unchanged; (ii) the `extends` parent projection `FiniteTaskFrame.toTaskFrame` became
      `ParamFiniteTaskFrame.toParamTaskFrame`, updated at its 5 structure-projection sites and at
      no user-defined `toTaskFrame` site; (iii) all 95 `D : Type*` binder sites were demoted to
      `D : Type`, without which the `CoeOut` cannot fire across the universe boundary.)*
- [x] In `FormalSystem/Semantics/TaskFrame.lean`, declare the bundled `structure TaskFrame` in the
      target shape (Overview), with `Duration : Type`, `WorldState : Type`, the four
      instance-implicit algebra fields, `worldNonempty`, `TaskRel`, and the six axiom fields
      citing the (now `ParamTaskFrame.`-namespaced) bare-relation predicates definitionally.
- [x] Declare bundled `structure FiniteTaskFrame` correspondingly (probe M8 confirms the shape).
- [x] Emit `attribute [instance] TaskFrame.addCommGroup TaskFrame.linearOrder
      TaskFrame.orderedAddMonoid TaskFrame.nontrivial TaskFrame.worldNonempty`.
- [x] Declare `@[reducible] def TaskFrame.ofParam` and `def TaskFrame.toParam`; prove both round
      trips by `rfl` and `(ofParam F).Duration = D` by `rfl` as in-file `example`s.
- [x] Resolve the transitional-compatibility decision ladder: probe option (a) `CoeOut`; if it
      fires at explicit-argument positions, adopt it; otherwise adopt (b). Record the outcome in
      the phase commit message.
      *(outcome: **option (a) adopted**. `CoeOut (ParamTaskFrame D) TaskFrame` fires at explicit
      argument positions of plain `def`s, of structure parameters, and with dependent following
      arguments; `(ofParam F).addCommGroup = inferInstance` closes by `rfl` at reducible
      transparency. Shim ledger is therefore empty by construction. One extra mechanical step was
      required and is recorded as a deviation below: the coercion cannot cross a universe
      boundary, so the 95 `D : Type*` binder sites were demoted to `D : Type` — which is the
      target shape's own choice (research F2), not a workaround.)*
- [x] Probe that `(TaskFrame.ofParam F).addCommGroup` unifies with the ambient `[AddCommGroup D]`
      binder at reducible transparency. If not, record `haveI` normalization as the per-site
      fallback.
- [x] Add the four definitional-content `example`s for the **bundled** form, mirroring
      `TaskFrame.lean:1501-1511`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 81 live files carry the `TaskFrame` token (183 `TaskFrame D` occurrences,
12 `variable` lines, 80 `(D := …)` named-argument sites). Confirm at implementation time with
`grep -rl "TaskFrame" FormalSystem Tests --include=*.lean | grep -v Boneyard | wc -l` before the
rename and `grep -rc "\bTaskFrame\b"` after, and reconcile any discrepancy before proceeding. The
`CoeOut` coercion firing at argument positions is a hypothesis, confirmed or refuted by the probe
above; the fallback is pre-specified.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — rename structure, add bundled structure + bridge +
  `attribute [instance]` block + definitional-content examples
- All 80 other live files mentioning `TaskFrame` — mechanical token rename only

**Verification**:
- Standing contract (1-7).
- `git diff --stat` shows only token renames outside `TaskFrame.lean`.
- The bridge `example`s close by `rfl`.
- `grep -rn "\bTaskFrame\b" FormalSystem Tests --include=*.lean | grep -v Boneyard` returns only
  `TaskFrame.lean`'s new declarations (the bundled surface) and nothing else.

---

### Phase 2: Semantics core structures [COMPLETED]

**Goal**: `PartialHistory`, `WorldHistory`, `TaskModel`, `Truth`, `FrameAxioms` take
`(F : TaskFrame)` natively (probe M7 confirms all three structures re-parameterize natively).

**Tasks**:
- [x] Migrate `PartialHistory.lean` (`structure PartialHistory` `:91`) and
      `PartialHistoryOrder.lean`.
- [x] Migrate `WorldHistory.lean` (`structure WorldHistory` `:100`) *(deviation: altered — the
      `ParamTaskFrame.HF` subtype at the end of the file is deliberately LEFT parameterized and
      migrates with `Extension/`/`ShiftSet.lean` in Phase 4. Dot notation `F.HF` resolves by the
      head constant of `F`'s type and does NOT go through the `CoeOut`, so migrating `HF` alone
      breaks every unmigrated `F.HF` site; leaving it parameterized costs nothing because
      `WorldHistory F` inside it coerces.)*
- [x] Migrate `TaskModel.lean` (`structure TaskModel` `:49`) *(deviation: altered — `FiniteTaskModel`
      is left over `ParamFiniteTaskFrame`; it migrates with the finite-frame constructions in
      Phase 6.)*
- [x] Migrate `Truth.lean` (`def TruthAt` `:163`).
- [x] Migrate `FrameAxioms.lean` (32 occurrences) *(deviation: altered — only the
      `namespace PartialHistory` half migrates; the `namespace ParamTaskFrame` half is bare-relation
      apparatus with no frame binder and is untouched until Phase 13.)*
- [x] Apply the Phase-1 compatibility mechanism at every unmigrated downstream call site so the
      tree stays green; if mechanism (b), record the shim count. *(Mechanism (a): zero call-site
      edits were needed across all 75 unmigrated files. Three files needed an unrelated kind of
      edit — see the F4 note below — and no shim was introduced anywhere.)*
- [x] *(deviation: added — the F4 hazard bites one phase earlier than the plan expected. Migrating
      `TruthAt` moves the order relation on a ℤ-carried frame's times from `Int.instLT` to the
      bundled frame's own projection instance, which `omega` does not recognize even though the
      two are defeq. Three ℤ-facing files (`BiLasso/Unfold.lean`, `BiLasso/TruthLemma.lean`,
      `Extension/PeriodicExtension.lean`) needed the F4 idiom applied now rather than in their own
      phase. The working form is `@LT.lt ℤ _ a b` / `@LE.le ℤ _ a b` written explicitly: a plain
      `(t : ℤ) < s` ascription is a no-op whenever `t` is itself frame-typed, so it silently
      re-elaborates at the frame type and does not help. No mathematical content changed — every
      restatement is an identity accepted by `defeq`.)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: 6 files migrated; ~73 `TaskFrame` occurrences within them. Downstream
call-site surface is 55 files mentioning `WorldHistory`, 47 `TaskModel`, 68 `TruthAt` — under
mechanism (a) these need no edit; confirm by building without touching them. Under mechanism (b),
enumerate the shim sites and record the count as the starting value of the shim ledger.

**Files to modify**:
- `FormalSystem/Semantics/{PartialHistory,PartialHistoryOrder,WorldHistory,TaskModel,Truth,FrameAxioms}.lean`

**Verification**:
- Standing contract (1-7).
- No `sorry`, no `admit`, no new lemma introduced to close a previously-closing proof.
- Shim ledger recorded in the commit message (mechanism (b) only).

---

### Phase 3: Validity and the BL layer [NOT STARTED]

**Goal**: The five `Valid*` predicates and `TaskFrame.ValidOn` are stated over bundled frames;
`valid_iff_forall_validOn` still ties the two notions.

**Tasks**:
- [ ] Migrate `Semantics/Validity.lean`: `valid` (`:94`), the `Valid*` predicates
      (`:94,206,248,301,336`) become `∀ F : TaskFrame, C F -> …`; `TaskFrame.ValidOn` (`:561`)
      loses its binder list entirely.
- [ ] Preserve `valid_iff_forall_validOn` (`:622`) as the tie between the two notions — statement
      shape may change, content may not.
- [ ] Introduce frame-class side conditions as `haveI`-introduced Prop hypotheses on the frame
      (probe R7) rather than statement-level instance binders wherever the condition will later
      be an arm of a `FrameConditionFor` match.
- [ ] Migrate `BLValidity.lean`, `BLTruth.lean`, `DurationClassification.lean`.
- [ ] Do **not** rename `Dedekind`; that is 507's territory.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: 4 files, ~34 `TaskFrame` occurrences, 5 `Valid*` predicates. Confirm the
predicate count with `grep -n "^def Valid\|^theorem valid" FormalSystem/Semantics/Validity.lean`
before editing; if more than five surface, report rather than silently widening the phase.

**Files to modify**:
- `FormalSystem/Semantics/{Validity,BLValidity,BLTruth,DurationClassification}.lean`

**Verification**:
- Standing contract (1-7).
- `valid_iff_forall_validOn` closes with the same proof term shape (no new lemmas).
- No `Dedekind` identifier renamed anywhere in the diff.

---

### Phase 4: Extension layer and ShiftSet [COMPLETED WITH EXCLUSIONS]

**Goal**: `Semantics/Extension/` and `ShiftSet.lean` on bundled frames, with the Step Lemma's
consumption of `F.spherical` remaining **definitional**.

**Tasks**:
- [x] Migrate `Extension/{Admissible,Constraint,Extension,Step}.lean` *(deviation: altered —
      `PeriodicExtension.lean` is excluded; see Reasoned Exclusions below.)*
- [x] Verify the Step Lemma still consumes `F.spherical` definitionally (this is what the
      bundled definitional-content `example`s from Phase 1 protect); if it does not, stop and
      report — that is drift, not a proof-engineering problem to work around. *(It does:
      `PartialHistory.step` elaborates unchanged over `(F : TaskFrame)`, and the bundled
      definitional-content `example`s in `TaskFrame.lean` close by `rfl`.)*
- [x] Migrate `ShiftSet.lean` (including `ShiftSet.frame`, one of the 27 concrete frame values —
      duration is a type variable here, so F4 does not apply). *(deviation: altered — the plan's
      "F4 does not apply" is right about instance synthesis but wrong about `rw`: `hist`'s
      `respects_task` proof rewrites under `S.frame.Duration`, which a plain `def` does not
      unfold. `ShiftSet.frame` is now `@[reducible]`, which is the same mechanism the phase
      contract already prescribes for concrete frame constants. `ShiftSet` itself stays
      parameterized by a duration **type** — it is a carrier-level structure, not a frame — so
      only its frame-facing lemmas took `F.Duration`.)*

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: 6 files, ~92 `TaskFrame` occurrences. `ShiftSet.frame` is asserted to be
type-variable-carried (research F5 table); confirm by reading its definition before applying any
F4 idiom.

**Files to modify**:
- `FormalSystem/Semantics/Extension/{Admissible,Constraint,Extension,PeriodicExtension,Step}.lean`
- `FormalSystem/Semantics/ShiftSet.lean`

**Verification**:
- Standing contract (1-7). `lake build` exits 0; `check-module-invariants.sh` ALL CHECKS PASSED.
- Step Lemma proof unchanged in content; `F.spherical` used definitionally.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `Semantics/Extension/PeriodicExtension.lean` | The file is ℤ-specific, not abstract: it consumes `IntNormalForm`'s `HFofStepPath`/`IsStepPath`/`step`, every one of which is stated over `ParamTaskFrame ℤ` and is Phase 5 territory. Migrating its binders to `(F : TaskFrame)` makes those applications ill-typed, because the coercion only runs parameterized -> bundled. It migrates with `IntNormalForm.lean` in Phase 5. | Reverted to its Phase-2 state and left green; `lake build` and C6's compile-check of this (unreachable) module both pass. |
| Ordering: Phase 4 ran **before** Phase 3 | Phase 3's dependency on Phase 2 is real, but Phase 4's stated dependency on Phase 3 is not: no file in `Semantics/Extension/` or `ShiftSet.lean` imports `Semantics/Validity.lean`. Phase 3 is the one phase whose migration cannot be held green by the coercion (see the Phase 3 note), so it was deferred rather than allowed to block a phase it does not actually gate. | `grep '^import' FormalSystem/Semantics/Extension/*.lean FormalSystem/Semantics/ShiftSet.lean` shows no `Validity` import. |

---

### Phase 5: ℤ machinery — IntNormalForm and IntTransfer [NOT STARTED]

**Goal**: The ℤ normal-form and transfer machinery on bundled frames, using the F4 idiom from the
first edit.

**PHASE CONTRACT (F4 idiom — state before editing, apply throughout)**: state every
concrete-frame lemma with an explicit `(d : Int)` binder, never at `F.Duration`. Discharge all
arithmetic at `Int`, **outside** the frame application. Do not attempt to make `omega` see
`F.Duration` — probe R1a records that neither `abbrev` nor an ascription-`show` recovers it. If a
concrete frame constant must support numerals, write it with literal field syntax as an `abbrev`
or `@[reducible] def` (probe R1/R3), never as `ofParam (…)` (probe M2/M3 negative).

**Tasks**:
- [ ] Migrate `Semantics/IntNormalForm.lean` (54 occurrences).
- [ ] Migrate `Semantics/IntTransfer.lean` (31 occurrences), including `TaskFrame.map` (`:88`),
      the one `E`-transported concrete frame.
- [ ] For each concrete ℤ frame encountered, apply the idiom and record in the commit which form
      (`abbrev` with literal fields vs. `(d : Int)`-binder restatement) was used.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 2 files, 85 `TaskFrame` occurrences; research F5 puts 9 ℤ-carried concrete
frames in live code overall, of which `TaskFrame.ofStep`, `intTimeFrame`, `intNatFrame`,
`intBoolFrame`, `zTaskFrameV2`, `multiFamTaskFrame` and `TaskFrame.map` are expected in this
phase's or Phase 6's territory. Confirm the per-file inventory with
`grep -n "TaskFrame\s*\(Int\|ℤ\)\|: *ParamTaskFrame Int"` before editing; an unexpected extra
concrete frame is a scope signal, not something to absorb silently.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean`
- `FormalSystem/Semantics/IntTransfer.lean`

**Verification**:
- Standing contract (1-7).
- No goal is left depending on `omega` at a `F.Duration`-typed hypothesis.
- Every concrete-frame lemma statement uses `Int`, not `F.Duration`.

---

### Phase 6: ℤ machinery — IntPresentation and FMP [NOT STARTED]

**Goal**: `IntPresentation` and the finite-model-property machinery on bundled frames, under the
same F4 phase contract as Phase 5.

**Tasks**:
- [ ] Migrate `Metalogic/Decidability/IntPresentation.lean` (28), including
      `IntPresentation.toTaskFrame` and `IntPresentation.toFiniteFrame` (two ℤ concrete frames).
- [ ] Migrate `Metalogic/Decidability/FMP/{Filtration,FiniteModel,Periodicity,FMP}.lean`
      (28/24/4/3), including the `FiniteFilteredTaskFrame` / `RefinedFilteredTaskFrame` /
      `filteredFiniteFrame` constructions (type-variable-carried; F4 does not apply to those).
- [ ] Apply the Phase 5 F4 idiom verbatim wherever the frame is ℤ-carried.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 5 files, ~87 `TaskFrame` occurrences, 4 of the live `FiniteTaskFrame`
values. Confirm the `FiniteTaskFrame` inventory with
`grep -rn "ParamFiniteTaskFrame\|FiniteTaskFrame" FormalSystem --include=*.lean | grep -v Boneyard`
at phase start.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean`
- `FormalSystem/Metalogic/Decidability/FMP/{Filtration,FiniteModel,Periodicity,FMP}.lean`

**Verification**:
- Standing contract (1-7).
- C2 checked explicitly: FMP sits close to the flagship completeness theorems.

---

### Phase 7: ReynoldsBridge and the group-model countermodel base [NOT STARTED]

**Goal**: The largest single ℤ-facing file migrated, plus the `ℚ ×ₗ ℤ` countermodel base.

**Tasks**:
- [ ] Migrate `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (73 occurrences — the
      largest non-`TaskFrame.lean` file in the migration).
- [ ] Migrate `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` (7; `ℚ ×ₗ ℤ` concrete
      frame at `:85`).
- [ ] Apply the F4 idiom; for the `ℚ ×ₗ ℤ` frame note that the hazard is the same shape but the
      arithmetic is not `omega`-discharged, so the `(d : ℚ ×ₗ ℤ)`-binder restatement is the
      relevant half of the idiom.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 2 files, 80 `TaskFrame` occurrences. If `ReynoldsBridge.lean` cannot be
completed in one agent run, split it at a named section boundary and land the first half green
rather than ending the phase red — record the split point in the commit and mark the phase
`[PARTIAL]`.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`

**Verification**:
- Standing contract (1-7).
- C2 checked explicitly: `countermodel_dense` is a flagship theorem.

---

### Phase 8: Soundness layer [NOT STARTED]

**Goal**: Soundness and its lemma files on bundled frames. Abstract frames only — F4 does not
apply anywhere in this phase (probe R6).

**Tasks**:
- [ ] Migrate `Metalogic/Soundness.lean` (9) and `Metalogic/BaseLanguageSoundness.lean` (11).
- [ ] Migrate `Metalogic/SoundnessLemmas/{Core,CoValidity}.lean` (3/1) and
      `Metalogic/SetConsequence.lean` (7).
- [ ] Migrate `Metalogic/StrongCompleteness.lean` (4) and
      `Metalogic/DiscreteNonCompactness.lean` (7).
- [ ] Migrate `Automation/PrefilterSoundness.lean` (4).
- [ ] Introduce frame-class side conditions (`NoMaxOrder`, `NoMinOrder`, `DenselyOrdered`,
      `SuccOrder`/`PredOrder`, `Archimedean`) as `haveI`-introduced Prop hypotheses on the frame
      per research F6/(a), reserving statement-level instance binders for cases that will never
      be a `FrameConditionFor` match arm.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 7 files, ~46 `TaskFrame` occurrences. `Archimedean` is asserted to appear at
only 4 sites (`SoundnessLemmas/Separability.lean:97`, `Independence/LoopingDuration.lean:190,214,238`);
confirm with `grep -rn "Archimedean" FormalSystem --include=*.lean | grep -v Boneyard` and note
that `Separability.lean` is in this phase's territory while `LoopingDuration.lean` is in Phase 11's.

**Files to modify**:
- `FormalSystem/Metalogic/{Soundness,BaseLanguageSoundness,SetConsequence,StrongCompleteness,DiscreteNonCompactness}.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/{Core,CoValidity}.lean` (and `Separability.lean` if it
  carries frame binders)
- `FormalSystem/Automation/PrefilterSoundness.lean`

**Verification**:
- Standing contract (1-7).
- No proof body changed except for binder plumbing; report any that needed more.

---

### Phase 9: Canonical constructions [NOT STARTED]

**Goal**: `FlowFrame`, the canonical task relation, and the BXCanonical family on bundled frames.
These carry the four C2 flagship theorems, so this is the highest-drift-risk phase.

**Tasks**:
- [ ] Migrate `Metalogic/Algebraic/FlowFrame.lean` (68 occurrences, including `bundleFlowFrame`).
- [ ] Migrate `Metalogic/Bundle/CanonicalTaskRelation.lean` (6).
- [ ] Migrate `Metalogic/BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`
      (1/6/1). `CompletenessDedekind.lean:76` carries the single `ℝ` example frame;
      `DiscreteCarrierProbe.lean:72` the second `ℚ ×ₗ ℤ` frame — apply the F4 idiom at both.
- [ ] Migrate `Metalogic/BXCanonical/Chronicle/{ChronicleMonadicBridge,MCSMixedCase,ChronicleToCountermodelBasic}.lean`
      (13/1/1).
- [ ] Do not rename `Dedekind` (507's territory), even where the bundled form makes `Complete`
      the more natural word.

**Timing**: 2 hours

**Depends on**: 7, 8

**Verification Tier**: full

**Scope Hypothesis**: 8 files, ~97 `TaskFrame` occurrences. All four C2 flagship theorems live in
or immediately above this territory; confirm each theorem's axiom profile individually
(`#print axioms` per theorem) rather than relying on the aggregate gate output.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean`
- `FormalSystem/Metalogic/BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/{ChronicleMonadicBridge,MCSMixedCase,ChronicleToCountermodelBasic}.lean`

**Verification**:
- Standing contract (1-7).
- Per-theorem `#print axioms` for all four flagship theorems, output compared to the C2 baseline
  at `scripts/check-module-invariants.sh:144-149`.

---

### Phase 10: Decidability remainder [NOT STARTED]

**Goal**: BiLasso, the Verified bridge, and the remaining decidability files on bundled frames,
reusing `FrameConditionFor` rather than inventing a parallel `Sat`.

**Tasks**:
- [ ] Migrate `Metalogic/Decidability/Verified/Bridge/{Carrier,RegionFrame,TruthLemma,Interpolate}.lean`.
      `FrameConditionFor` (`Carrier.lean:110`) becomes `FrameConditionFor fc F.Duration` — a
      per-frame condition — and `TemporalCarrier`'s (`:126`) type-class binder disappears. **Reuse
      this abstraction; do not write a parallel `FrameClass.Sat`** (research F9).
- [ ] Migrate `Metalogic/Decidability/BiLasso/*.lean` (14 files:
      `Basic, Agreement, Annotation, Assembly, BoxOracle, Check, Extend, Extraction, GoodCycle,
      Orbit, Realized, SmallModel, TruthLemma, Unfold`).
- [ ] Migrate `Metalogic/Decidability/{CountermodelExtraction}.lean`,
      `Metalogic/Decidability/Verified/Decidable.lean`,
      `Metalogic/Decidability/Propositional/Decidable.lean`.
- [ ] Leave `.Dedekind` arm naming untouched (507 renames it to `.Complete`).

**Timing**: 2 hours

**Depends on**: 6, 9

**Verification Tier**: full

**Scope Hypothesis**: ~21 files, ~90 `TaskFrame` occurrences, most at 1-7 per file. The BiLasso
directory is asserted to be 14 files with low per-file counts; confirm with
`grep -rc "TaskFrame" FormalSystem/Metalogic/Decidability/BiLasso/*.lean`. If the aggregate
exceeds one agent run, split at the `Verified/Bridge` vs. `BiLasso` boundary into 10 and 10.1.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/{Carrier,RegionFrame,TruthLemma,Interpolate}.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/*.lean`
- `FormalSystem/Metalogic/Decidability/{CountermodelExtraction}.lean`
- `FormalSystem/Metalogic/Decidability/Propositional/Decidable.lean`

**Verification**:
- Standing contract (1-7).
- `grep -rn "class TemporalCarrier\|FrameConditionFor" FormalSystem` shows the existing
  abstraction reused, with no new `Sat`-shaped definition introduced.

---

### Phase 11: Independence, Examples, FrameConditions, aggregators [NOT STARTED]

**Goal**: The remaining live `FormalSystem/` surface, including deletion of the orphaned
`ValidOver`.

**Tasks**:
- [ ] Migrate `Metalogic/Independence/{ClockFrame,LoopingDuration,CoNotPriorU}.lean` (11/9/2).
      `ClockFrame.lean:173` is the single `ℚ` concrete frame — apply the F4 idiom.
- [ ] Migrate `FormalSystem/Examples/TemporalStructures.lean` (73 occurrences — carries
      `trivialFrame`, `staticFrame`, `natFrame`, `genericTimeFrame`, `genericNatFrame`,
      `flipFrame`, `intTimeFrame`, `intNatFrame`, `intBoolFrame`, `multiFamTaskFrame*`,
      `regionFrame` and friends; a mix of type-variable-carried and ℤ-carried frames — apply F4
      selectively).
- [ ] Migrate `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean`
      and **delete** `FrameConditions.ValidOver` (`Validity.lean:59`), subsumed by bundled
      `TaskFrame.ValidOn` (research Recommendation 6, and 511/reports/01 §S3).
- [ ] Update the aggregators: `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic.lean`,
      `FormalSystem/Metalogic/Independence.lean`, `FormalSystem/Metalogic/Decidability.lean`.

**Timing**: 2 hours

**Depends on**: 9, 10

**Verification Tier**: full

**Scope Hypothesis**: ~11 files, ~110 `TaskFrame` occurrences; `TemporalStructures.lean` alone is
73 and holds the majority of the 27 live concrete frame values. Enumerate that file's frame
constants first (`grep -n "def .*Frame\|abbrev .*Frame" FormalSystem/Examples/TemporalStructures.lean`)
and classify each as type-variable-carried or ℤ-carried before editing; if the file cannot be
completed in one run, split it at a section boundary and land the first half green.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/{ClockFrame,LoopingDuration,CoNotPriorU}.lean`
- `FormalSystem/Examples/TemporalStructures.lean`
- `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean`
- `FormalSystem/{Semantics,Metalogic}.lean`, `FormalSystem/Metalogic/{Independence,Decidability}.lean`

**Verification**:
- Standing contract (1-7).
- `grep -rn "ValidOver" FormalSystem --include=*.lean | grep -v Boneyard` returns nothing.

---

### Phase 12: Tests [NOT STARTED]

**Goal**: The test suite migrated and green; the `SemanticBenchmark.lean` name defect fixed.

**Tasks**:
- [ ] Migrate `Tests/BimodalTest/Semantics/{TaskFrameTest,SemanticPropertyTest,SphericalFiniteAxiomTest,TruthTest,DependentUltraproductProbe}.lean`
      and `Tests/BimodalTest/Property/Generators.lean`, `Tests/BimodalTest/Property.lean`,
      `Tests/BimodalTest.lean`. All four test concrete frames are `TaskFrame Int` and delegating —
      apply the F4 idiom.
- [ ] Fix `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50`: it names
      `TaskFrame.trivial_frame`, which does not exist (the live name is `trivialFrame`). This went
      uncaught because the file is not imported by `Tests/BimodalTest.lean`.
- [ ] Do **not** wire `SemanticBenchmark.lean` into the test aggregator in this task — that
      changes what is built and is out of scope for a restatement refactor. Record the
      still-unimported status in the phase commit so it is not silently forgotten.

**Timing**: 1.5 hours

**Depends on**: 11

**Verification Tier**: full

**Scope Hypothesis**: 8-9 test files, ~72 `TaskFrame` occurrences, 4 concrete `TaskFrame Int`
values. Confirm the aggregator's import list with
`grep -n "import" Tests/BimodalTest.lean` before deciding which files the build actually covers.

**Files to modify**:
- `Tests/BimodalTest/Semantics/*.lean`, `Tests/BimodalTest/Property*.lean`, `Tests/BimodalTest.lean`

**Verification**:
- Standing contract (1-7).
- `lake build BimodalTest` (or the project's test target) exits 0.
- `SemanticBenchmark.lean` elaborates under `lake env lean` even though it is not imported.

---

### Phase 13: Delete the bridge; restore names; documentation [NOT STARTED]

**Goal**: `ParamTaskFrame` and the whole transitional layer are gone; documentation records the
new shape and the `def:frame` conformance argument.

**Tasks**:
- [ ] Confirm the shim ledger is at zero (mechanism (b)) or that no `CoeOut` coercion remains
      reachable (mechanism (a)); `grep -rn "ofParam\|toParam\|ParamTaskFrame\|ParamFiniteTaskFrame"`
      over live scope must return only the declarations about to be deleted.
- [ ] Delete `ParamTaskFrame`, `ParamFiniteTaskFrame`, `TaskFrame.ofParam`, `TaskFrame.toParam`,
      and the compatibility instance if one was added.
- [ ] Rename the bare-relation predicate namespace back:
      `ParamTaskFrame.{Compositional,Converse,Serial,Limit,Spherical,NullityIdentity}` ->
      `TaskFrame.*` (the reversal of Phase 1's deliberate over-reach).
- [ ] Rewrite the `TaskFrame.lean` module docstring to record that `Duration`-as-a-field is the
      `def:frame` conforming encoding (`F = <W, D, =>>`) and that the parameterized form was the
      deviation. Keep every existing paper anchor resolving (C15):
      `def:frame`, `def:temporal-order`, `def:task-relation`, `def:directed`, `lem:nullity`.
- [ ] Update the 15 markdown files under `docs/` and `README.md` that mention `TaskFrame` so C14
      documented counts and C12/C13 links stay correct.
- [ ] Leave `FormalSystem/Boneyard/` untouched; add C11 waivers only if the gate demands them.

**Timing**: 1.5 hours

**Depends on**: 12

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 15 markdown files mention `TaskFrame` (research F10/scale table); confirm
with `grep -rl "TaskFrame" docs README.md | wc -l` at phase start, and treat a different count as
a signal that documentation drifted during the migration rather than as a number to overwrite.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — deletions plus module docstring rewrite
- 15 markdown files under `docs/` plus `README.md`
- `scripts/boneyard-import-waivers.txt` (only if C11 requires)

**Verification**:
- Standing contract (1-7), with the **full** `bash scripts/check-module-invariants.sh` run
  (no `--no-build`).
- `grep -rn "ParamTaskFrame" FormalSystem Tests docs README.md` returns nothing.
- C15 anchor resolution passes against `specs/paper-definitions-of-record.md`.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase boundary and at task completion.
- [ ] `bash scripts/check-module-invariants.sh` passes at task completion (full run, with build).
- [ ] C2: `#print axioms` for `FormalSystem.Metalogic.BXCanonical.{completeness,
      completeness_dense, completeness_discrete}` and
      `FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense` each equal
      `[propext, Classical.choice, Quot.sound]` — checked per phase, not only at the end.
- [ ] C3: zero structural `sorry` in the tree at every phase boundary.
- [ ] C9: no task-number citation anywhere under `FormalSystem/`.
- [ ] C14/C15: documented axiom/sorry counts consistent across `docs/`, `README.md` and Lean
      docstrings; every paper anchor resolves.
- [ ] The four bundled definitional-content `example`s in `TaskFrame.lean` close by `rfl`.
- [ ] `grep -rn "ParamTaskFrame\|ofParam\|toParam" FormalSystem Tests --include=*.lean |
      grep -v Boneyard` returns nothing after Phase 13.
- [ ] `lake build` wall time at Phase 13 within 25% of the Phase 1 baseline.

## Artifacts & Outputs

- `specs/512_bundle_duration_into_taskframe/plans/01_bundle-duration-into-taskframe.md` (this file)
- `specs/512_bundle_duration_into_taskframe/summaries/01_bundle-duration-into-taskframe-summary.md`
  (written at implementation completion)
- `FormalSystem/Semantics/TaskFrame.lean` — bundled `TaskFrame`/`FiniteTaskFrame`, rewritten
  module docstring
- 80 further migrated live `.lean` files across `FormalSystem/` and `Tests/`
- Deleted: `FormalSystem/FrameConditions/Validity.lean`'s `ValidOver`
- Updated: 15 markdown files under `docs/` plus `README.md`

## Rollback/Contingency

- **Per-phase**: every phase is one or more commits ending green. Roll a phase back with
  `git revert` of that phase's commits; all prior phases remain green and the tree remains
  buildable. Never use a destructive git operation on a dirty tree — snapshot first via
  `bash .claude/scripts/git-snapshot.sh 512`.
- **Mid-phase interruption**: mark the phase `[PARTIAL]`, record the resume point (file plus
  section boundary) in the progress file, and leave the last green commit as the tree state.
  `ReynoldsBridge.lean` (Phase 7) and `TemporalStructures.lean` (Phase 11) are the two files most
  likely to need an intra-file split; both phases pre-authorize it.
- **Whole-task abort**: because the bridge is introduced in Phase 1 and deleted only in Phase 13,
  the tree is in a coherent, green, dual-representation state at every intermediate boundary.
  Aborting mid-migration leaves a working build with `ParamTaskFrame` still present; that is an
  acceptable resting state, not a broken one.
- **Drift detected** (a C2 profile changes, or a proof needs a genuinely new lemma): stop the
  phase, do not work around it, and report. The bridge round-trip being `rfl` means legitimate
  restatement never requires new mathematical content.
