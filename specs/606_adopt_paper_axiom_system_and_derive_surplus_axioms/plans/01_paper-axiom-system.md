# Implementation Plan: Task #606

- **Task**: 606 - Adopt the paper axiom system and derive the surplus axioms
- **Status**: [IMPLEMENTING]
- **Effort**: 17 hours
- **Dependencies**: None
- **Research Inputs**: specs/606_adopt_paper_axiom_system_and_derive_surplus_axioms/reports/01_paper-axiom-audit.md
- **Artifacts**: plans/01_paper-axiom-system.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The goal is to make the primitive `inductive Axiom` (`FormalSystem/ProofSystem/Axioms.lean`) exactly the paper's system:
- 29 schemata: CPL as K/S/EFQ/Peirce, MK, MT, M5, the 11 BX temporal schemata, the 4 uniformity schemata, MF, DN, NN, UZ, Z1, PU and SEP.
- The rules MP, MN, TN and TR.

All 16 surplus constructors become derived definitions. That means the 12 TR past mirrors, plus `modal_4`, `modal_b`, `prior_SZ` and `prior_S_gap`. TL, CN and TS are restated in the paper's verbatim form.

The strategy is add-first, remove-last, so the build stays green until the constructor-removal phase:
1. Build the derived definitions while the constructors still exist.
2. Rewrite every construction site to use the derived definitions.
3. Delete the constructors and their dispatcher arms.
4. Restate TL, CN and TS.
5. Regenerate the machine appendix and docs, then run the full gate.

### Research Integration

The report (`reports/01_paper-axiom-audit.md`) supplies:
- **Classification**: all 45 constructors are classified. 29 are paper-primitive (4 of them restated), 16 are derivable surplus, and none is underivable. There is therefore no "surplus with no known derivation" class to report or carry.
- **Prototyped derivations**, all compiled with `lean_run_code`:
  - The TR mirror recipe: `time_reflection` on the primary at `reflectTime`d arguments, then `simpa [Formula.reflectTime, <operator defs>, Formula.reflect_time_involution]`.
  - `discrete_symm_bwd` as a bare `time_reflection` term.
  - `modal_4` and `modal_b` from K, T and 5, via `theoremFlip`, `bCombinator`, `notNotIntro`, `doubleNegation` and `impTrans`.
- **Per-frame-class check**:
  - TR is a constructor of `DerivationTree fc` for every `fc`.
  - Each mirror has the same `minFrameClass` as its primary.
  - So no frame class needs a surplus axiom. The only gated derived items are `prior_SZ` (hypothesis `ZTime ≤ fc`) and `prior_S_gap` (hypothesis `RTime ≤ fc`).
- **Blast radius**:
  - About 330 qualified `Axiom.<surplus>` sites in about 61 files.
  - 6 exhaustive dispatchers.
  - "Axiom-as-data" consumers: `plusValidIn_of_tm`, `cValid_of_tm`, `RuleSpec.ruleAxioms`, `matchAxiom`, the `modal_search` name list, `FormulaEnumerator` and `applyAxiomTo`.
- **Import-order constraint**: `Theorems/Combinators.lean`'s `temporalFutureDerived` uses `Axiom.modal_4`, but `doubleNegation` lives downstream in `Propositional/Core.lean`.

This plan adds two findings from its own reads:
- `PlusAxiom.ofTM` (`Syntax/PlusLanguage/Derivation.lean`) is `rfl`-shaped per arm. Restating TL, CN or TS in TM therefore forces a **lockstep restatement of the TM⁺ twins** (and of any Star/Det re-declaration that stays definitionally aligned). Otherwise `ofTM` stops typechecking.
- `ProofSystem/Derivation.lean:393` has an `example` built on `Axiom.modal_4`. It must change, because `Derivation.lean` precedes every derived module.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted: no `roadmap_path` in the delegation context.

## Goals & Non-Goals

**Goals**:
- The 19 derived definitions below are sorry-free and axiom-free, `{fc}`-polymorphic where their primary is Base, and gated by a frame-class hypothesis otherwise: `serial_past`, `connect_past`, `temp_linearity_past`, `since_P`, `P_since_equiv`, `absorb_since`, `right_mono_since`, `self_accum_since`, `left_mono_since_H`, `enrichment_since`, `linear_since`, `discrete_symm_bwd`, `prior_SZ`, `prior_S_gap`, `modal_4`, `modal_b`, `temp_linearity_legacy`, `linear_until_legacy`, `serial_future_imp`
- The primitive axiom type has exactly the 29 paper schemata. TL, CN and TS are stated in the paper's verbatim form, with the 3-way disjunctions right-associated.
- Every former primitive is now either a paper axiom or a proved derivation, and the axiom check confirms this on each derived definition.
- The build is green with no new sorry and no new axiom. All tests pass.
- The machine appendix, the generated Typst counts and the axiom reference doc describe the 29-schema primitive system plus its derived mirrors.
- New dataset generation records an explicit axiom-system version tag. Existing serialized datasets stay byte-stable.

