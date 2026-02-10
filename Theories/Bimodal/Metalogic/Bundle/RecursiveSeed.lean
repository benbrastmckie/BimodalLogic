import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
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
  intro h_in
  -- The proof is by structural induction on phi, using equation lemmas
  -- Key insight: buildSeedAux only adds entries to seed.entries, never removes them.
  induction phi using Formula.rec generalizing famIdx timeIdx seed with
  | atom s =>
    simp only [buildSeedAux]
    exact addFormula_preserves_familyIndices' seed famIdx timeIdx (.atom s) .universal_target idx h_in
  | bot =>
    simp only [buildSeedAux]
    exact addFormula_preserves_familyIndices' seed famIdx timeIdx .bot .universal_target idx h_in
  | box psi ih =>
    simp only [buildSeedAux]
    have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.box psi) .universal_target idx h_in
    have h2 := addToAllFamilies_preserves_familyIndices' _ timeIdx psi idx h1
    exact ih famIdx timeIdx _ h2
  | all_future psi ih =>
    simp only [buildSeedAux]
    have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.all_future psi) .universal_target idx h_in
    have h2 := addFormula_preserves_familyIndices' _ famIdx timeIdx psi .universal_target idx h1
    have h3 := addToAllFutureTimes_preserves_familyIndices' _ famIdx timeIdx psi idx h2
    exact ih famIdx timeIdx _ h3
  | all_past psi ih =>
    simp only [buildSeedAux]
    have h1 := addFormula_preserves_familyIndices' seed famIdx timeIdx (.all_past psi) .universal_target idx h_in
    have h2 := addFormula_preserves_familyIndices' _ famIdx timeIdx psi .universal_target idx h1
    have h3 := addToAllPastTimes_preserves_familyIndices' _ famIdx timeIdx psi idx h2
    exact ih famIdx timeIdx _ h3
  | imp psi1 psi2 _ih1 _ih2 =>
    -- The imp case requires careful handling of special patterns
    -- buildSeedAux has special matching for: imp (box _) bot, imp (all_future _) bot, imp (all_past _) bot
    -- Due to dependent matching complexity, we use sorry for now.
    -- The proof follows the same structure: each case adds entries, never removes.
    sorry

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
-/
def SeedWellFormed (seed : ModelSeed) : Prop :=
  -- All family indices are valid
  (∀ entry ∈ seed.entries, entry.familyIdx < seed.nextFamilyIdx) ∧
  -- Entries at different positions in the list with same (family, time) are merged
  (∀ ei ∈ seed.entries, ∀ ej ∈ seed.entries, ei ≠ ej →
    ¬(ei.familyIdx = ej.familyIdx ∧ ei.timeIdx = ej.timeIdx))

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

theorem seedConsistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeed phi) := by
  -- The proof proceeds by induction on the formula complexity
  -- At each step, we maintain the invariant that all seed entries are consistent
  -- This requires proving that buildSeedAux preserves consistency
  --
  -- Key lemmas used:
  -- - initialSeedConsistent: {phi} consistent when phi consistent
  -- - addFormula_preserves_consistent_of_theorem: adding theorems preserves consistency
  -- - diamond_box_interaction: witness families are consistent
  --
  -- The full proof requires tracking the invariant through buildSeedAux
  -- which is left as future work
  sorry

end Bimodal.Metalogic.Bundle
