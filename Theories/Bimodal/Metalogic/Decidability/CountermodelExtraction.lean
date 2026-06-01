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
## Saturation Invariants

These lemmas derive properties of saturated open branches from the conditions
`findUnexpanded b = none` (saturation) and `findClosure b fc = none` (openness).
They form the foundation for the truth lemma proof.
-/

/--
**No T(bot) in open branch**: If `findClosure b fc = none`, then no signed
formula `T(bot)` at any label appears in the branch.
-/
theorem sat_no_bot_pos (b : Branch) (fc : FrameClass)
    (hOpen : findClosure b fc = none) :
    ∀ l : Label, ¬(⟨.pos, .bot, l⟩ ∈ b) := by
  intro l hmem
  -- findClosure = checkBotPos <|> ... = none implies checkBotPos b = some _
  -- which contradicts hOpen
  have hBot : (checkBotPos b).isSome := by
    rw [checkBotPos, List.findSome?_isSome_iff]
    exact ⟨⟨.pos, .bot, l⟩, hmem, by simp⟩
  -- But findClosure b fc = none implies checkBotPos b is none
  simp only [findClosure] at hOpen
  cases h : checkBotPos b with
  | none => simp [h] at hBot
  | some r => simp [h] at hOpen

/--
**No complementary pair in open branch**: If `findClosure b fc = none`, then
for any formula `φ` and label `l`, not both `T(φ)` and `F(φ)` at `l` are in `b`.
-/
theorem sat_no_contradiction (b : Branch) (fc : FrameClass)
    (hOpen : findClosure b fc = none) :
    ∀ φ : Formula, ∀ l : Label,
      ¬(⟨.pos, φ, l⟩ ∈ b ∧ ⟨.neg, φ, l⟩ ∈ b) := by
  intro φ l ⟨hpos, hneg⟩
  -- If both T(φ) and F(φ) at l are in b, then checkContradiction b ≠ none
  have hContra : (checkContradiction b).isSome := by
    rw [checkContradiction, List.findSome?_isSome_iff]
    refine ⟨⟨.pos, φ, l⟩, hpos, ?_⟩
    simp only [SignedFormula.isPos, Option.isSome_some]
    -- Need to show: (true ∧ b.hasNegAt φ l) is true for the if-then-else
    -- hasNegAt b φ l = b.contains ⟨.neg, φ, l⟩ = b.any (· == ⟨.neg, φ, l⟩)
    have hNegAt : Branch.hasNegAt b φ l = true := by
      simp only [Branch.hasNegAt, Branch.contains, List.any_eq_true]
      exact ⟨_, hneg, beq_self_eq_true _⟩
    simp [hNegAt]
  -- But findClosure b fc = none implies checkContradiction b is none
  simp only [findClosure] at hOpen
  cases hb : checkBotPos b with
  | some r => simp [hb] at hOpen
  | none =>
    simp [hb] at hOpen
    cases hc : checkContradiction b with
    | some r => simp [hc] at hOpen
    | none => simp [hc] at hContra

/--
**Atom consistency**: In a saturated open branch, for any atom `p` and label `l`,
not both `T(atom p)` and `F(atom p)` at label `l` are in the branch.
A corollary of `sat_no_contradiction`.
-/
theorem sat_atom_consistent (b : Branch) (fc : FrameClass)
    (hOpen : findClosure b fc = none) :
    ∀ (p : Atom) (l : Label),
      ¬(b.hasPosAt (.atom p) l = true ∧ b.hasNegAt (.atom p) l = true) := by
  intro p l ⟨hPosAt, hNegAt⟩
  -- hasPosAt b (atom p) l = true means ⟨.pos, .atom p, l⟩ ∈ b (via List.any)
  simp only [Branch.hasPosAt, Branch.contains, List.any_eq_true] at hPosAt
  obtain ⟨sf_pos, hmem_pos, hbeq_pos⟩ := hPosAt
  have heq_pos : sf_pos = ⟨.pos, .atom p, l⟩ := beq_iff_eq.mp hbeq_pos
  subst heq_pos
  -- Similarly for hasNegAt
  simp only [Branch.hasNegAt, Branch.contains, List.any_eq_true] at hNegAt
  obtain ⟨sf_neg, hmem_neg, hbeq_neg⟩ := hNegAt
  have heq_neg : sf_neg = ⟨.neg, .atom p, l⟩ := beq_iff_eq.mp hbeq_neg
  subst heq_neg
  -- Now we have both ⟨.pos, .atom p, l⟩ ∈ b and ⟨.neg, .atom p, l⟩ ∈ b
  exact sat_no_contradiction b fc hOpen (.atom p) l ⟨hmem_pos, hmem_neg⟩

