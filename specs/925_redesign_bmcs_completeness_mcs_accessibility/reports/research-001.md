# Research Report: Task #925

**Task**: Redesign BMCS completeness construction using MCS accessibility relation
**Date**: 2026-02-25
**Mode**: Team Research (2 teammates)
**Focus**: Study proposed construction, identify gaps/pitfalls, compare canonical frame vs seed-based approaches

## Summary

This research investigates the proposed MCS accessibility relation approach for BMCS completeness, comparing two broad construction strategies. **The key finding is that the problem requires not just a different construction, but a structural change to how the truth predicate handles the Box case.** The recommended approach combines the CanonicalMCS domain (which provides sorry-free temporal coherence) with a restructured truth predicate that eliminates the need for temporal coherence in witness families.

## Key Findings

### Finding 1: The Core Obstacle Is Architectural, Not Constructional

The central problem across ALL previous approaches (tasks 916, 922, 924) is:
- `BMCS.temporally_coherent` requires forward_F and backward_P for **EVERY** family in the bundle
- Witness families (for modal saturation) are constant families (same MCS at every time)
- Constant families **mathematically cannot** satisfy forward_F/backward_P

**Proof** (from research-005 task 924): For a constant family with MCS W:
- forward_F requires: F(phi) in W implies phi in W
- F(phi) = neg(G(neg phi)), so this requires: neg(G(neg phi)) in W implies phi in W
- By contraposition: neg(phi) in W implies G(neg(phi)) in W
- This would make G trivial (phi -> G(phi)), which is **not a theorem of the logic**

**Conclusion**: No construction can make constant witness families temporally coherent. The obstacle is mathematical.

### Finding 2: The Proposed "Four-Constraint" Accessibility Relation

The task description mentions "four-constraint accessibility". Based on the existing axiom system and codebase:

| Constraint | Formula | Implementation | Status |
|------------|---------|----------------|--------|
| Temporal Future | G phi in MCS1 -> phi in MCS2 | `CanonicalR` (GContent subset) | Proven |
| Temporal Past | H phi in MCS2 -> phi in MCS1 | `CanonicalR_past` (HContent subset) | Proven |
| Modal | Box phi in MCS1 -> phi in MCS2 | `BoxContent` subset | Proven for constant families |
| Modal-Temporal | Box G phi cascades via modal_future axiom | Derived from above | Follows |

**Existing infrastructure** in the codebase:
- `CanonicalR` defined in `CanonicalFrame.lean` with reflexivity, transitivity, forward_F, backward_P all sorry-free
- `BoxContent` defined in `CoherentConstruction.lean` with `diamond_boxcontent_consistent_constant` proven
- `GContent`, `HContent` defined in `TemporalContent.lean`

**Gap**: No unified relation combining all constraints. However, **the analysis reveals this unification is not the critical path**.

### Finding 3: Path A (Int + DovetailingChain) Is Definitively Unprovable

The omega-squared chain approach over D = Int fails due to the **Big Seed Counterexample**:
1. An MCS can contain both F(p) and F(neg p) simultaneously (this is consistent)
2. To satisfy forward_F, both p and neg p must be placed at future times
3. The "Big Seed" `{p, neg p} union GContent(M)` is **inconsistent**
4. Therefore, all F-witnesses cannot be placed at the same time point
5. Sequential placement faces uncontrollable Lindenbaum interference

**Verdict**: The 2 sorries in DovetailingChain.lean (forward_F at line 1869, backward_P at line 1881) are **mathematically unprovable** for any linear or omega-squared chain construction over Int.

### Finding 4: CanonicalMCS Domain Has Sorry-Free Temporal Infrastructure

The `CanonicalMCS` construction in `CanonicalBFMCS.lean` achieves temporal coherence:

