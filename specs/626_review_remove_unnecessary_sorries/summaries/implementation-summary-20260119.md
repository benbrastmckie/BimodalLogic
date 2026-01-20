# Implementation Summary: Task #626

**Completed**: 2026-01-19
**Duration**: ~45 minutes

## Overview

Systematically cleaned up Metalogic_v2 by removing unnecessary theorems with sorries and documenting deprecated approaches in the Boneyard.

## Changes Made

### Theorems Deleted (4 total)

1. **BranchClosure.lean**:
   - Deleted `closed_extend_closed` (unused, low-value)
   - Deleted `add_neg_causes_closure` (unused, low-value)

2. **Correctness.lean**:
   - Deleted `tableau_complete` (never completed, alternative decidability exists via FMP)
   - Deleted `decide_complete` (depended on `tableau_complete`)

3. **SemanticCanonicalModel.lean**:
   - Deleted `semantic_truth_implies_truth_at` (deprecated bridge approach)
   - Deleted `main_weak_completeness_v2` (deprecated, superseded by `semantic_weak_completeness`)
   - Updated `main_provable_iff_valid_v2` to inline the sorry (completeness direction)

### Documentation Created

- Created `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` documenting:
  - Why `semantic_task_rel_compositionality` has a sorry (mathematically impossible for unbounded durations)
  - Why `semantic_truth_implies_truth_at` was deprecated (formula induction challenges)
  - Why `main_weak_completeness_v2` was deprecated (truth bridge issues)
  - The recommended approach: use `semantic_weak_completeness`

### README Updates

- Updated `Theories/Bimodal/Boneyard/README.md` with new DeprecatedCompleteness section
- Updated `Theories/Bimodal/Metalogic_v2/README.md` with:
  - New sorry count (4 instead of 5)
  - Updated completeness architecture documentation
  - Updated future work section

### Dependent Code Updates

- **FiniteModelProperty.lean**: Inlined sorry where `semantic_truth_implies_truth_at` was called
- **Decidability.lean**: Updated hub file to remove `#check decide_complete`

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic_v2/Decidability/BranchClosure.lean` | Removed 2 theorems (~55 lines) |
| `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` | Removed 2 theorems (~90 lines), updated comments |
| `Theories/Bimodal/Metalogic_v2/Decidability.lean` | Updated hub exports |
| `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` | Removed 2 theorems (~130 lines), updated `main_provable_iff_valid_v2` |
| `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` | Inlined sorry, updated comments |
| `Theories/Bimodal/Metalogic_v2/README.md` | Updated sorry count and documentation |
| `Theories/Bimodal/Boneyard/README.md` | Added DeprecatedCompleteness section |
| `Theories/Bimodal/Boneyard/DeprecatedCompleteness.lean` | New file (documentation) |

## Sorry Count Before/After

| File | Before | After | Change |
|------|--------|-------|--------|
| BranchClosure.lean | 2 | 0 | -2 |
| Correctness.lean | 3 | 1 | -2 |
| SemanticCanonicalModel.lean | 3 | 2 | -1 |
| FiniteModelProperty.lean | 0 | 1 | +1 (inlined) |
| **Total Metalogic_v2** | **8** | **4** | **-4** |

Note: The net reduction is 4 sorries. One sorry was moved (inlined) from `semantic_truth_implies_truth_at` to `finite_model_property_constructive`.

## Verification

- Lake build: SUCCESS (976 jobs)
- All grep searches confirm no orphaned references to deleted theorems
- Main completeness chain via `semantic_weak_completeness`: Unaffected (sorry-free)

## Notes

- The `semantic_task_rel_compositionality` sorry remains in place because it's used by `SemanticCanonicalFrame`. This is an acceptable limitation documented in the code.
- The sorry-free completeness result `semantic_weak_completeness` is the recommended approach for all completeness proofs.
- The deprecated approach has been thoroughly documented in the Boneyard for historical reference.
