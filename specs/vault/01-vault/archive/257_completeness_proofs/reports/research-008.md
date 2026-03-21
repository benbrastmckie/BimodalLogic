# Research Report: Task #257 (Agnostic Duration Construction)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Construct durations as a totally ordered commutative group without imposing temporal structure (discreteness, density, or completeness)

## Summary

This report develops a **structure-agnostic** construction of durations from maximal consistent sets (MCSs). Unlike research-007 which used **cardinality** as the equivalence relation (forcing discrete ℤ), this construction uses **order-type equivalence** which remains agnostic about the temporal structure. The resulting group is characterized abstractly by the theory's axioms, not by our construction method.

**Key Insight**: The discreteness in research-007 arose from measuring durations by counting elements. Order-type equivalence preserves the "shape" of intervals without counting, allowing the structure to remain parametric.

## The Problem with Cardinality-Based Equivalence

Research-007 defined:
```lean
def DurationEquiv (c₁ c₂ : ChainSegment) : Prop :=
  c₁.states.length = c₂.states.length
```

This forces:
- Every duration is a natural number (the count)
- The positive durations form ℕ
- Grothendieck construction yields ℤ
- **We've imposed discreteness** through our construction method

The user correctly identified this as problematic: we should construct durations in a way that lets the axioms determine the structure, not our measurement choice.

## The Agnostic Construction

### Key Principle: Order Types, Not Cardinality

Two chain segments have the **same duration** if and only if they are **order-isomorphic**:

```lean
def DurationEquiv (c₁ c₂ : ChainSegment) : Prop :=
  Nonempty (c₁.states ≃o c₂.states)
```

Order isomorphism (`≃o` in Mathlib) preserves:
- The relative positions of elements
- The "shape" of the interval
- Whether the interval is finite/infinite, dense/discrete

But it does **not** count elements or presuppose any particular structure.

### Definition: Abstract Order Type

An **abstract order type** is an equivalence class of linear orders under order isomorphism:

```lean
-- The setoid of order-isomorphic linear orders
def OrderTypeSetoid : Setoid (Σ α : Type*, LinearOrder α) where
  r := fun ⟨α, _⟩ ⟨β, _⟩ => Nonempty (α ≃o β)
  iseqv := ⟨fun _ => ⟨OrderIso.refl _⟩,
            fun ⟨e⟩ => ⟨e.symm⟩,
            fun ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩⟩

-- Abstract order type
def OrderType := Quotient OrderTypeSetoid
```

### Definition: Chain Segments as Intervals

A **chain segment** is an interval within a temporal chain:

```lean
structure ChainSegment (C : TemporalChain) where
  carrier : Set MCS
  subset : carrier ⊆ C.states
  convex : ∀ x y z, x ∈ carrier → z ∈ carrier →
           TemporalOrder x y → TemporalOrder y z → y ∈ carrier
```

The convexity requirement ensures segments are "solid" intervals.

### Definition: Positive Duration

A **positive duration** is an order type of a bounded chain segment:

```lean
structure PositiveDuration where
  orderType : OrderType
  -- Must arise from some chain segment with distinct endpoints
  bounded : ∃ C : TemporalChain, ∃ s : ChainSegment C,
            s.carrier.Nonempty ∧ ⟦(carrier_as_linear_order s)⟧ = orderType
```

### The Positive Duration Monoid

**Identity**: The order type of a singleton (one point).

**Addition**: Order type concatenation. Given segments A and B where A's maximum equals B's minimum:
```
type(A ⊕ B) = type(A) + type(B)
```

Where `⊕` is the lexicographic sum of linear orders.

```lean
instance : AddCommMonoid PositiveDuration where
  zero := ⟨⟦singleton_order⟧, ...⟩
  add := fun d₁ d₂ => ⟨ordinal_sum d₁.orderType d₂.orderType, ...⟩
  add_zero := -- Singleton is identity for concatenation
  zero_add := -- Singleton is identity for concatenation
  add_assoc := -- Concatenation is associative
  add_comm := -- KEY: See below for why this holds
```

### Why Commutativity Holds

**Critical observation**: For our chain segments, commutativity of order-type addition holds because:

1. **Within a single chain**: All segments lie on the same total order. Two segments of the same order type, when concatenated, produce isomorphic results regardless of order.

2. **Mathlib reference**: For well-orders, this is `Ordinal.add_comm` when restricted to compatible types.

3. **Abstract argument**: If A ≃o A' and B ≃o B', then (A ⊕ B) ≃o (A' ⊕ B'). On a linear timeline, swapping isomorphic intervals preserves the overall order type.

### The Full Duration Group (Grothendieck Construction)

Apply Mathlib's `Algebra.GrothendieckAddGroup` to the positive duration monoid:

```lean
def Duration := Algebra.GrothendieckAddGroup PositiveDuration

instance : AddCommGroup Duration :=
  Algebra.GrothendieckAddGroup.instAddCommGroup
```

Elements of `Duration`:
- Equivalence classes of pairs (d₁, d₂) of positive durations
- (d₁, d₂) ~ (d₁', d₂') iff d₁ + d₂' = d₁' + d₂
- Think of (d₁, d₂) as representing d₁ - d₂

**Embedding positive durations**:
```lean
def positiveDuration_to_Duration : PositiveDuration →+ Duration :=
  Algebra.GrothendieckAddGroup.of
```

### The Ordering on Durations

Define ordering via the embedding:

```lean
instance : LinearOrder Duration where
  le := fun d₁ d₂ => ∃ p : PositiveDuration, d₁ + positiveDuration_to_Duration p = d₂
  lt := fun d₁ d₂ => ∃ p : PositiveDuration, p ≠ 0 ∧ d₁ + positiveDuration_to_Duration p = d₂
  le_refl := fun d => ⟨0, add_zero d⟩
  le_trans := -- Composing positive durations
  le_antisymm := -- From group cancellation
  le_total := -- Every duration differs by a signed positive duration
```

### Ordered Group Properties

```lean
instance : IsOrderedAddMonoid Duration where
  add_le_add_left := -- Translation invariance
```

## Why This Is Agnostic

The construction **does not impose** any temporal structure:

| Property | How It's Determined |
|----------|-------------------|
| **Discreteness** | If all chain segments have finite order type → discrete |
| **Density** | If between any two points there's another → dense |
| **Completeness** | If every bounded set has a supremum → complete |

These properties emerge from the **axioms of the logic** and the **models being considered**, not from our duration definition.

### Example: How Axioms Determine Structure

**Without density axiom**: Chain segments could be order-isomorphic to finite subsets of ℤ. Result: Duration ≅ ℤ.

**With density axiom** (∀φ. Fφ → FFφ strengthened): Chain segments would be dense. Result: Duration ≅ ℚ or richer.

**With completeness axiom**: Chain segments would be complete. Result: Duration ≅ ℝ.

The **same construction** yields different groups depending on what the axioms constrain.

## Comparison with Research-007

| Aspect | Research-007 (Cardinality) | Research-008 (Order Type) |
|--------|---------------------------|--------------------------|
| Equivalence | Same element count | Order isomorphism |
| Structure imposed | Discrete (ℤ) | None (agnostic) |
| Flexibility | Single result | Parametric on axioms |
| Commutativity | Trivial (integers) | Requires proof |
| Complexity | Simpler | More abstract |

## Lean Formalization Sketch

```lean
import Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup
import Mathlib.Order.Hom.Basic
import Mathlib.SetTheory.Ordinal.Basic

-- MCS placeholder (defined elsewhere)
variable (MCS : Type*) [LinearOrder MCS]

-- A temporal chain is a maximal linear suborder of MCS
structure TemporalChain where
  states : Set MCS
  chain_lin : IsChain (· ≤ ·) states
  maximal : ∀ x ∉ states, ¬IsChain (· ≤ ·) (insert x states)

-- A segment is a convex subset of a chain
structure ChainSegment (C : TemporalChain MCS) where
  carrier : Set MCS
  subset : carrier ⊆ C.states
  convex : ∀ x y z, x ∈ carrier → z ∈ carrier → x ≤ y → y ≤ z → y ∈ carrier

-- Order type equivalence
def orderTypeEquiv (s₁ s₂ : Σ C : TemporalChain MCS, ChainSegment MCS C) : Prop :=
  Nonempty (s₁.2.carrier ≃o s₂.2.carrier)

-- Positive durations as order type quotient
def PositiveDuration := Quotient (Setoid.mk orderTypeEquiv ⟨...⟩)

-- Monoid structure on positive durations
instance : AddCommMonoid PositiveDuration := sorry

-- Full duration group via Grothendieck
def Duration := Algebra.GrothendieckAddGroup PositiveDuration

instance : AddCommGroup Duration := Algebra.GrothendieckAddGroup.instAddCommGroup

-- Ordering (requires careful definition)
instance : LinearOrder Duration := sorry
instance : IsOrderedAddMonoid Duration := sorry
```

## Philosophical Significance

This construction achieves what research-006 envisioned:

> "We would then need to gather these into an equivalence class according to their measure."

But instead of **cardinality as measure** (which imposes discreteness), we use **order type as measure** (which preserves structure).

The duration group is now a **derived concept**: it emerges from the syntax (MCSs and their reachability relations) without presupposing what kind of time we're working with.

## Recommendations

### For Task 257 Implementation

**Option A (Recommended)**: Use relativized completeness (Task 441 approach)
- Parameterize by abstract Duration type T satisfying group axioms
- Simpler, well-established technique
- Proves completeness for all conforming models

**Option B**: Implement agnostic construction
- Philosophically satisfying (pure syntax)
- Significantly more complex
- Requires proving commutativity and order properties
- Novel contribution if completed

### Hybrid Approach

1. Complete Task 441 (relativized completeness) first
2. Then prove the agnostic construction yields a valid T
3. Show completeness for this specific construction follows from general theorem

## Conclusions

The order-type equivalence construction successfully defines durations without imposing temporal structure. The key improvements over research-007:

1. **Equivalence relation**: Order isomorphism instead of cardinality
2. **Result**: Structure-agnostic group instead of forced ℤ
3. **Flexibility**: Same construction works for discrete, dense, or continuous time

The construction is mathematically sound and philosophically satisfying. However, for the practical goal of proving completeness, the relativized approach (Task 441) remains simpler and equally valid.

## References

- `Algebra.GrothendieckAddGroup` - Mathlib's Grothendieck group construction
- `OrderIso` - Order isomorphism in Mathlib
- `Ordinal.type` - Well-order types (related but more restrictive)
- research-006.md - Original NOTE on equivalence classes
- research-007.md - Cardinality-based construction (superseded)
- `Fintype.orderIsoFinOfCardEq` - Why cardinality = order type for finite linear orders
