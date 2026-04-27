# Research Report: Task 107 -- Teammate D Findings

## The 2-Layer g-Value Architecture: Horizons

**Task**: 107 - Design the correct 2-layer g-value architecture
**Angle**: Horizons -- whether finite-stage g and limit g need to be connected
**Started**: 2026-04-26

## Executive Summary

The codebase already implements the correct 2-layer architecture. The two g-functions serve entirely independent purposes and do NOT need to be formally connected. Crucially, `rebuild_g` is unnecessary in its current form -- but not because it should be removed. Rather, the problem is that `rebuild_g` calls `burgessR3Maximal_exists_general` (which is FALSE for arbitrary MCS pairs), when the elimination functions already produce valid g-values with proper seeds. The fix is to thread the elimination-produced g-values through the omega chain instead of discarding and rebuilding them.

## Finding 1: Burgess Uses TWO Different g-Functions (Confirmed)

Reading Claim 2.11 (lines 238-248 of the transcription) carefully:

> "If alpha = U(beta, gamma). If alpha in f(x), then by C5a there is a y in X with x < y and **gamma in f(y) and beta in g(x,y)**. If z in X and x < z < y, then **by C3 we have g(x,y) subset f(z)**, whence beta in f(z)."

Burgess's truth lemma uses `g(x,y)` directly -- the limit g. The proof works as:
1. C5a gives a witness y with the event gamma in f(y) and the guard beta in **g(x,y)**
2. C3 gives g(x,y) subset f(z) for intermediate z, so beta in f(z)

