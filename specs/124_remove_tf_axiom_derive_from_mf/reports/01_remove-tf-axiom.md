# Research Report: Remove TF Axiom and Derive from MF

**Task**: 124 — remove_tf_axiom_derive_from_mf
**Session**: sess_1778519000_9c9d89
**Date**: 2026-05-11

## 1. Current Axiom Definitions

### TF (temp_future) — Target for Removal

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 331
```lean
| temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))
```
Semantics: `□φ → G□φ` — "necessary truths will always be necessary"

### MF (modal_future) — Used in Derivation

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 328
```lean
| modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))
```
Semantics: `□φ → □Gφ` — "necessary truths remain necessary in the future"

### T (modal_t) — Used in Derivation

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 88
```lean
| modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)
```
Semantics: `□φ → φ`

### 4 (modal_4) — Used in Derivation

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`, line 91
```lean
| modal_4 (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))
```
Semantics: `□φ → □□φ`

## 2. Derivation Strategy

TF (`□φ → G□φ`) is derivable from MF + T + 4 as follows:

### Step-by-step derivation

1. **modal_4(φ)**: `□φ → □□φ`
2. **modal_future(□φ)**: `□□φ → □G□φ` (MF instantiated with `□φ`)
3. **modal_t(G□φ)**: `□G□φ → G□φ` (T instantiated with `G□φ`)
4. **Chain 1→2→3**: `□φ → □□φ → □G□φ → G□φ` = `□φ → G□φ` = TF(φ)

### Lean implementation

```lean
/-- TF is derivable from MF + T + 4: □φ → G□φ -/
def temp_future_derived (φ : Formula) :
    ⊢ (Formula.box φ).imp (Formula.all_future (Formula.box φ)) :=
  -- Step 1: □φ → □□φ (modal_4)
  let step1 := DerivationTree.axiom [] _ (Axiom.modal_4 φ)
  -- Step 2: □□φ → □G□φ (MF applied to □φ)
  let step2 := DerivationTree.axiom [] _ (Axiom.modal_future (Formula.box φ))
  -- Step 3: □G□φ → G□φ (T applied to G□φ)
  let step3 := DerivationTree.axiom [] _ (Axiom.modal_t (Formula.all_future (Formula.box φ)))
  -- Chain: □φ → □□φ → □G□φ → G□φ
  Combinators.imp_trans (Combinators.imp_trans step1 step2) step3
```

This uses `Bimodal.Theorems.Combinators.imp_trans` for chaining (file: `Theories/Bimodal/Theorems/Combinators.lean`, line 83).

## 3. Complete File Impact Analysis

### Core files requiring structural changes

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `ProofSystem/Axioms.lean` | 331 | Constructor definition | **Remove** `temp_future` constructor |
| `ProofSystem/Axioms.lean` | 33, 35, 63 | Doc comments | Update axiom count (45→44) and lists |
| `ProofSystem/Axioms.lean` | 400-432 | `frameClass`, `isBase`, etc. | No change (wildcard patterns handle removal) |
| `ProofSystem/Derivation.lean` | (none) | — | No change needed |
| `ProofSystem/Substitution.lean` | 370-372 | Match arm in `axiom_subst` | **Remove** `temp_future` match arm |
| `ProofSystem.lean` | 17, 32 | Doc comments | Update text |

### Soundness infrastructure

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Metalogic/Soundness.lean` | 267-273 | `temp_future_valid` theorem | **Remove** (no longer needed as axiom) |
| `Metalogic/Soundness.lean` | 999 | `axiom_base_valid` match arm | **Remove** |
| `Metalogic/Soundness.lean` | 1051 | `axiom_valid_dense` match arm | **Remove** |
| `Metalogic/Soundness.lean` | 1104 | `axiom_valid_discrete` match arm | **Remove** |
| `Metalogic/Soundness.lean` | 1211 | `soundness_dense` match arm | **Remove** |
| `Metalogic/Soundness.lean` | 1387 | `soundness_discrete_valid` match arm | **Remove** |
| `Metalogic/Soundness.lean` | 18-19, 34, 43, 48 | Doc comments | Update text |
| `Metalogic/SoundnessLemmas.lean` | 393-399 | `swap_axiom_tf_valid` | **Remove** (no longer needed) |
| `Metalogic/SoundnessLemmas.lean` | 836 | Match arm in swap validity | **Remove** |
| `Metalogic/SoundnessLemmas.lean` | 1045, 1420, 2223 | `axiom_temp_future_valid`, match arms | **Remove** |
| `Metalogic/SoundnessLemmas.lean` | 1918 | Match arm in discrete swap | **Remove** |
| `Metalogic/SoundnessLemmas.lean` | 51, 215, 385, 484 | Doc comments | Update text |

### Frame conditions

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `FrameConditions/Compatibility.lean` | 156-157 | `AxiomLinearCompatible` instance | **Remove** |
| `FrameConditions/Compatibility.lean` | 31 | Doc comment | Update list |
| `FrameConditions/Soundness.lean` | 174 | Doc comment | Update text |