| Property | Proof Status | Location |
|----------|--------------|----------|
| `canonicalMCSBFMCS` (BFMCS construction) | Sorry-free | line 158 |
| `canonicalMCS_forward_F` | Sorry-free | line 196 |
| `canonicalMCS_backward_P` | Sorry-free | line 217 |
| `canonical_forward_G` | Sorry-free | CanonicalFrame.lean |
| `canonical_backward_H` | Sorry-free | CanonicalFrame.lean |

**Why this works**: CanonicalMCS makes every MCS a domain element. Forward_F/backward_P witnesses (which are fresh Lindenbaum MCSes) automatically belong to the domain. No reachability argument needed.

**Remaining gap**: Modal coherence (modal_forward/modal_backward for BMCS) is not yet constructed for CanonicalMCS domain.

### Finding 5: The Breakthrough - Restructured Truth Predicate

**The critical insight** (from Teammate B): The problem is not how to construct temporally coherent witness families, but **whether we need temporal coherence for witness families at all**.

The current truth definition for Box recurses on all families:
```lean
| .box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
```

This forces the truth lemma to hold for witness families, requiring temporal coherence for them.

**The fix**: Redefine Box truth using syntactic MCS membership:
```lean
| .box phi => forall fam' in B.families, phi in fam'.mcs t
```

This eliminates inter-family recursion entirely. Benefits:
1. Truth lemma only needs to hold for the eval family
2. Temporal coherence only needed for eval family (satisfied by CanonicalMCS)
3. Witness families only need syntactic containment (satisfied by constant families)

**Proof validity**: The key bidirectional property `BMCS.box_iff_universal` (BMCS.lean:256) already proves:
```lean
Box phi in fam.mcs t iff forall fam' in B.families, phi in fam'.mcs t
```

This is **exactly** the restructured truth definition. No inter-family truth recursion is needed.

### Finding 6: All Required Infrastructure Is Already Sorry-Free

| Component | Location | Status | Purpose |
|-----------|----------|--------|---------|
| `canonicalMCSBFMCS` | CanonicalBFMCS.lean:158 | Sorry-free | Eval family with temporal coherence |
| `canonicalMCS_forward_F` | CanonicalBFMCS.lean:196 | Sorry-free | F-witness existence |
| `canonicalMCS_backward_P` | CanonicalBFMCS.lean:217 | Sorry-free | P-witness existence |
| `saturated_modal_backward` | ModalSaturation.lean:408 | Sorry-free | Modal backward from saturation |
| `CoherentBundle.toBMCS` | CoherentConstruction.lean | Sorry-free | Converts bundle to BMCS |
| `eval_saturated_bundle_exists` | CoherentConstruction.lean | Sorry-free | Modal saturation existence |
| `BMCS.box_iff_universal` | BMCS.lean:256 | Sorry-free | Box iff universal membership |
| `bmcs_truth_lemma` | TruthLemma.lean | Sorry-free | Main truth lemma |

### Finding 7: Comparison of Two Approaches

The user asked about two approaches:

**Approach 1: Universal Canonical Frame (CanonicalMCS + all MCSs)**
- Construct frame independent of any consistent sentence
- Show consistent sentences live in some MCS at time 0
- **Viability**: High, but requires restructured truth predicate

**Approach 2: Seed-Based Unraveling (DovetailingChain)**
- Start with consistent sentence, unravel recursively
- Saturate and complete to full model
- **Viability**: None - mathematically blocked by Big Seed counterexample

**The Winner**: Approach 1, combined with the restructured truth predicate, provides a complete path to sorry-free completeness.

## Synthesis: Conflicts and Resolution

### Conflict 1: Unified Seed vs Restructured Truth

**Teammate A** proposed a unified seed combining all obligations:
```
Seed = GContent(M) union {psi | F(psi) in M} union BoxContentSet(M)
```

**Teammate B** proposed eliminating the need for this via restructured truth predicate.

**Resolution**: Teammate B's approach is superior because:
1. The unified seed may face consistency problems (multiple F-witnesses can conflict)
2. The restructured truth predicate eliminates the architectural bottleneck entirely
3. It requires less new infrastructure (the key lemmas already exist)

