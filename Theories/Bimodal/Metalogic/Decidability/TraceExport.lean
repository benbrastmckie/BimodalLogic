/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.Tableau
import Bimodal.Metalogic.Decidability.TraceCertificate
import Bimodal.Automation.DataExport

/-!
# JSON Serialization for Trace Certificates

This module provides string-based JSON serialization for the trace certificate
data types defined in `Bimodal.Metalogic.Decidability.TraceCertificate`.

The serialization mirrors the style of `Bimodal.Automation.DataExport`:
- Field names are quoted strings.
- Lists are rendered as JSON arrays.
- Strings are escaped using `escapeJsonString` (re-used from `DataExport`).
- The result is one JSON object per certificate (intended to be written
  as one JSONL line per run).

## Main Definitions

- `TableauRule.toJson` — String name of a rule (e.g., "andPos").
- `Sign.toJson` — String name of a sign (e.g., "pos").
- `FrameClass.toJson` — String name of a frame class (e.g., "Dense").
- `CertOutcome.toJson` — String name of a certificate outcome.
- `ClosureReason.toJson` — JSON object for a closure reason.
- `Label.toJson` — JSON object for a label (world, time).
- `SignedFormula.toJson` — JSON object for a signed formula.
- `TraceEntry.toJson` — JSON object for a trace entry (5 cases).
- `ProofCertificate.toJsonString` — JSON object for a full certificate.
- `TraceResult.toJsonString` — JSON object for a `TraceResult`.

## References

- `Bimodal.Automation.DataExport` — String-based JSON helpers.
- `Bimodal.Metalogic.Decidability.TraceCertificate` — Data types.
- `tableau_rule_firing_traces` — the rule-firing trace deliverable exported here.
-/

namespace Bimodal.Metalogic.Decidability.TraceExport

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation.DataExport

/-!
## Primitive Type Serialization
-/

/-- String name of a `TableauRule` (mirrors `ruleToString`). -/
def tableauRuleToJsonString (rule : TableauRule) : String :=
  "\"" ++ escapeJsonString (ruleToString rule) ++ "\""

/-- String name of a `Sign`. -/
def signToJsonString (s : Sign) : String :=
  match s with
  | .pos => "\"pos\""
  | .neg => "\"neg\""

/-- String name of a `FrameClass`. -/
def frameClassToJsonString (fc : FrameClass) : String :=
  match fc with
  | .Base     => "\"Base\""
  | .Dense    => "\"Dense\""
  | .Discrete => "\"Discrete\""

/-- String name of a `CertOutcome`. -/
def certOutcomeToJsonString (o : CertOutcome) : String :=
  match o with
  | .validProof  => "\"valid_proof\""
  | .countermodel => "\"countermodel\""
  | .timeout     => "\"timeout\""
  | .blocked     => "\"blocked\""

/-!
## Label and SignedFormula Serialization
-/

/-- JSON object for a `Label`. -/
def labelToJsonString (l : Label) : String :=
  "{\"world\": " ++ toString l.world ++
  ", \"time\": " ++ toString l.time ++ "}"

/-- JSON object for a `SignedFormula`. -/
def signedFormulaToJsonString (sf : SignedFormula) : String :=
  "{\"sign\": " ++ signToJsonString sf.sign ++
  ", \"formula\": " ++ sf.formula.toJson ++
  ", \"label\": " ++ labelToJsonString sf.label ++ "}"

/-!
## ClosureReason Serialization
-/

/-- JSON object for a `ClosureReason`. -/
def closureReasonToJsonString (reason : ClosureReason) : String :=
  match reason with
  | .contradiction φ l =>
      "{\"kind\": \"contradiction\"" ++
      ", \"formula\": " ++ φ.toJson ++
      ", \"world\": " ++ toString l.world ++
      ", \"time\": " ++ toString l.time ++ "}"
  | .botPos l =>
      "{\"kind\": \"bot_pos\"" ++
      ", \"world\": " ++ toString l.world ++
      ", \"time\": " ++ toString l.time ++ "}"
  | .axiomNeg φ _ l =>
      "{\"kind\": \"axiom_neg\"" ++
      ", \"formula\": " ++ φ.toJson ++
      ", \"world\": " ++ toString l.world ++
      ", \"time\": " ++ toString l.time ++ "}"

/-!
## TraceEntry Serialization
-/

