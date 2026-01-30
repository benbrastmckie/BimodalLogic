import Bimodal.Boneyard.Metalogic.Decidability.Tableau
import Bimodal.Automation.ProofSearch

/-!
# Branch Closure Detection for Tableau Decision Procedure

This module implements closure detection for tableau branches. A branch is
closed if it contains a logical contradiction, which can arise from:

1. **Contradiction**: Both T(φ) and F(φ) for some formula φ
2. **Bot positive**: T(⊥) (bottom asserted true)
3. **Axiom negation**: F(axiom instance) where the axiom is valid

## Main Definitions

- `ClosureReason`: Witness type explaining why a branch closed
- `findClosure`: Detect if a branch is closed and produce witness
- `isClosed`: Boolean check for branch closure

## Implementation Notes

The closure detection integrates with the `matchAxiom` function from
ProofSearch.lean to identify negated axiom instances. When F(φ) is in
the branch and φ matches an axiom pattern, the branch closes because
axioms are valid in all models.

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace Bimodal.Metalogic.UnderDevelopment.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation

/-!
## Closure Reason Type
-/

/--
Witness for why a branch is closed.

Each constructor provides evidence of the contradiction:
- `contradiction`: Both T(φ) and F(φ) are present
- `botPos`: T(⊥) is present (asserting falsum is true)
- `axiomNeg`: F(axiom) is present (negating a valid axiom)
-/
inductive ClosureReason : Type where
  /-- Branch contains both T(φ) and F(φ) for some formula φ. -/
  | contradiction (φ : Formula)
  /-- Branch contains T(⊥) (bottom asserted true). -/
  | botPos
  /-- Branch contains F(φ) where φ is an axiom instance. -/
  | axiomNeg (φ : Formula) (witness : Axiom φ)
  deriving Repr

namespace ClosureReason

/-- Get a description of the closure reason. -/
def describe : ClosureReason → String
  | contradiction φ => s!"Contradiction on formula: {repr φ}"
  | botPos => "Bottom asserted true (T(⊥))"
  | axiomNeg φ _ => s!"Negated axiom: {repr φ}"

end ClosureReason

/-!
## Closure Detection
-/

/--
Check if a branch contains T(⊥).
-/
def checkBotPos (b : Branch) : Option ClosureReason :=
  if b.hasBotPos then some .botPos else none

/--
Check if a branch contains a direct contradiction (both T(φ) and F(φ)).
Returns the formula that causes the contradiction if found.
-/
def checkContradiction (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then
      some (.contradiction sf.formula)
    else
      none

/--
Check if a branch contains F(axiom) for some axiom instance.
Uses matchAxiom from ProofSearch to identify axiom patterns.
-/
def checkAxiomNeg (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isNeg then
      match matchAxiom sf.formula with
      | some ⟨φ, witness⟩ =>
          if _h : sf.formula = φ then
            some (.axiomNeg φ witness)
          else
            none
      | none => none
    else
      none

/--
Find a closure reason for a branch if one exists.
Checks in order: T(⊥), contradiction, negated axiom.
-/
def findClosure (b : Branch) : Option ClosureReason :=
  checkBotPos b <|> checkContradiction b <|> checkAxiomNeg b

/--
Check if a branch is closed (has any closure reason).
-/
def isClosed (b : Branch) : Bool :=
  (findClosure b).isSome

/--
Check if a branch is open (not closed).
-/
def isOpen (b : Branch) : Bool :=
  ¬isClosed b

/-!
## Closure Witness Types
-/

/--
A closed branch is a branch together with a witness for its closure.
-/
structure ClosedBranch where
  /-- The branch contents. -/
  branch : Branch
  /-- Evidence for why the branch is closed. -/
  reason : ClosureReason
  deriving Repr

/--
An open branch is a branch that has no closure reason.
-/
structure OpenBranch where
  /-- The branch contents. -/
  branch : Branch
  /-- Evidence that the branch is open (no closure reason found). -/
  notClosed : findClosure branch = none

/--
Classification of a branch as either closed or open.
-/
inductive BranchStatus where
  /-- Branch is closed with a reason. -/
  | closed (reason : ClosureReason)
  /-- Branch is open (not closed). -/
  | open
  deriving Repr

/--
Classify a branch as closed or open.
-/
def classifyBranch (b : Branch) : BranchStatus :=
  match findClosure b with
  | some reason => .closed reason
  | none => .open

/-!
## Closure Properties
-/

/--
A closed branch remains closed when extended.
Adding more formulas cannot "undo" a contradiction.
-/
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed] at *
  cases hb : findClosure b with
  | none => simp [hb] at h
  | some reason =>
    simp only [findClosure, checkBotPos, checkContradiction, checkAxiomNeg] at *
    -- The closure reason from b will still be found in sf :: b
    -- because b is a suffix of sf :: b
    sorry  -- Technical: would need to show findSome? finds the same element

/--
If a branch has T(φ) and we add F(φ), it becomes closed.
-/
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure, checkBotPos, checkContradiction]
  -- The contradiction check will find the pair
  sorry  -- Technical: would need to unfold definitions

/-!
## Closure Detection Statistics
-/

/--
Count potential contradictions in a branch (for heuristic guidance).
Counts formulas that have their negation present.
-/
def countPotentialContradictions (b : Branch) : Nat :=
  b.filter (fun sf => sf.isPos ∧ b.hasNeg sf.formula) |>.length

/--
Count negated axiom instances in a branch.
-/
def countNegatedAxioms (b : Branch) : Nat :=
  b.filter (fun sf => sf.isNeg ∧ (matchAxiom sf.formula).isSome) |>.length

end Bimodal.Boneyard.Metalogic.Decidability
