# Research Report: Task #446

**Task**: Agnostic Duration Construction
**Date**: 2026-01-12
**Focus**: Lean 4 and Mathlib constructs for implementing order-type based duration construction

## Summary

This report provides detailed findings on the Mathlib constructs needed to implement the agnostic duration construction described in research-008.md. The construction builds Duration as an ordered additive commutative group from temporal chains of maximal consistent sets (MCSs), using order-type equivalence rather than cardinality to avoid imposing discreteness.

Key findings:
1. Mathlib provides `Quotient` and `Setoid` for defining order-type equivalence classes
2. `Algebra.GrothendieckAddGroup` handles the monoid-to-group completion
3. `OrderIso` (`≃o`) is the right type for order isomorphism
4. `LinearOrderedAddCommGroup` is the target typeclass for Duration
5. The current Completeness.lean has set-based MCS infrastructure ready for extension

## Context and Scope

### Prior Research (research-008.md)

Research-008.md established the mathematical approach:
- Use **order-type equivalence** (order isomorphism) instead of cardinality
- Define `PositiveDuration` as quotient of chain segments under order isomorphism
- Apply Grothendieck construction to get full Duration group
- Define ordering via positive duration embedding

### Current Completeness Infrastructure

The existing `Completeness.lean` provides:

**Already Implemented (proven)**:
- `SetConsistent S : Prop` - Consistency for sets of formulas
- `SetMaximalConsistent S : Prop` - Maximal consistency for sets
- `set_lindenbaum` - Zorn's lemma extension theorem (proven)
- `CanonicalWorldState : Type` - Set-based MCS subtype
- Various MCS properties: closure, negation complete, conjunction/disjunction iff

**Axioms (placeholder stubs)**:
- `canonical_task_rel` - Task relation between MCSs (axiom)
- `canonical_frame` - TaskFrame construction (axiom)
- `canonical_model` - TaskModel construction (axiom)
- `truth_lemma` - Truth correspondence (axiom)
- `weak_completeness`, `strong_completeness` - Main theorems (axioms)

**Key Types for Duration Construction**:
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
def CanonicalTime : Type := Int  -- Currently uses integers
```

The task is to construct Duration abstractly from MCS chains rather than assuming Int.

## Findings by Topic

### 1. Quotient and Setoid Machinery

**Core Types** (from `Init.Core`):
```lean
-- Setoid defines an equivalence relation on a type
structure Setoid (α : Sort u) where
  r : α → α → Prop
  iseqv : Equivalence r

-- Quotient creates type of equivalence classes
def Quotient {α : Sort u} (s : Setoid α) : Sort u

-- Key operations
Quotient.mk : {α : Sort u} → (s : Setoid α) → (a : α) → Quotient s
Quotient.lift : (f : α → β) → (h : ∀ a b, s.r a b → f a = f b) → Quotient s → β
Quotient.ind : (∀ a, motive ⟦a⟧) → ∀ q, motive q
Quotient.exact : ⟦a⟧ = ⟦b⟧ → a ≈ b
```

**Application to Duration**:
```lean
-- Define setoid for order-type equivalence
def orderTypeSetoid (MCS : Type) [LinearOrder MCS] : Setoid (Σ C : TemporalChain MCS, ChainSegment C) where
  r := fun ⟨_, s₁⟩ ⟨_, s₂⟩ => Nonempty (s₁.carrier ≃o s₂.carrier)
  iseqv := ⟨
    fun _ => ⟨OrderIso.refl _⟩,
    fun ⟨e⟩ => ⟨e.symm⟩,
    fun ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩
  ⟩

-- Positive durations as order-type quotient
def PositiveDuration (MCS : Type) [LinearOrder MCS] :=
  Quotient (orderTypeSetoid MCS)
```

### 2. Order Isomorphism

**Key Type** (from `Mathlib.Order.Hom.Basic`):
```lean
-- Order isomorphism: equivalence preserving ≤
abbrev OrderIso (α β : Type*) [LE α] [LE β] := @RelIso α β (· ≤ ·) (· ≤ ·)

-- Notation
infixl:25 " ≃o " => OrderIso

