# Phase 5 Handoff: Wiring Deterministic Chain to Completeness

## Current State

Phases 1-4 are COMPLETED:
- Phase 1: X-K, X-Det, Y-K, Y-Det axioms added to TM system
- Phase 2: x_content/y_content proved to be MCS
- Phase 3: Deterministic chain with sorry-free Until/Since persistence
- Phase 4: ParametricTruthLemma Until/Since cases closed (using h_uc hypothesis)

Phase 5 is IN PROGRESS with substantial analysis completed but no sorry closures.

## Key Files Modified (Phases 1-4)

- `Theories/Bimodal/ProofSystem/Axioms.lean` - 4 new axiom constructors
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean` - deterministic chain + properties
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Until/Since cases via h_uc
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - added temporal_backward_G_with_fwd_F helpers

## New Infrastructure (Phase 5 Partial)

Added to `TemporalCoherence.lean`:
- `temporal_backward_G_with_fwd_F`: version of temporal_backward_G that takes forward_F as explicit function argument (not from TemporalCoherentFamily)
- `temporal_backward_H_with_bwd_P`: symmetric dual

Added to `DeterministicChain.lean`:
- `G_persists_forward_one_step`: G(phi) at chain(n) implies G(phi) at chain(n+1)
- `G_persists_forward`: G(phi) persists to chain(n+k) for all k
- `forward_G_nat`: G(phi) at chain(n), n < m implies phi at chain(m)
- `H_persists_backward_one_step`, `H_persists_backward`, `backward_H_negSucc`: symmetric

## The Central Blocker: Forward F-Resolution

### Problem Statement

`forward_F(psi)`: F(psi) in chain(t) implies exists s > t, psi in chain(s).

This is needed for:
1. `temporally_coherent` (unrestricted temporal coherence for BFMCS)
2. `until_since_coherent` (Until/Since semantic coherence) - forward_until needs forward_F
3. The backward G case in the truth lemma (via temporal_backward_G)

### Why It's Circular

- The truth lemma backward at G(psi) needs forward_F at neg(psi)
- forward_F at neg(psi) needs the truth lemma backward at G(neg(neg(psi)))
- which needs forward_F at neg(neg(neg(psi)))
- Each application adds two negations, creating infinite regress

### Approaches Analyzed

1. **Well-founded induction on formula size**: FAILS because temporal_backward_G adds negations (size increases, not decreases)

2. **Until-depth induction**: Partially works for Until/Since cases but NOT for forward_F at Until-depth 0 (G/H formulas still need forward_F with growing negation depth)

3. **Restricted F-nesting bound**: Works for DeferralRestrictedMCS chains (bounded F-nesting) but NOT for full MCS chains like succ_chain_fam or deterministic_chain

4. **Direct chain argument**: F(psi) -> T U psi, Until persistence propagates, but termination requires either (a) the truth lemma or (b) G(neg(psi)) membership which requires forward_F

5. **Model-theoretic / simultaneous construction**: Prove truth lemma + forward_F + until_coherent simultaneously. This is the CORRECT approach but requires restructuring the truth lemma proof.

### Recommended Resolution

**Option A: Mutual Induction Approach** (estimated 6-10 hours)

Define a combined proposition:
```
Package(k) := for all psi with Until-depth(psi) <= k:
  truth_lemma(psi) AND forward_F(psi) AND backward_P(psi)
```

Prove by induction on k:
- Package(0): truth lemma for Until-depth 0 + forward_F for all formulas. The forward_F proof uses the truth lemma at G(neg(psi)) which has Until-depth 0. But this still has the negation regress issue at Until-depth 0.

The resolution at depth 0: use the truth lemma to establish G(neg(psi)) membership non-constructively. The truth lemma at G(neg(psi)) forward direction (G(neg(psi)) in chain(t) -> truth(G(neg(psi)), t)) + contrapositive gives: G(neg(psi)) not in chain(t) -> neg(truth(G(neg(psi)), t)). Combined with semantic truth of G(neg(psi)) from neg(psi) at all future times, this gives a contradiction.

The KEY: this approach uses the truth lemma only in the FORWARD direction for G, which does NOT need forward_F (only fam.forward_G from the FMCS structure).

So the correct decomposition is:
1. Truth lemma FORWARD (MCS -> truth): needs only forward_G, backward_H (from FMCS)
2. Forward_F: uses truth lemma forward at G formulas + truth lemma backward at neg(psi) formulas. The backward at neg(psi) is the imp case composed with smaller formulas, which by formula-size induction is available.

This MIGHT break the circularity. The truth lemma backward at G(psi) uses forward_F, but forward_F uses the truth lemma forward at G(neg(psi)) (which is independent of forward_F) plus the truth lemma backward at neg(psi) (which is the imp case, using truth lemma at smaller formulas).

**Option B: Restricted Chain Approach** (estimated 4-6 hours)

Use the DeferralRestrictedMCS chain (which has sorry-free F-nesting bounds and hence sorry-free restricted forward_F), then embed it into the completeness argument. This requires:
1. Completing the restricted backward chain construction
2. Building a restricted FMCS from the restricted chains
3. Proving the restricted truth lemma with Until/Since coherence

**Option C: Parametric Truth Lemma Path** (estimated 8-12 hours)

Build a new completeness path using parametric_canonical_truth_lemma (which takes h_tc and h_uc as separate hypotheses). Prove h_tc and h_uc for the deterministic chain. This requires solving the forward_F problem for h_tc and the until forward problem for h_uc.

## Cross-Boundary G/H Issue

The deterministic chain's forward and backward arms are connected only through M_0. G(phi) at a negative position does NOT automatically propagate to positive positions because:
- G(phi) in chain(-(n+1)) = y_content^{n+1}(M_0) means Y^{n+1}(G(phi)) in M_0
- Getting G(phi) in M_0 from Y^{n+1}(G(phi)) in M_0 requires the derivation Y(G(phi)) -> G(phi)
- This derivation IS sound (G at t-1 means phi at all s > t-1, including all s > t, so G at t)
- But the SYNTACTIC derivation has not been established in the TM axiom system

The dovetailed chain DOES handle cross-boundary G/H correctly and is sorry-free for forward_G and backward_H. It only has sorries in forward_F and backward_P.

## Recommendations for Next Agent

1. Start with Option A: try the mutual induction approach, decomposing the truth lemma into forward-only (no forward_F needed) and backward (needs forward_F from induction)
2. If Option A is too complex, fall back to Option B with the restricted chain
3. The deterministic chain's Until/Since persistence (Phases 2-3) is the KEY infrastructure - any approach should leverage it
4. The parametric truth lemma (sorry-free) handles Until/Since via h_uc - build on this

## Files Needing Changes

- `TemporalCoherence.lean` - temporal_backward_G helpers (DONE)
- `DeterministicChain.lean` - G/H persistence within arms (DONE), need DeterministicFMCS
- `DovetailedChain.lean` - close forward_F/backward_P sorries (main target)
- `CanonicalConstruction.lean` - close Until/Since in restricted_shifted_truth_lemma
- `Completeness.lean` - wire completeness_over_Int through sorry-free path
- `ParametricRepresentation.lean` - fix broken countermodel_implies_not_provable (missing h_uc arg)
