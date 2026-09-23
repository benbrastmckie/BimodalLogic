# Research Report: Task #656

**Task**: 656 - Refactor task frames: general frames with the four constraints as frame conditions, the constrained class named *regular*
**Started**: 2026-09-22T00:00:00Z
**Completed**: 2026-09-22T00:00:00Z
**Effort**: research round, ~2 hours wall clock; 2 probe files, 481 lines, 0 sorries, both compile with `lake env lean` at exit 0 and emit no warnings
**Dependencies**: 655 (completed), 651, 652, 654 (all completed)
**Sources/Inputs**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md` — Q5 ("What the Lean refactor should build", items 1–6) and Q6 (collision check + identifier scheme) are the primary inputs
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/*.lean` — six compiled, sorry-free probe files (1983 lines) that the counterexample and topology modules lift from
- `specs/656_refactor_task_frames_general_with_frame_constraints/.decisions.json` — two user-ratified decisions (build the topology here, not a follow-up; prefer the import-weight lever over per-declaration instance pinning)
- Lean tree: `FormalSystem/Semantics/TaskFrame.lean` (2358 lines), `TemporalOrder.lean`, `PartialHistory.lean`, `Extension/{Constraint,Admissible,Step,Extension}.lean`, `Validity.lean`, `ValidityLayer.lean`, `FrameClassValidity.lean`, `FrameProperty.lean`, `ShiftSet.lean`, `Correspondence/{Rigidity,RigiditySharpness,RigidityReal}.lean`, `Semantics.lean`, `Correspondence.lean`
- Infrastructure: `scripts/check-module-invariants.sh` (C1–C27), `scripts/module-invariants-allowlist.txt`, `docs/theorem-index.md`, `docs/reference/API_REFERENCE.md`, `docs/user-guide/architecture.md`
- lean-lsp / `lake env lean` for every probe; Mathlib pinned at `v4.33.0-rc1` (resolved `79d0395a`)
**Artifacts**:
- This report
- `specs/656_refactor_task_frames_general_with_frame_constraints/probes/RegularClass.lean` (259 lines) — the `class IsRegular` architecture, in miniature, mirroring the real `FrameOver`/`TaskFrame` shapes; compiles at exit 0
- `specs/656_refactor_task_frames_general_with_frame_constraints/probes/TopologyInstance.lean` (222 lines) — `instance : TopologicalSpace F.WorldState := nbhdTopology F.TaskRel` on the general frame, `Limit ↔ T1`, derived `T1Space`/`R0Space` on the regular class, and the `ℝ`-carrier keying probe; compiles at exit 0, `#print axioms` standard only
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The architecture compiles.** Stripping the four axiom fields off the fibre and carrying them in `class FrameOver.IsRegular (F : FrameOver D) : Prop`, then re-exporting `FrameOver.comp`/`serial`/`limit`/`saturation` as theorems taking `[F.IsRegular]`, leaves **every consumer site textually unchanged** — `F.comp` still elaborates, `F.nullity` still elaborates, structure eta still holds by `rfl`, and the total space delegates by `abbrev TaskFrame.IsRegular G := G.toFibre.IsRegular`. Verified in `probes/RegularClass.lean`.
- **The migration is ~45–55 Lean files, not 165.** The "roughly 165 modules" in the task description counts every module that *mentions* `TaskFrame`; almost all of those use only `F.WorldState`, `F.TaskRel` and `F.Duration`, which do not change. The files that actually change are: **13** with `ofReflective` call sites (31 occurrences outside `TaskFrame.lean`), **5** with literal-structure construction outside `TaskFrame.lean`, **~29** touching the four axiom accessors (a grep with false positives from `Function.comp`), plus the validity chain (3 files), `Extension/` (4 files), `FrameProperty.lean`, `ShiftSet.lean`, and the two new topology modules. Counts and file lists are in "Findings → Migration surface".
- **The task description understates what `thm:extension` consumes.** It conjectures "Saturation and, through interpolation, half of Compositionality". The tree says otherwise: `Constraint.lean` uses **both halves** of Compositionality (`F.forward_comp` at :149 and :171 for directedness; `F.interpolates` at :254 for segment-nonemptiness), `F.serial` at :231/:233, `Step.lean` uses `F.saturation` at :135 (its sole application site), and `Admissible.lean:326` uses `TaskFrame.nullity_of_serial_limit F.serial F.limit` — i.e. **Limit too**. The extension theorem consumes all four constraints; the general-frame statement must take all four as hypotheses (or an `[F.IsRegular]` binder).
- **The cheapest meaning-preserving lever for validity is `FrameClass.Sat`.** `FrameClass.Sat .Base F` is `True` today, so after the strip `Valid` would silently widen to all general frames. Redefining `Sat .Base F := F.IsRegular` (and conjoining `F.IsRegular` into the `.Dense`/`.ZTime`/`.RTime` tags) keeps `Valid`, `ValidIn`, `ValidOnFrames`, `Valid.apply`, `Valid.of_forall` and every downstream validity theorem **defined verbatim**. `Sat` is already `@[reducible]` precisely so that `intro h` registers the frame condition in the local instance cache — verified that this works for a `Prop`-valued class, so `G.comp` elaborates after a bare `intro h` with no `sat_intro` change at `.Base`.
- **`ofReflective` migrates by one token per site.** Keep `ofReflective` as the general 3-argument constructor (`W`, `R`, `hR`); add `ofReflectiveRegular` with the *existing* 7-argument signature, defined as `ofReflective W R hR`, plus an **auto-instance** `instance : (ofReflectiveRegular W R hR hcomp hser hlim hsat).IsRegular`. Each of the 31 call sites then changes by renaming one identifier; synthesis supplies the class. Verified.
- **The topology instance is accepted and safe-but-sharp.** `instance (F : FrameOver D) : TopologicalSpace F.WorldState := nbhdTopology F.TaskRel` elaborates, is keyed on `FrameOver.WorldState _`, leaves Mathlib's `ℝ` topology untouched, and yields `T1Space F.WorldState ↔ Limit F.TaskRel` on the **general** frame with `T1Space` and (free) `R0Space` instances on the regular class. Two hazards, both manageable and both named below: a `def` of class type (`nbhdTopology`) emits `warn.classDefReducibility`, which is **fatal under `lake build --wfail`**; and at a frame whose carrier is a type Mathlib already topologizes (`ℝ`, `ℚ`), the two instances coexist on the same underlying type, so which one a goal gets depends on whether the type is spelled `ℝ` or `F.WorldState`.
- **No theorem name has to change for the four axioms.** `FrameOver.comp`/`serial`/`limit`/`saturation` are re-declared as theorems under their existing names, so no deprecation alias is needed for them. Aliases are needed only where a declaration is genuinely renamed (the main candidate is `ofReflective` if the plan chooses the other naming split — see Decisions). `@[deprecated old (since := "...")] alias` is verified working at this toolchain.

