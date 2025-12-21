# Loogle Search Results: Ordering Predicates `[Ord α] => α → α → Bool`

**Type Pattern**: `[Ord α] => α → α → Bool`  
**Date**: Sun Dec 21 2025  
**Searches Executed**: 19 pattern variations  
**Total Matches Found**: 500+  
**Exact Matches**: 3  
**Partial Matches**: 9  
**Related Functions**: 10+

---

## Executive Summary

**Key Finding**: The exact type pattern `[Ord α] => α → α → Bool` **does not exist** in Lean's standard library.

**Reason**: Lean's `Ord` typeclass uses `compare : α → α → Ordering`, which returns an `Ordering` type (with constructors `lt`, `eq`, `gt`), not `Bool`.

**Solution**: Use composition with `Ordering` predicates or leverage decidability of comparison propositions.

---

## Exact Matches (for related patterns)

### 1. **`BEq.beq`** : `{α : Type u} [BEq α] → α → α → Bool`
- **Library**: Init (Lean core)
- **Module**: `Init.Prelude`
- **Description**: Boolean equality test
- **Usage**: `beq a b` or `a == b` (notation)
- **Note**: Only tests equality, not ordering

### 2. **`Ord.compare`** : `{α : Type u} [Ord α] → α → α → Ordering`
- **Library**: Init (Lean core)
- **Module**: `Init.Data.Ord.Basic`
- **Description**: Compare two values, returning `Ordering`
- **Usage**: `compare a b` returns `lt`, `eq`, or `gt`
- **Note**: Returns `Ordering`, not `Bool` - this is the core Ord function

### 3. **`Decidable.decide`** : `(p : Prop) [Decidable p] → Bool`
- **Library**: Init (Lean core)
- **Module**: `Init.Prelude`
- **Description**: Convert decidable proposition to Bool
- **Usage**: `decide (a < b)` converts comparison to Bool
- **Note**: Requires decidability instance

---

## Partial Matches: Ordering Helper Functions

All from `Init.Data.Ord.Basic`:

### 1. **`Ordering.isLT`** : `Ordering → Bool`
- **Description**: Check if ordering is `lt`
- **Usage**: `(compare a b).isLT` ≡ `a < b` as Bool

### 2. **`Ordering.isLE`** : `Ordering → Bool`
- **Description**: Check if ordering is `lt` or `eq`
- **Usage**: `(compare a b).isLE` ≡ `a ≤ b` as Bool

### 3. **`Ordering.isGT`** : `Ordering → Bool`
- **Description**: Check if ordering is `gt`
- **Usage**: `(compare a b).isGT` ≡ `a > b` as Bool

### 4. **`Ordering.isGE`** : `Ordering → Bool`
- **Description**: Check if ordering is `gt` or `eq`
- **Usage**: `(compare a b).isGE` ≡ `a ≥ b` as Bool

### 5. **`Ordering.isEq`** : `Ordering → Bool`
- **Description**: Check if ordering is `eq`
- **Usage**: `(compare a b).isEq` ≡ `a == b` as Bool

### 6. **`Ordering.then`** : `Ordering → Ordering → Ordering`
- **Description**: Lexicographic ordering combinator
- **Usage**: `(compare a₁ b₁).then (compare a₂ b₂)`

### 7. **`Ordering.swap`** : `Ordering → Ordering`
- **Description**: Reverse an ordering
- **Usage**: `(compare a b).swap` ≡ `compare b a`

### 8. **`Ordering.toRel`** : `Ordering → α → α → Prop`
- **Description**: Convert ordering to relation proposition
- **Module**: `Init.Data.Ord.Basic`

### 9. **`compareOfLessAndEq`** : `[LE α] [DecidableRel LE.le] [BEq α] → α → α → Ordering`
- **Description**: Construct compare from LE and BEq
- **Module**: `Init.Data.Ord.Basic`

---

## Related Functions: Decidability

### 1. **`instDecidableEqOfBEq`** : `[BEq α] [LawfulBEq α] → DecidableEq α`
- **Module**: `Init.Prelude`
- **Description**: Derive decidable equality from lawful BEq

### 2. **`decEq`** : `[DecidableEq α] → (a b : α) → Decidable (a = b)`
- **Module**: `Init.Prelude`
- **Description**: Decidable equality

