# Implementation Summary: Bulldozing via Seeded F-Content

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan Version**: 13
**Status**: PARTIAL

## Summary

This implementation adds `f_content u` to `constrained_successor_seed_restricted`, enabling strong F-persistence in the forward chain construction. The original target sorries at lines 3006 and 3037 are now closed, but they depend on `boundary_implies_k_lt_B` which itself has a sorry.

## Key Changes

### Phase 1: Add f_content to Seed Definition
- Modified `constrained_successor_seed_restricted` in SuccExistence.lean to include `f_content u`
- Updated membership lemma to include 5th disjunct
- Added subset lemmas for all components

### Phase 2: Seed Consistency Adaptation
- Updated `constrained_successor_seed_restricted_subset_deferralClosure` to handle f_content case
- Updated `neg_not_in_seed_when_in_brs` to handle f_content case (uses BRS mutual exclusion)
- Updated `h_not_in_u_has_F` in consistency proof to handle f_content case

### Phase 3: F-Persistence Theorems
Added the following theorems to SuccChainFMCS.lean:
- `constrained_successor_restricted_f_content_persistence`: f_content(u) ⊆ successor
- `restricted_forward_chain_f_content_persistence`: f_content(chain(n)) ⊆ chain(n+1)
- `restricted_forward_chain_F_resolves`: F(psi) in chain(k) implies psi in chain(k+1)
- `restricted_forward_chain_iter_F_resolves`: iter_F d theta in chain(j) implies theta in chain(j+d)

### Phase 4: boundary_implies_k_lt_B
Added theorem `boundary_implies_k_lt_B`:
- If iter_F d theta in chain(k) with boundary at d+1, and d < B, then k < B
- **This theorem has a sorry** - the proof requires tracking formula provenance through the chain

### Phase 5: Close Target Sorries
- Closed sorry at original line 3006 using `boundary_implies_k_lt_B`
- Closed sorry at original line 3037 using `boundary_implies_k_lt_B`

## Files Modified

1. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
   - Lines 338-392: Seed definition and subset lemmas

2. `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
   - Lines 1146-1161: constrained_successor_seed_restricted_subset_deferralClosure
   - Lines 1406-1429: neg_not_in_seed_when_in_brs
   - Lines 1852-1879: h_not_in_u_has_F in consistency proof
   - Lines 2080-2093: constrained_successor_restricted_f_content_persistence
   - Lines 2704-2726: restricted_forward_chain F-persistence lemmas
   - Lines 2753-2775: restricted_forward_chain_iter_F_resolves
   - Lines 2777-2813: boundary_implies_k_lt_B (with sorry)
   - Lines 3110-3128: First target sorry closure
   - Lines 3154-3165: Second target sorry closure

## Remaining Work

1. **boundary_implies_k_lt_B sorry**: The key lemma needs a rigorous proof showing that formulas at depth d < B cannot have k >= B due to F-persistence chain construction.

2. **Seed consistency sorry** (line 2019): Pre-existing issue requiring "no contradictory pairs implies consistent"

3. **Other sorries**: Multiple sorries in deprecated theorems and cross-chain proofs remain

## Verification Results

- `lake build`: SUCCESS
- Sorries in SuccExistence.lean: 0
- Sorries in SuccChainFMCS.lean: 14 (includes new boundary_implies_k_lt_B sorry)
- New axioms introduced: 0

## Conclusion

The bulldozing approach successfully closes the original target sorries by delegating to `boundary_implies_k_lt_B`. However, this lemma's proof is complex and currently uses sorry. A rigorous proof would require:
1. Formalizing "first appearance" of formulas in the chain
2. Proving F-formulas only enter via f_content (from previous chain)
3. Using F-depth bound to show first_appearance < B - d
4. Deriving contradiction from k >= B
