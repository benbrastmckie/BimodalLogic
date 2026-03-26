# Implementation Summary: Task 65

**Task**: Build TaskModel from Restricted Construction
**Session**: sess_1774564134_4004c1
**Date**: 2026-03-26
**Status**: BLOCKED

## Executive Summary

Phase 1 verification confirms that `shifted_truth_lemma` **requires family-level temporal coherence**, not bundle-level coherence. This is an unbridgeable gap with the current `construct_bfmcs_bundle` construction, which only provides bundle-level coherence.

The approach outlined in v2 of the plan (wiring existing infrastructure) is **blocked**.

## Phase 1: Verification Results

### Finding: Family-Level Coherence Required

**Location**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean:648-772`

The `shifted_truth_lemma` theorem signature is:
```lean
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t φ
```

It requires `h_tc : B.temporally_coherent` where `B.temporally_coherent` is defined as (line 216-219):
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)
```

This is **family-level** coherence: F(phi) witnesses must be in the **same family**.

### Proof Trace: Where Same-Family is Used

**G backward case** (line 744-754):
1. `h_tc fam hfam` extracts `(h_forward_F, h_backward_P)` for the specific `fam`
2. A `TemporalCoherentFamily` is constructed with these proofs
3. `temporal_backward_G` is called (line 754)

**Inside `temporal_backward_G`** (TemporalCoherence.lean:165-178):
1. Assumes `G(phi) not in fam.mcs t`
2. By MCS maximality: `neg(G(phi)) = F(neg(phi)) in fam.mcs t`
3. **Line 176**: `fam.forward_F` gives `exists s > t, neg(phi) in fam.mcs s` (**SAME family**)
4. **Line 177**: Hypothesis gives `phi in fam.mcs s` (same s, same family)
5. **Line 178**: Contradiction via `set_consistent_not_both` because **both are in fam.mcs s**

The contradiction requires both `phi` and `neg(phi)` to be in the **same MCS**. Bundle-level coherence would give:
- `phi in fam.mcs s`
- `neg(phi) in fam'.mcs s'` (different family)

No contradiction is possible with different families.

### Bundle Construction Provides Only Bundle-Level Coherence

**Location**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:2875-2877`

```lean
theorem construct_bfmcs_bundle_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    BundleTemporallyCoherent (construct_bfmcs_bundle M0 h_mcs).families
```

Where `BundleTemporallyCoherent` (line 2554-2555) provides witnesses in **any** family:
```lean
def BundleTemporallyCoherent (families : Set (FMCS Int)) : Prop :=
  ∀ fam ∈ families, bundle_forward_F families fam ∧ bundle_backward_P families fam
```

And `bundle_forward_F` (line 2536-2538) is:
```lean
def bundle_forward_F (families : Set (FMCS Int)) (fam : FMCS Int) : Prop :=
  ∀ t phi, Formula.some_future phi ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs s  -- ANY family, not same family
```

### Conclusion

The gap between bundle-level and family-level coherence is **fundamental**:
- **Bundle-level**: F(phi) in fam.mcs t -> exists fam' in families, s > t, phi in fam'.mcs s
- **Family-level**: F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s (SAME family)

No transformation can bridge this because:
1. The contradiction proof requires same-MCS membership
2. Bundle coherence only guarantees witnesses exist somewhere in the bundle
3. There's no relationship between the witnessing family and the originating family

## Target Sorries Analysis

The target sorries are in `Theories/Bimodal/FrameConditions/Completeness.lean`:
- Line 120: `dense_completeness_fc` - sorry
- Line 163: `discrete_completeness_fc` - sorry
- Line 214: `bundle_validity_implies_provability` - sorry

These require the model-theoretic glue connecting `BFMCS_Bundle` to `TaskModel` semantics, which in turn requires the `shifted_truth_lemma`. Since `shifted_truth_lemma` requires family-level coherence that we cannot provide, these sorries **cannot be resolved** with the current approach.

## Alternative Paths Forward

### Option 1: Omega-Enumeration Construction (Mentioned but Not Implemented)

The codebase mentions `omegaClassFamilies_temporally_coherent` as a replacement for the blocked `boxClassFamilies_temporally_coherent`. This construction would achieve family-level coherence by explicit dovetailing of F/P obligations.

**Location**: UltrafilterChain.lean:1865-1893 (documentation only)

**Status**: NOT IMPLEMENTED - only the documentation exists, no actual theorem.

### Option 2: Weaker Truth Lemma

Create a truth lemma that only requires the forward direction (MCS membership implies truth), not the backward direction (truth implies MCS membership). The completeness proof using contrapositive only needs the forward direction.

**Evidence**: Line 2879-2890 mentions "Forward truth lemma core" approach.

### Option 3: Alternative Contradiction Strategy

Find a different contradiction path that doesn't require same-family witnesses. This would require reworking the G/H backward cases in the truth lemma.

## Recommendations

1. **Spawn Task**: Implement the omega-enumeration construction (`omegaClassFamilies`) that achieves family-level coherence by construction
2. **Or Spawn Task**: Implement a forward-only truth lemma sufficient for completeness
3. **Do Not Attempt**: Bundle-level truth lemma (proven blocked in v1 research)

## Files Modified

None - implementation was blocked before any code changes.

## Files Examined

| File | Lines | Purpose |
|------|-------|---------|
| `Bundle/CanonicalConstruction.lean` | 648-772 | `shifted_truth_lemma` proof |
| `Bundle/TemporalCoherence.lean` | 165-205, 216-219 | `temporal_backward_G/H`, `BFMCS.temporally_coherent` |
| `Algebraic/UltrafilterChain.lean` | 1805-1893, 2536-2555, 2875-2877 | Bundle construction, coherence definitions |
| `FrameConditions/Completeness.lean` | 100-270 | Target sorries |

## Verification

No verification performed - no code changes made.
