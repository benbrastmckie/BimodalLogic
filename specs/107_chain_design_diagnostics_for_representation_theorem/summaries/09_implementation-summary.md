# Implementation Summary: Task #107 (Session sess_1777053244_2a67a8)

## Changes Made

### Phase 5: Prove Limit Properties (C5/C5') -- COMPLETED

Closed 2 sorry sites in `ChronicleConstruction.lean`:
- `limit_satisfies_c5_weak` (sorry #7): proven sorry-free
- `limit_satisfies_c5'_weak` (sorry #8): proven sorry-free

### Key Architectural Fix: Omega-Chain Dovetailing

**Bug found and fixed**: The omega-chain construction used a simple linear enumeration (`counterexample_enum n` at step n+1), which failed to handle the case where a domain point x enters at step n0 but the corresponding counterexample has enumeration index k < n0. In this case, the counterexample is skipped (x not yet in domain) and never re-processed.

**Fix**: Changed to Cantor unpairing (`counterexample_enum (Nat.unpair n).2` at step n+1), following the same pattern used in `CanonicalModel.lean`'s `schedule`. This ensures every counterexample index j is re-processed at infinitely many steps.

Added `counterexample_enum_surjective_above`: for any pc and k, exists n >= k with the counterexample at (Nat.unpair n).2 = pc.

### EliminationResult Refactoring

Refactored `eliminate_potential_counterexample` return type from anonymous subtype to `EliminationResult` structure, which bundles:
- `dom_sub`: domain extension
- `c0`: C0 preservation
- `f_agrees`: f-agreement on old points
- `c5_forward_witness`: C5 witness guarantee (new)
- `c5_backward_witness`: C5' witness guarantee (new)

The C5/C5' witness fields guarantee that if the input is a c5_forward/c5_backward counterexample with x in domain and Until/Since formula present, then the result has a witness in its domain.

### Files Modified

1. **CounterexampleElimination.lean**: Added `EliminationResult` structure, refactored `eliminate_potential_counterexample` to use it, added C5/C5' witness fields
2. **ChronicleConstruction.lean**:
   - Fixed omega_chain to use Cantor unpairing (dovetailing)
   - Added `counterexample_enum_surjective_above`
   - Added `omega_chain_c5_witness` and `omega_chain_c5'_witness`
   - Proved `limit_satisfies_c5_weak` and `limit_satisfies_c5'_weak` sorry-free
   - Updated `omega_chain_dom_mono`, `omega_chain_f_agrees` for new API

## Sorry Site Status

| # | File | Status | Notes |
|---|------|--------|-------|
| 5 | CounterexampleElimination.lean:289 | OPEN | C4 hard case (delta in both endpoints) |
| 6 | CounterexampleElimination.lean:355 | OPEN | C4' hard case (mirror) |
| 7 | ChronicleConstruction.lean | **CLOSED** | limit_satisfies_c5_weak |
| 8 | ChronicleConstruction.lean | **CLOSED** | limit_satisfies_c5'_weak |
| 9 | ChronicleToCountermodel.lean:192 | OPEN | chronicle_fmcs.forward_G |
| 10 | ChronicleToCountermodel.lean:196 | OPEN | chronicle_fmcs.backward_H |
| 11 | ChronicleToCountermodel.lean:234 | OPEN | box_stable_in_chronicle_fmcs |
| 12 | ChronicleToCountermodel.lean:320 | OPEN | restricted_tc F-resolution |
| 13 | ChronicleToCountermodel.lean:323 | OPEN | restricted_tc P-resolution |
| 14 | ChronicleToCountermodel.lean:342 | OPEN | restricted_buc Until |
| 15 | ChronicleToCountermodel.lean:345 | OPEN | restricted_buc Since |
| 16 | ChronicleToCountermodel.lean:374 | OPEN | restricted_fuc Until |
| 17 | ChronicleToCountermodel.lean:377 | OPEN | restricted_fuc Since |

**Net progress**: 13 -> 11 sorry sites (2 closed)

## Remaining Blockers

### Phase 6 (Domain Extension) -- Blocks 9 sorry sites

The `forward_G` and `backward_H` in `chronicle_fmcs` are unprovable with the current `extended_limit_f` because non-domain points are assigned the root MCS A, and `G(phi) in A` does not imply `phi in A` under strict semantics.

**Resolution requires** either:
- Dense chronicle domain (interleave density insertions in omega-chain so every rational is eventually a domain point)
- Subtype-indexed model (`BFMCS { x : Rat // x in limit_dom }`)

### Phase 4 remainder (C4 hard cases) -- 2 sorry sites

The case where delta is in BOTH f(x) and f(y) requires C3 invariant tracking through the omega-chain. This is blocked until the chronicle maintains C1-C3 alongside C0.

## Build Status

`lake build` succeeds with no regressions. All 1055 jobs pass.
