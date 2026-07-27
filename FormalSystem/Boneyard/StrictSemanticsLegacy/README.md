# StrictSemanticsLegacy

Archived completeness files written under **strict temporal semantics** (G/H with strict `<`).

## Why These Files Were Archived

The codebase reverted from strict temporal semantics to **reflexive BX semantics** (G/H with `<=`).
These files encode completeness proofs that assume strict ordering on temporal accessibility,
making them architecturally incompatible with the current semantic foundation.

The sorry counts in these files (107 total) reflect this **architectural incompatibility**,
not mathematical gaps -- the proof strategies are sound under their original semantics but
cannot be directly adapted to the reflexive setting.

## Active Completeness Path

The current completeness development uses `BXCanonical/` (reflexive BX semantics).
See `ROAD_MAP.md` in the repository root for the current trajectory.

## Archived Files

### Primary Targets (4 files, 99 sorries)
- `Algebraic/UltrafilterChain.lean` (18 sorries) -- Bundle-level temporal coherence
- `Algebraic/DovetailedChain.lean` (9 sorries) -- Dovetailed chain construction
- `Bundle/SuccChainFMCS.lean` (18 sorries) -- Successor chain FMCS construction
- `FrameConditions/Completeness.lean` (54 sorries) -- Frame condition completeness wiring

### Dependent Files (2 files, 4 sorries)
- `Algebraic/RestrictedTruthLemma.lean` (1 sorry) -- Restricted truth lemma
- `Bundle/CanonicalConstruction.lean` (3 sorries) -- Canonical construction using SuccChain

### Downstream Wiring Files (3 files, 4 sorries)
- `BaseCompleteness.lean` (0 sorries) -- Base completeness wiring
- `DiscreteCompleteness.lean` (3 sorries) -- Discrete frame completeness
- `DenseCompleteness.lean` (1 sorry) -- Dense frame completeness

## Relationship to ChainCompleteness

The sibling `Boneyard/ChainCompleteness/` directory contains an earlier iteration of chain-based
completeness that was superseded by the SuccChain approach archived here. Both represent
explorations of the strict-semantics completeness path that are no longer on the active
development trajectory.

## References

- `ROAD_MAP.md` -- Current development trajectory
- `Metalogic/BXCanonical/` -- Active completeness path (reflexive BX semantics)
- `Boneyard/ChainCompleteness/` -- Earlier chain completeness attempt
