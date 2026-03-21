# Research Report: Task #956 Comprehensive Audit

**Task**: 956 - construct_d_as_translation_group_from_syntax
**Session**: sess_1773626222_17156
**Date**: 2026-03-15
**Effort**: Research audit
**Sources/Inputs**:
- Full codebase scan of Theories/Bimodal/Metalogic/
- Task 961 research-008.md findings
- Implementation plan v024
- Build verification (lake build)
**Artifacts**: This report at specs/956_construct_d_as_translation_group_from_syntax/reports/research-049.md
**Standards**: report-format.md, proof-debt-policy.md

## Executive Summary

**Major Finding**: The Task 961 blocker has been RESOLVED. CantorApplication.lean now has ZERO sorries, having been fully proven via Task 967's T-axiom irreflexivity approach. The implementation plan v024 is OUT OF DATE.

**Sorry Inventory (Active Metalogic)**:
- **Total sorries in active Metalogic files**: 12
- **Dense completeness path (StagedConstruction/)**: 0 sorries
- **Int-based completeness path (Bundle/DovetailingChain, TemporalCoherentConstruction)**: 4 sorries
- **Discrete timeline path (Domain/DiscreteTimeline)**: 5 sorries
- **Constructive fragment (Canonical/ConstructiveFragment)**: 2 sorries
- **Axioms**: 0 new axioms in active code

**Build Status**: Clean (743 jobs, 0 errors, only linter warnings)

## Detailed Sorry Inventory

### 1. StagedConstruction/ Directory - ZERO SORRIES (CLEAN)

| File | Lines | Status |
|------|-------|--------|
| CantorApplication.lean | 246 | 0 sorries |
| DenseTimeline.lean | - | 0 sorries |
| DensityFrameCondition.lean | ~278 | 0 sorries |
| CantorPrereqs.lean | - | 0 sorries |
| SeparationLemma.lean | - | 0 sorries |
| StagedExecution.lean | - | 0 sorries |
| StagedTimeline.lean | - | 0 sorries |
| WitnessSeedWrapper.lean | - | 0 sorries |

**Key Achievement**: The dense completeness pipeline from consistent set to `cantor_iso : Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat)` is FULLY PROVEN.

**How CantorApplication.lean was proven**:
- `NoMaxOrder`: Uses `dense_timeline_has_future` + `canonicalR_strict` from irreflexivity
- `NoMinOrder`: Uses `dense_timeline_has_past` + `canonicalR_strict` from irreflexivity
- `DenselyOrdered`: Uses `dense_timeline_has_intermediate` + `canonicalR_strict` for both endpoints

The Task 967 T-axiom approach provides `canonicalR_irreflexive` as a THEOREM (not axiom), which then yields `canonicalR_strict`: if `CanonicalR M N`, then `NOT CanonicalR N M`.

### 2. Bundle/CanonicalIrreflexivity.lean - ZERO SORRIES (PROVEN)

The core theorem enabling the dense pipeline:
```lean
theorem canonicalR_irreflexive :
  forall (M : Set Formula), SetMaximalConsistent M -> NOT CanonicalR M M
```

This is FULLY PROVEN using the Gabbay IRR technique with the T-axiom for past.

### 3. Bundle/DovetailingChain.lean - 2 SORRIES

| Line | Theorem | Status |
|------|---------|--------|
| 1893 | `buildDovetailingChainFamily_forward_F` | Sorry (F-witness construction) |
| 1905 | `buildDovetailingChainFamily_backward_P` | Sorry (P-witness construction) |

**Analysis**: These sorries are in the Int-chain approach which is DEPRECATED. The documentation states:
> "DovetailingChain is being archived (incompatible with irreflexive semantics). The density completeness path uses CanonicalMCS, not Int chains."

**Impact**: None for Task 956. The dense completeness path (StagedConstruction/) does not use DovetailingChain.

### 4. Bundle/TemporalCoherentConstruction.lean - 2 SORRIES

| Line | Theorem | Status |
|------|---------|--------|
| 422 | `temporal_coherent_family_exists_Int` | Sorry |
| 516 | `fully_saturated_bfmcs_exists_int` | Sorry |

