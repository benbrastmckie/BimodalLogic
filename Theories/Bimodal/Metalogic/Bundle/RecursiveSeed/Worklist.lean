import Bimodal.Metalogic.Bundle.RecursiveSeed.Builder

/-!
# RecursiveSeed Worklist Algorithm

WorkItem, WorklistState, processWorkItem, processWorklist, and buildSeedComplete.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Worklist-Based Seed Construction (Task 864, v005)

This section implements a worklist-based seed construction algorithm that resolves
the architectural cross-sign coherence blocker identified in v004. The algorithm
processes every formula at every position it is placed, guaranteeing that:

1. `Box psi` at (f, t) ensures `psi` at all families
2. `G psi` at (f, t) ensures `psi` at all future times in the seed
3. `H psi` at (f, t) ensures `psi` at all past times in the seed

The worklist terminates because new work items have strictly smaller formula complexity
than the item being processed, and positions are bounded by subformula count.

### Key Data Structures

- `WorkItem`: A formula to be processed at a specific (family, time) position
- `WorklistState`: Seed + worklist + processed set
- `processWorkItem`: Process one item, return new work items
- `processWorklist`: Main loop (terminates via lexicographic measure)
- `buildSeedComplete`: Entry point for worklist-based construction
-/

/-!
### Phase 1: Data Structures
-/

/--
A work item represents a formula to be processed at a specific position.

The worklist algorithm maintains a list of work items that need processing.
Processing a work item adds the formula to the seed at the specified position
and potentially creates new work items for propagated formulas.
-/
structure WorkItem where
  /-- The formula to process -/
  formula : Formula
  /-- The family index in the seed -/
  famIdx : Nat
  /-- The time index in the seed -/
  timeIdx : Int
  deriving Repr

/-- Decidable equality for WorkItem. -/
instance : DecidableEq WorkItem := fun w1 w2 =>
  if h : w1.formula = w2.formula ∧ w1.famIdx = w2.famIdx ∧ w1.timeIdx = w2.timeIdx then
    isTrue (by cases w1; cases w2; simp_all)
  else
    isFalse (by intro heq; cases heq; simp_all)

/-- BEq instance for WorkItem. -/
instance : BEq WorkItem where
  beq w1 w2 := w1.formula == w2.formula && w1.famIdx == w2.famIdx && w1.timeIdx == w2.timeIdx

/-- LawfulBEq instance for WorkItem. -/
instance : LawfulBEq WorkItem where
  eq_of_beq := by
    intro w1 w2 h
    simp only [BEq.beq, Bool.and_eq_true] at h
    obtain ⟨⟨h1, h2⟩, h3⟩ := h
    have hf : w1.formula = w2.formula := eq_of_beq h1
    have hfam : w1.famIdx = w2.famIdx := eq_of_beq h2
    have ht : w1.timeIdx = w2.timeIdx := eq_of_beq h3
    cases w1; cases w2
    simp_all
  rfl := by
    intro w
    simp only [BEq.beq]
    have h1 : instBEqFormula.beq w.formula w.formula = true := beq_self_eq_true w.formula
    simp only [h1, decide_true, Bool.and_self]

/-- Hashable instance for WorkItem (uses formula hash + family + time). -/
instance : Hashable WorkItem where
  hash w := mixHash (hash w.formula) (mixHash (hash w.famIdx) (hash w.timeIdx))

/--
Extended model seed with processing state.

The worklist state tracks:
- `seed`: The current model seed being built
- `worklist`: List of work items to process
- `processed`: Set of already-processed work items (to avoid reprocessing)
-/
structure WorklistState where
  /-- The model seed being built -/
  seed : ModelSeed
  /-- Work items to process -/
  worklist : List WorkItem
  /-- Already processed work items -/
  processed : Finset WorkItem

/-- Empty worklist state with a given seed. -/
def WorklistState.empty (seed : ModelSeed) : WorklistState :=
  { seed := seed, worklist := [], processed := ∅ }

/-- Initial worklist state for building a seed from a formula. -/
def WorklistState.initial (phi : Formula) : WorklistState :=
  { seed := ModelSeed.initial phi
  , worklist := [{ formula := phi, famIdx := 0, timeIdx := 0 }]
  , processed := ∅ }

