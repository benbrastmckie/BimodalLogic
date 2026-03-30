# Implementation Summary: Task #67 - Well-Founded Restructure Attempt

**Task**: 67 - prove_bundle_validity_implies_provability
**Plan Version**: v10 (well-founded-restructure)
**Session**: sess_1774829128_ad0ed3
**Status**: BLOCKED - Phase 2

## Work Completed

### Phase 1: Backward Chain Proofs [COMPLETED]
- Previously completed in plan v9 sessions
- `constrained_predecessor_restricted_g_persistence_reverse` proven
- `constrained_predecessor_restricted_f_step_forward` proven

### Phase 2: Well-Founded Infrastructure [BLOCKED]

Attempted multiple approaches to eliminate the fuel-exhaustion sorries:

1. **Two-fuel approach** (resolve_fuel, defer_fuel):
   - Designed to capture lexicographic termination
   - Failed: Invariant preservation requires `resolve_fuel >= 1` at recursive calls
   - When `resolve_fuel = 1`, recursive call has `resolve_fuel' = 0`, violating invariant

2. **Single remaining_steps approach** (original):
   - Works for termination proof via `termination_by remaining_steps`
   - Fails at base case: `remaining_steps = 0` with `d >= 1` needs witness

3. **Strong induction on d**:
   - Cannot directly use: new depth `d' + (n-1)` after resolve is not necessarily < old depth `n+1`
   - Requires `d' < 2`, but `d' >= 1` can be up to `B-1`

## Blocking Issue

The fundamental challenge is that **depth can increase on resolve**:

- Old depth: `d = n + 1`
- After resolve to `k+1`, get new boundary `d'` for inner formula
- New tracking depth: `d' + (n - 1)`
- For depth to decrease: need `d' + (n-1) < n+1`, i.e., `d' < 2`
- But `d' >= 1` and can be up to `B-1`

The termination argument requires tracking **levels resolved** (F's peeled off) rather than current depth, but this requires significant restructuring to thread through the proof.

## Current Sorry Sites

All 4 target sorries remain in `SuccChainFMCS.lean`:

| Line | Function | Status |
|------|----------|--------|
| 2909, 2911 | `restricted_bounded_witness_wf` | Unchanged |
| 5523 | `restricted_backward_bounded_witness_fueled` | Unchanged |
| 5681 | `restricted_combined_bounded_witness_fueled` | Unchanged |
| 5877 | `restricted_combined_bounded_witness_P_fueled` | Unchanged |

## Dependency Analysis

```
bundle_validity_implies_provability
  └─> bfmcs_from_mcs_temporally_coherent [SORRY - line 220]
      └─> Z_chain_forward_F / Z_chain_backward_P [in UltrafilterChain.lean]
          └─> restricted_bounded_witness [depends on sorries]
```

The completeness theorem is structurally complete but blocked by the temporal coherence sorry, which traces back to these fuel-exhaustion sorries.

## Recommended Next Steps

### Option 1: Fuel-Sufficient Invariant (Medium complexity)
Thread an invariant `h_fuel_sufficient : remaining_steps >= work_remaining` where:
- `work_remaining = levels_remaining * B + defers_at_current_level`
- Prove invariant preserved at each recursive call
- Base case becomes: `0 >= work_remaining` with `work_remaining >= 1` is contradiction

### Option 2: Nested Strong Induction (High complexity)
Structure as:
- Outer induction on `levels_remaining` (number of F's to peel)
- Inner induction on `defers_at_current_level` (bounded by B)
- Each resolve decreases outer, resets inner
- Each defer decreases inner

### Option 3: Accept Semantically Sound (Pragmatic)
- Document that sorries are unreachable with proper initialization
- Verify via testing that completeness path functions correctly
- Create follow-up task for formal elimination

## Build Status

```
lake build: SUCCESS (with warnings)
Sorry count in SuccChainFMCS.lean: 4 target + 3 deprecated
```

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - Attempted two-fuel restructuring (reverted)
  - Documentation updates in `restricted_bounded_witness_wf`
