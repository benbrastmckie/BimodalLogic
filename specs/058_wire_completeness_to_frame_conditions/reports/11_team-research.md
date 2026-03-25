# Research Report: Task #58 — G-Theory Propagation Gap Resolution

**Task**: Wire completeness to frame conditions
**Date**: 2026-03-25
**Mode**: Team Research (3 teammates)
**Session**: sess_1774480375_d641c3
**Prior Reports**: 09_team-research.md (task 64, omega-enumeration architecture)

## Summary

This report addresses the 5 sorries introduced by the omega-enumeration BFMCS implementation (Phases 4-5), focusing on the G-theory propagation gap at the Z-chain boundary. All three proposed solutions face fundamental mathematical obstacles, but the analysis reveals a deeper structural insight that opens a viable path forward.

**Key finding**: The problem is deeper than G-theory propagation alone. The Z-chain has two categories of sorry:
1. **Universal propagation** (forward_G, backward_H): G/H-formulas don't propagate across the chain boundary
2. **Existential witnesses** (forward_F, backward_P): F-obligations in the backward chain and P-obligations in the forward chain are never resolved

Category 2 is what `BFMCS.temporally_coherent` actually requires. Category 1 is needed for the truth lemma's forward direction for G(phi).

## Key Findings

### 1. Extended Witness Theorem: NOT Provable (Teammate A)

**Result**: `{phi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M)` cannot be proven consistent.

**Root cause**: The consistency proof requires G-lifting ALL seed elements. H_theory elements are NOT G-liftable because:
- `G_of_temporal_box_seed` requires elements to have their G-version in M
- H(a) ∈ M does NOT imply G(H(a)) ∈ M without also having G(a) ∈ M
- The only G-H interaction is via `temp_l`: `H(a) ∧ G(a) → G(H(a))`, which needs BOTH

**Confidence**: HIGH

### 2. Bundle-Level Coherence: NOT Viable (Teammate C)

**Result**: Weakening temporal coherence to bundle-level fundamentally breaks the truth lemma.

**Root cause**: The truth lemma for G(phi) requires witnesses at the SAME family:
- G(phi) semantics: `∀ s ≥ t, truth_at M Omega τ s phi` — same history τ
- The backward direction uses contraposition via `temporal_backward_G`:
  - Assume G(phi) ∉ fam.mcs(t)
  - Get F(¬phi) ∈ fam.mcs(t) by MCS duality
  - By forward_F: ∃ s > t with ¬phi ∈ **fam**.mcs(s)
  - Contradiction with phi ∈ **fam**.mcs(s) from hypothesis
- With bundle-level: ¬phi would be in **fam'**.mcs(s), no contradiction

**Why Box is different**: Box quantifies over different histories (σ ∈ Omega), while G quantifies over different times in the SAME history.

**Confidence**: HIGH

### 3. Alternative Chain Architectures (Teammate B)

| Architecture | Feasibility | Issue |
|-------------|-------------|-------|
| Double-rooted chains | LOW | Disconnected chains, no coherent timeline |
| Interleaved F/P steps | LOW | G/H theories oscillate, neither accumulates |
| Dual-theory witness (GH-intersection) | MEDIUM-HIGH | Provable for eternal formulas only |
| Bundle-level connection | DEAD | See finding 2 above |

**Most promising**: Architecture 3 (dual-theory witness), restricted to "eternal" formulas where both G(a) and H(a) are in M0.

**Confidence**: MEDIUM

## Synthesis

### The Deeper Problem

The 5 sorries decompose into two distinct categories:

| Sorry | Category | Required By |
|-------|----------|-------------|
| `Z_chain_forward_G` (2 sorries) | Universal propagation | Truth lemma forward direction for G |
| `Z_chain_backward_H` (1 sorry) | Universal propagation | Truth lemma forward direction for H |
| `Z_chain_forward_F` (1 sorry) | Existential witness | BFMCS.temporally_coherent |
| `Z_chain_backward_P` (1 sorry) | Existential witness | BFMCS.temporally_coherent |

**Category 2 (existential)** is what the BFMCS definition requires:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t, ∀ φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧   -- forward_F
    (∀ t, ∀ φ, P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s)      -- backward_P
