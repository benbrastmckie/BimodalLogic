# Handoff: Guard-in-B Fix for FUC/FSC Sorries (Task 107)

Session: sess_1778014444_dca927

## Status: PARTIAL (Phase 1 of 4 complete)

## Root Cause Analysis (CONFIRMED)

The 2 remaining sorries in `ChronicleToCountermodel.lean:634,638` block forward
Until/Since coherence (`cantor_bfmcs_restricted_fuc`). The root cause:

1. `lemma_2_4` calls `burgessR3Maximal_from_g_content_sub` which seeds B with
   `DC({top})` where top = bot.imp bot
2. This does NOT guarantee guard (gamma) in B
3. Without guard in B, the g-value g(t,s) = B lacks the guard formula
4. At the limit level, `limit_g(t,s) = {phi | forall y in limit_dom, t < y < s -> phi in limit_f(y)}`
5. Without guard in limit_g(t,s), we cannot prove guard at intermediate points

## Work Completed

### Phase 1: `burgessR3Maximal_with_guard` (RRelation.lean) -- DONE, BUILDS

Added theorem at line ~1582 of `RRelation.lean`:

```lean
theorem burgessR3Maximal_with_guard (A C : Set Formula) (eta : Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_burgessR : burgessR A eta C)
    (h_burgessRSince : burgessRSince C eta A)
    (h_nubr3 : NoUnivBurgessR3) :
    exists B : Set Formula, eta in B /\ BurgessR3Maximal A B C
```

Key innovations in this proof:
- Does NOT require `eta in A` (unlike `burgessR3Maximal_exists_from_seed`)
- Consistency of `{eta}` is derived from `burgessR(A, eta, C) + NoUnivBurgessR3`:
  - If eta inconsistent (derives bot), then by BX2G (left mono under G), all formulas
    satisfy burgessR, giving `burgessR3(A, Set.univ, C)`, contradicting NoUnivBurgessR3
- Uses Zorn on `DC({eta})`, with `eta in DC({eta}) subset B`

## Remaining Work

### Phase 2: Modify `lemma_2_4` (PointInsertion.lean)

**Change output type** from:
```lean
exists B C, SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\
  some_past(untl gamma beta) in C /\ BurgessR3Maximal A B C
```
to:
```lean
exists B C, SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\
  some_past(untl gamma beta) in C /\ gamma in B /\ BurgessR3Maximal A B C
```

**Required seed change**: The seed C0 must include `{snce(gamma, alpha) : alpha in A}` in
addition to `{beta} union g_content(A)`. This ensures `burgessRSince(C, gamma, A)` holds
for the constructed C, which (via Lemma 2.3) gives `burgessR(A, gamma, C)`.

**Enriched seed consistency proof strategy**:
For any finite L subset C0_enriched with L derives bot:
1. L contains at most: beta, some phi_j in g_content(A), some snce(gamma, alpha_i) with alpha_i in A
2. By iterated BX13 enrichment: `untl(gamma, beta and snce(gamma, alpha_1) and ... and snce(gamma, alpha_n)) in A`
3. By BX3 right mono + G(phi_j) in A: fold g_content formulas into the event
4. By BX10: `F(big_conjunction) in A`
5. By generalized temporal K (existing infrastructure): L consistent

This mirrors `forward_temporal_witness_seed_consistent` but with BX13 enrichment folded in.
The iterated enrichment infrastructure already exists (`iterated_enrichment` at line ~1388).

**After constructing C from enriched seed**:
- `burgessRSince(C, gamma, A)` from seed membership (snce(gamma, alpha) in C for all alpha in A)
- `burgessR(A, gamma, C)` from `burgessR_implies_burgessRSince` backward (Lemma 2.3)
  - Actually: use `burgessRSince_implies_burgessR` (the converse direction)
- Apply `burgessR3Maximal_with_guard` with eta = gamma

### Phase 3: Update callers of `lemma_2_4`

`lemma_2_4` is called at:
- `CounterexampleElimination.lean:670` (C5 forward case n=0)
- Possibly other locations in the same file for C5 cases

Each caller destructures `lemma_2_4`'s output. Adding `gamma in B` requires updating
the pattern match. The callers set `g(t,s) = B`, so `gamma in B = gamma in g(t,s)`.

### Phase 4: Prove guard propagation and close FUC sorries

**Option A (structural)**: Thread `guard in g(t,s)` through the omega chain:
- Add a lemma: for all n >= n0 and all y in dom_n with t < y < s, guard in f_n(y)
- This follows from BurgessR3Maximal splitting: when y is inserted between t and s,
  Lemma 2.5 absorption gives B = B' inter D inter B'', so B subset D, hence guard in D = f(y)
- At the limit: guard in limit_g(t,s) follows

**Option B (direct at limit)**: Prove `limit_satisfies_c5_full`:
```lean
theorem limit_satisfies_c5_full (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_nubr3 : NoUnivBurgessR3)
    (x : Rat) (hx : x in limit_dom A h_mcs h_nubr3)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta in limit_f A h_mcs h_nubr3 x) :
    exists y in limit_dom A h_mcs h_nubr3, x < y /\ eta in limit_f A h_mcs h_nubr3 y /\
      xi in limit_g A h_mcs h_nubr3 x y
```

Then in `cantor_bfmcs_restricted_fuc`:
- Use `limit_satisfies_c5_full` (gives endpoint + guard in limit_g)
- `limit_g(t,s) subset limit_f(r)` for all r between t and s (from `limit_c3_interval_subset_point`)
- Transfer through Cantor isomorphism (same pattern as existing restricted_tc proof)

## Convention Reference

- Our `untl(gamma, beta)` = Burgess `U(beta, gamma)`. gamma = guard (1st arg), beta = event (2nd arg)
- `burgessR(A, beta, C)` = forall delta in C, untl(beta, delta) in A
- `burgessRSince(C, beta, A)` = forall alpha in A, snce(beta, alpha) in C
- `g_content(A)` = {phi | all_future(phi) in A}
- `limit_g(x,z)` = {phi | forall y in limit_dom, x < y < z -> phi in limit_f(y)}

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- added `burgessR3Maximal_with_guard`

## Build Status

`lake build` passes with the change. The 2 original sorries remain (unchanged).
No new sorries introduced.
