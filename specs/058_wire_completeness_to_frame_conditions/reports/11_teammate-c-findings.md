# Research Report: Bundle-Level vs Family-Level Temporal Coherence

**Task**: 58 - Wire completeness to frame conditions
**Research Focus**: Can we weaken temporal coherence from family-level to bundle-level?
**Completed**: 2026-03-25

## Executive Summary

**Recommendation: Bundle-level coherence is NOT a viable alternative.**

Bundle-level temporal coherence fundamentally breaks the truth lemma induction for temporal operators G and H. The witness being in a different family (fam' != fam) breaks the inductive hypothesis application.

**Confidence Level**: HIGH

## Analysis

### 1. Current Family-Level Coherence

The current `BFMCS.temporally_coherent` requires (from `TemporalCoherence.lean:216-219`):

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)
```

Key property: **The witness s is in the SAME family fam**.

### 2. Proposed Bundle-Level Coherence

The weaker requirement would be:

```lean
-- Bundle-level F-coherence: F(phi) at time t has witness somewhere in bundle
bundle_forward_F : ∀ fam ∈ families, ∀ t : Int, ∀ phi,
  F(phi) ∈ fam.mcs(t) → ∃ fam' ∈ families, ∃ s > t, phi ∈ fam'.mcs(s)
```

Key difference: **The witness s can be in a DIFFERENT family fam'**.

### 3. Why Bundle-Level Breaks the Truth Lemma

The truth lemma proof for `all_future` (G) relies critically on family-level coherence.

**Truth definition** (from `Truth.lean:125`):
```lean
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

Note: G(phi) is true at (τ, t) iff **phi is true at (τ, s) for all s >= t** - same history τ!

**The backward direction of the truth lemma** (from `ParametricTruthLemma.lean:278-289`):

```lean
· -- Backward: forall s ≥ t, truth tau s psi -> G psi in MCS
  intro h_all
  obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam  -- USES family-level coherence!
  let tcf : TemporalCoherentFamily D := { ... }
  have h_all_mcs : ∀ s : D, t < s → psi ∈ fam.mcs s := by
    intro s hts
    exact (ih fam hfam s).mpr (h_all s (le_of_lt hts))  -- IH applied to SAME fam!
  exact temporal_backward_G tcf t psi h_all_mcs
```

The inductive hypothesis `ih fam hfam s` requires **the same family fam** throughout the induction.

**With bundle-level coherence, `temporal_backward_G` would fail** because the contraposition argument (from `TemporalCoherence.lean:165-178`) requires:

1. If G(phi) not in fam.mcs t
2. Then F(neg phi) in fam.mcs t (by duality)
3. Then exists s > t with neg(phi) in **fam.mcs s** (by forward_F)
4. But we have phi in fam.mcs s (by hypothesis)
5. Contradiction

With bundle-level coherence, step 3 would give neg(phi) in **fam'.mcs s** for potentially different fam', and the contradiction in step 5 fails because we only know phi in fam.mcs s, not fam'.mcs s.

### 4. Relationship to Standard Kripke Semantics

In standard Kripke semantics for temporal logic:
- Each world w has temporal successors via relation R_F
- G(phi) true at w iff phi true at all R_F-successors of w
- The successors are in the SAME frame

The BFMCS construction mirrors this:
- Each family fam is like a "temporal line" through the model
- G(phi) true at (fam, t) iff phi true at (fam, s) for all s >= t
- Witnesses must be along the SAME temporal line

Bundle-level coherence would be like saying "there exists SOME temporal line where phi holds" - this is a **different modality** (existential rather than universal over time within a history).

### 5. Modal vs Temporal: Why Box Works Differently

For Box, bundle-level quantification works because:
- Box(phi) true at (fam, t) iff phi true at (fam', t) for ALL fam' in bundle
- The semantics explicitly quantifies over different families

From `Truth.lean:123`:
```lean
| Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

Note: Box quantifies over **different histories σ**, while G quantifies over **different times s in the same history τ**.

### 6. Construction Feasibility

Even if bundle-level coherence were semantically sufficient (which it is not), it would NOT be easier to construct because:

1. `boxClassFamilies_modal_forward/backward` are sorry-free, but they relate to MODAL coherence (across families at same time)

2. Temporal coherence is orthogonal - it requires building F/P-witnesses WITHIN each family's Z-chain

3. The sorry in `boxClassFamilies_temporally_coherent` comes from needing to propagate G-theory along the chain, not from modal considerations

## Conclusion

**Bundle-level temporal coherence is NOT viable** because:

1. **Semantically incorrect**: G(phi) quantifies over times within a SINGLE history, not across histories
2. **Breaks truth lemma**: The inductive hypothesis requires same-family witnesses
3. **Not easier to construct**: The construction difficulty is in temporal propagation, not modal aspects

The current approach of family-level temporal coherence is the correct one. The challenge is in CONSTRUCTING families that satisfy it, not in finding a weaker sufficient condition.

## Recommendation

Focus on construction strategies that achieve family-level temporal coherence:
1. Dovetailed omega-enumeration (as suggested by `omegaClassFamilies_temporally_coherent`)
2. Ultrafilter chain construction with careful F/P-obligation resolution
3. Tree-unraveling approaches that naturally satisfy temporal coherence

Do NOT pursue bundle-level coherence weakening.