**Analysis**: These are Int-specialized versions for the deprecated Int-chain approach. File header states:
> "DEPRECATED (2026-03-11): Int-specialized construction, violates pure-syntax constraint"

**Impact**: None for Task 956. This file should be archived or removed.

### 5. Domain/DiscreteTimeline.lean - 5 SORRIES

| Line | Instance/Theorem | Status |
|------|------------------|--------|
| 179 | `SuccOrder.le_succ` | Sorry |
| 187 | `SuccOrder.max_of_succ_le` | Sorry |
| 200 | `SuccOrder.succ_le_of_lt` | Sorry (KEY - coverness from DF) |
| 218 | `PredOrder.le_pred_of_lt` | Sorry |
| 231 | `IsSuccArchimedean.exists_succ_iterate_of_le` | Sorry |

**Analysis**: The discrete timeline is NOT on the Task 956 critical path. Task 956 constructs D via the DENSE pipeline (Cantor isomorphism to Q), not the discrete pipeline (orderIsoIntOfLinearSuccPredArch to Z).

**Impact**: None for Task 956 dense completion. These would be needed for a separate discrete-axiom completeness proof.

### 6. Canonical/ConstructiveFragment.lean - 2 SORRIES

| Line | Instance | Status |
|------|----------|--------|
| 579 | `NoMaxOrder` for ConstructiveQuotient | Sorry |
| 584 | `NoMinOrder` for ConstructiveQuotient | Sorry |

**Analysis**: ConstructiveFragment.lean is an experimental constructive approach. The file uses a different construction (`ConstructiveQuotient` vs `TimelineQuot`) that predates the T-axiom solution.

**Impact**: None for Task 956. This is an alternative/experimental path.

## What is PROVEN (Summary)

### Dense Completeness Pipeline (Task 956 Primary Path)
1. `density_frame_condition` - PROVEN (non-strict density witness)
2. `canonicalR_irreflexive` - PROVEN (via T-axiom, Task 967)
3. `canonicalR_strict` - PROVEN (consequence of irreflexivity + T4 transitivity)
4. `dense_timeline_has_intermediate` - PROVEN (gives non-strict intermediate)
5. `NoMaxOrder` on TimelineQuot - PROVEN
6. `NoMinOrder` on TimelineQuot - PROVEN
7. `DenselyOrdered` on TimelineQuot - PROVEN
8. `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` - PROVEN

### Supporting Infrastructure
- `Countable TimelineQuot` - PROVEN
- `LinearOrder TimelineQuot` - PROVEN (via Antisymmetrization)
- All MCS properties - PROVEN
- All seed constructions - PROVEN

## Technical Debt and Cruft

### Files to Archive (Boneyard Candidates)

1. **Bundle/DovetailingChain.lean** (~1930 lines)
   - Status: DEPRECATED, 2 sorries
   - Reason: Int-chain approach incompatible with pure-syntax constraint
   - Contains attempted F/P witness construction that fails due to F-persistence gap
   - Recommendation: Archive to Boneyard, remove from build

2. **Bundle/TemporalCoherentConstruction.lean** (~575 lines)
   - Status: DEPRECATED, 2 sorries
   - Reason: Int-specialized, violates pure-syntax constraint
   - Header explicitly states "DO NOT USE for new development"
   - Recommendation: Archive to Boneyard, remove from build

3. **Domain/DiscreteTimeline.lean** (~315 lines)
   - Status: 5 sorries, blocks discrete completeness path
   - Reason: SuccOrder/PredOrder instances require coverness from DF
   - Recommendation: Keep if discrete completeness is desired; otherwise archive

4. **Canonical/ConstructiveFragment.lean** (~590 lines)
   - Status: 2 sorries, experimental alternative path
   - Reason: Predates T-axiom solution
   - Recommendation: Archive or mark clearly as experimental

### Obsolete Documentation

The implementation plan v024 (implementation-024.md) is OUT OF DATE:
- Lists 6 sorries in CantorApplication.lean at lines 210, 269, 332, 345, 380, 385
- Actual state: CantorApplication.lean has 0 sorries (246 lines)
- Phase 7 status should be COMPLETED, not PARTIAL
- Phase 8 (QuotientDensity) is NOT NEEDED

