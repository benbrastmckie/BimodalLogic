# Research Report: Bundle the duration type into `TaskFrame`

- **Task**: 512 - bundle_duration_into_taskframe
- **Started**: 2026-08-31T00:00:00Z
- **Completed**: 2026-08-31T00:00:00Z
- **Effort**: ~2 hours research; implementation estimated 5-8 phases (see Recommendations)
- **Dependencies**: None blocking. Sequencing interaction with 507 (Dedekind -> Complete rename)
  and with the FrameClass-indexed-validity work (review issue H1).
- **Sources/Inputs**:
  - Lean sources: `FormalSystem/Semantics/{TaskFrame,PartialHistory,WorldHistory,TaskModel,Truth,Validity,FrameAxioms}.lean`,
    `FormalSystem/FrameConditions/{FrameClass,Validity,Soundness,Compatibility}.lean`,
    `FormalSystem/Metalogic/Decidability/Verified/Bridge/Carrier.lean`
  - `specs/reviews/review-2026-08-31-metalogic-systematicity.md` (issues H1, H2, H3, M1, M2)
  - `specs/511_research_frame_correspondence_infrastructure/reports/01_frame-correspondence-infrastructure.md` (S3, O1-O3, §5.1)
  - `scripts/check-module-invariants.sh` (C1/C2/C3/C15 gates)
  - Empirical: three Lean probe files written and executed for this report (below)
- **Artifacts**:
  - `specs/512_bundle_duration_into_taskframe/reports/01_bundle-duration-into-taskframe.md` (this report)
  - `specs/512_bundle_duration_into_taskframe/reports/01_probes.lean` (green)
  - `specs/512_bundle_duration_into_taskframe/reports/02_probes.lean` (green)
  - `specs/512_bundle_duration_into_taskframe/reports/03_probes.lean` (green)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Project Context

- **Upstream Dependencies**: `Mathlib.Algebra.Order.*` (the `AddCommGroup`/`LinearOrder`/
  `IsOrderedAddMonoid`/`Nontrivial` stack); nothing project-internal sits above `TaskFrame`.
- **Downstream Dependents**: 81 live (non-Boneyard) `.lean` files mention `TaskFrame`;
  55 mention `WorldHistory`, 47 `TaskModel`, 68 `TruthAt`, 19 `PartialHistory`. Plus 12
  Boneyard files (2 of which already fail to elaborate against the current field set) and
  15 markdown files under `docs/`/`README.md`.
- **Alternative Paths**: the parameterized `Sat : FrameClass -> TaskFrame D -> Prop` option,
  explicitly rejected in the task statement. Not re-litigated here; §Decisions records why the
  rejection survives contact with the evidence.
- **Potential Extensions**: frame morphisms, bisimulation, disjoint unions, category of frames
  (Finding F7); collapse of the 15 validity predicates / ~23 soundness theorems (review H1/H2).

## Executive Summary

- **The target shape elaborates exactly as written.** `structure TaskFrame` with
  `Duration : Type`, four instance-implicit algebra fields, `WorldState : Type` and the six
  existing axiom fields type-checks; instance-implicit fields are in scope for later fields'
  types, so `comp`/`limit`/`serial`/`spherical` still cite the bare-relation predicates
  *definitionally*. Verified in `01_probes.lean` P1-P2.
- **No universe change and no universe-polymorphism decision to make.** Bundled `TaskFrame` is
  `Type 1`, which is exactly what `TaskFrame D` already is. Keep both `Duration : Type` and
  `WorldState : Type` at `Type 0`; that matches `WorldState : Type` today and matches `valid`'s
  own `∀ (D : Type)` binder. Going polymorphic buys nothing and draws a `checkUnivs` linter
  warning (`01_probes.lean` P7).
- **The bridge to the current structure is a definitional isomorphism.** `ofParam`/`toParam`
  round-trip by `rfl` in both directions via structure eta (`01_probes.lean` P3). This makes a
  file-by-file migration possible with the build green at every step — the single most important
  planning fact in this report.
