# Loogle Search Results: Caching and Memoization

**Search Topic**: Caching and memoization patterns in LEAN 4  
**Date**: Sat Dec 20 2025  
**Total Matches**: 7,258+ declarations (across all queries)  
**Specialist**: Loogle Specialist  

---

## Executive Summary

This comprehensive search identified extensive caching and memoization infrastructure in LEAN 4, spanning:
- **569+ cache-related declarations** (showing first 200)
- **6 memoization functions**
- **2,628+ State monad declarations** (showing first 200)
- **159 StateT transformer declarations**
- **186 IO.Ref declarations** for mutable references
- **3,650+ caching wrapper patterns** (`α → m α`)
- **66+ StateT patterns** (`_ → StateT _ _ _`)

The ecosystem provides multiple approaches to caching:
1. **Pure functional caching** via State monads
2. **Mutable reference caching** via IO.Ref
3. **Specialized domain caches** (AIG, BVExpr, Parser, Simp)
4. **Monadic caching infrastructure** (MonadCache, MonadCacheT)

---

## 1. Cache-Related Functions

### 1.1 Name Search: "cache"

**Total Matches**: 569 declarations (showing first 200)

#### Core Cache Infrastructure

##### Lean.MonadCache (Core Caching Monad)

**Type Class Definition:**
- **`Lean.MonadCache`** - `Lean.Util.MonadCache`
  - Type: `(α β : Type) (m : Type → Type) : Type`
  - Purpose: Generic monad type class for caching operations

**Core Operations:**
- **`Lean.MonadCache.cache`**
  - Type: `{α β : Type} {m : Type → Type} [self : Lean.MonadCache α β m] : α → β → m Unit`
  - Purpose: Store a value in the cache
  
- **`Lean.MonadCache.findCached?`**
  - Type: `{α β : Type} {m : Type → Type} [self : Lean.MonadCache α β m] : α → m (Option β)`
  - Purpose: Lookup a cached value
  
- **`Lean.checkCache`**
  - Type: `{α β : Type} {m : Type → Type} [Lean.MonadCache α β m] [Monad m] (a : α) (f : Unit → m β) : m β`
  - Purpose: Check cache and compute if missing

**Monad Transformers:**
- **`Lean.MonadCacheT`**
  - Type: `{ω : Type} (α β : Type) (m : Type → Type) [STWorld ω m] [BEq α] [Hashable α] : Type → Type`
  - Purpose: Monad transformer adding caching capability
  
- **`Lean.MonadStateCacheT`**
  - Type: `(α β : Type) (m : Type → Type) [BEq α] [Hashable α] : Type → Type`
  - Purpose: State-based cache transformer

**HashMap Cache Adapter:**
- **`Lean.MonadHashMapCacheAdapter`**
  - Type: `(α β : Type) (m : Type → Type) [BEq α] [Hashable α] : Type`
  - Purpose: Adapter for HashMap-based caching
  
- **`Lean.MonadHashMapCacheAdapter.cache`**
  - Type: `{α β : Type} {m : Type → Type} [BEq α] [Hashable α] [Lean.MonadHashMapCacheAdapter α β m] (a : α) (b : β) : m Unit`
  
- **`Lean.MonadHashMapCacheAdapter.findCached?`**
  - Type: `{α β : Type} {m : Type → Type} [BEq α] [Hashable α] [Monad m] [Lean.MonadHashMapCacheAdapter α β m] (a : α) : m (Option β)`
  
- **`Lean.MonadHashMapCacheAdapter.getCache`**
  - Type: `{α β : Type} {m : Type → Type} [BEq α] [Hashable α] [self : Lean.MonadHashMapCacheAdapter α β m] : m (Std.HashMap α β)`
  
- **`Lean.MonadHashMapCacheAdapter.modifyCache`**
  - Type: `{α β : Type} {m : Type → Type} [BEq α] [Hashable α] [self : Lean.MonadHashMapCacheAdapter α β m] : (Std.HashMap α β → Std.HashMap α β) → m Unit`

#### Domain-Specific Cache Systems

##### Std.Sat.AIG (And-Inverter Graph) Cache System

**Core Cache Types:**
- **`Std.Sat.AIG.Cache`** - `Std.Sat.AIG.Basic`
  - Type: `(α : Type) [DecidableEq α] [Hashable α] (decls : Array (Std.Sat.AIG.Decl α)) : Type`
  - Purpose: Cache for AIG construction
  
- **`Std.Sat.AIG.CacheHit`** - `Std.Sat.AIG.Basic`
  - Type: `{α : Type} (decls : Array (Std.Sat.AIG.Decl α)) (decl : Std.Sat.AIG.Decl α) : Type`
  - Purpose: Witness that a declaration is cached

