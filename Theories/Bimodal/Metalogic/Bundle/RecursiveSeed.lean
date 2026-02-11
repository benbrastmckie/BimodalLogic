import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.GeneralizedNecessitation
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Finite.Basic

/-!
# Recursive Seed Construction for Henkin Model Completeness

This module implements a recursive, formula-driven seed construction for Henkin model
completeness in TM bimodal logic. Instead of building temporal and modal structure
independently (which failed in task 843 due to cross-sign temporal propagation),
this construction builds the entire model structure -- both temporal families and
modal families -- directly from the recursive structure of a consistent formula.

## Overview

The seed construction works by recursively unpacking a formula and creating
"seed entries" that specify which formulas should appear at which (family, time)
pairs. The key insight is that ALL temporal witnesses are placed in the seed
BEFORE any Lindenbaum extension, avoiding the cross-sign propagation problem
that blocked task 843's two-chain architecture.

## Main Definitions

- `FormulaClass`: Classification of formulas by their main operator
- `SeedEntryType`: Distinguishes temporal_witness vs. universal_target entries
- `SeedEntry`: A single entry in the model seed: (family, time, formulas, type)
- `ModelSeed`: Collection of seed entries plus metadata
- `classifyFormula`: Classify a formula by its main operator

## Key Insight

The distinction between modal witnesses (new families) and temporal witnesses
(new time indices within same family) mirrors BMCS semantics:
- Modal: neg(Box phi) creates a NEW FAMILY where phi holds
- Temporal: neg(G phi) creates a NEW TIME in the SAME family where phi holds

## References

- Research report: specs/864_recursive_seed_henkin_model/reports/research-002.md
- Task 843 blockage analysis: DovetailingChain.lean cross-sign propagation issue
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Formula Classification

We classify formulas by their main operator to determine how to process them
during seed construction.
-/

/--
Classification of formulas by their main operator.

This determines how the seed builder processes each formula:
- `atomic`: Propositional atoms, add to current entry
- `bottom`: Bottom, should not appear in consistent formulas
- `implication`: Implications, add to current entry (Lindenbaum decides branches)
- `negation`: Generic negation (not a special negated operator)
- `boxPositive`: Box phi, universal modal (add phi to all families)
- `boxNegative`: neg(Box phi), existential modal (create new family with neg phi)
- `futurePositive`: G phi, universal future (add phi to all future times)
- `futureNegative`: neg(G phi), existential future (create new time with neg phi)
- `pastPositive`: H phi, universal past (add phi to all past times)
- `pastNegative`: neg(H phi), existential past (create new time with neg phi)
-/
inductive FormulaClass : Type where
  | atomic : String → FormulaClass
  | bottom : FormulaClass
  | implication : Formula → Formula → FormulaClass
  | negation : Formula → FormulaClass
  | boxPositive : Formula → FormulaClass
  | boxNegative : Formula → FormulaClass
  | futurePositive : Formula → FormulaClass
  | futureNegative : Formula → FormulaClass
  | pastPositive : Formula → FormulaClass
  | pastNegative : Formula → FormulaClass
  deriving Repr, DecidableEq

/--
Classify a formula by its main operator.

Pattern matching logic:
- `imp (box phi) bot` = neg(Box phi) → boxNegative
- `imp (all_future phi) bot` = neg(G phi) → futureNegative
- `imp (all_past phi) bot` = neg(H phi) → pastNegative
- `imp phi bot` for other phi → generic negation
- `box phi` → boxPositive
- `all_future phi` → futurePositive
- `all_past phi` → pastPositive
- `imp phi psi` (not negation) → implication
- `atom s` → atomic
- `bot` → bottom
-/
def classifyFormula : Formula → FormulaClass
  | Formula.atom s => FormulaClass.atomic s
  | Formula.bot => FormulaClass.bottom
  | Formula.box phi => FormulaClass.boxPositive phi
  | Formula.all_future phi => FormulaClass.futurePositive phi
  | Formula.all_past phi => FormulaClass.pastPositive phi
  | Formula.imp (Formula.box phi) Formula.bot => FormulaClass.boxNegative phi
  | Formula.imp (Formula.all_future phi) Formula.bot => FormulaClass.futureNegative phi
  | Formula.imp (Formula.all_past phi) Formula.bot => FormulaClass.pastNegative phi
  | Formula.imp phi Formula.bot => FormulaClass.negation phi
  | Formula.imp phi psi => FormulaClass.implication phi psi

/--
Get the "inner formula" that the classification extracted.
For positive operators, this is the operand. For negative operators, this is the negated operand.
-/
def FormulaClass.innerFormula : FormulaClass → Option Formula
  | atomic _ => none
  | bottom => none
  | implication _ _ => none
  | negation phi => some phi
  | boxPositive phi => some phi
  | boxNegative phi => some phi
  | futurePositive phi => some phi
  | futureNegative phi => some phi
  | pastPositive phi => some phi
  | pastNegative phi => some phi

/-!
## Seed Entry Types

We track whether a seed entry was created as a temporal/modal witness (singleton)
or as a universal target (formulas added by universal propagation).
-/

/--
Type of a seed entry, tracking how it was created.

- `temporal_witness`: Created by neg(G phi) or neg(H phi), contains singleton witness formula
- `modal_witness`: Created by neg(Box phi), contains singleton witness formula
- `universal_target`: Contains formulas added by universal propagation (Box/G/H)
- `initial`: The initial entry for the starting formula

This distinction matters for:
1. Proving seed consistency (witness entries have singleton formulas)
2. Proving temporal coherence (universal entries need containment proofs)
-/
inductive SeedEntryType : Type where
  | temporal_witness : SeedEntryType
  | modal_witness : SeedEntryType
  | universal_target : SeedEntryType
  | initial : SeedEntryType
  deriving Repr, DecidableEq, BEq

/-!
## Seed Entry Structure

A seed entry represents a collection of formulas at a specific (family, time) position.
-/

/--
A single entry in the model seed.

Fields:
- `familyIdx`: Index of the family (0 for the initial/evaluation family)
- `timeIdx`: Time index within the family
- `formulas`: Set of formulas at this position
- `entryType`: How this entry was created

Invariant: After seed construction, each (familyIdx, timeIdx) pair has exactly one entry.
-/
structure SeedEntry where
  familyIdx : Nat
  timeIdx : Int
  formulas : Set Formula
  entryType : SeedEntryType

instance : BEq SeedEntry where
  beq e1 e2 := e1.familyIdx == e2.familyIdx && e1.timeIdx == e2.timeIdx

/--
Check if two entries have the same position (family, time).
-/
def SeedEntry.samePosition (e1 e2 : SeedEntry) : Prop :=
  e1.familyIdx = e2.familyIdx ∧ e1.timeIdx = e2.timeIdx

/-!
## Model Seed Structure

The model seed collects all seed entries and tracks the next available family index.
-/

/--
A model seed is a collection of seed entries with bookkeeping.

Fields:
- `entries`: List of seed entries
- `nextFamilyIdx`: Next available family index for creating new families
- `uniquePositions`: Each (family, time) position has at most one entry

The construction maintains:
1. Initial family is always at index 0
2. New families get consecutive indices from nextFamilyIdx
3. Formulas are merged into existing entries when applicable
-/
structure ModelSeed where
  entries : List SeedEntry
  nextFamilyIdx : Nat

/--
Empty model seed.
-/
def ModelSeed.empty : ModelSeed :=
  { entries := [], nextFamilyIdx := 0 }

/--
Create an initial seed with a single formula at family 0, time 0.
-/
def ModelSeed.initial (phi : Formula) : ModelSeed :=
  { entries := [{ familyIdx := 0, timeIdx := 0, formulas := {phi}, entryType := .initial }],
    nextFamilyIdx := 1 }

/-!
## Seed Manipulation Functions
-/

/--
Find an entry at a specific (family, time) position.
-/
def ModelSeed.findEntry (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) : Option SeedEntry :=
  seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx)

/--
Get formulas at a specific (family, time) position.
Returns empty set if no entry exists.
-/
def ModelSeed.getFormulas (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) : Set Formula :=
  match seed.findEntry famIdx timeIdx with
  | some entry => entry.formulas
  | none => ∅

/--
Get the entry type at a specific position.
-/
def ModelSeed.getEntryType (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) : Option SeedEntryType :=
  (seed.findEntry famIdx timeIdx).map SeedEntry.entryType

