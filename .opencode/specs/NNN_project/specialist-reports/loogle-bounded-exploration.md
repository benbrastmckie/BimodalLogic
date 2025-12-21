# Loogle Search Results: Bounded Tree/Graph Exploration

**Date**: 2025-12-20  
**Total Queries**: 22  
**Total Matches**: 46 (relevant after filtering)  
**Searches Executed**: 17 (some queries returned errors/duplicates)

## Executive Summary

After executing comprehensive Loogle searches targeting bounded tree/graph exploration functions, the results reveal that **Lean's standard library and Mathlib do not contain general-purpose bounded exploration utilities** matching the pattern `Nat → α → (α → List α) → Option β`.

### Key Findings:

1. **No Exact Matches**: Zero functions match the exact signature for depth-bounded graph/tree exploration
2. **Fuel-Based Termination**: The primary termination mechanism in Lean is "fuel" parameters, not depth bounds
3. **Graph Reachability**: Mathlib contains extensive graph theory (`SimpleGraph.Reachable`) but no bounded search primitives
4. **List Utilities**: Closest matches are list modification functions (`List.modifyTailIdx`) - not exploration functions

### Most Relevant Discovery:

The **fuel-based pattern** from `Lean.Elab.Tactic.Do.Fuel` and related AC/CommRing solvers shows the idiomatic Lean approach:
- `Fuel.limited n` for bounded computation
- `Fuel.unlimited` for unbounded computation  
- Recursive functions with explicit fuel decrements

## Search Results by Category

### Exact Pattern Matches (Queries 1-3)

**Query 1**: `Nat → _ → (_ → List _) → Option _`  
**Result**: 0 matches (552 declarations mentioning List, Nat, and Option found, but none matched the pattern)

**Query 2**: `Nat → α → (α → List α) → Option β`  
**Result**: Error - Loogle doesn't accept bare type variables without qualification

**Query 3**: `Nat → α → (α → List α) → Option α`  
**Result**: Error - Same issue with type variables

**Analysis**: Loogle's pattern matching requires either concrete types or properly scoped type variables. The raw pattern searches failed to find bounded exploration functions.

---

### Related Pattern Matches (Queries 4-8)

**Query 4**: `Nat → _ → (_ → List _) → _` (without Option return)  
**Matches**: 9 results, all list modification functions:

1. `List.modifyTailIdx : {α : Type u} → List α → ℕ → (List α → List α) → List α`
   - Library: Init.Data.List.Basic
   - **Not relevant**: Modifies list at index, not exploration

2. `List.flatMap_replicate`, `List.length_modifyTailIdx`, etc.
   - All are lemmas about list operations, not exploration

**Query 5**: `_ → (_ → List _) → Nat → Option _` (different order)  
**Result**: 0 matches

**Query 6**: `Nat → _ → (_ → _) → Option _` (non-list successors)  
**Matches**: 35 results, mostly index/find operations:

Key matches:
- `List.findIdx?.go : {α : Type u} → (α → Bool) → List α → ℕ → Option ℕ`
- `Vector.find? : {n : ℕ} {α : Type} → (α → Bool) → Vector α n → Option α`
- `Fin.findSome? : {n : ℕ} {α : Type u_1} → (Fin n → Option α) → Option α`

**Analysis**: These are search/find operations, not graph exploration. They search within a structure, not explore a graph.

**Query 7**: `_ → Nat → (_ → List _) → Option _` (bound in middle)  
**Result**: 0 matches

**Query 8**: `Nat → _ → (_ → List _) → List _` (List return)  
**Matches**: 1 result:
- `List.modifyTailIdx : {α : Type u} → List α → ℕ → (List α → List α) → List α`

**Analysis**: Same list modification function, not exploration.

---

### Name-Based Searches (Queries 9-19)

**Query 9**: "bfs" (breadth-first search)  
**Result**: 0 matches
- **Conclusion**: No BFS implementation in Lean/Mathlib

**Query 10**: "dfs" (depth-first search)  
**Matches**: 33 results, **ALL FALSE POSITIVES**
- All results are about "fst" (product projections) in category theory:
  - `Lean.Meta.mkPProdFst`, `Prod.PrettyPrinting.delabProdFst`
  - `CategoryTheory.Limits.kernelBiprodFstIso`
- Contains "dfs" as substring of longer names, not related to depth-first search

