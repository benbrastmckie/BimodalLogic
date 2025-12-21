# Loogle Search Results: Cache, Memoization, and State Management Patterns

**Date**: 2025-12-20  
**Specialist**: Loogle Type-Based Search  
**Query Scope**: Caching, memoization, and state management in LEAN 4 libraries

---

## Executive Summary

This comprehensive search identified **extensive caching and state management infrastructure** across LEAN 4's standard library, Batteries, and Mathlib. The search executed 11 distinct queries covering type patterns and name-based searches, yielding thousands of relevant declarations.

**Key Findings**:
- **HashMap-based caching** is the primary pattern (6,786+ declarations)
- **StateM/StateT monads** provide stateful computation primitives (43 + 102 declarations)
- **Specialized caching systems** exist for SAT solving (AIG cache), simplification, and proof search
- **RBMap** provides ordered map alternative (199 declarations)
- **Minimal direct memoization support** - only `memoFix` and simplifier config flags

**Recommended Approach for Proof Search Caching**:
1. Use `Std.HashMap` for general-purpose caching (most mature, well-documented)
2. Use `StateT` monad transformer for stateful proof search
3. Consider `Lean.PersistentHashMap` for persistent data structures
4. Study AIG cache system for inspiration on cache correctness proofs

---

## 1. Type Pattern Matches

### 1.1 HashMap Lookup Pattern: `HashMap _ _ → _ → Option _`

**Matches Found**: 3 core functions

#### **Std.HashMap.get?**
- **Type**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) : Option β`
- **Module**: `Std.Data.HashMap.Basic`
- **Library**: Std (Lean Standard Library)
- **Documentation**: Tries to retrieve the mapping for the given key, returning `none` if no such mapping is present. The notation `m[a]?` is preferred over calling this function directly.
- **Relevance**: **PRIMARY CACHE LOOKUP PATTERN** - This is the standard way to check if a value exists in cache

#### **Std.HashMap.getKey?**
- **Type**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) : Option α`
- **Module**: `Std.Data.HashMap.Basic`
- **Library**: Std
- **Documentation**: Checks if a mapping for the given key exists and returns the key if it does, otherwise `none`. The result in the `some` case is guaranteed to be pointer equal to the key in the map.
- **Relevance**: Useful when you need to retrieve the canonical key representation from cache

#### **Std.HashMap.findEntry?**
- **Type**: `{α : Type u_1} {β : Type u_2} [BEq α] [Hashable α] (m : Std.HashMap α β) (k : α) : Option (α × β)`
- **Module**: `Batteries.Data.HashMap.Basic`
- **Library**: Batteries
- **Documentation**: Given a key `a`, returns a key-value pair in the map whose key compares equal to `a`. Note that the returned key may not be identical to the input, if `==` ignores some part of the value.
- **Relevance**: Returns both key and value, useful for cache entries with metadata

---

### 1.2 Cache with Fallback Pattern: `_ → _ → (_ → _) → _`

**Note**: Loogle requires at least one named constant in patterns. The cache-with-fallback pattern is represented by `getD` and `findD` functions.

**Matches Found**: 8+ core functions

#### **Std.HashMap.getD**
- **Type**: `{α : Type u} {β : Type v} {BEq α} {Hashable α} (m : Std.HashMap α β) (a : α) (fallback : β) : β`
- **Module**: `Std.Data.HashMap.Basic`
- **Library**: Std
- **Documentation**: Tries to retrieve the mapping for the given key, returning `fallback` if no such mapping is present.
- **Relevance**: **PRIMARY CACHE-WITH-FALLBACK PATTERN** - Essential for proof search with computation fallback

#### **Option.getD**
- **Type**: `{α : Type u_1} (opt : Option α) (dflt : α) : α`
- **Module**: `Init.Prelude`
- **Library**: Lean Core
- **Documentation**: Gets an optional value, returning a given default on `none`. This function is `@[macro_inline]`, so `dflt` will not be evaluated unless `opt` turns out to be `none`.
- **Relevance**: Fundamental pattern for cache miss handling with lazy evaluation

#### **List.getD**
- **Type**: `{α : Type u_1} (as : List α) (i : ℕ) (fallback : α) : α`
- **Module**: `Init.Data.List.BasicAux`
- **Library**: Lean Core
- **Documentation**: Returns the element at the provided index, counting from `0`. Returns `fallback` if the index is out of bounds.
- **Relevance**: Useful for indexed cache structures

#### **Array.getD**
- **Type**: `{α : Type u_1} (a : Array α) (i : ℕ) (v₀ : α) : α`
- **Module**: `Init.Prelude`
- **Library**: Lean Core
- **Documentation**: Returns the element at the provided index, counting from `0`. Returns the fallback value `v₀` if the index is out of bounds.
- **Relevance**: Array-based cache with bounds-safe access

#### **Lean.PersistentHashMap.findD**
- **Type**: `{α : Type u_1} {β : Type u_2} {BEq α} {Hashable α} (m : Lean.PersistentHashMap α β) (a : α) (b₀ : β) : β`
- **Module**: `Lean.Data.PersistentHashMap`
- **Library**: Lean Core
- **Relevance**: **PERSISTENT CACHE PATTERN** - Useful for immutable cache structures in proof search

#### **Batteries.HashMap.findD**
- **Type**: `{α : Type u_1} {BEq α} {Hashable α} {β : Type u_2} (self : Batteries.HashMap α β) (a : α) (b₀ : β) : β`
- **Module**: `Batteries.Data.HashMap.Basic`
- **Library**: Batteries (Legacy)
- **Documentation**: Looks up an element in the map with key `a`. Returns `b₀` if the element is not found.
- **Relevance**: Alternative HashMap implementation

---

### 1.3 StateM Pattern: `StateM _ _`

**Matches Found**: 39 declarations

**Core StateM Operations**:

#### **StateM Type**
- **Type**: `(σ : Type u) (α : Type u) : Type u`
- **Module**: `Init.Control.State`
- **Library**: Lean Core
- **Documentation**: State monad - computation that carries mutable state of type `σ` and returns value of type `α`
- **Relevance**: **FUNDAMENTAL STATEFUL COMPUTATION PATTERN** for proof search with cache state

**Key StateM Functions**:

1. **StateM.run**: `{σ α : Type u} (x : StateM σ α) (s : σ) : α × σ`
   - Execute stateful computation with initial state, return value and final state

2. **StateM.run'**: `{σ α : Type u} (x : StateM σ α) (s : σ) : α`
   - Execute stateful computation, discard final state