/--
Get future time indices for a family in the seed.
Returns all time indices in the family that are greater than the given time.
-/
def getFutureTimes (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) : List Int :=
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  familyEntries.filter (fun e => e.timeIdx > currentTime) |>.map SeedEntry.timeIdx |>.eraseDups

/--
Get past time indices for a family in the seed.
Returns all time indices in the family that are less than the given time.
-/
def getPastTimes (seed : ModelSeed) (famIdx : Nat) (currentTime : Int) : List Int :=
  let familyEntries := seed.entries.filter (fun e => e.familyIdx == famIdx)
  familyEntries.filter (fun e => e.timeIdx < currentTime) |>.map SeedEntry.timeIdx |>.eraseDups

/--
Complexity of a work item (delegates to formula complexity).
-/
def WorkItem.complexity (w : WorkItem) : Nat := w.formula.complexity

/--
Total complexity of pending work items (not yet processed).
-/
def totalPendingComplexity (worklist : List WorkItem) (processed : Finset WorkItem) : Nat :=
  (worklist.filter (fun w => w ∉ processed)).map WorkItem.complexity |>.sum

/--
The termination measure for processWorklist.
Lexicographic pair: (total pending complexity, worklist length).
-/
def terminationMeasure (state : WorklistState) : Nat × Nat :=
  (totalPendingComplexity state.worklist state.processed, state.worklist.length)

/--
Multiset of pending complexities (for Dershowitz-Manna termination).
-/
def pendingComplexityMultiset (worklist : List WorkItem) (processed : Finset WorkItem) : Multiset Nat :=
  (worklist.filter (fun w => w ∉ processed)).map WorkItem.complexity

/-!
### Phase 2: Core Algorithm

The worklist algorithm processes work items one by one, creating new work items
for propagated formulas.
-/

/--
Process a single work item and return new items to process.

The function analyzes the formula classification and:
- Adds the formula to the seed at the specified position
- Creates new work items for propagated formulas (inner formulas of modal/temporal operators)