```

**Category 1 (universal)** is needed by the truth lemma's FORWARD direction for G(phi):
- G(phi) ∈ fam.mcs(t) → ∀ s > t, phi ∈ fam.mcs(s)
- This requires G-theory to propagate through the entire chain

### GH-Intersection Seed: Provably Consistent

Define `GH_theory(M0)` = {G(a) | G(a) ∈ M0 ∧ H(a) ∈ M0} (the "eternal" G-formulas).

**Claim**: The modified backward chain seed `{psi_n} ∪ H_theory(backward(n)) ∪ GH_theory(M0) ∪ box_theory(backward(n))` IS consistent.

**Proof sketch**:
1. For G(a) ∈ GH_theory(M0): both G(a) ∈ M0 and H(a) ∈ M0
2. By dual of temp_l: G(a) ∧ H(a) → H(G(a)), so H(G(a)) ∈ M0
3. H(G(a)) propagates through backward chain via H-theory preservation
4. Therefore G(a) is H-liftable at each backward step: H(G(a)) ∈ backward(n)
5. Standard H-lifting consistency proof applies to full modified seed

**Impact**: This gives `GH_theory(M0) ⊆ backward(n)` for all n.

### Why GH-Intersection Partially Resolves forward_F

With GH_theory(M0) in the backward chain:

If F(phi) ∈ backward(n):
- F(phi) = ¬G(¬phi), so G(¬phi) ∉ backward(n)
- If G(¬phi) ∈ GH_theory(M0): G(¬phi) ∈ backward(n), contradiction
- Therefore G(¬phi) ∉ GH_theory(M0)
- Two sub-cases:
  - **(a) G(¬phi) ∉ M0**: Then F(phi) ∈ M0, and the forward chain resolves it ✓
  - **(b) G(¬phi) ∈ M0 but H(¬phi) ∉ M0**: Non-eternal case. F(phi) ∉ M0 because G(¬phi) ∈ M0. Forward chain has ¬phi at all times (from G(¬phi)). Witness must come from backward chain at time between t and 0.

**Sub-case (b) is the remaining gap.** The backward chain doesn't resolve F-obligations, so phi might not appear at any time > t.

### Fundamental Constraint

The core mathematical constraint is:

> **In TM over ℤ, a single chain construction cannot simultaneously resolve F-obligations (requiring future witnesses) and P-obligations (requiring past witnesses) while preserving both G-theory (future universal) and H-theory (past universal).**

This is because:
- Forward witnesses (temporal_theory_witness_exists) preserve G but not H
- Backward witnesses (past_theory_witness_exists) preserve H but not G
- Interleaving causes oscillation (neither accumulates)
- The extended seed (preserving both) is provably NOT consistent in general

### Recommended Path Forward

**Strategy: Prove forward_F and backward_P directly, bypassing forward_G and backward_H.**

The truth lemma's BACKWARD direction for G(phi) only needs forward_F (via contraposition). The FORWARD direction needs forward_G. But forward_G might be derivable from forward_F + MCS properties if we strengthen the chain construction.

**Concrete approach**:

1. **Prove GH-intersection seed consistency** (straightforward, ~2h):
   - Define `GH_theory(M0)`
   - Prove `dual_temp_l`: G(a) ∧ H(a) → H(G(a))
   - Prove `past_theory_witness_exists_with_GH`: extended backward witness
   - Modify `OmegaBackwardInvariant` to track GH_theory(M0)

2. **Prove forward_F for all t** (the real challenge, ~3-4h):
   - For t ≥ 0: Already resolved by forward chain dovetailing
   - For t < 0, sub-case (a): F(phi) ∈ M0, resolved by forward chain
   - For t < 0, sub-case (b): F(phi) ∈ backward(n), G(¬phi) ∈ M0 non-eternal
     - Key insight: G(¬phi) ∈ M0 → ¬phi ∈ M0 (by G → identity)
     - G(¬phi) ∈ forward(s) for all s ≥ 0 (by forward G-propagation)
     - So ¬phi ∈ forward(s) for all s ≥ 0
     - Also ¬phi ∈ M0 = backward(0)
     - Need phi somewhere between backward(n) and M0
     - Since F(phi) ∈ backward(n), semantically phi should hold at some time > -n
     - **But syntactically, we can't derive this without temporal coherence (circular!)**

3. **If sub-case (b) is blocking**: Consider whether it's actually reachable:
   - F(phi) ∈ backward(n) AND G(¬phi) ∈ M0 non-eternal
   - Means: at time -n, "phi eventually" holds, but at time 0, "¬phi always" holds
   - This IS semantically consistent (phi holds between -n and 0, but not after)
   - **The backward chain MUST contain phi at some earlier point (closer to M0)**
   - But the backward chain doesn't construct witnesses for F-obligations

4. **Alternative for sub-case (b)**: Modify backward chain to ALSO resolve F-obligations:
   - At each backward step, alternate between P-resolution and F-resolution
   - But this brings back the oscillation problem (Architecture 2)
   - Unless we use a combined seed: resolve P while preserving the needed F-witnesses

### Effort Estimate for Recommended Path

| Component | Hours | Risk |
|-----------|-------|------|
| GH-intersection seed + proof | 2 | LOW |
| Modified backward invariant | 1 | LOW |
| forward_F sub-case (a) | 1 | LOW |
| forward_F sub-case (b) | 3-4 | HIGH |
| forward_G from forward_F | 2 | MEDIUM |
| Wire to completeness | 1 | LOW |
| **Total** | **10-12** | |

## Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A says extended witness impossible, B recommends it | Both agree when restricted to GH-intersection (eternal formulas). Full extended witness is impossible, but GH-restricted version IS provable. |
| B recommends bundle-level as fallback, C rules it out | C's analysis is definitive — bundle-level breaks the truth lemma. Remove from consideration. |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Extended witness theorem feasibility | completed | HIGH |
| B | Alternative chain architectures | completed | MEDIUM |
| C | Bundle-level coherence analysis | completed | HIGH |

## References

### Teammate Reports
- `specs/058_wire_completeness_to_frame_conditions/reports/11_teammate-a-findings.md` — Extended witness analysis
- `specs/058_wire_completeness_to_frame_conditions/reports/11_teammate-b-findings.md` — Architecture comparison
- `specs/058_wire_completeness_to_frame_conditions/reports/11_teammate-c-findings.md` — Bundle-level analysis

### Key Source Files
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — Z-chain, witness theorems, omega chains
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — Truth lemma (G/H cases)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — BFMCS temporal coherence definition
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` — temp_l (TL_quot)
