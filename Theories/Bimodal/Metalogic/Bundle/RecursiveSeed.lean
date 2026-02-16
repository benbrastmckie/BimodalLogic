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
freshFutureTime returns a time strictly greater than currentTime.
-/
theorem ModelSeed.freshFutureTime_gt_current (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.freshFutureTime famIdx currentTime > currentTime := by
  unfold freshFutureTime
  simp only  -- Simplify let bindings
  -- The foldl computes max over all entries at famIdx starting from currentTime
  -- So result >= currentTime, and result + 1 > currentTime
  have h_ge : ∀ L : List SeedEntry, ∀ init : Int,
      init ≤ L.foldl (fun acc e => max acc e.timeIdx) init := by
    intro L
    induction L with
    | nil => intro init; simp [List.foldl]
    | cons e es ih =>
      intro init
      simp only [List.foldl_cons]
      calc init ≤ max init e.timeIdx := le_max_left _ _
           _ ≤ es.foldl (fun acc e => max acc e.timeIdx) (max init e.timeIdx) := ih _
  have h := h_ge (List.filter (fun e => e.familyIdx == famIdx) seed.entries) currentTime
  omega

/--
freshFutureTime returns a time not equal to currentTime.
-/
theorem ModelSeed.freshFutureTime_ne_current (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.freshFutureTime famIdx currentTime ≠ currentTime := by
  have h := freshFutureTime_gt_current seed famIdx currentTime
  omega

/--
freshPastTime returns a time strictly less than currentTime.
-/
theorem ModelSeed.freshPastTime_lt_current (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.freshPastTime famIdx currentTime < currentTime := by
  unfold freshPastTime
  simp only  -- Simplify let bindings
  -- The foldl computes min over all entries at famIdx starting from currentTime
  -- So result <= currentTime, and result - 1 < currentTime
  have h_le : ∀ L : List SeedEntry, ∀ init : Int,
      L.foldl (fun acc e => min acc e.timeIdx) init ≤ init := by
    intro L
    induction L with
    | nil => intro init; simp [List.foldl]
    | cons e es ih =>
      intro init
      simp only [List.foldl_cons]
      calc es.foldl (fun acc e => min acc e.timeIdx) (min init e.timeIdx)
           ≤ min init e.timeIdx := ih _
           _ ≤ init := min_le_left _ _
  have h := h_le (List.filter (fun e => e.familyIdx == famIdx) seed.entries) currentTime
  omega

/--
freshPastTime returns a time not equal to currentTime.
-/
theorem ModelSeed.freshPastTime_ne_current (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) :
    seed.freshPastTime famIdx currentTime ≠ currentTime := by
  have h := freshPastTime_lt_current seed famIdx currentTime
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
    -- G psi: add G psi and psi to current, add psi to all future times, propagate G psi, recurse
    let phi := Formula.all_future psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
    let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi  -- Propagate G psi to future times
    buildSeedAux psi famIdx timeIdx seed4
  | Formula.all_past psi, famIdx, timeIdx, seed =>
    -- H psi: add H psi and psi to current, add psi to all past times, propagate H psi, recurse
    let phi := Formula.all_past psi
    let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
    let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
    let seed3 := seed2.addToAllPastTimes famIdx timeIdx psi
    let seed4 := seed3.addToAllPastTimes famIdx timeIdx phi  -- Propagate H psi to past times
    buildSeedAux psi famIdx timeIdx seed4
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

/--
The initial seed has exactly [0] as its familyIndices.
This is key for the single-path invariant in buildSeedAux_preserves_seedConsistent.
-/
theorem initial_familyIndices_eq (phi : Formula) :
    (ModelSeed.initial phi).familyIndices = [0] := by
  simp only [ModelSeed.initial, ModelSeed.familyIndices, List.map, List.eraseDups]
  decide

/--
The initial seed has exactly [0] as its timeIndices for family 0.
This is key for the single-time invariant in buildSeedAux_preserves_seedConsistent.
-/
theorem initial_timeIndices_eq (phi : Formula) :
    (ModelSeed.initial phi).timeIndices 0 = [0] := by
  simp only [ModelSeed.initial, ModelSeed.timeIndices, List.filter, beq_self_eq_true,
             List.map, List.eraseDups]
  native_decide

/-!
## Helper lemmas for family index preservation
-/

/-- Membership in eraseDups of appended lists preserves membership from left. -/
private theorem mem_eraseDups_append_left {α : Type*} [BEq α] [LawfulBEq α] {a : α} {l1 l2 : List α}
    (h : a ∈ l1.eraseDups) : a ∈ (l1 ++ l2).eraseDups := by
  rw [List.eraseDups_append]; exact List.mem_append_left _ h

/-!
### Single-Family Invariant Lemmas

These lemmas show that certain operations preserve the property that familyIndices = [famIdx].
This is key for the Box/G/H cases in buildSeedAux_preserves_seedConsistent.
-/

/-- Helper: if eraseDups l = [a], then all elements of l equal a. -/
private theorem all_eq_of_eraseDups_singleton {α : Type*} [DecidableEq α]
    {l : List α} {a : α} (h : l.eraseDups = [a]) : ∀ x ∈ l, x = a := by
  induction l with
  | nil =>
    intro x hx
    simp at hx
  | cons hd tl ih =>
    intro x hx
    simp only [List.mem_cons] at hx
    simp only [List.eraseDups_cons] at h
    have h_hd : hd = a := by
      have : (hd :: (List.filter (fun b => !b == hd) tl).eraseDups).head? = some a := by
        rw [h]; simp
      simp only [List.head?_cons] at this
      exact Option.some.inj this
    cases hx with
    | inl hx => rw [hx]; exact h_hd
    | inr hx =>
      have h_rest : (List.filter (fun b => !b == hd) tl).eraseDups = [] := by
        have h_eq : [a] = hd :: (List.filter (fun b => !b == hd) tl).eraseDups := by rw [← h]
        injection h_eq with _ h_eq'
        exact h_eq'.symm
      have h_filter_empty : List.filter (fun b => !b == hd) tl = [] := by
        match h_filt : List.filter (fun b => !b == hd) tl with
        | [] => rfl
        | c :: cs =>
          simp only [h_filt, List.eraseDups_cons] at h_rest
          exact (List.cons_ne_nil _ _ h_rest).elim
      have h_all_hd : ∀ y ∈ tl, y = hd := by
        intro y hy
        if h_eq : y = hd then
          exact h_eq
        else
          exfalso
          have h_in_filter : y ∈ List.filter (fun b => !b == hd) tl := by
            rw [List.mem_filter]
            constructor
            · exact hy
            · simp only [beq_iff_eq, Bool.not_eq_true', Bool.eq_false_iff, ne_eq]
              exact h_eq
          rw [h_filter_empty] at h_in_filter
          simp at h_in_filter
      have h_x_eq_hd := h_all_hd x hx
      rw [h_x_eq_hd, h_hd]

/-- Helper: eraseDups of a list where all elements are equal to a single value. -/
private theorem eraseDups_all_same {α : Type*} [DecidableEq α]
    {l : List α} {a : α} (h : ∀ x ∈ l, x = a) (h_ne : l ≠ []) : l.eraseDups = [a] := by
  induction l with
  | nil => simp at h_ne
  | cons hd tl ih =>
    simp only [List.eraseDups_cons]
    have h_hd : hd = a := h hd (by simp)
    rw [h_hd]
    have h_filter_empty : List.filter (fun b => !(b == a)) tl = [] := by
      match h_filt : List.filter (fun b => !(b == a)) tl with
      | [] => rfl
      | c :: cs =>
        have h_c_in_filter : c ∈ List.filter (fun b => !(b == a)) tl := by rw [h_filt]; simp
        have h_c_in : c ∈ tl := (List.mem_filter.mp h_c_in_filter).1
        have h_c_ne_a : (!(c == a)) = true := (List.mem_filter.mp h_c_in_filter).2
        have h_c_eq : c = a := h c (by simp [h_c_in])
        simp only [Bool.not_eq_true', Bool.eq_false_iff] at h_c_ne_a
        rw [h_c_eq] at h_c_ne_a
        simp at h_c_ne_a
    rw [h_filter_empty]
    simp only [List.eraseDups_nil]

/--
If seed.familyIndices = [famIdx], then after addFormula at the same family,
the familyIndices remains [famIdx].
-/
theorem addFormula_preserves_single_family (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (ty : SeedEntryType)
    (h_single : seed.familyIndices = [famIdx]) :
    (seed.addFormula famIdx timeIdx phi ty).familyIndices = [famIdx] := by
  unfold ModelSeed.familyIndices at *
  unfold ModelSeed.addFormula
  cases h_match : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | some i =>
    -- Modifying an existing entry preserves the map of familyIdx
    have h_modify_pres : (seed.entries.modify i
        (fun e => { e with formulas := insert phi e.formulas })).map SeedEntry.familyIdx =
        seed.entries.map SeedEntry.familyIdx := by
      apply List.ext_getElem; simp only [List.length_map, List.length_modify]
      intro n h1 h2; simp only [List.getElem_map, List.getElem_modify]; split <;> rfl
    simp only [h_modify_pres]; exact h_single
  | none =>
    -- Adding new entry with famIdx
    simp only [List.map_append, List.map_cons, List.map_nil]
    -- We need to show eraseDups (oldEntries.map familyIdx ++ [famIdx]) = [famIdx]
    have h_all_famIdx : ∀ x ∈ seed.entries.map SeedEntry.familyIdx, x = famIdx :=
      all_eq_of_eraseDups_singleton h_single
    -- The new list maps all to famIdx
    have h_all_new : ∀ x ∈ (seed.entries.map SeedEntry.familyIdx ++ [famIdx]), x = famIdx := by
      intro x hx
      rw [List.mem_append] at hx
      cases hx with
      | inl h => exact h_all_famIdx x h
      | inr h => simp only [List.mem_singleton] at h; exact h
    -- The new list is non-empty (has at least famIdx)
    have h_ne : seed.entries.map SeedEntry.familyIdx ++ [famIdx] ≠ [] := by
      intro h_empty
      have : famIdx ∈ seed.entries.map SeedEntry.familyIdx ++ [famIdx] := by simp
      rw [h_empty] at this
      simp at this
    exact eraseDups_all_same h_all_new h_ne

/--
If seed.familyIndices = [famIdx], then addToAllFamilies preserves this.
Since familyIndices = [famIdx], addToAllFamilies only calls addFormula at famIdx.
-/
theorem addToAllFamilies_preserves_single_family (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (h_single : seed.familyIndices = [famIdx]) :
    (seed.addToAllFamilies timeIdx phi).familyIndices = [famIdx] := by
  unfold ModelSeed.addToAllFamilies ModelSeed.familyIndices at *
  -- familyIndices = [famIdx], so the list is [famIdx] and foldl iterates over it
  simp only [h_single, List.foldl_cons, List.foldl_nil]
  exact addFormula_preserves_single_family seed famIdx timeIdx phi .universal_target h_single

/--
Helper: foldl over time list with addFormula preserves single-family property.
-/
private theorem foldl_addFormula_times_preserves_single_family (phi : Formula) (famIdx : Nat)
    (times : List Int) (seed : ModelSeed)
    (h_single : seed.familyIndices = [famIdx]) :
    (times.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed).familyIndices = [famIdx] := by
  induction times generalizing seed with
  | nil => exact h_single
  | cons t ts ih =>
    simp only [List.foldl_cons]
    apply ih
    exact addFormula_preserves_single_family seed famIdx t phi .universal_target h_single

/--
If seed.familyIndices = [famIdx], then addToAllFutureTimes preserves this.
-/
theorem addToAllFutureTimes_preserves_single_family (seed : ModelSeed) (famIdx : Nat)
    (timeIdx : Int) (phi : Formula) (h_single : seed.familyIndices = [famIdx]) :
    (seed.addToAllFutureTimes famIdx timeIdx phi).familyIndices = [famIdx] := by
  unfold ModelSeed.addToAllFutureTimes
  exact foldl_addFormula_times_preserves_single_family phi famIdx _ seed h_single

/--
If seed.familyIndices = [famIdx], then addToAllPastTimes preserves this.
-/
theorem addToAllPastTimes_preserves_single_family (seed : ModelSeed) (famIdx : Nat)
    (timeIdx : Int) (phi : Formula) (h_single : seed.familyIndices = [famIdx]) :
    (seed.addToAllPastTimes famIdx timeIdx phi).familyIndices = [famIdx] := by
  unfold ModelSeed.addToAllPastTimes
  exact foldl_addFormula_times_preserves_single_family phi famIdx _ seed h_single

/--
createNewTime preserves single-family property since it adds entry at same family.
-/
theorem createNewTime_preserves_single_family (seed : ModelSeed) (famIdx : Nat)
    (timeIdx : Int) (phi : Formula) (h_single : seed.familyIndices = [famIdx]) :
    (seed.createNewTime famIdx timeIdx phi).familyIndices = [famIdx] := by
  unfold ModelSeed.createNewTime ModelSeed.familyIndices at *
  simp only [List.map_append, List.map_cons, List.map_nil]
  have h_all : ∀ x ∈ seed.entries.map SeedEntry.familyIdx, x = famIdx :=
    all_eq_of_eraseDups_singleton h_single
  have h_all_new : ∀ x ∈ (seed.entries.map SeedEntry.familyIdx ++ [famIdx]), x = famIdx := by
    intro x hx
    rw [List.mem_append] at hx
    cases hx with
    | inl h => exact h_all x h
    | inr h => simp only [List.mem_singleton] at h; exact h
  have h_ne : seed.entries.map SeedEntry.familyIdx ++ [famIdx] ≠ [] := by
    intro h_empty
    have : famIdx ∈ seed.entries.map SeedEntry.familyIdx ++ [famIdx] := by simp
    rw [h_empty] at this
    simp at this
  exact eraseDups_all_same h_all_new h_ne

/-!
### Single-Time Invariant Lemmas

These lemmas show that if timeIndices famIdx = [timeIdx], then there are no future/past times.
This is key for the G/H cases in buildSeedAux_preserves_seedConsistent.
-/

/--
If seed.timeIndices famIdx = [timeIdx], then there are no entries with timeIdx > currentTime.
-/
theorem no_future_times_of_single_time (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (h_single : seed.timeIndices famIdx = [timeIdx]) :
    (seed.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx > timeIdx) = [] := by
  apply List.filter_eq_nil_iff.mpr
  intro e he
  -- he : e ∈ seed.entries.filter (fun e => e.familyIdx == famIdx)
  unfold ModelSeed.timeIndices at h_single
  have h_all := all_eq_of_eraseDups_singleton h_single e.timeIdx
  have h_in_map : e.timeIdx ∈ (seed.entries.filter (fun e' => e'.familyIdx == famIdx)).map SeedEntry.timeIdx :=
    List.mem_map_of_mem (f := SeedEntry.timeIdx) he
  have h_eq := h_all h_in_map
  simp only [h_eq, gt_iff_lt, lt_self_iff_false, decide_false, Bool.false_eq_true, not_false_eq_true]

/--
If seed.timeIndices famIdx = [timeIdx], then there are no entries with timeIdx < currentTime.
-/
theorem no_past_times_of_single_time (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (h_single : seed.timeIndices famIdx = [timeIdx]) :
    (seed.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx < timeIdx) = [] := by
  apply List.filter_eq_nil_iff.mpr
  intro e he
  -- he : e ∈ seed.entries.filter (fun e => e.familyIdx == famIdx)
  unfold ModelSeed.timeIndices at h_single
  have h_all := all_eq_of_eraseDups_singleton h_single e.timeIdx
  have h_in_map : e.timeIdx ∈ (seed.entries.filter (fun e' => e'.familyIdx == famIdx)).map SeedEntry.timeIdx :=
    List.mem_map_of_mem (f := SeedEntry.timeIdx) he
  have h_eq := h_all h_in_map
  simp only [h_eq, lt_self_iff_false, decide_false, Bool.false_eq_true, not_false_eq_true]

/-- filter commutes with modify when the modifier doesn't affect the filter predicate
    and the element at idx passes the filter -/
private lemma filter_modify_eq_modify_filter (l : List SeedEntry) (idx : Nat) (f : SeedEntry → SeedEntry)
    (hf : ∀ e, (f e).familyIdx = e.familyIdx) (famIdx : Nat)
    (h_idx : idx < l.length)
    (h_passes : ((l.get ⟨idx, h_idx⟩).familyIdx == famIdx) = true) :
    (l.modify idx f).filter (fun e => e.familyIdx == famIdx) =
    (l.filter (fun e => e.familyIdx == famIdx)).modify
      (l.take idx |>.filter (fun e => e.familyIdx == famIdx)).length f := by
  induction l generalizing idx with
  | nil => simp at h_idx
  | cons hd tl ih =>
    cases idx with
    | zero =>
      simp only [List.modify_cons, ite_true, List.take_zero, List.filter_nil, List.length_nil, List.filter_cons]
      have heq : ((f hd).familyIdx == famIdx) = (hd.familyIdx == famIdx) := by
        simp only [beq_iff_eq, hf]
      have h_passes' : (hd.familyIdx == famIdx) = true := h_passes
      simp only [h_passes', ↓reduceIte, heq, List.modify_cons, ite_true]
    | succ n =>
      simp only [List.modify_cons, Nat.add_one_ne_zero, ↓reduceIte, Nat.add_one_sub_one,
        List.take_succ_cons, List.filter_cons]
      have h_idx' : n < tl.length := Nat.lt_of_succ_lt_succ h_idx
      have h_passes' : ((tl.get ⟨n, h_idx'⟩).familyIdx == famIdx) = true := by
        simp only [List.get_cons_succ] at h_passes
        exact h_passes
      cases hb : hd.familyIdx == famIdx
      · simp only [Bool.false_eq_true, ↓reduceIte]
        exact ih n h_idx' h_passes'
      · simp only [↓reduceIte, List.length_cons, List.modify_cons, Nat.add_one_ne_zero,
          ite_false, Nat.add_one_sub_one]
        congr 1
        exact ih n h_idx' h_passes'

/-- map . modify = map when the modifier doesn't affect the mapped field -/
private lemma map_modify_eq_map_of_eq {α β : Type*} (l : List α) (idx : Nat) (f : α → α) (g : α → β)
    (hf : ∀ a, g (f a) = g a) :
    (l.modify idx f).map g = l.map g := by
  ext i; simp [List.getElem?_modify]; split_ifs <;> simp [hf]

/--
If seed.timeIndices famIdx = [timeIdx], then addFormula at (famIdx, timeIdx) preserves single-time.
addFormula only modifies/adds entries at the same (famIdx, timeIdx) position.
-/
theorem addFormula_preserves_single_time (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (ty : SeedEntryType)
    (h_single : seed.timeIndices famIdx = [timeIdx]) :
    (seed.addFormula famIdx timeIdx phi ty).timeIndices famIdx = [timeIdx] := by
  unfold ModelSeed.timeIndices at *
  unfold ModelSeed.addFormula
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | some idx =>
    simp only [h_find]
    -- The modifier doesn't change familyIdx or timeIdx
    have h_fam_eq : ∀ e : SeedEntry, ({ e with formulas := insert phi e.formulas } : SeedEntry).familyIdx = e.familyIdx := by
      intro e; rfl
    have h_time_eq : ∀ e : SeedEntry, ({ e with formulas := insert phi e.formulas } : SeedEntry).timeIdx = e.timeIdx := by
      intro e; rfl
    -- Get idx bounds and filter predicate from findIdx? result
    have h_findIdx_iff := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx : idx < seed.entries.length := h_findIdx_iff.1
    have h_passes : ((seed.entries.get ⟨idx, h_idx⟩).familyIdx == famIdx) = true := by
      have h_pred := h_findIdx_iff.2.1
      simp only [Bool.and_eq_true] at h_pred
      rw [List.get_eq_getElem]
      exact h_pred.1
    -- Show filter commutes with modify
    have h1 := filter_modify_eq_modify_filter seed.entries idx
      (fun e => { e with formulas := insert phi e.formulas }) h_fam_eq famIdx h_idx h_passes
    rw [h1]
    -- Show map commutes with modify
    have h2 := map_modify_eq_map_of_eq
      (List.filter (fun e => e.familyIdx == famIdx) seed.entries)
      ((seed.entries.take idx).filter (fun e => e.familyIdx == famIdx)).length
      (fun e => { e with formulas := insert phi e.formulas })
      SeedEntry.timeIdx h_time_eq
    rw [h2]
    exact h_single
  | none =>
    simp only [h_find]
    -- New entry case: append adds entry with same timeIdx
    simp only [List.filter_append, List.map_append]
    -- The new entry has famIdx and timeIdx, so filter keeps it
    simp only [List.filter_cons, List.filter_nil, beq_self_eq_true, ↓reduceIte]
    simp only [List.map_cons, List.map_nil]
    -- eraseDups (oldTimes ++ [timeIdx]) = [timeIdx] since oldTimes all equal timeIdx
    have h_all_eq := all_eq_of_eraseDups_singleton h_single
    -- So eraseDups of (all timeIdx) ++ [timeIdx] = [timeIdx]
    apply eraseDups_all_same
    · intro t ht
      rw [List.mem_append] at ht
      cases ht with
      | inl h => exact h_all_eq t h
      | inr h => simp only [List.mem_singleton] at h; exact h
    · simp

/--
If seed.timeIndices famIdx = [timeIdx], then addToAllFamilies at timeIdx preserves single-time.
-/
theorem addToAllFamilies_preserves_single_time (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (h_single_fam : seed.familyIndices = [famIdx])
    (h_single_time : seed.timeIndices famIdx = [timeIdx]) :
    (seed.addToAllFamilies timeIdx phi).timeIndices famIdx = [timeIdx] := by
  unfold ModelSeed.addToAllFamilies ModelSeed.familyIndices at *
  simp only [h_single_fam, List.foldl_cons, List.foldl_nil]
  exact addFormula_preserves_single_time seed famIdx timeIdx phi .universal_target h_single_time

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
      have h4 := addToAllFutureTimes_preserves_familyIndices' _ famIdx timeIdx (.all_future psi) idx h3
      have h_lt : psi.complexity < c := by rw [← h_c]; simp [Formula.complexity]
      exact ih psi.complexity h_lt psi famIdx timeIdx _ rfl h4
    | Formula.all_past psi =>
      simp only [buildSeedAux]
      have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.all_past psi) .universal_target idx h_in
      have h2 := addFormula_preserves_familyIndices' _ famIdx timeIdx psi .universal_target idx h1
      have h3 := addToAllPastTimes_preserves_familyIndices' _ famIdx timeIdx psi idx h2
      have h4 := addToAllPastTimes_preserves_familyIndices' _ famIdx timeIdx (.all_past psi) idx h3
      have h_lt : psi.complexity < c := by rw [← h_c]; simp [Formula.complexity]
      exact ih psi.complexity h_lt psi famIdx timeIdx _ rfl h4
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
      -- We use unique positions: if two entries have same (familyIdx, timeIdx), they're equal.
      -- The modified entry has the same (familyIdx, timeIdx) as original, so it can't match
      -- any other entry which has a different position.
      rw [List.nodup_iff_getElem?_ne_getElem?]
      intro i j h_i_lt_j h_j_lt
      let f : SeedEntry → SeedEntry := fun e => ⟨e.familyIdx, e.timeIdx, insert phi e.formulas, e.entryType⟩
      have h_len := List.length_modify f seed.entries idx
      rw [h_len] at h_j_lt
      have h_i_lt_len : i < seed.entries.length := Nat.lt_trans h_i_lt_j h_j_lt
      -- Key helper: f preserves position (familyIdx, timeIdx)
      have h_f_pos : ∀ e : SeedEntry, (f e).familyIdx = e.familyIdx ∧ (f e).timeIdx = e.timeIdx :=
        fun e => ⟨rfl, rfl⟩
      -- Get elements at positions i and j in the modified list
      rw [List.getElem?_modify f idx seed.entries i, List.getElem?_modify f idx seed.entries j]
      have h_some_i : seed.entries[i]? = some seed.entries[i] := List.getElem?_eq_some_iff.mpr ⟨h_i_lt_len, rfl⟩
      have h_some_j : seed.entries[j]? = some seed.entries[j] := List.getElem?_eq_some_iff.mpr ⟨h_j_lt, rfl⟩
      simp only [h_some_i, h_some_j, Option.map, ne_eq]
      intro h_eq
      -- After simp: h_eq : some (if idx = i then f seed.entries[i] else seed.entries[i]) =
      --                    some (if idx = j then f seed.entries[j] else seed.entries[j])
      have h_eq' : (if idx = i then f seed.entries[i] else seed.entries[i]) =
                   (if idx = j then f seed.entries[j] else seed.entries[j]) := by
        injection h_eq
      -- The key insight: f preserves familyIdx and timeIdx, so we can extract position equality
      have h_pos_i : (if idx = i then f seed.entries[i] else seed.entries[i]).familyIdx =
                     seed.entries[i].familyIdx ∧
                     (if idx = i then f seed.entries[i] else seed.entries[i]).timeIdx =
                     seed.entries[i].timeIdx := by
        by_cases h_eq_i : idx = i <;> simp only [h_eq_i, ↓reduceIte, h_f_pos, and_self]
      have h_pos_j : (if idx = j then f seed.entries[j] else seed.entries[j]).familyIdx =
                     seed.entries[j].familyIdx ∧
                     (if idx = j then f seed.entries[j] else seed.entries[j]).timeIdx =
                     seed.entries[j].timeIdx := by
        by_cases h_eq_j : idx = j <;> simp only [h_eq_j, ↓reduceIte, h_f_pos, and_self]
      -- From h_eq' we get equal positions
      have h_fam_eq : seed.entries[i].familyIdx = seed.entries[j].familyIdx :=
        h_pos_i.1.symm.trans (congrArg SeedEntry.familyIdx h_eq' |>.trans h_pos_j.1)
      have h_time_eq : seed.entries[i].timeIdx = seed.entries[j].timeIdx :=
        h_pos_i.2.symm.trans (congrArg SeedEntry.timeIdx h_eq' |>.trans h_pos_j.2)
      -- But entries[i] ≠ entries[j] by nodup, so they must have different positions
      have h_ei_in : seed.entries[i] ∈ seed.entries := List.getElem_mem h_i_lt_len
      have h_ej_in : seed.entries[j] ∈ seed.entries := List.getElem_mem h_j_lt
      have h_idx_ne : seed.entries[i] ≠ seed.entries[j] := by
        intro h_eq''
        have : i = j := List.Nodup.getElem_inj_iff h_wf.2.2 |>.mp h_eq''
        omega
      exact h_wf.2.1 _ h_ei_in _ h_ej_in h_idx_ne ⟨h_fam_eq, h_time_eq⟩
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
If Box phi is consistent, then phi is consistent.
Proof: By contraposition. If phi is inconsistent, then [phi] ⊢ ⊥.
By deduction: [] ⊢ neg phi.
By necessitation: [] ⊢ Box(neg phi).
With Box phi, we have [Box phi, Box(neg phi)] ⊢ phi ∧ neg phi ⊢ ⊥ via T-axiom.
Hence Box phi is inconsistent.
-/
theorem box_consistent_implies_content_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.box phi)) :
    FormulaConsistent phi := by
  intro ⟨d, _⟩
  apply h
  -- d : DerivationTree [phi] bot
  -- We need: DerivationTree [Box phi] bot
  -- From [phi] ⊢ ⊥, by deduction: [] ⊢ phi → ⊥ = [] ⊢ phi.neg
  have d_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg :=
    deduction_theorem [] phi Formula.bot d
  -- By necessitation: [] ⊢ Box(phi.neg)
  have d_box_neg : Bimodal.ProofSystem.DerivationTree [] (Formula.box phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.necessitation _ d_neg
  -- Weakening: [Box phi] ⊢ Box(phi.neg)
  have d_box_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.box phi] (Formula.box phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_box_neg (by intro; simp)
  -- We also have [Box phi] ⊢ Box phi (assumption)
  have d_box_phi : Bimodal.ProofSystem.DerivationTree [Formula.box phi] (Formula.box phi) :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  -- By T-axiom: Box phi ⊢ phi and Box(neg phi) ⊢ neg phi
  have d_T_phi : Bimodal.ProofSystem.DerivationTree [] ((Formula.box phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t phi)
  have d_T_neg : Bimodal.ProofSystem.DerivationTree [] ((Formula.box phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t phi.neg)
  -- Weaken to context [Box phi]
  have d_T_phi_weak : Bimodal.ProofSystem.DerivationTree [Formula.box phi] ((Formula.box phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_phi (by intro; simp)
  have d_T_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.box phi] ((Formula.box phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_neg (by intro; simp)
  -- MP to get [Box phi] ⊢ phi and [Box phi] ⊢ neg phi
  have d_phi : Bimodal.ProofSystem.DerivationTree [Formula.box phi] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_phi_weak d_box_phi
  have d_neg_phi : Bimodal.ProofSystem.DerivationTree [Formula.box phi] phi.neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_neg_weak d_box_neg_weak
  -- phi and neg phi give ⊥
  exact ⟨derives_bot_from_phi_neg_phi d_phi d_neg_phi, trivial⟩

/--
If G phi (all_future) is consistent, then phi is consistent.
Proof: Same structure as box_consistent_implies_content_consistent, using temp_t_future axiom.
-/
theorem all_future_consistent_implies_content_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.all_future phi)) :
    FormulaConsistent phi := by
  intro ⟨d, _⟩
  apply h
  -- From [phi] ⊢ ⊥, derive [] ⊢ phi.neg, then [] ⊢ G(phi.neg)
  -- With [G phi], we get phi and neg phi via T-axiom, contradiction
  have d_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg :=
    deduction_theorem [] phi Formula.bot d
  have d_G_neg : Bimodal.ProofSystem.DerivationTree [] (Formula.all_future phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ d_neg
  have d_G_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] (Formula.all_future phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_G_neg (by intro; simp)
  have d_G_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] (Formula.all_future phi) :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  -- T-axiom: G phi -> phi
  have d_T_phi : Bimodal.ProofSystem.DerivationTree [] ((Formula.all_future phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future phi)
  have d_T_neg : Bimodal.ProofSystem.DerivationTree [] ((Formula.all_future phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future phi.neg)
  have d_T_phi_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] ((Formula.all_future phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_phi (by intro; simp)
  have d_T_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] ((Formula.all_future phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_neg (by intro; simp)
  have d_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_phi_weak d_G_phi
  have d_neg_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_future phi] phi.neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_neg_weak d_G_neg_weak
  exact ⟨derives_bot_from_phi_neg_phi d_phi d_neg_phi, trivial⟩

/--
If H phi (all_past) is consistent, then phi is consistent.
Proof: Same structure as all_future_consistent_implies_content_consistent, using temp_t_past axiom.
-/
theorem all_past_consistent_implies_content_consistent {phi : Formula}
    (h : FormulaConsistent (Formula.all_past phi)) :
    FormulaConsistent phi := by
  intro ⟨d, _⟩
  apply h
  have d_neg : Bimodal.ProofSystem.DerivationTree [] phi.neg :=
    deduction_theorem [] phi Formula.bot d
  have d_H_neg : Bimodal.ProofSystem.DerivationTree [] (Formula.all_past phi.neg) :=
    Bimodal.Theorems.past_necessitation _ d_neg
  have d_H_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] (Formula.all_past phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_H_neg (by intro; simp)
  have d_H_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] (Formula.all_past phi) :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have d_T_phi : Bimodal.ProofSystem.DerivationTree [] ((Formula.all_past phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past phi)
  have d_T_neg : Bimodal.ProofSystem.DerivationTree [] ((Formula.all_past phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past phi.neg)
  have d_T_phi_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] ((Formula.all_past phi).imp phi) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_phi (by intro; simp)
  have d_T_neg_weak : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] ((Formula.all_past phi.neg).imp phi.neg) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_T_neg (by intro; simp)
  have d_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] phi :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_phi_weak d_H_phi
  have d_neg_phi : Bimodal.ProofSystem.DerivationTree [Formula.all_past phi] phi.neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_T_neg_weak d_H_neg_weak
  exact ⟨derives_bot_from_phi_neg_phi d_phi d_neg_phi, trivial⟩

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
createNewFamily creates a new family with exactly one time index.
The new family's timeIndices is [timeIdx].
-/
theorem createNewFamily_timeIndices_new_family
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed) :
    let (seed', newFamIdx) := seed.createNewFamily timeIdx phi
    seed'.timeIndices newFamIdx = [timeIdx] := by
  simp only [ModelSeed.createNewFamily, ModelSeed.timeIndices]
  -- Filter entries for newFamIdx = seed.nextFamilyIdx
  -- No existing entry has familyIdx = nextFamilyIdx (by well-formedness)
  have h_no_old : (seed.entries.filter (fun e => e.familyIdx == seed.nextFamilyIdx)).length = 0 := by
    rw [List.length_eq_zero_iff]
    apply List.filter_eq_nil_iff.mpr
    intro e he
    have h_lt := h_wf.1 e he
    simp only [beq_iff_eq, Bool.eq_false_iff]
    omega
  simp only [List.filter_append]
  -- The old entries contribute nothing for the new family
  have h_filter_old : seed.entries.filter (fun e => e.familyIdx == seed.nextFamilyIdx) = [] := by
    rwa [List.length_eq_zero_iff] at h_no_old
  rw [h_filter_old]
  simp only [List.nil_append, List.filter_cons, beq_self_eq_true, ↓reduceIte,
             List.filter_nil, List.map]
  rfl

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

/-!
## Membership Lemmas for Seed Operations

These lemmas characterize how formulas are added to seed positions by various operations.
-/

/--
Helper: foldl with addFormula over a family list preserves SeedConsistent.
-/
private theorem foldl_addFormula_preserves_consistent
    (famList : List Nat) (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_cons : SeedConsistent seed)
    (h_phi_cons : FormulaConsistent phi)
    (h_compat : ∀ entry ∈ seed.entries, entry.timeIdx = timeIdx →
                SetConsistent (insert phi entry.formulas)) :
    SeedConsistent (famList.foldl (fun s famIdx => s.addFormula famIdx timeIdx phi .universal_target) seed) := by
  induction famList generalizing seed with
  | nil => exact h_cons
  | cons f fs ih =>
    simp only [List.foldl_cons]
    apply ih
    · -- addFormula preserves SeedConsistent
      apply addFormula_seed_preserves_consistent
      · exact h_cons
      · exact h_phi_cons
      · intro entry h_entry h_fam h_time
        exact h_compat entry h_entry h_time
    · -- Compatibility for entries in the modified seed
      intro entry h_entry h_time
      unfold ModelSeed.addFormula at h_entry
      cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == f && e.timeIdx == timeIdx) with
      | some idx =>
        simp only [h_find] at h_entry
        rw [List.mem_modify_iff] at h_entry
        cases h_entry with
        | inl h_old =>
          obtain ⟨j, hj, _⟩ := h_old
          exact h_compat entry (List.mem_of_getElem? hj) h_time
        | inr h_mod =>
          obtain ⟨old_entry, h_old, h_eq⟩ := h_mod
          subst h_eq
          simp only
          have h_mem := List.mem_of_getElem? h_old
          have h_pred := List.findIdx?_eq_some_iff_getElem.mp h_find
          obtain ⟨h_lt, h_pred_holds, _⟩ := h_pred
          have h_idx_time : old_entry.timeIdx = timeIdx := by
            have h_old_some := (List.getElem?_eq_some_iff.mp h_old)
            simp only [beq_iff_eq, Bool.and_eq_true] at h_pred_holds
            rw [h_old_some.2] at h_pred_holds
            exact h_pred_holds.2
          rw [Set.insert_idem]
          exact h_compat old_entry h_mem h_idx_time
      | none =>
        simp only [h_find] at h_entry
        rw [List.mem_append, List.mem_singleton] at h_entry
        cases h_entry with
        | inl h_old => exact h_compat entry h_old h_time
        | inr h_new =>
          subst h_new
          simp only
          rw [Set.insert_eq_of_mem (Set.mem_singleton_iff.mpr rfl)]
          exact singleton_consistent_iff.mpr h_phi_cons

/--
addToAllFamilies preserves consistency if phi is consistent and compatible with all entries.
-/
theorem addToAllFamilies_preserves_consistent
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_cons : SeedConsistent seed)
    (h_phi_cons : FormulaConsistent phi)
    (h_compat : ∀ entry ∈ seed.entries, entry.timeIdx = timeIdx →
                SetConsistent (insert phi entry.formulas)) :
    SeedConsistent (seed.addToAllFamilies timeIdx phi) := by
  unfold ModelSeed.addToAllFamilies
  exact foldl_addFormula_preserves_consistent _ seed timeIdx phi h_cons h_phi_cons h_compat

/--
Helper: foldl with addFormula over a family list preserves well-formedness.
-/
private theorem foldl_addFormula_preserves_wellFormed
    (famList : List Nat) (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_valid : ∀ f ∈ famList, f < seed.nextFamilyIdx) :
    SeedWellFormed (famList.foldl (fun s famIdx => s.addFormula famIdx timeIdx phi .universal_target) seed) := by
  induction famList generalizing seed with
  | nil => exact h_wf
  | cons f fs ih =>
    simp only [List.foldl_cons]
    apply ih
    · apply addFormula_preserves_wellFormed
      · exact h_wf
      · intro _; exact h_valid f (by simp)
    · intro f' hf'
      rw [addFormula_nextFamilyIdx]
      exact h_valid f' (by simp [hf'])

/--
Helper: eraseDups subset by length induction.
-/
private theorem eraseDups_subset_length {α : Type*} [BEq α] [LawfulBEq α] :
    ∀ (n : Nat) (l : List α), l.length ≤ n → l.eraseDups ⊆ l := by
  intro n
  induction n with
  | zero =>
    intro l hl
    have h_empty : l = [] := List.eq_nil_of_length_eq_zero (Nat.le_zero.mp hl)
    simp [h_empty]
  | succ n ih =>
    intro l hl
    match l with
    | [] => simp
    | x :: xs =>
      simp only [List.eraseDups_cons]
      intro a h
      rw [List.mem_cons] at h ⊢
      rcases h with h | h
      · left; exact h
      · right
        have h_filter_len : (List.filter (fun b => !b == x) xs).length ≤ n := by
          calc (List.filter (fun b => !b == x) xs).length
              ≤ xs.length := List.length_filter_le _ _
            _ ≤ n := by simp only [List.length_cons] at hl; omega
        have h1 : (List.filter (fun b => !b == x) xs).eraseDups ⊆ List.filter (fun b => !b == x) xs :=
          ih (List.filter (fun b => !b == x) xs) h_filter_len
        have h2 : a ∈ List.filter (fun b => !b == x) xs := h1 h
        exact List.mem_of_mem_filter h2

/--
Helper: membership in eraseDups implies membership in original list.
-/
private theorem mem_of_eraseDups {α : Type*} [BEq α] [LawfulBEq α] {l : List α} {a : α}
    (h : a ∈ l.eraseDups) : a ∈ l :=
  eraseDups_subset_length l.length l (le_refl _) h

/--
addToAllFamilies preserves well-formedness.
-/
theorem addToAllFamilies_preserves_wellFormed
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed) :
    SeedWellFormed (seed.addToAllFamilies timeIdx phi) := by
  unfold ModelSeed.addToAllFamilies
  apply foldl_addFormula_preserves_wellFormed
  · exact h_wf
  · intro f hf
    have h_in : f ∈ seed.entries.map SeedEntry.familyIdx := mem_of_eraseDups hf
    obtain ⟨entry, h_entry, h_fam⟩ := List.mem_map.mp h_in
    rw [← h_fam]
    exact h_wf.1 entry h_entry

/--
Helper: foldl with addFormula over a time list preserves well-formedness.
-/
private theorem foldl_addFormula_times_preserves_wellFormed
    (timeList : List Int) (seed : ModelSeed) (famIdx : Nat) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_valid : famIdx < seed.nextFamilyIdx) :
    SeedWellFormed (timeList.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed) := by
  induction timeList generalizing seed with
  | nil => exact h_wf
  | cons t ts ih =>
    simp only [List.foldl_cons]
    apply ih
    · apply addFormula_preserves_wellFormed
      · exact h_wf
      · intro _; exact h_valid
    · rw [addFormula_nextFamilyIdx]
      exact h_valid

/--
addToAllFutureTimes preserves well-formedness.
-/
theorem addToAllFutureTimes_preserves_wellFormed
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_valid : famIdx < seed.nextFamilyIdx) :
    SeedWellFormed (seed.addToAllFutureTimes famIdx currentTime phi) := by
  unfold ModelSeed.addToAllFutureTimes
  exact foldl_addFormula_times_preserves_wellFormed _ seed famIdx phi h_wf h_valid

/--
addToAllPastTimes preserves well-formedness.
-/
theorem addToAllPastTimes_preserves_wellFormed
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_valid : famIdx < seed.nextFamilyIdx) :
    SeedWellFormed (seed.addToAllPastTimes famIdx currentTime phi) := by
  unfold ModelSeed.addToAllPastTimes
  exact foldl_addFormula_times_preserves_wellFormed _ seed famIdx phi h_wf h_valid

/-!
### addToAllFutureTimes/addToAllPastTimes Consistency Preservation

These lemmas show that adding a formula to all future/past times preserves seed consistency,
provided that the formula is derivable at each affected entry.

Key insight: If G psi is present at all entries where psi is being added, then psi is
derivable via temp_t_future (G psi -> psi), so adding psi preserves consistency.

**Current status**: The lemmas below require G psi to be present at future entries.
For the construction to satisfy this, G psi must be propagated to future times.
Currently, buildSeedAux only propagates psi, not G psi. This is a gap that requires
either:
1. Modifying buildSeedAux to also propagate G psi (semantically correct)
2. Using the no-op trick (single-time means no future times)
3. A different proof strategy

For now, these lemmas provide the template for what's needed.
-/

/-- Membership in eraseDups implies membership in original list. -/
private lemma mem_eraseDups_imp_mem {α : Type*} [BEq α] [LawfulBEq α] {a : α} (l : List α)
    (h : a ∈ l.eraseDups) : a ∈ l := by
  match l with
  | [] => simp [List.eraseDups] at h
  | x :: xs =>
    rw [List.eraseDups_cons] at h
    simp only [List.mem_cons] at h ⊢
    cases h with
    | inl heq => exact Or.inl heq
    | inr h_rest =>
      right
      have h_in_filter := mem_eraseDups_imp_mem (xs.filter (fun b => !(b == x))) h_rest
      exact (List.mem_filter.mp h_in_filter).1
termination_by l.length
decreasing_by
  simp_wf
  calc (List.filter (fun b => !b == x) xs).length
      ≤ xs.length := List.length_filter_le _ _
    _ < (x :: xs).length := by simp

/-- eraseDups produces a list with no duplicates. -/
private lemma nodup_eraseDups {α : Type*} [BEq α] [LawfulBEq α] (l : List α) :
    l.eraseDups.Nodup := by
  match l with
  | [] => simp [List.eraseDups]
  | x :: xs =>
    rw [List.eraseDups_cons]
    apply List.Nodup.cons
    · intro h
      have h' := mem_eraseDups_imp_mem _ h
      simp only [List.mem_filter, beq_self_eq_true, Bool.not_true, and_false] at h'
      exact Bool.false_ne_true h'.2  -- false = true is absurd
    · exact nodup_eraseDups (xs.filter (fun b => !(b == x)))
termination_by l.length
decreasing_by
  simp_wf
  calc (List.filter (fun b => !b == x) xs).length
      ≤ xs.length := List.length_filter_le _ _
    _ < (x :: xs).length := by simp

/--
addToAllFutureTimes preserves seed consistency when G psi is present at all future entries.

**Key Insight**: If G psi is in each future time entry's formula set, then psi is
derivable via temp_t_future (`G psi -> psi`). This derivation witnesses that adding
psi preserves consistency.

**Note**: This version requires G psi to be at all future entries. For the construction
to satisfy this, G psi must be propagated to future times along with psi. See the
positive G case in buildSeedAux_preserves_seedConsistent for how this applies.
-/
-- Helper: foldl adding psi to times preserves consistency when G psi is at each target entry
private theorem foldl_addFormula_times_preserves_consistent_with_gpsi
    (timeList : List Int) (seed : ModelSeed) (famIdx : Nat) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_nodup : timeList.Nodup)
    (h_gpsi_compat : ∀ t ∈ timeList, ∀ entry ∈ seed.entries,
        entry.familyIdx = famIdx → entry.timeIdx = t →
        psi.all_future ∈ entry.formulas) :
    SeedConsistent (timeList.foldl (fun s t => s.addFormula famIdx t psi .universal_target) seed) := by
  induction timeList generalizing seed with
  | nil => exact h_seed_cons
  | cons t ts ih =>
    simp only [List.foldl_cons]
    -- Get the nodup info for the tail
    have h_nodup_tail : ts.Nodup := (List.nodup_cons.mp h_nodup).2
    have h_t_not_in_ts : t ∉ ts := (List.nodup_cons.mp h_nodup).1
    apply ih
    · -- addFormula preserves SeedConsistent
      apply addFormula_seed_preserves_consistent
      · exact h_seed_cons
      · exact h_psi_cons
      · intro entry h_entry h_fam h_time
        -- entry is at (famIdx, t) in seed, so G psi ∈ entry.formulas
        have h_gpsi_in : psi.all_future ∈ entry.formulas :=
          h_gpsi_compat t (List.mem_cons_self) entry h_entry h_fam h_time
        -- psi is derivable from G psi via temp_t_future
        have h_entry_cons : SetConsistent entry.formulas := h_seed_cons entry h_entry
        have d_psi : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ entry.formulas) ∧
            Nonempty (Bimodal.ProofSystem.DerivationTree L psi) := by
          use [psi.all_future]
          constructor
          · intro ψ hψ; simp only [List.mem_singleton] at hψ; rw [hψ]; exact h_gpsi_in
          · constructor
            have d_t : Bimodal.ProofSystem.DerivationTree [] (psi.all_future.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future psi)
            have d_gpsi : Bimodal.ProofSystem.DerivationTree [psi.all_future] psi.all_future :=
              Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
            have d_t' : Bimodal.ProofSystem.DerivationTree [psi.all_future] (psi.all_future.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_t (by intro; simp)
            exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_t' d_gpsi
        exact addFormula_preserves_consistent h_entry_cons d_psi
    · -- ts.Nodup
      exact h_nodup_tail
    · -- G psi compat for remaining times in modified seed
      intro t' ht' entry h_entry h_fam h_time
      unfold ModelSeed.addFormula at h_entry
      cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == t) with
      | some idx =>
        simp only [h_find] at h_entry
        rw [List.mem_modify_iff] at h_entry
        cases h_entry with
        | inl h_old =>
          obtain ⟨j, hj, _⟩ := h_old
          exact h_gpsi_compat t' (List.mem_cons_of_mem t ht') entry (List.mem_of_getElem? hj) h_fam h_time
        | inr h_mod =>
          obtain ⟨old_entry, h_old, h_eq⟩ := h_mod
          subst h_eq
          simp only
          have h_mem := List.mem_of_getElem? h_old
          have h_pred := List.findIdx?_eq_some_iff_getElem.mp h_find
          obtain ⟨_, h_pred_holds, _⟩ := h_pred
          have h_old_fam : old_entry.familyIdx = famIdx := by
            have h_old_some := (List.getElem?_eq_some_iff.mp h_old)
            simp only [beq_iff_eq, Bool.and_eq_true] at h_pred_holds
            rw [h_old_some.2] at h_pred_holds
            exact h_pred_holds.1
          -- h_time says old_entry.timeIdx = t', but modified entry preserves timeIdx
          -- Since old_entry.familyIdx = famIdx = h_fam and old_entry.timeIdx = t' = h_time
          have h_gpsi_in := h_gpsi_compat t' (List.mem_cons_of_mem t ht') old_entry h_mem h_old_fam h_time
          exact Set.mem_insert_of_mem psi h_gpsi_in
      | none =>
        simp only [h_find] at h_entry
        rw [List.mem_append, List.mem_singleton] at h_entry
        cases h_entry with
        | inl h_old => exact h_gpsi_compat t' (List.mem_cons_of_mem t ht') entry h_old h_fam h_time
        | inr h_new =>
          subst h_new
          simp only at h_fam h_time
          -- New entry has formulas = {psi}, not G psi
          -- But if t' = t, then we're looking at the new entry which has psi, not G psi
          -- The h_find = none means no existing entry at (famIdx, t)
          -- But the new entry has timeIdx = t, and h_time says timeIdx = t'
          -- So t = t', but we have ts which doesn't include t (since t is head)
          -- Wait, ht' : t' ∈ ts, so t' ≠ t (unless ts has duplicates)
          -- The new entry has timeIdx = t, but h_time says entry.timeIdx = t' with t' ∈ ts
          -- Since entry is the new entry {psi}, its timeIdx = t
          -- But h_time says t = t', yet t' ∈ ts (the tail after removing t)
          -- The time list comes from eraseDups, so there are no duplicates
          -- If t' ∈ ts and new entry has timeIdx = t (head), then t ≠ t' unless ts has t
          -- This means the case is impossible because t' ≠ t
          -- Case is impossible: t = t' but t ∉ ts and t' ∈ ts
          exfalso
          -- h_time gives t = t' (new entry has timeIdx = t)
          have h_t_eq_t' : t = t' := h_time
          -- ht' : t' ∈ ts, so by substitution t ∈ ts
          rw [← h_t_eq_t'] at ht'
          -- But h_t_not_in_ts : t ∉ ts - contradiction!
          exact h_t_not_in_ts ht'

theorem addToAllFutureTimes_preserves_seedConsistent_with_gpsi
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_gpsi_at_futures : ∀ entry ∈ seed.entries,
        entry.familyIdx = famIdx → entry.timeIdx > currentTime →
        psi.all_future ∈ entry.formulas) :
    SeedConsistent (seed.addToAllFutureTimes famIdx currentTime psi) := by
  unfold ModelSeed.addToAllFutureTimes
  apply foldl_addFormula_times_preserves_consistent_with_gpsi
  · exact h_seed_cons
  · exact h_psi_cons
  · exact nodup_eraseDups _
  · intro t ht entry h_entry h_fam h_time
    -- t is in the future times list, so entry.timeIdx = t > currentTime
    -- Need to show t > currentTime
    have h_t_future : t > currentTime := by
      -- t comes from filtering entries with timeIdx > currentTime
      have ht' := mem_eraseDups_imp_mem _ ht
      simp only [List.mem_map, List.mem_filter] at ht'
      obtain ⟨e, ⟨he_mem, he_filter⟩, he_t⟩ := ht'
      simp only [Bool.and_eq_true, decide_eq_true_eq] at he_filter
      rw [← he_t]
      exact he_filter
    exact h_gpsi_at_futures entry h_entry h_fam (h_time ▸ h_t_future)

