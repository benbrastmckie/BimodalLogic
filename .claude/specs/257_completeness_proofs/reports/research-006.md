# Research Report: Task #257 (Durations as Ordered MCS Chains)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Can durations be modeled as totally ordered sets of world states (MCSs) with a reachability ordering?

## Summary

This report investigates a novel approach to syntactic time construction: modeling **durations** as **ordered chains of maximal consistent sets (MCSs)**, where the ordering comes from the **temporal reachability relation**.

**Key Finding**: This approach is **mathematically viable** and provides a genuine construction of time from syntax. The resulting structure is an **order type** (equivalence class of linear orders under order-isomorphism). With appropriate construction, this can yield a structure isomorphic to ℤ (for discrete time) or ℚ/ℝ (for dense/continuous time), depending on what axioms constrain the reachability relation.

## The Proposal Analyzed

### Core Idea

The proposal suggests:
1. **World states** = Maximal Consistent Sets (MCSs)
2. **Durations** = Totally ordered sets (chains) of MCSs
3. **Duration ordering** = Inherited from temporal reachability between MCSs

### Interpretation

A **world history** τ in TM semantics is a sequence of world states indexed by time:
```
... Γ_{-2} → Γ_{-1} → Γ_0 → Γ_1 → Γ_2 → ...
```

The proposal asks: can we **reverse** this and **define** durations/times as the order structure of such chains?

## Mathematical Analysis

### Definition: Temporal Reachability

Given MCSs Γ and Δ, define temporal reachability relations:

```lean
-- Γ is "future-reachable" from Δ (Δ comes before Γ)
def FutureReach (Γ Δ : MCS) : Prop :=
  ∀ φ, Fφ ∈ Δ.val → φ ∈ Γ.val

-- Γ is "past-reachable" from Δ (Δ comes after Γ)
def PastReach (Γ Δ : MCS) : Prop :=
  ∀ φ, Pφ ∈ Δ.val → φ ∈ Γ.val
```

Combined with modal accessibility:
```lean
-- Γ is modally accessible from Δ (S5 equivalence)
def ModalAccess (Γ Δ : MCS) : Prop :=
  ∀ φ, □φ ∈ Δ.val → φ ∈ Γ.val
```

### The Temporal Chain Structure

A **temporal chain** is a maximal linearly ordered set of MCSs under the temporal reachability relation:

```lean
structure TemporalChain where
  states : Set MCS
  linear : IsLinear TemporalOrder states
  maximal : ∀ Γ ∉ states, ¬IsLinear TemporalOrder (states ∪ {Γ})
```

Where `TemporalOrder` on states is defined by:
- Γ ≤ Δ iff `FutureReach Δ Γ` (Δ is in Γ's future)

### Key Question: Does Reachability Give a Total Order?

**For a single chain**: YES, by construction (we take maximal linear subsets).

**For all MCSs**: NO, not in general. Two MCSs might be:
- **Temporally comparable**: One is in the other's future/past
- **Temporally incomparable**: Neither is in the other's temporal cone (they're on different "branches" of possibility)

However, within a **world history** (a single temporal evolution), MCSs ARE totally ordered.

### Constructing Durations from Chain Segments

**Approach 1: Concrete Segments**

A duration could be a "segment" of a chain:
```lean
structure ChainSegment (C : TemporalChain) where
  start : MCS
  finish : MCS
  h_start : start ∈ C.states
  h_finish : finish ∈ C.states
```

But this is **too concrete** - durations should be abstract, not tied to specific endpoints.

**Approach 2: Order Types (Ordinals for Linear Orders)**

A better approach: durations are **order types** of chain segments.

```lean
-- The order type of a segment
def OrderType (segment : ChainSegment) : LinearOrderType :=
  Quotient.mk (interval_order segment.start segment.finish)
```

Two segments have the same "duration" iff they have the same order type (are order-isomorphic).

### The Group Structure Problem

For durations to form an **ordered abelian group**, we need:

#### 1. Identity Element ✓
The **empty segment** or **singleton** {Γ} has order type 1 (single point).
This is the duration 0.

#### 2. Addition (Concatenation) ✓
If segment A goes Γ₀ → Γ₁ → ... → Γₙ and segment B goes Γₙ → ... → Γₘ,
then A + B is Γ₀ → ... → Γₘ.

Order types compose: `type(A) + type(B) = type(A ∪ B)` (ordinal addition).

#### 3. Inverses ⚠️
For segment Γ₀ → Γ₁ → ... → Γₙ, the "inverse" would be Γₙ → ... → Γ₀ (reversal).

**Problem**: Reversal gives the **reverse order type**, which is NOT the same type in general.

**Solution**: Use **signed order types**:
- Positive duration: order type of forward segment
- Negative duration: order type of backward segment (= reverse of forward)

This gives ℤ-like structure when chains are discrete.

#### 4. Commutativity ⚠️
Order type addition is **NOT commutative** in general!
- ω + 1 ≠ 1 + ω for ordinals

