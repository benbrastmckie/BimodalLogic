# Phase 4 Handoff: Regression Fix + Edge Case Analysis

**Session**: sess_1779565373_9bf0c5
**Phase**: 4 (regression fix, cases III/IV and rank-varying assessment)
**Status**: PARTIAL (regression fixed for main case; edge cases and independent sorries remain)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

## What Was Done

### 1. Fixed h_strict_failure Regression (Priority 1)

The regression sorry at line ~3331 (v = c_inf sub-case of h_strict_failure) was caused by
a previous agent de-indenting dead code that exposed a latent type error. The original
by_contra argument was mathematically wrong: it attempted to show s in S_C_M, but
cont_holds_cross failing at c_inf (a mu-point in (s, y)) prevents s from being in S_C_M.

**Fix**: Case-split on `cont_holds_cross at c_inf` BEFORE the K- argument:

- **h_cont_c case** (cont_holds_cross holds at c_inf): h_strict_failure's v = c_inf
  branch becomes a contradiction: h_cont_c (cont_holds_cross at c_inf) vs h_not_cont_v
  (from h_cofinal_failure_below_c_inf, which gives ¬cont_holds_cross at v = c_inf).
  The existing K- argument (pigeonhole_strict + Since + formula agreement) then works
  unmodified. **Zero sorries in this case.**

- **¬h_cont_c case** (cont_holds_cross fails at c_inf): Direct formula argument using
  A from ¬cont_holds_cross (depth <= r). Formula agreement transfers A's failure from
  c_inf to r2_resp. For carrier-point r2_resp strictly below rank_embed(y'), the
  contradiction is immediate (A holds at extendPoint(q_r2) from hd_in_SC.2). Two
  edge-case sorries remain:
  - Line 3759: r2_resp = rank_embed(y') forces c_inf = y (boundary edge case)
  - Line 3793: r2_resp is a gap (requires formula materialization per report 39)

### 2. Cases III/IV Assessment (Priority 2)

`ghr93_cases_III_IV` at line 6734 remains sorry'd. The comment says "requires Lemma 9"
but left_formula_gap_detection IS now sorry-free in EFGames.lean. The actual blocker is
implementing the gap case construction: given a_n is a gap, find a matching gap in M
using Lemma 9, construct all response elements, and verify the winning condition.
Estimated: 200-400 lines of new code.

### 3. Rank-Varying Theorem Assessment (Priority 3)

`ghr93_forward_to_backward_rank_varying` at line 6989 remains sorry'd. Needs infrastructure
for transporting game strategies across ranks via rank_embed (no existing lemmas for this).
The derivation from the uniform-rank version requires:
1. From rank-(r+4n) game, derive rank-r game via rank descent
2. Derive h_r1_univ by round/rank monotonicity
Estimated: 100-200 lines of new infrastructure + proof.

## Current Sorry Inventory (9 in ExpressivenessGeneral.lean)

| Line | Category | Description | Status |
|------|----------|-------------|--------|
| 2835 | h_d_unique | d < t' direction | UNPROVABLE as stated |
| 2859 | h_d_unique | t' < d direction | UNPROVABLE as stated |
| 3759 | ¬h_cont_c | boundary r2_resp = rank_embed(y') | Edge case, needs boundary lemma |
| 3793 | ¬h_cont_c | gap r2_resp | Edge case, needs formula materialization |
| 5651 | same_order_type | sigma sub-case | Blocked on h_d_unique |
| 5751 | same_order_type | tau sub-case (start) | Blocked on h_d_unique |
| 5804 | same_order_type | tau sub-case (main) | Blocked on h_d_unique |
| 6734 | cases_III_IV | gap detection | Lemma 9 proved; needs construction |
| 6989 | rank_varying | transport via rank_embed | Needs infrastructure |

## Key Insight: Formula Materialization

The ¬h_cont_c edge cases (lines 3759, 3793) and the h_d_unique restructuring all share
a common root cause: the Lean code represents the continuation predicate cont_holds as
a universally-quantified Prop, while GHR93 uses a concrete formula C (the conjunction
of all depth-r formulas satisfying the interval type). Materializing this conjunction
as a single StaviFormula would unblock multiple sorry sites simultaneously.

Report 39 identifies this as "circular at this proof stage" because the formula C requires
enumerating all depth-r formulas, which requires stavi_expressive_completeness, which
depends on the theorem being proved.

## Immediate Next Action

1. **cases_III_IV** (line 6734): Most tractable independent sorry. Lemma 9 infrastructure
   is ready. Needs gap case construction (left-defined vs right-defined gap, matching gap
   in M, response assembly).

2. **rank_varying** (line 6989): Second priority. Needs rank_embed game transport lemma
   (new infrastructure).

3. **¬h_cont_c edge cases** (lines 3759, 3793): Low priority. Depend on formula
   materialization or dedicated boundary/gap lemmas.

## Build Status

`lake build` passes with 0 errors, only linter warnings (unused variables in other files).
