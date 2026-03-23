# Phase 5-6 Status Report: Task 29 - Reflexive G/H Semantics

**Date**: 2026-03-22
**Session**: sess_1774169883_0f6b7d
**Plan**: plans/02_reflexive-semantics-revised.md

## Overview

This report documents the current status of Phases 5 and 6 of Task 29. Both phases are marked as [BLOCKED] pending resolution of a fundamental mathematical challenge in the proof strategy.

## Phase Status Summary

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Enumeration and Pattern Catalog | COMPLETED |
| 1 | Core Semantic Change | COMPLETED |
| 2 | FMCS Structure Update | COMPLETED |
| 3 | Soundness Proof Repairs | COMPLETED |
| 4 | Truth Lemma Adjustment | COMPLETED |
| 5 | Axiom Removal and Downstream Repair | BLOCKED |
| 6 | Additional Axiom Conversion | BLOCKED |
| 7 | Frame Class Simplification | COMPLETED |
| 8 | Documentation and Final Verification | COMPLETED |

## The Blocking Issue

### Problem Statement

Under reflexive semantics, the canonical accessibility relation `CanonicalR` is reflexive:
- `CanonicalR M M` holds for all MCS M (proven via T-axiom: `G phi -> phi`)

The existing proofs for NoMaxOrder, NoMinOrder, and DenselyOrdered use irreflexivity:
```lean
-- Old pattern: derive contradiction from reflexive accessibility
have h_MM := canonicalR_transitive M N M h_mcs h_R h_R'
exact canonicalR_irreflexive M h_mcs h_MM  -- This is now FALSE
```

### Why Antisymmetry Alone is Insufficient

The plan proposes using antisymmetry: `CanonicalR M N AND CanonicalR N M -> M = N`

However, this theorem requires a non-trivial proof. The claim is that if `g_content(M) <= N` and `g_content(N) <= M`, then M = N. This is NOT immediately obvious and may require:
1. A Gabbay-style naming set argument adapted for distinctness
2. A blocking formula construction to establish witnesses are distinct
3. Potentially new mathematical infrastructure

### Affected Call Sites

25+ call sites in 11 active files depend on `canonicalR_irreflexive`:

| File | Sites | Complexity |
|------|-------|------------|
| DovetailedTimelineQuot.lean | 10 | High |
| SaturatedChain.lean | 8 | Medium |
| FMCSTransfer.lean | 2 | High (requires redesign) |
| CanonicalSerialFrameInstance.lean | 2 | Medium |
| ClosureSaturation.lean | 2 | Low |
| TimelineQuotCanonical.lean | 1 | Low |
| IncrementalTimeline.lean | 1 | Low |

### Frame Class Collapse

Under reflexive semantics, the following properties collapse:
- NoMaxOrder: F(phi) is witnessed by the present (reflexively)
- NoMinOrder: P(phi) is witnessed by the present (reflexively)
- DenselyOrdered: Intermediate points become trivial

This is documented in the theoretical analysis as the "frame class collapse" - a feature for proof simplification but requiring careful handling of existing proofs that assume strict ordering.

## Current System State

### Build Status
- Full `lake build` passes (1044 jobs)
- No new sorries introduced by this task
- Existing sorries are pre-existing and semantics-independent

### Axiom Count (10 axioms)
1. `canonicalR_irreflexive_axiom` - DEPRECATED (semantically FALSE, retained temporarily)
2. `discreteImmediateSuccSeed_consistent_axiom` - Unchanged
3. `discreteImmediateSucc_covers_axiom` - Unchanged
4. `discrete_Icc_finite_axiom` - Unchanged (2 locations)
5. `succ_chain_fam_p_step` - Unchanged
6. `f_nesting_boundary` - Unchanged
7. `p_nesting_boundary` - Unchanged
8. `successor_deferral_seed_consistent_axiom` - Unchanged
9. `predecessor_deferral_seed_consistent_axiom` - Unchanged
10. `predecessor_f_step_axiom` - Unchanged

### New Theorems Added (Phases 1-4)
- `canonicalR_reflexive` - Proven (via T-axiom)
- `canonicalR_past_reflexive` - Proven (via T-axiom)
- `temp_t_future` / `temp_t_past` - T-axiom constructors in proof system

### System Inconsistency

The current system has a logical inconsistency:
- `canonicalR_reflexive` proves `CanonicalR M M` (TRUE)
- `canonicalR_irreflexive_axiom` asserts `NOT CanonicalR M M` (FALSE)

This inconsistency is contained by the deprecated warning and the axiom not being used in the primary completeness paths.

## Recommended Next Steps

### Option A: Full Axiom Removal (5+ hours)

1. Prove `canonicalR_antisymmetric` using Gabbay naming set adaptation
2. Add distinctness witnesses to seriality/density constructions
3. Rewrite all 25+ call sites to use antisymmetry + distinctness
4. Remove `canonicalR_irreflexive_axiom`

### Option B: Axiom Deprecation with Documentation (Completed)

1. Keep axiom with deprecation warning (DONE)
2. Document inconsistency in code comments (DONE)
3. Ensure primary completeness paths don't use deprecated axiom
4. Create follow-up task for full removal when resources available

### Option C: Alternative Proof Architecture

1. Accept frame class collapse as feature
2. Remove NoMaxOrder/NoMinOrder/DenselyOrdered requirements where possible
3. Simplify completeness proofs to not require these properties
4. This may involve significant restructuring of DovetailedTimelineQuot

## Phase 6 Assessment

Phase 6 (`discreteImmediateSuccSeed_consistent_axiom` proof) depends on:
- Understanding how T-axiom simplifies Case 2 in the seed consistency proof
- The blocking formula construction being well-understood

Without completing Phase 5's antisymmetry infrastructure, Phase 6 cannot proceed reliably.

## Verification Results

```
lake build: PASSED (1044 jobs)
New sorries: 0
Axiom count: 10 (unchanged from pre-task)
Deprecated axiom usage: 25+ sites (documented)
```

## Conclusion

Phases 5 and 6 are blocked on a mathematical challenge: proving `canonicalR_antisymmetric` in a way that enables replacement of all irreflexivity-based proofs. The current implementation takes Option B (deprecation with documentation), leaving the system in a working but mathematically inconsistent state. A follow-up task should be created to complete the axiom removal when the proof strategy is fully worked out.