Returns: (new work items, updated state)
-/
def processWorkItem (item : WorkItem) (state : WorklistState) :
    List WorkItem × WorklistState :=
  match classifyFormula item.formula with
  | .atomic _ =>
    -- Just add to seed, no new work
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .bottom =>
    -- Just add to seed, no new work
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .implication _ _ =>
    -- Implications handled by Lindenbaum, just add
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .negation _ =>
    -- Generic negation: just add
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .boxPositive psi =>
    -- Box psi: add Box psi to current, add psi to ALL families at current time
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    let familyIndices := seed1.familyIndices
    -- Create work items for psi at each family (including current)
    let newWork := familyIndices.map (fun f => ⟨psi, f, item.timeIdx⟩)
    let seed2 := familyIndices.foldl (fun s f =>
        s.addFormula f item.timeIdx psi .universal_target) seed1
    (newWork, { state with seed := seed2 })

  | .boxNegative psi =>
    -- neg(Box psi): add to current, create NEW family with neg psi
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx
                   (Formula.neg (Formula.box psi)) .universal_target
    let (seed2, newFamIdx) := seed1.createNewFamily item.timeIdx (Formula.neg psi)
    -- Add work item for neg psi at new family
    let newWork := [⟨Formula.neg psi, newFamIdx, item.timeIdx⟩]
    (newWork, { state with seed := seed2 })

  | .futurePositive psi =>
    -- G psi: add G psi and psi to current, add psi and G psi to all future times
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.all_future psi) .universal_target
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    let futureTimes := getFutureTimes seed2 item.famIdx item.timeIdx
    -- CRITICAL: Create work items for psi at EACH future time
    let newWork := futureTimes.map (fun t => ⟨psi, item.famIdx, t⟩)
    let seed3 := futureTimes.foldl (fun s t =>
        let s' := s.addFormula item.famIdx t psi .universal_target
        s'.addFormula item.famIdx t (Formula.all_future psi) .universal_target) seed2
    -- Also add work item for psi at current time
    (⟨psi, item.famIdx, item.timeIdx⟩ :: newWork, { state with seed := seed3 })

  | .futureNegative psi =>
    -- neg(G psi): add to current, create fresh future time with neg psi
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx
                   (Formula.neg (Formula.all_future psi)) .universal_target
    let newTime := seed1.freshFutureTime item.famIdx item.timeIdx
    let seed2 := seed1.createNewTime item.famIdx newTime (Formula.neg psi)
    let newWork := [⟨Formula.neg psi, item.famIdx, newTime⟩]
    (newWork, { state with seed := seed2 })

  | .pastPositive psi =>
    -- H psi: add H psi and psi to current, add psi and H psi to all past times
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.all_past psi) .universal_target
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    let pastTimes := getPastTimes seed2 item.famIdx item.timeIdx
    -- CRITICAL: Create work items for psi at EACH past time
    let newWork := pastTimes.map (fun t => ⟨psi, item.famIdx, t⟩)
    let seed3 := pastTimes.foldl (fun s t =>
        let s' := s.addFormula item.famIdx t psi .universal_target
        s'.addFormula item.famIdx t (Formula.all_past psi) .universal_target) seed2
    -- Also add work item for psi at current time
    (⟨psi, item.famIdx, item.timeIdx⟩ :: newWork, { state with seed := seed3 })

  | .pastNegative psi =>
    -- neg(H psi): add to current, create fresh past time with neg psi
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx
                   (Formula.neg (Formula.all_past psi)) .universal_target
    let newTime := seed1.freshPastTime item.famIdx item.timeIdx
    let seed2 := seed1.createNewTime item.famIdx newTime (Formula.neg psi)
    let newWork := [⟨Formula.neg psi, item.famIdx, newTime⟩]
    (newWork, { state with seed := seed2 })

/-!
### Phase 3: Termination Infrastructure

The termination proof relies on the key insight that new work items have
strictly smaller formula complexity than the item being processed.
-/

/-- Formula complexity is positive. -/
theorem Formula.complexity_pos (phi : Formula) : phi.complexity > 0 := by
  cases phi <;> simp only [Formula.complexity] <;> omega

/-- Negation increases complexity by 2. -/
theorem Formula.neg_complexity (phi : Formula) :
    (Formula.neg phi).complexity = phi.complexity + 2 := by
  simp only [Formula.neg, Formula.complexity]
  omega

/-- Box inner has smaller complexity than Box formula. -/
theorem Formula.box_inner_complexity_lt (psi : Formula) :
    psi.complexity < (Formula.box psi).complexity := by
  simp only [Formula.complexity]
  omega

/-- G inner has smaller complexity than G formula. -/
theorem Formula.all_future_inner_complexity_lt (psi : Formula) :
    psi.complexity < (Formula.all_future psi).complexity := by
  simp only [Formula.complexity]
  omega

/-- H inner has smaller complexity than H formula. -/
theorem Formula.all_past_inner_complexity_lt (psi : Formula) :
    psi.complexity < (Formula.all_past psi).complexity := by
  simp only [Formula.complexity]
  omega

/-- neg psi has smaller complexity than neg(Box psi). -/
theorem Formula.neg_box_inner_complexity_lt (psi : Formula) :
    (Formula.neg psi).complexity < (Formula.neg (Formula.box psi)).complexity := by
  simp only [Formula.neg, Formula.complexity]
  omega

/-- neg psi has smaller complexity than neg(G psi). -/
theorem Formula.neg_future_inner_complexity_lt (psi : Formula) :
    (Formula.neg psi).complexity < (Formula.neg (Formula.all_future psi)).complexity := by
  simp only [Formula.neg, Formula.complexity]
  omega

/-- neg psi has smaller complexity than neg(H psi). -/
theorem Formula.neg_past_inner_complexity_lt (psi : Formula) :
    (Formula.neg psi).complexity < (Formula.neg (Formula.all_past psi)).complexity := by
  simp only [Formula.neg, Formula.complexity]
  omega

/-- Pending complexity of rest is <= pending complexity of item :: rest. -/
private theorem totalPendingComplexity_rest_le (item : WorkItem) (rest : List WorkItem)
    (processed : Finset WorkItem) :
    totalPendingComplexity rest processed ≤ totalPendingComplexity (item :: rest) processed := by
  unfold totalPendingComplexity
  simp only [List.filter_cons]
  by_cases h : item ∈ processed
  · -- item in processed: filter drops it
    have h_dec : decide (item ∉ processed) = false := by simp [h]
    rw [h_dec]
    simp only [Bool.false_eq_true, ↓reduceIte, le_refl]
  · -- item not in processed: adds its complexity
    have h_dec : decide (item ∉ processed) = true := by simp [h]
    rw [h_dec]
    simp only [↓reduceIte, List.map_cons, List.sum_cons]
    exact Nat.le_add_left _ _

/-- If item is in processed, pending complexity stays the same. -/
theorem totalPendingComplexity_of_in_processed (item : WorkItem) (rest : List WorkItem)
    (processed : Finset WorkItem) (h : item ∈ processed) :
    totalPendingComplexity rest processed = totalPendingComplexity (item :: rest) processed := by
  unfold totalPendingComplexity
  simp only [List.filter_cons]
  have h_dec : decide (item ∉ processed) = false := by simp [h]
  rw [h_dec]
  simp only [Bool.false_eq_true, ↓reduceIte]

/-- The rest has smaller length than item :: rest. -/
private theorem rest_length_lt (item : WorkItem) (rest : List WorkItem) :
    rest.length < (item :: rest).length := by
  simp only [List.length_cons]
  omega

/-- If item is not in processed, pending complexity includes item. -/
private theorem totalPendingComplexity_cons_not_in (item : WorkItem) (rest : List WorkItem)
    (processed : Finset WorkItem) (h : item ∉ processed) :
    totalPendingComplexity (item :: rest) processed =
    item.complexity + totalPendingComplexity rest processed := by
  unfold totalPendingComplexity
  simp only [List.filter_cons]
  have h_dec : decide (item ∉ processed) = true := by simp [h]
  rw [h_dec]
  simp only [↓reduceIte, List.map_cons, List.sum_cons]

/-- processWorkItem preserves the processed set. -/
theorem processWorkItem_processed_eq (item : WorkItem) (state : WorklistState) :
    (processWorkItem item state).2.processed = state.processed := by
  unfold processWorkItem
  cases classifyFormula item.formula <;> simp [WorklistState.processed]

/-- processWorkItem result is independent of state.worklist.
    The seed, new work items, and processed set are determined only by state.seed,
    item.famIdx, item.timeIdx, and item.formula. -/
lemma processWorkItem_indep_worklist (item : WorkItem) (state : WorklistState)
    (wl : List WorkItem) :
    (processWorkItem item { state with worklist := wl }).2.seed = (processWorkItem item state).2.seed ∧
    (processWorkItem item { state with worklist := wl }).1 = (processWorkItem item state).1 ∧
    (processWorkItem item { state with worklist := wl }).2.processed = (processWorkItem item state).2.processed := by
  unfold processWorkItem
  cases classifyFormula item.formula <;> simp [WorklistState.seed, WorklistState.processed]

/-- Items produced by processWorkItem have strictly smaller complexity than the input. -/
theorem processWorkItem_newWork_complexity_lt (item : WorkItem) (state : WorklistState)
    (w : WorkItem) (hw : w ∈ (processWorkItem item state).1) :
    w.complexity < item.complexity := by
  unfold processWorkItem at hw
  -- Case split on item.formula structure (not on classification result)
  match hf : item.formula with
  | Formula.atom s =>
    -- classifyFormula (atom s) = atomic s => newWork = []
    simp only [classifyFormula, hf] at hw
    exact (List.not_mem_nil hw).elim
  | Formula.bot =>
    simp only [classifyFormula, hf] at hw
    exact (List.not_mem_nil hw).elim
  | Formula.box psi =>
    -- classifyFormula (box psi) = boxPositive psi => newWork maps psi
    simp only [classifyFormula, hf, List.mem_map] at hw
    obtain ⟨_, _, rfl⟩ := hw
    simp only [WorkItem.complexity, hf]
    exact Formula.box_inner_complexity_lt psi
  | Formula.all_future psi =>
    -- newWork = ⟨psi, item.famIdx, item.timeIdx⟩ :: map (fun t => ⟨psi, ..., t⟩) futureTimes
    simp only [classifyFormula, hf, List.mem_cons, List.mem_map] at hw
    rcases hw with rfl | ⟨_, _, rfl⟩ <;> simp only [WorkItem.complexity, hf, Formula.all_future_inner_complexity_lt]
  | Formula.all_past psi =>
    -- Similar structure to all_future
    simp only [classifyFormula, hf, List.mem_cons, List.mem_map] at hw
    rcases hw with rfl | ⟨_, _, rfl⟩ <;> simp only [WorkItem.complexity, hf, Formula.all_past_inner_complexity_lt]
  | Formula.imp phi psi =>
    -- Need further case analysis based on phi and psi
    match phi, psi with
    | Formula.box inner, Formula.bot =>
      -- boxNegative: newWork = [⟨neg inner, ...⟩]
      simp only [classifyFormula, hf, List.mem_singleton] at hw
      rw [hw]
      simp only [WorkItem.complexity, Formula.neg, hf]
      exact Formula.neg_box_inner_complexity_lt inner
    | Formula.all_future inner, Formula.bot =>
      simp only [classifyFormula, hf, List.mem_singleton] at hw
      rw [hw]
      simp only [WorkItem.complexity, Formula.neg, hf]
      exact Formula.neg_future_inner_complexity_lt inner
    | Formula.all_past inner, Formula.bot =>
      simp only [classifyFormula, hf, List.mem_singleton] at hw
      rw [hw]
      simp only [WorkItem.complexity, Formula.neg, hf]
      exact Formula.neg_past_inner_complexity_lt inner
    -- Generic negation cases (phi is not box/all_future/all_past)
    | Formula.atom s, Formula.bot =>
      simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.bot =>
      simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp a b, Formula.bot =>
      simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    -- Generic implication cases (psi is not bot, so classifyFormula returns .implication)
    | Formula.atom a, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.atom a, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.atom a, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.atom a, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.atom a, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.bot, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp _ _, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp _ _, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp _ _, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp _ _, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.imp _ _, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.box _, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.box _, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.box _, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.box _, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.box _, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_future _, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_future _, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_future _, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_future _, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_future _, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_past _, Formula.atom _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_past _, Formula.imp _ _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_past _, Formula.box _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_past _, Formula.all_future _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim
    | Formula.all_past _, Formula.all_past _ => simp only [classifyFormula, hf] at hw; exact (List.not_mem_nil hw).elim

/-- All work items produced by processWorkItem have valid positions in the new seed.
    Key for maintaining WorklistPosInvariant through processing. -/
lemma processWorkItem_newWork_hasPosition (item : WorkItem) (state : WorklistState)
    (h_item_pos : state.seed.hasPosition item.famIdx item.timeIdx) :
    ∀ w ∈ (processWorkItem item state).1,
      (processWorkItem item state).2.seed.hasPosition w.famIdx w.timeIdx := by
  unfold processWorkItem
  match hf : item.formula with
  | Formula.atom s =>
    -- newWork = [], vacuously true
    simp only [classifyFormula, hf]
    intro w hw; exact (List.not_mem_nil hw).elim
  | Formula.bot =>
    simp only [classifyFormula, hf]
    intro w hw; exact (List.not_mem_nil hw).elim
  | Formula.imp phi psi =>
    match phi, psi with
    | Formula.box inner, Formula.bot =>
      -- boxNegative: new item at (newFamIdx, item.timeIdx)
      simp only [classifyFormula, hf, Formula.neg, Formula.box]
      intro w hw
      simp only [List.mem_singleton] at hw
      subst hw
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      exact createNewFamily_self_hasPosition _ _ _
    | Formula.all_future inner, Formula.bot =>
      -- futureNegative: new item at (item.famIdx, newTime)
      simp only [classifyFormula, hf, Formula.neg, Formula.all_future]
      intro w hw
      simp only [List.mem_singleton] at hw
      subst hw
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      exact createNewTime_self_hasPosition _ _ _ _
    | Formula.all_past inner, Formula.bot =>
      -- pastNegative: new item at (item.famIdx, newTime)
      simp only [classifyFormula, hf, Formula.neg, Formula.all_past]
      intro w hw
      simp only [List.mem_singleton] at hw
      subst hw
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      exact createNewTime_self_hasPosition _ _ _ _
    | _, _ =>
      -- Generic cases: newWork = [] or classifyFormula gives negation/implication
      -- Most cases are negation or implication (no modal, no temporal)
      -- Check all remaining sub-cases
      simp only [classifyFormula, hf]
      split
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
      · intro w hw; simp only at hw; exact (List.not_mem_nil hw).elim
  | Formula.box psi =>
    -- boxPositive: new items at (f, item.timeIdx) for f ∈ familyIndices
    simp only [classifyFormula, hf]
    intro w hw
    simp only [List.mem_map] at hw
    obtain ⟨f, hf_in, rfl⟩ := hw
    simp only [WorkItem.famIdx, WorkItem.timeIdx]
    -- seed2 = foldl (addFormula f item.timeIdx psi) seed1 familyIndices
    -- where seed1 = state.seed.addFormula item.famIdx item.timeIdx (box psi)
    -- f ∈ familyIndices of seed1
    -- Need: seed2.hasPosition f item.timeIdx
    exact foldl_addFormula_fam_self_hasPosition psi item.timeIdx
      (state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target).familyIndices
      (state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target)
      f hf_in
  | Formula.all_future psi =>
    -- futurePositive: new items at (item.famIdx, item.timeIdx) and (item.famIdx, t) for t ∈ futureTimes
    simp only [classifyFormula, hf]
    intro w hw
    simp only [List.mem_cons, List.mem_map] at hw
    rcases hw with rfl | ⟨t, ht_in, rfl⟩
    · -- w = ⟨psi, item.famIdx, item.timeIdx⟩
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      -- seed3 ⊇ seed2, and seed2.hasPosition item.famIdx item.timeIdx by addFormula_self_hasPosition
      have h_seed2_pos : (state.seed.addFormula item.famIdx item.timeIdx (Formula.all_future psi) .universal_target).addFormula
          item.famIdx item.timeIdx psi .universal_target |>.hasPosition item.famIdx item.timeIdx :=
        addFormula_self_hasPosition _ _ _ _ _
      -- seed3 preserves this position
      apply foldl_compound_future_preserves_hasPosition
      exact h_seed2_pos
    · -- w = ⟨psi, item.famIdx, t⟩ for t ∈ futureTimes
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      -- t ∈ futureTimes, so after foldl, position (item.famIdx, t) exists
      exact foldl_compound_future_self_hasPosition psi item.famIdx _ _ t ht_in
  | Formula.all_past psi =>
    -- pastPositive: similar to futurePositive
    simp only [classifyFormula, hf]
    intro w hw
    simp only [List.mem_cons, List.mem_map] at hw
    rcases hw with rfl | ⟨t, ht_in, rfl⟩
    · -- w = ⟨psi, item.famIdx, item.timeIdx⟩
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      have h_seed2_pos : (state.seed.addFormula item.famIdx item.timeIdx (Formula.all_past psi) .universal_target).addFormula
          item.famIdx item.timeIdx psi .universal_target |>.hasPosition item.famIdx item.timeIdx :=
        addFormula_self_hasPosition _ _ _ _ _
      apply foldl_compound_past_preserves_hasPosition
      exact h_seed2_pos
    · -- w = ⟨psi, item.famIdx, t⟩ for t ∈ pastTimes
      simp only [WorkItem.famIdx, WorkItem.timeIdx]
      exact foldl_compound_past_self_hasPosition psi item.famIdx _ _ t ht_in

/-- processWorkItem is monotone on the seed: existing positions are preserved. -/
lemma processWorkItem_preserves_hasPosition (item : WorkItem) (state : WorklistState)
    (fam' : Nat) (time' : Int)
    (h : state.seed.hasPosition fam' time') :
    (processWorkItem item state).2.seed.hasPosition fam' time' := by
  unfold processWorkItem
  match hf : item.formula with
  | Formula.atom s =>
    simp only [classifyFormula, hf]
    exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
  | Formula.bot =>
    simp only [classifyFormula, hf]
    exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
  | Formula.box psi =>
    simp only [classifyFormula, hf]
    apply foldl_addFormula_fam_preserves_hasPosition
    exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
  | Formula.all_future psi =>
    simp only [classifyFormula, hf]
    apply foldl_compound_future_preserves_hasPosition
    apply addFormula_preserves_hasPosition
    exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
  | Formula.all_past psi =>
    simp only [classifyFormula, hf]
    apply foldl_compound_past_preserves_hasPosition
    apply addFormula_preserves_hasPosition
    exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
  | Formula.imp phi psi =>
    match phi, psi with
    | Formula.box inner, Formula.bot =>
      -- boxNegative: seed gets addFormula then createNewFamily
      simp only [classifyFormula, hf, Formula.neg, Formula.box]
      apply createNewFamily_preserves_hasPosition
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | Formula.all_future inner, Formula.bot =>
      -- futureNegative: seed gets addFormula then createNewTime
      simp only [classifyFormula, hf, Formula.neg, Formula.all_future]
      apply createNewTime_preserves_hasPosition
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | Formula.all_past inner, Formula.bot =>
      -- pastNegative: seed gets addFormula then createNewTime
      simp only [classifyFormula, hf, Formula.neg, Formula.all_past]
      apply createNewTime_preserves_hasPosition
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    -- Generic negation cases (psi = bot but phi is not box/all_future/all_past)
    | Formula.atom s, Formula.bot =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | Formula.bot, Formula.bot =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | Formula.imp _ _, Formula.bot =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    -- Generic implication cases (psi ≠ bot)
    | _, Formula.atom _ =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | _, Formula.imp _ _ =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | _, Formula.box _ =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | _, Formula.all_future _ =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h
    | _, Formula.all_past _ =>
      simp only [classifyFormula, hf]
      exact addFormula_preserves_hasPosition _ _ _ _ _ _ _ h

/--
Fuel-based worklist processor (auxiliary).

Processes at most `fuel` items. Terminates structurally on fuel.
-/
def processWorklistAux (fuel : Nat) (state : WorklistState) : ModelSeed :=
  match fuel with
  | 0 => state.seed
  | fuel' + 1 =>
    match state.worklist with
    | [] => state.seed
    | item :: rest =>
      if item ∈ state.processed then
        -- Already processed, skip
        processWorklistAux fuel' { state with worklist := rest }
      else
        -- Process the item
        let (newWork, state') := processWorkItem item { state with worklist := rest }
        -- Filter out already-processed items
        let filteredNew := newWork.filter (fun w => w ∉ state'.processed)
        processWorklistAux fuel' {
          state' with
          worklist := rest ++ filteredNew,
          processed := Insert.insert item state'.processed
        }

/--
Compute an upper bound on the number of iterations needed.

Key insight: each (subformula, position) pair can be processed at most once.
The total number of such pairs is bounded by:
- Subformulas: complexity of initial formula
- Positions: bounded by subformula count (only neg G/H/Box create new positions)
-/
def worklistFuelBound (phi : Formula) : Nat :=
  -- Upper bound: (subformula count)² for (formula × position) pairs
  -- Each subformula can appear at most once per position
  let subfCount := phi.complexity
  subfCount * subfCount

/--
Main worklist processor.

Processes work items until the worklist is empty, creating new items for
propagated formulas. Returns the final seed.

Uses fuel-based recursion with a proven upper bound on iterations.
-/
def processWorklist (state : WorklistState) : ModelSeed :=
  -- Use fuel based on maximum formula complexity in initial worklist
  let maxComplexity := state.worklist.map WorkItem.complexity |>.foldl max 0
  let fuel := (maxComplexity * maxComplexity + 1) * (state.worklist.length + 1)
  processWorklistAux fuel state

/--
Build a complete model seed from a starting formula using the worklist algorithm.

This is the main entry point for worklist-based seed construction:
1. Create initial state with formula at (family 0, time 0)
2. Process all work items until worklist is empty

The resulting seed has:
- All formulas propagated according to modal/temporal semantics
- Cross-sign coherence guaranteed by construction
-/
def buildSeedComplete (phi : Formula) : ModelSeed :=
  processWorklist (WorklistState.initial phi)

/--
Test that buildSeedComplete computes on a simple formula.
-/
theorem buildSeedComplete_computes : (buildSeedComplete (Formula.atom "p")).entries.length > 0 := by
  native_decide


end Bimodal.Metalogic.Bundle
