# Research Report: Task #357

**Task**: Fix ModalS5.lean noncomputable cascade
**Date**: 2026-01-10
**Focus**: Identify and fix `noncomputable` marker requirements in ModalS5.lean

## Summary

The build errors in ModalS5.lean are caused by 5 definitions that depend on `noncomputable` functions from Propositional.lean but are not themselves marked as `noncomputable`. The fix is straightforward: add the `noncomputable` keyword to each affected definition.

## Findings

### 1. Root Cause: Classical Deduction Theorem

The `deduction_theorem` in `Bimodal/Metalogic/DeductionTheorem.lean` (line 332) is marked `noncomputable` because it uses `Classical.choice` via the `Classical.propDecidable` instance (line 41). This is required for decidable equality on formulas during context manipulation.

### 2. Propositional.lean Noncomputable Section

The entire `Bimodal.Theorems.Propositional` namespace (lines 46-1672) is wrapped in a `noncomputable section` because:
- `lce_imp` (line 737) uses `deduction_theorem`
- `rce_imp` (line 755) uses `deduction_theorem`
- `classical_merge` (line 785) uses `deduction_theorem`

### 3. Affected Definitions in ModalS5.lean

The 5 definitions with build errors:

| Line | Definition | Direct Dependency | Error Type |
|------|------------|-------------------|------------|
| 63 | `classical_merge` | `Propositional.classical_merge` | noncomputable |
| 203 | `box_disj_intro` | Local `classical_merge` (line 63) | cascade |
| 379 | `box_iff_intro` | `Propositional.lce_imp` | noncomputable |
| 514 | `box_conj_iff` | `Propositional.lce_imp` | noncomputable |
| 621 | `diamond_disj_iff` | `box_iff_intro` (line 379) | cascade |

### 4. Dependency Chain Analysis

```
DeductionTheorem.deduction_theorem (noncomputable - Classical.choice)
    │
    ├── Propositional.lce_imp (noncomputable section)
    │       │
    │       ├── ModalS5.box_iff_intro (NEEDS noncomputable)
    │       │       │
    │       │       └── ModalS5.diamond_disj_iff (NEEDS noncomputable - cascade)
    │       │
    │       └── ModalS5.box_conj_iff (NEEDS noncomputable)
    │
    ├── Propositional.rce_imp (noncomputable section)
    │       │
    │       └── (also used by box_iff_intro, box_conj_iff)
    │
    └── Propositional.classical_merge (noncomputable section)
            │
            └── ModalS5.classical_merge (NEEDS noncomputable)
                    │
                    └── ModalS5.box_disj_intro (NEEDS noncomputable - cascade)
```

## Recommendations

1. **Add `noncomputable` keyword** to each of the 5 affected definitions:
   - Line 63: `noncomputable def classical_merge`
   - Line 203: `noncomputable def box_disj_intro`
   - Line 379: `noncomputable def box_iff_intro`
   - Line 514: `noncomputable def box_conj_iff`
   - Line 621: `noncomputable def diamond_disj_iff`

2. **Alternative approach** (not recommended): Wrap the affected definitions in a `noncomputable section` block. However, this is less explicit and could mask future issues.

3. **Verification**: After adding markers, run `lake build Bimodal.Theorems.ModalS5` to confirm errors are resolved.

## References

- `Bimodal/Theorems/ModalS5.lean` - File with build errors
- `Bimodal/Theorems/Propositional.lean` - Source of noncomputable dependencies (lines 46-1672)
- `Bimodal/Metalogic/DeductionTheorem.lean` - Root cause (line 332, 41)

## Next Steps

1. Create implementation plan with single phase
2. Add `noncomputable` markers to the 5 definitions
3. Verify build succeeds
4. Commit changes