**Non-Goals**:
- Removing mirror constructors from the separate TM⁺, TM⋆, Determined and TM⁻ axiom inductives. They are distinct systems, and that is a possible follow-up. Lockstep restatement of the TL, CN and TS twins that are definitionally aligned with TM is in scope.
- Renaming the NA constructor (discrete propagation backward). The decision is to keep the name, because a rename would change the machine-appendix names and dataset wire tags. Its docstring and reference row are corrected instead.
- Regenerating the hosted HF datasets.
- Editing the paper, which is read-only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mass rewrite of about 330 sites introduces churn or breaks proofs | H | M | Add first, remove last. The constructors stay live through the rewrite phases, so each file rewrite is independently green-checkable. Most sites match a regex (`DerivationTree.axiom (fc := _)? Γ _ (Axiom.X args) h` becomes the derived def, weakened to Γ). |
| `PlusAxiom.ofTM` (and any Star/Det embedding) stops typechecking once TL, CN or TS change | H | H | Restate the TM⁺ twins, and any other definitionally aligned re-declarations, in the same atomic batch. Re-prove their validity lemmas with the same disjunct permutation. |
| Tableau and RuleSpec index branches by TL disjunct order | M | M | Point them at the legacy TL definition. Do not reorder tableau branches: the Termination and SubformulaProperty proofs index them. |
| A missed exhaustive-match arm after constructor removal | L | M | This fails loudly as a compile error, so it cannot be a silent gap. The removal phase runs the full build. |
| A `simpa`-cast derived def is not reducible where height-based or computable recursion needs it | M | L | Fall back to an explicit `▸` over a proved formula equation. For `discrete_symm_bwd` no cast is needed at all. |
| Import cycle from placing `modal_4`/`modal_b` after `Propositional.Core` | M | M | Move `temporalFutureDerived` into the new modal-derived module, keeping its name and namespace. Its 9 importing files then import that module. |
| Dataset wire-format drift | M | L | Leave existing files untouched. Add an explicit axiom-system version field (e.g. `paper-29`) to generator metadata for newly generated data. |
| Concurrent lake builds in parallel phases corrupt `.lake` | M | L | The phases run strictly sequentially, one wave per phase. |

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

The phases are deliberately sequential. They all share one Lake build tree, and the call-site rewrites touch modules that import each other.

### Phase 1: TR-derived mirror module [COMPLETED]

**Goal**: Add `FormalSystem/ProofSystem/DerivedAxioms.lean`. It holds the 14 TR-derived definitions for the 12 Base mirrors plus `prior_SZ` and `prior_S_gap`, each proved by `time_reflection` from its primary. The existing constructors stay in place.

**Tasks**:
- [x] Record a baseline census of the `sorry` count and the `axiom` declaration count in `FormalSystem/` and `Tests/`, excluding Boneyard. Write it to the task's progress notes for the final comparison. *(completed: baseline = 0 non-Boneyard sorries (census total 160, all under Boneyard), 0 `axiom` declarations; baseline full `lake build` green, 2660 jobs)*
- [x] Create the module in namespace `FormalSystem.ProofSystem.DerivedAxioms`, importing only `ProofSystem.Derivation` and `Syntax.Formula`. *(deviation: altered — also imports the leaf `Automation.LemmaDB` so the defs can carry `@[tmLemma]`)*
- [x] For each mirror, write `def X {fc : FrameClass} (args) : ⊢[fc] <exact current constructor formula>`. The body applies `time_reflection` to the primary's axiom instance at `reflectTime`d arguments (with `FrameClass.base_le fc`), then `simpa [...]`, following the report's Tactic Survey.
  - `discrete_symm_bwd` is the bare term `time_reflection _ (axiom … discrete_symm_fwd …)`.
  - `prior_SZ` takes `(h : FrameClass.ZTime ≤ fc)` and `prior_S_gap` takes `(h : FrameClass.RTime ≤ fc)`. Pass `h` through as the primary's `h_fc`.
- [x] For each, add a context-lifted helper `XAt (Γ : Context) … : Γ ⊢[fc] …` via `DerivationTree.weakening [] Γ _ d (List.nil_subset Γ)`, so that non-empty-context call sites rewrite one-to-one. Tag the definitions `@[tmLemma]` where `Combinators` does the same for similar lemmas, so the lemma DB and search see them.
- [x] Re-export from `FormalSystem/ProofSystem.lean`.
- [x] Run `lean_verify` on each of the 14 defs. Expect nothing beyond `propext`, `Classical.choice` and `Quot.sound`. *(completed: all 14 depend on `[propext]` only; each def's type checked equal to its constructor's index)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 14 definitions with statements byte-identical to the current constructors. Confirm by `#check`-comparing each def's type against `Axiom.X`'s index. A `example : <def type> = <constructor index> := rfl` per mirror, or a successful build of the phase 3 rewrites, is sufficient.

