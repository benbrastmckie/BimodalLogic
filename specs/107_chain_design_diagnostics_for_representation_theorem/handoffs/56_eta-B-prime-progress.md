# Handoff: eta-in-B' Implementation Progress

## Status

- Sorry site 4 (eta in B'): CLOSED
- Sorry site 3 (lemma_2_7_seed_consistent): NOT STARTED
- Sorry site 1 (burgess_D0_finite_subset_consistent): NOT STARTED
- Sorry site 2 (burgess_D0_finite_subset_consistent_incons): NOT STARTED

## Key Achievement: Sorry Site 4 Closed

The proof of `eta in B'` in `lemma_2_7` was completed using a restructured approach
that bypasses the problematic consistency argument for `{eta} union B'`.

### Proof Strategy (Implemented)

Instead of using Zorn from B (which gives B' containing B but potentially not eta),
the proof uses Zorn from DC({eta}) directly:

1. **F(eta) in A**: From `untl(xi, eta) in A` + BX10 (until_implies_F_in_mcs)

2. **{eta} is consistent**: If eta were refutable (|- neg eta), then G(neg eta) would
   be in every MCS (temporal necessitation). But F(eta) = neg(G(neg eta)) in A
   contradicts G(neg eta) in A.

3. **snce(eta, alpha) in D for all alpha in A**: From the 5th seed component
   `snce(beta AND eta, alpha) in D` via left_mono_since with `|- (beta AND eta) -> eta`.

4. **untl(eta, delta) in A for all delta in D**: From step 3 via
   `burgessRSince_implies_burgessR`.

5. **burgessR3 A (DC({eta})) D**: For any phi in DC({eta}) (so |- eta -> phi):
   - Until direction: from untl(eta, delta) in A + left_mono gives untl(phi, delta) in A
   - Since direction: from snce(eta, alpha) in D + left_mono gives snce(phi, alpha) in D

6. **Zorn from DC({eta})**: `burgessR3Maximal_extension_exists` gives B' containing
   DC({eta}) with BurgessR3Maximal A B' D.

7. **eta in B'**: eta in DC({eta}) subset B'.

### Why This Avoids the Consistency Problem

The old approach needed `{eta} union B'` consistent (where B' extends B via Zorn).
If eta.neg in B, then eta.neg in B subset B', making {eta} union B' inconsistent.
The new approach sidesteps this entirely by using DC({eta}) as the Zorn seed,
which only requires {eta} consistent (always true when F(eta) in A).

The trade-off: B' no longer extends B. But the theorem only requires
`BurgessR3Maximal A B' D` with `eta in B'` (no B subset B' needed in the conclusion).

## Remaining Sorry Sites (3)

All three remaining sorries are about seed consistency using the Burgess compression
argument:

### Site 1 (line 1126): burgess_D0_finite_subset_consistent
- Hypothesis: BurgessR3Maximal(A, B, C), beta not in B, {beta}union B consistent
- Goal: SetConsistent (burgess_D0_seed A B C beta)
- Key: BX5+BX14+BX10 chain constructs F(zeta) in A where zeta implies any finite L subset D0

### Site 2 (line 1150): burgess_D0_finite_subset_consistent_incons  
- Hypothesis: BurgessR3Maximal(A, B, C), beta.neg in B
- Goal: SetConsistent (burgess_D0_seed A B C beta)
- Key: Simpler variant without BX14 step

### Site 3 (line 1586): lemma_2_7_seed_consistent
- Hypothesis: BurgessR3Maximal(A, B, C), g_content(A) subset C, untl(xi,eta) in A, eta not in B
- Goal: SetConsistent (lemma_2_7_seed A B C xi eta)
- Key: Same compression pattern as sites 1/2 but with additional snce(beta AND eta, alpha) component

## Infrastructure Available for Remaining Sites

- `derivation_from_implied` (line ~1061): List-level cut principle
- `untl_conj_guard` / `snce_conj_guard`: Guard conjunction for BX7
- `right_mono_until_mcs`: Event strengthening for Until
- `untl_left_mono_thm` / `snce_left_mono_thm`: Guard weakening
- `until_self_accum_in_mcs`: BX5 at MCS level
- `separation_until_mcs`: BX14 at MCS level
- `enrichment_until_mcs`: BX13 at MCS level
- `until_implies_F_in_mcs`: BX10 at MCS level
- `forward_temporal_witness_seed_consistent`: F(psi) -> {psi} union g_content consistent

The main gap for sites 1-3: building the compressed zeta from a finite L subset D0,
showing each element of L is derivable from [zeta], and applying the BX chain to show
F(zeta) in A (hence zeta consistent, hence L consistent via derivation_from_implied).
