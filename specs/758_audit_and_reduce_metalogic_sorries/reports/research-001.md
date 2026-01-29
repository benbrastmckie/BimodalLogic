# Research Report: Audit and Reduce Metalogic Sorries

**Task**: 758 - Audit and reduce sorry count in Theories/Bimodal/Metalogic/
**Date**: 2026-01-29
**Session**: sess_1769710427_28a303

## Executive Summary

The Metalogic directory contains **28 actual code sorries** across 8 files (excluding comments mentioning "sorry"). The architecture features two parallel completeness paths:
1. **`semantic_weak_completeness`** - SORRY-FREE, provides the main completeness result
2. **Standard Kripke completeness** - Contains sorries in truth bridge lemmas

Most sorries are **NOT blocking** the main theorem path because `semantic_weak_completeness` bypasses them. The critical sorries are in soundness (1 sorry) and the classical propositional logic lemmas (2 sorries).

## Sorry Count by File

| File | Code Sorries | Category | Notes |
|------|-------------|----------|-------|
| `Representation/CoherentConstruction.lean` | 8 | (c) Exploratory | Cross-origin coherence cases |
| `Algebraic/AlgebraicSemanticBridge.lean` | 8 | (b) Secondary | Alternative completeness path |
| `Representation/TaskRelation.lean` | 5 | (c) Exploratory | Compositionality cases |
| `Representation/TruthLemma.lean` | 4 | (b) Secondary | Backward truth lemma + box |
| `Representation/IndexedMCSFamily.lean` | 4 | (b) Secondary | Delegates to CoherentConstruction |
| `FMP/SemanticCanonicalModel.lean` | 2 | (b) Secondary | Truth bridge + compositionality |
| `FMP/FiniteModelProperty.lean` | 1 | (b) Secondary | Constructive FMP variant |
| `Completeness/WeakCompleteness.lean` | 1 | **(a) Critical** | Soundness axiom |

**Total: 33 sorries** (28 code + 5 in IndexedMCSFamily that delegate)

## Detailed Analysis

### Category (a): Critical - Blocking Main Theorem Path

#### 1. Soundness Axiom (WeakCompleteness.lean:92)
```lean
theorem soundness (Γ : Context) (φ : Formula) :
    (DerivationTree Γ φ) → semantic_consequence Γ φ := by
  sorry
```
- **Complexity**: MEDIUM-HARD
- **Impact**: Required for bidirectional soundness-completeness
- **Notes**: Full proof exists in Boneyard/Metalogic_v2/Soundness but needs fixing for reflexive temporal semantics
- **Recommendation**: HIGH PRIORITY - Port and fix the Boneyard proof

### Category (b): Secondary - Required for Full Biconditional

#### 2. Classical Propositional Logic Lemmas (AlgebraicSemanticBridge.lean:301, 307)
```lean
-- Line 301: ⊢ ¬(ψ → χ) → ψ
sorry  -- Classical propositional logic

-- Line 307: ⊢ ¬(ψ → χ) → ¬χ
sorry  -- Classical propositional logic
```
- **Complexity**: EASY
- **Impact**: Needed for imp case backward direction in algebraic bridge
- **Notes**: Standard classical logic tautologies, need derivation trees
- **Recommendation**: MEDIUM PRIORITY - Straightforward proof construction

#### 3. Backward Truth Lemma - Temporal Cases (TruthLemma.lean:416, 438)
```lean
-- H case backward (line 416)
-- ARCHITECTURAL LIMITATION (omega-rule)
sorry

-- G case backward (line 438)
-- ARCHITECTURAL LIMITATION (omega-rule)
sorry
```
- **Complexity**: IMPOSSIBLE in current architecture
- **Impact**: Would complete truth lemma biconditional
- **Notes**: Requires deriving H/G from infinitely many instances (omega-rule), which TM logic cannot express. This is a fundamental limitation.
- **Recommendation**: LOW PRIORITY - Document as architectural limitation, not a bug

#### 4. Box Cases (TruthLemma.lean:366, 389)
```lean
-- Box forward (line 366)
sorry

-- Box backward (line 389)
sorry
```
- **Complexity**: MEDIUM
- **Impact**: Modal box completeness
- **Notes**: Requires reasoning about all histories, not just canonical history. Would need modal accessibility relations.
- **Recommendation**: LOW PRIORITY - Not used by current completeness approach

#### 5. Temporal Cases in AlgebraicSemanticBridge (lines 325, 328, 342, 347, 358, 362)
- **Complexity**: MEDIUM
- **Impact**: Alternative algebraic completeness path
- **Notes**: Requires time-independence lemma for constant histories
- **Recommendation**: LOW PRIORITY - `semantic_weak_completeness` bypasses this

#### 6. SemanticCanonicalModel Sorries
```lean
-- Line 226: Compositionality axiom
compositionality := fun _ _ _ _ _ => sorry

-- Line 684: Forward truth lemma gap
sorry
```
- **Complexity**: Line 226 - HARD (fundamental architectural issue); Line 684 - MEDIUM
- **Impact**: `truth_at_implies_semantic_truth` theorem
- **Notes**: Line 226 is mathematically false for unbounded durations. Line 684 is architectural gap between MCS-derived states and arbitrary states.
- **Recommendation**: LOW PRIORITY - `semantic_weak_completeness` bypasses both

