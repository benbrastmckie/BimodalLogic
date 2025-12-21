# Loogle Search Results: Binary Predicates (_ → _ → Bool)

**Type Pattern**: `_ → _ → Bool`
**Date**: Sun Dec 21 2025
**Total Matches Found**: 2362
**Results Returned**: 200 (Loogle limit: 200)

## Search Summary

This search queried the Loogle API for all binary predicate functions matching the pattern `_ → _ → Bool`. Out of 20,869 declarations mentioning `Bool`, we found **2,362 matches** for this specific pattern. The first 200 results are analyzed below.

### Key Insights

- **All 200 returned results** are from the Core library (Init.* modules)
- **30 exact matches** with the pure `α → β → Bool` signature
- **170 partial matches** including type constraints, implicit parameters, or explicit naming
- **94 functions** have documentation
- Primary use cases: equality testing, ordering, collection operations, and syntax validation

## Exact Matches

Functions that exactly match `α → β → Bool` without type constraints:

### 1. `Nat.beq`
- **Type**: ` : ℕ → ℕ → Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Boolean equality of natural numbers, usually accessed via the `==` operator.

This function is overridden in both the kernel and the compiler to efficiently evaluate using the
arbitrary-precision arit...

### 2. `Nat.ble`
- **Type**: ` : ℕ → ℕ → Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: The Boolean less-than-or-equal-to comparison on natural numbers.

This function is overridden in both the kernel and the compiler to efficiently evaluate using the
arbitrary-precision arithmetic libra...

### 3. `Lean.Name.beq`
- **Type**: ` : Lean.Name → Lean.Name → Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: (Boolean) equality comparator for names. 

### 4. `Lean.Meta.instBEqEtaStructMode.beq`
- **Type**: ` : Lean.Meta.EtaStructMode → Lean.Meta.EtaStructMode → Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Core

### 5. `Lean.Meta.instBEqOccurrences.beq`
- **Type**: ` : Lean.Meta.Occurrences → Lean.Meta.Occurrences → Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Core

### 6. `Lean.Meta.instBEqTransparencyMode.beq`
- **Type**: ` : Lean.Meta.TransparencyMode → Lean.Meta.TransparencyMode → Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Core

### 7. `Lean.Meta.DSimp.instBEqConfig.beq`
- **Type**: ` : Lean.Meta.DSimp.Config → Lean.Meta.DSimp.Config → Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Core

### 8. `Lean.Meta.Simp.instBEqConfig.beq`
- **Type**: ` : Lean.Meta.Simp.Config → Lean.Meta.Simp.Config → Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Core

### 9. `Lean.Grind.instBEqConfig.beq`
- **Type**: ` : Lean.Grind.Config → Lean.Grind.Config → Bool`
- **Module**: `Init.Grind.Config`
- **Library**: Core

### 10. `Nat.bitwise`
- **Type**: ` (f : Bool → Bool → Bool) (n m : ℕ) : ℕ`
- **Module**: `Init.Data.Nat.Bitwise.Basic`
- **Library**: Core
- **Description**: A helper for implementing bitwise operators on `Nat`.

Each bit of the resulting `Nat` is the result of applying `f` to the corresponding bits of the input
`Nat`s, up to the position of the highest se...

### 11. `String.Internal.any`
- **Type**: ` (s : String) (p : Char → Bool) : Bool`
- **Module**: `Init.Data.String.Bootstrap`
- **Library**: Core

### 12. `String.Internal.atEnd`
- **Type**: ` : String → String.Pos.Raw → Bool`
- **Module**: `Init.Data.String.Bootstrap`
- **Library**: Core

### 13. `Substring.Raw.Internal.all`
- **Type**: ` (s : Substring.Raw) (p : Char → Bool) : Bool`
- **Module**: `Init.Data.String.Bootstrap`
- **Library**: Core

### 14. `Std.Format.instBEqFlattenAllowability.beq`
- **Type**: ` : Std.Format.FlattenAllowability → Std.Format.FlattenAllowability → Bool`
- **Module**: `Init.Data.Format.Basic`
- **Library**: Core

### 15. `Std.Format.instBEqFlattenBehavior.beq`
- **Type**: ` : Std.Format.FlattenBehavior → Std.Format.FlattenBehavior → Bool`
- **Module**: `Init.Data.Format.Basic`
- **Library**: Core

