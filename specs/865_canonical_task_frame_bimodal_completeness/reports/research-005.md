# Research Report: Task #865 (Round 5)

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-10
**Focus**: Phase 1 blockage analysis, task 864 seed construction applicability, debt-free alternatives for temporal coherence

## Summary

This report investigates what blocked Phase 1 implementation of the canonical task frame construction and whether task 864's recursive seed construction approach can help. The core finding is that Phase 1 was never actually started for task 865 -- the task remains in the RESEARCHING status with 4 research reports completed (research-001 through research-004) but no implementation plan created yet. The "blockage" referenced in the delegation context relates to **task 843's temporal coherence construction**, not task 865 directly. Task 843's Phase 1 (interleaved temporal chain construction) is BLOCKED due to a fundamental architectural limitation: cross-sign temporal propagation (G formulas from negative times reaching positive times) cannot work with the two-chain architecture. Task 864's recursive seed construction offers a viable alternative that could address both task 843's blockage and provide the temporal coherence needed for task 865's canonical task frame.

## 1. Clarifying the Blockage

### 1.1 What the Delegation Context Said

The delegation context stated: "Phase 1 implementation was blocked - need research into alternative temporal coherence constructions."

### 1.2 What Actually Happened

After reading all relevant materials:

1. **Task 865 status**: RESEARCHING (no implementation plan exists)
2. **Task 865 artifacts**: 4 research reports (research-001 through research-004)
3. **No Phase 1 for task 865**: There is no implementation plan, so there is no "Phase 1" to be blocked

The "Phase 1 blockage" refers to **task 843**, not task 865:

| Task | Status | Phase 1 |
|------|--------|---------|
| 843 | IMPLEMENTING | [BLOCKED] - Cross-sign temporal propagation cannot work with two-chain architecture |
| 864 | PLANNED | [NOT STARTED] - Recursive seed construction approach |
| 865 | RESEARCHING | N/A - No implementation plan exists |

### 1.3 The Relationship

Task 865's canonical task frame construction depends on temporal coherence being available. Task 843's temporal coherence construction is blocked. Therefore, any implementation of task 865 would eventually hit the same wall.

The delegation context's request to "research alternative temporal coherence constructions" is about finding a path forward that could unblock both task 843 and enable task 865.

## 2. Analysis of Task 843's Phase 1 Blockage

### 2.1 The Two-Chain Architecture Problem

Task 843's `DovetailingChain.lean` uses a two-chain architecture:
- **Forward chain**: Builds MCS at indices 0, 1, 2, 3, ... using GContent seeds
- **Backward chain**: Builds MCS at indices 0, -1, -2, -3, ... using HContent seeds

Both chains share a base MCS at index 0 (proven via `chains_share_base`).

### 2.2 Why Cross-Sign Fails

