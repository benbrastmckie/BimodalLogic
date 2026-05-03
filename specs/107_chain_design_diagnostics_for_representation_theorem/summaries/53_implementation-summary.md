# Implementation Summary: Task #107

**Date**: 2026-05-03
**Status**: Partial Implementation
**Total Sorries**: 6 remaining

## Overview

This session focused on implementing the Burgess 1982 chronicle construction for the BX bimodal logic representation theorem. The work addressed Phase 2 (D0 seed consistency) and Phase 3 (Lemma 2.7 BX7 chain).

## Accomplishments

### Phase 2: D0 Seed Consistency [Partial]

**Issue Fixed**: Build failures due to type errors in the inconsistent case.

**Changes Made**:
1. Fixed unterminated comment at `d0_a_event_list_mem` (line ~1406)
2. Simplified `burgess_D0_finite_subset_consistent_incons` to use `sorry` pending correct event construction
3. Simplified `d0_a_event_list_mem` to use `sorry` pending Classical.choose reasoning

**Remaining**: 2 sorries
- `d0_a_event_list_mem`: Requires proof that Classical.choose extracts the correct α from the Since formula
- `burgess_D0_finite_subset_consistent_incons`: Requires restructuring event construction to derive `event → b` from enrichment

### Phase 3: Lemma 2.7 BX7 Chain [Skeleton Complete]

**Implementation**: Created the full proof structure following Burgess 1982 p.372.

**New Helper Lemmas** (all with `sorry`, structured correctly):

1. **`lemma_2_7_neg_untl_exists`** (line ~2227)
   - Extracts β₀ ∈ B, γ₀ ∈ C with `¬untl(β₀ ∧ eta, γ₀) ∈ A`
   - Uses BurgessR3Maximal maximality property

2. **`linear_until_mcs`** (line ~2238)
   - BX7 (linear_until) at MCS level
   - Produces three-way disjunction D1 ∨ D2 ∨ D3 ∈ A

3. **`lemma_2_7_disjunct_elim_D1`** (line ~2251)
   - Shows D1 contradicts neg-until witness
   - Uses monotonicity: D1 = `untl(xi∧b, eta∧γ_hat)` implies `untl(xi∧b, eta)`

4. **`lemma_2_7_disjunct_elim_D2`** (line ~2263)
   - Shows D2 contradicts neg-until witness
   - Similar structure to D1 elimination

5. **`lemma_2_7_seed_consistent`** (line ~2283)
   - Main theorem with BX7 chain structure
   - Orchestrates the 10-step Burgess proof

**Remaining Work**:
- Implement maximality extraction for neg-until witness
- Apply BX7 axiom with proper derivation tree construction
- Prove disjunct elimination using Until monotonicity
- Complete the main proof with enrichment and F-extraction

## Build Status

```
lake build Bimodal.Metalogic.BXCanonical.Chronicle.PointInsertion
-- Build completed successfully (785 jobs)
-- 6 sorries remaining
```

## File Changes

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Fixed type errors and unterminated comments
  - Added Phase 3 helper lemma skeletons
  - 165 lines net change (simplified inconsistent case, added BX7 structure)

## Time Estimate for Completion

**Remaining**: 5-7 hours
- Phase 2 sorries: 2-3 hours (event construction, Classical.choose reasoning)
- Phase 3 sorries: 3-4 hours (maximality extraction, BX7 application, disjunct elimination)

## Next Steps

1. **Implement `lemma_2_7_neg_untl_exists`**:
   - Unfold BurgessR3Maximal definition
   - Use extension_fails to extract the neg-until witness
   - Apply criterion 2.3(a) from Burgess

2. **Implement `linear_until_mcs`**:
   - Use `theorem_in_mcs` with `Axiom.linear_until`
   - Apply conjunction closure for the Until formulas

3. **Implement disjunct elimination**:
   - For D1: Use right monotonicity with `eta∧γ_hat → eta`
   - For D2: Use right monotonicity with `eta∧b → eta`
   - Derive contradiction with neg-until via left monotonicity

4. **Complete main proof**:
   - Chain the helpers together
   - Apply BX13 enrichment and BX10 F-extraction
   - Show event implies all 5 seed components

## References

- Burgess 1982 "Axioms for Tense Logic: Since and Until", Notre Dame Journal, Vol. 23, No. 4, pp. 367-374
- Lemma 2.7 proof structure: Section 2.7, p. 372
- BX7 axiom: `Axiom.linear_until` in ProofSystem/Axioms.lean
