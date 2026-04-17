# Research Report: Task #93 (Round 32)

**Task**: 93 - Complete BXCanonical embedding (close 6 sorry sites)
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Session**: sess_1776399079_6c388d

## Summary

Round 32 assembled four independent analysts to rigorously evaluate viable directions for closing the 6 sorry sites in `RootScopedChain.lean`. The unanimous conclusion across all teammates: **the existing round-robin enriched chain (`rr_fwd_chain`) cannot prove forward_F, and no syntactic modification can rescue it.** The perpetual deferral (dead end 22) is a structural property of BX11's interaction with unconstrained Lindenbaum `.choose`, not a proof technique gap.

All four teammates converge on the **quasimodel-derived chain** as the only viable path, but with important caveats about the g_content chaining gap and additional blockers for sorries 2, 3, and 5 that prior rounds underestimated.

## Key Findings

### Finding 1: Forward_F Is Definitively Unprovable on the Existing Chain (99% consensus)

**All four teammates confirm** that `rr_fwd_chain_forward_F` (sorry 1, line 1413) cannot be proved as a theorem about the existing chain. The argument:

- The BX11 fold (`enriched_fwd_fold`, lines 162-249) gives disjunctive preservation: `chi in M' OR F(chi) in M'`
- `enriched_fwd_step_resolves_one` (line 644) guarantees SOME formula is resolved, but the IDENTITY depends on BX11's three-way case split and the Lindenbaum `.choose`
- Case 3 of BX11 (`F(F(beta) AND chi)`) wraps the accumulated compound in F, degrading all previously-tracked formulas to F-protected (line 240)
- No BX axiom combination can constrain what `Classical.choice` / `set_lindenbaum` selects across MCS extensions (Teammate C)
- The Report 31 Section 17 perpetual deferral contradiction argument has an unfixable gap: non-P formulas can oscillate indefinitely, providing inexhaustible alternative resolutions while P-members are perpetually F-protected (Teammate A)

**This settles the question definitively after 31 rounds.** Further investment in proving forward_F on the existing chain is not warranted.

### Finding 2: Corrected Sorry Dependency Graph (No Circularity)

Teammate C disproved Report 31's claimed circularity. The actual dependency structure is a diamond:

```
Sorry 1 (forward_F depth-0, line 1413) ----+
  |                                         |
  v                                         |
Sorry 2 (forward_F t<0, line 1457)          |
  |                                         |
  +----> Sorry 4 (restricted_tc, line 1517) <----+
  |        |                                     |
  |        v                                     |
  |      Sorry 6 (restricted_fuc, line 1527)     |
  |                                              |
Sorry 3 (backward_P, line 1464) ----------------+
  |
  +----> Sorry 5 (restricted_buc, line 1522) -- partially independent
```

- **Sorry 1 and Sorry 3** are independent root blockers (forward F vs backward P)
- **Sorry 4** depends on both (needs forward_F AND backward_P for restricted temporal coherence)
- **Sorry 6** depends on sorry 4 (forward Until discharge requires forward_F via BX9/BX10)
- **Sorry 5** has weaker dependency: needs step transfer, not full forward_F

### Finding 3: Sorry 5 (Backward Until) Is an Independent Blocker (New)

Both Teammates A and C identified that sorry 5 (`dd_bfmcs_restricted_buc`, line 1522) requires a **step transfer** property:

```
(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)
```

This cannot be derived from the chain's g_content/h_content structure because:
- `(phi U psi)` is not a G-formula, so g_content propagation goes the wrong direction
- BX4' gives `H(F(phi U psi))` from `(phi U psi) in chain(r+1)`, which yields `F(phi U psi) in chain(r)` via backward H
- Going from `F(phi U psi)` to `(phi U psi)` at chain(r) requires forward_F -- creating apparent circularity
- Teammate C revised confidence to 60% that this can be proved independently

**This means sorry 5 needs to be addressed by the chain replacement, not treated as a low-hanging fruit.**

### Finding 4: Sorry 3 (Backward_P) Is Strictly Harder Than Sorry 1 (New)

Teammate C identified that the backward chain (`rr_bwd_chain`) uses plain `bwd_pred` with NO enrichment (no BX11 fold, no p_carry equivalent of f_carry). Any solution must:
- Either enrich the backward chain symmetrically to the forward chain
- Or use a unified construction that handles both temporal directions

Teammate A confirmed: sorry 2 (forward_F for t < 0) requires F-formula propagation through the backward chain, which `bwd_pred`/`p_carry` does not support. The naive path via BX4 (`G(P(F(psi)))`) is circular.

### Finding 5: No Alternative Approach Escapes the Core Obstacle (95% consensus)

Teammate B systematically analyzed 8 alternative approaches:

