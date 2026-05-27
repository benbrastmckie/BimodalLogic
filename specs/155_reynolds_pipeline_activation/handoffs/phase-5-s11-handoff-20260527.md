# Phase 5 S11 Handoff: Detailed Analysis of 3 Remaining Sorries

## Status: BLOCKED

## Session
Session: sess_1779860853_aa14bdbdcf56

## Summary

Deep analysis of the 3 remaining sorry sites in `ghr93_cases_III_IV` (CaseAnalysis.lean). All three are BLOCKED by fundamental issues that require either new infrastructure or resolution of the sel_pn_ord problem (Phase 3C).

## Sorry Sites

### Sorry #1: Left interval upper bound (line 3328)
**Goal**: `Sum.inr gamma_M <= y`
**Location**: Inside construction of `h_gamma_M_in : inClosedInterval x y (Sum.inr gamma_M)`
**Context**: gamma_M obtained from `left_formula_gap_detection` at m_M in M. m_M is in [x, y] (from forward game). gamma_M is D-definable-on-left gap above m_M.

**Root cause**: `left_formula_gap_detection` finds ANY D-definable-on-left gap above m_M in the ENTIRE extended carrier, not restricted to [x, y]. The existential quantifier in the gap detection formula is global.

### Sorry #2: Right interval lower bound (line 3639)
**Goal**: `x <= Sum.inr gamma_M`
**Location**: Inside construction of `h_gamma_M_in : inClosedInterval x y (Sum.inr gamma_M)`
**Context**: Symmetric to #1 but for the right case.

### Sorry #3: Winning condition assembly (line 3753)
**Goal**: Find `b_resp` with `ghr93_winning_condition (n+1)` for the (n+1)-round backward game
**Context**: Needs to assemble ordering, gap/point, and formula agreement for all (n+4)^2 position pairs. Position n+1 is a gap (gamma_M / gamma_N) instead of a carrier point.

**Root cause**: The ordering between tau selections (a_init(k) / resp_tau(k)) and the gap (gamma_N / gamma_M) requires `sel_pn_ord`, which is itself sorry'd at line 1435 pending Phase 3C.

## Approaches Analyzed for Sorries #1 and #2

### Approach 1: Formula agreement at y vs y' via forward game
- `hform_1` at position 3 gives formula agreement at y vs y' (rank r+4, depth <= r+4)
- `left_formula(sf_verum, D)` has depth <= r+4
- If gamma_M > y, left_formula at y is TRUE (using gamma_M as witness)
- By agreement, left_formula at y' is also TRUE
- This means there exists a D-def-left gap above y' in N
- **Problem**: This is CONSISTENT, not contradictory. There could be other D-def-left gaps above y'.

### Approach 2: Case split y' = Sum.inr gamma_N
- For y' = gamma_N: Use degenerate boundary technique (tau sub-game endpoint agreement, lines 3419-3451 pattern). Y is also a gap by gap_point agreement, and formula agreement transfers. This gives gamma_M at y directly, so gamma_M <= y trivially.
- For y' != gamma_N (gamma_N < y'): Need to find a complement point q_N above gamma_N with q_N <= y'. Challenge forward game with q_N to get q_M. If left_formula at q_N is FALSE and gamma_M > q_M, get contradiction. But can't guarantee left_formula is false at q_N.

### Approach 3: Use gap_detection_unique + formula agreement
- gamma_M is unique D-def-left gap above m_M with D-between(m_M, gamma_M)
- gamma_N is unique D-def-left gap above m_N with D-between(m_N, gamma_N)
- Formula transfer ensures their existence. But uniqueness doesn't constrain interval membership.

### Approach 4: Sub-interval forward game
- `h_r1_univ` gives forward games for any sub-interval at any rank
- Could play on [m_M, y] vs [m_N, y'] to get tighter formula agreement
- **Problem**: `ghr93_duplicator_wins_sub_interval` doesn't exist as a lemma. Would need to be proved.

### Approach 5: GHR93 paper argument (closest gap)
- The paper implicitly uses left_formula to detect the CLOSEST D-definable gap
- Our formalization uses an existential (some gap), not the closest
- **Problem**: Would need to add a "closest gap" property to left_formula_gap_detection or add interval restriction to the gap detection machinery

## Recommended Path Forward

### For Sorries #1 and #2:
**Option A (Quick)**: Add case split on `y' = Sum.inr gamma_N` in the left case and `x' = Sum.inr gamma_N` in the right case. Handle the degenerate sub-case via tau endpoint agreement. For the non-degenerate sub-case, either:
  - Add a `gap_in_interval` lemma to GapDetection.lean that restricts gap detection to an interval
  - Or use a 2-challenge forward game with a complement point to bound gamma_M

**Option B (Proper)**: Add interval-restricted variant of `left_formula_gap_detection` that guarantees the detected gap is within a given interval. This is the cleanest approach but requires modifying GapDetection.lean.

### For Sorry #3:
**Blocked by sel_pn_ord** (line 1435, Phase 3C). Cannot be closed until the ordering between tau selections and the gap/point at position n is resolved. Once sel_pn_ord is available, the assembly is mechanical (~200 lines following Case II pattern, adapted for gap instead of point at position n).

## Key Hypotheses in Scope at Sorry Sites

For sorries #1 and #2:
- `hform_pts`: formula agreement at m_M vs m_N for depth <= r+4
- `hform_1`: formula agreement at all game_tuple positions (x, c, m_M, y vs x', a'_1(0), m_N, y')
- `_hord_1`: order agreement at game_tuple positions
- `_hgp_1`: gap/point agreement at game_tuple positions
- `h_def_gamma_M_left`: gamma_M is D-definable-on-left
- `h_D_bet_gamma_M`: D holds at cut elements between m_M and gamma_M
- `hm_M_in`: m_M in [x, y]
- `hm_lt_gamma_M`: m_M < gamma_M

For sorry #3:
- `hwin_tau`: tau sub-game for positions 0..n-1
- `h_gamma_M_form`: formula agreement at gamma_M vs gamma_N
- `h_gamma_gp`: gap/point agreement at gamma_M vs gamma_N
- `props.h_d_compat_left`: d-compatible forward game
- `props.sigma`, `props.tau`: sub-interval strategies
- All SplitPointProps fields

## Files Modified
None (analysis only).

## Immediate Next Action
1. Resolve sel_pn_ord (Phase 3C) to unblock sorry #3
2. For sorries #1 and #2: implement case split on y' = gamma_N (degenerate sub-case closes immediately; non-degenerate requires gap_in_interval infrastructure)
