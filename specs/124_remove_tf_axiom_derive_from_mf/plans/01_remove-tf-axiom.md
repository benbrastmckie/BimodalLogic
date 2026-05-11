# Implementation Plan: Remove TF Axiom and Derive from MF

- **Task**: 124 - Remove TF axiom and derive from MF
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/124_remove_tf_axiom_derive_from_mf/reports/01_tf-derivation-research.md, specs/124_remove_tf_axiom_derive_from_mf/reports/01_remove-tf-axiom.md
- **Artifacts**: plans/01_remove-tf-axiom.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove the `temp_future` axiom constructor (`□φ -> G□φ`) from the `Axiom` inductive type and replace all usages with a derived theorem that chains `modal_4` (`□φ -> □□φ`), `modal_future` applied to `□φ` (`□□φ -> □G□φ`), and `modal_t` applied to `G□φ` (`□G□φ -> G□φ`) via two `imp_trans` calls. The change touches approximately 30 files with ~75 references. The task is complete when `lake build` passes with no new sorries and no references to `Axiom.temp_future` remain in the codebase.

### Research Integration

Two research reports confirmed the derivation strategy and mapped all call sites:

- **01_tf-derivation-research.md**: Identified the 3-step derivation (modal_4 + MF(□φ) + T(G□φ)), catalogued all ~75 references across ~30 files with line numbers, and assessed risk levels.
- **01_remove-tf-axiom.md**: Confirmed derivation uses `Combinators.imp_trans`, identified automation complexity (ProofSearch `matchAxiom` returns `Option (Sigma Axiom)` -- TF can no longer be returned as an Axiom witness), and recommended placement in `TemporalDerived.lean`.

Key findings:
- All downstream usages are either `DerivationTree.axiom [] _ (Axiom.temp_future φ)` (replace with `temp_future_derived φ`) or match arms in exhaustive patterns (delete).
- The STSA `TF` algebraic field stays -- only its proof changes internally.
- ExtAxiom mirrors Axiom and needs synchronized removal.
- ProofSearch `matchAxiom` needs special handling since it returns `Option (Sigma Axiom)`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances:
- **ROADMAP.md Layer 4 "Modal-Temporal Interaction (2)"**: Reduces from 2 primitive axioms to 1 (`modal_future` only); `temp_future` becomes a derived theorem.
- **Axiom count**: 45 -> 44 constructors.

## Goals & Non-Goals

**Goals**:
- Remove `temp_future` from the `Axiom` inductive type
- Add `temp_future_derived` as a proof term deriving TF from MF + T + Modal 4
- Update all ~30 files that reference `Axiom.temp_future`
- Maintain passing `lake build` with zero new sorries
- Update documentation (axiom counts, comments, docstrings)

**Non-Goals**:
- Changing the STSA class interface (keep the `TF` field; only the instance proof changes)
- Removing other axioms or further axiom-reduction refactoring
- Modifying the derivation strategy (MF + T + 4 is confirmed correct)
- Fixing existing sorries unrelated to this task

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ProofSearch `matchAxiom` type mismatch after removal | H | M | Phase 4 handles this specifically: either add a parallel `matchDerived` function or modify `matchAxiom` to return `Option (DerivationTree)` instead of `Option (Sigma Axiom)` for the TF pattern |
| ConservativeExtension ExtAxiom desync | M | L | Phase 3 synchronizes ExtAxiom removal with Axiom removal, updating all 4 affected files together |
| Boneyard files break build | L | M | Phase 5 updates all 5 Boneyard files; these are legacy but must still compile |
| Completeness proofs broken by type changes | H | L | Phase 2 does mechanical replacement only (`temp_future_derived φ` has identical type signature to the old axiom invocation) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5, 6 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Derived Theorem and Remove Axiom Constructor [NOT STARTED]

**Goal**: Create `temp_future_derived` in TemporalDerived.lean, then remove `temp_future` from the Axiom inductive type so the compiler identifies all downstream breakages.

