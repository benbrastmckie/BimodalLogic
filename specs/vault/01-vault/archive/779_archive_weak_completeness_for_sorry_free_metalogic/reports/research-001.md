# Research Report: Archive WeakCompleteness for Sorry-Free Metalogic

**Task**: 779
**Date**: 2026-01-30
**Session**: sess_1769740541_653f21

## Executive Summary

Archiving `WeakCompleteness.lean` will achieve **zero sorry count** in `Theories/Bimodal/Metalogic/`. The file contains the only actual sorry in the Metalogic directory (excluding `UnderDevelopment/`). However, `FiniteStrongCompleteness.lean` directly depends on `weak_completeness`, so it must be archived together. The Boneyard/Metalogic_v5 directory does not exist and should be created following the Metalogic_v4 pattern.

## Key Findings

### 1. Sorry Count Analysis

**Current sorry in Metalogic (excluding UnderDevelopment)**:
```
Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean:217:  sorry
```

This is the **ONLY** actual sorry statement. All other occurrences are in comments, docstrings, or the isolated `UnderDevelopment/` directory.

### 2. Files That Import WeakCompleteness

| File | Import Purpose | Impact of Removal |
|------|----------------|-------------------|
| `Completeness/Completeness.lean` | Module root | Just needs import removed |
| `Completeness/FiniteStrongCompleteness.lean` | Uses `weak_completeness` directly | **MUST be archived together** |
| `FMP/FiniteModelProperty.lean` | Uses `weak_completeness` in `consistent_implies_satisfiable` | **MUST be archived together** |

### 3. Dependency Analysis

#### `FiniteStrongCompleteness.lean`
- Line 1: `import Bimodal.Metalogic.Completeness.WeakCompleteness`
- Line 197: `have h_deriv := weak_completeness (impChain Gamma phi) h_valid`
- **Cannot function without `weak_completeness`** - must be archived

#### `FMP/FiniteModelProperty.lean`
- Line 2: `import Bimodal.Metalogic.Completeness.WeakCompleteness`
- Line 113: `have h_neg_deriv : ContextDerivable [] (Formula.neg phi) := weak_completeness (Formula.neg phi) h_neg_valid`
- **Also depends on `weak_completeness`** - must be archived or refactored

#### Definitions Used Elsewhere
The file also defines:
- `ContextDerivable` - Used by many files
- `Consistent` (list version) - Used by FiniteModelProperty
- `soundness` (wrapper) - Used by FiniteStrongCompleteness
- `derivable_implies_valid` - Used by provable_iff_valid

### 4. `finite_strong_completeness` Cannot Be Kept Separately

The theorem `finite_strong_completeness` depends on `weak_completeness`:
```lean
theorem finite_strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi := by
  intro h_entails
  have h_valid := entails_imp_chain Gamma phi h_entails
  have h_deriv := weak_completeness (impChain Gamma phi) h_valid  -- HERE
  exact imp_chain_to_context Gamma phi h_deriv
```

**There is no way to keep `finite_strong_completeness` without the sorry.**

### 5. Existing Boneyard Structure

**Boneyard/Metalogic_v4 exists** with this structure:
```
Boneyard/Metalogic_v4/
├── README.md                       # Detailed archival explanation
├── TaskRelation.lean               # 5 sorries
├── CoherentConstruction.lean       # 8 sorries
├── TruthLemma.lean                 # 4 sorries
├── CanonicalHistory.lean           # Depends on sorried code
├── UniversalCanonicalModel.lean    # Depends on sorried code
├── InfinitaryStrongCompleteness.lean
└── Compactness.lean
```

Additionally, there's a separate FMP archive at `Boneyard/Metalogic_v4/FMP/` (at project root):
```
Boneyard/Metalogic_v4/FMP/
├── README.md
├── SemanticCanonicalFrame.lean
├── TruthLemmaGap.lean
└── FiniteModelPropertyConstructive.lean
```

**Boneyard/Metalogic_v5 does NOT exist** - must be created.

### 6. Impact Analysis

#### What Will Be Archived

| File | Theorems/Defs Lost | Sorry-Free Alternative |
|------|-------------------|------------------------|
| WeakCompleteness.lean | `weak_completeness`, `provable_iff_valid` | `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean) |
| FiniteStrongCompleteness.lean | `finite_strong_completeness`, `context_provable_iff_entails` | None for List contexts; use Set-based approach |
| FiniteModelProperty.lean | `consistent_implies_satisfiable`, `finite_model_property` | Refactor to not use weak_completeness |

#### What Will Be Preserved

The sorry-free completeness remains via:
```lean
-- In FMP/SemanticCanonicalModel.lean (sorry-free)
theorem semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

### 7. Refactoring Option for FiniteModelProperty.lean

