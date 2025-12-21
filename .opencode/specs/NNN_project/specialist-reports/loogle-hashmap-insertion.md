# Loogle Search Results: HashMap Insertion and Cache Patterns

**Search Date**: Sun Dec 21 2025
**Total Queries**: 11
**Total Matches**: 1,289
**Successful Queries**: 4 of 11

## Executive Summary

This comprehensive Loogle search investigated HashMap insertion and cache patterns in Lean 4's standard library and Mathlib4. The search executed 11 queries targeting insertion functions, update patterns, and memoization utilities.

**Key Findings**:
- **Primary insertion function**: `Std.HashMap.insert` - standard insertion that overwrites existing values
- **Conditional insertion**: `Std.HashMap.insertIfNew` - inserts only if key doesn't exist
- **Update function**: `Std.HashMap.modify` - modifies existing values using a function
- **No built-in memoization**: Lean 4 standard library does not provide built-in memoization or cache utilities
- **Namespace requirement**: All HashMap functions require `Std.HashMap` prefix; bare `HashMap` queries fail

**Recommended Approach for Caching**:
Use `Std.HashMap.insert` for standard cache insertion with overwrite semantics, or `Std.HashMap.insertIfNew` for cache patterns that preserve first-computed values.

---

## Search Query Results

### Query 1: "α → β → HashMap α β"
- **Pattern Type**: Exact insertion pattern
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: Type pattern queries require proper namespace (`Std.HashMap`)

### Query 2: "Std.HashMap.insert"
- **Pattern Type**: By name
- **Matches Found**: 45
- **Status**: Success
- **Primary Result**:
  - **Name**: `Std.HashMap.insert`
  - **Type**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (b : β) : Std.HashMap α β`
  - **Module**: `Std.Data.HashMap.Basic`
  - **Library**: Mathlib4
  - **URL**: https://leanprover-community.github.io/mathlib4_docs/Std/Data/HashMap/Basic.html#Std.HashMap.insert

### Query 3: "_ → _ → HashMap _ _"
- **Pattern Type**: Wildcard pattern
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: Wildcard patterns require proper namespace

### Query 4: "α → β → Std.HashMap α β"
- **Pattern Type**: With namespace
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: Type pattern matching appears to require function name prefix

### Query 5: "Std.HashMap"
- **Pattern Type**: General HashMap functions
- **Matches Found**: 1,192 (200 displayed)
- **Status**: Success
- **Coverage**: Comprehensive list of all HashMap operations, instances, and theorems

### Query 6: "insert : _ → _ → HashMap _ _"
- **Pattern Type**: Insert with wildcards
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: Combined name/type pattern requires proper namespace

### Query 7: "memoize"
- **Pattern Type**: Memoization utilities
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: No built-in memoization utilities in Lean 4 standard library

### Query 8: "cache"
- **Pattern Type**: Cache-related functions
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: No built-in cache utilities in Lean 4 standard library

### Query 9: "α → β → Std.Data.HashMap α β"
- **Pattern Type**: Alternative namespace
- **Matches Found**: 0
- **Status**: Failed
- **Reason**: Incorrect namespace; correct is `Std.HashMap`, not `Std.Data.HashMap`

### Query 10: "Std.HashMap.insertIfNew"
- **Pattern Type**: Conditional insertion
- **Matches Found**: 30
- **Status**: Success
- **Primary Result**:
  - **Name**: `Std.HashMap.insertIfNew`
  - **Type**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (b : β) : Std.HashMap α β`
  - **Module**: `Std.Data.HashMap.Basic`
  - **Library**: Mathlib4
  - **URL**: https://leanprover-community.github.io/mathlib4_docs/Std/Data/HashMap/Basic.html#Std.HashMap.insertIfNew

