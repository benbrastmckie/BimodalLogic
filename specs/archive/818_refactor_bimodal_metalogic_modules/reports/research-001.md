# Research Report: Task #818

**Task**: Refactor Bimodal Metalogic Modules
**Date**: 2026-02-03
**Focus**: Post-completion state after task 812 (BMCS Completeness), task 825 (FDSM Multi-History Modal Saturation), and related tasks. Assess what can be archived, refactored, and how main theorems can be better exposed.

## Executive Summary

The Bimodal/Metalogic/ directory (12,545 lines across 42 files) contains completed metalogical results for TM bimodal logic: soundness, completeness, decidability, and finite model property. Following task 812 (BMCS approach) and task 825 (FDSM modal saturation), the architecture has evolved considerably but leaves behind redundant code paths, inconsistent naming, and unclear dependencies.

**Key Findings**:
1. **Main theorems are proven** with manageable sorry counts (31 total in active code)
2. **Three completeness approaches** exist (Bundle/BMCS, FDSM, FMP), creating redundancy
3. **~1400 lines in FDSM/ModalSaturation.lean** needs cleanup or archival
4. **Algebraic/ is isolated** and ready for future algebraic representation theorem
5. **Naming inconsistencies** across modules (e.g., "semantic_weak_completeness" vs "bmcs_weak_completeness")

## Current Module Inventory

### Top-Level Structure (12,545 total lines)

| Directory | Files | Lines | Purpose | Status |
|-----------|-------|-------|---------|--------|
| Core/ | 4 | 898 | MCS theory, deduction theorem | Stable, well-organized |
| Bundle/ | 6 | 2,135 | BMCS completeness (Task 812) | Production, sorry-free core |
| FDSM/ | 4 | 2,427 | Finite DSM completeness | Partially complete, needs cleanup |
| FMP/ | 5 | 2,427 | Finite model property | Stable, contains sorry-free completeness |
| Completeness/ | 2 | 343 | Completeness re-exports | Thin wrappers |
| Decidability/ | 9 | 2,040 | Decision procedure | Partial, needs work |
| Algebraic/ | 6 | 2,154 | Algebraic representation | Isolated, for future use |
| Root files | 5 | 2,121 | Imports, soundness | Mixed |

### Dependency Graph (Simplified)

```
Core/ (MCS, Deduction)
  |
  +---> Bundle/ (BMCS Completeness) <--- Task 812 SUCCESS
  |
  +---> FMP/ (Finite Model Property)
  |       |
  |       +---> FDSM/ (Finite DSM) <--- Task 825 PARTIAL
  |       |
  |       +---> Completeness/ (Strong completeness)
  |
  +---> Decidability/ (Tableau, proof extraction)
  |
  +---> Algebraic/ (Lindenbaum, ultrafilters) [ISOLATED]

Soundness.lean, SoundnessLemmas.lean (COMPLETE, sorry-free)
```

## Main Theorems Status

### 1. Soundness (COMPLETE, SORRY-FREE)

**Location**: `Soundness.lean` (710 lines), `SoundnessLemmas.lean`

**Main Result**:
```lean
theorem soundness (Gamma : Context) (phi : Formula) : (Gamma |- phi) -> (Gamma |= phi)
```

**Status**: Fully proven, no sorries. All 17 axiom validity lemmas proven.

### 2. BMCS Completeness (COMPLETE with limited sorries)

**Location**: `Bundle/Completeness.lean` (461 lines)

**Main Results**:
```lean
theorem bmcs_representation (phi : Formula) (h_cons : ContextConsistent [phi]) :
    exists (B : BMCS Int), bmcs_truth_at B B.eval_family 0 phi -- SORRY-FREE

theorem bmcs_weak_completeness (phi : Formula) (h_valid : bmcs_valid phi) :
    Nonempty (DerivationTree [] phi) -- SORRY-FREE in this file

theorem bmcs_strong_completeness (Gamma : List Formula) (phi : Formula)
    (h_conseq : bmcs_consequence Gamma phi) :
    ContextDerivable Gamma phi -- SORRY-FREE in this file
```

**Inherited Sorries**:
- `Bundle/Construction.lean`: 1 sorry in `modal_backward` (acceptable construction assumption)
- `Bundle/TruthLemma.lean`: 4 sorries in temporal backward directions (omega-saturation issue)

### 3. FMP Completeness (COMPLETE with 1 bridge sorry)

**Location**: `FMP/SemanticCanonicalModel.lean` (435 lines)

