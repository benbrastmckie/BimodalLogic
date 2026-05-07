# Handoff: Phase 2 Task 2.8 -- Since Seed 5th Component Analysis

## Status: NOT STARTED (research complete, approach identified)

## Session: sess_1778114001_749277

## Summary

Deep analysis of the Since seed consistency proof reveals that the 5th component must be `{untl(beta AND xi, gamma) : beta in B, gamma in C}` (NOT `{snce(beta AND xi, alpha)}` as the previous handoff suggested). This is because the BX13' enrichment in C produces untl formulas, not snce formulas. The result is `xi in B''` (not `xi in B'`), which is correct for the Since direction.

## Key Finding: The Previous Handoff Was Partially Wrong

The previous handoff (`64_phase2-lemma27.md`) recommended adding `{snce(beta AND xi, alpha) | beta in B, alpha in A}` as the 5th component to the Since seed. This is mathematically IMPOSSIBLE to prove consistent because:

1. The BX5'+BX7'+BX13' chain (Since direction, operating in C) produces untl formulas via enrichment, NOT snce formulas.
2. The only snce output from the event is `event -> snce(b, alpha_hat)` from the base event.
3. Left monotonicity of snce goes from STRONGER guard to WEAKER: `snce(beta AND xi, alpha) -> snce(beta, alpha)`, NOT the reverse.
4. There is NO derivation rule that produces `event -> snce(beta AND xi, alpha)` from `event -> snce(b, alpha_hat)` when `b` does not imply `xi`.

## Correct Approach: Use untl(beta AND xi, gamma) as 5th Component

### Burgess Paper Analysis

In Burgess 1982, the Until seed D0 for Lemma 2.7 is:
```
{S(alpha, beta AND eta)} union B union {xi} union {U(gamma, beta)}
```
where eta is Burgess's guard (= our xi), xi is Burgess's event (= our eta).

The Since mirror (obtained by swapping U<->S, A<->C) gives:
```
{U(gamma, beta AND eta)} union B union {xi} union {S(alpha, beta)}
```

In our convention:
- `U(gamma, beta AND eta)` = `untl(beta AND xi, gamma)` (the 5th component)
- `S(alpha, beta)` = `snce(beta, alpha)` (the 4th component)

So the Burgess-correct Since seed is:
```
B union {eta} union {untl(beta, gamma)} union {snce(beta, alpha)} union {untl(beta AND xi, gamma)}
```

### Why untl(beta AND xi, gamma) Works in the Consistency Proof

The h_key suffices produces:
```
event -> untl(b AND chi_gen, gamma) for gamma in gamma_list
```
where `chi_gen = xi AND snce(xi, eta)` and the enrichment guard contains both `b` and `chi_gen`.

For a 5th component element `untl(beta' AND xi, gamma')`:
- `b AND chi_gen -> beta' AND xi` (since `b -> beta'` and `chi_gen -> xi`)
- Left mono: `untl(b AND chi_gen, gamma') -> untl(beta' AND xi, gamma')`
- So `event -> untl(beta' AND xi, gamma')` via composition

This works because the enrichment (BX13') produces untl formulas, and the guard of the enrichment contains xi information via chi_gen.

### Result: xi in B'' (not B')

In `lemma_2_7_since`:
- `BurgessR3Maximal(A, B', D)` -- B' between A and D
- `BurgessR3Maximal(D, B'', C)` -- B'' between D and C

The Since formula `snce(xi, eta) in C` operates on C. By symmetry with the Until direction (where the Until formula in A gives xi in B'), the guard goes into the C-side interval: xi in B''.

The chain for xi in B'':
1. From seed: `untl(beta AND xi, gamma) in D` for beta in B, gamma in C
2. Left mono: `untl(xi, gamma) in D` for all gamma in C (burgessR(D, xi, C))
3. `burgessR_implies_burgessRSince`: burgessRSince(C, xi, D) = for all delta in D, snce(xi, delta) in C
4. From seed (comp 3+4): burgessR3(D, B, C)
5. Guard conjunction: burgessRSince(C, beta, D) AND burgessRSince(C, xi, D) -> burgessRSince(C, beta AND xi, D)
6. `dc_delta_B_burgessR3(D, C, B, r3_DBC, h_untl_conj, h_snce_conj)`:
   - h_untl_conj: for all beta in B, gamma in C, untl(beta AND xi, gamma) in D -- from seed 5th component
   - h_snce_conj: for all beta in B, delta in D, snce(beta AND xi, delta) in C -- from step 5
   - Result: burgessR3(D, DC(B union {xi}), C)
7. Zorn from DC(B union {xi}): B'' with DC(B union {xi}) subset B''
8. xi in DC(B union {xi}) subset B''

### Downstream Compatibility

For Phase 5 (Since cases in CounterexampleElimination.lean): when splitting at a point in the backward direction, the guard needs to be in B'' (the g-value adjacent to C = f(x')), NOT B'. So `xi in B''` is the correct result.

## Implementation Plan

### Step 1: Modify lemma_2_7_since_seed

Change signature from `(A B C : Set Formula) (eta : Formula)` to `(A B C : Set Formula) (xi eta : Formula)`.

Add 5th component `{untl(beta AND xi, gamma) | beta in B, gamma in C}`:
```lean
private def lemma_2_7_since_seed (A B C : Set Formula) (xi eta : Formula) : Set Formula :=
  B union {eta} union {phi | exists beta in B, exists gamma in C, phi = Formula.untl beta gamma} union
  {phi | exists beta in B, exists alpha in A, phi = Formula.snce beta alpha} union
  {phi | exists beta in B, exists gamma in C, phi = Formula.untl (Formula.and beta xi) gamma}
```

### Step 2: Update lemma_2_7_since_seed_consistent

Key changes to the "Use h_key" extraction section:

1. **h_seed_sub**: Components 1-4 map into `lemma_2_7_seed`. Component 5 does NOT map (untl(beta AND xi, gamma) is not in lemma_2_7_seed when xi not in B).

2. **List construction**: Split L into L_14 (components 1-4, processed by l27_ helpers) and L_5 (component 5, processed manually). Merge the extracted lists.

   For L_14: use existing l27_ helpers with `L_14 = L.filter (not comp5)`.
   For L_5: extract beta' via `Classical.choose` (Formula.and is not a constructor, so pattern matching doesn't work). Extract gamma' similarly.
   
   Merge: `b_list = beta0 :: (b_list_raw ++ b5_list)`, `c_list = c_list_raw ++ c5_list`.

3. **Case split**: Add 5th case for `untl(beta' AND xi, gamma')`:
   ```
   -- beta' in b_list -> b -> beta'
   -- gamma' in c_list -> h_ev_untl gamma'
   -- b AND chi_gen -> beta' AND xi (b -> beta', chi_gen -> xi)
   -- untl(b AND chi_gen, gamma') -> untl(beta' AND xi, gamma')
   ```

4. **Exhaustion**: Update to handle 5 disjuncts:
   ```
   rcases h_phi_seed with ((((h1 | h2) | h3) | h4) | h5)
   ```

5. **DCS argument for case 1 vs 5 disambiguation**: When phi in B, show it's NOT in component 5 by: if `phi = untl(beta' AND xi, gamma')` and `phi in B`, then `beta' AND xi in B` (untl's first arg), so `xi in B` via DCS closure, contradicting `xi not in B`.

### Step 3: Update lemma_2_8_since_seed_consistent

Same changes as Step 2, applied to the lemma_2_8 variant (which uses the same seed but with a different hypothesis: neg_disj instead of xi not in B).

### Step 4: Update lemma_2_7_since

Change return type to include `xi in B''`:
```lean
exists B' D B'' : Set Formula,
  BurgessR3Maximal A B' D and
  BurgessR3Maximal D B'' C and
  SetMaximalConsistent D and
  eta in D and
  B subset B' and
  B subset D and
  B subset B'' and
  xi in B''  -- NEW
```

Add Steps 5b-6 (same pattern as lemma_2_7's strengthening but for B''):
- Step 5b: Extract `untl(beta AND xi, gamma) in D` from 5th seed component
- Step 5c: Derive `untl(xi, gamma) in D` via left_mono (burgessR(D, xi, C))
- Step 5d: burgessR_implies_burgessRSince -> burgessRSince(C, xi, D)
- Step 5e: Guard conjunction with burgessRSince(C, beta, D) -> burgessRSince(C, beta AND xi, D)
- Step 6: dc_delta_B_burgessR3(D, DC(B union {xi}), C) 
- Step 6b: DC(B union {xi}) is DCS (same argument as lemma_2_7)
- Step 6c: Zorn from DC(B union {xi}) for B'' with xi in B''

### Step 5: Update lemma_2_8_since

Same changes as Step 4.

### Step 6: Update callers in CounterexampleElimination.lean

For each caller of lemma_2_7_since and lemma_2_8_since (6 sites), add trailing `_` to destructure the new `xi in B''` component. The callers currently destructure as:
```
obtain <B', D, B'', hB', hB'', hD, heta, h_B_sub_B', h_B_sub_D, h_B_sub_B''> := lemma_2_7_since ...
```
Change to:
```
obtain <B', D, B'', hB', hB'', hD, heta, h_B_sub_B', h_B_sub_D, h_B_sub_B'', _> := lemma_2_7_since ...
```

Note: the destructuring order differs between lemma_2_7_since and lemma_2_8_since (check which has B subset D before/after B subset B').

### Step 7: Verify build

Run `lake build` and verify 0 new sorries, 0 new axioms.

## Estimated Effort

- Step 1: 5 minutes (trivial definition change)
- Step 2: 2-3 hours (hardest part -- list construction with l27_ helpers and 5th case)
- Step 3: 1-2 hours (mirror of Step 2)
- Steps 4-5: 1-2 hours (straightforward, follows lemma_2_7 pattern)
- Step 6: 30 minutes (mechanical caller updates)
- Step 7: 15 minutes

Total: 5-8 hours

## Key Infrastructure

- `burgessR_conj` (RRelation.lean:1065) -- Phase 1 result, Until guard conjunction
- `burgessRSince_conj` (RRelation.lean:1080) -- Phase 1 result, Since guard conjunction
- `dc_delta_B_burgessR3` (PointInsertion.lean:659) -- DC extension of B preserves R3
- `burgessR_implies_burgessRSince` (RRelation.lean:1294) -- R <-> RSince conversion
- `burgessRSince_implies_burgessR` (RRelation.lean:1352) -- RSince <-> R conversion
- `l27_collect_guards`, `l27_c_event_list`, `l27_a_event_list` -- list extraction helpers for lemma_2_7_seed
- `combine_imp_conj` -- combine two implications into conjunction implication

## Convention Reminder

Our `untl(guard=xi, event=eta)` = Burgess `U(event=xi, guard=eta)`. SWAPPED.
Our `snce(guard=xi, event=eta)` = Burgess `S(event=eta, guard=xi)`. SWAPPED.
Burgess 2.7: eta not-in B (guard not in B), result eta in B' (guard in B').
Our code: xi not-in B (guard not in B).
- Until direction: result xi in B' (guard in B', the A-side interval)
- Since direction: result xi in B'' (guard in B'', the C-side interval)
