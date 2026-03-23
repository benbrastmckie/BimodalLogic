# Implementation Plan: Research Modified Successor Seed for P-Step

- **Task**: 45 - research_modified_successor_seed
- **Status**: [COMPLETED]
- **Effort**: 2-3 hours
- **Dependencies**: Parent task 40 (blocked on forward_chain_p_step)
- **Research Inputs**: specs/040_succ_p_step_forward_chain/reports/02_spawn-analysis.md
- **Artifacts**: plans/01_research-plan.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4

## Overview

Research how to modify the successor seed construction to satisfy p-step for CanonicalTask relations. The current successor seed (`g_content(u) UNION deferralDisjunctions(u)`) only handles F-formulas, leaving P-formulas unconstrained. The predecessor seed achieves p-step via `pastDeferralDisjunctions`, but there is no symmetric mechanism for successors. This research explores whether a clean structural solution exists within the CanonicalTask framework.

### Research Integration

Key context from spawn analysis:
- The sorry at SuccChainFMCS.lean:350 (`succ_chain_fam_p_step`) blocks forward chain P-coherence
- Predecessor seed uses `pastDeferralDisjunctions` to guarantee p-step
- The `temp_a: phi -> G(P(phi))` axiom relates forward movement to P-formulas
- The `h_content_reverse` duality theorem derives H-coherence from G-persistence

## Goals & Non-Goals

**Goals**:
- Determine if `futureDeferralDisjunctionsForP` can be defined to constrain P-formulas in successors
- Analyze whether `temp_a` axiom usage in Lindenbaum extension can derive p-step
- Evaluate if `h_content_subset_implies_g_content_reverse` provides a p-step argument
- Identify whether a semantic argument exists for p-step in forward chains
- Produce a clear recommendation: structural proof viable, axiom required, or impossible

