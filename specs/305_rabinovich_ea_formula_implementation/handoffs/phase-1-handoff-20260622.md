# Phase 1 Handoff: prior_exist_transfer_one_dir

## Immediate Next Action
Resolve the zone-3 interval bounding problem for `prior_exist_transfer_one_dir`. Two sub-problems:
1. **Zone-3 witness**: Prove that on Prior structures, when z is between envM_i and envM_j, there exists z' between envN_i and envN_j with matching depth-d 1-var NF type.
2. **K/K_outer mismatch**: Restructure the strong induction at the call sites so the induction variable K is bounded by K_outer, enabling application of prior_exist_transfer_one_dir.

## Current State
- Phase 1 BLOCKED on zone-3 interval bounding
- 5 sorry sites unchanged (1 at prior_exist_transfer_one_dir line 515, 4 at call sites)
- No regressions: PriorComposition.lean compiles with only sorry warnings
- All sorry-free infrastructure preserved

## Key Decisions
1. **Induction on d confirmed**: The proof must use Nat.rec on d (depth) with r universally quantified. No algebraic mechanism (exist_transfer_from_full_agree, nvar_transfer_from_1var_agree) can bridge the depth-1 gap without Prior-UZ/SZ.
2. **cross_extend_bwd_1var provides depth-d 2-var matching** (from h_1var at depth d+1), which gives depth-d 1-var agreement at z/z'. This handles predicates and single-element order but NOT multi-element zone placement.
3. **char_fn + Prior-UZ gives full-depth 1-var matching** without depth loss, but interval bounding (z' < envN_j) is unresolved.
4. **K/K_outer structural issue**: The strong induction in prior_nonconstenv_2var_agree_until/since introduces a universally quantified K that shadows the outer K_outer. Hypotheses h_x, h_t, char_correct are fixed at K_outer depth, but the goal is at K depth. This prevents direct application of prior_exist_transfer_one_dir at the call sites.

## Sorry Inventory
| file | line | statement | assumption | why_deferred | next_dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 515 | prior_exist_transfer_one_dir | Zone-3 witness placement + full proof | Zone-3 interval bounding unresolved; K/K_outer mismatch | Resolve zone-3 bounding; restructure strong induction |
| PriorComposition.lean | 586 | sorry in prior_nonconstenv_2var_agree_until (fwd) | cross_extend gives depth-K 2-var but need depth-(K+1) 3-var | Same zone-3 gap at call site level | Wire via prior_exist_transfer_one_dir once it's proved |
| PriorComposition.lean | 590 | sorry in prior_nonconstenv_2var_agree_until (bwd) | Same as fwd with M/N swapped | Same zone-3 gap | Wire via prior_exist_transfer_one_dir once it's proved |
| PriorComposition.lean | 650 | sorry in prior_nonconstenv_2var_agree_since (fwd) | Same structure as Until | Same zone-3 gap | Wire via prior_exist_transfer_one_dir once it's proved |
| PriorComposition.lean | 654 | sorry in prior_nonconstenv_2var_agree_since (bwd) | Same as fwd with M/N swapped | Same zone-3 gap | Wire via prior_exist_transfer_one_dir once it's proved |

## Possible Approaches for Next Dispatch
1. **3-var compound transfer**: Instead of two independent 2-var transfers (one from each endpoint), use a single transfer that encodes z's relationship to BOTH envM_i and envM_j. This would require a 3-var existential transfer mechanism, which is the very thing being proved (circular at the same depth). However, at LOWER depth (d-1 via IH), this might work.
2. **Temporal interval argument**: Show that if temporal_truth is satisfied at points above and below an interval, then Prior-UZ/SZ guarantees a satisfying point WITHIN the interval. This would require a lemma about "temporal formulas satisfied at boundary points imply existence in interior," which doesn't hold for general temporal formulas.
3. **Strengthened hypothesis**: Add `h_rvar : depth-(d+2) r-var agreement` as a hypothesis to prior_exist_transfer_one_dir, making it more like nvar_transfer_from_1var_agree. This would make the call sites harder to wire (need to construct h_rvar), but the proof itself becomes algebraic.
4. **Restructure strong induction**: Instead of `Nat.strong_induction_on K`, use a different induction structure that explicitly maintains K ≤ K_outer, allowing direct use of char_correct and h_x/h_t at the right depth.
5. **Alternative to prior_exist_transfer_one_dir**: Instead of proving the general lemma, directly prove the biconditional at each call site using the specific structure (r=2, env=[x,t] with known order). The Until zone (t < x) has specific zone structure that might simplify the argument.