3. **StateM.get**: `{σ : Type u} : StateM σ σ`
   - Retrieve current state

4. **StateM.set**: `{σ : Type u} (s : σ) : StateM σ Unit`
   - Replace current state

5. **StateM.modify**: `{σ : Type u} (f : σ → σ) : StateM σ Unit`
   - Modify state in-place

**Notable StateM Use Cases in LEAN**:

- **Lean.sanitizeName**: `(userName : Lean.Name) : StateM Lean.NameSanitizerState Lean.Name`
  - Name sanitization with state tracking

- **Lean.HasConstCache.contains**: `{declNames : Array Lean.Name} (e : Lean.Expr) : StateM (Lean.HasConstCache declNames) Bool`
  - **CACHE CHECKING WITH STATE** - Direct example of cache + StateM pattern

- **Mathlib.Tactic.ITauto.prove**: `(Γ : Context) (B : IProp) : StateM ℕ (Bool × Proof)`
  - Proof search with state (fresh name generation)

- **Mathlib.Tactic.Order.Graph.tarjanDFS**: `(g : Graph) (v : ℕ) : StateM TarjanState Unit`
  - Graph algorithm with state (SCC finding)

---

### 1.4 StateT Pattern: `StateT _ _ _`

**Matches Found**: 102 declarations

**Core StateT Operations**:

#### **StateT Type**
- **Type**: `(σ : Type u) (m : Type u → Type v) (α : Type u) : Type (max u v)`
- **Module**: `Init.Control.State`
- **Library**: Lean Core
- **Documentation**: State monad transformer - adds mutable state to any monad `m`
- **Relevance**: **COMPOSABLE STATEFUL COMPUTATION** - Combine state with IO, error handling, etc.

**Key StateT Functions**:

1. **StateT.get**: `{σ : Type u} {m : Type u → Type v} [Monad m] : StateT σ m σ`
   - Retrieve current state in transformer

2. **StateT.set**: `{σ : Type u} {m : Type u → Type v} [Monad m] : σ → StateT σ m PUnit`
   - Replace state in transformer

3. **StateT.run**: `{σ : Type u} {m : Type u → Type v} {α : Type u} (x : StateT σ m α) (s : σ) : m (α × σ)`
   - Execute transformer, return value and state in underlying monad

4. **StateT.lift**: `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (t : m α) : StateT σ m α`
   - Lift computation from underlying monad

**StateT Use Cases**:

- **Lean.Doc.getPositional**: `{α : Type} [FromDocArg α] (name : Name) : StateT (Array DocArg) DocM α`
  - Documentation parsing with state

- **Lean.Server.RpcEncodable.rpcEncode**: `{α : Type} [RpcEncodable α] : α → StateT RpcObjectStore Lean.Json`
  - RPC encoding with object store state

- **Std.Do.WP support**: Multiple weakest precondition lemmas for StateT
  - Formal verification of stateful code

---

## 2. Name-Based Matches

### 2.1 "cache" - 569 Declarations

**Primary Cache Systems**:

#### **AIG Cache System** (Std.Sat.AIG - And-Inverter Graph)

The most sophisticated caching system with **proven correctness properties**:

**Core Types**:

1. **Std.Sat.AIG.Cache**
   - **Type**: `(α : Type) [DecidableEq α] [Hashable α] (decls : Array (Std.Sat.AIG.Decl α)) : Type`
   - **Module**: `Std.Sat.AIG.Basic`
   - **Documentation**: A cache for reusing elements from `decls` if they are available.
   - **Relevance**: **CACHE WITH CORRECTNESS PROOFS** - Excellent model for verified caching

2. **Std.Sat.AIG.CacheHit**
   - **Type**: `{α : Type} (decls : Array (Std.Sat.AIG.Decl α)) (decl : Std.Sat.AIG.Decl α) : Type`
   - **Documentation**: Contains the index of `decl` in `decls` along with a proof that the index is indeed correct.
   - **Fields**: `idx : ℕ`, `hbound : idx < decls.size`, `hvalid : decls[idx] = decl`
   - **Relevance**: **CACHE HIT WITH PROOF** - Cache lookup returns proof of correctness

**AIG Cache Operations**:

- **Cache.empty**: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Decl α)} : Cache α decls`
  - Create empty cache valid for any decl array

- **Cache.get?**: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Decl α)} (cache : Cache α decls) (decl : Decl α) : Option (CacheHit decls decl)`
  - Lookup with proof of correctness on hit

- **Cache.insert**: `{α : Type} [Hashable α] [DecidableEq α] (decls : Array (Decl α)) (cache : Cache α decls) (decl : Decl α) : Cache α (decls.push decl)`
  - Insert maintaining cache validity

- **Cache.WF**: `{α : Type} [Hashable α] [DecidableEq α] : Array (Decl α) → HashMap (Decl α) ℕ → Prop`
  - Well-formedness predicate for cache correctness

**Cached AIG Operations**:

- **mkAtomCached**, **mkConstCached**, **mkGateCached**: Cached construction operations
- **mkAndCached**, **mkOrCached**, **mkXorCached**, **mkNotCached**: Cached logical gates
- All use builtin cache for automated subterm sharing

#### **Lean Core Cache Types**:

1. **Lean.MonadCache.cache**
   - Part of MonadCache typeclass for cacheable monads

2. **Lean.Core.Cache**
   - Cache structure for Lean's core monad

3. **Lean.Meta.Cache**
   - Cache structure for Lean's meta monad
   - Used throughout elaboration and type checking

4. **Lean.Meta.Simp.Cache**
   - Simplifier cache for memoizing simplification results

5. **Lean.HasConstCache.cache**
   - Cache for constant occurrence checking in expressions

#### **BV Decision Procedure Caches**:

- **Std.Tactic.BVDecide.BVExpr.Cache**: Bit-vector expression caching
- **Std.Tactic.BVDecide.BVExpr.Return.cache**: Return value caching
- **Std.Tactic.BVDecide.BVExpr.WithCache.cache**: Computation with cache

#### **Other Specialized Caches**:

- **Batteries.Tactic.Cache**: Tactic-level caching
- **Mathlib.Tactic.Ring.Cache**: Ring tactic caching
- **Lean.Elab.Tactic.Omega.Cache**: Omega tactic caching
- **Lean.Meta.LazyDiscrTree.Cache**: Discrimination tree caching

---

### 2.2 "memo" - 119 Declarations

**Primary Memoization Functions**:

