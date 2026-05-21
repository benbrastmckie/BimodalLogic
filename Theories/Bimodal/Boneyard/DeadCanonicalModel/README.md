# DeadCanonicalModel (ARCHIVED)

**Archived**: 2026-05-02 (task 113)
**Reason**: Enriched seed approach is structurally unfixable

## Overview

Single file (90 lines, 4 sorries) containing a dead enriched seed approach to
canonical model construction. The enrichment step cannot maintain consistency of
the extended seed.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| EnrichedSeedLegacy.lean | 90 | 4 | Definitions and theorems for f_carry/p_carry enriched seed |

## What Was Tried

The approach tried to enrich the successor seed with `f_carry` (F-formulas
literally present in an MCS) and `p_carry` (P-formulas) to preserve F-obligations
through non-resolving chain steps. The definitions are mathematically sound but:

1. `enriched_seed_consistent` / `enriched_past_seed_consistent`: Under irreflexive
   semantics `g_content(M) subset M` does NOT hold (BX1 removed), so the old proof
   is invalid
2. `fwd_succ_f_carry` / `bwd_pred_p_carry`: Under irreflexive semantics the
   non-resolving step seeds with `g_content(M)` alone, so f_carry is NOT preserved

## Relationship to Active Code

The active path uses `fwd_succ` with seed `g_content(M)` alone (consistent via
seriality). See `BXCanonical/CanonicalModel.lean`.

## References

- Task 109: Removed during open guard refactoring
- Task 113: Archived to Boneyard
