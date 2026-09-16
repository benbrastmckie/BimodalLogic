# Implementation Plan: Task #602

- **Task**: 602 - Bundle semantics over WorldHistory
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours
- **Dependencies**: None (coordinate with task 601: whichever lands second rebases)
- **Research Inputs**: specs/602_bundle_semantics_over_worldhistory/reports/01_bundle-semantics-worldhistory.md
- **Artifacts**: plans/01_bundle-semantics-worldhistory.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace `TaskFrame.HF` with `def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}`
(in `FormalSystem/Semantics/PartialHistory.lean`) with a `state`/`timeShift`/`ofTotal` API, then
retarget `TruthAt`, `MinusTruthAt`, `PlusTruthAt`, `StarTruthAt`, `CTruthAt`, `ToyTruthAt` and every
validity/consequence/satisfiability predicate to evaluate at and quantify over `WorldHistory F`.
The atom clause becomes `M.valuation (τ.state t) p`, box becomes `∀ σ : WorldHistory F, …`, stab
becomes `∀ σ : WorldHistory F, τ.state t = σ.state t → …`; `SameStateAt`, `FrameOver.HF`,
`StabClause.sameState` and the `_total` adapter family are deleted. Only the first phase is
independently green; once `TruthAt`'s parameter type moves, every consumer breaks at once, so
Phases 2-9 form one declared atomic batch (on a task branch, durable `--no-revert` snapshots at
phase ends, one green commit at Phase 9). Docs and Decision A' land as a final green phase.
Definition of done: zero `sorry`, C2/C14 axiom baselines unchanged, `lake build` and
`scripts/check-module-invariants.sh` green, acceptance greps empty outside Boneyard.

### Research Integration

The report (01_bundle-semantics-worldhistory.md) established: (a) no consumer evaluates truth at a
genuinely non-total history (audit table covers TruthTransport, TimeShift, TruthIso, IntTransfer,
Extension, DeterministicBridge, canonical/chronicle countermodels, the decidability bridge, BiLasso,
MinusLanguage, Plus/Star pasting, FwdRecPeriodicity, CoarsenedModels) so no obstruction exists;
(b) prototypes of the new `TruthAt`, `box_iff` (`Iff.rfl`), `timeShift_state`/`ofTotal_state`
(`rfl`), bundled `TruthCorr`/`shiftCorr`/`timeShift_preserves_truth` compile with axioms
`[propext, Quot.sound]` (baseline); (c) `thm:extension`/`cor:occurrence` typecheck unchanged;
(d) `WorldHistory G` for `G : FrameOver D` elaborates through the existing coercion; (e) the
bridge-lemma disposition list (delete / collapse / retype) and migration idioms. The plan adopts
the report's layered execution order, splitting its large "batch C" by directory.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- A single named type of world histories with a non-dependent state accessor and simp API, no alias of the old name left behind.
- Every truth relation evaluates at a world history; every quantifier over histories in truth, validity, consequence and satisfiability ranges over world histories.
- The atom clause carries no domain conjunct and the agreement relation for stability is a plain state equation.
- Bridge lemmas that become unused are deleted; zero transitional lemmas survive if possible.
- Decision A' recorded, docstrings/docs/typst updated, talk-slide names re-checked.
- Lean challenge identifiers: `FormalSystem.Semantics.WorldHistory.states_eq_state`, `FormalSystem.Semantics.WorldHistory.ofTotal_state`, `FormalSystem.Semantics.WorldHistory.timeShift_state`, `FormalSystem.Semantics.Truth.atom_iff`, `FormalSystem.Semantics.Truth.box_iff`, `FormalSystem.Semantics.TimeShift.timeShift_preserves_truth`

