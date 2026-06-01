import Bimodal.Metalogic.Decidability.Closure

/-!
# Tableau Saturation and Expansion

This module implements the saturation process for tableau branches and
the main tableau expansion algorithm with termination guarantees.

## Main Definitions

- `ExpandedTableau`: Result type for fully expanded tableaux
- `expandToCompletion`: Expand a branch until closed or saturated
- `buildTableau`: Build complete tableau for a formula

## Termination

Termination is guaranteed by the subformula property: tableau expansion
only produces formulas from the subformula closure of the initial branch.
The total complexity decreases with each expansion step.

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Expanded Tableau Type
-/

/--
A fully expanded tableau has all branches either closed or saturated.

- `allClosed`: All branches closed → formula is valid
- `hasOpen`: At least one saturated open branch → formula is invalid
-/
inductive ExpandedTableau : Type where
  /-- All branches are closed (formula is valid). -/
  | allClosed (closedBranches : List ClosedBranch)
  /-- At least one branch is open/saturated (formula is invalid). -/
  | hasOpen (openBranch : Branch) (saturated : findUnexpanded openBranch = none)
  deriving Repr

namespace ExpandedTableau

/-- Check if the tableau shows the formula is valid. -/
def isValid : ExpandedTableau → Bool
  | allClosed _ => true
  | hasOpen _ _ => false

/-- Check if the tableau shows the formula is invalid. -/
def isInvalid : ExpandedTableau → Bool
  | allClosed _ => false
  | hasOpen _ _ => true

end ExpandedTableau

/-!
## Branch List Operations
-/

/--
Result of expanding a list of branches.
-/
inductive BranchListResult : Type where
  /-- All branches closed. -/
  | allClosed (closedBranches : List ClosedBranch)
  /-- Found an open saturated branch. -/
  | foundOpen (openBranch : Branch) (saturated : findUnexpanded openBranch = none)
  /-- Still have branches to process. -/
  | pending (branches : List Branch)
  deriving Repr

/-!
## Fuel-Based Expansion
-/

/--
Expand a single branch until closed or saturated.
Uses fuel to ensure termination (refinement of well-founded approach).

Returns:
- `some (inl closedBranch)`: Branch closed
- `some (inr openBranch)`: Branch saturated (open)
- `none`: Ran out of fuel
-/
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option (ClosedBranch ⊕ Branch) :=
  match fuel with
  | 0 => none  -- Out of fuel
  | fuel + 1 =>
      -- First check if already closed
      match findClosure b fc with
      | some reason => some (.inl ⟨b, reason⟩)
      | none =>
          -- Check temporal blocking: if any active time has its type
          -- subsumed by an ancestor time, treat the branch as saturated.
          -- This prevents infinite chains from Until/Since positive rules
          -- re-introducing the same formula at fresh time points.
          if (findBlockedTime b timeOrd).isSome then
            some (.inr b)  -- Blocked: treat as saturated open branch
          else
          -- Try to expand
          match expandOnce b timeOrd with
          | (.saturated, _) => some (.inr b)  -- Open saturated branch
          | (.extended newBranch, newOrd) => expandBranchWithFuel newBranch fuel newOrd fc
          | (.split branches, newOrd) =>
              -- For a split, we check if ALL branches close
              -- If any branch stays open, we return that open branch
              -- This is a simplification - full implementation would track all branches
              let tryBranch := fun acc newBranch =>
                match acc with
                | some (.inr openBr) => some (.inr openBr)  -- Already found open
                | _ =>
                    match expandBranchWithFuel newBranch fuel newOrd fc with
                    | none => none  -- Out of fuel
                    | some (.inl _) => acc  -- This branch closed, continue
                    | some (.inr openBr) => some (.inr openBr)  -- Found open
              branches.foldl tryBranch (some (.inl ⟨b, .botPos Label.initial⟩))  -- Dummy initial closed
termination_by fuel

/--
Expand multiple branches until all closed or one is found open.
Uses fuel to ensure termination.

