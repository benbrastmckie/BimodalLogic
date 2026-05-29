import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.DataExport

/-!
# Dataset Validator: Conformance Tests, Diversity Metrics & Feasibility Gate

This module validates dataset quality, diversity, and signal informativeness.
It provides conformance tests (known valid/invalid formulas), diversity metrics
computation, and a feasibility gate to determine whether to proceed to value
network training.

## Main Definitions

### Conformance Testing
- `knownValidFormulas`: Curated list of known valid TM formulas (BX axiom instances)
- `knownInvalidFormulas`: Curated list of known non-theorems
- `ConformanceResult`: Result of a single conformance test
- `runConformanceTests`: Run both valid and invalid tests, report results

### Diversity Metrics
- `DiversityReport`: Comprehensive diversity metrics for a labeled dataset
- `computeDiversityReport`: Compute diversity metrics from labeled formulas

### Feasibility Gate
- `FeasibilityResult`: Gate result with pass/fail and specific metrics
- `runFeasibilityGate`: Enumerate, label, compute diversity, evaluate gate
- `runFullValidation`: Run conformance tests + feasibility gate, print results

## References

- Phase 6 of Task 201 implementation plan
- `DatasetGenerator.lean`: `LabeledFormula`, `labelFormula`, `labelBatch`
- `FormulaEnumerator.lean`: `EnumConfig`, `enumerateUpToDepth`, `smallConfig`, `mediumConfig`
- `DataExport.lean`: JSON serialization primitives
-/

set_option autoImplicit false

namespace Bimodal.Automation.DatasetValidator

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport

/-!
## Helper Atoms
-/

/-- Atom formula for "p". -/
private def p : Formula := Formula.atom_s "p"

/-- Atom formula for "q". -/
private def q : Formula := Formula.atom_s "q"

/-- Atom formula for "r". -/
private def r : Formula := Formula.atom_s "r"

/-!
## Known Valid Formulas (BX Axiom Instances)

These are concrete instances of BX axiom schemata. All should be decided `.valid`
by the decision procedure.
-/

/--
Curated list of known valid TM formulas — concrete instances of BX axiom schemata.

Includes representatives from each layer:
- Propositional (K, S, ex falso, Peirce)
- S5 Modal (T, 4, B, 5-collapse, K-distribution)
- BX Temporal (serial future, connect future, until-F)
- Modal-temporal interaction (modal future)
-/
def knownValidFormulas : List Formula :=
  [ -- Propositional K: (p → (q → r)) → ((p → q) → (p → r))
    Formula.imp (Formula.imp p (Formula.imp q r))
                (Formula.imp (Formula.imp p q) (Formula.imp p r))
  , -- Propositional S (weakening): p → (q → p)
    Formula.imp p (Formula.imp q p)
  , -- Ex falso: ⊥ → p
    Formula.imp Formula.bot p
  , -- Peirce's law: ((p → q) → p) → p
    Formula.imp (Formula.imp (Formula.imp p q) p) p
  , -- Modal T: □p → p
    Formula.imp (Formula.box p) p
  , -- Modal 4: □p → □□p
    Formula.imp (Formula.box p) (Formula.box (Formula.box p))
  , -- Modal K distribution: □(p → q) → (□p → □q)
    Formula.imp (Formula.box (Formula.imp p q))
                (Formula.imp (Formula.box p) (Formula.box q))
  , -- Modal future (MF): □p → □(Gp)
    -- Note: Uses all_future which expands to neg (untl (neg p) top), verified to work
    Formula.imp (Formula.box p) (Formula.box (Formula.all_future p))
  , -- Weakening variant: ⊥ → q
    Formula.imp Formula.bot q
  , -- Modal T on q: □q → q
    Formula.imp (Formula.box q) q
  ]

/-!
## Known Invalid Formulas

These are formulas that are NOT theorems of TM logic. All should be decided `.invalid`
by the decision procedure.
-/

