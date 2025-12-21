# Loogle Search Results: Nat → α → Option α

**Type Pattern**: `Nat → α → Option α` (bounded search with depth limit pattern)  
**Alternative Pattern**: `Nat → _ → Option _` (wildcard search)  
**Date**: 2025-12-21  
**Matches Found**: 114 exact pattern matches, 871 total related matches  
**Search Context**: Functions taking a natural number (depth/bound/index) and a value, returning an optional result

---

## Executive Summary

This search identifies functions matching the bounded computation pattern `Nat → α → Option α`, where:
- **First parameter (Nat)**: Represents a bound, depth limit, index, or iteration count
- **Second parameter (α)**: The value being processed or searched
- **Return type (Option α)**: Optional result (may fail or return none)

The pattern is commonly used for:
1. **Index-based access** with bounds checking
2. **Bounded iteration** with fuel/gas parameters
3. **Enumeration** with step counts
4. **Depth-limited search** operations

---

## Exact Matches (Nat → α → Option α)

### 1. **Std.PRange.UpwardEnumerable.succMany?**
- **Type**: `{α : Type u} [self : Std.PRange.UpwardEnumerable α] (n : ℕ) (a : α) : Option α`
- **Library**: Std (Init.Data.Range.Polymorphic.UpwardEnumerable)
- **Description**: Apply successor operation `n` times to value `a`
- **Usage Pattern**: Bounded enumeration - advance `n` steps in an enumerable type
- **Example Use Case**: `succMany? 5 x` advances `x` by 5 steps if possible

### 2. **Std.Iterators.Iter.Partial.atIdxSlow?**
- **Type**: `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Monad Id] (n : ℕ) (it : Std.Iterators.Iter.Partial β) : Option β`
- **Library**: Std (Init.Data.Iterators.Consumers.Access)
- **Description**: Access element at index `n` in partial iterator
- **Usage Pattern**: Index-based access with bounds checking
- **Example Use Case**: `atIdxSlow? 3 iter` retrieves 4th element if it exists

### 3. **Std.Iterators.Iter.atIdxSlow?**
- **Type**: `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Std.Iterators.Productive α Id] (n : ℕ) (it : Std.Iter β) : Option β`
- **Library**: Std (Init.Data.Iterators.Consumers.Access)
- **Description**: Access element at index `n` in iterator (slow version)
- **Usage Pattern**: Index-based access for productive iterators
- **Example Use Case**: Sequential access to nth element

### 4. **Std.Iterators.Iter.atIdx?**
- **Type**: `{α β : Type u_1} [Std.Iterators.Iterator α Id β] [Std.Iterators.Productive α Id] [Std.Iterators.IteratorAccess α Id] (n : ℕ) (it : Std.Iter β) : Option β`
- **Library**: Std (Init.Data.Iterators.Consumers.Access)
- **Description**: Access element at index `n` in iterator (optimized version)
- **Usage Pattern**: Fast index-based access with IteratorAccess typeclass
- **Example Use Case**: Random access to iterator elements

---

## Partial Matches (Similar Patterns)

### Index Access Functions (Nat → Collection → Option Element)

#### **List.get?Internal**
- **Type**: `{α : Type u_1} (as : List α) (i : ℕ) : Option α`
- **Library**: Init (Init.GetElem)
- **Description**: Internal implementation of list indexing
- **Pattern**: Takes index first, then list (reversed parameter order)

#### **Vector.back?**
- **Type**: `{α : Type u_1} {n : ℕ} (xs : Vector α n) : Option α`
- **Library**: Init (Init.Data.Vector.Basic)
- **Description**: Get last element of vector
- **Pattern**: Implicit Nat parameter (vector size), returns Option α

#### **FloatArray.get?**
- **Type**: `(ds : FloatArray) (i : ℕ) : Option Float`
- **Library**: Init (Init.Data.FloatArray.Basic)
- **Description**: Safe array access at index
- **Pattern**: Array first, index second (reversed order)

### Bounded Search Functions

#### **Array.binSearch**
- **Type**: `{α : Type} (as : Array α) (k : α) (lt : α → α → Bool) (lo : ℕ := 0) (hi : ℕ := as.size - 1) : Option α`
- **Library**: Init (Init.Data.Array.BinSearch)
- **Description**: Binary search with index bounds
- **Pattern**: Uses Nat parameters for bounds, returns Option α

