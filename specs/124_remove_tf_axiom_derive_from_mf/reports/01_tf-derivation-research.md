# Research Report: Remove TF Axiom and Derive from MF

**Task**: 124
**Status**: Research Complete
**Date**: 2026-05-11

## 1. Background

The TF axiom (`temp_future`: `□φ → G(□φ)`) is currently a primitive axiom constructor in the `Axiom` inductive type. The MF axiom (`modal_future`: `□φ → □(Gφ)`) is a separate primitive. The task is to remove TF as primitive and derive it from MF + T + Modal 4.

## 2. Derivation Proof

TF is derivable from MF, Modal T, and Modal 4:

1. **MF** (modal_future): `□φ → □(Gφ)` (any φ)
2. **T** (modal_t) at `Gφ`: `□(Gφ) → Gφ`
3. **Chain** (imp_trans): `□φ → Gφ` (intermediate lemma)
4. **Instantiate step 3** with `φ := □φ`: `□(□φ) → G(□φ)`
5. **Modal 4**: `□φ → □(□φ)`
6. **Chain** (imp_trans): `□φ → G(□φ)` = **TF** ✓

This uses `imp_trans` from `Theorems/Combinators.lean:83`.

## 3. Impact Analysis

### 3.1 Axiom Constructor (Axioms.lean)

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean:328-331`

Remove:
```lean
| temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))
```

Update axiom count in docstring: 45 → 44 constructors. Update Layer 4 comment: "Modal-Temporal Interaction (2)" → "(1)".

### 3.2 New Derived Theorem

Add a new theorem (suggested location: `Theorems/Combinators.lean` or a new file `Theorems/ModalTemporal.lean`):

```lean
def temp_future_derived (φ : Formula) :
    ⊢ (Formula.box φ).imp (Formula.all_future (Formula.box φ)) :=
  let mf_box := DerivationTree.axiom [] _ (Axiom.modal_future (Formula.box φ))  -- □(□φ) → □(G(□φ))
  let t_G_box := DerivationTree.axiom [] _ (Axiom.modal_t (Formula.all_future (Formula.box φ)))  -- □(G(□φ)) → G(□φ)
  let chain1 := imp_trans mf_box t_G_box  -- □(□φ) → G(□φ)
  let m4 := DerivationTree.axiom [] _ (Axiom.modal_4 φ)  -- □φ → □(□φ)
  imp_trans m4 chain1  -- □φ → G(□φ)
