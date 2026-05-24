# Handoff: rank_down Move + h_interior_d Restructure

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-23
**Status**: Partial -- rank_down moved, h_interior_d sorries relocated to suffices block

---

## 1. What Was Changed

### Moved ghr93_duplicator_wins_rank_down Earlier

`ghr93_duplicator_wins_rank_down` (GHR93 Lemma 10, rank part) was at line 6834, after the call sites. Moved to line 1868 (after d_consistency_right, before the Inductive Step Infrastructure section). The theorem has no dependencies on code between its old and new positions.

### Restructured suffices to Include h_interior_d

The `suffices h_exists` in `obtain_split_point_props` previously provided:
- `inClosedInterval x y c`
- `hcd_form` (formula agreement c-d at depth r)
- `hcd_gp` (gap/point agreement)
- `hcd_boundary` (boundary correspondence)

Now also provides:
- `h_interior_d_left_from_suffices` (Claim 1 left: response with d at position 1+3n)
- `h_interior_d_right_from_suffices` (Claim 1 right: response with d at position 0)
- These are constructed inside the suffices proof where c = c_inf is known

**Why the restructuring was needed**: The h_interior_d proofs require the K-(negD) argument at rank r+2. This argument uses:
1. Formula agreement between rank_embed(c_inf) and the game response at depth r+2
2. Cofinal failures below c_inf (for K-(negD_M)) 
3. Cofinal failures below d (for direction 2)

Property 1 requires knowing c = c_inf, which is only established inside the suffices proof (the suffices proves that c_inf satisfies the required properties, then c := c_inf). The old architecture had h_interior_d outside the suffices block, where c was an abstract element.

### Sorry Locations

The two sorries are now at lines ~4412, ~4426 inside the suffices proof of `obtain_split_point_props`, immediately before the `refine` that closes the suffices.

---

## 2. Sorry Count

Before and after: 8 standalone sorries + 1 pattern-match sorry = 9 total.
The two old h_interior_d sorries were replaced by two new ones inside the suffices block.

---

## 3. How to Close the Remaining Sorries

### h_interior_left (line ~4412) and h_interior_right (line ~4426)

**Goal**: Given Spoiler's a_pad in [x,y] with a_pad(1+3n) = c_inf, produce a'_full in [x',y'] with winning condition AND a'_full(1+3n) = d.

**Context available** (inside suffices proof):
- `h_r2_eq : r2_resp = rank_embed d` (the 1-round Claim 1 result)
- `h_cont_transfer` (cont_holds transfer from game Round 2)  
- `h_cofinal_failure_below_d` (cofinal failures below d in N)
- `h_cofinal_failure_below_c_inf` (cofinal failures below c_inf in M)
- `hform_r2_1` (formula agreement at depth r+2 between rank_embed(c_inf) and rank_embed(d))
- `h_fwd_r1` (the full (4+3n)-round game at rank r+2)
- All infimum properties for c_inf and d

**Approach**: Inline ghr93_duplicator_wins_rank_down with position tracking:

1. Construct (1+3n+1)-round rank r+2 game from h_fwd_r1 via round_mono
2. Play with rank_embed(a_pad(i)) to get a'_r2 at rank r+2
3. Prove a'_r2(1+3n) = rank_embed(d) via K-(negD) argument:
   - Direction 1 (a'_r2(1+3n) <= rank_embed(d)): 
     - Extract D_M from pigeonhole_definable_formula_cross_strict on S_C_M
     - K-(negD_M) holds at c_inf, transfer to rank_embed(c_inf) at rank r+2
     - Game formula agreement at position 1+3n: transfer to a'_r2(1+3n)
     - Since(T, D_M) holds at a'_r2(1+3n) if it were > rank_embed(d) (from d in S_C)
     - Contradiction with K-(negD_M)
   - Direction 2 (rank_embed(d) <= a'_r2(1+3n)):
     - Construct h_cont_transfer_multi: for mu p above a'_r2(1+3n), cont_holds at p
     - If a'_r2(1+3n) < rank_embed(d), cofinal failure below d gives contradiction
4. Project all a'_r2 responses to rank r using rank_down's gap-definability argument
5. a'_r2(1+3n) = rank_embed(d) projects to d

**Estimated complexity**: ~250 lines for rank_down projection + ~300-500 lines for K-(negD) argument (shorter than the existing 1000 lines because the interior case simplifies: x < c_inf < y and x' < d < y').

**Alternative approach**: Factor the K-(negD) argument into a reusable lemma that takes formula agreement + infimum properties as parameters. Then call it once for the 1-round case (existing) and once for the multi-round case (new). This would eliminate code duplication but requires significant refactoring of the existing 1-round proof.

---

## 4. What NOT to Change

- The game index arithmetic differs between 1-round (4 positions: x, c_inf, b, y) and multi-round (1+3n+1+3 positions). The K-(negD) argument at specific positions needs adjusted index calculations.
- Do NOT try to use rank_down as a black box for position tracking -- it doesn't expose internal response construction.
- The h_interior_right proof is a mirror of h_interior_left with position 0 instead of 1+3n.

---

## 5. Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
  - Moved ghr93_duplicator_wins_rank_down from line 6834 to line 1868
  - Extended suffices to include h_interior_d_left/right
  - Replaced sorry'd h_interior_d_left/right with references to suffices output
  - Added sorry'd h_interior_left/right inside suffices proof
