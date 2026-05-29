import Bimodal.Syntax
import Bimodal.Automation.SuccessPatterns

/-!
# Formula Enumerator for Dataset Generation

This module provides bounded enumeration of TM bimodal logic formulas with
structural diversity control. It supports exhaustive enumeration at low complexity
and grammar-based random sampling at higher complexity.

## Main Definitions

- `SamplingMode`: Enum for enumeration strategy selection
- `EnumParams`: Configuration structure for formula generation
- `enumerateExhaustive`: Generate all formulas up to given complexity bounds
- `sampleRandom`: Grammar-based random formula generation
- `enrichWithDuals`: Apply `swap_temporal` for free 2x augmentation of valid formulas
- `DiversityReport`: Distribution statistics across GoalCategory and depth buckets

## Design Decisions

- **Exhaustive at complexity ≤7**: Feasible (~60K formulas), complete coverage
- **Random sampling above 7**: Avoids super-exponential blowup (2.5M at 9, 117M at 11)
- **3 atoms (p, q, r)**: Sufficient for interesting patterns without combinatorial explosion
- **Rejection criteria**: Skip pure propositional formulas (no box/untl/snce) and trivially
  small formulas (complexity < 3) to ensure dataset has meaningful modal/temporal content
- **Deduplication**: Uses `List.eraseDups` via `BEq Formula` (already derived)

## Usage

```lean
-- Enumerate formulas at complexity ≤ 5 with 2 atoms
let params : EnumParams := { maxComplexity := 5, atoms := defaultAtoms.take 2 }
let formulas := enumerateExhaustive params
-- formulas : List Formula
```

## References

- Team research report: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
-/

set_option autoImplicit false

namespace Bimodal.Automation

open Bimodal.Syntax

/--
Sampling mode for formula generation.
- `exhaustive`: Generate all formulas within bounds (complete but slow for high complexity)
- `random`: Grammar-based random generation (fast but incomplete)
- `hybrid`: Exhaustive up to a threshold, random above
-/
inductive SamplingMode where
  | exhaustive
  | random
  | hybrid
  deriving Repr, DecidableEq, BEq, Inhabited

/-- Default atoms for formula generation: p, q, r. -/
def defaultAtoms : List Atom :=
  [Atom.mk_base "p", Atom.mk_base "q", Atom.mk_base "r"]

/--
Configuration parameters for formula enumeration.

Controls complexity bounds, atom vocabulary, maximum formula count,
and sampling strategy.
-/
structure EnumParams where
  /-- Maximum structural complexity (number of connectives + 1). Default 5. -/
  maxComplexity : Nat := 5
  /-- Maximum modal operator nesting depth. Default 2. -/
  maxModalDepth : Nat := 2
  /-- Maximum temporal operator nesting depth. Default 2. -/
  maxTemporalDepth : Nat := 2
  /-- Atom vocabulary for formula generation. Default: p, q, r. -/
  atoms : List Atom := defaultAtoms
  /-- Maximum number of formulas to generate (cap for large enumerations). Default 5000. -/
  maxFormulas : Nat := 5000
  /-- Sampling strategy. Default: exhaustive. -/
  samplingMode : SamplingMode := .exhaustive
  deriving Repr, Inhabited

/--
Check whether a formula passes the rejection criteria.
Rejects:
1. Pure propositional formulas (no box, untl, or snce constructors)
2. Trivially small formulas (complexity < 3)
-/
def passesFilter (φ : Formula) : Bool :=
  φ.complexity ≥ 3 && hasModalOrTemporal φ
where
  /-- Check if a formula contains at least one modal or temporal operator. -/
  hasModalOrTemporal : Formula → Bool
    | .atom _ => false
    | .bot => false
    | .imp a b => hasModalOrTemporal a || hasModalOrTemporal b
    | .box _ => true
    | .untl _ _ => true
    | .snce _ _ => true

/--
Enumerate all formulas within the given complexity budget, respecting
modal and temporal depth bounds.

Uses bounded recursion on the complexity budget. At each step, chooses among
the 6 primitive constructors (atom, bot, imp, box, untl, snce) and distributes
the remaining budget to subformulas.