/--
Curated list of known non-theorems. Each should be decided `.invalid`
with a consistent countermodel.
-/
def knownInvalidFormulas : List Formula :=
  [ -- p (bare atom: not a theorem)
    p
  , -- q (another bare atom)
    q
  , -- p → q (not valid without assumptions)
    Formula.imp p q
  , -- □p (not valid: p might not be necessary)
    Formula.box p
  , -- ◇p (not valid: p might not be possible) — uses diamond = ¬□¬p
    p.diamond
  , -- F(p) = U(p, ⊤) (not valid: p need not hold in the future)
    Formula.some_future p
  , -- P(p) = S(p, ⊤) (not valid: p need not have held in the past)
    Formula.some_past p
  , -- p ∧ ¬p (contradiction) — uses and = ¬(p → ¬q)
    Formula.and p p.neg
  , -- □p → □q (no connection between p and q)
    Formula.imp (Formula.box p) (Formula.box q)
  , -- □p ∧ □¬p (modal contradiction)
    Formula.and (Formula.box p) (Formula.box p.neg)
  , -- U(p, q) (not valid: no guarantee of future p with guard q)
    Formula.untl p q
  , -- S(p, q) (not valid: no guarantee of past p with guard q)
    Formula.snce p q
  , -- ⊥ (bottom is not a theorem)
    Formula.bot
  , -- q → p (not valid without further assumptions)
    Formula.imp q p
  , -- □(p → q) → (p → q) — trivial but not because □ is removable
    -- Actually this IS valid by Modal T. Let me use something else.
    -- r → (p → q) (not valid)
    Formula.imp r (Formula.imp p q)
  , -- □□p → p — this is VALID by Modal T applied twice. Use □p → q instead.
    Formula.imp (Formula.box p) q
  , -- Box of atom q
    Formula.box q
  , -- p → (q → r) — not valid without further constraints
    Formula.imp p (Formula.imp q r)
  , -- (p → q) → p — not valid (affirmation of consequent)
    Formula.imp (Formula.imp p q) p
  , -- □⊥ (impossible: necessity of falsehood is not valid — by Modal T, □⊥ → ⊥)
    Formula.box Formula.bot
  ]

/-!
## Conformance Testing
-/

/--
Result of a single conformance test.
-/
structure ConformanceResult where
  /-- The formula tested. -/
  formula : Formula
  /-- Expected label (valid or invalid). -/
  expected : FormulaLabel
  /-- Actual label returned by the decision procedure. -/
  actual : FormulaLabel
  /-- Whether the test passed. -/
  passed : Bool
  deriving Repr

/--
Run conformance tests on both known valid and known invalid formulas.

Returns true if all tests pass (all valid formulas decided valid,
all invalid formulas decided invalid), false otherwise.
Prints detailed results.
-/
def runConformanceTests : IO Bool := do
  IO.println "=== Conformance Tests ==="
  IO.println ""

  -- Test valid formulas
  IO.println "--- Known Valid Formulas ---"
  let mut validResults : List ConformanceResult := []
  let mut validPassed : Nat := 0
  let mut validFailed : Nat := 0
  for φ in knownValidFormulas do
    let labeled ← labelFormula φ
    let passed := labeled.label == .valid
    let result : ConformanceResult := {
      formula := φ
      expected := .valid
      actual := labeled.label
      passed := passed
    }
    validResults := result :: validResults
    if passed then
      validPassed := validPassed + 1
      IO.println s!"  [PASS] {φ.prettyPrint}"
    else
      validFailed := validFailed + 1
      IO.println s!"  [FAIL] {φ.prettyPrint} — expected valid, got {repr labeled.label}"
  IO.println s!"  Valid tests: {validPassed} passed, {validFailed} failed"
  IO.println ""

  -- Test invalid formulas
  IO.println "--- Known Invalid Formulas ---"
  let mut invalidResults : List ConformanceResult := []
  let mut invalidPassed : Nat := 0
  let mut invalidFailed : Nat := 0
  for φ in knownInvalidFormulas do
    let labeled ← labelFormula φ
    let passed := labeled.label == .invalid
    let result : ConformanceResult := {
      formula := φ
      expected := .invalid
      actual := labeled.label
      passed := passed
    }
    invalidResults := result :: invalidResults
    if passed then
      invalidPassed := invalidPassed + 1
      IO.println s!"  [PASS] {φ.prettyPrint}"
    else
      invalidFailed := invalidFailed + 1
      IO.println s!"  [FAIL] {φ.prettyPrint} — expected invalid, got {repr labeled.label}"
  IO.println s!"  Invalid tests: {invalidPassed} passed, {invalidFailed} failed"
  IO.println ""

  let allPassed := validFailed == 0 && invalidFailed == 0
  if allPassed then
    IO.println "Conformance tests: ALL PASSED"
  else
    IO.println s!"Conformance tests: FAILED ({validFailed + invalidFailed} failures)"
  return allPassed

