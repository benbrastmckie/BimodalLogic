# Handoff: Task 107 - Phase 1 In Progress

## Current Status

**Date**: 2026-05-03 (Sun)
**Phases**: Phase 1 marked [IN PROGRESS] in plan. Build partially fixed but major architectural issues identified.

## What Was Done

1. **Plan status updated**: Phase 1 changed to [IN PROGRESS]
2. **Early metadata created**: `.return-meta.json` initialized
3. **Build fixes attempted** for `ChronicleConstruction.lean`:
   - Fixed `omega_chain_f_eq_elim` and `omega_chain_dom_eq_elim` proofs
   - Attempted to thread `c2'` through `omega_chain`, but reverted due to massive type-mismatch cascade
   - Reverted omega_chain to original `{ χ : Chronicle // χ.c0 }` with `sorry` for c2' parameter
4. **Source exploration**: Identified all 29 sorries across Chronicle/ directory.

## Critical Blockers Found

### Blocker 1: `eliminate_potential_counterexample` requires `h_c2'`
- Signature: `(χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2') (pc : PotentialCounterexample)`
- But `omega_chain` only tracks `c0`, not `c2'`.
- Reverted threading attempt because it breaks `omega_chain_val` projection chain, `EliminationResult` type parameters, and all downstream proofs.

### Blocker 2: g-values are never constructed in eliminations
- `eliminate_C5_counterexample` and all other eliminations produce chronicles with `g` unchanged (`χ.g`)
- The new point creates adjacent pairs with undefined/zero g-values, breaking c2'
- To fix: Need to construct g-values at NEW adjacent pairs using `burgessR3Maximal_from_g_content_sub`

### Blocker 3: Phase 3 sorries (`h_ev_b`, `h_ev_untl`) in `PointInsertion.lean` (lines 1872–1873)
- These are inside `burgess_D0_finite_subset_consistent_incons`
- Need to derive `event → b` and `event → untl(b, γ_hat)` using BX axioms
- Approach: `event → q` where `q = b ∧ untl(b, γ_hat)`, via the enriched event construction + self-accumulated until. Use `lce_imp`/`rce_imp` from conjunction elimination.

### Blocker 4: C4 hard cases (lines 412, 510)
- Require `lemma_2_6_splitting` (available) + BurgessR3Maximal bridging via c2'
- Will resolve only after g-population and c2' threading are fixed.

## Suggested Path Forward

1. **Fix g-population in each elimination function** FIRST (Phase 1 core)
   - C5 forward: use lemma_2_4 output B as g(x,y) for new adjacent (x,y)
   - C5 backward: mirror with lemma_2_4' or past_temporal_witness
   - C4 forward: use lemma_2_6_splitting to get B', B''; assign g(x,z)=B', g(z,y)=B''; update g(x,y) via C3
   - C4 backward: mirror
   - Density: use burgessR3Maximal_from_g_content_sub with f(x), f(y) to get g(x,z) and g(z,y)

2. **After g-population, re-attempt omega_chain c2' threading**
   - Need to change signature of `omega_chain` to `{ χ : Chronicle // χ.c0 ∧ χ.c2' }`
   - All `EliminationResult` projections must be proven first
   - This is a global refactor touching ~15 call sites in ChronicleConstruction.lean

3. **Parallel safe targets while waiting for Phase 1**
   - Phase 3 (`h_ev_b`, `h_ev_untl` in PointInsertion.lean): independent of g-population
   - Phase 6 (`lemma_2_7_seed_consistent`): independent but massive (~5-8 hour task)

## Files Modified So Far
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (reverted; only omega_chain_f_eq_elim and omega_chain_dom_eq_elim changed)

## Files with Most Sorries (priority order)
- `CounterexampleElimination.lean`: 12 sorries (c2' + 2 hard cases)
- `PointInsertion.lean`: 3 sorries (h_ev_b, h_ev_untl, lemma_2_7_seed_consistent)
- `ChronicleConstruction.lean`: several sorry (limit theorems + omega_chain helpers)
- `ChronicleToCountermodel.lean`: 2 sorries (FUC/FSC)

## Context State
Context window is at about 85% and degrading. Recommend spawning child agents:
- Agent A: Fix PointInsertion.lean Phase 3 sorries (independent)
- Agent B: Implement g-population in CounterexampleElimination.lean elimination functions
- Agent C: After A and B succeed, re-thread c2' through omega_chain and fix ChronicleConstruction.lean

## Reference to Plan
`specs/107_chain_design_diagnostics_for_representation_theorem/plans/56_implementation-plan.md`
