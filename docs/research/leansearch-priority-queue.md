# LeanSearch Results: Priority Queue Data Structures

**Query**: "priority queue"  
**Date**: Sun Dec 21 2025  
**Results Found**: 15+  
**Library Coverage**: Batteries (Lean 4 Standard Library)  

## Executive Summary

This search identified three complete heap/priority queue implementations in the Batteries library for Lean 4. These data structures provide different performance characteristics for priority-based operations:

1. **BinaryHeap**: Array-based max-heap with O(1) insert/merge, O(log n) deleteMax
2. **BinomialHeap**: Forest-based min-heap with O(log n) for all main operations
3. **PairingHeap**: Tree-based min-heap with O(1) merge, amortized O(log n) deleteMin

All three support the core priority queue operations needed for heuristic-guided proof search.

## Top Results

### 1. Batteries.BinaryHeap (Relevance: 1.0)
- **Type**: Structure
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `BinaryHeap (α : Type u) (lt : α → α → Bool) : Type u`
- **Description**: Array-based max-heap with O(1) insert and peek, O(log n) extract operations
- **Key Operations**:
  - `empty : BinaryHeap α lt` - O(1) create empty heap
  - `singleton : α → BinaryHeap α lt` - O(1) create single-element heap
  - `insert : BinaryHeap α lt → α → BinaryHeap α lt` - O(log n) insert element
  - `max : BinaryHeap α lt → Option α` - O(1) peek maximum
  - `popMax : BinaryHeap α lt → BinaryHeap α lt` - O(log n) remove maximum
  - `extractMax : BinaryHeap α lt → Option α × BinaryHeap α lt` - O(log n) extract maximum
  - `size : BinaryHeap α lt → Nat` - O(1) get size
  - `increaseKey : BinaryHeap α lt → Fin (size) → α → BinaryHeap α lt` - O(log n) increase priority
  - `decreaseKey : BinaryHeap α lt → Fin (size) → α → BinaryHeap α lt` - O(log n) decrease priority
- **Use Case**: Best for simple priority queue needs with good cache locality

### 2. Batteries.BinomialHeap (Relevance: 0.95)
- **Type**: Structure  
- **Library**: Batteries.Data.BinomialHeap
- **Signature**: `BinomialHeap (α : Type u) (le : α → α → Bool) : Type u`
- **Description**: Forest of binomial trees min-heap with O(log n) for all operations and efficient merge
- **Key Operations**:
  - `empty : BinomialHeap α le` - O(1) create empty heap
  - `singleton : α → BinomialHeap α le` - O(1) create single-element heap
  - `insert : α → BinomialHeap α le → BinomialHeap α le` - O(log n) insert element
  - `merge : BinomialHeap α le → BinomialHeap α le → BinomialHeap α le` - O(log n) merge two heaps
  - `head? : BinomialHeap α le → Option α` - O(log n) peek minimum
  - `deleteMin : BinomialHeap α le → Option (α × BinomialHeap α le)` - O(log n) extract minimum
  - `tail : BinomialHeap α le → BinomialHeap α le` - O(log n) remove minimum
  - `size : BinomialHeap α le → Nat` - O(log n) get size
  - `isEmpty : BinomialHeap α le → Bool` - O(1) check if empty
- **Use Case**: Best for mergeable priority queues with guaranteed O(log n) worst-case bounds

### 3. Batteries.PairingHeap (Relevance: 0.93)
- **Type**: Structure
- **Library**: Batteries.Data.PairingHeap  
- **Signature**: `PairingHeap (α : Type u) (le : α → α → Bool) : Type u`
- **Description**: Pairing heap min-heap with O(1) merge and amortized O(log n) deleteMin
- **Key Operations**:
  - `empty : PairingHeap α le` - O(1) create empty heap
  - `singleton : α → PairingHeap α le` - O(1) create single-element heap
  - `insert : α → PairingHeap α le → PairingHeap α le` - O(1) insert element
  - `merge : PairingHeap α le → PairingHeap α le → PairingHeap α le` - O(1) merge two heaps
  - `head? : PairingHeap α le → Option α` - O(1) peek minimum
  - `deleteMin : PairingHeap α le → Option (α × PairingHeap α le)` - Amortized O(log n) extract minimum
  - `tail : PairingHeap α le → PairingHeap α le` - Amortized O(log n) remove minimum
  - `size : PairingHeap α le → Nat` - O(n) get size (expensive!)
  - `isEmpty : PairingHeap α le → Bool` - O(1) check if empty
