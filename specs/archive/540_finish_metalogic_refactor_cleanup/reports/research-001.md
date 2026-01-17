# Research Report: Task #540

**Task**: 540 - Finish Metalogic Directory Refactor and Cleanup
**Date**: 2026-01-17
**Focus**: Complete analysis of remaining Metalogic refactoring work
**Session ID**: sess_1768660568_f65d39

## Summary

The Metalogic directory cleanup from Task 523 documented the architecture but left several broken modules and parallel structures. This research identifies what remains: (1) the Representation/ module has 21+ compilation errors from incorrect APIs, (2) three modules (CompletenessTheorem.lean, Compactness.lean, FiniteModelProperty.lean) are empty due to import failures, (3) a decision must be made whether to fix or remove these broken modules. The working proofs exist in `Completeness.lean` (3719 lines, proven), with the Boneyard already containing deprecated approaches.

## Findings

### 1. Current Architecture Assessment

The Task 523 README accurately documents the two parallel structures:

**Working Structure (builds successfully)**:
```
Completeness.lean (154KB, proven) → provable_iff_valid
├── Uses Soundness/Soundness.lean
├── Uses DeductionTheorem.lean
├── Uses Core/Basic.lean
└── Extends to Completeness/FiniteCanonicalModel.lean
    └── semantic_weak_completeness (proven)
```

**Intended Structure (broken, does not build)**:
```
Representation/
├── CanonicalModel.lean        # 21+ errors
├── TruthLemma.lean            # Depends on broken
├── RepresentationTheorem.lean # Depends on broken
└── FiniteModelProperty.lean   # Depends on broken
    ↓
Completeness/CompletenessTheorem.lean # Empty (import fails)
Applications/Compactness.lean          # Empty (import fails)
```

### 2. Representation Module Errors

`Representation/CanonicalModel.lean` has **21 compilation errors**:

| Error Type | Count | Examples |
|------------|-------|----------|
| Invalid field `.toList` | 4 | `carrier.toList` on Set Formula |
| Invalid field `.subformula_closure` | 1 | `φ.subformula_closure` doesn't exist |
| Invalid field `.chain` | 1 | `C.chain` on Set |
| Unknown identifiers | 3 | `exists_mem_of_mem_union`, `subset_union₀`, `zorn_nonempty_partial_order` |
| Type mismatches | 3 | `φ` (Formula) where Prop expected |
| Missing alternatives | 4 | `past`, `future` vs `all_past`, `all_future` |
| Unsolved goals | 1 | Lindenbaum lemma incomplete |

**Root cause**: The module was written for an older Lean 4/Mathlib API. The `Set Formula` type doesn't have `.toList`, and Zorn's lemma patterns have changed.

### 3. Empty Modules Due to Import Chain

These modules import from the broken Representation chain and have **no declarations**:

1. **`Completeness/CompletenessTheorem.lean`** (3259 bytes)
   - Imports: `Representation.CanonicalModel`, `Representation.RepresentationTheorem`
   - Result: Empty module (import fails)

2. **`Applications/Compactness.lean`** (3301 bytes)
   - Imports: `Completeness.CompletenessTheorem`, `Representation.RepresentationTheorem`
   - Result: Empty module (import fails)

3. **`Representation/FiniteModelProperty.lean`** (3171 bytes)
   - Has failed dependencies on CanonicalModel, DeductionTheorem, Soundness
   - Contains FMP scaffolding that never compiled

### 4. Working Boneyard Already Exists

`Theories/Bimodal/Boneyard/` (not inside Metalogic) contains:
- `SyntacticApproach.lean` - Deprecated syntactic completeness (has sorries)
- `DurationConstruction.lean` - Deprecated Duration-based time domain
- `README.md` - Documents why approaches were deprecated

This is the correct location for deprecated code per Task 487.

### 5. Discrepancy: README vs Reality

The `Metalogic/README.md` mentions `Metalogic/Boneyard/` but this directory does not exist. The actual Boneyard is at `Bimodal/Boneyard/`. The README should be corrected.

### 6. DeductionTheorem Location

`DeductionTheorem.lean` is at `Metalogic/DeductionTheorem.lean` but the README's "Intended Structure" suggests it should be in `Core/`. This is a minor organizational issue.

## Architectural Decision Required

**Option A: Remove Broken Modules Entirely**
- Delete: `Representation/*.lean` (except ContextProvability.lean which works)
- Delete: `Completeness/CompletenessTheorem.lean`
- Delete: `Applications/Compactness.lean`
- Keep: Working `Completeness.lean` and `FiniteCanonicalModel.lean`
- Rationale: The working proofs exist; broken scaffolding provides no value

