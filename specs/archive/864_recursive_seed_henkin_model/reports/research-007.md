# Research Report: Task #864

**Task**: Recursive seed construction for Henkin model completeness
**Date**: 2026-02-17
**Focus**: Elegant Worklist-Based Seed Construction Design
**Session**: sess_1771394690_0e5fff

## Executive Summary

This report designs a mathematically elegant worklist algorithm for seed construction that:
1. Fully unpacks ALL nested modal/temporal implications
2. Guarantees cross-sign coherence by construction
3. Has a clean termination proof based on formula complexity
4. Enables simple inductive proofs for the Truth Lemma

The key insight is that the worklist terminates because:
- Formula complexity strictly decreases with each recursion
- Positions grow only finitely (bounded by subformulas and seed construction)
- The lexicographic order (formula complexity, unprocessed positions) is well-founded

## Current Problem Analysis

### Root Cause (from research-006.md)

The current `buildSeedAux` (RecursiveSeed.lean:555-606) has a fundamental gap:

```lean
def buildSeedAux : Formula → Nat → Int → ModelSeed → ModelSeed
  | Formula.all_future psi, famIdx, timeIdx, seed =>
    let seed4 := ... -- adds psi and G psi to future times
    buildSeedAux psi famIdx timeIdx seed4  -- RECURSES ONLY ON psi AT CURRENT POSITION
```

**The Gap**: When `G(H psi)` is processed at time 0:
1. `H psi` is propagated to future times (via `addToAllFutureTimes`)
2. But `buildSeedAux` only recurses on `H psi` at time 0
3. The `H psi` at future times is NEVER processed

**Consequence**: `G(H psi)` at t=0 should imply `psi` at t=0 (via `H psi` at some future time), but this cross-sign coherence is not established by the current construction.

### Current SeedCompletion.lean Technical Debt

| Line | Theorem | Root Cause |
|------|---------|------------|
| 161 | `modal_witness_includes_boxcontent` | BoxContent not processed at witness |
| 246 | `forward_G` (t < 0 case) | G phi propagated but inner not processed |
| 256 | `backward_H` (t >= 0 case) | H phi propagated but inner not processed |
| 328 | `buildFamilyFromSeed_cross_sign_seed` | Same as 246 |
| 372 | `buildFamilyFromSeed_contains_seed` (t!=0) | Seed formulas not connected through chain |

## Worklist Algorithm Design

### Core Data Structures

```lean
/-- A work item represents a formula to be processed at a specific position. -/
structure WorkItem where
  formula : Formula
  famIdx : Nat
  timeIdx : Int
  deriving DecidableEq, BEq, Hashable

/-- Compare work items for equality of position and formula. -/
instance : BEq WorkItem where
  beq w1 w2 := w1.formula == w2.formula &&
               w1.famIdx == w2.famIdx &&
               w1.timeIdx == w2.timeIdx

/-- Extended model seed with processing state. -/
structure WorklistState where
  seed : ModelSeed
  worklist : List WorkItem
  processed : Finset WorkItem
```

### Algorithm Specification

