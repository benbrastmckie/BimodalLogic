# Research Report: Task #601

**Task**: 601 - Align task-frame definition with the paper's reflection convention
**Started**: 2026-09-16T21:04:41Z
**Completed**: 2026-09-16T21:40:00Z
**Effort**: 8-12 hours implementation (5 phases)
**Dependencies**: 599 (completed); 598 (completed). Coordination risk with 602 (researching; touches `PartialHistory`/truth)
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/TaskFrame.lean`, `TemporalOrder.lean`, 18 frame construction sites, docs/typst/README), paper `possible_worlds.tex` (def:task-relation L2803, def:frame L2812-2826, L964, L2887, L2948, L2998, L3518), lean-lsp MCP (`lean_run_code` prototypes, `lean_local_search`, `lean_leanfinder`), `scripts/check-paper-definitions.sh`
**Artifacts**: - specs/601_align_task_frame_reflection_convention/reports/01_reflection-convention-encoding.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- The clean, sorry-free encoding is: **primitive field on the positive cone** `PosRel : WorldState → {x : ↑D // 0 ≤ x} → WorldState → Prop`, a bare-relation definition `TaskFrame.reflect` that extends it to all of `D` by case split, and `FrameOver.TaskRel := reflect F.PosRel` as a *definition*. The four axiom fields keep citing the existing predicates over the extended relation (`Compositional (reflect PosRel)` etc.), so `F.serial : Serial F.TaskRel` still elaborates definitionally (prototyped).
- The reflection law `F.TaskRel w d u ↔ F.TaskRel u (-d) w` becomes a **theorem** `FrameOver.reflection`: definitional for `d ≠ 0`, and at `d = 0` it follows from the already-derived `nullity`/`eq_of_taskRel_zero` (Seriality + Limit). All proofs prototyped and compile with no sorry.
- The frame class is **unchanged**: old frames map to new by restricting `TaskRel` to `D⁺` (`reflect_eq_of_reflective`), new to old via the `reflection` theorem. Every semantic result keeps its content.
- Migration cost is contained: 18 live construction sites (not Boneyard), 28 `.converse` projection uses (a rename to `.reflection`), about 20 `respects_task` history sites plus a few `Iff.rfl` bridge lemmas that relied on `TaskRel` being definitionally the site's concrete relation. A smart constructor `FrameOver.ofReflective` plus a `@[simp]` bridge lemma turns each site into a mechanical edit.
- Subtlety found in the paper: `w ⇒_{-x} u := u ⇒_x w` "for x ≥ 0" overlaps itself at `x = 0` (`-0 = 0`). Read literally it forces `⇒_0` to be symmetric, so it is a constraint rather than notation. The Lean encoding should use the strict split (primitive at `d ≥ 0`, reversed only at `d < 0`), which makes the convention pure notation. Symmetry at 0 is then a theorem. A paper wording tweak ("for x > 0", or a note) is advisable but does not block anything.

## Context & Scope
Researched: (1) the paper's current def:task-relation / def:frame wording; (2) the current `FrameOver` structure and its `converse` field; (3) candidate encodings, prototyped in `lean_run_code`; (4) the consumer and construction-site surface; (5) the rename surface ("converse convention" -> "reflection convention"), separating it from genuine uses of "converse". Constraint: zero sorry, no new axioms, and `FrameOver` fields must be exactly `WorldState`, `[Nonempty]`, the primitive relation, and the four axioms.

## Findings

### Paper (current wording, verified)
- def:task-relation (L2803): a relation `w ⇒_x u` for `x ∈ D⁺`, "extended to negative durations by the *reflection convention* `w ⇒_{-x} u := u ⇒_x w` for `x ≥ 0`". Fiber/Cone/Segment are defined over the extended relation on all of `D`.
- def:frame (L2812-2826): four axioms for `x, y ≥ 0`: Compositionality (a biconditional), Seriality (successor and predecessor), Limit (`⋂_{x>0}(w)_x = {w}`: cones range over negative `y` too, so the extended relation is used), and Saturation (fibers at all `x ∈ D`, segments use `Fib(v,-y)`, so again extended). No reflection axiom.
- Uses of the convention in proofs: L2887 (T1, at `y` with `|y| < x`, possibly `y = 0`), L2948, L2998, L3518 (Deterministic "in both temporal directions"). At L2887 the paper uses the convention at `y = 0`, which in the strict reading is justified by `lem:nullity` plus Limit-injectivity. The Lean theorem covers this case uniformly.

### Codebase Patterns
- `FormalSystem/Semantics/TaskFrame.lean` L612-701: `structure FrameOver (D : TemporalOrder)` with fields `WorldState`, `[worldNonempty]`, `TaskRel` (two-sided), `comp : Compositional TaskRel`, `converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w`, `serial`, `limit`, `saturation`.
- Derived theorems that already avoid `converse`: `nullity` (via `nullity_of_serial_limit`), `eq_of_taskRel_zero` (Limit alone), `nullity_identity`, `forward_comp`, `interpolates`. Only `backward_comp` (fibre and total space) uses `converse`. There is no circularity in deriving `reflection` from `nullity`.
- `TaskFrame` total space re-exports `converse` at L1880-1882. There are `@[reducible]` delegates for `TaskRel`.
- `TemporalOrder.lean` L42-47 documents D⁺ as "not carried as separate data ... expressed by `0 ≤ x` hypotheses". This docstring must be rewritten once D⁺ types the primitive relation.
- Bare-relation helper classes (`*_of_permissive`, `*_of_eq`, `*_of_total`, `limit_of_shift`, `saturation_of_fib_*`) all take a two-sided `R`, and `converse_of_permissive` exists. These stay usable unchanged via `ofReflective` (below).

**Live construction sites setting `converse` (18; Boneyard is not built by `lakefile.lean` and is excluded):**
`Semantics/TaskFrame.lean` (trivialFrame 1552, staticFrame 1614, natFrame 1687); `Semantics/Frames/Standard.lean` (translationFrame 89, permissiveFrame 127); `Semantics/ShiftSet.lean` 178; `Semantics/IntTransfer.lean` 150 (`FrameOver.map`); `Semantics/IntNormalForm.lean` 459 (`ofStepRel`); `Examples/TemporalStructures.lean` 84/151/243 (plus generic frames); `Metalogic/Algebraic/FlowFrame.lean` 160; `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` 213; `Metalogic/Decidability/FMP/Filtration.lean` 337; `Metalogic/Independence/{ClockFrame 183, DriftFrame 223, ForwardDeterministicFrame 218}`; `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` 470.

**`.converse` projection uses (28):** TaskFrame.lean 8, Extension/Constraint.lean 5, PartialHistory.lean 3, PlusLanguage/PlusPasting.lean 2, IntNormalForm.lean 2, Extension/Admissible.lean 2, Independence/DriftFrame.lean 2, and 1 each in IntTransfer, FrameProperty, DeterministicBridge, Independence/StarDiscrimination, Independence/LoopingDuration.

**Definitional-dependence sites (these break when `TaskRel` stops being the site's literal relation):** `@[simp] ..._taskRel ... := Iff.rfl` lemmas (Standard.lean translationFrame/permissiveFrame, RealTranslationFrame `f1_taskRel_iff`, TaskFrameTest `customFrame_rel_iff` and `example ... := Or.inl ...`, the `*_rel_iff` lemmas in TaskFrame.lean/TemporalStructures.lean), `example : (genericTimeFrame intOrder).TaskRel = intTimeFrame.TaskRel := rfl` (TemporalStructures L430, which stays `rfl` if both come from the same constructor over the same R), and about 20 `respects_task :=` history constructions (PartialHistory 3, IntTransfer 2, DurationFrames 2, ReynoldsBridge 2, TemporalStructures 2, and 1 each in PartialHistoryOrder, Extension, Admissible, DeterministicBridge, CoNotPriorU, ClockFrame, DiscreteNonCompactness, RegionFrame, FlowFrame). Most are over an abstract `F` and are unaffected. Only those at concrete frames need a bridge rewrite.

### External Resources
- Mathlib: `Nonneg.coe_add` (`↑(a + b) = ↑a + ↑b` on `{x // 0 ≤ x}`, `Mathlib.Algebra.Order.Nonneg.Basic`) supplies the subtype arithmetic API. `AddGroupCone` (`Mathlib.Algebra.Order.Group.Cone`) is a *constructor of orders from a cone* and does not fit here (the order is given). `SetRel.inv`/`flip` is the idiom for the plain converse relation. No Mathlib notion of a "D⁺-graded relation extended by reflection" exists (leanfinder search), so a local `TaskFrame.reflect` is justified.

### Candidate encodings (compared)

| Option | Primitive | Extended `TaskRel` | Reflection law | Faithfulness | Burden |
|---|---|---|---|---|---|
| A (recommended) | `PosRel : W → {x : ↑D // 0 ≤ x} → W → Prop` | `def` = `reflect PosRel`, strict `dite` split | theorem (d≠0 definitional, d=0 from nullity) | exact: primitive typed on D⁺, no junk, frame equality = relation equality | dite/subtype coercions confined to `TaskFrame.lean` API and `ofReflective` |
| B | `PosRel : W → ↑D → W → Prop` (values at `d<0` ignored) | `if 0 ≤ d then P w d u else P u (-d) w` | same | junk values: distinct structures with the same `TaskRel`; the "primitive on D⁺" claim is only by convention | slightly lighter (no subtype), `split_ifs` friendly (prototyped) |
| C | same as A/B, but symmetric closure at 0: `(0 ≤ d ∧ P w d u) ∨ (d ≤ 0 ∧ P u (-d) w)` | disjunctive | theorem for *every* P, no axioms needed | deviates at 0: `TaskRel w 0 u` is P or its flip, not the primitive | Comp/Serial at x=0 no longer literally the primitive |
| D | `TaskRelation` structure bundling primitive plus extension, as field `rel` | `F.rel.ext` | theorem | mirrors def:task-relation as a separate object | extra projection layer at every use. A bare function type already *is* the paper's object, so this adds nothing |
| E (status quo) | two-sided field plus `converse` field | field | field | not the paper's four-field shape | none |

### Recommendations
1. **Adopt Option A.** In `TaskFrame.lean`, above the structure:
   - `def TaskFrame.reflect {W} (P : W → {x : D // 0 ≤ x} → W → Prop) (w : W) (d : D) (u : W) : Prop := if h : 0 ≤ d then P w ⟨d, h⟩ u else P u ⟨-d, _⟩ w`
   - API: `reflect_of_nonneg` (`0 ≤ d → (reflect P w d u ↔ P w ⟨d,h⟩ u)`), `reflect_of_neg`, `reflect_coe` (`reflect P w ↑x u ↔ P w x u`), `reflect_reflection_of_ne` (reflection off zero, for every P), `reflect_eq_of_reflective` (`(∀ w d u, R w d u ↔ R u (-d) w) → reflect (fun w x u => R w ↑x u) = R`).
   - Structure fields: `WorldState`, `[worldNonempty]`, `PosRel`, `comp : Compositional (reflect PosRel)`, `serial : Serial (reflect PosRel)`, `limit : ... reflect PosRel w y u ...`, `saturation : Saturation (reflect PosRel)`. Keep the axioms stated over the extended relation. This preserves the documented invariant that fields are *definitionally* `Serial F.TaskRel` / `Saturation F.TaskRel` (the Step Lemma's consumption), and Limit and Saturation must use the extended relation anyway. Optionally add `compositional_reflect_iff` showing that `Compositional (reflect P)` is the cone-literal statement over `P` with subtype addition, to certify faithfulness to def:frame's "x, y ≥ 0".
   - `def FrameOver.TaskRel (F) := reflect F.PosRel` as a plain (non-`@[reducible]`) `def`, so simp does not unfold it into `dite` at abstract frames. Prototyped: `example (F) : Serial F.TaskRel := F.serial` elaborates.
   - Theorem `FrameOver.reflection : F.TaskRel w d u ↔ F.TaskRel u (-d) w` (proof prototyped: trichotomy on `d`, `dif_pos`/`dif_neg` off zero, `eq_of_taskRel_zero ▸ nullity` at zero). Re-export as `TaskFrame.reflection`. `backward_comp` switches to it.
   - Smart constructor `FrameOver.ofReflective (W) [Nonempty W] (R) (hR : reflective R) (hcomp : Compositional R) (hser : Serial R) (hlim : …R…) (hsat : Saturation R)` with `@[simp] ofReflective_taskRel : (ofReflective …).TaskRel w d u ↔ R w d u` (prototyped via `rw [reflect_eq_of_reflective hR]`). Existing construction sites become `ofReflective` calls. Their former `converse` proof becomes the `hR` argument, which is honest: a site presenting a two-sided relation must show it is the reflection of its D⁺ restriction. Sites whose relation is naturally one-sided (translation, shift) may instead set `PosRel` directly. Prototyped for `translation`, including Limit.
   - Name the D⁺ type in `TemporalOrder.lean` (e.g. `abbrev TemporalOrder.PositiveCone (D : TemporalOrder) := {x : ↑D // 0 ≤ x}`), since def:temporal-order is where the paper defines D⁺, and rewrite that module's "positive cone is not carried" docstring. **Avoid the name `Cone`**, which would clash with `TaskFrame.cone` (the paper's cone clause `(w)_x`).
2. **Field name for the primitive:** `PosRel` (UpperCamelCase per Mathlib naming for Prop-valued functions). Docstring: "def:task-relation's primitive relation on D⁺". Keep `TaskRel` as the extended relation's name so that the roughly 100 `F.TaskRel` consumers are untouched.
3. **Rename:** `converse` -> `reflection` (theorem). The repo has one `@[deprecated]` attribute in total and no downstream library consumers, so a **direct rename without a deprecated alias** is recommended. `docs/development/VERSIONING.md` describes a deprecation policy; if the implementer judges it applicable, a single `@[deprecated (since := "2026-09-16")] alias converse := reflection` on both `FrameOver` and `TaskFrame` is cheap. `converse_of_permissive` -> `reflection_of_permissive`. Site-local lemmas `fzero_converse`, `fn_converse`, `canonical_task_rel_converse` (Boneyard, unbuilt) -> `*_reflection`.
4. **Prose rename scope** (the phrase "converse convention"): 37 occurrences in 11 live Lean files (TaskFrame 12, PartialHistory 4, Extension/Admissible 4, IntNormalForm 3, Extension/Constraint 3, FlowFrame 3, PlusPasting 2, Semantics.lean 2, ForwardDeterministicFrame 2, LoopingDuration 1, ClockFrame 1); non-Lean: `README.md`, `FormalSystem/Semantics/README.md` (L67, L69 field list), `docs/reference/API_REFERENCE.md` (L144, L161, L216), `docs/reference/paper-definitions-of-record.md` (L685, L689 verbatim quote, L1463 def:deterministic quote), `typst/chapters/02-semantics.typ` (L46, L56, L149 prose that describes the field packaging, which must be rewritten, not just renamed), `typst/chapters/06-notes.typ` L28, `typst/FormalFoundations.typ` L194/L282/L370, `typst/notation/bimodal-notation.typ` L119 (`#let leanConverse = raw("converse")` -> `leanReflection`, and update its users), `latex/subfiles/02-Semantics.tex` (L31/L37/L43/L57/L111; not named in the task, include for consistency or mark as an explicit exclusion). `NOTATION.md` has no occurrence.
5. **Do NOT rename** genuine converses: logical converses of implications/theorems (Compactness, StrongCompleteness, DeductionTheorem `deductionConverse`, Kamp/EFGames/DenseModelSurgery prose, and many others), relational converse and `O-Conv` terminology, `orderDual_converse` (Decidability Bridge, a time-order dual, unrelated), typst 02-semantics L57 "Any converse operation ... superscript inverse" (a genuine relational converse; keep), `SpCountermodel` "converse-closed", `latex` L111 "take converses" (genuine relational converses of tasks, so arguably keep "converse" and add "by the reflection convention"). Beware of collision with typst "no separate *Reflection* axiom" (L56, 06-notes L28): rephrase to "the reflection law is not an axiom: it is the reflection convention" to avoid implying a Reflection axiom.
6. **paper-definitions-of-record.md:** re-pin `def:task-relation` and `def:deterministic` verbatim from the current paper. `check-paper-definitions.sh` currently reports 16 drifted anchors plus 1 dangling (`thm:M5-valid`). Only those two are in scope. Record the other 14 as pre-existing, out-of-scope drift.

## Decisions
- Strict split at zero (primitive for `d ≥ 0`, reversed only for `d < 0`), matching "extended to negative durations". Reflection at 0 is derived from Limit and Seriality, not stipulated.
- Axiom fields are stated over the extended relation (`reflect PosRel`), not over the subtype primitive, to keep the definitional-citation invariant and Limit/Saturation faithful.
- Subtype primitive (Option A) over junk-valued (Option B), for exact faithfulness and extensionality. Option B is an acceptable fallback if subtype coercions prove noisy at construction sites. The two are interchangeable behind `ofReflective`, and B was also prototyped.
- `FrameOver.TaskRel` is a non-reducible `def`. Consumers use `reflection`, `taskRel_of_nonneg`, `taskRel_of_neg`, and per-frame `@[simp]` bridges.
- No sorry and no axioms. Every new obligation is proved (prototypes compiled clean except for one scratch sorry in an abandoned first draft that was then proved).

## Risks & Mitigations
- **Definitional breakage at concrete frames** (`Iff.rfl` bridges, `Or.inl` examples, concrete `respects_task` proofs): mitigate with `ofReflective_taskRel` (`simp`/`rw`). Rebuild dependents in the order TaskFrame -> Standard/Examples -> Metalogic sites, and run `lake build` detached and guarded after each group.
- **`FiniteFrameOver extends FrameOver`**: field rename propagates. Any `{ toFrameOver := … }` builds need `ofReflective` inside.
- **Tests/BimodalTest/Property/Generators.lean** (L32, L146) lists field names in prose and may build frames: update.
- **Concurrency with task 602** (WorldHistory, touches `PartialHistory`/truth): the overlap is `PartialHistory.lean` (3 `.converse`, 4 prose mentions). Sequence 601 before 602's implementation, or rebase. The 601 edits there are one-token renames, so conflicts are trivial.
- **`simp` normal-form drift** if `reflect` gets `@[simp]` unfolding: do not tag `reflect`/`TaskRel` as simp. Tag only the sign-guarded bridge lemmas.
- **`omega` and the TemporalOrder carrier** (documented in the TaskFrame implementation notes): subtype values `⟨d, h⟩` add another coercion layer at ℤ sites. Use `reflect_of_nonneg` before `omega`.
- **Boneyard** frames (`SuccChainTaskFrame`, `CanonicalConstruction`) set `converse` but are not built. Leave them untouched (and out of the prose-rename lint scope) unless `check-module-invariants.sh` scans Boneyard text.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `reflect P w d u ↔ P w d u` given `0 ≤ d` (junk variant) | `simp [reflect, h, not_lt.mpr h]` | success | — |
| subtype variant, `x : {x // 0 ≤ x}` | `simp [reflect, x.2]` | success | — |
| `reflection` off zero | `simp only [TaskRel, reflect, dif_neg …, dif_pos …, neg_neg]` | success | `neg_nonneg`, `neg_neg_iff_pos` |
| `reflection` at zero | `F.eq_of_zero h ▸ F.nullity _` | success | derived `nullity`, `eq_of_taskRel_zero` |
| `reflect (R restricted) = R` from reflective R | `funext; propext; by_cases 0 ≤ d; simp [reflect, h]` / `(hR …).symm` | success | — |
| `ofReflective` field transport | `by rw [reflect_eq hR]; exact hcomp` | success | (`e ▸ hcomp` FAILS: motive picks up nested reflect) |
| translation frame Compositionality over `reflect` | `simp only [reflect, dif_pos …]; abel` | success | `add_nonneg` |
| translation frame Limit over `reflect` | `by_contra`, witness `|u - w|`, `split_ifs`/`dif` + `abel` | success | `abs_pos`, `sub_ne_zero` |
| `Serial F.TaskRel := F.serial` with non-reducible `TaskRel` def | term | success | default-transparency defeq |

## Context Extension Recommendations
- **Topic**: Encoding paper "notational conventions" (reflection extensions of D⁺-graded relations) in Lean structures
- **Gap**: No context file documents the "primitive-on-cone field plus derived extended relation plus smart constructor" pattern, or the `e ▸ h` motive pitfall versus `rw`
- **Recommendation**: after implementation, add a short pattern note under `.claude/context/project/lean4/patterns/` (edit the source store `agent-system/extensions/lean/...`, not `.claude/`)

## Appendix
- Search queries: `lean_local_search AddGroupCone`; `lean_leanfinder "relation indexed by nonnegative elements extended to negative elements by taking the converse relation"` (hits: `SetRel.inv`, `symmetrize`, none applicable); `#check Nonneg.coe_add`.
- Greps: `converse *:=` field sites; `\.converse\b` projections; `converse convention` across Lean/docs/typst/latex; `respects_task :=`; `Iff.rfl` in construction files.
- `scripts/check-paper-definitions.sh`: 16 drifted, 1 dangling (pre-existing). `def:task-relation` and `def:deterministic` are in scope.
- Suggested paper note (non-blocking, author's call): state the convention "for x > 0", or add that at `x = 0` it is consistent because `⇒_0` is the identity by `lem:nullity` and Limit.
