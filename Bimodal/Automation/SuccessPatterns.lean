import Std.Data.HashMap
import Bimodal.Syntax

/-!
# Success Pattern Learning for Proof Search

This module implements pattern learning for proof search optimization.
Successful proof patterns are recorded and used to guide future searches
by boosting heuristics for strategies that have worked on similar formulas.

## Overview

The pattern learning system records:
- Formula structural patterns (based on modal depth, temporal depth, etc.)
- Which proof strategies succeeded (axiom type, search depth required)
- Context characteristics

This information is used to prioritize proof strategies when searching
for proofs of similar formulas.

## Pattern Matching Strategy

Patterns are matched based on:
1. **Formula structure**: Modal depth, temporal depth, implication count
2. **Goal type**: Top-level operator category
3. **Context size**: Number of assumptions

## Usage

```lean
-- Create empty pattern database
let db := PatternDatabase.empty

-- After successful proof, record pattern
let db' := db.recordSuccess goal proofInfo

-- Query for hints on new goal
let hints := db'.queryPatterns newGoal context
```

## References

- "Learning to Prove Theorems via Interacting with Proof Assistants" (Yang et al., 2019)
- "Reinforcement Learning for Theorem Proving" (Kaliszyk et al., 2018)
-/

namespace Bimodal.Automation

open Bimodal.Syntax

/-!
## Goal Category Types
-/

/--
Category of goal formula for pattern matching.
Based on the top-level operator of a formula.
-/
inductive GoalCategory where
  | Atom        -- Propositional variable
  | Bottom      -- ⊥
  | Implication -- φ → ψ
  | Box         -- □φ
  | AllPast     -- Hφ (all_past)
  | AllFuture   -- Gφ (all_future)
  deriving BEq, Hashable, Repr, DecidableEq

instance : Inhabited GoalCategory := ⟨.Atom⟩

/--
Extract the top-level operator category from a formula.
Only considers primitive constructors (not derived operators).
-/
def goalCategory (φ : Formula) : GoalCategory :=
  match φ with
  | .atom _ => .Atom
  | .bot => .Bottom
  | .imp _ _ => .Implication
  | .box _ => .Box
  | .all_past _ => .AllPast
  | .all_future _ => .AllFuture

/-!
## Pattern Key Types

Keys for indexing patterns based on formula structure.
-/

/--
Formula pattern key for indexing success patterns.
Uses structural properties rather than exact formula matching for generalization.
-/
structure PatternKey where
  /-- Modal nesting depth (0 = no modal operators). -/
  modalDepth : Nat
  /-- Temporal nesting depth (0 = no temporal operators). -/
  temporalDepth : Nat
  /-- Number of implication operators. -/
  impCount : Nat
  /-- Formula complexity (total connective count). -/
  complexity : Nat
  /-- Top-level operator category. -/
  topOperator : GoalCategory
  deriving BEq, Hashable, Repr

instance : Inhabited PatternKey :=
  ⟨{ modalDepth := 0, temporalDepth := 0, impCount := 0, complexity := 1, topOperator := .Atom }⟩

/--
Create a pattern key from a formula.
This extracts structural features for pattern matching.
-/
def PatternKey.fromFormula (φ : Formula) : PatternKey :=
  { modalDepth := φ.modalDepth
  , temporalDepth := φ.temporalDepth
  , impCount := φ.countImplications
  , complexity := φ.complexity
  , topOperator := goalCategory φ
  }

/-!
## Success Pattern Types
-/

/--
Proof strategy that led to success.
-/
inductive ProofStrategy where
  | Axiom (name : String)     -- Direct axiom match
  | Assumption                 -- Found in context
  | ModusPonens               -- Applied modus ponens
  | ModalK                    -- Applied modal K rule
  | TemporalK                 -- Applied temporal K rule
  deriving Repr, DecidableEq

instance : BEq ProofStrategy where
  beq s1 s2 := match s1, s2 with
    | .Axiom n1, .Axiom n2 => n1 == n2
    | .Assumption, .Assumption => true
    | .ModusPonens, .ModusPonens => true
    | .ModalK, .ModalK => true
    | .TemporalK, .TemporalK => true
    | _, _ => false

instance : Hashable ProofStrategy where
  hash s := match s with
    | .Axiom n => hash ("axiom", n)
    | .Assumption => hash "assumption"
    | .ModusPonens => hash "mp"
    | .ModalK => hash "modalK"
    | .TemporalK => hash "temporalK"

