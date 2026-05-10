# Research Report: Z-Chain Bypass Analysis (RootScopedChain.lean)

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Status**: Research complete (Z-chain bypass assessed as NOT more tractable)
- **Type**: lean4
- **Date**: 2026-05-10
- **Session**: sess_1778449535_f13ea4

## Executive Summary

The Z-chain bypass in `RootScopedChain.lean` trades IsSuccArchimedean (1 sorry, global structural property) for 3 restricted coherence sorries (F/P-resolution and Until/Since coherence). After thorough analysis, **the Z-chain sorries are HARDER than IsSuccArchimedean, not easier**. The fundamental "F-obligation preservation" problem documented in the module docstring is a genuine mathematical obstacle that the chronicle construction explicitly solves via a different mechanism (C5 point insertion). Switching to the Z-chain path would be a regression.

## Architecture Overview

### Two Completeness Paths

The codebase contains two independent paths to the BX completeness theorem:

**Path A: Chronicle (active, on critical path)**
- `Completeness.lean` -> `dd_countermodel_chronicle_dense` (sorry-free) + `dd_countermodel_chronicle_nondense_sorry` (1 sorry)
- Dense case: Burgess chronicle on Rat via Cantor isomorphism. FULLY PROVEN.
- Non-dense case: Burgess chronicle on Int via Z-isomorphism. Blocked by `limitDomSubtype_isSuccArchimedean` (1 sorry at ChronicleToCountermodel.lean:1068).

**Path B: Z-Chain (dead code, NOT on critical path)**
- `RootScopedChain.lean` -> `dd_countermodel` (3 sorries)
- Builds `bx_fmcs : FMCS Int` directly on Z via schedule-based Lindenbaum chain.
- Sorries: `bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`.

### Current Critical Path

```
bx_completeness
  -> dense case: dd_countermodel_chronicle_dense  [SORRY-FREE]
  -> non-dense case: dd_countermodel_chronicle_nondense_sorry  [1 SORRY]
       -> depends on: limitDomSubtype_isSuccArchimedean  [THE sorry]
           -> at ChronicleToCountermodel.lean:1068
```

The Z-chain's `dd_countermodel` is NOT used by `bx_completeness`. It is dead code.

## Analysis of the 3 Z-Chain Sorries

### Sorry 1: `bx_bfmcs_restricted_tc` (Restricted Temporal Coherence)

**What it requires**: For any FMCS family in the BFMCS, if `F(phi)` is in `fam.mcs(t)`, then there exists `s > t` with `phi` in `fam.mcs(s)` (and symmetrically for `P(phi)`).

**Why it is hard**: The schedule-based chain constructs `fwd_chain(n+1)` from `fwd_chain(n)` using `fwd_succ`, which targets formula `schedule(n)` for resolution. If `F(phi)` is in `fwd_chain(n)`, the step either:
- **Resolves it** (if `schedule(n) = phi`): `phi` appears in `fwd_chain(n+1)`. But `F(phi)` may no longer be present.
- **Doesn't resolve it** (if `schedule(n) != phi`): The Lindenbaum extension includes `g_content(fwd_chain(n))`, so `G(chi)` propagates. But `F(phi)` is NOT in `g_content` -- it is `F(phi) = neg(G(neg phi))`, and `g_content = {chi | G(chi) in M}`.

The docstring at RootScopedChain.lean:28-36 explicitly documents this:
> "The simple Lindenbaum-based chain does not preserve F-obligations across steps. When `fwd_succ` builds a new MCS from `g_content(chain(n))`, the F(phi) formula may be absent from the result even though it was present in chain(n). This means F(phi) can be permanently lost without phi ever appearing."

**The monotonicity theorem** (lines 112-143) proves that once `F(phi)` LEAVES the chain, it never returns (because `G(neg phi)` propagates forward). But this is the WRONG direction -- we need to show `F(phi)` stays UNTIL `phi` appears, not that it can't come back after leaving.

**Estimated effort**: This is the "F-obligation preservation" problem that blocked the defect-directed chain (archived in Boneyard). The BX11 fold approach was tried and abandoned due to `Classical.choice` opacity. The enriched seed approach was tried and found to have consistency issues. No viable approach has been identified in 37+ dead ends (per ROADMAP). **Effort: UNKNOWN / POTENTIALLY UNBOUNDED**.

### Sorry 2: `bx_bfmcs_restricted_buc` (Backward Until/Since Coherence)

**What it requires**: If `U(phi,psi)` in `subformulaClosure(root)` and there exists a witness `s > t` with `phi in fam.mcs(s)` and `psi in fam.mcs(r)` for all `t < r < s`, then `U(phi,psi) in fam.mcs(t)`.

**Why it is hard**: This is a "backward" coherence property: from semantic witnesses, conclude syntactic membership. For the schedule-based chain, the MCS at time `t` is constructed by Lindenbaum extension and does not "see" the witnesses at future times. The chronicle construction handles this via C4/C4' (counterexample elimination), which is a completely different mechanism.

**Estimated effort**: Requires proving that Lindenbaum extensions respect Until structure. No clear approach. **Effort: HIGH**.

### Sorry 3: `bx_bfmcs_restricted_fuc` (Forward Until/Since Coherence)

**What it requires**: If `U(phi,psi) in fam.mcs(t)`, then there exists `s > t` with `phi in fam.mcs(s)` and `psi in fam.mcs(r)` for all `t < r < s`.