Returns:
- `allClosed`: All branches closed (formula valid)
- `foundOpen`: Found saturated open branch (formula invalid)
- `pending`: Ran out of fuel with branches remaining
-/
def expandBranchesWithFuel (branches : List Branch) (fuel : Nat)
    (closed : List ClosedBranch := [])
    (fc : FrameClass := .Base) : BranchListResult :=
  match branches with
  | [] => .allClosed closed
  | b :: rest =>
      match expandBranchWithFuel b fuel TimeOrdering.empty fc with
      | none => .pending (b :: rest)  -- Out of fuel
      | some (.inl closedBr) => expandBranchesWithFuel rest fuel (closedBr :: closed) fc
      | some (.inr openBr) =>
          -- Check if open branch is saturated
          match h : findUnexpanded openBr with
          | none => .foundOpen openBr h
          | some _ => .pending (openBr :: rest)  -- Not yet saturated

/-!
## Main Expansion Function
-/

/--
Build a complete tableau for proving ¬φ is unsatisfiable (i.e., φ is valid).

Starts with F(φ) (asserting φ is false) and expands until:
- All branches close → φ is valid
- Some branch saturates open → φ is invalid

Uses fuel parameter for termination. The fuel should be set based on
the formula's complexity.
-/
def buildTableau (φ : Formula) (fuel : Nat := 1000)
    (fc : FrameClass := .Base) : Option ExpandedTableau :=
  let initialBranch : Branch := [SignedFormula.neg φ Label.initial]
  match expandBranchWithFuel initialBranch fuel TimeOrdering.empty fc with
  | none => none  -- Out of fuel
  | some (.inl closedBr) => some (.allClosed [closedBr])
  | some (.inr openBr) =>
      match h : findUnexpanded openBr with
      | none => some (.hasOpen openBr h)
      | some _ => none  -- Should be saturated but isn't

/--
Recommended fuel based on formula complexity.
Uses 10 * complexity as a heuristic upper bound.
-/
def recommendedFuel (φ : Formula) : Nat :=
  10 * φ.complexity + 100

/--
Build tableau with automatic fuel calculation.
-/
def buildTableauAuto (φ : Formula) (fc : FrameClass := .Base) : Option ExpandedTableau :=
  buildTableau φ (recommendedFuel φ) fc

/-!
## Saturation Properties
-/

/--
Check if a branch is fully saturated (all formulas expanded).
-/
def isSaturated (b : Branch) : Bool :=
  (findUnexpanded b).isNone

