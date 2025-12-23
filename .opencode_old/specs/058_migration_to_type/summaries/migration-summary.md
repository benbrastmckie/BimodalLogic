# Migration Summary: Derivable : Prop → DerivationTree : Type

**Project**: #058  
**Date**: 2025-12-19  
**Status**: Plan Complete, Awaiting Decision

---

## Executive Summary

### Decision Context

**Previous Research** (Project #057): Recommended **KEEPING** dual-type approach  
**User Decision**: **OVERRIDE** - Proceed with migration to Type

This migration **reverses** research-backed recommendation to enable:
- Computable height functions (remove 6 axioms)
- Pattern matching on derivations
- Explicit proof term analysis

### Complexity Assessment

| Metric | Value |
|--------|-------|
| **Files Affected** | 20 files |
| **Estimated Effort** | 60-80 hours |
| **Risk Level** | HIGH |
| **Breaking Changes** | YES (entire codebase) |
| **Performance Impact** | +25-50% compilation time |

---

## Key Findings

### 1. Scope of Changes

**Critical Files** (4):
- `Derivation.lean`: Core type definition, remove 7 axioms, add computable height
- `DeductionTheorem.lean`: Update well-founded recursion
- `Soundness.lean`: Update induction on derivations
- `Completeness.lean`: Update type signatures

**High Impact** (9):
- All theorem libraries (Propositional, Combinators, GeneralizedNecessitation, Perpetuity)
- Automation (Tactics, AesopRules)

**Moderate Impact** (7):
- All test suites

**Minor Impact** (4):
- Module organization and documentation

### 2. Migration Benefits

✅ **Remove 6 axioms**: All height properties become provable theorems  
✅ **Computable height**: Pattern matching enables `def height : DerivationTree → Nat`  
✅ **Pattern matching**: Can extract data from derivations  
✅ **Decidable equality**: Can derive `DecidableEq` for proof terms  
✅ **Repr instance**: Automatic derivation for debugging

### 3. Migration Costs

❌ **Breaking changes**: Every file using `Derivable` breaks  
❌ **Performance**: 25-50% slower compilation, 50-100% more memory  
❌ **Effort**: 60-80 hours of migration work  
❌ **Risk**: Medium-high risk of introducing bugs  
❌ **Proof term overhead**: Proof terms not erased at runtime

---

## Recommended Approach

### Strategy: Incremental Migration with Parallel Types

**Phase 1**: Add `DerivationTree : Type` alongside `Derivable : Prop`  
**Phase 2**: Migrate files one-by-one to use `DerivationTree`  
**Phase 3**: Keep conversion function `DerivationTree.toDerivable`  
**Phase 4**: Remove `Derivable` when all files migrated

**Benefits**:
- Low risk (incremental)
- Easy rollback (per file)
- Testable at each step
- Verify equivalence before full switch

**Timeline**:
- Week 1: Core definition + Metalogic (24-31 hours)
- Week 2: Theorems + Automation (37-48 hours)
- Week 3: Tests + Documentation (21-29 hours)

---

## Critical Risks

### Risk 1: Breaking All Downstream Code (100% likelihood)
**Mitigation**: Incremental migration, parallel types, comprehensive testing

### Risk 2: Performance Degradation (80% likelihood)
**Mitigation**: Benchmark before/after, optimize if >50% slower, rollback if unacceptable

### Risk 3: Tactic System Breakage (60% likelihood)
**Mitigation**: Careful metaprogramming updates, extensive testing, Zulip consultation

---

## Go/No-Go Recommendation

### CONDITIONAL GO

**GO IF**:
- ✅ User accepts 60-80 hour effort
- ✅ User accepts 25-50% compilation slowdown
- ✅ User accepts HIGH risk during migration
- ✅ User commits to incremental approach
- ✅ User has rollback plan

**NO-GO IF**:
- ❌ Performance degradation >50% unacceptable
- ❌ Cannot allocate 60-80 hours
- ❌ Need immediate production stability
- ❌ Cannot tolerate breaking changes

---

## Alternative Approaches

### Alternative 1: Hybrid (Keep Both Types)
- Keep `Derivable : Prop` for proofs
- Add `DerivationTree : Type` for analysis
- **Pros**: No breaking changes, best of both worlds
- **Cons**: Maintenance burden, conversion overhead

### Alternative 2: Minimal Migration (Height Only)
- Keep `Derivable : Prop`
- Add computable height separately
- **Pros**: Minimal changes
- **Cons**: Still uses axioms, limited benefits

---

## Next Steps

1. **User Decision**: GO / NO-GO / Modify approach
2. **If GO**: Create git branch, begin Phase 1
3. **If NO-GO**: Document decision, consider Alternative 1

---

## References

- **Full Migration Plan**: `.opencode/specs/058_migration_to_type/reports/migration-plan-001.md`
- **Previous Research**: `.opencode/specs/057_deep_embedding_research/reports/research-001.md`
- **Project State**: `.opencode/specs/058_migration_to_type/state.json`

---

**Summary Complete**: 2025-12-19
