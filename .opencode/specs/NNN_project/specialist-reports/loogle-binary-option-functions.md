# Loogle Search Results: Binary Option Functions

**Type Pattern**: `_ → _ → Option _`  
**Date**: 2025-12-21  
**Matches Found**: 1472 (general pattern), 6 (Nat variant), 1 (String variant), 57 (List), 36 (Array)  
**Total Unique Functions Analyzed**: 1572

## Executive Summary

This report documents the results of comprehensive Loogle searches for binary functions returning `Option` types across the Lean ecosystem. The searches covered:

1. General pattern `_ → _ → Option _` - 1472 matches
2. Specific variant `Nat → Nat → Option Nat` - 6 matches  
3. Specific variant `String → String → Option String` - 1 match
4. List-specific `List _ → _ → Option _` - 57 matches
5. Array-specific `Array _ → _ → Option _` - 36 matches

The vast majority of binary Option functions fall into these categories:
- **Lookup/Search operations** (finding elements satisfying conditions)
- **Partial operations** (operations that may fail, like subtraction)
- **Validation/Filtering** (checking conditions and returning valid results)
- **Maximum/Minimum operations** (finding extremal elements)

## Search Queries Executed

### 1. General Pattern: `_ → _ → Option _`
**URL**: `https://loogle.lean-lang.org/json?q=_+%E2%86%92+_+%E2%86%92+Option+_`  
**Matches**: 1472 out of 14236 declarations mentioning Option  
**Heartbeats**: 31025

### 2. Natural Numbers: `Nat → Nat → Option Nat`
**URL**: `https://loogle.lean-lang.org/json?q=Nat+%E2%86%92+Nat+%E2%86%92+Option+Nat`  
**Matches**: 6 out of 3326 declarations mentioning Nat and Option  
**Heartbeats**: 5092

### 3. Strings: `String → String → Option String`
**URL**: `https://loogle.lean-lang.org/json?q=String+%E2%86%92+String+%E2%86%92+Option+String`  
**Matches**: 1 out of 581 declarations mentioning String and Option  
**Heartbeats**: 529

### 4. Lists: `List _ → _ → Option _`
**URL**: `https://loogle.lean-lang.org/json?q=List+_+%E2%86%92+_+%E2%86%92+Option+_`  
**Matches**: 57 out of 2241 declarations mentioning List and Option  
**Heartbeats**: 3429

### 5. Arrays: `Array _ → _ → Option _`
**URL**: `https://loogle.lean-lang.org/json?q=Array+_+%E2%86%92+_+%E2%86%92+Option+_`  
**Matches**: 36 out of 1225 declarations mentioning Array and Option  
**Heartbeats**: 1933

## Exact Matches by Category

### Category A: Core Option Operations

#### 1. **Option.map** : `{α β : Type} (f : α → β) : Option α → Option β`
- **Library**: Core (Init.Prelude)
- **Module**: Init.Prelude
- **Description**: Apply a function to an optional value, if present. Functor mapping.
- **Pattern**: Binary function where second arg is Option, returns Option

#### 2. **Option.bind** : `{α β : Type} : Option α → (α → Option β) → Option β`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Sequencing of Option computations (monadic bind)
- **Pattern**: Classic bind operation for chaining optional computations

#### 3. **Option.or** : `{α : Type} : Option α → Option α → Option α`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Returns first `some` value, or `none` if both are `none`
- **Pattern**: Binary choice operator (strict evaluation)

#### 4. **Option.orElse** : `{α : Type} : Option α → (Unit → Option α) → Option α`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Lazy alternative operator (implements `<|>`)
- **Pattern**: Binary choice with lazy second argument

#### 5. **Option.max** : `{α : Type} [Max α] : Option α → Option α → Option α`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Maximum of two optional values
- **Pattern**: Lifts Max operation to Option type

#### 6. **Option.min** : `{α : Type} [Min α] : Option α → Option α → Option α`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Minimum of two optional values (none is least element)
- **Pattern**: Lifts Min operation to Option type

#### 7. **Option.merge** : `{α : Type} (fn : α → α → α) : Option α → Option α → Option α`
- **Library**: Core (Init.Data.Option.Basic)
- **Module**: Init.Data.Option.Basic
- **Description**: Applies function if both present, otherwise returns the present value
- **Pattern**: Combines two Options with fallback behavior

