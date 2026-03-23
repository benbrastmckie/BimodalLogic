# Implementation Plan: Task #40 (v2)

- **Task**: 40 - succ_p_step_forward_chain
- **Status**: [BLOCKED]
- **Effort**: 2-3 hours (exploratory)
- **Dependencies**: None
- **Research Inputs**: specs/040_succ_p_step_forward_chain/reports/01_team-research.md
- **Artifacts**: plans/02_proof-based-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Revised plan avoiding axioms. The original plan added `successor_p_step_axiom`, but **no new axioms are permitted**. This revision explores proving the p-step property from existing infrastructure, specifically using `temp_a: φ → G(P(φ))` and existing duality theorems.

### Key Constraint

**No new axioms permitted.** The proof must use only:
- Existing theorems and lemmas
- Temporal axioms already in the proof system (temp_a, past_temp_a, etc.)
- Properties derivable from the Succ relation and MCS theory

### Research Integration

Key findings:
- `temp_a: φ → G(P(φ))` is used in `g_content_subset_implies_h_content_reverse`
- `past_temp_a: φ → H(F(φ))` is used in `h_content_subset_implies_g_content_reverse`
- `Succ_implies_h_content_reverse`: If Succ u v, then h_content(v) ⊆ u
- Predecessor case uses `pastDeferralDisjunctions` in seed - no such structure for successor

### Potential Proof Path

Using temp_a-based reasoning:
1. If φ ∈ u, then G(P(φ)) ∈ u (by temp_a + MCS closure)
2. If Succ u v, then g_content(u) ⊆ v, so P(φ) ∈ v
3. This shows: φ ∈ u implies P(φ) ∈ v

We need the **reverse**: P(φ) ∈ v implies φ ∈ u ∪ p_content(u)

This may require proving a contrapositive or using additional frame properties.

## Goals & Non-Goals

**Goals**:
- Fill the sorry at SuccChainFMCS.lean:350 **without adding any axiom**
- Prove `forward_chain_p_step` from existing infrastructure
- Or determine definitively that this is impossible without an axiom

**Non-Goals**:
- Adding `successor_p_step_axiom` or any other axiom
- Modifying the Succ definition
- Major refactoring of the successor construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| No proof exists without axiom | H | M | Document the impossibility, recommend blocking task |
| Proof is significantly complex | M | M | Time-box investigation, fallback to blocking |
| Requires new derived lemmas | L | H | Create helper lemmas in WitnessSeed.lean |

## Implementation Phases

### Phase 1: Investigate temp_a-Based Proof [COMPLETED]

**Goal**: Determine if `temp_a` and related infrastructure can prove successor p-step

**Tasks**:
- [ ] Study `g_content_subset_implies_h_content_reverse` proof pattern (WitnessSeed.lean:322-350)
- [ ] Attempt dual reasoning for p_content using past_temp_a
- [ ] Check if `Succ_implies_h_content_reverse` can be extended to p-step
- [ ] Document findings

**Investigation questions**:
1. Can we prove: If Succ u v and P(φ) ∈ v, what can we conclude about u?
2. Does the Succ relation + MCS properties give us enough to constrain p_content?
3. Is there a semantic argument from frame conditions?

**Timing**: 45 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (duality proofs)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (Succ properties)
- `Theories/Bimodal/ProofSystem/Axioms.lean` (temp_a, past_temp_a)

**Exit criteria**:
- Either: Working proof strategy identified → Continue to Phase 2
- Or: Definitive proof that axiom is required → Skip to Phase 3 (block)

---

### Phase 2: Implement Proof-Based Solution [NOT STARTED]

**Goal**: Implement the proof if Phase 1 succeeds

**Tasks**:
- [ ] Add any necessary helper lemmas to WitnessSeed.lean
- [ ] Add `forward_chain_p_step` theorem to SuccChainFMCS.lean (without axiom)
- [ ] Fill the sorry at line 350
- [ ] Verify compilation

**Timing**: 60 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - Helper lemmas if needed
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Main theorem + sorry fix

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- No axioms added (verify with grep)

---

### Phase 3: Block or Document (Contingency) [COMPLETED]

**Goal**: If no proof exists, document and recommend blocking

**Trigger**: Phase 1 determines axiom is required

**Tasks**:
- [ ] Document the impossibility proof/argument
- [ ] Update task status to BLOCKED with clear reason
- [ ] Propose alternative: accept axiom in future (separate task)
- [ ] Clean up any partial work

**Timing**: 20 minutes

**Documentation content**:
- Why the successor seed structure prevents pure proof
- What would be needed to make it provable
- Comparison with predecessor case

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify complete solution (if Phase 2 succeeds)

**Tasks**:
- [ ] Run full `lake build`
- [ ] Verify downstream dependent compiles (`succ_chain_canonicalTask_backward_MCS_P_from`)
- [ ] Remove outdated comments
- [ ] Verify no axioms were added: `grep -n "axiom" SuccExistence.lean | wc -l` unchanged

**Timing**: 15 minutes

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] No new axioms in SuccExistence.lean
- [ ] No production sorries remain in succ_chain_fam_p_step
- [ ] Dependent theorems compile

## Artifacts & Outputs

**If successful**:
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (proof-based solution)
- Possibly modified: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (helper lemmas)

**If blocked**:
- Updated: Task status to BLOCKED
- Created: Documentation of impossibility

## Rollback/Contingency

If implementation fails:
1. `git checkout -- Theories/Bimodal/Metalogic/Bundle/`
2. Run `lake build` to restore working state
3. Update task to BLOCKED status

## Why This Differs from v1

| Aspect | v1 Plan | v2 Plan |
|--------|---------|---------|
| Approach | Add `successor_p_step_axiom` | Use existing temp_a infrastructure |
| Axioms | +1 new axiom | No new axioms |
| Confidence | High (axiom trivially works) | Medium (proof may not exist) |
| Fallback | None needed | Block task if impossible |

## Semantic Analysis

The core question: Why might a proof exist without an axiom?

**Predecessor case (works)**: The seed `h_content(u) ∪ pastDeferralDisjunctions(u)` contains explicit P-formulas from u. When extended by Lindenbaum, the resulting MCS inherits these P-step properties from the seed.

**Successor case (unclear)**: The seed `g_content(u) ∪ deferralDisjunctions(u)` has no P-content. However:
- `temp_a: φ → G(P(φ))` means any formula in u generates P-formulas in successors
- If P(φ) ∈ v (successor) and it came from temp_a, then φ ∈ u
- The question: can ALL P-formulas in v be traced back this way?

This is what Phase 1 will investigate.
