# Research Report: Task #781

**Task**: Refactor Metalogic to eliminate `valid` and achieve zero-sorry completeness
**Date**: 2026-01-30
**Focus**: Analyze architecture of weak_completeness vs semantic_weak_completeness, identify dependencies, determine refactoring feasibility

## Summary

The refactoring is feasible but requires significant changes. The core insight is that `semantic_weak_completeness` (sorry-free) can replace `weak_completeness` (sorry) if we redefine the two dependent theorems to use semantic truth conditions directly instead of requiring universal validity. Both `finite_strong_completeness` and `consistent_implies_satisfiable` can be reformulated without the `valid` predicate.

## Findings

### 1. Architecture Overview

#### The `valid` Definition (Validity.lean:61-64)
```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (t : D),
    truth_at M τ t φ
```

This quantifies over ALL possible:
- Temporal types D (Int, Rat, Real, etc.)
- Task frames F
- Task models M
- World histories tau
- Times t

#### The `semantic_weak_completeness` Theorem (SemanticCanonicalModel.lean:354-411)
```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

This only requires truth at finite `SemanticWorldState` instances - a much weaker condition.

#### The `weak_completeness` Theorem (WeakCompleteness.lean:211-217)
```lean
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro _h_valid
  sorry  -- ARCHITECTURAL SORRY