/--
Add a formula to a specific (family, time) position.
If an entry exists at that position, merge the formula into it.
If no entry exists, create a new entry with the given type.
-/
def ModelSeed.addFormula (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (newType : SeedEntryType) : ModelSeed :=
  let existingIdx := seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx)
  match existingIdx with
  | some idx =>
    -- Merge formula into existing entry (update entry at idx)
    let entries' := seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })
    { seed with entries := entries' }
  | none =>
    -- Create new entry
    let newEntry : SeedEntry := { familyIdx := famIdx, timeIdx := timeIdx,
                                  formulas := {phi}, entryType := newType }
    { seed with entries := seed.entries ++ [newEntry] }

/--
Add a formula to ALL existing families at a specific time.
Used for Box phi propagation.
-/
def ModelSeed.addToAllFamilies (seed : ModelSeed) (timeIdx : Int) (phi : Formula) : ModelSeed :=
  -- Get all unique family indices
  let famIndices := seed.entries.map SeedEntry.familyIdx |>.eraseDups
  famIndices.foldl (fun s famIdx => s.addFormula famIdx timeIdx phi .universal_target) seed

/--
Add a formula to all future times in a specific family.
Used for G phi propagation.
-/
def ModelSeed.addToAllFutureTimes (seed : ModelSeed) (famIdx : Nat)
    (currentTime : Int) (phi : Formula) : ModelSeed :=
  -- Find all time indices in this family that are > currentTime
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  let futureTimes := familyEntries.filter (fun e => e.timeIdx > currentTime)
                                  |>.map SeedEntry.timeIdx |>.eraseDups
  futureTimes.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed

/--
Add a formula to all past times in a specific family.
Used for H phi propagation.
-/
def ModelSeed.addToAllPastTimes (seed : ModelSeed) (famIdx : Nat)
    (currentTime : Int) (phi : Formula) : ModelSeed :=
  -- Find all time indices in this family that are < currentTime
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  let pastTimes := familyEntries.filter (fun e => e.timeIdx < currentTime)
                                |>.map SeedEntry.timeIdx |>.eraseDups
  pastTimes.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed

/--
Create a new family with a formula at a specific time.
Used for diamond (neg Box phi) witnesses.
Returns the updated seed and the new family index.
-/
def ModelSeed.createNewFamily (seed : ModelSeed) (timeIdx : Int)
    (phi : Formula) : ModelSeed × Nat :=
  let newFamIdx := seed.nextFamilyIdx
  let newEntry : SeedEntry := { familyIdx := newFamIdx, timeIdx := timeIdx,
                                formulas := {phi}, entryType := .modal_witness }
  ({ entries := seed.entries ++ [newEntry], nextFamilyIdx := newFamIdx + 1 }, newFamIdx)

/--
Create a new time index in an existing family.
Used for F/P (neg G/neg H) witnesses.
-/
def ModelSeed.createNewTime (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) : ModelSeed :=
  let newEntry : SeedEntry := { familyIdx := famIdx, timeIdx := timeIdx,
                                formulas := {phi}, entryType := .temporal_witness }
  { seed with entries := seed.entries ++ [newEntry] }

/--
Get all family indices in the seed.
-/
def ModelSeed.familyIndices (seed : ModelSeed) : List Nat :=
  seed.entries.map SeedEntry.familyIdx |>.eraseDups

/--
Get all time indices for a specific family.
-/
def ModelSeed.timeIndices (seed : ModelSeed) (famIdx : Nat) : List Int :=
  seed.entries.filter (fun e => e.familyIdx == famIdx)
              |>.map SeedEntry.timeIdx |>.eraseDups

/--
Check if a position exists in the seed.
-/
def ModelSeed.hasPosition (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) : Bool :=
  seed.entries.any (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx)

/--
If hasPosition is true, then findEntry returns some.
-/
theorem ModelSeed.hasPosition_iff_findEntry_isSome (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) :
    seed.hasPosition famIdx timeIdx = true ↔ (seed.findEntry famIdx timeIdx).isSome := by
  unfold hasPosition findEntry
  simp only [List.find?_isSome, List.any_eq_true]

/--
If hasPosition is true, then findEntry returns some entry.
-/
theorem ModelSeed.findEntry_some_of_hasPosition (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (h : seed.hasPosition famIdx timeIdx = true) :
    ∃ entry, seed.findEntry famIdx timeIdx = some entry := by
  rw [hasPosition_iff_findEntry_isSome] at h
  exact Option.isSome_iff_exists.mp h

/--
Get the number of entries in the seed.
-/
def ModelSeed.size (seed : ModelSeed) : Nat :=
  seed.entries.length

/-!
## Phase 2: Recursive Seed Builder

The core recursive function that builds a model seed from a formula.
-/

/--
Helper lemma: foldl max is monotone in the accumulator.
-/
theorem foldl_max_timeIdx_ge_acc {α : Type} (l : List α) (a : Int) (f : α → Int) :
    a ≤ List.foldl (fun acc e => max acc (f e)) a l := by
  induction l generalizing a with
  | nil => simp only [List.foldl_nil]; exact le_refl a
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    exact le_trans (le_max_left a (f hd)) (ih (max a (f hd)))

/--
Helper lemma: foldl max bounds any list element.
-/
theorem foldl_max_timeIdx_ge_mem {α : Type} (l : List α) (a : Int) (f : α → Int) (x : α)
    (h : x ∈ l) : f x ≤ List.foldl (fun acc e => max acc (f e)) a l := by
  induction l generalizing a with
  | nil => simp at h
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    rw [List.mem_cons] at h
    cases h with
    | inl h => subst h; exact le_trans (le_max_right a (f x)) (foldl_max_timeIdx_ge_acc tl (max a (f x)) f)
    | inr h => exact ih (max a (f hd)) h

/--
Helper lemma: foldl min is anti-monotone in the accumulator.
-/
theorem foldl_min_timeIdx_le_acc {α : Type} (l : List α) (a : Int) (f : α → Int) :
    List.foldl (fun acc e => min acc (f e)) a l ≤ a := by
  induction l generalizing a with
  | nil => simp only [List.foldl_nil]; exact le_refl a
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    exact le_trans (ih (min a (f hd))) (min_le_left a (f hd))

/--
Helper lemma: foldl min bounds any list element from below.
-/
theorem foldl_min_timeIdx_le_mem {α : Type} (l : List α) (a : Int) (f : α → Int) (x : α)
    (h : x ∈ l) : List.foldl (fun acc e => min acc (f e)) a l ≤ f x := by
  induction l generalizing a with
  | nil => simp at h
  | cons hd tl ih =>
    simp only [List.foldl_cons]
    rw [List.mem_cons] at h
    cases h with
    | inl h => subst h; exact le_trans (foldl_min_timeIdx_le_acc tl (min a (f x)) f) (min_le_right a (f x))
    | inr h => exact ih (min a (f hd)) h

/--
Compute a fresh time index for temporal witnesses.
For future witnesses (F phi = neg(G(neg phi))), we need a time greater than current.
For past witnesses (P phi = neg(H(neg phi))), we need a time less than current.
-/
def ModelSeed.freshFutureTime (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) : Int :=
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  let maxTime := familyEntries.foldl (fun acc e => max acc e.timeIdx) currentTime
  maxTime + 1

def ModelSeed.freshPastTime (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) : Int :=
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  let minTime := familyEntries.foldl (fun acc e => min acc e.timeIdx) currentTime
  minTime - 1

/--
freshFutureTime produces a time with no existing entry.
The returned time is greater than all existing times at famIdx.
-/
theorem ModelSeed.freshFutureTime_no_entry (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.findEntry famIdx (seed.freshFutureTime famIdx currentTime) = none := by
  unfold freshFutureTime findEntry
  rw [List.find?_eq_none]
  intro e he
  simp only [beq_iff_eq, Bool.and_eq_true, Bool.eq_false_iff, not_and, decide_eq_true_eq]
  intro h_fam
  -- e is in the filtered list since e.familyIdx = famIdx
  have h_in_filtered : e ∈ List.filter (fun e => e.familyIdx == famIdx) seed.entries := by
    rw [List.mem_filter]
    exact ⟨he, by simp [h_fam]⟩
  -- e.timeIdx is <= the max
  have h_le : e.timeIdx ≤ List.foldl (fun acc e => max acc e.timeIdx) currentTime
      (List.filter (fun e => e.familyIdx == famIdx) seed.entries) :=
    foldl_max_timeIdx_ge_mem _ _ _ e h_in_filtered
  -- max + 1 > e.timeIdx
  omega

/--
freshPastTime produces a time with no existing entry.
The returned time is less than all existing times at famIdx.
-/
theorem ModelSeed.freshPastTime_no_entry (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.findEntry famIdx (seed.freshPastTime famIdx currentTime) = none := by
  unfold freshPastTime findEntry
  rw [List.find?_eq_none]
  intro e he
  simp only [beq_iff_eq, Bool.and_eq_true, Bool.eq_false_iff, not_and, decide_eq_true_eq]
  intro h_fam
  -- e is in the filtered list since e.familyIdx = famIdx
  have h_in_filtered : e ∈ List.filter (fun e => e.familyIdx == famIdx) seed.entries := by
    rw [List.mem_filter]
    exact ⟨he, by simp [h_fam]⟩
  -- min is <= e.timeIdx
  have h_le : List.foldl (fun acc e => min acc e.timeIdx) currentTime
      (List.filter (fun e => e.familyIdx == famIdx) seed.entries) ≤ e.timeIdx :=
    foldl_min_timeIdx_le_mem _ _ _ e h_in_filtered
  -- min - 1 < e.timeIdx
  omega

/--
The recursive seed builder auxiliary function.

This function recursively unpacks a formula and builds seed entries:
- For atoms/bottom/implications: add to current position
- For Box phi: add Box phi to current, add phi to ALL families at current time, recurse
- For neg(Box phi): add neg(Box phi) to current, create NEW family with neg(phi), recurse
- For G phi: add G phi and phi to current, add phi to all FUTURE times in family, recurse
- For neg(G phi): add neg(G phi) to current, create NEW TIME with neg(phi), recurse
- For H phi: add H phi and phi to current, add phi to all PAST times in family, recurse
- For neg(H phi): add neg(H phi) to current, create NEW TIME with neg(phi), recurse

The function uses `Formula.complexity` as a decreasing measure for termination.
We pattern match directly on the formula structure to enable proper termination proofs.
-/
def buildSeedAux : Formula → Nat → Int → ModelSeed → ModelSeed
  | Formula.atom s, famIdx, timeIdx, seed =>
    seed.addFormula famIdx timeIdx (Formula.atom s) .universal_target
  | Formula.bot, famIdx, timeIdx, seed =>
    seed.addFormula famIdx timeIdx Formula.bot .universal_target
  | Formula.box psi, famIdx, timeIdx, seed =>
    -- Box psi: add Box psi to current, add psi to ALL families at current time, recurse
    let phi := Formula.box psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addToAllFamilies timeIdx psi
    buildSeedAux psi famIdx timeIdx seed2
  | Formula.all_future psi, famIdx, timeIdx, seed =>
    -- G psi: add G psi and psi to current, add psi to all future times, recurse
    let phi := Formula.all_future psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
    buildSeedAux psi famIdx timeIdx seed3
  | Formula.all_past psi, famIdx, timeIdx, seed =>
    -- H psi: add H psi and psi to current, add psi to all past times, recurse
    let phi := Formula.all_past psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllPastTimes famIdx timeIdx psi
    buildSeedAux psi famIdx timeIdx seed3
  -- Negated Box: neg(Box psi) = diamond(neg psi)
  | Formula.imp (Formula.box psi) Formula.bot, famIdx, timeIdx, seed =>
    let phi := Formula.neg (Formula.box psi)
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let (seed2, newFamIdx) := seed1.createNewFamily timeIdx (Formula.neg psi)
    buildSeedAux (Formula.neg psi) newFamIdx timeIdx seed2
  -- Negated G: neg(G psi) = F(neg psi)
  | Formula.imp (Formula.all_future psi) Formula.bot, famIdx, timeIdx, seed =>
    let phi := Formula.neg (Formula.all_future psi)
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let newTime := seed1.freshFutureTime famIdx timeIdx
    let seed2 := seed1.createNewTime famIdx newTime (Formula.neg psi)
    buildSeedAux (Formula.neg psi) famIdx newTime seed2
  -- Negated H: neg(H psi) = P(neg psi)
  | Formula.imp (Formula.all_past psi) Formula.bot, famIdx, timeIdx, seed =>
    let phi := Formula.neg (Formula.all_past psi)
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let newTime := seed1.freshPastTime famIdx timeIdx
    let seed2 := seed1.createNewTime famIdx newTime (Formula.neg psi)
    buildSeedAux (Formula.neg psi) famIdx newTime seed2
  -- Generic implication (including other negations)
  | Formula.imp psi1 psi2, famIdx, timeIdx, seed =>
    -- Just add the implication to current position
    seed.addFormula famIdx timeIdx (Formula.imp psi1 psi2) .universal_target
termination_by phi _ _ _ => phi.complexity
decreasing_by
  all_goals simp_wf
  all_goals simp only [Formula.complexity, Formula.neg]
  all_goals omega

/--
Build a complete model seed from a starting formula.

This is the entry point for seed construction:
1. Create initial seed with formula at (family 0, time 0)
2. Recursively unpack the formula to build the full seed

The resulting seed contains all formula-required witnesses BEFORE
any Lindenbaum extension, avoiding the cross-sign propagation problem.
-/
def buildSeed (phi : Formula) : ModelSeed :=
  let initialSeed := ModelSeed.initial phi
  buildSeedAux phi 0 0 initialSeed

/--
Family 0 is always in the initial seed's familyIndices.
-/
theorem initial_has_family_zero (phi : Formula) :
    0 ∈ (ModelSeed.initial phi).familyIndices := by
  simp only [ModelSeed.initial, ModelSeed.familyIndices, List.map, List.eraseDups]
  decide

/-!
## Helper lemmas for family index preservation
-/

/-- Membership in eraseDups of appended lists preserves membership from left. -/
private theorem mem_eraseDups_append_left {α : Type*} [BEq α] [LawfulBEq α] {a : α} {l1 l2 : List α}
    (h : a ∈ l1.eraseDups) : a ∈ (l1 ++ l2).eraseDups := by
  rw [List.eraseDups_append]; exact List.mem_append_left _ h

/-- addFormula preserves family indices. -/
private theorem addFormula_preserves_familyIndices' (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (newType : SeedEntryType) (idx : Nat)
    (h_in : idx ∈ seed.familyIndices) : idx ∈ (seed.addFormula famIdx timeIdx phi newType).familyIndices := by
  unfold ModelSeed.familyIndices at *; unfold ModelSeed.addFormula
  cases h_match : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | some i =>
    have h_modify_pres : (seed.entries.modify i
        (fun e => { e with formulas := insert phi e.formulas })).map SeedEntry.familyIdx =
        seed.entries.map SeedEntry.familyIdx := by
      apply List.ext_getElem; simp only [List.length_map, List.length_modify]
      intro n h1 h2; simp only [List.getElem_map, List.getElem_modify]; split <;> rfl
    simp only [h_modify_pres]; exact h_in
  | none => simp only [List.map_append, List.map_cons, List.map_nil]; exact mem_eraseDups_append_left h_in

/-- foldl with addFormula over family indices preserves family indices. -/
private theorem foldl_addFormula_fam_preserves (phi : Formula) (ty : SeedEntryType) (timeIdx : Int)
    (fams : List Nat) (seed : ModelSeed) (idx : Nat)
    (h_in : idx ∈ seed.familyIndices) :
    idx ∈ (fams.foldl (fun s f => s.addFormula f timeIdx phi ty) seed).familyIndices := by
  induction fams generalizing seed with
  | nil => exact h_in
  | cons f fs ih => simp only [List.foldl_cons]; apply ih
                    exact addFormula_preserves_familyIndices' seed f timeIdx phi ty idx h_in

/-- foldl with addFormula over time indices preserves family indices. -/
private theorem foldl_addFormula_times_preserves (phi : Formula) (famIdx : Nat)
    (times : List Int) (seed : ModelSeed) (idx : Nat)
    (h_in : idx ∈ seed.familyIndices) :
    idx ∈ (times.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed).familyIndices := by
  induction times generalizing seed with
  | nil => exact h_in
  | cons t ts ih => simp only [List.foldl_cons]; apply ih
                    exact addFormula_preserves_familyIndices' seed famIdx t phi .universal_target idx h_in

/-- addToAllFamilies preserves family indices. -/
private theorem addToAllFamilies_preserves_familyIndices' (seed : ModelSeed) (timeIdx : Int)
    (phi : Formula) (idx : Nat) (h : idx ∈ seed.familyIndices) :
    idx ∈ (seed.addToAllFamilies timeIdx phi).familyIndices := by
  unfold ModelSeed.addToAllFamilies
  exact foldl_addFormula_fam_preserves phi .universal_target timeIdx _ seed idx h

/-- addToAllFutureTimes preserves family indices. -/
private theorem addToAllFutureTimes_preserves_familyIndices' (seed : ModelSeed) (famIdx : Nat)
    (t : Int) (phi : Formula) (idx : Nat) (h : idx ∈ seed.familyIndices) :
    idx ∈ (seed.addToAllFutureTimes famIdx t phi).familyIndices := by
  unfold ModelSeed.addToAllFutureTimes
  exact foldl_addFormula_times_preserves phi famIdx _ seed idx h

/-- addToAllPastTimes preserves family indices. -/
private theorem addToAllPastTimes_preserves_familyIndices' (seed : ModelSeed) (famIdx : Nat)
    (t : Int) (phi : Formula) (idx : Nat) (h : idx ∈ seed.familyIndices) :
    idx ∈ (seed.addToAllPastTimes famIdx t phi).familyIndices := by
  unfold ModelSeed.addToAllPastTimes
  exact foldl_addFormula_times_preserves phi famIdx _ seed idx h

/-- createNewFamily preserves family indices. -/
private theorem createNewFamily_preserves_familyIndices' (seed : ModelSeed) (t : Int)
    (phi : Formula) (idx : Nat) (h : idx ∈ seed.familyIndices) :
    idx ∈ (seed.createNewFamily t phi).1.familyIndices := by
  unfold ModelSeed.createNewFamily ModelSeed.familyIndices at *
  simp only [List.map_append, List.map_cons, List.map_nil]
  exact mem_eraseDups_append_left h

/-- createNewTime preserves family indices. -/
private theorem createNewTime_preserves_familyIndices' (seed : ModelSeed) (f : Nat) (t : Int)
    (phi : Formula) (idx : Nat) (h : idx ∈ seed.familyIndices) :
    idx ∈ (seed.createNewTime f t phi).familyIndices := by
  unfold ModelSeed.createNewTime ModelSeed.familyIndices at *
  simp only [List.map_append, List.map_cons, List.map_nil]
  exact mem_eraseDups_append_left h

/--
buildSeedAux preserves family indices (only adds new families, never removes).
-/
theorem buildSeedAux_preserves_familyIndices (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (idx : Nat) :
    idx ∈ seed.familyIndices → idx ∈ (buildSeedAux phi famIdx timeIdx seed).familyIndices := by
  -- Use strong induction on formula complexity to match the recursion pattern of buildSeedAux
  generalize h_c : phi.complexity = c
  induction c using Nat.strong_induction_on generalizing phi famIdx timeIdx seed with
  | h c ih =>
    intro h_in
    -- Case split on the formula structure
    match phi with
    | Formula.atom s =>
      simp only [buildSeedAux]
      exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.atom s) .universal_target idx h_in
    | Formula.bot =>
      simp only [buildSeedAux]
      exact addFormula_preserves_familyIndices' seed famIdx timeIdx .bot .universal_target idx h_in
    | Formula.box psi =>
      simp only [buildSeedAux]
      have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.box psi) .universal_target idx h_in
      have h2 := addToAllFamilies_preserves_familyIndices' _ timeIdx psi idx h1
      have h_lt : psi.complexity < c := by rw [← h_c]; simp [Formula.complexity]
      exact ih psi.complexity h_lt psi famIdx timeIdx _ rfl h2
    | Formula.all_future psi =>
      simp only [buildSeedAux]
      have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.all_future psi) .universal_target idx h_in
      have h2 := addFormula_preserves_familyIndices' _ famIdx timeIdx psi .universal_target idx h1
      have h3 := addToAllFutureTimes_preserves_familyIndices' _ famIdx timeIdx psi idx h2
      have h_lt : psi.complexity < c := by rw [← h_c]; simp [Formula.complexity]
      exact ih psi.complexity h_lt psi famIdx timeIdx _ rfl h3
    | Formula.all_past psi =>
      simp only [buildSeedAux]
      have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.all_past psi) .universal_target idx h_in
      have h2 := addFormula_preserves_familyIndices' _ famIdx timeIdx psi .universal_target idx h1
      have h3 := addToAllPastTimes_preserves_familyIndices' _ famIdx timeIdx psi idx h2
      have h_lt : psi.complexity < c := by rw [← h_c]; simp [Formula.complexity]
      exact ih psi.complexity h_lt psi famIdx timeIdx _ rfl h3
    | Formula.imp psi1 psi2 =>
      -- The imp case has several subcases depending on psi1 and psi2
      -- We need to match the pattern matching structure of buildSeedAux
      match psi1, psi2 with
      | Formula.box inner, Formula.bot =>
        -- Case: neg(Box inner) = imp (box inner) bot, recurses on neg inner = inner.imp bot
        simp only [buildSeedAux]
        have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.neg (.box inner)) .universal_target idx h_in
        have h2 := createNewFamily_preserves_familyIndices' _ timeIdx (Formula.neg inner) idx h1
        have h_lt : (Formula.neg inner).complexity < c := by
          rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
        exact ih (Formula.neg inner).complexity h_lt (Formula.neg inner) _ timeIdx _ rfl h2
      | Formula.all_future inner, Formula.bot =>
        -- Case: neg(G inner) = imp (all_future inner) bot
        simp only [buildSeedAux]
        let seed1 := seed.addFormula famIdx timeIdx (.neg (.all_future inner)) .universal_target
        let newTime := seed1.freshFutureTime famIdx timeIdx
        have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.neg (.all_future inner)) .universal_target idx h_in
        have h2 := createNewTime_preserves_familyIndices' seed1 famIdx newTime (Formula.neg inner) idx h1
        have h_lt : (Formula.neg inner).complexity < c := by
          rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
        exact ih (Formula.neg inner).complexity h_lt (Formula.neg inner) famIdx newTime _ rfl h2
      | Formula.all_past inner, Formula.bot =>
        -- Case: neg(H inner) = imp (all_past inner) bot
        simp only [buildSeedAux]
        let seed1 := seed.addFormula famIdx timeIdx (.neg (.all_past inner)) .universal_target
        let newTime := seed1.freshPastTime famIdx timeIdx
        have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.neg (.all_past inner)) .universal_target idx h_in
        have h2 := createNewTime_preserves_familyIndices' seed1 famIdx newTime (Formula.neg inner) idx h1
        have h_lt : (Formula.neg inner).complexity < c := by
          rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
        exact ih (Formula.neg inner).complexity h_lt (Formula.neg inner) famIdx newTime _ rfl h2
      | Formula.atom s, Formula.bot =>
        -- Generic negation case (psi1 is atom)
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp (.atom s) .bot) .universal_target idx h_in
      | Formula.bot, Formula.bot =>
        -- Generic negation case (psi1 is bot)
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp .bot .bot) .universal_target idx h_in
      | Formula.imp a b, Formula.bot =>
        -- Generic negation case (psi1 is imp)
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp (.imp a b) .bot) .universal_target idx h_in
      | p1, Formula.atom s =>
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp p1 (.atom s)) .universal_target idx h_in
      | p1, Formula.box inner =>
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp p1 (.box inner)) .universal_target idx h_in
      | p1, Formula.all_future inner =>
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp p1 (.all_future inner)) .universal_target idx h_in
      | p1, Formula.all_past inner =>
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp p1 (.all_past inner)) .universal_target idx h_in
      | p1, Formula.imp a b =>
        simp only [buildSeedAux]
        exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.imp p1 (.imp a b)) .universal_target idx h_in

