import Bimodal.Automation.Normalization
import Bimodal.Metalogic.Decidability.DecisionProcedure

/-!
# Normalization Tests (Task 287)

Unit tests verifying that `normalizeFormula` is the identity function on
all formula types (primitive and derived operators), and that `decide`
works correctly with normalization wired in.

## Test Coverage

- Primitive formulas: atom, bot, imp, box, untl, snce
- Derived propositional: neg, top, and, or
- Derived modal: diamond
- Derived temporal: next, prev, some_future, some_past, all_future, all_past
- Derived composite: weak_future, weak_past, always, sometimes
- Derived binary temporal: strong_release, strong_trigger
- Nested combinations: always (diamond p), box (neg (and p q))
- Round-trip: normalizeFormula phi == phi for all test cases
- Decision procedure: decide still produces correct results after normalization
-/

namespace BimodalTest.Automation.NormalizationTest

open Bimodal.Syntax Bimodal.Automation.Normalization
open Bimodal.Metalogic.Decidability

-- Convenience abbreviations
private def p : Formula := .atom (Atom.mk_base "p")
private def q : Formula := .atom (Atom.mk_base "q")
private def r : Formula := .atom (Atom.mk_base "r")

/-!
## Section 1: Primitive Formula Tests

normalizeFormula should be the identity on all primitive constructors.
All proofs use `exact normalizeFormula_id _` which applies the `@[simp]`
theorem directly.
-/

-- Test 1: atom is preserved
example : normalizeFormula (.atom (Atom.mk_base "p")) = .atom (Atom.mk_base "p") := rfl

-- Test 2: bot is preserved
example : normalizeFormula .bot = .bot := rfl

-- Test 3: imp is preserved
example : normalizeFormula (.imp p q) = .imp p q := normalizeFormula_id _

-- Test 4: box is preserved
example : normalizeFormula (.box p) = .box p := normalizeFormula_id _

-- Test 5: untl is preserved
example : normalizeFormula (.untl p q) = .untl p q := normalizeFormula_id _

-- Test 6: snce is preserved
example : normalizeFormula (.snce p q) = .snce p q := normalizeFormula_id _

/-!
## Section 2: Derived Operator Tests

normalizeFormula should be the identity on derived operators (which are
`def` abbreviations that unfold to primitives).
-/

-- Test 7: neg is preserved (neg φ = imp φ bot)
example : normalizeFormula (Formula.neg p) = Formula.neg p := normalizeFormula_id _

-- Test 8: top is preserved (top = imp bot bot)
example : normalizeFormula Formula.top = Formula.top := normalizeFormula_id _

-- Test 9: and is preserved
example : normalizeFormula (Formula.and p q) = Formula.and p q := normalizeFormula_id _

-- Test 10: or is preserved
example : normalizeFormula (Formula.or p q) = Formula.or p q := normalizeFormula_id _

-- Test 11: diamond is preserved
example : normalizeFormula (Formula.diamond p) = Formula.diamond p := normalizeFormula_id _

-- Test 12: next is preserved
example : normalizeFormula (Formula.next p) = Formula.next p := normalizeFormula_id _

-- Test 13: prev is preserved
example : normalizeFormula (Formula.prev p) = Formula.prev p := normalizeFormula_id _

-- Test 14: some_future is preserved
example : normalizeFormula (Formula.some_future p) = Formula.some_future p :=
  normalizeFormula_id _

-- Test 15: some_past is preserved
example : normalizeFormula (Formula.some_past p) = Formula.some_past p :=
  normalizeFormula_id _

-- Test 16: all_future is preserved
example : normalizeFormula (Formula.all_future p) = Formula.all_future p :=
  normalizeFormula_id _

-- Test 17: all_past is preserved
example : normalizeFormula (Formula.all_past p) = Formula.all_past p :=
  normalizeFormula_id _

/-!
## Section 3: Composite Operator Tests
-/

-- Test 18: weak_future is preserved
example : normalizeFormula (Formula.weak_future p) = Formula.weak_future p :=
  normalizeFormula_id _

