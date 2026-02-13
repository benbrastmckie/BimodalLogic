# Implementation Plan: Task #880 (v002) - DovetailingChain Completion

**Task**: 880 - Augmented Extension Seed Approach → DovetailingChain Pivot
**Version**: 002
**Created**: 2026-02-12
**Language**: lean
**Status**: [NOT STARTED]
**Estimated Effort**: 15-21 hours
**Research Input**: research-004.md (team research recommending pivot)

## Overview

This plan pivots from the ZornFamily approach (Phases 5-6 blocked by controlled Lindenbaum complexity) to completing DovetailingChain.lean. The team research (research-004.md) unanimously recommended this pivot based on:

1. **ZornFamily theorem-level flaws**: `maximal_implies_total` may be false; universal `forward_F` incompatible with domain extension
2. **DovetailingChain has clear path**: 15-21 hours of well-understood engineering work
3. **Shared foundation**: Both approaches use the proven `temporal_witness_seed_consistent` lemma

### Strategic Rationale

| Metric | ZornFamily (Phases 5-6) | DovetailingChain |
|--------|-------------------------|------------------|
| Estimated effort | 29-45 hours | **15-21 hours** |
| Risk level | High | **Low-Medium** |
| Blocking issues | Theorem-level flaws | **None** |
| Path clarity | Requires redesign | **Clear** |

### Work Preserved from v001

- Phases 1-4 completed: ZornFamily cleanup (deleted false lemmas, removed F/P fields, simplified seed)
- Cross-sign seed consistency insight: transferable conceptually to DovetailingChain
- Single-witness approach validation: `temporal_witness_seed_consistent` is correct granularity

## Goals & Non-Goals

**Goals**:
- Resolve all 4 sorry sites in DovetailingChain.lean
- Achieve zero-sorry temporal coherent family construction
- Establish `temporal_coherent_family_exists_theorem` without axiom dependency

**Non-Goals**:
- Further work on ZornFamily.lean (preserved as-is with documented technical debt)
- Optimizing proof performance (correctness first)
- Refactoring beyond what's needed for sorry elimination

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-sign lemma harder than expected | MEDIUM | LOW | Well-understood via shared-base argument |
| Encodable Formula instance missing | LOW | LOW | Straightforward to implement if needed |
| Dovetailing enumeration complexity | MEDIUM | LOW | Nat.pair/unpair is standard Mathlib pattern |
| Witness placement order issues | MEDIUM | MEDIUM | Careful induction on construction step |

## Sorry Characterization

### Target Sorries (DovetailingChain.lean)

| ID | Line | Name | Category | Resolution Strategy |
|----|------|------|----------|---------------------|
| D1 | 606 | forward_G (t < 0) | Cross-sign | Global propagation via shared M_0 |
| D2 | 617 | backward_H (t >= 0) | Cross-sign | Symmetric to D1 |
| D3 | 633 | forward_F | Witness construction | Dovetailing enumeration |
| D4 | 640 | backward_P | Witness construction | Symmetric to D3 |

### Expected Resolution

| Phase | Sorries | Approach |
|-------|---------|----------|
| Phase 1 | D1, D2 | Global cross-sign propagation lemma |
| Phase 2 | (infrastructure) | Dovetailing enumeration |
| Phase 3 | D3, D4 | F/P witness proofs |

### Remaining Debt

After full implementation:
- 0 sorries in DovetailingChain.lean
- 5 sorries remain in ZornFamily.lean (documented technical debt)
- `temporal_coherent_family_exists_theorem` proven without axiom dependency

## Implementation Phases

### Phase 1: Global Cross-Sign Propagation (6-8 hours) [NOT STARTED]

**Dependencies**: None
**Goal**: Prove forward_G and backward_H across the time-zero boundary

**Key Insight**: Both forward and backward chains share M_0 as their base MCS. This enables:
- G phi in M_t (t < 0) → G phi in M_0 → phi in M_{t'} (t' > 0)
- H phi in M_t (t > 0) → H phi in M_0 → phi in M_{t'} (t' < 0)

**Tasks**:
- [ ] Create lemma: `G_backward_to_base` - G phi in backward chain implies G phi in M_0
- [ ] Create lemma: `G_base_to_forward` - G phi in M_0 implies phi in forward chain
- [ ] Prove `forward_G` for t < 0 case (D1) using composition
- [ ] Create symmetric lemmas for H: `H_forward_to_base`, `H_base_to_backward`
- [ ] Prove `backward_H` for t >= 0 case (D2) using composition

**Verification**:
- [ ] `lake build` succeeds
- [ ] D1, D2 sorry sites eliminated
- [ ] 2 sorries remain (D3, D4)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

---

### Phase 2: Dovetailing Enumeration Infrastructure (4-5 hours) [NOT STARTED]

**Dependencies**: None (can run in parallel with Phase 1)
**Goal**: Implement infrastructure for F/P witness enumeration

**Key Components**:
1. **Encodable Formula**: Instance for encoding formulas as Nat (may already exist via Countable)
2. **Witness enumeration**: Function mapping construction step to (time, formula) pair
3. **Completeness lemma**: Every F/P obligation is eventually enumerated