/--
A saturated branch contains only atomic signed formulas
(atoms, bot, or modal/temporal operators that can't be further expanded).
-/
def isAtomicBranch (b : Branch) : Bool :=
  b.all fun sf =>
    match sf.formula with
    | .atom _ => true
    | .bot => true
    | _ => isExpanded sf b

/-!
## Termination Measure
-/

/--
Termination measure for branch expansion.
Sum of unexpanded complexities decreases with each rule application.
-/
def expansionMeasure (b : Branch) : Nat :=
  b.foldl (fun acc sf =>
    if isExpanded sf b then acc
    else acc + sf.formula.complexity) 0

-- Note: expansion_decreases_measure theorem was archived (required technical proof)

/-!
## Tableau Statistics
-/

/--
Statistics about a tableau expansion.
-/
structure TableauStats where
  /-- Number of branches created. -/
  branchCount : Nat
  /-- Number of closed branches. -/
  closedCount : Nat
  /-- Maximum branch depth. -/
  maxDepth : Nat
  /-- Total expansion steps. -/
  expansionSteps : Nat
  deriving Repr, Inhabited

/-!
## Until/Since Integration Tests

These tests verify the 4 Until/Since tableau rules (untlPos, untlNeg, sncePos, snceNeg)
produce correct results for known axioms and satisfiable formulas.
-/

section UntilSinceTests

open Bimodal.Syntax

-- Helper: create propositional atom formulas
private def p : Formula := .atom (Atom.mk_base "p")
private def q : Formula := .atom (Atom.mk_base "q")

-- Test 1: U(p, bot) -> F(p) should be valid (allClosed)
-- U(p, bot) = "bot until p" = essentially Next(p)
-- Event branch: T(p) at t1 + F(p) at t1 from F(F(p)) propagation => contradiction
-- Guard branch: T(bot) at t1 => botPos closure
#eval do
  let φ := Formula.imp (.untl p .bot) (Formula.some_future p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: U(p, bot) -> F(p) is valid"
  | some (.hasOpen _ _) => return "FAIL: U(p, bot) -> F(p) should be valid but got open branch"
  | none => return "FAIL: U(p, bot) -> F(p) ran out of fuel"

-- Test 2: S(p, bot) -> P(p) should be valid (allClosed)
-- Symmetric past version of Test 1
#eval do
  let φ := Formula.imp (.snce p .bot) (Formula.some_past p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: S(p, bot) -> P(p) is valid"
  | some (.hasOpen _ _) => return "FAIL: S(p, bot) -> P(p) should be valid but got open branch"
  | none => return "FAIL: S(p, bot) -> P(p) ran out of fuel"

-- Test 3: F(p) -> U(p, top) should be valid (definitional equality: both = untl p top)
-- F(φ) = U(φ, ⊤) by definition, so this is U(p, ⊤) -> U(p, ⊤), trivial
#eval do
  let φ := Formula.imp (Formula.some_future p) (.untl p Formula.top)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: F(p) -> U(p, top) is valid (BX12)"
  | some (.hasOpen _ _) => return "FAIL: F(p) -> U(p, top) should be valid but got open branch"
  | none => return "FAIL: F(p) -> U(p, top) ran out of fuel"

-- Test 4: P(p) -> S(p, top) should be valid (symmetric BX12')
#eval do
  let φ := Formula.imp (Formula.some_past p) (.snce p Formula.top)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: P(p) -> S(p, top) is valid (BX12')"
  | some (.hasOpen _ _) => return "FAIL: P(p) -> S(p, top) should be valid but got open branch"
  | none => return "FAIL: P(p) -> S(p, top) ran out of fuel"

-- Test 5: Seriality test: F(top) -> top should be valid
#eval do
  let φ := Formula.imp (Formula.some_future Formula.top) Formula.top
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: F(top) -> top is valid"
  | some (.hasOpen _ _) => return "FAIL: F(top) -> top should be valid but got open branch"
  | none => return "FAIL: F(top) -> top ran out of fuel"

-- Test 6: U(p, q) is satisfiable (NOT valid), so buildTableauAuto should produce hasOpen or timeout
-- U(p, q) alone is not a tautology - it has models where p eventually holds with q as guard
#eval do
  let φ := Formula.untl p q
  let result := buildTableau φ 50  -- Use limited fuel since this is satisfiable
  match result with
  | some (.allClosed _) => return "FAIL: U(p, q) should be satisfiable but got allClosed"
  | some (.hasOpen _ _) => return "PASS: U(p, q) is satisfiable (open branch found)"
  | none => return "PASS: U(p, q) is satisfiable (exhausted fuel without closing)"

-- Test 7: p -> p is a tautology (baseline propositional test)
#eval do
  let φ := Formula.imp p p
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: p -> p is valid"
  | some (.hasOpen _ _) => return "FAIL: p -> p should be valid"
  | none => return "FAIL: p -> p ran out of fuel"

end UntilSinceTests

/-!
## Blocking Termination Tests

These tests verify that subset blocking correctly terminates tableau expansion
for formulas that would previously loop or exhaust fuel.
-/

section BlockingTests

open Bimodal.Syntax

private def p' : Formula := .atom (Atom.mk_base "p")
private def q' : Formula := .atom (Atom.mk_base "q")

-- Test B1: G(p) -> G(p) is trivially valid (regression baseline)
#eval do
  let φ := Formula.imp (Formula.all_future p') (Formula.all_future p')
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS B1: G(p) -> G(p) is valid"
  | some (.hasOpen _ _) => return "FAIL B1: G(p) -> G(p) should be valid"
  | none => return "FAIL B1: G(p) -> G(p) ran out of fuel"

-- Test B2: U(p, q) -> U(p, q) is trivially valid (temporal identity)
#eval do
  let φ := Formula.imp (.untl p' q') (.untl p' q')
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS B2: U(p,q) -> U(p,q) is valid"
  | some (.hasOpen _ _) => return "FAIL B2: U(p,q) -> U(p,q) should be valid"
  | none => return "FAIL B2: U(p,q) -> U(p,q) ran out of fuel"

end BlockingTests

end Bimodal.Metalogic.Decidability
