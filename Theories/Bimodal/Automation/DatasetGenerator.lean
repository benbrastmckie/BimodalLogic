import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Automation.SuccessPatterns
import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.DataExport
import Bimodal.Automation.EnrichedCountermodel

/-!
# Dataset Generator: Decider Integration and ProofTrace Extraction

This module provides the labeling pipeline for the formula dataset.
It runs the existing `DecisionProcedure.decide` on enumerated formulas,
extracts simplified proof traces from valid results, computes difficulty
metrics, and produces labeled records.

## Main Definitions

- `ProofTrace`: Simplified proof information (height, axiom names, rule names)
- `DifficultyMetrics`: Structural and computational difficulty measures
- `FormulaLabel`: Classification label (valid, invalid, timeout)
- `LabeledFormula`: Complete labeled record with formula, label, trace, and metrics
- `labelFormula`: Run decision procedure and produce a labeled record
- `labelBatch`: Process multiple formulas with progress reporting

## Design Decisions

- **Simplified ProofTrace**: Extracts height, axiom constructor names, and rule names
  from `DerivationTree` without full serialization (dependent types make full
  serialization impractical)
- **Base frame class only**: `decideAuto` only supports `FrameClass.Base`
- **Wall-clock timing**: Uses `IO.monoMsNow` for decision time measurement
- **All axiom constructors handled**: Pattern match covers all constructors in
  `Bimodal.ProofSystem.Axiom`

## References

- Team research report: specs/203_formula_enumerator_dataset_export/reports/01_team-research.md
- DecisionProcedure: Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean
-/

set_option autoImplicit false

namespace Bimodal.Automation

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability
open Bimodal.Automation.DataExport
open Bimodal.Automation.Enriched

/--
Simplified proof trace extracted from a DerivationTree.

Contains the proof height, list of axiom schema names used,
and list of inference rule names applied. This avoids serializing
the full dependent-type proof tree.
-/
structure ProofTrace where
  /-- Maximum depth of the proof tree. -/
  height : Nat
  /-- Names of axiom schemata used (e.g., "modal_t", "prop_k"). -/
  axioms_used : List String
  /-- Names of inference rules applied (e.g., "modus_ponens", "necessitation"). -/
  rules_applied : List String
  deriving Repr, Inhabited

/--
Difficulty metrics for a formula, combining structural and computational measures.
-/
structure DifficultyMetrics where
  /-- Structural complexity (connective count + 1). -/
  complexity : Nat
  /-- Maximum modal operator nesting. -/
  modalDepth : Nat
  /-- Maximum temporal operator nesting. -/
  temporalDepth : Nat
  /-- Number of implication operators. -/
  impCount : Nat
  /-- Number of distinct atoms. -/
  atomCount : Nat
  /-- Wall-clock decision time in milliseconds. -/
  decisionTimeMs : Nat := 0
  /-- Human-readable difficulty tier. -/
  difficultyTier : String := "unknown"
  deriving Repr, Inhabited

/--
Label classification for a formula.
- `valid`: Formula is valid in the logic (a theorem)
- `invalid`: Formula is not valid (countermodel exists)
- `timeout`: Decision procedure ran out of resources
-/
inductive FormulaLabel where
  | valid
  | invalid
  | timeout
  deriving Repr, DecidableEq, BEq, Inhabited

/--
Serializable summary of a `SemanticCountermodel` for JSON export.

The full `SemanticCountermodel` contains non-serializable fields (the raw branch
list and a function-valued atom valuation). This summary captures the key
structural information: world set, time set, temporal ordering constraints,
and the formula being refuted.
-/
structure SemanticCountermodelSummary where
  /-- All world indices in the model. -/
  worlds : List Nat
  /-- All time indices in the model. -/
  times : List Nat
  /-- Temporal ordering constraints: each `(a, b)` means `a < b`. -/
  timeConstraints : List (Nat × Nat)
  /-- Number of worlds. -/
  worldCount : Nat
  /-- Number of time points. -/
  timeCount : Nat
  deriving Repr, Inhabited

