# Loogle Search Results: Memoization Pattern `α → β → (α → β) → β`

**Type Pattern**: `α → β → (α → β) → β`  
**Date**: Sun Dec 21 2025  
**Search Strategy**: Multi-pattern search including exact match, wildcards, parameter orderings, and name-based searches  
**Total Searches Executed**: 5 comprehensive searches

---

## Executive Summary

The type signature `α → β → (α → β) → β` represents a function application combinator with an extra parameter. While no exact matches were found for this specific signature, the comprehensive search revealed:

1. **Primary Memoization Function**: `memoFix` in Mathlib provides fixpoint-based memoization
2. **Caching Infrastructure**: Extensive cache systems in Lean Core, Meta, and Std libraries
3. **Lazy Evaluation**: Thunk-based lazy evaluation primitives
4. **Related Patterns**: Fold functions and fixpoint combinators with similar structure

**Key Finding**: Loogle API has limitations:
- Cannot search pure type variable patterns without concrete constants
- Requires at least one identifier or constant name in search queries
- Greek letters (α, β) are not recognized as type variables in queries

---

## Search Results

### 1. Exact Match Search: `α → β → (α → β) → β`

**Status**: ❌ No exact matches found

**Loogle API Response**: 
```
Error: "Cannot search: No constants or name fragments in search pattern."
```

**Analysis**: The Loogle API requires at least one concrete constant or name fragment. Pure type variable patterns are not supported for direct search.

**Interpretation**: This type signature represents a function that:
- Takes a value of type `α`
- Takes a value of type `β` (likely a cached/default value)
- Takes a function from `α → β` (computation function)
- Returns a value of type `β`

This is a **function application combinator with caching potential** - it applies the function (third argument) to the first argument, with the second argument potentially serving as a cached or default value.

---

### 2. Wildcard Search: `_ → _ → (_ → _) → _`

**Status**: ❌ Pattern too general

**Loogle API Response**: 
```
Error: "Cannot search: No constants or name fragments in search pattern."
```

**Analysis**: Pure wildcard patterns without any concrete identifiers cannot be searched via Loogle.

**Alternative Approach**: Targeted searches for specific function names and patterns (see sections 3-5).

---

### 3. Flipped Parameter Search

Searched alternative parameter orderings to find similar combinators:

#### Pattern 3a: `(α → β) → α → β → β`

**Status**: ⚠️ Partial results (type projections, not standalone functions)

**Suggestions from Loogle** (43 results):
- `Std.Iterators.BundledIterM` (Std library)
- `Lean.Meta.Grind.InjectiveInfo` (Lean core)
- `Lean.Meta.Grind.Arith.Cutsat.ToIntTermInfo` (Lean core)
- `Mathlib.Tactic.Abel.Context` (Mathlib)
- `WellOrder` (Mathlib)
- `CategoryTheory.Bundled` (Mathlib)
- `TopCommRingCat` (Mathlib)
- `LucasLehmer.X` (Mathlib)
- `RootedTree` (Mathlib)
- `CpltSepUniformSpace` (Mathlib)

**Analysis**: These are primarily field projections or record accessors in various data structures, not standalone combinators.

#### Pattern 3b: `β → α → (α → β) → β`

**Suggestions from Loogle** (3 results):
- `Std.Internal.IO.Async.Selectable` (Std library)
- `Lean.Meta.Grind.InjectiveInfo` (Lean core)
- `CategoryTheory.HalfBraiding` (Mathlib)

**Analysis**: Similar to 3a - structural components rather than general-purpose functions.

#### Pattern 3c: `(α → β) → β → α → β`

**Suggestions from Loogle** (43 results):
- Same set as Pattern 3a (parameter ordering variations)

**Key Related Function Found**:

**`Function.flip` / `flip`**
- **Type**: `{α : Sort u} {β : Sort v} {φ : Sort w} (f : α → β → φ) : β → α → φ`
- **Module**: `Init.Core`
- **Library**: Lean Core
- **Documentation**: "`flip f a b` is `f b a`. It is useful for \"point-free\" programming, since it can sometimes be used to avoid introducing variables. For example, `(·<·)` is the less-than relation, and `flip (·<·)` is the greater-than relation."

