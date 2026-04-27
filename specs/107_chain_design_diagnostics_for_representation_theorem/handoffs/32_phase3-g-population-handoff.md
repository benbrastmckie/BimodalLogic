# Phase 3 Implementation Handoff: G-Value Population

## Session: sess_1777301335_857c05
## Status: IN PROGRESS (partial, needs continuation)

## What Was Done

### 1. Added `burgessR3Maximal_exists_general` to RRelation.lean (line ~1345)
- Single sorry lemma stating: for any two MCS A, C, there exists B with BurgessR3Maximal(A, B, C)
- This is the ONLY new sorry introduced (consolidates 10 distributed sorries)
- Builds successfully: `lake build Bimodal.Metalogic.BXCanonical.Chronicle.RRelation`

### 2. Added `rebuild_g` helper to ChronicleConstruction.lean (lines ~143-185)
- `rebuild_g`: takes chronicle with c0, assigns BurgessR3Maximal g-values to adjacent pairs
- Uses `Classical.dec` for adjacency decidability
- Proved: `rebuild_g_c0`, `rebuild_g_f`, `rebuild_g_dom`, `rebuild_g_c2'`

### 3. Changed `omega_chain` return type (line ~295)
- Old: `{ chi : Chronicle // chi.c0 }`
- New: `{ chi : Chronicle // chi.c0 AND chi.c2' }`
- Singleton: uses `singleton_c2'` (vacuously true, new lemma at line ~113)
- Step: wraps elimination result with `rebuild_g` before returning

### 4. Added bridge lemmas (lines ~343-365)
- `omega_chain_elim_result`: extracts the pre-rebuild elimination result at step n
- `omega_chain_f_eq_elim`: f at step n+1 equals elimination result's f (rebuild_g preserves f)
- `omega_chain_dom_eq_elim`: dom at step n+1 equals elimination result's dom

### 5. Updated `omega_chain_c0`, `omega_chain_c2'` extractors
- Now use `.property.1` and `.property.2` respectively

### 6. Updated `omega_chain_dom_mono`, `omega_chain_f_agrees`
- Rewritten to go through `omega_chain_dom_eq_elim` / `omega_chain_f_eq_elim`

### 7. Rewrote limit_g with C3-derived definition (line ~920)
- Old: `limit_g(x,y) = g_n(x,y)` for some stage n (relied on g-immutability)
- New: `limit_g(x,y) = {phi | forall w in limit_dom, x < w -> w < y -> phi in limit_f(w)}`
- This automatically satisfies C3 by construction
- Proved `limit_c3` directly from the new definition (no sorry)

### 8. Deleted vacuous g-satisfaction artifacts
- Deleted: `omega_chain_g_ext`, `omega_chain_g_ext_le`, `omega_chain_g_empty`
- Deleted: `omega_chain_c3` (the old version that relied on g-emptiness)
- Deleted: `limit_c2'_vacuous`, `limit_g_is_mcs_vacuous`
- Deleted: `omega_chain_g_agrees_le`
- Deleted: old `limit_g_eq` (was based on g-immutability)

## What REMAINS (Blocking Compilation)

### A. Witness lemma rewrites (8 errors)
The omega_chain witness lemmas (`omega_chain_c5_witness`, `omega_chain_c5'_witness`, `omega_chain_c4_witness`, `omega_chain_c4'_witness`) need updating. They currently fail because:

1. They use `set result := omega_chain_elim_result A h_mcs n` which creates a local alias
2. Then try to match `result.val.dom/f` with `omega_chain_val (n+1).dom/f` via bridge lemmas
3. The type mismatch occurs because `result` has `pc` in its type while `omega_chain_elim_result` has `counterexample_enum ...`, and Lean doesn't automatically unify them after `set`

**Fix approach**: Don't use `set` for both result and pc. Instead:
- Use `omega_chain_elim_result` directly without `set`
- Or use `have` instead of `set` to avoid creating definitional equalities
- Or just use `simp only [omega_chain_val, omega_chain, rebuild_g, omega_chain_elim_result]` to unfold and match

### B. Density witness rewrite (1 error at ~line 809)
Same pattern as above. The `limit_dom_dense` proof constructs an inline elimination result.

### C. References to deleted lemmas
- `limit_g_eq` is referenced by limit_c3 consequences but has been deleted
- The limit_c3 consequences (subset_point, subset_left, subset_right) use the new limit_c3 and should compile fine
- `limit_satisfies_c4` and `limit_satisfies_c4'` at lines ~830-900 may reference old patterns

### D. ChronicleToCountermodel.lean downstream
- May reference `omega_chain_g_empty`, `limit_c2'_vacuous`, etc.
- These need updating or the references need removal

## Key Architectural Decisions

1. **g-values are independently reconstructed at each stage** via `rebuild_g`. There is no g-immutability across stages. This is correct because the limit domain is dense (no adjacent pairs), so limit_g is fully determined by C3 (i.e., by limit_f values at intermediate points).

2. **The single sorry** (`burgessR3Maximal_exists_general`) is the mathematically deep claim. Under Burgess's reflexive semantics it's trivial (any formula in A ∩ C is a seed). Under strict semantics, it requires a careful argument using BX axiom structure.

3. **limit_g is defined by C3 directly**: `{phi | forall y between x and z, phi in limit_f(y)}`. This is the unique definition satisfying C3 for a dense domain.

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (added `burgessR3Maximal_exists_general`)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (major refactor)

## Sorry Count
- Before: 10 (all c2' args) + 2 (FUC) = 12
- After (when complete): 1 (`burgessR3Maximal_exists_general`) + 2 (FUC) = 3
- Current (blocked on compilation): intermediate state with ~8 compilation errors
