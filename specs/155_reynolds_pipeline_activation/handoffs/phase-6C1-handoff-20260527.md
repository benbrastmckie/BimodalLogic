# Phase 6C-1 Handoff: k=0 Base Case Completed

**Date**: 2026-05-27
**Session**: sess_1779910019_ec7547
**Status**: Phase 6C-1 COMPLETED

## What Was Done

Proved the backward direction of `nf_2var_existence_characterizable` at k=0 in `StaviCompleteness.lean`.

### Proof Structure (~160 lines, lines 1868-2026)

1. **Case split on k**: `cases k with | zero => ... | succ k' => sorry`
2. **Formula witness**: `nf_exist_sf atomMap h_surj 0 char_k parent_atoms sub_nf`
3. **Forward direction**: Delegates to existing `nf_exist_sf_forward`
4. **Backward direction** (the new proof):
   - Handle t-consistency failure: formula reduces to `.base .bot` (False), giving contradiction
   - Handle t-consistency success:
     - Unfold `nf_exist_sf`, `NormalForm.atom_assgn` at k=0
     - Set `b_x_lt_t` and `b_t_lt_x` as abbreviations for order booleans
     - Use `change` to convert h_sf to use abbreviations
     - Handle order-both-true impossibility via `h_order_both`
     - Rewrite match discriminants via `h_btx_rw`, `h_bxt_rw`
     - Build helper `extract_witness`: from `sf_disjList` truth at x, extract `nf_x` with atom compatibility and `nf_eval_nf M 0 1 (fun _ => x) nf_x`
     - Build helper `h_pred_t`: t-consistency gives `M.interp p t <-> sub_nf (.pred p 1) = true`
     - Build helper `build_nf_eval`: from predicate hypotheses + order hypotheses, construct `nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf`
     - Build helper `use_witness`: combines `extract_witness` and `build_nf_eval`
     - Four-way case split on `b_t_lt_x, b_x_lt_t`:
       - `(false, false)`: x = t, witness is t
       - `(false, true)`: x < t, Since case
       - `(true, false)`: t < x, Until case  
       - `(true, true)`: impossible

## Key Technical Challenges Overcome

1. **Proof term matching**: `nf_order_0_1._proof_*` terms in h_sf didn't match `by omega`/`by decide` proof terms in `set` definitions. Fixed by using explicit `have` equalities + `rw` instead of `simp`.

2. **if-then-else reduction**: `simp only [↓reduceIte]` doesn't reduce `if ¬false = true then ...` because `¬false = true` isn't literal `True`. Fixed by using `if_pos h_t_cons` for the t-consistency case.

3. **AtomKind matching at k=0**: `NormalForm.atom_assgn` at k=0 is definitionally `id`, but Lean doesn't always see through it. Used `simp only [NormalForm.atom_assgn]` to unfold.

## Remaining Sorry

Line 2033: `sorry` in the `succ k'` case.

Goal:
```
⊢ ∃ x, nf_eval_nf M (k' + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf
```

This requires a different formula construction. The current `nf_exist_sf` with `sf_top` guard is provably insufficient for the backward direction at k>=1.

## Next Action

Implement Phase 6C-2: either replace `nf_exist_sf` formula with interval guard (Approach A) or implement nested temporal formula (Approach C).
