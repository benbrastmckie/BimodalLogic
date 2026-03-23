# Research Report: Task #48 - Team Research Synthesis

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Mode**: Team Research (2 teammates)
**Session**: sess_1774289228_d767ac

## Summary

Both research teammates independently converged on the same conclusion: the mathematically correct path forward is to **thread RestrictedMCS through the succ_chain_fam construction**, with the decisive sub-question being whether deferral disjunctions (`chi ∨ F(chi)`) stay within `closureWithNeg(phi)`. If not, an augmented closure (still finite, still bounding F-depth) must be defined.

All alternative approaches (direct induction, axiom-based, scope restriction) reduce to the same RestrictedMCS requirement when analyzed to completion. The literature confirms that every temporal logic completeness proof relies on subformula closure bounding.

## Key Findings

### From Teammate A (Mathematical Foundations)

1. **Rigorous confirmation**: An arbitrary MCS can contain all F-iterations. The set `{F^n(phi) | n : Nat}` is consistent, so Lindenbaum extends it to an MCS containing all iterations. The sorry in `f_nesting_is_bounded` CANNOT be filled.

2. **Structural gap identified**: succ_chain_fam elements are built via unrestricted `lindenbaumMCS_set`, not `restricted_lindenbaum`. They carry no finite-closure bound.

3. **Key technical obstacle**: The deferral seed introduces `psi ∨ F(psi)` (deferral disjunctions) that are NOT in `closureWithNeg(phi)`. Simply swapping to `restricted_lindenbaum` breaks the construction.

4. **Proposed solution**: Define `augmentedDeferralClosure(phi)` extending `closureWithNeg(phi)` with deferral disjunctions. This set is still finite, F-depth is still bounded, and the deferral seed lies within it by construction.

### From Teammate B (Alternative Approaches)

1. **Usage site analysis**: `f_nesting_boundary` is called at exactly 3 sites (lines 836, 788, 1103). `bounded_witness` only needs `(d, h_iter_d, h_iter_d1_not)` — it doesn't care HOW d was obtained.

2. **All alternatives collapse**: Five approaches analyzed (RestrictedMCS chain, thread-through, direct induction, restricted truth lemma, axiom-based). All viable approaches reduce to the same RestrictedMCS requirement.

3. **Literature confirmation**: Standard temporal logic completeness proofs (Gabbay, Goldblatt, Venema) ALL use closure-bounded MCS — either via filtration or restricted Lindenbaum. No approach avoids this.

4. **Same decisive sub-question**: Does `closureWithNeg(phi)` contain `chi ∨ F(chi)` when `F(chi) ∈ closureWithNeg(phi)`? This determines whether the fix is 4-6 hours (yes) or 6-9 hours (no, requiring extended closure).

## Synthesis

### Conflicts Resolved

**No substantive conflicts.** Both teammates independently arrived at the same mathematical conclusion and the same implementation recommendation. Minor differences in framing:
- Teammate A framed it as "augmentedDeferralClosure" (new closure type)
- Teammate B framed it as "deferralClosure extension" (extending existing closure)
- These are the same mathematical object with different names

### The Decisive Sub-Question

Before implementation, resolve ONE question:

> Is `chi ∨ F(chi) ∈ closureWithNeg(phi)` when `F(chi) ∈ closureWithNeg(phi)`?

Check `SubformulaClosure.lean` definition. If `closureWithNeg` only contains subformulas + negations, then `chi ∨ F(chi)` is NOT in the closure (it's a disjunction, not a subformula).

**If YES**: Proceed directly. All infrastructure exists. Est. 4-6 hours.
**If NO**: Define `deferralClosure(phi)` = `closureWithNeg(phi) ∪ {chi ∨ F(chi) | F(chi) ∈ closureWithNeg(phi)} ∪ {chi ∨ P(chi) | P(chi) ∈ closureWithNeg(phi)}`. Prove finiteness and F-depth bounding. Est. 6-9 hours.

### Gaps Identified

1. **P-step deferral**: The analysis focused primarily on F-step (forward). P-step (backward) has symmetric deferral disjunctions `chi ∨ P(chi)` that need the same closure treatment.

2. **Constrained successor seed (Task 50)**: Task 50 adds `p_step_blocking_formulas(u) = {H(neg phi) | P(phi) not in u and phi not in u}`. These formulas also need to be checked against the closure. If `H(neg phi)` escapes `closureWithNeg`, the augmented closure must include them too.

3. **g_content correctness**: Both teammates noted `g_content(u) ⊆ closureWithNeg(phi)` holds when `u ⊆ closureWithNeg(phi)` because G(psi) being a subformula implies psi is a subformula. This needs formal verification via `closure_all_future`.

### Recommendations

**Primary**: Implement the augmented closure approach (both teammates' recommendation):

1. **Verify closure question** (15 min): Read `SubformulaClosure.lean`
2. **Define `deferralClosure`** if needed (2-3 hours): Extend closure, prove finiteness and F/P-depth bounding
3. **Thread RestrictedMCS through chain** (3-4 hours): Define restricted forward/backward chain builders using `restricted_lindenbaum` over the (possibly augmented) closure
4. **Swap boundary calls** (1-2 hours): Replace `f_nesting_boundary` → `f_nesting_boundary_restricted` at all 3 usage sites
5. **Update completeness proof** (1 hour): Use restricted Lindenbaum for M0

**Total estimate**: 6-9 hours (accounting for augmented closure if needed)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical Foundations | completed | High (math), Medium (implementation) |
| B | Alternative Approaches | completed | High |

## References

### From Teammate B (Literature)
- Blackburn, de Rijke, Venema - *Modal Logic* (Cambridge Tracts)
- Venema - *Chapter 10: Temporal Logic*
- Stanford Encyclopedia of Philosophy - Temporal Logic
- Imperial College - Canonical models for normal logics (lecture notes)
- Springer - A Note on the Issue of Cohesiveness in Canonical Models

### Codebase References

| File | Key Content |
|------|------------|
| `SuccChainFMCS.lean:706` | `f_nesting_is_bounded_restricted` (provable) |
| `SuccChainFMCS.lean:724` | `f_nesting_boundary_restricted` (provable) |
| `SuccChainFMCS.lean:836,788,1103` | Usage sites needing migration |
| `RestrictedMCS.lean:312` | `restricted_lindenbaum` |
| `RestrictedMCS.lean:481,586` | `restricted_mcs_F_bounded`, `restricted_mcs_P_bounded` |
| `SuccChainCompleteness.lean:139` | Lindenbaum call to replace |
| `SuccExistence.lean:87` | `successor_deferral_seed` definition |
| `SubformulaClosure.lean` | **CHECK THIS**: closure definition for deferral question |
