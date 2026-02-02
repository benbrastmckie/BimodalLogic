# Implementation Summary: Task #799 (Phases 1-2)

**Task**: Complete Decidability proofs
**Completed**: 2026-02-02
**Phases**: 1-2 of 5

## Overview

Completed Phases 1 and 2 of the decidability proofs implementation. These phases focused on Closure.lean and required adding LawfulBEq instances for BEq equality conversion.

## Changes Made

### Formula.lean
- Added `beq_refl` theorem for BEq reflexivity
- Added `eq_of_beq` theorem for BEq injectivity
- Added `ReflBEq Formula` instance
- Added `LawfulBEq Formula` instance

### SignedFormula.lean
- Added `ReflBEq Sign` instance
- Added `Sign.eq_of_beq` theorem
- Added `LawfulBEq Sign` instance
- Added `SignedFormula.beq_eq` definitional equality
- Added `SignedFormula.beq_refl` theorem
- Added `ReflBEq SignedFormula` instance
- Added `SignedFormula.eq_of_beq` theorem
- Added `LawfulBEq SignedFormula` instance

### Closure.lean
- Added 6 monotonicity helper lemmas:
  - `hasNeg_mono`
  - `hasPos_mono`
  - `hasBotPos_mono`
  - `checkBotPos_mono`
  - `checkContradiction_mono`
  - `checkAxiomNeg_mono`
- Completed `closed_extend_closed` theorem using Option.orElse_eq_some analysis
- Completed `add_neg_causes_closure` theorem using LawfulBEq and witness extraction

## Key Technical Challenges

1. **BEq Reflexivity**: The derived BEq instance for SignedFormula is not definitionally reflexive. This required proving explicit `ReflBEq` instances for Sign, Formula, and SignedFormula.

2. **BEq to Equality Conversion**: Converting BEq equalities `(a == b) = true` to regular equalities `a = b` required `LawfulBEq` instances with `beq_iff_eq`.

3. **Option.orElse Analysis**: The `closed_extend_closed` proof required careful analysis of `Option.orElse_eq_some` to handle the three-way closure check.

## Verification

- `lake build` succeeds with no errors
- Closure.lean: 2 sorries removed (0 remaining)
- SignedFormula.lean: No new sorries
- Formula.lean: No new sorries

## Remaining Work (Phases 3-5)

4 sorries remain in the Decidability module:
- Saturation.lean: 1 (`expansion_decreases_measure`)
- Correctness.lean: 3 (`decide_axiom_valid`, `tableau_complete`, `decide_complete`)

These require FMP infrastructure and more complex proof strategies.

## Files Modified

- `Theories/Bimodal/Syntax/Formula.lean`
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