## Context & Scope

Researched: (i) what shape the general/regular split must take in Lean for the four constraints to become assumable in any subset while no downstream statement changes meaning; (ii) the honest migration surface, from greps of construction and consumption rather than module counts; (iii) exactly which constraints the extension theorem consumes; (iv) whether the user-ratified `𝒩_F` topology instance can live on the general frame; (v) the infrastructure gates (`check-module-invariants.sh` C-checks, theorem index, allowlists) the refactor must satisfy.

Not researched (deliberately, and flagged as plan work): the Saturation proofs for the two-origin and hedgehog counterexample frames, which report 01 of the dependency task records as still paper arguments; and the manuscript edits, which the user will make separately after this refactor lands.

Constraints honored: no file under `FormalSystem/` or `Tests/` was modified. Every claim below is either the name of a compiled, sorry-free declaration in `specs/656_.../probes/`, a `grep` result quoted with its file and line, or labelled **UNVERIFIED**.

## Findings

### Codebase Patterns

#### 1. What `FrameOver` carries today, and what the general structure keeps

`FormalSystem/Semantics/TaskFrame.lean:768` declares `structure FrameOver (D : TemporalOrder)` with six fields: `WorldState`, `[worldNonempty]`, `PosRel`, `comp`, `serial`, `limit`, `saturation`. The general structure keeps exactly the first three — which is what design requirement (1) asks for — and the four constraint fields move to a class.

Three properties of the current design survive the strip unchanged, and all three were verified by `rfl`-level `example`s in `probes/RegularClass.lean`:

- **Structure eta**: `(⟨G.Duration, G.toFibre⟩ : TaskFrame) = G` and `(FrameOver.toTaskFrame F).toFibre = F` still hold by `rfl`.
- **The fibre/total-space split**: `TaskFrame = Σ (D : TemporalOrder), FrameOver D` is untouched; the ℤ layer's `FrameOver intOrder` is untouched.
- **`TaskRel := TaskFrame.reflect PosRel`**: the reflection convention is already a definition, not a field, so nothing about it moves.

One derived theorem changes its hypothesis profile and must be noted: `FrameOver.reflection` (`:984`) is, per its own docstring, "definitional off zero, and derived at zero from *Seriality* and *Limit*". It therefore becomes `FrameOver.reflection (F) [F.IsRegular]`, and so do `nullity` (`:923`), `eq_of_taskRel_zero` (`:933`, needs Limit alone), `nullity_identity` (`:944`), `forward_comp` (`:958`), `interpolates` (`:970`) and `backward_comp` (`:1004`). Of these, `eq_of_taskRel_zero` is the one that genuinely needs *fewer* constraints than the class provides, so it is the natural first candidate for the generalize-then-derive pattern of requirement (3).

#### 2. The class, verified

The shape that compiles (`probes/RegularClass.lean`, exit 0, `#print axioms` = `[propext]` for the derived `nullity`):

```lean
class FrameOver.IsRegular (F : FrameOver D) : Prop where
  comp       : TaskFrame.Compositional F.TaskRel
  serial     : TaskFrame.Serial F.TaskRel
  limit      : TaskFrame.Limit F.TaskRel
  saturation : TaskFrame.Saturation F.TaskRel

theorem FrameOver.comp (F : FrameOver D) [h : F.IsRegular] :
    TaskFrame.Compositional F.TaskRel := h.comp
-- and serial / limit / saturation likewise
```

