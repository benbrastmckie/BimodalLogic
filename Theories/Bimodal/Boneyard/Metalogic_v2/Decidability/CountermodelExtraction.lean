import Bimodal.Boneyard.Metalogic_v2.Decidability.Saturation
import Bimodal.Boneyard.Metalogic_v2.Decidability.BranchTaskModel
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
open Bimodal.Semantics

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

-- Note: open_branch_consistent is now imported from BranchClosure.lean via BranchTaskModel

/--
T(φ→ψ) is not expanded because the impPos rule applies.

The `impPos` rule applies to any `SignedFormula.pos (.imp φ ψ)` and returns
`.branching [[.neg φ], [.pos ψ]]`, so `isExpanded` returns `false`.
-/
lemma isExpanded_pos_imp_false (φ ψ : Formula) :
    isExpanded (SignedFormula.pos (.imp φ ψ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- T(□φ) is not expanded because the boxPos rule applies. -/
lemma isExpanded_pos_box_false (φ : Formula) :
    isExpanded (SignedFormula.pos (.box φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- T(Gφ) is not expanded because the allFuturePos rule applies. -/
lemma isExpanded_pos_all_future_false (φ : Formula) :
    isExpanded (SignedFormula.pos (.all_future φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- T(Hφ) is not expanded because the allPastPos rule applies. -/
lemma isExpanded_pos_all_past_false (φ : Formula) :
    isExpanded (SignedFormula.pos (.all_past φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- F(φ→ψ) is not expanded because the impNeg rule applies. -/
lemma isExpanded_neg_imp_false (φ ψ : Formula) :
    isExpanded (SignedFormula.neg (.imp φ ψ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- F(□φ) is not expanded because the boxNeg rule applies. -/
lemma isExpanded_neg_box_false (φ : Formula) :
    isExpanded (SignedFormula.neg (.box φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- F(Gφ) is not expanded because the allFutureNeg rule applies. -/
lemma isExpanded_neg_all_future_false (φ : Formula) :
    isExpanded (SignedFormula.neg (.all_future φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- F(Hφ) is not expanded because the allPastNeg rule applies. -/
lemma isExpanded_neg_all_past_false (φ : Formula) :
    isExpanded (SignedFormula.neg (.all_past φ)) = false := by
  simp only [isExpanded, findApplicableRule, allRules, List.findSome?]
  simp only [applyRule, asNeg?, asAnd?, asOr?, asDiamond?]
  repeat (first | rfl | (split; try rfl))

/-- Helper: Derive False from saturation and a formula that's not expanded. -/
lemma saturation_contradiction (b : Branch) (hSat : findUnexpanded b = none)
    (sf : SignedFormula) (hsf_in : sf ∈ b) (h_not_expanded : isExpanded sf = false) : False := by
  simp only [findUnexpanded, List.find?_eq_none] at hSat
  have h_expanded := hSat sf hsf_in
  simp only [decide_eq_true_eq, not_not] at h_expanded
  rw [h_not_expanded] at h_expanded
  cases h_expanded

/--
Saturation implies all non-atomic formulas are expanded.
If T(φ→ψ) is in a saturated branch, then either F(φ) or T(ψ) is in the branch.

**Note**: This theorem is vacuously true. A saturated branch has `findUnexpanded = none`,
meaning all formulas have `isExpanded = true`. But `T(φ→ψ)` has `isExpanded = false`
(since the `impPos` rule applies). So `T(φ→ψ)` cannot be in a saturated branch.
-/
theorem saturated_imp_expanded (b : Branch) (hSat : findUnexpanded b = none)
    (φ ψ : Formula) :
    SignedFormula.pos (.imp φ ψ) ∈ b → SignedFormula.neg φ ∈ b ∨ SignedFormula.pos ψ ∈ b := by
  intro h_imp_in
  -- We prove by contradiction: T(φ→ψ) cannot be in a saturated branch.
  exfalso
  -- From saturation: all sf ∈ b have isExpanded sf = true
  simp only [findUnexpanded, List.find?_eq_none] at hSat
  have h_expanded := hSat (SignedFormula.pos (.imp φ ψ)) h_imp_in
  -- h_expanded : ¬(¬isExpanded (...) = true) = true, i.e., isExpanded (...) = true
  simp only [decide_eq_true_eq, not_not] at h_expanded
  -- But isExpanded (SignedFormula.pos (.imp φ ψ)) = false
  rw [isExpanded_pos_imp_false] at h_expanded
  -- Now h_expanded : false = true, which is a contradiction
  cases h_expanded

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
      -- findClosure b = none means checkBotPos b = none, i.e., hasBotPos b = false
      simp only [findClosure] at hOpen
      rw [Option.orElse_eq_none, Option.orElse_eq_none] at hOpen
      obtain ⟨hBotPos, _, _⟩ := hOpen
      simp only [checkBotPos] at hBotPos
      -- hBotPos : (if b.hasBotPos then some .botPos else none) = none
      -- This means b.hasBotPos = false
      split at hBotPos
      · -- b.hasBotPos = true branch, gives some .botPos = none, contradiction
        cases hBotPos
      · -- b.hasBotPos = false branch
        rename_i h_not_bot
        -- But we have sf ∈ b with sf.sign = pos and sf.formula = bot
        -- So SignedFormula.pos .bot is in b
        simp only [Branch.hasBotPos, Branch.contains, List.any_eq_true] at h_not_bot
        push_neg at h_not_bot
        -- We need to show sf is SignedFormula.pos .bot
        -- sf is a structure, so we prove equality via cases
        rcases sf with ⟨sign, formula⟩
        simp only [SignedFormula.pos] at *
        subst hpos hf
        have := h_not_bot ⟨.pos, .bot⟩ hsf_in
        exact this (by native_decide)
    | .imp φ ψ =>
      -- T(φ→ψ) cannot be in a saturated branch (would have been expanded)
      exfalso
      have h_not_exp : isExpanded (SignedFormula.pos (.imp φ ψ)) = false := isExpanded_pos_imp_false φ ψ
      have hsf_eq : sf = SignedFormula.pos (.imp φ ψ) := by
        cases sf; simp only [SignedFormula.pos] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .box φ =>
      -- T(□φ) cannot be in a saturated branch (would have been expanded)
      exfalso
      have h_not_exp : isExpanded (SignedFormula.pos (.box φ)) = false := isExpanded_pos_box_false φ
      have hsf_eq : sf = SignedFormula.pos (.box φ) := by
        cases sf; simp only [SignedFormula.pos] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .all_future φ =>
      -- T(Gφ) cannot be in a saturated branch
      exfalso
      have h_not_exp : isExpanded (SignedFormula.pos (.all_future φ)) = false := isExpanded_pos_all_future_false φ
      have hsf_eq : sf = SignedFormula.pos (.all_future φ) := by
        cases sf; simp only [SignedFormula.pos] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .all_past φ =>
      -- T(Hφ) cannot be in a saturated branch
      exfalso
      have h_not_exp : isExpanded (SignedFormula.pos (.all_past φ)) = false := isExpanded_pos_all_past_false φ
      have hsf_eq : sf = SignedFormula.pos (.all_past φ) := by
        cases sf; simp only [SignedFormula.pos] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
  · -- Negative case: F(φ) ∈ b implies evalFormula b φ = false
    intro hneg
    match hf : sf.formula with
    | .atom p =>
      -- F(p) ∈ b and p is false iff T(p) ∉ b (by openness/consistency)
      simp only [evalFormula, extractValuation]
      simp only [Bool.eq_false_iff, ne_eq, List.any_eq_true, not_exists, not_and]
      intro sf' hsf'_in hmatch
      -- hmatch says sf' matches (pos, atom p) pattern
      -- We need to derive contradiction using open_branch_consistent
      have hconsist := open_branch_consistent b hOpen p
      -- We have F(p) ∈ b and we're assuming something like T(p) ∈ b
      -- sf' ∈ b and its (sign, formula) matches pattern for T(p)
      -- Extract that sf' = SignedFormula.pos (.atom p)
      split at hmatch
      · -- sf'.sign = .pos and sf'.formula = .atom q where p == q = true
        rename_i q heq_sign heq_formula
        simp only [beq_iff_eq] at hmatch
        subst hmatch
        -- So sf' = SignedFormula.pos (.atom p)
        have hsf'_eq : sf' = SignedFormula.pos (.atom p) := by
          cases sf'; simp only [SignedFormula.pos] at *; simp_all
        rw [hsf'_eq] at hsf'_in
        -- We have T(p) ∈ b and F(p) ∈ b (since sf = F(p))
        have hsf_eq : sf = SignedFormula.neg (.atom p) := by
          cases sf; simp only [SignedFormula.neg] at *; simp_all
        rw [hsf_eq] at hsf_in
        exact hconsist ⟨hsf'_in, hsf_in⟩
      · -- Other cases return false, so hmatch = true means contradiction
        rename_i heq
        cases hmatch
    | .bot =>
      -- F(⊥) in branch means ⊥ is false, which is correct
      simp only [evalFormula]
    | .imp φ ψ =>
      -- F(φ→ψ) cannot be in a saturated branch (would have been expanded)
      exfalso
      have h_not_exp : isExpanded (SignedFormula.neg (.imp φ ψ)) = false := isExpanded_neg_imp_false φ ψ
      have hsf_eq : sf = SignedFormula.neg (.imp φ ψ) := by
        cases sf; simp only [SignedFormula.neg] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .box φ =>
      -- F(□φ) cannot be in a saturated branch
      exfalso
      have h_not_exp : isExpanded (SignedFormula.neg (.box φ)) = false := isExpanded_neg_box_false φ
      have hsf_eq : sf = SignedFormula.neg (.box φ) := by
        cases sf; simp only [SignedFormula.neg] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .all_future φ =>
      -- F(Gφ) cannot be in a saturated branch
      exfalso
      have h_not_exp : isExpanded (SignedFormula.neg (.all_future φ)) = false := isExpanded_neg_all_future_false φ
      have hsf_eq : sf = SignedFormula.neg (.all_future φ) := by
        cases sf; simp only [SignedFormula.neg] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp
    | .all_past φ =>
      -- F(Hφ) cannot be in a saturated branch
      exfalso
      have h_not_exp : isExpanded (SignedFormula.neg (.all_past φ)) = false := isExpanded_neg_all_past_false φ
      have hsf_eq : sf = SignedFormula.neg (.all_past φ) := by
        cases sf; simp only [SignedFormula.neg] at *; simp_all
      rw [hsf_eq] at hsf_in
      exact saturation_contradiction b hSat _ hsf_in h_not_exp

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

/-!
## TaskModel-Based Countermodel Extraction

The following provides proper task-semantic countermodel extraction,
replacing the simplified evalFormula which treats modal/temporal as identity.
-/

/--
A countermodel with proper task frame semantics.

This provides the full semantic structure needed for modal/temporal operators:
- TaskFrame with nullity and compositionality
- TaskModel with valuation
- World history for evaluation
- Initial time point

The types are fixed to use BranchTaskFrame to avoid universe level issues.
-/
structure TaskModelCountermodel where
  /-- The formula being refuted. -/
  formula : Formula
  /-- The task model (valuation over BranchTaskFrame). -/
  model : TaskModel BranchTaskFrame
  /-- The world history for evaluation. -/
  history : WorldHistory BranchTaskFrame
  /-- The initial time point. -/
  time : Int
  /-- The initial world state (from the branch). -/
  worldState : BranchWorldState

/--
Extract a TaskModel-based countermodel from a saturated open branch.

This provides semantically correct countermodel extraction where:
- Box quantifies over ALL world histories at a given time
- G/H operators quantify over ALL times in the duration group
-/
def extractTaskModelCountermodel (φ : Formula) (b : Branch)
    (_hSat : findUnexpanded b = none) (_hOpen : findClosure b = none) :
    TaskModelCountermodel :=
  { formula := φ
  , model := extractBranchTaskModel b
  , history := extractBranchWorldHistory b
  , time := 0
  , worldState := extractBranchWorldState b
  }

/--
Display a TaskModel countermodel.
-/
noncomputable def TaskModelCountermodel.display (cm : TaskModelCountermodel) : String :=
  let atoms := cm.worldState.atoms.toList
  let atomStr := if atoms.isEmpty then "none" else String.intercalate ", " atoms
  s!"TaskModel Countermodel for {repr cm.formula}:\n  World state atoms: {atomStr}\n  Time: {cm.time}"

/--
Result type for countermodel extraction with TaskModel variant.
-/
inductive CountermodelResultEx (φ : Formula) where
  /-- Simple countermodel (atom valuation only). -/
  | simple (cm : SimpleCountermodel)
  /-- TaskModel countermodel (full modal/temporal semantics). -/
  | taskModel (cm : TaskModelCountermodel)
  /-- Formula is valid, no countermodel exists. -/
  | valid
  /-- Extraction failed. -/
  | failed (reason : String)

/--
Find countermodel with extended result type.
Returns TaskModel countermodel for proper modal/temporal semantics.
-/
def findCountermodelEx (φ : Formula) (fuel : Nat := 1000) : CountermodelResultEx φ :=
  match buildTableau φ fuel with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch hSat) =>
      match hOpen : findClosure openBranch with
      | some _ => .failed "Branch has closure (internal error)"
      | none =>
        .taskModel (extractTaskModelCountermodel φ openBranch hSat hOpen)

/-!
## Semantic Bridge Lemma

The key bridge between tableau evaluation and full task frame semantics.
For a saturated open branch, F(φ) in the branch implies ¬truth_at for
the extracted model.

The proof is much simpler than expected due to saturation:
- Only F(atom p) and F(bot) can appear in a saturated branch
- Complex formulas (F(imp), F(box), F(all_future), F(all_past)) are vacuous
  because they would have been expanded by the saturation process
-/

/--
Bridge lemma: If F(φ) is in a saturated open branch b, then φ is not satisfied
at the extracted countermodel.

This connects the tableau-based formula evaluation to full task frame semantics,
enabling the completeness proof for the decidability procedure.

**Key insight**: In a saturated branch, complex formulas cannot appear in negative
position because they would have been expanded. So only atom and bot cases are
non-vacuous.
-/
theorem evalFormula_implies_sat (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b = none) (φ : Formula)
    (hneg : SignedFormula.neg φ ∈ b) :
    ¬truth_at (extractBranchTaskModel b) (extractBranchWorldHistory b) 0 φ := by
  -- Case split on the formula structure
  cases φ with
  | atom p =>
    -- Atom case: use atom_false_if_neg_in_open_branch
    -- We need to show ¬truth_at M τ 0 (atom p)
    -- truth_at ... (atom p) = ∃ (ht : τ.domain 0), M.valuation (τ.states 0 ht) p
    simp only [truth_at]
    intro ⟨ht, hval⟩
    -- hval : M.valuation (τ.states 0 ht) p
    -- For extractBranchWorldHistory, states is constant (extractInitialWorldState b)
    -- So hval : branchWorldStateValuation (extractBranchWorldState b) p
    -- But atom_false_if_neg_in_open_branch says ¬branchWorldStateValuation ... p
    have hfalse := atom_false_if_neg_in_open_branch b hOpen p hneg
    -- Need to show hval contradicts hfalse
    -- extractBranchTaskModel b has valuation = branchWorldStateValuation
    -- extractBranchWorldHistory b has states _ _ = extractInitialWorldState b = extractBranchWorldState b
    simp only [extractBranchTaskModel, extractBranchWorldHistory, constantBranchHistory,
               extractInitialWorldState] at hval
    exact hfalse hval
  | bot =>
    -- Bot case: truth_at ... bot = False, so ¬False is trivial
    simp only [truth_at, not_false_eq_true]
  | imp φ₁ φ₂ =>
    -- F(φ→ψ) cannot be in a saturated branch (would have been expanded)
    exfalso
    exact saturation_contradiction b hSat _ hneg (isExpanded_neg_imp_false φ₁ φ₂)
  | box φ₁ =>
    -- F(□φ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ hneg (isExpanded_neg_box_false φ₁)
  | all_future φ₁ =>
    -- F(Gφ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ hneg (isExpanded_neg_all_future_false φ₁)
  | all_past φ₁ =>
    -- F(Hφ) cannot be in a saturated branch
    exfalso
    exact saturation_contradiction b hSat _ hneg (isExpanded_neg_all_past_false φ₁)

end Bimodal.Metalogic_v2.Decidability
