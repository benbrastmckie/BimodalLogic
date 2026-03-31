# Research Report: Task #70 - Mathematically Rigorous Path Forward

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774926142_4a9890

## Summary

Two teammates conducted rigorous mathematical analysis of the current implementation state and all viable paths to sorry-free completeness. The central finding is that **the CoherentZChain approach is fundamentally flawed** due to asymmetric preservation, and the **bundle-level approach is insufficient** because the truth lemma intrinsically requires same-family witnesses. The mathematically correct path forward is a **bidirectional temporal witness construction** that preserves both G-theory and H-theory simultaneously, which is proven to be consistent.

## Key Findings

### 1. CoherentZChain Is Architecturally Broken (Both Teammates Agree)

The 6 sorries in CoherentZChain (lines 7377, 7380, 7392, 7394, 7453, 7469) are all consequences of the same architectural flaw: the forward chain preserves G but not H; the backward chain preserves H but not G. These are **not fixable** without redesigning the chain construction.

### 2. Bundle-Level Coherence Is Insufficient for Completeness (Teammate A, High Confidence)

The parametric truth lemma requires same-family witnesses for both `forward_F` and `backward_P`. This is **mathematically intrinsic** to the semantics, not an artifact of the formalization:

- `G(phi)` true at `(tau, t)` means `phi` true at `(tau, s)` for all `s >= t` — along the **same history** `tau`
- The contraposition proof (used in `temporal_backward_G`) requires: if `F(neg phi) ∈ fam.mcs(t)`, then `∃ s >= t, neg(phi) ∈ fam.mcs(s)` — witness in the **same family**
- A witness in a different family uses a different history, making the semantic argument invalid

Teammate B initially recommended bundle-level as Priority 1 but acknowledged the same gap. Teammate A's deeper semantic analysis conclusively shows this path is a dead end for the standard completeness proof.

### 3. `f_preserving_seed_consistent` Sub-case A Is Genuinely Unprovable (Teammate B, High Confidence)

The sorry at line 3363 is not a proof gap but a mathematical falsehood in the specific proof strategy. When `phi ∈ L_no_F` (phi appears in context alongside extracted F-elements), the G-lift argument produces `G(phi) → G(neg psi) ∈ M`. But:
- If `G(phi) ∈ M`: contradiction with `F(psi) ∈ M` ✓
- If `G(phi) ∉ M`: the implication is vacuously true, no contradiction ✗

The semantic reason (line 2924 comment): "If 'eventually phi' and 'phi implies always neg psi', then after phi holds we have 'always neg psi'. But 'eventually psi' says psi holds at some point — **this is consistent if ssi holds BEFORE phi**."

### 4. Bidirectional Temporal Witness Is Mathematically Sound (Teammate A, High Confidence)

A new witness construction preserving **both** G-theory and H-theory simultaneously is consistent:

- **G_theory(M)** = {phi | G(phi) ∈ M} ⊆ M (by T-axiom: G(phi) → phi)
- **H_theory(M)** = {psi | H(psi) ∈ M} ⊆ M (by T-past axiom: H(psi) → psi)
- Therefore `{phi} ∪ G_theory(M) ∪ H_theory(M) ⊆ {phi} ∪ M`
- When `F(phi) ∈ M`, the set `{phi} ∪ M` is consistent (standard temporal witness argument)
- Therefore the combined seed is consistent

The key new lemma needed:
```lean
theorem temporal_theory_witness_bidirectional (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (phi : Formula) (h_F : F(phi) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ psi, G(psi) ∈ M → G(psi) ∈ W) ∧   -- G-preservation
      (∀ psi, H(psi) ∈ M → H(psi) ∈ W) ∧   -- H-preservation (NEW)
      box_class_agree M W
```

### 5. Sorry-Free Infrastructure Already Available (Teammate B)

Confirmed sorry-free:
- `ultrafilter_F_resolution` and `ultrafilter_P_resolution` (fixed in previous phase)
- `construct_bfmcs_bundle` and all bundle-level coherence theorems
- `boxClassFamilies_bundle_forward_F`, `boxClassFamilies_bundle_backward_P`
- `F_persistence_through_chain` (line 6148)
- `omega_F_preserving_forward_F_resolution` (line 6224) — alternative to dovetailed chain

### 6. Dovetailed Chain Sorry (Line 7696) Is Bypassable (Teammate B)

The sorry in `omega_true_dovetailed_forward_F_resolution` can be bypassed by using `omega_F_preserving_forward_F_resolution` directly, which maintains F-persistence by construction.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Resolution |
|----------|-----------|-----------|------------|
| Bundle-level sufficiency | Cannot work (truth lemma requires same-family) | Recommended as Priority 1 | **Teammate A correct** — semantic analysis is conclusive. G/H operators are intrinsically single-history. |
| Path forward | Bidirectional witness (Path B) | Bundle verification first, then F-preserving chain | **Bidirectional witness is the correct mathematical approach**, but verifying bundle infrastructure is a useful prerequisite |

