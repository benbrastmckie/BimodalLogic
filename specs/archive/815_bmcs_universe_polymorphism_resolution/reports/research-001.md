# Research Report: BMCS Universe Polymorphism Resolution

**Task**: 815 - BMCS Universe Polymorphism Resolution
**Date**: 2026-02-02
**Session**: sess_1770068208_f80de2
**Status**: Complete

## Executive Summary

The two sorries in BMCS completeness (`bmcs_valid_implies_valid_Int` at line 158-160 and `bmcs_consequence_implies_consequence_Int` at line 288-292) stem from Lean 4's universe polymorphism system. The root cause is that `bmcs_valid` uses `Type*` (which elaborates to `Type u` for some universe variable `u`), while `Int : Type` lives specifically in `Type 0`. Direct instantiation fails with a universe mismatch error.

**Recommended Solution**: Restructure the definitions to use `Type` instead of `Type*`, or restructure the proofs to directly use the Int-specific versions without the polymorphic intermediary.

## Problem Analysis

### The Universe Polymorphism Issue

The definitions in question:

```lean
-- From BMCSTruth.lean:108-110
def bmcs_valid (φ : Formula) : Prop :=
  ∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

-- From Completeness.lean:143-144
def bmcs_valid_Int (φ : Formula) : Prop :=
  ∀ (B : BMCS Int), ∀ fam ∈ B.families, ∀ t : Int, bmcs_truth_at B fam t φ
```

When we have `h : bmcs_valid φ` and try to apply it with `h Int B fam hfam t`, we get:

```
error: Application type mismatch: The argument
  ℤ
has type
  Type
of sort `Type 1` but is expected to have type
  Type u_1
of sort `Type (u_1 + 1)` in the application
  @h ℤ
```

### Why This Happens

1. `Type*` in Lean 4 elaborates to `Type u` where `u` is a universe metavariable
2. When `bmcs_valid` is defined, the `u` becomes fixed in the definition
3. `Int : Type` (which is `Type 0`)
4. The elaborator cannot unify `Type u_1` with `Type 0` because `u_1` may be constrained elsewhere

### Semantic Analysis

The polymorphism in `bmcs_valid` is **mathematically unnecessary** for completeness:

1. **Completeness is existential**: It says "if `φ` is valid, then `φ` is derivable"
2. **The contrapositive**: "if `¬derivable φ`, then `¬valid φ`"
3. **To prove `¬valid φ`**: We only need to find ONE countermodel where `φ` fails
4. **Int suffices**: The domain `Int` has all necessary properties (ordered additive group)

The `bmcs_valid` definition quantifies over all type universes, but we only NEED validity over `Int` for completeness. The polymorphic version is stronger than necessary.

## Verified Solutions

### Solution A: Use Universe-Monomorphic Definition (RECOMMENDED)

Change `bmcs_valid` to use `Type` instead of `Type*`:

```lean
-- In BMCSTruth.lean:108-110
def bmcs_valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ
```

Then the implication works directly:

```lean
lemma bmcs_valid_implies_valid_Int (φ : Formula) (h : bmcs_valid φ) :
    bmcs_valid_Int φ := by
  intro B fam hfam t
  exact h Int B fam hfam t  -- Now works: Int : Type
```

**Pros**:
- Simple one-line change
- No axioms needed
- Preserves all existing proof structure

**Cons**:
- Loses polymorphism over higher universes
- Minor semantic change (but irrelevant for completeness)

### Solution B: Eliminate Intermediate Lemmas

Restructure to use `bmcs_valid_Int` directly without going through `bmcs_valid`:

1. Replace `bmcs_weak_completeness`:
   ```lean
   theorem bmcs_weak_completeness (φ : Formula) (h_valid : bmcs_valid_Int φ) :
       Nonempty (DerivationTree [] φ) := ...
   ```

2. Replace `bmcs_strong_completeness` similarly

3. Remove `bmcs_valid_implies_valid_Int` and `bmcs_consequence_implies_consequence_Int`

**Pros**:
- Removes the problematic lemmas entirely
- Clear Int-focused semantics

**Cons**:
- More invasive change
- Loses the "polymorphic" API

### Solution C: Use Explicit Universe Annotations

Define with explicit universe levels:

```lean
universe u

def bmcs_valid_in_universe.{v} (φ : Formula) : Prop :=
  ∀ (D : Type v) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

def bmcs_valid_Int (φ : Formula) : Prop := bmcs_valid_in_universe.{0} φ
```

**Pros**:
- Maximum flexibility
- Clear universe stratification

**Cons**:
- More complex API
- May need changes throughout codebase

### Solution D: Keep as Axiom (Current State)

Leave the `sorry` and document that this is a Lean technicality, not a mathematical gap.

**Pros**:
- No code changes needed
- Mathematically sound (the implication is obviously true)

**Cons**:
- Not fully formalized
- Counts toward sorry count

## Type Class Instances Verified

All required instances exist in Mathlib for `Int`:

| Type Class | Instance | Module |
|------------|----------|--------|
| `AddCommGroup Int` | `Int.instAddCommGroup` | `Mathlib.Algebra.Group.Int.Defs` |
| `LinearOrder Int` | `Int.instLinearOrder` | `Mathlib.Data.Int.Order.Basic` |
| `IsOrderedAddMonoid Int` | `Int.instIsOrderedAddMonoid` | `Mathlib.Algebra.Order.Group.Int` |

## Recommended Implementation Plan

### Option 1: Quick Fix (Solution A)

1. **Edit BMCSTruth.lean:108**: Change `Type*` to `Type`
2. **Edit BMCSTruth.lean:267-270**: Same change for `bmcs_consequence`
3. **Verify Completeness.lean builds**: The `sorry`s should now be directly provable
4. **Fill in the proofs**: Replace `sorry` with `exact h Int B fam hfam t` (or similar)

### Option 2: Clean Architecture (Solution B)

1. Remove the polymorphic definitions
2. Use only Int-specific versions throughout
3. Update documentation to clarify Int-focused approach

## Impact Assessment

| File | Changes Required |
|------|------------------|
| `BMCSTruth.lean` | Change `Type*` to `Type` in 2 definitions |
| `Completeness.lean` | Fill in 2 sorries (trivial after BMCSTruth change) |
| Other files | None (API compatible) |

## Conclusion

The universe polymorphism sorries are **purely technical** - there is no mathematical gap. The recommended fix is **Solution A**: change `Type*` to `Type` in the validity definitions. This is a minimal change that makes the proofs go through while preserving all semantic content relevant to the completeness theorems.

The polymorphism was arguably unnecessary to begin with: for completeness, we only need countermodels in ONE domain, and `Int` is a natural choice that satisfies all requirements.

## Files Created

- `Theories/Bimodal/Metalogic/Bundle/UniverseTest.lean` - Verification of solutions
- `Theories/Bimodal/Metalogic/Bundle/UniverseTest2.lean` - Analysis documentation

These test files can be deleted after implementation, or kept as documentation of the investigation.

## References

- Lean 4 documentation on universe polymorphism
- `Int.instAddCommGroup` in `Mathlib.Algebra.Group.Int.Defs`
- `Int.instLinearOrder` in `Mathlib.Data.Int.Order.Basic`
- `Int.instIsOrderedAddMonoid` in `Mathlib.Algebra.Order.Group.Int`
