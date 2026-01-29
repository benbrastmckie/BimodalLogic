# Research Report: Task #750

**Task**: Refactor the metalogic to use a clean Two-Pillar Architecture
**Date**: 2026-01-29
**Focus**: Proof dependency structure after implementing implementation-001.md; what gets moved to Boneyard

## Summary

This research analyzes the proposed implementation plan for task 750 to determine the resulting proof dependency structure and identify which files can be safely archived. The analysis confirms that **the plan has a critical flaw**: the files marked for archival are actually **required** by the current completeness proofs. Archiving them would break `WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean`. An alternative approach is recommended.

## Findings

### 1. Current Dependency Graph

The current Metalogic/ directory has the following import dependency structure:

```
Completeness/
  WeakCompleteness.lean
    └── imports UniversalCanonicalModel.lean (CRITICAL)

  InfinitaryStrongCompleteness.lean
    └── imports UniversalCanonicalModel.lean (CRITICAL)
    └── uses construct_coherent_family, canonical_model, truth_lemma

Representation/
  UniversalCanonicalModel.lean
    ├── imports TruthLemma.lean
    ├── imports IndexedMCSFamily.lean
    └── imports CoherentConstruction.lean (CRITICAL)

  TruthLemma.lean
    ├── imports CanonicalHistory.lean
    └── imports IndexedMCSFamily.lean

  CanonicalHistory.lean
    ├── imports TaskRelation.lean
    └── imports IndexedMCSFamily.lean

  TaskRelation.lean
    └── imports CanonicalWorld.lean

  CoherentConstruction.lean
    └── imports IndexedMCSFamily.lean

  IndexedMCSFamily.lean
    └── imports CanonicalWorld.lean

FMP/
  SemanticCanonicalModel.lean
    └── imports WeakCompleteness.lean (circular dependency noted)
    └── DOES NOT import Representation/ files

  FiniteModelProperty.lean
    └── imports SemanticCanonicalModel.lean

Algebraic/
  AlgebraicRepresentation.lean
    └── imports UltrafilterMCS.lean
    └── DOES NOT import Representation/ files
```

### 2. Analysis of Archival Candidates

The implementation plan proposes archiving these files:

#### 2.1 CoherentConstruction.lean

**Sorries**: 10+ sorries
**Status**: **CANNOT BE ARCHIVED**

**Critical Dependency**: `UniversalCanonicalModel.lean` imports this file and uses:
- `construct_coherent_family`
- `construct_coherent_family_origin`

These are used in `representation_theorem` which is the foundation of `weak_completeness` in `WeakCompleteness.lean`.

If archived:
- `UniversalCanonicalModel.lean` would fail to compile
- `WeakCompleteness.lean` would fail
- `InfinitaryStrongCompleteness.lean` would fail

#### 2.2 CanonicalHistory.lean

**Sorries**: 2 sorries (T-axiom applications)
**Status**: **CANNOT BE ARCHIVED**

**Critical Dependency**: `TruthLemma.lean` imports this file.

If archived:
- `TruthLemma.lean` would fail to compile
- `UniversalCanonicalModel.lean` would fail (imports TruthLemma)
- Cascading failure through completeness proofs

#### 2.3 TaskRelation.lean

**Sorries**: 5 sorries
**Status**: **CANNOT BE ARCHIVED**

**Critical Dependency**: `CanonicalHistory.lean` imports this file.

If archived:
- `CanonicalHistory.lean` would fail
- Cascading failure to TruthLemma and completeness proofs

#### 2.4 UniversalCanonicalModel.lean

**Sorries**: 4 sorries (including the critical `h_no_G_bot`, `h_no_H_bot` lemmas)
**Status**: **CANNOT BE ARCHIVED**

**Critical Dependency**: Both `WeakCompleteness.lean` and `InfinitaryStrongCompleteness.lean` import this file directly.

```lean
-- WeakCompleteness.lean line 4:
import Bimodal.Metalogic.Representation.UniversalCanonicalModel

-- InfinitaryStrongCompleteness.lean line 2:
import Bimodal.Metalogic.Representation.UniversalCanonicalModel
```

The completeness proofs use:
- `representation_theorem`
- `canonical_model`
- `canonical_history_family`
- `construct_coherent_family`
- `truth_lemma`

If archived:
- Both completeness modules would fail to compile
- No completeness proofs would work

### 3. Files Safe to Keep (Verified)

#### 3.1 IndexedMCSFamily.lean

**Sorries**: 4 sorries (in helper lemmas, not core definitions)
**Used By**: TruthLemma, CanonicalHistory, CoherentConstruction, UniversalCanonicalModel, Boneyard
**Status**: Must keep - foundational data structure

#### 3.2 CanonicalWorld.lean

**Sorries**: 2 sorries (neg_complete, deductively_closed)
**Used By**: IndexedMCSFamily, TaskRelation
**Status**: Must keep - foundational data structure

### 4. The Two Pillars (Current State)

#### Pillar A: Algebraic Path (Algebraic/)

**Key Theorem**: `algebraic_representation_theorem`
```lean
theorem algebraic_representation_theorem (φ : Formula) :
    AlgSatisfiable φ ↔ AlgConsistent φ
```