instance : Inhabited ProofStrategy := ⟨.Assumption⟩

/--
Information about a successful proof.
-/
structure ProofInfo where
  /-- Primary strategy that closed the goal. -/
  strategy : ProofStrategy
  /-- Search depth at which proof was found. -/
  depth : Nat
  /-- Context size when proof was found. -/
  contextSize : Nat
  /-- Total nodes visited during search. -/
  nodesVisited : Nat := 0
  deriving Repr

instance : BEq ProofInfo where
  beq i1 i2 := i1.strategy == i2.strategy && i1.depth == i2.depth &&
               i1.contextSize == i2.contextSize

instance : Inhabited ProofInfo := ⟨{ strategy := .Assumption, depth := 0, contextSize := 0 }⟩

/--
Aggregated success data for a pattern.
-/
structure SuccessData where
  /-- Total successful proofs with this pattern. -/
  successCount : Nat := 0
  /-- Successful strategies and their counts. -/
  strategyCounts : List (ProofStrategy × Nat) := []
  /-- Average depth at which proofs were found. -/
  avgDepth : Nat := 0
  /-- Sum of depths (for computing average). -/
  totalDepth : Nat := 0
  /-- Most recent successful proof info. -/
  lastSuccess : Option ProofInfo := none
  deriving Repr

instance : Inhabited SuccessData := ⟨{}⟩

namespace SuccessData

/-- Empty success data. -/
def empty : SuccessData := {}

