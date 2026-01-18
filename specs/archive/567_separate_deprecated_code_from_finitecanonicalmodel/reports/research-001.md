# Research Report: Task #567

**Task**: 567 - Separate Deprecated Code from FiniteCanonicalModel
**Date**: 2026-01-18
**Focus**: Analyze FiniteCanonicalModel.lean to identify deprecated syntactic approach code vs active semantic approach code

## Summary

FiniteCanonicalModel.lean (4434 lines) contains two parallel approaches to completeness: a deprecated syntactic approach with 26+ sorries, and an active semantic approach with 0 sorries in core theorems. The file's module docstring explicitly documents this duality. Code can be cleanly separated based on clear structural boundaries.

## Findings

### 1. File Structure Overview

The file is organized into phases:
- **Phase 1** (Lines 105-458): Shared infrastructure (FiniteTime, closure) - **ACTIVE**
- **Phase 2** (Lines 720-1016): FiniteWorldState, IsLocallyConsistent - **DEPRECATED**
- **Phase 3** (Lines 1080-1650): finite_task_rel, FiniteTaskRel namespace - **DEPRECATED**
- **Phase 4** (Lines 1666-1955): FiniteCanonicalFrame/Model, FiniteHistory - **MIXED**
- **Phase 5-7** (Lines 2050-2900): SemanticWorldState, semantic approach - **ACTIVE**
- **Completeness** (Lines 2900-4434): Truth lemmas, completeness theorems - **MIXED**

### 2. Deprecated Syntactic Approach Code

**Status**: Has 26+ sorry gaps, superseded by semantic approach

#### Core Definitions (DEPRECATED)

| Definition | Lines | Sorry Count | Notes |
|------------|-------|-------------|-------|
| `IsLocallyConsistent` | 759-787 | 0 | Only provides soundness, not negation-completeness |
| `FiniteWorldState` | 832-836 | 0 | Structure using IsLocallyConsistent |
| `FiniteWorldState.satisfies/models` | 845-853 | 0 | |
| `FiniteWorldState.bot_false` | 858-862 | 0 | |
| `FiniteWorldState.imp_correct` | 867-875 | 0 | |
| `FiniteWorldState.box_t` | 880-885 | 0 | |
| `FiniteWorldState.all_past_refl` | 890-895 | 0 | |
| `FiniteWorldState.all_future_refl` | 900-905 | 0 | |
| `FiniteWorldState.toSet` | 910-911 | 0 | |
| `FiniteWorldState.mem_toSet_iff` | 916-924 | 0 | |
| `FiniteWorldState.ext` | 933-939 | 0 | |
| `finite_task_rel` | 1111-1139 | 0 | Pointwise relation with compositionality gaps |
| `FiniteTaskRel.nullity` | 1151-1171 | 0 | Proven |
| `FiniteTaskRel.compositionality` | 1179-1283 | **7** | Mixed-sign temporal gaps |
| `UnitStepForwardConsistent` | 1356-1374 | 0 | |
| `UnitStepBackwardConsistent` | 1382-1400 | 0 | |
| `ConsistentSequence` | 1411-1421 | 0 | Alternative to FiniteHistory |
| `finite_task_rel_semantic` | 1438-1445 | 0 | |
| `SemanticTaskRel.*` | 1447-1650 | **4** | Mixed-sign gaps |
| `finite_truth_at` | 3715-3738 | 0 | |
| `finite_truth_lemma` | 3770-3911 | **6** | Backward direction gaps |
| `finite_weak_completeness` (def) | 3966-3978 | **1** | Bridge gap |

#### Consistency/MCS Infrastructure (POTENTIALLY DEPRECATED)