/--
Family 0 is in buildSeed's familyIndices.
-/
theorem buildSeed_has_family_zero (phi : Formula) :
    0 ∈ (buildSeed phi).familyIndices := by
  unfold buildSeed
  apply buildSeedAux_preserves_familyIndices
  exact initial_has_family_zero phi

/-!
## Seed Builder Tests
-/

-- Test building a simple atom seed
#reduce (buildSeed (Formula.atom "p")).entries.length

-- Test building a Box seed (should create entry with phi at same position)
#reduce (buildSeed (Formula.box (Formula.atom "p"))).entries.length

-- Test building a diamond seed (should create a new family)
#reduce (buildSeed (Formula.neg (Formula.box (Formula.atom "p")))).familyIndices

-- Test building a G seed
#reduce (buildSeed (Formula.all_future (Formula.atom "p"))).entries.length

-- Test building an F seed (neg G) - should create new time
#reduce (buildSeed (Formula.neg (Formula.all_future (Formula.atom "p")))).timeIndices 0

/-!
## Classification Tests

Quick tests to verify classifyFormula works correctly.
-/

#check classifyFormula (Formula.atom "p")
#check classifyFormula Formula.bot
#check classifyFormula (Formula.box (Formula.atom "p"))
#check classifyFormula (Formula.neg (Formula.box (Formula.atom "p")))
#check classifyFormula (Formula.all_future (Formula.atom "p"))
#check classifyFormula (Formula.neg (Formula.all_future (Formula.atom "p")))

-- Verify classification produces expected results
example : classifyFormula (Formula.atom "p") = FormulaClass.atomic "p" := rfl
example : classifyFormula Formula.bot = FormulaClass.bottom := rfl
example : classifyFormula (Formula.box (Formula.atom "p")) =
    FormulaClass.boxPositive (Formula.atom "p") := rfl

-- Note: Formula.neg is defined as phi.imp bot
example : classifyFormula (Formula.neg (Formula.box (Formula.atom "p"))) =
    FormulaClass.boxNegative (Formula.atom "p") := rfl
example : classifyFormula (Formula.neg (Formula.all_future (Formula.atom "p"))) =
    FormulaClass.futureNegative (Formula.atom "p") := rfl
example : classifyFormula (Formula.neg (Formula.all_past (Formula.atom "p"))) =
    FormulaClass.pastNegative (Formula.atom "p") := rfl

-- Implication that is not a negation
example : classifyFormula ((Formula.atom "p").imp (Formula.atom "q")) =
    FormulaClass.implication (Formula.atom "p") (Formula.atom "q") := rfl

-- Generic negation (not a special operator)
example : classifyFormula (Formula.neg (Formula.atom "p")) =
    FormulaClass.negation (Formula.atom "p") := rfl

/-!
## Phase 3: Seed Consistency Proof

We prove that if the starting formula is consistent, then every entry in the
seed is consistent. This is the mathematically hardest part of the construction.

### Key Insight

The diamond-box interaction lemma is the KEY LEMMA:
When Box phi and neg(Box psi) are jointly consistent in the parent family,
{phi, neg psi} is consistent in the witness family.

### Invariants

At each recursive step, for each (family, time) entry:
1. If it's a temporal_witness entry: contains singleton {witness_formula}
2. If it's a universal_target entry: contains formulas derivable from parent + universal additions
3. Cross-family Box additions: {phi, neg psi} consistent by diamond-box interaction lemma
-/

/--
A seed is consistent if every entry's formula set is SetConsistent.
-/
def SeedConsistent (seed : ModelSeed) : Prop :=
  ∀ entry ∈ seed.entries, SetConsistent entry.formulas

/--
A seed is well-formed if structural invariants hold:
- Unique entries per (family, time)
- Valid family indices (all < nextFamilyIdx)
- No duplicate entries in the list
-/
def SeedWellFormed (seed : ModelSeed) : Prop :=
  -- All family indices are valid
  (∀ entry ∈ seed.entries, entry.familyIdx < seed.nextFamilyIdx) ∧
  -- Entries at different positions in the list with same (family, time) are merged
  (∀ ei ∈ seed.entries, ∀ ej ∈ seed.entries, ei ≠ ej →
    ¬(ei.familyIdx = ej.familyIdx ∧ ei.timeIdx = ej.timeIdx)) ∧
  -- No duplicate entries in the list
  List.Nodup seed.entries

/--
Formula consistency: a formula is consistent if it is not derivable to bot.
-/
def FormulaConsistent (phi : Formula) : Prop :=
  ¬∃ (d : Bimodal.ProofSystem.DerivationTree [phi] Formula.bot), True

/--
Singleton set consistency: a singleton set {phi} is consistent iff phi is consistent.
-/
theorem singleton_consistent_iff {phi : Formula} :
    SetConsistent {phi} ↔ FormulaConsistent phi := by
  constructor
  · intro h_set h_formula
    obtain ⟨d, _⟩ := h_formula
    -- Build SetConsistent contradiction
    unfold SetConsistent at h_set
    have h := h_set [phi] (by simp)
    unfold Consistent at h
    exact h ⟨d⟩
  · intro h_formula L hL
    unfold Consistent
    intro ⟨d⟩
    apply h_formula
    -- If L ⊆ {phi} derives bot, then [phi] derives bot
    have h_sub : ∀ ψ ∈ L, ψ ∈ [phi] := by
      intro ψ hψ
      have := Set.mem_singleton_iff.mp (hL ψ hψ)
      simp [this]
    -- Weaken: since all elements of L are in [phi], we can weaken to [phi]
    have d' : Bimodal.ProofSystem.DerivationTree [phi] Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.weakening L [phi] Formula.bot d h_sub
    exact ⟨d', trivial⟩

/--
Initial seed consistency: if phi is consistent, then the initial seed is consistent.
-/
theorem initialSeedConsistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (ModelSeed.initial phi) := by
  intro entry h_entry
  simp only [ModelSeed.initial] at h_entry
  simp only [List.mem_singleton] at h_entry
  rw [h_entry]
  simp only
  -- entry.formulas = {phi}
  exact singleton_consistent_iff.mpr h_cons

/--
Initial seed well-formedness: the initial seed has unique entries per position.
-/
theorem initialSeedWellFormed (phi : Formula) :
    SeedWellFormed (ModelSeed.initial phi) := by
  refine ⟨?_, ?_, ?_⟩
  · -- All family indices are valid (< nextFamilyIdx)
    intro entry h_entry
    simp only [ModelSeed.initial] at h_entry
    simp only [List.mem_singleton] at h_entry
    rw [h_entry]
    simp only [ModelSeed.initial]
    omega
  · -- No duplicate positions
    intro ei h_ei ej h_ej h_ne
    simp only [ModelSeed.initial, List.mem_singleton] at h_ei h_ej
    rw [h_ei, h_ej] at h_ne
    exact absurd rfl h_ne
  · -- List.Nodup
    simp only [ModelSeed.initial, List.nodup_singleton]

/--
Adding a formula derivable from existing formulas preserves consistency.

If S is consistent, and phi is derivable from formulas in S, then S ∪ {phi} is consistent.
Actually, this is not quite right - we need the stronger statement that
if phi is a theorem, then adding it preserves consistency.
-/
theorem addFormula_preserves_consistent_of_theorem {S : Set Formula} {phi : Formula}
    (h_cons : SetConsistent S)
    (h_thm : ∃ d : Bimodal.ProofSystem.DerivationTree [] phi, True) :
    SetConsistent (insert phi S) := by
  intro L hL
  unfold Consistent
  intro ⟨d⟩
  -- If L ⊆ insert phi S derives bot, need to show contradiction
  -- Key insight: if phi ∉ L, then L ⊆ S, contradicting S consistent
  -- If phi ∈ L, we can use the theorem proof to eliminate phi from the derivation
  by_cases h_phi_in_L : phi ∈ L
  · -- phi ∈ L: use the theorem to replace phi
    -- L ⊢ ⊥ and phi is a theorem means we can derive ⊥ from L \ {phi}
    -- Actually, since phi is a theorem, removing it doesn't change consistency
    -- We have L ⊢ ⊥. Let L' = L.filter (· ≠ phi)
    -- We can show L' ⊢ ⊥ by weakening from [] ⊢ phi
    -- No wait, that's not right. We need to show S is inconsistent.
    -- Actually, the issue is that L ⊆ insert phi S, so L \ {phi} ⊆ S
    -- And from L ⊢ ⊥ with phi being a theorem, we get L' ⊢ ⊥
    -- where L' = L \ {phi} ⊆ S
    -- The key is: if [] ⊢ phi and L ⊢ ⊥, then L.filter(· ≠ phi) ⊢ ⊥
    -- This is because we can replace assumptions of phi with the theorem proof
    obtain ⟨d_thm, _⟩ := h_thm
    -- Let L' = L \ {phi}
    let L' := L.filter (· ≠ phi)
    -- L' ⊆ S since L ⊆ insert phi S and we removed phi
    have h_L'_sub : ∀ ψ ∈ L', ψ ∈ S := by
      intro ψ hψ
      have h_mem := List.mem_filter.mp hψ
      have h_in_L := h_mem.1
      have h_ne : ψ ≠ phi := by simpa using h_mem.2
      have := hL ψ h_in_L
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq h_ne
      | inr h_in_S => exact h_in_S
    -- We need to show L' ⊢ ⊥, which gives a contradiction with S consistent
    -- From L ⊢ ⊥ and [] ⊢ phi, we can construct L' ⊢ ⊥
    -- This is because any assumption of phi in L can be replaced with the theorem
    -- The idea: weaken d_thm to L' ⊢ phi, then use it wherever phi was assumed
    -- Actually, this requires a proper "cut elimination" style argument
    -- Simpler: weaken L' to L' ++ [phi] which is "similar" to L
    -- We need: L' ++ [phi] has same elements as L (since phi ∈ L and L' = L \ {phi})
    -- Then weaken d : L ⊢ ⊥ to L' ++ [phi] ⊢ ⊥ won't work directly
    -- Instead: from L ⊢ ⊥ and phi ∈ L, by deduction theorem: L' ⊢ phi → ⊥
    -- But we also have [] ⊢ phi, so L' ⊢ phi (by weakening)
    -- By modus ponens: L' ⊢ ⊥
    -- However, this assumes L' = L with phi at front, which isn't quite right
    -- Let me use the deduction_with_mem approach
    -- Actually, let's use the perm approach: L has same elements as phi :: L'
    have h_perm : ∀ x, x ∈ L ↔ x ∈ phi :: L' := by
      intro x
      constructor
      · intro hx
        by_cases h_eq : x = phi
        · simp only [List.mem_cons, h_eq, true_or]
        · simp only [List.mem_cons]
          right
          exact List.mem_filter.mpr ⟨hx, by simpa using h_eq⟩
      · intro hx
        simp only [List.mem_cons] at hx
        cases hx with
        | inl h_eq => exact h_eq ▸ h_phi_in_L
        | inr h_in_L' =>
          have h_mem := List.mem_filter.mp h_in_L'
          exact h_mem.1
    -- Exchange: phi :: L' ⊢ ⊥
    have d_reord : Bimodal.ProofSystem.DerivationTree (phi :: L') Formula.bot := by
      apply Bimodal.ProofSystem.DerivationTree.weakening L (phi :: L') Formula.bot d
      intro x hx
      exact (h_perm x).mp hx
    -- By deduction theorem: L' ⊢ phi → ⊥ = L' ⊢ phi.neg
    have d_neg : Bimodal.ProofSystem.DerivationTree L' phi.neg :=
      Bimodal.Metalogic.Core.deduction_theorem L' phi Formula.bot d_reord
    -- Weaken the theorem: L' ⊢ phi
    have d_phi : Bimodal.ProofSystem.DerivationTree L' phi :=
      Bimodal.ProofSystem.DerivationTree.weakening [] L' phi d_thm (List.nil_subset L')
    -- Modus ponens: L' ⊢ ⊥
    have d_bot_L' : Bimodal.ProofSystem.DerivationTree L' Formula.bot :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens L' phi Formula.bot d_neg d_phi
    -- This contradicts S being consistent
    exact h_cons L' h_L'_sub ⟨d_bot_L'⟩
  · -- phi ∉ L: L ⊆ S directly
    have h_L_sub : ∀ ψ ∈ L, ψ ∈ S := by
      intro ψ hψ
      have := hL ψ hψ
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h => h_phi_in_L (h ▸ hψ))
      | inr h_in_S => exact h_in_S
    exact h_cons L h_L_sub ⟨d⟩

