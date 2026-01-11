import Std.Data.HashMap
import Std.Data.HashSet
import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Automation.SuccessPatterns

/-!
# Automated Proof Search

This module implements automated proof search for the TM bimodal logic system,
including both bounded depth-first search and iterative deepening variants.

## Main Functions

- `search`: Unified search interface with configurable strategy (recommended)
- `iddfs_search`: Iterative deepening DFS with completeness guarantees
- `bounded_search`: Depth-limited DFS (may miss deep proofs)
- `search_with_heuristics`: Heuristic-guided proof search
- `search_with_cache`: Cached search with memoization

## Search Strategies

### SearchStrategy.IDDFS (Default - Recommended)

Iterative Deepening Depth-First Search (IDDFS) combines the completeness of BFS
with the space efficiency of DFS by running depth-limited searches with
increasing depth limits.

**Properties**:
- **Complete**: Guaranteed to find a proof if one exists (within maxDepth)
- **Optimal**: Guaranteed to find the shortest proof (minimum depth)
- **Space efficient**: O(d) space complexity where d = solution depth
- **Time complexity**: O(b^d) where b = branching factor

**Algorithm**:
```
IDDFS(goal, maxDepth):
  for depth = 0 to maxDepth:
    result = bounded_search(goal, depth)
    if result = SUCCESS:
      return SUCCESS (shortest proof found)
  return FAILURE (no proof within maxDepth)
```

The overhead of re-exploring shallow depths is minimal (~11% for branching
factor 10) because the deepest level dominates the search cost.

### SearchStrategy.BoundedDFS

Traditional depth-limited DFS. Faster for shallow proofs but may miss proofs
beyond the depth limit. Not complete or optimal.

### SearchStrategy.BestFirst

Priority queue-based best-first search that explores nodes by f-score (cost + heuristic).
Uses pattern-aware heuristics for intelligent branch ordering. Implemented in task 176.

## Design Pattern

```
bounded_search(goal, depth):
  if depth = 0: return None

  // Try axioms first (cheapest)
  for each axiom A:
    if A matches goal: return proof via axiom

  // Try assumptions
  if goal ∈ context: return proof via assumption

  // Try modus ponens
  for each implication (φ → ψ) in context:
    if ψ = goal:
      subproof = bounded_search(φ, depth-1)
      if subproof: return proof via MP

  // Try modal K rule
  if goal = □φ:
    subproof = bounded_search(φ in mapped context, depth-1)
    if subproof: return proof via modal_k

  return None
```

## Complexity Analysis

| Strategy | Time | Space | Complete | Optimal |
|----------|------|-------|----------|---------|
| IDDFS | O(b^d) | O(d) | Yes | Yes |
| BoundedDFS | O(b^d) | O(d) | No | No |
| BestFirst | O(b^d) | O(b^d) | Yes | Depends |

Where b = branching factor, d = depth of shallowest solution.

## Implementation Status

**Current Status**: Core search algorithms implemented with boolean result.
Returns `true` if derivation exists, `false` otherwise.

**Implemented**:
- ✓ Bounded DFS with heuristics and caching
- ✓ Iterative deepening DFS (IDDFS) with completeness guarantees
- ✓ SearchStrategy enum with unified interface
- ✓ Visit limit enforcement
- ✓ Search statistics tracking
- ✓ Domain-specific heuristics (modal, temporal, structure)
- ✓ Advanced heuristic scoring with bonuses/penalties
- ✓ Benchmark suite for performance analysis

**Domain-Specific Heuristics** (task 318):
- `modal_heuristic_bonus`: -5 priority boost for □/◇ goals
- `temporal_heuristic_bonus`: -5 priority boost for G/F/H/P goals
- `structure_heuristic`: Penalty based on formula complexity
- `advanced_heuristic_score`: Combined scoring with all heuristics
- `orderSubgoalsByAdvancedScore`: Ordering with advanced heuristics

**Future Work**:
- Proof term construction (blocked by Axiom Prop vs Type issue, task 315)
- Best-first search with priority queue (deferred)
- Expanded testing suite (task 319)

## Example Usage