-- Test 19: weak_past is preserved
example : normalizeFormula (Formula.weak_past p) = Formula.weak_past p :=
  normalizeFormula_id _

-- Test 20: always is preserved
example : normalizeFormula (Formula.always p) = Formula.always p :=
  normalizeFormula_id _

-- Test 21: sometimes is preserved
example : normalizeFormula (Formula.sometimes p) = Formula.sometimes p :=
  normalizeFormula_id _

-- Test 22: strong_release is preserved
example : normalizeFormula (Formula.strong_release p q) = Formula.strong_release p q :=
  normalizeFormula_id _

-- Test 23: strong_trigger is preserved
example : normalizeFormula (Formula.strong_trigger p q) = Formula.strong_trigger p q :=
  normalizeFormula_id _

/-!
## Section 4: Nested Combination Tests
-/

-- Test 24: always (diamond p) is preserved
example : normalizeFormula (Formula.always (Formula.diamond p)) =
    Formula.always (Formula.diamond p) := normalizeFormula_id _

-- Test 25: box (neg (and p q)) is preserved
example : normalizeFormula (Formula.box (Formula.neg (Formula.and p q))) =
    Formula.box (Formula.neg (Formula.and p q)) := normalizeFormula_id _

-- Test 26: imp (diamond p) (all_future q) is preserved
example : normalizeFormula (Formula.imp (Formula.diamond p) (Formula.all_future q)) =
    Formula.imp (Formula.diamond p) (Formula.all_future q) := normalizeFormula_id _

-- Test 27: untl (neg p) (or q r) is preserved
example : normalizeFormula (Formula.untl (Formula.neg p) (Formula.or q r)) =
    Formula.untl (Formula.neg p) (Formula.or q r) := normalizeFormula_id _

/-!
## Section 5: Round-Trip Eval Tests

Verify normalizeFormula φ == φ for a comprehensive set of formulas
using computable equality.
-/

#eval do
  let formulas : List Formula := [
    -- Primitives
    p, q, .bot, .imp p q, .box p, .untl p q, .snce p q,
    -- Derived propositional
    Formula.neg p, Formula.top, Formula.and p q, Formula.or p q,
    -- Derived modal
    Formula.diamond p,
    -- Derived temporal
    Formula.next p, Formula.prev p,
    Formula.some_future p, Formula.some_past p,
    Formula.all_future p, Formula.all_past p,
    -- Composite
    Formula.weak_future p, Formula.weak_past p,
    Formula.always p, Formula.sometimes p,
    Formula.strong_release p q, Formula.strong_trigger p q,
    -- Nested
    Formula.always (Formula.diamond p),
    Formula.box (Formula.neg (Formula.and p q)),
    Formula.imp (Formula.diamond p) (Formula.all_future q)
  ]
  let results := formulas.map fun f =>
    normalizeFormula f == f
  let allPass := results.all id
  let failCount := results.filter (! ·) |>.length
  return s!"normalizeFormula identity test: {if allPass then "ALL PASS" else s!"FAILURES: {failCount}"} ({formulas.length} formulas tested)"

/-!
## Section 6: Decision Procedure Integration Tests

Verify that `decide` with normalization wired in still produces correct results.
-/

-- Test: p -> p is valid (basic tautology)
#eval do
  let f := Formula.imp p p
  let result := decide f
  return s!"p -> p: {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: bot is invalid
#eval do
  let f := Formula.bot
  let result := decide f
  return s!"bot: {if result.isInvalid then "INVALID" else "UNEXPECTED"}"

-- Test: box(p -> p) is valid
#eval do
  let f := Formula.box (Formula.imp p p)
  let result := decide f
  return s!"box(p -> p): {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: diamond(p) -> diamond(p) is valid
#eval do
  let f := Formula.imp (Formula.diamond p) (Formula.diamond p)
  let result := decide f
  return s!"diamond(p) -> diamond(p): {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: p is invalid (not a tautology)
#eval do
  let f := p
  let result := decide f
  return s!"p: {if result.isInvalid then "INVALID" else "UNEXPECTED"}"

end BimodalTest.Automation.NormalizationTest
