# Boneyard

This directory contains deprecated code from the ProofChecker project. The code is preserved for historical reference and potential future exploration but is **not part of active development**.

## Structure

```
Boneyard/
  Metalogic/         # Deprecated metalogic completeness approaches
    README.md        # Detailed documentation of archived approaches
  FMP_Bridge/        # Deprecated FMP bridge code
```

There is also `Theories/Bimodal/Boneyard/` for theory-specific archived code.

## Purpose

The Boneyard serves as an archive for:

1. **Superseded approaches**: Proof strategies that were replaced by better methods
2. **Dead ends**: Approaches that hit fundamental blockers
3. **Technical debt**: Code with sorries that is no longer on the active path

## Restoration

To restore a file for exploration:

1. Copy to active location
2. Update imports to match current module structure
3. Fix any Mathlib/Lean 4 API changes

Note: Archived files may not build cleanly with current versions.

## Related Documentation

- `Boneyard/Metalogic/README.md`: Detailed docs on deprecated completeness approaches
- `Theories/Bimodal/Boneyard/README.md`: Theory-specific archives

## Active Development

For active completeness proofs, see:
- `Theories/Bimodal/Metalogic/StagedConstruction/`: Cantor-interval construction
- `Theories/Bimodal/Metalogic/Bundle/`: Publication-path definitions
- `Theories/Bimodal/Metalogic/FMP/`: Finite model property proof

---

*Last updated: 2026-03-15*
