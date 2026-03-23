# StagedConstruction Archive

**Archived**: 2026-03-23
**Reason**: Superseded by SuccChain completeness approach
**Task**: 43 - Archive dead paths to Boneyard

## Overview

This directory contains the StagedConstruction/ approach to modal completeness proofs. The approach has been superseded by the SuccChain architecture which correctly separates W (MCSs) from D (timeline points).

## Axioms Eliminated

Three axioms are archived here (no longer loaded in active builds):

1. **discrete_Icc_finite_axiom** (DiscreteSuccSeed.lean)
2. **discreteImmediateSuccSeed_consistent_axiom** (DiscreteSuccSeed.lean)
3. **discreteImmediateSucc_covers_axiom** (DiscreteSuccSeed.lean)

These axioms attempted to formalize discrete timeline properties but conflated W (worlds/MCSs) with D (timeline domain). The SuccChain approach avoids this by:
- Building timelines on dedicated domain type D
- Using successor chain construction without discreteness axioms
- Properly separating algebraic structure from semantic interpretation

## File Count

- 29 .lean files
- Domain/ subdirectory (for archived Domain/*.lean files)
- Canonical/ subdirectory (for archived Canonical/*.lean files)

## Key Files

- `Completeness.lean` - Main completeness orchestration (superseded)
- `DiscreteSuccSeed.lean` - Contains the 3 eliminated axioms
- `DovetailedTimelineQuot.lean` - Complex quotient construction (had many sorries)
- `CantorPrereqs.lean` - Cantor interval prerequisites

## Sorries

This archive contained 45+ sorries at time of archival. These were never fixed because the underlying approach was superseded.

## Restoration

To restore for exploration:
1. Copy needed files to Theories/Bimodal/Metalogic/
2. Update imports to match current module structure
3. Files will not build cleanly (imports reference non-existent modules)

## Active Replacement

For the current completeness approach, see:
- `Theories/Bimodal/Metalogic/SuccChain/` - Successor chain construction
- `Theories/Bimodal/Metalogic/FrameConditions/` - Frame condition approach

---

*This README replaces the original StagedConstruction/README.md*
