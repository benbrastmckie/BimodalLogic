# FiltrationOrdering -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: BXCanonical/Filtration/SigmaOrdering.lean

## Why Archived

Sigma-restricted ordering on BXPoints for filtration-based completeness.
3 sorries in SigmaOrdering stem from BX1 removal under irreflexive semantics:
sigma_le reflexivity, sigma_strict irreflexivity, and sigma_equiv exclusion
all require G(phi)->phi which is not valid in strict temporal semantics.

Superseded by Chronicle construction which avoids filtration entirely.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| sigma_le_refl | BX1 (G(phi)->phi) removed |
| sigma_strict_irrefl | BX1 removed |
| not_sigma_equiv_of_sigma_strict | BX1 removed |

## Task Cross-References

- Task 101: Original design of sigma ordering
- Task 113: BX1 removal (open guard refactor)
- Task 130: This archival