**Why it is hard**: This is "forward" coherence: from syntactic membership, produce semantic witnesses. The schedule-based chain has no Until-specific insertion mechanism. The chronicle construction handles this via C5 (point insertion for Until witnesses), which is purpose-built for this property.

The dense case proves this via `limit_satisfies_c5_strong` -> the chronicle's C5 property, then transports through the Cantor isomorphism. The Z-chain has no analogous mechanism.

**Estimated effort**: Requires implementing Until-witness resolution in the schedule-based chain. This is essentially reimplementing the chronicle's C5 property inside a different framework. **Effort: VERY HIGH (months of work)**.

## How the Chronicle Solves What the Z-Chain Cannot

### F-Resolution

The chronicle converts `F(phi)` to `U(phi, top)` using axiom BX12 (`F phi <-> top U phi`), then uses the C5 point insertion mechanism to find a witness. This is `limit_F_resolution` at ChronicleConstruction.lean:689.

The Z-chain has no equivalent -- it relies on round-robin scheduling to eventually target `phi` for resolution, but the Lindenbaum step can lose `F(phi)` before the schedule reaches it.

### Until/Since Coherence

The chronicle has purpose-built C4/C5 properties (counterexample elimination and point insertion) that directly establish Until/Since coherence. These are architectural features of the Burgess construction.

The Z-chain has no Until/Since-aware construction. Adding one would essentially mean reimplementing the chronicle within the Z-chain framework.

## Why IsSuccArchimedean Is Actually Easier

### Nature of the Gap

IsSuccArchimedean asks: for `a <= b` in `LimitDomSubtype`, does there exist `n` with `succ^[n](a) = b`? The proof is partially completed (lines 1054-1068): the starting MCS pair `(a, b)` is located in some `omega_chain_val(N).dom`. The missing piece is showing that repeated successor application from `a` reaches `b` within the finite set `dom_N intersection [a, b]`.

### Why It Is Easier Than the Z-Chain Sorries

1. **IsSuccArchimedean is a single gap in an otherwise working framework**. The chronicle handles F-resolution, G/H propagation, Until/Since coherence, C4/C5 properties, and the dense case -- ALL sorry-free. Only IsSuccArchimedean remains.

2. **The Z-chain sorries would require reimplementing core chronicle features**. Sorry 3 (forward Until/Since) essentially requires rebuilding C5 inside a Lindenbaum chain framework. Sorry 1 (F-resolution) requires solving the F-obligation preservation problem that defeated 37 approaches.

3. **IsSuccArchimedean is well-characterized**. The proof sketch is 90% complete (see report 03_team-research.md). The gap is proving that `limit_dom intersection [a,b]` is finite (equivalently, that succ-chains reach their target). This is a SINGLE mathematical question.

4. **The Z-chain has 3 INDEPENDENT unsolved problems**. Each requires different techniques, and Sorry 1 alone (F-obligation preservation) may be as hard as or harder than IsSuccArchimedean.

## Why LimitDomSubtype Cannot Be Used Directly

One might ask: can we build BFMCS directly on `LimitDomSubtype` instead of transporting to Int/Rat? No, because:

- The parametric framework requires `D` to be an `AddCommGroup` with `LinearOrder` and `IsOrderedAddMonoid`.
- `LimitDomSubtype` is a subtype of Rat that is NOT closed under addition.
- An isomorphism to Int (discrete) or Rat (dense) is REQUIRED.

## Feasibility Assessment

### Switching to Z-Chain Path: NOT RECOMMENDED

| Aspect | Chronicle + IsSuccArchimedean | Z-Chain (3 sorries) |
|--------|-------------------------------|---------------------|
| Sorries remaining | 1 | 3 |
| Effort per sorry | Medium-Hard (well-characterized gap) | Hard to Very Hard (uncharacterized) |
| Code reuse | All chronicle infrastructure works | Must rebuild C4/C5 equivalents |
| Historical attempts | 20+ rounds on this specific gap | 37+ dead ends on F-obligation preservation |
| Dense case | Sorry-free | Sorry-free (same code) |
| Progress to date | 90% proof sketch complete | No viable approach identified |

### Estimated Effort Comparison

| Sorry | Estimated Effort |
|-------|-----------------|
| `limitDomSubtype_isSuccArchimedean` | 1-4 weeks (if gap insight found) |
| `bx_bfmcs_restricted_tc` | Unknown (blocked by F-obligation preservation, 37 dead ends) |
| `bx_bfmcs_restricted_buc` | 2-4 weeks (backward coherence, unclear approach) |
| `bx_bfmcs_restricted_fuc` | 4-8 weeks (requires rebuilding C5-equivalent) |

## Recommendations

1. **Do NOT switch to the Z-chain path.** The 3 Z-chain sorries are collectively harder than IsSuccArchimedean, and Sorry 1 alone may be intractable (same problem that defeated 37 approaches on the defect-directed chain).

2. **Continue pursuing IsSuccArchimedean on the chronicle path.** The gap is well-characterized and the proof is 90% complete. The ONE missing piece (finiteness of `limit_dom intersection [a,b]`) is a specific, well-defined mathematical question.

3. **If IsSuccArchimedean proves intractable, consider Option 3 from the team research**: document it as a formalization gap. The dense case is sorry-free, and the discrete sorry is isolated.

4. **The Z-chain path should remain dead code.** It serves as a historical record of the defect-directed approach and its limitations.
