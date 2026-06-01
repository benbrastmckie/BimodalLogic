import Bimodal.Metalogic.Decidability.Saturation
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

namespace Bimodal.Metalogic.Decidability

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
  trueAtoms : List Atom
  /-- Atoms that are false. -/
  falseAtoms : List Atom
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
def extractTrueAtoms (b : Branch) : List Atom :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .atom p => some p
    | _, _ => none

/--
Extract the set of atoms that should be false from a saturated branch.
An atom is false if F(atom) appears in the branch.
-/
def extractFalseAtoms (b : Branch) : List Atom :=
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
  let atomToStr (a : Atom) : String := match a.fresh_index with
    | none => a.base
    | some n => s!"{a.base}_{n}"
  let trueStr := if cm.trueAtoms.isEmpty then "none"
                 else String.intercalate ", " (cm.trueAtoms.map atomToStr)
  let falseStr := if cm.falseAtoms.isEmpty then "none"
                  else String.intercalate ", " (cm.falseAtoms.map atomToStr)
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
    (_fc : FrameClass := .Base) : Option SimpleCountermodel :=
  match tableau with
  | .allClosed _ => none  -- No countermodel, formula is valid
  | .hasOpen openBranch hSaturated _ =>
      some (extractCountermodelSimple φ openBranch hSaturated)

/-!
## Semantic Countermodel

A `SemanticCountermodel` captures the full finite model extracted from a
saturated open branch: world states, time domain, temporal ordering, and
atom valuation. This is the "Layer 1" (branch model) of the two-layer
countermodel approach, defined directly on the branch structure to avoid
universe level issues with the full `TaskFrame`/`WorldHistory` stack.
-/

/--
A semantic countermodel extracted from a saturated open tableau branch.

Contains the finite world set, time set, temporal ordering constraints,
and atom valuation. The valuation is indexed by `(WorldIndex, TimeIndex, Atom)`
triples, matching the labeled tableau's structure.
-/
structure SemanticCountermodel where
  /-- The formula being refuted. -/
  formula : Formula
  /-- The saturated open branch from which this model is extracted. -/
  branch : Branch
  /-- All world indices appearing in the branch. -/
  worlds : List WorldIndex
  /-- All time indices appearing in the branch. -/
  times : List TimeIndex
  /-- Temporal ordering constraints from the tableau expansion. -/
  timeOrdering : TimeOrdering
  /-- Atom valuation: true iff `T(atom p)` at `(w, t)` appears in the branch. -/
  atomValuation : WorldIndex → TimeIndex → Atom → Bool

/-!
### Time Ordering Helpers
-/

/--
Check whether `t1` is strictly before `t2` in the transitive closure of
the time ordering constraints. Uses fuel-bounded reachability.
-/
def isTimeOrderedBefore (ord : TimeOrdering) (t1 t2 : TimeIndex)
    (fuel : Nat := 50) : Bool :=
  match fuel with
  | 0 => false
  | fuel + 1 =>
    -- Direct edge?
    if ord.constraints.any (fun (a, b) => a == t1 && b == t2) then true
    else
      -- Transitive: t1 < t_mid < t2 for some t_mid?
      let successors := ord.futureOf t1
      successors.any fun t_mid => isTimeOrderedBefore ord t_mid t2 fuel
termination_by fuel

/--
Check whether `t1` is strictly after `t2` in the temporal ordering.
-/
def isTimeOrderedAfter (ord : TimeOrdering) (t1 t2 : TimeIndex)
    (fuel : Nat := 50) : Bool :=
  isTimeOrderedBefore ord t2 t1 fuel

/--
Collect all times in the model that are strictly after `t` (transitive closure).
-/
def futureTimes (ord : TimeOrdering) (t : TimeIndex)
    (allTimes : List TimeIndex) : List TimeIndex :=
  allTimes.filter fun t' => isTimeOrderedBefore ord t t'

/--
Collect all times in the model that are strictly before `t` (transitive closure).
-/
def pastTimes (ord : TimeOrdering) (t : TimeIndex)
    (allTimes : List TimeIndex) : List TimeIndex :=
  allTimes.filter fun t' => isTimeOrderedBefore ord t' t

/--
Collect all times strictly between `t1` and `t2` (exclusive on both ends).
A time `t` is between `t1` and `t2` if `t1 < t` and `t < t2`.
-/
def timesBetween (ord : TimeOrdering) (t1 t2 : TimeIndex)
    (allTimes : List TimeIndex) : List TimeIndex :=
  allTimes.filter fun t =>
    isTimeOrderedBefore ord t1 t && isTimeOrderedBefore ord t t2

