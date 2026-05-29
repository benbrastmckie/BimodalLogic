import Bimodal.Syntax
import Bimodal.Automation.SuccessPatterns
import Std.Data.HashMap

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

### Task 210: Exact-complexity enumeration with memoization
- `enumExactHelper`: Memoized exact-complexity enumeration (3-constraint)
- `enumExactBudget`: Memoized exact-complexity enumeration (legacy 2-constraint)
- `generateValidBatch`: Axiom-schema instantiation for guaranteed-valid formulas

## Design Decisions

- **Exact-complexity semantics (Task 210)**: Each call generates formulas of EXACTLY
  the given complexity, not "up to". This eliminates the 651x bloat at budget 5 caused
  by re-including base cases at every recursion level.
- **Memoization (Task 210)**: A `Std.HashMap` cache keyed by `(budget, modalBudget,
  temporalBudget)` eliminates redundant computation. At budget 5 there are only 27
  unique argument triples despite 1,027 recursive calls in the naive version.
- **Three simultaneous constraints**: `enumerateUpToDepth` bounds modal depth, temporal
  depth, and total size independently. This prevents runaway in any single dimension.
- **Deterministic sampling**: `sampleFormulas` uses a linear congruential generator (LCG)
  for reproducibility. Same seed always produces same formulas.
- **Deduplication**: Exact-complexity levels produce disjoint formula sets by construction.
  Within a level, formulas are unique because each structural position is filled exactly once.
  `eraseDups` is no longer needed on the main enumeration path.
- **3-5 atoms**: Sufficient for non-trivial operator interactions

## References

- Task 201 plan: specs/201_alphazero_proof_search_harness/plans/01_task-decomposition.md
- Team research: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
- Task 210 research: specs/210_enumerator_complexity_blowup/reports/01_enumerator-blowup-research.md
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

/-!
## Memoization Cache Type

The memoization cache maps `(sizeBudget, modalBudget, temporalBudget)` triples
to the list of formulas at that exact complexity level. This eliminates redundant
computation: at budget 5 there are only 27 unique argument triples despite 1,027
recursive calls in the naive version.
-/

/-- Cache type for memoized enumeration, keyed by (size, modal, temporal). -/
abbrev EnumCache := Std.HashMap (Nat × Nat × Nat) (List Formula)

/--
Enumerate all formulas of EXACTLY the given complexity, respecting modal and
temporal depth bounds. Uses memoization via a carried cache to avoid redundant
computation.

**Exact-complexity semantics (Task 210)**: Unlike the original `enumHelper`,
this function generates formulas whose complexity is exactly `sizeBudget`, not
"up to". Base cases (atoms, bot) are only generated at sizeBudget=1. This
eliminates the 651x bloat caused by re-including base cases at every level.

