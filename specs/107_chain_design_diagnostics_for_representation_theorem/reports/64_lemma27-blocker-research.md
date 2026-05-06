# Research Report: lemma_2_7 B ⊆ B' Gap for Guard Propagation

## 1. Burgess Construction vs Our Construction

### Burgess 2.7 (p.372)

**Statement**: Given R(A, B, C), U(xi, eta) in A, eta not in B. Then there exist B', D, B'' with eta in B', xi in D, R(A, B', D), R(D, B'', C), and **B = B' cap D cap B''**.

**Convention**: Burgess U(xi, eta) = our untl(eta, xi). Burgess xi = our eta (event), Burgess eta = our xi (guard). Arguments SWAPPED.

**Seed D0**: {S(alpha, beta and eta) : alpha in A, beta in B} union B union {xi} union {U(gamma, beta) : gamma in C, beta in B}

In our notation (swapping Burgess xi<->eta): {snce(beta and xi, alpha) : alpha in A, beta in B} union B union {eta} union {untl(beta, gamma) : gamma in C, beta in B}

**Post-consistency construction** (2.6 pattern, line 172): "let D be any MCS extending D0, and let B', B'' be maximal with respect to the properties **B subset B' and r(A, B', D)** and **B subset B'' and r(D, B'', C)** respectively."

Burgess constructs B' by extending **B** (not {eta} or DC({xi})) via Zorn maximality. Then B = B' cap D cap B'' by Lemma 2.5.

### How eta in B' follows from Burgess's construction

The 5th seed component S(alpha, beta and eta) (= our snce(beta and xi, alpha)) is the key. After extending D0 to MCS D:

1. snce(beta and xi, alpha) in D for all beta in B, alpha in A
2. This gives burgessRSince(D, beta and xi, A) for each beta in B
3. Via Lemma 2.3 backward: burgessR(A, beta and xi, D) for each beta in B
4. Since derivable beta and xi -> xi (right conjunct elim), by BX1 (guard left-mono): burgessR(A, xi, D)
5. Similarly: snce(xi, alpha) in D for all alpha in A, giving burgessRSince(D, xi, A)

With burgessR(A, xi, D) and burgessRSince(D, xi, A), **burgessR3(A, DC(B union {xi}), D)** holds via `dc_delta_B_burgessR3`:
- burgessR3(A, B, D) from the seed (steps 4-5 in existing code)
- For all beta in B, delta in D: untl(beta and xi, delta) in A (from burgessR(A, beta and xi, D))
- For all beta in B, alpha in A: snce(beta and xi, alpha) in D (from h_snce_conj_xi_D)

Zorn gives B' with DC(B union {xi}) subset B', hence **both B subset B' AND xi in B'**.

### Our Code (PointInsertion.lean:3616)

**Output type**:
```lean
exists B' D B'', BurgessR3Maximal A B' D and BurgessR3Maximal D B'' C and
  SetMaximalConsistent D and eta in D and xi in B'
```

**Zorn step (lines 3724-3728)**:
- B' seeded from **DC({xi})** (not DC(B union {xi})): gives xi in B' but NOT B subset B'
- B'' seeded from **B**: gives B subset B'' (correct)

**Deviation**: Code uses DC({xi}) instead of DC(B union {xi}). This was likely chosen to avoid needing `burgessR3(A, DC(B union {xi}), D)`, which requires the derivation chain through `dc_delta_B_burgessR3` and `burgessR(A, beta and xi, D)`.

## 2. The Fix: Seed B' from DC(B union {xi})

### Why DC(B union {xi}) works

We already have all the ingredients in the existing proof:

1. **h_r3_ABD** (line 3664): `burgessR3(A, B, D)` -- base r3 for the existing B
2. **h_snce_conj_xi_D** (line 3667): `forall beta in B, forall alpha in A, snce(beta and xi, alpha) in D` -- the 5th seed component
3. From (2): `burgessRSince(D, beta and xi, A)` for each beta in B
4. From (3) via `burgessRSince_implies_burgessR`: `burgessR(A, beta and xi, D)` for each beta in B
5. From (4): `forall beta in B, forall delta in D, untl(beta and xi, delta) in A`

Applying `dc_delta_B_burgessR3` with (1), (5), (2) gives:
```
burgessR3(A, DC({xi} union B), D)
```

### Consistency of B union {xi}

B union {xi} is provably consistent from the existing premises (no case split needed):

**Proof by contradiction**: If B union {xi} is inconsistent, there exists b in B with derivable not(b and xi). From `burgessR(A, b and xi, D)` (step 4 above) and the inconsistency of b and xi, by ex-falso propagation through BX2G (same argument as `burgessR3Maximal_with_guard` lines 1600-1667): `burgessR(A, phi, D)` for ALL phi, hence `burgessR3(A, Set.univ, D)`, contradicting `NoUnivBurgessR3`.

This means the entire `by_cases h_xi_cons` split (lines 3693-3806, ~110 lines) can be removed.

### Concrete Code Changes

**Step 1**: After step 5b (line 3670), add derivation of `burgessR(A, beta and xi, D)`:

```lean
-- Step 5e: burgessR(A, beta and xi, D) for each beta in B
have h_burgessR_conj_xi : forall beta, beta in B -> burgessR A (Formula.and beta xi) D := by
  intro beta hbeta
  have h_rSince : burgessRSince D (Formula.and beta xi) A :=
    h_snce_conj_xi_D beta hbeta
  exact burgessRSince_implies_burgessR h_mcs_A h_D_mcs h_rSince

-- Step 5f: Until condition for DC(B union {xi})
have h_until_conj : forall beta, beta in B -> forall delta, delta in D ->
    Formula.untl (Formula.and beta xi) delta in A := by
  intro beta hbeta delta hdelta
  exact h_burgessR_conj_xi beta hbeta delta hdelta
```

**Step 2**: Prove consistency of B union {xi}:

```lean
-- Step 6: B union {xi} is consistent (from burgessR + NoUnivBurgessR3)
have h_B_xi_cons : SetConsistent ({xi} union B : Set Formula) := by
  -- proof by contradiction: inconsistency implies burgessR3(A, Set.univ, D)
  <proof using h_burgessR_conj_xi and NoUnivBurgessR3>
```

**Step 3**: Build DC(B union {xi}) seed and apply Zorn:

```lean
-- Step 7: burgessR3(A, DC(B union {xi}), D) via dc_delta_B_burgessR3
have h_dc_B_xi_dcs : SetDeductivelyClosed (deductiveClosure ({xi} union B)) :=
  deductiveClosure_is_dcs h_B_xi_cons
have h_dc_B_xi_r3 : burgessR3 A (deductiveClosure ({xi} union B)) D :=
  dc_delta_B_burgessR3 h_mcs_A h_D_mcs h_B_dcs h_r3_ABD h_until_conj h_snce_conj_xi_D

-- Step 8: Zorn gives B' with DC(B union {xi}) subset B'
obtain <B', h_seed_sub_B', _, h_B'_max> := burgessR3Maximal_extension_exists h_mcs_A h_D_mcs
    h_dc_B_xi_dcs h_dc_B_xi_r3 h_no_univ_AD

-- Step 9: Extract B subset B' and xi in B'
have h_B_sub_B' : B subset B' :=
  fun phi hphi => h_seed_sub_B' (subset_deductiveClosure _ (Set.mem_union_right _ hphi))
have h_xi_B' : xi in B' :=
  h_seed_sub_B' (subset_deductiveClosure _ (Set.mem_union_left _ (Set.mem_singleton xi)))
```

**Step 4**: Change output type to include B subset B' (and optionally keep xi in B'):

