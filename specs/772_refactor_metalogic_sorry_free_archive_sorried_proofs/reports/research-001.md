# Research Report: Refactor Metalogic for Sorry-Free Archive

**Task**: 772 - refactor_metalogic_sorry_free_archive_sorried_proofs
**Date**: 2026-01-30
**Researcher**: lean-research-agent
**Session**: sess_1769732744_ce1b0e

## Executive Summary

The Metalogic directory currently contains 20 sorries across 5 files, all in code paths marked as DEPRECATED (Task 769). The sorries exist in:
1. `Representation/TaskRelation.lean` (5 sorries) - cross-sign duration composition
2. `Representation/CoherentConstruction.lean` (8 sorries) - cross-origin coherence
3. `Representation/TruthLemma.lean` (4 sorries) - box/temporal backward directions
4. `FMP/SemanticCanonicalModel.lean` (2 sorries) - frame compositionality, truth bridge
5. `FMP/FiniteModelProperty.lean` (1 sorry) - FMP truth bridge

The **canonical completeness theorem is `semantic_weak_completeness`** in `FMP/SemanticCanonicalModel.lean`, which is **completely sorry-free** and provides the main completeness result via contrapositive approach.

## Detailed Sorry Analysis

### 1. TaskRelation.lean (5 sorries)

**Location**: `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`

**Function**: `canonical_task_rel_comp` (lines 161-213)

**Sorry Cases**:
| Line | Case | Description |
|------|------|-------------|
| 183 | d1+d2=0 | MCS equality when durations cancel |
| 197 | d1+d2>0 forward G | G-formula propagation for positive sum |
| 202 | d1+d2>0 backward H | H-formula propagation for positive sum |
| 209 | d1+d2<0 forward H | H-formula propagation for negative sum |
| 213 | d1+d2<0 backward G | G-formula propagation for negative sum |

**Why Not Needed**: The completeness theorem uses `IndexedMCSFamily` coherence conditions directly. Formula propagation goes through `forward_G`, `backward_H`, `forward_H`, `backward_G` from the family, not task relation composition.

### 2. CoherentConstruction.lean (8 sorries)

**Location**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Function**: `mcs_unified_chain_pairwise_coherent` (lines 696-811)

**Sorry Cases**:
| Line | Condition | Case |
|------|-----------|------|
| 721 | forward_G | t<0, t'>=0 (cross-origin) |
| 724 | forward_G | both<0, toward origin |
| 732 | backward_H | both>=0 (forward chain H) |
| 735 | backward_H | t>=0, t'<0 (cross-origin) |
| 753 | forward_H | both>=0 (H in forward chain) |
| 760 | forward_H | t<0, t'>=0 (cross-origin) |
| 808 | backward_G | t'<0, t>=0 (cross-origin) |
| 811 | backward_G | both<0 |

**Proven Cases** (used by completeness):
- forward_G Case 1 (both >= 0): via `mcs_forward_chain_coherent`
- backward_H Case 4 (both < 0): via `mcs_backward_chain_coherent`
- forward_H Case 4 (both < 0): via `mcs_backward_chain_H_persistence`
- backward_G Case 1 (both >= 0): via `mcs_forward_chain_G_persistence`

### 3. TruthLemma.lean (4 sorries)

**Location**: `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Function**: `truth_lemma_mutual` (lines 249-454)

**Sorry Cases**:
| Line | Case | Limitation |
|------|------|------------|
| 382 | box forward | S5-style universal quantification over ALL histories |
| 405 | box backward | Same Box semantics limitation |
| 432 | all_past backward | Omega-rule (infinite derivation) required |
| 454 | all_future backward | Omega-rule (infinite derivation) required |

**Key Insight**: The representation theorem only requires `truth_lemma_forward` (forward direction). The backward direction is architecturally impossible due to S5-style Box semantics (Task 750 confirmed).

### 4. SemanticCanonicalModel.lean (2 sorries)

**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

| Line | Function | Issue |
|------|----------|-------|
| 231 | `SemanticCanonicalFrame.compositionality` | Mathematically false for unbounded durations in finite time domain [-k, k] |
| 693 | `truth_at_implies_semantic_truth` | Forward truth lemma gap - Box quantifies over ALL histories |

### 5. FiniteModelProperty.lean (1 sorry)

**Location**: `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean`

| Line | Function | Issue |
|------|----------|-------|
| 233 | `finite_model_property_constructive` | Truth bridge connecting finite model truth to general `truth_at` |

## The semantic_weak_completeness Approach

### What It Does

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w origin phi) ->
    ⊢ phi
```

### Why It's Sorry-Free

Works via **contrapositive**:
1. Assume phi is not provable
2. Then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS
5. Build FiniteWorldState from closure MCS
6. phi is false at this world state (by construction)
7. Build SemanticWorldState at origin
8. Show phi is false in semantic_truth_at_v2 sense
9. Contrapositive: valid phi -> provable phi

### Why Other Approaches Have Sorries

The direct approach (representation_theorem -> truth_lemma -> weak_completeness) fails because:
- Box quantifies over ALL histories (S5-style universal quantification)
- MCS/assignment constructions only have information about ONE world state
- This is an architectural limitation, not a bug

## Current Import Structure

