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
## World and Time Index Types
-/

/-- World index for multi-world modal reasoning in labeled tableaux. -/
abbrev WorldIndex := Nat

/-- Time index for temporal reasoning in labeled tableaux. -/
abbrev TimeIndex := Nat

/--
A label combining world and time indices for tableau signed formulas.
Each signed formula carries a label indicating the world and time at which
it is asserted.
-/
structure Label : Type where
  /-- The world at which the formula is evaluated. -/
  world : WorldIndex
  /-- The time at which the formula is evaluated. -/
  time : TimeIndex
  deriving Repr, DecidableEq, BEq, Hashable

namespace Label

/-- The initial label at world 0, time 0. -/
def initial : Label := { world := 0, time := 0 }

/-- BEq on Label decomposes to component BEq. -/
theorem beq_eq (l1 l2 : Label) :
    (l1 == l2) = (l1.world == l2.world && l1.time == l2.time) := by
  cases l1; cases l2; rfl

/-- BEq on Label is reflexive. -/
theorem beq_refl (l : Label) : (l == l) = true := by
  rw [beq_eq]
  simp only [beq_self_eq_true, Bool.and_self]

instance : ReflBEq Label where
  rfl := beq_refl _

/-- BEq on Label is injective. -/
theorem eq_of_beq {l1 l2 : Label} (h : (l1 == l2) = true) : l1 = l2 := by
  rw [beq_eq] at h
  simp only [Bool.and_eq_true, beq_iff_eq] at h
  cases l1; cases l2
  simp only [mk.injEq]
  exact h

instance : LawfulBEq Label where
  eq_of_beq := eq_of_beq
  rfl := beq_refl _

end Label

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

/-- BEq on Sign is reflexive. -/
instance : ReflBEq Sign where
  rfl := fun {s} => by cases s <;> native_decide

/-- BEq on Sign is injective: if `s1 == s2 = true` then `s1 = s2`. -/
theorem eq_of_beq {s1 s2 : Sign} (h : (s1 == s2) = true) : s1 = s2 := by
  cases s1 <;> cases s2
  · rfl
  · exact absurd h (by native_decide)
  · exact absurd h (by native_decide)
  · rfl

instance : LawfulBEq Sign where
  eq_of_beq := eq_of_beq
  rfl := by intro s; cases s <;> native_decide

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
  /-- The world/time label for this assertion. -/
  label : Label
  deriving Repr, DecidableEq, BEq, Hashable

namespace SignedFormula

/-- Create a positive signed formula (asserted true). -/
def pos (φ : Formula) (l : Label := Label.initial) : SignedFormula := ⟨.pos, φ, l⟩

/-- Create a negative signed formula (asserted false). -/
def neg (φ : Formula) (l : Label := Label.initial) : SignedFormula := ⟨.neg, φ, l⟩

/-- Flip the sign of a signed formula, preserving the label. -/
def flip (sf : SignedFormula) : SignedFormula := ⟨sf.sign.flip, sf.formula, sf.label⟩

@[simp]
theorem flip_flip (sf : SignedFormula) : sf.flip.flip = sf := by
  simp [flip, Sign.flip_flip]

/-- Check if this is a positive signed formula. -/
def isPos (sf : SignedFormula) : Bool := sf.sign = .pos

/-- Check if this is a negative signed formula. -/
def isNeg (sf : SignedFormula) : Bool := sf.sign = .neg

/-- Get the complexity of the signed formula (same as formula complexity). -/
def complexity (sf : SignedFormula) : Nat := sf.formula.complexity

/-- Definitional equality for SignedFormula BEq. -/
theorem beq_eq (sf1 sf2 : SignedFormula) :
    (sf1 == sf2) = (sf1.sign == sf2.sign && (sf1.formula == sf2.formula && sf1.label == sf2.label)) := by
  cases sf1; cases sf2; rfl

