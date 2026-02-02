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
## Helper Lemmas for Monotonicity
-/

/-- hasBotPos is monotonic under branch extension -/
theorem hasBotPos_mono (b : Branch) (sf : SignedFormula) :
    Branch.hasBotPos b → Branch.hasBotPos (sf :: b) := by
  unfold Branch.hasBotPos Branch.contains
  simp only [List.any_cons, Bool.or_eq_true, beq_iff_eq]
  intro h
  right
  exact h

/-- hasPos is monotonic under branch extension -/
theorem hasPos_mono (b : Branch) (sf : SignedFormula) (φ : Formula) :
    Branch.hasPos b φ → Branch.hasPos (sf :: b) φ := by
  unfold Branch.hasPos Branch.contains
  simp only [List.any_cons, Bool.or_eq_true, beq_iff_eq]
  intro h
  right
  exact h

/-- hasNeg is monotonic under branch extension -/
theorem hasNeg_mono (b : Branch) (sf : SignedFormula) (φ : Formula) :
    Branch.hasNeg b φ → Branch.hasNeg (sf :: b) φ := by
  unfold Branch.hasNeg Branch.contains
  simp only [List.any_cons, Bool.or_eq_true, beq_iff_eq]
  intro h
  right
  exact h

/-- checkBotPos is monotonic: if it returns some for b, it returns some for sf :: b -/
theorem checkBotPos_mono (b : Branch) (sf : SignedFormula) :
    (checkBotPos b).isSome → (checkBotPos (sf :: b)).isSome := by
  unfold checkBotPos
  intro h
  split at h
  · rename_i hBot
    split
    · simp
    · rename_i hnoBot
      exact absurd (hasBotPos_mono b sf hBot) hnoBot
  · simp at h

/-- If a branch contains a contradiction witness, so does the extended branch -/
theorem checkContradiction_mono (b : Branch) (sf : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (sf :: b)).isSome := by
  unfold checkContradiction
  intro h
  -- Key insight: We need to find an element in (sf :: b) that satisfies the predicate
  -- If sf satisfies it, we're done. Otherwise, we look in b.
  -- The tricky part: the predicate uses hasNeg on the extended branch, which is different.
  -- But hasNeg is monotonic: if hasNeg b φ, then hasNeg (sf :: b) φ
  simp only [List.findSome?_cons]
  -- First check if sf satisfies the predicate on the extended branch
  by_cases hsf : sf.isPos ∧ Branch.hasNeg (sf :: b) sf.formula
  · simp [hsf]
  · simp only [hsf, ↓reduceIte]
    -- sf doesn't satisfy, so we look in b
    -- We need to show that findSome? on b returns some when the predicate uses (sf :: b)
    -- Key: if an element of b satisfied the old predicate (using b), it satisfies the new one (using sf :: b)
    induction b with
    | nil => simp at h
    | cons hd tl ih =>
      simp only [List.findSome?_cons] at h ⊢
      by_cases hhd : hd.isPos ∧ Branch.hasNeg (hd :: tl) hd.formula
      · -- hd satisfies old predicate, so it satisfies new predicate (with monotonicity)
        have hhdNew : hd.isPos ∧ Branch.hasNeg (sf :: hd :: tl) hd.formula := by
          constructor
          · exact hhd.1
          · -- hasNeg (hd :: tl) → hasNeg (sf :: hd :: tl)
            apply hasNeg_mono (hd :: tl) sf
            exact hhd.2
        simp [hhdNew]
      · -- hd doesn't satisfy old predicate
        simp only [hhd, ↓reduceIte] at h
        by_cases hhdNew : hd.isPos ∧ Branch.hasNeg (sf :: hd :: tl) hd.formula
        · simp [hhdNew]
        · simp only [hhdNew, ↓reduceIte]
          -- Need to apply induction hypothesis
          -- But ih requires findSome? on tl with predicate using (hd :: tl) to be Some
          -- We have findSome? on tl with predicate using (hd :: tl) from h
          -- Need to transform to predicate using (sf :: hd :: tl)
          -- This is where the recursion gets tricky because the predicate changes
          -- Let's use a generalized induction
          sorry

