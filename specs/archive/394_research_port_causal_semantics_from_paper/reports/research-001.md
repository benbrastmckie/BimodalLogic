# Research Report: Task #394

**Task**: Research and port causal semantics from paper
**Date**: 2026-01-12
**Focus**: Causal operator semantics from "Counterfactual Worlds" (Brast-McKie 2025)

## Summary

The paper provides a hyperintensional causal semantics that differs fundamentally from the current Lewis-style counterfactual analysis in Truth.lean. The causal operator is primitive, defined in terms of expected evolutions through state space, and requires three conditions: (1) inclusion in background assumptions, (2) substantial contribution via minimal subevolutions, and (3) difference-making via inverted effect analysis. The Logos implementation has the necessary infrastructure (task relations, world-histories) but needs significant adaptation to support evolutions and the closeness/expectation ordering.

## Findings

### 1. Current Implementation (Truth.lean)

The current causal operator uses a **counterfactual analysis** (Lewis 1973):

```lean
| Formula.causal φ ψ =>
    -- A ○→ B := A ∧ FB ∧ (¬A □→ ¬FB)
    truthAt M τ t ht σ idx φ ∧
    (∃ y, ∃ hy : y ∈ τ.domain, y > t ∧ truthAt M τ y hy σ idx ψ) ∧
    truthAt M τ t ht σ idx (Formula.counterfactual (Formula.neg φ) (Formula.neg (Formula.some_future ψ)))
```

This definition is:
- **Intensional**: Based on possible worlds/histories
- **Derivative**: Defined in terms of the counterfactual conditional
- **Simplified**: Does not capture minimal causation or substantial contribution

### 2. Paper's Semantics (Line 626)

The paper defines `A ○→ B` (circleright) as:

**M, c ⊨ A ○→ B** iff:

**(1) Inclusion**: |A| ⊑ β(x) and |B| ⊑ β(y)
- The cause A is included in background assumptions at time x
- The effect B is included in background assumptions at time y

**(2) Substantial Contribution**: For all s ∈ β(x)⁺ and τ ∈ ⟨s⟩ₓ:
- There exists δ ⊑* τ (expected subevolution)
- Where δ(y) ∈ ⟦B⟧⁺ (effect inexactly verified at y)
- For every γ ⊑* δ: if γ(y) ∈ ⟦B⟧⁺, then γ(x) ∈ ⟦A⟧⁺
- (Minimal subevolutions that verify effect must also verify cause)

**(3) Difference-Making**: For every t ∈ (β(y)/|B|)⁺ and λ ∈ ⟨t⟩ᵧ:
- If λ(x) ∈ ⟦A⟧⁺, then there exists d ⊑ λ(x)
- Where d ∈ ⟦A⟧⁺ and ω(y) ∈ ⟦B⟧⁺ for all ω ∈ ⟨d⟩ₓ
- (Inverted effect with cause implies preventer scenario)

### 3. Key Concepts Requiring Implementation

#### 3.1 Ordered State Space

The paper introduces:
- **Weak closeness relation** ≼ₛ: likelihood of state transitions
- **Task relation**: s → t iff ∃q(t ≺ₛ q)
- **Expectation**: [s] = {t : s ↦ t} (closest states)
- **Accessibility**: (s) = {t : s → t}

Current Frame.lean has `taskRel` but lacks:
- Closeness ordering
- Expectation function

#### 3.2 Evolutions

Paper defines:
- **Discrete evolution**: τ : ℤ → S where τ(n) → τ(n+1)
- **Expected evolution**: τ(n) ↦ τ(n+1) for all n
- **Subevolution**: δ ⊑ τ iff ∀x(δ(x) ⊑ τ(x))
- **Expected subevolution**: δ ⊑* τ := δ ∈ E_S ∧ δ ⊑ τ

Current implementation has `WorldHistory` but:
- No evolution structure over ℤ
- No subevolution relation
- Uses T (linear ordered abelian group) not ℤ

#### 3.3 Context and Background Assumptions

Paper requires evaluation context c = ⟨x, y, β⟩:
- x: time of cause
- y: time of effect (y > x)
- β: ℤ → P_S⁺ (background assumptions at each time)

Current implementation:
- No explicit context structure
- No background assumptions function
- Evaluation at single time, not time pairs

#### 3.4 Logical Operations on Propositions

Paper uses:
- **Inversion**: P/Q = (P - Q) ∧ ¬Q (inverting Q in P)
- **Logical remainder**: P - Q = ⋀{R : R ⊑ P ∧ R ⋢ Q}
- **Inexact verification**: ⟦A⟧⁺ = {t : s ⊑ t for some s ∈ |A|⁺}