#### **memoFix**
- **Type**: `{α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β`
- **Module**: `Mathlib.Util.MemoFix`
- **Library**: Mathlib
- **Documentation**: Takes the fixpoint of `f` with caching of values that have been seen before. Hashing makes use of a pointer hash. This is useful for implementing tree traversal functions where subtrees may be referenced in multiple places.
- **Relevance**: **ONLY GENERAL-PURPOSE MEMOIZATION FUNCTION** - Uses pointer hashing for automatic memoization

**Simplifier Memoization**:

#### **Lean.Meta.Simp.Config.memoize**
- **Type**: `(self : Lean.Meta.Simp.Config) : Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Lean Core
- **Documentation**: When true (default: `true`) then the simplifier caches the result of simplifying each sub-expression, if possible.
- **Relevance**: **SIMPLIFIER CACHING CONTROL** - Shows how LEAN's simplifier uses memoization

#### **Lean.Meta.Simp.Context.setMemoize**
- **Type**: `(c : Lean.Meta.Simp.Context) (flag : Bool) : Lean.Meta.Simp.Context`
- **Module**: `Lean.Meta.Tactic.Simp.Types`
- **Relevance**: Programmatic control of simplifier memoization

**Memory Management Functions** (119 total):

- **System memory queries**: `availableMemory`, `totalMemory`, `freeMemory`, `constrainedMemory`
- **LLVM memory buffers**: `LLVM.MemoryBuffer`, `createMemoryBufferWithContentsOfFile`
- **Kernel exceptions**: `Lean.Kernel.Exception.excessiveMemory`
- **Decidable membership**: Many `instDecidableMem` instances for various data structures

**Iterator Memoization**:

- **Std.Iterators.Zip.memoizedLeft**: Memoized left iterator in zip combinator
- Related theorems for correctness of memoized iteration

---

### 2.3 "memoize" - 6 Declarations

**All Memoization-Related Functions**:

1. **Lean.Meta.Simp.Config.memoize** (see above)
2. **Lean.Meta.Simp.Context.setMemoize** (see above)
3. **Std.Iterators.Zip.memoizedLeft** (see above)
4. **Std.Iterators.Zip.rel₁_of_memoizedLeft**: Correctness theorem
5. **Std.Iterators.Zip.rel₂_of_memoizedLeft**: Correctness theorem
6. **Std.Iterators.Zip.rel₃_of_memoizedLeft**: Correctness theorem

**Key Insight**: LEAN 4 has minimal explicit memoization support. Caching is primarily done through:
- HashMap-based manual caching
- StateM/StateT for stateful cache management
- Simplifier's built-in memoization
- `memoFix` for recursive function memoization

---

### 2.4 "lookup" - 137 Declarations

**Core Lookup Functions**:

#### **List.lookup**
- **Type**: `{α : Type u} {β : Type v} [BEq α] : α → List (α × β) → Option β`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean Core
- **Complexity**: `O(|l|)`
- **Documentation**: Treats the list as an association list that maps keys to values, returning the first value whose key is equal to the specified key.
- **Relevance**: **ASSOCIATION LIST LOOKUP** - Simple cache implementation

**List.lookup Theorems** (17 theorems):
- `lookup_nil`, `lookup_cons`, `lookup_cons_self`
- `lookup_eq_none_iff`, `lookup_isSome_iff`, `lookup_eq_some_iff`
- `lookup_append`, `lookup_singleton`
- Interaction with sublists, prefixes, suffixes

#### **Lean Server Lookup**:

- **Lean.Server.lookupLspRequestHandler**: `(method : String) : IO (Option RequestHandler)`
- **Lean.Server.lookupStatefulLspRequestHandler**: `(method : String) : BaseIO (Option StatefulRequestHandler)`
- **Relevance**: Dynamic handler lookup in LSP server

#### **Metaprogramming Lookup**:

- **mkNatLookupTable**: `(i type : Lean.Expr) (es : Array Lean.Expr) : Lean.MetaM Lean.Expr`
  - Builds expression for `Nat → type` using binary search
  - **Relevance**: Efficient lookup table construction

- **Lean.Elab.Tactic.Omega.lookup**: `(e : Lean.Expr) : OmegaM (ℕ × Option (List Lean.Expr))`
  - Look up expression in atoms, record if new
  - **Relevance**: Tactic-level expression caching

- **Lean.Elab.Tactic.BVDecide.Frontend.M.lookup**: `(e : Lean.Expr) (width : ℕ) (synthetic : Bool) : M ℕ`
  - Look up expression in atoms
  - **Relevance**: BV tactic expression caching

#### **Mathlib Lookup Functions**:

- **List.dlookup**: `{α : Type u} {β : α → Type v} [DecidableEq α] (a : α) : List (Sigma β) → Option (β a)`
  - Dependent lookup in sigma list

- **List.lookupAll**: `{α : Type u} {β : α → Type v} [DecidableEq α] (a : α) : List (Sigma β) → List (β a)`
  - All values for a key

- **AList.lookup**: `{α : Type u} {β : α → Type v} [DecidableEq α] (a : α) (s : AList β) : Option (β a)`
  - Association list lookup

- **Finmap.lookup**: `{α : Type u} {β : α → Type v} [DecidableEq α] (a : α) (s : Finmap β) : Option (β a)`
  - Finite map lookup

---

### 2.5 "insert" - 5,606 Declarations

**Core Insert Operations**:

#### **Insert Type Class**
- **Type**: `Insert α γ` where `insert : α → γ → γ`
- **Module**: `Init.Core`
- **Documentation**: Generic insert operation, used for `{ a, b, c }` syntax
- **Relevance**: Polymorphic insertion interface

#### **List.insert**
- **Type**: `{α : Type u} [BEq α] : α → List α → List α`
- **Module**: `Init.Data.List.Basic`
- **Documentation**: Inserts element without duplication (if present, returns list unchanged)
- **Relevance**: Set-like insertion

#### **List.insertIdx**
- **Type**: `{α : Type u} : ℕ → α → List α → List α`
- **Module**: `Init.Data.List.Basic`
- **Documentation**: Inserts at specific index
- **Relevance**: Positional insertion

#### **Array.insertIdx**
- **Type**: `{α : Type u} (a : Array α) (i : Nat) (v : α) (h : i ≤ a.size) : Array α`
- **Module**: `Init.Data.Array.Basic`
- **Documentation**: Safe insertion at index with proof
- **Relevance**: Verified array insertion

**Hash-based Insert**:

- **Std.HashMap.insert**: `{α β : Type} {BEq α} {Hashable α} (m : HashMap α β) (a : α) (b : β) : HashMap α β`
  - **PRIMARY CACHE INSERT OPERATION**
  - Replaces both key and value if key exists

- **Std.HashMap.insertIfNew**: `{α β : Type} {BEq α} {Hashable α} (m : HashMap α β) (a : α) (b : β) : HashMap α β`
  - Insert only if key doesn't exist
  - **Relevance**: Cache-miss-only insertion

- **Std.HashSet.insert**: Set insertion
- **Std.DHashMap.insert**: Dependent hash map insertion

**Tree-based Insert**:

- **Batteries.RBMap.insert**: `{α β : Type} {cmp : α → α → Ordering} (t : RBMap α β cmp) (k : α) (v : β) : RBMap α β cmp`
  - **Complexity**: `O(log n)`
  - **Relevance**: Ordered cache insertion

- **Batteries.RBSet.insert**: Ordered set insertion
- **Lean.RBMap.insert**: Lean's RBMap insertion

**Specialized Insert**:

- **Lean.KVMap.insert**: Key-value map insertion
- **Lean.PersistentHashMap.insert**: Persistent hash map insertion
- **Lean.NameMap.insert**: Name-keyed map insertion
- **Lean.Meta.DiscrTree.insert**: Discrimination tree insertion

---

### 2.6 "HashMap" - 6,786 Declarations

**Primary Implementation: Std.HashMap**

#### **Std.HashMap Type**
- **Type**: `(α : Type u) (β : Type v) [BEq α] [Hashable α] : Type (max u v)`
- **Module**: `Std.Data.HashMap.Basic`
- **Library**: Std (Lean Standard Library)
- **Documentation**: Hash maps. This is a simple separate-chaining hash table. The data consists of a cached size and an array of buckets, where each bucket is a linked list of key-value pairs. The number of buckets is always a power of two. The hash map doubles its size when elements exceed 75% of bucket capacity. Backed by an `Array` - users should ensure linear usage to avoid expensive copies. Uses `==` (BEq) for key comparison and `hash` (Hashable) for hashing. Contains a bundled well-formedness invariant.
- **Relevance**: **RECOMMENDED PRIMARY CACHE IMPLEMENTATION**

**Construction Functions** (11 functions):

1. **emptyWithCapacity**: `{α β : Type} [BEq α] [Hashable α] (capacity : ℕ := 8) : HashMap α β`
   - Create empty map with optional capacity
   - **Relevance**: Pre-sized cache creation

2. **ofArray**: `{α β : Type} [BEq α] [Hashable α] (a : Array (α × β)) : HashMap α β`
   - Build from array (last occurrence wins)

3. **ofList**: `{α β : Type} [BEq α] [Hashable α] (l : List (α × β)) : HashMap α β`
   - Build from list (last occurrence wins)

4. **unitOfArray**: Build map with Unit values (for HashSet)
5. **unitOfList**: Build map with Unit values (for HashSet)

**Query Functions** (13 functions):

1. **isEmpty**: `Bool` - Check if empty
2. **size**: `ℕ` - Number of mappings
3. **contains**: `α → Bool` - Check key existence
4. **get?**: `α → Option β` - Lookup with Option (notation: `m[a]?`)
5. **getD**: `α → β → β` - Lookup with default
6. **get!**: `[Inhabited β] → α → β` - Lookup with panic
7. **get**: `(a : α) → (h : a ∈ m) → β` - Lookup with proof (notation: `m[a]`)
8. **getKey?**: `α → Option α` - Get canonical key
9. **getKeyD**: `α → α → α` - Get canonical key with default
10. **getKey!**: `[Inhabited α] → α → α` - Get canonical key with panic
11. **getKey**: `(a : α) → (h : a ∈ m) → α` - Get canonical key with proof

**Modification Functions** (7 functions):

1. **insert**: `α → β → HashMap α β` - Insert/replace mapping
   - **Relevance**: PRIMARY CACHE UPDATE

2. **insertIfNew**: `α → β → HashMap α β` - Insert only if new
   - **Relevance**: Cache-miss-only update

3. **erase**: `α → HashMap α β` - Remove mapping
   - **Relevance**: Cache eviction

4. **modify**: `α → (β → β) → HashMap α β` - In-place modify value
   - **Relevance**: Efficient cache update

5. **alter**: `α → (Option β → Option β) → HashMap α β` - Insert/modify/delete
   - **Relevance**: Flexible cache manipulation

**Combined Operations** (3 functions):

1. **containsThenInsert**: `α → β → Bool × HashMap α β`
   - Check + unconditional insert
   - **Relevance**: Atomic check-and-insert

2. **containsThenInsertIfNew**: `α → β → Bool × HashMap α β`
   - Check + conditional insert
   - **Relevance**: Efficient cache-miss handling

3. **getThenInsertIfNew?**: `α → β → Option β × HashMap α β`
   - Get + conditional insert
   - **Relevance**: Get-or-create pattern

**Bulk Operations** (2 functions):

1. **insertMany**: `{ρ : Type} [ForIn Id ρ (α × β)] → ρ → HashMap α β`
   - Insert multiple mappings
   - **Relevance**: Batch cache population

2. **insertManyIfNewUnit**: For HashSet implementation

**Set Operations** (3 functions):

1. **union**: `HashMap α β → HashMap α β → HashMap α β`
   - **Complexity**: `O(min(m₁.size, m₂.size))`
   - **Relevance**: Cache merging

2. **inter**: `HashMap α β → HashMap α β → HashMap α β`
   - **Complexity**: `O(min(m₁.size, m₂.size))`
   - **Relevance**: Cache intersection

3. **diff**: `HashMap α β → HashMap α β → HashMap α β`
   - **Complexity**: `O(min(m₁.size, m₂.size))`
   - **Relevance**: Cache difference

**Filtering Functions** (4 functions):

1. **filter**: `(α → β → Bool) → HashMap α β → HashMap α β`
   - Remove mappings not satisfying predicate

2. **partition**: `(α → β → Bool) → HashMap α β → HashMap α β × HashMap α β`
   - Split into two maps

3. **all**: `(α → β → Bool) → Bool`
   - Check all elements satisfy predicate

4. **any**: `(α → β → Bool) → Bool`
   - Check any element satisfies predicate

**Transformation Functions** (2 functions):

1. **map**: `(α → β → γ) → HashMap α β → HashMap α γ`
   - Transform all values

2. **filterMap**: `(α → β → Option γ) → HashMap α β → HashMap α γ`
   - Transform and filter

**Conversion Functions** (8 functions):

1. **toArray**: `Array (α × β)` - Convert to array
2. **toList**: `List (α × β)` - Convert to list
3. **keys**: `List α` - All keys as list
4. **keysArray**: `Array α` - All keys as array
5. **values**: `List β` - All values as list
6. **valuesArray**: `Array β` - All values as array

**Iteration Functions** (4 functions):

1. **fold**: `(γ → α → β → γ) → γ → HashMap α β → γ`
   - Fold over mappings

2. **foldM**: `[Monad m] → (γ → α → β → m γ) → γ → HashMap α β → m γ`
   - Monadic fold

3. **forM**: `[Monad m] → (α → β → m PUnit) → HashMap α β → m PUnit`
   - Monadic iteration

4. **forIn**: Support for `for` loops in `do` blocks

**Iterator Functions** (3 functions):

1. **keysIter**: `Std.Iter α` - Finite iterator over keys
2. **valuesIter**: `Std.Iter β` - Finite iterator over values
3. **iter**: `Std.Iter (α × β)` - Finite iterator over entries

**Comparison Functions** (2 functions):

1. **beq**: `[BEq α] [BEq β] → HashMap α β → HashMap α β → Bool`
   - Boolean equality

2. **Equiv**: `HashMap α β → HashMap α β → Prop`
   - Propositional equivalence

**Utility Functions**:

- **Array.groupByKey**: `{α β : Type} [BEq α] [Hashable α] (key : β → α) (xs : Array β) : HashMap α (Array β)`
  - Group array elements by key
  - **Relevance**: Batch cache organization

- **List.groupByKey**: List version of groupByKey

**Internal Functions**:

- **inner**: Access internal DHashMap
- **Internal.numBuckets**: Get bucket count (for monitoring)

---

### 2.7 "RBMap" - 199 Declarations

**Two Implementations**:

1. **Batteries.RBMap** (158 declarations) - Primary, feature-rich
2. **Lean.RBMap** (41 declarations) - Core, simpler

#### **Batteries.RBMap Type**
- **Type**: `(α : Type u) (β : Type v) (cmp : α → α → Ordering) : Type (max u v)`
- **Module**: `Batteries.Data.RBMap.Basic`
- **Library**: Batteries
- **Documentation**: An `RBMap` is a self-balancing binary search tree, used to store a key-value map. The `cmp` function is the comparator that will be used for performing searches; it should satisfy the requirements of `TransCmp` for it to have sensible behavior.
- **Relevance**: **ORDERED CACHE IMPLEMENTATION** - Use when order matters or range queries needed

**Construction** (5 functions):

1. **mkRBMap**: `(α : Type u) (β : Type v) (cmp : α → α → Ordering) : RBMap α β cmp`
   - Create empty map

2. **empty**: `RBMap α β cmp`
   - Empty map

3. **single**: `(k : α) (v : β) : RBMap α β cmp`
   - Single-element map

4. **ofArray**: `(l : Array (α × β)) (cmp : α → α → Ordering) : RBMap α β cmp`
   - **Complexity**: `O(n log n)`
   - Build from unsorted array

5. **ofList**: `(l : List (α × β)) (cmp : α → α → Ordering) : RBMap α β cmp`
   - **Complexity**: `O(n log n)`
   - Build from unsorted list

**Basic Operations** (3 functions):

1. **isEmpty**: `Bool` - **Complexity**: `O(1)`
2. **size**: `ℕ` - **Complexity**: `O(n)`
3. **contains**: `α → Bool` - **Complexity**: `O(log n)`

**Insertion & Modification** (4 functions):

1. **insert**: `α → β → RBMap α β cmp`
   - **Complexity**: `O(log n)`
   - **Relevance**: Ordered cache insertion

2. **erase**: `α → RBMap α β cmp`
   - **Complexity**: `O(log n)`
   - **Relevance**: Ordered cache eviction

3. **modify**: `α → (β → β) → RBMap α β cmp`
   - **Complexity**: `O(log n)`
   - In-place value modification

4. **alter**: `α → (Option β → Option β) → RBMap α β cmp`
   - **Complexity**: `O(log n)`
   - Insert/modify/delete

**Lookup Operations** (8 functions):

1. **find?**: `α → Option β`
   - **Complexity**: `O(log n)`
   - **Relevance**: Ordered cache lookup

2. **findD**: `α → β → β`
   - **Complexity**: `O(log n)`
   - Lookup with default

3. **find!**: `[Inhabited β] → α → β`
   - Lookup with panic

4. **findEntry?**: `α → Option (α × β)`
   - **Complexity**: `O(log n)`
   - Find key-value pair

5. **lowerBound?**: `α → Option (α × β)`
   - **Complexity**: `O(log n)`
   - **Relevance**: RANGE QUERY - largest key ≤ k

6. **min?**: `Option (α × β)`
   - **Complexity**: `O(log n)`
   - Minimum element

7. **max?**: `Option (α × β)`
   - **Complexity**: `O(log n)`
   - Maximum element

8. **min!**, **max!**: Panic versions

**Conversion Operations** (8 functions):

1. **toList**: `List (α × β)` - **Complexity**: `O(n)` - Ascending order
2. **keysArray**: `Array α` - **Complexity**: `O(n)`
3. **keysList**: `List α` - **Complexity**: `O(n)`
4. **valuesArray**: `Array β` - **Complexity**: `O(n)`
5. **valuesList**: `List β` - **Complexity**: `O(n)`
6. **keys**: `RBMap.Keys α β cmp` - **Complexity**: `O(1)` wrapper
7. **values**: `RBMap.Values α β cmp` - **Complexity**: `O(1)` wrapper

**Fold & Iteration** (4 functions):

1. **foldl**: `(σ → α → β → σ) → σ → RBMap α β cmp → σ`
   - **Complexity**: `O(n)` - Increasing order

2. **foldr**: `(α → β → σ → σ) → σ → RBMap α β cmp → σ`
   - **Complexity**: `O(n)` - Decreasing order

3. **foldlM**: Monadic fold
4. **forM**: Monadic iteration

**Filtering & Predicates** (3 functions):

1. **filter**: `(α → β → Bool) → RBMap α β cmp → RBMap α β cmp`
   - **Complexity**: `O(n * log n)`

2. **all**: `(α → β → Bool) → Bool`
   - **Complexity**: `O(n)`

3. **any**: `(α → β → Bool) → Bool`
   - **Complexity**: `O(n)`

**Set Operations** (4 functions):

1. **mergeWith**: `(α → β → β → β) → RBMap α β cmp → RBMap α β cmp → RBMap α β cmp`
   - **Complexity**: `O(n₂ * log (n₁ + n₂))`
   - **Relevance**: Ordered cache merging

2. **intersectWith**: `(α → β → γ → δ) → RBMap α β cmp → RBMap α γ cmp → RBMap α δ cmp`
   - **Complexity**: `O(n₁ * log (n₁ + n₂))`

3. **sdiff**: `RBMap α β cmp → RBMap α β cmp → RBMap α β cmp`
   - **Complexity**: `O(n₁ * (log n₁ + log n₂))`

4. **eqKeys**: `RBMap α β cmp → RBMap α γ cmp → Bool`
   - Check same key sets

**Comparison** (2 functions):

1. **all₂**: Compare two maps pairwise
2. **eqKeys**: Check key equality

**Mapping** (1 function):

1. **mapVal**: `(α → β → γ) → RBMap α β cmp → RBMap α γ cmp`
   - **Complexity**: `O(n)`
   - Transform values

---

## 3. Pattern Analysis

### 3.1 Common Caching Patterns Identified

#### **Pattern 1: HashMap-Based Cache**

**Structure**:
```lean
structure ProofCache where
  cache : Std.HashMap Formula Proof
  [BEq Formula]
  [Hashable Formula]
