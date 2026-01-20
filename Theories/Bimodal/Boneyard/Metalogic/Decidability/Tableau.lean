import Bimodal.Boneyard.Metalogic.Decidability.SignedFormula

/-!
# Tableau Rules for TM Bimodal Logic

This module defines the tableau expansion rules for the TM bimodal logic
decision procedure. The rules systematically decompose signed formulas
until branches close (contradiction found) or saturate (countermodel exists).

## Main Definitions

- `TableauRule`: Enumeration of all tableau expansion rules
- `RuleResult`: Result of applying a rule (linear extension or branching)
- `applyRule`: Apply a tableau rule to a signed formula
- `expandBranch`: Single-step expansion of a branch

## Tableau Rules

### Propositional Rules
- `andPos`: T(A ∧ B) → T(A), T(B) (non-branching)
- `andNeg`: F(A ∧ B) → F(A) | F(B) (branching)
- `orPos`: T(A ∨ B) → T(A) | T(B) (branching)
- `orNeg`: F(A ∨ B) → F(A), F(B) (non-branching)
- `impPos`: T(A → B) → F(A) | T(B) (branching)
- `impNeg`: F(A → B) → T(A), F(B) (non-branching)
- `negPos`: T(¬A) → F(A) (non-branching)
- `negNeg`: F(¬A) → T(A) (non-branching)

### Modal S5 Rules
- `boxPos`: T(□A) → propagate T(A) to accessible states
- `boxNeg`: F(□A) → create state with F(A)

### Temporal Rules
- `allFuturePos`: T(GA) → propagate T(A) to future times
- `allFutureNeg`: F(GA) → create future time with F(A)
- `allPastPos`: T(HA) → propagate T(A) to past times
- `allPastNeg`: F(HA) → create past time with F(A)

## Implementation Notes

Since TM combines S5 modal logic with linear temporal logic, we use a
simplified tableau system that exploits the special properties of S5
(all worlds are mutually accessible, so we can use a single equivalence class).

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Boneyard.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Tableau Rule Type
-/

/--
Tableau expansion rules for TM bimodal logic.

Each rule specifies how to decompose a signed formula. Rules are either:
- **Linear** (non-branching): Add formulas to the current branch
- **Branching**: Split into multiple branches (any must close for tableau to close)
-/
inductive TableauRule : Type where
  /-- T(A ∧ B) → T(A), T(B) (A ∧ B = ¬(A → ¬B)) -/
  | andPos
  /-- F(A ∧ B) → F(A) | F(B) (branching) -/
  | andNeg
  /-- T(A ∨ B) → T(A) | T(B) (A ∨ B = ¬A → B, branching) -/
  | orPos
  /-- F(A ∨ B) → F(A), F(B) -/
  | orNeg
  /-- T(A → B) → F(A) | T(B) (branching) -/
  | impPos
  /-- F(A → B) → T(A), F(B) -/
  | impNeg
  /-- T(¬A) → F(A) (¬A = A → ⊥) -/
  | negPos
  /-- F(¬A) → T(A) -/
  | negNeg
  /-- T(□A) → T(A) at current state (S5 reflexivity) -/
  | boxPos
  /-- F(□A) → F(A) (introduce witness state in S5) -/
  | boxNeg
  /-- T(◇A) → T(A) (S5: possibility implies accessibility) -/
  | diamondPos
  /-- F(◇A) → F(A) at all accessible states -/
  | diamondNeg
  /-- T(GA) → T(A) at current and all future times -/
  | allFuturePos
  /-- F(GA) → F(A) at some future time -/
  | allFutureNeg
  /-- T(HA) → T(A) at current and all past times -/
  | allPastPos
  /-- F(HA) → F(A) at some past time -/
  | allPastNeg
  deriving Repr, DecidableEq

/-!
## Rule Result Type
-/

/--
Result of applying a tableau rule to a signed formula.

- `linear`: Add formulas to the current branch (non-branching)
- `branching`: Split into multiple branches (all must close for validity)
- `notApplicable`: Rule doesn't apply to this signed formula
-/
inductive RuleResult : Type where
  /-- Add these signed formulas to the current branch. -/
  | linear (formulas : List SignedFormula)
  /-- Split into multiple branches (each is a list of formulas to add). -/
  | branching (branches : List (List SignedFormula))
  /-- Rule does not apply to this signed formula. -/
  | notApplicable
  deriving Repr

/-!
## Formula Decomposition Helpers
-/

/--
Try to decompose a formula as negation (A → ⊥).
Returns `some A` if the formula is `A.imp .bot`, otherwise `none`.
-/
def asNeg? : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/--
Try to decompose a formula as conjunction (¬(A → ¬B)).
Note: A ∧ B = (A.imp B.neg).neg = (A.imp (B.imp .bot)).imp .bot
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asAnd? : Formula → Option (Formula × Formula)
  | .imp (.imp φ (.imp ψ .bot)) .bot => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as disjunction (¬A → B).
