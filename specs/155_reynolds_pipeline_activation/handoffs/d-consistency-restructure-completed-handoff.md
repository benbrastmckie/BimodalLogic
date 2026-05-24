# Handoff: d_consistency Restructure Completed

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-23
**Status**: Partial -- h_d_unique removed, interior case sorries remain

---

## 1. What Was Changed

### Removed mathematically false h_d_unique

The universal claim `h_d_unique` (previously at line 2755 with 2 sorry sites) has been deleted. This claim asserted that ANY element t' in [x',y'] sharing d's rank-r type, gap/point status, and boundary relationships must equal d. This is mathematically false: two distinct points can share the same rank-r type but differ on K-(negD) of depth r+2.

### Modified d_consistency_left/right signatures

Both `d_consistency_left` (line 1688) and `d_consistency_right` (line 1782) now take a new parameter `h_interior_d` instead of `h_d_unique`:

```lean
(h_interior_d : x' != d -> d != y' ->
  forall a_pad, bounds -> boundary_pos = c ->
  exists a'_full, bounds /\ winning /\ a'_full(boundary) = d)
```

This parameter directly provides the d-consistency conclusion for the interior case, making it the caller's responsibility to prove that SOME response exists with position n = d. Boundary cases (x' = d or d = y') are handled directly in d_consistency_left/right using h_fwd, unchanged.

### Call site changes

At the call site (line 2681), `h_d_unique` block (107 lines, 2 sorries) is replaced with `h_interior_d_left` and `h_interior_d_right` (each with 1 sorry). The new sorries are provable via inline rank_down + K-(negD).

---

## 2. Sorry Count

### Before
- ExpressivenessGeneral.lean: 8 sorries (including 2 at lines 2835, 2859 for h_d_unique)

### After
- ExpressivenessGeneral.lean: 8 sorries (2 h_d_unique replaced with 2 h_interior_d at lines 2708, 2721)

### Key difference
- Old sorries (h_d_unique): **mathematically unprovable**
- New sorries (h_interior_d): **provable** via inline rank_down + K-(negD)

---

## 3. How to Close the New Sorries

### h_interior_d_left (line 2708)

**Goal**: Given Spoiler's a_pad in [x,y] with a_pad(1+3n) = c, produce a'_full in [x',y'] with winning condition AND a'_full(1+3n) = d.

**Approach**: Inline ghr93_duplicator_wins_rank_down's construction:
1. Embed a_pad to rank r+2: rank_embed(a_pad(i))
2. Play through h_mono_left_r1 at rank r+2 to get a'_r2
3. For each i: project a'_r2(i) to rank r (carrier points stay, gaps get r-definability from gap_char_formula transfer)
4. Prove bounds and winning condition (same as rank_down)
5. For position 1+3n: prove a'_r2(1+3n) = rank_embed(d) via K-(negD)
6. Therefore proj(1+3n) = d

**Blocker**: ghr93_duplicator_wins_rank_down is defined at line 6834, AFTER the call site at line 2708. Either:
- (A) Move rank_down earlier in the file (it has no dependencies on lines 2700-6833)
- (B) Inline the ~250-line rank_down proof with K-(negD) tracking addition
- (C) Create a forward declaration pattern

**Recommended**: Option (A) -- move rank_down to before line 2700. Then use it directly, with a separate K-(negD) argument for position tracking. The K-(negD) argument for multi-round games reduces to the 1-round case by showing that formula agreement at the boundary position (game_tuple index 1+3n+1) transfers K-(negD) of depth r+2, which is within the r+2 budget.

### h_interior_d_right (line 2721)

Same as h_interior_d_left but with position 0 instead of 1+3n. The proof is symmetric.

---

## 4. Available Infrastructure

The following infrastructure is available at the call site (line 2700) and needed for the interior proof:

| Item | Description | Available |
|------|-------------|-----------|
| h_mono_left_r1 | (1+3n+1)-round rank r+2 strategy on rank-embedded boundaries | Yes (line 2630) |
| hd_in_SC | d in continuation set S_C | Yes (line 2648) |
| hd_glb | d <= all s in S_C | Yes (from infimum construction) |
| hd_is_inf | d is greatest lower bound of S_C | Yes (from infimum construction) |
| h_cofinal_failure_below_d | cont_holds failures cofinal below d | Yes (line 2661) |
| hc_inf_in_SC_M | c_inf in M-side continuation set | Yes (line 2565) |
| h_cofinal_failure_below_c_inf | M-side cofinal failures | Yes (line 2576) |
| h_pt | point witness in [x', y'] | Yes (parameter) |
| hcd_form | formula agreement c-d at depth r | Yes (from suffices proof) |

---

## 5. Relationship to Other Sorry Sites

### same_order_type sorries (5613, 5666)

Still gated on d_consistency. Once h_interior_d_left/right are closed, the d_consistency output provides the ordering data needed for same_order_type:
- d < p_n <-> c < e_n follows from the winning condition at the boundary position

### Edge cases (3621, 3655)

Independent of d_consistency. These are in the not-cont_holds_cross branch of Claim 1 Direction 1.

---

## 6. Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
  - d_consistency_left: removed h_d_unique param, added h_interior_d param, simplified proof
  - d_consistency_right: same changes
  - Call site: deleted h_d_unique proof block, added h_interior_d_left/right (sorry'd)