In Burgess's paper, the limit g is obtained as the union of the finite-stage g values:
- Each finite-stage (f_n, g_n) is in script-F (satisfies C0-C3 including c2')
- The limit (f, g) = union of (f_n, g_n) also satisfies C0-C3
- C5 holds because counterexamples are eliminated at finite stages, and the elimination step 2.10 guarantees **both** the endpoint (eta in f(y)) AND the guard (eta in g(x,y))

So in Burgess, the finite-stage g and the limit g are connected by IMMUTABILITY: g-values assigned at stage n are never modified at later stages.

## Finding 2: The Codebase Breaks Immutability via rebuild_g

The codebase's omega chain (ChronicleConstruction.lean:307-315):

```
omega_chain A h_mcs (n+1) =
  let elim = eliminate_potential_counterexample prev pc
  rebuild_g elim.val elim.c0
```

After each elimination step, `rebuild_g` DISCARDS all existing g-values and reassigns them using `burgessR3Maximal_exists_general`. This breaks the immutability invariant:

1. **g-values from elimination are discarded**: The elimination functions (PointInsertion.lean) carefully construct g-values via `burgessR3Maximal_exists_from_seed` using proper temporal seeds. These g-values satisfy burgessR3 for the specific adjacent pairs involved. But `rebuild_g` throws them away.

2. **rebuild_g uses `burgessR3Maximal_exists_general` which is FALSE**: As documented in the v32 sorry analysis, `burgessR3Maximal_exists_general` claims to produce a BurgessR3Maximal set for ANY pair of MCS, which is false (the G(p)/neg(p) counterexample).

3. **The consequence**: Even if `burgessR3Maximal_exists_general` were fixed (restricted to temporal pairs), `rebuild_g` would produce DIFFERENT g-values at each stage, meaning the limit g (defined as the intersection in the codebase) would NOT equal the limit of the finite-stage g-values.

## Finding 3: The Codebase's limit_g is Already Correct for FUC

The codebase defines (ChronicleConstruction.lean:902-904):

```lean
noncomputable def limit_g (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat -> Rat -> Set Formula :=
  fun x z => { phi | forall y in limit_dom A h_mcs, x < y -> y < z -> phi in limit_f A h_mcs y }
```

This is the "intersection of all intermediate f-values" definition. It trivially satisfies:
- **C3** (limit_c3, already proved sorry-free): g(x,z) = g(x,y) inter f(y) inter g(y,z)
- **g(x,z) subset f(y)** for x < y < z (limit_c3_interval_subset_point, already proved)

For the FUC proof, what we need is:
- Given U(phi, psi) in f(x), find y > x with psi in f(y) and phi in f(z) for all z in (x,y) in the limit domain
- C5_weak already gives us the witness y with psi in f(y)
- What's missing: phi in g(x,y), which would give phi in f(z) by C3

## Finding 4: The Gap -- phi in limit_g(x,y) is NOT Guaranteed

The FUC sorry sites (ChronicleToCountermodel.lean:615, 619) need:

> Given U(phi, psi) in limit_f(x), there exists y with psi in limit_f(y) AND phi in limit_g(x,y)

The current `limit_satisfies_c5_weak` only gives the endpoint but NOT the guard. The guard requires phi in limit_g(x,y), which by the intersection definition means: phi in limit_f(z) for ALL z between x and y in the limit domain.

In Burgess, this works because:
1. The C5 elimination (Lemma 2.10) inserts y and sets g(x,y) = B where eta in B (the guard element)
2. This g-value is IMMUTABLE -- it persists to the limit
3. At the limit, g(x,y) (the Burgess limit) contains eta
4. C3 gives g(x,y) subset f(z) for intermediate z

In the codebase, even if we fix rebuild_g, the limit_g is defined as the intersection rather than the Burgess limit. So we need to prove that the intersection definition implies the guard property.

## Finding 5: The Two Layers CAN Be Independent (Key Architectural Insight)

Here is the critical insight: **we do NOT need the finite-stage g to equal the limit g**. We need two separate properties:

**Layer 1 (Finite-stage g + c2'): Used ONLY for C4 elimination**
- The C4 hard case (CounterexampleElimination.lean:343-433) uses `h_R3M := h_c2' w w_next h_adj`
- This gives BurgessR3Maximal(f(w), g(w, w_next), f(w_next)) for the adjacent pair (w, w_next)
- From this, `burgessR3_gamma_not_in_B` proves gamma not in g(w, w_next)
- Then gamma.neg is in some MCS extending g(w, w_next), giving the witness

**Layer 2 (limit_g = intersection): Used ONLY for FUC**
- limit_g(x,y) = {phi | forall z in limit_dom, x < z < y -> phi in limit_f(z)}
- C3 holds by construction
- FUC needs: phi in limit_g(x,y) when U(phi,psi) in limit_f(x) and psi in limit_f(y)

These layers serve completely different purposes. The question is whether Layer 2's requirement can be satisfied without connecting it to Layer 1.

## Finding 6: FUC Requires a New Proof Strategy

For Layer 2 (the FUC guard), we need to show:

> If U(phi, psi) in limit_f(x) and limit_satisfies_c5_weak gives witness y with psi in limit_f(y), then for ALL z in limit_dom with x < z < y, phi in limit_f(z).

This is equivalent to: phi in limit_g(x,y).

**Approach A: Prove guard from C4 contrapositive (BUC-style)**

This is exactly what the backward direction already uses! The backward Until/Since coherence (`cantor_bfmcs_restricted_buc`, ChronicleToCountermodel.lean:495-582) works by:
- Assume the semantic witness pattern holds (endpoint + guard at intermediate points)
- If neg(U(phi,psi)) in f(t), apply C4 to get guard violation -> contradiction

For the FORWARD direction, we need the reverse: U(phi,psi) in f(x) implies the semantic pattern. The issue is that C5_weak only gives the endpoint, not the guard.

**Approach B: Strengthen C5_weak to C5_full using the rRelation**

The elimination functions (Lemma 2.10) use `future_temporal_witness_seed_consistent` (from PointInsertion.lean) to construct the witness MCS C and interval set B. In Burgess:
- B satisfies r(A, B, C) where A = f(x), C = f(y)
- This means: for all gamma in C, untl(beta, gamma) in A for all beta in B
- In particular: eta in B (the guard element)

If the omega chain preserved the g-values from elimination (instead of rebuild_g discarding them), then:
- At stage n, g_n(x,y) = B with eta in B and burgessR3(f(x), B, f(y))
- At the limit, if g is immutable, g(x,y) still = B
- C3 gives B = g(x,y) subset f(z) for intermediate z

**Approach C: Prove directly that U(phi,psi) in f(x), psi in f(y), neg(phi) in f(z) for some z between x and y leads to contradiction**

If we could show this directly from BX axioms and MCS properties (without needing the finite-stage g), then limit_g would automatically contain phi. The argument would be:
- Suppose U(phi,psi) in f(x) and psi in f(y) and neg(phi) in f(z) for x < z < y
- Need: contradiction

But this does NOT work purely from BX axioms. U(phi,psi) at x means there exists a future point where psi holds and phi guards until then. But the witness y from C5_weak is a SPECIFIC y -- there could be intermediate points where phi fails between x and y, as long as the actual semantic witness is closer than z.

**Approach D: Use a DIFFERENT C5 witness -- the one with the guard built in**

Instead of using `limit_satisfies_c5_weak` and trying to prove the guard afterward, modify the omega chain to preserve guard information from the elimination step.

This requires:
1. NOT discarding g-values (remove `rebuild_g` from the omega chain)
2. The elimination step's g-values must be carried forward unchanged
3. At the limit, define limit_g as the union of finite-stage g values (Burgess's actual definition)
4. Prove that this Burgess limit_g satisfies C3

## Recommendation: Remove rebuild_g, Use Immutable g-values

### The Architecture

**Finite stages**: Each elimination function (C5, C5', C4, C4', density) already constructs proper g-values:
- C5/C5' elimination: Uses `burgessR3Maximal_exists_from_seed` with a temporal seed (the Until/Since obligation provides the seed). This IS valid because the seed carries the temporal connection.
- C4/C4' elimination: Uses the existing g-values from c2' (the adjacent pair's BurgessR3Maximal set). Inserts a point and splits the g-value using Lemma 2.6.
- Density: Inserts a midpoint, splits existing g-values.

The EliminationResult already has `g_ext: forall a b, val.g a b = chi.g a b` -- the g-values are PRESERVED unchanged. This is the immutability property.

**Omega chain without rebuild_g**:
```
omega_chain (n+1) = eliminate(omega_chain n, enum (unpair n).2)
```
No rebuild_g step. The c2' invariant is maintained because:
- Elimination preserves g on old pairs (g_ext)
- For new adjacent pairs created by point insertion, the elimination function assigns proper g-values

**Limit**: Define limit_g as the union:
```
limit_g(x,y) = omega_chain_val(n).g(x,y)  for the first n where both x,y in dom(n)
```
This is well-defined by immutability.

**But wait**: The current elimination functions set g_ext to preserve chi.g unchanged, which means new adjacent pairs created by insertion get chi.g values (typically empty for pairs not in the original domain). The actual g-values for new pairs are NOT stored in the EliminationResult.

This is the real issue: the elimination functions in the codebase are designed as "insert point, assign f-value, keep g unchanged, let rebuild_g handle g-values later." This design was built around rebuild_g.

### What Needs to Change

1. **Modify elimination functions** to assign proper g-values for new adjacent pairs:
   - C5 elimination (Lemma 2.10): When inserting y after x, set g(x,y) = B from `burgessR3Maximal_exists_from_seed`
   - C4 elimination (Lemma 2.9): When inserting z between w and w_next, set g(w,z) = B' and g(z,w_next) = B'' from Lemma 2.6 splitting
   - For non-adjacent old pairs that become split: define g by C3

2. **Remove rebuild_g** from the omega chain.

3. **Change limit_g** from intersection definition to union definition.

4. **Prove C5_full** at the limit: U(phi,psi) in limit_f(x) gives witness y with psi in limit_f(y) AND phi in limit_g(x,y).

### Alternatively: Keep the Intersection Definition

If we keep limit_g as the intersection (the current definition), we need to prove:

> For any C5 witness y (from limit_satisfies_c5_weak), phi in limit_f(z) for all z between x and y in limit_dom.

This requires showing that the elimination step's witness y has the property that ALL future density insertions between x and y will have phi in their f-value.

With immutable g and proper seeds, this follows from:
- At stage n, g_n(x,y) = B with phi in B
- At stage m > n, when a density point z is inserted between x and y, the new f(z) is constructed as an MCS extending g(x,y) (because B = g(x,z) inter f(z) inter g(z,y) by C3, so f(z) must contain B's elements)

But proving this requires the full Burgess machinery of C3 preservation through the chain.

## Finding 7: The `burgessR3Maximal_exists_general` Sorry is the Root Blocker

The sorry at RRelation.lean:1348 blocks `rebuild_g`, which blocks the omega chain's c2' invariant, which blocks C4 elimination at finite stages, which blocks limit_satisfies_c4, which blocks both BUC and limit_forward_G/backward_H.

However, `rebuild_g` is architecturally wrong (it discards good g-values and tries to construct new ones for arbitrary MCS pairs). The fix is NOT to prove `burgessR3Maximal_exists_general` -- it IS false. The fix is to restructure the omega chain to not need it.

The elimination functions already call `burgessR3Maximal_exists_from_seed` (for C5) which works because the seed has the proper temporal connection. And for C4, they use the existing c2' g-values. So the only consumer of `burgessR3Maximal_exists_general` is `rebuild_g`.

## Summary: The Correct Architecture

```
Layer 1: Finite-stage g (immutable, from elimination functions)
  - C5 elimination: g assigned via burgessR3Maximal_exists_from_seed
  - C4 elimination: g inherited from c2' and split via Lemma 2.6
  - Density: g split from parent interval
  - Invariant: c2' maintained by construction (NOT by rebuild)
  - Used by: C4 hard case proof

Layer 2: Limit g (defined as intersection OR union of finite-stage)
  - If union: equals the finite-stage g by immutability
  - If intersection: provably equal to the union for the relevant cases
  - Satisfies C3 by construction
  - Used by: FUC proof (guard at intermediate points)

Connection: NOT formally needed as a theorem. Both layers work
independently for their respective consumers. But the union definition
makes FUC straightforward, while the intersection definition requires
additional work.
```

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Restructuring elimination functions is invasive | High | Functions already have g_ext; need to extend, not rewrite |
| C3 preservation through chain is complex | Medium | Burgess's immutability handles this; just need g_ext to carry new pairs |
| The intersection limit_g may NOT equal the union | Medium | For FUC-relevant cases (C5 witnesses), they should agree |
| Removing rebuild_g breaks omega chain type | Low | omega_chain just needs c0; c2' comes from elimination directly |

## Concrete Next Steps

1. **Stop trying to prove `burgessR3Maximal_exists_general`** -- it is false and unnecessary
2. **Modify elimination functions** to output proper g-values for new adjacent pairs
3. **Remove `rebuild_g`** from the omega chain definition
4. **Add `c2'` to EliminationResult** (currently only `c0` is guaranteed)
5. **Prove C5_full** at the limit using immutable g-values
6. **Close the FUC sorries** using C5_full + C3

## Appendix: Burgess vs. Codebase Comparison

| Aspect | Burgess 1982 | Codebase |
|--------|-------------|----------|
| Finite g | Part of (f,g) pair in script-F | Discarded by rebuild_g |
| Limit g | Union of finite g_n | Intersection of f-values |
| C5 guard | Comes from g(x,y) via Lemma 2.10 | Missing (C5_weak only) |
| C4 uses | Adjacent c2' at finite stage | Same (when c2' not sorry-blocked) |
| g immutability | Yes (extension, not modification) | Broken by rebuild_g |
| burgessR3Maximal existence | Proved from seed (Lemma 2.4) | Claimed for all pairs (false) |
