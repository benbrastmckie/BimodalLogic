# Handoff: Phase 2 -- Strengthen lemma_2_7/2_8 with DC(B union {xi}) Seed

## Status: PARTIAL -- Until direction complete, Since direction blocked

## Session: sess_1778114001_749277

## Summary

Strengthened `lemma_2_7` and `lemma_2_8` in PointInsertion.lean to return `xi in B'` (guard in B') by using `DC(B union {xi})` as the Zorn seed instead of just `B`. All callers in CounterexampleElimination.lean updated. Build passes with 1097 jobs.

The Since mirrors (`lemma_2_7_since`, `lemma_2_8_since`) are blocked because the Since seed (`lemma_2_7_since_seed`) lacks the 5th component needed to derive `burgessR(A, xi, D)`.

## Completed Work

### lemma_2_7 (PointInsertion.lean:3616)

**Return type**: Added `xi in B'` as the 8th conjunct:
```lean
exists B' D B'' : Set Formula,
  BurgessR3Maximal A B' D and
  BurgessR3Maximal D B'' C and
  SetMaximalConsistent D and
  eta in D and
  B subset B' and
  B subset D and
  B subset B'' and
  xi in B'       -- NEW
```

**Proof changes** (Step 6 replaced):
1. `h_burgessR_conj`: for all beta in B, `burgessR(A, beta-and-xi, D)` via `burgessR_conj`
2. `h_until_conj`: for all beta in B, delta in D, `untl(beta-and-xi, delta) in A`
3. `h_r3_DC_ABD`: `burgessR3(A, DC({xi} union B), D)` via `dc_delta_B_burgessR3`
4. `h_DC_cons`: consistency of `{xi} union B` (contrapositive: if inconsistent, DC = univ, contradicting `not burgessR3 A Set.univ D`)
5. `h_DC_dcs`: `SetDeductivelyClosed (DC({xi} union B))` via `deductiveClosure_is_dcs`
6. Zorn from `DC({xi} union B)`: gives `DC({xi} union B) subset B'`
7. `xi in DC({xi} union B) subset B'`: gives `xi in B'`

### lemma_2_8 (PointInsertion.lean:4021)

Same approach. Added Steps 5b-5d (snce_conj_xi_D extraction, snce_xi_D derivation, burgessR_xi derivation) that lemma_2_7 already had, then the same Step 6 as lemma_2_7.

### Callers in CounterexampleElimination.lean

Updated 8 destructuring patterns (4 for lemma_2_7, 2 for lemma_2_8, plus 2 for lemma_2_7 with self-accumulation variant). Each gets a trailing `_` to discard the `xi in B'` component.

## Blocked Work: Since Mirrors (Task 2.8)

### Problem

The Since seed (`lemma_2_7_since_seed`) has only 4 components:
```
B union {eta} union {untl(beta,gamma) | beta in B, gamma in C} union {snce(beta,alpha) | beta in B, alpha in A}
```

The Until seed (`lemma_2_7_seed`) has a 5th component:
```
... union {snce(beta-and-xi, alpha) | beta in B, alpha in A}
```

The 5th component enables deriving `burgessRSince(D, xi, A)` -> `burgessR(A, xi, D)`, which is needed for `dc_delta_B_burgessR3`.

### Why the Since direction cannot simply use the existing seed

To get `burgessR(A, xi, D)` = `forall delta in D, untl(xi, delta) in A`, we need `burgessRSince(D, xi, A)` = `forall alpha in A, snce(xi, alpha) in D`. This requires `snce(xi, alpha) in D` for all alpha in A.

From the existing 4-component seed, D only has `snce(beta, alpha) in D` for beta in B. We cannot derive `snce(xi, alpha) in D` because left monotonicity goes the wrong direction: `snce(beta-and-xi, alpha) implies snce(beta, alpha)` (weakening), NOT `snce(beta, alpha) implies snce(beta-and-xi, alpha)` (strengthening).

### Solution: Add 5th component to Since seed

Add `{snce(beta-and-xi, alpha) | beta in B, alpha in A}` to `lemma_2_7_since_seed`, making it identical to `lemma_2_7_seed`.

The seed consistency proof (`lemma_2_7_since_seed_consistent`, ~300 lines) needs to be updated:
1. The `suffices h_key` statement already produces an event with `event -> untl(b-and-chi_gen, gamma)` where chi_gen = xi-and-snce(xi,eta). Since `b-and-chi_gen -> b-and-xi -> beta-and-xi`, the event implies `untl(beta-and-xi, gamma)`. So the `h_key` proof does NOT need modification.
2. The "Use h_key" part (guard extraction and L-element mapping, ~160 lines) needs a 5th case for `snce(beta-and-xi, alpha)` elements, analogous to the 4th case for `snce(beta, alpha)`.
3. The exhaustion case at the end needs the 5th disjunct.
4. The `h_seed_sub` lemma (`lemma_2_7_since_seed subset lemma_2_7_seed`) would need to be updated or removed since the seeds would be equal.

**Estimated effort**: 2-3 hours. The hardest part is ensuring the l27_ extraction helpers work with the 5th component in the Since direction, or inlining the extraction.

### Alternative approach

Instead of modifying the seed, derive `snce(beta-and-xi, alpha) in D` by showing it follows from `snce(xi, eta) in C` and the rest of the seed. This would require proving a non-trivial derived rule, which is harder than modifying the seed.

### Recommendation

Add the 5th component to `lemma_2_7_since_seed` and update the consistency proof. The approach is well-understood from the Until direction, and the `h_key` proof does not change.

Also update `lemma_2_8_since_seed_consistent` analogously.

## Key Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - `lemma_2_7`: return type + proof Steps 6-6e (lines ~3690-3738)
  - `lemma_2_8`: return type + proof Steps 5b-6 (lines ~4067-4125)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
  - 8 call sites updated (lines ~1036, 1059, 1064, 1066, 1260, 1286, 1289, 1293)

## Key Files NOT Modified (needed for Task 2.8)

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - `lemma_2_7_since_seed` (line ~4139): needs 5th component
  - `lemma_2_7_since_seed_consistent` (line ~4148): needs 5th case in "Use h_key"
  - `lemma_2_7_since` (line ~4461): needs Steps 5b-6 (same as lemma_2_7)
  - `lemma_2_8_since_seed_consistent` (line ~4434): same changes as 2_7_since
  - `lemma_2_8_since` (line ~4668): needs Steps 5b-6 (same as lemma_2_8)
  - Callers of lemma_2_7_since/2_8_since in CounterexampleElimination.lean (~6 sites)

## Convention Reminder

Our `untl(guard=xi, event=eta)` = Burgess `U(event=xi, guard=eta)`. SWAPPED.
Burgess 2.7: eta not-in B (guard not in B), result eta in B' (guard in B').
Our code: xi not-in B (guard not in B), result xi in B' (guard in B').
