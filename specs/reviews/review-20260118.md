# Code Review Report: Metalogic_v2 Independence Assessment

**Date**: 2026-01-18
**Scope**: Theories/Bimodal/Metalogic_v2/ - Representation-first architecture for TM bimodal logic
**Reviewed by**: Claude

## Summary

This review evaluates the Metalogic_v2/ directory's progress toward its stated goal: providing a complete restructuring of the old Bimodal/Metalogic/ to put the representation theorem at the center, from which completeness, decidability, and compactness results follow, while remaining totally independent of the old Metalogic/ directory.

- **Total files reviewed**: 18 Lean files
- **Critical issues**: 0
- **High priority issues**: 2
- **Medium priority issues**: 3
- **Low priority issues**: 2

## Executive Assessment

### Independence from Old Metalogic/: **ACHIEVED**

The Metalogic_v2/ directory has **zero code dependencies** on the old Metalogic/ directory. All 18 Lean files import only from:
- `Bimodal.Metalogic_v2.*` (internal)
- `Bimodal.ProofSystem`
- `Bimodal.Semantics`
- `Mathlib.*`

The only references to old Metalogic are in the README.md (documentation for migration guidance).

### Representation-Centered Architecture: **PARTIALLY ACHIEVED**

The architecture places the Representation layer correctly:

```
Core (Basic, Provability, DeductionTheorem, MaximalConsistent)
  ↓
Representation (CanonicalModel, TruthLemma, RepresentationTheorem, ContextProvability, FiniteModelProperty)
  ↓
FMP.lean (central hub)
  ↓
Completeness (WeakCompleteness, StrongCompleteness) + Applications (Compactness)
```

Key theorems successfully derived from this architecture:
- `weak_completeness`: valid φ → provable φ
- `strong_completeness`: Γ ⊨ φ → Γ ⊢ φ
- `provable_iff_valid`: ContextDerivable [] φ ↔ valid φ
- `main_provable_iff_valid_v2`: Nonempty (⊢ phi) ↔ valid phi
- `compactness_entailment`, `compactness_satisfiability`, `compactness_unsatisfiability`
- `finite_model_property`
- `satisfiability_decidable`, `validity_decidable_via_fmp`

### Remaining Technical Debt

| Metric | Metalogic_v2/ | Old Metalogic/ | Improvement |
|--------|---------------|----------------|-------------|
| Sorry count | 12 | 132 | 91% reduction |
| Axiom declarations | 0 | 0 | Maintained |
| Noncomputable defs | 11 | (uncounted) | N/A |
| File count | 18 | 23 | Leaner structure |

## High Priority Issues

### H1. Sorries in Semantic Bridge Lemmas

**Files affected**:
- `Representation/SemanticCanonicalModel.lean` (lines 207, 286, 404, 554)
- `Representation/Closure.lean` (lines 347, 471)
- `Representation/FiniteWorldState.lean` (line 321)

**Description**: 7 sorries remain in the semantic bridge infrastructure connecting MCS membership to semantic truth. These are concentrated in:
1. `semantic_task_rel_compositionality` (time arithmetic)
2. `finiteHistoryToWorldHistory` (history construction)
3. `semantic_truth_implies_truth_at` (the central bridge lemma)
4. `main_weak_completeness_v2` helper lemmas

**Impact**: While the main theorems (weak/strong completeness) compile without sorries by routing through proven lemmas, the underlying semantic machinery has gaps. These sorries block:
- Full computational decidability (currently using `Decidable.decide` fallbacks)
- Constructive model extraction
- Verification of finite model bounds

**Recommendation**: Create focused tasks to prove these lemmas, particularly `semantic_truth_implies_truth_at` which is the key bridge.

---

### H2. README Documentation Claims Inaccuracy

**File**: `Metalogic_v2/README.md:93`

**Description**: The README states "All theorems in Metalogic_v2 are fully proven with no sorry statements" which is false. There are 12 sorry occurrences (7 active sorries in proofs).

**Impact**: Misleading documentation could lead to incorrect assumptions about proof completeness.

**Recommendation**: Update README to accurately reflect the sorry count and location.

---

## Medium Priority Issues

### M1. Missing Decidability Layer

