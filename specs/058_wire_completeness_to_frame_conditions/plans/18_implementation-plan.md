# Implementation Plan: Task #58 (v18)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure)
- **Research Inputs**: reports/82_team-research.md (systematic 4-teammate review)
- **Artifacts**: plans/18_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the completeness wiring for task 58 based on the systematic team research (report 82). The 3 sorries in `FrameConditions/Completeness.lean` (lines 120, 163, 214) all reduce to one: `bundle_validity_implies_provability`. The research identified a tiered approach: (1) immediate 3-to-1 sorry reduction via typeclass plumbing, (2) targeted audits of Z-chain sorries and deferral disjunction seeds, (3) the hard mathematical problem (Z_chain_forward_F dovetailing) if no shortcut exists.

### Research Integration

Key findings from report 82 integrated into this plan:
- **Root Problem**: Gap between bundle-level temporal coherence (what we have) and family-level temporal coherence (what `parametric_shifted_truth_lemma` requires)
- **Immediate Win**: Wire `dense_completeness_fc` and `discrete_completeness_fc` through `completeness_over_Int` (typeclass plumbing, not new math)
- **Z-chain Sorries**: Lines 2347/2369 (G/H crossing case) may be tractable engineering; lines 2485/2494 (forward_F/backward_P) are the dovetailing argument
- **Deferral Disjunction Seeds**: Untested approach that may eliminate G-lift barrier entirely
- **Dead Ends Confirmed**: Bundle-level truth lemma, forward-only truth lemma, algebraic bypass, multi-BRS consistency via G-lift

## Goals and Non-Goals

**Goals**:
- Reduce 3 sorries to 1 via typeclass plumbing (Tier 1)
- Audit Z-chain crossing-case sorries for tractability (Tier 2A)
- Test deferral disjunction seed approach (Tier 2B)
- Establish clear path forward for remaining work (Tier 2C or Tier 3)

**Non-Goals**:
- Complete elimination of all sorries (this is Tier 3 mathematical research)
- Re-attempting any of the 24 definitively dead approaches
- Modifying the semantics of `valid_over` or `TaskModel`

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Z-chain crossing sorries are G-lift barrier instances | Medium | Medium | Quick audit distinguishes tractable vs. fundamental |
| Deferral disjunction seeds break `bounded_witness` | High | Low | Small proof-of-concept before full integration |
| Tier 2 reveals no shortcut, requiring Tier 3 | Medium | Medium | Document findings for future work; this is acceptable progress |

## Implementation Phases

### Phase 1: Wire 3 Sorries to 1 [COMPLETED]

**Goal**: Reduce the 3 sorries in Completeness.lean to delegate through `completeness_over_Int`, making the dependency explicit.

**Tasks**:
- [ ] Modify `dense_completeness_fc` (line 115) to delegate through `completeness_over_Int`
- [ ] Modify `discrete_completeness_fc` (line 158) to delegate through `completeness_over_Int`
- [ ] Verify both theorems type-check with the delegation
- [ ] Update docstrings to document the dependency chain
- [ ] Run `lake build` to confirm no new errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `lake build` succeeds
- All 3 sorries now trace to `bundle_validity_implies_provability`
- `#print axioms dense_completeness_fc` shows dependency on `bundle_validity_implies_provability`

---

### Phase 2: Audit Z-chain Crossing-Case Sorries [COMPLETED]

**Goal**: Determine if the sorries at lines 2347/2369 in UltrafilterChain.lean are tractable engineering problems or fundamental G-lift barrier instances.

**Tasks**:
- [ ] Read Z_chain_forward_G theorem structure (lines 2290-2375)
- [ ] Analyze the t < 0, t' >= 0 crossing case (line 2347)
- [ ] Analyze the t < 0, t' < 0 backward case (line 2369)
- [ ] Check if G-theory propagation through chain seam is provable
- [ ] Document findings: tractable (G_theory passes through M0) or blocked (G-lift barrier)
- [ ] If tractable: implement the seam-propagation proof

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (if tractable)

**Verification**:
- Clear determination of tractability for each sorry
- If tractable: sorries eliminated, `lake build` succeeds
- If blocked: document why (should match G-lift barrier pattern)

---

### Phase 3: Check Deferral Disjunction Seed Approach [COMPLETED]

**Goal**: Test whether using `psi OR F(psi)` instead of bare `psi` in BRS seeds eliminates the G-lift barrier.

**Tasks**:
- [ ] Locate the BRS seed construction in the codebase (temporal_theory_witness_exists or similar)
- [ ] Verify that `psi OR F(psi)` is already in the MCS (as deferral disjunction)
- [ ] Check if consistency of disjunction seed is trivially provable
- [ ] Check if `bounded_witness` theorem still extracts `psi` from disjunction-seeded extension
- [ ] If viable: create proof-of-concept modification
- [ ] Document findings with specific proof obligations that succeed/fail

**Timing**: 2 hours

**Files to modify**:
- Possibly `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (proof-of-concept)

**Verification**:
- Clear determination of viability
- If viable: document the modified seed construction
- If blocked: document which proof obligation fails and why

---

### Phase 4: Quick Check bot-in-deferralClosure [COMPLETED]

**Goal**: Check if bot (False) is in the deferral closure, which would provide an alternative consistency proof path.

**Tasks**:
- [ ] Locate deferralClosure definition
- [ ] Check if `bot NOTIN deferralClosure phi` is provable or assumed
- [ ] If bot is in closure: examine `drm_closed_under_derivation` for consistency path
- [ ] Document findings

**Timing**: 30 minutes

**Files to modify**:
- None (audit only)

**Verification**:
- Clear answer: bot in closure (alternative path exists) or bot not in closure (no shortcut)

---

### Phase 5: Document Path Forward [COMPLETED]

**Goal**: Based on Tier 2 findings, document the path forward for task 58.

**Tasks**:
- [ ] Summarize which Tier 2 audits succeeded vs. blocked
- [ ] If any shortcut found: create detailed implementation plan for completion
- [ ] If no shortcut found: document Tier 3 requirements (Z_chain_forward_F dovetailing)
- [ ] Update task status appropriately ([PARTIAL] or [BLOCKED] with clear next steps)
- [ ] Create summary artifact documenting progress

**Timing**: 1 hour

**Files to modify**:
- `specs/058_wire_completeness_to_frame_conditions/summaries/18_audit-summary.md` (new)
- `specs/TODO.md` (status update)
- `specs/state.json` (status update)

**Verification**:
- Clear documentation of findings
- Actionable next steps identified
- No ambiguity about what was tried vs. what remains

## Testing and Validation

- [ ] `lake build` succeeds after Phase 1
- [ ] `#print axioms` shows correct dependency chain after Phase 1
- [ ] Z-chain crossing-case audit produces clear determination (Phase 2)
- [ ] Deferral disjunction seed audit produces clear determination (Phase 3)
- [ ] bot-in-closure audit produces clear determination (Phase 4)
- [ ] Summary artifact documents all findings (Phase 5)

## Artifacts and Outputs

- Modified `Theories/Bimodal/FrameConditions/Completeness.lean` (Phase 1)
- Possibly modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (Phases 2-3)
- Summary at `specs/058_wire_completeness_to_frame_conditions/summaries/18_audit-summary.md`

## Rollback/Contingency

Phase 1 is pure refactoring with no functional change. If it introduces errors:
- Revert to current state where each sorry is independent
- The 3 sorries remain unchanged

Phases 2-4 are audits that may produce code changes only if shortcuts are found:
- If a shortcut attempt fails: revert the attempt, keep documentation
- No risk to existing functionality

Phase 5 is documentation only; no rollback needed.