/-- BEq on SignedFormula is reflexive. -/
theorem beq_refl (sf : SignedFormula) : (sf == sf) = true := by
  rw [beq_eq]
  simp only [beq_self_eq_true, Bool.and_self]

instance : ReflBEq SignedFormula where
  rfl := beq_refl _

/-- BEq on SignedFormula is injective: if `sf1 == sf2 = true` then `sf1 = sf2`. -/
theorem eq_of_beq {sf1 sf2 : SignedFormula} (h : (sf1 == sf2) = true) : sf1 = sf2 := by
  rw [beq_eq] at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hs, hf, hl⟩ := h
  cases sf1 with
  | mk s1 f1 l1 =>
    cases sf2 with
    | mk s2 f2 l2 =>
      have hs := Sign.eq_of_beq hs
      have hf := Formula.eq_of_beq hf
      have hl := Label.eq_of_beq hl
      subst hs hf hl
      rfl

instance : LawfulBEq SignedFormula where
  eq_of_beq := eq_of_beq
  rfl := beq_refl _

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

/-- Check if branch contains a positive formula at the initial label. -/
def hasPos (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.pos φ)

/-- Check if branch contains a negative formula at the initial label. -/
def hasNeg (b : Branch) (φ : Formula) : Bool :=
  b.contains (SignedFormula.neg φ)

/-- Check if branch contains T(φ) at a specific label. -/
def hasPosAt (b : Branch) (φ : Formula) (l : Label) : Bool :=
  b.contains (SignedFormula.pos φ l)

/-- Check if branch contains F(φ) at a specific label. -/
def hasNegAt (b : Branch) (φ : Formula) (l : Label) : Bool :=
  b.contains (SignedFormula.neg φ l)

/-- Check if branch contains T(⊥) at any label. -/
def hasBotPos (b : Branch) : Bool :=
  b.any fun sf => sf.sign == .pos && sf.formula == .bot

/--
Check if branch has a direct contradiction: both T(φ) and F(φ) at the same label.
Returns `some φ` if contradiction found, `none` otherwise.
-/
def findContradiction (b : Branch) : Option Formula :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNegAt sf.formula sf.label then some sf.formula
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

/--
Collect all distinct world indices from signed formulas in the branch.
Used by S5 modal rules to know which worlds exist for universal propagation.
-/
def knownWorlds (b : Branch) : List WorldIndex :=
  (b.map (·.label.world)).eraseDups

/--
Maximum world index in the branch (0 if empty).
Used to compute the next fresh world index.
-/
def maxWorld (b : Branch) : WorldIndex :=
  b.foldl (fun acc sf => max acc sf.label.world) 0

/--
Next fresh world index (one past the maximum).
Used by existential modal rules to introduce witness worlds.
-/
def nextWorld (b : Branch) : WorldIndex :=
  b.maxWorld + 1

/--
Collect all T(□A) formulas in the branch (positive box formulas).
These are universal modal formulas that must be propagated to every known world.
-/
def boxPosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .pos, .box _ => true
    | _, _ => false

/--
Collect all F(◇A) formulas in the branch (negative diamond formulas).
These are universal modal formulas that must be propagated to every known world.
F(◇A) = F(¬□¬A) means □¬A holds, so ¬A must hold at every world.
Diamond encoding: ◇A = ¬□¬A = (.imp (.box (.imp A .bot)) .bot)
-/
def diamondNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .neg, .imp (.box (.imp _ .bot)) .bot => true
    | _, _ => false

/--
Collect all distinct time indices from signed formulas in the branch.
Used by temporal rules to know which times exist for universal propagation.
-/
def knownTimes (b : Branch) : List TimeIndex :=
  (b.map (·.label.time)).eraseDups

/--
Maximum time index in the branch (0 if empty).
Used to compute the next fresh time index.
-/
def maxTime (b : Branch) : TimeIndex :=
  b.foldl (fun acc sf => max acc sf.label.time) 0

/--
Next fresh time index (one past the maximum).
Used by existential temporal rules to introduce witness times.
-/
def nextTime (b : Branch) : TimeIndex :=
  b.maxTime + 1

