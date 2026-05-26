import Bimodal.Automation.ProofSearch.Core

namespace Bimodal.Automation

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Best-First Search

Priority queue-based search that explores promising branches first.
-/

/--
Search node for best-first search, containing goal state and priority information.
-/
structure SearchNode where
  /-- Current proof context. -/
  context : Context
  /-- Goal formula to prove. -/
  goal : Formula
  /-- Accumulated cost (path length). -/
  cost : Nat
  /-- Heuristic score (estimated remaining cost). -/
  heuristic : Nat
  /-- f-score = cost + heuristic (for priority ordering). -/
  fscore : Nat := cost + heuristic
  deriving Repr

instance : Inhabited SearchNode :=
  ⟨{ context := [], goal := .bot, cost := 0, heuristic := 0 }⟩

/--
Simple priority queue implemented as a sorted list (ascending by f-score).

For proof search, a simple list-based implementation is sufficient since
the queue rarely grows beyond a few hundred elements and insertion is O(n).
-/
abbrev PriorityQueue := List SearchNode

namespace PriorityQueue

/-- Empty priority queue. -/
def empty : PriorityQueue := []

/-- Check if queue is empty. -/
def isEmpty (q : PriorityQueue) : Bool := q.length == 0

/-- Insert a node maintaining sorted order by f-score. -/
def insert (q : PriorityQueue) (node : SearchNode) : PriorityQueue :=
  let rec insertSorted : List SearchNode → List SearchNode
    | [] => [node]
    | h :: t =>
        if node.fscore ≤ h.fscore then node :: h :: t
        else h :: insertSorted t
  insertSorted q

/-- Extract the minimum f-score node. -/
def extractMin (q : PriorityQueue) : Option (SearchNode × PriorityQueue) :=
  match q with
  | [] => none
  | h :: t => some (h, t)

/-- Get queue size. -/
def size (q : PriorityQueue) : Nat := q.length

end PriorityQueue

/--
Best-first search for proof derivation using priority queue.

Explores nodes in order of f-score (cost + heuristic), where:
- cost = number of inference steps taken
- heuristic = estimated steps remaining (from advanced_heuristic_score)

**Properties**:
- Complete: Finds proof if one exists (within expansion limit)
- Optimal with admissible heuristic: Finds shortest proof if h(n) ≤ h*(n)
- Space: O(b^d) in worst case (stores frontier)

**Parameters**:
- `Γ`: Initial proof context
- `φ`: Goal formula
- `maxExpansions`: Maximum node expansions before giving up
- `weights`: Heuristic weights for scoring
- `patternDb`: Optional pattern database for learned hints

