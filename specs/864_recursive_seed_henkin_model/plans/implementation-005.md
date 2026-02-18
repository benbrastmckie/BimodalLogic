# Implementation Plan: Recursive Seed Henkin Model Construction (v5 - Worklist Algorithm)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [NOT STARTED]
- **Effort**: 13 hours
- **Dependencies**: None (supersedes implementation-004.md approach)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-007.md (worklist algorithm design)
  - specs/864_recursive_seed_henkin_model/reports/research-006.md (worklist proposal)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v004 -> v005)

Based on research-007.md proposing a fundamentally different worklist-based approach:

| Aspect | v004 | v005 Changes |
|--------|------|--------------|
| Core algorithm | `buildSeedAux` (recursion on inner formula only) | **Worklist algorithm** (processes ALL propagated formulas) |
| Architectural blocker | 5 sorries in SeedCompletion.lean due to cross-sign coherence | **RESOLVED BY DESIGN**: worklist guarantees cross-sign coherence |
| Termination | Structural recursion on formula | **Lexicographic measure** (complexity sum, worklist length) |
| Closure properties | Not achieved | **Guaranteed**: ModalClosed, GClosed, HClosed |
| Phase structure | 6 phases continuing from prior work | **Fresh 6 phases** implementing new algorithm |

**Key insight from research-007.md**: The current `buildSeedAux` only recurses on the inner formula AT THE CURRENT POSITION. When `G(H psi)` is processed at time 0, `H psi` is propagated to future times but never processed there. The worklist approach processes ALL propagated formulas, guaranteeing cross-sign coherence by construction.

## Overview

This plan implements a worklist-based seed construction algorithm that resolves the architectural cross-sign coherence blocker identified in v004. The algorithm processes every formula at every position it is placed, guaranteeing that:

1. `Box psi` at (f, t) ensures `psi` at all families
2. `G psi` at (f, t) ensures `psi` at all future times in the seed
3. `H psi` at (f, t) ensures `psi` at all past times in the seed

The worklist terminates because new work items have strictly smaller formula complexity than the item being processed, and positions are bounded by subformula count.

### Research Integration

From research-007.md:
- **WorkItem and WorklistState structures** - Defined with DecidableEq, BEq, Hashable
- **processWorkItem function** - 10 formula classification cases with work item generation
- **processWorklist function** - Main loop with termination annotation
- **Termination measure** - Lexicographic (totalPendingComplexity, worklist.length)
- **Closure properties** - ModalClosed, GClosed, HClosed definitions and proof strategies

## Goals & Non-Goals

**Goals**:
- Implement worklist-based seed construction replacing `buildSeedAux`
- Prove termination using formula complexity measure
- Prove consistency preservation through worklist processing
- Prove closure properties (ModalClosed, GClosed, HClosed)
- Resolve the 5 sorries in SeedCompletion.lean via closure properties
- Connect to existing Completeness.lean via `buildSeedBMCS`

**Non-Goals**:
- Modifying the existing `buildSeedAux` (will be deprecated, not removed)
- Changing the existing `ModelSeed` data structure
- Modifying Completeness.lean directly (connection via bridge theorem)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof complexity | High | Medium | Use established lexicographic measure pattern from research-007.md |
| Consistency proof difficulty | Medium | Medium | Leverage existing T/4-axiom lemmas in codebase |
| WorkItem proliferation | Low | Low | Positions bounded by subformula count (proven finite) |
| Integration with existing code | Medium | Low | Reuse all existing ModelSeed operations |
| GClosed/HClosed for dynamically created positions | Medium | Medium | New positions from neg(G/H) only get neg formula; propagation covers new witnesses |

## Sorry Characterization

### Pre-existing Sorries

**SeedCompletion.lean** (5 sorries):
- Line 161: `modal_witness_includes_boxcontent` - Box propagation to modal witness
- Line 246: `forward_G` (t < 0 case) - Cross-sign G propagation
- Line 256: `backward_H` (t >= 0 case) - Cross-sign H propagation
- Line 328: `buildFamilyFromSeed_cross_sign_seed` - Cross-sign seed formula
- Line 372: `buildFamilyFromSeed_contains_seed` (t!=0) - Seed containment at non-zero times

**RecursiveSeed.lean** (3 non-critical sorries in buildSeedForList - not on main path)

