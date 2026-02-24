# Research Report: Task #916 (Path Forward Synthesis)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-24
**Mode**: Team Research (3 teammates)
**Session**: sess_1771943737_5ab454

---

## Summary

This team research synthesizes 13 prior reports, 9 implementation plans, and 4+ failed implementation attempts to identify the best path forward for a sorry-free, axiom-free, mathematically correct proof. Three teammates analyzed the problem from different angles: critical path analysis (A), alternative approaches (B), and risk/devil's advocate (C).

**Key consensus**: The WitnessGraph ("Deferred Concretization") approach is the ONLY viable path. All chain-based approaches are blocked by Lindenbaum opacity. The mathematical result is a standard textbook theorem (99% confidence), but the formalization has ~40% cumulative success probability with an expected 55-75 hours of effort.

---

## Key Findings

### 1. The F-Preserving Seed Conjecture Was Refuted (Not Just Blocked)

The "most promising" approach from research-005/007 (proving `{psi} union GContent(M) union FContent(M)` is consistent) was **refuted by counterexample** during implementation v005. The derivation surgery argument has a gap at step 12 that cannot be filled. This path should be permanently abandoned.

**Consensus**: All teammates agree this is definitively blocked.

### 2. The Phase 5 Failure Was Due to Reverting to Linear Chain

WitnessGraph.lean (3113 lines) correctly builds a DAG where each F/P obligation gets its own fresh Lindenbaum extension. Phases 1-3 are architecturally sound. The failure at Phase 5 occurred because the `enrichedForwardChain` embedding (lines 2740-2760) is structurally identical to the original DovetailingChain—it reverted to building MCSs step-by-step via Lindenbaum extension of GContent seeds.

**The WitnessGraph infrastructure is correct; only the embedding strategy is wrong.**

### 3. Hidden Assumption: Reflexive vs Strict Semantics

10 of 13 prior reports describe temporal operators as STRICT, but Truth.lean (lines 118-119) uses REFLEXIVE semantics (`<=`). The forward_F signature still correctly requires strict `t < s` because `F(phi)` at t does NOT imply `phi` at t. However, the FIX comment in research-008 noting this discrepancy was never systematically addressed.

### 4. Mathematical Correctness Is Certain

All teammates agree (99% confidence) that the mathematical result is a standard textbook theorem (Goldblatt 1992, Blackburn et al. 2001, Reynolds 2003). The difficulty is purely formalization—fitting the proof into Lean 4, handling dependent types, managing the DAG-to-Int embedding, and proving global coherence from local properties.

**There is no mathematical reason why this is impossible.**

### 5. Three Approaches Are Definitively Blocked

| Approach | Reason | Report |
|----------|--------|--------|
| FPreservingSeed | Counterexample refutes the conjecture | v005 failure |
| Derivation surgery | Gap at step 12 unfillable | research-007 |
| Omega² directed limit | Generalized seed consistency is FALSE | research-004 |

### 6. WitnessGraph Is the Standard Step-by-Step Construction

The WitnessGraph approach IS the Lean formalization of the step-by-step construction from temporal logic literature (Burgess 1982, Gabbay-Hodkinson-Reynolds 2000, Reynolds 2003). It:
- Creates a fresh MCS for each F/P obligation (avoids persistence)
- Places witnesses on-demand (avoids past-encoding)
- Uses only the PROVEN `forward_temporal_witness_seed_consistent` lemma

**Consensus**: All teammates agree this is the only viable path.

---

## Synthesis: Conflicts and Resolutions

### Conflict 1: Effort Estimates Vary

- Teammate A: 30-50 hours (AliveF path) or 80-120 hours (step-by-step)
- Teammate B: 32-49 hours (WitnessGraph completion)
- Teammate C: 55-75 hours expected, 120+ worst case

**Resolution**: The estimates reflect different assumptions. Teammate B's 32-49 hours assumes Phase 3A errors are fixable quickly (2.5-3.5 hours). Teammate C's 55-75 hours accounts for Lean engineering friction and context exhaustion. **Use 55-75 hours as the realistic expected effort.**

### Conflict 2: AliveF vs WitnessGraph

Teammate A recommends AliveF + Fair Scheduling (30-50 hours, 50-60% confidence) as the "best risk-adjusted option." Teammates B and C focus exclusively on WitnessGraph.

**Resolution**: The AliveF approach has an unresolved residual gap at witness steps (F-obligations can be killed when placing other witnesses). Teammate A acknowledges this gap remains open. WitnessGraph fundamentally avoids this issue by giving each obligation its own node. **WitnessGraph is the more architecturally sound choice**, though AliveF could be a fallback if WitnessGraph fails.

### Conflict 3: Success Probability

- Teammate A: 50-60% (AliveF) or 80-90% (step-by-step)
- Teammate B: 85% (WitnessGraph)
- Teammate C: 40% cumulative (WitnessGraph phases 3A-6)