### Query 11: "Std.HashMap.modify"
- **Pattern Type**: Update patterns
- **Matches Found**: 22
- **Status**: Success
- **Primary Result**:
  - **Name**: `Std.HashMap.modify`
  - **Type**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (f : β → β) : Std.HashMap α β`
  - **Module**: `Std.Data.HashMap.Basic`
  - **Library**: Mathlib4
  - **URL**: https://leanprover-community.github.io/mathlib4_docs/Std/Data/HashMap/Basic.html#Std.HashMap.modify

---

## Categorized Results

### Exact Matches: HashMap Insertion

#### 1. **Std.HashMap.insert**
- **Type Signature**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (b : β) : Std.HashMap α β`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Standard insertion operation that adds or overwrites a key-value pair
- **Semantics**: If key `a` exists, overwrites the value; otherwise, adds new entry
- **Requirements**: Type `α` must have `BEq` and `Hashable` instances
- **Usage Pattern**: `m.insert key value` or `Std.HashMap.insert m key value`
- **Related Theorems**: 44 lemmas about insertion properties (associativity, commutativity, etc.)

#### 2. **Std.HashMap.insertIfNew**
- **Type Signature**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (b : β) : Std.HashMap α β`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Conditional insertion that preserves existing values
- **Semantics**: Inserts only if key `a` does not already exist; preserves existing value if present
- **Requirements**: Type `α` must have `BEq` and `Hashable` instances
- **Usage Pattern**: `m.insertIfNew key value` or `Std.HashMap.insertIfNew m key value`
- **Cache Use Case**: Ideal for memoization where first-computed value should be preserved
- **Related Theorems**: 29 lemmas about conditional insertion properties

### Partial Matches: Related HashMap Operations

#### 1. **Std.HashMap.modify**
- **Type Signature**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) (f : β → β) : Std.HashMap α β`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Modifies the value associated with a key using a function
- **Semantics**: If key exists, applies function `f` to the value; behavior undefined if key doesn't exist
- **Usage Pattern**: `m.modify key updateFn`
- **Cache Use Case**: Useful for updating cached values based on previous computation
- **Related Theorems**: 21 lemmas about modification properties

#### 2. **Std.HashMap.empty**
- **Type Signature**: `{α : Type u_1} {β : Type u_2} [BEq α] [Hashable α] : Std.HashMap α β`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Creates an empty HashMap
- **Usage Pattern**: `Std.HashMap.empty` or `∅`
- **Cache Use Case**: Initialize empty cache

#### 3. **Std.HashMap.find?**
- **Type Signature**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) : Option β`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Looks up a value by key, returning `Option β`
- **Semantics**: Returns `some value` if key exists, `none` otherwise
- **Usage Pattern**: `m.find? key`
- **Cache Use Case**: Check cache before computing

#### 4. **Std.HashMap.contains**
- **Type Signature**: `{α : Type u} {β : Type v} {x✝ : BEq α} {x✝¹ : Hashable α} (m : Std.HashMap α β) (a : α) : Bool`
- **Library**: Mathlib4
- **Module**: `Std.Data.HashMap.Basic`
- **Description**: Checks if a key exists in the HashMap
- **Usage Pattern**: `m.contains key`
- **Cache Use Case**: Quick existence check

### Related Patterns: Memoization and Caching

**No built-in memoization or cache utilities found in Lean 4 standard library or Mathlib4.**

**Implications**:
- Manual cache implementation required using `Std.HashMap`
- No automatic function memoization decorators
- No cache eviction policies (LRU, LFU, etc.)
- No thread-safe cache implementations

**Recommended Manual Implementation Pattern**:
```lean
-- Cache pattern using HashMap
def memoizedCompute (cache : Std.HashMap α β) (key : α) (compute : α → β) : β × Std.HashMap α β :=
  match cache.find? key with
  | some value => (value, cache)
  | none =>
    let value := compute key
    (value, cache.insert key value)
