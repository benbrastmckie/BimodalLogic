# Implementation Plan: Remove TF Axiom and Derive from MF

- **Task**: 124 - Remove TF axiom and derive from MF
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/124_remove_tf_axiom_derive_from_mf/reports/01_tf-derivation-research.md
- **Artifacts**: plans/01_remove-tf-axiom.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Remove the `temp_future` constructor from the `Axiom` inductive type and replace it with a derived theorem `temp_future_derived` that proves TF from MF + T + Modal 4 using `imp_trans` chains. This is a refactoring task: approximately 93 references across 21 Theories files and 25 references across 9 Test files must be updated. The derivation is straightforward (3 axiom instantiations + 2 `imp_trans` applications), and all call-site changes are mechanical replacements of `DerivationTree.axiom [] _ (Axiom.temp_future phi)` with `temp_future_derived phi`. The critical path runs through Soundness (deletions), ConservativeExtension (parallel removal of ExtAxiom.temp_future), and the BXCanonical completeness proofs (replacements).

### Research Integration

Key findings from the research report:
- TF derivation chain: MF(box phi) -> T(G(box phi)) -> imp_trans -> Modal 4(phi) -> imp_trans -> TF
- 93 references in Theories/, 25 in Tests/, 26 in Boneyard/ (low priority)
- Soundness changes are purely deletive (remove match arms and validity theorems)
- ConservativeExtension has a parallel `ExtAxiom.temp_future` that must be removed in coordination with `embedAxiom` and lifting theorems
- ProofSearch/Tactics need derived theorem accessible as a lookup, not as an Axiom constructor

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

The roadmap describes 45 BX axioms organized in 6 layers. Removing TF reduces the axiom count to 44 and changes the Layer 4 "Modal-Temporal Interaction" count from (2) to (1). This is a proof-system cleanup that simplifies the axiom base without changing the logic's strength, which aligns with the overall completeness effort by reducing the surface area that soundness and completeness proofs must cover.

## Goals & Non-Goals

**Goals**:
- Remove `temp_future` from the `Axiom` inductive type
- Add `temp_future_derived` theorem deriving TF from MF + T + Modal 4
- Update all exhaustive pattern matches on `Axiom` to remove the `temp_future` arm
- Replace all proof sites using `Axiom.temp_future` with `temp_future_derived`
- Remove `ExtAxiom.temp_future` from ConservativeExtension and update `embedAxiom`
- Remove soundness validity theorems for TF (now inherited from component axioms)
- Update automation (ProofSearch, Tactics) to use derived theorem
- Achieve clean `lake build` with no new sorries

**Non-Goals**:
- Changing the logic's strength (TF remains provable, just derived)
- Fixing or modifying Boneyard files beyond what is needed for compilation
- Removing or modifying any other axioms
- Changing the derivation strategy for other axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Exhaustive match compilation errors cascade across many files | M | H | Phase 3 removes the constructor after all uses are replaced, so Lean will surface all remaining match arms as errors at once; fix them systematically |
| ConservativeExtension embedAxiom/lifting out of sync | M | M | Phase 4 handles ConservativeExtension as a single atomic unit; verify with lake build after |
| ProofSearch returns DerivationTree, not Axiom -- type mismatch | M | M | Research confirms temp_future_derived returns same type (DerivationTree); just swap call sites |
| Boneyard files break after Axiom constructor removal | L | H | Boneyard is dead code; add sorry or comment if needed, do not invest time fixing proofs |
| imp_trans chain types do not unify | L | L | Research verified the exact instantiations; test in Phase 1 before proceeding |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Derived Theorem [COMPLETED]

**Goal**: Create `temp_future_derived` theorem and verify it type-checks.

