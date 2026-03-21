# Research Report: Task #1004

**Task**: Dovetailing Chain F/P Witnesses - Blocker Analysis
**Date**: 2026-03-19
**Mode**: Team Research (2 teammates)
**Focus**: Deep mathematical analysis of fundamental F/P persistence blocker

## Summary

Two research teammates independently confirmed that the F/P persistence failure in linear chain constructions is a **fundamental mathematical limitation**, not an implementation gap. The root cause is an asymmetry between G and F in temporal logic: G-content propagates forward via the Temporal 4 axiom (`G(phi) -> G(G(phi))`), but F-content has no corresponding propagation axiom. Linear chain constructions using Lindenbaum extension are free to introduce `G(~phi)` at any step, killing `F(phi) = ~G(~phi)`. The literature uniformly uses all-MCS domains for temporal completeness proofs, validating the existing `CanonicalFMCS.lean` approach. Three concrete proposals are analyzed below.

## Key Findings

### 1. Root Cause: The G/F Temporal Axiom Asymmetry

The Temporal 4 axiom `G(phi) -> G(G(phi))` ensures G-content propagates transitively through chains:
- If `G(phi) in MCS_t`, then `G(G(phi)) in MCS_t` by modus ponens
- Therefore `G(phi) in GContent(MCS_t)`, ensuring persistence into all successors

**There is no corresponding axiom for F**:
- `F(phi) -> G(F(phi))` is **semantically invalid** — "phi will happen" does not imply "at all future times, phi will still be coming"
- `F(phi) = ~G(~phi)` means F is defined negatively, and `GContent` seeds only propagate positive G-formulas
- Lindenbaum extension of `GContent(M)` is FREE to add `G(~phi)`, killing `F(phi)` at all future positions

This asymmetry is **inherent to the logic itself**, not to any particular construction.

### 2. Literature Confirmation

Both teammates reviewed canonical texts and confirmed:

| Source | Approach | Uses Linear Chain? |
|--------|----------|-------------------|
| Goldblatt (1992) | All-MCS canonical model | No |
| Blackburn/de Rijke/Venema (2001) | All-MCS canonical model | No |
| Hughes & Cresswell (1996) | Henkin-style all-MCS | No |

**Key insight**: Standard texts use all-MCS domains for temporal completeness proofs precisely because linear chain constructions cannot handle F/P operators. This is often implicit — the texts don't discuss why chains fail, they simply don't use chains.

### 3. The Witness Comparability Problem (Zorn-based approach)

Even Zorn's lemma cannot solve this. From `SaturatedChain.lean` (lines 220-238): the witness MCS from `canonical_forward_F` is constructed via Lindenbaum's lemma and is NOT guaranteed to be **comparable** with all elements of an existing chain. For witness W to join chain C, W must be comparable with EVERY element of C — a condition that cannot be guaranteed.

### 4. All Attempted Alternatives Have Failed

The codebase documents at least 5 failed approaches (Task 916 produced 16 research reports and 12 plan versions):

| Approach | Why It Failed |
|----------|---------------|
| Enriched linear chain | F-formulas don't persist through GContent seeds |
| Witness-graph-guided chain | DAG has LOCAL GContent propagation, not universal |
| Constant family oracle | F(psi) in M doesn't imply psi in M |
| Two-timeline embedding | Nodes reachable by both directions conflict |
| Omega-squared construction | Would require processing F-obligations BEFORE Lindenbaum (impossible) |

### 5. Why CanonicalFMCS Works (Pattern Extraction)

The `CanonicalFMCS.lean` proof of `canonicalMCS_forward_F` is only 7 lines because:
1. `canonical_forward_F` constructs witness W with `CanonicalR M W` and `phi in W`
2. W is an MCS by construction
3. Domain = ALL MCSes, so W is **automatically** a domain element
4. No chain position assignment, no ordering proof, no persistence requirement

This is a **domain inclusion guarantee** that is impossible to replicate for any strict subset of MCSes.

### 6. Category-Theoretic Perspective

