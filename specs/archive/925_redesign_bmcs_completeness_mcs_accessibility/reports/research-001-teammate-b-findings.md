# Research Findings: Teammate B - Construction Strategy Analysis

**Task**: 925 - Redesign BMCS completeness using MCS accessibility relation
**Date**: 2026-02-25
**Focus**: Compare Universal Canonical Frame vs Seed-Based Unraveling approaches, inventory infrastructure, recommend strategy

## Key Findings

### Finding 1: The Core Conflict Is Temporal Coherence for Witness Families

The central obstacle across ALL approaches is that `BMCS.temporally_coherent` requires forward_F and backward_P for EVERY family in the bundle, not just the eval family. Witness families (added for modal saturation) are typically constant families, and constant families trivially satisfy forward_G/backward_H (via T-axiom) but FAIL forward_F/backward_P. This is proven impossible in research-005.md for task 924 (Section 4.3-4.4):

- Constant family forward_F requires: F(phi) in W implies phi in W, i.e., neg(G(neg phi)) in W implies phi in W
- By contraposition this requires: neg(phi) in W implies G(neg(phi)) in W
- This is NOT a theorem of the logic (it would make G trivial)

**No construction can circumvent this for constant witness families.** The obstacle is mathematical, not engineering.

### Finding 2: Path A (Omega-Squared Chain Over Int) Is Definitively Not Viable

Research-005 for task 924 provided a definitive counterexample (Section 3.4):

- An MCS can contain both F(p) and F(neg p) simultaneously
- F(p) = neg(G(neg p)), F(neg p) = neg(G(p)) -- consistent together
- But the "Big Seed" {p, neg p} union GContent(M) is inconsistent
- Therefore, all F-witnesses cannot be placed at the same time point via single Lindenbaum
- Sequential placement faces uncontrollable Lindenbaum interference (each extension can kill future witnesses)

**The 2 sorries in DovetailingChain.lean (forward_F, backward_P at lines 1869, 1881) are UNPROVABLE for the linear chain construction.** This is not a matter of finding the right proof -- the mathematical structure prevents it.

### Finding 3: Approach 1 (Universal Canonical Frame / CanonicalMCS) Has Sorry-Free Temporal Infrastructure

The `CanonicalMCS` domain in `CanonicalBFMCS.lean` provides a BFMCS where:

| Property | Status | Proof Location |
|----------|--------|----------------|
| `canonicalMCSBFMCS` | Sorry-free | CanonicalBFMCS.lean:158 |
| `canonicalMCS_forward_G` | Sorry-free | CanonicalBFMCS.lean:128 |
| `canonicalMCS_backward_H` | Sorry-free | CanonicalBFMCS.lean:142 |
| `canonicalMCS_forward_F` | Sorry-free | CanonicalBFMCS.lean:196 |
| `canonicalMCS_backward_P` | Sorry-free | CanonicalBFMCS.lean:217 |
| `temporal_coherent_family_exists_CanonicalMCS` | Sorry-free | CanonicalBFMCS.lean:267 |

The key insight: CanonicalMCS makes every MCS a domain element, so forward_F/backward_P witnesses (which are fresh Lindenbaum MCSes) are automatically in the domain. No reachability argument needed.

**However**: CanonicalMCS gives temporal coherence for the eval family only. The gap is modal coherence (modal_forward / modal_backward) for the BMCS.

### Finding 4: Approach 2 (Seed-Based Unraveling via DovetailingChain) Has Failed Repeatedly

The DovetailingChain construction (`DovetailingChain.lean`, 1908 lines) has been attempted across 12+ approaches and tasks (843, 857, 864, 881, 916, 922, 924). Key failure modes:

1. **F-persistence failure**: F(psi) in M_n does NOT imply F(psi) in M_{n+1} when M_{n+1} = Lindenbaum(GContent(M_n)). Lindenbaum can introduce G(neg(psi)).
2. **Cross-sign propagation**: Resolved in Task 916 for G/H, but F/P remain blocked.
3. **Big Seed inconsistency**: Cannot combine multiple F-witnesses at same time point (counterexample: F(p) and F(neg p)).

**Verdict**: Seed-based unraveling over Int is architecturally incapable of satisfying forward_F/backward_P.

### Finding 5: The "Third Way" -- Restructured Truth Predicate -- Is the Breakthrough

Research-005 for task 924 (Sections 5.3-5.5) identified a critical architectural insight:

**The truth lemma's Box case currently recurses on ALL families:**
```lean
| .box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
```

This forces the truth lemma to hold for witness families, which requires temporal coherence for witness families.

**The fix: Redefine Box truth using syntactic MCS membership:**
```lean
| .box phi => forall fam' in B.families, phi in fam'.mcs t
```

This eliminates the inter-family recursion entirely. The truth lemma only needs to hold for the eval family. Temporal coherence is only needed for the eval family. Witness families only need to contain the right formulas syntactically, which constant families already do.

