# Handoff: Burgess D0 Seed Consistency Implementation

## Status

- `derivation_from_implied` helper lemma: PROVED (line ~1061)
- Sorry site 1 (line 1126): `burgess_D0_finite_subset_consistent` - NOT STARTED
- Sorry site 2 (line 1150): `burgess_D0_finite_subset_consistent_incons` - NOT STARTED
- Sorry site 3 (line 1586): `lemma_2_7_seed_consistent` - NOT STARTED
- Sorry site 4 (line 1659): `h_eta_B'` in `lemma_2_7` - NOT STARTED

## Key Helper Proved

`derivation_from_implied Gamma L psi h_derives d : DerivationTree Gamma psi`

Given:
- `h_derives : forall phi in L, DerivationTree Gamma phi`
- `d : DerivationTree L psi`

This is the list-level CUT principle. Proved by induction on L using deduction theorem + modus ponens.

## Mathematical Arguments

### Sorry Sites 1 & 2: D0 Seed Consistency

**Goal**: `SetConsistent (burgess_D0_seed A B C beta)` where D0 = B union {beta.neg} union untl-formulas union snce-formulas.

**Correct Proof Strategy** (Burgess 1982, p.370-371):

Given finite L subset D0 with d : L |- bot:
1. Extract ALL B-elements appearing in L (as base elements AND as guards in untl/snce formulas)
2. Form b = conjunction of all such elements (b in B since B is DCS)
3. Extract all gamma_i from untl-formulas, form gamma_hat = conjunction (in C since C is MCS)
4. Extract all alpha_j from snce-formulas, form alpha_hat = conjunction (in A since A is MCS)
5. Define zeta = b AND beta.neg AND untl(b, gamma_hat) AND snce(b, alpha_hat)
6. Show [zeta] |- l for each l in L:
   - For B-elements: zeta |- b (conjunct), b |- b_i (conj elimination)
   - For beta.neg: zeta |- beta.neg (conjunct)
   - For untl(beta'_i, gamma_i): from untl(b, gamma_hat) using:
     * left_mono with |- b -> beta'_i (conj elimination since b includes beta'_i)
     * right_mono with |- gamma_hat -> gamma_i (conj elimination)
   - For snce(beta'_j, alpha_j): from snce(b, alpha_hat) using:
     * snce_left_mono_thm with |- b -> beta'_j
     * snce right_mono (BX3') with |- alpha_hat -> alpha_j
7. Apply derivation_from_implied to get [zeta] |- bot
8. But zeta is consistent (proved via BX chain):
   - untl(b, gamma_hat) in A (from burgessR3 with b in B, gamma_hat in C)
   - BX5: untl(b AND untl(b,gamma_hat), gamma_hat) in A
   - BX14: untl(q, q AND r.neg) in A where q = b AND untl(b,gamma_hat), r = b AND beta
     (from h_neg_until_in_A: (untl(b AND beta, gamma_hat)).neg in A, obtained from
     (untl(beta0 AND beta, gamma0)).neg in A via left_mono contrapositive)
   - BX13: pack snce(q, alpha_hat) into event
   - BX10: F(event) in A
   - F_mono: F(zeta) in A (event implies zeta propositionally)
   - forward_temporal_witness_seed_consistent: {zeta} union g_content(A) consistent
   - SetConsistent_of_subset: {zeta} = [zeta] is consistent
9. Contradiction with [zeta] |- bot

**Implementation Challenges**:
- Step 6 requires building DerivationTree for conjunction elimination (propositional)
- Step 6 for untl/snce needs right_mono_since (BX3' at MCS level) - might need a new helper
- The snce right_mono needs G(alpha_hat -> alpha_j) in the target MCS? Actually BX3' (right_mono_since) takes G(event1 -> event2) so it needs the G in C? No - check the actual axiom. It should be analogous to right_mono_until.
- Step 8 for BX14: need to show (untl(b AND beta, gamma_hat)).neg in A. This follows from:
  * We have (untl(beta0 AND beta, gamma0)).neg in A (from maximality, already proved in the file for burgess_D0_seed_consistent at lines 1217-1221)
  * |- (b AND beta) -> (beta0 AND beta) (since |- b -> beta0, conjunction monotonicity)
  * Contrapositive of left_mono: if untl(b AND beta, gamma_hat) in A, then by left_mono with |- (b AND beta) -> (beta0 AND beta): untl(beta0 AND beta, gamma_hat) in A. But we also need right_mono to change gamma_hat to gamma0. Then: untl(beta0 AND beta, gamma0) in A. Contradiction.
  * So (untl(b AND beta, gamma_hat)).neg in A.
  * Actually more precisely: by contradiction. If untl(b AND beta, gamma_hat) in A, then:
    - left_mono with |- (b AND beta) -> (beta0 AND beta): untl(beta0 AND beta, gamma_hat) in A
    - right_mono with |- gamma_hat -> gamma0 (conj elim): untl(beta0 AND beta, gamma0) in A
    - Contradicts (untl(beta0 AND beta, gamma0)).neg in A (from maximality)
  * So untl(b AND beta, gamma_hat) not in A, hence its neg is in A.

**For the inconsistent case** (sorry site 2, beta.neg in B):
Same argument but simpler:
- D0 = B union untl union snce (beta.neg already in B)
- The conjunction b already includes beta.neg as a B-element
- BX14 needs neg-until from SOME beta0, gamma0. Use BurgessR3Maximal_extension_fails on eta = beta (or any formula not in B - but actually in the inconsistent case {beta} union B IS inconsistent, so we can't use that directly).
- Alternative for inconsistent case: from beta.neg in B, D0 subset B union A union C. Use a SIMPLER version of the BX chain without BX14.
- Actually: untl(beta.neg, gamma0) in A (from burgessR3 with beta.neg in B, gamma0 in C). BX5 gives self-accumulation. BX13 packs since formulas. BX10 gives F(event). No BX14 needed!

### Sorry Site 3: lemma_2_7_seed_consistent

Same structure as sites 1/2 but seed is:
B union {xi} union {untl(beta,gamma): beta in B, gamma in C} union {snce(beta,alpha): beta in B, alpha in A} union {snce(beta AND eta, alpha): beta in B, alpha in A}

The last component is the new addition. The proof follows the same pattern using:
- untl(xi, eta) in A as the starting point for the BX chain
- BX5: untl(xi AND untl(xi,eta), eta) in A
- BX14: untl(q, q AND r.neg) where r involves eta somehow
- BX13: packs snce-formulas including snce(beta AND eta, alpha)

### Sorry Site 4: eta in B'

**Goal**: eta in B' where BurgessR3Maximal(A, B', D).

**Correct Proof Strategy**:

By contradiction: assume eta not in B'.
1. Show {eta} union B' is consistent (needed for dc_delta_B_burgessR3 contradiction)
2. Show burgessR3(A, DC({eta} union B'), D) via dc_delta_B_burgessR3

For (2), need:
- h_until_all: forall beta' in B', forall delta in D, untl(beta' AND eta, delta) in A
- h_since_all: forall beta' in B', forall alpha in A, snce(beta' AND eta, alpha) in D

**Key facts available**:
- untl(eta, delta) in A for all delta in D (from seed: snce(beta AND eta, alpha) in D for beta in B, alpha in A; by snce_left_mono_thm with |- (beta AND eta) -> eta: snce(eta, alpha) in D for all alpha in A; by burgessRSince_implies_burgessR: untl(eta, delta) in A)
- untl(beta', delta) in A for all beta' in B', delta in D (from burgessR3(A, B', D))

**For h_until_all** (the hard part):
- From untl(eta, delta) in A AND untl(beta', delta) in A:
- BX7 (linear_until): (eta U delta) AND (beta' U delta) implies one of:
  * untl(eta AND beta', delta AND delta) in A
  * untl(eta AND beta', delta AND beta') in A
  * untl(eta AND beta', eta AND delta) in A
- In ALL cases: untl(eta AND beta', event) in A where event implies delta (by right_mono with conj elimination)
- So untl(eta AND beta', delta) in A (from right_mono)
- Then untl(beta' AND eta, delta) in A (by left_mono with conjunction commutativity)

**For h_since_all**: Mirror argument using:
- snce(eta, alpha) in D for all alpha in A (proved above)
- snce(beta', alpha) in D for all beta' in B', alpha in A (from burgessRSetSince(D, B', A))
- BX7' (linear_since) to combine
- Result: snce(beta' AND eta, alpha) in D

**For (1) {eta} union B' consistent**:
- If inconsistent: eta.neg in B' (neg_mem_of_inconsistent_union)
- From eta.neg in B' and burgessR3(A, B', D): untl(eta.neg, delta) in A for all delta in D
- From the seed structure + burgessRSince_implies_burgessR: untl(eta, delta) in A for all delta in D
- BX7 on (eta U delta) AND (eta.neg U delta): guard = eta AND eta.neg (inconsistent)
- All three BX7 cases give untl(eta AND eta.neg, something) in A
- BX10 on that: F(something) in A where something implies delta
- Need to show this gives a contradiction... 
- ALTERNATIVE: from untl(eta AND eta.neg, event) in A, use left_mono with |- (eta AND eta.neg) -> bot_proxy to get untl(bot_proxy, event) in A... not helpful
- SIMPLEST: actually F(eta) in A (from BX5 + BX10 on untl(xi, eta)). And {eta} union g_content(A) consistent (forward_temporal_witness_seed_consistent). And g_content(A) subset B subset B'. So {eta} union g_content(A) subset {eta} union B'. But superset of consistent != consistent.
- THIS IS THE HARDEST SUBGOAL. It may require showing that the Zorn construction can be modified to include eta from the start. See alternative approach below.

**Alternative approach for eta in B'**: Instead of proving eta in the EXISTING B' from `burgessR3Maximal_extension_exists`, MODIFY the Zorn input to use DC({eta} union B) as the base (if consistent + burgessR3 holds). This avoids the consistency problem:
1. Show {eta} union B consistent: from F(eta) in A + g_content(A) subset B + forward_temporal_witness argument. TRICKY - may need indirect argument.
2. If step 1 fails (eta.neg in B): then the seed gives snce(eta.neg AND eta, alpha) in D. By left_mono_since with |- (eta.neg AND eta) -> bot: snce(bot, alpha) in D? Not clear this helps.

## Recommended Implementation Order

1. **Site 4** (eta in B'): Most tractable. The BX7 argument for h_until_all and h_since_all is clean. The consistency part ({eta}∪B') needs careful handling.
2. **Sites 1 & 2** (D0 seed consistency): Requires the full compression. Consider implementing a shared helper that takes the BX chain output and produces the consistency result.
3. **Site 3** (lemma_2_7_seed): Similar to sites 1/2 but with additional snce(beta AND eta, alpha) components.

## Available Infrastructure

- `derivation_from_implied` (line ~1061): List-level cut principle
- `enrichment_until_mcs` (line ~988): BX13 at MCS level
- `separation_until_mcs` (line ~976): BX14 at MCS level
- `self_accum_until_mcs` (line ~1228 area): BX5 at MCS level
- `until_implies_F_mcs` (line ~1000): BX10 at MCS level
- `F_mono_mcs` (line ~1009): F-monotonicity
- `untl_left_mono_thm` (RRelation.lean): Guard weakening for Until
- `snce_left_mono_thm` (RRelation.lean): Guard weakening for Since
- `right_mono_until_mcs` (line ~918): Event strengthening for Until
- `dc_delta_B_burgessR3` (line ~583): Extension preserves burgessR3
- `BurgessR3Maximal_extension_fails` (line ~566): Maximality contradiction
- `neg_mem_of_inconsistent_union` (line ~661): Inconsistency gives neg in DCS
- `forward_temporal_witness_seed_consistent` (Bundle/WitnessSeed.lean): F(psi) -> {psi} union g_content consistent
- `burgessRSince_implies_burgessR` (RRelation.lean): Since -> Until direction
- `conj_mcs` (line ~210): Conjunction in MCS
- `SetMaximalConsistent.conjunction_intro` (Completeness.lean): phi in S, psi in S -> phi AND psi in S

## Missing Infrastructure (Needs Implementation)

1. `right_mono_since_mcs`: BX3' at MCS level (mirror of right_mono_until_mcs)
2. BX7 (linear_until) at MCS level: disjunction from two until formulas
3. BX7' (linear_since) at MCS level: disjunction from two since formulas
4. Conjunction elimination propositional derivation for iterated conjunctions (for the compression step)
5. `snce_right_mono_mcs` helper (if not already available)
