# Handoff: Phase 3 rebuild_g Removal (Task 107, Plan v20)

## Session
- **Session ID**: sess_1777305935_d9720c
- **Date**: 2026-04-26
- **Agent**: lean-implementation-agent

## What Was Done

### 1. Deleted `burgessR3Maximal_exists_general` (RRelation.lean)
- **Line**: Was at ~1345
- **Reason**: Proved FALSE by counterexample (A with G(p), C with p.neg)
- **Impact**: Removes 1 sorry (the false theorem itself)

### 2. Deleted `rebuild_g` and all helpers (ChronicleConstruction.lean)
- Deleted: `rebuild_g`, `rebuild_g_c0`, `rebuild_g_f`, `rebuild_g_dom`, `rebuild_g_c2'`
- These were lines 143-183, all dependent on the false theorem

### 3. Modified `EliminationResult` (CounterexampleElimination.lean)
- **Removed**: `g_ext` field (extensional g-equality)
- **Added**: `c2'` field (BurgessR3Maximal for all adjacent pairs)
- `g_agrees` retained (old-domain pair g-equality)

### 4. Updated `eliminate_potential_counterexample` (CounterexampleElimination.lean)
- All 7 NOOP branches: `c2' := h_c2'` (sorry-free)
- All 7 actual elimination branches: `c2' := sorry` (7 new sorry sites)
- Removed all `g_ext` field assignments

### 5. Updated `omega_chain` (ChronicleConstruction.lean)
- Changed from: `rebuild_g(eliminate(...))` with `rebuild_g_c0`, `rebuild_g_c2'`
- Changed to: `eliminate(...)` directly with `elim.c0`, `elim.c2'`
- Updated comments to remove rebuild_g references

### 6. Updated `omega_chain_f_eq_elim` and `omega_chain_dom_eq_elim`
- Removed `rebuild_g` from simp calls (now trivial by definition)

## Build Status
- `lake build` succeeds (1097 jobs, 0 errors)

## Sorry Count
- **Before**: 3 sorry (1 false theorem + 2 FUC)
- **After**: 9 sorry (7 c2' in elimination + 2 FUC)
- **False theorems removed**: 1 (`burgessR3Maximal_exists_general`)
- **Net**: +6 sorry, but the false theorem is gone and architecture is correct

## What Remains for Phase 3

### Closing the 7 c2' sorry sites (CounterexampleElimination.lean)

Each sorry site needs proof that the elimination result satisfies c2' (BurgessR3Maximal for all adjacent pairs). The strategy differs by elimination type:

#### C5 forward (line 786): New adjacent pair (x_max, y)
- `y` is added beyond all domain points
- New adjacent pair: (x_max, y) where x_max is the previous maximum
- Need: BurgessR3Maximal(f(x_max), g(x_max, y), f(y))
- Current g(x_max, y) = chi.g(x_max, y) = empty (from singleton)
- **Fix**: Modify `eliminate_C5_counterexample` to set g(x_max, y) using `burgessR3Maximal_exists_from_seed` with seed from Lemma 2.4
- **Blocker**: Need to prove `burgessR(f(x_max), seed, C)` and `burgessRSince(C, seed, f(x_max))` where C is from Lemma 2.4. The counterexample point x may not be x_max.

#### C5' backward (line 824): Mirror of C5
- New adjacent pair: (y, x_min) where y is added before all domain points

#### C4 forward (line 864): New adjacent pairs from splitting
- Inserts z between x and y
- Old pair (x,y) may break into (x,z) and (z,y)
- Need: BurgessR3Maximal for (x,z) and (z,y) from existing g(x,y)
- **Fix**: Use `burgessR3_absorption` on existing BurgessR3Maximal g(x,y)
- **Blocker**: `burgessR3_absorption` lemma does not yet exist

#### C4' backward (line 902): Mirror of C4

#### Density (line 1009): Same as C4 splitting

#### g_prop forward (line 938): Same splitting pattern
#### h_prop backward (line 970): Same splitting pattern

### Key Missing Lemmas

1. **burgessR3_absorption**: If BurgessR3Maximal(A, B, C) and D is an MCS between A and C, then there exist B1, B2 with BurgessR3Maximal(A, B1, D) and BurgessR3Maximal(D, B2, C).

2. **burgessR seed from g_content**: If g_content(A) subset C, derive burgessR(A, seed, C) for some seed. This is needed for C5 where x != x_max.

3. Modification of individual elimination functions (eliminate_C5_counterexample, etc.) to set non-trivial g-values for new adjacent pairs.

## What Remains for Phases 4-5

### Phase 4: limit_g
- Revert limit_g to stage-based definition (currently intersection)
- Prove g-immutability across stages
- Prove limit_c3 from finite-stage C3 + immutability

### Phase 5: FUC closure
- Show guard formula in limit_g from C5 seed construction
- Apply c3_interval_subset_point for intermediate points
- Close 2 sorry sites in ChronicleToCountermodel.lean

## Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