#### **Lean.Order.Example.find**
- **Type**: `(P : ℕ → Bool) : ℕ → Option ℕ`
- **Library**: Init (Init.Internal.Order.Basic)
- **Description**: Find natural number satisfying predicate
- **Pattern**: Bounded search starting from given Nat

### Enumeration and Stepping Functions

#### **Nat.psub**
- **Type**: `(m : ℕ) : ℕ → Option ℕ`
- **Library**: Mathlib (Mathlib.Data.Nat.PSub)
- **Description**: Partial subtraction (predecessor subtraction)
- **Pattern**: `Nat → Nat → Option Nat` - bounded arithmetic

#### **Nat.psub'**
- **Type**: `(m n : ℕ) : Option ℕ`
- **Library**: Mathlib (Mathlib.Data.Nat.PSub)
- **Description**: Alternative partial subtraction
- **Pattern**: Two Nat parameters, optional result

### Decoding Functions

#### **Encodable.decode**
- **Type**: `{α : Type u_1} [self : Encodable α] : ℕ → Option α`
- **Library**: Mathlib (Mathlib.Logic.Encodable.Basic)
- **Description**: Decode natural number to value
- **Pattern**: `Nat → Option α` - encoding/decoding with bounds

#### **Encodable.decode₂**
- **Type**: `(α : Type u_3) [Encodable α] (n : ℕ) : Option α`
- **Library**: Mathlib (Mathlib.Logic.Encodable.Basic)
- **Description**: Alternative decode function
- **Pattern**: Explicit type parameter, then Nat

---

## Related Patterns by Category

### Category 1: Index-Based Access (Collection → Nat → Option Element)

**Pattern**: Collection comes first, index second (reversed from target pattern)

| Function | Type | Library |
|----------|------|---------|
| `List.get?Internal` | `List α → ℕ → Option α` | Init.GetElem |
| `Array.findIdx?.loop` | `Array α → (α → Bool) → ℕ → Option ℕ` | Init.Data.Array.Basic |
| `BitVec.getLsb?` | `{w : ℕ} → BitVec w → ℕ → Option Bool` | Init.Data.BitVec.Basic |
| `BitVec.getMsb?` | `{w : ℕ} → BitVec w → ℕ → Option Bool` | Init.Data.BitVec.Basic |
| `ByteArray.findIdx?` | `ByteArray → (UInt8 → Bool) → ℕ → Option ℕ` | Init.Data.ByteArray.Basic |
| `FloatArray.get?` | `FloatArray → ℕ → Option Float` | Init.Data.FloatArray.Basic |

### Category 2: Tree/Map Index Access (Nat → Structure → Option Value)

**Pattern**: Index-based access to ordered structures

| Function | Type | Library |
|----------|------|---------|
| `Std.DTreeMap.keyAtIdx?` | `Std.DTreeMap α β cmp → ℕ → Option α` | Std.Data.DTreeMap.Basic |
| `Std.TreeMap.keyAtIdx?` | `Std.TreeMap α β cmp → ℕ → Option α` | Std.Data.TreeMap.Basic |
| `Std.TreeSet.atIdx?` | `Std.TreeSet α cmp → ℕ → Option α` | Std.Data.TreeSet.Basic |
| `Ordnode.nth` | `Ordnode α → ℕ → Option α` | Mathlib.Data.Ordmap.Ordnode |

### Category 3: Bounded Computation (Nat → Value → Option Result)

**Pattern**: Matches target pattern exactly - bounded operations

| Function | Type | Library |
|----------|------|---------|
| `Std.PRange.UpwardEnumerable.succMany?` | `ℕ → α → Option α` | Init.Data.Range.Polymorphic.UpwardEnumerable |
| `Computation.runFor` | `Computation α → ℕ → Option α` | Mathlib.Data.Seq.Computation |
| `Stream'.Seq.get?` | `Stream'.Seq α → ℕ → Option α` | Mathlib.Data.Seq.Defs |

### Category 4: Encoding/Decoding (Nat → Option α)

