# Teammate B: Alternative Approaches Analysis

**Task**: 870 - Zorn-based family selection for temporal coherence
**Focus**: Alternative approaches for sorry-free path
**Date**: 2026-02-12
**Session**: sess_1770947549_cdaca1

## Summary

DovetailingChain has 4 sorry sites compared to ZornFamily's 6 active sorries. Critically, DovetailingChain's cross-sign propagation sorries are SOLVABLE using the same "collect-into-one-MCS" argument that works for Zorn's cross-sign case. The one-at-a-time witness strategy via `temporal_witness_seed_consistent` provides correct granularity for F/P witness placement. A combined approach using one-at-a-time witnesses plus GH-controlled Lindenbaum is theoretically cleanest but requires significant new infrastructure.

## DovetailingChain Analysis

### Current State
- **File**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- **Lines**: 667
- **Sorry count**: 4
- **Construction**: Interleaved dovetailing (M_0, M_1, M_{-1}, M_2, M_{-2}, ...)

### Sorry Locations

| Line | Location | Type |
|------|----------|------|
| 606 | `buildDovetailingChainFamily.forward_G` (t < 0 branch) | Cross-sign G propagation |
| 617 | `buildDovetailingChainFamily.backward_H` (t >= 0 branch) | Cross-sign H propagation |
| 633 | `buildDovetailingChainFamily_forward_F` | F-witness construction |
| 640 | `buildDovetailingChainFamily_backward_P` | P-witness construction |

### Sorry Classification

| Sorry | Type | Solvability |
|-------|------|-------------|
| Line 606 (forward_G cross-sign) | Cross-sign propagation | **SOLVABLE** - same "collect-into-one-MCS" argument as Zorn cross-sign |
| Line 617 (backward_H cross-sign) | Cross-sign propagation | **SOLVABLE** - symmetric to line 606 |
| Line 633 (forward_F) | F-witness construction | **HARDER** - requires dovetailing enumeration tracking |
| Line 640 (backward_P) | P-witness construction | **HARDER** - symmetric to line 633 |

### Why DovetailingChain Might Be Better

1. **Cross-sign sorries are solvable**: Unlike Zorn's seed consistency problem (which is mathematically FALSE for conflicting F-obligations), DovetailingChain's cross-sign issues use the same "collect-into-one-MCS" argument that works in the Zorn cross-sign case.

2. **No multi-witness seed inconsistency**: DovetailingChain builds one MCS at a time with explicit witness placement. It never needs to place multiple F-witnesses simultaneously in the same seed.

3. **Construction trace available**: The explicit construction order (dovetailIndex/dovetailRank) provides a trace that Zorn's maximality argument hides.

4. **Proven infrastructure**:
   - `dovetailRank_dovetailIndex` and `dovetailIndex_dovetailRank` are proven (inverses)
   - `dovetail_neighbor_constructed` is proven
   - Same-sign coherence (forward_G for t >= 0, backward_H for t <= 0) is fully proven

### Why DovetailingChain Has Different Challenges

1. **F/P witness enumeration**: The F/P witness sorries require proving that the dovetailing enumeration eventually processes all (time, formula) pairs, ensuring witnesses are placed. This is a counting/enumeration argument, not a consistency argument.

2. **Cross-sign requires global view**: Cross-sign propagation (G from negative to positive times) requires understanding that the construction propagates content through time 0 (the shared base MCS).

## One-at-a-Time Witness Strategy

### Available Infrastructure

- **`temporal_witness_seed_consistent`** (TemporalCoherentConstruction.lean):
  - **Status**: PROVEN
  - **Signature**: `(M : Set Formula) -> SetMaximalConsistent M -> (psi : Formula) -> some_future psi in M -> SetConsistent ({psi} union GContent M)`
  - **Purpose**: Single F-witness seed is consistent

- **`temporal_witness_seed_consistent_past`** (TemporalLindenbaum.lean):
  - **Status**: PROVEN
  - **Signature**: `(M : Set Formula) -> SetMaximalConsistent M -> (psi : Formula) -> some_past psi in M -> SetConsistent ({psi} union HContent M)`
  - **Purpose**: Single P-witness seed is consistent

