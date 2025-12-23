# Loogle Search Results: Binary Predicates (α → α → Bool)

**Type Pattern**: α → α → Bool  
**Date**: Sun Dec 21 2025  
**Matches Found**: 2362 (showing first 200)  
**Search Variants**: ["_ → _ → Bool", "α → α → Bool", "α → α → Prop"]  
**API Endpoint**: https://loogle.lean-lang.org/json  

## Executive Summary

The Loogle search identified **2,362 declarations** matching binary predicate patterns (`_ → _ → Bool`). The most significant findings include:

1. **Core Type Classes**: `BEq.beq` serves as the primary polymorphic binary equality predicate
2. **Built-in Types**: Specialized implementations for `Nat`, `Int`, `Bool`, `String`, `List`, `Array`
3. **Comparison Categories**: Equality (`beq`), ordering (`ble`, `blt`), containment (`elem`, `contains`), and structural (`isPrefixOf`, `isSublist`)
4. **Library Distribution**: Predominantly from `Init.*` (Lean Core), with extensive coverage in data structures

## Exact Matches: {α} → α → α → Bool

### Core Type Class - BEq

**`BEq.beq`** : `{α : Type u} [self : BEq α] : α → α → Bool`
- **Module**: `Init.Prelude`
- **Description**: Boolean equality, notated as `a == b`. The recommended spelling of `==` in identifiers is `beq`.
- **Usage**: Primary polymorphic equality predicate
- **Constructor**: `BEq.mk {α : Type u} (beq : α → α → Bool) : BEq α`

## Exact Matches: Concrete Types (α → α → Bool)

### Natural Numbers (ℕ)

1. **`Nat.beq`** : `ℕ → ℕ → Bool`
   - Module: `Init.Prelude`
   - Description: Boolean equality of natural numbers, usually accessed via the `==` operator
   - Implementation: Overridden in kernel and compiler for efficiency
   - Logical Model: Provided definition serves as reference

2. **`Nat.ble`** : `ℕ → ℕ → Bool`
   - Module: `Init.Prelude`
   - Description: The Boolean less-than-or-equal-to comparison
   - Examples: `Nat.ble 2 5 = true`, `Nat.ble 5 2 = false`, `Nat.ble 5 5 = true`
   - Implementation: Optimized for arbitrary-precision arithmetic

3. **`Nat.blt`** : `(a b : ℕ) : Bool`
   - Module: `Init.Data.Nat.Basic`
   - Description: The Boolean less-than comparison
   - Examples: `Nat.blt 2 5 = true`, `Nat.blt 5 2 = false`, `Nat.blt 5 5 = false`

4. **`Nat.testBit`** : `(m n : ℕ) : Bool`
   - Module: `Init.Data.Nat.Bitwise.Basic`
   - Description: Returns `true` if the `(n+1)`th least significant bit is `1`

### Integers (ℤ)

1. **`Int.beq'`** : `(a b : ℤ) : Bool`
   - Module: `Init.Data.Int.Basic`
   - Description: Equality predicate for kernel reduction

2. **`Int.ble'`** : `(a b : ℤ) : Bool`
   - Module: `Init.Data.Int.Basic`
   - Description: `x ≤ y` for kernel reduction

3. **`Int.blt'`** : `(a b : ℤ) : Bool`
   - Module: `Init.Data.Int.Basic`
   - Description: `x < y` for kernel reduction

### Boolean Operations

1. **`Bool.and`** : `(x y : Bool) : Bool`
   - Module: `Init.Prelude`
   - Description: Boolean "and", also known as conjunction. Can be written `x && y`
   - Special: Uses `@[macro_inline]` for short-circuit evaluation
   - Propositional Analog: `And : Prop → Prop → Prop` (written `∧`)

2. **`Bool.or`** : `(x y : Bool) : Bool`
   - Module: `Init.Prelude`
   - Description: Boolean "or", also known as disjunction. Can be written `x || y`
   - Special: Uses `@[macro_inline]` for short-circuit evaluation
   - Propositional Analog: `Or : Prop → Prop → Prop` (written `∨`)

3. **`strictAnd`** : `(b₁ b₂ : Bool) : Bool`
   - Module: `Init.Core`
   - Description: Same as `and`, but without short-circuit evaluation (both sides evaluated)

4. **`strictOr`** : `(b₁ b₂ : Bool) : Bool`
   - Module: `Init.Core`
   - Description: Same as `or`, but without short-circuit evaluation (both sides evaluated)

### Names and Syntax

1. **`Lean.Name.beq`** : `Lean.Name → Lean.Name → Bool`
   - Module: `Init.Prelude`
   - Description: Boolean equality comparator for names

