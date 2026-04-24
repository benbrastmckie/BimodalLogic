# Phase 1 Handoff: g_content_chain_property

## Session: sess_1777066378_e57207
## Date: 2026-04-24

## What Was Done

### Sorry-free progress
1. **limit_c1_at_domain** closed (was sorry): deductiveClosure(g_content(limit_f(x))) is a DCS because g_content of an MCS is consistent (g_content_set_consistent) and deductiveClosure of a consistent set is a DCS (deductiveClosure_is_dcs).

2. **g_content_sub_imp_h_content_sub** NEW lemma (sorry-free): For MCS A, B: g_content(A) subset B implies h_content(B) subset A. Proof by contradiction using BX4 (connect_future) and DNI propagation through H via past_necessitation + past_k_dist.

3. **h_content_sub_imp_g_content_sub** NEW lemma (sorry-free): Dual direction. For MCS A, B: h_content(B) subset A implies g_content(A) subset B. Uses BX4' (connect_past) and DNI propagation through G via temporal_necessitation + temp_k_dist.

4. **limit_backward_H** restructured: Now proved from g_content_chain_property using the duality bridge. The proof: g_content(f(y)) subset f(x) (chain property, y < x) implies h_content(f(x)) subset f(y) (duality), hence H(phi) in f(x) gives phi in f(y).

### Analysis of g_content_chain_property (the remaining sorry)

The enlarged-seed approach from plan v6 was analyzed in depth and found to have a fundamental consistency gap:

**Problem**: When C5-forward elimination at triggering point t inserts y beyond all domain points, for domain points x > t we need g_content(f(x)) subset f(y). The plan suggests including g_content of ALL predecessors in the seed for f(y).

**Key finding**: By temp_4 and the inductive invariant, the union of all g_content(f(x)) for x in dom equals g_content(f(m)) where m = max(dom). So the "enlarged seed" is just {eta} union g_content(f(m)).

**Blocker**: This seed requires F(eta) in f(m) for consistency (via forward_temporal_witness_seed_consistent). We have F(eta) in f(t) from U(xi,eta) in f(t), but F(eta) does NOT propagate forward through g_content. F(alpha) = neg G(neg alpha) is existential and G(neg alpha) not in f(t) does NOT imply G(neg alpha) not in f(m). In fact, G(neg eta) could be in f(m), making the seed {eta, neg eta, ...} inconsistent.

### Recommended Approach for Closing g_content_chain_property

**Two-pass construction**: Modify the omega-chain step to:
1. First, insert the witness point y with the standard seed {eta} union g_content(f(t))
2. Then, at the same step, extend f(y) to a NEW MCS that also includes g_content of all predecessors

The second extension starts from the already-established f(y) (which contains eta and g_content(f(t))). The additional elements (g_content of predecessors) are already in f(t) by the invariant, so they're consistent with g_content(f(t)). The extension maintains eta membership.

**Alternative**: Restructure the omega-chain to interleave C5 elimination with "g_content propagation" steps. Each propagation step, given a pair (x, y) in dom with g_content(f(x)) not subset f(y), replaces f(y) with a Lindenbaum extension of f(y) union g_content(f(x)). Consistency: g_content(f(x)) subset g_content(f(m)) (temp_4 + invariant) and g_content(f(m)) union f(y) has a specific consistency argument.

**Caveat**: Both approaches require careful verification that the modified construction still produces C5 witnesses (the new MCS at y might lose eta during extension). The "two-pass" approach is safer because the first pass guarantees eta, and the second pass only adds more formulas.

## Sorry Count
- Before: 14 (3 in ChronicleConstruction, 2 in CounterexampleElimination, 9 in ChronicleToCountermodel)
- After: 13 (2 in ChronicleConstruction [g_content_chain_property remains, limit_c1 closed], 2 in CounterexampleElimination, 9 in ChronicleToCountermodel)
- Note: limit_backward_H is structurally sorry-free but depends on the sorry in g_content_chain_property

## Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

## Build Status
- `lake build` succeeds with no errors