**Proof sketch of the revised truth lemma Box case:**
- Forward: Box(psi) in fam.mcs(t) -> psi in fam'.mcs(t) for all fam' (by `modal_forward`). Already proven.
- Backward: psi in fam'.mcs(t) for all fam' -> Box(psi) in fam.mcs(t) (by `modal_backward`). Already proven via `saturated_modal_backward` in ModalSaturation.lean.

The `BMCS.box_iff_universal` theorem (BMCS.lean:256) already establishes this bidirectional property.

### Finding 6: CoherentBundle Infrastructure Is Sorry-Free for Modal Saturation

The `CoherentConstruction.lean` module provides:

| Component | Status | Purpose |
|-----------|--------|---------|
| `BoxContent` | Defined | Set of chi where Box(chi) in any family MCS |
| `WitnessSeed` | Defined | {psi} union BoxContent(base) for witness construction |
| `diamond_boxcontent_consistent_constant` | Proven | Witness seed consistency for constant families |
| `CoherentBundle` | Defined | Collection of mutually coherent constant families |
| `CoherentBundle.toBMCS` | Proven (sorry-free) | Converts saturated bundle to BMCS |
| `eval_saturated_bundle_exists` | Proven (sorry-free) | Existence of modally saturated bundle |

This infrastructure handles modal saturation completely and is sorry-free.

### Finding 7: Completeness Chain Is Already Polymorphic

The key theorems in the completeness chain are polymorphic in the domain type D:

| Theorem | Domain Requirement | Int-specific? |
|---------|-------------------|---------------|
| `bmcs_truth_lemma` | `[Preorder D] [Zero D]` | No |
| `bmcs_representation` | Uses `BMCS Int` | Yes (only in construction entry) |
| `bmcs_weak_completeness` | Via `bmcs_representation` | Yes (transitively) |
| `bmcs_strong_completeness` | Via `bmcs_context_representation` | Yes (transitively) |

The ONLY Int dependency is `construct_saturated_bmcs_int` called in Completeness.lean. Providing a CanonicalMCS construction would make the entire chain sorry-free.

## Approach Comparison

### Approach 1: Universal Canonical Frame (CanonicalMCS Domain)

**Strengths:**
- Temporal coherence is sorry-free for the eval family (already proven)
- Forward_F and backward_P are trivially satisfied (each witness is an independent MCS)
- Avoids the Lindenbaum uncontrollability problem entirely
- CanonicalR linearity proven (CanonicalEmbedding.lean:280)
- Preorder instance on CanonicalMCS already exists (CanonicalBFMCS.lean:95)

**Weaknesses:**
- Modal coherence (going from BFMCS to BMCS) not yet constructed for this domain
- Requires restructured truth predicate (Box case change in BMCSTruth.lean)
- Completeness.lean must be updated from Int to CanonicalMCS

**Gap analysis:**
1. Need: BMCS over CanonicalMCS with modal saturation -- can use CoherentBundle
2. Need: Restructured truth predicate -- targeted 3-line change + re-proof
3. Need: Updated Completeness.lean -- generalize construction entry point

### Approach 2: Seed-Based Unraveling (DovetailingChain over Int)

**Strengths:**
- Significant existing infrastructure (1908 lines in DovetailingChain.lean)
- Forward_G and backward_H cross-sign cases are resolved
- Dovetailing index functions work correctly

**Weaknesses:**
- forward_F and backward_P are UNPROVABLE for the linear chain (proven in research-005)
- The Big Seed counterexample kills omega-squared approaches
- 12+ failed attempts across multiple tasks
- Lindenbaum uncontrollability is a mathematical obstruction, not an engineering gap

**Gap analysis:**
1. 2 sorries remain (forward_F, backward_P) -- mathematically unprovable
2. Even if resolved, would only give temporal coherence for eval family
3. Witness family temporal coherence is still blocked (constant family impossibility)

### Approach 3 ("Third Way"): Restructured Truth Predicate + CanonicalMCS Domain

This is NOT a separate approach but the combination that makes Approach 1 work end-to-end.

**Construction:**
1. Domain: CanonicalMCS (all MCSes with CanonicalR Preorder)
2. Eval family: `canonicalMCSBFMCS` (identity mapping, sorry-free temporal coherence)
3. Witness families: Constant families from CoherentBundle (sorry-free modal saturation)
4. Truth predicate: Box case uses syntactic membership (no inter-family truth recursion)
5. Truth lemma: Only proved for eval family, using its temporal coherence
6. Modal forward/backward: From `saturated_modal_backward` (sorry-free)

**This approach eliminates ALL sorries in the completeness chain.**

## Recommended Strategy

### Primary Recommendation: Restructured Truth Predicate + CanonicalMCS Domain

**Phase 1: Restructure `bmcs_truth_at` in BMCSTruth.lean**
- Change Box case from recursive truth to syntactic membership
- This is a 3-line definitional change
- Re-prove derived lemmas (bmcs_truth_neg, bmcs_truth_and, etc.)

**Phase 2: Re-prove TruthLemma.lean**
- The truth lemma only needs temporal coherence for the family under proof
- Box case uses `BMCS.box_iff_universal` directly (already proven in BMCS.lean:256)
- G and H backward cases use `temporal_backward_G`/`temporal_backward_H` as before
- The proof becomes SIMPLER because there is no inter-family recursion