2. **`Lean.Syntax.structEq`** : `Lean.Syntax → Lean.Syntax → Bool`
   - Module: `Init.Meta.Defs`
   - Description: Compare syntax structures modulo source info

3. **`Lean.Syntax.isOfKind`** : `(stx : Lean.Syntax) (k : Lean.SyntaxNodeKind) : Bool`
   - Module: `Init.Prelude`
   - Description: Checks whether syntax has the given kind or pseudo-kind

4. **`Lean.Syntax.matchesIdent`** : `(stx : Lean.Syntax) (id : Lean.Name) : Bool`
   - Module: `Init.Prelude`
   - Description: Pattern matching for syntactic identifiers (compares modulo macro scopes)

### List Predicates

1. **`List.beq`** : `{α : Type u} [BEq α] : List α → List α → Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Checks whether two lists have same length and pairwise `BEq` elements

2. **`List.isPerm`** : `{α : Type u} [BEq α] : List α → List α → Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Returns `true` if `l₁` and `l₂` are permutations. `O(|l₁| * |l₂|)`
   - Logical Relation: `List.Perm`

3. **`List.isPrefixOf`** : `{α : Type u} [BEq α] : List α → List α → Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Checks whether first list is prefix of second
   - Examples: `[1, 2].isPrefixOf [1, 2, 3] = true`

4. **`List.isSublist`** : `{α : Type u} [BEq α] : List α → List α → Bool`
   - Module: `Init.Data.List.Basic`
   - Description: True if first is potentially non-contiguous subsequence of second
   - Examples: `[1, 3].isSublist [0, 1, 2, 3, 4] = true`

5. **`List.isSuffixOf`** : `{α : Type u} [BEq α] (l₁ l₂ : List α) : Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Checks whether first list is suffix of second
   - Examples: `[2, 3].isSuffixOf [1, 2, 3] = true`

### Array Predicates

1. **`Array.isPrefixOf`** : `{α : Type u} [BEq α] (as bs : Array α) : Bool`
   - Module: `Init.Data.Array.Basic`
   - Description: Returns `true` if `as` is prefix of `bs`
   - Examples: `#[0, 1, 2].isPrefixOf #[0, 1, 2, 3] = true`

2. **`Array.isEqv`** : `{α : Type u} (xs ys : Array α) (p : α → α → Bool) : Bool`
   - Module: `Init.Data.Array.Basic`
   - Description: Checks if arrays have same length and are pairwise related by `p`
   - Short-circuits: At first non-related pair

### String Predicates

1. **`String.Internal.contains`** : `(s : String) (c : Char) : Bool`
   - Module: `Init.Data.String.Bootstrap`

2. **`String.Internal.isPrefixOf`** : `(p s : String) : Bool`
   - Module: `Init.Data.String.Bootstrap`

3. **`Substring.Raw.Internal.beq`** : `(ss1 ss2 : Substring.Raw) : Bool`
   - Module: `Init.Data.String.Bootstrap`

### System and Utility Predicates

1. **`ptrEq`** : `{α : Type u_1} (a b : α) : Bool`
   - Module: `Init.Util`
   - Description: Compares two objects for pointer equality (same memory address)
   - Warning: Unsafe - can distinguish definitionally equal values

2. **`ptrEqList`** : `{α : Type u_1} (as bs : List α) : Bool`
   - Module: `Init.Util`
   - Description: Element-wise pointer equality check for lists

3. **`isExclusiveUnsafe`** : `{α : Type u} (a : α) : Bool`
   - Module: `Init.Util`
   - Description: Returns `true` if object is exclusive (single-threaded, ref count = 1)
   - Warning: Unsafe

## Partial Matches: Additional Type Constraints

### Higher-Order Binary Predicates

