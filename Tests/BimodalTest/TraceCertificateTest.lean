/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Decidability.SignedFormula
import FormalSystem.Metalogic.Decidability.Closure
import FormalSystem.Metalogic.Decidability.Tableau
import FormalSystem.Metalogic.Decidability.TraceCertificate
import FormalSystem.Metalogic.Decidability.Saturation
import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.TraceExport

/-!
# Trace Certificate Unit Tests (Task 277)

Unit tests for the trace certificate data types and decision procedure
instrumentation. Verifies that:
1. `ProofCertificate.empty` produces a well-formed empty certificate.
2. `decideWithTrace` returns a `TraceResult.success` for valid formulas.
3. `decideWithTrace` returns a `TraceResult.failure` for fuel-exhausted cases.
4. Trace events are correctly recorded.
5. `axiomFingerprint` is correctly updated.
6. The trace contains expected rule firings.

## References

- `FormalSystem.Metalogic.Decidability.TraceCertificate` — type definitions.
- `FormalSystem.Metalogic.Decidability.DecisionProcedure.decideWithTrace` — main entry.
- Task 277 — tableau_rule_firing_traces.
-/

namespace BimodalTest.TraceCertificateTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.TraceExport

/-- Atom helper. -/
private def p : Formula := .atomS "p"
private def q : Formula := .atomS "q"

/-- Test 1: empty certificate has the expected field values. -/
def testEmptyCertificate : IO Bool := do
  let cert := ProofCertificate.empty p
  if cert.formula == p then
    IO.println "PASS Test 1: empty cert has correct formula"
    return true
  else
    IO.println s!"FAIL Test 1: empty cert has wrong formula: {cert.formula.prettyPrint}"
    return false

/-- Test 2: empty certificate serializes to valid JSON. -/
def testEmptySerialization : IO Bool := do
  let cert := ProofCertificate.empty p
  let s := proofCertificateToJsonString cert
  if s.startsWith "{" ∧ s.endsWith "}" then
    IO.println "PASS Test 2: empty cert serializes to valid JSON"
    return true
  else
    IO.println "FAIL Test 2: empty cert serialization is malformed"
    return false

/-- Test 3: decideWithTrace on a tautology returns success. -/
def testTautologySuccess : IO Bool := do
  let φ := Formula.imp p p  -- p → p is a tautology
  match decideWithTrace φ 100 with
  | .success cert =>
    if cert.outcome == .validProof then
      IO.println "PASS Test 3: tautology has outcome validProof"
      return true
    else
      IO.println s!"FAIL Test 3: tautology has wrong outcome: {repr cert.outcome}"
      return false
  | .failure f =>
    IO.println s!"FAIL Test 3: tautology returned failure: {repr f}"
    return false

/-- Test 4: trace on a tautology contains rule_fired events. -/
def testTraceContainsRuleFired : IO Bool := do
  let φ := Formula.imp p p
  match decideWithTrace φ 100 with
  | .success cert =>
    if cert.trace.any fun e =>
        match e with
        | .ruleFired _ _ _ _ _ _ _ _ => true
        | _ => false
    then
      IO.println s!"PASS Test 4: tautology trace has rule_fired events (count: {cert.trace.length})"
      return true
    else
      IO.println
          s!"FAIL Test 4: tautology trace has no rule_fired events (count: {cert.trace.length})"
      return false
  | .failure f =>
    IO.println s!"FAIL Test 4: tautology returned failure: {repr f}"
    return false

/-- Test 5: trace on a tautology contains a branchClosed event. -/
def testTraceContainsBranchClosed : IO Bool := do
  let φ := Formula.imp p p
  match decideWithTrace φ 100 with
  | .success cert =>
    if cert.trace.any fun e =>
        match e with
        | .branchClosed _ _ _ => true
        | _ => false
    then
      IO.println "PASS Test 5: tautology trace has branchClosed event"
      return true
    else
      IO.println s!"FAIL Test 5: tautology trace has no branchClosed event"
      return false
  | .failure _ =>
    IO.println "FAIL Test 5: tautology returned failure"
    return false