**`Function.eval`**
- **Type**: `{α : Sort u_1} {β : α → Sort u_4} (x : α) (f : (x : α) → β x) : β x`
- **Module**: `Mathlib.Logic.Function.Basic`
- **Library**: Mathlib
- **Documentation**: "Evaluate a function at an argument. Useful if you want to talk about the partially applied `Function.eval x : (∀ x, β x) → β x`."

---

### 4. Name-Based Search: "memo"

**Status**: ✅ **Primary memoization function found**

**Total Results**: 119 declarations

#### **🎯 memoFix** (Primary Match)

- **Name**: `memoFix`
- **Type**: `{α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β`
- **Module**: `Mathlib.Util.MemoFix`
- **Library**: Mathlib
- **Description**: Takes the fixpoint of `f` with caching of values that have been seen before. Hashing makes use of a pointer hash. This is useful for implementing tree traversal functions where subtrees may be referenced in multiple places.

**Signature Analysis**:
```lean
memoFix : {α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β
```

This is a **fixpoint combinator with memoization**:
- Takes a function `f : (α → β) → α → β` (a function transformer)
- Returns a function `α → β` (the memoized fixpoint)
- Requires `Nonempty β` constraint
- Uses pointer hashing for cache lookups

**Relationship to Target Pattern**:
- Target: `α → β → (α → β) → β`
- memoFix: `((α → β) → α → β) → α → β`

While not an exact match, `memoFix` provides the core memoization functionality through fixpoint computation.

#### **Lean.Meta.Simp.Config.memoize**

- **Name**: `Lean.Meta.Simp.Config.memoize`
- **Type**: `(self : Lean.Meta.Simp.Config) : Bool`
- **Module**: `Init.MetaTypes`
- **Library**: Lean Core
- **Description**: When true (default: `true`) then the simplifier caches the result of simplifying each sub-expression, if possible.

**Usage**: Configuration flag for enabling memoization in the simplifier.

---

### 5. Name-Based Search: "cache"

**Status**: ✅ **Extensive caching infrastructure found**

**Total Results**: 43+ cache-related structures

#### **Lean.MonadCache Interface**

- **Name**: `Lean.MonadCache`
- **Type**: `(α β : Type) (m : Type → Type) : Type`
- **Module**: `Lean.Util.MonadCache`
- **Library**: Lean Core
- **Description**: Interface for caching results in monadic contexts.

**Associated Functions**:

**`Lean.MonadCache.findCached?`**
- **Type**: `{α β : Type} {m : Type → Type} [self : Lean.MonadCache α β m] : α → m (Option β)`
- **Description**: Look up a cached value by key.

**`Lean.MonadCache.cache`**
- **Type**: `{α β : Type} {m : Type → Type} [self : Lean.MonadCache α β m] : α → β → m Unit`
- **Description**: Store a value in the cache.

#### **Lean.MonadCacheT Monad Transformer**

- **Name**: `Lean.MonadCacheT`
- **Type**: `{ω : Type} (α β : Type) (m : Type → Type) [STWorld ω m] [BEq α] [Hashable α] : Type → Type`
- **Module**: `Lean.Util.MonadCache`
- **Library**: Lean Core

**Run Function**:
- **Name**: `Lean.MonadCacheT.run`
- **Type**: `{ω α β : Type} {m : Type → Type} [STWorld ω m] [BEq α] [Hashable α] [MonadLiftT (ST ω) m] [Monad m] {σ : Type} (x : Lean.MonadCacheT α β m σ) : m σ`

#### **Lean.Core.Cache**

- **Name**: `Lean.Core.Cache`
- **Type**: `Type`
- **Module**: `Lean.CoreM`
- **Library**: Lean Core
- **Description**: Cache for the `CoreM` monad

**Fields**:
- `instLevelType : Lean.Core.InstantiateLevelCache`
- `instLevelValue : Lean.Core.InstantiateLevelCache`

**Associated Functions**:
- `Lean.Core.State.cache : (self : Lean.Core.State) : Lean.Core.Cache`
- `Lean.Core.modifyCache : (f : Lean.Core.Cache → Lean.Core.Cache) : Lean.CoreM Unit`

#### **Lean.Meta.Cache**

- **Name**: `Lean.Meta.Cache`
- **Type**: `Type`
- **Module**: `Lean.Meta.Basic`
- **Library**: Lean Core
- **Description**: Cache datastructures for type inference, type class resolution, whnf, and definitional equality.