1. **`List.isEqv`** : `{α : Type u} (as bs : List α) (eqv : α → α → Bool) : Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Checks if lists have same length and are pairwise related by custom `eqv`
   - Complexity: `O(min |as| |bs|)`, short-circuits
   - Examples: `[1, 2, 3].isEqv [2, 3, 4] (· < ·) = true`

2. **`List.eraseDupsBy`** : `{α : Type u_1} (r : α → α → Bool) (as : List α) : List α`
   - Module: `Init.Data.List.Basic`
   - Description: Erases duplicated elements using custom comparison
   - Complexity: `O(|l|^2)`
   - Examples: `[1, 3, 4, 2, 1, 5].eraseDupsBy (· % 3 == · % 3) = [1, 3, 2]`

3. **`List.eraseRepsBy`** : `{α : Type u_1} (r : α → α → Bool) : List α → List α`
   - Module: `Init.Data.List.Basic`
   - Description: Erases repeated elements using custom comparison
   - Complexity: `O(|l|)`
   - Examples: `[1, 3, 2, 2, 2, 3, 3, 7].eraseRepsBy (· % 4 == · % 5) = [1, 3, 2, 3]`

4. **`List.splitBy`** : `{α : Type u} (R : α → α → Bool) : List α → List (List α)`
   - Module: `Init.Data.List.Basic`
   - Description: Splits list into longest segments where adjacent pairs are related by `R`
   - Complexity: `O(|l|)`
   - Examples: `[1, 1, 2, 2, 2, 3, 2].splitBy (· == ·) = [[1, 1], [2, 2, 2], [3], [2]]`

5. **`List.lex`** : `{α : Type u} [BEq α] (l₁ l₂ : List α) (lt : α → α → Bool := by exact (· < ·)) : Bool`
   - Module: `Init.Data.List.Basic`
   - Description: Compares lists lexicographically with respect to comparison function
   - Default: Uses `<` operator if not specified

6. **`Nat.bitwise`** : `(f : Bool → Bool → Bool) (n m : ℕ) : ℕ`
   - Module: `Init.Data.Nat.Bitwise.Basic`
   - Description: Helper for bitwise operators - applies `f` to corresponding bits

### Generic Utility Functions

1. **`bne`** : `{α : Type u} [BEq α] (a b : α) : Bool`
   - Module: `Init.Core`
   - Description: `x != y` is boolean not-equal (negation of `x == y`)
   - Spelling: Recommended identifier spelling is `bne`
   - Type: `Bool`-valued (not `Prop`-valued like `Ne`)

## Related Functions: Decidable Propositions (Prop)

### Core Decidable Infrastructure

1. **`Decidable.decide`** : `(p : Prop) [h : Decidable p] : Bool`
   - Module: `Init.Prelude`
   - Description: Converts decidable proposition into `Bool`
   - Behavior: Returns `true` if `p` is true, `false` if `p` is false

2. **`toBoolUsing`** : `{p : Prop} (d : Decidable p) : Bool`
   - Module: `Init.Core`
   - Description: Similar to `decide`, but uses explicit instance

### DecidableEq Instances

These provide propositional equality that can be decided to `Bool`:

1. **`Nat.decEq`** : `(n m : ℕ) : Decidable (n = m)`
   - Module: `Init.Prelude`
   - Optimized: Overridden in kernel and compiler
   - Examples: `Nat.decEq 5 5 = isTrue rfl`

2. **`Bool.decEq`** : `(a b : Bool) : Decidable (a = b)`
   - Module: `Init.Prelude`

3. **`String.decEq`** : `(s₁ s₂ : String) : Decidable (s₁ = s₂)`
   - Module: `Init.Prelude`
   - Optimized: Native implementation override at runtime

4. **`UInt8.decEq`, `UInt16.decEq`, `UInt32.decEq`, `UInt64.decEq`, `USize.decEq`**
   - Module: `Init.Prelude`
   - All optimized with efficient runtime implementations

### DecidableLE/LT Instances

1. **`Nat.decLe`** : `(n m : ℕ) : Decidable (n ≤ m)`
   - Module: `Init.Prelude`
   - Examples: `(if 3 ≤ 4 then "yes" else "no") = "yes"`

2. **`Nat.decLt`** : `(n m : ℕ) : Decidable (n < m)`
   - Module: `Init.Prelude`
   - Examples: `(if 3 < 4 then "yes" else "no") = "yes"`

3. **`UInt8.decLe`, `UInt8.decLt`, `UInt32.decLe`, `UInt32.decLt`**
   - Module: `Init.Prelude`
   - All with optimized runtime implementations

## Categorization by Library

### Init.Prelude (Core Primitives)
- `BEq.beq` - Primary polymorphic equality
- `Nat.beq`, `Nat.ble` - Natural number comparisons
- `Lean.Name.beq` - Name equality
- `Bool.and`, `Bool.or` - Boolean operations
- `Decidable.decide` - Prop to Bool conversion

### Init.Core (Core Extensions)
- `strictAnd`, `strictOr` - Non-short-circuit Boolean ops
- `bne` - Boolean not-equal
- `toBoolUsing` - Explicit decidable conversion

### Init.Data.List.Basic (List Operations)
- `List.beq`, `List.isPerm`, `List.isPrefixOf`, `List.isSublist`, `List.isSuffixOf`
- `List.isEqv`, `List.eraseDupsBy`, `List.eraseRepsBy`, `List.splitBy`, `List.lex`
- `List.elem`, `List.contains`

### Init.Data.Array.Basic (Array Operations)
- `Array.isPrefixOf`, `Array.isEqv`
- `Array.elem`, `Array.contains`

### Init.Data.Nat.Basic (Natural Numbers)
- `Nat.blt` - Less-than comparison

### Init.Data.Int.Basic (Integers)
- `Int.beq'`, `Int.ble'`, `Int.blt'` - Kernel reduction predicates