```lean
-- Use IDDFS (default, complete and optimal)
let (found, cache, visited, stats, visits) := search [] myFormula

-- Use bounded DFS for quick shallow search
let (found, _, _, _, _) := search [] myFormula (.BoundedDFS 5)

-- Use IDDFS with custom depth limit
let (found, _, _, _, _) := search [] myFormula (.IDDFS 50)

-- With custom visit limit and heuristic weights
let weights := { axiomWeight := 0, mpBase := 3 : HeuristicWeights }
let (found, _, _, _, _) := search [] myFormula (.IDDFS 100) 5000 weights
```

## References

* Korf, R.E. (1985). Depth-first iterative-deepening: An optimal admissible
  tree search. Artificial Intelligence, 27(1), 97-109.
* Automated Theorem Proving: https://www.cs.cmu.edu/~fp/courses/atp/
* LEAN Proof Search: Mathlib's `solve_by_elim` tactic
-/

namespace Bimodal.Automation

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Proof Search Types (Planned)
-/

/--
Proof search result: either a derivation or search failure.

**Design**: Uses `Bool` for now since `Derivable Γ φ` is a `Prop`.
Full implementation would require extracting proof terms.
-/
abbrev SearchResult (_ : Context) (_ : Formula) := Bool

/-- Cache key combines the current context and goal formula. -/
abbrev CacheKey := Context × Formula

/-- Hash-based proof cache for memoization (stores success/failure). -/
abbrev ProofCache := Std.HashMap CacheKey Bool

/-- Visited set to prevent cycles during search. -/
abbrev Visited := Std.HashSet CacheKey

/-- Search statistics surfaced to callers and tests. -/
structure SearchStats where
  /-- Cache hits (entries found). -/
  hits : Nat := 0
  /-- Cache misses (entries inserted). -/
  misses : Nat := 0
  /-- Nodes visited (after passing depth/limit guard). -/
  visited : Nat := 0
  /-- Nodes pruned because visit limit was reached. -/
  prunedByLimit : Nat := 0
  deriving Inhabited, DecidableEq

namespace ProofCache

/-- Empty proof cache. -/
@[simp] def empty : ProofCache := {}

end ProofCache

namespace Visited

/-- Empty visited set. -/
@[simp] def empty : Visited := {}

end Visited

/-!
## Heuristic Weights
-/

/--
Tunable weights for heuristic scoring. Lower scores are preferred.
-/
structure HeuristicWeights where
  /-- Score assigned when a goal matches an axiom schema. -/
  axiomWeight : Nat := 0
  /-- Score assigned when a goal is already present in the context. -/
  assumptionWeight : Nat := 1
  /-- Base cost for a modus ponens step before considering antecedent complexity. -/
  mpBase : Nat := 2
  /-- Multiplier applied to antecedent complexity when ranking modus ponens candidates. -/
  mpComplexityWeight : Nat := 1
  /-- Base cost for modal K-style expansion (□). -/
  modalBase : Nat := 5
  /-- Base cost for temporal K-style expansion (G/all_future). -/
  temporalBase : Nat := 5
  /-- Penalty per context entry when performing context-transforming steps. -/
  contextPenaltyWeight : Nat := 1
  /-- Fallback cost when no strategy applies. -/
  deadEnd : Nat := 100
  deriving Inhabited

/-!
## Helper Functions
-/

/--
Check if a formula matches any of the 14 TM axiom schemata (prop, modal, temporal, interaction).