### Expected Resolution

- **Phase 5** resolves lines 246, 256, 328 via GClosed/HClosed closure properties
- **Phase 6** resolves lines 161, 372 by connecting closure to seed containment
- The worklist algorithm guarantees these properties by construction

### New Sorries

- None expected in core algorithm. Proof stub sorries may be used temporarily during Phase 3 (termination proof) but must be resolved before Phase 3 completion.

### Remaining Debt

After this implementation:
- 0 sorries expected in SeedCompletion.lean
- 3 non-critical sorries remain in RecursiveSeed.lean (buildSeedForList helper - not on critical path)
- Completeness theorem becomes sorry-free on main path

## Implementation Phases

### Phase 1: Data Structures [NOT STARTED]

- **Dependencies:** None
- **Goal:** Add WorkItem, WorklistState structures and helper types to RecursiveSeed.lean

**Tasks**:
- [ ] Define `WorkItem` structure with formula, famIdx, timeIdx fields
- [ ] Add `DecidableEq`, `BEq`, `Hashable` instances for WorkItem
- [ ] Define `WorklistState` structure with seed, worklist, processed fields
- [ ] Define `FormulaClass` inductive for formula classification
- [ ] Implement `classifyFormula : Formula -> FormulaClass` function
- [ ] Add helper functions: `getFutureTimes`, `getPastTimes` for seed queries
- [ ] Verify all definitions compile

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add new definitions at end of file

**Verification:**
- `lake build` succeeds
- All new definitions have correct types

---

### Phase 2: Core Algorithm [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Implement processWorkItem and processWorklist functions

**Tasks**:
- [ ] Implement `processWorkItem` with all 10 formula classification cases:
  - `.atomic` - Add to seed, no new work
  - `.bottom` - Add to seed, no new work
  - `.implication` - Add to seed, no new work (Lindenbaum handles)
  - `.boxPositive` - Add Box and psi to all families, create work items
  - `.boxNegative` - Create new family with neg psi, create work item
  - `.futurePositive` - Add G and psi to future times, create work items
  - `.futureNegative` - Create fresh future time with neg psi
  - `.pastPositive` - Add H and psi to past times, create work items
  - `.pastNegative` - Create fresh past time with neg psi
  - `.negation` - Add to seed, no new work
- [ ] Implement `processWorklist` main loop (initially with `sorry` for termination)
- [ ] Implement `buildSeedComplete : Formula -> ModelSeed` entry point
- [ ] Add test theorem: `buildSeedComplete_computes` (verify it evaluates on simple formula)

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add functions after data structures

**Verification:**
- `lake build` succeeds (with termination sorry)
- `#check buildSeedComplete` shows correct type
- `#reduce buildSeedComplete (Formula.atom "p")` produces non-empty seed

---

### Phase 3: Termination Proof [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove processWorklist terminates using lexicographic measure

**Tasks**:
- [ ] Define `WorkItem.complexity : WorkItem -> Nat` (delegates to Formula.complexity)
- [ ] Define `totalPendingComplexity : List WorkItem -> Finset WorkItem -> Nat`
- [ ] Define `terminationMeasure : WorklistState -> Nat x Nat`
- [ ] Prove `processWorkItem_complexity_decreases`:
  - For each formula class, new work items have strictly smaller complexity
- [ ] Prove `complexity_facts` for formula constructors:
  - `(Box psi).complexity = 1 + psi.complexity`
  - `(neg phi).complexity = phi.complexity + 2`
  - `(G psi).complexity = 1 + psi.complexity`
  - etc.
- [ ] Replace termination sorry with `termination_by terminationMeasure state`
- [ ] Prove termination argument (may need `decreasing_by` block)

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add termination infrastructure

**Verification:**
- `lake build` succeeds with NO termination sorries
- `processWorklist` compiles with proven termination
- `#check processWorklist` confirms it is not marked partial/sorry

---

### Phase 4: Consistency Proof [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove worklist processing preserves seed consistency