### Gaps Identified

1. **Bidirectional witness implementation effort**: Teammate A estimates 15-25 hours. This may be optimistic given the complexity of proving the Lindenbaum extension preserves H-theory.

2. **RestrictedTemporallyCoherentFamily viability**: Teammate A identified Path C (using `DeferralRestrictedSerialMCS`) but its applicability to the general completeness case needs investigation.

3. **`FPreservingForwardChain.forward_G` sorry (line 6428)**: Teammate B noted this sorry exists but its relationship to the main completeness path is unclear.

### Recommendations

**In priority order:**

#### 1. Implement Bidirectional Temporal Witness (Path B) — The Mathematically Correct Fix

Build `temporal_theory_witness_bidirectional` as described above. The consistency argument is proven sound. This enables a single-family chain construction that preserves both G and H in both directions, directly satisfying the truth lemma's requirements.

**Key steps:**
1. Define `bidirectional_seed M phi := {phi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M)`
2. Prove consistency of `bidirectional_seed` (follows from `bidirectional_seed ⊆ {phi} ∪ M`)
3. Apply Lindenbaum to get MCS W
4. Prove G-preservation: `∀ psi, G(psi) ∈ M → G(psi) ∈ W` (seed membership + upward closure)
5. Prove H-preservation: `∀ psi, H(psi) ∈ M → H(psi) ∈ W` (seed membership + upward closure)
6. Build bidirectional chain step using this witness
7. Prove the resulting Int-indexed chain satisfies both `forward_F` and `backward_P`

**Risk**: The Lindenbaum extension might add `neg(H(psi))`, contradicting H-preservation. This is blocked by including `H(psi)` directly in the seed (since `H(psi)` is in the seed, and the seed is extended to a consistent MCS, `H(psi)` remains in W).

**Wait — critical subtlety**: The seed includes H-theory formulas `psi` (not `H(psi)` itself). We need `H(psi) ∈ W`, not just `psi ∈ W`. So the seed should include `H(psi)` for all `H(psi) ∈ M`, not just `psi`.

Revised seed: `{phi} ∪ {G(psi) | G(psi) ∈ M} ∪ {H(psi) | H(psi) ∈ M} ∪ box_theory(M)`

This is still a subset of M (by MCS closure), so consistency follows.

#### 2. Investigate RestrictedTemporallyCoherentFamily (Path C) — Possible Shortcut

The existing `RestrictedTemporallyCoherentFamily` in SuccChainFMCS.lean may already provide what's needed for completeness of specific formulas. If every formula's negation can be embedded in a `DeferralRestrictedSerialMCS`, this gives a direct completeness path. Needs investigation.

#### 3. Clean Up Dead Code

Regardless of which path succeeds:
- Mark `CoherentZChain` infrastructure as dead code (6 unfixable sorries)
- Mark `f_preserving_seed_consistent` as known-unprovable
- Mark `omega_true_dovetailed_forward_F_resolution` as superseded by `omega_F_preserving_forward_F_resolution`
- Consider moving these to a separate file or deleting them entirely

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical Foundations | completed | high |
| B | Alternative Approaches | completed | high |

## References

### Key Source Locations

| Item | File | Lines | Status |
|------|------|-------|--------|
| `truth_at` (G/H semantics) | Semantics/Truth.lean | 118-125 | Sorry-free |
| `BFMCS.temporally_coherent` | Bundle/TemporalCoherence.lean | 218-221 | Definition |
| `parametric_canonical_truth_lemma` | Algebraic/ParametricTruthLemma.lean | 207-353 | Sorry-free |
| `temporal_backward_G` | Bundle/TemporalCoherence.lean | 165-178 | Sorry-free |
| `construct_bfmcs_bundle` | Algebraic/UltrafilterChain.lean | 5094-5105 | Sorry-free |
| `f_preserving_seed_consistent` | Algebraic/UltrafilterChain.lean | 3363-3369 | **Unprovable** |
| `CoherentZChain_to_FMCS` | Algebraic/UltrafilterChain.lean | 7340-7419 | **6 unfixable sorries** |
| `omega_true_dovetailed_forward_F_resolution` | Algebraic/UltrafilterChain.lean | 7696 | **Superseded** |
| `omega_F_preserving_forward_F_resolution` | Algebraic/UltrafilterChain.lean | 6224 | Sorry-free |
| `F_persistence_through_chain` | Algebraic/UltrafilterChain.lean | 6148 | Sorry-free |
| `temporal_theory_witness_exists` | Algebraic/UltrafilterChain.lean | ~4880 | Sorry-free |
| Bundle coherence gap comment | Algebraic/UltrafilterChain.lean | 5120-5147 | (comment) |
| `RestrictedTemporallyCoherentFamily` | Bundle/SuccChainFMCS.lean | 5805+ | Needs investigation |
