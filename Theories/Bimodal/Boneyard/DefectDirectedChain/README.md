# DefectDirectedChain (ARCHIVED)

**Archived**: 2026-04-28 (task 107)
**Reason**: Defect metric does not decrease monotonically through chain extension steps

## Overview

Root-scoped defect-discharge chain construction (1 file, 1,556 lines, 7 sorries).
Attempted to build MCS chains by directing construction toward reducing a "defect"
metric -- the count of unresolved F/P obligations. Abandoned when the defect metric
was shown to not decrease monotonically.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| RootScopedChain.lean | 1,556 | 7 | Infinite round-robin FMCS/BFMCS with all coherence properties |

## Architecture

The approach used an infinite round-robin chain that cycles through all formulas
in sigma, resolving each one at its scheduled step. F-formulas persist between
steps because:
1. At non-resolving steps: f_carry preserves them
2. At resolving steps: the enriched seed (via BX11 fold) protects them
3. F(F(psi)) -> F(psi) by temp_4 contrapositive ensures fold compounds work

## Why It Failed

The defect metric (count of unresolved obligations) does not decrease monotonically.
Resolving one F-obligation can introduce new obligations via the BX11 fold, leading
to a non-terminating cycle.

## Relationship to Active Code

Imports active modules (`OrderedSeedConsistency`, `CanonicalModel`,
`UntilSinceCoherence`, `ParametricCompleteness`, `RestrictedParametricTruthLemma`).

## References

- Task 107: Archived with QuasimodelOracle and RoundRobinChain
