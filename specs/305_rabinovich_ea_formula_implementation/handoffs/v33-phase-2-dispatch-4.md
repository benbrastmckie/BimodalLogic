# Handoff: Task 305 Phase 2 Dispatch 4

## Current State
- Phase 2 IN PROGRESS, 3 sorrys remaining (down from 1 fundamentally unfixable sorry)
- Build passes (`lake build` succeeds)
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (438 lines)

## What Changed
The original sorry at line 521 (forward direction of the IH-based Since/Until formula) was **provably unfixable** because the formula construction using `restrict_inner` + IH + Since/Until fundamentally cannot capture cross-conditions between inner variables and t. The IH produces witnesses relative to x (the Since/Until witness), but the NF also requires conditions between these witnesses and t, which the formula doesn't constrain.

### New Architecture
The succ case of `nf_nvar_exist_depth0_tl` is now factored into `nf_nvar_exist_depth0_tl_succ` with a clean three-way case split:

1. **NF inconsistent** (pair cycle, non-transitive triple, incompatible NF-equal pair): return `Formula.bot`. **FULLY PROVED.**

2. **NF-equal pair with full compatibility** (Case A): merge positions and use IH at reduced arity.
   - **Backward direction (j != free var): FULLY PROVED** -- builds env' from env by composing with skipFin.
   - **Forward direction (j != free var): sorry** (line 237) -- needs to insert duplicate value at position j.
   - **j = free variable sub-case: sorry** (line 217) -- needs symmetric argument merging i instead of j.

3. **Transitive strict total order** (Case B): use `translateEF1` from Translation.lean. **sorry** (line 363).

### Key Decisions
- Added `skipFin`, `skipFin_injective`, `mergeNF` infrastructure for the merge case
- The compatibility check (`h_compat`) requires BOTH predicate and order agreement at merged positions
- The incompatibility sub-case proves the NF is unsatisfiable when positions are NF-equal but have different conditions, using a `iff_bool_eq` helper

## Sorry Inventory

| # | File | Line | Statement | Why Deferred | Next Dispatch |
|---|------|------|-----------|--------------|---------------|
| 1 | NfDepth0Generalized.lean | 217 | Case A, j = free variable | Symmetric to the j != free-var case but merging i instead of j | Mirror the j != free-var proof with skipFin i instead of skipFin j |
| 2 | NfDepth0Generalized.lean | 237 | Case A forward direction | Needs to construct env from env' by inserting duplicate at merged position | Define env from full_val = insertEnv env' t composed with unskipFin, plus duplicate at j |
| 3 | NfDepth0Generalized.lean | 363 | Case B translateEF1 | Needs rank computation infrastructure (rank function, bijection proof, sorted permutation) | Define nf_rank, prove injectivity (using h_trans), build translateEF1 with sorted permutation |

## Immediate Next Action
- **Sorry 1 (line 217)**: Copy the j != free-var proof structure but swap i and j roles. Use `mergeNF sub_nf i` and `skipFin i` instead. The backward direction proof can be directly adapted.
- **Sorry 2 (line 237)**: Define `full_val : Fin (n+2) -> M.carrier` where `full_val(skipFin j k) = insertEnv env' t k` and `full_val(j) = full_val(i)`. Then `env = fun k => full_val ⟨k.val, _⟩`. Show `insertEnv env t = full_val` and verify all atoms using h_compat + h_merged.
- **Sorry 3 (line 363)**: This is the hardest. Define `nf_rank : Fin (n+2) -> Fin (n+2)` as the count of predecessors. Prove it's injective (hence bijective) using h_trans. Use the inverse as the sorted permutation. Build `translateEF1 (n+1) k alpha beta` and prove biconditional using `translateEF1_correct`.

## Key Decisions
- translateEF1 is the CORRECT tool for Case B (confirmed by analysis showing IH-based approach is fundamentally broken)
- The merge approach correctly handles NF-equal positions by reducing arity
- All "NF is unsatisfiable" sub-cases are fully proved
