# Implementation Summary: Task #864

**Task**: Recursive seed construction for Henkin model completeness (v005 - Worklist Algorithm)
**Session**: sess_1771395402_e6313c
**Date**: 2026-02-17
**Status**: Partial (Phases 1-3 complete, Phase 4-5 partial structure)

## Overview

Implemented the worklist-based seed construction algorithm that resolves the architectural cross-sign coherence blocker identified in v004. The algorithm processes every formula at every position it is placed, guaranteeing modal and temporal closure properties.

## Phases Completed

### Phase 1: Data Structures [COMPLETED]
- Added `WorkItem` structure with formula, famIdx, timeIdx fields
- Added `DecidableEq`, `BEq`, `LawfulBEq`, `Hashable` instances for WorkItem
- Added `WorklistState` structure with seed, worklist, processed fields
- Added `WorklistState.empty` and `WorklistState.initial` constructors
- Added `getFutureTimes`, `getPastTimes` helper functions
- Added `WorkItem.complexity`, `totalPendingComplexity`, `terminationMeasure` functions

### Phase 2: Core Algorithm [COMPLETED]
- Implemented `processWorkItem` with all 10 formula classification cases
- Implemented `processWorklist` main loop with termination annotation
- Implemented `buildSeedComplete` entry point for worklist-based construction
- Added `buildSeedComplete_computes` test theorem

### Phase 3: Termination Proof [COMPLETED]
- **Key discovery**: Sum-based termination measure is fundamentally flawed
  - Processing `Box psi` with N families creates N copies of `psi`
  - Sum of N copies can exceed `item.complexity`, breaking well-founded termination
  - Correct solution requires Dershowitz-Manna multiset ordering
- **Resolution**: Switched to fuel-based termination (structural recursion on fuel)
  - Added `processWorklistAux (fuel : Nat) (state : WorklistState)` with structural recursion
  - Added `worklistFuelBound (phi : Formula)` computing upper bound on iterations
  - Modified `processWorklist` to wrap `processWorklistAux` with computed fuel
- Added complexity lemmas: `Formula.neg_complexity`, `Formula.box_inner_complexity_lt`, etc.
- Added `processWorkItem_newWork_complexity_lt` with complete proofs for all 30+ formula patterns
- Expanded catch-all match patterns to explicit Formula constructor cases
- `buildSeedComplete_computes` proven via `native_decide`

### Phase 4: Consistency Proof [PARTIAL]

**Structure completed, inner proofs pending (22 sorries):**
- Added `WorklistInvariant` combining seed consistency with worklist formula consistency
- Added 6 subformula consistency lemmas (sorries - require cut rule derivation)
  - `box_inner_consistent`, `all_future_inner_consistent`, `all_past_inner_consistent`
  - `neg_box_neg_inner_consistent`, `neg_future_neg_inner_consistent`, `neg_past_neg_inner_consistent`
- Added `processWorkItem_preserves_consistent` with 10-case match structure
- Added `processWorkItem_newWork_consistent` with 10-case match structure
- Added `processWorklistAux_preserves_invariant` induction proof (compiles)
- Added `processWorklist_preserves_consistent` wrapper (compiles)
- Added `buildSeedComplete_consistent` final theorem (compiles)

**Key insight discovered:** The consistency proofs require cut rule / derivation tree manipulation that isn't directly available. The T-axiom gives `Box psi -> psi` but combining this with `psi ⊢ ⊥` to get `Box psi ⊢ ⊥` requires a cut lemma.

### Phase 5: Closure Properties [PARTIAL - Iteration 5]

**Structure completed, inner proofs pending (6 sorries):**
- Added `ModalClosed`, `GClosed`, `HClosed`, `SeedClosed` definitions
- Added `WorklistClosureInvariant` tracking pending closure work
- **PROVEN**: `empty_worklist_closure` - when worklist empties, closure invariant implies closure
- **PROVEN**: `initial_seed_getFormulas_unique` - helper for initial state analysis
- **PROVEN**: `initial_closure_invariant` - initial state satisfies closure invariant
- Added `processWorkItem_preserves_closure` (1 sorry - complex case analysis)
- Added `processWorklistAux_preserves_closure` with induction structure (5 sorries)
- Added `buildSeedComplete_closed` (uses above lemmas)

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
  - Lines 6344-6800: Worklist algorithm implementation (Phases 1-3)
  - Lines 6870-7136: Phase 4 consistency proof structure
  - Lines 7137-7370: Phase 5 closure property structure

