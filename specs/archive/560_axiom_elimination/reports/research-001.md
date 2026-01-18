# Research Report: Task #560

**Task**: 560 - Axiom Elimination
**Date**: 2026-01-17
**Focus**: Replace representation_theorem_backward_empty axiom with proven theorem in Representation/ContextProvability.lean using completeness contrapositive argument

## Summary

The axiom `representation_theorem_backward_empty` in `Representation/ContextProvability.lean` (line 83-84) asserts that semantic consequence from empty context implies syntactic derivability. This research identifies the proof strategy using the completeness contrapositive argument, discovers the required infrastructure already exists in Metalogic_v2, and outlines the theorem dependencies needed for the proof.

## Findings

### 1. Current State of the Axiom

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`

**Current Declaration** (lines 83-84):
```lean
axiom representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ
```

**Usage**: This axiom is used by:
- `representation_theorem_empty` (line 91-95): The full equivalence theorem
- `valid_implies_derivable` (line 102-107): Validity to derivability conversion
- `representation_validity` (line 126-130): Validity characterization
- `weak_completeness` in `Completeness/WeakCompleteness.lean` (line 68-77)

### 2. Proof Strategy: Completeness via Contrapositive

The standard completeness proof for modal logic proceeds by contrapositive:

**Goal**: `semantic_consequence [] φ → ContextDerivable [] φ`

**Contrapositive**: `¬ContextDerivable [] φ → ¬semantic_consequence [] φ`

**Proof Steps**:
1. Assume `¬ContextDerivable [] φ` (φ is not derivable from empty context)
2. Show `Consistent [φ.neg]` (negation is consistent)
3. By representation theorem, `[φ.neg]` is satisfiable in canonical model
4. Therefore `¬φ` is true at some world, so `φ` is false somewhere
5. Hence `¬semantic_consequence [] φ` (not valid in all models)

### 3. Available Infrastructure

**Core Theorems in `Representation/RepresentationTheorem.lean`**:

```lean
-- line 69-86
theorem representation_theorem :
    Consistent Γ → ∃ (w : CanonicalWorldState), ∀ φ ∈ Γ, canonicalTruthAt w φ

-- line 95-127
theorem strong_representation_theorem {φ : Formula} :
    ¬ContextDerivable Γ (Formula.neg φ) →
    ∃ (w : CanonicalWorldState), (∀ ψ ∈ Γ, canonicalTruthAt w ψ) ∧ (canonicalTruthAt w φ)
```

**Consistency Definitions in `Core/MaximalConsistent.lean`**:

```lean
-- line 58
def Consistent (Γ : Context) : Prop := ¬Nonempty (DerivationTree Γ Formula.bot)
```

**Propositional Logic Theorems in `Theorems/Propositional.lean`**:

```lean
-- Double Negation Elimination (line 140)
def double_negation (φ : Formula) : ⊢ φ.neg.neg.imp φ

-- Derives from inconsistent extension (MaximalConsistent.lean line 362-370)
lemma derives_neg_from_inconsistent_extension {Γ : Context} {φ : Formula}
    (h_incons : ¬Consistent (φ :: Γ)) :
    Nonempty (DerivationTree Γ (Formula.neg φ))
```

**Mathlib Theorems for Contrapositive**:

```lean
-- From Mathlib.Logic.Basic
theorem not_imp_not : (¬a → ¬b) ↔ (b → a)
theorem Function.mtr : (¬a → ¬b) → b → a
theorem Mathlib.Tactic.Contrapose.mtr : (¬q → ¬p) → (p → q)
```

### 4. Key Insight: The Gap

The existing `completeness_corollary` in `RepresentationTheorem.lean` (lines 138-159) attempts this proof but has two sorries:

1. **Double negation elimination in proof context** (line 151): Needs to show that `[] ⊢ ¬¬φ` implies `[] ⊢ φ`
2. **Connecting canonical world truth to semantic validity** (line 159): Needs to bridge canonical truth to model satisfaction

**The Gap**: The canonical model `CanonicalWorldState` is constructed from maximal consistent sets, but there's no direct embedding into the polymorphic semantic framework that quantifies over `∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

### 5. Proof Approach

**Option A: Direct Proof via Canonical Model**

This requires constructing a semantic interpretation from the canonical model:
1. Choose a concrete temporal type (e.g., `Int` or `Nat`)
2. Construct a `TaskFrame D` from `CanonicalFrame`
3. Construct a `TaskModel F` from `CanonicalModel`
4. Show truth in canonical model implies truth in constructed semantic model

**Option B: Proof via Contrapositive with Existing Infrastructure**

1. Use `strong_representation_theorem` with `Γ = []`
2. When `¬ContextDerivable [] φ`, need to show `¬ContextDerivable [] (Formula.neg φ)` implies consistency
3. Actually, the theorem gives us the converse: from `¬ContextDerivable [] (Formula.neg φ)`, we get satisfiability

The key is showing:
```
¬ContextDerivable [] φ → Consistent [φ.neg]
```

This follows because:
- `¬ContextDerivable [] φ` means `¬Nonempty (DerivationTree [] φ)`
- If `[φ.neg]` were inconsistent, we'd have `[φ.neg] ⊢ ⊥`
- By deduction theorem: `[] ⊢ φ.neg → ⊥` = `[] ⊢ φ.neg.neg`
- By DNE: `[] ⊢ φ`
- Contradiction with `¬ContextDerivable [] φ`

