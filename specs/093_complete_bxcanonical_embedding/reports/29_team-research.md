# Research Report: Task #93 -- Team Research Round 29

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776382982_88c24e

## Summary

Round 29 synthesizes findings from 4 teammates after the Plan 28 DRM chain implementation encountered obstacles (DRMChain.lean sorry at line 284, plus 3 handoffs documenting DRM-chain and BXPoint-chain blockers). The team produces three convergent conclusions and one major new discovery:

1. **The DRM `bounded_witness` approach (Plan 28) is structurally blocked.** The `single_step_forcing` theorem requires `SetMaximalConsistent` negation completeness; DRM states only provide negation completeness within `subformulaClosure`, which is insufficient at the F-nesting boundary. Additionally, `iter_F_not_mem_closureWithNeg` proves departure from `closureWithNeg`, not the larger `deferralClosure`. Three independent gaps make Plan 28 unimplementable as written (Teammate A Finding 1, Teammate C Finding 2).

2. **The targeted seed `{psi} union g_content(u)` IS provably consistent** when `F(psi) in subformulaClosure(phi)` (Teammate A Finding 4). This is the KEY new mathematical insight of this round. The generalized temporal K argument lifts inconsistency of {psi} + g_content to G(neg psi) in u, contradicting F(psi) = neg(G(neg psi)) in u. This targeted seed approach can produce a DRM containing the witness psi, bypassing the BX11 hijacking/perpetual deferral entirely.

3. **The literature consensus is: do NOT build one chain resolving all eventualities simultaneously** (Teammate D Finding 1). Burgess, GHR, and Goldblatt all use either per-formula resolution chains, quasimodel-then-linearize, or semantic truth lemma arguments. The project's current approach (one chain, all obligations, all at once) is contrary to all published techniques.

4. **Sorry 6 (forward Until/Since coherence) has an INDEPENDENT obstacle beyond forward_F** (Teammate C Finding 4). Until persistence through Lindenbaum chain steps is a separate problem documented in task 84. The "all 6 sorries form one cluster" claim from Report 27 is imprecise.

## Key Findings

### Primary Approach Analysis (from Teammate A)

**Finding 1 -- DRM single_step_forcing is structurally blocked**: The negation completeness gap at the F-nesting boundary is irreducible. When `iter_F(d+1, psi)` exits deferralClosure, neither it nor `neg(iter_F(d+1, psi))` can participate in DRM maximality arguments. The `bounded_witness` proof chain requires `neg(FF(X)) in u` which the DRM cannot provide. Confidence: HIGH.

**Finding 2 -- Full MCS bounded_witness also fails**: In any full MCS, `phi_in_mcs_imp_F_phi` makes all F-iterates present (`iter_F k psi in M` for ALL k >= 1), so the exit condition `iter_F(d+1, psi) NOT in M` never holds. `bounded_witness` was designed for RESTRICTED MCS only. Confidence: HIGH.

**Finding 3 -- DRM perpetual deferral is identical to enriched chain**: The DRM chain's `f_step` condition (`F(psi) in u => psi in v OR F(psi) in v`) has the same Lindenbaum non-determinism as `enriched_fwd_step`. The DRM approach merely relocates the non-determinism. Confidence: HIGH.

**Finding 4 -- Targeted seed {psi} + g_content IS consistent**: When `F(psi) in u` and `G(neg psi) in deferralClosure(phi)`, the seed `{psi} union g_content(u)` is provably consistent via the generalized temporal K argument. The condition `G(neg psi) in deferralClosure` holds whenever `F(psi) in subformulaClosure(phi)`. This is the critical new discovery. Confidence: HIGH.

**Finding 5 -- Gap: targeted seed lacks f_step**: The targeted seed provides g_content propagation but NOT f_step (deferralDisjunctions are excluded). The recommended resolution is an existential chain approach: when forward_F is queried for a specific psi, build a ONE-STEP targeted witness chain rather than requiring the universal chain to resolve all F-obligations. Confidence: MEDIUM.

### Alternative Approaches (from Teammate B)