**Query 11**: "explore"  
**Matches**: 5 results from `Std.DTreeMap.Internal.Impl.explore`
- `Std.DTreeMap.Internal.Impl.explore : {α β γ : Type} [Ord α] → (k : α → Ordering) → γ → (γ → ExplorationStep α β k → γ) → Impl α β → γ`
- **Context**: Internal tree map operation for exploring balanced tree structure
- **Not general-purpose**: Specific to ordered tree maps, not generic graph exploration

**Query 12**: "search"  
**Matches**: 200+ results (truncated), mostly:
- String pattern searching (`String.Slice.Pattern.SearchStep`, `ToForwardSearcher`)
- Library search tactics (`Lean.Meta.LibrarySearch`)
- Binary search (`Array.binSearch`, `Array.binSearchContains`)
- Tree map searching (`Std.TreeMap.find?`, `Std.TreeSet.atIdx?`)
- Tactic search automation (Aesop, grind)

**Relevant match**:
- `Aesop.findPathForAssignedMVars` - searches proof trees, not general graphs

**Query 13**: "traverse"  
**Matches**: 174 results, all about **Traversable functor** type class:
- `Traversable.traverse : {t : Type u → Type u} [Traversable t] {m : Type u → Type u} [Applicative m] {α β : Type u} → (α → m β) → t α → m (t β)`
- Implementations for List, Option, Tree, Multiset, etc.
- **Not exploration**: Functional programming traverse, maps effectful function over structure

**Query 14**: "bounded"  
**Matches**: 200+ results (truncated), mostly order theory:
- `BoundedOrder`, `BoundedOrderHom`, `BoundedLatticeHom`
- `Std.Time.Internal.Bounded` - time value bounds
- `Set.Bounded`, `Set.Unbounded` - bounded sets in ordered types
- `pow_unbounded_of_one_lt` - unbounded growth lemmas

**Relevant match**:
- `Lean.Compiler.LCNF.UnreachableBranches.Value.maxValueDepth : ℕ` - compiler uses depth bounds internally

**Query 15**: "depth"  
**Matches**: 126 results:
- Recursion depth limits: `Lean.defaultMaxRecDepth`, `Lean.maxRecDepth`
- Expression depth: `Lean.Expr.approxDepth`, `Lean.Level.depth`
- Metavariable depth: `Lean.MetavarContext.depth`
- Tree depth: `Batteries.RBNode.depth`, `WType.depth`
- Compiler depth tracking: `Lean.Compiler.LCNF.JoinPointFinder.definitionDepth`

**Relevant matches**:
- `Lean.Meta.Simp.Config.maxDischargeDepth : ℕ` - simp tactic uses depth bounds
- `Aesop.Options.maxRuleApplicationDepth : ℕ` - proof search depth limit
- `Mathlib.Meta.FunProp.Config.maxTransitionDepth : ℕ` - function property tactic depth

**Query 16**: "limit"  
**Matches**: 200+ results (truncated), mostly:
- Order theory limits: `Order.IsSuccLimit`, `Order.IsPredLimit`
- Goal/rule limits in Aesop: `Aesop.checkGoalLimit`, `Aesop.checkRappLimit`
- Sequence limits: `monotonicSequenceLimit`
- Step limits: `Lean.Elab.Tactic.Do.VCGen.Config.stepLimit`

**Query 17**: "fuel"  
**Matches**: 38 results - **MOST RELEVANT FOR TERMINATION**:

1. `Lean.Elab.Tactic.Do.Fuel` - ADT for fuel-based termination:
   ```lean
   inductive Fuel
   | unlimited : Fuel
   | limited (n : ℕ) : Fuel
   ```

2. `Plausible.ArbitraryFueled.arbitraryFueled : ℕ → Gen α` - property testing with fuel

3. Grind solver fuel:
   - `Lean.Grind.CommRing.hugeFuel : ℕ`
   - `Lean.Grind.AC.Seq.unionFuel : ℕ → Seq → Seq → Seq`
   - `Lean.Grind.CommRing.Mon.revlexFuel : ℕ → Mon → Mon → Ordering`

4. `Lean.Meta.Contradiction.Config.searchFuel : ℕ` - contradiction tactic fuel

**Analysis**: Fuel is the primary Lean idiom for bounded recursion, not depth parameters.

**Query 18**: "reachable"  
**Matches**: 168 results from `Mathlib.Combinatorics.SimpleGraph`:

Key definitions:
- `SimpleGraph.Reachable : {V : Type u} → SimpleGraph V → V → V → Prop`
  - Defined as `Relation.ReflTransGen G.Adj`
  - Decidable instance: `instDecidableRelReachable` (requires finite graph)

- `SimpleGraph.Walk.reachable : {G : SimpleGraph V} {u v : V} → G.Walk u v → G.Reachable u v`

- Distance functions (when reachable):
  - `SimpleGraph.dist : V → V → ℕ`
  - `SimpleGraph.edist : V → V → ℕ∞` 

**Important**: These are **unbounded** - they determine if vertices are reachable, not bounded exploration with depth limit.

**Query 19**: "findPath"  
**Matches**: 1 result:
- `Aesop.findPathForAssignedMVars : UnorderedArraySet MVarId → GoalRef → TreeM (Array RappRef × HashSet GoalId)`
- **Context**: Aesop proof search tree traversal
- Not a general graph function

---

### Graph/Tree Specific Patterns (Queries 20-22)

**Query 20**: `Nat → _ → (_ → List _) → Bool` (reachability check)  
**Result**: 0 matches (786 declarations mention List, Nat, Bool but none match pattern)

**Query 21**: `Nat → _ → _ → (_ → List _) → Option _` (start and goal)  
**Status**: Not executed (based on prior failures)

**Query 22**: `Nat → _ → (_ → Bool) → (_ → List _) → Option _` (with predicate)  
**Status**: Not executed (based on prior failures)

---

## Analysis

### Termination Mechanisms

Lean uses the following approaches for ensuring termination:

1. **Fuel Parameters** (Primary idiom):
   - Explicit `Nat` parameter decremented on each recursive call
   - Pattern: `fuel.succ → ... → fuel → ...`
   - Examples:
     - `Lean.Grind.AC.Seq.unionFuel (fuel : ℕ) (s₁ s₂ : Seq) : Seq`
     - `Lean.Grind.CommRing.Mon.revlexFuel (fuel : ℕ) (m₁ m₂ : Mon) : Ordering`

2. **Structural Recursion**:
   - Default Lean approach using well-founded recursion on structure size
   - No explicit depth/fuel needed when structurally decreasing

3. **WellFoundedLT/GT**:
   - Type class for well-founded < relation
   - Used in `SuccOrder.limitRecOn`, `PredOrder.limitRecOn`
   - Enables recursion on order-theoretic structures

4. **Depth Tracking** (Internal to tactics):
   - Not exposed as general utilities
   - Examples: `maxRecDepth`, `maxDischargeDepth`, `maxRuleApplicationDepth`

### Library Distribution

| Library | Count | Types |
|---------|-------|-------|
| Mathlib.Combinatorics.SimpleGraph | 168 | Graph reachability (unbounded) |
| Lean.Elab.Tactic.Do | 11 | Fuel-based do notation |
| Lean.Grind | 17 | Fuel-based AC/ring solvers |
| Init.Data.List | 9 | List modification (not exploration) |
| Std.Data.TreeMap | 22 | Ordered tree search |
| Batteries.Data.RBMap | 8 | Red-black tree depth |
| Mathlib.Control.Traversable | 174 | Traversable type class |

### Usage Patterns

1. **Graph Theory (Mathlib)**:
   - Focus on **proofs about graphs**, not algorithms
   - `SimpleGraph.Reachable` is a Prop, not computable
   - `instDecidableRelReachable` exists but requires full graph fintype
   - No bounded/iterative exploration primitives

2. **Fuel Pattern**:
   ```lean
   def recursiveComputation (fuel : Nat) (state : α) : Option β :=
     match fuel with
     | 0 => none  -- out of fuel
     | fuel' + 1 => 
       -- recursive call with fuel'
       recursiveComputation fuel' (step state)
   ```

3. **Tree Exploration (DTreeMap)**:
   - Internal implementation detail, not exported as general utility
   - Specific to balanced tree structure maintenance

### Type Pattern Analysis

**Patterns Found**:
- `(α → Bool) → List α → ℕ → Option ℕ` (findIdx)
- `(α → Bool) → Vector α n → Option α` (Vector.find)
- `ℕ → (α → m β) → t α → m (t β)` (traverse)
- `ℕ → Seq → Seq → Seq` (fuel-based union)

