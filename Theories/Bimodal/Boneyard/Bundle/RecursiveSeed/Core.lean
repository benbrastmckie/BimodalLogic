import Bimodal.Syntax.Formula
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Propositional
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Set.Finite.Basic

/-!
# RecursiveSeed Core Definitions

Data structures, ModelSeed operations, formula classification, and type definitions
for the recursive seed construction.
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
If a formula is in getFormulas at (f, t), then hasPosition f t is true.
-/
theorem ModelSeed.mem_getFormulas_implies_hasPosition (seed : ModelSeed) (famIdx : Nat) (timeIdx : Int)
    (phi : Formula) (h_mem : phi ∈ seed.getFormulas famIdx timeIdx) :
    seed.hasPosition famIdx timeIdx = true := by
  unfold getFormulas at h_mem
  cases h_find : seed.findEntry famIdx timeIdx with
  | some entry =>
    rw [hasPosition_iff_findEntry_isSome]
    simp only [h_find, Option.isSome_some]
  | none =>
    rw [h_find] at h_mem
    exact absurd h_mem (Set.not_mem_empty phi)

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
If a position exists at (famIdx, t), then t < freshFutureTime famIdx currentTime.
This is because freshFutureTime is max(currentTime, all existing times) + 1.
-/
theorem ModelSeed.hasPosition_time_lt_freshFutureTime (seed : ModelSeed) (famIdx : Nat)
    (t currentTime : Int) (h_pos : seed.hasPosition famIdx t) :
    t < seed.freshFutureTime famIdx currentTime := by
  unfold freshFutureTime hasPosition at *
  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos
  obtain ⟨e, h_mem, h_fam, h_time⟩ := h_pos
  -- e.timeIdx = t and e is in entries with e.familyIdx = famIdx
  have h_in_filtered : e ∈ List.filter (fun e => e.familyIdx == famIdx) seed.entries := by
    rw [List.mem_filter]
    exact ⟨h_mem, by simp [h_fam]⟩
  -- e.timeIdx ≤ max over filtered entries
  have h_le := foldl_max_timeIdx_ge_mem
    (List.filter (fun e => e.familyIdx == famIdx) seed.entries)
    currentTime SeedEntry.timeIdx e h_in_filtered
  -- So t = e.timeIdx ≤ maxTime, hence t < maxTime + 1
  simp only; omega

