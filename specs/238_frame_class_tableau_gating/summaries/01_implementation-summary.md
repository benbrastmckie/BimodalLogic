# Implementation Summary: Task #238 - Frame-Class-Aware Tableau Expansion

- **Task**: 238 - Frame-class-aware tableau expansion
- **Status**: [COMPLETED]
- **Plan**: specs/238_frame_class_tableau_gating/plans/01_implementation-plan.md
- **Type**: lean4

## Overview

Threaded a `FrameClass` parameter through the entire tableau decision pipeline and gated axiom-based closure by `ax.minFrameClass <= fc`. This fixes a critical correctness bug where `checkAxiomNeg` accepted ALL axiom witnesses regardless of the target frame class. Added 5 frame-class-specific `TableauRule` constructors for Dense and Discrete logics.

## Changes by File

### Closure.lean
- `checkAxiomNeg`: Added `fc : FrameClass := .Base` parameter and guard `witness.minFrameClass <= fc` before returning axiom closure
- `findClosure`, `isClosed`, `isOpen`, `classifyBranch`: Threaded `fc` parameter
- `OpenBranch`: Parameterized by `fc`, updated `notClosed` proof obligation
- Monotonicity theorems (`checkAxiomNeg_mono`, `closed_extend_closed`, `add_neg_causes_closure`): Updated to accept `fc`

### Tableau.lean
- Added 5 new `TableauRule` constructors: `denseIndicatorClosure`, `densityRule`, `priorUZ`, `priorSZ`, `z1Rule`
- `isApplicable`: Added `fc` parameter; Dense rules gated by `Dense <= fc`, Discrete rules by `Discrete <= fc`
- `applyRule`: Added implementation for all 5 new rules
- `allRulesForFC`: New function returning frame-class-aware rule list
- `findApplicableRule`, `isExpanded`, `findUnexpanded`, `expandOnce`: Threaded `fc` parameter
- `countUnexpanded`, `totalUnexpandedComplexity`: Threaded `fc` parameter

### Saturation.lean
- `expandBranchWithFuel`: Threaded `fc` to `findClosure` and `expandOnce`
- `expandBranchesWithFuel`: Threaded `fc` through recursive calls
- `buildTableau`, `buildTableauAuto`: Added `fc` parameter
- `isSaturated`, `isAtomicBranch`, `expansionMeasure`: Threaded `fc`
- Added 9 frame-class gating integration tests (FC1-FC9)

### DecisionProcedure.lean
- `decide`, `decideAuto`, `decideOptimized`, `decideBatch`: Added `fc` parameter
- `isValid`, `isSatisfiable`, `isTautology`, `isContradiction`, `isContingent`: Added `fc` parameter
- Hardcoded `FrameClass.Base` check in `decide` retained for proof extraction (proof terms are always Base-parameterized)

### ProofExtraction.lean
- `extractProof`, `findProofCombined`: Added `fc` parameter for forward-compatibility
- `tryAxiomProof`, `extractFromClosureReason`, `proofFromAxiom`: Kept at Base level (DecisionResult returns Base proofs)

### CountermodelExtraction.lean
- `findCountermodel`, `extractCountermodelFromTableau`, `branchTruthLemma`: Added `fc` parameter

### Correctness.lean
- `decide_result_exclusive`: Updated to accept `fc` parameter

## Key Design Decisions

1. **Default parameter approach**: All new `fc` parameters default to `.Base`, ensuring backward compatibility -- existing call sites compile unchanged.

2. **Proof extraction stays at Base**: The `DecisionResult` type returns `⊢ φ` (= `DerivationTree FrameClass.Base [] φ`). Proof extraction functions remain at Base level. The correctness fix is in `checkAxiomNeg` gating, which uses the threaded `fc`.

3. **New rules use persistent mode**: Dense/Discrete rules return `.persistent` rather than `.linear` to keep source formulas on the branch for re-propagation.

4. **allRulesForFC replaces allRules for lookup**: `findApplicableRule` now uses `allRulesForFC fc` with `isApplicable` pre-check for efficiency.

## Verification

- `lake build`: Passes with zero errors (1679 jobs)
- Sorry count in modified files: 0 new (3 pre-existing from task 237)
- Vacuous definitions: 0
- New axioms: 0
- Integration tests: 9 frame-class gating tests (FC1-FC9)

## Plan Deviations

- Phase 1 task for `expandOnce`/`findApplicableRule`/`findUnexpanded`/`isExpanded` fc threading: deferred from Phase 1 to Phase 2-3 since these functions needed fc for frame-class-specific rules, not just for gating axiomNeg
- `recommendedFuel` not parameterized (only depends on formula complexity, not frame class)
- ProofExtraction functions kept at Base level rather than parameterized (DecisionResult type constraint)
- Dense/Discrete `#eval` tests consolidated into Phase 4 rather than being in Phases 2 and 3 separately
- Representative test suite (9 tests) rather than all 42 axiom constructors