```lean
/-- Process a single work item and return new items to process. -/
def processWorkItem (item : WorkItem) (state : WorklistState) :
    List WorkItem × WorklistState :=
  match classifyFormula item.formula with
  | .atomic s =>
    -- Just add to seed, no new work
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .bottom =>
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .implication phi psi =>
    -- Implications handled by Lindenbaum, just add
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

  | .boxPositive psi =>
    -- Box psi: add Box psi to current, add psi to ALL families
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
    let familyIndices := seed1.familyIndices
    -- Create work items for psi at each family
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
    -- G psi: add G psi and psi to current, add to all future times
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
    -- H psi: add H psi and psi to current, add to all past times
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.all_past psi) .universal_target
    let seed2 := seed1.addFormula item.famIdx item.timeIdx psi .universal_target
    let pastTimes := getPastTimes seed2 item.famIdx item.timeIdx
    -- CRITICAL: Create work items for psi at EACH past time
    let newWork := pastTimes.map (fun t => ⟨psi, item.famIdx, t⟩)
    let seed3 := pastTimes.foldl (fun s t =>
        let s' := s.addFormula item.famIdx t psi .universal_target
        s'.addFormula item.famIdx t (Formula.all_past psi) .universal_target) seed2
    (⟨psi, item.famIdx, item.timeIdx⟩ :: newWork, { state with seed := seed3 })

  | .pastNegative psi =>
    -- neg(H psi): add to current, create fresh past time with neg psi
    let seed1 := state.seed.addFormula item.famIdx item.timeIdx
                   (Formula.neg (Formula.all_past psi)) .universal_target
    let newTime := seed1.freshPastTime item.famIdx item.timeIdx
    let seed2 := seed1.createNewTime item.famIdx newTime (Formula.neg psi)
    let newWork := [⟨Formula.neg psi, item.famIdx, newTime⟩]
    (newWork, { state with seed := seed2 })

  | .negation phi =>
    -- Generic negation: just add
    let seed' := state.seed.addFormula item.famIdx item.timeIdx item.formula .universal_target
    ([], { state with seed := seed' })

/-- Main worklist processor. -/
def processWorklist (state : WorklistState) : ModelSeed :=
  match state.worklist with
  | [] => state.seed
  | item :: rest =>
    if item ∈ state.processed then
      processWorklist { state with worklist := rest }
    else
      let (newWork, state') := processWorkItem item { state with worklist := rest }
      let filteredNew := newWork.filter (fun w => w ∉ state'.processed)
      processWorklist {
        state' with
        worklist := rest ++ filteredNew,
        processed := state'.processed.insert item
      }
termination_by (totalComplexity state.worklist state.processed, state.worklist.length)
```

## Termination Proof Strategy

### Key Insight

The termination measure is a **lexicographic pair**:
1. **Primary**: Sum of complexities of unprocessed formulas
2. **Secondary**: Worklist length (tie-breaker)

### Formal Termination Measure

```lean
/-- Complexity of a work item (formula complexity). -/
def WorkItem.complexity (w : WorkItem) : Nat := w.formula.complexity

/-- Total complexity of pending work. -/
def totalPendingComplexity (worklist : List WorkItem) (processed : Finset WorkItem) : Nat :=
  (worklist.filter (fun w => w ∉ processed)).map WorkItem.complexity |>.sum

/-- The termination measure: lexicographic on (pending complexity, worklist length). -/
def terminationMeasure (state : WorklistState) : Nat × Nat :=
  (totalPendingComplexity state.worklist state.processed, state.worklist.length)
```

### Why Termination Holds

**Key Property**: Every new work item has **strictly smaller formula complexity** than the item being processed.

| Case | Item formula | New work formulas | Complexity relation |
|------|--------------|-------------------|---------------------|
| `Box psi` | `Box psi` | `psi` at each family | `psi.complexity < (Box psi).complexity` |
| `neg(Box psi)` | `neg(Box psi)` | `neg psi` | `(neg psi).complexity < (neg(Box psi)).complexity` |
| `G psi` | `G psi` | `psi` at each future | `psi.complexity < (G psi).complexity` |
| `neg(G psi)` | `neg(G psi)` | `neg psi` | `(neg psi).complexity < (neg(G psi)).complexity` |
| `H psi` | `H psi` | `psi` at each past | `psi.complexity < (H psi).complexity` |
| `neg(H psi)` | `neg(H psi)` | `neg psi` | `(neg psi).complexity < (neg(H psi)).complexity` |

**Formula Complexity Facts** (from Formula.lean):
```lean
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  | all_past φ => 1 + φ.complexity
  | all_future φ => 1 + φ.complexity
```

For `neg phi = imp phi bot`:
- `(neg phi).complexity = 1 + phi.complexity + 1 = phi.complexity + 2`

So:
- `(Box psi).complexity = 1 + psi.complexity`
- `(neg(Box psi)).complexity = 1 + (Box psi).complexity + 1 = psi.complexity + 3`
- `(neg psi).complexity = psi.complexity + 2`