/--
If a position exists at (famIdx, t), then t > freshPastTime famIdx currentTime.
This is because freshPastTime is min(currentTime, all existing times) - 1.
-/
theorem ModelSeed.hasPosition_time_gt_freshPastTime (seed : ModelSeed) (famIdx : Nat)
    (t currentTime : Int) (h_pos : seed.hasPosition famIdx t) :
    t > seed.freshPastTime famIdx currentTime := by
  unfold freshPastTime hasPosition at *
  simp only [List.any_eq_true, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h_pos
  obtain ⟨e, h_mem, h_fam, h_time⟩ := h_pos
  -- e.timeIdx = t and e is in entries with e.familyIdx = famIdx
  have h_in_filtered : e ∈ List.filter (fun e => e.familyIdx == famIdx) seed.entries := by
    rw [List.mem_filter]
    exact ⟨h_mem, by simp [h_fam]⟩
  -- min over filtered entries ≤ e.timeIdx
  have h_le := foldl_min_timeIdx_le_mem
    (List.filter (fun e => e.familyIdx == famIdx) seed.entries)
    currentTime SeedEntry.timeIdx e h_in_filtered
  -- So minTime ≤ t = e.timeIdx, hence minTime - 1 < t
  simp only; omega

/-- Classification inversion: atomic classification implies atom formula. -/
theorem classifyFormula_eq_atomic (phi : Formula) (s : String)
    (h : classifyFormula phi = FormulaClass.atomic s) : phi = Formula.atom s := by
  cases phi with
  | atom s' => simp only [classifyFormula, FormulaClass.atomic.injEq] at h; exact congrArg Formula.atom h
  | bot => simp only [classifyFormula] at h; contradiction
  | box _ => simp only [classifyFormula] at h; contradiction
  | all_future _ => simp only [classifyFormula] at h; contradiction
  | all_past _ => simp only [classifyFormula] at h; contradiction
  | imp phi1 phi2 =>
    cases phi2 with
    | bot =>
      cases phi1 with
      | box _ => simp only [classifyFormula] at h; contradiction
      | all_future _ => simp only [classifyFormula] at h; contradiction
      | all_past _ => simp only [classifyFormula] at h; contradiction
      | _ => simp only [classifyFormula] at h; contradiction
    | _ => simp only [classifyFormula] at h; contradiction

/-- Classification inversion: bottom classification implies bot formula. -/
theorem classifyFormula_eq_bottom (phi : Formula)
    (h : classifyFormula phi = FormulaClass.bottom) : phi = Formula.bot := by
  cases phi with
  | atom _ => simp only [classifyFormula] at h; contradiction
  | bot => rfl
  | box _ => simp only [classifyFormula] at h; contradiction
  | all_future _ => simp only [classifyFormula] at h; contradiction
  | all_past _ => simp only [classifyFormula] at h; contradiction
  | imp phi1 phi2 =>
    cases phi2 with
    | bot =>
      cases phi1 with
      | box _ => simp only [classifyFormula] at h; contradiction
      | all_future _ => simp only [classifyFormula] at h; contradiction
      | all_past _ => simp only [classifyFormula] at h; contradiction
      | _ => simp only [classifyFormula] at h; contradiction
    | _ => simp only [classifyFormula] at h; contradiction

/-- Classification inversion: implication classification implies imp formula. -/
theorem classifyFormula_eq_implication (phi : Formula) (p1 p2 : Formula)
    (h : classifyFormula phi = FormulaClass.implication p1 p2) :
    phi = Formula.imp p1 p2 := by
  cases phi with
  | atom _ => simp only [classifyFormula] at h; contradiction
  | bot => simp only [classifyFormula] at h; contradiction
  | box _ => simp only [classifyFormula] at h; contradiction
  | all_future _ => simp only [classifyFormula] at h; contradiction
  | all_past _ => simp only [classifyFormula] at h; contradiction
  | imp phi1 phi2 =>
    cases phi2 with
    | bot =>
      cases phi1 with
      | box _ => simp only [classifyFormula] at h; contradiction
      | all_future _ => simp only [classifyFormula] at h; contradiction
      | all_past _ => simp only [classifyFormula] at h; contradiction
      | _ => simp only [classifyFormula] at h; contradiction
    | _ =>
      simp only [classifyFormula, FormulaClass.implication.injEq] at h
      exact congrArg₂ Formula.imp h.1 h.2

/-- Classification inversion: negation classification implies neg formula (phi.imp bot with non-modal phi). -/
theorem classifyFormula_eq_negation (phi inner : Formula)
    (h : classifyFormula phi = FormulaClass.negation inner) :
    phi = Formula.neg inner := by
  cases phi with
  | atom _ => simp only [classifyFormula] at h; contradiction
  | bot => simp only [classifyFormula] at h; contradiction
  | box _ => simp only [classifyFormula] at h; contradiction
  | all_future _ => simp only [classifyFormula] at h; contradiction
  | all_past _ => simp only [classifyFormula] at h; contradiction
  | imp phi1 phi2 =>
    cases phi2 with
    | bot =>
      cases phi1 with
      | box _ => simp only [classifyFormula] at h; contradiction
      | all_future _ => simp only [classifyFormula] at h; contradiction
      | all_past _ => simp only [classifyFormula] at h; contradiction
      | atom s =>
        simp only [classifyFormula, FormulaClass.negation.injEq] at h
        rw [h]; rfl
      | imp a b =>
        simp only [classifyFormula, FormulaClass.negation.injEq] at h
        rw [h]; rfl
      | bot =>
        simp only [classifyFormula, FormulaClass.negation.injEq] at h
        rw [← h]; rfl
    | _ => simp only [classifyFormula] at h; contradiction


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
Modal closure: If Box psi is in the seed at (f, t), then psi is at all families at time t.
-/
def ModalClosed (seed : ModelSeed) : Prop :=
  ∀ f t psi, Formula.box psi ∈ seed.getFormulas f t →
    ∀ f', seed.hasPosition f' t → psi ∈ seed.getFormulas f' t

/--
G-closure: If G psi is in the seed at (f, t), then psi is at all future times in family f.
-/
def GClosed (seed : ModelSeed) : Prop :=
  ∀ f t psi, Formula.all_future psi ∈ seed.getFormulas f t →
    ∀ t' > t, seed.hasPosition f t' → psi ∈ seed.getFormulas f t'

/--
H-closure: If H psi is in the seed at (f, t), then psi is at all past times in family f.
-/
def HClosed (seed : ModelSeed) : Prop :=
  ∀ f t psi, Formula.all_past psi ∈ seed.getFormulas f t →
    ∀ t' < t, seed.hasPosition f t' → psi ∈ seed.getFormulas f t'

/--
Combined closure property for seeds.
-/
def SeedClosed (seed : ModelSeed) : Prop :=
  ModalClosed seed ∧ GClosed seed ∧ HClosed seed

end Bimodal.Metalogic.Bundle