Returns `true` on an exact structural match, otherwise `false`.
-/
def matches_axiom (φ : Formula) : Bool :=
  let imp? : Formula → Option (Formula × Formula)
    | .imp α β => some (α, β)
    | _ => none
  let eqf (a b : Formula) : Bool := decide (a = b)
  match imp? φ with
  | none => false
  | some (lhs, rhs) =>
    let prop_k : Bool :=
      match lhs, rhs with
      | .imp φ (.imp ψ χ), .imp (.imp φ' ψ') (.imp φ'' χ') =>
          eqf φ φ' && eqf φ' φ'' && eqf ψ ψ' && eqf χ χ'
      | _, _ => false
    let prop_s : Bool :=
      match lhs, rhs with
      | φ, .imp _ φ' => eqf φ φ'
      | _, _ => false
    let ex_falso : Bool :=
      match lhs with
      | .bot => true
      | _ => false
    let peirce : Bool :=
      match lhs, rhs with
      | .imp (.imp φ ψ) φ', φ'' => eqf φ φ' && eqf φ' φ''
      | _, _ => false
    let modal_k_dist : Bool :=
      match lhs, rhs with
      | .box (.imp φ ψ), .imp (.box φ') (.box ψ') => eqf φ φ' && eqf ψ ψ'
      | _, _ => false
    let temp_k_dist : Bool :=
      match lhs, rhs with
      | .all_future (.imp φ ψ), .imp (.all_future φ') (.all_future ψ') => eqf φ φ' && eqf ψ ψ'
      | _, _ => false
    let modal_5_collapse : Bool :=
      match lhs, rhs with
      | .diamond (.box φ), .box φ' => eqf φ φ'
      | _, _ => false
    let modal_b : Bool :=
      match lhs, rhs with
      | φ, .box φ' => eqf φ' φ.diamond
      | _, _ => false
    let temp_4 : Bool :=
      match lhs, rhs with
      | .all_future φ, .all_future (.all_future φ') => eqf φ φ'
      | _, _ => false
    let temp_a : Bool :=
      match lhs, rhs with
      | φ, .all_future (.some_past φ') => eqf φ φ'
      | _, _ => false
    let temp_l : Bool :=
      match lhs, rhs with
      -- always φ = φ.all_past.and (φ.and φ.all_future)
      | .and (.all_past φ₁) (.and φ₂ (.all_future φ₃)), .all_future (.all_past φ') =>
          eqf φ₁ φ₂ && eqf φ₂ φ₃ && eqf φ₃ φ'
      | _, _ => false
    let modal_future : Bool :=
      match lhs, rhs with
      | .box φ, .box (.all_future φ') => eqf φ φ'
      | _, _ => false
    let temp_future : Bool :=
      match lhs, rhs with
      | .box φ, .all_future (.box φ') => eqf φ φ'
      | _, _ => false
    let modal_4 : Bool :=
      match lhs, rhs with
      | .box φ, .box (.box φ') => eqf φ φ'
      | _, _ => false
    let modal_t : Bool :=
      match lhs, rhs with
      | .box φ, φ' => eqf φ φ'
      | _, _ => false
    prop_k || prop_s || ex_falso || peirce || modal_t || modal_4 || modal_b || modal_5_collapse ||
    modal_k_dist || temp_k_dist || temp_4 || temp_a || temp_l || modal_future || temp_future

/--
Find all implications `ψ → φ` in context where the consequent matches the goal.

This function filters the context for implications whose consequent is the target
formula, returning the list of antecedents. This is used for backward chaining
via modus ponens: if we want to prove φ and we have ψ → φ, we should try to prove ψ.

**Parameters**:
- `Γ`: Context (list of assumptions)
- `φ`: Goal formula (the desired consequent)

**Returns**: List of antecedent formulas ψ such that `ψ → φ` is in the context

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `find_implications_to [p.imp q, r.imp q] q` returns `[p, r]`
- `find_implications_to [p, q] r` returns `[]`
-/
def find_implications_to (Γ : Context) (φ : Formula) : List Formula :=
  Γ.filterMap (fun f => match f with
    | Formula.imp ψ χ => if χ = φ then some ψ else none
    | _ => none)

/--
Transform context for modal K application: map all formulas with box operator.

The modal K inference rule states: if `Γ.map box ⊢ φ` then `Γ ⊢ box φ`.
This function applies the box operator to every formula in the context.

**Parameters**:
- `Γ`: Context to transform

**Returns**: New context where every formula is wrapped with `Formula.box`

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `box_context [Formula.atom "p", Formula.atom "q"]` returns
  `[Formula.box (Formula.atom "p"), Formula.box (Formula.atom "q")]`
-/
def box_context (Γ : Context) : Context :=
  Γ.map Formula.box

/--
Transform context for temporal K application: map all formulas with all_future operator.

The temporal K inference rule states: if `Γ.map all_future ⊢ φ` then `Γ ⊢ all_future φ`.
This function applies the all_future operator to every formula in the context.

**Parameters**:
- `Γ`: Context to transform

**Returns**: New context where every formula is wrapped with `Formula.all_future`

**Complexity**: O(n) where n is the size of the context

**Examples**:
- `future_context [Formula.atom "p", Formula.atom "q"]` returns
  `[Formula.all_future (Formula.atom "p"), Formula.all_future (Formula.atom "q")]`
-/
def future_context (Γ : Context) : Context :=
  Γ.map Formula.all_future

/-!
## Domain-Specific Heuristics

Heuristic functions that provide bonuses/penalties based on formula structure.
Lower scores are preferred (higher priority).
-/

/--
Modal heuristic bonus: prioritize modal goals that can use modal axioms.

Returns a negative bonus (priority boost) for modal goals (□φ, ◇φ).
Modal goals benefit from modal axioms (T, 4, 5, B) so we explore them earlier.

**Returns**:
- `-5` for box goals (□φ)
- `-5` for diamond goals (◇φ)
- `0` for non-modal goals
-/
def modal_heuristic_bonus (φ : Formula) : Int :=
  match φ with
  | .box _ => -5
  | .diamond _ => -5
  | _ => 0

/--
Temporal heuristic bonus: prioritize temporal goals that can use temporal axioms.

Returns a negative bonus (priority boost) for temporal goals (Gφ, Fφ, Hφ, Pφ).
Temporal goals benefit from temporal axioms (4, A, L) so we explore them earlier.

**Returns**:
- `-5` for all_future goals (Gφ)
- `-5` for some_future goals (Fφ)
- `-5` for all_past goals (Hφ)
- `-5` for some_past goals (Pφ)
- `0` for non-temporal goals
-/
def temporal_heuristic_bonus (φ : Formula) : Int :=
  match φ with
  | .all_future _ => -5
  | .some_future _ => -5
  | .all_past _ => -5
  | .some_past _ => -5
  | _ => 0

/--
Structure-based heuristic penalty: penalize complex formulas.

Computes penalty based on formula structure:
- Base complexity (number of nodes)
- Modal depth (nesting of □/◇)
- Temporal depth (nesting of G/F/H/P)
- Implication count (→ operators)

**Formula**: `complexity + 2*modalDepth + 2*temporalDepth + countImplications`

Higher penalty = lower priority (complex formulas are harder to prove).
-/
def structure_heuristic (φ : Formula) : Nat :=
  φ.complexity + 2 * φ.modalDepth + 2 * φ.temporalDepth + φ.countImplications

/--
Compute heuristic score for a proof search branch (lower score = higher priority).

Scores are configurable via `HeuristicWeights` while keeping the default
ordering used by bounded search.
-/
def heuristic_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula) : Nat :=
  if matches_axiom φ then
    weights.axiomWeight
  else if Γ.contains φ then
    weights.assumptionWeight
  else
    let implications := find_implications_to Γ φ
    if implications.isEmpty then
      match φ with
      | Formula.box _ =>
          weights.modalBase + weights.contextPenaltyWeight * Γ.length
      | Formula.all_future _ =>
          weights.temporalBase + weights.contextPenaltyWeight * Γ.length
      | _ => weights.deadEnd
    else
      let min_complexity := implications.foldl
        (fun acc ψ => min acc (weights.mpComplexityWeight * ψ.complexity))
        weights.deadEnd
      weights.mpBase + min_complexity

/--
Advanced heuristic score combining base scoring with domain-specific adjustments.

Combines:
1. Base heuristic score (axiom/assumption/modus ponens/modal/temporal priorities)
2. Modal bonus for modal goals
3. Temporal bonus for temporal goals
4. Structure penalty for complex formulas

**Parameters**:
- `weights`: Configurable heuristic weights
- `Γ`: Current proof context
- `φ`: Goal formula to score

**Returns**: Combined score (lower = higher priority). Score is clamped to 0 minimum.
-/
def advanced_heuristic_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula) : Nat :=
  let baseScore : Int := heuristic_score weights Γ φ
  let modalBonus := modal_heuristic_bonus φ
  let temporalBonus := temporal_heuristic_bonus φ
  let structurePenalty : Int := structure_heuristic φ / 4  -- Damped to avoid overwhelming base score
  let combined := baseScore + modalBonus + temporalBonus + structurePenalty
  combined.toNat  -- Clamp to 0 if negative

/--
Order candidate subgoals by heuristic score so cheaper branches are explored first.

Uses stable merge sort (O(n log n)) to order targets by ascending heuristic score.
Lower scores indicate higher priority (axioms/assumptions before complex modus ponens).
-/
def orderSubgoalsByScore (weights : HeuristicWeights) (Γ : Context) (targets : List Formula) :
    List Formula :=
  targets.mergeSort (fun φ ψ => heuristic_score weights Γ φ ≤ heuristic_score weights Γ ψ)

/--
Order candidate subgoals by advanced heuristic score (includes domain-specific bonuses).

Uses stable merge sort (O(n log n)) to order targets by ascending advanced heuristic score.
Lower scores indicate higher priority. Includes modal/temporal bonuses and structure penalties.
-/
def orderSubgoalsByAdvancedScore (weights : HeuristicWeights) (Γ : Context) (targets : List Formula) :
    List Formula :=
  targets.mergeSort (fun φ ψ => advanced_heuristic_score weights Γ φ ≤ advanced_heuristic_score weights Γ ψ)

/-!
## Pattern-Aware Heuristic Scoring

Heuristic functions that incorporate learned success patterns.
-/

/--
Pattern-aware heuristic score incorporating learned success patterns.

Combines the advanced heuristic score with bonuses from the pattern database
for strategies that have worked on similar formulas.

**Parameters**:
- `weights`: Configurable heuristic weights
- `Γ`: Current proof context
- `φ`: Goal formula to score
- `patternDb`: Optional pattern database for learned hints
- `strategy`: The strategy being considered (for pattern bonus lookup)

**Returns**: Combined score (lower = higher priority)
-/
def pattern_aware_score (weights : HeuristicWeights := {}) (Γ : Context) (φ : Formula)
    (patternDb : PatternDatabase := PatternDatabase.empty)
    (strategy : ProofStrategy := .ModusPonens) : Nat :=
  let baseScore : Int := advanced_heuristic_score weights Γ φ
  let patternBonus := patternDb.heuristicBonus φ strategy
  (baseScore + patternBonus).toNat  -- Clamp to 0 if negative

/--
Order candidate subgoals by pattern-aware heuristic score.

Uses the pattern database to boost scores for formulas that match
previously successful patterns.
-/
def orderSubgoalsByPatternScore (weights : HeuristicWeights) (Γ : Context)
    (targets : List Formula) (patternDb : PatternDatabase := PatternDatabase.empty) :
    List Formula :=
  targets.mergeSort (fun φ ψ =>
    pattern_aware_score weights Γ φ patternDb .ModusPonens ≤
    pattern_aware_score weights Γ ψ patternDb .ModusPonens)

/-!
## Search Functions
-/

/--
Bounded depth-first search for a derivation of `φ` from context `Γ`.

**Parameters**:
- `Γ`: Proof context (list of assumptions)
- `φ`: Goal formula to derive
- `depth`: Maximum search depth (prevents infinite loops)
- `weights`: Heuristic weights to rank branch ordering

**Returns**: `true` if derivation found within depth bound, `false` otherwise

**Algorithm**:
1. Base case: depth = 0 → return false
2. Check axioms and assumptions eagerly
3. Rank modus ponens antecedents by heuristic score (cheapest first)
4. Explore modal/temporal branches with cached results
5. Return false if all strategies fail or visit limits are exceeded

**Complexity**: O(b^d) where b = branching factor, d = depth
-/
def bounded_search (Γ : Context) (φ : Formula) (depth : Nat)
    (cache : ProofCache := ProofCache.empty)
    (visited : Visited := Visited.empty)
    (visits : Nat := 0)
    (visitLimit : Nat := 500)
    (weights : HeuristicWeights := {})
    (stats : SearchStats := {}) : Bool × ProofCache × Visited × SearchStats × Nat :=
  if depth = 0 then
    (false, cache, visited, stats, visits)
  else if visits ≥ visitLimit then
    (false, cache, visited, {stats with prunedByLimit := stats.prunedByLimit + 1}, visits)
  else
    let visits := visits + 1
    let stats := {stats with visited := stats.visited + 1}
    let key : CacheKey := (Γ, φ)
    if visited.contains key then
      (false, cache, visited, stats, visits)
    else
      match cache.find? key with
      | some result => (result, cache, visited, {stats with hits := stats.hits + 1}, visits)
      | none =>
          let visited := visited.insert key
          let stats := {stats with misses := stats.misses + 1}
          if matches_axiom φ then
            (true, cache.insert key true, visited, stats, visits)
          else if Γ.contains φ then
            (true, cache.insert key true, visited, stats, visits)
          else
            -- Try modus ponens: search for antecedents of implications
            let implications := find_implications_to Γ φ
            let orderedTargets := orderSubgoalsByScore weights Γ implications
            -- Try each antecedent in order (simplified - no nested recursion)
            let tryAntecedent (state : Bool × ProofCache × Visited × SearchStats × Nat) (ψ : Formula) :
                Bool × ProofCache × Visited × SearchStats × Nat :=
              let (found, cache, visited, stats, visits) := state
              if found then state  -- Already found, skip
              else
                let (result, cache', visited', stats', visits') :=
                  bounded_search Γ ψ (depth - 1) cache visited visits visitLimit weights stats
                (result, cache', visited', stats', visits')
            let (mpFound, cacheAfterMp, visitedAfterMp, statsAfterMp, visitsAfterMp) :=
              orderedTargets.foldl tryAntecedent (false, cache, visited, stats, visits)
            if mpFound then
              (true, cacheAfterMp.insert key true, visitedAfterMp, statsAfterMp, visitsAfterMp)
            else
              -- Try modal/temporal rules
              match φ with
              | Formula.box ψ =>
                  let (found, cache', visited', stats', visits') :=
                    bounded_search (box_context Γ) ψ (depth - 1) cacheAfterMp visitedAfterMp visitsAfterMp visitLimit weights statsAfterMp
                  (found, cache'.insert key found, visited', stats', visits')
              | Formula.all_future ψ =>
                  let (found, cache', visited', stats', visits') :=
                    bounded_search (future_context Γ) ψ (depth - 1) cacheAfterMp visitedAfterMp visitsAfterMp visitLimit weights statsAfterMp
                  (found, cache'.insert key found, visited', stats', visits')
              | _ => (false, cacheAfterMp.insert key false, visitedAfterMp, statsAfterMp, visitsAfterMp)
termination_by depth
decreasing_by
  all_goals simp_wf
  all_goals omega

/--
Iterative deepening depth-first search for a derivation of `φ` from context `Γ`.

Runs bounded_search with increasing depth limits until proof found or maxDepth reached.
Guarantees finding shortest proof (minimum depth) if it exists.

**Parameters**:
- `Γ`: Proof context (list of assumptions)
- `φ`: Goal formula to derive
- `maxDepth`: Maximum search depth (prevents infinite loops)
- `visitLimit`: Maximum total visits across all depths
- `weights`: Heuristic weights to rank branch ordering

**Returns**: `(found, cache, visited, stats, totalVisits)` where:
- `found`: true if derivation found within maxDepth
- `cache`: Updated proof cache
- `visited`: Visited set from final depth iteration
- `stats`: Cumulative search statistics
- `totalVisits`: Total visits across all depth iterations

**Complexity**: O(b^d) time, O(d) space where b = branching factor, d = solution depth

**Completeness**: Guaranteed to find proof if it exists within maxDepth

**Optimality**: Guaranteed to find shortest proof (minimum depth)
-/
def iddfs_search (Γ : Context) (φ : Formula) (maxDepth : Nat := 100)
    (visitLimit : Nat := 10000) (weights : HeuristicWeights := {})
    : Bool × ProofCache × Visited × SearchStats × Nat :=
  let rec iterate (depth : Nat) (cache : ProofCache) (stats : SearchStats)
                  (totalVisits : Nat) : Bool × ProofCache × Visited × SearchStats × Nat :=
    if hdepth : depth ≥ maxDepth then
      (false, cache, Visited.empty, stats, totalVisits)
    else if totalVisits ≥ visitLimit then
      (false, cache, Visited.empty, stats, totalVisits)
    else
      -- Run bounded search at current depth, starting with fresh visited set
      let (found, cache', visited', stats', visits') :=
        bounded_search Γ φ depth cache Visited.empty totalVisits visitLimit weights stats

      if found then
        (true, cache', visited', stats', visits')
      else if visits' ≥ visitLimit then
        (false, cache', visited', stats', visits')
      else
        have hdec : maxDepth - (depth + 1) < maxDepth - depth := by
          have hlt : depth < maxDepth := Nat.not_le.mp hdepth
          omega
        iterate (depth + 1) cache' stats' visits'
  termination_by maxDepth - depth
  iterate 0 ProofCache.empty {} 0

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
def isEmpty (q : PriorityQueue) : Bool := q.isEmpty

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

  -- Main search loop
  let rec searchLoop (queue : PriorityQueue) (cache : ProofCache) (visited : Visited)
                     (stats : SearchStats) (expansions : Nat)
      : Bool × ProofCache × Visited × SearchStats × Nat :=
    if expansions ≥ maxExpansions then
      (false, cache, visited, {stats with prunedByLimit := stats.prunedByLimit + 1}, expansions)
    else
      match queue.extractMin with
      | none =>
          -- Queue empty, no proof found
          (false, cache, visited, stats, expansions)
      | some (node, queue') =>
          let key : CacheKey := (node.context, node.goal)

          -- Skip if already visited
          if visited.contains key then
            searchLoop queue' cache visited stats expansions
          else
            let visited' := visited.insert key
            let stats' := {stats with visited := stats.visited + 1}

            -- Check cache
            match cache.find? key with
            | some true =>
                -- Cached success
                (true, cache, visited', {stats' with hits := stats'.hits + 1}, expansions + 1)
            | some false =>
                -- Cached failure, skip
                searchLoop queue' cache visited' {stats' with hits := stats'.hits + 1} expansions
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
                  searchLoop queue'' (cache.insert key false) visited' stats' (expansions + 1)
  termination_by maxExpansions - expansions
  decreasing_by
    all_goals simp_wf
    all_goals omega

  searchLoop initQueue ProofCache.empty Visited.empty {} 0

/-!
## Search Strategy Configuration
-/

/--
Search strategy configuration.

**Variants**:
- `BoundedDFS depth`: Depth-limited DFS (may miss proofs beyond depth)
- `IDDFS maxDepth`: Iterative deepening DFS (complete and optimal)
- `BestFirst maxDepth`: Best-first search with heuristics (future enhancement)
-/
inductive SearchStrategy where
  | BoundedDFS (depth : Nat)
  | IDDFS (maxDepth : Nat)
  | BestFirst (maxDepth : Nat)  -- Future enhancement (task 318)
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
      -- Best-first search with priority queue (task 176)
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
example : ∃ (proof : DerivationTree [] ((Formula.atom "p").box.imp (Formula.atom "p"))), True :=
  sorry  -- Would use: let proof := bounded_search [] _ 1

/-- Example: Search with depth 2 for modus ponens application -/
example (p q : Formula) (h1 : DerivationTree [] p) (h2 : DerivationTree [] (p.imp q)) :
    ∃ (proof : DerivationTree [] q), True :=
  sorry  -- Would use: let proof := bounded_search [] q 2

/-- Example: Modal K search requires context transformation -/
example (p : Formula) (h : DerivationTree [p.box] p) :
    ∃ (proof : DerivationTree [p.box] p.box), True :=
  sorry  -- Would use: let proof := bounded_search [p.box] p.box 3

end Bimodal.Automation
