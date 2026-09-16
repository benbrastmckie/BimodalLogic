# Implementation Plan: Task #601

- **Task**: 601 - Align task-frame definition with the paper's reflection convention
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: 599 (completed), 598 (completed). Coordinate with 602 (planning; also edits `Semantics/PartialHistory.lean`)
- **Research Inputs**: specs/601_align_task_frame_reflection_convention/reports/01_reflection-convention-encoding.md
- **Artifacts**: plans/01_reflection-convention-frame.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`FrameOver` currently has a two-sided `TaskRel` field plus a `converse` field. The paper
(`def:task-relation`, `def:frame`) instead has a primitive relation on D⁺, a notational reflection
convention, and exactly four axioms. This plan follows the research's Option A. The primitive
field becomes `PosRel : WorldState → {x : D // 0 ≤ x} → WorldState → Prop`.
`TaskRel := TaskFrame.reflect PosRel` becomes a non-reducible definition, split strictly at zero.
The four axiom fields are stated over `reflect PosRel`, and the reflection law is a derived
theorem, `FrameOver.reflection`. Construction sites move to a smart constructor,
`FrameOver.ofReflective`, which takes a two-sided relation plus a reflection proof. After that
comes a scoped prose rename, "converse convention" -> "reflection convention", in Lean, docs,
typst and LaTeX. Genuine converses are excluded. Done means a green full `lake build` and
BimodalTest, clean `check-module-invariants.sh` and `readme-lint.sh`, no new sorry or axioms, and
`def:task-relation`/`def:deterministic` re-pinned in paper-definitions-of-record.

### Research Integration

- Encoding: Option A (subtype-typed primitive, strict split, reflection derived at 0 from
  `nullity` + `eq_of_taskRel_zero`). All core proofs were prototyped sorry-free. Option B
  (junk-valued `PosRel : W → D → W → Prop`) is the fallback **only** if subtype coercions block a
  construction site. It sits behind `ofReflective`, so consumers never see the difference.
- Surface: 18 construction sites (grep today finds 17 `converse :=` lines outside Boneyard, see
  Phase 3/4 hypotheses), 28 `.converse` projections in 12 files, about 20 `respects_task`
  histories, and a set of `Iff.rfl` bridge lemmas at concrete frames.
- Pitfall: when transporting a field through `reflect_eq_of_reflective`, use `rw`, not `e ▸ h`.
  The motive picks up the nested `reflect`.
- Do not tag `reflect` or `TaskRel` as `@[simp]`. Tag only the sign-guarded bridges and
  `ofReflective_taskRel`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested (no `roadmap_path` or `roadmap_flag` in this dispatch).

### Decisions

- **No deprecated alias for `converse`.** The change is breaking anyway: the construction field
  `converse :=` disappears and cannot be aliased. Aliasing only the projection would be a
  half-measure. The repo is pre-1.0 ("flexible" in `docs/development/VERSIONING.md`), has no
  downstream consumers, and carries one `@[deprecated]` attribute in total. Rename directly:
  `converse` -> `reflection`, `converse_of_permissive` -> `reflection_of_permissive`, and
  site-local `*_converse` -> `*_reflection`.
- **Name D⁺** in `TemporalOrder.lean` as `abbrev TemporalOrder.PositiveCone (D) := {x : ↑D // 0 ≤ x}`.
  Do not use `Cone`, which would clash with `TaskFrame.cone`. The bare-relation
  `TaskFrame.reflect` keeps the raw subtype `{x : D // 0 ≤ x}`, since it is stated over a bare
  `D`. `FrameOver.PosRel` uses `D.PositiveCone`, which is reducibly the same type.
- **LaTeX** (`latex/subfiles/02-Semantics.tex`) is in scope for the prose rename, for
  consistency. Its "take converses" wording (genuine relational converses) stays.
- **Boneyard** is not built and is excluded from edits.
- The paper's "for x ≥ 0" overlap at 0 is recorded in the summary as a non-blocking note for the
  author. The paper is not edited.

## Goals & Non-Goals

**Goals**:
- `FrameOver` fields are exactly `WorldState`, `[worldNonempty]`, `PosRel`, `comp`, `serial`,
  `limit`, `saturation`. There is no reflection/converse field.
- Prove the challenge-pinned theorems `TaskFrame.reflect_eq_of_reflective`, `FrameOver.reflection`,
  `TaskFrame.reflection` (the total-space re-export). Also add the simp bridge
  ofReflective_taskRel, which is pinned by content (see Lean Challenge Statements).
