# Phase 2 Definition Fix Handoff

## Summary

Changed `BurgessR3Maximal` maximality clause from `SetDeductivelyClosed` to `ClosedUnderDerivation`, matching Burgess 1982 exactly. This enables the neg-until witness extraction for ALL δ ∉ B, including when {δ}∪B is inconsistent (B is MCS case).

## Changes Made

### 1. ChronicleTypes.lean:326 — Definition change
- **Before**: `∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C`
- **After**: `∀ D, ClosedUnderDerivation D → B ⊂ D → ¬burgessR3 A D C`
- First conjunct `SetDeductivelyClosed B` retained (B is consistent + CUD)

### 2. RRelation.lean — Zorn proof updated
- `burgessR3Maximal_extension_exists`: added `h_no_univ : ¬burgessR3 A Set.univ C` hypothesis
- Proof upgraded: SDC-Zorn + case split (consistent → SDC maximality; inconsistent → h_no_univ)
- `burgessR3Maximal_exists_from_seed`: threads h_no_univ
- `burgessR3Maximal_from_g_content_sub`: takes h_no_univ as hypothesis

### 3. PointInsertion.lean — Sorry #1 CLOSED
- `BurgessR3Maximal_extension_fails`: removed consistency requirement (now works for any δ∉B)
- `BurgessR3Maximal_neg_or_ext_fails`: simplified
- `burgess_D0_finite_subset_consistent_incons` Case B (B is MCS): pos sub-case now PROVEN
  - Uses CUD-maximality to extract neg-until witness via β∉B directly
  - Derives ⊢ (b∧β)→⊥ (since b contains β.neg), then EFQ to guard
  - left_mono + right_mono gives untl(beta0∧β, gamma0) ∈ A, contradiction with witness

## Remaining Sorries

### New NoUnivBurgessR3 sorries (5 instances, single condition)
- Line 178: lemma_2_4 → burgessR3Maximal_from_g_content_sub
- Lines 2716, 2718: lemma_2_6_splitting → burgessR3Maximal_extension_exists  
- Lines 2897, 2899: lemma_2_7 → burgessR3Maximal_extension_exists

All 5 are the SAME structural condition: `¬burgessR3 A Set.univ C`. This should be threaded from the chronicle construction level. In the chronicle, g(x,y) = Set.univ is impossible when x,y have intermediate points (C3 forces g(x,y) ⊆ f(z) for any intermediate z, and f(z) is MCS ≠ Set.univ).

### Existing sorry #3 (line 2922): xi inconsistent case
Requires B' to contain xi where xi is a contradiction. SetDeductivelyClosed B' (consistent) makes this impossible. Fix requires either:
- Change first conjunct to ClosedUnderDerivation (massive downstream impact)
- Add SetConsistent({xi}) as a hypothesis (provable in dense-order completeness)

### Existing sorry #2 (line 2783): lemma_2_7_seed_consistent
Separate issue — requires BX5+BX7+BX13+BX14 chain construction.

## Build Status
- `lake build`: passes successfully
- No regressions in existing proofs

## Recommended Next Steps
1. Thread `NoUnivBurgessR3` from chronicle construction (prove at C2' level)
2. Close sorry #3 by adding `SetConsistent ({xi})` hypothesis (from Burgess 2.2: if U(γ,δ)∈A MCS, then γ is consistent — the EVENT is consistent, and the guard xi can still be inconsistent in J₀. But on dense orders, untl(inconsistent_guard, event) is unsatisfiable.)
3. Close sorry #2 (lemma_2_7_seed_consistent) via BX chain construction