### 6. Critical Dependencies

**Required for the Proof**:

1. **Deduction Theorem**: Available at `Core/DeductionTheorem.lean`
   - `deduction_theorem : (A :: Γ) ⊢ B → Γ ⊢ A.imp B`

2. **Double Negation Elimination**: Available at `Theorems/Propositional.lean`
   - `double_negation : ⊢ φ.neg.neg.imp φ`

3. **Representation Theorem**: Available at `Representation/RepresentationTheorem.lean`
   - `representation_theorem : Consistent Γ → ∃ w, ∀ φ ∈ Γ, canonicalTruthAt w φ`

4. **Semantic Embedding** (MISSING): Need to show canonical world satisfaction implies semantic validity negation

### 7. The Semantic Embedding Problem

**Challenge**: `semantic_consequence` quantifies over all temporal types:

```lean
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ
```

But `canonicalTruthAt` is defined simply as set membership:

```lean
def canonicalTruthAt (w : CanonicalWorldState) (φ : Formula) : Prop := φ ∈ w.carrier
```

**Bridge Required**: Need to either:
1. Construct a concrete semantic model from canonical model, OR
2. Show canonical truth failure implies existence of a semantic countermodel

### 8. Recommended Proof Structure

```lean
theorem representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ := by
  -- By contrapositive: ¬ContextDerivable [] φ → ¬semantic_consequence [] φ
  apply Function.mtr
  intro h_not_deriv

  -- Step 1: Show [φ.neg] is consistent
  have h_neg_cons : Consistent [φ.neg] := by
    intro ⟨d_bot⟩
    apply h_not_deriv
    -- From [φ.neg] ⊢ ⊥, by deduction theorem, [] ⊢ φ.neg → ⊥ = [] ⊢ ¬¬φ
    have d_neg_neg := deduction_theorem [] φ.neg Formula.bot d_bot
    -- By DNE, [] ⊢ φ
    have d_phi := DerivationTree.modus_ponens [] φ.neg.neg φ (double_negation φ |> ...) d_neg_neg
    exact ⟨d_phi⟩

  -- Step 2: By representation theorem, [φ.neg] is satisfiable in canonical model
  obtain ⟨w, h_sat⟩ := representation_theorem h_neg_cons

  -- Step 3: ¬φ is true at w
  have h_neg_true : φ.neg ∈ w.carrier := h_sat φ.neg (List.mem_singleton_self _)

  -- Step 4: Need to produce a countermodel for semantic consequence
  -- This requires embedding the canonical model into the semantic framework
  -- ...
  sorry
```

### 9. Alternative: Using FMP Bridge

The FMP module (`FMP.lean`) might provide the bridge between canonical models and semantic validity. The Finite Model Property states that if a formula is satisfiable, it's satisfiable in a finite model. This could help:

1. Canonical model produces an MCS where `¬φ` is true
2. FMP provides a finite semantic model from the canonical model
3. This finite model witnesses `¬semantic_consequence [] φ`

### 10. Existing Related Work in Old Metalogic

The old `Metalogic/Representation/ContextProvability.lean` has a proven version:

```lean
theorem representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ := by
  intro h_entails
  have h_valid : valid φ := by
    intro D _ _ _ F M τ t
    exact h_entails D F M τ t (fun ψ h_in => absurd h_in List.not_mem_nil)
  exact ⟨weak_completeness φ h_valid⟩
```

But this relies on `weak_completeness` which is an axiom in the old system. In Metalogic_v2, we need to prove this from first principles.

## Recommendations

1. **Primary Approach**: Prove via contrapositive using existing infrastructure
   - Use `Function.mtr` from Mathlib for contrapositive transformation
   - Leverage `deduction_theorem` and `double_negation` for Step 1
   - Use `representation_theorem` for Step 2

2. **Bridge Needed**: The semantic embedding is the missing piece
   - Either construct a `TaskFrame Int` from `CanonicalFrame` and prove equivalence
   - Or prove a lemma: `canonicalTruthAt w φ.neg → ∃ model, ¬truth_at model φ`

3. **Dependencies to Verify**:
   - Ensure `double_negation` is properly weakened to contexts
   - Ensure modus ponens combines DNE with the derived `¬¬φ` correctly

4. **Fallback**: If semantic embedding proves complex, consider adding a `canonicalModelEmbed` lemma as an intermediate step that can be proven later

## Proof Complexity Assessment

- **Difficulty**: Medium-High
- **Estimated Effort**: 2-3 hours for the proof, possibly more for semantic embedding
- **Key Challenge**: Bridging canonical model truth to polymorphic semantic validity

## References

- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Target file
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - representation_theorem
- `Theories/Bimodal/Metalogic_v2/Core/DeductionTheorem.lean` - deduction_theorem
- `Theories/Bimodal/Theorems/Propositional.lean` - double_negation
- `Theories/Bimodal/Semantics/Validity.lean` - semantic_consequence definition
- Mathlib.Logic.Basic - contrapositive theorems (not_imp_not, Function.mtr)

## Next Steps

1. Run `/plan 560` to create implementation plan
2. Focus on Step 1 (consistency of negation) first as it uses existing infrastructure
3. Then address the semantic embedding challenge
