# BX1DependentCode -- Archived Dead Code

Archived: Task 130 (2026-05-20)
Source: Extracted from BXCanonical/Quasimodel/Realization.lean

## Why Archived

Helper theorems that require BX1 (G(phi)->phi), which was removed when the
project moved to irreflexive (strict) temporal semantics under task 113.

F_of_mem and P_of_mem prove F(psi) in w / P(psi) in w from psi in w,
which requires G(neg psi) not in w, which in turn requires BX1 to push
G-content into the current world. Without BX1, this reasoning breaks.

The enriched seed consistency sorries (inside enriched_seed_consistent_until
and enriched_seed_consistent_since) similarly depend on g_content(w) subset
w.formulas, which requires BX1.

## Sorry Summary

| Definition | Sorry Reason |
|-----------|-------------|
| F_of_mem | BX1 (G(phi)->phi) removed |
| P_of_mem | BX1 (H(phi)->phi) removed |
| enriched_seed_consistent_until (inner) | g_content subset via BX1 |
| enriched_seed_consistent_since (inner) | h_content subset via BX1 |

## Task Cross-References

- Task 113: BX1/BX1' removal (open guard refactor)
- Task 130: This archival