/-- checkAxiomNeg is monotonic -/
theorem checkAxiomNeg_mono (b : Branch) (sf : SignedFormula) :
    (checkAxiomNeg b).isSome → (checkAxiomNeg (sf :: b)).isSome := by
  unfold checkAxiomNeg
  intro h
  simp only [List.findSome?_cons]
  -- The predicate for checkAxiomNeg doesn't depend on the branch
  cases hsf : (if sf.isNeg then
      match matchAxiom sf.formula with
      | some ⟨φ, witness⟩ => if _ : sf.formula = φ then some (ClosureReason.axiomNeg φ witness) else none
      | none => none
    else none) with
  | none =>
    -- sf doesn't witness, find in b
    induction b with
    | nil => simp at h
    | cons hd tl ih =>
      simp only [List.findSome?_cons] at h ⊢
      -- The predicate is the same regardless of branch context
      cases hhd : (if hd.isNeg then
          match matchAxiom hd.formula with
          | some ⟨φ, witness⟩ => if _ : hd.formula = φ then some (ClosureReason.axiomNeg φ witness) else none
          | none => none
        else none) with
      | none =>
        simp only [hhd] at h
        exact ih h
      | some _ => simp
  | some _ => simp

/-!
## Closure Properties
-/

/-- Helper: isSome of orElse is disjunction of isSome -/
private theorem orElse_isSome {α : Type*} (a b : Option α) :
    (a <|> b).isSome = true ↔ a.isSome = true ∨ b.isSome = true := by
  cases a with
  | none => simp
  | some x => simp

/--
A closed branch remains closed when extended.
Adding more formulas cannot "undo" a contradiction.
-/
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed, findClosure] at *
  -- findClosure = checkBotPos <|> checkContradiction <|> checkAxiomNeg
  -- isSome of orElse: (a <|> b).isSome ↔ a.isSome ∨ b.isSome
  rw [orElse_isSome] at *
  rcases h with hbot | hrest
  · -- checkBotPos b was Some
    left
    exact checkBotPos_mono b sf hbot
  · rw [orElse_isSome] at hrest
    rcases hrest with hcontra | hax
    · -- checkContradiction b was Some
      right
      rw [orElse_isSome]
      left
      exact checkContradiction_mono b sf hcontra
    · -- checkAxiomNeg b was Some
      right
      rw [orElse_isSome]
      right
      exact checkAxiomNeg_mono b sf hax

/--
If a branch has T(φ) and we add F(φ), it becomes closed.
-/
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure]
  rw [orElse_isSome]
  -- checkContradiction will find the contradiction
  right
  rw [orElse_isSome]
  left
  -- Show checkContradiction (SignedFormula.neg φ :: b) returns Some
  unfold checkContradiction
  simp only [List.findSome?_cons]
  -- The head element F(φ) has isPos = false, so condition fails
  simp only [SignedFormula.isPos, ↓reduceIte]
  -- Now we need to find T(φ) in b such that it has hasNeg with the extended branch
  simp only [Branch.hasPos, Branch.contains] at hpos
  rw [List.any_eq_true] at hpos
  obtain ⟨sf', hsfmem, hsfeq⟩ := hpos
  -- hsfeq : (sf' == SignedFormula.pos φ) = true, convert to eq
  have hsfeq' : sf' = SignedFormula.pos φ := eq_of_beq_eq_true hsfeq
  subst hsfeq'
  -- Now we show findSome? finds this element
  induction b with
  | nil => exact absurd hsfmem (List.not_mem_nil _)
  | cons hd tl ih =>
    simp only [List.findSome?_cons]
    cases hmem_cases : List.mem_cons.mp hsfmem with
    | inl heq =>
      -- hd = SignedFormula.pos φ
      subst heq
      -- hd.isPos = true and hasNeg (SignedFormula.neg φ :: hd :: tl) hd.formula holds
      simp only [SignedFormula.pos, SignedFormula.isPos, decide_eq_true_eq, ↓reduceIte]
      -- hasNeg includes SignedFormula.neg φ at the head
      simp only [SignedFormula.formula, Branch.hasNeg, Branch.contains, List.any_cons]
      simp only [SignedFormula.neg, beq_self_eq_true, Bool.true_or]
    | inr hmem =>
      -- SignedFormula.pos φ ∈ tl
      by_cases hhd : hd.isPos ∧ Branch.hasNeg ({ sign := Sign.neg, formula := φ } :: hd :: tl) hd.formula
      · simp only [hhd, ↓reduceIte, Option.isSome_some]
      · simp only [hhd, ↓reduceIte]
        exact ih hmem

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
