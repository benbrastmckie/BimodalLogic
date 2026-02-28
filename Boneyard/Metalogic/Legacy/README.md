# Legacy Archive

This directory contains obsolete files that were duplicates or superseded by reorganized code.

## Contents

### DeductionTheorem.lean

**Archived**: 2026-02-03 (Task 818)

**Reason**: Duplicate of `Metalogic/Core/DeductionTheorem.lean`. The root-level version was no longer imported by any active code - all imports use the canonical `Core/DeductionTheorem.lean` version.

**Canonical Location**: `Bimodal.Metalogic.Core.DeductionTheorem`

The two files were nearly identical, differing only in:
- Namespace (`Bimodal.Metalogic` vs `Bimodal.Metalogic.Core`)
- Minor formatting in simp calls

The Core version is preferred as it properly places deduction theorem infrastructure within the Core layer where MCS properties depend on it.
