# Research Report: Task #58 - BRS Blocker Algebraic Analysis

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Mode**: Team Research (3 teammates)
**Session**: sess_1774633914_6725e8

## Summary

All three teammates converge on a critical finding: `neg_not_in_boundary_resolution_set` is **mathematically false** as stated and should be eliminated. The correct path uses a reformulated lemma `neg_not_in_seed_when_in_brs` taking `psi in BRS` as hypothesis, which is immediately provable from four existing lemmas.

## Key Findings

### Critical Discovery: The Theorem is FALSE (All 3 Teammates)

`neg_not_in_boundary_resolution_set` claims: `F(chi) in u -> chi.neg notin BRS`.

This is **false**. The conditions `F(chi) in u` and `chi.neg in BRS` can coexist:
- `chi.neg in BRS` requires `F(chi.neg.neg) notin u` (Fix A1 condition)
- `F(chi)` and `F(chi.neg.neg)` are **syntactically different** in Lean (`chi != chi.neg.neg` because `chi.neg.neg = (chi.imp bot).imp bot`)
- So `F(chi) in u` creates no contradiction with `F(chi.neg.neg) notin u`
- The `drm_closed_under_derivation` path to bridge them requires `F(chi.neg.neg) in deferralClosure`, which fails because deferralClosure is NOT closed under double negation

### Algebraic Root Cause (Teammate A)

`deferralClosure phi = closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi`

Closure properties:
- **Has**: Downward subformula closure, single negation (`psi in subformulaClosure -> psi.neg in closureWithNeg`)
- **Lacks**: Double negation closure (`chi.neg in closureWithNeg` does NOT imply `chi.neg.neg in closureWithNeg`)
- **Consequence**: `F(chi.neg.neg) in deferralClosure` cannot be derived from `F(chi) in u`

### The Theorem Has Exactly ONE Call Site (Teammate B)

At SuccChainFMCS.lean:1456, inside the BRS case of `neg_not_in_constrained_successor_seed_restricted`. At this call site, the proof state has BOTH `h_F_in : F(chi) in u` AND `h_brs : chi.neg in BRS`. The `chi.neg in BRS` hypothesis is strictly stronger and sufficient.

### The Correct Reformulation (Teammate C)

Replace the false theorem with a **provable** one:

```lean
theorem neg_not_in_seed_when_in_brs (phi : Formula) (u : Set Formula) (psi : Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
    psi.neg ∉ constrained_successor_seed_restricted phi u
```

**Proof**: Case-split on which seed component `psi.neg` might be in:
1. `psi.neg in g_content(u)`: Ruled out by `neg_not_in_g_content_when_F_in` (since `F(psi) in u` from BRS membership)
2. `psi.neg in deferralDisjunctions`: Ruled out by `neg_not_in_deferralDisjunctions` (structural)
3. `psi.neg in p_step_blocking`: Ruled out by `neg_not_in_p_step_blocking_restricted` (structural)
4. `psi.neg in BRS`: Ruled out by `brs_mutual_exclusion` (Fix A1)

All four lemmas are **already proven** (no sorries).

## Synthesis

### Conflicts Resolved

No conflicts -- all three teammates independently concluded the theorem is false and should be bypassed. Minor differences in proposed alternatives:
- Teammate A explored extending deferralClosure (higher cost, rejected)
- Teammate B explored reformulating the hypothesis (insufficient alone)
- Teammate C provided the concrete replacement lemma (adopted as recommendation)

### Recommended Action Plan

1. **Delete** `neg_not_in_boundary_resolution_set` (false theorem)
2. **Delete** `neg_not_in_constrained_successor_seed_restricted` (depends on false theorem)
3. **Create** `neg_not_in_seed_when_in_brs` taking `psi in BRS` as hypothesis
4. **Prove** `constrained_successor_seed_restricted_consistent` using the "no contradictory pairs" argument:
   - Non-BRS part of seed is subset of u (consistent)
   - For each BRS element psi, psi.neg is NOT in seed (by new lemma)
   - Therefore no `{psi, psi.neg}` contradictory pairs exist in seed
   - Seed is consistent

### Remaining Challenge

The step "no contradictory pairs + non-BRS subset of consistent u -> seed is consistent" needs formalization. Two approaches:
- **Direct**: Show any finite L subset seed that derives bot can be reduced to a subset of u that derives bot (contradiction)
- **Partition**: Split any derivation of bot from seed into contributions from u-elements and BRS-elements, use deduction theorem to eliminate BRS-elements

Teammate C rates this step as **medium** confidence (provable but requires careful setup).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Closure algebra | completed | high | deferralClosure is NOT closed under double neg -- gap is algebraically fundamental |
| B | Theorem reformulation | completed | high | Theorem is FALSE; only call site has stronger hypothesis available |
| C | Alternative strategies | completed | high | Four existing lemmas suffice; concrete replacement lemma `neg_not_in_seed_when_in_brs` |

## References

- SuccChainFMCS.lean:1306-1324 -- `neg_not_in_g_content_when_F_in` (PROVEN)
- SuccChainFMCS.lean:1332-1346 -- `neg_not_in_deferralDisjunctions` (PROVEN)
- SuccChainFMCS.lean:1356-1366 -- `neg_not_in_p_step_blocking_restricted` (PROVEN)
- SuccChainFMCS.lean:1378-1393 -- `brs_mutual_exclusion` (PROVEN)
- SuccChainFMCS.lean:1411-1440 -- `neg_not_in_boundary_resolution_set` (FALSE - DELETE)
- SuccChainFMCS.lean:1445-1456 -- `neg_not_in_constrained_successor_seed_restricted` (DELETE)
- SuccChainFMCS.lean:1512-1548 -- `constrained_successor_seed_restricted_consistent` (TARGET)
- SuccExistence.lean:284-287 -- `boundary_resolution_set` definition (Fix A1)
- SubformulaClosure.lean:649 -- `deferralClosure` definition
