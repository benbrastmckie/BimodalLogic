# Research Report: Task #604

**Task**: migrate_fmp_to_semanticcanonicalmodel_v2
**Date**: 2026-01-19
**Focus**: Migration path for FiniteModelProperty.lean and ContextProvability.lean to use SemanticCanonicalModel_v2 instead of old Bimodal.Metalogic.Completeness.FiniteCanonicalModel

## Executive Summary

- FiniteModelProperty.lean currently imports `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` and uses 10+ definitions from the old Metalogic namespace
- ContextProvability.lean is already clean - no imports from old Metalogic (uses `main_provable_iff_valid_v2` from SemanticCanonicalModel.lean)
- Task 597 created v2 infrastructure including SemanticWorldState, SemanticCanonicalFrame, SemanticCanonicalModel, but is missing several key definitions needed by FiniteModelProperty.lean
- Migration requires porting 6-8 definitions/theorems from old FiniteCanonicalModel to v2 infrastructure

## Context & Scope

### Files Under Analysis

1. **FiniteModelProperty.lean** (`Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`)
   - Contains FMP theorems including `finite_model_property_constructive`
   - Imports from old Metalogic: `import Bimodal.Metalogic.Completeness.FiniteCanonicalModel` (line 9)
   - Uses `open Bimodal.Metalogic.Completeness` and `open Bimodal.Metalogic.Completeness.SemanticWorldState` (lines 301-302)

2. **ContextProvability.lean** (`Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`)
   - Already clean - no direct imports from old Metalogic/
   - Uses `main_provable_iff_valid_v2` from SemanticCanonicalModel.lean (line 149)
   - **Status**: No migration needed

### V2 Infrastructure Available (from Task 597)

Located in `Theories/Bimodal/Metalogic_v2/Representation/`:

| File | Key Definitions |
|------|-----------------|
| `SemanticCanonicalModel.lean` | `SemanticWorldState`, `SemanticCanonicalFrame`, `SemanticCanonicalModel`, `htEquiv`, `htSetoid`, `semantic_task_rel`, `semantic_valuation`, `finiteHistoryToWorldHistory`, `finite_history_from_state`, `main_provable_iff_valid_v2` |
| `FiniteWorldState.lean` | `FiniteTime`, `temporalBound`, `FiniteTruthAssignment`, `FiniteWorldState`, `FiniteHistory`, `worldStateFromClosureMCS`, `worldStateFromClosureMCS_models_iff` |
| `Closure.lean` | `closure`, `closureWithNeg`, `phi_mem_closure`, `closure_subset_closureWithNeg`, `ClosureMaximalConsistent`, `mcs_projection_is_closure_mcs` |

## Findings

### 1. Definitions Used from Old FiniteCanonicalModel in FiniteModelProperty.lean

| Definition | Usage Location | V2 Equivalent | Status |
|------------|----------------|---------------|--------|
| `closureSize` | Line 318, 346-347, 357, 386, 485 | **MISSING** | Need to port |
| `FiniteTruthAssignment` | Line 338, 342-343, 355 | Exists in FiniteWorldState.lean | Already ported |
| `SemanticWorldState` (old) | Lines 301-302, 310, 318, etc. | Exists in SemanticCanonicalModel.lean | Already ported |
| `toFiniteWorldState` | Line 320, 460, 464, 480 | `SemanticWorldState.toFiniteWorldState` in v2 | Already ported |
| `eq_iff_toFiniteWorldState_eq` | Line 322 | Exists in SemanticCanonicalModel.lean | Already ported |
| `FiniteWorldState.ext` | Line 335 | **MISSING** | Need to port |
| `FiniteWorldState.mem_toSet_iff` | Line 465 | **MISSING** | Need to port |
| `semanticWorldState_finite` | Line 475 | **MISSING** | Need to port |
| `semantic_world_state_has_world_history` | Line 470 | **MISSING** | Need to port |
| `semantic_truth_implies_truth_at` | Line 483 | **MISSING** (has sorry in old code) | Need to port |
| `phi_consistent_of_not_refutable` | Line 426 | **MISSING** | Need to port |
| `self_mem_closure` | Line 439 | `phi_mem_closure` in Closure.lean | Rename needed |
| `closure_subset_closureWithNeg` | Line 440 | Exists in Closure.lean | Already ported |
| `set_lindenbaum` | Line 429 | Exists in Core/MaximalConsistent.lean | Already ported |
| `worldStateFromClosureMCS_models_iff` | Line 448 | Exists in FiniteWorldState.lean | Already ported |
| `mcs_projection_is_closure_mcs` | Line 436 | Exists in Closure.lean | Already ported |

### 2. Gap Analysis - Definitions That Need Porting

**Required Definitions (6 total)**:

1. **`closureSize`** (simple definition)
   - Old: `def closureSize (phi : Formula) : Nat := (closure phi).card`
   - Target file: `Closure.lean` or `FiniteWorldState.lean`
   - Effort: Trivial

2. **`FiniteWorldState.ext`** (extensionality lemma)
   - Old: Proves two FiniteWorldStates are equal iff their assignments are equal
   - Target file: `FiniteWorldState.lean`
   - Effort: Trivial

3. **`FiniteWorldState.mem_toSet_iff`** (membership characterization)
   - Old: `phi ∈ w.toSet ↔ w.models phi h_mem`
   - Target file: `FiniteWorldState.lean`
   - Effort: Trivial

