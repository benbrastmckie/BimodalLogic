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
## Monotonicity Lemmas

These lemmas establish that closure checks are monotonic: if a branch is closed,
extending it with more formulas keeps it closed.
-/

/--
hasNeg is monotonic: if `b` contains F(φ), then `x :: b` also contains F(φ).
-/
theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasNeg b φ → Branch.hasNeg (x :: b) φ := by
  intro h
  simp only [Branch.hasNeg, Branch.contains, List.any_cons] at h ⊢
  simp only [Bool.or_eq_true]
  right
  exact h

/--
hasPos is monotonic: if `b` contains T(φ), then `x :: b` also contains T(φ).
-/
theorem hasPos_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasPos b φ → Branch.hasPos (x :: b) φ := by
  intro h
  simp only [Branch.hasPos, Branch.contains, List.any_cons] at h ⊢
  simp only [Bool.or_eq_true]
  right
  exact h

/--
hasBotPos is monotonic: if `b` contains T(⊥), then `x :: b` also contains T(⊥).
-/
theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
    Branch.hasBotPos b → Branch.hasBotPos (x :: b) := by
  intro h
  simp only [Branch.hasBotPos, Branch.contains, List.any_cons] at h ⊢
  simp only [Bool.or_eq_true]
  right
  exact h

/--
checkBotPos is monotonic: if it succeeds on `b`, it succeeds on `x :: b`.
-/
theorem checkBotPos_mono (b : Branch) (x : SignedFormula) :
    (checkBotPos b).isSome → (checkBotPos (x :: b)).isSome := by
  simp only [checkBotPos]
  intro h
  split_ifs with hxb
  · rfl
  · -- b.hasBotPos was true but (x :: b).hasBotPos is false - contradiction
    exfalso
    split_ifs at h with hb
    · have := hasBotPos_mono b x hb
      exact hxb this
    · simp at h

/--
checkContradiction is monotonic: if it succeeds on `b`, it succeeds on `x :: b`.
-/
theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
  intro h
  rw [checkContradiction, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  rw [checkContradiction, List.findSome?_isSome_iff]
  refine ⟨sf, List.mem_cons_of_mem x hsf_mem, ?_⟩
  simp only [Option.isSome_iff_exists] at hsf_cond ⊢
  obtain ⟨reason, hreason⟩ := hsf_cond
  split_ifs at hreason with hcond
  -- The condition was true for b; show it's still true for x :: b
  obtain ⟨hpos, hneg⟩ := hcond
  have hneg' : Branch.hasNeg (x :: b) sf.formula := hasNeg_mono b x sf.formula hneg
  use ClosureReason.contradiction sf.formula
  split_ifs with hcond'
  · rfl
  · push_neg at hcond'
    exact absurd hneg' (hcond' hpos)

