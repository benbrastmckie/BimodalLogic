# Phase R2 Handoff: Theorem6 Induction Restructuring

## Status
Phase R2 COMPLETED. Theorem6.lean restructured with delta parameter. CaseAnalysis.lean updated minimally to compile.

## What Changed

### Theorem6.lean
- `ghr93_forward_to_backward_core`: removed `char_k` params, added `delta` parameter, calls `ghr93_inductive_step` with `delta := 0`
- `ghr93_forward_to_backward`: removed `char_k` params, calls core with `delta := 0`
- `ghr93_forward_to_backward_rank_varying`: removed `char_k` params, succ case calls `ghr93_inductive_step` with `delta := 4`
- 2 sorry sites: (1) core succ-case IH for rank_embed identity at delta=0, (2) rank-varying succ-case IH for rank promotion at delta=4

### CaseAnalysis.lean (minimal Phase R2 surgery)
- `{delta : Nat}` added to `ghr93_case_I`, `ghr93_case_II`, `ghr93_cases_III_IV`, `ghr93_cases_II_III_IV` signatures
- `ghr93_inductive_step`: added `delta` parameter, IH now produces backward at `r + delta`, removed `h_ih_r2` and `char_k` params
- `obtain_split_point_props` call: now passes `delta` explicitly
- `ghr93_case_II`: body sorry'd (to be rewritten in Phase R3)
- `ghr93_cases_II_III_IV`: dispatch to Case II sorry'd
- `props.sigma` / `props.tau` uses in Case I and Cases III/IV: sorry'd where they fail due to rank mismatch (sigma/tau at r+delta, not r)

## Sorry Sites (Theorem6.lean only)
1. **Line 121**: `fun {x₀ y₀ x₀' y₀'} hle hle' hpt' hfwd => sorry` -- the IH for ghr93_inductive_step in the core's succ case with delta=0. Needs: forward (1+3n) at r -> backward n at r+0 on rank_embed (r<=r+0) positions. The rank_embed (r<=r+0) identity transport is the blocker.
2. **Line 322**: `sorry` -- the IH for ghr93_inductive_step in the rank-varying succ case with delta=4. Needs: forward (1+3n) at r -> backward n at r+4 on rank-embedded positions. This is the rank promotion problem.

## Key Discovery
Lean 4's `revert` for `{x y : ExtM r} {x' y' : ExtN r}` produces forall order `x y x' y'` (grouped by declaration block, not interleaved). But `hxy : x <= y` is reverted AFTER `y'`, so the forall order is `x y x' y' hxy hx'y' ...`. With `h_enough` also reverted (before position vars), the intro pattern must be `intro r h_enough x y x' y' hxy hx'y' ...`. Removing `h_enough` from the revert fixes the ordering: `intro r x y x' y' hxy hx'y' ...`.

## Next Action (Phase R3)
Rewrite CaseAnalysis.lean:
1. Fix `ghr93_case_II` to use tau at rank r+delta for full rank-r type formula transfer
2. Add rank projection for `props.sigma`/`props.tau` in Case I and Cases III/IV
3. Resolve Theorem6.lean sorry sites by providing `rank_embed_id` lemma (delta=0) and rank promotion construction (delta=4)
4. Delete workaround infrastructure (char_k, h_ih_r2, resp_mod, tau_left, etc.)
