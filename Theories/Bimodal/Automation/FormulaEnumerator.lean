import Bimodal.Syntax
import Bimodal.Automation.SuccessPatterns

/-!
# Formula Enumerator for Dataset Generation

This module provides bounded enumeration of TM bimodal logic formulas with
structural diversity control. It supports exhaustive enumeration at low complexity
and both IO-based random and deterministic seed-based sampling at higher complexity.

## Main Definitions

### Plan-specified API (Task 201 Phase 2)
- `EnumConfig`: Configuration with modal depth, temporal depth, and size bounds
- `enumerateUpToDepth`: Exhaustive enumeration respecting all three constraints
- `sampleFormulas`: Deterministic pseudo-random sampling with seed-based LCG
- `defaultAtomPool`, `smallConfig`, `mediumConfig`: Standard configurations
- `DiversitySummary`: Operator distribution, depth histogram, per-category counts

### Legacy API (Task 203)
- `SamplingMode`: Enum for enumeration strategy selection
- `EnumParams`: Configuration structure for formula generation
- `enumerateExhaustive`: Generate all formulas up to given complexity bounds
- `sampleRandom`: IO-based random formula generation
- `enrichWithDuals`: Apply `swap_temporal` for free 2x augmentation
- `DiversityReport`: Distribution statistics across GoalCategory and depth buckets

## Design Decisions

- **Three simultaneous constraints**: `enumerateUpToDepth` bounds modal depth, temporal
  depth, and total size independently. This prevents runaway in any single dimension.
- **Deterministic sampling**: `sampleFormulas` uses a linear congruential generator (LCG)
  for reproducibility. Same seed always produces same formulas.
- **Deduplication**: Uses `List.eraseDups` via `BEq Formula` (already derived)
- **3-5 atoms**: Sufficient for non-trivial operator interactions

## References

- Task 201 plan: specs/201_alphazero_proof_search_harness/plans/01_task-decomposition.md
- Team research: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
-/

set_option autoImplicit false

namespace Bimodal.Automation

open Bimodal.Syntax

/-!
## Plan-specified API: EnumConfig and Core Enumeration (Task 201 Phase 2)
-/

/--
Configuration for bounded formula enumeration.
Controls three independent structural constraints plus an atom vocabulary.
-/
structure EnumConfig where
  /-- Bound on box nesting depth (modal depth). -/
  maxModalDepth : Nat
  /-- Bound on untl/snce nesting depth (temporal depth). -/
  maxTemporalDepth : Nat
  /-- Total connective count bound (formula complexity). -/
  maxSize : Nat
  /-- Available atoms for formula construction. -/
  atomPool : List Atom
  deriving Repr

/-- Default atom pool: p, q, r, s, t. -/
def defaultAtomPool : List Atom :=
  ["p", "q", "r", "s", "t"].map Atom.mk_base

/-- Small config: depth 2, size 8, 3 atoms. Suitable for exhaustive enumeration. -/
def smallConfig : EnumConfig :=
  { maxModalDepth := 2
  , maxTemporalDepth := 2
  , maxSize := 8
  , atomPool := defaultAtomPool.take 3 }

/-- Medium config: depth 3, size 12, 5 atoms. Larger space for sampling. -/
def mediumConfig : EnumConfig :=
  { maxModalDepth := 3
  , maxTemporalDepth := 3
  , maxSize := 12
  , atomPool := defaultAtomPool }

/--
Enumerate all formulas satisfying modal depth, temporal depth, and size constraints.

Uses bounded recursion on `sizeBudget`. At each recursive call, tries all 6 constructors:
- `atom a`, `bot`: base cases consuming 1 unit of size budget
- `imp φ ψ`: binary, no depth increment, partitions size budget
- `box φ`: unary, increments modal depth, consumes 1 size unit
- `untl φ ψ`, `snce φ ψ`: binary, increments temporal depth, partitions size budget

