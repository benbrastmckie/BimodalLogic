# Implementation Summary: Task #799 (Final)

**Task**: Complete Decidability proofs
**Completed**: 2026-02-02
**Phases**: 1-2 completed; 3-5 superseded by Task 806

## Overview

Task 799 aimed to complete 6 sorries in the Decidability module. Phases 1-2 were completed in an earlier session, successfully proving the closure theorems. Phases 3-5 were subsequently superseded by Task 806, which achieved zero-sorry Metalogic by archiving the completeness theorems to Boneyard.

## Phases 1-2: Completed

### Changes Made

#### Formula.lean
- Added `beq_refl` theorem for BEq reflexivity
- Added `eq_of_beq` theorem for BEq injectivity
- Added `ReflBEq Formula` instance
- Added `LawfulBEq Formula` instance

#### SignedFormula.lean
- Added `ReflBEq Sign` instance
- Added `Sign.eq_of_beq` theorem
- Added `LawfulBEq Sign` instance
- Added `SignedFormula.beq_eq` definitional equality
- Added `SignedFormula.beq_refl` theorem
- Added `ReflBEq SignedFormula` instance
- Added `SignedFormula.eq_of_beq` theorem
- Added `LawfulBEq SignedFormula` instance

#### Closure.lean
- Added 6 monotonicity helper lemmas:
  - `hasNeg_mono`
  - `hasPos_mono`
  - `hasBotPos_mono`
  - `checkBotPos_mono`
  - `checkContradiction_mono`
  - `checkAxiomNeg_mono`
- Completed `closed_extend_closed` theorem using Option.orElse_eq_some analysis
- Completed `add_neg_causes_closure` theorem using LawfulBEq and witness extraction

### Key Technical Challenges

1. **BEq Reflexivity**: The derived BEq instance for SignedFormula is not definitionally reflexive. This required proving explicit `ReflBEq` instances for Sign, Formula, and SignedFormula.

2. **BEq to Equality Conversion**: Converting BEq equalities `(a == b) = true` to regular equalities `a = b` required `LawfulBEq` instances with `beq_iff_eq`.

3. **Option.orElse Analysis**: The `closed_extend_closed` proof required careful analysis of `Option.orElse_eq_some` to handle the three-way closure check.

## Phases 3-5: Superseded by Task 806

Task 806 (commit c5917f44) achieved zero-sorry Metalogic by archiving incomplete theorems:

- **Phase 3** (`expansion_decreases_measure`): Archived to Boneyard
- **Phase 4** (`decide_axiom_valid`): Archived to Boneyard
- **Phase 5** (`tableau_complete`, `decide_complete`): Archived to Boneyard

These completeness theorems require FMP (Finite Model Property) infrastructure that is preserved in Boneyard for future completion.

## Final State

- Decidability module: **0 sorries** (all closure theorems complete, completeness theorems archived)
- Metalogic module: **0 sorries** overall (achieved by Task 806)
- `lake build` passes with no errors

## Files Modified

- `Theories/Bimodal/Syntax/Formula.lean`
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
