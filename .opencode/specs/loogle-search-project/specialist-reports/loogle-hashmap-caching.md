# Loogle Search Results: HashMap and Caching Structures

**Date**: 2025-12-20
**Search Focus**: HashMap types, operations, and caching/memoization functions in LEAN 4
**Total Searches**: 9 queries
**Total Matches**: 1200+ results (categorized below)

---

## Executive Summary

This comprehensive search identified three main HashMap implementations in LEAN 4:
1. **Std.HashMap** - Standard non-dependent hash map (most common)
2. **Batteries.HashMap** - Alternative implementation with similar API
3. **Std.DHashMap** - Dependent hash map where value type depends on key

For **memoization and caching**, LEAN 4 provides:
- `memoFix` (Mathlib) - Main memoization combinator using pointer hashing
- Multiple cache types in Lean.Meta and Lean.Core for type inference and compilation
- AIG cache structures for SAT solving
- Tactic-specific caches (Ring, Batteries)

**Recommendation for Proof Search**: Use `Std.HashMap` with `memoFix` for caching proof search results.

---

## Search Results by Category

### 1. HashMap Type Constructors

#### Std.HashMap (Primary Implementation)

**Type**: `Std.HashMap : (α : Type u) (β : Type v) [BEq α] [Hashable α] : Type (max u v)`
- **Library**: Std
- **Module**: Std.Data.HashMap.Basic
- **Description**: Simple separate-chaining hash table with cached size and array of buckets. Doubles size when >75% full.
- **Requirements**: `BEq α` and `Hashable α` instances for key type

#### Batteries.HashMap (Alternative)

**Type**: `Batteries.HashMap : (α : Type u) (β : Type v) [BEq α] [Hashable α] : Type (max u v)`
- **Library**: Batteries
- **Module**: Batteries.Data.HashMap.Basic
- **Description**: Key-value map using hash function for lookups. Average O(1) lookup with perfect hash. Not persistent - use linearly for updates.
- **Requirements**: `BEq α` and `Hashable α` instances for key type

#### Std.DHashMap (Dependent Version)

**Type**: `Std.DHashMap : (α : Type u) (β : α → Type v) [BEq α] [Hashable α] : Type (max u v)`
- **Library**: Std
- **Module**: Std.Data.DHashMap.Basic
- **Description**: Dependent hash map where value type can depend on key. Same implementation strategy as HashMap.
- **Use Case**: When value type varies based on key (e.g., different proof types for different formulas)

---

### 2. HashMap Core Operations

#### Construction

1. **Std.HashMap.empty**
   - Type: `{α β : Type} [BEq α] [Hashable α] : Std.HashMap α β`
   - Creates empty hash map
   - Example: `(empty : Std.HashMap Int Int).toList = []`

2. **Std.mkHashMap**
   - Type: `{α β : Type} [BEq α] [Hashable α] (capacity : ℕ := 0) : Std.HashMap α β`
   - Creates hash map with specified initial capacity
   - Use for performance when size is known

3. **Batteries.HashMap.empty**
   - Type: `{α β : Type} [BEq α] [Hashable α] : Batteries.HashMap α β`
   - Batteries equivalent of empty constructor

4. **Std.HashMap.ofList**
   - Type: `{α β : Type} [BEq α] [Hashable α] (l : List (α × β)) : Std.HashMap α β`
   - Builds HashMap from list of pairs
   - Last occurrence wins for duplicate keys

#### Insertion

1. **Std.HashMap.insert**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) (b : β) : Std.HashMap α β`
   - Module: Std.Data.HashMap.Basic
   - **Behavior**: Replaces both key and value if key exists
   - **Note**: Different from HashSet.insert which preserves existing keys

2. **Batteries.HashMap.insert**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (self : Batteries.HashMap α β) (a : α) (b : β) : Batteries.HashMap α β`
   - Module: Batteries.Data.HashMap.Basic
   - Same replacement behavior as Std version

3. **Std.DHashMap.insertIfNew**
   - Type: `{α : Type u} {β : α → Type v} {_ : BEq α} {_ : Hashable α} (m : Std.DHashMap α β) (a : α) (b : β a) : Std.DHashMap α β`
   - Only inserts if key doesn't exist
   - Returns map unaltered if key present
   - **Use Case**: Caching - don't overwrite existing results

