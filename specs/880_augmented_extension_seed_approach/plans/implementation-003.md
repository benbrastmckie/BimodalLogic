# Implementation Plan: Task #880 (v003) - Unified Chain DovetailingChain

**Task**: 880 - Redesign DovetailingChain with combined GContent/HContent seeds
**Version**: 003
**Created**: 2026-02-12
**Language**: lean
**Status**: [NOT STARTED]
**Estimated Effort**: 29-43 hours
**Research Input**: research-005.md (comparative analysis)

## Overview

This plan redesigns DovetailingChain to use a unified chain construction where each step's seed includes BOTH GContent from past-constructed times AND HContent from future-constructed times. This solves the cross-sign temporal propagation problem that blocked v002 by building cross-sign constraints INTO the construction rather than trying to enforce them post-hoc.

### Why v002 Failed

The two-chain architecture (forward chain with GContent seeds, backward chain with HContent seeds) cannot support cross-sign temporal propagation:
- G formulas only propagate through GContent-seeded forward chain
- H formulas only propagate through HContent-seeded backward chain
- G formulas in backward chain (t < 0) have no path to forward chain (t > 0)

### Why v003 Works

The unified chain uses combined seeds at each step:
```
unifiedSeed(n) = GContent(all M_t where t < dovetailIndex(n) and already constructed)
              ∪ HContent(all M_t where t > dovetailIndex(n) and already constructed)
```

This ensures:
- G formulas propagate forward through both positive AND negative times
- H formulas propagate backward through both positive AND negative times
- Cross-sign propagation happens naturally via the shared base M_0

### Inherited Infrastructure

From DovetailingChain.lean (reusable ~50%):
- `dovetailIndex`, `dovetailRank` - Dovetailing enumeration functions
- `dovetailRank_dovetailIndex`, `dovetailIndex_dovetailRank` - Bijection proofs
- `dovetail_neighbor_constructed` - Construction order property
- `dovetail_GContent_consistent`, `dovetail_HContent_consistent` - Component consistency
- `temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent` - Witness seeds

## Goals & Non-Goals

**Goals**:
- Create unified chain construction in new file `UnifiedChain.lean`
- Prove `combined_seed_consistent`: GContent ∪ HContent is consistent
- Prove cross-sign propagation for forward_G and backward_H
- Resolve all 4 DovetailingChain sorries via unified approach
- Achieve zero-sorry `temporal_coherent_family_exists_unified`