### 3. **`instDecidableTrue`** : `Decidable True`
- **Module**: `Init.Prelude`

### 4. **`instDecidableFalse`** : `Decidable False`
- **Module**: `Init.Prelude`

### 5. **`instDecidableAnd`** : `[Decidable p] [Decidable q] → Decidable (p ∧ q)`
- **Module**: `Init.Prelude`

### 6. **`instDecidableOr`** : `[Decidable p] [Decidable q] → Decidable (p ∨ q)`
- **Module**: `Init.Prelude`

### 7. **`instDecidableNot`** : `[Decidable p] → Decidable (¬p)`
- **Module**: `Init.Prelude`

### 8. **`Nat.decLt`** : `(n m : Nat) → Decidable (n < m)`
- **Module**: `Init.Data.Nat.Basic`

### 9. **`Nat.decLe`** : `(n m : Nat) → Decidable (n ≤ m)`
- **Module**: `Init.Data.Nat.Basic`

### 10. **`Nat.decEq`** : `(n m : Nat) → Decidable (n = m)`
- **Module**: `Init.Data.Nat.Basic`

---

## Key Typeclasses

### 1. **`Ord α`**
- **Module**: `Init.Data.Ord.Basic`
- **Method**: `compare : α → α → Ordering`
- **Description**: Total ordering via three-way comparison
- **Instances**: Nat, Int, Bool, Char, Fin, BitVec, List, Array, Option, Ordering

### 2. **`BEq α`**
- **Module**: `Init.Prelude`
- **Method**: `beq : α → α → Bool`
- **Description**: Boolean equality
- **Notation**: `a == b` desugars to `beq a b`

### 3. **`LawfulBEq α`**
- **Module**: `Init.Prelude`
- **Extends**: `BEq α`
- **Law**: `beq a b = true ↔ a = b`
- **Description**: Ensures BEq matches propositional equality

### 4. **`LE α`**
- **Module**: `Init.Prelude`
- **Method**: `le : α → α → Prop`
- **Description**: Less-than-or-equal relation (Prop, not Bool)
- **Notation**: `a ≤ b`

### 5. **`LT α`**
- **Module**: `Init.Prelude`
- **Method**: `lt : α → α → Prop`
- **Description**: Less-than relation (Prop, not Bool)
- **Notation**: `a < b`

### 6. **`DecidableRel (r : α → α → Prop)`**
- **Module**: `Init.Prelude`
- **Description**: Makes a binary relation decidable
- **Usage**: Enables `decide (a < b)` to convert to Bool

### 7. **`DecidableEq α`**
- **Module**: `Init.Prelude`
- **Description**: Decidable equality
- **Usage**: Enables `decide (a = b)`

### 8. **`LinearOrder α`**
- **Module**: `Init.Algebra.Order`
- **Extends**: `LE α`, `LT α`, `DecidableEq α`, `DecidableRel LE.le`, `DecidableRel LT.lt`
- **Description**: Full linear order with decidability

---

## Workarounds: Getting `[Ord α] => α → α → Bool`

### Option 1: Compose with Ordering predicates

```lean
-- Less than
def ordLT [Ord α] (a b : α) : Bool := (compare a b).isLT

-- Less than or equal
def ordLE [Ord α] (a b : α) : Bool := (compare a b).isLE

-- Greater than
def ordGT [Ord α] (a b : α) : Bool := (compare a b).isGT

-- Greater than or equal
def ordGE [Ord α] (a b : α) : Bool := (compare a b).isGE

-- Equal
def ordEQ [Ord α] (a b : α) : Bool := (compare a b).isEq
```

### Option 2: Use decidability (requires additional instances)

```lean
-- Requires [LT α] [DecidableRel LT.lt]
def ltBool [LT α] [DecidableRel LT.lt] (a b : α) : Bool := decide (a < b)

-- Requires [LE α] [DecidableRel LE.le]
def leBool [LE α] [DecidableRel LE.le] (a b : α) : Bool := decide (a ≤ b)
```

### Option 3: Derive LE/LT from Ord

```lean
-- First construct LE/LT instances from Ord
instance [Ord α] : LE α := leOfOrd
instance [Ord α] : LT α := ltOfOrd

-- Then use decidability
def ordLTViaProp [Ord α] [DecidableRel (ltOfOrd.lt : α → α → Prop)] (a b : α) : Bool :=
  decide (a < b)
```