4. **Std.DHashMap.insertMany**
   - Type: `{α : Type u} {β : α → Type v} {_ : BEq α} {_ : Hashable α} {ρ : Type w} [ForIn Id ρ ((a : α) × β a)] (m : Std.DHashMap α β) (l : ρ) : Std.DHashMap α β`
   - Bulk insert from any iterable collection
   - Last occurrence wins for duplicates

#### Lookup

1. **Std.HashMap.find?**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) : Option β`
   - Returns `some value` if found, `none` otherwise
   - **Primary lookup method**

2. **Batteries.HashMap.find?**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (self : Batteries.HashMap α β) (a : α) : Option β`
   - Batteries equivalent

3. **Std.HashMap.findD**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) (b₀ : β) : β`
   - Returns default value `b₀` if not found
   - Avoids Option unwrapping

4. **Batteries.HashMap.find!**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} [Inhabited β] (self : Batteries.HashMap α β) (a : α) : β`
   - **Panics** if element not found
   - Use only when key existence is guaranteed

5. **Std.DHashMap.get?**
   - Type: `{α : Type u} {β : α → Type v} {_ : BEq α} {_ : Hashable α} [LawfulBEq α] (m : Std.DHashMap α β) (a : α) : Option (β a)`
   - Dependent version with type-correct return
   - Requires `LawfulBEq α` for type casting

6. **Std.HashMap.contains**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) : Bool`
   - Check existence without retrieving value
   - More efficient than `find?.isSome`

#### Modification

1. **Std.HashMap.modify**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) (f : β → β) : Std.HashMap α β`
   - In-place edit ensuring linear usage
   - **Use Case**: Update cached value based on old value

2. **Batteries.HashMap.modify**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (self : Batteries.HashMap α β) (a : α) (f : α → β → β) : Batteries.HashMap α β`
   - Passes both key and value to function
   - More flexible than Std version

3. **Std.DHashMap.modify**
   - Type: `{α : Type u} {β : α → Type v} {_ : BEq α} {_ : Hashable α} [LawfulBEq α] (m : Std.DHashMap α β) (a : α) (f : β a → β a) : Std.DHashMap α β`
   - Dependent version with type-correct modification

4. **Std.HashMap.erase**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) (a : α) : Std.HashMap α β`
   - Removes key from map
   - Returns unchanged map if key doesn't exist

#### Aggregation

1. **Std.HashMap.fold**
   - Type: `{α δ β : Type} {_ : BEq α} {_ : Hashable α} (f : δ → α → β → δ) (init : δ) (m : Std.HashMap α β) : δ`
   - Fold over elements in arbitrary order
   - **Use Case**: Collect statistics from cache

2. **Batteries.HashMap.fold**
   - Type: `{α δ β : Type} {_ : BEq α} {_ : Hashable α} (f : δ → α → β → δ) (init : δ) (self : Batteries.HashMap α β) : δ`
   - Batteries equivalent

3. **Std.HashMap.foldM**
   - Type: `{α δ β : Type} {m : Type → Type} {_ : BEq α} {_ : Hashable α} [Monad m] (f : δ → α → β → m δ) (init : δ) (self : Std.HashMap α β) : m δ`
   - Monadic fold for effectful operations

4. **Batteries.HashMap.forM**
   - Type: `{α β : Type} {m : Type → Type} {_ : BEq α} {_ : Hashable α} [Monad m] (f : α → β → m PUnit) (self : Batteries.HashMap α β) : m PUnit`
   - Iterate with monadic effects
   - **Use Case**: Print cache contents, validate entries

5. **Std.HashMap.mergeWith**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (f : α → β → β → β) (m₁ m₂ : Std.HashMap α β) : Std.HashMap α β`
   - Combine two maps using merge function
   - **Use Case**: Merge caches from parallel searches

#### Conversion

1. **Std.HashMap.toList**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) : List (α × β)`
   - Convert to list of pairs

2. **Batteries.HashMap.toArray**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (self : Batteries.HashMap α β) : Array (α × β)`
   - Convert to array of pairs

#### Queries

1. **Std.HashMap.isEmpty**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) : Bool`
   - Check if map is empty

