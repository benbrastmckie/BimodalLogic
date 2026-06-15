# Phase 3 Handoff: Forward Sorry Encoding Analysis

## Status: BLOCKED (encoding flaw confirmed)

## Immediate Next Action
Prove `BracketFormula.holds_of_unordered_distinct` in VecEAFormula.lean (currently sorry'd),
then change `enriched_vecEA2_until` to use BracketFormula k with bracket witnesses.

## Current State
- Phase 2: COMPLETED (backward sorry closed with n=0 bracket + Since encoding)
- Phase 3: BLOCKED (forward sorry L2205 unprovable with current encoding)
- Build: GREEN (3 sorries: L2205 forward, L2362 since, L2450 k>0)
- Permutation lemma statement added to VecEAFormula.lean:371 (sorry'd)

## Key Decisions
1. **Encoding flaw confirmed**: `Formula.snce char_y Formula.top` at x gives `y < x` but
   NOT `t < y`. All alternative temporal encodings at single endpoints were exhaustively
   analyzed and rejected. The flaw is fundamental: no single-endpoint temporal formula
   can express "exists y strictly in (t, x)."

2. **BracketFormula k is the correct fix**: Using `BracketFormula k` where k = number of
   positive between_tx SSNs. The bracket semantics (`IntervalPattern.holds`) guarantees
   witnesses in (t, x) by construction.

3. **Permutation lemma needed for backward direction**: When re-proving backward with
   BracketFormula k, the witnesses from nf_eval are unordered. Since different SSNs have
   mutually exclusive depth-0 char formulas (different nf_y_proj values), their witnesses
   are at distinct model points. The permutation lemma sorts these and constructs the
   bracket holds.

## Analysis Summary: Why Each Alternative Fails

### Since with Formula.top (current)
- Gives y < x but not t < y
- When eq_t twin SSN is positive, Since can find y = t (char_y true at t)

### Since with seg_guard_f
- Same as above; seg_guard on (y, x) doesn't constrain y relative to t

### Since with char_y.neg guard  
- Backward breaks: can't guarantee char_y.neg on (y, x) for arbitrary y in (t, x)

### Bounded Until at t: Formula.untl char_y seg_guard_f
- Gives y > t but not y < x
- Adding (char_1 nf_x).neg to guard gives y <= x but not y < x
- The y = x case is not excludable in general

### Dual encoding (Until at t + Since at x)
- Until gives y1 > t, Since gives y2 < x
- y1 and y2 can be different points; can't show y1 = y2

### Conjunction of single-witness brackets in endpointLeft
- Each bracket includes endRight, coupling all conditions
- Different x' from inner Until vs x from outer Until

## Implementation Plan for Next Dispatch

1. **Prove permutation lemma** (VecEAFormula.lean:371):
   - By induction on n using Finset.min' to extract minimum witness
   - Or by constructing sorted witnesses via Finset.sort on the image
   - Estimated: 50-100 lines

2. **Change enriched_vecEA2_until**:
   - Collect pos_between list (positive between_tx SSNs)  
   - Build BracketFormula with pos_between.length witnesses
   - pointTypes: char formulas indexed by pos_between
   - segmentTypes: all seg_guard (uniform)
   - Remove between_tx Since from right_conjuncts
   - Estimated: 30 lines of definition changes

3. **Re-prove backward** (backward_holdsLeft_of_nf_eval):
   - endRight case: remove between_tx Since subcase (no longer in endpointRight)
   - bracket case: use BracketFormula.holds_of_unordered_distinct
     - witnesses: from h_eval_quant for each positive between_tx SSN
     - injectivity: from mutual exclusivity of depth-0 char formulas
     - h_in: from between_tx_temporal_iff (t < y < x)
     - h_pt: from nf_depth0_char_formula_correct
   - Estimated: 80-120 lines

4. **Prove forward** (forward_nf_eval_of_holdsLeft):
   - Transport through h_eq (Sigma.mk.inj) to unfold VecEA2
   - Provide x as nf_eval witness
   - Atom conditions: from char_1(nf_x) via char_1_correct
   - Quantifier conditions by zone:
     - eq_x, above_x: from endpointRight (same as before)
     - eq_t, below_t: from endpointLeft (same as before)
     - between_tx negative: from bracket seg_guard (contradict witness in (t,x))
     - between_tx positive: from bracket witnesses (IntervalPattern.holds gives
       ordered w_i in (t,x), each satisfying char_y_i, directly providing nf_eval witnesses)
   - Estimated: 100-150 lines

## Sorry Inventory
1. **VecEAFormula.lean:371** — `BracketFormula.holds_of_unordered_distinct` (permutation lemma)
   - Statement is correct; proof needs sorting infrastructure
   - Next dispatch: prove by induction on n with Finset.min'

2. **KampBypass.lean:2205** — `forward_nf_eval_of_holdsLeft` (forward direction)
   - Blocked by encoding flaw; will be closed after encoding change + permutation lemma

3. **KampBypass.lean:2362** — `existPart_succ_n1_bypass_k0_since` (Since case, Phase 4)
   - Independent of Phase 3; same encoding flaw may apply to between_xt positive SSNs

4. **KampBypass.lean:2450** — depth >= 2 bypass (Phase 5, out of scope)