**Tasks**:
- [ ] Add `temp_future_derived` definition to `Theorems/Combinators.lean` (or a new section near existing modal-temporal theorems)
- [ ] Implement the 3-step derivation: MF(box phi) -> chain with T(G(box phi)) -> chain with Modal 4(phi)
- [ ] Verify the theorem type-checks with `lake build Theories.Bimodal.Theorems.Combinators`
- [ ] Ensure the type signature matches the old constructor: `forall phi, |- (box phi).imp (all_future (box phi))`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/Combinators.lean` - Add `temp_future_derived` definition

**Verification**:
- `lake build Theories.Bimodal.Theorems.Combinators` succeeds
- `temp_future_derived` has type `(phi : Formula) -> DerivationTree [] ((Formula.box phi).imp (Formula.all_future (Formula.box phi)))`

---

### Phase 2: Replace All Proof-Site Usages [COMPLETED]

**Goal**: Replace every `Axiom.temp_future` usage in proof terms with `temp_future_derived`, before removing the constructor.

**Tasks**:
- [ ] Replace `Axiom.temp_future` in `Metalogic/BXCanonical/Frame.lean` (~3 proof uses + update 4 comments)
- [ ] Replace `Axiom.temp_future` in `Metalogic/BXCanonical/CanonicalModel.lean` (~4 occurrences)
- [ ] Replace `Axiom.temp_future` in `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (~7 occurrences)
- [ ] Replace `Axiom.temp_future` in `Metalogic/Algebraic/TenseS5Algebra.lean` (~1 occurrence)
- [ ] Replace `Axiom.temp_future` in `Metalogic/Algebraic/ParametricTruthLemma.lean` (~2 occurrences)
- [ ] Replace `Axiom.temp_future` in `Theorems/Perpetuity/Principles.lean` (~3 occurrences)
- [ ] Replace `Axiom.temp_future` in `Examples/BimodalProofStrategies.lean` (~6 occurrences)
- [ ] Replace `Axiom.temp_future` in `Examples/TemporalProofs.lean` (~2 occurrences)
- [ ] Replace in `Automation/ProofSearch.lean` (~4 occurrences) -- wire derived theorem into search table
- [ ] Replace in `Automation/Tactics.lean` (~2 occurrences) -- update tactic lookup lists
- [ ] Update comment in `Automation/AesopRules.lean` (~1 occurrence)
- [ ] Update comment in `FrameConditions/Soundness.lean` (~1 occurrence)
- [ ] Update comment in `ProofSystem/LinearityDerivedFacts.lean` (~1 occurrence)
- [ ] Run `lake build` to verify all replacements type-check with the constructor still present

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - Replace proof usages
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Replace proof usages
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace proof usages
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` - Replace proof usage
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Replace proof usages
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Replace proof usages
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - Replace references
- `Theories/Bimodal/Examples/TemporalProofs.lean` - Replace references
- `Theories/Bimodal/Automation/ProofSearch.lean` - Wire derived theorem into search
- `Theories/Bimodal/Automation/Tactics.lean` - Update tactic lists
- `Theories/Bimodal/Automation/AesopRules.lean` - Update comment
- `Theories/Bimodal/FrameConditions/Soundness.lean` - Update comment
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` - Update comment

**Verification**:
- `lake build` succeeds with zero new errors
- `grep -rn "Axiom.temp_future" Theories/Bimodal/` returns only Axioms.lean, Substitution.lean, Soundness.lean, SoundnessLemmas.lean, FrameConditions/Compatibility.lean, and ConservativeExtension files (match arms to be removed in Phase 3 and 4)

---

### Phase 3: Remove Constructor and Clean Match Arms [COMPLETED]

**Goal**: Remove `temp_future` from the `Axiom` inductive type and delete all exhaustive match arms that reference it.

**Tasks**:
- [ ] Remove `temp_future` constructor from `ProofSystem/Axioms.lean` (line ~331)
- [ ] Update docstring: axiom count 45 -> 44, Layer 4 comment "(2)" -> "(1)"
- [ ] Remove `temp_future` match arm from `ProofSystem/Substitution.lean` (~2 arms)
- [ ] Remove `temp_future_valid` theorem and all match arms from `Metalogic/Soundness.lean` (~7 locations)
- [ ] Remove `axiom_temp_future_valid` and match arms from `Metalogic/SoundnessLemmas.lean` (~6 locations), remove `swap_axiom_tf_valid`
- [ ] Remove `AxiomLinearCompatible` instance for temp_future from `FrameConditions/Compatibility.lean` (~3 locations)
- [ ] Run `lake build` to surface any remaining match arm errors
- [ ] Fix any additional match arms that the compiler flags

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Remove constructor, update docs
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Remove match arms
- `Theories/Bimodal/Metalogic/Soundness.lean` - Remove validity theorems and match arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove validity theorems and match arms
- `Theories/Bimodal/FrameConditions/Compatibility.lean` - Remove instance

**Verification**:
- `lake build` succeeds for core Theories (excluding ConservativeExtension and Boneyard)
- `grep -rn "Axiom.temp_future" Theories/Bimodal/` returns zero matches outside Boneyard and ConservativeExtension

---

### Phase 4: Update ConservativeExtension [COMPLETED]

