# Research Report: Task #760

**Task**: Determine Sorry Disposition - Archive vs Complete
**Date**: 2026-01-29
**Focus**: Categorize remaining sorries as ARCHIVE (move to Boneyard) or COMPLETE (prove for sorry-free codebase)

## Summary

Analysis of the codebase reveals approximately 40 actual code sorries in the main (non-Boneyard) `Theories/` directory. These fall into distinct categories: architectural limitations that cannot be resolved, exploratory/exercise code, non-critical alternative paths, and dead code. The main completeness theorem `semantic_weak_completeness` is already sorry-free, providing the core metatheoretical result without these gaps.

## Findings

### 1. Sorries in Main Metalogic Code (NOT Critical Path)

These sorries exist in the main Metalogic/ directory but are NOT on the critical path for `semantic_weak_completeness`.

#### 1.1 TruthLemma.lean - 4 sorries (Lines 366, 389, 416, 438)
**Location**: `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
**Nature**: Architectural limitations

| Sorry | Description | Root Cause |
|-------|-------------|------------|
| Line 366 | Box forward direction | Box semantics quantifies over ALL histories; canonical model only has one |
| Line 389 | Box backward direction | Necessitation rule only works for theorems, not MCS membership |
| Line 416 | H backward direction | Omega-rule limitation: cannot derive Hphi from infinitely many phi instances |
| Line 438 | G backward direction | Omega-rule limitation: symmetric to H case |

**Recommendation**: **KEEP AS-IS (DOCUMENTED)** - These are architectural limitations with extensive inline documentation. The backward directions are explicitly marked "NOT REQUIRED FOR COMPLETENESS". Moving to Boneyard would lose the educational documentation.

#### 1.2 CoherentConstruction.lean - 8 sorries (Lines 712, 715, 723, 726, 744, 751, 799, 802)
**Location**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
**Nature**: Cross-origin coherence cases

**All sorries are marked "NOT REQUIRED FOR COMPLETENESS"** and reference `Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`.

**Recommendation**: **ARCHIVE** - These cross-origin cases are not needed for the main completeness proof. The code could delegate to Boneyard or be moved there entirely.

#### 1.3 TaskRelation.lean - 5 sorries (Lines 173, 186, 190, 196, 199)
**Location**: `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
**Nature**: Compositionality proof for task relation

These are complex case analyses for the task relation's compositionality property involving mixed-sign durations.

**Recommendation**: **ARCHIVE** - Task relation compositionality is not on the critical path for `semantic_weak_completeness`. The sorried lemma `canonical_task_rel_compositionality` is used by constructions that are themselves not the primary completeness path.

#### 1.4 IndexedMCSFamily.lean - 4 sorries (Lines 620, 626, 632, 638)
**Location**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
**Nature**: Coherence delegation in `construct_indexed_family`

**Task 758 finding**: This is DEAD CODE - `construct_indexed_family` is not used anywhere in the codebase. The main completeness proofs use `construct_coherent_family` through CoherentConstruction.

**Recommendation**: **ARCHIVE** - Move `construct_indexed_family` to Boneyard as it provides an alternative approach not integrated with the main codebase.

### 2. FMP/SemanticCanonicalModel Sorries (Alternative Path)

#### 2.1 SemanticCanonicalModel.lean - 2 sorries (Lines 226, 684)
**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

| Sorry | Description | Status |
|-------|-------------|--------|
| Line 226 | `compositionality` axiom in SemanticCanonicalFrame | **MATHEMATICALLY IMPOSSIBLE** - documented limitation |
| Line 684 | `truth_at_implies_semantic_truth` | Forward truth lemma gap - architectural |

**Recommendation**: **KEEP AS-IS (DOCUMENTED)** - The file explicitly documents that `semantic_weak_completeness` IS sorry-free and these gaps are for alternative paths. The compositionality sorry is mathematically provably impossible (finite time domain cannot accommodate unbounded duration sums).

#### 2.2 FiniteModelProperty.lean - 1 sorry (Line 221)
**Location**: `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`

The `finite_model_property_constructive` theorem has a truth bridge sorry. Documentation explicitly states: "The core completeness is provided by `semantic_weak_completeness`."

**Recommendation**: **KEEP AS-IS (DOCUMENTED)** - This provides a pedagogical alternative path with clear documentation about the sorry-free alternative.

### 3. AlgebraicSemanticBridge Sorries (Alternative Approach)

**Location**: `Theories/Bimodal/Metalogic/Algebraic/AlgebraicSemanticBridge.lean`
**Count**: 8 sorries (Lines 301, 307, 325, 328, 342, 347, 358, 362)

This module provides an ALTERNATIVE completeness path via algebraic representation. It is NOT the primary completeness path.

| Category | Lines | Count | Description |
|----------|-------|-------|-------------|
| Classical prop logic | 301, 307 | 2 | Provable with ~100 lines infrastructure |
| Box case | 325, 328 | 2 | Requires reasoning about ALL ultrafilters |
| Temporal cases | 342, 347, 358, 362 | 4 | Time-independence for constant histories |

**Recommendation**: **ARCHIVE** - The algebraic approach is exploratory and not integrated with the main completeness path. HybridCompleteness.lean documents this is alternative infrastructure.

### 4. Example/Exercise Sorries (Educational)

