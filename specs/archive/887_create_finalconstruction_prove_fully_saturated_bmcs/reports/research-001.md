# Research Report: FinalConstruction.lean and fully_saturated_bmcs_exists_int

## Task 887 Research
**Session ID**: sess_1771308695_939a6e
**Date**: 2026-02-16

## Executive Summary

Task 887 aims to create `FinalConstruction.lean` that combines modal saturation (from `SaturatedConstruction.lean`) with temporal coherence (from `TemporalCoherentConstruction.lean`) to implement a constructive proof of `fully_saturated_bmcs_exists_int`. This would eliminate the current theorem's sorry in `TemporalCoherentConstruction.lean:822-842`.

**Finding**: The research reveals that the core challenge is ensuring witness families built during modal saturation are temporally coherent. Three options were investigated; **Option B is the most viable** but requires structural infrastructure not yet implemented.

## Current State Analysis

### 1. What does `constructSaturatedBMCS` return?

Location: `SaturatedConstruction.lean:1178-1183`

```lean
noncomputable def constructSaturatedBMCS (phi : Formula) (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant) : BMCS D :=
  let initial := initialFamilyCollection phi fam
  let h_all_const := initialFamilyCollection_allConstant phi fam h_const
  let saturated := initial.saturate h_all_const
  saturated.toBMCS (initial.saturate_isFullySaturated h_all_const)
```

**Properties guaranteed**:
- Takes a constant initial family and produces a BMCS
- The BMCS is **modally saturated** (every Diamond has a witness)
- All families in the BMCS are **constant** (same MCS at all times)
- `modal_forward` and `modal_backward` are proven (sorry-free as of Task 881 Phase 2)
- Uses `exists_fullySaturated_extension` which is now **sorry-free**

### 2. What does `BMCS.temporally_coherent` require?

Location: `TemporalCoherentConstruction.lean:298-301`

```lean
def BMCS.temporally_coherent (B : BMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s) /\
    (forall t phi, P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s)
```

**Key requirement**: Every family in the BMCS must satisfy `forward_F` and `backward_P`. This includes:
- The eval_family (initial family)
- ALL witness families added during modal saturation

### 3. How are witness families constructed during modal saturation?

Location: `SaturatedConstruction.lean:985-1116` (in `exists_fullySaturated_extension`)

The witness construction process:
1. When a Diamond formula `Diamond psi` needs witnessing, construct `{psi} union BoxContent(M)`
2. Prove this seed is consistent using `diamond_box_coherent_consistent`
3. Extend to MCS via regular `set_lindenbaum`
4. Create constant family via `constantWitnessFamily`

**Critical observation**: Step 3 uses **regular Lindenbaum**, not temporal Lindenbaum. This means witness families are NOT guaranteed to be temporally saturated.

## Option Analysis

### Option A: Use temporal Lindenbaum for witness families

**Approach**: Replace `set_lindenbaum` with `temporalSetLindenbaum` in witness construction.

**Current state of TemporalLindenbaum.lean**:
- File has **6 sorries** (lines 444, 485, 631, 655, 662, 691)
- Main theorem `temporalLindenbaumMCS` depends on `henkinLimit_forward_saturated` and `henkinLimit_backward_saturated`
- The base case (line 444, 485) requires proving that F/P witnesses in the base set are preserved
- The temporal formula case (lines 655, 662) in `maximal_tcs_is_mcs` requires showing that adding F(psi) forces psi to be addable

**Difficulty assessment**: HIGH
- The TemporalLindenbaum sorries are in delicate structural proofs
- Fixing them requires careful reasoning about temporal formula enumeration
- The base case issue is fundamental: the Henkin construction starts from a base that may already contain F/P formulas without their witnesses

**Verdict**: Not recommended as primary path. Would require significant investment with uncertain outcome.

### Option B: Prove constant witness families from temporally saturated MCSes inherit temporal coherence

**Approach**: Show that if the source MCS is temporally saturated (F psi -> psi and P psi -> psi), then the constant family built from it satisfies `forward_F` and `backward_P`.

**This is already proven!** See `SaturatedConstruction.lean:1259-1318`:

```lean
lemma constant_family_temporally_saturated_is_coherent
    (fam : IndexedMCSFamily D)
    (h_const : fam.isConstant)
    (h_fwd_sat : TemporalForwardSaturated (fam.mcs 0))
    (h_bwd_sat : TemporalBackwardSaturated (fam.mcs 0)) :
    (forall t phi, F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s) /\
    (forall t phi, P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s)
```

**The key insight**: For a constant family (where `mcs t = mcs s` for all t, s), temporal coherence reduces to temporal saturation of the underlying MCS.

**What's needed**:
1. Modify `exists_fullySaturated_extension` to use `henkinLimit + temporalSetLindenbaum` instead of `set_lindenbaum` for witness construction
2. Prove that `{psi} union BoxContent(M)` extended via temporal Lindenbaum produces a temporally saturated MCS
3. Apply `constant_family_temporally_saturated_is_coherent` to get the coherence properties

**Difficulty assessment**: MEDIUM-HIGH
- The infrastructure exists (`constant_family_temporally_saturated_is_coherent` is proven)
- But still requires fixing TemporalLindenbaum sorries OR finding an alternative
- The alternative would be proving temporal saturation is preserved through regular Lindenbaum when the seed is temporally saturated

**Verdict**: Most promising option if TemporalLindenbaum can be fixed or circumvented.

### Option C: Restructure truth lemma to only require eval_family temporal coherence

**Approach**: Weaken `BMCS.temporally_coherent` to only require temporal coherence for the eval_family.

**Analysis of TruthLemma.lean** (lines 291-429):

