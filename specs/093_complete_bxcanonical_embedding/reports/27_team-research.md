# Research Report: Task #93 — Team Research Round 27

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776640200_b8e4f2

## Summary

Round 27 synthesizes findings from 4 teammates following Report 26's definitive proof that the existing `rr_fwd_chain` with `enriched_fwd_step` CANNOT prove `forward_F` due to perpetual deferral being semantically consistent. The team converges on two key conclusions:

1. **All direct axiom-level approaches to rescue the existing chain are blocked.** BX12 (F→Until bridge), BX5 (self-accumulation), BX6 (absorption), BX7 (Until linearity), and BX4/BX4' (connectedness) have all been exhaustively checked and provide no new information that could force ψ into the chain.

2. **The Goldblatt-style WF-induction chain is the most promising replacement**, using the simple `fwd_succ` step (already sorry-free via `forward_temporal_witness_seed_consistent`) with well-founded induction on deferral closure depth. The critical risk is circularity between `forward_F` and `backward_G`, mitigated by the explicit parameter design of `restricted_temporal_backward_G_strict`.

The team also establishes that **all 6 sorry sites form a single cluster** (Critic refutes prior claims of sorry-5/6 independence) and identifies 5 new dead ends (22-26) for the ROAD_MAP.

## Key Findings

### Primary Approach Analysis (from Teammate A)

**Finding 1 — BX12 bridge is semantically vacuous for chain construction**: Converting F(ψ) to (⊤ U ψ) via BX12 adds no new information. The Until formulas live in the same MCS states as the F-formulas they came from and do not interact productively with the chain construction. Confidence: HIGH.

**Finding 2 — BX5/BX6/BX7 operate within a single MCS**: Self-accumulation, absorption, and Until linearity are intra-MCS properties. They cannot force formulas into chain successor states. The chain's inter-MCS mechanism is exclusively through g_content/h_content propagation. Confidence: HIGH.

**Finding 3 — G(neg(ψ)) cannot be derived from chain properties alone**: Having neg(ψ) in every chain state does NOT give G(neg(ψ)) in any state. The backward-G argument requires forward_F as an explicit hypothesis — the core circularity. No BX axiom combination can break this circularity within the existing chain structure. Confidence: HIGH.

**Finding 4 — Omega-squared / dovetailing chain identified as viable**: Teammate A identifies resolving each F-defect on a separate subsequence (avoiding BX11 interaction entirely) as the most promising direction. This aligns with the TemporalContent.lean comments (lines 47-49) suggesting non-linear constructions.

### Alternative Approaches (from Teammate B)

**Finding 5 — Goldblatt WF-induction chain is the primary recommendation**: Replace `enriched_fwd_step` with `fwd_succ` (using `forward_temporal_witness_seed_consistent`, already sorry-free). Prove forward_F by well-founded induction on deferral closure depth. Estimated 400-600 new LOC, 200-300 modified LOC. The key infrastructure (`deferralClosure`, `max_F_depth_in_closure`, `forward_temporal_witness_seed_consistent`) is all sorry-free. Confidence: MEDIUM-HIGH (0.7).

**Finding 6 — Goldblatt's actual technique**: The standard construction processes F-formulas in order of complexity. At depth 0, formulas are immediately resolvable. At depth k+1, resolution may introduce obligations for depth ≤ k formulas, which are handled by the induction hypothesis. The `deferralClosure` infrastructure in `SubformulaClosure.lean` is designed for exactly this pattern.

**Finding 7 — Main risk: WF-induction circularity**: The backward-G argument requires forward_F for neg(φ), which has the SAME depth as φ. However, `restricted_temporal_backward_G_strict` (TemporalCoherence.lean:376) takes forward_F as an explicit parameter, enabling mutual induction on formula complexity. Whether this mutual induction actually terminates needs pen-and-paper verification.