-- Helper: foldl adding psi to times preserves consistency when H psi is at each target entry
private theorem foldl_addFormula_times_preserves_consistent_with_hpsi
    (timeList : List Int) (seed : ModelSeed) (famIdx : Nat) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_nodup : timeList.Nodup)
    (h_hpsi_compat : ∀ t ∈ timeList, ∀ entry ∈ seed.entries,
        entry.familyIdx = famIdx → entry.timeIdx = t →
        psi.all_past ∈ entry.formulas) :
    SeedConsistent (timeList.foldl (fun s t => s.addFormula famIdx t psi .universal_target) seed) := by
  induction timeList generalizing seed with
  | nil => exact h_seed_cons
  | cons t ts ih =>
    simp only [List.foldl_cons]
    have h_nodup_tail : ts.Nodup := (List.nodup_cons.mp h_nodup).2
    have h_t_not_in_ts : t ∉ ts := (List.nodup_cons.mp h_nodup).1
    apply ih
    · -- addFormula preserves SeedConsistent
      apply addFormula_seed_preserves_consistent
      · exact h_seed_cons
      · exact h_psi_cons
      · intro entry h_entry h_fam h_time
        -- entry is at (famIdx, t) in seed, so H psi ∈ entry.formulas
        have h_hpsi_in : psi.all_past ∈ entry.formulas :=
          h_hpsi_compat t (List.mem_cons_self) entry h_entry h_fam h_time
        -- psi is derivable from H psi via temp_t_past
        have h_entry_cons : SetConsistent entry.formulas := h_seed_cons entry h_entry
        have d_psi : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ entry.formulas) ∧
            Nonempty (Bimodal.ProofSystem.DerivationTree L psi) := by
          use [psi.all_past]
          constructor
          · intro ψ hψ; simp only [List.mem_singleton] at hψ; rw [hψ]; exact h_hpsi_in
          · constructor
            have d_t : Bimodal.ProofSystem.DerivationTree [] (psi.all_past.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past psi)
            have d_hpsi : Bimodal.ProofSystem.DerivationTree [psi.all_past] psi.all_past :=
              Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
            have d_t' : Bimodal.ProofSystem.DerivationTree [psi.all_past] (psi.all_past.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_t (by intro; simp)
            exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_t' d_hpsi
        exact addFormula_preserves_consistent h_entry_cons d_psi
    · -- ts.Nodup
      exact h_nodup_tail
    · -- H psi compat for remaining times in modified seed
      intro t' ht' entry h_entry h_fam h_time
      unfold ModelSeed.addFormula at h_entry
      cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == t) with
      | some idx =>
        simp only [h_find] at h_entry
        rw [List.mem_modify_iff] at h_entry
        cases h_entry with
        | inl h_old =>
          obtain ⟨j, hj, _⟩ := h_old
          exact h_hpsi_compat t' (List.mem_cons_of_mem t ht') entry (List.mem_of_getElem? hj) h_fam h_time
        | inr h_mod =>
          obtain ⟨old_entry, h_old, h_eq⟩ := h_mod
          subst h_eq
          simp only
          have h_mem := List.mem_of_getElem? h_old
          have h_pred := List.findIdx?_eq_some_iff_getElem.mp h_find
          obtain ⟨_, h_pred_holds, _⟩ := h_pred
          have h_old_fam : old_entry.familyIdx = famIdx := by
            have h_old_some := (List.getElem?_eq_some_iff.mp h_old)
            simp only [beq_iff_eq, Bool.and_eq_true] at h_pred_holds
            rw [h_old_some.2] at h_pred_holds
            exact h_pred_holds.1
          have h_hpsi_in := h_hpsi_compat t' (List.mem_cons_of_mem t ht') old_entry h_mem h_old_fam h_time
          exact Set.mem_insert_of_mem psi h_hpsi_in
      | none =>
        simp only [h_find] at h_entry
        rw [List.mem_append, List.mem_singleton] at h_entry
        cases h_entry with
        | inl h_old => exact h_hpsi_compat t' (List.mem_cons_of_mem t ht') entry h_old h_fam h_time
        | inr h_new =>
          -- Case is impossible: t = t' but t ∉ ts and t' ∈ ts
          exfalso
          subst h_new
          simp only at h_fam h_time
          have h_t_eq_t' : t = t' := h_time
          rw [← h_t_eq_t'] at ht'
          exact h_t_not_in_ts ht'

/--
addToAllPastTimes preserves seed consistency when H psi is present at all past entries.

Symmetric to `addToAllFutureTimes_preserves_seedConsistent_with_gpsi` using temp_t_past.
-/
theorem addToAllPastTimes_preserves_seedConsistent_with_hpsi
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (psi : Formula)
    (h_seed_cons : SeedConsistent seed)
    (h_psi_cons : FormulaConsistent psi)
    (h_hpsi_at_pasts : ∀ entry ∈ seed.entries,
        entry.familyIdx = famIdx → entry.timeIdx < currentTime →
        psi.all_past ∈ entry.formulas) :
    SeedConsistent (seed.addToAllPastTimes famIdx currentTime psi) := by
  unfold ModelSeed.addToAllPastTimes
  apply foldl_addFormula_times_preserves_consistent_with_hpsi
  · exact h_seed_cons
  · exact h_psi_cons
  · exact nodup_eraseDups _
  · intro t ht entry h_entry h_fam h_time
    -- t is in the past times list, so entry.timeIdx = t < currentTime
    have h_t_past : t < currentTime := by
      have ht' := mem_eraseDups_imp_mem _ ht
      simp only [List.mem_map, List.mem_filter] at ht'
      obtain ⟨e, ⟨he_mem, he_filter⟩, he_t⟩ := ht'
      simp only [Bool.and_eq_true, decide_eq_true_eq] at he_filter
      rw [← he_t]
      exact he_filter
    exact h_hpsi_at_pasts entry h_entry h_fam (h_time ▸ h_t_past)

/--
Helper: find? on modified list returns the modified element if predicate is preserved.
NOTE: This lemma is not currently used.
-/
private lemma find?_modify_of_preserves {α : Type*} (l : List α) (idx : Nat) (f : α → α) (p : α → Bool)
    (h_idx : idx < l.length)
    (h_pred : p (l.get ⟨idx, h_idx⟩) = true)
    (h_pres : p (f (l.get ⟨idx, h_idx⟩)) = true)
    (h_first : ∀ i (hi : i < idx), p (l.get ⟨i, Nat.lt_trans hi h_idx⟩) = false) :
    (l.modify idx f).find? p = some (f (l.get ⟨idx, h_idx⟩)) := by
  rw [List.find?_eq_some_iff_getElem]
  have h_len : (l.modify idx f).length = l.length := List.length_modify _ _ _
  constructor
  · exact h_pres
  · use idx, (h_len ▸ h_idx)
    constructor
    · rw [List.getElem_modify]; simp only [↓reduceIte, List.get_eq_getElem]
    · intro j hj
      rw [List.getElem_modify]
      split
      · omega
      · have hj_lt : j < l.length := Nat.lt_trans hj h_idx
        have := h_first j hj
        simp only [List.get_eq_getElem] at this
        simp only [this, Bool.not_false]

/--
addFormula adds phi to the target position's formulas.
-/
theorem addFormula_formula_in_getFormulas
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula) (newType : SeedEntryType) :
    phi ∈ (seed.addFormula famIdx timeIdx phi newType).getFormulas famIdx timeIdx := by
  unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | none =>
    -- New entry appended at end
    simp only
    rw [List.find?_append]
    have h_none : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = none := by
      rw [List.find?_eq_none]
      intro x hx
      have := List.findIdx?_eq_none_iff.mp h_find x hx
      simp only [Bool.not_eq_true]
      exact this
    simp only [h_none, Option.none_or, List.find?_cons_of_pos, beq_self_eq_true, Bool.and_self,
               Set.mem_singleton_iff]
  | some idx =>
    simp only
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred := h_spec.2.1
    set entry := seed.entries[idx] with h_entry_def
    set entry' := { entry with formulas := insert phi entry.formulas } with h_entry'_def
    -- Show find? returns entry' after modification
    have h_find_modified : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).find?
        (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = some entry' := by
      rw [List.find?_eq_some_iff_getElem]
      have h_len : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).length =
          seed.entries.length := List.length_modify _ _ _
      constructor
      · -- entry' satisfies predicate
        simp only [beq_iff_eq, Bool.and_eq_true] at h_pred ⊢
        exact h_pred
      · use idx, (h_len ▸ h_idx_lt)
        constructor
        · rw [List.getElem_modify]
          simp only [↓reduceIte, h_entry'_def, h_entry_def]
        · intro j hj
          rw [List.getElem_modify]
          split
          · omega
          · have := h_spec.2.2 j hj
            simp only [Bool.not_eq_true] at this
            simp only [this, Bool.not_false]
    rw [h_find_modified]
    simp only [h_entry'_def]
    exact Set.mem_insert phi entry.formulas

/--
Helper: addFormula at different family preserves getFormulas.
NOTE: API compatibility issues - marked sorry for now.
-/
private lemma addFormula_preserves_getFormulas_diff_fam
    (seed : ModelSeed) (famIdx famIdx' : Nat) (timeIdx : Int) (phi : Formula) (ty : SeedEntryType)
    (h_diff : famIdx ≠ famIdx') :
    (seed.addFormula famIdx' timeIdx phi ty).getFormulas famIdx timeIdx = seed.getFormulas famIdx timeIdx := by
  unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry
  let p := fun e : SeedEntry => e.familyIdx == famIdx && e.timeIdx == timeIdx
  let p' := fun e : SeedEntry => e.familyIdx == famIdx' && e.timeIdx == timeIdx
  cases h_find : seed.entries.findIdx? p' with
  | none =>
    simp only
    -- New entry appended with familyIdx = famIdx' ≠ famIdx
    rw [List.find?_append]
    have h_new_pred : p { familyIdx := famIdx', timeIdx := timeIdx, formulas := {phi}, entryType := ty } = false := by
      simp only [p, Bool.and_eq_false_iff]
      left
      simp only [beq_eq_false_iff_ne, ne_eq]
      exact Ne.symm h_diff
    have h_find_new : [{ familyIdx := famIdx', timeIdx := timeIdx, formulas := ({phi} : Set Formula), entryType := ty }].find? p = none := by
      rw [List.find?_eq_none]
      intro x hx
      simp only [List.mem_singleton] at hx
      subst hx
      simp only [Bool.not_eq_true]
      exact h_new_pred
    rw [h_find_new, Option.or_none]
  | some idx =>
    simp only
    -- Modification preserves find? result when the element at idx doesn't match our predicate p
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred := h_spec.2.1
    simp only [beq_iff_eq, Bool.and_eq_true, p'] at h_pred
    -- The entry at idx has familyIdx = famIdx' ≠ famIdx, so p entries[idx] = false
    have h_p_idx_false : p seed.entries[idx] = false := by
      simp only [p, Bool.and_eq_false_iff, beq_eq_false_iff_ne, ne_eq]
      left
      intro h
      have : famIdx = famIdx' := h.symm.trans h_pred.1
      exact h_diff this
    -- Key insight: modification at idx doesn't affect find? result when p entries[idx] = false
    -- Because if find? returns some entry at position j:
    -- - If j < idx: entries[j] is unchanged by modification
    -- - If j = idx: can't happen since p entries[idx] = false
    -- - If j > idx: entries[j] is unchanged by modification
    -- Use getFormulas characterization via Option.map
    cases h_find_orig : seed.entries.find? p with
    | none =>
      -- No entry matches p in original, show none matches in modified
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).find? p = none := by
        rw [List.find?_eq_none]
        intro x hx
        rw [List.mem_modify_iff] at hx
        cases hx with
        | inl h_unchanged =>
          obtain ⟨j, hj, _⟩ := h_unchanged
          have h_mem := List.mem_of_getElem? hj
          have := List.find?_eq_none.mp h_find_orig x h_mem
          simp only [Bool.not_eq_true] at this ⊢
          exact this
        | inr h_modified =>
          obtain ⟨old, h_old, h_eq⟩ := h_modified
          subst h_eq
          -- old = entries[idx], and we showed p entries[idx] = false
          have h_old_eq : old = seed.entries[idx] := by
            have := (List.getElem?_eq_some_iff.mp h_old).2
            exact this.symm
          simp only [Bool.not_eq_true]
          show p { old with formulas := insert phi old.formulas } = false
          simp only [p, h_old_eq]
          exact h_p_idx_false
      rw [h_find_mod]
    | some entry =>
      -- entry matches p, show modified list also returns entry (unchanged)
      have h_entry_pred := List.find?_some h_find_orig
      -- Use the characterization directly: get the first index where p is true
      have h_first := List.find?_eq_some_iff_getElem.mp h_find_orig
      obtain ⟨i, hi_lt, hi_eq, h_before_i⟩ := h_first.2
      -- i is the first index where entries[i] = entry (and p entry = true)
      -- We need to show i ≠ idx (since p entries[idx] = false but p entry = true)
      have h_i_ne_idx : i ≠ idx := by
        intro h_eq
        have h_p_i : p seed.entries[i] = true := by rw [hi_eq]; exact h_entry_pred
        have h_p_idx_eq : p seed.entries[idx] = true := h_eq ▸ h_p_i
        rw [h_p_idx_eq] at h_p_idx_false
        cases h_p_idx_false
      -- entry is unchanged in modified list since i ≠ idx
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).find? p = some entry := by
        rw [List.find?_eq_some_iff_getElem]
        have h_len := List.length_modify (fun e : SeedEntry => { e with formulas := insert phi e.formulas }) seed.entries idx
        constructor
        · exact h_entry_pred
        · -- Show entry is at position i in modified list (using first match index)
          use i, (h_len ▸ hi_lt)
          constructor
          · rw [List.getElem_modify]
            split
            · rename_i h_idx_eq_i; exfalso; exact h_i_ne_idx h_idx_eq_i.symm
            · exact hi_eq
          · -- All earlier positions don't match p
            intro k hk
            rw [List.getElem_modify]
            split
            · -- k = idx case: show p of modified entry is false
              rename_i h_k_eq_idx
              simp only [Bool.not_eq_true']
              show p { seed.entries[k] with formulas := insert phi seed.entries[k].formulas } = false
              simp only [p, ← h_k_eq_idx]
              exact h_p_idx_false
            · -- k ≠ idx case: entry unchanged, use h_before_i
              exact h_before_i k hk
      rw [h_find_mod]

/--
Helper: addFormula at different time preserves getFormulas.
NOTE: API compatibility issues - marked sorry for now.
-/
private lemma addFormula_preserves_getFormulas_diff_time
    (seed : ModelSeed) (famIdx : Nat) (timeIdx timeIdx' : Int) (phi : Formula) (ty : SeedEntryType)
    (h_diff : timeIdx ≠ timeIdx') :
    (seed.addFormula famIdx timeIdx' phi ty).getFormulas famIdx timeIdx = seed.getFormulas famIdx timeIdx := by
  unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry
  let p := fun e : SeedEntry => e.familyIdx == famIdx && e.timeIdx == timeIdx
  let p' := fun e : SeedEntry => e.familyIdx == famIdx && e.timeIdx == timeIdx'
  cases h_find : seed.entries.findIdx? p' with
  | none =>
    simp only
    rw [List.find?_append]
    have h_new_pred : p { familyIdx := famIdx, timeIdx := timeIdx', formulas := {phi}, entryType := ty } = false := by
      simp only [p, Bool.and_eq_false_iff]
      right
      simp only [beq_eq_false_iff_ne, ne_eq]
      exact Ne.symm h_diff
    have h_find_new : [{ familyIdx := famIdx, timeIdx := timeIdx', formulas := ({phi} : Set Formula), entryType := ty }].find? p = none := by
      rw [List.find?_eq_none]
      intro x hx
      simp only [List.mem_singleton] at hx
      subst hx
      simp only [Bool.not_eq_true]
      exact h_new_pred
    rw [h_find_new, Option.or_none]
  | some idx =>
    simp only
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred := h_spec.2.1
    simp only [beq_iff_eq, Bool.and_eq_true, p'] at h_pred
    have h_p_idx_false : p seed.entries[idx] = false := by
      simp only [p, Bool.and_eq_false_iff, beq_eq_false_iff_ne, ne_eq]
      right
      intro h
      have : timeIdx = timeIdx' := h.symm.trans h_pred.2
      exact h_diff this
    cases h_find_orig : seed.entries.find? p with
    | none =>
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).find? p = none := by
        rw [List.find?_eq_none]
        intro x hx
        rw [List.mem_modify_iff] at hx
        cases hx with
        | inl h_unchanged =>
          obtain ⟨j, hj, _⟩ := h_unchanged
          have h_mem := List.mem_of_getElem? hj
          have := List.find?_eq_none.mp h_find_orig x h_mem
          simp only [Bool.not_eq_true] at this ⊢
          exact this
        | inr h_modified =>
          obtain ⟨old, h_old, h_eq⟩ := h_modified
          subst h_eq
          have h_old_eq : old = seed.entries[idx] := by
            have := (List.getElem?_eq_some_iff.mp h_old).2
            exact this.symm
          simp only [Bool.not_eq_true]
          show p { old with formulas := insert phi old.formulas } = false
          simp only [p, h_old_eq]
          exact h_p_idx_false
      rw [h_find_mod]
    | some entry =>
      have h_entry_pred := List.find?_some h_find_orig
      have h_first := List.find?_eq_some_iff_getElem.mp h_find_orig
      obtain ⟨i, hi_lt, hi_eq, h_before_i⟩ := h_first.2
      have h_i_ne_idx : i ≠ idx := by
        intro h_eq
        have h_p_i : p seed.entries[i] = true := by rw [hi_eq]; exact h_entry_pred
        have h_p_idx_eq : p seed.entries[idx] = true := h_eq ▸ h_p_i
        rw [h_p_idx_eq] at h_p_idx_false
        cases h_p_idx_false
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).find? p = some entry := by
        rw [List.find?_eq_some_iff_getElem]
        have h_len := List.length_modify (fun e : SeedEntry => { e with formulas := insert phi e.formulas }) seed.entries idx
        constructor
        · exact h_entry_pred
        · use i, (h_len ▸ hi_lt)
          constructor
          · rw [List.getElem_modify]
            split
            · rename_i h_idx_eq_i; exfalso; exact h_i_ne_idx h_idx_eq_i.symm
            · exact hi_eq
          · intro k hk
            rw [List.getElem_modify]
            split
            · rename_i h_k_eq_idx
              simp only [Bool.not_eq_true']
              show p { seed.entries[k] with formulas := insert phi seed.entries[k].formulas } = false
              simp only [p, ← h_k_eq_idx]
              exact h_p_idx_false
            · exact h_before_i k hk
      rw [h_find_mod]

/--
Helper: addFormula at same position keeps existing membership.
-/
private lemma addFormula_preserves_mem_getFormulas_same
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi psi : Formula) (ty : SeedEntryType)
    (h_mem : phi ∈ seed.getFormulas famIdx timeIdx) :
    phi ∈ (seed.addFormula famIdx timeIdx psi ty).getFormulas famIdx timeIdx := by
  unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry at *
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | none =>
    have h_none : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = none := by
      rw [List.find?_eq_none]
      intro x hx
      have := List.findIdx?_eq_none_iff.mp h_find x hx
      simp only [Bool.not_eq_true]
      exact this
    rw [h_none] at h_mem
    exact absurd h_mem (Set.notMem_empty phi)
  | some idx =>
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred : (seed.entries[idx].familyIdx == famIdx && seed.entries[idx].timeIdx == timeIdx) = true := h_spec.2.1
    have h_find_orig : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = some seed.entries[idx] := by
      rw [List.find?_eq_some_iff_getElem]
      constructor
      · exact h_pred
      · use idx, h_idx_lt
        constructor
        · rfl
        · intro j hj
          have := h_spec.2.2 j hj
          simp only [Bool.not_eq_true] at this
          simp only [this, Bool.not_false]
    simp only [h_find_orig] at h_mem
    set entry' := { seed.entries[idx] with formulas := insert psi seed.entries[idx].formulas } with h_entry'
    have h_pres : (entry'.familyIdx == famIdx && entry'.timeIdx == timeIdx) = true := h_pred
    have h_find_modified : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas })).find?
        (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) = some entry' := by
      rw [List.find?_eq_some_iff_getElem]
      constructor
      · exact h_pres
      · have h_len : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas })).length =
            seed.entries.length := List.length_modify _ _ _
        use idx, (h_len ▸ h_idx_lt)
        constructor
        · rw [List.getElem_modify]
          simp only [↓reduceIte, h_entry']
        · intro j hj
          rw [List.getElem_modify]
          split
          · omega
          · have := h_spec.2.2 j hj
            simp only [Bool.not_eq_true] at this
            simp only [this, Bool.not_false]
    rw [h_find_modified, h_entry']
    exact Set.mem_insert_of_mem psi h_mem

/--
Helper: foldl addFormula preserves membership.
-/
private lemma foldl_addFormula_preserves_mem
    (phi : Formula) (psi : Formula) (timeIdx : Int) (famIndices : List Nat) (seed : ModelSeed)
    (famIdx : Nat) (h_mem : phi ∈ seed.getFormulas famIdx timeIdx) :
    phi ∈ (famIndices.foldl (fun s f => s.addFormula f timeIdx psi .universal_target) seed).getFormulas famIdx timeIdx := by
  induction famIndices generalizing seed with
  | nil => exact h_mem
  | cons f fs ih =>
    simp only [List.foldl_cons]
    apply ih
    by_cases h_diff : famIdx = f
    · subst h_diff
      exact addFormula_preserves_mem_getFormulas_same seed famIdx timeIdx phi psi .universal_target h_mem
    · rw [addFormula_preserves_getFormulas_diff_fam seed famIdx f timeIdx psi .universal_target h_diff]
      exact h_mem

/--
Helper: foldl addFormula adds phi at famIdx if famIdx is in the list.
-/
private lemma foldl_addFormula_adds_at_family
    (phi : Formula) (timeIdx : Int) (famIndices : List Nat) (seed : ModelSeed)
    (famIdx : Nat) (h_in : famIdx ∈ famIndices) :
    phi ∈ (famIndices.foldl (fun s f => s.addFormula f timeIdx phi .universal_target) seed).getFormulas famIdx timeIdx := by
  induction famIndices generalizing seed with
  | nil => simp at h_in
  | cons f fs ih =>
    simp only [List.foldl_cons]
    rw [List.mem_cons] at h_in
    cases h_in with
    | inl h_eq =>
      subst h_eq
      have h_added : phi ∈ (seed.addFormula famIdx timeIdx phi .universal_target).getFormulas famIdx timeIdx :=
        addFormula_formula_in_getFormulas seed famIdx timeIdx phi .universal_target
      exact foldl_addFormula_preserves_mem phi phi timeIdx fs (seed.addFormula famIdx timeIdx phi .universal_target) famIdx h_added
    | inr h_in_fs =>
      exact ih (seed.addFormula f timeIdx phi .universal_target) h_in_fs

/--
Helper: foldl addFormula over times preserves getFormulas at a time not in the list.
-/
private lemma foldl_addFormula_times_preserves_getFormulas
    (phi : Formula) (famIdx : Nat) (timeIdx : Int) (times : List Int) (seed : ModelSeed)
    (h_not_in : timeIdx ∉ times) :
    (times.foldl (fun s t => s.addFormula famIdx t phi .universal_target) seed).getFormulas famIdx timeIdx =
    seed.getFormulas famIdx timeIdx := by
  induction times generalizing seed with
  | nil => rfl
  | cons t ts ih =>
    simp only [List.foldl_cons]
    rw [ih]
    · have h_diff : timeIdx ≠ t := fun h => h_not_in (h ▸ List.mem_cons_self)
      exact addFormula_preserves_getFormulas_diff_time seed famIdx timeIdx t phi .universal_target h_diff
    · exact fun h => h_not_in (List.mem_cons_of_mem t h)

/--
addToAllFutureTimes preserves getFormulas at currentTime.
-/
theorem addToAllFutureTimes_preserves_getFormulas_current
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (phi : Formula) :
    (seed.addToAllFutureTimes famIdx currentTime phi).getFormulas famIdx currentTime =
    seed.getFormulas famIdx currentTime := by
  unfold ModelSeed.addToAllFutureTimes
  apply foldl_addFormula_times_preserves_getFormulas
  intro h_in
  have h_times := mem_of_eraseDups h_in
  rw [List.mem_map] at h_times
  obtain ⟨e, h_e_mem, h_e_time⟩ := h_times
  rw [List.mem_filter] at h_e_mem
  have h_gt : e.timeIdx > currentTime := by
    simp only [List.mem_filter, decide_eq_true_eq] at h_e_mem
    exact h_e_mem.2
  omega

/--
addToAllPastTimes preserves getFormulas at currentTime.
-/
theorem addToAllPastTimes_preserves_getFormulas_current
    (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) (phi : Formula) :
    (seed.addToAllPastTimes famIdx currentTime phi).getFormulas famIdx currentTime =
    seed.getFormulas famIdx currentTime := by
  unfold ModelSeed.addToAllPastTimes
  apply foldl_addFormula_times_preserves_getFormulas
  intro h_in
  have h_times := mem_of_eraseDups h_in
  rw [List.mem_map] at h_times
  obtain ⟨e, h_e_mem, h_e_time⟩ := h_times
  rw [List.mem_filter] at h_e_mem
  have h_lt : e.timeIdx < currentTime := by
    simp only [List.mem_filter, decide_eq_true_eq] at h_e_mem
    exact h_e_mem.2
  omega

/--
If famIdx is in seed.familyIndices, then addToAllFamilies adds phi at (famIdx, timeIdx).
-/
theorem addToAllFamilies_adds_at_family
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (h_fam : famIdx ∈ seed.familyIndices) :
    phi ∈ (seed.addToAllFamilies timeIdx phi).getFormulas famIdx timeIdx := by
  unfold ModelSeed.addToAllFamilies
  exact foldl_addFormula_adds_at_family phi timeIdx
    (seed.entries.map SeedEntry.familyIdx).eraseDups seed famIdx h_fam

/--
Helper: membership in list implies membership in eraseDups (length induction).
-/
private lemma mem_eraseDups_of_mem_length {α : Type*} [BEq α] [LawfulBEq α] :
    ∀ (n : Nat) (l : List α), l.length ≤ n → ∀ a ∈ l, a ∈ l.eraseDups := by
  intro n
  induction n with
  | zero =>
    intro l hl a ha
    have : l = [] := List.eq_nil_of_length_eq_zero (Nat.le_zero.mp hl)
    simp [this] at ha
  | succ n ih =>
    intro l hl a ha
    match l with
    | [] => simp at ha
    | x :: xs =>
      simp only [List.eraseDups_cons]
      rw [List.mem_cons] at ha
      rw [List.mem_cons]
      cases ha with
      | inl h => left; exact h
      | inr h =>
        by_cases hax : a == x
        · left; exact beq_iff_eq.mp hax
        · right
          have h_in_filter : a ∈ List.filter (fun b => !b == x) xs := by
            rw [List.mem_filter]
            constructor
            · exact h
            · simp only [hax, Bool.not_eq_true']
          have h_len : (List.filter (fun b => !b == x) xs).length ≤ n := by
            calc (List.filter (fun b => !b == x) xs).length
                ≤ xs.length := List.length_filter_le _ _
              _ ≤ n := by simp only [List.length_cons] at hl; omega
          exact ih (List.filter (fun b => !b == x) xs) h_len a h_in_filter

private lemma mem_eraseDups_of_mem_list {α : Type*} [BEq α] [LawfulBEq α] (a : α) (l : List α) (h : a ∈ l) :
    a ∈ l.eraseDups :=
  mem_eraseDups_of_mem_length l.length l (Nat.le_refl _) a h

/--
If there's a formula at position (famIdx, timeIdx), then famIdx is in familyIndices after addFormula.
-/
private lemma addFormula_famIdx_in_familyIndices
    (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula) (ty : SeedEntryType)
    (h_phi_in : phi ∈ seed.getFormulas famIdx timeIdx) :
    famIdx ∈ (seed.addFormula famIdx timeIdx phi ty).familyIndices := by
  unfold ModelSeed.addFormula
  cases h_find : seed.entries.findIdx? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | none =>
    unfold ModelSeed.familyIndices
    simp only [List.map_append, List.map_cons, List.map_nil]
    apply mem_eraseDups_of_mem_list
    apply List.mem_append_right
    exact List.mem_singleton_self famIdx
  | some idx =>
    unfold ModelSeed.familyIndices
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred := h_spec.2.1
    simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
    have h_fam_eq : seed.entries[idx].familyIdx = famIdx := h_pred.1
    have h_in_orig : famIdx ∈ seed.familyIndices := by
      unfold ModelSeed.familyIndices
      apply mem_eraseDups_of_mem_list
      rw [List.mem_map]
      use seed.entries[idx]
      constructor
      · exact List.getElem_mem h_idx_lt
      · exact h_fam_eq
    have h_map_eq : (seed.entries.modify idx (fun e => { e with formulas := insert phi e.formulas })).map SeedEntry.familyIdx =
        seed.entries.map SeedEntry.familyIdx := by
      apply List.ext_getElem
      simp only [List.length_map, List.length_modify]
      intro n h1 h2
      simp only [List.getElem_map, List.getElem_modify]
      split <;> rfl
    rw [h_map_eq]
    exact h_in_orig

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
    (h_phi_cons : FormulaConsistent phi)
    (h_single_family : phi.needsPositiveHypotheses → seed.familyIndices = [famIdx])
    (h_single_time : phi.needsPositiveHypotheses → seed.timeIndices famIdx = [timeIdx]) :
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
      -- Define intermediate seeds for clarity
      let seed1 := seed.addFormula famIdx timeIdx psi.box .universal_target
      let seed2 := seed1.addToAllFamilies timeIdx psi
      -- Extract concrete hypotheses (box is a positive case, needsPositiveHypotheses = true)
      have h_single_family_proof : seed.familyIndices = [famIdx] := h_single_family rfl
      have h_single_time_proof : seed.timeIndices famIdx = [timeIdx] := h_single_time rfl
      -- Show psi is consistent (from Box psi being consistent)
      have h_psi_cons : FormulaConsistent psi := box_consistent_implies_content_consistent h_phi_cons
      -- Show complexity decreases for IH
      have h_complexity : psi.complexity < c := by
        rw [← h_c]; simp only [Formula.complexity]; omega
      -- Show seed1 is consistent (Box psi already in seed, insert is identity)
      have h_seed1_cons : SeedConsistent seed1 := by
        apply addFormula_seed_preserves_consistent
        · exact h_cons
        · exact h_phi_cons
        · intro entry h_entry h_fam h_time
          have h_entry_cons := h_cons entry h_entry
          have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
          have h_phi_in_entry : psi.box ∈ entry.formulas := by
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
      -- Show psi is in seed2 at (famIdx, timeIdx)
      -- addToAllFamilies adds psi to famIdx (since it's a family index in seed1)
      have h_psi_in_seed2 : psi ∈ seed2.getFormulas famIdx timeIdx := by
        have h_fam_in_seed1 : famIdx ∈ seed1.familyIndices :=
          addFormula_famIdx_in_familyIndices seed famIdx timeIdx psi.box .universal_target h_phi_in
        exact addToAllFamilies_adds_at_family seed1 famIdx timeIdx psi h_fam_in_seed1
      -- Show seed1 preserves single-family property (needed for both seed2 consistency and IH)
      have h_seed1_single : seed1.familyIndices = [famIdx] :=
        addFormula_preserves_single_family seed famIdx timeIdx psi.box .universal_target h_single_family_proof
      -- Show seed2 is consistent
      -- This requires showing that adding psi to all families preserves consistency
      -- For entries that already have Box psi, psi is derivable via T-axiom
      -- For entries that don't have Box psi, we need the "all subformulas compatible" invariant
      have h_seed2_cons : SeedConsistent seed2 := by
        -- Use addToAllFamilies_preserves_consistent with T-axiom derivation
        apply addToAllFamilies_preserves_consistent seed1 timeIdx psi h_seed1_cons h_psi_cons
        -- Need to show: for every entry at timeIdx in seed1, adding psi preserves consistency
        intro entry h_entry h_time
        -- The key insight: Box psi is in seed at (famIdx, timeIdx)
        -- For the entry at (famIdx, timeIdx), psi is derivable via T-axiom (Box psi -> psi)
        -- For other entries, we need to argue they share Box psi or are compatible
        -- SINGLE-FAMILY KEY: Since seed1.familyIndices = [famIdx], all entries have familyIdx = famIdx
        -- So the "other family" case is impossible
        have h_entry_famIdx : entry.familyIdx = famIdx := by
          -- entry ∈ seed1.entries and seed1.familyIndices = [famIdx]
          -- familyIndices = eraseDups of all familyIdx values
          -- If eraseDups = [famIdx], then all familyIdx values = famIdx
          have h_in_map : entry.familyIdx ∈ seed1.entries.map SeedEntry.familyIdx :=
            List.mem_map_of_mem (f := SeedEntry.familyIdx) h_entry
          have h_eraseDups_eq : (seed1.entries.map SeedEntry.familyIdx).eraseDups = [famIdx] := by
            unfold ModelSeed.familyIndices at h_seed1_single
            exact h_seed1_single
          exact all_eq_of_eraseDups_singleton h_eraseDups_eq entry.familyIdx h_in_map
        -- Entry is at (famIdx, timeIdx): has Box psi, so psi is derivable
        have h_entry_has_box : psi.box ∈ entry.formulas := by
          have h_eq := getFormulas_eq_of_wellformed_and_at_position seed1 entry famIdx timeIdx
            h_seed1_wf h_entry h_entry_famIdx h_time
          have h_box_in_seed1 : psi.box ∈ seed1.getFormulas famIdx timeIdx :=
            addFormula_formula_in_getFormulas seed famIdx timeIdx psi.box .universal_target
          rw [h_eq] at h_box_in_seed1
          exact h_box_in_seed1
        -- psi is derivable from Box psi via T-axiom
        have h_entry_cons : SetConsistent entry.formulas := h_seed1_cons entry h_entry
        have d_psi : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ entry.formulas) ∧
            Nonempty (Bimodal.ProofSystem.DerivationTree L psi) := by
          use [psi.box]
          constructor
          · intro ψ hψ; simp only [List.mem_singleton] at hψ; rw [hψ]; exact h_entry_has_box
          · constructor
            have d_t : Bimodal.ProofSystem.DerivationTree [] (psi.box.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.modal_t psi)
            have d_box : Bimodal.ProofSystem.DerivationTree [psi.box] psi.box :=
              Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
            have d_t' : Bimodal.ProofSystem.DerivationTree [psi.box] (psi.box.imp psi) :=
              Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_t (by intro; simp)
            exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_t' d_box
        exact addFormula_preserves_consistent h_entry_cons d_psi
      -- Show seed2 is well-formed
      have h_seed2_wf : SeedWellFormed seed2 :=
        addToAllFamilies_preserves_wellFormed seed1 timeIdx psi h_seed1_wf
      have h_seed2_single : seed2.familyIndices = [famIdx] :=
        addToAllFamilies_preserves_single_family seed1 famIdx timeIdx psi h_seed1_single
      -- Show seed2 preserves single-time property
      have h_seed1_single_time : seed1.timeIndices famIdx = [timeIdx] :=
        addFormula_preserves_single_time seed famIdx timeIdx psi.box .universal_target h_single_time_proof
      have h_seed2_single_time : seed2.timeIndices famIdx = [timeIdx] :=
        addToAllFamilies_preserves_single_time seed1 famIdx timeIdx psi h_seed1_single h_seed1_single_time
      -- Apply IH with conditional hypotheses for psi (which may or may not need them)
      exact ih psi.complexity h_complexity psi famIdx timeIdx seed2
        h_seed2_cons h_seed2_wf h_psi_in_seed2 h_psi_cons
        (fun _ => h_seed2_single) (fun _ => h_seed2_single_time) rfl
    | Formula.all_future psi =>
      -- G case: adds G psi to current, psi to current, psi to all future times, G psi to all future times, recurses on psi
      simp only [buildSeedAux]
      -- Define intermediate seeds for clarity
      let phi := psi.all_future
      let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
      let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
      let seed3 := seed2.addToAllFutureTimes famIdx timeIdx psi
      let seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi
      -- Extract concrete hypotheses (all_future is a positive case, needsPositiveHypotheses = true)
      have h_single_family_proof : seed.familyIndices = [famIdx] := h_single_family rfl
      have h_single_time_proof : seed.timeIndices famIdx = [timeIdx] := h_single_time rfl
      -- Show psi is consistent (from G psi being consistent)
      have h_psi_cons : FormulaConsistent psi := all_future_consistent_implies_content_consistent h_phi_cons
      -- Show complexity decreases for IH
      have h_complexity : psi.complexity < c := by
        rw [← h_c]; simp only [Formula.complexity]; omega
      -- Show seed1 is consistent
      have h_seed1_cons : SeedConsistent seed1 := by
        apply addFormula_seed_preserves_consistent
        · exact h_cons
        · exact h_phi_cons
        · intro entry h_entry h_fam h_time
          have h_entry_cons := h_cons entry h_entry
          have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
          have h_phi_in_entry : phi ∈ entry.formulas := by
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
      -- Show seed2 is consistent (adding psi which is derivable from G psi via T-axiom)
      have h_seed2_cons : SeedConsistent seed2 := by
        apply addFormula_seed_preserves_consistent
        · exact h_seed1_cons
        · exact h_psi_cons
        · intro entry h_entry h_fam h_time
          -- psi is derivable from G psi via temporal T-axiom
          -- The entry at (famIdx, timeIdx) in seed1 has G psi
          -- So psi is derivable, and insert preserves consistency
          have h_entry_cons := h_seed1_cons entry h_entry
          -- entry is at (famIdx, timeIdx) in seed1, so G psi ∈ entry.formulas
          have h_gpsi_in : phi ∈ entry.formulas := by
            have h_eq := getFormulas_eq_of_wellformed_and_at_position seed1 entry famIdx timeIdx
              h_seed1_wf h_entry h_fam h_time
            have h_in_seed1 : phi ∈ seed1.getFormulas famIdx timeIdx :=
              addFormula_formula_in_getFormulas seed famIdx timeIdx phi .universal_target
            rw [h_eq] at h_in_seed1
            exact h_in_seed1
          -- Build derivation: [G psi] ⊢ psi via temp_t_future
          have d_psi : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ entry.formulas) ∧
              Nonempty (Bimodal.ProofSystem.DerivationTree L psi) := by
            use [phi]
            constructor
            · intro ψ hψ
              simp only [List.mem_singleton] at hψ
              rw [hψ]
              exact h_gpsi_in
            · constructor
              have d_t : Bimodal.ProofSystem.DerivationTree [] (phi.imp psi) :=
                Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_future psi)
              have d_gpsi : Bimodal.ProofSystem.DerivationTree [phi] phi :=
                Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
              have d_t' : Bimodal.ProofSystem.DerivationTree [phi] (phi.imp psi) :=
                Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_t (by intro; simp)
              exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_t' d_gpsi
          exact addFormula_preserves_consistent h_entry_cons d_psi
      -- Show seed2 is well-formed
      have h_seed2_wf : SeedWellFormed seed2 := by
        apply addFormula_preserves_wellFormed
        · exact h_seed1_wf
        · intro h_none
          -- This case is impossible: seed1 has G psi at (famIdx, timeIdx)
          exfalso
          have h_in : phi ∈ seed1.getFormulas famIdx timeIdx :=
            addFormula_formula_in_getFormulas seed famIdx timeIdx phi .universal_target
          unfold ModelSeed.getFormulas at h_in
          rw [h_none] at h_in
          exact Set.not_mem_empty _ h_in
      -- Establish single-time properties first (needed for h_no_future)
      have h_seed1_single_time : seed1.timeIndices famIdx = [timeIdx] :=
        addFormula_preserves_single_time seed famIdx timeIdx phi .universal_target h_single_time_proof
      have h_seed2_single_time : seed2.timeIndices famIdx = [timeIdx] :=
        addFormula_preserves_single_time seed1 famIdx timeIdx psi .universal_target h_seed1_single_time
      -- Key insight: on the positive branch with single-time, there are no future times
      -- addToAllFutureTimes folds over an empty list, so seed3 = seed2 and seed4 = seed3 = seed2
      have h_no_future : (seed2.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx > timeIdx) = [] :=
        no_future_times_of_single_time seed2 famIdx timeIdx h_seed2_single_time
      -- Show seed3 = seed2 via the empty fold
      have h_seed3_eq : seed3 = seed2 := by
        show seed2.addToAllFutureTimes famIdx timeIdx psi = seed2
        unfold ModelSeed.addToAllFutureTimes
        simp only [h_no_future, List.map_nil]
        rfl
      -- Show seed3 is consistent and well-formed
      have h_seed3_cons : SeedConsistent seed3 := by rw [h_seed3_eq]; exact h_seed2_cons
      have h_seed3_wf : SeedWellFormed seed3 := by
        apply addToAllFutureTimes_preserves_wellFormed
        · exact h_seed2_wf
        · -- Need famIdx < seed2.nextFamilyIdx
          rw [addFormula_nextFamilyIdx, addFormula_nextFamilyIdx]
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
      -- Show seed3 preserves single-family property
      have h_seed1_single : seed1.familyIndices = [famIdx] :=
        addFormula_preserves_single_family seed famIdx timeIdx phi .universal_target h_single_family_proof
      have h_seed2_single : seed2.familyIndices = [famIdx] :=
        addFormula_preserves_single_family seed1 famIdx timeIdx psi .universal_target h_seed1_single
      have h_seed3_single : seed3.familyIndices = [famIdx] :=
        addToAllFutureTimes_preserves_single_family seed2 famIdx timeIdx psi h_seed2_single
      -- Show seed3 preserves single-time property
      have h_seed3_single_time : seed3.timeIndices famIdx = [timeIdx] := by
        rw [h_seed3_eq]; exact h_seed2_single_time
      -- Now handle seed4 (adding G psi to all future times)
      -- Since seed3 = seed2 has no future times, seed4 = seed3
      have h_no_future_seed3 : (seed3.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx > timeIdx) = [] := by
        rw [h_seed3_eq]; exact h_no_future
      have h_seed4_eq : seed4 = seed3 := by
        show seed3.addToAllFutureTimes famIdx timeIdx phi = seed3
        unfold ModelSeed.addToAllFutureTimes
        simp only [h_no_future_seed3, List.map_nil]
        rfl
      -- Show seed4 properties via seed4 = seed3
      have h_seed4_cons : SeedConsistent seed4 := by rw [h_seed4_eq]; exact h_seed3_cons
      have h_seed4_wf : SeedWellFormed seed4 := by
        apply addToAllFutureTimes_preserves_wellFormed
        · exact h_seed3_wf
        · -- Need famIdx < seed3.nextFamilyIdx
          rw [h_seed3_eq, addFormula_nextFamilyIdx, addFormula_nextFamilyIdx]
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
      -- Show psi is in seed4 at (famIdx, timeIdx)
      have h_psi_in_seed4 : psi ∈ seed4.getFormulas famIdx timeIdx := by
        rw [h_seed4_eq, h_seed3_eq]
        -- psi is in seed2 at (famIdx, timeIdx)
        exact addFormula_formula_in_getFormulas seed1 famIdx timeIdx psi .universal_target
      have h_seed4_single : seed4.familyIndices = [famIdx] :=
        addToAllFutureTimes_preserves_single_family seed3 famIdx timeIdx phi h_seed3_single
      have h_seed4_single_time : seed4.timeIndices famIdx = [timeIdx] := by
        rw [h_seed4_eq]; exact h_seed3_single_time
      -- Apply IH with conditional hypotheses for psi
      exact ih psi.complexity h_complexity psi famIdx timeIdx seed4
        h_seed4_cons h_seed4_wf h_psi_in_seed4 h_psi_cons
        (fun _ => h_seed4_single) (fun _ => h_seed4_single_time) rfl
    | Formula.all_past psi =>
      -- H case: adds H psi to current, psi to current, psi to all past times, H psi to all past times, recurses on psi
      simp only [buildSeedAux]
      -- Define intermediate seeds for clarity
      let phi := psi.all_past
      let seed1 := seed.addFormula famIdx timeIdx phi .universal_target
      let seed2 := seed1.addFormula famIdx timeIdx psi .universal_target
      let seed3 := seed2.addToAllPastTimes famIdx timeIdx psi
      let seed4 := seed3.addToAllPastTimes famIdx timeIdx phi
      -- Extract concrete hypotheses (all_past is a positive case, needsPositiveHypotheses = true)
      have h_single_family_proof : seed.familyIndices = [famIdx] := h_single_family rfl
      have h_single_time_proof : seed.timeIndices famIdx = [timeIdx] := h_single_time rfl
      -- Show psi is consistent (from H psi being consistent)
      have h_psi_cons : FormulaConsistent psi := all_past_consistent_implies_content_consistent h_phi_cons
      -- Show complexity decreases for IH
      have h_complexity : psi.complexity < c := by
        rw [← h_c]; simp only [Formula.complexity]; omega
      -- Show seed1 is consistent
      have h_seed1_cons : SeedConsistent seed1 := by
        apply addFormula_seed_preserves_consistent
        · exact h_cons
        · exact h_phi_cons
        · intro entry h_entry h_fam h_time
          have h_entry_cons := h_cons entry h_entry
          have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
          have h_phi_in_entry : phi ∈ entry.formulas := by
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
      -- Show seed2 is consistent (adding psi which is derivable from H psi via T-axiom)
      have h_seed2_cons : SeedConsistent seed2 := by
        apply addFormula_seed_preserves_consistent
        · exact h_seed1_cons
        · exact h_psi_cons
        · intro entry h_entry h_fam h_time
          -- psi is derivable from H psi via temporal T-axiom
          -- The entry at (famIdx, timeIdx) in seed1 has H psi
          have h_entry_cons := h_seed1_cons entry h_entry
          have h_hpsi_in : phi ∈ entry.formulas := by
            have h_eq := getFormulas_eq_of_wellformed_and_at_position seed1 entry famIdx timeIdx
              h_seed1_wf h_entry h_fam h_time
            have h_in_seed1 : phi ∈ seed1.getFormulas famIdx timeIdx :=
              addFormula_formula_in_getFormulas seed famIdx timeIdx phi .universal_target
            rw [h_eq] at h_in_seed1
            exact h_in_seed1
          -- Build derivation: [H psi] ⊢ psi via temp_t_past
          have d_psi : ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ entry.formulas) ∧
              Nonempty (Bimodal.ProofSystem.DerivationTree L psi) := by
            use [phi]
            constructor
            · intro ψ hψ
              simp only [List.mem_singleton] at hψ
              rw [hψ]
              exact h_hpsi_in
            · constructor
              have d_t : Bimodal.ProofSystem.DerivationTree [] (phi.imp psi) :=
                Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_t_past psi)
              have d_hpsi : Bimodal.ProofSystem.DerivationTree [phi] phi :=
                Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
              have d_t' : Bimodal.ProofSystem.DerivationTree [phi] (phi.imp psi) :=
                Bimodal.ProofSystem.DerivationTree.weakening [] _ _ d_t (by intro; simp)
              exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ d_t' d_hpsi
          exact addFormula_preserves_consistent h_entry_cons d_psi
      -- Show seed2 is well-formed
      have h_seed2_wf : SeedWellFormed seed2 := by
        apply addFormula_preserves_wellFormed
        · exact h_seed1_wf
        · intro h_none
          -- This case is impossible: seed1 has H psi at (famIdx, timeIdx)
          exfalso
          have h_in : phi ∈ seed1.getFormulas famIdx timeIdx :=
            addFormula_formula_in_getFormulas seed famIdx timeIdx phi .universal_target
          unfold ModelSeed.getFormulas at h_in
          rw [h_none] at h_in
          exact Set.not_mem_empty _ h_in
      -- Establish single-time properties first (needed for h_no_past)
      have h_seed1_single_time : seed1.timeIndices famIdx = [timeIdx] :=
        addFormula_preserves_single_time seed famIdx timeIdx phi .universal_target h_single_time_proof
      have h_seed2_single_time : seed2.timeIndices famIdx = [timeIdx] :=
        addFormula_preserves_single_time seed1 famIdx timeIdx psi .universal_target h_seed1_single_time
      -- Key insight: on the positive branch with single-time, there are no past times
      -- addToAllPastTimes folds over an empty list, so seed3 = seed2 and seed4 = seed3 = seed2
      have h_no_past : (seed2.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx < timeIdx) = [] :=
        no_past_times_of_single_time seed2 famIdx timeIdx h_seed2_single_time
      -- Show seed3 = seed2 via the empty fold
      have h_seed3_eq : seed3 = seed2 := by
        show seed2.addToAllPastTimes famIdx timeIdx psi = seed2
        unfold ModelSeed.addToAllPastTimes
        simp only [h_no_past, List.map_nil]
        rfl
      -- Show seed3 is consistent and well-formed
      have h_seed3_cons : SeedConsistent seed3 := by rw [h_seed3_eq]; exact h_seed2_cons
      have h_seed3_wf : SeedWellFormed seed3 := by
        apply addToAllPastTimes_preserves_wellFormed
        · exact h_seed2_wf
        · -- Need famIdx < seed2.nextFamilyIdx
          rw [addFormula_nextFamilyIdx, addFormula_nextFamilyIdx]
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
      -- Show seed3 preserves single-family property
      have h_seed1_single : seed1.familyIndices = [famIdx] :=
        addFormula_preserves_single_family seed famIdx timeIdx phi .universal_target h_single_family_proof
      have h_seed2_single : seed2.familyIndices = [famIdx] :=
        addFormula_preserves_single_family seed1 famIdx timeIdx psi .universal_target h_seed1_single
      have h_seed3_single : seed3.familyIndices = [famIdx] :=
        addToAllPastTimes_preserves_single_family seed2 famIdx timeIdx psi h_seed2_single
      -- Show seed3 preserves single-time property
      have h_seed3_single_time : seed3.timeIndices famIdx = [timeIdx] := by
        rw [h_seed3_eq]; exact h_seed2_single_time
      -- Now handle seed4 (adding H psi to all past times)
      -- Since seed3 = seed2 has no past times, seed4 = seed3
      have h_no_past_seed3 : (seed3.entries.filter (fun e => e.familyIdx == famIdx)).filter (fun e => e.timeIdx < timeIdx) = [] := by
        rw [h_seed3_eq]; exact h_no_past
      have h_seed4_eq : seed4 = seed3 := by
        show seed3.addToAllPastTimes famIdx timeIdx phi = seed3
        unfold ModelSeed.addToAllPastTimes
        simp only [h_no_past_seed3, List.map_nil]
        rfl
      -- Show seed4 properties via seed4 = seed3
      have h_seed4_cons : SeedConsistent seed4 := by rw [h_seed4_eq]; exact h_seed3_cons
      have h_seed4_wf : SeedWellFormed seed4 := by
        apply addToAllPastTimes_preserves_wellFormed
        · exact h_seed3_wf
        · -- Need famIdx < seed3.nextFamilyIdx
          rw [h_seed3_eq, addFormula_nextFamilyIdx, addFormula_nextFamilyIdx]
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
      -- Show psi is in seed4 at (famIdx, timeIdx)
      have h_psi_in_seed4 : psi ∈ seed4.getFormulas famIdx timeIdx := by
        rw [h_seed4_eq, h_seed3_eq]
        -- psi is in seed2 at (famIdx, timeIdx)
        exact addFormula_formula_in_getFormulas seed1 famIdx timeIdx psi .universal_target
      have h_seed4_single : seed4.familyIndices = [famIdx] :=
        addToAllPastTimes_preserves_single_family seed3 famIdx timeIdx phi h_seed3_single
      have h_seed4_single_time : seed4.timeIndices famIdx = [timeIdx] := by
        rw [h_seed4_eq]; exact h_seed3_single_time
      -- Apply IH with conditional hypotheses for psi
      exact ih psi.complexity h_complexity psi famIdx timeIdx seed4
        h_seed4_cons h_seed4_wf h_psi_in_seed4 h_psi_cons
        (fun _ => h_seed4_single) (fun _ => h_seed4_single_time) rfl
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
        -- Show seed2 has single-time property at the NEW family
        -- For the new family result.2, there's only one entry at timeIdx, so this is TRUE
        have h_seed2_single_time : result.1.timeIndices result.2 = [timeIdx] :=
          createNewFamily_timeIndices_new_family seed1 timeIdx inner.neg h_seed1_wf
        -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
        -- The hypotheses are never called because needsPositiveHypotheses returns false for all imp forms
        exact ih inner.neg.complexity h_complexity inner.neg result.2 timeIdx result.1
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
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
        -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
        -- The hypotheses are never called because needsPositiveHypotheses returns false for all imp forms
        exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
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
        -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
        -- The hypotheses are never called because needsPositiveHypotheses returns false for all imp forms
        exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
          h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
          (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
      | p1, p2 =>
        -- Generic implication case: We prove by case analysis on p1 and p2.
        -- For most combinations, buildSeedAux reduces to addFormula.
        -- For neg-Box/G/H cases (which "should have" matched earlier but Lean doesn't know),
        -- we apply the IH recursively.
        cases hp2 : p2 with
        | bot =>
          -- Negation case: p1 -> bot
          cases hp1 : p1 with
          | atom s =>
            -- Generic negation of atom
            subst hp1 hp2
            simp only [buildSeedAux]
            apply addFormula_seed_preserves_consistent
            · exact h_cons
            · exact h_phi_cons
            · intro entry h_entry h_fam h_time
              have h_entry_cons := h_cons entry h_entry
              have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
              have h_phi_in_entry : (Formula.atom s).neg ∈ entry.formulas := by
                rw [← h_getFormulas_eq]; exact h_phi_in
              simp only [Formula.neg] at h_phi_in_entry
              rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
          | bot =>
            -- Generic negation of bot
            subst hp1 hp2
            simp only [buildSeedAux]
            apply addFormula_seed_preserves_consistent
            · exact h_cons
            · exact h_phi_cons
            · intro entry h_entry h_fam h_time
              have h_entry_cons := h_cons entry h_entry
              have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
              have h_phi_in_entry : Formula.bot.neg ∈ entry.formulas := by
                rw [← h_getFormulas_eq]; exact h_phi_in
              simp only [Formula.neg] at h_phi_in_entry
              rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
          | box inner =>
            -- neg-Box case (duplicate of earlier case but reached via catch-all)
            subst hp1 hp2
            simp only [buildSeedAux]
            let seed1 := seed.addFormula famIdx timeIdx inner.box.neg .universal_target
            let result := seed1.createNewFamily timeIdx inner.neg
            have h_inner_neg_cons : FormulaConsistent inner.neg :=
              negBox_consistent_implies_neg_consistent h_phi_cons
            have h_complexity : inner.neg.complexity < c := by
              rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
            have h_seed1_cons : SeedConsistent seed1 := by
              apply addFormula_seed_preserves_consistent
              · exact h_cons
              · exact h_phi_cons
              · intro entry h_entry h_fam h_time
                have h_entry_cons := h_cons entry h_entry
                have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
                have h_phi_in_entry : inner.box.neg ∈ entry.formulas := by
                  rw [← h_getFormulas_eq]; exact h_phi_in
                rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
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
            have h_seed2_cons : SeedConsistent result.1 :=
              createNewFamily_preserves_seedConsistent seed1 timeIdx inner.neg h_seed1_cons h_inner_neg_cons
            have h_seed2_wf : SeedWellFormed result.1 :=
              createNewFamily_preserves_wellFormed seed1 timeIdx inner.neg h_seed1_wf
            have h_neg_in : inner.neg ∈ result.1.getFormulas result.2 timeIdx :=
              createNewFamily_formula_at_new_position seed1 timeIdx inner.neg h_seed1_wf
            -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
            exact ih inner.neg.complexity h_complexity inner.neg result.2 timeIdx result.1
              h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
          | all_future inner =>
            -- neg-G case (duplicate of earlier case but reached via catch-all)
            subst hp1 hp2
            simp only [buildSeedAux]
            let seed1 := seed.addFormula famIdx timeIdx inner.all_future.neg .universal_target
            let newTime := seed1.freshFutureTime famIdx timeIdx
            let seed2 := seed1.createNewTime famIdx newTime inner.neg
            have h_inner_neg_cons : FormulaConsistent inner.neg :=
              negG_consistent_implies_neg_consistent h_phi_cons
            have h_complexity : inner.neg.complexity < c := by
              rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
            have h_seed1_cons : SeedConsistent seed1 := by
              apply addFormula_seed_preserves_consistent
              · exact h_cons
              · exact h_phi_cons
              · intro entry h_entry h_fam h_time
                have h_entry_cons := h_cons entry h_entry
                have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
                have h_phi_in_entry : inner.all_future.neg ∈ entry.formulas := by
                  rw [← h_getFormulas_eq]; exact h_phi_in
                rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
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
            have h_no_entry : seed1.findEntry famIdx newTime = none :=
              ModelSeed.freshFutureTime_no_entry seed1 famIdx timeIdx
            have h_seed2_cons : SeedConsistent seed2 :=
              createNewTime_preserves_seedConsistent seed1 famIdx newTime inner.neg h_seed1_cons h_inner_neg_cons
            have h_seed2_wf : SeedWellFormed seed2 := by
              apply createNewTime_preserves_wellFormed
              · exact h_seed1_wf
              · rw [addFormula_nextFamilyIdx]
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
            have h_neg_in : inner.neg ∈ seed2.getFormulas famIdx newTime :=
              createNewTime_formula_at_new_position seed1 famIdx newTime inner.neg h_no_entry
            -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
            exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
              h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
          | all_past inner =>
            -- neg-H case (duplicate of earlier case but reached via catch-all)
            subst hp1 hp2
            simp only [buildSeedAux]
            let seed1 := seed.addFormula famIdx timeIdx inner.all_past.neg .universal_target
            let newTime := seed1.freshPastTime famIdx timeIdx
            let seed2 := seed1.createNewTime famIdx newTime inner.neg
            have h_inner_neg_cons : FormulaConsistent inner.neg :=
              negH_consistent_implies_neg_consistent h_phi_cons
            have h_complexity : inner.neg.complexity < c := by
              rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
            have h_seed1_cons : SeedConsistent seed1 := by
              apply addFormula_seed_preserves_consistent
              · exact h_cons
              · exact h_phi_cons
              · intro entry h_entry h_fam h_time
                have h_entry_cons := h_cons entry h_entry
                have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
                have h_phi_in_entry : inner.all_past.neg ∈ entry.formulas := by
                  rw [← h_getFormulas_eq]; exact h_phi_in
                rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
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
            have h_no_entry : seed1.findEntry famIdx newTime = none :=
              ModelSeed.freshPastTime_no_entry seed1 famIdx timeIdx
            have h_seed2_cons : SeedConsistent seed2 :=
              createNewTime_preserves_seedConsistent seed1 famIdx newTime inner.neg h_seed1_cons h_inner_neg_cons
            have h_seed2_wf : SeedWellFormed seed2 := by
              apply createNewTime_preserves_wellFormed
              · exact h_seed1_wf
              · rw [addFormula_nextFamilyIdx]
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
            have h_neg_in : inner.neg ∈ seed2.getFormulas famIdx newTime :=
              createNewTime_formula_at_new_position seed1 famIdx newTime inner.neg h_no_entry
            -- Apply IH with vacuous conditional hypotheses (inner.neg is an imp, needsPositiveHypotheses = false)
            exact ih inner.neg.complexity h_complexity inner.neg famIdx newTime seed2
              h_seed2_cons h_seed2_wf h_neg_in h_inner_neg_cons
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim)
              (fun h => by simp only [Formula.neg] at h; exact (Bool.false_ne_true h).elim) rfl
          | imp q1 q2 =>
            -- Generic negation of implication
            subst hp2 hp1
            simp only [buildSeedAux]
            apply addFormula_seed_preserves_consistent
            · exact h_cons
            · exact h_phi_cons
            · intro entry h_entry h_fam h_time
              have h_entry_cons := h_cons entry h_entry
              have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
              have h_phi_in_entry : (q1.imp q2).neg ∈ entry.formulas := by
                rw [← h_getFormulas_eq]; exact h_phi_in
              -- (q1.imp q2).neg = (q1.imp q2).imp bot
              simp only [Formula.neg] at h_phi_in_entry
              rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
        | atom s =>
          -- p1 -> atom s
          subst hp2
          simp only [buildSeedAux]
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : p1.imp (Formula.atom s) ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
        | box q =>
          -- p1 -> box q
          subst hp2
          simp only [buildSeedAux]
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : p1.imp q.box ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
        | all_future q =>
          -- p1 -> G q
          subst hp2
          simp only [buildSeedAux]
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : p1.imp q.all_future ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
        | all_past q =>
          -- p1 -> H q
          subst hp2
          simp only [buildSeedAux]
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : p1.imp q.all_past ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons
        | imp q1 q2 =>
          -- p1 -> (q1 -> q2)
          subst hp2
          simp only [buildSeedAux]
          apply addFormula_seed_preserves_consistent
          · exact h_cons
          · exact h_phi_cons
          · intro entry h_entry h_fam h_time
            have h_entry_cons := h_cons entry h_entry
            have h_getFormulas_eq := getFormulas_eq_of_wellformed_and_at_position seed entry famIdx timeIdx h_wf h_entry h_fam h_time
            have h_phi_in_entry : p1.imp (q1.imp q2) ∈ entry.formulas := by
              rw [← h_getFormulas_eq]; exact h_phi_in
            rw [Set.insert_eq_of_mem h_phi_in_entry]; exact h_entry_cons

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
  · -- Initial seed has single-family property: familyIndices = [0] (conditional)
    intro _
    exact initial_familyIndices_eq phi
  · -- Initial seed has single-time property: timeIndices 0 = [0] (conditional)
    intro _
    exact initial_timeIndices_eq phi

/-!
## Helper Lemmas: Membership Preservation

These lemmas establish that seed operations preserve membership of existing formulas
at a position. This is foundational for proving `buildSeed_contains_formula`.
-/

/--
Helper: addFormula at different position preserves membership.
More general than diff_fam or diff_time: works when either family or time differs.

NOTE: This is the key auxiliary lemma. The existing addFormula_preserves_getFormulas_*
lemmas require query time = add time. This generalizes to disjoint positions.
-/
private lemma addFormula_preserves_mem_diff_position
    (seed : ModelSeed) (famIdx addFam : Nat) (t addTime : Int) (phi psi : Formula) (ty : SeedEntryType)
    (h_diff : famIdx ≠ addFam ∨ t ≠ addTime)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.addFormula addFam addTime psi ty).getFormulas famIdx t := by
  -- The proof strategy: show that getFormulas at (famIdx, t) is unchanged by addFormula at (addFam, addTime)
  -- when the positions differ. This follows from the fact that find? uses different predicates.
  unfold ModelSeed.addFormula ModelSeed.getFormulas ModelSeed.findEntry at *
  let p := fun e : SeedEntry => e.familyIdx == famIdx && e.timeIdx == t
  let p' := fun e : SeedEntry => e.familyIdx == addFam && e.timeIdx == addTime
  -- Key observation: when (famIdx, t) ≠ (addFam, addTime), any entry matching p' won't match p in a way that changes results
  have h_pred_neq : ∀ (e : SeedEntry), (p e = true ∧ p' e = true) → False := by
    intro e ⟨hp, hp'⟩
    simp only [p, p', beq_iff_eq, Bool.and_eq_true] at hp hp'
    rcases h_diff with h_fam | h_time
    · exact h_fam (hp.1.symm.trans hp'.1)
    · exact h_time (hp.2.symm.trans hp'.2)
  cases h_find : seed.entries.findIdx? p' with
  | none =>
    -- No existing entry at (addFam, addTime): new entry appended
    simp only
    rw [List.find?_append]
    -- Check original find result
    cases h_find_orig : seed.entries.find? p with
    | none =>
      rw [h_find_orig] at h_mem
      exact absurd h_mem (Set.notMem_empty phi)
    | some entry =>
      simp only [Option.some_or]
      rw [h_find_orig] at h_mem
      exact h_mem
  | some idx =>
    -- Existing entry at idx with (addFam, addTime): modify entry at idx
    simp only
    have h_spec := List.findIdx?_eq_some_iff_getElem.mp h_find
    have h_idx_lt : idx < seed.entries.length := h_spec.1
    have h_pred_idx : p' seed.entries[idx] = true := h_spec.2.1
    -- p must be false at entries[idx] since p' is true and predicates can't both be true
    have h_p_idx_false : p seed.entries[idx] = false := by
      by_contra h_p_true
      push_neg at h_p_true
      simp only [Bool.not_eq_false] at h_p_true
      exact h_pred_neq seed.entries[idx] ⟨h_p_true, h_pred_idx⟩
    -- The modified entry also doesn't match p (modification doesn't change familyIdx or timeIdx)
    have h_p_mod_false : p { seed.entries[idx] with formulas := insert psi seed.entries[idx].formulas } = false := by
      simp only [p, Bool.and_eq_false_iff] at h_p_idx_false ⊢
      exact h_p_idx_false
    cases h_find_orig : seed.entries.find? p with
    | none =>
      rw [h_find_orig] at h_mem
      exact absurd h_mem (Set.notMem_empty phi)
    | some entry =>
      -- entry matches p, show it's unchanged in modified list (since entry is at i ≠ idx)
      have h_entry_pred := List.find?_some h_find_orig
      have h_first := List.find?_eq_some_iff_getElem.mp h_find_orig
      obtain ⟨i, hi_lt, hi_eq, h_before_i⟩ := h_first.2
      have h_i_ne_idx : i ≠ idx := by
        intro h_eq
        have h_p_i : p seed.entries[i] = true := by rw [hi_eq]; exact h_entry_pred
        have h_p_idx_eq : p seed.entries[idx] = true := h_eq ▸ h_p_i
        rw [h_p_idx_eq] at h_p_idx_false
        cases h_p_idx_false
      have h_find_mod : (seed.entries.modify idx (fun e => { e with formulas := insert psi e.formulas })).find? p = some entry := by
        rw [List.find?_eq_some_iff_getElem]
        have h_len := List.length_modify (fun e : SeedEntry => { e with formulas := insert psi e.formulas }) seed.entries idx
        constructor
        · exact h_entry_pred
        · use i, (h_len ▸ hi_lt)
          constructor
          · rw [List.getElem_modify]
            split
            · rename_i h_idx_eq_i; exfalso; exact h_i_ne_idx h_idx_eq_i.symm
            · exact hi_eq
          · intro k hk
            rw [List.getElem_modify]
            split
            · -- k = idx case: show p of modified entry is false
              rename_i h_k_eq_idx
              simp only [Bool.not_eq_true']
              show p { seed.entries[k] with formulas := insert psi seed.entries[k].formulas } = false
              simp only [p, ← h_k_eq_idx]
              exact h_p_idx_false
            · -- k ≠ idx case: entry unchanged, use h_before_i
              exact h_before_i k hk
      -- Now rewrite the goal using h_find_mod, and h_mem using h_find_orig
      -- Note: p = (fun e => e.familyIdx == famIdx && e.timeIdx == t), which is definitionally equal to
      -- the predicate in the goal
      have h_find_mod' : List.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t)
            (seed.entries.modify idx fun e => { e with formulas := insert psi e.formulas }) = some entry := h_find_mod
      simp only [h_find_mod']
      rw [h_find_orig] at h_mem
      exact h_mem

/--
Helper: foldl over addFormula (over time list) preserves membership.
-/
private lemma foldl_addFormula_preserves_mem_general
    (phi psi : Formula) (famIdx addFam : Nat) (t : Int)
    (times : List Int) (s : ModelSeed)
    (h_mem : phi ∈ s.getFormulas famIdx t) :
    phi ∈ (times.foldl (fun s' addTime => s'.addFormula addFam addTime psi .universal_target) s).getFormulas famIdx t := by
  induction times generalizing s with
  | nil => exact h_mem
  | cons addTime rest ih =>
    simp only [List.foldl_cons]
    apply ih
    by_cases h_fam_eq : famIdx = addFam
    · by_cases h_time_eq : t = addTime
      · rw [h_fam_eq, h_time_eq]
        exact addFormula_preserves_mem_getFormulas_same s addFam addTime phi psi .universal_target (h_fam_eq ▸ h_time_eq ▸ h_mem)
      · exact addFormula_preserves_mem_diff_position s famIdx addFam t addTime phi psi .universal_target (Or.inr h_time_eq) h_mem
    · exact addFormula_preserves_mem_diff_position s famIdx addFam t addTime phi psi .universal_target (Or.inl h_fam_eq) h_mem

/--
Helper: foldl over addFormula (over family list) preserves membership.
-/
private lemma foldl_addFormula_fam_preserves_mem_general
    (phi psi : Formula) (famIdx : Nat) (t addTime : Int)
    (fams : List Nat) (s : ModelSeed)
    (h_mem : phi ∈ s.getFormulas famIdx t) :
    phi ∈ (fams.foldl (fun s' addFam => s'.addFormula addFam addTime psi .universal_target) s).getFormulas famIdx t := by
  induction fams generalizing s with
  | nil => exact h_mem
  | cons addFam rest ih =>
    simp only [List.foldl_cons]
    apply ih
    by_cases h_time_eq : t = addTime
    · by_cases h_fam_eq : famIdx = addFam
      · rw [h_fam_eq, h_time_eq]
        exact addFormula_preserves_mem_getFormulas_same s addFam addTime phi psi .universal_target (h_fam_eq ▸ h_time_eq ▸ h_mem)
      · exact addFormula_preserves_mem_diff_position s famIdx addFam t addTime phi psi .universal_target (Or.inl h_fam_eq) h_mem
    · exact addFormula_preserves_mem_diff_position s famIdx addFam t addTime phi psi .universal_target (Or.inr h_time_eq) h_mem

/--
addToAllFamilies preserves membership of existing formulas at any position.
Since addToAllFamilies only adds formulas (doesn't remove), existing membership is preserved.
-/
theorem addToAllFamilies_preserves_mem_getFormulas
    (seed : ModelSeed) (timeIdx : Int) (phi psi : Formula) (famIdx : Nat) (t : Int)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.addToAllFamilies timeIdx psi).getFormulas famIdx t := by
  unfold ModelSeed.addToAllFamilies
  exact foldl_addFormula_fam_preserves_mem_general phi psi famIdx t timeIdx _ seed h_mem

/--
addToAllPastTimes preserves membership of existing formulas at any position.
-/
theorem addToAllPastTimes_preserves_mem_getFormulas
    (seed : ModelSeed) (famIdxTarget : Nat) (currentTime : Int) (phi psi : Formula)
    (famIdx : Nat) (t : Int)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.addToAllPastTimes famIdxTarget currentTime psi).getFormulas famIdx t := by
  unfold ModelSeed.addToAllPastTimes
  exact foldl_addFormula_preserves_mem_general phi psi famIdx famIdxTarget t _ seed h_mem

/--
addToAllFutureTimes preserves membership of existing formulas at any position.
-/
theorem addToAllFutureTimes_preserves_mem_getFormulas
    (seed : ModelSeed) (famIdxTarget : Nat) (currentTime : Int) (phi psi : Formula)
    (famIdx : Nat) (t : Int)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.addToAllFutureTimes famIdxTarget currentTime psi).getFormulas famIdx t := by
  unfold ModelSeed.addToAllFutureTimes
  exact foldl_addFormula_preserves_mem_general phi psi famIdx famIdxTarget t _ seed h_mem

/--
createNewFamily preserves getFormulas at existing positions.
Since createNewFamily appends a new entry with a fresh family index,
existing entries are unchanged.

**Precondition**: Query position must differ from new entry position
(famIdx ≠ nextFamilyIdx or t ≠ timeIdx).
-/
theorem createNewFamily_preserves_getFormulas
    (seed : ModelSeed) (timeIdx : Int) (phi : Formula) (famIdx : Nat) (t : Int)
    (h_diff : famIdx ≠ seed.nextFamilyIdx ∨ t ≠ timeIdx) :
    (seed.createNewFamily timeIdx phi).1.getFormulas famIdx t = seed.getFormulas famIdx t := by
  unfold ModelSeed.createNewFamily ModelSeed.getFormulas ModelSeed.findEntry
  simp only
  -- New entry has familyIdx = seed.nextFamilyIdx which is > all existing family indices
  -- So find? on original list equals find? on appended list for existing famIdx
  rw [List.find?_append]
  cases h_find : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t) with
  | some entry => simp only [Option.some_or]
  | none =>
    simp only [Option.none_or]
    -- The new entry has familyIdx = nextFamilyIdx, which must be checked
    rw [List.find?_cons_of_neg]
    · rfl
    · -- New entry predicate is false due to h_diff
      intro h_pred
      simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
      -- h_pred : seed.nextFamilyIdx = famIdx ∧ timeIdx = t
      rcases h_diff with h_fam | h_time
      · exact h_fam h_pred.1.symm
      · exact h_time h_pred.2.symm

/--
createNewFamily preserves membership of existing formulas at any position.
Since createNewFamily only appends a new entry, existing entries are unchanged.

Note: The precondition about position difference is not needed because
if membership exists in the original seed, the entry is preserved in the result.
-/
theorem createNewFamily_preserves_mem_getFormulas
    (seed : ModelSeed) (timeIdx : Int) (phi psi : Formula) (famIdx : Nat) (t : Int)
    (h_mem : phi ∈ seed.getFormulas famIdx t) :
    phi ∈ (seed.createNewFamily timeIdx psi).1.getFormulas famIdx t := by
  unfold ModelSeed.createNewFamily ModelSeed.getFormulas ModelSeed.findEntry
  simp only
  rw [List.find?_append]
  -- Original find? found entry with phi
  have h_find_some : ∃ entry, seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t) = some entry := by
    by_contra h_none
    push_neg at h_none
    have h_eq_none : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t) = none := by
      cases h_find : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t) with
      | some entry => exfalso; exact h_none entry h_find
      | none => rfl
    unfold ModelSeed.getFormulas ModelSeed.findEntry at h_mem
    simp only [h_eq_none] at h_mem
    exact Set.notMem_empty phi h_mem
  obtain ⟨entry, h_entry⟩ := h_find_some
  simp only [h_entry, Option.some_or]
  -- entry.formulas contains phi
  unfold ModelSeed.getFormulas ModelSeed.findEntry at h_mem
  simp only [h_entry] at h_mem
  exact h_mem

/--
createNewTime preserves getFormulas at existing positions.
Since createNewTime appends a new entry, existing entries are unchanged.
-/
theorem createNewTime_preserves_getFormulas
    (seed : ModelSeed) (famIdxTarget : Nat) (newTime : Int) (phi : Formula)
    (famIdx : Nat) (t : Int) (h_diff : famIdx ≠ famIdxTarget ∨ t ≠ newTime) :
    (seed.createNewTime famIdxTarget newTime phi).getFormulas famIdx t = seed.getFormulas famIdx t := by
  unfold ModelSeed.createNewTime ModelSeed.getFormulas ModelSeed.findEntry
  simp only
  rw [List.find?_append]
  cases h_find : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == t) with
  | some entry => simp only [Option.some_or]
  | none =>
    simp only [Option.none_or]
    rw [List.find?_cons_of_neg]
    · rfl
    · intro h_pred
      simp only [beq_iff_eq, Bool.and_eq_true] at h_pred
      rcases h_diff with h_fam | h_time
      · exact h_fam h_pred.1.symm
      · exact h_time h_pred.2.symm

/--
createNewTime preserves membership of existing formulas at any position
that differs from (famIdxTarget, newTime).
-/
theorem createNewTime_preserves_mem_getFormulas
    (seed : ModelSeed) (famIdxTarget : Nat) (newTime : Int) (phi psi : Formula)
    (famIdx : Nat) (t : Int)
    (h_mem : phi ∈ seed.getFormulas famIdx t)
    (h_diff : famIdx ≠ famIdxTarget ∨ t ≠ newTime) :
    phi ∈ (seed.createNewTime famIdxTarget newTime psi).getFormulas famIdx t := by
  rw [createNewTime_preserves_getFormulas seed famIdxTarget newTime psi famIdx t h_diff]
  exact h_mem

/--
If there's a formula at position (famIdx, timeIdx) in a well-formed seed,
then famIdx < nextFamilyIdx.
-/
theorem wellFormed_mem_implies_famIdx_lt (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int) (phi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_mem : phi ∈ seed.getFormulas famIdx timeIdx) :
    famIdx < seed.nextFamilyIdx := by
  unfold ModelSeed.getFormulas ModelSeed.findEntry at h_mem
  cases h_find : seed.entries.find? (fun e => e.familyIdx == famIdx && e.timeIdx == timeIdx) with
  | none =>
    simp only [h_find] at h_mem
    exact absurd h_mem (Set.not_mem_empty phi)
  | some entry =>
    have h_entry_mem : entry ∈ seed.entries := List.mem_of_find?_eq_some h_find
    have h_entry_fam : entry.familyIdx = famIdx := by
      have := List.find?_some h_find
      simp only [beq_iff_eq, Bool.and_eq_true] at this
      exact this.1
    have h_lt := h_wf.1 entry h_entry_mem
    rw [← h_entry_fam]
    exact h_lt

/--
buildSeedAux preserves membership at ANY position, not just the processing position.
This is the monotonicity property: buildSeedAux only adds formulas, never removes.

**Proof strategy**: By strong induction on formula complexity. Each buildSeedAux operation
(addFormula, addToAllFamilies, createNewFamily, etc.) only adds formulas, never removes.
So membership at any position is preserved.

**Remaining work**: The proof requires handling many cases with proper disjunction conversion
using `not_and_or`. The key lemmas (addFormula_preserves_mem_diff_position,
addToAllFamilies_preserves_mem_getFormulas, etc.) are already proven.
-/
theorem buildSeedAux_preserves_mem_general (phi : Formula) (procFam : Nat) (procTime : Int)
    (seed : ModelSeed) (psi : Formula) (queryFam : Nat) (queryTime : Int)
    (h_mem : psi ∈ seed.getFormulas queryFam queryTime) :
    psi ∈ (buildSeedAux phi procFam procTime seed).getFormulas queryFam queryTime := by
  -- All operations in buildSeedAux only add formulas, never remove them
  -- This is a monotonicity property: formulas at any position are preserved
  -- Proof by strong induction on formula complexity
  generalize h_c : phi.complexity = c
  induction c using Nat.strong_induction_on generalizing phi procFam procTime seed with
  | _ c ih =>
    match phi with
    | Formula.atom s =>
      simp only [buildSeedAux]
      by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
      · rw [h_pos.1, h_pos.2]
        exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi (Formula.atom s) .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
      · push_neg at h_pos
        rcases not_and_or.mp h_pos with h_fam | h_time
        · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi (Formula.atom s) .universal_target (Or.inl h_fam) h_mem
        · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi (Formula.atom s) .universal_target (Or.inr h_time) h_mem
    | Formula.bot =>
      simp only [buildSeedAux]
      by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
      · rw [h_pos.1, h_pos.2]
        exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi Formula.bot .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
      · push_neg at h_pos
        rcases not_and_or.mp h_pos with h_fam | h_time
        · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi Formula.bot .universal_target (Or.inl h_fam) h_mem
        · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi Formula.bot .universal_target (Or.inr h_time) h_mem
    | Formula.box inner =>
      simp only [buildSeedAux]
      have h_complexity : inner.complexity < c := by rw [← h_c]; simp only [Formula.complexity]; omega
      -- Step 1: addFormula preserves membership
      have h1 : psi ∈ (seed.addFormula procFam procTime inner.box .universal_target).getFormulas queryFam queryTime := by
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi inner.box .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.box .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.box .universal_target (Or.inr h_time) h_mem
      -- Step 2: addToAllFamilies preserves membership
      have h2 : psi ∈ ((seed.addFormula procFam procTime inner.box .universal_target).addToAllFamilies procTime inner).getFormulas queryFam queryTime :=
        addToAllFamilies_preserves_mem_getFormulas _ procTime psi inner queryFam queryTime h1
      -- Step 3: recursive call preserves membership
      exact ih inner.complexity h_complexity inner procFam procTime _ psi queryFam queryTime h2 rfl
    | Formula.all_future inner =>
      simp only [buildSeedAux]
      have h_complexity : inner.complexity < c := by rw [← h_c]; simp only [Formula.complexity]; omega
      -- Step 1: first addFormula preserves membership
      have h1 : psi ∈ (seed.addFormula procFam procTime inner.all_future .universal_target).getFormulas queryFam queryTime := by
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi inner.all_future .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.all_future .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.all_future .universal_target (Or.inr h_time) h_mem
      -- Step 2: second addFormula preserves membership
      have h2 : psi ∈ ((seed.addFormula procFam procTime inner.all_future .universal_target).addFormula procFam procTime inner .universal_target).getFormulas queryFam queryTime := by
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same _ procFam procTime psi inner .universal_target (h_pos.1 ▸ h_pos.2 ▸ h1)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position _ queryFam procFam queryTime procTime psi inner .universal_target (Or.inl h_fam) h1
          · exact addFormula_preserves_mem_diff_position _ queryFam procFam queryTime procTime psi inner .universal_target (Or.inr h_time) h1
      -- Step 3: first addToAllFutureTimes preserves membership
      have h3 := addToAllFutureTimes_preserves_mem_getFormulas _ procFam procTime psi inner queryFam queryTime h2
      -- Step 4: second addToAllFutureTimes preserves membership
      have h4 := addToAllFutureTimes_preserves_mem_getFormulas _ procFam procTime psi inner.all_future queryFam queryTime h3
      -- Step 5: recursive call
      exact ih inner.complexity h_complexity inner procFam procTime _ psi queryFam queryTime h4 rfl
    | Formula.all_past inner =>
      simp only [buildSeedAux]
      have h_complexity : inner.complexity < c := by rw [← h_c]; simp only [Formula.complexity]; omega
      -- Step 1: first addFormula preserves membership
      have h1 : psi ∈ (seed.addFormula procFam procTime inner.all_past .universal_target).getFormulas queryFam queryTime := by
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi inner.all_past .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.all_past .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi inner.all_past .universal_target (Or.inr h_time) h_mem
      -- Step 2: second addFormula preserves membership
      have h2 : psi ∈ ((seed.addFormula procFam procTime inner.all_past .universal_target).addFormula procFam procTime inner .universal_target).getFormulas queryFam queryTime := by
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same _ procFam procTime psi inner .universal_target (h_pos.1 ▸ h_pos.2 ▸ h1)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position _ queryFam procFam queryTime procTime psi inner .universal_target (Or.inl h_fam) h1
          · exact addFormula_preserves_mem_diff_position _ queryFam procFam queryTime procTime psi inner .universal_target (Or.inr h_time) h1
      -- Step 3: first addToAllPastTimes preserves membership
      have h3 := addToAllPastTimes_preserves_mem_getFormulas _ procFam procTime psi inner queryFam queryTime h2
      -- Step 4: second addToAllPastTimes preserves membership
      have h4 := addToAllPastTimes_preserves_mem_getFormulas _ procFam procTime psi inner.all_past queryFam queryTime h3
      -- Step 5: recursive call
      exact ih inner.complexity h_complexity inner procFam procTime _ psi queryFam queryTime h4 rfl
    | Formula.imp p1 p2 =>
      -- Case split on negation cases vs regular implication
      cases hp2 : p2 with
      | bot =>
        -- Negation case: phi = p1 -> bot = neg p1
        cases hp1 : p1 with
        | box inner =>
          -- neg(Box inner): creates new family
          simp only [buildSeedAux]
          have h_complexity : (Formula.neg inner).complexity < c := by
            rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
          -- Step 1: addFormula preserves
          have h1 : psi ∈ (seed.addFormula procFam procTime (Formula.neg (Formula.box inner)) .universal_target).getFormulas queryFam queryTime := by
            by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
            · rw [h_pos.1, h_pos.2]
              exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
            · push_neg at h_pos
              rcases not_and_or.mp h_pos with h_fam | h_time
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
          -- Step 2: createNewFamily preserves (no precondition needed - just appends)
          set seed1 := seed.addFormula procFam procTime (Formula.neg (Formula.box inner)) .universal_target with h_seed1
          set result := seed1.createNewFamily procTime (Formula.neg inner) with h_result
          have h2 : psi ∈ result.1.getFormulas queryFam queryTime :=
            createNewFamily_preserves_mem_getFormulas seed1 procTime psi (Formula.neg inner) queryFam queryTime h1
          -- Step 3: recursive call
          exact ih (Formula.neg inner).complexity h_complexity (Formula.neg inner) result.2 procTime result.1 psi queryFam queryTime h2 rfl
        | all_future inner =>
          -- neg(G inner): creates new time in future
          simp only [buildSeedAux]
          have h_complexity : (Formula.neg inner).complexity < c := by
            rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
          -- Step 1: addFormula preserves
          have h1 : psi ∈ (seed.addFormula procFam procTime (Formula.neg (Formula.all_future inner)) .universal_target).getFormulas queryFam queryTime := by
            by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
            · rw [h_pos.1, h_pos.2]
              exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
            · push_neg at h_pos
              rcases not_and_or.mp h_pos with h_fam | h_time
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
          -- Step 2: createNewTime preserves
          set seed1 := seed.addFormula procFam procTime (Formula.neg (Formula.all_future inner)) .universal_target with h_seed1
          set newTime := seed1.freshFutureTime procFam procTime with h_newTime
          have h_diff : queryFam ≠ procFam ∨ queryTime ≠ newTime := by
            -- newTime is fresh (> all existing times for procFam), so if queryTime is in seed1, queryTime ≠ newTime
            by_cases h_fam : queryFam = procFam
            · right
              -- queryTime exists in seed1 (by h1), and newTime is fresh
              -- We need to show queryTime ≠ freshFutureTime
              rw [h_fam] at h1
              -- freshFutureTime is > all times in seed1 for family procFam
              -- If psi ∈ getFormulas procFam queryTime, then queryTime is an existing time
              -- Therefore queryTime < freshFutureTime (actually, could be ≤, but fresh guarantees strict >)
              -- This requires knowing freshFutureTime_gt_all or similar
              intro h_eq
              rw [h_eq] at h1
              -- h1 says psi ∈ seed1.getFormulas procFam newTime
              -- But newTime is fresh, so there's no entry at (procFam, newTime) in seed1 yet
              have h_no_entry : seed1.getFormulas procFam newTime = ∅ := by
                unfold ModelSeed.getFormulas ModelSeed.findEntry
                have h_find_none : seed1.entries.find? (fun e => e.familyIdx == procFam && e.timeIdx == newTime) = none := by
                  rw [List.find?_eq_none]
                  intro x hx
                  simp only [Bool.not_eq_true, beq_iff_eq, Bool.and_eq_false_iff]
                  by_cases h_fam_x : x.familyIdx = procFam
                  · right
                    -- x.timeIdx ≠ newTime because newTime is fresh
                    rw [h_fam_x]
                    have h_fresh := freshFutureTime_gt_current seed1 procFam procTime
                    -- freshFutureTime is > all times in familyTimes procFam
                    -- If x is in seed1.entries with familyIdx = procFam, then x.timeIdx is in familyTimes
                    have h_x_time_in : x.timeIdx ∈ seed1.familyTimes procFam := by
                      unfold ModelSeed.familyTimes
                      simp only [List.mem_map, List.mem_filter]
                      use x
                      constructor
                      · constructor
                        · exact hx
                        · simp only [beq_iff_eq]; exact h_fam_x
                      · rfl
                    have h_all_lt : ∀ t ∈ seed1.familyTimes procFam, t < seed1.freshFutureTime procFam procTime := by
                      intro t ht
                      unfold ModelSeed.freshFutureTime
                      have h_bound := seed1.familyTimeBound procFam
                      omega
                    have := h_all_lt x.timeIdx h_x_time_in
                    omega
                  · left; exact h_fam_x
                simp only [h_find_none]
              rw [h_no_entry] at h1
              exact Set.not_mem_empty psi h1
            · left; exact h_fam
          have h2 := createNewTime_preserves_mem_getFormulas seed1 procFam newTime (Formula.neg inner) psi queryFam queryTime h1 h_diff
          -- Step 3: recursive call
          exact ih (Formula.neg inner).complexity h_complexity (Formula.neg inner) procFam newTime _ psi queryFam queryTime h2 rfl
        | all_past inner =>
          -- neg(H inner): creates new time in past
          simp only [buildSeedAux]
          have h_complexity : (Formula.neg inner).complexity < c := by
            rw [← h_c]; simp only [Formula.complexity, Formula.neg]; omega
          -- Step 1: addFormula preserves
          have h1 : psi ∈ (seed.addFormula procFam procTime (Formula.neg (Formula.all_past inner)) .universal_target).getFormulas queryFam queryTime := by
            by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
            · rw [h_pos.1, h_pos.2]
              exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
            · push_neg at h_pos
              rcases not_and_or.mp h_pos with h_fam | h_time
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
              · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
          -- Step 2: createNewTime preserves
          set seed1 := seed.addFormula procFam procTime (Formula.neg (Formula.all_past inner)) .universal_target with h_seed1
          set newTime := seed1.freshPastTime procFam procTime with h_newTime
          have h_diff : queryFam ≠ procFam ∨ queryTime ≠ newTime := by
            by_cases h_fam : queryFam = procFam
            · right
              rw [h_fam] at h1
              intro h_eq
              rw [h_eq] at h1
              have h_no_entry : seed1.getFormulas procFam newTime = ∅ := by
                unfold ModelSeed.getFormulas ModelSeed.findEntry
                have h_find_none : seed1.entries.find? (fun e => e.familyIdx == procFam && e.timeIdx == newTime) = none := by
                  rw [List.find?_eq_none]
                  intro x hx
                  simp only [Bool.not_eq_true, beq_iff_eq, Bool.and_eq_false_iff]
                  by_cases h_fam_x : x.familyIdx = procFam
                  · right
                    rw [h_fam_x]
                    have h_x_time_in : x.timeIdx ∈ seed1.familyTimes procFam := by
                      unfold ModelSeed.familyTimes
                      simp only [List.mem_map, List.mem_filter]
                      use x
                      constructor
                      · constructor
                        · exact hx
                        · simp only [beq_iff_eq]; exact h_fam_x
                      · rfl
                    have h_all_gt : ∀ t ∈ seed1.familyTimes procFam, t > seed1.freshPastTime procFam procTime := by
                      intro t ht
                      unfold ModelSeed.freshPastTime
                      have h_bound := seed1.familyTimeBound procFam
                      omega
                    have := h_all_gt x.timeIdx h_x_time_in
                    omega
                  · left; exact h_fam_x
                simp only [h_find_none]
              rw [h_no_entry] at h1
              exact Set.not_mem_empty psi h1
            · left; exact h_fam
          have h2 := createNewTime_preserves_mem_getFormulas seed1 procFam newTime (Formula.neg inner) psi queryFam queryTime h1 h_diff
          -- Step 3: recursive call
          exact ih (Formula.neg inner).complexity h_complexity (Formula.neg inner) procFam newTime _ psi queryFam queryTime h2 rfl
        | atom s =>
          -- neg(atom s): just addFormula
          simp only [buildSeedAux]
          by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
          · rw [h_pos.1, h_pos.2]
            exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
          · push_neg at h_pos
            rcases not_and_or.mp h_pos with h_fam | h_time
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
        | bot =>
          -- neg(bot) = bot -> bot: just addFormula
          simp only [buildSeedAux]
          by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
          · rw [h_pos.1, h_pos.2]
            exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
          · push_neg at h_pos
            rcases not_and_or.mp h_pos with h_fam | h_time
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
        | imp q1 q2 =>
          -- neg(imp q1 q2): just addFormula
          simp only [buildSeedAux]
          by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
          · rw [h_pos.1, h_pos.2]
            exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
          · push_neg at h_pos
            rcases not_and_or.mp h_pos with h_fam | h_time
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
            · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
      | atom s =>
        -- p1 -> (atom s): just addFormula
        simp only [buildSeedAux]
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
      | box q =>
        -- p1 -> (box q): just addFormula
        simp only [buildSeedAux]
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
      | all_future q =>
        -- p1 -> (all_future q): just addFormula
        simp only [buildSeedAux]
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
      | all_past q =>
        -- p1 -> (all_past q): just addFormula
        simp only [buildSeedAux]
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem
      | imp q1 q2 =>
        -- p1 -> (imp q1 q2): just addFormula
        simp only [buildSeedAux]
        by_cases h_pos : queryFam = procFam ∧ queryTime = procTime
        · rw [h_pos.1, h_pos.2]
          exact addFormula_preserves_mem_getFormulas_same seed procFam procTime psi _ .universal_target (h_pos.1 ▸ h_pos.2 ▸ h_mem)
        · push_neg at h_pos
          rcases not_and_or.mp h_pos with h_fam | h_time
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inl h_fam) h_mem
          · exact addFormula_preserves_mem_diff_position seed queryFam procFam queryTime procTime psi _ .universal_target (Or.inr h_time) h_mem

/--
buildSeedAux preserves membership of existing formulas at the processing position.

This is the key lemma: when buildSeedAux processes a formula at (famIdx, timeIdx),
any formula already present at that position remains present in the result.

Requires well-formedness to ensure family indices are valid.
-/
theorem buildSeedAux_preserves_getFormulas (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (psi : Formula)
    (h_wf : SeedWellFormed seed)
    (h_mem : psi ∈ seed.getFormulas famIdx timeIdx) :
    psi ∈ (buildSeedAux phi famIdx timeIdx seed).getFormulas famIdx timeIdx := by
  -- This follows from the more general buildSeedAux_preserves_mem_general
  -- but that lemma is currently sorried. The key insight is:
  -- buildSeedAux only adds formulas (addFormula, addToAllFamilies, etc.)
  -- It never removes formulas, so membership is preserved.
  exact buildSeedAux_preserves_mem_general phi famIdx timeIdx seed psi famIdx timeIdx h_mem

-- Original proof structure (archived for reference):
-- induction on formula complexity, case analysis on phi
-- For each case: trace through the operations showing membership preserved
-- The challenge: recursive calls need well-formedness of intermediate seeds
-- This requires proving buildSeedAux_preserves_wellFormed as a mutual lemma
-- Alternative: use buildSeedAux_preserves_mem_general which doesn't need wf

/-  OLD PROOF START (removed to fix build errors)
  generalize h_c : phi.complexity = c
  induction c using Nat.strong_induction_on generalizing phi famIdx timeIdx seed with
  | h c ih =>
    match phi with
    | Formula.atom s =>
      simp only [buildSeedAux]
      exact addFormula_preserves_mem_getFormulas_same seed famIdx timeIdx psi (Formula.atom s) .universal_target h_mem
    | Formula.bot =>
      simp only [buildSeedAux]
      exact addFormula_preserves_mem_getFormulas_same seed famIdx timeIdx psi Formula.bot .universal_target h_mem
    | Formula.box inner =>
      simp only [buildSeedAux]
      have h_complexity : inner.complexity < c := by rw [← h_c]; simp only [Formula.complexity]; omega
      have h1 := addFormula_preserves_mem_getFormulas_same seed famIdx timeIdx psi inner.box .universal_target h_mem
      have h2 := addToAllFamilies_preserves_mem_getFormulas _ timeIdx psi inner famIdx timeIdx h1
      exact ih inner.complexity h_complexity inner famIdx timeIdx _ h2 rfl
    ...
  OLD PROOF END -/

theorem buildSeedAux_preserves_getFormulas_v2 (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) (psi : Formula)
    (h_mem : psi ∈ seed.getFormulas famIdx timeIdx) :
    psi ∈ (buildSeedAux phi famIdx timeIdx seed).getFormulas famIdx timeIdx :=
  -- Version without well-formedness requirement, using the general lemma
  buildSeedAux_preserves_mem_general phi famIdx timeIdx seed psi famIdx timeIdx h_mem

/-!
## Phase 1 (Task 881): Multi-Formula Seed Builder

This section extends RecursiveSeed to process multiple formulas, enabling construction
of seeds for entire MCS content. This is the foundation for modal saturation:
- Process ALL formulas in an evaluation MCS
- Pre-place witnesses for ALL neg(Box phi) formulas
- Maintain consistency throughout

### Key Insight

When formulas come from a consistent set (like an MCS), adding them sequentially
to the seed preserves consistency because:
1. Each formula is individually consistent (subset of consistent set)
2. buildSeedAux only adds subformulas and logical consequences
3. Adding derivable formulas preserves consistency
-/

/--
Build a model seed from a list of formulas by processing each sequentially.

Each formula is processed at position (0, 0) in family 0, starting from an
initial seed containing the first formula (if the list is non-empty).

This is used to build seeds for MCS content where all formulas should be
present at the evaluation position (0, 0).
-/
def buildSeedForList : List Formula → ModelSeed
  | [] => ModelSeed.empty
  | [phi] => buildSeed phi
  | phi :: psi :: rest =>
    -- Start with seed for phi, then add psi and remaining formulas
    let seed0 := buildSeed phi
    (psi :: rest).foldl (fun seed phi' => buildSeedAux phi' 0 0 seed) seed0

/--
Alternative definition: foldl starting from an initial seed with the first formula.
-/
def buildSeedForList' (formulas : List Formula) : ModelSeed :=
  match formulas with
  | [] => ModelSeed.empty
  | phi :: rest =>
    let initialSeed := ModelSeed.initial phi
    -- First process phi to build its structure
    let seed0 := buildSeedAux phi 0 0 initialSeed
    -- Then add each remaining formula at (0, 0)
    rest.foldl (fun seed phi' => buildSeedAux phi' 0 0 seed) seed0

/--
buildSeedForList preserves the single-formula case.
-/
theorem buildSeedForList_singleton (phi : Formula) :
    buildSeedForList [phi] = buildSeed phi := rfl

/--
buildSeedForList on empty list gives empty seed.
-/
theorem buildSeedForList_nil : buildSeedForList [] = ModelSeed.empty := rfl

/--
Helper: foldl with buildSeedAux preserves SeedConsistent when all formulas are consistent.
-/
theorem foldl_buildSeedAux_preserves_seedConsistent
    (formulas : List Formula) (seed : ModelSeed)
    (h_seed_cons : SeedConsistent seed)
    (h_seed_wf : SeedWellFormed seed)
    (h_formulas_cons : ∀ phi ∈ formulas, FormulaConsistent phi)
    (h_has_family_0 : 0 ∈ seed.familyIndices)
    (h_single_fam : seed.familyIndices = [0] → ∀ phi ∈ formulas,
        (buildSeedAux phi 0 0 seed).familyIndices = [0])
    (h_single_time : seed.timeIndices 0 = [0] → ∀ phi ∈ formulas,
        (buildSeedAux phi 0 0 seed).timeIndices 0 = [0]) :
    SeedConsistent (formulas.foldl (fun s phi => buildSeedAux phi 0 0 s) seed) := by
  induction formulas generalizing seed with
  | nil => exact h_seed_cons
  | cons phi rest ih =>
    simp only [List.foldl_cons]
    -- For the recursive call, we need to show buildSeedAux phi 0 0 seed is consistent
    -- This requires the entry at (0, 0) to contain phi (which it does after addFormula)
    -- and phi to be consistent
    have h_phi_cons := h_formulas_cons phi List.mem_cons_self
    -- We need to establish that buildSeedAux phi 0 0 seed satisfies SeedConsistent
    -- This follows a similar pattern to seedConsistent but starting from an existing seed
    -- The key insight is that buildSeedAux adds phi and its subformulas/consequences
    -- For now, we use the fact that the seed already has structure at (0, 0)
    -- and phi is consistent
    -- TODO: The full proof requires generalizing buildSeedAux_preserves_seedConsistent
    -- to work with arbitrary starting seeds that already have formulas at (0, 0)
    -- For Phase 1, we establish the definition; full proof comes in later phases
    sorry

/--
If all formulas in a list are consistent, then buildSeedForList produces a consistent seed.

**Note**: This theorem requires that the formulas be MUTUALLY consistent (e.g., from the same MCS),
not just individually consistent. A full proof requires showing that buildSeedAux preserves
consistency when adding formulas that are compatible with existing seed content.
-/
theorem buildSeedForList_consistent (formulas : List Formula) (h_ne : formulas ≠ [])
    (h_all_cons : ∀ phi ∈ formulas, FormulaConsistent phi)
    (h_mutual_cons : SetConsistent (formulas.toFinset.toSet)) :
    SeedConsistent (buildSeedForList formulas) := by
  match formulas with
  | [] => contradiction
  | [phi] =>
    simp only [buildSeedForList]
    exact seedConsistent phi (h_all_cons phi (by simp))
  | phi :: psi :: rest =>
    simp only [buildSeedForList]
    -- Start from buildSeed phi which is consistent
    have h_phi_cons := h_all_cons phi (by simp)
    have h_seed_cons : SeedConsistent (buildSeed phi) := seedConsistent phi h_phi_cons
    -- Now we need to show the foldl preserves consistency
    -- This requires the mutual consistency hypothesis
    sorry

/--
buildSeed phi contains phi at position (0, 0).

This holds because buildSeedAux calls addFormula at (0, 0) for the formula phi,
and addFormula_formula_in_getFormulas ensures phi is in the result.
-/
theorem buildSeed_contains_formula (phi : Formula) : phi ∈ (buildSeed phi).getFormulas 0 0 := by
  unfold buildSeed
  -- For non-recursive cases, buildSeedAux directly calls addFormula
  -- For recursive cases, we use buildSeedAux_preserves_mem_general to show the formula
  -- added at the beginning is preserved through the recursive processing
  induction phi with
  | atom s =>
    simp only [buildSeedAux]
    exact addFormula_formula_in_getFormulas _ _ _ _ _
  | bot =>
    simp only [buildSeedAux]
    exact addFormula_formula_in_getFormulas _ _ _ _ _
  | box psi ih =>
    simp only [buildSeedAux]
    -- Step 1: box psi is added at (0, 0)
    have h1 : psi.box ∈ ((ModelSeed.initial psi.box).addFormula 0 0 psi.box .universal_target).getFormulas 0 0 :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    -- Step 2: addToAllFamilies preserves membership at (0, 0)
    have h2 := addToAllFamilies_preserves_mem_getFormulas _ 0 psi.box psi 0 0 h1
    -- Step 3: recursive buildSeedAux preserves membership
    exact buildSeedAux_preserves_mem_general psi 0 0 _ psi.box 0 0 h2
  | all_future psi ih =>
    simp only [buildSeedAux]
    -- Step 1: all_future psi is added at (0, 0)
    have h1 : psi.all_future ∈ ((ModelSeed.initial psi.all_future).addFormula 0 0 psi.all_future .universal_target).getFormulas 0 0 :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    -- Step 2: second addFormula preserves
    have h2 : psi.all_future ∈ (((ModelSeed.initial psi.all_future).addFormula 0 0 psi.all_future .universal_target).addFormula 0 0 psi .universal_target).getFormulas 0 0 :=
      addFormula_preserves_mem_getFormulas_same _ _ _ psi.all_future psi .universal_target h1
    -- Step 3: addToAllFutureTimes preserves
    have h3 := addToAllFutureTimes_preserves_mem_getFormulas _ 0 0 psi.all_future psi 0 0 h2
    -- Step 4: second addToAllFutureTimes preserves
    have h4 := addToAllFutureTimes_preserves_mem_getFormulas _ 0 0 psi.all_future psi.all_future 0 0 h3
    -- Step 5: recursive buildSeedAux preserves
    exact buildSeedAux_preserves_mem_general psi 0 0 _ psi.all_future 0 0 h4
  | all_past psi ih =>
    simp only [buildSeedAux]
    -- Similar to all_future case
    have h1 : psi.all_past ∈ ((ModelSeed.initial psi.all_past).addFormula 0 0 psi.all_past .universal_target).getFormulas 0 0 :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    have h2 : psi.all_past ∈ (((ModelSeed.initial psi.all_past).addFormula 0 0 psi.all_past .universal_target).addFormula 0 0 psi .universal_target).getFormulas 0 0 :=
      addFormula_preserves_mem_getFormulas_same _ _ _ psi.all_past psi .universal_target h1
    have h3 := addToAllPastTimes_preserves_mem_getFormulas _ 0 0 psi.all_past psi 0 0 h2
    have h4 := addToAllPastTimes_preserves_mem_getFormulas _ 0 0 psi.all_past psi.all_past 0 0 h3
    exact buildSeedAux_preserves_mem_general psi 0 0 _ psi.all_past 0 0 h4
  | imp psi1 psi2 ih1 ih2 =>
    -- Case split on negation vs regular implication
    cases hp2 : psi2 with
    | bot =>
      cases hp1 : psi1 with
      | box inner =>
        simp only [buildSeedAux]
        -- neg(Box inner) case: add negation, then createNewFamily, then recurse
        have h1 : (Formula.neg (Formula.box inner)) ∈
            ((ModelSeed.initial (Formula.neg (Formula.box inner))).addFormula 0 0 (Formula.neg (Formula.box inner)) .universal_target).getFormulas 0 0 :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := (ModelSeed.initial (Formula.neg (Formula.box inner))).addFormula 0 0 (Formula.neg (Formula.box inner)) .universal_target
        set result := seed1.createNewFamily 0 (Formula.neg inner)
        have h2 : (Formula.neg (Formula.box inner)) ∈ result.1.getFormulas 0 0 :=
          createNewFamily_preserves_mem_getFormulas seed1 0 (Formula.neg (Formula.box inner)) (Formula.neg inner) 0 0 h1
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) result.2 0 result.1 (Formula.neg (Formula.box inner)) 0 0 h2
      | all_future inner =>
        simp only [buildSeedAux]
        -- neg(G inner) case
        have h1 : (Formula.neg (Formula.all_future inner)) ∈
            ((ModelSeed.initial (Formula.neg (Formula.all_future inner))).addFormula 0 0 (Formula.neg (Formula.all_future inner)) .universal_target).getFormulas 0 0 :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := (ModelSeed.initial (Formula.neg (Formula.all_future inner))).addFormula 0 0 (Formula.neg (Formula.all_future inner)) .universal_target
        set newTime := seed1.freshFutureTime 0 0
        have h_diff : (0 : Nat) ≠ 0 ∨ (0 : Int) ≠ newTime := by
          right
          have := freshFutureTime_ne_current seed1 0 0
          omega
        have h2 : (Formula.neg (Formula.all_future inner)) ∈ (seed1.createNewTime 0 newTime (Formula.neg inner)).getFormulas 0 0 :=
          createNewTime_preserves_mem_getFormulas seed1 0 newTime (Formula.neg (Formula.all_future inner)) (Formula.neg inner) 0 0 h1 h_diff
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) 0 newTime _ (Formula.neg (Formula.all_future inner)) 0 0 h2
      | all_past inner =>
        simp only [buildSeedAux]
        -- neg(H inner) case
        have h1 : (Formula.neg (Formula.all_past inner)) ∈
            ((ModelSeed.initial (Formula.neg (Formula.all_past inner))).addFormula 0 0 (Formula.neg (Formula.all_past inner)) .universal_target).getFormulas 0 0 :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := (ModelSeed.initial (Formula.neg (Formula.all_past inner))).addFormula 0 0 (Formula.neg (Formula.all_past inner)) .universal_target
        set newTime := seed1.freshPastTime 0 0
        have h_diff : (0 : Nat) ≠ 0 ∨ (0 : Int) ≠ newTime := by
          right
          have := freshPastTime_ne_current seed1 0 0
          omega
        have h2 : (Formula.neg (Formula.all_past inner)) ∈ (seed1.createNewTime 0 newTime (Formula.neg inner)).getFormulas 0 0 :=
          createNewTime_preserves_mem_getFormulas seed1 0 newTime (Formula.neg (Formula.all_past inner)) (Formula.neg inner) 0 0 h1 h_diff
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) 0 newTime _ (Formula.neg (Formula.all_past inner)) 0 0 h2
      | atom s =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
      | bot =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
      | imp q1 q2 =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
    | atom s =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | box q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | all_future q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | all_past q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | imp q1 q2 =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _

/--
buildSeedAux phi famIdx timeIdx seed adds phi to position (famIdx, timeIdx).

This generalizes buildSeed_contains_formula to arbitrary seeds and positions.
The proof follows the same structure: buildSeedAux always starts by adding the
formula at the processing position, and subsequent operations preserve this.
-/
theorem buildSeedAux_adds_formula_at_position (phi : Formula) (famIdx : Nat) (timeIdx : Int)
    (seed : ModelSeed) : phi ∈ (buildSeedAux phi famIdx timeIdx seed).getFormulas famIdx timeIdx := by
  -- The proof follows the same pattern as buildSeed_contains_formula
  induction phi generalizing famIdx timeIdx seed with
  | atom s =>
    simp only [buildSeedAux]
    exact addFormula_formula_in_getFormulas _ _ _ _ _
  | bot =>
    simp only [buildSeedAux]
    exact addFormula_formula_in_getFormulas _ _ _ _ _
  | box psi ih =>
    simp only [buildSeedAux]
    have h1 : psi.box ∈ (seed.addFormula famIdx timeIdx psi.box .universal_target).getFormulas famIdx timeIdx :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    have h2 := addToAllFamilies_preserves_mem_getFormulas _ timeIdx psi.box psi famIdx timeIdx h1
    exact buildSeedAux_preserves_mem_general psi famIdx timeIdx _ psi.box famIdx timeIdx h2
  | all_future psi ih =>
    simp only [buildSeedAux]
    have h1 : psi.all_future ∈ (seed.addFormula famIdx timeIdx psi.all_future .universal_target).getFormulas famIdx timeIdx :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    have h2 : psi.all_future ∈ ((seed.addFormula famIdx timeIdx psi.all_future .universal_target).addFormula famIdx timeIdx psi .universal_target).getFormulas famIdx timeIdx :=
      addFormula_preserves_mem_getFormulas_same _ _ _ psi.all_future psi .universal_target h1
    have h3 := addToAllFutureTimes_preserves_mem_getFormulas _ famIdx timeIdx psi.all_future psi famIdx timeIdx h2
    have h4 := addToAllFutureTimes_preserves_mem_getFormulas _ famIdx timeIdx psi.all_future psi.all_future famIdx timeIdx h3
    exact buildSeedAux_preserves_mem_general psi famIdx timeIdx _ psi.all_future famIdx timeIdx h4
  | all_past psi ih =>
    simp only [buildSeedAux]
    have h1 : psi.all_past ∈ (seed.addFormula famIdx timeIdx psi.all_past .universal_target).getFormulas famIdx timeIdx :=
      addFormula_formula_in_getFormulas _ _ _ _ _
    have h2 : psi.all_past ∈ ((seed.addFormula famIdx timeIdx psi.all_past .universal_target).addFormula famIdx timeIdx psi .universal_target).getFormulas famIdx timeIdx :=
      addFormula_preserves_mem_getFormulas_same _ _ _ psi.all_past psi .universal_target h1
    have h3 := addToAllPastTimes_preserves_mem_getFormulas _ famIdx timeIdx psi.all_past psi famIdx timeIdx h2
    have h4 := addToAllPastTimes_preserves_mem_getFormulas _ famIdx timeIdx psi.all_past psi.all_past famIdx timeIdx h3
    exact buildSeedAux_preserves_mem_general psi famIdx timeIdx _ psi.all_past famIdx timeIdx h4
  | imp psi1 psi2 ih1 ih2 =>
    cases hp2 : psi2 with
    | bot =>
      cases hp1 : psi1 with
      | box inner =>
        simp only [buildSeedAux]
        have h1 : (Formula.neg (Formula.box inner)) ∈
            (seed.addFormula famIdx timeIdx (Formula.neg (Formula.box inner)) .universal_target).getFormulas famIdx timeIdx :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := seed.addFormula famIdx timeIdx (Formula.neg (Formula.box inner)) .universal_target
        set result := seed1.createNewFamily timeIdx (Formula.neg inner)
        have h2 : (Formula.neg (Formula.box inner)) ∈ result.1.getFormulas famIdx timeIdx :=
          createNewFamily_preserves_mem_getFormulas seed1 timeIdx (Formula.neg (Formula.box inner)) (Formula.neg inner) famIdx timeIdx h1
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) result.2 timeIdx result.1 (Formula.neg (Formula.box inner)) famIdx timeIdx h2
      | all_future inner =>
        simp only [buildSeedAux]
        have h1 : (Formula.neg (Formula.all_future inner)) ∈
            (seed.addFormula famIdx timeIdx (Formula.neg (Formula.all_future inner)) .universal_target).getFormulas famIdx timeIdx :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := seed.addFormula famIdx timeIdx (Formula.neg (Formula.all_future inner)) .universal_target
        set newTime := seed1.freshFutureTime famIdx timeIdx
        have h_diff : famIdx ≠ famIdx ∨ timeIdx ≠ newTime := by
          right
          have := freshFutureTime_ne_current seed1 famIdx timeIdx
          omega
        have h2 : (Formula.neg (Formula.all_future inner)) ∈ (seed1.createNewTime famIdx newTime (Formula.neg inner)).getFormulas famIdx timeIdx :=
          createNewTime_preserves_mem_getFormulas seed1 famIdx newTime (Formula.neg (Formula.all_future inner)) (Formula.neg inner) famIdx timeIdx h1 h_diff
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) famIdx newTime _ (Formula.neg (Formula.all_future inner)) famIdx timeIdx h2
      | all_past inner =>
        simp only [buildSeedAux]
        have h1 : (Formula.neg (Formula.all_past inner)) ∈
            (seed.addFormula famIdx timeIdx (Formula.neg (Formula.all_past inner)) .universal_target).getFormulas famIdx timeIdx :=
          addFormula_formula_in_getFormulas _ _ _ _ _
        set seed1 := seed.addFormula famIdx timeIdx (Formula.neg (Formula.all_past inner)) .universal_target
        set newTime := seed1.freshPastTime famIdx timeIdx
        have h_diff : famIdx ≠ famIdx ∨ timeIdx ≠ newTime := by
          right
          have := freshPastTime_ne_current seed1 famIdx timeIdx
          omega
        have h2 : (Formula.neg (Formula.all_past inner)) ∈ (seed1.createNewTime famIdx newTime (Formula.neg inner)).getFormulas famIdx timeIdx :=
          createNewTime_preserves_mem_getFormulas seed1 famIdx newTime (Formula.neg (Formula.all_past inner)) (Formula.neg inner) famIdx timeIdx h1 h_diff
        exact buildSeedAux_preserves_mem_general (Formula.neg inner) famIdx newTime _ (Formula.neg (Formula.all_past inner)) famIdx timeIdx h2
      | atom s =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
      | bot =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
      | imp q1 q2 =>
        simp only [buildSeedAux]
        exact addFormula_formula_in_getFormulas _ _ _ _ _
    | atom s =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | box q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | all_future q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | all_past q =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _
    | imp q1 q2 =>
      simp only [buildSeedAux]
      exact addFormula_formula_in_getFormulas _ _ _ _ _