**Phase 3: Build BMCS over CanonicalMCS**
- Eval family: `canonicalMCSBFMCS` (existing, sorry-free)
- Modal saturation: Adapt CoherentBundle construction for CanonicalMCS domain
  - Constant witness families work because we no longer need temporal coherence for them
  - `constructWitnessFamily` from ModalSaturation.lean provides the witness MCS
  - Wrap constant witness families in the BMCS bundle
- Combine into `fully_saturated_bmcs_exists_CanonicalMCS`

**Phase 4: Update Completeness.lean**
- Replace `construct_saturated_bmcs_int` with CanonicalMCS-based construction
- TruthLemma is already polymorphic; only the construction entry point changes
- Verify end-to-end: representation theorem, weak completeness, strong completeness

**Phase 5: Documentation and Cleanup**
- Document DovetailingChain.lean sorries as superseded (not just "not yet proved")
- Mark Int-based construction as deprecated
- Remove or archive unused omega-squared/seed infrastructure

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Restructured truth predicate breaks soundness | Low | High | Box case is equivalent to universal quantification; `BMCS.box_iff_universal` already proves the equivalence |
| CoherentBundle does not adapt to CanonicalMCS | Low | Medium | CoherentBundle.toBMCS is sorry-free and domain-polymorphic |
| Truth lemma re-proof is harder than expected | Low | Medium | Proof becomes simpler (fewer recursive cases); Box case uses existing lemma directly |
| Completeness.lean has hidden Int dependencies | Low | Medium | Only `construct_saturated_bmcs_int` is Int-specific; rest is polymorphic |
| CanonicalMCS Preorder is not Zero | Low | Low | `CanonicalMCS.instZero` already exists (CanonicalBFMCS.lean:178) |

## Evidence (Verified Lemma Names)

### Sorry-Free Temporal Infrastructure (CanonicalBFMCS.lean)
- `canonicalMCSBFMCS` -- BFMCS CanonicalMCS construction (line 158)
- `canonicalMCS_forward_F` -- F-coherence (line 196, no sorry)
- `canonicalMCS_backward_P` -- P-coherence (line 217, no sorry)
- `temporal_coherent_family_exists_CanonicalMCS` -- existence theorem (line 267, no sorry)

### Sorry-Free Modal Infrastructure (ModalSaturation.lean)
- `saturated_modal_backward` -- modal backward from saturation (line 408, no sorry)
- `diamond_implies_psi_consistent` -- Diamond formula consistency (line 169, no sorry)
- `constructWitnessFamily` -- witness family construction (line 277, no sorry)

### Sorry-Free CoherentBundle Infrastructure (CoherentConstruction.lean)
- `CoherentBundle.toBMCS` -- converts saturated bundle to BMCS
- `eval_saturated_bundle_exists` -- saturation existence (Phase 5, proven)

### Key Bidirectional Lemma (BMCS.lean)
- `BMCS.box_iff_universal` -- Box phi iff phi in all families (line 256, no sorry)

### Existing Sorries in Completeness Chain
- `fully_saturated_bmcs_exists_int` -- TemporalCoherentConstruction.lean:819 (PRIMARY BLOCKER)
- `temporal_coherent_family_exists` -- TemporalCoherentConstruction.lean:613 (generic D, sorry)
- `singleFamilyBMCS` modal_backward -- Construction.lean:197 (deprecated, sorry)
- DovetailingChain forward_F -- DovetailingChain.lean:1869 (UNPROVABLE)
- DovetailingChain backward_P -- DovetailingChain.lean:1881 (UNPROVABLE)

## Confidence Level

**HIGH** (9/10) for the recommended strategy.

**Basis for confidence:**
1. The restructured truth predicate is a minimal, targeted change that eliminates the architectural bottleneck
2. All required infrastructure components are already sorry-free (temporal coherence for CanonicalMCS, modal saturation via CoherentBundle)
3. The mathematical argument is well-understood and has been validated across multiple research rounds
4. The `BMCS.box_iff_universal` lemma already proves the key bidirectional property needed for the Box case
5. The approach has been independently validated in research-005 for task 924

**Remaining uncertainty** (1/10):
- The truth lemma re-proof could surface unexpected issues in the G/H backward cases
- The CoherentBundle adaptation to CanonicalMCS domain may need adjustments to the WitnessSeed construction
- End-to-end verification may reveal minor compatibility issues in Completeness.lean

## Summary of Approach Viability

| Approach | Temporal Coherence | Modal Coherence | Sorry-Free? | Recommended? |
|----------|-------------------|-----------------|-------------|--------------|
| Int + DovetailingChain | UNPROVABLE | Via saturation | No (2+ sorries) | No |
| Int + Omega-Squared | UNPROVABLE (BigSeed counterexample) | Via saturation | No | No |
| CanonicalMCS + Constant Witnesses | Eval: yes, Witnesses: IMPOSSIBLE | Via saturation | No | No |
| CanonicalMCS + Restructured Truth | Eval: yes (sufficient) | Via saturation | YES | **YES** |