**Finding 8 — Reynolds quasimodel bridge is viable fallback**: The 1,816 lines of sorry-free Quasimodel code can be concatenated into Int-indexed FMCS families, but requires 800-1200 new LOC for the bridge layer. Main difficulty: modal coherence across chain segments. Confidence: MEDIUM.

**Finding 9 — Approximation and LMCS approaches are both BLOCKED**: Both face the same G(F(χ)) obstruction from Report 26. Neither provides a path around the fundamental issue.

### Gaps and Shortcomings (from Critic)

**Finding 10 — Report 26 claims CONFIRMED with minor imprecision**: The 2-formula perpetual deferral counterexample is valid but has one imprecision: Report 26 claims F(ψ ∧ F(χ)) absent from chain, but its own semantic model has it TRUE. The main argument (perpetual deferral via fixed BX11 ordering) is unaffected. Confidence: HIGH.

**Finding 11 — G(F(χ)) non-derivability CONFIRMED**: Verified via explicit semantic countermodel: time domain {0,1,2}, p only at time 1. F(p) true at 0 but G(F(p)) false at 0. This is the irreducible obstruction. Confidence: 100%.

**Finding 12 — Sorry 5 and 6 are NOT independent — ALL 6 sorries form ONE cluster**: Sorry 6 (forward Until coherence) directly needs forward_F to extract witnesses from (φ U ψ) → F(ψ). Sorry 5 (backward Until coherence) needs forward_F for backward propagation of Until via backward_G. Prior reports incorrectly suggested sorry 5/6 might be independently closable. Confidence: HIGH.

**Finding 13 — BX12-based Until exploitation is likely circular**: Converting F(ψ) to (⊤ U ψ) and then using BX5/BX6 to derive structural constraints is unexplored in depth, but Teammate A's analysis confirms it provides no new inter-MCS information.

### Strategic Horizons (from Teammate D)

**Finding 14 — ROAD_MAP is significantly stale in 6 areas**:
1. All 6 sorry line numbers are wrong (+46 offset)
2. Module counts wrong (3,473 → 5,669 lines, 13 → 16 files)
3. Sorry inventory internally contradictory (claims both "1 sorry" and "6 sorries")
4. 3 files (39% of BXCanonical) missing from import graph: CanonicalModel.lean (498 lines), OrderedSeedConsistency.lean (255 lines), RootScopedChain.lean (1,454 lines)
5. Task cross-references stale (103 and 94 completed but listed as not started/planning)
6. Task 93 described as "chain replacement approach" which is now undetermined

**Finding 15 — 5 new dead ends for ROAD_MAP (22-26)**:
- (22) Defect re-entry in enriched chain (perpetual deferral scenario)
- (23) G(F(χ)) non-derivability blocking persistent-carry seed
- (24) Non-enriched chain F-obligation loss
- (25) Quasimodel BXPoint-to-Int bridging gap
- (26) Semantic coherence circularity (truth lemma requires forward_F)

**Finding 16 — Publishable partial result exists NOW**: Complete soundness (sorry-free), Until/Since eventuality resolution via defect-discharge (novel formalization technique, 2,289 lines), full truth lemma, canonical frame construction. The forward_F obstruction is a well-documented open problem. Publication venue: ITP, CPP, or LICS workshop.

**Finding 17 — Strategic recommendation: pen-and-paper first**: After 26 rounds of automated research exhaustively mapping the obstacle space, human mathematical insight is needed. Follow published proof techniques (Goldblatt 1992, Burgess 1984) more closely. Combined probability of eventually closing forward_F: ~60-70%.

## Synthesis

### Conflicts Resolved

1. **Teammate A ("direct axiom approach blocked") vs Teammate B ("Goldblatt WF-induction works")**

   These are NOT conflicting — they address different levels. Teammate A shows that NO axiom-level argument can rescue the EXISTING chain. Teammate B proposes REPLACING the chain with a fundamentally different construction (simple `fwd_succ` steps + WF induction). Both are correct: the existing chain is provably unfixable, but a new chain design may work.