Thus `(neg psi).complexity = psi.complexity + 2 < psi.complexity + 3 = (neg(Box psi)).complexity`.

### Handling Infinite Time Domain

**Question**: Don't G/H cases create infinitely many positions?

**Answer**: No. Positions are only created by:
1. Initial position (1 position)
2. `neg(G psi)` creates 1 fresh future time
3. `neg(H psi)` creates 1 fresh past time
4. `neg(Box psi)` creates 1 new family

**Bound**: The total number of positions created is at most `|subformulas(phi)| + 1`:
- Each witness-creating formula (`neg(G...)`, `neg(H...)`, `neg(Box...)`) can only be processed once per subformula
- There are finitely many subformulas

The G/H cases propagate to **existing** times only, not creating new ones.

### Termination Proof Outline

```lean
theorem processWorklist_terminates (state : WorklistState) :
    ∃ seed, processWorklist state = seed := by
  -- Induction on terminationMeasure
  apply WellFounded.induction (wf := Prod.lex Nat.lt.wf Nat.lt.wf) state
  intro state ih
  cases h_work : state.worklist with
  | nil =>
    -- Base case: empty worklist
    exact ⟨state.seed, rfl⟩
  | cons item rest =>
    -- If item already processed, worklist shrinks
    by_cases h_mem : item ∈ state.processed
    · apply ih; exact ⟨Nat.lt.base _, Or.inl rfl⟩  -- complexity same, length decreases
    · -- Process item
      let (newWork, state') := processWorkItem item { state with worklist := rest }
      -- Key: each w ∈ newWork has w.formula.complexity < item.formula.complexity
      have h_complex : ∀ w ∈ newWork, w.formula.complexity < item.formula.complexity := by
        -- Case analysis on formula classification
        sorry  -- Each case proven from formula complexity
      -- Total pending complexity decreases
      have h_decrease : totalPendingComplexity (rest ++ filteredNew) state'.processed <
                        totalPendingComplexity (item :: rest) state.processed := by
        -- Item is removed (processed), new items have smaller total complexity
        sorry
      apply ih
      exact ⟨h_decrease, Or.inl rfl⟩
```

## Consistency Invariant

### Statement

```lean
/-- The consistency invariant: at each position, formulas are mutually consistent. -/
def WorklistConsistent (state : WorklistState) : Prop :=
  ∀ entry ∈ state.seed.entries, SetConsistent entry.formulas

/-- The seed does not contain both phi and neg phi at any position. -/
def NoContradiction (seed : ModelSeed) : Prop :=
  ∀ famIdx timeIdx phi,
    phi ∈ seed.getFormulas famIdx timeIdx →
    Formula.neg phi ∉ seed.getFormulas famIdx timeIdx
```

### Preservation Proof Sketch

**Key Lemma**: Processing a work item preserves consistency.

```lean
theorem processWorkItem_preserves_consistent (item : WorkItem) (state : WorklistState)
    (h_consistent : WorklistConsistent state) :
    WorklistConsistent (processWorkItem item state).2 := by
  match h_class : classifyFormula item.formula with
  | .boxPositive psi =>
    -- Adding Box psi and psi at existing positions
    -- If Box psi is consistent with seed at (f, t), then psi is also consistent
    -- (by maximality of MCS and T axiom: Box psi → psi)
    sorry
  | .boxNegative psi =>
    -- Creating new family with neg psi
    -- New family has only neg psi; trivially consistent
    sorry
  | .futurePositive psi =>
    -- Adding G psi and psi at existing times
    -- If G psi is consistent at t, then psi is consistent at all future t'
    -- (by T axiom for G: G psi → psi and 4 axiom: G psi → G(G psi))
    sorry
  | .futureNegative psi =>
    -- Creating fresh future time with neg psi
    -- Fresh time has only neg psi; trivially consistent
    sorry
  -- ... other cases similar
```

**Why Consistency is Preserved**:
1. **Witness creation** (neg Box/G/H): Creates fresh positions with single formula
2. **Universal propagation** (Box/G/H): Adds formulas derivable from existing formulas by axioms
3. The initial formula is consistent (by assumption), and derivable formulas preserve consistency

