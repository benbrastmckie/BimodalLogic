# Research Report: G-Liftability Blocker Analysis

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Type**: Blocker Analysis
**Status**: Research Complete

## Executive Summary

The bidirectional temporal witness construction (plan v4) is blocked at Phase 2 because **H_theory elements are not G-liftable**. This report analyzes the mathematical structure of the blocker, investigates whether it can be weakened or avoided, and recommends a path forward.

**Key Finding**: The formula `H(a) -> G(H(a))` is **not valid** in the TM axiom system. This is semantically correct - in linear time with S5 modal accessibility, having "always in the past a" does NOT imply "it will always be that always in the past a". The past can grow.

**Recommendation**: Abandon the bidirectional seed approach. Use the **separate-direction witnesses** strategy, where F-witnesses use temporal_box_seed and P-witnesses use past_temporal_box_seed, then combine at the chain level.

## 1. The G-Liftability Requirement

### 1.1 What G-Liftability Means

A set S is **G-liftable from M** if for all x in S, G(x) in M.

This property is critical for the consistency proof of `temporal_theory_witness_consistent`:

```
If L subset {phi} union temporal_box_seed(M) derives bot, then:
1. L_no_phi derives neg(phi)
2. G-lift L_no_phi: since all elements are G-liftable, we get G(neg(phi)) in M
3. But F(phi) in M means neg(G(neg(phi))) in M
4. Contradiction
```

### 1.2 Why Bidirectional Seed Fails

The bidirectional_temporal_box_seed is defined as:
```
bidirectional_temporal_box_seed M := G_theory M union H_theory M union box_theory M
```

Where:
- G_theory M = {G(a) | G(a) in M} - G-liftable (by temp_4: G(a) -> G(G(a)))
- box_theory M = {Box(a) | Box(a) in M} - G-liftable (by temp_future: Box(a) -> G(Box(a)))
- H_theory M = {H(a) | H(a) in M} - **NOT G-liftable**

The sorries at lines 3864 and 4271 of UltrafilterChain.lean mark exactly this gap.

## 2. Semantic Analysis: Why H(a) -> G(H(a)) Is Invalid

### 2.1 Semantic Interpretation

In linear temporal logic with reflexive semantics:
- H(a) at time t means: for all s <= t, a holds at s
- G(H(a)) at time t means: for all r >= t, for all s <= r, a holds at s

G(H(a)) is equivalent to: for all s in Z, a holds at s (i.e., always(a)).

### 2.2 Countermodel

Consider a linear timeline {..., -1, 0, 1, 2, ...} and formula a = "x > 0".

At time t = 1:
- H(a) holds: for all s <= 1, x > 0 at s (assuming x = s)
- Actually this is false since at s = 0, x = 0.

Better countermodel: Let a be true exactly at times {..., -2, -1, 0, 1}.

At time t = 1:
- H(a) holds: a is true at all s <= 1 (check: true at -2, -1, 0, 1)
- G(H(a)) fails: at time t = 2, H(a) requires a at all s <= 2, but a is false at s = 2

The past **grows** as time advances. H(a) at time 1 does not guarantee H(a) at time 2 unless a holds at time 2.

### 2.3 Axiom System Check

The TM axiom schema includes:
- temp_4: G(a) -> G(G(a)) (the future is transitively closed)
- temp_t_future: G(a) -> a (reflexive future)
- temp_l: always(a) -> G(H(a)) (perpetuity implies future-past)
- temp_a: a -> G(P(a)) (temporal connectedness)

There is NO axiom `H(a) -> G(H(a))`. The closest is temp_l, which requires always(a) = H(a) and a and G(a), not just H(a).

## 3. Can the Requirement Be Weakened?

### 3.1 Option: Prove H_theory Elements Don't Contribute to neg(phi)

**Hypothesis**: If L subset bidirectional_seed derives neg(phi), then L intersect H_theory is "harmless" - removing it still allows the derivation.

**Analysis**: This is difficult to formalize because derivations can use H-formulas substantively. For example:
- H(neg(phi)) in H_theory
- {H(neg(phi)), phi} |- bot (via temp_t_past and contradiction)

If phi and H(neg(phi)) are both in the seed, the seed is inconsistent. But this scenario is blocked: F(phi) in M means neg(G(neg(phi))) in M, which is compatible with H(neg(phi)) in M.

However, more subtle interactions exist. The general case is hard to rule out.

**Verdict**: Not feasible without deep proof-theoretic analysis.

### 3.2 Option: Use Subset Argument

**Hypothesis**: bidirectional_seed subset {phi} union M, and if F(phi) in M, then {phi} union M is consistent.

**Analysis**: This is FALSE. F(phi) in M means "eventually phi" but neg(phi) can still be in M (phi false now but true eventually). So {phi} union M can be inconsistent when both phi and neg(phi) are in M... but wait, M is MCS so at most one of phi, neg(phi) is in M.

Actually, if neg(phi) in M, then F(phi) in M contradicts... no, F(phi) = neg(G(neg(phi))), so:
- neg(phi) in M
- F(phi) = neg(G(neg(phi))) in M

These are consistent! phi is false now, but neg(G(neg(phi))) says "not always neg(phi)" - phi will be true eventually.

So {phi} union M can be inconsistent when neg(phi) in M. The seed must be chosen to avoid including neg(phi).