**Goal**: Remove `ExtAxiom.temp_future` and update all related functions and match arms in the ConservativeExtension module.

**Tasks**:
- [ ] Remove `temp_future` from `ExtAxiom` inductive type in `ConservativeExtension/ExtDerivation.lean`
- [ ] Update `embedAxiom` function to remove the `Axiom.temp_future` case (or add `ext_temp_future_derived` if needed)
- [ ] Remove match arms in `ConservativeExtension/Lifting.lean` (~3 locations)
- [ ] Remove match arm in `ConservativeExtension/Substitution.lean` (~1 location)
- [ ] Run `lake build` to verify ConservativeExtension compiles

**Timing**: 1 hour

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Remove ExtAxiom.temp_future, update embedAxiom
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Remove match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` - Remove match arm

**Verification**:
- `lake build Theories.Bimodal.Metalogic.ConservativeExtension` succeeds
- `grep -rn "temp_future" Theories/Bimodal/Metalogic/ConservativeExtension/` returns zero matches

---

### Phase 5: Update Tests, Examples, and Boneyard [NOT STARTED]

**Goal**: Fix all remaining compilation errors in test files and handle Boneyard references.

**Tasks**:
- [ ] Update `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` (~2 references)
- [ ] Update `Tests/BimodalTest/ProofSystem/DerivationTest.lean` (~1 reference)
- [ ] Update `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` (~1 reference)
- [ ] Update `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` (~7 references)
- [ ] Update `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` (~1 reference)
- [ ] Update `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` (~1 reference)
- [ ] Update `Tests/BimodalTest/Automation/TacticsTest.lean` (~6 references)
- [ ] Update `Tests/BimodalTest/Automation/EdgeCaseTest.lean` (~1 reference)
- [ ] Update `Tests/BimodalTest/Automation/ProofSearchTest.lean` (~5 references)
- [ ] Handle Boneyard references: add `sorry` placeholders or update references in `Boneyard/QuasimodelOracle/OracleCoherence.lean`, `Boneyard/DefectDirectedChain/RootScopedChain.lean`, `Boneyard/StrictSemanticsLegacy/`, `Boneyard/ChainCompleteness/` as needed to compile
- [ ] Run full `lake build` to verify clean compilation
- [ ] Verify no new sorries introduced outside Boneyard

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` - Update/remove temp_future tests
- `Tests/BimodalTest/ProofSystem/DerivationTest.lean` - Update reference
- `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` - Update reference
- `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` - Replace Axiom.temp_future usages
- `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` - Replace reference
- `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` - Replace reference
- `Tests/BimodalTest/Automation/TacticsTest.lean` - Update tactic tests
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - Update reference
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` - Update search tests
- `Theories/Bimodal/Boneyard/` (multiple files) - Add sorry placeholders if needed

**Verification**:
- `lake build` succeeds with zero errors
- `grep -rn "Axiom.temp_future" .` returns zero matches (or only sorry-ed Boneyard lines)
- No new sorries in Theories/ or Tests/

## Testing & Validation

- [ ] `lake build` completes with zero errors
- [ ] `temp_future_derived` type-checks as `(phi : Formula) -> DerivationTree [] ((Formula.box phi).imp (Formula.all_future (Formula.box phi)))`
- [ ] No new sorries introduced anywhere in Theories/ or Tests/
- [ ] `grep -rn "Axiom.temp_future" Theories/` returns zero matches
- [ ] `grep -rn "ExtAxiom.temp_future" Theories/` returns zero matches
- [ ] All existing tests pass (lake build covers Tests/)
- [ ] The derived theorem is accessible from ProofSearch and Tactics

## Artifacts & Outputs

- `specs/124_remove_tf_axiom_derive_from_mf/plans/01_remove-tf-axiom.md` (this plan)
- `specs/124_remove_tf_axiom_derive_from_mf/summaries/01_remove-tf-axiom-summary.md` (after implementation)
- Modified file: `Theories/Bimodal/Theorems/Combinators.lean` (new `temp_future_derived`)
- Modified files: ~30 files across Theories/, Tests/, Boneyard/

## Rollback/Contingency

All changes are in-tree Lean source modifications. If the implementation fails:
1. `git stash` or `git checkout -- .` to revert all changes
2. The `temp_future` constructor remains in `Axiom` and all match arms stay intact
3. No external state or configuration is modified
4. The task can be re-attempted after further research if any type-checking issues arise with the derivation chain