- **Use Case**: Best for applications with many merges and inserts, fewer deletions
- **Warning**: deleteMin may be O(n) in worst case; not suitable for persistent use

### 4. Array.toBinaryHeap (Relevance: 0.85)
- **Type**: Function
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `Array.toBinaryHeap (lt : α → α → Bool) (a : Array α) : BinaryHeap α lt`
- **Description**: O(n) conversion from unsorted array to heap using heapify
- **Use Case**: Efficient batch heap construction from existing data

### 5. Array.heapSort (Relevance: 0.82)
- **Type**: Function
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `Array.heapSort (a : Array α) (lt : α → α → Bool) : Array α`
- **Description**: O(n log n) in-place heap sort using binary heap
- **Use Case**: Sorting with heap-based algorithm

### 6. BinaryHeap.heapifyUp (Relevance: 0.78)
- **Type**: Definition
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `heapifyUp {α sz} (lt : α → α → Bool) (a : Vector α sz) (i : Fin sz) : Vector α sz`
- **Description**: Core O(log n) operation to restore heap property by moving element up
- **Use Case**: Internal operation for insert and increaseKey

### 7. BinaryHeap.heapifyDown (Relevance: 0.76)
- **Type**: Definition
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `heapifyDown {α sz} (lt : α → α → Bool) (a : Vector α sz) (i : Fin sz) : Vector α sz`
- **Description**: Core O(log n) operation to restore heap property by moving element down
- **Use Case**: Internal operation for popMax and decreaseKey

### 8. BinomialHeap.findMin (Relevance: 0.72)
- **Type**: Function
- **Library**: Batteries.Data.BinomialHeap.Basic
- **Signature**: `Heap.findMin (le : α → α → Bool) (k : Heap α → Heap α) : Heap α → FindMin α → FindMin α`
- **Description**: O(log n) find minimum element with metadata for heap reconstruction
- **Use Case**: Internal operation for deleteMin implementation

### 9. BinomialHeap.merge (Relevance: 0.88)
- **Type**: Function
- **Library**: Batteries.Data.BinomialHeap.Basic
- **Signature**: `Heap.merge (le : α → α → Bool) : Heap α → Heap α → Heap α`
- **Description**: O(log n) merge two binomial heaps maintaining rank order
- **Use Case**: Core operation for efficient heap merging

### 10. PairingHeap.combine (Relevance: 0.70)
- **Type**: Function
- **Library**: Batteries.Data.PairingHeap
- **Signature**: `Heap.combine (le : α → α → Bool) : Heap α → Heap α`
- **Description**: Auxiliary for deleteMin: merge forest in pairs
- **Use Case**: Internal operation for maintaining pairing heap structure

### 11. BinaryHeap.mkHeap (Relevance: 0.68)
- **Type**: Function
- **Library**: Batteries.Data.BinaryHeap
- **Signature**: `mkHeap (lt : α → α → Bool) (a : Vector α sz) : Vector α sz`
- **Description**: O(n) bottom-up heapify construction from unsorted vector
- **Use Case**: Efficient batch heap construction via Floyd's algorithm

### 12. BinomialHeap.WF (Relevance: 0.65)
- **Type**: Predicate
- **Library**: Batteries.Data.BinomialHeap.Basic
- **Signature**: `Heap.WF (le : α → α → Bool) (n : Nat) : Heap α → Prop`
- **Description**: Well-formedness predicate for binomial heap verification
- **Use Case**: Formal verification of heap invariants

