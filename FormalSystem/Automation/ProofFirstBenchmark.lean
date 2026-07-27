/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.DatasetGenerator
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.SuccessPatterns
import Std.Data.HashMap
import Std.Data.HashSet

/-! # Proof-First Benchmark

Computes 8 cross-corpus metrics for labeled formula datasets and provides a
side-by-side comparison utility.

## Metrics

1. **Axiom diversity** — unique axiom names / total axiom applications
2. **Proof depth distribution** — histogram of proof tree heights
3. **Temporal axiom usage** — fraction of proofs that use at least one temporal axiom
4. **Modal axiom usage** — fraction of proofs that use at least one modal axiom
5. **Rule profile distribution** — aggregated rule firing counts
6. **Ex_falso dominance** — fraction of valid proofs containing the ex_falso axiom
7. **Operator diversity** — distinct goal categories / total categories
8. **Generation cost** — wall-clock milliseconds (supplied by caller)
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.Automation.DataExport

/-- Temporal axiom names used for metric classification. -/
def temporalAxiomNames : List String :=
  [ "serial_future", "serial_past", "left_mono_until_G", "left_mono_since_H"
  , "right_mono_until", "right_mono_since", "connect_future", "connect_past"
  , "enrichment_until", "enrichment_since", "self_accum_until", "self_accum_since"
  , "absorb_until", "absorb_since", "linear_until", "linear_since"
  , "until_F", "since_P", "temp_linearity", "temp_linearity_past"
  , "F_until_equiv", "P_since_equiv" ]

/-- Modal axiom names used for metric classification. -/
def modalAxiomNames : List String :=
  [ "modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist" ]

/-- Metrics computed over a corpus of labeled formulas. -/
structure CorpusMetrics where
  /-- Unique axiom names divided by total axiom applications. -/
  axiomDiversity : Float
  /-- Histogram of proof heights. -/
  proofDepthHistogram : List (Nat × Nat)
  /-- Fraction of proofs using a temporal axiom. -/
  temporalAxiomUsage : Float
  /-- Fraction of proofs using a modal axiom. -/
  modalAxiomUsage : Float
  /-- Aggregated rule firing counts. -/
  ruleProfileDistribution : Std.HashMap String Nat
  /-- Fraction of valid proofs containing ex_falso. -/
  exFalsoDominance : Float
  /-- Distinct goal categories divided by total categories (8). -/
  operatorDiversity : Float
  /-- Wall-clock generation cost in milliseconds. -/
  generationCostMs : Nat
  /-- Total number of valid theorems. -/
  totalTheorems : Nat
  /-- Total number of axiom applications across all proofs. -/
  totalAxiomApplications : Nat
  deriving Inhabited

/-- Count how many times each key appears in a list. -/
private def countKeys {α : Type} [BEq α] [Hashable α] (xs : List α) : Std.HashMap α Nat :=
  xs.foldl (fun m k =>
    match m[k]? with
    | some n => m.insert k (n + 1)
    | none => m.insert k 1) {}

/-- Insert or increment a count in a string-keyed hash map. -/
private def incrString (m : Std.HashMap String Nat) (k : String) (n : Nat) : Std.HashMap String Nat :=
  match m[k]? with
  | some prev => m.insert k (prev + n)
  | none => m.insert k n

/-- Check whether a proof trace uses any axiom from a given name list. -/
private def usesAnyAxiom (pt : ProofTrace) (names : List String) : Bool :=
  pt.axiomsUsed.any (fun ax => names.contains ax)