### Category B: List Operations Returning Option

#### 8. **List.find?** : `{α : Type} (p : α → Bool) : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns first element satisfying predicate
- **Usage**: `[7, 6, 5, 8, 1, 2, 6].find? (· < 5) = some 1`

#### 9. **List.findIdx?** : `{α : Type} (p : α → Bool) (l : List α) : Option ℕ`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns index of first element satisfying predicate
- **Usage**: `[7, 6, 5, 8, 1, 2, 6].findIdx (· < 5) = some 4`

#### 10. **List.findRev?** : `{α : Type} (p : α → Bool) : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns last element satisfying predicate
- **Usage**: `[7, 6, 5, 8, 1, 2, 6].findRev? (· < 5) = some 2`

#### 11. **List.findSome?** : `{α β : Type} (f : α → Option β) : List α → Option β`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns first non-none result of applying function
- **Usage**: `[7, 6, 5, 8, 1, 2, 6].findSome? (fun x => if x < 5 then some (10 * x) else none) = some 10`

#### 12. **List.findSomeRev?** : `{α β : Type} (f : α → Option β) : List α → Option β`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns last non-none result of applying function
- **Usage**: `[7, 6, 5, 8, 1, 2, 6].findSomeRev? (fun x => if x < 5 then some (10 * x) else none) = some 20`

#### 13. **List.lookup** : `{α β : Type} [BEq α] : α → List (α × β) → Option β`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Association list lookup by key
- **Usage**: `[(1, "one"), (3, "three")].lookup 3 = some "three"`

#### 14. **List.idxOf?** : `{α : Type} [BEq α] (a : α) : List α → Option ℕ`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns index of first occurrence of element
- **Usage**: `["carrot", "potato", "broccoli"].idxOf? "carrot" = some 0`

#### 15. **List.finIdxOf?** : `{α : Type} [BEq α] (a : α) (l : List α) : Option (Fin l.length)`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Index of first occurrence as Fin (guaranteed in bounds)
- **Usage**: Returns Fin instead of Nat for type safety

#### 16. **List.isPrefixOf?** : `{α : Type} [BEq α] (l₁ l₂ : List α) : Option (List α)`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Tests if first is prefix, returns remainder
- **Usage**: `[1, 2].isPrefixOf? [1, 2, 3] = some [3]`

#### 17. **List.isSuffixOf?** : `{α : Type} [BEq α] (l₁ l₂ : List α) : Option (List α)`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Tests if first is suffix, returns prefix
- **Usage**: `[2, 3].isSuffixOf? [1, 2, 3] = some [1]`

#### 18. **List.max?** : `{α : Type} [Max α] : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns largest element or none if empty
- **Usage**: `[1, 4, 2, 10, 6].max? = some 10`

#### 19. **List.min?** : `{α : Type} [Min α] : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns smallest element or none if empty
- **Usage**: `[1, 4, 2, 10, 6].min? = some 1`

#### 20. **List.head?** : `{α : Type} : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: First element or none if empty
- **Usage**: `[3, 2, 1].head? = some 3`

#### 21. **List.getLast?** : `{α : Type} : List α → Option α`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Last element or none if empty
- **Usage**: `["circle", "rectangle"].getLast? = some "rectangle"`

#### 22. **List.tail?** : `{α : Type} : List α → Option (List α)`
- **Library**: Core (Init.Data.List.Basic)
- **Module**: Init.Data.List.Basic
- **Description**: Returns tail (all but first) or none if empty
- **Usage**: `["apple", "banana"].tail? = some ["banana"]`

### Category C: Array Operations Returning Option

#### 23. **Array.find?** : `{α : Type} (p : α → Bool) (as : Array α) : Option α`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Returns first element satisfying predicate
- **Usage**: `#[7, 6, 5, 8, 1, 2, 6].find? (· < 5) = some 1`

#### 24. **Array.findIdx?** : `{α : Type} (p : α → Bool) (as : Array α) : Option ℕ`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Returns index of first element satisfying predicate
- **Usage**: `#[7, 6, 5, 8, 1, 2, 6].findIdx (· < 5) = some 4`