/-!
## Diversity Metrics
-/

/--
Comprehensive diversity report for a set of labeled formulas.

Captures:
- Total counts by label category
- Provability ratio
- Operator distribution (top-level GoalCategory)
- Modal and temporal depth distributions
- Proof height statistics (mean, variance, max) for valid formulas
-/
structure DiversityReport where
  /-- Total formulas in the set. -/
  totalFormulas : Nat
  /-- Number decided valid. -/
  validCount : Nat
  /-- Number decided invalid. -/
  invalidCount : Nat
  /-- Number timed out. -/
  timeoutCount : Nat
  /-- Ratio of valid to total (validCount / totalFormulas). -/
  provabilityRatio : Float
  /-- Distribution of top-level GoalCategory: (category_name, count). -/
  operatorDistribution : List (String × Nat)
  /-- Modal depth histogram: (depth, count). -/
  modalDepthDistribution : List (Nat × Nat)
  /-- Temporal depth histogram: (depth, count). -/
  temporalDepthDistribution : List (Nat × Nat)
  /-- Mean proof height for valid formulas. -/
  proofHeightMean : Float
  /-- Variance of proof height for valid formulas. -/
  proofHeightVariance : Float
  /-- Maximum proof height among valid formulas. -/
  proofHeightMax : Nat
  deriving Repr

/-- Increment the count for a key in a (String × Nat) association list. -/
private def incrStrCount (counts : List (String × Nat)) (key : String)
    : List (String × Nat) :=
  if counts.any (fun (k, _) => k == key) then
    counts.map fun (k, n) => if k == key then (k, n + 1) else (k, n)
  else
    (key, 1) :: counts

/-- Increment the count for a Nat key in a (Nat × Nat) association list. -/
private def incrNatCount (counts : List (Nat × Nat)) (key : Nat)
    : List (Nat × Nat) :=
  if counts.any (fun (k, _) => k == key) then
    counts.map fun (k, n) => if k == key then (k, n + 1) else (k, n)
  else
    (key, 1) :: counts

/-- Convert GoalCategory to string name. -/
private def goalCategoryName (gc : GoalCategory) : String :=
  match gc with
  | .Atom => "Atom"
  | .Bottom => "Bottom"
  | .Implication => "Implication"
  | .Box => "Box"
  | .AllPast => "AllPast"
  | .AllFuture => "AllFuture"
  | .Until => "Until"
  | .Since => "Since"

/-- Extract proof height from a labeled formula, if valid and has a proof trace. -/
private def getProofHeight (lf : LabeledFormula) : Option Nat :=
  if lf.label == .valid then
    lf.proofTrace.map (·.height)
  else
    none

/--
Compute a comprehensive diversity report from labeled formulas.