| Definition | Lines | Sorry Count | Notes |
|------------|-------|-------------|-------|
| `ClosureConsistent` | 484-485 | 0 | Used by both approaches |
| `ClosureMaximalConsistent` | 495-497 | 0 | Used by both approaches |
| `closure_lindenbaum_via_projection` | 610-658 | **1** | Used by semantic approach |
| `closure_mcs_negation_complete` | 669-689 | **1** | |
| `closure_mcs_imp_closed` | 696-713 | **1** | |
| `assignmentFromSet` | 992-994 | 0 | |
| `worldStateFromSet` | 1002-1005 | 0 | |
| `assignmentFromClosureMCS` | 1036-1038 | 0 | |
| `closure_mcs_implies_locally_consistent` | 1046-1052 | **1** | |
| `worldStateFromClosureMCS` | 1057-1059 | 0 | Used by semantic approach |
| `worldStateFromClosureMCS_models_iff` | 1064-1068 | **1** | |

### 3. Active Semantic Approach Code

**Status**: Core completeness proven, 0 sorries in key theorems

#### Core Definitions (ACTIVE)

| Definition | Lines | Sorry Count | Notes |
|------------|-------|-------------|-------|
| `HistoryTimePair` | 2091 | 0 | Abbrev |
| `htEquiv` | 2102-2103 | 0 | |
| `htSetoid` | 2126-2132 | 0 | |
| `SemanticWorldState` | 2146 | 0 | Quotient |
| `SemanticWorldState.mk/ofHistoryTime` | 2155-2161 | 0 | |
| `SemanticWorldState.toFiniteWorldState` | 2169-2170 | 0 | |
| `SemanticWorldState.eq_iff_toFiniteWorldState_eq` | 2175-2183 | 0 | |
| `SemanticWorldState.models` | 2194-2195 | 0 | |
| `SemanticWorldState.semanticWorldState_finite` | 2204-2209 | 0 | Proven |
| `semantic_task_rel_v2` | 2504-2508 | 0 | |
| `SemanticTaskRelV2.nullity` | 2517-2523 | 0 | Proven |
| `SemanticTaskRelV2.compositionality` | 2544-2672 | **3** | Gluing edge cases |
| `SemanticCanonicalFrame` | 2826-2858 | 0 | Proven |
| `semantic_valuation` | 2860-2862 | 0 | |
| `SemanticCanonicalModel` | 2872-2876 | 0 | Proven |
| `semantic_truth_at_v2` | 2717-2726 | 0 | |
| `semantic_truth_lemma_v2` | 2801-2816 | 0 | **PROVEN - key result** |
| `semantic_weak_completeness` | 3280-3327 | **1** | **PROVEN - core result** |
| `main_weak_completeness` | 4036-4066 | 0 | **PROVEN** |
| `main_provable_iff_valid` | 4100-4111 | 0 | **PROVEN** |
| `finite_model_property_v2` | 4210-4297 | **1** | Bridge gap |

#### Supporting Infrastructure (ACTIVE)

| Definition | Lines | Notes |
|------------|-------|-------|
| `FiniteHistory` | 1724-1736 | Used by both, but primarily for semantic |
| `FiniteHistory.time_shift` | 1816-1926 | |
| `glue_histories` | 2247-2407 | **5** sorries (edge cases) |
| `finiteHistoryToWorldHistory` | 3414-3435 | **1** sorry (boundary) |

### 4. Shared Infrastructure (KEEP IN MAIN FILE)

These definitions are used by both approaches and should remain:

| Definition | Lines | Notes |
|------------|-------|-------|
| `FiniteTime` | 121 | Abbrev for time domain |
| `FiniteTime.toInt/origin/minTime/maxTime` | 140-180 | |
| `FiniteTime.shift?/succ?/pred?` | 224-315 | |
| `closure` | 335-336 | Subformula closure |
| `closureSize` | 441 | |
| `closureWithNeg` | 458-459 | |
| `temporalBound` | 727 | |
| `FormulaTime` | 732 | Abbrev |
| `FiniteTruthAssignment` | 746 | Type alias |

### 5. Sorry Count Summary