**Non-Goals**:
- Implementing the actual proof (that is Task 46)
- Modifying the ExistsTask Kripke relation (focus is on CanonicalTask)
- Restructuring the entire canonical model construction
- Proving backward chain p-step (already works via predecessor seed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| No clean structural solution exists | H | M | Document why and identify minimal axiom if needed |
| P-formula prediction is inherently undecidable | H | L | Analyze MCS properties to bound possibilities |
| temp_a does not constrain successor P-formulas | M | H | Investigate reverse application via H-duality |
| Research inconclusive | M | M | Clearly document partial findings and open questions |

## Implementation Phases

### Phase 1: Analyze Current Seed Asymmetry [COMPLETED]

**Goal**: Understand precisely why predecessor seed satisfies p-step and successor seed does not.

**Tasks**:
- [ ] Read SuccExistence.lean lines 50-120 for successor seed definition
- [ ] Read SuccExistence.lean lines 126-200 for predecessor seed definition
- [ ] Compare `deferralDisjunctions` vs `pastDeferralDisjunctions` structures
- [ ] Document the structural asymmetry in detail
- [ ] Identify what information is missing at successor seed construction time

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Seed definitions
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - How p-step is used

**Verification**:
- Clear written explanation of why predecessor seed works and successor seed does not

---

### Phase 2: Investigate futureDeferralDisjunctionsForP [COMPLETED]

**Goal**: Determine if P-formula deferral disjunctions can be added to the successor seed.

**Tasks**:
- [ ] Define hypothetical `futureDeferralDisjunctionsForP(u) = {phi OR P(phi) | P(phi) in u}`
- [ ] Analyze if this addition maintains seed consistency
- [ ] Check if Lindenbaum extension of augmented seed satisfies p-step
- [ ] Identify mathematical obstacles (if any)
- [ ] Document whether this approach is viable

**Timing**: 40 minutes

**Reasoning approach**:
- If P(phi) in u, then phi OR P(phi) forces either phi in v (resolved) or P(phi) in v (deferred)
- This mirrors pastDeferralDisjunctions but for the successor direction
- Key question: Does P(phi) in u persist to successor v without explicit constraint?

**Verification**:
- Written analysis with conclusion: viable, partially viable, or not viable

---

### Phase 3: Analyze temp_a Axiom Constraints [COMPLETED]

**Goal**: Determine if `temp_a: phi -> G(P(phi))` can constrain P-formulas in successors.

**Tasks**:
- [ ] Read Axioms.lean for temp_a definition and usage patterns
- [ ] Analyze: If phi in u, then G(P(phi)) in u (by temp_a), so P(phi) in successor v
- [ ] Check: Does this give p-step? p_content(v) <= u UNION p_content(u)?
- [ ] Trace through MCS closure to see what P-formulas must appear
- [ ] Document findings on temp_a's constraining power

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - temp_a definition
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - temp_a usage in duality proofs

**Verification**:
- Clear statement on whether temp_a provides p-step constraints

---

### Phase 4: Investigate h_content_reverse Duality [COMPLETED]

**Goal**: Determine if g_content/h_content duality theorems imply p-step.

**Tasks**:
- [ ] Read WitnessSeed.lean lines 321-380 for duality theorems
- [ ] Analyze `g_content_subset_implies_h_content_reverse`: g_content(u) <= v => h_content(v) <= u
- [ ] Check if this duality provides any p_content constraints
- [ ] Compare h_content (H-formulas) vs p_content (P-formulas) - are they related?
- [ ] Document whether duality provides p-step argument

**Timing**: 30 minutes

**Key insight to verify**:
- h_content(v) gives formulas phi where H(phi) in v
- p_content(v) gives formulas phi where P(phi) in v
- These are different: H and P are dual but not identical

**Verification**:
- Clear analysis of relationship between h_content duality and p_content constraints

---

### Phase 5: Semantic Arguments for P-Step [COMPLETED]

**Goal**: Explore semantic/model-theoretic arguments for why p-step should hold.

**Tasks**:
- [ ] Consider: What does p-step mean semantically for forward chains?
- [ ] Analyze: In temporal models, does going forward constrain P-obligations?
- [ ] Check: Does the CanonicalTask discrete structure impose implicit p-step?
- [ ] Review CanonicalTaskRelation.lean lines 718-726 for how p-step is used
- [ ] Document semantic justification (or lack thereof) for p-step in forward chains

**Timing**: 30 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - CanonicalTask_backward_MCS_P usage

**Verification**:
- Semantic explanation of p-step role and whether it should hold for forward chains

---

### Phase 6: Synthesize Findings and Recommendation [COMPLETED]

**Goal**: Produce a clear recommendation for how to proceed.

**Tasks**:
- [ ] Summarize findings from phases 1-5
- [ ] Determine: Is a clean structural proof possible?
- [ ] If yes: Outline the proof approach
- [ ] If no: Identify the minimal axiom or modification needed
- [ ] Consider alternative: Can CanonicalTask_backward_MCS_P be reformulated?
- [ ] Write research report with recommendation

**Timing**: 30 minutes

**Possible outcomes**:
1. **Structural proof exists**: Define futureDeferralDisjunctionsForP, prove it works
2. **Axiom-based proof**: temp_a or another axiom provides the constraint
3. **Semantic argument**: Forward chains inherently satisfy p-step by model properties
4. **Requires modification**: CanonicalTask definition needs adjustment
5. **Impossible without new axiom**: Document the gap and propose minimal axiom

**Verification**:
- Research report written with clear recommendation
- Specific next steps for Task 46 (implementation)

## Testing & Validation

- [ ] Each phase produces documented findings (notes or sections in report)
- [ ] Final recommendation is actionable for Task 46
- [ ] Key questions from spawn analysis are all addressed
- [ ] Mathematical arguments are complete and verifiable

## Artifacts & Outputs

- `plans/01_research-plan.md` (this file)
- `reports/01_modified-succ-seed-research.md` (research findings)

## Rollback/Contingency

If research concludes that no clean solution exists:
- Document the impossibility argument clearly
- Propose minimal axiom addition (if applicable)
- Consider reformulating CanonicalTask_backward_MCS_P to avoid forward region p-step requirement
- Alternatively, mark Task 46 as not viable and update Task 40 blocker accordingly
