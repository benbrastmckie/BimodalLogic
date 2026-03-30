# Bundle-Level Coherence Semantic Analysis

**Task**: 70 - Ultrafilter construction exploration
**Date**: 2026-03-30
**Session**: sess_1774912521_a72037
**Focus**: Why bundle-level coherence violates task semantics

## Summary

Bundle-level temporal coherence (`boxClassFamilies_bundle_forward_F`) allows F-witnesses to exist in ANY family of the bundle, not the SAME family. This is semantically CORRECT for TM logic completeness, despite initial concerns. The key insight is that temporal operators in TM semantics evaluate over a SINGLE history `tau`, while the Box operator evaluates over ALL histories in Omega. The bundle structure handles modal (Box) coherence; temporal coherence is handled WITHIN each history/family.

## The Semantic Requirement

### TaskFrame Semantics (Official)

From `Theories/Bimodal/Semantics/Truth.lean` lines 118-126:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

**Critical observation**: The temporal operators (`all_future`/G and `all_past`/H) evaluate along the SAME history `tau` at different times. The Box operator (`box phi`) changes to a DIFFERENT history `sigma` but keeps the same time `t`.

### What This Means for Completeness

When proving the truth lemma (MCS membership iff semantic truth), we need:

1. **Box case**: `Box(phi) in fam.mcs(t) <-> forall sigma in Omega, phi true at sigma,t`
   - This requires witnesses in DIFFERENT families/histories (modal coherence)

2. **G case**: `G(phi) in fam.mcs(t) <-> forall s >= t, phi true at tau,s`
   - This requires witnesses at DIFFERENT times in the SAME history/family

## Bundle-Level Coherence Analysis

### What `boxClassFamilies_bundle_forward_F` Does

From `UltrafilterChain.lean` lines 3588-3626:

```lean
theorem boxClassFamilies_bundle_forward_F (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam in boxClassFamilies M0 h_mcs)
    (t : Int) (phi : Formula) (h_F : Formula.some_future phi in fam.mcs t) :
    exists fam' in boxClassFamilies M0 h_mcs, exists s > t, phi in fam'.mcs s
```

This provides F-witnesses in a potentially DIFFERENT family `fam'`.

### Why This Is Actually CORRECT

The confusion arises from conflating two different coherence requirements:

1. **Family-level temporal coherence** (required for truth lemma backward G/H):
   - `TemporalCoherentFamily.forward_F`: `F(phi) in fam.mcs(t) -> exists s >= t, phi in fam.mcs(s)`
   - Witnesses must be in SAME family (this is what `B.temporally_coherent` requires)

2. **Bundle-level existence** (required for constructing the bundle):
   - `bundle_forward_F`: `F(phi) in fam.mcs(t) -> exists fam' in families, exists s > t, phi in fam'.mcs(s)`
   - Witnesses can be in ANY family

The key is that `BFMCS.temporally_coherent` (from `TemporalCoherence.lean` lines 218-221) ALREADY requires family-level coherence:

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families,
    (forall t : D, forall phi : Formula, Formula.some_future phi in fam.mcs t -> exists s : D, t <= s and phi in fam.mcs s) and
    (forall t : D, forall phi : Formula, Formula.some_past phi in fam.mcs t -> exists s : D, s <= t and phi in fam.mcs s)
