# Research Report: Verification of fmp_weak_completeness Axiom/Sorry Status

**Task**: 854 - Bimodal metalogic audit and cleanup
**Focus**: Verify fmp_weak_completeness is truly axiom-free and sorry-free transitively
**Date**: 2026-02-04
**Report Version**: 005

## Executive Summary

**VERIFIED**: The `fmp_weak_completeness` theorem is **sorry-free** and uses only **standard Lean axioms** in its complete transitive dependency chain. The claim that this theorem establishes completeness without custom axioms or sorries is **confirmed** and suitable for publication claims.

## Theorem Details

### Location
```
Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
```

### Signature
```lean
noncomputable def fmp_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

### Axiom Dependencies (from `#print axioms`)
```
'Bimodal.Metalogic.FMP.fmp_weak_completeness' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

These are **standard Lean axioms**, not custom project axioms:
- `propext` - Propositional extensionality
- `Classical.choice` - Axiom of choice (needed for classical logic)
- `Quot.sound` - Quotient soundness

## Verification Methodology

### 1. Direct Build Verification
```bash
lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel
# Result: Build completed successfully (952 jobs)
```

### 2. Axiom Trace Analysis
Used Lean's `#print axioms` command to trace all axioms in the transitive closure:

| Dependency | Axioms Used |
|------------|-------------|
| `fmp_weak_completeness` | propext, Classical.choice, Quot.sound |
| `neg_set_consistent_of_not_provable` | propext, Classical.choice, Quot.sound |
| `worldStateFromClosureMCS` | propext, Classical.choice, Quot.sound |
| `worldStateFromClosureMCS_not_models` | propext, Classical.choice, Quot.sound |
| `mcs_projection_is_closure_mcs` | propext, Classical.choice, Quot.sound |
| `set_lindenbaum` | propext, Classical.choice, Quot.sound |
| `set_mcs_neg_excludes` | propext |
| `soundness` | propext, Classical.choice, Quot.sound |

**None of these depend on `sorryAx`** (the sorry axiom).

### 3. Sorry Presence Check
Searched for `sorry` in the FMP module files:

| File | Sorry Count | Impact on fmp_weak_completeness |
|------|-------------|--------------------------------|
| `SemanticCanonicalModel.lean` | 0 (actual) | N/A |
| `FiniteWorldState.lean` | 0 | N/A |
| `BoundedTime.lean` | 0 | N/A |
| `Closure.lean` | 1 | **NOT USED** (see below) |

### 4. Isolated Sorry Analysis
The single sorry in `Closure.lean` (line 728) is in:
```lean
theorem diamond_in_closureWithNeg_of_box (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) :
    Formula.neg (Formula.box (Formula.neg psi)) ∈ closureWithNeg phi := by
  sorry
```

**Verification that this is NOT used by fmp_weak_completeness:**
```
'Bimodal.Metalogic.FMP.diamond_in_closureWithNeg_of_box' depends on axioms:
  [propext, sorryAx, Classical.choice, Quot.sound]
```

The `sorryAx` dependency appears ONLY for this theorem, not for `fmp_weak_completeness`. This confirms the sorry is isolated and not in the transitive closure.

### 5. Custom Axiom Check
Searched for `^axiom\s` declarations in the non-Boneyard Metalogic modules:

| Location | Custom Axioms |
|----------|---------------|
| `Metalogic/FMP/*.lean` | 0 |
| `Metalogic/Core/*.lean` | 0 |
| `Metalogic/Soundness.lean` | 0 |
| `ProofSystem.lean` | 0 |
| `Semantics.lean` | 0 |
| `Theorems/Propositional.lean` | 0 |

**Note**: Custom axioms exist in `Bundle/Construction.lean` and `Bundle/CoherentConstruction.lean`, but these are NOT in the import chain of `fmp_weak_completeness`.

## Import Chain Analysis

Direct imports of `SemanticCanonicalModel.lean`:
```lean
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.FMP.FiniteWorldState
import Bimodal.Metalogic.FMP.BoundedTime
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.Propositional
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finite.Defs
```

**Key observation**: The module does NOT import `Bundle/` modules, which contain the custom axioms. The FMP approach is completely independent.

## Comparison with Bundle Approach

| Approach | Sorry Status | Custom Axioms |
|----------|--------------|---------------|
| **FMP (SemanticCanonicalModel)** | SORRY-FREE | NONE |
| Bundle (Completeness) | SORRY-FREE | `singleFamily_modal_backward_axiom`, `saturated_extension_exists`, `weak_saturated_extension_exists` |

The FMP approach via `fmp_weak_completeness` provides a cleaner completeness result with no custom axioms.

## Publication Readiness

### Safe Claims

1. "The completeness theorem (`fmp_weak_completeness`) is proven without sorries."
2. "The proof uses only standard Lean axioms (propext, Classical.choice, Quot.sound)."
3. "No custom axioms are required for the FMP-based completeness result."

### Caveats

1. The theorem is `noncomputable` (uses Classical.choice).
2. The module file contains one sorry in `diamond_in_closureWithNeg_of_box`, but this is NOT used by the completeness theorem.
3. Other modules (Bundle/*) contain custom axioms for an alternative completeness approach.

## Recommendations

1. **For publication**: Use `fmp_weak_completeness` as the primary completeness result.
2. **Documentation**: Note that `diamond_in_closureWithNeg_of_box` is dead code with a sorry - consider removing or archiving.
3. **Boneyard cleanup**: The sorry-containing `diamond_in_closureWithNeg_of_box` could be moved to Boneyard if not needed.

## Conclusion

The verification confirms that `fmp_weak_completeness`:
- Compiles successfully with no errors
- Does NOT depend on `sorryAx`
- Uses only standard Lean axioms
- Is NOT affected by the isolated sorry in Closure.lean
- Is independent of the Bundle approach's custom axioms

**The completeness claim is publication-ready.**
