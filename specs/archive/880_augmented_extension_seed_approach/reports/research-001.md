# Research Report: Task #880

**Task**: 880 - Investigate augmented extension seed approach for pure past/future cases
**Date**: 2026-02-12
**Mode**: Team Research (2 teammates)
**Session**: sess_1770921898_b765d1

## Summary

Team research confirms that the **augmented extension seed approach is NOT viable** for pure past/future cases. The fundamental problem is that conflicting F-obligations (e.g., F(p) and F(neg p) in the same MCS) create an inherently inconsistent seed BEFORE any Lindenbaum extension occurs. Additionally, the research reveals a deeper flaw: **universal forward_F is incompatible with domain extension** for families with conflicting existential obligations.

The cross-sign case (domain times both above and below t) IS solvable with existing infrastructure - all elements collect into a single reference MCS. However, pure past/future cases require a fundamentally different construction approach, likely one-at-a-time witness placement combined with controlled Lindenbaum extension.

## Key Findings

### 1. The Augmented Seed Approach FAILS

Both research angles confirm: adding negative GH constraints to the seed does not fix the pure past/future problem.

**Why augmentation fails**:
- The seed inconsistency arises from conflicting F-obligations ({p, neg p} from F(p) and F(neg p))
- This inconsistency occurs BEFORE Lindenbaum runs, so controlling what Lindenbaum adds is irrelevant
- Adding negative constraints (e.g., G(neg phi)) makes the seed larger without resolving the conflict
- G(neg phi) is not derivable from existing MCSs just because phi is absent from some MCS

**The counterexample** (confirmed):
- MCS M contains F(p) and F(neg p) (both consistent in temporal logic)
- The seed `{p, neg p} union GContent(M)` is inconsistent because {p, neg p} derives bottom directly

### 2. Universal forward_F is INCOMPATIBLE with Domain Extension (New Discovery)

Research uncovered a deeper flaw in the "strengthened family" approach from research-005:

**Proof by counterexample**:
- Base family: domain = {0}, mcs(0) = M where F(p) in M and F(neg p) in M
- Try to extend to domain = {0, 1}
- Universal forward_F requires: F(p) in mcs(0) implies p in mcs(1), AND F(neg p) in mcs(0) implies neg p in mcs(1)
- But p and neg p in mcs(1) contradicts mcs(1) being an MCS

**Consequence**: Zorn's lemma may give a maximal family with domain = {0} because extension is impossible. The entire "strengthened family" strategy from Phase 2 has a fundamental gap.

### 3. The Cross-Sign Case IS Solvable

Both teammates confirm: when domain has times both above and below t, seed consistency is achievable:
- Take s_max = max past source time, s_min = min future source time
- s_max < t < s_min, both in domain
- GContent from past propagates to s_min via forward_G + 4-axiom
- F-obligations from past propagate to s_min via forward_F (both s_max and s_min in domain)
- HContent and P-obligations are already at s_min
- Everything collects into mcs(s_min), which is consistent

The key difference: F-obligations propagate to an EXISTING domain time, not to the new time being added.

### 4. `temporal_witness_seed_consistent` Provides the Correct Granularity

The proven lemma `temporal_witness_seed_consistent` handles exactly:
> If F(psi) in M, then {psi} union GContent(M) is consistent.

This is ONE witness for ONE F-obligation. The multi-witness version (`multi_witness_seed_consistent_future/past`) attempts to place ALL witnesses simultaneously, which is mathematically false. Any viable construction must proceed one witness at a time.

### 5. Six Alternative Approaches Analyzed

| Approach | Seed Consistency | New-to-Old | Base Case | Complexity | Sorry Risk |
|----------|-----------------|------------|-----------|------------|------------|
| A: One-at-a-Time Witness | Solved | Requires separate argument | Straightforward | Medium-High | Medium |
| B: GH-Controlled Lindenbaum | NOT solved | Solved | Straightforward | High | Medium-Low |
| C: Modified Seed (no F-obligations) | Solved (trivially) | NOT solved | Straightforward | Low | High (shifts problem) |
| D: Pair-Extension | Solved | Solved | Needs rethinking | Very High | Low in theory |
| E: Weakened Forward_F | Solved | Solved | FAILS for singleton | Medium | Medium |
| F: Weaker Zorn Target | NOT solved | NOT solved | Straightforward | Medium | High |
| **A+B Combined** | **Solved** | **Solved** | **Straightforward** | **High** | **Medium** |