**Finding 6 -- Quasimodel bridge is MEDIUM-HIGH viable**: The sorry-free Quasimodel/ infrastructure (1,816 lines) can be bridged to BFMCS. `bx_le` gives `forward_G` for free. `bx_forward_witness` provides per-formula F-resolution. The main difficulty is Until/Since guard conditions (bx_le non-totality). Estimated 600-1000 LOC. Confidence: MEDIUM-HIGH for restricted_temporally_coherent, MEDIUM-LOW for full Until/Since coherence.

**Finding 7 -- Per-formula witness chain is most promising variant**: Instead of building ONE chain resolving all F-obligations, use `bx_forward_witness` per-formula when forward_F is queried. The FMCS forward_F property is existential (`exists s > t, psi in fam.mcs s`) -- the witness `s` can come from a per-formula chain. But the same F-persistence problem applies if using a linear chain. Confidence: MEDIUM.

**Finding 8 -- Filtration NOT viable for forward_F**: The Filtration/ infrastructure provides sigma ordering but no chain construction mechanism. Cannot independently close any sorry. Confidence: HIGH.

**Finding 9 -- Boneyard confirms universal pattern**: Every Boneyard approach using iterated Lindenbaum extension hits the same perpetual deferral wall. No Boneyard code comes close to proving forward_F. Confidence: HIGH.

### Gaps and Shortcomings (from Critic)

**Finding 10 -- Report 26 perpetual deferral is CONFIRMED**: The BX11 fold CAN permanently F-wrap the target. Compound F-formula monotonicity ensures ordering stabilization. No Ramsey or finite-automaton argument rescues the existing chain. Confidence: HIGH.

**Finding 11 -- Plan 28 has THREE unaddressed critical gaps**: (a) `bounded_witness` requires `SetMaximalConsistent`, not `DeferralRestrictedMCS`; (b) `iter_F_not_mem_closureWithNeg` proves departure from `closureWithNeg` not `deferralClosure`; (c) DRM states cannot plug into `CanonicalTask_forward_MCS`. Plan 28 significantly understates required work. Confidence: HIGH.

**Finding 12 -- "All 6 sorries form one cluster" is IMPRECISE**: Sorries 1-4 form a tight cluster depending solely on forward_F. Sorry 5 depends on forward_F through backward G. Sorry 6 has an ADDITIONAL independent obstacle: Until persistence through Lindenbaum chain steps (documented in task 84, TemporalCoherence.lean:486-494). Confidence: HIGH.

**Finding 13 -- `boundary_resolution_set` in SuccExistence.lean is relevant**: For formulas at the BOUNDARY of deferralClosure (F(chi) in deferralClosure but FF(chi) NOT), the DRM step directly resolves chi. This is exactly where single_step_forcing applies. But a DRM-specific version of the theorem is still needed. Confidence: MEDIUM-HIGH.

### Strategic Horizons (from Teammate D)

**Finding 14 -- Literature consensus on three proof families**: (a) Per-formula chains with outer induction on formula complexity (Burgess 1982); (b) Quasimodel-then-linearize (GHR 1994); (c) Semantic truth lemma argument where forward_F is a CONSEQUENCE not prerequisite (Goldblatt 1992). The project's approach (one chain, all obligations simultaneously) conflicts with all three families. Confidence: HIGH.

**Finding 15 -- No published formalization covers bidirectional LTL completeness**: This project would be the FIRST formalization of completeness for Until + Since over integers. Publishable even as partial result at ITP, CPP, or LICS workshop. Confidence: HIGH.

**Finding 16 -- DRM approach 45-55% probability, total 60-70%**: Across DRM + quasimodel bridge paths, the probability of eventually closing forward_F is estimated at 60-70%. The project should NOT pivot. Confidence: HIGH (assessment), MEDIUM (probabilities).

**Finding 17 -- Game-theoretic approach is theoretically clean but costly**: Lange/Stirling focus games avoid the chain construction entirely by making eventualities part of the game winning condition. But implementation requires 3000+ new LOC and abandoning existing infrastructure. Not recommended as primary path. Confidence: MEDIUM.

## Synthesis

### Conflicts Resolved

1. **Teammate A ("DRM bounded_witness blocked") vs Plan 28 ("apply bounded_witness within DRM")**

   Teammate A is correct. Plan 28's core premise -- that `bounded_witness` applies in DRM -- is wrong due to the `SetMaximalConsistent` type requirement. Teammate C independently confirms three concrete gaps. **Resolution**: Plan 28's Phase 2 (DRM bounded_witness) must be replaced with a different proof strategy.