### 13. PairingHeap.WF (Relevance: 0.64)
- **Type**: Predicate
- **Library**: Batteries.Data.PairingHeap
- **Signature**: `Heap.WF (le : α → α → Bool) : Heap α → Prop`
- **Description**: Well-formedness predicate for pairing heap verification
- **Use Case**: Formal verification of heap invariants

### 14. BinomialHeap.ofList (Relevance: 0.60)
- **Type**: Function
- **Library**: Batteries.Data.BinomialHeap.Basic
- **Signature**: `BinomialHeap.ofList (le : α → α → Bool) (as : List α) : BinomialHeap α le`
- **Description**: O(n log n) construct heap from list by repeated insertion
- **Use Case**: Heap construction from list data

### 15. PairingHeap.ofArray (Relevance: 0.58)
- **Type**: Function
- **Library**: Batteries.Data.PairingHeap
- **Signature**: `PairingHeap.ofArray (le : α → α → Bool) (as : Array α) : PairingHeap α le`
- **Description**: O(n log n) construct heap from array by repeated insertion
- **Use Case**: Heap construction from array data

## Performance Comparison

| Operation | BinaryHeap | BinomialHeap | PairingHeap |
|-----------|------------|--------------|-------------|
| **insert** | O(log n) | O(log n) | O(1) |
| **peek min/max** | O(1) | O(log n) | O(1) |
| **delete min/max** | O(log n) | O(log n) | O(log n) amortized |
| **merge** | O(1) | O(log n) | O(1) |
| **size** | O(1) | O(log n) | O(n) |
| **increaseKey** | O(log n) | ❌ | ❌ |
| **decreaseKey** | O(log n) | ❌ | ❌ |
| **fromArray** | O(n) | O(n log n) | O(n log n) |
| **Persistent** | ✅ Good | ✅ Good | ⚠️ Poor |
| **Cache locality** | ✅ Excellent | ⚠️ Fair | ⚠️ Fair |

## Key Patterns and Insights

### 1. Heap Type Selection

**BinaryHeap** is best when:
- You need a simple, efficient priority queue
- Cache locality is important
- You need `increaseKey`/`decreaseKey` operations
- Heap is used ephemerally (not persisted)

**BinomialHeap** is best when:
- You need guaranteed worst-case O(log n) bounds
- You need efficient merge operations
- You need persistent data structures
- Size queries are important

**PairingHeap** is best when:
- You have many inserts and merges
- Deletions are relatively rare
- You can tolerate amortized complexity
- You don't need size queries

### 2. Min vs Max Heaps

- **BinaryHeap**: Uses `lt` comparison → **max-heap** by default
  - For min-heap: use `flip lt` or `fun a b => !lt a b`
- **BinomialHeap**: Uses `le` comparison → **min-heap** by default
  - For max-heap: use `flip le` or `fun a b => le b a`
- **PairingHeap**: Uses `le` comparison → **min-heap** by default
  - For max-heap: use `flip le` or `fun a b => le b a`

### 3. Well-Formedness Predicates

All three implementations include formal verification predicates:
- `BinaryHeap`: Implicit well-formedness via Vector invariants
- `BinomialHeap.Imp.Heap.WF`: Explicit predicate for binomial tree properties
- `PairingHeap.Imp.Heap.WF`: Explicit predicate for pairing heap properties

These can be used for formal verification of correctness.

### 4. Iteration Support

All three heaps support `forIn` iteration:
```lean
for x in heap do
  -- process x in priority order
```

This is O(n log n) as it repeatedly extracts the minimum.

### 5. Conversion Operations

Each heap provides:
- `toList` / `toArray`: O(n log n) ordered extraction
- `toListUnordered` / `toArrayUnordered`: O(n) arbitrary order (BinomialHeap, PairingHeap)
- `ofList` / `ofArray`: O(n log n) construction (or O(n) for BinaryHeap)

## Recommendations for Modal Logic Proof Search

