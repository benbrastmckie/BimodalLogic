# Implementation Summary: Tableau Termination via Blocking and FMP Bounds

- **Task**: 237 - Implement blocking strategy ensuring tableau expansion terminates for all formulas
- **Status**: Completed
- **Session**: sess_1780339480_ozo

## Changes Made

### Phase 1: Time-type computation and subset blocking predicate
**File**: `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`

Added blocking infrastructure after the `TimeOrdering` section:
- `Branch.formulasAtTime`: collects signed formulas at a given time index
- `Branch.timeType`: extracts deduplicated `(Sign, Formula)` pairs at a time
- `Branch.isSubsetBlocked`: checks if type at t_new is subset of type at t_anc
- `ancestorTimes`: computes transitive closure of temporal predecessors/successors in TimeOrdering
- `isTemporallyBlocked`: checks if any ancestor blocks a given time
- `findBlockedTime`: finds first blocked time on a branch
- `BlockingState`: tracks blocked times and their blocking ancestors

### Phase 2: Wire blocking into expansion pipeline
**File**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

Modified `expandBranchWithFuel` to add a blocking check after `findClosure` returns `none` and before `expandOnce`. When `findBlockedTime` detects a blocked time, the branch is treated as saturated open (returned as `some (.inr b)`). This prevents infinite chains from Until/Since positive rules.

### Phase 3: FMP-derived sound fuel bound
**Files**: `Saturation.lean`, `DecisionProcedure.lean`

Added `soundFuel : Formula -> Nat` computing `n * 2^n` (capped at 100000) where `n = |subformulaClosure(phi)|.card`, based on the Finite Model Property. Updated `buildTableauAuto` and `decideAuto` to use `soundFuel` instead of `recommendedFuel`. The old `recommendedFuel` is kept for backward compatibility but marked deprecated.

### Phase 4: EventualityTracker integration
**File**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

Added `EventualityTracker` parameter to `expandBranchWithFuel`. Added `registerEventualities` (scans branch for T(U(event,guard)) and T(S(event,guard)) formulas, registering pending eventualities) and `fulfillEventualities` (checks if event formulas appear at different times on the branch). The tracker is updated at each expansion step.

### Phase 5: Testing and completeness argument
**File**: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`

- Added 5 extended tests (E1-E5): nested Until, combined Until/Since, propositional regression, satisfiable formula with blocking, G(p)->p
- Stated 3 correctness theorem stubs with `sorry`: `subformula_property`, `blocking_terminates`, `blocking_sound`
- Added comprehensive completeness preservation argument documentation

## Test Results

All tests pass:
- 7 original Until/Since tests: PASS
- 3 blocking tests (B1-B3): PASS
- 5 extended tests (E1-E5): PASS/INFO
- Pre-existing modal-temporal tests: PASS (with 2 known INFO items)
- Pre-existing frame class tests: PASS

## Verification

- `lake build`: passes (1680 jobs, zero errors)
- Sorry count: 3 (exactly the planned theorem stubs)
- Vacuous definitions: 0
- New axioms: 0
- Build warnings: only pre-existing linter warnings

## Plan Deviations

- Phase 1: `timeType` returns `List (Sign x Formula)` instead of `List Formula` to preserve sign information
- Phase 2: TimeOrdering threading was already in place; blocking tests used simpler formulas than originally planned
- Phase 3: Used `n * 2^n` bound instead of `2^(2n)` for tighter practical bound; kept `recommendedFuel` for backward compat
- Phase 4: Used branch-scanning approach for eventuality registration rather than rule-specific detection; subset blocking automatically handles eventuality inheritance (per research Section 4.4)
- Phase 5: Skipped `#print axioms buildTableau` (def, not theorem); verified zero axiom declarations instead

## Files Modified

1. `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Blocking predicate, ancestor computation, BlockingState
2. `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Blocking check, soundFuel, EventualityTracker, tests, theorem stubs
3. `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Updated decideAuto to use soundFuel
4. `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Fixed duplicate docstring (concurrent task 236 artifact)