**Pattern**: Single Nat parameter, decode to optional value

| Function | Type | Library |
|----------|------|---------|
| `Encodable.decode` | `ℕ → Option α` | Mathlib.Logic.Encodable.Basic |
| `Encodable.decode₂` | `ℕ → Option α` | Mathlib.Logic.Encodable.Basic |
| `Encodable.decodeSum` | `ℕ → Option (α ⊕ β)` | Mathlib.Logic.Encodable.Basic |
| `Encodable.decodeSigma` | `ℕ → Option (Sigma γ)` | Mathlib.Logic.Encodable.Basic |
| `Encodable.decodeSubtype` | `ℕ → Option {a // P a}` | Mathlib.Logic.Encodable.Basic |
| `Encodable.decodeList` | `ℕ → Option (List α)` | Mathlib.Logic.Equiv.List |
| `decodeMultiset` | `ℕ → Option (Multiset α)` | Mathlib.Logic.Equiv.Multiset |
| `Fin2.optOfNat` | `ℕ → Option (Fin2 n)` | Mathlib.Data.Fin.Fin2 |

### Category 5: String/Character Decoding (ByteArray/String → Nat → Option Char)

**Pattern**: Position-based character decoding

| Function | Type | Library |
|----------|------|---------|
| `ByteArray.utf8DecodeChar?` | `ByteArray → ℕ → Option Char` | Init.Data.String.Decode |
| `String.utf8DecodeChar?` | `ByteArray → ℕ → Option Char` | Init.Data.String.Extra |

### Category 6: FilterMap Operations (α → Option β)

**Pattern**: Transform with optional results (not matching target, but related)

Many functions use `filterMap` with signature `(α → Option β) → Collection α → Collection β`:
- `Array.filterMap`
- `List.filterMap`
- `Vector.findSome?`
- And 100+ related lemmas and properties

---

## Library Distribution

### By Library Source

| Library | Count | Percentage |
|---------|-------|------------|
| **Init** (Lean Core) | ~85 | 74% |
| **Std** (Standard Library) | ~20 | 17% |
| **Mathlib** | ~9 | 8% |

### By Module (Top 10)

1. **Init.Data.Array.Lemmas** - 40+ functions (filterMap lemmas)
2. **Init.Data.List.Lemmas** - 15+ functions (filterMap lemmas)
3. **Init.Data.Vector.Find** - 12+ functions (findSome? operations)
4. **Init.Data.Iterators** - 8 functions (iterator access)
5. **Std.Data.TreeMap/TreeSet** - 6 functions (indexed access)
6. **Mathlib.Logic.Encodable** - 7 functions (encoding/decoding)
7. **Init.Data.ByteArray** - 5 functions (byte operations)
8. **Init.Data.String** - 4 functions (string operations)
9. **Std.Data.DHashMap** - 15+ functions (hash map operations)
10. **Mathlib.Data.Seq** - 3 functions (sequence operations)

---

## Usage Patterns and Recommendations

### Pattern 1: Bounded Enumeration
**Use Case**: Advance `n` steps in an enumerable structure  
**Recommended Function**: `Std.PRange.UpwardEnumerable.succMany?`  
**Example**:
```lean
-- Advance 5 steps in enumerable type
succMany? 5 x
```

### Pattern 2: Iterator Index Access
**Use Case**: Access nth element of iterator  
**Recommended Functions**:
- `Std.Iterators.Iter.atIdx?` (fast, requires IteratorAccess)
- `Std.Iterators.Iter.atIdxSlow?` (slower, more general)  
**Example**:
```lean
-- Get 10th element of iterator
atIdx? 10 myIterator
```

### Pattern 3: Bounded Computation
**Use Case**: Run computation for n steps  
**Recommended Function**: `Computation.runFor`  
**Example**:
```lean
-- Run computation for 100 steps
runFor myComputation 100
```

### Pattern 4: Sequence Access
**Use Case**: Access nth element of lazy sequence  
**Recommended Function**: `Stream'.Seq.get?`  
**Example**:
```lean
-- Get 42nd element of sequence
Stream'.Seq.get? mySeq 42
```