**Non-Goals**:
- Changing `PartialHistory`, `Extends`, the Extension-machinery objects, or `MinusFrameTruth` (a non-`TaskFrame` semantics).
- Introducing any parallel partial-history truth relation or compatibility shim.
- Touching `FormalSystem/Boneyard/`.
- Editing the PossibleWorlds talk slides (outside this repository); they are re-checked and mismatches reported only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Long red window (Phases 2-9) across multiple agent runs | H | H | Task branch `task-602-worldhistory`; `git-snapshot.sh 602 --no-revert` at every phase end; per-module targeted `lake build FormalSystem.X.Y` in import order; progress file records the last module that builds |
| Axiom drift (C2/C14) from proofs that now close via `simp` | H | M | Prefer `Iff.rfl`/`rw`/`exact` in clause lemmas (TruthClauses "Classical discipline"); compare `#print axioms` of C2 flagships and C14 subjects in Phase 9 before committing |
| Simp normal form leaves `τ.val.states t _` terms | M | M | `@[simp] WorldHistory.states_eq_state` rewrites toward `state`; never make `state` simp-unfoldable; keep `WorldHistory` a `def` not `abbrev` |
| Hidden consumer truly needs truth at a partial history (contradicting the research audit) | H | L | Stop and report the concrete site in the phase record; do not introduce a parallel relation |
| Scope larger than hypothesised (136 files mention a truth relation or history pattern) | M | M | Each phase's Scope Hypothesis is confirmed by grep at phase start; overflow is carried as `[PARTIAL]` within the batch rather than widened ad hoc |
| Conflict with task 601 (TaskFrame.lean, frame constructions) | M | M | Whichever lands second rebases; construction-site conflicts are local (`WorldHistory.ofTotal`) |
| Set equalities over `{σ | ∀ t, σ.domain t}` (ReynoldsBridge, ChronicleMonadicBridge) | L | H | Restate as surjectivity / `Set.univ = Set.range …` over `WorldHistory` |
| Docs lint pre-existing failures (`check-paper-definitions.sh`) | L | H | Compare against pre-change baseline output; only new failures block |

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

Phases within the same wave can execute in parallel. The chain is fully sequential: Phases 2-9
share one red working tree and one build, so they are not parallel-safe.

### Phase 1: WorldHistory type, API, and HF rename [COMPLETED]

**Goal**: Introduce `WorldHistory` and its API in place of `TaskFrame.HF`, migrate every `HF` user, keep the tree green, commit.

**Tasks**:
- [x] Record pre-change baselines: `#print axioms` output for C2 flagships and C14 subjects (run `scripts/check-module-invariants.sh` once, save output under the task dir scratch area), and `check-paper-definitions.sh` output
- [ ] Create task branch `task-602-worldhistory` from main *(deviation: skipped — no concurrent work in the tree; the batch stays uncommitted on main with `--no-revert` snapshots and lands as one green commit)*
- [x] In `FormalSystem/Semantics/PartialHistory.lean`: replace `def TaskFrame.HF` with `def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}`; namespace `WorldHistory` with `CoeOut` to `PartialHistory F`, `state`, `@[simp] states_eq_state`, `@[ext] ext`, `ofTotal`, `@[simp] ofTotal_state`, `ofTotal_val` (keep only if used), `timeShift`, `@[simp] timeShift_state`, `timeShift_val` (keep only if used), `state_congr`
- [x] Delete `FrameOver.HF` and its `example`
- [x] Migrate all `HF` users (`F.HF` -> `WorldHistory F`, `TaskFrame.HF.ofTotal` -> `WorldHistory.ofTotal`, `toHF` -> `toWorldHistory`, `HFofStepPath` renamed to a `WorldHistory`-based name) without yet changing any truth relation's parameter type
- [x] `lake build` (detached, guarded) green; commit `task 602 phase 1: introduce WorldHistory and retire TaskFrame.HF`

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: `\bHF\b` / `toHF` / `FrameOver.HF` users are the ~21 files found by `grep -rlE "\bHF\b" --include=*.lean FormalSystem Tests` (Compactness, Semantics.lean, CoNotPriorU, BiLasso/{Basic,Extend,Realized}, ValidityLayer, PeriodicExtension, IntNormalForm, Correspondence/{DurationFrames,FwdRec,FwdRecBridge}, Minus/Star/PlusValidity, DeterministicBridge, Validity, Extension/Extension, TruthTransport, ShiftSet, PartialHistory). Confirm by re-running the grep plus `grep -rn "toHF\|HFof"` at phase start.

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean` - new type and API, HF section removed
- the HF-user files listed in the Scope Hypothesis - rename uses

**Verification**:
- `lake build` exits 0; `grep -rnE "\bHF\b|toHF|FrameOver\.HF" --include=*.lean FormalSystem Tests | grep -v Boneyard` returns nothing (a renamed `HFofStepPath` included)
- `WorldHistory.timeShift_state`, `ofTotal_state`, `states_eq_state` proved by `rfl`

---

### Phase 2: Atomic batch A1 - truth core [NOT STARTED]

**Goal**: Retarget the abstract clause layers and the base truth relation to `WorldHistory F`, and transport.

**Tasks**:
- [ ] `TruthClauses.lean`: `TruthEnv.T` over `WorldHistory F`; delete `StabClause.sameState`, state `stab_clause` with `τ.state t = σ.state t`; box/diamond/stab lemmas quantify `∀ σ : WorldHistory F`
- [ ] `ValidityLayer.lean`: `PointTruth.sat` over `WorldHistory F`; generic validity quantifies over `WorldHistory F`; collapse/delete `of_forall_total`/`apply_total`/`of_not` generics (keep one renamed `apply`/`of_forall` pair only if a later call site benefits)
- [ ] `Truth.lean`: `TruthAt (M) (τ : WorldHistory F) (t)` with atom `M.valuation (τ.state t) p`, box `∀ σ : WorldHistory F`; `atom_iff_of_domain` -> `atom_iff` (`Iff.rfl`); delete `atom_false_of_not_domain`; `box_iff` over `WorldHistory`; drop `_hτ`/`_hσ` from `box_const`/`box_time_const`
- [ ] `TruthTransport.lean`: `TruthCorr.Rel` over `WorldHistory`, non-dependent `atom`, `fwd`/`bwd` without `IsTotal`; `ShiftRel Δ ρ ρ' := ∀ z, ρ.state z = ρ'.state (z + Δ)`; `shiftCorr`; `timeShift_preserves_truth (σ : WorldHistory F)`; delete `timeShift_preserves_truth_total` and the domain half of `shiftRel_timeShift_neg`; `TruthIso.hist : WorldHistory F ≃ WorldHistory F'`
- [ ] Targeted builds in import order: `lake build FormalSystem.Semantics.TruthClauses`, `.ValidityLayer`, `.Truth`, `.TruthTransport`
- [ ] End of phase: `bash .claude/scripts/git-snapshot.sh 602 --no-revert`; record last green module in progress file

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 4 files (TruthClauses, ValidityLayer, Truth, TruthTransport). Confirm with `lake build` of each module; any additional module required to build them is added here and noted.

