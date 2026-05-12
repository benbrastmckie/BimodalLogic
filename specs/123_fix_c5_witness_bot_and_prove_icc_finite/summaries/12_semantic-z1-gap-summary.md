# Implementation Summary: Semantic Z1 Gap Elimination (v12)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Plan**: plans/12_semantic-z1-gap.md
- **Status**: Partial (Phase 2 blocked)
- **Session**: sess_1778619293_1bf3ac

## What Was Accomplished

### Phase 1: Completed (prior session)
- Added Mathlib imports
- Proved `order_succ_eq` and `order_pred_eq`

### Phase 2: Blocked
- Proved `backward_P` lemma (dual of `backward_F`) at line 1800 of ChronicleToCountermodel.lean
- Documented the gap elimination problem thoroughly with analysis of approaches
- The sorry at line 1816 (originally 1778) in `succ_cofinal` remains

### Phase 3: Not Started (depends on Phase 2)

## Analysis of the Gap Problem

The sorry is in the `else` branch of `succ_cofinal` where `L <= pred(b).val`. In this "gap scenario":
- The orbit `s^[n](a)` converges upward to `L` in reals
- The pred-chain `pred^[k](pb)` is strictly decreasing with values >= `L`
- All orbit points are strictly below all pred-chain points
- The orbit and pred-chain form disconnected succ/pred-closed components

### Approaches Evaluated

1. **Prior-SZ maximum principle**: The plan's primary approach. Requires a discriminating formula (one that holds at all orbit points but fails at some non-orbit point). In the "constant MCS" case (all limit_dom points share the same MCS), no such formula exists. The temporal logic axioms are trivially satisfied with constant MCS labels, so the contradiction must come from the omega-chain construction internals.

2. **Prior-UZ with Until guards**: Until witnesses in the discrete case are always adjacent (immediate successor), making guards vacuous. The Since witnesses similarly resolve to adjacent predecessors.

3. **Syntactic Z1 derivation tree**: `G(Gp -> p) -> (FGp -> Gp)` from Prior-UZ. Estimated at 100+ lines with no published derivation to follow. Research report 14 confirmed intractability.

4. **Stage induction**: The `succ_reaches_dom_N` theorem also has boundary case sorries (lines 1295, 1448) with the same fundamental difficulty.

### Root Cause

The `IsSuccArchimedean` property is an asymptotic/global property (succ-iterates eventually reach any target), while the available temporal axioms provide only local constraints (nearest-point witnesses). Bridging the local-to-global gap requires either:

- A **Z1 axiom** (which IS the bridge principle, saying "G is Noetherian"), obtained either syntactically or added as an axiom with a soundness proof
- A **construction-level argument** showing stage-level connectivity transfers to the limit, requiring deep interaction with `omega_chain_elim_result`, `BurgessR3Maximal`, etc.

## New Infrastructure

- `backward_P`: For `y < x` and `phi in limit_f(y)`, `P(phi) in limit_f(x)`. Proved by contradiction using `limit_backward_H` and `set_consistent_not_both`. Available for future gap elimination attempts.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`: Added backward_P lemma and documentation at the sorry site. Sorry count unchanged (6 total, same as HEAD).

## Recommended Next Steps

1. **Z1 as axiom**: Add `Z1 : Axiom (G(Gp -> p) -> (FGp -> Gp))` with a soundness proof for the discrete case. The soundness proof should use the limit chronicle properties directly (not general model theory, which would create circularity).

2. **Construction-level argument**: Investigate whether `omega_chain_dom_new_unique` and stage-level adjacency can be used to show that the limit succ function is archimedean, bypassing temporal logic entirely.

3. **Plan revision**: Run `/revise 123` with the analysis from this summary to generate a new plan that addresses the "constant MCS" case and the local-to-global gap.