2. **Std.HashMap.size**
   - Type: `{α β : Type} {_ : BEq α} {_ : Hashable α} (m : Std.HashMap α β) : ℕ`
   - Get number of elements
   - O(1) - cached value

---

### 3. Memoization Functions

#### Primary Memoization

1. **memoFix**
   - Type: `{α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β`
   - Library: Mathlib
   - Module: Mathlib.Util.MemoFix
   - **Description**: Takes fixpoint of `f` with caching of previously seen values
   - **Implementation**: Uses pointer hashing for efficient lookup
   - **Use Case**: Tree traversal where subtrees may be referenced multiple times
   - **Perfect for**: Recursive proof search with shared subgoals

#### Simp Memoization

2. **Lean.Meta.Simp.Config.memoize**
   - Type: `(self : Lean.Meta.Simp.Config) : Bool`
   - Library: Lean (Std)
   - Module: Init.MetaTypes
   - **Description**: Config flag for simplifier caching
   - Default: `true`
   - When enabled, simplifier caches result of simplifying each sub-expression

---

### 4. Cache Structures

#### AIG Cache (SAT Solving)

1. **Std.Sat.AIG.Cache**
   - Type: `(α : Type) [DecidableEq α] [Hashable α] (decls : Array (Std.Sat.AIG.Decl α)) : Type`
   - Library: Std
   - Module: Std.Sat.AIG.Basic
   - **Purpose**: Cache for reusing AIG elements from `decls`

2. **Std.Sat.AIG.Cache.empty**
   - Type: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} : Std.Sat.AIG.Cache α decls`
   - Create empty cache valid for any decl array

3. **Std.Sat.AIG.Cache.get?**
   - Type: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Option (Std.Sat.AIG.CacheHit decls decl)`
   - Lookup declaration in cache

4. **Std.Sat.AIG.Cache.insert**
   - Type: `{α : Type} [Hashable α] [DecidableEq α] (decls : Array (Std.Sat.AIG.Decl α)) (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Std.Sat.AIG.Cache α (decls.push decl)`
   - Extend cache and decls simultaneously
   - Maintains validity invariant