For cross-sign G propagation (G phi at time t < 0 should give phi at time t' >= 0):

1. G phi is in `M_{t}` where t < 0 (in the backward chain)
2. We need phi in `M_{t'}` where t' >= 0 (in the forward chain)
3. The backward chain's seed at each step is `HContent(previous_step)`, NOT `GContent`
4. G formulas in the backward chain do NOT propagate toward the shared base

**Root cause**: Each chain only includes content from one direction (GContent for forward, HContent for backward). There is no mechanism for G formulas from negative times to flow across the 0-boundary into positive times.

### 2.3 Why Interleaved Construction Does Not Help

Task 843's v008 plan proposed an interleaved construction order: M_0, M_1, M_{-1}, M_2, M_{-2}, ...

However, as research-017.md analysis showed:
- The interleaved ORDER changes which MCS are built first
- Each MCS's SEED still only includes GContent/HContent from neighbors
- M_0 is built first (step 0) without GContent from negative times
- When M_{-1} is built, its G formulas cannot retroactively affect M_0

**Conclusion**: The problem is not the construction order but the seed content. Interleaving does not fundamentally solve the cross-sign propagation problem.

## 3. Task 864's Recursive Seed Construction

### 3.1 Core Idea

Task 864 proposes a radically different approach: instead of building temporal and modal structure independently, the recursive seed construction builds the ENTIRE model structure directly from the formula's recursive structure.

Key distinction:
- **Modal witnesses** (negated Box): Create NEW FAMILIES
- **Temporal witnesses** (negated G/H): Create NEW TIME INDICES within the SAME family

### 3.2 How It Addresses Temporal Coherence

The seed construction naturally handles temporal witnesses:
1. If `F(psi)` (i.e., `neg(G(neg(psi)))`) appears at time t in family f, the seed creates a new time index t' > t with psi
2. If `P(psi)` (i.e., `neg(H(neg(psi)))`) appears at time t in family f, the seed creates a new time index t' < t with psi
3. The witness times are created BEFORE Lindenbaum extension, not during chain construction

### 3.3 Why This Avoids the Two-Chain Problem

The two-chain problem arises because:
1. Lindenbaum extension is one-directional (from seed toward completion)
2. G formulas added during backward chain construction cannot propagate forward

The seed construction avoids this by:
1. Placing ALL required temporal witnesses in the seed BEFORE Lindenbaum
2. Lindenbaum extension only adds formulas not required by the original formula's structure
3. Cross-sign propagation is not needed because the formula-required witnesses are already placed

### 3.4 Applicability to Task 865

Task 865 needs a BMCS (bundle of indexed MCS families) with:
1. Temporal coherence (forward_G, backward_H, forward_F, backward_P)
2. Modal coherence (modal_forward, modal_backward)

Task 864's seed construction directly provides both:
- Temporal: Witnesses created at seed level, not during chain construction
- Modal: New families created for diamond witnesses

The canonical task frame from research-004 (Construction B2: BMCS-indexed with WorldState = (family, time) pairs) can be built on top of a seed-constructed BMCS.

## 4. Debt-Free Path Analysis

### 4.1 Current Proof Debt Status

| Component | Sorries | Axioms | Status |
|-----------|---------|--------|--------|
| Task 843 temporal chain | 4 | 0 | BLOCKED (cross-sign propagation) |
| Task 843 modal axiom | 0 | 1 (fully_saturated_bmcs_exists) | CORRECT axiom (replaces FALSE one) |
| Completeness theorems | 0 | 1 (inherited from above) | Transitively depends on correct axiom |

### 4.2 What "Debt-Free" Means

Per the proof-debt-policy.md:
- **Sorries** are unproven gaps marked with `sorry` tactic
- **Axioms** are explicit unproven assumptions declared with `axiom`
- Both represent mathematical debt that propagates transitively
- "Debt-free" means no sorries AND no undisclosed axioms in the dependency chain

### 4.3 Achievable vs. Ideal Outcomes

**Ideal outcome** (zero debt):
- All 4 temporal sorries eliminated via seed construction
- `fully_saturated_bmcs_exists` axiom proven as theorem
- Task 865 canonical task frame builds on fully-proven BMCS

**Realistic near-term outcome**:
- Task 864 seed construction replaces task 843's temporal chain
- Temporal coherence proven via seed structure (no sorries)
- `fully_saturated_bmcs_exists` remains as CORRECT axiom (documented, not FALSE)
- Task 865 canonical task frame inherits 1 correct axiom as transitive debt

**Why this is acceptable for near-term**:
- The current FALSE axiom (`singleFamily_modal_backward_axiom`) has been replaced with a CORRECT one
- 1 correct axiom is strictly better than 1 false axiom + 4 sorries
- The correct axiom can be proven later (task 843 Phase 5) without blocking progress

### 4.4 Path to Full Debt Freedom

For complete debt elimination:

1. **Task 864**: Implement recursive seed construction (30-44 hours per plan)
2. **Task 843 Phase 5**: Prove `fully_saturated_bmcs_exists` using canonical model construction (20-30 hours)
3. **Task 865**: Build canonical task frame on proven BMCS

Total estimated effort: 50-75 hours for full debt freedom, but the path is well-defined.

## 5. Comparison: Seed Construction vs. Interleaved Chain

### 5.1 Structural Comparison

| Aspect | Interleaved Chain (Task 843) | Recursive Seed (Task 864) |
|--------|------------------------------|---------------------------|
| Construction order | M_0, M_1, M_{-1}, M_2, ... | From formula structure |
| Seed content | GContent/HContent from neighbors | Formula-driven constraints |
| Temporal witnesses | Dovetailing enumeration during chain | Placed in seed before Lindenbaum |
| Modal witnesses | Separate families from BMCS bundle | Created as new families in seed |
| Cross-sign propagation | NOT SOLVED | Avoided (witnesses pre-placed) |

### 5.2 Why Seed Construction Is More Promising

1. **Unified construction**: Both temporal and modal structure built simultaneously
2. **Formula-driven**: Witness placement follows the formula's logical form
3. **Finite seed**: Bounded by formula complexity, termination is clear
4. **Correctness by construction**: The starting formula is satisfied by design

### 5.3 Risks of Seed Construction

1. **Seed consistency proof**: Must show each (family, time) entry is consistent (HIGH risk per task 864 plan)
2. **Cross-family Box additions**: When Box phi adds phi to a diamond witness family, consistency must be preserved
3. **Lindenbaum extension at non-seed times**: May introduce formulas breaking cross-family coherence

## 6. Implications for Task 865

### 6.1 What Task 865 Needs

From research-004's recommended Construction B2:
1. A `BMCS D` structure with temporal and modal coherence
2. WorldState = (family, time) pairs
3. Task relation: same family + time arithmetic
4. World histories: constant family + offset
5. TruthLemma: 6 cases, box case uses MF/TF propagation

### 6.2 What Task 864 Provides

Task 864's seed construction provides:
1. A `BMCS Int` with seed-based temporal coherence
2. Modal coherence from seed structure (witness families include BoxContent)
3. The eval_family at time 0 containing the starting formula

### 6.3 How They Fit Together

Task 865's canonical task frame can be built on top of task 864's seed-constructed BMCS:

```
Task 864: consistent phi -> BMCS Int (seed-based)
          |
          v
Task 865: BMCS Int -> TaskFrame Int (canonical_frame_B2)
          |
          v
          formula_satisfiable phi (standard semantics)
```

The TruthLemma from research-003/004 bridges BMCS truth to standard task-frame truth.

### 6.4 Ordering of Implementation

Recommended order:
1. **First**: Task 864 (seed construction) - provides the BMCS
2. **Then**: Task 865 (canonical task frame) - builds on the BMCS
3. **Later**: Task 843 Phase 5 (prove the axiom) - full debt elimination

## 7. Detailed Recommendations

### 7.1 For Task 865

**Immediate**: Do NOT proceed with Phase 1 implementation yet.

**Reason**: Task 865 depends on a temporally coherent BMCS. The current BMCS construction has either:
- 4 sorries (two-chain approach)
- 1 correct axiom (current state after task 843 Phase 4)

**Wait for**: Task 864 to provide a seed-based BMCS, then build the canonical task frame on top.

**Alternative**: Accept the correct axiom as transitive debt and proceed with task 865 implementation. This is acceptable per proof-debt-policy.md as long as the axiom is documented and a remediation path exists (task 843 Phase 5).

### 7.2 For Task 864

**Proceed with implementation** per the existing plan (implementation-001.md).

**Key phases**:
1. Formula classification and seed data structures (2 hours)
2. Recursive seed builder (4 hours)
3. Seed consistency proof (8 hours) - HIGHEST RISK
4. Seed completion to MCS families (6 hours)
5. BMCS assembly and coherence proofs (8 hours)
6. Verification and cleanup (2 hours)

**Risk mitigation**: If seed consistency proof stalls, fall back to correct axiom as temporary debt.

### 7.3 For Task 843

**Phase 1 should be DEFERRED** in favor of task 864's seed construction.

**Reason**: The interleaved chain approach does not fundamentally solve the cross-sign propagation problem. Task 864's seed construction is a more promising path.

**Keep Phase 4 completion**: The FALSE axiom has been replaced with a CORRECT one. This is valuable regardless of how temporal coherence is ultimately achieved.

### 7.4 Relationship Summary

```
Task 843 Phase 1 [BLOCKED] -- interleaved chain does not solve cross-sign
          |
          +---> Task 864 [PLANNED] -- seed construction bypasses the problem
                    |
                    v
               Task 865 [RESEARCHING] -- canonical frame on seed-based BMCS
                    |
                    v
               Standard Completeness (formula_satisfiable from consistent)
```

## 8. Specific Technical Insights

### 8.1 Why the 4-Axiom Is Relevant

Research-002 identified that cross-boundary temporal coherence in composed families uses the 4-axioms:
- `G phi -> G(G phi)` (forward 4)
- `H phi -> H(H phi)` (backward 4)

These propagate G/H formulas through junction points when families are composed. The seed construction inherently respects this because:
1. G phi at time t in a seed entry means phi is added to all future times in that family
2. The 4-axiom closure happens during Lindenbaum extension automatically (MCS closure under theorems)

### 8.2 Why MF/TF Resolve the Offset Problem

Research-003 identified the offset problem: world histories in the indexed frame include time-shifted versions. The box case of the TruthLemma requires phi at ALL (family, time) pairs, not just at the evaluation time.

Resolution (research-003 Section 8.3):
1. `box phi in fam.mcs t` implies `G(box phi) in fam.mcs t` (by TF axiom)
2. Therefore `box phi in fam.mcs s` for all s >= t (by forward_G)
3. Similarly for past times (derivable via MF + modal/temporal interaction)
4. Therefore `phi in fam'.mcs s` for all fam' and all s (by modal_forward at each time)

This works for ANY temporally coherent BMCS, including seed-constructed ones.

### 8.3 Seed Construction's Handling of Modal Coherence

Task 864's seed handles modal coherence by:
1. Universal operators (Box): Add argument to ALL families at current time
2. Existential operators (neg Box): Create NEW family with witness

This directly mirrors the BMCS coherence conditions:
- `modal_forward`: Box phi in one family implies phi in all families at same time
- `modal_backward`: phi in all families at same time implies Box phi in each family

The seed pre-places these constraints, and Lindenbaum extension preserves them.

## 9. Conclusions

### 9.1 Key Findings

1. **Task 865 has no "Phase 1"** - it is still in RESEARCHING status
2. **The blockage is in task 843** - the two-chain architecture cannot support cross-sign temporal propagation
3. **Task 864's seed construction** offers a viable alternative that bypasses the architectural limitation
4. **The recommended path** is: implement task 864, then build task 865 on top

### 9.2 Debt Assessment

| Scenario | Sorries | Axioms | Status |
|----------|---------|--------|--------|
| Current (task 843 Phase 4 complete) | 4 | 1 (correct) | Acceptable |
| After task 864 | 0 | 1 (correct) | Better |
| After task 843 Phase 5 | 0 | 0 | Ideal |

All scenarios involve documented debt with clear remediation paths. The current state is not "debt-free" but is mathematically sound (the axiom is correct, not false).

### 9.3 Action Items

1. **Task 864**: Prioritize implementation of recursive seed construction
2. **Task 843 Phase 1**: Mark as SUPERSEDED BY task 864 approach
3. **Task 865**: Create implementation plan AFTER task 864 provides seed-based BMCS
4. **Documentation**: Update TODO.md to reflect dependencies

## 10. References

### Task Artifacts

- Task 865 research-001 through research-004
- Task 864 research-001 and implementation-001
- Task 843 research-017 (architectural redesign analysis)
- Task 843 implementation-008 (current plan)
- Task 843 implementation-summary-20260210 (latest status)

### Key Codebase Files

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Two-chain construction (4 sorries)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Temporal coherence + correct axiom
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Deprecated FALSE axiom
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - BMCS truth lemma (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Completeness theorems

### Policy Documents

- `.claude/context/project/lean4/standards/proof-debt-policy.md` - Debt characterization policy

## Next Steps

1. Update task 865 status to reflect research findings
2. Prioritize task 864 implementation
3. Create task 865 implementation plan after task 864 provides seed-based BMCS
4. Consider marking task 843 Phase 1 as superseded
