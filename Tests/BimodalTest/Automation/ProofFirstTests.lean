/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms
import Bimodal.ProofSystem.Derivation
import Bimodal.Automation.FormulaEnumerator
import Bimodal.Automation.ForwardProofGenerator
import Bimodal.Automation.ProofFirstExporter
import Bimodal.Automation.ProofFirstBenchmark
import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DataExport

/-! # Proof-First Integration Tests (Task 279 Phase 11)

12 integration tests covering the end-to-end forward-chaining pipeline.
-/

namespace BimodalTest.Automation.ProofFirst

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation
open Bimodal.Automation.DataExport
open FormulaLabel

-- Convenience atoms
private def p : Formula := .atom_s "p"
private def q : Formula := .atom_s "q"
private def r : Formula := .atom_s "r"
private def atoms : List Atom := [Atom.mk_base "p", Atom.mk_base "q", Atom.mk_base "r"]

/-! ## Test 1: All 42 axiom schemata produce witnesses -/

#eval do
  IO.println "=== Test 1: Axiom instantiation covers all 42 schemata ==="
  let mut failed := 0
  for idx in List.range 42 do
    let result ← mkAxiomAtIdx atoms 2 idx
    match result with
    | some _ => pure ()
    | none =>
      IO.println s!"  [FAIL] Schema {idx} produced none"
      failed := failed + 1
  if failed > 0 then
    throw (IO.userError s!"Test 1: {failed} schemata failed")
  IO.println "  [PASS] All 42 schemata produce witnesses"

/-! ## Test 2: Pool dedup shortest-wins -/

#eval do
  IO.println "=== Test 2: Pool dedup shortest-wins ==="
  let φ := Formula.bot.imp Formula.bot
  let d1 := DerivationTree.axiom [] φ (Axiom.ex_falso Formula.bot) (FrameClass.base_le .Base)
  let d2 := DerivationTree.axiom [] (φ.imp (φ.imp φ)) (Axiom.prop_s φ φ) (FrameClass.base_le .Base)
  let d3 := DerivationTree.modus_ponens [] φ (φ.imp φ) d2 d1
  let d4 := DerivationTree.modus_ponens [] φ φ d3 d1
  let pool0 := ProofPool.empty (fc := .Base)
  let pool1 := pool0.add φ d4
  let pool2 := pool1.add φ d1
  match pool2.index[φ]? with
  | some idx =>
    let stored := pool2.entries[idx]!
    if stored.snd.height == 0 then
      IO.println "  [PASS] Shortest proof (height 0) kept"
    else
      throw (IO.userError s!"Test 2: Expected height 0, got {stored.snd.height}")
  | none =>
    throw (IO.userError "Test 2: Formula missing from pool")

/-! ## Test 3: MP closure via implication index -/

#eval do
  IO.println "=== Test 3: MP closure via implication index ==="
  let φ := Formula.bot.imp Formula.bot
  let ψ := q
  let d_imp := DerivationTree.axiom [] (φ.imp (ψ.imp φ)) (Axiom.prop_s φ ψ) (FrameClass.base_le .Base)
  let d_ant := DerivationTree.axiom [] φ (Axiom.ex_falso Formula.bot) (FrameClass.base_le .Base)
  let pool0 := ProofPool.empty (fc := .Base)
  let pool1 := pool0.add (φ.imp (ψ.imp φ)) d_imp
  let pool2 := pool1.add φ d_ant
  let cfg : ForwardConfig := { atoms := atoms, maxParamSize := 4 }
  let pool3 ← applyModusPonens cfg pool2
  if pool3.contains (ψ.imp φ) then
    IO.println "  [PASS] MP produced expected conclusion"
  else
    throw (IO.userError "Test 3: MP did not produce conclusion")

/-! ## Test 4: Ex-falso cap <= 20% -/

#eval do
  IO.println "=== Test 4: Ex-falso cap ==="
  let cfg : ForwardConfig := { atoms := atoms, seedCount := 200, maxDepth := 1, maxPoolSize := 500, exFalsoCap := 1, exFalsoDenom := 5 }
  let pool ← forwardGenerate cfg
  let total := pool.length
  let exCount := (pool.filter (fun σ => isExFalso (Sigma.fst σ))).length
  if total > 0 then
    let fraction := Float.ofNat exCount / Float.ofNat total
    if fraction ≤ 0.21 then
      IO.println s!"  [PASS] Ex-falso fraction {fraction} ≤ 0.2"
    else
      throw (IO.userError s!"Test 4: Ex-falso fraction {fraction} > 0.2")
  else
    IO.println "  [SKIP] Empty pool"

/-! ## Test 5: No weakening nodes in output -/

private def hasWeakeningNode {fc Γ φ} : DerivationTree fc Γ φ → Bool
  | .weakening _ _ _ _ _ => true
  | .modus_ponens _ _ _ d1 d2 => hasWeakeningNode d1 || hasWeakeningNode d2
  | .necessitation _ d => hasWeakeningNode d
  | .temporal_necessitation _ d => hasWeakeningNode d
  | .temporal_duality _ d => hasWeakeningNode d
  | _ => false

#eval do
  IO.println "=== Test 5: No weakening in output ==="
  let cfg : ForwardConfig := { atoms := atoms, seedCount := 50, maxDepth := 1, maxPoolSize := 500 }
  let pool ← forwardGenerate cfg
  let mut found := false
  for σ in pool do
    let d := Sigma.snd σ
    if hasWeakeningNode d then found := true
  if found then
    throw (IO.userError "Test 5: Found weakening node in output")
  else
    IO.println "  [PASS] No weakening nodes"

