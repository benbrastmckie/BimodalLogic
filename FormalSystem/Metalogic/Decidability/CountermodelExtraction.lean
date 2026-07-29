/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Saturation
import FormalSystem.Semantics

/-!
# Countermodel Extraction from Open Tableau Branches

This module extracts finite countermodels from open (saturated) tableau branches.
When a branch saturates without closing, it describes a model that falsifies
the original formula, providing a witness for invalidity.

## Main Definitions

- `SimpleCountermodel`: Simple countermodel description (atoms true/false)
- `SemanticCountermodel`: Full semantic countermodel with world states, time domain,
  temporal ordering, and atom valuation
- `extractSimpleCountermodel`: Build simple countermodel from saturated branch
- `extractSemanticCountermodel`: Build semantic countermodel from saturated branch
- the `sat_*` family: the Hintikka conditions a saturated open branch satisfies, each read
  directly off the guard that suppressed a rule

## Two-Layer Architecture

1. **SimpleCountermodel** (Layer 0): Tracks only which atoms are true/false.
   Useful for debugging, display, and training data generation.

2. **SemanticCountermodel** (Layer 1): Full finite model with worlds, times,
   temporal ordering, and valuation. Defined directly on the branch structure
   to avoid universe level issues with the full TaskFrame/WorldHistory stack.

## Where semantic correctness actually lives

**Not here.** This file extracts countermodel *data* and proves the `sat_*` Hintikka conditions;
it does not prove a truth lemma, and no longer contains a definition purporting to evaluate truth
on the extracted structure. The truth lemma is `Verified/Bridge/IntTruth.lean`'s `branchTruthAt`,
stated against the real `TaskModel`/`WorldHistory` semantics over a carrier, with
`Verified/Bridge/DenseTruth.lean` carrying it to the dense carriers.

See "Branch Truth Lemma — Retired", below, for what used to be claimed here, why it was
withdrawn, and why the recursive `branchTruth` evaluator that survived that withdrawal has now
been deleted too.

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem

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
  let atomToStr (a : Atom) : String := match a.freshIndex with
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
    {ord : TimeOrdering} {fc : FrameClass}
    (_hSaturated : findUnexpanded b (timeOrd := ord) (fc := fc) = none)
    : SimpleCountermodel :=
  extractSimpleCountermodel φ b

/--
Extract countermodel from an expanded tableau with an open branch.
-/
def extractCountermodelFromTableau (φ : Formula) (tableau : ExpandedTableau)
    (_fc : FrameClass := .Base) : Option SimpleCountermodel :=
  match tableau with
  | .allClosed _ => none  -- No countermodel, formula is valid
  | .hasOpen openBranch _ord _fc hSaturated =>
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
    simp only [SignedFormula.isPos]
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
    simp only [hb, Option.orElse_eq_orElse, Option.orElse_eq_or, Option.none_or,
      Option.or_eq_none_iff] at hOpen
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
  push Not at h
  -- h : b.hasPosAt (.atom p) ⟨w, t⟩ ≠ false, so it must be true
  have hPosAt : Branch.hasPosAt b (.atom p) ⟨w, t⟩ = true := by
    cases hc : Branch.hasPosAt b (.atom p) ⟨w, t⟩ <;> simp_all
  -- We also need hasNegAt to be true
  have hNegAt : Branch.hasNegAt b (.atom p) ⟨w, t⟩ = true := by
    simp only [Branch.hasNegAt, Branch.contains, List.any_eq_true]
    exact ⟨_, hmem, beq_self_eq_true _⟩
  exact sat_atom_consistent b fc hOpen p ⟨w, t⟩ ⟨hPosAt, hNegAt⟩

/--
Helper: `findUnexpanded b = none` implies every formula in `b` is expanded.
-/
private theorem findUnexpanded_none_all_expanded (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none) :
    ∀ sf ∈ b, isExpanded sf b (timeOrd := timeOrd) = true := by
  intro sf hsf
  -- findUnexpanded b = b.find? (fun sf => !isExpanded sf b) = none
  -- By List.find?_eq_none, for all sf ∈ b, ¬(!isExpanded sf b)
  unfold findUnexpanded at hSat
  have h := List.find?_eq_none.mp hSat sf hsf
  simp only [Bool.not_eq_true, Bool.decide_eq_false, Bool.not_eq_eq_eq_not, Bool.not_true,
    Bool.not_eq_false] at h
  exact h