The re-export is what makes the refactor cheap: `F.comp` at a consumer site resolves to the theorem rather than the field projection, and the text at the site is byte-identical. `FrameOver.nullity (F) [F.IsRegular] (w) : F.TaskRel w 0 w := TaskFrame.nullity_of_serial_limit F.serial F.limit w` elaborates with the instance implicit, again byte-identical to today's body.

Total-space delegation:

```lean
abbrev TaskFrame.IsRegular (G : TaskFrame) : Prop := G.toFibre.IsRegular
instance (G : TaskFrame) [h : G.toFibre.IsRegular] : G.IsRegular := h
theorem TaskFrame.comp (G : TaskFrame) [G.IsRegular] : TaskFrame.Compositional G.TaskRel :=
  G.toFibre.comp
```

This keeps `TaskFrame.comp`/`serial`/`limit`/`saturation` (`TaskFrame.lean:2176`–`:2193`) at their existing names and statements modulo the added binder.

The Q6 warning about `IsRegular` bare at top level is real and is respected here: the declaration is `FrameOver.IsRegular`, never `IsRegular`, so Mathlib's `IsRegular` (cancellable monoid elements) and `RegularSpace` (T3) are not shadowed. Note that after this task the tree *does* import `Mathlib.Topology.Separation.Basic`, which brings `RegularSpace` into scope in the topology module — the namespacing is what keeps that harmless.

#### 3. `Limit` must be named, and the name is free

`FrameOver.limit`'s type is written out literally at `TaskFrame.lean:836` (`∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskFrame.reflect PosRel w y u) → u = w`), and the module docstring records the non-naming as deliberate. The topology results need `Limit` on the right of an `↔`, so it must be named. `TaskFrame.Limit` is free: the dependency task's probes already declare exactly

```lean
def Limit (R : W → D → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
```

in namespace `FormalSystem.Semantics.TaskFrame` and compile. Because it is definitionally the literal shape, `IsRegular.limit : Limit F.TaskRel` is stated by citation exactly as `serial` and `saturation` already are, and the three docstrings that record the deliberate non-naming (the module header's "Alignment status" bullet, the `limit` field docstring, and `exists_uniform_radius_of_finite`'s "Status" paragraph) are the ones that must be rewritten.

#### 4. What the extension theorem actually consumes — correcting the task description

Grepped, with line numbers:

| Module | Line | Constraint consumed | Via |
|---|---|---|---|
| `Extension/Constraint.lean` | 149, 171 | Compositionality, **composition half** | `F.forward_comp` (directedness of the constraint family) |
| `Extension/Constraint.lean` | 231, 233 | **Seriality** | `F.serial` (`nonempty_fib_of_serial`) |
| `Extension/Constraint.lean` | 254 | Compositionality, **interpolation half** | `F.interpolates` (`nonempty_seg_of_interpolates`) |
| `Extension/Admissible.lean` | 326 | **Seriality + Limit** | `TaskFrame.nullity_of_serial_limit F.serial F.limit` |
| `Extension/Admissible.lean` | 318 | Seriality + Limit (at zero) | `F.reflection` |
| `Extension/Step.lean` | 135 | **Saturation** | `F.saturation` — the sole application site in the development |

So the answer design requirement (2) asks for, stated exactly: **`thm:extension` consumes all four constraints** — the *whole* biconditional Compositionality (both halves, at different sites), Seriality, Limit (through `lem:nullity` in the admissibility characterisation and through `reflection` at zero), and Saturation. The task description's conjecture that it is "Saturation and, through interpolation, half of Compositionality" is too weak and should not be carried into the plan.

The practical consequence is good news for churn: `Extension/` needs an `[F.IsRegular]` binder, not a four-hypothesis rewrite, and `Step.lean`'s docstring claim that `F.saturation` is applied "directly, with zero adaptation" stays true, because the re-exported theorem has the same type as the old field.

**Histories need nothing.** `PartialHistory F` (`PartialHistory.lean:129`) and `WorldHistory F` (`:416`) are already defined over `TaskFrame` using only `respects_task`, i.e. `TaskRel` — no axiom field appears in either. Design requirement (2)'s "histories, partial histories, convex histories are defined over the general frame" therefore costs **zero edits** to those definitions; they become general-frame notions the moment the fields leave the structure. `IsConvex` (`:281`), `IsTotal` (`:218`), `timeShift`, `ofTotal` likewise.

#### 5. The validity chain — the one place meaning could silently change

`Valid φ := ValidIn ProofSystem.FrameClass.Base φ` (`Validity.lean:365`), `GenericValidIn fc φ := GenericValidOnFrames fc.Sat φ` (`ValidityLayer.lean:187`), `GenericValidOnFrames P φ := ∀ F : TaskFrame, P F → ...` (`:182`), and `FrameClass.Sat .Base _ := True` (`FrameClassValidity.lean:132`).

After the field strip, `∀ F : TaskFrame` ranges over general frames, so `Valid` would become validity over *all* frames — strictly stronger than today's notion, and soundness would break. Requirement (3) forbids that.

**Recommended lever**: redefine the `Sat` table, leaving every `Valid*` definition byte-identical:

