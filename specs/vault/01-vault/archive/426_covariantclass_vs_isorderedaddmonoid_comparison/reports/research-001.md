# Research Report: Task #426

**Task**: CovariantClass vs IsOrderedAddMonoid comparison
**Date**: 2026-01-12
**Focus**: Analyze whether using IsOrderedAddMonoid (task 420) loses expressiveness compared to CovariantClass (originally intended in task 417) for representing time as a totally ordered commutative group

## Summary

The current implementation using `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` is **mathematically equivalent** to using `CovariantClass` for the project's purposes. Both approaches correctly capture the paper's specification of time as a totally ordered abelian group. The IsOrderedAddMonoid approach is preferred because it aligns with modern Mathlib conventions and is more maintainable.

## Background

### Paper Specification

From `recursive-semantics.md` (lines 246-250):
> A *core frame* is a structure **F** = <S, >, D, => where:
> - **Temporal Order**: D = <D, +, <= > is a totally ordered abelian group

The paper specifies time as a "totally ordered abelian group", which requires:
1. Abelian group structure: `(T, +, 0, -)` with commutativity
2. Total (linear) order: `<= ` is reflexive, antisymmetric, transitive, and total
3. Order compatibility: Addition preserves the order relation

### Current Implementation

From `TaskFrame.lean` (line 83):
```lean
structure TaskFrame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T] where
```

This unbundled approach was implemented by task 420 during the Mathlib v4.27.0 upgrade.

### Original Task 417 Recommendation

Task 417's research-001.md originally recommended using `CovariantClass`:
```lean
variable {T : Type*} [AddCommGroup T] [LinearOrder T]
  [CovariantClass T T (. + .) (. <= .)]
```

## Technical Analysis

### What IsOrderedAddMonoid Provides

From Mathlib (`Mathlib/Algebra/Order/Monoid/Defs.lean`):

```lean
class IsOrderedAddMonoid (alpha : Type*) [AddCommMonoid alpha] [PartialOrder alpha] : Prop where
  add_le_add_left : forall (a b : alpha), a <= b -> forall (c : alpha), a + c <= b + c
  add_le_add_right : forall (a b : alpha), a <= b -> forall (c : alpha), c + a <= c + b
```

Key instances automatically derived:
- `IsOrderedAddMonoid.toAddLeftMono` - provides `AddLeftMono T`
- `IsOrderedAddMonoid.toAddRightMono` - provides `AddRightMono T`

### What CovariantClass Provides

From Mathlib (`Mathlib/Algebra/Order/Monoid/Unbundled/Defs.lean`):

```lean
class CovariantClass (M N : Type*) (mu : M -> N -> N) (r : N -> N -> Prop) : Prop where
  elim : Covariant M N mu r
```

The abbreviations:
- `AddLeftMono T` is `CovariantClass T T (. + .) (. <= .)`
- `AddRightMono T` is `CovariantClass T T (Function.swap (. + .)) (. <= .)`

### Mathematical Equivalence

For additive commutative structures, the two approaches are **logically equivalent**:

1. **IsOrderedAddMonoid implies both CovariantClasses**:
   ```lean
   -- From IsOrderedAddMonoid, we get:
   instance [IsOrderedAddMonoid T] : AddLeftMono T := inferInstance
   instance [IsOrderedAddMonoid T] : AddRightMono T := inferInstance
   ```

2. **CovariantClass (left) implies CovariantClass (right) for commutative structures**:
   ```lean
   -- From Mathlib:
   theorem addRightMono_of_addLeftMono (N : Type*)
     [AddCommSemigroup N] [LE N] [AddLeftMono N] : AddRightMono N
   ```

3. **Both provide the same lemmas**:
   - `add_le_add_left`: If `a <= b` then `c + a <= c + b`
   - `add_le_add_right`: If `a <= b` then `a + c <= b + c`
   - `add_le_add`: If `a <= b` and `c <= d` then `a + c <= b + d`

### No Loss of Expressiveness

The paper requires time to be a "totally ordered abelian group". Both approaches provide:

| Requirement | IsOrderedAddMonoid | CovariantClass |
|------------|-------------------|----------------|
| Abelian group | `[AddCommGroup T]` | `[AddCommGroup T]` |
| Total order | `[LinearOrder T]` | `[LinearOrder T]` |
| Left monotonicity | `toAddLeftMono` | Direct constraint |
| Right monotonicity | `toAddRightMono` | Via commutativity |
| Cancellation | Via AddGroup | Via AddGroup + ContravariantClass |

**Critical insight**: For `AddCommGroup` (abelian group), having left monotonicity automatically gives right monotonicity due to commutativity. The `IsOrderedAddMonoid` class simply bundles both directions for convenience.

