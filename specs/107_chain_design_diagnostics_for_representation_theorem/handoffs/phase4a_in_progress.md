# Handoff: Phase 4a Started — c2' Parameter Added, Call Sites Need Fixing

## Status

- **Date**: 2026-05-04T03:56:43Z
- **Phase**: Phase 4a (Refactor EliminationResult to Carry c2') — IN PROGRESS
- **Files Modified**: CounterexampleElimination.lean
- **Files With New Errors**: ChronicleConstruction.lean

## What Was Done

1. **Signature change**: Added `(h_c2' : χ.c2')` parameter to `eliminate_potential_counterexample` in CounterexampleElimination.lean (line ~731).

2. **Confirmed `EliminationResult` already carries `c2'` field** (line 702), so no structural change to the result type was needed. The plan's Task 4a.1 was already completed in a previous iteration.

## Current Blocker

The `omega_chain` definition in ChronicleConstruction.lean calls `eliminate_potential_counterexample` without the new `h_c2'` argument, causing type errors:

- ChronicleConstruction.lean:259 — `let elim := eliminate_potential_counterexample prev.val prev.property pc`
- ChronicleConstruction.lean:281 — `eliminate_potential_counterexample` call in `omega_chain_elim_result`

## Next Steps (Unstarted)

### Immediate: Fix ChronicleConstruction call sites
- `omega_chain` step case needs `prev.val.c2'` as the third argument
- `omega_chain_elim_result` needs to extract/provide c2' from the chronicle
- Add `omega_chain_c2'` accessor theorem

### Then: Fill all 12 c2' sorries in CounterexampleElimination.lean
- 5 no-elimination cases: trivial reuse of `h_c2'`
- 1 density case: construct BurgessR3Maximal from existing g-values
- 4 C5/C5' elimination cases: use `lemma_2_4` to get new endpoint maximal
- 2 C4/C4' elimination cases: use `lemma_2_6_splitting` (requires Phase 2 completion)

### Finally: Fill remaining sorries
- PointInsertion.lean: 4 sorries (Phase 2 + Phase 3)
- CounterexampleElimination.lean: 2 hard-case C4/C4' sorries (C11/C12)
- ChronicleToCountermodel.lean: 2 FUC/FSC sorries (Phase 5)

## Build Status

`lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction` fails with type mismatch errors at `eliminate_potential_counterexample` call sites.

## Context

Approaching context limit — cannot proceed with further proof editing in this session.