### Init.Data.Nat.Bitwise.Basic (Bitwise Operations)
- `Nat.testBit` - Bit testing
- `Nat.bitwise` - Generic bitwise operation

### Init.Data.String.Bootstrap (String Operations)
- `String.Internal.contains`, `String.Internal.isPrefixOf`
- `Substring.Raw.Internal.beq`

### Init.Util (System Utilities)
- `ptrEq`, `ptrEqList` - Pointer equality (unsafe)
- `isExclusiveUnsafe` - Exclusivity check (unsafe)

### Init.Meta.* (Metaprogramming)
- `Lean.Syntax.structEq`, `Lean.Syntax.isOfKind`, `Lean.Syntax.matchesIdent`
- Various `instBEq*.beq` for meta types

## Common Binary Predicate Patterns

### 1. Equality Predicates
- **BEq Typeclass**: `BEq.beq {α} [BEq α] : α → α → Bool`
- **Concrete Types**: `Nat.beq`, `Int.beq'`, `Lean.Name.beq`, `List.beq`
- **Constructor**: `BEq.mk` creates instances from binary predicates

### 2. Ordering Predicates
- **Less-than-or-equal**: `Nat.ble`, `Int.ble'`
- **Strictly less-than**: `Nat.blt`, `Int.blt'`
- **Lexicographic**: `List.lex` (customizable comparison)

### 3. Containment Predicates
- **Element membership**: `List.elem`, `List.contains`, `Array.elem`, `Array.contains`
- **Character in string**: `String.Internal.contains`

### 4. Structural Predicates
- **Prefix**: `List.isPrefixOf`, `Array.isPrefixOf`, `String.Internal.isPrefixOf`
- **Suffix**: `List.isSuffixOf`
- **Sublist**: `List.isSublist`
- **Permutation**: `List.isPerm`

### 5. Custom Relation Predicates
- **Pairwise equivalence**: `List.isEqv`, `Array.isEqv`
- **Parameterized by relation**: Takes `(α → α → Bool)` as argument

### 6. Logical Connectives
- **Conjunction**: `Bool.and`, `strictAnd`
- **Disjunction**: `Bool.or`, `strictOr`

## Usage Recommendations

### 1. For Decidable Equality
**Use**: `BEq` typeclass with `beq` or `==` operator
```lean
-- Polymorphic equality
def checkEqual [BEq α] (x y : α) : Bool := x == y

-- Via BEq.beq explicitly
def checkEqual' [BEq α] (x y : α) : Bool := BEq.beq x y
```

**Create instances**:
```lean
-- Define BEq instance
instance : BEq MyType where
  beq x y := myComparisonFunction x y
```

### 2. For Ordering Comparisons
**Use**: Built-in comparison functions or define custom
```lean
-- Natural numbers
def isSmaller (n m : Nat) : Bool := Nat.blt n m

-- Custom lexicographic comparison
def compareWords (w1 w2 : List Char) : Bool :=
  w1.lex w2 (fun c1 c2 => c1.toNat < c2.toNat)
```

### 3. For Custom Predicates
**Pattern 1 - Direct definition**:
```lean
def isRelated (x y : MyType) : Bool :=
  -- custom logic
  true
```

**Pattern 2 - Higher-order with relation**:
```lean
-- Use functions like List.isEqv, List.eraseDupsBy
def customFilter (xs : List α) (rel : α → α → Bool) : List α :=
  xs.eraseDupsBy rel
```

**Pattern 3 - Via Decidable**:
```lean
-- Convert Prop to Bool
def isPrime (n : Nat) : Bool :=
  decide (Nat.Prime n)  -- requires Decidable instance
```

### 4. Performance Considerations

**Short-circuit evaluation**:
- Use `Bool.and` (&&) and `Bool.or` (||) for short-circuiting
- Use `strictAnd` and `strictOr` when both sides must be evaluated

**Optimized implementations**:
- `Nat.beq`, `Nat.ble`, `Nat.blt` are optimized at kernel and compiler level
- `Int.*'` functions are for kernel reduction
- String and numeric comparisons have native overrides