Note: A ∨ B = A.neg.imp B = (A.imp .bot).imp B
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asOr? : Formula → Option (Formula × Formula)
  | .imp (.imp φ .bot) ψ => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as diamond (¬□¬A).
Note: ◇A = A.neg.box.neg = ((A.imp .bot).box).imp .bot
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asDiamond? : Formula → Option Formula
  | .imp (.box (.imp φ .bot)) .bot => some φ
  | _ => none

/--
Try to decompose a formula as some_past (¬H¬A).
Note: PA = A.neg.all_past.neg = ((A.imp .bot).all_past).imp .bot
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomePast? : Formula → Option Formula
  | .imp (.all_past (.imp φ .bot)) .bot => some φ
  | _ => none

/--
Try to decompose a formula as some_future (¬G¬A).
Note: FA = A.neg.all_future.neg = ((A.imp .bot).all_future).imp .bot
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomeFuture? : Formula → Option Formula
  | .imp (.all_future (.imp φ .bot)) .bot => some φ
  | _ => none

/-!
## Rule Application
-/

/--
Check if a specific rule is applicable to a signed formula.
-/
def isApplicable (rule : TableauRule) (sf : SignedFormula) : Bool :=
  match rule, sf.sign, sf.formula with
  -- Propositional rules
  | .andPos, .pos, φ => (asAnd? φ).isSome
  | .andNeg, .neg, φ => (asAnd? φ).isSome
  | .orPos, .pos, φ => (asOr? φ).isSome
  | .orNeg, .neg, φ => (asOr? φ).isSome
  | .impPos, .pos, .imp _ _ => true
  | .impNeg, .neg, .imp _ _ => true
  | .negPos, .pos, φ => (asNeg? φ).isSome
  | .negNeg, .neg, φ => (asNeg? φ).isSome
  -- Modal rules
  | .boxPos, .pos, .box _ => true
  | .boxNeg, .neg, .box _ => true
  | .diamondPos, .pos, φ => (asDiamond? φ).isSome
  | .diamondNeg, .neg, φ => (asDiamond? φ).isSome
  -- Temporal rules
  | .allFuturePos, .pos, .all_future _ => true
  | .allFutureNeg, .neg, .all_future _ => true
  | .allPastPos, .pos, .all_past _ => true
  | .allPastNeg, .neg, .all_past _ => true
  | _, _, _ => false

/--
Apply a tableau rule to a signed formula.

Returns the result of the rule application:
- `linear [...]`: Add these formulas to the branch
- `branching [[...], [...]]`: Split into these branches
- `notApplicable`: Rule doesn't apply
-/
def applyRule (rule : TableauRule) (sf : SignedFormula) : RuleResult :=
  match rule, sf.sign, sf.formula with
  -- T(A ∧ B) → T(A), T(B)
  | .andPos, .pos, φ =>
      match asAnd? φ with
      | some (ψ, χ) => .linear [SignedFormula.pos ψ, SignedFormula.pos χ]
      | none => .notApplicable
  -- F(A ∧ B) → F(A) | F(B)
  | .andNeg, .neg, φ =>
      match asAnd? φ with
      | some (ψ, χ) => .branching [[SignedFormula.neg ψ], [SignedFormula.neg χ]]
      | none => .notApplicable
  -- T(A ∨ B) → T(A) | T(B)
  | .orPos, .pos, φ =>
      match asOr? φ with
      | some (ψ, χ) => .branching [[SignedFormula.pos ψ], [SignedFormula.pos χ]]
      | none => .notApplicable
  -- F(A ∨ B) → F(A), F(B)
  | .orNeg, .neg, φ =>
      match asOr? φ with
      | some (ψ, χ) => .linear [SignedFormula.neg ψ, SignedFormula.neg χ]
      | none => .notApplicable
  -- T(A → B) → F(A) | T(B)
  | .impPos, .pos, .imp ψ χ =>
      .branching [[SignedFormula.neg ψ], [SignedFormula.pos χ]]
  -- F(A → B) → T(A), F(B)
  | .impNeg, .neg, .imp ψ χ =>
      .linear [SignedFormula.pos ψ, SignedFormula.neg χ]
  -- T(¬A) → F(A)
  | .negPos, .pos, φ =>
      match asNeg? φ with
      | some ψ => .linear [SignedFormula.neg ψ]
      | none => .notApplicable
  -- F(¬A) → T(A)
  | .negNeg, .neg, φ =>
      match asNeg? φ with
      | some ψ => .linear [SignedFormula.pos ψ]
      | none => .notApplicable
  -- T(□A) → T(A) (S5: reflexivity gives us truth at current world)
  | .boxPos, .pos, .box ψ =>
      .linear [SignedFormula.pos ψ]
  -- F(□A) → F(A) (S5: introduce a witness world where A is false)
  | .boxNeg, .neg, .box ψ =>
      .linear [SignedFormula.neg ψ]
  -- T(◇A) → T(A) (S5: if possibly A, then A at some accessible world)
  | .diamondPos, .pos, φ =>
      match asDiamond? φ with
      | some ψ => .linear [SignedFormula.pos ψ]
      | none => .notApplicable
  -- F(◇A) → F(A) (S5: if not possibly A, then ¬A everywhere, so F(A))
  | .diamondNeg, .neg, φ =>
      match asDiamond? φ with
      | some ψ => .linear [SignedFormula.neg ψ]
      | none => .notApplicable
  -- T(GA) → T(A) (temporal: if always future A, then A now)
  | .allFuturePos, .pos, .all_future ψ =>
      .linear [SignedFormula.pos ψ]
  -- F(GA) → F(A) (temporal: if not always future A, then ¬A at some future time)
  | .allFutureNeg, .neg, .all_future ψ =>
      .linear [SignedFormula.neg ψ]
  -- T(HA) → T(A) (temporal: if always past A, then A now)
  | .allPastPos, .pos, .all_past ψ =>
      .linear [SignedFormula.pos ψ]
  -- F(HA) → F(A) (temporal: if not always past A, then ¬A at some past time)
  | .allPastNeg, .neg, .all_past ψ =>
      .linear [SignedFormula.neg ψ]
  | _, _, _ => .notApplicable