**Tasks**:
- [ ] Add `temp_future_derived` definition to `Theories/Bimodal/Theorems/TemporalDerived.lean` using the 3-step chain: `imp_trans (imp_trans (axiom modal_4 φ) (axiom modal_future (box φ))) (axiom modal_t (all_future (box φ)))`
- [ ] Verify `temp_future_derived` compiles and has type `⊢ (Formula.box φ).imp (Formula.all_future (Formula.box φ))`
- [ ] Remove `temp_future` constructor from `Axiom` inductive in `Theories/Bimodal/ProofSystem/Axioms.lean` (line ~331)
- [ ] Remove `temp_future` match arm from `Theories/Bimodal/ProofSystem/Substitution.lean` (line ~370-372)
- [ ] Update axiom count docstring in `Axioms.lean`: 45 -> 44 constructors
- [ ] Update Layer 4 comment: "Modal-Temporal Interaction (2)" -> "(1)"
- [ ] Update doc comments in `ProofSystem.lean` (lines ~17, 32)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add `temp_future_derived` definition
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Remove constructor, update docs
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Remove match arm
- `Theories/Bimodal/ProofSystem.lean` - Update doc comments

**Verification**:
- `temp_future_derived` compiles with correct type signature
- Compiler reports expected errors in downstream files (match arms and direct usages)

---

### Phase 2: Update Metalogic (Soundness, Completeness, Algebraic) [NOT STARTED]

**Goal**: Fix all compilation errors in the Metalogic directory by removing soundness match arms and replacing direct `Axiom.temp_future` usages in completeness and algebraic proofs.

**Tasks**:
- [ ] **Soundness.lean**: Remove `temp_future_valid` theorem (lines ~267-273) and all 5 match arms in `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete`, `soundness_dense`, `soundness_discrete_valid`
- [ ] **SoundnessLemmas.lean**: Remove `axiom_temp_future_valid`, `swap_axiom_tf_valid`, and all match arms (~6 removals)
- [ ] **FrameConditions/Compatibility.lean**: Remove `AxiomLinearCompatible` instance for `temp_future` (line ~156-157), update doc comment (line ~31)
- [ ] **FrameConditions/Soundness.lean**: Update doc comment (line ~174)
- [ ] **BXCanonical/Frame.lean**: Replace `DerivationTree.axiom [] _ (Axiom.temp_future φ)` with `temp_future_derived φ` at lines ~598, 617; update 4 comments
- [ ] **BXCanonical/CanonicalModel.lean**: Replace at lines ~332, 358
- [ ] **BXCanonical/Chronicle/ChronicleToCountermodel.lean**: Replace at lines ~323, 353, 420
- [ ] **Algebraic/TenseS5Algebra.lean**: Update `TF_quot` theorem (lines ~174-178) to use `temp_future_derived`
- [ ] **Algebraic/ParametricTruthLemma.lean**: Update `past_tf_deriv` (lines ~154-165) and `parametric_box_persistent` (lines ~180-182)
- [ ] Update doc comments in Soundness.lean (lines ~18-19, 34, 43, 48) and SoundnessLemmas.lean (lines ~51, 215, 385, 484)
- [ ] Run `lake build` on Metalogic modules to verify no errors

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Remove theorem + 5 match arms + docs
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove 2 theorems + match arms + docs
- `Theories/Bimodal/FrameConditions/Compatibility.lean` - Remove instance + doc
- `Theories/Bimodal/FrameConditions/Soundness.lean` - Update doc comment
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Replace 2 usages + 4 comments
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Replace 2 usages
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace 3 usages
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` - Update TF_quot
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Update 2 usages

**Verification**:
- All Metalogic modules compile without errors
- No references to `Axiom.temp_future` remain in Metalogic/

---

### Phase 3: Update ConservativeExtension [NOT STARTED]

**Goal**: Remove `temp_future` from the ExtAxiom mirror type and update all embedding/lifting match arms.

**Tasks**:
- [ ] **ExtDerivation.lean**: Remove `ExtAxiom.temp_future` constructor (line ~61-62) and the `embedAxiom` match arm (line ~123)
- [ ] **Lifting.lean**: Remove 3 match arms (lines ~207, 235, 475)
- [ ] **Substitution.lean**: Remove 1 match arm (line ~204)
- [ ] Add `ext_temp_future_derived` if needed (parallel derived form for ExtDerivation)
- [ ] Run `lake build` on ConservativeExtension modules

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Remove constructor + match arm
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Remove 3 match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` - Remove 1 match arm

