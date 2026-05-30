import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport
import Bimodal.Automation.ProofSearch.Core
import Bimodal.ProofSystem.Axioms

/-!
# Benchmark Anchors: Axiom Instance Generator for BMLogic-Bench

This module generates concrete formula instances of all 42 BX axiom schemata
with varied substitutions, labels them via the decision procedure, and exports
them as JSONL records for the BMLogic-Bench benchmark.

## Design

Each axiom constructor is instantiated with combinations from a substitution
vocabulary of base terms:
- Atoms: p, q, r
- Modal: box(p), neg(p)
- Temporal: F(p), G(p), U(p,q), S(p,q)

For ground axioms (no parameters), we produce the single fixed formula.
For parameterized axioms, we produce multiple instances with different substitutions.

The module produces only **Base** frame class axioms (37 axioms). Dense/Discrete
axioms are excluded since the benchmark uses FrameClass.Base throughout.

## Main Definitions

- `substitutionVocab`: The vocabulary of formula terms to substitute into axiom schemata
- `generateAxiomInstances`: Generate all axiom instances with varied substitutions
- `main`: CLI entry point that generates, labels, and exports as JSONL

## References

- Task 205 implementation plan (BMLogic-Bench curation)
- `DatasetGenerator.lean`: `labelFormula`, `LabeledFormula`
- `DataExport.lean`: JSON serialization primitives
- `DatasetGenerator.lean`: `labelFormula`, `LabeledFormula`, JSON serialization methods
- `Axioms.lean`: All 42 BX axiom constructors
-/

set_option autoImplicit false

namespace Bimodal.Automation.BenchmarkAnchors

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation
open Bimodal.Automation.DataExport

/-!
## Substitution Vocabulary
-/

/-- Atom formula for "p". -/
private def p : Formula := Formula.atom_s "p"

/-- Atom formula for "q". -/
private def q : Formula := Formula.atom_s "q"

/-- Atom formula for "r". -/
private def r : Formula := Formula.atom_s "r"

/-- Top formula (⊤ = ⊥ → ⊥). -/
private def top' : Formula := Formula.top

/--
Substitution vocabulary: terms to plug into axiom schema parameters.
Includes atoms, modal, and temporal sub-formulas for diversity.
-/
def substitutionVocab : List Formula :=
  [ p, q, r
  , Formula.box p              -- □p
  , Formula.neg p              -- ¬p
  , Formula.some_future p      -- F(p)
  , Formula.all_future p       -- G(p)
  , Formula.untl p q           -- U(p,q)
  ]

/-- Smaller vocabulary for higher-arity schemas to control combinatorial explosion. -/
def smallVocab : List Formula :=
  [ p, q, r, Formula.box p, Formula.neg p ]

/-- Minimal vocabulary for 4-parameter schemas. -/
def tinyVocab : List Formula :=
  [ p, q, r ]

/-!
## Axiom Instance Generation

For each axiom constructor, we generate concrete formula instances by
substituting vocabulary terms into the schema parameters.

The axiom constructors are organized by parameter count:
- Ground (0 params): produce exactly 1 formula each
- 1-param: vocab × 1 combinations
- 2-param: vocab × vocab combinations
- 3-param: smallVocab × smallVocab × smallVocab combinations
- 4-param: tinyVocab^4 combinations
-/

/-- Tag a formula with its axiom constructor name for tracking. -/
structure TaggedFormula where
  /-- The concrete formula instance. -/
  formula : Formula
  /-- Name of the axiom constructor that generated it. -/
  axiomName : String
  deriving Repr

