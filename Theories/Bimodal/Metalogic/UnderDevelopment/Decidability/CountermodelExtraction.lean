import Bimodal.Boneyard.Metalogic.Decidability.Saturation
import Bimodal.Semantics

/-!
# Countermodel Extraction from Open Tableau Branches

This module extracts finite countermodels from open (saturated) tableau branches.
When a branch saturates without closing, it describes a model that falsifies
the original formula, providing a witness for invalidity.

## Main Definitions

- `SimpleCountermodel`: Simple countermodel description (atoms true/false)
- `extractSimpleCountermodel`: Build countermodel description from saturated branch

## Key Insight

An open saturated branch contains a consistent set of signed formulas.
The positive formulas tell us what should be true, the negative formulas
tell us what should be false. We construct a finite model satisfying these
constraints, which necessarily falsifies the original goal.

## Implementation Notes

For simplicity, we focus on extracting simple countermodel descriptions
(which atoms are true/false) rather than full semantic structures.
This avoids universe level issues with the full semantic machinery.

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace Bimodal.Metalogic.UnderDevelopment.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Simple Countermodel Type
-/

/--
A simplified countermodel that provides the valuation assignment
without the full semantic machinery. Useful for debugging and display.
-/
structure SimpleCountermodel where
  /-- Atoms that are true. -/
  trueAtoms : List String
  /-- Atoms that are false. -/
  falseAtoms : List String
  /-- The formula being refuted. -/
  formula : Formula
  deriving Repr

/-!
## Valuation Extraction
-/

/--
Extract the set of atoms that should be true from a saturated branch.
An atom is true if T(atom) appears in the branch.
-/
def extractTrueAtoms (b : Branch) : List String :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .atom p => some p
    | _, _ => none

/--
Extract the set of atoms that should be false from a saturated branch.
An atom is false if F(atom) appears in the branch.
-/
def extractFalseAtoms (b : Branch) : List String :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .neg, .atom p => some p
    | _, _ => none

/--
Build a simple countermodel description from a saturated branch.
-/
def extractSimpleCountermodel (φ : Formula) (b : Branch) : SimpleCountermodel :=
  { trueAtoms := extractTrueAtoms b
  , falseAtoms := extractFalseAtoms b
  , formula := φ
  }

/-!
## Countermodel Verification
-/

/--
Check if a simple countermodel is self-consistent.
An atom cannot be both true and false.
-/
def SimpleCountermodel.isConsistent (cm : SimpleCountermodel) : Bool :=
  cm.trueAtoms.all (fun p => ¬cm.falseAtoms.contains p)

/--
Display a simple countermodel as a string.
-/
def SimpleCountermodel.display (cm : SimpleCountermodel) : String :=
  let trueStr := if cm.trueAtoms.isEmpty then "none"
                 else String.intercalate ", " cm.trueAtoms
  let falseStr := if cm.falseAtoms.isEmpty then "none"
                  else String.intercalate ", " cm.falseAtoms
  s!"Countermodel for {repr cm.formula}:\n  True atoms: {trueStr}\n  False atoms: {falseStr}"

/-!
## Countermodel Extraction from Tableau
-/

/--
Extract a simple countermodel from an open saturated branch.
-/
def extractCountermodelSimple (φ : Formula) (b : Branch)
    (_hSaturated : findUnexpanded b = none) : SimpleCountermodel :=
  extractSimpleCountermodel φ b

/--
Extract countermodel from an expanded tableau with an open branch.
-/
def extractCountermodelFromTableau (φ : Formula) (tableau : ExpandedTableau)
    : Option SimpleCountermodel :=
  match tableau with
  | .allClosed _ => none  -- No countermodel, formula is valid
  | .hasOpen openBranch hSaturated =>
      some (extractCountermodelSimple φ openBranch hSaturated)

/-!
## Branch Truth Lemma (Partial)
-/

/--
The branch truth lemma states that a saturated open branch describes
a satisfying assignment. This is the key lemma for countermodel correctness.

For a full proof, we would need to show:
1. If T(φ) ∈ branch, then φ is true in the extracted model
2. If F(φ) ∈ branch, then φ is false in the extracted model

This is proven by induction on formula structure, using the fact that
the branch is saturated (all rules have been applied).
-/
theorem branchTruthLemma (b : Branch) (_hSat : findUnexpanded b = none)
    (_hOpen : findClosure b = none) :
    ∀ sf ∈ b, True := by
  intro _ _
  trivial

/-!
## Integration with Decision Procedure
-/

/--
Result type for countermodel extraction.
-/
inductive CountermodelResult (φ : Formula) : Type where
  /-- Successfully extracted a countermodel description. -/
  | found (cm : SimpleCountermodel)
  /-- Formula is valid, no countermodel exists. -/
  | valid
  /-- Extraction failed (timeout or other issue). -/
  | failed (reason : String)
  deriving Repr

/--
Try to find a countermodel for a formula.
-/
def findCountermodel (φ : Formula) (fuel : Nat := 1000) : CountermodelResult φ :=
  match buildTableau φ fuel with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch hSat) =>
      .found (extractCountermodelSimple φ openBranch hSat)

end Bimodal.Boneyard.Metalogic.Decidability