- **One real hazard, precisely located: instance synthesis at *concrete* frames.** Typeclass
  synthesis runs at *reducible* transparency, so at a concrete `ℤ`-carried frame the numeral `1`
  cannot be elaborated at `F.Duration`, and `omega` cannot recognise the type at all — even
  though `F.Duration = Int` and `F.addCommGroup = Int.instAddCommGroup` are both `rfl` at default
  transparency. Abstract frames are entirely unaffected. Fully characterised in
  `03_probes.lean` R1-R6, with a working idiom (R4/R9).
- **A cheap adjacent win: a `TemporalOrder` Prop-mixin.** `class TemporalOrder (D) [AddCommGroup D]
  [LinearOrder D] : Prop extends IsOrderedAddMonoid D, Nontrivial D` collapses the 4-binder list
  to 3 binders, is diamond-free (Prop-valued; `inferInstance = Int.instIsOrderedAddMonoid` by
  `rfl`), is accepted by existing 4-binder declarations, and is a direct transcription of the
  paper's `def:temporal-order`. Verified in `02_probes.lean` M6.
- **Scope is large but shallow.** 183 `TaskFrame D` occurrences, 80 `(D := …)` named-argument
  sites, 208 `D`-binder sites, 12 `variable` lines — but only **27 concrete frame values** exist
  in live code, and the frame-class side conditions live in only a handful of files.

## Context & Scope

`TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`
(`FormalSystem/Semantics/TaskFrame.lean:493`) takes the duration type as a parameter. The
consequence chain the task statement identifies is confirmed by the tree:

- `def:frame` reads `F = <W, D, =>>` — `D` is a *component*. The current encoding is
  non-conforming to the definition of record.
- No property of a single frame can mention its duration structure, so "dense"/"discrete"/
  "complete" are predicated of `D` alone, so validity quantifies over `D`
  (`Semantics/Validity.lean:94,206,248,301,336`), so correspondence is pushed to carrier level
  (`511/reports/01` §5.1, and `FrameConditions.ValidOver` at `FrameConditions/Validity.lean:59`
  is the orphaned artifact of that push).
- The symptom the review calls H1 — 15 validity predicates, 8 semantic-consequence variants,
  ~23 soundness theorems, all differing only in an inlined typeclass binder list — is the same
  disease. This report's `02_probes.lean` M9 shows the bundled form admits a single
  `FClass.Sat : FClass -> TaskFrame -> Prop` plus one `ValidIn`.

The empirical work below was done against the actual tree at commit `3365859e2`, using
`lake env lean` on three standalone probe files. All three are green as committed.

## Findings

### F1. The target structure elaborates verbatim, and the axiom fields keep their definitional content

`01_probes.lean` P1-P2. The declared shape (with `nonempty` promoted to an instance-implicit
`worldNonempty` field) type-checks. Two things worth pinning:

- Instance-implicit fields declared *before* the axiom fields are in scope for those fields'
  types, so `comp : TaskFrame.Compositional TaskRel` elaborates — the `0`, `+`, `≤`, `|·|` in the
  predicates resolve through the structure's own instance fields. This is what preserves
  `TaskFrame.lean`'s "definitional-content checks" section (`:1501-1511`), whose four `example`s
  are load-bearing for the Step Lemma (`Semantics/Extension/Step.lean`).
- `attribute [instance] TaskFrame.addCommGroup …` after the structure exports the algebra at use
  sites: `add_comm`, `le_total`, `add_le_add_right`, `exists_pair_ne`, `sub_self`, `exists_between`
  under a `[DenselyOrdered F.Duration]` binder all resolve on a bare `(F : TaskFrame)`
  (`03_probes.lean` R6).

### F2. Universe: `Type 1` before and after — no decision to make