## Closure Properties

### Statement

After worklist processing, the seed satisfies:

```lean
/-- Modal closure: Box psi at (f, t) implies psi at all families f' at time t. -/
def ModalClosed (seed : ModelSeed) : Prop :=
  ∀ famIdx timeIdx psi,
    Formula.box psi ∈ seed.getFormulas famIdx timeIdx →
    ∀ famIdx' ∈ seed.familyIndices,
      seed.hasPosition famIdx' timeIdx = true →
      psi ∈ seed.getFormulas famIdx' timeIdx

/-- Temporal G-closure: G psi at (f, t) implies psi at all future times in seed. -/
def GClosed (seed : ModelSeed) : Prop :=
  ∀ famIdx timeIdx psi,
    Formula.all_future psi ∈ seed.getFormulas famIdx timeIdx →
    ∀ timeIdx' ∈ seed.timeIndices famIdx,
      timeIdx' > timeIdx →
      psi ∈ seed.getFormulas famIdx timeIdx'

/-- Temporal H-closure: H psi at (f, t) implies psi at all past times in seed. -/
def HClosed (seed : ModelSeed) : Prop :=
  ∀ famIdx timeIdx psi,
    Formula.all_past psi ∈ seed.getFormulas famIdx timeIdx →
    ∀ timeIdx' ∈ seed.timeIndices famIdx,
      timeIdx' < timeIdx →
      psi ∈ seed.getFormulas famIdx timeIdx'

/-- Complete closure property. -/
def SeedClosed (seed : ModelSeed) : Prop :=
  ModalClosed seed ∧ GClosed seed ∧ HClosed seed
```

### Proof Strategy

```lean
theorem processWorklist_closed (phi : Formula) (h_cons : Consistent phi) :
    SeedClosed (buildSeedComplete phi) := by
  unfold buildSeedComplete
  -- The worklist processes all propagation requirements
  -- Show: when worklist empties, all closure conditions hold
  constructor
  · -- ModalClosed
    intro famIdx timeIdx psi h_box famIdx' h_fam' h_pos'
    -- Box psi at (famIdx, timeIdx) was placed by some work item
    -- That work item created work items for psi at all families
    -- Those work items were processed (worklist empty)
    sorry
  constructor
  · -- GClosed
    intro famIdx timeIdx psi h_G timeIdx' h_time' h_gt
    -- Similar: G psi created work items for psi at all future times
    sorry
  · -- HClosed
    sorry
```

**Key Insight**: The worklist ensures that every formula added to the seed has its propagation consequences processed. When the worklist empties:
- Every `Box psi` has had `psi` processed at all families
- Every `G psi` has had `psi` processed at all future times in seed
- Every `H psi` has had `psi` processed at all past times in seed

## Cross-Sign Coherence Resolution

### How Worklist Solves Cross-Sign

Consider `G(H psi)` at time 0:

**Current `buildSeedAux` behavior**:
1. Places `H psi` at futures (t=1, 2, ...)
2. Recurses only on `H psi` at t=0
3. **Gap**: `H psi` at t=1 never processed

**Worklist behavior**:
1. Process `G(H psi)` at (0, 0)
2. Add work items: `{H psi, 0, 0}`, `{H psi, 0, 1}`, `{H psi, 0, 2}`, ...
3. Process `{H psi, 0, 1}`:
   - Add `H psi` and `psi` at t=1
   - Add `psi` to all past times including **t=0**
   - Add work items: `{psi, 0, 0}`, `{psi, 0, 1}`
4. Process `{psi, 0, 0}`:
   - Add `psi` at (0, 0)

**Result**: `psi` is explicitly placed at t=0 via processing `H psi` at t=1.

### Cross-Sign Theorem