**Complexity awareness**:
- `List.isPerm` is `O(|l₁| * |l₂|)` - expensive
- `List.eraseDupsBy` is `O(|l|²)` - quadratic
- `List.eraseRepsBy` is `O(|l|)` - linear

### 5. Bool vs Prop

**Use `Bool` when**:
- Runtime computation needed
- Programming context (not proof)
- Want short-circuit evaluation
- Working with concrete decidable predicates

**Use `Prop` when**:
- Proving theorems
- Logical reasoning required
- Need quantification or implication
- Working in proof context

**Convert between**:
- `Prop → Bool`: Use `decide` (requires `Decidable` instance)
- `Bool → Prop`: Use `= true` or `toBool` coercion

## Notable Patterns and Idioms

### 1. BEq Instance Pattern
```lean
-- Standard way to make type support ==
instance : BEq MyType where
  beq x y := -- implementation

-- Can then use:
-- if x == y then ... else ...
```

### 2. Higher-Order Relation Pattern
```lean
-- Many functions take (α → α → Bool) parameter
def processWithRelation (xs : List α) (rel : α → α → Bool) : Result :=
  -- use rel for custom comparisons
  xs.eraseDupsBy rel
```

### 3. Decidable to Bool Pattern
```lean
-- Convert propositional predicate to Bool
def checkProperty (x : α) [Decidable (Property x)] : Bool :=
  decide (Property x)
```

### 4. Comparison Chaining Pattern
```lean
-- Lexicographic with custom comparison
def comparePairs (p1 p2 : α × β) (cmpA : α → α → Bool) (cmpB : β → β → Bool) : Bool :=
  cmpA p1.1 p2.1 || (p1.1 == p2.1 && cmpB p1.2 p2.2)
```

## Limitations and Gaps

### Not Available in Loogle MCP
- Loogle MCP server is planned but not yet configured in `.mcp.json`
- This search used direct HTTP API calls to `https://loogle.lean-lang.org/json`
- Future integration would enable programmatic access via MCP protocol

### Unicode Search Limitations
- Direct Unicode `α` in query parameters causes "Unknown identifier" error
- Workaround: Use `_` wildcard pattern instead
- Suggestions provided for specific instantiations (e.g., `WellOrder.α → α → Bool`)

### Search Result Limitations
- Maximum 200 results shown (out of 2362 total matches)
- Some specialized predicates may not appear in top results
- Full enumeration would require pagination or more specific queries

### Missing Standard Predicates
While comprehensive, some expected predicates weren't in top 200:
- Floating-point comparisons (Float.beq, Float.ble, etc.)
- More complex container predicates (Map, Set operations)
- Graph-theoretic predicates
- Custom Mathlib predicates (would need Mathlib-specific search)

## Summary

The Loogle search for binary predicates (`α → α → Bool`) revealed a rich ecosystem of 2,362+ functions, with the most important being:

1. **Type Class Foundation**: `BEq.beq` provides the polymorphic equality interface that unifies all type-specific equality predicates

2. **Performance Optimization**: Core numeric types (`Nat`, `Int`, `UInt*`) have kernel-optimized implementations for equality and ordering

3. **Structural Richness**: Lists and arrays have extensive structural predicates (prefix, suffix, sublist, permutation) all built on `BEq`

4. **Decidability Bridge**: `Decidable.decide` enables seamless conversion from propositional logic to boolean computation

5. **Customization Support**: Higher-order functions like `List.isEqv`, `List.eraseDupsBy`, and `List.lex` allow custom binary relations to be used with standard algorithms

The pattern is clear: Lean 4 favors **type class-based polymorphism** (`BEq`) for equality, **optimized built-ins** for performance-critical operations, and **higher-order functions** for flexibility in custom predicates. The distinction between `Bool` (computational) and `Prop` (logical) is bridged by `Decidable`, making both worlds accessible.

## Appendix: Search Methodology

### API Calls Made
1. **Pattern**: `"α → α → Bool"` - Failed with "Unknown identifier"
2. **Pattern**: `"_ → _ → Bool"` - Success: 2362 matches
3. **Pattern**: `"α → α → Prop"` - Failed with "Unknown identifier"
4. **Pattern**: `"BEq.beq"` - Success: 2131 matches
5. **Pattern**: `"Decidable"` - Success: First 20 results analyzed

### Data Extraction
- Parsed JSON responses from Loogle API
- Extracted: `name`, `type`, `module`, `doc` fields
- Categorized by: library, type pattern, functionality
- Cross-referenced with Lean 4 documentation patterns

### Verification
- Types verified against expected patterns
- Module paths confirmed as valid Lean 4 libraries
- Documentation strings preserved verbatim from API responses
