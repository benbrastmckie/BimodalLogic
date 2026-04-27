# Research Report: Task #107 — Remove rebuild_g, Direct g-Construction per Burgess

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777305155_e44ec6

## Summary

Four teammates converged on the correct architecture: remove `rebuild_g` (which depends on the false `burgessR3Maximal_exists_general`) and construct g-values directly within each elimination function per Burgess. The limit_g-as-intersection definition is WRONG for FUC — it must be the limit of finite-stage g-values via immutability (Burgess Claim 2.11 uses g(x,y) directly, not the f-intersection). The implementation requires modifying all 7 elimination functions to produce proper g-values for new adjacent pairs.

## Key Findings

### 1. rebuild_g Must Be Replaced, Not Patched (A, B, D confirmed; C's concern resolved)

**Teammate C** correctly noted that removing rebuild_g breaks the C4 hard case (which needs c2'). But the fix is NOT to patch `burgessR3Maximal_exists_general` — it's to have elimination functions construct g-values directly, so c2' comes from the construction rather than from a post-hoc wrapper.

**The correct flow**: omega_chain step n+1 calls `eliminate_potential_counterexample`, which returns an EliminationResult carrying both the new chronicle AND c2' for new adjacent pairs. No rebuild_g wrapper needed.

### 2. Current Elimination Functions Set g' = chi.g Unchanged (B confirmed)

Every elimination function currently sets g to the input chronicle's g verbatim. The `g_agrees` and `g_ext` fields are all trivially `rfl`. This means:
- No elimination function actually constructs g-values for new pairs
- All g-construction was delegated to `rebuild_g`
- The fix requires modifying all 7 functions

### 3. limit_g Must Be Limit of Finite-Stage g, NOT Intersection (D confirmed from Burgess)

Burgess Claim 2.11 uses g(x,y) directly — the guard beta comes from g(x,y) and C3 propagates it to intermediate f(z). The intersection definition `{phi | forall y between x and z, phi in f(y)}` is tautological for the FUC guard (it contains phi only if phi is already at every intermediate point, which is what we're trying to prove).

**Correct limit_g**: `limit_g(x,y) = (omega_chain_val N).g(x,y)` where N is the first stage with both x,y in the domain. This was the definition from Phase 3's first session (before it was replaced with the intersection).

### 4. Two Problems, One Fix (C correctly identified)

- **Problem 1** (C4 at finite stages): needs BurgessR3Maximal at adjacent pairs → fixed by direct g-construction in elimination functions
- **Problem 2** (FUC at limit): needs phi ∈ limit_g(t,s) → fixed by having limit_g be the actual finite-stage g-value (which contains the guard from the C5 seed)

Both are fixed by the same infrastructure: proper g-values in elimination functions, immutability to the limit.

### 5. Context-Specific Seeds per Elimination Type (A confirmed)

| Elimination | New Adjacent Pairs | Seed Source | Method |
|-------------|-------------------|-------------|--------|
| C5 (add endpoint y after all) | (x_max, y) | eta from Lemma 2.4 | `burgessR3Maximal_exists_from_seed` |
| C5' (add endpoint x before all) | (x, x_min) | eta from Lemma 2.4 mirror | `burgessR3Maximal_exists_from_seed` |
| C4 (insert z between x,y) | (x,z), (z,y) replaces (x,y) | burgessR3_absorption on g(x,y) | Splitting |
| C4' (mirror) | Same pattern | Same | Splitting |
| Density (insert z between x,y) | (x,z), (z,y) replaces (x,y) | burgessR3_absorption on g(x,y) | Splitting |
| g_prop (insert z after x) | (x,z) or updates | From g(x, x_next) | Absorption |
| h_prop (insert z before y) | (z,y) or updates | From g(z_prev, y) | Absorption |

### 6. Estimated Implementation Scope (A estimated)

- Modify 7 elimination functions: ~400 lines
- EliminationResult gains c2' field: ~50 lines
- Remove rebuild_g from omega_chain: ~50 lines
- Revert limit_g to stage-based definition: ~30 lines
- Prove g-immutability for new g-values: ~100 lines
- Close FUC with proper limit_g: ~50 lines
- Total: ~700-800 lines

## Recommendations

### Implementation Plan

**Phase A**: Remove rebuild_g, add c2' to EliminationResult, revert limit_g to stage-based definition. Delete `burgessR3Maximal_exists_general` (false theorem). This will temporarily break the build.

**Phase B**: Modify C5/C5' elimination to construct g-values via `burgessR3Maximal_exists_from_seed`. These are the simplest — only one new adjacent pair.

**Phase C**: Modify C4/C4' elimination to split g-values via burgessR3_absorption. These need the most care — the C4 hard case proof depends on c2'.

**Phase D**: Modify density/g_prop/h_prop elimination (similar to C4 splitting).

**Phase E**: Prove g-immutability for the new g-values. Restore limit_g_eq.

**Phase F**: Close FUC using proper limit_g with phi in limit_g(t,s) from the C5 seed.

### What NOT to Do
- Do NOT patch `burgessR3Maximal_exists_general` — it's false
- Do NOT use limit_g as intersection of f-values — it's tautological for FUC
- Do NOT leave rebuild_g in any form — it's a shortcut that masks the real construction

## Teammate Contributions

| Teammate | Angle | Key Contribution |
|----------|-------|------------------|
| A | Remove rebuild_g | Detailed removal plan, scope estimate, per-elimination seed sources |
| B | Audit elimination functions | All 7 set g=chi.g (unchanged), all g_ext=rfl, complete function audit |
| C | Critic: validate approach | limit_g intersection is tautological for FUC, C4 needs c2' (both true) |
| D | 2-layer architecture | Burgess uses g(x,y) directly in Claim 2.11, not intersection; limit_g must be stage-based |