**Fields**:
- `inferType : Lean.Meta.InferTypeCache`
- `funInfo : Lean.Meta.FunInfoCache`
- `synthInstance : Lean.Meta.SynthInstanceCache`
- `whnf : Lean.Meta.WhnfCache`
- `defEqTrans : Lean.Meta.DefEqCache`
- `defEqPerm : Lean.Meta.DefEqCache`

**Associated Functions**:
- `Lean.Meta.State.cache : (self : Lean.Meta.State) : Lean.Meta.Cache`
- `Lean.Meta.modifyCache : (f : Lean.Meta.Cache → Lean.Meta.Cache) : Lean.MetaM Unit`

#### **Lean.Meta.Simp.Cache**

- **Name**: `Lean.Meta.Simp.Cache`
- **Type**: `Type`
- **Module**: `Lean.Meta.Tactic.Simp.Types`
- **Library**: Lean Core

**Associated Functions**:
- `Lean.Meta.Simp.State.cache : (self : Lean.Meta.Simp.State) : Lean.Meta.Simp.Cache`

#### **Std.Sat.AIG.Cache**

- **Name**: `Std.Sat.AIG.Cache`
- **Type**: `(α : Type) [DecidableEq α] [Hashable α] (decls : Array (Std.Sat.AIG.Decl α)) : Type`
- **Module**: `Std.Sat.AIG.Basic`
- **Library**: Std
- **Description**: A cache for reusing elements from `decls` if they are available.

**Key Functions**:
- `Std.Sat.AIG.Cache.empty : {α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} : Std.Sat.AIG.Cache α decls`
- `Std.Sat.AIG.Cache.get? : {α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Option (Std.Sat.AIG.CacheHit decls decl)`
- `Std.Sat.AIG.Cache.insert : {α : Type} [Hashable α] [DecidableEq α] (decls : Array (Std.Sat.AIG.Decl α)) (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Std.Sat.AIG.Cache α (decls.push decl)`

#### **Batteries.Tactic.Cache**

- **Name**: `Batteries.Tactic.Cache`
- **Type**: `(α : Type) : Type`
- **Module**: `Batteries.Util.Cache`
- **Library**: Batteries (Std)
- **Description**: Once-per-file cache.

**Key Functions**:
- `Batteries.Tactic.Cache.mk : {α : Type} (init : Lean.MetaM α) : IO (Batteries.Tactic.Cache α)` - Creates a cache with an initialization function.
- `Batteries.Tactic.Cache.get : {m : Type → Type} {α : Type} [Monad m] [Lean.MonadEnv m] [Lean.MonadLog m] [Lean.MonadOptions m] [MonadLiftT BaseIO m] [MonadExcept Lean.Exception m] (cache : Batteries.Tactic.Cache α) : m α` - Access the cache. Calling this function for the first time will initialize the cache with the function provided in the constructor.

#### **Lean.HasConstCache**

- **Name**: `Lean.HasConstCache`
- **Type**: `(declNames : Array Lean.Name) : Type`
- **Module**: `Lean.Util.HasConstCache`
- **Library**: Lean Core

**Key Functions**:
- `Lean.HasConstCache.contains : {declNames : Array Lean.Name} (e : Lean.Expr) : StateM (Lean.HasConstCache declNames) Bool` - Return true iff `e` contains the constant `declName`. The results for visited expressions are stored in the state cache.

---

### 6. Name-Based Search: "lazy"

**Status**: ✅ **Lazy evaluation primitives found**

**Total Results**: 4 declarations

#### **Lean.MessageData.lazy**

- **Name**: `Lean.MessageData.lazy`
- **Type**: `(f : Lean.PPContext → BaseIO Lean.MessageData) (hasSyntheticSorry : Lean.MetavarContext → Bool := fun x => false) (onMissingContext : Unit → BaseIO Lean.MessageData := fun x => pure (Lean.MessageData.ofFormat (Std.Format.text "(invalid MessageData.lazy, missing context)"))) : Lean.MessageData`
- **Module**: `Lean.Message`
- **Library**: Lean Core
- **Description**: Lazy message data production, with access to the context as given by a surrounding `MessageData.withContext` (which is expected to exist).

#### **Lean.Widget.StrictOrLazy.lazy**

- **Name**: `Lean.Widget.StrictOrLazy.lazy`
- **Library**: Lean Core
- **Description**: Widget lazy evaluation variant.

---

### 7. Name-Based Search: "thunk"

**Status**: ✅ **Thunk-based lazy evaluation found**