**Status**: SORRY-FREE in AlgebraicRepresentation.lean (verified by grep)
**Imports**: Does NOT import any Representation/ files
**Independent**: Yes, this path is fully independent

**Limitation**: Proves satisfiability iff consistency using ultrafilters, but does NOT connect to the semantic `truth_at` predicate used by `valid` and standard completeness statements.

#### Pillar B: FMP/Semantic Path (FMP/)

**Key Theorem**: `semantic_weak_completeness`
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

**Status**: PROVEN (verified - no sorry in the theorem itself)
**Known Sorry**: `compositionality` axiom in `SemanticCanonicalFrame` (documented as mathematically false for unbounded durations)
**Imports**: `WeakCompleteness.lean` (circular dependency with Representation/)

**Limitation**: Uses `semantic_truth_at_v2` which is a specialized finite-model truth predicate, not the standard `truth_at` used in `valid`.

### 5. The Representation Path (Representation/)

**Key Theorem**: `weak_completeness` in WeakCompleteness.lean
```lean
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ
```

**Status**: PROVEN using `representation_theorem` from UniversalCanonicalModel
**Sorries**: Soundness is axiomatized (sorry in `soundness` lemma)
**Depends On**: The entire Representation/ chain that was proposed for archival

### 6. Sorry Inventory

| File | Sorries | Impact |
|------|---------|--------|
| TruthLemma.lean | 4 | Box cases (architectural), backward temporal (omega-rule) |
| CoherentConstruction.lean | 10+ | Consistency arguments for family construction |
| CanonicalHistory.lean | 2 | T-axiom applications |
| TaskRelation.lean | 5 | MCS equality and temporal propagation |
| UniversalCanonicalModel.lean | 4 | G-bot/H-bot exclusion, non_provable_satisfiable |
| IndexedMCSFamily.lean | 4 | Helper lemmas |
| CanonicalWorld.lean | 2 | neg_complete, deductively_closed |
| WeakCompleteness.lean | 1 | soundness (axiomatized) |
| FMP/SemanticCanonicalModel.lean | 1 | compositionality (documented as false) |
| FMP/FiniteModelProperty.lean | 1 | truth bridge |

## Recommendations

### 1. Do NOT Archive the Proposed Files

The implementation plan's Phase 3 would break the build. The files marked for archival are:
- **Directly imported** by completeness modules
- **Provide essential definitions** (construct_coherent_family, truth_lemma, canonical_model)
- **Cannot be replaced** by the Algebraic or FMP paths without significant refactoring

### 2. Alternative: Documentation-Only Approach

Instead of archiving, the plan should be modified to:

1. **Phase 2 (Refactor TruthLemma)**: Proceed as planned - remove backward direction sorries
2. **Phase 3 (Archive)**: SKIP - do not archive any files
3. **Phase 4 (Documentation)**: Document the Two-Pillar Architecture in README.md
4. **Phase 5 (Cross-references)**: Proceed as planned

### 3. Future Work: True Two-Pillar Independence

To actually achieve independent two-pillar architecture:

**Option A**: Make FMP path connect to standard `valid`
- Replace `semantic_truth_at_v2` with standard `truth_at`
- Prove the truth bridge between finite model truth and standard truth
- Then FMP path would provide an alternative to Representation/

**Option B**: Make Algebraic path prove standard completeness
- Add a theorem connecting `AlgSatisfiable` to standard `valid`
- Would require defining algebraic semantics compatible with `truth_at`

**Option C**: Accept the current architecture
- Document that Representation/ is the canonical path
- Document that Algebraic/ proves a parallel result in algebraic semantics
- Document that FMP/ provides finite model bounds

### 4. Safe Sorries to Remove

The TruthLemma sorries in Phase 2 ARE safe to address:
- Box case sorries: documented architectural limitations, not needed for completeness
- Backward temporal sorries: require omega-rule, not needed for forward direction

These can be removed (along with the code) without breaking anything.

## Risk Assessment

| Action | Risk | Recommendation |
|--------|------|----------------|
| Archive CoherentConstruction | **CRITICAL** - Breaks build | Do NOT archive |
| Archive CanonicalHistory | **CRITICAL** - Breaks build | Do NOT archive |
| Archive TaskRelation | **CRITICAL** - Breaks build | Do NOT archive |
| Archive UniversalCanonicalModel | **CRITICAL** - Breaks build | Do NOT archive |
| Remove TruthLemma backward direction | Low - not used | Safe to do |
| Remove TruthLemma box cases | Low - documented limitation | Safe to do |
| Documentation updates | None | Proceed |

## References

- Implementation plan: `specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-001.md`
- WeakCompleteness: `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean`
- InfinitaryStrongCompleteness: `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
- AlgebraicRepresentation: `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean`
- SemanticCanonicalModel: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

## Next Steps

1. **Revise implementation plan** to remove Phase 3 (archival)
2. **Proceed with Phase 2** - simplify TruthLemma to forward-only
3. **Proceed with Phase 4** - update documentation
4. **Proceed with Phase 5** - add cross-references
5. **Create follow-up task** if true two-pillar independence is desired
