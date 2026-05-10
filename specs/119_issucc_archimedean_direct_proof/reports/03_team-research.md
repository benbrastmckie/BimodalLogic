# Research Report: IsSuccArchimedean Round 3 — Team Synthesis

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Status**: Research complete (core gap identified but unresolved)
- **Type**: lean4
- **Mode**: Team Research (4 teammates)
- **Date**: 2026-05-10
- **Session**: sess_1778449535_f13ea4

## Executive Summary

Four parallel research agents exhaustively investigated bounding omega chain insertions into bounded intervals. All four converge on the same conclusion: **there is ONE irreducible gap** in every proof strategy, and it is the same gap regardless of approach.

**The irreducible gap**: Prove that `limit_dom ∩ [a.val, b.val]` is finite — equivalently, that the omega chain eventually stops inserting points into any bounded rational interval. No WF measure, topological argument, birth-stage analysis, enumeration bound, or novel angle has cracked this in 20+ research rounds across tasks 118-120.

**The gap is equivalent to**: proving `limit_dom` is "ℝ-closed" (Cauchy sequences in limit_dom converging in ℝ have their limits in limit_dom). This is a deep structural property of the Burgess omega chain construction that has not been formalized.

## Teammate Contributions

| Teammate | Angle | Key Finding |
|----------|-------|-------------|
| A | Enumeration bounding | `dom_new_unique` confirmed (1 point/step). `WellFoundedGT.toIsSuccArchimedean` found in Mathlib. But total insertions into bounded interval remain unbounded. |
| B | Set.Finite / LocallyFiniteOrder | Complete Mathlib lemma inventory (20+ lemmas). All paths require `(Set.Icc a b).Finite` which IS the problem. Z×Z lex counterexample confirms pure order theory insufficient. |
| C | Complete proof sketch | Gap-free [ORDER] steps 0-4 (contradiction framework). ONE [GAP] at Step 6 Case B: when sup of succ-chain is NOT in limit_dom. |
| D | Novel angles | All approaches reduce to same core gap. Z-chain bypass (RootScopedChain.lean) identified as alternative with different sorries. |

## The Complete Proof Sketch (from Teammate C)

```
Given a < b in LimitDomSubtype, assume ∀ n, succ^[n](a) ≠ b.

Step 0 [ORDER]: The chain {succ^n(a)} is strictly increasing, bounded by b.
Step 1 [ORDER]: The chain {pred^m(b)} is strictly decreasing, bounded by a.
Step 2 [ORDER]: Interleaving: succ^n(a) < pred^m(b) for all n, m.
Step 3 [ORDER→ℝ]: Both chains embed into ℝ via Rat.cast, converge by monotone bounded.
Step 4 [ℝ]: Let L = sup{succ^n(a)}, L' = inf{pred^m(b)}. Then L ≤ L'.

Step 5 [ORDER]: If L ∈ limit_dom: pred(L) gives contradiction (chain elements
  violate sealed interval (pred(L), L)). ← PROVEN

Step 6 Case A: If L' ∈ limit_dom: succ(L') gives contradiction (dual argument). ← PROVEN

Step 6 Case B [GAP]: If L ∉ limit_dom AND L' ∉ limit_dom (or L = L' ∉ limit_dom):
  The succ-chain converges to L from below, pred-chain converges from above.
  Both limits are outside limit_dom. Need contradiction from omega chain structure.
  ← THIS IS THE ONE IRREDUCIBLE GAP
```

## Why Each Approach Fails at the Gap

| Approach | Why It Fails |
|----------|-------------|
| Birth-monotonicity | FALSE: g-values can contain ⊥ at finite stages |
| Dom_N count induction | pred(b) may not be in dom_N; increasing N inflates count |
| Lex-pair (count, birth) | Second component doesn't decrease when first stays equal |
| Topology (bounded+discrete→finite) | limit_dom not closed in ℝ; counterexample {1/n} |
| Real analysis (sSup) | Limit may not be in limit_dom (Case B above) |
| Enumeration bounding | Per-step bound of 1 doesn't give total bound over ω steps |
| LocallyFiniteOrder | Circular: requires Set.Icc finite = the problem |
| WellFoundedGT | Requires every bounded interval finite = the problem |
| Formula counting | Unbounded number of counterexamples can target same interval |

## Alternative Path: Z-Chain Bypass

Teammate D identified that `RootScopedChain.lean` builds `bx_fmcs : FMCS Int` directly on ℤ, bypassing the chronicle entirely. This has 3 different sorries:
1. `bx_bfmcs_restricted_tc` (restricted temporal coherence)
2. `bx_bfmcs_restricted_buc` (backward Until/Since coherence)
3. `bx_bfmcs_restricted_fuc` (forward Until/Since coherence)

These are the "F-obligation preservation" problem — a DIFFERENT obstacle from IsSuccArchimedean. It may or may not be more tractable.

## Mathlib Infrastructure Available (from Teammate B)

| Lemma | Provides | Requires |
|-------|----------|----------|
| `WellFoundedGT.toIsSuccArchimedean` | IsSuccArchimedean | WellFoundedGT |
| `LocallyFiniteOrder → IsSuccArchimedean` | IsSuccArchimedean | LocallyFiniteOrder |
| `LocallyFiniteOrder.ofFiniteIcc` | LocallyFiniteOrder | ∀ a b, (Set.Icc a b).Finite |
| `Set.Finite.subset` | Set.Finite S | S ⊆ T, T.Finite |
| `isCompact_Icc` (in ℝ) | IsCompact [a,b] | — |
| `Monotone.tendsto_atTop` | convergence | bounded monotone in ℝ |

## Recommendations

### Option 1: Prove the Gap (IsSuccArchimedean directly)

The ONE missing piece is: **prove that if `{q_n}` is an infinite strictly increasing sequence in `limit_dom` bounded above, with `(q_n, q_{n+1}) ∩ limit_dom = ∅` for all n, then `sup{q_n} ∈ limit_dom`**.

This is the "ℝ-closure" property. It must use omega chain structure — the counterexample enumeration eventually processes counterexamples near the limit, and the surjectivity-above property ensures this happens. But the formal mechanism linking "processing near L" to "inserting L into the domain" has not been identified.

### Option 2: Z-Chain Bypass (different sorries)

Abandon the chronicle path for the discrete case. Use `RootScopedChain.lean`'s direct ℤ construction. Trade the IsSuccArchimedean sorry for 3 restricted coherence sorries. These may be more tractable (the F-obligation preservation problem is about Lindenbaum extensions preserving specific formulas, which is a local property rather than a global structural one).

### Option 3: Accept the Sorry

Document the sorry as a genuine formalization gap (the mathematics is correct per Burgess 1982). The dense case is sorry-free. The discrete sorry is isolated and does not affect soundness or decidability.

## Status Assessment

After 20+ research rounds, 2 implementation attempts, and 3 team research sessions across tasks 118-120, the IsSuccArchimedean problem is well-characterized but unsolved. The ONE irreducible gap (ℝ-closure of limit_dom) requires a genuinely novel insight about the omega chain construction that has not emerged despite extensive investigation.
