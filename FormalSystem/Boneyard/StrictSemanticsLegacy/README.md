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

#### The frame-condition completeness wiring was archived, not removed

A standing claim elsewhere in this repository's history recorded that the frame-condition
completeness wiring was *done*, naming `completeness_over_Int`, `discrete_completeness_fc` and
`dovetailed_bundle`, and a later reading concluded that all three had been deleted. Neither
framing is accurate. The measured state:

- `completeness_over_Int` (`FrameConditions/Completeness.lean:530`) and
  `discrete_completeness_fc` (`:549`) both **still exist**, here, in this archive. They were
  moved, not deleted.
- Being archived, they are unreachable from every Lake target root, so no build elaborates them
  and neither theorem is compile-checked. Any live claim that the wiring "is done" is therefore
  false *of the live tree*, even though the source text is still on disk.
- `dovetailed_bundle` has no declaration of that exact name anywhere in the repository. What this
  file does declare are `dovetailed_bundle_to_bfmcs` (`:433`) and
  `dovetailed_bundle_validity_implies_provability` (`:474`); the bare name is genuinely gone, the
  prefix is not.

This file's `import FormalSystem.FrameConditions.Compatibility` (`:1`) is permanently waived in
`scripts/boneyard-import-waivers.txt`. The typeclass-based frame-condition layer it imported was
deleted from the live tree -- it was a carrier-typeclass re-encoding of the frame classes with no
consumer outside its own directory, superseded by `Semantics/FrameClassValidity.lean`'s
`FrameClass.Sat`, `Semantics/Validity.lean`'s `ValidIn`, and `Semantics/FrameProperty.lean`'s
`TaskFrame.IsDense` / `TaskFrame.IsSuccArchDiscrete` / `TaskFrame.IsDedekind`. No file of that
name exists on disk any more, so the import cannot be repointed; reviving the deleted layer is an
explicit non-goal. This file is retained precisely because it is the evidence for the correction
above.

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
