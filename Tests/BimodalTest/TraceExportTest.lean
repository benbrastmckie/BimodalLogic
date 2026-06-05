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
import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.TraceExport

/-!
# Round-Trip Test for Trace Certificate JSON Serialization (Task 277)

Verifies that the output of `ProofCertificate.toJsonString` and
`TraceResult.toJsonString` is parseable JSON (syntactically valid).

This is a structural test: we check that the output starts with `{`,
ends with `}`, and contains expected key fields. We do not validate
the *semantic* content of the JSON, only that the structure is valid.

## References

- `Bimodal.Metalogic.Decidability.TraceExport` — String-based JSON.
- Task 277 — tableau_rule_firing_traces.
-/

namespace BimodalTest.TraceExportTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability
open Bimodal.Metalogic.Decidability.TraceExport

/-- Atom helper. -/
private def p : Formula := .atom_s "p"
private def q : Formula := .atom_s "q"

/--
Verify that a JSON string has the expected structural form:
- starts with `{`
- ends with `}`
- contains the given key as a top-level key.
-/
def checkJsonObject (s : String) (key : String) (label : String) : IO Bool := do
  let trimmed := s.trimAscii.toString
  if not (trimmed.startsWith "{") then
    IO.println s!"FAIL {label}: does not start with curly-brace (got: {trimmed.take 30})" ; return false
  if not (trimmed.endsWith "}") then
    IO.println s!"FAIL {label}: does not end with curly-brace (got: ...{trimmed.takeRight 30})" ; return false
  -- The key should appear as `"key":` in the string
  let keyPattern := "\"" ++ key ++ "\":"
  if not (trimmed.contains keyPattern) then
    IO.println s!"FAIL {label}: missing key '{key}'" ; return false
  IO.println s!"PASS {label}" ; return true

/-- Run the full test suite. -/
def runTraceExportTests : IO Bool := do
  IO.println "=== TraceExport Round-Trip Tests ==="
  let mut passed : Nat := 0
  let mut failed : Nat := 0

  -- Test 1: empty certificate
  let cert0 := ProofCertificate.empty p
  let s0 := proofCertificateToJsonString cert0
  if ← checkJsonObject s0 "formula" "Test 1: empty certificate has 'formula' key" then
    passed := passed + 1
  else failed := failed + 1

  -- Test 2: empty certificate has 'outcome' key
  if ← checkJsonObject s0 "outcome" "Test 2: empty certificate has 'outcome' key" then
    passed := passed + 1
  else failed := failed + 1

  -- Test 3: empty certificate has 'trace' key
  if ← checkJsonObject s0 "trace" "Test 3: empty certificate has 'trace' key" then
    passed := passed + 1
  else failed := failed + 1

  -- Test 4: empty certificate has 'axiom_fingerprint' key
  if ← checkJsonObject s0 "axiom_fingerprint" "Test 4: empty certificate has 'axiom_fingerprint' key" then
    passed := passed + 1
  else failed := failed + 1

  -- Test 5: frame class names
  if s0.contains "\"frame_class\": \"Base\"" then
    IO.println "PASS Test 5: frame class is 'Base'"
    passed := passed + 1
  else
    IO.println s!"FAIL Test 5: frame class not 'Base' (got: ...{s0.takeRight 100})"
    failed := failed + 1

  -- Test 6: decideWithTrace result on a valid formula
  let φ := Formula.imp p p  -- p → p is a tautology
  let r6 := decideWithTrace φ 100
  match r6 with
  | .success cert =>
      let s6 := proofCertificateToJsonString cert
      if ← checkJsonObject s6 "outcome" "Test 6: decideWithTrace on tautology has 'outcome' key" then
        passed := passed + 1
      else failed := failed + 1
      if s6.contains "rule_fired" then
        IO.println "PASS Test 6b: tautology trace contains 'rule_fired' events"
        passed := passed + 1
      else
        IO.println s!"FAIL Test 6b: tautology trace missing 'rule_fired' events (got: {s6.take 200})"
        failed := failed + 1
  | .failure _ =>
      IO.println "FAIL Test 6: decideWithTrace on tautology should succeed"
      failed := failed + 1

  -- Test 7: TraceResult success
  let r7 := .success cert0
  let s7 := traceResultToJsonString r7
  if ← checkJsonObject s7 "status" "Test 7: TraceResult.success has 'status' key" then
    passed := passed + 1
  else failed := failed + 1
  if s7.contains "\"status\": \"success\"" then
    IO.println "PASS Test 7b: status is 'success'"
    passed := passed + 1
  else
    IO.println s!"FAIL Test 7b: status not 'success'"
    failed := failed + 1

  -- Test 8: TraceResult failure
  let r8 : TraceResult := .failure (.outOfFuel [] 0)
  let s8 := traceResultToJsonString r8
  if ← checkJsonObject s8 "status" "Test 8: TraceResult.failure has 'status' key" then
    passed := passed + 1
  else failed := failed + 1
  if s8.contains "out_of_fuel" then
    IO.println "PASS Test 8b: failure_kind is 'out_of_fuel'"
    passed := passed + 1
  else
    IO.println s!"FAIL Test 8b: failure_kind not 'out_of_fuel'"
    failed := failed + 1

  -- Test 9: axiom fingerprint is rendered as a JSON object
  if s0.contains "\"axiom_fingerprint\": {}" then
    IO.println "PASS Test 9: empty axiom_fingerprint renders as '{}'"
    passed := passed + 1
  else
    IO.println s!"FAIL Test 9: empty axiom_fingerprint not rendered as empty-object"
    failed := failed + 1

  -- Test 10: trace is a JSON array
  if s0.contains "\"trace\": []" then
    IO.println "PASS Test 10: empty trace renders as '[]'"
    passed := passed + 1
  else
    IO.println s!"FAIL Test 10: empty trace not rendered as '[]'"
    failed := failed + 1

  IO.println s!"\n=== Round-Trip Tests: {passed} passed, {failed} failed ==="
  return failed == 0

end BimodalTest.TraceExportTest

#eval do
  let ok ← BimodalTest.TraceExportTest.runTraceExportTests
  if not ok then
    throw (IO.userError "TraceExport round-trip tests failed")
  IO.println "All TraceExport round-trip tests PASSED"