/-!
### Branch Truth Evaluation

`branchTruth` defines truth of a formula at a `(world, time)` pair in the
semantic countermodel. This is defined by structural recursion on the formula.

- `atom p`: true iff `atomValuation w t p = true`
- `bot`: always false
- `imp φ ψ`: `φ` true implies `ψ` true (material conditional)
- `box φ`: `φ` true at all worlds in the model (S5 universal accessibility)
- `untl event guard`: there exists a future time `t'` where `event` is true,
  and `guard` is true at all times strictly between `t` and `t'`
- `snce event guard`: there exists a past time `t'` where `event` is true,
  and `guard` is true at all times strictly between `t'` and `t`
-/

/--
Evaluate truth of a formula at a `(world, time)` pair in the semantic
countermodel. Defined by structural recursion on the formula.
-/
def branchTruth (cm : SemanticCountermodel) (w : WorldIndex) (t : TimeIndex)
    : Formula → Prop
  | .atom p => cm.atomValuation w t p = true
  | .bot => False
  | .imp φ ψ => branchTruth cm w t φ → branchTruth cm w t ψ
  | .box φ => ∀ w' ∈ cm.worlds, branchTruth cm w' t φ
  | .untl event guard =>
      ∃ t' ∈ cm.times,
        isTimeOrderedBefore cm.timeOrdering t t' ∧
        branchTruth cm w t' event ∧
        ∀ t'' ∈ timesBetween cm.timeOrdering t t' cm.times,
          branchTruth cm w t'' guard
  | .snce event guard =>
      ∃ t' ∈ cm.times,
        isTimeOrderedBefore cm.timeOrdering t' t ∧
        branchTruth cm w t' event ∧
        ∀ t'' ∈ timesBetween cm.timeOrdering t' t cm.times,
          branchTruth cm w t'' guard

/--
Signed truth in the semantic countermodel: positive formulas must be true,
negative formulas must be false.
-/
def signedTruthInModel (cm : SemanticCountermodel) (sf : SignedFormula) : Prop :=
  match sf.sign with
  | .pos => branchTruth cm sf.label.world sf.label.time sf.formula
  | .neg => ¬branchTruth cm sf.label.world sf.label.time sf.formula

/-!
### Semantic Countermodel Extraction
-/

/--
Build the atom valuation from a branch: an atom `p` is true at `(w, t)` iff
`T(atom p)` at label `(w, t)` appears in the branch.
-/
def buildAtomValuation (b : Branch) : WorldIndex → TimeIndex → Atom → Bool :=
  fun w t p => b.hasPosAt (.atom p) ⟨w, t⟩

/--
Extract a `SemanticCountermodel` from a saturated open branch.

The model's worlds and times are exactly those appearing in the branch labels.
The atom valuation is determined by positive atom occurrences.
The time ordering comes from the tableau expansion's `TimeOrdering`.
-/
def extractSemanticCountermodel (φ : Formula) (b : Branch)
    (ord : TimeOrdering) : SemanticCountermodel :=
  { formula := φ
  , branch := b
  , worlds := b.knownWorlds
  , times := b.knownTimes
  , timeOrdering := ord
  , atomValuation := buildAtomValuation b
  }

/-!
## Branch Truth Lemma
-/

/--
The branch truth lemma: for a saturated open branch, every signed formula
in the branch is semantically true in the extracted countermodel.

- If `T(φ)` is in the branch, then `φ` is true at the formula's label in
  the countermodel.
- If `F(φ)` is in the branch, then `φ` is false at the formula's label in
  the countermodel.

This is the key correctness theorem for countermodel extraction: the model
we build from the branch genuinely satisfies the branch's assertions.
-/
theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
    (fc : FrameClass := .Base) (hOpen : findClosure b fc = none)
    (cm : SemanticCountermodel)
    (hCm : cm = extractSemanticCountermodel cm.formula b cm.timeOrdering) :
    ∀ sf ∈ b, signedTruthInModel cm sf := by
  sorry

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
def findCountermodel (φ : Formula) (fuel : Nat := 1000)
    (fc : FrameClass := .Base) : CountermodelResult φ :=
  match buildTableau φ fuel fc with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch hSat _) =>
      .found (extractCountermodelSimple φ openBranch hSat)

end Bimodal.Metalogic.Decidability
