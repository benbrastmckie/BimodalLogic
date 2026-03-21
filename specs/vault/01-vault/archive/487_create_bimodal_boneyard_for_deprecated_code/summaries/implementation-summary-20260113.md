# Implementation Summary: Task #487

**Task**: Create Bimodal/Boneyard/ for deprecated code
**Status**: Implemented
**Date**: 2026-01-13
**Session**: sess_1768347439_4e0821

## Summary

Created a Boneyard directory under `Theories/Bimodal/` to document and preserve references to deprecated completeness code. Instead of extracting code (which would break dependencies), created documentation files explaining what is deprecated, why, and what to use instead.

## Approach Adjustment

The original plan called for extracting deprecated code to the Boneyard. During implementation, analysis revealed:

1. **FiniteWorldState cannot be extracted**: It's used by SemanticWorldState.toFiniteWorldState in the working semantic approach
2. **Duration construction cannot be cleanly removed**: canonical_frame uses Duration as its time type
3. **Code is intertwined**: The deprecated and working approaches share infrastructure

**Solution**: Create documentation-only Boneyard files that:
- Document what is deprecated and its location
- Explain why each approach was deprecated
- Point to the working replacement code
- Serve as a reference guide for developers

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `Theories/Bimodal/Boneyard/README.md` | 95 | Overview of deprecated code and replacement |
| `Theories/Bimodal/Boneyard/SyntacticApproach.lean` | 68 | Documents finite_truth_lemma deprecation |
| `Theories/Bimodal/Boneyard/DurationConstruction.lean` | 166 | Documents Duration type deprecation |

## What's Documented as Deprecated

### Syntactic Approach (FiniteCanonicalModel.lean)

| Component | Location | Issue |
|-----------|----------|-------|
| `finite_truth_lemma` | ~line 3365 | 6 sorries in backward directions |
| `finite_weak_completeness` | ~line 3561 | Bridge sorry |
| `finite_strong_completeness` | ~line 3583 | Has sorry |

**Root cause**: `IsLocallyConsistent` captures only soundness, not negation-completeness needed for truth lemma backward directions.

### Duration Construction (Completeness.lean)

| Component | Location | Issue |
|-----------|----------|-------|
| `PositiveDuration` | ~line 1541 | 4 algebraic sorries |
| `Duration` | ~line 1812 | 2 order sorries |
| `canonical_task_rel` | ~line 2055 | Compositionality sorries |
| `canonical_frame` | ~line 2435 | Uses Duration type |

**Root cause**: Overcomplicated for no benefit; finite model property makes bounded time sufficient.

## Working Replacements

All working completeness code is in `FiniteCanonicalModel.lean`:

- `FiniteTime k` - Bounded time domain (Fin (2k+1))
- `SemanticWorldState` - Quotient of (history, time) pairs
- `semantic_truth_lemma_v2` - Proven, no sorries
- `semantic_weak_completeness` - Core completeness result
- `main_weak_completeness` - validity -> provability
- `main_provable_iff_valid` - Full characterization

## Verification

- `lake build`: Completed successfully (968 jobs)
- All existing tests pass
- No new warnings from Boneyard files
- Documentation files compile as Lean (comment-only)

## Design Rationale

The documentation-only approach was chosen because:

1. **Build stability**: No risk of breaking existing code
2. **Reference preservation**: Deprecated code remains accessible for study
3. **Clear guidance**: Developers know what to use and avoid
4. **Historical record**: Documents the evolution of the completeness proof

## Files Modified

No existing files were modified. Only new files were created in `Theories/Bimodal/Boneyard/`.

## Next Steps

- The deprecated code remains in place with existing documentation
- Future cleanup could add additional deprecation markers to the source files
- Consider adding `@[deprecated]` attributes to deprecated definitions (would require Lean changes)
