# Phase 1 Handoff (Round 3): Rank r+1 Parameter Propagated

## What Was Done

Cascading signature change completed. `h_fwd_r1` (rank r+1 strategy via rank_embed) now propagates through:
1. `d_consistency_left` — has h_fwd_r1, interior sorry has access to rank r+1 game
2. `d_consistency_right` — same
3. `obtain_split_point_props` — passes h_fwd_r1 down, constructs h_mono_left_r1
4. `ghr93_inductive_step` — passes h_fwd_r1 down
5. `ghr93_forward_to_backward` — takes h_r1 parameter, passes through induction

Build passes. No sorry count change in ExpressivenessGeneral.lean (still 6).

## Remaining Phase 1 Work

### 1. Claim 1 proof (~80-100 lines per direction)

In d_consistency_left interior case (line ~1160), the proof context has:
- `h_fwd_r1 : ghr93_duplicator_wins M N atomMap (n+1) (r+1) (rank_embed x) ... (rank_embed y')`
- `a_pad_r1` embedded selections at rank r+1
- `a'_r1` response at rank r+1 from playing h_fwd_r1
- Goal: show a'_full(n) = d (at rank r)

GHR93 Claim 1 strategy:
1. Define continuation formula C characterizing d's position
2. C' = ¬C ∨ K⁻¬C has stavi_depth ≤ r+1
3. From rank-(r+1) formula agreement: C'(t_r1) ↔ C'(d_r1)
4. C'(d_r1) holds → C'(t_r1) holds → t_r1 ≤ d_r1
5. If t_r1 < d_r1, contradiction → t_r1 = d_r1
6. Transfer back to rank r

The hard part is defining C and showing it characterizes d. C is the "continuation formula" from obtain_split_point_props — look at `continuation_set` (line 142) for the definition.

### 2. IH sub-interval rank r+1 strategy (line ~3757)

Currently sorry'd. Need to derive a rank-(r+1) strategy on sub-intervals from the full-interval rank-(r+1) strategy. This requires strategy restriction at rank r+1, which uses the same round_mono + restrict machinery but at rank r+1.

### 3. d_consistency_right (symmetric to left)

Same Claim 1 proof with position 0 instead of position n.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