```lean
theorem buildSeedComplete_cross_sign (phi : Formula) (h_cons : Consistent phi)
    (famIdx : Nat) (t : Int) (psi : Formula) (h_t_neg : t < 0)
    (h_G : Formula.all_future psi ∈ (buildSeedComplete phi).getFormulas famIdx t) :
    ∀ t' > 0, (buildSeedComplete phi).hasPosition famIdx t' = true →
              psi ∈ (buildSeedComplete phi).getFormulas famIdx t' := by
  intro t' h_gt h_pos
  -- G psi at t was processed
  -- Created work item for psi at all future times including t'
  -- That work item was processed since worklist emptied
  exact GClosed_holds_of_processed ...
```

## Connection to Existing Infrastructure

### ModelSeed Reuse

The worklist algorithm reuses the existing `ModelSeed` structure:
- `SeedEntry`, `SeedEntryType` unchanged
- `addFormula`, `addToAllFamilies`, etc. unchanged
- Only the **driver** (`buildSeedAux` → `processWorklist`) changes

### Changes Required

1. **Add `WorkItem` structure** (new)
2. **Add `WorklistState` structure** (new)
3. **Add `processWorkItem` function** (new)
4. **Add `processWorklist` function** (new, replaces `buildSeedAux` as driver)
5. **Add `buildSeedComplete` function** (new entry point, replaces `buildSeed`)
6. **Keep** all existing `ModelSeed` operations

### Minimal Diff

```diff
+ structure WorkItem where ...
+ structure WorklistState where ...
+ def processWorkItem : WorkItem → WorklistState → List WorkItem × WorklistState
+ def processWorklist : WorklistState → ModelSeed
+ def buildSeedComplete (phi : Formula) : ModelSeed :=
+   let initialState : WorklistState := {
+     seed := ModelSeed.initial phi,
+     worklist := [⟨phi, 0, 0⟩],
+     processed := ∅
+   }
+   processWorklist initialState

  -- buildSeedAux can be deprecated or kept for comparison
  def buildSeed (phi : Formula) : ModelSeed :=
-   let initialSeed := ModelSeed.initial phi
-   buildSeedAux phi 0 0 initialSeed
+   buildSeedComplete phi
```

## Truth Lemma Connection

### Required Lemmas for Truth Lemma

The Truth Lemma states: `phi ∈ MCS(f, t) ↔ truth_at(M, f, t, phi)`

For this, we need:
1. **Base case (atoms)**: Atoms in MCS ↔ valuation
2. **Inductive case (Box)**: Box phi in MCS ↔ phi in all families
3. **Inductive case (G)**: G phi in MCS ↔ phi at all future times
4. **Inductive case (H)**: H phi in MCS ↔ phi at all past times

### Worklist Closure → Truth Lemma

```lean
theorem seed_to_mcs_box (seed : ModelSeed) (h_closed : ModalClosed seed)
    (h_cons : SeedConsistent seed) (famIdx timeIdx : Nat) (psi : Formula) :
    Formula.box psi ∈ seedFamilyMCS seed h_cons famIdx timeIdx →
    ∀ famIdx', Formula.box psi ∈ seed.getFormulas famIdx timeIdx →
               psi ∈ seedFamilyMCS seed h_cons famIdx' timeIdx := by
  intro h_box famIdx' h_box_seed
  -- By ModalClosed: psi ∈ seed.getFormulas famIdx' timeIdx
  have h_psi_seed := h_closed famIdx timeIdx psi h_box_seed famIdx' ...
  -- By seedFamilyMCS_contains_seed: seed formulas are in MCS
  exact seedFamilyMCS_contains_seed ... h_psi_seed

theorem seed_to_mcs_G (seed : ModelSeed) (h_closed : GClosed seed)
    (h_cons : SeedConsistent seed) (famIdx : Nat) (t t' : Int) (psi : Formula)
    (h_lt : t < t') :
    Formula.all_future psi ∈ seedFamilyMCS seed h_cons famIdx t →
    psi ∈ seedFamilyMCS seed h_cons famIdx t' := by
  intro h_G
  -- Two cases: G psi from seed or from Lindenbaum
  -- If from seed: use GClosed
  -- If from Lindenbaum: use 4-axiom propagation through dovetail chain
  sorry  -- Combines closure property with chain propagation
```

