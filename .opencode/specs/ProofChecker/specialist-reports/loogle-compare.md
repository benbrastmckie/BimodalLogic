# Loogle API Search Report: 'compare' Pattern

## Search Metadata

- **Search Date**: 2025-12-21 19:07:49
- **Search Pattern**: `"compare"` (name-based search)
- **Total Matches Found**: 546
- **Matches Shown**: 200 (first 200)
- **API Heartbeats**: 17

## Overview

Found 546 declarations whose name contains "compare".
Of these, only the first 200 are shown.

- **Exact name matches** (name ends with 'compare'): 1
- **Partial name matches** (contains 'compare'): 199
- **Unique modules**: 15
- **Core comparison functions identified**: 5

---

## Library Distribution

- **Core/Init**: 128 functions (64.0%)
- **Std**: 72 functions (36.0%)

---

## Core Comparison Functions

These are the fundamental comparison utilities in Lean's standard library:

### 1. `Ord.compare`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u} [self : Ord α] : α → α → Ordering
```

**Documentation**: Compare two elements in `α` using the comparator contained in an `[Ord α]` instance. 

### 2. `compareOn`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering
```

**Documentation**: Compares two values by comparing the results of applying a function.

In particular, `x` is compared to `y` by comparing `f x` and `f y`.

Examples:
* `compareOn (·.length) "apple" "banana" = .lt`
* `compareOn (· % 3) 5 6 = .gt`
* `compareOn (·.foldl max 0) [1, 2, 3] [3, 2, 1] = .eq`


### 3. `compareLex`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering
```

**Documentation**: Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`.

`a` and `b` are first compared by `cmp₁`. If this returns `Ordering.eq`, `a` and `b` are compared
by `cmp₂` to break the tie.

To lexicographically combine two `Ordering`s, use `Ordering.then`.


### 4. `compareOfLessAndBEq`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering
```

**Documentation**: Uses a decidable less-than relation and Boolean equality to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x == y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndEq` uses `DecidableEq` instead of `BEq`.


### 5. `compareOfLessAndEq`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering
```

**Documentation**: Uses decidable less-than and equality relations to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x = y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndBEq` uses `BEq` instead of `DecidableEq`.


---

## Top 10 Modules by Function Count

1. **Std.Data.DTreeMap.Internal.Lemmas**: 52 functions
2. **Init.Data.Ord.Basic**: 42 functions
3. **Init.Data.Order.Ord**: 35 functions
4. **Std.Data.DTreeMap.Lemmas**: 11 functions
5. **Init.Data.Nat.Compare**: 10 functions
6. **Init.Data.Int.Compare**: 10 functions
7. **Init.Data.Ord.Vector**: 10 functions
8. **Init.Data.Ord.Array**: 6 functions
9. **Init.Data.Order.FactoriesExtra**: 5 functions
10. **Std.Data.DTreeMap.Internal.Ordered**: 5 functions

---

## Complete Function Listing

### Exact Matches (name ends with 'compare')

#### `Ord.compare`
- **Module**: `Init.Data.Ord.Basic`
- **Type**: ` {α : Type u} [self : Ord α] : α → α → Ordering`

---

## Functional Categories

Based on analysis of the results, 'compare' functions fall into these categories:

### Ordering/Comparison (55 functions)

- `Ord.compare`
- `compareOn`
- `compareLex`
- `compareOfLessAndBEq`
- `compareOfLessAndEq`
- `compareLex.eq_1`
- `compareOfLessAndEq_eq_lt`
- `compareLex_eq_eq`
- `compareOfLessAndEq.eq_1`
- `compareOfLessAndEq_eq_gt_of_lt_iff_not_gt_and_ne`
- *...and 45 more*

### List Operations (39 functions)

- `List.compareLex`
- `List.compareLex_nil_nil`
- `List.compareLex.eq_1`
- `List.compare_nil_nil`
- `List.isGE_compareLex_nil_right`
- `List.isLE_compareLex_nil_left`
- `List.isGE_compare_nil_right`
- `List.isLE_compare_nil_left`
- `List.compareLex_cons_nil`
- `List.compareLex_nil_cons`
- *...and 29 more*

### Data Structures (11 functions)