### Task 961 Status

Per research-008.md:
- Task 961 is OBSOLETE
- Goal (NoMaxOrder, NoMinOrder, DenselyOrdered for TimelineQuot) was achieved via Task 967
- The iteration-based approach described in Task 961 is NOT NEEDED
- Recommendation: Mark Task 961 as [OBSOLETE] or [ABANDONED] with note "resolved by Task 967"

## Dependency Status

| Task | Title | Status | Impact on 956 |
|------|-------|--------|---------------|
| 951 | BFMCS infrastructure | COMPLETE | Pre-requisite satisfied |
| 957 | Density frame condition | COMPLETE | Pre-requisite satisfied |
| 961 | Quotient density iteration | OBSOLETE | Goal achieved via Task 967 |
| 967 | T-axiom irreflexivity | COMPLETE | CRITICAL - enables strictness |
| 968 | Shift-closure canonical bridge | COMPLETE | Supporting infrastructure |

## Remaining Work for Publication-Ready Metalogic

### Immediate Actions (Task 956 Completion)

1. **Update implementation plan** - Create v025 reflecting actual state
2. **Update Task 961 status** - Mark [OBSOLETE]
3. **Implement remaining phases**:
   - Phase 9: DFromCantor.lean (D := Q via cantor_iso)
   - Phase 10: TaskFrame + Completeness connection

### Recommended Archival Actions

1. Archive DovetailingChain.lean to `Boneyard/Metalogic_v8/Bundle/`
2. Archive TemporalCoherentConstruction.lean to `Boneyard/Metalogic_v8/Bundle/`
3. Archive ConstructiveFragment.lean to `Boneyard/Metalogic_v8/Canonical/`
4. Keep DiscreteTimeline.lean if discrete completeness is planned; else archive

### Post-Archival State

After archival:
- **Sorries in active Metalogic**: 0
- **Build status**: Clean
- **Dense completeness path**: FULLY PROVEN

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plan v024 used by implementer | M | L | Create v025 immediately |
| Task 961 re-attempted | L | L | Update TODO.md with OBSOLETE status |
| Archival breaks imports | H | M | Verify no active files import deprecated modules |

## Decisions

1. **Architecture**: The dense completeness path via StagedConstruction is COMPLETE and PROVEN. The Int-chain approaches (DovetailingChain, TemporalCoherentConstruction) should be archived.

2. **Priority**: Create DFromCantor.lean to complete Task 956 Phases 9-10.

3. **Dependencies**: Task 961 dependency is RESOLVED (not blocking).

## Appendix: File-by-File Sorry Count

### Active Files with Sorries (Metalogic/)

| Path | Sorries | Status |
|------|---------|--------|
| Bundle/DovetailingChain.lean | 2 | DEPRECATED |
| Bundle/TemporalCoherentConstruction.lean | 2 | DEPRECATED |
| Domain/DiscreteTimeline.lean | 5 | Blocks discrete path only |
| Canonical/ConstructiveFragment.lean | 2 | Experimental |
| StagedConstruction/* | 0 | CLEAN |
| Bundle/CanonicalIrreflexivity.lean | 0 | PROVEN |
| Bundle/TruthLemma.lean | 0 | PROVEN |
| Bundle/CanonicalConstruction.lean | 0 | PROVEN |

### Files Outside Metalogic with Sorries (Examples)

| Path | Sorries | Status |
|------|---------|--------|
| Examples/ModalProofs.lean | 5 | Demo exercises |
| Examples/ModalProofStrategies.lean | 5 | Demo exercises |
| Examples/TemporalProofs.lean | 2 | Demo exercises |

These are intentional `sorry`s for users to fill in as exercises.

## Summary

**The Task 956 dense completeness path is FULLY PROVEN**. The blockers identified in earlier research (Task 961, quotient strictness gap, reflexive MCS obstacle) have all been RESOLVED via Task 967's T-axiom approach.

**Remaining work**:
1. Create DFromCantor.lean (D := Q)
2. Create or update TaskFrame/Completeness connection
3. Archive deprecated files
4. Update plan documentation

**Sorries in publication path**: 0

**Axioms in publication path**: 0 (standard Lean + Mathlib only)