```

**Operations**:
- **Lookup**: `cache.get? formula`
- **Insert**: `cache.insert formula proof`
- **Check-and-insert**: `cache.containsThenInsertIfNew formula proof`
- **Get-or-compute**: `cache.getThenInsertIfNew? formula proof`

**Advantages**:
- Average `O(1)` lookup and insertion
- Well-documented and mature
- Built-in well-formedness invariants
- Efficient bulk operations

**Disadvantages**:
- No ordering guarantees
- Not persistent (copies are `O(n)`)
- Requires `BEq` and `Hashable` instances

**Use Cases**:
- General-purpose proof caching
- Tactic result memoization
- Expression normalization caching

---

#### **Pattern 2: StateM/StateT with Cache**

**Structure**:
```lean
abbrev ProofSearchM := StateT ProofCache MetaM

def lookupProof (f : Formula) : ProofSearchM (Option Proof) := do
  let cache ← get
  return cache.get? f

def cacheProof (f : Formula) (p : Proof) : ProofSearchM Unit := do
  modify fun cache => cache.insert f p
```

**Operations**:
- **Get cache**: `get`
- **Modify cache**: `modify fun cache => cache.insert k v`
- **Lookup**: `(← get).get? k`
- **Run with initial cache**: `computation.run initialCache`

**Advantages**:
- Composable with other monads (IO, Meta, Elab)
- Clean separation of cache state
- Supports monadic proof search
- Can combine multiple state types

**Disadvantages**:
- Requires monad transformer stack
- More complex type signatures
- Performance overhead from monad operations

**Use Cases**:
- Proof search with caching
- Tactic development with state
- Multi-phase compilation with cache

---

#### **Pattern 3: AIG-Style Verified Cache**

**Structure**:
```lean
structure VerifiedCache (α : Type) [BEq α] [Hashable α] where
  entries : Array α
  cache : Std.HashMap α Nat
  wf : CacheWF entries cache