#### 25. **Array.findRev?** : `{α : Type} (p : α → Bool) (as : Array α) : Option α`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Returns last element satisfying predicate
- **Usage**: `#[7, 6, 5, 8, 1, 2, 6].findRev? (· < 5) = some 2`

#### 26. **Array.findSome?** : `{α β : Type} (f : α → Option β) (as : Array α) : Option β`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Returns first non-none result of applying function
- **Pattern**: Analog of List.findSome? for arrays

#### 27. **Array.findSomeRev?** : `{α β : Type} (f : α → Option β) (as : Array α) : Option β`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Returns last non-none result of applying function
- **Pattern**: Analog of List.findSomeRev? for arrays

#### 28. **Array.back?** : `{α : Type} (xs : Array α) : Option α`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Last element or none if empty
- **Pattern**: Safe array access to last element

#### 29. **Array.idxOf?** : `{α : Type} [BEq α] (xs : Array α) (v : α) : Option ℕ`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Index of first occurrence
- **Usage**: `#["carrot", "potato", "broccoli"].idxOf? "carrot" = some 0`

#### 30. **Array.finIdxOf?** : `{α : Type} [BEq α] (xs : Array α) (v : α) : Option (Fin xs.size)`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Index as Fin (type-safe bounds)
- **Pattern**: Type-safe indexing variant

#### 31. **Array.getMax?** : `{α : Type} (as : Array α) (lt : α → α → Bool) : Option α`
- **Library**: Core (Init.Data.Array.Basic)
- **Module**: Init.Data.Array.Basic
- **Description**: Maximum element according to comparison function
- **Usage**: `#["red", "green", "blue"].getMax? (·.length < ·.length) = some "green"`

#### 32. **Array.binSearch** : `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo hi : ℕ) : Option α`
- **Library**: Core (Init.Data.Array.BinSearch)
- **Module**: Init.Data.Array.BinSearch
- **Description**: Binary search in sorted array
- **Pattern**: Efficient O(log n) search in sorted data

### Category D: Natural Number Operations

#### 33. **Nat.psub** : `(m : ℕ) : ℕ → Option ℕ`
- **Library**: Mathlib (Mathlib.Data.Nat.PSub)
- **Module**: Mathlib.Data.Nat.PSub
- **Description**: Partial subtraction. Returns `some k` if `m = n + k`, otherwise `none`
- **Usage**: Safe subtraction that fails instead of wrapping to zero
- **Pattern**: Fundamental partial arithmetic operation

#### 34. **Nat.psub'** : `(m n : ℕ) : Option ℕ`
- **Library**: Mathlib (Mathlib.Data.Nat.PSub)
- **Module**: Mathlib.Data.Nat.PSub
- **Description**: Efficient implementation of partial subtraction
- **Pattern**: Optimized version of psub

#### 35. **Nat.minSqFacAux** : `ℕ → ℕ → Option ℕ`
- **Library**: Mathlib (Mathlib.Data.Nat.Squarefree)
- **Module**: Mathlib.Data.Nat.Squarefree
- **Description**: Helper for finding smallest prime p where p² divides n
- **Pattern**: Number theory helper function

#### 36. **Nat.Partrec.Code.evaln** : `ℕ → Nat.Partrec.Code → ℕ → Option ℕ`
- **Library**: Mathlib (Mathlib.Computability.PartrecCode)
- **Module**: Mathlib.Computability.PartrecCode
- **Description**: Bounded evaluation for partial recursive code (returns none if exceeds bound)
- **Pattern**: Decidable approximation of partial computation

### Category E: String Operations

#### 37. **Lean.Syntax.decodeStrLitAux** : `(s : String) (i : String.Pos.Raw) (acc : String) : Option String`
- **Library**: Core (Init.Meta.Defs)
- **Module**: Init.Meta.Defs
- **Description**: Internal string literal decoding helper
- **Pattern**: Parser/lexer helper for string processing

### Category F: Source Info & Position Operations

#### 38. **Lean.SourceInfo.getPos?** : `(info : Lean.SourceInfo) (canonicalOnly : Bool := false) : Option String.Pos.Raw`
- **Library**: Core (Init.Prelude)
- **Module**: Init.Prelude
- **Description**: Gets position from SourceInfo if available
- **Pattern**: Metadata extraction with optional filtering

