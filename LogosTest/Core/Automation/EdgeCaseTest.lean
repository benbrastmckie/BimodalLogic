import Logos.Core.Automation.ProofSearch
import Logos.Core.Automation.Tactics
import Logos.Core.ProofSystem

/-!
# Edge Case Tests for Proof Search Automation (Task 319 Phase 2)

Systematic edge case testing for the proof search system covering:
- Empty context cases
- Deep nesting of modal/temporal operators
- Large context sizes
- Complex mixed formulas
- Depth and visit limit enforcement
- Special formula patterns

## Test Count Target: 30+ edge case tests
-/

namespace LogosTest.Core.Automation.EdgeCase

open Logos.Core.Syntax Logos.Core.Automation Logos.Core.ProofSystem

-- Convenience abbreviations
abbrev p : Formula := .atom "p"
abbrev q : Formula := .atom "q"
abbrev r : Formula := .atom "r"
abbrev s : Formula := .atom "s"

/-!
## Section 1: Empty Context Tests

Verify axioms are found with empty context ([] ⊢ φ).
-/

-- Modal axioms with empty context
example : ⊢ (Formula.box p).imp p := by modal_search
example : ⊢ (Formula.box q).imp (Formula.box (Formula.box q)) := by modal_search
example : ⊢ p.imp (Formula.box p.diamond) := by modal_search

-- Temporal axioms with empty context
example : ⊢ (Formula.all_future p).imp (Formula.all_future (Formula.all_future p)) := by temporal_search
example : ⊢ p.imp (Formula.all_future (Formula.some_past p)) := by temporal_search

-- Propositional axioms with empty context
example : ⊢ p.imp (q.imp p) := by propositional_search
example : ⊢ (p.imp (q.imp r)).imp ((p.imp q).imp (p.imp r)) := by propositional_search
example : ⊢ Formula.bot.imp p := by propositional_search

#eval do
  IO.println "=== Empty Context Tests ==="
  let tests := [
    ([], (Formula.box p).imp p, "Modal T"),
    ([], (Formula.all_future p).imp (Formula.all_future (Formula.all_future p)), "Temporal 4"),
    ([], p.imp (q.imp p), "Prop S"),
    ([], Formula.bot.imp p, "Ex Falso"),
    ([], (Formula.box p).imp (Formula.all_future (Formula.box p)), "Temp Future")
  ]
  let mut passed := 0
  for (ctx, formula, name) in tests do
    let (found, _, _, _, _) := search ctx formula (.IDDFS 10) 100
    if found then
      passed := passed + 1
      IO.println s!"✓ {name}: found with empty context"
    else
      IO.println s!"✗ {name}: NOT found with empty context"
  IO.println s!"Empty context tests: {passed}/{tests.length} passed"

/-!
## Section 2: Deep Nesting Tests

Test formulas with deeply nested modal/temporal operators.
-/

-- Deep modal nesting: □□p, □□□p, □□□□p
#eval do
  IO.println "=== Deep Modal Nesting Tests ==="
  -- Modal T at various nesting levels
  let tests := [
    ((Formula.box p).imp p, "□p → p"),
    ((Formula.box (Formula.box p)).imp (Formula.box p), "□□p → □p"),
    ((Formula.box (Formula.box (Formula.box p))).imp (Formula.box (Formula.box p)), "□□□p → □□p"),
    ((Formula.box (Formula.box (Formula.box (Formula.box p)))).imp (Formula.box (Formula.box (Formula.box p))), "□□□□p → □□□p")
  ]
  let mut passed := 0
  for (formula, desc) in tests do
    let matched := matches_axiom formula
    let (found, _, _, _, _) := search [] formula (.IDDFS 5) 100
    if matched && found then
      passed := passed + 1
      IO.println s!"✓ {desc}: matched={matched}, found={found}"
    else
      IO.println s!"✗ {desc}: matched={matched}, found={found}"
  IO.println s!"Deep modal nesting: {passed}/{tests.length} passed"

-- Deep temporal nesting: Gp, GGp, GGGp, GGGGp
#eval do
  IO.println "=== Deep Temporal Nesting Tests ==="
  let tests := [
    ((Formula.all_future p).imp (Formula.all_future (Formula.all_future p)), "Gp → GGp"),
    ((Formula.all_future (Formula.all_future p)).imp (Formula.all_future (Formula.all_future (Formula.all_future p))), "GGp → GGGp"),
    ((Formula.all_future (Formula.all_future (Formula.all_future p))).imp (Formula.all_future (Formula.all_future (Formula.all_future (Formula.all_future p)))), "GGGp → GGGGp")
  ]
  let mut passed := 0
  for (formula, desc) in tests do
    let matched := matches_axiom formula
    let (found, _, _, _, _) := search [] formula (.IDDFS 5) 100
    if matched && found then
      passed := passed + 1
      IO.println s!"✓ {desc}: matched={matched}, found={found}"
    else
      IO.println s!"✗ {desc}: matched={matched}, found={found}"
  IO.println s!"Deep temporal nesting: {passed}/{tests.length} passed"

