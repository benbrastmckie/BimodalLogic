import Bimodal.Syntax.Formula
import Bimodal.ProofSystem

/-!
# Signed Formula and Branch Types for Tableau Decidability

This module defines the core types for tableau-based decision procedures:
- `Sign`: Positive (asserted true) or negative (asserted false)
- `SignedFormula`: A formula with a sign
- `Branch`: A list of signed formulas representing a tableau branch

## Main Definitions

- `Sign`: Inductive type with `pos` and `neg` constructors
- `SignedFormula`: Structure combining sign and formula
- `Branch`: Type alias for `List SignedFormula`
- `Formula.subformulas`: Collect all subformulas of a formula
- `subformulaClosure`: Compute the subformula closure

## Implementation Notes

The tableau method works by maintaining branches of signed formulas.
A positive sign means the formula is asserted true, negative means false.
The tableau systematically expands formulas until branches close (contradiction)
or saturate (open branch = countermodel).

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)
-/

namespace Bimodal.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Sign Type
-/

/--
Sign for signed formulas in tableau calculus.

- `pos`: Formula is asserted to be true
- `neg`: Formula is asserted to be false
-/
inductive Sign : Type where
  | pos : Sign
  | neg : Sign
  deriving Repr, DecidableEq, BEq, Hashable, Inhabited

namespace Sign

/-- Flip the sign. -/
def flip : Sign → Sign
  | pos => neg
  | neg => pos

@[simp]
theorem flip_flip (s : Sign) : s.flip.flip = s := by
  cases s <;> rfl

@[simp]
theorem flip_pos : Sign.pos.flip = Sign.neg := rfl

@[simp]
theorem flip_neg : Sign.neg.flip = Sign.pos := rfl

end Sign

/-!
## Signed Formula Type
-/

/--
A signed formula is a formula with a sign indicating truth assertion.

- `sign = pos`: The formula is asserted to be true
- `sign = neg`: The formula is asserted to be false

In tableau calculus, we start with the negation of the goal (sign = neg)
and expand until all branches close or we find an open saturated branch.
-/
structure SignedFormula : Type where
  /-- The sign indicating truth or falsity assertion. -/
  sign : Sign
  /-- The formula being signed. -/
  formula : Formula
  deriving Repr, DecidableEq, BEq, Hashable

namespace SignedFormula

/-- Create a positive signed formula (asserted true). -/
def pos (φ : Formula) : SignedFormula := ⟨.pos, φ⟩

/-- Create a negative signed formula (asserted false). -/
def neg (φ : Formula) : SignedFormula := ⟨.neg, φ⟩

/-- Flip the sign of a signed formula. -/
def flip (sf : SignedFormula) : SignedFormula := ⟨sf.sign.flip, sf.formula⟩

@[simp]
theorem flip_flip (sf : SignedFormula) : sf.flip.flip = sf := by
  simp [flip, Sign.flip_flip]

/-- Check if this is a positive signed formula. -/
def isPos (sf : SignedFormula) : Bool := sf.sign = .pos

/-- Check if this is a negative signed formula. -/
def isNeg (sf : SignedFormula) : Bool := sf.sign = .neg

/-- Get the complexity of the signed formula (same as formula complexity). -/
def complexity (sf : SignedFormula) : Nat := sf.formula.complexity

end SignedFormula

/-!
## Branch Type
-/

/--
A branch is a list of signed formulas in a tableau.

Branches grow as tableau rules are applied. A branch is closed if it
contains a contradiction (both T(φ) and F(φ) for some formula φ, or T(⊥)).
A branch is open if it is saturated (all rules applied) and not closed.
-/
abbrev Branch := List SignedFormula

namespace Branch

/-- Empty branch. -/
def empty : Branch := []

/-- Check if branch contains a specific signed formula. -/
def contains (b : Branch) (sf : SignedFormula) : Bool :=
  b.any (· == sf)

/-- Check if branch contains a positive formula. -/
def hasPos (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.pos φ)

/-- Check if branch contains a negative formula. -/
def hasNeg (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.neg φ)

/-- Check if branch contains T(⊥), an immediate contradiction. -/
def hasBotPos (b : Branch) : Bool :=
  b.contains (SignedFormula.pos .bot)

/--
Check if branch has a direct contradiction: both T(φ) and F(φ) for some φ.
Returns `some φ` if contradiction found, `none` otherwise.
-/
def findContradiction (b : Branch) : Option Formula :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then some sf.formula
    else none

/-- Check if branch has any contradiction (T(⊥) or complementary pair). -/
def hasContradiction (b : Branch) : Bool :=
  b.hasBotPos || b.findContradiction.isSome

