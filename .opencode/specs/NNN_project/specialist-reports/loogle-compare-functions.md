# Loogle Search Results: "compare" Functions

**Search Pattern**: `"compare"` (name-based search)  
**Date**: December 21, 2025  
**Total Matches Found**: 546 (showing first 200)  
**Query Type**: Name substring search

---

## Executive Summary

This search identified all comparison-related functions in LEAN libraries containing "compare" in their name. The results span multiple libraries including:
- **Init** (Core LEAN library)
- **Std** (Standard library)

Key categories of matches:
1. **Core comparison functions** (`Ord.compare`, `compareOn`, `compareLex`)
2. **Type-specific comparisons** (Nat, Int, List, Array, Vector)
3. **Comparison properties and theorems** (reflexivity, transitivity, lawfulness)
4. **Data structure comparisons** (DTreeMap internal operations)

---

## Core Comparison Functions

### 1. `Ord.compare`
- **Type**: `{α : Type u} [self : Ord α] : α → α → Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Compare two elements in `α` using the comparator contained in an `[Ord α]` instance.
- **Usage**: Primary comparison function for any type with an `Ord` instance

### 2. `compareOn`
- **Type**: `{β : Type u_1} {α : Sort u_2} [ord : Ord β] (f : α → β) (x y : α) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Compares two values by comparing the results of applying a function. In particular, `x` is compared to `y` by comparing `f x` and `f y`.
- **Examples**:
  - `compareOn (·.length) "apple" "banana" = .lt`
  - `compareOn (· % 3) 5 6 = .gt`
  - `compareOn (·.foldl max 0) [1, 2, 3] [3, 2, 1] = .eq`

### 3. `compareLex`
- **Type**: `{α : Sort u_1} {β : Sort u_2} (cmp₁ cmp₂ : α → β → Ordering) (a : α) (b : β) : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Compares `a` and `b` lexicographically by `cmp₁` and `cmp₂`. `a` and `b` are first compared by `cmp₁`. If this returns `Ordering.eq`, `a` and `b` are compared by `cmp₂` to break the tie.

### 4. `compareOfLessAndBEq`
- **Type**: `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [BEq α] : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Uses a decidable less-than relation and Boolean equality to find an `Ordering`. If `x < y` then result is `Ordering.lt`. If `x == y` then result is `Ordering.eq`. Otherwise, it is `Ordering.gt`.

