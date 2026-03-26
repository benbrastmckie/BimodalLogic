# Research Report: Task #58 - Cross-Chain Witness Propagation

**Task**: Wire completeness to frame conditions
**Date**: 2026-03-26
**Mode**: Team Research (3 teammates)
**Session**: sess_1774556754_cd2de9
**Focus**: Phase 1 sorries - cross-chain F/P witness propagation at chain junction (t=0)

## Summary

All 3 teammates converge on a single viable resolution: the **propagation-to-0 argument**. F-obligations in the backward chain propagate rightward via the Succ relation, eventually reaching position 0 (the seed), which bridges into the forward chain where existing `restricted_forward_chain_forward_F` provides witnesses. The symmetric argument handles P-obligations crossing from forward to backward.

However, this approach depends on a chain of pre-existing sorries that must be resolved first.

## Key Findings

### Primary Approach: Propagation-to-0 + Cross-Chain Transfer (ALL teammates)

**Mathematical argument** (Sorry 1, line 3892: F in backward chain):
1. `F(psi) in backward_chain(k+1)` at position `-(k+1)`
2. Succ relation: `f_content(backward_chain(n)) ⊆ backward_chain(n-1) ∪ f_content(backward_chain(n-1))`
3. F-obligations propagate rightward (toward 0) through the backward chain
4. Either `psi` resolves at some backward position `m` where `-k ≤ m ≤ 0`, or `F(psi)` reaches position 0
5. At position 0: `backward_chain(0) = forward_chain(0) = seed.world`
6. Apply `restricted_forward_chain_forward_F` → witness at `Int.ofNat m` where `m > 0`

**Mathematical argument** (Sorry 2, line 3917: P in forward chain):
Symmetric: P-obligations propagate leftward through forward chain to position 0, then `restricted_backward_chain_backward_P` provides witness in backward chain.

**Confidence**: HIGH for mathematical correctness, MEDIUM for Lean formalization.

### Alternative Approaches Evaluated (from Teammate B)

| Approach | Viability | Complexity | Notes |
|----------|-----------|------------|-------|
| Joint dovetailing construction | Medium-High | HIGH (5-8 hrs) | Standard in literature (Venema, Burgess) |
| Combined bounded witness over Int | Medium | MEDIUM (3-5 hrs) | **Best first attempt** - extends existing infrastructure |
| Closure-based seed enrichment | Low | Very High | Circular dependency |
| Colimit/limit approach | Low | Very High | Doesn't eliminate constructive gap |
| Fair-scheduling single chain | Medium | High | Major architecture change |

### Pre-existing Sorry Chain (from Teammates A and C)

**Critical path of sorries blocking resolution**:

| Priority | Sorry Location | Line | Description | Confidence |
|----------|---------------|------|-------------|------------|
| 1 | `constrained_predecessor_restricted_g_persistence_reverse` | 3360 | G-persistence reverse for Succ relation | MEDIUM |
| 2 | `constrained_predecessor_restricted_f_step_forward` | 3420 | F-step for predecessor (chi∉u, F(chi)∉u case) | MEDIUM |
| 3 | `restricted_bounded_witness` termination | 2405 | decreasing_by for F-witness search | LOW |
| 4 | `restricted_backward_bounded_witness` termination | 3824 | decreasing_by for P-witness search | LOW |
| 5 | `neg_not_in_boundary_resolution_set` | 1435 | Potentially unprovable as stated | LOW |
| 6 | `constrained_successor_seed_restricted_consistent` | 1543 | Depends on #5 | LOW |

**The dependency chain**:
```
cross-chain sorries (3892, 3917)
  └─ needs backward chain Succ verified
       └─ needs g_persistence_reverse (#1) + f_step_forward (#2)
  └─ needs bounded_witness to terminate
       └─ needs termination proof (#3, #4)
  └─ needs forward chain construction sound
       └─ needs seed consistency (#5, #6)
```

## Synthesis

### Conflicts Resolved

