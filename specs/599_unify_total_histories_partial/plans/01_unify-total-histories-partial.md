# Implementation Plan: Task #599

- **Task**: 599 - Unify total histories on PartialHistory (drop ConvexHistory as a structure)
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: None
- **Research Inputs**: specs/599_unify_total_histories_partial/reports/01_unify-total-histories-partial.md
- **Artifacts**: plans/01_unify-total-histories-partial.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Delete the `ConvexHistory` structure and re-base the whole history layer on `PartialHistory`:
totality is defined once (`PartialHistory.IsTotal`), convexity survives only as a paper-fidelity
predicate `PartialHistory.IsConvex`, and `TaskFrame.HF := {τ : PartialHistory F // τ.IsTotal}`.
`TruthAt`, the Plus/Minus/Star truth relations, `TruthCorr`, and all validity predicates then range
over `PartialHistory F`. This is what sec:Construction of the paper says: a world history is a
partial history whose domain is total. The migration touches about 91 Lean files. To keep every
phase ending on a green `lake build`, it goes through a temporary deprecated compatibility shim
(`abbrev ConvexHistory F := PartialHistory F` plus name aliases), which the final Lean phase
deletes. Docs and the PossibleWorlds talk slide are updated last, against the final source. Done
means: zero `ConvexHistory` identifiers in the live tree (`FormalSystem/`, `Tests/`; Boneyard
excluded), a green full build and test suite, no new `sorry` or axiom, and docs and the slide
quoting the new definitions.

### Research Integration

- Convexity is never *used* as a hypothesis anywhere live. It is only re-established or filled
  with `trivial`, so deleting the structure removes proof obligations and adds none.
- Every live `ConvexHistory` value is total. The non-total histories (`Extension.point`,
  `adjoin`, `chainSup`, the `DeterministicBridge` two-point history) are already `PartialHistory`.
- Duplicates to collapse: `IsTotal`, `total_nonempty`, `timeShift`, and `states_eq_of_time_eq`
  (whose binder explicitness differs between the two copies), plus the promotion glue in
  `Extension.lean` (`total_isConvex`, `toConvexHistory`, and the two lemmas about it). Dead code:
  `universal`, `universalTrivialFrame`, `universalNatFrame`, `stateAt`, and `timeShift_congr`
  (no live uses outside its own file).
- The feasibility probe compiled `IsConvex`, `IsTotal.isConvex`, `isConvex_timeShift` (via
  `add_le_add_left`, not `_right`), `ofTotal`, `isTotal_timeShift`, the re-based `HF`, `TruthAt`
  over `PartialHistory F`, and `extension` closed by `⟨⟨μ, htot⟩, le_def.mp hle⟩`.
- The shifted history's `domain`/`states` bodies are identical between the two `timeShift`
  definitions, so `rfl`/`show` proofs that unfold a shift survive retargeting.

### Decisions (recorded for the implementer)

- **Keep the hybrid predicate/subtype encoding (Decision A) unchanged. Only re-base it onto
  `PartialHistory`.** Research raised full bundling over `F.HF` as a non-blocking question. The
  user gave no answer, so this plan follows the research recommendation. Truth and validity keep
  the unbundled `(τ : PartialHistory F) (hτ : τ.IsTotal)` pattern, the box clause becomes
  `∀ σ : PartialHistory F, σ.IsTotal → …`, and the atom clause's `∃ (ht : τ.domain t)` conjunct
  stays. Full bundling is out of scope and belongs in a possible follow-up.
- `states_eq_of_time_eq` keeps the **explicit-times** signature, which already has 10 call sites.
  The implicit copy in `PartialHistoryOrder.lean` has exactly one caller (its own line ~158),
  which gets fixed.
- `ConvexHistory.trivial` becomes `PartialHistory.trivialFrameHistory`, not
  `PartialHistory.trivial`. The shorter name would shadow the root `trivial` term (e.g. in
  `⟨0, trivial⟩`) inside `namespace PartialHistory`.
- `IntTransfer.lean`'s `ConvexHistory.map`/`comap` become `PartialHistory.map`/`comap`.
- No `abbrev WorldHistory`: `TaskFrame.HF` remains the one name for H_F.
- Migration mechanism: a compatibility shim, then renames directory by directory, then deletion
  of the shim (see Phase 2). Fallback if the shim proves unworkable: do the rename as one
  `atomic-batch` sweep (see Rollback/Contingency).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists but has no item for the history layer. This is a fidelity and cruft