The truth lemma uses temporal coherence in two places:
1. **Line 392-404** (all_future backward case): Constructs a `TemporalCoherentFamily` from `h_tc fam hfam`
2. **Line 415-429** (all_past backward case): Same pattern

**Critical observation**: The truth lemma is proven by structural induction on formulas. In the BOX case (lines 353-377), it recurses on ALL families in the BMCS:
```lean
intro h_box fam' hfam'
have h_psi_mcs : psi in fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
exact (ih fam' hfam' t).mp h_psi_mcs  -- <-- Recurses on witness families
```

When the recursion hits a temporal formula inside a box, it needs temporal coherence for the witness family `fam'`.

**Verdict**: NOT viable. The truth lemma's inductive structure fundamentally requires temporal coherence for ALL families, not just eval_family.

## Circular Import Analysis

### Current import structure

```
SaturatedConstruction.lean imports:
  - TemporalCoherentConstruction.lean (for exists_gt_in_ordered_group, temporal lemmas)

TemporalCoherentConstruction.lean imports:
  - Construction.lean (for constantIndexedMCSFamily)
  - DovetailingChain.lean (for temporal_coherent_family_exists_theorem)
```

### How FinalConstruction.lean resolves this

FinalConstruction.lean would:
1. Import both SaturatedConstruction.lean and TemporalCoherentConstruction.lean
2. Combine their constructions to produce a BMCS that is both modally saturated AND temporally coherent
3. Prove `fully_saturated_bmcs_exists_int` constructively

There is no actual circular import - the apparent circularity from task 881 Phase 2 was resolved by having SaturatedConstruction import TemporalCoherentConstruction (for helper lemmas), not the other way around.

## Existing Proof Debt

### SaturatedConstruction.lean
- `fully_saturated_bmcs_exists_constructive` (line 1367): 1 sorry
  - Depends on temporal coherence for witness families
  - This is exactly what Task 887 aims to resolve

### TemporalCoherentConstruction.lean
- `fully_saturated_bmcs_exists_int` (line 822): 1 sorry
  - The theorem we're trying to prove constructively

### TemporalLindenbaum.lean
- `henkinLimit_forward_saturated` (lines 444): 1 sorry (base case)
- `henkinLimit_backward_saturated` (line 485): 1 sorry (base case)
- `maximal_tcs_is_mcs` (lines 631, 655, 662): 3 sorries (temporal formula cases)

**Total**: 6 sorries in TemporalLindenbaum, 1 in SaturatedConstruction, 1 in TemporalCoherentConstruction

### DovetailingChain.lean
- `dovetailing_forward_G_neg` (line 606): 1 sorry (cross-sign propagation)
- `dovetailing_backward_H_pos` (line 617): 1 sorry (cross-sign propagation)
- `dovetailing_forward_F` (line 633): 1 sorry (witness construction)
- `dovetailing_backward_P` (line 640): 1 sorry (witness construction)

**Total**: 4 sorries (all technical debt, mathematically valid)

## Recommended Approach

### Phase 1: Infrastructure (Required)
Create a new lemma proving that regular Lindenbaum preserves temporal saturation when applied to a temporally saturated seed:

```lean
lemma lindenbaum_preserves_temporal_saturation
    (S : Set Formula)
    (h_cons : SetConsistent S)
    (h_fwd : TemporalForwardSaturated S)
    (h_bwd : TemporalBackwardSaturated S) :
    TemporalForwardSaturated (lindenbaumExtension S h_cons) /\
    TemporalBackwardSaturated (lindenbaumExtension S h_cons)
```

**Why this might work**: The temporal witness seed `{psi} union BoxContent(M)` already contains the witnesses via GContent/HContent. If the starting MCS is temporally saturated, its GContent and HContent already satisfy the temporal saturation property for formulas in the seed.

### Phase 2: Witness Construction Modification
Modify `exists_fullySaturated_extension` to ensure witness families are temporally coherent:

1. When building a witness for Diamond psi:
   - Construct `{psi} union BoxContent(M) union GContent(M) union HContent(M)`
   - This seed is temporally saturated if M is
   - Apply regular Lindenbaum (now preserves temporal saturation)
   - Build constant family and apply `constant_family_temporally_saturated_is_coherent`

### Phase 3: FinalConstruction.lean
1. Start from a temporally coherent initial family (via `temporal_coherent_family_exists_Int`)
2. Apply modified `exists_fullySaturated_extension` that preserves temporal coherence
3. The result is both modally saturated and temporally coherent

## Alternative: Direct Proof Without TemporalLindenbaum

If Phase 1 cannot be proven, an alternative is:

1. **Use DovetailingChain for witness construction**: Instead of regular Lindenbaum, build witness families using the dovetailing chain construction
2. **Accept DovetailingChain sorries**: The 4 sorries in DovetailingChain are for witness enumeration, which is mathematically valid but not yet formalized

This would convert the 1 sorry in `fully_saturated_bmcs_exists_int` to dependency on DovetailingChain's 4 sorries - a trade-off of sorry placement, not count.

## Conclusion

**Option B is viable** with the following path:
1. Prove `lindenbaum_preserves_temporal_saturation` (new infrastructure)
2. Modify `exists_fullySaturated_extension` to use temporally saturated seeds
3. Create `FinalConstruction.lean` combining the constructions

**Estimated complexity**: Medium-High. The core mathematical insight (`constant_family_temporally_saturated_is_coherent`) is already proven. The remaining work is ensuring the seed construction and Lindenbaum extension preserve temporal saturation.

**Alternative path**: Accept DovetailingChain's 4 sorries as technical debt for temporal witness enumeration, which is mathematically sound but not yet formalized in Lean.