structure CacheHit (entries : Array α) (entry : α) where
  idx : Nat
  hbound : idx < entries.size
  hvalid : entries[idx] = entry
```

**Operations**:
- **Lookup with proof**: `cache.get? entry : Option (CacheHit entries entry)`
- **Insert with invariant**: `cache.insert entry : VerifiedCache α`
- **Well-formedness**: `CacheWF entries cache`

**Advantages**:
- Proven correctness properties
- Cache hits include validity proofs
- Maintains invariants automatically
- Suitable for verified systems

**Disadvantages**:
- More complex implementation
- Requires proof obligations
- Higher development cost

**Use Cases**:
- Verified proof checkers
- Certified compilation
- Safety-critical caching

---

#### **Pattern 4: RBMap-Based Ordered Cache**

**Structure**:
```lean
structure OrderedCache where
  cache : Batteries.RBMap Formula Proof cmp
  cmp : Formula → Formula → Ordering
  [TransCmp cmp]
```

**Operations**:
- **Lookup**: `cache.find? formula` - `O(log n)`
- **Insert**: `cache.insert formula proof` - `O(log n)`
- **Range query**: `cache.lowerBound? formula` - `O(log n)`
- **Min/max**: `cache.min?`, `cache.max?` - `O(log n)`

**Advantages**:
- Ordered iteration
- Range queries
- Predictable performance
- No hash function needed

**Disadvantages**:
- `O(log n)` operations vs `O(1)` for HashMap
- Requires total ordering
- Larger memory footprint

**Use Cases**:
- Caching with order requirements
- Range-based cache queries
- Proof libraries with ordering

---

#### **Pattern 5: Persistent Cache**

**Structure**:
```lean
structure PersistentCache where
  cache : Lean.PersistentHashMap Formula Proof
  [BEq Formula]
  [Hashable Formula]