**Files to modify**:
- `FormalSystem/Semantics/TruthClauses.lean`, `ValidityLayer.lean`, `Truth.lean`, `TruthTransport.lean`

**Verification**:
- The four targeted module builds succeed with no `sorry`
- `#print axioms FormalSystem.Semantics.TimeShift.timeShift_preserves_truth` = `[propext, Quot.sound]`

---

### Phase 3: Atomic batch A2 - validity and frame-level semantics [NOT STARTED]

**Goal**: Retarget validity predicates and the remaining Semantics-level consumers.

**Tasks**:
- [ ] `Validity.lean`: `Valid`, `ValidIn`, `ValidOnFrames`, `ConsequenceOnFrames`, `SemanticConsequence(In)`, `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable`, `TaskFrame.ValidOn`, `GenericValidOn` quantify `∀ τ : WorldHistory F`; collapse `validOn_iff_total`/`valid_iff_forall_validOn`; delete or rename (no `_total` suffix) the `of_forall_total`/`apply_total`/`of_not` adapters per remaining callers
- [ ] `IntTransfer.lean`: add `WorldHistory.map`/`comap`; `Aligned` as `∀ n, σ'.state n = σ.state (e.symm n)`; `truthAt_map`, `validZTime_iff_validInt`
- [ ] `IntNormalForm.lean`, `ShiftSet.lean`, `DeterministicBridge.lean` (`SingletonClasses` over `WorldHistory`), `FrameAxioms.lean`, `PartialHistoryOrder.lean` (only if affected), `Extension/{Extension,PeriodicExtension,Admissible,Constraint}.lean` (restate `extension`/`occurrence` conclusions over `WorldHistory`; `Extends` stays on `PartialHistory`), `Correspondence/{DurationFrames,FwdRec,FwdRecBridge,FwdRecPeriodicity}.lean`, `Ultraproduct/*`, frame-class validity module
- [ ] Targeted builds in import order for each touched module
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~18 Semantics files outside the three language directories (listed above). Confirm with `grep -rlE "IsTotal|SameStateAt|TruthAt|\.states t" FormalSystem/Semantics --include=*.lean | grep -vE "MinusLanguage|PlusLanguage|StarLanguage"` minus files already done in Phase 2; Extension/Constraint and Admissible may need no change (they mention `states` on raw partial histories) - confirm by build.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`, `IntTransfer.lean`, `IntNormalForm.lean`, `ShiftSet.lean`, `DeterministicBridge.lean`, `FrameAxioms.lean`, `Extension/*.lean`, `Correspondence/*.lean`, `Ultraproduct/*.lean` - retarget

**Verification**:
- Targeted builds succeed for every touched Semantics module outside the language directories
- `grep -nE "\.IsTotal *(→|∧)" ` over these files returns nothing

---

### Phase 4: Atomic batch B1 - Minus and Plus languages [NOT STARTED]

**Goal**: Retarget `MinusTruthAt`, `PlusTruthAt` and their validity/pasting/state-local layers; delete `SameStateAt`.

**Tasks**:
- [ ] `MinusLanguage/MinusTruth.lean` (atom conjunct removed), `MinusValidity.lean`, remaining MinusLanguage files; `minusTruthAt_timeShift`
- [ ] `PlusLanguage/PlusTruth.lean`: stab `∀ σ : WorldHistory F, τ.state t = σ.state t → …`; delete `SameStateAt` and its API (`sameStateAt_iff_of_total`, `.refl/.symm/.trans`, `sameStateAt_timeShift`, `sameStateAt_congr_left`), `timeShift_isTotal'`, `shift_neg_shift_domain`, `shift_neg_shift_states`; `stab_congr_sameState` -> `stab_congr_state`
- [ ] `PlusPasting.lean`: `WorldHistory.paste (ρ σ : WorldHistory F) (t) (hsame : ρ.state t = σ.state t)`; `PlusValidity`, `PlusStateLocal`, `PlusDeterminism`, `PlusNonValidities`, `Semantics/PlusLanguage.lean` aggregator docstring
- [ ] Targeted builds in import order
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~12 files (5 MinusLanguage, 7 PlusLanguage including aggregator). Confirm with `ls` of both directories intersected with the pattern grep.

**Files to modify**:
- `FormalSystem/Semantics/MinusLanguage/*.lean`, `FormalSystem/Semantics/PlusLanguage/*.lean`, `FormalSystem/Semantics/PlusLanguage.lean`

**Verification**:
- Targeted builds of every Minus/Plus module succeed
- `grep -rn "SameStateAt" FormalSystem/Semantics/MinusLanguage FormalSystem/Semantics/PlusLanguage` returns nothing

---

### Phase 5: Atomic batch B2 - Star language and Conservativity [NOT STARTED]

**Goal**: Retarget `StarTruthAt` layers and the Conservativity consumers of all three languages.

**Tasks**:
- [ ] `StarLanguage/{StarTruth,StarValidity,StarStateLocal,StarDeterminism,StarNonValidities}.lean` and remaining Star files
- [ ] `Metalogic/Conservativity/MinusLanguageSoundness.lean` (`truthAt_tr` over `WorldHistory`), `Plus/{Atomization,PlusSoundness}`, `Star/{StarAxiomValidity,StarPasting}`, `ChainBundleTruth`, `DenseObstructionTransfer`, `FragmentCompactness`, `SpWitness`, `Z1Countermodel`, `Conservativity.lean`
- [ ] Targeted builds in import order
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~6 StarLanguage files and ~12 Conservativity files. Confirm with the pattern grep over both directories.

**Files to modify**:
- `FormalSystem/Semantics/StarLanguage/*.lean`, `FormalSystem/Metalogic/Conservativity/**/*.lean`

**Verification**:
- Targeted builds of every Star and Conservativity module succeed

---

### Phase 6: Atomic batch C1 - soundness, canonical and countermodel consumers [NOT STARTED]

**Goal**: Retarget soundness-family, deterministic, compactness and canonical-model consumers.

**Tasks**:
- [ ] `Metalogic/Soundness.lean`, `SoundnessLemmas.lean`, `SoundnessLemmas/{CoValidity,DiscreteOrder,FrameClassVariants}`, `SetConsequence.lean`, `StrongCompleteness.lean`, `Compactness.lean`, `DedekindNonCompactness.lean`, `DiscreteNonCompactness.lean`, `Metalogic.lean` docstring
- [ ] `Metalogic/Deterministic/{Erasure,Soundness,Validity}`
- [ ] `WeakCanonical/{GroupModel/CountermodelBase,IntegerModel/ReynoldsBridge,Table}` (set equality at ReynoldsBridge restated as surjectivity / `Set.univ = Set.range`), `BXCanonical/{Chronicle/*,Completeness,CompletenessDedekind,DiscreteCarrierProbe,TruthLemma}` (ChronicleMonadicBridge set equality likewise), `Algebraic/FlowFrame` (histories as `WorldHistory.ofTotal` or `⟨rec, fun _ => trivial⟩`)
- [ ] Targeted builds in import order
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~25 files across Soundness*, Deterministic, Compactness, WeakCanonical, BXCanonical, Algebraic. Confirm with the pattern grep per directory; files that mention `TruthAt` only through already-retargeted lemmas may need no edit (confirm by build, not by grep).

**Files to modify**:
- files listed in Tasks - retarget binders, constructions and set equalities

**Verification**:
- Targeted builds of every listed module succeed

---

### Phase 7: Atomic batch C2 - Independence countermodels [NOT STARTED]

**Goal**: Retarget the Independence countermodels, including the separate coarse truth relation `CTruthAt`.

**Tasks**:
- [ ] `Independence/CoarsenedModels.lean`: `CTruthAt` over `WorldHistory` (retargeted on its own, not a `TruthClauses` instance)
- [ ] `Independence/{StaticFrame,OrderTransfer,CoNotPriorU,DeterminismUndefinable,LoopingDuration,StabUndefinable,PastingIndependence,RealTranslationFrame,ForwardDeterministicFrame,DriftHistories,StateSetTruth,StarDiscrimination,ClockFrame,LexIntWitness}`
- [ ] Targeted builds in import order
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~15 Independence files (~180 pattern lines; heaviest CoNotPriorU, CoarsenedModels, OrderTransfer). Confirm with `grep -rlE "IsTotal|SameStateAt|TruthAt|\.states t" FormalSystem/Metalogic/Independence`.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/*.lean`

**Verification**:
- Targeted builds of every Independence module succeed

---

### Phase 8: Atomic batch C3 - Decidability stack [NOT STARTED]

**Goal**: Retarget BiLasso, the verified decidability bridge and the remaining Decidability modules.

**Tasks**:
- [ ] `Decidability/BiLasso/*` (`hist A := A.lasso.toWorldHistory`, no `.val`)
- [ ] `Verified/Bridge/{RegionFrame,Interpolate,TruthLemma}`: `regionHistory : WorldHistory _`; `isTotal_iff_regionHistory` restated as `∀ σ : WorldHistory F, ∃ w Δ, σ = regionHistory f w Δ` (via `Subtype.ext` on the existing proof); `RegionConstant` retyped
- [ ] `Verified/Decidable.lean`, `CountermodelExtraction`, `FMP`, `IntPresentation`, `Propositional`, `Tableau`, `Decidability.lean`
- [ ] Targeted builds in import order (BiLasso, then Verified/Bridge, then Verified/Decidable)
- [ ] End of phase: `git-snapshot.sh 602 --no-revert`; progress file updated

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~29 Decidability files (13 BiLasso, 10 Verified, 6 others), many touching only `TruthAt` through retargeted lemmas. Confirm with the pattern grep and by build.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/**/*.lean`, `FormalSystem/Metalogic/Decidability.lean`

**Verification**:
- Targeted builds of every Decidability module succeed

---

### Phase 9: Close the batch - Automation, Tests, dead-lemma sweep, full gate, commit [NOT STARTED]

**Goal**: Finish remaining consumers, delete unused bridge lemmas, pass the full gate set, and land the batch as one green commit.

**Tasks**:
- [ ] `Automation/{PrefilterSoundness,TruthNormAttr}`, `FormalSystem/Examples/*`, `FormalSystem/Semantics.lean` code (docstring deferred to Phase 9), `Syntax/PlusLanguage.lean` if affected, `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` (`ToyTruthAt`), `Tests/BimodalTest/*Probe.lean`
- [ ] Dead-lemma sweep: for each surviving transitional/adapter lemma (`WorldHistory.mk_state`, `ofTotal_val`, `timeShift_val`, renamed `apply`/`of_forall` adapters, `state_congr`), check references (`lean_references` or grep); delete any with zero callers
- [ ] Full `lake build` (detached, guarded) exits 0, including `BimodalTest`
- [ ] `scripts/check-module-invariants.sh` passes (C2/C14 axiom baselines unchanged vs. Phase 1 record; C3 zero sorry). Any documented-count drift in docstrings is fixed here only if C14 requires it to go green
- [ ] Acceptance greps (outside Boneyard) all empty: `grep -rnE "\.IsTotal *(→|∧)" --include=*.lean FormalSystem Tests`, `grep -rn "∃ (ht : τ.domain t)" --include=*.lean FormalSystem Tests`, `grep -rnwE "HF|SameStateAt" --include=*.lean FormalSystem Tests`
- [ ] Single commit of Phases 2-9 on the task branch: `task 602 phase 9: retarget semantics over WorldHistory`; fast-forward/merge into main per the atomic-batch carve-out (local only, no push)

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~8 remaining files (Automation 2, Examples up to 2, Tests 4) plus whatever earlier phases left unbuilt. Confirm by the full `lake build` error list, which is the authoritative remaining-scope inventory.

**Files to modify**:
- `FormalSystem/Automation/*.lean`, `FormalSystem/Examples/*.lean`, `Tests/BimodalTest/**/*.lean`, any file with now-dead lemmas

**Verification**:
- `lake build` exit 0; `scripts/check-module-invariants.sh` exit 0; three acceptance greps empty; `grep -rn "sorry"` delta vs. baseline is zero

---

### Phase 10: Decision A', docstrings, docs, typst, slide re-check [NOT STARTED]

**Goal**: Bring all prose in line with the bundled encoding and record the decision.

**Tasks**:
- [ ] `docs/architecture/total-history-validity-decisions.md`: add Decision A' (bundled `WorldHistory`, literal atom clause, no `SameStateAt`, removal of the accepted atom-clause fidelity gap); mark Decision A and B''s "deferred alternative" superseded
- [ ] `FormalSystem/Semantics/PartialHistory.lean` module docstring: rewrite paper/Lean table (`H_F` -> `WorldHistory F`, possible world -> `τ : WorldHistory F`), delete the "no `abbrev WorldHistory`" note
- [ ] `FormalSystem/Semantics/Truth.lean` docstring ("ProofChecker Implementation Alignment", simp-normal-form rows for `box_iff`/`diamond_iff`); `FormalSystem/Semantics.lean` docstring; `FormalSystem/Semantics/README.md`
- [ ] `docs/user-guide/architecture.md`, `tutorial.md`, `docs/reference/API_REFERENCE.md`, `paper-definitions-of-record.md`, `LEAN_STYLE_GUIDE.md`, `theorem-index.md`, `operators.md`, `INTEGRATION.md`, `DIRECTORY_README_STANDARD.md`, `README.md`, `typst/chapters/02-semantics.typ`
- [ ] Re-grep docs/typst for `\bHF\b|IsTotal →|SameStateAt|PartialHistory F` in signature quotes and fix remaining hits
- [ ] Re-check talk slides (`~/Philosophy/Papers/PossibleWorlds/talks/57_possible_worlds_tense_modal/slides.md`, lines ~1623-1892) against final names; do not edit (outside repo); list any mismatch in the implementation summary
- [ ] `scripts/check-module-invariants.sh` (C5/C12/C13/C14/C15) and `check-paper-definitions.sh` show no new failures vs. the Phase 1 baseline; no task-number citations in deliverables; `typst compile` of the affected document succeeds
- [ ] Commit `task 602 phase 10: record Decision A' and update docs`

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: prose

**Scope Hypothesis**: ~14 prose files per the research doc grep (architecture.md 14 hits, tutorial.md 6, API_REFERENCE.md 5, paper-definitions-of-record.md 4, LEAN_STYLE_GUIDE.md 3, theorem-index.md 2, 02-semantics.typ 2, Semantics/README.md 2, plus README/operators/INTEGRATION/DIRECTORY_README_STANDARD) and 3 Lean docstrings. Confirm by `grep -rnE "\bHF\b|IsTotal|SameStateAt|PartialHistory F" docs typst README.md FormalSystem/Semantics/README.md` at phase start.

**Files to modify**:
- files listed in Tasks - prose only

**Verification**:
- Diff read-through confirms Lean edits are inside docstrings/comments; module-invariant doc checks and full gate pass; docs grep returns only intentional historical mentions inside Decision A (superseded)

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TruthTransport

namespace FormalSystem.Semantics

theorem WorldHistory.states_eq_state {F : TaskFrame} (τ : WorldHistory F) (t : F.Duration)
    (h : τ.val.domain t) : τ.val.states t h = τ.state t := sorry

theorem WorldHistory.ofTotal_state (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) (t : F.Duration) :
    (WorldHistory.ofTotal F f h).state t = f t := sorry

theorem WorldHistory.timeShift_state {F : TaskFrame} (τ : WorldHistory F) (Δ t : F.Duration) :
    (τ.timeShift Δ).state t = τ.state (t + Δ) := sorry

theorem Truth.atom_iff {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration} (p : FormalSystem.Syntax.Atom) :
    TruthAt M τ t (FormalSystem.Syntax.Formula.atom p) ↔ M.valuation (τ.state t) p := sorry

theorem Truth.box_iff {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F}
    {t : F.Duration} (φ : FormalSystem.Syntax.Formula) :
    TruthAt M τ t φ.box ↔ ∀ σ : WorldHistory F, TruthAt M σ t φ := sorry

theorem TimeShift.timeShift_preserves_truth {F : TaskFrame} (M : TaskModel F)
    (σ : WorldHistory F) (x y : F.Duration) (φ : FormalSystem.Syntax.Formula) :
    TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ y φ := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] Phase 1: full `lake build` green before the red window opens
