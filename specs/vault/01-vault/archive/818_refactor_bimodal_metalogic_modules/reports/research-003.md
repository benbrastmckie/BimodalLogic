# Research Report: Task #818

**Task**: Refactor Bimodal Metalogic modules
**Date**: 2026-02-03
**Focus**: Verify SemanticCanonicalModel.lean sorry-free claim and analyze all completeness paths

## Summary

**The claim in research-002.md is VERIFIED**: `semantic_weak_completeness` in `SemanticCanonicalModel.lean` is **fully sorry-free**, including all transitive dependencies. The only sorry in `Closure.lean` (`diamond_in_closureWithNeg_of_box` at line 728) is NOT used by this theorem. However, the BMCS approach in task 812 still has 3 actual sorries that prevent a fully sorry-free "standard" completeness result.

## Findings

### 1. SemanticCanonicalModel.lean Dependency Analysis

**VERIFIED SORRY-FREE**: The `semantic_weak_completeness` theorem has no sorries in its dependency chain.

#### Direct Imports of SemanticCanonicalModel.lean
| Import | Sorry Status |
|--------|--------------|
| `Bimodal.ProofSystem` | 0 sorries |
| `Bimodal.Semantics` | 0 sorries |
| `Bimodal.Metalogic.FMP.FiniteWorldState` | 0 sorries |
| `Bimodal.Metalogic.FMP.BoundedTime` | 0 sorries |
| `Bimodal.Metalogic.Soundness` | 0 sorries |
| `Bimodal.Metalogic.Core.DeductionTheorem` | 0 sorries |
| `Bimodal.Metalogic.Core.MaximalConsistent` | 0 sorries |
| `Bimodal.Metalogic.Core.MCSProperties` | 0 sorries |
| `Bimodal.Theorems.Propositional` | 0 sorries |

#### Closure.lean Functions Used by semantic_weak_completeness
| Function | Sorry Status | Used By |
|----------|--------------|---------|
| `closure` | sorry-free | Closure definition |
| `phi_mem_closure` | sorry-free | Line 383 |
| `closureWithNeg` | sorry-free | Line 379 |
| `ClosureMaximalConsistent` | sorry-free | Line 380 |
| `mcs_projection_is_closure_mcs` | sorry-free | Line 380 |
| `worldStateFromClosureMCS` | sorry-free | Line 389 |
| `worldStateFromClosureMCS_not_models` | sorry-free | Line 392-393 |

#### Unused Sorry in Closure.lean
The sorry at line 728 (`diamond_in_closureWithNeg_of_box`) is **NOT in the dependency chain**:
- It is never called by SemanticCanonicalModel.lean
- It relates to Diamond formula membership, not used in the contrapositive completeness proof
- The theorem is mathematically questionable anyway (Diamond formula may not be a subformula)

### 2. Completeness Paths Analysis

#### Path A: SemanticCanonicalModel.lean (FMP-Internal)
**Status**: SORRY-FREE

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

**Semantic notion**: FMP-internal validity (truth at all SemanticWorldStates)
**Approach**: Contrapositive - if not provable, construct countermodel from closure MCS

#### Path B: BMCS Bundle Approach
**Status**: 3 actual sorries

| File | Sorries | Nature |
|------|---------|--------|
| TruthLemma.lean | 2 | Temporal backward (H, G backward cases) |
| Construction.lean | 1 | modal_backward (construction assumption) |

**Semantic notion**: BMCS validity (truth at bundle MCS)
**Approach**: Henkin-style bundling with modal coherence

**Key achievement**: Box case is SORRY-FREE (resolves 30+ sorry obstruction from task 809)

#### Path C: FDSM Multi-History Approach
**Status**: BLOCKED (24+ sorries)

| File | Sorries | Nature |
|------|---------|--------|
| ModalSaturation.lean | 8 | Architectural blockers |
| TruthLemma.lean | 13 | Closure membership bookkeeping |
| Completeness.lean | 3 | Bridge lemmas |

**Status**: Architecturally blocked - projection from tracked to plain histories loses MCS link.

#### Path D: FiniteStrongCompleteness.lean
**Status**: 1 sorry (validity bridge)

```lean
-- Line 130: Bridging general validity to FMP-internal validity
sorry
```

This represents the fundamental gap between:
- General validity: truth in ALL TaskModels
- FMP-internal validity: truth at SemanticWorldStates

### 3. Tasks 810 and 812 Analysis

#### Task 810: Strategic Review
**Outcome**: Both direct model construction (v003) AND contrapositive (v004) approaches are blocked by the validity bridge gap.

**Key finding**: The gap between general TaskModel validity and FMP-internal validity cannot be bridged for modal/temporal operators because:
- FMP TaskFrame has permissive task_rel (all states reachable)
- Box semantics requires truth at ALL reachable states, including non-MCS states
- FMP WorldHistory is constant, losing temporal structure

#### Task 812: BMCS Approach
**Outcome**: Successfully reduced sorries from 30+ to 10 (now 3 remaining after tasks 813-816).

