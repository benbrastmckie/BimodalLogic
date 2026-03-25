# Research Report: Alternative Chain Architectures

**Task**: Task 58 - Wire Completeness to Frame Conditions
**Focus**: Alternative chain architectures to avoid G-theory propagation gap
**Date**: 2026-03-25

## Executive Summary

The current omega-enumeration architecture has a fundamental gap: the forward chain preserves G-theory while the backward chain preserves H-theory, but at the boundary crossing (backward -> M0 -> forward), G-formulas from the backward portion do not propagate into the forward portion.

After analyzing four alternative architectures, I recommend **Architecture 3: Bidirectional Extension with Dual-Theory Witness** as the most feasible solution, with **Architecture 4: Separate Chains with Bundle-Level Connection** as a fallback.

## Problem Analysis

### Current Architecture

```
backward_chain(n) <--P-- ... <--P-- backward_chain(1) <--P-- M0 --F--> forward_chain(1) --F--> ... --F--> forward_chain(m)
```

**Invariants**:
- `omega_chain_forward`: preserves G-theory from M0 (via `OmegaForwardInvariant.G_propagate`)
- `omega_chain_backward`: preserves H-theory from M0 (via `OmegaBackwardInvariant.H_propagate`)

**Gap**: When G(phi) is in `backward_chain(n)` for some n > 0, there's no mechanism to ensure G(phi) reaches `forward_chain(m)` because:
1. The backward chain construction uses `past_theory_witness_exists` which only preserves H-theory
2. M0 is the shared root, but G-formulas acquired in the backward direction don't propagate through M0 to the forward direction

### Root Cause

The witness theorems are asymmetric:
- `temporal_theory_witness_exists`: Uses `temporal_box_seed = G_theory ∪ box_theory`
- `past_theory_witness_exists`: Uses `past_temporal_box_seed = H_theory ∪ box_theory`

Neither preserves the OTHER direction's temporal theory.

## Alternative Architectures Analysis

### Architecture 1: Double-Rooted Chains

**Concept**: Use separate roots M0 and M0' where M0' is constructed as a past-witness of M0.

```
M0' --F--> ... --F--> backward_root(0) [preserves G from M0']
    |
    +--P-- [M0' is P-witness of M0]
    |
M0 --F--> forward_chain(1) --F--> ... --F--> forward_chain(m) [preserves G from M0]
```

**Analysis**:
- Forward chain from M0 preserves G-theory from M0
- New chain from M0' would preserve G-theory from M0'
- **Problem**: M0 and M0' are different MCSes. G(phi) in M0' does not imply G(phi) in M0
- **Problem**: Modal saturation requires all MCSes to be in the same box-class bundle, but connecting chains from different roots doesn't give the required coherence

**Feasibility**: LOW
- Does not solve the fundamental problem
- Creates two disconnected chains that don't form a coherent timeline

### Architecture 2: Interleaved Construction

**Concept**: Alternate between F-resolution and P-resolution steps in a single chain.

```
M0 --F--> W1 --P--> W2 --F--> W3 --P--> W4 --F--> ...
```

Where:
- Even steps (0, 2, 4, ...): Resolve an F-obligation using `temporal_theory_witness_exists`
- Odd steps (1, 3, 5, ...): Resolve a P-obligation using `past_theory_witness_exists`

**Analysis**:
- At step 2n: We have resolved n F-obligations and n P-obligations
- **Problem**: F-witnesses preserve G-theory, P-witnesses preserve H-theory
- After P-step: H-theory preserved but G-theory may be lost
- After F-step: G-theory preserved but H-theory may be lost
- The theories "oscillate" and don't accumulate

**Feasibility**: LOW
- Neither G nor H theory propagates coherently through the full chain
- Results in the same gap problem at a finer granularity

### Architecture 3: Bidirectional Extension with Dual-Theory Witness

**Concept**: Prove an extended witness theorem that preserves BOTH G-theory AND H-theory simultaneously.

**Mathematical Insight**: The key question is whether `{phi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M)` is consistent when F(phi) ∈ M.

**Proposed Extended Seed**:
```lean
def dual_temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ H_theory M ∪ box_theory M
```

**Required Theorem**:
```lean
theorem dual_temporal_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ dual_temporal_box_seed M)
```

**Proof Strategy**:
The current proof for `temporal_theory_witness_consistent` uses G-lift:
- From L ⊢ bot where L ⊆ {phi} ∪ G_theory(M) ∪ box_theory(M)
- Derive G(neg(phi)) ∈ M via G-lift
- Contradict F(phi) ∈ M

For the extended version, we need to show that adding H_theory(M) doesn't break consistency:
1. Elements of H_theory(M) have form H(a) where H(a) ∈ M
2. Key question: Can we derive bot from {phi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M)?
3. If so, can we G-lift this derivation?

**Critical Issue**: H-formulas are NOT G-liftable in general.
- G(H(a)) is not derivable from H(a) without interaction axioms
- In TM logic, we don't have G(H(a)) ↔ H(G(a)) as a general axiom

**Workaround**: Instead of G-lifting H-formulas, we can use:
- H(a) ∈ M implies a ∈ M (by temp_t_past: H(a) → a)
- So H_theory(M) content is already in M as plain formulas
- But this doesn't give us G(a) from H(a)