`01_probes.lean` P1a and `03_probes.lean` R8: bundled `TaskFrame : Type 1`, and
`TaskFrame D : Type 1` today. The `Duration : Type u` / `WorldState : Type v` variant elaborates
(`Type (max (u+1) (v+1))`) but draws the `linter.checkUnivs` warning "universes u, v only occur
together", and buys nothing: `WorldState : Type` is already monomorphic, and `valid`/
`SemanticConsequence` already bind `∀ (D : Type)` with an explicit in-source comment ("Uses
`Type` (not `Type*`) to avoid universe level issues in proofs", `Validity.lean:92`).

**Recommendation: `Duration : Type`, `WorldState : Type`.** This is a *narrowing* relative to
today's `D : Type*`, and it is safe: no live construction instantiates `D` above `Type 0`. The
duration types actually used are `ℤ`/`Int` (77 sites), `ℚ` (6), `ℝ` (4), `ℚ ×ₗ ℤ` (2) and type
variables at `Type` or `Type*`-instantiated-at-`Type`.

### F3. The bridge is a definitional isomorphism — migration can be incremental

`01_probes.lean` P3. With

```
def TaskFrame.toParam (F : TaskFrame) : ParamTaskFrame F.Duration
def TaskFrame.ofParam {D} [insts] (F : ParamTaskFrame D) : TaskFrame
```

both round trips are `rfl`, and `(ofParam F).Duration = D` is `rfl`. Lean 4 structure eta makes
`TaskFrame.mk F.Duration F.addCommGroup … ` defeq to `F`, so there is no coherence obligation to
discharge and no transport lemma to write.

**Planning consequence.** The whole-tree refactor does *not* have to be a big-bang. Rename the
existing structure to `ParamTaskFrame`, introduce the bundled `TaskFrame` beside it with the two
bridge functions, then migrate one module layer at a time, each layer green and committed. The
bridge is deleted in the final phase along with `ParamTaskFrame`. This is the difference between
one 81-file dispatch that cannot be verified until the end, and 6-8 phases each with `lake build`
green — which is what the phase-sizing contract wants anyway.

### F4. THE HAZARD: instance synthesis at concrete frames runs at reducible transparency

This is the one finding that will cost real time if the plan does not anticipate it.

At a concrete `ℤ`-carried bundled frame `F`:

| Fact | Result | Evidence |
|---|---|---|
| `F.Duration = Int` by `rfl` | **passes** | `02_probes.lean` M1 |
| `F.addCommGroup = Int.instAddCommGroup` by `rfl` | **passes** | `02_probes.lean` M1 |
| `(x : F.Duration) + 0 = x` by `simp` | **passes** (`0` comes from the exported `AddCommGroup`) | `01_probes.lean` P4b |
| `(x : F.Duration) + 1` — elaborating the numeral `1` | **FAILS**: `failed to synthesize OfNat F.Duration 1` | `02_probes.lean` M1 |
| `omega` on a goal at `F.Duration` | **FAILS**: "No usable constraints found" | `03_probes.lean` R1a |

The cause is transparency, not a genuine diamond: everything is defeq at *default* transparency;
typeclass synthesis and `omega`'s type recognition operate at *reducible* transparency, where a
plain `def` does not unfold.

Mitigations, measured:

- **`abbrev` / `@[reducible]` on the frame constant fixes the `OfNat` failure** — but only if the
  *whole chain* down to a `TaskFrame.mk` application is reducible. `02_probes.lean` M2/M3 record
  the negative: an `abbrev` frame defined as `ofParam (…)` still fails, because `ofParam` is
  itself a non-reducible `def`. `03_probes.lean` R1/R3 record the positive: an `abbrev` written
  with literal field syntax, and a `@[reducible] def` written the same way, both work.
- **`omega` is not recoverable this way.** It needs the goal's type to be syntactically `Int`/
  `Nat`; neither `abbrev` nor an ascription-`show` (which inserts no cast, the types being already
  defeq) helps. `03_probes.lean` R1a records both negatives explicitly.
- **The idiom that always works: state concrete-frame lemmas at `Int`, never at `F.Duration`.**
  `03_probes.lean` R4/R9. An `Int`-typed variable or an `(3 : Int)`-ascribed literal *can* be fed
  to `F.TaskRel` (unification runs at default transparency), and arithmetic is discharged at `Int`
  outside the frame application. `theorem opaqueInt_rel (w u : F.WorldState) (d : Int) :
  F.TaskRel w d u ↔ w = u := Iff.rfl` elaborates and proves.
- **Abstract frames are entirely unaffected** (`03_probes.lean` R6). All the metatheory that
  quantifies `∀ F : TaskFrame` — soundness, completeness, canonical models — is untouched by this.

**Where the hazard actually bites**: the `ℤ`-specific machinery. `Semantics/IntNormalForm.lean`
(54 `TaskFrame` hits), `Semantics/IntTransfer.lean` (31), `Metalogic/Decidability/IntPresentation.lean`
(28), `Metalogic/Decidability/FMP/{Filtration,FiniteModel}.lean` (28/24),
`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` (73). These should be a dedicated
phase, and the plan should budget for it accordingly.

### F5. Concrete frame values: 27 in live code, 4 in Tests, 2 already-broken in Boneyard

Full inventory gathered for this report. Live `FormalSystem/` (non-Boneyard), 27 total —
19 built field-by-field, 4 delegating, 4 `example`-level:

| Duration | Count | Notable sites |
|---|---|---|
| type variable `D` | 12 | `trivialFrame` `:1213`, `staticFrame` `:1276`, `natFrame` `:1346`, `ShiftSet.frame`, `genericTimeFrame`, `genericNatFrame`, `multiFamTaskFrameGen`, `regionFrame`, `RefinedFilteredTaskFrame`, `FiniteFilteredTaskFrame`, `filteredFiniteFrame`, `bundleFlowFrame` |
| `ℤ`/`Int` | 9 | `TaskFrame.ofStep`, `flipFrame`, `intTimeFrame`, `intNatFrame`, `intBoolFrame`, `zTaskFrameV2`, `multiFamTaskFrame`, `IntPresentation.toTaskFrame`, `IntPresentation.toFiniteFrame` |
| `ℚ` | 1 | `clockFrame` (`Metalogic/Independence/ClockFrame.lean:173`) |
| `ℝ` | 1 | `CompletenessDedekind.lean:76` example |
| `ℚ ×ₗ ℤ` | 2 | `CountermodelBase.lean:85`, `DiscreteCarrierProbe.lean:72` |
| `E` (transported) | 1 | `TaskFrame.map` (`IntTransfer.lean:88`) |

4 are `FiniteTaskFrame`. Tests add 4, all `TaskFrame Int`, all delegating.

Two incidental defects surfaced and are worth recording (neither is this task's job to fix, but
both will be encountered):

- `FormalSystem/Boneyard/{ChainCompleteness/Bundle/SuccChainTaskFrame.lean:95,
  StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:267}` use the pre-generalization field
  set (`task_rel`, `forward_comp`) and would not elaborate against today's structure either. They
  are already dead; the migration should leave them dead rather than port them.
- `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` names `TaskFrame.trivial_frame`, which
  does not exist (live name is `trivialFrame`). The file is not imported by `Tests/BimodalTest.lean`,
  so the build does not catch it.

### F6. Binder inventory: one shape dominates, and the `variable`-line surface is small

Across live `FormalSystem/` + `Tests/`: **225** binder-bearing `AddCommGroup` occurrences in 70
files, across **30** distinct binder-list shapes. The canonical shape
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` accounts for **115** of
them (51%) — 64 declaration-level, 51 in `variable` lines. Only **12** `variable` lines carry
`TaskFrame D` directly.

The long tail is the frame-class side conditions, and it is concentrated:

| Side condition | `[K D]` sites | Role |
|---|---|---|
| `Nontrivial` | 270 | already a structure binder; becomes a field |
| `NoMaxOrder` / `NoMinOrder` | 89 / 47 | seriality (unbounded time) |
| `SuccOrder` / `PredOrder` / `IsSuccArchimedean` / `IsPredArchimedean` | 73 / 29 / 36 / 21 | discrete class |
| `DenselyOrdered` | 70 | dense class |
| `Archimedean` | 4 | `SoundnessLemmas/Separability.lean:97`, `Independence/LoopingDuration.lean:190,214,238` |
| `ConditionallyCompleteLinearOrder` | 2 | Dedekind/Complete class |

Under bundling these become either (a) Prop-valued hypotheses on the frame
(`(hd : DenselyOrdered F.Duration)`, introduced with `haveI` — `03_probes.lean` R7), or (b)
instance binders on the *statement* (`[DenselyOrdered F.Duration]` — R6). Both work. Prefer (a)
for anything that will later be an arm of a `FrameClass.Sat` match, since a match arm cannot
produce an instance binder.

### F7. Bundling delivers the capabilities that motivated it

`01_probes.lean` P6, `02_probes.lean` M9:

- Two frames with different durations quantified in one statement: elaborates.
- `structure BHom (F G : TaskFrame)` with `onDuration : F.Duration -> G.Duration` and
  `map_rel : ∀ w x u, F.TaskRel w x u -> G.TaskRel (onState w) (onDuration x) (onState u)`:
  elaborates. This is genuinely inexpressible in the parameterized form without an ad hoc
  two-duration binder pair.
- `FClass.Sat : FClass -> TaskFrame -> Prop` as a four-arm match on the frame's own `Duration`,
  and a single `ValidIn (fc : FClass) (φ : Formula)`: elaborates. This is the H1 collapse target.
- Per-frame properties `F.Dense`, `F.Complete`, `F.IsDiscrete` are ordinary predicates on a frame.

Note the interaction with `511/reports/01` §3 O1: `staticFrame` refutes *carrier-only*
correspondence, and it still will after bundling. Bundling does not resolve the correspondence
question; it makes the *textbook shape* `F ⊨ ax ↔ C(F)` statable, which report 02 of task 511
established is the right shape.

### F8. `TemporalOrder` mixin — adjacent, cheap, diamond-free, paper-conforming

`02_probes.lean` M6. All four checks pass:

```
class TemporalOrder (D : Type*) [AddCommGroup D] [LinearOrder D] : Prop
    extends IsOrderedAddMonoid D, Nontrivial D
```

- recovers `IsOrderedAddMonoid D` and `Nontrivial D` by `inferInstance`;
- an existing 4-binder declaration (`F.serial` on a `TaskFrame D`) accepts a 3-binder context;
- `(inferInstance : IsOrderedAddMonoid Int) = Int.instIsOrderedAddMonoid` is `rfl` — no diamond,
  because the class is Prop-valued and therefore proof-irrelevant;
- an `MFrame` with three instance fields instead of four works identically.

This is `def:temporal-order` verbatim ("a nontrivial totally ordered abelian group"). The tree
already gestures at it: `FrameConditions.LinearTemporalFrame` (`FrameClass.lean:88`) is a marker
class trying to be this and failing to be adopted (review issue M1: the whole directory has
exactly one consumer, the library aggregator).

**However — do not couple it to this task.** It touches 225 binder sites, whereas the bundling
refactor touches the ~208 `D`-binder sites *at the same time*, and doing both in one pass makes
every diff twice as hard to review. Recommend it as a follow-up task, or as an explicitly final,
separately-committed phase.

### F9. Prior art in-tree: `TemporalCarrier` already indexes carrier conditions by `FrameClass`

`Metalogic/Decidability/Verified/Bridge/Carrier.lean:126` defines
`class TemporalCarrier (fc : FrameClass) (D : Type) [4 binders]` with a
`frame_condition : FrameConditionFor fc D` field, where `FrameConditionFor` (`:110`) is a
four-arm match producing `PUnit` / `PLift (DenselyOrdered D)` / `DiscreteStructure D` /
`PLift (DenselyOrdered D) × PLift (HasLUBs D)`.

This is the H1 abstraction, built, working, and confined to the Decidability bridge. Under
bundling it becomes `FrameConditionFor fc F.Duration` — a per-frame condition — and the class
binder disappears. **The plan should reuse `FrameConditionFor` rather than inventing a parallel
`Sat`.** Note its `.Dedekind` arm already includes `DenselyOrdered`, matching
`ValidDedekindDense` and the warning in `ValidDedekind`'s docstring, and it will be renamed to
`.Complete` under 507.

### F10. Verification gates and what they require

`scripts/check-module-invariants.sh`:

- **C1** `lake build` exits 0.
- **C2** hard stop: `#print axioms` for four flagship theorems must equal
  `[propext, Classical.choice, Quot.sound]` — `Metalogic.BXCanonical.{completeness,
  completeness_dense, completeness_discrete}` and `Metalogic.BXCanonical.Chronicle.countermodel_dense`.
  Bundling introduces no new axiom source (structure eta and instance projections are definitional),
  so the profiles should be unchanged. Verify per phase, not only at the end.
- **C3** zero structural `sorry`. The zero-debt gate applies: no phase may land a `sorry`.
- **C14** documented axiom/sorry counts in `docs/`, `README.md`, *and* `.lean` docstrings must
  match. 15 markdown files mention `TaskFrame`; their prose will need updating.
- **C15** every paper-anchor citation must resolve against `specs/paper-definitions-of-record.md`.
  `TaskFrame.lean`'s module docstring is dense with `def:frame`, `def:temporal-order`,
  `def:task-relation`, `def:directed`, `lem:nullity` citations. **The bundling change strengthens
  conformance and the docstring must say so** — `def:frame` reads `F = <W, D, =>>`, so `D` as a
  field is the conforming encoding and the parameterized form was the deviation.

## Decisions

1. **Bundle, as specified.** The evidence supports the task statement's rejection of the
   `Sat : FrameClass -> TaskFrame D -> Prop` alternative: F7 shows frame morphisms and
   cross-duration quantification are genuinely unavailable without bundling, and F9 shows the
   binder-list proliferation the alternative would leave in place is already causing real
   duplication (H1's 15 + 8 + 23 count).
2. **`Duration : Type`, `WorldState : Type`** — no universe polymorphism (F2).
3. **Instance-implicit *fields* plus `attribute [instance]` projections**, not instance binders on
   the structure. The existing `nonempty` field docstring (`TaskFrame.lean:507-509`) already gives
   the reason and it applies verbatim to the algebra fields: a binder must be supplied at every
   mention of the type; a field is discharged once per frame.
4. **Migrate via the `ParamTaskFrame` bridge**, not big-bang (F3).
5. **Keep the `nullity_identity` field.** Its docstring settles that the field is derivable and
   retained for construction ergonomics. This refactor is a restatement; do not reopen that
   question inside it.
6. **Defer the `TemporalOrder` mixin to its own task** (F8).
7. **Do not port the two dead Boneyard frames** (F5); they do not elaborate today either.

## Recommendations

Prioritized, with the phase decomposition the plan should adopt. Each phase ends `lake build`
green and is committed.

1. **Phase 1 — Rename + bridge (no behaviour change).** Rename `TaskFrame` -> `ParamTaskFrame`
   and `FiniteTaskFrame` -> `ParamFiniteTaskFrame` tree-wide (mechanical, 183 + N sites). Declare
   the bundled `TaskFrame`/`FiniteTaskFrame` beside them with `toParam`/`ofParam` and the
   `attribute [instance]` block. Add the four definitional-content `example`s for the bundled
   form. Green, committed. ~1 agent run.
2. **Phase 2 — `Semantics/` core.** `PartialHistory`, `WorldHistory`, `TaskModel`, `Truth`,
   `FrameAxioms`. Each of these has exactly the shape
   `{D} [4 binders] (F : TaskFrame D)` -> `(F : TaskFrame)`; `02_probes.lean` M7 confirms the
   re-parameterised structures elaborate natively. Downstream sites keep working through the
   bridge where not yet migrated.
3. **Phase 3 — `Semantics/Validity.lean` + `Semantics/Extension/`.** The five `Valid*` predicates
   become `∀ F : TaskFrame, C F -> …`. `TaskFrame.ValidOn` (`Validity.lean:561`) loses its binder
   list entirely. Keep `valid_iff_forall_validOn` (`:622`) as the tie between the two notions.
   Step Lemma consumption of `F.spherical` must remain definitional.
4. **Phase 4 — the `ℤ`-specific machinery.** `IntNormalForm`, `IntTransfer`, `IntPresentation`,
   `Decidability/FMP/*`, `WeakCanonical/IntegerModel/ReynoldsBridge`. **Apply F4's idiom from the
   start**: state every concrete-frame lemma with an explicit `(d : Int)` binder, never at
   `F.Duration`, and discharge arithmetic at `Int` outside the frame application. Budget this as
   the largest phase.
5. **Phase 5 — `Metalogic/` soundness + canonical constructions.** Abstract frames only; F4 does
   not apply. `Soundness.lean`, `SoundnessLemmas/`, `BXCanonical/`, `StrongCompleteness.lean`,
   `SetConsequence.lean`, `Algebraic/FlowFrame.lean`.
6. **Phase 6 — `FrameConditions/` + `Examples/` + `Tests/`.** `FrameConditions/` is orphaned
   (review M1, one consumer) so it is cheap; `ValidOver` (`Validity.lean:59`) is the artifact
   511/reports/01 §S3 identifies and should be *deleted*, not migrated, since bundled
   `TaskFrame.ValidOn` subsumes it.
7. **Phase 7 — Delete the bridge and `ParamTaskFrame`.** Then docs: 15 markdown files, plus the
   `TaskFrame.lean` module docstring rewritten to record that `D`-as-a-field is `def:frame`
   conformance (F10, C15).
8. **Follow-up tasks (do not fold in):** the `TemporalOrder` mixin (F8); the H1 collapse of
   `Valid*`/`SetSemanticConsequence*`/soundness onto `FrameConditionFor`-indexed definitions (F9),
   which bundling *enables* but which is its own body of work.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| `OfNat`/`omega` failures at concrete `ℤ` frames burn a whole dispatch | **High** if unanticipated | F4 is fully characterised with a working idiom and green probe evidence (`03_probes.lean` R4/R9). Plan Phase 4 with the idiom stated as the phase contract. |
| Semantic drift — a "restatement" that quietly changes a theorem | Medium | C2 axiom-profile check per phase, not only at the end. The bridge round-trip being `rfl` means any drift is a *typechecking* failure, not a silent one. |
| Big-bang dispatch stalls with 81 files red | High if attempted | F3's bridge. Never let a phase end red. |
| Instance-projection loops or slow synthesis on `F.Duration` | Low | Probes exercised `add_comm`, `le_total`, `exists_between`, `sub_self`, `Decidable` on abstract and concrete frames with no pathology. Watch build times per phase regardless. |
| `nullity_identity` / field-set churn creeping in | Medium | Decision 5: field set is frozen for this task. Any field change is a separate task. |
| 507's `Dedekind -> Complete` rename colliding | Medium | 507 touches `Validity.lean` names; this task touches its binder lists. Sequence 507 first if both are live, or partition: 507 owns names, 512 owns binders. Flag to the orchestrator. |
| Boneyard files break | Certain, harmless | 12 Boneyard files mention `TaskFrame`; 2 already fail. C11 only requires imports to resolve or be waived. Leave them on `ParamTaskFrame` or waive. |

## Context Extension Recommendations

- **Topic**: Bundled-structure instance transparency in Lean 4.
  **Gap**: `.claude/context/project/lean4/` has no note on the reducible-vs-default transparency
  split for typeclass synthesis, which is the single most expensive surprise in this refactor and
  recurs for any bundled structure with a carrier field.
  **Recommendation**: add `context/project/lean4/patterns/bundled-structure-transparency.md`
  recording F4's table and the "state concrete-carrier lemmas at the concrete type" idiom.

## Appendix

### Probe files

All three are standalone (imported by nothing) and green under
`lake env lean <path>` at commit `3365859e2`:

- `specs/512_bundle_duration_into_taskframe/reports/01_probes.lean` — P1 structure elaboration,
  P2 instance projections, P3 bridge round-trip, P4 concrete-frame diamond, P5 downstream shape,
  P6 cross-duration quantification + frame morphism, P7 universe polymorphism.
- `specs/512_bundle_duration_into_taskframe/reports/02_probes.lean` — M1-M4 the four mitigations
  (two negative, recorded as commented reproductions), M5 abstract-hypothesis form, M6 the
  `TemporalOrder` mixin, M7 native `PartialHistory`/`WorldHistory`/`TaskModel`, M8 `FiniteTaskFrame`,
  M9 `FClass.Sat` + single `ValidIn`.
- `specs/512_bundle_duration_into_taskframe/reports/03_probes.lean` — R1-R3 reducibility
  characterisation, R4/R9 the working `ℤ` idiom, R5 carrier equation, R6 abstract frames
  unaffected, R7 `haveI` for frame-class hypotheses, R8 universe confirmation.

### Key source anchors

| Anchor | Path |
|---|---|
| `structure TaskFrame` | `FormalSystem/Semantics/TaskFrame.lean:493` |
| `structure FiniteTaskFrame` | `FormalSystem/Semantics/TaskFrame.lean:1472` |
| definitional-content `example`s | `FormalSystem/Semantics/TaskFrame.lean:1501-1511` |
| `structure PartialHistory` | `FormalSystem/Semantics/PartialHistory.lean:91` |
| `structure WorldHistory` | `FormalSystem/Semantics/WorldHistory.lean:100` |
| `structure TaskModel` | `FormalSystem/Semantics/TaskModel.lean:49` |
| `def TruthAt` | `FormalSystem/Semantics/Truth.lean:163` |
| `def valid` | `FormalSystem/Semantics/Validity.lean:94` |
| `def TaskFrame.ValidOn` | `FormalSystem/Semantics/Validity.lean:561` |
| `theorem valid_iff_forall_validOn` | `FormalSystem/Semantics/Validity.lean:622` |
| `def ValidOver` (to delete) | `FormalSystem/FrameConditions/Validity.lean:59` |
| `class TemporalCarrier` | `FormalSystem/Metalogic/Decidability/Verified/Bridge/Carrier.lean:126` |
| `def FrameConditionFor` | `FormalSystem/Metalogic/Decidability/Verified/Bridge/Carrier.lean:110` |
| C2 axiom baseline | `scripts/check-module-invariants.sh:144-149` |

### Scale measurements (live, Boneyard excluded)

| Measure | Count |
|---|---|
| files mentioning `TaskFrame` | 81 (+12 Boneyard) |
| `TaskFrame D` occurrences | 183 |
| `TaskFrame ℤ`/`Int`/`ℚ`/`ℝ` occurrences | 48 / 29 / 6 / 4 |
| `(D := …)` named-argument sites | 80 |
| `{D : Type` / `(D : Type` binder sites | 106 / 102 |
| `variable` lines carrying `TaskFrame D` | 12 |
| binder-bearing `AddCommGroup` occurrences | 225 in 70 files, 30 distinct shapes |
| concrete frame values (live / Tests / Boneyard) | 27 / 4 / 2 |
| markdown files mentioning `TaskFrame` | 15 |