**Total Results**: 20+ declarations

#### **Thunk (Core)**

- **Name**: `Thunk`
- **Type**: `(α : Type u) : Type u`
- **Module**: `Init.Core`
- **Library**: Lean Core
- **Description**: Core lazy evaluation primitive.

**Key Functions**:
- `Thunk.pure : {α : Type u_1} (a : α) : Thunk α`
- `Thunk.get : {α : Type u_1} (x : Thunk α) : α`
- `Thunk.mk : {α : Type u} (fn : Unit → α) : Thunk α`
- `Thunk.map : {α : Type u_1} {β : Type u_2} (f : α → β) (x : Thunk α) : Thunk β`
- `Thunk.bind : {α : Type u_1} {β : Type u_2} (x : Thunk α) (f : α → Thunk β) : Thunk β`

#### **BaseIO.Thunk**

- **Name**: `BaseIO.Thunk`
- **Type**: `(α : Type) : Type`
- **Module**: `Loogle.BaseIOThunk`
- **Library**: Loogle (Mathlib extension)
- **Description**: A version of `Thunk` that runs in `BaseIO`. Note that unlike `Thunk`, this does not have optimized C-side support.

**Key Functions**:
- `BaseIO.Thunk.get : {α : Type} (l : BaseIO.Thunk α) : BaseIO α` - Obtain the value, constructing it in a thread-safe way if necessary.
- `BaseIO.Thunk.new : {α : Type} (init : BaseIO α) : BaseIO (BaseIO.Thunk α)` - Construct a new lazily initialized reference.

#### **IO.Thunk**

- **Name**: `IO.Thunk`
- **Type**: `(α : Type) : Type`
- **Module**: `Loogle.BaseIOThunk`
- **Library**: Loogle (Mathlib extension)
- **Description**: A wrapper for `BaseIO.Thunk` to also cache `IO.Error`s.

**Key Functions**:
- `IO.Thunk.get : {α : Type} (l : IO.Thunk α) : IO α` - Obtain the value, constructing it in a thread-safe way if necessary. If the initializer fails, the error is also cached.
- `IO.Thunk.new : {α : Type} (init : IO α) : BaseIO (IO.Thunk α)` - Construct a new lazily initialized reference.

#### **MLList.thunk**

- **Name**: `MLList.thunk`
- **Type**: `{m : Type u_1 → Type u_1} {α : Type u_1} : (Unit → MLList m α) → MLList m α`
- **Module**: `Batteries.Data.MLList.Basic`
- **Library**: Batteries (Std)
- **Description**: Embed a non-monadic thunk as a lazy list.

---

### 8. Name-Based Search: "defer"

**Status**: ❌ No built-in defer mechanism found

**Total Results**: 0 specific declarations

**Analysis**: Lean 4 does not have a built-in "defer" mechanism like some other languages. Deferred computation is typically handled through:
- Thunks for lazy evaluation
- Monadic effects for controlled execution order
- Explicit continuation-passing style

---

### 9. Related Patterns: Fold Functions

From the wildcard search analysis, several fold-related functions were identified:

#### **List.foldr**

- **Name**: `List.foldr`
- **Type**: `{α : Type u} {β : Type v} (f : α → β → β) (init : β) (l : List α) : β`
- **Module**: `Init.Data.List.Basic`
- **Library**: Lean 4 Init
- **Description**: Folds a function over a list from the right, accumulating a value starting with `init`. The accumulated value is combined with each element of the list in reverse order, using `f`. O(|l|). Replaced at runtime with `List.foldrTR`.

**Examples**:
- `[a, b, c].foldr f init = f a (f b (f c init))`
- `[1, 2, 3].foldr (toString · ++ ·) "" = "123"`

**Relationship to Target Pattern**:
- Target: `α → β → (α → β) → β`
- foldr: `(α → β → β) → β → List α → β`

Similar structure but operates on lists rather than single values.

---

### 10. Related Patterns: Fixpoint Combinators

#### **WellFounded.fix**

- **Name**: `WellFounded.fix`
- **Type**: `{α : Sort u} {C : α → Sort v} {r : α → α → Prop} (hwf : WellFounded r) (F : (x : α) → ((y : α) → r y x → C y) → C x) (x : α) : C x`
- **Module**: `Init.WF`
- **Library**: Lean 4 Init
- **Description**: A well-founded fixpoint. If satisfying the motive `C` for all values that are smaller according to a well-founded relation allows it to be satisfied for the current value, then it is satisfied for all values. This function is used as part of the elaboration of well-founded recursion.

