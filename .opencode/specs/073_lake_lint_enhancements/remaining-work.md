# Lake Lint Enhancements - Remaining Work

**Last Updated:** 2025-12-15  
**Status:** Phase 1.3 - 50% Complete (85/169 violations fixed)

## Quick Summary

- **Completed**: 3 files, 85 violations fixed (50% reduction)
- **Remaining**: 15 files, 84 violations to fix
- **Estimated Time**: 4.5-8.5 hours
- **Patterns Established**: All refactoring patterns documented and proven

## Detailed Breakdown by File

### High Priority (Top Violators)

#### 1. Propositional.lean - 20 violations (~40 min)
**Location:** `Logos/Core/Theorems/Propositional.lean`  
**Pattern:** Similar to Combinators.lean - long theorem signatures and have statements  
**Approach:** Follow established patterns from Combinators.lean  
**Verification:** `lake build Logos.Core.Theorems.Propositional`

#### 2. ModalS5.lean - 11 violations (~20 min)
**Location:** `Logos/Core/Theorems/ModalS5.lean`  
**Pattern:** Already 48% complete, remaining are same patterns  
**Approach:** Continue with established patterns  
**Verification:** Blocked by DeductionTheorem error (style fixes still valid)

### Medium Priority (5-9 violations)

#### 3. Perpetuity/Principles.lean - 9 violations (~25 min)
**Location:** `Logos/Core/Theorems/Perpetuity/Principles.lean`  
**Pattern:** Long theorem signatures with multiple hypotheses  
**Approach:** Break signatures across multiple lines  
**Verification:** `lake build Logos.Core.Theorems.Perpetuity.Principles`

#### 4. Perpetuity/Helpers.lean - 7 violations (~20 min)
**Location:** `Logos/Core/Theorems/Perpetuity/Helpers.lean`  
**Pattern:** Long have statements in proofs  
**Approach:** Extract intermediate steps  
**Verification:** `lake build Logos.Core.Theorems.Perpetuity.Helpers`

#### 5. ModalS4.lean - 6 violations (~20 min)
**Location:** `Logos/Core/Theorems/ModalS4.lean`  
**Pattern:** Similar to ModalS5.lean  
**Approach:** Follow ModalS5 patterns  
**Verification:** Blocked by DeductionTheorem error

#### 6. Soundness.lean - 6 violations (~20 min)
**Location:** `Logos/Core/Metalogic/Soundness.lean`  
**Pattern:** Long validity proofs  
**Approach:** Break complex proof steps  
**Verification:** `lake build Logos.Core.Metalogic.Soundness`

#### 7. Derivation.lean - 5 violations (~15 min)
**Location:** `Logos/Core/ProofSystem/Derivation.lean`  
**Pattern:** Long inductive type definitions  
**Approach:** Break constructor signatures  
**Verification:** `lake build Logos.Core.ProofSystem.Derivation`

### Low Priority (1-4 violations)

#### 8. Axioms.lean - 4 violations (~10 min)
**Location:** `Logos/Core/ProofSystem/Axioms.lean`  
**Pattern:** Long axiom definitions  
**Verification:** `lake build Logos.Core.ProofSystem.Axioms`

#### 9. Perpetuity/Bridge.lean - 3 violations (~10 min)
**Location:** `Logos/Core/Theorems/Perpetuity/Bridge.lean`  
**Verification:** `lake build Logos.Core.Theorems.Perpetuity.Bridge`

#### 10. TaskFrame.lean - 3 violations (~10 min)
**Location:** `Logos/Core/Semantics/TaskFrame.lean`  
**Verification:** `lake build Logos.Core.Semantics.TaskFrame`

#### 11. WorldHistory.lean - 2 violations (~5 min)
**Location:** `Logos/Core/Semantics/WorldHistory.lean`  
**Verification:** `lake build Logos.Core.Semantics.WorldHistory`

#### 12. TaskModel.lean - 2 violations (~5 min)
**Location:** `Logos/Core/Semantics/TaskModel.lean`  
**Verification:** `lake build Logos.Core.Semantics.TaskModel`

#### 13. Validity.lean - 2 violations (~5 min)
**Location:** `Logos/Core/Semantics/Validity.lean`  
**Verification:** `lake build Logos.Core.Semantics.Validity`

#### 14. GeneralizedNecessitation.lean - 2 violations (~5 min)
**Location:** `Logos/Core/Theorems/GeneralizedNecessitation.lean`  
**Verification:** Blocked by DeductionTheorem error

#### 15. Completeness.lean - 2 violations (~5 min)
**Location:** `Logos/Core/Metalogic/Completeness.lean`  
**Verification:** `lake build Logos.Core.Metalogic.Completeness`

## Refactoring Patterns (Established)

All patterns documented in `long-line-refactoring-guidelines.md`:

1. **Long Theorem Signatures** - Break across multiple lines with proper indentation
2. **Long Have Statements** - Extract to separate lines with type annotations
3. **Long Type Annotations** - Split complex types with alignment
4. **Long Comments** - Break at logical boundaries
5. **Long Function Calls** - Extract intermediate variables

## Workflow for Remaining Work

### Per-File Process

```bash
# 1. Check current violations
rg "^.{101,}" <file> --line-number

# 2. Edit file following guidelines
# (Use patterns from Combinators.lean, Truth.lean, ModalS5.lean)

# 3. Verify no new violations
rg "^.{101,}" <file> --line-number | wc -l

# 4. Build to verify correctness
lake build <module>

# 5. Commit
git add <file>
git commit -m "style: fix long lines in <file>"
```

### Batch Process (Recommended)

Work through files in priority order:
1. High priority (31 violations, ~80 min)
2. Medium priority (33 violations, ~110 min)
3. Low priority (20 violations, ~70 min)

**Total estimated**: 4.5 hours (conservative: 8.5 hours)

## Known Blockers

### DeductionTheorem.lean Build Error

**Issue:** Pre-existing build error in `Logos/Core/Metalogic/DeductionTheorem.lean`

**Impact:** Blocks build verification for:
- ModalS5.lean
- ModalS4.lean
- GeneralizedNecessitation.lean
- Propositional.lean (possibly)

**Workaround:** Style fixes are still valid even if build verification fails. The error is unrelated to style changes.

**Resolution:** Separate task to fix DeductionTheorem (not part of this spec)

## Success Criteria

- [ ] All 84 remaining violations fixed
- [ ] All buildable files verify with `lake build`
- [ ] `lake lint` shows 0 long line violations
- [ ] All commits follow established message format
- [ ] progress.md updated to 100% complete
- [ ] lake-lint-enhancements-plan.md updated to Phase 1 COMPLETE

## Next Phase Preview

After Phase 1 completion, Phase 2 (Batteries Integration) can begin:
- Implement environment linter execution
- Integrate with Batteries library
- Enable docBlameTheorems, tmNamingConventions, axiomDocumentation
- Estimated: 3 hours

## References

- **Guidelines**: [long-line-refactoring-guidelines.md](long-line-refactoring-guidelines.md)
- **Analysis**: [long-lines-analysis.md](long-lines-analysis.md)
- **Progress**: [progress.md](progress.md)
- **Plan**: [lake-lint-enhancements-plan.md](lake-lint-enhancements-plan.md)
- **TODO**: [/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md](../../TODO.md) (Task 47)