Current implementation has:
- `verifies` and `falsifies` relations
- Mereological parthood
- But no explicit inversion or remainder operations

### 4. Comparison: Logos Time vs Paper Time

| Aspect | Paper | Logos |
|--------|-------|-------|
| Time domain | ℤ (integers) | T (LinearOrderedAddCommGroup) |
| Evolutions | τ : ℤ → S | WorldHistory over T |
| Task duration | implicit (successor) | explicit (y - x) |
| Closeness | ≼ₛ primitive | Not present |
| Expectation | [s] derived | Not present |

### 5. Required Frame Extensions

To port the semantics, CoreFrame needs:

```lean
structure ExtendedCoreFrame (T : Type*) [LinearOrderedAddCommGroup T]
    extends CoreFrame T where
  /-- Closeness relation: closeness s t r means t ≼ₛ r -/
  closeness : State → State → State → Prop
  /-- Reflexivity: t ≼ₛ t -/
  closeness_refl : ∀ s t, closeness s t t
  /-- Transitivity -/
  closeness_trans : ∀ s t r q, closeness s t r → closeness s r q → closeness s t q
  /-- Totality -/
  closeness_total : ∀ s t q, closeness s t q ∨ closeness s q t
  /-- Inaccessibility and Stability constraints... -/
```

### 6. Required Evolution Infrastructure

```lean
/-- A discrete evolution over the frame -/
structure Evolution (F : ExtendedCoreFrame T) where
  /-- State at each integer time -/
  states : ℤ → F.State
  /-- Accessibility constraint: each state can transition to next -/
  accessible : ∀ n : ℤ, taskRel (states n) (states (n + 1))

/-- Expected evolution: each successor is a closest state -/
def ExpectedEvolution (F : ExtendedCoreFrame T) (τ : Evolution F) : Prop :=
  ∀ n : ℤ, isClosest F (τ.states n) (τ.states (n + 1))

/-- Subevolution relation -/
def isSubevolution (δ τ : Evolution F) : Prop :=
  ∀ n : ℤ, F.parthood (δ.states n) (τ.states n)
```

### 7. Causal Context Structure

```lean
/-- Causal evaluation context -/
structure CausalContext (F : ExtendedCoreFrame T) where
  /-- Time of cause -/
  causeTime : ℤ
  /-- Time of effect -/
  effectTime : ℤ
  /-- Effect occurs after cause -/
  effect_after_cause : causeTime < effectTime
  /-- Background assumptions function -/
  background : ℤ → BilateralProp F.State
  /-- Background assumptions are verifiable -/
  background_verifiable : ∀ t, (background t).verifiers.Nonempty
```

## Recommendations

### Approach 1: Full Semantics Port (Comprehensive)

Implement complete paper semantics:
1. Extend CoreFrame with closeness ordering
2. Define Evolution and ExpectedEvolution structures
3. Define CausalContext with background assumptions
4. Implement propositional inversion and remainder
5. Port the three-condition semantics

**Pros**: Faithful to paper, enables all example analyses
**Cons**: Significant infrastructure work, may require major refactoring

### Approach 2: Simplified Adaptation (Pragmatic)

Adapt semantics to existing infrastructure:
1. Use existing WorldHistory as evolution proxy
2. Define closeness in terms of task relation
3. Simplify background assumptions to current world-state
4. Port conditions (2) and (3) with adaptations

**Pros**: Faster implementation, reuses existing code
**Cons**: May lose precision, examples may not work

### Approach 3: Stub with Future Extension (Incremental)

1. Mark causal operator as primitive (not derived from counterfactual)
2. Provide axiom stub with documented semantics
3. Create extension points for future implementation
4. Focus on getting type signatures right

**Pros**: Enables progress on other features
**Cons**: Delays full causation support

## References

- Brast-McKie, B. (2025). "Counterfactual Worlds" - sn-article.tex (line 626)
- Lewis, D. (1973). "Counterfactuals"
- Fine, K. (2017). "Truthmaker Semantics"
- Current implementation: Theories/Logos/SubTheories/Explanatory/Truth.lean

## Next Steps

1. **Phase 1**: Define closeness relation extension to CoreFrame
2. **Phase 2**: Implement Evolution and subevolution infrastructure
3. **Phase 3**: Implement CausalContext and background assumptions
4. **Phase 4**: Port three-condition causal semantics
5. **Phase 5**: Verify with paper examples (preemption, overdetermination, trumping)

Estimated implementation effort: 8-12 hours (full port) or 4-6 hours (simplified)
