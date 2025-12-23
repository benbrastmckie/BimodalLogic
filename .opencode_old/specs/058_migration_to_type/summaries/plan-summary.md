# Implementation Plan Summary: Derivable → DerivationTree Migration

**Project**: #058  
**Plan Version**: 001  
**Date**: 2025-12-19  
**Status**: Ready for Execution

---

## Executive Summary

This implementation plan provides a detailed, step-by-step guide for migrating the core derivation relation from `Derivable : Prop` to `DerivationTree : Type` in the LEAN 4 ProofChecker project. The migration enables computable height functions, pattern matching on derivations, and explicit proof term analysis, at the cost of 60-80 hours effort and 25-50% compilation slowdown.

---

## Complexity Assessment

**Overall Complexity:** COMPLEX  
**Estimated Effort:** 60-80 hours  
**Risk Level:** HIGH  
**Confidence:** Medium-High

### Key Complexity Drivers:
1. Breaking changes across 20 files
2. Core type system refactor (Prop → Type)
3. Well-founded recursion updates
4. Metaprogramming/tactic fragility
5. Performance implications

---

## Implementation Phases

### Phase 1: Core Definition (6-8 hours) ⭐ CRITICAL
- Update inductive type: `Prop` → `Type`
- Remove 7 height axioms
- Add computable height function
- Prove 6 height properties as theorems
- Update notation and examples

### Phase 2: Metalogic Proofs (18-23 hours) ⭐ HIGH IMPACT
- Update DeductionTheorem.lean (10-12 hours)
- Update Soundness.lean (6-8 hours)
- Update Completeness.lean (2-3 hours)

### Phase 3: Theorem Libraries (29-37 hours)
- Update Propositional.lean (8-10 hours)
- Update Combinators.lean (4-5 hours)
- Update GeneralizedNecessitation.lean (5-6 hours)
- Update Perpetuity modules (6-8 hours)
- Update remaining theorems (6-8 hours)

### Phase 4: Automation (8-11 hours) ⚠️ HIGH RISK
- Update Tactics.lean (6-8 hours)
- Update AesopRules.lean (2-3 hours)

### Phase 5: Test Suites (19-26 hours)
- Update core tests (10-13 hours)
- Update theorem tests (6-8 hours)
- Update automation tests (4-5 hours)

### Phase 6: Documentation (2-3 hours)
- Update module files
- Update examples
- Add migration notes

### Phase 7: Final Verification (4-6 hours)
- Full build
- All tests
- Performance check
- Verify new capabilities

**Total Estimated Effort:** 60-80 hours

---

## Key Dependencies

### Critical Path:
1. **Phase 1 (Core Definition)** must complete first
2. **Phase 2 (Metalogic)** depends on Phase 1
3. **Phase 3 (Theorems)** depends on Phase 2
4. **Phase 4 (Automation)** depends on Phase 1
5. **Phase 5 (Tests)** depends on all previous phases
6. **Phase 6-7** depend on all implementation phases

### Required Imports:
- `Init.WF` - Well-founded recursion
- `Init.Data.Nat.Basic` - Nat operations (max, omega)
- `Mathlib.Tactic.Basic` - Basic tactics
- `Mathlib.Data.List.Basic` - List operations

---

## Success Criteria

### Primary Goal: Complete Migration
- ✅ Clean, consistent Type-based implementation
- ✅ Full completeness (zero `sorry` statements)
- ✅ Type-based derivation relation
- ✅ Computable height function (7 axioms removed)
- ✅ Pattern matching on derivations
- ✅ All tests passing
- ✅ Performance acceptable (<50% slower)

### Verification Checklist:
- [ ] All 20 files compile without errors
- [ ] All test suites pass
- [ ] All example derivations work
- [ ] All tactics function correctly
- [ ] Compilation time <50% slower than baseline
- [ ] Memory usage <100% higher than baseline
- [ ] Height function computable
- [ ] Pattern matching works
- [ ] Repr instance functional
- [ ] Zero `sorry` statements
- [ ] All 7 height axioms removed

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Breaking all downstream code | 100% | CRITICAL | Incremental migration, testing |
| Performance degradation >25% | 80% | HIGH | Benchmark, optimize, rollback |
| Tactic system breakage | 60% | HIGH | Careful updates, extensive testing |
| Height function bugs | 30% | MEDIUM | Prove properties as theorems |
| Time overrun | 40% | MEDIUM | Track time, reassess if >100 hours |