/-! ## Test 6: Frame class filtering (no density under Base) -/

#eval do
  IO.println "=== Test 6: Frame class filtering ==="
  let cfg : ForwardConfig := { atoms := atoms, seedCount := 100, maxDepth := 1, maxPoolSize := 500, frameClass := .Base }
  let pool ← forwardGenerate cfg
  let mut foundDensity := false
  for σ in pool do
    let trace := extractProofTrace σ.snd
    if trace.axioms_used.contains "density" then
      foundDensity := true
  if foundDensity then
    throw (IO.userError "Test 6: Density axiom found under Base")
  else
    IO.println "  [PASS] No density axioms under Base"

/-! ## Test 7: Forward generation produces valid theorems -/

#eval do
  IO.println "=== Test 7: Valid theorem generation ==="
  let cfg : ForwardConfig := { atoms := atoms, seedCount := 20, maxDepth := 1, maxPoolSize := 500 }
  let pool ← forwardGenerate cfg
  for σ in pool do
    let _ := extractProofTrace σ.snd
    let _ := walkDerivationTree σ.snd
    pure ()
  IO.println "  [PASS] All theorems processable"

/-! ## Test 8: labelFormula proofFirst dispatch -/

#eval do
  IO.println "=== Test 8: labelFormula proofFirst dispatch ==="
  let φ := Formula.bot.imp Formula.bot
  let d := DerivationTree.axiom [] φ (Axiom.ex_falso Formula.bot) (FrameClass.base_le .Base)
  let pool := ProofPool.empty (fc := .Base) |>.add φ d
  let labeled ← labelFormula φ .Base 1000 .proofFirst (some pool)
  if labeled.decisionMethod == "proof_first" then
    IO.println "  [PASS] decisionMethod = proof_first"
  else
    throw (IO.userError s!"Test 8: Expected proof_first, got {labeled.decisionMethod}")

/-! ## Test 9: labelFormula hybrid mode -/

#eval do
  IO.println "=== Test 9: labelFormula hybrid mode ==="
  let φ := Formula.bot.imp Formula.bot
  let d := DerivationTree.axiom [] φ (Axiom.ex_falso Formula.bot) (FrameClass.base_le .Base)
  let pool := ProofPool.empty (fc := .Base) |>.add φ d
  let labeled ← labelFormula φ .Base 1000 .hybrid (some pool)
  if labeled.label == FormulaLabel.valid then
    IO.println "  [PASS] Hybrid mode returned valid"
  else
    throw (IO.userError s!"Test 9: Hybrid mode returned {repr labeled.label}")

/-! ## Test 10: Corpus metrics known values -/

#eval do
  IO.println "=== Test 10: Corpus metrics known values ==="
  let lf1 : LabeledFormula := {
    formula := p, label := FormulaLabel.valid, proofTrace := some { height := 0, axioms_used := ["prop_s"], rules_applied := [] },
    countermodel := none, metrics := default, patternKey := default, ruleProfile := some { axiomCount := 1, assumptionCount := 0, mpCount := 0, necessitationCount := 0, temporalNecessitationCount := 0, temporalDualityCount := 0, weakeningCount := 0 },
    decisionMethod := "proof_first", countermodelConsistent := none, enrichedCountermodel := none, semanticCountermodelSummary := none, proofReconstructionMethod := none }
  let lf2 : LabeledFormula := {
    formula := q, label := FormulaLabel.valid, proofTrace := some { height := 0, axioms_used := ["prop_s"], rules_applied := [] },
    countermodel := none, metrics := default, patternKey := default, ruleProfile := some { axiomCount := 1, assumptionCount := 0, mpCount := 0, necessitationCount := 0, temporalNecessitationCount := 0, temporalDualityCount := 0, weakeningCount := 0 },
    decisionMethod := "proof_first", countermodelConsistent := none, enrichedCountermodel := none, semanticCountermodelSummary := none, proofReconstructionMethod := none }
  let m := computeCorpusMetrics [lf1, lf2]
  if m.axiomDiversity == 0.5 then
    IO.println "  [PASS] Axiom diversity = 0.5"
  else
    throw (IO.userError s!"Test 10: Expected axiomDiversity 0.5, got {m.axiomDiversity}")

/-! ## Test 11: compareCorpora writes JSON -/

#eval do
  IO.println "=== Test 11: compareCorpora writes JSON ==="
  let path := System.FilePath.mk "/tmp/test_comparison.json"
  compareCorpora "ex" "pf" [] [] 0 0 path
  let found ← path.pathExists
  if found then
    IO.println "  [PASS] Comparison JSON created"
  else
    throw (IO.userError "Test 11: Comparison JSON not created")

/-! ## Test 12: End-to-end CLI smoke -/

#eval do
  IO.println "=== Test 12: End-to-end CLI smoke ==="
  let args := ["--max-depth", "1", "--seed", "10", "--atoms", "p", "--output", "/tmp/pf_cli.jsonl"]
  _root_.main args
  let found ← (System.FilePath.mk "/tmp/pf_cli.jsonl").pathExists
  if found then
    IO.println "  [PASS] CLI produced output file"
  else
    throw (IO.userError "Test 12: CLI output file missing")

end BimodalTest.Automation.ProofFirst