### Related Lemmas (All Verified via lean_local_search)

| Lemma | File | Status |
|-------|------|--------|
| `GContent_consistent` | ZornFamily.lean, TemporalChain.lean | PROVEN |
| `HContent_consistent` | ZornFamily.lean, TemporalChain.lean | PROVEN |
| `GContent_propagates_forward` | ZornFamily.lean | PROVEN |
| `HContent_propagates_backward` | ZornFamily.lean | PROVEN |
| `CoherentExtensions_chain_has_ub` | ZornFamily.lean | PROVEN |

### Implementation Sketch

One-at-a-time witness construction would work as follows:

1. **Base**: Start with singleton domain {0} containing consistent MCS extending context
2. **Iterative Extension**: For each F-obligation `F(psi) in mcs(t)`:
   - Use `temporal_witness_seed_consistent` to show `{psi} union GContent(mcs(t))` is consistent
   - Extend via Lindenbaum to get MCS at time t+1
   - Mark F(psi) as witnessed
3. **Symmetric for P**: Use `temporal_witness_seed_consistent_past` for past direction
4. **Repeat**: Process all F/P obligations one at a time

**Key advantage**: Never tries to place conflicting witnesses simultaneously.

### Missing Pieces

1. **Iteration machinery**: Need to define:
   - Enumeration of (time, formula) pairs
   - "Already witnessed" predicate
   - Termination argument (or use omega-step construction)

2. **Coherence preservation**: After adding witness, must show:
   - Extended family still satisfies forward_G/backward_H
   - New MCS integrates correctly with existing structure

3. **GH-controlled Lindenbaum** (for new-to-old propagation): Must ensure the Lindenbaum extension doesn't introduce G/H formulas that violate coherence with existing MCSs.

## GH-Controlled Lindenbaum

### Concept

GH-controlled Lindenbaum is a modified Lindenbaum extension that:
1. Takes a "compatibility predicate" with existing family F
2. Only adds G(phi) to the extension if phi is in all future domain MCSs
3. Only adds H(phi) to the extension if phi is in all past domain MCSs
4. Results in an MCS that is "GH-compatible" with F

### Current Infrastructure

**Existing components**:
- `set_lindenbaum` (MaximalConsistent.lean): Standard Lindenbaum extension
- `TemporalForwardSaturated`, `TemporalBackwardSaturated` predicates
- `henkinLimit` construction in TemporalLindenbaum.lean (partial model)

**Missing components**:
- GH-compatibility predicate definition
- Selective Lindenbaum that respects GH-compatibility
- Proof that selective extension is still maximally consistent

### What It Would Take

**Estimated effort**: 6-8 hours (high complexity)

1. **Define GH-compatibility** (1-2 hours):
   ```lean
   def GHCompatible (S : Set Formula) (F : PartialFamily) (t : Int) : Prop :=
     (forall phi, G phi in S -> forall s in domain, t < s -> phi in F.mcs s) and
     (forall phi, H phi in S -> forall s in domain, s < t -> phi in F.mcs s)
   ```

2. **Prove seed is GH-compatible** (1 hour):
   Show extensionSeed F t is GH-compatible with F at t.

3. **Selective Lindenbaum construction** (2-3 hours):
   Modify Lindenbaum to only add G/H formulas that preserve compatibility.
   This requires careful handling of the enumeration order.

4. **Prove result is MCS** (2 hours):
   Show the selective extension is still maximally consistent.
   Key: if G(phi) is rejected, neg(G(phi)) = F(neg(phi)) can be added.

### Solves New-to-Old Problem