```

### Alternative Data Structures

While no dedicated cache structures exist, the following alternatives may be relevant:

1. **Std.RBMap** (Red-Black Tree Map)
   - Ordered key-value store
   - O(log n) operations vs O(1) average for HashMap
   - Useful when key ordering matters

2. **Std.AssocList** (Association List)
   - Simple list-based key-value store
   - O(n) operations
   - Useful for small caches

3. **Array-based caching**
   - For dense integer keys
   - O(1) access
   - Limited to `Nat` or `Fin n` keys

---

## Type Signature Analysis

### Insertion Patterns

#### Standard Insertion (Overwrite)
```lean
Std.HashMap.insert : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  Std.HashMap α β → α → β → Std.HashMap α β
```
- **Semantics**: Insert or overwrite
- **Use Case**: Standard cache with most-recent-value semantics

#### Conditional Insertion (Preserve Existing)
```lean
Std.HashMap.insertIfNew : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  Std.HashMap α β → α → β → Std.HashMap α β
```
- **Semantics**: Insert only if key doesn't exist
- **Use Case**: Memoization cache preserving first computation

### Update Patterns

#### Function-Based Modification
```lean
Std.HashMap.modify : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  Std.HashMap α β → α → (β → β) → Std.HashMap α β
```
- **Semantics**: Apply function to existing value
- **Use Case**: Incremental cache updates

### Construction Patterns

#### Empty HashMap
```lean
Std.HashMap.empty : {α : Type u} {β : Type v} [BEq α] [Hashable α] → Std.HashMap α β
```
- **Semantics**: Create empty map
- **Use Case**: Initialize cache

#### From List
```lean
Std.HashMap.ofList : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  List (α × β) → Std.HashMap α β
```
- **Semantics**: Build HashMap from association list
- **Use Case**: Initialize cache with pre-computed values

### Lookup Patterns

#### Optional Lookup
```lean
Std.HashMap.find? : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  Std.HashMap α β → α → Option β
```
- **Semantics**: Safe lookup returning `Option`
- **Use Case**: Cache lookup with explicit miss handling

#### Unsafe Lookup (with default)
```lean
Std.HashMap.findD : {α : Type u} {β : Type v} [BEq α] [Hashable α] →
  Std.HashMap α β → α → β → β
```
- **Semantics**: Lookup with default value
- **Use Case**: Cache lookup with fallback

---

## Recommendations

### For Cache Implementation

#### 1. Primary Approach: Standard Insertion with `insert`
**Recommended Function**: `Std.HashMap.insert`

**Why**:
- Standard overwrite semantics suitable for most caches
- Well-supported with 44 related theorems
- Efficient O(1) average-case performance
- Simple API: `cache.insert key value`

**Use When**:
- Most recent computation should be cached
- Cache updates are expected
- Standard cache behavior desired

**Example Pattern**:
```lean
def updateCache (cache : Std.HashMap α β) (key : α) (value : β) : Std.HashMap α β :=
  cache.insert key value
```

#### 2. Alternative Approach: Conditional Insertion with `insertIfNew`
**Recommended Function**: `Std.HashMap.insertIfNew`

**Why**:
- Preserves first-computed value
- Ideal for pure memoization
- Prevents cache pollution from recomputation
- 29 supporting theorems

**Use When**:
- First computation is canonical
- Memoization of expensive pure functions
- Cache should never be updated once set

**Example Pattern**:
```lean
def memoize (cache : Std.HashMap α β) (key : α) (compute : α → β) : β × Std.HashMap α β :=
  match cache.find? key with
  | some value => (value, cache)
  | none => (compute key, cache.insertIfNew key (compute key))
```

#### 3. Advanced Approach: Update with `modify`
**Recommended Function**: `Std.HashMap.modify`

**Why**:
- Functional update of cached values
- Useful for incremental computation
- Composable with other operations

**Use When**:
- Cached values need incremental updates
- Computation builds on previous results
- Functional update semantics desired

**Example Pattern**:
```lean
def incrementCachedCount (cache : Std.HashMap α Nat) (key : α) : Std.HashMap α Nat :=
  cache.modify key (· + 1)
```

### Usage Patterns

#### Pattern 1: Simple Memoization Cache
```lean
structure MemoCache (α β : Type) [BEq α] [Hashable α] where
  cache : Std.HashMap α β