2. **Teammate A ("targeted seed consistent") vs Teammate B ("same F-persistence problem")**

   Both are partially correct at different levels. The targeted seed `{psi} + g_content(u)` IS consistent (A), but a chain built from repeated targeted steps faces F-persistence loss (B). **Resolution**: Use the targeted seed for a ONE-STEP existential witness (not a full chain). Forward_F needs only `exists s > t, psi in chain(s)` -- the witness can come from a single targeted step at `t+1`.

3. **All 4 teammates agree**: The existing `rr_fwd_chain` cannot prove forward_F. A new construction is needed. The DRM approach needs fundamental revision (not just gap-filling).

### Gaps Identified

1. **The targeted seed f_step gap**: The targeted DRM successor from `{psi} + g_content(u)` has `psi` and g_content, but NOT f_step for other F-obligations. If the FMCS requires all of forward_G, backward_H, AND forward_F from the SAME chain, this single-step witness cannot be the chain step.

2. **Chain architecture mismatch**: The existing `dd_fmcs` expects an Int-indexed family where EVERY pair of consecutive states satisfies the same relation. A targeted-resolution approach produces DIFFERENT successor states depending on which formula is being witnessed. This requires either (a) redefining dd_fmcs to allow per-query witness chains, or (b) building a single chain that incorporates all targeted witnesses.

3. **Sorry 6 independence**: Even after closing forward_F and sorries 1-5, sorry 6 (forward Until/Since coherence) has an independent Until persistence obstacle. A complete solution requires addressing this separately.

4. **DRM-to-deferralClosure departure lemma**: The lemma `iter_F_not_mem_deferralClosure` (extending `iter_F_not_mem_closureWithNeg`) does not exist in the codebase and needs to be proved. Likely straightforward (~20 LOC).

### The Mathematically Correct Long-Term Solution

Synthesizing all findings, the mathematically correct approach has three components:

**Component 1: Existential Forward_F via Targeted BXPoint Resolution**

For the depth-0 base case of `rr_fwd_chain_forward_F`, the proof should be:

Given `F(psi) in chain(n)` with `f_nesting_depth(psi) = 0`:
1. Use `bx_forward_witness chain(n) psi` (sorry-free) to get BXPoint `v` with `bx_le chain(n) v` and `psi in v`.
2. `v` is a full MCS. `psi in v`.
3. The problem: `v` is not necessarily `chain(s)` for any `s`.

The resolution requires REDEFINING the chain so that `v` IS at some chain index. Two sub-approaches:

**Sub-approach 1a (Chain Replacement)**: Replace `rr_fwd_chain` with a chain that visits `bx_forward_witness` outputs. At each step, use `bx_forward_witness` for the round-robin target. This gives `psi in chain(visit_step + 1)` directly. But F-persistence through intermediate steps is the barrier (handoff 03).

**Sub-approach 1b (Existential Chain Extension)**: Keep `rr_fwd_chain` as-is for g_content/h_content properties. When forward_F is queried for `F(psi) in chain(n)`, extend the chain with a targeted witness:
- Build a DRM from `chain(n)` restricted to `deferralClosure(root)`
- Use the targeted seed `{psi} + g_content(chain(n))` (consistent by Finding 4)
- Lindenbaum-extend to a full MCS `M_witness`
- This `M_witness` has `psi in M_witness` and `g_content(chain(n)) subset M_witness`
- Define forward_F's existential witness `s = n + 1` with `chain_extended(n+1) = M_witness`

The difficulty: the extended chain may not have the same properties as the original chain at step n+1. If dd_fmcs requires a SINGLE chain with all properties, this approach requires careful surgery.

**Sub-approach 1c (Literature-Aligned, RECOMMENDED)**: Follow the Burgess/GHR architecture. Instead of proving forward_F as a chain property, restructure `dd_countermodel` to use the SEMANTIC forward_F (from `bx_forward_witness`) combined with the chain's other properties (g_content, modal coherence).

