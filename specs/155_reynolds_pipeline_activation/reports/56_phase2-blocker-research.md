# Phase 2 Blocker Research: completeness_discrete sorryAx Dependency

## Root Cause Analysis

The implementation agent misidentified the blocker. `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:489) is explicitly **dead BX pipeline code** (see lines 55-73: "Do NOT attempt to prove these definitions"). It is NOT on the critical path for `completeness_discrete`.

The actual sorry chain to `completeness_discrete` is:

```
completeness_discrete (Completeness.lean:309)
  → countermodel_discrete_reynolds (Transfer.lean:1203)
    → cantor_bfmcs_discrete_restricted_tc (ChronicleToCountermodel.lean:1993)
    → cantor_bfmcs_discrete_restricted_fuc (ChronicleToCountermodel.lean:2049)
      → succ_embed_surjective (ChronicleToCountermodel.lean:1667)
        → limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:790)
          → succ_cofinal (ChronicleToCountermodel.lean:776)
            → chronicle_gap_contradiction (ChronicleToCountermodel.lean:475) [sorry]
```

The core issue: `restricted_tc` and `restricted_fuc` both use `succ_embed_surjective` to map `limit_dom` temporal witnesses back to integers. The surjectivity proof goes through `IsSuccArchimedean`, which goes through the dead `succ_cofinal` sorry.

**What does NOT need surjectivity**: `cantor_bfmcs_discrete_restricted_buc` uses only `succ_embed_squeeze_strict` (sorry-free, no IsSuccArchimedean dependency).

## Solution Paths

### Path A: Prove succ_embed_surjective from omega-chain structure (Recommended)

**Idea**: Prove `succ_embed_surjective` directly from the omega-chain construction, bypassing `IsSuccArchimedean`/`succ_cofinal` entirely.

The omega chain builds `limit_dom` incrementally:
- Stage 0: `{0}` — a single point
- Stage N+1: adds one new point as a C5 witness for some temporal formula

Every point in `limit_dom` was added at some stage N. At that stage, the point was inserted between existing points (or at the boundary). Since `succ_embed` maps consecutive integers to consecutive `LimitDomSubtype` points, and the base of the induction is `succ_embed(0) = root = 0`, we need to show: when a new point p is added at stage N+1, if all stage-N points are in the image of succ_embed, then p is also in the image.

This is essentially `succ_reaches_dom_N` (line 101), which already has the inductive structure but gets stuck at the "boundary case" — when the new point is above the maximum of the previous stage's domain.

**Key insight for the boundary case**: When point p is above max(dom(N)), the successor of max(dom(N)) in LimitDomSubtype is either p itself (if no other point was added between max(dom(N)) and p in the limit) or something ≤ p. Since succ_embed covers dom(N) by IH and succ_embed is monotone with no gaps, succ_embed(n+1) = succ of succ_embed(n), the new max is reachable.

**Effort**: ~150-300 lines. Requires careful handling of the omega-chain boundary and showing succ_embed tracks the LimitDomSubtype successor through stage additions.

### Path B: Rewrite restricted_tc/fuc to avoid surjectivity

**Idea**: Restructure `cantor_bfmcs_discrete_restricted_tc` and `restricted_fuc` to not need the ℤ ↔ LimitDomSubtype bijection.

For TC (F direction): When F(φ) ∈ fam.mcs(t), the current proof uses `limit_F_resolution` to find a witness y in limit_dom, then `succ_embed_surjective` to map y to an integer m. Alternative: use the MCS-level Prior-UZ axiom to stay within the integer-indexed structure. The family fam.mcs is indexed by ℤ; if F(φ) ∈ fam.mcs(t), by the MCS properties (serial_future + C5), there should be a witness expressible in ℤ-indexed terms.

For FUC: Same pattern — the Until/Since witness in limit_dom needs to be mapped back to ℤ.

**Challenge**: The MCS families are DEFINED via limit_f ∘ succ_embed, so their temporal properties come from limit_dom. To avoid surjectivity, we'd need to prove the coherence conditions hold in the ℤ-indexed family directly, which may require an entirely different proof architecture.

**Effort**: ~400-800 lines. High risk of needing further lemmas about the ℤ-indexed families.

### Path C: Prove IsSuccArchimedean from countability + discreteness + no endpoints

**Idea**: A countable discrete linear order without endpoints and with a designated base point is isomorphic to ℤ if and only if it has one connected component. Prove this is the case for LimitDomSubtype.

The chronicle's limit domain is countable (each stage adds finitely many points, countably many stages). It is discrete (every point has an immediate successor/predecessor). It has no endpoints (limit_dom has no max/min — this might need verification).

For a countable discrete linear order without endpoints, the number of connected components equals the number of Dedekind cuts that are NOT realized by any element. In the omega-chain construction, every Dedekind cut induced by a temporal formula DOES produce a witness point (C5). The question is whether ALL cuts are induced by temporal formulas.

**Challenge**: This is the same fundamental difficulty as succ_cofinal — not every Dedekind cut corresponds to a temporal formula.

**Effort**: ~300-600 lines, same core difficulty as existing approaches.

## Recommendation

**Path A** is the most promising. The `succ_reaches_dom_N` induction (line 101) already has the right structure. The boundary case (new point above max(dom(N))) needs:

1. Show succ_embed tracks the omega-chain construction: at each stage, succ_embed covers the domain
2. When a new point p is added above max, show succ(max) ≤ p in the limit domain, and p = succ_embed(n+1) for appropriate n

This avoids the deep EF-game theory needed for chronicle_gap_contradiction and stays within the order-theoretic properties of the omega chain.

**Next step**: Revise the plan to target `succ_embed_surjective` directly via omega-chain induction, bypassing the dead BX pipeline entirely.