5. **Std.Sat.AIG.Cache.noUpdate**
   - Type: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} {decl : Std.Sat.AIG.Decl α} (cache : Std.Sat.AIG.Cache α decls) : Std.Sat.AIG.Cache α (decls.push decl)`
   - Extend decls without updating cache
   - Maintains validity

**Key Properties**:
- `Cache.get?_bounds`: Cache hits are within bounds
- `Cache.get?_property`: Cache hits return correct declaration

#### Lean Meta Cache

6. **Lean.Meta.Cache**
   - Type: `Type`
   - Library: Lean
   - Module: Lean.Meta.Basic
   - **Purpose**: Cache for type inference, type class resolution, whnf, definitional equality

**Components**:
- `inferType : Lean.Meta.InferTypeCache`
- `funInfo : Lean.Meta.FunInfoCache`
- `synthInstance : Lean.Meta.SynthInstanceCache`
- `whnf : Lean.Meta.WhnfCache`
- `defEqTrans : Lean.Meta.DefEqCache`
- `defEqPerm : Lean.Meta.DefEqCache`

7. **Lean.Meta.modifyCache**
   - Type: `(f : Lean.Meta.Cache → Lean.Meta.Cache) : Lean.MetaM Unit`
   - Modify meta cache in-place

#### Lean Core Cache

8. **Lean.Core.Cache**
   - Type: `Type`
   - Library: Lean
   - Module: Lean.CoreM
   - **Purpose**: Cache for CoreM monad

**Components**:
- `instLevelType : Lean.Core.InstantiateLevelCache`
- `instLevelValue : Lean.Core.InstantiateLevelCache`

9. **Lean.Core.modifyCache**
   - Type: `(f : Lean.Core.Cache → Lean.Core.Cache) : Lean.CoreM Unit`
   - Modify core cache

#### Batteries Tactic Cache

10. **Batteries.Tactic.Cache**
    - Type: `(α : Type) : Type`
    - Library: Batteries
    - Module: Batteries.Util.Cache
    - **Purpose**: Once-per-file cache for tactics

11. **Batteries.Tactic.Cache.mk**
    - Type: `{α : Type} (init : Lean.MetaM α) : IO (Batteries.Tactic.Cache α)`
    - Create cache with initialization function

12. **Batteries.Tactic.Cache.get**
    - Type: `{m : Type → Type} {α : Type} [Monad m] [Lean.MonadEnv m] [Lean.MonadLog m] [Lean.MonadOptions m] [MonadLiftT BaseIO m] [MonadExcept Lean.Exception m] (cache : Batteries.Tactic.Cache α) : m α`
    - Access cache, initializing on first call

#### Ring Tactic Cache

13. **Mathlib.Tactic.Ring.Cache**
    - Type: `{u : Lean.Level} {α : Q(Type u)} (sα : Q(CommSemiring $α)) : Type`
    - Library: Mathlib
    - Module: Mathlib.Tactic.Ring.Basic
    - **Purpose**: Cache for ring tactic execution

14. **Mathlib.Tactic.Ring.mkCache**
    - Type: `{u : Lean.Level} {α : Q(Type u)} (sα : Q(CommSemiring $α)) : Lean.MetaM (Mathlib.Tactic.Ring.Cache sα)`
    - Create cache by performing instance searches

**Precomputed Caches**:
- `Mathlib.Tactic.Ring.Cache.nat : Mathlib.Tactic.Ring.Cache Mathlib.Tactic.Ring.sℕ`
- `Mathlib.Tactic.Ring.Cache.int : Mathlib.Tactic.Ring.Cache Mathlib.Tactic.Ring.sℤ`

#### MonadCache Interface

15. **Lean.MonadCache.cache**
    - Type: `{α β : Type} {m : Type → Type} [self : Lean.MonadCache α β m] : α → β → m Unit`
    - Library: Lean
    - Module: Lean.Util.MonadCache
    - Generic caching interface for monads

---

### 5. HashMap Lemmas (Verification Support)

Std.HashMap provides extensive lemma support for verification:

#### Insert Lemmas

1. **Std.HashMap.isEmpty_insert**
   - `{α β : Type} {_ : BEq α} {_ : Hashable α} {m : Std.HashMap α β} [EquivBEq α] [LawfulHashable α] {k : α} {v : β} : (m.insert k v).isEmpty = false`
   - Inserted map is never empty

2. **Std.HashMap.contains_insert_self**
   - `{α β : Type} {_ : BEq α} {_ : Hashable α} {m : Std.HashMap α β} [EquivBEq α] [LawfulHashable α] {k : α} {v : β} : (m.insert k v).contains k = true`
   - Inserted key is always present

3. **Std.HashMap.mem_insert_self**
   - `{α β : Type} {_ : BEq α} {_ : Hashable α} {m : Std.HashMap α β} [EquivBEq α] [LawfulHashable α] {k : α} {v : β} : k ∈ m.insert k v`
   - Membership version of contains

4. **Std.HashMap.size_insert**
   - `{α β : Type} {_ : BEq α} {_ : Hashable α} {m : Std.HashMap α β} [EquivBEq α] [LawfulHashable α] {k : α} {v : β} : (m.insert k v).size = if k ∈ m then m.size else m.size + 1`
   - Size increases only for new keys

5. **Std.HashMap.getElem_insert_self**
   - `{α β : Type} {_ : BEq α} {_ : Hashable α} {m : Std.HashMap α β} [EquivBEq α] [LawfulHashable α] {k : α} {v : β} : (m.insert k v)[k] = v`
   - Retrieval returns inserted value

**Note**: 39+ additional insert lemmas available in Std.Data.HashMap.Lemmas

---

## Usage Patterns and Examples

### Pattern 1: Basic Cache for Proof Search

```lean
-- Define cache type
def ProofCache := Std.HashMap Formula Derivation

-- Initialize empty cache
def emptyCache : ProofCache := Std.HashMap.empty

-- Check cache before searching
def cachedProofSearch (cache : ProofCache) (goal : Formula) : Option Derivation :=
  cache.find? goal

-- Update cache with new result
def updateCache (cache : ProofCache) (goal : Formula) (proof : Derivation) : ProofCache :=
  cache.insert goal proof

-- Combined search with caching
def searchWithCache (cache : ProofCache) (goal : Formula) : ProofCache × Option Derivation :=
  match cache.find? goal with
  | some proof => (cache, some proof)  -- Cache hit
  | none =>                             -- Cache miss
    match proveGoal goal with
    | some proof => (cache.insert goal proof, some proof)
    | none => (cache, none)