2. **Teammate B ("forward_F via WF induction, confidence 0.7") vs Teammate D ("pen-and-paper first, confidence N/A")**

   Teammate B's WF-induction approach has a genuine risk (circularity between forward_F and backward_G for formulas of the same depth). Teammate D recommends resolving this risk on paper before Lean implementation. **Resolution**: Pen-and-paper verification of the WF measure is the critical next step. The Goldblatt approach is the primary candidate to verify.

3. **All 4 teammates agree**: The existing chain cannot prove forward_F. The project should NOT be abandoned. A modified chain construction is the path forward.

### Gaps Identified

1. **The WF-induction circularity gap**: Teammate B identifies the risk that backward_G requires forward_F for neg(φ), which has the same depth as φ. The `restricted_temporal_backward_G_strict` explicit parameter design is the proposed mitigation, but formal verification of the mutual induction termination is missing. This is the #1 gap.

2. **F-obligation persistence in the simple chain**: The Goldblatt chain uses `fwd_succ` (no f_carry). F-obligations can disappear. The WF-induction proof must handle the case where F(ψ) disappears before ψ's visit step. Teammate B's analysis shows this is the crux of the "If F(psi) NOT in chain(n)" branch.

3. **Sorry 5/6 closure after forward_F**: Even with forward_F proved, sorry 5 (backward Until coherence) and sorry 6 (forward Until coherence) may require additional step-transfer arguments. The exact requirements need analysis.

4. **ROAD_MAP update scope**: Teammate D's audit identifies extensive staleness. A dedicated task for ROAD_MAP update would be valuable.

### Recommendations

**Immediate priority (pen-and-paper, 8-20 hours)**:
1. Work out the Goldblatt WF-induction argument on paper, specifically:
   - Define the exact well-founded measure on deferralClosure formulas
   - Verify mutual induction between forward_F and backward_G terminates
   - Handle the F-obligation disappearance case (F(ψ) NOT in chain at visit step)
   - Verify the base case (depth-0 formulas resolvable in one step)

**If pen-and-paper succeeds (40-80 hours Lean)**:
2. Replace `rr_fwd_chain` body with simple `fwd_succ` chain
3. Prove `rr_fwd_chain_forward_F` by WF induction
4. Close remaining 5 sorries (most follow from forward_F)

**If pen-and-paper fails**:
5. Fall back to Reynolds quasimodel bridge (800-1200 new LOC)
6. Or investigate the omega-squared/dovetailing approach from Teammate A

**Independent of forward_F**:
7. Update ROAD_MAP.md with findings from this research (5 new dead ends, corrected metrics)
8. Consider publishing the partial result (Until/Since closure as novel contribution)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Direct axiom-level argument | completed | high (that it's blocked) |
| B | Literature chain constructions | completed | medium-high (Goldblatt approach) |
| C | Critic (validation + gaps) | completed | high |
| D | Horizons (ROAD_MAP + strategy) | completed | high (factual), medium (strategic) |

## References

- Burgess, J.P. (1982/1984). "Axioms for tense logic I: Since and Until" / "Basic tense logic"
- Goldblatt, R. (1992). "Logics of Time and Computation" — CSLI Lecture Notes
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic" — Oxford University Press
- Reynolds, M. (2003). Temporal logic completeness techniques
- Report 24: Team research (defect re-entry gap analysis)
- Report 25: BFMCS Quasimodel Witnesses (first-principles analysis)
- Report 26: Defect Re-Entry Analysis (definitive impossibility proof)
- SubformulaClosure.lean: deferralClosure, max_F_depth_in_closure
- WitnessSeed.lean: forward_temporal_witness_seed_consistent
- TemporalCoherence.lean:376: restricted_temporal_backward_G_strict (explicit forward_F parameter)
