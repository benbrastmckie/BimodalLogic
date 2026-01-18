# Research Report: Task #566

**Task**: 566 - Complete Semantic Embedding for Completeness Proof
**Date**: 2026-01-18
**Focus**: Complete semantic embedding for completeness proof to eliminate the `representation_theorem_backward_empty` axiom
**Session ID**: sess_1768700705_440112

## Summary

The semantic embedding gap identified in Task 560 requires bridging canonical model truth (set membership) to polymorphic semantic validity (quantified over all temporal types). Research reveals that existing infrastructure in `Metalogic/Completeness/FiniteCanonicalModel.lean` contains a PROVEN `semantic_weak_completeness` theorem that can be leveraged. The key insight is that `SemanticCanonicalFrame` with `D = Int` provides a concrete instantiation that satisfies all required properties.

## Findings

### 1. Problem Statement

The axiom `representation_theorem_backward_empty` in `Metalogic_v2/Representation/ContextProvability.lean` states:

```lean
axiom representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ
```

The proof strategy is via contrapositive:
1. Assume `¬ContextDerivable [] φ`
2. Show `Consistent [φ.neg]` (PROVEN in `not_derivable_implies_neg_consistent`)
3. By `representation_theorem`: `∃ w : CanonicalWorldState, φ.neg ∈ w.carrier`
4. **GAP**: Need to show `¬semantic_consequence [] φ` (existence of countermodel)

### 2. The Semantic Embedding Gap

The gap arises from type mismatches:

**Canonical Model Side (Metalogic_v2)**:
- `CanonicalWorldState`: Maximal consistent set of formulas
- `canonicalTruthAt w φ := φ ∈ w.carrier` (set membership)
- No temporal structure - just an abstract set of formulas

**Semantic Validity Side**:
```lean
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ
```

- Requires constructing `TaskFrame D`, `TaskModel`, `WorldHistory`
- Truth defined via recursive evaluation on formula structure
- Temporal operators quantify over ALL times in D

### 3. Existing Infrastructure in FiniteCanonicalModel.lean

The old `Metalogic/Completeness/FiniteCanonicalModel.lean` (4000+ lines) contains substantial infrastructure:

**SemanticWorldState Approach** (PROVEN, lines ~2072-2211):
- `SemanticWorldState phi`: Equivalence classes of (history, time) pairs
- Truth at world = truth in underlying history (no negation-completeness needed)
- Finite by construction (`semanticWorldState_finite`)

**SemanticCanonicalFrame** (PROVEN, lines ~2826-2860):
```lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel_v2 phi
  nullity := ...  -- proven
  compositionality := ... -- proven
```

