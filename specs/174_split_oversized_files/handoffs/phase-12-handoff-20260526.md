# Phase 12 Handoff — Split ExpressivenessGeneral.lean

## Status: COMPLETED

## What was done
Split ExpressivenessGeneral.lean (9988 lines) into 5 modules in Expressiveness/ directory.
Linear internal DAG: Claim1 → DConsistencyTransport → SplitPoint → CaseAnalysis → Theorem6.
Made ~37 private definitions non-private for cross-file access.
Updated 1 importer (WeakCanonical.lean). Full `lake build` passes (1667 jobs).

## Key decisions
- Many private defs in Claim1 (31) and DConsistencyTransport (4) were used across split boundaries — all made non-private
- SplitPoint remains 4657 lines as a single cohesive proof (obtain_split_point_props)
- All 20 sorries in split files are pre-existing, not introduced by the split

## Task 155 rebase reference
The split boundaries for ExpressivenessGeneral are:
- Claim1: lines 33-1644 (base case helpers, continuation predicates, gap r-definability)
- DConsistencyTransport: lines 1645-2372 (D-consistency, rank downward transport)
- SplitPoint: lines 2373-7015 (split point infrastructure)
- CaseAnalysis: lines 7016-9689 (Cases I, II, III-IV)
- Theorem6: lines 9690-9987 (final theorem)
