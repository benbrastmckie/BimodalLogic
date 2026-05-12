# Implementation Summary: Phase 4 - succ_embed_surjective

**Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
**Phase**: 4 - Prove succ_embed_surjective via Single-Orbit Argument
**Status**: BLOCKED
**Session**: sess_1778539019_1c65f0

## Outcome

Phase 4 remains BLOCKED. After extensive analysis (multiple proof strategies explored), the two sorry sites at lines 2060 and 2063 of `ChronicleToCountermodel.lean` could not be closed.

## Analysis Summary

### The Problem

`succ_embed_surjective` claims every `LimitDomSubtype` element is in the image of `succ_embed : Z -> LimitDomSubtype`. The current proof uses stage induction on the omega-chain construction. Two cases are unresolved:

1. **Above-max case** (line 2060): A new domain point `q` at stage K+1 has `q > max_K` (above all stage-K points).
2. **Below-min case** (line 2063): Symmetric, `q < min_K`.

### Strategies Explored

1. **Direct stage induction with dom_new_unique**: The immediate successor `succ_embed(j+1)` of `max_K = succ_embed(j)` enters the limit domain at some stage K'. If K' = K+1, then `dom_new_unique` forces `succ_embed(j+1).val = q` (only one new point per stage). However, if K' > K+1, `succ_embed(j+1)` is NOT at stage K+1, and `succ_embed(j+1) < q` (strictly). The no-gap property gives `q >= succ_embed(j+2)`, but repeating this argument produces an infinite descent that may not terminate.

2. **Cofinality approach** (from plan): Prove the orbit is unbounded above, then use squeeze. Requires showing bounded orbits lead to contradiction. The team research suggested an "interleaving" argument where pred-chain elements from the bounding point fall between consecutive orbit elements. However, careful analysis shows this interleaving does NOT occur: all pred-chain elements stay ABOVE all orbit elements (by collapse_class_sep), so they never enter orbit gaps.

3. **Convergence/real-analysis approach**: Cast orbit values to R, show bounded monotone sequences converge, derive contradiction from limit behavior. This requires proving L = M (both limits equal), which is non-trivial and may require deep analysis of the omega-chain construction.

4. **Icc finiteness approach**: Show bounded intervals in LimitDomSubtype are finite, then derive contradiction from infinite orbit in finite interval. The codebase author's own documentation states "omega-chains converge to accumulation points, making Icc intervals infinite," suggesting this approach was deliberately avoided.

5. **pred(q) approach**: Show `pred(q)` is at an earlier stage (by dom_new_unique reasoning), then use `succ(pred(q)) = q` to conclude. Fails because `pred(q)` may enter at a LATER stage than q (the limit-domain predecessor is determined by the entire limit, not just the current stage).

### Key Findings

- The theorem is equivalent to `IsSuccArchimedean` for `LimitDomSubtype`, which the codebase was explicitly designed to bypass (see the "Collapse-Based Discrete Pipeline" documentation at line 1082).
- The existing collapse approach (CollapseClass isomorphic to Z) works without `succ_embed_surjective`. The TC and FUC coherence proofs USE surjectivity, but could potentially be refactored to use the collapse quotient instead.
- The abstract order-theoretic properties (SuccOrder, PredOrder, NoMinOrder, NoMaxOrder, succ_pred, pred_succ) do NOT imply single orbit. Counterexample: Z + Z (disjoint union with first below second) has all these properties but two orbits.
- The proof must use specific properties of the omega-chain construction, not just the resulting order structure. The exact construction-specific property that forces single orbit has not been identified.

### Partial Progress

- Established that `succ_embed(j+1) <= q_element` via `succ_le_iff` (the orbit's immediate successor is <= any domain point above `max_K`).
- Proved `j >= 0` (the max of any stage maps to a non-negative orbit index).
- Proved `succ_embed(j+1)` is NOT at stage K (its value exceeds `max_K`).
- Handled the K' = K+1 subcase via `dom_new_unique`.
- The K' > K+1 subcase remains open.

## Recommendations

1. **Refactor TC/FUC to bypass surjectivity**: Instead of using `succ_embed_surjective` to convert limit-domain points to integers, use the collapse quotient `CollapseClass ≃o Z` (already proved sorry-free). This would make the sorry in `succ_embed_surjective` non-blocking.

2. **Deep construction analysis**: If surjectivity must be proved, analyze the omega-chain elimination procedure to identify which construction-specific property forces single orbit. The C5 walk for `U(T,bot)` always reaches the domain maximum and places a witness beyond -- this may be the key property.

3. **Plan revision**: Run `/revise 123` to update the plan with these findings and potentially redirect Phase 4 toward the bypass approach.

## Files Modified

None (the file was restored to its pre-attempt state with the original sorry sites).

## Build Status

`lake build` passes. The sorry sites remain at lines 2060 and 2063 of `ChronicleToCountermodel.lean`.