**Current state**: The old Metalogic/ has a full Decidability/ subdirectory (8 files, 61KB):
- `Tableau.lean` - Tableau calculus
- `SignedFormula.lean` - Signed formulas
- `Saturation.lean` - Saturation procedures
- `DecisionProcedure.lean` - Main decision algorithm
- `ProofExtraction.lean` - Proof extraction from tableaux
- `CountermodelExtraction.lean` - Countermodel extraction
- `Correctness.lean` - Correctness proofs
- `Closure.lean` - Closure properties

**Description**: Metalogic_v2/ has no Decidability/ layer. While `validity_decidable_via_fmp` and `satisfiability_decidable` exist in FMP.lean, they use the FMP trivially (identity witness on satisfiability) rather than providing constructive decision procedures.

**Impact**: Cannot fully deprecate old Metalogic/ until decidability infrastructure is ported.

**Recommendation**: Create task to port Decidability/ to Metalogic_v2/ architecture, integrating with FMP as the bridge theorem.

---

### M2. Noncomputable Definitions

**Count**: 11 noncomputable definitions

**Description**: Several core definitions are marked `noncomputable`, which is acceptable for classical metalogic but limits computational use.

**Key noncomputable items**:
- `SemanticCanonicalModel`
- `finiteHistoryToWorldHistory`
- `semantic_valuation`

**Impact**: Cannot #eval or computationally test the semantic machinery.

**Recommendation**: Document which definitions must remain noncomputable (classical logic) vs. which could be made computable with more work.

---

### M3. Closure Infrastructure Sorries

**File**: `Representation/Closure.lean`

**Description**: Two sorries in closure-related lemmas:
- Line 347: `closure_finite_formula` - requires detailed case analysis on formula structure
- Line 471: Technical lemma for closure bounds

**Impact**: These block constructive finite model bounds (currently using identity witness).

**Recommendation**: These should be prioritized after the semantic bridge lemmas (H1) since they're prerequisites for constructive FMP.

---

## Low Priority Issues

### L1. Unused Variable Warning

**File**: `Representation/Closure.lean:257`
**Message**: `unused variable 'h_clos'`

**Recommendation**: Remove or use the variable.

---

### L2. Suggested Tactic Simplifications

**File**: `Representation/RepresentationTheorem.lean`
**Lines**: 52, 163
**Message**: `Try this: intro L hL ⟨d⟩` and similar

**Recommendation**: Apply suggested simplifications for cleaner proofs.

---

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Sorry count | 7 active | Warning |
| Axiom declarations | 0 | OK |
| Build status | Pass | OK |
| Import cycles | None detected | OK |
| Old Metalogic imports | 0 (in .lean) | OK |

## Architectural Strengths

1. **Clean layering**: Core → Representation → FMP → Completeness/Applications
2. **No import cycles**: The layered architecture eliminates the import cycle problems of old Metalogic/
3. **Consolidated MCS theory**: MaximalConsistent.lean provides single source of truth
4. **Central hub pattern**: FMP.lean effectively serves as the bridge point
5. **Proven main theorems**: weak_completeness, strong_completeness, provable_iff_valid all compile cleanly

## Recommendations (Priority Order)

1. **[HIGH]** Complete the semantic bridge lemmas in SemanticCanonicalModel.lean, particularly `semantic_truth_implies_truth_at`
2. **[HIGH]** Update README.md to accurately document sorry count and locations
3. **[MEDIUM]** Port Decidability/ infrastructure to Metalogic_v2/ architecture
4. **[MEDIUM]** Complete closure infrastructure sorries in Closure.lean
5. **[LOW]** Clean up unused variables and apply suggested tactic simplifications
6. **[LOW]** Document noncomputable vs. potentially-computable definitions

## Conclusion

Metalogic_v2/ has **successfully achieved independence** from the old Metalogic/ directory at the code level. The representation-first architecture is sound and the main completeness theorems are proven. However, **7 sorries remain** in the underlying semantic bridge infrastructure, and the **Decidability layer is missing entirely**.

Before the old Metalogic/ can be deleted:
1. The 7 semantic bridge sorries should be resolved (or explicitly documented as acceptable)
2. The Decidability infrastructure needs to be ported

Overall assessment: **Good progress (75% complete)** toward the stated goal. The critical path is now the semantic bridge lemmas and decidability port.