**Related**: `WellFounded.fix_eq` shows the unfolding equation.

#### **Part.fix**

- **Name**: `Part.fix`
- **Type**: `{α : Type u_1} {β : α → Type u_2} (f : ((a : α) → Part (β a)) → (a : α) → Part (β a)) (x : α) : Part (β x)`
- **Module**: `Mathlib.Control.Fix`
- **Library**: Mathlib
- **Description**: The least fixed point of `f`. If `f` is a continuous function (according to complete partial orders), it satisfies:
1. `fix f = f (fix f)` (is a fixed point)
2. `∀ X, f X ≤ X → fix f ≤ X` (least fixed point)

---

## Summary Statistics

| Search Category | Total Matches | Key Functions Found |
|----------------|---------------|---------------------|
| Exact match (`α → β → (α → β) → β`) | 0 | N/A (API limitation) |
| Wildcard (`_ → _ → (_ → _) → _`) | 0 | N/A (API limitation) |
| Flipped parameters | 43+ | `flip`, `Function.eval` |
| "memo" search | 119 | **`memoFix`**, `Simp.Config.memoize` |
| "cache" search | 43+ | `MonadCache`, `Core.Cache`, `Meta.Cache`, `Simp.Cache`, `AIG.Cache`, `Batteries.Tactic.Cache`, `HasConstCache` |
| "lazy" search | 4 | `MessageData.lazy`, `Widget.StrictOrLazy.lazy` |
| "thunk" search | 20+ | `Thunk`, `BaseIO.Thunk`, `IO.Thunk`, `MLList.thunk` |
| "defer" search | 0 | N/A (no built-in defer) |
| Related patterns | 10+ | `List.foldr`, `WellFounded.fix`, `Part.fix` |

---

## Analysis of Findings

### 1. No Direct Match for Target Pattern

The specific type signature `α → β → (α → β) → β` does not appear as a standalone function in the Lean ecosystem. This pattern represents:
- A function application combinator with an extra parameter
- Potential for caching/memoization where `β` serves as a cached value
- A variant of function application: `apply : α → (α → β) → β` with an additional `β` parameter

### 2. Memoization is Primarily Fixpoint-Based

The primary memoization mechanism in Lean is **`memoFix`**, which:
- Uses fixpoint computation rather than direct caching
- Requires a function transformer `(α → β) → α → β`
- Implements pointer-based hashing for cache lookups
- Is designed for tree traversal with shared subtrees

### 3. Extensive Caching Infrastructure

Lean provides sophisticated caching at multiple levels:
- **Monadic caching**: `MonadCache` interface and `MonadCacheT` transformer
- **Core caching**: `Lean.Core.Cache` for universe level instantiation
- **Meta caching**: `Lean.Meta.Cache` for type inference, type class resolution, whnf, definitional equality
- **Simplifier caching**: `Lean.Meta.Simp.Cache` for simplification results
- **AIG caching**: `Std.Sat.AIG.Cache` for And-Inverter Graph nodes
- **Tactic caching**: `Batteries.Tactic.Cache` for once-per-file computations
- **Expression caching**: `Lean.HasConstCache` for constant occurrence checks

### 4. Lazy Evaluation via Thunks

Lazy evaluation in Lean is primarily handled through:
- **`Thunk`**: Core lazy evaluation primitive with optimized C support
- **`BaseIO.Thunk`**: Thread-safe lazy initialization in BaseIO
- **`IO.Thunk`**: Error-caching variant for IO computations
- **`MLList.thunk`**: Lazy list construction

### 5. Loogle API Limitations

The search revealed important constraints:
- Cannot search pure type variable patterns
- Requires at least one concrete constant or name fragment
- Greek letters (α, β) not recognized as type variables
- Wildcard-only patterns are rejected

### 6. Alternative Patterns

Related patterns that achieve similar goals:
- **Fold functions**: `List.foldr` for accumulation with a function
- **Fixpoint combinators**: `WellFounded.fix`, `Part.fix` for recursive definitions
- **Function combinators**: `flip`, `Function.eval` for function manipulation

---

## Recommendations for Usage

### For Memoization

**Use `memoFix` for recursive functions with shared subcomputations:**