```

**Operations**:
- **Lookup**: `cache.find? formula`
- **Insert**: `cache.insert formula proof` - Returns new map
- **Lookup with default**: `cache.findD formula default`

**Advantages**:
- Immutable/persistent
- Efficient structural sharing
- Safe for concurrent access
- No linear usage requirement

**Disadvantages**:
- Slightly slower than mutable HashMap
- More complex internal structure
- Less documentation

**Use Cases**:
- Concurrent proof search
- Backtracking with cache
- Incremental compilation

---

### 3.2 State Management Patterns

#### **Pattern 1: Simple State Monad**

```lean
def computation : StateM CacheState Result := do
  let cache ← get
  match cache.get? key with
  | some value => return value
  | none =>
    let value ← expensiveComputation
    set (cache.insert key value)
    return value
```

**Use Cases**: Single-threaded, single-state computations

---

#### **Pattern 2: State Transformer Stack**

```lean
abbrev ProofSearchM := StateT ProofCache (StateT Statistics MetaM)

def search : ProofSearchM Proof := do
  -- Access proof cache
  let cache ← get
  -- Access statistics (requires lift)
  let stats ← StateT.lift get
  -- Access MetaM (requires double lift)
  let type ← StateT.lift (StateT.lift (Meta.inferType expr))
  ...
```

**Use Cases**: Multiple state types, composable effects

---

#### **Pattern 3: Reader + State**

```lean
structure SearchConfig where
  maxDepth : Nat
  timeout : Nat

abbrev SearchM := ReaderT SearchConfig (StateT ProofCache MetaM)

def search : SearchM Proof := do
  let config ← read
  let cache ← get
  ...