## Pros and Cons Comparison

### IsOrderedAddMonoid (Current Implementation)

**Pros:**
1. **Mathlib-aligned**: Follows Mathlib 4.27+ conventions where bundled classes are deprecated in favor of `Is*` mixins
2. **Semantically clear**: Name directly states "this monoid is ordered"
3. **Bundled convenience**: Both left and right monotonicity in one class
4. **Future-proof**: Matches Mathlib's deprecation trend (`OrderedSemiring` -> `IsOrderedRing`)
5. **Proven working**: Already builds successfully with current Mathlib
6. **Simpler typeclass search**: One instance instead of two

**Cons:**
1. **Slightly coarser granularity**: Bundles both directions together
2. **Requires AddCommMonoid**: Cannot use with non-commutative structures (not relevant for this project)

### CovariantClass (Originally Recommended)

**Pros:**
1. **Maximum granularity**: Specifies exactly which direction of monotonicity is needed
2. **Minimal assumptions**: Uses the most primitive Mathlib building block
3. **Explicit documentation**: States precisely what properties are used
4. **Flexible**: Can specify only left OR only right monotonicity if needed

**Cons:**
1. **Against Mathlib conventions**: Mathlib is moving away from granular CovariantClass usage at definition level
2. **More verbose**: Requires spelling out the functor `(. + .)`
3. **May need ContravariantClass**: For cancellation lemmas like `add_le_add_iff_left`
4. **Would require code changes**: Would need to undo task 420's working implementation
5. **Potential instance search issues**: Two separate CovariantClass instances to find

## Semantic Accuracy Analysis

### Does IsOrderedAddMonoid Accurately Represent a Totally Ordered Abelian Group?

**Yes.** The constraint `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` captures exactly:

1. **Abelian group**: `AddCommGroup T` provides `(T, +, 0, -)` with all group axioms and commutativity
2. **Totally ordered**: `LinearOrder T` provides a total order with decidable comparison
3. **Order-group interaction**: `IsOrderedAddMonoid T` ensures addition respects the order

This is precisely what the paper specifies: "D = <D, +, <= > is a totally ordered abelian group".

### Would CovariantClass Be More Accurate?

**No.** Both approaches express the same mathematical content. The difference is purely in how Mathlib organizes the typeclasses, not in what mathematical properties are asserted.

The paper's informal "ordered abelian group" translates to the same formal requirement under either encoding:
- `a <= b` implies `a + c <= b + c` for all `c`

Both approaches assert this property.

## Recommendations

### Primary Recommendation: Keep IsOrderedAddMonoid

The current implementation correctly captures the paper's specification and is the idiomatic modern Mathlib approach. There is no benefit to changing to CovariantClass.

**Reasons:**
1. Mathematically equivalent to CovariantClass
2. Aligns with Mathlib's direction (unbundled `Is*` mixins)
3. Already working and tested
4. Cleaner code (one class vs multiple CovariantClass instances)
5. Better maintainability as Mathlib evolves

### Not Recommended: Switch to CovariantClass

Switching would:
1. Require code changes to working implementation
2. Go against Mathlib conventions
3. Provide no mathematical benefit
4. Potentially introduce instance search complexity

### Optional: Document the Design Decision

Consider adding a comment in `TaskFrame.lean` explaining the choice:

```lean
/-!
## Type Class Design Decision

The temporal type `T` uses `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]`
rather than `CovariantClass` because:
1. IsOrderedAddMonoid is the modern Mathlib convention for ordered algebraic structures
2. It provides both left and right monotonicity automatically
3. For commutative groups, IsOrderedAddMonoid is equivalent to CovariantClass

Both approaches correctly capture the paper's specification of time as a
"totally ordered abelian group" (recursive-semantics.md, line 250).
-/
```

## Conclusion

**No expressiveness is lost** by using `IsOrderedAddMonoid` instead of `CovariantClass`. The two approaches are mathematically equivalent for additive commutative groups. The current implementation correctly represents time as a totally ordered abelian group as specified in the paper.

The `IsOrderedAddMonoid` approach is actually **preferred** because it:
- Follows modern Mathlib conventions
- Is cleaner and more maintainable
- Has already been tested and verified to work

## References

- Mathlib.Algebra.Order.Monoid.Defs - IsOrderedAddMonoid definition
- Mathlib.Algebra.Order.Monoid.Unbundled.Defs - CovariantClass definition
- `recursive-semantics.md` lines 246-250 - Paper specification of temporal order
- Task 417 research-002.md - Previous analysis comparing approaches
- Task 420 implementation - Mathlib upgrade that introduced current approach
