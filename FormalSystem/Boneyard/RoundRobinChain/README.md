# RoundRobinChain (ARCHIVED)

**Archived**: 2026-04-28 (task 107)
**Reason**: BX11 perpetual deferral makes depth-0 base case of `forward_F` unprovable

## Overview

Round-robin chain construction (2 files, 2,522 lines, 7 sorries). Confirmed dead
after extensive research: the depth-0 base case of `forward_F` is permanently
blocked by the BX11 perpetual deferral obstruction -- an Until obligation can be
perpetually deferred to later chain stages without ever being fulfilled.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| DRMChain.lean | 286 | 7 | DRM chain construction with simplified restricted seed and forward_F proof attempt |
| ProofSketch_Sections1to30.lean | 2,236 | 0 | Detailed proof sketch for WF-induction approach (doc-only, uses `/-` block) |

## Why It Failed

At each resolving step for target chi, the Lindenbaum extension of
`{chi} union g_content(M)` can choose `G(neg(psi))` over `F(psi)`, permanently
killing any other F-obligation. Extended seed consistency fails in general when
`F(G(neg(psi)))` is in M (Case 4).

The enriched chain preserves `F(psi)` at every step
(`rr_fwd_chain_F_obligation_persists`), but at each resolving step the BX11 fold
may perpetually defer psi.

## Relationship to Active Code

DRMChain.lean imports active modules (`RestrictedMCS`, `SuccExistence`,
`SuccRelation`, `CanonicalTaskRelation`, `Propositional`). The mathematical
infrastructure is correct and reusable -- the obstruction is specifically in the
`forward_F` depth-0 base case.

## References

- Task 93: Confirmed dead after 40 rounds of research
- Task 107: Archived with QuasimodelOracle and DefectDirectedChain