/--
**Atom valuation correctness (positive)**: If `T(atom p)` at `(w, t)` is in
the branch, then `buildAtomValuation b w t p = true`.
This follows directly from the definition of `buildAtomValuation`.
-/
theorem valuation_reflects_pos (b : Branch) (p : Atom) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .atom p, ⟨w, t⟩⟩ ∈ b) :
    buildAtomValuation b w t p = true := by
  unfold buildAtomValuation Branch.hasPosAt Branch.contains
  rw [List.any_eq_true]
  exact ⟨_, hmem, beq_self_eq_true _⟩

/--
**Atom valuation correctness (negative)**: If `F(atom p)` at `(w, t)` is in
an open branch, then `buildAtomValuation b w t p = false`.
Follows from atom consistency: if F(atom p) is in b, then T(atom p) is not.
-/
theorem valuation_reflects_neg (b : Branch) (fc : FrameClass)
    (hOpen : findClosure b fc = none)
    (p : Atom) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .atom p, ⟨w, t⟩⟩ ∈ b) :
    buildAtomValuation b w t p = false := by
  -- buildAtomValuation b w t p = b.hasPosAt (.atom p) ⟨w, t⟩
  unfold buildAtomValuation
  -- If hasPosAt were true, we'd have both pos and neg, contradicting openness
  by_contra h
  push_neg at h
  -- h : b.hasPosAt (.atom p) ⟨w, t⟩ ≠ false, so it must be true
  have hPosAt : Branch.hasPosAt b (.atom p) ⟨w, t⟩ = true := by
    cases hc : Branch.hasPosAt b (.atom p) ⟨w, t⟩ <;> simp_all
  -- We also need hasNegAt to be true
  have hNegAt : Branch.hasNegAt b (.atom p) ⟨w, t⟩ = true := by
    simp only [Branch.hasNegAt, Branch.contains, List.any_eq_true]
    exact ⟨_, hmem, beq_self_eq_true _⟩
  exact sat_atom_consistent b fc hOpen p ⟨w, t⟩ ⟨hPosAt, hNegAt⟩

/--
**Implication negative saturation**: If `F(ψ → χ)` is in a saturated branch,
then `T(ψ)` and `F(χ)` are both in the branch at the same label.
The `impNeg` rule is a linear (non-branching) rule that adds both.
-/
theorem sat_imp_neg (b : Branch) (hSat : findUnexpanded b = none)
    (ψ χ : Formula) (l : Label)
    (hmem : ⟨.neg, .imp ψ χ, l⟩ ∈ b) :
    ⟨.pos, ψ, l⟩ ∈ b ∧ ⟨.neg, χ, l⟩ ∈ b := by
  -- PROOF STRATEGY: This is vacuously true in a saturated branch because
  -- F(ψ → χ) cannot be in a saturated branch. The impNeg rule always applies
  -- to F(A → B) and produces a non-notApplicable result (.linear [T(A), F(B)]),
  -- so findApplicableRule returns some, making isExpanded = false, which means
  -- findUnexpanded b ≠ none — contradicting hSat.
  -- BLOCKED BY: Requires unfolding through allRulesForFC, allRules, isApplicable,
  -- applyRule to show impNeg produces a non-notApplicable result. The proof is
  -- feasible but requires ~50 lines of tactic-level unfolding of the rule engine.
  sorry