With GH-controlled Lindenbaum:
- Line 1677 (h_G_from_new in Zorn): G phi in mcs_t implies phi in F.mcs(s') for s' > t
  - Proof: mcs_t was built via GH-compatible extension, so GH-compatibility holds
- Line 1684 (h_H_from_new in Zorn): Symmetric

**Does NOT solve**: Seed consistency for pure past/future cases (those are mathematically false).

## Comparison: ZornFamily vs DovetailingChain Sorries

### ZornFamily Sorry Inventory (6 Active)

| Line | Type | Status |
|------|------|--------|
| 1607 | `non_total_has_boundary` (gap case) | Mathematically FALSE |
| 1677 | `maximal_implies_total` h_G_from_new | Requires GH-controlled Lindenbaum |
| 1684 | `maximal_implies_total` h_H_from_new | Requires GH-controlled Lindenbaum |
| 1774 | `total_family_FObligations_satisfied` | Requires construction trace |
| 1790 | `total_family_PObligations_satisfied` | Requires construction trace |

**Note**: The false lemmas `multi_witness_seed_consistent_future/past` (lines 844, 874) have been identified as FALSE and should be deleted.

### DovetailingChain Sorry Inventory (4 Active)

| Line | Type | Status |
|------|------|--------|
| 606 | forward_G cross-sign | **SOLVABLE** via collect-into-one-MCS |
| 617 | backward_H cross-sign | **SOLVABLE** via collect-into-one-MCS |
| 633 | forward_F witnesses | Requires enumeration tracking |
| 640 | backward_P witnesses | Requires enumeration tracking |

### Summary Comparison

| Criterion | ZornFamily | DovetailingChain |
|-----------|------------|------------------|
| Total sorries | 6 | 4 |
| Mathematically FALSE | 1 (gap case) | 0 |
| Solvable now | 0 | 2 (cross-sign) |
| Requires new infrastructure | 4 (GH-Lindenbaum) | 2 (enumeration) |
| Construction trace available | No (Zorn hides it) | Yes (explicit) |

## Recommendation

### Primary Path: Pivot to DovetailingChain

**Rationale**:
1. DovetailingChain has 4 sorries vs Zorn's 6 active sorries
2. DovetailingChain's cross-sign sorries (2 of 4) are SOLVABLE with existing argument
3. DovetailingChain's F/P sorries require enumeration tracking, not consistency arguments
4. ZornFamily's `multi_witness_seed_consistent` lemmas are mathematically FALSE - no amount of work fixes them
5. ZornFamily's `non_total_has_boundary` is mathematically FALSE for gap domains

**Action items**:
1. Factor out cross-sign collection argument as shared lemma
2. Apply to DovetailingChain lines 606, 617 (estimated 2-3 hours)
3. Design F/P witness enumeration tracking for DovetailingChain (estimated 4-6 hours)
4. Archive ZornFamily approach with lessons learned

### Alternative Path: Combined One-at-a-Time + GH-Controlled Lindenbaum (NOT recommended unless time permits)

This is theoretically cleanest but requires:
- GH-controlled Lindenbaum implementation (6-8 hours)
- Iteration machinery for one-at-a-time witnesses (4-6 hours)
- Integration with existing infrastructure (2-3 hours)

**Total**: 12-17 hours vs 6-9 hours for DovetailingChain pivot

### Estimated Effort

| Approach | Effort | Sorry Outcome | Risk |
|----------|--------|---------------|------|
| DovetailingChain pivot | 6-9 hours | 2 sorries (F/P) | Medium |
| Combined approach | 12-17 hours | 0 sorries (if successful) | High |
| Accept Zorn debt | 2-3 hours | 6 sorries (3 mathematically false) | Low |

## Confidence Level

**Medium-High** on DovetailingChain recommendation.

**Basis**:
- Cross-sign argument is well-understood (same as Zorn cross-sign case)
- Single-witness lemmas are proven and work correctly
- The mathematical falsity of multi_witness_seed_consistent is definitive
- DovetailingChain's F/P sorries are qualitatively different (enumeration tracking vs consistency)

**Uncertainty**:
- F/P witness enumeration in DovetailingChain may reveal additional challenges
- GH-controlled Lindenbaum complexity is estimated, not measured

## References

- Task 880 research: `specs/880_augmented_extension_seed_approach/reports/research-001.md`
- Task 870 research-005 through research-007
- DovetailingChain.lean: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- ZornFamily.lean: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- TemporalLindenbaum.lean: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`