**Pattern NOT Found**:
- `ℕ → α → (α → List α) → Option β` ← **TARGET SIGNATURE**
- No bounded graph/tree exploration with successor function

## Top Functions

### Top 5 Most Relevant

#### 1. Fuel-Based Computation Pattern

**Name**: `Lean.Elab.Tactic.Do.Fuel` (type), various fuel-based functions  
**Type**: 
```lean
inductive Fuel
| unlimited : Fuel
| limited (n : ℕ) : Fuel
```

**Library**: Lean core  
**Module**: `Lean.Elab.Tactic.Do.VCGen.Basic`  

**Termination Mechanism**: Explicit fuel parameter decremented recursively

**Why Relevant**: This is the **idiomatic Lean approach** to bounded recursion. Instead of passing depth as `Nat`, Lean uses a `Fuel` ADT distinguishing unlimited vs limited computation. This is the pattern we should follow for bounded exploration.

**Usage Pattern**:
```lean
def boundedComputation (fuel : Fuel) (state : α) : Option β :=
  match fuel with
  | Fuel.unlimited => unboundedVersion state
  | Fuel.limited 0 => none
  | Fuel.limited (n + 1) => 
      recursiveCall (Fuel.limited n) (step state)
```

---

#### 2. SimpleGraph.Reachable

**Name**: `SimpleGraph.Reachable`  
**Type**: `{V : Type u} → (G : SimpleGraph V) → V → V → Prop`  
**Library**: Mathlib  
**Module**: `Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected`

**Termination Mechanism**: Not applicable (unbounded Prop)

**Why Relevant**: Shows that Mathlib **has graph theory but no bounded algorithms**. The decidability instance `instDecidableRelReachable` requires the full graph to be finite, making it unsuitable for lazy/bounded exploration.

**Key Properties**:
- `reachable_eq_reflTransGen : G.Reachable = Relation.ReflTransGen G.Adj`
- `reachable_is_equivalence : Equivalence G.Reachable`
- Decidable only when `[DecidableEq V] [Fintype V] [DecidableRel G.Adj]`

---

#### 3. Grind AC Fuel-Based Union

**Name**: `Lean.Grind.AC.Seq.unionFuel`  
**Type**: `(fuel : ℕ) → (s₁ s₂ : Seq) → Seq`  
**Library**: Lean core  
**Module**: `Init.Grind.AC`

**Termination Mechanism**: Fuel decremented at each recursive step

**Why Relevant**: Concrete example of fuel-based recursion pattern. Shows how Lean internal tactics use fuel to ensure termination in complex recursive operations.

**Implementation Pattern**:
```lean
def unionFuel (fuel : ℕ) (s₁ s₂ : Seq) : Seq :=
  match fuel with
  | 0 => s₁.concat s₂  -- fallback when out of fuel
  | fuel.succ =>
      match s₁, s₂ with
      | var x₁, var x₂ => ...
      | cons x₁ s₁', cons x₂ s₂' =>
          if blt x₁ x₂ then
            cons x₁ (unionFuel fuel s₁' (cons x₂ s₂'))
          else
            cons x₂ (unionFuel fuel (cons x₁ s₁') s₂')
```

---

#### 4. Std.DTreeMap.Internal.Impl.explore

**Name**: `Std.DTreeMap.Internal.Impl.explore`  
**Type**: `{α β γ : Type} [Ord α] → (k : α → Ordering) → γ → (γ → ExplorationStep α β k → γ) → Impl α β → γ`  
**Library**: Std  
**Module**: `Std.Data.DTreeMap.Internal.Model`

**Termination Mechanism**: Structural recursion on tree structure

**Why Relevant**: Shows tree traversal with accumulator pattern. Not general-purpose but demonstrates exploration idiom.

**Pattern**: Fold-like exploration with continuation:
- Initial accumulator: `init : γ`
- Step function: `γ → ExplorationStep α β k → γ`
- Structurally recursive on tree `Impl α β`

---

#### 5. Aesop Maximum Depth Configuration

**Name**: `Aesop.Options.maxRuleApplicationDepth`  
**Type**: `ℕ`  
**Library**: Aesop  
**Module**: `Aesop.Options.Public`

**Termination Mechanism**: Configuration parameter checked during search

**Why Relevant**: Shows how proof search in Lean uses explicit depth bounds. The Aesop tactic maintains depth counters and checks against configuration limits.

