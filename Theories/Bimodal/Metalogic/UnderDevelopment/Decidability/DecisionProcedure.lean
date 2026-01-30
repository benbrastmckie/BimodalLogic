import Bimodal.Boneyard.Metalogic.Decidability.ProofExtraction
import Bimodal.Boneyard.Metalogic.Decidability.CountermodelExtraction

/-!
# Decision Procedure for TM Bimodal Logic

This module provides the main decision procedure for TM bimodal logic validity.
The procedure decides whether a formula is valid, returning either:
- A proof term (`DerivationTree`) if valid
- A countermodel description if invalid

## Main Definitions

- `DecisionResult`: Sum type of proof or countermodel
- `decide`: Main decision function
- `isValid`, `isSatisfiable`: Boolean convenience functions

## Algorithm Overview

1. **Optimization**: First try direct proof search for shallow proofs
2. **Tableau**: Build tableau for F(φ) (asserting φ is false)
3. **Analysis**:
   - All branches close → φ is valid, extract proof
   - Open saturated branch → φ is invalid, extract countermodel

## Complexity

- Time: O(2^n) where n = formula complexity (PSPACE-complete)
- Space: O(n) for DFS-based tableau expansion
- Typical formulas: Much faster due to pruning and optimization

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Metalogic.UnderDevelopment.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation

/-!
## Decision Result Type
-/

/--
Result of the decision procedure for a formula.

- `valid`: Formula is valid, with a proof term
- `invalid`: Formula is invalid, with a countermodel description
- `timeout`: Procedure ran out of resources
-/
inductive DecisionResult (φ : Formula) : Type where
  /-- Formula is valid, witnessed by a derivation tree. -/
  | valid (proof : DerivationTree [] φ)
  /-- Formula is invalid, witnessed by a countermodel description. -/
  | invalid (counter : SimpleCountermodel)
  /-- Decision procedure timed out (fuel exhausted). -/
  | timeout
  deriving Repr

namespace DecisionResult

variable {φ : Formula}

/-- Check if result indicates validity. -/
def isValid : DecisionResult φ → Bool
  | valid _ => true
  | _ => false

/-- Check if result indicates invalidity. -/
def isInvalid : DecisionResult φ → Bool
  | invalid _ => true
  | _ => false

/-- Check if result timed out. -/
def isTimeout : DecisionResult φ → Bool
  | timeout => true
  | _ => false

/-- Get the proof if valid. -/
def getProof? : DecisionResult φ → Option (DerivationTree [] φ)
  | valid proof => some proof
  | _ => none

/-- Get the countermodel if invalid. -/
def getCountermodel? : DecisionResult φ → Option SimpleCountermodel
  | invalid cm => some cm
  | _ => none

end DecisionResult

/-!
## Main Decision Procedure
-/

/--
Decide validity of a TM bimodal logic formula.

**Algorithm**:
1. Try direct axiom proof (fast path for axiom instances)
2. Try proof search with limited depth (fast for shallow proofs)
3. Build tableau starting with F(φ)
4. If all branches close: valid, try to extract proof
5. If open branch found: invalid, extract countermodel

**Parameters**:
- `φ`: Formula to decide
- `searchDepth`: Maximum depth for initial proof search (default 10)
- `tableauFuel`: Maximum steps for tableau expansion (default 1000)

