# Implementation Summary: Task #107 Phase 1 (Partial)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Plan**: plans/15_implementation-plan.md
- **Status**: Phase 1 PARTIAL -- infrastructure definitions added, critical gap identified and documented
- **Session**: sess_1777063104_fcb2ea

## What Was Done

### Phase 1: g-Function Infrastructure (PARTIAL)

Added to `ChronicleConstruction.lean`:

1. **`limit_F_resolution`** (sorry-free): F(phi) in limit_f(x) implies exists y > x in limit_dom with phi in limit_f(y). Uses BX12 to convert F to Until, then C5_weak. This is the F-resolution property for domain points.

2. **`limit_P_resolution`** (sorry-free): P(phi) in limit_f(x) implies exists y < x with phi in limit_f(y). Mirror using BX12' and C5'_weak.

3. **`limit_g`** definition: For each pair (x, y), assigns deductiveClosure(g_content(limit_f(x))). This makes C3 trivial.

4. **`limit_c1_at_domain`** (sorry): DCS property for limit_g. Blocked on g_content consistency, which requires a generalized temporal K lemma.

5. **`limit_c3`** (sorry-free): g_content(limit_f(x)) subset limit_g(x, y). Immediate from subset_deductiveClosure.

6. **`g_content_chain_property`** (sorry, CRITICAL): The key invariant: for x < y in limit_dom, g_content(limit_f(x)) subset limit_f(y). This is the mathematical bottleneck.

7. **`limit_forward_G`** (depends on g_content_chain_property): Forward_G for domain points.

8. **`limit_backward_H`** (sorry): Dual of forward_G.

### Deep Analysis Results

The implementation session revealed a critical architectural finding that goes beyond what the research reports identified:

**Finding: `extended_limit_f` makes forward_G provably FALSE, not just unproven.**

- `extended_limit_f` assigns root MCS A to non-domain rationals
- For non-domain t < t' with extended_limit_f(t) = A = extended_limit_f(t'):
  forward_G requires G(phi) in A implies phi in A
- This is the reflexivity axiom Gp -> p (temp_t / A3a), which is INVALID under strict semantics
- Therefore forward_G for the current FMCS definition is unprovable
- This means `chronicle_fmcs.forward_G` (line 192) is not just sorry'd but FALSE

**Consequence**: The entire ChronicleToCountermodel approach (Path B) as currently structured cannot work. The `extended_limit_f` definition must be fundamentally changed, or a different approach is needed.

**Further finding: g_content_chain_property is NOT a consequence of the current omega-chain construction.**

- When C5 elimination inserts y for U(xi,eta) at x, f(y) contains g_content(f(x))
- But for an unrelated point x' with x' < y, g_content(f(x')) is NOT necessarily in f(y)
- The omega-chain inserts points in positions that don't maintain g_content chains
- Fixing this requires modifying the elimination seed to include g_content of ALL predecessors
- BUT: proving consistency of such enlarged seeds requires F-formulas at those predecessors, which is not guaranteed

## Sorry Site Changes

| File | Before | After | Change |
|------|--------|-------|--------|
| CounterexampleElimination.lean | 2 | 2 | No change |
| ChronicleConstruction.lean | 0 | 3 | +3 (infrastructure placeholders) |
| ChronicleToCountermodel.lean | 9 | 9 | No change |
| **Total** | **11** | **14** | **+3** |

The 3 new sorry sites are precisely scoped infrastructure placeholders:
- `limit_c1_at_domain`: g_content consistency (minor, edge case)
- `g_content_chain_property`: THE key mathematical bottleneck (critical)
- `limit_backward_H`: Depends on dual of g_content_chain_property

## Build Status

`lake build` succeeds with all changes.

## Recommendations for Next Steps

1. **Investigate the hybrid approach** (Int chain + chronicle): The Int chain has sorry-free forward_G/backward_H. The chronicle has C5/C5' witnesses. A hybrid BFMCS that uses Int chain families for G/H/Box evaluation and chronicle witnesses for Until/Since coherence could resolve the sorry sites.

2. **Fix extended_limit_f or abandon it**: The current definition is provably incorrect for forward_G. Either (a) define it using g_content-based interpolation for non-domain points, (b) restrict the FMCS domain to limit_dom (requires new parametric framework without AddCommGroup), or (c) use the Int chain as the base FMCS.

3. **Prove g_content_chain_property by modifying the omega-chain**: This requires changing the elimination functions to maintain the invariant, likely by enlarging seeds and modifying insertion positions.

4. **Consider a fundamentally different approach**: The direct truth lemma over sparse X (Phase 5) bypasses the FMCS framework entirely but still needs g_content chains for the G case.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- Added limit_g, F/P resolution, g_content_chain_property statement