Returns a list of formulas (may contain duplicates; caller should deduplicate).
-/
def enumerateAtBudget (atoms : List Atom) (budget : Nat) (maxModal : Nat) (maxTemporal : Nat)
    : List Formula :=
  match budget with
  | 0 => []
  | 1 =>
    -- Base cases: atoms and bot (complexity 1)
    .bot :: atoms.map .atom
  | n + 1 =>
    let base := if n + 1 ≥ 1 then [Formula.bot] ++ atoms.map .atom else []
    -- Binary constructors: imp, untl, snce
    -- Distribute budget n among two children (each gets at least 1)
    let binary := ((List.range n).flatMap fun i =>
      let leftBudget := i + 1
      let rightBudget := n - i
      if rightBudget < 1 then []
      else
        let lefts := enumerateAtBudget atoms leftBudget maxModal maxTemporal
        let rights := enumerateAtBudget atoms rightBudget maxModal maxTemporal
        let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
        let untls := if maxTemporal > 0 then
          lefts.flatMap fun l => rights.map fun r => Formula.untl l r
        else []
        let snces := if maxTemporal > 0 then
          lefts.flatMap fun l => rights.map fun r => Formula.snce l r
        else []
        imps ++ untls ++ snces)
    -- Unary constructor: box (uses budget n for child)
    let boxes := if maxModal > 0 then
      (enumerateAtBudget atoms n (maxModal - 1) maxTemporal).map .box
    else []
    base ++ binary ++ boxes

/--
Enumerate all formulas exhaustively within the parameter bounds.

Generates formulas at each complexity level from 1 to `maxComplexity`,
deduplicates, filters by rejection criteria, and caps at `maxFormulas`.
-/
def enumerateExhaustive (params : EnumParams) : List Formula :=
  let allFormulas := (List.range params.maxComplexity).flatMap fun i =>
    enumerateAtBudget params.atoms (i + 1) params.maxModalDepth params.maxTemporalDepth
  let deduped := allFormulas.eraseDups
  let filtered := deduped.filter passesFilter
  filtered.take params.maxFormulas

/--
Generate a single random formula within given bounds using IO.rand.

Grammar-based generation: at each step, randomly choose a constructor
type and recursively generate subformulas with reduced budget.
-/
partial def sampleOneRandom (atoms : List Atom) (budget : Nat) (maxModal : Nat)
    (maxTemporal : Nat) : IO Formula := do
  if budget ≤ 1 then
    -- Base case: pick a random atom or bot
    let idx ← IO.rand 0 atoms.length
    match atoms[idx]? with
    | some a => return .atom a
    | none => return .bot
  else
    -- Choose constructor type: 0=atom/bot, 1=imp, 2=box, 3=untl, 4=snce
    let maxChoice := if maxModal > 0 && maxTemporal > 0 then 4
                     else if maxModal > 0 then 2
                     else if maxTemporal > 0 then 4
                     else 1
    let choice ← IO.rand 0 maxChoice
    match choice with
    | 0 =>
      -- Base: atom or bot
      let idx ← IO.rand 0 atoms.length
      match atoms[idx]? with
      | some a => return .atom a
      | none => return .bot
    | 1 =>
      -- Binary: implication
      let split ← IO.rand 1 (budget - 1)
      let left ← sampleOneRandom atoms split maxModal maxTemporal
      let right ← sampleOneRandom atoms (budget - 1 - split) maxModal maxTemporal
      return .imp left right
    | 2 =>
      -- Unary: box (if allowed)
      if maxModal > 0 then
        let child ← sampleOneRandom atoms (budget - 1) (maxModal - 1) maxTemporal
        return .box child
      else
        -- Fallback to implication
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal maxTemporal
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal maxTemporal
        return .imp left right
    | 3 =>
      -- Binary temporal: until
      if maxTemporal > 0 then
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal (maxTemporal - 1)
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal (maxTemporal - 1)
        return .untl left right
      else
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal maxTemporal
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal maxTemporal
        return .imp left right
    | _ =>
      -- Binary temporal: since
      if maxTemporal > 0 then
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal (maxTemporal - 1)
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal (maxTemporal - 1)
        return .snce left right
      else
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal maxTemporal
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal maxTemporal
        return .imp left right

/--
Generate a batch of random formulas, filtering for quality and deduplicating.

Generates `count * 3` candidates (to account for filtering losses),
applies rejection criteria, deduplicates, and returns up to `count` formulas.
-/
partial def sampleRandom (params : EnumParams) : IO (List Formula) := do
  let targetCount := params.maxFormulas
  let attempts := targetCount * 3
  let mut results : List Formula := []
  for _ in List.range attempts do
    let budget ← IO.rand 3 params.maxComplexity
    let φ ← sampleOneRandom params.atoms budget params.maxModalDepth params.maxTemporalDepth
    if passesFilter φ then
      results := φ :: results
  let deduped := results.eraseDups
  return deduped.take targetCount