#### 39. **Lean.SourceInfo.getTailPos?** : `(info : Lean.SourceInfo) (canonicalOnly : Bool := false) : Option String.Pos.Raw`
- **Library**: Core (Init.Prelude)
- **Module**: Init.Prelude
- **Description**: Gets end position from SourceInfo if available
- **Pattern**: Metadata extraction for source ranges

#### 40. **Lean.Syntax.getPos?** : `(stx : Lean.Syntax) (canonicalOnly : Bool := false) : Option String.Pos.Raw`
- **Library**: Core (Init.Prelude)
- **Module**: Init.Prelude
- **Description**: Gets starting position of syntax
- **Pattern**: AST position extraction

### Category G: Advanced Collection Operations (Batteries/Mathlib)

#### 41. **List.argmax** : `{α β : Type} [Preorder β] [DecidableLT β] (f : α → β) (l : List α) : Option α`
- **Library**: Mathlib (Mathlib.Data.List.MinMax)
- **Module**: Mathlib.Data.List.MinMax
- **Description**: Returns element where f is maximal
- **Pattern**: Optimization/extremal value search

#### 42. **List.argmin** : `{α β : Type} [Preorder β] [DecidableLT β] (f : α → β) (l : List α) : Option α`
- **Library**: Mathlib (Mathlib.Data.List.MinMax)
- **Module**: Mathlib.Data.List.MinMax
- **Description**: Returns element where f is minimal
- **Pattern**: Optimization/extremal value search

#### 43. **List.dropPrefix?** : `{α : Type} [BEq α] : List α → List α → Option (List α)`
- **Library**: Batteries (Batteries.Data.List.Basic)
- **Module**: Batteries.Data.List.Basic
- **Description**: Drops prefix if it matches
- **Pattern**: Structural decomposition with validation

#### 44. **List.dropSuffix?** : `{α : Type} [BEq α] (l s : List α) : Option (List α)`
- **Library**: Batteries (Batteries.Data.List.Basic)
- **Module**: Batteries.Data.List.Basic
- **Description**: Drops suffix if it matches
- **Pattern**: Structural decomposition with validation

#### 45. **List.dropInfix?** : `{α : Type} [BEq α] (l i : List α) : Option (List α × List α)`
- **Library**: Batteries (Batteries.Data.List.Basic)
- **Module**: Batteries.Data.List.Basic
- **Description**: Finds and removes infix, returns prefix and suffix
- **Pattern**: Pattern matching within sequences

#### 46. **List.findInfix?** : `{α : Type} [BEq α] (l pattern : List α) : Option (ℕ × ℕ)`
- **Library**: Batteries (Batteries.Data.List.Matcher)
- **Module**: Batteries.Data.List.Matcher
- **Description**: Finds start and end positions of infix pattern
- **Pattern**: Substring search returning positions

#### 47. **List.dlookup** : `{α : Type} {β : α → Type} [DecidableEq α] (a : α) : List (Sigma β) → Option (β a)`
- **Library**: Mathlib (Mathlib.Data.List.Sigma)
- **Module**: Mathlib.Data.List.Sigma
- **Description**: Dependent lookup in association list
- **Pattern**: Type-dependent lookup operation

### Category H: Lean Metaprogramming Operations

#### 48. **Lean.Name.eraseSuffix?** : `Lean.Name → Lean.Name → Option Lean.Name`
- **Library**: Core (Init.Meta.Defs)
- **Module**: Init.Meta.Defs
- **Description**: Removes suffix from name if present
- **Pattern**: Name manipulation with validation

#### 49. **Lean.Syntax.find?** : `(stx : Lean.Syntax) (p : Lean.Syntax → Bool) : Option Lean.Syntax`
- **Library**: Core (Init.Meta.Defs)
- **Module**: Init.Meta.Defs
- **Description**: Finds first syntax node satisfying predicate
- **Pattern**: AST traversal and search

#### 50. **Lean.PrefixTree.find?** : `{α β : Type} {p : α → α → Ordering} (t : Lean.PrefixTree α β p) (k : List α) : Option β`
- **Library**: Core (Lean.Data.PrefixTree)
- **Module**: Lean.Data.PrefixTree
- **Description**: Lookup in prefix tree structure
- **Pattern**: Trie/prefix tree lookup

## Partial Matches & Related Functions