## Implementation Plan

### Phase 1: Data Structures (1 hour)
- Add `WorkItem` structure
- Add `WorklistState` structure
- Add decidable equality instances

### Phase 2: Core Algorithm (2 hours)
- Implement `processWorkItem` for each formula class
- Implement `processWorklist` with termination annotation
- Add `buildSeedComplete` entry point

### Phase 3: Termination Proof (3 hours)
- Prove formula complexity facts
- Prove `processWorkItem_complexity_decreases`
- Complete termination proof for `processWorklist`

### Phase 4: Consistency Proof (2 hours)
- Prove `processWorkItem_preserves_consistent`
- Prove `buildSeedComplete_consistent`

### Phase 5: Closure Proofs (3 hours)
- Prove `ModalClosed`, `GClosed`, `HClosed`
- Prove `SeedClosed` for `buildSeedComplete`

### Phase 6: Truth Lemma Connection (2 hours)
- Prove `seed_to_mcs_*` lemmas
- Connect to existing `buildFamilyFromSeed`
- Resolve SeedCompletion.lean technical debt

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Termination proof complexity | High | Use lexicographic measure on (complexity sum, length) |
| Consistency proof difficulty | Medium | Leverage existing T/4-axiom lemmas |
| Position explosion | Low | Bound by subformula count (proven finite) |
| MCS connection complexity | Medium | Reuse existing Lindenbaum infrastructure |

## Recommendations

### Immediate Actions

1. **Implement Phase 1-2**: Add data structures and core algorithm
2. **Add termination annotation**: Use `termination_by terminationMeasure state`
3. **Stub proofs**: Add sorry placeholders for termination and consistency

### Verification Strategy

Before full proof development:
1. Test on concrete examples (`G(H p)`, `Box(G p)`, etc.)
2. Verify expected formulas appear at expected positions
3. Check no infinite loops occur

### Alternative Approaches

If worklist proves difficult:
- **Fuel-based**: Process with fuel = subformula count, prove fuel suffices
- **Fixpoint**: Define seed as least fixpoint of propagation rules, prove finiteness

## References

- RecursiveSeed.lean:555-606 (current buildSeedAux)
- SeedCompletion.lean (5 sorries to resolve)
- Formula.lean:107-113 (complexity definition)
- Subformulas.lean (subformula closure)
- DovetailingChain.lean (temporal chain construction)
- research-006.md (worklist proposal)

## Appendix: Complete Processing Rules

| Formula at (f, t) | Place at Seed | Create Work Items |
|-------------------|---------------|-------------------|
| `atom p` | `{atom p}` at (f, t) | none |
| `bot` | `{bot}` at (f, t) | none |
| `phi -> psi` | `{phi -> psi}` at (f, t) | none |
| `Box psi` | `{Box psi, psi}` at (f, t), `{psi}` at all (f', t) | `{psi, f', t}` for each f' |
| `neg(Box psi)` | `{neg(Box psi)}` at (f, t), `{neg psi}` at new (f', t) | `{neg psi, f', t}` |
| `G psi` | `{G psi, psi}` at (f, t), `{G psi, psi}` at all future (f, t') | `{psi, f, t'}` for each future t' |
| `neg(G psi)` | `{neg(G psi)}` at (f, t), `{neg psi}` at fresh (f, t') | `{neg psi, f, t'}` |
| `H psi` | `{H psi, psi}` at (f, t), `{H psi, psi}` at all past (f, t') | `{psi, f, t'}` for each past t' |
| `neg(H psi)` | `{neg(H psi)}` at (f, t), `{neg psi}` at fresh (f, t') | `{neg psi, f, t'}` |
| `neg phi` (other) | `{neg phi}` at (f, t) | none |

## Next Steps

1. Create implementation plan based on this design
2. Implement worklist algorithm in RecursiveSeed.lean
3. Prove termination using formula complexity
4. Prove consistency preservation
5. Prove closure properties
6. Connect to SeedCompletion.lean to resolve technical debt