-- Deep modal nesting with tactics
example : ⊢ (Formula.box (Formula.box p)).imp (Formula.box p) := by modal_search
example : ⊢ (Formula.box (Formula.box (Formula.box p))).imp (Formula.box (Formula.box p)) := by modal_search

-- Deep temporal nesting with tactics
example : ⊢ (Formula.all_future (Formula.all_future p)).imp (Formula.all_future (Formula.all_future (Formula.all_future p))) := by temporal_search

/-!
## Section 3: Large Context Tests

Test with contexts containing many formulas.
-/

#eval do
  IO.println "=== Large Context Tests ==="

  -- Context with 5 formulas
  let ctx5 := [p, q, r, s, p.imp q]
  let (found5, _, _, stats5, _) := search ctx5 p (.IDDFS 5) 100
  IO.println s!"Context size 5: found={found5}, visited={stats5.visited}"

  -- Context with 10 formulas
  let ctx10 := [p, q, r, s, p.imp q, q.imp r, r.imp s, Formula.box p, Formula.all_future q, p.imp (q.imp p)]
  let (found10, _, _, stats10, _) := search ctx10 p (.IDDFS 5) 100
  IO.println s!"Context size 10: found={found10}, visited={stats10.visited}"

  -- Context with 15 formulas
  let ctx15 := [p, q, r, s, p.imp q, q.imp r, r.imp s, Formula.box p, Formula.all_future q,
                p.imp (q.imp p), Formula.box q, Formula.box r, Formula.all_future p,
                (Formula.box p).imp p, (Formula.all_future p).imp (Formula.all_future (Formula.all_future p))]
  let (found15, _, _, stats15, _) := search ctx15 p (.IDDFS 5) 100
  IO.println s!"Context size 15: found={found15}, visited={stats15.visited}"

  if found5 && found10 && found15 then
    IO.println "✓ All large context tests passed"
  else
    IO.println "✗ Some large context tests failed"

-- Tactic tests with large context
example : [p, q, r, s, p.imp q] ⊢ p := by modal_search
example : [p, q, r, s, p.imp q, q.imp r] ⊢ p := by modal_search
example : [p, q, r, s, p.imp q, q.imp r, r.imp s, Formula.box p, Formula.all_future q, p.imp (q.imp p)] ⊢ p := by modal_search

/-!
## Section 4: Complex Formula Tests

Test with mixed modal/temporal/propositional operators.
-/

#eval do
  IO.println "=== Complex Formula Tests ==="

  -- Mixed modal and temporal
  let mixedFormulas := [
    ((Formula.box p).imp (Formula.all_future (Formula.box p)), "□p → G□p (temp_future)"),
    ((Formula.box p).imp (Formula.box (Formula.all_future p)), "□p → □Gp (modal_future)"),
    ((Formula.box (p.imp q)).imp ((Formula.box p).imp (Formula.box q)), "□(p→q) → (□p → □q) (modal_k)")
  ]

  let mut passed := 0
  for (formula, desc) in mixedFormulas do
    let matched := matches_axiom formula
    let (found, _, _, _, _) := search [] formula (.IDDFS 5) 100
    if matched && found then
      passed := passed + 1
      IO.println s!"✓ {desc}: matched={matched}, found={found}"
    else
      IO.println s!"✗ {desc}: matched={matched}, found={found}"
  IO.println s!"Complex formula tests: {passed}/{mixedFormulas.length} passed"

-- Bimodal tactic tests
example : ⊢ (Formula.box p).imp (Formula.all_future (Formula.box p)) := by modal_search
example : ⊢ (Formula.box p).imp (Formula.box (Formula.all_future p)) := by modal_search

/-!
## Section 5: Depth Limit Tests

Verify search respects depth limits.
-/

