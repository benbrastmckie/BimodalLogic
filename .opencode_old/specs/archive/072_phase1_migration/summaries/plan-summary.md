# Plan Summary: Phase 1 - Core Definition Migration

**Project**: #072  
**Plan Version**: 001  
**Date**: 2025-12-19  
**Complexity**: COMPLEX  
**Estimated Effort**: 6-8 hours

---

## Overview

**Goal**: Migrate `Logos/Core/ProofSystem/Derivation.lean` from `Derivable : Prop` to `DerivationTree : Type`.

**Context**: Phase 1 of 7-phase migration to deep embedding. This is the CRITICAL first phase that enables all subsequent work.

**Parent Project**: #058 (Full Migration Plan)

---

## Key Changes

### 1. Inductive Type Declaration
- **Change**: `Derivable : Prop` → `DerivationTree : Type`
- **Impact**: Enables pattern matching and computable functions
- **Effort**: 1 hour

### 2. Height Axioms Removal
- **Remove**: 7 axiom declarations (lines 168-222)
- **Replace with**: Computable height function + proven theorems
- **Effort**: 30 minutes

### 3. Computable Height Function
- **Add**: Pattern matching on all 7 constructors
- **Returns**: Nat (computable)
- **Effort**: 1 hour

### 4. Height Properties as Theorems
- **Prove**: 6 height properties (previously axiomatized)
- **Tactics**: `simp [height]` and `omega`
- **Effort**: 2-3 hours

### 5. Notation and Examples
- **Update**: Notation to use DerivationTree
- **Update**: 4 example derivations
- **Effort**: 1.25 hours

---

## Implementation Steps

| Step | Description | Effort | Checkpoint |
|------|-------------|--------|------------|
| 1 | Update inductive type declaration | 1 hour | Type updated, deriving Repr added |
| 2 | Remove 7 height axioms | 30 min | All axioms deleted |
| 3 | Add computable height function | 1 hour | Pattern matching on 7 constructors |
| 4 | Prove 6 height properties | 2-3 hours | All theorems proven, no sorry |
| 5 | Update notation | 15 min | Notation uses DerivationTree |
| 6 | Update 4 examples | 1 hour | All examples compile |
| 7 | Final verification | 30 min | File compiles, zero sorry |

**Total**: 6-8 hours

---

## Success Criteria

### Primary Goal: Derivation.lean Migrated to Type

**Correctness:**
- ✅ File compiles without errors
- ✅ No `sorry` statements
- ✅ All examples work correctly
- ✅ Height function computable

**Completeness:**
- ✅ All 7 height axioms removed
- ✅ All 6 height properties proven as theorems
- ✅ Inductive type updated (Prop → Type)
- ✅ Type renamed (Derivable → DerivationTree)

**Quality:**
- ✅ Code follows LEAN style guide
- ✅ Docstrings complete and accurate
- ✅ Examples illustrative and working
- ✅ `deriving Repr` added

**Expected Breaking Changes:**
- ⚠️ Downstream files will not compile (EXPECTED)
- ⚠️ Phases 2-7 required to fix downstream files

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Height function bugs | 30% | MEDIUM | Prove properties as theorems |
| Proof failures | 40% | MEDIUM | Use simp + omega |
| Breaking downstream | 100% | EXPECTED | Phases 2-7 will fix |
| Rollback needed | 10% | LOW | Git branch, single file |

**Overall Risk**: MEDIUM (well-understood changes, critical file)

---

## Dependencies

### Prerequisites
- ✅ Git branch created
- ✅ Backup of Derivation.lean
- ✅ Current file compiles (baseline)
- ✅ Parent migration plan reviewed

### Blocks
- Task 73: Phase 2 - Metalogic Proofs Migration
- Task 74: Phase 3 - Theorem Libraries Migration
- Task 75: Phase 4 - Automation Migration
- Task 76: Phase 5 - Test Suites Migration
- Task 77: Phase 6 - Documentation Updates
- Task 78: Phase 7 - Final Verification

---

## Code Examples

### Height Function (Pattern Matching)
```lean
def DerivationTree.height : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | assumption _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | necessitation _ d => 1 + d.height
  | temporal_necessitation _ d => 1 + d.height
  | temporal_duality _ d => 1 + d.height
  | weakening _ _ _ d _ => 1 + d.height
```

### Height Property Theorem (Example)
```lean
theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega
```

---

## Verification Checkpoints

### After Each Step
- Incremental compilation: `lake build Logos.Core.ProofSystem.Derivation`
- Check for sorry: `grep -n "sorry" Logos/Core/ProofSystem/Derivation.lean`
- Review diff before committing

### Final Verification
- [ ] File compiles without errors
- [ ] Zero sorry statements
- [ ] All 7 height axioms removed
- [ ] All 6 height properties proven
- [ ] All 4 examples working
- [ ] Notation updated
- [ ] `deriving Repr` added

---

## Expected Impact

### This File (Derivation.lean)
- ✅ Compiles successfully
- ✅ Zero sorry statements
- ✅ All axioms removed
- ✅ Computable height function
- ✅ All properties proven

### Downstream Files (EXPECTED BREAKAGE)
- ⚠️ **Metalogic**: DeductionTheorem, Soundness, Completeness (Phase 2)
- ⚠️ **Theorems**: Propositional, Combinators, GeneralizedNecessitation, Perpetuity (Phase 3)
- ⚠️ **Automation**: Tactics, AesopRules (Phase 4)
- ⚠️ **Tests**: All test modules (Phase 5)

**This is EXPECTED and CORRECT** - Phases 2-7 will fix these files.

---

## Next Steps

### Immediate: Execute Phase 1
```bash
/lean .opencode/specs/072_phase1_migration/plans/phase1-implementation-001.md
```

### After Phase 1 Complete
1. Verify all success criteria met
2. Commit Phase 1 changes
3. Proceed to Phase 2 (Metalogic Proofs Migration)

### Phase 2 Preview
- **Files**: DeductionTheorem.lean, Soundness.lean, Completeness.lean
- **Effort**: 18-23 hours
- **Changes**: Update type signatures, constructor names, termination clauses

---

## Related Documentation

- **Full Implementation Plan**: `plans/phase1-implementation-001.md`
- **Parent Migration Plan**: `.opencode/specs/058_migration_to_type/plans/implementation-001.md`
- **Task Summary**: `summaries/task-summary.md`
- **TODO.md**: `.opencode/specs/TODO.md` (Task #72)

---

**Plan Summary Complete**: 2025-12-19  
**Ready for Execution**: YES  
**Recommended Command**: `/lean .opencode/specs/072_phase1_migration/plans/phase1-implementation-001.md`
