# Implementation Summary: Remove TF Axiom and Derive from MF

- **Task**: 124
- **Status**: Implemented
- **Date**: 2026-05-13
- **Session**: sess_1778694085_eb2fe3

## What Changed

Removed the `temp_future` constructor from the `Axiom` inductive type (reducing from 45 to 44 axiom constructors) and replaced it with a derived theorem `temp_future_derived` that proves TF (`□φ → G□φ`) from MF + T + Modal 4.

### Derivation Chain

```
Modal 4:  □φ → □□φ
MF(□φ):   □□φ → □G□φ
T(G□φ):   □G□φ → G□φ
────────────────────
TF:       □φ → G□φ     (via two imp_trans applications)
```

## Files Modified

### Phase 1: Add Derived Theorem (1 file)
- `Theories/Bimodal/Theorems/Combinators.lean` -- Added `temp_future_derived`

### Phase 2: Replace Proof-Site Usages (14 files)
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- 2 proof sites + 3 comments
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- 2 proof sites + 2 comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- 4 proof sites + 4 comments
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` -- 1 proof site
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- 2 proof sites
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` -- 3 proof sites
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` -- 5 proof sites + 1 comment
- `Theories/Bimodal/Examples/TemporalProofs.lean` -- 2 proof sites
- `Theories/Bimodal/Automation/ProofSearch.lean` -- Added `matchDerived` function, import, removed axiom arm
- `Theories/Bimodal/Automation/Tactics.lean` -- Added derived theorem check in `tryAxiomMatch`
- `Theories/Bimodal/Automation/AesopRules.lean` -- 1 comment
- `Theories/Bimodal/FrameConditions/Soundness.lean` -- 1 comment
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- 1 comment

### Phase 3: Remove Constructor and Clean Match Arms (5 files)
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Removed constructor, updated docs (45->44)
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- Removed match arm, added missing discrete/prior arms
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Removed `temp_future_valid` theorem and 5 match arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Removed `swap_axiom_tf_valid`, `axiom_temp_future_valid`, 4 match arms
- `Theories/Bimodal/FrameConditions/Compatibility.lean` -- Removed `AxiomLinearCompatible` instance

### Phase 4: Update ConservativeExtension (3 files)
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` -- Removed `ExtAxiom.temp_future`, updated `embedAxiom`
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` -- Removed 3 match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` -- Removed 1 match arm

### Phase 5: Update Tests (9 files)
- `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` -- Updated 2 tests
- `Tests/BimodalTest/ProofSystem/DerivationTest.lean` -- Updated 1 test
- `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` -- Updated 1 test
- `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` -- Updated 7 proof sites
- `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` -- Fixed 1 mistyped axiom reference
- `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` -- Updated 1 test
- `Tests/BimodalTest/Automation/TacticsTest.lean` -- Updated 4 tests
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` -- Updated 1 label
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` -- Updated 1 comment

## Verification

- `lake build` succeeds with zero errors
- `grep -rn "Axiom.temp_future" Theories/` returns only comments
- `grep -rn "ExtAxiom.temp_future" Theories/` returns zero matches
- No new sorries introduced in Theories/ or Tests/
- No new axioms introduced
- `temp_future_derived` is accessible from ProofSearch (via `matchDerived`) and Tactics (via `tryAxiomMatch`)

## Additional Fixes

- Added missing `discrete_symm_fwd/bwd`, `discrete_propagate_fwd/bwd`, `prior_UZ`, `prior_SZ`, and `z1` match arms to `axiom_subst` in `Substitution.lean` (pre-existing gap)