/--
checkAxiomNeg is monotonic: if it succeeds on `b`, it succeeds on `x :: b`.
The axiom check is branch-independent (only depends on the formula pattern).
-/
theorem checkAxiomNeg_mono (b : Branch) (x : SignedFormula) :
    (checkAxiomNeg b).isSome → (checkAxiomNeg (x :: b)).isSome := by
  intro h
  rw [checkAxiomNeg, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  rw [checkAxiomNeg, List.findSome?_isSome_iff]
  exact ⟨sf, List.mem_cons_of_mem x hsf_mem, hsf_cond⟩

/-!
## Closure Properties

Note: These theorems require careful reasoning about how `findSome?` interacts
with branch extension. The proofs are non-trivial because `checkContradiction`
captures the branch in its lambda, creating a dependency between the branch
being searched and the condition being checked.
-/

/--
A closed branch remains closed when extended.
Adding more formulas cannot "undo" a contradiction.

The intuition is clear: if we found a contradiction in `b`, that same
contradiction still exists in `sf :: b`. The technical challenge is that
`checkContradiction` checks `hasNeg b` (not `hasNeg (sf :: b)`), but since
`hasNeg` is monotonic, any witness in `b` remains valid.
-/
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed, findClosure] at h ⊢
  -- h says: (checkBotPos b <|> checkContradiction b <|> checkAxiomNeg b).isSome = true
  -- We analyze which of the three checks succeeded
  rw [Option.isSome_iff_exists] at h
  obtain ⟨r, hr⟩ := h
  -- hr : checkBotPos b <|> checkContradiction b <|> checkAxiomNeg b = some r
  rw [Option.orElse_eq_some] at hr
  rcases hr with hbot | ⟨_, hr'⟩
  · -- checkBotPos b = some r
    have hsome : (checkBotPos (sf :: b)).isSome := checkBotPos_mono b sf (by simp [hbot])
    simp only [Option.isSome_iff_exists] at hsome
    obtain ⟨r', hr'⟩ := hsome
    rw [Option.isSome_iff_exists]
    exact ⟨r', by simp [hr']⟩
  · -- checkBotPos b = none, and (checkContradiction b <|> checkAxiomNeg b) = some r
    rw [Option.orElse_eq_some] at hr'
    rcases hr' with hcontra | ⟨_, hax⟩
    · -- checkContradiction b = some r
      have hsome : (checkContradiction (sf :: b)).isSome := checkContradiction_mono b sf (by simp [hcontra])
      -- Either checkBotPos (sf :: b) is Some (then we're done) or checkContradiction is Some
      cases hbot' : checkBotPos (sf :: b) with
      | some _ => rfl
      | none =>
        simp only [Option.isSome_iff_exists] at hsome
        obtain ⟨r', hr''⟩ := hsome
        rw [Option.isSome_iff_exists]
        exact ⟨r', by simp [hbot', hr'']⟩
    · -- checkAxiomNeg b = some r
      have hsome : (checkAxiomNeg (sf :: b)).isSome := checkAxiomNeg_mono b sf (by simp [hax])
      cases hbot' : checkBotPos (sf :: b) with
      | some _ => rfl
      | none =>
        cases hcontra' : checkContradiction (sf :: b) with
        | some _ => rfl
        | none =>
          simp only [Option.isSome_iff_exists] at hsome
          obtain ⟨r', hr''⟩ := hsome
          rw [Option.isSome_iff_exists]
          exact ⟨r', by simp [hbot', hcontra', hr'']⟩

/--
If a branch has T(φ) and we add F(φ), it becomes closed.
-/
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    Branch.hasPos b φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure]
  -- If checkBotPos succeeds, we're done. Otherwise, use checkContradiction.
  cases hbot : checkBotPos (SignedFormula.neg φ :: b) with
  | some _ => rfl
  | none =>
    -- checkContradiction will find the contradiction
    simp only [hbot, Option.none_or]
    rw [Option.isSome_iff_exists]
    -- Use findSome?_isSome_iff to find the witness
    rw [checkContradiction, List.findSome?_isSome_iff]
    -- Extract witness from hasPos
    simp only [Branch.hasPos, Branch.contains, List.any_eq_true] at hpos
    obtain ⟨witness, hwit_mem, hwit_eq⟩ := hpos
    simp only [beq_iff_eq] at hwit_eq
    use witness
    constructor
    · exact List.mem_cons_of_mem (SignedFormula.neg φ) hwit_mem
    · -- witness.isPos = true ∧ (SignedFormula.neg φ :: b).hasNeg witness.formula
      simp only [Option.isSome_iff_exists]
      use ClosureReason.contradiction witness.formula
      rw [hwit_eq]
      simp only [SignedFormula.pos, SignedFormula.isPos]
      split_ifs with h
      · rfl
      · exfalso
        push_neg at h
        rcases h with ⟨hpos', _⟩ | ⟨_, hneg'⟩
        · exact hpos' rfl
        · -- Need to show (SignedFormula.neg φ :: b).hasNeg φ = true
          simp only [Branch.hasNeg, Branch.contains, List.any_cons, beq_self_eq_true,
            Bool.true_or, SignedFormula.neg] at hneg'

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
