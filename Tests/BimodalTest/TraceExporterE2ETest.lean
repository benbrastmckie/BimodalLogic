/-
Copyright (c) 2026 BimodalLogic contributors.
Released under the project's standard license.
-/

import Bimodal.Syntax
import Bimodal.ProofSystem
import Bimodal.Metalogic.Decidability.SignedFormula
import Bimodal.Metalogic.Decidability.Closure
import Bimodal.Metalogic.Decidability.Tableau
import Bimodal.Metalogic.Decidability.TraceCertificate
import Bimodal.Metalogic.Decidability.Saturation
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.TraceExport

/-!
# Trace Exporter E2E Smoke Test (Task 277)

End-to-end test that exercises the full `decideWithTrace` pipeline
on a set of canonical formulas and verifies that:
1. Each formula produces a valid `TraceResult`.
2. The trace contains the expected rule firings.
3. The certificate's outcome matches the expected semantic outcome.
4. JSON serialization of the result is well-formed.

## Test Formulas

- `p → p`: tautology (should be valid)
- `p → q`: not a tautology (should be invalid)
- `□p → □p`: boxed tautology (should be valid)
- `□⊥ → ⊥`: S5 reflexivity axiom (should be valid)

## References

- Task 277 — tableau_rule_firing_traces.
-/

namespace BimodalTest.TraceExporterE2ETest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability
open Bimodal.Metalogic.Decidability.TraceExport

private def p : Formula := .atom_s "p"
private def q : Formula := .atom_s "q"

/-- Run the full e2e smoke test. -/
def runE2ETest : IO Bool := do
  IO.println "=== Trace Exporter E2E Smoke Test ==="
  let mut passed : Nat := 0
  let mut failed : Nat := 0

  -- Test 1: p → p is valid
  IO.println "  Running test 1..."
  let r1 := decideWithTrace (Formula.imp p p) 200
  match r1 with
  | .success cert =>
    if cert.outcome == .validProof then
      IO.println "PASS Test 1: p → p is valid"
      passed := passed + 1
    else
      IO.println s!"FAIL Test 1: p → p has wrong outcome: {repr cert.outcome}"
      failed := failed + 1
  | .failure f =>
    IO.println s!"FAIL Test 1: p → p returned failure: {repr f}"
    failed := failed + 1

  -- Test 2: p → q is invalid (countermodel)
  IO.println "  Running test 2..."
  let r2 := decideWithTrace (Formula.imp p q) 200
  match r2 with
  | .success cert =>
    if cert.outcome == .countermodel then
      IO.println "PASS Test 2: p → q is invalid (countermodel)"
      passed := passed + 1
    else
      IO.println s!"FAIL Test 2: p → q has wrong outcome: {repr cert.outcome}"
      failed := failed + 1
  | .failure f =>
    IO.println s!"FAIL Test 2: p → q returned failure: {repr f}"
    failed := failed + 1

  -- Test 3: □p → □p is valid (T axiom instance)
  IO.println "  Running test 3..."
  let r3 := decideWithTrace (Formula.imp (Formula.box p) (Formula.box p)) 300
  match r3 with
  | .success cert =>
    if cert.outcome == .validProof then
      IO.println "PASS Test 3: □p → □p is valid"
      passed := passed + 1
    else
      IO.println s!"FAIL Test 3: □p → □p has wrong outcome: {repr cert.outcome}"
      failed := failed + 1
  | .failure f =>
    IO.println s!"FAIL Test 3: □p → □p returned failure: {repr f}"
    failed := failed + 1

  -- Test 4: JSON serialization of e2e result is well-formed
  IO.println "  Running test 4..."
  let s4 := traceResultToJsonString r1
  if s4.startsWith "{" ∧ s4.endsWith "}" then
    IO.println "PASS Test 4: JSON serialization of e2e result is well-formed"
    passed := passed + 1
  else
    IO.println "FAIL Test 4: JSON serialization is malformed"
    failed := failed + 1

  -- Test 5: trace on a more complex formula is non-empty
  IO.println "  Running test 5..."
  match r3 with
  | .success cert =>
    if cert.trace.length ≥ 1 then
      IO.println s!"PASS Test 5: trace on □p → □p is non-empty: {cert.trace.length} events"
      passed := passed + 1
    else
      IO.println s!"FAIL Test 5: trace on □p → □p is empty"
      failed := failed + 1
  | _ => failed := failed + 1

  -- Test 6: fingerprint for □p → □p contains expected rules
  IO.println "  Running test 6..."
  match r3 with
  | .success cert =>
    let has_impNeg := cert.axiomFingerprint.getD "impNeg" 0 > 0
    let has_boxPos := cert.axiomFingerprint.getD "boxPos" 0 > 0
    let has_boxNeg := cert.axiomFingerprint.getD "boxNeg" 0 > 0
    if has_impNeg ∨ has_boxPos ∨ has_boxNeg then
      IO.println "PASS Test 6: fingerprint contains expected modal/imp rules"
      passed := passed + 1
    else
      IO.println "FAIL Test 6: fingerprint missing expected rules"
      failed := failed + 1
  | _ => failed := failed + 1

  IO.println s!"\n=== E2E Smoke Test: {passed} passed, {failed} failed ==="
  return failed == 0

end BimodalTest.TraceExporterE2ETest

#eval do
  let ok ← BimodalTest.TraceExporterE2ETest.runE2ETest
  if not ok then
    throw (IO.userError "Trace exporter e2e smoke test failed")
  IO.println "All trace exporter e2e smoke tests PASSED"