**Verification**:
- ConservativeExtension modules compile without errors
- No references to `ExtAxiom.temp_future` remain

---

### Phase 4: Update Automation (ProofSearch, Tactics, AesopRules) [NOT STARTED]

**Goal**: Update the proof search and tactic machinery to handle TF as a derived theorem rather than a primitive axiom.

**Tasks**:
- [ ] **ProofSearch.lean**: Analyze `matchAxiom` return type (`Option (Sigma Axiom)`) and determine approach:
  - Option A: Add a separate `matchDerived` function that returns `Option (DerivationTree)` for the TF pattern, called after `matchAxiom` in the search loop
  - Option B: Change the search to first try `matchAxiom`, then try derived patterns, combining results
- [ ] **ProofSearch.lean**: Remove `temp_future` from `isAxiomLike` boolean check (line ~381)
- [ ] **ProofSearch.lean**: Remove/replace the TF match in `matchAxiom` (lines ~456-461) -- either remove entirely (if using a separate derived function) or convert to derived proof construction
- [ ] **ProofSearch.lean**: Update the TF pattern match at lines ~360-362
- [ ] **Tactics.lean**: Remove `Axiom.temp_future` from `axiomCtors` list (line ~623); add `temp_future_derived` as a derived axiom lookup if needed
- [ ] **AesopRules.lean**: Update doc comment (line ~34)
- [ ] Run `lake build` on Automation modules and verify proof search still finds TF proofs

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch.lean` - Remove/replace TF pattern matching, update derived proof handling
- `Theories/Bimodal/Automation/Tactics.lean` - Remove from axiom list, add derived lookup
- `Theories/Bimodal/Automation/AesopRules.lean` - Update doc comment

**Verification**:
- Automation modules compile without errors
- Proof search can still find TF-shaped proofs (via derived theorem)
- Existing tactic-based proofs in Examples/ still work

---

### Phase 5: Update Theorems, Examples, and Boneyard [NOT STARTED]

**Goal**: Replace all remaining `Axiom.temp_future` references in theorem files, example files, and legacy Boneyard code.

**Tasks**:
- [ ] **Perpetuity/Principles.lean**: Replace 3 usages (lines ~642, 788, 795) with `temp_future_derived`
- [ ] **Examples/BimodalProofStrategies.lean**: Replace 5 usages (lines ~224, 244, 284, 307, 366)
- [ ] **Examples/TemporalProofs.lean**: Replace 2 usages (lines ~238, 246)
- [ ] **Boneyard/QuasimodelOracle/OracleCoherence.lean**: Replace 2 usages (lines ~242, 264)
- [ ] **Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean**: Replace 2 usages (lines ~359, 377) -- may need import added for `temp_future_derived`
- [ ] **Boneyard/DefectDirectedChain/RootScopedChain.lean**: Replace 2 usages (lines ~747, 769)
- [ ] **Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean**: Replace 2 usages (lines ~402, 426)
- [ ] **Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean**: Replace references (lines ~2048, 2062)
- [ ] Run `lake build` to verify all theorem/example/boneyard files compile

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Replace 3 usages
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - Replace 5 usages
- `Theories/Bimodal/Examples/TemporalProofs.lean` - Replace 2 usages
- `Boneyard/QuasimodelOracle/OracleCoherence.lean` - Replace 2 usages
- `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean` - Replace 2 usages
- `Boneyard/DefectDirectedChain/RootScopedChain.lean` - Replace 2 usages
- `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` - Replace 2 usages
- `Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` - Replace references

**Verification**:
- All files compile
- `grep -r "Axiom.temp_future" Theories/ Boneyard/` returns zero results

---

### Phase 6: Update Tests and Documentation [NOT STARTED]

**Goal**: Fix all test files and update remaining documentation to reflect the axiom removal.

**Tasks**:
- [ ] **Tests/BimodalTest/ProofSystem/AxiomsTest.lean**: Remove/update 2 test references
- [ ] **Tests/BimodalTest/ProofSystem/DerivationTest.lean**: Update 1 test
- [ ] **Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean**: Update 1 reference
- [ ] **Tests/BimodalTest/Integration/BimodalIntegrationTest.lean**: Replace 7 `Axiom.temp_future` references
- [ ] **Tests/BimodalTest/Integration/ComplexDerivationTest.lean**: Replace 1 reference
- [ ] **Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean**: Replace 1 reference
- [ ] **Tests/BimodalTest/Automation/TacticsTest.lean**: Update 6 tactic tests
- [ ] **Tests/BimodalTest/Automation/EdgeCaseTest.lean**: Update 1 reference
- [ ] **Tests/BimodalTest/Automation/ProofSearchTest.lean**: Update 5 search tests
- [ ] Update doc comments in: `ProofSystem/LinearityDerivedFacts.lean` (line ~16), `Semantics/Truth.lean` (lines ~255, 691), `Semantics/Validity.lean` (line ~63), `Semantics/WorldHistory.lean` (line ~215), `Theorems/Perpetuity.lean` (line ~41), `Theorems/Perpetuity/Bridge.lean` (line ~953)
- [ ] Run full `lake build` to confirm zero errors
- [ ] Run `grep -rn "Axiom.temp_future\|ExtAxiom.temp_future\|temp_future_valid\|swap_axiom_tf_valid" Theories/ Tests/ Boneyard/` to confirm zero remaining references

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` - Update tests
- `Tests/BimodalTest/ProofSystem/DerivationTest.lean` - Update test
- `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` - Update reference
- `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` - Replace 7 references
- `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` - Replace reference
- `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` - Replace reference
- `Tests/BimodalTest/Automation/TacticsTest.lean` - Update 6 tests
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - Update reference
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` - Update 5 tests
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` - Update doc comment
- `Theories/Bimodal/Semantics/Truth.lean` - Update doc comments
- `Theories/Bimodal/Semantics/Validity.lean` - Update doc comment
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Update doc comment
- `Theories/Bimodal/Theorems/Perpetuity.lean` - Update doc comment
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - Update doc comment