For binary constructors, iterates over all ways to split the remaining size
budget between left and right children (each child gets at least 1).
-/
def enumHelper (atoms : List Atom) (modalBudget temporalBudget sizeBudget : Nat)
    : List Formula :=
  match sizeBudget with
  | 0 => []
  | 1 =>
    -- Base cases: atoms and bot (size 1, depth 0)
    Formula.bot :: atoms.map Formula.atom
  | n + 2 =>
    -- Size budget is n + 2 (at least 2), so we can form compound formulas.
    -- The constructor itself costs 1, leaving n + 1 for children.
    let childBudget := n + 1
    -- Also include base cases at this budget level
    let base := Formula.bot :: atoms.map Formula.atom
    -- Unary: box φ (modal depth + 1, same temporal depth, child gets childBudget)
    let boxes := if modalBudget > 0 then
      (enumHelper atoms (modalBudget - 1) temporalBudget childBudget).map Formula.box
    else []
    -- Binary constructors: distribute childBudget between left and right
    -- leftSize ranges from 1 to childBudget - 1, rightSize = childBudget - leftSize
    let binaryFormulas := (List.range childBudget).flatMap fun i =>
      let leftSize := i + 1
      let rightSize := childBudget - leftSize
      if rightSize < 1 then []
      else
        let lefts := enumHelper atoms modalBudget temporalBudget leftSize
        let rights := enumHelper atoms modalBudget temporalBudget rightSize
        -- imp: no depth change
        let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
        -- untl/snce: temporal depth + 1 for the whole formula, so children
        -- must fit within temporalBudget - 1
        let temporalBinaries := if temporalBudget > 0 then
          let tLefts := enumHelper atoms modalBudget (temporalBudget - 1) leftSize
          let tRights := enumHelper atoms modalBudget (temporalBudget - 1) rightSize
          let untls := tLefts.flatMap fun l => tRights.map fun r => Formula.untl l r
          let snces := tLefts.flatMap fun l => tRights.map fun r => Formula.snce l r
          untls ++ snces
        else []
        imps ++ temporalBinaries
    base ++ boxes ++ binaryFormulas

/--
Exhaustively enumerate all formulas up to the given depth and size bounds.

Generates all formulas satisfying ALL THREE constraints simultaneously:
- Modal depth ≤ `config.maxModalDepth`
- Temporal depth ≤ `config.maxTemporalDepth`
- Size (complexity) ≤ `config.maxSize`

Results are deduplicated using `Formula.BEq`.
-/
def enumerateUpToDepth (config : EnumConfig) : List Formula :=
  let raw := enumHelper config.atomPool config.maxModalDepth config.maxTemporalDepth config.maxSize
  raw.eraseDups

/-!
## Deterministic Pseudo-Random Sampling
-/

/--
Simple linear congruential generator (LCG) state.
Uses the glibc constants: a = 1103515245, c = 12345, m = 2^31.
-/
structure LCGState where
  /-- Current state value. -/
  value : Nat
  deriving Repr

/-- Initialize LCG from a seed. -/
def LCGState.init (seed : Nat) : LCGState :=
  { value := seed % (2 ^ 31) }

/-- Step the LCG, returning the next state and a random value. -/
def LCGState.next (s : LCGState) : LCGState × Nat :=
  let m := 2 ^ 31
  let newVal := (1103515245 * s.value + 12345) % m
  ({ value := newVal }, newVal)

