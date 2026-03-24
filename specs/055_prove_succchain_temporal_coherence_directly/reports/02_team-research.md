# Team Research Report: Task 55

**Task**: 55 - Prove SuccChain temporal coherence directly
**Date**: 2026-03-24
**Mode**: Team Research (3 teammates)
**Session**: sess_1774386313_93d135

## Summary

All three teammates converge on a critical conclusion: **the restriction-based approach (DeferralRestrictedMCS) is high-risk and should be abandoned** in favor of an algebraic approach that leverages the box-class infrastructure completed in task 48. The key insight is that temporal coherence is an *existential* property that can be proven via Lindenbaum extension, not a *constructive* property requiring bounded F-depth calculation.

## Key Findings

### Universal Agreement (All Teammates)

1. **`f_nesting_is_bounded` is mathematically FALSE** for arbitrary MCS — counterexample: `{F^n(p) | n ∈ ℕ}` is consistent
2. **The restriction-based approach is fragile** — task 48 went through 15 plan versions before abandoning it
3. **The algebraic infrastructure from task 48 provides the tools** for an elegant solution
4. **The sorry flows through**: `f_nesting_is_bounded` → `f_nesting_boundary` → `succ_chain_forward_F` → `SuccChainTemporalCoherent` → `boxClassFamilies_temporally_coherent` → `construct_bfmcs`

### Primary Approach (from Teammate A): Temporal Theory Witness

**Recommended approach**: Adapt the `box_theory_witness_exists` pattern for temporal operators.

1. Define `temporal_theory(M)` = {ψ | G(ψ) ∈ M} (analogous to `box_theory(M)` = {ψ | □(ψ) ∈ M})
2. Prove `temporal_theory_witness_consistent`: If F(φ) ∈ M (MCS), then {φ} ∪ temporal_theory(M) is consistent
3. Extend to full MCS via Lindenbaum's lemma → `temporal_theory_witness_exists`
4. Rewire `boxClassFamilies_temporally_coherent` to use this direct existential proof

**Why this works without f_nesting_is_bounded**:
- **Existential, not constructive** — no F-iteration counting needed
- **Uses Lindenbaum extension** — full negation completeness by definition
- **TF axiom** (□a ≤ G(□a)) ensures box-class agreement preserved across temporal steps
- Follows proven template: `box_theory_witness_consistent` (UltrafilterChain.lean:795-901)

**Estimated effort**: ~180 lines of new code, no new sorries.

### Alternative Approaches (from Teammate C)

**Finite Horizon Argument**: Bound the witness by `t + |deferralClosure(ψ)|`:
- F-iterations within deferralClosure are finite
- Induction on (bound - current_iteration) provides termination
- Avoids DeferralRestrictedMCS machinery

**Risk**: Medium — requires careful F-iteration tracking within deferralClosure, and the formalization of "eventually leaves deferralClosure" has subtleties.

### Task 48 Retrospective (from Teammate B)

**Failed approaches** (15 plan versions):
| Version | Approach | Failure Reason |
|---------|----------|----------------|
| v1-3 | Restricted MCS chain | Deferral disjunctions escape closureWithNeg |
| v5-6 | Fuel-based recursion | Fuel bound weakens in persistence case |
| v9-10 | Boundary resolution sets | Consistency proof circular |
| v12 | DRM negation completeness | closureWithNeg has ONE-LAYER negation only |
| v13 | Weaken bounded-witness | Intermediate lemmas mathematically FALSE |

**The breakthrough (v15)**: Abandon procedural chain enumeration, use algebraic/ultrafilter methods.

## Synthesis

### Conflicts Resolved

**Conflict 1: Sorry status of `boxClassFamilies_temporally_coherent`**
- Teammate A: "transitively depends on the broken lemma"
- Teammate B: Lists it as "proven, no sorry"
- **Resolution**: The theorem IS defined (compiles), but it CALLS `SuccChainTemporalCoherent`, which has `sorryAx` through the `f_nesting_is_bounded` chain. So it compiles but is NOT axiom-free — `#print axioms` will show `f_nesting_boundary` and `p_nesting_boundary`. **Teammate A and C are correct.**

**Conflict 2: Which alternative approach is best**
- Teammate A: Temporal theory witness (Lindenbaum-based existential)
- Teammate C: Finite horizon (deferralClosure-bounded iteration)
- **Resolution**: The temporal theory witness approach is **more elegant and lower risk** because:
  - It operates at the MCS/ultrafilter level with full negation completeness
  - It avoids ANY iteration counting or closure boundary reasoning
  - It directly follows the proven `box_theory_witness_consistent` template
  - The finite horizon approach still requires proving F-iteration containment in deferralClosure, which is adjacent to the boundary problems that plagued task 48

### Gaps Identified

1. **Need to verify**: Does `temporal_theory_witness_consistent` require any new axioms beyond TF, TA, and existing S5 structure?
2. **Need to verify**: Can the proof handle both F (future) and P (past) directions symmetrically?
3. **Need to verify**: The rewiring from `SuccChainTemporalCoherent` to the new direct proof — how much refactoring is needed in `boxClassFamilies_temporally_coherent`?

### Recommendations

**Primary**: Implement the temporal theory witness approach (Teammate A):
1. Define `G_theory(M) = {ψ | G(ψ) ∈ M}` and `H_theory(M) = {ψ | H(ψ) ∈ M}`
2. Prove consistency of `{φ} ∪ G_theory(M)` when `F(φ) ∈ M`
3. Prove consistency of `{φ} ∪ H_theory(M)` when `P(φ) ∈ M`
4. Extend to MCS witnesses via Lindenbaum
5. Rewire `boxClassFamilies_temporally_coherent` to use these witnesses
6. Remove/deprecate `f_nesting_is_bounded`, `f_nesting_boundary`, `succ_chain_forward_F`

**Do NOT pursue**: The restriction-based approach from the original plan (01_temporal-coherence-implementation.md).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Algebraic infrastructure | completed | HIGH | Temporal theory witness design |
| B | Task 48 retrospective | completed | HIGH | Pattern extraction from 15 failed versions |
| C | Risk analysis + alternatives | completed | MEDIUM-HIGH | Finite horizon alternative, risk matrix |

## References

### Key Proven Theorems (template for temporal analog)
- `box_theory_witness_consistent` (UltrafilterChain.lean:795-901)
- `box_theory_witness_exists` (UltrafilterChain.lean:906-933)
- `boxClassFamilies_modal_forward` (UltrafilterChain.lean:982-1030)
- `parametric_box_persistent` (ParametricTruthLemma.lean:137-165)

### Key Axioms Used
- TF: `□a ≤ G(□a)` — box persistence under temporal succession
- TA: Temporal axioms for G/H interaction
- S5 negative introspection: `¬□a → □¬□a`

### Task 48 Artifacts
- `specs/048_prove_succ_chain_fam_bounded_f_depth/plans/15_ultrafilter-chain.md` — successful plan
- `specs/048_prove_succ_chain_fam_bounded_f_depth/reports/33_team*` — final team research
