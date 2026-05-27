# Phase 6B/6C Sorry Closure Handoff (Session 2)

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6B/6C (continued)
**Date**: 2026-05-27
**Session**: sess_1748407200_orch155b
**Status**: PARTIAL -- 1 sorry closed, 2 remain (both require same game-theoretic argument)

## What Was Done

### Sorry #1 Closed: nf_exist_sf_forward final step (~line 1781)

The sorry in `nf_exist_sf_forward` (the forward direction of the existence formula) was
fully closed. The proof:

1. Uses `norm_num` to clean up Fin proof term mismatches in the filterMap
2. Constructs `h_in_list'` (membership in the cleaned filterMap) and `h_disj_at_x` 
   (sf_disjList truth at the witness x)
3. Case-splits on the two order Bools:
   - `true, false` (t < x): constructs `std_untl` witness with `h_disj_at_x` and `sf_top`
   - `false, true` (x < t): constructs `std_snce` witness symmetrically
   - `false, false` (x = t): proves x = t by contradiction with `h_x_lt_t`/`h_t_lt_x`, 
     then rewrites `h_disj_at_x`
   - `true, true`: impossible via `h_order_compat`

### Sorry #2 Restructured: Forward direction of nf_characterizable_by_stavi

The forward direction (`formula truth -> nf_eval_nf`) was fully restructured:

- **Atom part**: Proved from sf_conjList + atomKind_to_sf_literal_correct
- **Quant = false case**: CLOSED via contrapositive of nf_exist_sf_forward
  - From formula truth, extract `not stavi_temporal_truth (nf_exist_sf ...)` 
  - If `exists x, nf_eval_nf ...` held, nf_exist_sf_forward would give truth, contradiction
- **Quant = true case**: SORRY remains -- requires backward direction of nf_exist_sf

### Sorry #3 Structure Clarified

The backward direction quant = false case (`not exists x -> not temporal_truth`) also
requires the backward direction of nf_exist_sf. Cannot be closed by contrapositive of
forward (that gives the wrong direction).

## Critical Analysis: nf_exist_sf_backward is FALSE in isolation

During this session, I discovered that the backward direction of nf_exist_sf 
(temporal formula truth -> exists x with 2-variable NF = sub_nf) is FALSE as a 
standalone lemma. The reason:

The temporal formula `nf_exist_sf` only constrains:
- The 1-variable depth-k type of the witness (via disjunction over atom-compatible NFs)
- The order relation between witness and t (via Until/Since/identity)

But it does NOT uniquely determine the 2-variable depth-k type. Multiple 2-variable NFs 
can share the same pred-at-variable-0 atoms and order. The temporal formula cannot
distinguish between them because char_k only captures 1-variable information.

The backward direction BECOMES true in the context of the full nf_characterizable_by_stavi
theorem because of the game-theoretic argument: the 1-variable depth-k type + order 
DOES determine the 2-variable depth-k type. But proving this requires:
- GHR93 Proposition 7 (composition, already proved in Composition.lean)
- A bridging theorem showing composition implies NF type determination
- Or a direct inductive argument that 1-var type + order determines 2-var type

## Remaining Sorries (2, both in nf_characterizable_by_stavi)

### Sorry at ~line 1903 (forward direction, quant = true)
**Goal**: `stavi_temporal_truth M atomMap t (nf_exist_sf ... sub_nf)` implies
          `exists x, nf_eval_nf M k 2 (Fin.cons x ...) sub_nf`
**Requires**: Backward direction of nf_exist_sf (game-theoretic argument)

### Sorry at ~line 1959 (backward direction, quant = false)  
**Goal**: `not (exists x, nf_eval_nf ...)` implies
          `not (stavi_temporal_truth M atomMap t (nf_exist_sf ... sub_nf))`
**Requires**: Same backward direction (contrapositive form)

### Both sorries require the same core theorem:
"If the temporal formula for nf_exist_sf holds at t, then there exists x such that
the 2-variable NF of (x, t) at depth k equals sub_nf."

This requires bridging from `ghr93_strategy_compose` (Composition.lean, sorry-free) to
NF type determination at the concrete level.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - Lines ~1781-1811: nf_exist_sf_forward sorry replaced with full proof (~30 lines)
  - Lines ~1859-1906: Forward direction of nf_characterizable_by_stavi fully restructured
  - Lines ~1940-1960: Backward direction quant=false clarified with sorry

## Next Actions

1. **Prove a bridging theorem** connecting `ghr93_strategy_compose` to NF type determination:
   "If two points have the same 1-variable depth-k NF, the same 1-variable depth-k NF for t,
   and the same order relation, then they have the same 2-variable depth-k NF."
   This is the missing link between the EF game composition theorem and the concrete NF level.

2. **Use the bridging theorem** to close both remaining sorries.
