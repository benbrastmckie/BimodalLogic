# Phase 4 Handoff: blocking_terminates Resolution

**Date**: 2026-06-01
**Session**: sess_1780376119_ad7b68
**Phase**: 4 (Prove blocking_terminates)
**Status**: COMPLETED (theorem removed, sorry eliminated)

## What Was Done

1. **Proved theorem is FALSE via computational counterexample**: The formula ◇p
   (`(box (imp p bot)) → bot`) fails with `soundFuel = 160` because of a
   persistent rule loop between `boxPos` and `negPos`.

2. **Identified two independent failure modes**:
   - Blocked-but-not-saturated: `expandBranchWithFuel` returns blocked branches
     with unexpanded propositional formulas; `buildTableau` rejects these
   - Persistent rule loop: `boxPos` adds `T(psi)`, `negPos` consumes it immediately,
     `boxPos` re-adds it, loop exhausts fuel

3. **Fixed blocked-but-not-saturated issue**: Added `saturateBlocked` function that
   continues expanding non-time-generating rules after blocking fires. Modified
   `buildTableau` to use it. This fixes formulas like `G(p -> F(q))` that previously
   returned `none`.

4. **Removed the sorry**: Replaced the false `blocking_terminates` theorem with
   detailed documentation of both failure modes and prerequisites for a correct
   termination theorem.

## Key Decisions

- **Did NOT attempt to prove a false theorem**: The sorry was removed by removing
  the theorem, not by proving it. The theorem was demonstrated false.
- **Preserved existing proofs**: `expandBranchWithFuel_sound` and all other theorems
  remain unchanged and passing.
- **Improved practical behavior**: The `saturateBlocked` addition makes `buildTableau`
  succeed for more formulas (those with blocked-but-not-saturated branches).

## Files Modified

- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`: Added `saturateBlocked`,
  modified `buildTableau`, removed false `blocking_terminates` theorem, added documentation
- `specs/164_prove_tableau_correctness/plans/02_implementation-plan.md`: Updated Phase 4
  status and task annotations

## Verification

- Zero sorries in all Decidability files
- Zero vacuous definitions
- Full `lake build` passes (1680 jobs)
- All existing tests pass

## Follow-up Work Needed

To prove a correct termination theorem, the persistent rule loop must be fixed first.
Standard approaches:
1. Track "already expanded" persistent-rule instances
2. Change `boxPos` to check for expanded descendants
3. Make persistent rule outputs immune to consumable-rule removal

This is an architectural issue in the tableau expansion, not a proof gap.
