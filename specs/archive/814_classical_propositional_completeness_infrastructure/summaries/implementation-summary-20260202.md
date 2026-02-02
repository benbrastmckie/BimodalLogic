# Implementation Summary: Task #814

**Completed**: 2026-02-02
**Duration**: ~1.5 hours

## Overview

Resolved 4 classical propositional sorries in the BMCS completeness infrastructure by implementing proper proofs using the deduction theorem and double negation elimination. Also removed a duplicate definition.

## Changes Made

### TruthLemma.lean

**Added imports**:
- `Bimodal.Metalogic.Core.DeductionTheorem`
- `Bimodal.Theorems.Propositional`

**Implemented**:
1. `neg_imp_implies_antecedent`: Proves `|- neg(psi -> chi) -> psi`
   - Strategy: From [neg psi, neg(psi -> chi)], derive bot via efq_neg, then apply deduction theorem twice, then compose with double negation elimination
   - Marked as `noncomputable` due to dependency on `deduction_theorem`

2. `neg_imp_implies_neg_consequent`: Proves `|- neg(psi -> chi) -> neg chi`
   - Strategy: From [chi, neg(psi -> chi)], derive bot via prop_s, then apply deduction theorem twice
   - Marked as `noncomputable` due to dependency on `deduction_theorem`

### Completeness.lean

**Added imports**:
- `Bimodal.Metalogic.Core.DeductionTheorem`
- `Bimodal.Theorems.Propositional`

**Implemented**:
1. `not_derivable_implies_neg_consistent`: Proves that if phi is not derivable, then [neg phi] is consistent
   - Strategy: Assume inconsistency, apply deduction theorem to get |- neg neg phi, then use double negation elimination to get |- phi, contradicting non-derivability

2. `context_not_derivable_implies_extended_consistent`: Proves that if Gamma |-/- phi, then Gamma ++ [neg phi] is consistent
   - Strategy: Assume inconsistency, reorder context using weakening (since Gamma ++ [neg phi] subset of neg phi :: Gamma), apply deduction theorem to get Gamma |- neg neg phi, then use double negation elimination to get Gamma |- phi, contradicting non-derivability

**Refactored**:
- `double_negation_elim`: Converted from a definition with `sorry` to an abbreviation that reuses `Bimodal.Theorems.Propositional.double_negation`. This eliminates the duplicate definition.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - 2 sorries resolved, 2 imports added
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - 2 sorries resolved, 1 duplicate removed, 2 imports added
- `specs/814_classical_propositional_completeness_infrastructure/plans/implementation-001.md` - Updated phase statuses

## Verification

- `lake build` succeeds with no new errors
- All targeted sorries have been removed
- Remaining sorries in these files are out of scope:
  - TruthLemma.lean: Temporal backward sorries (omega-saturation required)
  - Completeness.lean: Universe polymorphism sorries (Lean technicality)

## Key Insights

1. The deduction theorem expects the formula to be discharged at the HEAD of the context (A :: Gamma). When working with Gamma ++ [A], context reordering via weakening is needed.

2. The existing `double_negation` theorem in Propositional.lean is complete and does not need reimplementation. The duplicate in Completeness.lean was unnecessary.

3. All four proofs follow a common pattern: construct a derivation leading to bot, apply deduction theorem to get a negated implication, and use double negation elimination when needed.

## Technical Notes

- The proofs rely on `deduction_theorem` which is `noncomputable` in Lean, so the implementing definitions must also be marked `noncomputable`.
- Context membership is verified using `by simp` for simple list membership proofs.
- Weakening is used to transfer theorems from empty contexts to non-empty contexts.
