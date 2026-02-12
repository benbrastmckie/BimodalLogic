# Teammate A: Current State Analysis

**Task**: 870 - Zorn-based family selection for temporal coherence
**File**: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
**Date**: 2026-02-11
**Analyst**: lean-research-agent (teammate-a)

## Executive Summary

ZornFamily.lean contains **12 sorries** across three implementation phases (3, 5, and 6). The file has substantial completed infrastructure (Phases 1, 2, 4) but the remaining sorries form a dependency chain that blocks the main theorem.

## Sorry Inventory

### Phase 3: Extension Seed Consistency (4 sorries)

| Line | Context | Type | Immediate Blockers |
|------|---------|------|-------------------|
| **650** | `multi_witness_seed_consistent_future` | Multi-formula deduction | Infrastructure for conjunction of negations |
| **680** | `multi_witness_seed_consistent_past` | Multi-formula deduction | Symmetric to line 650 |
| **694** | `extensionSeed_consistent` (cross-sign case) | G/H content compatibility | 4-axiom propagation proof |
| **926** | `extensionSeed_consistent` (F-obligations case) | GContent + FObligations consistency | `multi_witness_seed_consistent_future` (line 650) |

### Phase 5: Maximality Implies Totality (2 sorries)

| Line | Context | Type | Immediate Blockers |
|------|---------|------|-------------------|
| **1311** | `extendFamily.forward_G` | Extension propagation | Seed -> MCS tracing for G content |
| **1342** | `extendFamily.backward_H` | Extension propagation | Seed -> MCS tracing for H content |

### Phase 6: F/P Recovery (4 sorries)

| Line | Context | Type | Immediate Blockers |
|------|---------|------|-------------------|
| **1477** | `maximal_family_forward_F` | F witness existence | Phases 3, 5 completion |
| **1486** | `total_family_forward_F` | Compatibility alias | `maximal_family_forward_F` |
| **1522** | `maximal_family_backward_P` | P witness existence | Phases 3, 5 completion |
| **1530** | `total_family_backward_P` | Compatibility alias | `maximal_family_backward_P` |

### Blocked Tool Note

Line 1066 comment references `multi_witness_seed_consistent_past (line 680)` as a blocker. This accurately reflects the dependency structure.

## Progress Summary

### Completed Infrastructure (Phases 1, 2, 4)

**Phase 1 - Structure Restructuring** (Lines 96-220):
- `GHCoherentPartialFamily` structure with G/H-only coherence
- `Preorder` instance for Mathlib Zorn integration
- Partial order proofs: `le_refl`, `le_trans`, `le_antisymm_domain`