/-- Compute all 8 corpus metrics from a labeled formula list. -/
def computeCorpusMetrics (labeled : List LabeledFormula) (costMs : Nat := 0) : CorpusMetrics :=
  let valid := labeled.filter (fun (lf : LabeledFormula) => lf.label == .valid)
  let totalValid := valid.length
  -- Axiom diversity
  let allAxioms := valid.filterMap (fun (lf : LabeledFormula) => lf.proofTrace.map (·.axiomsUsed)) |>.flatten
  let uniqueAxioms := allAxioms.eraseDups.length
  let totalAxApps := valid.filterMap (fun (lf : LabeledFormula) => lf.ruleProfile.map (·.axiomCount)) |>.foldl (· + ·) 0
  let axDiv := if totalAxApps > 0 then Float.ofNat uniqueAxioms / Float.ofNat totalAxApps else 0.0
  -- Proof depth histogram
  let heights := valid.filterMap (fun (lf : LabeledFormula) => lf.proofTrace.map (·.height))
  let depthHist := countKeys heights |>.toList
  -- Temporal / modal usage
  let traces := valid.filterMap (fun (lf : LabeledFormula) => lf.proofTrace)
  let temporalCount := (traces.filter (fun pt => usesAnyAxiom pt temporalAxiomNames)).length
  let modalCount := (traces.filter (fun pt => usesAnyAxiom pt modalAxiomNames)).length
  let tempUsage := if totalValid > 0 then Float.ofNat temporalCount / Float.ofNat totalValid else 0.0
  let modalUsage := if totalValid > 0 then Float.ofNat modalCount / Float.ofNat totalValid else 0.0
  -- Rule profile distribution
  let ruleMap := valid.filterMap (fun (lf : LabeledFormula) => lf.ruleProfile) |>.foldl (fun acc rp =>
    let acc1 := incrString acc "axiomCount" rp.axiomCount
    let acc2 := incrString acc1 "assumptionCount" rp.assumptionCount
    let acc3 := incrString acc2 "mpCount" rp.mpCount
    let acc4 := incrString acc3 "necessitationCount" rp.necessitationCount
    let acc5 := incrString acc4 "temporalNecessitationCount" rp.temporalNecessitationCount
    let acc6 := incrString acc5 "temporalDualityCount" rp.temporalDualityCount
    let acc7 := incrString acc6 "weakeningCount" rp.weakeningCount
    acc7) {}
  -- Ex_falso dominance
  let exFalsoCount := (traces.filter (fun pt => pt.axiomsUsed.contains "ex_falso")).length
  let exDom := if totalValid > 0 then Float.ofNat exFalsoCount / Float.ofNat totalValid else 0.0
  -- Operator diversity
  let categories := labeled.map (fun lf => goalCategory lf.formula)
  let distinct := categories.eraseDups.length
  let opDiv := Float.ofNat distinct / 8.0
  { axiomDiversity := axDiv
  , proofDepthHistogram := depthHist
  , temporalAxiomUsage := tempUsage
  , modalAxiomUsage := modalUsage
  , ruleProfileDistribution := ruleMap
  , exFalsoDominance := exDom
  , operatorDiversity := opDiv
  , generationCostMs := costMs
  , totalTheorems := totalValid
  , totalAxiomApplications := totalAxApps }

/-- Format a corpus metrics record as a JSON object string. -/
def CorpusMetrics.toJson (m : CorpusMetrics) : String :=
  let depthStr := m.proofDepthHistogram.map (fun (d, n) => "[" ++ toString d ++ "," ++ toString n ++ "]") |> String.intercalate ","
  let ruleStr := m.ruleProfileDistribution.toList.map (fun (k, v) => "\"" ++ k ++ "\":" ++ toString v) |> String.intercalate ","
  "{\"axiomDiversity\": " ++ toString m.axiomDiversity
    ++ ", \"proofDepthHistogram\": [" ++ depthStr ++ "]"
    ++ ", \"temporalAxiomUsage\": " ++ toString m.temporalAxiomUsage
    ++ ", \"modalAxiomUsage\": " ++ toString m.modalAxiomUsage
    ++ ", \"ruleProfileDistribution\": {" ++ ruleStr ++ "}"
    ++ ", \"exFalsoDominance\": " ++ toString m.exFalsoDominance
    ++ ", \"operatorDiversity\": " ++ toString m.operatorDiversity
    ++ ", \"generationCostMs\": " ++ toString m.generationCostMs
    ++ ", \"totalTheorems\": " ++ toString m.totalTheorems
    ++ ", \"totalAxiomApplications\": " ++ toString m.totalAxiomApplications
    ++ "}"

/-- Print a side-by-side comparison table of two corpora. -/
def compareCorpora (name1 name2 : String) (corpus1 corpus2 : List LabeledFormula)
    (cost1 cost2 : Nat := 0) (jsonPath : System.FilePath := System.FilePath.mk "data/comparison.json")
    : IO Unit := do
  let m1 := computeCorpusMetrics corpus1 cost1
  let m2 := computeCorpusMetrics corpus2 cost2
  IO.println "============================================"
  IO.println ("  Metric                  " ++ name1 ++ "          " ++ name2)
  IO.println "============================================"
  IO.println ("  Axiom diversity         " ++ toString m1.axiomDiversity ++ "  " ++ toString m2.axiomDiversity)
  IO.println ("  Temporal axiom usage    " ++ toString m1.temporalAxiomUsage ++ "  " ++ toString m2.temporalAxiomUsage)
  IO.println ("  Modal axiom usage       " ++ toString m1.modalAxiomUsage ++ "  " ++ toString m2.modalAxiomUsage)
  IO.println ("  Ex_falso dominance      " ++ toString m1.exFalsoDominance ++ "  " ++ toString m2.exFalsoDominance)
  IO.println ("  Operator diversity      " ++ toString m1.operatorDiversity ++ "  " ++ toString m2.operatorDiversity)
  IO.println ("  Total theorems          " ++ toString m1.totalTheorems ++ "  " ++ toString m2.totalTheorems)
  IO.println ("  Generation cost (ms)    " ++ toString m1.generationCostMs ++ "  " ++ toString m2.generationCostMs)
  IO.println "============================================"
  let report :=
    "{\"corpus1\":" ++ m1.toJson ++ ", \"corpus2\":" ++ m2.toJson ++ "}"
  IO.FS.writeFile jsonPath report
  IO.println ("Comparison JSON written to " ++ toString jsonPath)

end FormalSystem.Automation