/--
The diamond-box interaction consistency lemma.

When Box phi and neg(Box psi) are jointly consistent (both in a consistent set S),
then {phi, neg psi} is consistent.

Proof outline:
1. Assume {phi, neg psi} is inconsistent, i.e., phi |- psi
2. By necessitation: Box phi |- Box psi
3. With neg(Box psi) in S, this contradicts S being consistent
-/
theorem diamond_box_interaction {S : Set Formula} {phi psi : Formula}
    (h_cons : SetConsistent S)
    (h_box : Formula.box phi ∈ S)
    (h_neg_box : Formula.neg (Formula.box psi) ∈ S) :
    SetConsistent {phi, Formula.neg psi} := by
  -- By contraposition: if {phi, neg psi} inconsistent, then S inconsistent
  by_contra h_incons
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, hL_sub, hL_incons⟩ := h_incons
  unfold Consistent at hL_incons
  push_neg at hL_incons
  obtain ⟨d_bot⟩ := hL_incons
  -- L ⊆ {phi, neg psi} and L ⊢ ⊥
  -- First, weaken L ⊢ ⊥ to [psi.neg, phi] ⊢ ⊥
  -- Note: deduction_theorem expects [A, ...Gamma] where A is the formula to abstract
  have h_L_subset : L ⊆ [psi.neg, phi] := by
    intro x hx
    have := hL_sub x hx
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at this
    cases this with
    | inl h => simp [h]
    | inr h => simp [h]
  have d_bot_full : Bimodal.ProofSystem.DerivationTree [psi.neg, phi] Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.weakening L [psi.neg, phi] Formula.bot d_bot h_L_subset
  -- By deduction theorem: [phi] ⊢ psi.neg → ⊥
  have d_neg_neg_psi : Bimodal.ProofSystem.DerivationTree [phi] (psi.neg.neg) :=
    Bimodal.Metalogic.Core.deduction_theorem [phi] psi.neg Formula.bot d_bot_full
  -- psi.neg.neg = (psi → ⊥) → ⊥ = double negation of psi
  -- We need to derive psi from psi.neg.neg using double negation elimination
  -- First, apply deduction again: [] ⊢ phi → psi.neg.neg
  have d_phi_imp : Bimodal.ProofSystem.DerivationTree [] (phi.imp psi.neg.neg) :=
    Bimodal.Metalogic.Core.deduction_theorem [] phi psi.neg.neg d_neg_neg_psi
  -- By necessitation: [] ⊢ Box(phi → psi.neg.neg)
  have d_box_imp : Bimodal.ProofSystem.DerivationTree [] (phi.imp psi.neg.neg).box :=
    Bimodal.ProofSystem.DerivationTree.necessitation _ d_phi_imp
  -- By modal_k_dist: Box(phi → psi.neg.neg) → (Box phi → Box psi.neg.neg)
  have d_k_dist : Bimodal.ProofSystem.DerivationTree [] ((phi.imp psi.neg.neg).box.imp (phi.box.imp psi.neg.neg.box)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_k_dist phi psi.neg.neg)
  -- Modus ponens: [] ⊢ Box phi → Box psi.neg.neg
  have d_box_phi_imp : Bimodal.ProofSystem.DerivationTree [] (phi.box.imp psi.neg.neg.box) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ d_k_dist d_box_imp
  -- Now we have Box phi ∈ S, so we can derive Box psi.neg.neg
  -- We need to show S is inconsistent
  -- Since Box phi ∈ S and we have Box phi → Box (psi.neg.neg)
  -- We can derive Box (psi.neg.neg) from S
  -- But we also have neg(Box psi) ∈ S
  -- We need: Box (psi.neg.neg) → Box psi, then S derives Box psi and neg(Box psi)
  -- Actually, we need double negation elimination inside Box
  -- By modal_5 and related S5 properties, Box psi.neg.neg ↔ Box psi in S5
  -- Let's use the DNE theorem: psi.neg.neg → psi
  have d_dne : Bimodal.ProofSystem.DerivationTree [] (psi.neg.neg.imp psi) := by
    -- DNE is derivable from Peirce's law and ex_falso
    -- We use the standard derivation
    -- Peirce: ((psi → ⊥) → psi) → psi
    -- We have psi.neg.neg = (psi → ⊥) → ⊥
    -- Need: ((psi → ⊥) → ⊥) → psi
    -- Let A = psi.neg = psi → ⊥, B = ⊥
    -- Need: (A → ⊥) → psi, i.e., A.neg → psi
    -- From Peirce: ((psi → ⊥) → psi) → psi
    -- If we can show (A → ⊥) → ((psi → ⊥) → psi), we can compose
    -- (A → ⊥) means ((psi → ⊥) → ⊥)
    -- We need: ((psi → ⊥) → ⊥) → ((psi → ⊥) → psi)
    -- By ex_falso: ⊥ → psi
    -- So if (psi → ⊥) → ⊥, and we have ⊥ → psi, we can show (psi → ⊥) → psi
    -- Actually, we need: from psi.neg.neg and psi.neg, derive psi
    -- Hmm, this is getting complex. Let's use a different approach.
    -- Use the theorem_in_mcs approach: if DNE is a theorem, we can use it
    -- The standard DNE proof from Peirce:
    have peirce : Bimodal.ProofSystem.DerivationTree [] (((psi.imp psi.neg).imp psi).imp psi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.peirce psi psi.neg)
    -- We need: psi.neg.neg → (psi.neg → psi)
    -- psi.neg.neg = (psi → ⊥) → ⊥
    -- psi.neg → psi = (psi → ⊥) → psi
    -- By ex_falso applied: ⊥ → psi
    have ex_falso_psi : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp psi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso psi)
    -- We want: psi.neg.neg → psi
    -- From (⊥ → psi) we can get ((psi → ⊥) → ⊥) → psi
    -- Using B combinator: (⊥ → psi) → ((psi → ⊥) → ⊥) → ((psi → ⊥) → psi)
    -- But we need the final step to psi
    -- Actually simpler: use Peirce directly
    -- Peirce says: ((psi → anything) → psi) → psi
    -- If we can derive (psi.neg → psi) from psi.neg.neg, then we get psi
    -- From psi.neg.neg and psi.neg we can derive ⊥ (modus ponens)
    -- From ⊥ we can derive psi (ex_falso)
    -- So psi.neg.neg → (psi.neg → psi)
    -- Actually we want psi.neg.neg → ((psi → q) → psi) for Peirce
    -- Let's work in context [psi.neg.neg]
    -- Have psi.neg.neg
    -- Assume psi.neg, derive psi:
    --   From psi.neg.neg and psi.neg, MP gives ⊥
    --   From ⊥, ex_falso gives psi
    -- So [psi.neg.neg] ⊢ psi.neg → psi
    -- By deduction: [] ⊢ psi.neg.neg → (psi.neg → psi)
    -- But we want [] ⊢ psi.neg.neg → psi directly
    -- Use Peirce: ((psi.neg → psi) → psi) → psi
    -- Hmm wait, Peirce is: ((A → B) → A) → A
    -- With A = psi, B = psi.neg: ((psi → psi.neg) → psi) → psi
    -- Not quite right. Let me reconsider.
    -- The standard DNE proof: psi.neg.neg → psi
    -- In context [psi.neg.neg, psi.neg]:
    --   psi.neg.neg : (psi → ⊥) → ⊥
    --   psi.neg : psi → ⊥
    --   MP: ⊥
    --   ex_falso: psi
    -- So [psi.neg.neg, psi.neg] ⊢ psi
    -- By deduction: [psi.neg.neg] ⊢ psi.neg → psi
    -- But Peirce: ((psi → ⊥) → psi) → psi
    -- So if we have psi.neg → psi, and that's (psi → ⊥) → psi, Peirce gives psi
    -- In context [psi.neg.neg]:
    --   Have psi.neg → psi (from above)
    --   Peirce instance: ((psi → ⊥) → psi) → psi
    --   MP: psi
    -- By deduction: [] ⊢ psi.neg.neg → psi
    -- Let's implement this step by step
    -- First: [psi.neg, psi.neg.neg] ⊢ psi
    -- Note: context order matters for deduction_theorem - first element is abstracted
    have step1 : Bimodal.ProofSystem.DerivationTree [psi.neg, psi.neg.neg] psi := by
      have h_neg_neg : Bimodal.ProofSystem.DerivationTree [psi.neg, psi.neg.neg] psi.neg.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_neg : Bimodal.ProofSystem.DerivationTree [psi.neg, psi.neg.neg] psi.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_bot : Bimodal.ProofSystem.DerivationTree [psi.neg, psi.neg.neg] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_neg h_neg
      have h_ex_falso : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp psi) :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso psi)
      have h_ex_falso' : Bimodal.ProofSystem.DerivationTree [psi.neg, psi.neg.neg] (Formula.bot.imp psi) :=
        Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_ex_falso (by intro; simp)
      exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_ex_falso' h_bot
    -- [psi.neg.neg] ⊢ psi.neg → psi
    have step2 : Bimodal.ProofSystem.DerivationTree [psi.neg.neg] (psi.neg.imp psi) :=
      Bimodal.Metalogic.Core.deduction_theorem [psi.neg.neg] psi.neg psi step1
    -- psi.neg = psi.imp Formula.bot, so psi.neg.imp psi = (psi.imp Formula.bot).imp psi
    -- Peirce: (((psi.imp Formula.bot).imp psi).imp psi)
    have step3_peirce : Bimodal.ProofSystem.DerivationTree [] ((psi.neg.imp psi).imp psi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.peirce psi Formula.bot)
    have step3_peirce' : Bimodal.ProofSystem.DerivationTree [psi.neg.neg] ((psi.neg.imp psi).imp psi) :=
      Bimodal.ProofSystem.DerivationTree.weakening [] _ _ step3_peirce (by intro; simp)
    have step3 : Bimodal.ProofSystem.DerivationTree [psi.neg.neg] psi :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ step3_peirce' step2
    exact Bimodal.Metalogic.Core.deduction_theorem [] psi.neg.neg psi step3
  -- Now use necessitation on DNE: [] ⊢ Box(psi.neg.neg → psi)
  have d_box_dne : Bimodal.ProofSystem.DerivationTree [] (psi.neg.neg.imp psi).box :=
    Bimodal.ProofSystem.DerivationTree.necessitation _ d_dne
  -- K-dist on DNE: Box(psi.neg.neg → psi) → (Box psi.neg.neg → Box psi)
  have d_k_dist_dne : Bimodal.ProofSystem.DerivationTree [] ((psi.neg.neg.imp psi).box.imp (psi.neg.neg.box.imp psi.box)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_k_dist psi.neg.neg psi)
  -- Modus ponens: [] ⊢ Box psi.neg.neg → Box psi
  have d_box_neg_neg_imp_box : Bimodal.ProofSystem.DerivationTree [] (psi.neg.neg.box.imp psi.box) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ d_k_dist_dne d_box_dne
  -- Compose: [] ⊢ Box phi → Box psi
  -- We have: Box phi → Box psi.neg.neg and Box psi.neg.neg → Box psi
  have d_box_phi_imp_box_psi : Bimodal.ProofSystem.DerivationTree [] (phi.box.imp psi.box) :=
    Bimodal.Theorems.Combinators.imp_trans d_box_phi_imp d_box_neg_neg_imp_box
  -- Now show S is inconsistent
  -- We have Box phi ∈ S, and [] ⊢ Box phi → Box psi
  -- By closure, Box psi ∈ S (or we derive it)
  -- But neg(Box psi) ∈ S, contradiction
  -- Use h_cons to derive a contradiction
  -- Build L' = [Box phi, Box phi → Box psi, neg(Box psi)]
  -- From this L' we can derive ⊥, and L' ⊆ S (after weakening theorem)
  -- Actually simpler: [Box phi, neg(Box psi)] ⊢ ⊥
  have d_incons : Bimodal.ProofSystem.DerivationTree [phi.box, psi.box.neg] Formula.bot := by
    have h_box_phi : Bimodal.ProofSystem.DerivationTree [phi.box, psi.box.neg] phi.box :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    have h_neg_box_psi : Bimodal.ProofSystem.DerivationTree [phi.box, psi.box.neg] psi.box.neg :=
      Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
    have h_imp : Bimodal.ProofSystem.DerivationTree [phi.box, psi.box.neg] (phi.box.imp psi.box) :=
      Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_box_phi_imp_box_psi (by intro; simp)
    have h_box_psi : Bimodal.ProofSystem.DerivationTree [phi.box, psi.box.neg] psi.box :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_imp h_box_phi
    -- neg(Box psi) = Box psi → ⊥
    exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_box_psi h_box_psi
  -- Now apply h_cons with L' = [Box phi, neg(Box psi)]
  have h_L'_sub : ∀ ψ ∈ [phi.box, psi.box.neg], ψ ∈ S := by
    intro ψ hψ
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
    cases hψ with
    | inl h => exact h ▸ h_box
    | inr h => exact h ▸ h_neg_box
  exact h_cons [phi.box, psi.box.neg] h_L'_sub ⟨d_incons⟩

/--
Invariant for seed consistency proof.

At each step of buildSeedAux, we maintain:
1. All existing entries in the seed are consistent
2. The "current" entry at (famIdx, timeIdx) contains formulas derivable from phi
3. New witness entries contain singleton sets which are consistent
-/
structure SeedConsistentInvariant (seed : ModelSeed) (phi : Formula) (famIdx : Nat) (timeIdx : Int) : Prop where
  /-- All entries in the seed are consistent -/
  entries_consistent : SeedConsistent seed
  /-- The current position has formulas all derivable from the root formula -/
  current_derivable : ∀ ψ ∈ seed.getFormulas famIdx timeIdx, ∃ d : Bimodal.ProofSystem.DerivationTree [phi] ψ, True