-- Core operations
OrderIso.refl (α) : α ≃o α
OrderIso.symm (e : α ≃o β) : β ≃o α
OrderIso.trans (e₁ : α ≃o β) (e₂ : β ≃o γ) : α ≃o γ
```

**Ordinal Reference** (from `Mathlib.SetTheory.Ordinal.Basic`):
```lean
-- Ordinals are defined similarly via well-order isomorphism
instance Ordinal.isEquivalent : Setoid WellOrder where
  r := fun ⟨_, r, _⟩ ⟨_, s, _⟩ => Nonempty (r ≃r s)
  iseqv := ⟨fun _ => ⟨RelIso.refl _⟩, fun ⟨e⟩ => ⟨e.symm⟩, fun ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩⟩

def Ordinal : Type (u + 1) := Quotient Ordinal.isEquivalent
```

This is the pattern to follow: durations are to linear orders as ordinals are to well orders.

### 3. Grothendieck Group Construction

**Key Definitions** (from `Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup`):
```lean
-- Grothendieck group of additive commutative monoid
abbrev Algebra.GrothendieckAddGroup (M : Type*) [AddCommMonoid M] : Type* :=
  Localization (⊤ : AddSubmonoid M)

-- Automatic group instance
instance : AddCommGroup (Algebra.GrothendieckAddGroup M) := ...

-- Embedding from monoid to group
abbrev Algebra.GrothendieckAddGroup.of : M →+ GrothendieckAddGroup M

-- Injective when monoid is cancellative
lemma of_injective [IsCancelAdd M] : Injective (of (M := M))
```

**Application to Duration**:
```lean
-- Assuming PositiveDuration has AddCommMonoid instance
def Duration := Algebra.GrothendieckAddGroup PositiveDuration

instance : AddCommGroup Duration := Algebra.GrothendieckAddGroup.instAddCommGroup
```

### 4. Ordered Group Typeclasses

**Target Typeclasses** (from `Mathlib.Algebra.Order.Group.Defs`):
```lean
-- Partially ordered additive group
class OrderedAddCommGroup (α : Type*) extends AddCommGroup α, PartialOrder α where
  add_le_add_left : ∀ a b, a ≤ b → ∀ c, c + a ≤ c + b

-- Linearly ordered additive group
class LinearOrderedAddCommGroup (α : Type*) extends OrderedAddCommGroup α, LinearOrder α
```

**Relevant Theorems** (from `Mathlib.GroupTheory.ArchimedeanDensely`):
```lean
-- Key dichotomy theorem
lemma LinearOrderedAddCommGroup.discrete_or_denselyOrdered (α : Type*)
    [LinearOrderedAddCommGroup α] :
    (∃ a : α, 0 < a ∧ ∀ b, 0 < b → a ≤ b) ∨ DenselyOrdered α

-- Equivalence with cyclicity
lemma LinearOrderedAddCommGroup.isAddCyclic_iff_not_denselyOrdered :
    IsAddCyclic α ↔ ¬DenselyOrdered α
```

This dichotomy is exactly what research-008.md aims to preserve: the construction doesn't force either discrete or dense structure.

### 5. Defining the Monoid Structure on PositiveDuration

The key challenge is defining `AddCommMonoid` on `PositiveDuration`:

**Zero Element**: Order type of singleton (one point)
```lean
def zeroDuration : PositiveDuration :=
  ⟦(singleton_chain, singleton_segment)⟧
```

**Addition**: Order type concatenation (lexicographic sum)
```lean
-- Need to show this is well-defined on equivalence classes
def addDuration (d₁ d₂ : PositiveDuration) : PositiveDuration :=
  Quotient.lift₂ (fun s₁ s₂ => ⟦concat s₁ s₂⟧)
    (fun _ _ _ _ h₁ h₂ => by
      -- Prove: if s₁ ≃o s₁' and s₂ ≃o s₂' then concat s₁ s₂ ≃o concat s₁' s₂'
      sorry)
    d₁ d₂
```

**Commutativity Requirement**: This is the subtle part. On a single chain (total order), order-type addition is commutative because swapping isomorphic segments preserves the overall order type. This needs careful proof.

### 6. Linear Order on Duration

Defining order on Duration (Grothendieck group):

```lean
instance : LinearOrder Duration where
  le := fun d₁ d₂ => ∃ p : PositiveDuration, d₁ + of p = d₂
  lt := fun d₁ d₂ => ∃ p : PositiveDuration, p ≠ 0 ∧ d₁ + of p = d₂
  le_refl := fun d => ⟨0, add_zero d⟩
  le_trans := -- By composing positive differences
  le_antisymm := -- By group cancellation
  le_total := -- Every difference is either positive or negative