**Locations**:
- `Theories/Bimodal/Examples/TemporalProofs.lean` - 2 sorries (Lines 180, 194)
- `Theories/Bimodal/Examples/ModalProofStrategies.lean` - 5 sorries (Lines 204, 252, 295, 325, 430)
- `Theories/Bimodal/Examples/ModalProofs.lean` - 5 sorries (Lines 168, 183, 196, 249, 256)

**Nature**: All marked as "EXERCISE: Complete this proof" with technique hints.

**Recommendation**: **COMPLETE** - These are intended as exercises/examples. Completing them improves documentation and demonstrates proof techniques. They are straightforward applications of existing infrastructure.

### 5. Automation/Infrastructure Sorries

#### 5.1 ProofSearch.lean - 3 sorries (Lines 1348, 1353, 1358)
**Location**: `Theories/Bimodal/Automation/ProofSearch.lean`

These are documentation examples showing how proof search "would work" - they are not actual implementations.

**Recommendation**: **KEEP AS-IS** - These are clearly marked as documentation placeholders illustrating future automation.

#### 5.2 Automation.lean - 1 sorry (Line 26)
**Location**: `Theories/Logos/Automation.lean`

Example usage placeholder for `modal_k_tactic` which is not yet implemented.

**Recommendation**: **KEEP AS-IS** - This is documentation for future meta-programming work.

### 6. Logos Subsystem Sorries

#### 6.1 Logos/SubTheories/Dynamics/Truth.lean - 1 sorry (Line 176)
**Location**: `Theories/Logos/SubTheories/Dynamics/Truth.lean`

The causation operator (`○→`) semantics is marked sorry with extensive comments explaining it requires Task 394's correct implementation.

**Recommendation**: **KEEP AS-IS (DOCUMENTED)** - Blocked on Task 394 implementation. The comments explain the correct semantics needed.

### 7. Boneyard Sorries (Already Archived)

The Boneyard already contains 100+ sorries across deprecated approaches. These are intentionally archived and should NOT be counted against a "sorry-free" goal for active code.

## Categorization Summary

### ARCHIVE (Move to Boneyard) - 25 sorries

| File | Sorries | Rationale |
|------|---------|-----------|
| CoherentConstruction.lean | 8 | Cross-origin cases not on critical path |
| TaskRelation.lean | 5 | Compositionality not on critical path |
| IndexedMCSFamily.lean | 4 | Dead code (construct_indexed_family unused) |
| AlgebraicSemanticBridge.lean | 8 | Alternative path not integrated |

### COMPLETE (Prove properly) - 12 sorries

| File | Sorries | Rationale |
|------|---------|-----------|
| TemporalProofs.lean | 2 | Exercises - straightforward to complete |
| ModalProofStrategies.lean | 5 | Exercises - straightforward to complete |
| ModalProofs.lean | 5 | Exercises - straightforward to complete |

### KEEP AS-IS (Documented limitations) - 11 sorries

| File | Sorries | Rationale |
|------|---------|-----------|
| TruthLemma.lean | 4 | Architectural (omega-rule, box quantification) |
| SemanticCanonicalModel.lean | 2 | Mathematically impossible + alternative path |
| FiniteModelProperty.lean | 1 | Alternative path with sorry-free alternative documented |
| ProofSearch.lean | 3 | Documentation examples |
| Logos/Automation.lean | 1 | Documentation placeholder |
| Logos/Truth.lean | 1 | Blocked on Task 394 |

## Recommendations

### Priority 1: Archive Dead/Exploratory Code
1. Move `construct_indexed_family` from IndexedMCSFamily.lean to Boneyard
2. Move `AlgebraicSemanticBridge.lean` to Boneyard (or mark as experimental)
3. Document that cross-origin cases in CoherentConstruction are optional

### Priority 2: Complete Example Exercises
1. Complete 12 exercise sorries in Examples/ files
2. These demonstrate proof techniques and improve documentation
3. Estimated effort: 2-4 hours (straightforward applications)

### Priority 3: Keep Architectural Sorries Documented
1. TruthLemma.lean backward directions - excellent documentation exists
2. SemanticCanonicalModel compositionality - mathematically impossible
3. These serve as educational examples of metatheoretical limitations

## Path to Sorry-Free Main Theorems

The main completeness theorem `semantic_weak_completeness` is ALREADY sorry-free. To achieve a "sorry-free codebase" perception:

1. **Immediate**: Archive 25 sorries (dead code + alternative paths) to Boneyard
2. **Short-term**: Complete 12 exercise sorries
3. **Documentation**: Keep 11 architectural sorries with their documentation

After these actions, the main Metalogic/ directory would have only the well-documented architectural sorries that explain fundamental limitations.

## References

- Task 758 research report: `specs/758_audit_and_reduce_metalogic_sorries/reports/research-001.md`
- Task 758 implementation plan: `specs/758_audit_and_reduce_metalogic_sorries/plans/implementation-001.md`
- Cross-origin cases analysis: `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`
- Semantic completeness: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

## Next Steps

1. Create implementation plan with phases for ARCHIVE and COMPLETE dispositions
2. For ARCHIVE: Identify import dependencies, create Boneyard structure
3. For COMPLETE: Estimate effort per exercise, prioritize by teaching value
4. Update repository health metrics in state.json after cleanup