**semantic_weak_completeness** (PROVEN, lines ~3280-3349):
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (FiniteTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

This proves: if phi is true at all semantic world states, then phi is derivable. This is the CORE result.

**main_weak_completeness** (HAS SORRY, lines ~3912-3930):
```lean
noncomputable def main_weak_completeness (phi : Formula) (h_valid : valid phi) : ⊢ phi :=
  semantic_weak_completeness phi (fun w => by sorry)  -- Bridge gap
```

This would connect `valid phi` to derivability, but needs the bridge to show `valid phi` implies truth at all `SemanticWorldState phi`.

**Bridge Infrastructure** (PARTIAL, lines ~3390-3920):
- `finiteHistoryToWorldHistory`: Converts FiniteHistory to WorldHistory (has 1 sorry in `respects_task`)
- `semantic_world_state_has_world_history`: Every semantic world state has a world history (has 1 sorry)
- `semantic_valuation_iff_assignment`: Connects valuations (proven)
- `semantic_truth_implies_truth_at`: Truth bridge (multiple sorries)

**Key Finding**: The core `semantic_weak_completeness` IS proven. The gap is bridging from `valid phi` (polymorphic over all temporal types) to `semantic_truth_at_v2` in the specific `SemanticCanonicalModel`.

### 4. Two Approaches to Complete the Embedding

**Approach A: Leverage Existing semantic_weak_completeness**

The `semantic_weak_completeness` theorem is PROVEN and establishes:
```
(∀ w : SemanticWorldState phi, semantic_truth_at_v2 ... phi) → ⊢ phi
```

To use this for `representation_theorem_backward_empty`:

1. Given `semantic_consequence [] φ`, we have φ valid in ALL models including `SemanticCanonicalModel φ`
2. Validity in `SemanticCanonicalModel φ` means φ true at all `SemanticWorldState φ`
3. Apply `semantic_weak_completeness φ` to get `⊢ φ`
4. Wrap in `ContextDerivable` constructor

**Key insight**: This approach requires proving that `semantic_consequence [] φ` implies truth at all `SemanticWorldState φ`. The bridge theorems with sorries (`finiteHistoryToWorldHistory.respects_task`, `semantic_world_state_has_world_history`) need to be completed.

**Approach B: Direct Instantiation with Int**

Instead of abstract bridges, directly instantiate the polymorphic quantifier:

1. `semantic_consequence [] φ` quantifies over ALL types D
2. Instantiate with `D = Int`, `F = SemanticCanonicalFrame φ`, `M = SemanticCanonicalModel φ`
3. For each `SemanticWorldState φ`, construct corresponding `WorldHistory`
4. Use the instantiated hypothesis to get φ true at all world states
5. Apply `semantic_weak_completeness`

This requires completing `finiteHistoryToWorldHistory` to properly construct world histories.

### 5. Required Bridge Theorems

To complete either approach, the following theorems need proofs:

**Critical (Approach A & B)**:
1. `finiteHistoryToWorldHistory.respects_task` (1 sorry at line ~3430-3435)
   - Need: `semantic_task_rel_v2 phi (states s) (t - s) (states t)`
   - Challenge: Clamping at boundaries complicates the proof

2. `semantic_world_state_has_world_history` (1 sorry at line ~3455)
   - Need: Extract representative history and show states match
   - Challenge: Time shift alignment

**Supporting**:
3. `truth_at_iff_semantic_truth` (lines ~3510-3520, multiple sorries)
   - Need: Truth in WorldHistory matches `semantic_truth_at_v2`
   - Structural induction on formula

4. `semantic_canonical_model_correct` (line ~3835)
   - Need: Tie everything together for completeness

### 6. Alternative: Simpler Proof via FMP

The Finite Model Property (FMP) approach might be simpler:

1. If `¬ContextDerivable [] φ`, then φ.neg is consistent
2. By `finite_model_property_contrapositive` (line ~4060): there exists a finite countermodel
3. This finite countermodel witnesses `¬semantic_consequence [] φ`

The FMP theorem IS proven (see line ~4060-4145):
```lean
theorem finite_model_property_contrapositive (φ : Formula) :
    ¬(⊢ φ) → ∃ (FF : FiniteTaskFrame Int) ...
```

This shows: if φ is not provable, there exists a finite model falsifying φ.

### 7. Architecture Analysis

**Metalogic_v2 vs Metalogic Structure**:

| Component | Metalogic_v2 | Metalogic (old) |
|-----------|--------------|-----------------|
| World State | `CanonicalWorldState` (MCS) | `SemanticWorldState` (quotient) |
| Truth | Set membership | History evaluation |
| Frame | `canonicalFrame` (abstract) | `SemanticCanonicalFrame` (concrete) |
| Completeness | `representation_theorem_backward_empty` (axiom) | `semantic_weak_completeness` (proven) |
| FMP | Not present | `finite_model_property_contrapositive` (proven) |

**Key Insight**: Metalogic_v2's `CanonicalWorldState` is more abstract (just MCS), while Metalogic's `SemanticWorldState` is concrete (history-time quotient). The proven infrastructure is in Metalogic, not Metalogic_v2.

### 8. Recommended Proof Strategy

**Phase 1: Port/Adapt Key Lemmas**

The cleanest approach is to adapt the proven `semantic_weak_completeness` for use in Metalogic_v2:

1. Import `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` into Metalogic_v2
2. Prove a bridge lemma:
   ```lean
   theorem semantic_consequence_to_semantic_truth {φ : Formula} :
       semantic_consequence [] φ →
       ∀ (w : SemanticWorldState φ), semantic_truth_at_v2 φ w (FiniteTime.origin ...) φ
   ```
3. Compose with `semantic_weak_completeness`

**Phase 2: Complete Bridge Sorries**

The bridge sorries in FiniteCanonicalModel.lean are:
- `finiteHistoryToWorldHistory.respects_task` (complex due to clamping)
- `semantic_world_state_has_world_history` (complex due to time alignment)

These could be:
- Proven directly (estimated 4-6 hours)
- Simplified by avoiding clamping (define history with full Int domain)

**Phase 3: Replace Axiom**

Once bridge is complete:
```lean
theorem representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ := by
  intro h_sem
  have h_all_sw := semantic_consequence_to_semantic_truth h_sem
  have h_prov := semantic_weak_completeness φ h_all_sw
  exact ⟨h_prov⟩
```

### 9. Complexity Assessment

| Approach | Estimated Effort | Risk |
|----------|------------------|------|
| Port semantic_weak_completeness (use FMP) | 2-3 hours | Low |
| Complete bridge sorries directly | 4-6 hours | Medium |
| Build new semantic embedding from scratch | 8-12 hours | High |

**Recommendation**: Start with the FMP approach since `finite_model_property_contrapositive` is proven.

### 10. Dependencies

**Required Imports** (already present or available):
- `Bimodal.Metalogic_v2.Core.MaximalConsistent`
- `Bimodal.Metalogic_v2.Representation.RepresentationTheorem`
- `Bimodal.Metalogic.Completeness.FiniteCanonicalModel` (to add)

**Mathlib Dependencies** (already in project):
- `Mathlib.Order.Zorn` (for Lindenbaum)
- `Mathlib.Algebra.Order.Group.Int` (for Int temporal type)

## Recommendations

### Primary Recommendation: FMP-Based Approach

1. **Leverage Existing Proven Infrastructure**
   - `finite_model_property_contrapositive` is fully proven
   - Provides contrapositive direction directly

2. **Proof Sketch**:
   ```lean
   theorem representation_theorem_backward_empty {φ : Formula} :
       semantic_consequence [] φ → ContextDerivable [] φ := by
     -- By contrapositive
     apply Function.mtr
     intro h_not_deriv
     -- h_not_deriv : ¬ContextDerivable [] φ
     -- Need: ¬semantic_consequence [] φ

     -- Convert to ¬(⊢ φ) for FMP
     have h_not_prov : ¬(⊢ φ) := h_not_deriv

     -- Apply finite_model_property_contrapositive
     obtain ⟨FF, M, τ, ht, h_false⟩ := finite_model_property_contrapositive φ h_not_prov

     -- Construct countermodel for semantic_consequence
     intro h_sem
     -- h_sem : ∀ D F M τ t, ... → truth_at M τ t φ
     -- Instantiate with FF (as TaskFrame Int)
     have h_truth := h_sem Int FF.toTaskFrame M τ 0 (by intro ψ hψ; exact List.not_mem_nil hψ |>.elim)
     -- But h_false says ¬truth_at M τ 0 φ
     exact h_false h_truth
   ```

3. **Estimated Effort**: 2-3 hours
   - Main complexity: handling type conversions and universe levels

### Secondary Recommendation: Bridge Completion

If FMP approach encounters issues:

1. Complete `finiteHistoryToWorldHistory.respects_task`
   - Simplify by using non-clamping domain (full Int always in domain)

2. Complete `semantic_world_state_has_world_history`
   - Use constant history at fixed time

3. Connect via `semantic_weak_completeness`

### Tertiary: Document Axiom Retention

If both approaches prove too complex for this task:

1. Enhance axiom documentation with specific gap analysis
2. Create follow-up subtasks for each missing bridge lemma
3. Track as technical debt in Metalogic_v2

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Universe level issues when instantiating polymorphic types | Medium | Use explicit type annotations; check `semantic_consequence` uses `Type` not `Type*` |
| FMP infrastructure doesn't export cleanly | Medium | May need to restructure imports or duplicate key lemmas |
| Time type mismatches (FiniteTime vs Int) | Low | `FiniteTime.toInt` provides conversion |
| Clamping in world history complicates respects_task | Medium | Use non-clamping approach with full Int domain |

## References

**Primary Source Files**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Target file with axiom
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Proven semantic completeness
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean` - `semantic_consequence` definition

**Key Theorems**:
- `semantic_weak_completeness` (line ~3280) - Core completeness
- `finite_model_property_contrapositive` (line ~4060) - FMP
- `not_derivable_implies_neg_consistent` (ContextProvability.lean line 97) - Syntactic half

**Task References**:
- Task 560: Partial implementation, identified gap
- Task 473: SemanticWorldState architecture
- Task 450: Formal connection to general completeness (not yet done)

**External References**:
- Blackburn et al., Modal Logic, Chapter 4.8 (Canonical Model Construction)
- specs/560_axiom_elimination/summaries/implementation-summary-20260117.md

## Next Steps

1. Run `/plan 566` to create implementation plan
2. Focus on FMP approach first as it has fewest gaps
3. Verify imports compile when adding FiniteCanonicalModel dependency
4. Test proof sketch in isolated file before modifying ContextProvability.lean