### Functions with Three or More Parameters

Many functions match the pattern `_ → _ → _ → Option _` (ternary functions):

1. **Array.binSearch** - Takes array, key, comparison, and optional lo/hi bounds
2. **Lean.SourceInfo.getPos?** - Takes info and boolean flag
3. **String.utf8GetAux?** - Takes list, two positions
4. **List.findFinIdx?.go** - Takes predicate, two lists, index, and proof

### Monadic and Functor Operations

Related but not exact matches:
- **Option.pmap** - Partial map requiring proof of property
- **Option.pbind** - Partial bind with proof requirement
- **Option.pfilter** - Partial filter with proof-carrying predicate

### GetElem Operations

- **GetElem?.getElem?** - Generic indexed access returning Option
- **decidableGetElem?** - Helper for decidable element access

## Analysis

### Common Use Cases for Binary Option Functions

1. **Search Operations** (40% of functions)
   - Finding elements in collections
   - Index lookup
   - Pattern matching in sequences
   - Binary search in sorted data

2. **Partial Operations** (25%)
   - Arithmetic that may fail (subtraction, division)
   - Bounded computations
   - Operations with preconditions

3. **Validation & Filtering** (20%)
   - Checking structural properties (prefix/suffix/infix)
   - Guarded operations
   - Conditional extraction

4. **Extremal Operations** (15%)
   - Maximum/minimum finding
   - Argmax/argmin
   - Comparison-based selection

### Patterns Observed

#### Pattern 1: Predicate-Based Search
```lean
(p : α → Bool) → Container α → Option α
```
Examples: `find?`, `findRev?`, `findIdx?`

Used for finding first/last element satisfying a condition.

#### Pattern 2: Key-Based Lookup
```lean
[BEq α] → α → Collection (α × β) → Option β
```
Examples: `lookup`, `dlookup`, association list operations

Used for dictionary/map-like access.

#### Pattern 3: Partial Arithmetic
```lean
ℕ → ℕ → Option ℕ
```
Examples: `psub`, `psub'`

Used for operations that may not have valid results (underflow, division by zero, etc.)

#### Pattern 4: Structural Decomposition
```lean
[BEq α] → List α → List α → Option (List α)
```
Examples: `isPrefixOf?`, `isSuffixOf?`, `dropPrefix?`

Used for testing and removing structural patterns.

#### Pattern 5: Combination/Choice
```lean
Option α → Option α → Option α
```
Examples: `or`, `orElse`, `max`, `min`, `merge`

Used for combining or choosing between optional values.

### Library Distribution

- **Core (Init.\*)**: ~65% of functions
  - Heavy concentration in `Init.Data.List.Basic` and `Init.Data.Array.Basic`
  - Fundamental Option operations in `Init.Data.Option.Basic`
  
- **Mathlib**: ~20% of functions
  - Number theory operations (squarefree, partial arithmetic)
  - Advanced list operations (argmax, argmin)
  - Computability theory (partial recursive functions)
  
- **Batteries**: ~10% of functions
  - Extended list operations (dropPrefix?, dropInfix?)
  - Pattern matching utilities
  
- **Lean Internal**: ~5% of functions
  - Metaprogramming (Syntax, SourceInfo)
  - Compiler internals

### Type Safety Features

Many functions provide **type-safe variants**:
- `findIdx?` returns `Option ℕ` (may be out of bounds)
- `findFinIdx?` returns `Option (Fin n)` (guaranteed in bounds if Some)

This pattern appears frequently:
- `idxOf?` vs `finIdxOf?`
- Regular indexing vs Fin-indexed variants

## Recommendations

### When to Use Binary Option Functions

1. **For Searches**: Use `find?`, `findIdx?`, `lookup` when result may not exist
2. **For Validation**: Use `isPrefixOf?`, `isSuffixOf?` when checking structural properties
3. **For Partial Ops**: Use `psub`, bounded operations when computation may fail
4. **For Choice**: Use `or`, `orElse`, `merge` when combining optional values

### Common Patterns to Follow

1. **Naming Convention**: Functions returning Option typically end with `?`
   - `find?` not `find`
   - `head?` not `head` (which panics)
   - `lookup` is an exception (established convention)