- `Std.DTreeMap.compare_getKey?_self`
- `Std.DTreeMap.compare_getKey_self`
- `Std.DTreeMap.Const.compare_maxKeyD_modify_eq`
- `Std.DTreeMap.Const.compare_minKeyD_modify_eq`
- `Std.DTreeMap.Const.compare_maxKey!_modify_eq`
- `Std.DTreeMap.Const.compare_minKey!_modify_eq`
- `Std.DTreeMap.Const.contains_alter_of_not_compare_eq`
- `Std.DTreeMap.Const.ordCompare_maxKeyD_modify_eq`
- `Std.DTreeMap.Const.ordCompare_minKeyD_modify_eq`
- `Std.DTreeMap.maxKey?_erase_eq_of_not_compare_eq_maxKey?`
- *...and 1 more*

### Natural Numbers (10 functions)

- `Nat.compare_eq_eq`
- `Nat.compare_swap`
- `Nat.compare_eq_gt`
- `Nat.compare_eq_lt`
- `Nat.compare_ne_gt`
- `Nat.compare_ne_lt`
- `Nat.isGE_compare`
- `Nat.isLE_compare`
- `Nat.compare_eq_ite_le`
- `Nat.compare_eq_ite_lt`

### Integers (70 functions)

- `Int.compare_eq_eq`
- `Int.compare_swap`
- `Int.compare_eq_gt`
- `Int.compare_eq_lt`
- `Int.compare_ne_gt`
- `Int.compare_ne_lt`
- `Int.isGE_compare`
- `Int.isLE_compare`
- `Int.compare_eq_ite_le`
- `Int.compare_eq_ite_lt`
- *...and 60 more*

### Arrays/Vectors (15 functions)

- `Array.compareLex`
- `Array.compare_eq_compareLex`
- `Array.instLawfulEqCmpCompareLex`
- `Array.instOrientedCmpCompareLex`
- `Array.instReflCmpCompareLex`
- `Array.instTransCmpCompareLex`
- `Array.instLawfulBEqCmpCompareLex`
- `Vector.compareLex`
- `Vector.instLawfulEqCmpCompareLex`
- `Vector.instOrientedCmpCompareLex`
- *...and 5 more*

---

## Top 10 Most Relevant Functions

Based on documentation quality, core functionality, and general applicability:

### 1. `compareOn`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering
```

**Documentation**: Compares two values by comparing the results of applying a function.

In particular, `x` is compared to `y` by comparing `f x` and `f y`.

Examples:
* `compareOn (·.length) "apple" "banana" = .lt`
* `compareOn (· % 3) 5 6 = .gt`
* `compareOn (·.foldl max 0) [1, 2, 3] [3, 2, 1] = .eq`


---

### 2. `compareLex`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering
```

**Documentation**: Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`.

`a` and `b` are first compared by `cmp₁`. If this returns `Ordering.eq`, `a` and `b` are compared
by `cmp₂` to break the tie.

To lexicographically combine two `Ordering`s, use `Ordering.then`.


---

### 3. `compareOfLessAndBEq`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering
```

**Documentation**: Uses a decidable less-than relation and Boolean equality to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x == y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndEq` uses `DecidableEq` instead of `BEq`.


---

### 4. `compareOfLessAndEq`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering
```

**Documentation**: Uses decidable less-than and equality relations to find an `Ordering`.

In particular, if `x < y` then the result is `Ordering.lt`. If `x = y` then the result is
`Ordering.eq`. Otherwise, it is `Ordering.gt`.

`compareOfLessAndBEq` uses `BEq` instead of `DecidableEq`.


---

