# LeanSearch Results: Best-First Search

**Query**: "best first search"  
**Date**: 2025-12-21  
**Results Found**: 20 (Top 15 shown)  
**Search Method**: Semantic search via LeanSearch MCP server

## Executive Summary

The search identified **comprehensive best-first search infrastructure** in Lean 4's Mathlib, specifically in the `Mathlib.Deprecated.MLList.BestFirst` module. Despite deprecation status, this module provides production-ready best-first search with:

- **Heuristic-guided search** via `Estimator` typeclass
- **Priority queue** implementation with lazy evaluation
- **Beam search** support via queue size constraints
- **Graph search** with deduplication and depth limits
- **Lazy evaluation** using monadic lazy lists (`MLList`)

## Top Results

### 1. Core Best-First Search Functions

#### `bestFirstSearch`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Function
- **Relevance**: ⭐⭐⭐⭐⭐ (0.00089)
- **Signature**: 
  ```lean
  {m : Type → Type} → {α : Type} → [Monad m] → [Alternative m] → [LinearOrder α] → 
  (α → MLList m α) → α → optParam (Option Nat) Option.none → 
  optParam (Option Nat) Option.none → optParam Bool Bool.true → MLList m α
  ```
- **Description**: Best-first graph search with configurable bounds and deduplication. Performs a best-first traversal of an implicit graph with optional depth bounds, queue size limits, and duplicate removal. Returns a lazy list of reachable nodes ordered by priority.
- **Use Case**: High-level interface for proof search with automatic duplicate detection

#### `bestFirstSearchCore`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Function
- **Relevance**: ⭐⭐⭐⭐⭐ (0.00088)
- **Signature**: 
  ```lean
  {ω α : Type} → (prio : α → Thunk ω) → (ε : α → Type) → 
  [inst : LinearOrder ω] → [inst_1 : (a : α) → Estimator (prio a) (ε a)] → 
  [I : ∀ (a : α), WellFoundedGT (Set.range ((inst_1 a).bound (prio a))).Elem] → 
  [Ord ω] → [Ord α] → {m : Type → Type} → [Monad m] → [Alternative m] → 
  [(a : α) → Bot (ε a)] → (α → MLList m α) → α → (β : Type) → [Ord β] → 
  optParam (Option (α → β)) Option.none → optParam (Option Nat) Option.none → 
  optParam (Option Nat) Option.none → MLList m α
  ```
- **Description**: Best-first search with priority queue and beam-width constraint. Uses estimator-based priority queue to always expand the node with the currently best estimated priority. Supports optional maximum queue size for beam search.
- **Use Case**: Core implementation with full control over priority estimation and beam constraints

### 2. Priority Queue Infrastructure

#### `BestFirstQueue`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐⭐ (0.0316)
- **Signature**: 
  ```lean
  {ω α : Type} → (prio : α → Thunk ω) → (ε : α → Type) → 
  [inst : LinearOrder ω] → [(a : α) → Estimator (prio a) (ε a)] → 
  (Type → Type) → Type → [Ord ω] → [Ord α] → Option Nat → Type
  ```
- **Description**: A priority queue of lazy lists (MLList m β), where each list is associated with a node and prioritized by lower bound estimates. Implemented as a tree map from BestFirstNode to lazy lists.
- **Use Case**: Underlying priority queue for managing search frontier

#### `BestFirstNode`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Structure
- **Relevance**: ⭐⭐⭐⭐ (0.0671)
- **Signature**: 
  ```lean
  {α : Sort u_1} → {ω : Type u_2} → (α → Thunk ω) → (α → Type) → Sort (max 1 u_1)
  ```
- **Description**: A node in a best-first queue, consisting of a key α and an estimator ε for the priority of the key. The priority function maps each key to a lazily evaluated priority value, and the estimator provides progressively improving lower bounds.
- **Use Case**: Node representation with lazy priority evaluation

### 3. Queue Operations

#### `BestFirstQueue.pop`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐ (0.0575)
- **Description**: Pops an element from the lazy list with lowest priority. May involve iteratively improving priority estimates and reorganizing the queue to maintain ordering.
- **Use Case**: Extract next node to expand in search