### 5. `compareOfLessAndEq`
- **Type**: `{α : Type u_1} (x y : α) [LT α] [Decidable (x < y)] [DecidableEq α] : Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Uses decidable less-than and equality relations to find an `Ordering`. If `x < y` then result is `Ordering.lt`. If `x = y` then result is `Ordering.eq`. Otherwise, it is `Ordering.gt`.

---

## List Comparison Functions

### 6. `List.compareLex`
- **Type**: `{α : Type u_1} (cmp : α → α → Ordering) : List α → List α → Ordering`
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Documentation**: Lexicographic comparison for lists

### 7. `List.compare`
- **Type**: Derived from `Ord` instance
- **Module**: `Init.Data.Ord.Basic`
- **Library**: Init (Core)
- **Relation**: `List.compare_eq_compareLex : compare = List.compareLex compare`

### List Comparison Theorems

#### Nil Cases
- `List.compareLex_nil_nil : List.compareLex cmp [] [] = Ordering.eq`
- `List.compare_nil_nil : compare [] [] = Ordering.eq`
- `List.compareLex_cons_nil : List.compareLex cmp (x :: xs) [] = Ordering.gt`
- `List.compareLex_nil_cons : List.compareLex cmp [] (x :: xs) = Ordering.lt`
- `List.compare_cons_nil : compare (x :: xs) [] = Ordering.gt`
- `List.compare_nil_cons : compare [] (x :: xs) = Ordering.lt`

#### Cons Cases
- `List.compareLex_cons_cons : List.compareLex cmp (x :: xs) (y :: ys) = (cmp x y).then (List.compareLex cmp xs ys)`
- `List.compare_cons_cons : compare (x :: xs) (y :: ys) = (compare x y).then (compare xs ys)`

#### Properties
- `List.isGE_compareLex_nil_right : (List.compareLex cmp xs []).isGE = true`
- `List.isLE_compareLex_nil_left : (List.compareLex cmp [] xs).isLE = true`
- `List.isGE_compare_nil_right : (compare xs []).isGE = true`
- `List.isLE_compare_nil_left : (compare [] xs).isLE = true`

---

## Natural Number Comparison

### 8. `Nat.compare`
- **Type**: Derived from `Ord Nat` instance
- **Module**: `Init.Data.Nat.Compare`
- **Library**: Init (Core)

### Nat Comparison Theorems

#### Equality
- `Nat.compare_eq_eq : compare a b = Ordering.eq ↔ a = b`
- `Nat.compare_eq_lt : compare a b = Ordering.lt ↔ a < b`
- `Nat.compare_eq_gt : compare a b = Ordering.gt ↔ b < a`

#### Negation
- `Nat.compare_ne_lt : compare a b ≠ Ordering.lt ↔ b ≤ a`
- `Nat.compare_ne_gt : compare a b ≠ Ordering.gt ↔ a ≤ b`

#### Properties
- `Nat.compare_swap : (compare a b).swap = compare b a`
- `Nat.isLE_compare : (compare a b).isLE = true ↔ a ≤ b`
- `Nat.isGE_compare : (compare a b).isGE = true ↔ b ≤ a`

#### Conditional Forms
- `Nat.compare_eq_ite_le : compare a b = if a ≤ b then if b ≤ a then Ordering.eq else Ordering.lt else Ordering.gt`
- `Nat.compare_eq_ite_lt : compare a b = if a < b then Ordering.lt else if b < a then Ordering.gt else Ordering.eq`

---

## Integer Comparison

### 9. `Int.compare`
- **Type**: Derived from `Ord Int` instance
- **Module**: `Init.Data.Int.Compare`
- **Library**: Init (Core)

### Int Comparison Theorems

(Similar structure to Nat theorems)

- `Int.compare_eq_eq : compare a b = Ordering.eq ↔ a = b`
- `Int.compare_eq_lt : compare a b = Ordering.lt ↔ a < b`
- `Int.compare_eq_gt : compare a b = Ordering.gt ↔ b < a`
- `Int.compare_ne_lt : compare a b ≠ Ordering.lt ↔ b ≤ a`
- `Int.compare_ne_gt : compare a b ≠ Ordering.gt ↔ a ≤ b`
- `Int.compare_swap : (compare a b).swap = compare b a`
- `Int.isLE_compare : (compare a b).isLE = true ↔ a ≤ b`
- `Int.isGE_compare : (compare a b).isGE = true ↔ b ≤ a`
- `Int.compare_eq_ite_le : compare a b = if a ≤ b then if b ≤ a then Ordering.eq else Ordering.lt else Ordering.gt`
- `Int.compare_eq_ite_lt : compare a b = if a < b then Ordering.lt else if b < a then Ordering.gt else Ordering.eq`

---

## Array Comparison Functions

### 10. `Array.compareLex`
- **Type**: `{α : Type u_1} (cmp : α → α → Ordering) (a₁ a₂ : Array α) : Ordering`
- **Module**: `Init.Data.Ord.Array`
- **Library**: Init (Core)

### Array Comparison Theorems

- `Array.compare_eq_compareLex : compare = Array.compareLex compare`
- `Array.compareLex_eq_compareLex_toList : Array.compareLex cmp a₁ a₂ = List.compareLex cmp a₁.toList a₂.toList`
- `List.compareLex_eq_compareLex_toArray : List.compareLex cmp l₁ l₂ = Array.compareLex cmp l₁.toArray l₂.toArray`
- `Array.compare_eq_compare_toList : compare a₁ a₂ = compare a₁.toList a₂.toList`
- `List.compare_eq_compare_toArray : compare l₁ l₂ = compare l₁.toArray l₂.toArray`

---

## Vector Comparison Functions

### 11. `Vector.compareLex`
- **Type**: `{α : Type u_1} {n : ℕ} (cmp : α → α → Ordering) (a b : Vector α n) : Ordering`
- **Module**: `Init.Data.Ord.Vector`
- **Library**: Init (Core)

### Vector Comparison Theorems

- `Vector.compareLex_eq_compareLex_toArray : Vector.compareLex cmp a b = Array.compareLex cmp a.toArray b.toArray`
- `Vector.compareLex_eq_compareLex_toList : Vector.compareLex cmp a b = List.compareLex cmp a.toList b.toList`
- `Vector.compare_eq_compare_toArray : compare a b = compare a.toArray b.toArray`
- `Vector.compare_eq_compare_toList : compare a b = compare a.toList b.toList`

---

## Comparison Lawfulness and Properties

### Reflexivity

#### `Std.ReflCmp.compare_self`
- **Type**: `{α : Type u} {cmp : α → α → Ordering} [self : Std.ReflCmp cmp] {a : α} : cmp a a = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)
- **Documentation**: Comparison is reflexive

