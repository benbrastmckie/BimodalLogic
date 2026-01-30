# Research Report: Task #773

**Task**: 773 - update_metalogic_typst_documentation
**Date**: 2026-01-30
**Session**: sess_1769733973_ada98a
**Focus**: Compare current 04-metalogic.typ content with recent Lean metalogic codebase changes

## Executive Summary

The Typst documentation in `04-metalogic.typ` (502 lines) is outdated and references deprecated code paths. Recent tasks (750, 760, 764, 769, 772) have significantly restructured the metalogic codebase, establishing `semantic_weak_completeness` as the canonical sorry-free completeness theorem while deprecating the `representation_theorem` approach.

**Key finding**: The documentation presents `representation_theorem` as the "pivotal result" when the codebase has migrated to `semantic_weak_completeness` as the primary completeness proof. This is the most significant discrepancy.

## Current Documentation Analysis

### Structure of 04-metalogic.typ (502 lines)

| Section | Lines | Content |
|---------|-------|---------|
| Introduction | 1-14 | Overview, mentions representation theorem |
| Soundness | 15-61 | 14 axiom validity table (now 15 axioms) |
| Core Infrastructure | 62-110 | Deduction theorem, MCS, Lindenbaum |
| Representation Theory | 111-232 | Canonical model, truth lemma, diagram |
| Completeness as Corollary | 233-302 | Weak/strong completeness |
| Decidability | 303-377 | Tableau-based decision procedure |
| File Organization | 378-435 | Directory structure diagram |
| Implementation Status | 436-502 | Sorry status tables |

### What the Documentation Says

