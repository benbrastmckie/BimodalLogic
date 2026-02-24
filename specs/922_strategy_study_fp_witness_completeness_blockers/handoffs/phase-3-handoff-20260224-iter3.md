# Handoff: Phase 3 - Linearity Theorem Blocker

**Task**: 922 - Canonical Quotient Completeness Proof
**Session**: sess_1771960688_9a2e76
**Date**: 2026-02-24
**Phase**: 3 of 5
**Status**: BLOCKED - linearity theorem proof blocked on frame correspondence

## Immediate Next Action

Prove the frame correspondence theorem for the linearity axiom, then use it to close
`canonical_reachable_linear` in `CanonicalEmbedding.lean`.

**Specifically**: Prove that if the linearity axiom schema
`F(p) AND F(q) -> F(p AND q) OR F(p AND F(q)) OR F(F(p) AND q)`
is valid on a Kripke frame (W, R), then R is a linear order on the reachable fragment.

This requires working with arbitrary valuations, not just the canonical valuation. The
standard argument uses a "distinguishing valuation" that separates incomparable worlds.

## Current State

### Files Modified (Iteration 3)

| File | Status | Sorries |
|------|--------|---------|
| `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | Complete | 0 |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` | Partial | 1 |

### New Proven Lemmas (Iteration 3)

- `canonical_F_of_mem_successor`: If CanonicalR M M' and phi in M', then F(phi) in M.
  Proof by contraposition: F(phi) not in M -> G(neg phi) in M -> neg phi in M' -> contradiction.
  (Lines 184-211 of CanonicalEmbedding.lean)

- `canonical_P_of_mem_past_successor`: Past version of above.
  (Lines 213-227 of CanonicalEmbedding.lean)

### Sorry-Backed Theorem

- `canonical_reachable_linear` (line 271 of CanonicalEmbedding.lean):
  If CanonicalR M M1 and CanonicalR M M2, then M1 and M2 are comparable.
  1 sorry.

## Key Decisions Made

1. **Syntactic proof approach does NOT work for linearity**: Extensive exploration (documented
   in plan file Phase 3 progress) shows that applying temp_linearity within individual MCSes
   creates circular dependencies. Each application produces new witnesses whose comparability
   requires the same theorem being proved.

2. **Frame correspondence is the correct approach**: The standard textbook proof (Goldblatt,
   Venema) uses a semantic argument: if the linearity axiom is valid on a frame, define a
   valuation that separates two incomparable worlds, derive that the axiom instance is false
   at their common predecessor, contradicting validity. This argument does NOT have the
   circularity problem because it works at the frame/valuation level, not the MCS level.

3. **Canonical existence lemmas are key infrastructure**: The bidirectional characterization
   of F(phi) in M (iff exists M' with MRM' and phi in M') is essential for the linearity
   proof and was not available before this iteration.

## What NOT to Try

1. **Substituting alpha and phi directly into temp_linearity at M**: All 3 cases produce
   witnesses but cannot be related to M1/M2 without the linearity theorem itself. Spent
   ~2 hours verifying this is circular.

2. **Substituting G(alpha) and G(phi)**: Cases 2 and 3 reduce to Case 1 via temp_4
   propagation. Case 1 gives W with G(alpha) AND G(phi), but W's relationship to M1/M2
   is unknown. Using linearity to determine this is circular.

3. **Secondary linearity on G(alpha AND phi) vs neg(phi)**: Cases 1-2 of the secondary
   application are provably impossible (phi AND neg(phi) at same world or propagation
   thereof). Case 3 (F(F(G(alpha AND phi)) AND neg(phi))) creates configuration where
   neg(phi) is at an earlier time than G(alpha AND phi), which is consistent in linear
   time and NOT directly contradictory.

4. **Self-perpetuating formulas (alpha AND G(alpha))**: Similar analysis. Cases 1-2 closed
   by alpha AND neg(alpha) contradiction. Case 3 remains open.

## Critical Context

1. The canonical frame (CanonicalFrame.lean) provides forward_F, backward_P, forward_G,
   backward_H, reflexivity, and transitivity - all proven with 0 sorries.

2. The canonical existence lemmas (CanonicalEmbedding.lean) provide the bidirectional
   characterization: F(phi) in M iff exists M' with MRM' and phi in M'.

3. Once `canonical_reachable_linear` is proven, the remaining phases (4-5) should be
   straightforward: embed the linearly ordered countable reachable fragment into Int.

4. The temp_linearity axiom was added in Phase 1 with soundness proofs. It IS sound for
   linear integer time semantics.

5. An alternative approach (bypassing linearity entirely) would be to modify the
   DovetailingChain construction to use canonical frame witnesses, but all 12 prior plans
   tried variants of this and failed due to F-persistence through GContent seeds.

## Recommended Approach for Successor

### Option A: Frame Correspondence (Recommended)

1. Define a general Kripke frame type (or use existing temporal semantics).
2. Prove: if F(p) AND F(q) -> F(p AND q) OR F(p AND F(q)) OR F(F(p) AND q) is valid
   on frame (W, R), then for all w, u, v with wRu and wRv: uRv or vRu.
3. Proof sketch: Assume wRu, wRv, NOT uRv, NOT vRu. Choose a propositional variable p
   not occurring in the existing formula language (or use the distinguishing formula trick).
   Define valuation V(p) = {x | uRx or x = u}. Then F(p) true at w (witnessed by u).
   Define V(q) = complement. Then F(q) true at w. But F(p AND q) is false (no world has
   both p and q), F(p AND F(q)) is false (at u, p is true but no successor of u has q
   unless that successor is a successor of v too), etc.
4. Apply to the canonical frame (which validates all TM theorems including temp_linearity).

### Option B: Direct MCS Argument with Well-Founded Induction

The circular dependency might be breakable via well-founded induction on formula complexity.
The witness alpha (for NOT M1 R M2) has some formula complexity. If the secondary witnesses
produced by linearity have strictly lower complexity, induction terminates. This requires
careful analysis of how temp_linearity's cases affect formula complexity.

### Option C: Accept Sorry and Focus on Phase 4

If the linearity proof is too hard, accept the sorry on `canonical_reachable_linear` and
proceed with Phases 4-5, building the BFMCS Int construction assuming linearity. This
would leave 1 sorry (replacing the 2 sorries in DovetailingChain), which is still progress.

## References

- Plan: `specs/922_.../plans/implementation-001.md`
- Research: `specs/922_.../reports/research-001.md`, `research-002.md`
- Phase 1 output: `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean`
- Phase 2 output: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- Phase 3 output: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`