/--
Update strategy counts helper.
-/
private def updateStrategyCounts (counts : List (ProofStrategy × Nat)) (s : ProofStrategy)
    : List (ProofStrategy × Nat) :=
  if counts.any (fun (s', _) => s' == s) then
    counts.map (fun (s', n) => if s' == s then (s', n + 1) else (s', n))
  else
    (s, 1) :: counts

/--
Update success data with new proof information.
-/
def update (data : SuccessData) (info : ProofInfo) : SuccessData :=
  let newCount := data.successCount + 1
  let newTotalDepth := data.totalDepth + info.depth
  let newStrategyCounts := updateStrategyCounts data.strategyCounts info.strategy
  { successCount := newCount
  , strategyCounts := newStrategyCounts
  , avgDepth := newTotalDepth / newCount
  , totalDepth := newTotalDepth
  , lastSuccess := some info
  }

/--
Get the most successful strategy for this pattern.
-/
def bestStrategy (data : SuccessData) : Option ProofStrategy :=
  let sorted := data.strategyCounts.mergeSort (fun (_, n1) (_, n2) => n1 > n2)
  sorted.head?.map (·.1)

/--
Get strategy success rate (count for strategy / total).
-/
def strategyRate (data : SuccessData) (s : ProofStrategy) : Float :=
  if data.successCount == 0 then 0.0
  else
    let count := data.strategyCounts.find? (fun (s', _) => s' == s)
      |>.map (·.2) |>.getD 0
    count.toFloat / data.successCount.toFloat

end SuccessData

/-!
## Pattern Database
-/

/--
Pattern database storing success patterns for proof search optimization.

The database maps pattern keys to success data, allowing the search
to query for strategies that have worked on similar formulas.
-/
structure PatternDatabase where
  /-- Map from pattern keys to success data. -/
  patterns : Std.HashMap PatternKey SuccessData := {}
  /-- Total patterns recorded. -/
  totalPatterns : Nat := 0
  /-- Total successful proofs recorded. -/
  totalSuccesses : Nat := 0
  deriving Repr

instance : Inhabited PatternDatabase := ⟨{}⟩

namespace PatternDatabase

/-- Empty pattern database. -/
def empty : PatternDatabase := {}

/--
Record a successful proof pattern.

**Parameters**:
- `db`: Pattern database to update
- `φ`: Goal formula that was proven
- `info`: Information about the successful proof

**Returns**: Updated pattern database
-/
def recordSuccess (db : PatternDatabase) (φ : Formula) (info : ProofInfo) : PatternDatabase :=
  let key := PatternKey.fromFormula φ
  let existingData := db.patterns.find? key |>.getD SuccessData.empty
  let newData := existingData.update info
  let isNew := db.patterns.find? key |>.isNone
  { patterns := db.patterns.insert key newData
  , totalPatterns := if isNew then db.totalPatterns + 1 else db.totalPatterns
  , totalSuccesses := db.totalSuccesses + 1
  }

/--
Query pattern database for hints on proving a formula.

**Parameters**:
- `db`: Pattern database to query
- `φ`: Goal formula to prove
- `contextSize`: Size of current proof context

**Returns**: Optional success data for similar patterns
-/
def queryPatterns (db : PatternDatabase) (φ : Formula) (_contextSize : Nat := 0)
    : Option SuccessData :=
  let key := PatternKey.fromFormula φ
  db.patterns.find? key

/--
Get the best strategy hint for a formula.

**Parameters**:
- `db`: Pattern database
- `φ`: Goal formula

**Returns**: Optional best strategy based on past successes
-/
def bestStrategyHint (db : PatternDatabase) (φ : Formula) : Option ProofStrategy :=
  db.queryPatterns φ |>.bind SuccessData.bestStrategy

/--
Get heuristic bonus based on pattern history.

Returns a negative bonus (priority boost) if the pattern has high success rate.
Used to integrate with existing heuristic scoring.

**Parameters**:
- `db`: Pattern database
- `φ`: Goal formula
- `strategy`: Strategy being considered

**Returns**: Bonus to add to heuristic score (negative = higher priority)
-/
def heuristicBonus (db : PatternDatabase) (φ : Formula) (strategy : ProofStrategy) : Int :=
  match db.queryPatterns φ with
  | none => 0  -- No history, no bonus
  | some data =>
      let rate := data.strategyRate strategy
      if rate > 0.8 then -10      -- Very successful: strong boost
      else if rate > 0.5 then -5  -- Moderately successful: medium boost
      else if rate > 0.2 then -2  -- Some success: small boost
      else 0                      -- Low success: no boost

/--
Get suggested depth limit based on pattern history.

**Parameters**:
- `db`: Pattern database
- `φ`: Goal formula

**Returns**: Suggested depth limit, or default if no history
-/
def suggestedDepth (db : PatternDatabase) (φ : Formula) (defaultDepth : Nat := 20) : Nat :=
  match db.queryPatterns φ with
  | none => defaultDepth
  | some data =>
      -- Add buffer to average depth
      let avgDepth := data.avgDepth
      if avgDepth == 0 then defaultDepth
      else min (avgDepth * 2) defaultDepth

/--
Merge two pattern databases (useful for combining learned patterns).
-/
def merge (db1 db2 : PatternDatabase) : PatternDatabase :=
  let mergedPatterns := db2.patterns.fold (init := db1.patterns) fun acc key data2 =>
    match acc.find? key with
    | none => acc.insert key data2
    | some data1 =>
        -- Combine the data (simplified: take the one with more successes)
        let combined := if data1.successCount >= data2.successCount then data1 else data2
        acc.insert key combined
  { patterns := mergedPatterns
  , totalPatterns := mergedPatterns.size
  , totalSuccesses := db1.totalSuccesses + db2.totalSuccesses
  }

/--
Get statistics about the pattern database.
-/
def statistics (db : PatternDatabase) : String :=
  let avgSuccessPerPattern :=
    if db.totalPatterns == 0 then 0
    else db.totalSuccesses / db.totalPatterns
  s!"PatternDatabase: {db.totalPatterns} patterns, {db.totalSuccesses} successes, " ++
  s!"avg {avgSuccessPerPattern} successes/pattern"

end PatternDatabase

/-!
## Pattern Learning Helpers
-/

/--
Identify the proof strategy from search result characteristics.

This is a heuristic inference when exact strategy isn't tracked.
-/
def inferStrategy (φ : Formula) (depth : Nat) (contextSize : Nat) : ProofStrategy :=
  -- If depth is 1, it was likely an axiom or assumption
  if depth ≤ 1 then
    -- Check if it could be an axiom based on structure
    match φ with
    | .imp (.box _) _ => .Axiom "modal_t"
    | .imp _ (.box (.box _)) => .Axiom "modal_4"
    | .imp (.all_future _) _ => .Axiom "temp_k"
    | _ =>
        if contextSize > 0 then .Assumption
        else .Axiom "prop"
  else
    -- Deeper search suggests MP or inference rules
    match φ with
    | .box _ => .ModalK
    | .all_future _ => .TemporalK
    | _ => .ModusPonens

/--
Create proof info from search statistics.
-/
def ProofInfo.fromSearchStats (φ : Formula) (depth : Nat) (contextSize : Nat)
    (nodesVisited : Nat := 0) : ProofInfo :=
  { strategy := inferStrategy φ depth contextSize
  , depth := depth
  , contextSize := contextSize
  , nodesVisited := nodesVisited
  }

end Bimodal.Automation