#eval do
  IO.println "=== Depth Limit Tests ==="

  -- Axioms should be found at depth 1
  let modalT := (Formula.box p).imp p
  let (found1, _, _, _, _) := search [] modalT (.BoundedDFS 1) 100
  let (found0, _, _, _, _) := search [] modalT (.BoundedDFS 0) 100

  IO.println s!"Modal T at depth 0: found={found0}"
  IO.println s!"Modal T at depth 1: found={found1}"

  -- Non-axiom should not be found at any reasonable depth
  let nonAxiom := Formula.atom "nonexistent"
  let (foundNA1, _, _, _, _) := search [] nonAxiom (.BoundedDFS 1) 100
  let (foundNA5, _, _, _, _) := search [] nonAxiom (.BoundedDFS 5) 100

  IO.println s!"Non-axiom at depth 1: found={foundNA1}"
  IO.println s!"Non-axiom at depth 5: found={foundNA5}"

  if found1 && !foundNA1 && !foundNA5 then
    IO.println "✓ Depth limit tests passed"
  else
    IO.println "✗ Depth limit tests failed"

/-!
## Section 6: Visit Limit Tests

Verify search respects visit limits.
-/

#eval do
  IO.println "=== Visit Limit Tests ==="

  -- Search for non-axiom with various visit limits
  let nonAxiom := Formula.atom "x"

  let limits := [1, 5, 10, 50, 100]
  for limit in limits do
    let (found, _, _, stats, visits) := iddfs_search [] nonAxiom 10 limit
    IO.println s!"Visit limit {limit}: found={found}, visits={visits}, visited={stats.visited}"
    if visits > limit then
      IO.println s!"  ✗ EXCEEDED LIMIT!"
    else
      IO.println s!"  ✓ Within limit"

/-!
## Section 7: Special Formula Patterns

Test edge cases with special formula structures.
-/

-- Self-referential patterns (valid axiom instances)
example : ⊢ p.imp (p.imp p) := by propositional_search  -- prop_s instance
example : ⊢ (p.imp p).imp (p.imp (p.imp p)) := by propositional_search

-- Double negation patterns (via ex falso and Peirce)
example : ⊢ Formula.bot.imp (Formula.bot.imp p) := by propositional_search

-- Nested implications (using prop_s pattern)
-- Note: p → (q → (r → p)) is NOT a direct prop_s instance since prop_s is φ → (ψ → φ)
-- We test valid nested implications that ARE axiom instances
example : ⊢ (p.imp q).imp (r.imp (p.imp q)) := by propositional_search

#eval do
  IO.println "=== Special Pattern Tests ==="

  -- Formulas with self-referential structure
  let selfRef := [
    (p.imp (p.imp p), "p → (p → p)"),
    ((p.imp p).imp (p.imp (p.imp p)), "(p→p) → (p → (p→p))")
  ]

  let mut passed := 0
  for (formula, desc) in selfRef do
    let matched := matches_axiom formula
    let (found, _, _, _, _) := search [] formula (.IDDFS 5) 100
    if matched && found then
      passed := passed + 1
      IO.println s!"✓ {desc}: matched={matched}, found={found}"
    else
      IO.println s!"✗ {desc}: matched={matched}, found={found}"
  IO.println s!"Special pattern tests: {passed}/{selfRef.length} passed"

/-!
## Section 8: Atom Name Variations

Test with various atom names including longer names.
-/

#eval do
  IO.println "=== Atom Name Variation Tests ==="

  let atoms := [
    Formula.atom "x",
    Formula.atom "variable",
    Formula.atom "longAtomName123",
    Formula.atom "special_chars_allowed"
  ]

  let mut passed := 0
  for atom in atoms do
    -- Test prop_s with this atom
    let formula := atom.imp (q.imp atom)
    let matched := matches_axiom formula
    let (found, _, _, _, _) := search [] formula (.IDDFS 5) 100
    if matched && found then
      passed := passed + 1
      IO.println s!"✓ prop_s with {repr atom}: matched={matched}, found={found}"
    else
      IO.println s!"✗ prop_s with {repr atom}: matched={matched}, found={found}"
  IO.println s!"Atom name tests: {passed}/{atoms.length} passed"

/-!
## Edge Case Summary
-/

#eval do
  IO.println "\n=== Edge Case Test Summary ==="
  IO.println "Section 1: Empty Context Tests - 8 tests"
  IO.println "Section 2: Deep Nesting Tests - 7 tests"
  IO.println "Section 3: Large Context Tests - 6 tests"
  IO.println "Section 4: Complex Formula Tests - 5 tests"
  IO.println "Section 5: Depth Limit Tests - 4 tests"
  IO.println "Section 6: Visit Limit Tests - 5 tests"
  IO.println "Section 7: Special Pattern Tests - 5 tests"
  IO.println "Section 8: Atom Name Tests - 4 tests"
  IO.println "---"
  IO.println "Total: 44 edge case tests"

end LogosTest.Core.Automation.EdgeCase
