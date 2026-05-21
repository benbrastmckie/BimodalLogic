# NonBurgessSeed (ARCHIVED)

**Archived**: 2026-04-28 (task 107, Phase 3)
**Reason**: Inconsistent case hits density gap

## Overview

Legacy g_content/h_content functions from PointInsertion.lean (1 file, 141 lines,
8 sorries). The consistent case of each function was proved, but the inconsistent
case hits the density gap: `G(phi)` and `untl(phi.neg, gamma)` are semantically
contradictory on dense orders but BX has no density axiom to derive the
contradiction formally.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| PointInsertionLegacy.lean | 141 | 8 | g_content/h_content helpers and splitting_seed_consistent (all commented out) |

## Archived Functions

- `G_conj_strengthen`: G(beta -> beta and phi) in A from G(phi) in A
- `g_content_consistent_case`: Consistent case helper for g_content subset B
- `H_conj_strengthen`: H(beta -> beta and psi) in C from H(psi) in C
- `g_content_sub_B_of_BurgessR3Maximal`: g_content(A) subset B (2 sorry sites)
- `h_content_sub_B_of_BurgessR3Maximal`: h_content(C) subset B (2 sorry sites)
- `splitting_seed_consistent` (old version): Seed consistency via g_content subset B

All code is commented out and non-compilable.

## Relationship to Active Code

The new approach in `splitting_seed_consistent` (active code) consolidates both
sorry sites into a single density gap sorry with clear documentation.

## References

- Task 107: Phase 3 restructured with Burgess D0 seed
- `Boneyard/DenseChronicle/` -- Same density gap from a different angle