/-!
## Branch Expansion
-/

/--
All tableau rules in priority order.
Propositional rules are tried first, then modal, then temporal.
-/
def allRules : List TableauRule := [
  .negPos, .negNeg,      -- Negation (simplest)
  .impNeg,               -- F(A → B) non-branching
  .andPos, .orNeg,       -- Non-branching compound
  .boxPos, .boxNeg,      -- Modal
  .diamondPos, .diamondNeg,
  .allFuturePos, .allFutureNeg,  -- Temporal
  .allPastPos, .allPastNeg,
  .impPos,               -- Branching implication
  .andNeg, .orPos        -- Branching compound
]

/--
Find a rule that applies to a signed formula.
Returns the first applicable rule and its result.
-/
def findApplicableRule (sf : SignedFormula) : Option (TableauRule × RuleResult) :=
  allRules.findSome? fun rule =>
    let result := applyRule rule sf
    match result with
    | .notApplicable => none
    | _ => some (rule, result)

/--
Check if a signed formula is fully expanded (no rules apply).
Atoms, bot with appropriate signs, and already-reduced formulas are expanded.
-/
def isExpanded (sf : SignedFormula) : Bool :=
  (findApplicableRule sf).isNone

/--
Find an unexpanded formula in a branch.
Returns the first formula that can still be expanded.
-/
def findUnexpanded (b : Branch) : Option SignedFormula :=
  b.find? (fun sf => ¬isExpanded sf)

/--
Result of a single expansion step on a branch.
-/
inductive ExpansionResult : Type where
  /-- Branch is fully saturated (no more expansions possible). -/
  | saturated
  /-- Single branch extension (non-branching rule applied). -/
  | extended (newBranch : Branch)
  /-- Branch splits into multiple branches (branching rule applied). -/
  | split (branches : List Branch)
  deriving Repr

/--
Perform a single expansion step on a branch.

Finds the first unexpanded formula and applies the appropriate rule.
Returns the result of the expansion.
-/
def expandOnce (b : Branch) : ExpansionResult :=
  match findUnexpanded b with
  | none => .saturated
  | some sf =>
      match findApplicableRule sf with
      | none => .saturated  -- Shouldn't happen if findUnexpanded returned something
      | some (_, result) =>
          match result with
          | .linear formulas =>
              -- Remove the expanded formula and add new ones
              let remaining := b.filter (· != sf)
              .extended (formulas ++ remaining)
          | .branching branches =>
              -- Remove the expanded formula from each branch and add new formulas
              let remaining := b.filter (· != sf)
              .split (branches.map fun newFormulas => newFormulas ++ remaining)
          | .notApplicable => .saturated  -- Shouldn't happen

/--
Count of unexpanded formulas in a branch (termination measure).
-/
def countUnexpanded (b : Branch) : Nat :=
  b.filter (fun sf => ¬isExpanded sf) |>.length

/--
Total unexpanded complexity (alternative termination measure).
-/
def totalUnexpandedComplexity (b : Branch) : Nat :=
  b.filter (fun sf => ¬isExpanded sf)
  |>.foldl (fun acc sf => acc + sf.complexity) 0

end Bimodal.Boneyard.Metalogic.Decidability
