# Claim 1 Boundary Cases Handoff

**Session**: sess_1779494931_55482d
**Date**: 2026-05-23
**Status**: Partial progress on sorry 1 (line 2577) and sorry 2 (lines 2697, 2699)

## What Was Done

### Boundary Cases Proved for Sorry 1 (h_r2_resp_le_d)

**Original sorry** at line 2495 (now line 2577 for the remaining case):
- Goal: `rank_embed(d) < r2_resp -> False`
- **Proved**: When `c_inf = x` (left boundary case), the order agreement from the game gives `r2_resp = rank_embed(x')`. Since `x' <= d`, we get `r2_resp <= rank_embed(d)`, contradicting `rank_embed(d) < r2_resp`.
- **Remaining**: Interior case `x < c_inf` (line 2577) requires K^-(neg D) pipeline.

### Boundary Cases Proved for Sorry 2 (h_r2_resp_ge_d, gap subcase)

**Original sorry** at line 2567 (now lines 2697, 2699):
- Goal: `r2_resp < rank_embed(d), r2_resp is a gap -> False`
- **Proved**: When `c_inf = y` (right boundary case), the order agreement gives `r2_resp = rank_embed(y')`. Since `d <= y'`, we get `rank_embed(d) <= r2_resp`, contradicting `r2_resp < rank_embed(d)`.
- **Remaining**: `c_inf = x` subcase (line 2697) and interior `x < c_inf < y` subcase (line 2699).

## What Remains: Interior Cases

Both remaining sorries require the K^-(neg D) formula pipeline:

1. **Extract single formula D**: A StaviFormula with `stavi_depth D <= r` that:
   - Holds on the N-interval (a_bwd(n), y')
   - Fails cofinally below c_inf in M (at carrier points)
   
2. **Build K^-(neg D)**: `neg(std_snce(.neg (.base .bot), D))` with depth `<= r + 2`

3. **Prove K^-(neg D)(c_inf) = TRUE in M**: D fails cofinally below c_inf, so `Since(top, D)` is FALSE, so `neg(Since(top, D))` is TRUE.

4. **Transfer via hform_r2_1**: K^-(neg D)(r2_resp) = TRUE in N at rank r+2.

5. **Derive contradiction**: If `rank_embed(d) < r2_resp` and there exists a mu-point between them at rank r+2, then `Since(top, D)(r2_resp) = TRUE` (D holds above d), contradicting step 4.

### Key Blocker: Gap Equivalence

When there are NO mu-points between rank_embed(d) and r2_resp at rank r+2 (both are gaps or adjacent), the K^-(neg D) approach doesn't give immediate contradiction. This requires proving that adjacent elements without intervening mu-points agree on all mu-relativized formulas (a "gap equivalence" lemma).

This is the fundamental limitation of the rank r+2 embedding: it introduces new gaps at rank r+2 that don't exist at rank r. GHR93 works at a single rank and doesn't face this issue.

### Alternative Approaches

1. **Materialize C as StaviFormula** (GHR93 Definition 8.8 faithful): Build characteristic formulas for NormalForms, construct X_v = conjunction, C = X_{(a_n,y')} = disjunction. Requires ~200 lines of new infrastructure.

2. **Gap equivalence lemma**: Prove that two extended carrier elements with no mu-points between them agree on all mu-relativized StaviFormula truth. This is a structural induction on StaviFormula (~50-100 lines).

3. **Restructure to avoid rank r+2**: Work at rank r directly, avoiding the gap issue entirely. Requires rethinking the game structure.

## Key Decisions Made

- Used order agreement (same_order_type) from the game to handle boundary cases
- The boundary cases (c_inf = x, c_inf = y) are fully proved without K^-(neg D)
- The interior cases genuinely require formula-level arguments

## File State

- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- Net sorry change: +1 (from 10 to 11)
- Sorries added/moved: 2577 (interior sorry 1), 2697 (c_inf=x gap sorry 2), 2699 (interior gap sorry 2)
- Sorry removed: None (original sorries at 2495, 2567 were restructured)
- Build: Passes