This requires modifying `fully_restricted_parametric_representation_from_neg_membership` or the restricted truth lemma to accept semantic forward_F rather than chain forward_F. The truth lemma already goes through the canonical frame (BXPoints), not through chain indices.

**Component 2: Quasimodel Bridge for Until/Since Coherence**

For sorries 5-6 (Until/Since coherence), the quasimodel infrastructure provides the right tool. The defect-discharge mechanism (sorry-free) handles Until eventualities directly. The bridge from quasimodel to BFMCS handles the guard condition.

**Component 3: DRM-specific Bounded_witness (Fallback)**

If Components 1-2 require too much restructuring, prove a DRM-specific version of `bounded_witness` + `single_step_forcing` that works within `deferralClosure`. This requires:
- `iter_F_not_mem_deferralClosure` (~20 LOC)
- `drm_single_step_forcing` using DRM negation completeness (~50 LOC)
- `drm_bounded_witness` carrying `DeferralRestrictedMCS` instead of `SetMaximalConsistent` (~80 LOC)

The DRM-specific approach adds ~150 LOC but avoids architectural changes.

### Recommendations

**Immediate priority (next plan revision)**:

1. **Prove the targeted seed consistency lemma** in Lean (from Finding 4). This is the key mathematical breakthrough: `{psi} union g_content(u)` is consistent when `F(psi) in u` and `psi in subformulaClosure(phi)`. Estimated: 50-80 LOC. This lemma is useful regardless of which architecture is chosen.

2. **Investigate Sub-approach 1c (truth lemma restructuring)**: Read `fully_restricted_parametric_representation_from_neg_membership` and the restricted truth lemma to determine if forward_F can be sourced from `bx_forward_witness` (semantic) rather than from chain indices. If the truth lemma already goes through BXPoints, the chain's forward_F may be unnecessary.

3. **Attempt DRM-specific bounded_witness** (Component 3): If the truth lemma restructuring is too invasive, prove the DRM-specific versions of single_step_forcing and bounded_witness. Teammate C's gap analysis provides the exact requirements.

4. **Prove `iter_F_not_mem_deferralClosure`**: Extension of `iter_F_not_mem_closureWithNeg` to the full deferralClosure. Needed by any DRM approach.

**If primary approaches fail**:

5. **Quasimodel bridge** (600-1000 LOC): Build Int-indexed FMCS families directly from the sorry-free Quasimodel infrastructure. Handles forward_F and Until coherence together.

6. **Partial publication**: Prepare ITP/CPP submission with the forward_F obstruction as an open formalization challenge.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | DRM bounded_witness + targeted seed | completed | high (blocked), high (seed consistent) |
| B | Quasimodel bridge + alternatives | completed | medium-high (bridge viable) |
| C | Critic (validate claims + gaps) | completed | high (3 gaps confirmed) |
| D | Literature + strategy | completed | high (literature), medium-high (DRM viability) |

## Dead Ends Confirmed (additions to ROAD_MAP)

- (27) DRM bounded_witness via single_step_forcing (negation completeness gap at F-nesting boundary)
- (28) Full MCS bounded_witness (F-reflexivity makes iter_F always present)
- (29) DRM chain preventing perpetual deferral (same Lindenbaum non-determinism as enriched chain)

## References

- Burgess, J.P. (1982/1984). "Axioms for tense logic I: Since and Until" / "Basic tense logic"
- Doczkal, C. and Smolka, G. (2014). "Completeness and decidability results for CTL in Coq"
- From, A.H. (2025). "Synthetic completeness for modal logic" (CPP)
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic" -- Oxford University Press
- Goldblatt, R. (1992). "Logics of Time and Computation" -- CSLI Lecture Notes
- Lange, M. and Stirling, C. (2001). "Focus games for satisfiability and completeness of LTL"
- DRMChain.lean:284 (sorry site)
- Frame.lean:164-171 (bx_forward_witness, sorry-free)
- SuccRelation.lean:232-268 (single_step_forcing, requires SetMaximalConsistent)
- CanonicalTaskRelation.lean:555-561, 650-678 (bounded_witness)
- TemporalCoherence.lean:486-494 (Until persistence obstacle documentation)
- WitnessSeed.lean:81-179 (forward_temporal_witness_seed_consistent)
