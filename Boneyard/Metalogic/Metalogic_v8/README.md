# Metalogic v8 Archive

**Archived**: 2026-02-28 (Task 948)
**Status**: ARCHIVED - Boneyard files may not build

## Reason for Archival

These files were archived because they prove completeness theorems using
**non-standard validity definitions** that are not proven equivalent to the
standard `valid` definition from `Semantics/Validity.lean`.

Specifically:

- **BFMCS Completeness** (`Bundle/Completeness.lean`): Uses `bmcs_valid`, which quantifies
  over all BFMCS (Bundles of Maximal Consistent Sets) rather than standard Kripke models.
  While this is a genuine Henkin-style completeness result, the connection to standard
  validity has not been formally established.

- **FMP Completeness** (`FMP/`): Uses `fmp_weak_completeness` with `semantic_truth_at_v2`,
  a custom truth predicate on finite world states. Again, the connection to standard
  `valid` from `Semantics/Validity.lean` has not been formalized.

## What Was Replaced

The standard completeness theorems (`standard_weak_completeness`,
`standard_strong_completeness`) in `Representation.lean` prove completeness with
respect to the standard `valid` definition, making these non-standard results
redundant for the main completeness chain.

## Archived Files

### Bundle/Completeness.lean
- Original: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Contains: `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness`
- Status: All theorems were SORRY-FREE
- Shared utilities (`ContextDerivable`, `not_derivable_implies_neg_consistent`,
  `context_not_derivable_implies_extended_consistent`) were relocated to
  `Bundle/Construction.lean` before archival

### FMP/ (4 files)
- `Closure.lean`: Subformula closure, closure-MCS, closure-maximal consistency
- `BoundedTime.lean`: Finite time domain `BoundedTime k = Fin (2*k+1)`
- `FiniteWorldState.lean`: Finite world states as truth assignments on closure
- `SemanticCanonicalModel.lean`: `fmp_weak_completeness`, `semanticWorldState_card_bound`
- Status: All files were SORRY-FREE and AXIOM-FREE

## Dependencies

These archived files depend on active modules in the main codebase:
- `Bundle/Construction.lean`, `Bundle/BFMCS.lean`, etc.
- `Core/MaximalConsistent.lean`, `Core/MCSProperties.lean`
- `Semantics/`, `ProofSystem/`, `Syntax/`

Since these are Boneyard files, broken imports are expected and documented.

## Related Tasks

- Task 812: Original BFMCS completeness implementation
- Task 910: Standard completeness via Representation.lean
- Task 912: Omega-parameterized validity
- Task 948: This archival
