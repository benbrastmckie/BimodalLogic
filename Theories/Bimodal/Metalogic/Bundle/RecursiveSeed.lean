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
  -- If L ⊆ S ∪ {phi} derives bot, we need to show S is inconsistent
  -- But if phi is a theorem, we can replace occurrences of phi with its derivation
  sorry

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
  -- This means {phi, neg psi} is inconsistent
  -- From phi and neg psi = (psi → ⊥), if we derive ⊥, then phi ⊢ psi
  -- By necessitation: Box phi ⊢ Box psi
  -- But Box phi ∈ S and neg(Box psi) ∈ S, so S derives both Box psi and neg(Box psi)
  sorry

/--
Main theorem: if phi is consistent, then buildSeed phi produces a consistent seed.

This is proven by induction on the formula structure.
-/
theorem seedConsistent (phi : Formula) (h_cons : FormulaConsistent phi) :
    SeedConsistent (buildSeed phi) := by
  -- The proof proceeds by induction on the formula complexity
  -- At each step, we maintain the invariant that all seed entries are consistent
  sorry

end Bimodal.Metalogic.Bundle