/--
Extract a serializable summary from a `SemanticCountermodel`.
-/
def SemanticCountermodelSummary.fromSemanticCountermodel
    (scm : SemanticCountermodel) : SemanticCountermodelSummary :=
  { worlds := scm.worlds
  , times := scm.times
  , timeConstraints := scm.timeOrdering.constraints
  , worldCount := scm.worlds.length
  , timeCount := scm.times.length
  }

/--
A fully labeled formula record combining the formula with its
decision result, proof trace (if valid), countermodel (if invalid),
difficulty metrics, and pattern key.
-/
structure LabeledFormula where
  /-- The formula that was labeled. -/
  formula : Formula
  /-- Classification result. -/
  label : FormulaLabel
  /-- Proof trace if formula is valid (None for invalid/timeout). -/
  proofTrace : Option ProofTrace
  /-- Countermodel if formula is invalid (None for valid/timeout). -/
  countermodel : Option SimpleCountermodel
  /-- Difficulty metrics. -/
  metrics : DifficultyMetrics
  /-- Pattern key for structural indexing. -/
  patternKey : PatternKey
  /-- Rule application counts from walkDerivationTree (valid formulas only). -/
  ruleProfile : Option RuleProfile
  /-- Which decision pipeline stage produced the result. -/
  decisionMethod : String
  /-- Whether the countermodel is self-consistent (invalid formulas only). -/
  countermodelConsistent : Option Bool
  /-- Enriched countermodel with branch structure (invalid formulas only). -/
  enrichedCountermodel : Option EnrichedCountermodel
  /-- Semantic countermodel summary (invalid formulas only). -/
  semanticCountermodelSummary : Option SemanticCountermodelSummary
  /-- How the proof was reconstructed (valid formulas only).
      Values: "axiom_match", "derived_match", "compositional", "proof_search",
      "tableau_extraction". -/
  proofReconstructionMethod : Option String
  deriving Repr

instance : Inhabited LabeledFormula :=
  ⟨{ formula := .bot
     label := .timeout
     proofTrace := none
     countermodel := none
     metrics := default
     patternKey := default
     ruleProfile := none
     decisionMethod := "timeout"
     countermodelConsistent := none
     enrichedCountermodel := none
     semanticCountermodelSummary := none
     proofReconstructionMethod := none }⟩

/--
Extract axiom schema name as a string from an Axiom constructor.

