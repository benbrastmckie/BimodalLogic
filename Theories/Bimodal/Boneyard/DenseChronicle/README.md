# DenseChronicle (ARCHIVED)

**Archived**: 2026-04-22 (task 105)
**Reason**: Density gap -- G(phi) and untl(phi.neg, gamma) are contradictory on dense orders but BX lacks a density axiom

## Overview

Dense chronicle construction attempts (3 files, 281 lines, 3 sorries). These files
attempted to adapt the Burgess chronicle construction to dense linear orders. All
three hit the same density gap: the contradiction between `G(phi)` and
`untl(phi.neg, gamma)` is semantic (valid on dense orders) but not derivable in BX.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| CantorIsoCountermodel.lean | ~150 | 3 | Cantor isomorphism countermodel pathway (uses `#exit`, reference only) |
| DenseCounterexampleElimination.lean | ~80 | 0 | Dense counterexample elimination (doc-only, uses `#exit`) |
| DenseLimitDomain.lean | ~50 | 0 | Dense limit domain infrastructure (doc-only, uses `#exit`) |

All three files use `#exit` to prevent compilation of their archived code.

## The Density Gap

The Cantor isomorphism approach requires `DenselyOrdered` on `LimitDomSubtype`,
which requires `limit_dom_dense`, which depends on the density counterexample kind.
Since density was removed (the sorry for `SetConsistent g` is unprovable), the
entire pathway was replaced by the natural inclusion approach (X subset Q).

## Relationship to Active Code

The active completeness path uses chronicle construction without density assumptions.
See `Metalogic/BXCanonical/ChronicleConstruction.lean`.

## References

- Task 105: Dense chronicle attempts
- Task 117: Natural inclusion approach (replacement)