/-- Get a random number in range [0, bound) from LCG state. Returns (nextState, value). -/
def LCGState.randBound (s : LCGState) (bound : Nat) : LCGState × Nat :=
  if bound == 0 then (s, 0)
  else
    let (s', v) := s.next
    (s', v % bound)

/--
Generate a single formula using deterministic pseudo-random choices.

At each step, randomly picks a constructor type, distributing
the remaining size budget to children. Respects modal and temporal
depth constraints.
-/
def sampleOne (atoms : List Atom) (modalBudget temporalBudget sizeBudget : Nat)
    (rng : LCGState) (fuel : Nat) : LCGState × Formula :=
  match fuel with
  | 0 => (rng, Formula.bot)  -- fallback if fuel exhausted
  | fuel' + 1 =>
  if sizeBudget ≤ 1 then
    -- Base case: pick a random atom or bot
    let numChoices := atoms.length + 1  -- +1 for bot
    let (rng', idx) := rng.randBound numChoices
    if idx == 0 then (rng', Formula.bot)
    else match atoms[idx - 1]? with
      | some a => (rng', Formula.atom a)
      | none => (rng', Formula.bot)
  else
    -- Count available constructor types
    -- 0 = base (atom/bot), 1 = imp, 2 = box (if modal ok), 3 = untl (if temporal ok), 4 = snce
    let hasModal := modalBudget > 0
    let hasTemporal := temporalBudget > 0
    let numChoices := 2 + (if hasModal then 1 else 0) + (if hasTemporal then 2 else 0)
    let (rng1, choice) := rng.randBound numChoices
    if choice == 0 then
      -- Base: atom or bot
      let numBase := atoms.length + 1
      let (rng2, idx) := rng1.randBound numBase
      if idx == 0 then (rng2, Formula.bot)
      else match atoms[idx - 1]? with
        | some a => (rng2, Formula.atom a)
        | none => (rng2, Formula.bot)
    else if choice == 1 then
      -- Binary: implication
      let childBudget := sizeBudget - 1
      if childBudget < 2 then
        -- Not enough for two children, fall back to base
        let (rng2, idx) := rng1.randBound (atoms.length + 1)
        if idx == 0 then (rng2, Formula.bot)
        else match atoms[idx - 1]? with
          | some a => (rng2, Formula.atom a)
          | none => (rng2, Formula.bot)
      else
        let maxSplit := childBudget - 1
        let (rng2, splitIdx) := rng1.randBound maxSplit
        let leftSize := splitIdx + 1
        let rightSize := childBudget - leftSize
        let (rng3, left) := sampleOne atoms modalBudget temporalBudget leftSize rng2 fuel'
        let (rng4, right) := sampleOne atoms modalBudget temporalBudget rightSize rng3 fuel'
        (rng4, Formula.imp left right)
    else if choice == 2 && hasModal then
      -- Unary: box
      let (rng2, child) := sampleOne atoms (modalBudget - 1) temporalBudget (sizeBudget - 1) rng1 fuel'
      (rng2, Formula.box child)
    else if hasTemporal then
      -- Temporal binary: untl or snce
      let childBudget := sizeBudget - 1
      if childBudget < 2 then
        let (rng2, idx) := rng1.randBound (atoms.length + 1)
        if idx == 0 then (rng2, Formula.bot)
        else match atoms[idx - 1]? with
          | some a => (rng2, Formula.atom a)
          | none => (rng2, Formula.bot)
      else
        let maxSplit := childBudget - 1
        let (rng2, splitIdx) := rng1.randBound maxSplit
        let leftSize := splitIdx + 1
        let rightSize := childBudget - leftSize
        let (rng3, left) := sampleOne atoms modalBudget (temporalBudget - 1) leftSize rng2 fuel'
        let (rng4, right) := sampleOne atoms modalBudget (temporalBudget - 1) rightSize rng3 fuel'
        -- Decide untl vs snce
        let (rng5, untlOrSnce) := rng4.randBound 2
        if untlOrSnce == 0 then (rng5, Formula.untl left right)
        else (rng5, Formula.snce left right)
    else
      -- Fallback: imp
      let childBudget := sizeBudget - 1
      if childBudget < 2 then
        let (rng2, idx) := rng1.randBound (atoms.length + 1)
        if idx == 0 then (rng2, Formula.bot)
        else match atoms[idx - 1]? with
          | some a => (rng2, Formula.atom a)
          | none => (rng2, Formula.bot)
      else
        let maxSplit := childBudget - 1
        let (rng2, splitIdx) := rng1.randBound maxSplit
        let leftSize := splitIdx + 1
        let rightSize := childBudget - leftSize
        let (rng3, left) := sampleOne atoms modalBudget temporalBudget leftSize rng2 fuel'
        let (rng4, right) := sampleOne atoms modalBudget temporalBudget rightSize rng3 fuel'
        (rng4, Formula.imp left right)

/-- Helper: generate `remaining` candidate formulas using LCG-based random choices. -/
private def sampleLoop (atoms : List Atom) (maxModal maxTemporal maxSize fuel : Nat)
    (rng : LCGState) (remaining : Nat) (acc : List Formula) : List Formula :=
  match remaining with
  | 0 => acc
  | n + 1 =>
    let minSize := min 3 maxSize
    let sizeRange := maxSize - minSize + 1
    let (rng1, sizeOff) := rng.randBound sizeRange
    let sizeBudget := minSize + sizeOff
    let (rng2, φ) := sampleOne atoms maxModal maxTemporal sizeBudget rng1 fuel
    sampleLoop atoms maxModal maxTemporal maxSize fuel rng2 n (φ :: acc)

/--
Deterministic pseudo-random sampling of formulas.

Uses a linear congruential generator seeded by `seed` for reproducibility.
Generates `count * 3` candidates (to account for duplicates), choosing random
constructor types and size distributions within the bounds of `config`.
Deduplicates and returns up to `count` formulas.

**Determinism**: Same `seed` always produces the same output list.
-/
def sampleFormulas (config : EnumConfig) (count seed : Nat) : List Formula :=
  let attempts := count * 3
  let fuel := config.maxSize * 4  -- generous fuel for recursion
  let candidates := sampleLoop config.atomPool config.maxModalDepth config.maxTemporalDepth
                      config.maxSize fuel (LCGState.init seed) attempts []
  let deduped := candidates.eraseDups
  deduped.take count

/-!
## Diversity Summary (Plan-specified)
-/

/--
Operator distribution: count of each top-level constructor in a formula list.
-/
structure OperatorDistribution where
  atomCount : Nat := 0
  botCount : Nat := 0
  impCount : Nat := 0
  boxCount : Nat := 0
  untlCount : Nat := 0
  snceCount : Nat := 0
  deriving Repr, Inhabited

/-- Count the top-level operator of a formula. -/
def countTopOperator (dist : OperatorDistribution) (φ : Formula) : OperatorDistribution :=
  match φ with
  | .atom _ => { dist with atomCount := dist.atomCount + 1 }
  | .bot => { dist with botCount := dist.botCount + 1 }
  | .imp _ _ => { dist with impCount := dist.impCount + 1 }
  | .box _ => { dist with boxCount := dist.boxCount + 1 }
  | .untl _ _ => { dist with untlCount := dist.untlCount + 1 }
  | .snce _ _ => { dist with snceCount := dist.snceCount + 1 }

/--
Diversity summary for a list of formulas.

Captures:
- Total count
- Operator distribution (top-level constructor frequencies)
- Modal depth histogram
- Temporal depth histogram
- Formula count per GoalCategory
-/
structure DiversitySummary where
  /-- Total formula count. -/
  totalCount : Nat
  /-- Top-level operator frequencies. -/
  operatorDist : OperatorDistribution
  /-- Modal depth histogram: (depth, count) pairs. -/
  modalDepthHist : List (Nat × Nat)
  /-- Temporal depth histogram: (depth, count) pairs. -/
  temporalDepthHist : List (Nat × Nat)
  /-- Formula count per GoalCategory. -/
  categoryCount : List (GoalCategory × Nat)
  deriving Repr, Inhabited

/-- Increment the count for a key in an association list. -/
private def incrCount {α : Type} [BEq α] (counts : List (α × Nat)) (key : α)
    : List (α × Nat) :=
  if counts.any (fun (k, _) => k == key) then
    counts.map fun (k, n) => if k == key then (k, n + 1) else (k, n)
  else
    (key, 1) :: counts

/--
Compute a diversity summary for a list of formulas.

Reports operator distribution, depth histograms, and per-category counts.
-/
def diversitySummary (formulas : List Formula) : DiversitySummary :=
  formulas.foldl (fun s φ =>
    { s with
      operatorDist := countTopOperator s.operatorDist φ
      modalDepthHist := incrCount s.modalDepthHist φ.modalDepth
      temporalDepthHist := incrCount s.temporalDepthHist φ.temporalDepth
      categoryCount := incrCount s.categoryCount (goalCategory φ) }
  ) { totalCount := formulas.length
    , operatorDist := {}
    , modalDepthHist := []
    , temporalDepthHist := []
    , categoryCount := [] }

/-- Display a diversity summary as a human-readable string. -/
def DiversitySummary.display (s : DiversitySummary) : String :=
  let opLines :=
    s!"  atom: {s.operatorDist.atomCount}, bot: {s.operatorDist.botCount}, " ++
    s!"imp: {s.operatorDist.impCount}, box: {s.operatorDist.boxCount}, " ++
    s!"untl: {s.operatorDist.untlCount}, snce: {s.operatorDist.snceCount}"
  let modalLines := s.modalDepthHist.map fun (d, n) => s!"  depth {d}: {n}"
  let tempLines := s.temporalDepthHist.map fun (d, n) => s!"  depth {d}: {n}"
  let catLines := s.categoryCount.map fun (c, n) => s!"  {repr c}: {n}"
  s!"Total formulas: {s.totalCount}\n" ++
  s!"Operator distribution:\n{opLines}\n" ++
  s!"Modal depth histogram:\n{String.intercalate "\n" modalLines}\n" ++
  s!"Temporal depth histogram:\n{String.intercalate "\n" tempLines}\n" ++
  s!"GoalCategory counts:\n{String.intercalate "\n" catLines}"

/-!
## Legacy API (Task 203 compatibility)

The following definitions preserve backward compatibility with the existing
`EnumParams`-based API used by DatasetGenerator and other consumers.
-/

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
Configuration parameters for formula enumeration (legacy API).

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
          let tLefts := enumerateAtBudget atoms leftBudget maxModal (maxTemporal - 1)
          let tRights := enumerateAtBudget atoms rightBudget maxModal (maxTemporal - 1)
          tLefts.flatMap fun l => tRights.map fun r => Formula.untl l r
        else []
        let snces := if maxTemporal > 0 then
          let tLefts := enumerateAtBudget atoms leftBudget maxModal (maxTemporal - 1)
          let tRights := enumerateAtBudget atoms rightBudget maxModal (maxTemporal - 1)
          tLefts.flatMap fun l => tRights.map fun r => Formula.snce l r
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
Diversity report: distribution of formulas across structural categories (legacy).
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

/-- Bucket a depth value: 0, 1, 2, or 3 (representing 3+). -/
private def depthBucket (d : Nat) : Nat :=
  if d ≤ 2 then d else 3

/--
Compute diversity metrics for a list of formulas (legacy API).

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
      categoryCounts := incrCount report.categoryCounts (goalCategory φ)
      modalDepthCounts := incrCount report.modalDepthCounts (depthBucket φ.modalDepth)
      temporalDepthCounts := incrCount report.temporalDepthCounts (depthBucket φ.temporalDepth)
    }
  ) init

/--
Format a diversity report as a human-readable string (legacy API).
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
Generate formulas according to the specified sampling mode (legacy API).
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