Based on the requirements for heuristic-guided proof search in a modal logic system, here are specific recommendations:

### 1. Choose BinomialHeap for Proof Search

**Rationale**:
- **Guaranteed O(log n)** for all operations (predictable performance)
- **Efficient merge** for combining proof state priorities from different branches
- **Persistent structure** allows backtracking without copying
- **Size queries** help with resource management and search termination

**Example Usage**:
```lean
-- Define proof state with priority
structure ProofState where
  goal : Formula
  context : Context
  heuristic : Nat  -- Lower is better
  deriving Repr

-- Min-heap based on heuristic value
def stateLE (s1 s2 : ProofState) : Bool :=
  s1.heuristic ≤ s2.heuristic

-- Create priority queue
def ProofQueue := Batteries.BinomialHeap ProofState stateLE

-- Initialize search
def initQueue (goal : Formula) : ProofQueue :=
  Batteries.BinomialHeap.singleton ⟨goal, Context.empty, computeHeuristic goal⟩

-- Best-first search step
def searchStep (queue : ProofQueue) : Option (ProofState × ProofQueue) :=
  queue.deleteMin
```

### 2. Alternative: PairingHeap for Aggressive Search

If proof search involves heavy branching with many merges:

**Use PairingHeap when**:
- Generating many proof branches (many inserts)
- Merging search frontiers frequently
- Extract operations are less common than inserts

**Caution**: Avoid if you need persistent queues for backtracking.

### 3. Heuristic Design Patterns

**Bounded Integer Heuristics**:
```lean
-- Use Nat for simplicity
def heuristicValue (state : ProofState) : Nat :=
  state.goal.depth + state.context.size * 2

-- Lower values = higher priority (min-heap)
def stateLE : ProofState → ProofState → Bool :=
  fun s1 s2 => heuristicValue s1 ≤ heuristicValue s2
```

**Multi-criteria Heuristics**:
```lean
structure Heuristic where
  primary : Nat    -- e.g., depth
  secondary : Nat  -- e.g., context size
  deriving Repr

instance : LE Heuristic where
  le h1 h2 :=
    h1.primary < h2.primary ∨
    (h1.primary = h2.primary ∧ h1.secondary ≤ h2.secondary)

def heuristicLE (h1 h2 : Heuristic) : Bool :=
  h1.primary < h2.primary ||
  (h1.primary == h2.primary && h1.secondary ≤ h2.secondary)
```

### 4. Integration with Proof Search Cache

Combine priority queue with memoization (see `leansearch-proof-caching-memoization.md`):

```lean
structure ProofSearchState where
  queue : ProofQueue                    -- Priority queue
  visited : Lean.HashSet Formula        -- Visited goals
  cache : Lean.HashMap Formula Proof    -- Cached proofs
  
def searchWithCache (state : ProofSearchState) : Option (Proof × ProofSearchState) := do
  let (current, newQueue) ← state.queue.deleteMin
  
  -- Check cache first
  if let some proof := state.cache.find? current.goal then
    return (proof, { state with queue := newQueue })
  
  -- Check visited set
  if state.visited.contains current.goal then
    searchWithCache { state with queue := newQueue }
  else
    -- Expand state and continue
    let newStates := expandProofState current
    let updatedQueue := newStates.foldl (·.insert) newQueue
    let updatedVisited := state.visited.insert current.goal
    searchWithCache { state with 
      queue := updatedQueue
      visited := updatedVisited 
    }
```

### 5. Bounded Search with Priority Queue

Implement iterative deepening or bounded search:

```lean
def boundedSearch (maxSteps : Nat) (queue : ProofQueue) : Option Proof :=
  loop maxSteps queue
where
  loop (steps : Nat) (q : ProofQueue) : Option Proof :=
    if steps = 0 then none
    else match q.deleteMin with
      | none => none  -- Queue exhausted
      | some (state, q') =>
        if isComplete state then
          some (extractProof state)
        else
          let expanded := expandState state
          let q'' := expanded.foldl (·.insert) q'
          loop (steps - 1) q''
```