#### 7. IndexedMCSFamily Coherence (lines 620, 626, 632, 638)
```lean
forward_G := by sorry  -- Delegates to CoherentConstruction
backward_H := by sorry
forward_H := by sorry
backward_G := by sorry
```
- **Complexity**: EASY (if CoherentConstruction is used)
- **Impact**: Alternative construction path
- **Notes**: These should invoke `CoherentConstruction.construct_coherent_family`
- **Recommendation**: MEDIUM PRIORITY - Simple delegation fix

#### 8. FiniteModelProperty Constructive (line 221)
```lean
-- truth_at (SemanticCanonicalModel φ) tau 0 φ
sorry
```
- **Complexity**: MEDIUM
- **Impact**: Constructive FMP variant
- **Notes**: Same truth bridge gap as SemanticCanonicalModel
- **Recommendation**: LOW PRIORITY - `semantic_weak_completeness` provides sorry-free completeness

### Category (c): Exploratory - Not Required

#### 9. CoherentConstruction Cross-Origin Cases (8 sorries at lines 712, 715, 723, 726, 744, 751, 799, 802)
All marked "NOT REQUIRED FOR COMPLETENESS" with references to Boneyard documentation.
- **Complexity**: HARD (would require fundamentally different construction)
- **Impact**: Full bidirectional coherence across time origin
- **Notes**: Completeness only uses single-direction chains. Cross-origin would need additional axioms.
- **Recommendation**: NO ACTION - Intentional scope exclusion

#### 10. TaskRelation Compositionality (5 sorries at lines 173, 186, 190, 196, 199)
```lean
sorry -- MCS equality argument (complex case analysis)
sorry -- Forward propagation (depends on signs of d1, d2)
...
```
- **Complexity**: MEDIUM
- **Impact**: `canonical_task_rel_compositionality` theorem
- **Notes**: Complex case analysis on signs of duration components
- **Recommendation**: LOW PRIORITY - Not used by main completeness path

## Priority Ranking

### High Priority (Should fix immediately)
1. **Soundness axiom** (WeakCompleteness.lean:92) - 1 sorry
   - This is the only sorry that truly blocks having a complete metatheory
   - Full proof exists in Boneyard, needs porting

### Medium Priority (Good to fix, moderate effort)
2. **Classical propositional logic lemmas** (AlgebraicSemanticBridge.lean:301, 307) - 2 sorries
   - Straightforward derivation tree construction
   - Would complete the algebraic completeness path

3. **IndexedMCSFamily delegation** (lines 620-638) - 4 sorries
   - Should simply delegate to CoherentConstruction
   - May be easy refactor

### Low Priority (Architectural limitations or alternative paths)
4. Backward truth lemma temporal cases - 2 sorries (omega-rule limitation)
5. Box cases in TruthLemma - 2 sorries (requires modal architecture change)
6. AlgebraicSemanticBridge temporal/box cases - 6 sorries
7. SemanticCanonicalModel truth bridge - 2 sorries
8. FiniteModelProperty constructive - 1 sorry

### No Action Recommended
9. CoherentConstruction cross-origin - 8 sorries (intentional scope exclusion)
10. TaskRelation compositionality - 5 sorries (not on critical path)

## Recommended Implementation Order

1. **Phase 1**: Fix soundness (1 sorry) - Port Boneyard/Metalogic_v2/Soundness, adapt for reflexive semantics
2. **Phase 2**: Fix classical prop logic lemmas (2 sorries) - Build derivation trees for standard tautologies
3. **Phase 3**: Fix IndexedMCSFamily delegation (4 sorries) - Refactor to use CoherentConstruction
4. **Future**: Consider algebraic bridge completion if alternative completeness path is needed

## Architecture Notes

The codebase has a **sorry-free completeness theorem** via:
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

This theorem at SemanticCanonicalModel.lean:448-505 is **fully proven without sorries**. It works by:
1. Assuming phi is not provable
2. Showing {neg phi} is consistent
3. Extending to MCS via Lindenbaum
4. Building a FiniteWorldState where phi is false
5. Deriving contradiction

The remaining sorries are either:
- On alternative completeness paths (algebraic bridge, standard Kripke)
- Architectural limitations (omega-rule, cross-origin coherence)
- The soundness axiom (which is needed for the other direction)

## Related Tasks

- **Task 750**: Forward Truth Lemma refactor - May address some TruthLemma sorries
- Boneyard/Metalogic_v2/Soundness: Contains full soundness proof needing adaptation

## Conclusion

The Metalogic directory is in good shape for its primary purpose. The `semantic_weak_completeness` theorem provides a sorry-free completeness result. The main gap is the **soundness axiom** (1 sorry), which blocks the soundness direction. The remaining sorries are either architectural limitations (cannot be fixed without fundamental changes) or on alternative completeness paths (nice to have but not blocking).

**Recommended action**: Focus on fixing the soundness axiom by porting and adapting the Boneyard proof.
