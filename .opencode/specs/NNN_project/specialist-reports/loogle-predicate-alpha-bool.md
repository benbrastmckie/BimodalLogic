# Loogle Search Results: α → Bool (Predicate Functions)

**Type Pattern**: `α → Bool` and related predicate patterns  
**Date**: 2025-12-21  
**Matches Found**: 8 primary predicates + 1753 Decidable-related declarations  

## Executive Summary

This search explored predicate functions in LEAN 4 with type signature `α → Bool` and related patterns. Due to Loogle API limitations with Greek letter type patterns, the search focused on specific function names and concrete type instances (`List α → Bool`, `Option α → Bool`, etc.).

**Key Finding**: LEAN 4 uses a consistent naming convention for predicates and bridges between `Bool` (computational) and `Prop` (logical) through the `Decidable` typeclass.

---

## Exact Matches: Core Predicate Functions

### 1. List.isEmpty
- **Type**: `{α : Type u} : List α → Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.List.Basic`
- **Description**: Checks whether a list is empty
- **Complexity**: O(1)
- **Usage Examples**:
  ```lean
  [].isEmpty = true
  ["grape"].isEmpty = false
  ["apple", "banana"].isEmpty = false
  ```

### 2. Option.isSome
- **Type**: `{α : Type u_1} : Option α → Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.Option.Basic`
- **Description**: Returns `true` on `some x` and `false` on `none`
- **Related Declarations**: 1,627 related theorems and lemmas
- **Related Functions**:
  - `Option.isSome_none`: Proof that `none.isSome = false`
  - `Option.isSome_some`: Proof that `(some a).isSome = true`
  - `Option.get`: Extract value when `isSome = true`

### 3. Option.isNone
- **Type**: `{α : Type u_1} : Option α → Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.Option.Basic`
- **Description**: Returns `true` on `none` and `false` on `some x`
- **Related**: `Option.not_isSome` theorem

### 4. Array.isEmpty
- **Type**: `{α : Type u} (xs : Array α) : Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.Array.Basic`
- **Description**: Checks whether an array is empty (size = 0)
- **Related Declarations**: 34 related theorems
- **Usage Examples**:
  ```lean
  (#[] : Array String).isEmpty = true
  #[1, 2].isEmpty = false
  #[()].isEmpty = false
  ```
- **Related Lemmas**:
  - `Array.isEmpty_empty`: `#[].isEmpty = true`
  - `Array.isEmpty_push`: `(xs.push x).isEmpty = false`
  - `Array.isEmpty_iff`: `xs.isEmpty = true ↔ xs = #[]`

---

## Partial Matches: Higher-Order Predicates

These functions take predicates as arguments and return `Bool`:

### 5. List.all
- **Type**: `{α : Type u} : List α → (α → Bool) → Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.List.Basic`
- **Description**: Returns `true` if predicate `p` returns `true` for every element
- **Complexity**: O(|l|)
- **Short-circuits**: Yes (stops at first `false`)
- **Related Declarations**: 66 related theorems
- **Usage Examples**:
  ```lean
  [a, b, c].all p = (p a && (p b && p c))
  [2, 4, 6].all (· % 2 = 0) = true
  [2, 4, 5, 6].all (· % 2 = 0) = false
  ```

### 6. List.any
- **Type**: `{α : Type u} (l : List α) (p : α → Bool) : Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.List.Basic`
- **Description**: Returns `true` if predicate `p` returns `true` for any element
- **Complexity**: O(|l|)
- **Short-circuits**: Yes (stops at first `true`)
- **Related Declarations**: 79 related theorems
- **Usage Examples**:
  ```lean
  [2, 4, 6].any (· % 2 = 0) = true
  [2, 4, 6].any (· % 2 = 1) = false
  [2, 4, 5, 6].any (· % 2 = 1) = true
  ```

### 7. List.elem
- **Type**: `{α : Type u} [BEq α] (a : α) (l : List α) : Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.List.Basic`
- **Description**: Checks whether `a` is an element of `l` using `==`
- **Complexity**: O(|l|)
- **Typeclass Requirements**: `[BEq α]`
- **Related Declarations**: 22 related theorems
- **Note**: `List.contains` is the preferred simp normal form
- **Usage Examples**:
  ```lean
  List.elem 3 [1, 4, 2, 3, 3, 7] = true
  List.elem 5 [1, 4, 2, 3, 3, 7] = false
  ```