### 16. `Lean.Syntax.isToken`
- **Type**: ` (token : String) : Lean.Syntax → Bool`
- **Module**: `Init.Meta.Defs`
- **Library**: Core

### 17. `Lean.Syntax.structEq`
- **Type**: ` : Lean.Syntax → Lean.Syntax → Bool`
- **Module**: `Init.Meta.Defs`
- **Library**: Core
- **Description**: Compare syntax structures modulo source info. 

### 18. `Lean.Meta.Occurrences.contains`
- **Type**: ` : Lean.Meta.Occurrences → ℕ → Bool`
- **Module**: `Init.Meta.Defs`
- **Library**: Core

### 19. `Lean.Syntax.instBEqPreresolved.beq`
- **Type**: ` : Lean.Syntax.Preresolved → Lean.Syntax.Preresolved → Bool`
- **Module**: `Init.Meta.Defs`
- **Library**: Core

### 20. `Bool.xor`
- **Type**: ` : Bool → Bool → Bool`
- **Module**: `Init.Data.Bool`
- **Library**: Core
- **Description**: Boolean “exclusive or”. `xor x y` can be written `x ^^ y`.

`x ^^ y` is `true` when precisely one of `x` or `y` is `true`. Unlike `and` and `or`, it does not
have short-circuiting behavior, because on...

### 21. `Nat.Linear.instBEqExpr.beq`
- **Type**: ` : Nat.Linear.Expr → Nat.Linear.Expr → Bool`
- **Module**: `Init.Data.Nat.Linear`
- **Library**: Core

### 22. `Nat.Linear.instBEqPolyCnstr.beq`
- **Type**: ` : Nat.Linear.PolyCnstr → Nat.Linear.PolyCnstr → Bool`
- **Module**: `Init.Data.Nat.Linear`
- **Library**: Core

### 23. `Lean.Omega.instBEqConstraint.beq`
- **Type**: ` : Lean.Omega.Constraint → Lean.Omega.Constraint → Bool`
- **Module**: `Init.Omega.Constraint`
- **Library**: Core