```

### 3.3 Files Requiring Changes

**Core files (Theories/)**:

| File | Occurrences | Change Required |
|------|-------------|-----------------|
| `ProofSystem/Axioms.lean` | 2 | Remove `temp_future` constructor + update docs |
| `ProofSystem/Substitution.lean` | 2 | Remove `temp_future` match arm |
| `Metalogic/Soundness.lean` | 7 | Remove `temp_future_valid`, remove 5 match arms |
| `Metalogic/SoundnessLemmas.lean` | 6 | Remove `axiom_temp_future_valid`, remove match arms, remove `swap_axiom_tf_valid` |
| `Metalogic/BXCanonical/Frame.lean` | 7 | Replace `Axiom.temp_future φ` with `temp_future_derived φ` (3 proof uses + 4 comments) |
| `Metalogic/BXCanonical/CanonicalModel.lean` | 4 | Replace `Axiom.temp_future` with `temp_future_derived` |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 7 | Replace `Axiom.temp_future` with `temp_future_derived` |
| `Metalogic/Algebraic/TenseS5Algebra.lean` | 1 | Replace in `TF_quot` |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 2 | Replace in `past_tf_deriv` and `parametric_box_persistent` |
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 2 | Remove `temp_future` from ExtAxiom, update embedAxiom |
| `Metalogic/ConservativeExtension/Lifting.lean` | 3 | Remove match arms |
| `Metalogic/ConservativeExtension/Substitution.lean` | 1 | Remove match arm |
| `FrameConditions/Compatibility.lean` | 3 | Remove `AxiomLinearCompatible` instance |
| `FrameConditions/Soundness.lean` | 1 | Update comment |
| `ProofSystem/LinearityDerivedFacts.lean` | 1 | Update comment |
| `Automation/ProofSearch.lean` | 4 | Replace axiom matching with derived call |
| `Automation/Tactics.lean` | 2 | Remove `Axiom.temp_future` from tactic list |
| `Automation/AesopRules.lean` | 1 | Update comment |
| `Theorems/Perpetuity/Principles.lean` | 3 | Replace `Axiom.temp_future` with `temp_future_derived` |
| `Examples/BimodalProofStrategies.lean` | 6 | Replace references |
| `Examples/TemporalProofs.lean` | 2 | Replace references |

**Test files (Tests/)**:

| File | Occurrences | Change Required |
|------|-------------|-----------------|
| `BimodalTest/ProofSystem/AxiomsTest.lean` | 2 | Remove/update tests |
| `BimodalTest/ProofSystem/DerivationTest.lean` | 1 | Update test |
| `BimodalTest/ProofSystem/DerivationPropertyTest.lean` | 1 | Update reference |
| `BimodalTest/Integration/BimodalIntegrationTest.lean` | 7 | Replace `Axiom.temp_future` |
| `BimodalTest/Integration/ComplexDerivationTest.lean` | 1 | Replace reference |
| `BimodalTest/Integration/ProofSystemSemanticsTest.lean` | 1 | Replace reference |
| `BimodalTest/Automation/TacticsTest.lean` | 6 | Update tactic tests |
| `BimodalTest/Automation/EdgeCaseTest.lean` | 1 | Update reference |
| `BimodalTest/Automation/ProofSearchTest.lean` | 5 | Update search tests |

**Boneyard files** (lower priority, may contain `sorry`):

| File | Occurrences |
|------|-------------|
| `Boneyard/QuasimodelOracle/OracleCoherence.lean` | 2 |
| `Boneyard/DefectDirectedChain/RootScopedChain.lean` | 2 |
| `Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` | 14 |
| `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` | 2 |
| `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean` | 6 |

### 3.4 Critical Downstream Impacts

**Completeness proof** (BXCanonical/): The `box_preserved_along_bx_le` theorem in Frame.lean and `box_stable_in_int_chain` in CanonicalModel.lean both use `Axiom.temp_future` directly. These are the most critical call sites — they prove that box formulas are stable along the canonical order, which is essential for completeness. The change is mechanical: replace `DerivationTree.axiom [] _ (Axiom.temp_future φ)` with `temp_future_derived φ`.

**Soundness proof**: The `temp_future_valid` theorem and all match arms in `axiom_valid`, `axiom_valid_dense`, `axiom_valid_discrete`, `axiom_valid_univ_sc`, and `axiom_valid_disc_sc` can be fully deleted. Soundness of TF is now inherited from soundness of MF + T + Modal 4.

**ConservativeExtension**: The ExtAxiom mirror type also has `temp_future`. It should either be removed (if TF derivability extends to ExtAxiom) or kept as a derived lemma. Since the ConservativeExtension module provides an independent axiom mirror, removing it requires adding `ext_temp_future_derived` or proving the embedding still works.

**ProofSearch/Tactics**: The automation currently pattern-matches on `Axiom.temp_future` to find applicable axioms. After removal, the proof search needs to find TF as a derived theorem. The simplest approach: keep `temp_future_derived` accessible and add it to the proof search table as a "derived axiom" lookup.

## 4. Risk Assessment

**Low risk**: The derivation is straightforward (3 axioms + 2 imp_trans chains). All call sites use temp_future purely as `DerivationTree.axiom [] _ (Axiom.temp_future φ)`, which can be mechanically replaced with `temp_future_derived φ`.

**Medium risk**: The ConservativeExtension module mirrors the axiom type — removing temp_future from both requires coordinated changes to embedAxiom, ExtAxiom, and lifting theorems.

**Low risk**: Soundness changes are purely deletive (removing match arms and theorems).

## 5. Suggested Implementation Strategy

**Phase 1**: Add `temp_future_derived` theorem.
**Phase 2**: Replace all `Axiom.temp_future` proof usages with `temp_future_derived`.
**Phase 3**: Remove `temp_future` from `Axiom` inductive type.
**Phase 4**: Remove soundness theorems/match arms.
**Phase 5**: Update ConservativeExtension (ExtAxiom, embedAxiom, lifting).
**Phase 6**: Update automation (ProofSearch, Tactics).
**Phase 7**: Update tests and examples.
**Phase 8**: Update docstrings and comments.

## 6. Open Questions

1. **Naming**: Should the derived theorem be `temp_future_derived` or just `temp_future`? Using `temp_future` (as a `def` or `theorem` rather than axiom constructor) preserves backward compatibility at call sites.

2. **ConservativeExtension**: Should ExtAxiom also lose `temp_future`? If so, the embedAxiom function and all three lifting theorems need simultaneous update.

3. **Perpetuity module**: The perpetuity module's `box_diamond_to_future_box_diamond` and `box_diamond_to_past_box_diamond` use TF directly. These are simple replacements but are in a critical proof chain (P5 and P6).