### Gap Identified: The "Four Constraints" May Be Unnecessary

The task description proposed a four-constraint accessibility relation. However, analysis reveals:
- The constraints are correct mathematically
- They are already implemented separately (CanonicalR, BoxContent)
- **Unifying them is not the critical path** - the truth predicate restructuring is more important
- A unified relation would be an optimization, not a prerequisite for completeness

## Recommendations

### Primary Path: Restructured Truth Predicate + CanonicalMCS Domain

**Phase 1: Restructure `bmcs_truth_at` in BMCSTruth.lean**
- Change Box case from recursive truth to syntactic membership (3-line change)
- Re-prove derived lemmas if needed

**Phase 2: Re-prove TruthLemma.lean Box case**
- Use `BMCS.box_iff_universal` directly (already proven)
- No inter-family recursion needed
- G/H cases unchanged (use existing temporal_backward_G/H)

**Phase 3: Build BMCS over CanonicalMCS**
- Eval family: `canonicalMCSBFMCS` (existing, sorry-free temporal coherence)
- Witness families: Constant families from CoherentBundle (works with restructured truth)
- Modal saturation: Adapt CoherentBundle for CanonicalMCS domain

**Phase 4: Update Completeness.lean**
- Replace `construct_saturated_bmcs_int` with CanonicalMCS-based construction
- Verify end-to-end: representation theorem, weak completeness, strong completeness

### Alternative Path: Unified Accessibility (Lower Priority)

If the restructured truth approach encounters issues:
- Formalize `MCS_Accessible` combining GContent, HContent, BoxContent
- Prove unified seed consistency (non-trivial, may face F(p)/F(neg p) issues)
- Build families as accessibility chains

### What NOT to Pursue

1. **DovetailingChain forward_F/backward_P** - mathematically unprovable
2. **Constant witness families with temporal coherence** - mathematically impossible
3. **Big Seed approaches** - counterexample exists
4. **D = Int constructions** - domain forces sequential placement

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Accessibility constraints | Completed | Four-constraint identification, unified seed proposal, sorry inventory |
| B | Construction strategy | Completed | Big Seed counterexample citation, restructured truth breakthrough, infrastructure inventory |

## References

- `specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/reports/research-005.md` - Definitive analysis of Path A failure
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure and `box_iff_universal`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - Sorry-free temporal infrastructure
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Current truth lemma (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Modal saturation infrastructure

## Confidence Level

**HIGH (85%)** for the restructured truth predicate + CanonicalMCS approach.

**Basis**:
1. All required infrastructure components are already sorry-free
2. The key lemma `BMCS.box_iff_universal` proves the Box case bidirectionality
3. The approach eliminates the architectural bottleneck rather than working around it
4. Mathematical elegance: one targeted change unlocks the entire completeness chain

**Uncertainty (15%)**:
- The truth lemma re-proof may surface unexpected issues in edge cases
- CoherentBundle adaptation to CanonicalMCS may need minor adjustments
- End-to-end verification may reveal compatibility issues

## Summary of Viability

| Approach | Temporal Coherence | Modal Saturation | Overall | Verdict |
|----------|-------------------|------------------|---------|---------|
| Int + DovetailingChain | UNPROVABLE | Yes | BLOCKED | Abandon |
| Int + Omega-Squared | UNPROVABLE | Yes | BLOCKED | Abandon |
| CanonicalMCS + Current Truth | Eval: YES, Witness: NO | Yes | BLOCKED | Modify truth |
| CanonicalMCS + Restructured Truth | Eval: YES (sufficient) | Yes | **VIABLE** | **RECOMMENDED** |

## Next Steps

1. Implement restructured `bmcs_truth_at` definition in BMCSTruth.lean
2. Re-prove TruthLemma.lean with restructured Box case
3. Build BMCS construction over CanonicalMCS using CoherentBundle for modal saturation
4. Update Completeness.lean entry point
5. Verify end-to-end sorry-freedom