| Approach | Verdict | Reason |
|----------|---------|--------|
| Filtration (Goldblatt 1992) | BLOCKED | Non-totality of `bx_le` prevents Int embedding |
| FMP detour | BLOCKED | Same non-totality + architectural mismatch |
| Verbrugge step-by-step | BLOCKED | Same seed inconsistency as dead end 23/24 |
| Quasimodel witness-seeded chain | Promising but incomplete | F-carry loss at resolving steps for other formulas |
| Burst resolution | BLOCKED | Reduces to enriched step (disjunctive preservation) |
| Mosaic methods | Not applicable | Decidability technique, not completeness |
| Weaken truth lemma | IMPOSSIBLE | forward_F is logically equivalent to G backward direction |
| Different semantic framework | No gain | Isomorphic to existing problem |

**Critical finding from Teammate B**: A resolved defect `psi in chain(n+1)` does NOT imply `G(neg psi) in chain(n+1)` (that would be inconsistent with `psi in chain(n+1)`), so a resolved formula cannot be PERMANENTLY killed in the next step. However, it CAN be lost at step n+2 via Lindenbaum non-determinism.

### Finding 6: The Quasimodel-Derived Chain Has a Specific, Bounded Gap

All teammates identify the **g_content chaining obstacle** as the key remaining gap:

- `bx_forward_witness` gives MCS `v` with `g_content(M) subset v` and `target in v`
- But chaining witnesses `M0 -> v1 -> v2 -> ...` requires `g_content(v_{i-1}) subset v_i`
- Each `v_i` extends `g_content(M0)`, NOT `g_content(v_{i-1})`
- `g_content(v_{i-1})` is NOT necessarily a subset of `g_content(M0)`

**Teammate C's resolution path**: The quasimodel's `hintikka_step` (Construction.lean:45-52) maps directly to g_content/h_content propagation. The finite defect-discharge chain from the quasimodel CAN be embedded as FMCS segments, because:
- `hintikka_step` requires exactly the G-propagation and H-backward properties that `g_content` and `h_content` provide
- The bridge is: map HintikkaPoint steps to BXPoint MCS extensions using `fwd_succ` (which guarantees g_content inclusion by construction)
- Each defect resolved by `hintikka_step` corresponds to one `fwd_succ` resolving step

### Finding 7: Architecture Is Mostly Correct (Teammate D)

Teammate D's sunk cost analysis:

| Component | LOC | Sorry-free? | Reusable? |
|-----------|-----|-------------|-----------|
| Quasimodel/ | 1816 | Yes | Fully |
| Frame.lean | 673 | Yes | Fully |
| CanonicalModel.lean | 498 | Mostly | Fully |
| Bundle/ | ~1800 | Partial | Fully |
| Algebraic/ | ~2500 | Partial | Fully |
| rr_fwd_chain/enriched_fwd_step | ~300 | No | **Replace** |

- Completeness is a terminal theorem with **ZERO downstream dependents**
- Changes are entirely contained within `BXCanonical/`
- The project's deviation from ALL published approaches (Burgess 1982, GHR 1994, Goldblatt 1992, Verbrugge 2004) is attempting to PROVE forward_F about a pre-existing chain rather than BUILDING it into the construction

## Synthesis

### Conflicts Found and Resolved

**Conflict 1: Independence of sorry 5**
- Teammate C initially claimed sorry 5 is 95% independent of sorry 1
- Teammate A showed the step transfer requires backward G-reflection, which leads back to forward_F
- **Resolution**: Sorry 5 has weaker dependency (step transfer, not full forward_F) but is NOT trivially independent. Confidence revised to 60% for independent proof.

**Conflict 2: Confidence in quasimodel-derived chain**
- Teammate D: 80% confidence
- Teammate B: 75% confidence
- Teammate A: 55% confidence (lowered by g_content chaining obstacle)
- Teammate C: 75% confidence
- **Resolution**: The g_content chaining obstacle is real but bounded. Teammate C's analysis that `hintikka_step` maps to `fwd_succ` is the key insight. Synthesized confidence: **70%** for closing all 6 sorries via quasimodel-derived chain.

**Conflict 3: Scope of required changes**
- Teammate D: 400-600 new LOC replacing ~300
- Teammate B: 500-800 new LOC
- Teammate A: Unestimated (flagged backward chain as additional scope)
- **Resolution**: 500-800 new LOC is realistic, accounting for both forward and backward chain replacement plus Until/Since coherence.

### Gaps Identified

1. **The g_content chaining gap**: How to chain `bx_forward_witness` outputs so that `g_content(v_{i-1}) subset v_i`. The `fwd_succ` approach (using `v_{i-1}` as the input MCS, not `M0`) should work IF the defect `F(psi_i)` is still present in `v_{i-1}`. This requires F-formula survival through the chain of witnesses -- the same fundamental challenge at a different level.

