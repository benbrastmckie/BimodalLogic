# Handoff: Task 107 Phase 1-2 Progress

**Session**: sess_1777762781_b2f826
**Date**: 2026-05-02
**Status**: In progress - fixing pre-existing build errors

## Completed Work

### Phase 1: Helper Lemma Infrastructure
All 4 planned helper lemmas implemented and verified via LSP:

1. **`d0_guard_untl_val`** - When `untl(B',G') not in B`, d0_guard returns B'. Uses `convert ... symm; simp [Formula.untl.injEq]` to resolve Classical.choose opacity.

2. **`d0_guard_snce_val`** - Same for snce case. Uses `Formula.snce.injEq`.

3. **`collect_guards_mem_of_untl`** - If `untl(B',G') in L` with `B' in B`, `G' in C`, and `untl(B',G') not in B`, then `B' in collect_guards output`. Uses `d0_guard_untl_val`.

4. **`collect_guards_mem_of_snce`** - Same for snce. Uses `d0_guard_snce_val`.

5. **`d0_c_event_list_gamma_mem`** - If `untl(B',G') in L` with `B' in B`, `G' in C`, then `G' in d0_c_event_list output`. Uses `dif_pos` + `Formula.untl.injEq` via Classical.choose_spec.

6. **`d0_a_event_list_alpha_mem`** - If `snce(B',A') in L` with `B' in B`, `A' in A`, then `A' in d0_a_event_list output`. Uses `if_neg` + `dif_pos` + `Formula.snce.injEq`.

Formula constructor injectivity (`Formula.untl.injEq`, `Formula.snce.injEq`) confirmed available as auto-generated.

### Phase 2: Close PointInsertion Sorry Sites 1-4
All 4 sorry sites closed and verified via LSP:

**Site 1 (phi in B)**: `collect_guards_mem_of_B` -> `list_conj_implies_elem` -> chain with `h_ev_b`.

**Site 2 (untl(B',G'))**: Split on `untl(B',G') in B`:
- If yes: same as site 1 via `collect_guards_mem_of_B`
- If no: `collect_guards_mem_of_untl` for B' in b_list, `d0_c_event_list_gamma_mem` for G' in c_list, then `untl_left_mono_deriv` + `untl_right_mono_deriv` for monotonicity.

**Site 3 (snce(B',A'))**: Split on `snce(B',A') in B`:
- If yes: same as site 1
- If no: `Formula.noConfusion` to discharge `h_not_untl`, `collect_guards_mem_of_snce` for B', `d0_a_event_list_alpha_mem` for A' in a_list, `h_ev_snce` + `snce_left_mono_deriv`.

**Site 4 (inconsistent case)**: Full reimplementation of `burgess_D0_finite_subset_consistent_incons`. Same BX chain as consistent case but without BX14:
- BX5 self-accumulation on `untl(b, gamma_hat)`
- BX13 iterated enrichment
- BX10 F-extraction
- All 4 L-element cases handled (B, beta.neg-as-B, untl, snce)

### Sorry Count
- Before: 5 sorries in PointInsertion.lean
- After: 1 sorry (lemma_2_7_seed_consistent, Phase 3)

## Pre-existing Build Errors

The file has ~18 pre-existing build errors from a Lean/Mathlib version upgrade. Key issues:

1. **`rcases` into Type**: `Or.casesOn` cannot eliminate into Type (DerivationTree). Fix: use `by_cases` with DecidableEq instead.

2. **`List.not_mem_nil`**: API changed, now returns `False` not `x not in []`. Fix: use `by simp at h`.

3. **`Sigma` vs `PSigma`**: `Sigma` requires Type components, but `Prop` membership used. Fix: use `Sigma'` and `x'` (PProd).

4. **`simp` no progress**: Various `simp` calls no longer make progress with newer Mathlib. Need investigation.

5. **Missing bracket**: `burgess_zeta_consistent` return type has mismatched parens.

6. **`collect_guards_mem_of_B`**: The `show` pattern may not match after API changes.

## Currently Fixing

Working through each pre-existing error systematically. The fixes are mechanical (API compatibility) and don't affect the mathematical content.

## What Remains

- Finish fixing all pre-existing build errors
- Run `lake build` to verify clean build
- Phase 3: `lemma_2_7_seed_consistent` (BX7 chain, estimated 5 hours)
- Phases 4-5: CounterexampleElimination and ChronicleToCountermodel (estimated 10 hours)
