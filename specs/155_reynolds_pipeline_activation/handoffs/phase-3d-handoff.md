# Phase 3d Handoff: Unified K- Argument + h_d_unique Analysis

**Session**: sess_1779565373_9bf0c5
**Phase**: 3d (K- formula construction for Claim 1)
**Status**: PARTIAL (2 sorries closed, 6 remain)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

## What Was Done

### 1. Unified K- Argument (eliminated Case B sorries)

Removed the `by_cases h_cont_c : cont_holds_cross` split in the Claim 1
direction 1 proof (formerly lines ~3275-3754). The Case A/B architecture
had 2 sorries in Case B:
- Case B carrier point at boundary y' (sorry 3)
- Case B gap (sorry 4)

**Fix**: Proved `h_strict_failure` unconditionally (without case-splitting on
cont_holds_cross at c_inf). The proof uses contradiction: if all failures
from `h_cofinal_failure_below_c_inf` were at c_inf itself, then
cont_holds_cross would hold at every mu between s and c_inf. Combined with
`c_inf in S_C_M` (which covers mu above c_inf), this makes s in S_C_M,
giving `c_inf <= s`, contradicting `s < c_inf`.

This is a cleaner argument than the original Case A (which used
`h_cont_c` to derive strict failures) and eliminates Case B entirely.

### 2. Critical Analysis: h_d_unique is UNPROVABLE as stated

Deep analysis revealed that the `h_d_unique` theorem (lines 2755-2859)
is **unprovable from its hypotheses**. The theorem states:

```
For ANY t' in [x', y'] with:
  - same depth-r type as d (ht'_form)
  - same gap/point (ht'_pt, ht'_gap)
  - same boundary correspondence (hx'_t', ht'_y')
=> t' = d
```

**Why it's unprovable**: The hypotheses only give depth-r formula agreement.
The K-(neg D) formula that distinguishes d from t' has depth r+2. At depth r,
d and t' are indistinguishable. No hypothesis in h_d_unique's scope forces
them to agree at depth r+2. The forward game h_mono_left_r1 (rank r+2) IS
in scope but connects c (M-side) with the game response (N-side), not
with an arbitrary t' that happens to have the same depth-r type.

**Mathematical counterexample**: In any sufficiently rich linear order N,
two distinct points d and t' can have the same rank-r type (same depth-r
StaviFormulas). The infimum property of d doesn't prevent other points
from having the same type.

**GHR93 Claim 1 says**: "the game response to c must be d" -- this is about
the SPECIFIC game response, NOT about all elements with the same rank-r
type. The universally quantified h_d_unique is STRONGER than what GHR93
proves.

## Remaining Sorry Inventory (6)

| Line | Category | Description |
|------|----------|-------------|
| 2835 | h_d_unique | d < t' direction (UNPROVABLE as stated) |
| 2859 | h_d_unique | t' < d direction (UNPROVABLE as stated) |
| 5653 | same_order | sigma sub-case (blocked on h_d_unique) |
| 5706 | same_order | tau sub-case (blocked on h_d_unique) |
| 6636 | cases_III_IV | gap detection (Lemma 9 dependency) |
| 6891 | rank_varying | transport via rank_embed |

## Root Blocker: Restructuring d_consistency_left/right

The h_d_unique sorries (2835, 2859) are the root blocker for 4 of the
6 remaining sorries. They cannot be fixed by writing more proof code --
the theorem statement itself is too strong.

### Required Restructuring

**Remove h_d_unique** and prove `d_consistency_left/right` directly using
the rank-(r+2) Claim 1 game argument. Specifically:

1. **Remove** h_d_unique (lines 2755-2859) and its uses (lines 2860-2865)

2. **Modify** d_consistency_left/right to NOT take h_d_unique as parameter.
   Instead, in the interior case (currently lines 1772-1815 of
   d_consistency_left), use h_fwd_r1 to play the rank-(r+2) game directly:
   
   a. Apply h_fwd_r1 with rank_embed(a_pad) at rank r+2
   b. Get rank-(r+2) response a'_r2
   c. Show a'_r2(n) = rank_embed(d) via the Claim 1 K- argument
      (already proved: h_r2_resp_le_d + h_r2_resp_ge_d -> h_r2_eq)
   d. Project the rank-(r+2) winning configuration to rank r
   e. The projected response has d at position n

3. **Challenge**: projecting rank-(r+2) responses to rank r. Carrier points
   project trivially (Sum.inl p is the same at both ranks). Gaps at rank r+2
   may not exist at rank r. However:
   - Position n: rank_embed(d) projects to d (always works)
   - Other positions: may need careful handling or replacement
   - Round 2 responses: carrier points (same at both ranks)
   
4. **Alternative approach**: Instead of projecting, construct the rank-r
   response using the rank-r game h_fwd, then prove position n = d by
   connecting the rank-r and rank-(r+2) games through their shared
   depth-r formula agreement.

### Estimated Effort

- Restructuring d_consistency_left/right: 4-8 hours
- Fixing same_order_type (sigma/tau): 2-4 hours (unblocked by restructuring)
- cases_III_IV: independent, needs Lemma 9
- rank_varying: independent, needs rank_embed transport

## Key Decisions

1. **Unified K- argument**: Removed the Case A/B split, using a cleaner
   contradiction argument for strict failures. This is mathematically
   stronger and eliminates 2 sorries.

2. **h_d_unique analysis**: Identified the fundamental unprovability of
   h_d_unique as stated. This is an architectural issue, not a missing
   lemma. The fix requires restructuring d_consistency_left/right.

## Immediate Next Action

1. Restructure d_consistency_left to use h_fwd_r1 directly (removing
   h_d_unique dependency). See "Required Restructuring" above.

2. After restructuring: h_d_unique block can be deleted, same_order_type
   sorries become closeable.

3. cases_III_IV and rank_varying are independent and can be worked on
   in parallel.