### Algebraic completeness infrastructure

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Metalogic/Algebraic/TenseS5Algebra.lean` | 104-105 | STSA field `TF` | **Change**: derive TF field from MF + T + 4 (keep the field, derive the proof differently) |
| `Metalogic/Algebraic/TenseS5Algebra.lean` | 174-178 | `TF_quot` theorem | **Update**: use `temp_future_derived` instead of `Axiom.temp_future` |
| `Metalogic/Algebraic/TenseS5Algebra.lean` | 347 | Instance field `TF := TF_quot` | No change (still uses TF_quot, which changes internally) |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 154-165 | `past_tf_deriv` | **Update**: use `temp_future_derived` instead of `Axiom.temp_future` |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 180-182 | `parametric_box_persistent` | **Update**: use `temp_future_derived` instead of `Axiom.temp_future` |

### Automation

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Automation/ProofSearch.lean` | 360-362 | `temp_future` pattern match | **Update**: derive TF pattern via proof term instead of axiom |
| `Automation/ProofSearch.lean` | 381 | Boolean combination | **Update**: remove `temp_future` from disjunction |
| `Automation/ProofSearch.lean` | 456-461 | `matchAxiom` match for TF | **Update**: return derived proof instead of `Axiom.temp_future` |
| `Automation/Tactics.lean` | 623 | Tactic axiom list | **Update**: replace `Axiom.temp_future` with derived term, or remove and add a custom tactic for TF pattern |
| `Automation/AesopRules.lean` | 34 | Doc comment | Update text |