```

**Use Cases**: Immutable config + mutable state

---

### 3.3 Memoization Support

**Limited Direct Support**:

1. **memoFix**: Only general-purpose memoization function
   - Uses pointer hashing
   - For recursive functions
   - Automatic caching

2. **Simplifier memoization**: Built into simp tactic
   - Controlled by `Config.memoize`
   - Caches sub-expression simplifications
   - Not directly accessible

3. **Manual caching**: Primary approach
   - HashMap + StateM/StateT
   - Explicit cache management
   - Full control

**Recommendation**: Use manual caching with HashMap + StateM for proof search

---

## 4. Library Distribution

### 4.1 Lean Core

**State Monads**:
- `StateM`, `StateT` - Core state monad infrastructure
- `EStateM` - State with exceptions
- Lawful instances and theorems

**Basic Collections**:
- `List.lookup` - Association list lookup
- `Option.getD` - Option with default
- `Array.getD` - Array with default

**Lean-Specific**:
- `Lean.PersistentHashMap` - Persistent hash maps
- `Lean.KVMap` - Key-value maps
- `Lean.NameMap` - Name-keyed maps
- `Lean.Core.Cache` - Core monad cache
- `Lean.Meta.Cache` - Meta monad cache
- `Lean.HasConstCache` - Constant occurrence cache

---

### 4.2 Std Library

**Primary HashMap**:
- `Std.HashMap` - Main hash map implementation (1,192 declarations)
- `Std.HashSet` - Hash set (built on HashMap)
- `Std.DHashMap` - Dependent hash map

**Tree Maps**:
- `Std.TreeMap` - Tree-based map
- `Std.TreeSet` - Tree-based set

**AIG Cache**:
- `Std.Sat.AIG.Cache` - Verified cache for SAT solving
- `Std.Sat.AIG.CacheHit` - Cache hit with proof
- Cached gate operations

**BV Decision**:
- `Std.Tactic.BVDecide.BVExpr.Cache` - Bit-vector caching

**Iterators**:
- `Std.Iterators.Zip.memoizedLeft` - Memoized iteration

---

### 4.3 Batteries

**RBMap**:
- `Batteries.RBMap` - Red-black tree map (158 declarations)
- `Batteries.RBSet` - Red-black tree set
- Comprehensive API with complexity annotations

**HashMap**:
- `Batteries.HashMap` - Alternative HashMap (31 declarations)
- Wraps `Std.HashMap`

**Heaps**:
- `Batteries.BinaryHeap`
- `Batteries.BinomialHeap`
- `Batteries.PairingHeap`

---

### 4.4 Mathlib

**Memoization**:
- `memoFix` - General-purpose memoization

**Association Lists**:
- `List.dlookup` - Dependent lookup
- `List.lookupAll` - All values for key
- `AList` - Association list type
- `Finmap` - Finite map

**Tactic Caches**:
- `Mathlib.Tactic.Ring.Cache`
- `Mathlib.Tactic.ITauto` - Proof search with state

---

## 5. Recommendations

### 5.1 Best Functions for Proof Search Caching

#### **Tier 1: Primary Recommendations**

1. **Std.HashMap** - **RECOMMENDED PRIMARY CACHE**
   - **Why**: Mature, well-documented, efficient, proven in production
   - **Operations**: `get?`, `getD`, `insert`, `insertIfNew`, `containsThenInsertIfNew`
   - **Complexity**: Average `O(1)` for all operations
   - **Use for**: General-purpose proof caching, tactic results, expression normalization

2. **StateT + HashMap** - **RECOMMENDED FOR STATEFUL SEARCH**
   - **Why**: Clean composition with MetaM, explicit state management
   - **Pattern**: `StateT ProofCache MetaM`
   - **Use for**: Proof search algorithms, tactic development, multi-phase processing

3. **Lean.PersistentHashMap** - **RECOMMENDED FOR PERSISTENT CACHING**
   - **Why**: Immutable, structural sharing, safe for backtracking
   - **Operations**: `find?`, `findD`, `insert`
   - **Use for**: Backtracking search, concurrent access, incremental compilation

#### **Tier 2: Specialized Use Cases**

4. **Batteries.RBMap** - **FOR ORDERED CACHING**
   - **Why**: Ordered iteration, range queries, no hash function needed
   - **Operations**: `find?`, `insert`, `lowerBound?`, `min?`, `max?`
   - **Complexity**: `O(log n)` for all operations
   - **Use for**: Proof libraries with ordering, range-based queries

5. **Std.Sat.AIG.Cache** - **FOR VERIFIED CACHING**
   - **Why**: Proven correctness, cache hits include proofs
   - **Operations**: `get?`, `insert` with invariant maintenance
   - **Use for**: Verified proof checkers, certified systems

6. **memoFix** - **FOR RECURSIVE MEMOIZATION**
   - **Why**: Automatic memoization of recursive functions
   - **Use for**: Tree traversals with shared subtrees, recursive proof search

#### **Tier 3: Utility Functions**

7. **List.lookup** - **FOR SIMPLE ASSOCIATION LISTS**
   - **Why**: Simple, no dependencies, good for small caches
   - **Complexity**: `O(n)`
   - **Use for**: Small proof caches, configuration lookup

8. **Array.groupByKey** - **FOR BATCH ORGANIZATION**
   - **Why**: Efficient grouping by key
   - **Use for**: Organizing proof batches, grouping tactics

---

### 5.2 Implementation Strategy for Proof Search

#### **Phase 1: Basic Caching**

```lean
-- Define cache type
structure ProofCache where
  formulas : Std.HashMap Formula Proof
  deriving Inhabited

-- Define search monad
abbrev ProofSearchM := StateT ProofCache MetaM

-- Lookup with caching
def searchWithCache (f : Formula) : ProofSearchM Proof := do
  let cache ← get
  match cache.formulas.get? f with
  | some proof => 
    -- Cache hit
    return proof
  | none =>
    -- Cache miss - compute
    let proof ← computeProof f
    -- Update cache
    modify fun c => { c with formulas := c.formulas.insert f proof }
    return proof
```

#### **Phase 2: Statistics Tracking**

```lean
structure SearchStats where
  cacheHits : Nat := 0
  cacheMisses : Nat := 0
  totalSearches : Nat := 0

structure ProofCache where
  formulas : Std.HashMap Formula Proof
  stats : SearchStats
  deriving Inhabited