/--
Helper: adding a formula to an existing consistent entry preserves consistency
if the formula is derivable from the entry's formulas.
-/
theorem addFormula_preserves_consistent {S : Set Formula} {phi : Formula}
    (h_cons : SetConsistent S)
    (h_deriv : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ S) ∧ Nonempty (Bimodal.ProofSystem.DerivationTree L phi)) :
    SetConsistent (insert phi S) := by
  intro L' hL'
  unfold Consistent
  intro ⟨d_bot⟩
  -- If phi ∉ L', then L' ⊆ S, contradicting S consistent
  by_cases h_phi_in_L' : phi ∈ L'
  · -- phi ∈ L': use derivation to replace phi
    obtain ⟨L_deriv, hL_sub, ⟨d_phi⟩⟩ := h_deriv
    -- Let L'_filt = L' \ {phi}
    let L'_filt := L'.filter (· ≠ phi)
    have h_filt_sub : ∀ ψ ∈ L'_filt, ψ ∈ S := by
      intro ψ hψ
      have h_and := List.mem_filter.mp hψ
      have h_ne : ψ ≠ phi := of_decide_eq_true h_and.2
      have := hL' ψ h_and.1
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq h_ne
      | inr h_in_S => exact h_in_S
    -- By deduction on L' ⊢ ⊥ with phi ∈ L', we get L'_filt ⊢ phi → ⊥
    have h_perm := cons_filter_neq_perm h_phi_in_L'
    have d_bot_reord : Bimodal.ProofSystem.DerivationTree (phi :: L'_filt) Formula.bot :=
      derivation_exchange d_bot (fun x => (h_perm x).symm)
    have d_neg_phi : Bimodal.ProofSystem.DerivationTree L'_filt (Formula.neg phi) :=
      deduction_theorem L'_filt phi Formula.bot d_bot_reord
    -- Weaken d_phi to L_deriv ++ L'_filt
    let Γ := L_deriv ++ L'_filt
    have h_Γ_sub : ∀ ψ ∈ Γ, ψ ∈ S := by
      intro ψ hψ
      cases List.mem_append.mp hψ with
      | inl h => exact hL_sub ψ h
      | inr h => exact h_filt_sub ψ h
    have d_phi_Γ : Bimodal.ProofSystem.DerivationTree Γ phi :=
      Bimodal.ProofSystem.DerivationTree.weakening L_deriv Γ phi d_phi (List.subset_append_left _ _)
    have d_neg_Γ : Bimodal.ProofSystem.DerivationTree Γ (Formula.neg phi) :=
      Bimodal.ProofSystem.DerivationTree.weakening L'_filt Γ (Formula.neg phi) d_neg_phi
        (List.subset_append_right _ _)
    have d_bot_Γ : Bimodal.ProofSystem.DerivationTree Γ Formula.bot :=
      derives_bot_from_phi_neg_phi d_phi_Γ d_neg_Γ
    exact h_cons Γ h_Γ_sub ⟨d_bot_Γ⟩
  · -- phi ∉ L', so L' ⊆ S
    have h_L'_sub : ∀ ψ ∈ L', ψ ∈ S := by
      intro ψ hψ
      have := hL' ψ hψ
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h => h_phi_in_L' (h ▸ hψ))
      | inr h_in_S => exact h_in_S
    exact h_cons L' h_L'_sub ⟨d_bot⟩

/--
Helper: A formula is a subformula_consistent if adding it to a consistent set preserves consistency.
For our purposes, this holds when the formula is:
1. A theorem (can be added to any consistent set)
2. Derivable from formulas already in the set
3. A consistent singleton (for new entries)
-/
def SubformulaConsistent (phi : Formula) : Prop := FormulaConsistent phi

/--
Membership characterization for List.modify.
If x is in the modified list, then either:
1. x is in the original list at some index other than i
2. x is f(original[i]) where i is the modified index
-/
private theorem List.mem_modify_iff {α : Type*} {l : List α} {i : Nat} {f : α → α} {x : α} :
    x ∈ l.modify i f ↔
    (∃ j, l[j]? = some x ∧ i ≠ j) ∨ (∃ y, l[i]? = some y ∧ x = f y) := by
  constructor
  · intro h
    rw [List.mem_iff_getElem?] at h
    obtain ⟨j, hj⟩ := h
    rw [List.getElem?_modify] at hj
    cases h_get : l[j]? with
    | none =>
      rw [h_get] at hj
      simp at hj
    | some y =>
      rw [h_get] at hj
      have hj' : (if i = j then f y else y) = x := Option.some_inj.mp hj
      by_cases h_eq : i = j
      · right
        simp only [h_eq, ↓reduceIte] at hj'
        exact ⟨y, h_eq ▸ h_get, hj'.symm⟩
      · left
        simp only [h_eq, ↓reduceIte] at hj'
        exact ⟨j, hj' ▸ h_get, h_eq⟩
  · intro h
    rw [List.mem_iff_getElem?]
    cases h with
    | inl h =>
      obtain ⟨j, hj, h_ne⟩ := h
      use j
      rw [List.getElem?_modify, hj]
      simp only [h_ne, ↓reduceIte]
      rfl
    | inr h =>
      obtain ⟨y, hy, h_eq⟩ := h
      use i
      rw [List.getElem?_modify, hy]
      simp only [↓reduceIte, h_eq]
      rfl

/--
Helper: findIdx?.go returns values >= its starting index.
-/
private theorem findIdx_go_ge {α : Type*} {l : List α} {p : α → Bool} {n m : Nat}
    (h : List.findIdx?.go p l n = some m) : m ≥ n := by
  induction l generalizing n m with
  | nil => simp [List.findIdx?.go] at h
  | cons x xs ih =>
    simp only [List.findIdx?.go] at h
    by_cases hpx : p x
    · simp only [hpx, ↓reduceIte, Option.some.injEq] at h
      omega
    · simp only [hpx, Bool.false_eq_true, ↓reduceIte] at h
      have := ih h
      omega

/--
Helper: If findIdx?.go p l n = some m, then the element at position m-n satisfies p.
-/
private theorem findIdx_go_pred {α : Type*} {l : List α} {p : α → Bool} {n m : Nat}
    (h : List.findIdx?.go p l n = some m) :
    ∃ (h_lt : m - n < l.length), p l[m - n] = true := by
  induction l generalizing n m with
  | nil => simp [List.findIdx?.go] at h
  | cons x xs ih =>
    simp only [List.findIdx?.go] at h
    by_cases hpx : p x
    · simp only [hpx, ↓reduceIte, Option.some.injEq] at h
      subst h
      simp only [Nat.sub_self, List.length_cons, Nat.zero_lt_succ, List.getElem_cons_zero, hpx,
        exists_prop, and_self]
    · simp only [hpx, Bool.false_eq_true, ↓reduceIte] at h
      have ⟨h_lt, h_pred⟩ := ih h
      have h_m_ge : m ≥ n + 1 := findIdx_go_ge h
      have h_eq : m - n = (m - (n + 1)) + 1 := by omega
      refine ⟨?_, ?_⟩
      · simp only [List.length_cons]; omega
      · simp only [h_eq, List.getElem_cons_succ]
        exact h_pred

/--
Helper: find? and findIdx? agree on the first matching element.
When findIdx? returns some i, find? returns xs[i].
-/
private theorem find?_getElem_of_findIdx?
    {α : Type*} {p : α → Bool} {xs : List α} {i : Nat}
    (h : xs.findIdx? p = some i) :
    ∃ (hi : i < xs.length), xs.find? p = some xs[i] := by
  have ⟨hi, hp, hn⟩ := List.findIdx?_eq_some_iff_getElem.mp h
  refine ⟨hi, ?_⟩
  rw [List.find?_eq_some_iff_getElem]
  -- Need: p xs[i] = true ∧ ∃ j, ∃ h, xs[j] = xs[i] ∧ ∀ k < j, (!p xs[k]) = true
  refine ⟨hp, i, hi, rfl, ?_⟩
  -- Need: ∀ j < i, (!p xs[j]) = true
  intro j hj
  have h_not := hn j hj
  cases h_eq : p xs[j]
  · rfl
  · exact absurd h_eq h_not

/--
Helper: When findIdx? finds an index, find? returns that element, which matches getFormulas.
This shows that h_compat in addFormula_seed_preserves_consistent is called with the same
entry whose formulas are returned by getFormulas.
-/
private theorem getFormulas_eq_findIdx?_entry
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (i : Nat)
    (h_findIdx : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = some i) :
    ∃ (hi : i < seed.entries.length), seed.getFormulas famIdx timeIdx = seed.entries[i].formulas := by
  have ⟨hi, h_find⟩ := find?_getElem_of_findIdx? h_findIdx
  refine ⟨hi, ?_⟩
  unfold ModelSeed.getFormulas ModelSeed.findEntry
  simp only [h_find]

/--
Helper: Adding a consistent formula to an entry in the seed.
If the formula is consistent and compatible with the target entry, the result is SeedConsistent.
-/
theorem addFormula_seed_preserves_consistent
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (newType : SeedEntryType)
    (h_seed_cons : SeedConsistent seed)
    (h_phi_cons : FormulaConsistent phi)
    (h_compat : ∀ entry ∈ seed.entries, entry.familyIdx = famIdx → entry.timeIdx = timeIdx →
                SetConsistent (insert phi entry.formulas)) :
    SeedConsistent (seed.addFormula famIdx timeIdx phi newType) := by
  intro entry h_entry
  unfold ModelSeed.addFormula at h_entry
  -- Case split on whether there's an existing entry
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | some idx =>
    simp only [h_find] at h_entry
    -- h_entry : entry ∈ seed.entries.modify idx (...)
    rw [List.mem_modify_iff] at h_entry
    match h_entry with
    | .inl ⟨j, hj, h_ne⟩ =>
      -- Unchanged entry
      have h_entry_mem : entry ∈ seed.entries := List.mem_of_getElem? hj
      exact h_seed_cons entry h_entry_mem
    | .inr ⟨old_entry, h_old_at_idx, h_entry_eq⟩ =>
      -- This is the modified entry
      subst h_entry_eq
      have h_old_mem : old_entry ∈ seed.entries := List.mem_of_getElem? h_old_at_idx
      -- The predicate holds for old_entry since it's at idx where findIdx? found it
      have h_pred : old_entry.familyIdx = famIdx ∧ old_entry.timeIdx = timeIdx := by
        have h_findIdx_go : List.findIdx?.go
            (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) seed.entries 0 = some idx := by
          simp only [List.findIdx?] at h_find; exact h_find
        have ⟨h_lt, h_at_idx⟩ := findIdx_go_pred h_findIdx_go
        simp only [Nat.sub_zero] at h_lt h_at_idx
        -- h_old_at_idx : seed.entries[idx]? = some old_entry
        -- h_at_idx : predicate holds for seed.entries[idx]
        -- We need: predicate holds for old_entry
        have h_eq_entry : seed.entries[idx]'h_lt = old_entry := by
          have := List.getElem?_eq_getElem h_lt
          rw [h_old_at_idx] at this
          exact (Option.some_inj.mp this.symm)
        rw [h_eq_entry] at h_at_idx
        simp only [beq_iff_eq, Bool.and_eq_true, decide_eq_true_eq] at h_at_idx
        exact h_at_idx
      exact h_compat old_entry h_old_mem h_pred.1 h_pred.2
  | none =>
    simp only [h_find] at h_entry
    rw [List.mem_append, List.mem_singleton] at h_entry
    match h_entry with
    | .inl h_old => exact h_seed_cons entry h_old
    | .inr h_new =>
      subst h_new
      simp only
      exact singleton_consistent_iff.mpr h_phi_cons

/--
If a seed is well-formed (unique entries per position), and entry is at position (famIdx, timeIdx),
then getFormulas returns entry.formulas.
-/
theorem getFormulas_eq_of_wellformed_and_at_position
    (seed : ModelSeed) (entry : SeedEntry) (famIdx : Nat) (timeIdx : Int)
    (h_wf : SeedWellFormed seed)
    (h_entry : entry ∈ seed.entries)
    (h_fam : entry.familyIdx = famIdx)
    (h_time : entry.timeIdx = timeIdx) :
    seed.getFormulas famIdx timeIdx = entry.formulas := by
  unfold ModelSeed.getFormulas ModelSeed.findEntry
  -- find? returns the first entry matching the predicate
  -- By well-formedness, there's only one entry at (famIdx, timeIdx)
  -- So find? must return entry
  have h_pred : (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) entry = true := by
    simp only [beq_iff_eq, Bool.and_eq_true, decide_eq_true_eq]
    exact ⟨h_fam, h_time⟩
  -- By List.find?_isSome, there exists an entry satisfying the predicate
  have h_exists : (seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx)).isSome := by
    rw [List.find?_isSome]
    exact ⟨entry, h_entry, h_pred⟩
  -- Get that entry
  have ⟨found, h_find⟩ := Option.isSome_iff_exists.mp h_exists
  simp only [h_find]
  -- Show found = entry by well-formedness (unique positions)
  have h_found_pred := List.find?_some h_find
  simp only [beq_iff_eq, Bool.and_eq_true, decide_eq_true_eq] at h_found_pred
  have h_found_in : found ∈ seed.entries := List.mem_of_find?_eq_some h_find
  -- found and entry are both at (famIdx, timeIdx), and well-formedness says they're equal
  by_cases h_eq : found = entry
  · simp [h_eq]
  · -- found ≠ entry but both at same position: contradiction with well-formedness
    exfalso
    have h_same_pos := h_wf.2.1 found h_found_in entry h_entry h_eq
    exact h_same_pos ⟨h_found_pred.1.trans h_fam.symm, h_found_pred.2.trans h_time.symm⟩

/--
createNewTime preserves seed consistency if the new formula is consistent.
-/
theorem createNewTime_preserves_seedConsistent
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_phi_cons : FormulaConsistent phi) :
    SeedConsistent (seed.createNewTime famIdx timeIdx phi) := by
  intro entry h_entry
  unfold ModelSeed.createNewTime at h_entry
  rw [List.mem_append, List.mem_singleton] at h_entry
  cases h_entry with
  | inl h_old => exact h_seed_cons entry h_old
  | inr h_new =>
    subst h_new
    simp only
    exact singleton_consistent_iff.mpr h_phi_cons

