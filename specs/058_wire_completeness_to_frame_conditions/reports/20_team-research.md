# Team Research Report: Task #58

**Task**: Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1774541340_62d198

## Summary

**Verdict: Bundle-level coherence is the mathematical ceiling for unrestricted MCS, but a DEFERRAL-RESTRICTED construction provides a sorry-free path to family-level coherence and full completeness.**

All four research teammates converged on the same fundamental finding: the sub-case (b) obstruction (when F(phi) exists but G(neg phi) blocks same-family witnesses) cannot be overcome for arbitrary MCS. However, **Teammate D identified a viable path**: using `DeferralRestrictedMCS` over `deferralClosure(phi)` which has bounded F-nesting and sorry-free family-level coherence.

## Key Findings

### From Teammate A (History-Unification)
- The Transfer Theorem `phi in fam'.mcs(s) -> exists s', phi in fam.mcs(s')` is **FALSE in general**
- Shared box-class only implies same Box-formulas, not temporal content
- G-agreement is one-directional (source -> witness), not bidirectional
- The Transfer Theorem would imply the blocked `Z_chain_forward_F` sorry
- **Confidence: HIGH** that history-unification fails

### From Teammate B (Saturation Methods)
- Dovetailed enumeration is mathematically feasible for forward chain
- **Sub-case (b) is the genuine mathematical obstruction**: when `F(phi) in backward_chain(n)` and `G(neg phi) in M0`, G-propagation forces `neg phi` into all forward chain elements, leaving no same-family witness
- Current omega chain only resolves `F_top` (trivial seriality), not specific F-obligations
- Bundle-level coherence (`BFMCS_Bundle`) is the ceiling of what's achievable for arbitrary MCS
- **Confidence: HIGH**

### From Teammate C (Partial Order Construction)
- The partial order approach with linearization is mathematically elegant
- `temp_linearity` axiom correctly enforces linear ordering within families
- However, the construction **converges to the same structure** as `boxClassFamilies`/`BFMCS_Bundle`
- The sub-case (b) obstruction persists: same-family witnesses cannot be guaranteed when G(neg phi) blocks future nodes
- **Confidence: MEDIUM** - clean conceptual framework but doesn't solve the core problem

### From Teammate D (Alternative Strategies) - **BREAKTHROUGH**
- **RECOMMENDED PATH**: Dovetailed Z-Chain via Deferral-Restricted Construction
- The existing `f_nesting_is_bounded_restricted` is **SORRY-FREE**
- The existing `restricted_forward_chain_forward_F` is **SORRY-FREE**
- Key insight: `DeferralRestrictedMCS` over `deferralClosure(phi)` has bounded F-nesting BY CONSTRUCTION
- This gives family-level coherence that plugs directly into `parametric_shifted_truth_lemma`
- **Confidence: HIGH (80%)** for this path

## Synthesis

### Conflicts Resolved

**Conflict 1**: Whether bundle-level vs family-level coherence is required
- *Resolution*: For unrestricted MCS, bundle-level is the ceiling (teammates A, B, C agree)
- *Resolution*: For restricted MCS, family-level is achievable (teammate D identifies the path)

**Conflict 2**: Whether the partial order construction offers a new solution
- *Resolution*: No - it's mathematically equivalent to the existing `boxClassFamilies` construction (teammate C)

**Conflict 3**: Which alternative strategy is most viable
- *Resolution*: Approach 6 (Dovetailed Z-Chain via restriction) > Approach 5 (FMP) > Approach 2 (Modified Truth Lemma)

### Gaps Identified

1. **Missing theorem**: `deferralClosure_closed_under_box_class` - proving that if M0 is closure-restricted, MCSs in the same box-class are also closure-restricted

2. **Wiring gap**: Connecting `DeferralRestrictedMCS` + `restricted_forward_chain_forward_F` to the `BFMCS` structure required by `parametric_shifted_truth_lemma`

3. **Modal coherence for restricted bundle**: Need to verify that `boxClassFamilies` from a restricted base MCS inherits the restriction

### Recommendations

**PRIMARY PATH (Deferral-Restricted Completeness)**:

