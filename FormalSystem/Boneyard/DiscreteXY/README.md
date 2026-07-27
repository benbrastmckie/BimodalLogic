# DiscreteXY (ARCHIVED)

**Archived**: 2026-04-05 (task 85)
**Reason**: Discrete x_content/y_content approach replaced by open guard semantics

## Overview

Single file (72 lines, 1 sorry) deriving the backward discreteness axiom (DP)
from the forward discreteness axiom (DF) using the temporal_duality inference rule.

## Files

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| Discreteness.lean | 72 | 1 | DP derived from DF via temporal_duality (references `temporal_duality`) |

## What It Does

Derives `discreteness_past`: (P(top) and phi and G(phi)) -> P(G(phi)) from the
forward discreteness axiom DF by:
1. Instantiating DF at `swap_temporal(phi)`
2. Applying `temporal_duality` to swap all_past with all_future
3. Using `swap_temporal_involution` to simplify

## Relationship to Active Code

Imports `Bimodal.ProofSystem.Derivation`. The discreteness axioms are not part
of the current TM axiom system. The approach was replaced by direct open guard
semantics.

## References

- Task 85: x_content/y_content removal