- Add the definitions `TaskFrame.reflect`, `FrameOver.TaskRel`, `FrameOver.ofReflective`,
  `TemporalOrder.PositiveCone`, plus the sign-guarded API (`reflect_of_nonneg`, `reflect_of_neg`,
  `reflect_coe`).
- Migrate every live construction site and projection. Frame semantics stay unchanged.
- Rename the "converse convention" prose to "reflection convention" in Lean, README(s), docs/,
  typst/ and latex/, keeping genuine converses.
- Re-pin `def:task-relation` and `def:deterministic` in `docs/reference/paper-definitions-of-record.md`.

**Non-Goals**:
- Editing the paper (`possible_worlds.tex`).
- Fixing the other 14 drifted and 1 dangling anchors reported by `check-paper-definitions.sh`
  (pre-existing, out of scope).
- Editing `FormalSystem/Boneyard/**`.
- Renaming genuine converses: logical converses of theorems, `deductionConverse`,
  `orderDual_converse`, relational converse / `O-Conv`, "converse-closed", typst 02-semantics
  "Any converse operation ... superscript inverse".
- Adding the lean4 pattern context note. That is a source-store follow-up, outside this task's
  deliverables.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Iff.rfl`/`rfl` bridges at concrete frames break once `TaskRel` is no longer the literal relation | M | H | Rewrite them through `ofReflective_taskRel` (`simp`/`rw`). `genericTimeFrame ... = intTimeFrame.TaskRel := rfl` should stay `rfl` when both use `ofReflective` over the same R. Otherwise prove it via `funext` + `simp`. |
| `omega`/`linarith` fail on subtype `⟨d, h⟩` at ℤ sites | M | M | Rewrite with `reflect_of_nonneg`/`reflect_coe` before arithmetic tactics. Fall back to Option B only if a site stays blocked after about 30 minutes. Record the switch in the summary. |
| `FrameOver.TaskRel` as a non-reducible `def` breaks `F.serial : Serial F.TaskRel` defeq, or instance search | H | L | Prototyped as working. If elaboration fails, make it `@[reducible]` but keep it out of simp sets. Verify with a Phase 2 `example`. |
| Concurrent edits with 602 in `PartialHistory.lean` | L | M | The 601 edits there are one-token renames. Before Phase 3, check `git log` for 602 commits touching the file and rebase or merge by hand. Never revert 602's work. |
| Accidental rename of a genuine converse | M | M | Rename only by exact phrase ("converse convention") and exact identifiers, never with a blanket `s/converse/reflection/`. Phase 7 audits the remaining `converse` hits against the exclusion list. |
| typst "no separate *Reflection* axiom" now reads as if a Reflection axiom exists | L | M | Rephrase to "the reflection law is not an axiom: it is the reflection convention". |
| Long `lake build` times | M | H | Build per module (`lake build FormalSystem.Semantics.TaskFrame`), then dependents in wave order. Run the full build once per phase close, detached with a log. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |

Phases 1-4 are strictly sequential: each one's build depends on the previous one's signatures.
Phases 5 and 6 touch disjoint files (Lean docstrings vs non-Lean docs) and may run in parallel.
Do not run two `lake build`s concurrently.

### Phase 1: Additive reflection API [COMPLETED]

**Goal**: Add the D⁺ name and the bare-relation `reflect` API. Nothing existing changes yet, so
the tree stays green.

**Tasks**:
- [x] `TemporalOrder.lean`: add `abbrev PositiveCone (D : TemporalOrder) := {x : ↑D // 0 ≤ x}` with a
      docstring citing `def:temporal-order`. Rewrite the "## The positive cone" module doc: D⁺
      now types the primitive task relation.
- [x] `TaskFrame.lean`, `namespace TaskFrame` (bare `D` variables): add
      `def reflect (P : W → {x : D // 0 ≤ x} → W → Prop) (w : W) (d : D) (u : W) : Prop` with a
      strict `dite` split (`0 ≤ d` primitive, else `P u ⟨-d, _⟩ w`). The docstring cites
      `def:task-relation` verbatim ("reflection convention").
- [x] Prove `reflect_of_nonneg`, `reflect_of_neg`, `reflect_coe` (`@[simp]`),
      `reflect_reflection_of_ne` (for every P, `d ≠ 0`), and `reflect_eq_of_reflective`.
- [x] Add `reflection_of_permissive` next to `converse_of_permissive`. Leave the old lemma in place
      until Phase 3.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Semantics/TemporalOrder.lean` - `PositiveCone` abbrev, module doc
- `FormalSystem/Semantics/TaskFrame.lean` - `reflect` and API lemmas (additive)

**Verification**:
- `lake build FormalSystem.Semantics.TaskFrame` is green. `lean_verify` on
  `reflect_eq_of_reflective` shows only the standard axioms.

---

### Phase 2: Restructure FrameOver and derive reflection [COMPLETED]

**Goal**: Swap the structure to `PosRel` + four axioms. Derive `reflection`, add `ofReflective`,
and migrate every use inside `TaskFrame.lean`.

**Tasks**:
- [x] Replace the `TaskRel`/`converse` fields with `PosRel : WorldState → D.PositiveCone → WorldState → Prop`.
      Restate `comp`, `serial`, `limit`, `saturation` over `TaskFrame.reflect PosRel`, keeping
      their citation form (`TaskFrame.Serial (TaskFrame.reflect PosRel)` etc.). Rewrite the
      structure docstring and the per-field docstrings (the `comp` doc's "0 ≤ x hypotheses"
      paragraph, and remove the converse-field doc).
- [x] Add `def FrameOver.TaskRel (F) := TaskFrame.reflect F.PosRel` (non-reducible). Add
      `taskRel_of_nonneg`, `taskRel_of_neg`, and a `TaskRel`-level `taskRel_coe`.
- [x] Add `example (F : FrameOver D) : TaskFrame.Serial F.TaskRel := F.serial` and the matching
      Saturation example. These guard the Step Lemma's definitional-citation invariant.
- [x] Prove `FrameOver.reflection` (trichotomy; `dif` off zero; at zero,
      `eq_of_taskRel_zero ▸ nullity`). Check that `nullity`, `eq_of_taskRel_zero`,
      `nullity_identity`, `forward_comp`, `interpolates` still compile unchanged. Switch
      `backward_comp` to `reflection`.
- [x] Add `FrameOver.ofReflective (W) [Nonempty W] (R) (hR) (hcomp) (hser) (hlim) (hsat)`
      (field transport by `rw [reflect_eq_of_reflective hR]`, never `▸`) and
      `@[simp] ofReflective_taskRel`. *(deviation: altered — also added the equation form `ofReflective_taskRel_eq`, and `@[simp] trivialFrame_taskRel` for the total frame)*
- [x] Migrate the in-file frames `trivialFrame`, `staticFrame`, `natFrame` to `ofReflective`. Fix
      their `*_rel_iff` bridges and the 8 in-file `.converse` projections (-> `.reflection`).
- [x] `FiniteFrameOver` and the total-space `TaskFrame` accessors: replace the `converse`
      re-export with `theorem TaskFrame.reflection`. `TaskFrame.TaskRel` stays a `@[reducible]`
      delegate to `F.toFibre.TaskRel`. Fix `RoundTripIdentity`/`DefinitionalContent` sections if
      they mention the fields.
- [x] Delete `converse_of_permissive` if nothing in this file uses it any more. *(deviation: altered — deleted in Phase 2; its one external user, `Frames/Standard.lean`, is migrated in Phase 3)* Otherwise delete
      it in Phase 3 after its external uses move.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch (the structure swap leaves `TaskFrame.lean` red until every in-file
site is migrated; commit once the module builds)

**Scope Hypothesis**: 3 in-file construction sites and 8 in-file `.converse` projections. Confirm
with `grep -n "converse" FormalSystem/Semantics/TaskFrame.lean` before starting and after.
Zero identifier hits should remain (prose is handled in Phase 5).

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - structure, `TaskRel` def, `reflection`,
  `ofReflective`, in-file frames, total-space re-exports

**Verification**:
- `lake build FormalSystem.Semantics.TaskFrame` is green. `#print FormalSystem.Semantics.FrameOver`
  lists exactly the 7 fields. `lean_verify` on `FrameOver.reflection` and `ofReflective_taskRel`
  shows no `sorryAx` and only standard axioms.

---

### Phase 3: Migrate Semantics-layer consumers [COMPLETED]

**Goal**: Rebuild `FormalSystem/Semantics/**` green on the new structure.

**Tasks**:
- [x] Check first whether 602 has committed changes to `PartialHistory.lean`
      (`git log --oneline -5 -- FormalSystem/Semantics/PartialHistory.lean`). If so, work on top of them.
- [x] Construction sites to `ofReflective`, or to direct `PosRel` where the relation is naturally
      one-sided (translation/shift, per the prototype): *(deviation: altered — `ShiftSet.fibre` stays a `@[reducible]` literal with `PosRel` and fields cited from new transport lemmas `TaskFrame.{compositional,serial,limit,saturation}_reflect_of_reflective` / `reflect_restrict_iff`, because `RealTranslationFrame` needs its carrier reducible; all other sites use `ofReflective`)* `Frames/Standard.lean`
      (translationFrame, permissiveFrame, plus their `Iff.rfl` `*_taskRel` simp lemmas),
      `ShiftSet.lean`, `IntTransfer.lean` (`FrameOver.map`), `IntNormalForm.lean` (`ofStepRel`).
- [x] `.converse` -> `.reflection` in `Extension/Constraint.lean`, `PartialHistory.lean`,
      `PlusLanguage/PlusPasting.lean`, `IntNormalForm.lean`, `Extension/Admissible.lean`,
      `IntTransfer.lean`, `FrameProperty.lean` and `DeterministicBridge.lean` (paths confirmed by grep).
- [x] Fix `respects_task` histories at concrete frames (IntTransfer, DurationFrames,
      PartialHistory, PartialHistoryOrder, Extension, Admissible, DeterministicBridge, CoNotPriorU,
      DiscreteNonCompactness) with `ofReflective_taskRel` or the site's bridge lemma. Sites over
      an abstract `F` should need no change.
- [x] Remove `converse_of_permissive` once it has no users.
- [x] Build `lake build FormalSystem.Semantics` (or the individual modules), dependents in import order.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep (commit each module group once it builds)

**Scope Hypothesis**: 4 construction sites and about 12 `.converse` projection uses across about 10
Semantics files, plus under 10 concrete `respects_task`/`Iff.rfl` bridges. Confirm with
`grep -rn "converse *:=\|\.converse\b\|converse_of_permissive" FormalSystem/Semantics`
(Boneyard excluded) at start. The result must be empty at close.

**Files to modify**:
- `FormalSystem/Semantics/Frames/Standard.lean`, `ShiftSet.lean`, `IntTransfer.lean`,
  `IntNormalForm.lean`, `PartialHistory.lean`, `Extension/Constraint.lean`,
  `Extension/Admissible.lean`, `PlusLanguage/PlusPasting.lean`, `FrameProperty.lean`,
  `DeterministicBridge.lean`, and the concrete-frame history files named above (as grep confirms)

**Verification**:
- All Semantics modules build. The grep above returns nothing outside Boneyard.

---

### Phase 4: Migrate Examples, Metalogic and Tests [NOT STARTED]

**Goal**: Full `lake build` and BimodalTest green.

**Tasks**:
- [ ] `Examples/TemporalStructures.lean`: 3 frames plus the generic frames, `*_rel_iff` bridges,
      the `genericTimeFrame ... = intTimeFrame.TaskRel := rfl` example, 2 histories.
- [ ] Metalogic construction sites: `Algebraic/FlowFrame.lean`,
      `Decidability/Verified/Bridge/RegionFrame.lean`, `Decidability/FMP/Filtration.lean`,
      `Independence/{ClockFrame, DriftFrame, ForwardDeterministicFrame}.lean`,
      `WeakCanonical/IntegerModel/ReynoldsBridge.lean`. Rename site-local lemmas
      (`fzero_converse`, `fn_converse` if live) to `*_reflection`.
- [ ] `.converse` projections: `Independence/DriftFrame.lean`, `Independence/StarDiscrimination.lean`,
      `Independence/LoopingDuration.lean`. Fix concrete histories in ClockFrame, RegionFrame,
      FlowFrame, ReynoldsBridge (and RealTranslationFrame `f1_taskRel_iff`).
- [ ] Tests: `customFrame_rel_iff` and its `Or.inl` example in the TaskFrame test, and the field-name
      prose and any frame builds in `Tests/BimodalTest/Property/Generators.lean`.
- [ ] Run `lake build` (full) and `lake test` (BimodalTest) in the background with a log. Fix any
      remaining breakage.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 10 construction sites, 4 `.converse` projections, about 6 concrete
histories/bridges, and 7 `converse` hits in Tests. Confirm with
`grep -rn "converse *:=\|\.converse\b\|_converse\b" FormalSystem Tests --include=*.lean | grep -v Boneyard`.
After this phase, the only identifier hits left should be genuine converses (e.g.
`deductionConverse`, `orderDual_converse`).

**Files to modify**:
- `FormalSystem/Examples/TemporalStructures.lean` and the Metalogic files named above
- `Tests/BimodalTest/**` files that grep identifies (TaskFrame test, `Property/Generators.lean`)

**Verification**:
- Full `lake build` is green. `lake test` passes. `grep -rn "sorry" ` diff vs HEAD~ shows no new
  sorry, and no new `axiom` declarations.

---

### Phase 5: Lean prose rename [NOT STARTED]

**Goal**: Replace "converse convention" with "reflection convention" in every live Lean
docstring and comment, and rewrite prose that describes the old field packaging.

**Tasks**:
- [ ] Replace the exact phrase "converse convention" in `TaskFrame.lean`, `PartialHistory.lean`,
      `Extension/Admissible.lean`, `IntNormalForm.lean`, `Extension/Constraint.lean`,
      `Algebraic/FlowFrame.lean`, `PlusLanguage/PlusPasting.lean`, `Semantics.lean`,
      `Independence/ForwardDeterministicFrame.lean`, `Independence/LoopingDuration.lean`,
      `Independence/ClockFrame.lean`.
- [ ] Rewrite (not just rename) any prose that says the convention is "packaged as structure
      data" or "a field". It is now a definition (`TaskRel := reflect PosRel`) with the law
      derived (`reflection`).
- [ ] `FormalSystem/Semantics/README.md` L67-69: update the field list to
      `WorldState, worldNonempty, PosRel, comp, serial, limit, saturation` and the prose.
- [ ] Check every edited hunk is inside a comment or docstring. Genuine converses stay untouched.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 37 occurrences in 11 live Lean files. Confirm with
`grep -rn "converse convention" FormalSystem Tests --include=*.lean | grep -v Boneyard`
(expect 0 afterwards).

**Files to modify**:
- The 11 Lean files listed above (comments/docstrings only)
- `FormalSystem/Semantics/README.md`

**Verification**:
- The grep above returns 0. A diff read-through shows only comment/docstring hunks. A module
  build of `TaskFrame.lean` stays green (docstrings compile).

---

### Phase 6: Non-Lean docs, typst, LaTeX, definitions of record [NOT STARTED]

**Goal**: Make the prose documentation and the paper-definition pins consistent with the paper
and the new encoding.

**Tasks**:
- [ ] `README.md`, `docs/reference/API_REFERENCE.md` (L144, L161, L216 region): rename, and update
      the `FrameOver` field list and API entries (`reflection`, `ofReflective`, `PosRel`).
- [ ] `docs/reference/paper-definitions-of-record.md`: re-pin `def:task-relation` (about L685-689)
      and `def:deterministic` (about L1463) verbatim from `possible_worlds.tex` (L2803 and the
      def:deterministic block near L3518). Rename commentary prose.
- [ ] `typst/notation/bimodal-notation.typ`: `leanConverse` -> `leanReflection`
      (`raw("reflection")`). Update every user (grep `leanConverse` under `typst/`).
- [ ] `typst/chapters/02-semantics.typ` (L46, L56, L149): rewrite the field-packaging prose. Keep
      the L57 genuine relational converse. Rephrase "no separate Reflection axiom".
      `typst/chapters/06-notes.typ` L28, `typst/FormalFoundations.typ` L194/L282/L370: rename.
- [ ] `latex/subfiles/02-Semantics.tex` (L31/L37/L43/L57): rename. At L111, keep "take converses"
      and add "by the reflection convention" if it reads naturally.
- [ ] Compile the typst document (`typst compile typst/FormalFoundations.typ` to a scratch output)
      to confirm the renamed macro resolves.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 9 non-Lean files (README.md, FormalSystem/Semantics/README.md is in Phase 5,
API_REFERENCE.md, paper-definitions-of-record.md, 02-semantics.typ, 06-notes.typ,
FormalFoundations.typ, bimodal-notation.typ, 02-Semantics.tex). Confirm with
`grep -rln "converse convention\|leanConverse" README.md docs typst latex`. Expect none afterwards.

**Files to modify**:
- `README.md`, `docs/reference/API_REFERENCE.md`, `docs/reference/paper-definitions-of-record.md`
- `typst/notation/bimodal-notation.typ`, `typst/chapters/02-semantics.typ`,
  `typst/chapters/06-notes.typ`, `typst/FormalFoundations.typ`
- `latex/subfiles/02-Semantics.tex`

**Verification**:
- The grep above is empty. typst compiles. `bash scripts/check-paper-definitions.sh` no longer
  reports `def:task-relation` or `def:deterministic` as drifted (other pre-existing drift is unchanged).

---

### Phase 7: Final gates and converse audit [NOT STARTED]

**Goal**: Run the complete gate set and audit the remaining uses of "converse".

**Tasks**:
- [ ] Full `lake build` and `lake test` (BimodalTest), both green.
- [ ] `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`, both clean.
- [ ] Sorry/axiom check: compare `grep -rn "sorry\|^axiom" FormalSystem --include=*.lean | grep -v Boneyard`
      counts against the pre-task baseline (`git show <base>`). They must not increase.
      `lean_verify` on `FrameOver.reflection`, `TaskFrame.reflection`, `reflect_eq_of_reflective`,
      `ofReflective_taskRel`.
- [ ] Converse audit: `grep -rn -i "converse" FormalSystem Tests docs typst latex README.md | grep -v Boneyard`.
      Classify each remaining hit as a genuine converse (logical, relational, order dual) and
      confirm none refers to the D⁺ extension stipulation.
- [ ] Record in the summary: the Option A/B outcome, the paper note about "x ≥ 0" overlapping at
      0 (author's call), and the out-of-scope anchor drift.

**Timing**: 1.25 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Files to modify**:
- None expected (fix-ups only if a gate fails)

**Verification**:
- Every gate passes. The audit list is recorded in the implementation summary.

## Lean Challenge Statements

Statement pins against the post-implementation module. `reflect_eq_of_reflective` pins the bare
relation lemma. `FrameOver.ofReflective` is a definition whose argument order may be chosen by
the implementer. Its bridge is pinned here by its content: the constructed frame's `TaskRel` is
`R`.

```lean
import FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics

theorem TaskFrame.reflect_eq_of_reflective {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] {W : Type} (R : W → D → W → Prop)
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) :
    TaskFrame.reflect (fun w (x : {x : D // 0 ≤ x}) u => R w (x : D) u) = R := sorry

theorem FrameOver.reflection {D : TemporalOrder} (F : FrameOver D) (w : F.WorldState) (d : ↑D)
    (u : F.WorldState) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := sorry

theorem TaskFrame.reflection (F : TaskFrame) (w : F.WorldState) (d : F.Duration)
    (u : F.WorldState) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := sorry

end FormalSystem.Semantics
```

(`ofReflective_taskRel`: `(FrameOver.ofReflective W R hR hcomp hser hlim hsat).TaskRel w d u ↔ R w d u`.
Its exact binder list follows `ofReflective`'s final signature. Pinned by content, not by a
standalone block, because it cannot elaborate before the definition exists.)

## Testing & Validation

- [ ] `lake build` (full) green
- [ ] `lake test` (BimodalTest) green
- [ ] `scripts/check-module-invariants.sh` clean
- [ ] `scripts/readme-lint.sh` clean
- [ ] `#print FrameOver` shows exactly 7 fields, none named `converse`/`reflection`
- [ ] No new `sorry` or `axiom`. `lean_verify` shows standard axioms only on the new theorems
- [ ] `check-paper-definitions.sh`: `def:task-relation`, `def:deterministic` not drifted
- [ ] `grep "converse convention"` is empty across live Lean, docs, typst and latex
- [ ] typst document compiles

## Artifacts & Outputs

- `FormalSystem/Semantics/TemporalOrder.lean`, `FormalSystem/Semantics/TaskFrame.lean` (new encoding)
- Migrated construction/consumer files across `FormalSystem/Semantics`, `Examples`, `Metalogic`, `Tests`
- Updated `README.md`, `FormalSystem/Semantics/README.md`, `docs/reference/API_REFERENCE.md`,
  `docs/reference/paper-definitions-of-record.md`, typst chapters/notation, `latex/subfiles/02-Semantics.tex`
- `specs/601_align_task_frame_reflection_convention/summaries/01_reflection-convention-frame-summary.md`

## Rollback/Contingency

- Every phase commits only at green milestones (Phase 2 is one atomic commit), so a failed phase
  rolls back with `git revert` of that phase's commits. There is no working-tree reset of
  unrelated files.
- If Option A's subtype coercions block Phases 3-4 at more than one site after a bounded attempt,
  switch `PosRel` to Option B (junk-valued `W → D → W → Prop`). This touches `reflect`, its API and
  `ofReflective` only, because sites go through `ofReflective`. Record the switch.
- If deriving `reflection` at zero or the `ofReflective` transport fails unexpectedly, stop at
  Phase 2 with `[PARTIAL]`. Do not reintroduce a `converse` field or a sorry.