- [ ] Each batch phase: targeted `lake build FormalSystem.<Module>` for every touched module, in import order
- [ ] Phase 9: full `lake build` (FormalSystem + BimodalTest) exit 0
- [ ] Phase 9: `scripts/check-module-invariants.sh` exit 0, C2/C14 axiom sets identical to the Phase 1 baseline
- [ ] Zero `sorry` (C3), no new `axiom`
- [ ] Acceptance greps outside Boneyard empty: `.IsTotal →`/`.IsTotal ∧`, `∃ (ht : τ.domain t)`, `\bHF\b`, `SameStateAt`
- [ ] `#print axioms` of `timeShift_preserves_truth`, `truthAt_of_truthCorr`, `validZTime_iff_validInt` equal baseline
- [ ] Phase 10: doc-related invariant checks (C5, C12-C15) and `check-paper-definitions.sh` show no new failures

## Artifacts & Outputs

- `specs/602_bundle_semantics_over_worldhistory/plans/01_bundle-semantics-worldhistory.md` (this plan)
- Modified Lean sources under `FormalSystem/Semantics/`, `FormalSystem/Metalogic/`, `FormalSystem/Automation/`, `FormalSystem/Examples/`, `Tests/BimodalTest/`
- Updated `docs/architecture/total-history-validity-decisions.md` (Decision A'), `docs/user-guide/*`, `docs/reference/*`, `typst/chapters/02-semantics.typ`, `README.md`
- `specs/602_bundle_semantics_over_worldhistory/summaries/01_bundle-semantics-worldhistory-summary.md` (including talk-slide re-check results)

## Rollback/Contingency

- Phase 1 is an ordinary green commit; revert with `git revert` if later phases are abandoned.
- Phases 2-9 live on branch `task-602-worldhistory` with `--no-revert` snapshots at each phase end; main is untouched until Phase 9's green commit. To abandon the batch, switch back to main (the branch preserves the work). A genuine rollback of uncommitted batch work follows `context/contracts/recovery.md`'s rollback rung (snapshot first, with its out-of-scope override for the deliberate whole-tree case).
- If a consumer is found that genuinely requires truth at a non-total history, stop, mark the current phase `[BLOCKED]` with the concrete declaration and file, and report; do not add a parallel partial-history truth relation.
- If task 601 lands first, rebase the task branch onto main before Phase 9's merge and resolve `WorldHistory.ofTotal` construction-site conflicts locally.