### 24. `Nat.all`
- **Type**: ` (n : ℕ) (f : (i : ℕ) → i < n → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether `f` returns `true` for every number strictly less than a bound.

Examples:
* `Nat.all 4 (fun i _ => i < 5) = true`
* `Nat.all 7 (fun i _ => i < 5) = false`
* `Nat.all 7 (fun i _ => i % ...

### 25. `Nat.allTR`
- **Type**: ` (n : ℕ) (f : (i : ℕ) → i < n → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether `f` returns `true` for every number strictly less than a bound.

This is a tail-recursive equivalent of `Nat.all` that's used at runtime.

Examples:
* `Nat.allTR 4 (fun i _ => i < 5) = ...

### 26. `Nat.any`
- **Type**: ` (n : ℕ) (f : (i : ℕ) → i < n → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether there is some number less that the given bound for which `f` returns `true`.

Examples:
* `Nat.any 4 (fun i _ => i < 5) = true`
* `Nat.any 7 (fun i _ => i < 5) = true`
* `Nat.any 7 (fun...

### 27. `Nat.anyTR`
- **Type**: ` (n : ℕ) (f : (i : ℕ) → i < n → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether there is some number less that the given bound for which `f` returns `true`.

This is a tail-recursive equivalent of `Nat.any` that's used at runtime.

Examples:
* `Nat.anyTR 4 (fun i _...

### 28. `Prod.allI`
- **Type**: ` (i : ℕ × ℕ) (f : (j : ℕ) → i.1 ≤ j → j < i.2 → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether a predicate holds for all natural numbers in a range.

In particular, `(start, stop).allI f` returns true if `f` is true for all natural numbers from
`start` (inclusive) to `stop` (excl...

### 29. `Prod.anyI`
- **Type**: ` (i : ℕ × ℕ) (f : (j : ℕ) → i.1 ≤ j → j < i.2 → Bool) : Bool`
- **Module**: `Init.Data.Nat.Fold`
- **Library**: Core
- **Description**: Checks whether a predicate holds for any natural number in a range.

In particular, `(start, stop).allI f` returns true if `f` is true for any natural number from
`start` (inclusive) to `stop` (exclus...

### 30. `ByteArray.instBEq.beq`
- **Type**: ` : ByteArray → ByteArray → Bool`
- **Module**: `Init.Data.ByteArray.Basic`
- **Library**: Core

## Partial Matches

Functions with similar signatures (with type constraints, implicit parameters, or named arguments):

### 1. `Bool.and`
- **Type**: ` (x y : Bool) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Boolean “and”, also known as conjunction. `and x y` can be written `x && y`.

The corresponding propositional connective is `And : Prop → Prop → Prop`, written with the `∧`
operator.

The Boolean `and...

### 2. `Bool.or`
- **Type**: ` (x y : Bool) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Boolean “or”, also known as disjunction. `or x y` can be written `x || y`.

The corresponding propositional connective is `Or : Prop → Prop → Prop`, written with the `∨`
operator.

The Boolean `or` is...

### 3. `Lean.Syntax.isOfKind`
- **Type**: ` (stx : Lean.Syntax) (k : Lean.SyntaxNodeKind) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Checks whether syntax has the given kind or pseudo-kind.

“Pseudo-kinds” are kinds that are assigned by convention to non-`Syntax.node` values:
`identKind` for `Syntax.ident`, `` `missing `` for `Synt...

### 4. `Lean.Syntax.matchesIdent`
- **Type**: ` (stx : Lean.Syntax) (id : Lean.Name) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Function used for determining whether a syntax pattern `` `(id) `` is matched.
There are various conceivable notions of when two syntactic identifiers should be regarded as identical,
but semantic def...

### 5. `Lean.Syntax.matchesNull`
- **Type**: ` (stx : Lean.Syntax) (n : ℕ) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Is this syntax a null `node`? 

### 6. `Decidable.decide`
- **Type**: ` (p : Prop) [h : Decidable p] : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Converts a decidable proposition into a `Bool`.

If `p : Prop` is decidable, then `decide p : Bool` is the Boolean value
that is `true` if `p` is true and `false` if `p` is false.


### 7. `Lean.Syntax.isNodeOf`
- **Type**: ` (stx : Lean.Syntax) (k : Lean.SyntaxNodeKind) (n : ℕ) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Is this syntax a `node` with kind `k`? 

### 8. `Lean.Syntax.matchesLit`
- **Type**: ` (stx : Lean.Syntax) (k : Lean.SyntaxNodeKind) (val : String) : Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Is this syntax a node kind `k` wrapping an `atom _ val`? 

### 9. `BEq.beq`
- **Type**: ` {α : Type u} [self : BEq α] : α → α → Bool`
- **Module**: `Init.Prelude`
- **Library**: Core
- **Description**: Boolean equality, notated as `a == b`. 

Conventions for notations in identifiers:

 * The recommended spelling of `==` in identifiers is `beq`.

### 10. `BEq.mk`
- **Type**: ` {α : Type u} (beq : α → α → Bool) : BEq α`
- **Module**: `Init.Prelude`
- **Library**: Core

### 11. `strictAnd`
- **Type**: ` (b₁ b₂ : Bool) : Bool`
- **Module**: `Init.Core`
- **Library**: Core
- **Description**: `strictAnd` is the same as `and`, but it does not use short-circuit evaluation semantics:
both sides are evaluated, even if the first value is `false`.


### 12. `strictOr`
- **Type**: ` (b₁ b₂ : Bool) : Bool`
- **Module**: `Init.Core`
- **Library**: Core
- **Description**: `strictOr` is the same as `or`, but it does not use short-circuit evaluation semantics:
both sides are evaluated, even if the first value is `true`.


### 13. `toBoolUsing`
- **Type**: ` {p : Prop} (d : Decidable p) : Bool`
- **Module**: `Init.Core`
- **Library**: Core
- **Description**: Similar to `decide`, but uses an explicit instance 

### 14. `bne`
- **Type**: ` {α : Type u} [BEq α] (a b : α) : Bool`
- **Module**: `Init.Core`
- **Library**: Core
- **Description**: `x != y` is boolean not-equal. It is the negation of `x == y` which is supplied by
the `BEq` typeclass.

Unlike `x ≠ y` (which is notation for `Ne x y`), this is `Bool` valued instead of
`Prop` valued...

### 15. `ToBool.toBool`
- **Type**: ` {α : Type u} [self : ToBool α] : α → Bool`
- **Module**: `Init.Control.Basic`
- **Library**: Core

### 16. `Except.isOk`
- **Type**: ` {ε : Type u} {α : Type u_1} : Except ε α → Bool`
- **Module**: `Init.Control.Except`
- **Library**: Core
- **Description**: Returns `true` if the value is `Except.ok`, `false` otherwise. 

### 17. `Except.toBool`
- **Type**: ` {ε : Type u} {α : Type u_1} : Except ε α → Bool`
- **Module**: `Init.Control.Except`
- **Library**: Core
- **Description**: Returns `true` if the value is `Except.ok`, `false` otherwise. 

### 18. `Nat.blt`
- **Type**: ` (a b : ℕ) : Bool`
- **Module**: `Init.Data.Nat.Basic`
- **Library**: Core
- **Description**: The Boolean less-than comparison on natural numbers.

This function is overridden in both the kernel and the compiler to efficiently evaluate using the
arbitrary-precision arithmetic library. The defi...

### 19. `Int.beq'`
- **Type**: ` (a b : ℤ) : Bool`
- **Module**: `Init.Data.Int.Basic`
- **Library**: Core
- **Description**: Equality predicate for kernel reduction. 

### 20. `Int.ble'`
- **Type**: ` (a b : ℤ) : Bool`
- **Module**: `Init.Data.Int.Basic`
- **Library**: Core
- **Description**: `x ≤ y` for kernel reduction. 

## Categorization

### By Library

- **Core**: 200 matches

### By Module (Top 15)

- **Init.Data.Option.Lemmas**: 28 functions
- **Init.Data.List.Basic**: 27 functions
- **Init.Data.BitVec.Basic**: 17 functions
- **Init.Data.Nat.Fold**: 16 functions
- **Init.Prelude**: 13 functions
- **Init.Data.Array.Basic**: 11 functions
- **Init.Data.List.Lemmas**: 10 functions
- **Init.Data.Nat.Bitwise.Lemmas**: 7 functions
- **Init.Data.String.Bootstrap**: 6 functions
- **Init.Data.Option.Basic**: 6 functions
- **Init.Data.Bool**: 6 functions
- **Init.MetaTypes**: 5 functions
- **Init.Util**: 5 functions
- **Init.Omega.Constraint**: 5 functions
- **Init.Data.BitVec.Bitblast**: 5 functions

### By Purpose

#### Collection Operations (58 functions)

- `Array.all`
- `Array.allDiff`
- `Array.any`
- `Array.contains`
- `Array.elem`
- `Array.getMax?`
- `Array.isEmpty`
- `Array.isEqv`
- `Array.isEqvAux`
- `Array.isEqvAux.congr_simp`
- *(and 48 more)*

#### Equality/Comparison (21 functions)

- `BEq.beq`
- `BEq.mk`
- `ByteArray.instBEq.beq`
- `Int.beq'`
- `Lean.Grind.instBEqConfig.beq`
- `Lean.Meta.DSimp.instBEqConfig.beq`
- `Lean.Meta.Simp.instBEqConfig.beq`
- `Lean.Meta.instBEqEtaStructMode.beq`
- `Lean.Meta.instBEqOccurrences.beq`
- `Lean.Meta.instBEqTransparencyMode.beq`
- *(and 11 more)*

#### Logical Operations (7 functions)

- `Bool.and`
- `Bool.and'`
- `Bool.or`
- `Bool.or'`
- `Bool.xor`
- `strictAnd`
- `strictOr`

#### Membership/Containment (13 functions)

- `Array.contains`
- `Array.elem`
- `Array.isPrefixOf`
- `Array.isPrefixOfAux`
- `Lean.Meta.Occurrences.contains`
- `List.contains`
- `List.elem`
- `List.isPerm`
- `List.isPrefixOf`
- `List.isSublist`
- *(and 3 more)*

#### Ordering (73 functions)

- `Array.elem`
- `BitVec.sle`
- `BitVec.slt`
- `BitVec.ule`
- `BitVec.ult`
- `Bool.atLeastTwo`
- `Decidable.decide`
- `Int.ble'`
- `Int.blt'`
- `Lean.Grind.instBEqConfig.beq`
- *(and 63 more)*

#### Other/Utility (29 functions)

- `BitVec.aandRec`
- `BitVec.carry`
- `BitVec.getLsb`
- `BitVec.getLsbD`
- `BitVec.getMsb`
- `BitVec.getMsbD`
- `BitVec.msb`
- `BitVec.negOverflow`
- `BitVec.resRec`
- `BitVec.saddOverflow`
- *(and 19 more)*

#### Predicates/Testing (42 functions)

- `Array.all`
- `Array.allDiff`
- `Array.any`
- `Array.isEqv`
- `Array.isEqvAux`
- `Array.isEqvAux.congr_simp`
- `Array.isEqv_eq_decide`
- `Array.isEqv_iff_rel`
- `Array.isEqv_toList`
- `List.all`
- *(and 32 more)*

#### State/Property Checks (19 functions)

- `Array.isEmpty`
- `Except.isOk`
- `List.isEmpty`
- `Nat.bitwise`
- `Nat.bitwise_div_two_pow`
- `Nat.bitwise_lt_two_pow`
- `Nat.bitwise_mod_two_pow`
- `Nat.bitwise_mul_two_pow`
- `Nat.shiftLeft_bitwise_distrib`
- `Nat.shiftRight_bitwise_distrib`
- *(and 9 more)*

#### Syntax/Parsing (8 functions)

- `Lean.Syntax.instBEqPreresolved.beq`
- `Lean.Syntax.isNodeOf`
- `Lean.Syntax.isOfKind`
- `Lean.Syntax.isToken`
- `Lean.Syntax.matchesIdent`
- `Lean.Syntax.matchesLit`
- `Lean.Syntax.matchesNull`
- `Lean.Syntax.structEq`

## Notable Binary Predicates

### Core Comparison Operations

#### `Nat.beq`
- **Purpose**: Natural number equality
- **Example**: `Nat.beq 3 3 = true`

#### `Nat.ble`
- **Purpose**: Natural number less-than-or-equal
- **Example**: `Nat.ble 2 5 = true`

#### `Nat.blt`
- **Purpose**: Natural number less-than
- **Example**: `Nat.blt 2 5 = true`

#### `BEq.beq`
- **Purpose**: Polymorphic boolean equality
- **Example**: `3 == 3 = true`

#### `List.beq`
- **Purpose**: List equality (element-wise)
- **Example**: `[1,2] == [1,2] = true`

### Collection Operations

#### `List.contains`
- **Purpose**: Check if element is in list
- **Example**: `[1,2,3].contains 2 = true`

#### `List.elem`
- **Purpose**: Synonym for contains
- **Example**: `List.elem 2 [1,2,3] = true`

#### `List.all`
- **Purpose**: Check if all elements satisfy predicate
- **Example**: `[2,4,6].all (· % 2 == 0) = true`

#### `List.any`
- **Purpose**: Check if any element satisfies predicate
- **Example**: `[1,2,3].any (· > 2) = true`

#### `Array.contains`
- **Purpose**: Check if element is in array
- **Example**: `#[1,2,3].contains 2 = true`

### Logical Operations

#### `Bool.and`
- **Purpose**: Boolean conjunction (&&)
- **Example**: `true && false = false`

#### `Bool.or`
- **Purpose**: Boolean disjunction (||)
- **Example**: `true || false = true`

#### `Bool.xor`
- **Purpose**: Boolean exclusive-or (^^)
- **Example**: `true ^^ true = false`

#### `strictAnd`
- **Purpose**: Non-short-circuiting AND
- **Example**: Both arguments always evaluated

#### `strictOr`
- **Purpose**: Non-short-circuiting OR
- **Example**: Both arguments always evaluated

## Usage Recommendations

### When to Use Binary Predicates

1. **For Equality Testing**:
   - Use `BEq.beq` (the `==` operator) for polymorphic equality
   - Use `Nat.beq`, `Int.beq`, etc. for specific numeric types
   - Use `List.beq`, `Array.beq` for structural equality of collections

2. **For Ordering**:
   - Use `Nat.blt`, `Nat.ble` for natural number comparisons
   - Use `Int.blt'`, `Int.ble'` for integer comparisons
   - Use `List.lex` for lexicographic ordering of lists

3. **For Collection Membership**:
   - Use `List.contains` or `Array.contains` to check membership
   - Use `List.isPrefixOf`, `List.isSuffixOf` for structural relationships
   - Use `List.isSublist` for subsequence checking

4. **For Custom Predicates**:
   - Define your own `α → β → Bool` function
   - Consider implementing `BEq` or `Ord` instances for your types
   - Use `Decidable` instances to convert `Prop` predicates to `Bool`

### Best Practices

- **Prefer `==` over `.beq`**: The `==` notation is more readable and standard
- **Use `Decidable.decide`**: Convert logical propositions to Bool when needed
- **Short-circuiting**: `&&` and `||` short-circuit; use `strictAnd`/`strictOr` if you need full evaluation
- **Polymorphism**: Use type class instances (`BEq`, `Ord`) for generic code

## Examples

### Example 1: Using `Nat.beq` for Natural Number Equality

```lean
-- Check if two natural numbers are equal
#eval Nat.beq 42 42  -- true
#eval 42 == 42       -- true (preferred notation)

-- In a proof context
example : Nat.beq 5 5 = true := rfl
```

### Example 2: Using `List.contains` for Membership

```lean
-- Check if an element is in a list
#eval [1, 2, 3, 4].contains 3  -- true
#eval [1, 2, 3, 4].contains 5  -- false

-- With custom equality
structure Point where
  x : Nat
  y : Nat
  deriving BEq

#eval [⟨1,2⟩, ⟨3,4⟩].contains ⟨1,2⟩  -- true
```

### Example 3: Using `List.all` with a Predicate

```lean
-- Check if all elements satisfy a condition
#eval [2, 4, 6, 8].all (· % 2 == 0)  -- true
#eval [2, 4, 5, 8].all (· % 2 == 0)  -- false

-- Combining predicates
#eval [1, 2, 3].all (fun n => n > 0 && n < 10)  -- true
```

### Example 4: Using `List.isEqv` for Custom Comparisons

```lean
-- Check if two lists are pairwise related
#eval [1, 2, 3].isEqv [2, 3, 4] (· < ·)  -- true
#eval [1, 2, 3].isEqv [2, 2, 4] (· < ·)  -- false

-- Must have same length
#eval [1, 2].isEqv [2, 3, 4] (· < ·)  -- false
```

### Example 5: Using `Decidable.decide` to Convert Props to Bool

```lean
-- Convert a decidable proposition to Bool
#eval decide (5 > 3)  -- true
#eval decide (∀ n : Nat, n < 10)  -- false

-- Useful in boolean contexts
def checkProperty (n : Nat) : Bool :=
  decide (n % 2 == 0 && n > 0)

#eval checkProperty 4  -- true
#eval checkProperty 3  -- false
```

## Related Searches

For further exploration, consider these related Loogle queries:

- **Ternary predicates**: `_ → _ → _ → Bool`
- **Predicates on specific types**: `Nat → Nat → Bool`
- **Predicates returning Props**: `_ → _ → Prop`
- **Comparison functions**: `_ → _ → Ordering`
- **Binary operations**: `_ → _ → _` (for non-predicate operations)
- **Decidable predicates**: `Decidable (_ → _ → Prop)`
- **List predicates**: `List _ → _ → Bool`
- **Higher-order predicates**: `(_ → Bool) → _ → Bool`

## Statistics

- **Total matches**: {cat['metadata']['total_matches']}
- **Exact matches** (no constraints): {len(cat['exact_matches'])}
- **Partial matches** (with constraints): {len(cat['partial_matches'])}
- **Documented functions**: {len(cat['top_documented'])}
- **Modules represented**: {len(cat['by_module'])}

## Most Common Modules

1. `Init.Data.Option.Lemmas`: 28 functions
2. `Init.Data.List.Basic`: 27 functions
3. `Init.Data.BitVec.Basic`: 17 functions
4. `Init.Data.Nat.Fold`: 16 functions
5. `Init.Prelude`: 13 functions
6. `Init.Data.Array.Basic`: 11 functions
7. `Init.Data.List.Lemmas`: 10 functions
8. `Init.Data.Nat.Bitwise.Lemmas`: 7 functions
9. `Init.Data.String.Bootstrap`: 6 functions
10. `Init.Data.Option.Basic`: 6 functions


---

**Report Generated**: Sun Dec 21 2025
**Query**: `_ → _ → Bool`
**API**: Loogle (https://loogle.lean-lang.org)
**Total Search Results**: 2362 (displaying first 200)