**Overall Risk:** HIGH - Multiple high-severity risks

---

## Key Implementation Steps

### Step 1: Core Type Change
```lean
-- BEFORE
inductive Derivable : Context → Formula → Prop where
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (h1 : Derivable Γ (φ.imp ψ))
      (h2 : Derivable Γ φ) : Derivable Γ ψ

-- AFTER
inductive DerivationTree : Context → Formula → Type where
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree Γ (φ.imp ψ))
      (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ
  deriving Repr
```

### Step 2: Computable Height
```lean
-- BEFORE (axiomatized)
axiom Derivable.height : Derivable Γ φ → Nat
axiom Derivable.mp_height_gt_left : d1.height < (modus_ponens Γ φ ψ d1 d2).height

-- AFTER (computable)
def DerivationTree.height : DerivationTree Γ φ → Nat
  | axiom _ _ _ => 0
  | modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | ...

theorem mp_height_gt_left : d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]; omega
```

### Step 3: Update All References
```bash
# Find-replace pattern
Derivable.axiom → DerivationTree.axiom
Derivable.modus_ponens → DerivationTree.modus_ponens
# ... for all constructors
```

---

## Benefits Achieved

### Removed Axioms:
- ❌ `Derivable.height` (axiom)
- ❌ `Derivable.weakening_height_succ` (axiom)
- ❌ `Derivable.subderiv_height_lt` (axiom)
- ❌ `Derivable.mp_height_gt_left` (axiom)
- ❌ `Derivable.mp_height_gt_right` (axiom)
- ❌ `Derivable.necessitation_height_succ` (axiom)
- ❌ `Derivable.temporal_necessitation_height_succ` (axiom)

**Total:** 7 axioms removed

### New Capabilities:
- ✅ Computable height function
- ✅ Pattern matching on derivations
- ✅ Decidable equality (via deriving)
- ✅ Repr instance for debugging
- ✅ Explicit proof term analysis

---

## Costs Accepted

### Performance:
- 25-50% slower compilation (expected)
- 50-100% more memory usage (expected)
- Proof terms not erased at runtime

### Effort:
- 60-80 hours implementation time
- Breaking changes across entire codebase
- High risk during migration

### Maintenance:
- More complex type system
- Deviation from LEAN community standards
- Contradicts previous research recommendation

---

## Rollback Plan

### If Migration Fails:

1. **Git Revert:**
   ```bash
   git checkout main
   git branch -D migration/derivable-to-type
   ```

2. **Restore Backups:**
   ```bash
   cp *.backup Logos/Core/ProofSystem/
   ```

3. **Verify:**
   ```bash
   lake clean && lake build && lake test
   ```

**Rollback Complexity:** Medium (git revert + backup restore)

---

## Next Steps

1. **User Decision:** Review plan and approve/modify
2. **If Approved:**
   - Create git branch: `migration/derivable-to-type`
   - Run baseline tests
   - Begin Phase 1 (Core Definition)
3. **If Not Approved:**
   - Document decision
   - Consider alternative approaches (hybrid, minimal)

---

## References

- **Full Implementation Plan**: `.opencode/specs/058_migration_to_type/plans/implementation-001.md`
- **Migration Plan**: `.opencode/specs/058_migration_to_type/reports/migration-plan-001.md`
- **Code Patterns**: `.opencode/specs/058_migration_to_type/reports/code-patterns.md`
- **Previous Research**: `.opencode/specs/057_deep_embedding_research/reports/research-001.md`
- **Migration Summary**: `.opencode/specs/058_migration_to_type/summaries/migration-summary.md`

---

**Summary Complete**: 2025-12-19  
**Plan Status**: Ready for Execution  
**Awaiting**: User approval to proceed
