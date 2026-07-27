# UltrafilterFrame (ARCHIVED)

**Archived**: 2026-05-20 (task 21)
**Reason**: Elaboration conflicts with BXCanonical completeness; prerequisite for Jonsson-Tarski (task 125)

## Overview

Tense S5 algebra typeclass and ultrafilter frame infrastructure (2 files, 1,553
lines, 5 sorries). TenseS5Algebra defines the STSA typeclass and proves the
Lindenbaum algebra instance. UltrafilterFrame defines R_G/R_H/R_Box accessibility
relations, UltrafilterChain structure, and F/P resolution theorems.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| TenseS5Algebra.lean | 365 | 3 | STSA typeclass + Lindenbaum instance (sorries for removed axioms temp_a, temp_l) |
| UltrafilterFrame.lean | 1,188 | 2 | R_G/R_H/R_Box relations, chain structure, F/P resolution (sorries for temp_4) |

## Why Archived

UltrafilterFrame was commented out from `Algebraic.lean` due to elaboration
interference with `BXCanonical/Completeness.lean` rfl proofs. TenseS5Algebra's
only consumer was UltrafilterFrame.

The 3 sorries in TenseS5Algebra are for axioms `temp_a` and `temp_l` which were
removed from the active axiom system. The 2 sorries in UltrafilterFrame are for
`temp_4` (G(phi) -> G(G(phi))).

## Recovery

Both files are prerequisites for the Jonsson-Tarski representation theorem
(task 125). Recoverable via git history when that task is undertaken.

## References

- `Metalogic/Algebraic/` -- Active algebraic infrastructure
- Task 125: Jonsson-Tarski representation (future)