**Files to modify**:
- `FormalSystem/ProofSystem/DerivedAxioms.lean`: new
- `FormalSystem/ProofSystem.lean`: add the import

**Verification**:
- `lake build FormalSystem.ProofSystem.DerivedAxioms` is green, and `lean_verify` is clean on all 14.

---

### Phase 2: Derived modal_4, modal_b and the TF relocation [COMPLETED]

**Goal**: Derive `modal_4` and `modal_b` from MK, MT and M5 in a module placed after `Propositional.Core`, and remove every pre-`Propositional` use of `Axiom.modal_4`.

**Tasks**:
- [x] Create `FormalSystem/Theorems/ModalPrimitiveDerived.lean` (namespace `FormalSystem.ProofSystem.DerivedAxioms`), importing `Theorems.Propositional.Core`. *(deviation: altered — no new module; `modal_b`/`modal_4` (+`…At`) are declared in namespace `FormalSystem.ProofSystem.DerivedAxioms` inside `Theorems/Combinators.lean`, using a local EFQ+Peirce double-negation elimination, so there is no dependency on `Propositional.Core` and no import cycle)*
  - `modal_b {fc} (φ) : ⊢[fc] φ.imp (Formula.box φ.diamond)`: contrapose MT at `¬φ` with DNI to get `φ → ◇φ`; contrapose M5 at `¬φ` with `doubleNegation` to get `◇φ → □◇φ`; then `impTrans`.
  - `modal_4 {fc} (φ)`: B at `□φ` gives `□φ → □◇□φ`; MN of M5 plus MK gives `□◇□φ → □□φ`; then `impTrans`.
  - Add the `…At Γ` helpers as in phase 1.
- [x] Move `temporalFutureDerived` from `Theorems/Combinators.lean` into this module, keeping the same name and namespace and the `@[tmLemma]` attribute. It now uses the derived `modal_4`. *(deviation: skipped — relocation unnecessary; `temporalFutureDerived` stays in `Combinators.lean` (moved below the derived S5 block) and consumers need no import changes)*
  - Add the new import to each of its consumers that does not already reach this module transitively: `BXCanonical/CanonicalModel.lean`, `BXCanonical/Frame.lean`, `Chronicle/ChronicleToCountermodelBasic.lean`, `Algebraic/FlowFrame.lean`, `Bundle/RealExtensionBundle.lean`, `Perpetuity/Principles.lean`, `Automation/FormulaEnumerator.lean`, `Automation/ProofSearch/Core.lean` and `Syntax/MinusLanguage/Axioms.lean`.
  - If any consumer sits upstream of `Propositional.Core` and so creates a cycle, stop and restructure that consumer's use instead. Do not reintroduce a primitive.
- [x] Replace the `Derivation.lean:393` example ("Modal 4 axiom is a theorem") with an equivalent example over a remaining primitive, or delete it. Its point is served by the new module.
- [x] Add the module to the `FormalSystem/Theorems.lean` aggregator, if one exists, and run `lean_verify` on `modal_4` and `modal_b`. *(aggregator step not applicable, no new module)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: `temporalFutureDerived` has 9 consumer files outside `Combinators.lean`. Confirm with `grep -rln temporalFutureDerived FormalSystem Tests` before editing imports.

**Files to modify**:
- `FormalSystem/Theorems/ModalPrimitiveDerived.lean`: new
- `FormalSystem/Theorems/Combinators.lean`: remove `temporalFutureDerived`
- `FormalSystem/ProofSystem/Derivation.lean`: the example
- The `temporalFutureDerived` consumer files listed above: imports only

**Verification**:
- The new module and every consumer build green.
- `grep -rn "Axiom.modal_4\|Axiom.modal_b" FormalSystem/Theorems/Combinators.lean FormalSystem/ProofSystem/Derivation.lean` is empty.

---

### Phase 3: Rewrite call sites in Theorems and Metalogic proof code [IN PROGRESS]

**Goal**: Replace every `Axiom.<surplus>` construction in theorem and metalogic proof code with the derived definitions, while the constructors still exist.

