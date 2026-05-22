# Phase 1 Handoff: Interface Change (hd_eq_an → hd_le_an)

## What Was Done

Changed `SplitPointProps.hd_eq_an : d = a_bwd ⟨n, ...⟩` to `hd_le_an : d ≤ a_bwd ⟨n, ...⟩`.

- **Case I**: Fixed (2 sites). `props.hd_eq_an ▸ le_refl _` → `props.hd_le_an`. Trivial.
- **Case II**: Sorry'd. The 762-line proof used hd_eq_an at 25+ sites. Old proof preserved in block comment.
- **obtain_split_point_props**: Changed `hd_eq_an := hd_eq_an` to `hd_le_an := le_refl d`.
- **ExpressivenessGeneral.lean**: Compiles cleanly (7 sorry warnings).

## What Remains

### Phase 1 completion (3 steps, can be done incrementally):

1. **Redefine d as infimum** in `obtain_split_point_props` (~60-100 lines). Currently d = a_bwd(n) with hd_le_an = le_refl. Change to d = infimum(continuation_set) with hd_le_an from infimum ≤ member. Uses existing infimum_gap infrastructure.

2. **Prove Claim 1** to close d_consistency_left/right interior (~80-100 lines). With d = infimum, the forward strategy's response at rank r+1 equals d by GHR93 Claim 1. h_fwd_r1 parameter already propagated (commit edee7e956).

3. **Rewrite Case II** to match GHR93 (~300-500 lines). Work with d = infimum, a_bwd(i) > d strictly, construct e_n fresh via formula transfer. This is the largest component.

### Key insight: steps 1 and 2 can be done WITHOUT step 3

With d = infimum:
- d_consistency_left/right become provable via Claim 1 (rank r+1)
- Case II stays sorry'd but is on correct mathematical ground
- Net sorry change: -2 (d_consistency) +0 (Case II was already sorry'd in this commit)

## Current Sorry Inventory (ExpressivenessGeneral.lean)

| Line | Identifier | Status |
|------|-----------|--------|
| 1080 | d_consistency_left | Interior sorry (NOW provable with infimum + Claim 1) |
| 1181 | d_consistency_right | Interior sorry (same) |
| 1351 | obtain_split_point_props | Propagated sorry |
| 2814 | ghr93_case_II | NEW sorry (interface change, needs GHR93-faithful rewrite) |
| 3583 | ghr93_cases_III_IV | Existing sorry (Phase 3) |
| 3693 | ghr93_inductive_step | Propagated sorry |
| 3797 | ghr93_forward_to_backward_rank_varying | Existing sorry (Phase 4) |

## Commit
`698890aaa`