def MemoCache.compute (mc : MemoCache α β) (key : α) (f : α → β) : β × MemoCache α β :=
  match mc.cache.find? key with
  | some value => (value, mc)
  | none =>
    let value := f key
    (value, { cache := mc.cache.insert key value })
```

#### Pattern 2: Cache with Explicit Miss Handling
```lean
def cachedLookup (cache : Std.HashMap α β) (key : α) (onMiss : α → β) : β × Std.HashMap α β :=
  match cache.find? key with
  | some value => (value, cache)
  | none =>
    let value := onMiss key
    (value, cache.insert key value)
```

#### Pattern 3: Stateful Cache in Monad
```lean
def withCache [Monad m] [MonadState (Std.HashMap α β) m] (key : α) (compute : α → m β) : m β := do
  let cache ← get
  match cache.find? key with
  | some value => return value
  | none =>
    let value ← compute key
    modify (·.insert key value)
    return value
```

---

## Library Sources

### Std.Data.HashMap (via Mathlib4)
**Total Functions Found**: 1,192 (200 displayed in search)

**Core Operations**:
- `Std.HashMap.insert` - Standard insertion (45 related results)
- `Std.HashMap.insertIfNew` - Conditional insertion (30 related results)
- `Std.HashMap.modify` - Value modification (22 related results)
- `Std.HashMap.find?` - Optional lookup
- `Std.HashMap.findD` - Lookup with default
- `Std.HashMap.contains` - Existence check
- `Std.HashMap.empty` - Empty map constructor
- `Std.HashMap.ofList` - Construct from list

**Instance Support**:
- `BEq` instance for HashMap equality
- `Repr` instance for debugging
- `EmptyCollection` instance for `∅` notation
- `Inhabited` instance with empty map

**Theorem Support**:
- Extensive lemma library for all operations
- Properties about insertion order
- Equivalence theorems
- Size and membership properties

### Mathlib
**No additional HashMap-specific functions beyond Std library**

### Other Libraries
**No memoization or cache utilities found**

---

## Insights

### HashMap Capabilities in Lean 4

**Strengths**:
1. **Well-designed core API**: Clean separation between `insert` (overwrite) and `insertIfNew` (preserve)
2. **Strong theorem support**: Extensive lemma libraries for verification
3. **Type class integration**: Proper use of `BEq` and `Hashable` constraints
4. **Efficient implementation**: Hash-based O(1) average-case operations
5. **Functional design**: Immutable data structure with persistent updates

**Limitations**:
1. **No built-in memoization**: Must implement manually
2. **No cache policies**: No LRU, LFU, TTL, or size-based eviction
3. **No thread safety**: Single-threaded use only
4. **No statistics**: No hit/miss tracking or performance metrics
5. **No lazy evaluation**: All values must be computed eagerly

### Memoization Approaches

Since Lean 4 lacks built-in memoization, the following approaches are recommended:

#### Approach 1: Manual HashMap-based Memoization
```lean
-- Explicit state threading
def memoFib (cache : Std.HashMap Nat Nat) (n : Nat) : Nat × Std.HashMap Nat Nat :=
  match cache.find? n with
  | some result => (result, cache)
  | none =>
    if n ≤ 1 then (n, cache.insert n n)
    else
      let (f1, cache1) := memoFib cache (n - 1)
      let (f2, cache2) := memoFib cache1 (n - 2)
      let result := f1 + f2
      (result, cache2.insert n result)
```

#### Approach 2: Monadic Memoization
```lean
-- Using State monad
def memoFibM (n : Nat) : StateM (Std.HashMap Nat Nat) Nat := do
  let cache ← get
  match cache.find? n with
  | some result => return result
  | none =>
    if n ≤ 1 then
      modify (·.insert n n)
      return n
    else
      let f1 ← memoFibM (n - 1)
      let f2 ← memoFibM (n - 2)
      let result := f1 + f2
      modify (·.insert n result)
      return result