**Verdict**: The subset argument doesn't work directly.

### 3.3 Option: Restricted H_theory

**Hypothesis**: Include only "safe" H-formulas that don't interfere with phi.

**Analysis**: Defining "safe" is complex and defeats the purpose of preserving all H-theory for the P-witness direction.

**Verdict**: Complicates the construction without clear benefit.

## 4. Alternative Approaches

### 4.1 Separate-Direction Witnesses (Recommended)

**Strategy**: Don't try to combine F-witness and P-witness construction. Use:
- For F(phi) resolution: temporal_theory_witness (G_theory + box_theory) - already proven consistent
- For P(phi) resolution: past_theory_witness (H_theory + box_theory) - already proven consistent

Each witness is built with its direction-appropriate seed. Cross-direction coherence is achieved at the **chain level**, not the single-witness level.

**How Cross-Direction Coherence Works**:
1. Forward chain: Each step uses F-witness, preserving G-theory (by construction) and also preserving H-theory (by Succ relation's h_content subset property)
2. Backward chain: Each step uses P-witness, preserving H-theory (by construction) and also preserving G-theory (by Succ relation's g_content subset property)

The key insight: The Succ relation already provides:
- g_content(M) subset M' (G-formulas persist forward)
- h_content(M') subset M (H-formulas persist backward)

So even though individual witnesses don't preserve both directions, the **chain** does.

### 4.2 Existing SuccChainFMCS Infrastructure

The codebase already has:
- SuccChainFMCS.lean: forward_chain and backward_chain construction
- succ_chain_forward_G: G(phi) propagates forward through the chain
- succ_chain_backward_H: H(phi) propagates backward through the chain

These are sorry-free for same-direction propagation!

**Gap**: forward_F and backward_P (existence witnesses) are marked as having issues due to unbounded nesting. But the G/H propagation (universal quantification) works.

### 4.3 Bundle-Level Coherence

**Strategy**: Weaken the temporal coherence requirement to bundle level:
- F(phi) at (tau, t) implies phi at (tau', t') for some tau' and t' > t (not necessarily tau)
- This is semantically different but may be sufficient for some completeness statements

**Verdict**: This fundamentally changes the semantics and would require reworking the truth lemma. Not recommended unless same-family coherence is provably impossible.

## 5. What Does H(a) -> G(H(a)) Actually Require?

Interestingly, the comments in UltrafilterChain.lean (lines 4240-4254) sketch why this WOULD be valid in linear time:

> In linear tense logic, F(neg(H(a))) and H(a) CANNOT coexist in an MCS.
> Because H(a) = always in the past a, and F(neg(H(a))) = eventually, not always in the past a.
> In linear time, once H(a) is true, it remains true in the future (past is fixed).
> So G(H(a)) follows from H(a) in linear time!

This reasoning is **semantically correct for a fixed timeline**. The past from any future point includes the current past plus additional history. If a held at all past times up to now, it held at all past times up to any future point (the shared past).

**But**: This requires a specific axiom for linear time that we don't have. The temp_linearity axiom handles F/P ordering but doesn't directly give H(a) -> G(H(a)).

### 5.1 Derivation Attempt

Could we derive H(a) -> G(H(a)) from existing axioms?

Approach: Use modal interaction.
- S5 gives Box(Diamond(a)) from a (modal_b)
- temp_future gives Box(a) -> G(Box(a))

But connecting H to Box is the challenge. We don't have H(a) -> Box(H(a)) or similar.

**Verdict**: If H(a) -> G(H(a)) were derivable, the comments in the codebase would not note it as a gap. The derivation is likely impossible without adding a new axiom.

### 5.2 Axiom Extension Option

Adding H(a) -> G(H(a)) as an axiom would:
- Make the bidirectional construction work
- Be semantically valid for linear time
- Potentially change the proof-theoretic properties of TM

This is a significant change and should be a separate task if pursued.

## 6. Recommendation

### Primary Path: Separate-Direction Chain Construction

1. **Keep temporal_theory_witness and past_theory_witness separate**
   - These are already proven consistent (sorry-free)
   - Each uses the appropriate direction's seed

2. **Leverage existing SuccChainFMCS infrastructure**
   - forward_G and backward_H already work
   - Focus on fixing forward_F and backward_P via fair-scheduling or restricted completeness

3. **Archive bidirectional_seed construction**
   - Mark as experimental/blocked
   - Document the H(a) -> G(H(a)) gap

### Secondary Path: Investigate H(a) -> G(H(a)) Derivation

Create a separate research task to:
1. Formally verify whether H(a) -> G(H(a)) is derivable from TM
2. If not, analyze whether adding it as axiom preserves completeness
3. If adding is acceptable, implement the extension and revisit bidirectional construction

## 7. Files Examined

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 3799-4280)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean`
- `Theories/Bimodal/Theorems/Perpetuity.lean`

## 8. Summary

| Question | Answer |
|----------|--------|
| Can bidirectional approach be salvaged? | Not without new axiom H(a) -> G(H(a)) |
| Can H_theory be proven harmless? | Difficult, no clear path |
| Alternative approaches? | Separate-direction witnesses + chain-level coherence |
| What existing infrastructure helps? | SuccChainFMCS has sorry-free forward_G/backward_H |
| Recommended path forward? | Abandon bidirectional seed; use separate F/P witnesses |