def searchWithStats (f : Formula) : ProofSearchM Proof := do
  let cache ← get
  modify fun c => { c with stats.totalSearches := c.stats.totalSearches + 1 }
  match cache.formulas.get? f with
  | some proof =>
    modify fun c => { c with stats.cacheHits := c.stats.cacheHits + 1 }
    return proof
  | none =>
    modify fun c => { c with stats.cacheMisses := c.stats.cacheMisses + 1 }
    let proof ← computeProof f
    modify fun c => { c with formulas := c.formulas.insert f proof }
    return proof
```

#### **Phase 3: Multi-Level Caching**

```lean
structure ProofCache where
  -- Fast cache for recent proofs
  recent : Std.HashMap Formula Proof
  -- Persistent cache for all proofs
  persistent : Lean.PersistentHashMap Formula Proof
  -- Statistics
  stats : SearchStats
  deriving Inhabited

def searchMultiLevel (f : Formula) : ProofSearchM Proof := do
  let cache ← get
  -- Check recent cache first
  match cache.recent.get? f with
  | some proof => return proof
  | none =>
    -- Check persistent cache
    match cache.persistent.find? f with
    | some proof =>
      -- Promote to recent cache
      modify fun c => { c with recent := c.recent.insert f proof }
      return proof
    | none =>
      -- Compute and cache in both
      let proof ← computeProof f
      modify fun c => { c with 
        recent := c.recent.insert f proof,
        persistent := c.persistent.insert f proof
      }
      return proof
```

---

### 5.3 Performance Considerations

#### **HashMap Performance**:
- **Average case**: `O(1)` for lookup, insert, erase
- **Worst case**: `O(n)` if hash function is poor
- **Load factor**: Resizes at 75% capacity
- **Memory**: Overhead from buckets array + linked lists

#### **RBMap Performance**:
- **All operations**: `O(log n)`
- **Predictable**: No hash function variance
- **Memory**: Tree node overhead
- **Ordering**: Maintains sorted order

#### **StateM/StateT Performance**:
- **Overhead**: Minimal for StateM, moderate for StateT
- **Composition**: Cost increases with transformer stack depth
- **Optimization**: Use `@[inline]` for hot paths

#### **Caching Strategy**:
- **Pre-size HashMap**: Use `emptyWithCapacity` to avoid resizing
- **Eviction policy**: Implement LRU if memory is constrained
- **Batch operations**: Use `insertMany` for bulk updates
- **Statistics**: Track hit rate to tune cache size

---

## 6. Caching Patterns Summary

### 6.1 Identified Patterns

1. **HashMap-based caching**: Most common, efficient, well-supported
2. **StateM/StateT state management**: Standard for stateful computations
3. **Verified caching (AIG)**: Proven correctness for critical systems
4. **Ordered caching (RBMap)**: When ordering or range queries needed
5. **Persistent caching**: For immutable/concurrent scenarios
6. **Memoization (memoFix)**: Automatic for recursive functions
7. **Simplifier memoization**: Built-in for simp tactic
8. **Association lists**: Simple, for small caches
9. **Multi-level caching**: Recent + persistent for performance
10. **Cache-with-fallback**: `getD` pattern for default values

### 6.2 Pattern Selection Guide

| Use Case | Recommended Pattern | Rationale |
|----------|-------------------|-----------|
| General proof caching | HashMap + StateT | Efficient, composable, well-documented |
| Ordered proof library | RBMap | Maintains order, supports range queries |
| Verified proof checker | AIG-style cache | Proven correctness properties |
| Backtracking search | PersistentHashMap | Immutable, structural sharing |
| Recursive memoization | memoFix | Automatic, pointer-based |
| Small configuration | List.lookup | Simple, no dependencies |
| Tactic development | StateT stack | Composable with MetaM/ElabM |
| Concurrent access | PersistentHashMap | Thread-safe immutability |
| Memory-constrained | HashMap + LRU | Efficient with eviction |
| Multi-phase compilation | StateT + persistent | Incremental with caching |

---

## 7. Conclusion

LEAN 4 provides **extensive infrastructure for caching and state management**, though explicit memoization support is limited. The ecosystem offers:

**Strengths**:
- Mature HashMap implementation with comprehensive API
- Flexible state monad infrastructure (StateM/StateT)
- Specialized caching systems (AIG, simplifier, tactics)
- Both mutable and persistent data structures
- Proven correctness patterns (AIG cache)

**Gaps**:
- Limited general-purpose memoization (only `memoFix`)
- No built-in LRU or eviction policies
- Minimal documentation on caching best practices
- No standard cache statistics/monitoring

**Recommended Approach**:
1. **Start with**: `Std.HashMap` + `StateT` for proof search caching
2. **Add**: Statistics tracking for cache performance monitoring
3. **Consider**: `Lean.PersistentHashMap` for backtracking scenarios
4. **Study**: AIG cache system for verified caching patterns
5. **Optimize**: Pre-size caches, implement eviction if needed

The combination of `Std.HashMap` for storage and `StateT` for state management provides a solid foundation for implementing efficient, maintainable proof search caching in LEAN 4.

---

## Appendix: Complete Query Results

### Query 1: `HashMap _ _ → _ → Option _`
- **Matches**: 3
- **Key functions**: `HashMap.get?`, `HashMap.getKey?`, `HashMap.findEntry?`

### Query 2: `_ → _ → (_ → _) → _` (cache-with-fallback)
- **Matches**: 8+ (getD variants)
- **Key functions**: `HashMap.getD`, `Option.getD`, `List.getD`, `Array.getD`

### Query 3: `StateM _ _`
- **Matches**: 39
- **Key use cases**: Name sanitization, constant caching, proof search, graph algorithms

### Query 4: `StateT _ _ _`
- **Matches**: 102
- **Key use cases**: Documentation parsing, RPC encoding, weakest precondition verification

### Query 5: "cache"
- **Matches**: 569
- **Key systems**: AIG cache, Lean core caches, tactic caches, BV decision caches

### Query 6: "memo"
- **Matches**: 119
- **Key functions**: `memoFix`, simplifier memoization, memory management

### Query 7: "memoize"
- **Matches**: 6
- **Key functions**: Simplifier config, iterator memoization

### Query 8: "lookup"
- **Matches**: 137
- **Key functions**: `List.lookup`, server lookup, metaprogramming lookup

### Query 9: "insert"
- **Matches**: 5,606
- **Key functions**: HashMap insert, RBMap insert, array insert, specialized inserts

### Query 10: "HashMap"
- **Matches**: 6,786
- **Key implementation**: `Std.HashMap` with comprehensive API

### Query 11: "RBMap"
- **Matches**: 199
- **Key implementations**: `Batteries.RBMap` (158), `Lean.RBMap` (41)

---

**End of Report**