**Verification**:
- Full `lake build` passes with zero errors
- Grep confirms no remaining `Axiom.temp_future` or `ExtAxiom.temp_future` references
- All tests pass

## Testing & Validation

- [ ] `lake build` completes with zero new errors
- [ ] `grep -rn "Axiom\.temp_future" Theories/ Tests/ Boneyard/` returns no matches
- [ ] `grep -rn "ExtAxiom\.temp_future" Theories/ Tests/ Boneyard/` returns no matches
- [ ] `grep -rn "temp_future_valid\|swap_axiom_tf_valid" Theories/ Tests/` returns no matches
- [ ] `temp_future_derived` has correct type: `(φ : Formula) -> ⊢ (Formula.box φ).imp (Formula.all_future (Formula.box φ))`
- [ ] Proof search automation still finds TF-shaped proofs
- [ ] No new `sorry` introduced

## Artifacts & Outputs

- `specs/124_remove_tf_axiom_derive_from_mf/plans/01_remove-tf-axiom.md` (this plan)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` (modified: new `temp_future_derived` definition)
- ~30 modified files across Theories/, Tests/, and Boneyard/

## Rollback/Contingency

Git-based rollback: all changes are on the `irr_until` branch. If the implementation causes unexpected breakage:

1. `git stash` or `git checkout .` to revert all uncommitted changes
2. Each phase is committed separately, so partial rollback via `git revert` is possible
3. The critical fallback: if automation changes in Phase 4 prove too complex, temporarily keep `temp_future` in `isAxiomLike` as a derived-proof lookup without changing the `matchAxiom` return type -- this is a safe intermediate step that preserves functionality while deferring the type-level cleanup