The cache is threaded through all recursive calls as a state parameter, and
the updated cache is returned alongside the result list.
-/
def enumExactHelper (atoms : List Atom) (modalBudget temporalBudget sizeBudget : Nat)
    (cache : EnumCache) : List Formula × EnumCache :=
  let key := (sizeBudget, modalBudget, temporalBudget)
  match cache[key]? with
  | some result => (result, cache)
  | none =>
    let (result, cache') := match sizeBudget with
      | 0 => ([], cache)
      | 1 =>
        -- Base cases: atoms and bot (complexity exactly 1)
        (Formula.bot :: atoms.map Formula.atom, cache)
      | n + 2 =>
        -- Complexity is n + 2 (at least 2). The constructor costs 1.
        let childBudget := n + 1
        -- Unary: box φ (child has exact complexity childBudget)
        -- box adds 1 to modal depth, so child must fit within modalBudget - 1
        let (boxes, cache1) := if modalBudget > 0 then
          let (children, c) := enumExactHelper atoms (modalBudget - 1) temporalBudget childBudget cache
          (children.map Formula.box, c)
        else ([], cache)
        -- Binary constructors: distribute childBudget between left and right
        -- Each child gets exact complexity >= 1, left + right = childBudget
        let (binaryFormulas, cache2) := ((List.range childBudget).foldl
          (fun (acc : List Formula × EnumCache) i =>
            let leftSize := i + 1
            let rightSize := childBudget - leftSize
            if rightSize < 1 then acc
            else
              let (accList, accCache) := acc
              -- imp: no depth change
              let (lefts, c1) := enumExactHelper atoms modalBudget temporalBudget leftSize accCache
              let (rights, c2) := enumExactHelper atoms modalBudget temporalBudget rightSize c1
              let imps := lefts.flatMap fun l => rights.map fun r => Formula.imp l r
              -- untl/snce: temporal depth + 1 for the whole formula
              let (temporalBinaries, c3) := if temporalBudget > 0 then
                let (tLefts, c2a) := enumExactHelper atoms modalBudget (temporalBudget - 1) leftSize c2
                let (tRights, c2b) := enumExactHelper atoms modalBudget (temporalBudget - 1) rightSize c2a
                let untls := tLefts.flatMap fun l => tRights.map fun r => Formula.untl l r
                let snces := tLefts.flatMap fun l => tRights.map fun r => Formula.snce l r
                (untls ++ snces, c2b)
              else ([], c2)
              (accList ++ imps ++ temporalBinaries, c3)
          ) ([], cache1))
        (boxes ++ binaryFormulas, cache2)
    -- Store result in cache before returning
    let cache'' := cache'.insert key result
    (result, cache'')

/--
Enumerate all formulas satisfying modal depth, temporal depth, and size constraints.

**Backward-compatible wrapper**: Generates formulas at each exact complexity level
from 1 to `sizeBudget` and concatenates the results. Uses memoized exact-complexity
enumeration internally to avoid the exponential blowup of the original implementation.

Note: The original `enumHelper` generated "up to budget" formulas with base case
re-inclusion at every level, causing 651x bloat at budget 5. This version generates
exact-complexity formulas at each level, which are disjoint by construction.
-/
def enumHelper (atoms : List Atom) (modalBudget temporalBudget sizeBudget : Nat)
    : List Formula :=
  let (_, result) := (List.range sizeBudget).foldl
    (fun (acc : EnumCache × List Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactHelper atoms modalBudget temporalBudget (i + 1) cache
      (cache', formulas ++ exact))
    ({}, [])
  result

/--
Exhaustively enumerate all formulas up to the given depth and size bounds.

Generates all formulas satisfying ALL THREE constraints simultaneously:
- Modal depth ≤ `config.maxModalDepth`
- Temporal depth ≤ `config.maxTemporalDepth`
- Size (complexity) ≤ `config.maxSize`

Uses memoized exact-complexity enumeration. Each complexity level produces
a disjoint set of formulas, so deduplication is unnecessary.
-/
def enumerateUpToDepth (config : EnumConfig) : List Formula :=
  enumHelper config.atomPool config.maxModalDepth config.maxTemporalDepth config.maxSize

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
sampling strategy, and axiom-seeded valid formula generation.
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
  /-- Number of axiom-instantiated valid formulas to seed into the pool (Task 210).
      Set to 0 to disable axiom seeding. Default: 500. -/
  validSeedCount : Nat := 500
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
Enumerate all formulas of EXACTLY the given complexity, respecting modal and
temporal depth bounds. Uses memoization via a carried cache.

This is the legacy-API counterpart of `enumExactHelper`. The difference is that
this function uses a 2-constraint key `(budget, maxModal, maxTemporal)` matching
the original `enumerateAtBudget` signature, while `enumExactHelper` uses the
3-constraint key from `enumHelper`.

Since both APIs use the same `(Nat x Nat x Nat)` key shape, they share the
same `EnumCache` type.
-/
def enumExactBudget (atoms : List Atom) (budget : Nat) (maxModal : Nat) (maxTemporal : Nat)
    (cache : EnumCache) : List Formula × EnumCache :=
  -- We reuse enumExactHelper directly since both APIs use the same constraint model:
  -- enumExactHelper treats its 3 parameters as (modalBudget, temporalBudget, sizeBudget)
  -- and enumerateAtBudget treats its 3 parameters as (maxModal, maxTemporal, budget).
  -- The key is (sizeBudget, modalBudget, temporalBudget) in both cases.
  enumExactHelper atoms maxModal maxTemporal budget cache

/--
Enumerate all formulas within the given complexity budget, respecting
modal and temporal depth bounds.

**Backward-compatible wrapper**: Preserves the original `enumerateAtBudget` signature
but uses memoized exact-complexity enumeration internally. Generates formulas at
each exact complexity level from 1 to `budget` and concatenates.

Note: The original implementation used "up to budget" semantics with base case
re-inclusion at every level, causing exponential blowup (651x at budget 5).
-/
def enumerateAtBudget (atoms : List Atom) (budget : Nat) (maxModal : Nat) (maxTemporal : Nat)
    : List Formula :=
  let (_, result) := (List.range budget).foldl
    (fun (acc : EnumCache × List Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget atoms (i + 1) maxModal maxTemporal cache
      (cache', formulas ++ exact))
    ({}, [])
  result

/--
Enumerate all formulas exhaustively within the parameter bounds.

Generates formulas at each complexity level from 1 to `maxComplexity` using
memoized exact-complexity enumeration, filters by rejection criteria, and
caps at `maxFormulas`.

Each exact complexity level produces a disjoint set of formulas by construction,
so cross-level deduplication is unnecessary. The memoization cache is shared
across all complexity levels for maximum reuse.
-/
def enumerateExhaustive (params : EnumParams) : List Formula :=
  let (_, allFormulas) := (List.range params.maxComplexity).foldl
    (fun (acc : EnumCache × List Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget params.atoms (i + 1) params.maxModalDepth
                                              params.maxTemporalDepth cache
      (cache', formulas ++ exact))
    ({}, [])
  let filtered := allFormulas.filter passesFilter
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

/-!
## Axiom-Schema Instantiation (Task 210 Phase 2)

Generate valid-by-construction formulas by instantiating axiom schemata with
random sub-formulas. This addresses the valid fraction problem: random sampling
at high complexity produces overwhelmingly invalid formulas (1.6% at complexity 7).

The strategy is:
1. **Seed pool**: Generate axiom instances by picking random sub-formulas
2. **Necessitation round**: For each valid formula, `box(φ)` is also valid
3. **MP round**: For implications `φ` and `φ → ψ` both in pool, `ψ` is valid
4. **Filter**: Discard formulas outside target complexity range, deduplicate
-/

/--
Generate a random sub-formula of bounded complexity using IO.rand.
Used to fill axiom schema parameters with random formulas.
-/
partial def randomSubFormula (atoms : List Atom) (maxSize : Nat) : IO Formula := do
  if maxSize ≤ 1 then
    let idx ← IO.rand 0 atoms.length
    match atoms[idx]? with
    | some a => return .atom a
    | none => return .bot
  else
    -- 6 branches: atom(0), imp(1), box(2), all_future(3), untl(4), snce(5)
    -- Weights: atom=1, imp=2, box=1, all_future=1, untl=1 (snce reuses untl branch)
    let choice ← IO.rand 0 5
    match choice with
    | 0 =>
      let idx ← IO.rand 0 atoms.length
      match atoms[idx]? with
      | some a => return .atom a
      | none => return .bot
    | 1 =>
      -- imp: split budget
      let leftSize ← IO.rand 1 (maxSize - 1)
      let rightSize := maxSize - 1 - leftSize
      let left ← randomSubFormula atoms (max 1 leftSize)
      let right ← randomSubFormula atoms (max 1 rightSize)
      return .imp left right
    | 2 =>
      -- box
      let child ← randomSubFormula atoms (maxSize - 1)
      return .box child
    | 3 =>
      -- all_future (G(φ) = ¬F(¬φ)): unary temporal, costs ~4 complexity overhead
      let child ← randomSubFormula atoms (max 1 (maxSize - 4))
      return child.all_future
    | 4 =>
      -- untl: binary temporal
      if maxSize < 3 then
        let child ← randomSubFormula atoms (maxSize - 1)
        return .box child
      else
        let leftSize ← IO.rand 1 (maxSize - 1)
        let rightSize := maxSize - 1 - leftSize
        let left ← randomSubFormula atoms (max 1 leftSize)
        let right ← randomSubFormula atoms (max 1 rightSize)
        return .untl left right
    | _ =>
      -- snce: binary temporal
      if maxSize < 3 then
        let child ← randomSubFormula atoms (maxSize - 1)
        return .box child
      else
        let leftSize ← IO.rand 1 (maxSize - 1)
        let rightSize := maxSize - 1 - leftSize
        let left ← randomSubFormula atoms (max 1 leftSize)
        let right ← randomSubFormula atoms (max 1 rightSize)
        return .snce left right

/--
Instantiate a random axiom schema with random sub-formulas.

Picks one of the 8 high-yield axiom schemata and generates random formulas to
fill the schema parameters. The result is guaranteed valid by construction.

**Supported schemata**:
- `prop_s(φ, ψ)`: `φ → (ψ → φ)` (weakening)
- `prop_k(φ, ψ, χ)`: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- `ex_falso(φ)`: `⊥ → φ`
- `peirce(φ, ψ)`: `((φ → ψ) → φ) → φ`
- `modal_t(φ)`: `□φ → φ` (reflexivity)
- `modal_4(φ)`: `□φ → □□φ` (transitivity)
- `modal_b(φ)`: `φ → □◇φ` (symmetry)
- `modal_k_dist(φ, ψ)`: `□(φ → ψ) → (□φ → □ψ)`
-/
partial def instantiateAxiom (atoms : List Atom) (maxParamSize : Nat) : IO Formula := do
  let schemaIdx ← IO.rand 0 13
  match schemaIdx with
  | 0 => do
    -- prop_s: φ → (ψ → φ)
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return φ.imp (ψ.imp φ)
  | 1 => do
    -- prop_k: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    let χ ← randomSubFormula atoms maxParamSize
    return (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))
  | 2 => do
    -- ex_falso: ⊥ → φ
    let φ ← randomSubFormula atoms maxParamSize
    return Formula.bot.imp φ
  | 3 => do
    -- peirce: ((φ → ψ) → φ) → φ
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return ((φ.imp ψ).imp φ).imp φ
  | 4 => do
    -- modal_t: □φ → φ
    let φ ← randomSubFormula atoms maxParamSize
    return (Formula.box φ).imp φ
  | 5 => do
    -- modal_4: □φ → □□φ
    let φ ← randomSubFormula atoms maxParamSize
    return (Formula.box φ).imp (Formula.box (Formula.box φ))
  | 6 => do
    -- modal_b: φ → □◇φ
    let φ ← randomSubFormula atoms maxParamSize
    return φ.imp (Formula.box φ.diamond)
  | 7 => do
    -- modal_k_dist: □(φ → ψ) → (□φ → □ψ)
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return (φ.imp ψ).box.imp (φ.box.imp ψ.box)
  -- Temporal axiom schemata (6 new schemata)
  | 8 => do
    -- serial_future: ⊤ → F(⊤)
    return Formula.top.imp (Formula.some_future Formula.top)
  | 9 => do
    -- serial_past: ⊤ → P(⊤)
    return Formula.top.imp (Formula.some_past Formula.top)
  | 10 => do
    -- connect_future(φ): φ → G(P(φ))
    let φ ← randomSubFormula atoms maxParamSize
    return φ.imp (φ.some_past.all_future)
  | 11 => do
    -- connect_past(φ): φ → H(F(φ))
    let φ ← randomSubFormula atoms maxParamSize
    return φ.imp (φ.some_future.all_past)
  | 12 => do
    -- right_mono_until(φ, ψ, χ): G(φ → ψ) → ((φ U χ) → (ψ U χ))
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    let χ ← randomSubFormula atoms maxParamSize
    return (φ.imp ψ).all_future.imp ((Formula.untl φ χ).imp (Formula.untl ψ χ))
  | _ => do
    -- F_until_equiv(φ): F(φ) → (φ U ⊤)
    let φ ← randomSubFormula atoms maxParamSize
    return (Formula.some_future φ).imp (Formula.untl φ Formula.top)

/--
Apply modus ponens: given valid φ and valid (φ → ψ), return ψ.
Returns `none` if the implication does not match.
-/
def generateValidFromMP (antecedent implication : Formula) : Option Formula :=
  match implication with
  | .imp lhs rhs =>
    if lhs == antecedent then some rhs else none
  | _ => none

/--
Apply necessitation: given valid φ, return □φ (also valid by the necessitation rule).
-/
def generateValidFromNec (φ : Formula) : Formula :=
  Formula.box φ

/--
Generate a batch of guaranteed-valid formulas using an incremental pool strategy.

1. **Seed pool**: Generate `seedCount` axiom instances (all valid by construction)
2. **Necessitation round**: For each pool member, add `□φ` (valid by necessitation)
3. **MP round**: For each pair `(φ, ψ)` where `ψ = φ → χ`, add `χ` (valid by MP)
4. **Repeat**: Run necessitation + MP rounds once more
5. **Filter**: Keep formulas within target complexity range, deduplicate

Parameters:
- `seedCount`: Number of initial axiom instances to generate
- `maxComplexity`: Maximum formula complexity to keep in output
- `atoms`: Atom vocabulary for sub-formula generation
-/
partial def generateValidBatch (seedCount : Nat) (maxComplexity : Nat)
    (atoms : List Atom) : IO (List Formula) := do
  -- Phase 1: Seed pool with axiom instances
  let maxParamSize := max 1 (maxComplexity / 3)
  let mut pool : List Formula := []
  for _ in List.range seedCount do
    let axiomInst ← instantiateAxiom atoms maxParamSize
    pool := axiomInst :: pool
  pool := pool.eraseDups
  -- Phase 2: Necessitation round
  let necFormulas := pool.map generateValidFromNec
  pool := (pool ++ necFormulas).eraseDups
  -- Phase 3: MP round
  let mut mpResults : List Formula := []
  for φ in pool do
    for ψ in pool do
      match generateValidFromMP φ ψ with
      | some result => mpResults := result :: mpResults
      | none => pure ()
  pool := (pool ++ mpResults).eraseDups
  -- Phase 4: Second necessitation round
  let necFormulas2 := pool.map generateValidFromNec
  pool := (pool ++ necFormulas2).eraseDups
  -- Phase 5: Second MP round
  let mut mpResults2 : List Formula := []
  for φ in pool do
    for ψ in pool do
      match generateValidFromMP φ ψ with
      | some result => mpResults2 := result :: mpResults2
      | none => pure ()
  pool := (pool ++ mpResults2).eraseDups
  -- Phase 6: Filter by complexity range
  let filtered := pool.filter fun φ => φ.complexity ≥ 3 && φ.complexity ≤ maxComplexity
  return filtered

/--
Generate formulas according to the specified sampling mode.

Combines up to three formula sources:
1. **Exhaustive/random/hybrid enumeration** (as before)
2. **Axiom-seeded valid formulas** (Task 210): If `validSeedCount > 0`,
   generates guaranteed-valid formulas via axiom instantiation, necessitation,
   and modus ponens closure. These are mixed in to boost the valid fraction.

All sources are deduplicated before returning.
-/
partial def generateFormulas (params : EnumParams) : IO (List Formula) := do
  -- Step 1: Generate formulas from the selected sampling mode
  let enumerated ← match params.samplingMode with
    | .exhaustive => pure (enumerateExhaustive params)
    | .random => sampleRandom params
    | .hybrid =>
      let exhaustiveParams := { params with maxComplexity := min 5 params.maxComplexity,
                                            maxFormulas := params.maxFormulas / 2 }
      let exhaustive := enumerateExhaustive exhaustiveParams
      let remaining := params.maxFormulas - exhaustive.length
      if remaining > 0 then do
        let randomParams := { params with maxFormulas := remaining }
        let random ← sampleRandom randomParams
        pure ((exhaustive ++ random).eraseDups)
      else
        pure exhaustive
  -- Step 2: Generate axiom-seeded valid formulas if requested
  let validSeeds ← if params.validSeedCount > 0 then
    generateValidBatch params.validSeedCount params.maxComplexity params.atoms
  else
    pure []
  -- Step 3: Combine and deduplicate all sources
  let combined := (enumerated ++ validSeeds).eraseDups
  return combined.take params.maxFormulas

end Bimodal.Automation
