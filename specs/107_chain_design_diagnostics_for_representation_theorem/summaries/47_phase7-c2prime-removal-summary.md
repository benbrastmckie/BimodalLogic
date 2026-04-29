# Phase 7 Implementation Summary: Remove c2' from EliminationResult

## Overview

Phase 7 of task 107 removes `c2'` from the `EliminationResult` structure and updates all callers. This eliminates the structural blocker that prevented Phases 8-9 from proceeding.

## Changes Made

### CounterexampleElimination.lean

1. **Removed `c2'` field from `EliminationResult` structure** (was always sorry)
2. **Removed `g_prop_forward` and `g_prop_backward` from `PotentialCounterexampleKind`** (not in Burgess's construction)
3. **Removed g_prop/h_prop match cases from `eliminate_potential_counterexample`** (~100 lines removed)
4. **Removed `h_c2'` parameter from `eliminate_potential_counterexample`**
5. **Removed `h_c2'` parameter from `eliminate_C4_counterexample` and `eliminate_C4'_counterexample`**
6. **Added sorry for C4/C4' hard cases** that previously used `h_c2'` for BurgessR3 bridging
7. **Simplified density case** - no longer needs modified g' construction for c2', uses original χ.g directly

### ChronicleConstruction.lean

1. **Changed `omega_chain` invariant** from `{ χ : Chronicle // χ.c0 ∧ χ.c2' }` to `{ χ : Chronicle // χ.c0 }`
2. **Removed `omega_chain_c2'` theorem** (no longer extractable from invariant)
3. **Updated `omega_chain_elim_result`** to not pass `h_c2'` to `eliminate_potential_counterexample`

## Sorry Count Change

- **Before Phase 7**: 7 sorries in CounterexampleElimination.lean
  - 4 × `c2' := sorry` in c5_forward, c5_backward, c4_forward, c4_backward cases
  - 2 × `c2' := sorry` in g_prop_forward, g_prop_backward cases (now removed)
  - 1 × density self-pair sorry
- **After Phase 7**: 2 sorries in CounterexampleElimination.lean
  - Line 412: C4 hard case (BurgessR3 bridging without c2')
  - Line 510: C4' hard case (BurgessR3 bridging without c2')
  - The density sorry was eliminated along with the c2' proof block

Net change: 7 → 2 sorries (5 eliminated, not 6 as planned, since 2 new sorries introduced at C4/C4' hard cases).

## Architectural Impact

- **EliminationResult** is now simpler: only carries c0, f_agrees, g_agrees, and witness fields
- **omega_chain** invariant is leaner: only c0
- **g_prop/h_prop** cases are completely removed from the codebase (not in Burgess 1982)
- **C4/C4' hard cases** now need sorry for BurgessR3 bridging - to be addressed in Phase 8 when c2' is re-established at the limit

## Remaining Work

- **Phase 8**: Close the C4/C4' hard case sorries by proving BurgessR3 holds via c2' at the limit
- **Phase 9**: Prove c2' is vacuously true at the limit (dense domain, no adjacent pairs)

## Build Status

Build passes successfully with 2 sorry warnings in CounterexampleElimination.lean (C4/C4' hard cases).