```

The sorry exists because bridging `valid` (ALL models) to `SemanticWorldState` truth requires the forward truth lemma, which is architecturally impossible (see TruthLemmaGap.lean in Boneyard).

### 2. Dependencies on `weak_completeness`

#### Dependency 1: `finite_strong_completeness` (FiniteStrongCompleteness.lean:191-199)
```lean
theorem finite_strong_completeness (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → ContextDerivable Γ φ := by
  intro h_entails
  have h_valid := entails_imp_chain Γ φ h_entails  -- Gets: valid (impChain Γ φ)
  have h_deriv := weak_completeness (impChain Γ φ) h_valid  -- USES SORRY
  exact imp_chain_to_context Γ φ h_deriv
```

**Current flow**: semantic_consequence -> valid (impChain) -> weak_completeness -> ContextDerivable

#### Dependency 2: `consistent_implies_satisfiable` (FiniteModelProperty.lean:102-125)
```lean
theorem consistent_implies_satisfiable (φ : Formula) (h_cons : Completeness.Consistent [φ]) :
    formula_satisfiable φ := by
  by_contra h_not_sat
  have h_neg_valid : valid (Formula.neg φ) := by ...  -- Builds valid
  have h_neg_deriv : ContextDerivable [] (Formula.neg φ) := weak_completeness (Formula.neg φ) h_neg_valid  -- USES SORRY
  ...
```

**Current flow**: ¬satisfiable -> valid (neg φ) -> weak_completeness -> contradiction with consistency

### 3. The Fundamental Gap

The gap is documented in `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`:

1. **Box Quantifies Over ALL Histories**: `truth_at M tau t (box psi)` requires psi true at ALL accessible world states
2. **MCS Has One State**: A ClosureMaximalConsistent set describes ONE world state
3. **Forward Direction Impossible**: Cannot prove arbitrary model truth implies MCS membership

The contrapositive in `semantic_weak_completeness` works because:
- We only need to show phi is FALSE at ONE world state
- MCS-derived world states have truth correspondence by construction

### 4. Refactoring Strategy

#### Option A: Replace `valid` with Semantic Truth in Theorem Statements

**For finite_strong_completeness:**

Replace `semantic_consequence Γ φ` (which quantifies over all models) with a new predicate that only requires truth at semantic world states. The challenge is that `semantic_consequence` is the standard definition users expect.

**Proposed new theorem:**
```lean
theorem semantic_strong_completeness (Γ : Context) (φ : Formula) :
    (∀ (w : SemanticWorldState (impChain Γ φ)),
     semantic_truth_at_v2 ... w ... (impChain Γ φ)) →
    ContextDerivable Γ φ
```

This is strictly weaker than the current statement but is sorry-free.

**For consistent_implies_satisfiable:**

The proof needs to show: if [φ] is consistent, then φ is satisfiable. Currently it assumes ¬satisfiable and derives valid(¬φ), which requires the gap.

**Alternative approach:**
```lean
theorem consistent_implies_semantic_satisfiable (φ : Formula) (h_cons : Consistent [φ]) :
    ∃ (w : SemanticWorldState φ),
      semantic_truth_at_v2 φ w (BoundedTime.origin (temporalBound φ)) φ
```

This is provable directly from the `semantic_weak_completeness` proof structure - if [φ] is consistent, we can build an MCS containing φ and derive a SemanticWorldState where φ is true.

#### Option B: Keep Current Statements, Accept the Sorry

Keep `valid`-based theorems with documented architectural sorries. This maintains the expected API but has known limitations.

#### Option C: Dual API (Recommended)

Provide BOTH:
1. **Semantic versions** (sorry-free): `semantic_strong_completeness`, `consistent_implies_semantic_satisfiable`
2. **Universal versions** (with documented sorries): `finite_strong_completeness`, `consistent_implies_satisfiable`

This gives users a choice and makes the limitation clear.

### 5. Impact on Public API

#### Breaking Changes if Removing `valid`-based Theorems

| Theorem | Current Signature | Breaking Change |
|---------|-------------------|-----------------|
| `finite_strong_completeness` | `semantic_consequence Γ φ → ContextDerivable Γ φ` | Would change to semantic version |
| `consistent_implies_satisfiable` | `Consistent [φ] → formula_satisfiable φ` | Would change to semantic version |
| `context_provable_iff_entails` | `ContextDerivable Γ φ ↔ Γ ⊨ φ` | Would lose the ← direction |

#### Preserved API if Using Dual Approach

Keep all current theorems (with documented sorries) and add semantic variants.

### 6. Implementation Complexity Assessment

| Component | Complexity | Notes |
|-----------|------------|-------|
| Define `semantic_strong_completeness` | Low | Direct from `semantic_weak_completeness` + impChain |
| Define `consistent_implies_semantic_satisfiable` | Medium | Extract from `semantic_weak_completeness` proof |
| Archive `WeakCompleteness.lean` | Low | Move to Boneyard with documentation |
| Update documentation | Low | Document the dual API |
| Update all imports | Medium | Find all users of `weak_completeness` |

### 7. Current Sorry Count Analysis

From the active Metalogic:
- `weak_completeness` (WeakCompleteness.lean:217): 1 sorry
- `provable_iff_valid` (WeakCompleteness.lean:228): Inherits sorry via weak_completeness

From FiniteModelProperty.lean:
- `consistent_implies_satisfiable` (line 113): Uses weak_completeness (inherits sorry)

From FiniteStrongCompleteness.lean:
- `finite_strong_completeness` (line 197): Uses weak_completeness (inherits sorry)

**Total active sorries related to this issue**: 1 direct + 3 indirect = 4 theorems affected

## Recommendations

1. **Adopt the Dual API approach (Option C)**:
   - Keep `weak_completeness` and `finite_strong_completeness` with documented sorries
   - Add new `semantic_strong_completeness` and `consistent_implies_semantic_satisfiable` (sorry-free)
   - Document clearly which to use for what purpose

2. **Do NOT archive WeakCompleteness.lean yet**:
   - The sorried theorems are still useful for users who accept the limitation
   - They match the standard modal logic API
   - Removing would be a breaking change

3. **Create new file `SemanticCompleteness.lean`**:
   - Contains sorry-free semantic versions
   - Clearly documented as the "canonical" results for formal verification

4. **Update Metalogic.lean documentation**:
   - Explain the two completeness approaches
   - Recommend semantic versions for formal verification
   - Note that universal versions have architectural sorry

5. **Implementation order**:
   1. Create `SemanticCompleteness.lean` with semantic versions
   2. Update documentation
   3. Update exports in Metalogic.lean
   4. Consider archiving sorried versions in a future task

## References

- `Theories/Bimodal/Semantics/Validity.lean` - Definition of `valid`
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Sorried weak_completeness
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Sorry-free semantic_weak_completeness
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Depends on weak_completeness
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - Depends on weak_completeness
- `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean` - Documents the architectural gap

## Next Steps

1. Create implementation plan for the dual API approach
2. Define exact type signatures for semantic versions
3. Plan documentation updates