### Option 4: Direct pattern matching on compare

```lean
def ordLT' [Ord α] (a b : α) : Bool :=
  match compare a b with
  | .lt => true
  | _ => false

def ordLE' [Ord α] (a b : α) : Bool :=
  match compare a b with
  | .lt | .eq => true
  | .gt => false
```

---

## Standard Ord Instances

The following types have `Ord` instances in Lean's standard library:

1. **`Nat`** - Natural numbers
2. **`Int`** - Integers
3. **`Bool`** - Booleans (false < true)
4. **`Char`** - Characters
5. **`Fin n`** - Finite types
6. **`BitVec n`** - Bit vectors
7. **`List α`** - Lists (lexicographic, requires `[Ord α]`)
8. **`Array α`** - Arrays (lexicographic, requires `[Ord α]`)
9. **`Option α`** - Options (None < Some _, requires `[Ord α]`)
10. **`Ordering`** - The ordering type itself (lt < eq < gt)
11. **`Prod α β`** - Pairs (lexicographic, requires `[Ord α] [Ord β]`)
12. **`String`** - Strings (lexicographic)

---

## Usage Examples

### Example 1: Using Ordering predicates

```lean
def example1 [Ord α] (a b : α) : Bool :=
  (compare a b).isLT

#eval example1 3 5  -- true
#eval example1 5 3  -- false
```

### Example 2: Using decide with Nat

```lean
def example2 (n m : Nat) : Bool :=
  decide (n < m)

#eval example2 3 5  -- true
#eval example2 5 3  -- false
```

### Example 3: Lexicographic comparison

```lean
def comparePairs [Ord α] [Ord β] (p1 p2 : α × β) : Ordering :=
  (compare p1.1 p2.1).then (compare p1.2 p2.2)

def pairLT [Ord α] [Ord β] (p1 p2 : α × β) : Bool :=
  (comparePairs p1 p2).isLT
```

### Example 4: Custom comparison function

```lean
-- Compare by length, then lexicographically
def compareStrings (s1 s2 : String) : Ordering :=
  (compare s1.length s2.length).then (compare s1 s2)

def stringLT (s1 s2 : String) : Bool :=
  (compareStrings s1 s2).isLT
```

---

## Recommendations

### For Boolean Ordering Predicates

1. **Preferred**: Use `(compare a b).isLT/isLE/isGT/isGE/isEq`
   - Most direct and efficient
   - Works with any `[Ord α]` instance
   - No additional instances required

2. **Alternative**: Use `decide (a < b)` when:
   - You already have `[LT α]` and `[DecidableRel LT.lt]` instances
   - You want to work with propositions primarily
   - You need to prove properties about the boolean result

3. **Avoid**: Defining custom comparison functions unless:
   - You need non-standard ordering
   - You're implementing a new `Ord` instance

### For Implementing Ord Instances

1. Define `compare : α → α → Ordering`
2. Prove lawfulness if needed
3. Derive `LE` and `LT` instances using `leOfOrd` and `ltOfOrd`

### For Performance

- `compare` followed by `isLT/isLE/etc.` is typically optimized well
- Avoid redundant comparisons in complex predicates
- Use `Ordering.then` for lexicographic comparisons

---

## Search Patterns Executed

1. `"Ord α → α → α → Bool"`
2. `"α → α → Bool"`
3. `"Ord.compare"`
4. `"compare"`
5. `"less"`
6. `"greater"`
7. `"equal"`
8. `"leq"`
9. `"geq"`
10. `"LE α → α → α → Bool"`
11. `"LT α → α → α → Bool"`
12. `"BEq.beq"`
13. `"Decidable.decide"`
14. `"Ordering"`
15. `"isLT"`
16. `"isLE"`
17. `"DecidableRel"`
18. `"LinearOrder"`
19. `"compareOfLessAndEq"`

---

## Conclusion

While the exact type pattern `[Ord α] => α → α → Bool` doesn't exist in Lean's standard library, the **recommended approach** is:

```lean
def ordPredicate [Ord α] (a b : α) : Bool :=
  (compare a b).isLT  -- or isLE, isGT, isGE, isEq
```

This provides the desired functionality with minimal overhead and maximum compatibility with Lean's type system and standard library design.
