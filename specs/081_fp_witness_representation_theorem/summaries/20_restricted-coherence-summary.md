# Implementation Summary: Task #81

**Completed**: 2026-04-02
**Duration**: ~4 hours

## Changes Made

Refactored the completeness proof architecture to use restricted temporal coherence
instead of full temporal coherence. The restricted approach only requires forward_F
and backward_P for formulas within `deferralClosure(root)`, which is sufficient for
the truth lemma when evaluating formulas in `subformulaClosure(root)`.

### Key Innovation

The truth lemma's G/H backward cases invoke `forward_F` on `neg(psi)` where `G(psi)`
is a subformula of the root formula. Since `neg(psi) in closureWithNeg(root) subset
deferralClosure(root)`, restricted coherence suffices. This insight decouples the
completeness proof from the intractable problem of proving forward_F for ALL formulas
in a full MCS chain.

### Architecture

```
completeness_over_Int
  -> restricted_bundle_validity_implies_provability
       -> restricted_shifted_truth_lemma (SORRY-FREE)
       -> bfmcs_restricted_temporally_coherent
            -> shifted_restricted_forward_F (SORRY-FREE)
            -> succ_chain_restricted_forward_F (SORRY)
            -> succ_chain_restricted_backward_P (SORRY)
```

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
  - Added `BFMCS.restricted_temporally_coherent`: restricted coherence predicate
  - Added `restricted_temporal_backward_G`: backward G with restricted forward_F
  - Added `restricted_temporal_backward_H`: backward H with restricted backward_P
  - Added `BFMCS.temporally_coherent_implies_restricted`: full implies restricted

- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
  - Added `restricted_shifted_truth_lemma`: truth lemma with restricted coherence
  - Added import for `SubformulaClosure`

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Added `succ_chain_restricted_forward_F` (SORRY): restricted forward_F for SuccChainFMCS
  - Added `succ_chain_restricted_backward_P` (SORRY): restricted backward_P for SuccChainFMCS
  - Added `shifted_restricted_forward_F`: shifting preserves restricted forward_F
  - Added `shifted_restricted_backward_P`: shifting preserves restricted backward_P

- `Theories/Bimodal/FrameConditions/Completeness.lean`
  - Added `bfmcs_restricted_temporally_coherent`: BFMCS restricted coherence
  - Added `restricted_bundle_validity_implies_provability`: restricted completeness
  - Updated `completeness_over_Int` to use restricted path

## Verification

- Build: Success (938 jobs, zero new errors)
- `restricted_shifted_truth_lemma`: Verified sorry-free
- `restricted_temporal_backward_G`: Verified sorry-free
- `restricted_temporal_backward_H`: Verified sorry-free
- Sorry count in Completeness.lean: Unchanged (2: dense + original)
- New sorries: 2 in UltrafilterChain.lean (succ_chain_restricted_forward_F, succ_chain_restricted_backward_P)

## Notes

### Remaining Sorries

The two new sorry-bearing lemmas (`succ_chain_restricted_forward_F` and
`succ_chain_restricted_backward_P`) are strictly more precise than the original
`bfmcs_from_mcs_temporally_coherent` sorry:

- **Old sorry**: Prove full temporal coherence (forward_F/backward_P for ALL formulas)
  for all families in the BFMCS
- **New sorry**: Prove restricted forward_F/backward_P for a SINGLE SuccChainFMCS,
  only for formulas in `deferralClosure(root)`

### Why the New Sorry is Hard

In a full MCS, `F(psi) in MCS` implies `F^k(psi) in MCS` for all k (by the
T-axiom for G applied contrapositively). So the F-nesting bound argument that
works for the restricted DRM chain does NOT apply to the full MCS chain.

### Potential Approaches to Close

1. Build a dovetailed chain with forced F-resolution via fair scheduling
2. Use ultrafilter-level arguments (R_G accessibility in Lindenbaum algebra)
3. Prove that the Succ relation's f_step with constrained_successor eventually
   forces resolution (requires showing G(neg(psi)) cannot enter the chain before
   F(psi) is resolved)

### FMP Sorries

FMP TruthPreservation sorries are deferred to task 82 as specified.