From a category-theoretic view:
- MCSes form a category with CanonicalR as morphisms (transitivity gives composition)
- A chain is a functor from a linearly ordered set to this category
- F-witnesses require **extending** the chain, but the extension may not exist in the category of chains
- The correct framework is **presheaves over CanonicalMCS** — function families indexed by all MCSes — which is exactly what `TemporalCoherentFamily` implements

## Synthesis

### Conflicts Found: 0

Both teammates reached identical conclusions through complementary methods:
- Teammate A via mathematical theory and literature review
- Teammate B via codebase archaeology and pattern analysis

### Gaps Identified: 1

**The AddCommGroup obstacle**: The current completeness theorem signature requires `[AddCommGroup D] [LinearOrder D]` on the duration domain. `CanonicalMCS` has a `Preorder` from CanonicalR reflexive closure, but NOT an AddCommGroup structure. This practical gap was identified by Teammate B and needs to be addressed for any CanonicalMCS-based solution.

## Recommended Approaches

### Approach A: Use CanonicalMCS as Primary Domain (HIGH CONFIDENCE)

Use the already-sorry-free `CanonicalFMCS` construction as the primary completeness vehicle.

**What exists**: `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean lines 293-311) is complete with no sorries.

**What's needed**: The completeness theorem needs to be formulated over CanonicalMCS domain rather than Int/Rat. This requires either:
- Weakening the `[AddCommGroup D]` requirement to `[Preorder D]`
- Or establishing a domain transfer from CanonicalMCS to the desired algebraic domain

**Mathematical soundness**: Matches the universal approach in the literature.

### Approach B: Countable Saturated Subchain + Domain Transfer (MEDIUM CONFIDENCE)

Extract a countable F/P-saturated subchain from CanonicalMCS and transfer to Int.

**Steps**:
1. Define `CountableSaturatedChain` as countable subset of CanonicalMCS containing root
2. Prove existence via Löwenheim-Skolem or explicit construction
3. Embed into Int via enumeration
4. Transfer F/P witnesses via inclusion in CanonicalMCS domain

**Risk**: Proving existence of a countable saturated chain containing a specific root is non-trivial.

### Approach C: Multi-Family Bundle (MEDIUM CONFIDENCE)

Use a bundle of chains where each F/P obligation spawns a new chain/family:
1. Primary family contains the original chain
2. Each F-obligation spawns a witness family containing the witness MCS
3. Bundle all families via ModalSaturation.lean infrastructure

**Risk**: Complexity; partially supported by existing `ModalSaturation.lean` patterns but requires significant new integration work.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical theory & literature | completed | HIGH |
| B | Codebase analysis & patterns | completed | HIGH |

## Bottom Line

**The mathematically correct path forward is to use the CanonicalFMCS approach** — it is the standard method in the literature, is already implemented sorry-free in the codebase, and avoids a fundamental limitation that has defeated 5+ alternative approaches over extensive development effort (Task 916).

The practical obstacle is the `AddCommGroup` requirement on the duration domain. Resolving this (via signature weakening or domain transfer) should be the focus of the next planning phase.

## Next Steps

1. Determine whether `AddCommGroup D` is genuinely needed for the completeness theorem or can be weakened
2. If AddCommGroup is needed: investigate domain transfer from CanonicalMCS to Int/Rat
3. If AddCommGroup can be weakened: refactor completeness to use CanonicalMCS directly
4. Consider abandoning IntBFMCS F/P sorries (leave as documented limitations) and focusing on the CanonicalFMCS path

## References

- Goldblatt (1992) - *Logics of Time and Computation*
- Blackburn, de Rijke, Venema (2001) - *Modal Logic*, Chapter 4
- Hughes & Cresswell (1996) - *A New Introduction to Modal Logic*
- CanonicalFMCS.lean (working sorry-free solution)
- IntBFMCS.lean (blocked implementation with documented limitation)
- SaturatedChain.lean (Zorn-based approach, witness comparability obstacle)
- Boneyard/DovetailingChain.lean, WitnessGraph.lean (failed approaches)
- Task 916 analysis (16 research reports, 12 plan versions documenting exploration)