#### `BestFirstQueue.insertAndEject`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐ (0.0571)
- **Description**: Adds a new lazy list to the best-first queue. If this takes the size above maxSize, ejects a list from the tail of the queue (lowest priority). Implements beam search constraint.
- **Use Case**: Add successors while maintaining beam width

#### `BestFirstQueue.ensureFirstIsBest`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐ (0.0126)
- **Description**: Ensures that the first element of the queue has the highest priority by iteratively improving the priority estimate of the front element or reordering the queue if a better candidate is found.
- **Use Case**: Maintain queue invariant for optimal node selection

### 4. Implementation Details

#### `impl`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐⭐ (0.00171)
- **Description**: Core implementation of bestFirstSearch that iteratively updates a priority queue of lazy lists. At each step, pops an element from the queue, computes its children lazily, and puts them back on the queue prioritized by lower bound estimates.
- **Use Case**: Internal implementation reference

#### `implMaxDepth`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐⭐ (0.00388)
- **Description**: Wrapper for impl implementing the maxDepth option. Performs best-first search with an optional maximum depth constraint to bound search depth while maintaining priority-based node expansion.
- **Use Case**: Depth-bounded search for iterative deepening

#### `BestFirstNode.estimate`
- **Library**: `Mathlib.Deprecated.MLList.BestFirst`
- **Type**: Definition
- **Relevance**: ⭐⭐⭐ (0.0178)
- **Description**: Calculates the current best lower bound estimate for the priority of a node in a best-first search queue, where the priority is computed by a function and the estimate is provided by an estimator.
- **Use Case**: Heuristic evaluation for node prioritization

### 5. Related Graph Search Components

#### `Mathlib.Tactic.Order.Graph.buildTransitiveLeProof`
- **Library**: `Mathlib.Tactic.Order.Graph`
- **Type**: Definition
- **Relevance**: ⭐⭐ (0.0974)
- **Description**: Given a ≤-graph, finds a proof of s ≤ t using transitivity. Constructs a proof by performing depth-first search on the graph to find a path and composing edge proofs.
- **Use Case**: Example of proof construction via graph search

#### `Mathlib.Tactic.Order.Graph.buildTransitiveLeProofDFS`
- **Library**: `Mathlib.Tactic.Order.Graph`
- **Type**: Definition
- **Relevance**: ⭐⭐ (0.0995)
- **Description**: DFS algorithm for constructing a proof that x ≤ y by finding a path from x to y in the ≤-graph. If a path exists, constructs a transitivity proof using edge proofs along the path.
- **Use Case**: Pattern for proof construction from search paths

#### `Mathlib.Tactic.TFAE.dfs`
- **Library**: `Mathlib.Tactic.TFAE`
- **Type**: Definition
- **Relevance**: ⭐⭐ (0.0901)
- **Description**: Uses depth-first search to find a path from proposition P to proposition P' in a TFAE (The Following Are Equivalent) graph where edges represent known implications.
- **Use Case**: Example of tactic-level proof search

#### `Mathlib.Tactic.Order.Graph.tarjanDFS`
- **Library**: `Mathlib.Tactic.Order.Graph`
- **Type**: Definition
- **Relevance**: ⭐⭐ (0.0661)
- **Description**: Depth-first search step in Tarjan's algorithm for finding strongly connected components. Performs DFS traversal updating visited status, lowlink values, and stack management.
- **Use Case**: Advanced graph algorithm for cycle detection

#### `SimpleGraph.Walk.reachable`
- **Library**: `Mathlib.Combinatorics.SimpleGraph.Connectivity.Connected`
- **Type**: Theorem
- **Relevance**: ⭐⭐ (0.1045)
- **Signature**: 
  ```lean
  ∀ {V : Type u} {G : SimpleGraph V} {u v : V} (p : G.Walk u v), G.Reachable u v
  ```
- **Description**: For any simple graph G with vertices u and v, if there exists a walk p from u to v in G, then u and v are reachable in G.
- **Use Case**: Theoretical foundation for reachability in search

## Recommendations for LOGOS Modal Logic Proof Search