### Pattern 5: Decoding with Bounds
**Use Case**: Decode natural number to value  
**Recommended Function**: `Encodable.decode`  
**Example**:
```lean
-- Decode natural number to type α
Encodable.decode (α := MyType) 123
```

---

## Key Observations

### 1. Parameter Order Variations
- **Target pattern**: `Nat → α → Option α` (index/bound first)
- **Common alternative**: `α → Nat → Option α` (value first, index second)
- **Reason**: Collection-first order is more common in Lean for partial application

### 2. Exact Match Rarity
Only **4 functions** exactly match `Nat → α → Option α`:
1. `Std.PRange.UpwardEnumerable.succMany?` - bounded enumeration
2. `Std.Iterators.Iter.Partial.atIdxSlow?` - partial iterator access
3. `Std.Iterators.Iter.atIdxSlow?` - iterator access (slow)
4. `Std.Iterators.Iter.atIdx?` - iterator access (fast)

### 3. Common Use Cases
The pattern appears in:
- **Bounded iteration** (fuel/gas parameters)
- **Index-based access** with bounds checking
- **Enumeration** with step counts
- **Decoding** with potential failure
- **Lazy evaluation** with depth limits

### 4. Related Patterns
- `Nat → Option α` - decoding without input value
- `α → Nat → Option α` - reversed parameter order
- `Nat → α → Option β` - transformation with bounds
- `Computation α → Nat → Option α` - bounded computation

---

## Implementation Guidance

### When to Use This Pattern

✅ **Good Use Cases**:
- Bounded search with depth limit
- Iteration with fuel/gas parameter
- Enumeration with step count
- Index-based access where index comes first

❌ **Avoid When**:
- Collection access is primary operation (use `Collection → Nat → Option α`)
- No natural bound or index concept
- Unbounded operations (use `α → Option α`)

### Design Considerations

1. **Parameter Order**: Choose `Nat → α → Option α` when:
   - The bound/index is the primary parameter
   - Partial application of bound is useful
   - Following enumeration/stepping semantics

2. **Alternative Order**: Choose `α → Nat → Option α` when:
   - The value/collection is the primary parameter
   - Partial application of value is more useful
   - Following collection access semantics

3. **Return Type**: Use `Option α` when:
   - Operation may fail (out of bounds, insufficient fuel)
   - No default value is appropriate
   - Caller should handle failure explicitly

---

## Related Searches

### Suggested Follow-up Searches

1. **Reversed parameter order**: `_ → Nat → Option _`
2. **Transformation variant**: `Nat → _ → Option _` (different output type)
3. **Monadic variant**: `Nat → α → m (Option α)`
4. **Fuel-based recursion**: `Nat → α → α` (total version)
5. **Bounded predicates**: `Nat → α → Bool`

### Related Type Signatures

- `Nat → α → α` - bounded operation (total)
- `Nat → α → Option β` - bounded transformation
- `Nat → α → Except ε α` - bounded with error
- `Computation α → Nat → Option α` - lazy computation with bound
- `α → Nat → Option α` - reversed parameter order

---

## Conclusion

The type signature `Nat → α → Option α` represents a **bounded computation pattern** where:
- A natural number parameter provides a bound, limit, or index
- An input value is processed or accessed
- An optional result is returned (may fail)

**Primary exact matches** (4 functions):
1. `Std.PRange.UpwardEnumerable.succMany?` - bounded enumeration
2. `Std.Iterators.Iter.atIdx?` - iterator access (fast)
3. `Std.Iterators.Iter.atIdxSlow?` - iterator access (slow)
4. `Std.Iterators.Iter.Partial.atIdxSlow?` - partial iterator access

**Related patterns** (110+ functions):
- Index-based access (reversed parameter order)
- Decoding operations (`Nat → Option α`)
- Bounded computations and searches
- FilterMap operations (different pattern)

**Recommendation**: For implementing bounded search with depth limit, consider:
1. `Std.PRange.UpwardEnumerable.succMany?` for enumeration-based stepping
2. `Computation.runFor` for bounded computation
3. Custom implementation following the pattern for domain-specific needs

The pattern is relatively rare in exact form but common in variations, suggesting that parameter order and specific use case strongly influence API design in the Lean ecosystem.