```
1. Non-provable phi
   |
2. {neg phi} is consistent (not_provable_implies_neg_set_consistent: SORRY-FREE)
   |
3. Extend to DeferralRestrictedMCS M0 over deferralClosure(phi)
   |
4. Build restricted forward/backward chains
   - f_nesting_is_bounded_restricted: SORRY-FREE
   - restricted_forward_chain_forward_F: SORRY-FREE
   |
5. Family-level coherence holds for the restricted chain
   |
6. Build boxClassFamilies from M0 for modal coherence
   - boxClassFamilies_modal_forward/backward: SORRY-FREE
   |
7. Prove families in boxClassFamilies(M0) inherit deferral-restriction
   - NEW THEOREM NEEDED
   |
8. Apply parametric_shifted_truth_lemma (SORRY-FREE given coherence)
   |
9. Get countermodel: neg(phi) true at time 0
   |
10. phi not valid -> completeness by contrapositive
```

**Key Implementation Steps**:

1. **Prove `restricted_boxClassFamilies_temporally_coherent`**: Show that when M0 is a `DeferralRestrictedMCS`, every family in `boxClassFamilies M0` satisfies family-level F/P coherence

2. **Wire to BFMCS**: Create a `construct_restricted_bfmcs` that builds from deferral-restricted base MCS

3. **Connect to completeness theorems**: Replace the blocked `construct_bfmcs` (line 1863) with `construct_restricted_bfmcs` in the completeness chain

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | History-Unification | completed | HIGH | Proved Transfer Theorem is FALSE |
| B | Saturation Methods | completed | HIGH | Confirmed sub-case (b) is irreducible |
| C | Partial Order | completed | MEDIUM | Showed equivalence to existing construction |
| D | Alternative Strategies | completed | HIGH | Identified deferral-restricted path |

## Critical Mathematical Insight

The sub-case (b) obstruction is:
- `F(phi) in fam.mcs(t)` at time t
- `G(neg phi) in M0` in the base MCS
- G-propagation forces `neg phi in fam.mcs(s)` for ALL s >= 0
- Therefore `phi not in fam.mcs(s)` for any s > t (if t >= 0 or if witness must be at s >= 0)
- Same-family F-witness is **mathematically impossible** in this case

**Why deferral-restriction resolves this**:
- `deferralClosure(phi)` is FINITE
- F-nesting depth within the closure is BOUNDED
- The deferred disjunction `phi or F(phi)` eventually resolves because chains cannot defer forever in finite closure
- `f_nesting_is_bounded_restricted` is the key lemma that proves this

## References

### Codebase (Sorry-Free Infrastructure)

| File | Theorem | Status |
|------|---------|--------|
| SuccChainFMCS.lean | `f_nesting_is_bounded_restricted` | SORRY-FREE |
| SuccChainFMCS.lean | `restricted_forward_chain_forward_F` | SORRY-FREE |
| UltrafilterChain.lean | `boxClassFamilies_bundle_forward_F` | SORRY-FREE |
| UltrafilterChain.lean | `construct_bfmcs_bundle` | SORRY-FREE |
| ParametricTruthLemma.lean | `parametric_shifted_truth_lemma` | SORRY-FREE (given h_tc) |

### Codebase (Blocked Sorries)

| File | Theorem | Reason Blocked |
|------|---------|----------------|
| UltrafilterChain.lean:1822 | `boxClassFamilies_temporally_coherent` | Sub-case (b) for arbitrary MCS |
| UltrafilterChain.lean:2485 | `Z_chain_forward_F` | Same obstruction |
| UltrafilterChain.lean:1863 | `construct_bfmcs` | Depends on blocked theorems |

## Next Steps

1. **Research**: Prove `deferralClosure_closed_under_box_class` - if M0 is restricted to closure C, and W has box_class_agree M0 W, is W also restricted to C?

2. **Implementation**: Create `construct_restricted_bfmcs` that:
   - Takes a DeferralRestrictedMCS M0 over deferralClosure(phi)
   - Builds boxClassFamilies M0 for modal coherence
   - Proves each family has family-level temporal coherence via restriction

3. **Wire**: Connect to `dense_completeness_fc`, `discrete_completeness_fc`, and `completeness_over_Int`