/-- Get all positive formulas in the branch. -/
def positives (b : Branch) : List Formula :=
  b.filterMap fun sf => if sf.isPos then some sf.formula else none

/-- Get all negative formulas in the branch. -/
def negatives (b : Branch) : List Formula :=
  b.filterMap fun sf => if sf.isNeg then some sf.formula else none

/-- Extend branch with a signed formula. -/
def extend (b : Branch) (sf : SignedFormula) : Branch := sf :: b

/-- Extend branch with multiple signed formulas. -/
def extendMany (b : Branch) (sfs : List SignedFormula) : Branch := sfs ++ b

/-- Total complexity of all formulas in branch. -/
def totalComplexity (b : Branch) : Nat :=
  b.foldl (fun acc sf => acc + sf.complexity) 0

end Branch

/-!
## Subformula Closure
-/

namespace Formula

/--
Collect all subformulas of a formula (including the formula itself).

This is used to bound the size of the tableau and ensure termination.
The subformula property ensures that tableau expansion only produces
formulas from the subformula closure.
-/
def subformulas : Formula → List Formula
  | φ@(.atom _) => [φ]
  | φ@.bot => [φ]
  | φ@(.imp ψ χ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.box ψ) => φ :: subformulas ψ
  | φ@(.all_past ψ) => φ :: subformulas ψ
  | φ@(.all_future ψ) => φ :: subformulas ψ

/-- Count of distinct subformulas (used for termination). -/
def subformulaCount (φ : Formula) : Nat := (subformulas φ).eraseDups.length

/-- Subformulas include the formula itself. -/
theorem self_mem_subformulas (φ : Formula) : φ ∈ subformulas φ := by
  cases φ <;> simp [subformulas]

/-- Subformulas of imp include both components. -/
theorem imp_left_mem_subformulas (ψ χ : Formula) : ψ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  right
  left
  exact self_mem_subformulas ψ

theorem imp_right_mem_subformulas (ψ χ : Formula) : χ ∈ subformulas (.imp ψ χ) := by
  simp only [subformulas, List.mem_cons, List.mem_append]
  right
  right
  exact self_mem_subformulas χ

/--
Transitivity of the subformula relation.

If chi is a subformula of psi, and psi is a subformula of phi,
then chi is a subformula of phi.
-/
theorem subformulas_trans {chi psi phi : Formula}
    (h1 : chi ∈ subformulas psi) (h2 : psi ∈ subformulas phi) :
    chi ∈ subformulas phi := by
  induction phi with
  | atom p =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | bot =>
    simp only [subformulas, List.mem_singleton] at h2
    subst h2
    exact h1
  | imp a b iha ihb =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; left
      exact iha ha
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; right
      exact ihb hb
  | box a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2
  | all_past a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2
  | all_future a iha =>
    simp only [subformulas, List.mem_cons] at h2
    rcases h2 with rfl | h2
    · exact h1
    · simp only [subformulas, List.mem_cons]
      right
      exact iha h2

end Formula

/--
Compute the subformula closure for a branch.

The subformula closure contains all subformulas of all formulas in the branch.
This bounds the size of the tableau and ensures termination.
-/
def subformulaClosure (b : Branch) : List Formula :=
  (b.flatMap (fun sf => Formula.subformulas sf.formula)).eraseDups

/--
Signed subformula closure: all signed versions of the subformula closure.

This is the maximum set of signed formulas that can appear in the tableau.
-/
def signedSubformulaClosure (b : Branch) : List SignedFormula :=
  let subs := subformulaClosure b
  subs.flatMap (fun φ => [SignedFormula.pos φ, SignedFormula.neg φ])

/-!
## Complexity Measures for Termination
-/

/--
Unexpanded complexity of a signed formula.

This measures how much "work" remains to fully expand the formula.
Atomic formulas and bot have 0 unexpanded complexity (nothing to expand).
-/
def unexpandedComplexity (sf : SignedFormula) : Nat :=
  match sf.formula with
  | .atom _ => 0
  | .bot => 0
  | .imp _ _ => sf.formula.complexity
  | .box _ => sf.formula.complexity
  | .all_past _ => sf.formula.complexity
  | .all_future _ => sf.formula.complexity

/--
Total unexpanded complexity of a branch.

This decreases with each tableau expansion step, ensuring termination.
-/
def branchUnexpandedComplexity (b : Branch) : Nat :=
  b.foldl (fun acc sf => acc + unexpandedComplexity sf) 0

end Bimodal.Metalogic.Decidability
