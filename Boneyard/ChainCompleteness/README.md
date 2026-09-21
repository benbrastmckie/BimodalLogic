# ChainCompleteness (ARCHIVED)

**Archived**: 2026-04-10 (task 93)
**Reason**: Superseded by the SuccChain approach in StrictSemanticsLegacy

## Overview

Earlier chain-based completeness iteration (12 files, 4,186 lines, 66 sorries).
This directory contains deterministic chains, resolving chains, targeted chains,
MCS witness chains, and the top-level completeness wiring -- all superseded by the
SuccChain approach which was itself superseded by the chronicle construction.

## Directory Structure

### Algebraic/ (3 files)

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| DeterministicChain.lean | 1,058 | 18 | Deterministic chain construction (Level 0, no Boneyard deps) |
| DeterministicFMCS.lean | ~700 | 4 | FMCS/BFMCS from deterministic chain + parametric completeness |
| FiniteDeferral.lean | ~500 | ~5 | Pigeonhole argument for F-obligation resolution |

### Bundle/ (7 files)

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| MCSWitnessSuccessor.lean | 364 | ~5 | Sorry-free successor from UltrafilterChain witness |
| MCSWitnessChain.lean | ~300 | ~5 | Forward/backward DRM chains from MCSWitnessSuccessor |
| SimplifiedChain.lean | 206 | ~3 | Simplified restricted chain bypassing seed consistency sorry |
| TargetedChain.lean | 413 | ~8 | Alternative FMCS resolving F/P in deferralClosure |
| ResolvingChain.lean | ~400 | ~8 | DRM chain with sorry-free forward_F in deferralClosure |
| SuccChainTaskFrame.lean | 98 | 0 | TaskFrame instantiation using CanonicalTask |
| SuccChainWorldHistory.lean | ~200 | ~3 | WorldHistory from Succ-chain FMCS family |
| SuccChainTruth.lean | ~400 | ~5 | Truth lemma for Succ-chain canonical model |

### Completeness/ (1 file)

| File | Lines | Sorries | Description |
|------|------:|--------:|-------------|
| SuccChainCompleteness.lean | ~200 | ~2 | Top-level completeness via Succ-chain |

## Internal Dependency Graph

```
Level 0: DeterministicChain (no Boneyard deps)
Level 2: MCSWitnessSuccessor, TargetedChain, SimplifiedChain, SuccChainTaskFrame
         (depend on StrictSemanticsLegacy/Bundle/SuccChainFMCS)
Level 3: MCSWitnessChain, ResolvingChain, DeterministicFMCS, SuccChainWorldHistory
Level 4: SuccChainTruth, FiniteDeferral
Level 5: SuccChainCompleteness
```

## Relationship to Active Code

This directory is NOT on the active completeness path. The current development
uses `BXCanonical/` with chronicle-based construction under reflexive BX semantics.
The chain approach here assumed strict temporal ordering.

## References

- `Boneyard/StrictSemanticsLegacy/` -- The SuccChain approach that superseded this
- `Metalogic/BXCanonical/` -- Active completeness path