**Revised Approach**: Define a weaker dual seed that IS G-liftable:
```lean
def dual_liftable_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ {a | H(a) ∈ M ∧ G(a) ∈ M} ∪ box_theory M
```

This only includes H-formulas that ALSO have their G-version in M.

**Feasibility**: MEDIUM-HIGH
- Requires proving new consistency lemma
- The weaker seed may be sufficient for completeness
- Need to verify the interaction between G and H in TM axioms

### Architecture 4: Separate F/P Chains with Bundle-Level Connection

**Concept**: Maintain the current architecture but weaken the coherence requirement to bundle-level rather than family-level.

**Current FMCS requirement**:
```lean
structure FMCS (T : Type) where
  mcs : T → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' phi, t ≤ t' → Formula.all_future phi ∈ mcs t → phi ∈ mcs t'
  backward_H : ∀ t t' phi, t' ≤ t → Formula.all_past phi ∈ mcs t → phi ∈ mcs t'
```

**Weakened Bundle requirement**:
```lean
structure BundleFMCS (T : Type) where
  mcs : T → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G_witness : ∀ t phi, Formula.all_future phi ∈ mcs t →
                      ∃ t', t < t' ∧ phi ∈ mcs t' ∧ box_class_agree (mcs t) (mcs t')
  backward_H_witness : ∀ t phi, Formula.all_past phi ∈ mcs t →
                       ∃ t', t' < t ∧ phi ∈ mcs t' ∧ box_class_agree (mcs t) (mcs t')
```

**Key Difference**: Instead of requiring phi to be at ALL future/past points, only require that a witness EXISTS in the bundle.

**Analysis**:
- This is the standard "bundle" approach in canonical model constructions
- The Z-chain naturally provides witnesses via `temporal_theory_witness_exists` and `past_theory_witness_exists`
- The witness is in the same box-class (by the witness theorem guarantees)
- Modal saturation still works because witnesses are in the bundle

**Completeness Impact**:
- Need to verify that truth lemma still goes through with weaker coherence
- For G(phi), need: phi true at all future times
- With bundle coherence: "there exists a witness with phi" doesn't immediately give "phi at all futures"

**Feasibility**: MEDIUM
- Simpler than Architecture 3
- May require restructuring the completeness proof
- Standard approach in modal logic literature (Blackburn, de Rijke, Venema)

## Recommended Architecture

### Primary Recommendation: Architecture 3 (Dual-Theory Witness)

**Rationale**:
1. Preserves the current FMCS structure which is already wired into completeness
2. The key insight is that we only need to preserve G-formulas that are ALSO H-formulas (the intersection)
3. Can be implemented as an extension to existing witness theorems

**Implementation Path**:
1. Define `GH_intersection_theory`: formulas a where both G(a) ∈ M and H(a) ∈ M
2. Prove this set is G-liftable (from G(a) ∈ M, we get G(G(a)) ∈ M by temp_4)
3. Extend backward chain invariant to also preserve this intersection
4. At boundary crossing, the intersection theory propagates both directions

**Key Lemma Needed**:
```lean
theorem past_theory_witness_exists_extended (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      (∀ a, Formula.all_future a ∈ M ∧ Formula.all_past a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W
```

This preserves:
- Full H-theory (as before)
- G-formulas that are also in M's H-closure (the "eternal" formulas)

### Fallback: Architecture 4 (Bundle-Level Connection)

If Architecture 3 proves mathematically infeasible (e.g., the extended seed is inconsistent), fall back to Architecture 4:
1. Weaken FMCS to BundleFMCS
2. Update completeness proof to use witness existence rather than universal quantification
3. This is mathematically sound and standard in the literature

## Confidence Assessment

| Architecture | Feasibility | Confidence |
|--------------|-------------|------------|
| 1. Double-rooted | Low | High (definitely won't work) |
| 2. Interleaved | Low | High (oscillation problem is fundamental) |
| 3. Dual-theory witness | Medium-High | Medium (depends on extended seed consistency) |
| 4. Bundle-level | Medium | High (standard approach, but requires proof restructuring) |

**Overall Recommendation Confidence**: MEDIUM

The dual-theory witness approach (Architecture 3) is the most promising because it:
- Requires minimal changes to existing structure
- Addresses the root cause (asymmetric witness theorems)
- Can be incrementally verified

However, proving the extended seed consistency is non-trivial and may reveal that the G and H theories interact in ways that prevent simultaneous preservation.

## Next Steps

1. **Immediate**: Attempt to prove `dual_temporal_witness_consistent` with the weaker seed that only preserves the G-H intersection
2. **If successful**: Extend `omega_step_backward` to use the new witness theorem
3. **If blocked**: Pivot to Architecture 4 with bundle-level coherence
4. **Regardless**: Document the mathematical constraints that determine which approach is viable

## Appendix: Relevant Code Locations

- `temporal_theory_witness_exists`: UltrafilterChain.lean:1153
- `past_theory_witness_exists`: UltrafilterChain.lean:1380
- `temporal_box_seed`: UltrafilterChain.lean:1044
- `past_temporal_box_seed`: UltrafilterChain.lean:1225
- `G_theory`: UltrafilterChain.lean:959
- `H_theory`: UltrafilterChain.lean:1198
- `Z_chain_forward_G` (with sorry): UltrafilterChain.lean:2300
- `OmegaForwardInvariant`: UltrafilterChain.lean:2011
- `OmegaBackwardInvariant`: UltrafilterChain.lean:2109