Covers all constructors in `Bimodal.ProofSystem.Axiom`:
- Layer 1: Propositional (prop_k, prop_s, ex_falso, peirce)
- Layer 2: S5 Modal (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
- Layer 3: BX Temporal (20 constructors)
- Layer 4: Modal-Temporal (modal_future)
- Layer 5: Uniformity (5 constructors)
- Layer 6: Prior (prior_UZ, prior_SZ)
- Layer 7: Z1
- Layer 8: Density (density, dense_indicator)
-/
def extractAxiomName {φ : Formula} (ax : Axiom φ) : String :=
  match ax with
  | .prop_k _ _ _ => "prop_k"
  | .prop_s _ _ => "prop_s"
  | .ex_falso _ => "ex_falso"
  | .peirce _ _ => "peirce"
  | .modal_t _ => "modal_t"
  | .modal_4 _ => "modal_4"
  | .modal_b _ => "modal_b"
  | .modal_5_collapse _ => "modal_5_collapse"
  | .modal_k_dist _ _ => "modal_k_dist"
  | .serial_future => "serial_future"
  | .serial_past => "serial_past"
  | .left_mono_until_G _ _ _ => "left_mono_until_G"
  | .left_mono_since_H _ _ _ => "left_mono_since_H"
  | .right_mono_until _ _ _ => "right_mono_until"
  | .right_mono_since _ _ _ => "right_mono_since"
  | .connect_future _ => "connect_future"
  | .connect_past _ => "connect_past"
  | .enrichment_until _ _ _ => "enrichment_until"
  | .enrichment_since _ _ _ => "enrichment_since"
  | .self_accum_until _ _ => "self_accum_until"
  | .self_accum_since _ _ => "self_accum_since"
  | .absorb_until _ _ => "absorb_until"
  | .absorb_since _ _ => "absorb_since"
  | .linear_until _ _ _ _ => "linear_until"
  | .linear_since _ _ _ _ => "linear_since"
  | .until_F _ _ => "until_F"
  | .since_P _ _ => "since_P"
  | .temp_linearity _ _ => "temp_linearity"
  | .temp_linearity_past _ _ => "temp_linearity_past"
  | .F_until_equiv _ => "F_until_equiv"
  | .P_since_equiv _ => "P_since_equiv"
  | .modal_future _ => "modal_future"
  | .discrete_symm_fwd => "discrete_symm_fwd"
  | .discrete_symm_bwd => "discrete_symm_bwd"
  | .discrete_propagate_fwd => "discrete_propagate_fwd"
  | .discrete_propagate_bwd => "discrete_propagate_bwd"
  | .discrete_box_necessity => "discrete_box_necessity"
  | .prior_UZ _ => "prior_UZ"
  | .prior_SZ _ => "prior_SZ"
  | .z1 _ => "z1"
  | .density _ => "density"
  | .dense_indicator => "dense_indicator"

/--
Extract a simplified proof trace from a DerivationTree.

Recursively traverses the proof tree, collecting:
- Height (max depth)
- Axiom names at leaves
- Inference rule names at internal nodes

This provides a useful summary without the complexity of full
dependent-type serialization.
-/
def extractProofTrace {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) : ProofTrace :=
  match d with
  | .axiom _ _ ax _ =>
    { height := 0
      axioms_used := [extractAxiomName ax]
      rules_applied := [] }
  | .assumption _ _ _ =>
    { height := 0
      axioms_used := []
      rules_applied := ["assumption"] }
  | .modus_ponens _ _ _ d1 d2 =>
    let t1 := extractProofTrace d1
    let t2 := extractProofTrace d2
    { height := 1 + max t1.height t2.height
      axioms_used := (t1.axioms_used ++ t2.axioms_used).eraseDups
      rules_applied := "modus_ponens" :: (t1.rules_applied ++ t2.rules_applied).eraseDups }
  | .necessitation _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axioms_used := t1.axioms_used
      rules_applied := "necessitation" :: t1.rules_applied }
  | .temporal_necessitation _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axioms_used := t1.axioms_used
      rules_applied := "temporal_necessitation" :: t1.rules_applied }
  | .temporal_duality _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axioms_used := t1.axioms_used
      rules_applied := "temporal_duality" :: t1.rules_applied }
  | .weakening _ _ _ d1 _ =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axioms_used := t1.axioms_used
      rules_applied := "weakening" :: t1.rules_applied }

/--
Compute difficulty metrics for a formula with optional decision time.
-/
def computeMetrics (φ : Formula) (decisionTimeMs : Nat := 0) : DifficultyMetrics :=
  { complexity := φ.complexity
    modalDepth := φ.modalDepth
    temporalDepth := φ.temporalDepth
    impCount := φ.countImplications
    atomCount := φ.atoms.card
    decisionTimeMs := decisionTimeMs
    difficultyTier := classifyDifficulty φ.complexity decisionTimeMs }
where
  /-- Classify difficulty tier based on complexity and decision time. -/
  classifyDifficulty (complexity : Nat) (_timeMs : Nat) : String :=
    if complexity ≤ 3 then "easy"
    else if complexity ≤ 6 then "medium"
    else if complexity ≤ 9 then "hard"
    else "very_hard"

/--
Infer the proof reconstruction method from the proof structure.

