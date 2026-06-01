# Implementation Summary: S5 Modal Tableau Rules (Multi-World Bookkeeping)

- **Task**: 233 - S5 modal tableau rules (multi-world bookkeeping)
- **Status**: Completed
- **Session**: sess_1748788800_orch233
- **Date**: 2026-06-01

## Changes

### SignedFormula.lean (~40 lines added)
Added branch helper functions in the `Branch` namespace:
- `knownWorlds`: Collects all distinct WorldIndex values from branch formulas
- `maxWorld`: Returns maximum world index (0 if empty)
- `nextWorld`: Returns maxWorld + 1 for fresh world allocation
- `boxPosFormulas`: Filters branch for all T(box A) formulas (universal modal)
- `diamondNegFormulas`: Filters branch for all F(diamond A) formulas (universal modal)

### Tableau.lean (~90 lines changed)
Core S5 modal rule implementation:
- Added `RuleResult.persistent` constructor for universal rules that must not be consumed
- Changed `applyRule` signature to accept `branch : Branch := []` for context-aware rules
- **boxPos** (T(box A)): Universal rule -- propagates T(A) to all known worlds, returns `.persistent` if new formulas exist, `.notApplicable` if all already present
- **boxNeg** (F(box A)): Existential rule -- introduces F(A) at fresh witness world, auto-propagates all T(box B) and F(diamond B) formulas to the new world
- **diamondPos** (T(diamond A)): Existential rule -- introduces T(A) at fresh witness world, auto-propagates universals
- **diamondNeg** (F(diamond A)): Universal rule -- propagates F(A) to all known worlds, persistent
- Updated `findApplicableRule`, `isExpanded`, `findUnexpanded`, `expandOnce`, `countUnexpanded`, `totalUnexpandedComplexity` to be branch-aware
- `expandOnce` handles `.persistent` by adding new formulas without removing the source formula

### Saturation.lean (~4 lines changed)
- Updated `isAtomicBranch` and `expansionMeasure` to pass branch context to `isExpanded`
- No changes needed to `expandBranchWithFuel` -- persistent expansion returns `.extended` from `expandOnce`, fuel still decrements preventing infinite loops

## Test Results

All S5 validity tests pass:
- T-axiom `box p -> p`: VALID (correct -- reflexivity propagation)
- K-axiom `box (p -> q) -> (box p -> box q)`: VALID (correct -- distribution)
- 5-axiom `diamond p -> box (diamond p)`: VALID (correct -- S5-specific)
- `p -> box p`: INVALID (correct -- non-theorem)
- `p -> p`: VALID (correct -- propositional regression)

## Verification

- `lake build` passes with zero errors (1679 jobs)
- Zero `sorry` in Decidability module
- Zero vacuous definitions
- Zero new axioms introduced
- No downstream compilation errors (CountermodelExtraction, ProofExtraction, DecisionProcedure, Correctness all compile unchanged)

## Plan Deviations

- Phase 1 Task 5: Inlined diamond pattern match (`.imp (.box (.imp _ .bot)) .bot`) instead of using `asDiamond?` which is defined in Tableau.lean, not available in SignedFormula.lean
- Phase 3 Task 1: No changes needed to `expandBranchWithFuel` since `expandOnce` returns `.extended` for persistent results
- Phase 4 Tasks 3: Verified types via successful compilation of all downstream consumers instead of interactive `#check`

## Design Decisions

1. **Universal rules return `.persistent`**: Source formula is retained in the branch so it can be re-applied when new worlds are introduced by existential rules
2. **Saturation via `.notApplicable`**: When all propagations are already present, universal rules return `.notApplicable`, making `isExpanded` return `true` and allowing saturation detection to work correctly
3. **Auto-propagation on existential rules**: When boxNeg or diamondPos create a fresh world, all existing universal formulas (T(box B), F(diamond B)) are immediately propagated to the new world, ensuring completeness
4. **Fuel-based termination**: Persistent expansions consume fuel like any other expansion, preventing infinite loops even though the source formula is retained
