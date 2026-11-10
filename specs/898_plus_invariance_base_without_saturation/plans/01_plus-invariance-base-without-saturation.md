# Implementation Plan: Task #898

- **Task**: 898 - plus_invariance base without saturation
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/898_plus_invariance_base_without_saturation/reports/01_plus-invariance-base-without-saturation.md
- **Artifacts**: plans/01_plus-invariance-base-without-saturation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Research settled the open question mechanically: *Saturation* is consumed **nowhere** in the
`HistoryMorphism.lean` lifting chain, and the base frame needs **no** `def:frame` constraint at
all — only the source frame needs anything, and it needs exactly *Compositionality*, *Seriality*
and *Limit*. This plan lands that finding as code in the house style already used by
`reflection_of_limit` / `reflection`: the explicit-hypothesis form becomes the general theorem and
every `[IsRegular]` form is kept as a thin wrapper **with its statement verbatim**, so the diff is
additive and no call site changes. It then carries the same weakening through
`IntNormalForm.taskRel_eq_iter` to the completeness programme's actual entry point,
`UniversalCover.exists_orientedForest_cover`, supplies a concrete non-saturated base frame over
ℤ-time as the non-vacuity witness, and corrects the four docstrings that over-report Saturation as
consumed. Definition of done: every new declaration compiles sorry-free, every pre-existing
signature is byte-identical, and the full gate set plus a full `lake build` is green.

### Research Integration

The report's compiled probes (`specs/evidence/history-morphism-saturation-audit/`) are a
feasibility proof, not a sketch: the entire chain was transplanted with `[F'.IsRegular]
[F.IsRegular]` replaced by explicit hypotheses and compiles at exit 0 with no `sorry`. Three
findings drive the decomposition directly:

- **Finding 2** — the base's single use of `IsRegular` is `F.reflection` inside
  `exists_preimage_step_neg`, invoked only at `δ = intIso.symm 1 ≠ 0`, where
  `TaskFrame.reflect_reflection_of_ne` discharges it with **no constraint on the relation**. So
  the base-side weakening goes all the way to zero constraints, threading one `δ ≠ 0` hypothesis
  through four `private` lemmas.
- **Finding 5** — `UniversalCover`'s base-side `IsRegular` flows through
  `FrameOver.taskRel_eq_iter` (*Comp* + *Serial* + *Limit*, no *Saturation*) and
  `F.serial w 1 zero_le_one`, so the headline restates over a three-constraint base once
  `IntNormalForm` carries an explicit-hypothesis variant pair.
- **Finding 7** — the weakening is on the **transfer-from** side only.
  `ProofSystem.FrameClass.Sat` still demands `IsRegular` of a frame-class member, and the cover
  has *Saturation* via `saturation_of_orientedForest`. This asymmetry is what makes the
  completeness argument go through, and every new docstring must say so rather than letting the
  weakened headline read as stronger than it is.

Re-derived at plan-authoring time rather than carried: `grep -n IsRegular
FormalSystem/Semantics/HistoryMorphism.lean` returns exactly **7** declarations (lines 306, 382,
434, 445, 469, 530, 590), matching the report; `grep -n "Constraints consumed"` on the same file
returns exactly **3** occurrences (468, 525, 586); `UniversalCover.lean:441` carries the fourth;
`docs/theorem-index.md` carries exactly **2** rows for the touched declarations (480, 481); and
`suite_selection_select` returns `__FULL_SWEEP__` for every path this plan touches.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch's delegation context, and no ROADMAP.md was
consulted. This plan advances the completeness programme's countermodel-of-record step as
described in the task description, but records no roadmap-item linkage.

## Goals & Non-Goals

**Goals**:
- `exists_preimage_step_neg_of_ne` -- predecessor lifting with source *Limit* and a nonzero
  duration, taking no base-frame constraint.
- `exists_histMorphism_of_isZTime_of_constraints` -- the lift construction over a base carrying no
  `def:frame` constraint and a source carrying *Compositionality*, *Seriality* and *Limit*.
- `plus_invariance_of_isZTime_of_constraints` -- L⁺ truth transfer at the same minimal hypothesis
  set.
- `taskRel_natCast_iff_iter_of_constraints` -- the nonnegative decomposition core over explicit
  *Comp* + *Serial* + *Limit*.
- `taskRel_eq_iter_of_constraints` -- the full decomposition theorem over explicit
  *Comp* + *Serial* + *Limit*.
- `exists_orientedForest_cover_of_constraints` -- the completeness programme's entry point,
  restated over a base carrying *Comp* + *Serial* + *Limit* and no *Saturation*.
- `srel_reflective` -- the reflection law that lets the separating frame be wrapped as a
  `FrameOver intOrder`.
- `exists_nonSaturated_base_orientedForest_cover` -- the non-vacuity witness: a concrete
  `FrameOver intOrder` that is *Compositional*, *Serial*, *Limit*, provably **not** *Saturated*,
  and to which the weakened headline applies.

**Non-Goals**:
- The dense-time case. The chain's existing docstrings already record that the walk has no next
  step over dense time and that lifting a whole history would need a fibre-relative saturation
  property; nothing here changes that and it stays unattempted.
- Any new typeclass (e.g. a `FrameOver.IsPreRegular` bundling three constraints). The finding is
  **asymmetric** — base: nothing; source: three constraints — so it is not one class, and a fifth
  way to say the same thing matches none of the four existing `_of_limit` / `_of_serial_limit`
  precedents.
- Re-routing any existing consumer of `taskRel_eq_iter`, `coverFrame`, or the chain onto the new
  forms. Every `[IsRegular]` form keeps its statement verbatim and every call site stays as it is.