```

### Pattern 2: Memoized Recursive Search

```lean
-- Use memoFix for recursive proof search with shared subgoals
def memoizedProofSearch : Formula → Option Derivation :=
  memoFix fun search goal =>
    match goal with
    | atom p => searchAxiom p
    | conj φ ψ =>
      match search φ, search ψ with  -- Recursive calls are memoized
      | some d₁, some d₂ => some (conjIntro d₁ d₂)
      | _, _ => none
    | _ => none
```

### Pattern 3: Cache with Statistics

```lean
structure CacheStats where
  hits : Nat
  misses : Nat
  size : Nat

def getCacheStats (cache : ProofCache) : CacheStats :=
  { hits := 0  -- Track separately
  , misses := 0
  , size := cache.size }

-- Fold over cache to collect information
def analyzeCache (cache : ProofCache) : List (Formula × Nat) :=
  cache.fold (fun acc goal proof => (goal, proof.size) :: acc) []
```

### Pattern 4: Conditional Insertion

```lean
-- Only cache if proof is small enough
def conditionalCache (cache : ProofCache) (goal : Formula) (proof : Derivation) : ProofCache :=
  if proof.size < 100 then
    cache.insert goal proof
  else
    cache  -- Don't cache large proofs

-- Use insertIfNew to avoid overwriting better proofs
def cacheIfBetter (cache : Std.DHashMap Formula (fun _ => Derivation)) 
                  (goal : Formula) (proof : Derivation) : _ :=
  match cache.get? goal with
  | none => cache.insert goal proof
  | some oldProof => 
    if proof.size < oldProof.size then
      cache.insert goal proof
    else
      cache
```

### Pattern 5: Merging Parallel Caches

```lean
-- Merge caches from parallel proof search
def mergeCaches (c₁ c₂ : ProofCache) : ProofCache :=
  c₁.mergeWith (fun _goal proof₁ proof₂ =>
    -- Keep smaller proof
    if proof₁.size ≤ proof₂.size then proof₁ else proof₂)
    c₂