Instead of archiving `FiniteModelProperty.lean`, it could be refactored:
1. Keep the structural FMP theorem (identity witness)
2. Remove `consistent_implies_satisfiable` (depends on weak_completeness)
3. Keep `satisfiability_decidable` and `validity_decidable_via_fmp` (use Classical.dec)

This would preserve useful infrastructure while removing the sorry dependency.

## Recommended Implementation Plan

### Phase 1: Create Archive Structure
```bash
mkdir -p Theories/Bimodal/Boneyard/Metalogic_v5/Completeness
```

### Phase 2: Move Files to Archive
1. Move `WeakCompleteness.lean` to `Boneyard/Metalogic_v5/Completeness/`
2. Move `FiniteStrongCompleteness.lean` to `Boneyard/Metalogic_v5/Completeness/`
3. Create comprehensive `Boneyard/Metalogic_v5/README.md` explaining the archival

### Phase 3: Update Completeness.lean
Remove WeakCompleteness and FiniteStrongCompleteness imports:
```lean
-- OLD
import Bimodal.Metalogic.Completeness.WeakCompleteness
import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness

-- NEW
import Bimodal.Metalogic.Soundness.Soundness
-- (no completeness imports - use FMP/SemanticCanonicalModel.lean for sorry-free completeness)
```

### Phase 4: Refactor FiniteModelProperty.lean
Option A (full archive): Move to Boneyard/Metalogic_v5/FMP/
Option B (recommended): Refactor to remove weak_completeness dependency:
- Keep `finite_model_property` (identity witness, no sorry)
- Remove `consistent_implies_satisfiable` (uses weak_completeness)
- Keep decidability theorems (use Classical.dec)

### Phase 5: Relocate Definitions
The definitions `ContextDerivable`, `Consistent`, `soundness`, `derivable_implies_valid` need new homes:
- `ContextDerivable` -> `Core/Provability.lean` or `Core/DeductionTheorem.lean`
- `Consistent` -> `Core/Basic.lean` (if not already there)
- `soundness` wrapper -> `Soundness/Soundness.lean`
- `derivable_implies_valid` -> `Soundness/Soundness.lean`

### Phase 6: Verify Build
```bash
lake build Bimodal.Metalogic
```
Confirm zero sorry count with:
```bash
grep -rn "^\s*sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v UnderDevelopment
# Should return empty
```

## Files to Archive

| Source Path | Archive Path |
|-------------|--------------|
| `Metalogic/Completeness/WeakCompleteness.lean` | `Boneyard/Metalogic_v5/Completeness/WeakCompleteness.lean` |
| `Metalogic/Completeness/FiniteStrongCompleteness.lean` | `Boneyard/Metalogic_v5/Completeness/FiniteStrongCompleteness.lean` |
| (optionally) `Metalogic/FMP/FiniteModelProperty.lean` | `Boneyard/Metalogic_v5/FMP/FiniteModelProperty.lean` |

## Files to Update

| File | Changes Required |
|------|------------------|
| `Metalogic/Completeness/Completeness.lean` | Remove imports, update docstring |
| `Metalogic/FMP/FiniteModelProperty.lean` | Remove weak_completeness dependency OR archive |
| `Metalogic/Metalogic.lean` | Update module documentation |
| `Metalogic/README.md` | Update architecture documentation |
| `Metalogic/FMP/README.md` | Update if FiniteModelProperty changes |
| `Metalogic/Completeness/README.md` | Update to reflect archived content |

## Definitions to Relocate

| Definition | From | To |
|------------|------|-----|
| `ContextDerivable` | WeakCompleteness.lean | Core/Provability.lean |
| `Consistent` | WeakCompleteness.lean | Core/Basic.lean |
| `soundness` | WeakCompleteness.lean | Soundness/Soundness.lean |
| `derivable_implies_valid` | WeakCompleteness.lean | Soundness/Soundness.lean |
| `list_consistent_implies_set_consistent` | WeakCompleteness.lean | Core/MaximalConsistent.lean or FMP/SemanticCanonicalModel.lean |

## Expected Outcome

After implementation:
- `Theories/Bimodal/Metalogic/` will have **zero sorry statements** (excluding `UnderDevelopment/`)
- Sorry-free completeness via `semantic_weak_completeness` remains available
- Archived code preserved in `Boneyard/Metalogic_v5/` with full documentation
- Build will succeed with no warnings from archived code

## References

- Task 772: Previous Metalogic archival (Metalogic_v4)
- Task 776: Refactor Metalogic to zero sorry (original goal)
- `Boneyard/Metalogic_v4/README.md`: Archival pattern to follow
- `FMP/SemanticCanonicalModel.lean`: Sorry-free completeness source