/--
Helper: if `isExpanded sf b = true`, then `findApplicableRule sf b = none`.
-/
private theorem expanded_iff_no_applicable (sf : SignedFormula) (b : Branch) :
    isExpanded sf b = true ↔ (findApplicableRule sf b).isNone = true := by
  unfold isExpanded
  simp

private theorem contains_iff_mem (b : Branch) (sf : SignedFormula) :
    Branch.contains b sf = true ↔ sf ∈ b := by
  simp only [Branch.contains, List.any_eq_true]
  constructor
  · rintro ⟨x, hx, heq⟩
    exact beq_iff_eq.mp heq ▸ hx
  · intro h
    exact ⟨sf, h, beq_self_eq_true _⟩

/-- Every formula on the branch contributes its time to `Branch.knownTimes`. -/
private theorem mem_knownTimes_of_mem {b : Branch} {sf : SignedFormula} (h : sf ∈ b) :
    sf.label.time ∈ b.knownTimes := by
  have hmap : sf.label.time ∈ b.map (·.label.time) := List.mem_map.mpr ⟨sf, h, rfl⟩
  simpa [Branch.knownTimes] using hmap

/-!
### From vacuity to content

The saturation facts below used to be proved *vacuously*: `F(ψ → χ)` was said to be unable to
occur on a saturated branch at all, because `impNeg` "always applies" to it. That was true of
the unguarded engine, and it is exactly why the facts were worth nothing — a hypothesis no
branch can satisfy proves every conclusion.

With `findApplicableRule` branch-guarded, "no rule applies to `F(ψ → χ)`" no longer means the
formula cannot be there; it means `impNeg`'s conclusion is *already on the branch*. Each of
these lemmas is therefore now read directly off the guard that suppressed the rule, and each
now has content. The fresh-label rules are read off `witnessPresent` in the same way.
-/

/--
**Implication negative saturation**: If `F(ψ → χ)` is in a saturated branch,
then `T(ψ)` and `F(χ)` are both in the branch at the same label.

