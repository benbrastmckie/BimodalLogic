# Phase 4 Handoff: NoUnivBurgessR3 Threading

## What Was Done

### PointInsertion.lean (6 sorry stubs closed)
- Added `(h_nubr3 : NoUnivBurgessR3)` parameter to `lemma_2_4`, `lemma_2_6_splitting`, and `lemma_2_7`
- Closed all 6 sorry stubs using the threaded parameter:
  - Line 178: `h_nubr3 A C h_mcs h_C_mcs` (was `sorry`)
  - Lines 2717, 2719: `h_nubr3 A D h_mcs_A h_D_mcs` and `h_nubr3 D C h_D_mcs h_mcs_C`
  - Lines 3596, 3598: same pattern as above
  - Line 3686: `h_nubr3 D C h_D_mcs h_mcs_C`
- Net effect: 0 sorry stubs in PointInsertion.lean (was 6)

### CounterexampleElimination.lean (1 new sorry, net -5)
- `eliminate_C5_counterexample` now creates `h_nubr3 : NoUnivBurgessR3` via sorry and passes it to `lemma_2_4`
- This localizes the `NoUnivBurgessR3` requirement to a single point

## What Remains

### Threading `NoUnivBurgessR3` through the full call chain

The `NoUnivBurgessR3` hypothesis needs to be threaded from `eliminate_C5_counterexample` up through:

1. `eliminate_potential_counterexample` (CounterexampleElimination.lean)
2. `omega_chain` (ChronicleConstruction.lean)
3. `omega_chain_val`, `omega_chain_c0`, `omega_chain_c2'`, `omega_chain_elim_result` (ChronicleConstruction.lean)
4. All `omega_chain_*` functions: `omega_chain_f_eq_elim`, `omega_chain_dom_eq_elim`, `omega_chain_dom_mono`, `omega_chain_f_agrees`, `omega_chain_dom_mono_le`, `omega_chain_f_agrees_le`, `omega_chain_c5_witness`, `omega_chain_c5'_witness`, `omega_chain_c4_witness`, `omega_chain_c4'_witness`
5. All `limit_*` functions: `limit_dom`, `limit_f`, `limit_f_eq`, `limit_c0`, `limit_f_zero`, `zero_mem_limit_dom`, `limit_satisfies_c5_weak`, `limit_satisfies_c5'_weak`, `limit_F_resolution`, `limit_P_resolution`, `limit_dom_dense`, `limit_satisfies_c4`, `limit_satisfies_c4'`, `limit_g`, `limit_c3`, `limit_c3_interval_subset_point`, `limit_c3_interval_subset_left`, `limit_c3_interval_subset_right`, `limit_forward_G`, `limit_backward_H`, `chronicle_model_exists`
6. `LimitDomSubtype`, `cantor_iso`, `cantor_f`, `cantor_zero`, `cantor_fmcs`, `shifted_cantor_fmcs`, `rooted_cantor_fmcs`, `cantor_bfmcs`, and related instances/theorems (ChronicleToCountermodel.lean)
7. `dd_countermodel_chronicle` (ChronicleToCountermodel.lean)
8. `bx_completeness` (Completeness.lean)

### Estimated effort
- ~35 function signatures need `(h_nubr3 : NoUnivBurgessR3)` added in ChronicleConstruction.lean
- ~20 function signatures need updating in ChronicleToCountermodel.lean
- ~200 call sites need `h_nubr3` threaded through in ChronicleConstruction.lean
- ~80 call sites need updating in ChronicleToCountermodel.lean
- The Completeness.lean change is small (1 function)

### Implementation approach (proven to work)
A Python script approach was tested and successfully built ChronicleConstruction.lean:
1. Add `(h_nubr3 : NoUnivBurgessR3)` to each function signature after `(h_mcs : SetMaximalConsistent A)`
2. Replace all `fn A h_mcs` calls with `fn A h_mcs h_nubr3` using regex
3. Handle special cases (functions with `{m n : Nat}`, functions called with different arg names like `N h_N`, `M₀ h₀`, `v.formulas v.is_mcs`)

### Key challenge: ChronicleToCountermodel.lean
The most complex file due to:
- `cantor_bfmcs` calls `rooted_cantor_fmcs` with different argument patterns (`N h_N`, `N' h_N'`, `M₀ h₀`, `v.formulas v.is_mcs`)
- Instance definitions that use `LimitDomSubtype`
- The `where` syntax in FMCS/BFMCS construction

### NoUnivBurgessR3 provability
`NoUnivBurgessR3` states `∀ A C : Set Formula, SetMaximalConsistent A → SetMaximalConsistent C → ¬burgessR3 A Set.univ C`. This is NOT directly provable from the axiom system (bot_until_elim is sorry'd). It must be threaded as a hypothesis or proved at the construction level using Q-density arguments.

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