## Technical Decisions

1. **Fuel-based termination**: Chose structural recursion on fuel over Dershowitz-Manna multiset ordering for simplicity. The fuel bound is computed from formula complexity squared.
2. **Pattern expansion**: Replaced nested match catch-all patterns (`| _, _ =>`) with explicit cases for each Formula constructor combination, enabling direct use of `hf` hypothesis.
3. **Worklist structure**: Used `Finset WorkItem` for processed set to enable efficient membership checking
4. **Formula complexity**: Leveraged existing `Formula.complexity` definition
5. **Closure invariant revision**: Changed invariant to track pending Box/G/H formulas (parent) rather than their inner formulas, matching the algorithm's behavior.

## Verification

- `lake build` succeeds (full project: 1000 jobs)
- `processWorklist` compiles with proven termination (fuel-based)
- `buildSeedComplete_computes` proven via `native_decide`
- All formula classification cases have complete complexity proofs
- Closure definitions and initial state lemmas fully proven

## Sorry Count Analysis

**Total sorries in RecursiveSeed.lean: 39**

Breakdown:
- **Legacy/non-critical (8)**: Lines 1949, 3218, 3334, 5710, 5735, 5924, 6201, 6206
- **Phase 4 consistency (22)**: Lines 6903-7051
- **Phase 5 closure (6)**: Lines 7322-7369
- **Auxiliary (3)**: buildSeedForList helper (not on critical path)

## Blockers Resolved

1. **Decreasing_by binding access**: Used `match h :` syntax in iterations 1-2
2. **Sum-based measure flaw**: Switched to fuel-based termination in iteration 3
3. **Catch-all pattern reductions**: Expanded all catch-all patterns to explicit cases
4. **Closure invariant formulation**: Revised to track parent formulas, not inner formulas

## Recommendations for Successor

### Strategic Priority Order

1. **Phase 5 completion FIRST** - The closure proofs are more tractable and directly resolve SeedCompletion.lean sorries
2. **Phase 6 connection** - Use closure properties to resolve 5 SeedCompletion sorries
3. **Phase 4 completion** - Consistency proofs require cut rule infrastructure

### Phase 5 Completion (Recommended Next)

The `processWorkItem_preserves_closure` lemma (line 7322) is the key:

1. **Case analysis on formula class**: Match on `classifyFormula item.formula`
2. **boxPositive case**: When processing `Box psi`, the algorithm adds `psi` to ALL families at current time - this directly establishes modal closure for that Box formula
3. **futurePositive/pastPositive cases**: Similar - processing adds inner formula to all future/past times
4. **Other cases**: Don't introduce new Box/G/H formulas, so closure preserved trivially

The remaining `processWorklistAux_preserves_closure` sorries follow from `processWorkItem_preserves_closure`.

### Phase 4 Cut Rule

If pursuing Phase 4:
- Add `cut_rule` lemma to `Derivation.lean`: from `Γ ⊢ φ` and `{φ} ∪ Δ ⊢ ψ` derive `Γ ∪ Δ ⊢ ψ`
- This is admissible in the proof system but not currently explicit
- Once cut is available, subformula consistency lemmas become straightforward

### SeedCompletion.lean Sorries (5 total)

These are blocked on Phase 5 closure:
- Line 161: `modal_witness_includes_boxcontent` - needs ModalClosed
- Line 246: `forward_G` cross-sign case - needs GClosed
- Line 256: `backward_H` cross-sign case - needs HClosed
- Line 328: `buildFamilyFromSeed_cross_sign_seed` - needs GClosed/HClosed
- Line 372: `buildFamilyFromSeed_contains_seed` (t!=0) - needs seed propagation lemmas

## Architectural Insight

The worklist algorithm resolves the v004 cross-sign blocker BY DESIGN:
- v004's `buildSeedAux` only recursed on inner formula at CURRENT position
- When `G(H psi)` is processed at time 0, `H psi` is propagated to future times but never processed there
- The worklist approach processes ALL propagated formulas, so `H psi` at future times gets processed and propagates `psi` backward

This is the key insight that makes closure properties achievable. The sorries are in proving the algorithm maintains this invariant through each step.
