# Implementation Plan: Task #512 (v02) — the temporal-order fibration

- **Task**: 512 - bundle_duration_into_taskframe
- **Status**: [NOT STARTED]
- **Effort**: 41 hours
- **Dependencies**: None blocking. Sequencing interaction with task 507 (Dedekind naming in
  `Semantics/Validity.lean` and `FrameClass`); the batch sequences 512 strictly before 507, so the
  two never run concurrently. Ownership partition unchanged: **512 owns binders, 507 owns names.**
  Cross-task observation for the orchestrator (record only, do not act): task 510's
  `TemporalCarrier` / `FrameConditionFor` (`Metalogic/Decidability/Verified/Bridge/Carrier.lean:110,126`)
  may simply *be* `TemporalOrder` under this design, in which case 510 shrinks to a merge.
- **Research Inputs**:
  - `specs/512_bundle_duration_into_taskframe/reports/01_bundle-duration-into-taskframe.md`
    (verified; probe files `reports/{01,02,03}_probes.lean` green at commit `3365859e2`)
  - `specs/512_bundle_duration_into_taskframe/summaries/01_bundle-duration-into-taskframe-summary.md`
    (v01 execution record: 5 phases landed green, 5 blocked, 3 unstarted)
  - `specs/512_bundle_duration_into_taskframe/probes/04_coercion-and-transparency.lean`,
    `probes/05_omega-at-a-coerced-frame.lean`,
    `probes/06_fixed-duration-expressibility.lean` (the blocker, reproduced)
  - `specs/paper-definitions-of-record.md` — `def:temporal-order`, `def:frame`,
    `def:task-relation`, `def:frame-properties`, `def:directed`, `lem:nullity`
- **Artifacts**: plans/02_temporal-order-fibration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v01 bundled `Duration : Type` plus four loose instance fields into `TaskFrame`, landed 86
files onto abstract bundled frames, and then hit a hard blocker: the **fibre** notion — "the task
frames over a fixed duration type" — became inexpressible, while the entire ℤ machinery is stated
exactly that way (76 occurrences of `ParamTaskFrame {ℤ,Int,ℚ,ℝ}` across 20 live files, plus four
test frames). `(F : TaskFrame) (hD : F.Duration = ℤ)` cannot carry it: `hD` is a `Prop` and
`OfNat F.Duration 1` is data.

