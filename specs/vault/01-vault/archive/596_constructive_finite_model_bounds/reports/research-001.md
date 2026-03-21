# Research Report: Task #596

**Task**: 596 - Constructive Finite Model Bounds
**Date**: 2026-01-18
**Focus**: constructive_finite_model_bounds
**Session ID**: sess_1768785977_eb9479
**Language**: lean

## Summary

The current Finite Model Property (FMP) implementation in `Metalogic_v2/Representation/FiniteModelProperty.lean` uses a trivial identity witness that simply unpacks and repacks the satisfiability hypothesis without constructing a finite model. A constructive implementation should explicitly construct a finite model bounded by `2^|subformulaList phi|` using the filtration technique and existing `FiniteCanonicalModel` infrastructure. The old code can be archived to `Bimodal/Boneyard/` once the constructive alternative achieves zero sorries.

## Findings

### 1. Current Trivial Witness Implementation

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` (lines 176-187)

```lean
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ →
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
      truth_at M τ t φ := by
  intro h_sat
  -- Uses the satisfiability witness directly (identity proof)
  obtain ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩ := h_sat
  exact ⟨D, inst1, inst2, inst3, F, M, τ, t, h_truth⟩
```

**Problem**: This is a trivial identity function that provides no constructive content. The theorem claims to prove FMP but simply returns the input model unchanged. It does not:
- Construct a finite model
- Provide any model size bound
- Use the subformula closure
- Leverage the canonical model construction

The related theorems (`finite_model_size_bound`, `satisfiability_decidable`, `validity_decidable_via_fmp`) similarly use `Classical.dec` or delegate to this trivial proof.

### 2. Existing Infrastructure for Constructive FMP

The codebase has substantial infrastructure in `FiniteCanonicalModel.lean` (4000+ lines) that can support a constructive FMP:

#### 2.1 Subformula Closure Infrastructure
- `subformulaList : Formula → List Formula` - computes subformulas
- `closure : Formula → Finset Formula` - subformula closure as Finset
- `closureWithNeg` - closure plus negations
- `subformulaList_finite` - proves `length < 2^complexity + 1` (proven in v2, sorry in v1)
- `closureSize` - cardinality of closure

#### 2.2 Finite Time Domain
- `FiniteTime k := Fin (2 * k + 1)` - time domain from -k to +k
- `temporalBound : Formula → Nat` - computes bound from temporal depth

#### 2.3 Finite World State Infrastructure
- `FiniteWorldState phi` - world states restricted to closure
- `FiniteTruthAssignment phi` - truth assignments on closure
- `IsLocallyConsistent` - consistency predicate
- `ClosureMaximalConsistent` - closure-restricted MCS

#### 2.4 Semantic World State Approach (Preferred)
- `SemanticWorldState phi := Quotient (htSetoid phi)` - equivalence classes of (history, time) pairs
- `semantic_task_rel_v2` - task relation via history existence
- `SemanticCanonicalFrame phi` - TaskFrame using semantic world states
- `SemanticCanonicalModel phi` - TaskModel for completeness

#### 2.5 Key Proven Results
- `semantic_truth_lemma_v2` - membership equals semantic truth (proven, no sorries)
- `semantic_weak_completeness` - validity implies derivability (proven)
- `semanticWorldState_finite` - semantic world states are finite

### 3. Boneyard Directory Structure

**Location**: `Theories/Bimodal/Boneyard/`

Current contents:
- `SyntacticApproach.lean` - Documentation of deprecated syntactic approach
- `DurationConstruction.lean` - Documentation of deprecated Duration-based time

These are documentation files explaining why certain approaches were deprecated. The old FMP implementation should be archived here with similar documentation.

### 4. Key Mathlib Resources

For constructive finite model bounds:

| Resource | Purpose | Location |
|----------|---------|----------|
| `Fintype.card` | Cardinality of finite types | `Mathlib.Data.Fintype.Card` |
| `Finset.card_pow_le` | `(s^n).card ≤ s.card^n` | `Mathlib.Algebra.Group.Pointwise.Finset.Basic` |
| `Quotient.finite` | Quotient of finite type is finite | Mathlib |
| `Fintype.subtype` | Subtype of finite type is finite | `Mathlib.Data.Fintype.Defs` |
| `Finset.card_le_univ` | `s.card ≤ Fintype.card α` | `Mathlib.Data.Fintype.Card` |

### 5. Filtration Technique

The standard approach for constructive FMP in modal logic:

1. **Input**: Model `M` where `φ` is satisfied at world `w`
2. **Subformula Closure**: Compute `Φ = closure(φ)`
3. **Equivalence Relation**: Define `w ~ v` iff `∀ψ ∈ Φ, M ⊨_w ψ ↔ M ⊨_v ψ`
4. **Quotient Model**: `M' = M / ~` with `|W'| ≤ 2^|Φ|`
5. **Truth Preservation**: Show `M' ⊨_[w] ψ ↔ M ⊨_w ψ` for `ψ ∈ Φ`
6. **Output**: Finite model `M'` satisfying `φ`