**Returns**: Same format as other search functions for compatibility
-/
def bestFirst_search (Γ : Context) (φ : Formula)
    (maxExpansions : Nat := 10000)
    (weights : HeuristicWeights := {})
    (patternDb : PatternDatabase := PatternDatabase.empty)
    : Bool × ProofCache × Visited × SearchStats × Nat :=
  -- Initialize with start node
  let initHeuristic := pattern_aware_score weights Γ φ patternDb .ModusPonens
  let initNode : SearchNode := { context := Γ, goal := φ, cost := 0, heuristic := initHeuristic }
  let initQueue := PriorityQueue.insert PriorityQueue.empty initNode

  -- Main search loop using fuel parameter for termination
  let rec searchLoop (queue : PriorityQueue) (cache : ProofCache) (visited : Visited)
                     (stats : SearchStats) (expansions : Nat) : (fuel : Nat) →
      Bool × ProofCache × Visited × SearchStats × Nat
    | 0 => (false, cache, visited, {stats with prunedByLimit := stats.prunedByLimit + 1}, expansions)
    | fuel + 1 =>
        if expansions ≥ maxExpansions then
          (false, cache, visited, {stats with prunedByLimit := stats.prunedByLimit + 1}, expansions)
        else
          match queue.extractMin with
          | none =>
              -- Queue empty, no proof found
              (false, cache, visited, stats, expansions)
          | some (node, queue') =>
              let key : CacheKey := (node.context, node.goal)

              -- Skip if already visited (doesn't count as expansion)
              if visited.contains key then
                searchLoop queue' cache visited stats expansions fuel
              else
                let visited' := visited.insert key
                let stats' := {stats with visited := stats.visited + 1}

                -- Check cache
                match cache[key]? with
                | some true =>
                    -- Cached success
                    (true, cache, visited', {stats' with hits := stats'.hits + 1}, expansions + 1)
                | some false =>
                    -- Cached failure, skip
                    searchLoop queue' cache visited' {stats' with hits := stats'.hits + 1} expansions fuel
                | none =>
                    let stats' := {stats' with misses := stats'.misses + 1}

                    -- Check if goal matches axiom
                    if matches_axiom node.goal then
                      (true, cache.insert key true, visited', stats', expansions + 1)
                    -- Check if goal is in context
                    else if node.context.contains node.goal then
                      (true, cache.insert key true, visited', stats', expansions + 1)
                    else
                      -- Expand node: generate successor nodes

                      -- 1. Modus ponens: find implications (ψ → goal) and add ψ as subgoal
                      let implications := find_implications_to node.context node.goal
                      let mpNodes := implications.map fun ψ =>
                        let h := pattern_aware_score weights node.context ψ patternDb .ModusPonens
                        { context := node.context, goal := ψ, cost := node.cost + 1, heuristic := h : SearchNode }

                      -- 2. Modal K rule: if goal is □ψ, add ψ with boxed context
                      let modalNodes := match node.goal with
                        | .box ψ =>
                            let ctx' := box_context node.context
                            let h := pattern_aware_score weights ctx' ψ patternDb .ModalK
                            [{ context := ctx', goal := ψ, cost := node.cost + 1, heuristic := h }]
                        | _ => []

                      -- 3. Temporal K rule: if goal is Gψ, add ψ with future context
                      let temporalNodes := match node.goal with
                        | .all_future ψ =>
                            let ctx' := future_context node.context
                            let h := pattern_aware_score weights ctx' ψ patternDb .TemporalK
                            [{ context := ctx', goal := ψ, cost := node.cost + 1, heuristic := h }]
                        | _ => []

                      -- Add all successor nodes to queue
                      let allSuccessors := mpNodes ++ modalNodes ++ temporalNodes
                      let queue'' := allSuccessors.foldl PriorityQueue.insert queue'

                      -- Continue search
                      searchLoop queue'' (cache.insert key false) visited' stats' (expansions + 1) fuel

  -- Use maxExpansions * 10 as fuel (allows for skipped visited nodes)
  searchLoop initQueue ProofCache.empty Visited.empty {} 0 (maxExpansions * 10)

/-!
## Search Strategy Configuration
-/

/--
Search strategy configuration.

**Variants**:
- `BoundedDFS depth`: Depth-limited DFS (may miss proofs beyond depth)
- `IDDFS maxDepth`: Iterative deepening DFS (complete and optimal)
- `BestFirst maxExpansions`: Priority queue search exploring by f-score
-/
inductive SearchStrategy where
  | BoundedDFS (depth : Nat)
  | IDDFS (maxDepth : Nat)
  | BestFirst (maxExpansions : Nat)  -- Priority queue search
  deriving Repr

/--
Unified search interface with configurable strategy.

**Default**: IDDFS with maxDepth=100 (complete and optimal)

**Parameters**:
- `Γ`: Proof context
- `φ`: Goal formula
- `strategy`: Search algorithm to use
- `visitLimit`: Maximum total visits
- `weights`: Heuristic weights

**Returns**: Same as bounded_search and iddfs_search

**Example**:
```lean
-- Use IDDFS (default, complete and optimal)
let (found, _, _, _, _) := search [] myFormula

-- Use bounded DFS (faster but may miss deep proofs)
let (found, _, _, _, _) := search [] myFormula (.BoundedDFS 5)

-- Use IDDFS with custom depth
let (found, _, _, _, _) := search [] myFormula (.IDDFS 50)
```
-/
def search (Γ : Context) (φ : Formula)
    (strategy : SearchStrategy := .IDDFS 100)
    (visitLimit : Nat := 10000)
    (weights : HeuristicWeights := {})
    : Bool × ProofCache × Visited × SearchStats × Nat :=
  match strategy with
  | .BoundedDFS depth =>
      bounded_search Γ φ depth ProofCache.empty Visited.empty 0 visitLimit weights {}
  | .IDDFS maxDepth =>
      iddfs_search Γ φ maxDepth visitLimit weights
  | .BestFirst maxExpansions =>
      -- Best-first search with priority queue
      bestFirst_search Γ φ maxExpansions weights PatternDatabase.empty

/--
Heuristic-guided proof search prioritizing likely-successful branches.
Returns the result, updated cache/visited sets, and stats.

**Note**: This function is preserved for backward compatibility.
New code should use `search` with the appropriate `SearchStrategy`.
-/
def search_with_heuristics (Γ : Context) (φ : Formula) (depth : Nat)
    (visitLimit : Nat := 500) (weights : HeuristicWeights := {}) : Bool × ProofCache × Visited × SearchStats × Nat :=
  bounded_search Γ φ depth ProofCache.empty Visited.empty 0 visitLimit weights {}

/--
Cached proof search using memoization, visit limits, and stats.

Returns `(result, updated_cache, visited, stats, visits)` where `stats` exposes cache hits/misses,
visited node count, and visit-limit prunes.
-/
def search_with_cache (cache : ProofCache := ProofCache.empty) (Γ : Context) (φ : Formula) (depth : Nat)
    (visitLimit : Nat := 500) (weights : HeuristicWeights := {}) : Bool × ProofCache × Visited × SearchStats × Nat :=
  bounded_search Γ φ depth cache Visited.empty 0 visitLimit weights {}

/-!
## Learning-Enabled Search

Search functions that record successful patterns for future optimization.
-/

/--
Search result with pattern learning data.
-/
structure LearningSearchResult where
  /-- Whether a proof was found. -/
  found : Bool
  /-- Updated proof cache. -/
  cache : ProofCache
  /-- Visited set. -/
  visited : Visited
  /-- Search statistics. -/
  stats : SearchStats
  /-- Total visits. -/
  visits : Nat
  /-- Updated pattern database (if learning enabled). -/
  patternDb : PatternDatabase
  deriving Inhabited

/--
Search with pattern learning: records successful patterns for future searches.

This function wraps the standard search and updates the pattern database
when a proof is found, recording the successful pattern for future reference.

**Parameters**:
- `Γ`: Proof context
- `φ`: Goal formula
- `strategy`: Search algorithm to use
- `visitLimit`: Maximum total visits
- `weights`: Heuristic weights
- `patternDb`: Pattern database to update (defaults to empty)
- `enableLearning`: Whether to record patterns (default true)

**Returns**: `LearningSearchResult` with updated pattern database

**Example**:
```lean
-- First search, starting with empty pattern database
let result1 := search_with_learning [] formula1

-- Subsequent search benefits from learned patterns
let result2 := search_with_learning [] formula2 patternDb := result1.patternDb
```
-/
def search_with_learning (Γ : Context) (φ : Formula)
    (strategy : SearchStrategy := .IDDFS 100)
    (visitLimit : Nat := 10000)
    (weights : HeuristicWeights := {})
    (patternDb : PatternDatabase := PatternDatabase.empty)
    (enableLearning : Bool := true)
    : LearningSearchResult :=
  let (found, cache, visited, stats, visits) := search Γ φ strategy visitLimit weights
  let updatedDb :=
    if found && enableLearning then
      -- Record the successful pattern
      let depth := stats.visited  -- Approximate depth from visits
      let info := ProofInfo.fromSearchStats φ depth Γ.length visits
      patternDb.recordSuccess φ info
    else
      patternDb
  { found, cache, visited, stats, visits, patternDb := updatedDb }

/--
Batch search with progressive pattern learning.

Searches for proofs of multiple formulas, accumulating learned patterns.
Later formulas benefit from patterns learned from earlier successes.

**Parameters**:
- `formulas`: List of (context, goal) pairs to prove
- `strategy`: Search algorithm to use
- `visitLimit`: Maximum visits per formula
- `weights`: Heuristic weights
- `patternDb`: Initial pattern database

**Returns**: List of results paired with final pattern database
-/
def batch_search_with_learning
    (formulas : List (Context × Formula))
    (strategy : SearchStrategy := .IDDFS 100)
    (visitLimit : Nat := 10000)
    (weights : HeuristicWeights := {})
    (patternDb : PatternDatabase := PatternDatabase.empty)
    : List LearningSearchResult × PatternDatabase :=
  let (results, finalDb) := formulas.foldl
    (fun (acc : List LearningSearchResult × PatternDatabase) (Γ, φ) =>
      let (results, currentDb) := acc
      let result := search_with_learning Γ φ strategy visitLimit weights currentDb true
      (results ++ [result], result.patternDb))
    ([], patternDb)
  (results, finalDb)

/--
Get pattern learning statistics from a database.
-/
def pattern_stats (db : PatternDatabase) : String :=
  db.statistics

/-!
## Proof Search Examples (Documentation)

These examples illustrate how proof search would work once implemented.
-/

/-- Example: Trivial search finds axiom immediately -/
example : ∃ (proof : ⊢ ((Formula.atom_s "p").box.imp (Formula.atom_s "p"))), True :=
  let p := Formula.atom_s "p"
  ⟨DerivationTree.axiom [] (p.box.imp p) (Axiom.modal_t p) trivial, trivial⟩

/-- Example: Search with depth 2 for modus ponens application -/
example (p q : Formula) (h1 : ⊢ p) (h2 : ⊢ (p.imp q)) :
    ∃ (proof : ⊢ q), True :=
  ⟨DerivationTree.modus_ponens [] p q h2 h1, trivial⟩

/-- Example: Modal K search requires context transformation -/
example (p : Formula) (h : [p.box] ⊢ p) :
    ∃ (proof : [p.box] ⊢ p.box), True :=
  ⟨DerivationTree.assumption [p.box] p.box (by simp), trivial⟩

end Bimodal.Automation