**Resolution**: Teammate C's 40% is the most methodologically rigorous (probability of ALL phases succeeding: 0.85 × 0.75 × 0.80 × 0.80). Teammate B's 85% is for the mathematical correctness of the approach, not the formalization success. **Use 40-50% as the realistic cumulative success probability for WitnessGraph completion.**

---

## Recommendations

### Primary Recommendation: Time-Boxed WitnessGraph Completion

**If time budget allows (30-hour time box)**:

1. **Phase 3A**: Fix 8 build errors using `congrArg` patterns (3-4 hours)
   - **GATE**: If Phase 3A takes >6 hours, abort to sorry debt acceptance
2. **Phase 3**: Complete remaining sorries (10-15 hours)
3. **Phase 4**: Embed witness graph into Int (10 hours)
4. **Phase 5**: Prove global coherence (15-20 hours)
5. **Phase 6**: Integration into DovetailingChain.lean (5-10 hours)

**HARD STOP at 30 hours total.** If not complete, accept sorry debt.

### Secondary Recommendation: Accept Sorry Debt

**If time budget is limited**:

1. Document the 2 sorries in DovetailingChain.lean per proof-debt-policy.md
2. Reference this synthesis and the 13 prior reports
3. Characterize the obstruction: Lindenbaum opacity + GContent seed invisibility
4. Note WitnessGraph.lean as partial resolution (3113 lines, Phases 1-2 complete)
5. Provide remediation spec: complete WitnessGraph Phases 3-6

**Effort**: 2-3 hours
**Risk**: 0%

### Do NOT Pursue

- F-preserving seed approach (refuted)
- Constructive Lindenbaum (Boneyard failure, 6 sorries)
- Full canonical model rewrite (60-80 hours, disproportionate)
- Any further chain-based approach (Lindenbaum opacity is fundamental)
- AliveF without WitnessGraph (residual gap at witness steps unresolved)

---

## Cost-Benefit Analysis

| Path | Effort | Risk | Value |
|------|--------|------|-------|
| WitnessGraph completion | 55-75 hours expected | ~60% failure | Proves standard textbook result; no mathematical novelty |
| Sorry debt acceptance | 2-3 hours | 0% | BMCS completeness unaffected; standard practice |

**Effort ratio**: 20-25x more effort to close vs document.

**Value assessment**: The sorries are in the bridge from BFMCS to standard completeness. The BMCS completeness proof (the main contribution) is sorry-free and publication-ready. Closing the sorries demonstrates Lean formalization capability but provides no mathematical novelty.

---

## Current State Summary

### DovetailingChain.lean
- 2 sorries at lines 1754, 1761 (forward_F, backward_P)
- ~1800 lines of sorry-free infrastructure

### WitnessGraph.lean
- 3113 lines
- 4 sorries at lines 3030, 3038, 3109, 3111
- Phases 1-2 complete (sorry-free)
- Phase 3 partial (5 sorries in committed version, 8 build errors in uncommitted)
- Phases 4-6 not started

### Total Proof Debt
- 6 sorries across both files for the same fundamental issue
- All are "structural sorry—known textbook result, formalization gap"

---

## Teammate Contributions

| Teammate | Focus | Status | Key Finding |
|----------|-------|--------|-------------|
| A | Critical path analysis | Completed | AliveF residual gap, WitnessGraph embedding failure |
| B | Alternative approaches | Completed | All alternatives reduce to WitnessGraph or fail |
| C | Risk/devil's advocate | Completed | 40% cumulative success; 20-25x effort ratio |

---

## Confidence Assessment

| Claim | Confidence | Basis |
|-------|------------|-------|
| Mathematical correctness of target theorem | 99% | Standard textbook result |
| WitnessGraph is architecturally sound | 90% | Avoids Lindenbaum opacity |
| F-preserving seed is refuted | 90% | Implementation v005 failure |
| Cumulative formalization success | 40-50% | Phase-by-phase probability |
| Effort estimate (55-75 hours) | 75% | Accounting for Lean friction |
| Sorry debt is acceptable | 95% | BMCS completeness unaffected |

---

## References

### Key Files
- `DovetailingChain.lean`: 2 sorries (lines 1754, 1761)
- `WitnessGraph.lean`: 4 sorries (lines 3030, 3038, 3109, 3111)
- `forward_temporal_witness_seed_consistent`: DovetailingChain.lean (proven)
- `Truth.lean`: Reflexive semantics (lines 118-119)

### Prior Research (13 reports)
- research-001 through research-013

### Literature
- Burgess (1982): Completeness for Kt
- Goldblatt (1992): Logics of Time and Computation
- Gabbay, Hodkinson, Reynolds (2000): Temporal Logic mathematical foundations
- Reynolds (2003): Completeness by construction
- Blackburn et al. (2001): Modal Logic textbook

---

## Next Steps

1. **Decision point**: Time-box WitnessGraph (30 hours) OR accept sorry debt immediately
2. If WitnessGraph: Start with Phase 3A build errors (3-4 hours)
3. If sorry debt: Create documentation following proof-debt-policy.md