/--
Collect all T(GA) formulas in the branch (positive all-future formulas).
These are universal temporal formulas that must be propagated to every known future time.
-/
def allFuturePosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .pos, .all_future _ => true
    | _, _ => false

/--
Collect all F(FA) formulas in the branch (negative some-future formulas).
These are universal temporal formulas that must be propagated to every known future time.
F(FA) = F(¬G¬A) means G¬A holds, so ¬A must hold at every future time.
-/
def someFutureNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .neg, .some_future _ => true
    | _, _ => false

/--
Collect all T(HA) formulas in the branch (positive all-past formulas).
These are universal temporal formulas that must be propagated to every known past time.
-/
def allPastPosFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .pos, .all_past _ => true
    | _, _ => false

/--
Collect all F(PA) formulas in the branch (negative some-past formulas).
These are universal temporal formulas that must be propagated to every known past time.
F(PA) = F(¬H¬A) means H¬A holds, so ¬A must hold at every past time.
-/
def somePastNegFormulas (b : Branch) : List SignedFormula :=
  b.filter fun sf =>
    match sf.sign, sf.formula with
    | .neg, .some_past _ => true
    | _, _ => false

end Branch

/-!
## Time Ordering Constraints
-/

/--
Time ordering constraints for abstract temporal order tracking.

In temporal tableau rules, fresh time points are introduced by existential rules
(F(GA), T(FA), etc.). These fresh time points have numerically larger indices
but may represent logically earlier or later times. The TimeOrdering structure
tracks the abstract temporal order via explicit constraint pairs.

Each constraint `(a, b)` means `a` is strictly before `b` in the abstract
temporal order (a < b).
-/
structure TimeOrdering : Type where
  /-- List of ordering constraints. Each `(a, b)` means `a < b` in abstract time. -/
  constraints : List (TimeIndex × TimeIndex)
  deriving Repr

namespace TimeOrdering

/-- Empty time ordering with no constraints. -/
def empty : TimeOrdering := { constraints := [] }

/-- Initial ordering: time 0 exists implicitly, no constraints needed. -/
def initWithTime0 : TimeOrdering := empty

/-- Add a future constraint: `t_new` is strictly after `t`. -/
def addFuture (ord : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering :=
  { constraints := (t, t_new) :: ord.constraints }

/-- Add a past constraint: `t_new` is strictly before `t`. -/
def addPast (ord : TimeOrdering) (t t_new : TimeIndex) : TimeOrdering :=
  { constraints := (t_new, t) :: ord.constraints }

/-- Find all times strictly after `t` (immediate successors in the ordering). -/
def futureOf (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  ord.constraints.filterMap fun (a, b) =>
    if a == t then some b else none

/-- Find all times strictly before `t` (immediate predecessors in the ordering). -/
def pastOf (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  ord.constraints.filterMap fun (a, b) =>
    if b == t then some a else none

end TimeOrdering

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
  | φ@(.untl ψ χ) => φ :: (subformulas ψ ++ subformulas χ)
  | φ@(.snce ψ χ) => φ :: (subformulas ψ ++ subformulas χ)

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
  | untl a b iha ihb =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; left
      exact iha ha
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; right
      exact ihb hb
  | snce a b iha ihb =>
    simp only [subformulas, List.mem_cons, List.mem_append] at h2
    rcases h2 with rfl | ha | hb
    · exact h1
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; left
      exact iha ha
    · simp only [subformulas, List.mem_cons, List.mem_append]
      right; right
      exact ihb hb

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
  | .untl _ _ => sf.formula.complexity
  | .snce _ _ => sf.formula.complexity

/--
Total unexpanded complexity of a branch.

This decreases with each tableau expansion step, ensuring termination.
-/
def branchUnexpandedComplexity (b : Branch) : Nat :=
  b.foldl (fun acc sf => acc + unexpandedComplexity sf) 0

end Bimodal.Metalogic.Decidability