```lean
@[reducible]
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base,  F => F.IsRegular
  | .Dense, F => F.IsRegular ∧ F.IsDense
  | .ZTime, F => F.IsRegular ∧ F.IsZTime
  | .RTime, F => F.IsRegular ∧ F.IsRTime
```

Verified in `probes/RegularClass.lean` (the `SatLever` section): with `Sat` `@[reducible]` and the tag's value a `Prop`-valued *class*, a bare `intro h` on a `Sat .Base G` hypothesis registers `G.IsRegular` in the local instance cache, so `G.comp` elaborates immediately with no explicit application. That is the same mechanism `FrameClassValidity.lean:125`'s docstring says the `.Dense` tag already depends on, so the existing `sat_intro` macro needs no new branch at `.Base`; the conjunctive tags need their `obtain` patterns extended by one component.

Two frame-level declarations do change statement (meaning preserved, binder added), and both must appear in the migration table:

- `TaskFrame.not_validOn_bot (F : TaskFrame)` (`Validity.lean:269`) → `(F : TaskFrame) [F.IsRegular]`. Its docstring's claim that the axioms are "not arguments: `FrameOver` carries them as structure fields" becomes false and must be rewritten to say they arrive through the class.
- `TaskFrame.hF_nonempty_of_frameAxioms` (`:282`) → same.

`TaskFrame.ValidOn` itself (`:247`) needs no binder: it quantifies over `WorldHistory F`, which is general-frame data. Only the *non-vacuity* theorem needs the class.

#### 6. Migration surface — the honest estimate

Greps over `FormalSystem/` + `Tests/` (623 `.lean` files total):

| Category | Files | Occurrences | Note |
|---|---|---|---|
| Mentions `TaskFrame` at all | 165 | — | the task description's figure; **not** the migration surface |
| Mentions `FrameOver` at all | 85 | — | still mostly `.WorldState`/`.TaskRel`, unchanged |
| Uses `.WorldState` | — | 259 | unchanged |
| Uses `.TaskRel` | — | 346 | unchanged |
| **`ofReflective` call sites** (excl. `TaskFrame.lean`) | **13** | **31** | one-token rename each, with the auto-instance |
| **Literal-structure construction** (`PosRel :=` / `PosRel w x u :=`, excl. `TaskFrame.lean`) | **5** | — | `Independence/{DriftFrame,LimitClosureFrame,ForwardDeterministicFrame}.lean`, `ShiftSet.lean`, `OpenLanguage/OpenReversal.lean`; each splits into `def` + `instance` |
| **Touches an axiom accessor** (`.comp`/`.serial`/`.limit`/`.saturation`) | **30** | 116 | includes `Function.comp` false positives; the heaviest are `TaskFrame.lean` (34), `Extension/Step.lean` (8), `IntTransfer.lean` (6), `Kamp/MonadicFormulaSubstitution.lean` (6), `ShiftSet.lean` (5) |
| **Validity chain** | 3 | — | `Validity.lean`, `ValidityLayer.lean`, `FrameClassValidity.lean` |
| **New modules** | 2 | — | `Semantics/StateTopology.lean`, `Semantics/StateTopology/Counterexamples.lean` |

De-duplicated, the realistic touch set is **~45–55 Lean files**. The plan should carry this table rather than the 165 figure, and should re-derive it with the same greps at plan time (the two greps are `grep -rn 'ofReflective'` and `grep -rnE "\.(comp|serial|limit|saturation)\b"`, both over `FormalSystem Tests --include=*.lean`).

Frames that will be *constructed generally and never made regular* — the point of the whole refactor — are the four-state funnel, the two-origin half-line, and the hedgehog, all of which exist compiled in the dependency task's probes.

#### 7. `ofReflective`: a one-token migration, verified

`FrameOver.ofReflective` (`TaskFrame.lean:1043`) takes `W`, `R`, `hR`, and the four axiom proofs. The verified split:

```lean
def ofReflective (W) [Nonempty W] (R) (hR) : FrameOver D                       -- general, 3 args
def ofReflectiveRegular (W) [Nonempty W] (R) (hR) (hcomp) (hser) (hlim) (hsat) -- existing 7-arg signature
    : FrameOver D := ofReflective W R hR
instance instIsRegularOfReflective (W) [Nonempty W] (R) (hR) (hcomp) (hser) (hlim) (hsat) :
    (ofReflectiveRegular W R hR hcomp hser hlim hsat).IsRegular where
  comp := TaskFrame.compositional_reflect_of_reflective hR hcomp
  serial := TaskFrame.serial_reflect_of_reflective hR hser
  limit := TaskFrame.limit_reflect_of_reflective hR hlim
  saturation := TaskFrame.saturation_reflect_of_reflective hR hsat
```

Compiles, and an `example` confirms synthesis finds the auto-instance so `(ofReflectiveRegular ...).serial` elaborates. Each of the 31 call sites migrates by renaming `ofReflective` → `ofReflectiveRegular`; nothing else at the site changes, including the `ofReflective_taskRel` / `ofReflective_taskRel_eq` bridges, whose extra arguments are implicit.

The four unused explicit arguments of `ofReflectiveRegular` must be underscore-prefixed (`_hcomp`, …) or the C16 Batteries `unusedArguments` linter fires. Confirmed by construction in the probe.

