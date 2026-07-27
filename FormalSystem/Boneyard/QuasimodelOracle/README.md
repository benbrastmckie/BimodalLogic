# Quasimodel Oracle Dead Code Archive

This directory contains orphaned files from the quasimodel oracle chain approach to completeness, archived from `Metalogic/BXCanonical/`.

## Archived Date

2026-04-20

## Why This Code Was Archived

These files implement an oracle-based approach to constructing forward/backward MCS chains for temporal coherence. The approach was abandoned due to:

1. **OracleStep** - Oracle step infrastructure (`qm_oracle_step`, `qm_oracle_step_bwd`, `hintikka_step_for_sigma_sig`) with 25 sorry gaps in core lemmas.
2. **OracleCoherence** - Oracle replacement for `dd_bfmcs`, abandoned at backward coherence obstruction. The backward step transfer `phi /\ F(phi U psi) -> phi U psi` is semantically invalid.
3. **RoundRobinChain** - Round-robin chain construction confirmed dead after 40 rounds of research: the depth-0 base case of `forward_F` is blocked by the BX11 perpetual deferral obstruction.

## File Summary

| File | Lines | Sorries | Origin |
|------|-------|---------|--------|
| OracleStep.lean | 458 | 25 | `BXCanonical/Quasimodel/` |
| OracleCoherence.lean | 500 | 14 | `BXCanonical/Boneyard/` |
| RoundRobinChain.lean | 509 | 5 | `BXCanonical/Boneyard/` |
| **Total** | **1,467** | **44** | |

All three files were already outside the build chain (not imported by any compiled module) prior to archival.

## Code Retrieval

The full git history is preserved. To view files at their original locations:

```bash
git log --follow Theories/Bimodal/Boneyard/QuasimodelOracle/OracleStep.lean
```

## Reference

See `ROADMAP.md` in project root for context on archived approaches.
