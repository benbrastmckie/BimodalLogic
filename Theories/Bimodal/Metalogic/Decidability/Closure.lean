import Bimodal.Metalogic.Decidability.Tableau
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

namespace Bimodal.Metalogic.Decidability

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
          if h : sf.formula = φ then
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
## Closure Properties - Helper Lemmas

These lemmas establish monotonicity: if a property holds for a branch `b`,
it also holds for any extension `x :: b`.
-/

/--
`hasNeg` is monotonic: if we found a negation of φ in b, we still find it in x :: b.
-/
theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    b.hasNeg φ → (x :: b).hasNeg φ := by
  intro h
  simp only [Branch.hasNeg, Branch.contains, List.any_cons]
  exact Or.inr h

/--
`hasPos` is monotonic: if we found a positive φ in b, we still find it in x :: b.
-/
theorem hasPos_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    b.hasPos φ → (x :: b).hasPos φ := by
  intro h
  simp only [Branch.hasPos, Branch.contains, List.any_cons]
  exact Or.inr h

/--
`hasBotPos` is monotonic: if T(⊥) was in b, it's still in x :: b.
-/
theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
    b.hasBotPos → (x :: b).hasBotPos := by
  intro h
  simp only [Branch.hasBotPos, Branch.contains, List.any_cons]
  exact Or.inr h

/-!
## Check Function Monotonicity

These lemmas establish that if a check function returns `some` on `b`,
it still returns `some` on `x :: b`.
-/

/--
`checkBotPos` is monotonic.
-/
theorem checkBotPos_mono (b : Branch) (x : SignedFormula) :
    (checkBotPos b).isSome → (checkBotPos (x :: b)).isSome := by
  intro h
  simp only [checkBotPos] at h ⊢
  split at h
  · next hbot =>
    have := hasBotPos_mono b x hbot
    simp only [ite_some_none_eq_isSome_of_true this]
  · contradiction

/--
`List.findSome?` satisfies a monotonicity property: if `findSome? f b` is `some`,
then `findSome? f (x :: b)` is also `some` (possibly with a different value).
-/
theorem findSome?_isSome_of_suffix {α β : Type*} (f : α → Option β)
    (x : α) (b : List α) :
    (List.findSome? f b).isSome → (List.findSome? f (x :: b)).isSome := by
  intro h
  simp only [List.findSome?_cons]
  cases hx : f x with
  | none => simp [hx, h]
  | some val => simp

/--
`checkContradiction` is monotonic.
If a contradiction exists in b, it still exists in x :: b.
-/
theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
  intro h
  simp only [checkContradiction] at h ⊢
  -- We need to show the findSome? still finds a witness
  exact findSome?_isSome_of_suffix _ x b h

/--
`checkAxiomNeg` is monotonic.
If a negated axiom exists in b, it still exists in x :: b.
-/
theorem checkAxiomNeg_mono (b : Branch) (x : SignedFormula) :
    (checkAxiomNeg b).isSome → (checkAxiomNeg (x :: b)).isSome := by
  intro h
  simp only [checkAxiomNeg] at h ⊢
  exact findSome?_isSome_of_suffix _ x b h