This revision resolves the blocker by **reifying the temporal order** and making the fibre the
primitive: `TemporalOrder` becomes a structure (the paper's `def:temporal-order`), `FrameOver D`
becomes the fibre over a temporal order and the sole home of the six frame axioms, and `TaskFrame`
becomes the total space `Σ (D : TemporalOrder), FrameOver D`, definitionally. The inclusion of a
fibre into the total space is then the **constructor** `TaskFrame.mk D`, not a coercion.

This is a **restatement refactor**: no theorem's mathematical content changes, and any semantic
drift is a defect. Definition of done is unchanged from v01 — target shape landed,
`ParamTaskFrame` and the whole transitional layer deleted, sorry-free, `lake build` exits 0,
`bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED, and the four C2 flagship
axiom profiles byte-identical to the recorded baseline.

### The diagnosis this plan acts on

The root defect is that the library **has no name for `def:temporal-order`**. It is transcribed as
an unnamed 4-binder list `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`,
hand-copied 225 times in 30 distinct shapes (research F6). That single omission causes *both*
observed symptoms:

- the binder-noise proliferation (research F6, review issue H1), and
- the fibre-inexpressibility blocker — you cannot **fix** "a temporal order" when there is no such
  object, only a bare `Type` plus four loose instance arguments.

Naming the object fixes both at once.

### Target shape (frozen for this task)

```lean
/-- `def:temporal-order`: a nontrivial totally ordered abelian group. -/
structure TemporalOrder where
  carrier : Type
  [addCommGroup       : AddCommGroup carrier]
  [linearOrder        : LinearOrder carrier]
  [isOrderedAddMonoid : IsOrderedAddMonoid carrier]
  [nontrivial         : Nontrivial carrier]

instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩
attribute [instance] TemporalOrder.addCommGroup TemporalOrder.linearOrder
                     TemporalOrder.isOrderedAddMonoid TemporalOrder.nontrivial

/-- The fibre: frames over a fixed temporal order. The frame axioms live HERE, stated once. -/
structure FrameOver (D : TemporalOrder) where
  WorldState : Type
  [worldNonempty : Nonempty WorldState]
  TaskRel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  comp      : TaskFrame.Compositional TaskRel
  converse  : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  serial    : TaskFrame.Serial TaskRel
  limit     : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  spherical : TaskFrame.Spherical TaskRel

/-- `def:frame` — the total space. `TaskFrame ≅ Σ (D : TemporalOrder), FrameOver D`,
definitionally (structure eta). -/
structure TaskFrame where
  Duration : TemporalOrder
  toFibre  : FrameOver Duration
```

`carrier : Type` and `WorldState : Type` — no universe polymorphism (research F2). The field set
is **frozen**: `nullity_identity` is retained (research Decision 5), and any field-set change is a
separate task.

`TaskFrame` keeps its whole flat surface through `@[reducible]` delegating accessors
(`TaskFrame.WorldState`, `.TaskRel`, `.comp`, `.converse`, `.serial`, `.limit`, `.spherical`,
`.nullity_identity`, and the derived API `.forward_comp` / `.interpolates` / `.nullity` /
`.backward_comp`), so the 86 files v01 landed on `(F : TaskFrame)` keep their existing spellings
`F.WorldState`, `F.TaskRel w d u`, `F.spherical`. This is Phase 0 probe (d) and it is what makes
this revision a *migration of the green state* rather than a revert.

### The owner decision, and why not the alternatives

Settled by the owner. Recorded here so it is not re-litigated at implementation time.

| Rejected alternative | Why it loses |
|---|---|
| Keep `ParamTaskFrame D` permanently as the fibre | Two structures each independently declaring `WorldState`, `TaskRel` and all six frame axioms — axioms stated twice, lemmas proved twice or transported, and the inclusion needs the `CoeOut` machinery with its universe restriction (v01 had to demote 95 `D : Type*` binders to `D : Type`). Under the fibration the axioms exist **once** and the inclusion `FrameOver D → TaskFrame` is `TaskFrame.mk D`, a constructor — nothing to transport, no coercion, no universe boundary to cross. |
| Reformulate the ℤ machinery over raw components `(W, R, axioms)` | Dissolves the fibre into loose tuples at ~350 sites and re-derives `ParamTaskFrame ℤ` by hand at each. Under the fibration the fibre stays a structure and the ℤ layer migrates by renaming `ParamTaskFrame ℤ` → `FrameOver intOrder`. |
| `FrameOver` carrying the carrier equation as data | Indexing over `TemporalOrder` *is* the clean form of that same idea. Do not carry evidence that the duration is ℤ; index by it. |

**Faithfulness.** This is *more* faithful to the paper, not less. `def:frame` reads
`𝔉 = ⟨W, 𝔇, ⇒⟩` where "𝔇 is a temporal order" — a temporal order is a *component*, and it is an
*object*, not a bare set with side conditions. `def:frame-properties` predicates
Discrete/Dense/Complete of the frame through its 𝔇-component, which becomes literally
`F.Duration.Dense`: a predicate on a `TemporalOrder`, exactly where the paper puts it.

**Structural payoff.** `TaskFrame → TemporalOrder` is a fibration and `FrameOver D` is its fibre
category, making base change along a temporal-order morphism first-class. Every capability the
bundling was undertaken for — frame morphisms, bisimulation, disjoint unions, the category of
frames (research F7) — survives unchanged, and gains the fibre structure for free.

### Migration mechanism (load-bearing; read before Phase 1)

Not a big-bang. Three moves, each green:

1. **`TemporalOrder` lands additively** (Phase 1) in a new module `FormalSystem/Semantics/TemporalOrder.lean`,
   imported by `TaskFrame.lean` and by the `Semantics.lean` aggregator. Nothing consumes it yet.
2. **`FrameOver` lands beside `ParamTaskFrame`, and `ParamTaskFrame` becomes a transitional
   `@[reducible] def`** (Phase 2):
   ```lean
   @[reducible] def ParamTaskFrame (D : Type) [AddCommGroup D] [LinearOrder D]
       [IsOrderedAddMonoid D] [Nontrivial D] : Type 1 := FrameOver (TemporalOrder.of D)
   ```
   If generalized field notation resolves through the reducible alias (Phase 0 probe (f)), all 63
   still-parameterized files stay green with **zero edits**, and each later phase migrates its own
   files' binder lists from `{D : Type} [4 instances] (F : ParamTaskFrame D)` to
   `{D : TemporalOrder} (F : FrameOver D)`, and `ParamTaskFrame ℤ` to `FrameOver intOrder`.
3. **`TaskFrame` is redefined as the total space** (Phase 3), with the flat delegating accessors
   that keep the 86 already-migrated files' spellings intact.

The transitional layer (`ParamTaskFrame`, `ParamFiniteTaskFrame`, `TaskFrame.ofParam`,
`TaskFrame.toParam`, `instCoeOutParamTaskFrame`, `TemporalOrder.of` if it does not earn its keep)
is deleted in Phase 20.

**The v01 `CoeOut` device is superseded and is NOT carried forward as a design element.** It
survives only as scaffolding for as long as `ParamTaskFrame` does, and there is **no shim ledger**
in this plan: the permanent inclusion is `FrameOver.toTaskFrame := ⟨D, F⟩`, definitionally the
constructor.

### Preserved assets — what v01 landed and what survives

v01 executed Phases 1-4 and 8 and left the tree green at commit `1d75b1d0e` (HEAD `949411db1`).
**That work is preserved, not reverted.** What changes is `TaskFrame`'s own definition; the
*direction* — quantifying over an abstract bundled frame — is exactly right and is kept.

| Asset from v01 | Status under v02 |
|---|---|
| `structure TaskFrame` bundled, with `attribute [instance]` block, derived API, definitional-content `example`s | **Kept**, reshaped in Phase 3: `Duration : Type` + 4 instance fields → `Duration : TemporalOrder`; `WorldState`/`TaskRel`/axioms move down into `FrameOver` and come back up as `@[reducible]` accessors |
| 86 files landed on `(F : TaskFrame)` — `PartialHistory`, `PartialHistoryOrder`, `WorldHistory`, `TaskModel`, `Truth`, `FrameAxioms`' history half, `H_F`, `Extension/{Admissible,Constraint,Extension,Step}`, `ShiftSet`, the whole `Valid*`/`SemanticConsequence*`/`Satisfiable*Set` family, and the soundness layer | **Kept as-is wherever the accessors and `CoeSort` hold** (Phase 0 probe (d) decides how much). Expected edit surface: concrete-frame *construction* sites and any place `F.Duration` is used other than in a type position |
| The 95 `D : Type*` → `D : Type` demotions | **Kept.** `TemporalOrder.carrier : Type` is the target shape's own choice (research F2), and under the fibration there is no universe boundary to cross at all |
| Statement-level instance binders for frame-class side conditions (`[DenselyOrdered F.Duration]`), taken instead of `haveI` Prop hypotheses | **Kept.** They become `[DenselyOrdered ↑F.Duration]`; the H1 collapse onto `FrameConditionFor` remains an explicit Non-Goal (507/513 territory) |
| The F4 idiom applied to `BiLasso/Unfold.lean`, `BiLasso/TruthLemma.lean`, `Extension/PeriodicExtension.lean` (`@LT.lt ℤ _ a b` written explicitly) | **Kept**, and re-examined per file: at the ℤ *fibre* the duration is syntactically fixed again, so some of those explicit forms may relax back. Relaxing is optional; do not spend a phase on it |
| `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` `TaskFrame.trivial_frame` → `trivialFrame` fix, and the recorded decision **not** to wire the file into the test aggregator | **Kept**, both the fix and the decision |
| `ParamTaskFrame.{Compositional,Converse,Serial,Limit,Spherical,NullityIdentity,Interpolates}` bare-relation predicate namespace (v01 Phase 1's deliberate rename over-reach) | **Reverted to `TaskFrame.*` in Phase 2**, one phase earlier than v01 planned, because `FrameOver`'s axiom fields must cite them and citing them under a namespace about to be deleted is gratuitous churn. This is a *restoration of the pre-512 name*, not a naming decision, and therefore does not encroach on 507 |
| `FormalSystem/Boneyard/` excluded throughout (2 frames already fail to elaborate) | **Kept excluded.** Leave dead |

### Structural findings from v01 execution, folded in

1. **v01's Phases 3 and 8 are ONE dependency component and are merged here** (Phase 5). Phase 3 in
   practice touched 17 files spanning v01 phases 3, 8, 9, 10 and 11. Cause: `valid` and its four
   siblings carry **explicit** `∀ (D : Type) [4 instances]` binders *inside a Prop*, so every
   consumer supplies them positionally and every consumer breaks at once — a breakage no coercion
   and no shim can absorb. Phase 5 is sized against that reality and pre-authorizes a 5.1 split.
2. **Generalized field notation never consults a coercion.** `F.HF`, `F.ValidOn`,
   `F.forward_comp` resolve by the head constant of `F`'s type. This is why the flat delegating
   accessors of Phase 3 are load-bearing, and why Phase 0 probes them before any migration.
3. **A `(t : ℤ)` ascription is a no-op when `t` is itself frame-typed** — it silently re-elaborates
   at the frame type. The working form is the explicit `@LT.lt ℤ _ a b`. Carry this into every
   ℤ-fibre phase.
4. **Phase ordering claims must be checked against imports, not assumed.** v01's Phase 4 ran before
   Phase 3 because Phase 4's stated dependency was not real. Every `Depends on` below is a claim to
   verify with `grep '^import'`, not an instruction to serialize needlessly.

### Research Integration

Newly integrated into this revision:

- `summaries/01_bundle-duration-into-taskframe-summary.md` — the v01 execution record: three
  load-bearing findings (CoeOut works and the shim ledger is empty; generalized field notation and
  explicit in-Prop `∀ D` binders are the two things a coercion cannot reach; the fibre blocker),
  the plan deviations, and the per-phase outcome table. This is the primary new input.
- `probes/04_coercion-and-transparency.lean` — `CoeOut` firing at explicit-argument, structure-
  parameter and dependent-argument positions; `(ofParam F).addCommGroup = inferInstance` by `rfl`
  at reducible transparency. Establishes that projection instances unify with ambient binder
  instances, which is the precondition for `TemporalOrder`'s `attribute [instance]` block.
- `probes/05_omega-at-a-coerced-frame.lean` — the `omega`-at-a-coerced-ℤ-frame characterisation
  and the explicit `@LT.lt ℤ _` restatement that recovers it.
- `probes/06_fixed-duration-expressibility.lean` — the blocker, reproduced: `OfNat F.Duration 1`
  fails to synthesize under a propositional carrier equation.

Carried forward from research report 01 unchanged: F1/F2 (target shape elaborates; `Type 1` before
and after), F3 (structure eta makes the bridge a definitional isomorphism), F4 (the reducible-
transparency hazard and the working idiom), F5 (the concrete-frame inventory), F6 (the 225 binder
occurrences in 30 shapes), F9 (`FrameConditionFor` prior art), F10 (the C1/C2/C3/C9/C14/C15 gates).

**Research finding F8 is promoted.** The `TemporalOrder` mixin was an explicit Non-Goal of v01
("do not couple it to this task"). Under this design it is **central**: it is the object whose
absence caused the blocker. Note the shape differs from F8's probe: F8 probed a `Prop`-valued
*mixin class* over an ambient carrier; this plan uses a `Type`-valued *structure* bundling the
carrier. F8's diamond-freeness result therefore does **not** transfer, which is why Phase 0
probe (c) re-establishes it for the structure form.

### Prior Plan Reference

`plans/01_bundle-duration-into-taskframe.md`. Phases 1-4 and 8 are `[COMPLETED]` or
`[COMPLETED WITH EXCLUSIONS]` there and their landed work is preserved (see Preserved Assets
above). Phases 5, 6, 7, 10 and 12 are `[BLOCKED]` on the blocker this revision resolves; Phases 9
and 11 were `[NOT STARTED]` downstream of them; Phase 13 was not executable as written because it
directed the deletion of `ParamTaskFrame`, which *is* the fibre notion. v01's phase numbering is
not preserved — the territory is re-cut around the fibration.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap consultation was performed
and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `TemporalOrder` exists as the library's name for `def:temporal-order`, with `CoeSort` and the
  four projection instances.
- `FrameOver (D : TemporalOrder)` is the fibre and the **sole** declaration site of the six frame
  axioms.
- `TaskFrame` is the total space, definitionally `Σ (D : TemporalOrder), FrameOver D`, with the
  inclusion `FrameOver.toTaskFrame` being the constructor.
- `TaskFrame`'s flat surface (`F.WorldState`, `F.TaskRel`, `F.spherical`, …) is preserved through
  `@[reducible]` accessors, so v01's 86 landed files need no restatement.
- Every `ParamTaskFrame {ℤ,Int,ℚ,ℝ}` site is restated at the corresponding fibre
  (`FrameOver intOrder`, …); the v01 blocker surface is closed.
- `ParamTaskFrame`, `ParamFiniteTaskFrame`, `ofParam`, `toParam` and the `CoeOut` are deleted.
- The bare-relation predicate namespace is restored to `TaskFrame.*`.
- `FormalSystem/FrameConditions/Validity.lean`'s orphaned `ValidOver` is **deleted** (subsumed by
  bundled `TaskFrame.ValidOn`).
- Sorry-free; `lake build` green; `check-module-invariants.sh` ALL CHECKS PASSED; C2 axiom profiles
  unchanged on all four flagship theorems.
- `TaskFrame.lean` and `TemporalOrder.lean` module docstrings record the fibration and the
  `def:frame` / `def:temporal-order` conformance argument.

**Non-Goals**:
- No change to any theorem's mathematical content. This is a restatement.
- **No H1 collapse** of the 15 `Valid*` / 8 `SetSemanticConsequence*` / ~23 soundness theorems onto
  `FrameConditionFor`-indexed definitions. That is 507/513 territory. Restating a fixed-carrier
  predicate over `FrameOver D` is a binder restatement and IS in scope; collapsing the family is
  not.
- No new `TemporalOrder.Dense` / `.Discrete` / `.Complete` predicates. The design *enables* them
  and the docstrings should say so, but declaring them is 507/513/514 work. Existing
  `[DenselyOrdered F.Duration]`-style instance binders simply become `[DenselyOrdered ↑F.Duration]`.
- No renaming of any `Dedekind` identifier. 507 owns names.
- No field-set change: `nullity_identity` stays.
- No universe polymorphism.
- No porting of the two dead Boneyard frames.
- No action on the 510 observation. It is recorded in this plan's metadata for the orchestrator and
  nothing else.
- No general theory of temporal-order morphisms beyond what Phase 8 finds already present in
  `IntTransfer.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Numerals do not elaborate at `↑intOrder` — the fibre design fails at its own premise | **Fatal** | M | Phase 0 probe (a) is a **STOP gate**: if it fails, the phase escalates a structured blocker and no migration work starts. Research R1/R3 give the positive precedent (literal-field `abbrev`/`@[reducible] def` supports numerals) and M2/M3 the negative (an `ofParam (…)`-built one does not), so the probe's job is to confirm the precedent survives the `CoeSort` projection |
| `omega` and `Int` arithmetic unusable at `FrameOver intOrder` | **Fatal** | M | Phase 0 probe (b), also a STOP gate. Expected to pass: the F4 idiom failed only for *abstract bundled* frames, and at the fibre the duration is syntactically fixed. Fallback inside the probe: `ℤ`-typed binders fed to `F.TaskRel` unify at default transparency, which is exactly the v01 Phase 2 working form |
| `attribute [instance]` on the four `TemporalOrder` projections creates a diamond or a resolution loop | H | M | Phase 0 probe (c), including at `↑D` for an abstract `(D : TemporalOrder)` and at the `TemporalOrder.of D` alias where an ambient binder instance and a projection instance both reach `AddCommGroup D`. Precedent: `probes/04` shows the analogous `(ofParam F).addCommGroup = inferInstance` closes by `rfl` at reducible transparency. Research F8's Prop-mixin diamond result does **not** transfer — this is a `Type`-valued structure |
| The flat accessors do not preserve `F.WorldState` / `F.TaskRel` notation, so all 86 landed files need restatement | H | L | Phase 0 probe (d). If it fails, the whole "preserve the green state" premise fails and the phase escalates rather than silently converting to a big-bang |
| Generalized field notation does not resolve through the `ParamTaskFrame` reducible alias, so the transitional bridge does not hold the 63 unmigrated files green | M | M | Phase 0 probe (f). Fallback pre-specified: keep `ParamTaskFrame` a genuine `structure` with `@[reducible]` conversions both ways, and pay one mechanical touch per downstream file at its own phase |
| Semantic drift — a "restatement" that quietly changes a theorem | H | M | C2 axiom-profile check **every phase**, not only at the end. Structure eta makes the fibre/total-space relation definitional, so drift is a typechecking failure rather than a silent one. Any proof needing a genuinely *new* lemma to close is a drift signal: stop and report |
| Phase 5 (the merged v01 3+8 component) blows past one agent run, as v01's Phase 3 did | M | H | Sized at 3 hours with a pre-authorized 5.1 split at a named boundary (`Validity.lean` + BL layer, then the ~17 consumer files). Land the first half green rather than ending the phase red |
| `ReynoldsBridge.lean` (1352 lines) or `TemporalStructures.lean` (550 lines, 70 occurrences) does not fit one run | M | M | Both phases (11, 17) pre-authorize an intra-file split at a named section boundary with `[PARTIAL]` and a recorded resume point |
| Build times regress from the extra projection layer (`↑D` through `TemporalOrder.carrier`) | M | M | Record `lake build` wall time in every phase commit. v01's Phase 1 full-rebuild baseline is 403 s. Investigate if it grows >25%. The accessors and `TemporalOrder.of` are `@[reducible]`, which is what keeps synthesis from stalling but also what makes unfolding cheap |
| 507's naming work collides | M | L | Batch sequences 512 strictly before 507. Do not rename any `Dedekind` identifier in this task. The `ParamTaskFrame.*` → `TaskFrame.*` predicate-namespace revert is a restoration of a pre-512 name, not a naming decision |
| A phase ends red and blocks the chain | H | M | Never let a phase end red. Phase-level rollback is `git revert` of that phase's commits only; all prior phases stay green |
| New module `Semantics/TemporalOrder.lean` disturbs an aggregator invariant | L | L | C8 governs directory/sibling-aggregator pairs and is unaffected by adding a file to an existing directory. The only obligation is the `FormalSystem/Semantics.lean` import line plus its `## Submodules` docstring entry (C5/C14). Verified against `scripts/check-module-invariants.sh`'s C8 body |

## Standing Per-Phase Contract

Applies to every phase below; not restated per phase.

1. `lake build` exits 0 at the phase boundary. **No phase ends red.**
2. `bash scripts/check-module-invariants.sh` reports **ALL CHECKS PASSED** (use `--no-build` for
   fast intra-phase structural passes; the full run is required at the boundary).
3. **Zero `sorry`.** The zero-debt gate applies: no phase may land a `sorry`, strategic or
   otherwise. This plan declares no strategic sorries and `plan_metadata.skeleton` is `false`.
4. C2 axiom profiles for the four flagship theorems (`BXCanonical.{completeness,
   completeness_dense, completeness_discrete}`, `BXCanonical.Chronicle.countermodel_dense`)
   unchanged — verified **this phase**, not deferred to the end.
5. Commit at the boundary: `task 512 phase {P}: {name}`, plus per-green-substep commits within the
   phase (except where `Commit Mode: atomic-batch` is declared). Record the `lake build` wall time.
6. No task-number citations in any file under `FormalSystem/` (C9).
7. `FormalSystem/Boneyard/` is excluded from every edit.
8. **Prohibited workarounds**: no `sorry`; no `def X := True`; no per-site `▸` casting campaign
   presented as a restatement. Any of these is a defect, and encountering the temptation is a
   signal to stop and report, not to proceed.
9. Every count, file list and scope estimate in a phase's **Scope Hypothesis** is confirmed at
   implementation time before editing. A discrepancy is reported, not silently absorbed.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5, 6 | 4 |
| 7 | 7, 12 | 5, 6 |
| 8 | 8, 9, 16, 18 | 5, 6, 7, 12 |
| 9 | 10, 11, 17 | 8, 9, 16 |
| 10 | 13, 14 | 10, 11, 12 |
| 11 | 15 | 9, 14 |
| 12 | 19 | 13, 15, 17 |
| 13 | 20 | 14, 18, 19 |

Phases within the same wave are file-disjoint and can execute in parallel under a territory
contract naming the file sets, with a serialized `lake build`. Sequential execution in the listed
order is the default and is always safe. Every `Depends on` claim below is checkable with
`grep '^import'` — check it rather than serializing on faith (v01 deviation 1).

---

### Phase 0: Probe the fibration design [COMPLETED]

**Goal**: Establish empirically, before any tree edit, that the target shape supports numerals at
the ℤ fibre, `omega`/`Int` arithmetic at the ℤ fibre, loop-free instance resolution through the
`TemporalOrder` projections, and the flat-accessor / `CoeSort` surface the 86 preserved files
depend on. **This phase is a STOP gate.**

**Already verified, do not re-probe** (research R1/R3, M2/M3): a literal-field `abbrev` /
`@[reducible] def` frame constant supports numerals, while an `ofParam (…)`-built one does not;
and `omega` cannot be made to see an abstract `F.Duration` by any of `abbrev`, ascription-`show`,
or a propositional carrier equation.

**Tasks**:
- [x] Write standalone probe files under `specs/512_bundle_duration_into_taskframe/probes/`
      (next free sequence numbers, `07_`…), each runnable with `lake env lean <path>` and imported
      by nothing.
- [x] **(a) Numerals at the fibre — STOP GATE.** With `@[reducible] def intOrder : TemporalOrder :=
      ⟨ℤ⟩` written with **literal fields**, check that the numerals `0` and `1` elaborate at
      `↑intOrder` — i.e. that `OfNat ↑intOrder 1` synthesizes at reducible transparency *through
      the `CoeSort` projection*. Probe both `F.TaskRel w 1 u` for `(F : FrameOver intOrder)` and a
      bare `(x : ↑intOrder) + 1`. Also probe the `TemporalOrder.of ℤ` spelling against the literal
      `⟨ℤ⟩` spelling and record which forms work, since the migration will write one of them ~76
      times.
- [x] **(b) `omega` and `Int` arithmetic at the fibre — STOP GATE.** At `(F : FrameOver intOrder)`,
      check that (i) an `omega` goal over `↑intOrder`-typed hypotheses closes, or failing that
      (ii) that `ℤ`-typed binders fed to `F.TaskRel` unify and let `omega` see `ℤ` — the v01
      Phase 2 working form, expected to apply here precisely because it failed only for abstract
      bundled frames. Record which of (i)/(ii) holds; (ii) alone is a pass, (i) is a bonus.
      Reproduce at least one real shape from `IntNormalForm.lean` (e.g. `step F w u := F.TaskRel w 1 u`
      and an `iter`-style arithmetic step).
- [x] **(c) Instance resolution through the projections.** Check `attribute [instance]` on the four
      `TemporalOrder` projections creates no diamond and no loop: (i) at `↑intOrder`, where the
      projection instance and `Int`'s own instances both apply; (ii) at `↑D` for an **abstract**
      `(D : TemporalOrder)`; (iii) at `↑(TemporalOrder.of D)` under ambient
      `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` binders, where two
      paths reach the same instance — confirm they unify by `rfl` at reducible transparency, as
      `probes/04`'s `(ofParam F).addCommGroup = inferInstance` did. Exercise `add_comm`, `le_total`,
      `add_le_add_right`, `exists_pair_ne`, `sub_self`, and `exists_between` under a
      `[DenselyOrdered ↑D]` binder. Watch for synthesis blow-up as well as outright failure: record
      `set_option synthInstance.maxHeartbeats` behaviour.
- [x] **(d) The flat accessors preserve the landed surface.** Declare `TaskFrame` as the total
      space with `@[reducible]` delegating accessors for `WorldState`, `TaskRel`, `worldNonempty`,
      the six axiom fields, and one derived API member, and check that already-migrated spellings
      still elaborate unchanged: `F.WorldState`, `F.TaskRel w d u`, `(d : F.Duration)` in binder
      position via `CoeSort`, `F.spherical` consumed **definitionally** by a `PartialHistory.step`-
      shaped goal, and a `structure Foo (F : TaskFrame)` with a `F.WorldState` field. Take at least
      two statement shapes verbatim from files v01 already landed.
- [x] **(e) The fibre inclusion is the constructor.** Check `FrameOver.toTaskFrame (F : FrameOver D)
      : TaskFrame := ⟨D, F⟩` elaborates, and that `(FrameOver.toTaskFrame F).Duration = D` and
      `(FrameOver.toTaskFrame F).toFibre = F` both close by `rfl`, and that
      `⟨G.Duration, G.toFibre⟩ = G` closes by `rfl` (structure eta — the total-space/Σ identity).
- [x] **(f) The transitional alias holds unmigrated code green.** With
      `@[reducible] def ParamTaskFrame (D : Type) [4 instances] : Type 1 := FrameOver (TemporalOrder.of D)`,
      check that generalized field notation resolves through the alias: `F.WorldState`,
      `F.TaskRel`, `F.spherical`, `F.comp` for `(F : ParamTaskFrame D)`, and that a
      `structure Bar {D} [4 instances] (F : ParamTaskFrame D)` still elaborates. If this fails,
      record the pre-specified fallback (keep `ParamTaskFrame` a genuine `structure` with
      `@[reducible]` conversions both ways, one mechanical touch per downstream file at its own
      phase) and proceed — this is **not** a stop gate.
- [x] **STOP GATE**: if (a) or (b) fails, do **not** proceed to Phase 1. Write the phase as
      `[BLOCKED]`, record a structured blocker (what failed, what was tried, why it is stuck, what
      decision is needed) in the phase body exactly as v01's Phase 5 blocker is written, and
      escalate. The whole design needs rethinking and no migration work may start. Failure of (c)
      or (d) is also a stop — a diamond or a lost accessor surface invalidates the "preserve the
      green state" premise — but record it separately, since the remedies differ.


#### Phase 0 Record — probe outcomes and the spellings later phases write against

Probe files: `probes/07_temporal-order-shape.lean` (concerns (a), (c)),
`probes/08_fibre-and-accessors.lean` (concerns (b), (d), (e), (f)). Both green under
`lake env lean`. Tree untouched; `lake build` exits 0 and `check-module-invariants.sh` reports
ALL CHECKS PASSED at the phase boundary.

| Probe | Verdict | Recorded spelling / detail |
|---|---|---|
| **(a) numerals at the fibre** — STOP GATE | **PASS** | All three spellings work: literal-field `@[reducible] def intOrder : TemporalOrder := ⟨ℤ⟩`, `TemporalOrder.of ℤ`, and the inline `(⟨ℤ⟩ : TemporalOrder)`. `(↑intOrder : Type) = ℤ` by `rfl`; `(x : ↑intOrder) + 1`, `(1 : ↑intOrder) = 1`, `R w 1 u` and `R w (-1) u` at `R : W → ↑intOrder → W → Prop` all elaborate. `↑intOrder` and `ℤ` are interchangeable in term position (`(x : ↑intOrder) + (y : ℤ)` elaborates, and `(x : ↑intOrder) : ℤ` is accepted). **Migration writes the literal-field `intOrder`.** |
| **(b) `omega`/`Int` arithmetic at the fibre** — STOP GATE | **PASS via (ii); (i) fails** | (i) `omega` on `↑intOrder`-**typed** hypotheses FAILS: `omega could not prove the goal: No usable constraints found`. (ii) `ℤ`-typed binders fed to `F.TaskRel` unify and `omega` sees `ℤ` — PASS. `IntNormalForm`'s real proofs (`step`, `taskRel_natCast_iff_iter`, `taskRel_eq_iter`, `iter_of_isStepPath`, `respects_of_isStepPath`) reproduce **verbatim** at `FrameOver intOrder`, `omega` calls intact and no `▸` added beyond the two the tree already has. |
| **(b) recovery form**, when a duration binder must be `↑intOrder`-typed | recorded | `change (0 : ℤ) < x at h` — a genuine hypothesis **type change** — restores `omega`. A `show`/`have` **ascription** does not (v01 finding 3 again): `show (x : ℤ) + 1 ≤ (y : ℤ)` plus `have h' : (x : ℤ) < (y : ℤ) := h` still leaves `omega` with no usable constraint. Recorded as a commented reproduction in `probes/08`. |
| **(c) instance resolution through the projections** | **PASS** | No diamond, no loop. `intOrder.addCommGroup = (inferInstance : AddCommGroup ℤ)` by `rfl`; `(TemporalOrder.of D).addCommGroup = (inferInstance : AddCommGroup D)` by `rfl` under ambient binders; `(↑(TemporalOrder.of D) : Type) = D` by `rfl`. `add_comm`, `le_total`, `add_le_add_right`, `exists_pair_ne`, `sub_self`, `abs_neg`, `abs_nonneg` all resolve at abstract `↑D`. Side conditions as statement-level binders work: `[DenselyOrdered ↑D]` → `exists_between`, `[Archimedean ↑D]` → `Archimedean.arch`. No synthesis blow-up: both `↑intOrder` and `↑(TemporalOrder.of D)` succeed under `set_option synthInstance.maxHeartbeats 2000`. |
| **(d) flat accessors preserve the landed surface** | **PASS, with one shape correction** | `F.WorldState`, `F.TaskRel w d u`, `(d : F.Duration)` and `(x y : F.Duration)` in binder position via `CoeSort`, `Nonempty F.WorldState` by `inferInstance`, and the axiom fields consumed **definitionally** (`ParamTaskFrame.Spherical F.TaskRel := F.spherical`) all hold. `PartialHistory` (`:91`) and `WorldHistory` (`:100`, including `extends`) reproduce verbatim over the total space, as do `stateAt` and the derived `forward_comp` reached by generalized field notation. **Correction the implementation must honour**: the Prop-valued accessors must be `theorem`s, not `@[reducible] def`s — Lean rejects `@[reducible]` on a proof (`failed to set reducibility status, 'worldNonempty' is not a definition`), and the `defProp` linter rejects `def` for a Prop. This is harmless: proof irrelevance means only the *declared type* matters, and that type cites the recorded predicate at `F.TaskRel`, which is itself a `@[reducible] def`. So: `@[reducible] def` for `WorldState`/`TaskRel`, plain `instance` for `worldNonempty`, `theorem` for the six axiom accessors and the derived API. |
| **(e) the fibre inclusion is the constructor** | **PASS** | `@[reducible] def FrameOver.toTaskFrame {D} (F : FrameOver D) : TaskFrame := ⟨D, F⟩`. `(F.toTaskFrame).Duration = D`, `(F.toTaskFrame).toFibre = F`, `(F.toTaskFrame).WorldState = F.WorldState`, `(F.toTaskFrame).TaskRel = F.TaskRel`, `(F.toTaskFrame).spherical = F.spherical` and the Σ-identity `⟨G.Duration, G.toFibre⟩ = G` all close by `rfl`. |
| **(f) the transitional alias holds unmigrated code green** | **PASS** | `@[reducible] def ParamTaskFrame (D : Type) [4 instances] : Type 1 := FrameOver (TemporalOrder.of D)` carries generalized field notation (`F.WorldState`, `F.TaskRel`, `F.spherical`, `F.comp`, `F.serial`), the `Nonempty` instance, and structure parameterization (`structure Bar {D} [4] (F : ParamTaskFrame D)`). `ParamTaskFrame ℤ = FrameOver intOrder` by `rfl`, and a `FrameOver intOrder` is accepted where a `ParamTaskFrame ℤ` is expected. **The Phase 2 fallback is not needed.** |

**Design consequence for the ℤ-fibre phases (7, 9, 10-Periodicity, 11, 15, 19)**: state every
duration binder that arithmetic touches as `(d : ℤ)`, not as `(d : ↑intOrder)`. Both elaborate
against `F.TaskRel`; only the former lets `omega` work. This is the Phase 7 contract's
"(b)(ii) only" branch, and it is the branch that holds.

**Baselines recorded at Phase 0**: `lake build` full clean rebuild wall time, and the four C2
flagship axiom profiles, both quoted in the phase commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: six probe concerns, expected as 3-5 probe files under `probes/`. The claim
that `probes/` currently holds `04`, `05` and `06` (so the next free number is `07`) is confirmed
with `ls specs/512_bundle_duration_into_taskframe/probes/`. No file under `FormalSystem/` or
`Tests/` is edited in this phase; if the phase finds itself editing one, that is a scope breach.

**Files to modify**:
- `specs/512_bundle_duration_into_taskframe/probes/07_*.lean` and successors (new)
- No tree files

**Verification**:
- Every probe file green under `lake env lean <path>`, with intended failures recorded as
  commented reproductions carrying their exact error text (the convention `probes/06` already uses).
- Standing contract items 1-3 (the tree is untouched, so this is trivially satisfied; run the
  gates anyway to establish the phase-0 baseline, including the `lake build` wall time).
- The phase commit message records, per probe, PASS/FAIL and the exact spelling that worked —
  those spellings are the contract every later phase writes against.

---

### Phase 1: `TemporalOrder` lands [COMPLETED]

**Goal**: The library has a name for `def:temporal-order`. Purely additive; nothing consumes it yet.

**Tasks**:
- [x] Create `FormalSystem/Semantics/TemporalOrder.lean` declaring `structure TemporalOrder` in the
      target shape, the `CoeSort` instance, and the `attribute [instance]` block for the four
      projections — using exactly the spellings Phase 0 recorded as working.
- [x] Add `TemporalOrder.of (D : Type) [4 instances] : TemporalOrder`, `@[reducible]`, as the
      transitional constructor the `ParamTaskFrame` alias needs. Mark it in its docstring as
      transitional-or-permanent pending Phase 20's review.
- [x] Declare the named temporal orders the tree actually needs, each `@[reducible]` and written
      with **literal fields** (research R1/R3; Phase 0(a) confirms): `intOrder` (ℤ), `ratOrder` (ℚ),
      `realOrder` (ℝ), and the `ℚ ×ₗ ℤ` order used by `CountermodelBase.lean:85` and
      `DiscreteCarrierProbe.lean:72`. Do not invent orders no site needs. *(deviation: altered — only
      `intOrder` is declared here. `ratOrder`, `realOrder` and the `ℚ ×ₗ ℤ` order are deferred to
      the phases that need them (13, 16), because declaring them in `Semantics/TemporalOrder.lean`
      would pull `Mathlib.Data.Real.Basic` and the lexicographic-product algebra into a module
      `TaskFrame.lean` imports, and therefore into the transitive import set of essentially every
      module in the tree — a build-cost regression the plan's own risk table warns against, taken
      for four constants with two consumers each. `intOrder` is in the core module because the ℤ
      layer is pervasive and `Mathlib.Algebra.Order.Group.Int` is already cheap.)*
- [x] Write the module docstring citing `def:temporal-order` verbatim ("a nontrivial totally
      ordered abelian group") and recording *why* the object is reified: the 4-binder list was the
      unnamed transcription of a paper object, and its absence is what made the fibre notion
      inexpressible. No task-number citation (C9).
- [x] Add the import to `FormalSystem/Semantics.lean` and a `## Submodules` docstring entry for the
      new module (C5/C14).
- [x] Add in-file `example`s pinning the Phase 0 facts that later phases depend on: numerals at
      `↑intOrder`, and instance recovery at `↑D` for abstract `D`. These are the regression guard
      for the design premise.

**Timing**: 1.5 hours

**Depends on**: 0

**Verification Tier**: full

**Scope Hypothesis**: exactly four named temporal orders are needed, from research F5's concrete-
frame inventory (ℤ 9 sites, ℚ 1, ℝ 1, `ℚ ×ₗ ℤ` 2). Confirm with
`grep -rn "ParamTaskFrame *\(ℤ\|Int\|ℚ\|ℝ\)\|×ₗ" FormalSystem Tests --include=*.lean | grep -v Boneyard`
before declaring them; a fifth carrier surfacing is a scope signal, not something to absorb.

**Files to modify**:
- `FormalSystem/Semantics/TemporalOrder.lean` (new)
- `FormalSystem/Semantics.lean` (import + submodule docstring entry)

**Verification**:
- Standing contract (1-9).
- `git diff --stat` shows one new file plus two lines in the aggregator.
- The in-file `example`s close.
- C8 unaffected (a new file in an existing directory); C15 anchor `def:temporal-order` resolves.

---

### Phase 2: `FrameOver` lands as the fibre; `ParamTaskFrame` becomes transitional [COMPLETED]

**Goal**: `FrameOver (D : TemporalOrder)` is the sole declaration site of the six frame axioms.
`ParamTaskFrame` becomes a `@[reducible] def` alias for `FrameOver (TemporalOrder.of D)`, holding
all 63 still-parameterized files green with no edits.

**Tasks**:
- [x] Revert the bare-relation predicate namespace `ParamTaskFrame.{Compositional, Converse, Serial,
      Limit, Spherical, NullityIdentity, Interpolates}` to `TaskFrame.*` (v01 Phase 1's deliberate
      over-reach, reversed one phase earlier than v01 planned). Mechanical token rename across live
      files. Record explicitly in the commit that this is a *restoration of the pre-512 name*, not a
      naming decision, and therefore not 507's territory. *(deviation: altered — the revert covers the
      whole bare-relation block, not only the named predicates: `Fib`, `mem_Fib`, `cone`,
      `mem_cone`, `cone_mono`, `Seg`, `mem_Seg`, `DirectedFamily`, `IsFiber`, `IsSegment`,
      `comp_of`, `forward_of_comp` and `interpolates_of_comp` sit in the same `namespace` block and
      were `TaskFrame.*` pre-512 too (verified against `7ecb341b9:.../TaskFrame.lean:172-447`), so
      splitting the block would strand half a namespace for Phase 20 to delete. 164 qualified
      renames across 16 files. `Converse`, `Limit` and `NullityIdentity` from the plan's list do
      not exist as declarations. Additionally `open TaskFrame` was added to the 7 remaining
      `namespace ParamTaskFrame` blocks, and 6 `open ParamTaskFrame` lines widened to
      `open ParamTaskFrame TaskFrame`, because the frame-level lemmas cite the predicates
      unqualified.)*
- [x] Declare `structure FrameOver (D : TemporalOrder)` in `Semantics/TaskFrame.lean` with
      `WorldState`, `worldNonempty`, `TaskRel : WorldState → D → WorldState → Prop`, and all six
      axiom fields citing the (now `TaskFrame.`-namespaced) bare-relation predicates
      **definitionally**.
- [x] Declare `structure FiniteFrameOver (D : TemporalOrder) extends FrameOver D` with
      `finite_world : Finite WorldState` (or the shape Phase 0 confirmed; probe M8's `FiniteTaskFrame`
      result is the precedent).
- [x] Replace `structure ParamTaskFrame` with
      `@[reducible] def ParamTaskFrame (D : Type) [4 instances] : Type 1 := FrameOver (TemporalOrder.of D)`,
      and `ParamFiniteTaskFrame` correspondingly. Both are transitional and are deleted in Phase 20.
      If Phase 0(f) failed, take the recorded fallback instead: keep both as genuine structures with
      `@[reducible]` conversions, and note in the commit that every later phase now owes one extra
      mechanical touch per file.
- [x] Reconcile the field-name mismatch: today's `ParamTaskFrame` has `nonempty`, the bundled form
      has `worldNonempty`. Pick `worldNonempty` (the bundled name, already landed in 86 files) and
      rename the ~N `\.nonempty` projection sites on frames. Enumerate them before editing. *(completed: 14 frame sites — 3
      `nonempty :=` in `TaskFrame.lean` plus its `ofParam`/`toParam`, 5 in
      `Examples/TemporalStructures.lean`, 2 in `ReynoldsBridge.lean`, 1 each in `ClockFrame.lean`,
      `IntNormalForm.lean`, `IntTransfer.lean`, `FlowFrame.lean`, `FMP/Filtration.lean` and
      `Verified/Bridge/RegionFrame.lean`, plus the `F.nonempty` projection in
      `PeriodicExtension.lean`. Enumerated by classifying every `^  nonempty :=` occurrence against
      its enclosing declaration's target type: 13 further occurrences belong to unrelated
      structures (`HintikkaRawChain`, `IsShuffleColouring`, `BFMCS`, …) and were left alone.
      `toParamTaskFrame` → `toFrameOver` at its 4 sites.)*
- [x] Keep `TaskFrame` (still `Duration : Type` at this point) and its `ofParam`/`toParam`/`CoeOut`
      working against the new `FrameOver`-backed `ParamTaskFrame`. This phase does **not** touch
      `TaskFrame`'s own definition — Phase 3 does.
- [x] Add in-file `example`s: the six axiom fields of `FrameOver` are the recorded predicates by
      `rfl`; `FrameOver (TemporalOrder.of D)` and the old `ParamTaskFrame D` field-for-field agree.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 63 live files mention `ParamTaskFrame` and 19 sites mention
`ParamFiniteTaskFrame` (5 files: `TaskFrame.lean` 7, `IntPresentation.lean` 6, `FMP/FiniteModel.lean` 3,
`FMP/FMP.lean` 2, `TaskModel.lean` 1), measured at HEAD `949411db1`. The predicate-namespace revert
is asserted to be a pure token rename over `ParamTaskFrame\.\(Compositional\|Converse\|Serial\|Limit\|Spherical\|NullityIdentity\|Interpolates\)`.
Confirm all three counts with `grep -rc` before editing. Under Phase 0(f) PASS, the expected
downstream edit count outside `TaskFrame.lean` is **zero** apart from the namespace revert and the
`nonempty` → `worldNonempty` rename; a non-zero remainder is a signal to stop and re-read, not to
widen the phase.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver`, `FiniteFrameOver`, the `ParamTaskFrame`
  alias, the predicate namespace, the new `example`s
- All live files carrying the `ParamTaskFrame.{predicate}` namespace or `.nonempty` on a frame —
  token renames only

**Verification**:
- Standing contract (1-9).
- `git diff --stat` shows only token renames outside `TaskFrame.lean`.
- `grep -rn "ParamTaskFrame\.\(Compositional\|Converse\|Serial\|Limit\|Spherical\|NullityIdentity\|Interpolates\)" FormalSystem Tests --include=*.lean | grep -v Boneyard`
  returns nothing.
- The `FrameOver` axiom-field `example`s close by `rfl`.

---

### Phase 3: `TaskFrame` becomes the total space [COMPLETED]

**Goal**: `TaskFrame` is `⟨Duration : TemporalOrder, toFibre : FrameOver Duration⟩`, the inclusion
is the constructor, and every one of v01's 86 landed files still compiles — most of them untouched.

**Tasks**:
- [x] Redefine `structure TaskFrame` as the total space. Delete the four algebra fields and the
      `WorldState`/`worldNonempty`/`TaskRel`/six-axiom fields from it; they now live in `FrameOver`.
- [x] Declare the `@[reducible]` delegating accessors in `namespace TaskFrame`: `WorldState`,
      `worldNonempty` (as an `instance`), `TaskRel`, `nullity_identity`, `comp`, `converse`,
      `serial`, `limit`, `spherical`. Use the exact spellings Phase 0(d) confirmed.
- [x] Re-express the bundled derived API (`forward_comp`, `interpolates`, `nullity`,
      `backward_comp`) over the accessors, with the same proofs. Where a fibre-level twin is the
      better home, declare it on `FrameOver` and let `TaskFrame`'s be the delegating spelling —
      generalized field notation never crosses between them, so both spellings must exist wherever
      both are used.
- [x] Declare `@[reducible] def FrameOver.toTaskFrame {D : TemporalOrder} (F : FrameOver D) :
      TaskFrame := ⟨D, F⟩` as the **canonical inclusion**, with a docstring recording that it is
      definitionally the constructor and that this is what replaces v01's `CoeOut` device.
- [x] Redefine `FiniteTaskFrame` in the corresponding total-space shape over `FiniteFrameOver`,
      preserving whatever projection name its ~5 structure-projection sites use. Enumerate those
      sites before editing.
- [x] Re-express `TaskFrame.ofParam` / `.toParam` / `instCoeOutParamTaskFrame` against the new
      shape (`ofParam F` is now literally `⟨TemporalOrder.of D, F⟩`). They stay only as
      scaffolding for `ParamTaskFrame`, and die with it in Phase 20.
- [x] Move the four definitional-content `example`s (v01's `TaskFrame.lean:1501-1511` descendants)
      to their correct home: state them at `FrameOver`, where the axiom fields now live, and keep a
      bundled spelling of each so the Step Lemma's consumption of `F.spherical` stays pinned at
      **both** levels.
- [x] Add `example`s pinning the Σ-identity: `⟨F.Duration, F.toFibre⟩ = F` by `rfl`, and the
      `toTaskFrame` round-trip facts from Phase 0(e).
- [x] Repair whatever of the 86 landed files the accessors do **not** cover. Expected surface:
      concrete-frame *construction* sites (field syntax `{ Duration := ℤ, WorldState := … }` must
      become `⟨intOrder, { WorldState := … }⟩`), and any site using `F.Duration` other than in a
      type position. Enumerate before editing; if the remainder exceeds one agent run, split at a
      named directory boundary as 3.1 and land the first half green.

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this is the phase whose blast radius is least predictable, and the estimate
is deliberately a hypothesis. Under Phase 0(d) PASS the expected edit surface outside
`TaskFrame.lean` is the bundled concrete-frame construction sites only — research F5 puts 27
concrete frame values in live `FormalSystem/` plus 4 in `Tests/`, but most are still on
`ParamTaskFrame` at this point and therefore untouched here. Confirm the *bundled* construction
sites with `grep -rn "TaskFrame.mk\|: TaskFrame :=\|: TaskFrame where" FormalSystem Tests --include=*.lean | grep -v Boneyard`
before editing. If the build after the `TaskFrame.lean` edit reports errors in more than ~6 files,
stop, record the actual list, and split into 3 and 3.1 rather than iterating a growing phase — this
is the exact failure mode v01's Phase 3 exhibited.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the total-space redefinition, accessors, inclusion,
  derived API, `example`s, transitional bridge re-expression
- The bundled concrete-frame construction sites the build names

#### Phase 3 Record — the blast radius, measured

`TaskFrame` is now `⟨Duration : TemporalOrder, toFibre : FrameOver Duration⟩`. The accessors are
`@[reducible] def` for `WorldState`/`TaskRel`, a plain `instance` for `worldNonempty`, and
`theorem`s for the six axioms plus the derived API — the shape correction Phase 0(d) recorded.

**Edit surface outside `TaskFrame.lean`: one file.** The plan budgeted for "the bundled
concrete-frame construction sites" and pre-authorized a 3/3.1 split above ~6 files. The build named
exactly one: `Semantics/ShiftSet.lean`'s `ShiftSet.frame`, which built a `TaskFrame` with flat
field syntax (`Duration := D`, `WorldState := …`, and the six axioms). All 86 files v01 landed on
`(F : TaskFrame)` — `PartialHistory`, `WorldHistory`, `TaskModel`, `Truth`, `H_F`, the
`Extension/` layer, the whole `Valid*` family and the soundness layer — compiled **untouched**,
which is the "preserve the green state" premise holding in practice rather than in probe.

`ShiftSet` was repaired by **splitting the definition rather than reindenting it**: the seven
field bodies moved verbatim into `ShiftSet.fibre : FrameOver (TemporalOrder.of D)`, and
`ShiftSet.frame : TaskFrame := S.fibre.toTaskFrame` is the inclusion. Not one proof changed, and
the `@[reducible]` that `hist`'s `respects_task` rewrite depends on is preserved on both. This
also front-loads what Phase 6 wants from `ShiftSet` anyway — a fibre-level value — without
touching its `D : Type` parameterization, which stays Phase 6's decision.

No split into 3.1 was needed.

**Verification**:
- Standing contract (1-9).
- The Σ-identity and round-trip `example`s close by `rfl`.
- The Step Lemma's consumption of `F.spherical` is still **definitional** at both `FrameOver` and
  `TaskFrame`. If it is not, that is drift: stop and report, do not work around it.
- C2 checked explicitly — this phase changes the type every flagship theorem quantifies over.

---

### Phase 4: Semantics core residue [COMPLETED]

**Goal**: The parts of the semantics core v01 deliberately left parameterized are restated at the
fibre or bundled, as each one's role dictates.

**Tasks**:
- [x] `WorldHistory.lean`: `ParamTaskFrame.HF` — v01 left it parameterized because dot notation
      does not coerce. Restate as `FrameOver.HF` **and** `TaskFrame.HF`, the latter delegating, so
      both `F.HF` spellings resolve (v01 finding 2). *(deviation: altered — the delegation runs the
      other way. `WorldHistory` is declared over the total space, so `TaskFrame.HF` is the
      primitive and `@[reducible] def FrameOver.HF (F) := F.toTaskFrame.HF` is the delegating
      spelling. Both `F.HF` spellings resolve, which is the requirement; the direction is forced
      by the existing layering, not chosen. `ParamTaskFrame.HF` no longer existed — v01 Phase 4
      had already moved it to `TaskFrame.HF`.)*
- [x] `TaskModel.lean`: `FiniteTaskModel`, left over `ParamFiniteTaskFrame`. Restate over
      `FiniteFrameOver D` / bundled `FiniteTaskFrame` as its consumers require.
- [x] `FrameAxioms.lean`: the `namespace ParamTaskFrame` half (bare-relation apparatus with no
      frame binder), 28 occurrences. Move it to the restored `TaskFrame.*` namespace or to
      `FrameOver` as each item's binders dictate.
- [x] `PartialHistory.lean`, `PartialHistoryOrder.lean`, `Truth.lean`: residual
      `ParamTaskFrame`/`TaskFrame` mentions only; confirm nothing is left needing the transitional
      alias in this layer.
- [x] Re-examine the three v01 F4-idiom sites in this layer's reach and record whether the
      explicit `@LT.lt ℤ _` forms can relax now that the ℤ layer will be at a fixed fibre. Relaxing
      is optional and must not be allowed to grow the phase.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: 6 files, with `ParamTaskFrame` counts at HEAD of `FrameAxioms.lean` 28,
`WorldHistory.lean` 5, `TaskModel.lean` 3, `PartialHistory.lean` 3, `Truth.lean` 0,
`PartialHistoryOrder.lean` 0. Confirm with `grep -rc` at phase start. *(Confirmed, and materially LOWER
than the hypothesis: `FrameAxioms.lean` 15 not 28, `TaskModel.lean` 2 not 3, the rest as stated.
The difference is Phase 2's namespace revert, which had already converted the
`ParamTaskFrame.{Spherical,Serial,Interpolates,…}` citations these files carry. Of the remainder
the only* code *items were `FrameAxioms.lean`'s `namespace ParamTaskFrame` block and
`WorldHistory.lean`'s three `ParamTaskFrame.{trivialFrame,natFrame}` helper histories; everything
else was docstring prose.)* Downstream call-site surface
is 55 files mentioning `WorldHistory`, 47 `TaskModel`, 68 `TruthAt` (research report scale table);
under the accessors these need no edit — confirm by building without touching them.

**Files to modify**:
- `FormalSystem/Semantics/{PartialHistory,PartialHistoryOrder,WorldHistory,TaskModel,Truth,FrameAxioms}.lean`

#### Phase 4 Record

- `FrameAxioms.lean`'s `namespace ParamTaskFrame` block held exactly one declaration,
  `nullity_of_serial_limit`, stated over a bare relation with no frame binder. Moved to
  `namespace TaskFrame` — the same pre-512 restoration Phase 2 performed on the apparatus block —
  and its 8 qualified references renamed across `TaskFrame.lean` and `Extension/Admissible.lean`.
- `FrameOver.HF` added beside `TaskFrame.HF`, with an `example` pinning that the two are the same
  type by `rfl`. This is what `PeriodicExtension.lean`'s `∃ σ : TaskFrame.HF F` at a fibre-typed
  `F` will need once Phase 20 removes the `CoeOut` that currently carries it.
- `FiniteTaskModel` restated over `FiniteFrameOver D` for `(D : TemporalOrder)`, with
  `FiniteTaskFrame.Model` as the bundled spelling. It has no consumers in the tree today; both
  spellings exist so Phase 10's filtration constructions can pick either.
- `PartialHistory.lean`, `PartialHistoryOrder.lean` and `Truth.lean` needed no code change,
  confirmed by building without touching them. `PartialHistory.lean` is now free of the string
  `ParamTaskFrame` entirely.
- The three v01 F4-idiom sites are not in this layer's reach; re-examination stays with Phases 9
  and 15, which own those files.

Downstream call-site surface — 55 files mentioning `WorldHistory`, 47 `TaskModel`, 68 `TruthAt` —
needed **zero** edits, confirmed by a clean build that touched none of them.

**Verification**:
- Standing contract (1-9).
- Both `F.HF` spellings resolve — one at `(F : FrameOver D)`, one at `(F : TaskFrame)`.
- No new lemma introduced to close a previously-closing proof.

---

### Phase 5: Validity, the BL layer, and the fixed-carrier validity predicates [COMPLETED]

**Goal**: The `Valid*` family, `TaskFrame.ValidOn`, and — newly expressible under the fibration —
the three fixed-carrier predicates v01 had to exclude, all restated. This is v01's Phases 3 and 8
merged: they are one dependency component, not two.

**This is the phase v01 mis-sized.** `valid` and its four siblings carry **explicit**
`∀ (D : Type) [4 instances]` binders *inside a Prop*, so every consumer supplies them positionally
and every consumer breaks at once — no coercion, no alias, and no accessor absorbs it. v01 measured
the blast radius at 17 files spanning what it had assigned to five different phases.

**Tasks**:
- [x] `Semantics/Validity.lean`: the five `Valid*` predicates and `TaskFrame.ValidOn` are already on
      bundled frames from v01; confirm they still elaborate under the total-space `TaskFrame` and
      repair the `∀ (D : Type) [4 instances]` remnants to `∀ (D : TemporalOrder)`.
- [x] Restate `satisfiable` / `SatisfiableAbs` (v01 exclusion 1) over `FrameOver D`. Under the
      fibration `satisfiable D Γ` — "satisfiable in a frame over a fixed `D`" — is expressible for
      the first time: `(D : TemporalOrder)` and `∀ F : FrameOver D`. This is a binder restatement,
      not the H1 collapse.
- [x] Restate `SoundnessLemmas/{Core,DenseValidity,FrameClassVariants}.lean`'s `IsValid D`
      (v01 exclusion 2) over `FrameOver D`, with the frame-class side condition as a statement-level
      instance binder `[DenselyOrdered ↑D]` (v01's recorded choice, preserved). Remove the
      `F.toParam` round-trips `Soundness.lean` needed to reach these lemmas — they become direct
      applications at `F.toFibre`.
- [x] Keep `valid_iff_forall_validOn` as the tie between the two notions — statement shape may
      change, content may not.
- [x] Repair the consumer sites the `Validity.lean` edit breaks: `Soundness.lean`,
      `BaseLanguageSoundness.lean`, `SetConsequence.lean`, `StrongCompleteness.lean`,
      `DiscreteNonCompactness.lean`, `SoundnessLemmas/CoValidity.lean`,
      `Automation/PrefilterSoundness.lean`, plus whatever the build names. The fixes are mechanical
      (`intro D _ _ _ _ F M τ hτ t` → `intro F M τ hτ t`; `h D F M τ hτ t` → `h F M τ hτ t`). *(deviation: altered — the predicted
      consumer set did not break. `valid` and its four siblings had already been moved to bundled
      frames by v01, so their `∀ (D : Type) [4 instances]` binders were gone before this phase
      started; the only such binders left in `Validity.lean` were on `satisfiable`,
      `SatisfiableAbs` and `unsatisfiable_implies_all{,_fixed}`, which have no live consumers
      outside the file. Of the eight files the plan named, ZERO needed repair. The single
      consumer the build did name was `Metalogic/Decidability/Verified/Decidable.lean`'s
      `truthAt_of_isValid` — Phase 14 territory, forced early by the `IsValid` reindex, and fixed
      by restating its hypothesis at `IsValid (TemporalOrder.of D) φ`, one line.)*
- [x] `BLValidity.lean`, `BLTruth.lean`, `DurationClassification.lean`: confirm; the last is
      entirely about duration **types** and may need only its binders reindexed to `TemporalOrder`,
      or nothing at all.
- [x] Do **not** rename `Dedekind` anywhere. Do **not** collapse the `Valid*` family.
- [x] **Split authorization**: if the phase exceeds one agent run, split at the named boundary
      *`Validity.lean` + BL layer* (Phase 5) / *the consumer files* (Phase 5.1), land the first half
      green, mark 5 `[PARTIAL]` and record the resume point.

**Timing**: 3 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: v01 measured this component at 17 files. At HEAD the files with residual
`ParamTaskFrame` in this territory are `Validity.lean` 9, `BaseLanguageSoundness.lean` 6,
`DiscreteNonCompactness.lean` 5, `Soundness.lean` 4, `SoundnessLemmas/Core.lean` 3,
`DurationClassification.lean` 2 — but the *breakage* surface is the consumer set, not the
`ParamTaskFrame` set. Take one build after the `Validity.lean` edit and let it enumerate the
consumers before editing any of them; treat a count materially above 17 as a signal to split, not
to absorb. *(Confirmed: `Validity.lean` 9,
`BaseLanguageSoundness.lean` 6, `DiscreteNonCompactness.lean` 5, `Soundness.lean` 4,
`SoundnessLemmas/Core.lean` 3, `DurationClassification.lean` 2 — every count exactly as stated.
The measured breakage surface was **1 file**, not 17: the accessor layer from Phase 3 plus v01's
already-bundled `Valid*` family absorbed the rest.)*

**Files to modify**:
- `FormalSystem/Semantics/{Validity,BLValidity,BLTruth,DurationClassification}.lean`
- `FormalSystem/Metalogic/{Soundness,BaseLanguageSoundness,SetConsequence,StrongCompleteness,DiscreteNonCompactness}.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/{Core,CoValidity,DenseValidity,FrameClassVariants}.lean`
- `FormalSystem/Automation/PrefilterSoundness.lean`
- plus whatever the post-edit build names

#### Phase 5 Record — v01's mis-sized phase, re-measured

**The blast radius was 1 file, not 17.** The plan's premise — that `valid` and its four siblings
carry explicit `∀ (D : Type) [4 instances]` binders inside a `Prop`, so every consumer breaks at
once — was true of the *pre-512* tree, but v01 had already moved that family onto bundled frames.
What remained carrying the loose binder list was only `satisfiable`, `SatisfiableAbs` and
`unsatisfiable_implies_all{,_fixed}`, none of which has a live consumer outside `Validity.lean`.
None of the eight consumer files the plan named needed repair.

What was done:

- **`satisfiable` is now the fibre predicate the fibration makes expressible for the first time**:
  `satisfiable (D : TemporalOrder) (Γ : Context)` over `∃ F : FrameOver D`. This is v01 exclusion 1
  discharged, and it is a binder restatement, not the H1 collapse — the `Valid*` family still has
  exactly its five pre-task members (`valid`, `ValidDense`, `ValidDiscrete`, `ValidDedekind`,
  `ValidDedekindDense`), none added, none merged. `SatisfiableAbs` collapses from a five-binder
  existential to `∃ D : TemporalOrder, satisfiable D Γ`.
- **`SoundnessLemmas.IsValid` is now over `FrameOver D` for `(D : TemporalOrder)`** — v01
  exclusion 2 discharged. `Core.lean`, `DenseValidity.lean` and `FrameClassVariants.lean` had their
  `variable {D : Type} [4 instances]` blocks collapsed to `variable {D : TemporalOrder}`, their
  four bundled binders deleted as now-automatic, and their frame-class side conditions moved to the
  carrier as `[DenselyOrdered ↑D]`, `[SuccOrder ↑D]`, `[IsSuccArchimedean ↑D]` and the rest —
  exactly v01's recorded statement-level-instance-binder choice, preserved.
- **The soundness-layer round-trips are gone**: `grep -rn "toParam" FormalSystem/Metalogic` returns
  **0**. `Soundness.lean`'s nine `F.toParam` applications are now `F.toFibre`, i.e. the second
  projection of the total space applied directly.
- `valid_iff_forall_validOn` is untouched — same statement, same proof term, no new lemma.
- No `Dedekind` identifier renamed (verified against the diff).

`BLValidity.lean`, `BLTruth.lean` and `DurationClassification.lean` needed no change; the last is
about duration *types* and its binders are not frame binders.

No split into 5.1 was needed.

**Verification**:
- Standing contract (1-9).
- `valid_iff_forall_validOn` closes with the same proof-term shape (no new lemmas).
- `grep -rn "toParam" FormalSystem/Metalogic --include=*.lean` shows the soundness-layer round-trips
  gone, replaced by direct `F.toFibre` applications.
- No `Dedekind` identifier renamed anywhere in the diff.
- The `Valid*` family still has exactly its pre-task membership — no predicate added, none merged.

---

### Phase 6: Extension layer and `ShiftSet` [COMPLETED]

**Goal**: `Semantics/Extension/` and `ShiftSet.lean` fully off the transitional alias, with the
Step Lemma's consumption of `F.spherical` remaining **definitional**.

**Tasks**:
- [x] Migrate `Extension/{Admissible,Constraint,Extension,Step}.lean` off `ParamTaskFrame`
      (13/14/10/7 occurrences at HEAD). `PeriodicExtension.lean` is ℤ-specific and belongs to
      Phase 9; exclude it here and record the exclusion.
- [x] Migrate `ShiftSet.lean` (9). Preserve v01's finding that `ShiftSet.frame` must be
      `@[reducible]` (its `hist` proof rewrites under `S.frame.Duration`), and that `ShiftSet`
      itself is a carrier-level structure — under the fibration it should be parameterized by a
      `TemporalOrder`, not by a bare duration type. Confirm which by reading the definition first.
- [x] Verify the Step Lemma still consumes `F.spherical` definitionally. If it does not, stop and
      report — that is drift, not a proof-engineering problem to work around.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 5 files, 53 `ParamTaskFrame` occurrences at HEAD
(`Constraint` 14, `Admissible` 13, `Extension` 10, `ShiftSet` 9, `Step` 7). Confirm with
`grep -rc`. This phase's independence from Phase 5 is a claim: confirm with
`grep '^import' FormalSystem/Semantics/Extension/*.lean FormalSystem/Semantics/ShiftSet.lean`
showing no `Validity` import (v01 verified this; re-verify, do not assume). *(Re-verified: no `Validity`
import in any of the five. Counts materially LOWER than the hypothesis — `Constraint` 5 not 14,
`Admissible` 4 not 13, `Extension` 10, `Step` 4 not 7, `ShiftSet` 7 not 9 — because Phase 2's
namespace revert had already converted the code citations; what remained was docstring prose plus
the `open ParamTaskFrame` lines.)*

**Files to modify**:
- `FormalSystem/Semantics/Extension/{Admissible,Constraint,Extension,Step}.lean`
- `FormalSystem/Semantics/ShiftSet.lean`

#### Phase 6 Record

**The Extension layer was already off `ParamTaskFrame` in substance.** Rather than assume it, the
claim was *tested*: `open ParamTaskFrame TaskFrame` was narrowed to `open TaskFrame` in all four
files and each was re-elaborated. All four still compile, which proves no name in them resolves
through the `ParamTaskFrame` namespace. All five files now contain the string `ParamTaskFrame`
zero times.

**The Step Lemma is untouched.** `F.spherical` is still applied directly at
`Extension/Step.lean:127`, and the file compiles — so the consumption is still definitional, which
is the drift check this phase existed to make.

**`ShiftSet` is re-parameterized by `TemporalOrder`** — the plan asked for this to be settled by
reading the definition, and the reading settles it *for*:

- `ShiftSet.fibre` now lands in `FrameOver D` instead of `FrameOver (TemporalOrder.of D)`, and
  `ofModel`'s target `ShiftSet F.Duration` typechecks on the nose. That removes `TemporalOrder.of`
  from two **permanent** (non-transitional) definitions — the transitional constructor should not
  be load-bearing in code that outlives Phase 20.
- The universe discipline the old docstring recorded is *preserved, not relaxed*:
  `TemporalOrder.carrier : Type`, so `↑D : Type` and `Carrier : Type` sit exactly where they did.
  The docstring now says so explicitly rather than justifying a bare-`Type` binder that no longer
  exists.

`Extension/PeriodicExtension.lean` stays excluded, per the phase's own Reasoned Exclusion; it is
Phase 9's.

**A miss worth recording.** The `ShiftSet` re-parameterization broke
`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`, and the phase build did **not**
catch it: `lake build` builds the default target only, not `BimodalTest`. The invariants gate did
catch it — `FAIL C1 lake build BimodalTest failed` — which is the second time this task that the
gate caught something a green `lake build` did not (the first was C6's isolation compile of
`PeriodicExtension.lean` in Phase 2). The per-phase build helper now builds `BimodalTest`
alongside the library so the two agree. The probe's fix is `ShiftSet (TemporalOrder.of (UD φ D))`,
which preserves what it measures: `TemporalOrder.of` demands exactly the four instances the old
binder list did, and they must still be synthesized on the ultraproduct.

**Verification**:
- Standing contract (1-9).
- Step Lemma proof unchanged in content; `F.spherical` used definitionally.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `Semantics/Extension/PeriodicExtension.lean` | ℤ-specific: it consumes `IntNormalForm`'s `HFofStepPath`/`IsStepPath`/`step`, all of which are stated at the ℤ fibre and are Phase 7/9 territory. Migrating its binders here makes those applications ill-typed. | v01 recorded the same exclusion for the same reason; 15 `ParamTaskFrame` occurrences, all ℤ-facing. |

---

### Phase 7: `IntNormalForm.lean` at the ℤ fibre [COMPLETED]

**Goal**: The first real fibre migration. `ParamTaskFrame ℤ` → `FrameOver intOrder` throughout the
ℤ normal-form machinery, with numerals and `omega` working exactly as Phase 0(a)/(b) recorded.

**PHASE CONTRACT (the ℤ-fibre idiom — state before editing, apply throughout)**: write the fibre as
`FrameOver intOrder` with `intOrder` the `@[reducible]`, literal-field constant from Phase 1. Write
numerals directly if Phase 0(a) passed for that spelling; otherwise use the recorded working form.
For arithmetic, use whichever of Phase 0(b)(i) or (ii) passed: if only (ii), state time variables
with explicit `(t : ℤ)` binders and let unification cross into `↑intOrder` at default transparency,
and write order relations as the explicit `@LT.lt ℤ _ a b` / `@LE.le ℤ _ a b` — a plain `(t : ℤ)`
*ascription* on an already-frame-typed term is a no-op and does not help (v01 deviation, Phase 2).
Never introduce a `▸` cast to make a numeral typecheck.

**Tasks**:
- [x] Migrate `Semantics/IntNormalForm.lean` (53 occurrences at HEAD), including
      `step F w u := F.TaskRel w 1 u` — the exact site the v01 blocker reproduced — and the
      `iter`/`iter_add` arithmetic core and `taskRel_eq_iter`.
- [x] Record in the commit, per construct, which form of the phase contract was needed. This is the
      reference the six later ℤ-fibre phases copy; getting it wrong here is expensive downstream.
- [x] Confirm that no goal anywhere in the file is left depending on `omega` seeing an abstract
      duration type.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: 1 file, 53 `ParamTaskFrame` occurrences, 526 lines. Research F5 puts
`TaskFrame.ofStep` in this file's territory as a ℤ-carried concrete frame; confirm the per-file
concrete-frame inventory with `grep -n "ParamTaskFrame *\(ℤ\|Int\)" FormalSystem/Semantics/IntNormalForm.lean`
before editing. An unexpected extra concrete frame is a scope signal.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean`

#### Phase 7 Record — THE ℤ-FIBRE IDIOM, as it actually landed

**Which branch of the phase contract was needed: neither recovery form.** The file's arithmetic
binders were *already* written `(n : ℕ)`, `(d : ℤ)`, `(s t : ℤ)` — genuine `ℤ`, not frame-typed —
because they are the *statement's* binders, not the frame's. Phase 0(b)(ii) is exactly that shape,
so every `omega` in the file kept working with **zero** edits to any proof. `git diff` on this file
adds **0** occurrences of `▸` and removes 0.

**The recovery form is needed only where the binder comes from a frame axiom's own type** — as in
Phase 2's `ofStep.comp`, where `TaskFrame.Compositional` hands you `0 ≤ x` at `↑intOrder` and
`omega` drops it. That is the site class Phases 9, 10, 11, 15 and 19 should watch: not "the file
mentions ℤ", but "the hypothesis was produced by a frame field rather than written by the author".

What changed, mechanically:
- `ParamTaskFrame ℤ` → `FrameOver intOrder` throughout, and the file's three
  `namespace ParamTaskFrame` blocks → `namespace FrameOver`, so `F.step`, `F.taskRel_eq_iter`,
  `F.HFofStepPath` and the rest still resolve by dot notation on a fibre-typed `F`.
- 23 qualified renames across 5 files for the declarations that changed namespace
  (`step`, `step_def`, `taskRel_eq_iter`, `taskRel_natCast_iff_iter`, `taskRel_one_iff_step`,
  `ofStep`, `ofStep_step`, `ofStep_taskRel`, `HFofStepPath`, `HFofStepPath_path`,
  `mem_HF_iff_adjacent`, `isTotal_respects_iff_adjacent`, `iter_of_isStepPath`,
  `respects_of_isStepPath`, `IsStepPath`) — `IntPresentation.lean` 6, `IntNormalForm.lean` 13,
  `BiLasso/{Basic,Extend}.lean` 3, `PeriodicExtension.lean` 1.
- Two bare-relation helpers still living in `namespace ParamTaskFrame` in `TaskFrame.lean`
  (`limit_of_succOrder`, `spherical_of_finite`) had to be qualified at their two use sites, since
  they no longer sit in the enclosing namespace. They are Phase 20's to relocate.

**C6 caught a third one.** `PeriodicExtension.lean` — unreachable-but-manifested, so not covered by
`lake build` — had an unqualified `HFofStepPath` that resolved through the old namespace. Only the
invariants gate's isolation compile saw it. That is now three for three: Phase 2 (`omega`), Phase 6
(`BimodalTest`), Phase 7 (namespace resolution). A green `lake build` is not the gate.

**Verification**:
- Standing contract (1-9).
- `grep -n "▸" FormalSystem/Semantics/IntNormalForm.lean` shows no cast introduced by this phase.
- Every arithmetic goal discharges at `ℤ`, outside the frame application.

---

### Phase 8: `IntTransfer.lean`, and the base-change hypothesis [COMPLETED]

**Goal**: `IntTransfer.lean` at the fibre, and an answer to the question of whether it is already
base change along a temporal-order morphism.

**HYPOTHESIS TO VERIFY, NOT ASSERT.** `Semantics/IntTransfer.lean` is *suspected* to already be
base change along a temporal-order morphism, written by hand without the name — the shape that
prompts the suspicion is `ParamTaskFrame.map (F : ParamTaskFrame D) (e : D ≃+o E) : ParamTaskFrame E`
(`:88`) with `TaskModel.map` (`:140`), `WorldHistory.map` (`:147`), `WorldHistory.comap` (`:203`),
`Aligned` (`:178`) and `truthAt_map` (`:254`) around it. **Check this against the actual file.** If
it holds, a portion of the file becomes an instance of a general construction
(`FrameOver.baseChange` along a `TemporalOrder` isomorphism) rather than bespoke code. If it does
not hold, say so explicitly in the phase record and migrate the file mechanically. Do not assume
either outcome, and do not let the general construction grow beyond what the file's existing
content already proves — a *new* theory of temporal-order morphisms is out of scope.

**Tasks**:
- [x] Read `Semantics/IntTransfer.lean` end to end and record the verdict on the hypothesis, with
      evidence (which declarations are instances of base change and which are not).
- [x] Migrate the file to the fibre: `ParamTaskFrame D` → `FrameOver D` with `(D : TemporalOrder)`,
      and `≃+o` transport reindexed accordingly. Note that `ValidInt` (`:336`) and
      `validDiscrete_iff_validInt` (`:356`) tie this file to Phase 5's `Valid*` work.
- [x] If the hypothesis holds: introduce the named construction, restate the existing declarations
      as its instances, and confirm every downstream consumer still closes with the same proof.
      Content may not change — this is a renaming of an existing construction, not a generalization.
- [x] If it does not hold: record why, migrate mechanically, and add nothing.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: 1 file, 31 `ParamTaskFrame` occurrences, 367 lines, with `ParamTaskFrame.map`
at `:88` the one `E`-transported concrete frame (research F5). The hypothesis that this file is
base change is *unverified* and this phase's first task is to settle it; the phase must produce a
verdict either way, and a phase that ends without one is incomplete.

**Files to modify**:
- `FormalSystem/Semantics/IntTransfer.lean`

#### Phase 8 VERDICT — is `IntTransfer.lean` already base change along a temporal-order morphism?

**Verdict: only along ISOMORPHISMS — and that restriction is forced, not incidental. No general
base-change construction is hiding here, and none was introduced.**

*Where the suspicion is right.* `FrameOver.map F e` leaves `WorldState` alone and precomposes
`TaskRel`'s duration argument with `e.symm`. As a construction that **is** reindexing — base change
along `e.symm : ↑E → ↑D`, carrying the fibre over `D` to the fibre over `E`. The fibration
vocabulary does name something already present.

*Where it is wrong, with declaration-level evidence.* The construction does not survive weakening
`e` to a one-directional morphism, and the obstruction localizes to a single axiom. From the field
proofs of `FrameOver.map`:

| field | what the proof uses | what it needs of `e` |
|---|---|---|
| `nullity_identity`, `converse` | `map_zero`, `map_neg` | a group hom |
| `comp`, `serial`, `spherical` | `map_le_map_iff e.symm` (`.mpr` direction) | `e.symm` order-reflecting |
| **`limit`** | `map_lt_map_iff e` **and** `map_lt_map_iff e.symm` | **both directions** |

***Limit* is the axiom that forces the isomorphism.** Its hypothesis is instantiated at `e x` —
pushing a duration *forward* — while its witness is produced as `e.symm n`, pulling one *back*. A
base change along a `g : ↑E → ↑D` with no inverse has nothing to instantiate the hypothesis with.
This is not a proof artifact: *Limit* asserts that every positive cone shrinks to a point, and a
non-surjective reindexing can omit exactly the small durations that witness it.

Everything downstream inherits the restriction. `WorldHistory.comap` — and through it the `box`
case of `truthAt_map`, the only case that touches it — consumes `e` **forward**. So `truthAt_map`
is an equivalence of fibres induced by an isomorphism of bases, not a functorial action of a
morphism.

*Action taken, per the plan's instruction not to let the construction outgrow what the file
proves.* The file was migrated to the fibre and **nothing was added**. No `FrameOver.baseChange`,
no theory of temporal-order morphisms. What the module contains, now said in its own docstring, is
that **the fibres over isomorphic temporal orders are equivalent** — at the frame (`map`), model
(`TaskModel.map`), history (`map`/`comap`/`Aligned`) and truth (`truthAt_map`) levels.

*Consequence for downstream scope.* A general base-change theory is **new mathematics**, not a
refactor: it would require re-proving *Limit* under whatever weaker hypothesis turns out to
suffice. Recorded here so 507/513 can size it as new work rather than expecting Phase 8 to have
delivered it.

**One migration detail worth carrying.** `validDiscrete_iff_validInt` needed its transport
ascribed at `↑intOrder` rather than at `ℤ` (`let e : ↑F.Duration ≃+o ↑intOrder := intIso`), plus
explicit `(D := F.Duration) (E := intOrder)`: Lean cannot invert `↑E ≟ ℤ` to recover
`E := intOrder`, since `↑E` is not a pattern. Expect the same wherever a ℤ-typed object has to
meet a `TemporalOrder`-indexed one.

`#print axioms FormalSystem.Semantics.validDiscrete_iff_validInt` =
`[propext, Classical.choice, Quot.sound]` — unchanged, as the phase requires.

**Verification**:
- Standing contract (1-9).
- The verdict on the base-change hypothesis is recorded in the phase body and the commit message,
  with the declaration-level evidence.
- If a general construction was introduced, `#print axioms` on `validDiscrete_iff_validInt` is
  unchanged.

---

### Phase 9: `PeriodicExtension.lean` and `IntPresentation.lean` [NOT STARTED]

**Goal**: The two remaining direct ℤ-fibre consumers of `IntNormalForm` migrated.

**Tasks**:
- [ ] Migrate `Semantics/Extension/PeriodicExtension.lean` (15 occurrences), excluded from Phase 6.
      Re-examine v01's `@LT.lt ℤ _` restatements here: the duration is at a fixed fibre again, so
      some may relax. Optional; do not grow the phase.
- [ ] Migrate `Metalogic/Decidability/IntPresentation.lean` (22 `ParamTaskFrame` + 6
      `ParamFiniteTaskFrame`), including `IntPresentation.toTaskFrame` and
      `IntPresentation.toFiniteFrame` — two ℤ-carried concrete frames. Under the fibration these
      naturally become `FrameOver intOrder` / `FiniteFrameOver intOrder` values, with the inclusion
      into `TaskFrame` available as `.toTaskFrame` where a total-space value is wanted. Preserve the
      existing names if their consumers use them.
- [ ] Apply the Phase 7 contract verbatim.

**Timing**: 2 hours

**Depends on**: 7, 6

**Verification Tier**: full

**Scope Hypothesis**: 2 files, 37 `ParamTaskFrame` + 6 `ParamFiniteTaskFrame` occurrences at HEAD.
`IntPresentation.toTaskFrame`'s name will now be ambiguous between "the fibre value" and "the total-
space value"; decide the naming *before* editing and record the decision, since ~14 BiLasso files
consume it in Phase 15.

**Files to modify**:
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean`
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean`

**Verification**:
- Standing contract (1-9).
- The `IntPresentation` naming decision is recorded in the commit.

---

### Phase 10: The finite-model-property family [NOT STARTED]

**Goal**: `Decidability/FMP/` at the fibre, with the filtration constructions reindexed.

**Tasks**:
- [ ] Migrate `Metalogic/Decidability/FMP/{Filtration,FiniteModel,Periodicity,FMP}.lean`
      (14/8/4/2 `ParamTaskFrame`, plus 3+2 `ParamFiniteTaskFrame`).
- [ ] `FiniteFilteredTaskFrame` / `RefinedFilteredTaskFrame` / `filteredFiniteFrame` are
      type-variable-carried, so the ℤ contract does not apply to them — they become
      `FiniteFrameOver D` values for an abstract `(D : TemporalOrder)`. `Periodicity.lean` is the
      ℤ-facing half; apply the Phase 7 contract there.
- [ ] C2 checked explicitly: FMP sits immediately below the flagship completeness theorems.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: 4 files, 28 `ParamTaskFrame` + 5 `ParamFiniteTaskFrame` occurrences, of which
4 of the live `FiniteTaskFrame` values (research F5). Confirm the finite-frame inventory with
`grep -rn "ParamFiniteTaskFrame\|FiniteFrameOver\|FiniteTaskFrame" FormalSystem/Metalogic/Decidability --include=*.lean`
at phase start.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/{Filtration,FiniteModel,Periodicity,FMP}.lean`

**Verification**:
- Standing contract (1-9), with C2 named explicitly in the phase commit.

---

### Phase 11: `ReynoldsBridge.lean` [NOT STARTED]

**Goal**: The largest ℤ-facing file in the tree migrated to the fibre.

**Tasks**:
- [ ] Migrate `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (22 `ParamTaskFrame`
      occurrences at HEAD across 1352 lines) under the Phase 7 contract.
- [ ] **Split authorization**: if the file cannot be completed in one agent run, split at a named
      section boundary, land the first half green, mark the phase `[PARTIAL]` and record the split
      point in the commit. Do not end the phase red.

**Timing**: 2.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: 1 file, 1352 lines, 22 `ParamTaskFrame` occurrences measured at HEAD — note
this is materially lower than v01's stated 73, because v01's figure counted `TaskFrame` tokens
before the Phase-1 rename. Confirm with `grep -c` at phase start and treat the lower figure as the
live one.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`

**Verification**:
- Standing contract (1-9).

---

### Phase 12: `FlowFrame.lean` and the canonical task relation [NOT STARTED]

**Goal**: The abstract half of the canonical-construction layer off the transitional alias.

**Tasks**:
- [ ] Migrate `Metalogic/Algebraic/FlowFrame.lean` (31 occurrences), including `bundleFlowFrame`
      — a type-variable-carried concrete frame, so it becomes a `FrameOver D` value for abstract
      `(D : TemporalOrder)` and the ℤ contract does not apply.
- [ ] Migrate `Metalogic/Bundle/CanonicalTaskRelation.lean` (6).
- [ ] Do not rename `Dedekind`, even where the fibration makes a different word read more naturally.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: 2 files, 37 `ParamTaskFrame` occurrences at HEAD. The claim that both are
abstract (no ℤ-carried frame) is from research F5's table; confirm with
`grep -n "ℤ\|Int" FormalSystem/Metalogic/Algebraic/FlowFrame.lean FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean`
before assuming the ℤ contract is unnecessary.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean`

**Verification**:
- Standing contract (1-9).

---

### Phase 13: BXCanonical, Chronicle, and the countermodel bases [NOT STARTED]

**Goal**: The flagship-theorem territory migrated. Highest drift risk in the plan.

**Tasks**:
- [ ] Migrate `Metalogic/BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`
      (1/3/1). `CompletenessDedekind.lean:76` carries the single `ℝ` frame and
      `DiscreteCarrierProbe.lean:72` a `ℚ ×ₗ ℤ` frame — both become `FrameOver realOrder` /
      `FrameOver` at the `ℚ ×ₗ ℤ` order declared in Phase 1.
- [ ] Migrate `Metalogic/BXCanonical/Chronicle/{ChronicleMonadicBridge,MCSMixedCase,ChronicleToCountermodelBasic}.lean`
      (2/1/1).
- [ ] Migrate `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` (2; the second
      `ℚ ×ₗ ℤ` frame at `:85`). Its arithmetic is not `omega`-discharged, so the relevant half of
      the ℤ contract is the explicit-binder half, not the `omega` half.
- [ ] Verify each of the four flagship theorems' axiom profiles **individually** with
      `#print axioms`, not by relying on the aggregate gate output.

**Timing**: 2 hours

**Depends on**: 12, 11

**Verification Tier**: full

**Scope Hypothesis**: 7 files, ~11 `ParamTaskFrame` occurrences at HEAD — small in tokens, large in
risk, because all four C2 flagship theorems live in or immediately above this territory. Confirm
the flagship theorem locations against `scripts/check-module-invariants.sh:139-149` before editing.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/{ChronicleMonadicBridge,MCSMixedCase,ChronicleToCountermodelBasic}.lean`
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean`

**Verification**:
- Standing contract (1-9).
- Per-theorem `#print axioms` output for all four flagship theorems, compared to the C2 baseline at
  `scripts/check-module-invariants.sh:144-149` and quoted in the phase commit.

---

### Phase 14: The decidability bridge [NOT STARTED]

**Goal**: `Decidability/Verified/` and the remaining non-BiLasso decidability files migrated,
reusing `FrameConditionFor` rather than inventing a parallel abstraction.

**Tasks**:
- [ ] Migrate `Metalogic/Decidability/Verified/Bridge/{Carrier,RegionFrame,TruthLemma,Interpolate}.lean`
      (RegionFrame is the heavy one at 22 occurrences).
- [ ] `FrameConditionFor fc D` (`Carrier.lean:110`) becomes `FrameConditionFor fc ↑D` for a
      `(D : TemporalOrder)`, or a per-frame `FrameConditionFor fc ↑F.Duration`. **Reuse this
      abstraction; do not write a parallel `FrameClass.Sat`** (research F9).
- [ ] **Record, do not act on, the cross-task observation**: `class TemporalCarrier (fc) (D) [4 binders]`
      (`Carrier.lean:126`) carries exactly the four binders `TemporalOrder` now bundles, so under
      this design `TemporalCarrier` may reduce to `(fc : FrameClass) (D : TemporalOrder)` plus its
      two genuine fields — which is task 510's territory and may shrink 510 to a merge. Write the
      observation into the phase commit and this plan's metadata. Do not restructure
      `TemporalCarrier` in this task beyond the binder restatement.
- [ ] Migrate `Metalogic/Decidability/{CountermodelExtraction}.lean`,
      `Metalogic/Decidability/Verified/Decidable.lean`,
      `Metalogic/Decidability/Propositional/Decidable.lean`.
- [ ] Leave the `.Dedekind` arm naming untouched (507 renames it).

**Timing**: 2 hours

**Depends on**: 5, 10

**Verification Tier**: full

**Scope Hypothesis**: 7 files, ~32 `ParamTaskFrame` occurrences at HEAD (`RegionFrame` 22,
`Verified/Decidable` 4, `Propositional/Decidable` 3, `CountermodelExtraction` 2, `TruthLemma` 1,
`Interpolate` 1, `Carrier` 0). Confirm with `grep -rc`; note `Carrier.lean` carries the abstraction
without a frame binder, so it may need only the `FrameConditionFor` reindex.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/{Carrier,RegionFrame,TruthLemma,Interpolate}.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/Decidability/Propositional/Decidable.lean`
- `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean`

**Verification**:
- Standing contract (1-9).
- `grep -rn "class TemporalCarrier\|FrameConditionFor" FormalSystem` shows the existing abstraction
  reused, with no new `Sat`-shaped definition introduced.
- The 510 observation is recorded in the commit message.

---

### Phase 15: BiLasso [NOT STARTED]

**Goal**: The 14-file BiLasso directory at the ℤ fibre.

**Tasks**:
- [ ] Migrate `Metalogic/Decidability/BiLasso/*.lean` — `Basic, Agreement, Annotation, Assembly,
      BoxOracle, Check, Extend, Extraction, GoodCycle, Orbit, Realized, SmallModel, TruthLemma,
      Unfold`. The directory is uniformly ℤ through `IntPresentation.toTaskFrame`, so the Phase 7
      contract and Phase 9's naming decision both apply.
- [ ] Re-examine v01's `@LT.lt ℤ _` restatements in `Unfold.lean` and `TruthLemma.lean`: the
      duration is at a fixed fibre again, so they may relax. Optional.

**Timing**: 2 hours

**Depends on**: 9, 14

**Verification Tier**: full

**Scope Hypothesis**: 14 files, but only 7 `ParamTaskFrame` occurrences remain at HEAD
(`Basic` 2, `Extend` 2, `Realized` 1, `Unfold` 1, `Orbit` 1; the other 9 files are at 0) — the
directory largely reaches ℤ frames *through* `IntPresentation`, so the migration surface is the
`IntPresentation` interface, not per-file binders. Confirm with
`grep -rc "ParamTaskFrame\|IntPresentation" FormalSystem/Metalogic/Decidability/BiLasso/*.lean`
at phase start; if the true surface is the `IntPresentation` interface, this phase may be far
cheaper than its file count suggests — report that rather than manufacturing work.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/*.lean`

**Verification**:
- Standing contract (1-9).

---

### Phase 16: Independence [NOT STARTED]

**Goal**: The independence-results files migrated, including the single `ℚ` concrete frame.

**Tasks**:
- [ ] Migrate `Metalogic/Independence/{ClockFrame,LoopingDuration,CoNotPriorU}.lean` (11/9/2).
      `ClockFrame.lean:173` is the single `ℚ` concrete frame — it becomes a `FrameOver ratOrder`
      value; the explicit-binder half of the ℤ contract applies, the `omega` half does not.
- [ ] `LoopingDuration.lean` carries 3 of the 4 `Archimedean` binder sites (research F6); those are
      side conditions on the carrier and become `[Archimedean ↑D]`.
- [ ] Update `FormalSystem/Metalogic/Independence.lean` (aggregator) if its docstring names the
      structure.

**Timing**: 1.5 hours

**Depends on**: 5, 7

**Verification Tier**: full

**Scope Hypothesis**: 3 files + 1 aggregator, 22 `ParamTaskFrame` occurrences at HEAD. The
`Archimedean` site count is asserted at 4 tree-wide (research F6); confirm with
`grep -rn "Archimedean" FormalSystem --include=*.lean | grep -v Boneyard`.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/{ClockFrame,LoopingDuration,CoNotPriorU}.lean`
- `FormalSystem/Metalogic/Independence.lean`

**Verification**:
- Standing contract (1-9).

---

### Phase 17: `Examples/TemporalStructures.lean` — the concrete-frame zoo [NOT STARTED]

**Goal**: The single largest concentration of concrete frame values migrated to fibre values plus
inclusions.

**Tasks**:
- [ ] Enumerate the file's frame constants **first**
      (`grep -n "def .*Frame\|abbrev .*Frame" FormalSystem/Examples/TemporalStructures.lean`) and
      classify each as type-variable-carried or concretely-carried before editing a single one.
- [ ] Migrate: `trivialFrame`, `staticFrame`, `natFrame`, `genericTimeFrame`, `genericNatFrame`,
      `flipFrame`, `intTimeFrame`, `intNatFrame`, `intBoolFrame`, `multiFamTaskFrame*`,
      `regionFrame` and the rest. Type-variable-carried ones become `FrameOver D` values for
      abstract `(D : TemporalOrder)`; ℤ-carried ones become `FrameOver intOrder` values written with
      **literal fields** and `@[reducible]` (research R1/R3 — this is the form numerals need).
- [ ] Preserve every constant's existing name; consumers across the tree and `Tests/` use them.
- [ ] `def:frame-properties` is cited by this file (per `specs/paper-definitions-of-record.md`);
      keep the citation resolving and update the prose where the fibration changes what the
      encoding says (C15).
- [ ] **Split authorization**: if the file cannot be completed in one agent run, split at a named
      section boundary, land the first half green, mark `[PARTIAL]`, record the resume point.

**Timing**: 2 hours

**Depends on**: 7, 16

**Verification Tier**: full

**Scope Hypothesis**: 1 file, 550 lines, 70 `ParamTaskFrame` occurrences at HEAD, holding the
majority of research F5's 27 live concrete frame values. The classification into type-variable-
carried vs. concretely-carried is the load-bearing hypothesis and is confirmed by the enumeration
task above before any edit.

**Files to modify**:
- `FormalSystem/Examples/TemporalStructures.lean`

**Verification**:
- Standing contract (1-9).
- Every migrated concrete frame supports the numerals its consumers write at it — check by building
  the consumers, not by inspection.
- C15: the `def:frame-properties` citation still resolves.

---

### Phase 18: `FrameConditions/`, `ValidOver` deletion, and the aggregators [NOT STARTED]

**Goal**: The orphaned frame-conditions directory migrated, `ValidOver` deleted, and every
aggregator's docstring consistent with the new module set.

**Tasks**:
- [ ] Migrate `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean`
      (`Soundness.lean` 6 occurrences; the others near zero).
- [ ] **Delete** `FrameConditions.ValidOver` (`Validity.lean:59`), subsumed by bundled
      `TaskFrame.ValidOn` (research Recommendation 6; `511/reports/01` §S3). Repair its two bridges
      to `valid` in place — v01 already crossed them over `F.Duration` / `F.toParam` and those
      crossings become direct.
- [ ] Note but do not act on `FrameConditions.LinearTemporalFrame` (`FrameClass.lean:88`), the
      marker class research F8 identifies as "trying to be `TemporalOrder` and failing to be
      adopted". Under this design it is redundant; its removal is 507/513 territory. Record the
      observation.
- [ ] Update the aggregators `FormalSystem/{Semantics,Metalogic}.lean`,
      `FormalSystem/Metalogic/{Independence,Decidability}.lean`: the `## Submodules` prose still
      describes `ParamTaskFrame` as "Task frame structure `F = (W, T, ·)`" and must describe the
      fibration instead (C5/C14).

**Timing**: 1.5 hours

**Depends on**: 5, 12

**Verification Tier**: full

**Scope Hypothesis**: 4 `FrameConditions/` files + 4 aggregators, ~11 `ParamTaskFrame` occurrences.
Research review issue M1 asserts `FrameConditions/` has exactly one consumer (the library
aggregator); confirm with `grep -rl "FrameConditions" FormalSystem --include=*.lean | grep -v Boneyard`
before assuming the deletion of `ValidOver` is cheap.

**Files to modify**:
- `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean`
- `FormalSystem/{Semantics,Metalogic}.lean`, `FormalSystem/Metalogic/{Independence,Decidability}.lean`

**Verification**:
- Standing contract (1-9).
- `grep -rn "ValidOver" FormalSystem --include=*.lean | grep -v Boneyard` returns nothing.

---

### Phase 19: Tests [NOT STARTED]

**Goal**: The test suite at the fibre and green, with v01's `SemanticBenchmark.lean` fix and its
recorded decision both preserved.

**Tasks**:
- [ ] Migrate `Tests/BimodalTest/Semantics/{TaskFrameTest,SemanticPropertyTest,SphericalFiniteAxiomTest,TruthTest,DependentUltraproductProbe}.lean`,
      `Tests/BimodalTest/Property/Generators.lean`, `Tests/BimodalTest/Property.lean`,
      `Tests/BimodalTest.lean`. All four test concrete frames are ℤ-carried and delegating — apply
      the Phase 7 contract.
- [ ] **Preserve v01's `SemanticBenchmark.lean` work**: the `:50` name fix (`TaskFrame.trivial_frame`
      → `trivialFrame`) stays, and the decision **not** to wire the file into the test aggregator
      stays — wiring it changes what is built and is out of scope for a restatement refactor.
      Re-record the still-unimported status in the phase commit so it is not silently forgotten.

**Timing**: 1.5 hours

**Depends on**: 17, 15, 13

**Verification Tier**: full

**Scope Hypothesis**: 8-9 test files, 81 `ParamTaskFrame` occurrences at HEAD (`TaskFrameTest` 28,
`SemanticPropertyTest` 22, `SphericalFiniteAxiomTest` 16, `Generators` 11, `TruthTest` 2, plus
singletons). Confirm the aggregator's import list with `grep -n "import" Tests/BimodalTest.lean`
before deciding which files the build actually covers.

**Files to modify**:
- `Tests/BimodalTest/Semantics/*.lean`, `Tests/BimodalTest/Property*.lean`, `Tests/BimodalTest.lean`

**Verification**:
- Standing contract (1-9).
- `lake build` covers the test target and exits 0.
- `SemanticBenchmark.lean` elaborates under `lake env lean` even though it is not imported.

---

### Phase 20: Delete the transitional layer; documentation [NOT STARTED]

**Goal**: `ParamTaskFrame` and the whole transitional layer are gone; the documentation records the
fibration and its `def:frame` / `def:temporal-order` conformance argument.

**Tasks**:
- [ ] Confirm no live reference remains:
      `grep -rn "ParamTaskFrame\|ParamFiniteTaskFrame\|ofParam\|toParam" FormalSystem Tests --include=*.lean | grep -v Boneyard`
      must return only the declarations about to be deleted.
- [ ] Delete `ParamTaskFrame`, `ParamFiniteTaskFrame`, `TaskFrame.ofParam`, `TaskFrame.toParam`,
      and `instCoeOutParamTaskFrame`.
- [ ] Decide `TemporalOrder.of`'s fate: keep it if construction sites read better with it, delete it
      if every site now writes literal fields. Record the decision either way.
- [ ] Rewrite the `TaskFrame.lean` module docstring to record the fibration: `TaskFrame` is the
      total space of `TaskFrame → TemporalOrder`, `FrameOver D` is its fibre, `def:frame`'s
      `⟨W, 𝔇, ⇒⟩` unfolds as it does in the paper, and `def:frame-properties` is now predicable of
      a frame through its `Duration` component. Keep every paper anchor resolving (C15):
      `def:frame`, `def:frame#{Compositionality,Seriality,Limit,Spherical}`, `def:temporal-order`,
      `def:task-relation`, `def:directed`, `lem:nullity`. No task-number citation (C9).
- [ ] Update the 15 markdown files under `docs/` plus `README.md` that mention `TaskFrame`, so C14's
      documented counts and C12/C13's links stay correct.
- [ ] Leave `FormalSystem/Boneyard/` untouched; add C11 waivers only if the gate demands them.
- [ ] Run the **full** `bash scripts/check-module-invariants.sh` (no `--no-build`) and
      `bash scripts/check-paper-definitions.sh`.

**Timing**: 2 hours

**Depends on**: 19, 18, 14

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 15 markdown files mention `TaskFrame` (research F10). Confirm with
`grep -rl "TaskFrame" docs README.md | wc -l` at phase start, and treat a different count as a
signal that documentation drifted during the migration rather than as a number to overwrite.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — deletions plus module docstring rewrite
- `FormalSystem/Semantics/TemporalOrder.lean` — docstring finalization
- 15 markdown files under `docs/` plus `README.md`
- `scripts/boneyard-import-waivers.txt` (only if C11 requires)

**Verification**:
- Standing contract (1-9), with the **full** invariants run.
- `grep -rn "ParamTaskFrame" FormalSystem Tests docs README.md` returns nothing.
- C15 anchor resolution passes against `specs/paper-definitions-of-record.md`.
- `lake build` wall time within 25% of the Phase 0 baseline.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase boundary and at task completion.
- [ ] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED at task completion (full
      run, with build).
- [ ] **C2**: `#print axioms` for `FormalSystem.Metalogic.BXCanonical.{completeness,
      completeness_dense, completeness_discrete}` and
      `FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense` each equal
      `[propext, Classical.choice, Quot.sound]` — checked **per phase**, not only at the end, and
      individually (not via the aggregate gate output) in Phase 13.
- [ ] **C3**: zero structural `sorry` at every phase boundary. No strategic sorries are planned;
      `plan_metadata.skeleton` is `false`.
- [ ] **C9**: no task-number citation anywhere under `FormalSystem/`.
- [ ] **C14/C15**: documented axiom/sorry counts consistent across `docs/`, `README.md` and Lean
      docstrings; every paper anchor resolves, `def:temporal-order` included.
- [ ] The definitional-content `example`s close by `rfl` at **both** `FrameOver` and `TaskFrame`.
- [ ] The Σ-identity `⟨F.Duration, F.toFibre⟩ = F` closes by `rfl`.
- [ ] `grep -rn "ParamTaskFrame\|ofParam\|toParam" FormalSystem Tests --include=*.lean | grep -v Boneyard`
      returns nothing after Phase 20.
- [ ] No `▸` cast was introduced anywhere to make a numeral or an arithmetic goal typecheck.
- [ ] `lake build` wall time at Phase 20 within 25% of the Phase 0 baseline.

## Artifacts & Outputs

- `specs/512_bundle_duration_into_taskframe/plans/02_temporal-order-fibration.md` (this file)
- `specs/512_bundle_duration_into_taskframe/probes/07_*.lean` and successors (Phase 0)
- `specs/512_bundle_duration_into_taskframe/summaries/02_temporal-order-fibration-summary.md`
  (written at implementation completion)
- `FormalSystem/Semantics/TemporalOrder.lean` — new module: `TemporalOrder`, `CoeSort`, projection
  instances, the named temporal orders
- `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver`, `FiniteFrameOver`, total-space `TaskFrame`,
  flat accessors, `FrameOver.toTaskFrame`, rewritten module docstring
- ~63 further migrated live `.lean` files across `FormalSystem/` and `Tests/`
- Deleted: `ParamTaskFrame`, `ParamFiniteTaskFrame`, `TaskFrame.ofParam`, `TaskFrame.toParam`,
  `instCoeOutParamTaskFrame`, and `FormalSystem/FrameConditions/Validity.lean`'s `ValidOver`
- Updated: `FormalSystem/Semantics.lean` and three other aggregators; 15 markdown files under
  `docs/` plus `README.md`

## Rollback/Contingency

- **Per-phase**: every phase is one or more commits ending green. Roll a phase back with
  `git revert` of that phase's commits; all prior phases remain green and the tree buildable. Never
  use a destructive git operation on a dirty tree — snapshot first via
  `bash .claude/scripts/git-snapshot.sh 512`.
- **Phase 0 STOP**: if probe (a) or (b) fails, nothing has been edited and there is nothing to roll
  back. Record the structured blocker and escalate; the design needs rethinking before any tree
  work. This is the cheapest possible failure and it is why Phase 0 exists.
- **Mid-phase interruption**: mark the phase `[PARTIAL]`, record the resume point (file plus section
  boundary) in the progress file, and leave the last green commit as the tree state. Phases 5, 11
  and 17 pre-authorize an intra-phase split.
- **Whole-task abort**: because `ParamTaskFrame` survives as a reducible alias from Phase 2 to
  Phase 20, the tree is in a coherent, green, dual-spelling state at every intermediate boundary.
  Aborting mid-migration leaves a working build with the alias still present — an acceptable
  resting state, not a broken one. Aborting *before* Phase 3 leaves the tree in v01's landed state
  plus two additive modules, which is strictly better than where this revision started.
- **Drift detected** (a C2 profile changes, or a proof needs a genuinely new lemma): stop the phase,
  do not work around it, and report. Structure eta makes the fibre/total-space relation
  definitional, so legitimate restatement never requires new mathematical content.
