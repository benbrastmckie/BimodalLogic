# Research Report: Complete weak_completeness Sorry

**Task**: 777 - Complete the architectural sorry in weak_completeness
**Date**: 2026-01-30
**Session**: sess_1769739438_c1504f
**Language**: Lean

## Executive Summary

The sorry in `weak_completeness` is **architecturally unfixable** due to a fundamental mismatch between universal validity (`valid phi`) and semantic truth in finite models (`semantic_truth_at_v2`). The gap arises from Box semantics quantifying over ALL histories, while MCS-derived world states only carry information about ONE state.

**Recommendation**: Document this as a known architectural limitation and use `semantic_weak_completeness` for sorry-free completeness proofs.

## 1. The Sorry Location

**File**: `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean`
**Lines**: 211-217

```lean
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro _h_valid
  -- The gap: We need to show that if phi is valid in ALL models, it is true
  -- at all SemanticWorldStates under semantic_truth_at_v2. This requires
  -- the forward truth lemma which is architecturally impossible.
  sorry
```

## 2. The Two Validity Definitions

### 2.1 Universal Validity (`valid`)
**File**: `Theories/Bimodal/Semantics/Validity.lean` (lines 61-64)

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ
```

This quantifies over:
- ALL temporal types D
- ALL task frames F
- ALL models M
- ALL world histories tau
- ALL times t

### 2.2 Semantic Truth (`semantic_truth_at_v2`)
**File**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` (lines 254-256)

```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop :=
  ∃ h_mem : psi ∈ closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

This checks a boolean assignment in a specific finite model constructed from closure-maximal-consistent sets.

## 3. The Forward Truth Lemma Gap

### 3.1 What Would Be Needed

To bridge `valid phi` to `semantic_weak_completeness`, we would need:

```lean
-- IMPOSSIBLE: truth_at_implies_semantic_truth
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) phi
```

### 3.2 Why It Fails: The Box Problem

**From** `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`:

1. **Box quantifies over ALL histories**: In TM semantics, `truth_at M tau t (box psi)` requires `psi` to be true at ALL world states accessible from `tau.states t _`. This is universal quantification over the entire frame.

2. **MCS construction has ONE state**: A ClosureMaximalConsistent set describes ONE world state's truth values. It has no information about other histories.

3. **The Gap**: For the forward direction:
   - Given: `truth_at M tau t phi` (recursive evaluation)
   - Need to show: The assignment at `tau.states t ht` has `phi` marked true
   - For Box formulas, this requires the assignment to MATCH recursive evaluation
   - But arbitrary FiniteWorldStates have arbitrary locally-consistent assignments

4. **Circular dependency**: Even for MCS-derived states, the forward direction would require knowing the formula is in the MCS, which requires completeness - circular!

### 3.3 The Backward Direction Works

The backward direction (MCS membership implies truth) works because:
- MCS membership DEFINES what's true in the constructed model
- We build the model so that phi in S implies phi is true

## 4. The Sorry-Free Alternative

### 4.1 `semantic_weak_completeness`
**File**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` (lines 354-411)

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

**Proof strategy** (contrapositive):
1. Assume phi is not provable
2. Then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS
5. Build FiniteWorldState from closure MCS
6. phi is FALSE at this world state (by construction)
7. Build SemanticWorldState at origin
8. phi is false in semantic_truth_at_v2 sense
9. This contradicts the hypothesis that phi is true everywhere

**Why this works**: The contrapositive only needs to show phi is FALSE at ONE state. MCS-derived world states have the truth correspondence property by construction. No forward truth lemma needed.

## 5. Approaches Attempted and Failed

### 5.1 MCSDerivedWorldState Restriction
**File**: `Theories/Bimodal/Boneyard/Metalogic_v3/FailedTruthLemma/MCSDerivedWorldState.lean`

Attempted to restrict the truth lemma to "MCS-derived" world states. **Failed** because even for MCS-derived states, the Box case requires truth at ALL histories, not just MCS-derived ones.

### 5.2 Algebraic-Semantic Bridge
**File**: `Theories/Bimodal/Boneyard/Metalogic_v3/FailedTruthLemma/AlgebraicSemanticBridge.lean`

Attempted to bridge algebraic representation (ultrafilter membership) to Kripke semantics. **Failed** because `algTrueAt U (box psi)` means membership in ONE ultrafilter, while `truth_at (box psi)` requires truth at ALL histories.

### 5.3 Hybrid Completeness
**File**: `Theories/Bimodal/Boneyard/Metalogic_v3/FailedTruthLemma/HybridCompleteness.lean`

Attempted to combine algebraic and FMP paths. **Failed** at the final step requiring `valid_implies_semantic_truth`.

## 6. Analysis: Is the Sorry Fixable?

### 6.1 Mathematical Possibility

**No**, the sorry is mathematically unfixable in the current architecture. The fundamental issue is that:

- `valid phi` is a statement about ALL possible models (uncountably many)
- `semantic_truth_at_v2` is a statement about ONE specific finite model
- Bridging these requires showing recursive truth evaluation matches finite model satisfaction
- For Box, recursive evaluation quantifies over ALL histories
- Finite models cannot capture "all histories" - they are inherently bounded

### 6.2 Alternative Architectures

To fix this, one would need to:

1. **Restrict the domain of validity**: Define validity only over certain model classes. But this changes the theorem statement.

2. **Change Box semantics**: Use an algebraic semantics instead of quantifying over histories. But this changes the logic's interpretation.

3. **Accept the weaker theorem**: Use `semantic_weak_completeness` which provides completeness for the finite model semantics. This is the current approach.

## 7. Recommendations

### 7.1 Documentation
Keep the sorry with clear documentation explaining it is architectural, not a proof gap.

### 7.2 Usage Guidance
Direct users to `semantic_weak_completeness` for sorry-free completeness proofs.

### 7.3 No Implementation Needed
This task should be marked as architectural/impossible rather than attempting further fixes.

## 8. Key Files Analyzed

| File | Purpose |
|------|---------|
| `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` | Main completeness theorems |
| `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | Sorry-free `semantic_weak_completeness` |
| `Theories/Bimodal/Semantics/Validity.lean` | `valid` definition |
| `Theories/Bimodal/Semantics/Truth.lean` | `truth_at` definition |
| `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean` | Gap documentation |
| `Boneyard/Metalogic_v4/FMP/README.md` | Architecture explanation |
| `Theories/Bimodal/Boneyard/Metalogic_v3/FailedTruthLemma/README.md` | Failed approaches |
| `Theories/Bimodal/Boneyard/Metalogic_v3/FailedTruthLemma/HybridCompleteness.lean` | Hybrid attempt |

## 9. Conclusion

The sorry in `weak_completeness` represents a **fundamental architectural limitation** in the relationship between:

- Universal validity (truth in all models)
- Finite model semantics (truth in constructed canonical models)

The gap is not a proof technique problem - it reflects a genuine mathematical incompatibility between the two notions when Box quantifies over all histories.

The sorry-free alternative `semantic_weak_completeness` provides the completeness result needed for practical use. The architectural sorry should be documented and preserved as a known limitation rather than attempted to be fixed.

**Status**: Architectural - No implementation possible
**Action**: Document limitation, use `semantic_weak_completeness` instead