#### 8. The topology, on the general frame

`probes/TopologyInstance.lean` lifts the dependency task's `nbhdTopology`, `Limit`, and `t1Space_nbhdTopology_iff_limit` verbatim (they compile unchanged) and adds the frame layer:

```lean
instance FrameOver.stateTopology (F : FrameOver D) : TopologicalSpace F.WorldState :=
  nbhdTopology F.TaskRel

theorem FrameOver.t1Space_iff_limit (F : FrameOver D) :
    T1Space F.WorldState ↔ Limit F.TaskRel := t1Space_nbhdTopology_iff_limit F.TaskRel

instance (F : FrameOver D) [F.IsRegular] : T1Space F.WorldState :=
  (t1Space_iff_limit F).mpr F.limit

example (F : FrameOver D) [F.IsRegular] : R0Space F.WorldState := inferInstance  -- free from Mathlib

def FrameOver.coneTop (F : FrameOver D) : TopologicalSpace F.WorldState := coneTopology F.TaskRel
```

`#print axioms` on `t1Space_iff_limit` and the derived `T1Space` instance: `[propext, Classical.choice, Quot.sound]` — Mathlib's standard three, nothing added.

`𝒯_F` stays a `def` with no instance, exactly as the ratified decision requires, so there is exactly one `TopologicalSpace` on a state space.

**Hazard A — `warn.classDefReducibility` is fatal under `--wfail`.** `nbhdTopology` is a `def` whose type is a class, and Lean emits:

> Definition `nbhdTopology` of class type is semireducible. Most type class instances should be instance-reducible, so consider marking this definition with `@[instance_reducible]`.

Observed directly. The dependency task's probe header already carries `set_option warn.classDefReducibility false`, which is why the probes are clean. The plan must choose deliberately between `@[instance_reducible] def nbhdTopology` and a scoped `set_option`, and record the choice; a `set_option` at module scope is the lower-risk option, because making the topology instance-reducible changes how eagerly unification unfolds it and could interact with Hazard B.

