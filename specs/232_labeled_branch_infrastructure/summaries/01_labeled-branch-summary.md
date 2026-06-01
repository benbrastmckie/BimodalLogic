# Implementation Summary: Labeled Branch Infrastructure

- **Task**: 232 - Labeled branch infrastructure (world/time-indexed types)
- **Status**: Implemented
- **Plan**: specs/232_labeled_branch_infrastructure/plans/01_labeled-branch-plan.md

## Overview

Replaced flat `SignedFormula` and `Branch` types in `Metalogic/Decidability/` with world/time-indexed types supporting proper multi-world modal and time-indexed temporal reasoning. The migration followed the import DAG strictly: SignedFormula -> Tableau -> Closure -> Saturation -> downstream files.

## Changes

### Phase 1: Core Type Definitions (SignedFormula.lean)
- Added `WorldIndex := Nat`, `TimeIndex := Nat`, and `Label` structure with `world` and `time` fields
- Added `Label.initial` at `(0, 0)` with full `LawfulBEq` instance
- Extended `SignedFormula` with a `label : Label` field
- Updated `pos`/`neg` constructors with optional label parameter (defaults to `Label.initial`)
- Updated `flip` to preserve labels
- Re-proved `beq_eq`, `beq_refl`, `eq_of_beq` for the 3-field structure
- Added `Branch.hasPosAt` and `Branch.hasNegAt` for label-specific membership checks
- Updated `Branch.hasBotPos` to match T(bot) at any label
- Updated `Branch.findContradiction` to match within same label

### Phase 2: Tableau Rule Migration (Tableau.lean)
- Threaded `sf.label` through all 16 `applyRule` cases
- Propositional rules (8) preserve input label in output formulas
- Modal/temporal rules (8) preserve labels as identity-collapse placeholders (tasks 233/234 will replace)

### Phase 3: Closure Detection Update (Closure.lean)
- Updated `ClosureReason` constructors to carry `Label` parameter
- Updated `checkBotPos` to use `findSome?` and record the label where T(bot) was found
- Updated `checkContradiction` to use `hasNegAt` for same-label matching
- Updated `checkAxiomNeg` to record the label
- Proved `hasNegAt_mono` and `hasPosAt_mono` monotonicity lemmas
- Re-proved all 6 existing monotonicity lemmas (`hasNeg_mono`, `hasPos_mono`, `hasBotPos_mono`, `checkBotPos_mono`, `checkContradiction_mono`, `checkAxiomNeg_mono`)
- Re-proved `closed_extend_closed` and `add_neg_causes_closure`

### Phase 4: Saturation (Saturation.lean)
- Updated `buildTableau` initial branch to use `Label.initial`
- Fixed dummy `ClosedBranch` for new `ClosureReason.botPos` signature

### Phase 5: Downstream Files
- **ProofExtraction.lean**: Updated `ClosureReason` pattern matches (added wildcard for label)
- **DecisionProcedure.lean**: Updated `ClosureReason` pattern matches (added wildcard for label)
- **CountermodelExtraction.lean**: No changes needed (accesses `sf.formula` and `sf.sign` only)
- **Correctness.lean**: No changes needed (zero SignedFormula/Branch usage)
- **EnrichedCountermodel.lean**: Added label to `SignedFormula.toJson` serialization

## Verification

- Zero sorries in all modified files
- Zero vacuous definitions introduced
- Zero new axioms introduced
- Full `lake build` passes (1679 jobs)
- FMP subsystem (7 files) unaffected

## Modified Files

1. `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`
2. `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`
3. `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
4. `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
5. `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean`
6. `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`
7. `Theories/Bimodal/Automation/EnrichedCountermodel.lean`

## Plan Deviations

- None (implementation followed plan)