- Single axiom node with no rules: "axiom_match"
- Only weakening applied (derived theorem match): "derived_match"
- Low rule count with modus_ponens (compositional builder): "compositional"
- Higher rule count or deep proof: "proof_search"
-/
def inferReconstructionMethod (rp : RuleProfile) (height : Nat) : String :=
  let totalRules := rp.mpCount + rp.necessitationCount + rp.temporalNecessitationCount +
                    rp.temporalDualityCount + rp.weakeningCount + rp.assumptionCount
  if totalRules == 0 && rp.axiomCount > 0 then
    "axiom_match"
  else if rp.weakeningCount > 0 && rp.mpCount == 0 && rp.axiomCount <= 1 then
    "derived_match"
  else if height <= 5 && rp.mpCount <= 3 then
    "compositional"
  else
    "proof_search"

/--
Extract enriched and semantic countermodel data for an invalid formula.

Runs `buildTableau` to obtain the raw open branch, then extracts:
1. `EnrichedCountermodel` (full branch structure with modal/temporal subsets)
2. `SemanticCountermodelSummary` (worlds, times, temporal ordering)

If the tableau build fails (rare, since `decideAuto` already confirmed invalidity),
returns `(none, none)`.
-/
def extractCountermodelData (φ : Formula) :
    Option EnrichedCountermodel × Option SemanticCountermodelSummary :=
  let fuel := soundFuel φ
  match buildTableau φ fuel with
  | none => (none, none)
  | some (.allClosed _) => (none, none)  -- Shouldn't happen for invalid formula
  | some (.hasOpen openBranch ord _applied _hSat) =>
      let ecm := extractEnrichedCountermodel φ openBranch
      let scm := extractSemanticCountermodel φ openBranch ord
      let summary := SemanticCountermodelSummary.fromSemanticCountermodel scm
      (some ecm, some summary)

/--
Build a `LabeledFormula` for an invalid result, including enriched countermodel data.
-/
private def mkInvalidLabel (φ : Formula) (cm : SimpleCountermodel)
    (metrics : DifficultyMetrics) (patternKey : PatternKey)
    (method : String := "tableau_open") : LabeledFormula :=
  let consistent := cm.isConsistent
  let (ecm, scmSummary) := extractCountermodelData φ
  { formula := φ
    label := .invalid
    proofTrace := none
    countermodel := some cm
    metrics := metrics
    patternKey := patternKey
    ruleProfile := none
    decisionMethod := method
    countermodelConsistent := some consistent
    enrichedCountermodel := ecm
    semanticCountermodelSummary := scmSummary
    proofReconstructionMethod := none
  }

/--
Label a single formula by running the decision procedure.

1. Measures wall-clock time using `IO.monoMsNow`
2. Calls `decideAuto` (automatic fuel based on formula complexity)
3. Extracts proof trace (valid), countermodel (invalid), or records timeout
4. Computes difficulty metrics and pattern key
5. For valid formulas, infers proof reconstruction method from proof structure
6. For invalid formulas, extracts enriched and semantic countermodel data

With task 239's 5-strategy proof extraction pipeline in place, `decideAuto`
returns `.valid` for all closed tableaux where proof extraction succeeds.
The `.timeout` case now represents genuine resource exhaustion (tableau
construction exceeded sound fuel), not a masking of extraction failure.
The `decideOptimized` retry path is no longer needed.
-/
def labelFormula (φ : Formula) : IO LabeledFormula := do
  let startTime ← IO.monoMsNow
  let result := decideAuto φ
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  let metrics := computeMetrics φ elapsed
  let patternKey := PatternKey.fromFormula φ
  match result with
  | .valid proof =>
    let trace := extractProofTrace proof
    let rp := walkDerivationTree proof
    -- Determine decision method: if proof uses only axioms, it was fast path;
    -- otherwise it came from proof search within decideAuto
    let method := if rp.mpCount == 0 && rp.necessitationCount == 0 &&
                     rp.temporalNecessitationCount == 0 && rp.temporalDualityCount == 0 &&
                     rp.weakeningCount == 0 && rp.assumptionCount == 0
                  then "fast_path_axiom"
                  else "proof_search"
    let reconMethod := inferReconstructionMethod rp trace.height
    return {
      formula := φ
      label := .valid
      proofTrace := some trace
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := some rp
      decisionMethod := method
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some reconMethod
    }
  | .invalid cm =>
    return mkInvalidLabel φ cm metrics patternKey
  | .timeout =>
    return {
      formula := φ
      label := .timeout
      proofTrace := none
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "timeout"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := none
      }