**Hazard B — instance keying at a carrier Mathlib already topologizes.** The instance is keyed on `FrameOver.WorldState _`, so Mathlib's `TopologicalSpace ℝ` is untouched and both coexist. Verified: at a frame `metricFrame : FrameOver realOrd` with `WorldState := ℝ`, `(inferInstance : TopologicalSpace metricFrame.WorldState) = FrameOver.stateTopology metricFrame` holds by `rfl`, while `TopologicalSpace ℝ` still resolves to Mathlib's. That is *not* a contradiction — the dependency task proved the two topologies are propositionally equal on the metric frame — but it is a genuine ambiguity: which instance a goal gets depends on whether the type is spelled `ℝ` or `metricFrame.WorldState`, and a lemma proved about one will not apply to the other without a bridging `rfl`/`congr`. `Correspondence/RigidityReal.lean` is where this will first bite. Mitigation the plan should carry: a named bridge lemma per real-carrier frame (`nbhdTopology_eq_real` already exists compiled in the dependency task's `RealFrames.lean` probe), and no attempt to make `WorldState` reducible.

**Hazard C — noncomputable.** A `FrameOver` whose carrier is `ℝ` needs `noncomputable def` (it depends on `Real.linearOrder`), and so does the `TemporalOrder.of Real` abbreviation. Observed. This is pre-existing behaviour, not new, but the counterexample module over `ℝ` (two origins, hedgehog) must be written with it.

**Module placement — applying the ratified import-weight decision.** `Mathlib.Topology` already reaches the whole library: `Semantics.lean:35` imports `Semantics.Correspondence`, whose aggregator (`Correspondence.lean:15`) imports `RigidityReal`, which imports Mathlib topology. So placing `StateTopology.lean` under the `Semantics` aggregator adds no *new* Mathlib weight — but it would put the new global `TopologicalSpace F.WorldState` **instance** in scope for every module in the development, which is the thing worth avoiding. Recommendation, following the precedent the decision names (`TimeIndexedSharpness` is out of `Semantics.lean:34`'s neighbourhood and imported only by the generated root at `FormalSystem.lean:501`): keep `Semantics/StateTopology.lean` and `Semantics/StateTopology/Counterexamples.lean` **out of `Semantics.lean`**, reached only by the generated root. C24 (every module transitively imports `FormalSystem.Init`) is satisfied through `TaskFrame`, so nothing is lost. State this choice explicitly in the plan, as the decision requires.

#### 9. Frame properties to re-site (requirement 5)

All of these are already stated over `TaskRel` alone and move to the general frame with no proof change:

| Declaration | Site | Note |
|---|---|---|
| `TaskFrame.Deterministic` | `FrameProperty.lean:349` | general |
| `TaskFrame.ForwardDeterministic` | `:385` | general |
| `TaskFrame.saturation_of_deterministic` | `:365` | **produces** a constraint — an `IsRegular` ingredient, not a consumer |
| `TaskFrame.Static` | `Correspondence/Rigidity.lean:110` | already on bare relations — the model the task cites |
| `TaskFrame.UniformDwell` | `Rigidity.lean:120` | already on bare relations |
| `FrameOver.static_iff_uniformDwell`, `static_of_finite` | `Rigidity.lean:243`, `:280` | already `(F : FrameOver D)` with no axiom use; unchanged, and they are `docs/theorem-index.md` rows 166–167 |
| `FrameOver.static_of_countable` | `Correspondence/RigidityReal.lean` | theorem-index row 168 |
| `TaskFrame.IsDense`/`IsDiscrete`/`IsZTime`/`IsComplete`/`IsRTime`/`IsQTime` | `FrameProperty.lean:125`–`:271` | properties of `Duration`, untouched by the strip |
| `ShiftSet.sep`, `rev_sep` | `ShiftSet.lean:326` | `rev_sep` is "dischargeable from `F.limit` alone" per its own docstring (`:113`) — so it becomes `[F.IsRegular]` or, better, an explicit `Limit` hypothesis, and the `sep`-without-Limit counterexample then becomes statable |

`Rigidity.lean` is the model requirement (3) points at, and it already follows the pattern: the bare-relation lemmas `eq_of_rel_of_step` (`:136`) and `eq_of_rel_of_uniform_radius` (`:166`) take explicit hypotheses, and the `FrameOver` versions are derived from them. That is the template for every "needs fewer constraints" generalization.

### External Resources

- **Mathlib at the `v4.33.0-rc1` pin**: `TopologicalSpace.generateFrom`, `TopologicalSpace.mkOfNhds`, `T1Space`, `R0Space` (with the `T1Space → R0Space` instance, which makes `app:topology-r0` free), `isOpen_compl_singleton`, `t1Space_antitone`, `OrderTopology`, `Ioo_mem_nhds`. All exercised in the dependency task's probes and re-exercised here.
- **Naming conventions**: Mathlib's `IsFoo` convention for a `Prop`-valued predicate on a *term* (`Ideal.IsPrime`, `IsUnit`) is what `FrameOver.IsRegular` follows; the Q6 analysis of the `RegularSpace`/Lemmon-regular-logic/"irregular worlds" collisions stands and needs no re-derivation.
- **Toolchain facts observed while probing** (worth carrying into the plan so phases do not rediscover them): `le_or_lt` is not available at this pin under `TaskFrame.lean`'s import set — use `lt_or_ge`; `push_neg` is deprecated in favour of `push Not`; `linarith` does not close goals over an abstract `TemporalOrder` carrier (an ordered additive group, not an ordered field) — use `sub_lt_self`, `lt_add_of_pos_right`, `sub_lt_iff_lt_add'`; `TaskFrame.Serial` takes the `0 ≤ x` proviso as an explicit third argument, which is easy to miss.

### Recommendations

1. **Adopt the class architecture verbatim from `probes/RegularClass.lean`** — general `FrameOver` with three fields, `class FrameOver.IsRegular` with four, and same-named theorem re-exports. This is the only shape found that satisfies requirements (1) and (3) simultaneously.
2. **Adopt the `FrameClass.Sat` lever** for the validity chain. It is the difference between a three-file change and a change that reaches every soundness and completeness theorem.
3. **Adopt the `ofReflective`/`ofReflectiveRegular` + auto-instance split.** 31 call sites at one token each.
4. **Sequence the phases so the tree is green at every boundary**, in this order (each is one agent run and ~100–500 lines of output, per the H8 sizing the task's process requirements imply):
   - **P1** Name `TaskFrame.Limit`; update the three docstrings that record the deliberate non-naming. Nothing else moves. Full `--wfail` build.
   - **P2** Add `class FrameOver.IsRegular` **alongside** the existing fields, with the four instance fields cited from `F.comp` etc. At this point every frame in the tree gets an instance for free from a single `instance (F : FrameOver D) : F.IsRegular := ⟨F.comp, F.serial, F.limit, F.saturation⟩`, and the tree is green with zero consumer edits. This is the "introduce alongside" step the process requirements demand.
   - **P3** Add `Semantics/StateTopology.lean` (outside the `Semantics` aggregator), lifting the dependency task's `NbhdTopology.lean` wholesale, plus the frame-level instance, `t1Space_iff_limit`, and the derived `T1Space`/`R0Space` instances. Green at this point *with the old fields still present* — so the topology lands before any churn.
   - **P4** Migrate consumers to the class: add `[F.IsRegular]` binders where an axiom accessor is used under a universally quantified frame; flip `FrameClass.Sat`; extend `sat_intro`'s conjunctive branches. Still green, because the blanket instance from P2 is still there.
   - **P5** Migrate constructors: `ofReflectiveRegular` + auto-instance, and split the 5 literal-structure sites into `def` + `instance`.
   - **P6** **Retire the fields**: delete `comp`/`serial`/`limit`/`saturation` from `FrameOver`, delete the blanket instance from P2, promote the re-exports to their final form. This is the only phase where a missed consumer surfaces, and by construction it surfaces as a build error, not a meaning change.
   - **P7** Land `StateTopology/Counterexamples.lean` — the four-state funnel (the acceptance test), the `sep`-without-Limit fact, the two-origin frame, the hedgehog, the ℤ partition facts — as general frames with their constraint facts proved separately.
   - **P8** Documentation, inventory and gates: `lake exe mk_all --lib FormalSystem`, `check-module-invariants.sh --emit-inventory`, `docs/theorem-index.md` rows and C14 pins, `scripts/module-invariants-allowlist.txt`, `docs/reference/API_REFERENCE.md:141-151` (which prints the six-field structure verbatim and will be wrong), `docs/user-guide/architecture.md:464-489` (same), `docs/reference/paper-definitions-of-record.md:896-898`, `docs/development/PROPERTY_TESTING_GUIDE.md:296`, and the `Semantics`/`Metalogic` READMEs.
5. **There is a sorry-free path.** Every mathematical ingredient the refactor needs is either already compiled in the tree or already compiled in the dependency task's probes. The one exception is flagged under Risks.
6. **Do not add deprecation aliases for the four axiom accessors** — they keep their names, so an alias would be a self-alias. Reserve aliases for genuine renames; `@[deprecated target (since := "…")] alias old := target` is verified working.

## Decisions

- **`FrameOver.IsRegular` as a `class`, not a `structure` or a bundled `Prop`.** Requirement (1) leaves the choice to the plan. The class wins decisively because instance synthesis is what keeps consumer text unchanged: with a plain structure or a bundled conjunction, every one of the 116 accessor occurrences would need an explicit argument threaded to it. Verified end-to-end in the probe. The `RegularFrameOver D extends FrameOver D` bundled form that Q6 offers as a *secondary* alias is **not recommended** for this task — it would give a second frame type for downstream code to disagree about, and nothing in the requirements needs it.
- **Keep `ofReflective` as the general constructor** and introduce `ofReflectiveRegular` for the 7-argument form, rather than the zero-churn inverse (keeping `ofReflective` regular and naming the general one something else). Reason: naming coherence with requirement (1)'s "the general structure keeps the bare frame name". The cost is 31 one-token edits, which is small and fully mechanical. Recorded here because the inverse is defensible and the plan may prefer it; if it does, it must say so and add a deprecation alias.
- **`FrameClass.Sat .Base F := F.IsRegular`** rather than adding `[F.IsRegular]` binders to `Valid`/`ValidIn`/`GenericValid*`. Verified that the reducible-chain instance registration the `.Dense` tag already relies on works for a `Prop` class, so this is the minimal-diff route.
- **`StateTopology.lean` outside the `Semantics` aggregator**, root-only. This applies the ratified preference for the import-weight lever over per-declaration instance pinning, and confines the new global `TopologicalSpace` instance to a leaf.
- **The extension theorem takes `[F.IsRegular]`, not four separate hypotheses.** It genuinely consumes all four (Finding 4), so splitting them buys nothing and costs a signature the downstream metalogic would have to thread.

## Risks & Mitigations

- **Saturation for the two-origin and hedgehog frames is not yet a Lean proof.** The dependency task's report records both as paper arguments (the "shadow map" argument of its §3.3), and its probes prove Seriality, Compositionality and Limit for them but not Saturation. If P7 needs those two frames to be *regular*, the refactor could stall at exactly the place requirement (6) cares about. **Mitigation**: nothing in requirement (6) needs them regular — they are wanted precisely as frames satisfying *some* constraints. Land them as general frames with the three proved constraints as separate facts and Saturation explicitly **not claimed**, and say so in their docstrings. The four-state funnel, which is the named acceptance test, needs no Saturation at all: it is finite, so `TaskFrame.saturation_of_finite` (`TaskFrame.lean:1389`) discharges it outright, and its *interest* is that Limit fails.
- **P6 is the risky phase.** Deleting the fields is the moment every missed consumer surfaces. **Mitigation**: the blanket instance introduced in P2 means P4 and P5 can be verified incrementally against a green tree, and P6 becomes a deletion whose failures are localized compile errors. Do not merge P6 with any other phase, and run the full `lake build --wfail` plus `Tests/BimodalTest` before and after it.
- **The `ℝ`-carrier topology ambiguity (Hazard B)** could produce confusing failures in `Correspondence/RigidityReal.lean` and in the counterexample module. **Mitigation**: land the bridge lemmas from the dependency task's `RealFrames.lean` probe at the same time as the instance, and never spell a frame carrier as the bare Mathlib type in a topological statement.
- **`warn.classDefReducibility` under `--wfail`** will fail the build at P3 if unhandled. **Mitigation**: decide the `@[instance_reducible]`-vs-`set_option` question in the plan, not at build time; the dependency task's probes show the `set_option` route is green.
- **C17 (dead-declaration scan) will flag the new topology vocabulary.** `coneTopology` is deliberately kept as a `def` with no instance and few consumers; several counterexample lemmas exist to be cited from docstrings rather than used. **Mitigation**: C17 excludes `instance`-attributed and simp-set declarations and `FormalSystem/Examples/`; for the rest, cite each new declaration from the module docstring or the theorem index, which is the pattern the tree already uses. Budget a sweep for this in P8.
- **C19 (90% docstring-coverage floor) and C16 (Batteries `docBlame`/`unusedArguments`)** apply to every new declaration — roughly 40 in `StateTopology.lean` alone. **Mitigation**: the dependency task's probe files already carry docstrings on essentially every declaration; lift them with the code.
- **Concurrency.** The task's `file_scope` is the whole library for a reason. Tasks 651/652/654/655 are all `completed`, so nothing is in flight today, but the plan should re-check `specs/state.json` for any `implementing` task touching `FormalSystem/` before P1.
- **Build cost.** A full `lake build --wfail` over `FormalSystem` plus `Tests/BimodalTest` at eight phase boundaries is the dominant wall-clock cost. **Mitigation**: run every build detached through the guard described in `context/project/lean4/operations/long-builds.md` with a bounded waiter, never a foreground blocking call.

## Tactic Survey Results

Surveyed against the goals that arose while building the two probes. All rows are observed outcomes from `lake env lean` runs, not predictions.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `T1Space (nbhdTopology R) ↔ Limit R` | `constructor` + `letI := nbhdTopology R` + explicit term steps | success | `isOpen_compl_singleton`, `Set.mem_singleton_iff`; the `letI` is load-bearing — without it `isOpen_compl_singleton` cannot find the topology and synthesis fails outright |
| same, without `letI` | `@T1Space.mk` / `@isClosed_singleton` with explicit instance arguments | fail | synthesis error `failed to synthesize TopologicalSpace W` at the first Mathlib lemma |
| `z - x < z` over an abstract `TemporalOrder` carrier | `linarith` | fail | no ordered-field structure; the carrier is an ordered additive group |
| same | `sub_lt_self z hx` | success | — |
| `|y - z| < x` from `y ∈ Ioo (z - x) (z + x)` | `rcases abs_cases … <;> linarith` | fail | same reason |
| `R w y u` at `y := x/2` over `ℚ` | `positivity` then `linarith` | success | works because the carrier is concretely `ℚ` |
| `Saturation` at a finite carrier | `TaskFrame.saturation_of_finite` | success | needs a `Finite` instance in scope; `Finite Bool` requires `Mathlib.Data.Finite.Prod` at this import set |
| `¬ Limit funnelRel` | `intro` + `Four.noConfusion` | success | — |
| `R0Space F.WorldState` given `T1Space` | `inferInstance` | success | free from Mathlib's `T1Space → R0Space` |
| instance found for `(ofReflectiveRegular …).IsRegular` | `exact (…).serial` (synthesis only) | success | auto-instance keyed on `ofReflectiveRegular` |
| `G.comp` after bare `intro h` on `Sat .Base G` | none (elaboration) | success | requires `Sat` `@[reducible]` and the tag's value to be a class |

## Context Extension Recommendations

- **Topic**: the instance-keying hazard for a structure-projection carrier (`F.WorldState`) that is definitionally a type Mathlib already equips with the same class.
  **Gap**: `context/project/lean4/` has no note on this pattern, and it is about to become load-bearing in this repository for the first time.
  **Recommendation**: add `context/project/lean4/patterns/projection-keyed-instances.md` recording (i) that an instance on `Struct.field F` is keyed on the projection, so it neither shadows nor is shadowed by an instance on the underlying type; (ii) that this is an ambiguity rather than a diamond; (iii) the bridge-lemma mitigation.
- **Topic**: `warn.classDefReducibility` as a `--wfail` blocker.
  **Gap**: the existing long-builds and lean4 rules do not mention it, and it will be met the first time any module here defines a `TopologicalSpace`-valued `def`.
  **Recommendation**: one paragraph in `context/project/lean4/` recording the warning, the two remedies, and why the `set_option` remedy is the conservative one.

## Appendix

### Search queries and greps used

- `grep -rlE '\.(comp|serial|limit|saturation)\b' FormalSystem Tests --include=*.lean` → 30 files
- `grep -rn 'ofReflective' FormalSystem Tests --include=*.lean` → 37 occurrences, 13 files outside `TaskFrame.lean`
- `grep -rln 'PosRel :=\|PosRel w' FormalSystem Tests --include=*.lean` → 6 files
- `grep -rn 'def [A-Za-z_'"'"'.]* .*: FrameOver' FormalSystem Tests --include=*.lean` → 36 occurrences, 20 files
- `grep -rn 'FrameOver\|PosRel\|worldNonempty' scripts/ docs/` → the doc/infrastructure surface listed in P8
- `grep -n '^# *C[0-9]' scripts/check-module-invariants.sh` → the C1–C27 gate inventory

### Probe verification log

Both probes were compiled with `timeout 900 lake env lean <file>` against the tree's existing `.lake` build, at exit code 0 with empty stderr apart from the requested `#print axioms` lines.

| Probe | Lines | Exit | `#print axioms` |
|---|---|---|---|
| `probes/RegularClass.lean` | 259 | 0 | `PreFrame.nullity` → `[propext]`; `funnel_not_limit` → `[propext, Classical.choice, Quot.sound]` |
| `probes/TopologyInstance.lean` | 222 | 0 | `PreFrame.t1Space_iff_limit` → `[propext, Classical.choice, Quot.sound]`; `PreFrame.instT1` → same |

Nothing under `FormalSystem/` or `Tests/` was modified during this research round.

### Correction carried forward

The task description's statement that the extension theorem "uses Saturation and, through interpolation, half of Compositionality" is inaccurate; it consumes all four constraints, with the sites tabulated in Finding 4. The plan should state the corrected version.