This is essentially what `SemanticWorldState` already implements.

### 6. Sorries in Current Semantic Infrastructure

The semantic approach has several remaining sorries that block a complete constructive proof:

| Location | Sorry | Description |
|----------|-------|-------------|
| `closure_consistent_empty` | 1 sorry | Empty context consistency |
| `closure_lindenbaum_via_projection` | 1 sorry | Inconsistency projection |
| `closureSize_le_complexity` | 1 sorry | Size bound |
| `glue_histories.forward_rel` | 4 sorries | History gluing edge cases |
| `glue_histories.backward_rel` | 1 sorry | History gluing |
| `SemanticTaskRelV2.compositionality` | Uses history gluing | |
| `finite_history_from_state` | 2 sorries | History construction |
| `finiteHistoryToWorldHistory.respects_task` | 1 sorry | Clamping proof |
| Various existence theorems | ~4 sorries | Transfer requirements consistency |

**Total**: Approximately 15-20 sorries in the semantic infrastructure.

### 7. Proposed Constructive Statement

A proper constructive FMP should have this form:

```lean
/-- Constructive Finite Model Property with explicit size bound -/
theorem finite_model_property_constructive (φ : Formula) :
    formula_satisfiable φ →
    ∃ (W : Type) (_ : Fintype W) (hbound : Fintype.card W ≤ 2^(closureSize φ))
      (F : TaskFrame Int) (M : TaskModel F) (τ : WorldHistory F) (t : Int),
      F.WorldState = W ∧ truth_at M τ t φ
```

This explicitly asserts:
1. The witness type `W` is finite (`Fintype W`)
2. The cardinality is bounded by `2^|closure(φ)|`
3. The model satisfies `φ`

## Recommendations

### Phase 1: Complete Semantic Infrastructure (Effort: 4-6 hours)

1. **Resolve closure_lindenbaum_via_projection sorry** (high priority)
   - The projection argument needs to show inconsistency witnesses can be restricted to closure

2. **Prove closureSize_le_complexity**
   - Each subformula contributes at most 1 to complexity
   - Should be a straightforward induction

3. **Complete history gluing**
   - The `glue_histories` edge cases are boundary handling
   - Need to handle when shifted time is out of bounds

### Phase 2: Constructive FMP Statement (Effort: 2-3 hours)

1. **Define proper constructive FMP theorem**
   - Use `Fintype` instance to witness finiteness
   - Include explicit cardinality bound
   - Connect to `SemanticCanonicalModel`

2. **Prove bound using SemanticWorldState**
   - `SemanticWorldState` is already shown finite
   - Need to connect its cardinality to `2^|closure|`

### Phase 3: Archive Old Implementation (Effort: 1 hour)

1. **Create Boneyard/TrivialFMP.lean**
   - Move trivial `finite_model_property` and related theorems
   - Add documentation explaining why replaced

2. **Update imports**
   - Ensure nothing depends on archived code
   - Update Metalogic_v2.lean to not import old file

### Implementation Strategy

The most direct path to constructive FMP:

1. **Use SemanticCanonicalModel directly**
   - `SemanticCanonicalModel φ` is already a valid TaskModel
   - `SemanticWorldState φ` is provably finite
   - `semantic_weak_completeness` connects to derivability

2. **Prove world state bound**
   ```lean
   theorem semanticWorldState_card_bound (φ : Formula) :
       Fintype.card (SemanticWorldState φ) ≤ 2^(closureSize φ)
   ```
   - Uses: `SemanticWorldState` maps injectively to `FiniteWorldState`
   - `FiniteWorldState` is at most 2^|closureWithNeg| truth assignments

3. **Connect to formula_satisfiable**
   - If `¬⊢ φ`, then `semantic_weak_completeness` gives countermodel
   - Contrapositive: if satisfiable, must be satisfiable in semantic model
   - Semantic model is finite with bounded size

## Dependencies

- Task 597 (re-prove main_provable_iff_valid in Metalogic_v2) - provides independence from old Metalogic/
- Existing `semantic_weak_completeness` infrastructure

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| History gluing sorries cascade | High | Focus on same-history compositionality first |
| Cardinality bounds hard to prove | Medium | Use Mathlib Fintype.card lemmas |
| Old code has hidden dependencies | Low | Check imports before archiving |

## References

- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - 4000+ lines of infrastructure
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - current trivial FMP
- `Theories/Bimodal/Boneyard/SyntacticApproach.lean` - example of archived code

## Next Steps

Run `/plan 596` to create an implementation plan that:
1. Completes the minimal set of sorries needed for constructive FMP
2. Defines and proves the constructive FMP theorem
3. Archives the old trivial implementation to Boneyard/
