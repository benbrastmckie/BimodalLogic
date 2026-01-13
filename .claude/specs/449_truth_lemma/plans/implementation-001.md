# Implementation Plan: Task #449

- **Task**: 449 - Truth Lemma
- **Status**: [NOT STARTED]
- **Effort**: 15-17 hours
- **Priority**: Low
- **Dependencies**: Task 448 (completed), Task 458 (completed)
- **Research Inputs**: .claude/specs/449_truth_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the truth lemma for the finite canonical model, establishing that membership in finite world states corresponds to semantic truth evaluation. The theorem `finite_truth_lemma` has 8 sorry gaps across 6 formula cases (atom/bot proven, imp/box/all_past/all_future need work). The implementation follows a dependency order: closure infrastructure first, then imp case, then the more complex modal and temporal cases.

### Research Integration

Research report research-001.md identified:
- closure_mono as the key blocking lemma (unlocks all subformula containment)
- imp case straightforward once closure_mono proven
- box case requires canonical property reasoning
- temporal cases use respects_task from FiniteHistory structure
- Compositionality gaps from Task 458 do not block truth lemma

## Goals & Non-Goals

**Goals**:
- Complete all 8 sorry gaps in finite_truth_lemma
- Prove closure_mono and derived containment lemmas
- Establish canonical properties for box operator
- Prove temporal transfer composition for all_past/all_future

**Non-Goals**:
- Fixing compositionality gaps from Task 458 (separate concern)
- Lindenbaum extension (Task 472)
- Completeness theorems (Task 450, depends on this task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| closure_mono harder than expected | Medium | Low | Fall back to case-by-case subformula proofs |
| Box canonical property unclear | High | Medium | Consult Task 458 notes, may need auxiliary lemmas about history consistency |
| Missing Formula.subformulas_trans | Medium | Low | Implement in SignedFormula.lean as first step |
| Temporal cases need stronger respects_task | Low | Low | respects_task already provides full relation via finite_task_rel |

## Implementation Phases

### Phase 1: Closure Infrastructure [NOT STARTED]

**Goal**: Implement closure_mono and derived subformula containment lemmas to enable recursive IH applications in the truth lemma.

**Tasks**:
- [ ] Add Formula.subformulas_trans to SignedFormula.lean (transitivity of subformula relation)
- [ ] Prove closure_mono in FiniteCanonicalModel.lean using subformulas_trans
- [ ] Add derived lemmas: imp_in_closure_left, imp_in_closure_right
- [ ] Add derived lemmas: box_in_closure, all_past_in_closure, all_future_in_closure
- [ ] Verify no new sorries introduced

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Add subformulas_trans
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Prove closure_mono, add derived lemmas

**Verification**:
- lean_diagnostic_messages shows no errors in modified files
- closure_mono compiles without sorry
- All derived lemmas compile without sorry

---

### Phase 2: Implication Case [NOT STARTED]

**Goal**: Complete the imp case of finite_truth_lemma (2 sorries).

**Tasks**:
- [ ] Review current imp case structure in finite_truth_lemma
- [ ] Implement forward direction: h_imp and h_psi_true implies chi true
- [ ] Implement backward direction: semantic implication implies syntactic
- [ ] Use imp_in_closure_left/right from Phase 1 for IH application
- [ ] Verify imp case compiles without sorry

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete imp case

**Verification**:
- lean_goal at imp case shows no goals remain
- lean_diagnostic_messages shows no errors
- Sorry count reduced by 2

---

### Phase 3: Box Case [NOT STARTED]

**Goal**: Complete the box case of finite_truth_lemma (2 sorries). This requires establishing canonical properties about modal consistency across histories.

**Tasks**:
- [ ] Analyze finite_truth_at definition for box: quantifies over all FiniteHistory
- [ ] Forward: Show box(psi) at state t implies psi at all histories at t
- [ ] Consider adding auxiliary lemma for modal consistency if needed
- [ ] Use box_in_closure from Phase 1 for IH
- [ ] Backward: Show if psi holds at all histories, box(psi) in world state
- [ ] Use negation completeness of MCS for backward direction
- [ ] Verify box case compiles without sorry

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete box case, possibly add auxiliary lemmas

**Verification**:
- lean_goal at box case shows no goals remain
- lean_diagnostic_messages shows no errors
- Sorry count reduced by 2

---

### Phase 4: Temporal Cases [NOT STARTED]

**Goal**: Complete all_past and all_future cases of finite_truth_lemma (4 sorries total, 2 each).

**Tasks**:
- [ ] Review FiniteHistory.respects_task structure
- [ ] Implement all_future forward: Use future transfer from finite_task_rel
- [ ] Implement all_future backward: Use negation completeness
- [ ] Apply same pattern for all_past case (reversed direction)
- [ ] Use all_past_in_closure/all_future_in_closure for IH
- [ ] Verify both temporal cases compile without sorry

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Complete temporal cases

**Verification**:
- lean_goal at temporal cases shows no goals remain
- lean_diagnostic_messages shows no errors
- Sorry count reduced by 4

---

### Phase 5: Integration and Verification [NOT STARTED]

**Goal**: Verify complete truth lemma and ensure no regressions in FiniteCanonicalModel.lean.

**Tasks**:
- [ ] Run full diagnostic on FiniteCanonicalModel.lean
- [ ] Count remaining sorries (should be reduced by 8 from truth lemma)
- [ ] Verify finite_truth_lemma has no sorry
- [ ] Document any auxiliary lemmas added
- [ ] Run lake build to verify project compiles

**Timing**: 1-2 hours

**Files to modify**:
- None (verification only)

**Verification**:
- lake build succeeds
- lean_diagnostic_messages on FiniteCanonicalModel.lean shows only expected sorries (not in truth lemma)
- finite_truth_lemma proof complete

## Testing & Validation

- [ ] lean_goal confirms no remaining goals in finite_truth_lemma
- [ ] lean_diagnostic_messages shows no new errors
- [ ] lake build completes successfully
- [ ] Sorry count in FiniteCanonicalModel.lean reduced by 8 (truth lemma sorries)
- [ ] All derived lemmas (closure containment) compile without sorry

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - subformulas_trans lemma
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - completed truth lemma
- `.claude/specs/449_truth_lemma/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If implementation encounters blocking issues:
1. Preserve all completed phases (each phase is independently valuable)
2. Document blocking issue in errors.json
3. Mark remaining phases [BLOCKED] with reason
4. Consider creating subtask for blocking issue resolution

If closure_mono approach fails:
- Fall back to direct case-by-case subformula proofs
- More verbose but avoids transitive dependency

If box case canonical property proves intractable:
- Consult original Task 257 research (research-001.md through research-008.md)
- Consider strengthening FiniteWorldState definition
- May require Task 458-style revision