**Cache Operations:**
- **`Std.Sat.AIG.Cache.empty`**
  - Type: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} : Std.Sat.AIG.Cache α decls`
  
- **`Std.Sat.AIG.Cache.get?`**
  - Type: `{α : Type} [Hashable α] [DecidableEq α] {decls : Array (Std.Sat.AIG.Decl α)} (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Option (Std.Sat.AIG.CacheHit decls decl)`
  
- **`Std.Sat.AIG.Cache.insert`**
  - Type: `{α : Type} [Hashable α] [DecidableEq α] (decls : Array (Std.Sat.AIG.Decl α)) (cache : Std.Sat.AIG.Cache α decls) (decl : Std.Sat.AIG.Decl α) : Std.Sat.AIG.Cache α (decls.push decl)`
  
- **`Std.Sat.AIG.cache`**
  - Type: `{α : Type} [DecidableEq α] [Hashable α] (self : Std.Sat.AIG α) : Std.Sat.AIG.Cache α self.decls`

**Cached Gate Constructors** (Std.Sat.AIG.CachedGates):
- **`Std.Sat.AIG.mkAndCached`** - Cached AND gate
- **`Std.Sat.AIG.mkOrCached`** - Cached OR gate
- **`Std.Sat.AIG.mkXorCached`** - Cached XOR gate
- **`Std.Sat.AIG.mkNotCached`** - Cached NOT gate
- **`Std.Sat.AIG.mkImpCached`** - Cached implication gate
- **`Std.Sat.AIG.mkBEqCached`** - Cached boolean equality gate
- **`Std.Sat.AIG.mkIfCached`** - Cached if-then-else gate
- **`Std.Sat.AIG.mkAtomCached`** - Cached atom constructor
- **`Std.Sat.AIG.mkConstCached`** - Cached constant constructor
- **`Std.Sat.AIG.mkGateCached`** - Generic cached gate constructor

**CNF Conversion Cache** (Std.Sat.AIG.CNF):
- **`Std.Sat.AIG.toCNF.Cache`**
  - Type: `(aig : Std.Sat.AIG ℕ) (cnf : Std.Sat.CNF aig.CNFVar) : Type`
  
- **`Std.Sat.AIG.toCNF.Cache.init`**
  - Type: `(aig : Std.Sat.AIG ℕ) : Std.Sat.AIG.toCNF.Cache aig []`
  
- **`Std.Sat.AIG.toCNF.State.cache`**
  - Type: `{aig : Std.Sat.AIG ℕ} (self : Std.Sat.AIG.toCNF.State aig) : Std.Sat.AIG.toCNF.Cache aig self.cnf`

##### Std.Tactic.BVDecide (Bit-Vector Decision) Cache System

**BVExpr Cache Types:**
- **`Std.Tactic.BVDecide.BVExpr.Cache`** - `Std.Tactic.BVDecide.Bitblast.BVExpr.Circuit.Impl.Expr`
  - Type: `(aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit) : Type`
  
- **`Std.Tactic.BVDecide.BVExpr.Cache.Key`**
  - Type: `Type`
  
- **`Std.Tactic.BVDecide.BVExpr.WithCache`**
  - Type: `(α : Type u) (aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit) : Type u`

**Cache Operations:**
- **`Std.Tactic.BVDecide.BVExpr.Cache.empty`**
  - Type: `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} : Std.Tactic.BVDecide.BVExpr.Cache aig`
  
- **`Std.Tactic.BVDecide.BVExpr.Cache.get?`**
  - Type: `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} {w : ℕ} (cache : Std.Tactic.BVDecide.BVExpr.Cache aig) (expr : Std.Tactic.BVDecide.BVExpr w) : Option (aig.RefVec w)`
  
- **`Std.Tactic.BVDecide.BVExpr.Cache.insert`**
  - Type: `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} {w : ℕ} (cache : Std.Tactic.BVDecide.BVExpr.Cache aig) (expr : Std.Tactic.BVDecide.BVExpr w) (refs : aig.RefVec w) : Std.Tactic.BVDecide.BVExpr.Cache aig`
  
- **`Std.Tactic.BVDecide.BVExpr.Cache.cast`**
  - Type: `{aig1 aig2 : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} (cache : Std.Tactic.BVDecide.BVExpr.Cache aig1) (h : aig1.decls.size ≤ aig2.decls.size) : Std.Tactic.BVDecide.BVExpr.Cache aig2`

**Bitblasting with Cache:**
- **`Std.Tactic.BVDecide.BVExpr.bitblast.goCache`**
  - Type: `{w : ℕ} (aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit) (expr : Std.Tactic.BVDecide.BVExpr w) (cache : Std.Tactic.BVDecide.BVExpr.Cache aig) : Std.Tactic.BVDecide.BVExpr.Return aig w`
  
- **`Std.Tactic.BVDecide.BVExpr.Return.cache`**
  - Type: `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} {w : ℕ} (self : Std.Tactic.BVDecide.BVExpr.Return aig w) : Std.Tactic.BVDecide.BVExpr.Cache (↑self.result).aig`
  
- **`Std.Tactic.BVDecide.Return.cache`**
  - Type: `{aig : Std.Sat.AIG Std.Tactic.BVDecide.BVBit} (self : Std.Tactic.BVDecide.Return aig) : Std.Tactic.BVDecide.BVExpr.Cache (↑self.result).aig`

#### Lean Core State Caches

**Core State:**
- **`Lean.Core.Cache`** - `Lean.Meta.Basic`
  - Type: Structure containing various caches
  
- **`Lean.Core.State.cache`**
  - Type: `(self : Lean.Core.State) : Lean.Core.Cache`

**Meta State:**
- **`Lean.Meta.Cache`** - `Lean.Meta.Basic`
  - Type: Meta-level cache structure
  
- **`Lean.Meta.State.cache`**
  - Type: `(self : Lean.Meta.State) : Lean.Meta.Cache`

**Simplification Cache:**
- **`Lean.Meta.Simp.Cache`** - Cache for simplification procedures
- **`Lean.Meta.Simp.Result.cache`** - Cache result for simplification
- **`Lean.Meta.Simp.State.cache`**
  - Type: `(self : Lean.Meta.Simp.State) : Lean.Meta.Simp.Cache`

#### Lean Expression Utilities

**No-Cache Variants** (for when caching is not desired):
- **`Lean.Expr.replaceNoCache`** - `Lean.Util.ReplaceExpr`
  - Type: `(f? : Lean.Expr → Option Lean.Expr) (e : Lean.Expr) : Lean.Expr`
  - Purpose: Replace subexpressions without caching
  
- **`Lean.Expr.instantiateLevelParamsNoCache`** - `Lean.Util.InstantiateLevelParams`
  - Type: `(e : Lean.Expr) (paramNames : List Lean.Name) (lvls : List Lean.Level) : Lean.Expr`
  - Purpose: Instantiate level parameters without caching

#### Lean Compiler & Specialized Caches

- **`Lean.Compiler.LCNF.Specialize.Cache`** - LCNF specialization cache
- **`Lean.Compiler.LCNF.ToLCNF.State.cache`** - LCNF conversion cache
- **`Lean.HasConstCache.cache`** - Constant checking cache
- **`Lean.Meta.Canonicalizer.State.cache`** - Expression canonicalization cache
- **`Lean.Meta.LazyDiscrTree.Cache`** - Discrimination tree cache
- **`Lean.MetavarContext.LevelMVarToParam.State.cache`** - Metavariable level parameter cache
- **`Lean.MetavarContext.MkBinding.State.cache`** - Binding construction cache

#### Lean Tactic & Proof Caches

- **`Batteries.Tactic.Cache`** - General tactic cache
- **`Batteries.Tactic.DeclCache.cache`** - Declaration cache
- **`Lean.Elab.WF.GuessLex.RecCallCache.cache`** - Well-founded recursion cache
- **`Lean.Elab.Tactic.Omega.Cache`** - Omega tactic cache
- **`Lean.Elab.Tactic.BVDecide.Frontend.Normalize.AndFlattenState.cache`** - BV normalization cache
- **`Lean.Meta.Grind.Arith.Linear.ProofM.State.cache`** - Linear arithmetic cache
- **`Lean.Meta.Grind.Arith.CommRing.ProofM.State.cache`** - Commutative ring cache
- **`Lean.Meta.Grind.AC.ProofM.State.cache`** - Associative-commutative cache
- **`Lean.Meta.AbstractNestedProofs.Context.cache`** - Nested proof abstraction cache
- **`Lean.Meta.FunInd.Collector.Cache`** - Function induction collector cache
- **`Lean.Meta.Try.Collector.Cache`** - Try collector cache
- **`Lean.Meta.CheckAssignment.State.cache`** - Assignment checking cache

#### Lean Parser Cache

- **`Lean.Parser.ParserCache`** - `Lean.Parser.Types`
  - Type: Type for parser caching
  
- **`Lean.Parser.ParserCacheEntry`** - `Lean.Parser.Types`
  - Type: Individual cache entry
  
- **`Lean.Parser.CacheableParserContext`** - `Lean.Parser.Types`
  - Type: Cacheable parser context
  
- **`Lean.Parser.ParserState.cache`** - Parser state cache field

#### Mathlib Caches

- **`Mathlib.Meta.FunProp.State.cache`** - Function property state cache
- **`Mathlib.Tactic.Ring.Cache`** - Ring tactic cache
- **`Mathlib.Tactic.BicategoryLike.State.cache`** - Bicategory tactic cache
- **`Mathlib.Tactic.CC.CCStructure.cache`** - Congruence closure cache

---

## 2. Memoization Functions

### 2.1 Name Search: "memoize"

**Total Matches**: 6 declarations

#### Core Memoization Configuration

1. **`Lean.Meta.Simp.Config.memoize`**
   - Type: `(self : Lean.Meta.Simp.Config) : Bool`
   - Module: `Init.MetaTypes`
   - Library: Init (Lean Core)
   - Purpose: Configuration flag for simplifier memoization (default: true)

2. **`Lean.Meta.Simp.Context.setMemoize`**
   - Type: `(c : Lean.Meta.Simp.Context) (flag : Bool) : Lean.Meta.Simp.Context`
   - Module: `Lean.Meta.Tactic.Simp.Types`
   - Library: Lean Core
   - Purpose: Set memoization flag in simplifier context

#### Iterator Memoization (Std Library)

3. **`Std.Iterators.Zip.memoizedLeft`**
   - Type: `{α₁ : Type w} {m : Type w → Type w'} {β₁ : Type w} [Std.Iterators.Iterator α₁ m β₁] {α₂ β₂ : Type w} (self : Std.Iterators.Zip α₁ m α₂ β₂) : Option { out // ∃ it, it.IsPlausibleOutput out }`
   - Module: `Std.Data.Iterators.Combinators.Monadic.Zip`
   - Library: Std
   - Purpose: Memoized left iterator value in zip combinator

4-6. **`Std.Iterators.Zip.rel*_of_memoizedLeft`**
   - Modules: `Std.Data.Iterators.Combinators.Monadic.Zip`
   - Library: Std
   - Purpose: Relation theorems about memoized iterator states
   - Variants: `rel₁_of_memoizedLeft`, `rel₂_of_memoizedLeft`, `rel₃_of_memoizedLeft`

### 2.2 Name Search: "memo"

**Total Matches**: 119 declarations (most are "mem" substring matches)

#### Primary Memoization Function

**`memoFix`** (Most Important)
- **Type**: `{α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β`
- **Module**: `Mathlib.Util.MemoFix`
- **Library**: Mathlib
- **Documentation**: Takes the fixpoint of `f` with caching of values that have been seen before. Hashing makes use of a pointer hash. This is useful for implementing tree traversal functions where subtrees may be referenced in multiple places.
- **Use Case**: Memoized fixed-point computation for recursive functions

#### Memory System Functions (Std Library)

System-level memory queries:
- **`Std.Internal.UV.System.availableMemory`** - `IO UInt64`
- **`Std.Internal.UV.System.constrainedMemory`** - `IO UInt64`
- **`Std.Internal.UV.System.freeMemory`** - `IO UInt64`
- **`Std.Internal.UV.System.totalMemory`** - `IO UInt64`
- Module: `Std.Internal.UV.System`

#### Server/Diagnostics Memoization (Lean Core)

- **`Lean.Server.FileWorker.MemorizedInteractiveDiagnostics`**
  - Type: `Type`
  - Module: `Lean.Server.FileWorker`
  - Purpose: State stored in `Snapshot.Diagnostics.cacheRef?`

#### LLVM Memory Buffer (Lean Compiler)

- **`LLVM.MemoryBuffer`**
  - Type: `(ctx : LLVM.Context) : Type`
  - Module: `Lean.Compiler.IR.LLVMBindings`
  
- **`LLVM.createMemoryBufferWithContentsOfFile`**
  - Type: `{ctx : LLVM.Context} (path : String) : BaseIO (LLVM.MemoryBuffer ctx)`
  - Module: `Lean.Compiler.IR.LLVMBindings`

---

## 3. State Monad Patterns

### 3.1 Name Search: "State"

**Total Matches**: 2,628 declarations (showing first 200)

#### Core State Monads (Init.Prelude, Init.Control.State)

##### EStateM - Exception State Monad

**Core Type:**
- **`EStateM`**
  - Type: `(ε σ α : Type u) : Type u`
  - Purpose: Exception state monad combining exceptions and state
  
- **`EStateM.Result`**
  - Type: `(ε σ α : Type u) : Type u`
  - Purpose: Result type for exception state monad
  
- **`EStateM.Backtrackable`**
  - Type: `(δ : outParam (Type u)) (σ : Type u) : Type u`
  - Purpose: Backtrackable state capability

**Operations:**
- **`EStateM.get`** - `{ε σ : Type u} : EStateM ε σ σ`
- **`EStateM.set`** - `{ε σ : Type u} (s : σ) : EStateM ε σ PUnit.{u + 1}`
- **`EStateM.pure`** - `{ε σ α : Type u} (a : α) : EStateM ε σ α`
- **`EStateM.throw`** - `{ε σ α : Type u} (e : ε) : EStateM ε σ α`
- **`EStateM.bind`** - `{ε σ α β : Type u} (x : EStateM ε σ α) (f : α → EStateM ε σ β) : EStateM ε σ β`
- **`EStateM.run`** - `{ε σ α : Type u} (x : EStateM ε σ α) (s : σ) : EStateM.Result ε σ α`
- **`EStateM.modifyGet`** - `{ε σ α : Type u} (f : σ → α × σ) : EStateM ε σ α`

##### StateM - State Monad

**Core Types:**
- **`StateM`**
  - Type: `(σ α : Type u) : Type u`
  - Purpose: Simple state monad
  
- **`StateT`**
  - Type: `(σ : Type u) (m : Type u → Type v) (α : Type u) : Type (max u v)`
  - Purpose: State monad transformer

**Basic Operations:**
- **`StateT.get`** - `{σ : Type u} {m : Type u → Type v} [Monad m] : StateT σ m σ`
- **`StateT.set`** - `{σ : Type u} {m : Type u → Type v} [Monad m] : σ → StateT σ m PUnit.{u + 1}`
- **`StateT.pure`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : StateT σ m α`
- **`StateT.bind`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (x : StateT σ m α) (f : α → StateT σ m β) : StateT σ m β`
- **`StateT.run`** - `{σ : Type u} {m : Type u → Type v} {α : Type u} (x : StateT σ m α) (s : σ) : m (α × σ)`
- **`StateT.run'`** - `{σ : Type u} {m : Type u → Type v} [Functor m] {α : Type u} (x : StateT σ m α) (s : σ) : m α`
- **`StateT.modifyGet`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (f : σ → α × σ) : StateT σ m α`

##### MonadState - State Monad Type Class

**Type Classes:**
- **`MonadState`**
  - Type: `(σ : outParam (Type u)) (m : Type u → Type v) : Type (max (u + 1) v)`
  - Purpose: Generic state monad interface
  
- **`MonadStateOf`**
  - Type: `(σ : semiOutParam (Type u)) (m : Type u → Type v) : Type (max (u + 1) v)`
  - Purpose: Specific state monad instance

**Operations:**
- **`MonadState.get`** - `{σ : outParam (Type u)} {m : Type u → Type v} [self : MonadState σ m] : m σ`
- **`MonadState.set`** - `{σ : outParam (Type u)} {m : Type u → Type v} [self : MonadState σ m] : σ → m PUnit.{u + 1}`
- **`MonadState.modifyGet`** - `{σ : outParam (Type u)} {m : Type u → Type v} [self : MonadState σ m] {α : Type u} : (σ → α × σ) → m α`

##### StateCpsT - CPS-style State Transformer

- **`StateCpsT`**
  - Type: `(σ : Type u) (m : Type u → Type v) (α : Type u) : Type (max (u + 1) v)`
  - Module: `Init.Control.StateCps`
  - Purpose: Continuation-passing style state transformer
  
- **`StateCpsT.run`** - `{α σ : Type u} {m : Type u → Type v} [Monad m] (x : StateCpsT σ m α) (s : σ) : m (α × σ)`
- **`StateCpsT.run'`** - `{α σ : Type u} {m : Type u → Type v} [Monad m] (x : StateCpsT σ m α) (s : σ) : m α`
- **`StateCpsT.runK`** - `{α σ : Type u} {m : Type u → Type v} {β : Type u} (x : StateCpsT σ m α) (s : σ) (k : α → σ → m β) : m β`

##### StateRefT' - Reference-based State

- **`StateRefT'`**
  - Type: `(ω σ : Type) (m : Type → Type) (α : Type) : Type`
  - Module: `Init.Control.StateRef`
  - Purpose: Reference-based state transformer using ST monad
  
- **`StateRefT'.get`** - `{ω σ : Type} {m : Type → Type} [MonadLiftT (ST ω) m] : StateRefT' ω σ m σ`
- **`StateRefT'.set`** - `{ω σ : Type} {m : Type → Type} [MonadLiftT (ST ω) m] (s : σ) : StateRefT' ω σ m PUnit.{1}`
- **`StateRefT'.run`** - `{ω σ : Type} {m : Type → Type} [Monad m] [MonadLiftT (ST ω) m] {α : Type} (x : StateRefT' ω σ m α) (s : σ) : m (α × σ)`

#### Lean Compiler & Core States

**Lean.Macro.State:**
- **`Lean.Macro.State`** - Type (Init.Prelude)
- **`Lean.Macro.State.macroScope`** - `(self : Lean.Macro.State) : Lean.MacroScope`
- **`Lean.Macro.State.traceMsgs`** - `(self : Lean.Macro.State) : List (Lean.Name × String)`

**Lean.Core.State:**
- **`Lean.Core.State`** - Type (Lean.Core)

**Lean.Meta.State:**
- **`Lean.Meta.State`** - Type (Lean.Meta)

**Lean.Elab States:**
- **`Lean.Elab.Level.State`** - Level elaboration state
- **`Lean.Elab.Tactic.State`** - Tactic elaboration state
- **`Lean.Elab.Term.State`** - Term elaboration state
- **`Lean.Elab.Command.State`** - Command elaboration state
- **`Lean.Elab.Frontend.State`** - Frontend state
- **`Lean.Elab.Do.State`** - Do notation state

**Lean.Compiler States:**
- **`Lean.Compiler.LCNF.CompilerM.State`** - LCNF compiler monad state
- **`Lean.Compiler.LCNF.Check.State`** - LCNF type checker state
- **`Lean.Compiler.LCNF.CSE.State`** - Common subexpression elimination state
- **`Lean.Compiler.LCNF.Simp.State`** - LCNF simplifier state
- **`Lean.Compiler.LCNF.Closure.State`** - Closure conversion state
- **`Lean.Compiler.LCNF.ToLCNF.State`** - Translation to LCNF state

**Lean.Meta Substates:**
- **`Lean.Meta.Simp.State`** - Simplifier state
- **`Lean.Meta.SimpAll.State`** - Simplify-all state
- **`Lean.Meta.SynthInstance.State`** - Type class synthesis state
- **`Lean.Meta.Match.State`** - Pattern matching state
- **`Lean.Meta.Closure.State`** - Closure state
- **`Lean.Meta.Grind.State`** - Grind tactic state

#### Standard Library States

**ST.Out.state:**
- **`ST.Out.state`**
  - Type: `{σ α : Type} (self : ST.Out σ α) : Void σ`
  - Module: `Init.System.ST`

**ST.Ref:**
- **`ST.Ref.toMonadStateOf`**
  - Type: `{σ : Type} {m : Type → Type} [MonadLiftT (ST σ) m] {α : Type} (r : ST.Ref σ α) : MonadStateOf α m`

**IO.TaskState:**
- **`IO.TaskState`** - Type (Init.System.IO)
- **`IO.TaskState.running`** - `IO.TaskState`
- **`IO.TaskState.waiting`** - `IO.TaskState`
- **`IO.TaskState.finished`** - `IO.TaskState`

---

## 4. StateT Transformer Patterns

### 4.1 Name Search: "StateT"

**Total Matches**: 159 declarations

See detailed breakdown in Section 3.1 above. Key categories:
- Core type and operations (10 declarations)
- Monad instances (15 declarations)
- Lawful instances (25 declarations)
- Std.Do verification infrastructure (20 declarations)
- Batteries extensions (10 declarations)
- Mathlib control theory (15 declarations)
- Lean server/elaboration integration (64 declarations)

---

## 5. Mutable Reference Patterns

### 5.1 Name Search: "IO.Ref"

**Total Matches**: 186 declarations

#### Core Type and Constructor

1. **`IO.Ref`**
   - Type: `(α : Type) : Type`
   - Module: `Init.System.IO`
   - Purpose: Mutable reference in IO monad

2. **`IO.mkRef`**
   - Type: `{α : Type} (a : α) : BaseIO (IO.Ref α)`
   - Purpose: Create new mutable reference

#### Standard Library (Init) - Basic IO References

3. **`IO.FS.Stream.ofBuffer`**
   - Type: `(r : IO.Ref IO.FS.Stream.Buffer) : IO.FS.Stream`
   
4. **`IO.stdGenRef`**
   - Type: `IO.Ref StdGen`
   - Module: `Init.Data.Random`
   - Purpose: Global random number generator reference

#### Lean Core - Compiler & Environment

Global registries using IO.Ref:
- **`Lean.searchPathRef`** - `IO.Ref Lean.SearchPath`
- **`Lean.persistentEnvExtensionsRef`** - `IO.Ref (Array ...)`
- **`Lean.internalExceptionsRef`** - `IO.Ref (Array Lean.Name)`
- **`Lean.builtinDeclRanges`** - `IO.Ref (Lean.NameMap Lean.DeclarationRanges)`
- **`Lean.compileDeclsRef`** - `IO.Ref (Array Lean.Name → Lean.CoreM Unit)`
- **`Lean.interpretedModInits`** - `IO.Ref Lean.NameSet`

#### Lean Core - Attributes & Extensions

- **`Lean.attributeImplBuilderTableRef`** - `IO.Ref Lean.AttributeImplBuilderTable`
- **`Lean.attributeMapRef`** - `IO.Ref (Std.HashMap Lean.Name Lean.AttributeImpl)`
- **`Lean.scopedEnvExtensionsRef`** - `IO.Ref (Array ...)`
- **`Lean.labelExtensionMapRef`** - `IO.Ref Lean.LabelExtensionMap`

#### Lean Core - Parser System

Parser registries (15+ declarations):
- **`categoryParserFnRef`**, **`builtinParserCategoriesRef`**
- **`builtinSyntaxNodeKindSetRef`**, **`builtinTokenTable`**
- **`parserAlias2kindRef`**, **`parserAliases2infoRef`**
- **`parserAliasesRef`**, **`parserAttributeHooks`**

#### Lean Core - Meta/Tactic System

Simplification and tactic registries:
- **`simpExtensionMapRef`**, **`builtinSEvalprocsRef`**
- **`builtinSimprocDeclsRef`**, **`builtinSimprocsRef`**
- **`simprocExtensionMapRef`**

#### Lean Core - Server & LSP (43+ declarations)

Extensive server infrastructure:
- **Request handling**: `requestHandlers`, `statefulRequestHandlers`
- **File workers**: `FileWorkerMap`, `RpcSession` references
- **Cancellation**: `RequestCancellationToken` with multiple `IO.Ref Bool` fields
- **Document state**: `diagnosticsRef`, `EditableDocumentCore`
- **Context structures**: `RequestContext`, `WorkerContext`, `WorkerState`

#### Aesop (Automated Theorem Prover) - 55+ declarations

Tree data structures using `IO.Ref` for:
- **GoalData**, **RappData**, **MVarClusterData** structures
- Parent-child relationships in proof search trees
- **`declaredRuleSetsRef`**

#### External Tools

- **`LeanSearchClient.leanSearchCache`** - Search result caching
- **`LeanSearchClient.stateSearchCache`** - State search caching
- **`LeanSearchClient.loogleCache`** - Loogle result caching

---

## 6. Type Pattern Matches

### 6.1 Pattern: `α → m α` (Caching Wrapper)

**Total Matches**: 3,650+ declarations (showing first 200)

#### Core Monad Infrastructure

**Pure Operations:**
- **`ReaderT.pure`** - `{ρ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : ReaderT ρ m α`
- **`ExceptT.pure`** - `{ε : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : ExceptT ε m α`
- **`StateT.pure`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : StateT σ m α`
- **`OptionT.pure`** - `{m : Type u → Type v} [Monad m] {α : Type u} (a : α) : OptionT m α`

**Lifting Operations:**
- **`ExceptT.lift`** - `{ε : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (t : m α) : ExceptT ε m α`
- **`StateT.lift`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (t : m α) : StateT σ m α`
- **`OptionT.lift`** - `{m : Type u → Type v} [Monad m] {α : Type u} (x : m α) : OptionT m α`

**Array Operations:**
- **`Array.modifyM`**
  - Type: `{α : Type u} {m : Type u → Type u_1} [Monad m] (xs : Array α) (i : ℕ) (f : α → m α) : m (Array α)`
  - Purpose: Monadic modification of array element
  
- **`Array.modifyMUnsafe`**
  - Type: `{α : Type u} {m : Type u → Type u_1} [Monad m] (xs : Array α) (i : ℕ) (f : α → m α) : m (Array α)`
  - Purpose: Unsafe version for performance

### 6.2 Pattern: `_ → StateT _ _ _` (StateT Patterns)

**Total Matches**: 66 out of 159 StateT declarations

#### Core StateT Operations

**State Access:**
- **`StateT.get`** - `{σ : Type u} {m : Type u → Type v} [Monad m] : StateT σ m σ`
- **`StateT.set`** - `{σ : Type u} {m : Type u → Type v} [Monad m] : σ → StateT σ m PUnit.{u + 1}`
- **`StateT.modifyGet`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (f : σ → α × σ) : StateT σ m α`

**Monad Operations:**
- **`StateT.pure`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : StateT σ m α`
- **`StateT.lift`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (t : m α) : StateT σ m α`
- **`StateT.bind`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (x : StateT σ m α) (f : α → StateT σ m β) : StateT σ m β`
- **`StateT.map`** - `{σ : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (f : α → β) (x : StateT σ m α) : StateT σ m β`

**Alternative Operations:**
- **`StateT.failure`** - `{σ : Type u} {m : Type u → Type v} [Alternative m] {α : Type u} : StateT σ m α`
- **`StateT.orElse`** - `{σ : Type u} {m : Type u → Type v} [Alternative m] {α : Type u} (x₁ : StateT σ m α) (x₂ : Unit → StateT σ m α) : StateT σ m α`

#### Lean Server Infrastructure

**Request Handlers:**
- **`Lean.Server.StatefulRequestHandler.pureOnDidChange`**
  - Type: `(self : Lean.Server.StatefulRequestHandler) : Lean.Lsp.DidChangeTextDocumentParams → StateT Dynamic Lean.Server.RequestM Unit`
  
- **`Lean.Server.FileWorker.handleInlayHintsDidChange`**
  - Type: `(p : Lean.Lsp.DidChangeTextDocumentParams) : StateT Lean.Server.FileWorker.InlayHintState Lean.Server.RequestM Unit`
  
- **`Lean.Server.FileWorker.handleSemanticTokensDidChange`**
  - Type: `Lean.Lsp.DidChangeTextDocumentParams → StateT Lean.Server.FileWorker.SemanticTokensState Lean.Server.RequestM Unit`

#### Documentation & Metaprogramming

**Doc String Parsing:**
- **`Lean.Doc.getFlag`**
  - Type: `(name : Lean.Name) (default : Bool) : StateT (Array (Lean.TSyntax \`doc_arg)) Lean.Doc.DocM Bool`
  
- **`Lean.Doc.getPositional`**
  - Type: `{α : Type} [Lean.Doc.FromDocArg α] (name : Lean.Name) : StateT (Array (Lean.TSyntax \`doc_arg)) Lean.Doc.DocM α`

**Quoted Expressions:**
- **`Qq.Impl.floatLevelAntiquot'`**
  - Type: `{m : Type → Type} [Monad m] [Lean.MonadQuotation m] (stx : Lean.Syntax) : StateT (Array (Lean.Syntax × Lean.Syntax × Lean.Syntax)) m Lean.Syntax`
  
- **`Qq.Impl.floatExprAntiquot`**
  - Type: `{m : Type → Type} [Monad m] [Lean.MonadQuotation m] (depth : ℕ) : Lean.Term → StateT (Array (Lean.Ident × Lean.Term × Lean.Term)) m Lean.Term`

#### Mathlib Tactics

**Tactic Utilities:**
- **`Mathlib.Tactic.Erw?.logDiffs`**
  - Type: `(tk : Lean.Syntax) (e₁ e₂ : Lean.Expr) : StateT (Array (Unit → Lean.MessageData)) Lean.MetaM Bool`
  
- **`Mathlib.PrintSorries.collect`**
  - Type: `(c : Lean.Name) : StateT Mathlib.PrintSorries.State Lean.MetaM Unit`
  
- **`Mathlib.Tactic.TFAE.dfs`**
  - Type: `(hyps : Array (ℕ × ℕ × Lean.Expr)) (atoms : Array Q(Prop)) (i j : ℕ) (P P' : Q(Prop)) (hP : Q(«$P»)) : StateT (Std.HashSet ℕ) Lean.MetaM Q(«$P'»)`

#### Control Theory

**Continuation Monad:**
- **`StateT.callCC`**
  - Type: `{m : Type u → Type v} {σ : Type u} [MonadCont m] {α β : Type u} (f : MonadCont.Label α (StateT σ m) β → StateT σ m α) : StateT σ m α`
  - Module: `Mathlib.Control.Monad.Cont`

---

## 7. Implementation Patterns Summary

### 7.1 Pure Functional Caching Approaches

**Pattern**: State monad with HashMap/DHashMap

**Example Structure**:
```lean
structure Cache (α β : Type) [BEq α] [Hashable α] where
  map : Std.HashMap α β

def lookup [BEq α] [Hashable α] (cache : Cache α β) (key : α) : Option β :=
  cache.map.find? key

def insert [BEq α] [Hashable α] (cache : Cache α β) (key : α) (value : β) : Cache α β :=
  { map := cache.map.insert key value }
```

**Usage Pattern**:
```lean
def cachedComputation [Monad m] [MonadState (Cache α β) m] 
    (key : α) (compute : Unit → m β) : m β := do
  let cache ← get
  match cache.lookup key with
  | some result => return result
  | none =>
    let result ← compute ()
    modify (·.insert key result)
    return result
```

**Advantages**:
- Pure functional
- Thread-safe (immutable)
- Compositional
- Easy to reason about

**Disadvantages**:
- Requires threading state through computation
- May have overhead from copying

**Examples in LEAN 4**:
- `Lean.MonadStateCacheT`
- `Std.Sat.AIG.Cache`
- `Std.Tactic.BVDecide.BVExpr.Cache`

### 7.2 Monadic State-Based Caching

**Pattern**: MonadCache type class

**Example Structure**:
```lean
class MonadCache (α β : Type) (m : Type → Type) where
  findCached? : α → m (Option β)
  cache : α → β → m Unit

def checkCache [MonadCache α β m] [Monad m] 
    (key : α) (compute : Unit → m β) : m β := do
  match ← findCached? key with
  | some result => return result
  | none =>
    let result ← compute ()
    cache key result
    return result
```

**Advantages**:
- Generic interface
- Composable with other monads
- Implementation-agnostic

**Disadvantages**:
- Requires monad transformer stack
- May have performance overhead

**Examples in LEAN 4**:
- `Lean.MonadCache`
- `Lean.MonadCacheT`
- `Lean.MonadHashMapCacheAdapter`

### 7.3 Mutable Reference Caching

**Pattern**: IO.Ref with HashMap

**Example Structure**:
```lean
structure MutableCache (α β : Type) [BEq α] [Hashable α] where
  ref : IO.Ref (Std.HashMap α β)

def mkMutableCache [BEq α] [Hashable α] : BaseIO (MutableCache α β) := do
  let ref ← IO.mkRef Std.HashMap.empty
  return { ref }

def lookup [BEq α] [Hashable α] (cache : MutableCache α β) (key : α) : IO (Option β) := do
  let map ← cache.ref.get
  return map.find? key

def insert [BEq α] [Hashable α] (cache : MutableCache α β) (key : α) (value : β) : IO Unit := do
  cache.ref.modify (·.insert key value)
```

**Usage Pattern**:
```lean
def cachedComputation [BEq α] [Hashable α] 
    (cache : MutableCache α β) (key : α) (compute : Unit → IO β) : IO β := do
  match ← cache.lookup key with
  | some result => return result
  | none =>
    let result ← compute ()
    cache.insert key result
    return result
```

**Advantages**:
- Efficient (in-place mutation)
- No state threading required
- Good for global caches

**Disadvantages**:
- Requires IO monad
- Not thread-safe without synchronization
- Harder to reason about

**Examples in LEAN 4**:
- `Lean.searchPathRef`
- `Lean.attributeMapRef`
- `Lean.Parser.categoryParserFnRef`
- `LeanSearchClient.loogleCache`

### 7.4 Transformer-Based Patterns

**Pattern**: StateT over base monad

**Example Structure**:
```lean
abbrev CachedM (α β γ : Type) (m : Type → Type) :=
  StateT (Cache α β) m γ

def runCached [Monad m] [BEq α] [Hashable α] 
    (comp : CachedM α β γ m) : m γ :=
  comp.run' { map := Std.HashMap.empty }

def withCache [Monad m] [BEq α] [Hashable α] 
    (key : α) (compute : Unit → CachedM α β β m) : CachedM α β β m := do
  let cache ← get
  match cache.lookup key with
  | some result => return result
  | none =>
    let result ← compute ()
    modify (·.insert key result)
    return result
```

**Advantages**:
- Composable with other transformers
- Clean separation of concerns
- Type-safe

**Disadvantages**:
- Transformer stack complexity
- Performance overhead from layers

**Examples in LEAN 4**:
- `Lean.Server.FileWorker` (StateT for request handling)
- `Mathlib.Tactic` utilities (StateT for tactic state)
- `Lean.Doc` parsing (StateT for doc args)

### 7.5 Memoized Fixed-Point Pattern

**Pattern**: `memoFix` for recursive functions

**Example**:
```lean
-- From Mathlib.Util.MemoFix
def memoFix {α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β
```

**Usage Pattern**:
```lean
-- Memoized Fibonacci
def fib : Nat → Nat :=
  memoFix fun fib n =>
    match n with
    | 0 => 0
    | 1 => 1
    | n + 2 => fib n + fib (n + 1)
```

**Advantages**:
- Automatic memoization
- Works for recursive functions
- Pointer-based hashing

**Disadvantages**:
- Requires `[Nonempty β]`
- Implementation-specific (pointer hash)
- Limited to pure functions

**Examples in LEAN 4**:
- `Mathlib.Util.MemoFix.memoFix`

---

## 8. Recommended Utilities

### Top 10 Most Useful Functions for Implementing Caching/Memoization

#### 1. **`Lean.MonadCache`** (Generic Caching Interface)
- **Type**: `(α β : Type) (m : Type → Type) : Type`
- **Module**: `Lean.Util.MonadCache`
- **Use Case**: Generic caching interface for any monad
- **Recommendation**: Use as base interface for custom caching

#### 2. **`Lean.MonadCacheT`** (Cache Transformer)
- **Type**: `{ω : Type} (α β : Type) (m : Type → Type) [STWorld ω m] [BEq α] [Hashable α] : Type → Type`
- **Module**: `Lean.Util.MonadCache`
- **Use Case**: Add caching to existing monad stack
- **Recommendation**: Use for composable caching in monadic code

#### 3. **`memoFix`** (Memoized Fixed-Point)
- **Type**: `{α β : Type} [Nonempty β] (f : (α → β) → α → β) : α → β`
- **Module**: `Mathlib.Util.MemoFix`
- **Use Case**: Automatic memoization for recursive functions
- **Recommendation**: Best for tree traversals and recursive computations

#### 4. **`IO.Ref`** + **`IO.mkRef`** (Mutable References)
- **Type**: `(α : Type) : Type` and `{α : Type} (a : α) : BaseIO (IO.Ref α)`
- **Module**: `Init.System.IO`
- **Use Case**: Global mutable caches in IO
- **Recommendation**: Use for global registries and persistent caches

#### 5. **`StateT`** (State Transformer)
- **Type**: `(σ : Type u) (m : Type u → Type v) (α : Type u) : Type (max u v)`
- **Module**: `Init.Control.State`
- **Use Case**: Thread cache state through computation
- **Recommendation**: Use for local caching in monadic pipelines

#### 6. **`Std.HashMap`** (Hash Map)
- **Type**: `(α : Type u) (β : Type v) [BEq α] [Hashable α] : Type (max u v)`
- **Module**: `Std.Data.HashMap`
- **Use Case**: Underlying storage for caches
- **Recommendation**: Primary data structure for key-value caching

#### 7. **`Lean.Meta.Simp.Config.memoize`** (Simplifier Memoization)
- **Type**: `(self : Lean.Meta.Simp.Config) : Bool`
- **Module**: `Init.MetaTypes`
- **Use Case**: Control simplifier caching behavior
- **Recommendation**: Use when customizing simplification

#### 8. **`Std.Sat.AIG.Cache`** (AIG Cache Pattern)
- **Type**: `(α : Type) [DecidableEq α] [Hashable α] (decls : Array (Std.Sat.AIG.Decl α)) : Type`
- **Module**: `Std.Sat.AIG.Basic`
- **Use Case**: Structural sharing in graph construction
- **Recommendation**: Pattern for DAG/graph caching

#### 9. **`Array.modifyM`** (Monadic Array Modification)
- **Type**: `{α : Type u} {m : Type u → Type u_1} [Monad m] (xs : Array α) (i : ℕ) (f : α → m α) : m (Array α)`
- **Module**: `Init.Data.Array.Basic`
- **Use Case**: Cached updates to array elements
- **Recommendation**: Use for array-based caches with monadic updates

#### 10. **`Lean.checkCache`** (Cache Check Helper)
- **Type**: `{α β : Type} {m : Type → Type} [Lean.MonadCache α β m] [Monad m] (a : α) (f : Unit → m β) : m β`
- **Module**: `Lean.Util.MonadCache`
- **Use Case**: Check cache and compute if missing
- **Recommendation**: Standard pattern for cache lookup with fallback

---

## 9. Design Patterns and Best Practices

### 9.1 Common Requirements

Most cache implementations require:
- **`[BEq α]`** - Equality comparison for keys
- **`[Hashable α]`** - Hashing for efficient lookup
- **Invariants** - Cache correctness properties (e.g., `Cache.Inv`)

### 9.2 Performance-Critical Areas

Caching is heavily used in:
1. **Expression replacement and substitution** - `Lean.Expr.replaceNoCache` (when caching not desired)
2. **SAT/SMT solving** - `Std.Sat.AIG.Cache`, `Std.Tactic.BVDecide.BVExpr.Cache`
3. **Tactic execution** - Various `*.State.cache` fields
4. **Parser state management** - `Lean.Parser.ParserCache`

### 9.3 Cache Invalidation Strategies

**Immutable Caches** (State monad):
- No invalidation needed
- Create new cache for new context

**Mutable Caches** (IO.Ref):
- Manual invalidation via `ref.set`
- Clear entire cache or selective removal

**Scoped Caches**:
- Cache lifetime tied to computation scope
- Automatic cleanup when scope exits

### 9.4 Thread Safety Considerations

**Pure Functional Caches**:
- Inherently thread-safe (immutable)
- No synchronization needed

**IO.Ref Caches**:
- Not thread-safe by default
- Require synchronization primitives for concurrent access
- Consider using `Task` with local caches instead

---

## 10. Conclusion

LEAN 4 provides a rich ecosystem for caching and memoization:

1. **Multiple Paradigms**: Pure functional (State), mutable (IO.Ref), and hybrid approaches
2. **Domain-Specific Solutions**: Specialized caches for AIG, BVExpr, Parser, Simp, etc.
3. **Generic Infrastructure**: `MonadCache` type class and transformers
4. **Automatic Memoization**: `memoFix` for recursive functions
5. **Production Use**: Extensive use in compiler, elaborator, and tactics

**Recommended Approach**:
- **For pure code**: Use `StateT` with `Std.HashMap`
- **For IO code**: Use `IO.Ref` with `Std.HashMap`
- **For recursive functions**: Use `memoFix`
- **For generic libraries**: Implement `MonadCache` interface

---

## Appendix: Search Methodology

**Queries Executed**:
1. Name search: "cache" → 569 matches
2. Name search: "memoize" → 6 matches
3. Name search: "memo" → 119 matches (mostly "mem" substring)
4. Name search: "State" → 2,628 matches
5. Name search: "StateT" → 159 matches
6. Name search: "IO.Ref" → 186 matches
7. Type pattern: "α → m α" → 3,650+ matches
8. Type pattern: "_ → StateT _ _ _" → 66 matches

**Total Unique Declarations**: 7,258+ (with overlap)

**Search Tool**: Loogle web service (https://loogle.lean-lang.org/)

**Note**: Loogle displays first 200 results for large result sets. Actual totals may be higher.
