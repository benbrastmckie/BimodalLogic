# Research Report: Task #355

**Task**: Fix all Lean build errors for the Bimodal/ theory
**Date**: 2026-01-11
**Focus**: Build error analysis and fix strategy

## Summary

The Bimodal/ theory has ~150 build errors primarily located in 7 example files under `Bimodal/Examples/`. The errors fall into 3 main categories: (1) incorrect type name usage (`Derivable` vs `DerivationTree`), (2) missing namespace qualifications for helper lemmas, and (3) missing `noncomputable` markers for definitions depending on noncomputable perpetuity theorems.

## Findings

### Error Categories

| Category | Count | Description |
|----------|-------|-------------|
| `Derivable.axiom` → `DerivationTree.axiom` | ~50 | Wrong type name |
| `Derivable.modus_ponens` → `DerivationTree.modus_ponens` | ~10 | Wrong type name |
| `Derivable.modal_k` → `DerivationTree.necessitation` + axiom | ~5 | Wrong pattern |
| `Derivable.temporal_duality` → `DerivationTree.temporal_duality` | ~10 | Wrong type name |
| `Derivable.assumption` → `DerivationTree.assumption` | ~2 | Wrong type name |
| `imp_trans` not found | ~15 | Missing open or namespace |
| `identity` not found | ~5 | Missing open or namespace |
| `combine_imp_conj*` not found | ~5 | Missing open or namespace |
| `noncomputable` missing | ~10 | Depends on noncomputable perpetuity |
| `Automation.ProofSearch` not found | ~20 | Module doesn't export expected names |

### Affected Files

All errors are in the Examples directory (formerly Archive/):

1. **Bimodal/Examples/ModalProofStrategies.lean** - ~35 errors
2. **Bimodal/Examples/ModalProofs.lean** - ~40 errors
3. **Bimodal/Examples/TemporalProofStrategies.lean** - ~35 errors
4. **Bimodal/Examples/TemporalProofs.lean** - ~25 errors
5. **Bimodal/Examples/BimodalProofStrategies.lean** - ~30 errors
6. **Bimodal/Examples/BimodalProofs.lean** - ~35 errors
7. **Bimodal/Examples/TemporalStructures.lean** - May have errors too

### Root Causes

1. **Type Naming**: The proof system type is `DerivationTree`, not `Derivable`. The examples used `Derivable.axiom`, `Derivable.modus_ponens`, etc., but should use `DerivationTree.axiom`, `DerivationTree.modus_ponens`, etc.

2. **Namespace Resolution**: Helper lemmas like `imp_trans`, `identity`, `combine_imp_conj` are defined in `Bimodal.Theorems.Combinators` but the examples only open `Bimodal.Theorems.Perpetuity`. Need to also `open Bimodal.Theorems.Combinators`.

3. **Noncomputable Definitions**: Several perpetuity theorems (`perpetuity_5`, `perpetuity_6`) are `noncomputable`. Example definitions using these need `noncomputable` marker.

4. **ProofSearch Module**: Examples import `Bimodal.Automation.ProofSearch` but reference identifiers like `Automation.ProofSearch.bounded_search` that may not exist or have different names.

### Existing Definitions (Verified in Codebase)

| Identifier | Location | Type |
|------------|----------|------|
| `imp_trans` | Bimodal/Theorems/Combinators.lean | def |
| `identity` | Bimodal/Theorems/Combinators.lean | def |
| `mp` | Bimodal/Theorems/Combinators.lean | def |
| `combine_imp_conj` | Bimodal/Theorems/Combinators.lean | (if exists) |
| `DerivationTree.axiom` | Bimodal/ProofSystem/Derivation.lean | constructor |
| `DerivationTree.modus_ponens` | Bimodal/ProofSystem/Derivation.lean | constructor |
| `DerivationTree.necessitation` | Bimodal/ProofSystem/Derivation.lean | constructor |
| `DerivationTree.temporal_duality` | Bimodal/ProofSystem/Derivation.lean | constructor |
| `DerivationTree.assumption` | Bimodal/ProofSystem/Derivation.lean | constructor |

## Recommendations

### Fix Strategy

1. **Global Replace `Derivable.` → `DerivationTree.`**: Replace all occurrences of `Derivable.axiom`, `Derivable.modus_ponens`, etc. with the correct `DerivationTree.*` constructors.

2. **Add Missing Opens**: Add `open Bimodal.Theorems.Combinators` to files using `imp_trans`, `identity`, etc.

3. **Add `noncomputable` Markers**: Add `noncomputable` before definitions that depend on noncomputable perpetuity theorems.

4. **ProofSearch References**: Either:
   - a) Comment out/remove ProofSearch-related examples if the API changed
   - b) Update to correct API if it exists with different names
   - c) Mark as `sorry` if ProofSearch is incomplete (Task 260 is BLOCKED)

### Effort Estimate

- Replace `Derivable.` → `DerivationTree.`: ~20 minutes (batch find/replace)
- Add missing opens: ~10 minutes (6-7 files)
- Add noncomputable markers: ~10 minutes
- Fix ProofSearch references: ~30 minutes (may need API investigation)

**Total**: ~1-2 hours

## References

- Bimodal/ProofSystem/Derivation.lean - Defines `DerivationTree` type
- Bimodal/Theorems/Combinators.lean - Defines helper lemmas
- .claude/specs/352_rename_logos_core_to_bimodal/summaries/implementation-summary-20260110.md - Notes pre-existing issues

## Next Steps

1. Create implementation plan with phased fixes
2. Fix type name errors first (highest count)
3. Add missing opens/noncomputable
4. Handle ProofSearch issues (may need separate approach)
5. Verify clean build