**Tasks**:
- [ ] Define `WorklistConsistent : WorklistState -> Prop`
- [ ] Define `NoContradiction : ModelSeed -> Prop`
- [ ] Prove `processWorkItem_preserves_consistent`:
  - Boxpositive: If Box psi consistent, psi at all families consistent (T axiom)
  - BoxNegative: New family with single formula trivially consistent
  - FuturePositive: G psi -> psi consistent via 4 axiom
  - FutureNegative: Fresh time with single formula trivially consistent
  - (similarly for past cases)
- [ ] Prove `processWorklist_preserves_consistent` by induction on worklist
- [ ] Prove `buildSeedComplete_consistent : FormulaConsistent phi -> SeedConsistent (buildSeedComplete phi)`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add consistency proofs

**Verification:**
- `lake build` succeeds
- `#check buildSeedComplete_consistent` shows correct type
- No sorries in consistency proof path

---

### Phase 5: Closure Proofs [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove ModalClosed, GClosed, HClosed for buildSeedComplete output

**Tasks**:
- [ ] Define `ModalClosed : ModelSeed -> Prop` (Box psi implies psi at all families)
- [ ] Define `GClosed : ModelSeed -> Prop` (G psi implies psi at all future times)
- [ ] Define `HClosed : ModelSeed -> Prop` (H psi implies psi at all past times)
- [ ] Define `SeedClosed : ModelSeed -> Prop` (conjunction of all three)
- [ ] Prove `processWorklist_modal_closed`:
  - When worklist empties, all Box psi have had psi processed at all families
- [ ] Prove `processWorklist_G_closed`:
  - When worklist empties, all G psi have had psi processed at all future times
- [ ] Prove `processWorklist_H_closed`:
  - When worklist empties, all H psi have had psi processed at all past times
- [ ] Prove `buildSeedComplete_closed : SeedClosed (buildSeedComplete phi)`

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add closure definitions and proofs

**Verification:**
- `lake build` succeeds
- `#check buildSeedComplete_closed` shows correct type
- No sorries in closure proof path

---

### Phase 6: Truth Lemma Connection [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Connect closure properties to SeedCompletion.lean, resolve 5 sorries

**Tasks**:
- [ ] Update SeedCompletion.lean imports to include new RecursiveSeed definitions
- [ ] Replace/refactor `buildFamilyFromSeed` to use `buildSeedComplete` output
- [ ] Prove `seed_to_mcs_box` using ModalClosed:
  - Box psi in seed at (f,t) implies psi in MCS at all families
- [ ] Prove `seed_to_mcs_G` using GClosed:
  - G psi in seed implies psi in MCS at all future times
- [ ] Prove `seed_to_mcs_H` using HClosed:
  - H psi in seed implies psi in MCS at all past times
- [ ] Resolve sorry at line 246 (forward_G cross-sign case)
- [ ] Resolve sorry at line 256 (backward_H cross-sign case)
- [ ] Resolve sorry at line 328 (buildFamilyFromSeed_cross_sign_seed)
- [ ] Resolve sorry at line 161 (modal_witness_includes_boxcontent)
- [ ] Resolve sorry at line 372 (buildFamilyFromSeed_contains_seed t!=0)
- [ ] Verify SeedBMCS.lean still compiles with updated SeedCompletion

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` - Resolve 5 sorries
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Add bridge lemmas if needed

**Verification:**
- `lake build` succeeds
- `grep -c "sorry" SeedCompletion.lean` returns 0
- `#check buildFamilyFromSeed` compiles without sorries on its dependencies
- SeedBMCS.lean compiles (may still have its own sorries)

---

## Testing & Validation

- [ ] `lake build` succeeds on entire Theories/ directory
- [ ] `grep "sorry" RecursiveSeed.lean` shows only 3 non-critical sorries in buildSeedForList
- [ ] `grep "sorry" SeedCompletion.lean` shows 0 sorries
- [ ] `buildSeedComplete` evaluates on test formulas (atom, Box p, G(H p))
- [ ] Termination proof completes without partial/sorry markers
- [ ] All closure properties provable without axioms

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-005.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the worklist approach proves intractable:

1. **Fuel-based alternative**: Process with fuel = subformula count, prove fuel suffices
2. **Fixpoint alternative**: Define seed as least fixpoint of propagation rules, prove finiteness
3. **Preserve v004 work**: The existing `buildSeedAux` remains in codebase and can be restored

The new code is additive (new functions) not destructive (modifying existing). Rollback requires only removing new definitions.