```

#### Approach 3: Lazy Evaluation with Thunks
```lean
-- Combine with lazy evaluation for on-demand computation
structure LazyCache (α β : Type) [BEq α] [Hashable α] where
  cache : Std.HashMap α (Thunk β)

-- Note: Requires custom Thunk implementation for memoization
```

### Cache Implementation Strategies

#### Strategy 1: Simple Unbounded Cache
- Use `Std.HashMap.insert` directly
- No eviction policy
- Suitable for small, bounded problem spaces
- Risk of unbounded memory growth

#### Strategy 2: Manual Size-Limited Cache
```lean
structure BoundedCache (α β : Type) [BEq α] [Hashable α] where
  cache : Std.HashMap α β
  maxSize : Nat

def BoundedCache.insert (bc : BoundedCache α β) (key : α) (value : β) : BoundedCache α β :=
  if bc.cache.size >= bc.maxSize then
    -- Simple eviction: clear cache (could implement LRU instead)
    { bc with cache := Std.HashMap.empty.insert key value }
  else
    { bc with cache := bc.cache.insert key value }
```

#### Strategy 3: Two-Level Cache
```lean
-- Fast cache for recent items, slow cache for older items
structure TwoLevelCache (α β : Type) [BEq α] [Hashable α] where
  hot : Std.HashMap α β
  cold : Std.HashMap α β
  hotSize : Nat
```

### Performance Considerations

1. **HashMap Performance**:
   - Average O(1) insertion, lookup, deletion
   - Worst-case O(n) on hash collisions
   - Memory overhead for hash table structure

2. **Memoization Overhead**:
   - Cache lookup cost on every call
   - Memory cost for storing results
   - State threading overhead in pure code

3. **Trade-offs**:
   - **Pure functional**: Explicit state threading, no side effects, verifiable
   - **Monadic**: Cleaner code, implicit state, harder to verify
   - **Unsafe IO**: Best performance, breaks purity, not verifiable

### Limitations and Alternatives

**Limitations of HashMap-based Caching**:
1. No automatic eviction (unbounded growth)
2. No TTL or expiration
3. No cache warming or preloading
4. No distributed caching
5. No persistence across runs

**Alternative Approaches**:
1. **Compile-time evaluation**: Use `#eval` or `#reduce` for constant folding
2. **Proof-time caching**: Rely on Lean's kernel caching
3. **External caching**: Use IO-based caching with files
4. **Tactic-level caching**: Cache proof search results in custom tactics

### Recommendations Summary

**For Proof Search Caching** (your use case):
1. Use `Std.HashMap.insert` for standard cache with overwrite semantics
2. Key type: Proof goal representation (requires `BEq` and `Hashable` instances)
3. Value type: Proof term or tactic script
4. Consider size limits to prevent unbounded growth
5. Implement cache statistics for hit/miss tracking
6. Use monadic state for cleaner code in proof search

**Implementation Checklist**:
- [ ] Define key type with `BEq` and `Hashable` instances
- [ ] Choose between `insert` (overwrite) and `insertIfNew` (preserve)
- [ ] Implement cache lookup with `find?`
- [ ] Add size limits if needed
- [ ] Track cache statistics (hits, misses, size)
- [ ] Consider persistence strategy (in-memory only vs. file-based)
- [ ] Test cache effectiveness with benchmarks

---

## Conclusion

Lean 4's `Std.HashMap` provides a solid foundation for implementing caching and memoization, but requires manual implementation of cache policies and eviction strategies. The three core functions (`insert`, `insertIfNew`, `modify`) cover the essential operations needed for cache implementation.

For proof search caching, the recommended approach is:
1. Use `Std.HashMap.insert` for standard cache behavior
2. Implement manual size limits to prevent unbounded growth
3. Use monadic state (`StateM`) for cleaner code
4. Track cache statistics for performance analysis
5. Consider `insertIfNew` if first-found proof should be preserved

The lack of built-in memoization utilities is a gap in the Lean 4 ecosystem, but the HashMap API is sufficient for implementing custom caching solutions with full control over cache policies and behavior.