/-- JSON object for a `TraceEntry`. -/
def traceEntryToJsonString (entry : TraceEntry) : String :=
  match entry with
  | .ruleFired stepIndex rule sign formula label produced isPersistent branchDepth =>
      "{\"event\": \"rule_fired\"" ++
      ", \"step\": " ++ toString stepIndex ++
      ", \"rule\": " ++ tableauRuleToJsonString rule ++
      ", \"sign\": " ++ signToJsonString sign ++
      ", \"formula\": " ++ formula.toJson ++
      ", \"label\": " ++ labelToJsonString label ++
      ", \"produced\": " ++ listToJsonArray (produced.map signedFormulaToJsonString) ++
      ", \"is_persistent\": " ++ toString isPersistent ++
      ", \"branch_depth\": " ++ toString branchDepth ++
      "}"
  | .branchCreated stepIndex parentBranch newBranchId fromRule =>
      "{\"event\": \"branch_created\"" ++
      ", \"step\": " ++ toString stepIndex ++
      ", \"parent\": " ++ toString parentBranch ++
      ", \"new_branch_id\": " ++ toString newBranchId ++
      ", \"from_rule\": " ++ tableauRuleToJsonString fromRule ++
      "}"
  | .branchClosed stepIndex branchId reason =>
      "{\"event\": \"branch_closed\"" ++
      ", \"step\": " ++ toString stepIndex ++
      ", \"branch_id\": " ++ toString branchId ++
      ", \"reason\": " ++ closureReasonToJsonString reason ++
      "}"
  | .blockingFired stepIndex blockedTime ancestorTime =>
      "{\"event\": \"blocking_fired\"" ++
      ", \"step\": " ++ toString stepIndex ++
      ", \"blocked_time\": " ++ toString blockedTime ++
      ", \"ancestor_time\": " ++ toString ancestorTime ++
      "}"
  | .fuelExhausted stepIndex fuelRemaining =>
      "{\"event\": \"fuel_exhausted\"" ++
      ", \"step\": " ++ toString stepIndex ++
      ", \"fuel_remaining\": " ++ toString fuelRemaining ++
      "}"

/-!
## Fingerprint Serialization
-/

/-- JSON object for the `axiomFingerprint` map. -/
def fingerprintToJsonString (fp : Std.HashMap String Nat) : String :=
  -- Collect entries as (key, value) pairs, then render as a JSON object.
  -- The `Std.HashMap` does not preserve insertion order, so we sort the
  -- entries by key for deterministic output.
  let entries : List (String × Nat) := fp.toList
  let sortedEntries := entries.mergeSort (fun a b => a.1 < b.1)
  "{" ++ String.intercalate ", " (sortedEntries.map fun (k, v) =>
    "\"" ++ escapeJsonString k ++ "\": " ++ toString v) ++ "}"

/-!
## Certificate and Result Serialization
-/

/-- JSON object for a `ProofCertificate`. -/
def proofCertificateToJsonString (cert : ProofCertificate) : String :=
  "{\"formula\": " ++ cert.formula.toJson ++
  ", \"formula_pretty\": \"" ++ escapeJsonString cert.formula.prettyPrint ++ "\"" ++
  ", \"frame_class\": " ++ frameClassToJsonString cert.frameClass ++
  ", \"outcome\": " ++ certOutcomeToJsonString cert.outcome ++
  ", \"total_steps\": " ++ toString cert.totalSteps ++
  ", \"max_depth\": " ++ toString cert.maxDepth ++
  ", \"branching_factor\": " ++ Float.toString cert.branchingFactor ++
  ", \"elapsed_ms\": " ++ toString cert.elapsedMs ++
  ", \"axiom_fingerprint\": " ++ fingerprintToJsonString cert.axiomFingerprint ++
  ", \"trace\": " ++ listToJsonArray (cert.trace.map traceEntryToJsonString) ++
  "}"

/-- JSON object for a `TraceResult`. -/
def traceResultToJsonString (result : TraceResult) : String :=
  match result with
  | .success cert =>
      "{\"status\": \"success\"" ++
      ", \"certificate\": " ++ proofCertificateToJsonString cert ++
      "}"
  | .failure (.outOfFuel trace steps) =>
      "{\"status\": \"failure\"" ++
      ", \"failure_kind\": \"out_of_fuel\"" ++
      ", \"steps_completed\": " ++ toString steps ++
      ", \"trace\": " ++ listToJsonArray (trace.map traceEntryToJsonString) ++
      "}"
  | .failure (.unsaturatable trace openBranch) =>
      "{\"status\": \"failure\"" ++
      ", \"failure_kind\": \"unsaturatable\"" ++
      ", \"open_branch\": " ++ listToJsonArray (openBranch.map signedFormulaToJsonString) ++
      ", \"trace\": " ++ listToJsonArray (trace.map traceEntryToJsonString) ++
      "}"
  | .failure (.applyRulePanic trace rule sf) =>
      "{\"status\": \"failure\"" ++
      ", \"failure_kind\": \"apply_rule_panic\"" ++
      ", \"rule\": " ++ tableauRuleToJsonString rule ++
      ", \"signed_formula\": " ++ signedFormulaToJsonString sf ++
      ", \"trace\": " ++ listToJsonArray (trace.map traceEntryToJsonString) ++
      "}"

end Bimodal.Metalogic.Decidability.TraceExport