/-!
## Main Closure Theorems
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
    -- We need to show findClosure (sf :: b) is some
    simp only [findClosure] at hb ⊢
    -- Case analysis on which check function succeeded
    cases hbot : checkBotPos b with
    | some r =>
      -- checkBotPos found it, so it's still there
      have := checkBotPos_mono b sf (by simp [hbot])
      simp only [Option.isSome_iff_exists] at this
      obtain ⟨r', hr'⟩ := this
      simp [hr']
    | none =>
      -- checkBotPos failed, try checkContradiction
      simp only [hbot, Option.none_orElse] at hb
      cases hcontra : checkContradiction b with
      | some r =>
        have := checkContradiction_mono b sf (by simp [hcontra])
        simp only [Option.isSome_iff_exists] at this
        obtain ⟨r', hr'⟩ := this
        simp only [Option.none_orElse]
        cases hbot' : checkBotPos (sf :: b) with
        | some _ => simp
        | none => simp [hr']
      | none =>
        simp only [hcontra, Option.none_orElse] at hb
        -- Must be checkAxiomNeg
        cases hax : checkAxiomNeg b with
        | some r =>
          have := checkAxiomNeg_mono b sf (by simp [hax])
          simp only [Option.isSome_iff_exists] at this
          obtain ⟨r', hr'⟩ := this
          simp only [Option.none_orElse]
          cases hbot' : checkBotPos (sf :: b) with
          | some _ => simp
          | none =>
            cases hcontra' : checkContradiction (sf :: b) with
            | some _ => simp
            | none => simp [hr']
        | none =>
          simp [hbot, hcontra, hax] at hb

/--
Helper: hasNeg on extended branch finds the head element.
-/
theorem hasNeg_head (b : Branch) (φ : Formula) :
    (SignedFormula.neg φ :: b).hasNeg φ := by
  simp only [Branch.hasNeg, Branch.contains, List.any_cons]
  left
  rfl

/--
Helper: When we have T(φ) in b, the contradiction check on F(φ) :: b finds it.
We need to unfold the definition and construct the witness directly.
-/
theorem checkContradiction_of_pos_with_neg_head (b : Branch) (φ : Formula) :
    b.hasPos φ → (checkContradiction (SignedFormula.neg φ :: b)).isSome := by
  intro hpos
  simp only [checkContradiction, List.findSome?_cons]
  -- The head is F(φ), which is negative, so the condition sf.isPos fails
  simp only [SignedFormula.neg, SignedFormula.isPos, Sign.pos, decide_False, Bool.false_and,
    ite_false]
  -- Now we recurse into the tail (which is b)
  -- We need to show findSome? finds T(φ) in b where hasNeg holds
  -- Because hasPos φ means T(φ) ∈ b, and hasNeg φ holds on the extended branch
  -- First, let's use that hasPos implies there's T(φ) in b
  simp only [Branch.hasPos, Branch.contains] at hpos
  -- We need to construct a witness: some sf ∈ b such that sf.isPos ∧ hasNeg of extended branch
  -- Since the extended branch has F(φ) at head, hasNeg φ is true on it
  have hneg : (SignedFormula.neg φ :: b).hasNeg φ := hasNeg_head b φ
  -- Use the fact that T(φ) is in b
  induction b with
  | nil => simp at hpos
  | cons x xs ih =>
    simp only [List.any_cons] at hpos
    simp only [List.findSome?_cons]
    cases hx : x == SignedFormula.pos φ with
    | false =>
      -- x is not T(φ), so continue searching
      simp only [Bool.false_eq_true, false_or] at hpos
      -- ih needs the hypothesis for xs
      have h_neg_xs : (SignedFormula.neg φ :: xs).hasNeg φ := hasNeg_head xs φ
      -- But wait, we're checking hasNeg on (SignedFormula.neg φ :: x :: xs), not on (neg :: xs)
      -- The branch we're searching is (neg φ :: x :: xs), and findSome? is on (x :: xs)
      -- So we need to show the inner findSome? succeeds
      -- When checking x, the condition is x.isPos ∧ hasNeg x.formula
      -- If x is not T(φ), we can't use it directly, so we recurse
      -- This is getting complicated - let me try a different approach
      sorry
    | true =>
      -- x is T(φ)
      simp only [beq_iff_eq] at hx
      subst hx
      simp only [SignedFormula.pos, SignedFormula.isPos, decide_True, Bool.true_and]
      -- Need to show hasNeg (SignedFormula.neg φ :: SignedFormula.pos φ :: xs) φ
      -- which is hasNeg_head applied to the full branch
      simp only [Branch.hasNeg, Branch.contains, List.any_cons]
      left
      rfl

/--
If a branch has T(φ) and we add F(φ), it becomes closed.
-/
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure]
  have h := checkContradiction_of_pos_with_neg_head b φ hpos
  simp only [Option.isSome_iff_exists] at h
  obtain ⟨r, hr⟩ := h
  -- Now we have checkContradiction succeeds, so findClosure succeeds
  simp only [Option.orElse_eq_some]
  cases hbot : checkBotPos (SignedFormula.neg φ :: b) with
  | some r' => left; exact ⟨r', rfl⟩
  | none =>
    right
    constructor
    · rfl
    · left; exact ⟨r, hr⟩

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

end Bimodal.Metalogic.Decidability