/--
Label a batch of formulas with progress reporting.

Prints progress every 100 formulas processed.
Returns the list of all labeled results.
-/
def labelBatch (formulas : List Formula) : IO (List LabeledFormula) := do
  let total := formulas.length
  let mut results : List LabeledFormula := []
  let mut count : Nat := 0
  for φ in formulas do
    let labeled ← labelFormula φ
    results := labeled :: results
    count := count + 1
    if count % 100 == 0 then
      IO.println s!"  Progress: {count}/{total} formulas labeled"
  return results.reverse

/--
Batch statistics: count labeled formulas by category.
-/
structure BatchStats where
  /-- Total formulas processed. -/
  totalCount : Nat
  /-- Number labeled valid. -/
  validCount : Nat
  /-- Number labeled invalid. -/
  invalidCount : Nat
  /-- Number that timed out. -/
  timeoutCount : Nat
  /-- Average decision time in milliseconds. -/
  avgTimeMs : Nat
  deriving Repr, Inhabited

/--
Compute batch statistics from labeled formulas.
-/
def computeBatchStats (labeled : List LabeledFormula) : BatchStats :=
  let init : BatchStats := { totalCount := 0, validCount := 0, invalidCount := 0,
                              timeoutCount := 0, avgTimeMs := 0 }
  let stats := labeled.foldl (fun acc lf =>
    { totalCount := acc.totalCount + 1
      validCount := acc.validCount + (if lf.label == .valid then 1 else 0)
      invalidCount := acc.invalidCount + (if lf.label == .invalid then 1 else 0)
      timeoutCount := acc.timeoutCount + (if lf.label == .timeout then 1 else 0)
      avgTimeMs := acc.avgTimeMs + lf.metrics.decisionTimeMs }
  ) init
  { stats with
    avgTimeMs := if stats.totalCount > 0 then stats.avgTimeMs / stats.totalCount else 0 }

/--
Display batch statistics as a human-readable string.
-/
def BatchStats.display (s : BatchStats) : String :=
  let timeoutRate := if s.totalCount > 0
    then toString (s.timeoutCount * 100 / s.totalCount)
    else "0"
  let validRate := if s.totalCount > 0
    then toString (s.validCount * 100 / s.totalCount)
    else "0"
  s!"Batch Statistics:\n" ++
  s!"  Total: {s.totalCount}\n" ++
  s!"  Valid: {s.validCount} ({validRate}%)\n" ++
  s!"  Invalid: {s.invalidCount}\n" ++
  s!"  Timeout: {s.timeoutCount} ({timeoutRate}%)\n" ++
  s!"  Avg decision time: {s.avgTimeMs}ms"

/-!
## JSON Serialization for Phase 3 API

These methods provide direct JSON serialization on `FormulaLabel` and
`LabeledFormula`, using the primitives from `DataExport.lean`.
-/

/--
Serialize a `FormulaLabel` to a JSON string value.

- `.valid` → `"valid"`
- `.invalid` → `"invalid"`
- `.timeout` → `"timeout"`
-/
def FormulaLabel.toJson : FormulaLabel → String
  | .valid => "\"valid\""
  | .invalid => "\"invalid\""
  | .timeout => "\"timeout\""

/--
Serialize a `ProofTrace` to a JSON object string.