```lean
exists B' D B'', BurgessR3Maximal A B' D and BurgessR3Maximal D B'' C and
  SetMaximalConsistent D and eta in D and B subset B' and xi in B'
```

Or, since callers don't use xi in B', simplify to:
```lean
exists B' D B'', BurgessR3Maximal A B' D and BurgessR3Maximal D B'' C and
  SetMaximalConsistent D and eta in D and B subset B'
```

**Step 5**: Update call sites in CounterexampleElimination.lean (5 sites) to destructure the new output. Since callers already discard `xi in B'`, this is minimal.

**Step 6**: Mirror for `lemma_2_7_since` (PointInsertion.lean:4483).

## 3. Why the Previous Approach Failed

The previous approach (my earlier report) proposed seeding B' from just B (without {xi}). This gives B subset B' but loses xi in B'. While xi in B' is unused by current callers, the Burgess-aligned construction with DC(B union {xi}) gives BOTH properties, matching Burgess exactly. The key insight I missed initially was that `dc_delta_B_burgessR3` provides the bridge: the 5th seed component `snce(beta and xi, alpha) in D` gives `burgessR(A, beta and xi, D)` for beta in B, which is exactly the `h_until_all` condition needed for `dc_delta_B_burgessR3`.

## 4. Summary of Required Changes

| File | Change | Lines |
|------|--------|-------|
| PointInsertion.lean | Add `h_burgessR_conj_xi` derivation | After 3670 |
| PointInsertion.lean | Prove `B union {xi}` consistent | Replace 3693 |
| PointInsertion.lean | Use `dc_delta_B_burgessR3` for DC(B union {xi}) | Replace 3694-3720 |
| PointInsertion.lean | Zorn from DC(B union {xi}) seed | Replace 3724 |
| PointInsertion.lean | Delete degenerate case | Delete 3735-3806 |
| PointInsertion.lean | Update output type | 3626-3631 |
| PointInsertion.lean | Mirror for lemma_2_7_since | ~4483 |
| CounterexampleElimination.lean | Update 5 call sites | ~986,1014,1018,1154,1180 |

**Net effect**: ~100 lines deleted (degenerate case), ~20 lines added (new derivation chain), output type gains `B subset B'`.

**Estimated effort**: 3-5 hours.

## 5. Impact on FUC/FSC

With B subset B' from lemma_2_7:
- When point z is inserted between x and y (g(x,y) = B):
  - g(x,z) = B' with B subset B' (from this fix)
  - f(z) = D with B subset D (from seed)
  - g(z,y) = B'' with B subset B'' (already correct)
- If guard in B (from enriched lemma_2_4, Phase 1 complete):
  - guard in B' (B subset B')
  - guard in D (B subset D)
  - guard in B'' (B subset B'')
- Lemma 2.5: B = B' cap D cap B'' (C3 identity holds)
- Guard propagates at every insertion step through the omega chain
- At the limit: guard in limit_g(x,y)

## 6. Key Files

- `PointInsertion.lean:3616` -- lemma_2_7 theorem
- `PointInsertion.lean:3667` -- h_snce_conj_xi_D (5th seed component, the crucial ingredient)
- `PointInsertion.lean:3724` -- B' Zorn seed (line to change)
- `PointInsertion.lean:659` -- dc_delta_B_burgessR3 (the bridge theorem)
- `RRelation.lean:760` -- burgessR3Maximal_extension_exists
- `RRelation.lean:591` -- burgessR3_absorption (Lemma 2.5)
- `CounterexampleElimination.lean:986-1180` -- call sites
- `ChronicleToCountermodel.lean:634,638` -- FUC/FSC sorry sites
- `literature/Burgess_1982.md:172-176` -- Burgess 2.6-2.7 construction
