# Implementation Plan: Task #488

- **Task**: 488 - fill_remaining_bridge_lemmas
- **Status**: [PARTIAL]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: Task 473 (completed), Task 481 (completed), Task 482 (completed)
- **Research Inputs**: specs/488_fill_remaining_bridge_lemmas/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Fill the remaining bridge lemmas and infrastructure sorries in FiniteCanonicalModel.lean. The research identified 34 sorries total, but only a subset are on the critical path or provide meaningful infrastructure value. This plan focuses on the **high and medium priority sorries** identified in research: bridge lemmas connecting finite and semantic worlds, transfer requirements consistency proofs, and the MCS projection maximality case. Deprecated syntactic approach sorries and edge-case compositionality sorries are explicitly excluded per research recommendations.

### Research Integration

Research report research-001.md (2026-01-13) identified:
- **34 total sorries** across 4 categories
- **Core completeness is proven** via semantic approach (not blocked)
- **High priority**: MCS projection maximality (1 sorry)
- **Medium priority**: Bridge lemmas (4), Transfer consistency (2)
- **Low priority/exclude**: Compositionality edge cases, deprecated syntactic approach

## Goals & Non-Goals

**Goals**:
- Fill MCS projection maximality sorry to clean up projection infrastructure
- Fill forward/backward transfer requirements consistency proofs
- Fill bridge lemmas connecting finite histories to semantic world histories
- Ensure lake build succeeds after each phase
- Reduce sorry count by 5-7 (from meaningful categories)

**Non-Goals**:
- Fill deprecated syntactic approach sorries (~12) - kept for documentation
- Fill compositionality edge cases (x<0, y<=0) - don't arise in completeness proof
- Achieve zero sorries - some acceptable per documentation
- Refactor existing proven infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure not closed under negation | High | High | Use closureWithNeg or prove closure closure property |
| Time arithmetic edge cases complex | Medium | Medium | Heavy use of omega tactic, careful case splits |
| Transfer consistency requires deep deduction reasoning | Medium | Medium | Use contrapositive via soundness theorem |
| Formula induction tedious for truth bridges | Low | High | Break into sub-lemmas per constructor |

## Implementation Phases

### Phase 1: MCS Projection Maximality [IN PROGRESS]

**Goal**: Fill the high-priority `mcs_projection_is_closure_mcs` maximality sorry (line ~3014)

**Tasks**:
- [ ] Analyze the current maximality proof structure
- [ ] Determine if closureWithNeg is needed or if existing closure suffices
- [ ] If needed, define helper lemma showing closure contains negations of relevant formulas
- [ ] Fill the maximality case using negation-completeness of MCS
- [ ] Verify with `lean_goal` at the sorry position
- [ ] Run `lake build` to verify no regressions

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FiniteCanonicalModel.lean` (line ~3014)

**Verification**:
- Sorry at line 3014 eliminated
- `lake build` succeeds
- `lean_diagnostic_messages` shows one fewer sorry

---

### Phase 2: Transfer Requirements Consistency [NOT STARTED]

**Goal**: Fill the two transfer requirements consistency sorries (lines ~2783, ~2819)

**Tasks**:
- [ ] Analyze `forwardTransferRequirements_consistent` structure
- [ ] Implement proof using contrapositive: if requirements inconsistent, G-formula derivation leads to contradiction
- [ ] Use soundness theorem to bridge semantic/syntactic reasoning
- [ ] Fill `backwardTransferRequirements_consistent` using dual argument
- [ ] Verify both proofs with `lean_goal`
- [ ] Run `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FiniteCanonicalModel.lean` (lines ~2783, ~2819)

**Verification**:
- Both transfer consistency sorries eliminated
- `lake build` succeeds
- Transfer requirements can be used in subsequent proofs

---

### Phase 3: Finite History Bridge Lemmas [NOT STARTED]

**Goal**: Fill `finiteHistoryToWorldHistory.respects_task` and `semantic_world_state_has_world_history`

**Tasks**:
- [ ] Analyze `finiteHistoryToWorldHistory.respects_task` at line ~3189
- [ ] Implement proof handling clamped time domain [-k, k]
- [ ] Case split on whether t is in bounds vs clamped at boundary
- [ ] Use `semantic_task_rel_v2` properties for the core argument
- [ ] Analyze `semantic_world_state_has_world_history` at line ~3208
- [ ] Implement using `time_shift` to position witnessing history at origin
- [ ] Verify with `lean_goal` at each position
- [ ] Run `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FiniteCanonicalModel.lean` (lines ~3189, ~3208)

**Verification**:
- Both bridge lemma sorries eliminated
- `lake build` succeeds
- History to world history connections established

---

### Phase 4: Gluing Relation Preservation [PARTIAL]

**Goal**: Fill `glue_histories.forward_rel` and `glue_histories.backward_rel` (lines ~2171, ~2174)

**Tasks**:
- [ ] Analyze the glue_histories structure from Task 482
- [ ] Implement `forward_rel` with case analysis: before junction, at junction, after junction
- [ ] Use `glue_histories_before_junction`, `glue_histories_at_junction`, `glue_histories_after_junction` lemmas
- [ ] Implement `backward_rel` using dual case analysis
- [ ] Verify correctness at junction boundary conditions
- [ ] Run `lake build`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FiniteCanonicalModel.lean` (lines ~2171, ~2174)

**Verification**:
- Both gluing relation sorries eliminated
- `lake build` succeeds
- Gluing preserves task relations in both temporal directions

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_diagnostic_messages` shows decreasing sorry count
- [ ] No new errors or warnings introduced
- [ ] `semantic_weak_completeness` remains proven (unaffected)
- [ ] Core completeness infrastructure intact

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FiniteCanonicalModel.lean` - Updated with filled sorries
- `specs/488_fill_remaining_bridge_lemmas/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If any phase encounters blocking issues:
1. Keep partial progress (each phase is independent)
2. Mark problematic sorry with `-- TODO: Task 488 - {reason}`
3. Document blocking issue in summary
4. Consider creating follow-up task for complex cases

If closure negation issues prove fundamental:
1. Document the structural limitation
2. Consider if closureWithNeg infrastructure needed as separate task
3. Mark as acceptable sorry with justification