```

This is the SAME-family requirement. The `parametric_canonical_truth_lemma` uses this at lines 322-332:

```lean
-- Backward: forall s >= t, truth tau s psi -> G psi in MCS
intro h_all
obtain <h_forward_F, h_backward_P> := h_tc fam hfam  -- h_tc : B.temporally_coherent
let tcf : TemporalCoherentFamily D := {
  toFMCS := fam
  forward_F := h_forward_F   -- SAME-family witnesses
  backward_P := h_backward_P
}
exact temporal_backward_G tcf t psi h_all_mcs
```

### The Actual Gap

The `boxClassFamilies_bundle_forward_F` is NOT the same as `BFMCS.temporally_coherent`. The bundle structure provides:
- `bundle_forward_F`: Witnesses in ANY family (proven sorry-free)
- `BFMCS.temporally_coherent`: Witnesses in SAME family (NOT proven for boxClassFamilies)

The `construct_bfmcs_bundle` (lines 3798+) creates a `BFMCS_Bundle` with bundle-level coherence, but the truth lemma requires `BFMCS.temporally_coherent` which is STRONGER.

## Where the Sorries Actually Are

From `ROADMAP.md` and `UltrafilterChain.lean`:

1. **Z_chain_forward_F** (line 3400-3422): Has a `sorry` for the case when `phi not in Z_chain(t)` - cannot find phi within the same chain.

2. **Z_chain_backward_P** (line 3430-3439): Symmetric sorry.

These sorries are NOT about bundle vs family - they're about F-obligation resolution within a single chain construction. The ROADMAP identifies these as "Class B" sorries requiring either:
- Weakening the theorem to "eventually appears" rather than "next step"
- Enlarging the deferral closure

## Implications for Task 70 (Ultrafilter Approach)

The ultrafilter approach is relevant but NOT because bundle-level is "wrong". The current situation is:

1. **Modal coherence**: Fully solved via `boxClassFamilies_modal_forward/backward` (sorry-free)

2. **Temporal coherence at bundle level**: Solved via `boxClassFamilies_bundle_forward_F/P` (sorry-free)

3. **Temporal coherence at family level**: NOT solved - this is the actual gap

The ultrafilter construction could help by providing a different FMCS construction that achieves family-level temporal coherence, but this requires resolving the F-obligation deferral problem identified in ROADMAP.md.

## Comments to Clarify

### UltrafilterChain.lean Lines 3455-3458
Current comment:
> "Bundle-level temporal coherence relaxes this: F-witnesses can exist in ANY family of the bundle. This is mathematically sound because..."

This is ACCURATE. The comment correctly states that bundle-level is mathematically sound for Jonsson-Tarski style completeness. The issue is that the truth lemma also needs family-level coherence, which is a separate (stronger) requirement.

### Research Report Clarification
The reports in `specs/065*/` and `specs/058*/` that say "bundle-level is the correct approach" are correct in context - bundle-level coherence IS correct for building the bundle structure. The additional requirement for family-level coherence is orthogonal.

## ROAD_MAP.md Updates

No updates needed. The ROADMAP correctly identifies the SuccChain F-obligation sorries as the core blocker. The confusion was in thinking "bundle-level vs family-level" is a dichotomy - they're complementary requirements.

## Elements to Archive to Boneyard/

None recommended. The `BFMCS_Bundle` and `boxClassFamilies_bundle_*` theorems are correct and useful infrastructure. They just don't solve the family-level coherence requirement on their own.

## Confidence Level

HIGH - The analysis is based on reading the actual semantics in Truth.lean and the truth lemma in ParametricTruthLemma.lean. The semantic requirements are clear:
- G/H evaluate along single history (needs family-level coherence)
- Box evaluates across histories (needs bundle-level coherence)

## Recommendations

1. **Task 69's "blocked" status is about F-obligation resolution**, not bundle vs family semantics. The true blocker is filling Z_chain_forward_F sorries.

2. **The ultrafilter approach (task 70) should focus on**:
   - Whether ultrafilter techniques can construct families with family-level temporal coherence
   - Alternative FMCS constructions that resolve F-obligations without explicit enumeration
   - The algebraic perspective from ROADMAP.md (temporal shift automorphism on Lindenbaum algebra)

3. **Immediate action**: Clarify in task 70 description that the goal is achieving `BFMCS.temporally_coherent` (family-level), not replacing bundle-level coherence which is already correct.

## Technical Appendix: Key Definitions

### TemporalCoherentFamily (family-level)
```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : forall t : D, forall phi : Formula,
    Formula.some_future phi in mcs t -> exists s : D, t <= s and phi in mcs s
  backward_P : forall t : D, forall phi : Formula,
    Formula.some_past phi in mcs t -> exists s : D, s <= t and phi in mcs s
```

### BundleTemporallyCoherent (bundle-level)
```lean
def BundleTemporallyCoherent (families : Set (FMCS Int)) : Prop :=
  forall fam in families, bundle_forward_F families fam and bundle_backward_P families fam
```

### BFMCS.temporally_coherent (what truth lemma needs)
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s >= t, phi in fam.mcs s) and
    (forall t phi, P(phi) in fam.mcs t -> exists s <= t, phi in fam.mcs s)
```

The latter is SAME-family requirement; this is what's missing for Z_chain/SuccChain constructions.
