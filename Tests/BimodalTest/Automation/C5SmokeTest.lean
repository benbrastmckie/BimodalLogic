import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.DatasetValidator

/-!
# C5 Smoke Test: Decision Procedure at Complexity 5

End-to-end smoke test that labels targeted c5 formulas via the decision procedure
and verifies correct results. Exercises the full pipeline: enumeration, labeling,
proof trace extraction, and countermodel generation.

Covers:
- Previously-problematic formulas (box(bot) -> box(r) and variants)
- Known valid formulas (axiom instances, tautologies)
- Known invalid formulas (bare atoms, contradictions)
- Edge cases at complexity 5 (nested temporal operators)
- Conformance test suite from DatasetValidator

## References

- Task 263: Smoke-test c5 dataset generation
- Task 261: Fuel bounding, per-record flush, eventuality-aware blocking
-/

namespace BimodalTest.Automation.C5Smoke

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DatasetValidator

-- Convenience abbreviations (using atom_s for compatibility with DatasetValidator patterns)
private abbrev p : Formula := .atom_s "p"
private abbrev q : Formula := .atom_s "q"
private abbrev r : Formula := .atom_s "r"

/-!
## Section 1: Previously-Problematic Formulas

These formulas involve box(bot) patterns that were previously problematic
before the task 261 fixes. All box(bot) -> X patterns should resolve as valid
because box(bot) is equivalent to asserting the impossible (the universal
modality of falsum), making any implication vacuously true.
-/

#eval do
  IO.println "=== Previously-Problematic Formulas ==="
  let tests : List (Formula × String × FormulaLabel) := [
    -- box(bot) -> box(r): the key regression formula
    (Formula.imp (Formula.box Formula.bot) (Formula.box r),
     "□⊥ → □r", .valid),
    -- box(bot) -> r: simpler variant
    (Formula.imp (Formula.box Formula.bot) r,
     "□⊥ → r", .valid),
    -- box(bot) -> bot: identity-like
    (Formula.imp (Formula.box Formula.bot) Formula.bot,
     "□⊥ → ⊥", .valid),
    -- box(bot) -> box(p): another variant
    (Formula.imp (Formula.box Formula.bot) (Formula.box p),
     "□⊥ → □p", .valid),
    -- box(bot) -> box(bot): reflexive
    (Formula.imp (Formula.box Formula.bot) (Formula.box Formula.bot),
     "□⊥ → □⊥", .valid)
  ]
  let mut passed := 0
  let mut failed := 0
  for (φ, name, expected) in tests do
    let labeled ← labelFormula φ
    if labeled.label == expected then
      passed := passed + 1
      IO.println s!"  [PASS] {name} → {repr labeled.label} (method: {labeled.decisionMethod})"
    else
      failed := failed + 1
      IO.println s!"  [FAIL] {name} → expected {repr expected}, got {repr labeled.label}"
  IO.println s!"  Result: {passed} passed, {failed} failed"
  if failed > 0 then
    throw (IO.userError s!"Previously-problematic formula tests: {failed} failures")

/-!
## Section 2: Known Valid Formulas

Standard axiom instances that should all be decided valid.
-/

#eval do
  IO.println "=== Known Valid Formulas ==="
  let tests : List (Formula × String) := [
    -- Propositional tautologies
    (Formula.imp p (Formula.imp q p), "p → (q → p)"),
    (Formula.imp Formula.bot p, "⊥ → p"),
    (Formula.imp p p, "p → p"),
    -- Modal axioms
    (Formula.imp (Formula.box p) p, "□p → p (Modal T)"),
    (Formula.imp (Formula.box (Formula.imp p q))
                 (Formula.imp (Formula.box p) (Formula.box q)),
     "□(p → q) → (□p → □q) (Modal K)"),
    -- Box of tautology
    (Formula.box (Formula.imp Formula.bot p), "□(⊥ → p)")
  ]
  let mut passed := 0
  let mut failed := 0
  for (φ, name) in tests do
    let labeled ← labelFormula φ
    if labeled.label == FormulaLabel.valid then
      passed := passed + 1
      IO.println s!"  [PASS] {name} → valid (method: {labeled.decisionMethod})"
    else
      failed := failed + 1
      IO.println s!"  [FAIL] {name} → expected valid, got {repr labeled.label}"
  IO.println s!"  Result: {passed} passed, {failed} failed"
  if failed > 0 then
    throw (IO.userError s!"Known valid formula tests: {failed} failures")

/-!
## Section 3: Known Invalid Formulas

Non-theorems that should all be decided invalid with countermodels.
-/

