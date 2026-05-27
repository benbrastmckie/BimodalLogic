# Phase 6C Handoff: nf_2var_existence_characterizable

**Date**: 2026-05-27
**Session**: sess_1779910019_ec7547
**Status**: BLOCKED at Phase 6C-1 (analysis complete, implementation not started)

## Current State

The single sorry at `nf_2var_existence_characterizable` (line 1865 of StaviCompleteness.lean) remains open. No code changes were committed.

## Key Mathematical Analysis

### The Problem

The theorem requires a StaviFormula `sf` such that:
```
∀ M t, (parent_atoms match at t) → 
  (sf truth at t ↔ ∃ x, nf_eval_nf M k 2 (cons x (fun _ => t)) sub_nf)
```

The IH provides `char_k` characterizing depth-k 1-var NFs. The existential is a depth-(k+1) property.

### Why the Current Formula Fails

The current `nf_exist_sf` uses `sf_top` (True) as the Until/Since guard:
```
U(sf_disjList [char_k nf_x | atom-compat nf_x], sf_top)
```

**Forward direction (existence → formula truth)**: PROVED by `nf_exist_sf_forward`.

**Backward direction (formula truth → existence)**: FAILS for k >= 1.

The formula gives us x > t with some compatible 1-var NF nf_x. We need `nf_eval_nf M k 2 (cons x (fun _ => t)) sub_nf`. For k >= 1, this requires the QUANT part of the 2-var NF to match sub_nf.2, but:

1. The 1-var NF of x alone does NOT determine the 2-var NF of (x,t). The 2-var NF also depends on the interval profile between t and x (what depth-k 1-var types exist between t and x) and on what exists outside the interval (above x or below t).

2. The formula provides NO constraints on intermediate points (sf_top is True) and NO constraints on the quant structure.

3. False positives: the formula can be TRUE at t when NO x has the right 2-var NF. This happens when some x has a compatible 1-var type (so the Until formula holds) but the actual 2-var NF of (x,t) differs from sub_nf in the quant part.

### k=0 Base Case

For k=0, the backward direction DOES work because:
- depth-0 2-var NFs have NO quant part (purely atomic)
- The atoms + order are fully determined by: x's predicates (from char_k nf_x), t's predicates (from parent_atoms), and the order (from Until/Since)
- Therefore `nf_exist_sf` has NO false positives at k=0

The proof structure for k=0 was outlined but not completed due to Lean tactic issues.

### k>=1: Approaches Analyzed

**Approach A (Interval Guard, plan's primary)**:
- Replace sf_top with a guard constraining intermediate-point types
- The guard must specify WHICH types are allowed AND which are actually realized
- For k=0,1: works because the quant part at these depths involves depth-(k-1) information that's purely atomic or determined by 1-var types
- For k>=2: the "outside-interval issue" -- points z outside (t,x) are unconstrained by the Until guard, and their contribution to the 2-var NF requires info not captured by the guard
- Report 36 Section 11 concludes: outside-interval issue is REAL for k>=2 in general

**Approach C (Nested Temporal Formula, plan's fallback)**:
- Directly encode the FULL 2-var NF condition using nested temporal formulas
- Each quant entry of sub_nf is encoded by nested Until/Since for different z-positions
- Zero risk (structural recursion), but ~600-800 lines
- Recursion: depth k with 2 vars → depth k-1 with 3 vars → ... → depth 0 with k+2 vars
- Each level uses nested temporal connectives to handle the new variable

**Disjunction over depth-(k+1) NFs**: FAILS because:
- We can't build characteristic formulas for depth-(k+1) NFs (that's what we're constructing)
- Using `nf_exist_sf` for each sub_nf' creates false positives that break even the FORWARD direction of the full characteristic formula

**Classical definability argument**: BLOCKED because:
- The theorem connecting StaviFormula truth to NF depth is NOT formalized in EFGames/
- `pigeonhole_definable_formula` exists in Expressiveness/Claim1.lean but importing it would create circular imports (Expressiveness/ imports EFGames/)

**Refined filter approach**: FAILS because:
- "nf_x forces sub_nf" universally is too strong (may be empty for some sub_nf)  
- "nf_x is existentially compatible" is too weak (model-dependent)

### Recommended Implementation Path

1. **Phase 6C-1**: Prove k=0 base case using `nf_exist_sf_depth0` or `nf_exist_sf`. This is straightforward but requires careful Lean tactic work with AtomKind case analysis. Estimated ~80-100 lines.

2. **Phase 6C-2 through 6C-4**: Implement Approach C (nested temporal formula) for k>=1. This avoids all bridge theorem and outside-interval issues. The formula construction recurses on k, increasing the variable count at each step. Both directions follow by structural recursion + `nf_eval_unique`. Estimated ~400-600 lines.

3. Alternative: if Approach C is too many lines, consider implementing the game-theoretic bridge (Corollary 12.8.19) directly within EFGames/, then use the classical definability argument. This requires:
   - Proving that stavi_n_equiv implies NF agreement at corresponding depth
   - Using this to show the existential is definable
   - ~200-300 lines for the bridge, ~100 lines for the definability argument

## Next Action

The immediate next step is: implement the k=0 backward direction proof in `nf_2var_existence_characterizable`. The proof outline:
1. Case-split on `nf_order_0_1 sub_nf` (Until/Since/equality)
2. For Until case: extract x from the Until witness, extract nf_x from the disjunction via `sf_disjList_iff`, use `char_k_correct` to get `nf_eval_nf M 0 1 (fun _ => x) nf_x`, then prove each AtomKind case using atom compatibility + h_atoms + h_t_cons + order from Until
3. Since case: symmetric
4. Equality case: witness is t itself

After k=0 is proved, implement Approach C for k>=1.

## Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- sorry at line 1865
- Plan: `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md`
- Reports: 36, 37, 43 (all in specs/155_reynolds_pipeline_activation/reports/)