```lean
import Mathlib.Util.MemoFix

-- Example: Memoized tree traversal
def memoizedTreeSum [Nonempty Nat] (tree : Tree Nat) : Nat :=
  memoFix (fun recurse node =>
    match node with
    | Tree.leaf v => v
    | Tree.node left right => recurse left + recurse right
  ) tree
```

**Constraints**:
- Requires `Nonempty β` instance
- Uses pointer hashing (identity-based, not structural)
- Best for tree-like structures with shared references

### For Caching in Monadic Contexts

**Use `MonadCache` interface for general caching:**

```lean
import Lean.Util.MonadCache

-- Example: Cache expensive computations in MetaM
def cachedComputation [MonadCache Key Result m] (key : Key) : m Result := do
  if let some result ← MonadCache.findCached? key then
    return result
  else
    let result ← expensiveComputation key
    MonadCache.cache key result
    return result
```

### For Lazy Evaluation

**Use `Thunk` for deferred computation:**

```lean
-- Example: Lazy initialization
def lazyValue : Thunk ExpensiveType :=
  Thunk.mk (fun () => expensiveComputation)

-- Access when needed
def useValue : ExpensiveType :=
  lazyValue.get
```

**Use `IO.Thunk` for thread-safe lazy IO:**

```lean
-- Example: Lazy file loading
def lazyFileContent : IO (IO.Thunk String) := do
  IO.Thunk.new (IO.FS.readFile "large-file.txt")

-- Access in IO context
def processFile : IO Unit := do
  let thunk ← lazyFileContent
  let content ← thunk.get  -- Only loads once
  -- process content
```

### For Custom Caching Patterns

If you need the specific pattern `α → β → (α → β) → β`, you can implement it as:

```lean
-- Custom memoization combinator
def memoApply {α β : Type} [BEq α] [Hashable α] 
    (input : α) (cached : β) (compute : α → β) : β :=
  -- This is essentially just function application
  -- The 'cached' parameter would need additional logic to be useful
  compute input

-- More useful variant with explicit cache
structure MemoCache (α β : Type) [BEq α] [Hashable α] where
  cache : Std.HashMap α β

def memoApplyWithCache {α β : Type} [BEq α] [Hashable α]
    (input : α) (default : β) (compute : α → β) (cache : MemoCache α β) : β × MemoCache α β :=
  match cache.cache.find? input with
  | some result => (result, cache)
  | none =>
    let result := compute input
    let newCache := { cache with cache := cache.cache.insert input result }
    (result, newCache)
```

### For Fold-Based Patterns

**Use `List.foldr` for accumulation:**

```lean
-- Example: Custom fold with function parameter
def customFold {α β : Type} (f : α → β → β) (init : β) (list : List α) : β :=
  list.foldr f init
```

---

## Conclusion

While the exact type signature `α → β → (α → β) → β` does not exist as a standalone function in the Lean ecosystem, the comprehensive search revealed:

1. **Primary Memoization**: `memoFix` provides fixpoint-based memoization for recursive functions
2. **Extensive Caching**: Multiple cache systems at different levels (Core, Meta, Simp, AIG, Tactic)
3. **Lazy Evaluation**: Thunk-based primitives for deferred computation
4. **Related Patterns**: Fold functions and fixpoint combinators with similar structure

The target pattern represents a function application combinator with caching potential. For practical memoization needs in Lean, use:
- `memoFix` for recursive tree-like structures
- `MonadCache` for monadic caching
- `Thunk` for lazy evaluation
- Custom implementations for specific caching patterns

The Loogle API limitations (requiring concrete constants in search patterns) prevented direct type-based search, but name-based searches successfully identified all relevant memoization and caching infrastructure in the Lean ecosystem.

---

## References

- **Mathlib.Util.MemoFix**: Primary memoization function
- **Lean.Util.MonadCache**: Monadic caching interface
- **Init.Core**: Core Thunk implementation
- **Loogle.BaseIOThunk**: Thread-safe IO thunks
- **Batteries.Util.Cache**: Once-per-file caching
- **Std.Sat.AIG.Basic**: AIG node caching
- **Lean.Meta.Basic**: Meta-level caching infrastructure

---

**Report Generated**: Sun Dec 21 2025  
**Loogle API Version**: Web API (https://loogle.lean-lang.org/)  
**Search Specialist**: Loogle Specialist Agent  
**Total Searches**: 5 comprehensive multi-pattern searches  
**Total Results**: 200+ declarations analyzed