Iterates through all labeled formulas, collecting:
- Label counts and provability ratio
- Operator distribution by GoalCategory
- Modal and temporal depth histograms
- Proof height statistics (mean, variance, max) for valid formulas
-/
def computeDiversityReport (labeled : List LabeledFormula) : DiversityReport :=
  -- Collect counts and distributions
  let init : (Nat × Nat × Nat × Nat × List (String × Nat) × List (Nat × Nat) ×
              List (Nat × Nat) × List Nat) :=
    (0, 0, 0, 0, [], [], [], [])
  let (total, valid, invalid, timeout, opDist, modalDist, tempDist, heights) :=
    labeled.foldl (fun (total, valid, invalid, timeout, opDist, modalDist, tempDist, heights) lf =>
      let cat := goalCategoryName (goalCategory lf.formula)
      let md := lf.formula.modalDepth
      let td := lf.formula.temporalDepth
      let newOpDist := incrStrCount opDist cat
      let newModalDist := incrNatCount modalDist md
      let newTempDist := incrNatCount tempDist td
      let newHeights := match getProofHeight lf with
        | some h => h :: heights
        | none => heights
      match lf.label with
      | .valid => (total + 1, valid + 1, invalid, timeout, newOpDist, newModalDist, newTempDist, newHeights)
      | .invalid => (total + 1, valid, invalid + 1, timeout, newOpDist, newModalDist, newTempDist, newHeights)
      | .timeout => (total + 1, valid, invalid, timeout + 1, newOpDist, newModalDist, newTempDist, newHeights)
    ) init
  -- Compute provability ratio
  let provRatio := if total > 0 then valid.toFloat / total.toFloat else 0.0
  -- Compute proof height statistics
  let (mean, variance, maxH) := computeHeightStats heights
  { totalFormulas := total
  , validCount := valid
  , invalidCount := invalid
  , timeoutCount := timeout
  , provabilityRatio := provRatio
  , operatorDistribution := opDist
  , modalDepthDistribution := modalDist.mergeSort (fun a b => a.1 < b.1)
  , temporalDepthDistribution := tempDist.mergeSort (fun a b => a.1 < b.1)
  , proofHeightMean := mean
  , proofHeightVariance := variance
  , proofHeightMax := maxH
  }
where
  /-- Compute mean, variance, and max from a list of proof heights. -/
  computeHeightStats (heights : List Nat) : (Float × Float × Nat) :=
    if heights.isEmpty then (0.0, 0.0, 0)
    else
      let n := heights.length.toFloat
      let sum := heights.foldl (· + ·) 0
      let mean := sum.toFloat / n
      let maxH := heights.foldl max 0
      let variance := heights.foldl (fun acc h =>
        let diff := h.toFloat - mean
        acc + diff * diff
      ) 0.0 / n
      (mean, variance, maxH)

/--
Display a diversity report as a human-readable string.
-/
def DiversityReport.display (r : DiversityReport) : String :=
  let opLines := r.operatorDistribution.map fun (cat, n) =>
    s!"    {cat}: {n}"
  let modalLines := r.modalDepthDistribution.map fun (d, n) =>
    s!"    depth {d}: {n}"
  let tempLines := r.temporalDepthDistribution.map fun (d, n) =>
    s!"    depth {d}: {n}"
  let validPct := if r.totalFormulas > 0
    then toString (r.validCount * 100 / r.totalFormulas) else "0"
  let invalidPct := if r.totalFormulas > 0
    then toString (r.invalidCount * 100 / r.totalFormulas) else "0"
  let timeoutPct := if r.totalFormulas > 0
    then toString (r.timeoutCount * 100 / r.totalFormulas) else "0"
  s!"Diversity Report:\n" ++
  s!"  Total formulas: {r.totalFormulas}\n" ++
  s!"  Valid: {r.validCount} ({validPct}%)\n" ++
  s!"  Invalid: {r.invalidCount} ({invalidPct}%)\n" ++
  s!"  Timeout: {r.timeoutCount} ({timeoutPct}%)\n" ++
  s!"  Provability ratio: {r.provabilityRatio}\n" ++
  s!"  Operator distribution:\n{String.intercalate "\n" opLines}\n" ++
  s!"  Modal depth distribution:\n{String.intercalate "\n" modalLines}\n" ++
  s!"  Temporal depth distribution:\n{String.intercalate "\n" tempLines}\n" ++
  s!"  Proof height mean: {r.proofHeightMean}\n" ++
  s!"  Proof height variance: {r.proofHeightVariance}\n" ++
  s!"  Proof height max: {r.proofHeightMax}"