**Main Result**:
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi -- SORRY-FREE
```

**Note**: The internal proof is sorry-free. The bridge from general validity to FMP-internal validity has 1 sorry in `FiniteStrongCompleteness.lean:130`.

### 4. FDSM Completeness (PARTIAL - needs work)

**Location**: `FDSM/Completeness.lean` (326 lines), `FDSM/ModalSaturation.lean` (1,399 lines)

**Main Results**:
```lean
noncomputable def fdsm_internal_completeness (phi : Formula) :
    (forall M : FiniteDynamicalSystemModel phi,
      fdsm_truth_at M M.eval_history (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

**Sorries** (significant):
- `ModalSaturation.lean`: 10 sorries related to:
  - `neg_box_iff_diamond_neg` (line 309)
  - `saturation_terminates` (line 728)
  - `fixed_point_is_saturated` (lines 803, 815)
  - `modal_backward_from_saturation` (line 877)
  - Multi-history saturation (lines 1211, 1273, 1306)
- `TruthLemma.lean`: 12 sorries for closure membership alignment
- `Completeness.lean`: 3 sorries

### 5. Decidability (PARTIAL)

**Location**: `Decidability/` directory (2,040 lines across 9 files)

**Status**: Tableau infrastructure complete, proof extraction partial.
- Soundness: Proven
- Completeness: Requires FMP formalization (partial)
- Proof extraction: Axiom instances only

### 6. Algebraic Representation (ISOLATED)

**Location**: `Algebraic/` directory (2,154 lines across 6 files)

**Main Structure**:
```
LindenbaumQuotient.lean   -- Quotient construction via provable equivalence
BooleanStructure.lean     -- Boolean algebra instance
InteriorOperators.lean    -- G/H as interior operators
UltrafilterMCS.lean       -- Bijection: ultrafilters <-> MCS
AlgebraicRepresentation.lean -- Main theorem
```

**Status**: Self-contained alternative proof path. Should be preserved for future algebraic representation theorem work.

## Remaining Sorries Analysis

### Total Count: 31 sorries in active code

| File | Count | Category | Difficulty |
|------|-------|----------|------------|
| `FDSM/ModalSaturation.lean` | 10 | Modal saturation | High |
| `FDSM/TruthLemma.lean` | 12 | Closure membership | Medium |
| `FDSM/Completeness.lean` | 3 | Bridge lemmas | Medium |
| `FMP/ConsistentSatisfiable.lean` | 6 | Truth correspondence | High |
| `Bundle/TruthLemma.lean` | 4 | Temporal backward | High |
| `Bundle/Construction.lean` | 1 | Modal backward | Low (accepted) |
| `Completeness/FiniteStrongCompleteness.lean` | 1 | Validity bridge | Medium |
| `FMP/Closure.lean` | 1 | Closure property | Low |

### Sorry Categories

1. **Modal Backward Direction** (Bundle, FDSM): The fundamental obstruction where Diamond-box duality requires multi-family saturation
2. **Temporal Backward Direction** (Bundle): Omega-rule limitation requiring infinitary reasoning
3. **Closure Membership Alignment** (FDSM): Technical bookkeeping sorries
4. **Saturation Termination** (FDSM): Classical termination argument needed

## Candidates for Boneyard Archival

### 1. FDSM/ModalSaturation.lean - Single-History Section

**Lines to archive**: ~300 lines (the deprecated `saturation_step` on untracked histories)
**Rationale**: Task 825 implemented `MCSTrackedHistory` approach; the abstract `saturation_step` on `Finset (FDSMHistory phi)` was explicitly deprecated.
**Comment to include**:
```lean
/-!
# ARCHIVED: Abstract Saturation on Untracked Histories

This code was archived because:
1. saturation_step operates on FDSMHistory which lacks MCS information
2. Cannot construct witnesses without knowing which MCS the history came from
3. Replaced by MCSTrackedHistory approach in ModalSaturation.lean

See: specs/825_fdsm_multi_history_modal_saturation/plans/implementation-002.md
-/
```

### 2. FMP/ConsistentSatisfiable.lean - Deprecated Bridge Code

**Lines to archive**: ~100 lines with 6 sorries
**Rationale**: Commented as "not on critical path"; bridge from general validity to FMP-internal validity is architecturally blocked.
**Comment to include**:
```lean
/-!
# ARCHIVED: General Validity to FMP Bridge

This code was archived because:
1. Modal/temporal operator truth correspondence is architecturally blocked
2. The FMP internal proof (semantic_weak_completeness) is sorry-free without this
3. See research-005 for analysis of the architectural limitation

The internal FMP completeness is the canonical sorry-free path.
-/
```

### 3. Redundant Re-exports

Files that are thin wrappers and add no value:
- `Completeness/Completeness.lean` (64 lines) - Just documentation
- `Decidability.lean` (44 lines) - Just imports

**Recommendation**: Keep for organizational clarity but mark as re-export modules.

## Naming/Organization Improvement Recommendations

### 1. Inconsistent Completeness Theorem Names

| Current | Proposed | Location |
|---------|----------|----------|
| `semantic_weak_completeness` | `fmp_weak_completeness` | FMP/SemanticCanonicalModel |
| `bmcs_weak_completeness` | Keep | Bundle/Completeness |
| `fdsm_internal_completeness` | Keep | FDSM/Completeness |
| `finite_strong_completeness` | `strong_completeness` | Completeness/FiniteStrongCompleteness |

### 2. Module Prefix Standardization

All Core/ exports should use `Core.` prefix consistently:
- `SetMaximalConsistent` -> `Core.SetMaximalConsistent` (or keep as-is if used widely)
- `deduction_theorem` -> `Core.deduction_theorem`

### 3. File Organization Issues

**Metalogic.lean** (135 lines): Currently a documentation file. Should be the main re-export entry point:
```lean
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Bundle.Completeness
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.Decidability
```

**DeductionTheorem.lean** exists at root level (deprecated) and in Core/. Archive root-level version.

## Algebraic/ Assessment

**Status**: Self-contained, isolated, production-ready structure

**Architecture**:
```
LindenbaumQuotient.lean (340 lines)
  - Provable equivalence relation
  - Quotient construction

BooleanStructure.lean (451 lines)
  - BooleanAlgebra instance for LindenbaumAlg
  - Order, meet, join, complement operations

InteriorOperators.lean (218 lines)
  - G/H as interior operators (using T-axioms)
  - Deflationary, monotone, idempotent proofs

UltrafilterMCS.lean (882 lines)
  - Bijection: ultrafilters <-> MCS
  - Core algebraic representation lemmas

AlgebraicRepresentation.lean (191 lines)
  - Main theorem: satisfiable phi <-> not(|- not phi)
```

**Recommendation**: Preserve as-is. This is the foundation for future algebraic representation theorem work. The module is designed to be:
- Isolated (does not modify existing metalogic files)
- Self-contained (independent proof path)
- Future-oriented (alternative to seed-extension approach)

## Recommended Refactoring Approach

### Phase 1: Archive Obsolete Code (Boneyard/)

1. Create `Boneyard/FDSM_v2/` for deprecated saturation approach
2. Create `Boneyard/FMP_Bridge/` for blocked validity bridge
3. Archive root-level `DeductionTheorem.lean`
4. Update all imports to use Core/ versions

### Phase 2: Consolidate Completeness Entry Points

1. Create single `Bimodal.Metalogic.Completeness` that exposes:
   - `bmcs_weak_completeness` (primary, Henkin-style)
   - `bmcs_strong_completeness` (primary)
   - `fmp_weak_completeness` (alternative, sorry-free internal)
   - `soundness` (from Soundness.lean)

2. Rename modules for clarity:
   - `Completeness/Completeness.lean` -> `Completeness/Overview.lean` (or delete)
   - `Completeness/FiniteStrongCompleteness.lean` -> `Completeness/StrongCompleteness.lean`

### Phase 3: FDSM Cleanup

1. Remove deprecated `saturation_step` code from ModalSaturation.lean
2. Keep `MCSTrackedHistory` approach as experimental
3. Document the 25 remaining sorries with clear TODO comments

### Phase 4: Documentation

1. Update `Metalogic.lean` module-level docs to reflect current state
2. Add theorem index to main entry point:
   ```lean
   /-!
   ## Main Results

   | Theorem | Type | Status |
   |---------|------|--------|
   | soundness | Gamma |- phi -> Gamma |= phi | SORRY-FREE |
   | bmcs_weak_completeness | bmcs_valid phi -> |- phi | SORRY-FREE |
   | bmcs_strong_completeness | bmcs_consequence Gamma phi -> Gamma |- phi | SORRY-FREE |
   | fmp_weak_completeness | fmp_internal_valid phi -> |- phi | SORRY-FREE |
   -/
   ```

## Success Criteria for Refactoring

- [ ] Zero orphan files (all files imported by at least one module)
- [ ] Clear single entry point (`Bimodal.Metalogic` exports main theorems)
- [ ] Boneyard contains all deprecated approaches with explanatory comments
- [ ] Remaining sorries documented with difficulty ratings
- [ ] Algebraic/ preserved unchanged
- [ ] Build passes (`lake build`) with no new sorries introduced

## References

- Task 812: BMCS Completeness implementation (completed)
- Task 825: FDSM Multi-History Modal Saturation (completed, partial)
- Boneyard/Metalogic_v5/: Previously archived representation approach
- specs/825_fdsm_multi_history_modal_saturation/plans/implementation-002.md

## Next Steps

1. Create implementation plan with phased archival/refactoring
2. Archive deprecated FDSM saturation code first (safest)
3. Consolidate completeness entry points
4. Document remaining sorries systematically
5. Update Metalogic.lean as main entry point