#### `Std.ReflOrd.compare_self`
- **Type**: `{α : Type u} [Ord α] [Std.ReflOrd α] {a : α} : compare a a = Ordering.eq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

### Lawful Equality

#### `Std.LawfulEqCmp.eq_of_compare`
- **Type**: `{α : Type u} {cmp : α → α → Ordering} [self : Std.LawfulEqCmp cmp] {a b : α} : cmp a b = Ordering.eq → a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)
- **Documentation**: If two values compare equal, then they are logically equal

#### `Std.LawfulEqCmp.compare_eq_iff_eq`
- **Type**: `{α : Type u} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] {a b : α} : cmp a b = Ordering.eq ↔ a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.LawfulEqOrd.eq_of_compare`
- **Type**: `{α : Type u} [Ord α] [Std.LawfulEqOrd α] {a b : α} : compare a b = Ordering.eq → a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.LawfulEqOrd.compare_eq_iff_eq`
- **Type**: `{α : Type u} [Ord α] [Std.LawfulEqOrd α] {a b : α} : compare a b = Ordering.eq ↔ a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

### Boolean Equality

#### `Std.LawfulBEqCmp.isEq_compare_eq_beq`
- **Type**: `{α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : (cmp a b).isEq = (a == b)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.LawfulBEqCmp.compare_eq_iff_beq`
- **Type**: `{α : Type u} {inst✝ : BEq α} {cmp : α → α → Ordering} [self : Std.LawfulBEqCmp cmp] {a b : α} : cmp a b = Ordering.eq ↔ (a == b) = true`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)
- **Documentation**: If two values compare equal, then they are boolean equal

#### `Std.LawfulBEqCmp.compare_beq_iff_eq`
- **Type**: `{α : Type u} {cmp : α → α → Ordering} [Std.LawfulEqCmp cmp] {a b : α} : (cmp a b == Ordering.eq) = true ↔ a = b`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.LawfulBEqCmp.compare_beq_eq_beq`
- **Type**: `{α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : (cmp a b == Ordering.eq) = (a == b)`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.LawfulBEqCmp.not_compare_eq_iff_beq_eq_false`
- **Type**: `{α : Type u} [BEq α] {cmp : α → α → Ordering} [Std.LawfulBEqCmp cmp] {a b : α} : ¬cmp a b = Ordering.eq ↔ (a == b) = false`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

### Oriented Comparison

#### Instance Declarations
- `Std.instOrientedCmpCompareOnOfOrientedOrd`
- `Std.instOrientedCmpCompareLex`
- `Array.instOrientedCmpCompareLex`
- `List.instOrientedCmpCompareLex`
- `Vector.instOrientedCmpCompareLex`

### Reflexive Comparison

#### Instance Declarations
- `Std.instReflCmpCompareOnOfReflOrd`
- `Std.instReflCmpCompareLex`
- `Array.instReflCmpCompareLex`
- `List.instReflCmpCompareLex`
- `Vector.instReflCmpCompareLex`

### Transitive Comparison

#### Instance Declarations
- `Std.instTransCmpCompareOnOfTransOrd`
- `Std.instTransCmpCompareLex`
- `Array.instTransCmpCompareLex`
- `List.instTransCmpCompareLex`
- `Vector.instTransCmpCompareLex`

#### `Std.TransOrd.compareOfLessAndEq_of_lt_trans_of_lt_iff`
- **Type**: `{α : Type u} [LT α] [DecidableLT α] [DecidableEq α] (lt_trans : ∀ {a b c : α}, a < b → b < c → a < c) (h : ∀ (x y : α), x < y ↔ ¬y < x ∧ x ≠ y) : Std.TransCmp fun x y => compareOfLessAndEq x y`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

#### `Std.TransOrd.compareOfLessAndEq_of_antisymm_of_trans_of_total_of_not_le`
- **Type**: Complex transitivity proof for `compareOfLessAndEq`
- **Module**: `Init.Data.Order.Ord`
- **Library**: Init (Core)

### Lawful Equality and Boolean Equality

#### Instance Declarations
- `Array.instLawfulEqCmpCompareLex`
- `Array.instLawfulBEqCmpCompareLex`
- `List.instLawfulEqCmpCompareLex`
- `List.instLawfulBEqCmpCompareLex`
- `Vector.instLawfulEqCmpCompareLex`
- `Vector.instLawfulBEqCmpCompareLex`

---

## Order-Related Comparison Functions

### `Std.LawfulOrderOrd.isGE_compare`
- **Type**: `{α : Type u} {inst✝ : Ord α} {inst✝¹ : LE α} [self : Std.LawfulOrderOrd α] (a b : α) : (compare a b).isGE = true ↔ b ≤ a`
- **Module**: `Init.Data.Order.ClassesExtra`
- **Library**: Init (Core)

### `Std.LawfulOrderOrd.isLE_compare`
- **Type**: `{α : Type u} {inst✝ : Ord α} {inst✝¹ : LE α} [self : Std.LawfulOrderOrd α] (a b : α) : (compare a b).isLE = true ↔ a ≤ b`
- **Module**: `Init.Data.Order.ClassesExtra`
- **Library**: Init (Core)

### `Std.LawfulOrderOrd.isGE_compare_eq_false`
- **Type**: `{α : Type u} [Ord α] [LE α] [Std.LawfulOrderOrd α] {a b : α} : (compare a b).isGE = false ↔ ¬b ≤ a`
- **Module**: `Init.Data.Order.ClassesExtra`
- **Library**: Init (Core)

### `Std.LawfulOrderOrd.isLE_compare_eq_false`
- **Type**: `{α : Type u} [Ord α] [LE α] [Std.LawfulOrderOrd α] {a b : α} : (compare a b).isLE = false ↔ ¬a ≤ b`
- **Module**: `Init.Data.Order.ClassesExtra`
- **Library**: Init (Core)

### Std Namespace Shortcuts

- `Std.isGE_compare : (compare a b).isGE = true ↔ b ≤ a`
- `Std.isLE_compare : (compare a b).isLE = true ↔ a ≤ b`
- `Std.compare_eq_gt : compare a b = Ordering.gt ↔ b < a`
- `Std.compare_eq_lt : compare a b = Ordering.lt ↔ a < b`
- `Std.compare_eq_eq : compare a b = Ordering.eq ↔ (a == b) = true`
- `Std.compare_eq_eq_iff_eq : compare a b = Ordering.eq ↔ a = b`

### Min/Max with Compare

- `Std.max_eq_if_isGE_compare : a ⊔ b = if (compare a b).isGE = true then a else b`
- `Std.min_eq_if_isLE_compare : a ⊓ b = if (compare a b).isLE = true then a else b`

---

## Package Factory Functions

### `Std.Packages.LinearOrderOfOrdArgs.eq_of_compare`
- **Type**: `{α : Type u} (self : Std.Packages.LinearOrderOfOrdArgs α) : ... ∀ (a b : α), compare a b = Ordering.eq → a = b`
- **Module**: `Init.Data.Order.PackageFactories`
- **Library**: Init (Core)

### `Std.Packages.LinearPreorderOfLEArgs.isLE_compare`
- **Type**: `{α : Type u} (self : Std.Packages.LinearPreorderOfLEArgs α) : ... ∀ (a b : α), (compare a b).isLE = true ↔ a ≤ b`
- **Module**: `Init.Data.Order.PackageFactories`
- **Library**: Init (Core)

### `Std.Packages.LinearPreorderOfLEArgs.isGE_compare`
- **Type**: `{α : Type u} (self : Std.Packages.LinearPreorderOfLEArgs α) : ... ∀ (a b : α), (compare a b).isGE = true ↔ b ≤ a`
- **Module**: `Init.Data.Order.PackageFactories`
- **Library**: Init (Core)

---

## Internal Cut Functions (Std.Data.Internal.Cut)

### `Std.Internal.instIsStrictCutCompareLt`
- **Type**: `{α : Type u} [Ord α] : Std.Internal.IsStrictCut compare fun x => Ordering.lt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Std

### `Std.Internal.instIsStrictCutCompare`
- **Type**: `{α : Type u} [Ord α] [Std.TransOrd α] {k : α} : Std.Internal.IsStrictCut compare (compare k)`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Std

### `Std.Internal.instIsStrictCutCompareThenGt`
- **Type**: `{α : Type u} [Ord α] [Std.TransOrd α] {k : α} : Std.Internal.IsStrictCut compare fun k' => (compare k k').then Ordering.gt`
- **Module**: `Std.Data.Internal.Cut`
- **Library**: Std

---

## DTreeMap Internal Comparison Functions

The `Std.Data.DTreeMap.Internal` module contains extensive comparison-related functions for internal tree operations. These are primarily used for maintaining ordered invariants in dependent tree maps.

### Key Categories:

#### 1. Ordered Comparison
- `Std.DTreeMap.Internal.Impl.Ordered.compare_left`
- `Std.DTreeMap.Internal.Impl.Ordered.compare_right`
- `Std.DTreeMap.Internal.Impl.Ordered.compare_left_beq_gt`
- `Std.DTreeMap.Internal.Impl.Ordered.compare_left_not_beq_eq`
- `Std.DTreeMap.Internal.Impl.Ordered.compare_right_not_beq_gt`

#### 2. Model Comparison
- `Std.DTreeMap.Internal.Impl.contains'_compare`
- `Std.DTreeMap.Internal.Impl.compare_ne_iff_beq_eq_false`
- `Std.DTreeMap.Internal.Impl.compare_getKey_self`
- `Std.DTreeMap.Internal.Impl.compare_getKey?_self`

#### 3. Modification Comparison
- `Std.DTreeMap.Internal.Impl.Const.compare_maxKeyD_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_minKeyD_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_maxKey!_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_minKey!_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_maxKey_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_minKey_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_maxKey?_modify_eq`
- `Std.DTreeMap.Internal.Impl.Const.compare_minKey?_modify_eq`

#### 4. Erase Operations with Comparison
- `Std.DTreeMap.Internal.Impl.maxKey?_erase!_eq_of_not_compare_eq_maxKey?`
- `Std.DTreeMap.Internal.Impl.minKey?_erase!_eq_of_not_compare_eq_minKey?`
- `Std.DTreeMap.Internal.Impl.maxKey?_erase!_eq_iff_not_compare_eq_maxKey?`
- `Std.DTreeMap.Internal.Impl.minKey?_erase!_eq_iff_not_compare_eq_minKey?`
- `Std.DTreeMap.Internal.Impl.maxKeyD_erase!_eq_of_not_compare_maxKeyD_eq`
- `Std.DTreeMap.Internal.Impl.minKeyD_erase!_eq_of_not_compare_minKeyD_eq`
- `Std.DTreeMap.Internal.Impl.maxKey!_erase!_eq_of_not_compare_maxKey!_eq`
- `Std.DTreeMap.Internal.Impl.minKey!_erase!_eq_of_not_compare_minKey!_eq`

(And many more erase-related comparison functions...)

#### 5. Alter Operations with Comparison
- `Std.DTreeMap.Internal.Impl.Const.contains_alter!_of_not_compare_eq`
- `Std.DTreeMap.Internal.Impl.contains_alter!_of_not_compare_eq`
- `Std.DTreeMap.Internal.Impl.Const.mem_alter!_of_compare_eq`
- `Std.DTreeMap.Internal.Impl.Const.mem_alter!_of_not_compare_eq`
- `Std.DTreeMap.Internal.Impl.mem_alter!_of_not_compare_eq`
- `Std.DTreeMap.Internal.Impl.mem_alter!_of_compare_eq`

(And many more alter-related comparison functions...)

#### 6. Get Operations with Comparison
- `Std.DTreeMap.Internal.Impl.Const.get?_eq_some_iff_exists_compare_eq_eq_and_mem_toList`

### DTreeMap Public API Comparison

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
- `Std.DTreeMap.minKey?_erase_eq_of_not_compare_eq_minKey?`

---

## Categorization by Library

### Init (Core LEAN Library)

**Modules**:
- `Init.Data.Ord.Basic` - Core comparison functions
- `Init.Data.Nat.Compare` - Natural number comparison
- `Init.Data.Int.Compare` - Integer comparison
- `Init.Data.Ord.Array` - Array comparison
- `Init.Data.Ord.Vector` - Vector comparison
- `Init.Data.Order.Ord` - Comparison lawfulness and properties
- `Init.Data.Order.ClassesExtra` - Additional order classes
- `Init.Data.Order.FactoriesExtra` - Order factory functions
- `Init.Data.Order.LemmasExtra` - Additional comparison lemmas
- `Init.Data.Order.PackageFactories` - Package construction with comparison

**Function Count**: ~120+ functions

### Std (Standard Library)

**Modules**:
- `Std.Data.Internal.Cut` - Internal cut operations
- `Std.Data.DTreeMap.Internal.Ordered` - DTreeMap ordering
- `Std.Data.DTreeMap.Internal.Model` - DTreeMap model operations
- `Std.Data.DTreeMap.Internal.Lemmas` - DTreeMap internal lemmas
- `Std.Data.DTreeMap.Lemmas` - DTreeMap public lemmas

**Function Count**: ~80+ functions (primarily DTreeMap-related)

---

## Usage Patterns

### 1. Basic Comparison
```lean
-- Compare two values
let result := compare 5 10  -- Ordering.lt

-- Compare with custom function
let result := compareOn (·.length) "hello" "world"  -- Ordering.eq
```

### 2. Lexicographic Comparison
```lean
-- Compare lists lexicographically
let result := List.compareLex compare [1, 2, 3] [1, 2, 4]  -- Ordering.lt

-- Combine two comparisons
let result := compareLex cmp1 cmp2 a b
```

### 3. Comparison from Order Relations
```lean
-- Build comparison from < and =
let result := compareOfLessAndEq x y

-- Build comparison from < and ==
let result := compareOfLessAndBEq x y
```

### 4. Checking Comparison Results
```lean
-- Check if less than or equal
if (compare a b).isLE then ...

-- Check if greater than or equal
if (compare a b).isGE then ...

-- Check if equal
if compare a b == Ordering.eq then ...
```

### 5. Using Comparison Properties
```lean
-- Reflexivity
have h : compare a a = Ordering.eq := Std.ReflOrd.compare_self

-- Equality implies comparison equality
have h : a = b → compare a b = Ordering.eq := ...

-- Comparison equality implies equality (for lawful types)
have h : compare a b = Ordering.eq → a = b := Std.LawfulEqOrd.eq_of_compare
```

---

## Recommendations

### For General Use

1. **Use `Ord.compare`** for comparing values of types with an `Ord` instance
2. **Use `compareOn`** when comparing by a derived property
3. **Use `compareLex`** for lexicographic comparison with tiebreaker
4. **Use type-specific comparisons** (Nat.compare, Int.compare, etc.) when working with specific types

### For Proofs

1. **Leverage comparison theorems** like `compare_eq_eq`, `compare_eq_lt`, `compare_eq_gt`
2. **Use lawfulness properties** (`LawfulEqOrd`, `LawfulBEqOrd`) to relate comparison to equality
3. **Use reflexivity, transitivity, and orientation** properties for reasoning about comparisons
4. **Use `isLE_compare` and `isGE_compare`** to relate comparison to order relations

### For Data Structures

1. **Use `compareLex` variants** for List, Array, Vector comparisons
2. **Leverage DTreeMap comparison lemmas** when working with ordered maps
3. **Use comparison invariants** to maintain ordered data structure properties

---

## Related Searches

To explore related functionality, consider these follow-up searches:

1. **Ordering type**: `"Ordering"` - Find functions working with the Ordering type
2. **Less-than comparison**: `"_ < _"` - Find theorems about less-than relations
3. **Equality comparison**: `"_ = _"` or `"_ == _"` - Find equality-related functions
4. **Ord typeclass**: `"Ord"` - Find Ord instances and related functions
5. **LawfulOrd**: `"LawfulOrd"` - Find lawfulness properties for ordered types
6. **Lexicographic**: `"Lex"` - Find lexicographic ordering functions
7. **Swap**: `"swap"` - Find functions for swapping comparison results

---

## Summary Statistics

- **Total Matches**: 546 (200 shown)
- **Primary Libraries**: Init (Core), Std
- **Key Modules**: 15+
- **Function Categories**: 10+
- **Core Functions**: 11
- **Type-Specific Comparisons**: 5 types (List, Nat, Int, Array, Vector)
- **Lawfulness Properties**: 20+ theorems
- **DTreeMap Internal**: 60+ functions

---

## Notes

1. This search returned 546 total matches, but only the first 200 are shown in this report
2. Many functions are internal implementation details (especially DTreeMap functions)
3. The comparison ecosystem is highly structured with clear lawfulness properties
4. Most comparison functions have corresponding theorems about their behavior
5. The `Ordering` type has three values: `lt`, `eq`, `gt`
6. Comparison functions are fundamental to ordered data structures in LEAN

---

## See Also

- [Loogle API Documentation](https://loogle.lean-lang.org/)
- [LEAN 4 Ord Documentation](https://leanprover-community.github.io/mathlib4_docs/Init/Data/Ord/Basic.html)
- [LEAN 4 Ordering Type](https://leanprover-community.github.io/mathlib4_docs/Init/Core.html#Ordering)
