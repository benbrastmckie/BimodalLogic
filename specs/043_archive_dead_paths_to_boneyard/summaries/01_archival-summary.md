# Implementation Summary: Archive Dead Paths to Boneyard

- **Task**: 43 - Archive StagedConstruction and DiscreteTimeline paths to Boneyard
- **Status**: COMPLETED
- **Date**: 2026-03-23
- **Session**: sess_1774251396_ba64e2

## Outcome

Successfully archived 40 dead path files from active development to Boneyard, eliminating 3 axioms from the build.

## Axioms Eliminated

The following 3 axioms are now archived (no longer in active builds):

1. **discrete_Icc_finite_axiom** - Finiteness of closed intervals in discrete timeline
2. **discreteImmediateSuccSeed_consistent_axiom** - Consistency of discrete successor seed
3. **discreteImmediateSucc_covers_axiom** - Covering property for discrete successors

**Axiom Count**: 9 -> 6 (3 eliminated)

## Files Archived

### Phase 1: StagedConstruction Core (29 files)
Moved all files from `Theories/Bimodal/Metalogic/StagedConstruction/` to `Boneyard/Metalogic/StagedConstruction/`:
- Completeness.lean, CantorPrereqs.lean, CantorApplication.lean
- DovetailedTimelineQuot.lean, DovetailedBuild.lean, DovetailedFMCS.lean
- DiscreteSuccSeed.lean (contained 2 archived axioms)
- And 22 other support files

### Phase 2: Domain and Canonical (5 files)
- Domain/DiscreteTimeline.lean (contained discrete_Icc_finite_axiom)
- Domain/DurationTransfer.lean
- Domain/CanonicalDomain.lean
- Domain/README.md
- Canonical/CanonicalTimeline.lean

### Phase 4: Algebraic Dependencies (6 files)
- DenseInstantiation.lean
- SeparatedTaskFrame.lean
- SeparatedHistory.lean
- IntBFMCS.lean
- SaturatedChain.lean
- CanonicalEmbedding.lean

### Phase 5: Canonical Fragment (1 file)
- Canonical/ConstructiveFragment.lean

## Files Updated

### Phase 3: Core Import Updates
- `Theories/Bimodal/Metalogic.lean` - Removed StagedConstruction import, updated docs
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Removed StagedConstruction import, updated docs
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Removed StagedConstruction imports, rewrote for SuccChain
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Removed StagedConstruction imports, rewrote for SuccChain

## Verification

- **lake build**: Passed (925 jobs completed successfully)
- **Axiom count**: 6 axioms remaining in active code (down from 9)
- **No StagedConstruction imports**: Verified no active files import from archived paths
- **Boneyard structure**: All archived files organized with README documentation

## Remaining Axioms (Active Code)

The 6 remaining axioms in active builds:
1. f_nesting_boundary (SuccChainFMCS.lean)
2. p_nesting_boundary (SuccChainFMCS.lean)
3. existsTask_irreflexive_axiom (CanonicalIrreflexivity.lean)
4. successor_deferral_seed_consistent_axiom (SuccExistence.lean)
5. predecessor_deferral_seed_consistent_axiom (SuccExistence.lean)
6. predecessor_f_step_axiom (SuccExistence.lean)

## Directory Structure After Archival

```
Boneyard/Metalogic/StagedConstruction/
+-- README.md (updated with archival documentation)
+-- *.lean (29 files)
+-- Domain/
|   +-- README.md
|   +-- DiscreteTimeline.lean
|   +-- DurationTransfer.lean
|   +-- CanonicalDomain.lean
+-- Canonical/
|   +-- CanonicalTimeline.lean
|   +-- ConstructiveFragment.lean
+-- Algebraic/
    +-- DenseInstantiation.lean
    +-- SeparatedTaskFrame.lean
    +-- SeparatedHistory.lean
    +-- IntBFMCS.lean
    +-- SaturatedChain.lean
    +-- CanonicalEmbedding.lean
```

## Notes

The StagedConstruction approach was superseded by the SuccChain architecture which correctly separates W (MCSs/worlds) from D (timeline domain). The archived files are preserved for historical reference but are not part of active development.

The SuccChain architecture introduces different axioms focused on successor existence rather than discreteness properties.