```

---

## Recommendations for Proof Search Caching

### Primary Recommendation: Std.HashMap + memoFix

**For most proof search applications**:

1. **Use `Std.HashMap Formula Derivation`** for main cache
   - Well-tested, extensive lemma support
   - Good performance characteristics
   - Standard library - no extra dependencies

2. **Use `memoFix`** for recursive proof search
   - Automatic caching of recursive calls
   - Pointer hashing for efficiency
   - Handles shared subgoals naturally

3. **Implement cache wrapper**:
   ```lean
   structure ProofSearchState where
     cache : Std.HashMap Formula Derivation
     stats : CacheStats
   
   def searchWithState (state : ProofSearchState) (goal : Formula) 
       : ProofSearchState × Option Derivation :=
     match state.cache.find? goal with
     | some proof => 
       ({ state with stats.hits := state.stats.hits + 1 }, some proof)
     | none =>
       match proveGoal goal with
       | some proof => 
         ({ cache := state.cache.insert goal proof
          , stats := { state.stats with misses := state.stats.misses + 1 } }
         , some proof)
       | none => 
         ({ state with stats.misses := state.stats.misses + 1 }, none)
   ```

### Alternative: Std.DHashMap for Type-Dependent Proofs

**If proof type depends on formula**:

Use `Std.DHashMap Formula (fun φ => Derivation φ)` where `Derivation : Formula → Type`

Benefits:
- Type-safe: proof type matches formula
- Prevents type mismatches
- Better for dependently-typed proof systems

Drawbacks:
- Requires `LawfulBEq` instance
- Slightly more complex API
- Type casting overhead

### Cache Size Management

**Strategies**:

1. **Bounded Cache**: Limit by size
   ```lean
   def boundedInsert (cache : ProofCache) (goal : Formula) (proof : Derivation) 
       (maxSize : Nat) : ProofCache :=
     if cache.size < maxSize then
       cache.insert goal proof
     else
       cache  -- Or implement LRU eviction
   ```

2. **Selective Caching**: Only cache small proofs
   ```lean
   def selectiveInsert (cache : ProofCache) (goal : Formula) (proof : Derivation) 
       (maxProofSize : Nat) : ProofCache :=
     if proof.size ≤ maxProofSize then
       cache.insert goal proof
     else
       cache
   ```

3. **Priority Caching**: Cache frequently-used formulas
   ```lean
   structure PriorityCache where
     cache : Std.HashMap Formula Derivation
     frequency : Std.HashMap Formula Nat
   
   def priorityInsert (pc : PriorityCache) (goal : Formula) (proof : Derivation) 
       : PriorityCache :=
     let freq := pc.frequency.findD goal 0 + 1
     if freq ≥ 3 then  -- Only cache after 3 uses
       { cache := pc.cache.insert goal proof
       , frequency := pc.frequency.insert goal freq }
     else
       { pc with frequency := pc.frequency.insert goal freq }
   ```

### Performance Considerations

1. **Hash Function Quality**:
   - Ensure `Hashable Formula` instance is well-distributed
   - Poor hash function → clustering → O(n) lookup

2. **Initial Capacity**:
   - Use `mkHashMap capacity` if size is predictable
   - Avoids repeated resizing

3. **Linear Usage**:
   - HashMap is not persistent
   - Avoid copying large maps
   - Use modify/fold for in-place updates

4. **Verification**:
   - Use lemmas from Std.Data.HashMap.Lemmas
   - Prove cache correctness properties
   - Ensure `EquivBEq` and `LawfulHashable` instances

---

## Implementation Checklist

For implementing proof search caching:

- [ ] Define `Hashable Formula` instance
- [ ] Define `BEq Formula` instance  
- [ ] Prove `LawfulBEq Formula` (for verification)
- [ ] Prove `LawfulHashable Formula` (for verification)
- [ ] Choose HashMap type (Std.HashMap vs Std.DHashMap)
- [ ] Implement cache wrapper with statistics
- [ ] Implement cache lookup before search
- [ ] Implement cache update after successful search
- [ ] Add cache size management strategy
- [ ] Consider using memoFix for recursive search
- [ ] Add cache hit/miss tracking
- [ ] Implement cache analysis/debugging tools
- [ ] Prove cache correctness properties
- [ ] Benchmark cache performance
- [ ] Document cache behavior and limitations

---

## Related Searches

For further exploration:

1. **HashSet**: `Std.HashSet`, `Batteries.HashSet` - for tracking visited states
2. **RBMap**: `Std.RBMap` - ordered alternative to HashMap
3. **Array**: For dense integer-indexed caching
4. **Trie**: For prefix-based formula caching
5. **Persistent Data Structures**: For backtracking search

---

## References

- **Std.Data.HashMap.Basic**: Core HashMap implementation
- **Std.Data.HashMap.Lemmas**: Verification lemmas (45+ lemmas)
- **Std.Data.DHashMap.Basic**: Dependent HashMap (1030+ definitions)
- **Batteries.Data.HashMap.Basic**: Alternative implementation
- **Mathlib.Util.MemoFix**: Memoization combinator
- **Std.Sat.AIG.Basic**: Example cache implementation for SAT solving
- **Lean.Meta.Basic**: Meta-level caching infrastructure
- **Batteries.Util.Cache**: Tactic-level caching utilities

---

## Summary Statistics

- **HashMap Types**: 3 (Std.HashMap, Batteries.HashMap, Std.DHashMap)
- **Core Operations**: 25+ (insert, find, modify, fold, etc.)
- **Verification Lemmas**: 45+ for Std.HashMap
- **Cache Structures**: 6 specialized caches (AIG, Meta, Core, Tactic, Ring, MonadCache)
- **Memoization Functions**: 1 primary (memoFix)
- **Total Matches**: 1200+ across all searches

**Most Relevant for Proof Search**:
1. `Std.HashMap.empty` - Initialize cache
2. `Std.HashMap.find?` - Check cache
3. `Std.HashMap.insert` - Update cache
4. `memoFix` - Memoize recursive search
5. `Std.HashMap.size` - Monitor cache growth
6. `Std.HashMap.fold` - Analyze cache contents
7. `Std.HashMap.mergeWith` - Combine parallel caches
8. `Std.DHashMap.insertIfNew` - Conditional caching
9. `Std.HashMap.modify` - Update existing entries
10. `Std.HashMap.contains` - Fast existence check