/--
Enrich a formula list with temporal duals via `swap_temporal`.

For each formula in the input, adds `swap_temporal φ` if it is different
from `φ` (i.e., if the formula actually contains temporal operators).
This provides a free 2x augmentation for formulas with temporal content.

Note: Temporal duality preserves validity, so valid formulas produce valid duals.
Invalid formulas may or may not produce invalid duals.
-/
def enrichWithDuals (formulas : List Formula) : List Formula :=
  let withDuals := formulas.flatMap fun φ =>
    let dual := φ.swap_temporal
    if dual == φ then [φ] else [φ, dual]
  withDuals.eraseDups

/--
Diversity report: distribution of formulas across structural categories.
-/
structure DiversityReport where
  /-- Total formula count. -/
  totalCount : Nat
  /-- Count per GoalCategory (top-level operator). -/
  categoryCounts : List (GoalCategory × Nat)
  /-- Count per modal depth bucket (0, 1, 2, 3+). -/
  modalDepthCounts : List (Nat × Nat)
  /-- Count per temporal depth bucket (0, 1, 2, 3+). -/
  temporalDepthCounts : List (Nat × Nat)
  deriving Repr, Inhabited

/-- Increment the count for a key in an association list. -/
private def incrementCount {α : Type} [BEq α] (counts : List (α × Nat)) (key : α) : List (α × Nat) :=
  if counts.any (fun (k, _) => k == key) then
    counts.map fun (k, n) => if k == key then (k, n + 1) else (k, n)
  else
    (key, 1) :: counts

/-- Bucket a depth value: 0, 1, 2, or 3 (representing 3+). -/
private def depthBucket (d : Nat) : Nat :=
  if d ≤ 2 then d else 3

/--
Compute diversity metrics for a list of formulas.

Reports distribution across:
1. Top-level operator categories (GoalCategory)
2. Modal depth buckets (0, 1, 2, 3+)
3. Temporal depth buckets (0, 1, 2, 3+)
-/
def computeDiversity (formulas : List Formula) : DiversityReport :=
  let init : DiversityReport := {
    totalCount := formulas.length
    categoryCounts := []
    modalDepthCounts := []
    temporalDepthCounts := []
  }
  formulas.foldl (fun report φ =>
    { report with
      categoryCounts := incrementCount report.categoryCounts (goalCategory φ)
      modalDepthCounts := incrementCount report.modalDepthCounts (depthBucket φ.modalDepth)
      temporalDepthCounts := incrementCount report.temporalDepthCounts (depthBucket φ.temporalDepth)
    }
  ) init

/--
Format a diversity report as a human-readable string.
-/
def DiversityReport.display (r : DiversityReport) : String :=
  let catLines := r.categoryCounts.map fun (c, n) =>
    s!"  {repr c}: {n}"
  let modalLines := r.modalDepthCounts.map fun (d, n) =>
    let label := if d == 3 then "3+" else toString d
    s!"  modal depth {label}: {n}"
  let tempLines := r.temporalDepthCounts.map fun (d, n) =>
    let label := if d == 3 then "3+" else toString d
    s!"  temporal depth {label}: {n}"
  s!"Total formulas: {r.totalCount}\n" ++
  s!"Category distribution:\n{String.intercalate "\n" catLines}\n" ++
  s!"Modal depth distribution:\n{String.intercalate "\n" modalLines}\n" ++
  s!"Temporal depth distribution:\n{String.intercalate "\n" tempLines}"

/--
Generate formulas according to the specified sampling mode.
-/
def generateFormulas (params : EnumParams) : IO (List Formula) := do
  match params.samplingMode with
  | .exhaustive => return enumerateExhaustive params
  | .random => sampleRandom params
  | .hybrid =>
    -- Exhaustive for low complexity, random for higher
    let exhaustiveParams := { params with maxComplexity := min 5 params.maxComplexity,
                                          maxFormulas := params.maxFormulas / 2 }
    let exhaustive := enumerateExhaustive exhaustiveParams
    let remaining := params.maxFormulas - exhaustive.length
    if remaining > 0 then
      let randomParams := { params with maxFormulas := remaining }
      let random ← sampleRandom randomParams
      let combined := (exhaustive ++ random).eraseDups
      return combined.take params.maxFormulas
    else
      return exhaustive

end Bimodal.Automation