**Tasks**:
- [ ] Rewrite `DerivationTree.axiom (fc := _)? Γ _ (Axiom.X args) h` into `DerivedAxioms.X args` (with Γ = `[]`) or `DerivedAxioms.XAt Γ args`.
  - Drop `h`, except for `prior_SZ` and `prior_S_gap`, where `h` (definitionally `ZTime ≤ fc` / `RTime ≤ fc`) becomes the gate argument.
  - Work through `Theorems/` (`ContextualProofs`, `TemporalDerived`, `DedekindDerived`, `ModalS4`, `ModalS5`, `ModalDerived`, `Perpetuity/Principles`).
  - Then `Metalogic/BXCanonical/**` (Chronicle/*, CanonicalModel, CanonicalChain, Frame, Quasimodel/Construction, Filtration/DefectChain).
  - Then `Metalogic/WeakCanonical/**`, `Metalogic/Bundle/**`, `Decidability/FMP/TruthPreservation.lean`, `Deterministic/Collapse.lean`, `Algebraic/InteriorOperators.lean`, `Conservativity/TMCompletenessReduction.lean` and `SoundnessLemmas/CoValidity.lean`.
- [ ] For `Theorems/Perpetuity/Helpers.lean`'s `applyAxiomTo (axiom_proof : Axiom _)`, switch callers that pass `modal_4` or `modal_b` to a derivation-taking variant. Add `applyDerivTo` if none exists.
- [ ] Build each module after it is edited, and commit per green sub-step.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: about 120 sites across about 35 files under `Theorems/` and `Metalogic/`, excluding Conservativity/Plus, Independence and Decidability/Verified. Confirm with the surplus-name grep in the report, restricted to those directories. It should reach 0 at phase end.

**Files to modify**:
- `FormalSystem/Theorems/**`, `FormalSystem/Metalogic/{BXCanonical,WeakCanonical,Bundle,Algebraic,Deterministic}/**`, `Metalogic/Decidability/FMP/TruthPreservation.lean`, `Metalogic/Conservativity/TMCompletenessReduction.lean`, `Metalogic/SoundnessLemmas/CoValidity.lean`: call-site rewrites

**Verification**:
- The grep for `Axiom\.(surplus names)` is empty in these directories. Docstring mentions are allowed and are fixed in phase 9.
- Each edited module builds.

---

### Phase 4: Rewrite Automation, the decision procedure and the dataset executables [COMPLETED]

**Goal**: Move the "axiom-as-data" consumers off the surplus constructors.

**Tasks**:
- [x] `Automation/ProofSearch/Core.lean`: move the surplus patterns out of `matchAxiom : Formula → Option (Sigma Axiom)` into `matchDerived` (around line 1044), returning the derived definitions. *(deviation: altered — mirror arms moved into new `mirrorCandidate`/`matchMirror`, which `matchDerived` tries first and `matchesAxiom` ORs in; `prior_SZ` gets its own ZTime-valued `matchPriorSZ`)*
- [x] `Automation/Tactics/Search.lean`: remove the surplus names from the ``Axiom.X`` list for `modal_search`. Add a parallel list of derived-definition names tried with `exact` (or `apply`), so that `modal_search` still closes the mirror goals in `Tests/`. *(deviation: altered — the Base mirrors are already `@[tmLemma]` and are reached by `tryLemmaMatch`; only the gated `prior_SZ`/`prior_S_gap` needed a new strategy, `tryGatedDerivedMatch`)*
- [x] `Automation/FormulaEnumerator.lean`: drop the surplus seeds, or seed from the derived definitions' formulas. *(mirror seeds dropped; schema indices compacted to the 29 primitives, `pickSchemaIdx` and `ProofFirstTests` updated)*
- [x] `Automation/ProofExtractorMain.lean` (about 30 sites): replace the constructors with derived definitions. If it emits axiom names into JSONL, keep the output keyed by formula, and note in phase 9 how mirror steps now serialize.
- [x] `Metalogic/Decidability/Verified/RuleSpec.lean`: in `ruleAxioms`, replace `since_P`, `self_accum_since`, `prior_SZ`, `prior_S_gap` and `serial_past` with their TR primaries. Check that the `by decide` gates still close, and document "grounded via TR" in the docstring.
- [x] `Metalogic/Decidability/Tableau.lean`: rewrite its surplus uses. *(only comments mention mirrors; addition: `Closure.lean`'s `ClosureReason.axiomNeg` now carries a derivation at its least frame class instead of an `Axiom` witness, and `checkAxiomNeg` also closes on negated derived schemata — without this `TableauConformance` regressed on BX11'/BX10'/BX7')*
- [x] `Decidability/ProofExtraction.lean`: check the callers of `proofFromAxiom` for surplus arguments.
- [x] Build each module, then build the executables with `lake build dataset_generator proof_extractor benchmark_anchors`.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: about 90 sites in `Automation/` plus `Decidability/{Verified,Tableau}`. Confirm by grep. It should reach 0 at phase end. `MachineAppendixMain.lean` is deferred to phase 9.

**Files to modify**:
- `FormalSystem/Automation/ProofSearch/Core.lean`, `Automation/Tactics/Search.lean`, `Automation/FormulaEnumerator.lean`, `Automation/ProofExtractorMain.lean`
- `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean`, `Metalogic/Decidability/Tableau.lean`, `Metalogic/Decidability/ProofExtraction.lean`

**Verification**:
- The affected modules and executables build.
- The `modal_search`-based tests in `Tests/BimodalTest/Automation/TacticsTest.lean` still elaborate. Build that test module.

---

### Phase 5: Rewrite the validity transfers, Star embeddings and tests [COMPLETED]

**Goal**: Replace the per-axiom validity-transfer arms that consume TM surplus constructors, and move the test suite onto the derived definitions.

**Tasks**:
- [x] `Conservativity/Plus/Atomization.lean`: next to `plusValidIn_of_tm` and `plusValidIn_swap_of_tm` (which take `(ax : Axiom _)`), add derivation-taking variants via `soundness_validIn` / `derivable_valid_and_swap_validIn`. Use them in the mirror arms of `Conservativity/Plus/AxiomValidity.lean` (32 sites).
- [x] `Independence/CoarsenedModels.lean`: apply the same fix to `cValid_of_tm` and `cValid_swap_of_tm` (28 sites).
- [x] `Syntax/StarLanguage/Axioms.lean` (about line 700 onward) and `Conservativity/Star/StarAxiomValidity.lean`: rewrite the TM-derivation constructions to the derived definitions. *(no qualified TM `Axiom.<surplus>` sites there: the planning-time hits were `StarAxiom` constructors, which are out of scope)*
- [x] `Tests/BimodalTest/**`, 48 sites: *(done in phase 3 by the same rewrite; AxiomsTest modal_4/modal_b examples converted)*
  - Rewrite constructor uses to the derived definitions.
  - Keep `modal_search` examples unchanged when they still close.
  - In `AxiomsTest.lean`, convert per-constructor tests on surplus axioms into tests on the derived definitions.
- [x] After this phase, grep for `Axiom\.(surplus)\b` across `FormalSystem/` and `Tests/` (excluding Boneyard and docstrings). It must return only `Axioms.lean`, the dispatchers listed in phase 6 and `MachineAppendixMain.lean`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: 60 validity-transfer sites, about 20 Star sites and 48 test sites. Confirm by grep. The residual list at phase end must be exactly the phase 6 dispatcher set plus the appendix.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Plus/{Atomization,AxiomValidity}.lean`, `Metalogic/Independence/CoarsenedModels.lean`
- `FormalSystem/Syntax/StarLanguage/Axioms.lean`, `Metalogic/Conservativity/Star/StarAxiomValidity.lean`
- `Tests/BimodalTest/**`

**Verification**:
- A full `lake build` is green (run detached and guarded), and the residual grep matches the expected set.

---

### Phase 6: Remove the 16 surplus constructors [NOT STARTED]

**Goal**: Delete the surplus constructors from `inductive Axiom`, together with every dispatcher arm, so that the primitive set is the 29 paper schemata (TL, CN and TS are still in the old form).

**Tasks**:
- [ ] Delete the 16 constructors from `ProofSystem/Axioms.lean`, and delete the `prior_SZ` and `prior_S_gap` arms of `Axiom.minFrameClass`.
- [ ] Delete the matching arms in the following dispatchers. The derived definitions are already TR-based, so nothing downstream depends on these arms.
  - `Metalogic/Soundness.lean`: `axiom_validIn_min`. Keep every `*_valid` / `*_swap_valid` lemma for the mirrors as a plain lemma, because the primaries' swap arms use them.
  - `SoundnessLemmas/FrameClassVariants.lean`: `axiom_swap_valid_general`.
  - `Syntax/PlusLanguage/Derivation.lean`: `PlusAxiom.ofTM` and `minFrameClass_ofTM`.
  - `Automation/DatasetGenerator.lean` and `Automation/ProofStepExtractor.lean`.
  - `Automation/AxiomNames.lean`.
  - `Automation/MachineAppendixMain.lean`.
  - Any further arm the compiler reports.
- [ ] Update the `Axioms.lean` constructor-count docstring (45 constructors in nine layers) to the 29-schema layout. The full documentation pass comes in phase 9.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 6 exhaustive dispatchers, plus `AxiomNames` and `MachineAppendixMain`. The compiler is the oracle. Record every additional arm it reports.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean`, `Metalogic/Soundness.lean`, `Metalogic/SoundnessLemmas/FrameClassVariants.lean`, `Syntax/PlusLanguage/Derivation.lean`, `Automation/{DatasetGenerator,ProofStepExtractor,AxiomNames,MachineAppendixMain}.lean`

**Verification**:
- A full `lake build` is green.
- The `Axiom` constructor count is 29 (`grep -c "^  | " ` over the inductive body, or `#eval` over `AxiomNames.allAxiomNames.length`).
- The sorry and axiom census is unchanged from the phase 1 baseline.

---

### Phase 7: Restate TL and CN verbatim, in lockstep with TM⁺ [NOT STARTED]

**Goal**: State `temp_linearity` as the paper's TL and `linear_until` as the paper's CN, with right-associated disjunctions, keeping the old forms as derived legacy definitions.

**Tasks**:
- [ ] In `Axioms.lean`, set TL to `F φ ∧ F ψ → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`.
- [ ] In `Axioms.lean`, set CN to `(φ U ψ) ∧ (χ U θ) → (φ∧χ) U (ψ∧θ) ∨ ((φ∧χ) U (ψ∧χ) ∨ (φ∧χ) U (φ∧θ))`, with the guard written first.
- [ ] Re-prove `temp_linearity_valid` and `linear_until_valid`, together with their swap forms. Only the disjunct permutation changes.
- [ ] Add `DerivedAxioms.temp_linearity_legacy` and `DerivedAxioms.linear_until_legacy` (the old statements) to `DerivedAxioms.lean` or a small follow-on module, using disjunction permutation and regrouping. Reuse `orElim`, `orIntroL`, `orIntroR` and `deductionTheorem`, or the reshuffle already in `MinusLanguage/AxiomDischarge.lean`'s `dischargeTempLinearity`.
  - This may need a propositional module to be imported. If so, place the legacy defs in `ModalPrimitiveDerived.lean`'s layer, or a sibling after `Propositional.Core`.
- [ ] Re-derive `DerivedAxioms.temp_linearity_past` and `DerivedAxioms.linear_since`, keeping their current statements, by TR of the new primaries followed by the same permutation.
- [ ] Lockstep:
  - Restate `PlusAxiom.temp_linearity` and `PlusAxiom.linear_until` identically, and re-prove their Plus validity lemmas.
  - Grep `StarAxiom`, `DetAxiom` and `MinusLanguage.Axiom` for any `ofTM`/`ofPlus`-style embedding that is definitionally aligned, and restate those twins too. A twin with no aligned embedding stays as-is.
- [ ] Switch every consumer of the old order to the `*_legacy` definitions. That covers Tableau, RuleSpec (whose "branches are the TL disjuncts" comment now points at the legacy lemma), `BXCanonical/OrderedSeedConsistency.lean`, `Chronicle/PointInsertion.lean`, `Chronicle/RRelation.lean`, `Theorems/DiscreteUnfolding.lean`, `MinusLanguage/AxiomDischarge.lean` and `Automation`.
  - Simplify `dischargeTempLinearity` where TL is now verbatim.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: about 50 TL/CN use sites across 15 files (grep census from planning), plus the Plus twins. Confirm with `grep -rn "Axiom\.\(temp_linearity\|linear_until\)\b"` and the corresponding `PlusAxiom` grep.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean`, `ProofSystem/DerivedAxioms.lean` (or its sibling), `Metalogic/Soundness.lean` (TL/CN validity), `Syntax/PlusLanguage/Axioms.lean`, Plus soundness
- The consumer files named above

**Verification**:
- A full `lake build` is green, and `lean_verify` is clean on both `_legacy` defs and on the re-derived `temp_linearity_past` and `linear_since`.

---

### Phase 8: Restate TS as bare F⊤ [NOT STARTED]

**Goal**: State `serial_future` as the paper's `F⊤`, keeping `⊤ → F⊤` as the derived `serial_future_imp`.

**Tasks**:
- [ ] Change the `serial_future` index to `Formula.someFuture (Formula.bot.imp Formula.bot)`, and re-prove its validity and swap validity.
- [ ] Add `DerivedAxioms.serial_future_imp {fc} : ⊢[fc] ⊤ → F⊤`, obtained by `prop_s` plus MP on the new axiom.
- [ ] Re-derive `DerivedAxioms.serial_past`, keeping its current `⊤ → P⊤` statement, by TR of TS followed by `prop_s`.
- [ ] Apply the same TM⁺ lockstep restatement as in phase 7.
- [ ] Rewrite the qualified `Axiom.serial_future` sites to `serial_future_imp`/`…At`.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 41 qualified `Axiom.serial_future` sites (planning-time grep). Confirm by grep before editing.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean`, `ProofSystem/DerivedAxioms.lean`, `Metalogic/Soundness.lean`, `Syntax/PlusLanguage/{Axioms,Derivation}.lean`, and the `serial_future` call-site files

**Verification**:
- A full `lake build` is green, and `lean_verify` is clean on `serial_future_imp` and `serial_past`.

---

### Phase 9: Machine appendix, generated counts, dataset versioning and docs [NOT STARTED]

**Goal**: Make every generated and documentary artifact describe the 29-schema primitive system plus its derived mirrors.

**Tasks**:
- [ ] Machine appendix:
  - Check that `Automation/AxiomNames.lean`'s `allAxiomNames` has 29 entries.
  - Update the `MachineAppendixMain` entries so that derived mirrors appear as derived theorems, if the appendix lists theorems.
  - Regenerate `typst/generated/machine-appendix.{jsonl,typ}` via `lake exe machine_appendix` and `typst/generated/status.typ` via `scripts/typst-status-counts.sh`.
- [ ] Dataset versioning: add an explicit axiom-system version field (value `paper-29`) to the generator and extractor metadata output (`DatasetGenerator`, `ProofStepExtractor`/`ProofExtractorMain`, `DataExport` as applicable).
  - Record that mirror steps now serialize as `time_reflection` over a primary.
  - Do not rewrite existing `data/*.jsonl`.
- [ ] Rewrite `docs/reference/axiom-reference.md`:
  - The primitive system: 29 schemata keyed by `\aitem` / `\label` (MK … SEP, `def:S5`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:BX-r`).
  - A "Derived mirrors" table listing each derived definition with its primary and derivation (TR, or K/T/5).
  - Correct the NA row: the constructor keeps its name and is the paper's NA.
  - The TL, CN and TS verbatim restatements, with their legacy definitions.
- [ ] Update the module docstrings in `ProofSystem/Axioms.lean` (layer counts, the NA docstring, the source table) and `Syntax/PlusLanguage/Axioms.lean`. The old wording ("the 45 TM schemata re-declared") becomes "the 29 TM schemata plus 16 TM-derivable schemata kept primitive in TM⁺".
- [ ] Update `typst/chapters/03-proof-theory.typ` and `typst/SYNC-MAP.md` where they state the constructor count or list mirrors as primitive. Update `docs/reference/paper-definitions-of-record.md`'s correspondence note, which claims a `derivable_iff` follow-up, to point at the new state.
- [ ] Fix any stale docstring mentions of the removed constructors that phases 3 to 8 left behind.
- [ ] Run `bash .claude/scripts/check-task-references.sh`, or the repo lint, to confirm that no deliverable cites a task number.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: interface

**Scope Hypothesis**: the machine appendix axiom rows go from 45 to 29. Confirm by `grep -c` on the regenerated JSONL `kind` field (or equivalent), before and after.

**Files to modify**:
- `FormalSystem/Automation/{AxiomNames,MachineAppendixMain,DatasetGenerator,ProofExtractorMain}.lean`, `typst/generated/*`, `typst/chapters/03-proof-theory.typ`, `typst/SYNC-MAP.md`
- `docs/reference/axiom-reference.md`, `docs/reference/paper-definitions-of-record.md`, `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Syntax/PlusLanguage/Axioms.lean`

**Verification**:
- `lake exe machine_appendix` runs and the regenerated files are committed.
- `typst compile` of the manual's root succeeds, if the chapter changed.
- The docs grep for "45" axiom-count claims is clean.

---

### Phase 10: Final gate [NOT STARTED]

**Goal**: Run the complete repository gate and certify the acceptance criteria.

**Tasks**:
- [ ] Run a full `lake build`, detached, including `BimodalTest` and every `lean_exe`.
- [ ] Run the test suite, following the repo's test invocation (`lake build BimodalTest` or `lake test`, whichever the repo defines).
- [ ] Run `lean_verify` on all 19 derived definitions, and on `soundness_validIn` plus the completeness headline theorems, to confirm their axiom footprint is unchanged.
- [ ] Recount sorry and axiom declarations, and diff against the phase 1 baseline. It must show no increase.
- [ ] Confirm the `Axiom` constructor count is 29, and that each of the 16 removed names resolves to a `DerivedAxioms` definition.

**Timing**: 1 hour

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- None, unless fixes are needed.

**Verification**:
- Every item above passes.

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace FormalSystem.ProofSystem.DerivedAxioms

def serial_past {fc : FrameClass} :
    ⊢[fc] (Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot)) :=
  sorry

def connect_past {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (φ.someFuture.allPast) := sorry

def temp_linearity_past {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := sorry

def since_P {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.somePast ψ) := sorry

def P_since_equiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.somePast φ).imp (Formula.snce (Formula.bot.imp Formula.bot) φ) := sorry

def absorb_since {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) := sorry

def right_mono_since {fc : FrameClass} (φ ψ χ : Formula) :
    ⊢[fc] (φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ)) := sorry

def self_accum_since {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.snce φ ψ).imp (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ) := sorry

def left_mono_since_H {fc : FrameClass} (φ χ ψ : Formula) :
    ⊢[fc] (φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ)) := sorry

def enrichment_since {fc : FrameClass} (φ ψ p : Formula) :
    ⊢[fc] (Formula.and p (Formula.snce φ ψ) |>.imp
      (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))) := sorry

def linear_since {fc : FrameClass} (φ ψ χ θ : Formula) :
    ⊢[fc] (Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.snce (Formula.and φ χ) (Formula.and φ θ)))) := sorry

def discrete_symm_bwd {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)) := sorry

def prior_SZ {fc : FrameClass} (h : FrameClass.ZTime ≤ fc) (φ : Formula) :
    ⊢[fc] φ.somePast.imp (Formula.snce φ.neg φ) := sorry

def prior_S_gap {fc : FrameClass} (h : FrameClass.RTime ≤ fc) (φ : Formula) :
    ⊢[fc] (Formula.and (Formula.snce φ Formula.top) φ.neg.somePast).imp
      (Formula.snce φ (Formula.or φ.neg (Formula.kMinus φ.neg))) := sorry

def modal_4 {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.box φ).imp (Formula.box (Formula.box φ)) := sorry

def modal_b {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (Formula.box φ.diamond) := sorry

def temp_linearity_legacy {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) := sorry

def linear_until_legacy {fc : FrameClass} (φ ψ χ θ : Formula) :
    ⊢[fc] (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untl (Formula.and φ χ) (Formula.and φ θ)))) := sorry

def serial_future_imp {fc : FrameClass} :
    ⊢[fc] (Formula.bot.imp Formula.bot).imp
      (Formula.someFuture (Formula.bot.imp Formula.bot)) := sorry

end FormalSystem.ProofSystem.DerivedAxioms
```

Notes on these statements:
- The argument order of the `prior_SZ` and `prior_S_gap` gate hypothesis, which comes before or after `φ`, is fixed by the statements above. If the rewrite ergonomics in phase 3 favour `φ` first, change both this block and the definitions together, never one without the other.
- The `XAt Γ` context-lifted helpers are convenience wrappers and are not challenge targets.

## Testing & Validation

- [ ] A full `lake build` is green: `FormalSystem`, `BimodalTest` and all `lean_exe` targets.
- [ ] No sorry or axiom declaration is added relative to the phase 1 baseline.
- [ ] `lean_verify` is clean on all 19 derived definitions.
- [ ] `inductive Axiom` has exactly 29 constructors, and TL, CN and TS match `sub:Logic`'s `\aitem{TL}`, `\aitem{CN}` and `\aitem{TS}` up to the right-associated 3-way disjunction.
- [ ] `modal_search` and the automation tests still close their former mirror goals.
- [ ] The machine appendix and `status.typ` are regenerated, and the axiom count reads 29.
- [ ] `docs/reference/axiom-reference.md` states the primitive system plus the derived-mirror table.

## Artifacts & Outputs

- `FormalSystem/ProofSystem/DerivedAxioms.lean` (new)
- `FormalSystem/Theorems/ModalPrimitiveDerived.lean` (new)
- The revised `FormalSystem/ProofSystem/Axioms.lean` (29 constructors)
- The regenerated `typst/generated/machine-appendix.{jsonl,typ}` and `status.typ`
- The rewritten `docs/reference/axiom-reference.md`
- `specs/606_adopt_paper_axiom_system_and_derive_surplus_axioms/summaries/01_paper-axiom-system-summary.md`

## Rollback/Contingency

- Phases 1 to 5 are purely additive or rewrite-only while the constructors stay live, so any one of them can be reverted per commit.
- Phases 6 to 8 are atomic batches. If one cannot reach green, revert that phase's uncommitted batch through the sanctioned snapshot-then-rollback flow (`git-snapshot.sh` rollback rung, see `context/contracts/recovery.md`), mark the phase [PARTIAL], and record the blocking arm.
- If the TM⁺ lockstep in phase 7 or 8 turns out to cascade too far into the Plus or Star soundness proofs, the fallback is to make `PlusDerivationTree.ofTM`'s axiom case call a derivation-valued `PlusAxiom.derivOfTM` whose TL, CN and TS arms permute the unchanged TM⁺ constructors. That keeps TM⁺ as it is. Record the choice in the phase notes.
- If phase 8 (TS) is blocked, TS may be explicitly waived with the recorded reason that it is trivially interderivable with `⊤ → F⊤`. It must be documented in `axiom-reference.md`, never silently kept.