- Correcting the ~20 other `Constraints consumed: Compositionality, Seriality, Limit, Saturation`
  docstrings elsewhere under `FormalSystem/` (`Nomic/`, `Validity.lean`,
  `Correspondence/RigidityReal.lean`, ...). Only the four on the audited chain are in scope;
  auditing the rest is separate work with no bearing on this result.
- The report's Context Extension Recommendation (an "Instance-binder audit by transplant" section
  for `context/project/lean4/patterns/dependency-tracing.md`). That file's edit target lives in
  the agent-system **source store** outside this repository
  (`rules/source-store-deploy-boundary.md`), so it belongs to a separate meta task rather than to
  this task's `file_scope`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A restatement silently breaks an existing call site | H | L | Keep every `[IsRegular]` form's statement byte-identical and verify by building the changed module's enumerated direct dependents (Phases 1-3 each declare `interface` for exactly this reason), not only the changed module |
| The `taskRel_eq_iter` wrapper rewrite ripples through its 12 direct dependents | M | L | The statement is preserved verbatim and only the proof body becomes a wrapper call; Phase 2's `interface` build covers the dependent set, and on any breakage the fallback is pure addition with the original proof body left untouched |
| `coverFrame`'s `def` becoming a wrapper changes definitional unfolding under the hood | M | M | `coverFrame F` is defined as `coverFrameOfSerial F F.serial` so it unfolds to the same term; `coverFrame_taskRel` and `coverFrame_isRegular` are re-proved against the new def in the same phase and their statements are preserved |
| The `sepFrame` witness pulls `StateTopology` into the chain's import closure | H | L | The witness lands **inside** the leaf `ConstraintWitnesses.lean`, which nothing under `FormalSystem/` imports (`docs/ARCHITECTURE.md`, "The state topology is a leaf, on purpose"). The new `import FormalSystem.Semantics.UniversalCover` edge therefore adds weight to nothing else, exactly as that module's existing `Extension.Completion` import note already records for a single-declaration dependency |
| The weakened headline reads as stronger than it is, because `FrameClass.Sat` still demands `IsRegular` | M | M | Every new public docstring states the weakening is on the **transfer-from** side only and that class membership of the countermodel still requires *Saturation*, which the cover has by `saturation_of_orientedForest`. Phase 5 carries the same correction to the prose surfaces |
| Correcting the four over-reporting docstrings is forgotten as a drive-by | M | M | They are explicit objectives with their own verification: three in Phase 1, the fourth in Phase 3, each with a grep-confirmable acceptance criterion |
| The `ConstraintWitnesses.lean` packaging-asymmetry correction reads as record-versioning narration | L | M | State the current fact (`srel` carries a `FrameOver` wrapper via this reflection law) without narrating the prior draft, per `rules/no-record-versioning-in-deliverables.md` |
| A phase-end `lake build` exceeds the foreground tool cap | M | M | Route every build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- ...` with the Bash tool `timeout` raised to 600000, or detach as a shell-level background job and block with the bounded single-call idiom (`context/project/lean4/operations/long-builds.md`); never `Bash(run_in_background: true)` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. Note that `lake-build-guard.sh` serializes
concurrent builds against this project, so parallel execution of Phases 1 and 2 (or 4 and 5) gains
nothing at the build step even though their edits are content-independent.

### Phase 1: Saturation-free lift chain in HistoryMorphism.lean [COMPLETED]

**Goal**: Land the explicit-hypothesis forms of the whole chain with no `[IsRegular]` on either
frame, keep both public `[IsRegular]` forms as verbatim-statement wrappers, and correct the three
docstrings in this module that over-report *Saturation* as consumed.

**Tasks**:
- [x] Add `TwoWayBounded.exists_preimage_step_neg_of_ne` taking `hlim' : TaskFrame.Limit F'.TaskRel`
      and `hx : x ≠ 0`, with no base-frame constraint, using
      `TaskFrame.reflect_reflection_of_ne (P := F.PosRel) hx` for the base-side step and
      `F'.reflection_of_limit hlim'` for the source side. Source:
      `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean`.
- [x] Rewrite `exists_preimage_step_neg` as a thin `[F'.IsRegular] [F.IsRegular]` wrapper, its
      statement byte-identical to the current one at line 306. *(completed: routed through
      `exists_preimage_step_neg_of_ne` at `x ≠ 0`; the `x = 0` case, which is outside that form's
      domain, is `nullity_identity` on each side and is the one place the base frame's instance
      binder is read, which is why both binders are retained)*
- [x] Reparameterise the four `private` lemmas `bwdSeq_spec`, `chain_spec`, `chain_step`,
      `chain_rel` over `hcomp' / hser' / hlim' / hδne` in place of the two instance binders. These
      are `private`, so no external statement is owed and no wrapper is owed. Do **not** thread
      `hδne` through `fwdSeq_spec`, which does not need it (the probe's uniform threading produced
      an unused-binder linter warning there).
- [x] Add `TwoWayBounded.exists_histMorphism_of_isZTime_of_constraints` as the general theorem,
      with the signature pinned under `## Lean Challenge Statements`.
- [x] Add `TwoWayBounded.plus_invariance_of_isZTime_of_constraints` as the general theorem, same
      pinning.
- [x] Rewrite `exists_histMorphism_of_isZTime` and `plus_invariance_of_isZTime` as thin
      `[IsRegular]` wrappers, statements byte-identical to the current ones at lines 530 and 590,
      discharging the three source-side hypotheses with `F'.comp`, `F'.serial`, `F'.limit` and the
      `δ ≠ 0` hypothesis with the `congrArg intIso` / `OrderAddMonoidIso.apply_symm_apply` /
      `one_ne_zero` route the report's tactic survey records.
- [x] Replace the three `Constraints consumed: Compositionality, Seriality, Limit, Saturation`
      lines (468, 525, 586) with the audited set, stating on which side each constraint lands:
      source `F'`: *Compositionality*, *Seriality*, *Limit*; base `F`: none.
- [x] In the two public `_of_constraints` docstrings, record Finding 7's caveat: the weakening is
      on the transfer-from side only, and `ProofSystem.FrameClass.Sat` still requires `IsRegular`
      of a frame-class member.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that `FormalSystem/Semantics/HistoryMorphism.lean`
carries exactly 7 `IsRegular` binders (306, 382, 434, 445, 469, 530, 590) and exactly 3
`Constraints consumed: ...` lines (468, 525, 586), and that the module has exactly 8 direct
dependents under `FormalSystem/` besides the `FormalSystem/Semantics.lean` root
(`UniversalCover`, `Frames/TranslationProduct`, `Metalogic/Decidability/WitnessFamily/Sharing/Stability`,
`HybridLanguage/HybridInvariance`, `HybridLanguage/HybridTransposition`,
`HybridLanguage/HybridRecurrence`, `QuantLanguage/QuantInvariance`,
`QuantLanguage/QuantRecurrence`). All three figures were re-derived by grep at plan-authoring time
rather than carried from the research report; confirm each again at implementation time with
`grep -n IsRegular`, `grep -n "Constraints consumed"`, and
`grep -rln "import FormalSystem.Semantics.HistoryMorphism" FormalSystem/`, since line numbers
drift with every edit in this phase.

**Tier Justification**: this phase's load-bearing claim is that both public wrapper signatures
stay byte-identical so no call site changes, which only a build of the enumerated direct
dependents can confirm -- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.HistoryMorphism FormalSystem.Semantics.UniversalCover
FormalSystem.Semantics.Frames.TranslationProduct
FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability
FormalSystem.HybridLanguage.HybridInvariance FormalSystem.HybridLanguage.HybridTransposition
FormalSystem.HybridLanguage.HybridRecurrence FormalSystem.QuantLanguage.QuantInvariance
FormalSystem.QuantLanguage.QuantRecurrence` -- and `suite_selection_select` returns
`__FULL_SWEEP__` for this path, so no shell test suite covers it and none is claimed.

**Files to modify**:
- `FormalSystem/Semantics/HistoryMorphism.lean` - add the five explicit-hypothesis forms, reparameterise four private lemmas, rewrite three `[IsRegular]` declarations as verbatim-statement wrappers, correct three `Constraints consumed` lines

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.HistoryMorphism`
  exits 0 with no errors and no `sorry`.
- The nine-module dependent build named in the Tier Justification exits 0.
- `git diff FormalSystem/Semantics/HistoryMorphism.lean` shows the three preserved signatures
  (`exists_preimage_step_neg`, `exists_histMorphism_of_isZTime`, `plus_invariance_of_isZTime`)
  changed in body only, never in statement.
- `grep -c "Constraints consumed: Compositionality, Seriality, Limit, Saturation"
  FormalSystem/Semantics/HistoryMorphism.lean` returns 0.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` exits 0 (task-reference lint;
  gate 3 would SKIP here and is deliberately not selected).

---

### Phase 2: Explicit-hypothesis decomposition theorem in IntNormalForm.lean [COMPLETED]

**Goal**: Add `taskRel_natCast_iff_iter_of_constraints` and `taskRel_eq_iter_of_constraints` over
explicit *Compositionality*, *Seriality* and *Limit*, with the two `[IsRegular]` forms kept as
verbatim-statement wrappers, so Phase 3 has a Saturation-free route to `taskRel_eq_iter`.

**Tasks**:
- [x] Add `FrameOver.taskRel_natCast_iff_iter_of_constraints` with the signature pinned under
      `## Lean Challenge Statements`, reusing the existing proof body with `F.nullity_identity`
      replaced by `TaskFrame.nullity_identity_of_serial_limit hser hlim` and `F.comp` replaced by
      `hcomp`.
- [x] Add `FrameOver.taskRel_eq_iter_of_constraints`, same pinning, reusing the existing proof body
      with `F.reflection` replaced by `F.reflection_of_limit hlim` and the recursive call routed to
      `taskRel_natCast_iff_iter_of_constraints`.
- [x] Rewrite `taskRel_natCast_iff_iter` and `taskRel_eq_iter` as thin `[F.IsRegular]` wrappers
      discharging the three hypotheses with `F.comp`, `F.serial`, `F.limit`. Statements must stay
      byte-identical to the current ones at lines 204 and 232.
- [x] Record in each new docstring which constraints are consumed and that `taskRel_eq_iter`'s
      `[IsRegular]` form is now a wrapper over the minimal-hypothesis general theorem.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that
`FormalSystem/Semantics/IntNormalForm.lean` has exactly 12 direct dependents under
`FormalSystem/` besides the `FormalSystem/Semantics.lean` root
(`IntNormalFormEffective`, `OrientedForest`, `SlicedFrame`, `Periodicity`, `Nomic/ZTime`,
`Correspondence/FwdRecBridge`, `Extension/PeriodicExtension`,
`Metalogic/Decidability/IntPresentation`,
`Metalogic/Decidability/PlusSlicedCertificate/Limits/FiniteCarrier`,
`Metalogic/Decidability/PlusSlicedCertificate/Limits/NoFiniteWidth`, `PlusLanguage/PlusRayFibre`,
`OpenLanguage/OpenOckhamist`), re-derived at plan-authoring time with
`grep -rln "import FormalSystem.Semantics.IntNormalForm$" FormalSystem/`. Confirm with the same
grep at implementation time before composing the dependent build, since any import added
elsewhere since authoring would widen the set.

**Tier Justification**: the existing `taskRel_eq_iter` proof body changes (it becomes a wrapper
call) while its statement is preserved, and the only check that actually covers "no dependent
broke" across that module's 12 direct dependents is the build of them -- `bash
.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.IntNormalForm` followed by the 12 enumerated dependent modules -- with
`suite_selection_select` returning `__FULL_SWEEP__` for this path, so no shell suite is claimed to
cover it.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - add two `_of_constraints` theorems, rewrite the two `[IsRegular]` forms as verbatim-statement wrappers

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.IntNormalForm`
  exits 0, no errors, no `sorry`.
- A single guarded build naming the 12 enumerated dependent modules exits 0.
- `git diff FormalSystem/Semantics/IntNormalForm.lean` shows `taskRel_natCast_iff_iter` and
  `taskRel_eq_iter` changed in body only, never in statement.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` exits 0.

---

### Phase 3: Saturation-free oriented-forest cover headline in UniversalCover.lean [COMPLETED]

**Goal**: Restate the completeness programme's entry point over a base carrying only
*Compositionality*, *Seriality* and *Limit*, keeping `coverFrame`, `endpt_twoWayBounded` and
`exists_orientedForest_cover` as verbatim-statement `[F.IsRegular]` wrappers, and correct the
fourth over-reporting docstring.

**Tasks**:
- [x] Add `coverFrameOfSerial (F : FrameOver intOrder) (hser : TaskFrame.Serial F.TaskRel) :
      FrameOver intOrder`, the current `coverFrame` body with
      `fun w => (F.serial w 1 zero_le_one).1` / `.2` replaced by the corresponding projections of
      `hser`.
- [x] Redefine `coverFrame F` as `coverFrameOfSerial F F.serial` so it unfolds to the same term,
      and re-prove `coverFrame_taskRel` and the `coverFrame_isRegular` instance against it with
      their statements unchanged. Add the matching `coverFrameOfSerial_taskRel` and
      `coverFrameOfSerial_isRegular`.
- [x] Add `endpt_twoWayBounded_of_constraints` over `hcomp / hser / hlim`, routing through
      `F.taskRel_eq_iter_of_constraints hcomp hser hlim` from Phase 2, and keep
      `endpt_twoWayBounded` as a verbatim-statement wrapper.
- [x] Add `exists_orientedForest_cover_of_constraints` with the signature pinned under
      `## Lean Challenge Statements`, applying
      `TwoWayBounded.plus_invariance_of_isZTime_of_constraints` from Phase 1 with the cover's own
      *Comp* / *Serial* / *Limit* taken from `coverFrameOfSerial_isRegular`.
- [x] Keep `exists_orientedForest_cover` as a thin `[F.IsRegular]` wrapper, statement
      byte-identical to the current one at line 507.
- [x] Replace the `Constraints consumed: Compositionality, Seriality, Limit, Saturation` line at
      `UniversalCover.lean:441` with the audited set, naming the base side explicitly.
- [x] Record Finding 7's caveat in `exists_orientedForest_cover_of_constraints`' docstring: the
      base need not be *Saturated*, the **cover** is (by `saturation_of_orientedForest`), and that
      is what makes the cover a bona fide `FrameClass.Sat .ZTime` member carrying the refutation.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that `FormalSystem/Semantics/UniversalCover.lean` has
exactly one direct dependent, the `FormalSystem/Semantics.lean` library root, and exactly one
`Constraints consumed: ...` line (441). Both were re-derived at plan-authoring time with
`grep -rln "import FormalSystem.Semantics.UniversalCover" FormalSystem/ Tests/` and
`grep -n "Constraints consumed"`. Re-confirm both before composing the dependent build; Phase 4
is planned to add a second importer, so run this grep before Phase 4 lands if the phases are
reordered.

**Tier Justification**: this phase changes a `def` (`coverFrame` becomes a wrapper over
`coverFrameOfSerial`), so definitional unfolding at any downstream use site is in the blast
radius and only a build of the module plus its single direct dependent covers it -- `bash
.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.UniversalCover FormalSystem.Semantics` -- with `suite_selection_select`
returning `__FULL_SWEEP__` for this path, so no shell suite is claimed.

**Files to modify**:
- `FormalSystem/Semantics/UniversalCover.lean` - add `coverFrameOfSerial` and its two companion theorems, two `_of_constraints` theorems, rewrite `coverFrame`/`endpt_twoWayBounded`/`exists_orientedForest_cover` as verbatim-statement wrappers, correct one `Constraints consumed` line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.UniversalCover FormalSystem.Semantics`
  exits 0, no errors, no `sorry`.
- `git diff FormalSystem/Semantics/UniversalCover.lean` shows `coverFrame_taskRel`,
  `coverFrame_isRegular`, `endpt_twoWayBounded` and `exists_orientedForest_cover` changed in body
  only, never in statement.
- `grep -c "Constraints consumed: Compositionality, Seriality, Limit, Saturation"
  FormalSystem/Semantics/UniversalCover.lean` returns 0.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` exits 0.

---

### Phase 4: Non-saturated base witness in the StateTopology leaf [COMPLETED]

**Goal**: Wrap `SeparatingFrame.srel` as a `FrameOver intOrder`, prove it *Compositional*,
*Serial*, *Limit* and **not** *Saturated*, apply Phase 3's weakened headline to it so the
weakening is demonstrably non-vacuous, and correct the module's packaging-asymmetry paragraph.

**Tasks**:
- [x] Add `import FormalSystem.Semantics.UniversalCover` to
      `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, with a comment in the
      existing style of that file's `Extension.Completion` import note naming the single
      declaration that consumes it and recording that this module is a leaf, so the edge adds
      weight to nothing else.
- [x] Add `SeparatingFrame.srel_reflective`, the signature pinned under
      `## Lean Challenge Statements`, proved by `rw [srel_iff, srel_iff, abs_sub_comm]; norm_num`
      per the report's tactic survey.
- [x] Add `def sepFrame : FrameOver intOrder := FrameOver.ofReflective ℚ srel srel_reflective`
      and `sepFrame_taskRel : sepFrame.TaskRel = srel` via `FrameOver.ofReflective_taskRel_eq`.
- [x] Add `sepFrame_comp`, `sepFrame_serial`, `sepFrame_limit` and `sepFrame_not_saturation`, each
      `rw [sepFrame_taskRel]` onto the existing bare-relation theorems `srel_compositional`,
      `srel_serial`, `srel_limit`, `not_srel_saturation`.
- [x] Add `exists_nonSaturated_base_orientedForest_cover`, the signature pinned under
      `## Lean Challenge Statements`, witnessed by `sepFrame` and discharged by
      `exists_orientedForest_cover_of_constraints` from Phase 3.
- [x] Update the `**A packaging asymmetry, recorded rather than papered over.**` paragraph
      (currently at `ConstraintWitnesses.lean:142`) to state the current fact: `srel` carries a
      `FrameOver` wrapper via `srel_reflective`, so the separating row is certified at the frame
      level, and `RationalTwoOrigins.rel` remains bare-relation-only. State this as the current
      design, with no narration of the prior draft, per
      `rules/no-record-versioning-in-deliverables.md`.
- [x] Add a regression `example` or `theorem` in
      `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` applying
      `exists_nonSaturated_base_orientedForest_cover`, so the witness has a test-library consumer
      as well as a library one.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that
`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` has **zero** importers under
`FormalSystem/` (it is a declared leaf per `docs/ARCHITECTURE.md`'s "The state topology is a leaf,
on purpose"), and that `srel_compositional`, `srel_serial`, `srel_limit` and
`not_srel_saturation` all already exist in that module. Confirm at implementation time with
`grep -rln "import FormalSystem.Semantics.StateTopology.ConstraintWitnesses" FormalSystem/`
returning nothing and `grep -n "theorem srel_\|not_srel_saturation"` on that file; if the leaf
claim no longer holds, stop and raise it rather than adding the `UniversalCover` import, since the
import edge is only safe under leaf status.

**Tier Justification**: the module is a declared leaf with zero importers under `FormalSystem/`,
so the entire blast radius of these additions is the two files this phase touches, and the
cheapest covering check is `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
build FormalSystem.Semantics.StateTopology.ConstraintWitnesses
BimodalTest.Semantics.OrientedForestSaturationTest`; `suite_selection_select` returns
`__FULL_SWEEP__` for both paths, so no shell suite is claimed to cover them.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` - add the UniversalCover import, srel_reflective, sepFrame and its four constraint theorems, the non-vacuity theorem, and the packaging-asymmetry paragraph correction
- `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` - add a regression consumer of the non-vacuity theorem

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.StateTopology.ConstraintWitnesses BimodalTest.Semantics.OrientedForestSaturationTest`
  exits 0, no errors, no `sorry`.
- `grep -rln "import FormalSystem.Semantics.StateTopology.ConstraintWitnesses" FormalSystem/`
  returns nothing, confirming the leaf status still holds after the edit.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` exits 0.

---

### Phase 5: Correct the prose surfaces that record Saturation as the obstruction [COMPLETED]

**Goal**: Bring the three prose records in line with the audited constraint sets, with every edit
confined to a docstring or markdown region.

**Tasks**:
- [x] In `FormalSystem/Metalogic/NamingRules.lean`'s "Not formalized" section (the paragraph
      currently at lines 64-95 ending "*Saturation* is the obstruction."), record what Finding 7
      establishes: the obstruction was reasoned from `FrameOver.ofReflectiveRegular` demanding all
      four constraints, whereas `FrameOver.ofReflective` presents a frame from a reflective
      relation with none, and the chain consumes only *Comp* + *Serial* + *Limit* of the source.
      State what survives: `ProofSystem.FrameClass.Sat` still requires `IsRegular` of a
      frame-class member, so *Saturation* remains genuinely required of the **countermodel**, which
      the cover supplies via `saturation_of_orientedForest`. Keep the three failing-route
      enumeration, reframed as applying to the class-membership obligation rather than to the lift.
- [x] In `FormalSystem/Semantics.lean`'s `UniversalCover` bullet (currently at lines 120-126),
      update "every regular frame over `intOrder` has a regular cover frame" to state the
      weakened headline alongside it: a base carrying *Compositionality*, *Seriality* and *Limit*
      — no *Saturation* — has a regular cover frame with surjective, `TwoWayBounded` endpoint
      projection and L⁺ truth transfer.
- [x] In `FormalSystem/Semantics.lean`'s `HistoryMorphism` bullet (currently at lines 127-130),
      note that the lift and L⁺ invariance results now carry explicit-hypothesis forms taking no
      base-frame constraint.
- [x] Update the two `docs/theorem-index.md` rows for
      `TwoWayBounded.exists_histMorphism_of_isZTime` and
      `TwoWayBounded.plus_invariance_of_isZTime` (currently lines 480-481) to point at the
      `_of_constraints` general theorems, and add rows for
      `exists_orientedForest_cover_of_constraints` and
      `exists_nonSaturated_base_orientedForest_cover`.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that `docs/theorem-index.md` carries exactly 2 rows
naming any of the five touched declarations, re-derived at plan-authoring time with
`grep -n "exists_histMorphism_of_isZTime\|plus_invariance_of_isZTime\|exists_orientedForest_cover\|taskRel_eq_iter\|endpt_twoWayBounded" docs/theorem-index.md`
(hits at lines 480 and 481 only). Re-run that grep at implementation time: a row added elsewhere
since authoring would widen the edit, and the two hits are the only confirmed correction targets.

**Tier Justification**: every hunk in this phase lies inside a Lean module docstring (`/-! ... -/`)
or a markdown table, with zero compile or elaboration surface, so the `prose` row's diff
read-through is the covering check, supplemented by `bash .claude/scripts/verify-deploy.sh
--skip-slow --only-gate 4` because `suite_selection_select` returns `__FULL_SWEEP__` for all three
paths (no shell suite covers them) and these are deploy-consumer-tree paths outside `specs/**`,
where gate 3 correctly SKIPs and gate 4 is the real check.

**Files to modify**:
- `FormalSystem/Metalogic/NamingRules.lean` - correct the recorded Saturation obstruction in the "Not formalized" section docstring
- `FormalSystem/Semantics.lean` - update the `UniversalCover` and `HistoryMorphism` module-docstring bullets
- `docs/theorem-index.md` - update two existing rows and add two rows

**Scope expansion, gate-driven (explained, not absorbed)**: running the repository's full
`scripts/check-module-invariants.sh` for the first time in this task surfaced five failures caused
by Phases 1-4, each repaired here rather than deferred. The repairs touched five files beyond the
three planned:
- `FormalSystem/Semantics/{HistoryMorphism,IntNormalForm,UniversalCover}.lean` and
  `StateTopology/ConstraintWitnesses.lean` - C34 requires every `Constraints consumed:` marker to
  use the closed vocabulary `{Compositionality, Seriality, Limit, Saturation}` or `None`, so the
  side-attributing form this plan's Phase 1/3 tasks specified ("source `F'`: ...; base `F`: none")
  is not admissible on the marker LINE; the attribution moved into adjacent prose and the markers
  became bare lists. C34b additionally requires a marker on three wrappers the plan left unmarked,
  and C15 requires a `Paper:` line on every declaration carrying a theorem-index row.
- `scripts/check-module-invariants.sh` - four C14 axiom-baseline entries, so the `pinned:C14`
  cells on the new and repointed theorem-index rows name declarations the gate actually pins.
- `scripts/nolint-attribute-allowlist.txt` - the two `[F.IsRegular]` binders retained on the
  Phase 1 wrappers are now genuinely unread, which C16's `unusedArguments` linter reports
  correctly; the binders are kept for signature stability, so the finding is suppressed in source
  with its reason recorded at both sites and here.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Semantics/StateTopology/README.md`, `typst/generated/status.typ` - generated
  blocks, regenerated by their own tools (`--emit-inventory`, `typst-sync-check.sh --fix`).

One further note recorded in `issues.jsonl`: C16's printed remedy,
`lake exe runLinter --update FormalSystem`, is destructive in this repository - it rewrote
`scripts/nolints.json` from 914 lines to 237, discarding every grandfathered entry outside the
single root named. It was restored from a pre-run backup, verified byte-identical to `HEAD`, and
the in-source attribute route was used instead.

**Verification**:
- `git diff FormalSystem/Metalogic/NamingRules.lean FormalSystem/Semantics.lean` shows every
  changed hunk inside a `/-!`/`-/` docstring region, with no declaration text touched.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.NamingRules FormalSystem.Semantics`
  exits 0, confirming no docstring edit crossed out of its comment region.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4` exits 0.
- `grep -n "exists_orientedForest_cover_of_constraints" docs/theorem-index.md` returns a row.

---

### Phase 6: Full-project verification and zero-debt gate [COMPLETED]

**Goal**: Confirm the whole change is green end to end: a full unscoped `lake build`, a sorry-free
and axiom-clean audit of every new declaration, and the complete repository gate set.

**Tasks**:
- [x] Run the full unscoped project build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Prefer the
      foreground `timeout N <guard call>` form with the Bash tool `timeout` raised to 600000; if it
      does not fit one call, detach as a shell-level background job and block with the bounded
      single-call idiom from `context/project/lean4/operations/long-builds.md`. Never use
      `Bash(run_in_background: true)`.
- [x] Run `lean_verify` on each of the eight Goal declarations by fully qualified name, confirming
      no `sorryAx` and no unexpected axiom beyond the project's baseline.
- [x] Grep the five touched Lean files for `sorry`, `admit`, and the prohibited vacuous-definition
      patterns from `rules/lean4.md` ("Vacuous Definitions"), confirming none were introduced.
- [x] Confirm `grep -rc "Constraints consumed: Compositionality, Seriality, Limit, Saturation"`
      returns 0 for `FormalSystem/Semantics/HistoryMorphism.lean` and
      `FormalSystem/Semantics/UniversalCover.lean`, and that the ~20 occurrences elsewhere under
      `FormalSystem/` are untouched (they are an explicit Non-Goal).
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`, with no `--only-gate`
      and no `--skip-slow` filter. *(deviation: altered — discharged against the SCOPED tier
      `verify-deploy.sh --skip-slow --only-gate 3,4` (PASS) per this dispatch's Batch Gate
      Deferral directive, which defers the complete unfiltered set to the batch stage at the end
      of the enclosing /orchestrate invocation. `scripts/check-module-invariants.sh` was
      additionally run IN FULL — C1, C14, C15, C16, C34, C34a, C34b and INV all PASS — because
      Phases 1-4 turned out to have introduced findings there that no phase's declared
      Verification Tier and no `lake build` would have caught.)*

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the full touched-file set is exactly the seven files
enumerated across Phases 1-5 and that no other file under `FormalSystem/`, `Tests/` or `docs/`
changed. Confirm with `git status --short` and `git diff --stat` before the final commit; any file
outside that set is a deviation to be explained, not absorbed.

**Files to modify**:
- none planned -- this phase is verification only and modifies no file; a marker repair in the plan file itself is the only expected write

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 with no errors
  and no `sorry` anywhere in the project.
- `bash .claude/scripts/verify-deploy.sh` exits 0 -- the complete gate set, unfiltered, with
  neither `--only-gate` nor `--skip-slow`, since neither a gate subset nor a skipped-slow pass is
  evidence for this phase's purpose.
- `lean_verify` on all eight Goal declarations reports no `sorryAx`.
- `git diff --stat` lists exactly the seven files from Phases 1-5 plus this plan file.

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.UniversalCover
import FormalSystem.Semantics.StateTopology.ConstraintWitnesses

namespace FormalSystem.Semantics

open FormalSystem.PlusLanguage

/-- Predecessor lifting at a nonzero duration: source *Limit* only, no base-frame constraint. -/
theorem TwoWayBounded.exists_preimage_step_neg_of_ne
    {D : TemporalOrder} {F' F : FrameOver D} {f : F'.WorldState → F.WorldState}
    (hlim' : TaskFrame.Limit F'.TaskRel) (h : TwoWayBounded f)
    (a : F'.WorldState) (x : ↑D) (hx : x ≠ 0) (u : F.WorldState)
    (hu : F.TaskRel u x (f a)) :
    ∃ c : F'.WorldState, F'.TaskRel c x a ∧ f c = u := sorry

/-- The lift construction with no `def:frame` constraint on the base frame. -/
theorem TwoWayBounded.exists_histMorphism_of_isZTime_of_constraints
    {D : TemporalOrder} {F' F : FrameOver D}
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) :
    ∃ g : HistMorphism F' F, g.toFun = f := sorry

/-- L⁺ truth transfer at the minimal hypothesis set. -/
theorem TwoWayBounded.plus_invariance_of_isZTime_of_constraints
    {D : TemporalOrder} {F' F : FrameOver D}
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) (M : TaskModel F.toTaskFrame) :
    ∃ g : HistMorphism F' F, g.toFun = f ∧
      ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
        PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := sorry

/-- The nonnegative decomposition core over explicit *Comp* + *Serial* + *Limit*. -/
theorem FrameOver.taskRel_natCast_iff_iter_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (n : ℕ) (w u : F.WorldState) :
    F.TaskRel w (n : ℤ) u ↔ iter F.step n w u := sorry

/-- The decomposition theorem over explicit *Comp* + *Serial* + *Limit*, no *Saturation*. -/
theorem FrameOver.taskRel_eq_iter_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (w u : F.WorldState) (d : ℤ) :
    F.TaskRel w d u ↔
      (0 ≤ d → iter F.step d.natAbs w u) ∧ (d ≤ 0 → iter F.step d.natAbs u w) := sorry

/-- **The completeness programme's entry point, over a non-saturated base.** A base frame
carrying only *Compositionality*, *Seriality* and *Limit* has a regular oriented-forest cover
with surjective, two-way bounded endpoint projection, along which L⁺ truth transfers. -/
theorem exists_orientedForest_cover_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (M : TaskModel F.toTaskFrame) :
    ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
      TwoWayBounded f ∧ Function.Surjective f ∧
        ∃ g : HistMorphism F' F, g.toFun = f ∧
          ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
            PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := sorry

/-- The reflection law for unit-speed drift on ℚ over ℤ-time. -/
theorem StateTopology.SeparatingFrame.srel_reflective (w : ℚ) (d : ℤ) (u : ℚ) :
    StateTopology.SeparatingFrame.srel w d u ↔ StateTopology.SeparatingFrame.srel u (-d) w :=
  sorry

/-- **Non-vacuity.** A concrete `FrameOver intOrder` that is *Compositional*, *Serial* and
*Limit*, provably **not** *Saturated*, and to which the weakened headline applies. -/
theorem StateTopology.SeparatingFrame.exists_nonSaturated_base_orientedForest_cover :
    ∃ F : FrameOver intOrder,
      TaskFrame.Compositional F.TaskRel ∧ TaskFrame.Serial F.TaskRel ∧
        TaskFrame.Limit F.TaskRel ∧ ¬ TaskFrame.Saturation F.TaskRel ∧
        ∀ M : TaskModel F.toTaskFrame,
          ∃ (F' : FrameOver intOrder) (_ : F'.IsRegular) (f : F'.WorldState → F.WorldState),
            TwoWayBounded f ∧ Function.Surjective f ∧
              ∃ g : HistMorphism F' F, g.toFun = f ∧
                ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑intOrder),
                  PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := sorry

end FormalSystem.Semantics
```

## Decisions

- **Base-side weakening taken all the way to zero constraints**, not stopping at the *Limit* the
  task description anticipated. The `δ ≠ 0` route is one hypothesis threaded through four
  `private` lemmas and costs nothing; stopping at *Limit* would leave an unexplained binder in the
  public signature.
- **`[IsRegular]` forms preserved verbatim as wrappers** at every site, so the diff is additive
  and no existing call site changes. This is what keeps the change low-risk and is why Phases 1-3
  declare `interface` rather than `local`: verifying the preservation claim requires building the
  dependents, not merely the changed module.
- **No new typeclass.** The finding is asymmetric (base: nothing; source: three constraints), so
  it is not one class; the four existing `_of_limit` / `_of_serial_limit` precedents are the
  matching house style.
- **The non-vacuity witness lands in the leaf `ConstraintWitnesses.lean`, not in `Semantics/`.**
  `docs/ARCHITECTURE.md` records the state topology as a leaf on purpose; adding the
  `UniversalCover` import there adds weight to nothing else, and the module already carries a
  precedent note for a single-declaration import of exactly this shape. A test-library consumer
  is added alongside, not instead.
- **Phase 2's dependent build is accepted as the cost of the wrapper rewrite.** The cheaper
  alternative — pure addition with `taskRel_eq_iter`'s original proof body left untouched — was
  rejected because it duplicates a nontrivial proof, and is recorded in Risks as the fallback if
  the wrapper rewrite breaks a dependent.
- **The dense-time case stays unattempted**, as the chain's existing docstrings already record.

## Testing & Validation

- [x] Full unscoped `lake build` exits 0 with no errors and no `sorry` project-wide (Phase 6).
- [x] All eight Goal declarations exist at their pinned signatures and pass `lean_verify` with no
      `sorryAx` (Phase 6).
- [x] Every pre-existing signature the plan touches is byte-identical in `git diff`:
      `exists_preimage_step_neg`, `exists_histMorphism_of_isZTime`, `plus_invariance_of_isZTime`,
      `taskRel_natCast_iff_iter`, `taskRel_eq_iter`, `coverFrame_taskRel`, `coverFrame_isRegular`,
      `endpt_twoWayBounded`, `exists_orientedForest_cover` (Phases 1-3).
- [x] Each changed module's enumerated direct dependents build clean (Phases 1-3).
- [x] `ConstraintWitnesses.lean` still has zero importers under `FormalSystem/` after the witness
      lands (Phase 4).
- [x] Zero remaining `Constraints consumed: Compositionality, Seriality, Limit, Saturation` lines
      in `HistoryMorphism.lean` and `UniversalCover.lean`; the occurrences elsewhere under
      `FormalSystem/` unchanged (Phase 6).
- [x] No vacuous-definition pattern from `rules/lean4.md` introduced in any touched file
      (Phase 6).
- [x] `bash .claude/scripts/verify-deploy.sh` — discharged at the scoped tier (gates 3,4 PASS) per the Batch Gate Deferral directive; the unfiltered run is deferred to the batch stage (Phase 6).

## Artifacts & Outputs

- `FormalSystem/Semantics/HistoryMorphism.lean` — five explicit-hypothesis forms, four
  reparameterised private lemmas, three verbatim-statement wrappers, three corrected docstrings
- `FormalSystem/Semantics/IntNormalForm.lean` — two `_of_constraints` theorems, two
  verbatim-statement wrappers
- `FormalSystem/Semantics/UniversalCover.lean` — `coverFrameOfSerial` plus companions, two
  `_of_constraints` theorems, four verbatim-statement wrappers, one corrected docstring
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — `srel_reflective`, `sepFrame`
  and its four constraint theorems, the non-vacuity theorem, the corrected packaging-asymmetry
  paragraph
- `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` — a regression consumer of the
  non-vacuity theorem
- `FormalSystem/Metalogic/NamingRules.lean` — corrected record of the Saturation obstruction
- `FormalSystem/Semantics.lean` — updated `UniversalCover` and `HistoryMorphism` bullets
- `docs/theorem-index.md` — two updated rows, two new rows
- `specs/898_plus_invariance_base_without_saturation/summaries/01_plus-invariance-base-without-saturation-summary.md`
  — implementation summary at task completion

## Rollback/Contingency

Every phase is a scoped, additive edit to one or two files and is committed per green sub-step, so
the ordinary contingency is `git revert` of that phase's commit — no snapshot is needed and none
should be taken as a routine precaution.

Per-phase fallbacks, preferred over a revert:

- **Phase 1** — if a wrapper's `δ ≠ 0` discharge will not elaborate, keep the chain's private
  lemmas on `hδne` and specialise the wrapper at `intIso.symm 1` explicitly rather than abstracting
  the duration; the probe at
  `specs/evidence/history-morphism-saturation-audit/lift-chain-without-isregular.lean` is the
  reference term.
- **Phase 2** — if the wrapper rewrite breaks a dependent, revert `taskRel_natCast_iff_iter` and
  `taskRel_eq_iter` to their original proof bodies and keep the `_of_constraints` forms as pure
  additions. The Goals are unaffected.
- **Phase 3** — if `coverFrame`'s redefinition as `coverFrameOfSerial F F.serial` changes
  definitional behavior at any use site, leave `coverFrame` exactly as it is and let
  `coverFrameOfSerial` stand beside it as an independent construction; only
  `coverFrameOfSerial_taskRel` and `coverFrameOfSerial_isRegular` are then needed.
- **Phase 4** — if the `UniversalCover` import into the leaf is refused for any architectural
  reason surfaced at implementation time, move `exists_nonSaturated_base_orientedForest_cover`
  (and only it) into `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean`, keeping
  `srel_reflective` and the `sepFrame` family in the leaf. Raise the move rather than absorbing it
  silently, since it changes where a Goal identifier resolves.
- **Phase 5** — prose only; revert the three files individually with no effect on any proof.

If a phase genuinely cannot be executed as written, mark it `[BLOCKED]` in this plan and raise it.
`rules/plan-compliance.md` applies to every `.lean` file here: a would-be deviation is escalated,
never silently annotated and passed.
