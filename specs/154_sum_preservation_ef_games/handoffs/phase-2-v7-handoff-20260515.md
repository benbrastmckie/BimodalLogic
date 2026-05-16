# Phase 2-3 Handoff: Build Errors Remaining (No Sorries)

**Task**: 154 - sum_preservation_ef_games
**Session**: sess_1778908496_369f57
**Timestamp**: 2026-05-15
**Status**: Phase 2 IN PROGRESS, Phase 3 COMPLETED (sorry closures applied)

## Key Achievement

ALL `sorry` statements have been removed from NEquivalence.lean. The proof logic is correct (verified via `lean_multi_attempt` at each sorry site). However, the file does not yet compile due to dependent type issues in the surrounding infrastructure code.

## Build Errors (16 total, all in NEquivalence.lean)

### Category 1: `h_nf_rewrite` cast issue (line 508)
**Problem**: `hK_eq ▸ cd.agree j (hK_eq ▸ nf)` has type mismatch because `hK_eq ▸` on the result of `cd.agree` produces wrong type.
**Fix**: Need to use `Eq.mpr` or explicit cast. The issue is `cd.agree j` returns `nf_eval_nf ... (budget - cd.sz j) ... ↔ ...` but we need it at `K + 1 = budget - cd.sz j`.
**Approach**: Try `exact (show ... from cd.agree j (show ... from nf))` with explicit Nat arithmetic casts.

### Category 2: `h_idx'` projection issue (lines 547-548)
**Problem**: `(Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M p).1` can't resolve `.1` projection.
**Fix**: Use `fun p => by cases p using Fin.cases with | zero => rfl | succ k => ...` approach (already attempted, still fails).
**Alternative**: Define `h_idx'` as:
```lean
have h_idx' : ∀ p : Fin (n + 1), ... := by
  intro p
  show (Fin.cons (⟨j, c⟩ : Sigma _) env_M p).1 = ...
  cases p using Fin.cases with
  | zero => rfl
  | succ k => exact h_idx k
```

### Category 3: `oracle_step` + backward oracle structure (lines 488, 591-592)
**Problem**: The `exact ⟨oracle_step, fun j c => ?_⟩` pattern causes "unexpected token 'have'" because the `?_` is term-mode but subsequent code is tactic-mode.
**Fix**: Use `refine ⟨oracle_step, fun j c => ?_⟩` instead of `exact`, or restructure as:
```lean
constructor
· exact oracle_step
· intro j c
  ...
```

### Category 4: `sum_lift_one_var` agree field (lines 790-814)
**Problem**: The `agree` field's `convert h_agree_comp nf using 2` generates subgoals with `funext` that can't close because the `dif_pos rfl` cast in `eM`/`eN` creates opaque terms.
**Fix**: Instead of `convert`, use explicit `Iff.intro` with `show` casts, or restructure `eM`/`eN` to avoid the `show ... from by rw ...` pattern. Consider using `cast` with explicit proofs instead of `show`.
**Alternative**: Define `eM i` directly as `Fin.cons a Fin.elim0` (since when `j' = i`, `sz j' = 1`) and use `Fin.elim0` for `j' != i` (since `sz j' = 0`), with proper `cast` to handle the `if` expression in the `Fin` index.

## Immediate Next Action

1. Fix the `build_bicompat` structure: change `exact ⟨oracle_step, fun j c => ?_⟩` to `constructor` + bullets
2. Fix `h_nf_rewrite`: use explicit `show` coercion or `Nat.succ_sub_one` application
3. Fix `h_idx'`: annotate with explicit sigma type for the `.1` projection
4. Fix `sum_lift_one_var` agree field: simplify `eM`/`eN` representation or use `native_decide`-style cast

## What Already Compiles (verified in isolation via lean_multi_attempt)

- `orderedSum_order_bwd_via_comp` mp branch (lines 428-446)
- `orderedSum_order_bwd_via_comp` mpr branch (lines 447-467)
- `build_bicompat` consistency field (in the forward oracle CompData)
- `build_bicompat` backward oracle (full CompData + recursive call)
- All 4 sorry closures in `sum_nf_agree_sentence` (via `sum_lift_one_var`)

## File Paths

- Source: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- Plan: `/home/benjamin/Projects/ProofChecker/specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md`