**Tasks**:
- [ ] Verify/create `Encodable Formula` instance
- [ ] Define `witnessEnumeration : Nat → Option (Int × Formula)`
- [ ] Prove enumeration completeness: `∀ t φ, F φ ∈ M_t → ∃ n, witnessEnumeration n = some (t, φ)`
- [ ] Define `shouldIncludeWitness : Nat → Int → Formula → Bool` for seed construction
- [ ] Prove witness inclusion correctness

**Verification**:
- [ ] `lake build` succeeds
- [ ] Enumeration lemmas compile
- [ ] No new sorries introduced

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

---

### Phase 3: F/P Witness Proofs (6-8 hours) [NOT STARTED]

**Dependencies**: Phase 1, Phase 2
**Goal**: Prove forward_F and backward_P using witness enumeration

**Strategy**:
1. Modify seed construction to include witnesses at appropriate steps
2. Use `temporal_witness_seed_consistent` for single-witness consistency
3. Prove that every F/P obligation is eventually witnessed

**Tasks**:
- [ ] Modify `dovetailForwardChainMCS` to optionally include F-witness in seed
- [ ] Modify `dovetailBackwardChainMCS` to optionally include P-witness in seed
- [ ] Prove `buildDovetailingChainFamily_forward_F` (D3):
  - Given F φ ∈ M_t, find step n where witness is included
  - Show φ ∈ M_s for s = dovetailIndex(n)
  - Prove t < s (witness is in future)
- [ ] Prove `buildDovetailingChainFamily_backward_P` (D4) symmetrically
- [ ] Verify `temporal_coherent_family_exists_theorem` compiles without sorry

**Verification**:
- [ ] `lake build` succeeds
- [ ] D3, D4 sorry sites eliminated
- [ ] DovetailingChain.lean has 0 sorries
- [ ] `temporal_coherent_family_exists_theorem` proven

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

---

### Phase 4: Verification and Documentation (1-2 hours) [NOT STARTED]

**Dependencies**: Phases 1-3
**Goal**: Verify complete sorry elimination and document results

**Tasks**:
- [ ] Run full `lake build` to verify clean build
- [ ] Verify `temporal_coherent_family_exists_theorem` is sorry-free
- [ ] Check transitive dependencies are sorry-free
- [ ] Update SORRY_REGISTRY.md to reflect elimination
- [ ] Create implementation summary

**Verification**:
- [ ] `lake build` succeeds with 0 errors
- [ ] `grep sorry DovetailingChain.lean` returns empty
- [ ] Implementation summary created

**Files to modify**:
- `docs/project-info/SORRY_REGISTRY.md`
- `specs/880_augmented_extension_seed_approach/summaries/implementation-summary-YYYYMMDD.md` (create)

## Evidence (From Research)

### Proven Infrastructure Available

| Lemma | Location | Purpose |
|-------|----------|---------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | F-witness seed is consistent |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | P-witness seed is consistent |
| `dovetail_GContent_consistent` | DovetailingChain.lean | GContent of MCS is consistent |
| `dovetail_HContent_consistent` | DovetailingChain.lean | HContent of MCS is consistent |
| `dovetailForwardChain_G_propagates` | DovetailingChain.lean | G propagates along forward chain |
| `dovetailBackwardChain_H_propagates` | DovetailingChain.lean | H propagates along backward chain |
| `chains_share_base` | DovetailingChain.lean | Forward and backward chains share M_0 |
| `set_lindenbaum` | MaximalConsistent.lean | Lindenbaum extension exists |

### Missing (To Be Implemented)

| Component | Phase | Effort |
|-----------|-------|--------|
| Global cross-sign propagation lemma | 1 | 6-8h |
| Encodable Formula instance | 2 | 1h (if needed) |
| Witness enumeration function | 2 | 2-3h |
| Enumeration completeness proof | 2 | 1-2h |
| Modified seed construction | 3 | 2-3h |
| F/P witness existence proofs | 3 | 4-5h |

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Sorry count decreases: 4 → 2 → 0
- [ ] No new sorries introduced
- [ ] All modified theorems type-check correctly
- [ ] `temporal_coherent_family_exists_theorem` compiles without sorry
- [ ] Downstream dependent theorems still compile

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Updated `docs/project-info/SORRY_REGISTRY.md`

## Rollback/Contingency

**Phase-level rollback**:
- Each phase committed separately; revert to previous commit if phase breaks invariants
- Phases 1 and 2 can be developed in parallel branches

**Full rollback**:
- If approach fundamentally fails, DovetailingChain.lean remains with documented 4 sorries
- ZornFamily.lean preserved as alternative (though with known theorem-level issues)
- All sorries remain as technical debt with clear remediation documentation

**Success criteria for continuation**:
- If any phase takes >2x estimated time, evaluate whether to continue or document as debt
- Phase 3 is the critical path - if blocked, consider accepting D3/D4 as documented debt

## Comparison to v001

| Aspect | v001 (ZornFamily) | v002 (DovetailingChain) |
|--------|-------------------|-------------------------|
| Target file | ZornFamily.lean | DovetailingChain.lean |
| Starting sorries | 12 → 5 (after v001 Phases 1-4) | 4 |
| Estimated effort | 29-45h remaining | 15-21h |
| Risk level | High | Low-Medium |
| Key blocker | Controlled Lindenbaum | None |

**Decision rationale**: Team research (research-004.md) identified that ZornFamily has theorem-level flaws (`maximal_implies_total` may be false), while DovetailingChain has a clear path with no blocking issues.
