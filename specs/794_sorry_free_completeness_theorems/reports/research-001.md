# Research Report: Sorry-Free Completeness Theorems

**Task**: 794 - sorry_free_completeness_theorems
**Date**: 2026-02-01
**Session**: sess_1769983702_97c7d8
**Focus**: Identify all sorries blocking sorry-free completeness theorems and map removal strategy

## Executive Summary

This research identifies a clear path to establishing sorry-free `weak_completeness`, `strong_completeness`, and `compactness` theorems. The key finding is that **two independent completeness paths exist** and one is already completely sorry-free.

**Critical Discovery**: The `semantic_weak_completeness` theorem in `FMP/SemanticCanonicalModel.lean` is **already completely sorry-free** and provides a working completeness result. The sorried `weak_completeness` in `Completeness/WeakCompleteness.lean` uses a different architecture (via the Representation module) that has 37+ sorries.

**Recommended Strategy**: Create new sorry-free `weak_completeness`, `strong_completeness`, and `compactness` theorems by building on `semantic_weak_completeness` instead of trying to fill the sorries in the Representation path.

## 1. Current State Analysis

### 1.1 Two Completeness Architectures

| Architecture | Entry Point | Status | Sorries |
|--------------|-------------|--------|---------|
| **FMP Path** | `semantic_weak_completeness` | SORRY-FREE | 0 |
| **Representation Path** | `weak_completeness` | BLOCKED | 37+ |

#### FMP Path (Recommended)
```
Core/MaximalConsistent
       |
       v
FMP/Closure --> FMP/FiniteWorldState
       |              |
       v              v
FMP/SemanticCanonicalModel
       |
       v
semantic_weak_completeness  <-- SORRY-FREE COMPLETENESS
```

Key theorem at `FMP/SemanticCanonicalModel.lean:354`:
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

#### Representation Path (Currently Sorried)
```
Core/MaximalConsistent
       |
       v
Representation/IndexedMCSFamily
       |
       v
Representation/CoherentConstruction
       |
       v
Representation/UniversalCanonicalModel
       |
       v
weak_completeness  <-- 1 sorry (+ 35 upstream)
```

### 1.2 Dependency Analysis

The `weak_completeness` theorem in `WeakCompleteness.lean` depends on:

1. **`representation_theorem`** in `UniversalCanonicalModel.lean` - has 2 sorries for G-bot and H-bot exclusion
2. **`soundness`** in `WeakCompleteness.lean:90-92` - has 1 sorry (LOCAL copy, not the proven one)

The downstream theorems depend on `weak_completeness`:
- `finite_strong_completeness` (FiniteStrongCompleteness.lean) - uses weak_completeness
- `infinitary_strong_completeness` (InfinitaryStrongCompleteness.lean) - uses representation_theorem directly
- `compactness` (Compactness.lean) - uses infinitary_strong_completeness

### 1.3 Detailed Sorry Inventory

| File | Line | Sorry Description | Tractability |
|------|------|-------------------|--------------|
| **WeakCompleteness.lean** | 92 | `soundness` theorem | **TRIVIAL** - already proven in Soundness.lean |
| UniversalCanonicalModel.lean | 84 | `h_no_G_bot : G-bot not in Gamma` | Medium - needs T-axiom proof |
| UniversalCanonicalModel.lean | 86 | `h_no_H_bot : H-bot not in Gamma` | Medium - needs T-axiom proof |
| CanonicalHistory.lean | 136, 139 | T-axiom applications | Medium |
| CanonicalWorld.lean | 116, 162 | MCS properties | Medium |
| TaskRelation.lean | 5 sorries | Task relation coherence | Hard |
| IndexedMCSFamily.lean | 4 sorries | Family construction | Hard |
| CoherentConstruction.lean | 12 sorries | Temporal coherence | Hard |
| TruthLemma.lean | 4 sorries | Truth lemma backward direction | Hard |
| TemporalCompleteness.lean | 2 sorries | Temporal completeness | Hard |

## 2. The Soundness Duplication Issue

**Critical Finding**: There are **two** `soundness` theorems with different states:

| Location | Status | Type Signature |
|----------|--------|----------------|
| `Metalogic/Soundness.lean:586` | **PROVEN** | `(Gamma vdash phi) -> (Gamma models phi)` |
| `Completeness/WeakCompleteness.lean:90` | **SORRY** | `(DerivationTree Gamma phi) -> semantic_consequence Gamma phi` |

These have the same type (since `Gamma vdash phi` is notation for `DerivationTree Gamma phi`). The WeakCompleteness file has a local sorry'd copy instead of importing the proven one.

**Fix**: The `Completeness.soundness` can be replaced by importing `Metalogic.soundness`.

## 3. Recommended Implementation Strategy

### Phase 1: Bridge FMP to Standard API (HIGH PRIORITY)

Create wrappers that expose `semantic_weak_completeness` with the standard completeness API:

```lean
-- In a new file or in WeakCompleteness.lean
theorem weak_completeness_v2 (phi : Formula) : valid phi -> |- phi := by
  intro h_valid
  -- Use semantic_weak_completeness directly
  apply semantic_weak_completeness phi
  intro w
  -- Show phi is true at every SemanticWorldState
  -- This requires bridging between validity and SemanticWorldState truth
  sorry -- Bridge lemma needed
```

**Challenge**: The `semantic_weak_completeness` uses `SemanticWorldState` and `semantic_truth_at_v2`, while standard validity uses arbitrary frames. A bridge lemma is needed.

### Phase 2: Fix the Trivial Sorry (MEDIUM PRIORITY)

If continuing with the Representation path is preferred, fix the single tractable sorry:

**File**: `Completeness/WeakCompleteness.lean`
**Change**: Replace local `soundness` with import of `Bimodal.Metalogic.soundness`

```lean
-- Current (sorried):
theorem soundness (Gamma : Context) (phi : Formula) :
    (DerivationTree Gamma phi) -> semantic_consequence Gamma phi := by
  sorry

-- Fix: Import and use the proven soundness
import Bimodal.Metalogic.Soundness

-- Then soundness is already available as Bimodal.Metalogic.soundness
```

**But Note**: This only fixes 1 of 37+ sorries. The upstream Representation sorries remain.

### Phase 3: Create New Strong Completeness (HIGH PRIORITY)

Build `strong_completeness` directly from `semantic_weak_completeness`:

```lean
theorem strong_completeness_v2 (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi := by
  -- Use the same impChain strategy as FiniteStrongCompleteness
  -- But base it on semantic_weak_completeness instead of weak_completeness
  intro h_entails
  have h_valid := entails_imp_chain Gamma phi h_entails
  -- Need: semantic_weak_completeness works for impChain validity
  sorry
```

### Phase 4: Create New Compactness (HIGH PRIORITY)

The current `compactness` proof uses `infinitary_strong_completeness` which depends on `representation_theorem` (2 sorries). An alternative path:

1. Prove compactness using FMP + finiteness
2. FMP gives finite model property, which implies compactness for finite formulas
3. Standard argument: if infinite set inconsistent, finite subset inconsistent

## 4. Concrete Fix for Immediate Progress

The **single quickest fix** that makes progress:

1. **Import the proven soundness** into `WeakCompleteness.lean`:
   - Add: `import Bimodal.Metalogic.Soundness`
   - Change the local `soundness` to delegate to `Bimodal.Metalogic.soundness`

2. **However**, this does NOT make `weak_completeness` sorry-free because it still depends on `representation_theorem` which has 2 sorries.

## 5. Architectural Recommendation

Given the analysis, the **recommended approach** is:

1. **Use `semantic_weak_completeness` as the foundation** - it's proven and works
2. **Create new theorems** (`weak_completeness_fmp`, `strong_completeness_fmp`, `compactness_fmp`) based on FMP
3. **Archive the Representation path** to Boneyard (already recommended in research-007)

This avoids the 35+ hard sorries in the Representation module and builds on solid foundations.

## 6. Files Requiring Modification

| File | Action | Priority |
|------|--------|----------|
| `FMP/SemanticCanonicalModel.lean` | Add bridge lemmas for standard validity API | HIGH |
| `Completeness/WeakCompleteness.lean` | Import Metalogic.Soundness OR rewrite using FMP | MEDIUM |
| `Completeness/FiniteStrongCompleteness.lean` | Update to use FMP-based completeness | HIGH |
| `Compactness/Compactness.lean` | Verify it works with FMP path | HIGH |
| `Representation/*` | Archive to Boneyard | LOW |

## 7. Key Bridge Lemma Needed

To connect `semantic_weak_completeness` to standard validity:

```lean
-- Need to prove:
lemma validity_implies_semantic_truth (phi : Formula) :
    valid phi ->
    forall (w : SemanticWorldState phi),
      semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi
```

This requires showing that if `phi` is true in ALL task semantic models, then it's true in the specific `SemanticWorldState` construction used by `semantic_weak_completeness`.

## 8. Conclusion

The path to sorry-free completeness theorems is clear:

1. **`semantic_weak_completeness`** is already sorry-free (FMP path)
2. A bridge lemma connecting standard validity to `SemanticWorldState` truth is needed
3. Once bridged, `strong_completeness` and `compactness` follow from the existing proofs

The Representation path has 35+ sorries and is architecturally redundant. The recommended strategy is to build on FMP and archive Representation.

## References

- Prior research: `specs/777_complete_weak_completeness_sorry/reports/research-007.md`
- FMP architecture: `Theories/Bimodal/Metalogic/FMP/README.md`
- Proven soundness: `Theories/Bimodal/Metalogic/Soundness.lean`

## Next Steps

1. Implement the bridge lemma `validity_implies_semantic_truth`
2. Create `weak_completeness_fmp` using the bridge
3. Update `strong_completeness` to use FMP path
4. Verify `compactness` works with FMP path
5. Archive Representation module to Boneyard