2. **The backward chain gap**: Sorry 3 requires a symmetric construction for P-defects. The backward chain has NO enrichment, meaning the entire backward chain construction may need replacement alongside the forward chain.

3. **The Until step transfer gap**: Sorry 5 needs `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`. No clean derivation from BX axioms + chain g_content structure has been found.

4. **The t < 0 F-propagation gap**: Sorry 2 needs `F(psi)` to propagate from the backward region through M0 into the forward chain. Neither g_content nor h_content carries F-formulas in the right direction.

### Recommendations

**Primary path (70% confidence)**: Replace `rr_fwd_chain`/`rr_bwd_chain` with quasimodel-derived chain construction.

**Specific next steps**:

1. **Research the `fwd_succ` chaining property**: Can we prove that if `F(psi) in M` and `v = fwd_succ(M, psi)`, then for any `F(chi) in v`, we can chain to `v' = fwd_succ(v, chi)` with `g_content(v) subset v'`? This is trivially true since `fwd_succ` always gives `g_content(input) subset output`. The real question is whether `F(chi) in v` (does the F-obligation survive the first resolution?).

2. **Implement a proof-of-concept**: Write a minimal `defect_fwd_chain` that resolves ONE defect per step (defect-driven, not round-robin) and attempt to prove forward_F for it. The forward_F proof should be: "F(psi) in chain(n) implies psi is the target at step n+1, so psi in chain(n+1)." The gap is: what if another defect chi is targeted first (chi has lower index)? Then F(psi) must survive one resolving step.

3. **Investigate the enriched seed with SINGLE additional F-formula**: Dead end 13 blocks `{target} union g_content union f_carry` (full f_carry inconsistent). But `{target, F(psi)} union g_content(M)` where BOTH target and F(psi) are in M should be consistent (subset of M, which is consistent). This protects exactly ONE other F-formula. At each resolving step, protect the NEXT defect in queue. This gives a cascading resolution: defect 1 resolved at step 1 while protecting defect 2's F-obligation; defect 2 resolved at step 2 while protecting defect 3; etc.

4. **Address the backward chain**: Either enrich `rr_bwd_chain` with P-formula preservation (symmetric to the forward enrichment), or build a unified bidirectional chain.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Approach | completed | 55% | Sorry 5 step transfer blocker; g_content chaining obstacle |
| B | Alternative Approaches | completed | 75% | 8 alternatives systematically eliminated; no novel escape |
| C | Critic | completed | 75% | No circularity; backward chain harder; BX11 definitively blocks |
| D | Horizons | completed | 80% | Architecture audit; sunk cost analysis; literature alignment |

## References

### Key Codebase Paths
- `RootScopedChain.lean:1413` - Sorry 1 (forward_F depth-0)
- `RootScopedChain.lean:1457` - Sorry 2 (forward_F t<0)
- `RootScopedChain.lean:1464` - Sorry 3 (backward_P)
- `RootScopedChain.lean:1517` - Sorry 4 (restricted_tc)
- `RootScopedChain.lean:1522` - Sorry 5 (restricted_buc)
- `RootScopedChain.lean:1527` - Sorry 6 (restricted_fuc)
- `RootScopedChain.lean:162-249` - enriched_fwd_fold (BX11 fold)
- `RootScopedChain.lean:644` - enriched_fwd_step_resolves_one
- `Frame.lean:164` - bx_forward_witness
- `Frame.lean:623` - bx_until_eventuality_resolution
- `CanonicalModel.lean:66` - fwd_succ
- `Quasimodel/Construction.lean:45-52` - hintikka_step
- `Quasimodel/Construction.lean:75` - defect_count
- `Bundle/TemporalCoherence.lean:295` - restricted_temporally_coherent
- `Bundle/TemporalCoherence.lean:535` - restricted_forward_until_since_coherent
- `Bundle/TemporalCoherence.lean:565` - restricted_backward_until_since_coherent
- `Bundle/UntilSinceCoherence.lean:25-26` - step transfer parameterization
- `Algebraic/RestrictedParametricTruthLemma.lean:471` - truth lemma entry point

### Literature
- Burgess 1982: Defect-driven chain construction (builds forward_F in)
- GHR 1994 Ch.6: Quasimodel + unraveling to Z-model
- Goldblatt 1992: Filtration approach (blocked by non-totality of bx_le)
- Verbrugge 2004: Step-by-step defect elimination
- BdRV 2001 Ch.4: Demand-driven construction

### Dead Ends Confirmed This Round
- Dead end 22 (perpetual deferral): DEFINITIVELY confirmed as structural, not proof-technique
- Dead end 13 (extended seed): Confirmed inconsistent for full f_carry
- Dead end 25/30 (BXPoint witness not on chain): Confirmed but bounded (hintikka_step bridge viable)
- Report 31 Section 17 (subset lattice termination): Gap confirmed unfixable (oscillating non-P defects)