4. **`semanticWorldState_finite`** (Finite instance)
   - Old: `instance semanticWorldState_finite : Finite (SemanticWorldState phi)`
   - Proof: Via injection into FiniteWorldState which is finite
   - Target file: `SemanticCanonicalModel.lean`
   - Effort: Low (straightforward Finite.of_injective proof)

5. **`semantic_world_state_has_world_history`** (WorldHistory existence)
   - Old: Complex theorem proving every SemanticWorldState has a WorldHistory passing through it
   - Proof uses: `finite_history_from_state`, `finiteHistoryToWorldHistory`
   - Target file: `SemanticCanonicalModel.lean`
   - Effort: Medium (infrastructure exists, need to port proof)

6. **`semantic_truth_implies_truth_at`** (truth bridge lemma)
   - Old: Has `sorry` - needs actual proof
   - Statement: `w.toFiniteWorldState.models phi h_mem -> truth_at M tau 0 phi`
   - Target file: `SemanticCanonicalModel.lean`
   - Effort: High (requires induction on formula structure)

7. **`phi_consistent_of_not_refutable`** (consistency from non-refutability)
   - Old: If phi is not refutable, then {phi} is set-consistent
   - Target file: `Core/MaximalConsistent.lean` or `SemanticCanonicalModel.lean`
   - Effort: Low

### 3. Naming Inconsistencies to Resolve

| Old Name | V2 Name | Action |
|----------|---------|--------|
| `self_mem_closure` | `phi_mem_closure` | Use v2 name (exists in Closure.lean) |
| `Bimodal.Metalogic.Completeness.SemanticWorldState` | `Bimodal.Metalogic_v2.Representation.SemanticWorldState` | Update import/open |

### 4. Import Changes Required

**FiniteModelProperty.lean current imports**:
```lean
import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Representation.ContextProvability
import Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Semantics.Validity
import Bimodal.Metalogic.Completeness.FiniteCanonicalModel  -- REMOVE THIS
```

**Target imports** (after migration):
```lean
import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Representation.ContextProvability
import Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel
import Bimodal.Metalogic_v2.Representation.Closure  -- If closureSize added here
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Semantics.Validity
-- NO OLD METALOGIC IMPORTS
```

### 5. ContextProvability.lean Status

Already migration-complete:
- No imports from old Metalogic/
- Uses `main_provable_iff_valid_v2` from v2 infrastructure
- Comment on line 59: "Using Metalogic_v2 infrastructure (no dependency on old Metalogic/)"

## Decisions

1. **Target v2 files for porting**:
   - `closureSize` -> `Closure.lean` (alongside closure definition)
   - `FiniteWorldState.ext`, `mem_toSet_iff` -> `FiniteWorldState.lean`
   - `semanticWorldState_finite`, `semantic_world_state_has_world_history`, `semantic_truth_implies_truth_at` -> `SemanticCanonicalModel.lean`
   - `phi_consistent_of_not_refutable` -> `Core/MaximalConsistent.lean`

2. **Rename `self_mem_closure` to `phi_mem_closure`** in FiniteModelProperty.lean (use existing v2 name)

3. **Update open statements** from `Bimodal.Metalogic.Completeness` to `Bimodal.Metalogic_v2.Representation`

## Recommendations

### Priority Order for Porting

1. **Phase 1** (Quick wins - trivial definitions):
   - Port `closureSize` to Closure.lean
   - Port `FiniteWorldState.ext` to FiniteWorldState.lean
   - Port `FiniteWorldState.mem_toSet_iff` to FiniteWorldState.lean
   - Port `phi_consistent_of_not_refutable` to MaximalConsistent.lean

2. **Phase 2** (Medium complexity):
   - Port `semanticWorldState_finite` instance to SemanticCanonicalModel.lean
   - Port `semantic_world_state_has_world_history` theorem

3. **Phase 3** (Complex - may have sorries):
   - Port `semantic_truth_implies_truth_at` - note: old code has `sorry`
   - This may need to remain a sorry or be proven fresh

4. **Phase 4** (Migration):
   - Update FiniteModelProperty.lean imports
   - Update open statements
   - Fix any namespace/name changes
   - Remove old Metalogic import
   - Verify `lake build` passes

### Estimated Effort

| Phase | Estimated Time | Risk |
|-------|----------------|------|
| Phase 1 | 30 minutes | Low |
| Phase 2 | 1-2 hours | Medium |
| Phase 3 | 2-4 hours | High (sorry in old code) |
| Phase 4 | 30 minutes | Low |

**Total**: 4-7 hours

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `semantic_truth_implies_truth_at` has sorry in old code | High - constructive FMP may remain incomplete | Accept sorry, document as future work, or invest time to prove |
| Namespace conflicts during migration | Medium | Port definitions incrementally, test after each |
| Missing auxiliary lemmas | Medium | Search old FiniteCanonicalModel for dependencies |

## Appendix

### Search Queries Used

- `mcp__lean-lsp__lean_local_search` for: `semantic_world_state_has_world_history`, `semanticWorldState_finite`, `closureSize`, `FiniteTruthAssignment`, etc.
- Grep patterns for imports and usages in FiniteModelProperty.lean

### Key File Locations

- Old code: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
- V2 targets:
  - `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean`
  - `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean`
  - `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean`

### Lines to Modify in FiniteModelProperty.lean

- Line 9: Remove `import Bimodal.Metalogic.Completeness.FiniteCanonicalModel`
- Lines 301-302: Update `open` statements to use v2 namespaces
- Line 439: Change `self_mem_closure` to `phi_mem_closure`
- All usages of old namespace definitions will resolve after porting

## Next Steps

Run `/plan 604` to create a phased implementation plan based on these findings.