```

The challenge is showing `le_total`: this requires that the embedding of PositiveDuration into Duration is "co-final" in some sense.

## Code Patterns

### Pattern 1: Defining Order-Type Setoid

```lean
import Mathlib.Order.Hom.Basic

variable (MCS : Type*) [LinearOrder MCS]

-- Temporal chain (maximal linear suborder of MCS reachability)
structure TemporalChain where
  states : Set MCS
  chain_lin : IsChain (· ≤ ·) states
  maximal : ∀ x ∉ states, ¬IsChain (· ≤ ·) (insert x states)

-- Chain segment (convex subset)
structure ChainSegment (C : TemporalChain MCS) where
  carrier : Set MCS
  subset : carrier ⊆ C.states
  convex : ∀ x y z, x ∈ carrier → z ∈ carrier → x ≤ y → y ≤ z → y ∈ carrier

-- Order-type equivalence
def orderTypeEquiv (s₁ s₂ : Σ C : TemporalChain MCS, ChainSegment MCS C) : Prop :=
  Nonempty (s₁.2.carrier ≃o s₂.2.carrier)

instance orderTypeSetoid : Setoid (Σ C : TemporalChain MCS, ChainSegment MCS C) where
  r := orderTypeEquiv MCS
  iseqv := ⟨
    fun _ => ⟨OrderIso.refl _⟩,
    fun ⟨e⟩ => ⟨e.symm⟩,
    fun ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩
  ⟩
```

### Pattern 2: PositiveDuration as Quotient

```lean
-- Positive durations
def PositiveDuration := Quotient (orderTypeSetoid MCS)

-- Zero is singleton order type
noncomputable def PositiveDuration.zero : PositiveDuration MCS :=
  ⟦⟨some_chain, singleton_segment⟩⟧  -- Need to construct witness

-- Addition via concatenation (requires well-definedness proof)
noncomputable def PositiveDuration.add : PositiveDuration MCS → PositiveDuration MCS → PositiveDuration MCS :=
  Quotient.lift₂ (fun s₁ s₂ => ⟦concat_segments s₁ s₂⟧)
    (concat_respects_equiv MCS)

-- Prove this forms AddCommMonoid
instance : AddCommMonoid (PositiveDuration MCS) where
  zero := PositiveDuration.zero MCS
  add := PositiveDuration.add MCS
  add_zero := sorry  -- Singleton is right identity
  zero_add := sorry  -- Singleton is left identity
  add_assoc := sorry -- Concatenation is associative
  add_comm := sorry  -- KEY: Order-type sum is commutative (needs proof)
```

### Pattern 3: Duration via Grothendieck

```lean
import Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup

-- Full duration group
def Duration := Algebra.GrothendieckAddGroup (PositiveDuration MCS)

instance : AddCommGroup (Duration MCS) := Algebra.GrothendieckAddGroup.instAddCommGroup

-- Embedding
def positiveToDuration : PositiveDuration MCS →+ Duration MCS :=
  Algebra.GrothendieckAddGroup.of
```

### Pattern 4: Linear Order on Duration

```lean
-- Ordering: d₁ ≤ d₂ iff d₂ - d₁ is a positive duration (or zero)
instance : LE (Duration MCS) where
  le d₁ d₂ := ∃ p : PositiveDuration MCS, d₁ + positiveToDuration MCS p = d₂

-- Need to prove LinearOrder and compatibility with group structure
instance : LinearOrderedAddCommGroup (Duration MCS) where
  le_refl := fun d => ⟨0, by simp⟩
  le_trans := sorry
  le_antisymm := sorry
  le_total := sorry  -- Most challenging: totality
  add_le_add_left := sorry  -- Translation invariance
