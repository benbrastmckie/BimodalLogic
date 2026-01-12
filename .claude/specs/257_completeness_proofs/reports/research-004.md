# Research Report: Task #257 (Canonical Time Construction)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: How to construct times in the canonical model while remaining agnostic about discreteness, density, and continuity

## Summary

This report addresses a fundamental philosophical question about canonical model construction: should times be constructed from syntax, and if so, how can this be done while remaining agnostic about the structure of time (discrete, dense, continuous)?

**Key Finding**: The correct approach is **relativized completeness** - proving completeness with respect to **all** frames over all time types simultaneously, rather than constructing a single canonical time. This matches the polymorphic validity definition already in `Validity.lean`.

## The Problem Analyzed

### Current Situation

In `research-003.md`, I suggested using `Int` as `CanonicalTime`. This appears to:
1. Assume discrete time
2. Not construct time from syntax
3. Potentially limit which models the canonical model captures

### The User's Concern

The user correctly identifies that:
1. Canonical model construction should build everything from syntax
2. Using `Int` commits to discrete time
3. A truly agnostic approach should support all theories of time (discrete, dense, continuous)

### The Deeper Issue

The challenge is that our validity definition already quantifies over ALL time types:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (F : TaskFrame T) (M : TaskModel F) ...
```

This means:
- A valid formula must be true in ALL frames over Int (discrete)
- AND true in ALL frames over Rat (dense)
- AND true in ALL frames over Real (continuous)
- AND true in ALL frames over any other ordered abelian group

## Three Approaches to Canonical Model Completeness

### Approach 1: Fixed Canonical Time (My Original Suggestion - Problematic)

**Definition**: Use `Int` as `CanonicalTime`.

**Problem**: This only proves completeness with respect to integer-time frames:
```
⊢ φ → ∀ (F : TaskFrame Int) ..., truth_at ...
```

But validity requires truth over ALL time types, so this is **insufficient**.

### Approach 2: Relativized Completeness (Recommended)

**Key Insight**: Prove completeness **relative to each time type T** separately.

**Statement**:
```lean
theorem strong_completeness_rel (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (Γ : Context) (φ : Formula) :
    (∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
      (∀ ψ ∈ Γ, truth_at M τ t ht ψ) → truth_at M τ t ht φ) →
    DerivationTree Γ φ
```

**Proof Strategy**:
1. Fix an arbitrary `T : Type*` with required instances
2. Construct canonical model `M_can(T)` using maximal consistent sets as worlds
3. Use `T` itself as the time type (not constructed from syntax)
4. Prove truth lemma for this specific `T`
5. Derive contradiction from assuming `¬(Γ ⊢ φ)`

**Why This Works**:
- The canonical model for each `T` validates the same formulas (those derivable from axioms)
- Since the axiom system is sound for ALL time types (proven in Soundness.lean)
- And the axiom system doesn't include any axioms specific to discrete/dense/continuous time
- The same formulas are provable regardless of `T`

**This approach is standard in temporal logic literature** - see [Goldblatt's "Logics of Time and Computation"](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation).

### Approach 3: Syntactic Time Construction (Theoretically Interesting but Complex)

**Idea**: Construct time from equivalence classes of formulas.

**Definition**:
```lean
-- Syntactic time points as equivalence classes
def SyntacticTime := Quotient (temporal_equivalence_setoid)

-- Where temporal equivalence relates formulas that "denote the same time"
def temporal_equiv (φ ψ : Formula) : Prop :=
  ∀ t, (truth_at_time t φ ↔ truth_at_time t ψ)
```

**Challenges**:
1. How to define an ordered group structure on `SyntacticTime`?
2. The equivalence relation depends on semantic notions (truth-at-time)
3. Without axioms about time structure, the quotient might be trivial

**When This Works**:
- In classical temporal logics with specific time axioms (e.g., discreteness)
- The axioms force the syntactic time to have the corresponding structure

**Why It Doesn't Apply Here**:
- TM logic is intentionally agnostic about time structure
- No axioms force discreteness, density, or continuity
- The syntactic quotient would be "maximally abstract"

## The Standard Solution: Frame Class Completeness

The standard approach in modal/temporal logic is **frame class completeness**:

### Definition

A logic L is **complete with respect to frame class C** if:
```
⊨_C φ  →  ⊢_L φ
```
where `⊨_C φ` means φ is valid in all frames in class C.

### For TM Logic

Our frame class C is: **all task frames over all ordered abelian groups**.

Completeness statement:
```
(∀ T [instances], ∀ (F : TaskFrame T), ⊨_F φ)  →  ⊢ φ
```

Equivalently (by contrapositive):
```
¬(⊢ φ)  →  (∃ T [instances], ∃ (F : TaskFrame T), ¬⊨_F φ)
```

### Proof Strategy

1. Assume `¬(⊢ φ)` (φ not provable)
2. The set `{¬φ}` is consistent
3. Extend to maximal consistent Γ via Lindenbaum
4. **For any T with required instances**, construct canonical frame `F_can(T)` with:
   - `WorldState := CanonicalWorldState` (maximal consistent sets)
   - `Time := T` (the given time type, NOT constructed)
   - `task_rel` defined syntactically from Γ membership
5. Construct canonical model `M_can(T)`
6. By truth lemma: `φ ∈ Γ ↔ truth_at M_can τ_can 0 φ`
7. Since `¬φ ∈ Γ`, we have `¬truth_at M_can τ_can 0 φ`
8. Thus φ is falsified in frame `F_can(T)`

**Key Point**: The time `T` is a parameter, not constructed. The **same** maximal consistent sets work for any `T`.

## Why This Is Philosophically Correct

### The Syntax-Semantics Relationship

In canonical model construction, we construct from syntax:
- **Worlds** (maximal consistent sets) ✓
- **Accessibility/Task relation** (from formula membership) ✓
- **Valuation** (from atomic formula membership) ✓

But **times** are part of the **frame signature**, not the model. They are analogous to:
- The carrier type in algebraic structures
- The domain in first-order logic

Just as first-order completeness doesn't require constructing the domain from syntax (Henkin's method uses arbitrary witness constants), temporal completeness doesn't require constructing times from syntax.

### What the Axioms Characterize

The TM axioms characterize **which formulas are valid across all time structures**. They don't characterize any particular time structure.

This is analogous to:
- Modal logic K is complete for ALL Kripke frames
- Modal logic S5 is complete for ALL equivalence-relation frames
- TM logic is complete for ALL task frames over ALL ordered abelian groups

## Implementation Plan

### Revised Approach

```lean
-- Completeness is relative to a given time type T
-- This matches our polymorphic validity definition

theorem weak_completeness (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (φ : Formula) :
    (∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
      truth_at M τ t ht φ) →
    DerivationTree [] φ := by
  intro h_valid_T
  -- Construct canonical model using T as the time type
  -- Time is NOT constructed from syntax - we use the given T
  -- World states ARE constructed from syntax (maximal consistent sets)
  sorry

-- Full polymorphic completeness follows by instantiation
theorem weak_completeness_poly (φ : Formula) : (⊨ φ) → DerivationTree [] φ := by
  intro h_valid
  -- Pick any T (e.g., Int) and apply weak_completeness
  apply weak_completeness Int φ
  intro F M τ t ht
  exact h_valid Int F M τ t ht
```

### Canonical Frame Definition (Type-Parameterized)

```lean
-- Canonical frame is parameterized by time type T
def canonical_frame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    : TaskFrame T where
  WorldState := CanonicalWorldState  -- Constructed from syntax!
  task_rel := canonical_task_rel     -- Defined syntactically!
  nullity := canonical_nullity
  compositionality := canonical_compositionality
```

The key insight: **WorldState** is constructed from syntax (maximal consistent sets), but **T** is a type parameter.

## Answering the User's Specific Questions

### Q1: Shouldn't times be constructed from syntax?

**Answer**: No, and here's why:
- Times are part of the frame signature, like domains in first-order logic
- The canonical model construction builds **worlds** and **relations** from syntax
- The completeness theorem is relativized to arbitrary time types
- This relativization is exactly what the polymorphic `valid` definition requires

### Q2: Does using Int commit to discreteness?

**Answer**: Using Int for a specific instantiation doesn't commit the logic to discreteness because:
- Completeness holds for ALL time types simultaneously
- The axiom system is the same regardless of time type
- Soundness was proven for all time types
- Any formula provable is valid in ALL frames (discrete, dense, continuous)

### Q3: How to remain agnostic about time structure?

**Answer**: The agnosticism is achieved by:
1. Polymorphic validity: `valid φ` quantifies over ALL time types
2. Axioms that don't assume discrete/dense/continuous properties
3. Relativized completeness: for each T, completeness holds for T-frames
4. The intersection of all T-valid formulas equals the provable formulas

## Connection to Existing Literature

From the [Stanford Encyclopedia of Philosophy on Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/):

> "The minimal temporal logic K_t captures those validities of TL that do not depend on any specific assumptions concerning the properties of the temporal precedence relation."

And:

> "By adding further axioms, each being a temporal formula corresponding to particular constraints on temporal frames, one can define linear temporal logics over discrete structures, dense structures, finite but unbounded structures, infinite structures, etc."

This confirms that:
- Basic temporal logics (like TM) are agnostic about time structure
- Adding axioms specializes to specific time structures
- Completeness is relative to the frame class characterized by the axioms

## Recommended Changes to Implementation

### In Completeness.lean

```lean
-- Remove: def CanonicalTime : Type := Int

-- Keep: def CanonicalWorldState : Type := {Γ : Context // MaximalConsistent Γ}

-- Parameterize canonical frame by T
def canonical_frame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    : TaskFrame T := sorry

-- State completeness with T parameter
theorem weak_completeness (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (φ : Formula) :
    (∀ (F : TaskFrame T) ..., truth_at ...) →
    DerivationTree [] φ := sorry

-- Derive polymorphic completeness
theorem weak_completeness_poly (φ : Formula) : (⊨ φ) → DerivationTree [] φ :=
  fun h => weak_completeness Int φ (fun F M τ t ht => h Int F M τ t ht)
```

## Conclusion

The correct approach to canonical model completeness for TM logic is:

1. **Do NOT construct times from syntax** - times are a type parameter
2. **DO construct worlds (maximal consistent sets) from syntax**
3. **DO construct task relation from formula membership**
4. **Prove completeness relative to each time type T**
5. **Derive polymorphic completeness by instantiation**

This approach:
- Matches the polymorphic validity definition
- Remains fully agnostic about time structure
- Follows standard practice in temporal logic
- Is simpler than trying to construct abstract times from syntax

## References

- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) - Frame class completeness
- [Goldblatt, Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) - Canonical models for temporal logic
- [nLab on Temporal Logic](https://ncatlab.org/nlab/show/temporal+logic) - Category-theoretic perspective
- `Theories/Bimodal/Semantics/Validity.lean` - Polymorphic validity definition
- `Theories/Bimodal/Metalogic/Soundness.lean` - Soundness for all time types