/--
addFormula preserves nextFamilyIdx.
-/
theorem addFormula_nextFamilyIdx (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (newType : SeedEntryType) :
    (seed.addFormula famIdx timeIdx phi newType).nextFamilyIdx = seed.nextFamilyIdx := by
  unfold ModelSeed.addFormula
  cases seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) <;> rfl

/--
addFormula preserves seed well-formedness when called with a valid family index.
Note: If the position doesn't exist in the seed, famIdx must be < nextFamilyIdx.
      If it does exist, this is automatically satisfied.

Session 10: Complex proof involving List.modify reasoning. Marked as sorry for future session.
The proof requires showing:
1. Family indices remain valid after modification/append
2. Unique positions are preserved (no duplicates created)

The key insight is that addFormula either:
- Modifies an existing entry (preserving well-formedness since position already exists)
- Adds a new entry only if no entry at (famIdx, timeIdx) exists (h_famIdx_valid ensures validity)
-/
theorem addFormula_preserves_wellFormed
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (newType : SeedEntryType) (h_wf : SeedWellFormed seed)
    (h_famIdx_valid : seed.findEntry famIdx timeIdx = none → famIdx < seed.nextFamilyIdx) :
    SeedWellFormed (seed.addFormula famIdx timeIdx phi newType) := by
  unfold SeedWellFormed ModelSeed.addFormula at *
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | some idx =>
    simp only
    refine ⟨?_, ?_, ?_⟩
    · -- All family indices are valid: List.modify only changes formulas, not family indices
      intro entry h_entry
      rw [List.mem_modify_iff] at h_entry
      cases h_entry with
      | inl h_unchanged =>
        obtain ⟨j, hj, _⟩ := h_unchanged
        exact h_wf.1 entry (List.mem_of_getElem? hj)
      | inr h_modified =>
        obtain ⟨old_entry, h_old, h_eq⟩ := h_modified
        subst h_eq; simp only
        exact h_wf.1 old_entry (List.mem_of_getElem? h_old)
    · -- Unique positions: List.modify preserves positions, only changes formulas
      intro ei h_ei ej h_ej h_ne
      rw [List.mem_modify_iff] at h_ei h_ej
      cases h_ei with
      | inl h_ei_orig =>
        obtain ⟨i, hi, h_i_ne_idx⟩ := h_ei_orig
        cases h_ej with
        | inl h_ej_orig =>
          obtain ⟨j, hj, _⟩ := h_ej_orig
          exact h_wf.2.1 ei (List.mem_of_getElem? hi) ej (List.mem_of_getElem? hj) h_ne
        | inr h_ej_mod =>
          obtain ⟨old_ej, h_old_ej, h_eq_ej⟩ := h_ej_mod
          subst h_eq_ej; simp only
          intro ⟨h_fam, h_time⟩
          have h_old_ej_in := List.mem_of_getElem? h_old_ej
          have h_ei_in := List.mem_of_getElem? hi
          by_cases h_eq : ei = old_ej
          · subst h_eq
            -- ei = old_ej means entries[i] = entries[idx], but List.Nodup prevents this
            have h_i_lt : i < seed.entries.length := (List.getElem?_eq_some_iff.mp hi).1
            have h_idx_info := List.findIdx?_eq_some_iff_getElem.mp h_find
            have h_idx_lt := h_idx_info.1
            have h_at_i := (List.getElem?_eq_some_iff.mp hi).2
            have h_at_idx := (List.getElem?_eq_some_iff.mp h_old_ej).2
            have h_ne_idx : i ≠ idx := fun h_eq => h_i_ne_idx h_eq.symm
            -- Use Nodup: entries[i] = entries[idx] with i ≠ idx contradicts nodup
            have h_nodup := h_wf.2.2
            have h_eq_entries : seed.entries[i] = seed.entries[idx] := h_at_i.trans h_at_idx.symm
            have h_idx_eq : i = idx := List.Nodup.getElem_inj_iff h_nodup |>.mp h_eq_entries
            exact h_ne_idx h_idx_eq
          · exact h_wf.2.1 ei h_ei_in old_ej h_old_ej_in h_eq ⟨h_fam, h_time⟩
      | inr h_ei_mod =>
        obtain ⟨old_ei, h_old_ei, h_eq_ei⟩ := h_ei_mod
        subst h_eq_ei; simp only
        cases h_ej with
        | inl h_ej_orig =>
          obtain ⟨j, hj, h_j_ne_idx⟩ := h_ej_orig
          intro ⟨h_fam, h_time⟩
          have h_old_ei_in := List.mem_of_getElem? h_old_ei
          have h_ej_in := List.mem_of_getElem? hj
          by_cases h_eq : old_ei = ej
          · subst h_eq
            -- ej = old_ei means entries[j] = entries[idx], but List.Nodup prevents this
            have h_j_lt : j < seed.entries.length := (List.getElem?_eq_some_iff.mp hj).1
            have h_idx_info := List.findIdx?_eq_some_iff_getElem.mp h_find
            have h_idx_lt := h_idx_info.1
            have h_at_j := (List.getElem?_eq_some_iff.mp hj).2
            have h_at_idx := (List.getElem?_eq_some_iff.mp h_old_ei).2
            have h_ne_idx : j ≠ idx := fun h_eq => h_j_ne_idx h_eq.symm
            have h_nodup := h_wf.2.2
            have h_eq_entries : seed.entries[j] = seed.entries[idx] := h_at_j.trans h_at_idx.symm
            have h_idx_eq : j = idx := List.Nodup.getElem_inj_iff h_nodup |>.mp h_eq_entries
            exact h_ne_idx h_idx_eq
          · exact h_wf.2.1 old_ei h_old_ei_in ej h_ej_in h_eq ⟨h_fam, h_time⟩
        | inr h_ej_mod =>
          obtain ⟨old_ej, h_old_ej, h_eq_ej⟩ := h_ej_mod
          subst h_eq_ej; simp only
          -- Both modified from entries at idx, so old_ei = old_ej
          have h_at_ei := (List.getElem?_eq_some_iff.mp h_old_ei).2
          have h_at_ej := (List.getElem?_eq_some_iff.mp h_old_ej).2
          have h_eq : old_ei = old_ej := h_at_ei.symm.trans h_at_ej
          subst h_eq
          exfalso; exact h_ne rfl
    · -- List.Nodup: List.modify preserves nodup
      -- The key insight: modify changes only the formulas field at idx.
      -- Original entries had distinct (familyIdx, timeIdx) pairs.
      -- The modified entry keeps the same (familyIdx, timeIdx) as entries[idx],
      -- so it still differs from all other entries by their (familyIdx, timeIdx).
      -- Technical proof requires careful handling of Option.map in getElem?.
      -- Marked as sorry - this is a structural property that holds for our seeds.
      sorry
  | none =>
    simp only
    refine ⟨?_, ?_, ?_⟩
    · -- All family indices are valid
      intro entry h_entry
      rw [List.mem_append, List.mem_singleton] at h_entry
      cases h_entry with
      | inl h_old => exact h_wf.1 entry h_old
      | inr h_new =>
        subst h_new; simp only
        have h_findEntry_none : seed.findEntry famIdx timeIdx = none := by
          unfold ModelSeed.findEntry
          rw [List.find?_eq_none]
          intro e he
          rw [List.findIdx?_eq_none_iff] at h_find
          have h_pred := h_find e he
          simp only [Bool.eq_false_iff] at h_pred
          exact h_pred
        exact h_famIdx_valid h_findEntry_none
    · -- Unique positions
      intro ei h_ei ej h_ej h_ne
      rw [List.mem_append, List.mem_singleton] at h_ei h_ej
      cases h_ei with
      | inl h_ei_old =>
        cases h_ej with
        | inl h_ej_old => exact h_wf.2.1 ei h_ei_old ej h_ej_old h_ne
        | inr h_ej_new =>
          subst h_ej_new; simp only
          intro ⟨h_fam, h_time⟩
          rw [List.findIdx?_eq_none_iff] at h_find
          have h_pred := h_find ei h_ei_old
          rw [h_fam.symm, h_time.symm, beq_self_eq_true, beq_self_eq_true, Bool.and_self] at h_pred
          cases h_pred
      | inr h_ei_new =>
        cases h_ej with
        | inl h_ej_old =>
          subst h_ei_new; simp only
          intro ⟨h_fam, h_time⟩
          rw [List.findIdx?_eq_none_iff] at h_find
          have h_pred := h_find ej h_ej_old
          rw [h_fam, h_time, beq_self_eq_true, beq_self_eq_true, Bool.and_self] at h_pred
          cases h_pred
        | inr h_ej_new =>
          subst h_ei_new h_ej_new
          exfalso; exact h_ne rfl
    · -- List.Nodup
      rw [List.nodup_append]
      constructor
      · exact h_wf.2.2
      constructor
      · exact List.nodup_singleton _
      · -- New entry not in old entries (since findIdx? found none)
        intro e h_e new_e h_new_e
        rw [List.mem_singleton] at h_new_e
        subst h_new_e
        intro h_eq
        rw [List.findIdx?_eq_none_iff] at h_find
        have h_pred := h_find e h_e
        simp only [h_eq, beq_self_eq_true, Bool.and_self] at h_pred
        cases h_pred

/--
createNewFamily preserves seed well-formedness.
-/
theorem createNewFamily_preserves_wellFormed
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed) :
    SeedWellFormed (seed.createNewFamily timeIdx phi).1 := by
  unfold SeedWellFormed ModelSeed.createNewFamily
  simp only
  refine ⟨?_, ?_, ?_⟩
  · -- All family indices are valid in the new seed (with nextFamilyIdx + 1)
    intro entry h_entry
    rw [List.mem_append, List.mem_singleton] at h_entry
    cases h_entry with
    | inl h_old =>
      -- Old entry has familyIdx < nextFamilyIdx < nextFamilyIdx + 1
      have h_valid := h_wf.1 entry h_old
      omega
    | inr h_new =>
      -- New entry has familyIdx = nextFamilyIdx < nextFamilyIdx + 1
      subst h_new
      simp only
      omega
  · -- Unique positions
    intro ei h_ei ej h_ej h_ne
    rw [List.mem_append, List.mem_singleton] at h_ei h_ej
    intro ⟨h_fam, h_time⟩
    cases h_ei with
    | inl h_ei_old =>
      cases h_ej with
      | inl h_ej_old =>
        -- Both old: use h_wf.2.1
        exact h_wf.2.1 ei h_ei_old ej h_ej_old h_ne ⟨h_fam, h_time⟩
      | inr h_ej_new =>
        -- ei old, ej new (has familyIdx = nextFamilyIdx)
        subst h_ej_new
        simp only at h_fam
        -- ei.familyIdx = nextFamilyIdx, but old entries have familyIdx < nextFamilyIdx
        have h_bound := h_wf.1 ei h_ei_old
        omega
    | inr h_ei_new =>
      cases h_ej with
      | inl h_ej_old =>
        -- ei new, ej old
        subst h_ei_new
        simp only at h_fam
        -- ej.familyIdx = nextFamilyIdx, but old entries have familyIdx < nextFamilyIdx
        have h_bound := h_wf.1 ej h_ej_old
        omega
      | inr h_ej_new =>
        -- Both new: contradicts h_ne since both are the same new entry
        subst h_ei_new h_ej_new
        exact h_ne rfl
  · -- List.Nodup
    rw [List.nodup_append]
    refine ⟨h_wf.2.2, List.nodup_singleton _, ?_⟩
    -- Prove ∀ a ∈ old, ∀ b ∈ new, a ≠ b
    intro e h_e new_e h_new_e
    rw [List.mem_singleton] at h_new_e
    subst h_new_e
    -- e is in old entries, new entry has familyIdx = nextFamilyIdx
    intro h_eq
    have h_bound := h_wf.1 e h_e
    simp only [h_eq] at h_bound
    omega

/--
createNewTime preserves seed well-formedness.
-/
theorem createNewTime_preserves_wellFormed
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_famIdx_valid : famIdx < seed.nextFamilyIdx)
    (h_no_entry : seed.findEntry famIdx timeIdx = none) :
    SeedWellFormed (seed.createNewTime famIdx timeIdx phi) := by
  unfold SeedWellFormed ModelSeed.createNewTime
  simp only
  refine ⟨?_, ?_, ?_⟩
  · -- All family indices are valid (nextFamilyIdx unchanged)
    intro entry h_entry
    rw [List.mem_append, List.mem_singleton] at h_entry
    cases h_entry with
    | inl h_old => exact h_wf.1 entry h_old
    | inr h_new =>
      subst h_new
      simp only
      exact h_famIdx_valid
  · -- Unique positions
    intro ei h_ei ej h_ej h_ne
    rw [List.mem_append, List.mem_singleton] at h_ei h_ej
    intro ⟨h_fam, h_time⟩
    cases h_ei with
    | inl h_ei_old =>
      cases h_ej with
      | inl h_ej_old =>
        -- Both old: use h_wf.2.1
        exact h_wf.2.1 ei h_ei_old ej h_ej_old h_ne ⟨h_fam, h_time⟩
      | inr h_ej_new =>
        -- ei old, ej is the new entry
        subst h_ej_new
        simp only at h_fam h_time
        -- ei has position (famIdx, timeIdx) but h_no_entry says no old entry has this position
        unfold ModelSeed.findEntry at h_no_entry
        rw [List.find?_eq_none] at h_no_entry
        have h_contra := h_no_entry ei h_ei_old
        rw [h_fam, h_time, beq_self_eq_true, beq_self_eq_true, Bool.and_self] at h_contra
        exact h_contra rfl
    | inr h_ei_new =>
      cases h_ej with
      | inl h_ej_old =>
        -- ei is the new entry, ej old
        subst h_ei_new
        simp only at h_fam h_time
        -- ej has position (famIdx, timeIdx) but h_no_entry says no old entry has this position
        unfold ModelSeed.findEntry at h_no_entry
        rw [List.find?_eq_none] at h_no_entry
        have h_contra := h_no_entry ej h_ej_old
        rw [← h_fam, ← h_time, beq_self_eq_true, beq_self_eq_true, Bool.and_self] at h_contra
        exact h_contra rfl
      | inr h_ej_new =>
        -- Both new: contradicts h_ne
        subst h_ei_new h_ej_new
        exact h_ne rfl
  · -- List.Nodup
    rw [List.nodup_append]
    refine ⟨h_wf.2.2, List.nodup_singleton _, ?_⟩
    -- Prove ∀ a ∈ old, ∀ b ∈ new, a ≠ b
    intro e h_e new_e h_new_e
    rw [List.mem_singleton] at h_new_e
    subst h_new_e
    intro h_eq
    -- e is in old entries with position (famIdx, timeIdx), but h_no_entry says no such entry
    unfold ModelSeed.findEntry at h_no_entry
    rw [List.find?_eq_none] at h_no_entry
    have h_contra := h_no_entry e h_e
    simp only [h_eq, beq_self_eq_true, Bool.and_self] at h_contra
    exact h_contra trivial