### 8. String.contains
- **Type**: `{ρ : Type} {σ : String.Slice → Type} [...] (s : String) (pat : ρ) [...] : Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Data.String.Search`
- **Description**: Checks whether a string has a match of the pattern `pat` anywhere
- **Note**: Generic over all currently supported patterns
- **Related Declarations**: 1 primary declaration
- **Usage Examples**:
  ```lean
  "coffee tea water".contains Char.isWhitespace = true
  "tea".contains (fun (c : Char) => c == 'X') = false
  "coffee tea water".contains "tea" = true
  ```

---

## Related Functions: Decidable Pattern

### Decidable (Type)
- **Type**: `(p : Prop) : Type`
- **Library**: Init (Lean Core)
- **Module**: `Init.Prelude`
- **Description**: Either a proof that `p` is true or a proof that `p` is false
- **Related Declarations**: 1,753 related theorems and instances
- **Note**: Equivalent to `Bool` paired with proof that `Bool` is true iff `p` is true
- **Primary Usage**: Via `if`-expressions and the `decide` tactic

### Decidable.decide
- **Type**: `(p : Prop) [h : Decidable p] : Bool`
- **Library**: Init (Lean Core)
- **Module**: `Init.Prelude`
- **Description**: Converts a decidable proposition into a `Bool`
- **Usage**: If `p : Prop` is decidable, then `decide p : Bool` is `true` iff `p` is true

---

## Naming Patterns Analysis

### State Predicates
Pattern: `is{State}` where State describes a boolean property
- `isEmpty` - checks if collection has no elements
- `isSome` - checks if Option contains a value
- `isNone` - checks if Option is empty

### Membership Predicates
Pattern: `contains` or `elem`
- `contains` - checks if element/pattern exists in collection
- `elem` - checks if element exists in list (using `BEq`)

### Quantified Predicates
Pattern: `all` or `any`
- `all` - universal quantification (∀)
- `any` - existential quantification (∃)

---

## Typeclass Requirements

### Equality-Based Predicates
- **Typeclass**: `[BEq α]`
- **Functions**: `List.elem`, `List.contains`
- **Purpose**: Boolean equality testing

### Lawful Equality
- **Typeclass**: `[LawfulBEq α]`
- **Purpose**: Ensures `BEq` respects equality laws
- **Used in**: Proofs about equality-based predicates

### Ordering-Based Predicates
- **Typeclass**: `[Ord α]`
- **Purpose**: Comparison operations
- **Note**: Not found in this search but common pattern

---

## Performance Characteristics

### Constant Time: O(1)
- `List.isEmpty`
- `Array.isEmpty`
- `Option.isSome`
- `Option.isNone`

### Linear Time: O(n)
- `List.all` - with short-circuiting
- `List.any` - with short-circuiting
- `List.elem`
- `String.contains`

### Short-Circuiting Behavior
Both `List.all` and `List.any` explicitly document short-circuiting:
- `all` stops at first `false`
- `any` stops at first `true`

This is crucial for performance with large collections.

---

## Relationship to Propositions

### Bool vs Prop Duality

LEAN 4 maintains both computational (`Bool`) and logical (`Prop`) versions of predicates:

1. **Computational**: `List.isEmpty : List α → Bool`
   - Used in programs
   - Decidable/computable
   - Returns `true` or `false`

2. **Logical**: Corresponding `Prop` versions with theorems
   - Used in proofs
   - May be undecidable
   - Proven true or false

3. **Bridge**: `Decidable` typeclass
   - Connects `Bool` and `Prop`
   - Enables `decide` tactic
   - Provides proof-carrying booleans

### Simp Lemmas

Many predicates have simp lemmas connecting boolean and propositional forms:
- `Option.isSome_none`: `none.isSome = false`
- `Option.isSome_some`: `(some a).isSome = true`
- `Array.isEmpty_iff`: `xs.isEmpty = true ↔ xs = #[]`

---

## Insights: Pattern Matching and Predicate Usage in LEAN

