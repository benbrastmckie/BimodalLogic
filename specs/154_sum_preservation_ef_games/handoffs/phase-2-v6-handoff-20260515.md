# Phase 2 Handoff: build_bicompat Recursive Construction

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778906163_d56272
**Timestamp**: 2026-05-15
**Status**: Phase 1 COMPLETED, Phase 2 IN PROGRESS

## What Was Done

### Phase 1 (COMPLETED) - Deviations from Plan

The plan called for 3 separate helpers (orderedSum_order_same_component, orderedSum_order_cross_component, sum_atoms_from_component_nf). Instead, the implementation took a different approach:

1. **cast_lt_iff** (line ~283): Cast transport lemma for comparing elements across component index equalities. `subst h; rfl`.

2. **CompData structure** (line ~289): Per-component NF state tracking with fields: `sz`, `eM`, `eN`, `agree`, `bound`, `consistent`. The `consistent` field uses the `h ▸ (env_M p).2 = eM j q` pattern to handle dependent casts.

3. **sum_atoms_one_var** (line ~314): Atom agreement at n=1 from component NF. Uses `atomKind_one_pred_only` to eliminate order atoms.

4. **orderedSum_order_fwd_via_comp** (line ~349): Forward order transfer `⟨j,c⟩ < env_M p ↔ ⟨j,c'⟩ < env_N p` using CompData consistency and `atom_agreement_from_nf`. Cross-component case reduces to index comparison; same-component case uses `cast_lt_iff` + component NF order atoms.

5. **orderedSum_order_bwd_via_comp** (line ~399): Backward order transfer `env_M p < ⟨j,c⟩ ↔ env_N p < ⟨j,c'⟩`. Symmetric to forward.

6. **build_bicompat** (line ~449): Started. Forward oracle step works:
   - `component_extend_fwd` call compiles with correct depth rewriting
   - `nf_agreement_monotone` extracts depth-0 agreement for atom extraction
   - Predicate agreement via `atom_agreement_from_nf(.pred p 0)`
   - Order forward/backward via `orderedSum_order_fwd/bwd_via_comp`
   - ALL above compile without sorry

### Phase 2 (IN PROGRESS) - Remaining in build_bicompat

Two sorry sites remain in build_bicompat:

1. **Line 520** (recursive BiCompat at depth d): Need to construct updated CompData for extended environments `(Fin.cons ⟨j,c⟩ env_M, Fin.cons ⟨j,c'⟩ env_N)` and call IH.

   **CompData update for component j**:
   - `sz j → sz j + 1`
   - `eM j → Fin.cons c (cd.eM j)`, `eN j → Fin.cons c' (cd.eN j)`
   - `agree j`: `h_ext_agree` at depth `K = budget - cd.sz j - 1 = budget - (cd.sz j + 1)`
   - `bound j`: need `cd.sz j + 1 < budget`, which holds when `d ≥ 1` (at depth d in the recursion, `budget ≥ d + (n+1) ≥ 2`). When `d = 0`, build_bicompat returns trivial.

   **CompData update for other components j'**:
   - `sz j'` unchanged
   - `eM j'`, `eN j'` unchanged
   - `agree j'` unchanged
   - `bound j'` unchanged

   **Consistency update**:
   - New env position 0 (= ⟨j, c⟩): maps to `eM j 0 = c` (Fin.cons)
   - Old env positions (Fin.succ p): use old consistency with shifted indices

   **Key challenge**: The `if j' = j then ... else ...` split requires DecidableEq on I (available from LinearOrder). Lean's `dite` or `if h : j' = j then ... else ...` pattern.

2. **Line 521** (backward oracle + outer proof): The backward oracle is symmetric to the forward oracle, using `component_extend_bwd` instead of `_fwd`. After having both `oracle_step_fwd` and `oracle_step_bwd`, the outer proof assembles them into the BiCompat constructor.

### Phase 3 (NOT STARTED) - Close Sorry Sites

Once build_bicompat is complete, the 4 sorry sites (lines 670, 692, 717, 737) close via:
```lean
have h_atoms_1 := sum_atoms_one_var ms ms' i a b h_agree_comp
have h_bc := build_bicompat sig k 1 (by omega) _ _ _ h_atoms_1 (initial_cd ...)
exact ⟨⟨i, a⟩, (sum_nf_lift_gen sig k 1 I ms ms' ... _ _ h_atoms_1 h_bc sub_nf).mpr hb_eval⟩
```

Where `initial_cd` constructs CompData with:
- Component i: sz = 1, eM = ![a], eN = ![b], agree from h_agree_comp
- Other components: sz = 0, eM = Fin.elim0, eN = Fin.elim0, agree from h_comp

## Immediate Next Action (Updated)

Fix remaining compilation errors (8 sorries total):

### Priority 1: Fix orderedSum_order_bwd_via_comp (lines 450, 469)
The backward order transfer has 2 sorries where the cast reassembly fails.
The issue: after extracting `hlt_N : eN_j q < c'` from component NF, need to
cast back to `(env_N p).2`-based comparison for the Sigma.Lex conclusion.

Pattern to follow (from orderedSum_order_fwd_via_comp which compiles):
```lean
have hlt_N' : @LT.lt _ (ms' j).carrier_order.toLT c' (h_eq_N ▸ (env_N p).2) := by rwa [hqN]
exact ⟨hidx ▸ heq, (cast_lt_iff h_eq_N c' (env_N p).2).mpr hlt_N'⟩
```
But for bwd, the direction is REVERSED: `eM_j q < c` not `c < eM_j q`.
Need: `(heq ▸ (env_M p).2) < c` → produce `heq ▸ (env_M p).2 < c` as the Lex right disjunct.
This should be: `exact ⟨heq, by rw [hqM]; exact hlt'⟩` or similar.

### Priority 2: Fix CompData `where` syntax (line 533-ish)
The `have cd' : CompData ... where` syntax doesn't work in tactic mode.
Change to explicit structure constructor: `exact CompData.mk ...` or use `refine { ... }`.

### Priority 3: CompData consistency proof (line 572)
Needs case split on `p` (Fin.cases for position 0 vs succ):
- Position 0 (= ⟨j, c⟩): maps to comp_eM j 0 = c (from Fin.cons)
- Position succ k: use old consistency with shifted index, handle the `if j' = j` split

### Priority 4: Backward oracle recursive BiCompat (line 602)
Symmetric to forward oracle. Copy the CompData construction from forward.

### Priority 5: Close 4 original sorry sites (lines 751, 773, 798, 818)
After build_bicompat compiles, apply at each site:
```lean
have h_atoms_1 := sum_atoms_one_var ms ms' i a b h_agree_comp
have h_bc := build_bicompat k 1 (by omega) ... h_atoms_1 (initial_cd ...)
exact ⟨⟨i, a⟩, (sum_nf_lift_gen sig k 1 I ms ms' ... h_atoms_1 h_bc sub_nf).mpr hb_eval⟩
```

## Key Decisions Made

- **CompData over rebuild-from-scratch**: After extensive analysis, confirmed that per-component NF state tracking is necessary. Rebuilding from h_comp gives elements with the same NF characteristic but NOT the same identity, so order atoms don't transfer.
- **Dependent cast handling**: `cast_lt_iff` (`subst h; rfl`) handles the `h ▸ x < y ↔ x < (h.symm ▸ y)` pattern cleanly. `Subsingleton.elim` resolves proof equality issues.
- **Order transfer factored into separate lemmas**: `orderedSum_order_fwd/bwd_via_comp` as standalone theorems avoids code duplication between forward/backward oracles.

## File Locations

- **Source**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- **Plan**: `/home/benjamin/Projects/ProofChecker/specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md`
- **Sorry count**: 6 (2 in build_bicompat + 4 original sorry sites)
