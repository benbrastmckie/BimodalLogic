# Handoff: Phase 2 Gap Analysis for succ_cofinal

**Session**: sess_1778605493_67cee2
**Date**: 2026-05-12
**Agent**: lean-implementation-agent (Phase 2, first attempt)

## Current State

The sorry is at line 1684 of `ChronicleToCountermodel.lean` in `succ_cofinal`, in the `else` branch where `L <= pred(b).val`.

### What Was Proven (lines 1613-1675)

The following intermediate lemmas were established and are in the proof context:

1. **`h_lt_pb : forall n, s^[n] a < pb`** -- all orbit points strictly below pred(b)
2. **`orbit_below_L : forall c, a <= c -> (c.val : R) < L -> exists m, s^[m] a = c`** -- every limit_dom point in [a, L) is an orbit point (uses convergence + succ_orbit_convex)
3. **`h_lt_pred_chain : forall k n, s^[n] a < p^[k] pb`** -- all orbit points below all pred-chain points (induction on k using succ_pred cancellation)
4. **`h_pred_chain_strict : forall k, (p^[k+1] pb).val < (p^[k] pb).val`** -- pred-chain strictly decreasing
5. **`h_pred_chain_ge_L : forall k, L <= ((p^[k] pb).val : R)`** -- all pred-chain values >= L

### The Goal

```
case neg
... (all context variables) ...
h_lt_pred_chain : forall (k n : N), s^[n] a < p^[k] pb
h_pred_chain_strict : forall (k : N), (p^[k + 1] pb).val < (p^[k] pb).val
h_pred_chain_ge_L : forall (k : N), L <= (p^[k] pb).val (cast to R)
|- False
```

## Analysis Summary

### Approaches Evaluated and Why They Fail

1. **Simple descent from b to pred(b)**: Works when pred(b).val < L (orbit_below_L gives pred(b) as orbit point, succ_pred gives pb = orbit point, contradiction). But h_pred_chain_ge_L shows this NEVER happens -- the pred-chain stays >= L forever.

2. **Well-founded induction on b**: No well-founded measure decreases from b to pred(b) in general. The rationals are not well-founded. The omega-chain stage of pred(b) can be larger than that of b.

3. **Omega-chain stage induction (succ_reaches_dom_N)**: Has its own sorry sites (boundary cases at lines 1295, 1448) where the new point is outside the range of dom(N). These boundary cases are equally hard.

4. **Finset.card counting on dom(N) intervals**: The count depends on which stage N, and increasing N to include pred(b) can INCREASE the count. Not well-founded.

5. **Pure order-theoretic gap arguments (L = L')**: The omega+omega* gap is order-theoretically consistent. Two monotone sequences converging to the same limit from opposite sides, with no points between consecutive terms, do not contradict each other purely from the order structure.

6. **Prior-UZ / Prior-SZ with next_top**: The discreteness formula next_top holds at every MCS, so Prior-UZ just gives the immediate successor as witness. The guard is vacuously satisfied. No contradiction from next_top alone.

7. **Constant MCS analysis**: If all MCS labels in [a, pb] are identical, Prior-UZ is consistently satisfied (all U-witnesses are immediate successors). So we cannot derive contradiction without showing MCS labels differ across the gap.

### The Core Difficulty

The gap scenario is:
- Orbit points `s^[n](a)` converge to L from below, all in limit_dom
- Pred-chain points `p^[k](pb)` converge to L' >= L from above, all in limit_dom  
- No limit_dom points between the two chains (between consecutive orbit/pred-chain points, no limit_dom by succ/pred definitions)
- The gap (L, L') or (approaching from both sides if L = L') contains no limit_dom points

This is the "omega + omega*" gap that Doets addresses via the Z1 axiom (modified Lob axiom).

### Why Doets/Z1 Is Needed But Hard to Apply

The Doets argument requires:
1. A discriminating formula phi that defines a bounded set with no maximum
2. Z1 (syntactically derivable or semantically valid) to show such sets must have maxima
3. Contradiction

**Problem 1 (discriminating formula)**: Finding phi requires showing the MCS labels differ between orbit and pred-chain. This may be provable from the construction (BurgessR3Maximal gives different extensions for different bracket pairs), but is complex to formalize.

**Problem 2 (circular dependency)**: The plan suggests using Z1 semantically via limit_forward_G. But limit_forward_G gives G(phi) in f(x) => phi in f(y), which is the FORWARD direction of the G truth lemma. The BACKWARD direction (phi at all future points => G(phi) in f(x)) is exactly what the full truth lemma proves, and the truth lemma requires IsSuccArchimedean, which requires succ_cofinal. So the Z1 semantic approach has a circular dependency.

**Breaking the circle**: Derive Z1 SYNTACTICALLY as a DerivationTree from Prior-UZ. Then theorem_in_mcs puts Z1 in every MCS as a formula. Then use modus ponens within the MCS (implication_property) to apply Z1. This avoids needing the backward direction of the G truth lemma.

### Recommended Next Steps

1. **Build DerivationTree for Z1** from Prior-UZ: `G(Gp -> p) -> (FGp -> Gp)`. This is a known derivation in temporal logic (Reynolds 1994, Doets 1987). It requires:
   - Prior-UZ instantiated with `Gp`: `F(Gp) -> U(Gp, neg(Gp))`
   - Temporal K-axiom: `G(p -> q) -> (Gp -> Gq)`
   - Temporal necessitation: `|-p => |-Gp`
   - G-transitivity: `Gp -> G(Gp)` (derivable from other axioms)
   - Propositional reasoning

2. **Find discriminating formula**: Show that in the gap scenario, there exists phi such that phi in limit_f(orbit point) and neg(phi) in limit_f(pred-chain point) (or vice versa). Use Classical.choice on the set-theoretic symmetric difference of the MCS labels.

3. **Apply Doets Claim 10**: With Z1 in every MCS and a discriminating formula, derive contradiction using MCS implication_property and limit_forward_G.

### Alternative Approach

If the DerivationTree for Z1 is too complex, consider:
- **Fallback**: Prove the boundary cases of succ_reaches_dom_N (lines 1295, 1448). These may be solvable by showing that in the discrete case, the successor of max(dom(N)) must be in dom(N+1) (or some nearby stage). This would avoid the gap argument entirely.

### Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`: Added intermediate lemmas (h_lt_pb, orbit_below_L, h_lt_pred_chain, h_pred_chain_strict, h_pred_chain_ge_L) in the else branch of succ_cofinal. Sorry still at line 1684.

### Key API References

- `limit_forward_G` (ChronicleConstruction.lean:1035): G(phi) in f(x) and y > x => phi in f(y)
- `limit_backward_H` (ChronicleConstruction.lean:1089): dual for H
- `limit_c0` (ChronicleConstruction.lean:590): limit_f(x) is SetMaximalConsistent
- `theorem_in_mcs` (MaximalConsistent.lean): derivable formulas in every MCS
- `SetMaximalConsistent.implication_property`: modus ponens in MCS
- `SetMaximalConsistent.negation_complete`: phi or neg(phi) in MCS
- `set_consistent_not_both`: MCS can't contain phi and neg(phi)
- `Axiom.prior_UZ` (Axioms.lean:377): F(phi) -> U(phi, neg(phi))
- `DerivationTree.axiom`: construct axiom tree
- `DerivationTree.temporal_necessitation`: G-necessitation
- `succ_orbit_convex` (ChronicleToCountermodel.lean:1112): orbit convexity
- `limitDomSubtype_succ_pred` / `limitDomSubtype_pred_succ`: succ/pred cancellation
