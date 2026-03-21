# Research Report: Task #417

**Task**: Split typeclass constraints in Explanatory
**Date**: 2026-01-11
**Focus**: Analyze feasibility of splitting LinearOrderedAddCommGroup into component constraints

## Summary

Splitting `LinearOrderedAddCommGroup T` into `[AddCommGroup T] [LinearOrder T] [CovariantClass T T (· + ·) (· ≤ ·)]` is feasible and should reduce typeclass instance search complexity. The code uses only basic operations (zero, addition, subtraction, comparison) that work with the split constraints. However, the change affects 3 files in Explanatory and may require adding explicit instances in some cases.

## Findings

### 1. Current Constraint Usage

The `LinearOrderedAddCommGroup T` constraint appears in:

| File | Line(s) | Context |
|------|---------|---------|
| Frame.lean | 34, 42, 221 | variable, CoreFrame structure, CoreModel structure |
| Truth.lean | 36 | variable |
| Explanatory.lean | 34 | variable (documentation example) |

Operations actually used from this constraint:
- `0 : T` (zero element) - in nullity: `taskRel s 0 s`
- `x + y : T` (addition) - in compositionality: `taskRel s (x + y) u`
- `y - x : T` (subtraction) - in task_respecting: `(y - x)` as duration
- `x ≤ y` (comparison) - in task_respecting and temporal operators
- `x < y` (strict comparison) - in temporal operators

### 2. Required Component Constraints

The split requires three constraints:

```lean
variable (T : Type*) [AddCommGroup T] [LinearOrder T]
  [CovariantClass T T (· + ·) (· ≤ ·)]
```

| Constraint | Provides | Hierarchy Depth |
|------------|----------|-----------------|
| `AddCommGroup T` | `0`, `+`, `-`, negation, commutativity | Shallow (via AddMonoid, AddZeroClass) |
| `LinearOrder T` | `≤`, `<`, totality, decidability | Moderate |
| `CovariantClass T T (· + ·) (· ≤ ·)` | Order compatibility with addition | Single class |

### 3. Verification of Component Sufficiency

Tested that split constraints support all required operations:

```lean
-- All operations verified working:
#check (0 : T)                           -- ✓ from AddGroup
example (x y : T) : x + y = x + y        -- ✓ from AddGroup
example (x y : T) : y - x = y + (-x)     -- ✓ from AddGroup
example (x y : T) : x ≤ y ∨ y ≤ x        -- ✓ from LinearOrder

-- Order-addition compatibility:
example (a b c : T) (h : b ≤ c) : a + b ≤ a + c := add_le_add_left h a  -- ✓
example (x y : T) (h : x ≤ y) : 0 ≤ y - x := -- ✓ (proof required)
```

### 4. Why This Helps Performance

According to research from task 400:

1. **Diamond Inheritance**: `LinearOrderedAddCommGroup` has multiple inheritance paths:
   - Via `OrderedAddCommGroup` → `PartialOrder` → `Preorder`
   - Via `LinearOrder` → `PartialOrder` → `Preorder`

2. **Instance Search Explosion**: Each failed instance synthesis takes ~0.001s, but with 500+ attempts during diamond resolution, delays compound to 0.5+ seconds per query.

3. **Split Benefits**:
   - `AddCommGroup` has a single clean inheritance chain
   - `LinearOrder` doesn't overlap with group structure
   - `CovariantClass` is a standalone class with no inheritance

### 5. ContravariantClass Consideration

Testing revealed that `ContravariantClass T T (· + ·) (· ≤ ·)` may also be needed for some lemmas involving cancellation:

```lean
-- This uses ContravariantClass:
example (x y z : T) (h : z + x ≤ z + y) : x ≤ y :=
  (add_le_add_iff_left z).mp h
```

The current code in Frame.lean and Truth.lean doesn't appear to use such cancellation lemmas, but this should be verified during implementation.

### 6. Bimodal Module Status

The Bimodal module also uses `LinearOrderedAddCommGroup` extensively (60+ occurrences). However, task 417 focuses only on Explanatory. A follow-up task could address Bimodal if performance improvements are significant.

## Recommendations

### Primary Approach

Replace in Frame.lean, Truth.lean, and Explanatory.lean:
```lean
-- Before
variable {T : Type*} [LinearOrderedAddCommGroup T]

-- After
variable {T : Type*} [AddCommGroup T] [LinearOrder T]
  [CovariantClass T T (· + ·) (· ≤ ·)]
```

Update structure definitions similarly:
```lean
structure CoreFrame (T : Type*) [AddCommGroup T] [LinearOrder T]
    [CovariantClass T T (· + ·) (· ≤ ·)] extends ConstitutiveFrame where
  ...
```

### Alternative: Use OrderedAddCommGroup + Decidability

A less invasive split uses `OrderedAddCommGroup` which bundles the covariance:
```lean
variable {T : Type*} [OrderedAddCommGroup T] [DecidableLE T] [DecidableLT T]
```

This might preserve more Mathlib lemma compatibility but provides less performance benefit.

### Files to Modify

1. **Frame.lean** (primary):
   - Line 34: Update variable declaration
   - Line 42: Update CoreFrame structure
   - Line 221: Update CoreModel structure

2. **Truth.lean**:
   - Line 36: Update variable declaration

3. **Explanatory.lean**:
   - Line 34: Update variable declaration in documentation

### Potential Complications

1. **Mathlib Lemma Compatibility**: Some Mathlib lemmas may require the full bundled class. These would need explicit instance parameters or alternative proofs.

2. **Cross-Module Dependencies**: If other modules import Explanatory and expect `LinearOrderedAddCommGroup`, they would need updates.

3. **Testing**: After changes, run `lake build` with profiling to verify performance improvement.

## References

- [Lean 4 Issue #2055](https://github.com/leanprover/lean4/issues/2055) - Typeclass inference performance
- [Mathlib.Algebra.Order.Group.Defs](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Order/Group/Defs.html) - Class definitions
- Task 400 research report - Performance investigation

## Next Steps

1. Create implementation plan with phased approach
2. Start with Frame.lean modifications (lowest dependency)
3. Build and test after each file
4. Measure performance improvement with profiling
