# Teammate A Findings: Primary Approach Analysis (Xu 3.2.1/3.2.2)

## Key Findings

### 1. The Phase 2 blocker is resolved by Xu Lemma 3.2.1

The implementation agent attempted to use Xu Lemma 2.4 (base/minimal logic version), which only yields `r(A, top, D)` and `r(D, top, C)`. This is insufficient because `lemma_2_6_splitting` requires `B subset B'` where `R(A, B', D)`, which needs `r(A, B, D)` -- not merely `r(A, top, D)`.

However, the codebase targets **linear tense logic**, which includes BX5 (self_accum_until, Xu's axiom (7)), BX6 (absorb_until, Xu's axiom (9)), BX7 (linear_until, Xu's axiom (10)), and temp_4 (future transitivity). These are the axioms for Xu's transitive+left-connected case (Theorem 3.4, extending Theorem 3.2).

**Xu Lemma 3.2.1** (transitive case strengthening) states: If `R(A, B, C)` then:
- (i) `U(gamma, beta) in B` for all beta in B, gamma in C
- (ii) `S(alpha, beta) in B` for all beta in B, alpha in A

This is strictly stronger than Xu 2.3 (which only gives `U(gamma, top) in B` and `S(alpha, top) in B`). Crucially, 3.2.1 gives Until/Since formulas in B with **arbitrary guards from B**, not just top.

### 2. Xu 3.2.1 proof uses only BX5 + maximality (no BX14 needed)

The proof (Xu 1988, p.226-227) works by contradiction:

1. Assume `U(gamma, beta) not-in B` for some beta in B, gamma in C.
2. By R-maximality (Note 2.0(iii)): exists beta' in B, gamma' in C with `neg-U(gamma', beta' AND U(gamma, beta)) in A`.
3. Let beta'' = beta AND beta', gamma'' = gamma AND gamma'.
4. From R(A, B, C): `U(gamma'', beta'') in A` (since beta'' in B, gamma'' in C).
5. By BX5 (self_accum): `U(gamma'', beta'' AND U(gamma'', beta'')) in A`.
6. Derivable: `beta'' AND U(gamma'', beta'') -> beta' AND U(gamma, beta)` (via conjunction projections + left/right monotonicity).
7. By BX2G (right mono with G): `U(gamma'', beta'' AND U(gamma'', beta'')) -> U(gamma'', beta' AND U(gamma, beta))`.
8. By BX3 (left mono): `U(gamma'', beta' AND U(gamma, beta)) -> U(gamma', beta' AND U(gamma, beta))`.
9. So `U(gamma', beta' AND U(gamma, beta)) in A`, contradicting step 2.

The derivation at step 6 breaks down as:
- `beta'' -> beta` (left or right projection since beta'' = beta AND beta')
- `gamma'' -> gamma` (left projection since gamma'' = gamma AND gamma')
- `U(gamma'', beta'') -> U(gamma, beta'') -> U(gamma, beta)` by BX3 then BX2G
- Therefore `beta'' AND U(gamma'', beta'') -> beta' AND U(gamma, beta)`
- Then apply BX2G to get step 7, and BX3 for step 8

**Key infrastructure already in codebase:**
- `self_accum_until_mcs` (BX5 at MCS level) -- line 194
- `BurgessR3Maximal_extension_fails` (maximality contradiction) -- used in xu_lemma_2_3
- `right_mono_until_mcs` (BX3 at MCS level) -- line 1150
- `untl_left_mono_G` (BX2G at MCS level) -- used in xu_lemma_2_3
- `dc_delta_B_controlled` (extract beta0, gamma0 witnesses from maximality)

The proof pattern is structurally identical to the existing `xu_lemma_2_3_since_top` and `xu_lemma_2_3_until_top` proofs -- a contradiction argument using maximality. The only difference is the guard strengthening step uses BX5 instead of BX4+BX12.

### 3. Xu 3.2.2 gives a BX14-free replacement for `lemma_2_6_splitting`

With Xu 3.2.1 established, the Xu 3.2.2 splitting lemma works as follows:

Given: `r(A, B, C)`, `neg-U(gamma, beta) in A`, `gamma in C`.

1. **Get B-star**: B* with B subset B* and R(A, B*, C) (existing `burgessR3Maximal_extension_exists`).
2. **beta not-in B-star**: If beta in B*, then untl(gamma, beta) in A (from R(A,B*,C)), contradicting neg-untl(gamma, beta) in A.
3. **Seed consistency (TRIVIAL)**: Seed = B* union {neg-beta}. Since B* is a DCS and beta not-in B*, the DCS closure of B* does not contain beta, so neg-beta is consistent with B*. (No BX14 needed!)
4. **Lindenbaum**: D = MCS extending Seed. So B* subset D and neg-beta in D.
5. **r(A, B*, D) via 3.2.1(ii)**: S(alpha, beta') in B* for all beta' in B*, alpha in A (by 3.2.1). Since B* subset D, S(alpha, beta') in D. This is burgessRSetSince(D, B*, A). By burgessRSince_implies_burgessR: r(A, B*, D).
6. **r(D, B*, C) via 3.2.1(i)**: U(gamma', beta') in B* for all beta' in B*, gamma' in C (by 3.2.1). Since B* subset D, U(gamma', beta') in D. This is burgessRSet(D, B*, C). By burgessR_implies_burgessRSince: burgessR3(D, B*, C).
7. **Zorn**: B' supset-eq B* with R(A, B', D), B'' supset-eq B* with R(D, B'', C).
8. **Output**: B subset B* subset B', B subset B* subset D, B subset B* subset B''.

This produces the exact same output type as the current `lemma_2_6_splitting`:
```
exists B' D B'', BurgessR3Maximal A B' D AND BurgessR3Maximal D B'' C AND
  SetMaximalConsistent D AND beta.neg in D AND B subset D AND B subset B' AND B subset B''
```

### 4. Impact on the four BX14 usage sites

The current codebase uses `separation_until_mcs` (BX14) at 4 locations:

- **Site 1** (`burgess_zeta_consistent`, line 1629): Core of `burgess_D0_seed_consistent` for `lemma_2_6_splitting`. **ELIMINATED** -- the Xu 3.2.2 approach replaces the entire seed consistency proof with the trivial DCS argument.
- **Site 2** (line 2280, `lemma_2_6_splitting` internals): Part of the same seed consistency chain. **ELIMINATED** by the same replacement.
- **Site 3** (line 2480): Mirror case. **ELIMINATED**.
- **Site 4** (line 2693-2697): In another splitting context. Needs individual analysis but likely also replaced if it's part of the same seed consistency argument.

### 5. Required codebase changes

**New theorem** (`xu_lemma_3_2_1_until` and `xu_lemma_3_2_1_since`):
```
theorem xu_lemma_3_2_1_until {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    {beta : Formula} (h_beta : beta in B)
    {gamma : Formula} (h_gamma : gamma in C) :
    Formula.untl gamma beta in B

theorem xu_lemma_3_2_1_since {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    {beta : Formula} (h_beta : beta in B)
    {alpha : Formula} (h_alpha : alpha in A) :
    Formula.snce alpha beta in B
```

**Modified theorem** (`lemma_2_6_splitting`): Replace the Burgess D0 seed construction with the Xu 3.2.2 construction. The output type stays identical. The proof becomes:
1. Get B* (Zorn)
2. Show beta not-in B* (from neg-until in A)
3. MCS(B* union {neg-beta}) = D
4. Use 3.2.1 for r(A, B*, D) and r(D, B*, C)
5. Zorn for B' and B''

## Recommended Approach

**Implement Xu 3.2.1 then replace `lemma_2_6_splitting` with Xu 3.2.2.**

This is the cleanest path because:
1. Xu 3.2.1 follows the same proof pattern as the existing `xu_lemma_2_3_since_top` (contradiction via maximality).
2. The seed consistency becomes trivial (DCS + element-not-in → extension consistent), eliminating the complex BX5+BX14+BX10 chain in `burgess_zeta_consistent`.
3. The output type of `lemma_2_6_splitting` stays identical, so **no changes needed in CounterexampleElimination.lean**.
4. All 4 BX14 usage sites in `lemma_2_6_splitting` are eliminated at once.

**Estimated implementation effort**: Medium. The new theorem (3.2.1) is ~50-80 lines following the pattern of `xu_lemma_2_3_since_top`. The replacement `lemma_2_6_splitting` is simpler than the current version (shorter proof, no `burgess_zeta_consistent` machinery).

## Evidence/Examples

**Xu 1988 Lemma 3.2.2** (p.227, lines 232-234 of literature file): Explicitly states `B subset B' intersect D intersect B''` and proves it using 3.2.1 and 2.1. The proof is 4 lines.

**Current `lemma_2_6_splitting`** (PointInsertion.lean line 2930-2979): Already achieves the same output using the elaborate D0 seed with BX14. The Xu 3.2.2 approach replaces the ~900-line seed consistency infrastructure (lines 1080-1920) with ~100 lines.

**Codebase axiom availability** (confirmed):
- BX5 = `Axiom.self_accum_until` (Axioms.lean line 221)
- `self_accum_until_mcs` helper (PointInsertion.lean line 194)
- `BurgessR3Maximal_extension_fails` (used in xu_lemma_2_3, line 709)
- `dc_delta_B_controlled` (extracts maximality witnesses)
- `burgessR_implies_burgessRSince` and `burgessRSince_implies_burgessR` (Lemma 2.1/2.3 equivalence)

## Confidence Level

**High (90%)**. The mathematical argument is sound and verified against both Xu 1988 and Burgess 1982. All required infrastructure (BX5, maximality, Lemma 2.1/2.3 equivalence, Zorn extension) exists in the codebase. The main risk is in the derivation at step 6 of Xu 3.2.1's proof, which requires composing BX5, BX2G, and BX3 -- but each of these has MCS-level helpers already available. The output type is identical to the current implementation, so downstream callers are unaffected.

The 10% uncertainty is for: (a) potential issues with the `dc_delta_B_controlled` interface when extracting the maximality witness for 3.2.1, and (b) the possibility that the seed consistency argument for `B* union {neg-beta}` requires more work than "trivial" due to codebase-specific DCS properties.