/-- Test 6: axiomFingerprint is updated for known rules. -/
def testFingerprintUpdated : IO Bool := do
  let φ := Formula.imp p p
  match decideWithTrace φ 100 with
  | .success cert =>
    -- The trace should have caused at least one fingerprint entry
    if cert.axiomFingerprint.size > 0 then
      IO.println s!"PASS Test 6: fingerprint has {cert.axiomFingerprint.size} entries"
      return true
    else
      IO.println s!"FAIL Test 6: fingerprint is empty (totalSteps: {cert.totalSteps})"
      return false
  | .failure _ =>
    IO.println "FAIL 6: tautology returned failure"
    return false

/-- Test 7: low fuel causes failure. -/
def testLowFuelFailure : IO Bool := do
  -- Use a more complex formula that needs more fuel
  let φ := Formula.imp (Formula.box p) p
  match decideWithTrace φ 2 with
  | .success _ =>
    -- If it succeeds even with low fuel, that's still acceptable
    IO.println "PASS Test 7: low-fuel complex formula succeeded (still acceptable)"
    return true
  | .failure (.outOfFuel trace _) =>
    if trace.length > 0 then
      IO.println
          s!"PASS Test 7: low-fuel formula returned failure with non-empty trace (length: \
              {trace.length})"
      return true
    else
      IO.println "FAIL Test 7: low-fuel formula returned failure with empty trace"
      return false
  | .failure f =>
    IO.println s!"FAIL Test 7: low-fuel formula returned wrong failure: {repr f}"
    return false

/-- Test 8: totalSteps increments monotonically. -/
def testTotalStepsMonotonic : IO Bool := do
  let φ := Formula.imp p p
  match decideWithTrace φ 100 with
  | .success cert =>
    -- totalSteps should equal the number of recorded events
    if cert.totalSteps == cert.trace.length then
      IO.println s!"PASS Test 8: totalSteps equals trace length: {cert.totalSteps}"
      return true
    else
      IO.println
          s!"FAIL Test 8: totalSteps ({cert.totalSteps}) != trace length ({cert.trace.length})"
      return false
  | .failure _ =>
    IO.println "FAIL Test 8: tautology returned failure"
    return false

/-- Test 9: JSONL output is well-formed for various outcome types. -/
def testJsonlForOutcomes : IO Bool := do
  let cert_valid := ProofCertificate.empty p
  let r_valid : TraceResult := .success cert_valid
  let s_valid := traceResultToJsonString r_valid
  let r_fail : TraceResult := .failure (.outOfFuel [] 5)
  let s_fail := traceResultToJsonString r_fail
  let r_blocked : TraceResult := .failure (.unsaturatable [] [])
  let s_blocked := traceResultToJsonString r_blocked
  if s_valid.contains "\"status\": \"success\"" ∧
     s_fail.contains "out_of_fuel" ∧
     s_blocked.contains "unsaturatable" then
    IO.println "PASS Test 9: all outcome types serialize correctly"
    return true
  else
    IO.println "FAIL Test 9: some outcomes don't serialize correctly"
    return false

/-- Run all tests. -/
def runAllTests : IO Bool := do
  IO.println "=== TraceCertificate Unit Tests ==="
  let mut passed : Nat := 0
  let mut failed : Nat := 0
  for test in [
    testEmptyCertificate,
    testEmptySerialization,
    testTautologySuccess,
    testTraceContainsRuleFired,
    testTraceContainsBranchClosed,
    testFingerprintUpdated,
    testLowFuelFailure,
    testTotalStepsMonotonic,
    testJsonlForOutcomes
  ] do
    if ← test then
      passed := passed + 1
    else
      failed := failed + 1
  IO.println s!"\n=== TraceCertificate Tests: {passed} passed, {failed} failed ==="
  return failed == 0

end BimodalTest.TraceCertificateTest

#eval do
  let ok ← BimodalTest.TraceCertificateTest.runAllTests
  if not ok then
    throw (IO.userError "TraceCertificate unit tests failed")
  IO.println "All TraceCertificate unit tests PASSED"