**Key achievement**: Box case of truth lemma is SORRY-FREE via Henkin-style bundling.

**Remaining sorries**:
- 2 temporal backward sorries (H/G backward cases in TruthLemma.lean)
- 1 modal_backward sorry (construction assumption in Construction.lean)

### 4. Current Sorry Distribution

#### Active Metalogic Sorry Count by Module
| Module | Actual Sorries | Category |
|--------|---------------|----------|
| FMP/Closure.lean | 1 | Unused lemma |
| FMP/ConsistentSatisfiable.lean | 6 | Validity bridge (blocked) |
| Completeness/FiniteStrongCompleteness.lean | 1 | Validity bridge (blocked) |
| Bundle/TruthLemma.lean | 2 | Temporal backward |
| Bundle/Construction.lean | 1 | Modal backward |
| FDSM/*.lean | 24+ | Blocked approach |
| **Total Active (excluding FDSM)** | **11** | |

### 5. Path to Zero Sorries

#### Achievable Zero-Sorry Results

1. **semantic_weak_completeness**: Already sorry-free (FMP-internal validity)
2. **soundness**: Already sorry-free (standard semantics)

#### What Would Require Resolving

For **BMCS zero-sorry completeness** (3 remaining sorries):

| Sorry | Location | Resolution Path | Difficulty |
|-------|----------|-----------------|------------|
| Temporal backward H | TruthLemma.lean:383 | Add omega-saturation to IndexedMCSFamily | Medium |
| Temporal backward G | TruthLemma.lean:395 | Add omega-saturation to IndexedMCSFamily | Medium |
| modal_backward | Construction.lean:220 | Multi-family construction or accept as construction axiom | Hard |

For **FiniteStrongCompleteness zero-sorry** (1 sorry):

| Sorry | Location | Resolution Path | Difficulty |
|-------|----------|-----------------|------------|
| Validity bridge | Line 130 | Change semantic notion to FMP-internal | **Architectural** |

The validity bridge cannot be resolved without changing what "validity" means. The current sorry is a fundamental limitation, not a fixable proof gap.

## Recommendations

### Recommendation 1: Accept FMP-Internal Completeness as Primary

`semantic_weak_completeness` provides a sorry-free completeness theorem using FMP-internal validity. This should be documented as the canonical result.

**Action**: Update ROAD_MAP.md and Metalogic/README.md to reflect this.

### Recommendation 2: Archive FDSM Blocked Code

The FDSM approach has 24+ sorries and is architecturally blocked. Archive to Boneyard.

**Files to archive**:
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean`
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Keep**:
- `Theories/Bimodal/Metalogic/FDSM/Core.lean` (clean types, 0 sorries)

### Recommendation 3: Continue BMCS Sorry Reduction

The BMCS approach has only 3 sorries remaining, none of which are mathematical gaps:
- 2 temporal sorries: solvable via omega-saturation
- 1 modal sorry: construction assumption (acceptable or solvable via multi-family)

### Recommendation 4: Document Validity Bridge Limitation

The validity bridge sorry in FiniteStrongCompleteness.lean should be documented as an architectural limitation, not a proof gap.

**Options**:
1. Keep sorry with documentation (current)
2. Change statement to use FMP-internal validity (removes sorry, changes semantics)
3. Remove file entirely (simplify codebase)

Option 2 is recommended if zero-sorry is desired; Option 1 is fine if the limitation is acceptable.

### Recommendation 5: Remove Unused Closure.lean Sorry

The `diamond_in_closureWithNeg_of_box` theorem at Closure.lean:728 is:
- Never used
- Mathematically questionable
- Adds noise to sorry counts

**Action**: Remove or comment out this lemma.

## Conclusion

The claim in research-002.md is **VERIFIED**: `semantic_weak_completeness` is fully sorry-free. The project has:

1. **One sorry-free completeness path**: `semantic_weak_completeness` (FMP-internal validity)
2. **One near-zero path**: BMCS with 3 sorries (reducible to 0 with effort)
3. **Two blocked paths**: FDSM (24+ sorries, architectural) and validity bridge (1 sorry, fundamental)

The recommended strategy is:
1. Accept `semantic_weak_completeness` as the primary completeness result
2. Continue BMCS sorry reduction if standard-semantics completeness is needed
3. Archive FDSM and document the validity bridge limitation
4. Clean up unused sorries like `diamond_in_closureWithNeg_of_box`

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Sorry-free completeness
- `specs/archive/810_strategic_review_representation_vs_semantic_paths/` - Validity bridge analysis
- `specs/archive/812_canonical_model_completeness/` - BMCS approach documentation
- `specs/826_fdsm_completeness_saturated_construction/reports/research-002.md` - Original claim

## Next Steps

1. **Task 818**: Implement recommendations above in refactoring work
2. **Future task**: BMCS temporal saturation (if zero-sorry standard completeness desired)
3. **Future task**: Multi-family BMCS construction (if zero-sorry modal backward desired)