/-!
## Feasibility Gate
-/

/--
Result of the feasibility gate evaluation.

The gate checks whether the generated dataset has sufficient quality
for downstream ML training.
-/
structure FeasibilityResult where
  /-- Whether the feasibility gate passed. -/
  passed : Bool
  /-- Total distinct formulas generated. -/
  totalFormulas : Nat
  /-- Ratio of valid to total formulas. -/
  provabilityRatio : Float
  /-- Variance of proof heights for valid formulas. -/
  proofHeightVariance : Float
  /-- Percentage of each GoalCategory in the dataset: (category, percentage). -/
  categoryDistribution : List (String × Float)
  /-- Reasons the gate failed (empty if passed). -/
  failReasons : List String
  deriving Repr

/--
Display a feasibility result as a human-readable string.
-/
def FeasibilityResult.display (fr : FeasibilityResult) : String :=
  let catLines := fr.categoryDistribution.map fun (cat, pct) =>
    s!"    {cat}: {pct}%"
  let statusStr := if fr.passed then "PASSED" else "FAILED"
  let failLines := if fr.failReasons.isEmpty then ""
    else "\n  Fail reasons:\n" ++
      String.intercalate "\n" (fr.failReasons.map fun r => s!"    - {r}")
  s!"Feasibility Gate: {statusStr}\n" ++
  s!"  Total formulas: {fr.totalFormulas}\n" ++
  s!"  Provability ratio: {fr.provabilityRatio}\n" ++
  s!"  Proof height variance: {fr.proofHeightVariance}\n" ++
  s!"  Category distribution:\n{String.intercalate "\n" catLines}" ++
  failLines

/--
Evaluate feasibility gate criteria against a diversity report.

**Pass criteria**:
- Total formulas >= `minFormulas`
- Provability ratio in [0.15, 0.70]
- Proof height variance > 2.0
- At least 3 GoalCategory types each account for >10% of formulas

**Fail criteria**:
- >80% formulas trivially propositional (Implication + Atom + Bottom)
- >90% same decision (all valid or all invalid)
- Total formulas < `hardMinFormulas`
-/
def evaluateGate (report : DiversityReport) (minFormulas : Nat := 10000)
    (hardMinFormulas : Nat := 1000) : FeasibilityResult :=
  let total := report.totalFormulas.toFloat
  -- Compute category distribution as percentages
  let catDist := report.operatorDistribution.map fun (cat, n) =>
    (cat, if total > 0.0 then (n.toFloat / total) * 100.0 else 0.0)
  -- Evaluate pass criteria by accumulating fail reasons
  let failReasons : List String := []
  -- Hard fail: too few formulas
  let failReasons := if report.totalFormulas < hardMinFormulas then
    s!"Too few formulas: {report.totalFormulas} < {hardMinFormulas}" :: failReasons
    else failReasons
  -- Soft fail: below target
  let failReasons := if report.totalFormulas < minFormulas then
    s!"Below target formula count: {report.totalFormulas} < {minFormulas} (soft)" :: failReasons
    else failReasons
  -- Provability ratio bounds
  let failReasons := if report.provabilityRatio < 0.15 then
    s!"Provability ratio too low: {report.provabilityRatio} < 0.15" :: failReasons
    else failReasons
  let failReasons := if report.provabilityRatio > 0.70 then
    s!"Provability ratio too high: {report.provabilityRatio} > 0.70" :: failReasons
    else failReasons
  -- Proof height variance
  let failReasons := if report.proofHeightVariance < 2.0 then
    s!"Proof height variance too low: {report.proofHeightVariance} < 2.0" :: failReasons
    else failReasons
  -- Category diversity: at least 3 categories each >10%
  let categoriesAbove10 := catDist.filter (fun (_, pct) => pct > 10.0)
  let failReasons := if categoriesAbove10.length < 3 then
    s!"Too few diverse categories (>10%): {categoriesAbove10.length} < 3" :: failReasons
    else failReasons
  -- Trivially propositional check
  let propCount := report.operatorDistribution.foldl (fun acc (cat, n) =>
    if cat == "Implication" || cat == "Atom" || cat == "Bottom" then acc + n else acc
  ) 0
  let failReasons := if total > 0.0 && propCount.toFloat / total > 0.80 then
    s!">80% trivially propositional: {propCount}/{report.totalFormulas}" :: failReasons
    else failReasons
  -- Same decision check
  let maxSame := max report.validCount (max report.invalidCount report.timeoutCount)
  let failReasons := if total > 0.0 && maxSame.toFloat / total > 0.90 then
    s!">90% same decision: {maxSame}/{report.totalFormulas}" :: failReasons
    else failReasons
  -- Determine overall pass/fail
  -- Soft failures (below target count) don't cause hard failure if >= hardMinFormulas
  let hardFails := failReasons.filter (fun r => !(r.endsWith "(soft)"))
  let passed := hardFails.isEmpty
  { passed := passed
  , totalFormulas := report.totalFormulas
  , provabilityRatio := report.provabilityRatio
  , proofHeightVariance := report.proofHeightVariance
  , categoryDistribution := catDist
  , failReasons := failReasons
  }