/--
If neg(Box phi) is consistent, then neg phi is consistent.
Proof: By contraposition. If neg phi is inconsistent, then ⊢ phi (from neg phi ⊢ ⊥).
By necessitation: ⊢ Box phi. Then neg(Box phi) is inconsistent (derives ⊥ via modus ponens).
-/
theorem negBox_consistent_implies_neg_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.neg (Formula.box phi))) :
    FormulaConsistent (Formula.neg phi) := by
  intro ⟨d, _⟩
  apply h
  -- d : DerivationTree [neg phi] bot
  -- We need: DerivationTree [neg(Box phi)] bot
  -- From [neg phi] ⊢ ⊥, by deduction: [] ⊢ neg phi → ⊥ = [] ⊢ phi.neg.neg
  -- By DNE: [] ⊢ phi
  -- By necessitation: [] ⊢ Box phi
  -- Weakening: [neg(Box phi)] ⊢ Box phi
  -- With [neg(Box phi)] ⊢ neg(Box phi) (assumption), modus ponens gives ⊥
  have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg.neg :=
    deduction_theorem [] phi.neg Formula.bot d
  -- Use DNE to get [] ⊢ phi
  -- We have phi.neg.neg = (phi → ⊥) → ⊥
  -- DNE: ((phi → ⊥) → ⊥) → phi
  have d_dne : Bimodal.ProofSystem.DerivationTree [] (phi.neg.neg.imp phi) := by
    -- Reuse the DNE construction from diamond_box_interaction
    have step1 : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi := by
      have h_neg_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_bot : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_neg h_neg
      have h_ex_falso : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso phi)
      have h_ex_falso' : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_ex_falso (by intro; simp)
      exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_ex_falso' h_bot
    have step2 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] (phi.neg.imp phi) :=
      deduction_theorem [phi.neg.neg] phi.neg phi step1
    have step3_peirce : Bimodal.ProofSystem.DerivationTree [] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.peirce phi Formula.bot)
    have step3_peirce' : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.weakening [] _ _ step3_peirce (by intro; simp)
    have step3 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] phi :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ step3_peirce' step2
    exact deduction_theorem [] phi.neg.neg phi step3
  have d_phi : Bimodal.ProofSystem.DerivationTree [] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_dne d_neg_neg
  have d_box_phi : Bimodal.ProofSystem.DerivationTree [] phi.box :=
    Bimodal.ProofSystem.DerivationTree.necessitation _ d_phi
  -- Now derive ⊥ from [neg(Box phi)]
  have d_box_phi' : Bimodal.ProofSystem.DerivationTree [phi.box.neg] phi.box :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_box_phi (by intro; simp)
  have d_neg_box : Bimodal.ProofSystem.DerivationTree [phi.box.neg] phi.box.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_bot : Bimodal.ProofSystem.DerivationTree [phi.box.neg] Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_neg_box d_box_phi'
  exact ⟨d_bot, trivial⟩

/--
If neg(G phi) is consistent, then neg phi is consistent.
Proof: By contraposition. If neg phi is inconsistent, then ⊢ phi.
By necessitation for G: ⊢ G phi. Then neg(G phi) is inconsistent.
-/
theorem negG_consistent_implies_neg_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.neg (Formula.all_future phi))) :
    FormulaConsistent (Formula.neg phi) := by
  intro ⟨d, _⟩
  apply h
  -- Similar structure to negBox_consistent_implies_neg_consistent
  have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg.neg :=
    deduction_theorem [] phi.neg Formula.bot d
  -- DNE to get [] ⊢ phi
  have d_dne : Bimodal.ProofSystem.DerivationTree [] (phi.neg.neg.imp phi) := by
    have step1 : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi := by
      have h_neg_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_bot : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_neg h_neg
      have h_ex_falso : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso phi)
      have h_ex_falso' : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_ex_falso (by intro; simp)
      exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_ex_falso' h_bot
    have step2 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] (phi.neg.imp phi) :=
      deduction_theorem [phi.neg.neg] phi.neg phi step1
    have step3_peirce : Bimodal.ProofSystem.DerivationTree [] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.peirce phi Formula.bot)
    have step3_peirce' : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.weakening [] _ _ step3_peirce (by intro; simp)
    have step3 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] phi :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ step3_peirce' step2
    exact deduction_theorem [] phi.neg.neg phi step3
  have d_phi : Bimodal.ProofSystem.DerivationTree [] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_dne d_neg_neg
  -- Use temporal necessitation (for G)
  have d_g_phi : Bimodal.ProofSystem.DerivationTree [] phi.all_future :=
    Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ d_phi
  have d_g_phi' : Bimodal.ProofSystem.DerivationTree [phi.all_future.neg] phi.all_future :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_g_phi (by intro; simp)
  have d_neg_g : Bimodal.ProofSystem.DerivationTree [phi.all_future.neg] phi.all_future.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_bot : Bimodal.ProofSystem.DerivationTree [phi.all_future.neg] Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_neg_g d_g_phi'
  exact ⟨d_bot, trivial⟩

/--
If neg(H phi) is consistent, then neg phi is consistent.
Proof: By contraposition. If neg phi is inconsistent, then ⊢ phi.
By past necessitation: ⊢ H phi. Then neg(H phi) is inconsistent.

Note: The proof uses temporal_duality since there's no direct H necessitation rule.
From ⊢ phi, we get ⊢ G phi via temporal_necessitation.
Then ⊢ swap_past_future (G phi) = H (swap_past_future phi) via temporal_duality.
For atoms and box formulas where swap_past_future phi = phi, this gives H phi directly.
-/
theorem negH_consistent_implies_neg_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.neg (Formula.all_past phi))) :
    FormulaConsistent (Formula.neg phi) := by
  intro ⟨d, _⟩
  apply h
  -- Similar structure to negG_consistent_implies_neg_consistent
  have d_neg_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg.neg :=
    deduction_theorem [] phi.neg Formula.bot d
  -- DNE to get [] ⊢ phi
  have d_dne : Bimodal.ProofSystem.DerivationTree [] (phi.neg.neg.imp phi) := by
    have step1 : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi := by
      have h_neg_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_neg : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] phi.neg :=
        Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
      have h_bot : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_neg h_neg
      have h_ex_falso : Bimodal.ProofSystem.DerivationTree [] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.ex_falso phi)
      have h_ex_falso' : Bimodal.ProofSystem.DerivationTree [phi.neg, phi.neg.neg] (Formula.bot.imp phi) :=
        Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_ex_falso (by intro; simp)
      exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_ex_falso' h_bot
    have step2 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] (phi.neg.imp phi) :=
      deduction_theorem [phi.neg.neg] phi.neg phi step1
    have step3_peirce : Bimodal.ProofSystem.DerivationTree [] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.peirce phi Formula.bot)
    have step3_peirce' : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] ((phi.neg.imp phi).imp phi) :=
      Bimodal.ProofSystem.DerivationTree.weakening [] _ _ step3_peirce (by intro; simp)
    have step3 : Bimodal.ProofSystem.DerivationTree [phi.neg.neg] phi :=
      Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ step3_peirce' step2
    exact deduction_theorem [] phi.neg.neg phi step3
  have d_phi : Bimodal.ProofSystem.DerivationTree [] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_dne d_neg_neg
  -- Use past necessitation (for H)
  have d_h_phi : Bimodal.ProofSystem.DerivationTree [] phi.all_past :=
    Bimodal.Theorems.past_necessitation _ d_phi
  have d_h_phi' : Bimodal.ProofSystem.DerivationTree [phi.all_past.neg] phi.all_past :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_h_phi (by intro; simp)
  have d_neg_h : Bimodal.ProofSystem.DerivationTree [phi.all_past.neg] phi.all_past.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_bot : Bimodal.ProofSystem.DerivationTree [phi.all_past.neg] Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_neg_h d_h_phi'
  exact ⟨d_bot, trivial⟩

/--
createNewFamily puts the formula at the new family position.
The new family index is seed.nextFamilyIdx, and the formula is at (newFamIdx, timeIdx).
Requires well-formedness to ensure no existing entry has familyIdx = nextFamilyIdx.
-/
theorem createNewFamily_formula_at_new_position
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed) :
    let (seed', newFamIdx) := seed.createNewFamily timeIdx phi
    phi ∈ seed'.getFormulas newFamIdx timeIdx := by
  simp only [ModelSeed.createNewFamily, ModelSeed.getFormulas, ModelSeed.findEntry]
  -- The new entry is at the end of the list with (nextFamilyIdx, timeIdx)
  -- Need to show find? returns the new entry (the one we appended)
  -- This requires showing no existing entry satisfies the predicate
  have h_no_match : ∀ x ∈ seed.entries, ¬(x.familyIdx = seed.nextFamilyIdx ∧ x.timeIdx = timeIdx) := by
    intro x hx ⟨h_fam, _⟩
    have h_lt := h_wf.1 x hx
    omega
  -- Use find?_append: find? (l1 ++ l2) = (find? l1).or (find? l2)
  rw [List.find?_append]
  -- Show find? on the original list is none
  have h_none : seed.entries.find? (fun e => e.familyIdx == seed.nextFamilyIdx && e.timeIdx == timeIdx) = none := by
    rw [List.find?_eq_none]
    intro x hx
    have := h_no_match x hx
    simp only [beq_iff_eq, Bool.and_eq_true, not_and] at this ⊢
    intro h_fam h_time
    exact this h_fam h_time
  simp only [h_none, Option.none_or, List.find?_cons_of_pos, beq_self_eq_true, Bool.and_self,
             Set.mem_singleton_iff]

/--
createNewTime puts the formula at the specified position.
Requires no existing entry at that position.
-/
theorem createNewTime_formula_at_new_position
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (h_no_entry : seed.findEntry famIdx timeIdx = none) :
    phi ∈ (seed.createNewTime famIdx timeIdx phi).getFormulas famIdx timeIdx := by
  simp only [ModelSeed.createNewTime, ModelSeed.getFormulas, ModelSeed.findEntry]
  -- The new entry is at the end of the list with (famIdx, timeIdx)
  -- Since no existing entry is at this position, find? will return the new entry
  rw [List.find?_append]
  have h_none : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = none := by
    unfold ModelSeed.findEntry at h_no_entry
    exact h_no_entry
  simp only [h_none, Option.none_or, List.find?_cons_of_pos, beq_self_eq_true, Bool.and_self,
             Set.mem_singleton_iff]

/--
createNewFamily preserves seed consistency if the new formula is consistent.
-/
theorem createNewFamily_preserves_seedConsistent
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_phi_cons : FormulaConsistent phi) :
    SeedConsistent (seed.createNewFamily timeIdx phi).1 := by
  intro entry h_entry
  unfold ModelSeed.createNewFamily at h_entry
  simp only at h_entry
  rw [List.mem_append, List.mem_singleton] at h_entry
  cases h_entry with
  | inl h_old => exact h_seed_cons entry h_old
  | inr h_new =>
    subst h_new
    simp only
    exact singleton_consistent_iff.mpr h_phi_cons

/--
buildSeedAux preserves seed consistency.

This is a fundamental theorem showing that the recursive seed construction maintains
consistency at every step. The key insights are:

1. For atomic/implication cases: Adding a formula to an entry preserves consistency
   when the existing entry is consistent and the formula is compatible.

2. For positive modal/temporal operators (Box, G, H): The subformula is a theorem
   when the operator formula is consistent, so adding it preserves consistency.

3. For negative modal/temporal operators (neg Box, neg G, neg H): New entries are
   created with singleton sets, which are consistent if the witness formula is consistent.

**Stronger Invariant Approach**:
The theorem uses a stronger precondition: not just that individual formulas are
consistent as singletons, but that:
1. phi is already IN the current position's formula set
2. The current position's formula set is consistent as a whole

This ensures that when we add additional formulas (subformulas of phi), they are
compatible with the existing set because they're derived from phi.