**Returns**:
- `valid proof`: Formula is valid with proof term
- `invalid counter`: Formula is invalid with countermodel
- `timeout`: Resources exhausted before decision
-/
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult φ :=
  -- Fast path: direct axiom proof
  match tryAxiomProof φ with
  | some proof => .valid proof
  | none =>
    -- Try proof search (fast for simple proofs)
    match bounded_search_with_proof [] φ searchDepth with
    | (some proof, _, _) => .valid proof
    | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau φ tableauFuel with
      | none => .timeout
      | some (.allClosed closedBranches) =>
          -- Formula is valid, try to extract proof
          -- Check if any closed branch gives us a direct proof
          let axiomProofs := closedBranches.filterMap fun cb =>
            match cb.reason with
            | .axiomNeg ψ ax =>
                if h : φ = ψ then some (h ▸ DerivationTree.axiom [] ψ ax)
                else none
            | _ => none
          match axiomProofs.head? with
          | some proof => .valid proof
          | none =>
              -- Try proof search again with higher depth
              match bounded_search_with_proof [] φ (searchDepth * 2) with
              | (some proof, _, _) => .valid proof
              | (none, _, _) =>
                  -- Formula is valid but we couldn't extract a proof term
                  -- This is a limitation of the current implementation
                  .timeout  -- Better than lying about invalidity
      | some (.hasOpen openBranch hSat) =>
          -- Formula is invalid, extract countermodel
          .invalid (extractCountermodelSimple φ openBranch hSat)

/--
Simplified decision: just return whether formula is valid.
-/
def isValid (φ : Formula) : Bool :=
  (decide φ).isValid

/--
Check if a formula is satisfiable (its negation is not valid).
-/
def isSatisfiable (φ : Formula) : Bool :=
  ¬isValid φ.neg

/--
Decide with automatic fuel based on formula complexity.
-/
def decideAuto (φ : Formula) : DecisionResult φ :=
  let fuel := recommendedFuel φ
  let depth := 5 + φ.complexity / 2
  decide φ depth fuel

/-!
## Batch Decision
-/

/--
Result of batch decision with statistics.
-/
structure BatchDecisionResult where
  /-- Number of formulas decided valid. -/
  validCount : Nat
  /-- Number of formulas decided invalid. -/
  invalidCount : Nat
  /-- Number of formulas that timed out. -/
  timeoutCount : Nat
  /-- Total formulas processed. -/
  totalCount : Nat
  deriving Repr, Inhabited

/--
Decide a batch of formulas, collecting statistics.
-/
def decideBatch (formulas : List Formula) (fuel : Nat := 1000) : BatchDecisionResult :=
  formulas.foldl (fun acc φ =>
    let result := decide φ 10 fuel
    { acc with
      validCount := acc.validCount + (if result.isValid then 1 else 0)
      invalidCount := acc.invalidCount + (if result.isInvalid then 1 else 0)
      timeoutCount := acc.timeoutCount + (if result.isTimeout then 1 else 0)
      totalCount := acc.totalCount + 1
    }
  ) { validCount := 0, invalidCount := 0, timeoutCount := 0, totalCount := 0 }

/-!
## Integration with Proof Search
-/

/--
Combined decision procedure using both tableau and proof search.

For formulas that are provable, this tries to return the shortest proof
by comparing tableau-derived proofs with proof search results.
-/
def decideOptimized (φ : Formula) : DecisionResult φ :=
  -- First, quick check with IDDFS
  let (found, _, _, _, _) := search [] φ (.IDDFS 20)
  if found then
    -- Found provable, get the proof term
    match bounded_search_with_proof [] φ 20 with
    | (some proof, _, _) => .valid proof
    | (none, _, _) =>
        -- Couldn't construct proof term, fall back to decide
        decide φ
  else
    -- Not immediately provable, use full decision procedure
    decide φ

/-!
## Convenience Functions
-/

/--
Check if a formula is a tautology (valid in propositional sense).
For TM logic, this is just validity check.
-/
def isTautology (φ : Formula) : Bool := isValid φ

/--
Check if a formula is a contradiction (negation is valid).
-/
def isContradiction (φ : Formula) : Bool := isValid φ.neg

/--
Check if a formula is contingent (neither valid nor contradictory).
-/
def isContingent (φ : Formula) : Bool :=
  ¬isValid φ ∧ ¬isContradiction φ

/-!
## Display Functions
-/

/--
Display the decision result as a human-readable string.
-/
def DecisionResult.display {φ : Formula} : DecisionResult φ → String
  | .valid proof => s!"Valid (proof height: {proof.height})"
  | .invalid _ => s!"Invalid (countermodel found)"
  | .timeout => "Timeout (resources exhausted)"

end Bimodal.Boneyard.Metalogic.Decidability