### 6. Fundamental Tension Identified

There is a structural tension between:
- **Zorn's non-constructive maximality**: gives existence without construction trace
- **F/P witness placement**: requires specific formulas in specific MCSs

This tension suggests the Zorn approach may be fundamentally unsuited for F/P satisfaction, which requires construction-level control.

## Synthesis

### Conflicts Resolved

No conflicts between teammates. Both independently reached the same conclusions:
1. Augmented seed is not viable
2. Cross-sign case is solvable
3. Universal forward_F is problematic
4. One-at-a-time witness is the correct granularity

### Gaps Identified

1. No single approach cleanly resolves all 12 sorry sites in ZornFamily.lean
2. Base case for weakened (existential) forward_F fails for singleton domains
3. Convergence of post-processing approach is speculative
4. GH-controlled Lindenbaum correctness proof not yet developed

### Recommendations

**Primary Recommendation: Bifurcate the Approach**

1. **For the cross-sign case**: Implement now using existing infrastructure - all elements collect into mcs(s_min)

2. **For pure past/future cases**: Two viable paths:
   - **Option A**: Combined one-at-a-time + GH-controlled Lindenbaum (highest coverage, highest effort)
   - **Option B**: Abandon Zorn for F/P satisfaction; use explicit Henkin/dovetailing construction

**Secondary Recommendation: Drop Universal forward_F/backward_P**

The universal versions are incompatible with domain extension. Either:
- Remove from structure entirely (return to G/H-only coherence)
- Replace with existential versions (but requires solving the singleton base case)

**Tertiary Recommendation: Evaluate DovetailingChain**

The DovetailingChain approach has 4 sorry sites but they may be more tractable than the ZornFamily sorries since they handle cross-sign propagation (which is solvable) rather than seed consistency (which is blocked for pure cases).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Augmented seed definition and consistency proof | completed | high on findings, medium on recommendations |
| B | Alternative approaches and prior art | completed | medium-low on any single approach resolving all sorries |

## Evidence (Verified via lean_local_search)

### Proven Lemmas Available
- `temporal_witness_seed_consistent` - single F-witness + GContent consistent
- `temporal_witness_seed_consistent_past` - past analog
- `GContent_consistent` - GContent of MCS is consistent
- `HContent_consistent` - HContent of MCS is consistent
- `GContent_propagates_forward` - GContent monotone forward via 4-axiom
- `HContent_propagates_backward` - HContent monotone backward via 4-axiom
- `CoherentExtensions_chain_has_ub` - chain upper bound for Zorn
- `zorn_le_nonempty_0` - Mathlib Zorn

### False Lemmas (Cannot Be Proven)
- `multi_witness_seed_consistent_future` - FALSE (counterexample confirmed)
- `multi_witness_seed_consistent_past` - FALSE (counterexample confirmed)

### Key Code Locations
- `extensionSeed` definition: ZornFamily.lean line 512
- `GHCoherentPartialFamily` structure: ZornFamily.lean line 96
- `forward_F` field: ZornFamily.lean line 121
- Sorry sites: lines 844, 874, 888, 1120, 1260, 1764, 1786, 1928, 1968, 2091, 2161, 2168

## References

- Task 870 research reports (research-001 through research-005)
- Task 870 implementation plan v004
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

## Next Steps

1. **Immediate**: Delete the false lemmas `multi_witness_seed_consistent_future/past` or clearly mark them as FALSE with counterexample documentation

2. **Short-term**: Implement the cross-sign case seed consistency (provable with current infrastructure)

3. **Medium-term**: Choose between:
   - (A) Develop GH-controlled Lindenbaum + one-at-a-time witness for Zorn approach
   - (B) Pivot to DovetailingChain approach for the full construction

4. **Architectural decision needed**: Whether to continue with the Zorn-based approach or switch to explicit construction. The Zorn approach has fundamental limitations for F/P satisfaction; explicit construction (DovetailingChain) may be more tractable despite its current sorry sites.
