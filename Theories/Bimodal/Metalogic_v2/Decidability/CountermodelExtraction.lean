import Bimodal.Metalogic_v2.Decidability.Saturation
import Bimodal.Semantics

/-!
# Countermodel Extraction from Open Tableau Branches (Metalogic_v2)

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

This is a port from `Bimodal.Metalogic.Decidability.CountermodelExtraction` to
the Metalogic_v2 architecture.

For simplicity, we focus on extracting simple countermodel descriptions
(which atoms are true/false) rather than full semantic structures.
This avoids universe level issues with the full semantic machinery.

## Future Enhancement

The SemanticCanonicalModel from Metalogic_v2.Representation could be used
to provide a more structured countermodel with proper modal/temporal semantics.
This would connect the tableau countermodel to the FMP witness construction.

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace Bimodal.Metalogic_v2.Decidability

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
## Branch Truth Lemma
-/

/--
Define a valuation from a saturated open branch.
An atom p is true iff T(p) is in the branch.
-/
def extractValuation (b : Branch) (p : String) : Bool :=
  b.any fun sf =>
    match sf.sign, sf.formula with
    | .pos, .atom q => p == q
    | _, _ => false

/--
Check if a formula is true under the extracted valuation.
This is a simple propositional evaluation without modal/temporal operators.
-/
def evalFormula (b : Branch) : Formula → Bool
  | .atom p => extractValuation b p
  | .bot => false
  | .imp φ ψ => !evalFormula b φ || evalFormula b ψ
  | .box φ => evalFormula b φ  -- Simplified: modal treated as identity in simple model
  | .all_future φ => evalFormula b φ  -- Simplified: temporal treated as identity
  | .all_past φ => evalFormula b φ

/--
Openness implies consistency: a branch is open if it has no closure.
This means no atom p has both T(p) and F(p) in the branch.
-/
theorem open_branch_consistent (b : Branch) (hOpen : findClosure b = none) :
    ∀ p, ¬(SignedFormula.pos (.atom p) ∈ b ∧ SignedFormula.neg (.atom p) ∈ b) := by
  intro p ⟨hpos, hneg⟩
  -- findClosure finds contradictions like T(p), F(p)
  -- If both T(p) and F(p) are in b, findClosure would return some reason
  -- This contradicts hOpen : findClosure b = none
  sorry  -- Technical: show findClosure detects atom contradictions

/--
Saturation implies all non-atomic formulas are expanded.
If T(φ→ψ) is in a saturated branch, then either F(φ) or T(ψ) is in the branch.
-/
theorem saturated_imp_expanded (b : Branch) (hSat : findUnexpanded b = none)
    (φ ψ : Formula) :
    SignedFormula.pos (.imp φ ψ) ∈ b → SignedFormula.neg φ ∈ b ∨ SignedFormula.pos ψ ∈ b := by
  intro h_imp_in
  -- A saturated branch has no unexpanded formulas
  -- T(φ→ψ) is expanded by impPos rule into branches F(φ) | T(ψ)
  -- Since the branch is saturated, the expansion has happened
  sorry  -- Technical: trace through saturation to show expansion

/--
The branch truth lemma states that a saturated open branch describes
a satisfying assignment. This is the key lemma for countermodel correctness.

The key properties are:
1. If T(p) ∈ b for atom p, then p is true in the extracted valuation
2. If F(p) ∈ b for atom p, then p is false in the extracted valuation
3. Compound formulas are consistent due to saturation

**Proof outline**:
- Atoms: direct from extraction (T(p) ∈ b implies evalFormula b p = true)
- Bot: F(⊥) can be in branch, T(⊥) cannot (would close branch)
- Implication: saturation ensures correct expansion
- Modal/Temporal: simplified to identity in this simple model
-/
theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b = none) :
    ∀ sf ∈ b, (sf.sign = .pos → evalFormula b sf.formula = true) ∧
              (sf.sign = .neg → evalFormula b sf.formula = false) := by
  intro sf hsf_in
  constructor
  · -- Positive case: T(φ) ∈ b implies evalFormula b φ = true
    intro hpos
    match hf : sf.formula with
    | .atom p =>
      -- T(p) ∈ b implies extractValuation b p = true
      simp only [evalFormula, extractValuation, hf]
      simp only [List.any_eq_true]
      use sf
      constructor
      · exact hsf_in
      · simp only [hpos, hf, beq_self_eq_true]
    | .bot =>
      -- T(⊥) cannot be in an open branch (would close it)
      exfalso
      -- findClosure should find T(⊥) and return .botPos
      sorry  -- Technical: show T(⊥) closes branch
    | .imp φ ψ =>
      -- T(φ→ψ) in saturated branch means F(φ) ∨ T(ψ) by expansion
      simp only [evalFormula]
      -- For the simple propositional model, we need !eval φ || eval ψ
      -- From saturation, the impPos rule was applied
      sorry  -- Technical: case analysis on saturation expansion
    | .box φ =>
      -- Simplified: treat box as identity
      simp only [evalFormula]
      sorry  -- Technical: show T(□φ) implies φ true
    | .all_future φ =>
      simp only [evalFormula]
      sorry  -- Technical: temporal case
    | .all_past φ =>
      simp only [evalFormula]
      sorry  -- Technical: temporal case
  · -- Negative case: F(φ) ∈ b implies evalFormula b φ = false
    intro hneg
    match hf : sf.formula with
    | .atom p =>
      -- F(p) ∈ b and p is false iff T(p) ∉ b (by openness/consistency)
      -- Technical: use open_branch_consistent to derive contradiction
      simp only [evalFormula, extractValuation]
      simp only [Bool.eq_false_iff, ne_eq]
      intro hany
      -- If List.any finds a witness, we can derive contradiction from consistency
      have hconsist := open_branch_consistent b hOpen p
      -- We have F(p) ∈ b (from sf, hneg, hf)
      -- If List.any is true, there exists T(p) in b, contradicting consistency
      sorry  -- Technical: extract witness from hany and derive contradiction
    | .bot =>
      -- F(⊥) in branch means ⊥ is false, which is correct
      simp only [evalFormula]
    | .imp φ ψ =>
      -- F(φ→ψ) means φ is true and ψ is false
      simp only [evalFormula]
      -- Saturation ensures T(φ) and F(ψ) are both in branch
      sorry  -- Technical: impNeg rule expansion
    | .box φ =>
      simp only [evalFormula]
      sorry  -- Technical: modal case
    | .all_future φ =>
      simp only [evalFormula]
      sorry  -- Technical: temporal case
    | .all_past φ =>
      simp only [evalFormula]
      sorry  -- Technical: temporal case

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

/--
Try to find a countermodel using FMP-based fuel.
-/
def findCountermodelWithFMPFuel (φ : Formula) : CountermodelResult φ :=
  findCountermodel φ (fmpBasedFuel φ)

end Bimodal.Metalogic_v2.Decidability
