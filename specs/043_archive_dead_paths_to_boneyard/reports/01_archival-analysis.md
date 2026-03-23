# Task 43: Archival Analysis for Dead Paths

## Executive Summary

The StagedConstruction directory and related modules contain 3 axioms and 44+ sorries, all superseded by the SuccChain completeness approach. Archiving these dead paths will eliminate axioms 7-9 from the project's debt.

## Target Files for Archival

### 1. StagedConstruction Directory (29 files)

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/`

**Files** (all to be moved to Boneyard):
- CantorApplication.lean
- CantorPrereqs.lean
- CanonicalRecovery.lean
- ClosureSaturation.lean
- Completeness.lean
- DenseTaskRelation.lean
- DenseTimeline.lean
- DensityFrameCondition.lean
- DiscreteSuccSeed.lean
- DovetailedBuild.lean
- DovetailedCompleteness.lean
- DovetailedCoverage.lean
- DovetailedCoverageReach.lean
- DovetailedFMCS.lean
- DovetailedTimelineQuot.lean
- DovetailedTimelineQuotBFMCS.lean
- Dovetailing.lean
- DFromCantor.lean
- ImmediateStagedBuild.lean
- IncrementalTimeline.lean
- SeparationLemma.lean
- StagedExecution.lean
- StagedTimeline.lean
- TimelineQuotAlgebra.lean
- TimelineQuotBFMCS.lean
- TimelineQuotCanonical.lean
- TimelineQuotCompleteness.lean
- WitnessChainFMCS.lean
- WitnessSeedWrapper.lean

### 2. Domain Files (2 files)

| File | Location | Notes |
|------|----------|-------|
| DiscreteTimeline.lean | `Domain/` | Contains `discrete_Icc_finite_axiom` |
| DurationTransfer.lean | `Domain/` | W=D conflation (deprecated construction) |

### 3. Canonical Files (1 file)

| File | Location | Notes |
|------|----------|-------|
| CanonicalTimeline.lean | `Canonical/` | Contains 1 sorry |

## Axioms to be Eliminated

| # | Axiom Name | Location | Line |
|---|------------|----------|------|
| 7 | `discrete_Icc_finite_axiom` | DiscreteTimeline.lean | 319 |
| 8 | `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean | 300 |
| 9 | `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean | 430 |

### Axiom Details

**discrete_Icc_finite_axiom** (DiscreteTimeline.lean:319):
```lean
axiom discrete_Icc_finite_axiom :
    forall (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```
Used to establish LocallyFiniteOrder for the discrete timeline. Blocked by task 979.

**discreteImmediateSuccSeed_consistent_axiom** (DiscreteSuccSeed.lean:300):
```lean
axiom discreteImmediateSuccSeed_consistent_axiom (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M)
```
Semantic property justified by seriality argument but not provable in current system.

**discreteImmediateSucc_covers_axiom** (DiscreteSuccSeed.lean:430):
```lean
axiom discreteImmediateSucc_covers_axiom
    (M K : Set Formula) (h_M : SetMaximalConsistent M) (h_K : SetMaximalConsistent K)
    (h_MK : CanonicalR M K) (h_KW : CanonicalR K (discreteImmediateSucc M h_M)) :
    K = M \/ K = discreteImmediateSucc M h_M
```
Covering property for discrete immediate successor construction.

## Sorry Count by File

| File | Sorry Count |
|------|-------------|
| ClosureSaturation.lean | 12 |
| DovetailedTimelineQuot.lean | 8 |
| DovetailedCoverageReach.lean | 8 |
| CanonicalRecovery.lean | 5 |
| DovetailedCompleteness.lean | 3 |
| Completeness.lean | 3 |
| TimelineQuotCanonical.lean | 2 |
| DovetailedTimelineQuotBFMCS.lean | 2 |
| DovetailedFMCS.lean | 1 |
| **CanonicalTimeline.lean** | 1 |
| **Total** | **45+** |

## Dependency Analysis

### Files Requiring Import Updates

These files outside StagedConstruction/Boneyard import from target modules:

#### Critical Updates Required (will break after archival)

| File | Imports From | Required Action |
|------|--------------|-----------------|
| `Metalogic.lean` | StagedConstruction.Completeness | Remove import |
| `Metalogic/Metalogic.lean` | StagedConstruction.Completeness | Remove import |
| `FrameConditions/Completeness.lean` | StagedConstruction.* | Remove imports, update docstrings |
| `DenseCompleteness.lean` | StagedConstruction.Completeness | Remove import |
| `Algebraic/DenseInstantiation.lean` | DovetailedTimelineQuotBFMCS, DovetailedTimelineQuot, DovetailedFMCS | Remove all imports |
| `Algebraic/SeparatedTaskFrame.lean` | TimelineQuotAlgebra, TimelineQuotCompleteness | Remove imports |
| `Algebraic/SeparatedHistory.lean` | TimelineQuotCanonical | Remove import |
| `Algebraic/IntBFMCS.lean` | DiscreteSuccSeed, CanonicalTimeline | Remove imports |
| `Algebraic/SaturatedChain.lean` | DensityFrameCondition, CanonicalTimeline | Remove imports |
| `Algebraic/CanonicalEmbedding.lean` | CantorApplication, TimelineQuotCanonical | Remove imports |
| `Domain/CanonicalDomain.lean` | DurationTransfer, DiscreteTimeline, CantorApplication | **Archive entire file** |
| `Domain/DiscreteTimeline.lean` | DurationTransfer, CantorPrereqs | **Archive target** |
| `Canonical/ConstructiveFragment.lean` | CanonicalTimeline | Remove import |

#### Files Already in Boneyard (no action needed)

- `Boneyard/Task994_DovetailedQuot/DovetailedFMCS.lean`
- `Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean`

### CanonicalTimeline Dependents

Files importing `CanonicalTimeline.lean`:
1. `Canonical/ConstructiveFragment.lean` - remove import
2. `Algebraic/IntBFMCS.lean` - remove import
3. `Algebraic/SaturatedChain.lean` - remove import
4. `StagedConstruction/WitnessSeedWrapper.lean` - will be archived
5. `StagedConstruction/StagedTimeline.lean` - will be archived

### DurationTransfer Dependents

Files importing `DurationTransfer.lean`:
1. `Domain/CanonicalDomain.lean` - **archive entirely** (depends on all dead paths)
2. `Domain/DiscreteTimeline.lean` - will be archived
3. `StagedConstruction/*.lean` (4 files) - will be archived

## Superseding Architecture: SuccChain

The SuccChain completeness path (`Completeness/SuccChainCompleteness.lean`) replaces StagedConstruction:

**SuccChain Architecture**:
- `Bundle/SuccChainFMCS.lean` - Family construction
- `Bundle/SuccChainTruth.lean` - Truth lemma
- `Bundle/SuccChainTaskFrame.lean` - TaskFrame construction
- `Bundle/SuccChainWorldHistory.lean` - History access

**Key Advantage**: SuccChain separates W (MCSs) from D (timeline), avoiding the W=D conflation that plagued DurationTransfer.

## Boneyard Structure

**Proposed location**: `Boneyard/Metalogic/StagedConstruction/`

```
Boneyard/Metalogic/StagedConstruction/
  +-- README.md (archive rationale)
  +-- CantorApplication.lean
  +-- ... (all 29 files)
  +-- Domain/
  |   +-- DiscreteTimeline.lean
  |   +-- DurationTransfer.lean
  |   +-- CanonicalDomain.lean
  +-- Canonical/
      +-- CanonicalTimeline.lean
```

## Implementation Checklist

### Phase 1: Archive Target Files
- [ ] Create `Boneyard/Metalogic/StagedConstruction/` directory
- [ ] Move all 29 StagedConstruction/*.lean files
- [ ] Move Domain/DiscreteTimeline.lean to Boneyard
- [ ] Move Domain/DurationTransfer.lean to Boneyard
- [ ] Move Domain/CanonicalDomain.lean to Boneyard
- [ ] Move Canonical/CanonicalTimeline.lean to Boneyard

### Phase 2: Update Imports
- [ ] Metalogic.lean - remove StagedConstruction import
- [ ] Metalogic/Metalogic.lean - remove StagedConstruction import
- [ ] FrameConditions/Completeness.lean - remove imports, update docs
- [ ] DenseCompleteness.lean - remove import
- [ ] Algebraic/DenseInstantiation.lean - remove imports or archive
- [ ] Algebraic/SeparatedTaskFrame.lean - remove imports or archive
- [ ] Algebraic/SeparatedHistory.lean - remove import or archive
- [ ] Algebraic/IntBFMCS.lean - remove imports
- [ ] Algebraic/SaturatedChain.lean - remove imports
- [ ] Algebraic/CanonicalEmbedding.lean - remove imports or archive
- [ ] Canonical/ConstructiveFragment.lean - remove import or archive

### Phase 3: Verification
- [ ] Run `lake build` - must pass
- [ ] Verify axiom count reduced (should be 6 remaining, down from 9)
- [ ] Update ROAD_MAP.md to reflect archival

## Risk Assessment

**Low Risk**:
- Build currently passes
- All targets are documented dead paths
- SuccChain architecture is established and working

**Medium Risk**:
- Several Algebraic/*.lean files may need archival if they depend solely on dead paths
- Canonical/ConstructiveFragment.lean may need archival

**Mitigation**:
- Start with leaf files (no dependents)
- Verify lake build after each batch of archives
- Keep Boneyard imports functional for reference

## Conclusion

Archiving these 32+ files eliminates 3 axioms and 45+ sorries while simplifying the codebase. The SuccChain architecture provides a complete, working alternative that correctly separates W and D types.