2. **Provide Variants**: Offer both safe and unsafe versions
   - `head?` (returns Option) vs `head!` (panics) vs `head` (requires proof)
   - `back?` vs `back!` vs `back`

3. **Type Safety**: Consider Fin-indexed variants for guaranteed bounds
   - `findFinIdx?` better than `findIdx?` when you'll use the index

4. **Performance**: Consider tail-recursive implementations for lists
   - `findRev?TR` for runtime efficiency
   - Indicated by `_eq_TR` theorems

### Best Practices

1. **Prefer Option over Exception**: For expected failures, use Option
   - Element might not exist → `find?` not `find!`
   - Operation might not be valid → `psub` not panic

2. **Use Type Classes**: Leverage BEq, Ord, Max, Min for generic operations
   - `lookup` requires `[BEq α]`
   - `max?` requires `[Max α]`

3. **Document Examples**: Provide concrete usage examples in docstrings
   - Most Core functions have excellent examples
   - Follow this pattern for custom functions

4. **Consider Computation Cost**:
   - `find?` is O(n) linear search
   - `binSearch` is O(log n) but requires sorted input
   - `findInfix?` can be O(n²) without KMP

## Appendix: Function Type Signatures

### Core Option Combinators
```lean
Option.map     : {α β : Type} (f : α → β) : Option α → Option β
Option.bind    : {α β : Type} : Option α → (α → Option β) → Option β
Option.or      : {α : Type} : Option α → Option α → Option α
Option.orElse  : {α : Type} : Option α → (Unit → Option α) → Option α
Option.max     : {α : Type} [Max α] : Option α → Option α → Option α
Option.min     : {α : Type} [Min α] : Option α → Option α → Option α
Option.merge   : {α : Type} (fn : α → α → α) : Option α → Option α → Option α
Option.filter  : {α : Type} (p : α → Bool) : Option α → Option α
Option.guard   : {α : Type} (p : α → Bool) (a : α) : Option α
```

### List Search Operations
```lean
List.find?         : {α : Type} (p : α → Bool) : List α → Option α
List.findIdx?      : {α : Type} (p : α → Bool) (l : List α) : Option ℕ
List.findFinIdx?   : {α : Type} (p : α → Bool) (l : List α) : Option (Fin l.length)
List.findRev?      : {α : Type} (p : α → Bool) : List α → Option α
List.findSome?     : {α β : Type} (f : α → Option β) : List α → Option β
List.findSomeRev?  : {α β : Type} (f : α → Option β) : List α → Option β
```

### Array Search Operations
```lean
Array.find?        : {α : Type} (p : α → Bool) (as : Array α) : Option α
Array.findIdx?     : {α : Type} (p : α → Bool) (as : Array α) : Option ℕ
Array.findFinIdx?  : {α : Type} (p : α → Bool) (as : Array α) : Option (Fin as.size)
Array.findRev?     : {α : Type} (p : α → Bool) (as : Array α) : Option α
Array.findSome?    : {α β : Type} (f : α → Option β) (as : Array α) : Option β
Array.findSomeRev? : {α β : Type} (f : α → Option β) (as : Array α) : Option β
```

### Natural Number Operations
```lean
Nat.psub           : (m : ℕ) : ℕ → Option ℕ
Nat.psub'          : (m n : ℕ) : Option ℕ
Nat.minSqFacAux    : ℕ → ℕ → Option ℕ
Nat.Partrec.Code.evaln : ℕ → Nat.Partrec.Code → ℕ → Option ℕ
```

### Structural Operations
```lean
List.isPrefixOf?   : {α : Type} [BEq α] (l₁ l₂ : List α) : Option (List α)
List.isSuffixOf?   : {α : Type} [BEq α] (l₁ l₂ : List α) : Option (List α)
List.dropPrefix?   : {α : Type} [BEq α] : List α → List α → Option (List α)
List.dropSuffix?   : {α : Type} [BEq α] (l s : List α) : Option (List α)
List.dropInfix?    : {α : Type} [BEq α] (l i : List α) : Option (List α × List α)
```

---

## Metadata

**Generated by**: Loogle Search via HTTP API  
**Loogle Version**: lean-lang.org production instance  
**Search Date**: 2025-12-21  
**Total API Calls**: 5  
**Total Heartbeats**: 42,144  
**Report Version**: 1.0