### BX Canonical Model / Completeness

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Metalogic/BXCanonical/CanonicalModel.lean` | 332, 358 | Direct `Axiom.temp_future` usage | **Replace** with `temp_future_derived` |
| `Metalogic/BXCanonical/Frame.lean` | 598, 617 | Direct `Axiom.temp_future` usage | **Replace** with `temp_future_derived` |
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 323, 353, 420 | Direct `Axiom.temp_future` usage | **Replace** with `temp_future_derived` |

### Conservative Extension

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 61-62 | `ExtAxiom.temp_future` constructor | **Remove** and add derived form |
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | 123 | Embedding match arm | **Remove** |
| `Metalogic/ConservativeExtension/Lifting.lean` | 207, 235, 475 | Match arms | **Remove** all three |
| `Metalogic/ConservativeExtension/Substitution.lean` | 204 | Match arm | **Remove** |

### Theorems and examples

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `Theorems/Perpetuity/Principles.lean` | 642 | `Axiom.temp_future φ.diamond` | **Replace** with `temp_future_derived` applied to `φ.diamond` |
| `Theorems/Perpetuity/Principles.lean` | 788, 795 | `Axiom.temp_future` usage | **Replace** with `temp_future_derived` |
| `Examples/BimodalProofStrategies.lean` | 224, 244, 284, 307, 366 | `Axiom.temp_future` usage | **Replace** all with `temp_future_derived` |
| `Examples/TemporalProofs.lean` | 238, 246 | `Axiom.temp_future` usage | **Replace** with `temp_future_derived` |

### Additional files (doc comment only)

| File | Line(s) | Reference Type | Change Required |
|------|---------|---------------|-----------------|
| `ProofSystem/LinearityDerivedFacts.lean` | 16 | Doc comment listing axioms | Update text |
| `Semantics/Truth.lean` | 255, 691 | Doc comments mentioning TF | Update text |
| `Semantics/Validity.lean` | 63 | Doc comment mentioning TF | Update text |
| `Semantics/WorldHistory.lean` | 215 | Doc comment mentioning TF | Update text |
| `Theorems/Perpetuity.lean` | 41 | Doc comment listing TF | Update text |
| `Theorems/Perpetuity/Bridge.lean` | 953 | Doc comment mentioning TF | Update text |

### Boneyard files (archived / legacy)

These files in `Boneyard/` also reference `Axiom.temp_future` but are archived legacy code:
- `Boneyard/QuasimodelOracle/OracleCoherence.lean` (lines 242, 264)
- `Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean` (lines 359, 377)
- `Boneyard/DefectDirectedChain/RootScopedChain.lean` (lines 747, 769)
- `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` (lines 402, 426)
- `Boneyard/StrictSemanticsLegacy/Algebraic/UltrafilterChain.lean` (lines 2048, 2062)

**Recommendation**: Update these too for compilation, but they are low priority.

## 4. Key Design Decisions

### Where to place `temp_future_derived`

**Recommended**: Create the derivation in `Theories/Bimodal/Theorems/TemporalDerived.lean` (already exists for derived temporal theorems). This keeps the proof system's axiom file clean while making TF available project-wide.

If `TemporalDerived.lean` imports are too heavy, a lighter alternative is to place it directly in a new section of `Theorems/Combinators.lean` since it only uses `imp_trans`, `Axiom.modal_4`, `Axiom.modal_future`, and `Axiom.modal_t`.

### TenseS5Algebra handling

The `STSA` class has a field `TF : forall a, box a <= G (box a)`. This is an algebraic property of the algebra, not a proof system axiom. The field should remain in the class definition. The instance proof (`TF := TF_quot`) just changes internally from using `Axiom.temp_future` to using `temp_future_derived`.

### Conservative Extension handling

The `ExtAxiom` type mirrors `Axiom`. If `temp_future` is removed from `Axiom`, it should also be removed from `ExtAxiom`. The embedding function and lifting functions will need corresponding match arm removals.

### Automation impact

The `ProofSearch.lean` file has a `matchAxiom` function that pattern-matches formulas to return `Axiom` witnesses. Since `temp_future` is no longer a constructor, the TF pattern (`□φ → G□φ`) needs special handling:
- **Option 1**: Detect the pattern and return the derivation tree directly (bypassing the Axiom witness)
- **Option 2**: Keep TF detection in `isAxiomLike` but route to the derived proof in `matchAxiom`
- **Recommended**: Option 2 — keep the `temp_future` boolean check in `isAxiomLike` for efficiency, and in `matchAxiom` construct the derivation tree using `temp_future_derived`. This requires changing the return type or wrapping in a helper.

Actually, looking more carefully at `matchAxiom`, it returns `Option (Σ φ, Axiom φ)`. Since TF is no longer an axiom, the function cannot return it as an Axiom. The cleanest approach: add a parallel function or modify the proof search to handle derived theorems alongside axioms. The `Tactics.lean` axiom list (`axiomCtors`) also needs updating.

### Downstream usage pattern

All downstream usages follow one of two patterns:
1. `DerivationTree.axiom [] _ (Axiom.temp_future φ)` — direct axiom invocation
2. `Axiom.temp_future φ` in match arms — exhaustive pattern matching

For pattern 1, replace with `temp_future_derived φ` (which produces the same type `⊢ (Formula.box φ).imp (Formula.all_future (Formula.box φ))`).

For pattern 2, simply remove the match arm.

## 5. Risk Assessment

### Low Risk
- Removing the constructor and match arms: mechanical, compiler-guided
- Updating downstream usages: pattern replacement, same types
- Doc comment updates: no compilation impact

### Medium Risk
- **Automation**: The proof search and tactic machinery needs careful updating. The `matchAxiom` function's type signature assumes it returns axiom witnesses. A derived theorem has a different construction.
- **Conservative Extension**: The `ExtAxiom` type mirrors `Axiom` and needs synchronized changes. Three files in ConservativeExtension/ need updates.

### High Risk
- **None identified**. The derivation is straightforward (3 steps using existing axioms), and all downstream usages are simple replacements.

## 6. Implementation Recommendations

### Phase 1: Create the derivation (no breaking changes)
1. Add `temp_future_derived` to `Theorems/TemporalDerived.lean`
2. Verify it compiles and has the correct type signature

### Phase 2: Remove axiom and update core
1. Remove `temp_future` from `Axiom` inductive in `Axioms.lean`
2. Remove from `Substitution.lean` match arm
3. Remove from `Soundness.lean` (theorem + all 5 match arms)
4. Remove from `SoundnessLemmas.lean` (`swap_axiom_tf_valid`, `axiom_temp_future_valid`, all match arms)
5. Remove from `FrameConditions/Compatibility.lean` instance

### Phase 3: Update downstream references
1. Replace all `DerivationTree.axiom [] _ (Axiom.temp_future ...)` with `temp_future_derived ...`
   - `Perpetuity/Principles.lean` (3 occurrences)
   - `Algebraic/ParametricTruthLemma.lean` (2 occurrences)
   - `Algebraic/TenseS5Algebra.lean` (1 occurrence)
   - `BXCanonical/CanonicalModel.lean` (2 occurrences)
   - `BXCanonical/Frame.lean` (2 occurrences)
   - `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (3 occurrences)
   - `Examples/BimodalProofStrategies.lean` (5 occurrences)
   - `Examples/TemporalProofs.lean` (2 occurrences)

### Phase 4: Update Conservative Extension
1. Remove `ExtAxiom.temp_future` from `ExtDerivation.lean`
2. Remove match arms in `Lifting.lean` (3 places) and `Substitution.lean` (1 place)

### Phase 5: Update Automation
1. Update `ProofSearch.lean`: remove `temp_future` from `isAxiomLike`, update `matchAxiom`
2. Update `Tactics.lean`: remove `Axiom.temp_future` from `axiomCtors` list

### Phase 6: Update Boneyard
1. Replace `Axiom.temp_future` in all 5 Boneyard files (10 occurrences)

### Phase 7: Update documentation
1. Update doc comments in approximately 15 files
2. Update axiom count from 45 to 44

### Total file count: ~30 files (non-Boneyard: ~25 files)