**Phase 2 - Base Family** (Lines 1182-1223):
- `buildBaseFamily` with singleton domain {0}
- Vacuous G/H coherence (no pairs t < t' in {0})
- Context preservation at time 0 via Lindenbaum extension

**Phase 4 - Zorn Application** (Lines 1077-1156):
- `chainUpperBound` construction with full proof
- `coherent_chain_has_upper_bound` theorem
- `zorn_maximal_exists` using `zorn_le_nonempty_0`
- `maximalCoherentFamily` extraction

### Partial Infrastructure

**Seed Construction** (Lines 384-456):
- `extensionSeed` definition complete
- `FObligations` and `PObligations` collectors
- Helper lemmas for seed membership (4 lemmas, all proven)

**Content Propagation** (Lines 461-532):
- `GContent_consistent` proven
- `HContent_consistent` proven
- `GContent_propagates_forward` using 4-axiom (proven)
- `HContent_propagates_backward` using 4-axiom (proven)

**Pure Past/Future Cases** (Lines 696-1045):
- Pure past case: All GContent elements proven to propagate to maximum source time
- Pure future case: All HContent elements proven to propagate to minimum source time
- Complex induction on List structure for finding max/min time

## Critical Path Analysis

### Dependency Graph

```
         Phase 3 Root Sorries
              |
    +---------+---------+
    |                   |
  Line 650           Line 694
  (multi-F)          (cross-sign)
    |                   |
    v                   |
  Line 680              |
  (multi-P)             |
    |                   |
    +-----+   +---------+
          |   |
          v   v
        Line 926
    (F-obligations case)
             |
             v
      extensionSeed_consistent
             |
      +------+------+
      |             |
      v             v
   Line 1311     Line 1342
  (forward_G)   (backward_H)
      |             |
      +------+------+
             |
             v
      maximal_implies_total
             |
      +------+------+
      |             |
      v             v
   Line 1477     Line 1522
  (forward_F)   (backward_P)
      |             |
      v             v
   Line 1486     Line 1530
  (alias F)     (alias P)
```

### Critical Sorry: Line 650 (multi_witness_seed_consistent_future)

This is the **root blocker** for the entire construction.

**Why it's critical**:
1. Directly blocks line 926 (F-obligations case)
2. Indirectly blocks all Phase 5 and Phase 6 sorries
3. Requires non-trivial derivation manipulation infrastructure

**Proof Strategy (documented in code)**:
- Given L subset of {psi_1, ..., psi_n} union GContent(M) with L proves bottom
- Partition L into L_psis and L_G
- Apply deduction theorem to get L_G proves disjunction of negations
- Apply generalized temporal necessitation
- Derive contradiction from MCS properties

**Key Missing Infrastructure**:
- Multi-formula deduction theorem application
- G distribution over disjunction (or alternative approach)
- Derivation manipulation for conjunction of F-witnesses

### Secondary Critical: Line 694 (cross-sign case)

**Why it matters**:
- Covers the case where both past and future times exist in domain
- Must show GContent from past times compatible with HContent from future times

**Proof Strategy Hint**:
Code comment says "Cross-sign consistency: requires 4-axiom propagation"
The 4-axiom lemmas (`set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`) already exist and are used in `GContent_propagates_forward` and `HContent_propagates_backward`.

## Recommendations

### Priority 1: Multi-Witness Consistency Infrastructure

Focus on lines 650 and 680. These require:
1. Lemma for derivation from conjunction of witnesses
2. Possibly leverage existing `temporal_witness_seed_consistent` (single-witness version) from TemporalLindenbaum.lean
3. Induction on list length with careful handling of MCS properties

### Priority 2: Cross-Sign Seed Consistency (Line 694)

After Priority 1, tackle the cross-sign case:
1. Use 4-axiom to show GContent from all past times contained in GContent at maximum past time
2. Use 4-axiom to show HContent from all future times contained in HContent at minimum future time
3. Show these two "boundary" contents are consistent with each other

### Priority 3: Extension Propagation (Lines 1311, 1342)

These may become simpler once seed consistency is proven:
- Need to trace how G/H content in mcs_t relates to original family
- Key insight: seed subset mcs_t, so seed membership implies mcs_t membership

### Priority 4: F/P Recovery (Lines 1477, 1522)

These should fall out naturally once Phases 3 and 5 are complete:
- Construction guarantees F-obligations in seed
- Seed subset mcs implies witness exists by construction

## Technical Debt Characterization

Following proof-debt-policy.md standards:

| Sorry | Category | Remediation Path |
|-------|----------|------------------|
| Line 650 | Core infrastructure | Multi-formula deduction infrastructure |
| Line 680 | Core infrastructure | Symmetric to 650 |
| Line 694 | Proof gap | 4-axiom application to cross-sign case |
| Line 926 | Blocked | Unblock via 650 completion |
| Line 1066 | Blocked | Unblock via 680 completion |
| Line 1311 | Construction detail | Seed-MCS tracing |
| Line 1342 | Construction detail | Seed-MCS tracing |
| Line 1477 | Blocked | Unblock via Phases 3, 5 |
| Line 1486 | Compatibility | Auto-resolves with 1477 |
| Line 1522 | Blocked | Unblock via Phases 3, 5 |
| Line 1530 | Compatibility | Auto-resolves with 1522 |

## File Statistics

- Total lines: 1589
- Total sorries: 12
- Completed proofs: ~40 lemmas/theorems
- Phase completion: 1 (done), 2 (done), 3 (partial), 4 (done), 5 (partial), 6 (partial)

## References

- Implementation Plan: `specs/870_zorn_family_temporal_coherence/plans/implementation-002.md`
- Research Reports: `research-001.md`, `research-002.md`, `research-003.md`
- Related File: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (single-witness version)
