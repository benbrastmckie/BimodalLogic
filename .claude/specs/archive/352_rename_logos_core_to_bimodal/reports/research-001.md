# Research Report: Task #352

**Task**: Rename Logos/Core/ to Bimodal/
**Date**: 2026-01-10
**Focus**: Directory restructuring and import path migration

## Summary

The task involves moving `Logos/Core/` to a new top-level `Bimodal/` directory, establishing the bimodal TM logic implementation as an independent project. This requires updating ~100+ files with import references, modifying the lakefile.lean to add a new library target, and ensuring the build system compiles correctly.

## Findings

### Current Directory Structure

The `Logos/Core/` directory contains the complete bimodal TM logic implementation:

```
Logos/Core/
├── Core.lean              # Main re-export module
├── Syntax.lean            # Re-exports Syntax/*
├── Syntax/
│   ├── Formula.lean       # Formula type definitions
│   └── Context.lean       # Proof context structures
├── ProofSystem.lean       # Re-exports ProofSystem/*
├── ProofSystem/
│   ├── Axioms.lean        # TM axiom definitions
│   └── Derivation.lean    # Derivation tree and rules
├── Semantics.lean         # Re-exports Semantics/*
├── Semantics/
│   ├── TaskFrame.lean     # Task frame structure
│   ├── TaskModel.lean     # Task model structure
│   ├── WorldHistory.lean  # World history definitions
│   ├── Truth.lean         # Truth evaluation
│   └── Validity.lean      # Validity definitions
├── Metalogic.lean         # Re-exports Metalogic/*
├── Metalogic/
│   ├── Soundness.lean     # Soundness theorem
│   ├── SoundnessLemmas.lean
│   ├── DeductionTheorem.lean
│   └── Completeness.lean  # Completeness theorem (partial)
├── Theorems.lean          # Re-exports Theorems/*
├── Theorems/
│   ├── Perpetuity.lean    # Perpetuity principles P1-P6
│   ├── Perpetuity/        # Perpetuity submodules
│   ├── Propositional.lean
│   ├── ModalS4.lean
│   ├── ModalS5.lean
│   ├── Combinators.lean
│   └── GeneralizedNecessitation.lean
└── Automation.lean        # Re-exports Automation/*
    └── Automation/
        ├── Tactics.lean
        ├── ProofSearch.lean
        └── AesopRules.lean
```

Total: 32 Lean files in Logos/Core/

### Import Reference Analysis

Files with `import Logos.Core` or `Logos.Core.*` references:

| Category | File Count | Notes |
|----------|------------|-------|
| Logos source files | ~40 | Includes Core internal imports |
| LogosTest files | ~35 | Test files for Core modules |
| Archive files | ~8 | Example and archived proofs |
| Documentation | ~15 | MD files with code examples |
| Spec files | ~100+ | Historical task artifacts |

Key files requiring updates:
1. `Logos.lean` - Main library entry, imports `Logos.Core`
2. `Logos/Core.lean` - Re-export module (will be renamed)
3. `LogosTest/` directory - All test files import Core modules
4. `Archive/` files - Import Core for examples
5. Extension stubs (`Epistemic.lean`, `Normative.lean`, `Explanatory.lean`) - Currently reference Core in comments

### lakefile.lean Configuration

Current configuration:
```lean
@[default_target]
lean_lib Logos where
  leanOptions := #[...]

lean_lib LogosTest
lean_lib Archive
```

Changes needed:
1. Add new `lean_lib Bimodal` target
2. Either remove Core from Logos or keep as re-export layer

### Namespace Considerations

Current namespace: `Logos.Core.*`
Target namespace: `Bimodal.*`

The namespace change affects:
- All `namespace Logos.Core` declarations
- All `open Logos.Core` statements
- Documentation references

### Extension Layer Dependencies

The extension layers (Epistemic, Normative, Explanatory) currently:
- Are placeholder stubs with minimal content
- Reference `Logos.Core.Syntax.Formula` in comments
- Will need to be updated to import from either `Bimodal` or a new Logos integration layer

### Test Files

Test files in `LogosTest/Core/` mirror the Core structure:
- Should move to `BimodalTest/` or remain in `LogosTest/Bimodal/`
- All test imports need updating

## Recommendations

### Option 1: Full Separation (Recommended)

Create completely independent `Bimodal/` library:

1. Move `Logos/Core/` → `Bimodal/`
2. Rename namespace `Logos.Core` → `Bimodal`
3. Add `lean_lib Bimodal` to lakefile.lean
4. Create `Logos/Core.lean` that re-exports `Bimodal` for backwards compatibility
5. Move tests to `BimodalTest/` (new library) or `LogosTest/Bimodal/`
6. Keep `Logos` library as integration layer that imports Bimodal

Pros:
- Clean separation for independent development
- Bimodal can be used without Logos wrapper
- Sets pattern for future extensions

Cons:
- More import changes (~150+ files)
- Need backwards compatibility layer

### Option 2: Minimal Move

Move directory but keep Logos.Core namespace:

1. Move `Logos/Core/` → `Bimodal/`
2. Keep namespace as `Logos.Core`
3. Update lakefile to build from new location

Pros:
- Fewer changes
- No namespace migration

Cons:
- Confusing: Bimodal/ dir with Logos.Core namespace
- Doesn't achieve true independence

### Recommended Approach

**Use Option 1 (Full Separation)** with phased implementation:

**Phase 1**: Physical move
- Move `Logos/Core/` → `Bimodal/`
- Update lakefile.lean
- Create compatibility re-export in `Logos/Core.lean`

**Phase 2**: Namespace migration
- Change `namespace Logos.Core` → `namespace Bimodal`
- Update all internal imports
- Build and fix errors

**Phase 3**: External reference updates
- Update LogosTest imports
- Update Archive imports
- Update extension stubs
- Documentation updates are lower priority

**Phase 4**: Verification
- Full build (`lake build`)
- Run test suite
- Verify all modules compile

## References

- `lakefile.lean` - Build configuration
- `Logos/Core/Core.lean` - Main module structure
- `docs/research/RECURSIVE_SEMANTICS.md` - Semantic architecture
- `docs/research/LAYER_EXTENSIONS.md` - Extension layer design

## Next Steps

1. Create implementation plan with 4 phases
2. Phase 1 can be done with git mv and targeted edits
3. Phase 2-3 will require systematic find-and-replace
4. Phase 4 is verification with lake build

Estimated effort: 2-4 hours (aligns with task estimate)