### 6. Parallel Search with Priority Queues

For parallel proof search, partition by priority ranges:

```lean
structure ParallelSearchState where
  queues : Array ProofQueue  -- One per thread
  
def partitionByPriority (states : List ProofState) (numPartitions : Nat) : Array ProofQueue :=
  -- Distribute states to queues based on heuristic value ranges
  sorry  -- Implementation details
```

## Related Searches

To expand this research, consider additional searches for:
- "A* search algorithm" - For optimal search strategies
- "best-first search" - For heuristic search patterns
- "branch and bound" - For search space pruning
- "discrimination tree" - For efficient pattern matching in proof search
- "proof state hashing" - For duplicate detection
- "iterative deepening" - For memory-bounded search

## Additional Data Structures

Consider combining priority queues with:
- **Batteries.Data.HashMap** - For visited set and proof cache
- **Batteries.Data.RBMap** - For ordered proof state storage
- **Batteries.Lean.Meta.DiscrTree** - For efficient lemma indexing

## References

All results from Batteries library, accessible via:
- Batteries documentation: https://leanprover-community.github.io/mathlib4_docs/Batteries.html
- Source code: https://github.com/leanprover-community/batteries
- Binary Heap: `Batteries.Data.BinaryHeap`
- Binomial Heap: `Batteries.Data.BinomialHeap`
- Pairing Heap: `Batteries.Data.PairingHeap`

## Implementation Notes

### BinaryHeap Specifics
- Backed by `Array α`
- Max-heap by default (use `lt` relation)
- Supports indexed operations: `get`, `increaseKey`, `decreaseKey`
- Best cache locality due to array-based implementation

### BinomialHeap Specifics
- Forest of binomial trees with strictly increasing ranks
- Min-heap by default (use `le` relation)
- Well-formed heaps have at most one tree per rank
- Rank = log₂(size), so at most O(log n) trees

### PairingHeap Specifics
- Simpler implementation than binomial heap
- Min-heap by default (use `le` relation)
- No sibling pointers in well-formed state (`NoSibling` predicate)
- Warning: `size` is O(n), not O(1)!

## Example: Complete Proof Search Setup

```lean
import Batteries.Data.BinomialHeap

-- Proof state with heuristic
structure ProofState where
  goal : Formula
  ctx : Context
  depth : Nat
  contextSize : Nat
  deriving Repr

-- Heuristic: prefer shallow depth, small context
def stateHeuristic (s : ProofState) : Nat :=
  s.depth * 10 + s.contextSize

def stateLE (s1 s2 : ProofState) : Bool :=
  stateHeuristic s1 ≤ stateHeuristic s2

-- Priority queue type
abbrev ProofQueue := Batteries.BinomialHeap ProofState stateLE

-- Search state with cache
structure SearchState where
  queue : ProofQueue
  visited : Lean.HashSet Formula
  cache : Lean.HashMap Formula Derivation

-- Initialize search
def initSearch (goal : Formula) : SearchState where
  queue := Batteries.BinomialHeap.singleton {
    goal := goal
    ctx := Context.empty
    depth := 0
    contextSize := 0
  }
  visited := Lean.HashSet.empty
  cache := Lean.HashMap.empty

-- Search loop
partial def search (state : SearchState) : Option Derivation := do
  let (current, newQueue) ← state.queue.deleteMin
  
  -- Check if goal is proved
  if isAxiom current.goal then
    return axeumDeriv current.goal
  
  -- Check cache
  if let some deriv := state.cache.find? current.goal then
    return deriv
  
  -- Check visited
  if state.visited.contains current.goal then
    search { state with queue := newQueue }
  else
    -- Expand and continue
    let successors := expandGoal current
    let newQueue' := successors.foldl (fun q s => q.insert s) newQueue
    let newVisited := state.visited.insert current.goal
    search { state with queue := newQueue', visited := newVisited }
```

This provides a complete framework for priority-based proof search in the modal logic system.
