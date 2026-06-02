# Phase 2 Handoff: succ_embed_surjective Blocker

**Task**: 155 - Close sorry chain to completeness_discrete via omega-chain surjectivity
**Phase**: 2 (Prove succ_embed_surjective via omega-chain induction)
**Status**: BLOCKED
**Timestamp**: 2026-06-02T15:53:00Z
**Session**: sess_1748899200_orchestrate

## Current State

Phase 1 (import cycle resolution) is COMPLETED. Phase 2 is BLOCKED after extensive analysis of the mathematical core.

## What Was Attempted

Five approaches were analyzed in depth for proving `succ_embed_surjective` (or its prerequisite `succ_cofinal`):

1. **Stage induction** (plan's recommended approach): Boundary case fails because `succ(max_N)` in limit_dom may come from stage M >> N+1, so `omega_chain_dom_new_unique` does not apply.

2. **Supremum argument**: The case where sup(orbit) is IN limit_dom gives a clean contradiction via pred/succ_pred. But the case where sup(orbit) is NOT in limit_dom creates a genuine gap scenario (disconnected succ-structure).

3. **Model surgery (chronicle_gap_contradiction)**: The distinguishing-formula case (case A) can work with k >= 1 (the existing code uses k=0, which is trivially satisfied). But the constant-MCS case (case B, where `limit_f(a) = limit_f(b)`) is genuinely hard -- no formula distinguishes the two sides of the gap.

4. **Z1 axiom**: Trivially satisfied when MCS is G-closed, provides no structural information.

5. **Prior-UZ**: Finds nearest witnesses but cannot force cross-component witnesses.

## Root Cause

`LimitDomSubtype` being a countable discrete linear order with no endpoints does NOT imply `IsSuccArchimedean`. The counterexample is Z + Z. The omega-chain axioms (Z1, Prior-UZ, discreteness) are all satisfiable on disconnected orders with constant MCS.

## Key Files

- `ChronicleToCountermodel.lean:1667` - `succ_embed_surjective` (target theorem)
- `ChronicleToCountermodel.lean:776` - `succ_cofinal` (prerequisite, sorry via line 489)
- `ChronicleToCountermodel.lean:475` - `chronicle_gap_contradiction` (core sorry)
- `ChronicleToCountermodel.lean:101` - `succ_reaches_dom_N` (stage induction, 2 sorry sites)

## Recommended Next Steps

1. **Research task**: Investigate approach (A) from the blocker -- multi-predicate model surgery with the full formula signature, not just a single distinguishing predicate. The EF-game at sufficient depth may detect the gap even in the constant-MCS case because temporal formulas (U/S/G/H) encode order-theoretic information.

2. **Alternative**: Approach (C) -- bypass surjectivity entirely by restructuring `restricted_tc` and `restricted_fuc` to prove coherence directly on the Z-indexed family without converting limit_dom witnesses to integers.

## Build Status

`lake build` passes. No files were modified (Phase 2 did not reach the implementation stage -- analysis revealed the mathematical blocker before code was written).