```

## Risks and Mitigations

### Risk 1: Commutativity of Order-Type Addition

**Problem**: Proving `d₁ + d₂ = d₂ + d₁` for order types is non-trivial.

**Mitigation**:
- For finite linear orders, this follows from `Fintype.orderIsoFinOfCardEq`
- For general linear orders on chains, use the fact that segments lie on a common total order
- Reference ordinal arithmetic patterns but note linear orders need not be well-founded

### Risk 2: Totality of Order on Duration

**Problem**: Showing `le_total` (every two durations are comparable) requires that for any d₁, d₂, either d₂ - d₁ or d₁ - d₂ is a positive duration.

**Mitigation**:
- This follows from the construction: every element of Duration is `p₁ - p₂` for positive p₁, p₂
- The difference of any two such elements can be written with a positive or negative difference

### Risk 3: Connecting to Canonical Model

**Problem**: The Duration type must integrate with `canonical_task_rel` and the canonical frame.

**Mitigation**:
- Define Duration as a parameter/universe-polymorphic type
- Prove it satisfies required typeclass constraints
- Instantiate `canonical_frame` with constructed Duration instead of Int

### Risk 4: Proof Complexity

**Problem**: Many proofs are marked `sorry` in the sketch - actual implementation may be complex.

**Mitigation**:
- Start with simpler cardinality-based approach (research-007) as fallback
- Use `decide`/`omega` automation where applicable
- Consider using `Ordinal` directly for well-founded chain segments

## Recommendations

### Implementation Approach

**Phase 1: Foundation (Task 446 Core)**
1. Define `TemporalChain` and `ChainSegment` structures
2. Define `orderTypeSetoid` with equivalence proofs
3. Define `PositiveDuration` quotient

**Phase 2: Monoid Structure**
4. Define zero element (singleton order type)
5. Define segment concatenation operation
6. Prove concatenation respects equivalence
7. Prove `AddCommMonoid` axioms (hardest: commutativity)

**Phase 3: Group Completion**
8. Apply `Algebra.GrothendieckAddGroup`
9. Define ordering on Duration
10. Prove `LinearOrderedAddCommGroup` instance

**Phase 4: Integration**
11. Replace `CanonicalTime := Int` with constructed Duration
12. Update `canonical_task_rel` to use Duration
13. Verify TaskFrame constraints satisfied

### Alternative: Relativized Approach (Simpler)

As suggested in research-008.md, an alternative is:
1. Parameterize completeness by abstract `Duration` type
2. Require `[LinearOrderedAddCommGroup Duration]`
3. Prove completeness for any conforming Duration
4. Later prove the agnostic construction yields valid Duration

This is simpler and may be more practical for initial completeness proof.

## Dependencies

**Required Mathlib Imports**:
```lean
import Mathlib.Order.Hom.Basic              -- OrderIso
import Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup  -- Grothendieck
import Mathlib.Algebra.Order.Group.Defs    -- LinearOrderedAddCommGroup
import Mathlib.Data.Quot                   -- Extended quotient utilities
```

**Task Dependencies**:
- Builds on existing `Completeness.lean` infrastructure
- Should integrate with Task 447 (Canonical Frame Construction)
- Duration used by Task 450 (Canonical History Construction)

## Conclusions

The agnostic duration construction is feasible in Lean 4 using Mathlib's quotient and Grothendieck group machinery. Key findings:

1. **Quotient approach works**: `Setoid` + `Quotient` handles order-type equivalence cleanly
2. **Grothendieck available**: `Algebra.GrothendieckAddGroup` provides group completion
3. **Target typeclass exists**: `LinearOrderedAddCommGroup` is the right abstraction
4. **Integration possible**: Current MCS infrastructure can be extended with Duration

The main implementation challenges are:
- Proving commutativity of order-type addition
- Proving totality of the order on Duration
- Integrating with canonical model construction

For practical completeness proof purposes, the relativized approach (parameterizing by abstract Duration) is recommended as the primary path, with the agnostic construction as a follow-up refinement.

## References

- `Mathlib.Order.Hom.Basic` - OrderIso and order homomorphisms
- `Mathlib.SetTheory.Ordinal.Basic` - Ordinal construction pattern
- `Mathlib.GroupTheory.MonoidLocalization.GrothendieckGroup` - Grothendieck construction
- `Mathlib.Algebra.Order.Group.Defs` - Ordered group typeclasses
- `research-008.md` - Mathematical specification for agnostic construction
- `Theories/Bimodal/Metalogic/Completeness.lean` - Current infrastructure

## Next Steps

Run `/plan 446` to create a phased implementation plan based on these findings.