`impNeg` is linear and does not mint a label, so the only way a saturated branch can carry
`F(ψ → χ)` is for the rule to have been suppressed by its output-presence guard — which says
precisely that both conclusions are already present.
-/
theorem sat_imp_neg (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (ψ χ : Formula) (l : Label)
    (hmem : ⟨.neg, .imp ψ χ, l⟩ ∈ b) :
    ⟨.pos, ψ, l⟩ ∈ b ∧ ⟨.neg, χ, l⟩ ∈ b := by
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat ⟨.neg, .imp ψ χ, l⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .impNeg (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  have hall : (List.all [SignedFormula.pos ψ l, SignedFormula.neg χ l] b.contains) = true := by
    by_contra hc
    simp only [isApplicable, applyRule, ruleMintsFreshLabel, if_true, Bool.false_eq_true,
      if_false, if_neg hc] at h
    exact absurd h (by simp)
  simp only [List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true] at hall
  exact ⟨(contains_iff_mem b _).mp hall.1, (contains_iff_mem b _).mp hall.2⟩

set_option maxHeartbeats 1600000 in
-- `sat_box_pos` unfolds `findApplicableRule`, which forces the whole `allRulesForFC`
-- rule table to reduce, then discharges applicability for every rule in it.
/--
**Box positive saturation**: If `T(□φ)` at `(w, t)` is in a saturated branch,
then `T(φ)` at `(w', t)` is in the branch for all known worlds `w'`.
The `boxPos` rule is persistent and propagates to all known worlds.
-/
theorem sat_box_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .box φ, ⟨w, t⟩⟩ ∈ b) :
    ∀ w' ∈ b.knownWorlds, ⟨.pos, φ, ⟨w', t⟩⟩ ∈ b := by
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat ⟨.pos, .box φ, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have hBoxPos := hExp (.boxPos) (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [isApplicable, applyRule] at hBoxPos
  simp only [ite_true] at hBoxPos
  -- Extract: the filterMap over knownWorlds must be empty
  set fm := (b.knownWorlds.filterMap fun w' =>
    if b.contains (SignedFormula.pos φ { world := w', time := t }) = true then none
    else some (SignedFormula.pos φ { world := w', time := t })) with hfm_def
  by_cases hfm : fm.isEmpty
  · -- filterMap empty: every world already has T(φ)
    intro w' hw'
    by_contra habs
    have hNotContains : Branch.contains b ⟨.pos, φ, ⟨w', t⟩⟩ = false := by
      simp only [Bool.eq_false_iff]; exact fun h => habs ((contains_iff_mem b _).mp h)
    have hmem_fm : SignedFormula.pos φ ⟨w', t⟩ ∈ fm := by
      rw [hfm_def, List.mem_filterMap]
      exact ⟨w', hw', by simp [SignedFormula.pos, hNotContains]⟩
    have hnil : fm = [] := List.isEmpty_iff.mp hfm
    rw [hnil] at hmem_fm
    exact absurd hmem_fm (by simp)
  · -- filterMap non-empty: applyRule returns persistent (not notApplicable),
    -- so findApplicableRule returns some, contradicting expansion
    simp [hfm] at hBoxPos

/--
**Box negative saturation**: If `F(□φ)` at `(w, t)` is in a saturated branch,
then there exists a world `w'` in `knownWorlds` such that `F(φ)` at `(w', t)`
is in the branch. The `boxNeg` rule creates a fresh witness world.
-/
theorem sat_box_neg (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (φ : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .box φ, ⟨w, t⟩⟩ ∈ b) :
    ∃ w' ∈ b.knownWorlds, ⟨.neg, φ, ⟨w', t⟩⟩ ∈ b := by
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat ⟨.neg, .box φ, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have h := hExp .boxNeg (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  -- `boxNeg` mints a fresh world, so its suppression is the witness guard, not output
  -- presence: some already-known world carries `F(φ)` at this time.
  have hwit : witnessPresent .boxNeg ⟨.neg, .box φ, ⟨w, t⟩⟩ b timeOrd = true := by
    by_contra hc
    simp only [isApplicable, applyRule, ruleMintsFreshLabel, if_true, if_neg hc] at h
    exact absurd h (by simp)
  simp only [witnessPresent, List.any_eq_true] at hwit
  obtain ⟨w', hw', hcont⟩ := hwit
  exact ⟨w', hw', (contains_iff_mem b _).mp hcont⟩

set_option maxHeartbeats 800000 in
/--
**Until positive saturation**: if `T(U(event, guard))` at `(w, t)` is on a saturated branch,
some known time carries the event witness, or carries the guard together with the Until itself.

Both rules that can act here mint a fresh time — `someFuturePos` when `guard = ⊤` (where the
formula is `F(event)`), `untlPos` otherwise — so in both cases suppression is the witness
guard, and the witness's own label puts its time in `Branch.knownTimes`.
-/
theorem sat_untl_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .untl event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes,
      (⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
      (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl event guard, ⟨w, t'⟩⟩ ∈ b) := by
  have hExp :=
    findUnexpanded_none_all_expanded b timeOrd hSat ⟨.pos, .untl event guard, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · -- `F(event)`: `someFuturePos` is the acting rule, and it is linear.
    subst hg
    have h := hExp .someFuturePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .someFuturePos ⟨.pos, .untl event Formula.top, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [Bool.not_eq_true, Formula.top] at hc
      simp [isApplicable, asSomeFuture?, Formula.top, applyRule, ruleMintsFreshLabel, hc] at h
    simp only [witnessPresent, asSomeFuture?, Formula.top, List.any_eq_true] at hwit
    obtain ⟨t', _, hcont⟩ := hwit
    have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp hcont
    exact ⟨t', mem_knownTimes_of_mem hmem', Or.inl hmem'⟩
  · -- Genuine Until: `untlPos` is the acting rule, and it is branching.
    have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .untlPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .untlPos ⟨.pos, .untl event guard, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [isApplicable, asUntil?, hg', if_false, applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true, Option.isSome_some, if_neg hc] at h
      exact absurd h (by simp)
    simp only [witnessPresent, asUntil?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', _, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp he
      exact ⟨t', mem_knownTimes_of_mem hmem', Or.inl hmem'⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp hgd
      have hmemU : (⟨.pos, .untl event guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        (contains_iff_mem b _).mp hu
      exact ⟨t', mem_knownTimes_of_mem hmemG, Or.inr ⟨hmemG, hmemU⟩⟩

set_option maxHeartbeats 800000 in
/-- **Since positive saturation**: past-directed mirror of `sat_untl_pos`. -/
theorem sat_snce_pos (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event guard : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.pos, .snce event guard, ⟨w, t⟩⟩ ∈ b) :
    ∃ t' ∈ b.knownTimes,
      (⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
      (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .snce event guard, ⟨w, t'⟩⟩ ∈ b) := by
  have hExp :=
    findUnexpanded_none_all_expanded b timeOrd hSat ⟨.pos, .snce event guard, ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  by_cases hg : guard = Formula.top
  · subst hg
    have h := hExp .somePastPos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .somePastPos ⟨.pos, .snce event Formula.top, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [Bool.not_eq_true, Formula.top] at hc
      simp [isApplicable, asSomePast?, Formula.top, applyRule, ruleMintsFreshLabel, hc] at h
    simp only [witnessPresent, asSomePast?, Formula.top, List.any_eq_true] at hwit
    obtain ⟨t', _, hcont⟩ := hwit
    have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp hcont
    exact ⟨t', mem_knownTimes_of_mem hmem', Or.inl hmem'⟩
  · have hg' : (guard == Formula.top) = false := by simp [hg]
    have h := hExp .sncePos (by simp [allRulesForFC, allRules, denseRules, discreteRules])
    have hwit :
        witnessPresent .sncePos ⟨.pos, .snce event guard, ⟨w, t⟩⟩ b timeOrd = true := by
      by_contra hc
      simp only [isApplicable, asSince?, hg', if_false, applyRule, ruleMintsFreshLabel,
        ruleSelfGuarded, if_true, Option.isSome_some, if_neg hc] at h
      exact absurd h (by simp)
    simp only [witnessPresent, asSince?, hg', Bool.false_eq_true, if_false, List.any_eq_true,
      Bool.or_eq_true, Bool.and_eq_true] at hwit
    obtain ⟨t', _, hcont⟩ := hwit
    rcases hcont with he | ⟨hgd, hu⟩
    · have hmem' : (⟨.pos, event, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp he
      exact ⟨t', mem_knownTimes_of_mem hmem', Or.inl hmem'⟩
    · have hmemG : (⟨.pos, guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b := (contains_iff_mem b _).mp hgd
      have hmemU : (⟨.pos, .snce event guard, ⟨w, t'⟩⟩ : SignedFormula) ∈ b :=
        (contains_iff_mem b _).mp hu
      exact ⟨t', mem_knownTimes_of_mem hmemG, Or.inr ⟨hmemG, hmemU⟩⟩

set_option maxHeartbeats 3200000 in
-- `sat_some_future_neg` combines the `allRulesForFC` rule-table reduction with a case
-- analysis repeated for every known future time in `timeOrd.futureOf t`.
/--
**Some-future negative saturation**: If `F(FA)` at `(w, t)` is in a saturated
branch, then `F(A)` is at `(w, t')` for every known future time `t'`.
Here `F(FA) = F(U(A, ⊤))`.
-/
theorem sat_some_future_neg (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .untl event (.imp .bot .bot), ⟨w, t⟩⟩ ∈ b) :
    ∀ t' ∈ timeOrd.futureOf t,
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b := by
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat
    ⟨.neg, .untl event (.imp .bot .bot), ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have hSFNeg := hExp (.someFutureNeg)
    (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [isApplicable, asSomeFuture?] at hSFNeg
  -- Extract: applyRule must return .notApplicable
  have hNA : (applyRule .someFutureNeg ⟨.neg, .untl event (.imp .bot .bot), ⟨w, t⟩⟩ b timeOrd).1 =
      .notApplicable := by
    by_contra h
    match hm :
      (applyRule .someFutureNeg ⟨.neg, .untl event (.imp .bot .bot), ⟨w, t⟩⟩ b timeOrd).1 with
    | .notApplicable => exact h hm
    -- `someFutureNeg` returns only `.notApplicable` or `.persistent`; the other two arms
    -- are structurally impossible, so they are discharged from `hm` rather than from the
    -- guard structure in `hSFNeg`.
    | .linear fs =>
        exact absurd hm (by unfold applyRule; simp only [asSomeFuture?]; split <;> simp)
    | .branching bs =>
        exact absurd hm (by unfold applyRule; simp only [asSomeFuture?]; split <;> simp)
    | .branchingOrdered bs =>
        exact absurd hm (by unfold applyRule; simp only [asSomeFuture?]; split <;> simp)
    | .persistent fs => rw [hm] at hSFNeg; simp at hSFNeg
  -- Unfold applyRule to get the filter structure
  unfold applyRule at hNA
  simp only [asSomeFuture?] at hNA
  intro t' ht'
  by_contra habs
  have hNotContains : Branch.contains b ⟨.neg, event, ⟨w, t'⟩⟩ = false := by
    simp only [Bool.eq_false_iff]; exact fun h => habs ((contains_iff_mem b _).mp h)
  -- Show the filterMap produces a non-empty list (t' contributes to it)
  have hFilterPred :
    (if Branch.contains b (SignedFormula.neg event { world := w, time := t' }) = true
      then none else some (SignedFormula.neg event { world := w, time := t' })) =
      some (SignedFormula.neg event { world := w, time := t' }) := by
    simp [SignedFormula.neg, hNotContains]
  -- The non-empty filterMap means the result is persistent (not notApplicable)
  have h_t'_fmap : SignedFormula.neg event { world := w, time := t' } ∈
      (timeOrd.futureOf t).filterMap fun t'' =>
        if Branch.contains b (SignedFormula.neg event { world := w, time := t'' }) = true
        then none else some (SignedFormula.neg event { world := w, time := t'' }) := by
    rw [List.mem_filterMap]
    exact ⟨t', ht', hFilterPred⟩
  have hNE : ((timeOrd.futureOf t).filterMap fun t'' =>
      if Branch.contains b (SignedFormula.neg event { world := w, time := t'' }) = true
      then none else some (SignedFormula.neg event { world := w, time := t'' })).isEmpty =
        false := by
    rw [Bool.eq_false_iff]
    intro hempty
    have := List.isEmpty_iff.mp hempty
    exact absurd (this ▸ h_t'_fmap) (by simp)
  simp only [SignedFormula.neg] at hNA hNE
  simp [hNE] at hNA

set_option maxHeartbeats 3200000 in
-- `sat_some_past_neg` is the past-directed mirror of `sat_some_future_neg`: same rule-table
-- reduction, repeated over every known past time.
/--
**Some-past negative saturation**: If `F(PA)` at `(w, t)` is in a saturated
branch, then `F(A)` is at `(w, t')` for every known past time `t'`.
Here `F(PA) = F(S(A, ⊤))`.
-/
theorem sat_some_past_neg (b : Branch) (timeOrd : TimeOrdering)
    (hSat : findUnexpanded b (timeOrd := timeOrd) = none)
    (event : Formula) (w : WorldIndex) (t : TimeIndex)
    (hmem : ⟨.neg, .snce event (.imp .bot .bot), ⟨w, t⟩⟩ ∈ b) :
    ∀ t' ∈ timeOrd.pastOf t,
      ⟨.neg, event, ⟨w, t'⟩⟩ ∈ b := by
  have hExp := findUnexpanded_none_all_expanded b timeOrd hSat
    ⟨.neg, .snce event (.imp .bot .bot), ⟨w, t⟩⟩ hmem
  simp only [isExpanded, Option.isNone_iff_eq_none] at hExp
  unfold findApplicableRule at hExp
  rw [List.findSome?_eq_none_iff] at hExp
  have hSPNeg := hExp (.somePastNeg)
    (by simp [allRulesForFC, allRules, denseRules, discreteRules])
  simp only [isApplicable, asSomePast?] at hSPNeg
  have hNA : (applyRule .somePastNeg ⟨.neg, .snce event (.imp .bot .bot), ⟨w, t⟩⟩ b timeOrd).1 =
      .notApplicable := by
    by_contra h
    match hm :
      (applyRule .somePastNeg ⟨.neg, .snce event (.imp .bot .bot), ⟨w, t⟩⟩ b timeOrd).1 with
    | .notApplicable => exact h hm
    -- Mirror of `sat_some_future_neg`: `.linear`/`.branching` are structurally impossible.
    | .linear fs =>
        exact absurd hm (by unfold applyRule; simp only [asSomePast?]; split <;> simp)
    | .branching bs =>
        exact absurd hm (by unfold applyRule; simp only [asSomePast?]; split <;> simp)
    | .branchingOrdered bs =>
        exact absurd hm (by unfold applyRule; simp only [asSomePast?]; split <;> simp)
    | .persistent fs => rw [hm] at hSPNeg; simp at hSPNeg
  unfold applyRule at hNA
  simp only [asSomePast?] at hNA
  intro t' ht'
  by_contra habs
  have hNotContains : Branch.contains b ⟨.neg, event, ⟨w, t'⟩⟩ = false := by
    simp only [Bool.eq_false_iff]; exact fun h => habs ((contains_iff_mem b _).mp h)
  have hFilterPred :
    (if Branch.contains b (SignedFormula.neg event { world := w, time := t' }) = true
      then none else some (SignedFormula.neg event { world := w, time := t' })) =
      some (SignedFormula.neg event { world := w, time := t' }) := by
    simp [SignedFormula.neg, hNotContains]
  have h_t'_fmap : SignedFormula.neg event { world := w, time := t' } ∈
      (timeOrd.pastOf t).filterMap fun t'' =>
        if Branch.contains b (SignedFormula.neg event { world := w, time := t'' }) = true
        then none else some (SignedFormula.neg event { world := w, time := t'' }) := by
    rw [List.mem_filterMap]
    exact ⟨t', ht', hFilterPred⟩
  have hNE : ((timeOrd.pastOf t).filterMap fun t'' =>
      if Branch.contains b (SignedFormula.neg event { world := w, time := t'' }) = true
      then none else some (SignedFormula.neg event { world := w, time := t'' })).isEmpty =
        false := by
    rw [Bool.eq_false_iff]
    intro hempty
    have := List.isEmpty_iff.mp hempty
    exact absurd (this ▸ h_t'_fmap) (by simp)
  simp only [SignedFormula.neg] at hNA hNE
  simp [hNE] at hNA

/-!
## `sat_untl_neg` / `sat_snce_neg` — Retired with the PASSIVE arms

These two theorems said: on a saturated branch carrying `F(U(event, guard))@(w,t)` with a
non-`top` guard, **every** known future time `t'` already carries `F(event)@(w,t')` or
`F(guard)@(w,t')` — and the past-directed mirror. They are recorded as retired rather than
deleted quietly, because they did not become merely unprovable. They became **false**.

Both were read straight off the PASSIVE co-decomposition arm of `applyRule .untlNeg` /
`.snceNeg`. The derivation was: saturation forces the rule to `.notApplicable`; the only way the
old rule reached `.notApplicable` with future times present was for its `unprocessed` filter to
be empty; and the filter was empty exactly when every future time already carried one of the two
disjuncts. Each theorem's conclusion *was* that filter predicate, transcribed.

The PASSIVE arms are now retired (see the blocks inside both arms in `Tableau.lean` for the
unsoundness that forced it, the refuted alternatives, and the authorization). `.notApplicable`
is now what the rule returns on **every** configuration with a non-empty `futureTimes`/
`pastTimes`, so saturation carries no information about those times at all, and a saturated
branch may perfectly well hold a future time with neither disjunct on it. The conclusion no
longer follows and does not hold.

Nothing consumed them. A grep across the project finds their names only in prose: two orientation
comments in `Tests/BimodalTest/TemporalWitnessProbe.lean` and one in
`Verified/Bridge/TemporalGate.lean`, each contrasting the strength of these facts against the
gate rows that superseded them. All three are updated in the same commit as this retirement.

What the gate rows do instead. `untlNegFuture` (`Verified/Bridge/TemporalGate.lean`) demands
`F(event)` at every known future time of every negative `Until` — strictly stronger than the
disjunction these theorems offered, and it is a hypothesis the truth lemmas bind (`hTW`) rather
than a fact derived from a rule's guard. That is the honest place for this content: a condition
the branch is *checked* against, not one inferred from an arm that should not have existed.
-/

/-!
## Branch Truth Lemma — Retired

The `branchTruthLemma` that used to live here was retired rather than repaired, and the
recursive `branchTruth` evaluator it ran on — together with its only consumer,
`signedTruthInModel` — has now been **deleted**.

The deletion is recorded rather than done silently, because the justification for the
intermediate state (keep the evaluator, retire only the lemma) turned out not to hold. That
state was defended on the ground that `branchTruth` remained "an executable debugging aid,
useful for `#eval`-inspecting what a branch claims". It was not executable: `branchTruth` is
`Prop`-valued and carries no `Decidable` instance, so
`Decidable (branchTruth cm w t f)` fails to synthesise and `#eval` was never available on it.
With that gone the definition had no remaining role — it was on no proof path, it could not be
run, and `signedTruthInModel`, its sole consumer, was itself referenced nowhere in the project.

The reason for retiring the lemma is unaffected by any of that, and is worth recording, because
the retirement is a gain rather than a loss. That lemma
proved its `imp`, `untl` and `snce` cases *vacuously*, via helper lemmas asserting that
`T(ψ → χ)`, `T(U(e,g))` and `T(S(e,g))` "cannot occur on a saturated branch at all". Those
helpers were true only of the unguarded, destructive engine, where every such formula was
consumed on sight — which is exactly why they were worthless: a case discharged by an
impossible hypothesis carries no semantic content, and three of the induction's six cases were
discharged that way.

Under the branch-guarded engine those formulas *can* sit on a saturated branch, with their
conclusions beside them, so the cases are now real. Discharging them properly is the
interpolation argument (a total valuation on a carrier, constant on the half-open intervals
between embedded branch times) plus the truth lemma built on it — mathematics of a different
order from anything in this file, and the subject of the `Verified/Bridge/` development.

What survives here, and is now non-vacuous, is the `sat_*` family above: each of those facts
is read directly off the guard that suppressed a rule, and each is a genuine Hintikka
condition the real truth lemma will consume.
-/


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
Result type for semantic countermodel extraction (richer than `CountermodelResult`).
Includes the `SemanticCountermodel` with its truth lemma guarantee alongside the
simple countermodel for backward compatibility.
-/
inductive SemanticCountermodelResult (φ : Formula) : Type where
  /-- Successfully extracted a semantic countermodel with correctness guarantee. -/
  | found (simple : SimpleCountermodel) (semantic : SemanticCountermodel)
  /-- Formula is valid, no countermodel exists. -/
  | valid
  /-- Extraction failed (timeout or other issue). -/
  | failed (reason : String)

/--
Try to find a countermodel for a formula.
Returns a `SimpleCountermodel` for backward compatibility.
-/
def findCountermodel (φ : Formula) (fuel : Nat := 1000)
    (fc : FrameClass := .Base) : CountermodelResult φ :=
  match buildTableau φ fuel fc with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch _ord _fc hSat) =>
      .found (extractCountermodelSimple φ openBranch hSat)

/--
Try to find a semantic countermodel for a formula.
Returns both a `SimpleCountermodel` (for display) and a `SemanticCountermodel`
(with the truth lemma guarantee that every signed formula in the saturated
branch is semantically satisfied in the model).
-/
def findSemanticCountermodel (φ : Formula) (fuel : Nat := 1000)
    (fc : FrameClass := .Base) : SemanticCountermodelResult φ :=
  match buildTableau φ fuel fc with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch ord _fc hSat) =>
      let simple := extractCountermodelSimple φ openBranch hSat
      let semantic := extractSemanticCountermodel φ openBranch ord
      .found simple semantic

/--
Extract both simple and semantic countermodels from an expanded tableau.
Returns `none` if the formula is valid (all branches closed).
-/
def extractCountermodelsFromTableau (φ : Formula) (tableau : ExpandedTableau)
    : Option (SimpleCountermodel × SemanticCountermodel) :=
  match tableau with
  | .allClosed _ => none
  | .hasOpen openBranch ord _fc hSaturated =>
      let simple := extractCountermodelSimple φ openBranch hSaturated
      let semantic := extractSemanticCountermodel φ openBranch ord
      some (simple, semantic)

end FormalSystem.Metalogic.Decidability