Example:
```json
{"height": 2, "axioms_used": ["modal_t"], "rules_applied": ["modus_ponens"]}
```
-/
def ProofTrace.toJson (pt : ProofTrace) : String :=
  let axiomsArr := listToJsonArray (pt.axioms_used.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  let rulesArr := listToJsonArray (pt.rules_applied.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  "{\"height\": " ++ toString pt.height
  ++ ", \"axioms_used\": " ++ axiomsArr
  ++ ", \"rules_applied\": " ++ rulesArr
  ++ "}"

/--
Serialize a `DifficultyMetrics` to a JSON object string.
-/
def DifficultyMetrics.toJson (dm : DifficultyMetrics) : String :=
  "{\"complexity\": " ++ toString dm.complexity
  ++ ", \"modalDepth\": " ++ toString dm.modalDepth
  ++ ", \"temporalDepth\": " ++ toString dm.temporalDepth
  ++ ", \"impCount\": " ++ toString dm.impCount
  ++ ", \"atomCount\": " ++ toString dm.atomCount
  ++ ", \"decisionTimeMs\": " ++ toString dm.decisionTimeMs
  ++ ", \"difficultyTier\": \"" ++ escapeJsonString dm.difficultyTier ++ "\""
  ++ "}"

/--
Serialize a `SemanticCountermodelSummary` to a JSON object string.
-/
def SemanticCountermodelSummary.toJson (s : SemanticCountermodelSummary) : String :=
  let worldsStr := listToJsonArray (s.worlds.map toString)
  let timesStr := listToJsonArray (s.times.map toString)
  let constraintsStr := listToJsonArray (s.timeConstraints.map fun (a, b) =>
    "[" ++ toString a ++ ", " ++ toString b ++ "]")
  "{\"worlds\": " ++ worldsStr
  ++ ", \"times\": " ++ timesStr
  ++ ", \"time_constraints\": " ++ constraintsStr
  ++ ", \"world_count\": " ++ toString s.worldCount
  ++ ", \"time_count\": " ++ toString s.timeCount
  ++ "}"

/--
Serialize a `LabeledFormula` to a complete JSON object string.

Includes all fields: formula, features, decision result, proof trace,
countermodel (simple, enriched, semantic), metrics, and rule profile.
-/
def LabeledFormula.toJson (lf : LabeledFormula) : String :=
  let proofStr := match lf.proofTrace with
    | none => "null"
    | some pt => pt.toJson
  let cmStr := match lf.countermodel with
    | none => "null"
    | some cm => cm.toJson
  let rpStr := match lf.ruleProfile with
    | none => "null"
    | some rp => rp.toJson
  let cmConsStr := match lf.countermodelConsistent with
    | none => "null"
    | some true => "true"
    | some false => "false"
  let ecmStr := match lf.enrichedCountermodel with
    | none => "null"
    | some ecm => ecm.toJson
  let scmStr := match lf.semanticCountermodelSummary with
    | none => "null"
    | some s => s.toJson
  let reconStr := match lf.proofReconstructionMethod with
    | none => "null"
    | some m => "\"" ++ escapeJsonString m ++ "\""
  "{\"formula\": " ++ lf.formula.toJson
  ++ ", \"formula_string\": \"" ++ escapeJsonString lf.formula.prettyPrint ++ "\""
  ++ ", \"features\": " ++ lf.patternKey.toJson
  ++ ", \"decision\": " ++ lf.label.toJson
  ++ ", \"decision_method\": \"" ++ escapeJsonString lf.decisionMethod ++ "\""
  ++ ", \"proof_reconstruction_method\": " ++ reconStr
  ++ ", \"proof\": " ++ proofStr
  ++ ", \"rule_profile\": " ++ rpStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"countermodel_consistent\": " ++ cmConsStr
  ++ ", \"enriched_countermodel\": " ++ ecmStr
  ++ ", \"semantic_countermodel\": " ++ scmStr
  ++ ", \"metrics\": " ++ lf.metrics.toJson
  ++ "}"

end Bimodal.Automation
