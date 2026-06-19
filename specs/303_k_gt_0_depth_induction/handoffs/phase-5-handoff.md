# Phase 5 Handoff: CharPart-Threading Complete, Phase 6 Pending

## Immediate Next Action

Implement the zone-based between-zone transfer in `prior_nonconstenv_2var_agree_until/since`
to close the 4 remaining sorry in PriorComposition.lean (lines 255, 270, 316, 331).

## Current State

- **Phase 5**: COMPLETED. Three FALSE/unprovable lemmas deleted, CharPart params added to 4
  theorems, KampBypass call sites updated. Both PriorComposition and KampBypass build.
- **Sorry count**: PriorComposition.lean has 4 sorry (quantifier parts of K=0 and K>0 for
  until/since). KampBypass.lean has 0 sorry.
- **Build**: `lake build` succeeds.

## Key Decisions Made

1. **CharPart depth mismatch**: `char_kp1` in `existPart_succ_n1_bypass` is at depth `k+1 = k'+2`,
   but `prior_2var_transfer_until` with `K=k'` needs `char_kp1_fn : NormalForm sig (K+1) 1 -> Formula`
   = depth `k'+1`. Resolved by constructing `char_k` from `ih_char` via `Exists.choose` at the
   KampBypass call site. The `ih_char` provides existential CharPart at depth `k = k'+1`, which is
   exactly the right depth.

2. **Parameter placement**: `char_kp1_fn`/`char_kp1_correct` placed after `h_order_N` (not after
   `h_SZ_N` as originally planned), to keep the parameter ordering natural.

## Sorry Inventory

| # | File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|---|------|------|-----------|------------|--------------|---------------|
| 1 | PriorComposition.lean | 255 | K=0 quant of prior_nonconstenv_2var_agree_until | depth-1 3-var existential transfer at [w,x,t]/[w',x',t'] with t<x, t'<x' | Zone-based between-zone transfer requires Prior-UZ/SZ squeeze + depth-0 4-var atomic argument | Implement between_zone_depth0_transfer_until helper |
| 2 | PriorComposition.lean | 270 | K>0 quant of prior_nonconstenv_2var_agree_until | depth-(K'+2) 3-var existential transfer | Same zone-based approach at higher depth, with IH giving partial transfer | Implement using IH + between_zone_succ_transfer_until |
| 3 | PriorComposition.lean | 316 | K=0 quant of prior_nonconstenv_2var_agree_since | mirror of #1 with reversed order | Same approach mirrored | Implement between_zone_depth0_transfer_since helper |
| 4 | PriorComposition.lean | 331 | K>0 quant of prior_nonconstenv_2var_agree_since | mirror of #2 | Same approach mirrored | Implement using IH + between_zone_succ_transfer_since |

## Goal States at Sorry Locations

### Sorry 1 (K=0 until, line 255):
```
⊢ (∃ x_1, nf_eval_nf M 1 (2 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf) ↔
    ∃ x, nf_eval_nf N 1 (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf
```
Available: h_x (depth-2 1-var), h_t (depth-2 1-var), char_kp1_fn (depth-1), Prior axioms, h_order_M (t<x), h_order_N (t'<x')

### Sorry 2 (K>0 until, line 270):
```
⊢ (∃ x_1, nf_eval_nf M (K' + 2) (2 + 1) (Fin.cons x_1 (Fin.cons x fun x ↦ t)) sub_nf) ↔
    ∃ x, nf_eval_nf N (K' + 2) (2 + 1) (Fin.cons x (Fin.cons x' fun x ↦ t')) sub_nf
```
Additionally has: ih (IH), h_x/h_t at depth K'+3, char_kp1_fn at depth K'+2

### Sorries 3-4 are mirrors for the since direction.

## Between-Zone Strategy (from reports/15_charpart-threading-design.md)

1. Zone decomposition on sub_nf order atoms for y vs x and y vs t
2. Outer zones: `cross_extend_bwd_1var` from h_x or h_t
3. Equality zones: direct witness (x' or t')
4. Between zone (t < y < x): 
   - Get c_x from h_x quant (depth-(K+1) 2-var at [y,x]/[c_x,x'], c_x < x')
   - Get c_t from h_t quant (depth-(K+1) 2-var at [y,t]/[c_t,t'], c_t > t')
   - Both have depth-(K+1) 1-var matching y
   - Use Prior-UZ/SZ to find witness between t' and x' with matching NF type
   - At K=0: depth-0 4-var quantifier conditions are purely atomic
   - At K>0: use IH for partial transfer + CharPart for depth boost

## References

- Plan: specs/303_k_gt_0_depth_induction/plans/15_charpart-threading-plan.md
- Research: specs/303_k_gt_0_depth_induction/reports/15_charpart-threading-design.md (sections "RESOLUTION" and "Architectural Conclusion")
- Prior axioms: Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean
- Key helper: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean (cross_extend_bwd_1var)