/--
Run the feasibility gate on a given enumeration configuration.

1. Enumerates formulas using `enumerateUpToDepth`
2. Labels all formulas via `labelBatch`
3. Computes diversity report
4. Evaluates the feasibility gate
-/
def runFeasibilityGate (config : EnumConfig) (configName : String := "default")
    : IO FeasibilityResult := do
  IO.println s!"=== Feasibility Gate ({configName}) ==="
  IO.println ""

  -- Step 1: Enumerate
  IO.println "Enumerating formulas..."
  let formulas := enumerateUpToDepth config
  IO.println s!"  Generated {formulas.length} unique formulas"

  -- Step 2: Label
  IO.println s!"Labeling {formulas.length} formulas..."
  let labeled ← labelBatch formulas

  -- Step 3: Compute diversity
  let report := computeDiversityReport labeled
  IO.println ""
  IO.println (report.display)
  IO.println ""

  -- Step 4: Evaluate gate
  let result := evaluateGate report config.maxSize config.maxSize
  IO.println (result.display)
  return result

/--
Run full validation: conformance tests + feasibility gate on small config.

Prints all results and returns whether everything passed.
-/
def runFullValidation : IO Unit := do
  IO.println "============================================"
  IO.println "  Dataset Validation Suite"
  IO.println "============================================"
  IO.println ""

  -- Part 1: Conformance tests
  let conformancePassed ← runConformanceTests
  IO.println ""

  -- Part 2: Feasibility gate on small config
  IO.println "--------------------------------------------"
  let smallResult ← runFeasibilityGate smallConfig "small (2,2,8,3-atoms)"
  IO.println ""

  -- Summary
  IO.println "============================================"
  IO.println "  Validation Summary"
  IO.println "============================================"
  IO.println s!"  Conformance tests: {if conformancePassed then "PASSED" else "FAILED"}"
  IO.println s!"  Feasibility gate (small): {if smallResult.passed then "PASSED" else "FAILED"}"
  if !smallResult.failReasons.isEmpty then
    IO.println "  Gate issues:"
    for reason in smallResult.failReasons do
      IO.println s!"    - {reason}"
  IO.println "============================================"

end Bimodal.Automation.DatasetValidator

/--
Entry point for the dataset validator executable.
Runs full validation (conformance tests + feasibility gate).
-/
def main : IO Unit :=
  Bimodal.Automation.DatasetValidator.runFullValidation
