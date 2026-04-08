# Implementation Summary: Task #84

**Completed**: 2026-04-08
**Mode**: Team Implementation (2 max concurrent teammates)
**Status**: PARTIAL (Phase 1 complete, Phases 2-4 blocked)

## Wave Execution

### Wave 1 (Trunk)
- Phase 1: Derive until_intro and since_intro — **COMPLETED** (single agent)

### Wave 2 (Parallel)
- Phase 2: Backward Until and Backward Since — **PARTIAL** (teammate: phase2-backward-until-since)
- Phase 3: Forward Until and Forward Since — **BLOCKED** (teammate: phase3-forward-until-since)

### Wave 3 (Not Reached)
- Phase 4: Assemble and Close Sorry Sites — **NOT STARTED** (blocked by Phases 2, 3)

## Changes Made

### Phase 1 — 6 Sorries Closed (COMPLETED)

Added 12 new sorry-free theorems to `Theories/Bimodal/Theorems/TemporalDerived.lean`:
- `contrapositive`, `formula_or_comm` (propositional helpers)
- `x_implies_id`, `y_implies_id` (X(a) → a, Y(a) → a from BX9+propositional)
- `or_until_imp`, `or_since_imp` (disjunction-to-Until/Since intro)
- `until_unfold_thm`, `since_unfold_thm` (current-time unfolding from BX5+BX9)
- `until_unfold_X`, `since_unfold_Y` (X/Y-wrapped unfolding)
- `until_intro`, `since_intro` (key rules: X(ψ ∨ (φ ∧ (φ U ψ))) → φ U ψ)

Closed 2 sorries in `SuccRelation.lean`:
- `until_unfold_in_mcs` — replaced with `until_unfold_X`
- `since_unfold_in_mcs` — replaced with `since_unfold_Y`

Closed 4 sorries in `DeterministicFMCS.lean`:
- `backward_until_chain` base case and inductive case (lines 371, 395)
- `backward_since_chain` base case and inductive case (lines 427, 451)

### Phase 2 — Parameterized Infrastructure (PARTIAL)

Created `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` with 6 sorry-free theorems:
- `backward_until_reflexive` / `backward_since_reflexive` (base cases)
- `backward_until_from_step` / `backward_since_from_step` (full backward, parameterized)
- `backward_until_coherent` / `backward_since_coherent` (BFMCS wrappers, parameterized)

All parameterized on a "step transfer" hypothesis that existing chain constructions cannot discharge.

### Phase 3 — Blocked (No Changes)

Thorough analysis revealed fundamental G-lift incompatibility:
- Until formulas `(φ U ψ) ∈ M` do NOT satisfy `G(φ U ψ) ∈ M` in general
- Enriched seed consistency argument requires G-lift for all seed elements
- Adding Until formulas to seed breaks consistency proof
- Five alternative approaches investigated and rejected

## Fundamental Blocker

Both Phases 2 and 3 converged on the same root cause: **Until formulas are not G-liftable**. The existing chain constructions (dovetailed, SuccChain) build successors via `g_content(M)` seeds, relying on the G-lift property `G(α) ∈ M → α ∈ next(M)`. Since Until formulas lack this property, they cannot be preserved across chain positions.

This means `until_since_coherent` requires a fundamentally new chain construction — one that either:
1. Uses a non-G-lift consistency argument for enriched seeds
2. Uses a quasimodel/filtration approach avoiding intra-family witnesses
3. Restructures the coherence predicate to use bundle-level (cross-family) witnesses

## Files Modified

- `Theories/Bimodal/Theorems/TemporalDerived.lean` — 12 new theorems
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — 2 sorries closed
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` — 4 sorries closed
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — new file, 6 parameterized theorems

## Verification

- Build: Pass (`lake build` succeeds after each wave)
- No new sorries or axioms introduced
- 6 sorries closed net

## Team Metrics

| Metric | Value |
|--------|-------|
| Total phases | 4 |
| Phases completed | 1 |
| Phases partial | 1 |
| Phases blocked | 1 |
| Phases not reached | 1 |
| Waves executed | 2 of 3 |
| Max parallelism | 2 |
| Debugger invocations | 0 |
| Total teammates spawned | 3 |

## Notes

- Phase 1 exceeded expectations: closed 6 sorries (2 in SuccRelation + 4 in DeterministicFMCS) beyond plan scope
- The G-lift incompatibility is a fundamental theoretical issue, not an implementation gap
- The parameterized backward infrastructure (Phase 2) is ready to use once a suitable chain construction exists
- Recommend new research task to explore alternative chain constructions for Until/Since preservation