/--
Generate all ground axiom instances (no parameters).
These produce exactly one formula each.
-/
def groundAxiomInstances : List TaggedFormula :=
  -- Layer 3: BX Temporal ground axioms
  [ { formula := (top'.imp (Formula.some_future top'))
    , axiomName := "serial_future" }
  , { formula := (top'.imp (Formula.some_past top'))
    , axiomName := "serial_past" }
  -- Layer 5: Uniformity ground axioms
  , { formula := (Formula.untl top' Formula.bot).imp
        (Formula.snce top' Formula.bot)
    , axiomName := "discrete_symm_fwd" }
  , { formula := (Formula.snce top' Formula.bot).imp
        (Formula.untl top' Formula.bot)
    , axiomName := "discrete_symm_bwd" }
  , { formula := (Formula.untl top' Formula.bot).imp
        (Formula.all_future (Formula.untl top' Formula.bot))
    , axiomName := "discrete_propagate_fwd" }
  , { formula := (Formula.untl top' Formula.bot).imp
        (Formula.all_past (Formula.untl top' Formula.bot))
    , axiomName := "discrete_propagate_bwd" }
  , { formula := (Formula.untl top' Formula.bot).imp
        (Formula.box (Formula.untl top' Formula.bot))
    , axiomName := "discrete_box_necessity" }
  -- Layer 8: Density ground axiom
  , { formula := (Formula.untl top' Formula.bot).neg
    , axiomName := "dense_indicator" }
  ]

/--
Generate 1-parameter axiom instances: each schema instantiated with each vocab term.
-/
def oneParamInstances : List TaggedFormula :=
  substitutionVocab.flatMap fun φ =>
    [ -- Layer 1: Propositional
      { formula := Formula.bot.imp φ, axiomName := "ex_falso" }
      -- Layer 2: S5 Modal
    , { formula := (Formula.box φ).imp φ, axiomName := "modal_t" }
    , { formula := (Formula.box φ).imp (Formula.box (Formula.box φ))
      , axiomName := "modal_4" }
    , { formula := φ.imp (Formula.box φ.diamond), axiomName := "modal_b" }
    , { formula := φ.box.diamond.imp φ.box, axiomName := "modal_5_collapse" }
      -- Layer 3: BX Temporal (1-param)
    , { formula := φ.imp (φ.some_past.all_future), axiomName := "connect_future" }
    , { formula := φ.imp (φ.some_future.all_past), axiomName := "connect_past" }
    , { formula := (φ.some_future).imp (Formula.untl φ top')
      , axiomName := "F_until_equiv" }
    , { formula := (φ.some_past).imp (Formula.snce φ top')
      , axiomName := "P_since_equiv" }
      -- Layer 4: Modal-Temporal Interaction
    , { formula := (Formula.box φ).imp (Formula.box (Formula.all_future φ))
      , axiomName := "modal_future" }
      -- Layer 6: Prior (discrete-only, but still valid instances)
    , { formula := φ.some_future.imp (Formula.untl φ φ.neg)
      , axiomName := "prior_UZ" }
    , { formula := φ.some_past.imp (Formula.snce φ φ.neg)
      , axiomName := "prior_SZ" }
      -- Layer 7: Z1 (discrete-only)
    , { formula := (φ.all_future.imp φ).all_future.imp
          (φ.all_future.some_future.imp φ.all_future)
      , axiomName := "z1" }
      -- Layer 8: Density
    , { formula := φ.all_future.all_future.imp φ.all_future
      , axiomName := "density" }
    ]

/--
Generate 2-parameter axiom instances.
-/
def twoParamInstances : List TaggedFormula :=
  smallVocab.flatMap fun φ =>
    smallVocab.flatMap fun ψ =>
      [ -- Layer 1: Propositional
        { formula := φ.imp (ψ.imp φ), axiomName := "prop_s" }
      , { formula := ((φ.imp ψ).imp φ).imp φ, axiomName := "peirce" }
        -- Layer 3: BX Temporal (2-param)
      , { formula := (Formula.untl ψ φ).imp
            (Formula.untl ψ (Formula.and φ (Formula.untl ψ φ)))
        , axiomName := "self_accum_until" }
      , { formula := (Formula.snce ψ φ).imp
            (Formula.snce ψ (Formula.and φ (Formula.snce ψ φ)))
        , axiomName := "self_accum_since" }
      , { formula := (Formula.untl (Formula.and φ (Formula.untl ψ φ)) φ).imp
            (Formula.untl ψ φ)
        , axiomName := "absorb_until" }
      , { formula := (Formula.snce (Formula.and φ (Formula.snce ψ φ)) φ).imp
            (Formula.snce ψ φ)
        , axiomName := "absorb_since" }
      , { formula := (Formula.untl ψ φ).imp (Formula.some_future ψ)
        , axiomName := "until_F" }
      , { formula := (Formula.snce ψ φ).imp (Formula.some_past ψ)
        , axiomName := "since_P" }
      , { formula := Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
            (Formula.or (Formula.some_future (Formula.and φ ψ))
              (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
                (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))
        , axiomName := "temp_linearity" }
      , { formula := Formula.and (Formula.some_past φ) (Formula.some_past ψ) |>.imp
            (Formula.or (Formula.some_past (Formula.and φ ψ))
              (Formula.or (Formula.some_past (Formula.and φ (Formula.some_past ψ)))
                (Formula.some_past (Formula.and (Formula.some_past φ) ψ))))
        , axiomName := "temp_linearity_past" }
      ]

/--
Generate 3-parameter axiom instances.
Uses smallVocab to control combinatorial explosion.
-/
def threeParamInstances : List TaggedFormula :=
  tinyVocab.flatMap fun φ =>
    tinyVocab.flatMap fun ψ =>
      tinyVocab.flatMap fun χ =>
        [ -- Layer 1: Propositional
          { formula := (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))
          , axiomName := "prop_k" }
          -- Layer 2: S5 Modal
        , { formula := (φ.imp ψ).box.imp (φ.box.imp ψ.box)
          , axiomName := "modal_k_dist" }
          -- Layer 3: BX Temporal (3-param)
        , { formula := (φ.imp χ).all_future.imp
              ((Formula.untl ψ φ).imp (Formula.untl ψ χ))
          , axiomName := "left_mono_until_G" }
        , { formula := (φ.imp χ).all_past.imp
              ((Formula.snce ψ φ).imp (Formula.snce ψ χ))
          , axiomName := "left_mono_since_H" }
        , { formula := (φ.imp ψ).all_future.imp
              ((Formula.untl φ χ).imp (Formula.untl ψ χ))
          , axiomName := "right_mono_until" }
        , { formula := (φ.imp ψ).all_past.imp
              ((Formula.snce φ χ).imp (Formula.snce ψ χ))
          , axiomName := "right_mono_since" }
        , { formula := Formula.and χ (Formula.untl ψ φ) |>.imp
              (Formula.untl (Formula.and ψ (Formula.snce χ φ)) φ)
          , axiomName := "enrichment_until" }
        , { formula := Formula.and χ (Formula.snce ψ φ) |>.imp
              (Formula.snce (Formula.and ψ (Formula.untl χ φ)) φ)
          , axiomName := "enrichment_since" }
        ]

/--
Generate 4-parameter axiom instances (linear_until, linear_since).
Uses tinyVocab to control combinatorial explosion.
-/
def fourParamInstances : List TaggedFormula :=
  tinyVocab.flatMap fun φ =>
    tinyVocab.flatMap fun ψ =>
      tinyVocab.flatMap fun χ =>
        tinyVocab.flatMap fun θ =>
          [ { formula := Formula.and (Formula.untl ψ φ) (Formula.untl θ χ)
                |>.imp (Formula.or
                  (Formula.or
                    (Formula.untl (Formula.and ψ θ) (Formula.and φ χ))
                    (Formula.untl (Formula.and ψ χ) (Formula.and φ χ)))
                  (Formula.untl (Formula.and φ θ) (Formula.and φ χ)))
            , axiomName := "linear_until" }
          , { formula := Formula.and (Formula.snce ψ φ) (Formula.snce θ χ)
                |>.imp (Formula.or
                  (Formula.or
                    (Formula.snce (Formula.and ψ θ) (Formula.and φ χ))
                    (Formula.snce (Formula.and ψ χ) (Formula.and φ χ)))
                  (Formula.snce (Formula.and φ θ) (Formula.and φ χ)))
            , axiomName := "linear_since" }
          ]

/--
Generate all axiom instances from all parameter arities.
Deduplicates by formula equality.
-/
def generateAllInstances : List TaggedFormula :=
  let all := groundAxiomInstances
    ++ oneParamInstances
    ++ twoParamInstances
    ++ threeParamInstances
    ++ fourParamInstances
  -- Deduplicate by formula (keep first occurrence)
  all.foldl (fun acc tf =>
    if acc.any (fun existing => existing.formula == tf.formula) then acc
    else acc ++ [tf]
  ) []

/-!
## Axiom Coverage Verification
-/

/-- All 42 axiom constructor names. -/
def allAxiomNames : List String :=
  [ "prop_k", "prop_s", "ex_falso", "peirce"
  , "modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist"
  , "serial_future", "serial_past"
  , "left_mono_until_G", "left_mono_since_H"
  , "right_mono_until", "right_mono_since"
  , "connect_future", "connect_past"
  , "enrichment_until", "enrichment_since"
  , "self_accum_until", "self_accum_since"
  , "absorb_until", "absorb_since"
  , "linear_until", "linear_since"
  , "until_F", "since_P"
  , "temp_linearity", "temp_linearity_past"
  , "F_until_equiv", "P_since_equiv"
  , "modal_future"
  , "discrete_symm_fwd", "discrete_symm_bwd"
  , "discrete_propagate_fwd", "discrete_propagate_bwd"
  , "discrete_box_necessity"
  , "prior_UZ", "prior_SZ"
  , "z1"
  , "density", "dense_indicator"
  ]

/-- Check which axiom names are covered by the generated instances. -/
def checkCoverage (instances : List TaggedFormula) : List String × List String :=
  let coveredNames := instances.map (·.axiomName) |>.eraseDups
  let missing := allAxiomNames.filter (fun name => !(coveredNames.contains name))
  (coveredNames, missing)

/-!
## Axiom-Based Labeling
-/

/-- Names of axiom constructors that require non-Base frame classes. -/
private def nonBaseAxiomNames : List String :=
  ["prior_UZ", "prior_SZ", "z1", "density", "dense_indicator"]

/--
Label a tagged formula via `matchAxiom` directly, bypassing the tableau decision procedure.

For Base-class axioms (37 constructors): produces a valid label with proof trace
referencing the matched axiom constructor.
For non-Base axioms (5 constructors: prior_UZ, prior_SZ, z1, density, dense_indicator):
produces an invalid label with a note about frame class incompatibility.

Returns `none` if `matchAxiom` fails (shouldn't happen for well-formed instances).
-/
def labelViaAxiomMatch (tf : TaggedFormula) : Option LabeledFormula :=
  let φ := tf.formula
  match Bimodal.Automation.matchAxiom φ with
  | some ⟨_, _witness⟩ =>
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    if nonBaseAxiomNames.contains tf.axiomName then
      -- Non-Base axiom: label as invalid (not valid on Base frame class)
      some {
        formula := φ
        label := .invalid
        proofTrace := none
        countermodel := none
        metrics := metrics
        patternKey := patternKey
      }
    else
      -- Base axiom: label as valid with proof trace
      let trace : ProofTrace := {
        height := 0
        axioms_used := [tf.axiomName]
        rules_applied := ["axiom_match"]
      }
      some {
        formula := φ
        label := .valid
        proofTrace := some trace
        countermodel := none
        metrics := metrics
        patternKey := patternKey
      }
  | none => none

/--
Select top-N lowest-complexity instances per axiom constructor.

Groups instances by `axiomName`, sorts each group by formula complexity
(ascending), and takes the first `n` per constructor.
-/
def selectTopInstances (instances : List TaggedFormula) (n : Nat := 3) : List TaggedFormula :=
  -- Group by axiom name
  let groups := instances.foldl (fun acc tf =>
    let key := tf.axiomName
    let existing := acc.find? (fun (k, _) => k == key)
    match existing with
    | some _ =>
      acc.map (fun (k, vs') => if k == key then (k, vs' ++ [tf]) else (k, vs'))
    | none => acc ++ [(key, [tf])]
  ) ([] : List (String × List TaggedFormula))
  -- Sort each group by complexity ascending, take top-n
  groups.flatMap (fun (_, vs) =>
    let sorted := vs.mergeSort (fun a b => a.formula.complexity ≤ b.formula.complexity)
    sorted.take n)

/-!
## JSONL Export
-/

/-- Assign a deterministic split based on formula string hash. -/
def assignSplit' (formulaStr : String) : String :=
  let h := hash formulaStr
  let bucket := h % 100
  if bucket < 80 then "train"
  else if bucket < 90 then "val"
  else "test"

/-- Zero-pad a natural number to at least `width` digits. -/
def padNat' (n : Nat) (width : Nat) : String :=
  let s := toString n
  let padLen := if s.length < width then width - s.length else 0
  String.ofList (List.replicate padLen '0') ++ s

/--
Convert a tagged formula with its labeled result into a JSONL record string.
-/
def taggedToJsonl (idx : Nat) (tf : TaggedFormula) (lf : LabeledFormula)
    : String :=
  let idStr := "axiom-" ++ padNat' idx 5
  let splitName := assignSplit' lf.formula.prettyPrint
  let traceStr := match lf.proofTrace with
    | none => "null"
    | some pt => pt.toJson
  let cmStr := match lf.countermodel with
    | none => "null"
    | some cm => cm.toJson
  let augStr := "{\"source\": \"axiom_instance\", \"original_formula_str\": null, \"axiom_name\": \""
    ++ escapeJsonString tf.axiomName ++ "\"}"
  "{\"id\": \"" ++ escapeJsonString idStr ++ "\""
  ++ ", \"split\": \"" ++ escapeJsonString splitName ++ "\""
  ++ ", \"formula_str\": \"" ++ escapeJsonString lf.formula.prettyPrint ++ "\""
  ++ ", \"formula_ast\": " ++ lf.formula.toJson
  ++ ", \"frame_class\": \"Base\""
  ++ ", \"label\": " ++ lf.label.toJson
  ++ ", \"proof_trace\": " ++ traceStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"pattern_key\": " ++ lf.patternKey.toJson
  ++ ", \"metrics\": " ++ lf.metrics.toJson
  ++ ", \"augmentation\": " ++ augStr
  ++ ", \"axiom_name\": \"" ++ escapeJsonString tf.axiomName ++ "\""
  ++ "}"

end Bimodal.Automation.BenchmarkAnchors

/-!
## Main Entry Point
-/

open Bimodal.Automation
open Bimodal.Automation.BenchmarkAnchors
open Bimodal.Automation.DataExport

/--
Main entry point for the benchmark_anchors executable.

Pipeline:
1. Generate all axiom instances from the substitution vocabulary
2. Select top-3 lowest-complexity instances per constructor (126 records)
3. Check coverage of all 42 axiom constructors
4. Label each instance via `matchAxiom` (direct axiom proof), falling back to
   `labelFormula`/`decideAuto` if `matchAxiom` fails
5. Write JSONL output file with `axiom_name` preserved
6. Print summary statistics
-/
def main (args : List String) : IO Unit := do
  let outputPath := match args with
    | "--output" :: path :: _ => path
    | _ => "data/axiom-instances.jsonl"

  IO.println "BMLogic-Bench Axiom Instance Generator"
  IO.println "======================================"
  IO.println ""

  -- Step 1: Generate all instances
  IO.println "Generating axiom instances..."
  let allInstances := generateAllInstances
  IO.println s!"  Generated {allInstances.length} unique instances (all arities)"

  -- Step 2: Select top-3 per constructor
  IO.println "Selecting top-3 lowest-complexity per constructor..."
  let instances := selectTopInstances allInstances 3
  IO.println s!"  Selected {instances.length} instances (target: 126 = 42 x 3)"

  -- Step 3: Check coverage
  let (covered, missing) := checkCoverage instances
  IO.println s!"  Axiom coverage: {covered.length}/42 constructors"
  if !missing.isEmpty then
    IO.println s!"  WARNING: Missing axioms: {missing}"

  -- Step 4: Tier distribution preview
  let tierCounts := instances.foldl (fun (e, m, h, vh) tf =>
    let c := tf.formula.complexity
    if c ≤ 3 then (e + 1, m, h, vh)
    else if c ≤ 6 then (e, m + 1, h, vh)
    else if c ≤ 9 then (e, m, h + 1, vh)
    else (e, m, h, vh + 1)
  ) (0, 0, 0, 0)
  IO.println s!"  Tier distribution (pre-labeling):"
  IO.println s!"    easy (≤3): {tierCounts.1}"
  IO.println s!"    medium (4-6): {tierCounts.2.1}"
  IO.println s!"    hard (7-9): {tierCounts.2.2.1}"
  IO.println s!"    very_hard (≥10): {tierCounts.2.2.2}"
  IO.println ""

  -- Step 5: Label instances via matchAxiom (direct axiom proof)
  IO.println "Labeling instances via axiom matching..."
  let mut labeled : List (TaggedFormula × LabeledFormula) := []
  let mut validCount : Nat := 0
  let mut invalidCount : Nat := 0
  let mut timeoutCount : Nat := 0
  let mut axiomMatchCount : Nat := 0
  let mut fallbackCount : Nat := 0
  for tf in instances do
    -- Try axiom match first (fast, direct)
    match labelViaAxiomMatch tf with
    | some lf =>
      labeled := (tf, lf) :: labeled
      axiomMatchCount := axiomMatchCount + 1
      match lf.label with
      | .valid => validCount := validCount + 1
      | .invalid => invalidCount := invalidCount + 1
      | .timeout => timeoutCount := timeoutCount + 1
    | none =>
      -- Fallback to decision procedure
      let lf ← labelFormula tf.formula
      labeled := (tf, lf) :: labeled
      fallbackCount := fallbackCount + 1
      match lf.label with
      | .valid => validCount := validCount + 1
      | .invalid => invalidCount := invalidCount + 1
      | .timeout => timeoutCount := timeoutCount + 1
  labeled := labeled.reverse
  IO.println s!"  Labeling complete: {validCount} valid, {invalidCount} invalid, {timeoutCount} timeout"
  IO.println s!"  Axiom-matched: {axiomMatchCount}, Fallback: {fallbackCount}"

  -- Step 6: Per-constructor coverage summary
  let mut constructorCounts : List (String × Nat × Nat) := []  -- (name, valid, total)
  for name in allAxiomNames do
    let nameRecords := labeled.filter (fun (tf, _) => tf.axiomName == name)
    let nameValid := nameRecords.filter (fun (_, lf) => lf.label == .valid) |>.length
    constructorCounts := constructorCounts ++ [(name, nameValid, nameRecords.length)]
  let constructorsWithValid := constructorCounts.filter (fun (_, v, _) => v > 0) |>.length
  IO.println s!"  Constructors with valid instances: {constructorsWithValid}/42"

  -- Step 7: Ensure output directory exists
  let outFilePath : System.FilePath := ⟨outputPath⟩
  match outFilePath.parent with
  | some dir => do
    let dirExists ← dir.pathExists
    if !dirExists then
      IO.FS.createDirAll dir
  | none => pure ()

  -- Step 8: Write JSONL
  IO.println ""
  IO.println s!"Writing JSONL to {outputPath}..."
  let handle ← IO.FS.Handle.mk outFilePath .write
  let mut writeIdx : Nat := 0
  for (tf, lf) in labeled do
    writeIdx := writeIdx + 1
    let line := taggedToJsonl writeIdx tf lf
    handle.putStrLn line
  IO.println s!"  Wrote {writeIdx} records"

  -- Step 9: Summary
  IO.println ""
  IO.println "Summary"
  IO.println "======="
  IO.println s!"  Total instances generated: {allInstances.length}"
  IO.println s!"  Selected (top-3 per constructor): {instances.length}"
  IO.println s!"  Valid: {validCount}"
  IO.println s!"  Invalid: {invalidCount}"
  IO.println s!"  Timeout: {timeoutCount}"
  IO.println s!"  Coverage: {covered.length}/42 axiom constructors"
  IO.println s!"  Axiom-matched: {axiomMatchCount} ({axiomMatchCount * 100 / instances.length}%)"
  IO.println ""
  IO.println "Done!"