/--
Helper: foldl with buildSeedAux preserves membership at (0, 0).
-/
private lemma foldl_buildSeedAux_preserves_mem_at_origin
    (formulas : List Formula) (seed : ModelSeed) (phi : Formula)
    (h_mem : phi ∈ seed.getFormulas 0 0) :
    phi ∈ (formulas.foldl (fun s psi => buildSeedAux psi 0 0 s) seed).getFormulas 0 0 := by
  induction formulas generalizing seed with
  | nil => exact h_mem
  | cons psi rest ih =>
    simp only [List.foldl_cons]
    apply ih
    exact buildSeedAux_preserves_mem_general psi 0 0 seed phi 0 0 h_mem

/--
Helper: foldl with buildSeedAux adds each formula to (0, 0).
-/
private lemma foldl_buildSeedAux_adds_formula_at_origin
    (formulas : List Formula) (seed : ModelSeed) (phi : Formula)
    (h_mem : phi ∈ formulas) :
    phi ∈ (formulas.foldl (fun s psi => buildSeedAux psi 0 0 s) seed).getFormulas 0 0 := by
  induction formulas generalizing seed with
  | nil => simp at h_mem
  | cons psi rest ih =>
    simp only [List.foldl_cons]
    rw [List.mem_cons] at h_mem
    cases h_mem with
    | inl h_eq =>
      -- phi = psi, so it's added by buildSeedAux psi 0 0 seed
      subst h_eq
      -- First, show that buildSeedAux psi 0 0 seed contains psi at (0, 0)
      have h_contains := buildSeedAux_adds_formula_at_position psi 0 0 seed
      -- Then foldl preserves this
      exact foldl_buildSeedAux_preserves_mem_at_origin rest _ psi h_contains
    | inr h_rest =>
      -- phi is in rest, so use IH
      exact ih (buildSeedAux psi 0 0 seed) h_rest