### 1. Direct Integration Strategy

**Use `bestFirstSearch` as foundation**:
```lean
-- Adapt for modal logic proof search
def modalProofSearch (goal : Formula) (maxDepth : Option Nat := some 100) 
    (beamWidth : Option Nat := some 1000) : MetaM (Option Derivation) := do
  let successors : ProofState → MLList MetaM ProofState := generateSuccessors
  let results := bestFirstSearch successors (initialState goal) maxDepth beamWidth true
  -- Extract first successful proof
  results.find? (·.isProof)
```

### 2. Heuristic Design

**Implement `Estimator` typeclass for proof states**:
- **Priority metric**: Estimated distance to proof (lower = better)
- **Estimator**: Progressively improving lower bounds on proof complexity
- **Heuristics**: Formula size, modal depth, subformula count, axiom applicability

### 3. Beam Search Configuration

**Recommended parameters**:
- `maxDepth`: 100-200 (prevent infinite loops)
- `maxSize` (beam width): 1000-10000 (balance memory vs completeness)
- `dedup`: true (avoid redundant proof states)

### 4. Lazy Evaluation Benefits

**MLList advantages for proof search**:
- Generate successors on-demand (avoid computing all branches)
- Early termination when proof found
- Memory-efficient for large search spaces
- Composable with other monadic operations

### 5. Alternative: Custom Implementation

**If deprecated module is unsuitable**:
- Extract core algorithms from `BestFirst` module
- Adapt to modern Lean 4 idioms
- Integrate with `Aesop` framework
- Use `Std.Data.BinomialHeap` or `Std.Data.RBMap` for priority queue

## Technical Considerations

### Deprecation Status

The `Mathlib.Deprecated.MLList.BestFirst` module is marked as deprecated, which means:
- ⚠️ May be removed in future Mathlib versions
- ⚠️ Not actively maintained
- ✅ Still functional and well-tested
- ✅ Can be copied/adapted for project-specific use

**Recommendation**: Copy relevant code into LOGOS project with proper attribution, or contribute to Mathlib to un-deprecate and modernize the module.

### Dependencies

**Required imports**:
```lean
import Mathlib.Deprecated.MLList.BestFirst
import Mathlib.Data.MLList.Basic
import Mathlib.Order.Estimator
```

**Key typeclasses**:
- `LinearOrder ω` - Priority ordering
- `Estimator (prio a) (ε a)` - Heuristic estimation
- `Monad m` - Monadic context (typically `MetaM` for tactics)
- `Alternative m` - Failure and choice operations

### Performance Characteristics

**Time complexity**:
- Best case: O(d) where d is proof depth (if heuristic is perfect)
- Worst case: O(b^d) where b is branching factor (exhaustive search)
- With beam width k: O(k × d)

**Space complexity**:
- Without beam: O(b^d) (stores all frontier nodes)
- With beam width k: O(k) (bounded frontier)

## Integration Checklist

- [ ] Import `Mathlib.Deprecated.MLList.BestFirst` or copy source
- [ ] Define `ProofState` type with `Ord` instance
- [ ] Implement `Estimator` instance for heuristic evaluation
- [ ] Define successor generation function `ProofState → MLList MetaM ProofState`
- [ ] Configure beam width and depth limits
- [ ] Test on simple modal logic theorems
- [ ] Benchmark performance vs current proof search
- [ ] Consider contributing improvements back to Mathlib

## Related Queries

For comprehensive proof search implementation, also search for:
- "priority queue" - Alternative priority queue implementations
- "A* search" - Informed search with admissible heuristics
- "iterative deepening" - Depth-first iterative deepening strategies
- "proof search automation" - Existing proof automation frameworks
- "tactic framework" - Integration with Lean's tactic system

## References

- **LeanSearch API**: https://leansearch.net/
- **Mathlib Source**: `Mathlib.Deprecated.MLList.BestFirst`
- **Estimator Theory**: `Mathlib.Order.Estimator`
- **MLList Documentation**: `Mathlib.Data.MLList.Basic`

---

*Generated by LeanSearch Specialist on 2025-12-21*
