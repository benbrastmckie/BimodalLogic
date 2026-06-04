import Bimodal.Syntax
import Bimodal.Automation.SuccessPatterns
import Bimodal.Automation.AtomCanonicalization
import Std.Data.HashMap
import Std.Data.HashSet

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

/-- Cache type for memoized enumeration, keyed by (size, modal, temporal).
    Uses `Array Formula` for O(1) amortized push and efficient iteration. -/
abbrev EnumCache := Std.HashMap (Nat × Nat × Nat) (Array Formula)

/--
Check if a formula is structurally trivial and should be pruned during enumeration.
A formula is structurally trivial if it is semantically equivalent to a simpler
formula that is already in the enumeration space.

Pruned patterns:
- Identity implication: `φ → φ` (any formula implying itself, trivially valid)
- Ex falso: `⊥ → φ` (covered by the ex_falso axiom, always valid)
- S5 box idempotence: `□(□φ)` is equivalent to `□φ` under S5
- Double negation redundancy: `(φ → ⊥) → ⊥` when `φ` is lower complexity

These checks are O(1) pattern matches -- no deep traversal needed.
-/
def structurallyTrivial : Formula → Bool
  -- Identity: φ → φ
  | .imp l r => l == r || match l, r with
    -- Ex falso: ⊥ → φ
    | .bot, _ => true
    | _, _ => false
  -- S5 box idempotence: □(□φ) equivalent to □φ
  | .box (.box _) => true
  | _ => false

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
    (cache : EnumCache) : Array Formula × EnumCache :=
  let key := (sizeBudget, modalBudget, temporalBudget)
  match cache[key]? with
  | some result => (result, cache)
  | none =>
    let (result, cache') := match sizeBudget with
      | 0 => (#[], cache)
      | 1 =>
        -- Base cases: atoms and bot (complexity exactly 1)
        let base := #[Formula.bot] ++ (atoms.map Formula.atom).toArray
        (base, cache)
      | n + 2 =>
        -- Complexity is n + 2 (at least 2). The constructor costs 1.
        let childBudget := n + 1
        -- Unary: box φ (child has exact complexity childBudget)
        -- box adds 1 to modal depth, so child must fit within modalBudget - 1
        let (boxes, cache1) := if modalBudget > 0 then
          let (children, c) := enumExactHelper atoms (modalBudget - 1) temporalBudget childBudget cache
          -- Filter out box(box(φ)) since □□φ ≡ □φ under S5
          let boxed := children.foldl (fun (acc : Array Formula) child =>
            let f := Formula.box child
            if structurallyTrivial f then acc else acc.push f
          ) #[]
          (boxed, c)
        else (#[], cache)
        -- Derived unary temporal operators: F, P, G, H
        -- These are defined in terms of untl/snce but enumerated as first-class targets.
        -- Overhead: F/P/G/H all cost 1 complexity (pattern-aware complexity, task 274)
        -- Gated by temporalBudget > 0 (consumes 1 temporal depth).
        let (derivedTemporal, cache1a) := if temporalBudget > 0 then
          -- F(child): some_future child, overhead = 1, child complexity = sizeBudget - 1
          let fOverhead := 1
          let (fFormulas, c1) := if sizeBudget > fOverhead then
            let childSize := sizeBudget - fOverhead
            let (children, c) := enumExactHelper atoms modalBudget (temporalBudget - 1) childSize cache1
            (children.map Formula.some_future, c)
          else (#[], cache1)
          -- P(child): some_past child, overhead = 1, child complexity = sizeBudget - 1
          let pOverhead := 1
          let (pFormulas, c2) := if sizeBudget > pOverhead then
            let childSize := sizeBudget - pOverhead
            let (children, c) := enumExactHelper atoms modalBudget (temporalBudget - 1) childSize c1
            (children.map Formula.some_past, c)
          else (#[], c1)
          -- G(child): all_future child, overhead = 1, child complexity = sizeBudget - 1
          let gOverhead := 1
          let (gFormulas, c3) := if sizeBudget > gOverhead then
            let childSize := sizeBudget - gOverhead
            let (children, c) := enumExactHelper atoms modalBudget (temporalBudget - 1) childSize c2
            (children.map Formula.all_future, c)
          else (#[], c2)
          -- H(child): all_past child, overhead = 1, child complexity = sizeBudget - 1
          let hOverhead := 1
          let (hFormulas, c4) := if sizeBudget > hOverhead then
            let childSize := sizeBudget - hOverhead
            let (children, c) := enumExactHelper atoms modalBudget (temporalBudget - 1) childSize c3
            (children.map Formula.all_past, c)
          else (#[], c3)
          (fFormulas ++ pFormulas ++ gFormulas ++ hFormulas, c4)
        else (#[], cache1)
        -- Binary constructors: distribute childBudget between left and right
        -- Each child gets exact complexity >= 1, left + right = childBudget
        let (binaryFormulas, cache2) := ((List.range childBudget).foldl
          (fun (acc : Array Formula × EnumCache) i =>
            let leftSize := i + 1
            let rightSize := childBudget - leftSize
            if rightSize < 1 then acc
            else
              let (accArr, accCache) := acc
              -- imp: no depth change
              let (lefts, c1) := enumExactHelper atoms modalBudget temporalBudget leftSize accCache
              let (rights, c2) := enumExactHelper atoms modalBudget temporalBudget rightSize c1
              -- Cross-product for implication with structural pruning
              let imps := lefts.foldl (fun (acc : Array Formula) l =>
                rights.foldl (fun (acc' : Array Formula) r =>
                  let f := Formula.imp l r
                  if structurallyTrivial f then acc' else acc'.push f
                ) acc
              ) (Array.mkEmpty (lefts.size * rights.size))
              -- untl/snce: temporal depth + 1 for the whole formula
              let (temporalBinaries, c3) := if temporalBudget > 0 then
                let (tLefts, c2a) := enumExactHelper atoms modalBudget (temporalBudget - 1) leftSize c2
                let (tRights, c2b) := enumExactHelper atoms modalBudget (temporalBudget - 1) rightSize c2a
                let untls := tLefts.foldl (fun (acc : Array Formula) l =>
                  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.untl l r)) acc
                ) (Array.mkEmpty (tLefts.size * tRights.size))
                let snces := tLefts.foldl (fun (acc : Array Formula) l =>
                  tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.snce l r)) acc
                ) (Array.mkEmpty (tLefts.size * tRights.size))
                (untls ++ snces, c2b)
              else (#[], c2)
              (accArr ++ imps ++ temporalBinaries, c3)
          ) (#[], cache1a))
        (boxes ++ derivedTemporal ++ binaryFormulas, cache2)
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
    (fun (acc : EnumCache × Array Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactHelper atoms modalBudget temporalBudget (i + 1) cache
      (cache', formulas ++ exact))
    ({}, #[])
  result.toList

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
    -- 0 = base (atom/bot), 1 = imp, 2 = box (if modal ok),
    -- 3 = untl/snce (if temporal ok),
    -- 4 = F/P (if temporal ok and sizeBudget > 4),
    -- 5 = G/H (if temporal ok and sizeBudget > 8)
    let hasModal := modalBudget > 0
    let hasTemporal := temporalBudget > 0
    let hasDerivedFP := hasTemporal && sizeBudget > 1
    let hasDerivedGH := hasTemporal && sizeBudget > 1
    let numChoices := 2 + (if hasModal then 1 else 0) + (if hasTemporal then 1 else 0)
                        + (if hasDerivedFP then 1 else 0) + (if hasDerivedGH then 1 else 0)
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
    else if choice == 2 + (if hasModal then 1 else 0) && hasTemporal then
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
    else if hasDerivedFP && choice == 2 + (if hasModal then 1 else 0) + (if hasTemporal then 1 else 0) then
      -- Derived unary temporal: F (some_future) or P (some_past)
      -- Overhead: 4 complexity (untl/snce + top)
      let childSize := sizeBudget - 4
      let (rng2, child) := sampleOne atoms modalBudget (temporalBudget - 1) childSize rng1 fuel'
      let (rng3, fpChoice) := rng2.randBound 2
      if fpChoice == 0 then (rng3, child.some_future)
      else (rng3, child.some_past)
    else if hasDerivedGH then
      -- Derived unary temporal: G (all_future) or H (all_past)
      -- Overhead: 8 complexity (neg(F/P(neg child)))
      let childSize := sizeBudget - 8
      let (rng2, child) := sampleOne atoms modalBudget (temporalBudget - 1) childSize rng1 fuel'
      let (rng3, ghChoice) := rng2.randBound 2
      if ghChoice == 0 then (rng3, child.all_future)
      else (rng3, child.all_past)
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
Includes both primitive constructors and recognized derived temporal operators.
-/
structure OperatorDistribution where
  atomCount : Nat := 0
  botCount : Nat := 0
  impCount : Nat := 0
  boxCount : Nat := 0
  untlCount : Nat := 0
  snceCount : Nat := 0
  /-- Count of formulas matching the F (some_future) pattern: untl(φ, ⊤). -/
  allFutureCount : Nat := 0
  /-- Count of formulas matching the H (all_past) pattern: ¬P(¬φ). -/
  allPastCount : Nat := 0
  /-- Count of formulas matching the F (some_future) pattern: untl(φ, ⊤). -/
  someFutureCount : Nat := 0
  /-- Count of formulas matching the P (some_past) pattern: snce(φ, ⊤). -/
  somePastCount : Nat := 0
  deriving Repr, Inhabited

/-- Check if a formula matches the ⊤ pattern (imp bot bot). -/
private def isTop : Formula → Bool
  | .imp .bot .bot => true
  | _ => false

/-- Check if a formula matches the negation pattern (imp φ bot). -/
private def isNeg : Formula → Bool
  | .imp _ .bot => true
  | _ => false

/-- Count the top-level operator of a formula, recognizing derived temporal patterns.
    Derived operators are counted in BOTH the primitive field and the derived field. -/
def countTopOperator (dist : OperatorDistribution) (φ : Formula) : OperatorDistribution :=
  match φ with
  | .atom _ => { dist with atomCount := dist.atomCount + 1 }
  | .bot => { dist with botCount := dist.botCount + 1 }
  | .box _ => { dist with boxCount := dist.boxCount + 1 }
  | .untl _ rhs =>
    let dist' := { dist with untlCount := dist.untlCount + 1 }
    -- Check for F pattern: untl(φ, ⊤)
    if isTop rhs then { dist' with someFutureCount := dist'.someFutureCount + 1 }
    else dist'
  | .snce _ rhs =>
    let dist' := { dist with snceCount := dist.snceCount + 1 }
    -- Check for P pattern: snce(φ, ⊤)
    if isTop rhs then { dist' with somePastCount := dist'.somePastCount + 1 }
    else dist'
  | .imp inner .bot =>
    -- Check for G pattern: ¬(F(¬φ)) = imp(untl(imp(φ, bot), imp(bot, bot)), bot)
    -- Check for H pattern: ¬(P(¬φ)) = imp(snce(imp(φ, bot), imp(bot, bot)), bot)
    let dist' := { dist with impCount := dist.impCount + 1 }
    match inner with
    | .untl negChild guard =>
      if isNeg negChild && isTop guard then
        { dist' with allFutureCount := dist'.allFutureCount + 1 }
      else dist'
    | .snce negChild guard =>
      if isNeg negChild && isTop guard then
        { dist' with allPastCount := dist'.allPastCount + 1 }
      else dist'
    | _ => dist'
  | .imp _ _ => { dist with impCount := dist.impCount + 1 }

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
  let derivedLines :=
    s!"  G (all_future): {s.operatorDist.allFutureCount}, " ++
    s!"H (all_past): {s.operatorDist.allPastCount}, " ++
    s!"F (some_future): {s.operatorDist.someFutureCount}, " ++
    s!"P (some_past): {s.operatorDist.somePastCount}"
  let modalLines := s.modalDepthHist.map fun (d, n) => s!"  depth {d}: {n}"
  let tempLines := s.temporalDepthHist.map fun (d, n) => s!"  depth {d}: {n}"
  let catLines := s.categoryCount.map fun (c, n) => s!"  {repr c}: {n}"
  s!"Total formulas: {s.totalCount}\n" ++
  s!"Operator distribution (primitive):\n{opLines}\n" ++
  s!"Derived temporal operators:\n{derivedLines}\n" ++
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
  | stratified
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
  /-- Maximum number of formulas to generate. 0 means no limit (truly exhaustive). Default 0. -/
  maxFormulas : Nat := 0
  /-- Sampling strategy. Default: exhaustive. -/
  samplingMode : SamplingMode := .exhaustive
  /-- Number of axiom-instantiated valid formulas to seed into the pool (Task 210).
      Set to 0 to disable axiom seeding. Default: 500. -/
  validSeedCount : Nat := 500
  /-- Per-complexity-level quotas for stratified sampling.
      Each pair is (complexity, maxRecords). A maxRecords of 0 means exhaustive.
      Only used when samplingMode = .stratified. -/
  stratifiedQuotas : List (Nat × Nat) := []
  /-- Optional directory for checkpoint files. When set, enables per-level JSONL
      output and crash resume. -/
  checkpointDir : Option System.FilePath := none
  /-- Whether to attempt resume from existing checkpoint. When true and
      checkpointDir is set, completed levels are skipped on restart. -/
  resume : Bool := false
  /-- Whether to apply atom-permutation canonicalization and deduplication
      during enumeration. When true, formulas are canonicalized per-level and
      duplicates under atom renaming are removed. Yields ~4.58x reduction at c7.
      Default false for backward compatibility; set true for c8+ runs. -/
  canonicalDedup : Bool := false
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
    (cache : EnumCache) : Array Formula × EnumCache :=
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
    (fun (acc : EnumCache × Array Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget atoms (i + 1) maxModal maxTemporal cache
      (cache', formulas ++ exact))
    ({}, #[])
  result.toList

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
    (fun (acc : EnumCache × Array Formula) i =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget params.atoms (i + 1) params.maxModalDepth
                                              params.maxTemporalDepth cache
      (cache', formulas ++ exact))
    ({}, #[])
  let filtered := allFormulas.toList.filter passesFilter
  if params.maxFormulas == 0 then filtered else filtered.take params.maxFormulas

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
    -- Choose constructor type: 0=atom/bot, 1=imp, 2=box, 3=untl, 4=snce,
    -- 5=F/P (if temporal ok and budget > 4), 6=G/H (if temporal ok and budget > 8)
    let hasDerivedFP := maxTemporal > 0 && budget > 1
    let hasDerivedGH := maxTemporal > 0 && budget > 1
    let maxChoice := (if maxModal > 0 && maxTemporal > 0 then 4
                     else if maxModal > 0 then 2
                     else if maxTemporal > 0 then 4
                     else 1)
                     + (if hasDerivedFP then 1 else 0)
                     + (if hasDerivedGH then 1 else 0)
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
    | 4 =>
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
    | 5 =>
      -- Derived temporal: F (some_future) or P (some_past), overhead 1 (task 274)
      if hasDerivedFP then
        let childSize := budget - 1
        let child ← sampleOneRandom atoms (max 1 childSize) maxModal (maxTemporal - 1)
        let fpChoice ← IO.rand 0 1
        if fpChoice == 0 then return child.some_future
        else return child.some_past
      else
        -- Fallback to implication
        let split ← IO.rand 1 (budget - 1)
        let left ← sampleOneRandom atoms split maxModal maxTemporal
        let right ← sampleOneRandom atoms (budget - 1 - split) maxModal maxTemporal
        return .imp left right
    | _ =>
      -- Derived temporal: G (all_future) or H (all_past), overhead 1 (task 274)
      if hasDerivedGH then
        let childSize := budget - 1
        let child ← sampleOneRandom atoms (max 1 childSize) maxModal (maxTemporal - 1)
        let ghChoice ← IO.rand 0 1
        if ghChoice == 0 then return child.all_future
        else return child.all_past
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
    -- 9 branches: atom(0), imp(1), box(2), all_future(3), all_past(4),
    -- some_future(5), some_past(6), untl(7), snce(8)
    let choice ← IO.rand 0 8
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
      -- all_future (G(φ) = ¬F(¬φ)): unary temporal, costs ~8 complexity overhead
      let child ← randomSubFormula atoms (max 1 (maxSize - 8))
      return child.all_future
    | 4 =>
      -- all_past (H(φ) = ¬P(¬φ)): unary temporal, costs ~8 complexity overhead
      let child ← randomSubFormula atoms (max 1 (maxSize - 8))
      return child.all_past
    | 5 =>
      -- some_future (F(φ) = untl(φ, ⊤)): unary temporal, costs ~4 complexity overhead
      let child ← randomSubFormula atoms (max 1 (maxSize - 4))
      return child.some_future
    | 6 =>
      -- some_past (P(φ) = snce(φ, ⊤)): unary temporal, costs ~4 complexity overhead
      let child ← randomSubFormula atoms (max 1 (maxSize - 4))
      return child.some_past
    | 7 =>
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

Picks one of 22 axiom schemata and generates random formulas to fill the schema
parameters. The result is guaranteed valid by construction.

**Supported schemata** (22 total):
- Propositional (4): prop_s, prop_k, ex_falso, peirce
- Modal (4): modal_t, modal_4, modal_b, modal_k_dist
- Temporal basic (6): serial_future, serial_past, connect_future, connect_past,
  right_mono_until, F_until_equiv
- Temporal-modal interaction (8, Task 272): modal_future, modal_past, perpetuity_1,
  perpetuity_2, G_distribution, H_distribution, always_to_present, present_to_sometimes
-/
partial def instantiateAxiom (atoms : List Atom) (maxParamSize : Nat) : IO Formula := do
  let schemaIdx ← IO.rand 0 21
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
  -- Temporal axiom schemata (6 existing temporal schemata)
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
  | 13 => do
    -- F_until_equiv(φ): F(φ) → (φ U ⊤)
    let φ ← randomSubFormula atoms maxParamSize
    return (Formula.some_future φ).imp (Formula.untl φ Formula.top)
  -- Temporal-modal interaction schemata (Task 272, 8 new schemata)
  | 14 => do
    -- modal_future(φ): □φ → G(□φ) (from temp_future_derived / box_to_future via MF+MT)
    let φ ← randomSubFormula atoms maxParamSize
    return φ.box.imp φ.box.all_future
  | 15 => do
    -- modal_past(φ): □φ → H(□φ) (past dual of modal_future)
    let φ ← randomSubFormula atoms maxParamSize
    return φ.box.imp φ.box.all_past
  | 16 => do
    -- perpetuity_1(φ): □φ → always(φ)
    let φ ← randomSubFormula atoms maxParamSize
    return φ.box.imp φ.always
  | 17 => do
    -- perpetuity_2(φ): sometimes(φ) → ◇φ
    let φ ← randomSubFormula atoms maxParamSize
    return φ.sometimes.imp φ.diamond
  | 18 => do
    -- G_distribution(φ, ψ): G(φ → ψ) → (Gφ → Gψ)
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return (φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)
  | 19 => do
    -- H_distribution(φ, ψ): H(φ → ψ) → (Hφ → Hψ)
    let φ ← randomSubFormula atoms maxParamSize
    let ψ ← randomSubFormula atoms maxParamSize
    return (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past)
  | 20 => do
    -- always_to_present(φ): always(φ) → φ
    let φ ← randomSubFormula atoms maxParamSize
    return φ.always.imp φ
  | _ => do
    -- present_to_sometimes(φ): φ → sometimes(φ)
    let φ ← randomSubFormula atoms maxParamSize
    return φ.imp φ.sometimes

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
Check if a formula matches the ex_falso pattern: `⊥ → φ`.
-/
private def isExFalso : Formula → Bool
  | .imp .bot _ => true
  | _ => false

/--
Theorem seed formulas from task 212's proven theorems.
These are guaranteed valid and provide diverse structural patterns.
Uses atoms p, q, r for concrete instantiation.
-/
private def theoremSeedFormulas : List Formula :=
  let p := Formula.atom (Atom.mk_base "p")
  let q := Formula.atom (Atom.mk_base "q")
  let r := Formula.atom (Atom.mk_base "r")
  [
    -- Combinators (8)
    p.imp p,                                                  -- identity
    (q.imp r).imp ((p.imp q).imp (p.imp r)),                 -- b_combinator
    (p.imp (q.imp r)).imp (q.imp (p.imp r)),                 -- flip
    p.imp ((p.imp q).imp q),                                 -- app1
    p.imp (q.imp ((p.imp (q.imp r)).imp r)),                 -- app2
    p.imp (q.imp (p.and q)),                                 -- pairing
    p.imp p.neg.neg,                                         -- dni
    p.box.imp p.box.all_future,                              -- temp_future_derived
    -- ModalS4 (2)
    p.box.diamond.box.imp p.box,                             -- s4_box_diamond_box
    p.diamond.imp p.box.diamond.diamond,                     -- s4_diamond_box_diamond
    -- ModalS5 (6)
    p.box.imp p.diamond,                                     -- t_box_to_diamond
    (p.imp q).box.imp (p.neg.imp q.neg).neg.box,             -- box_contrapose (□(A→B) → □(¬B→¬A))
    (p.imp q).box.imp (p.diamond.imp q.diamond),             -- k_dist_diamond
    (p.and p.neg).box.imp Formula.bot,                       -- t_box_consistency
    p.box.diamond.imp p.box,                                 -- s5_diamond_box (simplified half)
    p.box.diamond.imp p,                                     -- s5_diamond_box_to_truth
    -- TemporalDerived (5 unique — 2 duplicates removed)
    p.imp (p.some_past.all_future),                          -- connect_future_thm
    p.imp (p.some_future.all_past),                          -- connect_past_thm
    p.all_future.imp ((p.all_future.imp p.all_future).all_future),  -- G_implies_G_id
    (Formula.untl q p).imp q.some_future,                    -- until_implies_some_future
    (Formula.snce q p).imp q.some_past,                      -- since_implies_some_past
    -- Helpers (3)
    p.box.imp p.all_future,                                  -- box_to_future
    p.box.imp p.all_past,                                    -- box_to_past
    p.box.imp p,                                             -- box_to_present (= modal_t)
    -- Principles (10)
    p.box.imp p.always,                                      -- perpetuity_1
    p.diamond.diamond.imp p.diamond,                         -- diamond_4
    p.diamond.imp p.diamond.box,                             -- modal_5
    p.sometimes.diamond.imp p.diamond,                       -- perpetuity_2
    p.box.imp p.all_past.box,                                -- box_to_box_past
    p.box.imp p.always.box,                                  -- perpetuity_3
    p.sometimes.diamond.imp p.diamond,                       -- perpetuity_4 (= perpetuity_2)
    p.imp p.diamond.box,                                     -- mb_diamond (= modal_b)
    p.diamond.box.imp p.diamond.box.all_future,              -- box_diamond_to_future_box_diamond
    p.diamond.box.imp p.diamond.box.all_past,                -- box_diamond_to_past_box_diamond
    -- Bimodal interaction seeds (Task 272, 14 new)
    -- G/H distribution with concrete formulas
    (p.imp q).all_future.imp (p.all_future.imp q.all_future),  -- G_distribution(p,q)
    (p.imp q).all_past.imp (p.all_past.imp q.all_past),        -- H_distribution(p,q)
    -- Conjunction elimination from compound temporal operators
    p.always.imp p,                                            -- always_to_present
    p.imp p.sometimes,                                         -- present_to_sometimes
    p.weak_future.imp p,                                       -- weak_future_left
    p.weak_future.imp p.all_future,                            -- weak_future_right
    p.weak_past.imp p,                                         -- weak_past_left
    p.weak_past.imp p.all_past,                                -- weak_past_right
    p.always.imp p.all_future,                                 -- always_imp_all_future
    p.always.imp p.all_past,                                   -- always_imp_all_past
    -- Bimodal interactions mixing box with G/H/F/P
    p.box.imp p.box.all_past,                                  -- box_to_box_past (duplicate check ok)
    p.box.imp p.always,                                        -- perpetuity_1 (duplicate check ok)
    p.sometimes.imp p.diamond,                                 -- perpetuity_2_alt (sometimes -> diamond)
    -- Deep temporal chains
    p.imp (p.some_past.some_future.all_past.all_future)        -- connect_future_chain(p)
  ]

/--
Generate a batch of guaranteed-valid formulas using fixpoint Nec/MP closure.

1. **Seed pool**: Generate `seedCount` axiom instances (all valid by construction)
   plus theorem seed formulas from task 212's proven theorems.
2. **Ex_falso cap**: Limit ex_falso-pattern formulas to at most 20% of the seed pool.
3. **Fixpoint closure**: Iterate Nec+MP rounds until no new formulas added,
   pool exceeds 10,000, or 10 rounds completed.
   - Uses `Std.HashSet` + `Array` pool for O(1) membership/dedup (task 251).
   - Uses implication-index `Std.HashMap` for O(n) MP closure (task 251).
   - Uses early complexity filtering to bound pool growth (task 251).
4. **Filter**: Keep formulas within target complexity range.
-/
partial def generateValidBatch (seedCount : Nat) (maxComplexity : Nat)
    (atoms : List Atom) : IO (List Formula) := do
  let batchStartMs ← IO.monoMsNow
  -- Pool data structure: HashSet for O(1) membership, Array for ordered iteration
  let mut poolSet : Std.HashSet Formula := {}
  let mut poolArr : Array Formula := #[]
  -- Helper: insert into pool only if not already present
  let addToPool := fun (s : Std.HashSet Formula) (a : Array Formula) (φ : Formula) =>
    if s.contains φ then (s, a)
    else (s.insert φ, a.push φ)
  -- Phase 1: Seed pool with axiom instances + theorem seeds
  let maxParamSize := max 1 (maxComplexity / 3)
  let progressInterval := max 1 (seedCount / 10)
  let mut seedIdx : Nat := 0
  for _ in List.range seedCount do
    let axiomInst ← instantiateAxiom atoms maxParamSize
    let (s', a') := addToPool poolSet poolArr axiomInst
    poolSet := s'; poolArr := a'
    seedIdx := seedIdx + 1
    if seedIdx % progressInterval == 0 then
      let elapsedMs ← IO.monoMsNow
      let elapsedSecs := (elapsedMs - batchStartMs) / 1000
      IO.println s!"[valid] Seeding: {seedIdx}/{seedCount} axiom instances, pool: {poolArr.size} unique, {elapsedSecs}s elapsed"
  -- Add theorem seed formulas
  for φ in theoremSeedFormulas do
    let (s', a') := addToPool poolSet poolArr φ
    poolSet := s'; poolArr := a'
  -- Phase 2: Cap ex_falso instances to at most 20% of pool
  let exFalsoCount := poolArr.foldl (fun acc φ => if isExFalso φ then acc + 1 else acc) 0
  let maxExFalso := poolArr.size / 5  -- 20%
  if exFalsoCount > maxExFalso then
    -- Rebuild pool keeping non-ex_falso + limited ex_falso
    let mut newSet : Std.HashSet Formula := {}
    let mut newArr : Array Formula := #[]
    let mut exFalsoKept : Nat := 0
    for φ in poolArr do
      if isExFalso φ then
        if exFalsoKept < maxExFalso then
          let (s', a') := addToPool newSet newArr φ
          newSet := s'; newArr := a'
          exFalsoKept := exFalsoKept + 1
      else
        let (s', a') := addToPool newSet newArr φ
        newSet := s'; newArr := a'
    poolSet := newSet; poolArr := newArr
    -- Generate replacement non-ex_falso axiom instances
    let replacements := exFalsoCount - maxExFalso
    for _ in List.range replacements do
      let mut axiomInst ← instantiateAxiom atoms maxParamSize
      -- Retry up to 5 times to get a non-ex_falso instance
      let mut retries : Nat := 0
      while isExFalso axiomInst && retries < 5 do
        axiomInst ← instantiateAxiom atoms maxParamSize
        retries := retries + 1
      let (s', a') := addToPool poolSet poolArr axiomInst
      poolSet := s'; poolArr := a'
  -- Phase 3: Fixpoint Nec/MP closure
  let mut round : Nat := 0
  let mut prevSize : Nat := 0
  while round < 10 && poolArr.size < 10000 do
    prevSize := poolArr.size
    -- Necessitation round: □φ for each φ in pool
    let snapshot := poolArr
    for φ in snapshot do
      let boxPhi := generateValidFromNec φ
      if boxPhi.complexity ≤ maxComplexity then
        let (s', a') := addToPool poolSet poolArr boxPhi
        poolSet := s'; poolArr := a'
    -- MP round: implication-index for O(n) closure
    -- Build index: for each (lhs → rhs) in pool, map lhs ↦ [rhs, ...]
    let mpSnapshot := poolArr
    let mut impIndex : Std.HashMap Formula (Array Formula) := {}
    for ψ in mpSnapshot do
      match ψ with
      | .imp lhs rhs =>
        match impIndex[lhs]? with
        | some arr => impIndex := impIndex.insert lhs (arr.push rhs)
        | none => impIndex := impIndex.insert lhs #[rhs]
      | _ => pure ()
    -- Single pass: for each φ in pool, look up consequents via index
    for φ in mpSnapshot do
      match impIndex[φ]? with
      | some rhsArr =>
        for rhs in rhsArr do
          if rhs.complexity ≤ maxComplexity then
            let (s', a') := addToPool poolSet poolArr rhs
            poolSet := s'; poolArr := a'
      | none => pure ()
    round := round + 1
    -- Check growth rate: stop if less than 1% growth
    let growth := poolArr.size - prevSize
    let growthRate := if prevSize > 0 then growth * 100 / prevSize else 100
    let closureElapsedMs ← IO.monoMsNow
    let closureElapsedSecs := (closureElapsedMs - batchStartMs) / 1000
    IO.println s!"[valid] Closure round {round}: pool {prevSize} -> {poolArr.size} (+{growth}, {growthRate}% growth), {closureElapsedSecs}s elapsed"
    if growthRate < 1 then
      IO.println s!"[valid] Closure converged at round {round} ({growthRate}% growth < 1%)"
      break
  -- Phase 4: Filter by complexity range
  let filtered := poolArr.toList.filter fun φ => φ.complexity ≥ 3 && φ.complexity ≤ maxComplexity
  return filtered

/--
Deduplicate a list of formulas using a HashMap for O(n) instead of O(n^2).
Uses `Formula` hash as the key since `Formula` derives `Hashable`.
-/
private def hashDedup (formulas : List Formula) : List Formula :=
  let (_, result) := formulas.foldl
    (fun (acc : Std.HashMap UInt64 Unit × Array Formula) φ =>
      let (seen, deduped) := acc
      let h := hash φ
      if seen.contains h then (seen, deduped)
      else (seen.insert h (), deduped.push φ))
    ({}, #[])
  result.toList

/--
Stratified enumeration: for each complexity level, enumerate exhaustively or sample
up to a per-level quota. Levels not in the quota list default to exhaustive.
A quota of 0 means exhaustive enumeration at that level.
-/
private def enumerateStratified (params : EnumParams) : List Formula :=
  let quotaMap := params.stratifiedQuotas.foldl
    (fun (m : Std.HashMap Nat Nat) (k, v) => m.insert k v) {}
  let (_, allFormulas) := (List.range params.maxComplexity).foldl
    (fun (acc : EnumCache × Array Formula) i =>
      let level := i + 1
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget params.atoms level params.maxModalDepth
                                              params.maxTemporalDepth cache
      let filtered := exact.filter passesFilter
      -- Check if there's a quota for this level
      let levelFormulas := match quotaMap[level]? with
        | some 0 => filtered  -- 0 means exhaustive
        | some quota =>
          if filtered.size ≤ quota then filtered
          else
            -- Deterministic sampling using LCG with level as seed
            let rng := LCGState.init (level * 12345 + 42)
            deterministicSample filtered quota rng
        | none => filtered  -- no quota entry = exhaustive
      (cache', formulas ++ levelFormulas))
    ({}, #[])
  let result := allFormulas.toList
  if params.maxFormulas == 0 then result else result.take params.maxFormulas
where
  /-- Deterministically sample `count` elements from an array using LCG. -/
  deterministicSample (xs : Array Formula) (count : Nat) (rng : LCGState) : Array Formula :=
    let n := xs.size
    if n ≤ count then xs
    else
      -- Fisher-Yates partial shuffle: select `count` random elements
      let (selected, _) := (List.range count).foldl
        (fun (acc : Array Formula × LCGState) _ =>
          let (picked, r) := acc
          let (r', idx) := r.randBound n
          match xs[idx]? with
          | some φ => (picked.push φ, r')
          | none => (picked, r'))
        (#[], rng)
      selected

/-!
## Checkpoint and Incremental Output (Task 283 Phase 2)

Provides per-level JSONL flushing and checkpoint resume so that a crash during
c8+ enumeration does not lose hours of work.
-/

/--
Checkpoint state for incremental enumeration.
Records which levels have been completed so that enumeration can resume
after a crash.
-/
structure CheckpointState where
  /-- Number of complexity levels fully completed. -/
  completedLevels : Nat
  /-- Cumulative formula count across completed levels. -/
  formulaCount : Nat
  /-- Path to the JSONL output file being written. -/
  outputPath : System.FilePath
  deriving Repr, Inhabited

/-- Write a checkpoint marker file recording the completion of a level.
    Format: one line per completed level with "level,formulaCount,elapsedMs". -/
private def writeCheckpointMarker (checkpointDir : System.FilePath) (level : Nat)
    (cumulativeCount : Nat) (elapsedMs : Nat) : IO Unit := do
  let markerPath := checkpointDir / "checkpoint.csv"
  let line := s!"{level},{cumulativeCount},{elapsedMs}\n"
  -- Append to marker file
  let h ← IO.FS.Handle.mk markerPath .append
  h.putStr line
  h.flush

/-- Read the checkpoint marker file and return the highest completed level.
    Returns (completedLevels, cumulativeFormulaCount) or (0, 0) if no checkpoint. -/
private def readCheckpoint (checkpointDir : System.FilePath) : IO (Nat × Nat) := do
  let markerPath := checkpointDir / "checkpoint.csv"
  let fileExists ← markerPath.pathExists
  if !fileExists then return (0, 0)
  let content ← IO.FS.readFile markerPath
  let lines := content.splitOn "\n" |>.filter (· ≠ "")
  let mut maxLevel : Nat := 0
  let mut lastCount : Nat := 0
  for line in lines do
    let parts := line.splitOn ","
    match parts with
    | [levelStr, countStr, _] =>
      match levelStr.toNat?, countStr.toNat? with
      | some l, some c =>
        if l > maxLevel then
          maxLevel := l
          lastCount := c
      | _, _ => pure ()
    | _ => pure ()
  return (maxLevel, lastCount)

/-- Write formulas for a level to a JSONL file (one `repr` per line).
    Appends to existing file so that levels accumulate incrementally. -/
private def writeFormulaJSONL (outputPath : System.FilePath)
    (formulas : Array Formula) (level : Nat) : IO Unit := do
  let h ← IO.FS.Handle.mk outputPath .append
  for φ in formulas do
    h.putStr s!"\{\"level\":{level},\"formula\":\"{repr φ}\"}\n"
  h.flush

/--
Canonicalize and deduplicate an array of formulas, threading a seen-set for
cross-level deduplication. Returns the deduplicated array and updated seen set.
Each formula is canonicalized under atom permutation before checking membership.
-/
private def canonicalDedupArray (formulas : Array Formula)
    (seen : Std.HashSet Formula) : Array Formula × Std.HashSet Formula :=
  formulas.foldl (fun (acc : Array Formula × Std.HashSet Formula) φ =>
    let (deduped, s) := acc
    let canonical := AtomCanonicalization.canonicalize φ
    if s.contains canonical then (deduped, s)
    else (deduped.push canonical, s.insert canonical)
  ) (#[], seen)

/--
IO wrapper for exhaustive enumeration with per-complexity-level progress.

Iterates complexity levels 1 to `maxComplexity`, calling `enumExactBudget` (pure)
per level with shared `EnumCache`, applying `passesFilter`, and emitting progress
after each level. Caps at `maxFormulas`.

When `checkpointDir` is set, writes per-level JSONL output and checkpoint markers
for crash resume. When `resume` is true, skips levels already recorded in the
checkpoint file.

When `canonicalDedup` is true, applies atom-permutation canonicalization and
cross-level deduplication, yielding ~4.58x formula count reduction.
-/
private def enumerateWithProgress (params : EnumParams) : IO (List Formula) := do
  let startMs ← IO.monoMsNow
  -- Check for resume state
  let (resumeLevel, resumeCount) ← match params.checkpointDir with
    | some dir =>
      if params.resume then do
        let (rl, rc) ← readCheckpoint dir
        if rl > 0 then
          IO.println s!"[enum] Resuming from checkpoint: {rl} levels completed, {rc} formulas"
        pure (rl, rc)
      else pure (0, 0)
    | none => pure (0, 0)
  -- Ensure checkpoint directory exists if specified
  match params.checkpointDir with
  | some dir => IO.FS.createDirAll dir
  | none => pure ()
  let mut cache : EnumCache := {}
  let mut allFormulas : Array Formula := #[]
  let mut totalCount : Nat := resumeCount
  let mut canonicalSeen : Std.HashSet Formula := {}
  for i in List.range params.maxComplexity do
    let level := i + 1
    let (exact, cache') := enumExactBudget params.atoms level params.maxModalDepth
                                           params.maxTemporalDepth cache
    cache := cache'
    -- If resuming and this level is already done, just update cache and skip
    if level ≤ resumeLevel then
      continue
    let filtered := exact.filter passesFilter
    -- Apply canonical dedup if enabled
    let rawCount := filtered.size
    let levelFormulas ← if params.canonicalDedup then do
      let (deduped, seen') := canonicalDedupArray filtered canonicalSeen
      canonicalSeen := seen'
      pure deduped
    else
      pure filtered
    allFormulas := allFormulas ++ levelFormulas
    totalCount := totalCount + levelFormulas.size
    let elapsedMs ← IO.monoMsNow
    let elapsed := elapsedMs - startMs
    let elapsedSecs := elapsed / 1000
    let rate := if elapsedSecs > 0 then totalCount / elapsedSecs else totalCount
    -- ETA estimation based on completed levels
    let remainingLevels := params.maxComplexity - level
    let avgMsPerLevel := if level > resumeLevel then elapsed / (level - resumeLevel) else 0
    let etaSecs := remainingLevels * avgMsPerLevel / 1000
    let dedupStr := if params.canonicalDedup then s!" (raw: {rawCount}, deduped: {levelFormulas.size})" else ""
    IO.println s!"[enum] Level {level}/{params.maxComplexity}: {levelFormulas.size} formulas{dedupStr} (cumulative: {totalCount}), {elapsedSecs}s elapsed, {rate} formulas/sec, ETA: {etaSecs}s"
    -- Write JSONL output and checkpoint marker if checkpoint dir is set
    match params.checkpointDir with
    | some dir =>
      let jsonlPath := dir / "formulas.jsonl"
      writeFormulaJSONL jsonlPath levelFormulas level
      writeCheckpointMarker dir level totalCount elapsed
    | none => pure ()
    if params.maxFormulas > 0 && totalCount ≥ params.maxFormulas then
      break
  let result := allFormulas.toList
  if params.maxFormulas == 0 then return result else return result.take params.maxFormulas

/-- Deterministically sample `count` elements from an array using LCG.
    Extracted as a top-level helper for reuse by both pure and IO stratified enumeration. -/
private def deterministicSampleFormulas (xs : Array Formula) (count : Nat) (rng : LCGState)
    : Array Formula :=
  let n := xs.size
  if n ≤ count then xs
  else
    let (selected, _) := (List.range count).foldl
      (fun (acc : Array Formula × LCGState) _ =>
        let (picked, r) := acc
        let (r', idx) := r.randBound n
        match xs[idx]? with
        | some φ => (picked.push φ, r')
        | none => (picked, r'))
      (#[], rng)
    selected

/--
IO wrapper for stratified enumeration with per-complexity-level progress.

Mirrors `enumerateStratified` logic but with per-level IO progress reporting.
-/
private def enumerateStratifiedWithProgress (params : EnumParams) : IO (List Formula) := do
  let startMs ← IO.monoMsNow
  let quotaMap := params.stratifiedQuotas.foldl
    (fun (m : Std.HashMap Nat Nat) (k, v) => m.insert k v) {}
  let mut cache : EnumCache := {}
  let mut allFormulas : Array Formula := #[]
  let mut totalCount : Nat := 0
  for i in List.range params.maxComplexity do
    let level := i + 1
    let (exact, cache') := enumExactBudget params.atoms level params.maxModalDepth
                                           params.maxTemporalDepth cache
    cache := cache'
    let filtered := exact.filter passesFilter
    let levelFormulas := match quotaMap[level]? with
      | some 0 => filtered
      | some quota =>
        if filtered.size ≤ quota then filtered
        else
          let rng := LCGState.init (level * 12345 + 42)
          deterministicSampleFormulas filtered quota rng
      | none => filtered
    allFormulas := allFormulas ++ levelFormulas
    totalCount := totalCount + levelFormulas.size
    let elapsedMs ← IO.monoMsNow
    let elapsedSecs := (elapsedMs - startMs) / 1000
    let rate := if elapsedSecs > 0 then totalCount / elapsedSecs else totalCount
    let quotaStr := match quotaMap[level]? with
      | some 0 => " [exhaustive]"
      | some q => s!" [quota: {q}, from {filtered.size}]"
      | none => " [exhaustive]"
    IO.println s!"[enum] Level {level}/{params.maxComplexity}: {levelFormulas.size} formulas{quotaStr} (cumulative: {totalCount}), {elapsedSecs}s elapsed, {rate} formulas/sec"
    if params.maxFormulas > 0 && totalCount ≥ params.maxFormulas then
      break
  let result := allFormulas.toList
  if params.maxFormulas == 0 then return result else return result.take params.maxFormulas

/--
Generate formulas according to the specified sampling mode.

Combines up to three formula sources:
1. Exhaustive/random/hybrid/stratified enumeration
2. Axiom-seeded valid formulas (Task 210): If `validSeedCount > 0`,
   generates guaranteed-valid formulas via axiom instantiation, necessitation,
   and modus ponens closure. These are mixed in to boost the valid fraction.

All sources are deduplicated using HashMap-based dedup before returning.
Emits progress reporting for long-running enumeration and valid-seed phases.
-/
partial def generateFormulas (params : EnumParams) : IO (List Formula) := do
  let modeStr := match params.samplingMode with
    | .exhaustive => "exhaustive"
    | .random => "random"
    | .hybrid => "hybrid"
    | .stratified => "stratified"
  IO.println s!"[gen] Starting formula enumeration ({modeStr} mode, max complexity {params.maxComplexity})..."
  -- Step 1: Generate formulas from the selected sampling mode
  let enumStartMs ← IO.monoMsNow
  let enumerated ← match params.samplingMode with
    | .exhaustive => enumerateWithProgress params
    | .random => sampleRandom params
    | .hybrid =>
      let exhaustiveParams := { params with maxComplexity := min 5 params.maxComplexity,
                                            maxFormulas := params.maxFormulas / 2 }
      let exhaustive ← enumerateWithProgress exhaustiveParams
      let remaining := params.maxFormulas - exhaustive.length
      if remaining > 0 then do
        let randomParams := { params with maxFormulas := remaining }
        let random ← sampleRandom randomParams
        pure (hashDedup (exhaustive ++ random))
      else
        pure exhaustive
    | .stratified => enumerateStratifiedWithProgress params
  let enumEndMs ← IO.monoMsNow
  let enumElapsed := (enumEndMs - enumStartMs) / 1000
  IO.println s!"[gen] Enumeration complete: {enumerated.length} formulas in {enumElapsed}s"
  -- Step 2: Generate axiom-seeded valid formulas if requested
  let validSeeds ← if params.validSeedCount > 0 then do
    IO.println s!"[gen] Starting valid-seed generation ({params.validSeedCount} seeds)..."
    let seedStartMs ← IO.monoMsNow
    let seeds ← generateValidBatch params.validSeedCount params.maxComplexity params.atoms
    let seedEndMs ← IO.monoMsNow
    let seedElapsed := (seedEndMs - seedStartMs) / 1000
    IO.println s!"[gen] Valid-seed generation complete: {seeds.length} valid formulas in {seedElapsed}s"
    pure seeds
  else
    pure []
  -- Step 3: Combine and deduplicate all sources using HashMap
  let combined := hashDedup (enumerated ++ validSeeds)
  let capped := if params.maxFormulas == 0 then combined else combined.take params.maxFormulas
  IO.println s!"[gen] Total: {capped.length} unique formulas after deduplication"
  return capped

/-!
## Bimodal Interaction Filter and Dataset Generation (Task 272 Phase 4)

Identifies and generates formulas that contain BOTH modal (box/diamond) and
derived temporal (G/H/F/P) operators, enabling targeted generation of formulas
that are likely to require temporal axioms in their proofs.
-/

/-- Check if a formula contains at least one box operator. -/
private def hasBox : Formula → Bool
  | .atom _ => false
  | .bot => false
  | .imp a b => hasBox a || hasBox b
  | .box _ => true
  | .untl a b => hasBox a || hasBox b
  | .snce a b => hasBox a || hasBox b

/-- Check if a formula contains at least one derived temporal operator pattern
    (G, H, F, or P recognized by their primitive expansion). -/
private def hasDerivedTemporal : Formula → Bool
  | .atom _ => false
  | .bot => false
  | .box a => hasDerivedTemporal a
  -- Check for G/H patterns: ¬F(¬φ) or ¬P(¬φ) = imp(untl/snce(imp _ bot, imp bot bot), bot)
  | .imp inner .bot =>
    match inner with
    | .untl (.imp _ .bot) (.imp .bot .bot) => true  -- G pattern
    | .snce (.imp _ .bot) (.imp .bot .bot) => true  -- H pattern
    | _ => hasDerivedTemporal inner
  | .imp a b => hasDerivedTemporal a || hasDerivedTemporal b
  -- Check for F/P patterns: untl/snce(φ, ⊤)
  | .untl _ (.imp .bot .bot) => true   -- F pattern
  | .untl a b => hasDerivedTemporal a || hasDerivedTemporal b
  | .snce _ (.imp .bot .bot) => true   -- P pattern
  | .snce a b => hasDerivedTemporal a || hasDerivedTemporal b

/--
Check if a formula has bimodal interaction: contains BOTH a box operator
and at least one derived temporal operator (G/H/F/P pattern).
-/
def hasBimodalInteraction (φ : Formula) : Bool :=
  hasBox φ && hasDerivedTemporal φ

/--
Generate a bimodal interaction dataset slice.

Enumerates formulas at the specified complexity levels, filters to those
containing both modal and temporal operators, and returns the filtered list
along with diversity statistics.

**Usage**: Call with complexity levels 5-7 to generate targeted bimodal
interaction formulas for temporal axiom usage verification.
-/
def generateBimodalSlice (atoms : List Atom) (maxModal maxTemporal : Nat)
    (complexityLevels : List Nat) : List Formula × DiversitySummary :=
  let (_, allFormulas) := complexityLevels.foldl
    (fun (acc : EnumCache × Array Formula) level =>
      let (cache, formulas) := acc
      let (exact, cache') := enumExactBudget atoms level maxModal maxTemporal cache
      let bimodal := exact.filter hasBimodalInteraction
      (cache', formulas ++ bimodal))
    ({}, #[])
  let result := allFormulas.toList
  let summary := diversitySummary result
  (result, summary)

/-!
## Two-Phase Parallel Enumeration and Pipeline Overlap (Task 283 Phase 5)

Parallelizes level-N cross-product computation across multiple cores and
enables labeling to begin while enumeration of later levels continues.

**Design**:
- Phase A (sequential, fast): Pre-compute all sub-levels 1..(N-1) into a read-only `EnumCache`
- Phase B (parallel): For each binary partition (leftSize + rightSize = N-1),
  spawn an independent task that reads the immutable cache and produces cross-products
-/

/--
Configuration for parallel enumeration.
-/
structure ParallelEnumConfig where
  /-- Number of worker tasks for parallel cross-product computation. Default 8. -/
  numWorkers : Nat := 8
  /-- Minimum complexity level to enable parallel cross-product. Below this,
      sequential enumeration is used (overhead of task spawning exceeds benefit). -/
  parallelThreshold : Nat := 7
  deriving Repr, Inhabited

/--
Notification emitted when a complexity level finishes enumeration.
Used for pipeline overlap: downstream labeling can begin while enumeration
of later levels continues.
-/
structure LevelComplete where
  /-- The complexity level that was completed. -/
  level : Nat
  /-- The formulas enumerated at this level (post-filter, post-dedup). -/
  formulas : Array Formula
  /-- Wall-clock milliseconds elapsed for this level. -/
  elapsedMs : Nat
  deriving Repr, Inhabited

/--
Compute cross-product formulas for a single binary partition (leftSize, rightSize)
reading from an immutable cache. This is the unit of work for parallel enumeration.

Returns an array of formulas for all binary constructors (imp, untl, snce) at
this partition.
-/
private def partitionCrossProduct (atoms : List Atom) (modalBudget temporalBudget : Nat)
    (leftSize rightSize : Nat) (cache : EnumCache) : Array Formula :=
  if rightSize < 1 then #[]
  else
    let (lefts, _) := enumExactHelper atoms modalBudget temporalBudget leftSize cache
    let (rights, _) := enumExactHelper atoms modalBudget temporalBudget rightSize cache
    -- Implication cross-product with structural pruning
    let imps := lefts.foldl (fun (acc : Array Formula) l =>
      rights.foldl (fun (acc' : Array Formula) r =>
        let f := Formula.imp l r
        if structurallyTrivial f then acc' else acc'.push f
      ) acc
    ) (Array.mkEmpty (lefts.size * rights.size))
    -- Temporal cross-product
    let temporal := if temporalBudget > 0 then
      let (tLefts, _) := enumExactHelper atoms modalBudget (temporalBudget - 1) leftSize cache
      let (tRights, _) := enumExactHelper atoms modalBudget (temporalBudget - 1) rightSize cache
      let untls := tLefts.foldl (fun (acc : Array Formula) l =>
        tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.untl l r)) acc
      ) (Array.mkEmpty (tLefts.size * tRights.size))
      let snces := tLefts.foldl (fun (acc : Array Formula) l =>
        tRights.foldl (fun (acc' : Array Formula) r => acc'.push (Formula.snce l r)) acc
      ) (Array.mkEmpty (tLefts.size * tRights.size))
      untls ++ snces
    else #[]
    imps ++ temporal

/--
Enumerate formulas at a single complexity level using parallel cross-product
computation. Pre-computes all sub-levels sequentially (Phase A), then spawns
parallel tasks for each binary partition (Phase B).

Falls back to sequential enumeration if the level is below `parallelThreshold`.
-/
private def enumerateLevelParallel (atoms : List Atom) (modalBudget temporalBudget level : Nat)
    (cache : EnumCache) (config : ParallelEnumConfig) : IO (Array Formula × EnumCache) := do
  -- Phase A: Pre-compute all sub-levels 1..(level-1) into the cache sequentially
  -- This is fast since sub-levels are cached from previous iterations
  let mut buildCache := cache
  for i in List.range (level - 1) do
    let subLevel := i + 1
    let (_, c') := enumExactHelper atoms modalBudget temporalBudget subLevel buildCache
    buildCache := c'
  let immutableCache := buildCache
  -- Check the key for this level -- it may already be cached
  let key := (level, modalBudget, temporalBudget)
  match immutableCache[key]? with
  | some result => return (result, immutableCache)
  | none =>
  -- If below threshold, use sequential enumeration
  if level < config.parallelThreshold then
    let (result, cache') := enumExactHelper atoms modalBudget temporalBudget level immutableCache
    return (result, cache')
  else
    -- Phase B: Parallel cross-product for binary constructors
    let childBudget := level - 1
    -- Generate partition list: (leftSize, rightSize) pairs
    let partitions := (List.range childBudget).filterMap fun i =>
      let leftSize := i + 1
      let rightSize := childBudget - leftSize
      if rightSize < 1 then none else some (leftSize, rightSize)
    -- Spawn parallel tasks for each partition
    IO.println s!"[parallel] Level {level}: spawning {partitions.length} partition tasks"
    let mut tasks : Array (Task (Except IO.Error (Array Formula))) := #[]
    for (leftSize, rightSize) in partitions do
      let task ← IO.asTask (prio := .dedicated) do
        pure (partitionCrossProduct atoms modalBudget temporalBudget leftSize rightSize immutableCache)
      tasks := tasks.push task
    -- Collect results from all tasks
    let mut binaryFormulas : Array Formula := #[]
    let mut partIdx : Nat := 0
    for task in tasks do
      let result ← IO.ofExcept (← IO.wait task)
      binaryFormulas := binaryFormulas ++ result
      partIdx := partIdx + 1
    -- Unary: box formulas (sequential, fast)
    let boxes := if modalBudget > 0 then
      let (children, _) := enumExactHelper atoms (modalBudget - 1) temporalBudget childBudget immutableCache
      children.foldl (fun (acc : Array Formula) child =>
        let f := Formula.box child
        if structurallyTrivial f then acc else acc.push f
      ) #[]
    else #[]
    -- Derived temporal unary operators (sequential, fast)
    let derivedTemporal := if temporalBudget > 0 && level > 1 then
      let childSize := level - 1
      let (children, _) := enumExactHelper atoms modalBudget (temporalBudget - 1) childSize immutableCache
      children.map Formula.some_future
        ++ children.map Formula.some_past
        ++ children.map Formula.all_future
        ++ children.map Formula.all_past
    else #[]
    let result := boxes ++ derivedTemporal ++ binaryFormulas
    -- Store in cache for subsequent use
    let finalCache := immutableCache.insert key result
    return (result, finalCache)

/--
Exhaustive enumeration with parallel cross-product computation and pipeline
overlap. For each complexity level, spawns parallel tasks for binary partitions
and invokes the `onLevelComplete` callback when a level finishes.

**Pipeline overlap**: The callback receives completed levels immediately,
allowing downstream processing (e.g., labeling) to begin while enumeration
of later levels continues.
-/
def enumerateWithPipeline (params : EnumParams) (parallelConfig : ParallelEnumConfig)
    (onLevelComplete : LevelComplete → IO Unit) : IO (List Formula) := do
  let startMs ← IO.monoMsNow
  let mut cache : EnumCache := {}
  let mut allFormulas : Array Formula := #[]
  let mut totalCount : Nat := 0
  let mut canonicalSeen : Std.HashSet Formula := {}
  for i in List.range params.maxComplexity do
    let level := i + 1
    let levelStartMs ← IO.monoMsNow
    let (exact, cache') ← enumerateLevelParallel params.atoms params.maxModalDepth
                            params.maxTemporalDepth level cache parallelConfig
    cache := cache'
    let filtered := exact.filter passesFilter
    -- Apply canonical dedup if enabled
    let rawCount := filtered.size
    let levelFormulas ← if params.canonicalDedup then do
      let (deduped, seen') := canonicalDedupArray filtered canonicalSeen
      canonicalSeen := seen'
      pure deduped
    else
      pure filtered
    allFormulas := allFormulas ++ levelFormulas
    totalCount := totalCount + levelFormulas.size
    let levelEndMs ← IO.monoMsNow
    let levelElapsed := levelEndMs - levelStartMs
    let elapsedSecs := (levelEndMs - startMs) / 1000
    let rate := if elapsedSecs > 0 then totalCount / elapsedSecs else totalCount
    let dedupStr := if params.canonicalDedup then s!" (raw: {rawCount}, deduped: {levelFormulas.size})" else ""
    IO.println s!"[parallel] Level {level}/{params.maxComplexity}: {levelFormulas.size} formulas{dedupStr} (cumulative: {totalCount}), {levelElapsed}ms this level, {elapsedSecs}s total, {rate} formulas/sec"
    -- Fire pipeline overlap callback
    onLevelComplete { level, formulas := levelFormulas, elapsedMs := levelElapsed }
    -- Write checkpoint if enabled
    match params.checkpointDir with
    | some dir =>
      let jsonlPath := dir / "formulas.jsonl"
      writeFormulaJSONL jsonlPath levelFormulas level
      writeCheckpointMarker dir level totalCount (levelEndMs - startMs)
    | none => pure ()
    if params.maxFormulas > 0 && totalCount ≥ params.maxFormulas then
      break
  let result := allFormulas.toList
  if params.maxFormulas == 0 then return result else return result.take params.maxFormulas

end Bimodal.Automation