1. **Completeness approach**: "Representation Theorem is the core of the metalogic" (line 113)
2. **Truth Lemma location**: `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (line 155)
3. **Representation Theorem location**: `UniversalCanonicalModel.lean` (lines 165-166)
4. **Sorry count**: "3 remaining sorry statements" in Metalogic_v2 (lines 440-447)
5. **Two approaches**: Syntactic (archived) vs Semantic (primary) canonical models

## Current Codebase State

### Directory Structure Changes

The codebase now has:
```
Theories/Bimodal/Metalogic/
├── Core/              # MCS theory, deduction theorem
├── Soundness/         # 15 axioms, 7 rules (migrated from Boneyard 2026-01-29)
├── Representation/    # Canonical model (contains deprecated code)
├── FMP/               # Finite Model Property - NEW PRIMARY LOCATION for completeness
├── Completeness/      # WeakCompleteness.lean uses representation_theorem
├── Compactness/
└── Algebraic/         # Alternative approach (NEW - sorry-free)
```

### Key Changes Since Documentation

| Aspect | Documentation Says | Codebase Now |
|--------|-------------------|--------------|
| Primary completeness | `representation_theorem` | `semantic_weak_completeness` |
| Sorry count | 3 in Metalogic_v2 | 20 in Metalogic/ (all deprecated) |
| Completeness location | Representation/UniversalCanonicalModel | FMP/SemanticCanonicalModel |
| Axiom count | 14 axioms | 15 axioms |
| Soundness location | Not specified | Soundness/ subdirectory |
| Algebraic approach | Not mentioned | Algebraic/ subdirectory (complete) |
| Boneyard status | Contains syntactic approach | Pure historical reference |

### The Completeness Story Has Changed

**Old approach (documented)**:
```
representation_theorem → truth_lemma → weak_completeness
```
- Uses `Representation/UniversalCanonicalModel.lean`
- Depends on truth lemma with architectural sorries
- Has Box semantics limitation (S5-style universal quantification)

**New approach (not documented)**:
```
semantic_weak_completeness (contrapositive, sorry-free)
```
- Located in `FMP/SemanticCanonicalModel.lean`
- Works via contrapositive: unprovable → countermodel exists
- Avoids truth bridge gap entirely
- **Completely sorry-free**

### Sorry Analysis

The documentation's "Implementation Status" section (lines 436-502) is outdated:

| Documentation Says | Current Reality |
|-------------------|-----------------|
| 3 sorries in Metalogic_v2 | That namespace is deprecated |
| Lists specific line numbers | Line numbers have changed |
| `semantic_task_rel_compositionality` | Still exists but DEPRECATED |
| Core completeness "fully proven" | Now via `semantic_weak_completeness` |

**Current sorry inventory** (from Task 769):
- TruthLemma.lean: 4 sorries (architectural - omega-rule/S5 box)
- TaskRelation.lean: 5 sorries (not required for completeness)
- CoherentConstruction.lean: 8 sorries (not required for completeness)
- SemanticCanonicalModel.lean: 2 sorries (architectural - frame compositionality)
- FiniteModelProperty.lean: 1 sorry (alternative path)
- **Total**: 20 sorries, ALL deprecated with references to sorry-free alternative

## Specific Updates Needed

### 1. Introduction Section (Lines 1-14)

**Current**: "This chapter presents a representation theorem from which completeness and compactness follow as corollaries."

**Update**: Should acknowledge that `semantic_weak_completeness` is the primary completeness theorem, while the representation theorem provides supporting infrastructure.

### 2. Soundness Section (Lines 15-61)

**Issues**:
- Table shows 14 axioms; codebase has 15 (check for MF/TF additions)
- Lean theorem names may have changed
- Need to verify axiom table against `Soundness/Soundness.lean`

### 3. Representation Theory Section (Lines 111-232)

**Major update needed**:
- Lines 164-166: `representation_theorem` is no longer the pivotal result
- Add note that this approach has architectural limitations
- Reference `semantic_weak_completeness` as the sorry-free alternative
- Update the theorem dependency diagram (lines 184-228) to show new structure

### 4. Completeness Section (Lines 233-302)

**Updates needed**:
- Line 243: `semantic_weak_completeness` should be the primary theorem
- Line 268: `main_strong_completeness` status needs verification
- Add section on the contrapositive approach
- Document why representation_theorem has sorries

### 5. File Organization Section (Lines 378-435)

**Outdated**:
- Missing `Soundness/` directory
- Missing `Algebraic/` directory
- FMP description incomplete (doesn't mention semantic completeness)
- Dependency diagram needs update

### 6. Implementation Status Section (Lines 436-502)

**Complete rewrite needed**:
- Sorry count changed (3 → 20, but all deprecated)
- All sorries are now documented as architectural limitations
- `semantic_weak_completeness` is THE completeness theorem
- Update both tables with current status

## Recommendations

### High Priority Updates

1. **Add `semantic_weak_completeness` as primary completeness theorem**
   - New section or update to Completeness section
   - Explain contrapositive approach
   - Note that it's completely sorry-free

2. **Update Implementation Status tables**
   - Reflect 20 architectural sorries (all deprecated)
   - Show sorry-free path via `semantic_weak_completeness`
   - Update Lean theorem names and line numbers

3. **Update File Organization diagram**
   - Add Soundness/ and Algebraic/ directories
   - Show FMP/ contains primary completeness theorem
   - Update dependency arrows

### Medium Priority Updates

4. **Revise Representation Theory framing**
   - Representation theorem provides infrastructure
   - Truth lemma has architectural limitations
   - Point to FMP/ for sorry-free completeness

5. **Verify axiom table**
   - Check for 15th axiom
   - Verify Lean theorem names

6. **Add Algebraic approach section**
   - Lindenbaum quotient
   - Boolean algebra structure
   - Alternative completeness path (also sorry-free)

### Low Priority (Cosmetic)

7. **Update line number references**
   - All specific line numbers are likely stale

8. **Update Boneyard references**
   - Currently describes syntactic vs semantic
   - Now purely historical reference

## Content to Add

### New Section: The Contrapositive Approach

The documentation should explain why `semantic_weak_completeness` works:

1. Contrapositive: `valid phi → ⊢ phi` becomes `¬⊢ phi → ¬valid phi`
2. If phi is not provable, then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS (finite subset)
5. Build FiniteWorldState from closure MCS
6. phi is false at this world state (by construction)
7. This gives a countermodel, so phi is not valid

This avoids the truth bridge gap because the assignment IS the MCS membership function.

### New Section: Algebraic Approach (Optional)

The `Algebraic/` subdirectory provides an alternative sorry-free completeness path:
- LindenbaumQuotient.lean
- BooleanStructure.lean
- InteriorOperators.lean
- UltrafilterMCS.lean
- AlgebraicRepresentation.lean

## References

- Task 750: Truth bridge analysis (confirmed architectural limitation)
- Task 760: Sorry disposition (ARCHIVE vs COMPLETE)
- Task 764: Migration to self-contained Metalogic/
- Task 769: Sorry audit (20 sorries, all deprecated)
- Task 772: Plan for sorry-free archive
- `Theories/Bimodal/Metalogic/README.md`: Current architecture documentation
- `Theories/Bimodal/Metalogic/FMP/README.md`: FMP details including completeness

## Next Steps

1. Run `/plan 773` to create implementation plan with specific edits
2. Implementation should update all 6 sections identified above
3. Verify Typst compiles after changes
4. Consider updating the theorem dependency diagram (CeTZ figure)