See research-002.md Section 5 for the diamond-box interaction lemma that is key
to the cross-family consistency proof.
-/
theorem buildSeedAux_preserves_seedConsistent (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (h_cons : SeedConsistent seed) (h_wf : SeedWellFormed seed)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx)
    (h_phi_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeedAux phi famIdx timeIdx seed) := by
  -- Use strong induction on formula complexity
  generalize h_c : phi.complexity = c
  induction c using Nat.strong_induction_on generalizing phi famIdx timeIdx seed with
  | h c ih =>
    -- Case split on formula structure to match buildSeedAux
    match phi with
    | Formula.atom s =>
      -- Atom case: just adds atom to current position
      simp only [buildSeedAux]
      -- addFormula just merges into existing entry, seed stays consistent
      apply addFormula_seed_preserves_consistent
      · exact h_cons
      · exact h_phi_cons
      · intro entry h_entry h_fam h_time
        -- entry is at position (famIdx, timeIdx) and is consistent
        have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
        --
        -- KEY INSIGHT: Although h_compat is quantified over all entries at the position,
        -- addFormula_seed_preserves_consistent only CALLS it with the FIRST matching entry
        -- (old_entry, found by findIdx?). This entry is exactly the one whose formulas
        -- are returned by getFormulas.
        --
        -- h_phi_in : atom s ∈ seed.getFormulas famIdx timeIdx
        -- getFormulas returns entry.formulas for the first entry at (famIdx, timeIdx)
        -- The h_compat callback will only be called with that first entry.
        --
        -- Since findEntry/getFormulas uses find? and findIdx? finds the first match,
        -- and entry is at position (famIdx, timeIdx), if entry is the first match,
        -- then getFormulas famIdx timeIdx = entry.formulas.
        --
        -- The matching between find? and findIdx? is guaranteed:
        -- findIdx? finds index i where predicate first holds, find? returns element at that index.
        -- Since entry matches the predicate and is in the list, and findIdx? found some index,
        -- the entry at that index is the first one matching the predicate.
        --
        -- If entry IS the first matching entry:
        --   getFormulas famIdx timeIdx = entry.formulas (by definition of findEntry/getFormulas)
        --   So phi ∈ entry.formulas by h_phi_in
        --   Then insert phi entry.formulas = entry.formulas (phi already there)
        --   So SetConsistent (insert phi entry.formulas) = SetConsistent entry.formulas ✓
        --
        -- The h_compat callback is only called when findIdx? finds an entry, and with
        -- that specific entry. So we can assume entry is the first matching one.
        -- This is captured by the proof of addFormula_seed_preserves_consistent which
        -- uses old_entry = entries[idx] where idx is from findIdx?.
        --
        -- To formalize: we need that when h_compat is called with entry at (famIdx, timeIdx),
        -- entry is the first such entry in the list. This is true by construction.
        --
        -- For now, proceed assuming phi ∈ entry.formulas (sound by the above reasoning)
        -- and later add formal well-formedness tracking if needed.
        --
        -- The structural invariant is: seeds built by buildSeedAux have at most one
        -- entry per position (because addFormula merges rather than duplicates).
        -- This should be proven as a separate lemma.
        --
        -- Use well-formedness to show phi ∈ entry.formulas:
        -- Since seed is well-formed and entry is at (famIdx, timeIdx),
        -- getFormulas returns entry.formulas
        have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
        have h_phi_in_entry : (Formula.atom s) ∈ entry.formulas := by
          rw [← h_getFormulas_eq]
          exact h_phi_in
        have h_insert_eq : insert (Formula.atom s) entry.formulas = entry.formulas :=
          Set.insert_eq_of_mem h_phi_in_entry
        rw [h_insert_eq]
        exact h_entry_cons
    | Formula.bot =>
      -- Bot case: adds bot to current position
      simp only [buildSeedAux]
      apply addFormula_seed_preserves_consistent
      · exact h_cons
      · exact h_phi_cons
      · intro entry h_entry h_fam h_time
        have h_entry_cons : SetConsistent entry.formulas := h_cons entry h_entry
        -- Use well-formedness to show phi ∈ entry.formulas
        have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
        have h_phi_in_entry : Formula.bot ∈ entry.formulas := by
          rw [← h_getFormulas_eq]
          exact h_phi_in
        rw [Set.insert_eq_of_mem h_phi_in_entry]
        exact h_entry_cons
    | Formula.box psi =>
      -- Box case: adds Box psi to current, then psi to all families, then recurses on psi
      simp only [buildSeedAux]
      -- This requires several steps:
      -- 1. Add Box psi to current position (preserves consistency since phi is already there)
      -- 2. Add psi to all families at current time (needs compatibility proof)
      -- 3. Recurse on psi at current position (needs stronger invariant)
      --
      -- The challenge is that adding psi to OTHER families requires showing psi is compatible
      -- with those families. This is where the modal coherence comes in:
      -- If Box psi is consistent, then psi is consistent (as a singleton)
      -- But we need {existing formulas at other family} ∪ {psi} to be consistent
      --
      -- Actually, the seed construction adds psi ONLY when Box psi is being processed,
      -- meaning Box psi is in the current family. For psi to be in all families,
      -- we need the modal forward property. But this is what we're BUILDING, not assuming.
      --
      -- Key insight: at this stage, we're just building the SEED. The consistency property
      -- is about the seed itself, not about the full MCS structure yet.
      --
      -- For the seed: when we add Box psi to position (f, t), and then add psi to all
      -- other families at time t, those other families might not have Box psi.
      -- But that's OK because:
      -- - If another family has neg(Box psi), then by diamond_box_interaction,
      --   {psi, neg psi'} is consistent (where psi' is the inner formula)
      -- - Actually no, the issue is simpler: other families at this stage only have
      --   the formulas we've put there via previous buildSeedAux calls
      --
      -- BLOCKING: Requires addToAllFamilies_preserves_consistent lemma
      -- The key challenge is proving that adding psi to other families preserves
      -- consistency. This requires tracking that all seed formulas are subformulas
      -- of a consistent root, hence mutually compatible.
      -- See research-002.md Section 5 for the theoretical justification.
      sorry
    | Formula.all_future psi =>
      -- G case: similar structure to Box but adds psi to all FUTURE times
      -- BLOCKING: Requires addToAllFutureTimes_preserves_consistent lemma
      sorry
    | Formula.all_past psi =>
      -- H case: similar structure to Box but adds psi to all PAST times
      -- BLOCKING: Requires addToAllPastTimes_preserves_consistent lemma
      sorry
    | Formula.imp psi1 psi2 =>
      match psi1, psi2 with
      | Formula.box inner, Formula.bot =>
        -- neg(Box inner) case: creates new family with neg inner
        simp only [buildSeedAux]
        -- Work with explicit projections to avoid let-binding issues
        let seed1 := seed.addFormula famIdx timeIdx inner.box.neg .universal_target
        let result := seed1.createNewFamily timeIdx inner.neg
        -- Show inner.neg is consistent
        have h_inner_neg_cons : FormulaConsistent inner.neg :=
          negBox_consistent_implies_neg_consistent h_phi_cons
        -- Show complexity decreases
        have h_complexity : inner.neg.complexity < c := by
          rw [← h_c]
          simp only [Formula.complexity, Formula.neg]
          omega
        -- Show seed1 is consistent
        have h_seed1_cons : SeedConsistent seed1 := by
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : inner.box.neg ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]
            exact h_entry_cons
        -- Show seed1 is well-formed
        have h_seed1_wf : SeedWellFormed seed1 := by
          apply addFormula_preserves_wellFormed
          · exact h_wf
          · intro _
            unfold ModelSeed.getFormulas at h_phi_in
            cases h_find_entry : seed.findEntry famIdx timeIdx with
            | some entry =>
              unfold ModelSeed.findEntry at h_find_entry
              have h_mem := List.mem_of_find?_eq_some h_find_entry
              have h_entry_valid := h_wf.1 entry h_mem
              have h_pred := List.find?_some h_find_entry
              simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
              rw [← h_pred.1]; exact h_entry_valid
            | none => simp only [h_find_entry, Set.mem_empty_iff_false] at h_phi_in
        -- Show result.1 (seed2) is consistent
        have h_seed2_cons : SeedConsistent result.1 :=
          createNewFamily_preserves_seedConsistent seed1 timeIdx inner.neg h_seed1_cons h_inner_neg_cons
        -- Show result.1 (seed2) is well-formed
        have h_seed2_wf : SeedWellFormed result.1 :=
          createNewFamily_preserves_wellFormed seed1 timeIdx inner.neg h_seed1_wf
        -- Show inner.neg is in result.1's formulas at result.2
        have h_neg_in : inner.neg ∈ result.1.getFormulas result.2 timeIdx :=
          createNewFamily_formula_at_new_position seed1 timeIdx inner.neg h_seed1_wf
        -- Apply IH
        exact ih inner.neg.complexity h_complexity inner.neg result.2 timeIdx result.1
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons rfl
      | Formula.all_future inner, Formula.bot =>
        -- neg(G inner) case: creates new time in same family with neg inner
        simp only [buildSeedAux]
        let seed1 := seed.addFormula famIdx timeIdx inner.all_future.neg .universal_target
        let newTime := seed1.freshFutureTime famIdx timeIdx
        let seed2 := seed1.createNewTime famIdx newTime inner.neg
        -- Show inner.neg is consistent
        have h_inner_neg_cons : FormulaConsistent inner.neg :=
          negG_consistent_implies_neg_consistent h_phi_cons
        -- Show complexity decreases
        have h_complexity : inner.neg.complexity < c := by
          rw [← h_c]
          simp only [Formula.complexity, Formula.neg]
          omega
        -- Show seed1 is consistent
        have h_seed1_cons : SeedConsistent seed1 := by
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : inner.all_future.neg ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]
            exact h_entry_cons
        -- Show seed1 is well-formed
        have h_seed1_wf : SeedWellFormed seed1 := by
          apply addFormula_preserves_wellFormed
          · exact h_wf
          · intro _
            unfold ModelSeed.getFormulas at h_phi_in
            cases h_find_entry : seed.findEntry famIdx timeIdx with
            | some entry =>
              unfold ModelSeed.findEntry at h_find_entry
              have h_mem := List.mem_of_find?_eq_some h_find_entry
              have h_entry_valid := h_wf.1 entry h_mem
              have h_pred := List.find?_some h_find_entry
              simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
              rw [← h_pred.1]; exact h_entry_valid
            | none => simp only [h_find_entry, Set.mem_empty_iff_false] at h_phi_in
        -- Show no entry exists at newTime
        have h_no_entry : seed1.findEntry famIdx newTime = none :=
          ModelSeed.freshFutureTime_no_entry seed1 famIdx timeIdx
        -- Show seed2 is consistent
        have h_seed2_cons : SeedConsistent seed2 :=
          createNewTime_preserves_seedConsistent seed1 famIdx newTime inner.neg h_seed1_cons h_inner_neg_cons
        -- Show seed2 is well-formed
        have h_seed2_wf : SeedWellFormed seed2 := by
          apply createNewTime_preserves_wellFormed
          · exact h_seed1_wf
          · -- famIdx < seed1.nextFamilyIdx
            rw [addFormula_nextFamilyIdx]
            unfold ModelSeed.getFormulas at h_phi_in
            cases h_find_entry : seed.findEntry famIdx timeIdx with
            | some entry =>
              unfold ModelSeed.findEntry at h_find_entry
              have h_mem := List.mem_of_find?_eq_some h_find_entry
              have h_entry_valid := h_wf.1 entry h_mem
              have h_pred := List.find?_some h_find_entry
              simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
              rw [← h_pred.1]; exact h_entry_valid
            | none => simp only [h_find_entry, Set.mem_empty_iff_false] at h_phi_in
          · exact h_no_entry
        -- Show inner.neg is in seed2's formulas at newTime
        have h_neg_in : inner.neg ∈ seed2.getFormulas famIdx newTime :=
          createNewTime_formula_at_new_position seed1 famIdx newTime inner.neg h_no_entry
        -- Apply IH
        exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons rfl
      | Formula.all_past inner, Formula.bot =>
        -- neg(H inner) case: creates new time in same family with neg inner
        simp only [buildSeedAux]
        let seed1 := seed.addFormula famIdx timeIdx inner.all_past.neg .universal_target
        let newTime := seed1.freshPastTime famIdx timeIdx
        let seed2 := seed1.createNewTime famIdx newTime inner.neg
        -- Show inner.neg is consistent
        have h_inner_neg_cons : FormulaConsistent inner.neg :=
          negH_consistent_implies_neg_consistent h_phi_cons
        -- Show complexity decreases
        have h_complexity : inner.neg.complexity < c := by
          rw [← h_c]
          simp only [Formula.complexity, Formula.neg]
          omega
        -- Show seed1 is consistent
        have h_seed1_cons : SeedConsistent seed1 := by
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : inner.all_past.neg ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]
            exact h_entry_cons
        -- Show seed1 is well-formed
        have h_seed1_wf : SeedWellFormed seed1 := by
          apply addFormula_preserves_wellFormed
          · exact h_wf
          · intro _
            unfold ModelSeed.getFormulas at h_phi_in
            cases h_find_entry : seed.findEntry famIdx timeIdx with
            | some entry =>
              unfold ModelSeed.findEntry at h_find_entry
              have h_mem := List.mem_of_find?_eq_some h_find_entry
              have h_entry_valid := h_wf.1 entry h_mem
              have h_pred := List.find?_some h_find_entry
              simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
              rw [← h_pred.1]; exact h_entry_valid
            | none => simp only [h_find_entry, Set.mem_empty_iff_false] at h_phi_in
        -- Show no entry exists at newTime
        have h_no_entry : seed1.findEntry famIdx newTime = none :=
          ModelSeed.freshPastTime_no_entry seed1 famIdx timeIdx
        -- Show seed2 is consistent
        have h_seed2_cons : SeedConsistent seed2 :=
          createNewTime_preserves_seedConsistent seed1 famIdx newTime inner.neg h_seed1_cons h_inner_neg_cons
        -- Show seed2 is well-formed
        have h_seed2_wf : SeedWellFormed seed2 := by
          apply createNewTime_preserves_wellFormed
          · exact h_seed1_wf
          · -- famIdx < seed1.nextFamilyIdx
            rw [addFormula_nextFamilyIdx]
            unfold ModelSeed.getFormulas at h_phi_in
            cases h_find_entry : seed.findEntry famIdx timeIdx with
            | some entry =>
              unfold ModelSeed.findEntry at h_find_entry
              have h_mem := List.mem_of_find?_eq_some h_find_entry
              have h_entry_valid := h_wf.1 entry h_mem
              have h_pred := List.find?_some h_find_entry
              simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
              rw [← h_pred.1]; exact h_entry_valid
            | none => simp only [h_find_entry, Set.mem_empty_iff_false] at h_phi_in
          · exact h_no_entry
        -- Show inner.neg is in seed2's formulas at newTime
        have h_neg_in : inner.neg ∈ seed2.getFormulas famIdx newTime :=
          createNewTime_formula_at_new_position seed1 famIdx newTime inner.neg h_no_entry
        -- Apply IH
        exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons rfl
      | p1, p2 =>
        -- Generic implication case: buildSeedAux adds the implication to current position.
        -- The tricky part is that Lean can't reduce buildSeedAux with abstract pattern variables.
        --
        -- We need to show: SeedConsistent (buildSeedAux (p1.imp p2) famIdx timeIdx seed)
        -- By buildSeedAux's definition, the last case for imp just calls addFormula.
        -- But we can't prove definitional equality with abstract p1, p2.
        --
        -- Instead, we use the semantic argument: adding a formula that's already in the
        -- seed preserves consistency (since insert of existing element is identity).
        -- The seed already has (p1.imp p2) at (famIdx, timeIdx) by h_phi_in.
        --
        -- However, we need to connect buildSeedAux to the resulting seed structure.
        -- Since buildSeedAux's last imp case just calls addFormula, and the earlier
        -- special cases (box/bot, all_future/bot, all_past/bot) were already matched
        -- in the inner match, this case catches remaining patterns.
        --
        -- BLOCKING: Requires either:
        -- 1. Explicit case analysis on p1 and p2 to exhaust remaining patterns
        -- 2. A lemma showing buildSeedAux_imp_generic_eq_addFormula for non-special patterns
        -- 3. Native_decide or similar to reduce the pattern match
        sorry

theorem seedConsistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeed phi) := by
  unfold buildSeed
  apply buildSeedAux_preserves_seedConsistent
  · -- Initial seed is consistent
    exact initialSeedConsistent phi h_cons
  · -- Initial seed is well-formed
    exact initialSeedWellFormed phi
  · -- phi is in the initial seed at position (0, 0)
    have h_init : (ModelSeed.initial phi).getFormulas 0 0 = {phi} := by
      unfold ModelSeed.initial ModelSeed.getFormulas ModelSeed.findEntry
      simp only [List.find?_cons_of_pos, beq_self_eq_true, Bool.and_self]
    rw [h_init]
    exact Set.mem_singleton_iff.mpr rfl
  · -- phi is consistent
    exact h_cons

end Bimodal.Metalogic.Bundle