/--
A formula is in buildSeedForList's seed at (0, 0) if it's in the input list.
-/
theorem buildSeedForList_contains_input (formulas : List Formula) (phi : Formula)
    (h_mem : phi ∈ formulas) :
    phi ∈ (buildSeedForList formulas).getFormulas 0 0 := by
  match formulas with
  | [] => simp at h_mem
  | [psi] =>
    simp only [List.mem_singleton] at h_mem
    subst h_mem
    simp only [buildSeedForList]
    exact buildSeed_contains_formula phi
  | psi1 :: psi2 :: rest =>
    simp only [buildSeedForList]
    rw [List.mem_cons] at h_mem
    cases h_mem with
    | inl h_eq =>
      -- phi = psi1, contained in buildSeed psi1
      subst h_eq
      have h_in_seed := buildSeed_contains_formula psi1
      exact foldl_buildSeedAux_preserves_mem_at_origin (psi2 :: rest) _ psi1 h_in_seed
    | inr h_rest =>
      -- phi is in psi2 :: rest, so foldl adds it
      exact foldl_buildSeedAux_adds_formula_at_origin (psi2 :: rest) (buildSeed psi1) phi h_rest

/--
Box formulas are propagated to all families in the seed.

If Box psi is in the input list, then psi appears in all families at time 0.
-/
theorem buildSeedForList_propagates_box (formulas : List Formula) (psi : Formula)
    (h_box_mem : Formula.box psi ∈ formulas) :
    ∀ famIdx ∈ (buildSeedForList formulas).familyIndices,
      psi ∈ (buildSeedForList formulas).getFormulas famIdx 0 := by
  intro famIdx h_fam
  -- Box psi processing adds psi to ALL families at current time
  sorry -- Requires proving box propagation through foldl

end Bimodal.Metalogic.Bundle