/--
**Box positive saturation**: If `T(□φ)` at `(w, t)` is in a saturated branch,
then `T(φ)` at `(w', t)` is in the branch for all known worlds `w'`.
The `boxPos` rule is persistent and propagates to all known worlds.
-/
theorem sat_box_pos (b : Branch) (hSat : findUnexpanded b = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .box φ, ⟨w, t⟩⟩ ∈ b) :
    ∀ w' ∈ b.knownWorlds, ⟨.pos, φ, ⟨w', t⟩⟩ ∈ b := by
  -- PROOF STRATEGY: The boxPos rule is persistent and propagates T(φ) to all
  -- known worlds. In a saturated branch, either all T(φ) at (w', t) are already
  -- present (and we're done), or boxPos would apply and findApplicableRule would
  -- return some, contradicting saturation. Specifically, applyRule .boxPos filters
  -- for worlds where T(φ) is NOT already present; if any such world exists, it
  -- returns .persistent (non-empty list), so findApplicableRule returns some.
  -- If all are present, applyRule returns .notApplicable (empty filter), and we
  -- can conclude the result directly from branch membership.
  -- BLOCKED BY: Requires case analysis on whether applyRule produces notApplicable
  -- or persistent, and relating the filterMap in boxPos to branch membership.
  sorry

/--
**Box negative saturation**: If `F(□φ)` at `(w, t)` is in a saturated branch,
then there exists a world `w'` in `knownWorlds` such that `F(φ)` at `(w', t)`
is in the branch. The `boxNeg` rule creates a fresh witness world.
-/
theorem sat_box_neg (b : Branch) (hSat : findUnexpanded b = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .box φ, ⟨w, t⟩⟩ ∈ b) :
    ∃ w' ∈ b.knownWorlds, ⟨.neg, φ, ⟨w', t⟩⟩ ∈ b := by
  -- PROOF STRATEGY: Vacuously true in a saturated branch. The boxNeg rule always
  -- applies to F(□φ) and produces a .linear result (introducing a fresh witness
  -- world), which is never .notApplicable. So findApplicableRule returns some,
  -- making isExpanded false, contradicting hSat.
  -- BLOCKED BY: Same as sat_imp_neg — requires unfolding the rule engine to show
  -- boxNeg always produces a non-notApplicable result for F(□φ).
  sorry

/--
**Until positive saturation**: If `T(U(event, guard))` at `(w, t)` was in a
saturated branch, then at some future time `t'`, either:
- `T(event)` at `(w, t')` is in the branch (event witnessed), or
- `T(guard)` at `(w, t')` and `T(U(event, guard))` at `(w, t')` are in the
  branch (guard holds and obligation continues).
-/
theorem sat_untl_pos (b : Branch) (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .untl event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes,
      (⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
      (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl event guard, ⟨w, t'⟩⟩ ∈ b) := by
  -- PROOF STRATEGY: If guard = top, this is some_future (handled by someFuturePos
  -- rule). If guard ≠ top, the untlPos rule applies via asUntil? returning some.
  -- The branching result produces an event-witness branch and a guard+continue
  -- branch. In the saturated branch we examine, one of the two alternatives holds.
  -- BLOCKED BY: Requires analyzing the branching structure of expandOnce to track
  -- which branch alternative was taken. The saturated branch must be one of the
  -- child branches of the untlPos split, so either T(event) or T(guard) ∧ T(U(...))
  -- is present. This requires tracking formula provenance through expansion.
  sorry

/--
**Since positive saturation**: Mirror of `sat_untl_pos` for past-directed Since.
-/
theorem sat_snce_pos (b : Branch) (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .snce event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes,
      (⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
      (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .snce event guard, ⟨w, t'⟩⟩ ∈ b) := by
  -- PROOF STRATEGY: Mirror of sat_untl_pos for past-directed Since.
  -- BLOCKED BY: Same as sat_untl_pos — requires branching provenance tracking.
  sorry

/--
**Until negative saturation**: If `F(U(event, guard))` at `(w, t)` is in a
saturated branch with guard not equal to `top`, then for every known future
time `t'`, either `F(event)` at `(w, t')` or the negated guard condition holds.
This follows from the Reynolds co-decomposition applied by `untlNeg`.
-/
theorem sat_untl_neg (b : Branch) (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event guard, ⟨w, t⟩⟩ ∈ b)
    (hguard : guard ≠ Formula.top) :
    ∀ t' ∈ b.knownTimes,
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨
      ⟨.neg, guard, ⟨w, t'⟩⟩ ∈ b := by
  -- PROOF STRATEGY: The untlNeg rule is persistent and propagates F(event) and
  -- F(guard) to all known future times via Reynolds co-decomposition. In a
  -- saturated branch, either the propagated formulas are already present (done)
  -- or the rule would apply (contradicting saturation). Similar to sat_box_pos.
  -- BLOCKED BY: Requires relating the untlNeg persistent rule's filterMap to
  -- branch membership and showing that if any time is missing the result,
  -- findApplicableRule would return some.
  sorry

/--
**Since negative saturation**: Mirror of `sat_untl_neg` for past-directed Since.
-/
theorem sat_snce_neg (b : Branch) (hSat : findUnexpanded b = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .snce event guard, ⟨w, t⟩⟩ ∈ b)
    (hguard : guard ≠ Formula.top) :
    ∀ t' ∈ b.knownTimes,
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b ∨
      ⟨.neg, guard, ⟨w, t'⟩⟩ ∈ b := by
  -- PROOF STRATEGY: Mirror of sat_untl_neg for past-directed Since.
  -- BLOCKED BY: Same as sat_untl_neg — requires persistent rule analysis.
  sorry

/-!
## Branch Truth Lemma

The truth lemma is the key correctness theorem. It states that for a saturated
open branch, every signed formula in the branch holds semantically in the
extracted countermodel:
- T(φ) at (w,t) implies φ is true at (w,t) in the model
- F(φ) at (w,t) implies φ is false at (w,t) in the model

The proof proceeds by structural induction on the formula, using the saturation
invariants established above.
-/

/--
Helper: if T(φ) at (w,t) is in the branch, then branchTruth cm w t φ holds.
Proved by structural induction on φ.
-/
private theorem truthLemma_pos (b : Branch) (hSat : findUnexpanded b = none)
    (fc : FrameClass) (hOpen : findClosure b fc = none)
    (cm : SemanticCountermodel)
    (hCm : cm = extractSemanticCountermodel cm.formula b cm.timeOrdering)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, φ, ⟨w, t⟩⟩ ∈ b) :
    branchTruth cm w t φ := by
  induction φ generalizing w t with
  | atom p =>
    -- T(atom p) at (w,t) ∈ b => buildAtomValuation b w t p = true
    simp only [branchTruth]
    have := valuation_reflects_pos b p w t hmem
    rw [hCm]; simp [extractSemanticCountermodel, this]
  | bot =>
    -- T(bot) cannot be in an open branch
    exact absurd hmem (sat_no_bot_pos b fc hOpen ⟨w, t⟩)
  | imp ψ χ ih_ψ ih_χ =>
    -- T(ψ → χ) at (w,t): the impPos rule is branching (F(ψ) | T(χ)).
    -- In a saturated branch, the formula was consumed and one branch was chosen.
    -- But in our setting, findUnexpanded b = none means the formula IS expanded
    -- (it was consumed by the linear/branching rule). This case actually means
    -- the formula should not be in the saturated branch (it would have been consumed).
    -- The theorem is vacuously true — but to show it properly requires the same
    -- rule-engine unfolding as sat_imp_neg. We use sorry here.
    simp only [branchTruth]
    sorry
  | box ψ ih =>
    -- T(□ψ) at (w,t): by sat_box_pos, T(ψ) at (w',t) for all known worlds w'.
    -- By IH, branchTruth cm w' t ψ for all w' in knownWorlds.
    -- Since cm.worlds = knownWorlds (by hCm), this gives ∀ w' ∈ cm.worlds, branchTruth...
    simp only [branchTruth]
    intro w' hw'
    rw [hCm] at hw'
    simp [extractSemanticCountermodel] at hw'
    have hbox := sat_box_pos b hSat ψ w t hmem
    exact ih w' t (hbox w' hw')
  | untl event guard ih_event ih_guard =>
    -- T(U(event, guard)): by sat_untl_pos, there exists t' with T(event) at (w,t')
    -- or T(guard) at (w,t') ∧ T(U(event,guard)) at (w,t').
    -- This requires tracking temporal witnesses through the model construction.
    simp only [branchTruth]
    sorry
  | snce event guard ih_event ih_guard =>
    -- T(S(event, guard)): mirror of untl case.
    simp only [branchTruth]
    sorry

/--
Helper: if F(φ) at (w,t) is in the branch, then ¬branchTruth cm w t φ holds.
Proved by structural induction on φ.
-/
private theorem truthLemma_neg (b : Branch) (hSat : findUnexpanded b = none)
    (fc : FrameClass) (hOpen : findClosure b fc = none)
    (cm : SemanticCountermodel)
    (hCm : cm = extractSemanticCountermodel cm.formula b cm.timeOrdering)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, φ, ⟨w, t⟩⟩ ∈ b) :
    ¬branchTruth cm w t φ := by
  induction φ generalizing w t with
  | atom p =>
    -- F(atom p) at (w,t) ∈ b => buildAtomValuation b w t p = false
    simp only [branchTruth]
    have := valuation_reflects_neg b fc hOpen p w t hmem
    rw [hCm]; simp [extractSemanticCountermodel, this]
  | bot =>
    -- F(bot) at (w,t): branchTruth cm w t bot = False, so ¬False is trivial
    simp [branchTruth]
  | imp ψ χ ih_ψ ih_χ =>
    -- F(ψ → χ) at (w,t): by sat_imp_neg, T(ψ) and F(χ) are in the branch.
    -- By IH (pos for ψ, neg for χ), branchTruth ψ and ¬branchTruth χ.
    -- Therefore branchTruth (ψ → χ) = (branchTruth ψ → branchTruth χ) is false.
    simp only [branchTruth]
    intro h
    have ⟨hψ, hχ⟩ := sat_imp_neg b hSat ψ χ ⟨w, t⟩ hmem
    have hψ_true := truthLemma_pos b hSat fc hOpen cm hCm ψ w t hψ
    have hχ_false := ih_χ w t hχ
    exact hχ_false (h hψ_true)
  | box ψ ih =>
    -- F(□ψ) at (w,t): by sat_box_neg, there exists w' with F(ψ) at (w',t).
    -- By IH, ¬branchTruth ψ at w'. So branchTruth (□ψ) requires ψ true at all
    -- worlds including w', contradiction.
    simp only [branchTruth]
    intro h
    have ⟨w', hw'mem, hw'neg⟩ := sat_box_neg b hSat ψ w t hmem
    have := ih w' t hw'neg
    have hw'_in_cm : w' ∈ cm.worlds := by
      rw [hCm]; simp [extractSemanticCountermodel]; exact hw'mem
    exact this (h w' hw'_in_cm)
  | untl event guard ih_event ih_guard =>
    -- F(U(event, guard)): requires showing no future time satisfies the until condition.
    simp only [branchTruth]
    sorry
  | snce event guard ih_event ih_guard =>
    -- F(S(event, guard)): mirror of untl case.
    simp only [branchTruth]
    sorry

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
  intro sf hsf
  unfold signedTruthInModel
  -- Decompose sf into its components
  obtain ⟨sign, formula, ⟨world, time⟩⟩ := sf
  cases sign with
  | pos =>
    -- sf = ⟨.pos, formula, ⟨world, time⟩⟩: show branchTruth
    exact truthLemma_pos b hSat fc hOpen cm hCm formula world time hsf
  | neg =>
    -- sf = ⟨.neg, formula, ⟨world, time⟩⟩: show ¬branchTruth
    exact truthLemma_neg b hSat fc hOpen cm hCm formula world time hsf

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