### 1. Consistent Design Philosophy

LEAN 4's standard library exhibits remarkable consistency in predicate design:
- **Naming**: Predictable patterns (`isEmpty`, `isSome`, `contains`)
- **Performance**: Documented complexity guarantees
- **Duality**: Both computational and logical versions

### 2. Type-Driven Development

Predicates are organized by the types they operate on:
- `List α → Bool` for list predicates
- `Option α → Bool` for option predicates
- `Array α → Bool` for array predicates

This enables type-directed search and discovery.

### 3. Typeclass Polymorphism

Predicates leverage typeclasses for generic behavior:
- `BEq α` for equality testing
- `Ord α` for ordering
- `Decidable p` for Prop-to-Bool conversion

### 4. Proof Automation Support

The extensive related declarations (1,627 for `Option.isSome`, 343 for `List.isEmpty`) indicate:
- Rich theorem libraries for reasoning about predicates
- Simp lemmas for automatic simplification
- Integration with proof tactics

### 5. Performance-Conscious Design

Explicit documentation of:
- Time complexity (O(1), O(n))
- Short-circuiting behavior
- Preferred simp normal forms

This guides users toward efficient implementations.

### 6. Pattern Matching Integration

While this search focused on predicate functions, LEAN 4's pattern matching integrates seamlessly:
- Predicates can be used in `if` conditions
- Pattern matching on `Bool` results
- `decide` tactic for decidable propositions

---

## Search Limitations

### Technical Constraints
1. **Type Pattern Searches**: Loogle doesn't directly support `α → Bool` with Greek letters
2. **Timeout Issues**: Very general patterns like `_ → Bool` timed out
3. **API Errors**: Intermittent 502 errors from Loogle API
4. **Search Strategy**: Had to use specific function names instead of pure type patterns

### Missing Predicates
Due to API limitations, could not retrieve:
- `Char.isAlpha`, `Char.isDigit`, `Char.isWhitespace`
- `Nat` predicates (prime checking, divisibility)
- Custom user-defined predicates

---

## Recommendations

### For Finding More Predicates
1. **Search by Type**: Use concrete types (`Nat → Bool`, `String → Bool`)
2. **Search by Name**: Use common predicate names (`is*`, `has*`, `contains`)
3. **Browse Modules**: Explore `Init.Data.*` and `Std.Data.*` modules
4. **Use LeanSearch**: Complement Loogle with semantic search

### For Using Predicates
1. **Prefer Standard Library**: Use built-in predicates when available
2. **Document Complexity**: Follow standard library pattern of documenting O(n)
3. **Provide Simp Lemmas**: Connect `Bool` and `Prop` versions
4. **Use Typeclasses**: Leverage `BEq`, `Ord`, `Decidable` for genericity

### For Proof Development
1. **Use `decide` Tactic**: For decidable predicates
2. **Leverage Simp Lemmas**: Automatic simplification of predicate expressions
3. **Understand Duality**: Know when to use `Bool` vs `Prop`
4. **Check Related Theorems**: Explore the extensive theorem libraries

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Primary Predicates Found | 8 |
| Total Related Declarations | 3,945+ |
| Libraries Covered | Init (Lean Core) |
| Modules Explored | 5 |
| Type Patterns Searched | 6 |

### Distribution by Type
- **List**: 4 predicates (isEmpty, all, any, elem)
- **Option**: 2 predicates (isSome, isNone)
- **Array**: 1 predicate (isEmpty)
- **String**: 1 predicate (contains)
- **Decidable**: 1,753 related declarations

---

## Conclusion

This search reveals LEAN 4's sophisticated approach to predicates:
1. **Dual Nature**: Both computational (`Bool`) and logical (`Prop`)
2. **Consistent Design**: Predictable naming and organization
3. **Rich Ecosystem**: Thousands of related theorems and lemmas
4. **Performance-Aware**: Documented complexity and optimization
5. **Type-Driven**: Organized by types and typeclasses

The `Decidable` typeclass serves as the crucial bridge between computation and logic, enabling proof automation while maintaining computational efficiency.

For pattern matching and formula testing in LEAN, these predicates provide a solid foundation with strong proof support and efficient implementations.