**Option B: Fix Broken Modules (Major Effort)**
- Rewrite `CanonicalModel.lean` with correct Mathlib APIs
- Estimated effort: 8-12 hours
- Risk: May duplicate existing proven code in `Completeness.lean`

**Recommendation**: Option A - The proven completeness exists in `Completeness.lean`. The Representation module was scaffolding that never worked. Removing broken code reduces confusion.

## Cleanup Actions Identified

### Phase 1: Remove Broken Modules (1 hour)
1. **Delete or move to Boneyard**:
   - `Representation/CanonicalModel.lean` (broken)
   - `Representation/TruthLemma.lean` (depends on broken)
   - `Representation/RepresentationTheorem.lean` (depends on broken)
   - `Representation/FiniteModelProperty.lean` (depends on broken)
   - `Completeness/CompletenessTheorem.lean` (empty)
   - `Applications/Compactness.lean` (empty)

2. **Keep**:
   - `Representation/ContextProvability.lean` (builds, may be useful)
   - All files in `Completeness/` except CompletenessTheorem.lean
   - All Decidability files

### Phase 2: Fix README (30 minutes)
1. Update `Metalogic/README.md`:
   - Change `Metalogic/Boneyard/` references to `Bimodal/Boneyard/`
   - Remove references to deleted modules
   - Mark Representation/ as deprecated or removed
   - Update module status table

2. Verify all file paths are accurate

### Phase 3: Consider Moving DeductionTheorem (Optional, 30 minutes)
- Move `DeductionTheorem.lean` to `Core/DeductionTheorem.lean`
- Update imports in all dependent files
- Low priority, no functional benefit

### Phase 4: Update Parent Module (30 minutes)
- Check `Bimodal/Metalogic.lean` for broken imports
- Remove references to deleted modules
- Verify `lake build Bimodal.Metalogic` succeeds

## Module Dependency Graph (Post-Cleanup)

```
                      Bimodal.ProofSystem
                              │
                              ▼
                     Bimodal.Semantics
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        Core/Basic    DeductionTheorem   Soundness/
              │               │               │
              └───────────────┴───────────────┘
                              │
                              ▼
                    Completeness.lean (PROVEN)
                              │
                              ▼
           Completeness/FiniteCanonicalModel.lean (PROVEN)

                         (Separate)
                              │
                              ▼
                    Decidability/* (Partial)
                    - Soundness proven
                    - Completeness has sorries
```

## Recommendations

### Immediate Actions
1. **Choose cleanup strategy**: Option A (remove) or Option B (fix)
2. **If Option A**: Move broken files to Boneyard with deprecation note
3. **Update README**: Fix Boneyard path and module status

### Medium-Term Actions
1. **Complete Decidability**: Connect to FMP once architecture stabilizes
2. **Consider Compactness**: May not need dedicated module if not actively used

### Documentation
Update README.md to accurately reflect:
- Working modules (Core/, Soundness/, DeductionTheorem, Completeness.lean)
- Partial modules (Decidability/)
- Removed modules (Representation/, Applications/)

## Files to Create/Modify

| File | Action | Notes |
|------|--------|-------|
| `specs/540_*/reports/research-001.md` | Create | This report |
| `Metalogic/README.md` | Update | Fix paths, remove broken refs |
| `Representation/*.lean` (4 files) | Delete/Move | Except ContextProvability |
| `Completeness/CompletenessTheorem.lean` | Delete/Move | Empty module |
| `Applications/Compactness.lean` | Delete/Move | Empty module |
| `Bimodal/Boneyard/README.md` | Update | Add moved files |

## Key Theorems Inventory (Working)

| Theorem | Location | Status |
|---------|----------|--------|
| `Soundness.soundness` | `Soundness/Soundness.lean` | PROVEN |
| `deduction_theorem` | `DeductionTheorem.lean` | PROVEN |
| `provable_iff_valid` | `Completeness.lean` | PROVEN |
| `semantic_weak_completeness` | `FiniteCanonicalModel.lean` | PROVEN |
| `semantic_truth_lemma_v2` | `FiniteCanonicalModel.lean` | PROVEN |
| `decide_sound` | `Decidability/Correctness.lean` | PROVEN |
| `decide_complete` | `Decidability/Correctness.lean` | SORRY |

## Next Steps

Run `/plan 540` to create implementation plan for cleanup activities.