refactor adjacent to the semantics items, not a roadmap deliverable.

## Goals & Non-Goals

**Goals**:
- Define totality exactly once, on PartialHistory, and delete the ConvexHistory structure, its
  IsTotal wrapper, the promotion glue, and the dead declarations.
- Re-base H_F, truth (all four languages), truth transport, int transfer, and validity onto
  PartialHistory, keeping the hybrid predicate/subtype encoding.
- Keep convexity only as a Prop-valued predicate on PartialHistory, with totality-implies-convexity
  and shift-invariance lemmas.
- Consolidate the non-order history API (ofTotal, timeShift, states transport, totality under
  shift) in PartialHistory.lean. PartialHistoryOrder.lean keeps only order-theoretic content.
- Pinned theorem identifiers: `PartialHistory.isTotal_timeShift`.
- Update module docstrings, docs/**, the decision record (Decision B'), and the talk slide
  "Semantics in Lean II: Histories and Models" to match.

**Non-Goals**:
- Bundling truth and validity over F.HF (overturning Decision A), or removing the atom clause's
  domain conjunct.
- Editing the paper (the wording mismatch between the body and appendix def:world-history is
  recorded as a note only).
- Boneyard files, which are not built.
- Fixing the 16 pre-existing check-paper-definitions.sh anchor failures.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The shim (abbrev + aliases) does not carry every site: generalized field notation through an abbrev, `simp [ConvexHistory.ofTotal]` unfolding an alias, or structure-instance notation on the abbrev | M | M | Probe the shim with `lean_run_code` at the start of Phase 2. Sites the shim cannot carry get renamed directly in Phase 2. If the probe fails wholesale, switch to the atomic-batch fallback |
| `convex :=` fields, `.toPartialHistory` projections, and `ConvexHistory.mk (PartialHistory.mk _ _ _ _) _` patterns fail under any encoding | M | H (certain) | Enumerate them up front and fix them in Phase 2: about 12 relevant `convex :=` sites (the `DenseModelSurgery` hits belong to unrelated structures, so leave them), `.toPartialHistory` in Extension/PeriodicExtension/BiLasso Agreement, and 5 `mk` sites in FlowFrame/ReynoldsBridge |
| Wrong Mathlib lemma direction in `isConvex_timeShift` | L | M | Use `add_le_add_left hxy Δ`, which the probe verified |
| `simp` sets lose `ofTotal_domain`/`ofTotal_states` after the namespace move | M | L | Keep `@[simp]`. `trivial_truth_iff` in Decidability/Propositional/Decidable.lean is the canary |
| Blanket sed rewrites prose so that it wrongly calls something a "partial history" where the text discusses the convex tier | L | M | Review the diff per phase. Phase 7 sweeps the prose |
| Concurrent `lake build`s in one tree conflict | M | L | Lean phases run strictly sequentially. Only the prose/slide phases share a wave |
| Name clash on `PartialHistory.map`/`comap`/`ofTotal`/`IsConvex` | L | L | Run `lean_local_search` before adding each name |
| Long full-build time | M | M | Run one detached full `lake build` at each phase close. Run per-module `lake build <Module>` for inner iterations |

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
| 7 | 7, 8 | 6 |

Phases within the same wave can execute in parallel. Phases 3-5 only need Phase 2's shim, but
they run sequentially to avoid concurrent `lake build`s in a single tree.

### Phase 1: Additive PartialHistory API [COMPLETED]

**Goal**: Put the full target non-order API on `PartialHistory` without removing anything, so the
tree stays green.

**Tasks**:
- [x] Record a baseline: current `sorry` count and axiom profile of `FormalSystem`, and
  `check-paper-definitions.sh` failure count (expected 16). *(completed: 16 drifted + 1 unresolved anchor `thm:M5-valid`; 0 live `sorry`; 0 real `axiom` decls)*
- [x] Move `timeShift`, `timeShift_domain`, and `states_eq_of_time_eq` from
  `PartialHistoryOrder.lean` to `PartialHistory.lean`. Switch `states_eq_of_time_eq` to explicit
  times `(τ) (t₁ t₂) (h) (h₁) (h₂)` and fix its one caller in `PartialHistoryOrder.lean`
  (`timeShift_timeShift_neg_states`).
- [x] Add to `PartialHistory.lean`: `IsConvex` (convex domain, same shape as the old `convex`
  field), `IsTotal.isConvex`, `isConvex_timeShift`, `isTotal_timeShift`, `isTotal_iff` (only if a
  caller needs it; otherwise skip) *(deviation: altered — `isTotal_iff` skipped, no caller)*, `ofTotal` with `@[simp] ofTotal_domain`/`ofTotal_states` and
  `ofTotal_isTotal`, and `trivialFrameHistory`.
- [x] Keep one `total_nonempty` (the PartialHistory one), unchanged.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: `states_eq_of_time_eq` (implicit form) has exactly one caller. Confirm with
`grep -rn "states_eq_of_time_eq" FormalSystem Tests` before changing the binder.

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean` - receives the moved and new declarations
- `FormalSystem/Semantics/PartialHistoryOrder.lean` - loses the moved declarations and fixes the
  one caller

**Verification**:
- `lake build FormalSystem.Semantics.PartialHistoryOrder FormalSystem.Semantics.ConvexHistory
  FormalSystem.Semantics.Extension.Extension` is green, then a full `lake build` is green before
  the phase closes.
- `lean_verify` on `PartialHistory.isTotal_timeShift` and `PartialHistory.isConvex_timeShift`
  shows no `sorryAx`.

---

### Phase 2: Core flip behind a compatibility shim [NOT STARTED]

**Goal**: Make `PartialHistory` the carrier of H_F, truth, and validity. `ConvexHistory` survives
only as a deprecated alias layer.

**Tasks**:
- [ ] Probe the shim first with `lean_run_code`: `abbrev ConvexHistory (F) := PartialHistory F`,
  plus aliases (`ConvexHistory.ofTotal`, `ofTotal_isTotal`, `timeShift`, `states_eq_of_time_eq`,
  `IsTotal`, `isTotal_timeShift`, `total_nonempty`, `trivial`, `map`, `comap`). Check that
  `τ.IsTotal`, `τ.timeShift Δ`, structure-instance notation, and `simp [ConvexHistory.ofTotal]`
  behave. If the probe fails wholesale, stop and switch to the fallback in Rollback/Contingency.
- [ ] Move `TaskFrame.HF`, `HF.ofTotal`/`ofTotal_val`, `HF.timeShift`/`timeShift_val`, and
  `FrameOver.HF` into `PartialHistory.lean`, re-based as `{τ : PartialHistory F // τ.IsTotal}`
  (with `HF.ofTotal` built on `PartialHistory.ofTotal`).
- [ ] Rewrite `ConvexHistory.lean` as the deprecated shim, containing nothing but the aliases.
  Delete the structure, `universal`, `universalTrivialFrame`, `universalNatFrame`, `stateAt`, and
  `timeShift_congr`.
- [ ] `Extension.lean`: delete `total_isConvex`, `toConvexHistory`,
  `toConvexHistory_toPartialHistory`, and `isTotal_toConvexHistory`. Restate `extension` as
  `∃ σ : F.HF, Extends σ.val τ`, proved by `⟨⟨μ, htot⟩, le_def.mp hle⟩`. Drop the
  `ConvexHistory` import.
- [ ] Remove `.toPartialHistory` projections in `Extension/PeriodicExtension.lean` and
  `Metalogic/Decidability/BiLasso/Agreement.lean`.
- [ ] `IntTransfer.lean`: rename `map`/`comap` into the `PartialHistory` namespace and delete
  their `convex :=` blocks.
- [ ] Delete every remaining history-related `convex :=` field (DurationFrames x2,
  TemporalStructures x2, FlowFrame, RegionFrame, DiscreteNonCompactness, ClockFrame, CoNotPriorU,
  ReynoldsBridge x2). Do not touch the `DenseModelSurgery` hits.
- [ ] Rewrite the 5 `change ConvexHistory.mk (PartialHistory.mk _ _ _ _) _ = …` goals
  (FlowFrame x2, ReynoldsBridge x3; 10 lines) to `change PartialHistory.mk _ _ _ _ = …`.
- [ ] Rename directly (without waiting for Phases 3-6) any other site the shim demonstrably does
  not carry.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: About 12 history-related `convex :=` sites in 10 files, `.toPartialHistory`
in 3 files, and 10 `ConvexHistory.mk` lines (5 sites) in 2 files. Confirm with
`grep -rn "convex :=\|toPartialHistory\|ConvexHistory.mk" FormalSystem Tests | grep -v Boneyard`.
The remaining red set after the flip, observed from the first full build, is the ground truth.

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean`, `FormalSystem/Semantics/ConvexHistory.lean`,
  `FormalSystem/Semantics/Extension/Extension.lean`,
  `FormalSystem/Semantics/Extension/PeriodicExtension.lean`,
  `FormalSystem/Semantics/IntTransfer.lean`
- The `convex :=` / `mk` / `toPartialHistory` sites listed above

**Verification**:
- A full `lake build` is green, with no new `sorry` against the Phase 1 baseline.
- `lean_verify` on `PartialHistory.extension`, `PartialHistory.occurrence`, and
  `PartialHistory.hF_nonempty` shows an unchanged axiom profile.
- `grep -rn "structure ConvexHistory" FormalSystem` returns nothing.

---

### Phase 3: Rename in Semantics/ [NOT STARTED]

**Goal**: Retarget every `Semantics/` consumer from shim names to `PartialHistory` names.

**Tasks**:
- [ ] Rename, file by file, in `Truth.lean`, `TruthClauses.lean`, `TruthTransport.lean`,
  `Validity.lean`, `ValidityLayer.lean`, `TaskModel.lean`, `TaskFrame.lean`, `IntNormalForm.lean`,
  `ShiftSet.lean`, `DeterministicBridge.lean`, `Correspondence/*`, `PlusLanguage/*`,
  `MinusLanguage/*`, `StarLanguage/*`, and the `Semantics.lean` root. The renames are:
  `ConvexHistory F` becomes `PartialHistory F`, `ConvexHistory.<lemma>` becomes
  `PartialHistory.<lemma>` (with `trivial` becoming `trivialFrameHistory`), and
  `import FormalSystem.Semantics.ConvexHistory` becomes `import FormalSystem.Semantics.PartialHistory`.
- [ ] Hand-review each diff so that prose describing the convex tier is not mangled. Fix
  docstrings that name `ConvexHistory` as a type; the deeper prose sweep is Phase 7.
- [ ] Re-establish the `TruthAt` box clause as `∀ σ : PartialHistory F, σ.IsTotal → …`, and keep
  the atom clause unchanged.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: About 25 files under `FormalSystem/Semantics/` still mention
`ConvexHistory` after Phase 2. Confirm with
`grep -rl ConvexHistory FormalSystem/Semantics FormalSystem/Semantics.lean`.

**Files to modify**:
- `FormalSystem/Semantics/**/*.lean` (except `ConvexHistory.lean`, which is the shim)
- `FormalSystem/Semantics.lean`

**Verification**:
- `grep -rl ConvexHistory FormalSystem/Semantics | grep -v ConvexHistory.lean` is empty.
- A full `lake build` is green.

---

### Phase 4: Rename in Metalogic (Decidability, Deterministic, soundness layer) and Automation [NOT STARTED]

**Goal**: Retarget the first half of `Metalogic/`, plus `Automation/`.

**Tasks**:
- [ ] Apply the same renames in `Metalogic/Decidability/**` (BiLasso, Verified/Bridge,
  Propositional, CountermodelExtraction, IntPresentation), `Metalogic/Deterministic/*`,
  `Metalogic/Soundness.lean`, `SoundnessLemmas/FrameClassVariants.lean`, `SetConsequence.lean`,
  `StrongCompleteness.lean`, `DedekindNonCompactness.lean`, `DiscreteNonCompactness.lean`, and
  `Automation/PrefilterSoundness.lean`.
- [ ] Confirm that `trivial_truth_iff` (`Decidability/Propositional/Decidable.lean`) still closes
  by `simp`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: 17 Decidability + 3 Deterministic + 6 top-level/soundness + 1 Automation
= 27 files. Confirm with `grep -rl ConvexHistory` over those paths.

**Files to modify**:
- The Metalogic/Automation files listed above

**Verification**:
- `grep -rl ConvexHistory` over those paths is empty.
- A full `lake build` is green.

---

### Phase 5: Rename in Metalogic (Independence, Conservativity, BXCanonical, WeakCanonical, Algebraic) [NOT STARTED]

**Goal**: Retarget the rest of `Metalogic/`.

**Tasks**:
- [ ] Apply the same renames in `Metalogic/Independence/**` (including the `CTruthAt` relation in
  `CoarsenedModels.lean`), `Metalogic/Conservativity/**`, `Metalogic/BXCanonical/**`,
  `Metalogic/WeakCanonical/**`, and `Metalogic/Algebraic/FlowFrame.lean`.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 13 Independence + 8 Conservativity + 6 BXCanonical + 2 WeakCanonical + 1
Algebraic = 30 files. Confirm with `grep -rl ConvexHistory FormalSystem/Metalogic`.

**Files to modify**:
- The Metalogic files listed above

**Verification**:
- `grep -rl ConvexHistory FormalSystem/Metalogic` is empty.
- A full `lake build` is green.

---

### Phase 6: Examples, Tests, and shim deletion [NOT STARTED]

**Goal**: Finish the Lean migration and delete `ConvexHistory.lean`.

**Tasks**:
- [ ] Rename in `FormalSystem/Examples/TemporalStructures.lean`,
  `Tests/BimodalTest/Semantics/TruthTest.lean` (`testHistory := PartialHistory.trivialFrameHistory`,
  and the `simp [...]` lists), and `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`.
- [ ] Delete `FormalSystem/Semantics/ConvexHistory.lean` and its `Semantics.lean` import. Check
  for any `lakefile`/module-list or `check-module-invariants.sh` entry naming the module.
- [ ] Run a final sweep: `grep -rn "ConvexHistory" FormalSystem Tests --include=*.lean | grep -v
  Boneyard` should return only prose/docstring mentions, which are handed to Phase 7.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Examples/TemporalStructures.lean`, `Tests/BimodalTest/Semantics/TruthTest.lean`,
  `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, `FormalSystem/Semantics.lean`
- `FormalSystem/Semantics/ConvexHistory.lean` (deleted)

**Verification**:
- A full `lake build` and the test target build are green.
- The `sorry` count and the axiom profile of `PartialHistory.extension` and the soundness
  theorems match the Phase 1 baseline.
- No `ConvexHistory` identifier remains in code (docstrings excepted until Phase 7).

---

### Phase 7: Docstrings, docs, and decision record [NOT STARTED]

**Goal**: Make all prose describe the new layer.

**Tasks**:
- [ ] Module docstrings: rewrite the `PartialHistory.lean` module docstring for the tiers
  (partial history, convex as a predicate, world history = total partial history, H_F). Also
  update `PartialHistoryOrder.lean`, `Extension.lean` (the `extension` proof recipe no longer has
  a convexity step), and the `TaskFrame.lean` and `DiscreteNonCompactness.lean` docstrings that
  cite `universalNatFrame`. Fix every remaining Lean docstring mention of `ConvexHistory`.
- [ ] `docs/**` (14 files mention `ConvexHistory`, among them `ARCHITECTURE.md`,
  `reference/API_REFERENCE.md`, `theorem-index.md`, and `user-guide/*`): update names and the
  layer description.
- [ ] `docs/architecture/total-history-validity-decisions.md`: add Decision B', which supersedes
  Decision B's `extends` layering. Convexity is a predicate, H_F is a subtype of `PartialHistory`,
  and the rationale is that no proof uses convexity. Note that Decision A is retained, and name
  full bundling as the deferred alternative.
- [ ] `docs/reference/paper-definitions-of-record.md`: add a note that the body of
  sec:Construction ("partial history … total") and the appendix `def:world-history` ("convex
  history … total") denote the same set, and that the Lean definition follows the body.
- [ ] Do not cite task numbers in any of these files.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: 14 docs files plus about 10 Lean docstrings. Confirm with
`grep -rl ConvexHistory docs FormalSystem Tests | grep -v Boneyard`.

**Files to modify**:
- `docs/**/*.md` (those that mention it), `docs/architecture/total-history-validity-decisions.md`,
  `docs/reference/paper-definitions-of-record.md`, and Lean module docstrings

**Verification**:
- `grep -rn ConvexHistory docs FormalSystem Tests | grep -v Boneyard` returns only deliberate
  historical mentions in the decision record.
- `bash .claude/scripts/check-task-references.sh` is clean for the edited files.
- `scripts/check-paper-definitions.sh` failure count is still 16 (no new drift).
- A full `lake build` is green (final gate, since docstrings were touched).

---

### Phase 8: Talk slide update [NOT STARTED]

**Goal**: Make the slide "Semantics in Lean II: Histories and Models" quote the new definitions
verbatim.

**Tasks**:
- [ ] In `~/Philosophy/Papers/PossibleWorlds/talks/57_possible_worlds_tense_modal/slides.md`
  (about lines 1556-1630): replace the `structure ConvexHistory … extends PartialHistory` block
  and its `IsTotal` wrapper with `def IsTotal (τ : PartialHistory F) : Prop := ∀ t, τ.domain t`.
  Optionally add a one-line `IsConvex` predicate.
- [ ] Change `TaskFrame.HF` to `{τ : PartialHistory F // τ.IsTotal}`.
- [ ] Retarget the `TruthAt` signature (about line 1673), the box clause (about line 1741), and
  the history binder at about line 1836 to `PartialHistory F`.
- [ ] Change the gloss to "World history: a partial history with X = D".
- [ ] Copy each quoted snippet from the final Lean source (post-Phase 6) rather than retyping it.
- [ ] Commit in the PossibleWorlds repo, staging only `slides.md`. That repo has unrelated dirty
  files, so never use `git add -A`.

**Timing**: 0.75 hours

**Depends on**: 6

**Verification Tier**: prose

**Files to modify**:
- `~/Philosophy/Papers/PossibleWorlds/talks/57_possible_worlds_tense_modal/slides.md`

**Verification**:
- `grep -n ConvexHistory slides.md` is empty.
- Each quoted Lean snippet matches `FormalSystem/Semantics/PartialHistory.lean` and `Truth.lean`
  by diff read-through.
- Optionally, the slide deck builds if its toolchain is available.

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.PartialHistoryOrder

namespace FormalSystem.Semantics.PartialHistory

theorem isTotal_timeShift {F : TaskFrame} {τ : PartialHistory F} (h : τ.IsTotal)
    (Δ : F.Duration) : (τ.timeShift Δ).IsTotal := sorry

end FormalSystem.Semantics.PartialHistory
```

(Only this statement is pinned. It typechecks against the tree both before and after the
refactor. The other key restatement, `extension : ∃ σ : F.HF, Extends σ.val τ`, depends on the
re-based `HF` and cannot typecheck before Phase 2. Phase 2 verifies it instead.)

## Testing & Validation

- [ ] Full `lake build` green at the close of every Lean phase (1-6) and after Phase 7.
- [ ] Test suite (`Tests/BimodalTest`) builds, including `TruthTest.lean` and
  `ValidityLayerTest.lean`.
- [ ] `sorry` count and axiom profiles (`lean_verify` on `PartialHistory.extension`,
  `PartialHistory.occurrence`, and the soundness theorems) are unchanged from the Phase 1 baseline.
- [ ] `grep -rn ConvexHistory FormalSystem Tests --include=*.lean | grep -v Boneyard` is empty.
- [ ] `check-paper-definitions.sh` shows no new failures beyond the pre-existing 16, and
  `check-task-references.sh` is clean.
- [ ] The slide's quoted definitions match the source.

## Artifacts & Outputs

- `specs/599_unify_total_histories_partial/plans/01_unify-total-histories-partial.md` (this plan)
- Modified: `FormalSystem/Semantics/PartialHistory.lean`, `PartialHistoryOrder.lean`,
  `Extension/*.lean`, `IntTransfer.lean`, and about 85 consumer Lean files
- Deleted: `FormalSystem/Semantics/ConvexHistory.lean`
- Updated docs: `docs/**`, including the Decision B' record and a paper-definitions note
- Updated slide: `talks/57_possible_worlds_tense_modal/slides.md` (PossibleWorlds repo)
- `specs/599_unify_total_histories_partial/summaries/01_unify-total-histories-partial-summary.md`

## Rollback/Contingency

- Each phase closes on a green commit, so a failed phase is abandoned by reverting to the
  previous phase commit. For a genuine working-tree rollback, follow
  `.claude/context/contracts/recovery.md`'s rollback rung, which covers snapshot first and its
  out-of-scope override for whole-tree rollbacks.
- **Shim fallback**: if the Phase 2 probe shows the abbrev/alias shim cannot carry the tree, merge
  Phases 2-6 into a single `atomic-batch` sweep: flip the core, run a scripted
  `ConvexHistory` to `PartialHistory` rename over all live Lean files, hand-fix the residual
  `convex :=`/`mk`/`toPartialHistory`/`trivial` sites, and iterate to green before one commit.
  Split that sweep by directory into multiple dispatches if it overruns one agent run.
- If any proof resists retargeting beyond a mechanical fix, keep that file on the shim, finish
  the rest, and report the residue with the exact errors rather than introducing a `sorry`.