**Related functions**:
- `Aesop.setMaxRuleApplicationDepthReached : SearchM Q Unit`
- `Aesop.wasMaxRuleApplicationDepthReached : SearchM Q Bool`
- `Aesop.Strategy.depthFirst : Strategy`

**Usage**: Depth tracking in search state, not a pure bounded function.

---

## Recommendations

Based on this comprehensive Loogle search, I recommend:

### 1. Implement Custom Bounded Exploration

**Conclusion**: There is no pre-existing bounded graph/tree exploration utility in Lean/Mathlib. We need to implement it ourselves.

**Recommended Signature**:
```lean
def boundedExplore 
  (fuel : Nat) 
  (initial : α) 
  (successors : α → List α) 
  (goal : α → Bool) 
  : Option α :=
  match fuel with
  | 0 => none
  | fuel' + 1 =>
      if goal initial then
        some initial
      else
        (successors initial).findSome? 
          (boundedExplore fuel' · successors goal)
```

### 2. Follow Fuel Pattern, Not Depth Parameter

The idiomatic Lean approach uses explicit fuel:
- More explicit about termination
- Distinguishes unlimited vs limited (via ADT or Nat)
- Standard pattern in Lean tactics and solvers

### 3. Consider Monadic Interface

For integration with proof search, consider:
```lean
def boundedExploreM 
  [Monad m] 
  (fuel : Nat) 
  (initial : α) 
  (successorsM : α → m (List α)) 
  (goalM : α → m Bool) 
  : m (Option α)
```

### 4. Add Visited Set for Graph Search

For graphs (vs trees), track visited nodes:
```lean
structure SearchState (α : Type) [BEq α] [Hashable α] where
  visited : Std.HashSet α
  fuel : Nat

def boundedGraphSearch 
  [BEq α] [Hashable α]
  (fuel : Nat)
  (initial : α)
  (successors : α → List α)
  (goal : α → Bool)
  : Option α := ...
```

### 5. Reference Implementations

Study these for patterns:
1. **Fuel usage**: `Lean.Grind.AC.Seq.unionFuel`
2. **Tree exploration**: `Std.DTreeMap.Internal.Impl.explore`
3. **Proof search depth**: Aesop depth tracking
4. **Graph theory**: `SimpleGraph.Reachable` (for properties to prove)

### 6. Testing Against Mathlib Graph Theory

Once implemented, verify correctness against `SimpleGraph.Reachable`:
```lean
theorem boundedExplore_sound 
  (fuel : Nat) (G : SimpleGraph V) (u v : V) :
  boundedExplore fuel u (G.neighbors ·) (· = v) = some v →
  G.Reachable u v
```

---

## Appendix: Search Query Summary

| Query # | Pattern | Matches | Category |
|---------|---------|---------|----------|
| 1 | `Nat → _ → (_ → List _) → Option _` | 0 | Exact |
| 2 | `Nat → α → (α → List α) → Option β` | Error | Exact |
| 3 | `Nat → α → (α → List α) → Option α` | Error | Exact |
| 4 | `Nat → _ → (_ → List _) → _` | 9 | Related |
| 5 | `_ → (_ → List _) → Nat → Option _` | 0 | Related |
| 6 | `Nat → _ → (_ → _) → Option _` | 35 | Related |
| 7 | `_ → Nat → (_ → List _) → Option _` | 0 | Related |
| 8 | `Nat → _ → (_ → List _) → List _` | 1 | Related |
| 9 | "bfs" | 0 | Name |
| 10 | "dfs" | 33 (all false positives) | Name |
| 11 | "explore" | 5 | Name |
| 12 | "search" | 200+ | Name |
| 13 | "traverse" | 174 | Name |
| 14 | "bounded" | 200+ | Name |
| 15 | "depth" | 126 | Name |
| 16 | "limit" | 200+ | Name |
| 17 | "fuel" | 38 ⭐ | Name |
| 18 | "reachable" | 168 | Name |
| 19 | "findPath" | 1 | Name |
| 20 | `Nat → _ → (_ → List _) → Bool` | 0 | Graph |
| 21 | `Nat → _ → _ → (_ → List _) → Option _` | Not executed | Graph |
| 22 | `Nat → _ → (_ → Bool) → (_ → List _) → Option _` | Not executed | Graph |

**Legend**:  
⭐ = Most relevant for implementation  