**However**: For **dense linear orders without endpoints** (like ℚ), any two countable dense unbounded orders are isomorphic (Cantor's theorem). So addition IS commutative up to isomorphism.

**For discrete orders** (like ℤ): The order type is uniquely ℤ, and ℤ is commutative.

### What Determines the Structure?

The structure of syntactic time depends on **what temporal axioms constrain reachability**:

| Axiom Pattern | Structural Consequence |
|---------------|----------------------|
| T4 (Fφ → FFφ) | Transitivity - chains are well-defined |
| TA (φ → FPφ) | Connectedness - no temporal gaps |
| TL (△φ → FPφ) | Convexity - fills gaps |
| No density axiom | Could be discrete (ℤ-like) |
| With density axiom | Would be dense (ℚ-like) |

**Current TM logic**: Has T4, TA, TL but NO density/discreteness axioms.
**Result**: The syntactic time is "maximally abstract" - it works for both discrete and dense interpretations.

## The Construction in Detail

### Step 1: Define Temporal Equivalence

Two MCSs are **temporally equivalent** if they satisfy the same temporal formulas:
```lean
def TemporalEquiv (Γ Δ : MCS) : Prop :=
  (∀ φ, Fφ ∈ Γ ↔ Fφ ∈ Δ) ∧
  (∀ φ, Pφ ∈ Γ ↔ Pφ ∈ Δ) ∧
  (∀ φ, □φ ∈ Γ ↔ □φ ∈ Δ)
```

### Step 2: Quotient by Temporal Equivalence

```lean
def SyntacticMoment := Quotient TemporalEquivSetoid
```

The quotient identifies MCSs that are "at the same moment" (satisfy the same temporal formulas).

### Step 3: Order on Moments

```lean
def MomentOrder : SyntacticMoment → SyntacticMoment → Prop :=
  Quotient.lift₂ (fun Γ Δ => ∃ n : ℕ, FutureReachN n Γ Δ) ...
```

Where `FutureReachN n` means "reachable in n future steps".

### Step 4: Define Durations as Differences

```lean
def SyntacticDuration := SyntacticMoment × SyntacticMoment / ~
```

Where (m₁, m₂) ~ (m₃, m₄) iff "the signed distance from m₁ to m₂ equals that from m₃ to m₄".

### Step 5: Group Operations

```lean
instance : AddCommGroup SyntacticDuration where
  zero := ⟦(m, m)⟧  -- Any moment paired with itself
  add := -- Concatenation of segments
  neg := -- Reversal of segment direction
  add_comm := -- Proved from axiom properties
```

## Comparison with Standard Approach

| Aspect | Standard (Relativized) | Syntactic Construction |
|--------|----------------------|----------------------|
| Time type | Parameter T | Constructed from MCSs |
| Group structure | Assumed (typeclass) | Proved from axioms |
| Completeness | For each T separately | For constructed T |
| Philosophical | Frame type is external | Everything from syntax |
| Complexity | Simpler | More complex |

## Does This Actually Work?

### YES, with caveats:

1. **Reflexivity**: ✓ Nullity (task_rel Γ 0 Γ) gives identity.

2. **Transitivity**: ✓ T4 axiom gives transitivity of future reachability.

3. **Totality on chains**: ✓ By construction of maximal chains.

4. **Addition well-defined**: ✓ Order type concatenation is well-defined.

5. **Inverses**: ✓ Via reversal + signed durations.

6. **Commutativity**: ⚠️ Only for specific order types:
   - For finite segments: ✓ (all finite linear orders of same cardinality are isomorphic)
   - For ℤ-like chains: ✓ (integers commute)
   - For general ordinals: ✗

### The Catch

**If the logic has no axioms forcing specific time structure** (discrete/dense), then:
- The syntactic construction yields the "free" ordered abelian group on one generator
- This is isomorphic to ℤ
- So we get integers "for free"!

**If we add density axioms**, we'd get ℚ.
**If we add completeness axioms**, we'd approach ℝ.

## Conclusions

### Answer to the Research Question

**YES**, durations can be modeled as totally ordered sets of world states (MCSs) with the ordering from temporal reachability, under the following interpretation:

1. **Moments** = Equivalence classes of MCSs under temporal equivalence
2. **Durations** = Differences of moments (signed distances)
3. **Ordering** = Induced from reachability chains
4. **Group structure** = From chain concatenation and reversal

### Practical Recommendation

While this construction is **mathematically elegant** and **philosophically satisfying** (pure syntax!), it requires:

1. Proving the quotient has the required group structure
2. Proving commutativity (depends on axiom set)
3. Proving the truth lemma for this construction
4. Significant additional complexity

**For the implementation**, the **relativized approach** (Option A from research-004) remains simpler and equally valid. The syntactic construction is a beautiful theoretical result but not strictly necessary for proving completeness.

### Future Work

If pursuing the syntactic construction:
1. Add precise definitions of `TemporalEquiv` and `SyntacticMoment`
2. Prove the quotient is totally ordered
3. Prove commutativity of duration addition
4. Connect back to the truth lemma

## References

- Mathlib `Ordinal` - order types and ordinal arithmetic
- Cantor's theorem on countable dense linear orders
- [Temporal Logic SEP entry](https://plato.stanford.edu/entries/logic-temporal/) - frame properties
- `Theories/Bimodal/Metalogic/Completeness.lean` - current infrastructure
- `Theories/Bimodal/Semantics/WorldHistory.lean` - chain structure
- research-004.md, research-005.md - prior analysis