```
Metalogic/
├── Core/                        # MCS theory, deduction theorem
├── Soundness/                   # 15 axioms, 7 rules (sorry-free)
├── Representation/              # Canonical model construction
│   ├── TaskRelation.lean        # 5 sorries (DEPRECATED)
│   ├── CoherentConstruction.lean # 8 sorries (DEPRECATED)
│   ├── TruthLemma.lean          # 4 sorries (DEPRECATED)
│   └── UniversalCanonicalModel.lean  # Uses CoherentConstruction
├── Completeness/
│   └── WeakCompleteness.lean    # Uses representation_theorem (has sorries in deps)
├── FMP/
│   ├── SemanticCanonicalModel.lean # semantic_weak_completeness (SORRY-FREE)
│   └── FiniteModelProperty.lean # 1 sorry (DEPRECATED)
└── Compactness/
```

## Boneyard Pattern Analysis

The existing Boneyard structure shows the pattern:
```
Theories/Bimodal/Boneyard/
├── Metalogic/              # Original v1 approach
├── Metalogic_v2/           # Second iteration
└── Metalogic_v3/           # Failed attempts archive
    ├── TaskRelation/Compositionality.lean   # Documentation for TaskRelation sorries
    ├── Coherence/CrossOriginCases.lean      # Documentation for coherence sorries
    └── FailedTruthLemma/                    # Failed truth lemma attempts
```

Files in Boneyard are:
1. Pure documentation (no imports, no compilable code)
2. Archived attempts with extensive comments
3. Referenced from main code via comments

## Refactoring Strategy

### Option A: Archive to Boneyard (Recommended)

**Files to Archive**:
1. `TaskRelation.lean` -> `Boneyard/Metalogic/TaskRelation.lean`
2. `CoherentConstruction.lean` -> `Boneyard/Metalogic/CoherentConstruction.lean`
3. `TruthLemma.lean` -> `Boneyard/Metalogic/TruthLemma.lean`

**Files to Modify** (remove deprecated code):
1. `SemanticCanonicalModel.lean` - Keep only `semantic_weak_completeness` and supporting code
2. `FiniteModelProperty.lean` - Remove `finite_model_property_constructive`

**Files to Update**:
1. `UniversalCanonicalModel.lean` - Remove dependency on CoherentConstruction
2. `WeakCompleteness.lean` - Use semantic_weak_completeness instead of representation_theorem
3. `Metalogic.lean` - Update imports

### Option B: In-Place Deprecation (Current State)

Already done by Task 769. All sorries have DEPRECATED comments pointing to `semantic_weak_completeness`.

### Recommended Approach

**Phase 1**: Create sorry-free completeness path
- `FMP/SemanticCanonicalModel.lean` already has `semantic_weak_completeness`
- Update `Completeness/WeakCompleteness.lean` to use `semantic_weak_completeness` as primary

**Phase 2**: Archive sorried files
- Move `TaskRelation.lean`, `CoherentConstruction.lean`, `TruthLemma.lean` to Boneyard
- Keep `UniversalCanonicalModel.lean` but remove the sorried dependency chain

**Phase 3**: Clean up FMP
- Remove sorried theorems from `SemanticCanonicalModel.lean`
- Remove `finite_model_property_constructive` from `FiniteModelProperty.lean`

## Dependencies to Preserve

### Must Keep (sorry-free):
- `semantic_weak_completeness` (FMP/SemanticCanonicalModel.lean)
- `semanticWorldState_card_bound` (FMP/SemanticCanonicalModel.lean)
- `ClosureMaximalConsistent`, `worldStateFromClosureMCS` (FMP/Closure.lean)
- All Core/ files
- All Soundness/ files
- `Representation/IndexedMCSFamily.lean` (type definitions only)
- `Representation/CanonicalWorld.lean`, `CanonicalHistory.lean` (type definitions)

### Can Archive (sorried):
- `TaskRelation.lean` (5 sorries)
- `CoherentConstruction.lean` (8 sorries)
- `TruthLemma.lean` (4 sorries)
- Deprecated theorems in SemanticCanonicalModel.lean
- `finite_model_property_constructive` in FiniteModelProperty.lean

## Implementation Checklist

1. [ ] Create `Boneyard/Metalogic_v4/` for archived files
2. [ ] Archive `Representation/TaskRelation.lean`
3. [ ] Archive `Representation/CoherentConstruction.lean`
4. [ ] Archive `Representation/TruthLemma.lean`
5. [ ] Update `UniversalCanonicalModel.lean` to remove sorried deps
6. [ ] Update `WeakCompleteness.lean` to use `semantic_weak_completeness`
7. [ ] Clean deprecated theorems from `SemanticCanonicalModel.lean`
8. [ ] Clean `FiniteModelProperty.lean`
9. [ ] Update `Metalogic.lean` module imports
10. [ ] Verify zero sorry count in Metalogic/ (excluding Boneyard/, Examples/)
11. [ ] Run `lake build` to verify

## Risk Assessment

**Low Risk**:
- All sorried code is already marked DEPRECATED
- `semantic_weak_completeness` is proven and provides the main result
- Boneyard pattern is established and proven safe

**Medium Risk**:
- Import chain changes may break downstream code
- Need to verify all public API is preserved

**Mitigation**:
- Keep theorem statements even if proofs use `semantic_weak_completeness`
- Test build after each phase

## Conclusion

The refactoring is straightforward because:
1. All sorried code is already deprecated and documented
2. A sorry-free alternative (`semantic_weak_completeness`) exists and is proven
3. The Boneyard archive pattern is established
4. Clear separation between what to keep (sorry-free) and what to archive (sorried)

The main work is reorganizing imports and ensuring the sorry-free completeness path is the primary one used by downstream code.