1. **Architecture impossibility vs propagation argument**: Teammate B states cross-chain witnesses are a "genuine impossibility for the current architecture," while A and C argue propagation-to-0 works within existing architecture. **Resolution**: B's claim is about *direct* guarantees - the chains have no built-in cross-chain mechanism. But the *indirect* propagation argument (A/C) exploits the Succ relation flowing rightward through the backward chain to reach the seed bridge at position 0. This is not a built-in guarantee but a derived property. B also identifies the same approach as "combined bounded witness."

2. **Priority ordering**: A suggests bottom-up (Succ sorries first), C suggests seed consistency first. **Resolution**: The Succ relation sorries (g_persistence_reverse, f_step_forward) are more critical since the propagation argument directly depends on them. Seed consistency affects the forward chain construction but the forward chain is already working for its own F-coherence.

### Gaps Identified

1. **No `restricted_backward_chain_F_bounded` theorem exists** (noted by A) - needed for the bounded witness argument in the backward chain direction
2. **No `restricted_backward_bounded_witness_F` theorem exists** (needed for backward-to-forward propagation)
3. **Termination proofs** are flagged LOW confidence by both A and C - the `decreasing_by` blocks fail `simp_wf` and need manual well-foundedness arguments
4. **`neg_not_in_boundary_resolution_set`** is explicitly flagged as "potentially unprovable" in the source comments - may require definition change

### Recommendations

**Recommended path (2 options)**:

**Option A: Combined Bounded Witness (Teammates A+B convergence)**
1. Define `restricted_combined_bounded_witness` working over the full Int-indexed `restricted_succ_chain_fam`
2. Use existing `succ_chain_canonicalTask_forward_MCS_from` infrastructure for chain traversal across junction
3. Apply `restricted_mcs_F_bounded` (exists, sorry-free) to bound the witness search
4. Prove cross-chain sorries directly from the combined witness lemma
- **Advantage**: May bypass some pre-existing sorries by working at a higher level
- **Risk**: Still needs Succ relation verification

**Option B: Bottom-up Sorry Resolution (Teammate A primary)**
1. Resolve `constrained_predecessor_restricted_g_persistence_reverse` (line 3360)
2. Resolve `constrained_predecessor_restricted_f_step_forward` (line 3420)
3. Create `restricted_backward_chain_F_bounded` + `restricted_backward_bounded_witness_F`
4. Prove propagation-to-0 using step-wise induction
5. Fill cross-chain sorries (3892, 3917)
- **Advantage**: Solid foundation, resolves multiple sorry chains
- **Risk**: Higher effort, termination proofs may block progress

**Immediate next step**: Try Option A first (lower complexity). If blocked by Succ relation issues, pivot to Option B.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A (math-struct) | Structural analysis | completed | HIGH math / MEDIUM Lean | Propagation-to-0 mechanism, priority ordering of pre-existing sorries |
| B (math-alt) | Alternative approaches | completed | MEDIUM | 5 approaches evaluated, combined bounded witness shortcut recommended |
| C (math-risk) | Risk analysis | completed | MEDIUM | Full sorry dependency chain mapped, termination risk flagged LOW |

## References

- `SuccChainFMCS.lean:3878-3938` - Main cross-chain sorries
- `SuccChainFMCS.lean:314-320` - `succ_chain_fam` split definition
- `SuccChainFMCS.lean:560-577` - `succ_chain_canonicalTask_forward_MCS_from`
- `SuccChainFMCS.lean:692-737` - `f_nesting_is_bounded_restricted`
- `SuccChainFMCS.lean:2402-2405` - `restricted_bounded_witness` termination sorry
- `SuccChainFMCS.lean:3360` - `constrained_predecessor_restricted_g_persistence_reverse` sorry
- `SuccChainFMCS.lean:3420` - `constrained_predecessor_restricted_f_step_forward` sorry
- Venema, "Temporal Logic" (Chapter 10) - Standard Lin.Z completeness
- Burgess (1982), "Axioms for Tense Logic I" - Fair-scheduling witnesses