**Non-Goals**:
- Modifying DovetailingChain.lean (preserved as reference)
- Optimizing proof performance (correctness first)
- Addressing RecursiveSeed.lean sorries (separate approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| combined_seed_consistent harder than expected | HIGH | MEDIUM | Decision point after Phase 2; fallback to RecursiveSeed |
| Bidirectional indexing complexity | MEDIUM | LOW | Careful lemma factoring |
| Seed size growth complicates proofs | LOW | LOW | Incremental construction |
| F/P witness placement unchanged difficulty | MEDIUM | MEDIUM | Same approach as v002 Phase 3 |

## Sorry Characterization

### Target Sorries (inherited from DovetailingChain)

| ID | Line | Name | v003 Resolution |
|----|------|------|-----------------|
| D1 | 606 | forward_G (t < 0) | Unified seed contains GContent from all prior steps |
| D2 | 617 | backward_H (t >= 0) | Unified seed contains HContent from all prior steps |
| D3 | 633 | forward_F | Dovetailing enumeration (unchanged from v002) |
| D4 | 640 | backward_P | Symmetric to D3 |

### New Theorems Required

| Theorem | Purpose | Difficulty |
|---------|---------|------------|
| `combined_seed_consistent` | GContent ∪ HContent is consistent | HARD |
| `unifiedChain_G_propagates` | G propagates through unified chain | MEDIUM |
| `unifiedChain_H_propagates` | H propagates through unified chain | MEDIUM |
| `unifiedChain_forward_G` | forward_G for all t, t' | MEDIUM |
| `unifiedChain_backward_H` | backward_H for all t, t' | MEDIUM |

## Implementation Phases

### Phase 1: Design Unified Chain Structure (2-3 hours) [NOT STARTED]

**Dependencies**: None
**Goal**: Create the unified chain construction framework

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean`
- [ ] Import DovetailingChain, TemporalContent, MaximalConsistent
- [ ] Define `unifiedSeed : Nat → Set Formula`
  ```lean
  def unifiedSeed (constructed : Nat → Option (Set Formula)) (n : Nat) : Set Formula :=
    let t := dovetailIndex n
    let pastContent := ⋃ (m : Nat) (hm : m < n) (ht : dovetailIndex m < t),
        GContent (constructed m).getD ∅
    let futureContent := ⋃ (m : Nat) (hm : m < n) (ht : dovetailIndex m > t),
        HContent (constructed m).getD ∅
    pastContent ∪ futureContent
  ```
- [ ] Define `unifiedChainMCS : Nat → {M : Set Formula // SetMaximalConsistent M}`
- [ ] Define `unifiedChainSet : Int → Set Formula` (wrapper)

**Verification**:
- [ ] File compiles with definitions
- [ ] Types are correct
- [ ] No new sorries in structure

---

### Phase 2: Prove Combined Seed Consistency (8-12 hours) [NOT STARTED]

**Dependencies**: Phase 1
**Goal**: Prove the critical theorem that makes unified chain work

**DECISION POINT**: This is the make-or-break phase. If combined_seed_consistent cannot be proven in 12-15 hours, pivot to RecursiveSeed.

**Strategy 1 - T-axiom reduction**:
```lean
-- Both GContent and HContent elements satisfy T-axiom:
-- G phi in M implies phi in M
-- H phi in M implies phi in M
-- So GContent(M) ⊆ M and HContent(M) ⊆ M via T-axiom
-- If M_s and M_t share a common ancestor (M_0),
-- their GContent/HContent may share consistency
```

**Strategy 2 - Temporal logic duality**:
```lean
-- G phi in M and H(neg phi) in same MCS is inconsistent
-- Because G phi → phi and H(neg phi) → neg phi
-- So phi and neg phi would both be in the MCS
-- This constrains what can appear in combined seed
```

**Tasks**:
- [ ] Prove `GContent_HContent_consistent_same_MCS`: GContent(M) ∪ HContent(M) consistent
- [ ] Prove `GContent_HContent_consistent_shared_base`:
      If M_s and M_t both extend M_0, then GContent(M_s) ∪ HContent(M_t) is consistent
- [ ] Prove `combined_seed_consistent`: Full theorem for arbitrary constructed steps
- [ ] Handle edge case: n = 0 (base case, seed is empty or just base context)
- [ ] Handle edge case: n = 1 (only M_0 exists, seed is GContent(M_0) or HContent(M_0))

**Verification**:
- [ ] `lake build` succeeds
- [ ] No sorry in `combined_seed_consistent`
- [ ] If blocked >12h, evaluate pivot to RecursiveSeed

---

### Phase 3: Migrate Same-Sign Infrastructure (3-5 hours) [NOT STARTED]

**Dependencies**: Phase 2
**Goal**: Port proven same-sign proofs from DovetailingChain

**Tasks**:
- [ ] Port `dovetailForwardChain_G_propagates` → `unifiedChain_G_propagates_forward`
- [ ] Port `dovetailBackwardChain_H_propagates` → `unifiedChain_H_propagates_backward`
- [ ] Prove `unifiedChainSet_is_mcs`: Each chain element is MCS
- [ ] Prove `unifiedChainMCS_extends_seed`: Lindenbaum extension includes seed
- [ ] Verify same-sign propagation still works with combined seed

**Verification**:
- [ ] Same-sign tests pass (positive-to-positive, negative-to-negative)
- [ ] `lake build` succeeds

---

### Phase 4: Prove Cross-Sign Propagation (6-10 hours) [NOT STARTED]

**Dependencies**: Phases 2, 3
**Goal**: Resolve D1 and D2 sorries

**Key Insight**: Cross-sign propagation works because:
1. G phi in M_t (t < 0) means G phi entered M_t's construction
2. G phi is in unifiedSeed for all later steps n where dovetailIndex(n) > t
3. In particular, G phi is in seed for M_0 (step 0), M_1 (step 1), etc.
4. So G phi is in all positive-time MCSs
5. By T-axiom, phi is in all positive-time MCSs

**Tasks**:
- [ ] Prove `G_in_negative_implies_G_in_seed_positive`:
      G phi in M_t (t < 0) → G phi in unifiedSeed(n) for all n where dovetailIndex(n) > t
- [ ] Prove `unifiedChain_forward_G_cross_sign`:
      G phi in M_t (t < 0) → phi in M_{t'} (t' > 0)
- [ ] Symmetric: Prove `H_in_positive_implies_H_in_seed_negative`
- [ ] Prove `unifiedChain_backward_H_cross_sign`:
      H phi in M_t (t > 0) → phi in M_{t'} (t' < 0)
- [ ] Combine same-sign and cross-sign into full `forward_G` and `backward_H`

**Verification**:
- [ ] D1 (forward_G t < 0) eliminated
- [ ] D2 (backward_H t >= 0) eliminated
- [ ] `lake build` succeeds with 2 remaining sorries (D3, D4)

---

### Phase 5: F/P Witness Construction (8-10 hours) [NOT STARTED]

**Dependencies**: Phase 4
**Goal**: Resolve D3 and D4 sorries via dovetailing enumeration

**Note**: This phase is essentially unchanged from v002 Phase 3. The combined seed doesn't affect witness placement.

**Tasks**:
- [ ] Implement `Encodable Formula` instance (if not exists)
- [ ] Define `witnessEnumeration : Nat → Option (Int × Formula)`
- [ ] Prove enumeration completeness
- [ ] Modify `unifiedChainMCS` to include F-witness at appropriate step
- [ ] Modify `unifiedChainMCS` to include P-witness at appropriate step
- [ ] Prove `buildUnifiedChainFamily_forward_F`:
      F phi in M_t → ∃ s > t, phi in M_s
- [ ] Prove `buildUnifiedChainFamily_backward_P`:
      P phi in M_t → ∃ s < t, phi in M_s

**Verification**:
- [ ] D3 (forward_F) eliminated
- [ ] D4 (backward_P) eliminated
- [ ] `lake build` succeeds with 0 sorries in UnifiedChain.lean

---

### Phase 6: Final Theorem and Integration (2-3 hours) [NOT STARTED]

**Dependencies**: Phase 5
**Goal**: Complete the main theorem and verify integration

**Tasks**:
- [ ] Prove `temporal_coherent_family_exists_unified`:
      ∃ family, G/H/F/P-coherent for all time pairs
- [ ] Verify no sorries in transitive closure
- [ ] Update SORRY_REGISTRY.md
- [ ] Create implementation summary

**Verification**:
- [ ] `grep sorry UnifiedChain.lean` returns empty
- [ ] `lake build` succeeds with clean build
- [ ] Implementation summary created

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count decreases: 4 → 2 → 0
- [ ] Cross-sign propagation works (test: G phi at t=-1 reaches t=1)
- [ ] Same-sign propagation preserved (test: G phi at t=1 reaches t=2)
- [ ] F/P witnesses placed correctly
- [ ] Final theorem compiles without sorry

## Artifacts & Outputs

- `plans/implementation-003.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- New `Theories/Bimodal/Metalogic/Bundle/UnifiedChain.lean`
- Updated `docs/project-info/SORRY_REGISTRY.md`

## Rollback/Contingency

**Phase-level rollback**:
- Each phase committed separately
- If phase breaks invariants, revert to previous commit

**Decision point (after Phase 2)**:
- If `combined_seed_consistent` takes >15h or fundamental obstacle found
- Pivot to RecursiveSeed approach (research-005.md fallback)
- RecursiveSeed estimated 40-60h additional

**Full rollback**:
- If v003 fails completely, UnifiedChain.lean can be deleted
- DovetailingChain.lean preserved as reference with 4 documented sorries
- Accept technical debt if all approaches fail

## Comparison to Prior Versions

| Aspect | v001 (ZornFamily) | v002 (Two-Chain) | v003 (Unified Chain) |
|--------|-------------------|------------------|----------------------|
| Target | ZornFamily.lean | DovetailingChain.lean | NEW UnifiedChain.lean |
| Architecture | Zorn partial families | Separate forward/backward chains | Single unified chain |
| Cross-sign | Impossible (forward_F flaw) | Impossible (chain separation) | Built into construction |
| Sorries | 5 → BLOCKED | 4 → BLOCKED | 4 → 0 (target) |
| Effort | 29-45h (blocked) | 15-21h (blocked) | 29-43h (active) |

## Key Lemma: combined_seed_consistent

This is the critical theorem. Here's the expected proof structure:

```lean
theorem combined_seed_consistent (constructed : Nat → Option (Set Formula))
    (h_mcs : ∀ m, m < n → ∃ M, constructed m = some M ∧ SetMaximalConsistent M)
    (n : Nat) :
    SetConsistent (unifiedSeed constructed n) := by
  -- Case split: is the seed empty?
  by_cases h_empty : unifiedSeed constructed n = ∅
  · exact SetConsistent.empty
  -- Otherwise, find the "reference MCS" that contains the seed
  -- Key insight: All GContent elements come from MCSs that extend M_0
  -- All HContent elements come from MCSs that extend M_0
  -- So the combined seed is "rooted" in M_0's consistency
  sorry -- The actual proof requires careful construction order analysis
```

The proof will need to show that GContent from past times and HContent from future times are "compatible" because they both inherit from the shared base M_0.