### 5. `Ord.compare`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u} [self : Ord α] : α → α → Ordering
```

**Documentation**: Compare two elements in `α` using the comparator contained in an `[Ord α]` instance. 

---

### 6. `compareOn.eq_1`

**Module**: `Init.Data.Order.Ord`

**Type Signature**:
```lean
 {β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : compareOn f x y = compare (f x) (f y)
```

**Documentation**: None

---

### 7. `List.compareLex`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering
```

**Documentation**: None

---

### 8. `compareLex.eq_1`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : compareLex cmp₁ cmp₂ a b = (cmp₁ a b).then (cmp₂ a b)
```

**Documentation**: None

---

### 9. `compareLex_eq_eq`

**Module**: `Init.Data.Ord.Basic`

**Type Signature**:
```lean
 {α : Sort u_1} {cmp₁ cmp₂ : α → α → Ordering} {a b : α} : compareLex cmp₁ cmp₂ a b = Ordering.eq ↔ cmp₁ a b = Ordering.eq ∧ cmp₂ a b = Ordering.eq
```

**Documentation**: None

---

### 10. `Nat.compare_swap`

**Module**: `Init.Data.Nat.Compare`

**Type Signature**:
```lean
 (a b : ℕ) : (compare a b).swap = compare b a
```

**Documentation**: None

---

## Usage Recommendations

### For General Comparison

1. **`Ord.compare`**: Primary comparison function for types with an `Ord` instance
   - Use when you need to compare two values of the same type
   - Returns `Ordering` (`.lt`, `.eq`, or `.gt`)

2. **`compareOn`**: Compare values by projecting through a function
   - Useful for comparing complex types by a specific field
   - Example: `compareOn (·.length) "apple" "banana"`

### For Lexicographic Ordering

3. **`compareLex`**: Combine two comparisons lexicographically
   - First compares by `cmp₁`, then by `cmp₂` if equal
   - Essential for multi-field comparisons

4. **`List.compareLex`**: Lexicographic comparison for lists
   - Compares lists element-by-element
   - Used in `List`'s `Ord` instance

### For Custom Comparison Logic

5. **`compareOfLessAndEq`**: Build comparison from `<` and `=` relations
   - Use when defining `Ord` instances for custom types
   - Requires `DecidableLT` and `DecidableEq`

6. **`compareOfLessAndBEq`**: Similar but uses `BEq` instead of `DecidableEq`
   - Useful for types with Boolean equality

### Type-Specific Comparisons

- **Natural numbers**: See functions in `Init.Data.Nat.Compare`
- **Integers**: See functions in `Init.Data.Int.Compare`
- **Lists**: Use `List.compareLex` or the `Ord` instance
- **Arrays/Vectors**: See `Init.Data.Ord.Array` and `Init.Data.Ord.Vector`

---

## Patterns and Insights

### Naming Conventions

1. **`compare`**: Base comparison function
2. **`compareLex`**: Lexicographic comparison variant
3. **`compareOn`**: Comparison with projection function
4. **`compareOf*`**: Constructors for building comparison functions
5. **`*_compare_*`**: Theorems about comparison properties

### Common Theorem Patterns

- **`compare_nil_*`**: Properties of comparing with empty lists
- **`compare_cons_*`**: Properties of comparing list constructors
- **`compare_*_eq_eq`**: Conditions for equality comparison result
- **`isLE_compare_*`**, **`isGE_compare_*`**: Properties of comparison ordering

### Library Organization

- **Core/Init** (128 functions): Fundamental comparison utilities
- **Std** (72 functions): Data structure comparisons (DTreeMap, RBTree)
- **Lean** (0 functions): Internal compiler/metaprogramming comparisons

---

## Appendix: Full Module List

- **Init.Data.Int.Compare**: 10 functions
- **Init.Data.Nat.Compare**: 10 functions
- **Init.Data.Ord.Array**: 6 functions
- **Init.Data.Ord.Basic**: 42 functions
- **Init.Data.Ord.Vector**: 10 functions
- **Init.Data.Order.ClassesExtra**: 4 functions
- **Init.Data.Order.FactoriesExtra**: 5 functions
- **Init.Data.Order.LemmasExtra**: 3 functions
- **Init.Data.Order.Ord**: 35 functions
- **Init.Data.Order.PackageFactories**: 3 functions
- **Std.Data.DTreeMap.Internal.Lemmas**: 52 functions
- **Std.Data.DTreeMap.Internal.Model**: 1 functions
- **Std.Data.DTreeMap.Internal.Ordered**: 5 functions
- **Std.Data.DTreeMap.Lemmas**: 11 functions
- **Std.Data.Internal.Cut**: 3 functions

---

*Report generated on 2025-12-21 19:07:49 via Loogle API*

*Total declarations in database: 546*
*Showing: 200 declarations*