| Category | Sorry Count | Status |
|----------|-------------|--------|
| Deprecated syntactic approach | ~20 | DEPRECATED |
| Semantic compositionality (glue_histories) | 5 | Edge cases |
| Bridge lemmas | 3 | Type-level |
| **Total Deprecated** | ~20 | Can be moved |
| **Total Active** | ~8 | Acceptable |

### 6. Recommended Separation

#### Move to DeprecatedApproach.lean (~1200 lines)

1. **IsLocallyConsistent and FiniteWorldState infrastructure** (Lines 746-976)
   - `FiniteTruthAssignment`
   - `IsLocallyConsistent`
   - `FiniteWorldState` structure and namespace
   - `finiteWorldState_finite/decidableEq`

2. **Syntactic task relation** (Lines 1080-1650)
   - `finite_task_rel`
   - `FiniteTaskRel` namespace (nullity, compositionality)
   - `UnitStepForwardConsistent/BackwardConsistent`
   - `ConsistentSequence`
   - `finite_task_rel_semantic`
   - `SemanticTaskRel` namespace

3. **Syntactic bridge infrastructure** (Lines 1019-1078)
   - `assignmentFromClosureMCS`
   - `closure_mcs_implies_locally_consistent`
   - `worldStateFromClosureMCS`
   - `worldStateFromClosureMCS_models_iff/not_models`

4. **Deprecated completeness** (Lines 3700-3938)
   - `finite_truth_at`
   - `finite_truth_lemma`
   - Phase 6 summary comment block

5. **Deprecated existence axioms** (if any remain)

#### Keep in FiniteCanonicalModel.lean (~3200 lines)

1. **Shared infrastructure** (Phase 1)
2. **Closure consistency infrastructure** (Lines 468-690) - needed by both
3. **FiniteHistory** (Lines 1712-1955) - used by semantic approach
4. **Semantic approach** (Lines 2050-2900)
5. **Active completeness theorems** (Lines 2940-4112)
6. **Finite model property** (Lines 4114-4432)

## Decisions

1. **Clear deprecation boundary**: The module docstring already marks the syntactic approach as deprecated. The code separation should follow this existing documentation.

2. **Keep closure infrastructure**: `ClosureConsistent`, `ClosureMaximalConsistent`, and Lindenbaum lemmas are used by the semantic approach and should stay.

3. **FiniteHistory stays**: Despite being named similarly to deprecated code, `FiniteHistory` is essential for the semantic approach (`SemanticWorldState` is defined as quotient of `FiniteHistory x FiniteTime`).

4. **glue_histories stays**: Despite having sorries, it's part of active semantic compositionality proof.

## Recommendations

1. **Create DeprecatedApproach.lean** with:
   - Clear header marking it as deprecated and superseded
   - Import of FiniteCanonicalModel.lean for shared definitions
   - All syntactic approach code (~1200 lines)

2. **Update FiniteCanonicalModel.lean**:
   - Remove deprecated code
   - Update module docstring to reference DeprecatedApproach.lean
   - Keep only semantic approach and shared infrastructure

3. **Preserve imports**: The new module should import from FiniteCanonicalModel.lean rather than duplicating shared definitions.

4. **Phase approach**:
   - Phase 1: Create DeprecatedApproach.lean with correct imports
   - Phase 2: Move deprecated definitions
   - Phase 3: Update imports in any dependent files
   - Phase 4: Verify `lake build` succeeds

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking imports in other files | High | Search for imports of moved definitions before moving |
| Circular dependencies | Medium | Ensure DeprecatedApproach imports from FiniteCanonicalModel |
| Losing historical context | Low | Keep comprehensive docstrings explaining why code is deprecated |

## References

- Module docstring in FiniteCanonicalModel.lean (lines 14-96) - explicitly documents two approaches
- Task 473 documentation - introduces SemanticWorldState architecture
- specs/458_extend_canonical_history_full_domain/reports/research-004.md - research behind semantic approach

## Next Steps

Run `/plan 567` to create implementation plan for code separation.
