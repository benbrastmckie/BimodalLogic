# Mathlib Theorems Research Report: Soundness Type Mismatch Fix

## Overview

This report documents research on Mathlib patterns relevant to fixing the type mismatch errors in `Logos/Core/Metalogic/Soundness.lean`.

## Problem Statement

The Soundness.lean file has systematic type mismatch errors where the variable `F` is being shadowed/confused. The `semantic_consequence` definition in Validity.lean quantifies over:

```lean
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    (∀ ψ ∈ Γ, truth_at M τ t ht ψ) →
    truth_at M τ t ht φ
```

The `intro` pattern in the soundness theorem captures variables incorrectly, leading to `F` becoming a type instead of a TaskFrame.

## Key Mathlib Patterns Identified

### 1. Type-Level vs Term-Level Parameter Distinction

Mathlib follows a consistent pattern for universe-polymorphic definitions:

**Pattern**: Use explicit `(T : Type*)` as the first parameter, followed by instance `[LinearOrderedAddCommGroup T]`, then term-level structures.

**Reference**: `Mathlib.Algebra.Order.Group.Defs` uses this consistently.

### 2. Correct Intro Pattern for Polymorphic Predicates

When introducing variables from a quantified proposition, the order must match the definition order:

```lean
-- Definition order: T, instance, F, M, τ, t, ht
intro T inst F M τ t ht h_all
```

The current Soundness.lean uses:
```lean
intro F M τ t ht h_all  -- Missing T and inst!
```

### 3. Named Instance Parameters

Mathlib convention: instance parameters can be named when needed for explicit application:

```lean
intro T -- Type
intro (inst : LinearOrderedAddCommGroup T)  -- Instance (usually implicit)
intro F  -- TaskFrame
```

### 4. Proof Irrelevance for Domain Membership

The `truth_at` function signature:
```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) : Formula → Prop
```

The `ht : τ.domain t` proof is passed explicitly. Mathlib's `Subtype` and proof irrelevance patterns apply.

## Relevant Mathlib Theorems

### For Time-Shift Operations

1. `add_sub_cancel` : `∀ a b, a + b - b = a`
2. `add_sub_cancel_left` : `∀ a b, a + (b - a) = b`
3. `sub_add_cancel` : `∀ a b, a - b + b = a`
4. `Int.lt_trans` : `∀ a b c, a < b → b < c → a < c`
5. `neg_sub` : `∀ a b, -(a - b) = b - a`

### For Classical Logic

1. `Classical.byContradiction` : `(¬P → False) → P`
2. `False.elim` : `False → P`
3. `List.not_mem_nil` : `∀ a, a ∉ []`
4. `List.mem_cons_self` : `∀ a l, a ∈ a :: l`

## Findings

### Finding 1: Variable Shadowing Root Cause

The errors like "argument M has type `LinearOrderedAddCommGroup F`" indicate that `F` is being bound to the type variable `T`, not the TaskFrame. This happens because:

1. `semantic_consequence` begins: `∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) ...`
2. The proof uses: `intro F M τ t ht ...`
3. This binds `F` to `T`, `M` to the instance, etc.

### Finding 2: Systematic Pattern

All errors in the soundness theorem follow this pattern:
- Lines 89, 103, 120, 142, etc.: "function expected at `h1`/`h_phi`/`h_box`"
- Lines 473, 486, 487, 501, 525, 557, 601: "argument `M` has type `LinearOrderedAddCommGroup F` but expected `TaskFrame F`"

### Finding 3: Correct Fix Pattern

The fix is simple - add the missing type and instance introductions:

**Current (Broken)**:
```lean
intro F M τ t ht h_all
```

**Fixed**:
```lean
intro T _ F M τ t ht h_all
```

The underscore `_` for the instance works because Lean can infer it.

## Recommendations

### Recommendation 1: Update All Intro Patterns in Soundness Theorem

Every case in the soundness theorem needs:
```lean
intro T _ F M τ t ht ...
```

Instead of:
```lean
intro F M τ t ht ...
```

### Recommendation 2: Update Axiom Validity Lemmas

The axiom validity lemmas (prop_k_valid, modal_t_valid, etc.) also need updating:

**Current**:
```lean
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro F M τ t ht
```

**Fixed**:
```lean
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ F M τ t ht
```

### Recommendation 3: Apply Systematically

Apply this fix to:
- All 12 axiom validity lemmas (lines 84-450)
- The main soundness theorem (lines 466-604)
- Any helper lemmas with similar structure

## Conclusion

The type mismatch errors are caused by a systematic intro pattern error throughout Soundness.lean. The fix is mechanical: add `T _` at the beginning of each intro pattern to match the `semantic_consequence` and `valid` definition signatures.

Estimated effort: 2-3 hours for careful application and testing.