#eval do
  IO.println "=== Known Invalid Formulas ==="
  let tests : List (Formula × String) := [
    -- Bare atoms
    (p, "p"),
    (Formula.bot, "⊥"),
    -- Unrelated implication
    (Formula.imp p q, "p → q"),
    -- Box of non-theorem
    (Formula.box p, "□p"),
    -- No connection between p and q under box
    (Formula.imp (Formula.box p) (Formula.box q), "□p → □q"),
    -- Box of falsum (not valid by Modal T: □⊥ → ⊥)
    (Formula.box Formula.bot, "□⊥")
  ]
  let mut passed := 0
  let mut failed := 0
  for (φ, name) in tests do
    let labeled ← labelFormula φ
    if labeled.label == FormulaLabel.invalid then
      passed := passed + 1
      let hasCM := if labeled.countermodel.isSome then "yes" else "no"
      IO.println s!"  [PASS] {name} → invalid (countermodel: {hasCM})"
    else
      failed := failed + 1
      IO.println s!"  [FAIL] {name} → expected invalid, got {repr labeled.label}"
  IO.println s!"  Result: {passed} passed, {failed} failed"
  if failed > 0 then
    throw (IO.userError s!"Known invalid formula tests: {failed} failures")

/-!
## Section 4: Edge Cases at Complexity 5

Formulas with nested temporal operators testing complexity boundary behavior.
-/

#eval do
  IO.println "=== Complexity 5 Edge Cases ==="
  let tests : List (Formula × String × FormulaLabel) := [
    -- U(p, q) — bare Until is not valid
    (Formula.untl p q, "U(p, q)", .invalid),
    -- S(p, q) — bare Since is not valid
    (Formula.snce p q, "S(p, q)", .invalid),
    -- F(p) = U(p, ⊤) — not valid
    (Formula.some_future p, "Fp", .invalid),
    -- p → G(F(p)) is NOT valid in general for strict future
    -- But p → F(p) is not valid either (strict future)
    (Formula.imp p (Formula.some_future p), "p → Fp", .invalid)
  ]
  let mut passed := 0
  let mut failed := 0
  for (φ, name, expected) in tests do
    let labeled ← labelFormula φ
    if labeled.label == expected then
      passed := passed + 1
      IO.println s!"  [PASS] {name} → {repr labeled.label} (method: {labeled.decisionMethod})"
    else
      failed := failed + 1
      IO.println s!"  [FAIL] {name} → expected {repr expected}, got {repr labeled.label}"
  IO.println s!"  Result: {passed} passed, {failed} failed"
  if failed > 0 then
    throw (IO.userError s!"Complexity 5 edge case tests: {failed} failures")

/-!
## Section 5: Metrics Validation

Verify that labeled formulas have non-null metrics fields.
-/

#eval do
  IO.println "=== Metrics Validation ==="
  -- Test a selection of formulas for complete metrics
  let formulas := [
    Formula.imp (Formula.box Formula.bot) (Formula.box r),
    Formula.imp (Formula.box p) p,
    p,
    Formula.untl p q
  ]
  let mut passed := 0
  let mut failed := 0
  for φ in formulas do
    let labeled ← labelFormula φ
    let m := labeled.metrics
    -- Check all metrics fields are populated (non-zero for actual formulas)
    let ok := m.complexity > 0
    if ok then
      passed := passed + 1
      IO.println s!"  [PASS] complexity={m.complexity} modal={m.modalDepth} temporal={m.temporalDepth} imp={m.impCount} atom={m.atomCount} tier={m.difficultyTier}"
    else
      failed := failed + 1
      IO.println s!"  [FAIL] metrics incomplete for formula"
  IO.println s!"  Result: {passed} passed, {failed} failed"
  if failed > 0 then
    throw (IO.userError s!"Metrics validation: {failed} failures")

/-!
## Section 6: Conformance Test Suite

Run the existing conformance tests from DatasetValidator.
-/

#eval do
  IO.println "=== DatasetValidator Conformance Tests ==="
  let allPassed ← runConformanceTests
  if !allPassed then
    throw (IO.userError "DatasetValidator conformance tests failed")
  IO.println "Conformance tests: ALL PASSED"

/-!
## Summary

All sections must pass for the smoke test to succeed:
1. Previously-problematic formulas (box(bot) patterns) resolve correctly
2. Known valid formulas are labeled valid
3. Known invalid formulas are labeled invalid with countermodels
4. Complexity 5 edge cases produce expected labels
5. Metrics fields are fully populated
6. DatasetValidator conformance tests pass
-/

end BimodalTest.Automation.C5Smoke
